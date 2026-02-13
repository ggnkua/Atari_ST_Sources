* Musix by BENN DAGLISH
* Crap program by Pyrotechnics
* All music ripped by XERUD
	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	moveq	#0,d0	;change tune here (from 0 upwards)
	BSR	MUS
	MOVE.L	#PLAY,$4d6
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D6.W
	MOVEQ	#0,D0
	BSR	MUS
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	BSR.S MUS+4
end	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\benn_dag.lis\switch.bd