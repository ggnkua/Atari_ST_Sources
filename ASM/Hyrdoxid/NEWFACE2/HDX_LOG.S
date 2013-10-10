;_il manque 1 test pour verifier que l'on soit ds la sens trigo
;_test inutil si faces cachees car tjrs sens trigo !!!

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	BSR	INITS
 	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	bsr	GEN_CODE
	bsr	INIT_PAL
	move	#360,z_angle
	clr	x_angle
	clr	y_angle
;	move	#-200,zdep
LOOP
;	addq	#2,zdep
;	rept	1000
;	move	#2,d0
;	divs	#2,d0
;	endr
	move.l	#$50,$FFFF9800
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	BSR.W	EFFA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR.W	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR.W	TRACE
	BSR.W	SYNCHRO
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
	cmp.b	#53,$ffffc02
	bne.s	NO_ADD
	addq	#2,ZDEP
NO_ADD
	cmp.b	#54,$ffffc02
	bne.s	NO_SUB
	subq	#2,ZDEP
NO_SUB
*	ADD.W	#4,X_ANGLE
	CMPI.W	#720,X_ANGLE
	BLT.S	NO_STOP
	CLR.W	X_ANGLE
NO_STOP
*	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	Y_ANGLE
NO_STOP2
*	ADD.W	#6,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	BSR	TRIGO
	LEA	COORD,A0
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#13-1,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
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
	ADD.W	#192,D5	
	ADD.W	#120,D2
	MOVEM.L	(SP)+,D0/A1-A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVEC.L	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	move.l	$44E.W,OLDXBIOS2
	
	MOVE.L	#XBIOS2,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,AFFECR

	MOVE.L	#XBIOS3,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,WORKECR

	BSR	SYNCHRO
	BSR	VGA
	RTS
SYNCHRO:
	MOVE.L	AFFECR,D0
	MOVE.L	WORKECR,AFFECR
	MOVE.L	D0,WORKECR

	move.b AFFECR+1,$ffff8201.w
	move.b AFFECR+2,$ffff8203.w
	move.b AFFECR+3,$ffff820D.w
	RTS
VGA:
	MOVE	#192,$FFFF8210.W	;TAILLE EN MOT
*	MOVE	#192,$FFFF820E.W	;TAILLE EN MOT
	MOVE	#16,$FFFF8266.W	;16=VGA & 256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203-5,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#47-5,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#764,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#157,$FFFF828A.W	;FULL DROIT
	MOVE	#216,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#625,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#47,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#85,$FFFF82A8.W	;FULL HAUT
	MOVE	#566,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	CLR	$FFFF82C2.W	;PIXEL OPTIONS	
	RTS
*******************************SOUS ROUTINES*****************************************
INIT_PAL
	lea	$ffff9804,a0
;plan 1
	move.l	#$55000088,(a0)+
;plan 2
	move.l	#$3c6800f0,(a0)+
	move.l	#$3c6800f0,(a0)+
;plan 3
	move.l	#$f8f800ff,(a0)+
	move.l	#$d4d400f4,(a0)+
	move.l	#$f8f800ff,(a0)+
	move.l	#$f8f800ff,(a0)+
	rts
NEW_VBL
	addq	#1,$466.w
	rte
