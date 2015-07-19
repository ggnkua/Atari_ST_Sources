	opt	o+,ow2-
	opt	x+
	output	fractal.prg
AFFLOGO=1		;0=AFFICHAGE LOGO 2 PLANS
;
; demo fractale avec :
;
;	- musique
;	- pas de bordure bas
;	- code optimis‚
;	- sort sans plantage
;	- peut etre assembl‚ en m‚moire
;
SPACE=$2D
NUMMUS=1
PLANSCROLLER=0
YSCROLL	EQU	224-4
LOAD_TEXT:EQU	0	;0=LOAD TEXTE
TAILLE	EQU	25	;HAUTEUR DU SCROLLER
STEP	EQU	2	;PAS DU SCROLLER
HAUTEUR	EQU	262
screen	equ	($80000-HAUTEUR*160+255)&-256
plan1	equr	d0
plan2	equr	d1
za	equr	d2
zb	equr	d3
zb2	equr	d4
za2	equr	d5
color	equr	d6
reso	equr	d7
ecran	equr	a0
ca	equr	a1
cb	equr	a2
ptrcarre:equr	a3
var7	equr	a4
regvar2	equr	a5
regvar3	equr	a6

	OFFSET	$140

PTRCNT	DS.L	1
PTRCOL	DS.W	1
PTRBUF	DS.L	1
PARITE	DS.W	1
PTRFNT	DS.L	1
PTRTXT	DS.L	1

num:	ds.w	1
current:ds.w	7
var2:	equ	current+2
var3:	equ	current+4
var4:	equ	current+6
var5:	equ	current+8
var6:	equ	current+10

vitcurseur:ds.w	1
ycurseur:ds.w	1
lastycurseur:ds.w	1
mode:	ds.w	1
sync:	ds.w	1
accelere:ds.w	1

repeat:	ds.b	1
lastkey:ds.b	1
key:	ds.b	1
flagediteur:ds.b	1
	even
	list

	nolist
	SECTION	TEXT
	org	$8000
stack:
	lea	stack(pc),sp

	lea	carres+65536*2,a0
	move.l	a0,a1
	MOVE.l	#4,(a0)+
	moveq	#1,d0
	moveq	#3,d1
	move	#$8000-1,d2

	MOVE.L	#1<<(31-3),d4

fill:
	MOVE.L	D0,D3
;	cmp.l	#1<<(31-3),d3
	CMP.L	D4,D3
	bhs.s	.no
	ASL.L	#3,D3
	addq	#4,d3
	move.l	D3,(a0)+
	move.l	D3,-(a1)
	add.l	d1,d0
	addq.l	#2,d1
	dbra	d2,fill

	IFEQ	1
.ERR	illegal
.no
	CMP.L	#$10000000,D3
	BNE.S	.ERR
	CMP	#$4000,D2
	BNE.S	.ERR
	ELSEIF
.no
	ENDC

	MOVE.L	#1<<(31)-4,D3
.fil2
	move.l	D3,(a0)+
	move.l	D3,-(a1)
	dbra	d2,.fil2

	lea	screen,a0
	move	#(160*HAUTEUR+255)/4-1,d1
	moveq	#0,d0
.cls	move.l	d0,(a0)+
	dbra	d1,.cls

INITSCROLLER:
;
; PREDECALE LA FONTE
;
	MOVEQ	#16,D1
	LEA	PREDEC,A1
NXTDEC:
	LEA	FONTE,A0
NXTCAR:
	MOVEQ	#TAILLE-1,D7
DECAL:
	MOVEQ	#0,D0
	MOVE	(A0)+,D0
	ROR.L	D1,D0
	MOVE.L	D0,(A1)+
	DBRA	D7,DECAL

	CMP.L	#FINFONTE,A0
	BLO.S	NXTCAR

	SUBQ	#STEP,D1
	BHI.S	NXTDEC

	CMP.L	#FINPREDEC,A1
	BLO.S	1$
	MOVEQ	#-1,D0
2$	MOVE	D0,$FFFF8240.W
	DBRA	D0,2$
1$

	IFNE	LOAD_TEXT
;
; INITIALISE LE SCROLLER
;
	LEA	TEXTE,A0
	MOVEQ	#0,D0
CONV	MOVE.B	(A0),D0
	BMI.S	FINCONV

	LEA	CONVTBL(pc),A1
