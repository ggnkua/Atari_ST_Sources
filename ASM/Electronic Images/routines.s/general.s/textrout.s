Setup		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		LEA log_base(PC),A0
		MOVE.L D0,(A0)

		LEA text(PC),A6
		BSR.S Print_text
		MOVE #1,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		CLR -(SP)
		TRAP #1

* Print string routine.
* A6 points to x/y co-ordinates,
* followed by text ended with 0.
* D0-D3/A0-A2 smashed.

Print_text	MOVE.L log_base(PC),A2
		MOVE (A6)+,D0
		MOVE (A6)+,D1
		MULU #160,D1
		ADDA D1,A2
		MOVE D0,D2
		AND #15,D2
text_lp	LEA font_buf(PC),A0
		CLR D1
		MOVE.B (A6)+,D1
		BEQ.S text_done
		SUB.B #32,D1
		LSL #5,D1
		ADDA D1,A0
		MOVE D0,D3
Print_let	LSR #1,D3
		AND #$FFF8,D3
		LEA 0(A2,D3),A1
		MOVEQ #15,D3
linep_lp	MOVEQ #0,D1
		MOVE (A0)+,D1
		ROR.L D2,D1
		OR D1,(A1)+
		OR D1,(A1)+
		OR D1,(A1)+
		SWAP D1
		OR.L D1,(A1)+
		OR D1,(A1)+
		OR D1,(A1)+
		OR D1,(A1)
		LEA 146(A1),A1
		DBRA D3,linep_lp
		ADD #16,D0
		BRA.S text_lp
text_done	RTS

log_base	DS.L 1
text		DC.W 10,100
		DC.B "GOOD ISN'T IT!",0
		EVEN
font_buf	INCBIN "A:\FONTS\STANDARD.FN1"
