	include	f:\bordel\tos_030.s	;
	include	f:\bordel\hard_sys.s	;
	include	f:\divers.dsp\sndtrack.dsp\dsp_play.inc	;D‚finitions du soundtracker

ReadHost	MACRO	dst
.\@	btst	#0,$ffffa202.w
	beq.s	.\@
	move.l	$ffffa204.w,\1
	ENDM
WritHost	MACRO	src
.\@	btst	#1,$ffffa202.w
 	beq.s	.\@
	move.l	\1,$ffffa204.w
	ENDM
col1	=	$FFFF00FF
col2	=	$CCCC00CC
col3	=	$99990099
col4	=	$66660066
nbpts	=	4
nbpts2	=	3

	Section	TEXT

	LEA.L	PILE,SP	
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	MOVE.W	#0,$FFFF8240
	BSR	CLR_REGISTERS
	CLR.L	$FFFF9800
*	bsr	INIT_RAST
	bsr	MAKE_YTABLE
	bsr	VBL
	bsr	All_Black
	bsr	VGA
	bsr	Cls_VGA
	
;
	bsr	NYTRIK_LOGO
	bsr	PRESENT
	bsr	LOVE_VS
	bsr	GFX
	bsr	CODE
	bsr	SND
	bsr	SKIDZ_CUBE
;    
	bra	Fin
*************************************************************************************
********************LES PARTS********************************************************
*************************************************************************************
NYTRIK_LOGO
	move.l	#$3111,d0
	movec.l	d0,CACR
	bsr	VBL
	bsr	ALL_BLACK
	move.w	#(384*240/4)-1,d0
	lea	LOGO+1024,a0
	move.l	WORKECR,a1
	lea	30*384(a1),a1
AFF_LOGO
	move.l	(a0)+,(a1)+
	dbf	d0,AFF_LOGO
	bsr	SWAP
	bsr	VBL
	lea	LOGO,a0
	bsr	FADE_IN
	move.l	#$2510,d0
	movec.l	d0,CACR
	bsr	vbl
	move	#170,d0
BOUCLE2	
	bsr	VBL
	dbf	d0,BOUCLE2
BOUCLE	
	addq.w	#1,COMPT
	cmpi.w	#250,COMPT
	beq.s	GO
	add.l	#384,AFFECR
	move.b 	AFFECR+1,$ffff8201.w
	move.b 	AFFECR+2,$ffff8203.w
	move.b 	AFFECR+3,$ffff820d.w
	bsr	VBL
	cmpi.b	#57,$ffffc02
	bne.s	BOUCLE
GO
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	rts
******************
PRESENT	
	bsr	VBL
	lea	$ffff9800,a1
	moveq	#0,d1
	move	#255,d0
FADE_BLANC
	move	#127,d2
	lea	$ffff9800,a1
FADE_B
	move.l	d1,(a1)+
	dbf	d2,FADE_B
	bsr	VBL	
	add.l	#$01010001,d1
	dbf	d0,FADE_BLANC
	move.l	#$ffff00ff,$ffff9800

	lea	PRESENT2+1024,a0
	move.l	WORKECR,a1
	move.l	AFFECR,a2
	lea	20*384(a1),a1
	lea	20*384(a2),a2
	move	#384*240/4,d0
AFF_PRESENT
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,AFF_PRESENT
	bsr	VBL

	bsr	VBL
	lea	$ffff9800,a0
	lea	128*4(a0),a0
	lea	PRESENT2,a1
	lea	128*4(a1),a1
	move	#127,d0
AFF_128
	move.l	(a1)+,(a0)+
	dbf	d0,AFF_128

	move	#125,d0
	move	#125,COMPT
BOUCLE3
	move	d0,COMPT
	BSR	EFFA
	BSR	TRACE
	SUB.W	#1,YEE1
	SUB.W	#1,YEE2
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	bsr	VBL
	move	COMPT,D0
	dbf	d0,BOUCLE3	


	bsr	CLR_REGISTERS
	move	#506,COMPT		;506 pour l'horizontale
LOOP 
	BSR	EFFA
	BSR	DO_PTS
	BSR	TRACE
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	BSR	VBL
 	CMPI.W	#380,COMPT
	BNE.S	LOOP
	
	lea	PRESENT2+4,a0
	move.l	#$ffff00ff,d0
	bsr	FADE_PRECALC
	bsr	FADE_IN3

	move.w	#80,d0
BOUCLE4
	bsr	VBL
	dbf	d0,BOUCLE4

	bsr	VBL
	lea	PRESENT2,a0
	bsr	FADE_OUT

	bsr	ALL_BLACK
	bsr	CLS_VGA
	bsr	RESTORE_BASE
	rts
**************
LOVE_VS
	bsr	VBL
	lea	PIC+1024,a0
	move.l	WORKECR,a1
	move	#(384*240/4)-1,d0
LOVE	
	move.l	(a0)+,(a1)+
	dbf	d0,LOVE
	bsr	SWAP
	bsr	VBL
	lea	PIC,a0
	bsr	FADE_IN
	move	#100,d0
BOUCLE8	
	bsr	VBL
	dbf	d0,BOUCLE8
	lea	PIC,a0
	bsr	FADE_OUT
	bsr	CLS_VGA
	bsr	RESTORE_BASE
	rts
**************
GFX
	move	#220,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
LITTLE_FADE
	cmpi.l	#$02000000,d1
	beq.s	NO_D1
	add.l	#$01000000,d1
NO_D1
	cmpi.l	#$004a0000,d2
	beq.s	NO_D2
	add.l	#$00010000,d2
NO_D2
	cmpi	#$3d,d3
	beq.s	NO_D3
	addq	#1,d3
NO_D3
	moveq	#0,d4
	or.l	d1,d4	
	or.l	d2,d4	
	or	d3,d4	
	move.l	d4,$ffff9800
	bsr	VBL
	dbf	d0,LITTLE_FADE
	
	move	#0,COMPT
	move.w	#6,plan
	move.w	#1,OK2
	move	#360,X_ANGLE
LOOP4
	move.l	#$024a003d,$ffff9800
	bsr	choose_col
	add	#1,COMPT
	cmpi.w	#142/2-1,COMPT
	bgt.s	NO_ADD
	add.w	#4,zdep
NO_ADD
	cmpi.w	#260,COMPT
	ble.s	NO_ADD2
	sub.w	#4,zdep
NO_ADD2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT1
	MOVE.L	#$FF000000,$FFFF9800
NO_ALt1
	BSR	EFFA2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT2
	MOVE.L	#$00FF0000,$FFFF9800
NO_ALT2
	BSR	MAKE_GFX
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT3
	MOVE.L	#$FFFF00FF,$FFFF9800
NO_ALT3
	BSR	TRACE2
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
	MOVE.L	#$00FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.W	#440,COMPT
	BLE	LOOP4
	move	#0,COMPT
;
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	HR
	
	moveq	#0,d3
	move.l	WORKECR,a0
	add.l	#768*150,a0		
	lea	TEXT,a1
	move	#24*4,d0		;nombre de lettres
	bsr	PRINTING

	bsr	VBL
	lea	$ffff9804,a0
	move.l	#$024a003d,d0
	move	#254,d1
	move.l	#$3111,d4
	movec.l	d4,CACR
GREEN_PAL
	move.l	d0,(a0)+
	dbf	d1,GREEN_PAL
	bsr	SWAP
	move.l	#$2510,d4
	movec.l	d4,CACR
	bsr	VBL

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_IN2		

	move	#50,d0
BOUCLE5
	bsr	VBL
	dbf	d0,BOUCLE5

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_OUT2
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	VBL
	bsr	VGA
	rts
************
CODE
	move.w	#6,plan
	move.w	#1,OK2
	move	#360,X_ANGLE
	clr	COMPT
	move	#-200,ZDEP
	move	#360,X_ANGLE
	clr	Y_ANGLE
	clr	Z_ANGLE
	bsr	VBL
LOOP11
	move.l	#$024a003d,$ffff9800
	addq	#1,COMPT
	bsr	choose_col
	CMPI.W	#185,COMPT
	BGT.S	NO_ADD10
	ADDQ.W	#2,ZDEP
NO_ADD10
	CMPI.W	#430,COMPT
	BGT.S	NO_ADD_BAS
	CMPI.W	#220,COMPT
	BLE.S	NO_ADD_BAS
	ADDQ	#1,ADD_BAS
NO_ADD_BAS
	BSR	EFFA4
	BSR	MAKE_CODE
	BSR	TRACE4
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
	bne.s 	trainee2			; on boucle
 	subq.w 	#8,affecr+2
trainee2

	MOVEM.L	(SP)+,A1-A2
	BSR	VBL
	CMPI.W	#440,COMPT
	BNE	LOOP11
