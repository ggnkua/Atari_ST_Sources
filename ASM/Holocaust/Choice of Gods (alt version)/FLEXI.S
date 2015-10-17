;************************************************************************
;
;                         FLEXI-KILLER-SCROLLER
;
;************************************************************************

; Code by DAN NATO, ZAPPY, ELRIC and ZERIOUL OF HOLOCAUST !!
;
; Gfx by Zappy.
;
; (C) 1992 - HOLOCAUST

X	EQU	5
Y	EQU	63
NB_SPR	EQU	5
NB_DECAL	EQU	8
NB_DEC	EQU	1
PAS	EQU	15*6


DEBUT:	MOVEA.L	A7,A5
	LEA.L 	D_PILE,A7
	MOVE.L 	4(A5),A5
	MOVE.L 	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L 	#$100,D0
	MOVE.L	D0,-(SP)
	MOVE.L	A5,-(SP)
	MOVE	#0,-(SP)
	MOVE	#$4A,-(SP)
	TRAP	#1
	LEA	12(SP),SP

	PEA	0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP	

	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,pal_save
	JSR	TOUT_NOIR
	
	MOVEQ	#1,D0
	JSR	ZIK

*
	CLR.L	PNT_FAD
	CLR.L	PNT_FAD2
	CLR.L	FORCE_DEMO
	move	#0,adag1
	move	#4,adag2
	move	#2,adag3
	MOVE	#2,DONNEE
	MOVE	#-2,DONNEE2
*

	MOVE.L	#BUFFERSCR,D0
	clr.b	D0
	MOVE.L	D0,SCREEN1
	ADD.L	#154*256,D0
	MOVE.L	D0,SCREEN2

	MOVE.L  #CAMEO,A0
	MOVE.L  #routines,A1
	JSR decrunch 

	move.l	#FIN,$8.w
	move.l	#FIN,$c.w
	move.l	#FIN,$10.w
	move.l	#FIN,$14.w
	move	#$2300,sr

	CLR	-(sp)
	PEA	-1.W
	PEA	-1.W
	move #5,-(sp)
	trap #14
	lea 12(sp),sp

	move.l	SCREEN2,d0
	lsr.l	#8,d0	
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	
	move.l $70.w,vbl_save
	move.l $120.w,tb_save

	lea $fffffa07.w,a0
	movep.w (a0),d0
	move d0,mfp_save
	moveq #0,d0

	MOVE.B	$FFFFFA07.W,MFP1
	MOVE.B	$FFFFFA09.W,MFP2
	MOVE.B	$FFFFFA0F.W,MFP3
	MOVE.B	$FFFFFA13.W,MFP4
	MOVE.B	$FFFFFA1B.W,MFP5
	MOVE.B	$FFFFFA21.W,MFP6
	
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	
	MOVE.B	#$12,$FFFFFC02.W
	
	CLR.B	$FFFFFA1B.W
	BSET	#0,$FFFFFA07.W
	BSET	#0,$FFFFFA13.W

	move.l	#RTE,$120.w

	MOVEA.L	SCREEN2,A1
	LEA	routines+34,A0
	MOVE.L	#7999,D0
AFF_CAMEO	MOVE.L	(A0)+,(A1)+
	DBF	D0,AFF_CAMEO
	MOVE.L	#VBL_AF_CAMEO,$70.W

	BSR	PRP_CRB
	BSR	PRP_LET
	MOVE.L	#BUF2CRB,BUF_ACT_CRB
	MOVE.L	#BUF1CRB,ANNEX
	MOVE.W	#64*160,ADDIT
	MOVE.L	#CRB_REBOND,PNT_REBOND
	LEA	CRB_REBOND,A0
	LEA	320(A0),A1
	MOVE.L	-4(A1),-4(A0)

	bsr demo
FIN:
	move #$2700,sr
	MOVE.B	#8,$FFFFFC02.W
	MOVE.B	MFP1,$FFFFFA07.W
	MOVE.B	MFP2,$FFFFFA09.W
	MOVE.B	MFP3,$FFFFFA0F.W
	MOVE.B	MFP4,$FFFFFA13.W
	MOVE.B	MFP5,$FFFFFA1B.W
	MOVE.B	MFP6,$FFFFFA21.W

	movem.l pal_save,d0-d7
	movem.l d0-d7,$ffff8240.w
	move.l vbl_save,$70.w
	move.l tb_save,$120.w
	lea $fffffa07.w,a0
	move mfp_save,d0
	movep.w d0,(a0)

	MOVE.L	#$8080000,$FFFF8800.W
	MOVE.L	#$9090000,$FFFF8800.W
	MOVE.L	#$A0A0000,$FFFF8800.W

	move #$2300,sr

	PEA	0.W
	trap #1


VBL_COUCHE:	MOVEM.L	D0-A6,-(SP)
	CLR.B	$FFFFFA1B.W
	sf	$ffff8240.w
	MOVE.B	#78,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	move.l	#tb,$120.w

	ADDQ.L	#1,TIME
	CMPI.L	#50,TIME
	BGE.S	PHAZ1
	CLR.L	$FFFF8242.W
	CLR	$FFFF8246.W
	CLR	$FFFF824A.W
	CLR.L	$FFFF824C.W
	BRA	SQ
PHAZ1	CMPI.L	#55,TIME
	BGE.S	PHAZ2
	MOVE.L	#$01010111,$FFFF8242.W
	MOVE	#$111,$FFFF8246.W
	MOVE	#$101,$FFFF824A.W
	MOVE.L	#$01110111,$FFFF824C.W
	BRA.S	SQ
PHAZ2	CMPI.L	#60,TIME
	BGE.S	PHAZ3
	MOVE.L	#$01020212,$FFFF8242.W
	MOVE	#$222,$FFFF8246.W
	MOVE	#$102,$FFFF824A.W
	MOVE.L	#$02120222,$FFFF824C.W
	BRA.S	SQ
PHAZ3	CMPI.L	#60,TIME
	BGE.S	PHAZF
	MOVE.L	#$01030213,$FFFF8242.W
	MOVE	#$324,$FFFF8246.W
	MOVE	#$103,$FFFF824A.W
	MOVE.L	#$02130324,$FFFF824C.W
	BRA.S	SQ
PHAZF
	MOVE.L	#$01030214,$FFFF8242.W
	MOVE	#$325,$FFFF8246.W
	MOVE	#$103,$FFFF824A.W
	MOVE.L	#$02140325,$FFFF824C.W
SQ
	JSR	ZIK+8
	move.l	SCREEN1,d0
	move.l	SCREEN2,SCREEN1
	move.l	d0,SCREEN2
	lsr.l	#8,d0	
	move.l	#$ffff8201,a0
	movep	d0,(a0)

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	MOVE.L	PNT_REBOND,A1
	SUBQ.L	#4,A1
	MOVE.L	SCREEN2,A0
	ADDA.W	(A1)+,A0
	LEA	48(A0),A0
	MOVEQ	#0,D0
	JSR	EFFAC
	MOVE.L	PNT_REBOND,A0
	MOVE.W	(A0),D7
	ADDI.W	#48,D7
	LEA	TABLE,A5
	MOVE.L	BUF_ACT_CRB,A2
	ADDA.W	ADDIT,A2

	REPT	9
	MOVE.L	(A5)+,A4
	JSR	(A4)
	ENDR

	MOVE.L	BUF_ACT_CRB,D0
	MOVE.L	ANNEX,BUF_ACT_CRB
	MOVE.L	D0,ANNEX

	SUBI.W	#64,ADDIT
	CMPI.W	#-64,ADDIT
	BNE.S	SUITZ
	MOVE.W	#64*159,ADDIT
SUITZ	ADDQ.L	#2,PNT_REBOND
	MOVE.L	PNT_REBOND,A0
	CMPI.W	#-1,(A0)
	BNE.S	SUIT2Z
	MOVE.L	#CRB_REBOND,PNT_REBOND
SUIT2Z
	movea.l	SCREEN2,A0
	LEA	32000(A0),A0
	movea.l	SCREEN2,A1
	LEA	32000(A1),A1

N	SET	0
N2	SET	0
	REPT	40
	MOVEM.L	N(A0),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,N2(A1)

	MOVEM.L	52+N(A0),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,52+N2(A1)

	MOVEM.L	52*2+N(A0),D0-D7/A2-A6
	MOVEM.L	D0-D7/A2-A6,52*2+N2(A1)

	MOVE.L	52*3+N(A0),D0
	MOVE.L	D0,52*3+N2(A1)

N	SET	N-320
N2	SET	N2+160
	ENDR

	MOVE.L	#1,PNT_FAD

	SF	$FFFF8240.W

	MOVEM.L	(SP)+,D0-A6
	CMPI.B	#$39,$FFFFFC02.W
	BNE.S	NO_CONT
	MOVE.L	#1,FORCE_DEMO
NO_CONT	CMPI.B	#$1,$FFFFFC02.w
	BEQ	FIN
RTE	RTE
VBL_DEL:	
	CLR.B	$FFFFFA1B.W
;0001	42	300
;0010	44	400
;0011	46	300
;0100	48	700
;0101	4A	700
;0110	4C	700
;0111	4E	700
;1000	50	777
;1001	52	300
;1010	54	400
;1011	56	700
;1100	58	700
;1101	5A	700
;1110	5C	700
;1111	5E	700
	move	#$300,$ffff8246.w
	move	#$700,$FFFF824A.W
	move	#$700,$FFFF824C.W
	MOVE	#$700,$ffff824E.w
	move	#$300,$ffff8252.w
	move.l	#$04000300,$ffff8254.w
	move.l	#$07000700,$ffff8258.w
	move.l	#$07000700,$ffff825c.w

	move	#$300,$ffff8242.w
	move	#$400,$ffff8244.w
	move	#$700,$ffff8248.w
*10 = 300
*30 = 500
*50 = 700
	move	#$777,$ffff8250.w

	sf	$ffff8240.w

	MOVE.B	#40,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	move.l	#TBDEL,$120.w

	JSR	ZIK+8
	
	CMPI	#35,DONNEE
	BGE.S	NO_ZOOM
	ADDQ	#1,DONNEE
	SUBQ	#1,DONNEE2

	LEA	tpoitesp1,A0
	LEA	2(A0),A0
	MOVEQ	#0,D0
	MOVE	DONNEE,D0
	SWAP	D0
	MOVE	DONNEE,D0
	MOVEQ	#0,D1
	MOVE	DONNEE2,D1
	SWAP	D1
	MOVE	DONNEE2,D1

	MOVE.L	D1,(A0)+
	MOVE	D1,(A0)+
;	dc.w	-50,-50,-50		1

	MOVE	D1,(A0)+
	MOVE	D0,(A0)+
	MOVE	D1,(A0)+
;	dc.w	-50,50,-50		2

	MOVE.L	D0,(A0)+
	MOVE	D1,(A0)+
;	dc.w	50,50,-50		3	

	MOVE	D0,(A0)+
	MOVE.L	D1,(A0)+
;	dc.w	50,-50,-50		4

	MOVE.L	D1,(A0)+
	MOVE	D0,(A0)+
;	dc.w	-50,-50,50		5	

	MOVE	D1,(A0)+
	MOVE.L	D0,(A0)+
;	dc.w	-50,50,50		6	

	MOVE.L	D0,(A0)+
	MOVE	D0,(A0)+
;	dc.w	50,50,50		7

	MOVE	D0,(A0)+
	MOVE	D1,(A0)+
	MOVE	D0,(A0)+
;	dc.w	50,-50,50		8
NO_ZOOM	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	SUBA.L	A1,A1
	SUBA.L	A2,A2
	SUBA.L	A3,A3
	SUBA.L	A4,A4
	SUBA.L	A5,A5
	SUBA.L	A0,A0
	MOVEA.L	SCREEN2,A6
	LEA	40+(49-10)*160(A6),A6
N	SET	0
	REPT	102+20
	MOVEM.L	D0-A5,N(A6)
	MOVEM.L	D0-D1,N+14*4(A6)
N	SET	N+160
	ENDR
	SUBA.L	A6,A6
	
	move.w	$fffffc02.w,key

	bsr	calcpoint
	bsr	tobj
	bsr	calcrot

	JSR	FLEXI_ROUTY


	move.l	SCREEN2,d0
	move.l	SCREEN1,SCREEN2
	move.l	d0,SCREEN1
	lsr.l	#8,d0	
	move.l	#$ffff8201,a0
	movep	d0,(a0)

	SF	$FFFF8240.W

	CMPI.B	#$39,$FFFFFC02.W
	BNE.S	NO_CONT2
	MOVE.L	#1,FORCE_DEMO
NO_CONT2	CMPI.B	#$3B,$FFFFFC02.w
	BEQ	FIN
	RTE
VBL_WATER
	CLR.B	$FFFFFA1B.W
	move.l	#RTE,$120.w
	MOVEM.L	D0-A6,-(SP)
	JSR	ZIK+8
	
	ADDQ.L	#1,PNT_W4
	CMPI.L	#250,PNT_W4
	BLE	OK2

	MOVEA.L	SCREEN2,A0
	LEA	160*50(A0),A0
	LEA	BUF1CRB+34,A1
	ADDA.L	PNT_W3,A1
	MOVE	#38,D0
AFF_C	MOVE	#39,D1
AFF_L	MOVE.L	(A1)+,(A0)+
	DBF	D1,AFF_L
	DBF	D0,AFF_C
	LEA	PAL_WATER,A0
	ADDA.L	PNT_W,A0
	CMPI.L	#-1,(A0)
	BEQ.S	OK
	MOVE	(A0),$FFFF8242.W
	ADDQ.L	#1,PNT_W2
	CMPI.L	#2,PNT_W2
	BNE.S	OK2
	CLR.L	PNT_W2
	ADDQ.L	#2,PNT_W
	BRA.S	OK2
OK	CMPI.L	#160*39*3,PNT_W3
	BEQ.S	OK2
	ADD.L	#160*39,PNT_W3
	CLR.L	PNT_W
	CLR.L	PNT_W2
OK2	
	move.l	SCREEN2,d0
	lsr.l	#8,d0	
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	MOVEM.L	(SP)+,D0-A6
	RTE

VBL_WAT:	
	CLR.B	$FFFFFA1B.W

	MOVE.L	#$00010005,$FFFF8240.W

	CMPI.B	#$F,$FFFFFC02.W
	BNE.S	NO_TM3
	ST	$FFFF8240.W
NO_TM3
	move.l	#RTE,$120.w

	JSR	ZIK+8
	
	JSR	FLEXI_ROUTY

	move.l	SCREEN2,d0
	move.l	SCREEN1,SCREEN2
	move.l	d0,SCREEN1
	lsr.l	#8,d0	
	move.l	#$ffff8201,a0
	movep	d0,(a0)

	MOVE	#$1,$FFFF8240.W

	CMPI.B	#$39,$FFFFFC02.W
	BNE.S	NO_CONT3
	MOVE.L	#1,FORCE_DEMO
NO_CONT3	CMPI.B	#1,$FFFFFC02.w
	BEQ	FIN
	RTE

VBL_AF_CAMEO	
	MOVEM.L	D0-D7/A0-6,-(SP)
	LEA	FADING,A0
	ADDA.L	PNT_FAD,A0
	MOVEM.L	(A0),D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	CMPI.L	#20*2*16,PNT_FAD
	BGE.S	LA_BAS2
	CMPI.L	#2*2,PNT_FAD2
	BLE.S	LA_BAS
	CLR.L	PNT_FAD2
	ADD.L	#2*16,PNT_FAD
LA_BAS	ADDQ.L	#2,PNT_FAD2
LA_BAS2	JSR	ZIK+8
	MOVEM.L	(SP)+,D0-D7/A0-A6
	cmpI.b	#$1,$fffffc02.w
	beq	FIN
	RTE

