*******************************************************
*          LITTLE MULTIPART FOR THE SANOM II          *
*              by Cristalion/Hydroxid  		      *
*          A FIRST REAL TRY OF DEMO IN ASM ...        *
*******************************************************

*	opt	o+,d+,w+
largeur=	319
hauteur=	51


	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP	
	MOVE.L	SP,SAVE_SP
	
	CMPI.L	#$484458,$604
	BEQ.S	GO
	CMPI	#$FF,$59E
	BNE.S	NOT_FAL
	CLR	$59E
NOT_FAL	lea	$0.w,a7		pile apres reset
	lea	4.w,a0		pc apres reset
	move.l	(a0),a0
	jmp	(a0)		reset !
GO	
	LEA	LIGNE_TAB,A5
	BSR	PRECALC

	BSR	VBL
	PEA	$ffff823E
	MOVE	#1,-(SP)
	BSR	TRUE_FADE_OUT_NEW
	ADDQ.L	#6,SP

	CLR.L	$4D6	
	CLR.B	FALCON
	CMPI.W	#$FF,$59E	
	BNE.S	NO_FALC		
	MOVE.B	#1,FALCON
	MOVE.B	$FF8007,SAVE_8007		;si FALCON		
	MOVE.B	#%00100101,$FF8007		;on met le turbo !!!
NO_FALC

	BSR	GEN_MUS
	BSR	GEN_MUS_FIN
	*BSR	VBL
	*CLR.B	$484.W
	*MOVE.B	#18,$FFFFC02
	BSR	REAL_PAL_NOIR
	BSR	VBL
	BSR	INITS
	BSR	SAVE_INTER
	MOVE.L	#PLAYER,$4D2
	BSR	INIT_RAST
	MOVE.L	#TIMER,$4D2
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	VBL
*******
	BSR	ZOOM
	BSR	PRINTER_1
*;*
	BSR	PART1
*;*
	BSR	PART2
*;*
	BSR	PART3
*;*
	BSR	PART4
*;*
	BSR	PART5
*;*
	BSR	PART6
*******
	BRA	FIN	
*****************************************INTRO*****************************************************
ZOOM
	PEA	LOGO+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	MOVE.W	#0,COMPT
	LEA	LIGNE_TAB,A5
	MOVE.L	#0,ROZO
	MOVE.W	#0,COMPT_FADE
	MOVE.W	(A5),D2
ZOOM_IN
	bsr	VBL
	CLR.W	$FFFF8240
	ADDQ.W	#1,COMPT_FADE
	BSR	EFFAZ
	BSR	AFF_ZOOM
	MOVE.W	(A5),D2
	CMPI.L	#220000,ROZO
	BHI.S	NO_ROZO
	MOVE.W	(A5)+,D2
	ADD.L	D2,ROZO
NO_ROZO
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.W	#5,$FFFF8240
NO_ALT
	CMPI.W	#350,COMPT_FADE
	BLE.S	ZOOM_IN
	PEA	LOGO
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	RTS
***************************************************************************************************
********************************PREMIERE PART (3d SHADE SPRITES)*****************************************************
***************************************************************************************************
	
PRINTER_1
	BSR	CLS
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	MOVE.L	WORKECR,A2
	ADD.L	#5120,A2
	MOVE.W	#0,D7
LOOP2	
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#111,D3
	BNE.S	LOOP2
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	COMPT_FADE
SUITE5
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	SUITE5
	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	RTS
************
PART1
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVEQ.L	#3,D7
	MOVEQ.L	#80,D5
	CLR.W	COMPT_FADE
PART_1
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE26
	lea	COLORS,a0
	BSR	SPLINE_FADE_OUT
NO_FADE26
	CMPI.W	#560,COMPT_FADE
	BHI	END_PART1_2
	lea.l colors,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	BSR 	ROUT_SPRITES
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee			; on boucle
 	subq.w #8,affecr+2
trainee
	cmpi.b	#56,$fffffc02
	bne.s	ALT
	MOVE.W	#5,$FFFF8240.W
alt
	BRA	PART_1
END_PART1_2
	CLR	COMPT_FADE
 	BSR	PAL_NOIR
	BSR	VBL
	BSR	CLS
	BSR	RESTORE_SCREEN
	BSR	PAL_NOIR
	BSR	CLS
	BSR	VBL
PART_1_2
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE24
	lea	COLORS2,a0
	BSR	SPLINE_FADE_OUT
NO_FADE24
	cmpi.W	#560,COMPT_FADE
	BHI	END_PART1
	lea.l colors2,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	BSR 	ROUT_SPRITES2
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee8			; on boucle
 	subq.w #8,affecr+2
trainee8
	cmpi.b	#56,$fffffc02
	bne.s	ALT8
	MOVE.W	#5,$FFFF8240.W
alt8
	BRA	PART_1_2
END_PART1
	BSR	PAL_NOIR
	BSR	VBL
	BSR	CLS
	BSR	RESTORE_SCREEN
	BSR	PAL_NOIR
	BSR	CLS
	BSR	VBL
	RTS
******************LES 2 CUBES************************
	
ROUT_SPRITES
	MOVEM.L	A1-A3/D2-D4/D6,-(SP)
	MOVEQ.L	#0,D2
	ADDQ.W	#1,D7
	ADDQ.W	#1,D5
	CMPI.W	#360,D5
	BLO.S	TEST3
	SUBI.W #360,D5
TEST3	CMPI.W	#360,D7
	BLO.S	TEST2
	SUBI.W #360,D7
TEST2	CMPI.W	#360,D1			; si courbe fini on boucle
	BNE.S	SUITE
	MOVEQ.L	#0,D1

*********EFFACE LES TRACES******
SUITE
	BSR	EFFA
	
*********AFFICHE LES SPRITES*****

	MOVE.L	#XCUBE,X
	MOVE.L	#YCUBE,Y		

	MOVEQ.W	#63,D0
MULTI	BSR	SPRITE
	ADD.L	#380,D6
	DBF	D0,MULTI

	MOVE.L 	D7,-(SP)
	MOVEQ.L	#0,D6
 	MOVE.L	D5,D7
	MOVE.W	#63,D0
MULTI2	BSR	SPRITE
	ADD.L	#380,D6
	DBF	D0,MULTI2
	MOVE.L	(SP)+,D7

	ADDQ.W	#1,D1	

	MOVEM.L	(SP)+,A1-A3/D2-D4/D6
	RTS	
******************LE HDX************************	
ROUT_SPRITES2
	MOVE.L	D6,-(SP)
	MOVEM.L	A1-A3/D2-D4,-(SP)
	CLR.L	D2
	ADDQ.W	#1,D7
	ADDQ.W	#1,D5
	CMPI.W	#360,D5
	BNE.S	TES
	CLR.W	D5
TES	CMPI.W	#360,D7
	BNE.S	TES2
	CLR.W	D7
TES2					; si courbe fini on boucle

*********EFFACE LES TRACES******
	BSR	EFFA
*********AFFICHE LES SPRITES*****

	MOVE.L	#XHDX,X	
	MOVE.L	#YHDX,Y		

	CLR.L	D6
	CLR.L	D1
	MOVE.W	#35,D0
MULT	BSR	SPRITE2
	ADD.L	#380,D6
	ADD.L	#380*2,D1
	DBF	D0,MULT

	MOVE.L 	D7,-(SP)
	CLR.L	D6
	CLR.L	D1
 	MOVE.L	D5,D7
	MOVE.W	#35,D0
MULT2	BSR	SPRITE2
	ADD.L	#380,D6
	ADD.L	#380*2,D1
	DBF	D0,MULT2
	MOVE.L	(SP)+,D7	

	MOVEM.L	(SP)+,A1-A3/D2-D4
	MOVE.L	(SP)+,D6
	RTS	
**********************************************************************************************
*********************************PART 2 (NYTRIK-GFX)*************************************************
**********************************************************************************************
PART2
	BSR	CLS
	BSR	PAL_NOIR
	BSR	VBL
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	BSR	VBL
	CLR.L	D4
	MOVE.L	WORKECR,A2
	ADD.L	#2560+640+160,A2
	MOVE.W	#224,D7
LOOP22	
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#128,D3
	BNE.S	LOOP22
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	COMPT_FADE
SUITE55
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	SUITE55
	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	CLS
	BSR	REAL_PAL_NOIR
	BSR	CLR_REGISTERS

	CLR.L	$4D2
	CLR.W	$FFFF8240.W
	MOVE.L  #player,$4D2	 ; VBL
	CLR.W	$FFFF8240.W
	BSR	VBL
*affiche nain
	LEA	NAIN+34,A0
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.W	#7999,D0	
REP_NAIN
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	DBF	D0,REP_NAIN
	BSR	VBL
	PEA	NAIN
	MOVE.W	#0,-(SP)		;fade_in
	BSR	TRUE_FADE_OUT_NEW
	ADDQ.L	#6,SP
	PEA	NAIN+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	
	CLR.W	COMPT_FADE
REP3_NAIN
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	REP3_NAIN
	PEA	NAIN
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT_NEW
	ADDQ.L	#6,SP
	BSR	REAL_PAL_NOIR
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.L	#TIMER,$4D2.W
	RTS
**********************************************************************************************
*********************************PART 3 (SPLINE)**********************************************
**********************************************************************************************
PART3
	BSR	RESTORE_SCREEN
	BSR	PAL_NOIR
	BSR	VBL
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	CLR.L	D4
	MOVE.L	WORKECR,A2
	ADD.L	#5120+1280,A2
	MOVE.W	#480,D7
LOOP222	
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#96,D3
	BNE.S	LOOP222
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	COMPT_FADE
SUITE555
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	SUITE555
	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	BSR	CLS
	BSR	CLR_REGISTERS

*les splines FALCON ou ST ???
	CMPI.B	#1,FALCON
	BNE.S	NO_GOOD
	BSR	FALC_SPLINE2
	BRA.S	GOOD
NO_GOOD	
	BSR	SPLINE2
GOOD
	RTS
