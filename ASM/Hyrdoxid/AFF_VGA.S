	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	VBL
	BSR	INITS
	BSR	AFF_IMG
	BSR	MAKE_PAL
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP
	BRA	FIN
***************************INITIALISATIONS*********************************************************
INITS
*	MOVEC.L	CACR,D0			
*	MOVE.L	D0,OLD_CACR
*	MOVE.L	#$2510,D0		;coupe cache
*	MOVEC.L	D0,CACR

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
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

	move	#50,$FFFF82A8.w		;OVER HAUT
	move	#611,$FFFF82AA.w		;BAS

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	#74240*2,d0
	MOVE.L	d0,A2
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

AFF_IMG	
	MOVE.L	AFFECR,A1
	LEA	IMAGE+1664,A0
	MOVE.W	#(384*240)/4-1,D0	
*	ADD.L	#384*70,A1
AFF
	MOVE.L	(A0)+,(A1)+
	DBF	D0,AFF
	RTS

MAKE_PAL
	LEA	$FFFF9800,A1
	MOVE	#255,D0
CACA
	MOVE.L	#0,(A1)+
	DBF	D0,CACA


	LEA	IMAGE+16+112,A0
	LEA	$FFFF9800,A1
	MOVEQ	#0,D6
;
	MOVE.W	(A0)+,D1
	LSR.W	#2,D1
	MOVE.B	D1,D6
	LSL.W	#8,D6
	MOVE.W	(A0)+,D1
	LSR.W	#2,D1
	OR.B	D1,D6
	SWAP	D6	
	MOVE.W	(A0),D1
	LSR.W	#2,D1
	OR.B	D1,D6
	MOVE.L	D6,(A1)
;
	LEA	IMAGE+16+112+12,A0
	LEA	$FFFF9804,A1
	MOVE	#31,D0
PAL
	MOVEQ	#0,D6
	MOVEQ	#0,D1	
	MOVE.W	(A0)+,D1
	LSR.W	#2,D1
	MOVE.B	D1,D6
	LSL.W	#8,D6
	MOVE.W	(A0)+,D1
	LSR.W	#2,D1
	OR.B	D1,D6
	SWAP	D6
	MOVE.W	(A0)+,D1
	LSR.W	#2,D1
	OR.B	D1,D6
	MOVE.L	D6,(A1)+
	DBF	D0,PAL
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
IMAGE		INCBIN	"F:NYTRIK.PNT"
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
SCREEN_ADD		DC.L	0
		SECTION BSS
		DS.L	2000
PILE		DS.L 	10	
SCREEN		DS.L	50000
	END
 																																		  																																																																																																																											