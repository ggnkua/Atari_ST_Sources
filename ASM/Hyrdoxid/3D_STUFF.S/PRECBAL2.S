*****************************
*      SMALL    DOTSBALL    *	
*      	    by		    *	
*     Cristalion/Hydroxid   *
*****************************

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	BSR	PRECALC_BALL
	MOVE.W	#$FFF,$FFFF8242

LOOP
	CLR.W	$FFFF8240
	BSR	EFFA
	BSR	REBOND_BALL

	MOVE.W	XADD,D1
	MOVE.W	COMPT,D2
	MOVE.W	D2,CURVE_COMPT
	BSR	AFF_DOTS
	MOVE.W	CURVE_COMPT,D2
	MOVE.W	D2,COMPT

	MOVE.W	XADD2,D1
	MOVE.W	COMPT2,D2
	MOVE.W	D2,CURVE_COMPT
	BSR	AFF_DOTS
	MOVE.W	CURVE_COMPT,D2
	MOVE.W	D2,COMPT2

	lea.l colors,a0
	lea.l $ffff8240.w,a1
	move.w (a0),2(a1)
	move.w (a0),4(a1)
	move.w (a0),8(a1)
	move.w (a0)+,16(a1)
	move.w (a0),6(a1)
	move.w (a0),10(a1)
	move.w (a0),12(a1)
	move.w (a0),18(a1)
	move.w (a0),20(a1)
	move.w (a0),22(a1)
	move.w (a0)+,24(a1)
	move.w (a0),14(a1)
	move.w (a0),26(a1)
	move.w (a0)+,28(a1)
	move.w (a0),30(a1)
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
*	addq.l #2,affecr
*	move.w affecr+2,d0
*	andi.w #8,d0			; si on a fait les 4 plans			
*	cmpi.w	#8,d0
*	bne.s trainee			; on boucle
* 	subq.w #8,affecr+2
*trainee
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.W	#5,$FFFF8240
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
PRECALC_BALL
	LEA	BUFFER,A3
MAKE_DOTS
	ADD.W	#4,X_ANGLE
	CMPI.W	#720,X_ANGLE
	BLS.S	NO_STOP
	RTS
NO_STOP
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLS.S	NO_STOP2
	CLR.W	Y_ANGLE
NO_STOP2
*	ADD.W	#4,Z_ANGLE
*	CMPI.W	#720,Z_ANGLE
*	BLT.S	NO_STOP3
*	CLR.W	Z_ANGLE
*NO_STOP3
	BSR	TRIGO
	MOVE.W	#809,D7
	LEA	COORD,A2
AFF_BALL
	MOVE.L	(A2)+,XE
	MOVE.W	(A2)+,ZE
**COORD SPAT TO PLAN******
	MOVEM.L	  D7/A2-A3/A4/A5,-(SP)		
	LEA	XE,A6
	MOVE.W	(A6)+,D0
	MOVE.W	(A6)+,D1
	MOVE.W	(A6),D2
	MOVE.W	ZDEP,D5
	MOVEQ.B	#9,D6
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D5,A3
	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5
	MULS	(A6)+,D3	;d3=c*xe*512
	MULS	(A6)+,D4	;d4=f*ye*512
	MULS	(A6)+,D5	;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	MOVE.L	D5,A5		;a5=new_ze*512
	LSR.L	#8,D5

	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze
	MULS	(A6)+,D3	;d3=a*xe*512
	MULS	(A6)+,D4	;d4=d*ye*512
	MULS	(A6)+,D5	;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	MOVE.L	D5,A4		;a4=new_xe*512
	DIVS	D7,D5		;d5=new_xe/q
	MULS	(A6)+,D0	;d0=b*xe*512
	MULS	(A6)+,D1	;d1=e*ye*512
	MULS	(A6)+,D2	;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	MOVE.L	D2,D6		;d6=new_ye*512
	DIVS	D7,D2		;d2=new_ye/q
	LEA	XP,A6		;A6 pointe sur zone de sauve 				;coord planes
	MOVE.W	D5,(A6)+	;xp
	ADD.W	#120,D2	
	MOVE.W	D2,(A6)+	;yp
	MOVEM.L	(SP)+,D7/A2-A3/A4/A5
