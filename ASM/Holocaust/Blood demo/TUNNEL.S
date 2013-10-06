;Tunnel masqu‚.
;Code by Elric/Holocaust.

TEMPS1	=	50*6

NB_PTS_PER_CERCLE = 60
NB_CERCLE = 80
NB_FRAMES = 500

MAIN	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP
	CLR	-(SP)
	PEA	-1.W
	PEA	-1.W
	MOVE	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W

	MOVEQ	#1,D0
	JSR	ZIK

	LEA	ZIK+4,A0
	LEA	RET,A1
	JMP	DEBUT
ZIK	INCBIN	BUGGIN10.MUS
RET	MOVE	#$2700,SR
	MOVE	#$700,$FFFF8240.W
	BRA.S	RET
*********

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
	beq.s	sp3_23
	move.w	d5,$FFFF8240.W
sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

RT_ZIK	MOVEM.L	D0-A6,-(SP)
MODZIK	EQU	*+2
	JSR	$12345678
	MOVEM.L	(SP)+,D0-A6
	RTS
DEBUT
	MOVE.L	A0,MODZIK
	MOVE.L	A1,MODRET
	MOVE.L	#FIN,$008.W
	MOVE.L	#FIN,$00C.W
	MOVE.L	#FIN,$010.W
	MOVE.L	#FIN,$014.W
	LEA	DEB_BSS,A0
	LEA	END_BSS,A1
.KILL	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CMP.L	A1,A0
	BLE.S	.KILL

	MOVE.L	#$00010001,D0
	MOVE.L	D0,$FFFF8240.W
	MOVE.L	D0,$FFFF8244.W
	MOVE.L	D0,$FFFF8248.W
	MOVE.L	D0,$FFFF824C.W
	MOVE.L	D0,$FFFF8250.W
	MOVE.L	D0,$FFFF8254.W
	MOVE.L	D0,$FFFF8258.W
	MOVE.L	D0,$FFFF825C.W

	MOVE.L	#BUFFER,D0
	CLR.B	D0
	MOVE.L	D0,SCREEN1
	ADDI.L	#32000+5*1280,D0
	MOVE.L	D0,SCREEN2

	LEA	TXT,A0
	MOVE.L	SCREEN1,A1
	LEA	160*80(A1),A1
	MOVE.L	SCREEN2,A2
	LEA	160*80(A2),A2
	MOVEQ	#48-1,D7
.AFL
N	SET	0
	REPT	20
	MOVE	(A0),N(A1)
	MOVE	(A0)+,N(A2)
N	SET	N+8
	ENDR
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBF	D7,.AFL

	MOVE.B	SCREEN1+1,$FFFF8201.W
	MOVE.B	SCREEN1+2,$FFFF8203.W
	MOVE.L	#VBL_DEB,$70.W

	LEA	FILE,A0
	JSR	unpack

	BSR	PREPARE_ZOOM

	BSR	PREPARE_FICHIER
	CLR.W	PT
	MOVE.W	#0,Z_DEP
	MOVE.W	#$667,$FFFF8242.W

	MOVE.L	SCREEN1,A1
	MOVE.L	SCREEN2,A2
	MOVE	#7999,D7
.KILLEM	CLR.L	(A1)+
	CLR.L	(A2)+
	DBF	D7,.KILLEM

	MOVE.L	SCREEN1,A1
	MOVE.L	SCREEN2,A2
	MOVE	#200-1,D7
	MOVEQ	#3,D0
.COLONNE	MOVE	D0,152+2(A1)
	MOVE	D0,152+2(A2)
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBF	D7,.COLONNE

	CLR.W	OFF
	CLR.W	ACT

	LEA	FILE,A6
	MOVE.L	A6,PT_FILE
	MOVE.L	#VBL_TUNNEL,$70.W
	CLR	TIME
BOUCLE	BRA.S	BOUCLE
MODRET	EQU	*+2
	JMP	$12345678
FAD_DEB	DC	$001,$112,$223,$334,$445,$556,$667
	DC	$1234
POF	DC	3
TIME	DC	0
VBL_DEB	MOVEM.L	D0-A6,-(SP)
	CMPI	#TEMPS1,TIME
	BLE.S	.GO
	LEA	FAD_DEB,A0
MODF2	EQU	*+2
	LEA	0(A0),A0
	CMPI	#$1234,2(A0)
	BEQ.S	.OK2
	SUBQ	#1,POF
	BNE.S	.OK2
	MOVE	#3,POF
	ADDQ	#2,MODF2
