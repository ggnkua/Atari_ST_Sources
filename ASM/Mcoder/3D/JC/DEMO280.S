;
; … faire :
;	- rentrer nouveaux objets
;	- mettre routine d'affichage des points avec clipping en X
;	- affichage 2 plans
;	- startdraw rajouter des octets aprŠs le bra
;		pour avoir une puissance de 2 !!!
;	- objets transparents (entrer facettes internes)
;	- routine DRAWLINE en code g‚n‚r‚
;	- optimiser effacement ‚cran (lea -d(a6),a6)
;	- gestion multi‚crans … d‚bugger avec rasters en bas
;	- liste des bugs :
;		- droites horizontales merdent parfois (??)
;		- cachage des facettes pas clean
;
	opt	o+
	OUTPUT	DEMO.PRG
LONGFONTE = 472+8
DEBUG = 0			;0=debugger
NBSCR = 8
nbpts = 25
nblig = 200-8
PROF = 1
;
; manquent :
;	- on peut enlever les divisions en calculant les points de la maniŠre
;	  suivante :
;			add.l	PENTE,x
;			swap	x
;			move	x,(a6)+
;			swap	x
;	avec PENTE lu dans une table
;
; POINT DE ROTATION : (0,0,100)
;
	offset	$800
pointsgauches:ds.w	nblig
pointsdroits:ds.w	nblig

	DS.W	10
MUL160	DS.W	nblig
	DS.W	10
curobj:	ds.w	1
sync:	ds.w	1
NEW:	DS.W	9
PUSHCLS:DS.L	40
finpush:
;
repeat:	ds.w	1
latchkey:ds.b	1
cheat:	ds.b	1
	even
ptwr:	ds.l	1
ptrd:	ds.l	1
nbimages:ds.w	1
lastecran:ds.l	1
ptr_aff:ds.l	1
DIST:	DS.W	1
CURTEXT:DS.L	1
;
; structure :
;	0.L=adresse ‚cran
;	4.W=xmin
;	6.W=xmax
;	8.W=ymin
;	10.W=ymax
;
	rsreset
rsecran	rs.l	1
rsxmin	rs.w	1
rsxmax	rs.w	1
rsymin	rs.w	1
rsymax	rs.w	1
rspal	rs.l	1
rslong	equ	(__RS+1)&-2
ptrscr:	ds.b	rslong*NBSCR
finscr:
;
; variables pour scroller
;
SHIFT1:	DS.W	1
L5E9A:	DS.W	1
BUFSCR:	DS.L	1
L5EA6:	DS.W	1
LETTRE1:DS.L	1
LETTRE2:DS.L	1
PTRTXT:	DS.L	1
ROTATEX	DS.B	1	;vitesse de rotation
ROTATEY	DS.B	1
ROTATEZ	DS.B	1
;
; ANGLES DE ROTATION, ETC...
;
ROTX	DS.B	1
ROTY	DS.B	1
ROTZ	DS.B	1
	EVEN

segments
	ds.b	nbpts*4

	section	text

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr

	lea	$80000,sp
	movem.l	trans(pc),d0-d7
	movem.l	d0-d7,-(sp)
	lea	moveup(pc),a0
	lea	CODE,a1
	move	#65536/4-1,d0
	jmp	(sp)
trans:	move.l	(a0)+,(a1)+
	move	a1,$ffff8240.w
	dbra	d0,trans
	jmp	CODE

moveup
	org	$8000
CODE
	move	#$2700,sr

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	ifeq	DEBUG
	jsr	debugger
	endc

	lea	pile,sp		;super stack

	move	#enddraw2-startdraw2,d0
	cmp	#enddraw-startdraw,d0
	beq.s	.okdr
	illegal
.okdr
	moveq	#NBSCR-1,d0
	move.l	#$80000,a0
	lea	ptrscr\w,a1
.genit
	lea	-32000(a0),a0
	move.l	a0,(a1)+
	move	#160,(a1)+
	move	#160,(a1)+
	move	#nblig/2,(a1)+
	move	#nblig/2,(a1)+
	move.l	#bugpal,(a1)+
	dbra	d0,.genit

	cmp.l	#finscr,a1
	beq.s	.good
	illegal
.good
	cmp.l	#fincode,a0
	bhs.s	.nobug
	illegal
.nobug
	move.l	#ptrscr,ptwr\w
	move.l	#ptrscr,ptrd\w
	move.l	a0,lastecran\w
	clr	nbimages\w

	lea	$80000,a1
	moveq	#0,d1
.cls
	move.l	d1,(a0)+
	cmp.l	a1,a0
	blo.s	.cls

	lea	(MUL160-20).W,A0
	move	#nblig+20-1,d0
.fil160	move	#-1,(a0)+
	dbra	d0,.fil160

	moveq	#0,d0
	lea	MUL160\W,A0
.mul160	move	d0,(a0)+
	add	#160,d0
	cmp	#nblig*160,d0
	blo.s	.mul160

	BSR	INITSCROLL
	bsr	gendraw
	BSR	INITCALC
	bsr	genere_cls

	bsr	INITMUSIC
	move.l	#vbl,$70.w
	move	#$2300,sr
	clr	sync\W
.vbl1	tst	sync\W
	beq.s	.vbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#prg_sur_vbl,$70.w
	clr	curobj\w
	clr.b	latchkey\w
	clr.b	cheat\w
CLRALL	MACRO
	CLR.B	ROTX.W
	CLR.B	ROTY.W
	CLR.B	ROTZ.W
	ENDM
	move.l	#divs0,$14.w
	move.b	#2,ROTATEX\W
	move.b	#1,ROTATEY.W
	move.b	#3,ROTATEZ.W
	MOVE	#$60,DIST\W
	CLRALL

demo
	clr	d0
	move.b	$fffffc02.w,d0

	ifeq	DEBUG
	cmp.b	#$1d,latchkey\w
	bne.s	.paquit
	cmp.b	#$2e,d0
	bne.s	.paquit
	clr.l	$426.w
	move.l	4.w,a0
	jmp	(a0)
.paquit
	endc

	cmp.b	#$24,latchkey\w
	bne.s	.nocheat
	cmp.b	#$2e,d0
	bne.s	.nocheat
	st	cheat\w
	lea	TEXTE2,A0
	MOVE.L	A0,CURTEXT\W
	MOVE.L	A0,PTRTXT\W
.nocheat
	cmp.b	latchkey\w,d0
	bne.s	.diffkey
	subq	#1,repeat.w
	bne	.nokey
	move	#4,repeat.w
	bra.s	.samekey
.diffkey
	move	#10,repeat.w
.samekey
	move.b	d0,latchkey\w
	bmi	.nokey

	tst.b	cheat\w
	beq	.nokey

	cmp.b	#$e,d0
	bne.s	.0
	move.b	#2,ROTATEX\W
	move.b	#1,ROTATEY.W
	move.b	#3,ROTATEZ.W
	MOVE	#$60,DIST\W
	CLRALL
.0
	cmp.b	#$50,d0		;flŠche bas
	bne.s	.1
	subq.b	#1,ROTATEX.W
	CLRALL
.1
	cmp.b	#$48,d0		;flŠche haut
	bne.s	.2
	addq.b	#1,ROTATEX.W
	CLRALL
.2
	cmp.b	#$47,d0		;INSERT
	bne.s	.3
	subq.b	#1,ROTATEY.W
	CLRALL
.3
	cmp.b	#$52,d0		;CLR-HOME
	bne.s	.4
	addq.b	#1,ROTATEY.W
	CLRALL
.4
	cmp.b	#$4b,d0		;flŠche gauche
	bne.s	.5
	subq.b	#1,ROTATEZ.W
	CLRALL
.5
	cmp.b	#$4d,d0		;flŠche droite
	bne.s	.6
	addq.b	#1,ROTATEZ.W
	CLRALL
.6
	cmp.b	#$62,d0		;HELP
	bne.s	.7
	CMP	#PROF,DIST\W
	BLS.S	.7
	subq	#PROF,DIST\W
.7
	cmp.b	#$61,d0		;UNDO
	bne.s	.8
	ADDQ	#PROF,DIST\W
.8
.nokey
	subq.b	#2,d0
	cmp	#8,d0
	bhs.s	.nochg
	add	d0,d0
	add	d0,d0
	move	d0,curobj\w
	CLRALL
.nochg
	move.l	ptwr\w,a0
	move.l	rsecran(a0),a1
	tst	nbimages\w
	beq.s	.ok
	move	#$2700,sr
	cmp.l	lastecran\w,a1
	bne.s	.ok2
	illegal
.ok2
	moveq	#0,d0
	move.b	$ffff8201.w,d0
	swap	d0
	move.b	$ffff8203.w,d0
	asl	#8,d0
	cmp.l	d0,a1
	bne.s	.ok3
	illegal
.ok3
	moveq	#0,d0
	move.b	$ffff8205.w,d0
	swap	d0
	move.b	$ffff8207.w,d0
	asl	#8,d0
	move.b	$ffff8209.w,d0
	sub.l	a1,d0
	cmp.l	#32000,d0
	bhs.s	.ok
	illegal
