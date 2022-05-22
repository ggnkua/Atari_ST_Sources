		********************************
		*  THE ULTIMATE HEADACHE DEMO  *
		* by Humungus & Dogue de Mauve *
		*    from OVERLANDERS (1991)   *
		*       for INNER CIRCLE       *
		********************************
		
* Coding: 	Dogue de Mauve (Intro) - Humungus (Main Demo)
* Graphix:	Furyo (Font) - Ludug (Font) - Walter (Bubbles)
* Music:		Doclands (Main Theme)

* Message from Dogue de Mauve to INNER CIRCLE :

* I hope you won't laugh too much at my little ASM code. I would like 
* to pretend that it was quickly coded (it was, in fact!) and that my
* next demos will be far better but it would hardly be true.
* And forgive all the GFA precalculations but I was a GFA coder before,
* remember, and it's hard to get rid of bad habits...

* I and Humungus wish you a happy including of this screen (we tried
* to code it in the cleanest and clearest way possible) and we're
* both very proud to take part of the new INNER CIRCLE demo... Thanx!

* May the Mauve be with you all!

	opt	d+,o+,ow-
	
TESTVBL	EQU	0
NSPR	EQU	24-1
N_SPR	EQU	9
HT	EQU	7
N	EQU	11

	SECTION TEXT
	
Vsync	macro
	move.w	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	endm

	bsr	INIT		* Lance l'initialisation

MAIN:	
	move.l	$466,d0
VSYNC:	cmp.l	$466,d0		* Synchro VBL ($466=counter)
	beq.s	VSYNC

SWAP:	move.l	ecran2,d0
	move.l	ecran1,ecran2
	move.l	d0,ecran1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	
	bsr	SPRITES
	bsr	SCROLL

	cmpi.b	#57,$fffffc02	* Test ESPACE
	bne.s	MAIN	
	
FIN:

	move.l	$466,d0
VSYNC2:	cmp.l	$466,d0		* Synchro VBL ($466=counter)
	beq.s	VSYNC2

	bsr	DEMO

	move.l	$466,d0
VSYNC3:	cmp.l	$466,d0		* Synchro VBL ($466=counter)
	beq.s	VSYNC3

	move.l	oldsync,$70.w

	clr.b	$fffffa19.w	* Timer B OFF
	move.l	old120,$120.w

	move.b	inter1,$fffffa07.w
	move.b	inter2,$fffffa09.w

	move.l	oldscreen,$ffff8200.w
	move.b	oldrez,$ffff8260.w
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.b	#7,$484.w		* retablit clavier
	move.b	#8,$fffffc02.w	* retablit souris
	
	move.l	#$08000000,$ff8800
	move.l	#$09000000,$ff8800
	move.l	#$0a000000,$ff8800

	move.l	old418,$418.w

	move.l	super,-(a7)	* mode superviseur
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	
	clr.w	-(a7)		* retour bureau
	trap	#1
	

* Routines VBL *


VBL:	addq.l	#1,$466.w

	movem.l	d0-d7,-(a7)
	jsr	player+8

	movem.l	logopal,d0-d7	* Palette logo
	movem.l	d0-d7,$ffff8240.w

	move.l	#CHANGE,$120.w	* Nouvelle HBL
	move.b	#33+1,$fffffa21.w	* Nb de lignes
	move.b	#8,$fffffa1b.w	* Even Count Mode ON
	movem.l	(a7)+,d0-d7

	rte

CHANGE:	
	movem.l	d0-d7,-(a7)
	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr.b	$fffffa1b.w	* Even Count Mode OFF
	movem.l	(a7)+,d0-d7
	rte	

**** PROCEDURES **** 

SPRITES:
	move.l	ecran1,a3		* a3 = ecran actuel
	addq	#4,a3
	
D_SWAP:	move.l	do2,do3
	move.l	do1,do2	
	move.l	do,do1	

D_EFF:	move.l	do3,a0
	addq	#2,a0
	
	move.w	(a0)+,d0		* Position de l'effacage
	move.l	a3,a2
	add.w	d0,a2
	moveq	#0,d0

