;
; Programme de conversion d'un fichier *.LST (ORCS)
; en un fichier Basic Omikron (*.BAS).
; Programme TTP.
;
; ½ Pierre-Jean Goulier & Start Micro / 1993.
;

	section	text
	
	output	convorcs.ttp	; Sortie du fichier en TTP.
	
	move.l	4(sp),a5	; R‚cup‚ration de l'adresse de la
	lea	$80(a5),a5	; basepage et de la command-tail.
	move.b	(a5)+,d0	; Longueur de la command-tail.
	beq	install		; Si L=0, pas de command-tail.
	lea	filename,a4	; On ‚crit le nom du fichier
get_filename:			; … l'adresse filename.
	move.b	(a5)+,(a4)+
	subq.b	#1,d0
	bne.s	get_filename
	clr.b	(a4)		; On met un octet nul … la fin.
	
	move.l	4(sp),a5	; A5 = d‚but de la basepage.
	move.l	$c(a5),d0	; D0 = taille domaine prg
	add.l	$14(a5),d0	;    + taille domaine data
	add.l	$1c(a5),d0	;    + taille domaine bss
	add.l	#$100,d0	;    + 256 octets pour la basepage
	add.l	#$400,d0	;    + 1 Ko de pile.
	move.l	d0,d1
	add.l	a5,d1		; Adresse du sommet de la pile => D1.
	and.l	#-2,d1		; Forcer adresse paire.
	movea.l	d1,sp		; Adresse de la nouvelle pile.
	move.l	d0,-(sp)	; Taille du domaine … r‚server.
	move.l	a5,-(sp)	; Adresse du domaine … r‚server (old sp).
	clr	-(sp)		; R‚serv‚ systŠme.
	move	#$4a,-(sp)	; Fonction Mshrink.
	trap	#1
	lea	12(sp),sp
	tst	d0		; Si D0<>0, tout va mal !
	bne	memory_error
	
	pea	dta		; Fixer tampon DTA.
	move	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move	#0,-(sp)	; Chercher fichier.
	pea	filename
	move	#$4e,-(sp)
	trap	#1
	lea	8(sp),sp
	tst	d0		; Si D0<0, pas de fichier.
	bmi	not_found
	
test:	lea	nom,a0		; Est-ce un fichier *.LST ?
	clr.l	d0
	clr.l	d1
.loop	move.b	(a0)+,d1	; O— se trouve l'extension du fichier ?
	cmp.b	#'.',d1
	beq.s	.found
	addq.b	#1,d0
	cmp.b	#9,d0
	beq	no_good_file	; Pas d'extension => No good !
	bra.s	.loop
.found	move.b	(a0)+,d0	; Est-ce la bonne extension ?
	cmp.b	#'L',d0
	bne	no_good_file
	move.b	(a0)+,d0
	cmp.b	#'S',d0
	bne	no_good_file
	move.b	(a0),d0
	cmp.b	#'T',d0		; C'est tout bon...
	bne	no_good_file
	
	move.l	long,-(sp)	; Reservation m‚moire pour
	move	#$48,-(sp)	; blocs 'source' et 'cible'.
	trap	#1
	addq.l	#6,sp
	tst	d0		; Si D0 = 0, problŠme m‚moire...
	beq	memory_error
	move.l	d0,source	; On sauve l'adresse du bloc source,
	move.l	long,-(sp)
	move	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst	d0		
	beq	memory_error
	move.l	d0,cible	; et du bloc cible.
	
	move	#2,-(sp)	; Ouverture du fichier.
	pea	filename
	move	#$3d,-(sp)
	trap	#1
	lea	8(sp),sp
	tst	d0
	bmi	disk_error
	move	d0,handle
	
	move.l	source,-(sp)	; Lecture du fichier dans 'Source'.
	move.l	long,-(sp)
	move	handle,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst	d0
	bmi	disk_error
	
	move	handle,-(sp)	; Fermeture du fichier.
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	bmi	disk_error
	
	pea	text_ok		; C'est parti !
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.l	source,a0	; Source => A0.
	move.l	cible,a1	; Cible => A1.
	
saut:	move.b	(a0)+,d0	; Pour commencer, on saute la 1Šre ligne (source).
	cmp.b	#$0a,d0		; Fin de ligne ?
	bne.s	saut

	move	#8,d1		; On ‚crit la s‚quence de s‚paration.
	lea	special,a2
.loop	move.b	(a2)+,(a1)+
	dbra	d1,.loop
	adda.l	#3,a0		; On corrige le pointeur source.
	
main:	adda.l	#4,a0		; On saute le "LET".

loop1:	move.b	(a0)+,d0	; Prendre un octet dans la source.
	cmp.b	#' ',d0		; Est-ce un espace ?
	beq.s	ok1		; Oui => Ok1.
	cmp.b	#"=",d0		; Le signe "=" alors ?
	beq.s	ok2		; Oui => Ok2.
	move.b	d0,(a1)+	; Non, on l'‚crit dans la cible.
	bra.s	loop1		; On y retourne...

ok2:	move.b	#'%',(a1)+	; On ‚crit le "%".
	move.b	d0,(a1)+	; On ‚crit le "=".
	bra.s	loop2
ok1:	move.b	#'%',(a1)+	; On ‚crit le "%".
loop2:	move.b	(a0)+,d0	; On continue...
	cmp.b	#'!',d0		; Est-ce un "!" ?
	beq.s	ok3		; Oui => Ok3.
	move.b	d0,(a1)+
	bra.s	loop2
	
ok3:	move.b	#$27,(a1)+	; On met le "'" … la place du "!".
	
loop3:	move.b	(a0)+,d0	; Jusqu'… la fin de la ligne...
	move.b	d0,(a1)+
	cmp	#$0a,d0
	bne.s	loop3
	
	move.b	(a0),d0		; Est-ce la derniŠre ligne ?
	cmp	#"'",d0
	beq.s	maybe		; Peut-ˆtre...
return:	move.b	#$20,(a1)+	; Non, on ‚crit les 3 espaces de
	move.b	#$20,(a1)+	; la ligne suivante,
	move.b	#$20,(a1)+
	bra	main		; et on boucle.
	
notyet:	move	#5,d1		; Sinon,
	lea	special,a2	; on recopie la s‚quence de s‚paration.
.loop	move.b	(a2)+,(a1)+	
	dbra	d1,.loop
	adda.l	#3,a0		; On corrige le pointeur source.
	bra.s	return
	
maybe:	move.l	a0,a2		; Comparons la taille du fichier et A0+3.
	suba.l	source,a2
	adda.l	#3,a2
	cmpa.l	long,a2
	bne.s	notyet		; Ce n'est pas encore la fin...
	
already:			; C'est d‚j… la fin, comme le temps passe...
	move	#5,d1
	lea	special,a2	; On recopie la s‚quence de s‚paration.
.loop	move.b	(a2)+,(a1)+	
	dbra	d1,.loop
	
						
write_file:			; Ecriture du fichier.
	lea	filename,a0	; On recherche la fin du nom.
.nonul:	move.b	(a0)+,d0
	bne.s	.nonul
	subq	#4,a0		; On se replace avant le "LST".
	move.b	#'B',(a0)+	; On place 'BAS" … la place.
	move.b	#'A',(a0)+
	move.b	#'S',(a0)+

	move.l	cible,a0	; Calcul de la taille de notre fichier.
	suba.l	a0,a1		; Taille => A1.
	
	clr	-(sp)		; Cr‚ation du nouveau fichier.
	pea	filename
	move	#$3c,-(sp)
	trap	#1
	lea	8(sp),sp
	tst	d0
	bmi	disk_error
	move	d0,handle
	
				; Ecriture du fichier.
	pea	def_proc	; "DEF_PROC Init_Rsc"
	move.l	#22,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst	d0
	bmi	disk_error
	
	move.l	cible,-(sp)	; Le fichier lui-mˆme.
	move.l	a1,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst	d0
	bmi	disk_error
	
	pea	end_proc	; "END_PROC"
	move.l	#11,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	tst	d0
	bmi	disk_error
	
	move	handle,-(sp)	; Fermeture du fichier.
	move	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst	d0
	bmi	disk_error
	
	move.l	source,-(sp)	; Lib‚ration de la m‚moire.
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	cible,-(sp)
	move	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	
exit:				; Fin du programme.
	clr.l	-(sp)		; Fonction Pterm0.
	trap	#1
	
wait_key:			; Attente d'une touche.
	move	#7,-(sp)	; Fonction Crawcin.
	trap	#1
	addq.l	#2,sp
	rts
	
print:				; Affichage d'un texte.
	pea	(a0)
	move	#9,-(sp)	; Fonction Cconws.
	trap	#1
	addq.l	#6,sp
	rts
	
install:
	lea	text_install,a0
	bra.s	common
	
memory_error:
	lea	text_mem,a0
	bra.s	common

not_found:
	lea	text_file,a0
	bra.s	common
	
disk_error:
	lea	text_disk,a0
	bra.s	common
	
no_good_file:
	lea	text_nogood,a0
	
common:
	bsr.s	print
	bsr.s	wait_key
	bra.s	exit

	section	data
		
text_ok:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	27,"p","CONVORCS / ",189," Annybal 1993.",27,"q",10,10,13
	dc.b	"Conversion *.LST => *.BAS en cours...",10,10,13,0
	
text_install:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	"Vous devez entrer un nom de fichier !",10,13
	dc.b	"Appuyez sur une touche...",0
	
text_mem:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	"Erreur m‚moire... D‚sol‚ !",10,10,13
	dc.b	"Appuyez sur une touche...",0
	
text_file:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	"Fichier introuvable... D‚sol‚ !",10,10,13
	dc.b	"Appuyez sur une touche...",0
	
text_disk:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	"Erreur disque... D‚sol‚ !",10,10,13
	dc.b	"Appuyez sur une touche...",0
	
text_nogood:
	dc.b	$1B,"E",$1B,"e",10
	dc.b	"Mauvais fichier... D‚sol‚ !",10,10,13
	dc.b	"Appuyez sur une touche...",0
	
def_proc:
	dc.b	$27,$0D,$0A,"DEF PROC Init_Rsc",$0D,$0A
end_proc:
	dc.b	"RETURN",$0D,$0A,$1A	; Si l'on possŠde l'Omikron 3.5
					; on pourra remplacer le "RETURN"
					; par "END_PROC", ce qui permettra
					; de refermer la proc‚dure au moyen
					; de [CTRL]+[D] (foldering).
	
special:
	dc.b	$20,$20,$20,$27,$0D,$0A,$20,$20,$20
	
	
	section	bss
	
source:	ds.l	1
cible:	ds.l	1
handle:	ds.w	1

filename:
	ds.b	128
	
dta:	ds.b	21
attr:	ds.b	1
	even
heure:	ds.w   1
date:	ds.w   1
long:	ds.l   1
nom:	ds.b   14
