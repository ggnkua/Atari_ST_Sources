
	SECTION	TEXT

	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	LEA		6(SP),SP
	LEA		SAVE_STACK(PC),A0
	MOVE.L	D0,(A0)
	lea	pile,a7

*	bsr	INITMFP
	
	JSR	SAVE_INTERRUPTS(PC)
	MOVE.B	#$12,$FFFFFC02.W
	JSR	MAIN(PC)
EXIT
	MOVE.B	#$8,$FFFFFC02.W
	JSR	REINSTALL_INTERRUPTS(PC)

*	bsr	FINMFP

	MOVE.L	SAVE_STACK(PC),-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	LEA	6(SP),SP

GO_OUT
	CLR.w	-(SP)
	TRAP	#1

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
	LEA		$FFFF8200.W,A0
	MOVE	4(A1),D0
	MOVEP	D0,$1(A0)
	MOVE.B	6(A1),$A(A0)
	MOVE.B	7(A1),$60(A0)
	MOVEM.L	8(A1),D0-D7
	MOVEM.L	D0-D7,$40(A0)
	MOVE	#$2300,SR
	RTS

MAIN
	MOVE	#$2700,SR
	JSR	INIT_MUZEXX(PC)
	JSR	PLAY_MUZEXX(PC)
	JSR	REINSTALL_INTERRUPTS(PC)


INIT_MUZEXX
	LEA	SEQ(PC),A0
	LEA	PAT(PC),A1
	LEA	NBR_INS(PC),A2
	LEA	MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE	REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	LEA	MUZEXX,A0
	ADD	SEQ(PC),A0
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
	LEA		MUZEXX,A0
	ADD		PAT,A0
	ADD.L	D2,A0
	LEA		20+MUZEXX,A1
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
	rts
	
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
ON	
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	bsr	SET_SCR

	lea	DECOR+34,a0
	move.l	SCREEN1,a1
	move.l	SCREEN2,a2
	move.w	#8000-1,d0
AFF:	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,AFF
	
	lea	TEXTE,a0
	move.l	a0,MEM_LET	Position fonte (Table)
	move.w	#0,PART_AFF	(2 Parties)


	MOVE	#$2700,SR
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA	MUZEXX,A0
	ADD	SEQ(PC),A0
	LEA	-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA	OFF(PC),A0
	LEA	OFF(PC),A1
	LEA	OFF(PC),A2
	LEA	OFF(PC),A3
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
	movem.l	d0-d3/a0-a3,savreg

	MOVE.B	#0,$FFFFFA19.W
	MOVE.B	#61,$FFFFFA1F.W
	MOVE.B	#1,$FFFFFA19.W
	BCLR	#3,$FFFFFA17.W
	MOVE.L	#AMIGA,$134.W
	OR.B	#%00100000,$FFFFFA13.W
	OR.B	#%00100000,$FFFFFA07.W
	MOVE.L	#VBL,$70.W
	MOVE	#$2300,SR
	jsr	VSYNC

PROGRAM


	CMP.B	#$39,$fffffc02.w
	BEQ	END_OF_MUZEXX
	BRA	PROGRAM

AMIGA	movem.l	d4/a0-a1,-(sp)
poke	move.l	pt_buf1,a0
	move.w	(a0)+,d4
	move.l	a0,pt_buf1
	MOVE.L	SOUND(PC,D4),D4
	lea	$ffff8800.w,a1
	MOVEP.L	D4,(a1)	
	movem.l	(sp)+,d4/a0-a1
	RTE

SOUND
	incbin	"2cano.tab"

VBL
*	move.w	#$700,$ffff8240.w
	movem.l	d0-d7/a0-a6,-(sp)

	movem.l	DECOR+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.w	#$700,$ffff8240.w

	move.l	#HBL,$120.w
	clr.b	$fffffa1b.w
	move.b	#150,$fffffa21.w
	move.b	#8,$fffffa1b.w
	
	bsr	SWAP_SCR
	bsr	SCROLL
	bsr	AFF_FNT

pas_affichage

	movem.l	savreg,d0-d3/a0-a3
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	JSR	EFFECT
END_VBL	jsr	REMP_BUF
	movem.l	d0-d3/a0-a3,savreg
	MOVE	#$2700,SR

	move.l	pt_buf1,d0
	move.l	pt_buf2,pt_buf1
	move.w	#$2300,sr
	cmp.l	#buf2,d0
	blt	la
	move.l	#buf2,d0
	bra	ici
la	move.l	#buf1,d0
ici	move.l	d0,pt_buf2
	movem.l	(sp)+,d0-d7/a0-a6
	ST	SWITCH
	move.w	#$000,$ffff8240.w
	RTE