;
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	HR
	
	moveq	#0,d3
	move.l	WORKECR,a0
	add.l	#768*35,a0		
	lea	TEXT+24*4*4,a1
	move	#24*11,d0		;nombre de lettres
	bsr	PRINTING

	bsr	VBL
	lea	$ffff9804,a0
	move.l	#$024a003d,d0
	move	#254,d1
	move.l	#$3111,d4
	movec.l	d4,CACR
GREEN_PAL2
	move.l	d0,(a0)+
	dbf	d1,GREEN_PAL2
	bsr	SWAP
	move.l	#$2510,d4
	movec.l	d4,CACR
	bsr	VBL

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_IN2		

	move	#100,d0
BOUCLE10
	bsr	VBL
	dbf	d0,BOUCLE10

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_OUT2
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	VBL

	moveq	#0,d3
	move.l	WORKECR,a0
	add.l	#768*100,a0		
	lea	TEXT+24*(4+11)*4,a1
	move	#24*8,d0		;nombre de lettres
	bsr	PRINTING

	bsr	VBL
	lea	$ffff9804,a0
	move.l	#$024a003d,d0
	move	#254,d1
	move.l	#$3111,d4
	movec.l	d4,CACR
GREEN_PAL3
	move.l	d0,(a0)+
	dbf	d1,GREEN_PAL3
	bsr	SWAP
	move.l	#$2510,d4
	movec.l	d4,CACR
	bsr	VBL

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_IN2		

	move	#100,d0
BOUCLE11
	bsr	VBL
	dbf	d0,BOUCLE11

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_OUT2
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	VBL
	bsr	VGA
	rts
************
SND
	bsr	CLR_REGISTERS
	clr	Y_ANGLE
	clr	Z_ANGLE
	move	#170,ZDEP
	move.w	#6,plan
	move.w	#1,OK2
	move	#360,X_ANGLE
	clr	COMPT
	move	#280,ADD_BAS
LLOOP
	move.l	#$024a003d,$ffff9800
	addq	#1,COMPT
	bsr	choose_col
	cmpi	#280,COMPT
	bgt.s	NO_ADDK
	subq	#1,ADD_BAS
NO_ADDK	
	cmpi	#360,COMPT
	ble.s	NO_ADDZ
	subq	#2,ZDEP
NO_ADDZ
	
	BSR	EFFA5
	BSR	MAKE_SND
	BSR	TTRACE
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
	bne.s 	traineee			; on boucle
 	subq.w 	#8,affecr+2
traineee

	MOVEM.L	(SP)+,A1-A2
	BSR	VBL
	CMPI	#500,COMPT
	BNE	LLOOP
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	HR

	moveq	#0,d3
	move.l	WORKECR,a0
	add.l	#768*100,a0		
	lea	TEXT+24*(4+8+11)*4,a1
	move	#24*7,d0		;nombre de lettres
	bsr	PRINTING

	bsr	VBL
	lea	$ffff9804,a0
	move.l	#$024a003d,d0
	move	#254,d1
	move.l	#$3111,d4
	movec.l	d4,CACR
GREEN_PAL4
	move.l	d0,(a0)+
	dbf	d1,GREEN_PAL4
	bsr	SWAP
	move.l	#$2510,d4
	movec.l	d4,CACR
	bsr	VBL

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_IN2		

	move	#100,d0
BOUCLE12
	bsr	VBL
	dbf	d0,BOUCLE12

	lea	FNT+4,a0
	move.l	#$024a003d,d0
	bsr	FADE_PRECALC
	bsr	FADE_OUT2
	bsr	VBL
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	bsr	VBL
	bsr	VGA


	lea	$ffff9800,a0
	move.l	#$024a003d,d0
	move.b	#$3d,d1
	move.l	#$4a0000,d2
	move.l	#$02000000,d3
	moveq	#0,d4
	move	#140,d5
FADE_BLACK
	tst.b	d1
	beq.s	NO_VERT
	sub.b	#1,d1
NO_VERT
	tst.l 	d2
	beq.s	NO_VERT2
	sub.l	#$010000,d2
NO_VERT2
	tst.l 	d3
	beq.s	NO_VERT3
	sub.l	#$01000000,d3
NO_VERT3
	moveq	#0,d4
	or.b	d1,d4	
	or.l	d2,d4	
	or.l	d3,d4
	move.l	d4,(a0)
	bsr	VBL
	dbf	d5,FADE_BLACK	
	rts
************
SKIDZ_CUBE
	move.l	FOND,d0
	bsr	CLR_REGISTERS
	bsr	VBL
	bsr	AFF_PAL
	bsr	VBL

	move.l	FOND,d0
	lea	$ffff9800,a0
	move	#150,d1
	moveq	#0,d2
AFF_VIOLET
	cmp.l	d2,d0
	beq.s	STOP_VIOLET
	add.l	#$01000001,d2
STOP_VIOLET
	move.l	d2,(a0)
	bsr	VBL
	dbf	d1,AFF_VIOLET

	bsr	AFF_GFX
	clr	COMPT
	clr	X_ANGLE
	clr	Y_ANGLE
	clr	Z_ANGLE
	move	#-900,ZDEP
	bsr	VBL
LOOOP
	MOVE.L	FOND,$FFFF9800
	ADDQ	#1,COMPT 
	CMPI.W	#230,COMPT
	BHI.S	STOP_ZOOM
	ADDQ	#4,ZDEP
STOP_ZOOM
	BSR	VBL
	BSR	EFFA3
	BSR	MAKE_CUBE
	BSR	TRACE3
	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOOP
	clr	COMPT

	bsr	VBL
	bsr	AFF_GFX2
	bsr	VBL
	bsr	SWAP
	lea	SKIDZ,a0
	lea	$ffff9800,a1
	move	#31,d0
LOOP_PAL
	move.l	(a0)+,(a1)+
	dbf	d0,LOOP_PAL
	bsr	VBL
	lea	SKIDZ,a0
	bsr	FADE_OUT_SKIDZ
	bsr	VBL
	bsr	ALL_BLACK
	bsr	RESTORE_BASE
	bsr	CLS_VGA
	RTS
*************************************************************************************
********************INITIALISATIONS**************************************************	
*************************************************************************************
Inits
	MOVEC.L	CACR,D0
	MOVE.L	D0,OLD_CACR
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	
	MOVE.L	$44E.W,OLDXBIOS	
	MOVE.L	#XBIOS3,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,AFFECR
	ADD.L	#560*768,D0
	MOVE.L	D0,WORKECR
	move.l	AFFECR,LOGBASE2
	move.l	WORKECR,PHYSBASE2
	move.b 	AFFECR+1,$ffff8201.w
	move.b 	AFFECR+2,$ffff8203.w
	move.b 	AFFECR+3,$ffff820d.w
	bsr	INIT_MOD
	rts
*************************************************************************************
**************SOUS ROUTINES**********************************************************
*************************************************************************************
PRINTING
	
	move.l	(a1)+,d2
	lea	FNT+1024+320,a2
	move	#31,d1	
	move.l	#$3111,d4
	movec.l	d4,CACR
AFF_FNT
	move.l	(a2,d2.l),(a0)
	move.l	4(a2,d2.l),4(a0)
	move.l	8(a2,d2.l),8(a0)
	move.l	12(a2,d2.l),12(a0)

	move.l	16(a2,d2.l),16(a0)
	move.l	20(a2,d2.l),20(a0)
	move.l	24(a2,d2.l),24(a0)
	move.l	28(a2,d2.l),28(a0)

	lea	384*2(a0),a0
	lea	320(a2),a2
	dbf	d1,AFF_FNT
	move.l	#$2510,d4
	movec.l	d4,CACR
	lea	32(a0),a0
	sub.l	#384*2*32,a0
	addq	#1,d3
	cmpi	#24,d3
	bne.s	CLR_D3
	moveq	#0,d3
	add.l	#384*6*4+384*2*33-24*16*2,a0
CLR_D3
	dbf	d0,PRINTING
	rts

RESTORE_BASE
	move.l	LOGBASE2,AFFECR
	move.l	PHYSBASE2,WORKECR	
	move.b 	AFFECR+1,$ffff8201.w
	move.b 	AFFECR+2,$ffff8203.w
	move.b 	AFFECR+3,$ffff820d.w
	rts
SWAP
	move.l	WORKECR,a0
	move.l	AFFECR,WORKECR
	move.l	a0,AFFECR	
	move.b 	AFFECR+1,$ffff8201.w
	move.b 	AFFECR+2,$ffff8203.w
	move.b 	AFFECR+3,$ffff820d.w
	rts
VBL
	move.l	d7,-(sp)
	move.l	$466.w,d7
VSYNC2:	cmp.l	$466.w,d7
	beq.s	VSYNC2
	move.l	(sp)+,d7
	RTS
