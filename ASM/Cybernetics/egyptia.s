nbr:		equ	30
hauteur:	equ	16
largeur:	equ	17	* ATTENTION SI >16
nbcourbe:	equ	6
nbcouleur:	equ	8
nbetape:	equ	50
ste:		set	1
timemach:	set	0
trackon:	set	1
*-------------------------------------------------------------------------*
*									  *
*	FLEXI	par KRAG			       	  -02/06/1992-	  *
*									  *
*   Merci a METALAGES pour son aide					  *
*   ( optimisation par des movem )					  *	
*   ( Fonte tourn‚e de 90 degres )					  *
*									  *
*-------------------------------------------------------------------------*

aigus:		set	7
graves:		set	10

		output	e:\code\effects.grx\relaps_f\egyptia.prg

		opt	o+
	
		clr.l	-(sp)		* Superviseur
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack

		clr.w	-(sp)		* Basse resolution
		move.l	#-1,-(sp)
		move.l	#-1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp
	
		move.w	#2,-(sp)	* Physbase
		trap	#14
		addq.l	#2,sp
 		move.l	d0,ecran1

		move.b	#2,$ffff820a.w

		bsr	initsound
		
		ifne 	trackon
		moveq.l	#-1,d0
		move.l	#vbl,d1
		lea	moduledeb,a0
		lea	moduleend,a1
		jsr	zik
		endc

		ifeq	trackon
		move.w	#$2700,sr
		move.l	$70.w,oldvbl
		move.b	$fffffa07.w,oldiera		
		move.b	$fffffa09.w,oldierb		
		move.l	#vbl,$70.w
		move.w	#$2300,sr
		endc

		lea	espace,a2	* Autre ecran
		move.l	a2,d0
		clr.b	d0
		move.l	d0,a2
		lea	$100(a2),a2
		move.l	a2,ecran2

		move.l	#image+4,-(sp)		*palette source
		move.l	#image+4+2*8,-(sp)	*palette d'arrivee
		move.l	#couleur,-(sp)		*palettes de transition
		move.w	#nbcouleur,-(sp)	*nb couleurs
		move.w	#nbetape,-(sp)		*nb etapes
		jsr 	fade
		lea	16(sp),sp
		
		jsr	place			*affiche l'image

		movem.l	d0-a6,-(sp)

		lea	pal,a2
		lea	zero,a0
		moveq.l	#-1,d1
		bsr	light

		movem.l	(sp)+,d0-a6

		jsr	genere			* genere le code pour chaque lettre
	
		move.l	#tabcou,a0		*tableau contenant les ad. des courbes
		move.l	a0,coucour		*position courante dans ce tableau
		move.l	#courbe6,(a0)+
		move.l	#courbe2,(a0)+
		move.l	#courbe1,(a0)+
		move.l	#courbe4,(a0)+
		move.l	#courbe3,(a0)+
		move.l	#courbe5,(a0)+
		
		move.l	ecran1,a1
		move.l	ecran2,a2
		lea	baratin,a4
		lea	ou,a5

main2:		lea	tableau,a0		
		lea	lettre,a3		
		moveq.l	#nbr-1,d0		* Met des espaces
int:		move.l	(a5),(a3)+			
		dbra.w	d0,int
		
main:		move.w	#-1,vsync		* Attend la sync

temp:		tst.w	vsync
		bne.s	temp

		exg	a1,a2			* Swap ecran
		move.l	a1,d2			
		lsr.w	#$8,d2
		move.b	d2,$ffff8203.w
		swap	d2
		move.b	d2,$ffff8201.w
		
	 	ifgt	timemach
		move.w	#$567,$ffff8240.w		
		endc
		
		cmp.l	#tableau,a0		* Nouvelle lettre
		bge	affiche
		
		lea	lettre,a3		
	        rept	nbr-1			* Decalle les autres
		move.l	4(a3),(a3)+
		endr
		
retour:		move.b	(a4)+,d3		* Boucle si fin texte
		cmp.b	#'$',d3	
		bne.s	suite
		
		move.b	(a4)+,d3
		cmp.b	#'1',d3
		bne.s	ordre2
		move.l	#couleur,addcou
		move.w	#nbetape,nbvpas		* fade in
		move.l	#0,vpas
		bra.s	retour
		
ordre2:		cmp.b	#'2',d3			* fade out
		bne.s	ordre3
		move.l	#couleur+2*(nbetape)*nbcouleur,addcou
		move.w	#nbetape,nbvpas
		move.l	#4*(nbcouleur),vpas
		bra.s	retour
		
