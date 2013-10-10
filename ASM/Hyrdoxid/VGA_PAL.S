 	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	BSR	INITS
	BSR	CLS

; 		  RRVV  BB
	MOVE.L	#$00000000,$FFFF9800
;merci a AURA pour leurs renseignements totalement faux ...
;et merci a ATARI pour cette organisation merdique de la palette !!!

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp	
	BRA	FIN
CLS
	MOVEM.L	D0-D1/A0,-(SP)
	MOVEQ.L	#0,D1
	MOVE.L	AFFECR,A0
	MOVE.W	#15999,D0
OK
	MOVE.L	D1,(A0)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0-D1/A0
	RTS
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE		


;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000000100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN,-(SP)
	MOVE.L	SCREEN,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP
 	move.l $44e.w,d0
	MOVE.L	D0,AFFECR
	RTS
FIN
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1

	SECTION	DATA
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
AFFECR		DC.L	0
screen		dc.l	2048000
	END
  																								  																								  																									