; A proper ST emulator

st_emu		CLR -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		PFLUSHA
		PMOVE.L my_tc,TC
		PMOVE.L my_tt0,TT0
		PMOVE.L my_tt1,TT1
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1 
oldsp		DC.L 0
		;DC.L FEDCBA9876543210FEDCBA9876543210

my_tc		DC.L $80F04445
my_tt0		DC.L $017e8107  ; $01000000..$80000000 ??
my_tt1		DC.L $807e8507  ; $80000000..$ffffffff cache inhibit!
