	opt	o+,ow2-
	OUTPUT	DEMO.PRG
;
; effacement minimal … impl‚menter !!!!!
;
;	opt	ow1+	;branch made short
;	opt	ow2+	;offset removed
;	opt	ow3+	;short word
;	opt	ow4+	;moveq substitued
;	opt	ow5+	;quick form used
;	opt	ow6+	;could be short
;	opt	ow7+	;branch to nop
;
; … faire :
;	- boucle de calcul … d‚velopper (la doubler...)
;	- voir TRAPV
;	- rentrer les matrices avec X=0,Y=0,Z=0
;	- comment calculer polygones r‚guliers ?
;	- revoir calcul de la matrice !!!
;	- quand toutes les droites sont horizontales que faire ????
;	- damier … moiti‚ vide ou disym‚trique
;	- rentrer t‚traŠdre
;	- entrer calcul incr‚mental des positions
;	  (+sc‚nario afin d'exploiter cet avantage !!!)
;	- objets transparents
;	- gestion multi‚crans … d‚bugger avec rasters en bas
;
MUS = 0		;1
NEXT	MACRO
	move	(a4)+,a0
	jmp	(a0)
	ENDM
XMILIEU = 320/2
DEBUG = 0			;0=debugger
NBSCR = 10
nbpts = 30		;25 si pas nscarre
nblig = 200
PROF = 1
CLIPPEGAUCHE = 1024
CLIPPEDROITE = 1024
;
; POINT DE ROTATION : (0,0,100)
;
	offset	$800
pointsdroits:ds.w	nblig	;points qui descendent
pointsgauches:ds.w	nblig	;points qui montent

	DS.W	10
MUL160	DS.W	nblig
	DS.W	10
curobj:	ds.w	1
sync:	ds.w	1
PUSHD0:	DS.W	1
obsx:	ds.w	1
obsy:	ds.w	1
obsz:	ds.w	1
cptscen:ds.w	1
transx:	ds.w	1
transy:	ds.w	1
transz:	ds.w	1
axex:	ds.w	1
axey:	ds.w	1
axez:	ds.w	1
revolx:	ds.w	1
revoly:	ds.w	1
revolz:	ds.w	1
MATRICE:DS.W	9
	ds.l	2	;translation
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
flagscen:ds.b	1
	EVEN
ptscen:	ds.l	1

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
	org	$4000
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
;	move.b	#$40,$fffffa17.w
;	move.l	#hbl,$120.w
;	or.b	#1,$fffffa07.w
;	or.b	#1,$fffffa13.w

	lea	pile,sp		;super stack

	moveq	#NBSCR-1,d0
	lea	$80000,a0
	lea	ptrscr.w,a1
	lea	firstpal,a2
.genit
	lea	-32000(a0),a0
	move.l	a0,(a1)+
	move	#160,(a1)+
	move	#160,(a1)+
;	move	#160,(a1)
;	move	(a1)+,(a1)+
	move	#nblig/2,(a1)+
	move	#nblig/2,(a1)+
;	move	#nblig/2,(a1)
;	move	(a1)+,(a1)+
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
	move.l	#ptrscr,ptwr.w
	move.l	#ptrscr,ptrd.w
	move.l	a0,lastecran.w
	clr	nbimages.w

	lea	$80000,a1
	moveq	#0,d1
.cls
	move.l	d1,(a0)+
	cmp.l	a1,a0
	blo.s	.cls

	lea	MUL160-20.W,A0
	move	#nblig+20-1,d0
.fil160	move	#-1,(a0)+
	dbra	d0,.fil160

	moveq	#0,d0
	lea	MUL160.W,A0
.mul160	move	d0,(a0)+
	add	#160,d0
	cmp	#nblig*160,d0
	blo.s	.mul160

	bsr	gendraw
	bsr	genereline
	bsr	genere_cls
	clr.b	flagscen.w
	bsr	initscenario

	IFNE	MUS
	LEA	MUZAK,A0
	MOVEQ	#MUS,D0
	bsr	musique
	ENDC
	move.l	#vbl,$70.w
	move	#$2300,sr
	clr	sync.w
.vbl1	tst	sync.w
	beq.s	.vbl1
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	move.l	#prg_sur_vbl,$70.w
	move.l	#bugpal,lastpal.w
	clr	curobj.w
	clr.b	latchkey.w
	ST	cheat.w		;TRICHONS UN PEU

	move.b	#50,cptvbl.w
	clr.b	numsec.w
	clr.b	latchnum.w

CLRALL	MACRO
	CLR.B	ROTX.W
	CLR.B	ROTY.W
	CLR.B	ROTZ.W
	ENDM
	move.l	#divs0,$14.w
	move.b	#1,ROTATEX.w
	move.b	#2,ROTATEY.W
	move.b	#3,ROTATEZ.W
	clr	obsx.w
	clr	obsy.w
	clr	obsz.w
	clr	axex.w
	clr	axey.w
	clr	axez.w
	MOVE	#$60,DIST.w
	CLRALL

demo
	clr	d0
	move.b	$fffffc02.w,d0

	ifeq	DEBUG
	cmp.b	#$1d,latchkey.w
	bne.s	.paquit
	cmp.b	#$2e,d0
	bne.s	.paquit
	clr.l	$426.w
	move.l	4.w,a0
	jmp	(a0)
.paquit
	endc

	cmp.b	#$24,latchkey.w
	bne.s	.nocheat
	cmp.b	#$2e,d0
	bne.s	.nocheat
	st	cheat.w
.nocheat

	cmp.b	#$6d,d0
	beq.s	.gau
	cmp.b	#$67,d0
	beq.s	.gau
	cmp.b	#$6a,d0
	bne.s	.nogau
.gau	addq	#1,obsx.w
.nogau
	cmp.b	#$69,d0
	beq.s	.dro
	cmp.b	#$6f,d0
	beq.s	.dro
	cmp.b	#$6c,d0
	bne.s	.nodro
.dro	subq	#1,obsx.w
.nodro
	cmp.b	#$67,d0
	beq.s	.up
	cmp.b	#$69,d0
	beq.s	.up
	cmp.b	#$68,d0
	bne.s	.noup
.up	addq	#1,obsy.w
.noup
	cmp.b	#$6d,d0
	beq.s	.dn
	cmp.b	#$6f,d0
	beq.s	.dn
	cmp.b	#$6e,d0
	bne.s	.nodwn
.dn	subq	#1,obsy.w
.nodwn


	cmp.b	latchkey.w,d0
	bne.s	.diffkey
	subq	#1,repeat.w
	bne	.nokey
	move	#4,repeat.w
	bra.s	.samekey
.diffkey
	move	#10,repeat.w
.samekey
	move.b	d0,latchkey.w
	bmi	.nokey

	tst.b	cheat.w
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
	move.b	#1,ROTATEX.w	;Backspace
	move.b	#2,ROTATEY.W
	move.b	#3,ROTATEZ.W
	MOVE	#$60,DIST.w
	clr	obsx.w
	clr	obsy.w
	clr	obsz.w
	clr	axex.w
	clr	axey.w
	clr	axez.w
	CLRALL
.0
	cmp.b	#$50,d0		;flŠche bas
	bne.s	.1
	addq.b	#1,ROTATEX.W
	CLRALL
.1
	cmp.b	#$48,d0		;flŠche haut
	bne.s	.2
	subq.b	#1,ROTATEX.W
	CLRALL
.2
	cmp.b	#$47,d0		;INSERT
	bne.s	.3
	subq.b	#1,ROTATEZ.W
	CLRALL
.3
	cmp.b	#$52,d0		;CLR-HOME
	bne.s	.4
	addq.b	#1,ROTATEZ.W
	CLRALL
.4
	cmp.b	#$4b,d0		;flŠche gauche
	bne.s	.5
	subq.b	#1,ROTATEY.W
	CLRALL
.5
	cmp.b	#$4d,d0		;flŠche droite
	bne.s	.6
	addq.b	#1,ROTATEY.W
	CLRALL
.6
	cmp.b	#$62,d0		;HELP
	bne.s	.7
	CMP	#PROF,DIST.w
	BLS.S	.7
	subq	#PROF,DIST.w
.7
	cmp.b	#$61,d0		;UNDO
	bne.s	.8
	ADDQ	#PROF,DIST.w
.8
	cmp.b	#$1c,d0
	bne.s	.noscen
	not.b	flagscen.w
	bsr	initscenario
.noscen
.nokey
;	subq.b	#2,d0
;	cmp	#8,d0
;	bhs.s	.nochg
;	add	d0,d0
;	add	d0,d0
;	move	d0,curobj.w
;	CLRALL
;.nochg
	move.l	ptwr.w,a0
	move.l	rsecran(a0),a1
	tst	nbimages.w
	beq.s	.ok
	move	#$2700,sr
	cmp.l	lastecran.w,a1
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

	cmp.b	#$1d,$fffffc02.w
	bne.s	.nocrl1
	move	#$700,$ffff8240.w
.nocrl1
	bsr	cls
	clr	$ffff8240.w
	bsr	scenario

	MOVE	curobj.w,D0		;NUMERO DE L'OBJET*4
	lea	all_objects(pc),a0
	move.l	8(a0,d0.w),a2		;palette
	movem.l	(a2)+,d1-d7/a1
	movem.l	d1-d7/a1,palette.w
	move.l	0(a0,d0.w),a0		;adresse des points

	lea	segments.w,a1

	CMP.B	#$39,$FFFFFC02.W
	BNE.S	.NOCPU
	MOVE	#$555,$FFFF8240.W
.NOCPU
CALC
	BSR	CALCOBJ

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
	move.l	ptwr.w,a0
	MOVEM	A3/A4/A5/A6,rsxmin(a0)
	CLR	$FFFF8240.W

	move.l	rsecran(a0),a1
	move.l	a1,usp

	MOVE	curobj.w,D0		;NUMERO DE L'OBJET*4
	lea	all_objects(pc),a0
	move.l	4(a0,d0.w),a4		;routine de branchement
	clr	planes.w
	lea	offsetsgauches+CLIPPEGAUCHE*4+XMILIEU*4,a5
	lea	offsetsdroits+(CLIPPEGAUCHE-1)*4+XMILIEU*4,a6

	cmp.b	#$1d,$fffffc02.w
	bne.s	.nocrl2
	move	#$007,$ffff8240.w
.nocrl2
	NEXT
prg_rts
	clr	$ffff8240.w
	move.l	ptwr.w,a0
	move	planes.w,rsplanes(a0)
	move.l	rspal(a0),a1
	movem.l	palette.w,d0-d7
	movem.l	d0-d7,(a1)

	tst.b	cheat.w
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
	move.l	ptwr.w,a0
	lea	rslong(a0),a0
	cmp.l	#finscr,a0
	blo.s	.lowup
	lea	ptrscr.w,a0
.lowup
	move.l	a0,ptwr.w
	addq	#1,nbimages.w
	tst.b	cheat.w
	beq.s	.loop
	cmp.b	#1,$fffffc02.w
	bne.s	.loop
	move	#$077,$ffff8240.w
.loop	cmp	#NBSCR-3,nbimages.w
	bhs.s	.loop
	bra	demo
;
; gestion du sc‚nario !!!!
;
initscenario:
	move.l	#debutscenario,ptscen.w
	clr	cptscen.w
	clr	transx.w
	clr	transy.w
	clr	transz.w
	clr	revolx.w
	clr	revoly.w
	clr	revolz.w
	rts
scenario:
	tst.b	flagscen.w
	beq.s	.rts

	subq	#1,cptscen.w
	bgt.s	.nonew
	bsr.s	readscenario
.nonew
;
; variables … mettre … jour :
;
;	curobj=num‚ro de l'objet … animer
;	ROTATEX,ROTATEY,ROTATEZ=angles de rotation
;	ROTX,ROTY,ROTZ=angles courants
;	obsx,obsy,obsz=translations
;
	move	transx.w,d0
	add	d0,obsx.w
	move	transy.w,d0
	add	d0,obsy.w
	move	transz.w,d0
	add	d0,obsz.w
	move	revolx.w,d0
	add	d0,axex.w
	move	revoly.w,d0
	add	d0,axey.w
	move	revolz.w,d0
	add	d0,axez.w
.rts	rts
readscenario:
	move.l	ptscen.w,a0
.nextscene
	move	(a0)+,d0
	jmp	.scene(pc,d0.w)
.scene
	bra.w	.code0
	bra.w	.code1
	bra.w	.code2
	bra.w	.code3
	bra.w	.code4

.code0:	lea	debutscenario,a0
	bra.s	.nextscene
.code1:
	move	(a0)+,curobj.w
	move	(a0)+,cptscen.w
	move.l	a0,ptscen.w
	rts
.code2:
	move	(a0)+,obsx.w
	move	(a0)+,obsy.w
	move	(a0)+,obsz.w
	move	(a0)+,transx.w
	move	(a0)+,transy.w
	move	(a0)+,transz.w
	bra.s	.nextscene
.code3:
	move.b	(a0)+,ROTX.W
	move.b	(a0)+,ROTY.W
	move.b	(a0)+,ROTZ.W
	move.b	(a0)+,ROTATEX.W
	move.b	(a0)+,ROTATEY.W
	move.b	(a0)+,ROTATEZ.W
	bra.s	.nextscene
.code4:
	move	(a0)+,axex.w
	move	(a0)+,axey.w
	move	(a0)+,axez.w
	move	(a0)+,revolx.w
	move	(a0)+,revoly.w
	move	(a0)+,revolz.w
	bra.s	.nextscene
;
;	curobj=num‚ro de l'objet … animer
;	ROTATEX,ROTATEY,ROTATEZ=angles de rotation
;	ROTX,ROTY,ROTZ=angles courants
;	obsx,obsy,obsz=translations
;
;
FINSCENE:MACRO
	DC.W	0*4
	ENDM
NBIMAGE:MACRO
n	set	\1
	ENDM
OBJET:	MACRO
	DC.W	1*4
	DC.W	\1,n
	ENDM
DEPLACE:MACRO
	DC.W	2*4
	DC.W	\1,\2,\3	;XYZ d‚part
	DC.W	(\4-\1)/n	;translation fixe
	DC.W	(\5-\2)/n
	DC.W	(\6-\3)/n
	ENDM

ROTATE:	MACRO
	DC.W	3*4
	DC.B	\1,\2,\3	;angles d‚part
	DC.B	(\4-\1)/n	;rotation fixe
	DC.B	(\5-\2)/n
	DC.B	(\6-\3)/n
	ENDM
REVOL:	MACRO			;r‚volution autour de son axe
	DC.W	4*4
	DC.W	\1,\2,\3
	DC.W	(\4-\1)/n	;translation fixe
	DC.W	(\5-\2)/n
	DC.W	(\6-\3)/n
	ENDM

debutscenario:
	NBIMAGE	256
	DEPLACE	-256,0,-256,0,0,0
	ROTATE	0,0,0,1*n,2*n,3*n
	REVOL	-256,0,-256,0,0,0
	OBJET	0

	NBIMAGE	50
	DEPLACE	0,0,0,0,0,0
	REVOL	0,0,0,0,0,0
	OBJET	0

	NBIMAGE	256
	DEPLACE	0,0,0,n,-n,-n
	REVOL	0,0,0,n,-n,0
	OBJET	0

	FINSCENE
	even
;
;
;
divs0:
	addq	#PROF,DIST.W
	addq	#1,d4
	addq	#1,d5
	rte
vbl:	addq	#1,sync.w
	rte
retr:	rtr

prg_sur_vbl:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	lastpal.w,a0
	movem.l	(a0),d0-d7
	move	d0,$ffff8242.w
	movem.l	d1-d7,$ffff8244.w

	IFNE	MUS
	bsr	musique+4
	ENDC

	tst	nbimages.w
	beq.s	novbl
	subq	#1,nbimages.w
	clr	$ffff8240.w

	sub	d0,d0		;clr d0 efface X ???
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

	move.l	ptrd.w,a0
	move.l	rsecran(a0),d0
	move.l	d0,lastecran.w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	rspal(a0),lastpal.w
	cmp.b	#$3b,$fffffc02.w
	bne.s	.notf1
	move.l	#bugpal,lastpal.w
.notf1
	lea	rslong(a0),a0
	cmp.l	#finscr,a0
	blo.s	1$
	lea	ptrscr.w,a0
1$	move.l	a0,ptrd.w

	movem.l	(sp)+,d0-d7/a0-a6
	rte
novbl:
	subq.b	#1,cptvbl.w
	bne.s	.nodispx2
	move.b	#50,cptvbl.w
	move.b	numsec.w,latchnum.w
	clr.b	numsec.w
.nodispx2

	tst.b	cheat.w
	beq.s	.nocpu

	cmp.b	#$f,$fffffc02.w
	bne.s	.nocpu
	add	#$333,$ffff8240.w	;indique quand passage en 2
.nocpu
	movem.l	(sp)+,d0-d7/a0-a6
	rte
;
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
;
; REGISTRES GENERAUX
;
MINY	equr	D6
MAXY	equr	D7
;
; A4 POINTE SUR L'OBJET
;
; registres utilis‚s dans hline1
;
SCRATCH	EQUR	a0
ADECR	EQUR	a1		;offset ‚cran
PTRGAU	EQUR	a2		;points gauches
PTRDRO	EQUR	a3		;points droits

OFFGAU	EQUR	a5		;offsets gauches
OFFDRO	EQUR	a6		;offsets droits

XGAU	EQUR	d0
XDRO	EQUR	d1
FFFF	EQUR	d2		;$FFFF
;
; REGISTRES DRAWLINE
;
XA	equr	D0	;extremit‚s de la droite
YA	equr	D1
XB	equr	D2
YB	equr	D3
REGDATA	equr	D4
DX	EQUR	D5

PTRY	equr	A0	;pointeur tabley
;
; d6=Ymin
; d7=Ymax
;
prg_test:
	movem	(a4)+,a0/a1/a2
	MOVEM	(a0),d0/d1	;A
	MOVEM	(a1),d4/d5	;C
	MOVE.L	(a2),d2		;B

	sub	D2,d5		;d5=yc-yb
	sub	D2,d1		;d1=ya-yb
	SWAP	D2

	sub	d2,d4		;d4=xc-xb
	sub	D2,d0		;d0=xa-xb

	muls	d1,d4		;d4=(ya-yb)*(xc-xb)
	muls	d0,d5		;d5=(xa-xb)*(yc-yb)

	sub.l	d4,d5
	bgt.s	5$		;invisible !!!
	addq	#2,a4
	NEXT
5$	add	(a4)+,a4
	NEXT


prg_skip:
	move.l	(a4),a4
	NEXT
prg_init
	moveq	#-1,d6		;Y minimum
	moveq	#0,d7		;Y maximum
	NEXT
prg_poly0
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	move.l	usp,ADECR
	lea	MUL160.W,a0
	add	(a0,d6.w),ADECR
	or	#%0001*4,planes.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0

	jmp	(a0)
1$
	NEXT

prg_poly00
	move	(a4)+,d0	;palette
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	or	#%0001*4,planes.w
	move	d0,palette+2.w	;couleur 2 change
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$
	NEXT

prg_poly1
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2,ADECR
	or	#%0010*4,planes.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT

prg_poly10
	move	(a4)+,d0
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2,ADECR
	or	#%0010*4,planes.w
	move	d0,palette+4.w
	move	d0,palette+6.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7				;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT

prg_poly2
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2*2,ADECR
	or	#%0100*4,planes.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT
prg_poly20
	move	(a4)+,d0
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2*2,ADECR
	or	#%0100*4,planes.w
	move	d0,palette+8.w
	move	d0,palette+10.w
	move	d0,palette+12.w
	move	d0,palette+14.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT

prg_poly3
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2*3,ADECR
	or	#%1000*4,planes.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT

prg_poly30
	move	(a4)+,d0
	sub	d6,d7		;d7=nb lignes-1
	add	d6,d6
	bmi.s	1$		;clipp‚ ???
	lea	MUL160.W,a0
	move.l	usp,ADECR
	add	(a0,d6.w),ADECR
	ADDQ	#2*3,ADECR
	or	#%1000*4,planes.w
	move	d0,palette+16.w
	move	d0,palette+18.w
	move	d0,palette+20.w
	move	d0,palette+22.w
	move	d0,palette+24.w
	move	d0,palette+26.w
	move	d0,palette+28.w
	move	d0,palette+30.w
	lea	pointsgauches.w,PTRGAU
	add	d6,PTRGAU			;ptr d‚but
	lea	pointsdroits-pointsgauches(PTRGAU),PTRDRO
	moveq	#-1,FFFF
	asl	#7,d7			;hline2-hline1 !!!
	lea	fast_draw+(nblig-1)*(hline2-hline1),a0
	sub.l	d7,a0
	jmp	(a0)
1$	NEXT
;
; routine de calcul des points d'un polygone !!!!
;
;-------------- cas d'une ligne verticale -----------------------


		REPT	nblig
		MOVE	XA,(PTRY)+	;mise en place nouveau points
		ENDR
affvert
retourvert
	NEXT

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
	NEXT

;-------------- d‚but calcul d'une ligne -------------------------

prg_draw
	movem	(a4)+,a0/a1
	movem	(a0),d0/d1
	movem	(a1),d2/d3
drawline:
	lea	pointsdroits.w,PTRY

	cmp	YA,YB
	beq.s	calcretour	;ligne horizontale
	bge.s	.YBsupYA

	exg	XA,XB		;echange les points
	exg	YA,YB

	lea	pointsgauches-pointsdroits(PTRY),PTRY	;c'est une ligne montante
.YBsupYA

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
.YAsup0
		CMP	#nblig,YB
		BLO.S	.YBinfmax
		BLT.S	calcretour
		move	#nblig-1,YB
		move	YB,REGDATA
		sub	YA,REGDATA	;DY
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

	NEXT

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
	NEXT


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
	move.l	lastcode(pc),(a6)+
	cmp.l	#findraw,a6
	beq.s	.ok
	illegal
.ok
	rts
lastcode:
	NEXT
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
	LEA	MATRICE\W,a2
	move.l	a2,usp

	MOVE	(A0)+,PUSHD0.w		;nb points

	LEA	SINCOS(PC),a3
	CLR	D0
	MOVE.B	ROTATEX.W,D0
	ADD.B	ROTX.W,D0
	MOVE.B	D0,ROTX.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A3,D0.W),SX/CX

	CLR	D0
	MOVE.B	ROTATEY.W,D0
	ADD.B	ROTY.W,D0
	MOVE.B	D0,ROTY.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A3,D0.W),SY/CY

	CLR	D0
	MOVE.B	ROTATEZ.W,D0
	ADD.B	ROTZ.W,D0
	MOVE.B	D0,ROTZ.W
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A3,D0.W),SZ/CZ
;
; CALCULE LA MATRICE DE PROJECTION
;
	NEG	SZ			;ROTATION EN Z BUGGEE !!!

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
	move	obsx.w,d0
	swap	d0
	clr	d0
	move.l	d0,(a2)+
	move	obsy.w,d0
	swap	d0
	clr	d0
	move.l	d0,(a2)+