ordre3:		cmp.b	#'3',d3			* prochaine courbe
		bne.s	ordre4
		bra	pcb
		bra	main2
				
ordre4:		lea	baratin,a4		* boucle texte
		bra.s	retour

suite:		sub.w	#32,d3					* Introduit nouvelle lettre
		add.b	d3,d3
		add.b	d3,d3	
		move.l	(a5,d3.w),(a3)
		
		lea	(hauteur*largeur*4)(a0),a0		* Initialise debut du tableau
		
affiche:	movem.l	d0-d7/a1/a5,-(sp)
		lea	lettre,a3	
		
		rept	nbr					* Saute a la routine
		move.l	(a3)+,a5				* Correspondant a la lettre
		jsr	(a5)
		endr
	
		movem.l	(sp)+,d0-d7/a1/a5
		lea	-((nbr*4*hauteur*largeur)+$40)(a0),a0	* On se remet au debut
	
		
	 	ifgt	timemach
		move.w	#$000,$ffff8240.w
		endc
		
		cmp.b	#57,tch					* Test clavier
coucou:		bne	main

fin:		lea	pal,a0
		lea	zero,a2
		moveq.l	#-1,d1
		bsr	light
		
		bsr	fadesound

		ifne	trackon
		moveq.l	#0,d0
		jsr	zik
		endc

		ifeq	trackon
		move.w	#$2700,sr
		move.b	oldiera,$fffffa07.w
		move.b	oldierb,$fffffa09.w
		move.l	oldvbl,$70.w
		move.w	#$2300,sr
		endc
		
		move.l	stack,-(sp)		* Utilisateur
		move.w	#$20,-(sp)	
		trap	#1
		addq.l	#6,sp

 		clr.l	-(sp)			* Pterm
		trap	#1

zero:		rept	8
		dc.l	0
		endr
*-------------------------------------------------------------------------*
initsound:
	move.w		#$7ff,$ffff8924.w		* Init microwire
dmwr:	cmp.w		#$7ff,$ffff8924.w
	bne.s		dmwr
	move.w		#%10011101111,d0		* Volume max
	bsr		microwrite
	move.w		#%10010000000+aigus,d0		* Aigus 
	bsr		microwrite
	move.w		#%10001000000+graves,d0		* Graves
	bsr		microwrite
	rts

microwrite:
	move.w		d0,$ffff8922.w
	moveq.l		#127,d0
waitdma:dbra.w		d0,waitdma
	rts

fadesound:	
	moveq.l		#20,d0
temp2:	move.w		#$4c0,d2
	or.w		d0,d2
	add.w		#20,d2
	move.w		d2,$ffff8922.w
	move.w		#5000,d1
temp1:	move.l		4(sp),4(sp)
	dbra.w		d1,temp1
	dbra.w		d0,temp2
	rts

*----------------------------- FADE ROUTINE ------------------------------*
*	A0 = adr palette depart						  *
* 	A2 = adr palette arrivee					  *
* 	D1 = masque							  *
*-------------------------------------------------------------------------*
light:
	move.w		d1,a5			* Sauve le mot de test couleurs
	clr.w		rd4			* Compteur de boucles: nbre d'etapes
looplight:					* Boucle principale
	move.l		a0,a1			* Adresse palette
	move.l		a2,a3			* Adresse palette
	move.w		rd4(pc),d2		* Compteur boucle (‚tape fade)
	lsl.w		#4,d2			*
	lea		$ffff8240.w,a4		* Adr palette
	move.w		a5,d1
	move.w		#15,rd6
	
	stop		#$2300
	
light_colors:
	move.w  	(a1)+,d4		* Couleur de depart
	move.w		(a3)+,d5 		* Couleur d'arrivee
	
	add.w		d1,d1			* Test si il faut modifier
	bcc.s		nocol			* ce registre de couleur
	
	moveq.l		#0,d3			* Registre pour couleur finale
	moveq.l		#0,d0			* Indice boucle: 0-4-8 (decalage composante r-v-b)

