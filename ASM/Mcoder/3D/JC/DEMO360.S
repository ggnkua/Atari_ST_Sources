;
; … faire :
;	- revoir calcul de la matrice !!!
;	- d‚bugger objets Vincent (trop de points par face !!!)
;	- Claude -> mettre nb pts avant chaque objet !!!
;	- quand toutes les droites sont horizontales que faire ????
;	- entrer objets Claude (convexes/concaves)
;	- damier … moiti‚ vide ou disym‚trique
;	- rentrer t‚traŠdre
;	- entrer calcul incr‚mental des positions
;	  (+sc‚nario afin d'exploiter cet avantage !!!)
;	- objets transparents (entrer facettes internes)
;	- gestion multi‚crans … d‚bugger avec rasters en bas
;
	opt	o+,ow-
	OUTPUT	DEMO.PRG
XMILIEU = 320/2
LONGFONTE = 472+8
DEBUG = 0			;0=debugger
NBSCR = 8
nbpts = 30		;25 si pas nscarre
nblig = 200-8
PROF = 1
CLIPPEGAUCHE = 1024
CLIPPEDROITE = 1024
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
MATRICE:DS.W	9
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
DIST:	DS.W	1
CURTEXT:DS.L	1
planes:	ds.w	1
lastpal:ds.l	1
palette:ds.b	16*2
;
; structure :
;	0.L=adresse ‚cran
;	4.W=xmin
;	6.W=xmax
;	8.W=ymin
;	10.W=ymax
;	12.L=adresse palette … afficher
;	16.W=plans … effacer
;
	rsreset
rsecran	rs.l	1
rsxmin	rs.w	1
rsxmax	rs.w	1
rsymin	rs.w	1
rsymax	rs.w	1
rspal	rs.l	1
rsplanes:rs.w	1
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


latchnum:ds.b	1
numsec	ds.b	1
cptvbl	ds.b	1
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
	move	#65536*2/4-1,d0
	jmp	(sp)
trans:	move.l	(a0)+,(a1)+
	move	a1,$ffff8240.w
	dbra	d0,trans
	jmp	CODE

	IFEQ	1
	DC.B	"DO YOU REALLY THINK I COULD LET YOU INSPECT "
	DC.B	"MY ROUTINES EASILY ? DON'T MAKE ANY DEMO-BREAKER "
	DC.B	"BECAUSE YOU COULD HAVE PROBLEMS IN THE NEAR FUTURE !!! "
	EVEN
	ENDC
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
	move.b	#$40,$fffffa17.w
	move.l	#hbl,$120.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w

	lea	pile,sp		;super stack

	moveq	#NBSCR-1,d0
	move.l	#$80000,a0
	lea	ptrscr\w,a1
	lea	firstpal,a2
.genit
	lea	-32000(a0),a0
	move.l	a0,(a1)+
	move	#160,(a1)+
	move	#160,(a1)+
	move	#nblig/2,(a1)+
	move	#nblig/2,(a1)+
	move.l	a2,(a1)+
	lea	32(a2),a2
	clr	(a1)+
	dbra	d0,.genit

	cmp.l	#finscr,a1
	beq.s	.good
	illegal
.good
	cmp.l	#fincode,a0
	bhs.s	.nobug
	illegal
.nobug
	move	#hline2-hline1,d0
	cmp	#128,d0
	beq.s	.oklin
	illegal
.oklin
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
	jsr	gendraw
	jsr	genereline
	JSR	INITCALC
	jsr	genere_cls

	jsr	INITMUSIC
	move.l	#vbl,$70.w
	move	#$2300,sr
	clr	sync\W
.vbl1	tst	sync\W
	beq.s	.vbl1
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#prg_sur_vbl,$70.w
	move.l	#bugpal,lastpal\w
	clr	curobj\w
	clr.b	latchkey\w
	clr.b	cheat\w

	move.b	#50,cptvbl.w
	clr.b	numsec.w
	clr.b	latchnum.w

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

	cmp.b	#$4a,d0
	bne.s	.notmoins
	tst	curobj.w
	beq.s	.notmoins
	sub	#12,curobj.w
	CLRALL
.notmoins
	cmp.b	#$4e,d0
	bne.s	.notplus
	cmp	#(NBOBJETS-1)*12,curobj.w
	bhs.s	.notplus
	add	#12,curobj.w
	CLRALL
.notplus

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
;	subq.b	#2,d0
;	cmp	#8,d0
;	bhs.s	.nochg
;	add	d0,d0
;	add	d0,d0
;	move	d0,curobj\w
;	CLRALL
;.nochg
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

	jsr	cls

	MOVE	curobj\w,D0		;NUMERO DE L'OBJET*4
	lea	all_objects(pc),a0
	move.l	8(a0,d0.w),a4		;palette
	movem.l	(a4)+,d1-d7/a1
	movem.l	d1-d7/a1,palette.w
	move.l	0(a0,d0.w),a0		;adresse des points

	lea	segments\w,a1
	JSR	CALCOBJ

	move.l	rsecran(a0),a1
	move.l	a1,usp

	MOVE	curobj\w,D0		;NUMERO DE L'OBJET*4
	lea	drawline,a4		;optimisation !!!
	lea	all_objects(pc),a0
	move.l	4(a0,d0.w),a0		;routine de branchement
	clr	planes\w
	JSR	(a0)

	move.l	ptwr\w,a0
	move	planes\w,rsplanes(a0)
	move.l	rspal(a0),a1
	movem.l	palette.w,d0-d7
	movem.l	d0-d7,(a1)

	tst.b	cheat\w
	beq.s	.nodisp
	MOVE.L	USP,A6
	MOVE.B	latchnum.w,D7	;nb images par seconde
	BSR	print

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
	tst.b	cheat.w
	beq.s	.loop
	cmp.b	#1,$fffffc02.w
	bne.s	.loop
	move	#$077,$ffff8240.w
.loop	cmp	#NBSCR-3,nbimages\w
	bhs.s	.loop
	bra	demo

divs0:
	addq	#PROF,DIST.W
	addq	#1,d4
	addq	#1,d5
	rte
vbl:	addq	#1,sync\W
	rte
retr:	rtr

prg_sur_vbl:
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	#nblig,$fffffa21.w
	move.b	#8,$fffffa1b.w

	move.l	lastpal\w,a0
	movem.l	(a0),d0-d7
	move	d0,$ffff8242.w
	movem.l	d1-d7,$ffff8244.w

	JSR	PLAYMUSIC
	MOVE.L	lastecran\w,a2
	bsr	SCROLLER

	tst	nbimages\w
	beq.s	novbl
	subq	#1,nbimages\w
	clr	$ffff8240.w

	sub	d0,d0
	moveq	#1,d1
	move.b	numsec.w,d0
	abcd	d1,d0

	subq.b	#1,cptvbl.w
	bne.s	.nodispx2
	move.b	#50,cptvbl.w
	move.b	d0,latchnum.w
	clr	d0
.nodispx2
	move.b	d0,numsec.w

	move.l	ptrd\w,a0
	move.l	rsecran(a0),d0
	move.l	d0,lastecran\w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	rspal(a0),lastpal\w
	cmp.b	#$3b,$fffffc02.w
	bne.s	.notf1
	move.l	#bugpal,lastpal\w
.notf1
	lea	rslong(a0),a0
	cmp.l	#finscr,a0
	blo.s	1$
	lea	ptrscr\w,a0
1$	move.l	a0,ptrd\w

	movem.l	(sp)+,d0-d7/a0-a6
	rte
novbl:
	subq.b	#1,cptvbl.w
	bne.s	.nodispx2
	move.b	#50,cptvbl.w
	move.b	numsec.w,latchnum.w
	clr.b	numsec.w
.nodispx2

	tst.b	cheat\w
	beq.s	.nocpu

	cmp.b	#$f,$fffffc02.w
	bne.s	.nocpu
	add	#$333,$ffff8240.w	;indique quand passage en 2
.nocpu
	movem.l	(sp)+,d0-d7/a0-a6
	rte
hbl:
;	move	#$222,$ffff8240.w
	move	#$044,1*2+$ffff8240.w
	move	#$055,2*2+$ffff8240.w
	move	#$066,4*2+$ffff8240.w
	move	#$077,8*2+$ffff8240.w
;	clr	$ffff8240.w
	clr.b	$fffffa1b.w
	rte
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

xx	set	0
zz	set	2
Z	SET	32

Y	SET	(200-TAILLE)*160
X	SET	0
	REPT	TAILLE*152/8

	MOVE	(A1)+,X+Y+xx(A2)
X	SET	X+8

	IFEQ	X-X/160*160-152

	MOVE.L	(A0)+,D0
	OR.L	(A3)+,D0
	OR	(A1),D0
	MOVE	D0,X+Y+xx(A2)
	SWAP	D0
	MOVE.L	D0,-40(A1)
	MOVE.L	D0,(A1)
X	SET	X+8

xx	set	xx+zz
	iflt	xx
xx	set	0
	endc

	ifeq	xx-6
zz	set	-zz
	endc

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

print:
	bsr.w	digit
digit:
	rol.b	#4,d7
	moveq	#$f,d0
	and	d7,d0
	asl	#3,d0
	lea	fonte,a0
	add	d0,a0
x	set	6
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

	;OPT	OW-
	ifeq	\1-\3+1
	MOVEM	\1*4+segments.w,d0/d1/d4/d5	;A/C
	elseif
	MOVEM	\1*4+segments.w,d0/d1		;A
	MOVEM	\3*4+segments.w,d4/d5		;C
	endc
	MOVE.L	\2*4+segments.w,d2		;B
	;OPT	OW+

	sub	D2,d5		;d5=yc-yb
	sub	D2,d1		;d1=ya-yb
	SWAP	D2

	sub	d2,d4		;d4=xc-xb
	sub	D2,d0		;d0=xa-xb

	muls	d1,d4		;d4=(ya-yb)*(xc-xb)
	muls	d0,d5		;d5=(xa-xb)*(yc-yb)

	sub.l	d4,d5
	bmi	\5		;invisible !!!

	ENDM

DRAW	MACRO
	;OPT	OW-
	ifeq	\1-\2+1
	movem	\1*4+segments.w,d0/d1/d2/d3
	elseif
	movem	\1*4+segments.w,d0/d1
	movem	\2*4+segments.w,d2/d3
	endc
	;OPT	OW+
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
	IFEQ	\1
	or	#%0001*4,planes.w
	ifne	\2+1
	move	#\2,palette+2.w	;couleur 2 change
	endc
	ENDC
	IFEQ	\1-1
	or	#%0010*4,planes.w
	ifne	\2+1
	move.l	#\2<<16+\2,palette+4.w
	endc
	ENDC
	IFEQ	\1-2
	or	#%0100*4,planes.w
	ifne	\2+1
	move.l	#\2<<16+\2,d0
	move.l	d0,palette+8.w
	move.l	d0,palette+12.w
	endc
	ENDC
	IFEQ	\1-3
	or	#%1000*4,planes.w
	ifne	\2+1
	move.l	#\2<<16+\2,d0
	move.l	d0,palette+16.w
	move.l	d0,palette+20.w
	move.l	d0,palette+24.w
	move.l	d0,palette+28.w
	endc
	ENDC
	lea	pointsgauches,a2
	add	d6,a2			;ptr d‚but
	lea	pointsdroits-pointsgauches(a2),a6
	moveq	#-1,d5
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0

	lea	offsetsgauches+CLIPPEGAUCHE*4+XMILIEU*4,a1
	lea	offsetsdroits+(CLIPPEGAUCHE-1)*4+XMILIEU*4,a5
	jsr	(a0)
\@
	ENDM

AFF3	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
	ENDM

AFF4	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
	ENDM

FACE3	MACRO
	TEST	\3,\4,\5,-1,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\3
	AFFPOLY	\1,\2
\@
	ENDM
FACE4	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE5	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE6	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE7	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\3
	AFFPOLY	\1,\2
\@
	ENDM

FACE8	MACRO
	TEST	\3,\4,\5,\6,\@
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	DRAW	\5,\6
	DRAW	\6,\7
	DRAW	\7,\8
	DRAW	\8,\9
	DRAW	\9,\A
	DRAW	\A,\3
	AFFPOLY	\1,\2
\@
	ENDM

INV3	MACRO
	FACE3	\1,\2,\5,\4,\3
	ENDM
INV4	MACRO
	FACE4	\1,\2,\6,\5,\4,\3
	ENDM
INV5	MACRO
	FACE5	\1,\2,\7,\6,\5,\4,\3
	ENDM
INV6	MACRO
	FACE6	\1,\2,\8,\7,\6,\5,\4,\3
	ENDM
INV7	MACRO
	FACE7	\1,\2,\9,\8,\7,\6,\5,\4,\3
	ENDM
INV8	MACRO
	FACE8	\1,\2,\A,\9,\8,\7,\6,\5,\4,\3
	ENDM
;
; structure utilis‚e :
;
;	0.L=liste des coordonn‚es
;	4.L=adresse routine affichage
;	8.L=palette objet
;	12.L=fin
;
; … impl‚menter :
;	- sc‚nario (X,Y,Z) d‚part+arriv‚e+nb images
;	- zoom maximal … stocker
;
NBOBJETS = 13+14
all_objects:
	dc.l	coords_spider,spider,palette1
	dc.l	coords_cube,cube,palette2
	dc.l	coords_tetra,tetraedre,palette3
	dc.l	coords_grille,grille,palette4
	dc.l	coords_spacecraft,spacecraft,palette5

	dc.l	coords_cube2,cube2,palette6
	dc.l	coords_cube3,cube3,palette7
	dc.l	coords_pyramide,pyramide,palette8
	dc.l	coords_carre,carre,palette1
	dc.l	coords_alliance,alliance,palette2
	dc.l	coords_craft,craft,palette3
	dc.l	coords_dodecaedre,dodecaedre,palette4

	dc.l	pspider2,fspider2,palette5
	dc.l	pvcube,fvcube,palette6
	dc.l	prcube,frcube,palette7
	dc.l	pmine,fmine,palette8
	dc.l	ptorus,ftorus,palette1
	dc.l	pchiffre8,fchiffre8,palette2
	dc.l	plettrea,flettrea,palette3
	dc.l	pdalle,fdalle,palette4
	dc.l	puncube,funcube,palette5
	dc.l	pdeuxcube,fdeuxcube,palette6
	dc.l	ppyramide,fpyramide,palette7
	dc.l	pglider2,fglider2,palette8
	dc.l	pdodecaedre,fdodecaedre,palette1
	dc.l	pnscarre,fnscarre,palette2
	dc.l	picosaedre,ficosaedre,palette3

pspider2
	DC.W	12

	DC.W	-15,40,0
	DC.W	15,40,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-50,-30,-50
	DC.W	-50,-50,-50
	DC.W	50,-30,-50
	DC.W	50,-50,-50
	DC.W	5,-80,-20
	DC.W	-5,-80,-20
	DC.W	-10,40,-10
	DC.W	10,40,-10

fspider2

;	ailes dessous

	INV4	0,-1,7,2,11,6
	INV4	0,-1,4,10,3,5

;	cotes

	INV3	1,-1,3,10,9
	INV3	1,-1,11,2,8

;	dessous

	INV4	2,-1,11,8,9,10

;	reacteurs

	INV4	1,-1,10,0,1,11
	INV3	2,-1,6,11,1
	INV3	2,-1,4,0,10

;	dessus

	INV4	2,-1,1,0,3,2

;	ailes dessus

	INV4	3,-1,6,1,2,7
	INV4	3,-1,3,0,4,5

;	cockpit

	INV4	3,-1,2,3,9,8
	RTS

pvcube
	DC.W	8
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

fvcube
	;faces internes

	INV4	0,-1,5,1,0,4
	INV4	0,-1,0,3,7,4
	INV4	1,-1,3,2,6,7
	INV4	1,-1,2,1,5,6

	;faces externes

	INV4	2,-1,5,4,0,1
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	3,-1,2,6,5,1
	rts

prcube
	DC.W	8
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

frcube
	;faces externes

	INV4	0,-1,1,0,3,2
	INV4	1,-1,5,6,7,4
	INV4	2,-1,5,4,0,1
	INV4	0,-1,0,4,7,3
	INV4	1,-1,3,7,6,2
	INV4	2,-1,2,6,5,1
	RTS

BIG	MACRO
	DC.W	\1*2,\2*2,\3*2
	ENDM
pmine
	dc.w	9
	BIG	-10,20,0
	BIG	10,20,0
	BIG	20,10,0
	BIG	20,-10,0
	BIG	10,-20,0
	BIG	-10,-20,0
	BIG	-20,-10,0
	BIG	-20,10,0
	BIG	0,0,30
fmine
	INV3	0,-1,0,1,8
	INV3	1,-1,2,3,8
	INV3	0,-1,4,5,8
	INV3	1,-1,6,7,8
	INV3	2,-1,0,8,1
	INV3	3,-1,2,8,3
	INV3	2,-1,4,8,5
	INV3	3,-1,6,8,7
	rts

ptorus
	dc.w	24

	BIG	-10,20,5
	BIG	10,20,5
	BIG	20,10,5
	BIG	20,-10,5
	BIG	10,-20,5
	BIG	-10,-20,5
	BIG	-20,-10,5
	BIG	-20,10,5

	BIG	-15,35,0
	BIG	15,35,0
	BIG	35,15,0
	BIG	35,-15,0
	BIG	15,-35,0
	BIG	-15,-35,0
	BIG	-35,-15,0
	BIG	-35,15,0

	BIG	-10,20,-5
	BIG	10,20,-5
	BIG	20,10,-5
	BIG	20,-10,-5
	BIG	10,-20,-5
	BIG	-10,-20,-5
	BIG	-20,-10,-5
	BIG	-20,10,-5

ftorus

	;faces internes

	INV4	0,-1,16,0,7,23
	INV4	1,-1,17,1,0,16
	INV4	0,-1,18,2,1,17
	INV4	1,-1,19,3,2,18
	INV4	0,-1,20,4,3,19
	INV4	1,-1,21,5,4,20
	INV4	0,-1,22,6,5,21
	INV4	1,-1,23,7,6,22
	INV4	0,-1,16,0,7,23

	;faces dessus

	INV4	2,-1,0,1,9,8
	INV4	3,-1,1,2,10,9
	INV4	2,-1,2,3,11,10
	INV4	3,-1,3,4,12,11
	INV4	2,-1,4,5,13,12
	INV4	3,-1,5,6,14,13
	INV4	2,-1,6,7,15,14
	INV4	3,-1,7,0,8,15

	;faces dessous

	INV4	2,-1,9,17,16,8
	INV4	3,-1,10,18,17,9
	INV4	2,-1,11,19,18,10
	INV4	3,-1,12,20,19,11
	INV4	2,-1,13,21,20,12
	INV4	3,-1,14,22,21,13
	INV4	2,-1,15,23,22,14
	INV4	3,-1,8,16,23,15
	rts

pchiffre8
	dc.w	14

	BIG	-20,30,0
	BIG	20,30,0
	BIG	-10,20,0
	BIG	10,20,0
	BIG	-10,5,0
	BIG	10,5,0
	BIG	-20,0,0
	BIG	20,0,0
	BIG	-10,-5,0
	BIG	10,-5,0
	BIG	-10,-20,0
	BIG	10,-20,0
	BIG	-20,-30,0
	BIG	20,-30,0

fchiffre8
	INV4	0,-1,1,0,2,3
	INV4	0,-1,0,6,4,2
	INV4	0,-1,1,3,5,7
	INV6	0,-1,5,4,6,8,9,7
	INV4	0,-1,6,12,10,8
	INV4	0,-1,9,11,13,7
	INV4	0,-1,10,12,13,11
	rts

plettrea
	dc.w	11

	BIG	-5,20,5
	BIG	5,20,5
	BIG	0,10,5
	BIG	-8,-5,5
	BIG	8,-5,5
	BIG	-10,-10,5
	BIG	10,-10,5
	BIG	-25,-20,5
	BIG	-15,-20,5
	BIG	15,-20,5
	BIG	25,-20,5

flettrea
	INV4	0,-1,0,7,8,1
	INV4	0,-1,9,10,1,0
	INV4	0,-1,3,5,6,4

	INV4	1,-1,0,1,8,7
	INV4	1,-1,9,0,1,10
	INV4	1,-1,3,4,6,5
	rts

pdalle
	dc.w	4
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0

fdalle
	INV4	0,-1,3,2,1,0
	INV4	1,-1,0,1,2,3
	rts

puncube
	dc.w	8

	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15

funcube
	INV4	0,-1,1,2,6,5
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	1,-1,4,5,6,7
	rts

pdeuxcube
	dc.w	16

	DC.W	-40,40,15
	DC.W	-10,40,15
	DC.W	-10,10,15
	DC.W	-40,10,15
	DC.W	-40,40,-15
	DC.W	-10,40,-15
	DC.W	-10,10,-15
	DC.W	-40,10,-15

	DC.W	10,40,15
	DC.W	40,40,15
	DC.W	40,10,15
	DC.W	10,10,15
	DC.W	10,40,-15
	DC.W	40,40,-15
	DC.W	40,10,-15
	DC.W	10,10,-15

fdeuxcube
	INV4	0,-1,1,2,6,5
	INV4	0,-1,8,12,15,11
	INV4	1,-1,3,2,1,0
	INV4	0,-1,1,5,4,0
	INV4	2,-1,0,4,7,3
	INV4	3,-1,3,7,6,2
	INV4	0,-1,4,5,6,7		;6
	INV4	1,-1,11,10,9,8
	INV4	0,-1,9,13,12,8
	INV4	3,-1,11,15,14,10
	INV4	0,-1,12,13,14,15	;6
	INV4	0,-1,9,10,14,13
	rts

ppyramide
	dc.w	13

	DC.W	-30,30,0
	DC.W	30,30,0
	DC.W	30,-30,0
	DC.W	-30,-30,0
	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20
	DC.W	-15,15,30
	DC.W	15,15,30
	DC.W	15,-15,30
	DC.W	-15,-15,30
	DC.W	0,0,60

fpyramide

	INV4	0,-1,7,6,5,4
	INV4	0,-1,8,9,10,11
	INV4	1,-1,0,1,2,3
	INV3	2,-1,12,9,8
	INV4	2,-1,5,1,0,4
	INV3	3,-1,12,10,9
	INV4	3,-1,6,2,1,5
	INV3	1,-1,12,11,10	;4
	INV4	2,-1,7,3,2,6	;4
	INV3	3,-1,12,8,11	;4
	INV4	1,-1,4,0,3,7	;4
	rts

pglider2
	dc.w	8

	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10

fglider2
	INV4	0,-1,0,4,5,1
	INV3	1,-1,0,2,4
	INV3	1,-1,1,5,3
	INV4	2,-1,0,1,7,6
	INV3	3,-1,0,6,2
	INV3	3,-1,1,3,7
	INV6	2,-1,4,2,6,7,3,5
	rts

DODEC	MACRO
	DC.W	\1/6/2,\2/6/2,\3/6/2
	ENDM

pdodecaedre:
	DC.W	20

	DODEC	283,631,390
	DODEC	458,631,-149
	DODEC	0,631,-482
	DODEC	-458,631,-149
	DODEC	-283,631,390
	DODEC	-458,149,631
	DODEC	0,-149,780
	DODEC	458,149,631
	DODEC	742,-149,241
	DODEC	742,149,-241
	DODEC	458,-149,-631
	DODEC	0,149,-780
	DODEC	-458,-149,-631
	DODEC	-742,149,-241
	DODEC	-742,-149,241
	DODEC	-283,-631,-390
	DODEC	-458,-631,149
	DODEC	0,-631,482
	DODEC	458,-631,149
	DODEC	283,-631,-390

fdodecaedre
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	1,-1,1,9,10,11,2
	INV5	2,-1,2,11,12,13,3
	INV5	3,-1,3,13,14,5,4
	INV5	0,-1,12,15,16,14,13
	INV5	2,-1,14,16,17,6,5
	INV5	3,-1,6,17,18,8,7
	INV5	0,-1,8,18,19,10,9
	INV5	3,-1,11,10,19,15,12
	INV5	1,-1,17,16,15,19,18
	RTS

pnscarre
	DC.W	28

	DC.W	-10,10,-30
	DC.W	10,10,-30
	DC.W	10,-10,-30
	DC.W	-10,-10,-30

	DC.W	-20,20,-20
	DC.W	20,20,-20
	DC.W	20,-20,-20
	DC.W	-20,-20,-20

	DC.W	-30,30,-10
	DC.W	30,30,-10
	DC.W	30,-30,-10
	DC.W	-30,-30,-10

	DC.W	-40,40,0
	DC.W	40,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0

	DC.W	-30,30,10
	DC.W	30,30,10
	DC.W	30,-30,10
	DC.W	-30,-30,10

	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20

	DC.W	-10,10,30
	DC.W	10,10,30
	DC.W	10,-10,30
	DC.W	-10,-10,30

fnscarre:
	INV4	0,-1,3,2,1,0
	INV4	1,-1,7,6,5,4
	INV4	2,-1,11,10,9,8
	INV4	3,-1,15,14,13,12
	INV4	2,-1,19,18,17,16
	INV4	1,-1,23,22,21,20
	INV4	0,-1,27,26,25,24

	;faces autre cote

	INV4	0,-1,24,25,26,27
	INV4	1,-1,20,21,22,23
	INV4	2,-1,16,17,18,19
	INV4	3,-1,12,13,14,15
	INV4	2,-1,8,9,10,11
	INV4	1,-1,4,5,6,7
	INV4	0,-1,0,1,2,3
	RTS
DIM	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM

picosaedre
	DC.W	12

	DIM	89,0,44
	DIM	27,85,44
	DIM	-72,52,44
	DIM	-72,-52,44
	DIM	27,-85,44
	DIM	0,0,100
	DIM	0,0,-100
	DIM	72,52,-44
	DIM	-27,85,-44
	DIM	-89,0,-44
	DIM	-27,-85,-44
	DIM	72,-52,-44
;
; BUG ICOSAEDRE :
;	SOUSTRAIRE 1 A CHAQUE NUMERO DE SOMMET !!!!
;
FAC3	MACRO
	INV3	\1,\2,(\3-1),(\4-1),(\5-1)
	ENDM
ficosaedre:
	FAC3	0,-1,1,2,6
	FAC3	1,-1,2,3,6
	FAC3	2,-1,3,4,6
	FAC3	3,-1,4,5,6
	FAC3	0,-1,5,1,6
	FAC3	1,-1,12,1,5
	FAC3	2,-1,12,8,1
	FAC3	3,-1,8,2,1
	FAC3	0,-1,9,2,8
	FAC3	1,-1,9,3,2
	FAC3	2,-1,9,10,3
	FAC3	3,-1,10,4,3
	FAC3	0,-1,10,11,4
	FAC3	1,-1,11,5,4
	FAC3	0,-1,11,12,5
	FAC3	1,-1,7,8,12
	FAC3	3,-1,7,9,8
	FAC3	0,-1,7,10,9
	FAC3	1,-1,7,11,10
	FAC3	2,-1,7,12,11
	RTS

	ifeq	1
objets:
	DC.L		interph
	DC.L		helice
	DC.L		raie
	DC.L		car
	DC.L		scareface
	DC.L		grille


FACE	MACRO
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM


;---------------------------------------------------

scareface

	DC.L	pscareface
	DC.L	0
	DC.L	scareface
pscareface

	DC.W	-35,10,0
	DC.W	-15,10,0
	DC.W	15,10,0
	DC.W	35,10,0
	DC.W	-25,0,0
	DC.W	-5,0,0
	DC.W	5,0,0
	DC.W	25,0,0
	DC.W	-10,15,5
	DC.W	10,15,5
	DC.W	-35,15,5
	DC.W	35,15,5
	DC.W	-20,30,-5
	DC.W	20,30,-5
	DC.W	-15,-40,-20
	DC.W	15,-40,-20
	DC.W	-40,10,-20
	DC.W	40,10,-20
	DC.W	-15,-40,-40
	DC.W	15,-40,-40
	DC.W	-40,10,-50
	DC.W	40,10,-50

	DC.W	-20,30,-50
	DC.W	20,30,-50

	DC.W	-15,5,-60
	DC.W	15,5,-60


	DC.W	0

	DC.L	fscareface

fscareface


	;yeux

	FACE4	9,-1,1,0,4,5
	FACE4	9,-1,2,6,7,3
	FACE3	2,-1,8,1,5
	FACE3	2,-1,9,6,2
	FACE4	3,-1,10,0,1,8
	FACE4	3,-1,3,11,9,2
	FACE4	4,-1,8,5,6,9
	FACE4	5,-1,12,10,8
	FACE4	5,-1,13,9,11

	;face

	FACE	4,14,15,7
	DC.W	5*8
	DC.L	scarebouche

	FACE3	4,-1,4,0,14
	FACE3	7,-1,16,14,0
	FACE3	4,-1,7,15,3
	FACE3	7,-1,3,15,17
	FACE3	3,-1,16,0,10
	FACE3	3,-1,11,3,17
	FACE3	4,-1,10,12,16
	FACE3	4,-1,11,17,13
	FACE4	3,-1,13,12,8,9
	FACE4	3,-1,14,18,19,15
	FACE4	3,-1,16,20,18,14
	FACE4	3,-1,21,17,15,19
	FACE4	4,-1,22,12,13,23
	FACE4	5,-1,22,20,16,12

	FACE4	5,-1,23,13,17,21
	FACE4	4,-1,22,23,25,24
	FACE3	3,-1,22,24,20
	FACE3	3,-1,23,21,25
	FACE3	2,-1,20,24,18
	FACE3	2,-1,21,19,25
	FACE4	3,-1,24,25,19,18

	DC.W	-1

scarebouche
	DC.W	-10,-20,-10
	DC.W	10,-20,-10
	DC.W	10,-30,-15
	DC.W	-10,-30,-15
	DC.W	0
	FACE4	0,-1,3,2,1,0
	DC.W	-1




;------------------------------------------------------
grille:
	DC.L	pgrille
	DC.L	0
	DC.L	grille

pgrille

	DC.W	-40,-40,0
	DC.W	-20,-40,0
	DC.W	1,-40,0
	DC.W	20,-40,0
	DC.W	40,-40,0
	DC.W	-40,-20,0
	DC.W	-20,-20,0
	DC.W	1,-20,0
	DC.W	20,-20,0
	DC.W	40,-20,0
	DC.W	-40,0,0
	DC.W	-20,0,0
	DC.W	1,0,0
	DC.W	20,0,0
	DC.W	40,0,0
	DC.W	-40,20,0
	DC.W	-20,20,0
	DC.W	1,20,0
	DC.W	20,20,0
	DC.W	40,20,0
	DC.W	-40,40,0
	DC.W	-20,40,0
	DC.W	1,40,0
	DC.W	20,40,0
	DC.W	40,40,0
	DC.W	0

	DC.L	fgrille

fgrille

	FACE4	4,-1,0,5,6,1
	FACE4	3,-1,1,6,7,2
	FACE4	4,-1,2,7,8,3
	FACE4	5,-1,3,8,9,4
	FACE4	3,-1,5,10,11,6
	FACE4	4,-1,6,11,12,7
	FACE4	5,-1,7,12,13,8
	FACE4	2,-1,8,13,14,9
	FACE4	4,-1,10,15,16,11
	FACE4	5,-1,11,16,17,12
	FACE4	2,-1,12,17,18,13
	FACE4	3,-1,13,18,19,14
	FACE4	5,-1,15,20,21,16
	FACE4	2,-1,16,21,22,17
	FACE4	3,-1,17,22,23,18
	FACE4	4,-1,18,23,24,19
	FACE4	2,-1,6,5,0,1
	FACE4	3,-1,7,6,1,2
	FACE4	4,-1,8,7,2,3
	FACE4	5,-1,9,8,3,4
	FACE4	3,-1,11,10,5,6
	FACE4	4,-1,12,11,6,7
	FACE4	5,-1,13,12,7,8
	FACE4	2,-1,14,13,8,9
	FACE4	4,-1,16,15,10,11
	FACE4	5,-1,17,16,11,12
	FACE4	2,-1,18,17,12,13
	FACE4	3,-1,19,18,13,14
	FACE4	5,-1,21,20,15,16
	FACE4	2,-1,22,21,16,17
	FACE4	3,-1,23,22,17,18
	FACE4	4,-1,24,23,18,19
	DC.W	-1


	IFEQ	1

;-----------------------------------------------------------
damier:
	DC.W	-90,-90,0
	DC.W	-70,-90,0
	DC.W	-50,-90,0
	DC.W	-30,-90,0
	DC.W	-10,-90,0
	DC.W	10,-90,0
	DC.W	30,-90,0
	DC.W	50,-90,0
	DC.W	70,-90,0
	DC.W	90,-90,0
	DC.W	-90,-70,0
	DC.W	-70,-70,0
	DC.W	-50,-70,0
	DC.W	-30,-70,0
	DC.W	-10,-70,0
	DC.W	10,-70,0
	DC.W	30,-70,0
	DC.W	50,-70,0
	DC.W	70,-70,0
	DC.W	90,-70,0
	DC.W	-90,-50,0
	DC.W	-70,-50,0
	DC.W	-50,-50,0
	DC.W	-30,-50,0
	DC.W	-10,-50,0
	DC.W	10,-50,0
	DC.W	30,-50,0
	DC.W	50,-50,0
	DC.W	70,-50,0
	DC.W	90,-50,0
	DC.W	-90,-30,0
	DC.W	-70,-30,0
	DC.W	-50,-30,0
	DC.W	-30,-30,0
	DC.W	-10,-30,0
	DC.W	10,-30,0
	DC.W	30,-30,0
	DC.W	50,-30,0
	DC.W	70,-30,0
	DC.W	90,-30,0
	DC.W	-90,-10,0
	DC.W	-70,-10,0
	DC.W	-50,-10,0
	DC.W	-30,-10,0
	DC.W	-10,-10,0
	DC.W	10,-10,0
	DC.W	30,-10,0
	DC.W	50,-10,0
	DC.W	70,-10,0
	DC.W	90,-10,0
	DC.W	-90,10,0
	DC.W	-70,10,0
	DC.W	-50,10,0
	DC.W	-30,10,0
	DC.W	-10,10,0
	DC.W	10,10,0
	DC.W	30,10,0
	DC.W	50,10,0
	DC.W	70,10,0
	DC.W	90,10,0
	DC.W	-90,30,0
	DC.W	-70,30,0
	DC.W	-50,30,0
	DC.W	-30,30,0
	DC.W	-10,30,0
	DC.W	10,30,0
	DC.W	30,30,0
	DC.W	50,30,0
	DC.W	70,30,0
	DC.W	90,30,0
	DC.W	-90,50,0
	DC.W	-70,50,0
	DC.W	-50,50,0
	DC.W	-30,50,0
	DC.W	-10,50,0
	DC.W	10,50,0
	DC.W	30,50,0
	DC.W	50,50,0
	DC.W	70,50,0
	DC.W	90,50,0
	DC.W	-90,70,0
	DC.W	-70,70,0
	DC.W	-50,70,0
	DC.W	-30,70,0
	DC.W	-10,70,0
	DC.W	10,70,0
	DC.W	30,70,0
	DC.W	50,70,0
	DC.W	70,70,0
	DC.W	90,70,0
	DC.W	-90,90,0
	DC.W	-70,90,0
	DC.W	-50,90,0
	DC.W	-30,90,0
	DC.W	-10,90,0
	DC.W	10,90,0
	DC.W	30,90,0
	DC.W	50,90,0
	DC.W	70,90,0
	DC.W	90,90,0
	DC.W	0

	FACE4	3,-1,1,11,12,2
	FACE4	5,-1,3,13,14,4
	FACE4	7,-1,5,15,16,6
	FACE4	9,-1,7,17,18,8
	FACE4	11,-1,10,20,21,11
	FACE4	13,-1,12,22,23,13
	FACE4	15,-1,14,24,25,15
	FACE4	2,-1,16,26,27,17
	FACE4	4,-1,18,28,29,19
	FACE4	6,-1,21,31,32,22
	FACE4	8,-1,23,33,34,24
	FACE4	10,-1,25,35,36,26
	FACE4	12,-1,27,37,38,28
	FACE4	14,-1,30,40,41,31
	FACE4	1,-1,32,42,43,33
	FACE4	3,-1,34,44,45,35
	FACE4	5,-1,36,46,47,37
	FACE4	7,-1,38,48,49,39
	FACE4	9,-1,41,51,52,42
	FACE4	11,-1,43,53,54,44
	FACE4	13,-1,45,55,56,46
	FACE4	15,-1,47,57,58,48
	FACE4	2,-1,50,60,61,51
	FACE4	4,-1,52,62,63,53
	FACE4	6,-1,54,64,65,55
	FACE4	8,-1,56,66,67,57
	FACE4	10,-1,58,68,69,59
	FACE4	12,-1,61,71,72,62
	FACE4	14,-1,63,73,74,64
	FACE4	1,-1,65,75,76,66
	FACE4	3,-1,67,77,78,68
	FACE4	5,-1,70,80,81,71
	FACE4	7,-1,72,82,83,73
	FACE4	9,-1,74,84,85,75
	FACE4	11,-1,76,86,87,77
	FACE4	13,-1,78,88,89,79
	FACE4	15,-1,81,91,92,82
	FACE4	2,-1,83,93,94,84
	FACE4	4,-1,85,95,96,86
	FACE4	6,-1,87,97,98,88
	DC.W	-1


	ENDC



palette
	DC.W	$000,$777,$770,$777,$504,$777,$770,$777
	DC.W	$007,$777,$770,$777,$504,$777,$770,$777
palette2:
	DC.W	$000,$FF0,$013,$024,$035,$046,$057,$700
	DC.W	$720,$740,$760,$770,$212,$434,$656,$777

;--------------------------------------------------------


	EVEN

helice:
	DC.L	phelice1
	DC.L	phelice3
	DC.L	phelice5
	DC.L	phelice7
	DC.L	phelice9
	DC.L	phelice11
	DC.L	phelice13
	DC.L	phelice15
	DC.L	phelice17
	DC.L	phelice19
	DC.L	phelice21
	DC.L	phelice23
	DC.L	phelice25
	DC.L	phelice27
	DC.L	phelice29
	DC.L	0
	DC.L	helice
phelice1
	DC.W	50,5,0
	DC.W	50,-5,0
	DC.W	5,-50,0
	DC.W	-5,-50,0
	DC.W	-50,-5,0
	DC.W	-50,5,0
	DC.W	-5,50,0
	DC.W	5,50,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice3
	DC.W	49,10,0
	DC.W	50,0,0
	DC.W	10,-49,0
	DC.W	1,-50,0
	DC.W	-49,-10,0
	DC.W	-50,0,0
	DC.W	-10,49,0
	DC.W	1,50,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice5
	DC.W	47,15,0
	DC.W	49,5,0
	DC.W	15,-47,0
	DC.W	5,-49,0
	DC.W	-47,-15,0
	DC.W	-49,-5,0
	DC.W	-15,47,0
	DC.W	-5,49,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice7
	DC.W	46,20,0
	DC.W	49,10,0
	DC.W	20,-46,0
	DC.W	10,-49,0
	DC.W	-46,-20,0
	DC.W	-49,-10,0
	DC.W	-20,46,0
	DC.W	-10,49,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice9
	DC.W	43,24,0
	DC.W	47,15,0
	DC.W	24,-43,0
	DC.W	15,-47,0
	DC.W	-43,-24,0
	DC.W	-47,-15,0
	DC.W	-24,43,0
	DC.W	-15,47,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice11
	DC.W	40,29,0
	DC.W	45,20,0
	DC.W	29,-40,0
	DC.W	20,-45,0
	DC.W	-40,-29,0
	DC.W	-45,-20,0
	DC.W	-29,40,0
	DC.W	-20,45,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice13
	DC.W	37,33,0
	DC.W	43,25,0
	DC.W	33,-37,0
	DC.W	25,-43,0
	DC.W	-37,-33,0
	DC.W	-43,-25,0
	DC.W	-33,37,0
	DC.W	-25,43,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice15
	DC.W	33,37,0
	DC.W	40,29,0
	DC.W	37,-33,0
	DC.W	29,-40,0
	DC.W	-33,-37,0
	DC.W	-40,-29,0
	DC.W	-37,33,0
	DC.W	-29,40,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice17
	DC.W	29,40,0
	DC.W	37,33,0
	DC.W	40,-29,0
	DC.W	33,-37,0
	DC.W	-29,-40,0
	DC.W	-37,-33,0
	DC.W	-40,29,0
	DC.W	-33,37,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice19
	DC.W	25,43,0
	DC.W	33,37,0
	DC.W	43,-25,0
	DC.W	37,-33,0
	DC.W	-25,-43,0
	DC.W	-33,-37,0
	DC.W	-43,25,0
	DC.W	-37,33,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice21
	DC.W	20,45,0
	DC.W	29,40,0
	DC.W	45,-20,0
	DC.W	40,-29,0
	DC.W	-20,-45,0
	DC.W	-29,-40,0
	DC.W	-45,20,0
	DC.W	-40,29,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice23
	DC.W	15,47,0
	DC.W	24,43,0
	DC.W	47,-15,0
	DC.W	43,-24,0
	DC.W	-15,-47,0
	DC.W	-24,-43,0
	DC.W	-47,15,0
	DC.W	-43,24,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice25
	DC.W	10,49,0
	DC.W	20,46,0
	DC.W	49,-10,0
	DC.W	46,-20,0
	DC.W	-10,-49,0
	DC.W	-20,-46,0
	DC.W	-49,10,0
	DC.W	-46,20,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice27
	DC.W	5,49,0
	DC.W	15,47,0
	DC.W	49,-5,0
	DC.W	47,-15,0
	DC.W	-5,-49,0
	DC.W	-15,-47,0
	DC.W	-49,5,0
	DC.W	-47,15,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
phelice29
	DC.W	1,50,0
	DC.W	10,49,0
	DC.W	50,0,0
	DC.W	49,-10,0
	DC.W	1,-50,0
	DC.W	-10,-49,0
	DC.W	-50,0,0
	DC.W	-49,10,0
	DC.W	1,0,0
	DC.W	-10,15,-40
	DC.W	10,15,-40
	DC.W	10,-15,-40
	DC.W	-10,-15,-40
	DC.W	0
	DC.L	fhelice
fhelice:

	;helice interne

	FACE3	11,-1,1,8,0
	FACE3	11,-1,7,8,6
	FACE3	11,-1,5,8,4
	FACE3	11,-1,3,8,2

	;face internes

	FACE3	4,-1,9,8,10
	FACE3	4,-1,11,8,12
	FACE3	5,-1,12,8,9
	FACE3	5,-1,10,8,11

	;helice externe

	FACE3	11,-1,0,8,1
	FACE3	11,-1,6,8,7
	FACE3	11,-1,4,8,5
	FACE3	11,-1,2,8,3

	FACE4	6,-1,9,10,11,12

	DC.W	-1


raie:
	DC.L	praie1
	DC.L	praie2
	DC.L	praie3
	DC.L	praie4
	DC.L	praie5
	DC.L	praie6
	DC.L	praie7
	DC.L	praie8
	DC.L	praie9
	DC.L	praie10
	DC.L	praie11
	DC.L	praie12
	DC.L	praie13
	DC.L	praie14
	DC.L	praie15
	DC.L	praie16
	DC.L	praie17
	DC.L	praie18
	DC.L	praie19
	DC.L	praie20
	DC.L	praie21
	DC.L	praie22
	DC.L	praie23
	DC.L	praie24
	DC.L	0
	DC.L	raie
praie1
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-22
	DC.W	-30,10,-9
	DC.W	-30,-10,-9
	DC.W	30,10,-9
	DC.W	30,-10,-9
	DC.W	50,0,-22
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie2
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-23
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-23
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie3
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-24
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-24
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie4
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-25
	DC.W	-30,10,-7
	DC.W	-30,-10,-7
	DC.W	30,10,-7
	DC.W	30,-10,-7
	DC.W	50,0,-25
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie5
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-24
	DC.W	-30,10,-6
	DC.W	-30,-10,-6
	DC.W	30,10,-6
	DC.W	30,-10,-6
	DC.W	50,0,-24
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie6
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-23
	DC.W	-30,10,-5
	DC.W	-30,-10,-5
	DC.W	30,10,-5
	DC.W	30,-10,-5
	DC.W	50,0,-23
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie7
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-22
	DC.W	-30,10,-4
	DC.W	-30,-10,-4
	DC.W	30,10,-4
	DC.W	30,-10,-4
	DC.W	50,0,-22
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie8
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-20
	DC.W	-30,10,-2
	DC.W	-30,-10,-2
	DC.W	30,10,-2
	DC.W	30,-10,-2
	DC.W	50,0,-20
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie9
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-17
	DC.W	-30,10,-1
	DC.W	-30,-10,-1
	DC.W	30,10,-1
	DC.W	30,-10,-1
	DC.W	50,0,-17
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie10
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-15
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-15
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie11
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-12
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-12
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie12
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-10
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-10
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie13
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-7
	DC.W	-30,10,1
	DC.W	-30,-10,1
	DC.W	30,10,1
	DC.W	30,-10,1
	DC.W	50,0,-7
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie14
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-6
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-6
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie15
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie16
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,0
	DC.W	-30,-10,0
	DC.W	30,10,0
	DC.W	30,-10,0
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie17
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-5
	DC.W	-30,10,-1
	DC.W	-30,-10,-1
	DC.W	30,10,-1
	DC.W	30,-10,-1
	DC.W	50,0,-5
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie18
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-6
	DC.W	-30,10,-2
	DC.W	-30,-10,-2
	DC.W	30,10,-2
	DC.W	30,-10,-2
	DC.W	50,0,-6
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie19
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-7
	DC.W	-30,10,-3
	DC.W	-30,-10,-3
	DC.W	30,10,-3
	DC.W	30,-10,-3
	DC.W	50,0,-7
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie20
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-9
	DC.W	-30,10,-5
	DC.W	-30,-10,-5
	DC.W	30,10,-5
	DC.W	30,-10,-5
	DC.W	50,0,-9
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie21
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-12
	DC.W	-30,10,-6
	DC.W	-30,-10,-6
	DC.W	30,10,-6
	DC.W	30,-10,-6
	DC.W	50,0,-12
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie22
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-14
	DC.W	-30,10,-7
	DC.W	-30,-10,-7
	DC.W	30,10,-7
	DC.W	30,-10,-7
	DC.W	50,0,-14
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie23
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-17
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-17
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie
praie24
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	10,-30,0
	DC.W	-10,-30,0
	DC.W	-50,0,-19
	DC.W	-30,10,-8
	DC.W	-30,-10,-8
	DC.W	30,10,-8
	DC.W	30,-10,-8
	DC.W	50,0,-19
	DC.W	1,-25,-10
	DC.W	1,10,-10
	DC.W	1,50,-5
	DC.W	0
	DC.L	fraie


fraie:

	; ailes dessous

	FACE4	3,-1,0,3,6,5
	FACE4	3,-1,7,8,2,1
	FACE3	2,-1,5,6,4
	FACE3	2,-1,9,8,7

	; corps

 	FACE3	1,-1,2,3,10
	FACE4	3,-1,10,3,0,11
	FACE4	3,-1,11,1,2,10
	FACE3	2,-1,12,11,0
	FACE3	2,-1,12,1,11
	FACE3	8,-1,1,12,0

	; dessus

	FACE4	5,-1,3,2,1,0
	FACE4	4,-1,0,5,6,3
	FACE4	4,-1,7,1,2,8
	FACE3	3,-1,5,4,6
	FACE3	3,-1,9,7,8

	DC.W	-1



interph
	DC.L	pinterph0
	DC.L	pinterph1
	DC.L	pinterph2
	DC.L	pinterph3
	DC.L	pinterph4
	DC.L	pinterph5
	DC.L	pinterph6
	DC.L	pinterph7
	DC.L	pinterph8
	DC.L	pinterph9
	DC.L	pinterph10
	DC.L	pinterph11
	DC.L	pinterph12
	DC.L	pinterph13
	DC.L	pinterph14
	DC.L	pinterph15
	DC.L	pinterph16
	DC.L	pinterph17
	DC.L	pinterph18
	DC.L	pinterph19
	DC.L	pinterph20
	DC.L	pinterph19
	DC.L	pinterph18
	DC.L	pinterph17
	DC.L	pinterph16
	DC.L	pinterph15
	DC.L	pinterph14
	DC.L	pinterph13
	DC.L	pinterph12
	DC.L	pinterph11
	DC.L	pinterph10
	DC.L	pinterph9
	DC.L	pinterph8
	DC.L	pinterph7
	DC.L	pinterph6
	DC.L	pinterph5
	DC.L	pinterph4
	DC.L	pinterph3
	DC.L	pinterph2
	DC.L	pinterph1
	DC.L	0
	DC.L	interph
pinterph0
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,10
	DC.W	20,0,10
	DC.W	0
	DC.L	finterph
pinterph1
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,12
	DC.W	20,0,12
	DC.W	0
	DC.L	finterph
pinterph2
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,14
	DC.W	20,0,14
	DC.W	0
	DC.L	finterph
pinterph3
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,16
	DC.W	20,0,16
	DC.W	0
	DC.L	finterph
pinterph4
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,18
	DC.W	20,0,18
	DC.W	0
	DC.L	finterph
pinterph5
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,20
	DC.W	20,0,20
	DC.W	0
	DC.L	finterph
pinterph6
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,22
	DC.W	20,0,22
	DC.W	0
	DC.L	finterph
pinterph7
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,24
	DC.W	20,0,24
	DC.W	0
	DC.L	finterph
pinterph8
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,26
	DC.W	20,0,26
	DC.W	0
	DC.L	finterph
pinterph9
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,28
	DC.W	20,0,28
	DC.W	0
	DC.L	finterph
pinterph10
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,30
	DC.W	20,0,30
	DC.W	0
	DC.L	finterph
pinterph11
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,32
	DC.W	20,0,32
	DC.W	0
	DC.L	finterph
pinterph12
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,34
	DC.W	20,0,34
	DC.W	0
	DC.L	finterph
pinterph13
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,36
	DC.W	20,0,36
	DC.W	0
	DC.L	finterph
pinterph14
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,38
	DC.W	20,0,38
	DC.W	0
	DC.L	finterph
pinterph15
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,40
	DC.W	20,0,40
	DC.W	0
	DC.L	finterph
pinterph16
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,42
	DC.W	20,0,42
	DC.W	0
	DC.L	finterph
pinterph17
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,44
	DC.W	20,0,44
	DC.W	0
	DC.L	finterph
pinterph18
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,46
	DC.W	20,0,46
	DC.W	0
	DC.L	finterph
pinterph19
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,48
	DC.W	20,0,48
	DC.W	0
	DC.L	finterph
pinterph20
	DC.W	-20,10,10
	DC.W	20,10,10
	DC.W	20,-10,10
	DC.W	-20,-10,10
	DC.W	-30,20,0
	DC.W	30,20,0
	DC.W	30,-20,0
	DC.W	-30,-20,0
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	1,0,10
	DC.W	-20,0,50
	DC.W	20,0,50
	DC.W	0
	DC.L	finterph


finterph:
	FACE4	3,-1,3,2,1,0
	FACE4	4,-1,3,7,6,2
	FACE4	4,-1,1,5,4,0
	FACE4	5,-1,0,4,7,3
	FACE4	5,-1,2,6,5,1
	FACE3	9,-1,3,0,8
	FACE3	9,-1,1,2,9
	FACE3	1,-1,10,12,11
	FACE3	1,-1,11,12,10
	FACE3	10,-1,8,0,3
	FACE3	10,-1,9,2,1
	DC.W	-1


;
; objet plus durs … impl‚menter (sous-facettes)
;
ZZCAR	MACRO
	DC.W	\1,\2+100,\3*2/3
	ENDM
ZZROU	MACRO
	DC.W	\1,\2+100,\3*3/4
	ENDM

car:
	DC.L	pcar
	DC.L	0
	DC.L	car

pcar
	; points flanc droit

	ZZCAR	-60,-25,30
	ZZCAR	-60,-25,10
	ZZCAR	-50,-25,3
	ZZCAR	65,-25,3
	ZZCAR	65,-25,10
	ZZCAR	30,-25,30

	; points flanc gauche

	ZZCAR	-60,25,30
	ZZCAR	-60,25,10
	ZZCAR	-50,25,3
	ZZCAR	65,25,3
	ZZCAR	65,25,10
	ZZCAR	30,25,30


	; point cockpit droit bas

	ZZCAR	-45,-25,30
	ZZCAR	-25,-25,30
	ZZCAR	-5,-25,30

	; point cockpit gauche bas

	ZZCAR	-45,25,30
	ZZCAR	-25,25,30
	ZZCAR	-5,25,30

	; point cockpit droit haut

	ZZCAR	-30,-20,45
	ZZCAR	-20,-20,45
	ZZCAR	-10,-20,45

	; point cockpit gauche haut

	ZZCAR	-30,20,45
	ZZCAR	-20,20,45
	ZZCAR	-10,20,45

	DC.W	0

	DC.L	fcar

fcar

	; coffre arriere

	FACE4	3,-1,6,0,12,15

	; lunette arriere

	FACE4	5,-1,18,21,15,12

	; flanc droit

	FACE	5,0,1,2,3,4
	DC.W	2*8
	DC.L	roued

	; flanc gauche

	FACE	7,6,11,10,9,8
	DC.W	2*8
 	DC.L	roueg

	; capot

	FACE4	3,-1,11,5,4,10

	; calandre

	FACE4	4,-1,10,4,3,9

	; feux arriere

	FACE	1,0,6,7
	DC.W	4*8
	DC.L	feuxar

	; bas de caisse arriŠre

	FACE4	5,-1,2,1,7,8

	; pare brise

	FACE4	5,-1,20,5,11,23

	; pare brise droit

	FACE3	4,-1,20,14,5

	; pare brise gauche

	FACE3	4,-1,23,11,17

	; lunette droit

	FACE4	4,-1,18,12,13,19

	; lunette gauche

	FACE4	4,-1,21,22,16,15

	; lunette toit

	FACE4	5,-1,18,19,22,21

	; toit cockpit

	FACE4	3,-1,19,20,23,22

	; cockpit droit

	FACE4	3,-1,13,14,20,19

	; cockpit gauche

	FACE4	3,-1,22,23,17,16

	; bas de caisse

;	FACE4	4,-1,3,2,8,9

	DC.W	-1

feuxar
	ZZCAR	-60,-22,15
	ZZCAR	-60,-22,25
	ZZCAR	-60,22,15
	ZZCAR	-60,22,25
	ZZCAR	-60,-15,15
	ZZCAR	-60,-15,25
	ZZCAR	-60,15,15
	ZZCAR	-60,15,25
	DC.W	0

	FACE4	7,-1,0,1,5,4
	FACE4	7,-1,6,7,3,2
	DC.W	-1


roued
	; roues arriere droite

	ZZROU	-45,-25,0
	ZZROU	-35,-25,0
	ZZROU	-30,-25,5
	ZZROU	-30,-25,15
	ZZROU	-35,-25,20
	ZZROU	-45,-25,20
	ZZROU	-50,-25,15
	ZZROU	-50,-25,5

	ZZROU	-45+70,-25,0
	ZZROU	-35+70,-25,0
	ZZROU	-30+70,-25,5
	ZZROU	-30+70,-25,15
	ZZROU	-35+70,-25,20
	ZZROU	-45+70,-25,20
	ZZROU	-50+70,-25,15
	ZZROU	-50+70,-25,5
	DC.W	0

	FACE8	15,-1,0,1,2,3,4,5,6,7
	FACE8	15,-1,8,9,10,11,12,13,14,15
	DC.W	-1

roueg
	; roues arriere droite

	ZZROU	-45,25,0
	ZZROU	-35,25,0
	ZZROU	-30,25,5
	ZZROU	-30,25,15
	ZZROU	-35,25,20
	ZZROU	-45,25,20
	ZZROU	-50,25,15
	ZZROU	-50,25,5

	ZZROU	-45+70,25,0
	ZZROU	-35+70,25,0
	ZZROU	-30+70,25,5
	ZZROU	-30+70,25,15
	ZZROU	-35+70,25,20
	ZZROU	-45+70,25,20
	ZZROU	-50+70,25,15
	ZZROU	-50+70,25,5
	DC.W	0

	FACE8	15,-1,7,6,5,4,3,2,1,0
	FACE8	15,-1,15,14,13,12,11,10,9,8
	DC.W	-1


	endc


spider:
	FACE3	0,-1,2,0,3
	FACE4	1,-1,0,1,4,3
	FACE3	2,-1,1,5,4
	FACE4	3,-1,2,3,7,6
	FACE4	0,-1,3,4,8,7
	FACE4	1,-1,4,5,9,8
	FACE3	2,-1,6,7,10
	FACE4	3,-1,7,8,11,10
	FACE3	0,-1,8,9,11
	FACE4	1,-1,12,0,2,14
	FACE4	2,-1,12,13,1,0
	FACE4	3,-1,5,1,13,15
	FACE4	0,-1,9,5,15,17
	FACE4	1,-1,11,9,17,19
	FACE4	2,-1,10,11,19,18
	FACE4	3,-1,6,10,18,16
	FACE4	0,-1,2,6,16,14
	FACE4	1,-1,20,21,13,12
	FACE3	2,-1,12,14,20
	FACE3	3,-1,20,14,16
	FACE3	0,-1,20,16,18
	FACE4	1,-1,18,19,21,20
	FACE3	2,-1,21,19,17
	FACE3	3,-1,15,21,17
	FACE3	0,-1,13,21,15
	RTS

spacecraft
	FACE4	0,-1,0,1,4,3	;ABED
	FACE3	1,-1,1,5,4,-1	;BFE
	FACE3	1,-1,0,3,2,-1	;ADC
	FACE3	2,-1,5,1,7,-1	;FBH
	FACE3	2,-1,6,0,2,-1	;GAC
	FACE4	0,-1,6,7,1,0	;GHBA
	FACE4	3,-1,3,4,7,6	;DEHG
	FACE3	0,-1,2,3,6,-1	;CDG
	FACE3	0,-1,4,5,7,-1	;EFH
	RTS
;
; affichage d'un cube
;
cube:
	TEST	0,1,2,3,not0

	AFF4	0,$055,0,1,2,3
	bra	not1
not0
	FACE4	0,$022,7,6,5,4
not1
	TEST	0,3,7,4,not2
	AFF4	1,$066,0,3,7,4
	bra	not3
not2
	FACE4	1,$033,2,1,5,6
not3
	TEST	3,2,6,7,not4
	AFF4	2,$077,3,2,6,7
	bra	not5
not4
	FACE4	2,$044,0,4,5,1
not5
	rts
;
; affichage d'un t‚traŠdre
;
tetraedre:
	FACE3	0,-1,0,2,1
	FACE3	1,-1,0,3,2
	FACE3	2,-1,0,1,3
	FACE3	3,-1,1,2,3
	rts
grille:
	INITDRAW
;	TEST	0,5,6,1,laba0
	TEST	0,20,24,4,laba0

;	AFF4	0,$700,0,20,24,4

	AFF4	0,$700,0,5,6,1
	AFF4	0,-1,8,13,14,9
	AFF4	0,-1,12,17,18,13
	AFF4	0,-1,16,21,22,17

	AFF4	1,$070,1,6,7,2
	AFF4	2,$007,2,7,8,3
	AFF4	3,$777,3,8,9,4
	AFF4	1,-1,5,10,11,6
	AFF4	2,-1,6,11,12,7
	AFF4	3,-1,7,12,13,8
	AFF4	2,-1,10,15,16,11
	AFF4	3,-1,11,16,17,12
	AFF4	1,-1,13,18,19,14
	AFF4	3,-1,15,20,21,16
	AFF4	1,-1,17,22,23,18
	AFF4	2,-1,18,23,24,19
	rts
laba0:
;	AFF4	0,$777,0,4,24,20

	AFF4	0,$777,0,1,6,5
	AFF4	0,-1,8,9,14,13
	AFF4	0,-1,12,13,18,17
	AFF4	0,-1,16,17,22,21

	AFF4	1,$007,1,2,7,6
	AFF4	2,$070,2,3,8,7
	AFF4	3,$700,3,4,9,8
	AFF4	1,-1,5,6,11,10
	AFF4	2,-1,6,7,12,11
	AFF4	3,-1,7,8,13,12
	AFF4	2,-1,10,11,16,15
	AFF4	3,-1,11,12,17,16
	AFF4	1,-1,13,14,19,18
	AFF4	3,-1,15,16,21,20
	AFF4	1,-1,17,18,23,22
	AFF4	2,-1,18,19,24,23
	rts

RED	MACRO
	DC.W	\1/2,\2/2,\3/2
	ENDM
		* Exemple de forme 3D ---> un cube
coords_cube2:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube2:
	INV4	0,-1,4,5,6,7
	INV4	1,-1,7,6,2,3
	INV4	2,-1,0,1,5,4
	INV4	0,-1,4,7,3,0
	INV4	1,-1,1,2,6,5
	INV4	2,-1,3,2,1,0
	RTS

coords_cube3:
	dc.w	8
	RED	-100,-100,-100
	RED	100,-100,-100
	RED	100,100,-100
	RED	-100,100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,100,100
	RED	-100,100,100
cube3:
	INV4	0,-1,3,7,4,0
	INV4	1,-1,0,4,5,1
	INV4	0,-1,1,5,6,2
	INV4	1,-1,2,6,7,3
	INV4	2,-1,0,4,7,3
	INV4	3,-1,1,5,4,0
	INV4	2,-1,2,6,5,1
	INV4	3,-1,3,7,6,2
	RTS

coords_pyramide:
	dc.w	5
	RED	0,150,0
	RED	-100,0,-100
	RED	100,0,-100
	RED	100,0,100
	RED	-100,0,100
pyramide:
	INV3	0,-1,0,2,1
	INV3	1,-1,0,3,2
	INV3	2,-1,0,4,3
	INV3	3,-1,0,1,4
	INV4	0,-1,1,2,3,4
	RTS

coords_carre:
	dc.w	4
	RED	-100,-100,-100
	RED	-100,-100,100
	RED	100,-100,100
	RED	100,-100,-100
carre:
	INV4	0,-1,0,1,2,3
	INV4	0,-1,3,2,1,0
	RTS

coords_alliance:
	dc.w	22		;22 points.
	RED	-32,80,-32	;Points No 0
	RED	-32,80,32	;Points No 1
	RED	32,80,-32	;Points No 2
	RED	32,80,32	;Points No 3
	RED	112,-80,-32	;Points No 4
	RED	112,-80,32	;Points No 5
	RED	48,-80,-32	;Points No 6
	RED	48,-80,32	;Points No 7
	RED	32,-48,-32	;Points No 8
	RED	32,-48,32	;Points No 9
	RED	-32,-48,-32	;Points No 10
	RED	-32,-48,32	;Points No 11
	RED	-48,-80,-32	;Points No 12
	RED	-48,-80,32	;Points No 13
	RED	-112,-80,-32	;Points No 14
	RED	-112,-80,32	;Points No 15
	RED	-16,-16,-32	;Points No 16
	RED	-16,-16,32	;Points No 17
	RED	16,-16,-32	;Points No 18
	RED	16,-16,32	;Points No 19
	RED	0,16,-32	;Points No 20
	RED	0,16,32		;Points No 21

alliance:
	INV4	0,-1,19,21,20,18
	INV4	1,-1,21,17,16,20
	INV4	0,-1,17,19,18,16
	INV4	1,-1,1,3,2,0
	INV4	1,-1,5,7,6,4
	INV4	1,-1,9,11,10,8
	INV4	1,-1,13,15,14,12
	INV4	0,-1,3,5,4,2
	INV4	0,-1,7,9,8,6
	INV4	0,-1,11,13,12,10
	INV4	0,-1,15,1,0,14
	INV4	2,-1,16,18,8,10
;	INV7	2,-1,0,2,20,16,10,12,14
	FACE7	2,-1,20,2,0,14,12,10,16

;	INV6	2,-1,2,4,6,8,18,20
	FACE6	2,-1,6,4,2,20,18,8

	INV4	3,-1,11,9,19,17
;	INV7	3,-1,1,15,13,11,17,21,3
	FACE7	3,-1,13,15,1,3,21,17,11

;	INV6	3,-1,7,5,3,21,19,9
	FACE6	3,-1,3,5,7,9,19,21
	RTS

coords_craft:
	dc.w	14		;14 points.
	RED	0,0,100		;Points No 0
	RED	0,10,10		;Points No 1
	RED	0,-10,10	;Points No 2
	RED	-21,0,10	;Points No 3
	RED	19,0,10		;Points No 4
	RED	0,19,-21	;Points No 5
	RED	0,12,-100	;Points No 6
	RED	0,-6,-100	;Points No 7
	RED	-12,0,-100	;Points No 8
	RED	12,0,-100	;Points No 9
	RED	-165,0,-61	;Points No 10
	RED	-168,0,-85	;Points No 11
	RED	168,0,-85	;Points No 12
	RED	168,0,-61	;Points No 13

craft:
	INV3	0,-1,3,1,5
	INV3	0,-1,1,4,5
	INV3	1,-1,3,0,1
	INV3	2,-1,0,4,1
	INV3	3,-1,2,0,3
	INV3	1,-1,2,4,0
	INV4	1,-1,8,3,5,6
	INV4	2,-1,4,9,6,5
	INV4	3,-1,7,2,3,8
	INV4	1,-1,4,2,7,9
	INV4	0,-1,9,7,8,6
	INV4	0,-1,3,8,11,10
	INV4	0,-1,4,13,12,9
	INV4	0,-1,10,11,8,3
	INV4	0,-1,9,12,13,4
	RTS

DODE	MACRO
	DC.W	\1/8/2,\2/8/2,\3/8/2
	ENDM

coords_dodecaedre
	DC.W	20

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390

dodecaedre:
	INV5	0,-1,0,1,2,3,4
	INV5	1,-1,0,4,5,6,7
	INV5	2,-1,0,7,8,9,1
	INV5	3,-1,1,9,10,11,2
	INV5	0,-1,2,11,12,13,3
	INV5	1,-1,3,13,14,5,4
	INV5	2,-1,12,15,16,14,13
	INV5	3,-1,14,16,17,6,5
	INV5	0,-1,6,17,18,8,7
	INV5	1,-1,8,18,19,10,9
	INV5	2,-1,11,10,19,15,12
	INV5	3,-1,17,16,15,19,18
	RTS

;
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
	lea	hline1(pc),a0
	move	#(hline2-hline1)/2-1,d0
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
PTRGAU	EQUR	a2		;points gauches
PTRDRO	EQUR	a6		;points droits

OFFGAU	EQUR	a1		;offsets gauches
OFFDRO	EQUR	a5		;offsets droits

ADECR	EQUR	a3		;offset ‚cran
SCRATCH	EQUR	a0
XGAU	EQUR	d0
XDRO	EQUR	d1
FFFF	EQUR	d5		;$FFFF
;
; la routine suivante doit faire exactement 128 octets !!!
;
hline1:
	moveq	#-4,XGAU
	and	(PTRGAU)+,XGAU
	moveq	#-4,XDRO
	and	(PTRDRO)+,XDRO

	move.l	(OFFGAU,XGAU.w),XGAU
	move.l	(OFFDRO,XDRO.w),XDRO

	sub	XDRO,XGAU
	bge.s	little_line

	move.l	ADECR,SCRATCH
	add	XDRO,SCRATCH
	swap	XDRO
	or	XDRO,(SCRATCH)
	add	XGAU,SCRATCH
	asr	#1,XGAU
	jmp	loopline+4(pc,XGAU.w)

little_line:
	bne.s	nohline

	and.l	XDRO,XGAU
	swap	XGAU
	or	XGAU,(ADECR,XDRO.w)
	bra.s	nohline
x	set	18*8
	rept	18
	move	FFFF,x(SCRATCH)
x	set	x-8
	endr
loopline:
	swap	XGAU
	or	XGAU,(SCRATCH)
nohline:
	lea	160(ADECR),ADECR
hline2:
;
; PORTION DE CODE EFFECTUANT LES PROJECTIONS DES POINTS
;

NXTANG	MACRO
	CLR	D0		;and 255
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
	LEA	MATRICE\W,a2
	move.l	a2,usp

	MOVE	CY,D0
	MULS	CZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(a2)+	;CY*CZ

	MOVE	CY,D0
	MULS	SZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,A3
	MULS	CX,D0
	MOVE	SX,D1
	MULS	SY,D1
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A2)+	;-(CY*SZ*CX+SX*SY)

	MOVE	A3,D0		;CY*SZ
	MULS	SX,D0
	MOVE	SY,D1
	MULS	CX,D1
	SUB.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A2)+	;CY*SZ*SX-SY*CX

	MOVE	SZ,(A2)+	;SZ

	MOVE	CZ,D0
	MULS	CX,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A2)+	;CX*CZ

	MOVE	CZ,D0
	MULS	SX,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A2)+	;-SX*CZ

	MULS	SY,CZ
	ADD.L	CZ,CZ
	SWAP	CZ
	MOVE	CZ,(A2)+	;SY*CZ

	MULS	SZ,SY
	ADD.L	SY,SY
	SWAP	SY

	MOVE	CY,D0
	MULS	SX,D0
	MOVE	SY,D1
	MULS	CX,D1
	SUB.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A2)+	;CY*SX-SY*SZ*CX

	MULS	SY,SX
	MULS	CY,CX
	ADD.L	SX,CX
	ADD.L	CX,CX
	SWAP	CX
	MOVE	CX,(A2)+	;SY*SZ*SX+CY*CX