.TSTLET:
	MOVE.B	(A1)+,D1
	BEQ.S	.SPC
	CMP.B	D1,D0
	BNE.S	.TSTLET
	MOVE.L	A1,D1
	SUB.L	#CONVTBL+1,D1
	MOVE.B	D1,(A0)+
	BRA.S	CONV
.SPC	MOVE.B	#$1D,(A0)+	;ESPACE
	BRA.S	CONV
FINCONV:
	ENDC

	LEA	TEXTE,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	MOVE.L	A0,PTRTXT.w
;	ASL	#6+1,D0
	MULU	#TAILLE*8,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,PTRFNT.w

	CLR.L	PTRCNT.w
	CLR	PTRCOL.w
	MOVE.L	#BUFFER,PTRBUF.w
	CLR	PARITE.w

	LEA	BUFFER,A0
	MOVEQ	#0,D0
	MOVE	#(16/STEP)*TAILLE*80/4-1,D1
CLRBUF:	MOVE.L	D0,(A0)+
	DBF	D1,CLRBUF

	move.l	#screen,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.b	#$40,$fffffa17.w
	CLR.B	$FFFFFA1B.W
	OR.B	#1,$FFFFFA13.W
	OR.B	#1,$FFFFFA07.W
	lea	musique(pc),a0
	moveq	#NUMMUS,d0
	bsr	player
	clr	num.w
	clr	mode.w			;0=d‚filement normal
	clr	ycurseur.w
	clr.b	flagediteur.w

	move.l	#newvbl,$70.w
	move	#$2300,sr
recalc:
	moveq	#14,d0
	mulu	num.w,d0
	lea	table(pc),a0
	movem	(a0,d0.w),d0-d6
	movem	d0-d6,current.w
calcule:
;	bsr	cls
	movem	current.w,d0-d5/var7
;	movem	d1-d5,var2
;	move	current+12.w,var7

	lea	screen,ecran
	move	#YSCROLL-1,reso
	move	var5.w,cb
	lea	carres+65536*2,ptrcarre
	subq	#1,var7
	tst	d0
	bne	julia
mandelbrot:
	movem	var2.w,regvar2/regvar3
.bcl1:
	swap	reso
	move	#320/16-1,reso
	move	var4.w,ca
.bcl2:
	moveq	#1,plan2
.bcl3:
	move	var7,color
	move	ca,za
	move	cb,zb
.bcl4:
	move	zb,zb2
	muls	za,zb
	ext.l	zb2
	asl.l	#2,zb2
	move.l	(ptrcarre,zb2.l),zb2

	ext.l	za
	asl.l	#2,za
	move.l	(ptrcarre,za.l),za
	move.l	za,za2
	sub.l	zb2,za
	swap	za
	asl.l	#4,zb
	swap	zb

	add	regvar2,za
	add	regvar3,zb
	add.l	zb2,za2
	dbmi	color,.bcl4
	not	color
	add	var6.w,ca

	swap	plan1
	lsr	#1,color
	addx	plan1,plan1
	swap	plan1
	lsr	#1,color
	addx	plan1,plan1
	swap	plan2
	lsr	#1,color
	addx	plan2,plan2
	swap	plan2
	lsr	#1,color
	addx	plan2,plan2
	bcc.s	.bcl3
	move.l	plan1,(ecran)+
	move.l	plan2,(ecran)+

	dbra	reso,.bcl2

	cmp.b	#$39,key.w
	beq	sortir

	sub	var6.w,cb
	swap	reso
	dbra	reso,.bcl1
	bra.s	next

julia:
.bcl1:
	swap	reso
	move	#320/16-1,reso
	move	var4.w,ca
.bcl2:
	moveq	#1,plan2
.bcl3:
	move	var7,color
	move	ca,za
	move	cb,zb
.bcl4:

	move	zb,zb2
	muls	za,zb
	ext.l	zb2
	asl.l	#2,zb2
	move.l	(ptrcarre,zb2.l),zb2

	ext.l	za
	asl.l	#2,za
	move.l	(ptrcarre,za.l),za
	move.l	za,za2
	sub.l	zb2,za
	swap	za		;za=(za^2-zb^2)/2^13
	asl.l	#4,zb
	swap	zb		;zb=(za*zb)/2^12

	add	ca,za
	add	cb,zb
	add.l	zb2,za2
	dbmi	color,.bcl4
	not	color
	add	var6.w,ca

	swap	plan1
	lsr	#1,color
	addx	plan1,plan1
	swap	plan1
	lsr	#1,color
	addx	plan1,plan1
	swap	plan2
	lsr	#1,color
	addx	plan2,plan2
	swap	plan2
	lsr	#1,color
	addx	plan2,plan2
	bcc.s	.bcl3
	move.l	plan1,(ecran)+
	move.l	plan2,(ecran)+

	dbra	reso,.bcl2

	cmp.b	#$39,key.w
	beq.s	sortir
	sub	var6.w,cb
	swap	reso
	dbra	reso,.bcl1