compo:	move.w		d4,d7			* Color dep
	bsr		rol4bits		*  
	move.w		d7,d6			* => valeur composante de 0 … 15
	move.w		d5,d7			* Color arr
	bsr		rol4bits		* => valeur composante de 0 … 15
	sub.w		d6,d7			* delta composante: Dc
	muls.w		d2,d7			* Dc * 256 / nb ‚tape 
	asr.w		#8,d7			* Dc / 256
	add.w		d6,d7			* Dc + color dep 
	bsr		ror4bits		* composante de 0 … 15 => ste color 
	lsl.w		d0,d7
	or.w		d7,d3			* D3 : resultat couleur

	lsr.w		#4,d4			* Decalage pour composante
	lsr.w		#4,d5
	
	addq.w		#4,d0			* Boucle composante
	cmp.w		#12,d0
	bne.s		compo
	
	move.w		d3,(a4)			* Fixe couleur
nocol:	addq.w		#2,a4
	
	subq.w		#1,rd6			* Boucle couleur
	bge.s 		light_colors

	move.w	#2,d5
temp4:	move.w	#-1,vsync
syncc:	tst.w	vsync
	bne.s	syncc
	dbra.w	d5,temp4

	addq.w		#1,rd4			* Boucle etape
	cmp.w		#16,rd4
	bne		looplight

	lea		$ffff8240.w,a1
	moveq.l		#7,d0
copypal:	
	move.l		(a2)+,(a1)+
	dbra.w		d0,copypal

	rts

rd4:	dc.w	0
rd6:	dc.w	0


rol4bits:
	add.w		d7,d7		* D7: couleur shift‚e (selon Composante voulue)
	btst.l		#4,d7
	beq.s		nobit1_1
	or.w		#1,d7	
nobit1_1:
	and.w		#15,d7		* D7: compsante de 0 … 15
	rts

	
ror4bits:
	ror.w		#1,d7
	bcc.s		nobit1_2
	or.w		#8,d7
nobit1_2:
	and.w		#15,d7
	rts

pal:	incbin	egypt.pal

*-------------------------------------------------------------------------*
tch:	dc.w	0

vbl:	
	move.b	$fffffc02.w,tch
	
	ifeq	trackon
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	endc

	clr.w	vsync
	tst.w	nbvpas
	blt.s	coco
	
	move.l	addcou,a1
	lea	$ffff8250.w,a2
	
	rept	nbcouleur
	move.w	(a1)+,(a2)+
	endr

	sub.l	vpas,a1	
	move.l	a1,addcou
	subq.w	#1,nbvpas
	
coco:	
	ifeq	trackon
	move.l	(sp)+,a2
	move.l	(sp)+,a1
	rte
	endc

	ifne	trackon
	rts
	endc


vpas:	dc.l	0
nbvpas:	dc.w	-1
addcou:	dc.l	0	
*-------------------------PROCHAINE COURBE--------------------------------*
pcb:		movem.l	d0-a6,-(sp)

		move.l	ecran2,-(sp)
		jsr	efface
		addq.l	#4,sp
		
		move.l	ecran1,-(sp)
		jsr	efface
		addq.l	#4,sp			

		move.l	ecran2,a4
		move.l	#tableau,a3
		move.w	#255,d1
ready:		move.l	#$7d00,(a3)+
		dbra	d1,ready

		move.l	coucour,a1
		move.l	(a1),a2
		jsr	(a2)
		
ready2:		move.l	#$7d00,(a3)+
		cmp.l	#tableau+$7e90,a3
		blt.s	ready2

		move.l	ecran2,-(sp)
		jsr	efface
		addq.l	#4,sp

		addq.l	#4,coucour
		move.l	a1,d0
		
		cmp.l	#tabcou+nbcourbe*4,coucour
		blt.s	peffet
		move.l	#tabcou,coucour
		
peffet:		movem.l	(sp)+,d0-a6
		bra	main2

*-------------------------GENERATEUR DE CODE------------------------------*

genere:	movem.l	d0-a6,-(sp)

	lea	font,a0		 * Gene
	lea	128(a0),a0
	lea	code,a1	

	lea	buffer,a3
	lea	suivant(pc),a2
	lea	ou,a4
	lea	text,a5
	moveq.l	#3,d6			* Nombre de colonnes
	
db3:	moveq.l	#9,d4			* Nombre de lettres/colonnes
	
db2:	moveq.w	#-1,d7			* Compteur d'instructions
	moveq.l	#0,d3
	move.w	#largeur-1,d1
	moveq.l	#0,d5
	move.b	(a5)+,d5		* Calcule place de la lettre
	sub.w	#32,d5			* dans le tableau
	add.w	d5,d5
	add.w	d5,d5
	move.l	a1,(a4,d5.w)		* Sauve addresse de la rout 
	
	move.w	#hauteur-1,d0		* Initialise tableau
