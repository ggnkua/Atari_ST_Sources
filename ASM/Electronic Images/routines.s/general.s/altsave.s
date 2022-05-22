* Alt Help Saver		

		PEA init(PC)
		MOVE #$26,-(SP)
		TRAP #14
		ADDQ.L #6,SP	
		LEA Save(PC),A0
		LEA $98000,A1
		MOVE #1000,D0
rel		MOVE.L (A0)+,(A1)+
		DBF D0,rel

		CLR -(SP)
		TRAP #1

init		MOVE.L #$98000,$502.W
		RTS

Save		MOVEM.L D0-D7/A0-A6,-(SP)
		clr -(SP)
		PEA filename(PC)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D7
write		MOVE.L #$a000,-(SP)
		MOVE.L #350000,-(SP)
		MOVE D7,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		LEA 12(SP),SP
close		MOVE D7,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS

filename	DC.B "DATA.DAT",0
		EVEN
