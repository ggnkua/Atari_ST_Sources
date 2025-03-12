	OPT	O+,OW2-
;	OPT	X+
	OUTPUT	LOADER.PRG
DEMONUM=$4FE
floplock=$42E
LOADED=$42F
BUFFER1=$430
BUFFER2=$434
BUFFER3=$438
;
; ORG $62000
;
; COEFF_TOT.W=0 A 127
;
ECRAN1=$80000-32000
ECRAN0=ECRAN1-32000
PLANSCROLLER=4
PLANLOADING=6
PLANSTARS=0
SCROLLER_SPEED=2
nb_stars=220

COEF=16
PROFMAX=600
prof1=80*2*2
prof2=200*2*2

	offset	$300
debut_offset:
fade:	ds.w	1
shift:	ds.w	1
cptbuf:	ds.w	1
ptrmess:ds.l	1
debutmess:ds.l	1
ptrdep:	ds.l	1
cptdep:	ds.w	1
xdep:	ds.w	1
ydep:	ds.w	1
zdep:	ds.w	1
ADR_ECRAN:DS.L	1
push_stars:ds.l	1

OFFSET		DS.W	1
COEFF1		DS.W	1
COEFF2		DS.W	1
COEFF_TOT	DS.W	1    <=COEFF. D'AGRANDISSEMENT SUR 7 BITS
COEFF1_FLAG	DS.W	1
COEFF2_FLAG	DS.W	1
MOUVEMENT1	DS.B	1
MOUVEMENT2	DS.B	1

fin_offset:
	section	text

	lea	debut_offset.w,a0
	moveq	#(fin_offset-debut_offset)/2-1,d0
cleare:	clr	(a0)+
	dbra	d0,cleare

	MOVE	DEMONUM.W,D0
	add	d0,d0
	lea	messages(pc),a0
	add	-2(a0,d0.w),a0
	move.l	A0,ptrmess.w
	move.l	A0,debutmess.w

	MOVE	#256,COEFF1.W
	MOVE	#256,COEFF2.W
	ST	MOUVEMENT2.W

	LEA	MUL160(PC),A0
	MOVEQ	#0,D0
.MUL	MOVE	D0,(A0)+
	ADD	#160,D0
	CMP	#160*200,D0
	BLO.S	.MUL

;	clr	shift.w
;	clr	cptbuf.w
	CLR	push1
	CLR	push2			;nb points
;	clr	cptdep.w
	MOVE.L	#push1,push_stars.w
	move.l	#deplacements,ptrdep.w

RND	MACRO
	MULU	#9,D7
	ADDQ	#1,D7
	ENDM

	lea	stars,a0
	moveq	#0,d7		;RND
	move	#nb_stars-1,d6
.init
	RND
	move	d7,(a0)+	;X
	RND
	move	d7,(a0)+	;Y

	RND
	MOVE	D7,D0
	BPL.S	1$
	NEG	D0
	AND	#511,D0
	NEG	D0
	BRA.S	2$
1$
	AND	#511,D0
2$
	move	d0,(a0)+	;Z
	dbra	d6,.init

	LEA	PREDIV,A0
	MOVEQ	#1,D7
.NEXT
	MOVE.L	#$7FFF,D0
	DIVS	D7,D0
	MOVE	D0,(A0)+

	ADDQ	#1,D7
	CMP	#PROFMAX,D7
	BLO.S	.NEXT
	lea	music(pc),a0
	moveq	#1,d0
	bsr	replay

*	GENERATION DU CODE EFFACANT LA SURFACE AFFICHEE

	MOVE	#5*160,D4
	LEA	CLS_SCREEN(PC),A1
	LEA	CODE,A2

	MOVE	#200-10-1,D7
BC_LIGNE2
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0

	moveq	#$f,d2
	and	d0,d2		;longueur
	eor	d2,d0		;coordonn‚e
	LSR	#1,D0
	add	D4,D0

BC_DEPACK
	MOVE	#$3140,(A2)+	;MOVE D0,D16(A0)
	MOVE	D0,(A2)+	;OFFSET
	ADDQ	#8,D0
	DBRA	D2,BC_DEPACK
	ADD	#160,D4
	DBRA	D7,BC_LIGNE2
	MOVE	#$4E75,(A2)+	;RTS DE FIN

