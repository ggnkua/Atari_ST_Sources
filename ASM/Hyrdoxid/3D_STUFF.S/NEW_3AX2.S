;max=590 pts avec rotation sur les 3 axes
points=512

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
	move.b	#$40,$ffffa09
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	CLR_REGISTERS
	bsr	PREC_DIVISION
	MOVE.W	#0,$FFFF8240
	MOVE.L	#$AAAA00AA,$FFFF9804
	MOVE.L	#$FFFF00FF,$FFFF9808
	MOVE.L	#$FFFF00FF,$FFFF980C
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2	

LOOP
	CLR.L	$FFFF9800
	BSR	EFFA2	
	MOVE.L	SAVE1,A1
	BSR	MAKE_DOTS
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVE.L	SAVE1,A1		;swap zones de sauvegarde
	MOVE.L	SAVE2,A2
	MOVE.L	A1,SAVE2
	MOVE.L	A2,SAVE1
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
MAKE_DOTS
*	ADD.W	#2,X_ANGLE
*	CMPI.W	#720,X_ANGLE
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE
*NO_STOP
*	ADD.W	#4,Y_ANGLE
*	CMPI.W	#720,Y_ANGLE
*	BLT.S	NO_STOP2
*	CLR.W	Y_ANGLE
*NO_STOP2
*	ADD.W	#2,Z_ANGLE
*	CMPI.W	#720,Z_ANGLE
*	BLT.S	NO_STOP3
*	CLR.W	Z_ANGLE
*NO_STOP3
	LEA	VAR_3D,A6
	LEA	Y_TABLE,A5
	LEA	DIV_TABL,A4
	MOVE.L	WORKECR,A0
	BSR	TRIGO
	MOVE.W	#points-1,D7
	LEA	COORD,A2
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
AFF_BALL
**COORD SPAT TO PLAN******
	MOVE.W	(A2)+,D0
	MOVE.W	(A2)+,D1
	MOVE.W	(A2)+,D2
	MOVE	#0,D5		;ZDEP
	MOVEQ	#9,D6
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D5,A3
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5
	MULS	(A6),D3		;d3=c*xe*512
	MULS	2(A6),D4		;d4=f*ye*512
	MULS	4(A6),D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	ASR.L	#8,D5
*	MOVE.W	D5,NEW_ZE

	MOVE.W	#512/4,D6
	SUB.W	D5,D6		;d7=512*q				;d7=512*(1-new_ze/z_pt_fuite)
	LSR	#3,D6
	MOVE.W	(A4,D6.W*2),D6

	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	6(A6),D3		;d3=a*xe*512
	MULS	8(A6),D4		;d4=d*ye*512
	MULS	10(A6),D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	MOVEQ	#9,D4
	LSR.L	D4,D5
	MULS	D6,D5
*	DIVS	D6,D5		;d5=new_xe/q

	MULS	12(A6),D0		;d0=b*xe*512
	MULS	14(A6),D1		;d1=e*ye*512
	MULS	16(A6),D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	LSR.L	D4,D2
	MULS	D6,D2
*	DIVS	D6,D2		;d2=new_ye/q
*************
	LSR.L	D4,D2
	LSR.L	D4,D5
	ANDI.L	#$FFFF,D5
	ADD	#140,D2
	ADD	#192,D5
	ADD	D5,D5
	ADD.L	(A5,D2.W*4),D5 		; coord y
	MOVE	#-1,(A0,D5.L)	
	MOVE.L	D5,(A1)+
	DBF	D7,AFF_BALL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
***************************INITIALISATIONS*********************************************************
INITS
	MOVEC	CACR,D0			
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
	move	#611,$FFFF82AA.w	;BAS

 	move.l 	$44e.w,d0
	MOVE.L	d0,A1
	add.l	#215040,d0
	MOVE.L	D0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS
*******************************SOUS ROUTINES*****************************************
NEW_VBL
	addq	#1,$466.w
	rte
EFFA2
	MOVE.L	WORKECR,A0		
	MOVE.W	#points/30,D1
	MOVEQ.W	#0,D2
	MOVEM.L	CLR,D3-D7
	MOVE.L	SAVE1,A1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	30
	MOVE.L	(A1)+,D3
	MOVE.W	D4,(A0,D3.L)
	ENDR
	DBF	D1,EFF2
	MOVE.L	#$2510,D0		;coupe cache
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
	move.l 	workecr,a1
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
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			       *
*en entree:x_angle,y_angle,z_angle(angle de rotation)  *	
*en sortie:A,B,C,D,E,F,G,H,I*512		       *				
********************************************************