HR:				
	BSR	VBL
	MOVE	#384,$FFFF8210.W	;TAILLE EN PIXELS
	MOVE	#16,$FFFF8266.W	;16=VGA & 256=TC
	MOVE	#510,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#409,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#80,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#29,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#334,$FFFF828A.W	;FULL DROIT
	MOVE	#434,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#624,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#43,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#42,$FFFF82A8.W	;FULL HAUT
	MOVE	#612,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	MOVE	#6,$FFFF82C2.W	;PIXEL OPTIONS
	RTS

 VGA:				;384*280
	MOVE	#192,$FFFF8210.W	;TAILLE EN PIXELS
	MOVE	#16,$FFFF8266.W	;16=VGA & 256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#49,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#764,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#157,$FFFF828A.W	;FULL DROIT
	MOVE	#216,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#625,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#47,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#47,$FFFF82A8.W	;FULL HAUT
	MOVE	#611,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	CLR	$FFFF82C2.W	;PIXEL OPTIONS
	RTS
ALL_BLACK
	LEA	$FFFF8240,A0
	MOVEQ	#0,D0
	MOVEQ	#15,D1
RGB
	MOVE.W	D0,(A0)+
	DBF	D1,RGB	
	MOVE	#255,D1
	LEA	$FFFF9800,A0
VGA2
	MOVE.L	D0,(A0)+
	DBF	D1,VGA2
	BSR	VBL
	RTS
CLS_VGA
	MOVE.W	#65535,D1	
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVEQ	#0,D0
	move.l	#$3111,d3
	movec.l	d3,CACR
CLS
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	DBF	D1,CLS
	MOVE.W	#41985,D1	
CLS2
	MOVE.L	D0,(A0)+
	MOVE.L	D0,(A1)+
	DBF	D1,CLS2
	move.l	#$2510,d0
	movec.l	d0,CACR
	RTS	
TRACE
	MOVE.W	YEE1,PTS
	MOVE.W	YEE2,PTS+2
	MOVE.W	YEE3,PTS+4
	MOVE.W	YEE4,PTS+6
	BSR	INIT_FACE
	MOVE.W	XEE1,CX1
	MOVE.W	YEE1,CY1
	MOVE.W	XEE2,CX2
	MOVE.W	YEE2,CY2
	BSR	TRACE_FACE
	MOVE.W	XEE2,CX1
	MOVE.W	YEE2,CY1
	MOVE.W	XEE3,CX2
	MOVE.W	YEE3,CY2
	BSR	TRACE_FACE
	MOVE.W	XEE3,CX1
	MOVE.W	YEE3,CY1
	MOVE.W	XEE4,CX2
	MOVE.W	YEE4,CY2
	BSR	TRACE_FACE
	MOVE.W	XEE4,CX1
	MOVE.W	YEE4,CY1
	MOVE.W	XEE1,CX2
	MOVE.W	YEE1,CY2
	BSR	TRACE_FACE
	MOVEQ	#14,D4
	BSR	REMPLI
	rts
******************************LA ROUTINE D'EFFACAGE BLITTER**********************
EFFA
	LEA	CLR,A0
	MOVE.L	WORKECR,A1
	ADD.L	#384*9+14,A1
	MOVEQ	#0,D2
 	MOVE.B	#2,$FFFF8A3A		; coupe ram de demi teinte
	MOVE.B	#0,$FFFF8A3B		; operations logiques
	MOVE.W	#0,$FF8A22			; Increment Vertical Source
	MOVE.W	#0,$FF8A20			; distance entre un mot et le suivant
	MOVE.W	#24,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		
;dest
	MOVE.W	#16,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#16,$FFFF8A30		; IVD
*****PLAN-1***********
; source	
	MOVE.L	A0,$FF8A24			; addresse bloc a transferer
	MOVE.W	#260,$FF8A38		; taille verticale
; destination
	MOVE.L	A1,$FFFF8A32	
	MOVE.B	D2,$FFFF8A3D		; registre pour decalage vers la droite
;		  XXX-XXXX			; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
MAKE_YTABLE
	LEA	Y_TABLE,A1
	MOVE.W	#320,D1
	MOVEQ	#0,D2
MAKE
	MOVE.L	D2,(A1)+
	ADD.L	#384,D2
	DBF	D1,MAKE
	RTS
DO_PTS
	LEA	CURV1,A0
	LEA	CURV1+5096,A1
	LEA	CURV1+5096*2,A2
	LEA	CURV1+5096*3,A3
	MOVE	COMPT,D0
	MOVE.L	(A0,D0.W*4),D1
	MOVE.L	D1,XEE1
	MOVE.L	(A1,D0.W*4),D1
	MOVE.L	D1,XEE2
	MOVE.L	(A2,D0.W*4),D1
	MOVE.L	D1,XEE3
	MOVE.L	(A3,D0.W*4),D1
	MOVE.L	D1,XEE4
	ADDQ	#4,COMPT
	CMPI.W	#5080/4-2,COMPT
	BLE.S	NO_CLR
	CLR.W	COMPT
NO_CLR
	RTS
MAKE_GFX
	ADD.W	#6,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP2 
	CLR.W	Y_ANGLE
NO_STOP2
	ADD.W	#4,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP3
	CLR.W	Z_ANGLE
NO_STOP3
	BSR	TRIGO
	LEA	XE1,A0
	LEA	YE1,A1
	LEA	ZE1,A2
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#27,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO
	MOVEM.L	D0/A1-A2,-(SP)		
	MOVE.W	(A0),D0
	MOVE.W	(A1),D1
	MOVE.W	(A2),D2
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
	ADD.W	#135,D2
	MOVEM.L	(SP)+,D0/A1-A2
	ADDQ	#6,A0
	ADDQ	#6,A1
	ADDQ	#6,A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
*******************************SOUS ROUTINES*****************************************
TRACE2
;LE X
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	MOVE.W	DY+6,PTS+6
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
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVE.W	DY+14,PTS+6
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
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
;LE F
	MOVE.W	DY+16,PTS
	MOVE.W	DY+18,PTS+2
	MOVE.W	DY+20,PTS+4
	MOVE.W	DY+22,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+18,CX1
	MOVE.W	DY+18,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+20,CX1
	MOVE.W	DY+20,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+16,PTS
	MOVE.W	DY+22,PTS+2
	MOVE.W	DY+24,PTS+4
	MOVE.W	DY+26,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+26,CX1
	MOVE.W	DY+26,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+28,PTS
	MOVE.W	DY+30,PTS+2
	MOVE.W	DY+32,PTS+4
	MOVE.W	DY+34,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+28,CX1
	MOVE.W	DY+28,CY1
	MOVE.W	DX+30,CX2
	MOVE.W	DY+30,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+30,CX1
	MOVE.W	DY+30,CY1
	MOVE.W	DX+32,CX2
	MOVE.W	DY+32,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+32,CX1
	MOVE.W	DY+32,CY1
	MOVE.W	DX+34,CX2
	MOVE.W	DY+34,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+34,CX1
	MOVE.W	DY+34,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
;LE G
	MOVE.W	DY+36,PTS
	MOVE.W	DY+38,PTS+2
	MOVE.W	DY+40,PTS+4
	MOVE.W	DY+42,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+36,CX1
	MOVE.W	DY+36,CY1
	MOVE.W	DX+38,CX2
	MOVE.W	DY+38,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+38,CX1
	MOVE.W	DY+38,CY1
	MOVE.W	DX+40,CX2
	MOVE.W	DY+40,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+40,CX1
	MOVE.W	DY+40,CY1
	MOVE.W	DX+42,CX2
	MOVE.W	DY+42,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+42,CX1
	MOVE.W	DY+42,CY1
	MOVE.W	DX+36,CX2
	MOVE.W	DY+36,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+44,PTS
	MOVE.W	DY+46,PTS+2
	MOVE.W	DY+40,PTS+4
	MOVE.W	DY+42,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+42,CX1
	MOVE.W	DY+42,CY1
	MOVE.W	DX+40,CX2
	MOVE.W	DY+40,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+40,CX1
	MOVE.W	DY+40,CY1
	MOVE.W	DX+46,CX2
	MOVE.W	DY+46,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+46,CX1
	MOVE.W	DY+46,CY1
	MOVE.W	DX+44,CX2
	MOVE.W	DY+44,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+44,CX1
	MOVE.W	DY+44,CY1
	MOVE.W	DX+42,CX2
	MOVE.W	DY+42,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+44,PTS
	MOVE.W	DY+46,PTS+2
	MOVE.W	DY+48,PTS+4
	MOVE.W	DY+50,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+44,CX1
	MOVE.W	DY+44,CY1
	MOVE.W	DX+46,CX2
	MOVE.W	DY+46,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+46,CX1
	MOVE.W	DY+46,CY1
	MOVE.W	DX+48,CX2
	MOVE.W	DY+48,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+48,CX1
	MOVE.W	DY+48,CY1
	MOVE.W	DX+50,CX2
	MOVE.W	DY+50,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+50,CX1
	MOVE.W	DY+50,CY1
	MOVE.W	DX+44,CX2
	MOVE.W	DY+44,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	MOVE.W	DY+52,PTS
	MOVE.W	DY+54,PTS+2
	MOVE.W	DY+48,PTS+4
	MOVE.W	DY+50,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+48,CX1
	MOVE.W	DY+48,CY1
	MOVE.W	DX+50,CX2
	MOVE.W	DY+50,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+50,CX1
	MOVE.W	DY+50,CY1
	MOVE.W	DX+52,CX2
	MOVE.W	DY+52,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+52,CX1
	MOVE.W	DY+52,CY1
	MOVE.W	DX+54,CX2
	MOVE.W	DY+54,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+54,CX1
	MOVE.W	DY+54,CY1
	MOVE.W	DX+48,CX2
	MOVE.W	DY+48,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI
	rts