*	COPIE DE LA TABLE DE COORDONNEE

	LEA	PACKED_COORDS(PC),A0
	LEA	FIN_TABLE_COORD(PC),A1
	LEA	TABLE_COORD(PC),A2
	CLR	D0
	CLR	D1
	move	#5120/4-1,d7
.depk
	ADD.B	(A0)+,D0
	ADD.B	(A0)+,D1
	EXT	D0
	EXT	D1
	MOVE	D0,(A1)+
	MOVE	D1,(A1)+
	MOVE	D0,(A2)+
	MOVE	D1,(A2)+
	dbra	d7,.depk

	*GENERATION DU CODE ET DE LA TABLE POUR LE TRACE DE LIGNE
*LIGNE NORMALE

	LEA	DRTX(PC),A0
	LEA	DRTY,A2
	LEA	DRT45,A4
	LEA	TABLE_JMP_X(PC),A1
	LEA	TABLE_JMP_Y(PC),A3
	LEA	TABLE_JMP_45(PC),A5
	MOVE	#$8000,D0		;DECALAGE

	MOVEQ	#19,D7
BC_BLOC
BC_PIXEL
	MOVE	#$0050,(A0)+	OR #$XXXX,(A0)
	MOVE	D0,(A0)+
	MOVE.L	A0,(A1)+
	MOVE	#$D845,(A0)+	ADD D5,D4
	MOVE	#$6402,(A0)+	BCC.S PC+2
	MOVE	#$D0C6,(A0)+	ADD D6,A0

	MOVE	#$0050,(A2)+	OR #$XXXX,(A0)
	MOVE	D0,(A2)+
	MOVE	#$D0C6,(A2)+	ADD D6,A0
	MOVE	#$DA44,(A2)+	ADD D4,D5
	MOVE	#$64F6,(A2)+	BCC.S PC-8
	MOVE.L	A2,(A3)+

	MOVE	#$0050,(A4)+	OR #$XXXX,(A0)
	MOVE	D0,(A4)+
	MOVE.L	A4,(A5)+
	MOVE	#$D0C6,(A4)+	ADD D6,A0

	ROR	#1,D0
	bcc.S	BC_PIXEL

	MOVE	#$5048,(A0)+	ADDQ #8,A0
	MOVE	#$5048,(A2)+
	MOVE	#$5048,(A4)+
	DBRA	D7,BC_BLOC

*LIGNE COURTE
	LEA	DRTX_CRT,A0
	LEA	TABLE_JMP_X_CRT,A1

	MOVEQ	#19,D7
BC_BLOC2

BC_PIXEL2
	MOVE	#$0050,(A0)+	OR	#$XXXX,(A0)
	MOVE	D0,(A0)+
	MOVE.L	A0,(A1)+
	MOVE	#$9845,(A0)+	SUB	D5,D4
	MOVE	#$6A04,(A0)+	BPL.S	PC+4
	MOVE	#$D0C6,(A0)+	ADD	D6,A0
	MOVE	#$D843,(A0)+	ADD	D3,D4

	ROR	#1,D0
	bcc.S	BC_PIXEL2
	MOVE	#$5048,(A0)+	ADDQ	#8,A0
	DBRA	D7,BC_BLOC2

	MOVE.L	#ECRAN0,ADR_ECRAN.w
;	lea	ECRAN0,a0
;	MOVE.L	a0,ADR_ECRAN.w
;	move	#64000/4-1,d0
;	moveq	#0,d1
;cls:	move.l	d1,(a1)+
;	dbra	d0,cls
	move.l	#VBL,$70.w
	rts

PALETTE:
	DC.W	0
	dcb.w	1,$000
	dcb.w	1,$000
	dcb.w	1,$000

	DCB.W	4,$007
	DCB.W	8,$700
NEWPAL:
	DC.W	0
	dcb.w	1,$455
	dcb.w	1,$677
	dcb.w	1,$233

	DCB.W	4,$334
	DCB.W	8,$740

