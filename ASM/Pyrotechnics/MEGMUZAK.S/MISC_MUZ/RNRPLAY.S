* Music from Rock n' Roll
* Crap program by Pyrotechnics
* Ripped by THE LAW 

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	MOVE.B	#2,$484.w
	lea	MUZAK,a0
	lea	$196ce,a1
	move.l	#28000,d0
M	move.b	(a0)+,(a1)+
	dbra	d0,M
	MOVE.L	#PLAY,$4d2.w
	MOVEQ	#1,D0	;Change tune here
	JSR	$1D6EC
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D2.W
	MOVEQ	#0,D0
	JSR	$1D6ec
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	JSR	$1D80C
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUZAK	INCBIN A:\MISC_MUZ\ROCKROLL.MUS