*************
	MOVE.W	XP,(A3)+
	MOVE.W	YP,(A3)+
	DBF	D7,AFF_BALL
	BRA	MAKE_DOTS
	RTS
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		*
	MOVE.W	#88,-(SP)		*
	TRAP	#14			*
	ADDQ.L	#4,SP			*
	MOVE.W	D0,OLDMODECODE		*

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$7d00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS

*******************************SOUS ROUTINES*****************************************
AFF_DOTS
	movem.l	clr,d2-d6/a0-a6
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	LEA	BUFFER,A2
	MOVE.L	WORKECR,A0
	ADD.W	#8,CURVE_COMPT
	CMPI.W	#1432,CURVE_COMPT
	BLT.S	NO_CLR
	CLR.W	CURVE_COMPT
NO_CLR
	MOVE.W	CURVE_COMPT,D7
	MULU	#405,D7
	ADD.L	D7,A2
	MOVE.W	#809,D4
	MOVE.W	YADD,D0

NO_D
	MOVE.W	(A2)+,D3
	MOVE.W	(A2)+,D2
	SUB.W	D0,D2
	ADD.W	D2,D2
	MOVE.W	(A5,D2.W),D5 		; coord y
	ADD.W	D1,D3
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.L	(A4,D3.W),D6		; coord x
	ADD.W	D6,D5
	SWAP	D6
	OR.W	D6,(A0,D5.W)	
	DBF	D4,NO_D
	RTS
***************************CLS ROUT*****************************************
;sur F30
EFFA
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#160*16,A1
	MOVEQ	#0,D0
	MOVE.W	#178,D1
.EFF
OXO	SET	0
	REPT	20
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+8
	ENDR
	LEA	160(A1),a1
	DBF	D1,.EFF
	MOVEM.L	(SP)+,D0/A1
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
	move.l workecr,a1
	MOVE.W	#7999,D0
OK
	MOVE.L	#0,(A0)+
	move.l #0,(a1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.B	#199,D1
	MOVEQ.W	#0,D2
MAKE
	MOVE.W	D2,(A1)+
	ADD.W	#160,D2
	DBF	D1,MAKE
	RTS

REBOND_BALL
	LEA	REBOND,A2
	ADDQ.W	#2,CURVE
	CMPI.W	#720,CURVE
	BLT.S	NO
	CLR	CURVE
NO
	MOVE.W	CURVE,D1	
	MOVE.W	(A2,D1.W),YADD
	RTS
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

SORTIE
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	CLR.W	-(SP)
	TRAP	#1

	SECTION DATA
*colors 		dc.w 	$023,$034,$045,$067
colors 		dc.w 	$FFF,$774,$045,$067
XADD		DC.W	235
XADD2		DC.W	80
YADD		DC.W	0
CURVE_COMPT	DC.W	0
CURVE		DC.W	0
********
COMPT		DC.W	0
COMPT2		DC.W	320
********
AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	1
OLDMODECODE	DC.W	1
FORME		INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\V.INL"	
COORD		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\DOTSBAL4.INL"
REBOND		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\REBOND.INL"
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
**************************
**************************
Y_TABLE
OXO	SET	0
	REPT	200
	DC.W	OXO
OXO	SET	OXO+160
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
*****************
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
ZDEP		DC.W	30
X_ANGLE		DC.W	2
Y_ANGLE		DC.W	2
Z_ANGLE		DC.W	2
Z_PT_FUITE	DC.W	256
	SECTION	BSS
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1
VAR_3D		DS.W	9
CLR	DS.L	17
	DS.L	2000
PILE	DS.L	10
BUFFER	DS.B	250000
	END

	  																									  																																								  																									  																																								  																									  																																								  																									  													
																									