		***************************************
		*   TRANSBEAUCE 2 - LESSER SCREENS    *
		* 	     Crap Menu              *
		*          by Dogue de Mauve          *
		*        from OVERLANDERS (1991)      *
		***************************************

* Coding : 	Dogue de Mauve (with help from nice friends...)
* Graphix :	Babar, Speedlight & The Sergeant
* Muzak :		Mad Max

* Version : GenST 2.20

	opt	o+,ow2-

TESTVBL	EQU	0
NSPR	EQU	6-1

DEMOS	EQU	15-1	* Nombre de d‚mos

v_sync	macro
	move.l	L466,d0
.\@	cmp.l	L466,d0
	beq.s	.\@
	endm

	SECTION TEXT

	move.l	#mem,d0
	clr.b	d0
	move.l	d0,ecran1
	add.l	#32000,d0
	move.l	d0,ecran2

	clr.b	$fffffa09.w		* Coupe MFP 8-15
	move.b	#$40,$fffffa17.w	;AEI
	clr.b	$fffffa1b.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

	lea	pic,a0

	MOVE	#160*200/8-1,D7
DECOMPV:

SHIFT4	MACRO
	ADD	D0,D0
	ADDX	D1,D1
	ADD	D0,D0
	ADDX	D2,D2
	ADD	D0,D0
	ADDX	D3,D3
	ADD	D0,D0
	ADDX	D4,D4
	ENDM

	REPT	4
	MOVE	(A0)+,D0
	SHIFT4
	SHIFT4
	SHIFT4
	SHIFT4
	ENDR

	MOVEM	D1-D4,-8(A0)
	DBRA	D7,DECOMPV

	lea	pic,a0
	move.l	ecran1,a1
	move.l	ecran2,a2

	move	#160*200/4-1,d7
BCK:	move.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	dbra	d7,BCK

	movem.l	palette_pic,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#sprxy,s0
	move.l	#sprxy,s1
	move.l	#sprxy,s2
	move.l	#sprxy,s3

	lea	phrase,a0
	move.l	a0,txt		* txt pointe sur le debut du texte
	move.l	#font,oldtranche	* oltranche pointe sur un vide
	move.b	#0,cptr		* Compteur de tranche = 0
	move.b	#0,direc
	move.b	#0,posdemo
	move.b	#$39,space

	move.b	#DEMOS,nbdemo

	bsr	SPRITER

	lea	music,a0
	moveq	#1,d0
	bsr	player		* Appelle la musique
	move.l	#VBL,$70.w

MAIN:
	v_sync

	IFNE	TESTVBL
	move.w	#$555,$ffff8240.w
	endc

;SWAP:
	move.l	ecran2,d0
	move.l	ecran1,ecran2
	move.l	d0,ecran1
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	bsr	SPRITES
	bsr	SCROLL
	bsr	VERTICAL

	bsr	CLAVIER

	clr.w	$ffff8240.w

	bra.s	MAIN

FIN:
	move	#$2700,sr
	move.l	#$8080000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$a0a0000,$ffff8800.w
	clr	d0
	move.b	nbdemo,d0		* Ici Tester la d‚mo … charger
	move.b	convnum(pc,d0.w),d0
	move	d0,$4fe.w	;num‚ro de la d‚mo
	illegal

convnum:
	DC.B	8+1	;VOYAGERS
	DC.B	7+1	;TSB
	DC.B	14+1	;TBC
	DC.B	5+1	;SILVERS
	DC.B	13+1	;OUTLAWS
	DC.B	6+1	;MISFITS
	DC.B	15+1	;MEGABUSTERS
	DC.B	9+1	;MCS
	DC.B	12+1	;HOLOCAUST
	DC.B	3+1	;EQUINOX
	DC.B	2+1	;DEFCON 4
	DC.B	1+1	;CYBERNETICS
	DC.B	4+1	;ART OF CODE 2
	DC.B	11+1	;ART OF CODE 1
	DC.B	10+1	;ARTIS MAGIA
	even

