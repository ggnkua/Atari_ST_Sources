LIGHTOFF:
	MOVE.W	#$06,-(SP)
	MOVE.W	#30,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	RTS
*******************************
                                            	                         	