Q	set	0
	rept	10
	move.l	d0,Q(a2)
	move.l	d0,Q+1*8(a2)
	move.l	d0,Q+2*8(a2)
	move.l	d0,Q+3*8(a2)
	move.l	d0,Q+4*8(a2)
	move.l	d0,Q+5*8(a2)
Q	set	Q+160
	endr

H_SWAP:	move.l	h2,h3
	move.l	h1,h2	
	move.l	h,h1	

H_EFF:	move.l	h3,a0
	addq	#2,a0
	
	move.w	(a0)+,d0		* Position de l'effacage
	move.l	a3,a2
	add.w	d0,a2
	moveq	#0,d0

Q	set	0
	rept	10
	move.l	d0,Q(a2)
	move.l	d0,Q+1*8(a2)
	move.l	d0,Q+2*8(a2)
	move.l	d0,Q+3*8(a2)
	move.l	d0,Q+4*8(a2)
Q	set	Q+160
	endr

S_SWAP:	move.l	s2,s3
	move.l	s1,s2	
	move.l	s,s1	

S_EFF:	move.l	s3,a0
	
	moveq	#NSPR,d7
EFF:		
	addq	#2,a0
	move.w	(a0)+,d1		* Position de l'effacage
	move.l	a3,a2
	add.w	d1,a2
	
Q	set	0
	rept	16
	move.l	d0,Q(a2)
	move.l	d0,Q+8(a2)
Q	set	Q+160
	endr
	dbra	d7,EFF

D_AFF:	move.l	do,a0
	
	move.w	(a0)+,d0		* Position dans le buffer sprite
	lea	dog,a1
	add.w	d0,a1	
	
	move.w	(a0)+,d0		* Position de l'affichage
	move.l	a3,a2
	add.w	d0,a2

Q	set	0
	rept	10
	movem.l	(a1)+,d0-d5
	move.l	d0,Q(a2)
	move.l	d1,Q+1*8(a2)
	move.l	d2,Q+2*8(a2)
	move.l	d3,Q+3*8(a2)
	move.l	d4,Q+4*8(a2)
	move.l	d5,Q+5*8(a2)
Q	set	Q+160
	endr
	
D_TEST:	cmpa.l	#fdog,a0
	bne.s	D_OK
	lea	dogtbl,a0
D_OK	move.l	a0,do

H_AFF:	move.l	h,a0
	
	move.w	(a0)+,d0		* Position dans le buffer sprite
	lea	hum,a1
	add.w	d0,a1	
	
	move.w	(a0)+,d0		* Position de l'affichage
	move.l	a3,a2
	add.w	d0,a2

Q	set	0
	rept	10
	movem.l	(a1)+,d0-d4
	or.l	d0,Q(a2)
	or.l	d1,Q+1*8(a2)
	or.l	d2,Q+2*8(a2)
	or.l	d3,Q+3*8(a2)
	or.l	d4,Q+4*8(a2)
Q	set	Q+160
	endr
	
H_TEST:	cmpa.l	#fhum,a0
	bne.s	H_OK
	lea	humtbl,a0
H_OK	move.l	a0,h


S_AFF:	move.l	s,a0
	lea	bubble,a4	

	moveq	#NSPR,d7
