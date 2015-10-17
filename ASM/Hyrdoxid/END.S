*************************
*'END' for THE multipart*
*by  Cristalion/Hydroxid*
*************************

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	CLR.W	$FFFF8240
	BSR	INITS
	BSR	CLS
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	bsr	VBL
	CLR.W	$FFFF8240
	BSR	ROUT_SPRITES
	lea.l colors,a0
	lea.l $ffff8240.w,a1
	bsr	SHADE_COL
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b AFFECR+1,$ffff8201.w
	move.b AFFECR+2,$ffff8203.w
	addq.l #2,AFFECR
	move.w AFFECR+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee			; on boucle
 	subq.w #8,AFFECR+2
trainee
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.W	#5,$FFFF8240
NO_ALT
	CMPI.B	#57,$FFFFC02
	BNE.S	LOOP
	BRA	FIN
***************************INITIALISATIONS*********************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$9B00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	WORKECR,-(SP)
	MOVE.L	WORKECR,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS
******************************LA ROUTINE D'EFFACAGE PLAN1**********************
EFFA
	MOVEM.L	A1/D1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVEQ.W	#0,D0
	MOVEQ.W	#14,D1
	LEA	24(A1),A1	
.EFF
OXO	SET	11*160
	REPT	175
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+160
	ENDR	
	LEA	8(A1),A1
	DBF	D1,.EFF	
	MOVEM.L	(SP)+,A1/D1
	RTS	
*****************************************
ROUT_SPRITES
	MOVEM.L	A1-A3/D1-D6,-(SP)
	ADDQ.W	#1,D7
	CMPI.W	#360,D7
	BNE.S	TEST2
	CLR.L	D7
TEST2	
*********EFFACE LES TRACES******
	BSR	EFFA	
*********AFFICHE LES SPRITES*****
	CLR.L	D6
	CLR.L	D1
	MOVEQ.W	#62,D5
MULTI	BSR	SPRITE
	ADD.L	#380,D6
	ADD.L	#380*2,D1
	DBF	D5,MULTI
	MOVEM.L	(SP)+,A1-A3/D1-D6
	RTS	

*****************************SOUS ROUTINES**************************************************
************LA routine de sprites***************
SPRITE	
	MOVEQ.W	#0,D3
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
	LEA	XEND,A2			; pointe sur x 
	LEA	YEND,A3			; pointe sur y
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
******************************POUR LE CALCUL DU DECALAGE**************
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
CLS
	MOVE.L	AFFECR,A0
	move.l workecr,a1
	MOVEQ.L	#0,D1
	MOVE.W	#7999,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L 	D1,(A1)+
	DBF	D0,OK
	RTS

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
*******************c'est FI-NI********************************************************************

FIN	
	CLR.L	$4D2
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	#0,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

**************************

		SECTION	DATA
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
X		DC.L	0
Y		DC.L	0
colors		dc.w 	$023,$034,$056,$067
XEND	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_END.INL"
XEND2	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\X_END2.INL"
YEND	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_END.INL"
YEND2	INCBIN	"C:\UTILS\CODE_UTI.LS\GFABASIC\Y_END2.INL"
Y_TABLE	incbin  "C:\UTILS\CODE_UTI.LS\GEN_ASM\FALCBOBS.S\YTABLE.INL"		
		SECTION BSS
	DS.L 2000
PILE	DS.L 10
	END
																													 	 															?																					 	 			