VBL_EFF_CAMEO	MOVEM.L	D0-D7/A0-6,-(SP)
	MOVE	#140,D0
	MOVE.L	SCREEN2,A0
	LEA	198*160+40(A0),A0
	MOVE.L	SCREEN2,A1
	LEA	199*160+40(A1),A1
EFF_CAM	MOVEM.L	(A0),D1-D7/A2-A6
	MOVEM.L	D1-D7/A2-A6,(A1)
	MOVEM.L	12*4(A0),D1-D7/A2-A6
	MOVEM.L	D1-D7/A2-A6,12*4(A1)
	LEA	-160(A0),A0
	LEA	-160(A1),A1
	DBF	D0,EFF_CAM
	ADDQ.L	#1,PNT_FAD2
	CMPI.L	#140,PNT_FAD2
	BNE.S	PAS_ENCORE
	MOVE.L	#1,PNT_FAD
PAS_ENCORE	JSR	ZIK+8
	MOVEM.L	(SP)+,D0-D7/A0-A6
	cmpI.b	#$1,$fffffc02.w
	beq	FIN
	RTE
VBL_ZIK	MOVEM.L	D0-D7/A0-6,-(SP)
	SF	$FFFF8240.W
	move.l	SCREEN1,d0
	lsr.l	#8,d0
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	JSR	ZIK+8
	MOVEM.L	(SP)+,D0-D7/A0-A6
	cmpI.b	#$1,$fffffc02.w
	beq	FIN
	RTE

tb	MOVE	#$111,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb20,$120.W
	MOVE.B	#8,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb20	MOVE	#$222,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb21,$120.W
	MOVE.B	#9,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb21	MOVE	#$333,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb22,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb22	MOVE	#$444,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb23,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb23	MOVE	#$555,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb24,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb24	MOVE	#$666,$FFFF8248.W
	move	#$777,$ffff824a.w
	move	#$777,$ffff824c.w
	move	#$777,$ffff824e.w
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb5,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb5
	MOVE	#$777,$FFFF8248.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb2,$120.W
	MOVE.B	#199-78-10-10-10-10-9-8,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE			
tb2
	DCB	127,$4E71
	CLR.B	$FFFF820A.W
	DCB	8,$4E71
	MOVE.B	#2,$FFFF820A.W
	MOVE	#$001,$FFFF8240.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb,$120.W
	BCLR	#0,$FFFFFA0F.W
	RTE			

TBDEL	MOVE	#$111,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb20DEL,$120.W
	MOVE.B	#8,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb20DEL	MOVE	#$222,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb21DEL,$120.W
	MOVE.B	#9,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb21DEL	MOVE	#$333,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb22DEL,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb22DEL	MOVE	#$444,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb23DEL,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb23DEL	MOVE	#$555,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb24DEL,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb24DEL	MOVE	#$666,$FFFF8250.W
	CLR.B	$FFFFFA1B.W
	MOVE.L	#tb5DEL,$120.W
	MOVE.B	#10,$FFFFFA21.W
	MOVE.B	#8,$FFFFFA1B.W
	BCLR	#0,$FFFFFA0F.W
	RTE
tb5DEL
	move.L	#$07770777,$ffff8250.w
	move.l	#$07770777,$ffff8254.w
	move.l	#$07770777,$ffff8258.w
	move.l	#$07770777,$ffff825c.w

	CLR.B	$FFFFFA1B.W
	MOVE.L	#TBDEL,$120.W
	BCLR	#0,$FFFFFA0F.W
	RTE			
VBL_SPR
	MOVEM.L	PIC+2,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W
	MOVE.L	PNT_CRB,A5
	SUBA.L	#12,A5
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	MOVE.L	#0,A0
	MOVE.L	#0,A1
	MOVE.L	#0,A2
	MOVE.L	#0,A3

	MOVE.L	SCREEN2,A4	;O
	ADDA.W	4(A5),A4
N	SET	0
	REPT	Y
	MOVEM.L	D0-D7/A0-A1,N(A4)
N	SET	N+160
	ENDR
	LEA	PAS(A5),A5

	MOVE.L	SCREEN2,A0
	LEA	TABLE_GEN+(36*8),A2
	MOVE.W	2(A5),D1
	MOVE.L	8(A2,D1.W),A1
	ADDA.W	4(A5),A0
	JSR	(A1)
	LEA	PAS(A5),A5

	MOVE.L	#0,A0
	MOVE.L	#0,A1
	MOVEQ	#0,D1

	MOVE.L	SCREEN2,A4	;A
	ADDA.W	4(A5),A4
N	SET	0
	REPT	Y
	MOVEM.L	D0-D7/A0-A1,N(A4)
N	SET	N+160
	ENDR
	LEA	PAS(A5),A5

	MOVE.L	SCREEN2,A4	;N
	ADDA.W	4(A5),A4
N	SET	0
	REPT	Y
	MOVEM.L	D0-D7/A0-A1,N(A4)
N	SET	N+160
	ENDR
	LEA	PAS(A5),A5

	MOVE.L	SCREEN2,A4	;A
	ADDA.W	4(A5),A4
N	SET	0
	REPT	Y
	MOVEM.L	D0-D7/A0-A1,N(A4)
N	SET	N+160
	ENDR
	LEA	PAS(A5),A5

	MOVE.L	SCREEN2,A4	;D
	ADDA.W	4(A5),A4
N	SET	0
	REPT	Y
	MOVEM.L	D0-D7/A0-A1,N(A4)
N	SET	N+160
	ENDR
	LEA	PAS(A5),A5


	*AFFICHAGE EN MOVEM

	MOVE.L	PNT_CRB,A5

	LEA	PREDEC_TAB,A4
	MOVE.W	(A5),D0
	LSR	#1,D0
	MOVE.L	(A4,D0.W),A0
	MOVE.L	SCREEN2,A1
	ADDA.W	4(A5),A1
N	SET	0
	REPT	Y
	MOVEM.L	(A0)+,D0-D7/A2-A3
	MOVEM.L	D0-D7/A2-A3,N(A1)
N	SET	N+160
	ENDR

	MOVE.L	PNT_CRB,A5
	LEA	PAS(A5),A5
	MOVE.L	#0,A4

	MOVE.L	SCREEN2,A3

	LEA	TABLE_GEN+(36*8),A6	;T
	ADDA.W	2(A5),A6
	MOVE.L	A3,A0
	ADDA.W	4(A5),A0
	MOVE.L	A3,A1
	ADDA.W	4(A5),A1
	MOVE.L	(A6)+,A2	;MSK
	MOVE.L	(A6),A6
	JSR	(A6)
	LEA	PAS(A5),A5

	LEA	TABLE_GEN+(12*8),A6	;A
	ADDA.W	2(A5),A6
	MOVE.L	A3,A0
	ADDA.W	4(A5),A0
	MOVE.L	A3,A1
	ADDA.W	4(A5),A1
	MOVE.L	(A6)+,A2	;MSK
	MOVE.L	(A6),A6
	JSR	(A6)
	LEA	PAS(A5),A5

	LEA	TABLE_GEN+(24*8),A6	;N
	ADDA.W	2(A5),A6
	MOVE.L	A3,A0
	ADDA.W	4(A5),A0
	MOVE.L	A3,A1
	ADDA.W	4(A5),A1
	MOVE.L	(A6)+,A2	;MSK
	MOVE.L	(A6),A6
	JSR	(A6)
	LEA	PAS(A5),A5

	LEA	TABLE_GEN+(12*8),A6	;A
	ADDA.W	2(A5),A6
	MOVE.L	A3,A0
	ADDA.W	4(A5),A0
	MOVE.L	A3,A1
	ADDA.W	4(A5),A1
	MOVE.L	(A6)+,A2	;MSK
	MOVE.L	(A6),A6
	JSR	(A6)
	LEA	PAS(A5),A5

	LEA	TABLE_GEN,A6	;D
	ADDA.W	2(A5),A6
	MOVE.L	A3,A0
	ADDA.W	4(A5),A0
	MOVE.L	A3,A1
	ADDA.W	4(A5),A1
	MOVE.L	(A6)+,A2	;MSK
	MOVE.L	(A6),A6
	JSR	(A6)
	LEA	PAS(A5),A5
	CMPI.L	#8,NB_PART
	BNE	SUITV0Z
	JSR	TEST_LET
	CLR.L	NB_PART
SUITV0Z	JSR	SCROLL
	JSR	SCROLL
	
	SF	$FFFF8240.W
	MOVE.L	SCREEN1,D0
	MOVE.L	SCREEN2,SCREEN1
	MOVE.L	D0,SCREEN2
	MOVE.B	SCREEN1+1,$FFFF8201.W
	MOVE.B	SCREEN1+2,$FFFF8203.W

	ADDQ.L	#6,PNT_CRB

	MOVE.L	PNT_CRB,A0
	CMPI.W	#-1,(PAS*6)-6(A0)
	BNE.S	FINF
	MOVE.L	#COURB,PNT_CRB
FINF	
	JSR	ZIK+8
	CMPI.B	#$39,$FFFFFC02.W
	BEQ	FIN
	RTE
SCROLL	MOVE.L	SCREEN2,A0
	LEA	160*192(A0),A0
	LEA	BUF_LET,A1
	REPT	8
	ROXL	(A1)

	ROXL	154(A0)
	ROXL	146(A0)
	ROXL	138(A0)
	ROXL	130(A0)
	ROXL	122(A0)
	ROXL	114(A0)
	ROXL	106(A0)
	ROXL	98(A0)
	ROXL	90(A0)
	ROXL	82(A0)
	ROXL	74(A0)
	ROXL	66(A0)
	ROXL	58(A0)	
	ROXL	50(A0)
	ROXL	42(A0)
	ROXL	34(A0)
	ROXL	26(A0)
	ROXL	18(A0)
	ROXL	10(A0)
	ROXL	2(A0)
	LEA	160(A0),A0
	ADDQ.L	#2,A1
	ENDR
	ADDI.L	#1,NB_PART
	RTS

TEST_LET	MOVEQ	#0,D0
	LEA	TEXTED,A0	
	ADDA.L	POINT,A0
	LEA	FONT8_8,A1
	CMPI.B	#$FF,(A0)
	BNE	SUITTST
	CLR.L	POINT
	LEA	TEXTED,A0
SUITTST	MOVE.B	(A0),D0	
	SUBI.B	#32,D0	
	LSL.W	#3,D0	
	ADDA.L	D0,A1	
	LEA	BUF_LET,A2
	MOVE.B	(A1)+,(A2)
	MOVE.B	(A1)+,2(A2)
	MOVE.B	(A1)+,4(A2)
	MOVE.B	(A1)+,6(A2)
	MOVE.B	(A1)+,8(A2)
	MOVE.B	(A1)+,10(A2)
	MOVE.B	(A1)+,12(A2)
	MOVE.B	(A1)+,14(A2)
	ADDI.L	#1,POINT
	RTS
demo:
	MOVE.L	#text,TEXT_EC
	move.l	#COURB1,COURB_EC
	MOVE	#128-1,COLONNE
	MOVE.L	#4,PLAN
	JSR	INIT_FLEXI

	MOVE.L	#VBL_EFF_CAMEO,$70.W
	CLR.L	PNT_FAD
	CLR.L	PNT_FAD2
WAIT	CMPI.L	#1,PNT_FAD
	BNE.S	WAIT
***
	JSR	EFF_ECR
	
	MOVE.L	#VBL_COUCHE,$70.w
BOUCLE	TST.L	PNT_FAD
	BEQ.S	BOUCLE
	CLR.L	PNT_FAD
	JSR	FLEXI_ROUTY
	TST.L	FORCE_DEMO
	BEQ	BOUCLE
	CLR.L	FORCE_DEMO
	MOVE.L	#VBL_ZIK,$70.W

	JSR	TOUT_NOIR
	JSR	EFF_ECR
	MOVE.L	#text2,TEXT_EC
	move.l	#COURB2,COURB_EC
	MOVE	#128-1,COLONNE
	MOVE.L	#6,PLAN
	JSR	INIT_FLEXI

	MOVE.L	#VBL_DEL,$70.W


BOUCLE2	TST.L	FORCE_DEMO
	BEQ.S	BOUCLE2
	CLR.L	FORCE_DEMO
	MOVE.L	#VBL_ZIK,$70.W

	JSR	TOUT_NOIR
	JSR	EFF_ECR

	LEA	WATER,A0
	LEA	BUF1CRB,A1
	JSR	decrunch
	MOVE.L	#VBL_WATER,$70.W
	
	MOVE.L	#text3,TEXT_EC
	move.l	#COURB3,COURB_EC
	MOVE	#32-1,COLONNE
	MOVE.L	#0,PLAN
	JSR	INIT_FLEXI

	MOVE.L	#VBL_WAT,$70.W

WETA	TST.L	FORCE_DEMO
	BEQ.S	WETA
	CLR.L	FORCE_DEMO
	MOVE.L	#VBL_ZIK,$70.W

	JSR	TOUT_NOIR
	JSR	EFF_ECR

	JSR	MAK_COD
	LEA	PIC+34+128,A0
	BSR	PREDECALET
	MOVE.L	SCREEN1,A0
	MOVE.L	SCREEN2,A1
	MOVE.W	#7999,D7
RECOMEFF	CLR.L	(A0)+
	CLR.L	(A1)+
	DBRA	D7,RECOMEFF

	LEA	COURB,A0
	LEA	FIN_CRB,A1
	MOVE.L	-12(A1),-12(A0)
	MOVE.L	-8(A1),-8(A0)
	MOVE.L	-4(A1),-4(A0)	
	MOVE.W	#((PAS/6)*6)-2,D7
RECOP1	MOVE.L	(A0)+,(A1)+
	MOVE.W	(A0)+,(A1)+
	DBRA	D7,RECOP1
	MOVE.L	#-1,(A1)

	MOVE.L	#COURB,PNT_CRB

	MOVE.L	#VBL_SPR,$70.W
J	JMP	J

INIT_FLEXI
	LEA	EMUL_LINEA,A0
	MOVE.L	A0,D0
	
	move.l a0,lineA_tab

	move.l #pattern,46(a0)
	move #0,50(a0)
	move #0,36(a0)
	move #-1,24(a0)
	move #0,26(a0)
	move #0,28(a0)
	move #0,30(a0)

	bsr text_convert
	
	lea text_buffer_end,a0
	MOVEA.L	TEXT_EC,a1
	lea font,a2
	moveq #0,d0
	move d0,d1
	move #30-1,d7	;30*5=150
text_lp:
	move.b (a1)+,d0
	move.b 3(a2,d0.w),-(a0)
	move.b 2(a2,d0.w),-(a0)
	move.b 1(a2,d0.w),-(a0)
	move.b 0(a2,d0.w),-(a0)
	move.b d1,-(a0)
	dbra d7,text_lp
	move.l a1,text_pt

	lea compteurs,a3
	
	bsr construction
	
	lea ad_routines,a0
	move.l 16(a0),a2	;routine d'effaáage
	move #-4,(a3)	;images
	move #-20,2(a3)	;compteur pour le scroll du buffer de texte 

	
	lea text_buffer_deb,a5
	move.l a5,text_buff_pt
	MOVEM.L	D0-A6,SAVE_ALL
	RTS
	
