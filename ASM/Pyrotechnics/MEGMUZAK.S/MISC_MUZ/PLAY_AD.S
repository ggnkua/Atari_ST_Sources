* Musix by ADRIAN DALEKI
* Crap program by Pyrotechnics

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	move.b	#$3,MUS+2	;change tune here! 
	MOVE.L	#PLAY,$4d6
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D6.W
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	BSR.S MUS
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\MISC_MUZ\clown.ad