.OK2	MOVE	(A0),$FFFF8240.W
	MOVE	(A0),$FFFF8244.W
	MOVE	(A0),$FFFF8246.W
	BRA.S	.NORM
.GO	LEA	FAD_DEB,A0
MODF	EQU	*+2
	LEA	0(A0),A0
	CMPI	#$1234,2(A0)
	BEQ.S	.OK
	SUBQ	#1,POF
	BNE.S	.OK
	MOVE	#3,POF
	ADDQ	#2,MODF
.OK	MOVE	(A0),$FFFF8242.W
.NORM	JSR	RT_ZIK
	MOVEM.L	(SP)+,D0-A6
	ADDQ	#1,TIME
	RTE
FAD_DEB2	DC	$556,$445,$334,$223,$112,$001,$1234
POF2	DC	2
VBL_TUNNEL	ADDQ	#1,TIME
	CMPI	#NB_FRAMES-7*2,TIME
	BLE.S	.GO
	LEA	FAD_DEB2,A0
MODF4	EQU	*+2
	LEA	0(A0),A0
	CMPI	#$1234,2(A0)
	BEQ.S	.OK2
	SUBQ	#1,POF2
	BNE.S	.OK2
	MOVE	#2,POF2
	ADDQ	#2,MODF4
.OK2	MOVE	(A0),$FFFF8242.W
	BRA.S	.NORM

.GO	LEA	FAD_DEB2,A0
MODF3	EQU	*+2
	LEA	0(A0),A0
	CMPI	#$1234,2(A0)
	BEQ.S	.OK
	SUBQ	#1,POF2
	BNE.S	.OK
	MOVE	#2,POF2
	ADDQ	#2,MODF3
.OK	MOVE	(A0),$FFFF8240.W
	MOVE	(A0),$FFFF8244.W
	;MOVE	#$700,$FFFF8244.W
	MOVE	(A0),$FFFF8246.W
	;MOVE	#$070,$FFFF8246.W
.NORM
	JSR	RT_ZIK
	MOVE.L	SCREEN2,A0
	BSR	EFFAC_SCREEN

	LEA	COURBE_TUNNEL(PC),A0
	MOVE.W	ACT,D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	OFF,D0	;D0=ACT*4+OFF
	MULU.W	#6,D0
	MOVE.W	2(A0,D0.W),D1	;Y_CRB(ACT*4+OFF)=D_Y
	MOVE.W	(A0,D0.W),D0	;X_CRB(ACT*4+OFF)=D_X
.NEXT
	MOVE.W	Z_DEP,D2
	BTST	#3,D2
	BEQ.S	.NAZE
	LEA	24(A0),A0
.NAZE	LSR.W	#4,D2
	MULU.W	#24,D2
	ADDA.W	D2,A0
.FOUND
	;A0=ADRESSE DU POINT DE LA COURBE OU FIGURE LE PREMIER Z>=0
	LEA	(NB_CERCLE-1)*4*6(A0),A0
	LEA	BUF_CALC_ZOOM,A1
	LEA	COEFF_3D,A2
	LEA	CORES_X,A3
	LEA	CORES_Y-200,A4
	MOVE.W	4(A0),D2	;Z_CRB
	SUB.W	Z_DEP,D2
	MOVE.W	D2,D5
	ADD.W	D2,D2
	ADDA.W	D2,A2
	LSL.W	#3,D5
	MOVEQ	#NB_CERCLE-1,D7
.CALC_ALL	MOVE.W	(A2),D2	;COEFF 3D
	MOVE.W	(A0),D3	;X_CRB
	MOVE.W	2(A0),D4	;Y_CRB
	SUB.W	D0,D3
	SUB.W	D1,D4
	ADD.W	D3,D3
	ADD.W	D4,D4
	MULS.W	D2,D3
	MULS.W	D2,D4
	SWAP	D3
	SWAP	D4

	ADD.W	D3,D3
	ADD.W	D3,D3
	ADD.W	D4,D4
	MOVE.W	(A4,D4.W),D4	;Y*160
	ADD.W	2(A3,D3.W),D4	;Y*160+OFFSET_X
	MOVE.W	(A3,D3.W),D3	;((X AND 15)/2)*4
	ADD.W	D5,D3

	MOVE.W	D3,(A1)+
	MOVE.W	D4,(A1)+
	SUBI.W	#16*8,D5
	LEA	-24(A0),A0
	LEA	-32(A2),A2
	DBRA	D7,.CALC_ALL