AFF:		
	move.w	(a0)+,d0		* Position dans le buffer sprite
	move.l	a4,a1
	add.w	d0,a1	
	
	move.w	(a0)+,d0		* Position de l'affichage
	move.l	a3,a2
	add.w	d0,a2	

	movem.l	(a1)+,d0-d6
	or.l	d0,(a2)
	or.l	d1,1*8(a2)
	or.l	d2,1*160(a2)
	or.l	d3,1*160+8(a2)
	or.l	d4,2*160(a2)
	or.l	d5,2*160+8(a2)
	or.l	d6,3*160(a2)
	movem.l	(a1)+,d0-d6
	or.l	d0,3*160+8(a2)
	or.l	d1,4*160(a2)
	or.l	d2,4*160+8(a2)
	or.l	d3,5*160(a2)
	or.l	d4,5*160+8(a2)
	or.l	d5,6*160(a2)
	or.l	d6,6*160+8(a2)
	movem.l	(a1)+,d0-d6
	or.l	d0,7*160(a2)
	or.l	d1,7*160+8(a2)
	or.l	d2,8*160(a2)
	or.l	d3,8*160+8(a2)
	or.l	d4,9*160(a2)
	or.l	d5,9*160+8(a2)
	or.l	d6,10*160(a2)
	movem.l	(a1)+,d0-d6
	or.l	d0,10*160+8(a2)
	or.l	d1,11*160(a2)
	or.l	d2,11*160+8(a2)
	or.l	d3,12*160(a2)
	or.l	d4,12*160+8(a2)
	or.l	d5,13*160(a2)
	or.l	d6,13*160+8(a2)
	movem.l	(a1)+,d0-d3
	or.l	d0,14*160(a2)
	or.l	d1,14*160+8(a2)
	or.l	d2,15*160(a2)
	or.l	d3,15*160+8(a2)

	dbra	d7,AFF

S_TEST:	cmpa.l	#fstbl,a0
	bne.s	S_OK
	lea	stbl,a0
S_OK	move.l	a0,s

	rts



* SCROLLUS *

	
SCROLL:
	move.l	scrpt,a0		* Mets scroll pointeur dans a0

SWAP_SWAP:	
	move.l	buffer1,d0	* Swapping des buffers
	move.l	buffer2,buffer1
	move.l	d0,buffer2

	move.l	bplus1,d0		* Swapping des "bonus buffer"
	move.l	bplus2,bplus1
	move.l	d0,bplus2
	
BUFFCOOL:
	addi.w	#32*4,bplus2
	cmpi.w	#32*20*4,bplus2
	bne.s	TRANCHE
	move.w	#0,bplus2

TRANCHE:	

	move.l	oldt,d1		* RecupŠre ancienne tranche

	addq.b	#1,trpt		* Compteur de tranches
	cmpi.b	#4,trpt		* Si compteur = 4
	bne.s	AFFI

	* Changement de lettre
	
	moveq	#0,d1
	move.b	#0,trpt		* Tranche = 0
	move.b	(a0)+,d1		* CaractŠre suivant
	tst.b	d1		* Test de Wraping
	bne.s	CONT_SCROLL
	lea	phrase,a0		* Si oui, remet au d‚but
	move.b	(a0)+,d1		* CaractŠre suivant
		
CONT_SCROLL:
	cmpi.b	#73,d1		* Cas sp‚cial pour le "I"
	bne.s	SUITE
	move.b	#2,trpt		* Tranche = 2

SUITE:
	sub.w	#32,d1		* Valeur ASCII - 32
	ext.w	d1		* Sur un mot long...
	lsl.l	#8,d1		* d1 x 256 (Taille x Plan x Tranches)
	
	add.l	#font,d1		* Ajoute l'adresse de la font
	sub.l	#32*2,d1		* Soustrait une tranche puis...
	
AFFI:
	addi.l	#32*2,d1		* Ajoute une tranche
	move.l	a0,scrpt		* Reinitialise le scroll pointeur


PUT:
	move.l	buffer2,a2
	adda	bplus2,a2		* Tranche invisible
	lea	32*4*20(a2),a3	* Tranche visible
	move.l	oldt,a0		* Mets ancienne adr. tranche ds a0
	move.l	d1,a1		* Mets nouvelle adr. tranche ds a1
	move.l	d1,oldt		* Stocke tranche

Q	set	0
	rept	8*4
	move.b	(a0)+,Q(a2)	
	move.b	(a0)+,Q+2(a2)
	move.b	(a1)+,Q+1(a2)
	move.b	(a1)+,Q+3(a2)
Q	set	Q+4
	endr

Q	set	0
	rept	8*4
	move.l	(a2)+,Q(a3)	
Q	set	Q+4
	endr

SHOWIT:	
	move.l	ecran1,a1		* Adr. ‚cran dans a1
	lea	39*160(a1),a1	* Position … l'‚cran
	move.l	qsin,a3		* Table de Sinus dans a3


	move.l	#160-1,d0		* 160 lignes … afficher
