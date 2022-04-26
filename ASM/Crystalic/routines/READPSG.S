READPSG:
	MOVE.B	#10,$FF8800
	MOVE.B	$FF8800,D0
	CMP.B	#14,D0
	BEQ	COLOR
	MOVE.W	#$000,$FF8240
	RTS
COLOR:
	MOVE.W	#$700,$FF8240
	RTS
*******************************
                                            	                         	