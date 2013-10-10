;1200*4
points=1200

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
	bsr	PREC_DIVISION
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
	MOVE.L	#$33050041,$FFFF9800		
	BSR	EFFA2	
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

	
********************SOUS ROUTINES*****************************************************
NEW_VBL
	addq	#1,$466.w
	rte
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
	LEA	DIV_TABL,A2
	MOVE.L	SAVE1,A3
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.L	WORKECR,A0	
	LEA	COORD,A1
	MOVE.W	#points,D4
	MOVE.L	#$3111,D0		;cache on
	MOVEC.L	D0,CACR
	MOVEQ	#9,D0		;pour decalages/512
PROJ
;Q
	move	#512/4,d3
	move	(a1),d1
	sub	d1,d3		;128-ZE=Q*128
	lsr	#3,d3		;Q*16
	move.w	(a2,d3.w*2),d3
;X
	move	2(a1),d1
	muls	d3,d1		;(XE/Q)*512
	lsr.l	d0,d1		
	add	#192,d1		;X EN D1
;Y	
	move	4(a1),d2		;(YE-Q)*512
	muls	d3,d2
	lsr.l	d0,d2
	add	#135,d2		;Y EN D2
****AFFICHE DOTS
PLAN1
	MOVE.W	(A5,D2.W*2),D7 		; coord y
	MOVE.L	(A4,D1.W*4),D6		; coord x
	ADD.W	D6,D7
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
	MOVE.W	#points/15,D7
	MOVEQ.W	#0,D2
	MOVEQ.W	#0,D5
	MOVEQ.W	#0,D6
	MOVE.L	SAVE1,A1
	MOVE.L	A1,A4
	LEA	points*2+2(A4),A4
	ADD.L	#384*100+(16*8),A3
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	15
	MOVE.W	(A1)+,D5
	MOVE.W	D2,(A0,D5.L)
	MOVE.W	(A4)+,D6
	MOVE.W	D2,(A3,D6.L)
	ENDR
	DBF	D7,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
PREC_DIVISION
;precalcul d'une table de division:512/1...512/n 
	lea	DIV_TABL,a0
	move	#512*16,d0
	move	#5000,d1
	moveq	#1,d2
BOUCLE_DIV
	move.l	#512*16,d0
	divu	d2,d0		;512/n
	move.w	d0,(a0)+
	addq	#1,d2
	dbf	d1,BOUCLE_DIV
	rts
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
*colors		dc.l	$60200060,$80400080,$A06000A0,$C06000C0
colors		dc.l	$005F007F,$007F009F,$009F00BF,$00DF00FF
************
COORD		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COORD.INL"
**************************
Y_TABLE
OXO	SET	0
	REPT	140
	DC.W	OXO
OXO	SET	OXO+384
	ENDR
	DCB.L	500*0
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+16
	ENDR
	SECTION	BSS
DIV_TABL		DS.L	500
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
								 																																																	  																									  																																								  																									  																																								  																									  																									
 																																		  																																																																																																																								