.ok
	move	#$2300,sr
	move.l	a1,usp

	bsr	cls

	move	curobj\w,d0
	lea	all_objects(pc),a0
	move.l	(a0,d0.w),a0

	lea	segments\w,a1
	BSR	CALCOBJ

	move.l	rsecran(a0),a1
	move.l	a1,usp

	MOVE	curobj\w,D0		;NUMERO DE L'OBJET*4
	lea	all_palettes(pc),a4
	move.l	(a4,d0.w),rspal(a0)

	lea	drawline+$16(pc),a4		;optimisation !!!
	lea	polycalc(pc),a0
	move	#320,a5			;optimisation
	JSR	(a0,D0.W)

	tst.b	cheat\w
	beq.s	.nodisp
	MOVE.L	USP,A6
	LEA	8*160(A6),A6
	MOVE.B	ROTATEX.W,D7
	BSR	print
	MOVE.L	USP,A6
	LEA	16*160(A6),A6
	MOVE.B	ROTATEY.W,D7
	BSR	print
	MOVE.L	USP,A6
	LEA	24*160(A6),A6
	MOVE.B	ROTATEZ.W,D7
	BSR	print
	MOVE.L	USP,A6
	LEA	32*160(A6),A6
	MOVE.B	DIST.W,D7
	BSR	print
	MOVE.B	DIST+1.W,D7
	BSR	print

	ifeq	1
	MOVE.L	USP,A6
	LEA	40*160(A6),A6
	MOVE.B	ROTX.W,D7
	BSR	print
	MOVE.L	USP,A6
	LEA	48*160(A6),A6
	MOVE.B	ROTY.W,D7
	BSR	print
	MOVE.L	USP,A6
	LEA	56*160(A6),A6
	MOVE.B	ROTZ.W,D7
	BSR	print
	endc
.nodisp
	move.l	ptwr\w,a0
	lea	rslong(a0),a0
	cmp.l	#finscr,a0
	blo.s	.lowup
	lea	ptrscr\w,a0
.lowup
	move.l	a0,ptwr\w
	addq	#1,nbimages\w
;CPU	MACRO
;	tst.b	cheat.w
;	beq.s	.\@
;	CMP.B	#$F,$FFFFFC02.W
;	BNE.S	.\@
;	MOVE	#\1,$FFFF8240.W
;.\@
;	ENDM
;	CPU	$555

	tst.b	cheat.w
	beq.s	.loop
	cmp.b	#1,$fffffc02.w
	bne.s	.loop
	move	#$077,$ffff8240.w
.loop	cmp	#NBSCR-3,nbimages\w
	bhs.s	.loop
	bra	demo

all_objects:
	dc.l coords_spider,coords_cube,coords_tetra,coords_grille
	dc.l coords_spider,coords_cube,coords_tetra,coords_grille
	dc.l coords_spider,coords_cube,coords_tetra,coords_grille
all_palettes:
	dc.l palette1,palette2,palette3,palette4
	dc.l palette5,palette6,palette7,palette8

divs0:
	addq	#PROF,DIST.W
	addq	#1,d4
	addq	#1,d5
	rte

prg_sur_vbl:
	movem.l	d0-d7/a0-a6,-(sp)
	BSR	PLAYMUSIC
	MOVE.L	lastecran\w,a2
	bsr	SCROLLER

	tst.b	cheat\w
	beq.s	.nodisp2
	move.l	lastecran\w,a6		;adresse ‚cran
	move	nbimages\w,d7
	bsr.s	print
.nodisp2
	tst	nbimages\w
	beq.s	novbl
	subq	#1,nbimages\w

	move.l	ptrd\w,a0
	move.l	rsecran(a0),d0
	move.l	d0,lastecran\w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	rspal(a0),a1
	cmp.b	#$3b,$fffffc02.w
	bne.s	.notf1
	lea	bugpal(pc),a1
.notf1
	movem.l	(a1),d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	rslong(a0),a0
	cmp.l	#finscr,a0
	blo.s	1$
	lea	ptrscr\w,a0
1$	move.l	a0,ptrd\w

	movem.l	(sp)+,d0-d7/a0-a6
	rte
novbl:
	tst.b	cheat\w
	beq.s	.nocpu
	cmp.b	#$f,$fffffc02.w
	bne.s	.nocpu
	add	#$333,$ffff8240.w	;indique quand passage en 2
.nocpu
	movem.l	(sp)+,d0-d7/a0-a6
	rte
print:
	bsr.w	digit
digit:
	rol.b	#4,d7
	moveq	#$f,d0
	and	d7,d0
	asl	#3,d0
	lea	fonte,a0
	add	d0,a0
x	set	0
	rept	8
	move.b	(a0)+,x(a6)
x	set	x+160
	endr
	addq	#1,a6
	move	a6,d0
	lsr	#1,d0
	bcs.s	.pair
	addq	#6,a6
.pair	rts

TEST	MACRO

	OPT	OW-
	ifeq	\1-\2+1
	MOVEM	\1*4+segments.w,d0/d1/d2/d3	;A/B
	elseif
	MOVEM	\1*4+segments.w,d0/d1		;A
	MOVEM	\2*4+segments.w,d2/d3		;B
	endc
	MOVEM	\3*4+segments.w,d4/d5		;C
	OPT	OW+

	IFEQ	1
	SUB	d0,d2
	SUB	d1,d3
	SUB	d0,d4
	SUB	d1,d5
	MULS	d2,d5
	MULS	d3,d4
	SUB.L	d5,d4
	bmi	\5
	ELSEIF
	sub	d2,d4		;d4=xc-xb
	sub	d0,d2		;d2=xb-xa
	sub	d3,d5		;d5=yc-yb
	sub	d3,d1		;d1=ya-yb
	muls	d2,d5
	muls	d1,d4
	add.l	d4,d5
	bgt.s	\5		;bpl ?
	ENDC

	ENDM

DRAW	MACRO
	OPT	OW-
	ifeq	\1-\2+1
	movem	\1*4+segments.w,d0/d1/d2/d3
	elseif
	movem	\1*4+segments.w,d0/d1
	movem	\2*4+segments.w,d2/d3
	endc
	OPT	OW+
	LEA	\@(PC),A1
	jmp	(a4)
\@
	ENDM
INITDRAW:MACRO
;	CPU	$777
	moveq	#-1,d6		;Y minimum
	moveq	#0,d7		;Y maximum
	ENDM
;
; d6=Ymin
; d7=Ymax
;
AFFPOLY:MACRO
;	CPU	$077
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	\@		;clipp‚ ???
	lea	(MUL160).W,A6
	move.l	usp,a3
	add	(a6,d6.w),a3
	IFNE	\1
	ADDQ	#2*\1,A3
	ENDC
	lea	(pointsgauches).W,a6
	add	d6,a6			;ptr d‚but
	lea	masques(pc),a1
	lea	pointsdroits-pointsgauches(a6),a2
	moveq	#-1,d5
	mulu	#enddraw2-startdraw2,d7
	move.l	ptr_aff.w,a0
	sub.l	d7,a0
	jsr	(a0)
\@
	ENDM

polycalc
	bra.w	spider
	bra.w	cube
	bra.w	tetraedre
	bra.w	grille
	bra.w	spider
	bra.w	cube
	bra.w	tetraedre
	bra.w	grille
	bra.w	spider
	bra.w	cube
	bra.w	tetraedre
	bra.w	grille
;
TAILLE = 8		;HAUTEUR DU SCROLLER
STEP = 2		;PAS DU SCROLLER
;
INITSCROLL:
;
; PREDECALE LA FONTE
;
	MOVEQ	#32,D1
	LEA	PREDEC,A1
NXTDEC:
	LEA	FONTE,A0
NXTCAR:
	MOVEQ	#8-1,D7
DECAL:
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SWAP	D0
	ROR.L	D1,D0
	MOVE.L	D0,(A1)+
	DBRA	D7,DECAL

	CMP.L	#FINFONTE,A0
	BLO.S	NXTCAR

	SUBQ	#STEP,D1
	BHI.S	NXTDEC

	CMP.L	#FINPREDEC,A1
	BLS.S	L1
	ILLEGAL
L1:
	LEA	TEXTE1,A0
	MOVE.L	A0,CURTEXT\W
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w

	CLR	SHIFT1.w
	CLR	L5E9A.w
	MOVE.L	#L6ECC,BUFSCR.w
	CLR	L5EA6.w

	LEA	L6ECC,A0
	MOVEQ	#0,D0
	MOVE	#(16/STEP)*TAILLE*80/4-1,D1
L84C8:	MOVE.L	D0,(A0)+
	DBF	D1,L84C8
	RTS
;
; A2=ADRESSE ECRAN
;
SCROLLER:
;
; SCROLLEUR 1 PLAN !!!!
;
	MOVE	SHIFT1.w,D0
	ADD	#(LONGFONTE)*16,D0
	MOVE.L	LETTRE1.w,A0		;PTR FONTE PREMIERE LETTRE
	ADD	D0,A0
	MOVE.L	LETTRE2.w,A3		;PTR FONTE SECONDE LETTRE
	ADD	SHIFT1.w,A3

	MOVE.L	BUFSCR.w,A1
	ADD	L5E9A.w,A1

Z	SET	32

Y	SET	(200-TAILLE)*160
X	SET	0
	REPT	TAILLE*152/8

	MOVE	(A1)+,X+Y(A2)