deplacements:
	dc.w	100,0,0,2
	dc.w	300,20*COEF,30*COEF,0
	dc.w	100,0,0,-2
	dc.w	300,20*COEF,30*COEF,0
fin_deplacements:

VBL
	MOVEM.L	D0-D7/A0-A6,-(SP)

	MOVEM.L	PALETTE(PC),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W

	BSR	replay+4

	TST.b	floplock.w
	BNE.S	.NOCHG

	MOVE	#$80,$FFFF8606.W	;EMPECHE BUG...
	MOVE	$FFFF8604.W,D0
	TST.B	D0
	BMI.S	.NOCHG
	MOVE.L	#$0E0E0707,$FFFF8800.W
	TAS.B	floplock.w		;$80=arret du moteur
.NOCHG
; COEFF_TOT.W=0 A 127
	tst.b	LOADED.w
	beq.S	.nofade
	move.b	fade.W,d0
	bne.S	.nofade

	add.b	#$20,fade+1.W	;une fois toutes les 4 VBLs !!!
	bcc.s	.nofade

	lea	PALETTE(pc),a0
	lea	NEWPAL(pc),a1
	moveq	#16-1,d7
.chpal
	move	(a0),d0
	move	(a1)+,d1

	move	#$700,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okr
	bhs.s	.decr
	add	#$100,d0
	bra.s	.okr
.decr
	sub	#$100,d0
.okr
	moveq	#$70,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okv
	bhs.s	.decv
	add	#$10,d0
	bra.s	.okv
.decv
	sub	#$10,d0
.okv
	moveq	#$7,d2
	move	d2,d3
	and	d0,d2
	and	d1,d3
	cmp	d3,d2
	beq.s	.okb
	bhs.s	.decb
	addq	#$1,d0
	bra.s	.okb
.decb
	subq	#$1,d0
.okb
	move	d0,(a0)+
	dbra	d7,.chpal

	addq.b	#1,fade+1.W
	cmp.b	#8,fade+1.W
	blo.S	.FORCE
	st	fade.W
	BRA.S	.FORCE
.nofade
	MOVE.L	BUFFER1.W,D0
	SUB.L	BUFFER2.W,D0
	MOVE.L	BUFFER3.W,D1
	SUB.L	BUFFER2.W,D1
	ASL.L	#7,D0

	MOVEQ	#32-1,D7	;NB BITS RESULTAT
	MOVEQ	#0,D2
.DIV1
	ADD.L	D0,D0
	ADDX.L	D2,D2
	CMP.L	D1,D2
	BLO.S	.DIV2
	SUB.L	D1,D2
	ADDQ	#1,D0
.DIV2
	DBRA	D7,.DIV1

	CMP	#128,D0
	BLO.S	.GOODV
.FORCE	MOVEQ	#127,D0
.GOODV
	MOVE	D0,COEFF_TOT.W

;
; SCROLLER 8*8 MINIMUM
;
scroller
	move	shift.w,d7
	lea	buffer,a0
	move	d7,d0
	mulu	#8*40*2/SCROLLER_SPEED,d0
	add	d0,a0
	add	cptbuf.w,a0

	move.l	ADR_ECRAN.w,a1
	lea	192*160+PLANSCROLLER(a1),a1
	moveq	#8-1,d0
afflig:
	rept	20
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	addq	#8-2,a1
	endr
	lea	40(a0),a0
	dbra	d0,afflig

	move.l	ptrmess.w,a6
	clr	d0
	move.b	(a6)+,d0
	asl	#3,d0
	lea	fonte(PC),a4
	add	d0,a4		;a4=caractŠre … gauche

	clr	d0
	lea	fonte(PC),a5
	move.b	(a6),d0
	bpl.s	.ok
	move.l	debutmess.w,a6
	move.b	(a6),d0
.ok
	asl	#3,d0
	add	d0,a5		;a5=caractŠre … droite

	move	shift.w,d7
	lea	buffer,a0
	move	d7,d0
	mulu	#8*40*2/SCROLLER_SPEED,d0
	add	d0,a0
	add	cptbuf.w,a0

x	set	0
y	set	0
	rept	8
	movep	x(a5),d0
	move.b	(a4)+,d0
	rol	d7,d0
	move.b	d0,y(a0)
	move.b	d0,y+40(a0)
