 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFFC02.W
	MOVE.B	#21,$FFFFFC02.W
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	BSR	INITS
 	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	MOVE.W	#$FFF,$FFFF8242
	lea.l 	colors,a0
	lea.l 	$FFFF9800,a1
	move.l 	(a0)+,4(a1)
	move.l 	(a0),8(a1)
	move.l 	(a0)+,12(a1)
	move.l 	(a0),16(a1)
	move.l 	(a0),20(a1)
	move.l 	(a0),24(a1)
	move.l 	(a0)+,28(a1)
	move.l 	(a0),32(a1)
	move.l 	(a0),36(a1)
	move.l 	(a0),40(a1)
	move.l 	(a0),44(a1)
	move.l 	(a0),48(a1)
	move.l 	(a0),52(a1)
	move.l 	(a0),56(a1)
	move.l 	(a0),60(a1)
	move.l	#$ff000000,4(a1)
	bsr	GEN_CODE
	MOVE	#0,X_ANGLE
	MOVE	#270+180+90+90,Y_ANGLE
	MOVE	#0,Z_ANGLE
	MOVE	#1,SUB
LOOP
	move.l	#0,$FFFF9800
	CMPI	#700,SUB
	BEQ.S	NO_MOVEMENT
	BSR	MOUVEMENT
NO_MOVEMENT
	CMPI	#550,SUB
	BGT.S	NO_ROTA
	CMPI	#500,SUB
	BLS.S	NO_ROTA
	SUBQ	#8,Y_ANGLE
NO_ROTA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	BSR	EFFA
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR	TRACE
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	SUB.L	#384*50*2,A1
	MOVE.L	A1,WORKECR2
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	move.b 	affecr+3,$ffff820d.w

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
*	MOVE.W	#7,-(SP)
*	TRAP	#1
*	ADDQ.L	#2,SP
*	ADD.W	#4,X_ANGLE
*	CMPI.W	#720,X_ANGLE
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE
*NO_STOP
*	CMPI.B	#80,$FFFFC02
*	BNE.S	NO_STOP2
*	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	Y_ANGLE
NO_STOP2
*	move	#270,Y_ANGLE
*	ADD.W	#4,Z_ANGLE
*	CMPI.W	#720,Z_ANGLE
*	BLT.S	NO_STOP3
*	CLR.W	Z_ANGLE
*NO_STOP3
	BSR	TRIGO
	LEA	XE1,A0
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#7,D0
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
	ADD.W	#120+50,D2
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
	SUB.L	#50*384*2,D0
	MOVE.L	D0,WORKECR2

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
	MOVE	#192,$FFFF820E.W	;TAILLE EN MOT
	MOVE	#16,$FFFF8266.W	;16=VGA & 256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203-10,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#47-10,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
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
MOUVEMENT
	lea	ZE1,a0
	move	#7,d1
DO_IT
	add	#2,(a0)
	addq	#6,a0
	dbf	d1,DO_IT
	addq	#2,SUB
	rts
NEW_VBL
	addq	#1,$466.w
	rte
TRACE
	MOVE.W	DX,X1
	MOVE.W	DY,Y1
	MOVE.W	DX+4,X2
	MOVE.W	DY+4,Y2
	MOVE.W	DX+6,X3
	MOVE.W	DY+6,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	MOVE.W	DY+6,PTS+6
	MOVE.W	DY+8,PTS+8
	MOVE.W	DY+10,PTS+10
	MOVE	#6-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
NO_FACE
	MOVE.W	DX,X1
	MOVE.W	DY,Y1
	MOVE.W	DX+2,X2
	MOVE.W	DY+2,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BLE	NO_FACE2
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVE.W	DY+14,PTS+6
	MOVEQ	#4-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#4,D4
	BSR	REMPLI
NO_FACE2
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+6,X2
	MOVE.W	DY+6,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE3
	MOVE.W	DY+8,PTS
	MOVE.W	DY+6,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVE.W	DY+14,PTS+6
	MOVEQ	#4-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVEQ	#2,D4
	BSR	REMPLI