X	SET	X+8

	IFEQ	X-X/160*160-152

	MOVE.L	(A0)+,D0
	OR.L	(A3)+,D0
	OR	(A1),D0
	MOVE	D0,X+Y(A2)
	SWAP	D0
	MOVE.L	D0,-40(A1)
	MOVE.L	D0,(A1)
X	SET	X+8

	IFNE	X-TAILLE*160
	LEA	40-2+4(A1),A1
	ENDC

	ENDC
	ENDR

	ADD.L	#TAILLE*80,BUFSCR.w
	ADD	#(LONGFONTE)*4,SHIFT1.w
	CMP	#(LONGFONTE)*4*(16/STEP),SHIFT1.w	;SCROLLER 4 EN 4
	BLO.S	L5102
	CLR	SHIFT1.w
	MOVE.L	#L6ECC,BUFSCR.w

	ADDQ	#2,L5E9A.w
	CMP	#40,L5E9A.w
	BNE.S	L50BC
	CLR	L5E9A.w
L50BC:
	MOVE.L	PTRTXT.w,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F8
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F8:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE1.w
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	L50F82
	MOVE.L	CURTEXT\W,A0
	MOVE.B	(A0)+,D0
L50F82:
	ASL	#5,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,LETTRE2.w
	MOVE.L	A0,PTRTXT.w
L5102:
	RTS

spider:
	TEST	2,0,3,-1,n0
	INITDRAW
	DRAW	2,0
	DRAW	0,3
	DRAW	3,2
	AFFPOLY	0
n0:
	TEST	0,1,4,3,n1
	INITDRAW
	DRAW	0,1
	DRAW	1,4
	DRAW	4,3
	DRAW	3,0
	AFFPOLY	1
n1:
	TEST	1,5,4,-1,n2
	INITDRAW
	DRAW	1,5
	DRAW	5,4
	DRAW	4,1
	AFFPOLY	2
n2:
	TEST	2,3,7,6,n3
	INITDRAW
	DRAW	2,3
	DRAW	3,7
	DRAW	7,6
	DRAW	6,2
	AFFPOLY	3
n3:
	TEST	3,4,8,7,n4
	INITDRAW
	DRAW	3,4
	DRAW	4,8
	DRAW	8,7
	DRAW	7,3
	AFFPOLY	0
n4:
	TEST	4,5,9,8,n5
	INITDRAW
	DRAW	4,5
	DRAW	5,9
	DRAW	9,8
	DRAW	8,4
	AFFPOLY	1
n5:
	TEST	6,7,10,-1,n6
	INITDRAW
	DRAW	6,7
	DRAW	7,10
	DRAW	10,6
	AFFPOLY	2
n6:
	TEST	7,8,11,10,n7
	INITDRAW
	DRAW	7,8
	DRAW	8,11
	DRAW	11,10
	DRAW	10,7
	AFFPOLY	3
n7:
	TEST	8,9,11,-1,n8
	INITDRAW
	DRAW	8,9
	DRAW	9,11
	DRAW	11,8
	AFFPOLY	0
n8:
	TEST	12,0,2,14,n9
	INITDRAW
	DRAW	12,0
	DRAW	0,2
	DRAW	2,14
	DRAW	14,12
	AFFPOLY	1
n9:
	TEST	12,13,1,0,n10
	INITDRAW
	DRAW	12,13
	DRAW	13,1
	DRAW	1,0
	DRAW	0,12
	AFFPOLY	2
n10:
	TEST	5,1,13,15,n11
	INITDRAW
	DRAW	5,1
	DRAW	1,13
	DRAW	13,15
	DRAW	15,5
	AFFPOLY	3
n11:
	TEST	9,5,15,17,n12
	INITDRAW
	DRAW	9,5
	DRAW	5,15
	DRAW	15,17
	DRAW	17,9
	AFFPOLY	0
n12:
	TEST	11,9,17,19,n13
	INITDRAW
	DRAW	11,9
	DRAW	9,17
	DRAW	17,19
	DRAW	19,11
	AFFPOLY	1
n13:
	TEST	10,11,19,18,n14
	INITDRAW
	DRAW	10,11
	DRAW	11,19
	DRAW	19,18
	DRAW	18,10
	AFFPOLY	2
n14:
	TEST	6,10,18,16,n15
	INITDRAW
	DRAW	6,10
	DRAW	10,18
	DRAW	18,16
	DRAW	16,6
	AFFPOLY	3
n15:
	TEST	2,6,16,14,n16
	INITDRAW
	DRAW	2,6
	DRAW	6,16
	DRAW	16,14
	DRAW	14,2
	AFFPOLY	0
n16:
	TEST	20,21,13,12,n17
	INITDRAW
	DRAW	20,21
	DRAW	21,13
	DRAW	13,12
	DRAW	12,20
	AFFPOLY	1
n17:
	TEST	12,14,20,-1,n18
	INITDRAW
	DRAW	12,14
	DRAW	14,20
	DRAW	20,12
	AFFPOLY	2
n18:
	TEST	20,14,16,-1,n19
	INITDRAW
	DRAW	20,14
	DRAW	14,16
	DRAW	16,20
	AFFPOLY	3
n19:
	TEST	20,16,18,-1,n20
	INITDRAW
	DRAW	20,16
	DRAW	16,18
	DRAW	18,20
	AFFPOLY	0
n20:
	TEST	18,19,21,20,n21
	INITDRAW
	DRAW	18,19
	DRAW	19,21
	DRAW	21,20
	DRAW	20,18
	AFFPOLY	1
n21:
	TEST	21,19,17,-1,n22
	INITDRAW
	DRAW	21,19
	DRAW	19,17
	DRAW	17,21
	AFFPOLY	2
n22:
	TEST	15,21,17,-1,n23
	INITDRAW
	DRAW	15,21
	DRAW	21,17
	DRAW	17,15
	AFFPOLY	3
n23:
	TEST	13,21,15,-1,n24
	INITDRAW
	DRAW	13,21
	DRAW	21,15
	DRAW	15,13
	AFFPOLY	0
n24:
	RTS
;
; affichage d'un cube
;
cube:
	TEST	0,1,2,3,not0
	INITDRAW
	DRAW	0,1
	DRAW	1,2
	DRAW	2,3
	DRAW	3,0
	AFFPOLY	0
	bra	not1
not0
	TEST	7,6,5,4,not1
	INITDRAW
	DRAW	7,6
	DRAW	6,5
	DRAW	5,4
	DRAW	4,7
	AFFPOLY	0
not1
	TEST	0,3,7,4,not2
	INITDRAW
	DRAW	0,3
	DRAW	3,7
	DRAW	7,4
	DRAW	4,0
	AFFPOLY	1
	bra	not3
not2
	TEST	2,1,5,6,not3
	INITDRAW
	DRAW	2,1
	DRAW	1,5
	DRAW	5,6
	DRAW	6,2
	AFFPOLY	1
not3
	TEST	3,2,6,7,not4
	INITDRAW
	DRAW	3,2
	DRAW	2,6
	DRAW	6,7
	DRAW	7,3
	AFFPOLY	2
	bra	not5
not4
	TEST	0,4,5,1,not5
	INITDRAW
	DRAW	0,4
	DRAW	4,5
	DRAW	5,1
	DRAW	1,0
	AFFPOLY	2
not5
	rts
;
; affichage d'un t‚traŠdre
;
tetraedre:
	TEST	0,2,1,-1,tet1
	INITDRAW
	DRAW	0,2
	DRAW	2,1
	DRAW	1,0
	AFFPOLY	0
tet1
	TEST	0,3,2,-1,tet2
	INITDRAW
	DRAW	0,3
	DRAW	3,2
	DRAW	2,0
	AFFPOLY	1
tet2
	TEST	0,1,3,-1,tet3
	INITDRAW
	DRAW	0,1
	DRAW	1,3
	DRAW	3,0
	AFFPOLY	2
tet3
	TEST	1,2,3,-1,tet4
	INITDRAW
	DRAW	1,2
	DRAW	2,3
	DRAW	3,1
	AFFPOLY	3
tet4
	rts
grille:
	INITDRAW
	TEST	0,5,6,1,laba0
	DRAW	0,5
	DRAW	5,6
	DRAW	6,1
	DRAW	1,0
	bra.s	lab0
laba0:
	DRAW	0,1
	DRAW	1,6
	DRAW	6,5
	DRAW	5,0
lab0:
	AFFPOLY	0
	INITDRAW
	TEST	1,6,7,2,laba1
	DRAW	1,6
	DRAW	6,7
	DRAW	7,2
	DRAW	2,1
	bra.s	lab1
laba1:
	DRAW	1,2
	DRAW	2,7
	DRAW	7,6
	DRAW	6,1
lab1:
	AFFPOLY	1
	INITDRAW
	TEST	2,7,8,3,laba2
	DRAW	2,7
	DRAW	7,8
	DRAW	8,3
	DRAW	3,2
	bra.s	lab2
laba2:
	DRAW	2,3
	DRAW	3,8
	DRAW	8,7
	DRAW	7,2
lab2:
	AFFPOLY	2
	INITDRAW
	TEST	3,8,9,4,laba3
	DRAW	3,8
	DRAW	8,9
	DRAW	9,4
	DRAW	4,3
	bra.s	lab3
laba3:
	DRAW	3,4
	DRAW	4,9
	DRAW	9,8
	DRAW	8,3