;
	move	#320,A3		;xmin
	SUB	A4,A4		;xmax
	move	#nblig-1,A5	;ymin
	SUB	A6,A6		;ymax

	MOVE	DIST\W,D4
modif1	JSR	FASTCALC

	MOVE	A3,D0
	ASR	#2,D0
	ADD	#XMILIEU,D0
	BPL.S	.1
	CLR	D0
.1	MOVE	D0,A3

	MOVE	A4,D0
	ASR	#2,D0
	ADD	#XMILIEU,D0
	CMP	#320,D0
	BLO.S	.2
	MOVE	#320-1,D0
.2	MOVE	D0,A4

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
; d0/d1/d2/d3/d6/d7 scratch‚s
; d4=zoom
; D5=NON SCRATCHE !!!!
;
CALCUL:
	MOVE.L	usp,A2
	MOVEM	(A0)+,D1/D2/D3

	MOVE	D1,D6
	MULS	(A2)+,D6	;X
	MOVE	D2,D0
	MULS	(A2)+,D0
	ADD.L	D0,D6
	MOVE	D3,D0
	MULS	(A2)+,D0
	ADD.L	D0,D6

	MOVE	D1,D7
	MULS	(A2)+,D7	;Y
	MOVE	D2,D0
	MULS	(A2)+,D0
	ADD.L	D0,D7
	MOVE	D3,D0
	MULS	(A2)+,D0
	ADD.L	D0,D7

	MULS	(A2)+,D1	;Z
	MULS	(A2)+,D2
	ADD.L	D2,D1
	MULS	(A2)+,D3
	ADD.L	D3,D1

	SWAP	D1
	SUB	d4,D1

	ifeq	1
	CMP	MIN,D1
	BGE.S	.NOTMIN
	MOVE	D1,MIN