BIG:
	moveq	#0,d1
	move.l	a2,a0
	move.b	(a3)+,d1
	cmpi.b	#32*4,d1
	bne.s	ADD
	move.l	#vide,a0
	bra.s 	TRUC
	
ADD:	lea	(a0,d1),a0 

TRUC:
Z	set	0
Q	set	0	
	rept	20
	move.l	Q(a0),Z(a1)
Z	set	Z+8
Q	set	Q+32*4
	endr
	
	lea	160(a1),a1

	dbra	d0,BIG
	
	ifne	TESTVBL
	move.w	#$77,$ffff8240.w
	endc

	cmpa.l	#fsin,a3
	blt	suitos
	lea	sin,a3
	
SUITOS:
	move.l	a3,qsin

	rts


* Appelle l' "Ultimate Headache Screen" *

VBL2:	addq.l	#1,$466.w

	jsr	player+8

	movem.l	d0-d7,-(a7)
	movem.l	logopal,d0-d7	* Palette logo
	movem.l	d0-d7,$ffff8240.w

	move.l	#CHANGE,$120.w	* Nouvelle HBL
	move.b	#33+1,$fffffa21.w	* Nb de lignes
	move.b	#8,$fffffa1b.w	* Even Count Mode ON

	bsr	efface
	bsr	sprite
	
	movem.l	(a7)+,d0-d7
	rte

;	routines sprites

sprite:	move.w	AV,d6
	move.w	d6,d5
	mulu.w	#N,d5
	
	lea	minipos,a2
	lea	minipre,a3
	add.w	d5,a3
	add.w	d5,d5
	add.w	d5,a2
	
	move.l	ecran1,a1
	lea	spr_str,a6
	move.l	eff0,a5
	moveq.l	#0,d2
	moveq.l	#N-1,d1

aff_spr:	move.l	a1,a0
	add.w	(a2)+,a0
	move.l	a0,(a5)+
	
	move.l	(a6)+,a4
	
	move.b	(a3)+,d2
	move.l	(a4,d2.w),a4
	jsr	(a4)
	
	dbra	d1,aff_spr
	
	addq.w	#1,d6
	cmp.w	#180,d6
	bne.s	ok_sp
	moveq.w	#0,d6
ok_sp:	move.w	d6,AV
	
;	move.l	eff0,d0
;	move.l	eff2,eff0
;	move.l	d0,eff2
	
	rts
	
efface:	move.l	eff0,a0
	moveq	#0,d0
	moveq.l	#N-1,d1
a_eff:	move.l	(a0)+,a1
X	set	0	
	rept	HT
	move.w	d0,X(a1)
	move.w	d0,X+8(a1)
X	set	X+160
	endr
	
	dbra	d1,a_eff
	rts

DEMO:
	movem.l	plpal,d0-d7
	movem.l	d0-d7,pal

	move.l	ecran1,a0
	lea	32000(a0),a0
	move.l	ecran2,a1	
	lea	32000(a1),a1

	movem.l	vide,d0-d6/a2-a6
	
	move.l	#562,d7
CLRS:	movem.l	d0-d6/a2-a6,-(a0)
	movem.l	d0-d6/a2-a6,-(a1)
	dbra	d7,CLRS

PREPARE:	lea	pleez,a0
	move.l	ecran1,a1
	lea	160*90+4*8(a1),a1

	move.l	#21-1,d7		* 21 lignes de haut
GP_AFF:

	movem.l	(a0)+,d0-d6/a2-a5
	move.l	d0,(a1)
	move.l	d1,1*8(a1)
	move.l	d2,2*8(a1)
	move.l	d3,3*8(a1)
	move.l	d4,4*8(a1)
	move.l	d5,5*8(a1)
	move.l	d6,6*8(a1)
	move.l	a2,7*8(a1)
	move.l	a3,8*8(a1)
	move.l	a4,9*8(a1)
	move.l	a5,10*8(a1)
	lea	160(a1),a1
	dbra	d7,GP_AFF
	
	bsr	INI_SPR
	
	move.l	$466,d0
