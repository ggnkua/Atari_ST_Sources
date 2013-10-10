*******************************************************
*           3D_SPRITES by Cristalion/Hydroxid         *
*     (thanxx to TCHOOM/AKM and OXBAB for the help)   *
*                   the 2/09/93                       *
*******************************************************

	opt	o+,d+,w+


	lea.l pile,sp
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	VBL
	MOVE.W	#0,$FFFF8260.W
*      	LEA     song1,A0
*       LEA     voice,A1
*       JSR     player          ; Init the player
*       MOVE.L  #player+8,$4D2.w ; VBL
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR.	VBL
	BSR	INITS
	BSR	CLS
	CLR.L	D1			 ; on ne sait jamais
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	CLR.L	D7
	MOVEQ.L	#3,D7
		
LOOP
	BSR	VBL
	MOVE.W	#0,$FFFF8240.W

	 pea (a0)
	 pea (a1)
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
	 move.l (sp)+,a1
	 move.l (sp)+,a0

	BSR 	ROUT_SPRITES
	CMPI.B	#57,$FFFFC02
	BEQ	FIN

	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	EXG	A1,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	addq.l #2,affecr
	move.w affecr+2,d0
	and.w #8,d0			; si on a fait les 4 plans			
	beq.s trainee			; on boucle
 	subq.w #8,affecr+2
trainee

	cmpi.b	#56,$fffffc02
	bne.s	alt
	MOVE.W	#5,$FFFF8240.W
	
alt
	BRA	LOOP
******************************SOUS ROUTINES********************
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
******************les sprites a la c...************************
	
ROUT_SPRITES
	MOVEM.L	A1-A3/D2-D6,-(SP)
	ADDQ.W	#2,D7
	CMPI.W	#360,D7
	BLO.S	TEST2
	SUBI.W #360,D7
TEST2	CMPI.W	#360,D1			; si courbe fini on boucle
	BNE.S	SUITE
	CLR.L	D1

*********EFFACE LES TRACES******
SUITE
	BSR	EFFA
	
*********AFFICHE LES SPRITES*****

	MOVE.W	#43,D5
MULTI	BSR.S	SPRITE
	ADD.L	#500,D6
	DBF	D5,MULTI

	ADDQ.W	#1,D1	

	MOVEM.L	(SP)+,A1-A3/D2-D6
	RTS	
********************************************************************************
**************************LA routine de sprites*********************************
********************************************************************************
********plan1******************
SPRITE	
	CLR.L	D3
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
	LEA	X,A2			; pointe sur x 
	LEA	Y,A3			; pointe sur y
	ADD.W	D6,A2
	ADD.W	D6,A3
	MOVE.B	(A2,D7),D2		; x en d2
	MOVE.B	D2,D4			; sauve d2 pour decalage
	MOVE.B	(A3,D7),D3		; y en d3
; conversion de coordonnees en adresse ecran
; les x
	LSR.W	D2			; version optimisee
	AND.W	#$FFF8,D2
	ADD.W	D2,A1	
; les y
	LEA	TAB_MUL160,A2
	ADD.W	D3,D3
	ADD.W	(A2,D3.W),A1
; le decalage
	AND.W	#$F,D4			; decalage sur 16 pixels	
; tests pour le predecalage (bbboouuhhh !!!! je sais pas le faire en temps reel !!! honte sur moa ....)
	BSR	DECA
	RTS		
*******************************************************************************	
******************************LA ROUTINE D'EFFACAGE PLAN1**********************

EFFA
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#160*24,A1
	MOVEQ	#0,D0
	MOVE.W	#160,D1
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

***************************INITS**************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
 	move.l $44e.w,d0
	MOVE.L	d0,A1
	subi.l #$7d00,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	MOVE.W	#0,-(SP)
	MOVE.L	AFFECR,-(SP)
	MOVE.L	affecr,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP
	RTS

******************************POUR LE CALCUL DU DECALAGE**************


DECA	EXT.W	D4
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
	ORI.W	#56,(A1)
	ORI.W	#124,160(A1)
	ORI.W	#124,320(A1)
	ORI.W	#124,480(A1)
	ORI.W	#56,640(A1)
	RTS
DECA5
	ORI.W	#28,(A1)
	ORI.W	#62,160(A1)
	ORI.W	#62,320(A1)
	ORI.W	#62,480(A1)
	ORI.W	#28,640(A1)
	RTS
DECA6
	ORI.W	#14,(A1)
	ORI.W	#31,160(A1)
	ORI.W	#31,320(A1)
	ORI.W	#31,480(A1)
	ORI.W	#14,640(A1)
	RTS
DECA7
	ORI.W	#7,(A1)
	ORI.W	#15,160(A1)
	ORI.W	#32768,168(A1)
	ORI.W	#15,320(A1)
	ORI.W	#32768,328(A1)
	ORI.W	#15,480(A1)
	ORI.W	#32768,488(A1)
	ORI.W	#7,640(A1)
	RTS
DECA8
	ORI.W	#3,(A1)
	ORI.W	#32768,8(A1)
	ORI.W	#7,160(A1)
	ORI.W	#49152,168(A1)
	ORI.W	#7,320(A1)
	ORI.W	#49152,328(A1)
	ORI.W	#7,480(A1)
	ORI.W	#49152,488(A1)
	ORI.W	#3,640(A1)
	ORI.W	#32768,648(A1)
	RTS
DECA9
	ORI.W	#1,(A1)
	ORI.W	#49152,8(A1)
	ORI.W	#7,160(A1)
	ORI.W	#49152,168(A1)
	ORI.W	#7,320(A1)
	ORI.W	#49152,328(A1)
	ORI.W	#7,480(A1)
	ORI.W	#49152,488(A1)
	ORI.W	#3,640(A1)
	ORI.W	#32768,648(A1)
	RTS
DECA10
	ORI.W	#57344,8(A1)
	ORI.W	#1,160(A1)
	ORI.W	#61440,168(A1)
	ORI.W	#1,320(A1)
	ORI.W	#61440,328(A1)
	ORI.W	#1,480(A1)
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

*******************c'est FI-NI*********************************
	

VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS

FIN	
*	CLR.L	$4D2
*	JSR	PLAYER+4
	MOVE.W	#0,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP		
	MOVE.W	#1,$FFFF8260.W
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	BSR.S	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1
	


                                                      
***********************************************


AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	0
X	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\X3.INL"
Y	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\Y3.INL"
song1	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\HDX.TRI"
voice	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\HDX.TVS"
PLAYER	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\REPLAYER.BIN"

TAB_MUL160
OXO	SET	0
	REPT	200
	DC.W	OXO
OXO	SET	OXO+160
	ENDR

colors dc.w $023,$034,$045,$067

	ds.l 2000
pile	ds.l 10

	END
