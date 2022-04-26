INIT:
	MOVE.L	$70,OLDVBL
	MOVE.L	#NEWVBL,$70
	RTS
RETINIT:
	MOVE.L	OLDVBL,$70
	RTS
*******************************
