*****************************
*      3D CALCUL ROUTINE    *	
*      	    by           *	
*     Cristalion/Hydroxid   *
*****************************
col1	=	$757
col2	=	$635
col3	=	$513
col4	=	$402

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
	BSR	MAKE_YTABLE
	BSR	CLR_REGISTERS
	MOVE.W	#0,$FFFF8240
	MOVE.W	#$FFF,$FFFF8242
	move.w	#6,plan
	move.w	#1,OK2

LOOP
	CLR.W	$FFFF8240
	bsr	choose_col
	CMPI.W	#108,ZDEP
	BGT.S	STOP_ZOOM
	ADDQ.W	#8,ZDEP
STOP_ZOOM
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.W	#$700,$FFFF8240
NO_ALt1
	BSR	EFFA_falc
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.W	#$70,$FFFF8240
NO_ALT2
	BSR	MAKE_CUBE
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.W	#$777,$FFFF8240
NO_ALT3
	BSR	TRACE_LIGNE
	lea.l colors,a0
	lea.l $ffff8240.w,a1
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	addq.l 	#2,affecr
	move.w 	affecr+2,d0
	andi.w 	#8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s 	trainee			; on boucle
 	subq.w 	#8,affecr+2
trainee
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
MAKE_CUBE
*	ADD.W	#4,X_ANGLE
*	CMPI.W	#720,X_ANGLE
*	BLT.S	NO_STOP
*	CLR.W	X_ANGLE
*NO_STOP
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2
	CLR.W	Y_ANGLE
NO_STOP2
	ADD.W	#2,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	BSR	TRIGO
	MOVE.W	XE1,XE
	MOVE.W	YE1,YE
	MOVE.W	ZE1,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX
	MOVE.W	YP,DY
;
	MOVE.W	XE2,XE
	MOVE.W	YE2,YE
	MOVE.W	ZE2,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+2
	MOVE.W	YP,DY+2
;
	MOVE.W	XE3,XE
	MOVE.W	YE3,YE
	MOVE.W	ZE3,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+4
	MOVE.W	YP,DY+4
;
	MOVE.W	XE4,XE
	MOVE.W	YE4,YE
	MOVE.W	ZE4,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+6
	MOVE.W	YP,DY+6
;
	MOVE.W	XE5,XE
	MOVE.W	YE5,YE
	MOVE.W	ZE5,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+8
	MOVE.W	YP,DY+8
;
	MOVE.W	XE6,XE
	MOVE.W	YE6,YE
	MOVE.W	ZE6,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+10
	MOVE.W	YP,DY+10
;
	MOVE.W	XE7,XE
	MOVE.W	YE7,YE
	MOVE.W	ZE7,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+12
	MOVE.W	YP,DY+12
;
	MOVE.W	XE8,XE
	MOVE.W	YE8,YE
	MOVE.W	ZE8,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+14
	MOVE.W	YP,DY+14
;
	MOVE.W	XE9,XE
	MOVE.W	YE9,YE
	MOVE.W	ZE9,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+16
	MOVE.W	YP,DY+16
;
	MOVE.W	XE10,XE
	MOVE.W	YE10,YE
	MOVE.W	ZE10,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+18
	MOVE.W	YP,DY+18
;
	MOVE.W	XE11,XE
	MOVE.W	YE11,YE
	MOVE.W	ZE11,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+20
	MOVE.W	YP,DY+20
;
	MOVE.W	XE12,XE
	MOVE.W	YE12,YE
	MOVE.W	ZE12,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+22
	MOVE.W	YP,DY+22
;
	MOVE.W	XE13,XE
	MOVE.W	YE13,YE
	MOVE.W	ZE13,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+24
	MOVE.W	YP,DY+24
;
	MOVE.W	XE14,XE
	MOVE.W	YE14,YE
	MOVE.W	ZE14,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+26
	MOVE.W	YP,DY+26
;
	MOVE.W	XE15,XE
	MOVE.W	YE15,YE
	MOVE.W	ZE15,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+28
	MOVE.W	YP,DY+28
;
	MOVE.W	XE16,XE
	MOVE.W	YE16,YE
	MOVE.W	ZE16,ZE
	BSR	SP_TO_PL
	MOVE.W	XP,DX+30
	MOVE.W	YP,DY+30
	RTS