NO_FACE3
;les cotes
	MOVE.W	DX,X1
	MOVE.W	DY,Y1
	MOVE.W	DX+10,X2
	MOVE.W	DY+10,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BGT	NO_FACE4
	MOVE.W	DY,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVEQ	#3-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#2,D4
	BSR	REMPLI
NO_FACE4
	MOVE.W	DX+2,X1
	MOVE.W	DY+2,Y1
	MOVE.W	DX+4,X2
	MOVE.W	DY+4,Y2
	MOVE.W	DX+14,X3
	MOVE.W	DY+14,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BlE	NO_FACE5
	MOVE.W	DY+2,PTS
	MOVE.W	DY+4,PTS+2
	MOVE.W	DY+14,PTS+4
	MOVEQ	#3-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVEQ	#2,D4
	BSR	REMPLI
NO_FACE5
	MOVE.W	DX+8,X1
	MOVE.W	DY+8,Y1
	MOVE.W	DX+10,X2
	MOVE.W	DY+10,Y2
	MOVE.W	DX+12,X3
	MOVE.W	DY+12,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BlE	NO_FACE6
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVEQ	#3-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVEQ	#4,D4
	BSR	REMPLI
NO_FACE6
	MOVE.W	DX+4,X1
	MOVE.W	DY+4,Y1
	MOVE.W	DX+6,X2
	MOVE.W	DY+6,Y2
	MOVE.W	DX+14,X3
	MOVE.W	DY+14,Y3
	BSR	CACHE
	CMPI.L	#0,D3
	BlE	NO_FACE7
	MOVE.W	DY+4,PTS
	MOVE.W	DY+6,PTS+2
	MOVE.W	DY+14,PTS+4
	MOVEQ	#3-1,D1		;NOMBRE DE PTS-1
	BSR	INIT_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVEQ	#4,D4
	BSR	REMPLI
NO_FACE7
	rts
EFFA
	move.l	WORKECR,a0
	lea	768*25(a0),a0
	moveq	#0,d1
	move	#200,d0
	MOVE.L	#$3111,D7		;active cache
	MOVEC.L	D7,CACR
CLR_2PL
ASM	set	0
	rept	24
	move.l	d1,ASM(a0)
	move.w	d1,ASM+4(a0)
ASM	set	ASM+16
	endr
	lea	768(a0),a0
	dbf	d0,CLR_2PL
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
	ADD.L	#384*2,D2
	DBF	D1,MAKE
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
																																																																																																																																				
********INIT DIVERS***********************************************
INIT_FACE
	movem.l	clr,d0/d2-d7/a0-a6
	lea	PTS,a0		;zone de coord des pts
	move.w	d1,d7
	move.w	#-1,d0		;d0=ymax
	move.w	#$FFF,d1		;d1=ymin
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
;recherche des ymax et ymin et calcul de la hauteur du polygone
TRI_Y
	move.w	(a0,d2.w),d3	
	addq.w	#2,d2
	cmp.w	d3,d1
	ble.s	NO_YMIN
	move.w	d3,d1		;D1=new ymin
NO_YMIN
	cmp.w	d3,d0
	bgt.s	NO_YMAX
	move.w	d3,d0		;D0=new ymax
NO_YMAX
	DBF	d7,TRI_Y
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
;pour le clipping
	cmpi.w	#235+50,d0
	ble.s	NO_CLIP_YBAS
	move	#235+50,d0
NO_CLIP_YBAS
	cmpi.w	#55,d1
	bgt.s	NO_CLIP_YHAUT
	moveq	#55,d1
NO_CLIP_YHAUT
	move.w	d0,YMAX
	move.w	d1,YMIN	
	sub.w	d1,d0		;D0=hauteur	
	move.w	d0,HAUTEUR
	lsr	d0
	addq	#1,d0
;initialisation des tableaux des xmin et xmax
	lea	XMAX1,a0
	lea	XMIN1,a1
	MOVE.L	#$3111,D6		;cache on	
	MOVEC.L	D6,CACR
	moveq	#-1,d1
	move.l	#$FFF0FFF,d2