next:
	tst	mode.w
	bne.s	.wait

	clr	sync.w
.wvbl	cmp	#100,sync.w		;attente 2 secondes
	blo.s	.wvbl

	move	num.w,d0
	addq	#1,d0
	cmp	#(fintable-table)/14,d0
	blo.s	.ok
	clr	d0
.ok
	move	d0,num.w
	bra	recalc
.wait:
	cmp.b	#$39,key.w
	bne.s	.wait
sortir:
editeur:
;
; gestion de l'‚diteur
;
	bsr	cls
	st	flagediteur.w

	lea	mess(pc),a0
	moveq	#0,d6		;X
	moveq	#0,d7		;Y
	bsr	print
	move	#-1,lastycurseur.w
	clr	vitcurseur.w
	bsr	display_info
	clr	sync.w
.init
	clr.b	key.w
	clr.b	repeat.w
.loop
	move	sync.w,d0
.ww	cmp	sync.w,d0
	beq.s	.ww

	move	vitcurseur.w,d0
	add	ycurseur.w,d0
	cmp	#YSCROLL-TAILLE-4,d0
	bhs.s	.clr
	move	d0,ycurseur.w
	ext.l	d0
	divu	#TAILLE+2,d0
	swap	d0
	tst	d0
	bne.s	.ok
.clr	clr	vitcurseur.w
.ok
;	move	#$555,$ffff8240.w
	move	lastycurseur.w,d0
	bmi.s	.noeff
	moveq	#0,d1
	bsr	affcurseur
.noeff:
	move	ycurseur.w,d0
	move	d0,lastycurseur.w
	moveq	#-1,d1
	bsr	affcurseur
;	clr	$ffff8240.w

	move.b	key.w,d0
	cmp.b	#$48,d0		;flŠche haut
	bne.s	.pahaut
	move	#-3,vitcurseur.w
	bra.s	.loop
.pahaut
	cmp.b	#$50,d0		;flŠche bas
	bne.s	.pabas
	move	#3,vitcurseur.w
	bra.s	.loop
.pabas
;
; les fonctions suivantes ne sont valides que quand on est sur une case
;
	tst	vitcurseur.w
	bne.s	.loop

	cmp.b	#$39,d0
	bne.s	.paspc
	clr.b	key.w
	move	#-1,mode.w
	clr.b	flagediteur.w
	bsr	cls
	bra	calcule
.paspc
;
; la saisie des touches suivantes a lieu toutes les 3 VBLs !!!
;
	cmp	#3,sync.w		;attente 3 VBLs !!!
	blo	.loop
	clr	sync.w
;
; touches g‚r‚es avec acc‚l‚ration
;
	cmp.b	repeat.w,d0
	beq.s	.rep
	move.b	d0,repeat.w
	clr	accelere.w
	bra	.loop
.rep
	cmp.b	#$4d,d0
	bne.s	.padroite
;
; flŠche droite
;
	addq	#1,accelere.w

	bsr.s	addit
	bra	.loop
.padroite
	cmp.b	#$4b,d0
	bne	.loop
;
; flŠche gauche
;
	subq	#1,accelere.w
	bsr.s	addit
	bra	.loop
addit:
	moveq	#0,d7
	move	ycurseur.w,d7
	divu	#TAILLE+2,d7		;d7=num‚ro de la case
	move	accelere.w,d0
	add	d7,d7
	add	d7,d7
	jmp	.tab(pc,d7.w)
.tab
	bra.w	.add0
	bra.w	.add1
	bra.w	.add2
	bra.w	.add3
	bra.w	.add4
	bra.w	.add5
	bra.w	.add6
	bra.w	.add7

.add0:
	add	num.w,d0
	cmp	#(fintable-table)/14,d0
	blo.s	.ok
	slt	d0
	ext	d0
	and	#(fintable-table)/14-1,d0
.ok
	move	d0,num.w
	mulu	#14,d0
	lea	table(pc),a0
	movem	(a0,d0.w),d0-d6
	movem	d0-d6,current.w
	bsr	display_info
	clr.b	repeat.w
	clr.b	key.w
	rts
