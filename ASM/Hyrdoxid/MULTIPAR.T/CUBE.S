*******************************************************
*           LITTLE MULTIPART FOR SUNGODESS            *
*              by Cristalion/Hydroxid  		      *
*******************************************************

	opt	o+,d+,w+


	lea.l pile,sp
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	BSR	VBL
*	MOVE.W	#0,$FFFF8260.W
*      	LEA     song1,A0
*	LEA     voice,A1
*	JSR     player          ; Init the player
*	MOVE.L  #player+8,$4D2.w ; VBL
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
	BSR	AFFI_GFX
	BSR	CLS_256
	BSR	PRINTER_1
	BSR	PART_1
	BRA	FIN	
***************************************************************************************************
********************************PREMIERE PART******************************************************
***************************************************************************************************
	
PRINTER_1
LOOP2	CMPI.B	#58,$FFFFC02
	BEQ.S	END_PRINTER1	
	BRA	LOOP2
END_PRINTER1
	RTS


PART_1
	BSR	VBL
	pea (a0)
	pea (a1)
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	lea.l colors,a0
	lea.l $ffff8240.w,a1
	move.w  (a0)+,(a1)
	move.w (a0),2(a1)
	move.w (a0),4(a1)
	move.w (a0),8(a1)
	move.w (a0)+,6(a1)
	move.w (a0),10(a1)
	move.w (a0)+,12(a1)
	move.w (a0),14(a1)
	move.l (sp)+,a1
	move.l (sp)+,a0

	BSR 	ROUT_SPRITES
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	EXG	A1,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR

	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w

	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #6,d0			; si on a fait les 3 plans			
	cmpi.w	#6,d0
	bne.s trainee			; on boucle
 	subq.w #6,affecr+2
trainee

	cmpi.b	#56,$fffffc02
	bne.s	ALT
	MOVE.W	#5,$FFFF8240.W
alt
	CMPI.B	#57,$FFFFC02
	BEQ	END_PART1
	BRA	PART_1
END_PART1
	RTS
******************les sprites a la c...************************
	
ROUT_SPRITES
	MOVEM.L	A1-A3/D2-D6,-(SP)
	ADDQ.W	#1,D7
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

	MOVE.W	#63,D5
MULTI	BSR	SPRITE
	ADD.L	#380,D6
	DBF	D5,MULTI

	ADDQ.W	#1,D1	

	MOVEM.L	(SP)+,A1-A3/D2-D6
	RTS	
***************************************************************************************************
***************************INITIALISATIONS*********************************************************
***************************************************************************************************
INITS
	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		*
	MOVE.W	#88,-(SP)		*
	TRAP	#14			*
	ADDQ.L	#4,SP			*
	MOVE.W	D0,OLDMODECODE		*

	MOVE.W	#0,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.L	#-1,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

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

	PEA	(A0)
	PEA	(A1)
	PEA	GFX+2
	MOVE.W	#6,-(SP)
	TRAP	#14
	ADDQ.L	#6,SP
	lea	colors,a0
	lea 	$ffff8240.w,a1
	BSR	VBL
	move.w 	(a0)+,(a1)
	move.w 	(a0),2(a1)
	move.w 	(a0),4(a1)
	move.w 	(a0),8(a1)
	move.w 	(a0)+,6(a1)
	move.w 	(a0),10(a1)
	move.w 	(a0)+,12(a1)
	move.w 	(a0),14(a1)
	BSR	VBL
	MOVE.L	(SP)+,A1
	MOVE.L	(SP)+,A0
	BSR	VBL
	RTS

**************************************************************************************************
*******************c'est FI-NI********************************************************************
**************************************************************************************************

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
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
*	MOVE.W	#1,$FFFF8260.W
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
***********************************************************************************************
******************************SOUS ROUTINES****************************************************
***********************************************************************************************
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
AFFI_GFX
	MOVEM.L	D0/A0-A2,-(SP)
	LEA	GFX+34,A0	
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.W	#7999,D0
REP
	MOVE.L	(A0),(A1)+
	MOVE.L	(A0)+,(A2)+
	DBF	D0,REP	
	MOVEM.L	(SP)+,D0/A0-A2
	RTS
***************REALTIME_FADE_OUT ROUTINE*******
REALTIME_FADE_OUT
	MOVEM.L	D0-D3/A0,-(SP)
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
FADE
	LEA	COLORS,A0		; addresse couleurs
	MOVEQ.W	#3,D0			; dec les 3 couls