TRIGO
	MOVEM.L	D0-D7/A4-A6,-(SP)
	LEA	COS_TAB,A4
	LEA	SIN_TAB,A5
	LEA	X_ANGLE,A6
	MOVE.W	(A6)+,D2	;d2=x angle
	MOVE.W	(A6)+,D1	;d1=y ...
	MOVE.W	(A6)+,D0	;d0=z ...

	MOVE.W	(A5,D2.W),D5	;d5=sinx
	MOVE.W	(A4,D2.W),D4	;d4=cosx
	MOVE.W	(A5,D1.W),D3	;d3=siny
	MOVE.W	(A4,D1.W),D2	;d2=cosy
	MOVE.W	(A5,D0.W),D1	;d1=sinz
	MOVE.W	(A4,D0.W),D0	;d0=cosz

	LEA	VAR_3D,A6	;zone sauvegarde calc intermediaire
	MOVEQ.W	#9,D7		;nombre de decalages pour/512

	;**********CALCUL DE C************
SP_C
	MOVE.W	D3,D6		;siny
	NEG.W	D6		;-siny	
	MOVE.W	D6,(A6)+
	;**********CALCUL DE F************
SP_F	
	MOVE.W	D2,D6		;cosy
	MULS	D5,D6		;cosy*sinx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+
	;**********CALCUL DE I************
SP_I
	MOVE.W	D2,D6		;cosy
	MULS	D4,D6		;cosy*cosx
	ASR.L	D7,D6		;/512
	MOVE.W	D6,(A6)+		
	;**********CALCUL DE A************
SP_A
	MOVE.W	D0,D6		;cosz
	MULS	D2,D6		;cosz*cosy
	ASR.L	D7,D6		
	MOVE.W	D6,(A6)+
	;**********CALCUL DE D************
SP_D
	MOVE.W	D1,D6		;sinz	
	MULS	D4,D6		;sinz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6		
	MULS	D5,D6		;cosz*siny*sinx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(cosz*siny*sinx)-(sinz*cosx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE G************
SP_G
	MOVE.W	D7,D6		;sinz
	MULS	D5,D6		;sinz*sinx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D0,D6		;cosz
	MULS	D3,D6		;cosz*siny
	ASR.L	D7,D6
	MULS	D4,D6		;cosz*siny*cosx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(cosz*siny*cosx)+(sinz*sinx)
	MOVE.W	D6,(A6)+
	;**********CALCUL DE B************
SP_B
	MOVE.W	D1,D6		;sinz		
	MULS	D2,D6		;sinz*cosy
	ASR.L	D7,D6
	MOVE.W	D6,(A6)+
	;**********CALCUL DE E************
SP_E
	MOVE.W	D0,D6		;cosz
	MULS	D4,D6		;cosz*cosx
	ASR.L	D7,D6
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny
	ASR.L	D7,D6
	MULS	D5,D6		;sinz*siny*sinx
	ASR.L	D7,D6
	ADD.W	A4,D6		;(sinz*siny*sinx)+(cosz*cosx)
	MOVE.W	D6,(A6)+	
	;**********CALCUL DE H*************
SP_H
	MOVE.W	D0,D6		;cosz
	MULS	D5,D6		;cosz*sinx
	ASR.L	D7,D6	
	MOVE.W	D6,A4

	MOVE.W	D1,D6		;sinz
	MULS	D3,D6		;sinz*siny		
	ASR.L	D7,D6
	MULS	D4,D6		;sinz*siny*cosx
	ASR.L	D7,D6
	SUB.W	A4,D6		;(sinz*siny*cosx)-(cosz*sinx)
	MOVE.W	D6,(A6)+
	MOVEM.L	(SP)+,D0-D7/A4-A6
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

SORTIE
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	move.b	OLD_A09,$ffffa09
	move.l	OLD_VBL,$70.w
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

	SECTION DATA
OLD_VBL		DC.L	0
OLD_A09		DC.B	0
XADD		DC.W	192
SAVE1		DC.L	0
SAVE2		DC.L	0
CURVE_COMPT	DC.W	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
COORD		INCBIN	"F:CUBE.INL"
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
**************************
**************************
Y_TABLE
OXO	SET	0
	REPT	280
	DC.L	OXO
OXO	SET	OXO+768
	ENDR
*****************
OLD_CACR		DC.L	0
SCREEN_ADD		DC.L	0
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
ZDEP		DC.W	-20
COMPT		DC.W	0
X_ANGLE		DC.W	2
Y_ANGLE		DC.W	2
Z_ANGLE		DC.W	2
	SECTION	BSS
DIV_TABL		DS.L	5000
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1
VAR_3D		DS.W	9
SAVE_POINT		DS.W	8000
SAVE_POINT2	DS.W	8000
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.B	600000
	END
 																																		  																																																																																																																									 	  																																		  																																																				
									