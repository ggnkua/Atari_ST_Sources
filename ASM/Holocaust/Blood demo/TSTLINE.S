;Routine de lignes utilis‚e pour les cadres au d‚but...
;Code by Zerioul/Holocaust (‡a date de la Choice, 15 diago/vbl only!)

	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	
	JSR	LINE
	
	MOVE.L	$44E.W,A0
	MOVE	#1,D0
	MOVE	#1,D1
	MOVE	#319,D2
	MOVE	#199,D3
	jsr	LINE+78

B	BRA.S	B

LINE	INCBIN	LINE.BIN