**********************************************************************************************
*********************************PART 4 (SAYA-GFX)**********************************************
**********************************************************************************************
PART4
	BSR	RESTORE_SCREEN
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	CLR.L	D4
	MOVE.L	WORKECR,A2
	ADD.L	#5120+2560+800,A2
	MOVE.W	#672,D7
LOOP2222	
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#96,D3
	BNE.S	LOOP2222
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	COMPT_FADE
SUITE5555
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	SUITE5555
	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	BSR	CLS
	BSR	CLR_REGISTERS
*affiche saya pic
	BSR	CLS
	BSR	RESTORE_SCREEN
	CLR.L	$4D2
	CLR.W	$FFFF8240.W
	MOVE.L  #player,$4D2	 ; VBL
	BSR	REAL_PAL_NOIR
	BSR	VBL
	LEA	IMAGE+34,A0
	MOVE.L	WORKECR,A1
	MOVE.L	AFFECR,A2
	MOVE.W	#7999,D0
OK100
	MOVE.L	(A0),(A1)+	
	MOVE.L	(A0)+,(A2)+	
	DBF	D0,OK100
	CLR.L	$4D2
	MOVE.L	#SAYA_TIMER,$4D2.W
	CLR.W	COMPT_FADE
REP3_SAYA
	ADDQ.W	#1,COMPT_FADE
	PEA	IMAGE+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	BSR	VBL
	CMPI.W	#411,COMPT_FADE
	BNE.S	REP3_SAYA
	MOVE.L	#TIMER,$4D2.W
	BSR	CLS
	BSR	PAL_NOIR
	BSR	CLR_REGISTERS
	RTS
**********************************************************************************************
*********************************PART 5 (3D LINES)**********************************************
**********************************************************************************************
PART5
	BSR	RESTORE_SCREEN
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	CLR.L	D4
	MOVE.L	WORKECR,A2
	ADD.L	#5120+2400,A2
	MOVE.W	#864,D7
LOOP224	
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#94,D3
	BNE.S	LOOP224
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	CLR.W	COMPT_FADE
SUITE554
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#411,COMPT_FADE
	BNE.S	SUITE554
	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	COOL_LINES
	RTS
************
**********************************************************************************************
*********************************PART 6 (DOTSBALL)**********************************************
**********************************************************************************************
PART6
	BSR	AFFI_GFX
	BSR	CLR_REGISTERS
	BSR	PAL_NOIR
	CLR.L	D4
	MOVE.L	WORKECR,A2
	ADD.L	#160,A2
	MOVE.W	#1056,D7
LOOP226
	ADDQ.L	#1,D4
	ADDQ.L	#1,D6
	BSR	PRINTING
	ADDQ.W	#1,D3
	CMPI.B	#160,D3
	BNE.S	LOOP226
	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVE.L	A1,AFFECR
	MOVE.L	A0,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	PEA	GFX
	MOVE.W	#0,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP

	CMPI.B	#1,FALCON
	BNE.S	NO_FALC12
	BSR	PRECALC_BALL_FALC
	CLR.W	COMPT_FADE
SUITE55555
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#211,COMPT_FADE
	BNE.S	SUITE55555
	BRA	TRALALA
NO_FALC12
	BSR	PRECALC_BALL
TRALALA

	PEA	GFX
	MOVE.W	#1,-(SP)
	BSR	TRUE_FADE_OUT
	ADDQ.L	#6,SP
	BSR	PAL_NOIR
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	RESTORE_SCREEN
	MOVE.W	#$FFF,$FFFF8242
	MOVE.W	#$FFF,$FFFF8244
	MOVE.W	#$FFF,$FFFF8246
	CMPI.B	#1,FALCON
	BNE.S	NO_FA12
	BSR	LOOP_BALL_FALC
	BRA	COCO
NO_FA12
	BSR	LOOP_BALL
COCO
	RTS
************
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
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
	subi.l #$9B00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	MOVE.L	A1,AFFINIT
	MOVE.L	A2,WORKINIT
	RTS

INIT_RAST:	
	and.b	#$40,$fffa09
	or.b	#1,$fffa07
	or.b	#1,$fffa13	
	RTS
SAVE_INTER
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	RTS

***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
PRECALC
	BSR	ZOOMER
	ADD.W	#6,COMPT
	CMPI.W	#314,XFACTEUR
	BHI.S	BIG
	ADDQ.W	#6,XFACTEUR
	ADDQ.W	#6,YFACTEUR
	MOVE.W	LIGNE,D2
	ADD.L	D2,ROZO
	MOVE.W	D2,(A5)+
	BRA	PRECALC
BIG
	RTS

AFF_ZOOM
	MOVE.L	#PREC,A1
	MOVE.L	WORKECR,A0
	LEA	12000(A0),A0
	ADD.L	ROZO,A1
	LSR	#2,D2
AF_ZOM
	MOVE.L	(A1)+,(A0)+
	DBF	D2,AF_ZOM
	RTS
EFFAZ
	MOVEM.L	A1/D1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ.W	#0,D0
	MOVEQ.W	#52,D1	
	LEA	12000(A1),A1
.EFFZ
	REPT	80
	MOVE.W	D0,(A1)+
	ENDR 	
	DBF	D1,.EFFZ	
	MOVEM.L	(SP)+,A1/D1
	RTS	
********************ZZZOOOOOOOOOOOOOOOOOOOOOOOMMMMMMMMMMMMMMMMMM**********************************
ZOOMER
;on prend les addresses de base(A5,A6,D1,D2)
	MOVE.L	A5,-(SP)
	MOVE.W	#160,LIGNE
	LEA	LOGO+34,A5
	MOVE.L	#PREC,A6
	ADD.L	ROZO,A6
	MOVE.W	Xfacteur,D1	;D1 compteur pour x
	MOVE.W	Yfacteur,D2	;D2 compteur pour y
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
	MOVEQ	#hauteur,D4	;D4 fait 40 lignes
	MOVEQ	#0,D5		;D5 compteur pour numero du pts image
;centre /x
	MOVE	#320,d6
	SUB.W	xFACTEUR,D6
	LSL.W	D6
;centre /y
;on fait le zoom
ZOOMER_Y
	ADD.W	yfacteur,D2	
	MOVE.W	#largeur,D3	;D3 fait les 320 pix
 	CMPI.W	#320,D2
	BLE	ZOOMER_X1
	ADD.W	#160,LIGNE
	LEA	160(A6),A6	;ligne ecran suivante
	SUBI.W	#320,D2
	MOVEM.L	D2/D4,-(SP)
ZOOMER_X
	ADD.W	xfacteur,D1	
	CMPI.W	#320,D1		;si facteur>320 affiche le point
	BLE.S	NO_POINT
	BSR.S	MAKE_POINT
	ADDQ.W	#1,D6		;point ecran suivant
	SUBI.W	#320,D1
NO_POINT
	ADDQ.W	#1,D5		;point image suivant
	DBF	D3,ZOOMER_X
	MOVEM.L	(SP)+,D2/D4
ZOOMER_X1
	MOVEQ	#0,D5		;remise a 0 pour nouvelle ligne
	MOVE	#320,d6		;centre les /x
	SUB.W	xFACTEUR,D6
	LSR.W	D6
	LEA	160(A5),A5	;ligne image suivante
	DBF	D4,ZOOMER_Y
	MOVE.L	(SP)+,A5
	RTS
;procedure chargee de voir quel point il faut afficher
MAKE_POINT
; conversion de coordonnees en adresse ecran
; les x	
	MOVE.W	D5,D2
	MOVE.W	D5,D7
	LSR.W	D2
	ANDI.W	#$FFF8,D2
; le decalage
	ANDI.W	#$F,D7			; decalage sur 16 pixels	
	LSL.W	#2,D7
	JMP	DECA_TABZ(PC,D7.W)
DECA_TABZ
	BRA	DACA0
	BRA	DACA1
	BRA	DACA2
	BRA	DACA3
	BRA	DACA4
	BRA	DACA5
	BRA	DACA6
	BRA	DACA7                                     
	BRA	DACA8
	BRA	DACA9
	BRA	DACA10
	BRA	DACA11
	BRA	DACA12
	BRA	DACA13
	BRA	DACA14
	BRA	DACA15
DACA0
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%10000000000000001000000000000000,D7
	ANDI.L	#%10000000000000001000000000000000,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA1
	MOVE.L	(A5,D2.W),D7
	MOVE.L 	4(A5,D2.W),D4
	ANDI.L	#%01000000000000000100000000000000,D7
	ANDI.L	#%01000000000000000100000000000000,D4
	ROL.L	#1,D7					
	ROL.L	#1,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA2
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00100000000000000010000000000000,D7
	ANDI.L	#%00100000000000000010000000000000,D4
	ROL.L	#2,D7					
	ROL.L	#2,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA3
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00010000000000000001000000000000,D7
	ANDI.L	#%00010000000000000001000000000000,D4
	ROL.L	#3,D7					
	ROL.L	#3,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA4
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00001000000000000000100000000000,D7
	ANDI.L	#%00001000000000000000100000000000,D4
	ROL.L	#4,D7					
	ROL.L	#4,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA5
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000100000000000000010000000000,D7
	ANDI.L	#%00000100000000000000010000000000,D4
	ROL.L	#5,D7					
	ROL.L	#5,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA6
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000010000000000000001000000000,D7
	ANDI.L	#%00000010000000000000001000000000,D4
	ROL.L	#6,D7					
	ROL.L	#6,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA7
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000001000000000000000100000000,D7
	ANDI.L	#%00000001000000000000000100000000,D4
	ROL.L	#7,D7					
	ROL.L	#7,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA8
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000100000000000000010000000,D7
	ANDI.L	#%00000000100000000000000010000000,D4
	ROL.L	#8,D7					
	ROL.L	#8,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA9
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000010000000000000001000000,D7
	ANDI.L	#%00000000010000000000000001000000,D4
	ROL.L	#8,D7					
	ROL.L	#1,D7
	ROL.L	#8,D4
	ROL.L	#1,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA10
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000001000000000000000100000,D7
	ANDI.L	#%00000000001000000000000000100000,D4
	ROL.L	#8,D7					
	ROL.L	#2,D7
	ROL.L	#8,D4
	ROL.L	#2,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA11
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000100000000000000010000,D7
	ANDI.L	#%00000000000100000000000000010000,D4
	ROL.L	#8,D7					
	ROL.L	#3,D7
	ROL.L	#8,D4
	ROL.L	#3,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT	