* 0	ARTIS MAGIA
* 1	ART OF CODE 1
* 2	ART OF CODE 2
* 3	CYBERNETICS
* 4	DEFCON 4
* 5	EQUINOX
* 6	HOLOCAUST
* 7	MCS
* 8	MEGABUSTERS
* 9	MISFITS
* 10	OUTLAWS
* 11	SILVERS
* 12	T.B.C
* 13	T.S.B
* 14	VOYAGERS - ENIGMA

	*	...	*




* Routines VBL *

VBL:
	addq.l	#1,L466

	movem.l	d0-d7,-(a7)
	bsr	player+4

	movem.l	npal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.b	$fffffa1b.w	* Timer B OFF
	move.l	#CHANGE,$120.w	* Nouvelle HBL
	move.b	#25-1,$fffffa21.w	* Nb de lignes
	move.b	#8,$fffffa1b.w	* Even Count Mode ON

	movem.l	(a7)+,d0-d7

	rte

CHANGE:
	movem.l	d0-d7,-(a7)

	movem.l	palette_pic,d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifne	TESTVBL
	move.w	#$555,$ffff8240.w
	endc

	clr.b	$fffffa1b.w		* Timer B OFF
	move.l	#CHANGE2,$120.w		* Nouvelle HBL
	move.b	#199-32-24,$fffffa21.w	* Nb de lignes
	move.b	#8,$fffffa1b.w		* Even Count Mode ON

	movem.l	(a7)+,d0-d7
	rte

CHANGE2:
	movem.l	d0-d7,-(a7)

	movem.l	fpal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifne	TESTVBL
	move.w	#$555,$ffff8240.w
	endc

	clr.b	$fffffa1b.w	* Even Count Mode OFF

	movem.l	(a7)+,d0-d7
	rte


*********************************************************************************

			* SPRITES *

*********************************************************************************

SPRITES:
	move.l	ecran1,a6		* a6 = ecran actuel

;SSWAP:
	move.l	s2,s3
	move.l	s1,s2
	move.l	s0,s1


		* Debut de l'effacage *

* a0 : position dans la table
* a1 : position effacage dans ‚cran "back"
* a2 : position affichage … l'‚cran
* a3 :  -
* a4 :  -
* a5 :  -
* a6 : ‚cran de base

* d7 : compteur

EFF:
	move.l	s3,a0		* Ancienne position ds la table
	addq	#2,a0		* Saute valeur X

	moveq	#NSPR,d7
E0:
	move.w	(a0),d0		* Position de l'effacage
	addq	#4,a0
	lea	pic,a1		* Back dans a1
	move.l	a6,a2		* Ecran dans a2
	add.w	d0,a1
	add.w	d0,a2

Q	set	160
	movem.l	(a1),d0-d5	* Gagne quelques cycles...
	movem.l	d0-d5,(a2)
	rept	31
	movem.l	Q(a1),d0-d5
	movem.l	d0-d5,Q(a2)
Q	set	Q+160
	endr

	dbra	d7,E0


		* Debut de l'affichage *

* a0 : position dans la table
* a1 : position dans buffer mask
* a2 : position dans buffer sprite
* a3 : position … l'‚cran 1
* a4 : position … l'‚cran 2
* a5 : utilis‚ pour additions
* a6 : ‚cran de base

SMSK:
	move.l	s0,a0

	lea	q1mask,a1		* 1
	lea	q1dec,a2
	bsr.s	SD

	lea	cmask,a1		* 2
	lea	cdec,a2
	bsr.s	SD

	lea	cmask,a1		* 3
	lea	cdec,a2
	bsr.s	SD

	lea	cmask,a1		* 4
	lea	cdec,a2
	bsr.s	SD

	lea	cmask,a1		* 5
	lea	cdec,a2
	bsr.s	SD

	lea	tmask,a1		* 6
	lea	tdec,a2
	bsr.s	SD

S_TEST:	cmpa.l	#fspr,a0
	bne.s	S_OK
	lea	sprxy,a0