EFFA2
	LEA	CLR,A0
	MOVE.L	WORKECR,A1
	ADD.L	#(24+22)*384+48,A1	
	MOVEQ	#0,D2
 	MOVE.B	#2,$FFFF8A3A		; coupe ram de demi teinte
	MOVE.B	#0,$FFFF8A3B		; operations logiques
	MOVE.W	#0,$FF8A22			; Increment Vertical Source
	MOVE.W	#0,$FF8A20			; distance entre un mot et le suivant
	MOVE.W	#18,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		
;dest
	MOVE.W	#16,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#16*7,$FFFF8A30		; IVD
*****PLAN-1***********
; source	
	MOVE.L	A0,$FF8A24			; addresse bloc a transferer
	MOVE.W	#181,$FF8A38		; taille verticale
; destination
	MOVE.L	A1,$FFFF8A32	
	MOVE.B	D2,$FFFF8A3D		; registre pour decalage vers la droite
;		  XXX-XXXX			; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
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
choose_col
	cmpi.w	#0,plan
	beq.s	plan1
	cmpi.w	#2,plan
	beq	plan2
	cmpi.w	#4,plan
	beq	plan3
	cmpi.w	#6,plan
	beq	plan4
plan1
           move.l #col1,$ffff9804
           move.l #col4,$ffff9808
           move.l #col1,$ffff980C
           move.l #col3,$ffff9810
           move.l #col1,$ffff9814
           move.l #col3,$ffff9818
           move.l #col1,$ffff981C
           move.l #col2,$ffff9820
           move.l #col1,$ffff9824
           move.l #col2,$ffff9828
           move.l #col1,$ffff982C
           move.l #col2,$ffff9830 
           move.l #col1,$ffff9834 
           move.l #col2,$ffff9838 
           move.l #col1,$ffff983C
	jmp	endcol
plan2
           move.l #col2,$ffff9804
           move.l #col1,$ffff9808
           move.l #col1,$ffff980C
           move.l #col4,$ffff9810
           move.l #col2,$ffff9814
           move.l #col1,$ffff9818
           move.l #col1,$ffff981C
           move.l #col3,$ffff9820
           move.l #col2,$ffff9824
           move.l #col1,$ffff9828
           move.l #col1,$ffff982C
           move.l #col3,$ffff9830
           move.l #col2,$ffff9834
           move.l #col1,$ffff9838
           move.l #col1,$ffff983C
	jmp	endcol
plan3 
           move.l #col3,$ffff9804
           move.l #col2,$ffff9808
           move.l #col2,$ffff980C
           move.l #col1,$ffff9810
           move.l #col1,$ffff9814
           move.l #col1,$ffff9818
           move.l #col1,$ffff981C
           move.l #col4,$ffff9820
           move.l #col3,$ffff9824
           move.l #col2,$ffff9828
           move.l #col2,$ffff982C
           move.l #col1,$ffff9830
           move.l #col1,$ffff9834
           move.l #col1,$ffff9838
           move.l #col1,$ffff983C
	jmp	endcol
plan4
           move.l #col4,$ffff9804
           move.l #col3,$ffff9808
           move.l #col3,$ffff980C
           move.l #col2,$ffff9810
           move.l #col2,$ffff9814
           move.l #col2,$ffff9818
           move.l #col2,$ffff981C
           move.l #col1,$ffff9820
           move.l #col1,$ffff9824
           move.l #col1,$ffff9828
           move.l #col1,$ffff982C
           move.l #col1,$ffff9830
           move.l #col1,$ffff9834
           move.l #col1,$ffff9838
           move.l #col1,$ffff983C
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

INIT_MOD
	lea	mod,a0		;Adresse du module NTK4
	lea	freq_buf,a1	;Buffer pour les fr‚quences
	jsr	dsp_play		;Pof, la routine s'initialise
	move.l	dsp_play+8,a0	;Adresse des variables internes
	clr.b	song_stop(a0)	;->D‚bloque
	st.b	dma2dsp(a0)	;->Transfert par le port Host
	lea	MFP_base.w,a6	;
	move.b	VR(a6),save_vr	;MFP en mode AEI
	bclr	#3,VR(a6)		;
	move.l	V_TB.w,save_vtb	;
	move.l	#PLAY_MOD,$4d2
	seq	dma2dsp(a0)	;->Transfert par le port Host
	RTS

INIT_RAST:
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	RTS
PLAY_MOD
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	DSP_PLAY+12
	movem.l	(sp)+,d0-d7/a0-a6
	rts

* FADING IN DE LA PIC
FADE_IN
	MOVEM.L	CLEAR,D0-D7/A1-A6
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	LEA	COL,A1
	MOVE	#255,D2
CLR_COL
	MOVE.L	D0,(A1)+
	DBF	D2,CLR_COL
	MOVE	#255,D2
	MOVE.L	A0,A3
LOOP1:
	BSR	VBL
	LEA	$FFFF9800.W,A1
	LEA	COL,A2
	MOVE	#255,D0
	MOVE.L	A3,A0
LOOP2:
	MOVE.B	(A0),D1
	CMP.B	(A2),D1
	BEQ.S	OK
	ADDQ.B	#1,(A2)
OK	
	MOVE.B	1(A0),D1
	CMP.B	1(A2),D1
	BEQ.S	OK22
	ADDQ.B	#1,1(A2)
OK22
	MOVE.B	3(A0),D1
	CMP.B	3(A2),D1
	BEQ.S	OK3
	ADDQ.B	#1,3(A2)
OK3	

	MOVE.L	(A2)+,(A1)+
	ADDQ	#4,A0
	DBF	D0,LOOP2
	DBF	D2,LOOP1
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
	
* FADING OUT DE LA PIC
FADE_OUT
	MOVEM.L	CLEAR,D0-D7/A1-A6
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	MOVE	#255,D2
	LEA	COL,A2
COPIE
	MOVE.L	(A0)+,(A2)+
	DBF	D2,COPIE
	MOVE	#255,D2
LOOP3:
	BSR	VBL
	LEA	$FFFF9800.W,A1
	LEA	COL,A2
	MOVE	#255,D0
LOOP44
	TST.B	(A2)
	BEQ.S	OK44
	SUBQ.B	#1,(A2)
OK44
	TST.B	1(A2)
	BEQ.S	OK5
	SUBQ.B	#1,1(A2)
OK5
	TST.B	3(A2)
	BEQ.S	OK6
	SUBQ.B	#1,3(A2)
OK6

	MOVE.L	(A2)+,(A1)+
	DBF	D0,LOOP44
	DBF	D2,LOOP3
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
FADE_OUT_SKIDZ
	MOVEM.L	CLEAR,D0-D7/A1-A6
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	MOVE	#255,D2
	LEA	COL,A2
COPIE_SKIDZ
	MOVE.L	(A0)+,(A2)+
	DBF	D2,COPIE_SKIDZ
	MOVE	#255,D2
LOOP3_SKIDZ
	LEA	$FFFF9800.W,A1
	LEA	COL,A2
	MOVE	#31,D0
LOOP44_SKIDZ
	TST.B	(A2)
	BEQ.S	OK44_SKIDZ
	SUBQ.B	#1,(A2)
OK44_SKIDZ
	TST.B	1(A2)
	BEQ.S	OK5_SKIDZ
	SUBQ.B	#1,1(A2)
OK5_SKIDZ
	TST.B	3(A2)
	BEQ.S	OK6_SKIDZ
	SUBQ.B	#1,3(A2)
OK6_SKIDZ

	MOVE.L	(A2)+,(A1)+
	DBF	D0,LOOP44_SKIDZ
	BSR	VBL
	DBF	D2,LOOP3_SKIDZ
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
************************
* FADING IN DE LA PIC
FADE_PRECALC
	MOVEM.L	CLEAR,D1-D7/A1-A6
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	LEA	COL,A1
	MOVE	#255,D2
CLR_COL2
	MOVE.L	D0,(A1)+
	DBF	D2,CLR_COL2
	
	MOVE	#255,D2
	MOVE.L	A0,A3
	LEA	COLOR,A1
LOOP12
	LEA	COL,A2
	MOVE	#254,D0
	MOVE.L	A3,A0
LOOP22:
	MOVE.B	(A0),D1
	CMP.B	(A2),D1
	BEQ.S	OKK
	BLS.S	SUB
	ADDQ.B	#1,(A2)
	BRA.S	OKK