DACA12
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000010000000000000001000,D7
	ANDI.L	#%00000000000010000000000000001000,D4
	ROL.L	#8,D7					
	ROL.L	#4,D7
	ROL.L	#8,D4
	ROL.L	#4,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	JMP	AFFPOINT
DACA13
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000001000000000000000100,D7
 	ANDI.L	#%00000000000001000000000000000100,D4
	ROL.L	#8,D7					
	ROL.L	#5,D7
	ROL.L	#8,D4
	ROL.L	#5,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	ANDI.W	#$F,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	JMP	AFF_POINT(PC,D2.W)
	
DACA14
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000000100000000000000010,D7
	ANDI.L	#%00000000000000100000000000000010,D4
	ROL.L	#8,D7					
	ROL.L	#6,D7
	ROL.L	#8,D4
	ROL.L	#6,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	ANDI.W	#$F,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	JMP	AFF_POINT(PC,D2.W)
	
DACA15
	MOVE.L	(A5,D2.W),D7
	MOVE.L	4(A5,D2.W),D4
	ANDI.L	#%00000000000000010000000000000001,D7
	ANDI.L	#%00000000000000010000000000000001,D4
	ROL.L	#8,D7					
	ROL.L	#7,D7
	ROL.L	#8,D4
	ROL.L	#7,D4
	MOVE.W	D6,D0
	MOVE.W	D6,D2
	LSR.W	D0
	ANDI.W	#$FFF8,D0
	ANDI.W	#$F,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	JMP	AFF_POINT(PC,D2.W)	
*******************
AFFPOINT
	ANDI.W	#$F,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	JMP	AFF_POINT(PC,D2.W)	
AFF_POINT
	BRA	AFF0
	BRA	AFF1
	BRA	AFF2
	BRA	AFF3
	BRA	AFF4
	BRA	AFF5
	BRA	AFF6
	BRA	AFF7
	BRA	AFF8
	BRA	AFF9
	BRA	AFF10
	BRA	AFF11
	BRA	AFF12
	BRA	AFF13
	BRA	AFF14
	BRA	AFF15
AFF0
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF1
	ROR.L	#1,D7
	ROR.L	#1,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF2
	ROR.L	#2,D7
	ROR.L	#2,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF3
	ROR.L	#3,D7
	ROR.L	#3,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS

AFF4
	ROR.L	#4,D7
	ROR.L	#4,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS

AFF5
	ROR.L	#5,D7
	ROR.L	#5,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS

AFF6
	ROR.L	#6,D7
	ROR.L	#6,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS

AFF7
	ROR.L	#7,D7
	ROR.L	#7,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS

AFF8
	ROR.L	#8,D7
	ROR.L	#8,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF9
	ROR.L	#8,D7
	ROR.L	#1,D7
	ROR.L	#8,D4
	ROR.L	#1,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF10
	ROR.L	#8,D7
	ROR.L	#2,D7
	ROR.L	#8,D4
	ROR.L	#2,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF11
	ROR.L	#8,D7
	ROR.L	#3,D7
	ROR.L	#8,D4
	ROR.L	#3,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF12
	ROR.L	#8,D7
	ROR.L	#4,D7
	ROR.L	#8,D4
	ROR.L	#4,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF13
	ROR.L	#8,D7
	ROR.L	#5,D7
	ROR.L	#8,D4
	ROR.L	#5,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF14
	ROR.L	#8,D7
	ROR.L	#6,D7
	ROR.L	#8,D4
	ROR.L	#6,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
AFF15
	ROR.L	#8,D7
	ROR.L	#7,D7
	ROR.L	#8,D4
	ROR.L	#7,D4
	OR.L	D7,(A6,D0.W)
	OR.L	D4,4(A6,D0.W)
	RTS
GEN_MUS
	MOVE.W	#$4EB9,PLAYER
	MOVE.L	$4D2,PLAYER+2
	MOVE.W	#$4E75,PLAYER+6
	RTS

GEN_MUS_FIN
	MOVE.W	#$4EB9,PLAYER_FIN
	MOVE.L	$4D2,A0
	SUBQ.L	#4,A0
	MOVE.L	A0,PLAYER_FIN+2
	MOVE.W	#$4E75,PLAYER_FIN+6
	RTS

MAKE_SPLINE
	lea	SPLINE_X,a0
	moveq.w	#19,d1
MAKEX
	move.w	#359,d2
	lea	XCURV,a1
MAKEX2
	move.l	(a1)+,(a0)+
	dbf	d2,MAKEX2	
	dbf	d1,MAKEX
	lea	SPLINE_Y,a0
	moveq.w	#19,d1
MAKEY
	move.w	#359,d2
	lea	YCURV,a1
MAKEY2
	move.l	(a1)+,(a0)+
	dbf	d2,MAKEY2	
	dbf	d1,MAKEY
	rts
SHADE_COL
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

	RTS

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
TIMER
	MOVE.L	#TIMER_B1,$120.W	
	MOVE.B	#1,$FFFFFA21.W			
	MOVE.B	#8,$FFFFA1B		
	RTS

CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
PAL_NOIR
	MOVEM.L	D0/A1,-(SP)
	MOVEQ.W	#14,D0
	LEA	$FFFF8242,A1
BLEU2
	MOVE.W	#2,(A1)+
	DBF	D0,BLEU2
	BSR	VBL
	MOVEM.L	(SP)+,D0/A1
	RTS
REAL_PAL_NOIR
	MOVEM.L	D0/A1,-(SP)
	MOVEQ.W	#14,D0
	LEA	$FFFF8242,A1
NOIR
	CLR.W	(A1)+
	DBF	D0,NOIR
	BSR	VBL
	MOVEM.L	(SP)+,D0/A1
	RTS
CLS
	MOVEM.L	D0-D1/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l workecr,a1
	MOVEQ.L	#0,D1
	MOVE.W	#7999,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(A1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0-D1/A0-a1
	RTS
AFFI_GFX
	MOVEM.L	D0/A0-A2,-(SP)
	LEA	GFX+34,A0	
	MOVE.L	WORKECR,A2
	MOVE.W	#7999,D0
REP
	MOVE.L	(A0)+,(A2)+
	DBF	D0,REP	
	MOVEM.L	(SP)+,D0/A0-A2
	RTS
TIMER_B1	
	MOVE.W	#$2700,SR
	MOVE.W	#$2,$FFFF8240.W
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	MOVE.B	#198,$FFFFFA21.W			
	MOVE.B	#8,$FFFFA1B		
	MOVE.L	#TIMER_B2,$120.W	
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE
TIMER_B2
	MOVE.W	#$2700,SR
	MOVE.W	#$0,$FFFF8240.W
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	MOVEM.L	D0-D7/A0-A6,-(SP)
	JSR	PLAYER
	MOVEM.L	(SP)+,D0-D7/A0-A6
	BCLR	#0,$FFFFFA0F.W		
	MOVE.W	#$2300,SR	
	RTE	
*************************ROUTS TIMER_B POUR SAYA GFX**********************
SAYA_TIMER
	MOVE.L	#TIMER_IMG1,$120.W	; palette 2 et 3 grace au timer_B
	CLR	$FFFF8240.W
	CLR.B	$FFFFFA1B.W
	MOVE.B	#79,$FFFFFA21.W
	MOVE.B	#8,$FFFFA1B
	RTS

TIMER_IMG1:
	MOVE.W	#$2700,SR
	MOVE.W	#$301,$FFFF824A.W		; 5
	MOVE.W	#$411,$FFFF824C.W		; 6
	MOVE.W	#$521,$FFFF824E.W		; 7
	MOVE.W	#$454,$FFFF8250.W		; 8
	MOVE.W	#$117,$FFFF825A.W		; 13
	MOVE.W	#$342,$FFFF825C.W		; 14
	MOVE.W	#$761,$FFFF825E.W		; 15
	CLR.B	$FFFFFA21.W
	CLR.B	$FFFFFA1B.W
	MOVE.B	#2,$FFFFFA21.W			; palette 3 deux ligne apres la 2
	MOVE.B	#8,$FFFFA1B			; event count mod
	MOVE.L	#TIMER_IMG2,$120.W	
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE

TIMER_IMG2:	
	MOVE.W	#$2700,SR
	MOVE.W	#$631,$FFFF8250.W		; 8
	MOVE.W	#$654,$FFFF825A.W		; 13
	MOVE.W	#$741,$FFFF825C.W		; 14	
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	MOVEM.L	D0-D7/A0-A6,-(SP)
	JSR	PLAYER
	MOVEM.L	(SP)+,D0-D7/A0-A6
	BCLR	#0,$FFFFFA0F.W
	CLR.B	$FFFFA1B			
	MOVE.W	#$2300,SR
	RTE		
	
*******************************AFFICHE FONTE***********************
FONT:
	MOVE.L	(A0),(A2)
	MOVE.L	4(A0),4(A2)
	MOVE.L	160(A0),160(A2)
	MOVE.L	164(A0),164(A2)
	MOVE.L	320(A0),320(A2)
	MOVE.L	324(A0),324(A2)
	MOVE.L	480(A0),480(A2)
	MOVE.L	484(A0),484(A2)
	MOVE.L	640(A0),640(A2)
	MOVE.L	644(A0),644(A2)
	MOVE.L	800(A0),800(A2)
	MOVE.L	804(A0),804(A2)
	MOVE.L	960(A0),960(A2)
	MOVE.L	964(A0),964(A2)
	MOVE.L	1120(A0),1120(A2)
	MOVE.L	1124(A0),1124(A2)
	MOVE.L	1280(A0),1280(A2)
	MOVE.L	1284(A0),1284(A2)
	MOVE.L	1440(A0),1440(A2)
	MOVE.L	1444(A0),1444(A2)
	MOVE.L	1600(A0),1600(A2)
	MOVE.L	1604(A0),1604(A2)
	MOVE.L	1760(A0),1760(A2)
	MOVE.L	1764(A0),1764(A2)
	MOVE.L	1920(A0),1920(A2)
	MOVE.L	1924(A0),1924(A2)
	MOVE.L	2080(A0),2080(A2)
	MOVE.L	2084(A0),2084(A2)
	MOVE.L	2240(A0),2240(A2)
	MOVE.L	2244(A0),2244(A2)
	MOVE.L	2400(A0),2400(A2)
	MOVE.L	2404(A0),2404(A2)
	RTS