.NOTMIN
	CMP	MAX,D1
	BLE.S	.NOTMAX
	MOVE	D1,MAX
.NOTMAX
	ENDC

	ASR.L	#8,D6		;X*4
	ASR.L	#8,D7

	DIVS	D1,D6
	DIVS	D1,D7

	add	d6,d6
	add	d6,d6
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
	sub	d1,d5		;d5=nb pixels … effacer (multiple de 16)
	ble.s	.nocls
	asr	#1,d1
	move.l	usp,a6
	add	d1,a6

	lea	MUL160.W,A1

	moveq	#0,d0
	lsr	#2,d5		;nbpixels … effacer/4
	move	rsplanes(a0),d1
	jmp	.fcls(pc,d1.w)
.fcls:
.nocls:	rts
	NOP
	BRA.W	PLAN0001	;ok
	BRA.W	PLAN0010	;ok
	BRA.W	PLAN0011	;ok
	BRA.W	PLAN0100	;ok
	BRA.W	PLAN0101	;OK
	BRA.W	PLAN0110	;ok
	BRA.W	PLAN0111	;OK
	BRA.W	PLAN1000	;ok
	BRA.W	PLAN1001
	BRA.W	PLAN1010	;OK
	BRA.W	PLAN1011	;OK
	BRA.W	PLAN1100	;ok
	BRA.W	PLAN1101	;OK
	BRA.W	PLAN1110	;OK