***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
*	MOVE.W	#-1,-(SP)		*
*	MOVE.W	#88,-(SP)		*
*	TRAP	#14			*
*	ADDQ.L	#4,SP			*
*	MOVE.W	D0,OLDMODECODE		*

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
choose_col
	cmpi.w	#0,plan
	beq.s	plan1
	cmpi.w	#2,plan
	beq.s	plan2
	cmpi.w	#4,plan
	beq	plan3
	cmpi.w	#6,plan
	beq	plan4
plan1
           move.w #col1,$ffff8242.w
           move.w #col4,$ffff8244.w
           move.w #col1,$ffff8246.w
           move.w #col3,$ffff8248.w
           move.w #col1,$ffff824a.w
           move.w #col3,$ffff824c.w
           move.w #col1,$ffff824e.w
           move.w #col2,$ffff8250.w
           move.w #col1,$ffff8252.w
           move.w #col2,$ffff8254.w
           move.w #col1,$ffff8256.w
           move.w #col2,$ffff8258.w 
           move.w #col1,$ffff825a.w 
          move.w #col2,$ffff825c.w 
           move.w #col1,$ffff825e.w
	jmp	endcol
plan2
           move.w #col2,$ffff8242.w
           move.w #col1,$ffff8244.w
           move.w #col1,$ffff8246.w
           move.w #col4,$ffff8248.w
           move.w #col2,$ffff824a.w
           move.w #col1,$ffff824c.w
           move.w #col1,$ffff824e.w
           move.w #col3,$ffff8250.w
           move.w #col2,$ffff8252.w
           move.w #col1,$ffff8254.w
           move.w #col1,$ffff8256.w
           move.w #col3,$ffff8258.w
           move.w #col2,$ffff825a.w
           move.w #col1,$ffff825c.w
           move.w #col1,$ffff825e.w
	jmp	endcol
plan3 
           move.w #col3,$ffff8242.w
           move.w #col2,$ffff8244.w
           move.w #col2,$ffff8246.w
           move.w #col1,$ffff8248.w
           move.w #col1,$ffff824a.w
           move.w #col1,$ffff824c.w
           move.w #col1,$ffff824e.w
          move.w #col4,$ffff8250.w
           move.w #col3,$ffff8252.w
           move.w #col2,$ffff8254.w
           move.w #col2,$ffff8256.w
           move.w #col1,$ffff8258.w
           move.w #col1,$ffff825a.w
           move.w #col1,$ffff825c.w
           move.w #col1,$ffff825e.w
	jmp	endcol
plan4
           move.w #col4,$ffff8242.w
           move.w #col3,$ffff8244.w
           move.w #col3,$ffff8246.w
           move.w #col2,$ffff8248.w
           move.w #col2,$ffff824a.w
           move.w #col2,$ffff824c.w
           move.w #col2,$ffff824e.w
           move.w #col1,$ffff8250.w
           move.w #col1,$ffff8252.w
           move.w #col1,$ffff8254.w
           move.w #col1,$ffff8256.w
           move.w #col1,$ffff8258.w
           move.w #col1,$ffff825a.w
           move.w #col1,$ffff825c.w
           move.w #col1,$ffff825e.w
endcol
	addq.w	#1,ok2	
	cmpi.w	#2,ok2	
	bne	endplan	
	move.w	#0,ok2	
	addq.w	#2,plan	
	cmpi.w	#8,plan	
	bne	endplan	
	move.w	#0,plan
endplan
	rts
**********************CLS ROUT*****************************************
;sur F30
EFFA_FALC
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#0,A1
	MOVEQ	#0,D0
	MOVE.W	#199,D1
.EFF
OXO	SET	16
	REPT	16
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
	movem.l	clr,d0-d6/a0-a6
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
**********************
TRACE_LIGNE
;face1
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	LINE
;face2
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
;lignes 
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	LINE
;****petit cube******
;face1
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
;face2
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+30,CX1
	MOVE.W	DY+30,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+30,CX1
	MOVE.W	DY+30,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	LINE
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	LINE
;lignes 
	MOVE.W	DX+18,CX1
	MOVE.W	DY+18,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+20,CX1
	MOVE.W	DY+20,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	LINE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+30,CX2
	MOVE.W	DY+30,CY2
	BSR	LINE
;******join les 2 cubes*********
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+30,CX2
	MOVE.W	DY+30,CY2
	BSR	LINE
	MOVE.W	DX+12,CX1
	MOVE.W	DY+12,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	LINE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	LINE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	LINE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	LINE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	LINE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	LINE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	LINE
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
********************************************
*calcul des coordonnees planes		   *
*en entree:xe,ye,ze,z_pt_fuite   	   *
*en sortie:xp,yp coordonnees planes	   *
*new_xe,new_ye,new_ze nouvelles coord sp   *
********************************************

SP_TO_PL
	MOVEM.L	D0-D7/A1-A6,-(SP)		
	LEA	XE,A6
	MOVEM.W	(A6)+,D0-D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	MOVEQ.W	#9,D6
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

	MULS	(A6)+,D3	;d3=c*xe*512
	MULS	(A6)+,D4	;d4=f*ye*512
	MULS	(A6)+,D5	;d5=i*ze*512
	ADD.L	D4,D5		;+f*ye*512
	ADD.L	D3,D5		;+c*xe*512
	ADD.L	A3,D5		;+zdep*512
	MOVE.L	D5,A5		;a5=new_ze*512
	DIVS	Z_PT_FUITE,D5	;d5=new_ze/z_pt_fuite
	
	MOVE.W	#512,D7
	SUB.W	D5,D7		;d7=512*q
				;d7=512*(1-new_ze/z_pt_fuite)
	MOVE.W	D0,D3		;d3=xe
	MOVE.W	D1,D4		;d4=ye
	MOVE.W	D2,D5		;d5=ze

	MULS	(A6)+,D3	;d3=a*xe*512
	MULS	(A6)+,D4	;d4=d*ye*512
	MULS	(A6)+,D5	;d5=g*ze*512
	ADD.L	D4,D5		
	ADD.L	D3,D5
	ADD.L	A1,D5
	MOVE.L	D5,A4		;a4=new_xe*512
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0	;d0=b*xe*512
	MULS	(A6)+,D1	;d1=e*ye*512
	MULS	(A6)+,D2	;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	MOVE.L	D2,D6		;d6=new_ye*512
	DIVS	D7,D2		;d2=new_ye/q

	LEA	XP,A6		;A6 pointe sur zone de sauve 
				;coord planes
	ADD.W	#160,D5
	MOVE.W	D5,(A6)+	;xp
	
	ADD.W	#100,D2
	MOVE.W	D2,(A6)+	;yp

	MOVEM.L	(SP)+,D0-D7/A1-A6
	RTS

SORTIE
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

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\LINEROUT\LINEROUT.S"
	SECTION DATA
SAV_CY1		DC.W	0
IND		DC.B	0
colors 		dc.w 	$023,$034,$045,$067
AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	1
OLDMODECODE	DC.W	1
FORME		INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\multipar.t\V.INL"	
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
****GRAND CUBE**********
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
****PETIT CUBE**********
XE9		DC.W	10
YE9		DC.W	10
ZE9		DC.W	-10
;
XE10		DC.W	10
YE10		DC.W	-10
ZE10		DC.W	-10
;
XE11		DC.W	-10
YE11		DC.W	10
ZE11		DC.W	-10
;
XE12		DC.W	-10
YE12		DC.W	-10
ZE12		DC.W	-10
;
XE13		DC.W	10
YE13		DC.W	10
ZE13		DC.W	10
;
XE14		DC.W	10
YE14		DC.W	-10
ZE14		DC.W	10
;
XE15		DC.W	-10
YE15		DC.W	10
ZE15		DC.W	10
;
XE16		DC.W	-10
YE16		DC.W	-10
ZE16		DC.W	10
*****************
OK2		DC.w	0
PLAN		DC.w	0
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	-500
X_ANGLE		DC.W	2
Y_ANGLE		DC.W	2
Z_ANGLE		DC.W	2
Z_PT_FUITE	DC.W	200
CX1		DC.W	0
CX2		DC.W	0
CY1		DC.W	0
CY2		DC.W	0
	SECTION	BSS
DX		DS.W	50
DY		DS.W	50
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1

VAR_3D		DS.W	9
Y_TABLE	DS.W	201
CLR	DS.L	17
	DS.L	2000
PILE	DS.L	10
	END
				 	  																																																																								 																								