S_OK	move.l	a0,s0

	rts

SD:
	move.w	(a0)+,d0
	add.w	d0,a1		* Position dans buffer masque
	add.w	d0,d0		* d0 = d0 x 2
	add.w	d0,a2		* Position dans buffer sprite

	move.w	(a0)+,d0
	move.l	a6,a3		* Ecrans dans a3
	add.w	d0,a3
	move.l	a3,a4		* Positions … l'ecran

	move.l	#160-3*8,a5	* a5 utilis‚ pour additions

	rept	32
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a3)+,d0
	and.l	(a3)+,d1
	or.l	(a2)+,d0
	or.l	(a2)+,d1

	move.l	(a1)+,d2
	move.l	d2,d3
	and.l	(a3)+,d2
	and.l	(a3)+,d3
	or.l	(a2)+,d2
	or.l	(a2)+,d3

	move.l	(a1)+,d4
	move.l	d4,d5
	and.l	(a3)+,d4
	and.l	(a3)+,d5
	or.l	(a2)+,d4
	or.l	(a2)+,d5

	movem.l	d0-d5,-(a3)
	lea	160(a3),a3
	endr

	ifeq	1

	rept	32/2
	movem.l	(a1)+,d0-d5
	and.l	d0,(a3)+
	and.l	d0,(a3)+
	and.l	d1,(a3)+
	and.l	d1,(a3)+
	and.l	d2,(a3)+
	and.l	d2,(a3)+
	add.l	a5,a3
	and.l	d3,(a3)+
	and.l	d3,(a3)+
	and.l	d4,(a3)+
	and.l	d4,(a3)+
	and.l	d5,(a3)+
	and.l	d5,(a3)+
	add.l	a5,a3
	endr

	rept	32
	movem.l	(a2)+,d0-d5
	or.l	d0,(a4)+
	or.l	d1,(a4)+
	or.l	d2,(a4)+
	or.l	d3,(a4)+
	or.l	d4,(a4)+
	or.l	d5,(a4)+
	add.l	a5,a4
	endr
	endc

	rts

*********************************************************************************

			* SCROLLER *

*********************************************************************************

SCROLL:

BMOVE:
	move.l	ecran1,a1		* Mets position a scroller dans a1
	lea	168*160(a1),a1
	move.l	a1,a0
	addq.w	#8,a0		* ...et a0
	move.w	#40,a4		* a4 utilis‚ pour additions

	rept	31*4
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,(a1)
	add.w	a4,a1
	endr

TRANCHE:
	move.l	ecran1,a1
	lea	168*160+152(a1),a1	* Mets position d'affichage dans a1

	move.l	txt,a0		* Mets pointeur texte dans a0
	move.l	oldtranche,d1	* Mets ancienne tranche dans d1

	move.b	cptr,d0
	addq	#1,d0		* Compteur de tranches (d0)
	cmpi.b	#4,d0
	bne.s	FINTEST

	moveq	#0,d0		* Changement de lettre
	move.b	(a0)+,d1
	tst.b	d1
	bne.s	CONT_SCROLL
	lea	phrase,a0		* Wrap
	move.b	(a0)+,d1

CONT_SCROLL:
	cmpi.b	#73,d1		* Cas sp‚cial pour le "I"
	bne.s	SUITE
	moveq	#2,d0
SUITE:
	sub.w	#32,d1
	ext.w	d1
	lsl.l	#8,d1		* d1 = d1 x 8
	add.l	d1,d1
	add.l	#font-32*4,d1

FINTEST:
	move.b	d0,cptr		* Re-init du compteur de tranches
	move.l	a0,txt		* Re-init du pointeur de texte
	addi.l	#32*4,d1		* Tranche suivante dans d1
	move.l	oldtranche,a0	* Stocke ancienne tranche dans a0
	move.l	d1,oldtranche	* Ancienne tranche = nouvelle

AFFSCROLL:

* Affiche ancienne tranche