;	BRA.W	PLAN1111	;OK

PLAN1001:

PLAN0101:
PLAN0111:
PLAN1010:
PLAN1011:
PLAN1101:
PLAN1110:
PLAN1111:
	lea	PUSHCLS-4\W,A0
	move.l	(a0,d5.w),a0

	cmp	#240/4,d5
	bhs.s	.fasteff

	sub	d6,d7

	add	d6,d6
	add	(a1,d6.w),a6

	ADD	D7,D7
	ADD	D7,D7
	pea	(a0,d7.w)

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
.fasteff
	move	d7,d2
	add	d2,d2
	add	(a1,d2.w),a6
	lea	160(a6),a6

	sub	d6,d7
	ADD	D7,D7
	ADD	D7,D7
	pea	(a0,d7.w)

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

	;opt	ow-
PLAN1000:ADDQ	#2,A6
PLAN0100:ADDQ	#2,A6
PLAN0010:ADDQ	#2,A6
PLAN0001:
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	add	(a1,d6.w),a6
	JMP	.ONEPLANE-4(PC,D5.W)
.ONEPLANE
	bra.w	.eff16
	bra.w	.eff32
	bra.w	.eff48
	bra.w	.eff64
	bra.w	.eff80
	bra.w	.eff96
	bra.w	.eff112
	bra.w	.eff128
	bra.w	.eff144
	bra.w	.eff160
	bra.w	.eff176
	bra.w	.eff192
	bra.w	.eff208
	bra.w	.eff224
	bra.w	.eff240
	bra.w	.eff256
	bra.w	.eff272
	bra.w	.eff288
	bra.w	.eff304
	bra.w	.eff320
	DCB.W	10,$4AFC