VSYNC4:	cmp.l	$466,d0		* Synchro VBL ($466=counter)
	beq.s	VSYNC4
	
	move.l	#VBL2,$70.w
		
KOKO:	cmpi.b	#1,$fffffc02
	bne	KOKO
	
	rts

* Initialisation *

;	initialisation sprites

INI_SPR:	moveq	#N_SPR-1,d7
	lea	mini_dat,a6	donnees sprites
	lea	adr_rout,a5	adresse des routines
	lea	r_sprite,a4	emplacement des routines

z_spr:	
	lea	dec_spr,a1
	moveq	#0,d1
	moveq.l	#HT-1,d0		recopie sprite 1er decalage
a_dec:	move.w	(a6)+,(a1)+
	move.w	d1,(a1)+
	dbra	d0,a_dec
	
	moveq.l	#14,d0		nbre de decalage
	lea	dec_spr,a0
	move.l	a0,a1
	add.l	#HT*2*2,a1
	moveq.l	#1,d1
b_dec:	moveq.l	#HT-1,d2
c_dec:	move.l	(a0)+,d3
	lsr.l	d1,d3		decale 15 fois
	move.l	d3,(a1)+
	dbra	d2,c_dec
	dbra	d0,b_dec
	
	lea	dec_spr,a0	adresse des decalages
	moveq.l	#15,d0		nbre de decalage
	
a_spr:	move.l	a4,(a5)+		sauve l'adresse de debut de la routine
	
	moveq.l	#2*HT-1,d1		nombre de .W a tester dans 1 sprites
	move.w	#8,add1
	move.w	#152,add2
	moveq.l	#0,d2
	lea	buf_spr,a2	adresse pour les stat. du sprite
	sub.l	#32,a2
	move.l	#0,a3
			
b_spr:	move.w	(a0)+,d3		debut boucle stat.		
	tst.w	d3		si .W=0 on passe au suivant
	beq.s	e_spr
no_qq:	move.w	d2,d4		nbre de .W deja trouves
	moveq.w	#0,d5
c_spr:	cmp.w	(a2,d5.w),d3	teste si ce .W a deja ete trouve	
	beq.s	d_spr		
	add.w	#32,d5
	dbf	d4,c_spr
	addq.w	#1,d2		nouveau .W
	move.w	d3,(a2,d5.w)	sauve ce .W
	move.w	#0,2(a2,d5.w)	initialise son compteur
	move.w	a3,4(a2,d5.w)	sauve l'emplacement de ce .W ds le sprite
	bra.s	e_spr

d_spr	move.w	2(a2,d5.w),d6	.W deja trouve
	addq.l	#1,d6		incremente son compteur
	move.w	d6,2(a2,d5.w)
	add.w	d6,d6
	add.w	d6,d5
	move.w	a3,4(a2,d5.w)	sauve son emplacement ds le sprite

e_spr:	add.w	add1,a3		emplacement suivant ds le sprite
	move.w	add1,d3
	move.w	add2,add1
	move.w	d3,add2
	dbra	d1,b_spr		boucle stat.
	
	subq.l	#1,d2		nbre de .W recenses
	lea	buf_spr,a2	donnees stat.	
	moveq.l	#0,d1
f_spr:	move.w	2(a2,d1.w),d3	nbre d'apparitions de ce .W
	tst.w	d3
	beq.s	h_spr		si 1 seule apparition
	
	move.w	(a2,d1.w),d5
	cmp.w	#127,d5
	bhi.s	tstq_2
	or.w	#$7000,d5		moveq	A,d0
	move.w	d5,(a4)+
	bra.s	q_spr
	
tstq_2:	cmp.w	#$FF00,d5
	bhi.s	q2
	bra.s	no_quick
q2:	and.w	#$00FF,d5
	or.w	#$7000,d5		moveq	A,d0
	move.w	d5,(a4)+
	bra.s	q_spr
	
no_quick:	move.w	#$303C,(a4)+	move.w	A,d0
	move.w	d5,(a4)+
