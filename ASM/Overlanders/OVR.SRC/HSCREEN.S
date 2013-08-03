* NAME: THE H-SCREEN BY MISTER BEE
* GRAPHIXX: MISTER BEE
* SOME APPLE PICTURES CONVERT FOR
* ATARI BY MISTER BEE
* IDEM FOR THE FONT
* MUSIC: OVERLANDER GAME
* THIS SOURCE IS NOW FOR OVERLANDERS COMPIL
* (C)SEPTEMBRE 1989 MISTER BEE
*

	section	TEXT
	
;	ORG	$8000		origine en $8000
	
	pea	main
	move	#$26,-(sp)
	trap	#14
	lea	6(sp),sp
	
	clr	-(sp)
	trap	#1
	
* LA ROUTINE SUIVANTE EST LA ROUTINE
* PRINCIPALE, ELLE SE TERMINE PAR
* UN RTS EST DOIT ETRE EXECUTE EN
* MODE SUPERVISEUR. ELLE N'UTILISE
* AUCUNE TRAP
* LES REGISTRES MFP SONT CONSERVES
* AINSI QUE LA PALETTE
* L'ECRAN ACTUEL EST UTILISE
* ET EST EFFACE A LA FIN

main	move	#$2700,sr
	move.l	sp,svesp		sauve le pointeur de pile
	lea	stacked,sp	init stack pointeur
	movea	#$8201,a0		registre d'adresse video
	movep	(a0),d1
	and.l	#$ffff,d1
	lsl.l	#8,d1
	move.l	d1,phybase	adresse video dans phybase
	bsr	clrscr		efface l'ecran
	
	movem.l	$ffff8240,d0-d7	sauve la palette
	movem.l	d0-d7,svepal

	movem.l	palette,d0-d7	installe la palette
	movem.l	d0-d7,$ffff8240
	
	bsr	savemfp		preserve les registres de du mfp
	clr	cptxy		compteur de la table de deplacement du fond
	clr.l	ixtbl
	bsr	setgrd		calcul la table de donne pour le scroll du fond
	bsr	setitle		affichage de la plaque du titre
	bsr	setplaq		affichage de la plaque du picture show
	bsr	setanim		init variable pour animation
	bsr	clrbuf		efface les buffer pour le scroll
	bsr	init		initialise les variables pour le scroll
	bsr	setrst
	bsr	setspr		calcul de la table de donnee pour les sprites
	bsr	setas		init variable for sprite animation
	bsr	initpal		init var for setpal for background
	moveq #1,d0
	bsr 	player+$554	
* METTRE PAR LA L'INITIALISATION
* DE LA MUSIQUE

	bclr	#4,$fffa09	timer c off
	bclr	#5,$fffa09	timer d off
	
	move.l	$70,sve70		sauve le vecteur vbl
	move.l	#vbl,$70		installe la vbl
	bsr	sethbl   		installe la hbl
	
	move.l	$118,sve118	sauve le vecteur clavier
	move.l	#rte,$118		installe le vecteur clavier
	move	#$2300,sr	
	
key	cmp.b	#$39,$fffc02	attend l'appuie sur espace
	bne.s	key
	
	move	#$2700,sr		interdit les its
	bsr	clrhbl		arrete la hbl
	move.l	sve70,$70		restaure la vbl
	move.l	sve118,$118	restaure le clavier

	bset	#4,$fffa09	timer c on
	bset	#5,$fffa09	timer d on
	
*****************************
* REMETTRE LE BSR OLDMFP POUR LA 
* VERSION FINALE
* avec le gem il pause des problemes
* ( de quoi ca vient ? )

;	bsr	oldmfp		restaure le mfp

	move.l	#$8080000,$ffff8800	registres sonores a 0
	move.l	#$9090000,$ffff8800
	move.l	#$a0a0000,$ffff8800

	bsr	clrscr		efface l'ecran
	movem.l	svepal,d0-d7	et restaure la palette
	movem.l	d0-d7,$ffff8240
	movea.l	svesp,sp		restaure le pointeur de pile
	move	#$2300,sr		its normal
	rts
	
* efface l'ecran

clrscr	move.l	phybase,a0
	move	#7999,d0
clrscr2	clr.l	(a0)+
	dbf	d0,clrscr2
	rts
	
* routine interuption du clavier

rte	bclr	#6,$fffa11
	rte
	