.eff16
	move	d0,(a6)
	lea	160(a6),a6
	dbra	d7,.eff16
	rts
.eff32
	move	d0,(a6)
	move	d0,8(a6)
	lea	160(a6),a6
	dbra	d7,.eff32
	rts
.eff48
x	set	0
	rept	3
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff48
	rts
.eff64
x	set	0
	rept	4
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff64
	rts
.eff80
x	set	0
	rept	5
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff80
	rts
.eff96
x	set	0
	rept	6
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff96
	rts
.eff112
x	set	0
	rept	7
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff112
	rts
.eff128
x	set	0
	rept	8
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff128
	rts
.eff144
x	set	0
	rept	9
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff144
	rts
.eff160
x	set	0
	rept	10
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff160
	rts
.eff176
x	set	0
	rept	11
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff176
	rts
.eff192
x	set	0
	rept	12
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff192
	rts
.eff208
x	set	0
	rept	13
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff208
	rts
.eff224
x	set	0
	rept	14
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff224
	rts
.eff240
x	set	0
	rept	15
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff240
	rts
.eff256
x	set	0
	rept	16
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff256
	rts
.eff272
x	set	0
	rept	17
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff272
	rts
.eff288
x	set	0
	rept	18
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff288
	rts