SUB
	SUBQ.B	#1,(A2)
OKK	

	MOVE.B	1(A0),D1
	CMP.B	1(A2),D1
	BEQ.S	OKK22
	BLS.S	SUB2
	ADDQ.B	#1,1(A2)
	BRA.S	OKK22
SUB2
	SUBQ.B	#1,1(A2)
OKK22

	MOVE.B	3(A0),D1
	CMP.B	3(A2),D1
	BEQ.S	OKK3
	BLS.S	SUB3
	ADDQ.B	#1,3(A2)
	BRA.S	OKK3
SUB3
	SUBQ.B	#1,3(A2)
OKK3	

	MOVE.L	(A2)+,(A1)+
	ADDQ	#4,A0
	DBF	D0,LOOP22
	DBF	D2,LOOP12
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS

* FADING IN DE LA PIC
FADE_IN2
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	move	#255,d1
	lea	COLOR,a1
IN
	bsr	VBL
	move	#254,d0
	lea	$ffff9804,a0
IN2
	move.l	(a1)+,(a0)+
	dbf	d0,IN2
	dbf	d1,IN
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
FADE_IN3
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	move	#255,d1
	lea	COLOR,a1
IN4
	bsr	VBL
	move	#126,d0
	lea	$ffff9804,a0
IN3
	move.l	(a1)+,(a0)+
	dbf	d0,IN3
	lea	4*128(a1),a1
	dbf	d1,IN4
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
* FADING OUT DE LA PIC
FADE_OUT2
	MOVE.L	#$3111,D1
	MOVEC.L	D1,CACR
	move	#255,d1
	lea	COLOR+255*256*4-4,a1
OUT
	bsr	VBL
	move	#254,d0
	lea	$ffff9800,a0
	lea	255*4(a0),a0
OUT2
	move.l	(a1),(a0)
	subq	#4,a1
	subq	#4,a0
	dbf	d0,OUT2
	dbf	d1,OUT
	MOVE.L	#$2510,D1
	MOVEC.L	D1,CACR
	RTS
TRACE3
	MOVE.W	SX,X1
	MOVE.W	SY,Y1
	MOVE.W	SZ,Z1
	MOVE.W	SX+4,X2
	MOVE.W	SY+4,Y2
	MOVE.W	SZ+4,Z2
	MOVE.W	SX+6,X3
	MOVE.W	SY+6,Y3
	MOVE.W	SZ+6,Z3
	BSR	CACHE
	CMPI.L	#-200000,D1
	BLT	NO_FACE
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	MOVE.W	DY+6,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#10,D4
	BSR	REMPLI
NO_FACE
	MOVE.W	SX+8,X1
	MOVE.W	SY+8,Y1
	MOVE.W	SZ+8,Z1
	MOVE.W	SX+14,X2
	MOVE.W	SY+14,Y2
	MOVE.W	SZ+14,Z2
	MOVE.W	SX+12,X3
	MOVE.W	SY+12,Y3
	MOVE.W	SZ+12,Z3
	BSR	CACHE
	CMPI.L	#-200000,D1
	BLT	NO_FACE2
;face2
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	MOVE.W	DY+14,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVEQ	#10,D4
	BSR	REMPLI
NO_FACE2
	MOVE.W	SX+10,X1
	MOVE.W	SY+10,Y1
	MOVE.W	SZ+10,Z1
	MOVE.W	SX+2,X2
	MOVE.W	SY+2,Y2
	MOVE.W	SZ+2,Z2
	MOVE.W	SX,X3
	MOVE.W	SY,Y3
	MOVE.W	SZ,Z3
	BSR	CACHE
	CMPI.L	#-200000,D1
	BLT	NO_FACE3
;face3
	MOVE.W	DY+10,PTS
	MOVE.W	DY,PTS+2
	MOVE.W	DY+2,PTS+4
	MOVE.W	DY+12,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+2,CX1
	MOVE.W	DY+2,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+12,CX2
	MOVE.W	DY+12,CY2
	BSR	TRACE_FACE
	MOVEQ	#10,D4
	BSR	REMPLI
NO_FACE3
	MOVE.W	SX+8,X1
	MOVE.W	SY+8,Y1
	MOVE.W	SZ+8,Z1
	MOVE.W	SX+6,X2
	MOVE.W	SY+6,Y2
	MOVE.W	SZ+6,Z2
	MOVE.W	SX+4,X3
	MOVE.W	SY+4,Y3
	MOVE.W	SZ+4,Z3
	BSR	CACHE
	CMPI.L	#-200000,D1
	BLT	NO_FACE4
;face4
	MOVE.W	DY+14,PTS
	MOVE.W	DY+4,PTS+2
	MOVE.W	DY+8,PTS+4
	MOVE.W	DY+6,PTS+6
	BSR	INIT_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+8,CX1
	MOVE.W	DY+8,CY1
	MOVE.W	DX+6,CX2
	MOVE.W	DY+6,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+6,CX1
	MOVE.W	DY+6,CY1
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+8,CX2
	MOVE.W	DY+8,CY2
	BSR	TRACE_FACE
	MOVEQ	#10,D4
	BSR	REMPLI
NO_FACE4
	rts
MAKE_CUBE
	CMPI.W	#300,COMPT
	BLE.S	NO_VIOLET
	MOVE.L	FOND,D0
	TST.L	D0
	BEQ.S	NO_VIOLET
	SUB.L	#$01000001,D0
	MOVE.L	D0,FOND
NO_VIOLET
	ADD.W	#4,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP22 
	CLR.W	Y_ANGLE
NO_STOP22
	ADD.W	#4,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NO_STOP33
	CLR.W	Z_ANGLE
NO_STOP33
	BSR	TRIGO
	MOVEQ	#7,D0
	LEA	XE1C,A0
	LEA	DX,A5
	LEA	DY,A4
	LEA	SX,A1
	LEA	SY,A2
	LEA	SZ,A3 
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO2
	MOVEM.L	D0/A1-A3,-(SP)		
	MOVE.W	(A0)+,D0
	MOVE.W	(A0)+,D1
	MOVE.W	(A0)+,D2
	LEA	XDEP,A3
	MOVEM.W	(A3)+,D3-D5
	ASL.L	D6,D5		;zdep*512
	ASL.L	D6,D3		;zdep*512
	ASL.L	D6,D4		;zdep*512
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
	MOVE.L	D5,NEW_ZE
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
	MOVE.L	D5,NEW_XE
	DIVS	D7,D5		;d5=new_xe/q

	MULS	(A6)+,D0		;d0=b*xe*512
	MULS	(A6)+,D1		;d1=e*ye*512
	MULS	(A6)+,D2		;d2=h*ze*512
	ADD.L	D0,D1		
	ADD.L	D1,D2
	ADD.L	A2,D2
	MOVE.L	D2,NEW_YE
	DIVS	D7,D2		;d2=new_ye/q
	ADD.W	#200,D5	
	ADD.W	#135,D2
	MOVEM.L	(SP)+,D0/A1-A3
	MOVE.L	NEW_XE,D1
	MOVE.L	NEW_YE,D4
	MOVE.L	NEW_ZE,D3
	ASR.L	D6,D1	
	ASR.L	D6,D4
	ASR.L	D6,D3	
	MOVE.W	D1,(A1)+
	MOVE.W	D4,(A2)+
	MOVE.W	D3,(A3)+
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
EFFA3
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	#$3111,D0
	MOVEC.L	D0,CACR
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.L	#64+10,A1
	LEA	5*384(A1),A1
	MOVEQ	#0,D0
	CMPI.W	#334,COMPT
	BLE.S	NO_FFF
	MOVEQ	#-1,D0
NO_FFF
	MOVE.W	#257,D1
.EFF
OXO	SET	0
	REPT	17
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+16
	ENDR
	LEA	384(A1),a1
	DBF	D1,.EFF
	MOVE.L	#$2510,D0
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A1
	RTS
AFF_PAL
	move.l	#$3111,d0
	movec.l	d0,CACR
	LEA	$FFFF9804,A1
	MOVE	#30,D1
	MOVE.L	#$44000044,D0
SKIDZ2
	MOVE.L	D0,(A1)+
	DBF	D1,SKIDZ2

	MOVE.L	CUBE_COL1,(A1)
	ADDQ	#4,A1
	LEA	SKIDZ+4,A0
	MOVE	#30,D1
SKIDZ3
	MOVE.L	(A0)+,(A1)+
	DBF	D1,SKIDZ3

	MOVE.L	CUBE_COL1,(A1)
	ADDQ	#4,A1
	LEA	SKIDZ+4,A0
	MOVE	#30,D1
SKIDZ4
	MOVE.L	(A0)+,(A1)+
	DBF	D1,SKIDZ4

	MOVE.L	CUBE_COL1,(A1)
	ADDQ	#4,A1
	LEA	SKIDZ+4,A0
	MOVE	#30,D1
