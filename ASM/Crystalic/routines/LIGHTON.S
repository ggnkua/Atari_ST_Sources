LIGHTON:
	MOVE.W	#$FD,-(SP)
	MOVE.W	#29,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	RTS
*******************************
                                            	                         	