* Perfect Sideways hardware scroll using only 1 scanline!!
* Unfortuantely it works on very few st's!!!

		CLR -(SP)
		PEA -1.W	
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP	
		CLR.L -(SP)
		MOVE #$20,-(sp)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L log_base(PC),A1
		MOVE.L A1,D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		LEA pic+34(PC),A0
		MOVE #1999,d0
copy:		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,copy
		MOVE.L $70.W,old_vbl
		MOVE.L #vbl,$70.w
		MOVE #7,-(sp)
		TRAP #1
		ADDQ.L #2,sp
		MOVE.L old_vbl(PC),$70.W
		CLR -(sp)
		TRAP #1

vbl		MOVE #$2700,SR
		MOVEM.L D0-D5/A0-A2,-(SP)
		ADDQ #1,vbl_timer
		SUBQ #8,sc_x
		BPL.S hscr_nwrap
		MOVE #152,sc_x
hscr_nwrap	MOVE #$8209,A0
waits		MOVE.B (A0),D0
		BEQ.S	waits
		MOVEQ #10,D1
		SUB D0,D1
		LSL D1,D0
		MOVEQ #25,D0
delay_lp	DBF D0,delay_lp
		NOP
		moveq #0,d3
		MOVEQ #2,D4
		MOVEQ #3,D5
		MOVE #$820a,A0
		MOVE #$8260,A2
line_lp	MOVE.B D5,(A0)
		MOVE sc_x(PC),D0
		neg d0
		LEA no_scr(PC),A1
		jmp -38(A1,D0)
		dcb.w 99,$4e71
no_scr	MOVE.B D4,(A0)
		MOVEM.L (SP)+,D0-D5/A0-A2
		RTE
sc_x		DC.W 152
vbl_timer	DC.W 0
old_vbl	DC.L 0
log_base	DC.L $A0000
pic		INCBIN \OXYGENE.PI1