*** SAMPLE PLAYER - CODED BY ZANAK ***
********* (C) 1994 ATROCITY **********

	SECTION TEXT
	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR.B	$FFFF8900.W		; IT DMA OFF
	CLR.B	$FFFF8901.W		; DMA STOP
	MOVE.L	#SAMPLE,D0
	MOVE.L	#SAMPLE_FIN,D1
	MOVE.B	D0,$FFFF8907.W
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8905.W
	SWAP	D0
	MOVE.B	D0,$FFFF8903.W
	MOVE.B	D1,$FFFF8913.W
	LSR.W	#8,D1
	MOVE.B	D1,$FFFF8911.W
	SWAP	D1
	MOVE.B	D1,$FFFF890F.W
	MOVE.B	#%10000010,$FFFF8921.W		; 25KHZ 8BITS MONO
	MOVE.B	#1,$FFFF8901.W		; DMA ON
	
FIN	CMP.B	#$39,$FFFFFC02
	BNE	FIN	

	CLR.B	$FFFF8901.W			; DMA STOP
	
	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP
	
	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
			
	SECTION DATA
	
SAMPLE	INCBIN	E:\INTRO.AVR
SAMPLE_FIN

	END
	