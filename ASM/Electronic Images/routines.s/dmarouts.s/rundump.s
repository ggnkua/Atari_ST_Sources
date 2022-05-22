		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA $1000,SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.B $FFFF8260.W
		JMP me
data		INCBIN LOSTSTAR.DAT
dataend
		EVEN
me		MOVE #$2700,SR
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.L #fake,$70.W
		LEA data,A0
		LEA $2500,A1
		MOVE.W #((dataend-data)/4)-1,D0
.copy		MOVE.L (A0)+,(A1)+
		DBF D0,.copy
		MOVE #$2300,SR
		JMP $2500.W
fake		RTE