;
	move	#320,A3		;xmin
	SUB	A4,A4		;xmax
	move	#nblig-1,A5	;ymin
	SUB	A6,A6		;ymax
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
	MOVE	DIST\W,D4
	sub	obsz.w,d4
	MOVE	PUSHD0.w,D5
	SUBQ	#1,D5
.CALCUL:
	MOVE.L	USP,A2
	MOVEM	(A0)+,D1/D2/D3
	add	axex.w,d1
	add	axey.w,d2
	add	axez.w,d3

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
	SUB	D4,D1

	add.l	(a2)+,d6
	add.l	(a2)+,d7

; mettre TRAPV ici !!!!
; ou BLE.S bug

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
	DBRA	D5,.CALCUL
	rts

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
	lea	PUSHCLS-4.w,A0
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
	lea	PUSHCLS.w,a3
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

	section	data
	IFNE	MUS
musique:incbin	replay.bin
	ENDC

INITDRAW:MACRO
	dc.w	prg_init
	ENDM

TEST	MACRO
	dc.w	prg_test
	dc.w	\1*4+segments,\3*4+segments,\2*4+segments
	dc.w	\4-*-2
	ENDM

DRAW	MACRO
	dc.w	prg_draw
	dc.w	\1*4+segments,\2*4+segments
	ENDM

