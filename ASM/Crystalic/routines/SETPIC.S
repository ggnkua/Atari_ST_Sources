SETPIC:
	MOVE.L	#PIC+34,A0
	MOVE.L	#$78000,A1
	MOVE.W	#8000,D0
SETPICLOOP:
	MOVE.L	(A0)+,(A1)+
	DBF.W	D0,SETPICLOOP	
	RTS
*******************************