PT_FILE = *+2
	LEA	$12345678,A1
	LEA	BUF_CALC_ZOOM,A2
	LEA	RETOUR(PC),A5
	MOVE.W	#$4ED5,A3	;CODE DU 'JMP (A5)'
	MOVEQ	#NB_CERCLE-1,D6
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0	;NB DE CERCLES VIDES
	SUB.W	D0,D6
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADDA.W	D0,A2  ;ON COMMENCE AU PREMIER CERCLE VISIBLE
	MOVEQ	#$40,D1
	MOVEQ	#$8,D4
	MOVEQ	#$4,D5

AFF2	MOVE.W	D6,R
	MOVE.W	(A2)+,D2      ;D2=((X AND 15)/2)*4+Z_CRB*32
	MOVE.W	(A2)+,D3	;D3=OFFSET_X

	LEA	ADR_ZOOM,A4
	MOVE.L	(A4,D2.W),A4	;A4=ADR DU CODE
	MOVE.L	SCREEN2,A0
	ADDA.W	D3,A0
	LEA	80+160*100(A0),A0
	MOVEQ	#0,D7
	MOVE.B	(A1)+,D7	;NB DE SEGMENTS-1
	BLT.S	CAS_OU_D7_EST_NUL
	MOVEQ	#$20,D2
	MOVEQ	#$10,D3
	MOVEQ	#$2,D6

AFF	MOVE.W	D7,P

	MOVE.L	A4,A6
	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0	;POINT DE DEPART*4
	ADDA.W	D0,A6
	MOVE.B	(A1)+,D0	;NB DE POINT*4
	MOVE.W	(A6,D0.W),SOV_MOT
	MOVE.W	D0,OFFSET
	MOVE.W	A3,(A6,D0.W)
	MOVEQ	#$80,D0
	MOVEQ	#1,D7
	JMP	(A6)
RETOUR
SOV_MOT = *+2
OFFSET = *+4
	MOVE.W	#$1234,1234(A6)

P = *+2
	MOVE.W	#$1234,D7
	DBRA	D7,AFF
CAS_OU_D7_EST_NUL
R = *+2
	MOVE.W	#$1234,D6
	DBRA	D6,AFF2
	MOVE.L	A1,PT_FILE

	ADDQ.W	#2,OFF
	CMPI.W	#4,OFF
	BLT.S	.OK
	CLR.W	OFF
	ADDQ.W	#1,ACT
.OK
	ADDQ.W	#8,Z_DEP

	BSR	SWAPEC

	ADDQ.W	#1,PT
	CMPI.W	#NB_FRAMES,PT
	BLT.S	.CONT
	CLR.W	PT
	CLR.W	Z_DEP
	CLR.W	OFF
	CLR.W	ACT
	MOVE.L	#FILE,PT_FILE
	MOVE	#$4E71,BOUCLE
.CONT	RTE

SWAPEC	MOVE.L	SCREEN1,D0
	MOVE.L	SCREEN2,SCREEN1
	MOVE.L	D0,SCREEN2
	MOVE.B	SCREEN1+1,$FFFF8201.W
	MOVE.B	SCREEN1+2,$FFFF8203.W
	RTS

FIN	MOVE.L	4.W,A0
	JMP	(A0)
	;A0=ADRESSE DE L'ECRAN A EFFACER
EFFAC_SCREEN	MOVEQ	#0,D0
	MOVE.W	#200-1,D7
.EFF	MOVE.W	D0,(A0)
N	SET	8
	REPT	19
	MOVE.W	D0,N(A0)
N	SET	N+8
	ENDR
	LEA	160(A0),A0
	DBRA	D7,.EFF
	RTS


PREPARE_ZOOM	LEA	BUF_COD_ZOOM,A5
	LEA	ADR_ZOOM,A4
	LEA	COEFF_3D(PC),A1
	MOVE.W	#324-1,D6
.AFF2	MOVE.W	(A1),D2	;D2=COEFF
	LEA	CERCLE_DEP(PC),A2
	LEA	BUF_TEMP,A3
	MOVE.W	#NB_PTS_PER_CERCLE-1,D7
.AFF	MOVE.W	(A2)+,D3	;D3=X(N)
	ADD.W	D3,D3
	MULS.W	D2,D3
	SWAP	D3
	MOVE.W	(A2)+,D4	;D4=Y(N)
	ADD.W	D4,D4
	MULS.W	D2,D4
	SWAP	D4
	;D3=X, D4=Y
	MOVE.W	D3,(A3)+	;X_C
	MOVE.W	D4,(A3)+	;Y_C
	DBRA	D7,.AFF
	LEA	TABLE_OR_COD(PC),A6
	MOVEQ	#0,D4
	MOVEQ	#8-1,D5