***************REALTIME_FADE_OUT ROUTINE*******
SPLINE_FADE_OUT
	MOVEM.L	D0-D3/A0,-(SP)
	ADDQ.B	#1,COMPT_F2
	CMPI.B	#2,COMPT_F2
	BNE.S	COMPT_NO
	CLR.B	COMPT_F2
	JMP	COMPT_NO2
COMPT_NO
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3

	MOVEQ.W	#3,D0			; dec les 3 couls
ROUGE
	MOVE.W	(A0),D1
	ANDI.W	#$700,D1
	ROR.W	#8,D1
VERT
	MOVE.W	(A0),D2
	ANDI.W	#$070,D2
	ROR.W	#4,D2
BLEU
	MOVE.W	(A0),D3
	ANDI.W	#$007,D3
	CLR.W	(A0)	

	CMPI.B	#0,D1
	BEQ.S	R
	SUBQ.W	#1,D1			; sauvegarde les new colors
	ROL.W	#8,D1
	OR.W	D1,(A0)	

R	CMPI.B	#0,D2
	BEQ.S	V
	SUBQ.W	#1,D2
	ROL.W	#4,D2
	OR.W	D2,(A0)	
	
V	CMPI.B	#2,D3
	BEQ.S	B
	SUBQ.W	#1,D3
	OR.W	D3,(A0)	

B	OR.W	D3,(A0)	
	ADDQ.L	#2,A0			; passe a coul suivante
	DBF	D0,ROUGE
COMPT_NO2
	MOVEM.L	(SP)+,D0-D3/A0
	RTS	                                                      
********************************************************************************
**************************LA routine de sprites*********************************
SPRITE2	
	MOVEQ.W	#0,D3
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
       	LEA	XHDX,A2			; pointe sur x 
	LEA	YHDX,A3			; pointe sur y
	ADD.L	D1,A2
	ADD.W	D6,A3
	MOVE.B	(A3,D7.W),D3		; y en d3
	ADD.W	D7,D7			;d7*2
	MOVE.W	(A2,D7.W),D2		; x en d2
	MOVE.W	D2,D4			; sauve d2 pour decalage
	LSR.W	D7			;d7/2 pour le recuperer
; conversion de coordonnees en adresse ecran
; les x
	LSR.W	D2				
	ANDI.W	#$FFF8,D2
	ADD.W	D2,A1	
; les y
	LEA	Y_TABLE,A2
	ADD.W	D3,D3
	ADD.W	(A2,D3.W),A1
; le decalage
	ANDI.W	#$F,D4			; decalage sur 16 pixels
	JMP	SCHMOLL
SPRITE	
	MOVEQ.W	#0,D3
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
	MOVE.L	X,A2			; pointe sur x 
	MOVE.L	Y,A3			; pointe sur y
	ADD.W	D6,A2
	ADD.W	D6,A3
	MOVE.B	(A2,D7.W),D2		; x en d2
	MOVE.B	D2,D4			; sauve d2 pour decalage
	MOVE.B	(A3,D7.W),D3		; y en d3
; conversion de coordonnees en adresse ecran
; les x
	LSR.B	D2				
	ANDI.B	#$F8,D2
	ADD.W	D2,A1	
; les y
	LEA	Y_TABLE,A2
	ADD.W	D3,D3
	ADD.W	(A2,D3.W),A1
; le decalage
	ANDI.B	#$F,D4			; decalage sur 16 pixels	
******************************POUR LE CALCUL DU DECALAGE**************
SCHMOLL
	ASL.W	#2,D4
	JMP	DECA_TAB(PC,D4.W)
DECA_TAB
	BRA	DECA0
	BRA	DECA1
	BRA	DECA2
	BRA	DECA3
	BRA	DECA4
	BRA	DECA5
	BRA	DECA6
	BRA	DECA7                                     
	BRA	DECA8
	BRA	DECA9
	BRA	DECA10
	BRA	DECA11
	BRA	DECA12
	BRA	DECA13
	BRA	DECA14
	BRA	DECA15
******************les decalages du sprite*********************
; c'est ce qu'on appelle du code de barbare !!!

DECA0
	ORI.W	#896,(A1)
	ORI.W	#1984,160(A1)
	ORI.W	#1984,320(A1)
	ORI.W	#1984,480(A1)
	ORI.W	#896,640(A1)
	RTS
DECA1
	ORI.W	#448,(A1)
	ORI.W	#992,160(A1)
	ORI.W	#992,320(A1)
	ORI.W	#992,480(A1)
	ORI.W	#448,640(A1)
	RTS	
DECA2
	ORI.W	#224,(A1)
	ORI.W	#496,160(A1)
	ORI.W	#496,320(A1)
	ORI.W	#496,480(A1)
	ORI.W	#224,640(A1)
	RTS
DECA3
	ORI.W	#112,(A1)
	ORI.W	#248,160(A1)
	ORI.W	#248,320(A1)
	ORI.W	#248,480(A1)
	ORI.W	#112,640(A1)
	RTS
DECA4
	ORI.B	#56,1(A1)
	ORI.B	#124,161(A1)
	ORI.B	#124,321(A1)
	ORI.B	#124,481(A1)
	ORI.B	#56,641(A1)
	RTS
DECA5
	ORI.B	#28,1(A1)
	ORI.B	#62,161(A1)
	ORI.B	#62,321(A1)
	ORI.B	#62,481(A1)
	ORI.B	#28,641(A1)
	RTS
DECA6
	ORI.B	#14,1(A1)
	ORI.B	#31,161(A1)
	ORI.B	#31,321(A1)
	ORI.B	#31,481(A1)
	ORI.B	#14,641(A1)
	RTS
DECA7
	ORI.B	#7,1(A1)
	ORI.B	#15,161(A1)
	ORI.W	#32768,168(A1)
	ORI.B	#15,321(A1)
	ORI.W	#32768,328(A1)
	ORI.B	#15,481(A1)
	ORI.W	#32768,488(A1)
	ORI.B	#7,641(A1)
	RTS
DECA8
	ORI.B	#3,1(A1)
	ORI.W	#32768,8(A1)
	ORI.B	#7,161(A1)
	ORI.W	#49152,168(A1)
	ORI.B	#7,321(A1)
	ORI.W	#49152,328(A1)
	ORI.B	#7,481(A1)
	ORI.W	#49152,488(A1)
	ORI.B	#3,641(A1)
	ORI.W	#32768,648(A1)
	RTS
DECA9
	ORI.B	#1,1(A1)
	ORI.W	#49152,8(A1)
	ORI.B	#7,161(A1)
	ORI.W	#49152,168(A1)
	ORI.B	#7,321(A1)
	ORI.W	#49152,328(A1)
	ORI.B	#7,481(A1)
	ORI.W	#49152,488(A1)
	ORI.B	#3,641(A1)
	ORI.W	#32768,648(A1)
	RTS
DECA10
	ORI.W	#57344,8(A1)
	ORI.B	#1,161(A1)
	ORI.W	#61440,168(A1)
	ORI.B	#1,321(A1)
	ORI.W	#61440,328(A1)
	ORI.B	#1,481(A1)
	ORI.W	#61440,488(A1)
	ORI.W	#57344,648(A1)
	RTS
DECA11
	ORI.W	#28672,8(A1)
	ORI.W	#63488,168(A1)
	ORI.W	#63488,328(A1)
	ORI.W	#63488,488(A1)
	ORI.W	#28672,648(A1)
	RTS
DECA12
	ORI.W	#14336,8(A1)
	ORI.W	#31744,168(A1)
	ORI.W	#31744,328(A1)
	ORI.W	#31744,488(A1)
	ORI.W	#14336,648(A1)
	RTS
DECA13
	ORI.W	#7168,8(A1)
	ORI.W	#15872,168(A1)
	ORI.W	#15872,328(A1)
	ORI.W	#15872,488(A1)
	ORI.W	#7168,648(A1)
	RTS
DECA14
	ORI.W	#3584,8(A1)
	ORI.W	#7936,168(A1)
	ORI.W	#7936,328(A1)
	ORI.W	#7936,488(A1)
	ORI.W	#3584,648(A1)
	RTS
DECA15
	ORI.W	#1792,8(A1)
	ORI.W	#3968,168(A1)
	ORI.W	#3968,328(A1)
	ORI.W	#3968,488(A1)
	ORI.W	#1792,648(A1)
	RTS
******************************************************************************************
**************************LINE ROUT*******************************************************
******************************************************************************************
COOL_LINES
	BSR	PAL_NOIR
	BSR	CLR_REGISTERS
	BSR	CLS
	BSR	RESTORE_SCREEN
	CLR	COMPT_FADE
LOOP
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT3
 	move.w 	#$700,$ffff8240.w
NO_ALT3
	bsr	EFFA_LINE
	cmpi.b 	#56,$fffffc02
 	bne 	NO_ALT2
 	move.w 	#$70,$ffff8240.w	
NO_ALT2
	bsr	READ_CURVE
	bsr	TRACE_LIGNES
	lea.l colors4,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee_line		; on boucle
 	subq.w #8,affecr+2
trainee_line
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_AL
 	move.w 	#$7,$ffff8240.w
NO_AL
	bsr	VBL
	addq.w	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE2
	lea	COLORS4,a0
	BSR	SPLINE_FADE_OUT
