;
; … faire :
;	- rentrer nouveaux objets
;	- affichage 2 plans
;	- startdraw rajouter des octets aprŠs le bra
;		pour avoir une puissance de 2 !!!
;	- routine DRAWLINE en code g‚n‚r‚
;	- routine de droite verticale
;	- liste des bugs :
;		- clipping en Y
;		- droites horizontales merdent parfois (??)
;		- cachage des facettes pas clean
;
	opt	o+
DEBUG = 0			;0=debugger
ecran1 = $80000-32000
ecran0 = ecran1-32000
nbpts = 22
nblig = 200
CPU	MACRO
	CMP.B	#$F,$FFFFFC02.W
	BNE.S	.\@
	MOVE	#\1,$FFFF8240.W
.\@
	ENDM
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
pointsgauches:ds.w	200
pointsdroits:ds.w	200

	DS.W	10
MUL160	DS.W	200
	DS.W	10
ecran:	ds.l	1
curobj:	ds.w	1
sync:	ds.w	1
xmin:	ds.w	1
xmax:	ds.w	1
ymin:	ds.w	1
ymax:	ds.w	1
xmin2:	ds.w	1
xmax2:	ds.w	1
ymin2:	ds.w	1
ymax2:	ds.w	1
NEW:	DS.W	9
PUSHCLS:DS.L	40
	ds.l	10

nbobj:	ds.w	1	;compteur d'objets stock‚s
ptrread:ds.l	1
ptrwrite:ds.l	1


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
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	ifeq	DEBUG
	jsr	debugger
	endc

	lea	ecran0,sp		;super stack

	move.l	#ecran0,d0
	move.l	d0,ecran\W
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	ecran0,a0
	move	#($80000-ecran0)/4-1,d0
	moveq	#0,d1
.cls
	move.l	d1,(a0)+
	dbra	d0,.cls

	lea	(MUL160-20).W,A0
	move	#220-1,d0
.fil160	move	#-1,(a0)+
	dbra	d0,.fil160

	moveq	#0,d0
	lea	MUL160\W,A0
.mul160	move	d0,(a0)+
	add	#160,d0
	cmp	#160*200,d0
	blo.s	.mul160

	bsr	gendraw
	BSR	INITCALC

	jsr	genere_cls

	move	#160,xmax\W
	move	#160,xmin\W
	move	#100,ymax\W
	move	#100,ymin\W
	move	#160,xmax2\W
	move	#160,xmin2\W
	move	#100,ymax2\W
	move	#100,ymin2\W

	move.l	#vbl,$70.w
	move	#$2300,sr
	clr	sync\W
