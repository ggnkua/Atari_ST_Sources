*	This is basically the Noisetracker source by the Empire (?)
*	and as such, is Public Domain... Though it has been changed
*	a little, so you'd probably be better swiping it off the
*	noisetracker disk...

*	The init_muzexx routine here has had the call to reverse_samples
*	removed, because it takes memory to do this and corrupts the
*	screen on a half meg ST + takes a little time, so all the music
*	for GRAV 2 has already had all the samples reversed, rendering
*	this call useless... That is why its been commented out.

*	Sorry about the absolute lack of comments, but I don't fully
*	understand what's going on...!!


SAVE_INTERRUPTS
	MOVE	#$2700,SR
	LEA		SAVE_INT(PC),A1
	LEA		TIMERA(PC),A2
	LEA		$FFFFFA00.W,A0
	MOVEP	$7(A0),D0
	MOVE	D0,(A1)
	MOVE.B	$13(A0),(A2)
	MOVE.B	$19(A0),1(A2)
	MOVE.B	#0,$19(A0)
	MOVE.B	$1F(A0),2(A2)
	MOVE.B	1(A2),$19(A0)
	MOVE.B	$17(A0),3(A2)
	LEA		$FFFF8200.W,A0
	MOVEP	$1(A0),D0
	MOVE	D0,4(A1)
	MOVE.B	$A(A0),6(A1)
	MOVE.B	$60(A0),7(A1)
	MOVEM.L	$40(A0),D0-D7
	MOVEM.L	D0-D7,8(A1)
	MOVE.L	$68.W,40(A1)
	MOVE.L	$70.W,44(A1)
	MOVE.L	$114.W,48(A1)
	MOVE.L	$118.W,52(A1)
	MOVE.L	$11C.W,56(A1)
	MOVE.L	$120.W,60(A1)
	MOVE.L	$134.W,64(A1)
	MOVE	#$2300,SR
	RTS

REINSTALL_INTERRUPTS
	MOVE	#$2700,SR
	LEA		SAVE_INT(PC),A1
	LEA		TIMERA(PC),A2
	MOVE.L	40(A1),$68.W
	MOVE.L	44(A1),$70.W
	MOVE.L	48(A1),$114.W
	MOVE.L	52(A1),$118.W
	MOVE.L	56(A1),$11C.W
	MOVE.L	60(A1),$120.W
	MOVE.L	64(A1),$134.W
	LEA		$FFFFFA00.W,A0
	MOVE.B	3(A2),$17(A0)
	MOVE	(A1),D0
	MOVEP	D0,$7(A0)
	MOVE.B	#0,$19(A0)
	MOVE.B	2(A2),$1F(A0)
	MOVE.B	1(A2),$19(A0)
	MOVE.B	(A2),$13(A0)
	*LEA		$FFFF8200.W,A0
	*MOVE	4(A1),D0
	*MOVEP	D0,$1(A0)
	*MOVE.B	6(A1),$A(A0)
	*MOVE.B	7(A1),$60(A0)
	*MOVEM.L	8(A1),D0-D7
	*MOVEM.L	D0-D7,$40(A0)
	MOVE	#$2300,SR
	RTS

INIT_MUZEXX
	LEA		SEQ(PC),A0
	LEA		PAT(PC),A1
	LEA		NBR_INS(PC),A2
	LEA		MUZEXX(PC),A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE		REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	LEA		MUZEXX(PC),A0
	ADD		SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF		D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA		MUZEXX(PC),A0
	ADD		PAT,A0
	ADD.L	D2,A0
	LEA		20+MUZEXX(PC),A1
	LEA		16+INS(PC),A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
INIT_MUZEXX3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ		INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE		INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA		30(A1),A1
	LEA		16(A2),A2
	DBRA	D0,INIT_MUZEXX3
	RTS

REVERSE_SAMPLES
	LEA		16+INS(PC),A0
	MOVEQ	#0,D0
	MOVE	4+SAVE_INT(PC),D0
	LSL.L	#8,D0
	SUB.L	#$8000,D0
	MOVE.L	D0,A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
REVERSE
	MOVE.L	(A0),D1
	BEQ		END_REVERSE_THIS_INS
	SUBQ.L	#1,D1
	MOVE.L	D1,D2
	MOVE.L	4(A0),A3
