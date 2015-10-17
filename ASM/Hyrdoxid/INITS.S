	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.B	#18,$FFFFC02
	CLR.W	$484
	BSR	VBL
	BSR	INITS
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP

	BRA	FIN
***************************INITIALISATIONS*********************************************************
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

	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

	MOVE	#50,$FFFF82A8.w		;OVER HAUT
	MOVE	#611,$FFFF82AA.w		;BAS

 	MOVE.L 	$44E.W,D0
	MOVE.L	D0,A1
	ADD.L	#74240,D0
	MOVE.L	D0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
*******************c'est FI-NI********************************************************************

FIN	
	CLR.L	$4D2
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

		SECTION	DATA
*IMAGE		INCBIN	"\GRAPHS\HYDROXID.PI1\1123.PI1"
OLD_CACR		DC.L	0
SCREEN_ADD		DC.L	0
AFFECR:		DC.L 	1
WORKECR:		DC.L 	1
OLDXBIOS2:		DC.L	1
OLDMODECODE	DC.W	1

		SECTION BSS
		DS.L 2000
PILE		DS.L 10
SCREEN		DS.W	200000
	END
	 	  																																		  																																																																	