x	set	x+1
y	set	y+80
	endr

	addq	#SCROLLER_SPEED,shift.w
	and	#7,shift.w
	bne.s	no16

	move.l	a6,ptrmess.w

	addq	#1,cptbuf.w
	cmp	#40,cptbuf.w
	blo.s	no16
	clr	cptbuf.w
no16:

	MOVE.L	ADR_ECRAN.w,A0
	IFNE	PLANLOADING
	ADDQ	#PLANLOADING,A0
	ENDC
	MOVEQ	#0,D0
	JSR	CODE		;EFFACE L'ECRAN

	LEA	TABLE_COORD,A1
	ADD	OFFSET.W,A1
	SUB	#40,OFFSET.W
	BHS.S	OK_OFFSET
	ADD	#5120,OFFSET.W
OK_OFFSET

	MOVE	COEFF1.W,D0
	MOVE	COEFF2.W,D1
	MULS	COEFF_TOT.W,D0
	MULS	COEFF_TOT.W,D1
	MOVE	D0,COEFF1_FLAG.W
	MOVE	D1,COEFF2_FLAG.W

	LEA	OPTIM,A0
	MOVEQ	#(FINOPTIM-OPTIM)/2-1,D7	;NB POINTS A PROJETER

	TST.B	LOADED.W
	BEQ.S	.NOTLOAD
	LEA	OPTIM1,A0
	MOVEQ	#(FINOPTIM1-OPTIM1)/2-1,D7	;NB POINTS A PROJETER
.NOTLOAD
	LEA	PROJETE,A6
	MOVE	#100,A3
	MOVE	#160,A4

	MOVE	COEFF1_FLAG.W,D2
	MOVE	COEFF2_FLAG.W,D3
.PROJ
	MOVE	(A0)+,D0
	MOVEM	(A1,D0),D0/D1

	MULS	D2,D0
	MULS	D3,D1

	ADD.L	D0,D0
	ADD.L	D1,D1
	SWAP	D0
	SWAP	D1

	ADD	A4,D0
	ADD	A3,D1
	MOVE	D0,(A6)+
	MOVE	D1,(A6)+

	DBRA	D7,.PROJ

	MOVE.L	ADR_ECRAN.w,A0
	IFNE	PLANLOADING
	ADDQ	#PLANLOADING,A0
	ENDC
	MOVE.L	A0,USP
	LEA	LINE(PC),A3
	LEA	PROJETE,A1
	LEA	MUL160(PC),A4

	TST.B	LOADED.W
	BEQ.S	.NOTLOAD2
	LEA	PTS1,A2
	BRA.S	1$
.NOTLOAD2
	LEA	PTS,A2
	MOVE	(A2)+,D0
	MOVEM	(A1,D0),D0/D2
	MOVE	(A2)+,D1
	MOVEM	(A1,D1),D1/D3
	JSR	(A3)
1$
	rept	57
	MOVE	(A2)+,D0
	MOVEM	(A1,D0),D0/D2
	MOVE	(A2)+,D1
	MOVEM	(A1,D1),D1/D3
	JSR	(A3)
	endr

	MOVE.L	ADR_ECRAN.w,D0
	LSR	#8,D0
	MOVE.L	D0,$FFFF8200.W

	CMP	#127,COEFF_TOT.W
	BNE.S	.NOMOVE
;DEF_X
	TST.B	MOUVEMENT1.W
	BNE.S	.MVT1_2
	ADDQ	#2,COEFF1.W
	CMP	#257,COEFF1.W
	BLT.S	.RTS
	NOT.B	MOUVEMENT1.W
	MOVE	#256,COEFF1.W
	BRA.S	.RTS
.MVT1_2	SUBQ	#2,COEFF1.W
	CMP	#-257,COEFF1.W
	BGT.S	.RTS
	NOT.B	MOUVEMENT1.W
	MOVE	#-256,COEFF1.W
.RTS

;DEF_Y
	TST.B	MOUVEMENT2.W
	BNE.S	.MVT2_2
	ADDQ	#1,COEFF2.W
	CMP	#257,COEFF2.W
	BLT.S	.RTS2
	NOT.B	MOUVEMENT2.W
	MOVE	#256,COEFF2.W
	BRA.S	.RTS2