REV_1
	MOVE.B	(A3)+,(A2)+
	DBRA	D1,REV_1
	MOVE.L	4(A0),A3
REV_2
	MOVE.B	-(A2),(A3)+
	DBRA	D2,REV_2
END_REVERSE_THIS_INS
	LEA		16(A0),A0
	DBRA	D0,REVERSE
	RTS

PLAY_MUZEXX
MFP_RESET
	MOVE.B	#0,$FFFFFA07.W
	MOVE.B	#0,$FFFFFA09.W
YAMAHA_RESET
	MOVE.B	#0,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#1,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#2,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#3,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#4,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#5,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#7,$FFFF8800.W
	MOVE.B	#$FF,$FFFF8802.W
	MOVE.B	#8,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#9,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
	MOVE.B	#10,$FFFF8800.W
	MOVE.B	#0,$FFFF8802.W
ON	MOVE	#$2700,SR
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX(PC),A0
	ADD		SEQ(PC),A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF(PC),A0
	LEA		OFF(PC),A1
	LEA		OFF(PC),A2
	LEA		OFF(PC),A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	CLR.L	CV0+2
	CLR.L	CV1+2
	CLR.L	CV2+2
	CLR.L	CV3+2
	CLR.L	CF0+2
	CLR.L	CF1+2
	CLR.L	CF2+2
	CLR.L	CF3+2

	MOVE.B	#0,$FFFFFA19.W
	MOVE.B	#61,$FFFFFA1F.W
	MOVE.B	#1,$FFFFFA19.W
	BCLR	#3,$FFFFFA17.W
	MOVE.L	#AMIGA,$134.W
	OR.B	#%00100000,$FFFFFA13.W
	OR.B	#%00100000,$FFFFFA07.W
	OR.B	#%01000000,$FFFFFA09.W
	MOVE.L	#VBL,$70.W
	MOVE	#$2300,SR
	RTS

* REPLAY CARTRIDGE FREQUENCY
REPLAY							;44(5/3)
	MOVEM.L	D4-D5/A4,-(SP)		;8+3*8
	SWAP	D0					;4(1/0)
	SWAP	D1					;4(1/0)
	SWAP	D2					;4(1/0)
	SWAP	D3					;4(1/0)
CV0	SUB.L	#0,D0				;16(3/0)
	BMI.S	CL0					;8(2/0)12
CV1	SUB.L	#0,D1				;16(3/0)
	BMI.S	CL1					;8(2/0)12
CV2	SUB.L	#0,D2				;16(3/0)
	BMI.S	CL2					;8(2/0)12
CV3	SUB.L	#0,D3				;16(3/0)
	BMI.S	CL3					;8(2/0)12
COUT
	SWAP	D0					;4(1/0)
	SWAP	D1					;4(1/0)
	SWAP	D2					;4(1/0)
	SWAP	D3					;4(1/0)
	MOVE.B	0(A0,D0),D4			;14(3/0)
	EXT.W	D4					;4(1/0)
	MOVE.B	0(A1,D1),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	MOVE.B	0(A2,D2),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	MOVE.B	0(A3,D3),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	ADD.W	#$80*4,D4			;8(2/0)
	AND.W	#$3FC,D4			;8(2/0)
	LSR.W	#1,D4				;8(1/0)
	LEA		$FA0000,A4			;12(3/0)
	MOVE.B	(A4,D4),D4			;14(3/0)
	MOVEM.L	(SP)+,D4-D5/A4		;12+3*8
CWB	RTE							;20(5/0)
CL0	MOVE.L	#0,D0
CF0	MOVE.L	#0,CV0+2
	BRA		CV1
CL1	MOVE.L	#0,D1
CF1	MOVE.L	#0,CV1+2
	BRA		CV2
CL2	MOVE.L	#0,D2
CF2	MOVE.L	#0,CV2+2
	BRA		CV3
CL3	MOVE.L	#0,D3
CF3	MOVE.L	#0,CV3+2
	BRA		COUT

L0	MOVE.L	#0,D0
F0	MOVE.L	#0,V0+2
	BRA		V1
L1	MOVE.L	#0,D1
F1	MOVE.L	#0,V1+2
	BRA		V2
