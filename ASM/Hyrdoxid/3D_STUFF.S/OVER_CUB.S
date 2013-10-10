;essaie routine de lignes en true-color

nblines=	12

	SECTION	TEXT

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70,OLD_VBL
	move.l	#NEW_VBL,$70
	BSR	INITS
 	BSR	CLS
	CLR.b	COMPT
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	MOVE.W	#$FFF,$FFFF8242
	MOVE.L	#TAB_SAV1,SAVE1
	MOVE.L	#TAB_SAV2,SAVE2	
LOOP
	move.l	#$77770077,$FFFF9800
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	cmpi.b	#2,compt
	blt.s	NO_EFFA
	BSR	EFFA
	BRA.S	OK_EFFA
NO_EFFA
	ADD.b	#1,COMPT
OK_EFFA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR	TRACE_LIGNE
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	add.l	#2*370,AFFECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	move.b	affecr+3,$ffff820d.w
	sub.l	#2*370,AFFECR
	MOVE.L	SAVE1,A1		;swap zones de sauvegarde
	MOVE.L	SAVE2,A2
	MOVE.L	A1,SAVE2
	MOVE.L	A2,SAVE1
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
*********************
MAKE_CUBE
	addq	#2,X_ANGLE
	cmpi	#720,X_ANGLE
	bne.s	NO_CLR1
	clr	X_ANGLE
NO_CLR1
	addq	#2,Y_ANGLE
	cmpi	#720,Y_ANGLE
	bne.s	NO_CLR2
	clr	Y_ANGLE
NO_CLR2
	bsr	TRIGO
	LEA	XE1,A0
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#7,D0
	MOVEQ.W	#9,D6
	MOVE.L	#$3111,D7
	MOVEC.L	D7,CACR
LOOP_TRIGO
	MOVEM.L	D0/A1-A2,-(SP)		
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	ASL.L	D6,D3		;xdep*512
	ASL.L	D6,D4		;ydep*512
	ASL.L	D6,D5		;zdep*512
	MOVE.L	D3,A1
	MOVE.L	D4,A2
	MOVE.L	D5,A3

	LEA	VAR_3D,A6
	MOVE.W	D0,D3
	MOVE.W	D1,D4
	MOVE.W	D2,D5

	MULS	(A6)+,D3		;d3=c*xe*512
	MULS	(A6)+,D4		;d4=f*ye*512
	MULS	(A6)+,D5		;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	ASR.L	#8,D5
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3		;d3=a*xe*512
	MULS	(A6)+,D4		;d4=d*ye*512
	MULS	(A6)+,D5		;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0		;d0=b*xe*512
	MULS	(A6)+,D1		;d1=e*ye*512
	MULS	(A6)+,D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	DIVS	D7,D2		;d2=new_ye/q
	ADD.W	#160+370,D5	
	ADD.W	#100,D2
	MOVEM.L	(SP)+,D0/A1-A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D7
	MOVEC.L	D7,CACR
	rts
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVEC	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		; cache on ... 
	MOVEC	D0,CACR			

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
 	MOVE.W	#%0000000000100100,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l 	$44e.w,d0
	MOVE.L	d0,A1
	add.l	#256000*2,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS
*******************************SOUS ROUTINES*****************************************
NEW_VBL
	addq.l	#1,$466
	rte
EFFA
	moveq	#nblines-1,d1
	moveq	#0,d2
	moveq	#0,d3
	MOVE.L	#$3111,D7
	MOVEC.L	D7,CACR
NEW_LINE
	move.l	SAVE1,a2	
	add.l	d3,a2
	move	(a2)+,d0
CLR_LINE
	move.l	(a2)+,a0
	move	d2,(a0)
	dbf	d0,CLR_LINE
	add.l	#400*4,d3
	dbf	d1,NEW_LINE
	MOVE.L	#$2510,D7
	MOVEC.L	D7,CACR
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
	MOVE.W	#46080,D0
OK
	MOVE.L	#0,(A0)+
	move.l 	#0,(a1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.B	#250,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#640,D2
	DBF	D1,MAKE
	RTS
**********************
TRACE_LIGNE
	move.l	SAVE1,a2
;face1
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea.l	400*4(a2),a2
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*2(a2),a2
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*3(a2),a2
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
;face2
	move.l	SAVE1,a2
	lea	400*4*4(a2),a2
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*5(a2),a2
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*6(a2),a2
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*7(a2),a2
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
;lignes 
	move.l	SAVE1,a2
	lea	400*4*8(a2),a2
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*9(a2),a2
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*10(a2),a2
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	LINE
	move.l	SAVE1,a2
	lea	400*4*11(a2),a2
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	LINE
	rts
****************************ROUTINE DE CALCUL************************************
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

	LEA	VAR_3D,A6		;zone sauvegarde calc intermediaire
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
	move.l	OLD_VBL,$70
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
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

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\LINEROUT\T_LINEF2.S"
	SECTION DATA
OLD_VBL		DC.L	0
OLD_CACR		DC.L	0
SAV_CY1		DC.W	0
IND		DC.B	0
AFFECR:		DC.L 	1
WORKECR:		DC.L 	1
OLDXBIOS2:		DC.L	1
OLDMODECODE	DC.W	1
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
XE1		DC.W	20
YE1		DC.W	20
ZE1		DC.W	-20
;
XE2		DC.W	20
YE2		DC.W	-20
ZE2		DC.W	-20
;
XE3		DC.W	-20
YE3		DC.W	20
ZE3		DC.W	-20
;
XE4		DC.W	-20
YE4		DC.W	-20
ZE4		DC.W	-20
;
XE5		DC.W	20
YE5		DC.W	20
ZE5		DC.W	20
;
XE6		DC.W	20
YE6		DC.W	-20
ZE6		DC.W	20
;
XE7		DC.W	-20
YE7		DC.W	20
ZE7		DC.W	20
;
XE8		DC.W	-20
YE8		DC.W	-20
ZE8		DC.W	20
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	145
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
Z_PT_FUITE		DC.W	140
CX1		DC.W	0
CX2		DC.W	0
CY1		DC.W	0
CY2		DC.W	0
SCREEN_ADD		DC.L	0
SAVE1		DC.L	0
SAVE2		DC.L	0
COMPT		DC.B	0
	SECTION	BSS
DX		DS.W	50
DY		DS.W	50
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1

VAR_3D		DS.W	9
Y_TABLE		DS.L	300
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.B	640*240*4*2
TAB_SAV1		DS.L	400*50
TAB_SAV2		DS.L	400*50
	END																									  																									 	  																																		  																																																														