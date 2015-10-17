*******************************************************
*              LITTLE SPLINE ROUTINE                  *
*             by  Cristalion/Hydroxid  	          *
*******************************************************

*	opt	o+,d+,w+

*******************
nbdots	=	2550
offsetx2	=	4
offsety2	=	2	
speedx2	=	4
speedy2	=	2
col1	=	$FFFF00FF
col2	=	$CCCC00CC
col3	=	$99990099
col4	=	$66660066
*******************
	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	VBL
	MOVE.B	#18,$FFFFC02
	MOVE.L	$70,OLD_VBL
	MOVE.B	$FFFFA09,OLD_A09
	MOVE.B	#$40,$FFFFA09
	MOVE.L	#NEW_VBL,$70
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	BSR	MAKE_CRIST
	move.w	#6,plan
	move.w	#1,OK2
*******
	BSR	SPLINE2
*;*
*******
	BRA	FIN	
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
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100010,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

 	move.l 	$44e.w,d0
	MOVE.L	d0,A1
	add.l	#46080,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	MOVE.L	A1,AFFINIT
	MOVE.L	A2,WORKINIT
	RTS

***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
NEW_VBL
	addq	#1,$466.l
	rte
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
MAKE_CRIST
	LEA	Y_TABLE,A1
	MOVE.B	#241,D1
	MOVEQ.W	#0,D2
MAKE
	MOVE.W	D2,(A1)+
	ADD.W	#192,D2
	DBF	D1,MAKE
	RTS
MAKE_SPLINE	
	lea	SPLINE_X,a0
	moveq.b	#50,d1
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
	move.l 	workecr,a1
	MOVE.W	#11519,D0
	MOVEQ	#0,D1
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(A1)+
	DBF	D0,OK
	MOVEM.L	(SP)+,D0/A0-a1
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
****boucle****
SPLINE_LOOP2
	CLR.L	$FFFF9800
	bsr	choose_col
	bsr	EFFA

	addq.w	#4,pos			; inc courbe 
	cmpi.w	#1440,pos
	bne.s	jump2
	clr.w	pos
jump2

	move.w	#nbdots,d7		; nombre de points
	move.l	WORKECR,a0	
	add.l	#192*10,a0	
	lea	SPLINE_X,a1			
	lea	SPLINE_Y,a2
	move.w	pos,d6
	MOVE.L	#$3111,D0		; cache on ... 
	MOVEC	D0,CACR			
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
	MOVE.W	(A5,D3.W*2),D5 		; coord y
	MOVE.L	(A4,D2.W*4),D3		; coord x
	ADD.W	D3,D5
	SWAP	D3
	OR.W	D3,(A0,D5.L)		
	DBF	D7,PLOT2	
	MOVE.L	#$2510,D7		; cache on ... 
	MOVEC	D7,CACR			

	MOVEM.L	A1-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	MOVEM.L	(SP)+,A1-A2

	addq.l 	#2,affecr
	move.w 	affecr+2,d0
 	andi.w 	#8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s 	trainee3			; on boucle
 	subq.w 	#8,affecr+2
trainee3
	cmpi.b	#56,$fffffc02
	bne.s	ALT3
	MOVE.L	#$000000FF,$FFFF9800
ALT3
	CMPI.B	#57,$FFFFC02
	BEQ	END_PART2
	BSR	VBL
	BRA	SPLINE_LOOP2 
END_PART2
	RTS
*********************
RESTORE_SCREEN
	MOVE.L	WORKINIT,WORKECR
	MOVE.L	AFFINIT,AFFECR
	RTS
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#0,A1
	MOVEQ	#0,D0
	MOVE.W	#210/2,D1
	MOVE.L	#$3111,D7		; cache on ... 
	MOVEC	D7,CACR			
.EFF
OXO	SET	0
	REPT	24*2
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+8
	ENDR
	LEA	192*2(A1),A1
	DBF	D1,.EFF
	MOVE.L	#$2510,D0		; cache on ... 
	MOVEC	D0,CACR			
	RTS
**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

FIN	
	CLR.L	$4D2
	MOVE.L	OLD_CACR,D0
	MOVEC	D0,CACR
	MOVE.L	OLD_VBL,$70
	MOVE.B	OLD_A09,$FFFFA09
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#8,$FFFFC02
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

***********************************************************************
***********************************************************************
		SECTION DATA
OLD_VBL		DC.L	0
OLD_A09		DC.L	0
OK2		DC.W	0
PLAN		DC.W	0
OLD_CACR		DC.L	0
SAVE_HBL:		DC.L	0
SAVE_A1B:		DC.B	0
SAVE_A21:		DC.B	0
SAVE_A07:		DC.B	0
SAVE_A09:		DC.B	0
SAVE_A13:		DC.B	0
SAVE_REZ:		DC.W	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
AFFINIT:		DC.L 	0
WORKINIT:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
SCREEN_ADD		DC.L	0
POS:		dc.w	12
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+8
	ENDR
XCURV		incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\MULTIPAR.T\doublex4.dat"
YCURV		incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\MULTIPAR.T\doubley3.dat"
		SECTION BSS
Y_TABLE		DS.W	250
CLR		DS.L	16
		DS.L	2000
PILE		DS.L	10
SPLINE_X		DS.W	150000
SPLINE_Y		DS.W 	150000
SCREEN		DS.W	100000
	END
				 	  																																																																								 																								 																								