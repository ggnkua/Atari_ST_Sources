Gemstart	MOVE.L SP,A5		save sp
		LEA my_stack(PC),SP	local stack
		MOVE.L 4(A5),A5		base page addr
		MOVE.L $C(A5),D0		prog length
		ADD.L $14(A5),D0		BSS length
		ADD.L $1C(A5),D0		DATA length
		ADD.L #$100,D0		skip base page
		MOVE.L D0,-(SP)		stack length
		MOVE.L A5,-(SP)		prog start
		CLR -(SP)			dummy word
		MOVE #$4A,-(SP)		memory shrink
		TRAP #1			gemdos
		LEA 12(SP),SP		correct stack