FLEXI_ROUTY
	MOVEM.L	SAVE_ALL,D0-A6
	moveq #0,d0
	moveq #1,d1
	moveq #2,d2
	moveq #3,d3
	moveq #4,d4

	move.l	#$ffffffff,d6
	move.l text_buff_pt,a5
	move.l SCREEN2,a6
	ADDA.L	PLAN,A6
	jsr (a2)
	move.l (a0)+,a1
	jsr (a1)

	addQ #1,(a3)
	bne END_ROUTY

	move #-4,(a3)
	lea ad_routines,a0
	sub.l d1,text_buff_pt
	
	addQ #1,2(a3)
	bne END_ROUTY
	
	move #-20,2(a3)
	lea text_buffer_deb,a5
	move.l a5,text_buff_pt
	movem.l 70(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,90(a5)
	movem.l 30(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,50(a5)
	movem.l -10(a5),d0-d7/a1/a6
	movem.l d0-d7/a1/a6,10(a5)
	movem.w -20(a5),d0-d4
	movem.w d0-d4,(a5)
	
	move.l text_pt,a1
	lea font,a6
	moveq #0,d0
	move d0,d1
	move #4-1,d7	;4*5=20
text_lp2:
	move.b (a1)+,d0
	cmpi.b	#255,d0
	bne.s	pas_la_fin
	MOVEA.L	TEXT_EC,A1
	move.l a1,text_pt
	move.b (a1)+,d0
pas_la_fin
	move.b 3(a6,d0.w),-(a5)
	move.b 2(a6,d0.w),-(a5)
	move.b 1(a6,d0.w),-(a5)
	move.b 0(a6,d0.w),-(a5)
	move.b d1,-(a5)
	dbra d7,text_lp2
	move.l a1,text_pt
END_ROUTY	
	MOVEM.L	D0-A6,SAVE_ALL
	RTS
	
text_convert:
	MOVEA.L	TEXT_EC,A0
	moveq #-1,d1
convert_lp:
	moveq #0,d0
	move.b (a0),d0
	cmp.b d1,d0
	bne.S convert_suite
	cmp.b #255,1(a0)
	beq.S convert_fin
	addq #1,a0
	bra.s convert_lp
convert_suite:
	cmp.b #$20,d0
	blo.s int2_conv
	cmp.b #$21,d0
	bhi.s int2_conv
	sub #$20,d0
	bra.S next_octet
int2_conv:
	cmp.b #$41,d0
	blo.s int3_conv
	cmp.b #$5a,d0
	bhi.s int3_conv
	sub #$3f,d0
	bra.S next_octet
int3_conv:
	cmp.b #$30,d0
	blo.s int4_conv
	cmp.b #$39,d0
	bhi.s int4_conv
	sub #$14,d0
	bra.S next_octet
int4_conv:
	cmp.b #$27,d0
	blo.s int5_conv
	cmp.b #$29,d0
	bhi.s int5_conv
	addQ #$2,d0
	bra.S next_octet
int5_conv:
	cmp.b #$2e,d0
	bne.s int6_conv
	subQ #$8,d0
	bra.S next_octet
int6_conv:
	cmp.b #$3a,d0
	bne.s int7_conv
	sub #$13,d0
	bra.S next_octet
int7_conv:
	cmp.b #$2c,d0
	bne.s int8_conv
	subQ #$4,d0
next_octet:
	lsl #2,d0
	move.b d0,(a0)+
	bra.S convert_lp
convert_fin:
	rts
int8_conv:
	jmp	FIN

construction:
	movem.l a0-a6/d1/d7,-(sp)
	
	lea off_bolean,a6	;effaáage des bits
	move #125-1,d7	;500 octets
	moveq #0,d6
off_bol_lp:
	move.l d6,(a6)+
	dbra d7,off_bol_lp

	move.l #ad_routines,routs_pt
	lea	PtsFill,a3	;tableau ptsin
	move.l a3,usp
	move.l	COURB_EC,a4
	
	move.l lineA_tab,a6
	lea routines,a5

	move #4-1,d7	;4 pas
pas_lp:
	move d7,-(sp)
	move.l routs_pt,a0
	move.l a5,(a0)+
	move.l a0,routs_pt

	move COLONNE,d7	;128 colonnes
col_lp:

	move #$1e1d,(a5)+	;move.b (a5)+,d7
	move #5-1,d6		;5 lignes
ligne_lp:
	move.b d6,d5		;pour obtenir code du btst
	add.b d5,d5
	addq.b #1,d5
	move.b d5,(a5)+
	move.b #7,(a5)+		;btst.l d4/3/2/1/0,d7
	move.l a5,-(sp)
	move #$6700,(a5)+		;beq.s (offset Ö dÇfinir)

	move.l (a4),(a3)+	;l,c
	move.l 4(a4),(a3)+	;l+1,c
	move.l 4+24(a4),(a3)+	;l+1,c+1
	move.l 24(a4),(a3)+	;l,c+1
	move.l (a4),(a3)	;l,c
	move.l usp,a3
	addq #4,a4

	move #+30000,d4	;ymin
	move #-30000,d5	;ymax
	move 2(a3),d3	;recherche de ymin et ymax
	cmp d3,d4
	ble.s pas_inf1
	move d3,d4
pas_inf1:
	cmp d3,d5
	bge.s pas_sup1
	move d3,d5
pas_sup1:
	move 6(a3),d3
	cmp d3,d4
	ble.s pas_inf2
	move d3,d4
pas_inf2:
	cmp d3,d5
	bge.s pas_sup2
	move d3,d5
pas_sup2: 
	move 10(a3),d3
	cmp d3,d4
	ble.s pas_inf3
	move d3,d4
pas_inf3:
	cmp d3,d5
	bge.s pas_sup3
	move d3,d5
pas_sup3:	
	move 14(a3),d3
	cmp d3,d4
	ble.s pas_inf4
	move d3,d4
pas_inf4:
	cmp d3,d5
	bge.s pas_sup4
	move d3,d5
pas_sup4:
	sub d4,d5	;ymax-ymin
	move d5,d3	;sauve le compteur en y

	move d4,40(a6)	;affichage du polygone avec $a006
aff_lp:	
	MOVEM.L	D0-D7/A0-A6,-(A7)
	jsr	FILL1
	MOVEM.L	(A7)+,D0-D7/A0-A6

	addQ #1,40(a6)
	dbra d5,aff_lp

	REPT 4	;affichage des 4 lignes afin d'obtenir
	move.l (a3)+,38(a6)	; la meme forme qu'avec polyfill.
	move.l (a3),42(a6)

	movem.l d0-d7/a0-a6,-(a7)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	MOVE	38(a6),D0
	MOVE	40(a6),D1
	
	MOVE	42(a6),D2
	MOVE	44(a6),D3

	bsr	DRAW_A_LINE


	movem.l (a7)+,d0-d7/a0-a6

	ENDR
	
	move.l usp,a3

	move #+30000,d0	;xmin
	move #-30000,d1	;xmax
	move (a3),d2	;recherche de xmin et xmax
	cmp d2,d0
	ble.s xpas_inf1
	move d2,d0
xpas_inf1:
	cmp d2,d1
	bge.s xpas_sup1
	move d2,d1
xpas_sup1:
	move 4(a3),d2
	cmp d2,d0
	ble.s xpas_inf2
	move d2,d0
xpas_inf2:
	cmp d2,d1
	bge.s xpas_sup2
	move d2,d1
xpas_sup2: 
	move 8(a3),d2
	cmp d2,d0
	ble.s xpas_inf3
	move d2,d0
xpas_inf3:
	cmp d2,d1
	bge.s xpas_sup3
	move d2,d1
xpas_sup3:	
	move 12(a3),d2
	cmp d2,d0
	ble.s xpas_inf4
	move d2,d0
xpas_inf4:
	cmp d2,d1
	bge.s xpas_sup4
	move d2,d1
xpas_sup4:
	lsr #4,d0	;on obtient le numÇro du groupe de 16 pixels
	lsr #4,d1
	sub d0,d1	;compteur
	lsl #3,d0	;*8 => offset en x
	muls #160,d4	;ymin*160 => offset en y
	add d4,d0	;offset / ad Çcran en .w

	move.l SCREEN1,a0

	move d6,-(sp)
	move d7,-(sp)
	move.l a6,-(sp)
	lea off_bolean,a6
scan_y:		;repÇrage du polygone
	move d0,d4	;sauvegarde des compteurs
	move d1,d2
scan_x:
	move (a0,d4.w),d5
	beq.s or_nul
	clr (a0,d4.w)	;effaáage

	cmp	#$ffff,d5
	beq.s	move1
	move #$006e,(a5)+	;or #$uuuu,vv(a6)
	move d5,(a5)+	;$uuuu
	move d4,(a5)+	;vv=d16
	bra.s	okay
move1	move #$3d46,(a5)+	;move d6,vv(a6)
	move d4,(a5)+	;vv=d16
okay	move d4,d6	;note l'offset pour l'effaáage (tjs >=0)
	lsr #3,d6
	move d6,d7
	and #$0007,d6
	lsr #3,d7
	bset.b d6,(a6,d7.w)
or_nul:
	addq #8,d4	;groupe suivant
	dbra d2,scan_x

	add #160,d0	;ligne suivante
	dbra d3,scan_y

	move.l (sp)+,a6
	move (sp)+,d7
	move (sp)+,d6

	move.l a5,d0	;on peut calculer l'offset pour beq.s
	move.l (sp)+,a1
	sub.l a1,d0
	subq #2,d0
	cmp #127,d0	;ok pour beq.S ?
	blo.s offset_short
	move #$6700,(a1)+	;beq.l
	move.l a5,a0
	move d0,d1
	addq #2,d0
	lsr #1,d1
off_l_lp:
	move -(a0),2(a0)
	dbra d1,off_l_lp
	move d0,(a1)+
	addq #2,a5
	bra.s off_l_fin
offset_short:
	move.b d0,1(a1)		;offset pour le beq.s
off_l_fin:

	cmp.l #routines+200000,a5
	blo.s mem_ok
	jmp	FIN
mem_ok:

	dbra d6,ligne_lp
	addq #4,a4

	dbra d7,col_lp
	add #24,a4

	move (sp)+,d7
	move #$4e75,(a5)+	;rts
	dbra d7,pas_lp



	move.l routs_pt,a0
	move.l a5,(a0)+
	move.l a0,routs_pt

	move #$7e00,(a5)+	;moveq #0,d7
	lea off_bolean,a0	;routine d'effaáage: les bits concernent
	moveq #0,d5	; les mots du premier plan,dans l'ordre;
	move #500-1,d7	; bit=1 effacer plan 1 de ce groupe de 16 
off_oct_lp:		; pixels, ne rien faire sinon.
	move.b (a0)+,d5
	moveq #8-1,d6
off_bit_lp:
	btst d6,d5
	beq.s bit_nul_off
	move #$3d47,(a5)+	;move d7,xx(a6)
	move #499,d4
	sub d7,d4
	lsl #3,d4
	add d6,d4
	lsl #3,d4
	move d4,(a5)+		;offset
	
	cmp.l #routines+200000,a5
	blo.s mem_ok2
	jmp	FIN
mem_ok2:

bit_nul_off:
	dbra d6,off_bit_lp
	dbra d7,off_oct_lp
	
	move #$4e75,(a5)+	;rts

	movem.l (sp)+,a0-a6/d1/d7
	rts

FILL1	MOVEQ.L	#3,D0
	LEA	PtsFill,a0
	LEA	BUF16DA,A1
	
	CLR.W	PNT_261E
LFCA0F4	MOVE.W	6(A0),D1
	MOVE.W	2(A0),D2
	SUB.W	D2,D1
	BEQ.S	LFCA13E
	MOVE.W	EMUL_LINEA-$299A+$29C2,D3
	MOVE.W	D3,D4
	SUB.W	D2,D4
	SUB.W	6(A0),D3
	MOVE.W	D4,D2
	EOR.W	D3,D2
	BPL.S	LFCA13E
	MOVE.W	4(A0),D2
	SUB.W	(A0),D2
	ADD.W	D2,D2
	MULS.W	D2,D4
	DIVS.W	D1,D4
	BPL.S	LFCA12E
	NEG.W	D4
	ADDQ.W	#1,D4
	ASR.W	#1,D4
	NEG.W	D4
	BRA.S	LFCA132
LFCA12E	ADDQ.W	#1,D4
	ASR.W	#1,D4
LFCA132	ADD.W	(A0),D4
	MOVE.W	D4,(A1)+
	ADDQ.W	#1,PNT_261E
LFCA13E	LEA	4(A0),A0
	DBF	D0,LFCA0F4
	MOVE.W	PNT_261E,D0
	BNE.S	LFCA150
	RTS

LFCA150	LEA	BUF16DA,A0
	BSR.S	LFCA1DC
	MOVE.W	PNT_261E,D0
	ASR.W	#1,D0
	SUBQ.W	#1,D0

LFCA16C	MOVE.W	(A1)+,EMUL_LINEA+$26
	MOVE.W	(A1)+,EMUL_LINEA+$2A
	MOVE.W	D0,-(A7)
	MOVE.L	A1,-(A7)
	BSR.S	FILL2
	MOVEA.L	(A7)+,A1
	MOVE.W	(A7)+,D0
	DBF	D0,LFCA16C
	RTS
	
LFCA1DC	SUBQ.W	#2,D0
	BCS.S	LFCA1FC
	MOVE.W	D0,D1
	MOVEA.L	A0,A1
LFCA1E4	MOVE.W	D1,D0
	MOVEA.L	A1,A0
LFCA1E8	MOVE.W	(A0)+,D2
	CMP.W	(A0),D2
	BLE.S	LFCA1F4
	MOVE.W	(A0),-2(A0)
	MOVE.W	D2,(A0)
LFCA1F4	DBF	D0,LFCA1E8
	DBF	D1,LFCA1E4
LFCA1FC	RTS

VALEURS	DC.L	$FFFF7FFF
	DC.L	$3FFF1FFF
	DC.L	$0FFF07FF
	DC.L	$03FF01FF
	DC.L	$00FF007F
	DC.L	$003F001F
	DC.L	$000F0007
	DC.L	$00030001
	DC	$0000


FILL2	
	LEA	EMUL_LINEA-$299A+$299A,A4

	MOVE	$26(A4),D4
	MOVE	$28(A4),D5
	MOVE	$2A(A4),D6

	MOVE.W	D5,D0

	AND.W	50(A4),D0	MASK DU SAMPLE REMPLISSAGE
	ADD.W	D0,D0
	
	MOVEA.L	46(A4),A0	PNTEUR SUR SAMPLE REMPLISSAGE
	ADDA.W	D0,A0	
	
	TST.W	52(A4)	1 OU POLYPLANS
	SNE	D0
	AND.W	#$20,D0
	MOVE.W	D4,D1
	ASR.W	#4,D1
	MOVE.W	D6,D2
	ASR.W	#4,D2
	MOVEQ	#$F,D3
	AND.W	D3,D4
	ADD.W	D4,D4
	MOVE.W	VALEURS(PC,D4.W),D4
	AND.W	D3,D6
	ADD.W	D6,D6
	MOVE.W	VALEURS+2(PC,D6.W),D6
	NOT.W	D6
	SUB.W	D1,D2
	BNE.S	LFCA63C
	AND.W	D6,D4
LFCA63C	

	MOVEA.L	SCREEN1,A1
	MULS.W	#160,D5
	ADDA.L	D5,A1

	MOVEA.W	D0,A2

	MOVE.W	#4,D7	NB PLANS
	MOVE	#8,D0
	MULS.W	D0,D1	
	ADDA.L	D1,A1	A1=SCREEN

	LEA	24(A4),A3	VALEUR DE LA COLOR DU PLAN 0

	NOT.W	D4
	NOT.W	D6
LFD1C56	MOVEA.L	A1,A4
	MOVE.W	D2,D5
	MOVE.W	(A0),D3
	ADDA.W	A2,A0
	TST.W	(A3)+
	BNE.S	LFD1C88
	MOVE.W	D4,D1
	AND.W	D1,(A1)+
	SUBQ.W	#1,D5
	BCS.S	LFD1C7E
	SUBQ.W	#1,D5
	BCS.S	LFD1C78
	CLR.W	D1
LFD1C70	ADDA.W	D0,A4
	MOVE.W	D1,(A4)

	DBF	D5,LFD1C70

LFD1C78	MOVE.W	D6,D1
	ADDA.W	D0,A4
	AND.W	D1,(A4)
LFD1C7E	

	NOT.W	D4
	NOT.W	D6
	RTS

LFD1C88	MOVE.W	(A4),D1
	EOR.W	D3,D1
	AND.W	D4,D1
	EOR.W	D3,D1
	MOVE.W	D1,(A1)+
	SUBQ.W	#1,D5
	BCS.S	LFD1CAE
	SUBQ.W	#1,D5
	BCS.S	LFD1CA2
LFD1C9A	ADDA.W	D0,A4
	MOVE.W	D3,(A4)
	DBF	D5,LFD1C9A
LFD1CA2	ADDA.W	D0,A4
	MOVE.W	(A4),D1
	EOR.W	D3,D1
	AND.W	D6,D1
	EOR.W	D3,D1
	MOVE.W	D1,(A4)

LFD1CAE	DBF	D7,LFD1C56

	NOT.W	D4
	NOT.W	D6
	RTS


	
DRAW_A_LINE
	cmp.w	d1,d3
	beq	DRAW_HORIZONTAL
	cmp.w	d0,d2
	beq	DRAW_VERTICAL

	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0
	move.w	d0,d5
	eor.w	#$0f,d5
	and.w	#$0f,d5
	clr.w	d6
	bset	d5,d6
	move.w	d6,d7
	not.w	d6

	sub.w	d0,d2
	sub.w	d1,d3

	move.l	#0,a1
	move.l	#0,a2
	move.l	#0,a3
	move.l	#0,a4
	
	tst.w	d2
	bpl.s	.dr_1
	beq.s	.dr_2
	move.w	#-1,a1
	neg.w	d2
	bra.s	.dr_2
.dr_1
	move.w	#1,a1
.dr_2
	tst.w	d3
	bpl.s	.dr_3
	beq.s	.dr_4
	move.w	#-1,a2
	neg.w	d3
	bra.s	.dr_4
.dr_3
	move.w	#1,a2
.dr_4
	cmp.w	d2,d3
	blt.s	.dr_5
	move.w	a2,a4
	exg	d2,d3
	bra.s	.dr_6
.dr_5
	move.w	a1,a3
.dr_6 
	move.w	d2,d0
	lsr.w	#1,d0
	move.w	d2,d1
.dr_7
	or.w	d7,(a0)
	add.w	d3,d0
	cmp.w	d0,d2
	bgt.s	.dr_8
	sub.w	d2,d0
	cmp.w	#0,a1
	beq.s	.dr_A5
	bmi.s	.dr_A6
	ror.w	#1,d6
	ror.w	#1,d7
	bcc.s	.dr_A5
	addq.l	#8,a0
	bra.s	.dr_A5
.dr_A6
	rol.w	#1,d6
	rol.w	#1,d7
	bcc.s	.dr_A5
	subq.l	#8,a0
.dr_A5
	cmp.w	#0,a2
	beq.s	.dr_A3
	bmi.s	.dr_A8
	lea	160(a0),a0
	bra.s	.dr_A3
.dr_A8
	lea	-160(a0),a0
	bra.s	.dr_A3
.dr_8
	cmp.w	#0,a3
	beq.s	.dr_A1
	bmi.s	.dr_A2
	ror.w	#1,d6
	ror.w	#1,d7
	bcc.s	.dr_A3
	addq.l	#8,a0
	bra.s	.dr_A3
.dr_A2
	rol.w	#1,d6
	rol.w	#1,d7
	bcc.s	.dr_A3
	subq.l	#8,a0
	bra.s	.dr_A3
.dr_A1
	cmp.w	#0,a4
	bmi.s	.dr_A4
	lea	160(a0),a0
	bra.s	.dr_A3
.dr_A4
	lea	-160(a0),a0
.dr_A3
	dbf	d1,.dr_7
	rts

DRAW_HORIZONTAL
	cmp.w	d0,d2
	bne.s	.dr_h_1
	rts
.dr_h_1
	bgt.s	.dr_h_2
	exg	d0,d2
.dr_h_2
	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0

	move.w	d2,d3
	move.w	d0,d6
	
	and.w	#$fff0,d6
	lsr.w	#4,d6
	and.w	#$fff0,d2
	lsr.w	#4,d2
	
	sub.w	d6,d2

	lea	PIXEL_TABLE_LEFT,a1
	and.w	#$000f,d0
	lsl.w	#1,d0
	move.w	(a1,d0),d0
	lea	PIXEL_TABLE_RIGHT,a1
	and.w	#$000f,d3
	lsl.w	#1,d3
	move.w	(a1,d3),d3

	tst	d2
	bne.s	.dr_h_7
	
	and.w	d0,d3
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7
	bra.s	.dr_h_m_1
.dr_h_7
	subq.w	#1,d2
	bne.s	.dr_h_8
	
	move.w	d0,d6
	move.w	d0,d7
	not.w	d7
	bsr.S	.dr_h_m_1
	
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7
	bra.s	.dr_h_m_1
.dr_h_8
	move.w	d0,d6
	move.w	d0,d7
	not.w	d7
	bsr.S	.dr_h_m_1

	subq.w	#1,d2
	move.w	#$ffff,d6
	clr.w	d7
.dr_h_9
	bsr.S	.dr_h_m_1
	dbf	d2,.dr_h_9
	
	move.w	d3,d6
	move.w	d3,d7
	not.w	d7

.dr_h_m_1
	or.w	d6,(a0)
	lea	8(a0),a0
	rts

DRAW_VERTICAL
	cmp.w	d1,d3
	bgt.s	.dr_v_1
	exg	d1,d3
.dr_v_1
	move.w	d0,d5
	move.w	d1,d6
	ext.l	d5
	ext.l	d6
	lsl.w	#1,d6
	lea	SCREEN_Y_TABLE,a0
	move.l	#0,a1
	move.w	(a0,d6),a1
	movea.l	SCREEN1,a0
	add.l	a1,a0
	and.l	#$fffffff0,d5
	lsr.w	#1,d5
	add.l	d5,a0

	eor.w	#$0f,d0
	and.w	#$0f,d0
	clr.w	d6
	bset	d0,d6
	move.w	d6,d7
	not.w	d7

	sub.w	d1,d3
.dr_v_m_1
	or.w	d6,(a0)

	lea	160(a0),a0
	dbf	d3,.dr_v_m_1
	rts

MAK_COD	MOVE.L	#TABLE_SPR,ANNEX
	LEA	routines,A2
	LEA	TABLE_GEN,A6
	LEA	FIC_OPT,A3	;OPT POUR LE SPRITE(MASK-SPRITE)
	CLR.W	FLAG_EFF
	BSR 	CODING	;D

	ADDQ.L	#4,ANNEX
	LEA	FIC_OPT+512,A3
	CLR.W	FLAG_EFF
	BSR	CODING	;A

	ADDQ.L	#4,ANNEX
	LEA	FIC_OPT+1024,A3
	CLR.W	FLAG_EFF
	BSR	CODING	;N

	ADDQ.L	#4,ANNEX
	LEA	FIC_OPT+1536,A3
	MOVE	#1,FLAG_EFF
	BSR	CODING	;T

;	ADDQ.L	#4,ANNEX
;	LEA	FIC_OPT+2048,A3
;	CLR.W	FLAG_EFF
;	BSR	CODING	;O

	RTS

CODING	
RECOMGENSPR	MOVE.L	ANNEX,A0
	MOVE.L	(A0),A0
	MOVE.L	SCREEN1,A1
	MOVE.L	SCREEN2,A5
	MOVE.W	#Y-1,D6
REAF2	MOVE.W	#X-2,D7
REAF1	MOVE.L	(A0),(A1)+
	MOVE.L	4(A0),(A1)+
	MOVE.W	(A0),D0
	MOVE.W	2(A0),D1
	MOVE.W	4(A0),D2
	OR.W	D2,D0
	OR.W	D1,D0
	NOT.W	D0
	MOVE.W	D0,(A5)+
	ADDQ.L	#8,A0
	DBRA	D7,REAF1
	CLR.L	(A1)+
	CLR.L	(A1)+
	MOVE.W	#-1,(A5)+
	LEA	160-((X-1)*8)(A0),A0
	DBRA	D6,REAF2

	MOVE.L	A3,(A6)+
	MOVE.L	A2,(A6)+
	BSR	COD_GEN
	MOVE.L	A2,(A6)+
	BSR	MAK_EFF
	REPT	NB_DECAL-1
	BSR	DECAL_SPR
	MOVE.L	A3,(A6)+
	MOVE.L	A2,(A6)+
	BSR	COD_GEN
	MOVE.L	A2,(A6)+
	BSR	MAK_EFF
	ENDR
	RTS

DECAL_SPR	MOVE.L	SCREEN2,A1	;MSK
	MOVE.W	#NB_DEC,D4
RECOM_DEC	MOVE.L	SCREEN1,A0	;SPR
	MOVE.W	#Y-1,D5
DEC3	MOVE.W	#3,D6
DEC2	MOVE.W	#X-1,D7
DEC1	ROXR	(A0)
	ADDQ.L	#8,A0
	DBRA	D7,DEC1
	LEA	-((X*8)-2)(A0),A0
	DBRA	D6,DEC2
	LEA	(X-1)*8(A0),A0
	DBRA	D5,DEC3
	DBRA	D4,RECOM_DEC
	MOVE.L	SCREEN1,A0
	MOVE.W	#Y-1,D6
MSK2	MOVE.W	#X-1,D7
MSK1	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	ADDQ.L	#2,A0
	OR.W	D1,D0
	OR.W	D2,D0
	NOT.W	D0
	MOVE.W	D0,(A1)+
	DBRA	D7,MSK1
	DBRA	D6,MSK2
	RTS

COD_GEN	MOVE.L	SCREEN1,A0	;SPR
	MOVE.L	SCREEN2,A1	;MSK
	MOVE.L	#$4CDA00FF,(A2)+
	MOVE.W	#Y-1,D6
CDG2	MOVE.W	#X-1,D7
CDG1	BSR	ANDS
	DBRA	D7,CDG1
	MOVE.W	#$41E8,(A2)+
	MOVE.W	#160-(X*8),(A2)+
	BSR	OPTI_ADDQ_ANDS
 	DBRA	D6,CDG2
	LEA	32(A3),A3
	MOVE.L	SCREEN1,A0	;SPR
	MOVE.L	SCREEN2,A1	;MSK
	MOVE.L	#$4CDA00FF,(A2)+
	MOVE.W	#Y-1,D6
CDG4	MOVE.W	#X-1,D7
CDG3	BSR	ORS
	DBRA	D7,CDG3
	MOVE.W	#$43E9,(A2)+
	MOVE.W	#160-(X*8),(A2)+
	BSR	OPTI_ADDQ_ORS
	DBRA	D6,CDG4
	LEA	32(A3),A3
	SUBQ.L	#4,A2
	MOVE.W	#$4E75,(A2)+
	RTS

ANDS	TST.W	(A1)
	BEQ.S	NO_MASK
	CMPI.W	#-1,(A1)
	BEQ.S	NO_MASK
	;TST.L	0(A0)
	;BEQ	AND1
	MOVE.W	#$C158,D4
	MOVE.W	#$C198,D5
	CLR.W	ADD1
	MOVE.W	(A1),D0
	MOVE.W	#7,D3
CHERCHMSK	CMP.W     	(A3),D0
	BEQ.S	MSKTROUVê
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	ADDI.W	#$200,D5
	ADDQ.W	#4,ADD1
	DBRA	D3,CHERCHMSK
	LEA	-32(A3),A3
	MOVE.W	#$0298,(A2)+
	MOVE.W	(A1),(A2)+
	MOVE.W	(A1),(A2)+
	MOVE.W	#$0258,(A2)+
	MOVE.W	(A1),(A2)+
	MOVE.W	#$5448,(A2)+
;	ADDQ.W	#1,ADD
	BRA.S	FIN_MASK
MSKTROUVê	SUBA.W	ADD1,A3
	MOVE.W	D5,(A2)+
	MOVE.W	D4,(A2)+
	MOVE.W	#$5448,(A2)+
;	ADDQ.W	#1,ADD
	BRA.S	FIN_MASK
NO_MASK	MOVE.W	#$5048,(A2)+
	BSR	OPTI_ADDQ_ANDS
;	ADDQ.W	#1,ADD
FIN_MASK	ADDQ.L	#2,A1
	ADDQ.L	#8,A0
	RTS

AND1	MOVE.W	#$0258,(A2)+
	MOVE.W	(A1),(A2)+
	MOVE.W	#$5C48,(A2)+
	BRA	FIN_MASK

OPTI_ADDQ_ANDS:
	CLR.W	VARI
	MOVE.W	#$5048,D1	;ADDQ.W	#8,A0
	MOVE.W	#$5448,D2	;ADDQ.W	#2,A0
	MOVE.W	#$41E8,D3	;LEA	#IMM(A0),A0
CONTANDQ	CMP.W	-2(A2),D1
	BNE.S	ANDQ2
	ADDQ.W	#8,VARI
	SUBQ.L	#2,A2
	BRA	CONTANDQ
ANDQ2	CMP.W	-2(A2),D2
	BNE.S	ANDQ3
	ADDQ.W	#2,VARI
	SUBQ.L	#2,A2
	BRA	CONTANDQ
ANDQ3	CMP.W	-4(A2),D3
	BNE.S	FINANDQ
	MOVE.W	-2(A2),D4
	ADD.W	D4,VARI
	SUBQ.L	#4,A2
	BRA	CONTANDQ
FINANDQ	TST.W	VARI
	BEQ	SORTANDQ
	CMPI.W	#8,VARI
	BGT	CHANDQ2
	CMPI.W	#2,VARI
	BNE.S	CH1
	MOVE.W	#$5448,(A2)+
	BRA.S	SORTANDQ
CH1	CMPI.W	#4,VARI
	BNE.S	CH11
	MOVE.W	#$5848,(A2)+
	BRA.S	SORTANDQ
CH11	CMPI.W	#6,VARI
	BNE.S	CH111
	MOVE.W	#$5C48,(A2)+
	BRA.S	SORTANDQ
CH111	MOVE.W	#$5048,(A2)+
	BRA.S	SORTANDQ
CHANDQ2	MOVE.W	#$41E8,(A2)+
	MOVE.W	VARI,(A2)+
SORTANDQ	RTS

OPTI_ADDQ_ORS:
	CLR.W	VARI
	MOVE.W	#$5449,D0
	MOVE.W	#$5849,D1
	MOVE.W	#$5C49,D2
	MOVE.W	#$5049,D3
	MOVE.W	#$43E9,D4
CONTORQ	CMP.W	-2(A2),D0
	BNE.S	ORQ2
	ADDQ.W	#2,VARI
	SUBQ.L	#2,A2
	BRA.S	CONTORQ
ORQ2	CMP.W	-2(A2),D1
	BNE.S	ORQ3
	ADDQ.W	#4,VARI
	SUBQ.L	#2,A2
	BRA.S	CONTORQ
ORQ3	CMP.W	-2(A2),D2
	BNE.S	ORQ4
	ADDQ.W	#6,VARI
	SUBQ.L	#2,A2
	BRA.S	CONTORQ
ORQ4	CMP.W	-2(A2),D3
	BNE.S	ORQ5
	ADDQ.W	#8,VARI
	SUBQ.L	#2,A2
	BRA.S	CONTORQ
ORQ5	CMP.W	-4(A2),D4
	BNE.S	SORTORQ
	MOVE.W	-2(A2),D0
	ADD.W	D0,VARI
	MOVE.W	#$5449,D0
	SUBQ.L	#4,A2
	BRA.S	CONTORQ
SORTORQ	TST.W	VARI
	BEQ	FINORQ
	CMPI.W	#8,VARI
	BGT	CHORQ2
	CMPI.W	#2,VARI
	BNE.S	ORQ11
	MOVE.W	#$5449,(A2)+
	BRA	FINORQ
ORQ11	CMPI.W	#4,VARI
	BNE.S	ORQ111
	MOVE.W	#$5849,(A2)+
	BRA	FINORQ
ORQ111	CMPI.W	#6,VARI
	BNE.S	ORQ1111
	MOVE.W	#$5C49,(A2)+
	BRA	FINORQ
ORQ1111	MOVE.W	#$5049,(A2)+
	BRA	FINORQ
CHORQ2	MOVE.W	#$43E9,(A2)+
	MOVE.W	VARI,(A2)+
FINORQ	RTS

ORS	TST.W	(A1)
	BEQ	AFF_MOV
	CMPI.W	#-1,(A1)
	BEQ	NO_AFF
	TST.L	(A0)
	BEQ	AFF3
	TST.L	2(A0)
	BEQ	AFF1
	TST.W	(A0)
	BEQ	AFF23
	TST.W	4(A0)
	BEQ	AFF12
;	TST.W	2(A0)
;	BEQ	AFF13
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CMP.W	2(A0),D0
	BEQ	COMPARE1
	BRA	NOT1SAME
APRES1COMP	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP1	CMP.L	(A3),D0
	BEQ.S	TROUVê1
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP1
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVê1	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

COMPARE1	CLR.W	ADD1
	SWAP	D0
	MOVE.W	2(A0),D0
	MOVE.W	#$8199,D4
	MOVE.W	#7,D3
CHERCHCOMP1	CMP.L	(A3),D0
	BEQ.S	TROUVêC1
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHCOMP1
	LEA	-32(A3),A3
	MOVE.W	#$0099,(A2)+
	MOVE.L	(A0),(A2)+
	BRA	APRES1COMP
TROUVêC1	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	BRA	APRES1COMP

NOT1SAME	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSPA	CMP.L	(A3),D0
	BEQ.S	TROUVêA
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSPA
	LEA	-32(A3),A3
	MOVE.W	#$0099,(A2)+
	MOVE.L	(A0),(A2)+
	BRA	APRES1COMP
TROUVêA	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	2(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSPB	CMP.L	(A3),D0
	BEQ.S	TROUVêB
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSPB
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	2(A0),(A2)+
	BRA	APRES1COMP
TROUVêB	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	BRA	APRES1COMP


AFF13	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP13	CMP.L	(A3),D0
	BEQ.S	TROUVê13
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP13
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	CONT2
TROUVê13	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD

CONT2	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP1_3	CMP.L	(A3),D0
	BEQ.S	TROUVê1_3
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP1_3
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVê1_3	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	
	BRA	FIN_AFF

AFF3	MOVE.W	#$5849,(A2)+
	BSR	OPTI_ADDQ_ORS
;	ADDQ.W	#1,ADD
	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP3	CMP.L	(A3),D0
	BEQ.S	TROUVê3
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP3
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVê3	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

AFF1	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP11	CMP.L	(A3),D0
	BEQ.S	TROUVê11
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP11
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	(A0),(A2)+
	MOVE.W	#$5C49,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVê11	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5C49,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

AFF12	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CMP.W	2(A0),D0
	BEQ	COMPARE2
	MOVE.W	#$0099,(A2)+
	MOVE.L	(A0),(A2)+
APRES2COMP	MOVE.W	#$5849,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

COMPARE2	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHCOMP2	CMP.L	(A3),D0
	BEQ.S	TROUVêC2
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHCOMP2
	LEA	-32(A3),A3
	MOVE.W	#$0099,(A2)+
	MOVE.L	(A0),(A2)+
	BRA	APRES2COMP
TROUVêC2	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	D4,(A2)+
	BRA	APRES2COMP

AFF23	BSR	OPTI_ADDQ_ORS
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	TST.W	4(A0)
	BEQ	AFF2
	MOVE.W	#$0099,(A2)+
	MOVE.L	2(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
AFF2	MOVEQ	#0,D0
	MOVE.W	2(A0),D0
	CLR.W	ADD1
	MOVE.W	#$8159,D4
	MOVE.W	#7,D3
CHERCHSP2	CMP.L	(A3),D0
	BEQ.S	TROUVê2
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#$200,D4
	DBRA	D3,CHERCHSP2
	LEA	-32(A3),A3
	MOVE.W	#$0059,(A2)+
	MOVE.W	2(A0),(A2)+
	MOVE.W	#$5849,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVê2	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5849,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

AFF_MOV	TST.L	(A0)
	BEQ	MOV3
;	TST.L	2(A0)
;	BEQ	MOV1
	TST.W	(A0)
	BEQ	MOV23
	TST.W	4(A0)
	BEQ	MOV12
;	TST.W	2(A0)
;	BEQ	MOV13
	MOVE.W	(A0),D0
	CMP.W	2(A0),D0
	BEQ	COMPARE3
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV66	CMP.L	(A3),D0
	BEQ.S	TROUVêMV66
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV66
	LEA	-32(A3),A3
	BRA	CONT6
TROUVêMV66	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+

	MOVE.W	2(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV77	CMP.L	(A3),D0
	BEQ.S	TROUVêMV77
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV77
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	2(A0),(A2)+
	BRA	APRES3COMP
TROUVêMV77	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	BRA	APRES3COMP

CONT6	MOVE.W	#$22FC,(A2)+
	MOVE.L	(A0),(A2)+
APRES3COMP	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV33	CMP.L	(A3),D0
	BEQ.S	TROUVêMV33
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV33
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMV33	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

COMPARE3	SWAP	D0
	MOVE.W	2(A0),D0
	CLR.W	ADD1
	MOVE.W	#$22C0,D4
	MOVE.W	#7,D3
CHERCHCOMP3	CMP.L	(A3),D0
	BEQ.S	TROUVêC3
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#1,D4
	DBRA	D3,CHERCHCOMP3
	LEA	-32(A3),A3
	MOVE.W	#$22FC,(A2)+
	MOVE.L	(A0),(A2)+
	BRA	APRES3COMP
TROUVêC3	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	BRA	APRES3COMP


MOV13	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV13	CMP.L	(A3),D0
	BEQ.S	TROUVêMV13
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV13
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	(A0),(A2)+
	MOVE.W	#$32CC,(A2)+
	BRA	CONT3
TROUVêMV13	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$32CC,(A2)+
CONT3	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV1_3	CMP.L	(A3),D0
	BEQ.S	TROUVêMV1_3
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV1_3
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMV1_3	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
MOV3	MOVE.W	#$22CC,(A2)+
	MOVEQ	#0,D0
	MOVE.W	4(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV3	CMP.L	(A3),D0
	BEQ.S	TROUVêMV3
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV3
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMV3	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
MOV1	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV1	CMP.L	(A3),D0
	BEQ.S	TROUVêMV1
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV1
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	4(A0),(A2)+
	MOVE.W	#$22CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMV1	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$22CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
	MOVE.W	#$32FC,(A2)+
	MOVE.W	(A0),(A2)+
	MOVE.W	#$22CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF


MOV23	MOVE.W	#$32CC,(A2)+
	TST.W	4(A0)
	BEQ	MOV2

	MOVEQ	#0,D0
	MOVE.W	2(A0),D0
	CMP.W	4(A0),D0
	BEQ	COMPARE5
	MOVE.W	#$22FC,(A2)+
	MOVE.L	2(A0),(A2)+
APRES5COMP	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

COMPARE5	CLR.W	ADD1
	SWAP	D0
	MOVE.W	4(A0),D0
	MOVE.W	#$22C0,D4
	MOVE.W	#7,D3
CHERCHCOMP5	CMP.L	(A3),D0
	BEQ.S	TROUVêC5
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#1,D4
	DBRA	D3,CHERCHCOMP5
	LEA	-32(A3),A3
	MOVE.W	#$22FC,(A2)+
	MOVE.L	2(A0),(A2)+
	BRA	APRES5COMP
TROUVêC5	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	BRA	APRES5COMP

MOV2	MOVEQ	#0,D0
	MOVE.W	2(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMV2	CMP.L	(A3),D0
	BEQ.S	TROUVêMV2
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMV2
	LEA	-32(A3),A3
	MOVE.W	#$32FC,(A2)+
	MOVE.W	2(A0),(A2)+
	MOVE.W	#$32CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMV2	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$32CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF


MOV12	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	CMP.W	2(A0),D0
	BEQ	COMPARE4
	MOVE.W	(A0),D0
	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHMVD	CMP.L	(A3),D0
	BEQ.S	TROUVêMVD
	ADDQ.L	#4,A3
	ADDQ.W	#4,ADD1
	ADDQ.W	#1,D4
	DBRA	D3,CHERCHMVD
	LEA	-32(A3),A3
	MOVE.W	#$22FC,(A2)+
	MOVE.L	(A0),(A2)+
	MOVE.W	#$32CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
TROUVêMVD	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	#$32FC,(A2)+
	MOVE.W	2(A0),(A2)+
	MOVE.W	#$32CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF
	
APRES4COMP	MOVE.W	#$32CC,(A2)+
	MOVE.W	#$5449,(A2)+
;	ADDQ.W	#1,ADD
	BRA	FIN_AFF

COMPARE4	CLR.W	ADD1
	MOVE.W	#$32C0,D4
	MOVE.W	#7,D3
CHERCHCOMP4	CMP.L	(A3),D0
	BEQ.S	TROUVêC4
	ADDQ.W	#4,ADD1
	ADDQ.L	#4,A3
	ADDI.W	#1,D4
	DBRA	D3,CHERCHCOMP4
	LEA	-32(A3),A3
	MOVE.W	#$22FC,(A2)+
	MOVE.L	(A0),(A2)+
	BRA	APRES4COMP
TROUVêC4	SUBA.W	ADD1,A3
	MOVE.W	D4,(A2)+
	MOVE.W	D4,(A2)+
	BRA	APRES4COMP

NO_AFF	MOVE.W	#$5049,(A2)+	
	BSR	OPTI_ADDQ_ORS
;	ADDQ.W	#1,ADD
FIN_AFF	ADDQ.L	#8,A0
	ADDQ.L	#2,A1
	RTS

PREDECALET	LEA	BUF_DEC,A1
	LEA	PREDEC_TAB,A6
	MOVE.W	#Y-1,D6
RECOP2	MOVE.W	#X-2,D7
RECOP11	MOVE.L	(A0)+,(A1)+
	MOVE.W	(A0)+,(A1)+
	CLR.W	(A1)+
	ADDQ.L	#2,A0
	DBRA	D7,RECOP11
	CLR.L	(A1)+
	CLR.L	(A1)+
	LEA	160-((X-1)*8)(A0),A0
	DBRA	D6,RECOP2

	LEA	BUF_DEC,A0
	MOVE.L	A0,(A6)+
	MOVE.W	#6,D3
DECPGEN	LEA	X*8*Y(A0),A1
	MOVE.L	A1,(A6)+
	MOVE.W	#(X*Y)-1,D7
RECOP3	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D7,RECOP3

	MOVE.W	#1,D4
DECPG1	MOVE.W	#Y-1,D5
DECP3	MOVE.W	#3,D6
DECP2	MOVE.W	#X-1,D7
DECP1	ROXR	(A0)
	ADDQ.L	#8,A0
	DBRA	D7,DECP1
	LEA	-((X*8)-2)(A0),A0
	DBRA	D6,DECP2
	LEA	(X-1)*8(A0),A0
	DBRA	D5,DECP3
	LEA	-(X*8*Y)(A0),A0
	DBRA	D4,DECPG1
	DBRA	D3,DECPGEN
	RTS

MAK_EFF	TST.W	FLAG_EFF
	BEQ	FLAGEFF_OFF
	MOVE.L	SCREEN2,A0	;MSK
	MOVE.L	SCREEN1,A1	;SPR
	MOVE.W	#Y-1,D6
RECOMEF2	MOVE.W	#X-1,D7
RECOMEF1	CMPI.W	#-1,(A0)
	BEQ	QQQ
	TST.L	(A1)
	BEQ	EFF3
	TST.L	2(A1)
	BEQ	EFF1
	TST.W	(A1)
	BEQ	EFF23
	TST.W	2(A1)
	BEQ	EFF13
	TST.W	4(A1)
	BEQ	EFF12
EFF_ALL	MOVE.W	#$20C0,(A2)+	;6 NOPS
	MOVE.W	#$30C0,(A2)+
	MOVE.W	#$5448,(A2)+
	BRA.S	NO_EFF
QQQ	MOVE.W	#$5048,(A2)+
	BSR	OPTI_ADDQ_EFF
NO_EFF	ADDQ.L	#8,A1
	ADDQ.L	#2,A0
	DBRA	D7,RECOMEF1
	MOVE.W	#$41E8,(A2)+
	MOVE.W	#160-(X*8),(A2)+
	BSR	OPTI_ADDQ_EFF
	DBRA	D6,RECOMEF2
	MOVE.W	#$4E75,(A2)+
FLAGEFF_OFF	RTS

EFF3	MOVE.W	#$5848,(A2)+
	BSR	OPTI_ADDQ_EFF
	MOVE.W	#$30C0,(A2)+	;4 NOPS
	MOVE.W	#$5448,(A2)+
	BRA	NO_EFF

EFF1	MOVE.W	#$30C0,(A2)+	;3 NOPS
	MOVE.W	#$5C48,(A2)+
	BRA	NO_EFF

EFF23	TST.W	4(A1)
	BEQ	EFF2
	MOVE.W	#$5448,(A2)+	;5 NOPS
	BSR	OPTI_ADDQ_EFF
	MOVE.W	#$20C0,(A2)+
	MOVE.W	#$5448,(A2)+
	BRA	NO_EFF
EFF2	MOVE.W	#$5448,(A2)+	;4 NOPS
	BSR	OPTI_ADDQ_EFF
	MOVE.W	#$30C0,(A2)+
	MOVE.W	#$5848,(A2)+
	BRA	NO_EFF

EFF13	MOVE.W	#$30C0,(A2)+	;6 NOPS
	MOVE.W	#$5448,(A2)+
	MOVE.W	#$30C0,(A2)+
	MOVE.W	#$5448,(A2)+
	BRA	NO_EFF

EFF12	MOVE.W	#$20C0,(A2)+	;4 NOPS
	MOVE.W	#$5848,(A2)+
	BRA	NO_EFF

OPTI_ADDQ_EFF
	MOVE.W	#$5448,D0
	MOVE.W	#$5848,D1
	MOVE.W	#$5C48,D2
	MOVE.W	#$5048,D3
	MOVE.W	#$41E8,D4
	CLR.W	ADD1
CONT_OPTEF	CMP.W	-2(A2),D0
	BNE.S	ADEF2
	ADDQ.W	#2,ADD1
	SUBQ.L	#2,A2
	BRA	CONT_OPTEF
ADEF2	CMP.W	-2(A2),D1
	BNE.S	ADEF3
	ADDQ.W	#4,ADD1
	SUBQ.L	#2,A2
	BRA	CONT_OPTEF
ADEF3	CMP.W	-2(A2),D2
	BNE.S	ADEF4
	ADDQ.W	#6,ADD1
	SUBQ.L	#2,A2
	BRA	CONT_OPTEF
ADEF4	CMP.W	-2(A2),D3
	BNE.S	ADEF5
	ADDQ.W	#8,ADD1
	SUBQ.L	#2,A2
	BRA	CONT_OPTEF
ADEF5	CMP.W	-4(A2),D4
	BNE.S	FIN_OPTEF
	MOVE.W	-2(A2),D0
	ADD.W	D0,ADD1
	MOVE.W	#$5448,D0
	SUBQ.L	#4,A2
	BRA	CONT_OPTEF
FIN_OPTEF	TST.W	ADD1
	BEQ	FINI_OPTEF
	CMPI.W	#8,ADD1
	BGT	MAK_LEAEF
	CMPI.W	#2,ADD1
	BNE.S	TESTEF2
	MOVE.W	#$5448,(A2)+
	BRA	FINI_OPTEF
TESTEF2	CMPI.W	#4,ADD1
	BNE.S	TESTEF3
	MOVE.W	#$5848,(A2)+
	BRA	FINI_OPTEF
TESTEF3	CMPI.W	#6,ADD1
	BNE.S	TESTEF4
	MOVE.W	#$5C48,(A2)+
	BRA	FINI_OPTEF
TESTEF4	MOVE.W	#$5048,(A2)+
	BRA	FINI_OPTEF
MAK_LEAEF	MOVE.W	#$41E8,(A2)+
	MOVE.W	ADD1,(A2)+
FINI_OPTEF	RTS


TOUT_NOIR
	CLR.L	$FFFF8240.W
	CLR.L	$FFFF8244.W
	CLR.L	$FFFF8248.W
	CLR.L	$FFFF824C.W
	CLR.L	$FFFF8250.W
	CLR.L	$FFFF8254.W
	CLR.L	$FFFF8258.W
	CLR.L	$FFFF825C.W
	RTS
EFF_ECR	MOVEA.L	SCREEN1,A0
	MOVEA.L	SCREEN2,A1
	MOVE.L	#7999,D0
EFFACE_ZOU	CLR.L	(A0)+
	CLR.L	(A1)+
	DBF	D0,EFFACE_ZOU
	RTS

decrunch:	movem.l d0-a6,-(sp)
	cmpi.l	#'Ice!',(a0)+	; Is data packed?
	bne.s	ice_03		; no!
	move.l	(a0)+,d0	; read packed data
	lea	-8(a0,d0.l),a5
	move.l	(a0)+,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	(sp),a6
	movea.l a6,a3
	bsr.s	ice_08
	bsr.s	ice_04
	bsr	ice_0c		;; Picture decrunch!
	bcc.s	ice_03		;; These marked lines may be
	move.w	#$0f9f,d7	;; removed in your own sources
ice_00:	moveq	#3,d6		;; if you do not use the
ice_01:	move.w	-(a3),d4	;; additional algorithm.
	moveq	#3,d5		;;
ice_02:	add.w	d4,d4		;;
	addx.w	d0,d0		;;
	add.w	d4,d4		;;
	addx.w	d1,d1		;;
	add.w	d4,d4		;;
	addx.w	d2,d2		;;
	add.w	d4,d4		;;
	addx.w	d3,d3		;;
	dbra	d5,ice_02	;;
	dbra	d6,ice_01	;;
	movem.w d0-d3,(a3)	;;
	dbra	d7,ice_00	;;
ice_03:	movem.l (sp)+,d0-a6
	rts
ice_04:	bsr.s	ice_0c
	bcc.s	ice_07
	moveq	#0,d1
	bsr.s	ice_0c
	bcc.s	ice_06
	lea	ice_1a(pc),a1
	moveq	#4,d3
ice_05:	move.l	-(a1),d0
	bsr.s	ice_0f
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice_05
	add.l	20(a1),d1
ice_06:	move.b	-(a5),-(a6)
	dbra	d1,ice_06
ice_07:	cmpa.l	a4,a6
	bgt.s	ice_12
	rts
ice_08:	moveq	#3,d0
ice_09:	move.b	-(a5),d7
	ror.l	#8,d7
	dbra	d0,ice_09
	rts
ice_0a:	move.w	a5,d7
	btst	#0,d7
	bne.s	ice_0b
	move.l	-(a5),d7
	addx.l	d7,d7
	bra.s	ice_11
ice_0b:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	bra.s	ice_11
ice_0c:	add.l	d7,d7
	beq.s	ice_0d
	rts
ice_0d:	move.w	a5,d7
	btst	#0,d7
	bne.s	ice_0e
	move.l	-(a5),d7
	addx.l	d7,d7
	rts
ice_0e:	move.l	-5(a5),d7
	lsl.l	#8,d7
	move.b	-(a5),d7
	subq.l	#3,a5
	add.l	d7,d7
	bset	#0,d7
	rts
ice_0f:	moveq	#0,d1
ice_10:	add.l	d7,d7
	beq.s	ice_0a
ice_11:	addx.w	d1,d1
	dbra	d0,ice_10
	rts
ice_12:	lea	ice_1b(pc),a1
	moveq	#3,d2
ice_13:	bsr.s	ice_0c
	dbcc	d2,ice_13
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice_14
	bsr.s	ice_0f
ice_14:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice_16
	lea	ice_1c(pc),a1
	moveq	#1,d2
ice_15:	bsr.s	ice_0c
	dbcc	d2,ice_15
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice_0f
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bra.s	ice_18
ice_16:	moveq	#0,d1
	moveq	#5,d0
	moveq	#0,d2
	bsr.s	ice_0c
	bcc.s	ice_17
	moveq	#8,d0
	moveq	#$40,d2
ice_17:	bsr.s	ice_0f
	add.w	d2,d1
ice_18:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice_19:	move.b	-(a1),-(a6)
	dbra	d4,ice_19
	bra	ice_04
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice_1a:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice_1b:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice_1c:	DC.B $0b,$04,$07,$00,$01,$20,$00,$00
	DC.B $00,$20


PRP_CRB	LEA	COURB_,A0
	LEA	BUF1CRB,A1
	LEA	BUF2CRB,A3
	LEA	ADR_ROUTS,A2
	MOVE.W	#159,D6
PRP_CRB2B	MOVEQ	#7,D7
PRP_CRB1	MOVE.W	(A0)+,D0
	MOVE.L	(A2,D0.W),(A1)+
	MOVE.L	(A2,D0.W),(A3)+
	MOVEQ	#0,D0
	MOVE.W	(A0),D0
	ADD.L	SCREEN2,D0
	MOVE.L	D0,(A1)+
	MOVEQ	#0,D0
	MOVE.W	(A0)+,D0
	ADD.L	SCREEN1,D0
	MOVE.L	D0,(A3)+
	DBRA	D7,PRP_CRB1
	DBRA	D6,PRP_CRB2B
	LEA	BUF1CRB,A0
	LEA	64*160(A0),A1
	MOVE.W	#(8*160)-1,D7
RECOP1_	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D7,RECOP1_
	LEA	BUF2CRB,A0
	LEA	64*160(A0),A1
	MOVE.W	#(8*160)-1,D7
RECOP2_	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBRA	D7,RECOP2_
	RTS

PRP_LET	LEA	MESSAG,A0
	LEA	ADR_ROUTS,A1
	LEA	TABLE,A2
	LEA	BUF_COD_,A3
	MOVEQ	#9,D6
ANAL_3	MOVE.L	A3,(A2)+
	MOVEQ	#7,D3
ANAL_2	MOVEQ	#7,D7
ANAL_1A	MOVE.B	(A0)+,D0
	BTST	D3,D0
	BEQ.S	NOT_GAGA_C_ZAPPY_1991
	MOVE.L	#$225A205A,(A3)+	;MOVE.L (A2)+,A1
				;MOVE.L (A2)+,A0
	MOVE.L	#$D0C74E91,(A3)+	;JSR (A1)
				;ADDA.W D7,A0
CONTINUE	DBRA	D7,ANAL_1A
	MOVE.L	#$45EA0040,(A3)+
	SUBQ.L	#8,A0
	DBRA	D3,ANAL_2
	ADDQ.L	#8,A0
	MOVE.W	#$4E75,(A3)+
	DBRA	D6,ANAL_3
	RTS

NOT_GAGA_C_ZAPPY_1991
	MOVE.W	#$504A,(A3)+	;ADDQ.W #8,A2
	BSR.S	OPTIMIZE
	BRA.S	CONTINUE

OPTIMIZE	MOVE.W	#$504A,D1
	MOVE.W	#$45EA,D2
	MOVEQ	#0,D4
RECOM_TST	CMP.W	-2(A3),D1
	BNE.S	TEST2
	SUBQ.L	#2,A3
	ADDQ.W	#8,D4
	BRA.S	RECOM_TST
TEST2	CMP.W	-4(A3),D2
	BNE.S	CONT_OPT
	SUBQ.L	#4,A3
	ADD.W	2(A3),D4
	BRA.S	RECOM_TST
CONT_OPT	TST.W	D4
	BEQ.S	NO_OPT
	CMPI.W	#8,D4
	BNE.S	MAK_LEA
	MOVE.W	#$504A,(A3)+
	BRA.S	NO_OPT
MAK_LEA	MOVE.W	#$45EA,(A3)+
	MOVE.W	D4,(A3)+
NO_OPT	RTS

DEC_1	MOVE.L	#$20005000,D0	;3
	MOVE.L	#$7000A800,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$F8007000,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_2	MOVE.L	#$10002800,D0	;3
	MOVE.L	#$38005400,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$7C003800,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_3	MOVE.L	#$8001400,D0	;3
	MOVE.L	#$1C002A00,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$3E001C00,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_4	MOVE.L	#$4000A00,D0	;3
	MOVE.L	#$E001500,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$1F000E00,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_5	MOVE.L	#$2000500,D0	;3
	MOVE.L	#$7000A80,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$F800700,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_6	MOVE.L	#$1000280,D0	;3
	MOVE.L	#$3800540,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$7C00380,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_7	MOVE.L	#$800140,D0	;3
	MOVE.L	#$1C002A0,D1	;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$3E001C0,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_8	MOVE.L	#$4000A0,D0		;3
	MOVE.L	#$E00150,D1		;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$1F000E0,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_9	MOVE.L	#$200050,D0		;3
	MOVE.L	#$7000A8,D1		;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$F80070,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_10	MOVE.L	#$100028,D0		;3
	MOVE.L	#$380054,D1		;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$7C0038,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_11	MOVE.L	#$80014,D0		;3
	MOVE.L	#$1C002A,D1		;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$3E001C,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_12	MOVE.L	#$4000A,D0		;3
	MOVE.L	#$E0015,D1		;3
	OR.L	D0,(A0)		;5
	OR.L	D1,$A0(A0)		;6
	ORI.L	#$1F000E,$140(A0)	;8
	OR.L	D1,$1E0(A0)		;6
	OR.L	D0,$280(A0)		;6
	RTS			;4
	;TOTAL	=		41
DEC_13	MOVE.W	#$8000,D0		;2
	MOVE.L	#$20005,D1		;3
	MOVE.L	#$7000A,D2		;3
	OR.L	D1,(A0)		;6
	OR.L	D2,$A0(A0)		;6
	OR.W	D0,$A8(A0)		;4
	ORI.L	#$F0007,$140(A0)	;8
	OR.W	D0,$148(A0)		;4
	OR.L	D2,$1E0(A0)		;6
	OR.W	D0,$1E8(A0)		;4
	OR.L	D1,$280(A0)		;6
	RTS			;4
	;TOTAL	=		56
DEC_14	MOVE.L	#$80004000,D0	;3
	MOVE.W	#$8000,D1		;2
	MOVE.L	#$10002,D2		;3
	MOVE.L	#$30005,D3		;3
	OR.L	D2,(A0)		;6
	OR.W	D1,8(A0)		;4
	OR.L	D3,$A0(A0)		;6
	OR.L	D0,$A8(A0)		;6
	ORI.L	#$70003,$140(A0)	;8
	ORI.L	#$C0008000,$148(A0)	;8
	OR.L	D3,$1E0(A0)		;6
	OR.L	D0,$1E8(A0)		;6
	OR.L	D2,$280(A0)		;6
	OR.W	D1,$288(A0)		;4
	RTS			;4
	;TOTAL	=		75
DEC_15	MOVE.L	#$80004000,D0	;3
	MOVE.L	#$C000A000,D1	;3
	MOVE.L	#$10002,D2		;3
	BSET	#0,3(A0)		;5
	OR.L	D0,8(A0)		;6
	OR.L	D2,$A0(A0)		;6
	OR.L	D1,$A8(A0)		;6
	ORI.L	#$30001,$140(A0)	;8
	ORI.L	#$E000C000,$148(A0)	;8
	OR.L	D2,$1E0(A0)		;6
	OR.L	D1,$1E8(A0)		;6
	BSET	#0,$283(A0)		;5
	OR.L	D0,$288(A0)		;6
	RTS			;4
	;TOTAL	=		75
DEC_16	MOVE.L	#$4000A000,D0	;3
	MOVE.L	#$E0005000,D1	;3
	OR.L	D0,8(A0)		;6
	BSET	#0,$A3(A0)		;5
	OR.L	D1,$A8(A0)		;6
	ORI.L	#$10000,$140(A0)	;8
	ORI.L	#$F000E000,$148(A0)	;8
	BSET	#0,$1E3(A0)		;5
	OR.L	D1,$1E8(A0)		;6
	OR.L	D0,$288(A0)		;6
	RTS			;4
	;TOTAL	=		60
	;TOTAL	=		716
	;MOYENNE	=		44.75
****
	even
key	dc.b	0
	even 

	*-----sous programe------*	
calcrot
	sub.w	#1,attvbl
	beq.s	calcrots	
	bra	finacal
calcrots
	move.w	#7,attvbl
	moveq	#0,d0
	move.b	key,d0

	cmp.w	#7,d0
	bgt.s	finacal
	beq.s	changobj
	subq	#1,d0

	lea.l	adag1,a0
	moveq.l	#1,d1
	and.w	d0,d1
	bne.s	suitadcal

	sub.w	d1,d0
	add.w	d0,a0
	sub.w	#2,(a0)
	bra.s	finacal
suitadcal
	sub.w	d1,d0
	add.w	d0,a0
	add.w	#2,(a0)
	bra.s	finacal
changobj	
	add.w	#8,numobj
	lea.l	paobj,a0
	add.w	numobj,a0
	move.l	(a0)+,d0	
	bgt.s	schangobj	
	move.w	#-8,numobj
	bra.s	changobj
schangobj	
	move.l	d0,ptchang2+2
	addq.l	#2,d0
	move.l	d0,ptchang1+2
	move.l	(a0),ptchang3+2	
	clr.l	adag1
	clr.w	adag3
	clr.w	ang1
	clr.w	ang2
	clr.w	ang3
finacal	
	move.w	ang1,d0
	add.w	adag1,d0
	and.w	#$1ff,d0
	move.w	d0,ang1

	move.w	ang2,d0
	add.w	adag2,d0
	and.w	#$1ff,d0
	move.w	d0,ang2

	move.w	ang3,d0
	add.w	adag3,d0
	and.w	#$1ff,d0
	move.w	d0,ang3

	rts
adag1	dc.w	0
adag2	dc.w	0
adag3	dc.w	0
attvbl	dc.w	10
numobj	dc.w	0	
calcpoint	
	lea.l	tsin(pc),a0
	lea.l	128(a0),a1
ang1	equ	*+2
	move.w	#0,d0
ang2	equ	*+2
	move.w	#0,d1
ang3	equ	*+2	
	move.w	#0,d2

	move.w	(a0,d1.w),d3	-sinb
	neg	d3
	move.w	d3,modf3+2	

	move.w	d0,d3		d3=a-b
	sub.w	d1,d3		
	add.w	d0,d1		d1=a+b

	move.w	(a1,d1.w),d4	1/2(cos(a+b)+cos(a-b))
	add.w	(a1,d3.w),d4	cosacosb
	asr	d4
	move.w	d4,modf1+2		

	move.w	(a0,d1.w),d4	-1:2(sin(a+b)+sin((a-b))
	add.w	(a0,d3.w),d4	-sinacosb
	asr	d4
	neg	d4
	move.w	d4,modf2+2		

	sub.w	d0,d1
	move.w	d1,d3		
	sub.w	d2,d3		d3=b-c
	add.w	d1,d2		d2=b+c

	move.w	(a0,d2.w),d4	-1:2(sin(b+c)-sin((b-c))
	sub.w	(a0,d3.w),d4	-sinccosb
	asr	d4
	neg	d4
	move.w	d4,modf6+2		

	move.w	(a1,d2.w),d4	1/2(cos(b+c)+cos(b-c))
	add.w	(a1,d3.w),d4	cosbcosc
	asr	d4
	move.w	d4,modf9+2		

	sub.w	d1,d2
	move.w	d0,d3
	sub.w	d2,d3		d3=a-c
	add.w	d0,d2		d2=a+c

	move.w	(a0,d2.w),d4	1:2(sin(a+c)+sin(a-c))
	add.w	(a0,d3.w),d4	sinacosc
	asr	d4
	move.w	d4,addmodf1

	move.w	(a1,d2.w),d4	1:2(cos(a+c)+cos(a-c))
	add.w	(a1,d3.w),d4	cosacosc
	asr	d4
	move.w	d4,addmodf2

	move.w	(a1,d3.w),d4	1:2(cos(a-c)-cos(a+c))
	sub.w	(a1,d2.w),d4	sinasinc
	asr	d4
	move.w	d4,addmodf3

	move.w	(a0,d2.w),d4	1:2(sin(a+c)-sin(a-c))
	sub.w	(a0,d3.w),d4	cosasinc
	asr	d4
	move.w	d4,addmodf4

	sub.w	d0,d2
	move.w	#14,d3

	move.w	(a1,d0.w),d4	-cosasinbsinc+sinacosc
	muls.w	(a0,d1.w),d4
	muls.w	(a0,d2.w),d4
	asr.l	d3,d4
	neg	d4
addmodf1	equ	*+2
	add.w	#0,d4
	move.w	d4,modf4+2

	move.w	(a0,d0.w),d4	sinasinbsinc+cosacosc
	muls.w	(a0,d1.w),d4
	muls.w	(a0,d2.w),d4
	asr.l	d3,d4
addmodf2	equ	*+2
	add.w	#0,d4
	move.w	d4,modf5+2

	move.w	(a1,d0.w),d4	cosasinbcosc+sinasinc
	muls.w	(a0,d1.w),d4
	muls.w	(a1,d2.w),d4
	asr.l	d3,d4
addmodf3	equ	*+2
	add.w	#0,d4
	move.w	d4,modf7+2

	move.w	(a0,d0.w),d4	-sinasinbcosc+cosasinc
	muls.w	(a0,d1.w),d4
	muls.w	(a1,d2.w),d4
	asr.l	d3,d4
	neg	d4
addmodf4	equ	*+2
	add.w	#0,d4
	move.w	d4,modf8+2
	
	lea.l	t_points,a0
ptchang3	lea.l	tpoitesp1,a1
	lea.l	tz+255*2,a2

	move.w	#155-8,d5
	move.w	#100,d6
	
	move.w	(a1)+,d7

bmatrix
	move.w	(a1)+,a3
	move.w	(a1)+,a4
	move.w	(a1)+,d4

	move.w	a3,d0
	move.w	a4,d1
	move.w	d4,d2

modf1	muls	#1<<7,d0
modf2	muls	#0,d1
modf3	muls	#0,d2
	add.l	d1,d0
	add.l	d2,d0
	
	move.w	a3,d1
	move.w	a4,d2
	move.w	d4,d3

modf4	muls	#0,d1
modf5	muls	#1<<7,d2
modf6	muls	#0,d3
	add.l	d2,d1
	add.l	d3,d1
	
	move.w	a3,d2
	move.w	a4,d3
	
modf7	muls	#0,d2
modf8	muls	#0,d3
modf9	muls	#1<<7,d4
	add.l	d3,d2
	add.l	d4,d2
	
	asr.w	#7,d2
	add.w	d2,d2
	
	add.w	#20,d2
	
	muls	(a2,d2.w),d0
	muls	(a2,d2.w),d1
	
	swap	d0
	swap	d1
	
	add.w	d5,d0
	add.w	d6,d1
	
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	
	dbra.w	d7,bmatrix
	rts
	
	
	incbin	tsin7.aid
tsin	incbin	tsin7.aid
	incbin	tsin7.aid

tz	incbin	tzoom.aid

*----------------------------------------------------
tobj
	
ptchang1	move.l	#tpoly1+2,chbobj
ptchang2	move.w	tpoly1,d0
bobj	
	move.w	d0,sauvd0
chbobj	equ	*+2
	move.l	tpoly1,d6
	add.l	#4,chbobj
	bsr	poly
	move.w	sauvd0,d0
	dbra.w	d0,bobj	
	
	rts

sauvd0	dc.w	0
*----------------------------------------------------	
	************************
	**trace de poly 1 plan**	
	************************
poly:
				*chercher +haut
  	move.l	d6,a5
  	move.w	(a5)+,plan2
  	lea.l	t_points,a1		*point	Y1		
				****************
	move.w	2(a5),d0
	move.w	4(a5),d1
	move.w	6(a5),d2		test	face
	move.w	(a1,d0.w),d3	     cachee
	sub.w	(a1,d1.w),d3
	move.w	2(a1,d0.w),d4
	sub.w	2(a1,d1.w),d4
	move.w	(a1,d2.w),d0
	sub.w	(a1,d1.w),d0
	move.w	2(a1,d2.w),d5
	sub.w	2(a1,d1.w),d5
	muls	d3,d5
	muls	d0,d4	
	sub.l	d4,d5
	bgt.s	ncaches	
	rts 
				****************
ncaches	
	move.w	(a5)+,d0		*d0=ndpoints
	
	moveq.l	#0,d7
	add.w	d0,d7
	subq.l	#2,d0		*calc avec tpoint
	
	move.w	(a5),d1
	move.w	2(a1,d1),d2
	lea.l	2(a5),a2
	move.w	(a2)+,d3
t_petit
	cmp.w	2(a1,d3.w),d2
	blt.s	st_ptit
	lea.l	-2(a2),a5
	move.w	2(a1,d3.w),d2
st_ptit
	move.w	(a2)+,d3
	dbra.w	d0,t_petit				
********************************************************************	
	move.w	d2,codmpyin+2		*calc ligne
	
	lea.l	calc(pc),a4		*pas touch
				*point=a1			*pointpoint=a5
				*tdpoint=a5
	add.w	d7,d7	
	addq.l	#4,d6
	add.l	d6,d7		
				*d7=fin de table
				*calc tgauche
	lea.l	tgauch,a3
	lea.l	(a5),a2
b_calct_g	
	move.w	(a2)+,d4		*pointe suivant tabe
	move.w	(a1,d4.w),d0
	move.w	2(a1,d4.w),d1
	
	cmp.l	d7,a2	
	bne.s	s_calct_g
	move.l	d6,a2
s_calct_g	
	move.w	(a2),d4	
	move.w	(a1,d4.w),d2
	move.w	2(a1,d4.w),d3
	
	cmp.w	d3,d1
	bgt.s	s1_calct_g	
	bsr	calcord
	bra.b	b_calct_g	
s1_calct_g		
	move.w	#0,(a3)
				**droit
	lea.l	tdroit,a3
	move.l	d7,mcodtd+2
	move.l	d6,d7	
	lea.l	(a5),a2
b_calct_d		
	move.w	(a2),d4
	move.w	(a1,d4.w),d0
	move.w	2(a1,d4.w),d1
	
	cmp.l	d7,a2	
	bne.s	s_calct_d
mcodtd	move.l	#t_points+2,a2
s_calct_d	
	move.w	-(a2),d4
	move.w	(a1,d4.w),d2
	move.w	2(a1,d4.w),d3
	
	cmp.w	d3,d1
	bgt.s	s1_calct_d	
	bsr	calcord
	bra.b	b_calct_d	
s1_calct_d	
	move.w	#-4,(a3)
******************************************************************
				*affiche poly			
				*peut toucher a4
	move.l	SCREEN2,a0
	
	LEA	-29*160(A0),A0
codmpyin	move.w	#100,d0
	lea.l	p_t_ord,a1
	add.w	d0,d0
	add.w	(a1,d0.w),a0 	*add ydeb	
plan2	dc.w	$4e71
	
	lea.l	tgauch,a1	
	lea.l	tdroit,a5
	lea.l	p_t_left,a2	
	lea.l	p_t_right,a3	
	lea.l	tdrempvd(pc),a6
	
	move.w	#$fffc,d3
	move.w	#$ffff,d7

pvalpoly	macro
				;256+12
 	moveq	#-4,d0		;4
	and.w	(a1)+,d0		;8
	move.l	(a2,d0.w),d0	;20
	
	moveq	#-4,d1		;4
	and.w	(a5)+,d1		;8
	move.l	(a3,d1.w),d1	;20	

	move.l	a0,a4		;4	
	add.w	d0,a4		;8	

	sub.w	d0,d1		;4	

	jmp	(a6,d1.w)		;16	
	endm
	pvalpoly
*********************************************
	rts
	bra.w	pdaffpa1
tdrempvd				
	bra.w	pdaffpa1		;12	
	dc.l	0
	bra.w	pdaffpa2
	dc.l	0
	bra.w	pdaffpa3	
	dc.l	0
	bra.w	pdaffpa4
	dc.l	0
	bra.w	pdaffpa5
	dc.l	0
	bra.w	pdaffpa6
	dc.l	0
	bra.w	pdaffpa7
	dc.l	0
	bra.w	pdaffpa8
	dc.l	0
	bra.w	pdaffpa9
	dc.l	0
	bra.w	pdaffpa10
	dc.l	0
	bra.w	pdaffpa11
	dc.l	0
	bra.w	pdaffpa12
	dc.l	0
	bra.w	pdaffpa13
	dc.l	0
	bra.w	pdaffpa14
	dc.l	0
	bra.w	pdaffpa15
	dc.l	0
	bra.w	pdaffpa16
	dc.l	0
	bra.w	pdaffpa17
	dc.l	0
	bra.w	pdaffpa18
	dc.l	0
	bra.w	pdaffpa19
	dc.l	0
	bra.w	pdaffpa20
pdaffpa1
	swap	d0
	swap	d1
	and.w	d0,d1
	or.w	d1,(a4)	
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa2
	swap	d0
	or.w	d0,(a4)
	swap	d1
	or.w	d1,8(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa3
	swap	d0
	or.w	d0,(a4)
	move.w	d7,8(a4)
	swap	d1
	or.w	d1,16(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa4
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	2
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa5
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	3
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa6
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	4
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0

	pvalpoly 						
	

pdaffpa7
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	5
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 					
	

pdaffpa8
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	6
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa9
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	7
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0

	pvalpoly 				 	
	

pdaffpa10
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	8
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				 	
	

pdaffpa11
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	9
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0

	pvalpoly 				 	
	

pdaffpa12
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	10
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0

	pvalpoly 				
	

pdaffpa13
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	11
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				


pdaffpa14
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	12
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0

	pvalpoly 				 	
	

pdaffpa15
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	13
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa16

	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	14
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa17
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	15
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa18
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	16
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
	

pdaffpa19
	swap	d0
	or.w	d0,(a4)
n	set	8
	rept	17
	move.w	d7,n(a4)
n	set	n+8
	endr
	swap	d1
	or.w	d1,n(a4)
	lea.l	160(a0),a0
	
	pvalpoly 				
 	

pdaffpa20
	swap	d0		;4
	or.w	d0,(a4)		;12
n	set	8
	rept	18
	move.w	d7,n(a4)		;12*18
n	set	n+8
	endr
	swap	d1		;4
	or.w	d1,n(a4)		;12
	lea.l	160(a0),a0		;8
	
	pvalpoly 				
	


*********************************************
calcord	
	
	moveq.l	#0,d4
	SUB.W	D0,D2
	SUB.W	D1,D3
	bne.s	scalcnul
	rts
scalcnul	
	move.w	d2,d4
	
	ASL.W	#7,D4
	ext.l	d4
	DIVS.W	d3,D4	*x(+1)=(dx/dy)+x
	move.w	#11,d2
	ext.l	d4
	ASL.L	d2,D4
	
	add.w	d3,d3
	add.w	d3,d3
	neg	d3
	SWAP	d4
	
	add.w	d0,d0	
	add.w	d0,d0
	sub.w	d1,d1
	JMP	(a4,d3)

	rept	201
	MOVE.W	d0,(A3)+
	ADDX.L	d4,d0
	endr
calc
	rts


	DATA

SCREEN_Y_TABLE
	dc.w	0,160,320,480,640,800,960,1120,1280,1440,1600,1760,1920,2080,2240
	dc.w	2400,2560,2720,2880,3040,3200,3360,3520,3680,3840,4000,4160,4320,4480,4640
	dc.w	4800,4960,5120,5280,5440,5600,5760,5920,6080,6240,6400,6560,6720,6880,7040
	dc.w	7200,7360,7520,7680,7840,8000,8160,8320,8480,8640,8800,8960,9120,9280,9440
	dc.w	9600,9760,9920,10080,10240,10400,10560,10720,10880,11040,11200,11360,11520,11680,11840
	dc.w	12000,12160,12320,12480,12640,12800,12960,13120,13280,13440,13600,13760,13920,14080,14240
	dc.w	14400,14560,14720,14880,15040,15200,15360,15520,15680,15840,16000,16160,16320,16480,16640
	dc.w	16800,16960,17120,17280,17440,17600,17760,17920,18080,18240,18400,18560,18720,18880,19040
	dc.w	19200,19360,19520,19680,19840,20000,20160,20320,20480,20640,20800,20960,21120,21280,21440
	dc.w	21600,21760,21920,22080,22240,22400,22560,22720,22880,23040,23200,23360,23520,23680,23840
	dc.w	24000,24160,24320,24480,24640,24800,24960,25120,25280,25440,25600,25760,25920,26080,26240
	dc.w	26400,26560,26720,26880,27040,27200,27360,27520,27680,27840,28000,28160,28320,28480,28640
	dc.w	28800,28960,29120,29280,29440,29600,29760,29920,30080,30240,30400,30560,30720,30880,31040
	dc.w	31200,31360,31520,31680,31840
PIXEL_TABLE_LEFT
	dc.w	%1111111111111111
	dc.w	%0111111111111111
	dc.w	%0011111111111111
	dc.w	%0001111111111111
	dc.w	%0000111111111111
	dc.w	%0000011111111111
	dc.w	%0000001111111111
	dc.w	%0000000111111111
	dc.w	%0000000011111111
	dc.w	%0000000001111111
	dc.w	%0000000000111111
	dc.w	%0000000000011111
	dc.w	%0000000000001111
	dc.w	%0000000000000111
	dc.w	%0000000000000011
	dc.w	%0000000000000001
PIXEL_TABLE_RIGHT
	dc.w	%1000000000000000
	dc.w	%1100000000000000
	dc.w	%1110000000000000
	dc.w	%1111000000000000
	dc.w	%1111100000000000
	dc.w	%1111110000000000
	dc.w	%1111111000000000
	dc.w	%1111111100000000
	dc.w	%1111111110000000
	dc.w	%1111111111000000
	dc.w	%1111111111100000
	dc.w	%1111111111110000
	dc.w	%1111111111111000
	dc.w	%1111111111111100
	dc.w	%1111111111111110
	dc.w	%1111111111111111

MESS_X_COORD	dc.w	0
MESS_Y_COORD	dc.w	0

pattern:	dc.w $ffff
FADING
	DC	$000,$000,$000,$000,$000,$000,$000,$000
	DC	$000,$000,$000,$000,$000,$000,$000,$000
	DC	$000,$000,$000,$000,$000,$000,$000,$000
	DC	$000,$100,$100,$100,$000,$000,$000,$000
	DC	$000,$000,$000,$000,$000,$000,$000,$000
	DC	$100,$200,$200,$200,$000,$000,$000,$000
	DC	$000,$000,$000,$000,$000,$000,$000,$100
	DC	$200,$300,$300,$300,$100,$000,$000,$000
	DC	$000,$000,$000,$000,$000,$000,$100,$200
	DC	$300,$400,$400,$400,$200,$100,$000,$000
	DC	$000,$100,$000,$000,$000,$100,$200,$300
	DC	$400,$500,$500,$500,$300,$200,$100,$000
	DC	$000,$200,$000,$000,$100,$200,$300,$400
	DC	$500,$600,$600,$600,$400,$300,$200,$100
	DC	$000,$300,$100,$100,$200,$300,$400,$500
	DC	$600,$700,$700,$700,$500,$400,$300,$200
	DC	$000,$400,$100,$100,$200,$300,$400,$500
	DC	$600,$700,$700,$710,$500,$400,$300,$200
	DC	$000,$500,$100,$100,$200,$300,$400,$500
	DC	$600,$700,$710,$720,$500,$400,$300,$200
	DC	$000,$500,$100,$100,$200,$300,$400,$500
	DC	$600,$710,$720,$730,$510,$400,$300,$200
	DC	$000,$500,$100,$100,$200,$300,$400,$500
	DC	$610,$720,$730,$740,$520,$410,$300,$200
	DC	$000,$500,$100,$100,$200,$300,$400,$510
	DC	$620,$730,$740,$750,$530,$420,$310,$200
	DC	$000,$500,$100,$100,$200,$300,$410,$520
	DC	$630,$740,$750,$760,$540,$430,$320,$210
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$640,$750,$760,$770,$550,$440,$330,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$640,$750,$760,$771,$550,$440,$330,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$640,$750,$760,$772,$550,$440,$330,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$640,$750,$761,$773,$551,$440,$330,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$640,$751,$762,$774,$552,$441,$330,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$530
	DC	$641,$752,$763,$775,$553,$442,$331,$220
	DC	$000,$500,$100,$110,$210,$310,$420,$531
	DC	$642,$753,$764,$776,$554,$443,$332,$221

CAMEO	INCBIN	CAMEO2.PI1
COURB1	incbin	COUCHE2.dat	90906
text:
	dc.b "                                     . . . H O L O C A U S T . . ."
	DC.B "      KEEPING THE DREAM ALIVE !!!       "
	DC.B	"HERE IS...   THE FLEXI KILLER SCROLLER "
	DC.B	"BY   DAN NATO  OF HOLOCAUST ! "
	DC.B	"        WHAT A SWELL CIRCLE PERFECTION !                YOU ARE ABOUT TO ENTER OUR KINGDOM OF MADNESS !"
	dc.b "                                "
	dc.b 255,255	 *2!
	even
ADR_ROUTS	DC.L	DEC_1,DEC_2,DEC_3,DEC_4,DEC_5,DEC_6,DEC_7,DEC_8
	DC.L	DEC_9,DEC_10,DEC_11,DEC_12,DEC_13,DEC_14,DEC_15
	DC.L	DEC_16

MESSAG	DC.B	230,102,102,110,102,102,230,0	;H
	DC.B	108,198,198,198,198,198,108,0	;O
	DC.B	240,96,96,96,96,98,238,0	;L
	DC.B	108,198,198,198,198,198,108,0	;O
	DC.B	46,98,224,224,224,98,46,0	;C
	DC.B	24,56,56,76,124,140,206,0	;A
	DC.B	246,98,98,98,98,98,28,0		;U
	DC.B	110,194,240,60,14,134,236,0	;S
	DC.B	126,90,24,24,24,24,60,0		;T
	DC.B	0,0,0,0,0,0,0,0
	EVEN
EFFAC	INCBIN	EFF_BALS.EFF
COURB_	INCBIN	CIRCLE_2.CRB
CRB_REBOND	INCBIN	REBOND.CRB
	DC.W	-1

COURB2	INCBIN	DELIRE2.DAT
text2:
	dc.b "                           "
	DC.B "GRIFF WAS RIGHT...             NEITHER TCB...   NOR TLB...   CAN BEAT HIS FLEXISCROLL...     "
	DC.B "   BUT  H O L O C A U S T   WIDELY CAN !  "
	DC.B "     USE KEYS ESC TO 6 TO CONTROL THE CUBE.       "
	DC.B "     PRESS SPACE TO CONTINUE...     "
	dc.b "                                "
	dc.b 255,255	 *2!
	even

	*_______variables________*
p_t_left
n	set	0
          	rept	20
            dc.w    %1111111111111111,n
            dc.w    %0111111111111111,n
            dc.w    %0011111111111111,n
            dc.w    %0001111111111111,n
            dc.w    %0000111111111111,n
            dc.w    %0000011111111111,n
            dc.w    %0000001111111111,n
            dc.w    %0000000111111111,n
            dc.w    %0000000011111111,n
            dc.w    %0000000001111111,n
            dc.w    %0000000000111111,n
            dc.w    %0000000000011111,n
            dc.w    %0000000000001111,n
            dc.w    %0000000000000111,n
            dc.w    %0000000000000011,n
            dc.w    %0000000000000001,n
n	set	n+8
	endr

	dc.w	-8,-6
p_t_right
n	set	0
            rept	20
            dc.w    %1000000000000000,n
            dc.w    %1100000000000000,n
            dc.w    %1110000000000000,n
            dc.w    %1111000000000000,n
            dc.w    %1111100000000000,n
            dc.w    %1111110000000000,n
            dc.w    %1111111000000000,n
            dc.w    %1111111100000000,n
            dc.w    %1111111110000000,n
            dc.w    %1111111111000000,n
            dc.w    %1111111111100000,n
            dc.w    %1111111111110000,n
            dc.w    %1111111111111000,n
            dc.w    %1111111111111100,n
            dc.w    %1111111111111110,n
            dc.w    %1111111111111111,n
n	set	n+8
	endr
	
p_t_ord
n	set	30*160
	rept	200
	dc.w	n
n	set	n+160
	endr			
	*------------variable------------*

paobj	dc.l	tpoly1,tpoitesp1,-1

******************cube*********************

tpoly1	dc.w	6-1
	dc.l	face11,face12,face13,face14,face15,face16 	

face11	dc.w	$5488,4,0,4,8,12
face12	dc.w	$5888,4,16,0,12,28
face13	dc.w	$4E71,4,12,8,24,28
face14	dc.w	$4E71,4,4,20,24,8
face15	dc.w	$5888,4,16,20,4,0 
face16	dc.w	$5488,4,28,24,20,16

tpoitesp1	
	dc.w	8-1
	dc.w	-50,-50,-50		1
	dc.w	-50,50,-50		2
	dc.w	50,50,-50		3
	dc.w	50,-50,-50		4
	dc.w	-50,-50,50		5
	dc.w	-50,50,50		6
	dc.w	50,50,50		7
	dc.w	50,-50,50		8


COURB3	INCBIN	rond10b.DAT
text3:
	dc.b "                           "
	DC.B "WHOOO !!!   YOU WERE WARNED !!! I'M ABLE TO FIND REAL OUTRAGEOUS WAVES !     "
	DC.B "  OK, THAT'S NOT A TRUE WATERSCROLLER...  BUT IT LOOKS LIKE !"

	dc.b "                            "
	dc.b 255,255	 *2!
	even
WATER	INCBIN	WATER.PI1

PAL_WATER
	DC	$000
	DC	$111
	DC	$222
	DC	$333
	DC	$444
	DC	$555
	DC	$666
	DC	$777
	DC	$777
	DC	$777
	DC	$777
	DC	$777
	DC	$777
	DC	$666
	DC	$555
	DC	$444
	DC	$333
	DC	$222
	DC	$111
	DC	$000
	
	DC.L	-1


font:	
	dc.b %00000,%00000,%00000,%00000	;' '
	dc.b %00000,%11101,%11101,%00000	;!
	dc.b %01111,%10100,%10100,%01111	;a
	dc.b %01010,%10101,%10101,%11111	;b
	dc.b %10001,%10001,%10001,%11111	;c
	dc.b %01110,%10001,%10001,%11111	;d
	dc.b %10001,%10101,%10101,%11111	;e

	dc.b %10000,%10100,%10100,%11111	;f
	dc.b %10110,%10101,%10001,%01110	;g
	dc.b %11111,%00100,%00100,%11111	;h
	dc.b %00000,%10001,%11111,%10001	;i
	dc.b %00000,%10000,%11111,%10001	;j
	dc.b %11011,%00100,%00100,%11111	;k
	dc.b %00001,%00001,%00001,%11111	;l
	dc.b %11111,%01000,%01000,%11111	;m
	dc.b %01111,%10000,%10000,%11111	;n
	dc.b %11111,%10001,%10001,%11111	;o
	dc.b %01000,%10100,%10100,%11111	;p
	dc.b %11111,%10011,%10001,%11111	;q
	dc.b %11101,%10110,%10100,%11111	;r
	dc.b %10010,%10101,%10101,%01001	;s
	dc.b %00000,%10000,%11111,%10000	;t
	dc.b %11111,%00001,%00001,%11111	;u
	dc.b %11110,%00001,%00001,%11110	;v
	dc.b %11111,%00010,%00010,%11111	;w
	dc.b %11011,%00100,%00100,%11011	;x
	dc.b %00000,%11100,%00111,%11100	;y
	dc.b %10001,%11001,%10101,%10011	;z
	dc.b %01110,%10001,%10001,%01110	;0
	dc.b %00000,%00001,%11111,%01001	;1
	dc.b %01001,%10101,%10011,%00001	;2
	dc.b %01010,%10101,%10101,%10001	;3
	dc.b %00010,%11111,%01010,%00110	;4
	dc.b %10010,%10101,%10101,%11101	;5
	dc.b %00010,%10101,%10101,%01110	;6
	dc.b %11000,%10100,%10010,%10001	;7
	dc.b %01010,%10101,%10101,%01010	;8
	dc.b %01110,%10101,%10101,%01001	;9
	dc.b %00000,%00011,%00011,%00000	;.
	dc.b %00000,%01001,%00000,%00000	;:
	dc.b %00000,%00010,%00001,%00000	;,
	dc.b %00000,%00000,%11000,%00000	;'
	dc.b %00000,%10001,%01110,%00000	;(
	dc.b %00000,%01110,%10001,%00000	;)

	EVEN
PIC	INCBIN	DAN2.PI1
FIC_OPT	INCBIN	DAN.OPT
	DS.L	100
COURB	INCBIN	b:\BIGGIE4.CRB
FIN_CRB	DS.L	1000
	DC.W	-1
ZIK	INCBIN	COPPER.MUS

TABLE_SPR	DC.L	PIC+34	D
	DC.L	PIC+34+32	A
	DC.L	PIC+34+64	N
	DC.L	PIC+34+96	T
	DC.L	PIC+34+128	O

NB_PART	DC.L	8
TEXTED
 DC.B "                                        "
 DC.B "*DAN NATO* is the coder of the Flexi-Killer-Scroller."
 dc.b " He did it 2 years ago, when he still was a lonesome"
 dc.b " coder. It is the oldest routy in our whole demo! "
 dc.b "  But this final screen was completed thanks to the "
 dc.b "efforts of almost all coders in the crew...  "
 dc.b "  The main work was done by Zappy ( me ) but I wouldn't have"
 dc.b " succeeded in such a challenge without the help of: "
 dc.b " Dan Nato for the original FlexiScroller.    Elric for the"
 dc.b " Blue Holocaust Balls at the beginning and for this sprite"
 dc.b " rout.    Zerioul for the 3D cube ( realtime, eh! ).    "
 dc.b " Actually, all I'd to do was: the intro-logo ( Cute! ), some"
 dc.b " waves for the scrolly, some ideas to find ( it means the global design ),"
 dc.b " some gfxs ( these sprites ), and the most difficult: to put all these routies"
 dc.b " together !!   ...Really boring...    Well.   A special message to"
 dc.b " WILL of 1984:          'Baaaaaaaaaaah!!!'           "
 dc.b " Hmmm. I'd to do it.      Grey things?  Naa. I hate greetings. "
 dc.b "  Or maybe a small list:  hallyhallo's to:     The Frenchies....   and the others. "
 dc.b "   Cool, I haven't forgotten anyone.          No... since I'm alone, nobody's here"
 dc.b " to tell me: 'Don't forget to greet Legacy!' or 'Say Hi to St Connexion!' ( Hi Vantage'n Krazy Rex! )"
 dc.b "  Then I won't send greetings, b'coz those who know us know who they are, we say Hi to them, and fak ya if you disagree."
 dc.b "   No, I'll greet MY friends. The ones you don't know. The cool ones.    Let's go.        "
 dc.b "   Special Hi's are flying through the air towards:     "
 dc.b " OXYGENE.  Not the crew, but the man. The Sysop of LEADER, which is a swell RTC not far from Paris... "
 dc.b "  The phone number is 34.66.03.57.   And it's an utterly SMASHING rtc!              "
 dc.b "  MARCO POLO.  The one who send you demoes when you write to STMag ( STMag, the only one. ) for this.  "
 dc.b " Hi! Marc.  Hang on for next year. And good luck.         "
 dc.b " A lot of words to:   PANZERBOY - DARKNESS - CRAM - RICK(ST) - BRAIN - SARAYAN/KILROY - MAJOR FATAL - CREATEUR - RBOY - KHELT - KILLER D - WATSIT.       "
 dc.b " The final greets ?     Yek yek.       ...to my friend called *FRIZOTUS* by our last german teacher. Ahahahah! Let's gloop, boys. "
 
 dc.b "                                                                        "
 DC.B "               ",$FF

	even

 
FONT8_8	
   	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
	dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
	dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
	dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
	dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
	dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
	dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
	dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
	dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
	dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
	dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
	dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
	dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
	dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
	dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
	dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
	dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
	dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
	dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
	dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
	dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
	dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
	dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
	dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
	dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
	dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
	dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
	dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
	dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
	dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
	dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
	dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
	dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
	dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
	dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
	dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
	dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
	dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 
	even


	BSS

routines
	ds.b 200000
	
F_PILE	DS.L 	128	
D_PILE	DS.L 	1	

vbl_save:	ds.l 1
tb_save:	ds.l 1
pal_save:	ds.w 16
mfp_save:	ds.w 1
lineA_tab:	ds.l 1
routs_pt:	ds.l 1
text_pt:	ds.l 1
text_buff_pt:	ds.l 1
PNT_261E	DS	1
SCREEN1	DS.L	1
SCREEN2	DS.L	1
compteurs:	ds.w 2
ad_routines:	ds.l 5
text_buffer:	ds.b 150
text_buffer_deb	equ text_buffer+20
text_buffer_end:ds.l 1
off_bolean:	ds.b 500
EMUL_LINEA	DS.B	60
	DS.B	256
BUFFERSCR	DS.B	154*256*2

MFP1	DS.B	1
MFP2	DS.B	1
MFP3	DS.B	1
MFP4	DS.B	1
MFP5	DS.B	1
MFP6	DS.B	1
SAVE_ALL	DS.L	16
BUF16DA	DS.B	512
PtsFill:	ds.b	512
*****
COURB_EC	DS.L	1
TEXT_EC	DS.L	1
PLAN	DS.L	1
PNT_FAD	DS.L	1
PNT_FAD2	DS.L	1
FORCE_DEMO	DS.L	1
COLONNE	DS	1
*** COUCHE
ADDIT	DS	1
BUF_ACT_CRB	DS.L	1
PNT_REBOND	DS.L	1
ANNEX	DS.L	1
TIME	DS.L	1
TABLE	DS.L	10
BUF_COD_	DS.W	3000
BUF_DEC
BUF1CRB	DS.B	20480
BUF2CRB	DS.B	20480
	EVEN
*** DEL
t_points	ds.w	20	
tdroit	ds.w	200
tgauch	ds.w	200
ancl	ds.w	1
stimb	ds.l	1
*
DONNEE	DS	1
DONNEE2	DS	1
*
PNT_W	DS.L	1
PNT_W2	DS.L	1
PNT_W3	DS.L	1
PNT_W4	DS.L	1
*
PREDEC_TAB	DS.L	8
;BUF_DEC	DS.L	(12*Y)*8
PNT_CRB	DS.L	1
VARI	DS.W	1
ADD1	DS.W	1
FLAG_EFF	DS.W	1
TABLE_GEN	DS.L	400
POINT	DS.L	1
POINT2	DS.L	1
BUF_LET	DS.B	(1*8)*2
BUF_LET2	DS.B	(1*8)*2