ROUGE
	MOVE.W	(A0),D1
	ANDI.W	#$F00,D1
	ROR.W	#8,D1
VERT
	MOVE.W	(A0),D2
	ANDI.W	#$0F0,D2
	ROR.W	#4,D2
BLEU
	MOVE.W	(A0),D3
	ANDI.W	#$00F,D3

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
	
V	CMPI.B	#0,D3
	BEQ.S	B
	SUBQ.W	#1,D3
	OR.W	D3,(A0)	

B	ADDQ.L	#2,A0			; passe a coul suivante
	DBF	D0,ROUGE
	MOVEM.L	(SP)+,D0-D3/A0
	JMP	ALT	                                                      
********************************************************************************
**************************LA routine de sprites*********************************
SPRITE	
	CLR.L	D3
	MOVE.L	WORKECR,A1		; adresse ecran dans a1
	SUBQ.L	#8,A1
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

******************************LA ROUTINE DE CLS 256 PIXELS**********************

CLS_256
	MOVEM.L	D0/A1-A2,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	MOVE.L	AFFECR,A2
	ADD.W	#160,A1
	MOVEQ	#0,D0
	MOVE.W	#199,D1
EFF2
OX	SET	0
	REPT	64
	MOVE.W	D0,OX(A1)
	MOVE.W	D0,OX(A2)
OX	SET	OX+2
	ENDR
	LEA	160(A1),A1
	LEA	160(A2),A2
	DBF	D1,EFF2
	MOVEM.L	(SP)+,D0/A1-A2
	RTS
******************************LA ROUTINE D'EFFACAGE PLAN1**********************

EFFA
	MOVEM.L	D0/A1,-(SP)
	MOVE.L	WORKECR,A1			; adresse ecran dans a1
	ADD.W	#10*160,A1
	MOVEQ	#0,D0
	MOVE.W	#188,D1
.EFF
OXO	SET	0
	REPT	16
	MOVE.W	D0,OXO(A1)
OXO	SET	OXO+8
	ENDR
	LEA	160(A1),a1
	DBF	D1,.EFF
	MOVEM.L	(SP)+,D0/A1
	RTS
***********************************************************************
***********************************************************************
*********************SECTION DATAS*************************************

AFFECR:		DC.L 	1
WORKECR:	DC.L 	1
OLDXBIOS2:	DC.L	1
OLDMODECODE	DC.W	1
colors 		dc.w 	$203,$034,$056,$067
X	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\Xcube.INL"
Y	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\Ycube.INL"
*song1	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\HDX2.TRI"
*voice	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\HDX2.TVS"
*PLAYER	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\REPLAYER.BIN"
GFX	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\HDX2.PI1"

TAB_MUL160
OXO	SET	0
	REPT	200
	DC.W	OXO
OXO	SET	OXO+160
	ENDR


	ds.l 2000
pile	ds.l 10

	END
colors dc.w $023,$034,$045,$067
******************
*PRINTING ROUTINE*
******************

	clr.l	d2
	clr.l	d0
	clr.l	d1
	clr.l	d3
	MOVE.L	AFFECR,A2
	ADD.L	#5120+2560,A2
	JMP	BOUCLE

********************************BOUCLE PRINCIPALE******************
BOUCLE:
	BSR	VSYNC
	CMPI.W	#112,D3
	BEQ.S	SUITE
	BSR	PRINTING
	ADDQ.W	#1,D3
SUITE	cmpi.b	#57,$ffffc02
	bne.s	BOUCLE
	JMP	SORTIE
*********************ROUTINE POUR LE PRINTING*************
PRINTING
	LEA	FONTE+34,A0
	LEA	TEXTE+2,A1
	ADD.W	D2,A1
	CMPI.B	#16,D1
	BNE.S	NO_CLEAR
	CLR.B	D1
	SUB	#16*8,A2
	ADD.W	#2560,A2	
NO_CLEAR
	ADD.W	(A1),A0
	BSR	FONT
	ADDQ.B	#1,D1
	ADDQ.W	#8,A2
	ADDQ.W	#2,D2
	RTS	
	
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
	RTS

	SECTION DATA

TEXTE:	INCBIN	C:\UTILS\GEN_ASM\FALCBOBS.S\TEXT.INL
FONTE:	INCBIN	C:\UTILS\GEN_ASM\FALCBOBS.S\FNT.INL
