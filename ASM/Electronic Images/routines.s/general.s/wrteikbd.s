writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S writeikbd
		MOVE.B D0,$FFFFFC02.W
		RTS