SKIP	MACRO
	dc.w	prg_skip
	dc.l	\1
	ENDM

AFFPOLY:MACRO
	ifeq	\1
	ifeq	\2+1
	dc.w	prg_poly0
	elseif
	dc.w	prg_poly00
	dc.w	\2
	endc
	endc

	ifeq	\1-1
	ifeq	\2+1
	dc.w	prg_poly1
	elseif
	dc.w	prg_poly10
	dc.w	\2
	endc
	endc

	ifeq	\1-2
	ifeq	\2+1
	dc.w	prg_poly2
	elseif
	dc.w	prg_poly20
	dc.w	\2
	endc
	endc

	ifeq	\1-3
	ifeq	\2+1
	dc.w	prg_poly3
	elseif
	dc.w	prg_poly30
	dc.w	\2
	endc
	endc

	ENDM

RET	MACRO
	dc.w	prg_rts
	ENDM

FACE	MACRO
	INITDRAW
	DRAW	\3,\4
	DRAW	\4,\5
	IFC	'\6',''
	DRAW	\5,\3
	ELSEIF
	DRAW	\5,\6
	IFC	'\7',''
	DRAW	\6,\3
	ELSEIF
	DRAW	\6,\7
	IFC	'\8',''
	DRAW	\7,\3
	ELSEIF
	DRAW	\7,\8
	IFC	'\9',''
	DRAW	\8,\3
	ELSEIF
	DRAW	\8,\9
	IFC	'\A',''
	DRAW	\9,\3
	ELSEIF
	ERROR
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	AFFPOLY	\1,\2
\@
	ENDM