.MVT2_2	SUBQ	#1,COEFF2.W
	CMP	#-257,COEFF2.W
	BGT.S	.RTS2
	NOT.B	MOUVEMENT2.W
	MOVE	#-256,COEFF2.W
.RTS2
	TST.B	LOADED.W
	BEQ.S	.NOTLOADED
	bsr.S	affiche_stars
.NOTLOADED
.NOMOVE
	EOR.L	#ECRAN0^ECRAN1,ADR_ECRAN.w

	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTE
affiche_stars:
	tst	cptdep.w
	bne.s	.cont
	move.l	ptrdep.w,a0
	move	(a0)+,cptdep.w
	move	(a0)+,xdep.w
	move	(a0)+,ydep.w
	move	(a0)+,zdep.w
	cmp.l	#fin_deplacements,a0
	blo.s	.ok
	lea	deplacements(PC),a0
.ok
	move.l	a0,ptrdep.w
	bra.s	.cont2
.cont	subq	#1,cptdep.w
.cont2
	move.l	push_stars.w,a4
	moveq	#0,d0
	move.l	ADR_ECRAN.w,a6
	IFNE	PLANSTARS
	addq	#PLANSTARS,a6
	ENDC
	move	(a4)+,d7		;nb points
	lsr	#1,d7
	bcc.s	.eff0
	move	(a4)+,d1
	move	d0,(a6,d1.w)
.eff0
	lsr	#1,d7
	bcc.s	.eff1
	move	(a4)+,d1
	move	d0,(a6,d1.w)
	move	(a4)+,d1
	move	d0,(a6,d1.w)
.eff1
	lsr	#1,d7
	bcc.s	.eff2
	movem	(a4)+,d1/d2/d3/d4
	move	d0,(a6,d1.w)
	move	d0,(a6,d2.w)
	move	d0,(a6,d3.w)
	move	d0,(a6,d4.w)
.eff2
	subq	#1,d7
	bmi.s	.fini
.loopeff
	movem	(a4)+,d1/d2/d3/d4/d5/d6/a0/a1
	move	d0,(a6,d1.w)
	move	d0,(a6,d2.w)
	move	d0,(a6,d3.w)
	move	d0,(a6,d4.w)
	move	d0,(a6,d5.w)
	move	d0,(a6,d6.w)
	move	d0,(a6,a0.w)
	move	d0,(a6,a1.w)
	dbra	d7,.loopeff
.fini

	move.l	push_stars.w,a4
	addq	#2,a4
	lea	stars,a6
	move.l	ADR_ECRAN.w,a5
	IFNE	PLANSTARS
	addq	#PLANSTARS,a5
	ENDC
	LEA	PREDIV,A3
;	move	xdep.w,d4
;	move	ydep.w,d5
;	move	zdep.w,d6
	movem	xdep.w,d4/d5/d6
	move	#PROFMAX,a2
	LEA	MUL160(pc),A1

PLOT	MACRO
	movem	(a6)+,d0-d2	;d0=X,d1=Y,d2=Z
	add	d4,d0
	add	d5,d1
	add	d6,d2
	movem	d0-d2,-6(a6)

	CMP	a2,D2
	BHS.S	.noproj\@

	ADD	D2,D2
	MOVE	(A3,D2.W),D3
	MULS	D3,D0
	MULS	D3,D1
	ADD.L	D0,D0
	ADD.L	D1,D1
	SWAP	D0
	SWAP	D1

	add	#160,d0
	add	#100,d1
	cmp	#320,d0
	bhs.s	.noproj\@
	cmp	#200,d1
	bhs.s	.noproj\@

	moveq	#15,d3
	eor	d3,d0
	and	d0,d3
	eor	d3,d0
	lsr	#1,d0

	ADD	D1,D1
	ADD	(A1,D1.W),D0

	clr	d1
	bset	d3,d1
	cmp	#prof1,d2
	ble.s	.proj1\@
	cmp	#prof2,d2
	ble.s	.proj2\@
	or	d1,(a5,d0.w)
	move	d0,(a4)+
