* Musix by Rob Hubbard
* Crap program by Pyrotechnics

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	BSR	MUS
	MOVE.L	#PLAY,$4d6
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D6.W
	MOVE.L #$8080000,$ffff8800.W
	MOVE.L #$9090000,$ffff8800.W
	MOVE.L #$A0A0000,$ffff8800.W
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	BSR.S MUS+$64
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\misc_muz\thun.rh