q_spr:	move.w	d1,d4
	addq.w	#4,d4

g_spr:	move.w	(a2,d4.w),d5	offset
	tst.w	d5
	bne.s	offset
	
	move.w	#$8150,(a4)+	or.w	d0,(a0)
	bra.s	g2_spr
	
offset:	move.w	#$8168,(a4)+	or.w	d0,X(a0)
	move.w	d5,(a4)+
	
g2_spr:	addq.w	#2,d4
	dbra	d3,g_spr
	bra.s	i_spr

h_spr:	move.w	4(a2,d1.w),d5	offset
	tst.w	d5
	bne.s	offset2
	
	move.w	#$0050,(a4)+
	move.w	(a2,d1.w),(a4)+	or.w	A,(a0)
	bra.s	i_spr

offset2:	move.w	#$0068,(a4)+	or.w	A,X(a0)
	move.w	(a2,d1.w),(a4)+
	move.w	d5,(a4)+
i_spr:	add.w	#32,d1
	dbra	d2,f_spr
	
	move.w	#$4E75,(a4)+	rts
	
	dbra	d0,a_spr
	
	dbra	d7,z_spr
	
	
	lea	b_eff,a0
	lea	b_eff2,a1
	move.l	a0,eff0
	move.l	a1,eff2
	move.l	ecran1,d0
	move.l	#N-1,d1
j_spr:	move.l	d0,(a0)+
	move.l	d0,(a1)+
	dbra	d1,j_spr
	
	rts
		

INIT:	
	clr.l	-(a7)		* mode superviseur
	move	#$20,-(a7)
	trap	#1
	adda.l	#6,a7
	move.l	d0,super
	
	Vsync

	move.l	$70.w,oldsync
	move.b	$ffff8260.w,oldrez
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	clr.b	$ffff8260.w
		
	move.b	#$12,$fffffc02.w	* coupe souris
	clr.b	$484.w		* coupe clavier
	move.w	#1,$4ee.w		* coupe ALT-HELP

	move.l	$ffff8200.w,oldscreen

	move.l	#mem,d0
	clr.b	d0
	move.l	d0,ecran1
	add.l	#32000,d0
	move.l	d0,ecran2

	Vsync
	
	move.l	$418.w,old418
	move.l	#16,$418.w

	move.b	$fffffa07.w,inter1	* sauve interruptions MFP 0-7
	move.b	$fffffa09.w,inter2	* sauve interruptions MFP 8-15
	clr.b	$fffffa09.w	* Coupe MFP 8-15

	clr.b	$fffffa19.w	* Timer B OFF
	move.b	#1,$fffffa07.w	* Timer B Enable
	
	move.b	#1,$fffffa13.w	* Timer B masqu‚
	bclr.b	#3,$fffffa17.w	* Automatic End of Interrupt

	move.l	$120.w,old120	* Sauve HBL
	move.l	#CHANGE,$120.w	* Nouvelle HBL

	move.l	#pic,a0	
	move.l	ecran1,a1
	move.l	ecran2,a2	

	move.l	#31*40-1,d7
LOGO:	movem.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra	d7,LOGO
	
	move.l	#169*40-1,d7
CLEAR:	clr.l	(a1)+
	clr.l	(a2)+
	dbra	d7,CLEAR

	move.l	#buff1,buffer1	* Stocke addresse buffers 
	move.l	#buff2,buffer2	* dans variables buffers

	move.l	buffer1,a0
	move.l	buffer2,a1
	move.l	#(32*160*2/4)-1,d7
EFFBUFF:	clr.l	(a0)+
	clr.l	(a1)+
	dbra	d7,EFFBUFF

	lea	vide,a0
	move.l	#(20*32*4/4)-1,d7
