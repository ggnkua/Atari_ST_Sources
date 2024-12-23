** FROM DODGYSOFT INC! BY DODGY KING.....**

	LEA $80000,A7
	DC.W $A00A
	CLR.L -(A7)
	MOVE.W #32,-(A7)
	TRAP #1
	ADDQ.L #6,A7
	CLR.W -(A7)
	MOVE.L #$78000,-(A7)
	MOVE.L #$78000,-(A7)
	MOVE.W #5,-(A7)
	TRAP #14
	LEA 12(A7),A7
	MOVE.L #TEXT,-(A7)
	MOVE.W #9,-(A7)
	TRAP #1
	ADDQ.L #6,A7
	MOVE.W #7,-(A7)
	TRAP #1
	ADDQ.L #2,A7
	LEA RTS(PC),A0
	MOVE.L #F3,A1
	MOVE.L #$80000,A2
LPRT	MOVE.B (A0)+,(A2)+
	CMP.L A0,A1
	BNE LPRT
	JMP $80000
TEXT	DC.B $1B,"E"
	DC.B $1B,"Y",32+2,32+0,"POMPEY PACKER V1.9a   "
	DC.B $1B,"Y",32+4,32+0,"PACK BY BLAH BLAH....."
	DC.B $1B,"Y",32+5,32+0,"                      "
	DC.B $1B,"Y",32+7,32+0,"PRESS ANY KEY TO PLAY!",0
	EVEN
RTS	MOVE.W #$2700,SR
	LEA F1(PC),A0
	ADD.L #F3-F1,A0
	MOVE.L #$10000,A2
	bsr depack
	MOVE.L #$10000,A0
	MOVE.L #$10000+190554,A1
	MOVE.L #$200,A2
RTS1	MOVE.W (A0)+,(A2)+
	CMP.L A0,A1
	BNE RTS1
RTS2	CLR.W (A2)+
	CMP.L #$78000,A2
	BNE RTS2
	LEA F1(PC),A2
	MOVE.L A2,A0
	ADD.L #F2-F1,A0
	bsr depack	
	MOVE.W #$4EF9,$34EE
	LEA LDR(PC),A0
	MOVE.L A0,$34F0
	JMP $90C.W
LDR	MOVEM.L D0-D7/A0-A6,-(A7)
	MOVE.L A0,$37E4
	EXT.L D0
	EXT.L D1
	CMP.W #$13E,D0
	BLT LDRR
	CMP.L #$13E,D0
	BNE L2
	MOVEQ.L #0,D0
	BRA L3
L2	SUB.L #$13F,D0
L3	LEA F1(PC),A1
	MOVE.L A1,A2
	MULU #512,D0
	MULU #512,D1
	ADD.L D0,A1
	ADD.L D0,A2
	ADD.L D1,A2
L1	MOVE.B (A1)+,(A0)+
	CMP.L A1,A2
	BNE L1
LDRR	MOVEM.L (A7)+,D0-D7/A0-A6
	CLR.W D4
	TST.W D4
	RTS
depack	SUB.L #4,A0	
		move.l -(a0),d6		;d6 = realsize
		move.l -(a0),d2		;d2 = packed size
		move.l a2,a4
		add.l d6,a2
		moveq.l #0,d0
		move.l #$ff8240,a6
		move.w (a6),d7
pack_0		move.b -(a0),d0
		beq.s pack_0
pack_1		moveq.l #0,d2
		bsr pack_15
		bcs.s pack_4
		move.b -(a0),d2
pack_2		move.b d2,-(a2)
		bra.s pack_6
pack_3		moveq.l #15,d4
		moveq.l #2,d3
		bsr pack_18
		bne pack_13
		move.w d4,d2
		bra.s pack_2
pack_4		bsr pack_15
		bcc pack_9
		bsr pack_15
		bcc pack_3
		bsr pack_15
		bcs pack_5
		moveq.l #2,d1
		bsr pack_22
		exg d1,d2
		addq.w #1,d2
		bset d1,d2
		bra pack_2
pack_5		bsr pack_15
		bcs.s pack_8
		moveq.l #15,d4
		moveq.w #3,d3
		bsr.s pack_18
		bne.s pack_13
		move.b (a2),-(a2)
pack_6		neg.w (a6)
		move.w d7,(a6)	
		cmpa.l a2,a4
		blt pack_1
pack_7		rts
pack_8		moveq.l #4,d3
		bra.s pack_12
pack_9		bsr pack_15
		bcs pack_27
		moveq.l #1,d1
pack_10		lsr.b #1,d0
		bne.s pack_11
		move.b -(a0),d0
		roxr.b #1,d0
pack_11		addx.w d2,d2
		dbf d1,pack_10
		move.w d2,d1
		beq pack_26
		addq.w #1,d1
		add.w d1,d1
		subq.w #1,d1
		bsr pack_22
		move.w d2,d3
pack_12		bsr.s pack_17
pack_13		movea.l a2,a1
		adda.l d2,a1
pack_14		move.b -(a1),-(a2)
		dbf d3,pack_14
		bra pack_6
pack_15		lsr.b #1,d0
		bne.s pack_16
		move.b -(a0),d0
		roxr.b #1,d0
pack_16		rts
pack_17		moveq.l #0,d4
pack_18		moveq.l #1,d1
		moveq.l #0,d2
pack_19		lsr.b #1,d0
		bne.s thanks_jpm
pack_20		move.b -(a0),d0
		roxr.b #1,d0
thanks_jpm	addx.w d2,d2
		dbf d1,pack_19
		move.w d2,d1
		addq.w #1,d1
		lsl.w #2,d1
		subq.w #1,d1
		eor.b d1,d4
		bne.s pack_22
		rts
pack_21		moveq.l #7,d1
pack_22		moveq.l #0,d2
pack_23		lsr.b #1,d0
		bne.s pack_25
pack_24		move.b -(a0),d0
		roxr.b #1,d0
pack_25		addx.w d2,d2
		dbf d1,pack_23
		rts
pack_26		bsr pack_17
		move.w d2,d3
		moveq.l #1,d2
		bra pack_13
pack_27		moveq.l #1,d3
		move.b -(a0),d2
		bra pack_13 
ret		rts		

** GAME NAMES GO HERE! ****
	
F1	INCBIN "INTRO.PRG"
F2	INCBIN "GAME.DAT"
F3	INCBIN "FILES.DAT"
