* Boot runner + alt saver in one.

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA $7500,SP
		LEA $2000,A0
		LEA Save(PC),A1
		MOVE #50,D0
rel		MOVE.w (A1)+,(A0)+
		DBF D0,rel	
init		MOVE.L #$2000,$502.W
		MOVE #$2700,SR
		LEA $FFFF8606,A6
		MOVE.L #$16DA,$4C6
		sub.l a5,a5
		jmp $fffc02c6

Save		MOVEM.L D0-D7/A0-A6,-(SP)
		
		clr.b $43e.w
Save_file	clr -(SP)
		PEA filename(PC)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		tst d0
		bmi.s Save_file
		MOVE D0,D7
write		MOVE.L #$A000,-(SP)
		MOVE.L #320000,-(SP)
		MOVE D7,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		LEA 12(SP),SP
close		MOVE D7,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		move.b #1,$43e.w
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS

filename	DC.B "DATA.DAT",0
		EVEN
cd
