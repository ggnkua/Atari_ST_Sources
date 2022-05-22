* Decompress a Degas Elite screen
* A0 points to the compressed data.
* D0-D5/A0-A1 Smashed.

Decompress	MOVE.L log_base(PC),A1
		MOVE #199,D5
line_lp	MOVEQ #3,D4
plane_lp	MOVEQ #1,D3
		MOVEQ #39,D2
byte_lp	CLR D0
		MOVE.B (A0)+,D0
		BMI.S dup
		SUB.B D0,D2
		SUBQ.B #1,D2
move_lp	MOVE.B (A0)+,(A1)
		ADDA D3,A1
		EOR #6,D3
		DBF D0,move_lp
		BRA.S test
dup		NEG.B D0
		SUB.B D0,D2
		SUBQ.B #1,D2
		MOVE.B (A0)+,D1
dup_lp	MOVE.B D1,(A1)
		ADDA D3,A1
		EOR #6,D3
		DBF D0,dup_lp
test		TST.B D2
		BPL.S byte_lp
next_plne	LEA -158(A1),A1
		DBF D4,plane_lp
next_line	LEA 152(A1),A1
		DBF D5,line_lp
		RTS