init2:	move.w	#$2,(a3)+		
	dbra.w	d0,init2
	lea	-hauteur*2(a3),a3	* Place debut du tableau
	
debut1:	move.w	#hauteur-1,d0
	
debut2:	move.w	d0,d2			
	lsl.w	d2			* Position dans le tableau
	rol.w	(a0)			* Rotation
	bcc.s	rien
	
inf:	cmp.b	#1,(a3,d2.w)		* Si bit set on saute
	beq.s	test2
	move.w	#$100,(a3,d2.w)		* Met a 1 la sauvegarde de l'etat du bit
	
test2:	cmp.b	#2,1(a3,d2.w)		* Si deja 2 bit mis 
	bne.s	ok			* Alors on saute
	jmp	(a2,d3.w)		
	
ok:	addq.b	#1,1(a3,d2.w)		* Sinon ajoute 1 au nombre de bits
	addq.w	#1,d7			* Ajoute 1 au compteur
	cmp.w	#3,d7			* Si d7>=3 alors 
	ble.s	inf1			* d7=0
	move.w	#0,d7			

inf1:	tst.w	d7			* Si d7>0 alors
	ble.s	normal			* Branche sur les movem
	jsr	movm
	bra.s	instruc			* Sinon normal
	
normal:	moveq.l	#0,d5
	move.l	#$30183218,(a1)+	* Move.w (a0)+,d0/move.w (a0)+,d1
	
instruc:
	move.l	#$81711000,(a1)+	* Or.w	d0,(a1,d1.w)
	add.l	d5,-4(a1)		* Modifie l'instruction
	move.b	#0,d3			* 0 pour se brancher sur suivant
	bra.s	boucle			* Suivant

	
rien:	tst.b	(a3,d2.w)		* Si bit a 0
	beq.s	test3			* Alors on saute
	clr.w	(a3,d2.w)		* Met a 0 la sauvegarde de l'etat du bit
	
test3:	cmp.b	#2,1(a3,d2.w)		* Si 2 bit a 0
	bne.s	ok2			* Alors on saute
	jmp	(a2,d3.w)
	
ok2:	addq.b	#1,1(a3,d2.w)		* Sinon ajoute 1 au nombre de bits
	addq.w	#1,d7			* Ajoute 1 au compteur
	cmp.w	#3,d7			* Si d7>=3 alors 
	ble.s	inf2			* d7=0
	move.w	#0,d7			

inf2:	tst.w	d7			* Si d7>0
	ble.s	normal2			* Branche sur les movem
	jsr	movm
	bra.s	instruc2		* Sinon normal

normal2:
	moveq.l	#0,d5
	move.l	#$30183218,(a1)+	* Move.w (a0)+,d0/move.w (a0)+,d1

instruc2:
	move.l	#$b1711000,(a1)+	* Eor.w	d0,(a1,d1.w)
	add.l	d5,-4(a1)		* Modifie instruction
	move.b	#0,d3			* 0 pour se brancher sur suivant
	bra.s	boucle			* Suivant

suivant:move.w	#-1,d7			* rupture compteur d7=-1
	move.w	#$5888,(a1)+		* Addq.w #4,a0
	move.w	#14,d3			* 10 pour saut variant sur s1
	bra.s	boucle			* Suivant
	
s1:	move.w	#$5088,-2(a1)		* Addq.w #8,a0
	move.w	#26,d3			* 22 pour saut variant sur s2			
	bra.s	boucle			* Suivant
	
s2:	move.l	#$41e8000c,-2(a1)	* Modifie ancienne instruction
	addq.l	#2,a1			* Lea $10(a0),a0
	move.w	#42,d3			* 38 pour saut variant sur s3
	bra.s	boucle			* Suivant
	
s3:	addq.w	#4,-2(a1)		* Ajoute 4 au lea
	
boucle:	dbra.w	d0,debut2		* Hauteur-1
	lea	160(a0),a0		* Prochaine ligne
	
	dbra.w	d1,debut1		* Largeur-1
	move.w	#$4e75,(a1)+		* Rts
	
	dbra.w	d4,db2				* Repeter colonnes-1 fois

	lea	-(160*largeur*10-8)(a0),a0	* va en haut colonne suivante
	
	dbra.w	d6,db3				* Repeter nbr colonnes-1fois
	
	movem.l	(sp)+,d0-a6
	rts

*-----------------------CAS DES MOVEMS--------------------------------*

movm:	cmp.w	#1,d7				* Si d7=1
	bne.w	tpts
	move.l	#$4c98000f,-8(a1)		* Movem.w (a0)+,d0-d3
	bra.s	sortie
	
