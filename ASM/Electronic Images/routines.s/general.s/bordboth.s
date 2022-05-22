* BOTH BORDER GET RIDDER.
* By Martin Griffiths (C) AUG 1989
* Using timer A for top border.
* updated MARCH 1990 - bottom bord made STE compatable.
*                    - Top border done with STOP to get 8 cycle sync.

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #$2700,SR
		LEA stack(PC),SP
		MOVE.L log_base(PC),A0
		MOVE.L A0,D2
		MOVE #11999,D0
		MOVEQ #-1,D1
b_lp		MOVE.L D1,(A0)+
		DBF D0,b_lp
set_scrn	LSR #8,D2
		MOVE.L D2,$FFFF8200.W

interrupts	LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA19.W
		MOVE.B #$21,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #$21,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #topbord,$134.W
		MOVE.L #hbl_1,$120.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR

wait_key	btst #0,$fffffc00.w
		beq.s wait_key
		move.b $fffffc02.w,d0
		cmp.b #$39,d0
		bne.s wait_key

restore	MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1
		
my_vbl	CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #228,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L #phbl,$68.W
		ADDQ #1,vbl_timer
		RTE

topbord	MOVE #$2100,sr
		STOP #$2100
		CLR.B $FFFFFA19.W
		DCB.W 78,$4E71
		CLR.B $FFFF820A.W
		DCB.W 18,$4E71
		MOVE.B #2,$FFFF820A.W
		RTE
phbl		RTE

hbl_1		MOVE D0,-(SP)
		DCB.W 32,$4e71
		CLR D0
.syncb		MOVE.B $ffff8209.w,D0
		NEG.B D0
		ADD.B #64+128,D0
		LSL.B D0,D0
		MOVE #18,D0
.wait		DBF D0,.wait		;101 nops!
		MOVE.B #0,$FF820A
		DCB.W 12,$4E71
		MOVE.B #2,$FF820A
		MOVE.w (SP)+,D0
		RTE
here		DC.W 0
log_base	DC.L $70300
vbl_timer	DS.W 1
		SECTION BSS
old_mfp	DS.L 7
		DS.L 149
stack		DS.L 1
