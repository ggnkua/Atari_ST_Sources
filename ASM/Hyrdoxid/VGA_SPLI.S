*******************************************************
*              LITTLE SPLINE ROUTINE           	      *
*             by  Cristalion/Hydroxid  		      *
*******************************************************

*	opt	o+,d+,w+

*******************
nbdots=		2400
offsetx2=	4
offsety2=	4	
speedx2	=	2
speedy2	=	4
*******************
	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	VBL
*	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	INITS
	BSR	INIT_RAST
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	INIT_PAL
	BSR	VBL
*******
	BSR	SPLINE2
*;*
*******
	BRA	FIN	
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
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

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	 #92160,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	MOVE.L	A1,AFFINIT
	MOVE.L	A2,WORKINIT
	RTS

***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
TIMER
	MOVE.L	#TIMER_B1,$120.W
	MOVE.B	#200,$FFFFFA21.W
	MOVE.B	#8,$FFFFA1B
	RTS
TIMER_B1	
	MOVE.W	#$2700,SR
	MOVE.B	#$6F,$FFFF9800
	MOVE.B	#$6F,$FFFF9801
	MOVE.B	#$6F,$FFFF9803
	CLR.B	$FFFFA21	
	CLR.B	$FFFFA1B
	BCLR	#0,$FFFFFA0F.W	
	MOVE.W	#$2300,SR	
	RTE

INIT_RAST:
	move.l	$120.W,SAVE_HBL
	move.b	$ffffa1b,SAVE_A1B
	move.b	$ffffa09,SAVE_A09
	move.b	$ffffa21,SAVE_A21
	move.b	$ffffa07,SAVE_A07
	move.b	$ffffa13,SAVE_A13
	
	and.b	#$40,$fffa09
	or.b	#1,$fffa07
	or.b	#1,$fffa13	
	RTS
MAKE_SPLINE	
	lea	SPLINE_X,a0
	moveq.b	#100,d1
MAKEX
	move.w	#359,d2
	lea	XCURV,a1
MAKEX2
	move.l	(a1)+,(a0)+
	dbf	d2,MAKEX2	
	dbf	d1,MAKEX

	lea	SPLINE_Y,a0
	moveq.b	#100,d1
MAKEY
	move.w	#359,d2
	lea	YCURV,a1
MAKEY2
	move.l	(a1)+,(a0)+
	dbf	d2,MAKEY2	
	dbf	d1,MAKEY
	rts

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d7/a0-a6
	rts
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l workecr,a1
	MOVE.W	#23040,D0
OK
	CLR.L	(A0)+
	CLR.L 	(A1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
REFLET
	MOVE.L	WORKECR,A0
	MOVE.L	A0,A1
	ADD.L	#384*200,A1
	ADD.L	#384*199,A0
	MOVEQ.W	#39,D1
AFF_REFLET
	MOVEQ.L	#23,D0	
AFF_REFLET2	
	MOVE.W	(A0),(A1)
	LEA	16(A0),A0
	LEA	16(A1),A1
	DBF	D0,AFF_REFLET2
	LEA	-768(A0),A0
	DBF	D1,AFF_REFLET
	RTS
******************************************************************************************
******************************SPLINE ROUT*************************************************
******************************************************************************************
**********************************
SPLINE2
	BSR	MAKE_SPLINE
	BSR	CLS
	BSR	CLR_REGISTERS
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.L	#TIMER,$4D2
****boucle****
SPLINE_LOOP2
	MOVE.B	#$9F,$FFFF9800
	MOVE.B	#$9F,$FFFF9801
	MOVE.B	#$9F,$FFFF9803
	bsr	EFFA
	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump2
	clr.w	pos
jump2

	move.w	#2100,d7		; nombre de points
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
	move.w	(a1,d5.l),d2		;on point sur tabx
	move.w	(a2,d4.l),d3		;on point sur taby
	add.w	(a1,d6.w),d2		;on point sur tabx
	add.w	(a2,d6.w),d3		;on point sur taby
* routine de point
	MOVE.L	(A5,D3.W*4),D5 		; coord y
	MOVE.L	(A4,D2.W*4),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.L)		
	DBF	D7,PLOT2	
*	BSR	REFLET

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	addq.l #2,affecr
	move.w affecr+2,d0
 	andi.w #16,d0			; si on a fait les 4 plans			
	cmpi.w	#16,d0
	bne.s trainee3			; on boucle
 	sub.w #16,affecr+2
trainee3
	cmpi.b	#56,$fffffc02
	bne.s	ALT3
	CLR.B	$FFFF9800
	CLR.B	$FFFF9801
	MOVE.B	#$FF,$FFFF9803
ALT3
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	SPLINE_LOOP2 
	RTS
*********************
RESTORE_SCREEN
	MOVE.L	WORKINIT,WORKECR
	MOVE.L	AFFINIT,AFFECR
	RTS
INIT_PAL
	LEA	$FFFF9800,A0
	MOVE.W	#254,D0
	CLR.B	(A0)
	CLR.B	1(A0)
	CLR.B	3(A0)
MAKE_PAL
	ADDQ.L	#4,A0
	MOVE.B	#$FF,(A0)
	MOVE.B	#$FF,1(A0)
	MOVE.B	#$FF,3(A0)
	DBF	D0,MAKE_PAL
	RTS
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ	#0,D0
	MOVE.W	#200,D1
.EFF
OXO	SET	0
	REPT	24
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+16
	ENDR
	LEA	384(A1),a1
	DBF	D1,.EFF
	MOVEM.L	(SP)+,D0/A1
	RTS
**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

FIN	
	CLR.L	$4D2
	MOVE.B	SAVE_A09,$FFFFA09
	MOVE.B	SAVE_A07,$FFFFA07	
	MOVE.L	SAVE_HBL,$120.W
	MOVE.B	SAVE_A1B,$FFFFA1B	
	MOVE.B	SAVE_A21,$FFFFA21	
	MOVE.B	SAVE_A13,$FFFFA13	
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
*	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

***********************************************************************
***********************************************************************
		SECTION DATA

SAVE_HBL:	DC.L	0
SAVE_A1B:	DC.B	0
SAVE_A21:	DC.B	0
SAVE_A07:	DC.B	0
SAVE_A09:	DC.B	0
SAVE_A13:	DC.B	0
SAVE_REZ:	DC.W	0
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
AFFINIT:	DC.L 	0
WORKINIT:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
PLAN:		DC.B	0
SCREEN_ADD	dc.l	0
POS:		dc.w	12
colors3		dc.w 	$FFF,$FFF,$FFF,$FFF
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+16
	ENDR
Y_TABLE	
CRIST	SET 	0
	REPT	240
	DC.L	CRIST
CRIST	SET	CRIST+384
	ENDR
XCURV	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\doublex4.dat"
YCURV	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\doubley3.dat"
		SECTION BSS
CLR		DS.L	16
		DS.L	2000
PILE		DS.L	10
SPLINE_X	DS.W	150000
SPLINE_Y	DS.W	150000
SCREEN		DS.W	200000
	END
  																								