tpts:	cmp.w	#2,d7				* Si d7=2
	bne.w	qpts
	move.l	#$4c98003f,-12(a1)		* Movem.w (a0)+,d0-d5
	bra.s	sortie				* Sinon
	
qpts:	move.l	#$4c9800ff,-16(a1)		* Movem.w (a0)+,d0-d7

sortie:	move.l	#$2001000,d5			* Calcule la modif
	cmp.w	#3,d7				* Si d7=3  
	bne.s 	vasy				* Calcule different
	subq.w	#1,d7
	lsl.l	d7,d5
	add.l	#$4002000,d5
	addq.l	#1,d7
	bra.s	fini
	
vasy:	lsl.l	d7,d5				* de l'instruction
fini:	rts


*-------------------------------------------------------------------*
*			effacement				    *
*-------------------------------------------------------------------*
efface:		move.l	d0,-(sp)
		move.l	a1,-(sp)

		move.w	#199,d0
		move.l	12(sp),a1
		addq.l	#6,a1
		
topo:		rept	20
		move.w	#0,(a1)
		addq.l	#8,a1
		endr
		dbra	d0,topo
		
		move.l	(sp)+,a1
		move.l	(sp)+,d0
		rts
*---------------------------------------------------------------------------------*		
*				FADE						  *
*
*( ad. palette source        )
*( ad. palette destination   )		
*( ad. des etapes	     )	
*( nb. de couleur	     ) 	
*( nb. d'etapes		     )	
*---------------------------------------------------------------------------------*
fade:		movem.l	d0-a6,-(sp)
		move.l	#version,a0
		move.l	#theme,a1
		move.l	76(sp),a2		*palette source
		move.l	72(sp),a3		*palette destination
		move.l	68(sp),a4		*resultat
		
		clr.l	d0		
		move.w	66(sp),d0		*nb couleur
		move.w	d0,a5
		lsl.w	#1,d0
		move.l	d0,offetap
		
		clr.l	d1		
		move.w	64(sp),d1
		addq.w	#1,d1
		mulu	d0,d1
		subq.w	#2,d1
		move.l	d1,offcoul

coulsui:	move.w	64(sp),d7		*nombre d'etape
		move.w	(a2)+,d0
		move.w	d0,(a4)
		add.l	offetap,a4		*recopie la couleur de depart
		
		move.w	d0,d1
		move.w	d1,d2
		
		and.w	#%111100000000,d0
		lsr.w	#8,d0	
		move.b	(a0,d0.w),d0		*composante rouge
		
		and.w	#%11110000,d1
		lsr.w	#4,d1
		move.b	(a0,d1.w),d1		*composante verte
		
		and.w	#%1111,d2
		move.b	(a0,d2.w),d2		*composante bleue
		
		move.w	(a3)+,d3
		move.w	d3,d4
		move.w	d4,d5
		
		and.w	#%111100000000,d3
		lsr.w	#8,d3	
		move.b	(a0,d3.w),d3		*composante rouge de destination
		
		and.w	#%11110000,d4
		lsr.w	#4,d4
		move.b	(a0,d4.w),d4		*composante verte de destination
		
		and.w	#%1111,d5
		move.b	(a0,d5.w),d5		*composante bleue de destination
		
		sub.l	d0,d3			*pas du rouge
		sub.l	d1,d4			*pas du vert
		sub.l	d2,d5			*pas du bleu
		
		mulu	d7,d0			*couleur*nombre d'etape
		mulu	d7,d1
		mulu 	d7,d2
		subq.w	#1,d7
		
etape:		add.w	d3,d0			*ajoute les pas des couleurs
		add.w	d4,d1
		add.w	d5,d2
		
		move.l	d0,d6			*recode la composante rouge
		divu	64(sp),d6
		move.b	(a1,d6.w),d6
		lsl.w	#8,d6
		move.w	d6,(a4)
		
		move.l	d1,d6			*recode la composante verte
		divu	64(sp),d6
		move.b	(a1,d6.w),d6
		lsl.w	#4,d6
		add.w	d6,(a4)
		
		move.l	d2,d6			*recode la composante bleue
		divu	64(sp),d6
		move.b	(a1,d6.w),d6
		add.w	d6,(a4)
		
		add.l	offetap,a4		*deplacement chaine
		dbra	d7,etape
		sub.l	offcoul,a4
		
		add.w	#-1,a5
		cmp.w   #0,a5
		bgt.w	coulsui
		
		movem.l	(sp)+,d0-a6
		rts

theme:		dc.b	0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15
version:	dc.b	0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15
offcoul:	dc.l	0
offetap:	dc.l	0
*----------------------------------------------------------------------------*

*-------------------------------------------------------------------*
courbe1:	move.w	#-1,ray
		move.w	#99,d6
		move.w	#60,centx
		move.w	#139,centy
		move.w	#1,pasr
		move.w	#1,pasd
		jsr	obli

		move.w	#1,ray
		move.w	#99,d6
		move.w	#160,centx
		move.w	#40,centy

		jsr	obli

		move.w	#139,centy
		move.w	#61,centx
		move.w	#1,pasr
		move.w	#1,pasd
		move.w	#198,d6
		
		jsr	hori
		
		rts
*-------------------------------------------------------------------------*
courbe2:	move.w	#50,depha1
		move.w	#700,depha2
		move.w	#100,centy
		move.w	#145,centx
		move.w	#100,ray
		move.w	#2,pasr
		move.w	#8,pasd
		move.w	#6,pasd2
		move.w	#473,d6

		jsr	cercle
		
		rts
*-------------------------------------------------------------------------*
courbe3:	move.w	#0,depha1
		move.w	#0,depha2
		move.w	#100,centy
		move.w	#160,centx
		move.w	#99,ray
		move.w	#2,pasr
		move.w	#6,pasd
		move.w	#6,pasd2
		move.w	#478,d6

		jsr	cercle
		
		rts
*-------------------------------------------------------------------------*
courbe4:	move.w	#320,depha1
		move.w	#0,depha2
		move.w	#100,centy
		move.w	#160,centx
		move.w	#99,ray
		move.w	#2,pasr
		move.w	#6,pasd
		move.w	#6,pasd2
		move.w	#478,d6

		jsr	cercle
		
		rts
*-------------------------------------------------------------------------*
courbe5:	move.w	#2520,depha1
		move.w	#1800,depha2
		move.w	#100,centy
		move.w	#160,centx
		move.w	#99,ray
		move.w	#2,pasr
		move.w	#6,pasd
		move.w	#12,pasd2
		move.w	#478,d6

		jsr	cercle
		
		rts
*-------------------------------------------------------------------------*
courbe6:	move.w	#0,depha1
		move.w	#0,depha2
		move.w	#100,centy
		move.w	#160,centx
		move.w	#95,ray
		move.w	#2,pasr
		move.w	#12,pasd
		move.w	#12,pasd2
		move.w	#239,d6

		jsr	cercle
		jsr	wave

		rts
*-----------------------AFFICHE L'IMAGE----------------------------*

place:	movem.l	d0-a6,-(sp)
	move.l	ecran1,a1
	move.l	ecran2,a2
	lea	$ffff8240.w,a4
	move.w	#7,d0

	lea	image+128,a3
	move.w	#7999,d0
mlo:	move.l	(a3),(a1)+
	move.l	(a3)+,(a2)+
	dbra.w	d0,mlo
	movem.l	(sp)+,d0-a6
	rts


*-------------------------------------------------------------------------*	
*                              CERCLE 					  *
*-------------------------------------------------------------------------*                      
cercle:	
	lea	cosinus,a0	* tableau de cosinus
	lea	sinus,a1	* tableau de sinus
	move.l	#cosinus+2878,a5
	move.l	#sinus+2878,a6
	lea	point,a2	* tableau des bits set

	add.w	depha1,a0			* angle
	add.w	depha2,a1
	
angle:	move.w	ray,d1		*rayon dans d2
	move.w	#15,d5

rayon:	
	move.w	d1,d2		* calcule du 
	muls	(a0),d2		* cosinus
	lsl.l	#2,d2
	sub.w	d2,d2
	swap	d2
	
	add.w	centx,d2	* ajoute coordonne en x du centre
	move.w	d2,d3
	and.w	#-16,d3		* masque les 4 derniers bits
	sub.w	d3,d2		
	add.w	d2,d2		* calcule la position du masque
	move.w	(a2,d2.w),d4	* recuper le masque
	lsr.w	#1,d3
	
	move.w	d1,d2		* calcule du cosinus
	muls	(a1),d2
	lsl.l	#2,d2
	sub.w	d2,d2
	swap	d2
	add.w	centy,d2	* ajout de la coordonnes en y 
	muls	#160,d2
	add.w	d2,d3		* offset addresse ecran
	addq.w	#6,d3
	
	move.w	(a4,d3.w),d2	* a4 ad ecran
	and.w	d4,d2
	tst.w	d2
	bne.s	dplace
	move.w	d4,(a3)+	* a3 ad tableau
	move.w	d3,(a3)+
	or.w	d4,(a4,d3.w)
	bra.s	rayon2
	
dplace:	move.w	d4,(a3)+
	move.w	#$7d00,(a3)+
		
rayon2:	sub.w	pasr,d1			* pas du rayon
	dbra	d5,rayon
	
	add.w	pasd,a0		* pas de l'angle
	cmp.l	a0,a5
	bge.s	ici
	
	move.l	a0,d7
	sub.l	a5,d7
	move.l	#cosinus,a0
	lea	(a0,d7.w),a0
	
ici:	add.w	pasd2,a1
	cmp.l	a1,a6
	bge.s	ici2
	
	move.l	a1,d7
	sub.l	a6,d7
	move.l	#sinus,a1
	lea	(a1,d7.w),a1
	
ici2:	dbra	d6,angle
	
	rts
*-------------------------------------------------------------------------*
*                         SINIUS                               		  *
*-------------------------------------------------------------------------*
wave:
	move.l	#sinus+120,a0	* se place sur degres 12
	move.l	#sinus+2878,a1	* fin du tableau
	lea	point,a2	* tableau des bits set
	move.w	#194,d6	
	
angle2:	move.w	#168,d1		
	move.w	#15,d5

rayon3:	
	move.w	(a0),d2		
	muls 	#15,d2		
	sub.w	d2,d2
	swap	d2
	
	add.w	d1,d2		
	move.w	d2,d3
	and.w	#-16,d3		* masque les 4 derniers bits
	sub.w	d3,d2		
	add.w	d2,d2		* calcule la position du masque
	move.w	(a2,d2.w),d4	* recuper le masque
	lsr.w	#1,d3
	
	move.w	d6,d2
	sub.w	#196,d2
	neg.w	d2
	muls	#160,d2
	add.w	d2,d3		* offset addresse ecran
	addq.w	#6,d3
	

	move.w	(a4,d3.w),d2	* a4 ad ecran
	and.w	d4,d2
	tst.w	d2
	bne.s	dplace2
	move.w	d4,(a3)+	* a3 ad tableau
	move.w	d3,(a3)+
	or.w	d4,(a4,d3.w)
	bra.s	rayon4
	
dplace2:
	move.w	d4,(a3)+
	move.w	#$7d00,(a3)+

rayon4:	subq.w	#1,d1		* pas du rayon
	dbra	d5,rayon3
	
	add.w	#36,a0		* pas de l'angle
	cmp.l	a0,a1
	bge.s	la
	
	move.l	a0,d7
	sub.l	a1,d7
	move.l	#sinus,a0
	lea	(a0,d7.w),a0
	
la:	dbra	d6,angle2
	
	rts

*-------------------------------------------------------------------------*	
*                            droites                                      *
*-------------------------------------------------------------------------*
hori:
	lea	point,a0	* tableau des bits set
	move.w	centx,d0
	
dx:	sub.w	d1,d1		*rayon dans d2
	move.w	#15,d5

dy:	move.w	d0,d2		* ajoute coordonne en x du centre
	move.w	d2,d3
	and.w	#-16,d3		* masque les 4 derniers bits
	sub.w	d3,d2		
	add.w	d2,d2		* calcule la position du masque
	move.w	(a0,d2.w),d4	* recuper le masque
	lsr.w	#1,d3
	
	move.w	d1,d2
	add.w	centy,d2
	muls	#160,d2
	add.w	d2,d3		* offset addresse ecran
	addq.w	#6,d3
	

	move.w	(a4,d3.w),d2	* a4 ad ecran
	and.w	d4,d2
	tst.w	d2
	bne.s	dplace3
	move.w	d4,(a3)+	* a3 ad tableau
	move.w	d3,(a3)+
	or.w	d4,(a4,d3.w)
	bra.s	rayon5
	
dplace3:
	move.w	d4,(a3)+
	move.w	#$7d00,(a3)+

rayon5:	add.w	pasr,d1		* pas du rayon
	dbra	d5,dy
	
	add.w	pasd,d0
	dbra	d6,dx
	
	
	rts
	
*-----------------------------------------------------------------------*

verti:
	lea	point,a0	* tableau des bits set
	move.w	centy,d0
	
dx2:	sub.w	d1,d1		
	move.w	#15,d5

dy2:	move.w	d1,d2
	add.w	centx,d2		* ajoute coordonne en x du centre
	move.w	d2,d3
	and.w	#-16,d3		* masque les 4 derniers bits
	sub.w	d3,d2		
	add.w	d2,d2		* calcule la position du masque
	move.w	(a0,d2.w),d4	* recuper le masque
	lsr.w	#1,d3
	
	move.w	d0,d2
	muls	#160,d2
	add.w	d2,d3		* offset addresse ecran
	addq.w	#6,d3
	

	move.w	(a4,d3.w),d2	* a4 ad ecran
	and.w	d4,d2
	tst.w	d2
	bne.s	dplace4
	move.w	d4,(a3)+	* a3 ad tableau
	move.w	d3,(a3)+
	or.w	d4,(a4,d3.w)
	bra.s	rayon6
	
dplace4:
	move.w	d4,(a3)+
	move.w	#$7d00,(a3)+

rayon6:	add.w	pasr,d1		* pas du rayon
	dbra	d5,dy2
	
	add.w	pasd,d0
	dbra	d6,dx2
	
	rts
*----------------------------------------------------------------------*

obli:	lea	point,a0	* tableau des bits set
	move.w	centx,d0
	
dx3:	sub.w	d1,d1		
	move.w	#15,d5

dy3:	move.w	d0,d2
	move.w	d0,d3
	and.w	#-16,d3		* masque les 4 derniers bits
	sub.w	d3,d2		
	add.w	d2,d2		* calcule la position du masque
	move.w	(a0,d2.w),d4	* recuper le masque
	lsr.w	#1,d3
	
	move.w	d0,d2
	sub.w	centx,d2
	muls	ray,d2
	add.w	d1,d2
	add.w	centy,d2
	muls	#160,d2
	add.w	d2,d3		* offset addresse ecran
	addq.w	#6,d3
	

	move.w	(a4,d3.w),d2	* a4 ad ecran
	and.w	d4,d2
	tst.w	d2
	bne.s	dplace5
	move.w	d4,(a3)+	* a3 ad tableau
	move.w	d3,(a3)+
	or.w	d4,(a4,d3.w)
	bra.s	rayon7
	
dplace5:
	move.w	d4,(a3)+
	move.w	#$7d00,(a3)+

rayon7:	add.w	pasr,d1		
	dbra	d5,dy3
	
	add.w	pasd,d0
	dbra	d6,dx3

	rts
	
	ifne	trackon
	ifne	ste
replay:		include	e:\code\effects.grx\kragflex\audio_r.s
	endc
	ifeq	ste
replay:		include	e:\code\effects.grx\kragflex\audio_f.s
	endc
	endc
	
	Section	data
	
cosinus:	incbin	cosinus.kra
sinus:		incbin	sinus.kra
point:		dc.w	32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1	

*-------------------------------------------------------------------------*
* 	VARIABLES & BUFFERS						  *
*-------------------------------------------------------------------------*

text:	 dc.b	"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.': "
baratin: dc.b	"$3   $1  EGYPTIA  THE 7700 POINTS FLEXIBLE SCROLL WITH"
	 dc.b   " A NEARLY 50 KHZ TRAX     $2   $3   $1  THANX TO MARC"
	 dc.b	" THAT LENT HIS STE TO KRAG TO REALISE THIS SCREEN."
	 dc.b	"   $2  $4       $0" 

		even
code:	 ds.l	1	
image: 	 incbin egyptian.neo
tableau: ds.l	1
font:	 incbin	font2.neo
	 ds.l	450

moduledeb:	incbin	d:\sndtrack\modules\tcn\egyptia.mod

	Section	 bss 

		ds.b	40000
moduleend:	ds.w	1

	even
ecran1:	 ds.l	1
ecran2:	 ds.l	1	
tabcou:	 ds.l	nbcourbe
coucour: ds.l	1	
depha1:	 ds.w	1
depha2:  ds.w	1
pasr:	 ds.w	1
pasd:	 ds.w	1
pasd2:	 ds.w	1
ray:	 ds.w	1
centy:	 ds.w	1
centx:	 ds.w	1
oldiera: ds.w	1
oldierb: ds.w	1
	ifeq	trackon
oldvbl:  ds.l	1
	endc
stack:	 ds.l	1
buffer:	 ds.w	16
ou:	 ds.l	60
lettre:	 ds.l	nbr+2
vsync:	 ds.w	1
espace:	 ds.w	32256
couleur: ds.w	nbcouleur*(nbetape+1)