L2	MOVE.L	#0,D2
F2	MOVE.L	#0,V2+2
	BRA		V3
L3	MOVE.L	#0,D3
F3	MOVE.L	#0,V3+2
	BRA		OUT
;AMIGA SOUND CHIP
AMIGA							;44(5/3)
	MOVEM.L	D4-D5/A4,-(SP)		;8+3*8
	SWAP	D0					;4(1/0)
	SWAP	D1					;4(1/0)
	SWAP	D2					;4(1/0)
	SWAP	D3					;4(1/0)
V0	SUB.L	#0,D0				;16(3/0)
	BMI.S	L0					;8(1/0)10
V1	SUB.L	#0,D1				;16(3/0)
	BMI.S	L1					;8(1/0)10
V2	SUB.L	#0,D2				;16(3/0)
	BMI.S	L2					;8(1/0)10
V3	SUB.L	#0,D3				;16(3/0)
	BMI.S	L3					;8(1/0)10
OUT	SWAP	D0					;4(1/0)
	SWAP	D1					;4(1/0)
	SWAP	D2					;4(1/0)
	SWAP	D3					;4(1/0)
	MOVE.B	0(A0,D0),D4			;14(3/0)
	EXT.W	D4					;4(1/0)
	MOVE.B	0(A1,D1),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	MOVE.B	0(A2,D2),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	MOVE.B	0(A3,D3),D5			;14(3/0)
	EXT.W	D5					;4(1/0)
	ADD.W	D5,D4				;4(1/0)
	ADD.W	D4,D4				;4(1/0)
	AND.W	#$7F8,D4			;8(2/0)
	MOVE.L	SOUND(PC,D4),D5		;18(4/0)
	MOVE.W	SOUND+4(PC,D4),D4	;14(3/0)
	LEA		$FFFF8800.W,A4		;8(2/0)
	MOVEP.L	D5,(A4)				;24(2/4)
	MOVEP.W	D4,(A4)				;16(2/2)
	MOVEM.L	(SP)+,D4-D5/A4		;12+3*8
WB	RTE							;20(5/0)

