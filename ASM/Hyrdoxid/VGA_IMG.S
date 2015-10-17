
*	opt	o+,d+,w+

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
*	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
*******
	BSR	INIT_PAL
	BSR	AFF_GFX
NO_QUIT	
	CMPI.B	#57,$FFFFC02
	BNE	NO_QUIT
	BRA	FIN
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
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
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN,-(SP)
	MOVE.L	SCREEN,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l $44e.w,d0
	MOVE.L	D0,AFFECR
	RTS

***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
AFF_GFX	
	MOVE.L	AFFECR,A0	
	LEA	IMAGE,A1
	LEA	1024(A1),A1	
	MOVE.W	#15999,D1
AFF	
	MOVE.L	(A1)+,(A0)+
	DBF	D1,AFF
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
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
*********************
INIT_PAL
	LEA	$FFFF9800,A0
	LEA	IMAGE,A1
	MOVE.W	#255,D0
MAKE_PAL
	MOVE.L	(A1)+,(A0)+
	DBF	D0,MAKE_PAL
	RTS
0**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

FIN	
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#8,$FFFFC02
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

***********************************************************************
***********************************************************************
		SECTION DATA
IMAGE		INCBIN	"F:BIGLOGO.HDX"
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
AFFECR		DC.L	0
screen		dc.l	2048000
		SECTION BSS
CLR		DS.L	16
	END
  																								