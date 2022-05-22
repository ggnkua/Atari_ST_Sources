; TOP BORDER GET RIDDER. By Martin Griffiths (C) AUG 1989
; (Using timer A + HBL)
; updated MARCH 1991 - Top border done with STOP to get 8 cycle sync.

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA stack(PC),SP
		MOVE.L log_base(PC),A0
		MOVE.L A0,D2
		MOVE #11999,D0
		MOVEQ #-1,D1
b_lp		MOVE.L D1,(A0)+
		DBF D0,b_lp
set_scrn	LSR #8,D2
		MOVE.L D2,$FFFF8200.W

		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE #$2700,SR
		MOVE.B #$20,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #$20,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #phbl,$68.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #topbord,$134.W
		MOVE #$2300,SR

wait_key	btst #0,$fffffc00.w
		beq.s wait_key
		cmp.b #$39+$80,$FFFFFC02.W
		bne.s wait_key

restore	MOVE #$2700,SR
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1
		
my_vbl	CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		ADDQ #1,vbl_timer
		RTE

topbord	MOVE #$2100,sr
		STOP #$2100
		CLR.B $FFFFFA19.W
		DCB.W 78,$4E71
		CLR.B $FFFF820A.W
		DCB.W 18,$4E71
		MOVE.B #2,$FFFF820A.W
phbl		RTE

log_base	DC.L $F0000
vbl_timer	DS.W 1
		SECTION BSS
old_mfp	DS.L 7
		DS.L 149
stack		DS.L 1