FACE2	MACRO
	INITDRAW
	DRAW	(\3-1),(\4-1)
	DRAW	(\4-1),(\5-1)
	IFC	'\6',''
	DRAW	(\5-1),(\3-1)
	ELSEIF
	DRAW	(\5-1),(\6-1)
	IFC	'\7',''
	DRAW	(\6-1),(\3-1)
	ELSEIF
	DRAW	(\6-1),(\7-1)
	IFC	'\8',''
	DRAW	(\7-1),(\3-1)
	ELSEIF
	DRAW	(\7-1),(\8-1)
	IFC	'\9',''
	DRAW	(\8-1),(\3-1)
	ELSEIF
	DRAW	(\8-1),(\9-1)
	IFC	'\A',''
	DRAW	(\9-1),(\3-1)
	ELSEIF
	ERROR
	ENDC
	ENDC
	ENDC
	ENDC
	ENDC
	AFFPOLY	\1,\2
\@
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
NBOBJETS = 26	;+2
all_objects:
;	dc.l	pchiffre8,fchiffre8,palette2
;	dc.l	plettrea,flettrea,palette3

	dc.l	lettrea,prga,palette1
	dc.l	lettreb,prgb,palette1
	dc.l	lettrec,prgc,palette1
	dc.l	lettred,prgd,palette1
	dc.l	lettree,prge,palette1
	dc.l	lettref,prgf,palette1
	dc.l	lettreg,prgg,palette1
	dc.l	lettreh,prgh,palette1
	dc.l	lettrei,prgi,palette1
	dc.l	lettrej,prgj,palette1
	dc.l	lettrek,prgk,palette1
	dc.l	lettrel,prgl,palette1
	dc.l	lettrem,prgm,palette1
	dc.l	lettren,prgn,palette1
	dc.l	lettreo,prgo,palette1
	dc.l	lettrep,prgp,palette1
	dc.l	lettreq,prgq,palette1
	dc.l	lettrer,prgr,palette1
	dc.l	lettres,prgs,palette1
	dc.l	lettret,prgt,palette1
	dc.l	lettreu,prgu,palette1
	dc.l	lettrev,prgv,palette1
	dc.l	lettrew,prgw,palette1
	dc.l	lettrex,prgx,palette1
	dc.l	lettrey,prgy,palette1
	dc.l	lettrez,prgz,palette1