NO_FADE2
	cmpi.W	#560,COMPT_FADE
	ble	LOOP
	BSR	PAL_NOIR
	CLR	COMPT
	BSR	CLR_REGISTERS
	BSR	CLS
	BSR	RESTORE_SCREEN
	CLR	COMPT_FADE
LOOP_2
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT32
 	move.w 	#$700,$ffff8240.w
NO_ALT32
	bsr	EFFA_LINE
	cmpi.b 	#56,$fffffc02
 	bne 	NO_ALT22
 	move.w 	#$70,$ffff8240.w	
NO_ALT22
	bsr	READ_CURVE2
	bsr	TRACE_LIGNES2
	lea.l colors5,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee_line2		; on boucle
 	subq.w #8,affecr+2
trainee_line2
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT_2
 	move.w 	#$7,$ffff8240.w
NO_ALT_2
	bsr	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE23
	lea	COLORS5,a0
	BSR	SPLINE_FADE_OUT
NO_FADE23
	cmpi.W	#560,COMPT_FADE
	bne	LOOP_2

	BSR	PAL_NOIR
	CLR	COMPT
	BSR	CLR_REGISTERS
	BSR	CLS
	BSR	RESTORE_SCREEN
	CLR	COMPT_FADE

LOOP_3
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT33
 	move.w 	#$700,$ffff8240.w
NO_ALT33
	bsr	EFFA_LINE
	cmpi.b 	#56,$fffffc02
 	bne 	NO_ALT23
 	move.w 	#$70,$ffff8240.w	
NO_ALT23
	bsr	READ_CURVE3
	bsr	TRACE_LIGNES3
	lea.l colors6,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee_line3		; on boucle
 	subq.w #8,affecr+2
trainee_line3
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT_3
 	move.w 	#$7,$ffff8240.w
NO_ALT_3
	bsr	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE25
	lea	COLORS6,a0
	BSR	SPLINE_FADE_OUT
NO_FADE25
	cmpi.W	#560,COMPT_FADE
	bne	LOOP_3
	BSR	PAL_NOIR
	BSR	CLR_REGISTERS
	BSR	CLS
	BSR	RESTORE_SCREEN
	rts

*/*/*/*/*/*/*/
TRACE_LIGNES
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+2,CX2
	move.w	DY+2,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+4,CX2
	move.w	DY+4,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
 	bsr	LINE
	move.w	DX+6,CX1
	move.w	DY+6,CY1
	move.w	DX+8,CX2
	move.w	DY+8,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+12,CX2
	move.w	DY+12,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
*
	move.w	DX+16,CX1
	move.w	DY+16,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+16,CX1
	move.w	DY+16,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+20,CX1
	move.w	DY+20,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+22,CX1
	move.w	DY+22,CY1
	move.w	DX+24,CX2
	move.w	DY+24,CY2
 	bsr	LINE
	move.w	DX+20,CX1
	move.w	DY+20,CY1
	move.w	DX+30,CX2
	move.w	DY+30,CY2
 	bsr	LINE
	move.w	DX+24,CX1
	move.w	DY+24,CY1
	move.w	DX+26,CX2
	move.w	DY+26,CY2
 	bsr	LINE
	move.w	DX+24,CX1
	move.w	DY+24,CY1
	move.w	DX+30,CX2
	move.w	DY+30,CY2
 	bsr	LINE
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+28,CX2
	move.w	DY+28,CY2
 	bsr	LINE
	move.w	DX+16,CX1
	move.w	DY+16,CY1
	move.w	DX+26,CX2
	move.w	DY+26,CY2
 	bsr	LINE
	move.w	DX+28,CX1
	move.w	DY+28,CY1
	move.w	DX+26,CX2
	move.w	DY+26,CY2
 	bsr	LINE
	move.w	DX+28,CX1
	move.w	DY+28,CY1
	move.w	DX+30,CX2
	move.w	DY+30,CY2
 	bsr	LINE
	CMPI.B	#1,FALCON
	BNE	NO_GOOD_CUBE
*sur F30
	move.w	DX+14,CX1
	move.w	DY+14,CY1
	move.w	DX+30,CX2
	move.w	DY+30,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+28,CX2
	move.w	DY+28,CY2
 	bsr	LINE
	move.w	DX+10,CX1
	move.w	DY+10,CY1
	move.w	DX+26,CX2
	move.w	DY+26,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+24,CX2
	move.w	DY+24,CY2
 	bsr	LINE
	move.w	DX+6,CX1
	move.w	DY+6,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
 	bsr	LINE
NO_GOOD_CUBE
	rts
READ_CURVE
	MOVEM.L	D1/A0-A1,-(SP)
	lea	X_CURVE,a0
	lea	Y_CURVE,a1
	addq.w	#1,compt
	cmpi.w	#360,compt
	bne.s	SUITE_LINE
	clr.w	compt
SUITE_LINE
	move.w	compt,d1
	add	d1,d1
	move.w	(a0,d1.w),DX
	move.w	(a1,d1.w),DY
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+2
	move.w	(a1,d1.w),DY+2
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+4
	move.w	(a1,d1.w),DY+4
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+6
	move.w	(a1,d1.w),DY+6
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+8
	move.w	(a1,d1.w),DY+8
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+10
	move.w	(a1,d1.w),DY+10
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+12
	move.w	(a1,d1.w),DY+12
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+14
	move.w	(a1,d1.w),DY+14
*
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+16
	move.w	(a1,d1.w),DY+16
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+18
	move.w	(a1,d1.w),DY+18
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+20
	move.w	(a1,d1.w),DY+20
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+22
	move.w	(a1,d1.w),DY+22
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+24
	move.w	(a1,d1.w),DY+24
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+26
	move.w	(a1,d1.w),DY+26
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+28
	move.w	(a1,d1.w),DY+28
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+30
	move.w	(a1,d1.w),DY+30
	MOVEM.L	(SP)+,D1/A0-A1
	rts
TRACE_LIGNES3
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+2,CX2
	move.w	DY+2,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+4,CX2
	move.w	DY+4,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+2,CX2
	move.w	DY+2,CY2
	BSR	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
	BSR	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
	BSR	LINE
	move.w	DX+14,CX1
	move.w	DY+14,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
	BSR	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
	BSR	LINE
	move.w	DX+10,CX1
	move.w	DY+10,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
	BSR	LINE
*
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
	BSR	LINE
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
	BSR	LINE
	move.w	DX+24,CX1
	move.w	DY+24,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
	BSR	LINE
	move.w	DX+20,CX1
	move.w	DY+20,CY1
	move.w	DX+24,CX2
	move.w	DY+24,CY2
	BSR	LINE
****	
	move.w	DX+26,CX1
	move.w	DY+26,CY1
	move.w	DX+28,CX2
	move.w	DY+28,CY2
 	bsr	LINE
	move.w	DX+26,CX1
	move.w	DY+26,CY1
	move.w	DX+30,CX2
	move.w	DY+30,CY2
 	bsr	LINE
	move.w	DX+38,CX1
	move.w	DY+38,CY1
	move.w	DX+28,CX2
	move.w	DY+28,CY2
	BSR	LINE
	move.w	DX+30,CX1
	move.w	DY+30,CY1
	move.w	DX+32,CX2
	move.w	DY+32,CY2
	BSR	LINE
	move.w	DX+38,CX1
	move.w	DY+38,CY1
	move.w	DX+32,CX2
	move.w	DY+32,CY2
	BSR	LINE
	move.w	DX+40,CX1
	move.w	DY+40,CY1
	move.w	DX+42,CX2
	move.w	DY+42,CY2
	BSR	LINE
	move.w	DX+34,CX1
	move.w	DY+34,CY1
	move.w	DX+40,CX2
	move.w	DY+40,CY2
	BSR	LINE
	move.w	DX+36,CX1
	move.w	DY+36,CY1
	move.w	DX+42,CX2
	move.w	DY+42,CY2
	BSR	LINE
*
	move.w	DX+44,CX1
	move.w	DY+44,CY1
	move.w	DX+46,CX2
	move.w	DY+46,CY2
	BSR	LINE
	move.w	DX+44,CX1
	move.w	DY+44,CY1
	move.w	DX+48,CX2
	move.w	DY+48,CY2
	BSR	LINE
	move.w	DX+50,CX1
	move.w	DY+50,CY1
	move.w	DX+48,CX2
	move.w	DY+48,CY2
	BSR	LINE
	move.w	DX+46,CX1
	move.w	DY+46,CY1
	move.w	DX+50,CX2
	move.w	DY+50,CY2
	BSR	LINE
*****
	move.w	DX+26,CX1
	move.w	DY+26,CY1
	move.w	DX,CX2
	move.w	DY,CY2
 	bsr	LINE
	move.w	DX+28,CX1
	move.w	DY+28,CY1
	move.w	DX+2,CX2
	move.w	DY+2,CY2
 	bsr	LINE
	move.w	DX+30,CX1
	move.w	DY+30,CY1
	move.w	DX+4,CX2
	move.w	DY+4,CY2
	BSR	LINE
	move.w	DX+32,CX1
	move.w	DY+32,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
	BSR	LINE
	move.w	DX+34,CX1
	move.w	DY+34,CY1
	move.w	DX+8,CX2
	move.w	DY+8,CY2
	BSR	LINE
	move.w	DX+36,CX1
	move.w	DY+36,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
	BSR	LINE
	move.w	DX+38,CX1
	move.w	DY+38,CY1
	move.w	DX+12,CX2
	move.w	DY+12,CY2
	BSR	LINE
	rts
READ_CURVE3
	MOVEM.L	D1/A0-A1,-(SP)
	lea	X_CURVE3,a0
	lea	Y_CURVE3,a1
	addq.w	#1,compt
	cmpi.w	#360,compt
	bne.s	SUITE_LINE3
	clr.w	compt
SUITE_LINE3
	move.w	compt,d1
	add	d1,d1
	move.w	(a0,d1.w),DX
	move.w	(a1,d1.w),DY
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+2
	move.w	(a1,d1.w),DY+2
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+4
	move.w	(a1,d1.w),DY+4
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+6
	move.w	(a1,d1.w),DY+6
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+8
	move.w	(a1,d1.w),DY+8
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+10
	move.w	(a1,d1.w),DY+10
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+12
	move.w	(a1,d1.w),DY+12
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+14
	move.w	(a1,d1.w),DY+14
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+16
	move.w	(a1,d1.w),DY+16
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+18
	move.w	(a1,d1.w),DY+18
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+20
	move.w	(a1,d1.w),DY+20
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+22
	move.w	(a1,d1.w),DY+22
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+24
	move.w	(a1,d1.w),DY+24
*
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+26
	move.w	(a1,d1.w),DY+26
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+28
	move.w	(a1,d1.w),DY+28
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+30
	move.w	(a1,d1.w),DY+30
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+32
	move.w	(a1,d1.w),DY+32
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+34
	move.w	(a1,d1.w),DY+34
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+36
	move.w	(a1,d1.w),DY+36
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+38
	move.w	(a1,d1.w),DY+38
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+40
	move.w	(a1,d1.w),DY+40
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+42
	move.w	(a1,d1.w),DY+42
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+44
	move.w	(a1,d1.w),DY+44
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+46
	move.w	(a1,d1.w),DY+46
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+48
	move.w	(a1,d1.w),DY+48
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+50
	move.w	(a1,d1.w),DY+50
	movem.l	(sp)+,D1/A0-A1
	rts
FULL	
	move.l	workecr,a0
	move.l	affecr,a1
	move.w	#7999,d0
OKFULL
	MOVE.L	#$FFFFFFFF,(A0)+
	MOVE.L	#$FFFFFFFF,(A1)+
	DBF	D0,OKFULL
	rts
**********************CLS ROUT*****************************************
;sur ST
EFFA_LINE
	MOVEM.L	A1/D1,-(SP)
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
	MOVEQ.W	#0,D0
	ADD.W	#32,A1
	MOVE.W	#11,D1
EFF
OXO	SET	2240
	REPT	174
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+160
	ENDR
	ADDQ.W	#8,A1
	DBF	D1,EFF
	MOVEM.L	(SP)+,A1/D1
	RTS
TRACE_LIGNES2
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+2,CX2
	move.w	DY+2,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+4,CX2
	move.w	DY+4,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+6,CX2
	move.w	DY+6,CY2
 	bsr	LINE
	move.w	DX+6,CX1
	move.w	DY+6,CY1
	move.w	DX+8,CX2
	move.w	DY+8,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+12,CX2
	move.w	DY+12,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+10,CX2
	move.w	DY+10,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+14,CX2
	move.w	DY+14,CY2
 	bsr	LINE
*les branches de l'etoile
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
 	bsr	LINE
	move.w	DX+14,CX1
	move.w	DY+14,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+16,CX2
	move.w	DY+16,CY2
 	bsr	LINE
	move.w	DX+10,CX1
	move.w	DY+10,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX+6,CX1
	move.w	DY+6,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+18,CX2
	move.w	DY+18,CY2
 	bsr	LINE
	move.w	DX+6,CX1
	move.w	DY+6,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+14,CX1
	move.w	DY+14,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+4,CX1
	move.w	DY+4,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+8,CX1
	move.w	DY+8,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+2,CX1
	move.w	DY+2,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX,CX1
	move.w	DY,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+10,CX1
	move.w	DY+10,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+12,CX1
	move.w	DY+12,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
*
	CMPI.B	#1,FALCON
	BNE	NO_GOOD_STAR
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+16,CX1
	move.w	DY+16,CY1
	move.w	DX+22,CX2
	move.w	DY+22,CY2
 	bsr	LINE
	move.w	DX+16,CX1
	move.w	DY+16,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
	move.w	DX+18,CX1
	move.w	DY+18,CY1
	move.w	DX+20,CX2
	move.w	DY+20,CY2
 	bsr	LINE
NO_GOOD_STAR
	rts
READ_CURVE2
	MOVEM.L	D1/A0-A1,-(SP)
	lea	X_CURVE2,a0
	lea	Y_CURVE2,a1
	addq.w	#1,compt
	cmpi.w	#360,compt
	bne.s	SUITE_LINE2
	clr.w	compt
SUITE_LINE2
	move.w	compt,d1
	add	d1,d1
	move.w	(a0,d1.w),DX
	move.w	(a1,d1.w),DY
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+2
	move.w	(a1,d1.w),DY+2
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+4
	move.w	(a1,d1.w),DY+4
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+6
	move.w	(a1,d1.w),DY+6
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+8
	move.w	(a1,d1.w),DY+8
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+10
	move.w	(a1,d1.w),DY+10
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+12
	move.w	(a1,d1.w),DY+12
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+14
	move.w	(a1,d1.w),DY+14
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+16
	move.w	(a1,d1.w),DY+16
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+18
	move.w	(a1,d1.w),DY+18
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+20
	move.w	(a1,d1.w),DY+20
	lea	370*2(a0),a0
	lea	370*2(a1),a1
	move.w	(a0,d1.w),DX+22
	move.w	(a1,d1.w),DY+22
	movem.l	(sp)+,d1/a0-a1
	rts
LOOP_BALL
	CLR.W	COMPT_FADE
LOOP_BALL2
	BSR	EFFA
	MOVEQ.W	#0,D4
	BSR	REBOND_BALL
	MOVE.W	COMPT,D2
	MOVE.W	D2,CURVE_COMPT
	BSR	AFF_DOTS
	MOVE.W	CURVE_COMPT,D2
	MOVE.W	D2,COMPT

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT_BALL
	MOVE.W	#5,$FFFF8240
NO_ALT_BALL
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#720,COMPT_FADE
	BLE	LOOP_BALL2
	RTS
******************************************************************************************
******************************SPLINE ROUT*************************************************
******************************************************************************************
**********************************
*******************
nbdots=		585
offsetx2=	4		
offsety2=	2		
speedx2	=	2
speedy2	=	2
*******************
*******************
nbdots2=	575
offsetx3=	4		
offsety3=	2		
speedx3	=	18
speedy3	=	2
*******************
*******************
offsetx4=	4		
offsety4=	4		
speedx4	=	18
speedy4	=	2
*******************
*******************
offsetx5=	4		
offsety5=	2		
speedx5	=	20
speedy5	=	20
*******************
*******************
offsetx6=	4		
offsety6=	2		
speedx6	=	18
speedy6	=	10
*******************
nbdots3	=	1000
SPLINE2
	BSR	MAKE_SPLINE
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
SPLINE_LOOP2
	CMPI.W	#2,COMPT_FADE
	BHI.S	NO_EFFA
	bsr	EFFA
NO_EFFA
	BSR	EFFA2	
	CMPI.B	#2,PAR
	BNE.S	NO_PAR	
	CLR.B	PAR
	LEA	SAVE_POINT,A6
	BRA.S	PAR_NO
NO_PAR
	LEA	SAVE_POINT2,A6
PAR_NO
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump2
	move.w	#0,pos
jump2
	move.w	#nbdots,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
Plot2	
	addq.w	#speedx2,a1		; vitesse increment x 
	addq.w	#speedy2,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx2,d4		; ecart entre x
	lsl.w	#offsety2,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	MOVE.W	D5,(A6)+
	DBF	D7,PLOT2	

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b  affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE22
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
NO_FADE22
	cmpi.b	#56,$fffffc02
	bne.s	ALT3
	MOVE.W	#5,$FFFF8240.W
ALT3
	CMPI.W	#550,COMPT_FADE
	BEQ.S	SPLINE3
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	SPLINE_LOOP2 
**********************************
SPLINE3
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
SPLINE_LOOP3
	CMPI.W	#2,COMPT_FADE
	BHI.S	NO_EFFA22
	bsr	EFFA
NO_EFFA22
	BSR	EFFA2	
	CMPI.B	#2,PAR
	BNE.S	NO_PAR2	
	CLR.B	PAR
	LEA	SAVE_POINT,A6
	BRA.S	PAR_NO2
NO_PAR2
	LEA	SAVE_POINT2,A6
PAR_NO2
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump3
	move.w	#0,pos
jump3
	move.w	#nbdots,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
Plot3	
	lea	18(a1),a1		; vitesse increment x 
	addq.w	#speedy3,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx3,d4		; ecart entre x
	lsl.w	#offsety3,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	MOVE.W	D5,(A6)+ 
	dbf	d7,plot3	
	BSR	COLOR_SWITCH

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE3
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
NO_FADE3
	cmpi.b	#56,$fffffc02
	bne.s	ALT4
	MOVE.W	#5,$FFFF8240.W
ALT4
	CMPI.W	#550,COMPT_FADE
	BEQ	SPLINE4
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	SPLINE_LOOP3
**********************************
SPLINE4
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
SPLINE_LOOP4
	CMPI.W	#2,COMPT_FADE
	BHI.S	NO_EFFA3
	bsr	EFFA
NO_EFFA3
	BSR	EFFA3
	CMPI.B	#2,PAR
	BNE.S	NO_PAR3	
	CLR.B	PAR
	LEA	SAVE_POINT,A6
	BRA.S	PAR_NO3
NO_PAR3
	LEA	SAVE_POINT2,A6
PAR_NO3
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump4
	move.w	#0,pos
jump4
	move.w	#nbdots2,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
Plot4	
	lea	18(a1),a1		; vitesse increment x 
	addq.w	#speedy4,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx4,d4		; ecart entre x
	lsl.w	#offsety4,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	MOVE.W	D5,(A6)+
	dbf	d7,plot4	

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE4
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
NO_FADE4
	cmpi.b	#56,$fffffc02
	bne.s	ALT5
	MOVE.W	#5,$FFFF8240.W
ALT5
	CMPI.W	#550,COMPT_FADE
	BEQ	SPLINE5	
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	SPLINE_LOOP4
**********************************
SPLINE5
	BSR	RESTORE_SCREEN
	MOVE.B	#0,PAR	
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
SPLINE_LOOP5
	CMPI.W	#2,COMPT_FADE
	BHI.S	NO_EFFA4
	bsr	EFFA