lab3:
	AFFPOLY	3
	INITDRAW
	TEST	5,10,11,6,laba4
	DRAW	5,10
	DRAW	10,11
	DRAW	11,6
	DRAW	6,5
	bra.s	lab4
laba4:
	DRAW	5,6
	DRAW	6,11
	DRAW	11,10
	DRAW	10,5
lab4:
	AFFPOLY	1
	INITDRAW
	TEST	6,11,12,7,laba5
	DRAW	6,11
	DRAW	11,12
	DRAW	12,7
	DRAW	7,6
	bra.s	lab5
laba5:
	DRAW	6,7
	DRAW	7,12
	DRAW	12,11
	DRAW	11,6
lab5:
	AFFPOLY	2
	INITDRAW
	TEST	7,12,13,8,laba6
	DRAW	7,12
	DRAW	12,13
	DRAW	13,8
	DRAW	8,7
	bra.s	lab6
laba6:
	DRAW	7,8
	DRAW	8,13
	DRAW	13,12
	DRAW	12,7
lab6:
	AFFPOLY	3
	INITDRAW
	TEST	8,13,14,9,laba7
	DRAW	8,13
	DRAW	13,14
	DRAW	14,9
	DRAW	9,8
	bra.s	lab7
laba7:
	DRAW	8,9
	DRAW	9,14
	DRAW	14,13
	DRAW	13,8
lab7:
	AFFPOLY	0
	INITDRAW
	TEST	10,15,16,11,laba8
	DRAW	10,15
	DRAW	15,16
	DRAW	16,11
	DRAW	11,10
	bra.s	lab8
laba8:
	DRAW	10,11
	DRAW	11,16
	DRAW	16,15
	DRAW	15,10
lab8:
	AFFPOLY	2
	INITDRAW
	TEST	11,16,17,12,laba9
	DRAW	11,16
	DRAW	16,17
	DRAW	17,12
	DRAW	12,11
	bra.s	lab9
laba9:
	DRAW	11,12
	DRAW	12,17
	DRAW	17,16
	DRAW	16,11
lab9:
	AFFPOLY	3
	INITDRAW
	TEST	12,17,18,13,laba10
	DRAW	12,17
	DRAW	17,18
	DRAW	18,13
	DRAW	13,12
	bra.s	lab10
laba10:
	DRAW	12,13
	DRAW	13,18
	DRAW	18,17
	DRAW	17,12
lab10:
	AFFPOLY	0
	INITDRAW
	TEST	13,18,19,14,laba11
	DRAW	13,18
	DRAW	18,19
	DRAW	19,14
	DRAW	14,13
	bra.s	lab11
laba11:
	DRAW	13,14
	DRAW	14,19
	DRAW	19,18
	DRAW	18,13
lab11:
	AFFPOLY	1
	INITDRAW
	TEST	15,20,21,16,laba12
	DRAW	15,20
	DRAW	20,21
	DRAW	21,16
	DRAW	16,15
	bra.s	lab12
laba12:
	DRAW	15,16
	DRAW	16,21
	DRAW	21,20
	DRAW	20,15
lab12:
	AFFPOLY	3
	INITDRAW
	TEST	16,21,22,17,laba13
	DRAW	16,21
	DRAW	21,22
	DRAW	22,17
	DRAW	17,16
	bra.s	lab13
laba13:
	DRAW	16,17
	DRAW	17,22
	DRAW	22,21
	DRAW	21,16
lab13:
	AFFPOLY	0
	INITDRAW
	TEST	17,22,23,18,laba14
	DRAW	17,22
	DRAW	22,23
	DRAW	23,18
	DRAW	18,17
	bra.s	lab14
laba14:
	DRAW	17,18
	DRAW	18,23
	DRAW	23,22
	DRAW	22,17
lab14:
	AFFPOLY	1
	INITDRAW
	TEST	18,23,24,19,laba15
	DRAW	18,23
	DRAW	23,24
	DRAW	24,19
	DRAW	19,18
	bra.s	lab15
laba15:
	DRAW	18,19
	DRAW	19,24
	DRAW	24,23
	DRAW	23,18
lab15:
	AFFPOLY	2
	rts
;
vbl:	addq	#1,sync\W
	rte
retr:	rtr

NEWPAL	MACRO
	DC.W	$0,\1,\2,\2,\3,\3,\3,\3
	DCB.W	8,\4
	ENDM

palette1:
	NEWPAL	$756,$645,$534,$423
palette2:
	NEWPAL	$456,$345,$234,$123
palette3:
	NEWPAL	$565,$454,$343,$232
palette4:
	NEWPAL	$656,$545,$434,$323

palette5:
	NEWPAL	$067,$057,$047,$037
palette6:
	NEWPAL	$766,$755,$744,$733
palette7:
	NEWPAL	$762,$752,$742,$732
palette8:
	NEWPAL	$666,$555,$444,$333
palette9:
	NEWPAL	$457,$346,$235,$124

;palette1:DC.W	$000
;	DC.W	$700		;0001
;	DC.W	$070		;0010
;	DC.W	$770		;0011
;	DC.W	$007		;0100
;	DC.W	$707		;0101
;	DC.W	$077		;0110
;	DC.W	$777		;0111
;
;	DCB.W	8,$555

bugpal:	DC.W	$000
	DC.W	$200		;0001
	DC.W	$020		;0010
	DC.W	$770		;0011
	DC.W	$002		;0100
	DC.W	$707		;0101
	DC.W	$077		;0110
	DC.W	$777		;0111

	dc.w	$222
	DCB.W	7,$555
;
gendraw:
	move	#nblig-1,d7
	lea	fast_draw,a6
1$
	lea	startdraw(pc),a0
	move	#(enddraw2-startdraw2)/2-1,d0
2$	move	(a0)+,(a6)+
	dbra	d0,2$
	dbra	d7,1$
	move	#$4e75,(a6)+		;rts
	cmp.l	#findraw,a6
	beq.s	.ok
	illegal
.ok
	move	#nblig-1,d7
	lea	fast_draw2,a6
11$
	lea	startdraw2(pc),a0
	move	#(enddraw2-startdraw2)/2-1,d0
12$	move	(a0)+,(a6)+
	dbra	d0,12$
	dbra	d7,11$
	move	#$4e75,(a6)+		;rts
	cmp.l	#findraw2,a6
	beq.s	.ok2
	illegal
.ok2
	rts
;
; registres utilis‚s :
;
;	a0/a1/a2/a3/a6
;	d0/d1/d2/d5/d6
;
startdraw
	move	(a2)+,d0
	move	(a6)+,d1
	moveq	#$f,d2
	and	d1,d2
	eor	d2,d1
	ADD	D2,D2
	move	masque1-masques(a1,d2.w),d6	;masque droit
	sub	d1,d0
	blt.s	.less0
	lsr	#1,d1
	ADD	D0,d0
	and	masque2-masques(a1,d0.w),d6
	or	d6,(a3,d1.w)
	bra	.cont
	ds.b	36-6		;ajustement d'octets
.less0
	move.l	a3,a0
	lsr	#1,d1
	add	d1,a0
	or	d6,(a0)
	moveq	#-$10,d2
	and	d0,d2
	eor	d2,d0
	asr	#1,d2
	add	d2,a0
	asr	#1,d2
	jmp	.last+4(pc,d2.w)
	move	d5,19*8(a0)
	move	d5,18*8(a0)
	move	d5,17*8(a0)
	move	d5,16*8(a0)
	move	d5,15*8(a0)
	move	d5,14*8(a0)
	move	d5,13*8(a0)
	move	d5,12*8(a0)
	move	d5,11*8(a0)
	move	d5,10*8(a0)
	move	d5,9*8(a0)
	move	d5,8*8(a0)
	move	d5,7*8(a0)
	move	d5,6*8(a0)
	move	d5,5*8(a0)
	move	d5,4*8(a0)
	move	d5,3*8(a0)
	move	d5,2*8(a0)
	move	d5,1*8(a0)
.last
	add	d0,d0
	move	masque2-masques(a1,d0.w),d6
	or	d6,(a0)
.cont
	lea	160(a3),a3
enddraw
startdraw2
	move	(a2)+,d0
	move	(a6)+,d1
	cmp	a5,d0
	bhs.s	.clip1
	cmp	a5,d1
	bhs.s	.clip2
.noclip
	moveq	#$f,d2
	and	d1,d2
	eor	d2,d1
	ADD	D2,D2
	move	masque1-masques(a1,d2.w),d6	;masque droit
	sub	d1,d0
	blt.s	.less0
	lsr	#1,d1
	ADD	D0,d0
	and	masque2-masques(a1,d0.w),d6
	or	d6,(a3,d1.w)
	bra	.cont
.clip1	sge	d0
	ext	d0
	and	#319,d0
	cmp	a5,d1
	blo.s	.noclip
.clip2
	sge	d1
	ext	d1
	and	#319,d1
	bra.s	.noclip