BIG	MACRO
	DC.W	\1*2,\2*2,0	;\3*2
	ENDM

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
	TEST	1,0,2,chif8r
	FACE	0,-1,1,0,2,3
	FACE	0,-1,0,6,4,2
	FACE	0,-1,1,3,5,7
	FACE	0,-1,5,4,6,8,9,7
	FACE	0,-1,6,12,10,8
	FACE	0,-1,9,11,13,7
	FACE	0,-1,10,12,13,11
chif8r:
	RET

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
	TEST	0,7,8,letrar
	FACE	0,-1,0,7,8,1
	FACE	0,-1,9,10,1,0
	FACE	0,-1,3,5,6,4
letrar:
	TEST	0,1,8,letrar2
	FACE	1,-1,0,1,8,7
	FACE	1,-1,9,0,1,10
	FACE	1,-1,3,4,6,5
letrar2:
	RET
;
; Alphabet Kefrens
;
lettrea:
	dc.w	14
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,48,0
	dc.w	-25,-32,0
	dc.w	-25,0,0
	dc.w	-25,32,0
	dc.w	-25,48,0
	dc.w	25,-32,0
	dc.w	25,0,0
	dc.w	25,32,0
	dc.w	25,48,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	50,48,0
lettreb:
	dc.w	14
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	-25,-32,0
	dc.w	-25,-16,0
	dc.w	-25,16,0
	dc.w	-25,32,0
	dc.w	25,-32,0
	dc.w	25,-16,0
	dc.w	25,16,0
	dc.w	25,32,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	25,48,0
lettrec:
	dc.w	10
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	-25,-32,0
	dc.w	-25,32,0
	dc.w	50,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	50,48,0
lettred:
	dc.w	10
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	-25,-32,0
	dc.w	-25,32,0
	dc.w	25,-32,0
	dc.w	25,32,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	25,48,0
lettree:
	dc.w	14
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	-25,-32,0
	dc.w	-25,-16,0
	dc.w	-25,16,0
	dc.w	-25,32,0
	dc.w	25,-16,0
	dc.w	25,16,0
	dc.w	50,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	50,48,0
lettref:
	dc.w	11
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,48,0
	dc.w	-25,-32,0
	dc.w	-25,-16,0
	dc.w	-25,16,0
	dc.w	-25,48,0
	dc.w	25,-16,0
	dc.w	25,16,0
	dc.w	50,-48,0
	dc.w	50,-32,0
lettreg:
	dc.w	12
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	-25,-32,0
	dc.w	-25,32,0
	dc.w	50,-48,0
	dc.w	50,-32,0
	dc.w	50,0,0
	dc.w	50,48,0
	dc.w	25,0,0
	dc.w	25,32,0
lettreh:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	-25,-48,0
	dc.w	-25,-16,0
	dc.w	-25,16,0
	dc.w	-25,48,0
	dc.w	25,-48,0
	dc.w	25,-16,0
	dc.w	25,16,0
	dc.w	25,48,0
	dc.w	50,-48,0
	dc.w	50,48,0
lettrei:
	dc.w	12
	dc.w	-25,-48,0
	dc.w	-25,-32,0
	dc.w	25,-48,0
	dc.w	25,-32,0
	dc.w	-25,32,0
	dc.w	-25,48,0
	dc.w	25,32,0
	dc.w	25,48,0
	dc.w	-13,-32,0
	dc.w	-13,32,0
	dc.w	12,-32,0
	dc.w	12,32,0