.eff304
x	set	0
	rept	19
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff304
	rts
.eff320
x	set	0
	rept	20
	move	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff320
	rts

PLAN1100:
;	BRA	PLAN1111
	CMP	#128/4,D5
	BLO	PLAN1111
	ADDQ	#4,A6
	BRA.S	PLAN00111
PLAN0110:
;	BRA	PLAN1111
	CMP	#128/4,D5
	BLO	PLAN1111
	ADDQ	#2,A6
	BRA.S	PLAN00111
PLAN0011:
;	BRA	PLAN1111
	CMP	#128/4,D5
	BLO	PLAN1111
PLAN00111
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	add	(a1,d6.w),a6
	JMP	.TWOPLANES-4(PC,D5.W)
.TWOPLANES
	bra.w	.eff16
	bra.w	.eff32
	bra.w	.eff48
	bra.w	.eff64
	bra.w	.eff80
	bra.w	.eff96
	bra.w	.eff112
	bra.w	.eff128
	bra.w	.eff144
	bra.w	.eff160
	bra.w	.eff176
	bra.w	.eff192
	bra.w	.eff208
	bra.w	.eff224
	bra.w	.eff240
	bra.w	.eff256
	bra.w	.eff272
	bra.w	.eff288
	bra.w	.eff304
	bra.w	.eff320
	DCB.W	10,$4AFC