NO_EFFA4
	BSR	EFFA2	
	CMPI.B	#2,PAR
	BNE.S	NO_PAR4
	CLR.B	PAR
	LEA	SAVE_POINT,A6
	BRA.S	PAR_NO4
NO_PAR4
	LEA	SAVE_POINT2,A6
PAR_NO4
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump5
	move.w	#0,pos
jump5
	move.w	#nbdots,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
Plot5	
	lea	20(a1),a1		; vitesse increment x 
	lea	20(a2),a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx5,d4		; ecart entre x
	lsl.w	#offsety5,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	MOVE.W	D5,(A6)+
	dbf	d7,plot5
	BSR	COLOR_SWITCH

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE5
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
NO_FADE5
	cmpi.b	#56,$fffffc02
	bne.s	ALT6
	MOVE.W	#5,$FFFF8240.W
ALT6
	CMPI.W	#550,COMPT_FADE
	BEQ	SPLINE6
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	SPLINE_LOOP5
**********************************
SPLINE6
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.B	#0,PAR	
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
SPLINE_LOOP6
	CMPI.W	#2,COMPT_FADE
	BHI.S	NO_EFFA5
	bsr	EFFA
NO_EFFA5
	BSR	EFFA2	
	CMPI.B	#2,PAR
	BNE.S	NO_PAR5
	CLR.B	PAR
	LEA	SAVE_POINT,A6
	BRA.S	PAR_NO5
NO_PAR5
	LEA	SAVE_POINT2,A6
PAR_NO5
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump6
	move.w	#0,pos
jump6
	move.w	#nbdots,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
