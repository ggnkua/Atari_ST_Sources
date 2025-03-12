;************************************
;      SOUND CHIP MUZAX PLAYER 
;          by Ralph Rudzki
;        for own muzax files.
;************************************

	PEA	0
	MOVE.W	#$20,-(A7)
	TRAP	#1
	LEA	6(A7),A7
	PEA	TEX
	MOVE.W	#9,-(A7)
	TRAP	#1
	LEA	6(A7),A7
	MOVE.L	$70.W,OLDVBL+2
	MOVE.L	$70.W,MC+$2A
	MOVE.L	#MC,$70.W
	MOVE.W	#7,-(A7)
	TRAP	#1
	LEA	2(A7),A7
OLDVBL:	MOVE.L	#0,$70.W
	MOVE.L	#$08000000,$FFFF8800.W
	MOVE.L	#$09000000,$FFFF8800.W
	MOVE.L	#$0A000000,$FFFF8800.W
	CLR.W	-(A7)
	TRAP	#1

MC:	INCBIN	A:\NORMAL.MUX\RALPH_N4.MUX
TEX:	DC.B	27,'HPlaying a tune...',0