.vbl1	tst	sync\W
	beq.s	.vbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette1(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	#prg_sur_vbl,$70.w
	clr	nbobj\w			;nb points calcul‚s
	move.l	#segments,ptrwrite\w
	move.l	#segments,ptrread\w
	clr	curobj\w
demo
	clr	d0
	move.b	$fffffc02.w,d0
	subq.b	#2,d0
	cmp	#2,d0
	bhs.s	.nochg
	add	d0,d0
	add	d0,d0
	move	d0,curobj\w
.nochg
	move.l	ptrwrite\w,a1

	move	curobj\w,d0
	lea	all_objects(pc),a0
	move.l	(a0,d0.w),a0

	BSR	CALCOBJ
	cmp.l	#finsegments,a1
	blo.s	.ok
	lea	segments,a1
.ok
	move.l	a1,ptrwrite\w
	addq	#1,nbobj\w
.loop	cmp	#200,nbobj\w
	beq.s	.loop
	bra.s	demo

all_objects:dc.l coords_spider,coords_cube

novbl:	rte
prg_sur_vbl:
	tst	nbobj\w
	beq.s	novbl

	subq	#1,nbobj\w

	movem.l	d0-d7/a0-a6,-(sp)


	move.l	usp,a0
	pea	(a0)

	move.l	ecran\W,d0
	move.l	d0,a0
	move.l	a0,usp
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	palette1(pc),a0
	cmp.b	#$3b,$fffffc02.w
	bne.s	.notf1
	lea	palette2(pc),a0
.notf1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	CPU	$555
	bsr	cls

	CPU	$770

	move.l	ptrread\w,a5

	move.l	xmin2\W,d0
	move.l	(a5)+,xmin2\W
	move.l	d0,xmin\W
	move.l	ymin2\W,d0
	move.l	(a5)+,ymin2\W
	move.l	d0,ymin\W

	MOVE	(A5)+,D0		;NUMERO DE L'OBJET*4
	JSR	polycalc(PC,D0.W)

	cmp.l	#finsegments,a5
	blo.s	.ok
	lea	segments,a5
.ok
	move.l	a5,ptrread\w

	eor.l	#ecran0^ecran1,ecran\W
	move.l	(sp)+,a0
	move.l	a0,usp
	movem.l	(sp)+,d0-d7/a0-a6
	clr	$ffff8240.w
	rte

TEST	MACRO

	ifeq	\1-\2+1
	MOVEM	\1*4(a5),d0/d1/d2/d3	;A/B
	elseif
	MOVEM	\1*4(a5),d0/d1		;A
	MOVEM	\2*4(a5),d2/d3		;B
	endc
	MOVEM	\3*4(a5),d4/d5		;C

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
	ifeq	\1-\2+1
	movem	\1*4(a5),d0/d1/d2/d3
	elseif
	movem	\1*4(a5),d0/d1
	movem	\2*4(a5),d2/d3
	endc
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
	mulu	#enddraw-startdraw,d7
	lea	fast_draw+(nblig-1)*(enddraw-startdraw),a0
	sub.l	d7,a0
	jsr	(a0)
\@
	ENDM

polycalc
	bra.w	spider
	bra.w	cube

spider:
	lea	drawline+$16(pc),a4		;optimisation !!!
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
	lea	22*4(a5),a5
	RTS
;
; affichage d'un cube
;
cube:
	lea	drawline+$16(pc),a4		;optimisation !!!
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
	lea	8*4(a5),a5
	rts
;
;
vbl:	addq	#1,sync\W
	rte
retr:	rtr
palette1:DC.W	$000
	DC.W	$700		;0001
	DC.W	$070		;0010
	DC.W	$770		;0011
	DC.W	$007		;0100
	DC.W	$707		;0101
	DC.W	$077		;0110
	DC.W	$777		;0111

	DCB.W	8,$555

palette2:DC.W	$000
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
	move	#(enddraw-startdraw)/2-1,d0
2$	move	(a0)+,(a6)+
	dbra	d0,2$
	dbra	d7,1$
	move	#$4e75,(a6)+		;rts
	cmp.l	#findraw,a6
	beq.s	.ok
	illegal
.ok
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
	bra.s	.cont
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
ROTATEX = 2		;vitesse de rotation
ROTATEY = 1
ROTATEZ = 3
;
; ANGLES DE ROTATION, ETC...
;
ROTX	DC.B	$20
ROTY	DC.B	$20
ROTZ	DC.B	$20
	EVEN

NXTANG	MACRO
	ADD.B	\1(PC),D0
	MOVE.B	D0,\1
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(a2,D0.W),\2
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
	MOVEQ	#ROTATEX,D0		;ROT X
	NXTANG	ROTX,SX/CX	;SX
	MOVEQ	#ROTATEY,D0		;ROT Y
	NXTANG	ROTY,SY/CY	;SY
	MOVEQ	#ROTATEZ,D0		;ROT Z
	NXTANG	ROTZ,SZ/CZ	;SZ
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
; A3=XMIN
; A4=XMAX
; A5=YMIN
; A6=YMAX
;
	move	#319,A3		;xmin
	SUB	A4,A4		;xmax
	move	#199,A5		;ymin
	SUB	A6,A6		;ymax

	MOVE.L	A1,MODIF+4
	ADDQ	#8,A1

	move	curobj\w,(a1)+
	MOVE	(A0)+,D4
modif1	JSR	FASTCALC

	MOVE	A3,D0
	BPL.S	.1
	SUB	A3,A3
.1
	CMP	#320,A4
	BLO.S	.2
	MOVE	#319,A4
.2
	MOVE	A5,D0
	BPL.S	.3
	SUB	A5,A5
.3
	CMP	#200,A6
	BLO.S	.4
	MOVE	#199,A6
.4

MODIF:	MOVEM	A3/A4/A5/A6,0.L
	rts

INITCALC
	LEA	FASTCALC,A6
	MOVE	#22-1,D7
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
; a3=xmax
; a4=xmin
; a5=profondeur
; USP=constante
; d0/d1/d2/d3/d5/d6/d7
;
; a6=ymin
; d4=LIBRE !!!!
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

	ADD.L	D5,D5
	SWAP	D5

	ADD.L	D7,D7
	ADD.L	D6,D6
	SWAP	D6
	SWAP	D7

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

	ADD	#-$12C,D5
	MULS	d4,D6
	MULS	d4,D7
	DIVS	D5,D6
	DIVS	D5,D7

	ADD	#360/2,D6
	ADD	#200/2,D7

	MOVE	D6,(A1)+
	MOVE	D7,(A1)+
;
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


coords_spider
	DC.W	22
	DC.W	$190-32			;ZOOM MAXIMAL

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
	DC.W	$190-40			;ZOOM MAXIMAL

	DC.W	-50,50,-50	;1
	DC.W	-50,-50,-50	;2
	DC.W	50,-50,-50	;3
	DC.W	50,50,-50	;4

	DC.W	-50,50,50	;5
	DC.W	-50,-50,50	;6
	DC.W	50,-50,50	;7
	DC.W	50,50,50	;8

cls:
	MOVEQ	#15,D0
	ADD	xmax\W,d0
	and	#$fff0,d0
	MOVEQ	#-16,D1
	AND	xmin\W,d1
	sub	d1,d0		;d2=nb pixels … effacer (multiple de 16)
	beq.s	.nocls
	asr	#1,d1
	move.l	usp,a6
	add	d1,a6
	lsr	#2,d0
	lea	PUSHCLS\W,A0
	move.l	(a0,d0.w),a0

	move	ymax\W,d0
	move	ymin\W,d1
	move	d1,d2
	mulu	#160,d2
	add	d2,a6

	sub	d1,d0
	ADD	D0,D0
	ADD	D0,D0
	add	d0,a0
	pea	(a0)

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
	lea	eff2402(pc),a2
	bsr	geneff

	lea	eff256(pc),a0
	lea	eff2561(pc),a1
	lea	eff2562(pc),a2
	bsr	geneff

	lea	eff272(pc),a0
	lea	eff2721(pc),a1
	lea	eff2722(pc),a2
	bsr	geneff

	lea	eff288(pc),a0
	lea	eff2881(pc),a1
	lea	eff2882(pc),a2
	bsr	geneff

	lea	eff304(pc),a0
	lea	eff3041(pc),a1
	lea	eff3042(pc),a2
	bsr	geneff

	lea	eff320(pc),a0
	lea	eff3201(pc),a1
	lea	eff3202(pc),a2
	bsr	geneff
	CMP.L	#FINFASTCLS,A6
	BLO.S	.OK
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
eff240:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d1,2(a6)
eff2401:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d1,2(a6)
eff2402:
eff256:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d3,2(a6)
eff2561:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d3,2(a6)
eff2562:
eff272:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d5,2(a6)
eff2721:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d5,2(a6)
eff2722:
eff288:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7,2(a6)
eff2881:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7,2(a6)
eff2882:
eff304:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a1,2(a6)
eff3041:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a1,2(a6)
eff3042:
eff320:	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a3,2(a6)
eff3201:movem.l	d0-d7/a0-a5,(a6)
	movem.l	d0-d7/a0-a5,2(a6)
	movem.l	d0-d7/a0-a3,2(a6)
eff3202:
geneff:
	move.l	a6,(a3)+
	move	#nblig-2,d7
gen1:	move.l	#$60000000,(a6)+
	dbra	d7,gen1
	move.l	a6,a5

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

	section	data
drawline:incbin	drawline.bin

	ifeq	DEBUG
debugger:incbin	debugger.bin
	endc

	SECTION	BSS
fast_draw:ds.b	(enddraw-startdraw)*nblig+2
findraw:

FASTCALC
	DS.B	(FINCALCUL-CALCUL)*22+2
FINFASTCALC

FASTCLS:
	ds.b	100000
FINFASTCLS:
segments
	ds.b	(nbpts*4+6)*210
finsegments