.add1
	not	current.w		;bascule 
	bsr	display1
	clr.b	repeat.w
	clr.b	key.w
	rts
.add2
	add	d0,current+2.w
	bra	display2
.add3
	add	d0,current+4.w
	bra	display3
.add4
	add	d0,current+6.w
	bra	display4
.add5
	add	d0,current+8.w
	bra	display5
.add6
	add	d0,current+10.w
	bgt.s	.ok3
	move	#1,current+10.w
.ok3
	bra	display6
.add7
	add	d0,current+12.w
	bgt.s	.ok2
	move	#1,current+12.w
.ok2
	bra	display7
;
; a0=message
; a1=adresse ‚cran
;
print:
	lea	screen,a1		;base ‚cran
.pr1
	clr	d0
	move.b	(a0)+,d0
	bpl.s	.nocnt
	addq.b	#1,d0			;-1 ???
	bne.s	.nocr
	clr	d6			;X=0,Y=Y+32
	add	#160*(TAILLE+2),d7
	bra.s	.pr1
.nocr
	rts
.nocnt
	move.l	a1,a3
	add	d6,a3
	add	d7,a3
	mulu	#TAILLE*4,d0
	lea	FONTE,A2
	ADD	D0,A2

	moveq	#TAILLE-1,d0
.aff	move	(a2)+,(a3)
	move	TAILLE*2-2(a2),8(a3)
	lea	160(a3),a3
	dbra	d0,.aff

	add	#16,d6
	bra.s	.pr1

display_info:
	bsr.s	display0
	bsr.s	display1
	bsr.s	display2
	bsr.s	display3
	bsr.s	display4
	bsr.s	display5
	bsr.s	display6
	bra.s	display7

display0:
	lea	hexa+2(pc),a0
	moveq	#1,d0
	add	num.w,d0
	divu	#10,d0
	add.l	#30*65536+30,d0
	move.b	d0,(a0)
	swap	d0
	move.b	d0,1(a0)
	moveq	#0,d7
	move	#8*16,d6
	bra.s	print

display1:
	lea	mess1(pc),a0
	tst	current.w
	bne.s	.mand
	lea	mess2(pc),a0
.mand
	move	#(TAILLE+2)*160,d7
	moveq	#5*16,d6
	bra	print
display2:
	move	current+2.w,d0
	move	#(TAILLE+2)*160*2,d7
	bra.s	disp_hex
display3:
	move	current+4.w,d0
	move	#(TAILLE+2)*160*3,d7
	bra.s	disp_hex
display4:
	move	current+6.w,d0
	move	#(TAILLE+2)*160*4,d7
	bra.s	disp_hex
display5:
	move	current+8.w,d0
	move	#(TAILLE+2)*160*5,d7
	bra.s	disp_hex
display6:
	move	current+10.w,d0
	move	#(TAILLE+2)*160*6,d7
	bra.s	disp_hex
display7:
	move	current+12.w,d0
	move	#(TAILLE+2)*160*7,d7

disp_hex:
	moveq	#6*16,d6
	moveq	#4-1,d1
	lea	hexa(pc),a0
.hex
	rol	#4,d0
	moveq	#$f,d2
	and	d0,d2
	cmp	#10,d2
	blo.s	.low10
	sub	#10,d2
	bra.s	.next
.low10	add	#30,d2
.next
	move.b	d2,(a0)+
	dbra	d1,.hex
	lea	hexa(pc),a0
	bra	print

cls:
	lea	screen,a0		;base ‚cran
	moveq	#0,d0
	move	#YSCROLL*160/8-1,d1
.cls	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,.cls
	rts

affcurseur:
	lea	screen+2,a0
	mulu	#160,d0
	add.l	d0,a0
	move	#160*TAILLE/16-1,d0
.aff	move	d1,(a0)
	move	d1,8(a0)
	lea	16(a0),a0
	dbra	d0,.aff
	rts

newvbl:
	CLR.B	$FFFFFA1B.W
	MOVE.B	#199,$FFFFFA21.W
	MOVE.L	#HBL,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	movem.l	d0-d7/a0-a6,-(sp)

	tst.b	flagediteur.w
	bne.s	.paledit
	movem.l	palette(pc),d0-d7
	bra.s	.skip
.paledit
	movem.l	palediteur(pc),d0-d7
.skip
	movem.l	d0-d7,$ffff8240.w

