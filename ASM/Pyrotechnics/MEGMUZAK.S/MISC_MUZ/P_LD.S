* Taken from the LAST DUEL
* Crap program by Pyrotechnics
* ONly wants to play sound effects

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	moveq	#6,d0	;change sounds here
	BSR	MUS+$32+$a6
	move.w	#$fe,MUS
	MOVE.L	#PLAY,$4d6
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D6.W
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	BSR	MUS+$a6
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\misc_muz\ld.muz