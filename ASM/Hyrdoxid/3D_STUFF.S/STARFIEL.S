*********************************
*        STARFIELD ROUTINE      *
*              by               *
*      Cristalion/Hydroxid      *
*         the 28/04/94          *
*********************************
;max=900*2*4=1800*4
points=600

	SECTION	TEXT

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2	
	MOVE.L	#SAVE_POINT3,SAVE3
	MOVE.L	#SAVE_POINT4,SAVE4
	MOVE.L	#SAVE_POINT5,SAVE5
	MOVE.L	#SAVE_POINT6,SAVE6
	MOVE.L	#SAVE_POINT7,SAVE7
	MOVE.L	#SAVE_POINT8,SAVE8
	lea.l colors,a0
	lea.l $FFFF9800,a1
	move.l (a0),4(a1)
	move.l (a0),8(a1)
	move.l (a0),16(a1)
	move.l (a0)+,32(a1)
	move.l (a0),12(a1)
	move.l (a0),20(a1)
	move.l (a0),24(a1)
	move.l (a0),36(a1)
	move.l (a0),40(a1)
	move.l (a0),44(a1)
	move.l (a0)+,48(a1)
	move.l (a0),28(a1)
	move.l (a0),52(a1)
	move.l (a0)+,56(a1)
	move.l (a0),60(a1)


*******
LOOP
	CLR.L	$FFFF9800		
	BSR	EFFA2	
	BSR	AFF_DOTS
	BSR	SYM_X 
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
 	MOVE.W	#%0000000001100010,-(SP)	
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

	
********************SOUS ROUTINES*****************************************************
SHADE
	MOVE.L	SAVE1,A0		;swap zones de sauvegarde
	MOVE.L	SAVE2,A1
	MOVE.L	SAVE3,A2
	MOVE.L	SAVE4,A3
	MOVE.L	SAVE5,A4
	MOVE.L	SAVE6,A5
	MOVE.L	SAVE7,A6
	MOVE.L	SAVE8,D1
	EXG	A0,A1
	EXG	A1,A2
	EXG	A2,A3
	EXG	A3,A4
	EXG	A4,A5
	EXG	A5,A6
	EXG	A6,D1
	MOVE.L	A0,SAVE1
	MOVE.L	A1,SAVE2
	MOVE.L	A2,SAVE3
	MOVE.L	A3,SAVE4
	MOVE.L	A4,SAVE5
	MOVE.L	A5,SAVE6
	MOVE.L	A6,SAVE7
	MOVE.L	D1,SAVE8
	addq.l 	#2,affecr
	move.w 	affecr+2,d0
	andi.w 	#8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s 	trainee			; on boucle
 	sub.w 	#8,affecr+2
trainee
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts

AFF_DOTS
	LEA	FORME,A2
	MOVE.L	SAVE1,A3
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.L	WORKECR,A0	
	LEA	COORD,A1
	LEA	SAVEY,A6
	MOVE.W	#points,D4
	MOVE.L	#$3111,D0		;cache on
	MOVEC.L	D0,CACR
PROJ
	MOVE.W	#512,D3
	MOVEQ	#9,D0	;pour decalages/512
	MOVE.W	(A1),D1
	ASL.W	#2,D1	;4*ZE
	SUB.W	D1,D3	;512-4*ZE=Q*512
	MOVE.W	2(A1),D1
	EXT.L	D1
	ASL.L	D0,D1	;XE*512
	DIVS	D3,D1	;XE*512/Q*512=X
	ADD.W	#192,D1	;X EN D1
	MOVE.W	4(A1),D2
	EXT.L	D2
	ASL.L	D0,D2	
	DIVS	D3,D2
	ADD.W	#135,D2	;Y EN D2
****AFFICHE DOTS
PLAN1
	MOVE.W	(A5,D2.W*2),D7 		; coord y
	MOVE.L	(A4,D1.W*4),D6		; coord x
	MOVE.W	D7,(A6)+
	ADD.W	D6,D7
	MOVE.L	D6,(A2)+
	SWAP	D6
	OR.W	D6,(A0,D7.L)	
	MOVE.W	D7,(A3)+
	ADDQ.W	#6,(A1)			;test pour scroll 
	BMI.S	NO_400			;des pts
	MOVE.W	#-500,(A1)
NO_400
	ADDQ	#6,A1
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
	MOVE.W	#18269,D0
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
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
	MOVE.W	#points,D7
	MOVEQ.W	#0,D2
	MOVEQ.W	#0,D5
	MOVEQ.W	#0,D6
	MOVE.L	SAVE1,A1
	MOVE.L	A1,A4
	LEA	points*2+2(A4),A4
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
	LEA	-70*192-64(A3),A3
EFF2
	MOVE.W	(A1)+,D5
	MOVE.W	D2,(A0,D5.L)
	MOVE.W	(A4)+,D6
	MOVE.W	D2,(A3,D6.L)
	DBF	D7,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
SYM_X
	MOVE.L	#$3111,D0
	MOVEC.L	D0,CACR
;
	MOVEQ	#0,D2
	MOVEQ	#0,D4
	LEA	SAVEY,A6
	LEA	FORME,A2		
	MOVE.L	WORKECR,A3
	MOVE.L	SAVE1,A1
	MOVE.L	A1,A4
	LEA	points*2+2(A4),A4
	
	MOVE.W	#points,D3
	LEA	-70*192-64(A3),A3
SYM
	MOVE.L	(A2)+,D1
	MOVE.W	(A6)+,D2
	MOVE.W	D1,D4
	SUB.W	D2,D4
	SWAP	D1
	OR.W	D1,(A3,D4.L)
	MOVE.W	D4,(A4)+
	DBF	D3,SYM
	MOVE.L	#$2510,D0
	MOVEC.L	D0,CACR
	RTS
**************************************************************************************
SORTIE	
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
*colors		dc.l	$60200060,$80400080,$A06000A0,$C06000C0
colors		dc.l	$00400060,$00600080,$008000A0,$00C000E0
************
COORD		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COORD.INL"
**************************
Y_TABLE
OXO	SET	0
	REPT	280
	DC.W	OXO
OXO	SET	OXO+192
	ENDR
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+8
	ENDR
	SECTION	BSS
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.W	200000
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
								 																																																	  																									  																																								  																									  																																								  																									  																									  																																		  																																																																																																																								