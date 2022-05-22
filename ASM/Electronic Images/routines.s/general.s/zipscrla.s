* FAST(ish) Left Scroll routine
* By Martin Griffiths May 1989
* D0-D6/A0/A1 Smashed.
		
		BRA test

Any_scr_l	MOVE.L log_base(PC),A0
		MOVEQ #4,D5			pixel step			
		LEA 8(A0),A1
		MOVE #199,D6
linesc_lp	REPT 19
		MOVE.L (A1)+,D0
		MOVE.L (A1)+,D2
		MOVE D0,D1
		MOVE D2,D3
		SWAP D1
		SWAP D3
		MOVE (A0)+,D0
		MOVE (A0)+,D1
		MOVE (A0)+,D2
		MOVE (A0)+,D3
		ROL.L D5,D0
		ROL.L D5,D1
		ROL.L D5,D2
		ROL.L D5,D3
		MOVEM.W D0-D3,-8(A0)
		ENDR
		MOVEM.W (A0)+,D0-D3
		LSL D5,D0
		LSL D5,D1
		LSL D5,D2
		LSL D5,D3
		MOVEM.W D0-D3,-8(A0)
		ADDQ.L #8,A1
		DBF D6,linesc_lp
		RTS

test		MOVE #3,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,log_base
		MOVEQ #49,D7
tst_loop	BSR Any_scr_l
		DBF D7,tst_loop
		CLR -(SP)
		TRAP #1

log_base	DS.L 1