INIT_X	
	move.l	d1,(a0)+
	move.l	d2,(a1)+
	dbf	d0,INIT_X
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
********REMPLI TABLEAUX******************************************
TRACE_FACE
;trace virtuellement les lignes et stock ds xmin et xmax
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\NEWLINE.S"
********ROUTINE DE REMPLISSAGE*********************************** 
REMPLI
	lea	Y_TABLE,a4
	move.l	WORKECR2,a2
	add	d4,a2
	lea	XMAX1,a3
	lea	XMIN1,a1
	move.w	YMIN,d0
	add.l	(a4,d0.w*4),a2	;pos y de depart du polygone
	move.l	a2,d3
	move.w	HAUTEUR,d1
	tst	d1
	bne.s	REMPLI_OK
	rts
REMPLI_OK
	lea	RETOUR,a2
	lea	ADR_TAB,a5
	lea	PIX_TAB,a6
	MOVE.L	#$3111,D6		;cache on		
	MOVEC.L	D6,CACR
*********************
AFF_FACE
	move.l	d3,a0		;restitue adresse ecran
	move.w	(a3)+,d7		;xmax
	move.w	(a1)+,d6		;xmin
****
	move	d6,d4
	sub.w	d6,d7

	andi.w	#$fff0,d6	
	andi.w	#$f,d4		;valeur du bloc de depart
	add.w	(a6,d4.w*2),d7	;fixe pixel de depart
	add.w	d6,a0
	move.l	(a5,d7.w*4),a4
	jmp	(a4.l)
RETOUR
	add.l	#768,d3		;new ligne
	dbf	d1,AFF_FACE
	MOVE.L	#$2510,D6		;cache off	
	MOVEC.L	D6,CACR		
	rts
																																																																																																																																					INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\NEW_FACE\GEN_04.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\3D_ROUTS\CACHE3.S"
	SECTION DATA
OLD_VBL		DC.L	0 
X1		DC.W	0
Y1		DC.W	0
Z1		DC.W	0
X2		DC.W	0
Y2		DC.W	0
Z2		DC.W	0
X3		DC.W	0
Y3		DC.W	0
Z3		DC.W	0
OLD_CACR		DC.L	0
SAV_CY1		DC.W	0
IND		DC.B	0
colors		dc.l	$00400060,$00600080,$008000A0,$00C000E0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
WORKECR2:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
****GRAND CUBE**********
XE1		DC.W	-15
YE1		DC.W	6
ZE1		DC.W	-25-500
;
XE2		DC.W	15
YE2		DC.W	6
ZE2		DC.W	-25-500
;
XE3		DC.W	20
YE3		DC.W	0
ZE3		DC.W	-25-500
;
XE4		DC.W	15
YE4		DC.W	-6
ZE4		DC.W	-25-500
;
XE5		DC.W	-15
YE5		DC.W	-6
ZE5		DC.W	-25-500
;
XE6		DC.W	-20
YE6		DC.W	0
ZE6		DC.W	-25-500
;
XE7		DC.W	-15
YE7		DC.W	0
ZE7		DC.W	25-500
;
XE8		DC.W	15
YE8		DC.W	0
ZE8		DC.W	25-500
*****************
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	160
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
CX1		DC.W	0
CX2		DC.W	0
CY1		DC.W	0
CY2		DC.W	0
SCREEN_ADD		DC.L	0
YMAX		DC.W	0
YMIN		DC.W	0
HAUTEUR		DC.W	0
COLOR:		DC.L	0
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
GEN		DS.B	485000
ADR_TAB		DS.B	1000*25
DX		DS.W	50
DY		DS.W	50
XP		DS.W	1
YP		DS.W	1
SUB		DS.W	1
SAVE_VBL:		DS.L	1
VAR_3D		DS.W	9
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		DS.B	4
XBIOS2:		DS.B	768*242
		DS.B	4
XBIOS3:		DS.B	768*242
		DS.L	500
XMAX1		DS.W	300
		DS.L	500
XMIN1		DS.W	300
Y_TABLE		DS.L	300
PTS		DS.W	15
		END
												