.proj1\@
	addq	#2,d0
.proj2\@
	or	d1,(a5,d0.w)
	move	d0,(a4)+
.noproj\@
	ENDM

	move	#nb_stars/10-1,d7
.aff
	rept	10
	PLOT
	endr
	dbra	d7,.aff

	move.l	push_stars.w,a0
	move.l	a4,d0
	sub.l	a0,d0
	lsr	#1,d0
	subq	#1,d0
	move	d0,(a0)

	move.l	#push1,d0
	eor.l	#push2,d0
	eor.l	d0,push_stars.w
	rts

LINE
	MOVEQ	#0,D4
	MOVEQ	#0,D5

	CMP	D0,D1
	BGT.S	OK_SENS1
	EXG	D0,D1
	EXG	D2,D3
OK_SENS1
	MOVEQ	#-16,D6
	AND	D0,D6
	LSR	#1,D6
	MOVE.L	USP,A0
	ADD	D6,A0

	MOVE	D2,D6
	ADD	D6,D6
	ADD	(A4,D6),A0		;*160

	MOVE	#160,D6

	MOVE	D3,D5
	SUB	D2,D5	;Y
	BPL.S	OK_SENS2
	NEG	D5
	NEG	D6
OK_SENS2
	BEQ.S	DROITE_HORIZONTALE

	MOVE	D1,D4
	SUB	D0,D4	;X
	BEQ	DROITE_VERTICALE

	CMP	D4,D5
	BEQ.S	DROITE_45
	BGT.S	DROITE_Y

DROITE_X
	CMP	#20,D5
	BLE	DRT_X_CRT		;ALG. DE BRESENHAM

	ADDQ	#1,D5
	CMP.W	D4,D5
	BNE.S	OK_X
	SUBQ	#1,D5
OK_X	SWAP	D5
	DIVU	D4,D5
DROITE_HORIZONTALE
	LEA	TABLE_JMP_X(PC),A5
	ADD	D1,D1	;XB
	ADD	D1,D1
	MOVE.L	(A5,D1),A6
	MOVE	#$4E75,(A6)

	ADD	D0,D0	;XA
	ADD	D0,D0
	MOVE.L	(A5,D0),A5
	MOVEQ	#0,D4
	JSR	-4(A5)
	MOVE	#$D845,(A6)
	RTS

DROITE_45	LEA	TABLE_JMP_45(PC),A5

	ADD	D1,D1	;XB
	ADD	D1,D1
	MOVE.L	(A5,D1),A6
	MOVE	#$4E75,(A6)

	ADD	D0,D0	;XA
	ADD	D0,D0
	MOVE.L	(A5,D0),A5
	JSR	-4(A5)
	MOVE	#$D0C6,(A6)
	RTS

*AFFICHAGE DE LA DROITE DE COMPOSANTE EN Y

DROITE_Y
	ADDQ	#1,D4
	CMP.W	D4,D5
	BNE.S	OK_Y
	SUBQ	#1,D4
OK_Y	SWAP	D4
	DIVU	D5,D4

	LEA	TABLE_JMP_Y(PC),A5

	ADD	D1,D1	;XB
	ADD	D1,D1
	MOVE.L	(A5,D1),A6
	MOVE	(A6),D1
	MOVE	#$4E75,(A6)

	ADD	D0,D0	;XA
	ADD	D0,D0
	MOVE.L	(A5,D0),A5
	MOVEQ	#0,D5
	JSR	-10(A5)
	MOVE	D1,(A6)
	RTS

DROITE_VERTICALE
	MOVEQ	#$F,D1
	EOR	D1,D0
	AND	D0,D1
	CLR	D0
	BSET	D1,D0
;	AND	#$F,D0
;	ADD	D0,D0
;	MOVE	TABLE_DECALAGE(PC,D0),D0
	OR	D0,(A0)
	DBRA	D5,BC_AFFICHE_VERTICALE
	RTS
BC_AFFICHE_VERTICALE
	ADD	D6,A0
	OR	D0,(A0)
	DBRA	D5,BC_AFFICHE_VERTICALE
	RTS

