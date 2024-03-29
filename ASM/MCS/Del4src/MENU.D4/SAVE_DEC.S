*OBJETS DE 32*16

INIT:	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP

	LEA	IMAGE+34,A0	
	MOVE.L	#BUFFER,A1
	
	MOVEQ	#10-1,D1
COLS:	MOVE.W	#16*12-1,D0		
IN_BUF:	MOVE.L	(A0),(A1)+
	MOVE.L	4(A0),(A1)+
	MOVE.L	8(A0),(A1)+
	MOVE.L	12(A0),(A1)+
	LEA	160(A0),A0
	DBRA	D0,IN_BUF
	ADD.L	#16,A0
	SUB.L	#160*192,A0
	DBRA	D1,COLS

	JSR	DISK
	CLR	-(SP)		
	TRAP	#1
	
DISK:	CLR.L	D5
	CLR.L	D0

	CLR.L	-(SP)
	PEA 	FILE
	MOVE.W 	#$3C,-(SP)
	TRAP 	#1		
	ADD.L 	#10,SP	
	MOVE.W 	D0,D5	

	CLR.L	D6
	MOVE.L	#30720,D6

	PEA	BUFFER
	MOVE.L	D6,-(SP)
	MOVE.W	D5,-(SP)
	MOVE.W	#$40,-(SP)
	TRAP	#1
	LEA.L	12(SP),SP

	MOVE.W	D5,-(SP)		;FCLOSE
	MOVE.W	#$3E,-(SP)
	TRAP	#1
	ADDQ.L	#4,SP
	RTS

******** DATA ********
IMAGE:	INCBIN	"\BLKMEN.PI1"
BUFFER:	DCB.B	30720,0	
FILE:	DC.B	"\DECORE.BLK",0
	END