.eff16
	move.l	d0,(a6)
	lea	160(a6),a6
	dbra	d7,.eff16
	rts
.eff32
	move.l	d0,(a6)
	move.l	d0,8(a6)
	lea	160(a6),a6
	dbra	d7,.eff32
	rts
.eff48
x	set	0
	rept	3
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff48
	rts
.eff64
x	set	0
	rept	4
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff64
	rts
.eff80
x	set	0
	rept	5
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff80
	rts
.eff96
x	set	0
	rept	6
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff96
	rts
.eff112
x	set	0
	rept	7
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff112
	rts
.eff128
x	set	0
	rept	8
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff128
	rts
.eff144
x	set	0
	rept	9
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff144
	rts
.eff160
x	set	0
	rept	10
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff160
	rts
.eff176
x	set	0
	rept	11
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff176
	rts
.eff192
x	set	0
	rept	12
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff192
	rts
.eff208
x	set	0
	rept	13
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff208
	rts
.eff224
x	set	0
	rept	14
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff224
	rts
.eff240
x	set	0
	rept	15
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff240
	rts
.eff256
x	set	0
	rept	16
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff256
	rts
.eff272
x	set	0
	rept	17
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff272
	rts
.eff288
x	set	0
	rept	18
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff288
	rts