Q	set	0
	rept	31
	move.b	(a0)+,Q(a1)
	move.b	(a0)+,Q+2(a1)
	move.b	(a0)+,Q+4(a1)
	move.b	(a0)+,Q+6(a1)
Q	set	Q+160
	endr

	addq.l	#1,a1
	move.l	d1,a0

Q	set	0		* Affiche nouvelle tranche
	rept	31
	move.b	(a0)+,Q(a1)
	move.b	(a0)+,Q+2(a1)
	move.b	(a0)+,Q+4(a1)
	move.b	(a0)+,Q+6(a1)
Q	set	Q+160
	endr

	rts

*********************************************************************************

                           * "MENU" DES DEMOS *

*********************************************************************************

VERTICAL:
	clr	d0
	move.b	nbdemo,d0
	mulu	#24*160,d0

	lea	names,a0
	add.l	d0,a0

	move.w	direc,d1		* Direction dans d1
	move.w	posdemo,d2	* Position dans d2

	tst.w	d1		* Si = 0 alors va … NOMOVE
	beq.s	NOMOVE
	add.w	d1,d2		* Addition direction
;	tst.w	d2		* Si Position <> 0 ...
	bne.s	SI_2		* ... va … SI_2
	moveq	#0,d1		* Sinon Direc. & Posi. annul‚es
	moveq	#0,d2
SI_2:	cmpi.w	#24*160,d2	* Si Position <> 24*160 ...
	bne.s	NOMOVE		* ... va … NOMOVE
	moveq	#0,d1		* Sinon Direc. & Posi. annul‚es
	moveq	#0,d2

NOMOVE:	move.w	d1,direc
	move.w	d2,posdemo

	add.w	d2,a0		* Rajoute position dans le logo

	move.l	ecran1,a1		* Ecran dans a1
	lea	24*160(a1),a1

VBMOVE:
	rept	24*4
	movem.l	(a0)+,d0-d7/a5-a6	* Affichage chiant mais rus‚...
	movem.l	d0-d7/a5-a6,-(a1)
	endr

	rts

*********************************************************************************

			* CLAVIER *

*********************************************************************************

CLAVIER:
	moveq	#0,d0
	moveq	#0,d1
	move.b	nbdemo,d2

	move.b	$fffffc02.w,d0
;	move.b	touche,d1
;	cmp.b	d0,d1
;	beq.s	FIN_CLAVIER

	cmp.b	space,d0
	bne.s	.notspc
	eor.b	#$80,space		;anti-rebond
	bpl	FIN
.notspc
	cmpi.w	#0,direc
	bne.s	FIN_CLAVIER

	cmpi.b	#$48,d0
	bne.s	BAS
	cmpi.b	#0,d2
	beq.s	FINHAUT
	subq.b	#1,d2
	move.w	#-160,direc	* Direction Haut (-160)
	move.w	#24*160,posdemo	* Position bas du logo
FINHAUT:
	bra.s	FIN_CLAVIER

BAS:	cmpi.b	#$50,d0
	bne.s	FIN_CLAVIER
	cmpi.b	#DEMOS,d2
	beq.s	FIN_CLAVIER
	addq.b	#1,d2
	move.w	#160,direc	* Direction Bas (+160)
	move.w	#-24*160,posdemo	* Position haut du logo

FIN_CLAVIER:

	move.b	d2,nbdemo
	move.b	d0,touche

	rts

*********************************************************************************

		* ROUTINES D'INITIALISATION *

*********************************************************************************

SPRITER:
	lea	tete,a0
	lea	tdec,a1
	bsr.s	SCOPY
	lea	tdec,a0
	lea	32*8*3(a0),a1
	bsr.s	DECAL
	lea	tdec,a0
	lea	tmask,a1
	bsr	MASKER

	lea	corps,a0
	lea	cdec,a1
	bsr.s	SCOPY
	lea	cdec,a0
	lea	32*8*3(a0),a1
	bsr.s	DECAL
	lea	cdec,a0
	lea	cmask,a1
	bsr	MASKER

	lea	queue,a0
	lea	q1dec,a1
	bsr.s	SCOPY
	lea	q1dec,a0
	lea	32*8*3(a0),a1
	bsr.s	DECAL
	lea	q1dec,a0
	lea	q1mask,a1
	bsr	MASKER

	rts

