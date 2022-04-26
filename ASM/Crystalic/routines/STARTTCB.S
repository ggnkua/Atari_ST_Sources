STARTTRACK:
	LEA	MODULE,A0	
	MOVEQ	#-1,D0		
	JSR	REPLAY_ROT+$24	
	
	JSR	INIT	
	RTS
ENDTRACK:
	JSR	RETINIT
	RTS
*******************************