;	move	#$300,$ffff8240.w
	bsr	player+4		;joue musique
SCROLLER:
;
; SCROLLEUR 1 PLAN !!!!
;
	MOVE.L	PTRFNT.w,A0		;PTR FONTE COURANT
	ADD.L	PTRCNT.w,A0

	MOVE.L	PTRBUF.w,A1
	ADD	PTRCOL.w,A1

	lea	screen+YSCROLL*160+PLANSCROLLER*2,A2

	moveq	#TAILLE-1,D7
AFF_SCR

X	SET	0
	REPT	152/8
	MOVE	(A1)+,X(A2)
X	SET	X+8
	ENDR

	IFNE	X-152
	FAIL
	ENDC

	MOVE.L	(A0)+,D0
	OR	(A1),D0
	MOVE	D0,X(A2)
	SWAP	D0
	MOVE.L	D0,-40(A1)
	MOVE.L	D0,(A1)
X	SET	X+8

	LEA	40-2+4(A1),A1
	LEA	160(A2),A2
	DBRA	D7,AFF_SCR

	ADD.L	#TAILLE*80,PTRBUF.w
	ADD.L	#(FINFONTE-FONTE)*2,PTRCNT.w
	CMP.L	#(FINFONTE-FONTE)*2*(16/STEP),PTRCNT.w	;SCROLLER 4 EN 4
	BLO.S	NEXTPART
	CLR.L	PTRCNT.w
	MOVE.L	#BUFFER,PTRBUF.w

	ADDQ	#2,PTRCOL.w
	CMP	#40,PTRCOL.w
	BNE.S	NOCOL40
	CLR	PTRCOL.w
NOCOL40:
	NOT	PARITE.w
	BEQ.S	SHIFT16
	ADD.L	#2*2*TAILLE,PTRFNT.w
	BRA.S	NEXTPART
SHIFT16
	MOVE.L	PTRTXT.w,A0
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BPL.S	NOTEND
	LEA	TEXTE,A0
	MOVE.B	(A0)+,D0
NOTEND:	MOVE.L	A0,PTRTXT.w
;	ASL	#6+1,D0
	MULU	#TAILLE*8,D0
	ADD.L	#PREDEC,D0
	MOVE.L	D0,PTRFNT.w
NEXTPART:

	IFEQ	AFFLOGO
	tst.b	flagediteur.w
	beq	.nologo
;
; affichage du logo
;
	lea	logo,a0
	lea	$fc0000,a0
	lea	screen+4,a1
x	set	0
	rept	100
	move.l	(a0)+,x(a1)
	move.l	(a0)+,x+8(a1)
	move.l	(a0)+,x+8*2(a1)
	move.l	(a0)+,x+8*3(a1)
	move.l	(a0)+,x+8*4(a1)
	move.l	(a0)+,x+8*5(a1)
	move.l	(a0)+,x+8*6(a1)
	move.l	(a0)+,x+8*7(a1)
x	set	x+160
	endr
.nologo
	ENDC
;
; gestion clavier
;
	move.b	$fffffc02.w,d0
	cmp.b	lastkey.w,d0
	beq.s	.nonew
	move.b	d0,lastkey.w
	move.b	d0,key.w
.nonew
;	clr	$ffff8240.w
	movem.l	(sp)+,d0-d7/a0-a6
	rte
HBL:
	CLR.B	$FFFFFA1B.W
	MOVE	D0,-(SP)
	PEA	(A0)
	LEA	$FFFF8209.W,A0
.1	MOVE.B	(A0),D0
	CMP.B	(A0),D0
	BEQ.S	.1
.2	move.b	(A0),d0
	cmp.b	(A0),d0
	bne.s	.2
	move.b	#0,$ffff820a.w

;	dcb.w	21,$4e71		;21*4 cycles

;	dcb.w	21-5,$4e71		;64 cycles
	move	#(64-8-6)/2,d0	;8
	lsr	d0,d0		;6+2n

	move.l	(sp)+,A0		;3
	move	(sp)+,d0		;2

	move.b	#2,$ffff820a.w
	MOVE.B	#YSCROLL-200,$FFFFFA21.W
	MOVE.L	#HBL2,$120.W
	MOVE.B	#8,$FFFFFA1B.W
	rte
HBL2:	clr.b	$fffffa1b.w
	move	#$640,$ffff8242.w
	addq	#1,sync.w
	rte