EFFVID:	clr.l	(a0)+
	dbra	d7,EFFVID

	jsr	player		* Appelle la musique

	move.l	#VBL,$70.w	* Installe nouvelle VBL

	move.l	#dogtbl,do
	move.l	do,do1
	move.l	do,do2
	move.l	do,do3

	move.l	#humtbl,h
	move.l	h,h1
	move.l	h,h2
	move.l	h,h3

	move.l	#stbl,s
	move.l	s,s1
	move.l	s,s2
	move.l	s,s3

	clr.l	bplus1
	clr.l	bplus2

	move.l	#phrase,scrpt	* scrpt pointe sur le texte 
	move.l	#font,oldt	* oldt pointe sur vide
	move.b	#3,trpt		* tranche = 3

	rts	
	
	SECTION	DATA

phrase:	incbin	\LINK.O\SCROLLUS.TXT
nul:	dc.b	0
	even

player:	incbin	\LINK.O\SCROLLUS.MUS
pic:	incbin	\LINK.O\OVERLOGO
pal:	incbin	\LINK.O\SCROLLUS.PAL
logopal:	incbin	\LINK.O\LOGO.PAL
font:	incbin	\LINK.O\LUDUG.FNT
sin:	incbin	\LINK.O\SCROLLUS.TBL
fsin:
qsin:	dc.l	sin

pleez:	incbin	\LINK.O\PLEEZ.DAT
plpal:	incbin	\LINK.O\PLEEZ.PAL

dog:	incbin	\LINK.O\DOGUE.SPR
hum:	incbin	\LINK.O\HUMUNGUS.SPR
bubble:	incbin	\LINK.O\BUBBLE.SPR

dogtbl:	incbin	\LINK.O\DOGUE.TBL
fdog:
humtbl:	incbin	\LINK.O\HUMUNGUS.TBL
fhum:
stbl:	incbin	\LINK.O\SPRITES.TBL
fstbl:
minipos:	incbin	\LINK.O\miniPOS.DAT
minipre:	incbin	\LINK.O\miniPRE.DAT
	even
mini_dat:	incbin	\LINK.O\miniSPR.DAT
spr_str:	dc.l	adr_rout+16*4*0
	dc.l	adr_rout+16*4*1
	dc.l	adr_rout+16*4*2
	dc.l	adr_rout+16*4*3
	dc.l	adr_rout+16*4*4
	dc.l	adr_rout+16*4*5
	dc.l	adr_rout+16*4*6
	dc.l	adr_rout+16*4*7
	dc.l	adr_rout+16*4*2
	dc.l	adr_rout+16*4*3
	dc.l	adr_rout+16*4*8
	
	SECTION	BSS
	
* Variables *
	even

buffer1:	ds.l	1
buffer2:	ds.l	1

bplus1:	ds.w	1
bplus2:	ds.w	1

scrpt:	ds.l	1
oldt:	ds.l	1

do:	ds.l	1
do1:	ds.l	1
do2:	ds.l	1
do3:	ds.l	1

h:	ds.l	1
h1:	ds.l	1
h2:	ds.l	1
h3:	ds.l	1

s:	ds.l	1
s1:	ds.l	1
s2:	ds.l	1
s3:	ds.l	1

trpt:	ds.b	1		* Compteur de tranches
	even

* Memoire & adresses *

	ds.b	256
mem:	ds.b	64000		* Ecran logique
ecran1:	ds.l	1
ecran2:	ds.l	1

buff1:	ds.b	32*160*2		* Buffers Double-largeur
buff2:	ds.b	32*160*2
	
vide:	ds.b	20*4*32		* Ligne vide

AV:	ds.w	1		* BSS MINISPRITES
add1:	ds.w	1
add2:	ds.w	1

eff0:	ds.l	1
eff2:	ds.l	1
b_eff:	ds.l	N
b_eff2:	ds.l	N

adr_rout:	ds.l	16*N_SPR

r_sprite:	ds.b	N_SPR*(HT*12+2)*16
	ds.b	32
buf_spr:	ds.b	32*HT
dec_spr:	ds.w	16*HT*2


* Variables r‚serv‚es *

inter1:	ds.b	1
inter2:	ds.b	1
	even

old418	ds.l	1
oldscreen	ds.l	1
oldpal	ds.w	16
oldrez	ds.w	1
oldsync	ds.l	1
old120	ds.l	1
super	ds.l	1
	even

end