.ALL_DEC	LEA	BUF_TEMP,A3
	MOVE.L	A5,(A4)+
	MOVE.W	#NB_PTS_PER_CERCLE-1,D7
.MK_COD_1	MOVE.W	(A3)+,D0	;X
	MOVE.W	(A3)+,D1	;Y
	ADD.W	D4,D0	;+DECALAGE
	MOVE.W	D0,D2
	ANDI.W	#15,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	MULS.W	#160,D1
	ANDI.W	#$FFF0,D0
	ASR.W	#1,D0
	ADD.W	2(A6,D2.W),D0
	ADD.W	D1,D0
	MOVE.W	(A6,D2.W),(A5)+
	MOVE.W	D0,(A5)+
	DBRA	D7,.MK_COD_1
	MOVE.W	#$4E75,(A5)+
	ADDQ.W	#2,D4
	DBRA	D5,.ALL_DEC
	ADDQ.W	#8,A1	;4 Z PLUS LOIN
	DBRA	D6,.AFF2
	RTS

	;OR.B Dn,D16(A0) : ($8128+n*$200).W + .W
TABLE_OR_COD	DC.W	$8128,0,$8328,0,$8528,0,$8728,N,$8928,0,$8B28,0,$8D28,0,$8F28,0
	DC.W	$8128,1,$8328,1,$8528,1,$8728,1,$8928,1,$8B28,1,$8D28,1,$8F28,1

PREPARE_FICHIER	LEA	FILE(PC),A0
	MOVE.W	#NB_FRAMES-1,D5
.ALL_FRAMES	MOVEQ	#NB_CERCLE-1,D6
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	SUB.W	D0,D6	;ON SAUTE LES 'VIDES'
.ALL_CERCLES	MOVEQ	#0,D7
	MOVE.B	(A0),D7	;NB DE SEGMENTS
	SUBQ.W	#1,D7	;-1
	MOVE.B	D7,(A0)+
	BLT.S	.NADA
.ALL_SEG	MOVEQ	#0,D0
	MOVE.B	(A0),D0	;POINT DE DEPART
	ADD.W	D0,D0
	ADD.W	D0,D0
	CMPI.W	#$100,D0
	BLT.S	.NO_1
	ILLEGAL
.NO_1	MOVE.B	D0,(A0)+
	MOVEQ	#0,D0
	MOVE.B	(A0),D0	;NB DE POINTS
	ADD.W	D0,D0
	ADD.W	D0,D0
	CMPI.W	#$100,D0
	BLT.S	.NO_2
	ILLEGAL
.NO_2	MOVE.B	D0,(A0)+
	DBRA	D7,.ALL_SEG
.NADA	DBRA	D6,.ALL_CERCLES
	DBRA	D5,.ALL_FRAMES
	RTS

COEFF_3D	INCBIN	COEFF.3DT

CERCLE_DEP	INCBIN	TEST.SIN

COURBE_TUNNEL	INCBIN	CRB.SIN
LONG_CRB = ((*-COURBE_TUNNEL)/6)-1

	DCB.L	16*20,$00000000
N	SET	-128
	REPT	16
	DC.W	0,N,0,N,4,N,4,N,8,N,8,N,12,N,12,N,16,N,16,N,20,N,20,N,24,N,24,N,28,N,28,N
N	SET	N+8
	ENDR
CORES_X
	REPT	16
	DC.W	0,N,0,N,4,N,4,N,8,N,8,N,12,N,12,N,16,N,16,N,20,N,20,N,24,N,24,N,28,N,28,N
N	SET	N+8
	ENDR
	DCB.L	16*20,$00000000

	DCB.W	200,-160
N	SET	-100*160
	REPT	200
	DC.W	N
N	SET	N+160
	ENDR
CORES_Y
	REPT	200
	DC.W	N
N	SET	N+160
	ENDR
	DCB.W	200,-160

TXT	INCBIN	TUNNEL.TXT
FILE	INCBIN	TESTFIN.PAK

	SECTION	BSS
DEB_BSS
	DS.B	104268
	DS.B	256+160+6400
BUFFER	DS.B	64000+6400+6400
SCREEN1	DS.L	1
SCREEN2	DS.L	1
	;
PT	DS.W	1
OFF	DS.W	1
ACT	DS.W	1
Z_DEP	DS.W	1
	;
BUF_CALC_ZOOM	DS.W	NB_CERCLE*3
ADR_ZOOM	DS.L	325*8
BUF_COD_ZOOM	DS.B	628000
BUF_TEMP	DS.W	2*NB_PTS_PER_CERCLE
END_BSS