PLAY
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI	RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA		MUZEXX,A0
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
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
CONT0
	CLR.B	20(A5)
	LEA	VOICE1(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
CONT1
	CLR.B	20(A5)
	LEA		VOICE2(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
CONT2
	CLR.B	20(A5)
	LEA		VOICE3(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
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
	AND	#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND	#$FF0,D1
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
	AND	#$F00,D0
	LSR	#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP	(A5)

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
	LEA	MUZEXX,A5
	ADD	SEQ(PC),A5
	LEA	-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB	D1,D0
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

REMP_BUF
	move.w	#199,d7
	move.l	pt_buf2,a6

bo_buf	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3
V0	SUB.L	#0,D0
	BMI.S	L0
V1	SUB.L	#0,D1
	BMI.S	L1
V2	SUB.L	#0,D2
	BMI.S	L2
V3	SUB.L	#0,D3
	BMI.S	L3
OUT	SWAP	D0
	SWAP	D1
	SWAP	D2
	SWAP	D3

	MOVE.B	(A0,D0),D4
	EXT.W	D4
	MOVE.B	(A1,D1),D5
	EXT.W	D5
	ADD.W	D5,D4
	MOVE.B	(A2,D2),D5
	EXT.W	D5
	ADD.W	D5,D4
	MOVE.B	(A3,D3),D5
	EXT.W	D5
	ADD.W	D5,D4
	ADD.W	D4,D4
	AND.W	#$7F8,D4
	move.w	d4,(a6)+
	dbf	d7,bo_buf
	move.w	d4,(a6)+	
	move.w	d4,(a6)+	
	move.w	d4,(a6)+	
	move.w	d4,(a6)+	
	move.w	d4,(a6)+	
	rts
	
L0	MOVE.L	#0,D0
F0	MOVE.L	#0,V0+2
	BRA	V1
L1	MOVE.L	#0,D1
F1	MOVE.L	#0,V1+2
	BRA	V2
L2	MOVE.L	#0,D2
F2	MOVE.L	#0,V2+2
	BRA	V3
L3	MOVE.L	#0,D3
F3	MOVE.L	#0,V3+2
	BRA	OUT

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
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
	movem.l	d0-d3/a0-a3,savreg
	BRA	PLAY

END_OF_MUZEXX
	MOVE	#$2700,SR
	RTS

VSYNC
	SF	SWITCH
WAIT_VBL
	TST.B	SWITCH
	BEQ.S	WAIT_VBL
	RTS

HBL:	movem.l	d0-d7,-(sp)
	movem.l	IMAGE+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	movem.l	(sp)+,d0-d7
	bclr	#0,$fffffa0f.w	; Mise hors service du timer
	rte

**** Procedures ****
SET_SCR:	move.l	#BUFFERSCR,d0
	and.l	#$ffffff00,d0
	move.l	d0,SCREEN1
	add.l	#32000,d0
	move.l	d0,SCREEN2
	rts	
SWAP_SCR:	move.l	SCREEN1,d0	Ecran courant
	move.l	SCREEN2,SCREEN1
	move.l	d0,SCREEN2
	lsr.l	#8,d0		8*2=16
	move.l	#$ffff8201,a0
	movep	d0,(a0)
	rts
SCROLL:	move.l	SCREEN2,a0	Ecran de travail
	adda.l	#160*166,a0
	move.l	SCREEN2,a1
	adda.l	 #(160*166)+8,a1

	rept 	33*20
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	endr
	
	rts

AFF_FNT:	cmp.w	#1,PART_AFF
	blo	PART1
	beq	PART2
	cmp.w	#3,PART_AFF
	blo	PART3
	beq	PART4
	
PART1:	move.l	#IMAGE+34,a2	Pointe sur les fontes
	move.l	MEM_LET,a0
	adda.w	(a0),a2
	move.l	SCREEN2,a1	(8 pixels de large)
	adda.l	#160*166+152,a1
INC	set	0
	rept	33
	move.b	INC+9(a2),INC(a1)
	move.b	INC+11(a2),INC+2(a1)
	move.b	INC+13(a2),INC+4(a1)
	move.b	INC+15(a2),INC+6(a1)
INC	set	INC+160
	endr
	
	addq.l	#2,a0		On passe … une autre lettre
	cmp.w	#$ffff,(a0)
	bne	GO_LET
	lea	TEXTE,a0
GO_LET:	move.l	a0,MEM_LET	On sauvegarde le pointeur
	
	move.l	#IMAGE+34,a2
	adda.w	(a0),a2
INC	set 	0
	rept 	33
	move.b	INC+0(a2),INC+1(a1)
	move.b	INC+2(a2),INC+3(a1)
	move.b	INC+4(a2),INC+5(a1)
	move.b	INC+6(a2),INC+7(a1)
INC	set	INC+160
	endr
	move.w	#1,PART_AFF
	bra	FIN_SCRO	
	
PART2:	move.l	#IMAGE+34,a2
	move.l	MEM_LET,a0
	adda.w	(a0),a2
	move.l	SCREEN2,a1
	adda.l	#160*166+152,a1
INC	set	0
	rept	33
	move.l	INC(a2),INC(a1)
	move.l	INC+4(a2),INC+4(a1)
INC	set	INC+160
	endr
	move.w	#2,PART_AFF
	bra	FIN_SCRO

PART3:	move.l	#IMAGE+34,a2
	move.l	MEM_LET,a0
	adda.w	(a0),a2
	move.l	SCREEN2,a1
	adda.l	#160*166+152,a1
INC	set	0
	rept	33
	move.b	INC+1(a2),INC(a1)	
	move.b	INC+3(a2),INC+2(a1)	
	move.b	INC+5(a2),INC+4(a1)
	move.b	INC+7(a2),INC+6(a1)
	move.b	INC+8(a2),INC+1(a1)	
	move.b	INC+10(a2),INC+3(a1)	
	move.b	INC+12(a2),INC+5(a1)	
	move.b	INC+14(a2),INC+7(a1)	
INC	set	INC+160
	endr
	move.w	#3,PART_AFF
	bra	FIN_SCRO

PART4:	move.l	#IMAGE+34,a2
	move.l	MEM_LET,a0
	adda.w	(a0),a2
	move.l	SCREEN2,a1
	adda.l	#160*166+152,a1
INC	set	0
	rept	33
	move.l	INC+8(a2),INC(a1)
	move.l	INC+12(a2),INC+4(a1)
INC	set	INC+160
	endr
	move.w	#0,PART_AFF
	bra	FIN_SCRO

FIN_SCRO	rts	

INITMFP:  	move.w	sr,-(a7)	Initiamisation du MFP
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	OLDMFP,a1
	move.w	#16,d0
SAVEMFP:  	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,SAVEMFP
	
	movem.l	$100.w,d0-d7	; On sauvegarde les vecteur MFP
	movem.l	d0-d7,OLDVEC
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,OLDVEC+32
	movem.l	$58.w,d0-d7	; Et 68000...
	movem.l	d0-d7,OLDVEC+64
	
	move.b	#%00000001,$fffffa07.w ; On lance le timer B seul
	move.b	#%00000001,$fffffa13.w ; Pareil avec le masque
	
	move.b	#%01000000,$fffffa09.w
	move.b	#%01000000,$fffffa15.w
	
	clr.b	$fffffa1b.w	; Arret Timer B (Reg control)
	rte
	
FINMFP:   
	move.w	#$2700,sr

	lea	OLDMFP,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
RESTMFP:  	move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,RESTMFP
	
	
	move.w	#$777,$ffff8240.w
	move.w	#$000,$ffff8246.w
	rts


	SECTION	DATA


			DS.B	40
OFF			DC.L	0
SPEED		DC.B	0
POS			DC.B	0
TRK			DC.B	0
SEQ			DS.W	1
PAT			DS.W	1
NBR_INS		DS.W	1
FRQ			INCBIN	'10_KHZ.FRQ',0
ARPEGGIO_DATA	DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
				DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
				DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
				DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
				DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

pt_buf1	dc.l	buf1
pt_buf2	dc.l	buf2

*	SECTION	BSS
	ds.l	200
pile

savreg	ds.l	8
	ds.w	100
buf1	ds.w	205
	ds.w	100
buf2	ds.w	205

SAVE_INT	DS.L	17
TIMERA		DS.L	1
SAVE_STACK	DS.L	1
			DS.L	128
STACK
SWITCH		DS.W	1
KEY_PRESS	DS.W	1
VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
INS			DS.L	32*4

*	section	bss
	
SAV07	ds.b	1
SAV09	ds.b	1
SAV13	ds.b	1
SAV1B	ds.b	1
SAV21	ds.b	1
	even
SAV120	ds.l	1
	ds.b	256
BUFFERSCR:ds.b	32000*2
	ds.b	256
SCREEN1:	ds.l	1
SCREEN2:	ds.l	1
MEM_LET:	ds.l	1
PART_AFF:	ds.w	1
OLDMFP	ds.b	24
OLDVEC	ds.l	24
fi	
TEXTE:	INCBIN	b:\TEXTE.DAT
IMAGE:	INCBIN	b:\CD03FNTS.PI1
DECOR:	INCBIN	b:\CD03INTR.PI1
MUZEXX	incbin	"a:\jj*.mod"
	even

	END