lettrej:
	dc.w	14
	dc.w	-50,-48,0
	dc.w	-50,-32,0
	dc.w	25,-32,0
	dc.w	25,32,0
	dc.w	50,-48,0
	dc.w	50,32,0
	dc.w	-50,0,0
	dc.w	-50,32,0
	dc.w	-25,0,0
	dc.w	-25,32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	50,32,0
	dc.w	25,48,0
lettrek:
	dc.w	16
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	-25,-48,0
	dc.w	-25,-16,0
	dc.w	25,-48,0
	dc.w	-25,-16,0
	dc.w	50,-48,0
	dc.w	0,-16,0
	dc.w	-25,16,0
	dc.w	-25,48,0
	dc.w	-25,16,0
	dc.w	25,48,0
	dc.w	0,16,0
	dc.w	50,48,0
	dc.w	0,-16,0
	dc.w	0,16,0
lettrel:
	dc.w	6
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	-25,-48,0
	dc.w	-25,32,0
	dc.w	50,32,0
	dc.w	50,48,0
lettrem:
	dc.w	16
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	50,-48,0
	dc.w	50,48,0
	dc.w	-25,-32,0
	dc.w	-25,48,0
	dc.w	25,-32,0
	dc.w	25,48,0
	dc.w	-25,-48,0
	dc.w	0,-32,0
	dc.w	25,-48,0
	dc.w	0,-32,0
	dc.w	-25,-32,0
	dc.w	0,0,0
	dc.w	25,-32,0
	dc.w	0,0,0
lettren:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	50,-48,0
	dc.w	50,48,0
	dc.w	-25,-32,0
	dc.w	-25,48,0
	dc.w	25,-48,0
	dc.w	25,32,0
	dc.w	-25,-48,0
	dc.w	25,32,0
	dc.w	-25,-32,0
	dc.w	25,48,0
lettreo:
	dc.w	12
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	25,48,0
	dc.w	-25,-32,0
	dc.w	-25,32,0
	dc.w	25,-32,0
	dc.w	25,32,0
lettrep:
	dc.w	13
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	-25,-32,0
	dc.w	-25,0,0
	dc.w	25,-32,0
	dc.w	25,0,0
	dc.w	50,-32,0
	dc.w	50,0,0
	dc.w	25,32,0
	dc.w	-25,32,0
	dc.w	-25,48,0
lettreq:
	dc.w	13
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	50,48,0
	dc.w	-25,-32,0
	dc.w	-25,32,0
	dc.w	25,-32,0
	dc.w	25,0,0
	dc.w	0,0,0
	dc.w	25,32,0
lettrer:
	dc.w	17
	dc.w	-50,-48,0
	dc.w	-50,48,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	-25,-32,0
	dc.w	-25,0,0
	dc.w	25,-32,0
	dc.w	25,0,0
	dc.w	50,-32,0
	dc.w	50,0,0
	dc.w	25,32,0
	dc.w	-25,32,0
	dc.w	-25,48,0
	dc.w	-25,32,0
	dc.w	12,48,0
	dc.w	12,32,0
	dc.w	50,48,0
lettres:
	dc.w	16
	dc.w	-25,-48,0
	dc.w	-50,-32,0
	dc.w	25,-48,0
	dc.w	50,-32,0
	dc.w	-50,-32,0
	dc.w	-50,16,0
	dc.w	-25,-32,0
	dc.w	-25,-16,0
	dc.w	50,-16,0
	dc.w	50,32,0
	dc.w	25,16,0
	dc.w	25,32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	50,32,0
	dc.w	25,48,0
lettret:
	dc.w	8
	dc.w	-50,-48,0
	dc.w	-50,-32,0
	dc.w	50,-48,0
	dc.w	50,-32,0
	dc.w	-13,-32,0
	dc.w	-13,48,0
	dc.w	12,-32,0
	dc.w	12,48,0
lettreu:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-50,32,0
	dc.w	50,-48,0
	dc.w	50,32,0
	dc.w	-25,-48,0
	dc.w	-25,32,0
	dc.w	25,-48,0
	dc.w	25,32,0
	dc.w	-50,32,0
	dc.w	-25,48,0
	dc.w	50,32,0
	dc.w	25,48,0
lettrev:
	dc.w	8
	dc.w	-50,-48,0
	dc.w	-13,48,0
	dc.w	-25,-48,0
	dc.w	0,32,0
	dc.w	25,-48,0
	dc.w	0,32,0
	dc.w	50,-48,0
	dc.w	12,48,0
lettrew:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-25,48,0
	dc.w	50,-48,0
	dc.w	25,48,0
	dc.w	-25,-48,0
	dc.w	-7,32,0
	dc.w	25,-48,0
	dc.w	6,32,0
	dc.w	-7,32,0
	dc.w	0,-16,0
	dc.w	6,32,0
	dc.w	0,-16,0
lettrex:
	dc.w	16
	dc.w	-50,-48,0
	dc.w	-13,0,0
	dc.w	-50,48,0
	dc.w	-13,0,0
	dc.w	50,-48,0
	dc.w	12,0,0
	dc.w	50,48,0
	dc.w	12,0,0
	dc.w	-25,-48,0
	dc.w	0,-32,0
	dc.w	-25,48,0
	dc.w	0,32,0
	dc.w	25,-48,0
	dc.w	0,-32,0
	dc.w	25,48,0
	dc.w	0,32,0
lettrey:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-13,0,0
	dc.w	50,-48,0
	dc.w	12,0,0
	dc.w	-25,-48,0
	dc.w	0,-32,0
	dc.w	25,-48,0
	dc.w	0,-32,0
	dc.w	-13,0,0
	dc.w	-13,48,0
	dc.w	12,0,0
	dc.w	12,48,0
lettrez:
	dc.w	12
	dc.w	-50,-48,0
	dc.w	-50,-32,0
	dc.w	-50,32,0
	dc.w	-50,48,0
	dc.w	50,-48,0
	dc.w	50,-32,0
	dc.w	50,32,0
	dc.w	50,48,0
	dc.w	12,-32,0
	dc.w	-50,32,0
	dc.w	50,-32,0
	dc.w	-13,32,0
FFACE2:	MACRO
	TEST	(\1-1),(\2-1),(\3-1),\4
	ENDM