SCOPY:
	moveq	#32-1,d7		* Recopie du sprite
GLOUBI:
	movem.l	(a0)+,d0-d5
	movem.l	d0-d5,(a1)
	lea	6*4(a1),a1
	dbra	d7,GLOUBI
	rts

DECAL:
	moveq	#15-1,d0		Nbre de d‚calages
DECLOOP1:
	moveq	#32-1,d1		32 pix. de haut
DECLOOP2:

Q	set	0
	rept	4		* Nb of bitplans

	move.w	Q(a0),d2		* 0-15 pix.
	roxr.w	#1,d2
	move.w	d2,Q(a1)

	move.w	Q+8(a0),d2	* 16-31 pix.
	roxr.w	#1,d2
	move.w	d2,Q+8(a1)

	move.w	Q+16(a0),d2	* 32-47 pix.
	roxr.w	#1,d2
	move.w	d2,Q+16(a1)

Q	set	Q+2
	endr

	lea	3*8(a0),a0
	lea	3*8(a1),a1

	dbra	d1,DECLOOP2	* Hauteur
	dbra	d0,DECLOOP1	* D‚calage

	rts

MASKER:
	move.w	#32*3*16-1,d7	* Charge le nombre de lignes
MASKLOOP:
	movem.w	(a0)+,d0-d3	* Charge les 4 plans
	move.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	not.w	d4
	move.w	d4,(a1)+
	move.w	d4,(a1)+

	dbra.w	d7,MASKLOOP

	rts


*********************************************************************************
*********************************************************************************
*********************************************************************************

	SECTION	DATA

phrase:	incbin	MENU.TXT
	dc.b	0
	even

player:	incbin	replay.bin
music:	incbin	chamber5.mus
	even

palette_pic
	DC.W	0,$175,$164,$153
	DC.W	$142,$131,$20,$765
	DC.W	$654,$543,$432,$321
	DC.W	$210,$300,$10,$500

pic:	incbin	MENU.PIC

names:	incbin	NAMES.DAT
fname:
npal:	incbin	NAMES.PAL

tete:	incbin	TETE.SPR
corps:	incbin	CORPS.SPR
queue:	incbin	QUEUE.SPR

font:	incbin	FONT_32.FNT
fpal:	incbin	FONT_32.PAL

sprxy:	incbin	S_MOVE.TBL
fspr:

	SECTION	BSS

* Variables *

touche:	ds.b	1

nbdemo:	ds.b	1		* Numero de la d‚mo
	even
L466	DS.L	1
posdemo:	ds.w	1		* Position dans le "rouleau"
direc:	ds.w	1		* Direction (-160 ou +160)


trpt:	ds.b	1		* Compteur de tranches

txt:	ds.l	1
cptr:	ds.b	1
space:	ds.b	1
	even

oldtranche:	ds.l	1


s0:	ds.l	1	* Glissements sprites
s1:	ds.l	1
s2:	ds.l	1
s3:	ds.l	1

cpt:	ds.l	1

* Memoire & adresses *

	ds.b	256
mem:	ds.b	64000		* Ecrans logiques
ecran1:	ds.l	1
ecran2:	ds.l	1

tdec:	ds.b	32*8*3*16		* Tete (4 bitplans)
tmask:	ds.b	32*4*3*16		* Mask (2 bitplans)

cdec:	ds.b	32*8*3*16		* Corps (4 bitplans)
cmask:	ds.b	32*4*3*16		* Mask (2 bitplans)

q1dec:	ds.b	32*8*3*16		* Queue 1 (4 bitplans)
q1mask:	ds.b	32*4*3*16		* Mask (2 bitplans)
