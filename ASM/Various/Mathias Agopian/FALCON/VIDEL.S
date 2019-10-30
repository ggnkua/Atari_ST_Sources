*
* Palettes ‚tendues II pour START MICRO MAG
* (c) 1993 AGOPIAN Mathias
*

*
* Les macros
*

SUPERVISEUR	MACRO
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,\1
		ENDM
		
UTILISATEUR	MACRO
		move.l	\1,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		ENDM


*
* Statup sequence
*

* R‚cup‚ration de la ligne de commande

	move.l	4(sp),a6	; Adresse de la base page dans A6
	lea	$80(a6),a6	; Adresse de la ligne de commande dans A6

* Initialiser la m‚moire

	move.l	a7,a5		; Start up s‚quence, habituelle
	move.l	#pile,a7	; On se cr‚e un nouveau pointeur de pile
	move.l	$4(a5),a5	; Adresse de la base page
	move.l	$c(a5),d0	; Taille du segment TEXT
	add.l	$14(a5),d0	; Plus taille du segment DATA
	add.l	$1c(a5),d0	; Plus taille du segment BSS
	add.l	#$100,d0	; Plus taille de la base bage
	move.l	d0,-(sp)	; ‚gal zone … r‚server
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)	; Mshrink
	trap	#1
	lea	12(sp),sp


	; GETDTA
	move.w	#$2f,-(sp)	; On r‚cupŠre l'adresse de la DTA
	trap	#1		; DTA = Disc Transfert Adresse
	addq.w	#2,sp
	move.l	d0,old_dta

	; SETDTA
	move.l	#dta,-(sp)	; On met notre propre DTA
	move.w	#$1a,-(sp)	; La DTA est un buffert de 44 octets
	trap	#1		; utilis‚ par les fonctions d'acces disque
	addq.w	#6,sp
	
	bsr	command		; Charger l'image pass‚e par la ligne de commande
	bra	error?		; Y a-t-il eu une erreur?
Post_Scriptum
	clr.l	d7
	bsr	fileselect	; Page principale, chargement
error?	cmp.l	#'_ERR',d7	; Erreur ?
	beq	fini		; oui, on recommence tout
	clr.l	d7		; non, l'image est charg‚e


* Initialisation.


	bsr	save		; On sauvegarde le contexte
	bsr	init		; On initialise le notre
	cmp.l	#'_ERR',d7	; Erreur?
	beq	fini		; Oui, on recommence tout

* c'est parti...	


targa	move.l	tga,a1		; Adresse de l'image 24bits
	lea	18(a1),a1	; On saute l'entete
	move.w	xres,d0		; xmax+ymax*largueur_de_l'‚cran
	mulu	yres,d0		; 
	add.l	d0,d0
	add.l	d0,d0
	move.l	screen,a3	; Adresse de l'‚cran
	lea	(a3,d0.l),a2	; plus offset=adresse de fin de l'‚cran
	
	lea	vide,a4		; Pour vider TRES rapidement les registres
.loop	movem.l	(a4),d0-d5	; On vide les registres

				; d0,d1,d2 sont les trois premiers pixels ‚l‚mentaires
				; d3,d4,d5 sont les trois seconds pixels ‚l‚mentaires
				
	move.b	(a1)+,d0	; Bleu	(entre 0 et 255)
	lsr.b	#3,d0		; divis‚ par 8	(-> entre 0 et 63)
	addx.b	d0,d3		; plus 1 si retenue
	
	move.b	(a1)+,d1	; Vert
	lsr.b	#2,d1		; divis‚ par 4
	addx.b	d1,d4		; plus 1 si retenue
	
	move.b	(a1)+,d2	; Rouge
	lsr.b	#3,d2		; divis‚ par 8
	addx.b	d2,d5		; plus 1 si retenue

	cmp.b	#31,d3		; On v‚rifie que d3,d4,d5
	bls.s	.ok1		; ne d‚passe pas respectivement
	move.b	#31,d3		; 31,63,31
.ok1	cmp.b	#63,d4
	bls.s	.ok2
	move.b	#63,d4
.ok2	cmp.b	#31,d5
	bls.s	.ok3
	move.b	#31,d5

.ok3	move.w	d0,d6		; On forme un mot au format
	lsl.w	#5,d1		; TRUE COLORS, a partir
	or.w	d1,d6		; de trois registres, contenant
	lsl.w	#5,d2		; le taux de rouge, vert et bleu.
	lsl.w	#6,d2
	or.w	d2,d6
	move.w	d6,(a3)+
	
	move.w	d3,d6		; Idem	
	lsl.w	#5,d4
	or.w	d4,d6
	lsl.w	#5,d5
	lsl.w	#6,d5
	or.w	d5,d6
	move.w	d6,(a3)+
	
	cmp.l	a2,a3		; On sort si on est ariv‚ … la fin 
	bls.s	.loop		; du buffer

	SUPERVISEUR d7		; On passe en superviseur
.scr	bsr	scroll_it	; Effectue le scroll et attend une VBL
	move.b	$fffc02,d0	; Lecture du clavier
	cmp.b	#$39,d0		; Si barre d'espace,
	beq.s	THE_END		; alors fin
	cmp.b	#$4d,d0		; Si roite
	beq.s	.right		; alors scrolle … droite
	cmp.b	#$4b,d0		; Si gauche
	beq.s	.left		; scrolle … gauche
	cmp.b	#$48,d0		; Si haut
	beq.s	.up		; scrolle haut
	cmp.b	#$50,d0		; Si bas
	beq.s	.down		; scrolle bas
	bra	.scr		; On recommance

* D‚placements

.right	add.l	#2,xscr		; Deux pixels, car on est en
	bra	.scr		; 640, si on remplace le #2 par #1
.left	sub.l	#2,xscr		; on obtient un scrolling au demi
	bpl.s	.scr		; pixel pres !
	clr.l	xscr		
	bra	.scr
.down	add.w	#1,yscr		; bas
	bra	.scr
.up	sub.w	#1,yscr		; haut
	bpl.s	.scr
	clr.w	yscr		
	bra	.scr
rte	rte

* On sort du programme

THE_END	UTILISATEUR d7		; Utilisateur
	bsr	clear_input	; On vide le buffer clavier du GEM
	bsr	restore		; On remet tout en place

fini	move.l	tga,-(sp)	; MFREE
	move.w	#$49,-(sp)	; Libere la RAM
	trap	#1		; occup‚e par le fichier TGA
	addq.l	#6,sp

	move.l	screen,-(sp)	; MFREE
	move.w	#$49,-(sp)	; Celle occup‚e par notre
	trap	#1		; ‚cran virtuel
	addq.l	#6,sp
	
	move.l	old_dta,-(sp)	; SETDTA
	move.w	#$1a,-(sp)	; Remet la DTA en place
	trap	#1
	addq.l	#6,sp
	
	bra	Post_Scriptum	; On recommance TOUT

* Vide le buffer Clavier

clear_input
	move.w	#2,-(sp)	; Tant qu'il
	move.w	#1,-(sp)	; y a un caractŠre
	trap	#13
	addq.l	#4,sp
	tst.w	d0
	beq.s	.ok
	move.w	#2,-(sp)	; Lire ce caractŠre
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp
	bra	clear_input
.ok	rts
	

* Routine de scroll

scroll_it
	move.l	$462.w,d0	; Attendre la VBL
.wvbl	cmp.l	$462.w,d0
	beq.s	.wvbl
	move.l	max_x,d0	; V‚rifier que l'on ne scrolle
	cmp.l	xscr,d0		; Pas trop … droite
	bhs.s	.okx		; ou en bas
	move.l	d0,xscr
.okx	move.w	max_y,d0
	cmp.w	yscr,d0
	bhs.s	.oky
	move.w	d0,yscr
.oky	move.w	xres,d0		; Largeur de l'image en pixels
	add.w	d0,d0		; *2 car on est en 640 pixels
	add.w	d0,d0		; *2 pour l'avoir en octets
	mulu	yscr,d0		; Y*Largeur de l'‚cran en octet
	add.l	xscr,d0		; Plus deux fois X (car on veut
	add.l	xscr,d0		; le r‚sulat en octets)
	add.l	screen,d0	; Plus l'adresse de l'‚cran
	move.l	d0,scroll	; -> adresse de l'‚cran physique pour le scroll.
	move.b	scroll+1,$ffff8201.w	; Poids fort
	move.b	scroll+2,$ffff8203.w	; Poids moyen
	move.b	scroll+3,$ffff820d.w	; Poids faible
	rts
		
