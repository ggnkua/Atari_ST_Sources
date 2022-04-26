FINDPHYSIC:
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PHYSBASE
	RTS
*******************************
