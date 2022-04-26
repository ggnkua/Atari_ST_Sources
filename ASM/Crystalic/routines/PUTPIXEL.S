PUTPIXEL:
	MOVE.L	#$78000,A1	* X-COR I D4, Y-COR I D5
	MULU	#160,D5
	ADD.W	D5,A1
	MOVE.W	D4,D5
	AND.W	#$FFF0,D5
	ASR.W	D5
	ADD.W	D5,A1
	LEA	NIBBLES,A0
	AND.W	#$000F,D4
	ASL.W	D4
	MOVE.W	(A0,D4.W),D0
	OR.W	D0,(A1)
	RTS
***************************************
NIBBLES:
	DC.W	$8000,$4000,$2000,$1000
	DC.W	$800,$400,$200,$100
	DC.W	$80,$40,$20,$10
	DC.W	$8,$4,$2,$1

***************************************
