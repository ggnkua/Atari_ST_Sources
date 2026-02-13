* Musix by CHRISPY NOODLE!
* Crap program by Pyrotechnics

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	MOVE.B	#2,$484.w
	MOVE.L	#PLAY,$4d2.w
	BSR	MUS
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	CLR.L	$4D2.W
	BSR	MUS
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	BSR MUS+$9c			;USE A8 FOR 121.cn& 240.CN 
	MOVEM.L	(a7)+,D0-D7/A0-A6       ;USE 9C FOR hey_m_l.cn & NZ.CN
	RTS
MUS	INCBIN a:\chrispy.n\hey_m_l.cn