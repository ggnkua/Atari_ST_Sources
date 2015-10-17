
*	opt	o+,d+,w+

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
*******
	BSR	INIT_PAL
	BSR	AFF_GFX
NO_QUIT	
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	NO_QUIT
	BRA	FIN
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
*	MOVEC	CACR,D0			
*	MOVE.L	D0,OLD_CACR
*	MOVE.L	#$3111,D0		; cache on ... 
*	MOVEC	D0,CACR			

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	 #96000,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
AFF_GFX	
	MOVE.L	AFFECR,A0	
	MOVE.L	WORKECR,A2
	LEA	IMAGE,A1
	LEA	1664(A1),A1	
	MOVE.W	#23039,D1
AFF	
	MOVE.L	(A1),(A0)+
	MOVE.L	(A1)+,(A2)+
	DBF	D1,AFF
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
CLS
	MOVEM.L	D0-D1/A0,-(SP)
	MOVEQ.L	#0,D1
	MOVE.L	AFFECR,A0
	MOVE.W	#23039,D0
OK
	MOVE.L	D1,(A0)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0-D1/A0
	RTS
*********************
INIT_PAL
	LEA	$FFFF9800,A0
	LEA	PAL,A1
	MOVE.W	#255,D0
MAKE_PAL
	MOVE.L	(A1)+,(A0)+
	DBF	D0,MAKE_PAL
	RTS
**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

FIN	
*	MOVE.L	OLD_CACR,D0
*	MOVEC	D0,CACR
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#8,$FFFFC02
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

***********************************************************************
***********************************************************************
		SECTION DATA
IMAGE		INCBIN	"F:OVER.PNT"
PAL		INCBIN	"F:OVER.PAL"
OLD_CACR	DC.L	0
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
SCREEN_ADD	DC.L	0
		SECTION BSS
CLR		DS.L	16
		DS.L	2000
PILE		DS.L	100
SCREEN		DS.W	150000
	END
 																								  																								 																								  																								