SETPAL:
	MOVE.L	#PIC+2,A0
	MOVE.L	#$FF8240,A1
	REPT	8
	MOVE.L	(A0)+,(A1)+
	ENDR
	RTS
*******************************