prga:
	FFACE2	1,2,4,pra
	FACE2	0,-1,1,2,4,8,13,12
	FACE2	0,-1,2,3,7,6,5,4
	FACE2	0,-1,5,6,10,9
	FACE2	0,-1,8,9,10,11,14,13
	RET
pra:
	FACE2	0,-1,1,12,13,8,4,2
	FACE2	0,-1,2,4,5,6,7,3
	FACE2	0,-1,5,9,10,6
	FACE2	0,-1,8,13,14,11,10,9
	RET
prgb:
	FFACE2	1,3,7,prb
	FACE2	0,-1,1,3,7,12,11
	FACE2	0,-1,1,2,6,5,4,3
	FACE2	0,-1,2,14,13,10,6
	FACE2	0,-1,7,8,9,10,13,12
	FACE2	0,-1,4,5,9,8
	RET
prb:
	FACE2	0,-1,1,11,12,7,3
	FACE2	0,-1,1,3,4,5,6,2
	FACE2	0,-1,2,6,10,13,14
	FACE2	0,-1,7,12,13,10,9,8
	FACE2	0,-1,4,8,9,5
	RET
prgc:
	FFACE2	1,2,5,prc
	FACE2	0,-1,1,2,5,8,7
	FACE2	0,-1,2,3,4,6,5
	FACE2	0,-1,6,4,10,9
	RET
prc:
	FACE2	0,-1,1,7,8,5,2
	FACE2	0,-1,2,5,6,4,3
	FACE2	0,-1,6,9,10,4
	RET
prgd:
	FFACE2	1,3,5,prd
	FACE2	0,-1,1,3,5,8,7
	FACE2	0,-1,1,2,4,3
	FACE2	0,-1,2,10,9,6,4
	FACE2	0,-1,5,6,9,8
	RET
prd:
	FACE2	0,-1,1,7,8,5,3
	FACE2	0,-1,1,3,4,2
	FACE2	0,-1,2,4,6,9,10
	FACE2	0,-1,5,8,9,6
	RET
prge:
	FFACE2	1,2,5,pre
	FACE2	0,-1,1,2,5,12,11
	FACE2	0,-1,2,3,4,8,7,6,5
	FACE2	0,-1,8,4,14,13
	FACE2	0,-1,6,7,10,9
	RET
pre:
	FACE2	0,-1,1,11,12,5,2
	FACE2	0,-1,2,5,6,7,8,4,3
	FACE2	0,-1,8,13,14,4
	FACE2	0,-1,6,9,10,7
	RET
prgf:
	FFACE2	1,2,4,prf
	FACE2	0,-1,1,2,4,11,10
	FACE2	0,-1,2,3,7,6,5,4
	FACE2	0,-1,5,6,9,8
	RET
prf:
	FACE2	0,-1,1,10,11,4,2
	FACE2	0,-1,2,4,5,6,7,3
	FACE2	0,-1,5,8,9,6
	RET
prgg:
	FFACE2	1,2,5,prg
	FACE2	0,-1,1,2,5,8,7
	FACE2	0,-1,2,3,4,6,5
	FACE2	0,-1,6,4,10,12
	FACE2	0,-1,11,12,10,9
	RET
prg:
	FACE2	0,-1,1,7,8,5,2
	FACE2	0,-1,2,5,6,4,3
	FACE2	0,-1,6,12,10,4
	FACE2	0,-1,11,9,10,12
	RET
prgh:
	FFACE2	1,2,6,prh
	FACE2	0,-1,1,2,6,5,4,3
	FACE2	0,-1,4,5,9,8
	FACE2	0,-1,7,8,9,10,12,11
	RET
prh:
	FACE2	0,-1,1,3,4,5,6,2
	FACE2	0,-1,4,8,9,5
	FACE2	0,-1,7,11,12,10,9,8
	RET
prgi:
	FFACE2	1,2,9,pri
	FACE2	0,-1,1,2,9,11,4,3
	FACE2	0,-1,9,10,12,11
	FACE2	0,-1,5,6,8,7,12,10
	RET
pri:
	FACE2	0,-1,1,3,4,11,9,2
	FACE2	0,-1,9,11,12,10
	FACE2	0,-1,5,10,12,7,8,6
	RET
prgj:
	FFACE2	1,2,3,prj
	FACE2	0,-1,1,2,3,5
	FACE2	0,-1,3,4,14,13,5
	FACE2	0,-1,7,11,10,9
	FACE2	0,-1,11,12,14,4,10
	RET
prj:
	FACE2	0,-1,1,5,3,2
	FACE2	0,-1,3,5,13,14,4
	FACE2	0,-1,7,9,10,11
	FACE2	0,-1,11,10,4,14,12
	RET
prgk:
	FFACE2	1,2,10,prk
	FACE2	0,-1,1,2,10,11,6,3
	FACE2	0,-1,5,6,15,7
	FACE2	0,-1,6,11,16,15
	FACE2	0,-1,11,12,14,16
	RET
prk:
	FACE2	0,-1,1,3,6,11,10,2
	FACE2	0,-1,5,7,15,6
	FACE2	0,-1,6,15,16,11
	FACE2	0,-1,11,16,14,12
	RET
prgl:
	FFACE2	1,2,4,prl
	FACE2	0,-1,1,2,4,3
	FACE2	0,-1,2,6,5,4
	RET
prl:
	FACE2	0,-1,1,3,4,2
	FACE2	0,-1,2,4,5,6
	RET
prgm:
	FFACE2	1,2,6,prm
	FACE2	0,-1,1,2,6,13,9
	FACE2	0,-1,9,13,16,12
	FACE2	0,-1,12,16,15,11
	FACE2	0,-1,11,15,8,4,3
	RET
prm:
	FACE2	0,-1,1,9,13,6,2
	FACE2	0,-1,9,12,16,13
	FACE2	0,-1,12,11,15,16
	FACE2	0,-1,11,3,4,8,15
	RET
prgn:
	FFACE2	1,2,6,prn
	FACE2	0,-1,1,2,6,11,9
	FACE2	0,-1,9,11,12,10
	FACE2	0,-1,7,10,12,4,3
	RET
prn:
	FACE2	0,-1,1,9,11,6,2
	FACE2	0,-1,9,10,12,11
	FACE2	0,-1,7,3,4,12,10
	RET
prgo:
	FFACE2	1,2,3,pro
	FACE2	0,-1,1,2,3,4,10,9
	FACE2	0,-1,1,9,11,5
	FACE2	0,-1,10,4,8,12
	FACE2	0,-1,5,11,12,8,7,6
	RET