.eff304
x	set	0
	rept	19
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff304
	rts
.eff320
x	set	0
	rept	20
	move.l	d0,x(a6)
x	set	x+8
	endr
	lea	160(a6),a6
	dbra	d7,.eff320
	rts
	;opt	ow+

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
;
; routine de calcul des points d'un polygone !!!!
;
MINY		equr		D6	;r‚serv‚s dans tous le calcul
MAXY		equr		D7

XA		equr		D0	;extremit‚s de la droite
YA		equr		D1
XB		equr		D2
YB		equr		D3

RETOUR		equr		A1	;adresse de retour droite

PTRY		equr		A0	;pointeur tabley

REGDATA		equr		D4
DX		EQUR		D5

;-------------- cas d'une ligne verticale -----------------------


		REPT	nblig
		MOVE	XA,(PTRY)+	;mise en place nouveau points
		ENDR
affvert
retourvert
		JMP	(RETOUR)

vertline
	; clipping
		CMP	#nblig,YA
		BLO.S	.YAsup0
		BGE.S	retourvert
		moveq	#0,YA
.YAsup0
		CMP	#nblig,YB
		BLO.S	.YBinfmax
		BLT.S	retourvert
		MOVE	#nblig-1,YB
.YBinfmax
		cmp	MINY,YA		;tester minimum
		bhs.s	.pasminimum
		move	YA,MINY
.pasminimum
		cmp	MAXY,YB		;tester maximum
		bls.s	.pasmaximum
		move	YB,MAXY
.pasmaximum
		SUB	YA,YB

		ADD	YA,YA
		ADD	YA,PTRY

		ADD	YB,YB
		NEG	YB
;		ADD	#calcretour-calcretour2-2,YB
;		JMP	calcretour2(PC,YB.W)
;		ADD	#calcretour-calcretour2-2,YB
		JMP	affvert-2(PC,YB.W)
calcretour				;fin du calcul des points
		jmp	(RETOUR)

;-------------- d‚but calcul d'une ligne -------------------------

drawline:
	lea	pointsgauches.w,PTRY
;	clr	$144.w		;flag clipping Y
;	movem	XA/YA/XB/YB,$146.W

		cmp	YA,YB
		beq.s	calcretour	;ligne horizontale
		bge.s	.YBsupYA

		exg	XA,XB		;echange les points
		exg	YA,YB

		lea	nblig*2(PTRY),PTRY	;c'est une ligne montante
.YBsupYA
;	move	XB,$142.W	;x arriv‚e !!!

		sub	XA,XB		;DX

		beq.s	vertline

		move	YB,REGDATA
		sub	YA,REGDATA	;DY
	MOVE	XB,DX

		ext.l	XB		;calcul de la pente
		asl.l	#8-2,XB		;DX*256

		divs	REGDATA,XB	;divise par DY
		bvc.s	.nodeborde
		asr.l	#6,XB
		divs	REGDATA,XB
		bvc.s	.okdeb
		addq	#7,$ffff8240.w
.okdeb
		SWAP	XB
		CLR	XB
		bra.s	.skipex
.nodeborde
		ext.l	XB
		asl.l	#8,XB		;recuperation virgule 1/256eme
		add.l	XB,XB
		add.l	XB,XB
.skipex

		CMP	#nblig,YA
		BLO.S	.YAsup0
		BGE.S	calcretour
		muls	DX,YA
		divs	REGDATA,YA
		sub	YA,XA
		moveq	#0,YA
		move	YB,REGDATA
;	addq	#1,$144.w
.YAsup0
		CMP	#nblig,YB
		BLO.S	.YBinfmax
		BLT.S	calcretour
		move	#nblig-1,YB
		move	YB,REGDATA
		sub	YA,REGDATA	;DY
;	addq	#1,$144.w
.YBinfmax
;------------ mise a jour des maximums et minimum ----------

		cmp	MINY,YA		;tester minimum
		bhs.s	.pasminimum
		move	YA,MINY
.pasminimum
		cmp	MAXY,YB		;tester maximum
		bls.s	.pasmaximum
		move	YB,MAXY
.pasmaximum

		add	YA,YA		;adresse tableau lignes
		add	YA,PTRY

		add	REGDATA,REGDATA	;offset pour le saut
		add	REGDATA,REGDATA
		neg	REGDATA

	swap	XA
	move	XB,XA
	beq	lineentier
	add	#.jmpline2-.jmpline1,REGDATA

	swap	XA
	swap	XB		;poids fort = virgule*4
				;poids faible = partie entiere*4
	addq	#2,XA		;X+1/2

	jmp	.jmpline1(PC,REGDATA.W)
.jmpline1
		REPT	nblig-1
		MOVE	XA,(PTRY)+
		ADDX.L	XB,XA
		ENDR
.jmpline2
jmpline
		MOVE	XA,(PTRY)

;	tst	$144.w
;	bne.s	.OK
;	move	$142.w,YA
;	eor	XA,YA
;	and	#-4,YA
;	BEQ.S	.OK
;	ADDQ	#7,$FFFF8240.W
;.OK
		jmp	(RETOUR)

;---------- cas d'une ligne … coefficient entier -----------

lineentier:
	swap	XA
	swap	XB

		ADD	#.lineent3-.lineent2,REGDATA
		JMP	.lineent2(PC,REGDATA.W)

.lineent2
		REPT	nblig-1
		MOVE	XA,(PTRY)+
		ADD	XB,XA
		ENDR
.lineent3
		MOVE	XA,(PTRY)

		JMP	(RETOUR)


genereline
	lea	offsetsgauches,a0
	move	#CLIPPEGAUCHE-1,d0
.fil1	move.l	#$ffff0000,(a0)+
	dbra	d0,.fil1

	moveq	#0,d6
genleft1:
	moveq	#-1,d7
genleft2:
	move	d7,(a0)+
	move	d6,(a0)+
	lsr	#1,d7
	bne.s	genleft2	;ou BCS
	addq	#8,d6
	cmp	#160,d6
	blo.s	genleft1

	move	#CLIPPEDROITE-1,d0
.fil2	move.l	#$00000000+160,(a0)+	;pour empecher tout affichage !!!
	dbra	d0,.fil2

	lea	offsetsdroits,a0

	move	#CLIPPEGAUCHE-1,d0
.fil1	move.l	#$fffffff8,(a0)+	;pour empecher tout affichage !!!
	dbra	d0,.fil1

	moveq	#0,d6
genrgt1:
	move	#$8000,d7
genrgt2:
	move	d7,(a0)+
	move	d6,(a0)+
	asr	#1,d7
	bcc.s	genrgt2
	addq	#8,d6
	cmp	#160,d6
	blo.s	genrgt1

	move	#CLIPPEDROITE-1,d0
.fil2	move.l	#$ffff0000+160-8,(a0)+
	dbra	d0,.fil2
	rts

	section	data

XYZ	MACRO
	DC.W	\1*10,\2*10,\3*20
	ENDM

coords_spacecraft
	DC.W	8
	XYZ	-2,5,0
	XYZ	2,5,0
	XYZ	-6,-5,0
	XYZ	-2,-5,1
	XYZ	2,-5,1
	XYZ	6,-5,0
	XYZ	-2,-5,-1
	XYZ	2,-5,-1

coords_spider
	DC.W	22
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
	dc.w	0,50,0
	dc.w	43,-25,0
	dc.w	-43,-25,0
	dc.w	0,0,50

;	dc.w	0,50,0
;	dc.w	-50,-50,-50
;	dc.w	50,-50,-50
;	dc.w	0,-50,50

;	dc.w	50,0,0
;	dc.w	-25,37,-22
;	dc.w	-26,-37,21
;	dc.w	0,0,-50

;	dc.w	100/2,0,0
;	dc.w	14/2,-99/2,0
;	dc.w	-7/2,-99/2,12/2
;	dc.w	-7/2,-99/2,-12/2

;	dc.w	0,50,0
;	dc.w	-43,-25,-25
;	dc.w	43,-25,-25
;	dc.w	0,-25,25

coords_grille:
	DC.W	25
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

TEXTE1:	INCBIN	MESSAGE.BIN
	DC.W	-1
TEXTE2:	ds.b	38
	INCBIN	MESS2.BIN
FONTE:	DS.B	8
fonte:	incbin	fonte3.img
FINFONTE:
LA2E:	INCBIN	ATOMIX.PAK

	ifeq	DEBUG
debugger:incbin	debugger.bin
	endc

	SECTION	BSS
	ds.l	50
pile:
firstpal:ds.b	32*NBSCR

fast_draw:ds.b	(hline2-hline1)*nblig+2
findraw:

FASTCALC
	DS.B	(FINCALCUL-CALCUL)*nbpts+2
FINFASTCALC

FASTCLS:
	ds.b	56764		;62720		;juste ??
FINFASTCLS:

PREDEC:	DS.B	2*4*(16/STEP)*(LONGFONTE)
FINPREDEC:
L6ECC:	DS.B	(16/STEP)*TAILLE*80	;BUFFER POUR SCROLLER


offsetsgauches
	ds.l	CLIPPEGAUCHE
	ds.l	320
	ds.l	CLIPPEDROITE
offsetsdroits
	ds.l	CLIPPEGAUCHE
	ds.l	320
	ds.l	CLIPPEDROITE
fincode:
