;
; Exemple de programme TTP avec r‚cup‚ration de paramŠtres.
; Encodeur de fichier ASCII.
; Programmation : P-Jean Goulier.
; ½ Start Micro & P-Jean Goulier / 1994.
;
; Les sources ont ‚t‚ d‚velopp‚s sur ASSEMBLE ½ BRAINSTORM.
; 100% compatible avec l'assembleur traditionnel.
; Utilisation des bibliothŠques MACROSYS et UTILES ½ P-Jean Goulier.
; Utilisation de la bibliothŠque AES ½ Brainstorm

	INCLUDE MACROSYS.S		; Macros du TOS.
	INCLUDE UTILES.S		; Macros utilitaires.
	OUTPUT	CODEUR.TTP		; Sortie du programme en TTP.
	
	TEXT
	
start:	move.l	4(sp),a5		; R‚cup‚ration de l'adresse de la
	lea	$80(a5),a5		; basepage et de la command-tail.
	move.b	(a5)+,d0		; Longueur de la command-tail.
	beq	no_command		; Si L = 0, pas de command-tail.
	lea	filename,a4		; On ‚crit le nom du fichier
.loop	move.b	(a5)+,(a4)+		; … l'adresse filename.
	subq.b	#1,d0
	bne.s	.loop
	clr.b	(a4)			; On met un octet nul … la fin.
	
	init_prg #1024			; Initialisation du programme.
	tst	d0			; Si D0 <> 0, tout va mal !
	bne	memory_error
	
	clr.l	d6			; D6 = Drapeau d'erreur pour shell.
	fsetdta	#dta			; Fixer le tampon DTA pour les fichiers.
	fsfirst	#filename,#0		; Chercher le fichier.
	tst	d0
	bmi	not_found		; Si D0 < 0, fichier non trouv‚.
	
	malloc	size			; R‚servation de m‚moire pour charger le fichier.
	tst	d0
	beq	memory_error		; Si D0 = 0, problŠme m‚moire.
	move.l	d0,buffer		; On sauve l'adresse r‚serv‚e.
		
	fopen	#filename,#2		; Ouverture du fichier en R/W.
	tst	d0
	bmi	file_error		; Si D0 < 0, erreur !
	move	d0,d7			; Sinon D7 = handle.
	
	fread	d7,size,buffer		; Lecture du fichier.
	tst	d0
	bmi	read_error		; Si D0 < 0, erreur de lecture.
	
coding:	move.l	buffer,a0
	move.l	size,d0
	dec.l	d0
.loop	eor.b	#49,(a0)+		; Coder le fichier octet par octet.
	dbra	d0,.loop		; 49 est une valeur arbitraire !
	
	fseek	#0,d7,#0		; Remettre le pointeur du fichier au d‚but.
	fwrite	d7,size,buffer		; Ecriture du fichier.
	tst	d0
	bmi	write_error
	
	fclose	d7			; Fermeture du fichier.
	mfree	buffer			; Lib‚ration du buffer.
	
	lea	text_ok,a0		; Affichage du message d'encodage.
	bsr	print
exit:	bsr	waitkey			; Attente d'une touche.
	pterm	d6			; Fin du programme. Si une erreur
					; s'est produite, le programme envoie
					; la valeur -1 … un shell ‚ventuel.

no_command:
	lea	command_text,a0
	bra	display
	
memory_error:
	move	#-1,d6
	lea	memory_text,a0
	bra	display
	
not_found:
	move	#-1,d6
	lea	found_text,a0
	bra	display
	
read_error:
	move	#-1,d6
	lea	read_text,a0
	bra	display
	
write_error:
	move	#-1,d6
	lea	write_text,a0
	bra	display
	
file_error:
	move.l	#-1,d6
	lea	file_text,a0

display:
	bsr	print
	bra	exit
		
print:	cconws	a0
	rts
	
waitkey:
	crawcin
	rts
	
	DATA

command_text:
	DC.B	27,"E",27,"f",10
	DC.B	"Vous devez entrer un nom de fichier sur",10,13
	DC.B	"la ligne de commande, ou amener l'ic“ne",10,13
	DC.B	"du fichier  … encoder sur CODEUR.TTP...",10,13
	DC.B	"Vous pouvez ‚galement installer le pro-",10,13
	DC.B	"gramme en  application  … partir du bu-",10,13
	DC.B	"reau; il s'ex‚cutera par un double clic",10,13
	DC.B	"sur le fichier … encoder.",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
memory_text:
	DC.B	27,"E",27,"f",10
	DC.B	"Probl‚me m‚moire... D‚sol‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
read_text:
	DC.B	27,"E",27,"f",10
	DC.B	"Erreur de lecture... D‚sol‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
write_text:
	DC.B	27,"E",27,"f",10
	DC.B	"Erreur d'‚criture... D‚sol‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
found_text:
	DC.B	27,"E",27,"f",10
	DC.B	"Fichier non trouv‚... D‚sol‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
file_text:
	DC.B	27,"E",27,"f",10
	DC.B	"ProblŠme de handle... D‚sol‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
text_ok:
	DC.B	27,"E",27,"f",10
	DC.B	"Encodage/D‚codage du fichier r‚alis‚ !",10,10,13
	DC.B	27,"p","Appuyez sur une touche...",27,"q",0
	
	BSS

buffer:	DS.L	1
	
dta:	DS.B	21
attr:	DS.B	1
	EVEN
hour:	DS.W	1
date:	DS.W	1
size:	DS.L	1
name:	DS.B	14

filename:
	DS.B	128