pro:
	FACE2	0,-1,1,9,10,4,3,2
	FACE2	0,-1,1,5,11,9
	FACE2	0,-1,10,12,8,4
	FACE2	0,-1,5,6,7,8,12,11
	RET
prgp:
	FFACE2	1,2,13,prp
	FACE2	0,-1,1,2,13,12,6,5
	FACE2	0,-1,1,5,7,9,3
	FACE2	0,-1,6,12,11,10,8
	FACE2	0,-1,7,8,10,9
	RET
prp:
	FACE2	0,-1,1,5,6,12,13,2
	FACE2	0,-1,1,3,9,7,5
	FACE2	0,-1,6,8,10,11,12
	FACE2	0,-1,7,9,10,8
	RET
prgq:
	FFACE2	1,2,3,prq
	FACE2	0,-1,1,2,3,4,9,8
	FACE2	0,-1,1,8,10,6,5
	FACE2	0,-1,11,12,13
	FACE2	0,-1,10,11,13,7,6
	FACE2	0,-1,9,4,7,13
	RET
prq:
	FACE2	0,-1,1,8,9,4,3,2
	FACE2	0,-1,1,5,6,10,8
	FACE2	0,-1,11,13,12
	FACE2	0,-1,10,6,7,13,11
	FACE2	0,-1,9,13,7,4
	RET
prgr:
	FFACE2	1,2,13,prr
	FACE2	0,-1,1,2,13,14,6,5
	FACE2	0,-1,1,5,7,9,3
	FACE2	0,-1,14,15,17,16
	FACE2	0,-1,6,14,16,11,10,8
	FACE2	0,-1,7,8,10,9
	RET
prr:
	FACE2	0,-1,1,5,6,14,13,2
	FACE2	0,-1,1,3,9,7,5
	FACE2	0,-1,14,16,17,15
	FACE2	0,-1,6,8,10,11,16,14
	FACE2	0,-1,7,9,10,8
	RET
prgs:
	FFACE2	1,5,6,prs
	FACE2	0,-1,1,5,6,8,7
	FACE2	0,-1,1,7,4,3
	FACE2	0,-1,8,6,11,9
	FACE2	0,-1,13,14,16,15,12
	FACE2	0,-1,11,12,15,9
	RET
prs:
	FACE2	0,-1,1,7,8,6,5
	FACE2	0,-1,1,3,4,7
	FACE2	0,-1,8,9,11,6
	FACE2	0,-1,13,12,15,16,14
	FACE2	0,-1,11,9,15,12
	RET
prgt:
	FFACE2	1,2,5,prt
	FACE2	0,-1,1,2,5,7,4,3
	FACE2	0,-1,5,6,8,7
	RET
prt:
	FACE2	0,-1,1,3,4,7,5,2
	FACE2	0,-1,5,7,8,6
	RET
prgu:
	FFACE2	1,9,10,pru
	FACE2	0,-1,1,9,10,6,5
	FACE2	0,-1,6,10,12,8
	FACE2	0,-1,7,8,12,11,3
	RET
pru:
	FACE2	0,-1,1,5,6,10,9
	FACE2	0,-1,6,8,12,10
	FACE2	0,-1,7,3,11,12,8
	RET
prgv:
	FFACE2	1,2,6,prv
	FACE2	0,-1,1,2,6,3
	FACE2	0,-1,6,2,8
	FACE2	0,-1,5,6,8,7
	RET
prv:
	FACE2	0,-1,1,3,6,2
	FACE2	0,-1,6,8,2
	FACE2	0,-1,5,7,8,6
	RET
prgw:
	FFACE2	1,2,9,prw
	FACE2	0,-1,1,2,9,5
	FACE2	0,-1,12,9,11
	FACE2	0,-1,9,2,4,11
	FACE2	0,-1,7,11,4,3
	RET
prw:
	FACE2	0,-1,1,5,9,2
	FACE2	0,-1,12,11,9
	FACE2	0,-1,9,11,4,2
	FACE2	0,-1,7,3,4,11
	RET
prgx:
	FFACE2	1,4,14,prx
	FACE2	0,-1,1,4,14,9
	FACE2	0,-1,4,3,11,16
	FACE2	0,-1,8,16,15,7
	FACE2	0,-1,13,14,8,5
	FACE2	0,-1,14,4,16,8
	RET
prx:
	FACE2	0,-1,1,9,14,4
	FACE2	0,-1,4,16,11,3
	FACE2	0,-1,8,7,15,16
	FACE2	0,-1,13,5,8,14
	FACE2	0,-1,14,8,16,4
	RET
prgy:
	FFACE2	1,9,8,pry
	FACE2	0,-1,1,9,8,5
	FACE2	0,-1,7,8,11,3
	FACE2	0,-1,8,9,10,12,11
	RET
pry:
	FACE2	0,-1,1,5,8,9
	FACE2	0,-1,7,3,11,8
	FACE2	0,-1,8,11,12,10,9
	RET
prgz:
	FFACE2	1,2,9,prz
	FACE2	0,-1,1,2,9,11,5
	FACE2	0,-1,9,10,12,11
	FACE2	0,-1,10,4,8,7,12
	RET
prz:
	FACE2	0,-1,1,5,11,9,2
	FACE2	0,-1,9,11,12,10
	FACE2	0,-1,10,12,7,8,4
	RET
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
XYZ	MACRO
	DC.W	\1*10,\2*10,\3*20
	ENDM

FONTE:	DS.B	8
fonte:	incbin	fonte3.img
FINFONTE:
	IFNE	MUS
MUZAK:	INCBIN	SEVGATE2.MUS
	ENDC

	ifeq	DEBUG
debugger:incbin	debugger.bin
	endc

	SECTION	BSS
	ds.l	50
pile:
firstpal:ds.b	32*NBSCR

fast_draw:ds.b	(hline2-hline1)*nblig+4
findraw:

FASTCLS:
	ifeq	nblig-192
	ds.b	56764		;62720		;juste ??
	elseif
	ds.b	59132
	endc
FINFASTCLS:

offsetsgauches
	ds.l	CLIPPEGAUCHE
	ds.l	320
	ds.l	CLIPPEDROITE
offsetsdroits
	ds.l	CLIPPEGAUCHE
	ds.l	320
	ds.l	CLIPPEDROITE
fincode:
