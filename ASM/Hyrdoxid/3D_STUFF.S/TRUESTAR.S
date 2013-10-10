*********************************
*        STARFIELD ROUTINE      *
*              by               *
*      Cristalion/Hydroxid      *
*         the 28/04/94          *
*********************************
;max=900*2*4=1800*4=7200
points=1150

	SECTION	TEXT

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	move.b	$ffffa09,OLD_A09
	move.b	#$40,$fffa09
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2	
*******
LOOP
	CLR.L	$FFFF9800
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$FF000000,$FFFF9800
NO_ALT2
	BSR	EFFA2	
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FF0000,$FFFF9800
NO_ALT3
	BSR	AFF_DOTS
*	BSR	SYM_X 
	MOVEM.L	A0-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	BSR	SHADE
	MOVEM.L	(SP)+,A0-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
*******

	BRA	SORTIE
***************************INITIALISATIONS*********************************************************
INITS
	MOVEC.L	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

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
 	MOVE.W	#%0000000001100100,-(SP)	
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
	add.l	#74240*4,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

	
********************SOUS ROUTINES*****************************************************
NEW_VBL
	addq	#1,$466.w
	rte
SHADE
	MOVE.L	SAVE1,A0		;swap zones de sauvegarde
	MOVE.L	SAVE2,A1
	EXG	A0,A1
	MOVE.L	A0,SAVE1
	MOVE.L	A1,SAVE2
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts

AFF_DOTS
	MOVE.L	SAVE1,A3
	LEA	Y_TABLE,A5
	MOVE.L	WORKECR,A0	
	LEA	COORD,A1
	MOVE.W	#points,D4
	MOVEQ	#9,D0		;pour decalages/512
	MOVEQ	#-1,D6
	MOVE.L	#$3111,D7		;cache on
	MOVEC.L	D7,CACR
PROJ
	MOVE.W	#512,D3
	MOVE.W	(A1),D1
	SUB.W	D1,D3	;512-4*ZE=Q*512
	MOVE.L	2(A1),D1
	DIVS	D3,D1	;XE*512/Q*512=X
	ADD.W	#192,D1	;X EN D1
	MOVE.L	6(A1),D2
	DIVS	D3,D2
	ADD.W	#135,D2	;Y EN D2
****AFFICHE DOTS
PLAN1
	MOVE.L	(A5,D2.W*4),D2 		; coord y
	ASL	D1
	ADD.W	D1,D2
	MOVE.W	D6,(A0,D2.L)	
	MOVE.L	D2,(A3)+
	ADD.W	#6*4,(A1)			;test pour scroll 
	BMI.S	NO_400			;des pts
	MOVE.W	#-500*4,(A1)
NO_400
	LEA	10(A1),A1
	DBF	D4,PROJ
	MOVE.L	#$2510,D0		;cache on
	MOVEC.L	D0,CACR
	RTS		
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVEQ.L	#0,D1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
	MOVE.W	#65535,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,OK
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
EFFA2
	MOVE.L	WORKECR,A0		
	MOVE.L	A0,A3
	MOVE.W	#points/40,D7
	MOVEQ.W	#0,D2
	MOVEQ.W	#0,D5
	MOVEQ.W	#0,D6
	MOVE.L	SAVE1,A1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	40
	MOVE.L	(A1)+,D5
	MOVE.W	D6,(A0,D5.L)
	ENDR
	DBF	D7,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
**************************************************************************************
SORTIE	
	MOVE.B	OLD_A09,$FFFFA09
	MOVE.L	OLD_VBL,$70.W
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	SECTION	DATA
OLD_VBL		DC.L	0
OLD_A09		DC.B	0
SAVE1		DC.L	0
SAVE2		DC.L	0
SAVE3		DC.L	0
SAVE4		DC.L	0
SAVE5		DC.L	0
SAVE6		DC.L	0
SAVE7		DC.L	0
SAVE8		DC.L	0
OLD_CACR		DC.L	0
SCREEN_ADD		DC.L	0
ZE		DC.W	0
XE		DC.W	0
YE		DC.W	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
************
COORD		INCBIN	"F:STAR.INL"
**************************
Y_TABLE
OXO	SET	0
	REPT	250
	DC.L	OXO
OXO	SET	OXO+768
	ENDR
	SECTION	BSS
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.B	600000
SAVE_POINT		DS.W	4000
SAVE_POINT2	DS.W	4000
SAVE_POINT3	DS.W	4000
SAVE_POINT4	DS.W	4000
SAVE_POINT5	DS.W	4000
SAVE_POINT6	DS.W	4000
SAVE_POINT7	DS.W	4000
SAVE_POINT8	DS.W	4000
FORME		DS.L	2000
SAVEY		DS.W	2000
	END
								 																																																	  																									  																																								  																									  																																								  																									  																									
 																																		  																																																																																																																								