Plot6
	lea	18(a1),a1		; vitesse increment x 
	lea	10(a2),a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx6,d4		; ecart entre x
	lsl.w	#offsety6,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d4.w),d2		;on point sur tabx
	move.w	(a2,d5.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	MOVE.W	D5,(A6)+
	dbf	d7,plot6
	BSR	COLOR_SWITCH

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	NO_FADE6
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
NO_FADE6
	cmpi.b	#56,$fffffc02
	bne.s	ALT7
	MOVE.W	#5,$FFFF8240.W
ALT7
	CMPI.W	#550,COMPT_FADE
	BEQ	END_PART2	
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	SPLINE_LOOP6
END_PART2
	RTS
*******************************************
******SPLINES SUR FALCON*******************
*******************************************
FALC_SPLINE2
	BSR	MAKE_SPLINE
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
FALC_SPLINE_LOOP2
	BSR	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	FALC_jump2
	move.w	#0,pos
FALC_jump2
	move.w	#nbdots3,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
FALC_Plot2	
	addq.w	#speedx2,a1		; vitesse increment x 
	addq.w	#speedy2,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx2,d4		; ecart entre x
	lsl.w	#offsety2,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	DBF	D7,FALC_PLOT2	

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b  affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	FALC_NO_FADE22
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
FALC_NO_FADE22
	cmpi.b	#56,$fffffc02
	bne.s	FALC_ALT3
	MOVE.W	#5,$FFFF8240.W
FALC_ALT3
	CMPI.W	#550,COMPT_FADE
	BEQ.S	FALC_SPLINE3
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	FALC_SPLINE_LOOP2 
****************************
FALC_SPLINE3
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
FALC_SPLINE_LOOP3
	BSR	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	FALC_jump3
	move.w	#0,pos
FALC_jump3
	move.w	#nbdots3,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
FALC_Plot3
	add.w	#speedx3,a1		; vitesse increment x 
	addq.w	#speedy3,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx3,d4		; ecart entre x
	lsl.w	#offsety3,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	DBF	D7,FALC_PLOT3

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b  affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	FALC_NO_FADE23
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
FALC_NO_FADE23
	cmpi.b	#56,$fffffc02
	bne.s	FALC_ALT4
	MOVE.W	#5,$FFFF8240.W
FALC_ALT4
	CMPI.W	#550,COMPT_FADE
	BEQ.S	FALC_SPLINE4
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	FALC_SPLINE_LOOP3 
****************************
FALC_SPLINE4
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
FALC_SPLINE_LOOP4
	BSR	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	FALC_jump4
	move.w	#0,pos
FALC_jump4
	move.w	#nbdots3,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
FALC_Plot4
	add.w	#speedx4,a1		; vitesse increment x 
	addq.w	#speedy4,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx4,d4		; ecart entre x
	lsl.w	#offsety4,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	DBF	D7,FALC_PLOT4

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b  affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	FALC_NO_FADE24
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
FALC_NO_FADE24
	cmpi.b	#56,$fffffc02
	bne.s	FALC_ALT5
	MOVE.W	#5,$FFFF8240.W
FALC_ALT5
	CMPI.W	#550,COMPT_FADE
	BEQ.S	FALC_SPLINE5
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	FALC_SPLINE_LOOP4 
****************************
FALC_SPLINE5
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.B	#0,PAR	
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
FALC_SPLINE_LOOP5
	BSR	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	FALC_jump5
	move.w	#0,pos
FALC_jump5
	move.w	#nbdots3,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
FALC_Plot5
	add.w	#speedx5,a1		; vitesse increment x 
	add.w	#speedy5,a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx5,d4		; ecart entre x
	lsl.w	#offsety5,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d5.w),d2		;on point sur tabx
	move.w	(a2,d4.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	DBF	D7,FALC_PLOT5

	BSR	COLOR_SWITCH
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b  affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	FALC_NO_FADE25
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
FALC_NO_FADE25
	cmpi.b	#56,$fffffc02
	bne.s	FALC_ALT6
	MOVE.W	#5,$FFFF8240.W
FALC_ALT6
	CMPI.W	#550,COMPT_FADE
	BEQ.S	FALC_SPLINE6
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	FALC_SPLINE_LOOP5 
**********************************
FALC_SPLINE6
	BSR	RESTORE_SCREEN
	BSR	CLS
	BSR	RESTORE_PAL
	MOVE.B	#0,PAR	
	MOVE.W	#0,COMPT_FADE
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	ADD.L	#160,WORKECR
	ADD.L	#160,AFFECR
****boucle****
FALC_SPLINE_LOOP6
	bsr	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	FALC_jump6
	move.w	#0,pos
FALC_jump6
	move.w	#nbdots3,d7		; nombre de points
	move.l	WORKECR,a0		
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
FALC_Plot6
	lea	18(a1),a1		; vitesse increment x 
	lea	10(a2),a2		; vitesse increment y
	move.w	d7,d4
	move.w	d7,d5	
	lsl.w	#offsetx6,d4		; ecart entre x
	lsl.w	#offsety6,d5		; ecart y	
	add.w	d6,d4			; pos x dans courbe
	add.w	d6,d5			; pos y dans courbe
	move.w	(a1,d4.w),d2		;on point sur tabx
	move.w	(a2,d5.w),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	ADD.W	D3,D3
	MOVE.W	(A5,D3.W),D5 		; coord y
	ADD.W	D2,D2		
	ADD.W	D2,D2		
	MOVE.L	(A4,D2.W),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.W)
	dbf	d7,FALC_plot6
	BSR	COLOR_SWITCH

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#520,COMPT_FADE
	BLE.S	FALC_NO_FADE6
	LEA	COLORS3,a0
	BSR	SPLINE_FADE_OUT
FALC_NO_FADE6
	cmpi.b	#56,$fffffc02
	bne.s	FALC_ALT7
	MOVE.W	#5,$FFFF8240.W
FALC_ALT7
	CMPI.W	#550,COMPT_FADE
	BEQ	FALC_END_PART2	
	ADDQ.B	#1,PAR	
	BSR	VBL
	BRA	FALC_SPLINE_LOOP6
FALC_END_PART2
	RTS
**********************************
*********************
RESTORE_SCREEN
	MOVE.L	WORKINIT,WORKECR
	MOVE.L	AFFINIT,AFFECR
	RTS
*********************
COLOR_SWITCH
	lea.l colors3,a0
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
	RTS
**********************************************************
RESTORE_PAL
	MOVEM.L	A0/D0,-(SP)
	LEA	COLORS3,A0
	MOVE.W	#3,D0
REST
	MOVE.W	#$777,(A0)+
	DBF	D0,REST	
	MOVEM.L	(SP)+,A0/D0
	RTS
*********************ROUTINE POUR LE PRINTING*************
PRINTING
	LEA	FONTE+34,A0
	LEA	TEXTE+2,A1
	ADD.W	D7,A1
	ADD.W	D2,A1
	CMPI.B	#16,D1
	BNE.S	NO_CLEAR
	MOVEQ.B	#0,D1
	LEA	-16*8(A2),A2
	LEA	2560+480+160(A2),A2	
NO_CLEAR
	ADD.W	(A1),A0
	BSR	FONT
	ADDQ.B	#1,D1
	ADDQ.W	#8,A2
	ADDQ.W	#2,D2
	RTS	
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA
	MOVEM.L	A1/D1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ.W	#0,D0
	MOVEQ.W	#19,D1	
.EFF
OXO	SET	0
	REPT	197
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+160
	ENDR	
	LEA	8(A1),A1
	DBF	D1,.EFF	
	MOVEM.L	(SP)+,A1/D1
	RTS	
EFFA2
	move.l	WORKECR,a0		
	MOVE.W	#nbdots,D1
	MOVEQ.W	#0,D2
	CMPI.B	#2,PAR
	BNE.S	NO_PAPAR
	LEA	SAVE_POINT,A6
	BRA.S	EFF2
NO_PAPAR
	LEA	SAVE_POINT2,A6
EFF2
	REPT	nbdots+1
	MOVE.W	(A6)+,D5
	MOVE.W	D2,(A0,D5.W)
	ENDR
	RTS
EFFA3
	move.l	WORKECR,a0		
	MOVE.W	#nbdots,D1
	MOVEQ.W	#0,D2
	CMPI.B	#2,PAR
	BNE.S	NO_PAPAR3
	LEA	SAVE_POINT,A6
	BRA.S	EFF3
NO_PAPAR3
	LEA	SAVE_POINT2,A6
EFF3
	REPT	nbdots2+1
	MOVE.W	(A6)+,D5
	MOVE.W	D2,(A0,D5.W)
	ENDR
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

REBOND_BALL
	LEA	REBOND,A2
	ADDQ.W	#2,CURVE
	CMPI.W	#360,CURVE
	BLT.S	NO
	CLR	CURVE
NO
	MOVE.W	CURVE,D1	
	ADD.W	D4,D1
	MOVE.W	(A2,D1.W),YADD
REBOND_BALL2
	LEA	REBOND,A2
	MOVE.W	CURVE,D1	
	ADD.W	D4,D1
	MOVE.W	(A2,D1.W),YADD
	RTS
*********************
PRECALC_BALL
	BSR	CLR_REGISTERS
	LEA	GFX+34,A3
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
	MOVE.W	#719,D7
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
	ADD.W	#160,D5
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
AFF_DOTS
	movem.l	clr,d2-d6/a0-a6
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	LEA	GFX+34,A2
	MOVE.L	WORKECR,A0
	ADD.W	#8,CURVE_COMPT
	CMPI.W	#1432,CURVE_COMPT
	BLT.S	NO_CLR
	CLR.W	CURVE_COMPT
NO_CLR
	MOVE.W	CURVE_COMPT,D7
	MULU	#360,D7
	ADD.L	D7,A2
	MOVE.W	#719,D4
	MOVE.W	YADD,D0

NO_D
	MOVE.W	(A2)+,D3
	MOVE.W	(A2)+,D2
	SUB.W	D0,D2
	ADD.W	D2,D2
	MOVE.W	(A5,D2.W),D5 		; coord y
	ADD.W	D3,D3
	ADD.W	D3,D3
	MOVE.L	(A4,D3.W),D6		; coord x
	ADD.W	D6,D5
	SWAP	D6
	OR.W	D6,(A0,D5.W)	
	DBF	D4,NO_D
	RTS
*********************
PRECALC_BALL_FALC
	BSR	CLR_REGISTERS
	LEA	GFX+34,A3
MAKE_DOTS_FALC
	ADD.W	#4,X_ANGLE
	CMPI.W	#720,X_ANGLE
	BLS.S	NO_STOPFALC
	RTS
NO_STOPFALC
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLS.S	NO_STOP_FALC2
	CLR.W	Y_ANGLE
NO_STOP_FALC2
*	ADD.W	#4,Z_ANGLE
*	CMPI.W	#720,Z_ANGLE
*	BLT.S	NO_STOP_FALC3
*	CLR.W	Z_ANGLE
*NO_STOP_FALC3
	BSR	TRIGO
	MOVE.W	#809,D7
	LEA	COORD2,A2
AFF_BALL_FALC
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
	DBF	D7,AFF_BALL_FALC
	BRA	MAKE_DOTS_FALC

AFF_DOTS_FALC
	movem.l	clr,d2-d6/a0-a6
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	LEA	GFX+34,A2
	MOVE.L	WORKECR,A0
	ADD.W	#8,CURVE_COMPT
	CMPI.W	#1432,CURVE_COMPT
	BLT.S	NO_CLR_FALC
	CLR.W	CURVE_COMPT
NO_CLR_FALC
	MOVE.W	CURVE_COMPT,D7
	MULU	#405,D7
	ADD.L	D7,A2
	MOVE.W	#809,D4
	MOVE.W	YADD,D0

NO_D_FALC
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
	DBF	D4,NO_D_FALC
	RTS

LOOP_BALL_FALC
	CLR.W	COMPT_FADE
LOOP_BALL_FALC2
	BSR	EFFA

	MOVEQ.W	#0,D4
	BSR	REBOND_BALL
	MOVE.W	XADD,D1
	MOVE.W	COMPT2,D2
	MOVE.W	D2,CURVE_COMPT
	BSR	AFF_DOTS_FALC
	MOVE.W	CURVE_COMPT,D2
	MOVE.W	D2,COMPT2

	MOVE.W	#80,D4
	BSR	REBOND_BALL2
	MOVE.W	XADD2,D1
	MOVE.W	COMPT3,D2
	MOVE.W	D2,CURVE_COMPT
	BSR	AFF_DOTS_FALC
	MOVE.W	CURVE_COMPT,D2
	MOVE.W	D2,COMPT3

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT_BALL_FALC
	MOVE.W	#5,$FFFF8240
NO_ALT_BALL_FALC
	BSR	VBL
	ADDQ.W	#1,COMPT_FADE
	CMPI.W	#720,COMPT_FADE
	BLE	LOOP_BALL_FALC2
	RTS
**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************
FIN	
	MOVE.W	#0,$FFFF8240.W
	CMPI.B	#1,FALCON
	BNE.S	NO_FALCON
	MOVE.B	SAVE_8007,$FF8007
NO_FALCON
	CLR.L	$4D2
	JSR	PLAYER_FIN
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.W	#0,$FFFF8240.W
	BSR	VBL
*	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#0,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP		
	MOVE.W	#0,$FFFF8240.W
*	BSR	VBL
*	MOVE.B	#15,$484.W
*	MOVE.B	#8,$FFFFC02
*	MOVE.W	#0,$FFFF8240.W
	BSR	VBL
	MOVE.W	#0,$FFFF8240.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP

	CLR.W	-(SP)
	TRAP	#1

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\LINEROUT\LINEROUT.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\RVB_FAD3.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\RVB_FADE.S"
***********************************************************************
***********************************************************************
		SECTION DATA
YADD		DC.W	0
CURVE_COMPT	DC.W	0
CURVE		DC.W	0
********
COMPT3		DC.W	320
COMPT2		DC.W	0
CURVX1		DC.W	150
CURVY1		DC.W	0
XADD		DC.W	235
XADD2		DC.W	80
********
XE		DC.W	0
YE		DC.W	0
ZE		DC.W	0
ZDEP		DC.W	40
X_ANGLE		DC.W	2
Y_ANGLE		DC.W	2
Z_ANGLE		DC.W	2
Z_PT_FUITE	DC.W	256
SAVE_8007	DC.B	0
COMPT_FADE:	DC.W	0
COMPT_F2:	DC.B	0
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
AFFINIT:	DC.L 	0
WORKINIT:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
PLAN:		DC.B	0
FALCON		DC.B	0
SAVE_HBL:	DC.L	0
SAVE_A1B:	DC.B	0
SAVE_A21:	DC.B	0
SAVE_A07:	DC.B	0
SAVE_A09:	DC.B	0
SAVE_A13:	DC.B	0
SAVE_REZ:	DC.W	0
POS:		dc.w	12
POS2:		DC.W	4
XFACTEUR	DC.W	2
YFACTEUR	DC.W	2
ROZO		DC.L	0
LIGNE		DC.W	0
PAR		DC.B	0
X:		DC.L	0
Y:		DC.L	0
CX1		DC.W	0
CY1		DC.W	0
CX2		DC.W	0
CY2		DC.W	0
SAVE_SP		DC.L	0
SAV_CY1		DC.W	0
IND		DC.B	0
COMPT		DC.W	0
colors4		dc.w 	$023,$034,$045,$067
colors5		dc.w 	$122,$233,$344,$366
colors6		dc.w 	$313,$424,$535,$646
colors 		dc.w 	$023,$034,$045,$067
colors2		dc.w 	$313,$424,$535,$646
colors3		dc.w 	$FFF,$FFF,$FFF,$FFF
TAB	
OXO	SET	0	
	REPT	20
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+8
	ENDR
COORD2	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\DOTSBAL4.INL"
COORD	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\DOTSBAL3.INL"
DECA	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\DECA.INL"	
FORME	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\V.INL"	
Y_TABLE	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\YTABLE.INL"		
REBOND	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\REBOND2.INL"
COS_TAB	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB	EQU	COS_TAB+720	
CRIST	DC.B	"LITTLE CODING BY -CRISTALION- OF THE GREAT HYDROXID TEAM ... SEE YA SOON ON OUR FIRST DEMO ON FALCON 030 ..."
*zone de precalcul pour dotsball
GFX	INCBIN	"E:\GRAPHS\HYDROXID.PI1\SAYA\HDX3.PI1"
TEXTE:	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\TEXT.INL"
PAL79	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\PAL79.PI1"
PAL81	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\PAL81.PI1"
XCURV	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\doublex3.dat"
YCURV	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\doubley3.dat"
IMAGE	INCBIN	"E:\GRAPHS\HYDROXID.PI1\SAYA\WISH.PI1"
XCUBE	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\Xcube.INL"
YCUBE	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\Ycube.INL"
XHDX	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_HDX.INL"
YHDX	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_HDX.INL"
NAIN	INCBIN	"E:\GRAPHS\HYDROXID.PI1\NYTRIK\GROSNAIN.PI1"
X_CURVE3 INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_DISK.INL"
Y_CURVE3 INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_DISK.INL"
X_CURVE2 INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_ETOILE.INL"
Y_CURVE2 INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_ETOILE.INL"
X_CURVE INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_CUBE.INL"
Y_CURVE INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_CUBE.INL"
LOGO	INCBIN	"E:\GRAPHS\HYDROXID.PI1\SAYA\1123.PI1"
FONTE:	INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\SAYA_FNT.PI1"
		SECTION BSS
SAVE_POINT	DS.L	2000
SAVE_POINT2	DS.L	2000
SAVE_POINT3	DS.L	2000
SAVE_POINT4	DS.L	2000
PREC		DS.B 	185000
SPLINE_X	DS.B	29000
SPLINE_Y	DS.B	29000
PLAYER		DS.L	16
PLAYER_FIN	DS.L	16
DX		DS.W	50
DY		DS.W	50
CLR		DS.L	16
XP		DS.W	1
YP		DS.W	1
NEW_XE		DS.W	1
NEW_YE		DS.W	1
NEW_ZE		DS.W	1
VAR_3D		DS.W	9
		DS.L	2000
PILE		DS.L	10
LIGNE_TAB	DS.W	200
	END
																										  																									  																																								  																									  																																																										 	 