.less0
	move.l	a3,a0
	lsr	#1,d1
	add	d1,a0
	or	d6,(a0)
	moveq	#-$10,d2
	and	d0,d2
	eor	d2,d0
	asr	#1,d2
	add	d2,a0
	asr	#1,d2
	jmp	.last+4(pc,d2.w)
	move	d5,19*8(a0)
	move	d5,18*8(a0)
	move	d5,17*8(a0)
	move	d5,16*8(a0)
	move	d5,15*8(a0)
	move	d5,14*8(a0)
	move	d5,13*8(a0)
	move	d5,12*8(a0)
	move	d5,11*8(a0)
	move	d5,10*8(a0)
	move	d5,9*8(a0)
	move	d5,8*8(a0)
	move	d5,7*8(a0)
	move	d5,6*8(a0)
	move	d5,5*8(a0)
	move	d5,4*8(a0)
	move	d5,3*8(a0)
	move	d5,2*8(a0)
	move	d5,1*8(a0)
.last
	add	d0,d0
	move	masque2-masques(a1,d0.w),d6
	or	d6,(a0)
.cont
	lea	160(a3),a3
enddraw2




masques
masque2
	DC.W	$FFFF,$7FFF,$3FFF,$1FFF
	DC.W	$0FFF,$07FF,$03FF,$01FF
	DC.W	$00FF,$007F,$003F,$001F
	DC.W	$000F,$0007,$0003,$0001
	dc.w	0
	dc.w	0,0
masque1
	dc.w	0
	DC.W	$8000,$C000,$E000,$F000
	DC.W	$F800,$FC00,$FE00,$FF00
	DC.W	$FF80,$FFC0,$FFE0,$FFF0
	DC.W	$FFF8,$FFFC,$FFFE,$FFFF
;
; PORTION DE CODE EFFECTUANT LES PROJECTIONS DES POINTS
;

NXTANG	MACRO
	CLR	D0
	MOVE.B	\1.W,D0
	ADD.B	\2.W,D0
	MOVE.B	D0,\2.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(a2,D0.W),\3
	ENDM