* Routine de VBL

vbl	movem.l	d0-d7/a0-a5,-(sp)
	lea	bufreg5,a6	pointeur pour la hbl

;	move	#$700,$ffff8240	pour mesurer le temp
vbl1	lea	tblbxy,a2		adresse de la table de deplacement du fond dans a2
	lea	tblbriq,a1
	move	cptxy,d0
	lsl	#2,d0		for long word index
	move.l	(a2,d0),d1	coordonne en x dans d1
	bpl.s	vbl2
	clr	cptxy
	bra.s	vbl1
vbl2	lsl	#2,d1		for long word 	
	move.l	(a1,d1),a0	adresse du buffer dans a1
	move.l	4(a2,d0),d0
	lsl.l	#4,d0
	adda.l	d0,a0
	move.l	a0,-(sp)		sauve l'adresse du fond
	bsr	prtbriq		affichage d'une partie du mur
;	move	#$7,$ffff8240	pour mesurer le temp
	addq	#2,cptxy		deplacement suivante dans la table
	bsr	xferbuf		affichage su scroll
	move.l	(sp)+,a0		restaure l'adresse du fond
	bsr	prtbriq2		affichage de la 2eme partie du fond
	bsr	animspr		affichage et animation des sprites
	bsr	animplaq		animation des plaques
	bsr	player+$2c

* METTRE ICI LE JSR POUR LA MUSIQUE
* (jusqu'ici le temp est quasiment toujours le meme
* ce qui n'influ pas trop sur la musique
* la duree d'execution du bsr suivant varie beaucoup)

	bsr	nxtpix
	bsr	animrst		animation des rasters dans le scroll
	bsr	circle		rouleaux derriere la plaque
	bsr	setpal
;	move	#0,$ffff8240	pour mesurer le temp
	
	movem.l	(sp)+,d0-d7/a0-a5	restaure les registres
	rte

* Affichage du fond avec une monte progressive des couleurs

initpal	move.l	#palettes,ixpal
	move	#350,durpal	7 secondes d'attente ...
	rts
	
setpal	tst	durpal		teste le compteur d'attente
	bmi.s	setpal1		fini ...
	beq.s	setpal2		palette suivante
	subq	#1,durpal
setpal1	rts
setpal2	move.l	ixpal,a0		adresse de la palette dans a0
	movem.l	(a0)+,d0-d3
	movem.l	d0-d3,$ffff8240	xfer seulement 8 registres
	move.l	a0,ixpal		palette suivante
	cmpa.l	#finpal,a0	derniere palette ?
	bne.s	setpal3		non ...
	move	#-1,durpal	fini
	rts
setpal3	move	#25,durpal	1/2 seconde entre chaque changement
	rts
	
* Affichage de la plaque du titre

setitle	lea	title,a0		adresse de la plaque dans a0
	moveq	#63,d0		64 lignes de haut
	move.l	phybase,a1	adresse de l'ecran dans a1
	lea	32(a1),a1		on ce centre sur la ligne
setit2	moveq	#23,d1		24 mots long par lignes
setit3	move.l	(a0)+,(a1)+	xfer 4 octets
	dbf	d1,setit3
	lea	64(a1),a1		ligne suivante
	dbf	d0,setit2
	rts
	
* Affichage de la plaque grise en base de l'ecran

setplaq	lea	plaque1,a0	adresse de la plaque dans a1
	move.l	phybase,a1	adresse de l'ecran dans a0
	lea	128*160+32(a1),a1	en bas et au milieu de l'ecran
	moveq	#71,d0		72 lignes de haut
	bra.s	setit2		meme routine que ci-dessus
	
* AFFICHAGE DU FOND
* l'affichage du fond ce fait avec l'utilisation de movem.l
* qui est l'instruction la plus courte
* il se fait en deux temp car sinon au moment de l'affichage
* du scroll on s'est fait rattrape par le balayage video


prtbriq	move.l	phybase,a1	adresse de l'ecran
	lea	160(a1),a1	on par du bout de la ligne puis on decremente
	moveq	#31,d7
prtb2	movem.l	(a0),d0-d3	lit le fond
	movem.l	(a0)+,d4-d5/a2-a3	en double	(ca vvva plus vite pour le reconstruire)
	movem.l	d0-d5/a2-a3,-(a1)	et on stocke (cote droit)
	lea	-96(a1),a1	on affiche a l'endroit de la plaque
	movem.l	d0-d5/a2-a3,-(a1)	cote gauche
	lea	33*160(a1),a1	et 32 fois plus bas
	movem.l	d0-d5/a2-a3,-(a1)	idem
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	33*160(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	lea	33*160(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-(3*32*160-2*160)(a1),a1
	dbf	d7,prtb2
	rts

* AFFICHAGE DE LA 2EME PARTIE DU FOND
* meme principe qu'au dessus

prtbriq2	move.l	phybase,a1
	lea	4*32*160+160(a1),a1
	moveq	#7,d7
prtb3	movem.l	(a0),d0-d3
	movem.l	(a0)+,d4-d5/a2-a3
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	33*160(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	33*160(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-(2*32*160-2*160)(a1),a1
	dbf	d7,prtb3

	moveq	#23,d7
prtb4	movem.l	(a0),d0-d3
	movem.l	(a0)+,d4-d5/a2-a3
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	33*160(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-96(a1),a1
	movem.l	d0-d5/a2-a3,-(a1)
	lea	-(1*32*160-2*160)(a1),a1
	dbf	d7,prtb4
	rts

* Remplissage du buffer pour le scrolling du fond
* on calcul le fond dans le 16 positions
* pour ne pas le scrolle ensuite

setgrd	lea	brique,a0
	lea	bufbriq,a1
	moveq	#0,d2
	bsr	setgrd1
	lea	bufbriq,a0
	moveq	#13,d2
	
setgrd1	moveq	#63,d1
setgrd2	rept	4
	move	8(a0),d0
	roxr	d0
	move	(a0)+,d0
	roxr	d0
	move	d0,(a1)+
	move	6(a0),d0
	roxr	d0
	move	d0,6(a1)
	endr
	lea	8(a0),a0
	lea	8(a1),a1
	dbf	d1,setgrd2
	dbf	d2,setgrd1
	rts
	
* initialisation pour l'animation des plaques

setanim	clr	ixadr		1ere plaque
	move	#200,wait		tempo de 4 secondes
	clr	direct		on descendra
	clr	cptlg		1ere ligne plaque a l'ecran
	clr	cptpl		1ere ligne plaque dans le buff
	move	#36,nblg		nombre de ligne/2
	rts
	
* animation des plaques

animplaq	tst	wait		tempo fini ?
	beq.s	animplq2		oui suite ...
	subq	#1,wait		on decremente le compteur (duree en 50eme de secondes)
	bne	animend
animplq2
	move.l	phybase,a0
	move.l	a0,a1
	lea	32+128*160(a0),a0	index pour la ligne qui descend
	lea	32+199*160(a1),a1	index pour la ligne qui monte
	adda	cptlg,a0
	suba	cptlg,a1
	
	tst	direct
	bne	animplq3
	
	lea	plaque1,a2
	move.l	a2,a3
	lea	96*71(a3),a3
	adda	cptpl,a2
	suba	cptpl,a3
	
	rept	24
	move.l	(a2)+,(a0)+	transfert la ligne superieur
	move.l	(a3)+,(a1)+	transfert la ligne inferieur
	endr
	
	addi	#160,cptlg	
	addi	#96,cptpl
	subq	#1,nblg
	bne	animend

	eori	#1,direct		on change de direction
	move	#50,wait
	move	#36,nblg
	bra	animend
	
animplq3	lea	tblplaq,a2
	move	ixadr,d0
	movea.l	(a2,d0),a2
	move.l	a2,d0		teste a2
	bne.s	animplq4
	clr	ixadr
	bra.s	animplq3
	
animplq4	movea.l	a2,a3
	lea	96*71(a3),a3
	adda	cptpl,a2
	suba	cptpl,a3
	
	rept	24
	move.l	(a2)+,(a0)+	transfert la ligne superieur
	move.l	(a3)+,(a1)+	transfert la ligne inferieur
	endr
	
	subi	#160,cptlg
	subi	#96,cptpl
	subq	#1,nblg
	bne.s	animend
	
	eori	#1,direct		on change de direction
	move	#250,wait		5 secondes d'attente entre chaque image
	move	#36,nblg
	addq	#4,ixadr		plaque suivante

animend	rts	
	
vitesse	=	4		vitesse de depart du scroll
	
*----------------------------*
*  PARTIE SCROLL DU MESSAGE  *
*----------------------------*

* Effacement du buffer de scroll et du buffer de caractäre

clrbuf	move	#10*set_v-1,d0	80*32/4 (on efface avec des mots longs) -1 pour le dbf	
	lea	bufscr,a0		adresse du buffer
clrbuf1	clr.l	(a0)+		on efface 4 octets...
	dbf	d0,clrbuf1
	
clrbuf2	moveq	#set_v-1,d0
	lea	bufchr,a0		adresse du buffer
clrbuf3	clr.l	(a0)+		on efface 4 octets...
	clr.l	(a0)+		et encore 4
	dbf	d0,clrbuf3
	rts
	
* defilement du scroll

nxtpix	tst	stop		scroll arrete ?
	beq.s	nxtpix1		non ... suite
	subq	#1,stop		decremente le compteur de duree
	rts
nxtpix1	move.b	cplgr,d0
	cmp.b	speed,d0		la largeur est-elle suffisante pour le scroll ?
	bhs.s	nxtpix2		oui ...
	bsr.s	nxtchr		sinon on ajoute un caractere dans le buffer
	bra.s	nxtpix		et on re-teste
nxtpix2	bsr	scroll		scroll le buffer
	move.b	speed,d0
	sub.b	d0,cplgr		compteur de largueur - vitesse
	rts
	
* lecture d'un caractäre et le xfer dans le buffer

init	clr.w	ixmess		index de message pointe le debut
	clr.b	cplgr		compteur de largeur des caracteres
	clr	stop		compteur arret a 0
	move.b	#vitesse,speed	vitesse du scroll

nxtchr	lea	mess,a0		a0 pointe le debut de la phrase
	move.w	ixmess,d1
	moveq.l	#0,d0
	move.b	(a0,d1.w),d0	lit une lettre
	beq.s	init		est-on Ö la fin ?
	addq.w	#1,ixmess		caractäre suivant
	cmp.b	#16,d0		commande de vitesse ?
	bls.s	nxtchr2		oui ...
	cmp.b	#17,d0		commande arret du scroll ?
	bne.s	nxtchr8		non ... suite
	move	#150,stop		on arrete le scroll 1/2 seconde
	rts
nxtchr2	move.b	d0,speed		nouvelle vitesse
	bra.s	nxtchr
nxtchr8	sub.b	#33,d0		calcul le numero du caractäre
	bmi	space		espace ? ... oui ...
	and	#$7f,d0		masque le numero de caractere (no de car inf a 128)
	lea	orlgr,a0		adresse de la table de largeur du set (63 car.)
	move.b	cplgr,d2		position de la lettre dans d2
	move.b	(a0,d0),d1	largeur du caractere dans d1
	addq.b	#2,d1		+ un espace entre chaque caractäre
	add.b	d1,cplgr		largeur du caractäre dans le compteur
	lea	orset,a0		adresse du jeu de caractere dans a0
	mulu	#4*set_v,d0	calcul offset du caractere
	adda.l	d0,a0		adresse du caractere dans a0
	lea	bufchr,a1		adresse du buffer de caractäre
	move.b	d2,d3
	andi	#$f0,d2		calcul la colonne
	lsr	d2
	andi	#$f,d3		nombres de rotation dans d3
	rept	17		set_v
	moveq	#0,d0
	move	(a0)+,d0		lit 16 pixels
	ror.l	d3,d0
	or	d0,(a1,d2)
	swap	d0
	or	d0,2(a1,d2)
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d3,d0
	or	d0,2(a1,d2)
	swap	d0
	or	d0,4(a1,d2)
	lea	8(a1),a1		ligne du buffer de char suivante
	endr
fin	rts

space	move.b	#20,cplgr		l'espace entre chaque caractäre en pixels
	rts
	
* scroll du buffer d'un pixel vers la gauche

scroll	moveq	#set_v-3,d0	32 lignes a scroller
	moveq	#0,d3
	move.b	speed,d3		vitesse du scroll
	lea	bufscr+40*(set_v-2),a0	adresse de fin du buffer de ligne
	lea	bufchr+8*(set_v-2),a1	adresse de fin du buffer de caractäre
	
scrll2	* SCROLL LE BUFFER DE LETTRE
	moveq	#0,d1		efface le mot fort
	move	-(a1),d1		
	lsl.l	d3,d1		d3 contient la vitesse du scroll
	move	d1,(a1)
	swap	d1		rÇcupäre les retenues
	moveq	#0,d2
	move	-(a1),d2
	lsl.l	d3,d2		scroll le mot
	or	d1,d2		plus les retenues
	move	d2,(a1)
	swap	d2		rÇcupäre les retenues

	moveq	#0,d1		efface le mot fort
	move	-(a1),d1		
	lsl.l	d3,d1		d3 contient la vitesse du scroll
	or	d2,d1		plus les retenues
	move	d1,(a1)
	swap	d1		rÇcupäre les retenues
	moveq	#0,d2
	move	-(a1),d2
	lsl.l	d3,d2		scroll le mot
	or	d1,d2		plus les retenues
	move	d2,(a1)
	swap	d2		rÇcupäre les retenues

	rept	9		SCROLL LE BUFFER ECRAN
	moveq	#0,d1		efface le mot fort
	move	-(a0),d1		
	lsl.l	d3,d1		d3 contient la vitesse du scroll
	or	d2,d1
	move	d1,(a0)
	swap	d1
	moveq	#0,d2
	move	-(a0),d2
	lsl.l	d3,d2
	or	d1,d2
	move	d2,(a0)
	swap	d2
	endr 
	moveq	#0,d1		efface le mot fort
	move	-(a0),d1		
	lsl.l	d3,d1		d3 contient la vitesse du scroll
	or	d2,d1
	move	d1,(a0)
	swap	d1
	moveq	#0,d2
	move	-(a0),d2
	lsl.l	d3,d2
	or	d1,d2
	move	d2,(a0)
	dbf	d0,scrll2
	rts
	
* transfert du buffer a l'ecran

xferbuf	movea.l	phybase,a0	adresse Çcran
	lea	bufscr,a1		adresse du buffer
	lea	tblsin,a3
	adda.l	ixtbl,a3
	addq.l	#4,ixtbl
	cmp.l	#127*4,ixtbl
	bls.s	xbuf1
	sub.l	#128*4,ixtbl

xbuf1	moveq	#19,d7		40 colonnes
xbuf2	move.l	(a3)+,d1
	movea.l	a0,a2
	adda.l	d1,a2
temp	set	0
	rept	17
	move	temp*40(a1),d0
	or	d0,temp*160(a2)
	or	d0,temp*160+2(a2)
	or	d0,temp*160+4(a2)
	or	d0,temp*160+6(a2)
temp	set	temp+1
	endr
	lea	8(a0),a0
	lea	2(a1),a1
	dbf	d7,xbuf2		ligne suivante
	rts
	
* installation des ITs HBL
* vecteur en $120
* 8->$fffa1b (TBCR)
* 1->$fffa21 (TBDR)

sethbl	move.l	$120,sve120
	move.l	#hbl,$120
	move.b	#2,$fffa21
	move.b	#8,$fffa1b
	bclr	#3,$fffa17	automatic end of interupt
	bset	#0,$fffa07
	bset	#0,$fffa13
	rts
	
* interdiction des ITs HBL

clrhbl	bclr	#0,$fffa07
	bclr	#0,$fffa13
	bset	#3,$fffa17	soft end of interupt
	move.l	sve120,$120
	rts
	
* routine d'interruption HBL

hbl	move.w	colors-bufreg5(a6),$ffff825e.w
	move.w	(a6)+,$ffff824a.w
	rte
	
* animation des rasters

speedrst	=	10

animrst	move.l	ixcol,a0
	lea	colors2,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	movem.l	32(a0),d0-d7
	movem.l	d0-d7,32(a1)
	subq	#1,speedcol
	bne.s	animrst2
	move	#speedrst,speedcol
	addq.l	#2,ixcol
	cmp.l	#findeg,ixcol
	bne.s	animrst2
	move.l	#deg,ixcol
animrst2	rts

* initialisation pour les rasters

setrst	move.l	#deg,ixcol
	move	#speedrst,speedcol

	clr	ixrst
	rts	

* animation des rasters

circle	move	ixrst,d1
	lea	sintbl,a2
	moveq	#3,d2		6 rouleaux
circle0	move	d1,d0
	cmp	#127*4,d0
	bls.s	circle1
	sub	#128*4,d0
circle1	move.l	(a2,d0),d0
	lea	bufreg5,a0
	adda.l	d0,a0
	clr	(a0)
	add	#64,d1
	dbf	d2,circle0
	
	addq	#4,ixrst
	cmp	#127*4,ixrst
	bls.s	circle2
	sub	#128*4,ixrst
	
circle2	lea	gris,a1
	move	ixrst,d1
	moveq	#3,d2		6 rouleaux
circle3	move	d1,d0	
	cmp	#127*4,d0
	bls.s	circle4
	sub	#128*4,d0
circle4	move.l	(a2,d0),d0
	lea	bufreg5,a0
	adda.l	d0,a0
	move	(a1),(a0)
	add	#64,d1
	dbf	d2,circle3
	rts
	
* save MFP registers

savemfp	lea	$fffa00,a0	adresse des registres MFP
	lea	svemfp,a1		adresse de sauvegarde
	move.b	$07(a0),(a1)+	IERA
	move.b	$09(a0),(a1)+	IERB
	move.b	$13(a0),(a1)+	IMRA
	move.b	$15(a0),(a1)+	IMRB
	move.b	$17(a0),(a1)+	VR
	move.b	$19(a0),(a1)+	TACR
	move.b	$1b(a0),(a1)+	TBCR
	move.b	$1d(a0),(a1)+	TCDCR
	move.b	$1f(a0),(a1)+	TADR
	move.b	$21(a0),(a1)+	TBDR
	move.b	$23(a0),(a1)+	TCDR
	move.b	$25(a0),(a1)+	TDCR
	rts
		
* restaure les registres du MFP

oldmfp	lea	$fffa00,a0	adresse des registres MFP
	lea	svemfp,a1		adresse de sauvegarde
	move.b	(a1)+,$07(a0)	IERA
	move.b	(a1)+,$09(a0)	IERB
	move.b	(a1)+,$13(a0)	IMRA
	move.b	(a1)+,$15(a0)	IMRB
	move.b	(a1)+,$17(a0)	VR
	move.b	(a1)+,$19(a0)	TACR
	move.b	(a1)+,$1b(a0)	TBCR
	move.b	(a1)+,$1d(a0)	TCDCR
	move.b	(a1)+,$1f(a0)	TADR
	move.b	(a1)+,$21(a0)	TBDR
	move.b	(a1)+,$23(a0)	TCDR
	move.b	(a1)+,$25(a0)	TDCR
	rts
		
* Initialisation du buffer pour les sprites

setspr	lea	smile,a0
	lea	bufspr,a1
	clr	d4
	bsr	setspr0
	lea	smile,a0
	lea	bufspr+14*16,a1
	clr	d4
	bsr	setspr2
	
	lea	mask,a0
	lea	bufmsk,a1
	move	#$ffff,d4
	bsr	setspr0
	lea	mask,a0
	lea	bufmsk+14*16,a1
	move	#$ffff,d4
	bsr	setspr2
	rts
	
setspr0	moveq	#15,d0
setspr1	rept	4
	move	(a0)+,(a1)+
	move	d4,6(a1)
	endr
	lea	8(a1),a1
	dbf	d0,setspr1
	rts
	
setspr2	moveq	#13,d3		14 lignes
setspr3	moveq	#3,d2		4 plans
setspr4	move	(a0)+,d0
	swap	d0
	move	d4,d0
	swap	d0
	moveq	#14,d1		15 buffer pour les 16 positions (le premier est deja fait)
setspr5	ror.l	d0
	move	d0,(a1)
	swap	d0
	move	d0,8(a1)
	swap	d0
	lea	14*16(a1),a1	buffer suivant
	dbf	d1,setspr5
	lea	-(16*14*15-2)(a1),a1	revient au premier buffer mot suivant
	dbf	d2,setspr4
	lea	8(a1),a1
	dbf	d3,setspr3	
	rts
	
* Draw Sprite :
* Parms:
* d0:no de ligne
* d1:no de colonne

drwspr	move.l	phybase,a0
	mulu	#160,d0
	adda.l	d0,a0
	move	d1,d2
	and.l	#$fff0,d1
	lsr.l	#1,d1
	and.l	#$f,d2
	mulu	#14*16,d2
	adda.l	d1,a0
	lea	bufmsk,a1
	adda.l	d2,a1
	lea	bufspr,a2
	adda.l	d2,a2
	
	rept	14
	movem.l	(a1)+,d0-d3
	movem.l	(a2)+,d4-d7
	and.l	d0,(a0)
	or.l	d4,(a0)+
	and.l	d1,(a0)
	or.l	d5,(a0)+
	and.l	d2,(a0)
	or.l	d6,(a0)+
	and.l	d3,(a0)
	or.l	d7,(a0)+
	lea	160-16(a0),a0
	endr
	rts
	
* animation des sprites

animspr	move	ixspr,d2
	lea	sinspr,a0
	move.b	(a0,d2),d0
	and	#$ff,d0
	lea	sinspr2,a0
	move.b	(a0,d2),d1
	and	#$ff,d1
	movem	d0-d1,-(sp)
	bsr	drwspr
	movem	(sp)+,d0-d1
 	add	#256,d1
	bsr	drwspr
	addq	#1,ixspr
	cmp	#128,ixspr
	bne.s	animspr2
setas	clr	ixspr
animspr2	rts
player	incbin	A:\MR_BEE.OVR\MUSICS\overlander.b	
smile	incbin	a:\MR_BEE.OVR\gfabasic\smile1.blk
mask	incbin	a:\MR_BEE.OVR\gfabasic\smilemsk.blk
sinspr	incbin	a:\MR_BEE.OVR\gfabasic\sinspr.tbl
sinspr2	incbin	a:\MR_BEE.OVR\gfabasic\sinspr2.tbl

bufspr	ds.w	2*4*14*16
bufmsk	ds.w	2*4*14*16
ixspr	ds.l	1		


palette	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$222,$333,$444,$555,$774,$770,$750,$666

palettes	dc.w	$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$001,$100
	dc.w	$000,$000,$000,$000,$000,$000,$002,$200
	dc.w	$000,$000,$000,$000,$100,$000,$113,$300
	dc.w	$000,$000,$000,$100,$210,$011,$224,$401
	dc.w	$000,$000,$100,$210,$321,$022,$335,$512
	dc.w	$000,$100,$210,$321,$432,$033,$446,$623
	dc.w	$000,$210,$321,$432,$543,$044,$557,$734
finpal

temp	set	0
tblbriq	dc.l	brique
	rept	15
	dc.l	temp*1024+bufbriq
temp	set	temp+1
	endr

* table de coordonee pour le deplacement du fond

tblbxy
	rept	8
	dc.l	1,0,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,9,9,10,10
	dc.l	11,11,12,12,13,13,14,14,14,15,15,0,14,1,14,2
	dc.l	13,3,12,4,11,5,10,6,9,7,8,8,6,9,5,10,4,11,3,12,2,13,1,14,1,15
	endr
	rept	10
	dc.l	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.l	8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15
	endr
	rept	8
	dc.l	0,0,2,2,4,4,6,6,8,8,10,10
	dc.l	12,12,14,14
	endr
	dc.l	15,14,15,13,15,12,15,11,15,10,15,9,15,8,15,7
	dc.l	15,6,15,5,15,4,15,3,15,2,15,1,15,0
	dc.l	13,0,11,0,9,0,7,0,5,0,3,0,0,0
	rept	20
	dc.l	15,0,14,0,13,0,12,0,11,0
	dc.l	10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,0,0
	endr
	rept	15
	dc.l	15,15,14,14,13,13,12,12,11,11,10,10,9,9
	dc.l	8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0
	dc.l	0,15,1,14,2,13,3,12,4,11,5,10,6,9
	dc.l	7,8,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15,0
	endr
	rept	12
	dc.l	0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0,10,0
	dc.l	11,0,12,0,13,0,14,0,15,0
	dc.l	0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9,0,10,0,11
	dc.l	0,12,0,13,0,14,0,15
	dc.l	15,0,14,0,13,0,12,0,11,0
	dc.l	10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,0,0
	dc.l	0,15,0,14,0,13,0,12,0,11,0
	dc.l	10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,0
	endr
	dc.l	-1


tblplaq	dc.l	plaque2
	dc.l	plaque3
	dc.l	plaque5
	dc.l	plaque6
	dc.l	plaque4
	dc.l	0		plus de plaque

brique	incbin	a:\MR_BEE.OVR\gfabasic\brique.blk	dessin de la brique
title	incbin	a:\MR_BEE.OVR\gfabasic\title.blk	dessin de la plaque titre
plaque1	incbin	a:\MR_BEE.OVR\gfabasic\plaque1.blk	plaque grise qui sert a cacher
plaque2	incbin	a:\MR_BEE.OVR\gfabasic\plaque2.blk	'keep on adventurin' '  (jeu masquerade sur apple)
plaque3	incbin	a:\MR_BEE.OVR\gfabasic\plaque3.blk	'you win Mr Toop' (jeu masquerde sur apple)
plaque4	incbin	a:\MR_BEE.OVR\gfabasic\plaque4.blk	'presentation captain goodnight' (jeu apple)
plaque5	incbin	a:\MR_BEE.OVR\gfabasic\plaque5.blk	'temple' (jeu karateka sur apple)
plaque6	incbin	a:\MR_BEE.OVR\gfabasic\plaque6.blk	'moi meme !' digitalise avec easy tizer

* table de sinus pour les rasters

sintbl	incbin	a:\MR_BEE.OVR\gfabasic\sinrst.tbl

* table de sinus pour le scroll
	
tblsin	incbin	a:\MR_BEE.OVR\gfabasic\sinscrll.tbl

set_h	=	4		30 pixels de large=4 octets
set_v	=	19		23 pixels de haut

orlgr	incbin	a:\MR_BEE.OVR\sets\orient.lgr	largeurs des caractäres
	even
orset	incbin	a:\MR_BEE.OVR\sets\orient.set	jeu de caractäres


* Le scrolling dispose des commandes suivantes:
* 0   : fin du message
* 1-16: vitesse de defilement
* 17  : arret du scroll pendant 1,5 secondes

mess	DC.B	'             OVERLANDERS 1990 .... COMPIL CODE VOLUME 1 .... EH! GUYS !!!!!   MAKE ANOTHER COMPIL SOURCE CODE !!!!         '
	
	dc.b	6,'              ',0  

	even

* buffer pour les rasters
bufreg5	rept	100
	dc.w	0
	endr

colors	rept	32
	dc.w	$666
	endr
colors2	rept	32
	dc.w	0
	endr
	rept	36
	dc.w	$666
	endr
	
gris	dc.w	$444

deg
violet	dc.w	$323,$434,$545,$656,$767,$656,$545,$434,$323
rose	dc.w	$300,$401,$502,$603,$704,$603,$502,$401,$300
or	dc.w	$200,$310,$420,$530,$640,$750,$640,$530,$420,$310,$200
grisvert	dc.w	$332,$443,$554,$665,$776,$665,$554,$443,$332
bleu	dc.w	$003,$104,$205,$306,$407,$306,$205,$104,$003
marron	dc.w	$311,$422,$533,$644,$755,$644,$533,$422,$311
grisbleu	dc.w	$233,$344,$455,$566,$677,$566,$455,$344,$233
findeg
	dc.w	$323,$434,$545,$656,$767,$656,$545,$434,$323
	dc.w	$300,$401,$502,$603,$704,$603,$502,$401,$300
	dc.w	$200,$310,$420,$530,$640,$750,$640,$530,$420,$310,$200
	dc.w	$332,$443,$554,$665,$776,$665,$554,$443,$332
	dc.w	$003,$104,$205,$306,$407,$306,$205,$104,$003
	dc.w	$311,$422,$533,$644,$755,$644,$533,$422,$311
	dc.w	$233,$344,$455,$566,$677,$566,$455,$344,$233



sve70	ds.l	1
sve118	ds.l	1
sve120	ds.l	1
svepal	ds.w	16
svemfp	ds.b	12		space for saving MFP registers
bufbriq	ds.b	15*1024
phybase	ds.l	1
cptxy	ds.w	1
ixcol	ds.l	1
speedcol	ds.w	1
ixpal	ds.l	1
durpal	ds.w	1

direct	ds.w	1
nblg	ds.w	1
cptlg	ds.w	1
cptpl	ds.w	1
ixadr	ds.w	1
wait	ds.w	1


ixmess	ds.w	1		index pour le message
stop	ds.w	1		compteur de duree pour l'arret du scroll
cplgr	ds.b	1		compteur largeur des caractäres
speed	ds.b	1		vitesse du scroll
ixtbl	ds.l	1
ixrst	ds.l	1
svesp	ds.l	1		save stack pointeur

	even
bufscr	ds.b	40*19		buffer pour le scroll
bufchr	ds.b	8*19		buffer pour 2 caractäres

stack	ds.l	100
stacked	ds.l	1
	end