SKIDZ5
	MOVE.L	(A0)+,(A1)+
	DBF	D1,SKIDZ5

	MOVE	#255-32*4,D1
SKIDZ6
	MOVE.L	CUBE_COL1,(A1)+
	DBF	D1,SKIDZ6
	move.l	#$2510,d0
	movec.l	d0,CACR
	RTS
AFF_GFX
	MOVE.L	#$3111,D0
	MOVEC.L	D0,CACR
	LEA	SKIDZ+1024,A0
	MOVE.L	WORKECR,A1
	MOVE.L	AFFECR,A2
	LEA	384*70(A1),A1
	LEA	384*70(A2),A2
	MOVE	#320*200/4-1,D0	
LOOP_GFX
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	DBF	D0,LOOP_GFX
	MOVE.L	#$2510,D0
	MOVEC.L	D0,CACR
	RTS
AFF_GFX2
	MOVE.L	#$3111,D0
	MOVEC.L	D0,CACR
	LEA	SKIDZ+1024,A0
	MOVE.L	WORKECR,A1
	LEA	384*70(A1),A1
	MOVE	#320*200/4-1,D0	
LOOP_GFX2
	MOVE.L	(A0)+,(A1)+
	DBF	D0,LOOP_GFX2
	MOVE.L	#$2510,D0
	MOVEC.L	D0,CACR
	RTS
MAKE_CODE
	ADD.W	#6,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NO_STOP24
	CLR.W	Y_ANGLE
NO_STOP24
	BSR	TRIGO
	LEA	OXE1,A0
	LEA	OYE1,A1
	LEA	OZE1,A2
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#22,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO4
	MOVEM.L	D0/A0-A2,-(SP)		
	MOVE.W	(A0),D0
	MOVE.W	(A1),D1
	MOVE.W	(A2),D2
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
	ADD.W	#140,D2
	ADD.W	ADD_BAS,D2
	MOVEM.L	(SP)+,D0/A0-A2
	ADDQ	#6,A0
	ADDQ	#6,A1
	ADDQ	#6,A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO4
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS

TRACE4
;LE C
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE11
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE11
	MOVE.W	DY,PTS
	MOVE.W	DY+4,PTS+2
	MOVE.W	DY+6,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE12
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
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
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE12
;LE O
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE13
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
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE13
	MOVE.W	DY+10,PTS
	MOVE.W	DY+14,PTS+2
	MOVE.W	DY+16,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE14
	MOVE.W	DX+10,CX1
	MOVE.W	DY+10,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+10,CX2
	MOVE.W	DY+10,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE14
;LE D
	MOVE.W	DY+18,PTS
	MOVE.W	DY+20,PTS+2
	MOVE.W	DY+22,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE5
	MOVE.W	DX+18,CX1
	MOVE.W	DY+18,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+20,CX1
	MOVE.W	DY+20,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE5
;LE E
	MOVE.W	DY+24,PTS
	MOVE.W	DY+26,PTS+2
	MOVE.W	DY+28,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE6
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+26,CX1
	MOVE.W	DY+26,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+28,CX1
	MOVE.W	DY+28,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE6
	MOVE.W	DY+24,PTS
	MOVE.W	DY+30,PTS+2
	MOVE.W	DY+32,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE7
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+30,CX2
	MOVE.W	DY+30,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+30,CX1
	MOVE.W	DY+30,CY1
	MOVE.W	DX+32,CX2
	MOVE.W	DY+32,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+32,CX1
	MOVE.W	DY+32,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE7
	MOVE.W	DY+34,PTS
	MOVE.W	DY+36,PTS+2
	MOVE.W	DY+38,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE8
	MOVE.W	DX+34,CX1
	MOVE.W	DY+34,CY1
	MOVE.W	DX+36,CX2
	MOVE.W	DY+36,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+36,CX1
	MOVE.W	DY+36,CY1
	MOVE.W	DX+38,CX2
	MOVE.W	DY+38,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+38,CX1
	MOVE.W	DY+38,CY1
	MOVE.W	DX+34,CX2
	MOVE.W	DY+34,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE8
;SUITE DU O
	MOVE.W	DY+40,PTS
	MOVE.W	DY+42,PTS+2
	MOVE.W	DY+44,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NO_FACE9
	MOVE.W	DX+40,CX1
	MOVE.W	DY+40,CY1
	MOVE.W	DX+42,CX2
	MOVE.W	DY+42,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+42,CX1
	MOVE.W	DY+42,CY1
	MOVE.W	DX+44,CX2
	MOVE.W	DY+44,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+44,CX1
	MOVE.W	DY+44,CY1
	MOVE.W	DX+40,CX2
	MOVE.W	DY+40,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NO_FACE9
	rts
EFFA4
	LEA	CLR,A0
	MOVE.L	WORKECR,A1
	ADD.L	#18*384,A1
	MOVEQ	#0,D2
 	MOVE.B	#2,$FFFF8A3A		; coupe ram de demi teinte
	MOVE.B	#0,$FFFF8A3B		; operations logiques
	MOVE.W	#0,$FF8A22			; Increment Vertical Source
	MOVE.W	#0,$FF8A20			; distance entre un mot et le suivant
	MOVE.W	#24,$FF8A36		; taille d'une ligne en mots
	MOVE.W	#-1,$FF8A28		; 3 registres pour les masques
	MOVE.W	#-1,$FF8A2A		; (permet de gerer au pixel pres !!)	
	MOVE.W	#-1,$FF8A2C		
;dest
	MOVE.W	#16,$FFFF8A2E		; Increment Horizontal Destination
	MOVE.W	#16,$FFFF8A30		; IVD
*****PLAN-1***********
; source	
	MOVE.L	A0,$FF8A24			; addresse bloc a transferer
	MOVE.W	#280-18,$FF8A38		; taille verticale
; destination
	MOVE.L	A1,$FFFF8A32	
	MOVE.B	D2,$FFFF8A3D		; registre pour decalage vers la droite
;		  XXX-XXXX			; registre de controle
 	MOVE.B	#%11000000,$FF8A3C    	; si bit 6 a 0:PARTAGE DE BUS sinon 680*0 stoppe jusqu'a fin du transfert				
	RTS
MAKE_SND
	ADD.W	#6,Y_ANGLE
	CMPI.W	#720,Y_ANGLE
	BLT.S	NNO_STOP2 
	CLR.W	Y_ANGLE
NNO_STOP2
	ADD.W	#4,Z_ANGLE
	CMPI.W	#720,Z_ANGLE
	BLT.S	NNO_STOP3
	CLR.W	Z_ANGLE
NNO_STOP3 
	BSR	TRIGO
	LEA	FXE1,A0
	LEA	FYE1,A1
	LEA	FZE1,A2
	LEA	DX,A5
	LEA	DY,A4
	MOVE	#20,D0
	MOVE.L	#$3111,D6		;cache on
	MOVEC.L	D6,CACR
	MOVEQ.W	#9,D6
LOOP_TRIGO8
	MOVEM.L	D0/A0-A2,-(SP)		
	MOVE.W	(A0),D0
	MOVE.W	(A1),D1
	MOVE.W	(A2),D2
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
	ADD.W	#140,D2
	ADD.W	ADD_BAS,D2
	MOVEM.L	(SP)+,D0/A0-A2
	ADDQ	#6,A0
	ADDQ	#6,A1
	ADDQ	#6,A2
	MOVE.W	D5,(A5)+
	MOVE.W	D2,(A4)+
	DBF	D0,LOOP_TRIGO8
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS

TTRACE
;LE S
	MOVE.W	DY,PTS
	MOVE.W	DY+2,PTS+2
	MOVE.W	DY+4,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE
	MOVE.W	DX,CX1
	MOVE.W	DY,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX+2,CX2
	MOVE.W	DY+2,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+4,CX1
	MOVE.W	DY+4,CY1
	MOVE.W	DX,CX2
	MOVE.W	DY,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE
	MOVE.W	DY+4,PTS
	MOVE.W	DY+6,PTS+2
	MOVE.W	DY+8,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE2
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
	MOVE.W	DX+4,CX2
	MOVE.W	DY+4,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE2
	MOVE.W	DY+8,PTS
	MOVE.W	DY+10,PTS+2
	MOVE.W	DY+12,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE3
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
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE3
;LE N
	MOVE.W	DY+14,PTS
	MOVE.W	DY+16,PTS+2
	MOVE.W	DY+18,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE4
	MOVE.W	DX+14,CX1
	MOVE.W	DY+14,CY1
	MOVE.W	DX+16,CX2
	MOVE.W	DY+16,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+16,CX1
	MOVE.W	DY+16,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+18,CX1
	MOVE.W	DY+18,CY1
	MOVE.W	DX+14,CX2
	MOVE.W	DY+14,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE4
	MOVE.W	DY+18,PTS
	MOVE.W	DY+20,PTS+2
	MOVE.W	DY+22,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE5
	MOVE.W	DX+18,CX1
	MOVE.W	DY+18,CY1
	MOVE.W	DX+20,CX2
	MOVE.W	DY+20,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+20,CX1
	MOVE.W	DY+20,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+18,CX2
	MOVE.W	DY+18,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE5
	MOVE.W	DY+22,PTS
	MOVE.W	DY+24,PTS+2
	MOVE.W	DY+26,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE6
	MOVE.W	DX+22,CX1
	MOVE.W	DY+22,CY1
	MOVE.W	DX+24,CX2
	MOVE.W	DY+24,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+24,CX1
	MOVE.W	DY+24,CY1
	MOVE.W	DX+26,CX2
	MOVE.W	DY+26,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+26,CX1
	MOVE.W	DY+26,CY1
	MOVE.W	DX+22,CX2
	MOVE.W	DY+22,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE6
