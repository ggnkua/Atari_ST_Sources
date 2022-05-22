clickoff	PEA text(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		PEA dclick(PC)
		MOVE.W #$26,-(SP)
		TRAP #14
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1

dclick		BCLR.B #0,$484.W
		RTS

text		DC.B "Key Click OFF!",0
		EVEN