SOUND
	DC.W	$80C,$90B,$A09,0,$80C,$90B,$A09,0
	DC.W	$80D,$908,$A08,0,$80B,$90B,$A0B,0
	DC.W	$80D,$909,$A05,0,$80C,$90B,$A08,0
	DC.W	$80D,$909,$A02,0,$80D,$908,$A06,0
	DC.W	$80C,$90B,$A07,0,$80D,$907,$A07,0
	DC.W	$80C,$90B,$A06,0,$80C,$90A,$A09,0
	DC.W	$80B,$90B,$A0A,0,$80C,$90B,$A02,0
	DC.W	$80C,$90B,$A00,0,$80C,$90A,$A08,0
	DC.W	$80D,$906,$A04,0,$80D,$905,$A05,0
	DC.W	$80D,$905,$A04,0,$80C,$909,$A09,0
	DC.W	$80D,$904,$A03,0,$80B,$90B,$A09,0
	DC.W	$80C,$90A,$A05,0,$80B,$90A,$A0A,0
	DC.W	$80C,$909,$A08,0,$80B,$90B,$A08,0
	DC.W	$80C,$90A,$A00,0,$80C,$90A,$A00,0
	DC.W	$80C,$909,$A07,0,$80B,$90B,$A07,0
	DC.W	$80C,$909,$A06,0,$80B,$90B,$A06,0
	DC.W	$80B,$90A,$A09,0,$80B,$90B,$A05,0
	DC.W	$80A,$90A,$A0A,0,$80B,$90B,$A02,0
	DC.W	$80B,$90A,$A08,0,$80C,$907,$A07,0
	DC.W	$80C,$908,$A04,0,$80C,$907,$A06,0
	DC.W	$80B,$909,$A09,0,$80C,$906,$A06,0
	DC.W	$80A,$90A,$A09,0,$80C,$907,$A03,0
	DC.W	$80B,$90A,$A05,0,$80B,$909,$A08,0
	DC.W	$80B,$90A,$A03,0,$80A,$90A,$A08,0
	DC.W	$80B,$90A,$A00,0,$80B,$909,$A07,0
	DC.W	$80B,$908,$A08,0,$80A,$90A,$A07,0
	DC.W	$80A,$909,$A09,0,$80C,$901,$A01,0
	DC.W	$80A,$90A,$A06,0,$80B,$908,$A07,0
	DC.W	$80A,$90A,$A05,0,$80A,$909,$A08,0
	DC.W	$80A,$90A,$A02,0,$80A,$90A,$A01,0
	DC.W	$80A,$90A,$A00,0,$809,$909,$A09,0
	DC.W	$80A,$908,$A08,0,$80B,$908,$A01,0
	DC.W	$80A,$909,$A06,0,$80B,$907,$A04,0
	DC.W	$80A,$909,$A05,0,$809,$909,$A08,0
	DC.W	$80A,$909,$A03,0,$80A,$908,$A06,0
	DC.W	$80A,$909,$A00,0,$809,$909,$A07,0
	DC.W	$809,$908,$A08,0,$80A,$908,$A04,0
	DC.W	$809,$909,$A06,0,$80A,$908,$A01,0
	DC.W	$809,$909,$A05,0,$809,$908,$A07,0
	DC.W	$808,$908,$A08,0,$809,$909,$A02,0
	DC.W	$809,$908,$A06,0,$809,$909,$A00,0
	DC.W	$809,$907,$A07,0,$808,$908,$A07,0
	DC.W	$809,$907,$A06,0,$809,$908,$A02,0
	DC.W	$808,$908,$A06,0,$809,$906,$A06,0
	DC.W	$808,$907,$A07,0,$808,$908,$A04,0
	DC.W	$808,$907,$A06,0,$808,$908,$A02,0
	DC.W	$807,$907,$A07,0,$808,$906,$A06,0
	DC.W	$808,$907,$A04,0,$807,$907,$A06,0
	DC.W	$808,$906,$A05,0,$808,$906,$A04,0
	DC.W	$807,$906,$A06,0,$807,$907,$A04,0
	DC.W	$808,$905,$A04,0,$806,$906,$A06,0
	DC.W	$807,$906,$A04,0,$807,$905,$A05,0
	DC.W	$806,$906,$A05,0,$806,$906,$A04,0
	DC.W	$806,$905,$A05,0,$806,$906,$A02,0
	DC.W	$806,$905,$A04,0,$805,$905,$A05,0
	DC.W	$806,$905,$A02,0,$805,$905,$A04,0
	DC.W	$805,$904,$A04,0,$805,$905,$A02,0
	DC.W	$804,$904,$A04,0,$804,$904,$A03,0
	DC.W	$804,$904,$A02,0,$804,$903,$A03,0
	DC.W	$803,$903,$A03,0,$803,$903,$A02,0
	DC.W	$803,$902,$A02,0,$802,$902,$A02,0
	DC.W	$802,$902,$A01,0,$801,$901,$A01,0
	DC.W	$802,$901,$A00,0,$801,$901,$A00,0
	DC.W	$801,$900,$A00,0,$800,$900,$A00,0
	DC.W	$80E,$90D,$A0C,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80F,$903,$A00,0
	DC.W	$80F,$903,$A00,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0B,0,$80E,$90D,$A0B,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90D,$A0A,0,$80E,$90D,$A0A,0
	DC.W	$80E,$90C,$A0C,0,$80E,$90D,$A00,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80D,$90D,$A0D,0,$80D,$90D,$A0D,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0B,0,$80E,$90C,$A0B,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80E,$90C,$A0A,0,$80E,$90C,$A0A,0
	DC.W	$80D,$90D,$A0C,0,$80D,$90D,$A0C,0
	DC.W	$80E,$90C,$A09,0,$80E,$90C,$A09,0
	DC.W	$80E,$90C,$A05,0,$80E,$90C,$A00,0
	DC.W	$80E,$90C,$A00,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0B,0
	DC.W	$80E,$90B,$A0B,0,$80E,$90B,$A0A,0
	DC.W	$80E,$90B,$A0A,0,$80E,$90B,$A0A,0
	DC.W	$80D,$90D,$A0B,0,$80D,$90D,$A0B,0
	DC.W	$80D,$90D,$A0B,0,$80E,$90B,$A09,0
	DC.W	$80E,$90B,$A09,0,$80E,$90B,$A09,0
	DC.W	$80D,$90C,$A0C,0,$80D,$90D,$A0A,0
	DC.W	$80E,$90B,$A07,0,$80E,$90B,$A00,0
	DC.W	$80E,$90B,$A00,0,$80D,$90D,$A09,0
	DC.W	$80D,$90D,$A09,0,$80E,$90A,$A09,0
	DC.W	$80D,$90D,$A08,0,$80D,$90D,$A07,0
	DC.W	$80D,$90D,$A04,0,$80D,$90D,$A00,0
	DC.W	$80E,$90A,$A04,0,$80E,$909,$A09,0
	DC.W	$80E,$909,$A09,0,$80D,$90C,$A0B,0
	DC.W	$80E,$909,$A08,0,$80E,$909,$A08,0
	DC.W	$80E,$909,$A07,0,$80E,$908,$A08,0
	DC.W	$80E,$909,$A01,0,$80C,$90C,$A0C,0
	DC.W	$80D,$90C,$A0A,0,$80E,$908,$A06,0
	DC.W	$80E,$907,$A07,0,$80E,$908,$A00,0
	DC.W	$80E,$907,$A05,0,$80E,$906,$A06,0
	DC.W	$80D,$90C,$A09,0,$80E,$905,$A05,0
	DC.W	$80E,$904,$A04,0,$80D,$90C,$A08,0
	DC.W	$80D,$90B,$A0B,0,$80E,$900,$A00,0
	DC.W	$80D,$90C,$A06,0,$80D,$90C,$A05,0
	DC.W	$80D,$90C,$A02,0,$80C,$90C,$A0B,0
	DC.W	$80C,$90C,$A0B,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80D,$90B,$A0A,0
	DC.W	$80D,$90B,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80C,$90C,$A0A,0,$80C,$90C,$A0A,0
	DC.W	$80D,$90B,$A09,0,$80D,$90B,$A09,0
	DC.W	$80D,$90A,$A0A,0,$80D,$90A,$A0A,0
	DC.W	$80D,$90A,$A0A,0,$80C,$90C,$A09,0
	DC.W	$80C,$90C,$A09,0,$80C,$90C,$A09,0
	DC.W	$80D,$90B,$A06,0,$80C,$90B,$A0B,0
	DC.W	$80C,$90C,$A08,0,$80D,$90B,$A00,0
	DC.W	$80D,$90B,$A00,0,$80C,$90C,$A07,0
	DC.W	$80C,$90C,$A06,0,$80C,$90C,$A05,0
	DC.W	$80C,$90C,$A03,0,$80C,$90C,$A01,0
	DC.W	$80C,$90B,$A0A,0,$80D,$90A,$A05,0
	DC.W	$80D,$90A,$A04,0,$80D,$90A,$A02,0
	DC.W	$80D,$909,$A08,0,$80D,$909,$A08,0