set_my_mode
	move.l	tga,a0		; Adresse de l'image
	move.b	12(a0),xres+1	; Format INTEL, pouahhh..
	move.b	13(a0),xres+0	; on r‚cupere la largeur
	move.b	14(a0),yres+1	; et la hauteur de l'image
	move.b	15(a0),yres+0
	move.w	xres,d0
	move.w	yres,d1
	mulu	d1,d0		; xres*yres pixels
	add.l	d0,d0		; en octets
	add.l	d0,d0		; *2 car on double la taille horizontale
				; -> Zone minimum … r‚server pour l'‚cran virtuel

	cmp.l	#(768*480*2),d0 ; <- Mais il faut r‚server au moins ‡a!
	bhs.s	.ok
	move.l	#(768*480*2),d0
.ok	move.l	d0,-(sp)	; MALLOC
	move.w	#$48,-(sp)	; R‚servation
	trap	#1
	addq.l	#6,sp
	lea	err5,a0
	tst.l	d0
	bmi	erreur
	move.l	d0,screen	; Adresse de l'‚cran

	move.w	#320,nbc	; Nombre de colones
	move.w	#400,nbl	; Nombre de ligne en entrelac‚
	move.w	#80,d3		; … ajouter … Y si overscan (20%)
	move.w	#%100101100,d1	; 640*400*65536	-> mode entrelac‚
	clr.l	d0		; L…, on d‚termine
	clr.l	d2		; l'aspect Ratio, c'est … dire
	move.w	xres,d0		; Si l'on doit utilis‚ l'entrelac‚
	move.w	yres,d2		; ou non
	divu	d2,d0
	tst.w	d0
	beq.s	.setres
	move.w	#200,nbl	; non, alors 200 lignes
	move.w	#40,d3		; … ajouter si overscan	(20%)
	move.w	#%000101100,d1	; 640*200*65536 -> non entrelac‚

.setres	cmp.w	#320,xres	; On test si on a besoin de
	bls.s	.allez		; l'overscan
	or.w	#$40,d1		; oui->Overscan
	move.w	#384,nbc	; alors 384 colones et pas 320
	add.w	d3,nbl		; plus 20% pour le nombre de ligne

.allez	move.w	d1,-(sp)	; SETSCREEN
	move.w	#3,-(sp)	; On change de r‚solution
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp

* Registres HARD, pour le HARDSCROLL !

	move.w	xres,d0		; Largeur totale-zone affich‚e
	sub.w	nbc,d0		; On obtient la "surlargeur"
	add.w	d0,d0		; de l'‚cran...
	bmi.s	.rien
	cmp.w	#511,d0		; Mais une bizzarerie du VIDEL
	bls.s	.ok1		; fait que le LINEOFFSET doit etre
	move.w	#511,d0		; inf‚rieur (strictement) … 512.
	move.w	xres,d1		; Sinon, on triche en augmentant
	add.w	d1,d1		; Le LINEWIDTH qui peut monter
	sub.w	d0,d1		; jusqu'a 1023
	move.w	d1,$ffff8210.w	; LINEWIDTH en mots
.ok1	move.w	d0,$ffff820e.w	; LINEOFFSET en mots
	bra	.return
.rien	move.w	xres,d0
	add.w	d0,d0
	move.w	d0,$ffff8210.w	; LINEWIDTH
.return	clr.l	$ffff9800.w	; Bon, *‡a* c'est pas tres *l‚gal*
	rts			; (c'est pour avoir le border noir)

* Routine d'initialisation

init	SUPERVISEUR	d5	; Superviseur
	bsr	set_my_mode	; On passe dans la bonne r‚solution
	clr.l	xscr		; On d‚termine le scroll maximum vers
	clr.w	yscr		; la droite et vers le bas.
	clr.l	d0
	clr.l	max_x		; max en PIXELS
	move.w	xres,d0
	sub.w	nbc,d0
	add.w	d0,d0
	bmi.s	.set_y
	ext.l	d0
	move.l	d0,max_x
.set_y	clr.w	max_y		; en lignes
	move.w	yres,d0
	sub.w	nbl,d0
	bmi.s	.ok
	move.w	d0,max_y
.ok	UTILISATEUR	d5	; Utilisateur
	rts

save	move.w	#-1,-(sp)	; On sauve la r‚solution
	move.w	#3,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	move.w	d0,oldrez
	move.w	#2,-(sp)		; On sauve
	trap	#14			; l'adresse de l'‚cran.
	addq.l	#2,sp			; -> D0
	move.l	d0,oldscr
	rts

restore	move.w	oldrez,-(sp)		; Et hop...
	move.w	#3,-(sp)		; On remet la r‚solution
	move.l	oldscr,-(sp)		; et l'‚cran initial.
	move.l	oldscr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	rts



* Ligne de comande

command	clr.l	d0		; Le premier octet
	move.b	(a6)+,d0	; de la ligne de commande
	beq.s	fileselect	; contient sa longueur (si=0 alos fileselect)
	clr.b	(a6,d0.w)	; On place zero … la fin de la ligne de commande
	bra	load		; On charge l'image

* S‚lecteur de fichier

fileselect
	lea	texte,a0	; Texte d'introduction
	bsr	print	
	
	lea	buffer,a6	; Saisir une chaine au clavier
	move.b	#64,(a6)
	clr.b	1(a6)
	move.l	a6,-(sp)
	move.w	#$a,-(sp)
	trap	#1
	addq.w	#6,sp

	addq.w	#2,a6
	clr.b	(a6,d0.w)	; le dernier octet DOIT etre nul

load	lea	dummy,a0
	bsr	print


* D‚ja, il faut d‚terminer la taille du fichier
* puis on R‚serve la m‚moire
	
	; FSFIRST
	clr.w	-(sp)		; On cherche le fichier
	move.l	a6,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	lea	err1,a0
	tst.l	d0
	bmi	erreur		; On ne l'a pas trouv‚ !
	
	; GETDTA
	move.w	#$2f,-(sp)	; On cherche l'adresse de la DTA
	trap	#1
	addq.l	#2,sp
	lea	err1,a0
	tst.l	d0
	bmi.s	erreur
	move.l	d0,a0
	move.l	26(a0),d6	; En DTA+26 on trouve la taille
				; Du fichier -> D6
				
	; MALLOC	
	move.l	d6,-(sp)	; On r‚serve la RAM
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	err5,a0
	tst.l	d0
	bmi.s	erreur
	move.l	d0,tga

* On ouvre le fichier

	clr.w	-(sp)	
	move.l	a6,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	lea	err1,a0
	tst.l	d0
	bmi.s	erreur
	move.w	d0,handle

* On charge le fichier

	move.l	tga,-(sp)
	move.l	d6,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	adda.l	#12,sp
	lea	err2,a0
	tst.l	d0
	bmi.s	erreur
	
* On ferme le fichier

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	lea	err3,a0
	tst.l	d0
	bmi.s	erreur
	rts


erreur	bsr	print
	lea	touche,a0
	bsr	print

* On attend une touche

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

* flag pour erreur

	move.l	#'_ERR',d7
	rts
	
* Routine qui affiche un texte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
	

* Les donn‚es initialis‚es
	
	SECTION	DATA
vide	DCB.L	16
err1	DC.B	'Fichier introuvable !',0
err2	DC.B	'Erreur pendant la lecture du fichier !',0
err3	DC.B	'Erreur pendant la fermeture du fichier !',0
err5	DC.B	'Pas assez de m‚moire !',0
touche	DC.B	10,13,'Appuyez sur une touche.',0
	
texte	DC.B	27,'E',27,'e'
	DC.B	'Les palettes ‚tendues V. F030'
	DC.B	10,13
	DC.B	' Par AGOPIAN Mathias '
	DC.B	'                     '
	DC.B	10,13,10,13
	DC.B	' 504063 couleurs en ',10,13
	DC.B	' True colors sur le ',10,13
	DC.B	' Falcon 030 h‚h‚...'
	DC.B	10,13,10,13
	DC.B	'[CTRL+C] pour quitter.'
	DC.B	10,13
	DC.B	'Les touches du curseur pour scroller'
	DC.B	10,13,10,13
	DC.B	'Entrez le nom de l''image :'
	DC.B	10,13
	DC.B	'(fichier TGA type 2 [POV] )'
	DC.B	10,13,10,13
	DC.B	' Nom : ',0
dummy	DC.B	27,'E',27,'f',0
	even

	; Buffer pour le nom du
	; Fichier.
	
buffer	DC.B	64
	DC.B	0
	DCB.B	67
	even
	
* Les variables

		SECTION BSS
xscr		DS.L	1
yscr		DS.W	1
xres		DS.W	1
yres		DS.W	1
max_x		DS.L	1
max_y		DS.W	1
nbc		DS.W	1
nbl		DS.W	1
scroll		DS.L	1
handle		DS.W	1
oldrez		DS.W	1
dta		DS.B	44
old_dta		DS.L	1
add_qrt		DS.L	1
oldscr		DS.L	1
tga		DS.L	1
screen		DS.L	1
		DS.L	$400
pile		DS.L	1