;
; structure des donn‚es qui suivent :
;
;	0.w=type de l'image
;		0=Julia
;		-1=Mandelbrot
;	2,4.w=c
;	6
TBL	MACRO
	DC.W	\1,\2,\3,\4,\5-(\6*10),\6,\7
	ENDM
;
; revoir le nb d'it‚rations !!!!
;
table:
	TBL	$0000,$0A82,$0FA0,$C180,$2EE0,$0064,$0020	;1
	TBL	$0000,$0834,$0000,$C180,$2EE0,$0064,$0080	;2
	TBL	$FFFF,$0000,$0000,$E0C0-56*10,$0960+64*10,$000A,$0020	;3
	TBL	$0000,$0A82,$0FA0,$DB58,$24A8,$0028,$0026	;4
	TBL	$0000,$0956,$0FA0,$C180,$2EE0,$0064,$0020	;5
	TBL	$0000,$0A96,$0FA0,$0032,$11AC,$0002,$0050	;6
	TBL	$FFFF,$0000,$0000,$C000,$0FA0+40*32,$0028,$0020	;7
	TBL	$FFFF,$0000,$0000,$D120,$00F0,$0002,$0032	;8
	TBL	$FFFF,$0000,$0000,$E4A8,$0708,$0003,$0040	;9
	TBL	$FFFF,$0000,$0000,$E764,$04B0,$0001,$0080	;10
	TBL	$0000,$0960,$0096,$C180,$2EE0,$0064,$0020	;11
	TBL	$FFFF,$0000,$0000,$C180,$2467,$004E,$0020	;12
	TBL	$0000,$0C80,$0BB8,$C180,$2EE0,$0064,$0020	;13
	TBL	$0000,$0000,$1A90,$C180,$2EE0,$0064,$0020	;14
	TBL	$0000,$E2B4,$0000,$C180,$2EE0,$0064,$0020	;15
fintable:


palette:
	DC.W	$000,$007,$037,$057,$077,$075,$073,$070
	DC.W	$370,$570,$770,$750,$730,$700,$503,$305
palediteur:
	dc.w	$000,$545,$434,$767
	dcb.w	16-4,$700

player:	INCBIN	REPLAY.BIN
musique:incbin	SEVGATE4.MUS
;
FONTE:
	INCBIN	FONTE.BIN
	ds.w	TAILLE*2
FINFONTE:

mess1:	dc.b	'M'-'A','A'-'A','N'-'A','D'-'A',43,-2
mess2:	DC.B	'J'-'A','U'-'A','L'-'A','I'-'A','A'-'A',-2
hexa:	dc.b	0,0,0,0,-2
mess:
	dc.b	'N'-'A','E'-'A','X'-'A','T'-'A'
	dc.b	-1
	dc.b	'T'-'A','Y'-'A','P'-'A','E'-'A',-1
	dc.b	SPACE,'C'-'A','A'-'A',-1
	dc.b	SPACE,'C'-'A','B'-'A',-1
	dc.b	SPACE,'Z'-'A','A'-'A',-1
	dc.b	SPACE,'Z'-'A','B'-'A',-1
	dc.b	'S'-'A','T'-'A','E'-'A','P'-'A',-1
	dc.b	'I'-'A','T'-'A','E'-'A','R'-'A'
	dc.b	-2
;
	IFNE	LOAD_TEXT
CONVTBL:
	DC.B	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	DC.B	"!?:'0123456789()-.,"
	dc.b	" ",0
	ENDC
	even
TEXTE
	IFEQ	LOAD_TEXT
	INCBIN	SCROLLER.BIN
	ELSEIF
	DC.B	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	DC.B	"!?:'0123456789()-.,"
	dc.b	" "
	DC.B	"WHAT ABOUT A LITTLE TRIP IN MANDELBROT AND JULIA LANDS ?  "
	DC.B	"LET'S START AGAIN...                    "
	DC.B	$FF
	ENDC

	EVEN
PREDEC:
;	DS.B	2*(16/STEP)*(FINFONTE-FONTE)
;	DS.W	1
FINPREDEC:equ	PREDEC+2*(16/STEP)*(FINFONTE-FONTE)+2
BUFFER	EQU	FINPREDEC
	;DS.B	(16/STEP)*TAILLE*80	;BUFFER POUR SCROLLER
	even
carres:	EQU	BUFFER+(16/STEP)*TAILLE*80
;	ds.b	65536*4+4
	list
fincarres:	EQU	carres+65536*4+4
;	DC.L	screen-fincarres	;nb bytes free