VBL
	MOVE	#$2700,SR
	jsr	standard_vbl
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	JSR		EFFECT
END_VBL
	ST		SWITCH
	RTE

PLAY
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI		RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA		MUZEXX(PC),A0
	ADD		PAT(PC),A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT(PC),A0
	LEA		FRQ(PC),A1
	LEA		INS(PC),A2
	LEA		COMMAND(PC),A3
	LEA		VOICE0(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE1(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE2(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE3(PC),A4
	BSR		LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
* ADDRESS ALL 4 VOICES
	MOVEM.L	D4/A5,-(SP)
	LEA		VOICE0(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	D4,CL0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	D4,CV0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
	MOVE.L	D4,CF0+2
CONT0
	CLR.B	20(A5)
	LEA		VOICE1(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	D4,CL1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	D4,CV1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
	MOVE.L	D4,CF1+2
CONT1
	CLR.B	20(A5)
	LEA		VOICE2(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	D4,CL2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	D4,CV2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
	MOVE.L	D4,CF2+2
CONT2
	CLR.B	20(A5)
	LEA		VOICE3(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	D4,CL3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	D4,CV3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
	MOVE.L	D4,CF3+2
CONT3
	CLR.B	20(A5)
	MOVEM.L	(SP)+,D4/A5

	BRA		END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND		#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD		D0,D0
	ADD		D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND		#$FF0,D1
	BEQ.S	COMMAND?
	MOVE.L	12(A4),16(A4)
	MOVE.L	0(A2,D1.W),(A4)
	MOVE.L	4(A2,D1.W),4(A4)
	MOVE.L	8(A2,D1.W),8(A4)
	BNE.S	REPEAT
	CLR.L	16(A4)
REPEAT
COMMAND?
	MOVE	(A0)+,D0
	MOVE.B	D0,D1
	AND		#$F00,D0
	LSR		#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP		(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		*ARPEGGIO COUNTER
	MOVE	#1,30(A4)
NO_ARPEGGIO
	RTS

PORTAMENTO_UP
	MOVE.B	#1,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

PORTAMENTO_DOWN
	MOVE.B	#2,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

POSITION_JUMP
	LEA		MUZEXX(PC),A5
	ADD		SEQ(PC),A5
	LEA		-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB		D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE			*NO REAL TIME VOLUME VARIATION
	CLR.L	12(A4)				*IN THIS VERSION! MAYBE
	MOVE.B	#1,20(A4)			*SOME OTHER DAY...
NO_CHANGE
	RTS

PATTERN_BREAK
	MOVE.B	#1,POS
	RTS

SET_FILTER
	RTS

SET_SPEED
	MOVE.B	D1,SPD+3
	MOVE.B	D1,SPEED
	RTS

COMMAND		DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,POSITION_JUMP
			DC.L	SET_VOLUME,PATTERN_BREAK,SET_FILTER,SET_SPEED

EFFECT
	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA		FRQ(PC),A5
	LEA		VOICE0(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT1
	BSR		DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA		VOICE1(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT2
	BSR		DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA		VOICE2(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT3
	BSR		DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA		VOICE3(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT4
	BSR		DO_EFFECT
	MOVE.L	26(A6),V3+2
	TST.L	F3+2
	BEQ.S	CONT_EFFECT4
	MOVE.L	26(A6),F3+2
CONT_EFFECT4
	MOVEM.L	(SP)+,D4-D6/A4-A6
	RTS

DO_EFFECT
	MOVE.B	22(A6),D4
	BEQ.S	ARPEGGIO_ROUT
	CMP.B	#1,D4
	BEQ.S	PORTUP
	CMP.B	#2,D4
	BEQ.S	PORTDOWN
	RTS

PORTUP
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	SUB		D4,D5
	CMP		#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD		D4,D5
	CMP		#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

ARPEGGIO_ROUT
	MOVE.B	21(A6),D4
	CMP.B	#1,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#2,D4
	BEQ.S	ARP_ROUT2
	CMP.B	#3,D4
	BEQ.S	ARP_ROUT3
	CMP.B	#4,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#5,D4
	BEQ.S	ARP_ROUT2
	RTS

ARP_ROUT1
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	LSR.B	#4,D4
	BRA.S	ARP_ROUT
ARP_ROUT2
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	AND.B	#$0F,D4
	BRA.S	ARP_ROUT
ARP_ROUT3
	MOVE	24(A6),D6
	BRA.S	END_ARP_ROUT2
ARP_ROUT
	ADD		D4,D4
	MOVE	24(A6),D5
	LEA		ARPEGGIO_DATA(PC),A4
ARP_LOOP
	CMP		(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA		2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD		D6,D6
	ADD		D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE.W	#1,RESTRT
	MOVE	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	CLR.L	CV0+2
	CLR.L	CV1+2
	CLR.L	CV2+2
	CLR.L	CV3+2
	CLR.L	CF0+2
	CLR.L	CF1+2
	CLR.L	CF2+2
	CLR.L	CF3+2
	BRA		PLAY

VSYNC
	SF		SWITCH
WAIT_VBL
	TST.B	SWITCH
	BEQ.S	WAIT_VBL
	RTS

RESTRT		DC.W	0
OFF		DC.L	0
SPEED		DC.B	0
POS		DC.B	0
TRK		DC.B	0
SEQ		DS.W	1
PAT		DS.W	1
NBR_INS		DS.W	1
FRQ		INCBIN	"a:\grav_2\data\10_khz.frq"
ARPEGGIO_DATA	DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
		DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
		DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
		DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
		DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

SAVE_INT	DS.L	17
TIMERA		DS.L	1
SWITCH		DS.W	1
KEY_PRESS	DS.W	1
VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
INS		DS.L	32*4
MUZEXX