;LE 'D'
	MOVE.W	DY+28,PTS
	MOVE.W	DY+30,PTS+2
	MOVE.W	DY+32,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE7
	MOVE.W	DX+28,CX1
	MOVE.W	DY+28,CY1
	MOVE.W	DX+30,CX2
	MOVE.W	DY+30,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+30,CX1
	MOVE.W	DY+30,CY1
	MOVE.W	DX+32,CX2
	MOVE.W	DY+32,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+32,CX1
	MOVE.W	DY+32,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE7
	MOVE.W	DY+32,PTS
	MOVE.W	DY+34,PTS+2
	MOVE.W	DY+36,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE8
	MOVE.W	DX+32,CX1
	MOVE.W	DY+32,CY1
	MOVE.W	DX+34,CX2
	MOVE.W	DY+34,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+34,CX1
	MOVE.W	DY+34,CY1
	MOVE.W	DX+36,CX2
	MOVE.W	DY+36,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+36,CX1
	MOVE.W	DY+36,CY1
	MOVE.W	DX+32,CX2
	MOVE.W	DY+32,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE8
	MOVE.W	DY+36,PTS
	MOVE.W	DY+38,PTS+2
	MOVE.W	DY+28,PTS+4
	BSR	INIT_FACE_CLIP
	TST	D4
	BNE	NNO_FACE9
	MOVE.W	DX+36,CX1
	MOVE.W	DY+36,CY1
	MOVE.W	DX+38,CX2
	MOVE.W	DY+38,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+38,CX1
	MOVE.W	DY+38,CY1
	MOVE.W	DX+28,CX2
	MOVE.W	DY+28,CY2
	BSR	TRACE_FACE
	MOVE.W	DX+28,CX1
	MOVE.W	DY+28,CY1
	MOVE.W	DX+36,CX2
	MOVE.W	DY+36,CY2
	BSR	TRACE_FACE
	MOVEQ	#0,D4
	BSR	REMPLI_CLIP
NNO_FACE9
	rts
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA5
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	#$3111,D0
	MOVEC.L	D0,CACR
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ	#0,D0
	MOVE.W	#279,D1
.EFF
OXO	SET	0
	REPT	24
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+16
	ENDR
	LEA	384(A1),a1
	DBF	D1,.EFF
	MOVE.L	#$2510,D0
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A1
	RTS

*************************************************************************************
*********************THE END*********************************************************
*************************************************************************************
Fin
	clr.l	$4d2
*	MOVE.B	SAVE_A09,$FFFFA09
*	MOVE.B	SAVE_A07,$FFFFA07	
*	MOVE.L	SAVE_HBL,$120.W
*	MOVE.B	SAVE_A1B,$FFFFA1B	
*	MOVE.B	SAVE_A21,$FFFFA21	
*	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS,-(SP)
	MOVE.L	OLDXBIOS,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	move.w	#$fff,$ffff8240
	bsr	vbl
	clr.b	TBCR(a6)		;D‚branche tout, et cassos
	bclr	#0,IERA(a6)	;
 	bclr	#0,IMRA(a6)	;
	move.l	save_vtb,V_TB.w	;
	move.b	save_vr,VR(a6)	;
fini	clr.b	$ffff8901.w	;
	clr.l	-(sp)		;Coupe la sortie son du DSP,
	Xbios	Snd_DspTriState	;pour pas merder.
	trap	#1		;Cassos
	moveq	#6,d7		;R‚glages sonores: 
	moveq	#3,d6		;(6,3);(5,3);(4,3);(1,$x0);(0,$x0)
.soundsys	cmp.w	d6,d7		;couple (3,3) ?
	bne.s	.soundset		;
	moveq	#1,d7		;Oui->passe au couple (1,$x0)
	move.w	#$e0,d6		;La valeur est modifi‚e en court
.soundset	move.w	d6,-(sp)		;de route..
	move.w	d7,-(sp)		;Un couple...
	Xbios	Snd_Cmd		;
	dbf	d7,.soundsys	;Suivant
.pcm_frq	move.w	#1,-(sp)		;Voil…, on a remis le son
	clr.l	-(sp)		;dans un ‚tat correct.
	pea	8.w		;
	Xbios	Snd_DevConnect	;
	clr.w	(sp)		;Et on se casse !!.
	trap	#1		;

	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\3D_256.COL\REMPL256.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\3D_STUFF.S\CACHE2.S"
	INCLUDE	"C:\UTILS\CODE_UTI.LS\GEN_ASM\FULLFACE\3D_256.COL\REMPCLIP.S"

	Section	DATA
X1		DC.W	0
Y1		DC.W	0
Z1		DC.W	0
X2		DC.W	0
Y2		DC.W	0
Z2		DC.W	0
X3		DC.W	0
Y3		DC.W	0
Z3		DC.W	0
EZ		DC.W	200
EX		DC.W	0
EY		DC.W	0
COMPT		DC.W	0
OLDXBIOS:		DC.L	0
save_vtb		dc.l	0
save_vr		dc.b	0
AFFECR:		DC.L	0
WORKECR		DC.L	0
OLDMODECODE:	DC.L	0
LOGBASE2		DC.L	0
PHYSBASE2		DC.L	0
OLD_CACR		DC.L	0
SAV_CY1		DC.W	0
IND		DC.B	0
FORME3		INCBIN	"C:\UTILS\CODE_UTI.LS\GEN_ASM\MULTIPAR.T\V.INL"
FORME		DC.W	%1111111111111111,%0111111111111111,%0011111111111111,%0001111111111111,%0000111111111111,%0000011111111111,%0000001111111111,%0000000111111111,%0000000011111111,%0000000001111111,%0000000000111111,%0000000000011111
		DC.W	%0000000000001111,%0000000000000111,%0000000000000011,%0000000000000001,0
FORME2		DC.W	%1000000000000000,%1100000000000000,%1110000000000000,%1111000000000000,%1111100000000000,%1111110000000000,%1111111000000000,%1111111100000000,%1111111110000000,%1111111111000000,%1111111111100000
		DC.W	%1111111111110000,%1111111111111000,%1111111111111100,%1111111111111110,%1111111111111111
COS_TAB		INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\COSIN.DAT"
SIN_TAB		EQU	COS_TAB+720	
DX		DS.W	50
DY		DS.W	50
*************
XEE1		DC.W	0
YEE1		DC.W	264
;
XEE2		DC.W	380
YEE2		DC.W	264
;
XEE3		DC.W	380
YEE3		DC.W	265
;
XEE4		DC.W	0
YEE4		DC.W	265
*****************
CURV1		INCBIN	C:\UTILS\CODE_UTI.LS\GFABASIC\CURV1.INL
*****************
CX1		DC.W	0
CY1		DC.W	0
CX2		DC.W	0
CY2		DC.W	0
SCREEN_ADD		DC.L	0
YMAX		DC.W	0
YMIN		DC.W	0
HAUTEUR		DC.W	0
PLAN		DC.W	0
****LE 'X'**********
XE1		DC.W	15
YE1		DC.W	15
ZE1		DC.W	0
;
XE2		DC.W	20
YE2		DC.W	15
ZE2		DC.W	0
;
XE3		DC.W	35
YE3		DC.W	-15
ZE3		DC.W	0
;
XE4		DC.W	30
YE4		DC.W	-15
ZE4		DC.W	0
;
XE5		DC.W	30
YE5		DC.W	15
ZE5		DC.W	0
;
XE6		DC.W	35
YE6		DC.W	15
ZE6		DC.W	0
;
XE7		DC.W	20
YE7		DC.W	-15
ZE7		DC.W	0
;
XE8		DC.W	15
YE8		DC.W	-15
ZE8		DC.W	0
;*****LE 'F'********
XE9		DC.W	-10
YE9		DC.W	15
ZE9		DC.W	0
;
XE10		DC.W	-10
YE10		DC.W	-15
ZE10		DC.W	0
;
XE11		DC.W	-5
YE11		DC.W	-15
ZE11		DC.W	0
;
XE12		DC.W	-5
YE12		DC.W	10
ZE12		DC.W	0
;
XE13		DC.W	10
YE13		DC.W	10
ZE13		DC.W	0
;
XE14		DC.W	10
YE14		DC.W	15
ZE14		DC.W	0
;
XE15		DC.W	-5
YE15		DC.W	0
ZE15		DC.W	0
;
XE16		DC.W	5
YE16		DC.W	0
ZE16		DC.W	0
;
XE17		DC.W	5
YE17		DC.W	5
ZE17		DC.W	0
;
XE18		DC.W	-5
YE18		DC.W	5
ZE18		DC.W	0
*****LE 'G'**********
;
XE19		DC.W	-15
YE19		DC.W	15
ZE19		DC.W	0
;
XE20		DC.W	-15
YE20		DC.W	10
ZE20		DC.W	0
;
XE21		DC.W	-30
YE21		DC.W	10
ZE21		DC.W	0
;
XE22		DC.W	-35
YE22		DC.W	15
ZE22		DC.W	0
;
XE23		DC.W	-35
YE23		DC.W	-15
ZE23		DC.W	0
;
XE24		DC.W	-30
YE24		DC.W	-10
ZE24		DC.W	0
;
XE25		DC.W	-20
YE25		DC.W	-10
ZE25		DC.W	0
;
XE26		DC.W	-15
YE26		DC.W	-15
ZE26		DC.W	0
;
XE27		DC.W	-15
YE27		DC.W	0
ZE27		DC.W	0
;
XE28		DC.W	-20
YE28		DC.W	-5
ZE28		DC.W	0
****GRAND CUBE**********
XE1C		DC.W	-63
YE1C		DC.W	63
ZE1C		DC.W	63
;
XE2C		DC.W	-63
YE2C		DC.W	-63
ZE2C		DC.W	63