;
; CALCUL OPTIMISE DES POINTS PROJETES
;
; CALCUL DE LA MATRICE CONSTANTE DE PROJECTION
;
; CHANGE L'ANGLE DE ROTATION ET CALCULE LES SINUS ET COSINUS ASSOCIES
;
; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; L14=ANGLE ROT X,L16=ANGLE ROT Y,L3C=ANGLE ROT Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS
;
SX	EQUR	D2
CX	EQUR	D3
SY	EQUR	D4
CY	EQUR	D5
SZ	EQUR	D6
CZ	EQUR	D7
;
; CHANGEMENT D'ANGLE DE ROTATION
;   (CONSTANTES POUR L'INSTANT)
;
CALCOBJ:
	MOVE	(A0)+,D0		;nb points
	mulu	#FINCALCUL-CALCUL,D0
	LEA	FINFASTCALC-2,A2
	SUB.L	D0,A2
	MOVE.L	A2,modif1+2

	LEA	SINCOS(PC),a2
	NXTANG	ROTATEX,ROTX,SX/CX	;X
	NXTANG	ROTATEY,ROTY,SY/CY	;Y
	NXTANG	ROTATEZ,ROTZ,SZ/CZ	;Z
;
; CALCULE LA MATRICE DE PROJECTION
;
	LEA	NEW\W,a2
	move.l	a2,usp

	MOVE	CY,D0
	MULS	CZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(a2)+

	MOVE	SY,(a2)+

	MOVE	CY,D0
	MULS	SZ,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(a2)+

	MOVE	SX,D1
	MULS	SZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(a2)+

	MOVE	CX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(a2)+	;$10

	MOVE	SX,D1
	MULS	CZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(a2)+	;$14

	MOVE	CX,D1
	MULS	SZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(a2)+	;$18

	MOVE	SX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(a2)+	;$1C

	MOVE	CX,D1
	MULS	CZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(a2)+	;$20

FAST	MACRO
	MOVE	\1,\2
	MULS	(A2)+,\2
	ENDM

ADDFAST	MACRO
	MOVE	\1,\3
	MULS	(A2)+,\3
	ADD.L	\3,\2
	ENDM
;
	move	#319,A3		;xmin
	SUB	A4,A4		;xmax
	move	#nblig-1,A5	;ymin
	SUB	A6,A6		;ymax

	MOVE	DIST\W,D4
modif1	JSR	FASTCALC

	move.l	#fast_draw+(nblig-1)*(enddraw2-startdraw2),ptr_aff.w
	MOVE	A3,D0
	BPL.S	.1
	SUB	A3,A3
	move.l	#fast_draw2+(nblig-1)*(enddraw2-startdraw2),ptr_aff.w
.1
	CMP	#320,A4
	BLO.S	.2
	MOVE	#319,A4
	move.l	#fast_draw2+(nblig-1)*(enddraw2-startdraw2),ptr_aff.w
.2
	MOVE	A5,D0
	BPL.S	.3
	SUB	A5,A5
.3
	CMP	#nblig,A6
	BLO.S	.4
	MOVE	#nblig-1,A6
.4
	move.l	ptwr\w,a0
	MOVEM	A3/A4/A5/A6,rsxmin(a0)
	rts

INITCALC
	LEA	FASTCALC,A6
	MOVEQ	#nbpts-1,D7
.LOOP
	LEA	CALCUL(PC),A0
	MOVE	#(FINCALCUL-CALCUL)/2-1,D0
.FILL	MOVE	(A0)+,(A6)+
	DBRA	D0,.FILL
	DBRA	D7,.LOOP
	MOVE	#$4E75,(A6)+
	CMP.L	#FINFASTCALC,A6
	BEQ.S	.OK
	ILLEGAL
.OK
	RTS
;
; a0=source
; a1=destination
; a2=ptr matrice
; a3=xmin
; a4=xmax
; a5=ymin
; a6=ymax
; USP=constante
; d0/d1/d2/d3/d5/d6/d7 scratch‚s
; d4=zoom
;
CALCUL:
	MOVE.L	usp,A2
	MOVEM	(A0)+,D1/D2/D3

	FAST	D1,D6		;X
	ADDFAST	D2,D6,D0
	ADDFAST	D3,D6,D0

	FAST	D1,D7		;Y
	ADDFAST	D2,D7,D0
	ADDFAST	D3,D7,D0

	FAST	D1,D5		;Z
	ADDFAST	D2,D5,D0
	ADDFAST	D3,D5,D0

	SWAP	D5
	SUB	d4,D5

	ifeq	1
	CMP	MIN,D5
	BGE.S	.NOTMIN
	MOVE	D5,MIN
.NOTMIN
	CMP	MAX,D5
	BLE.S	.NOTMAX
	MOVE	D5,MAX
.NOTMAX
	ENDC

	ASR.L	#8,D7
	ASR.L	#8,D6

	DIVS	D5,D6
	DIVS	D5,D7

	ADD	#360/2-16,D6
	ADD	#nblig/2,D7

	MOVE	D6,(A1)+
	MOVE	D7,(A1)+

	cmp	A3,d6		;xmin
	bge.s	.noxn
	move	d6,A3
.noxn
	cmp	A4,d6		;xmax
	ble.s	.noxx
	move	d6,A4
.noxx
	cmp	A5,d7		;ymin
	bge.s	.noyn
	move	d7,A5
.noyn
	cmp	A6,d7		;ymax
	ble.s	.noyx
	move	d7,A6
.noyx
FINCALCUL:

;MIN:	DC.W	$7FFF
;MAX:	DC.W	$8000

SINCOS		;TABLE DE SINUS/COSINUS
	dc.w	$0,$7FFF,$324,$7FF5,$647,$7FD7,$96A,$7FA6
	dc.w	$C8B,$7F61,$FAB,$7F08,$12C7,$7E9C,$15E1,$7E1C
	dc.w	$18F8,$7D89,$1C0B,$7CE2,$1F19,$7C29,$2223,$7B5C
	dc.w	$2527,$7A7C,$2826,$7989,$2B1E,$7883,$2E10,$776B
	dc.w	$30FB,$7640,$33DE,$7503,$36B9,$73B5,$398C,$7254
	dc.w	$3C56,$70E1,$3F16,$6F5E,$41CD,$6DC9,$447A,$6C23
	dc.w	$471C,$6A6C,$49B3,$68A5,$4C3F,$66CE,$4EBF,$64E7
	dc.w	$5133,$62F1,$539A,$60EB,$55F4,$5ED6,$5842,$5CB3
	dc.w	$5A81,$5A81,$5CB3,$5842,$5ED6,$55F4,$60EB,$539A
	dc.w	$62F1,$5133,$64E7,$4EBF,$66CE,$4C3F,$68A5,$49B3
	dc.w	$6A6C,$471C,$6C23,$447A,$6DC9,$41CD,$6F5E,$3F16
	dc.w	$70E1,$3C56,$7254,$398C,$73B5,$36B9,$7503,$33DE
	dc.w	$7640,$30FB,$776B,$2E10,$7883,$2B1E,$7989,$2826
	dc.w	$7A7C,$2527,$7B5C,$2223,$7C29,$1F19,$7CE2,$1C0B
	dc.w	$7D89,$18F8,$7E1C,$15E1,$7E9C,$12C7,$7F08,$FAB
	dc.w	$7F61,$C8B,$7FA6,$96A,$7FD7,$647,$7FF5,$324
	dc.w	$7FFF,$0,$7FF5,$FCDB,$7FD7,$F9B8,$7FA6,$F695
	dc.w	$7F61,$F374,$7F08,$F054,$7E9C,$ED38,$7E1C,$EA1E
	dc.w	$7D89,$E707,$7CE2,$E3F4,$7C29,$E0E6,$7B5C,$DDDC
	dc.w	$7A7C,$DAD8,$7989,$D7D9,$7883,$D4E1,$776B,$D1EF
	dc.w	$7640,$CF04,$7503,$CC21,$73B5,$C946,$7254,$C673
	dc.w	$70E1,$C3A9,$6F5E,$C0E9,$6DC9,$BE32,$6C23,$BB85
	dc.w	$6A6C,$B8E3,$68A5,$B64C,$66CE,$B3C0,$64E7,$B140
	dc.w	$62F1,$AECC,$60EB,$AC65,$5ED6,$AA0B,$5CB3,$A7BD
	dc.w	$5A81,$A57E,$5842,$A34C,$55F4,$A129,$539A,$9F14
	dc.w	$5133,$9D0E,$4EBF,$9B18,$4C3F,$9931,$49B3,$975A
	dc.w	$471C,$9593,$447A,$93DC,$41CD,$9236,$3F16,$90A1
	dc.w	$3C56,$8F1E,$398C,$8DAB,$36B9,$8C4A,$33DE,$8AFC
	dc.w	$30FB,$89BF,$2E10,$8894,$2B1E,$877C,$2826,$8676
	dc.w	$2527,$8583,$2223,$84A3,$1F19,$83D6,$1C0B,$831D
	dc.w	$18F8,$8276,$15E1,$81E3,$12C7,$8163,$FAB,$80F7
	dc.w	$C8B,$809E,$96A,$8059,$647,$8028,$324,$800A
	dc.w	$0,$8001,$FCDB,$800A,$F9B8,$8028,$F695,$8059
	dc.w	$F374,$809E,$F054,$80F7,$ED38,$8163,$EA1E,$81E3
	dc.w	$E707,$8276,$E3F4,$831D,$E0E6,$83D6,$DDDC,$84A3
	dc.w	$DAD8,$8583,$D7D9,$8676,$D4E1,$877C,$D1EF,$8894
	dc.w	$CF04,$89BF,$CC21,$8AFC,$C946,$8C4A,$C673,$8DAB
	dc.w	$C3A9,$8F1E,$C0E9,$90A1,$BE32,$9236,$BB85,$93DC
	dc.w	$B8E3,$9593,$B64C,$975A,$B3C0,$9931,$B140,$9B18
	dc.w	$AECC,$9D0E,$AC65,$9F14,$AA0B,$A129,$A7BD,$A34C
	dc.w	$A57E,$A57E,$A34C,$A7BD,$A129,$AA0B,$9F14,$AC65
	dc.w	$9D0E,$AECC,$9B18,$B140,$9931,$B3C0,$975A,$B64C
	dc.w	$9593,$B8E3,$93DC,$BB85,$9236,$BE32,$90A1,$C0E9
	dc.w	$8F1E,$C3A9,$8DAB,$C673,$8C4A,$C946,$8AFC,$CC21
	dc.w	$89BF,$CF04,$8894,$D1EF,$877C,$D4E1,$8676,$D7D9
	dc.w	$8583,$DAD8,$84A3,$DDDC,$83D6,$E0E6,$831D,$E3F4
	dc.w	$8276,$E707,$81E3,$EA1E,$8163,$ED38,$80F7,$F054
	dc.w	$809E,$F374,$8059,$F695,$8028,$F9B8,$800A,$FCDB
	dc.w	$8001,$FFFF,$800A,$324,$8028,$647,$8059,$96A
	dc.w	$809E,$C8B,$80F7,$FAB,$8163,$12C7,$81E3,$15E1
	dc.w	$8276,$18F8,$831D,$1C0B,$83D6,$1F19,$84A3,$2223
	dc.w	$8583,$2527,$8676,$2826,$877C,$2B1E,$8894,$2E10
	dc.w	$89BF,$30FB,$8AFC,$33DE,$8C4A,$36B9,$8DAB,$398C
	dc.w	$8F1E,$3C56,$90A1,$3F16,$9236,$41CD,$93DC,$447A
	dc.w	$9593,$471C,$975A,$49B3,$9931,$4C3F,$9B18,$4EBF
	dc.w	$9D0E,$5133,$9F14,$539A,$A129,$55F4,$A34C,$5842
	dc.w	$A57E,$5A81,$A7BD,$5CB3,$AA0B,$5ED6,$AC65,$60EB
	dc.w	$AECC,$62F1,$B140,$64E7,$B3C0,$66CE,$B64C,$68A5
	dc.w	$B8E3,$6A6C,$BB85,$6C23,$BE32,$6DC9,$C0E9,$6F5E
	dc.w	$C3A9,$70E1,$C673,$7254,$C946,$73B5,$CC21,$7503
	dc.w	$CF04,$7640,$D1EF,$776B,$D4E1,$7883,$D7D9,$7989
	dc.w	$DAD8,$7A7C,$DDDC,$7B5C,$E0E6,$7C29,$E3F4,$7CE2
	dc.w	$E707,$7D89,$EA1E,$7E1C,$ED38,$7E9C,$F054,$7F08
	dc.w	$F374,$7F61,$F695,$7FA6,$F9B8,$7FD7,$FCDB,$7FF5

cls:
	movem	rsxmin(a0),d4-d7
;
; d4=xmin
; d5=xmax
; d6=ymin
; d7=ymax
;
	ADD	#15,d5
	MOVEQ	#-16,D1
	and	d1,d5
	AND	d4,d1
	sub	d1,d5		;d2=nb pixels … effacer (multiple de 16)
	ble.s	.nocls
	asr	#1,d1
	move.l	usp,a6
	add	d1,a6
	lsr	#2,d5
	lea	PUSHCLS-4\W,A0
	move.l	(a0,d5.w),a0

	lea	MUL160.W,A1

	cmp	#240/4,d5
	bhs.s	.fasteff

	sub	d6,d7

	add	d6,d6
	add	(a1,d6.w),a6

	ADD	D7,D7
	ADD	D7,D7
	pea	(a0,d7.w)

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
.nocls:	rts
.fasteff
	move	d7,d2
	add	d2,d2
	add	(a1,d2.w),a6
	lea	160(a6),a6

	sub	d6,d7
	ADD	D7,D7
	ADD	D7,D7
	pea	(a0,d7.w)

	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	rts

genere_cls:
	lea	PUSHCLS\W,a3
	lea	FASTCLS,a6

	lea	eff16(pc),a0
	lea	eff161(pc),a1
	lea	eff162(pc),a2
	bsr	geneff

	lea	eff32(pc),a0
	lea	eff321(pc),a1
	lea	eff322(pc),a2
	bsr	geneff

	lea	eff48(pc),a0
	lea	eff481(pc),a1
	lea	eff482(pc),a2
	bsr	geneff

	lea	eff64(pc),a0
	lea	eff641(pc),a1
	lea	eff642(pc),a2
	bsr	geneff

	lea	eff80(pc),a0
	lea	eff801(pc),a1
	lea	eff802(pc),a2
	bsr	geneff

	lea	eff96(pc),a0
	lea	eff961(pc),a1
	lea	eff962(pc),a2
	bsr	geneff

	lea	eff112(pc),a0
	lea	eff1121(pc),a1
	lea	eff1122(pc),a2
	bsr	geneff

	lea	eff128(pc),a0
	lea	eff1281(pc),a1
	lea	eff1282(pc),a2
	bsr	geneff

	lea	eff144(pc),a0
	lea	eff1441(pc),a1
	lea	eff1442(pc),a2
	bsr	geneff

	lea	eff160(pc),a0
	lea	eff1601(pc),a1
	lea	eff1602(pc),a2
	bsr	geneff

	lea	eff176(pc),a0
	lea	eff1761(pc),a1
	lea	eff1762(pc),a2
	bsr	geneff

	lea	eff192(pc),a0
	lea	eff1921(pc),a1
	lea	eff1922(pc),a2
	bsr	geneff

	lea	eff208(pc),a0
	lea	eff2081(pc),a1
	lea	eff2082(pc),a2
	bsr	geneff

	lea	eff224(pc),a0
	lea	eff2241(pc),a1
	lea	eff2242(pc),a2
	bsr	geneff

	lea	eff240(pc),a0
	lea	eff2401(pc),a1
	bsr	geneff

	lea	eff256(pc),a0
	lea	eff2561(pc),a1
	bsr	geneff

	lea	eff272(pc),a0
	lea	eff2721(pc),a1
	bsr	geneff

	lea	eff288(pc),a0
	lea	eff2881(pc),a1
	bsr	geneff

	lea	eff304(pc),a0
	lea	eff3041(pc),a1
	bsr	geneff

	lea	eff320(pc),a0
	lea	eff3201(pc),a1
	bsr	geneff

	cmp.l	#finpush,a3
	bls.s	.good2
	illegal
.good2

	CMP.L	#FINFASTCLS,A6
	BLS.S	.OK
	ILLEGAL
.OK
	RTS

eff16:	movem.l	d0-d1,2(a6)
eff161:	movem.l	d0-d1,(a6)
eff162:
eff32:	movem.l	d0-d3,2(a6)
eff321:	movem.l	d0-d3,(a6)
eff322:
eff48:	movem.l	d0-d5,2(a6)
eff481:	movem.l	d0-d5,(a6)
eff482:
eff64:	movem.l	d0-d7,2(a6)
eff641:	movem.l	d0-d7,(a6)
eff642:
eff80:	movem.l	d0-d7/a0-a1,2(a6)
eff801:	movem.l	d0-d7/a0-a1,(a6)
eff802:
eff96:	movem.l	d0-d7/a0-a3,2(a6)
eff961:	movem.l	d0-d7/a0-a3,(a6)
eff962:
eff112:	movem.l	d0-d7/a0-a5,2(a6)
eff1121:movem.l	d0-d7/a0-a5,(a6)
eff1122:
eff128:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d1,2(a6)
eff1281:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d1,2(a6)
eff1282:
eff144:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d3,2(a6)
eff1441:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d3,2(a6)
eff1442:
eff160:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d5,2(a6)
eff1601:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d5,2(a6)
eff1602:
eff176:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7,2(a6)
eff1761:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7,2(a6)
eff1762:
eff192:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a1,2(a6)
eff1921:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a1,2(a6)
eff1922:
eff208:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a3,2(a6)
eff2081:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a3,2(a6)
eff2082:
eff224:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
eff2241:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
eff2242:
eff240:	lea	-40(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d1,-(a6)
eff2401:
eff256:	lea	-32(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d3,-(a6)
eff2561:
eff272:
	lea	-24(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d5,-(a6)
eff2721:
eff288:	lea	-16(a6),a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7,-(a6)
eff2881:
eff304:	subq	#8,a6
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a1,-(a6)
eff3041:
eff320:
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a5,-(a6)
	movem.l	d0-d7/a0-a3,-(a6)
eff3201:
geneff:
	move.l	a6,(a3)+
	move	#nblig-2,d7
gen1:	move.l	#$60000000,(a6)+
	dbra	d7,gen1
	move.l	a6,a5

	cmp.l	#eff240,a0
	bhs.s	gen240

	move	#nblig*160,d7
	bra.s	gen8
gen2:
	subq	#2,a5
	move.l	a6,d0
	sub.l	a5,d0
	move	d0,(a5)
	subq	#2,a5
gen8:
	sub	#160,d7
	beq.s	retgen
	move	d7,d6

	move.l	a0,a4
gen3:
	move	(a4)+,d0
	cmp	#2,d0
	bne.s	genok
	move	d6,d0
	add	#14*4,d6
genok:
	move	d0,(a6)+
	cmp.l	a1,a4
	blo.s	gen3
	bra.s	gen2
retgen:
	MOVE	#14*4,d6
gen6:
	move	(a1)+,d0
	cmp	#2,d0
	bne.s	gen7
	move	d6,d0
	ADD	#14*4,D6
gen7:
	move	d0,(a6)+
	cmp.l	a2,a1
	blo.s	gen6
	move	#$4e75,(a6)+
	rts
gen240
	move	#nblig-1,d7
	bra.s	.gen8
.gen2:
	subq	#2,a5
	move.l	a6,d0
	sub.l	a5,d0
	move	d0,(a5)
	subq	#2,a5
.gen8:
	move.l	a0,a4
.gen3:
	move	(a4)+,(a6)+
	cmp.l	a1,a4
	blo.s	.gen3
	dbra	d7,.gen2
	move	#$4e75,(a6)+
	rts

;	rsreset

off22 = 0	;rs.l	1	;ptr courant dans pattern
off0 = 4	;rs.l	1	;ptr base patterns
off34 = 8	;rs.l	1	;ptr fin musique

off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
offa = 14	;rs.l	1	;ptr base modulation volume
offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38 = 26	;rs.l	1	;incr‚ment pour crescendo

off8 = 30	;rs.b	1
off9 = 31	;rs.b	1

off16 = 32	;rs.b	1
off17 = 33	;rs.b	1
off18 = 34	;rs.b	1
off19 = 35	;rs.b	1
off1a = 36	;rs.b	1
off1b = 37	;rs.b	1
off1c = 38	;rs.b	1
off1d = 39	;rs.b	1
off1e = 40	;rs.b	1
off1f = 41	;rs.b	1
off21 = 42	;rs.b	1

off26 = 43	;rs.b	1
off27 = 44	;rs.b	1
off28 = 45	;rs.b	1	;15-volume sonore de la voix
off2a = 46	;rs.b	1	;0,1 ou 2=type de son
off2b = 47	;rs.b	1
off2c = 48	;rs.b	1
off2d = 49	;rs.b	1	;volume sonore calcul‚
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2

MUS = 1

INITMUSIC:
	LEA	LA2E,A0
	moveq	#MUS,d0
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
	TST	D0		;musique=0 -> cut mus
	BEQ	LCA
	subq	#1,d0

	LEA	PSGREG(PC),A6
	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	4(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L938-PSGREG(A6)
	MOVE.L	8(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L93C-PSGREG(A6)
	MOVE.L	$C(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L91A-PSGREG(A6)
	MOVE.L	$10(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L916-PSGREG(A6)
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D1,D0
	ADD	D0,A1
	MOVEQ	#$C,D7
	MULU	(A1)+,D7	;PREMIER PATTERN
	MOVE	(A1)+,D6
	ADDQ	#1,D6
	MULU	#$C,D6		;DERNIER PATTERN
	MOVE	(A1)+,D0
	MOVE.B	D0,L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A0
	LEA	L7C6(PC),A1
L658:	MOVE.L	A1,offa(a0)
	clr	offe(a0)
	CLR.B	off2d(A0)
	CLR.B	off8(a0)
	CLR.B	off9(a0)
	MOVE.L	A1,off12(A0)
	clr	off30(a0)
	MOVE.B	#1,off17(A0)
	MOVE.B	#1,off18(A0)
	CLR.B	off19(A0)
	clr.b	off1a(a0)
	clr.b	off1b(a0)
	clr.b	off1c(a0)
	clr.b	off1d(a0)
	clr.b	off1e(A0)
	clr.b	off1f(a0)
	move.l	d0,d3
	MOVE.B	d3,off21(A0)
	ADD	D3,D3
	ADD	D3,D3
	MOVE.L	L916(PC),d1
	add.l	D7,d1
	add.l	D3,d1
	move.l	d1,off0(A0)
	move.l	d1,a3
	MOVE.L	L916(PC),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,off34(A0)
	move	#$C,off4(a0)
	moveq	#0,d1
	move.b	(A3)+,D1
	ADD	D1,D1
	MOVE.L	L91A(PC),A4
	MOVE	(A4,D1.W),A4
	ADD.L	L934(PC),A4
	MOVE.L	A4,off22(A0)
	clr.b	off26(A0)
	clr.b	off27(A0)
	MOVE.B	#2,off2a(A0)
	move.b	(A3)+,off2c(A0)
	CLR.B	off2b(A0)
	move.b	(A3)+,off16(A0)
	moveq	#$10,d1
	add.B	(A3),D1
	bcs.s	L712
	moveq	#0,d1
L712:
	MOVE.B	D1,off28(A0)
	CLR.L	off38(A0)
	lea	off3c(a0),A0
	addq	#1,d0
	cmp	#3,d0
	blo	L658
	MOVE.B	#1,L80E-PSGREG(A6)
	CLR	L812-PSGREG(A6)

	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	RTS
LCA:	LEA	L812(PC),A0
	ST	(A0)
PLAYMUSIC:
	LEA	PSGREG(PC),A6
	TST.B	L812-PSGREG(A6)
	BEQ.S	L160
	TAS	L813-PSGREG(A6)
	BNE.S	L15E
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
L15E:	RTS
L160:	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR.s	L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:	move.b	#$C0,$1E(A6)
	LEA	voice0(PC),A0
	BSR	L39A
	move	d0,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,$22(A6)
	LEA	voice1(PC),A0
	BSR	L39A
	move	d0,$E(A6)
	MOVE.B	D0,$A(A6)
	MOVE.B	D1,$26(A6)
	LEA	voice2(PC),A0
	BSR	L39A
	move	D0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS

;
; calcule nouvelle note
;

L25C:	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	off22(A0),A1
L26C:	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.S	L2E2
	MOVE.L	off0(a0),a1
	add	off4(a0),a1
	cmp.l	off34(a0),a1
	blo.S	L288
	move	d5,off4(a0)
	MOVE.L	off0(a0),a1
L288:	MOVEQ	#0,D1
	move.b	(a1)+,D1
	move.b	(a1)+,off2c(A0)
	move.b	(a1)+,off16(A0)
	moveq	#$10,d0
	add.b	(a1)+,D0
	bcc.s	L2B4
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
	BRA.S	L2C4
L2B4:	add.b	#$10,d0
	bcc.S	L2C4
	move.B	d0,L810-PSGREG(A6)	;E0-EF=vitesse
L2C4:	ADD	D1,D1
	MOVE.L	L91A(PC),A1
	MOVE	(A1,D1.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off22(A0)
	add	#$C,off4(a0)
	BRA.s	L26C
L2E2:	CMP.B	#$FE,D0
	BNE.S	L2F4
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA.s	L26C
L2F4:	CMP.B	#$FD,D0
	BNE.S	L308
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,off22(A0)
	RTS
L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	L31C
	MOVE.B	(A1)+,off1f(A0)
L31C:	MOVE.L	A1,off22(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI.S	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L93C(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	move	d5,offe(A0)
	MOVE.B	(a1)+,d1
	move.b	d1,off17(A0)
	MOVE.B	d1,off18(A0)
	MOVEQ	#0,D1
	MOVE.B	(a1)+,D1
	MOVE.B	(a1)+,off1b(A0)
;	MOVE.B	#$40,off2e(A0)
	clr.b	off2e(a0)
	MOVE.B	(a1)+,D2
	MOVE.B	D2,off1c(A0)
	MOVE.B	D2,off1d(A0)
	MOVE.B	(a1)+,off1e(A0)
	MOVE.L	a1,offa(A0)
	add.b	d0,d0			;test bit 6
	bpl.s	L37A
	MOVE.B	off1f(A0),D1
L37A:	MOVE.L	L938(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	MOVE.L	a1,off12(A0)
	move	d5,off30(A0)
	MOVE.B	D5,off1a(A0)
	MOVE.B	D5,off19(A0)
L398:	RTS

;
; calcul de la note … jouer
;

L39A:	MOVEQ	#0,D7
	MOVE	off30(a0),d6
L3A0:	TST.B	off1a(A0)
	BEQ.S	L3AE
	SUBQ.B	#1,off1a(A0)
	BRA	L4C01
L3AE:	MOVE.L	off12(A0),A1
	add	d6,a1
L3B6:	move.b	(a1)+,d0
	cmp.b	#$E1,d0
	BEQ	L4C01
	cmp.b	#$E0,d0
	BNE.S	L3D8
	moveq	#$3f,d6
	and.B	(A1),D6
	MOVE.L	off12(A0),A1
	add	d6,A1
	move.b	(a1)+,d0
L3D8:	cmp.b	#$E2,d0
	BNE.S	L3EE
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6
L3EE:	cmp.b	#$E9,d0
	BNE.s	L422
	MOVE.B	#$B,$FFFF8800.W
	move.b	(A1)+,$FFFF8802.W
	move.l	#$0C0C0000,$FFFF8800.W
	move.l	#$0D0D0A0A,$FFFF8800.W
	addq	#2,d6
	bra.s	L3B6
L422:	cmp.b	#$E7,d0
	BNE.S	L44A
	clr	d0
	move.b	(A1),D0
	ADD	D0,D0
	MOVE.L	L938(PC),A1
	MOVE	(A1,D0.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off12(A0)
	clr	d6
	BRA.s	L3B6
L44A:	cmp.b	#$E8,d0
	BNE.S	L45E
	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0
L45E:	cmp.b	#$E4,d0
	BNE.S	L474
	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA.S	L4AE
L474:	cmp.b	#$E5,d0
	BNE.S	L488
	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
L488:	cmp.b	#$E6,d0
	BNE.S	L49A
	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA.S	L4AE
L49A:	cmp.b	#$E3,d0
	BNE.S	L4B0
	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:	move	d6,off30(a0)
;
; modulation volume
;
	move	offe(a0),d6
L4C0:	TST.B	off19(A0)
	BEQ.S	L4CC
	SUBQ.B	#1,off19(A0)
	BRA.S	L51A
L4CC:	SUBQ.B	#1,off17(A0)
	BNE.S	L51A
	MOVE.B	off18(A0),off17(A0)

	MOVE.L	offa(A0),A1
	add	d6,a1
	move.b	(A1)+,D0
	CMP.B	#$E0,D0
	BNE.S	L512
	moveq	#$3f,d6
	and.b	(A1),D6
	subq	#5,D6
	move.l	offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
L512:
	CMP.B	#$E8,D0
	BNE.S	L4F4
	addq	#2,d6
	move.b	(A1)+,off19(A0)
	BRA.S	L4C0
L4F4:	CMP.B	#$E1,D0
	BEQ.S	L51A
	MOVE.B	d0,off2d(A0)
	addq	#1,d6
L51A:	move	d6,offe(a0)

	clr	d5
	MOVE.B	off2b(A0),D5
	BMI.S	L528
	ADD.B	off8(a0),D5
	ADD.B	off2c(A0),D5
L528:
	LEA	L94E(PC),A1
	add.b	D5,D5
	MOVE	(A1,d5.w),D0

	move.b	off2a(A0),D2	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D3
	ADDQ	#3,D3

	subq.b	#1,D2
	BNE.S	L578
	subq	#3,d3
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578
	add.b	off8(a0),d7
L578:	BSET	D3,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	MOVE.B	off2e(A0),d6
	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d4
	MOVE.B	off1c(A0),D4
	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	d6
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	d6
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	D4,D4
	CMP.B	D4,D1
	BCS.S	L5DA
	bclr	#7,d6
	MOVE.B	D4,D1
L5DA:	lsr.b	#1,d4
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	D4,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d4

	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
L5FA:	EOR.B	#1,d6
	MOVE.B	d6,off2e(A0)
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	lsr.l	#4,d1		;asr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:	MOVE.B	off2d(A0),D1
	SUB.B	off28(A0),D1
	BPL.S	L634
	MOVEQ	#0,D1
L634:
	RTS

L94E:	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F
L7C6:	DC.B	1,0,0,0,0,0,0,$E1
PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808,0,$909,0
	DC.W	$A0A,0

L80E:	DC.B	4
L810:	DC.B	4
L812:	DC.B	-1
L813:	DC.B	0

voice0:	ds.B	off3c
voice1:	ds.B	off3c
voice2:	ds.B	off3c
L916:	DC.L	0
L91A:	DC.L	0
L934:	DC.L	0
L938:	DC.L	0
L93C:	DC.L	0

	section	data

coords_spider
	DC.W	22
;	DC.W	$60		;ZOOM MAXIMAL

	DC.W	-15,  25,  0
	DC.W	 25,  30,  0
	DC.W	-65,  10,  0
	DC.W	-15,  10,  5
	DC.W	 25,  10,  5
	DC.W	 40,  10,  0
	DC.W	-65, -10,  0
	DC.W	-15, -10,  5
	DC.W	 25, -10,  5
	DC.W	 40, -10,  0
	DC.W	-15, -25,  0
	DC.W	 25, -30,  0
	DC.W	-15,  25, -5
	DC.W	 25,  30, -5
	DC.W	-75,   5, -5
	DC.W	 40,  10, -5
	DC.W	-75,  -5, -5
	DC.W	 40, -10, -5
	DC.W	-15, -25, -5
	DC.W	 25, -30, -5
	DC.W	-10,   0,-15
	DC.W	 20,   0,-15

coords_cube
	DC.W	8
;	DC.W	$60			;ZOOM MAXIMAL

	DC.W	-50,50,-50	;1
	DC.W	-50,-50,-50	;2
	DC.W	50,-50,-50	;3
	DC.W	50,50,-50	;4

	DC.W	-50,50,50	;5
	DC.W	-50,-50,50	;6
	DC.W	50,-50,50	;7
	DC.W	50,50,50	;8

coords_tetra:
	dc.w	4
;	DC.W	$60			;ZOOM MAXIMAL

;	dc.w	0,50,0
;	dc.w	-50,-50,-50
;	dc.w	50,-50,-50
;	dc.w	0,-50,50

	dc.w	50,0,0
	dc.w	-25,37,-22
	dc.w	-26,-37,21
	dc.w	0,0,-50
;	dc.w	0,25,-44

;	dc.w	0,50,0
;	dc.w	-43,-25,-25
;	dc.w	43,-25,-25
;	dc.w	0,-25,25

coords_grille:
	DC.W	25
;	DC.W	$60			;ZOOM MAXIMAL
	DC.W	-50,-50,0
	DC.W	-25,-50,0
	DC.W	0,-50,0
	DC.W	25,-50,0
	DC.W	50,-50,0
	DC.W	-50,-25,0
	DC.W	-25,-25,0
	DC.W	0,-25,0
	DC.W	25,-25,0
	DC.W	50,-25,0
	DC.W	-50,0,0
	DC.W	-25,0,0
	DC.W	0,0,0
	DC.W	25,0,0
	DC.W	50,0,0
	DC.W	-50,25,0
	DC.W	-25,25,0
	DC.W	0,25,0
	DC.W	25,25,0
	DC.W	50,25,0
	DC.W	-50,50,0
	DC.W	-25,50,0
	DC.W	0,50,0
	DC.W	25,50,0
	DC.W	50,50,0

drawline:incbin	drawline.bin
TEXTE1:	INCBIN	MESSAGE.BIN
	DC.W	-1
TEXTE2:	ds.b	38
	INCBIN	MESS2.BIN
FONTE:	DS.B	8
fonte:	incbin	fonte3.img
FINFONTE:
LA2E:	INCBIN	MEDUSA.PAK

	ifeq	DEBUG
debugger:incbin	debugger.bin
	endc

	SECTION	BSS
	ds.l	50
pile:
fast_draw:ds.b	(enddraw2-startdraw2)*nblig+2
findraw:
fast_draw2:ds.b	(enddraw2-startdraw2)*nblig+2
findraw2:

FASTCALC
	DS.B	(FINCALCUL-CALCUL)*nbpts+2
FINFASTCALC

FASTCLS:
	ds.b	62720		;juste ??
FINFASTCLS:

PREDEC:	DS.B	2*4*(16/STEP)*(LONGFONTE)
FINPREDEC:
L6ECC:	DS.B	(16/STEP)*TAILLE*80	;BUFFER POUR SCROLLER
fincode:
