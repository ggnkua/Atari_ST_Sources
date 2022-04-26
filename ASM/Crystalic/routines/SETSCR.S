SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.L	#$78000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*******************************