;
XE3C		DC.W	63
YE3C		DC.W	-63
ZE3C		DC.W	63
;
XE4C		DC.W	63
YE4C		DC.W	63
ZE4C		DC.W	63
;
XE5C		DC.W	63
YE5C		DC.W	63
ZE5C		DC.W	-63
;
XE6C		DC.W	-63
YE6C		DC.W	63
ZE6C		DC.W	-63
;
XE7C		DC.W	-63
YE7C		DC.W	-63
ZE7C		DC.W	-63
;
XE8C		DC.W	63
YE8C		DC.W	-63
ZE8C		DC.W	-63
*****************
****LE 'C'**********
OXE1		DC.W	-50+3
OYE1		DC.W	0
OZE1		DC.W	0
;
OXE2		DC.W	-30+3
OYE2		DC.W	10
OZE2		DC.W	0
;
OXE3		DC.W	-40+3
OYE3		DC.W	0
OZE3		DC.W	0
;
OXE4		DC.W	-30+3
OYE4		DC.W	-10
OZE4		DC.W	0
****LE 'O'***********
OXE5		DC.W	-25+3
OYE5		DC.W	-10
OZE5		DC.W	0
;
OXE6		DC.W	-15+3
OYE6		DC.W	10
OZE6		DC.W	0
;
OXE7		DC.W	-20+3
OYE7		DC.W	-10
OZE7		DC.W	0
;
OXE8		DC.W	-10+3
OYE8		DC.W	-10
OZE8		DC.W	0
;
OXE9		DC.W	-5+3
OYE9		DC.W	-10
OZE9		DC.W	0
;
****LE 'D'**************
OXE10		DC.W	0+3
OYE10		DC.W	10
OZE10		DC.W	0
;
OXE11		DC.W	0+3
OYE11		DC.W	-10
OZE11		DC.W	0
;
OXE12		DC.W	20+3
OYE12		DC.W	-3
OZE12		DC.W	0
;
****LE 'E'**************
OXE13		DC.W	25+3
OYE13		DC.W	0
OZE13		DC.W	0
;
OXE14		DC.W	45+3
OYE14		DC.W	10
OZE14		DC.W	0
;
OXE15		DC.W	30+3
OYE15		DC.W	-2
OZE15		DC.W	0
;
OXE16		DC.W	30+3
OYE16		DC.W	2
OZE16		DC.W	0
;
OXE17		DC.W	45+3
OYE17		DC.W	-10
OZE17		DC.W	0
;
OXE18		DC.W	32+3
OYE18		DC.W	-2
OZE18		DC.W	0
;
OXE19		DC.W	32+3
OYE19		DC.W	2
OZE19		DC.W	0
;
OXE20		DC.W	45+3
OYE20		DC.W	0
OZE20		DC.W	0
*****************
;SUITE DU O
OXE21		DC.W	-25+3
OYE21		DC.W	-10
OZE21		DC.W	0
;
OXE22		DC.W	-22+3
OYE22		DC.W	-6
OZE22		DC.W	0
;
OXE23		DC.W	-5+3
OYE23		DC.W	-10
OZE23		DC.W	0
;
*****************
****LE 'S'**********
FXE1		DC.W	-20
FYE1		DC.W	10
FZE1		DC.W	0
;
FXE2		DC.W	-40
FYE2		DC.W	7
FZE2		DC.W	0
;
FXE3		DC.W	-40
FYE3		DC.W	3
FZE3		DC.W	0
;
FXE4		DC.W	-37
FYE4		DC.W	5
FZE4		DC.W	0
;
FXE5		DC.W	-20
FYE5		DC.W	-3
FZE5		DC.W	0
;
FXE6		DC.W	-25
FYE6		DC.W	-1
FZE6		DC.W	0
;
FXE7		DC.W	-40
FYE7		DC.W	-15
FZE7		DC.W	0
*********LE 'N'**********
;
FXE8		DC.W	-10
FYE8		DC.W	-10
FZE8		DC.W	0
;
FXE9		DC.W	-10
FYE9		DC.W	10
FZE9		DC.W	0
;
FXE10		DC.W	-5
FYE10		DC.W	10
FZE10		DC.W	0
;
FXE11		DC.W	-7
FYE11		DC.W	6
FZE11		DC.W	0
;
FXE12		DC.W	10
FYE12		DC.W	-10
FZE12		DC.W	0
;
FXE13		DC.W	10
FYE13		DC.W	10
FZE13		DC.W	0
;
FXE14		DC.W	5
FYE14		DC.W	-3
FZE14		DC.W	0
*********LE 'D'**************
;
FXE15		DC.W	20
FYE15		DC.W	10
FZE15		DC.W	0
;
FXE16		DC.W	20
FYE16		DC.W	-10
FZE16		DC.W	0
;
FXE17		DC.W	25
FYE17		DC.W	-10
FZE17		DC.W	0
;
FXE18		DC.W	22
FYE18		DC.W	-5
FZE18		DC.W	0
;
FXE19		DC.W	40
FYE19		DC.W	-10
FZE19		DC.W	0
;
FXE20		DC.W	35
FYE20		DC.W	-9
FZE20		DC.W	0
*****************
ADD_BAS		DC.W	0
COL:		DS.B	1024
SAVE_HBL:		DC.L	0
SAVE_A1B:		DC.B	0
SAVE_A21:		DC.B	0
SAVE_A07:		DC.B	0
SAVE_A09:		DC.B	0
SAVE_A13:		DC.B	0
XDEP		DC.W	0
YDEP		DC.W	0
ZDEP		DC.W	-140
X_ANGLE		DC.W	0
Y_ANGLE		DC.W	0
Z_ANGLE		DC.W	0
OK2		DC.W	0
SX		DS.W	50
SY		DS.W	50
SZ		DS.W	50
NEW_XE		DC.L	0
NEW_YE		DC.L	0
NEW_ZE		DC.L	0
FOND		DC.L	$44000044
CUBE_COL1		DC.L	0
SKIDZ		INCBIN	F:\ZIK_DISK.HDX\SKIDZ.HDX
	even
yoman		incbin	f:\divers.dsp\sndtrack.dsp\dsp_play.bin	;Routine de mixage!
dsp_play		equ	yoman+$1c
	even
mod		incbin	f:\ZIK_DISK.HDX\KEEL.NTK		;Mettez votre module NTK ici
TEXT		incbin	C:\UTILS\CODE_UTI.LS\GFABASIC\TEXT.INL
fnt		incbin	F:\ZIK_DISK.HDX\FNT_32.HDX
PIC		INCBIN	F:\ZIK_DISK.HDX\PRESENT.HDX
PRESENT2		INCBIN	F:\ZIK_DISK.HDX\PRESENT2.HDX
Logo		INCBIN	F:\ZIK_DISK.HDX\LOGO.HDX
	Section	BSS
		DS.L	1000
PILE		DS.L	10
VAR_3D		DS.W	9
CLEAR:		DS.L	16
Y_TABLE		DS.L	340
CLR		DS.L	17
freq_buf		ds.l	907-108+1		;Buffer indispensable
XMAX		DS.W	300
XMIN		DS.W	300
PTS		DS.W	10
COLOR		DS.L	255*256
XBIOS3:		DS.B	560*768*2
	END
  																																										  																																						