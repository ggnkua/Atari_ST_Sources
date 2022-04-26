NEWVBL:
	MOVEM.L	D0-D5/A0-A1,-(SP)	
	JSR	REPLAY_ROT+$28		
	MOVEM.L	(SP)+,D0-D5/A0-A1
	RTE
*******************************