TRACE
	lea	DX,a0
	lea	DY,a1
	lea	OBJET,a2
	lea	SAVEY,a3
	move	(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	2(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	4(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	6(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	#4-1,d7
	bsr	INIT_FACE
	moveq	#4-1,d0
.LOOP
	move	(a2)+,d1
	move	(a2),d2
	move	(a0,d1.w*2),CX1
	move	(a1,d1.w*2),CY1
	move	(a0,d2.w*2),CX2
	move	(a1,d2.w*2),CY2
	bsr	TRACE_FACE
	dbf	d0,.LOOP
	moveq	#0,d4
	bsr	REMPLI

	lea	DX,a0
	lea	DY,a1
	lea	OBJET,a2
	add.l	#5*2,a2
	lea	SAVEY,a3
	move	(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	2(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	4(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	6(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	#4-1,d7
	bsr	INIT_FACE
	moveq	#4-1,d0
.LOOP2
	move	(a2)+,d1
	move	(a2),d2
	move	(a0,d1.w*2),CX1
	move	(a1,d1.w*2),CY1
	move	(a0,d2.w*2),CX2
	move	(a1,d2.w*2),CY2
	bsr	TRACE_FACE
	dbf	d0,.LOOP2
	moveq	#0,d4
	bsr	REMPLI

	lea	DX,a0
	lea	DY,a1
	lea	OBJET,a2
	add.l	#10*2,a2
	lea	SAVEY,a3
	move	(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	2(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	4(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	6(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	#4-1,d7
	bsr	INIT_FACE
	moveq	#4-1,d0
.LOOP3
	move	(a2)+,d1
	move	(a2),d2
	move	(a0,d1.w*2),CX1
	move	(a1,d1.w*2),CY1
	move	(a0,d2.w*2),CX2
	move	(a1,d2.w*2),CY2
	bsr	TRACE_FACE
	dbf	d0,.LOOP3
	moveq	#0,d4
	bsr	REMPLI

	lea	DX,a0
	lea	DY,a1
	lea	OBJET,a2
	add.l	#15*2,a2
	lea	SAVEY,a3
	move	(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	2(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	4(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	6(a2),d1
	move	(a1,d1.w*2),(a3)+
	move	#4-1,d7
	bsr	INIT_FACE
	moveq	#4-1,d0
.LOOP4
	move	(a2)+,d1
	move	(a2),d2
	move	(a0,d1.w*2),CX1
	move	(a1,d1.w*2),CY1
	move	(a0,d2.w*2),CX2
	move	(a1,d2.w*2),CY2
	bsr	TRACE_FACE
	dbf	d0,.LOOP4
	moveq	#0,d4
	bsr	REMPLI
	rts

EFFA
	move.l	WORKECR,a0
	lea	192*2*25(a0),a0
	moveq	#0,d1
	move	#200,d0
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
CLR_1PL
ASM	set	48
	rept	18
	move.w	d1,ASM(a0)
ASM	set	ASM+16
	endr
	lea	384(a0),a0
	dbf	d0,CLR_1PL
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	rts
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
	MOVE.W	#(11520*2)-1,D0
	MOVEQ	#0,D1
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(a1)+
	DBF	D0,OK
	MOVE.L	#$2510,D6		;cache off
	MOVEC.L	D6,CACR		
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.B	#250,D1
	MOVEQ.L	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#384,D2
	DBF	D1,MAKE
	RTS
CACHE
	SUB	D0,D1	;X3-X1
	SUB	D2,D3	;Y2-Y1
	MULS	D1,D3	
	SUB	D0,D4	;X2-X1
	SUB	D2,D5	;Y3-Y1
	MULS	D4,D5
	SUB.L	D5,D3
	RTS
****************************ROUTINE DE CALCUL************************************
********************************************************
*precalculs trigonometriques			*
*en entree:x_angle,y_angle,z_angle(angles de rotation) *	
*en sortie:(A,B,C,D,E,F,G,H,I)*512		*				
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

	LEA	VAR_3D,A6		;zone sauvegarde calc intermediaire
	MOVEQ	#9,D7
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

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\GEN_04.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEWFACE2\REMPL_03.S"
	SECTION DATA
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	

OBJET	DC	0,1,2,3,0
	DC	2,1,4,5,2
	DC	8,7,6,4,8
	DC	9,10,11,12,9
COORD	
pt0	DC	25,0-12,0
pt1	DC	0,30-12,0
pt2	DC	0,22-12,0
pt3	DC	18,0-12,0
pt4	DC	-25,0-12,0
pt5	dc	-18,2-12,0
pt6	dc	-18,5-12,0
pt7	dc	5,5-12,0
pt8	dc	10,0-12,0
pt9	dc	35,-10-12,0
pt10	dc	30,-5-12,0
pt11	dc	-30,-5-12,0
pt12	dc	-35,-10-12,0
*****************
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	150
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
PIX_TAB		
		DC.W	0
		DC.W	385
		DC.W	(385+384)
		DC.W	(385+384+383)
		DC.W	(385+384+383+382)
		DC.W	(385+384+383+382+381)
		DC.W	(385+384+383+382+381+380)
		DC.W	(385+384+383+382+381+380+379)
		DC.W	(385+384+383+382+381+380+379+378)
		DC.W	(385+384+383+382+381+380+379+378+377)
		DC.W	(385+384+383+382+381+380+379+378+377+376)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373+372)
		DC.W	(385+384+383+382+381+380+379+378+377+376+375+374+373+372+370)
	SECTION	BSS
X1		DS	1
X2		DS	1
X3		DS	1
Y1		DS	1
Y2		DS	1
Y3		DS	1
CX1		DS	1
CX2		DS	1
CY1		DS	1
CY2		DS	1
YMAX		DS	1
YMIN		DS	1
HAUTEUR		DS	1
OLD_VBL		DS.L	1
OLD_CACR		DS.L	1
IND		DS.B	1
SAVEY		DS.W	10
AFFECR:		DS.L 	1
WORKECR:		DS.L 	1
OLDXBIOS2:		DS.L	1
OLDMODECODE	DS	1
GEN		DS.B	485000
ADR_TAB		DS.B	1000*25
DX		DS	50
DY		DS	50
VAR_3D		DS	9
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		DS.B	4
XBIOS2:		DS.B	768*242
		DS.B	4
XBIOS3:		DS.B	768*242
XMIN1		DS	300
XMAX1		DS	300
Y_TABLE		DS.L	300
	END										  																																																																																					  																									  																																												  																														