;TABLE_DECALAGE
;	DC.W	$8000,$4000,$2000,$1000
;	DC.W	$0800,$0400,$0200,$0100
;	DC.W	$0080,$0040,$0020,$0010
;	DC.W	$0008,$0004,$0002,$0001

;ALGO. DE BRESENHAM
DRT_X_CRT	LEA	TABLE_JMP_X_CRT(PC),A5
	ADD	D1,D1	;XB
	ADD	D1,D1
	MOVE.L	(A5,D1),A6
	MOVE	#$4E75,(A6)

	ADD	D0,D0	;XA
	ADD	D0,D0
	MOVE.L	(A5,D0),A5
	MOVE	D4,D3
	JSR	-4(A5)
	MOVE	#$9845,(A6)
	RTS

messages:incbin	messages.bin
	EVEN
fonte:	incbin	newfnt8.bin
	DC.B	0,0,0,%1111100,0,0,0,0

replay:	incbin	mmme.bin
music:	incbin	atomino1.mus

***	TABLES DES VECTEURS	:
***		TOUT LES VECTEURS NON VERTICAUX SONT
***		DECOUPES EN PETIT MORCEAUX POUR DONNER
***		UN EFFET D'ARRONDI
***		A LA RIGUEUR ON PEUT LES SUPPRIMER POUR
***		GAGNER DU TEMPS, MAIS ON PERDRA BEAUCOUP
***		EN BEAUTE (VOIR LE <L> OU ENCORE LE <N>)

OPTIM	DC.W	$3C,$10,$60,$B0
	DC.W	$100,$150,$194,$19C
	DC.W	$1F0,$240,$290,$2DC
	DC.W	$2D4,$280,$230,$1E0
	DC.W	$324,$330,$464,$470
	DC.W	$328,$378,$3C8,$418
	DC.W	$468,$370,$3C0,$410
	DC.W	$4B0,$4C0,$510,$560
	DC.W	$5B0,$5FC,$5F4,$5A0
	DC.W	$550,$500,$690,$6E0
	DC.W	$730,$6F0,$6A0,$740
	DC.W	$7D0,$7E0,$824,$878
	DC.W	$8CC,$920,$910,$AA4
	DC.W	$A50,$A00,$9B0,$964
	DC.W	$96C,$9C0,$A10,$A60
	DC.W	$AAC,$AA8,$A58,$A08
FINOPTIM:

PTS	DC.W	0,4,4,8
	DC.W	8,$C,$C,$10
	DC.W	$10,$14,$18,$1C
	DC.W	$1C,$20,$20,$24
	DC.W	$24,$28,$28,$2C
	DC.W	$2C,$30,$30,$34
	DC.W	$34,$38,$38,$3C
	DC.W	$3C,$18,$40,$44
	DC.W	$48,$4C,$50,$54
	DC.W	$54,$58,$58,$5C
	DC.W	$5C,$60,$40,$64
	DC.W	$64,$68,$68,$6C
	DC.W	$6C,$48,$70,$74
	DC.W	$74,$78,$78,$7C
	DC.W	$7C,$80,$80,$84
	DC.W	$84,$88,$88,$8C
	DC.W	$8C,$90,$90,$94
	DC.W	$94,$70,$98,$9C
	DC.W	$9C,$A0,$9C,$A4
	DC.W	$A8,$A4,$A4,$AC
	DC.W	$B0,$B4,$B0,$B8
	DC.W	$B8,$BC,$BC,$C0
	DC.W	$C0,$C4,$C4,$C8
	DC.W	$CC,$D0,$D0,$D4
	DC.W	$D4,$D8,$D8,$DC
	DC.W	$DC,$E0,$E0,$E4
	DC.W	$E4,$E8,$E8,$EC
	DC.W	$EC,$F0,$F0,$F4
	DC.W	$F4,$F8,$F8,$FC
FINPTS:

OPTIM1	DC.W	$3C,$10,$60,$B0
	DC.W	$100,$150,$194,$19C
	DC.W	$1F0,$240,$290,$2DC
	DC.W	$2D4,$280,$230,$1E0
	DC.W	$324,$330,$464,$470
	DC.W	$328,$378,$3C8,$418
	DC.W	$468,$370,$3C0,$410
	DC.W	$4B0,$4C0,$510,$560
	DC.W	$5B0,$5FC,$5F4,$5A0
	DC.W	$550,$500,$640,$648
	DC.W	$650,$690,$6E0,$730
	DC.W	$780,$698,$6E8,$6A0
	DC.W	$6F0,$740,$790,$7D0
	DC.W	$7E0,$830,$880,$8D0
	DC.W	$91C,$914,$8C0,$870
	DC.W	$820
FINOPTIM1

PTS1	DC.W	0,4,4,8
	DC.W	8,$C,$C,$10
	DC.W	$10,$14,$18,$1C
	DC.W	$1C,$20,$20,$24
	DC.W	$24,$28,$28,$2C
	DC.W	$2C,$30,$30,$34
	DC.W	$34,$38,$38,$3C
	DC.W	$3C,$18,$40,$44
	DC.W	$48,$4C,$50,$54
	DC.W	$54,$58,$58,$5C
	DC.W	$5C,$60,$40,$64
	DC.W	$64,$68,$68,$6C
	DC.W	$6C,$48,$70,$74
	DC.W	$74,$78,$78,$7C
	DC.W	$7C,$80,$80,$84
	DC.W	$84,$88,$88,$8C
	DC.W	$8C,$90,$90,$94
	DC.W	$94,$70,$98,$9C
	DC.W	$9C,$A0,$98,$A4
	DC.W	$A4,$A8,$A8,$AC
	DC.W	$AC,$B0,$9C,$B4
	DC.W	$B4,$B8,$A0,$BC
	DC.W	$BC,$C0,$C0,$C4
	DC.W	$C4,$C8,$CC,$D0
	DC.W	$D0,$D4,$D4,$D8
	DC.W	$D8,$DC,$DC,$E0
	DC.W	$E0,$E4,$E4,$E8
	DC.W	$E8,$EC,$EC,$F0
	DC.W	$F0,$CC
FINPTS1

CLS_SCREEN
;	DC.B	0,0,$91,$91,$83
	DC.B	$83,$83,$83
	DC.B	$84,$75,$75,$75,$75,$75,$75,$75
	DC.B	$67,$67,$67,$67,$67,$67,$67,$67
	DC.B	$67,$67,$67,$68,$59,$59,$59,$59
	DC.B	$59,$59,$59,$59,$59,$59,$59,$59
	DC.B	$59,$59,$59,$59,$59,$5A

	DC.B	$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B

	DCB.B	6,$4B		;$4C
	DCB.B	29,$4B		;$3D
	DCB.B	6,$4B		;$4C

	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B,$4B,$4B,$4B,$4B,$4B
	DC.B	$4B,$4B,$4B
	DC.B	$5A,$59,$59,$59,$59
	DC.B	$59,$59,$59,$59,$59,$59,$59,$59
	DC.B	$59,$59,$59,$59,$59,$68,$67,$67
	DC.B	$67,$67,$67,$67,$67,$67,$67,$67
	DC.B	$67,$75,$75,$75,$75,$75,$75,$75
	DC.B	$84,$83,$83
;	DC.B	$83,$83,$91,$91,0
	EVEN

TABLE_COORD
	DS.B	5120/2
PACKED_COORDS
	INCBIN	coord4.img
	SECTION	BSS
FIN_TABLE_COORD	DS.B	5120
	EVEN

TABLE_JMP_X	DS.L	320
TABLE_JMP_45	DS.L	320
TABLE_JMP_Y	DS.L	320
TABLE_JMP_X_CRT	DS.L	320

MUL160	DS.W	200

DRTX	DS.B	20*(16*10+2)+2
DRT45	DS.B	20*(16*6+2)+2
DRTY	DS.B	20*(16*10+2)+2
DRTX_CRT:DS.B	20*(16*12+2)+2

buffer:	ds.b	40*2*8*8/SCROLLER_SPEED

push1:	ds.w	nb_stars*2+1
push2:	ds.w	nb_stars*2+1
PREDIV:	DS.W	PROFMAX
stars:	ds.w	6*nb_stars
PROJETE:DS.B	(FINOPTIM-OPTIM)*2	;64*4
CODE	DS.B	7914
