**********************************************************************
************** INTRODUCTION DEMO ATROCITY - FLI BY RAZORBACK *********
************** MAIN CODE BY ZANAK - (C) 1994 ATROCITY Corp.  *********
**********************************************************************  

	SECTION TEXT
	
**********************************************************************
************** MEMOIRE - ECRANS **************************************
**********************************************************************

	MOVE.L	4(SP),A0
	
	MOVE.L	12(A0),D0	; TAILLE SECTION TEXT	
	ADD.L	20(A0),D0	; TAILLE SECTION DATA
	ADD.L	28(A0),D0	; TAILLE SECTION BSS
	ADDI.L	#256,D0	; TAILLE BASEPAGE
	ADDI.L	#256,D0	; TAILLE ERROR

	MOVE.L	D0,-(SP)	; TAILLE BLOCK ENTIER
	MOVE.L	A0,-(SP)	; ADRESSE BLOCK
	MOVE.W	#0,-(SP)
	MOVE.W	#$4A,-(SP)	; MSHRINK
	TRAP	#1	; CALL GEMDOS
	ADD.L	#12,SP
	
	TST.L	D0	; TESTE SI ERREUR ...
	BMI	BYE	; SI OUI FIN SINON
			; ON CONTINUE ...

**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)	; SUPERVISEUR
	TRAP	#1
	ADDQ.L	#6,SP

	CLR.B	$FFFF8900.W		; IT DMA OFF
	CLR.B	$FFFF8901.W		; DMA STOP

************** CLS ***************************************************

	PEA	TEXT(PC)
	MOVE.W	#$9,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

**********************************************************************
	
	MOVE.L	D0,-(SP)	; OLD REZ 
	LEA	VAR,A6	; VARIABLES

********* OVERSCAN PREPA ****************************************

;	MOVE.W	$FFFF8288.W,D0
;	MOVE.W	$FFFF828A.W,D1
;	MOVE.W	D0,HBB(a6)
;	MOVE.W	D1,HBL(a6)
	
**********************************************************************
	
	MOVE.W	#2,-(SP)	; OU EST L'ECRAN PHYSIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,PSCR(A6)	; IL EST LA ...
	
	MOVE.W	#3,-(SP)	; OU EST L'ECRAN LOGIQUE ?
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,LSCR(A6)	; IL EST LA AUSSI ...
	
	MOVE.W	#-1,-(SP)	; ET LA RESOLUTION ?
	MOVE.W	#88,-(SP)
	TRAP	#14
	ADDQ.L	#4,SP
	MOVE.W	D0,REZ(A6)	; ELLE EST LA ...

**********************************************************************

	MOVE.L	#SIZE1,D0		; TAILLE 1
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN1(A6)	; CONFIG ECRAN1
	
	MOVE.L	#SIZE2,D0		; TAILLE 2
	ADDI.L	#256,D0
	CLR.B	D0
	MOVE.L	D0,ECRAN2(A6)	; CONFIG ECRAN2
	
**********************************************************************

	MOVE.W	#%100010011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1(A6),-(SP)
	MOVE.L	ECRAN2(A6),-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP
	
**********************************************************************

	MOVE.L	#MOUSOFF,-(SP)	; COUPE LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ	#8,SP


************ SON **************************************
	
	MOVE.L	#SAMPLE+4000,D0
	MOVE.L	#SAMPLE_FIN,D1
	MOVE.B	D0,$FFFF8907.W
	LSR.W	#8,D0
	MOVE.B	D0,$FFFF8905.W
	SWAP	D0
	MOVE.B	D0,$FFFF8903.W
	MOVE.B	D1,$FFFF8913.W
	LSR.W	#8,D1
	MOVE.B	D1,$FFFF8911.W
	SWAP	D1
	MOVE.B	D1,$FFFF890F.W
	MOVE.B	#%10000010,$FFFF8921.W		; 25KHZ 8BITS MONO

	MOVE.B	#1,$FFFF8901.W		; DMA ON

************** FADE COULEUR 1 ****************************************

	MOVE.W	#$3C,D0
FADE	SUBI.L	#$4040004,$FFFF9800.W
	BSR	VBL0
	DBF	D0,FADE
	
************** COULEURS NOIR POUR TOUS *******************************

	CLR.L	$FFFF9804.W
	CLR.L	$FFFF9808.W
	CLR.L	$FFFF9834.W

**********************************************************************
			
	MOVE.W	#$24,-(A7)
	MOVE.W	#$58,-(A7)
	TRAP	#14
	ADDQ.L	#4,A7

	MOVE.B	#70,D0
WAIT	BSR	VBL0
	DBF	D0,WAIT
	
**********************************************************************

	BSR	ROUT_SAVE_COLORS
	MOVE.L	#ANIMATION,BUFFER
	 	
END_MONITOR	MOVE.L	#ECRAN,D0 
	LSR.L	#8,D0 
	MOVE.B	D0,-$7DFD.W 
	LSR.L	#8,D0 
	MOVE.B	D0,-$7DFF.W 
	MOVE.L	#ECRAN,D0 
	MOVE.B	D0,-$7DF3.W 
	MOVE.L	$70.L,SAUVE_VBL 
	MOVE.L	#BYE,8.L 
	MOVE.L	#BYE,$C.L
	MOVE.L	#BYE,$10.L 
	MOVE.L	#BYE,$14.L 
	MOVE.L	#BYE,$18.L 
	MOVE.L	#BYE,$1C.L 
	MOVE.L	#VBL,$70.W
                   
	BSR	READ_FLI_HEADER 

INIT_FILM	MOVE.W	FRAMES,D0 
	MOVE.W	D0,PAGE 
	MOVEA.L	BUFFER,A6 
	ADDA.L	#$80,A6 
READ_PAGE	MOVE.W	#0,TIME 
	BSR	READ_EXTRA_FLI_H
	MOVE.L	SPEED,D0
SUITE_VBL	CMP.W	TIME,D0 
	BGT.S	SUITE_VBL 
	CMPI.B	#$39,-$3FE.W
	BEQ	BYE
	SUBQ.W	#1,PAGE 
	TST.W	PAGE
	BNE.S	READ_PAGE 

**********************************************************************

BYE	MOVE.L    SAUVE_VBL,$70.W 

FIN	LEA	VAR,A6	; VARIABLES

	MOVE.W	#%1100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	ECRAN1(A6),-(SP)
	MOVE.L	ECRAN2(A6),-(SP)
	MOVE.W	#5,-(SP)	; VSETMODE
	TRAP	#14
	ADD.L	#14,SP

	CLR.L	$FFFF9800.W
	
	MOVE.B	#100,D0
FIN1	BSR	VBL0
	DBF	D0,FIN1
	


	MOVE.L	#MOUSON,-(SP)	; REMET LA SOURIS
	CLR.W	-(SP)
	MOVE.W	#25,-(SP)
	TRAP	#14
	ADDQ.L	#8,SP
	
	
**********************************************************************
	
	MOVE.W	REZ(A6),-(SP)
	MOVE.W	#3,-(SP)
	MOVE.L	PSCR(A6),-(SP)	; REMET ECRAN PHYSIQUE
	MOVE.L	LSCR(A6),-(SP)	; REMET ECRAN LOGIQUE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.L	#14,SP
		
;	MOVE.W	HBB(a6),D0
;	MOVE.W	HBL(a6),D1
;	MOVE.W	D0,$FFFF8288.W
;	MOVE.W	D1,$FFFF828A.W
	
	CLR.B	$FFFF8901.W			; DMA STOP
	
**********************************************************************

	CLR.L	-(SP)
	MOVE.W	#32,-(SP)	; USER	
	TRAP	#1
	ADDQ.L	#6,SP

	CLR	-(SP)	; RETOUR AU BUREAU
	TRAP	#1
	
**********************************************************************

VBL0	MOVE.L	$466.W,D6
VBL1	CMP.L	$466.W,D6
	BEQ.B	VBL1
	RTS

VBL	ADDQ.W	#1,TIME 
	RTE 

ROUT_SAVE_COLORS
	MOVE.W	#$FF,D0 
	MOVEA.L	#-$6800,A0
	MOVEA.L	#SAVE_COLORS,A1 
ROUT_SAVE	MOVE.L	(A0)+,(A1)+ 
	DBF	D0,ROUT_SAVE
	RTS 

	MOVE.W	#$FF,D0 
	MOVEA.L	#-$6800,A1
	MOVEA.L	#SAVE_COLORS,A0 
ROUT_RESTORE
	MOVE.L	(A0)+,(A1)+ 
	DBF	D0,ROUT_RESTORE 
	RTS 

INIT_SIZE	MOVEA.L	#BUFFER,A0
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.W	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE 
	RTS 

READ_FLI_HEADER
	MOVEA.L	BUFFER,A0 
	MOVEQ	#0,D0 
	MOVE.B	7(A0),D0
	LSL.W	#8,D0 
	MOVE.B	6(A0),D0
	MOVE.W	D0,FRAMES 
	MOVEQ	#0,D0 
	MOVE.B	9(A0),D0
	LSL.W	#8,D0 
	MOVE.B	8(A0),D0
	MOVE.W	D0,WIDTH
	MOVEQ	#0,D0 
	MOVE.B	11(A0),D0 
	LSL.W	#8,D0 
	MOVE.B	10(A0),D0 
	MOVE.W	D0,HEIGHT 	
	MOVEQ	#0,D0 
	MOVE.B	19(A0),D0 
	LSL.L	#8,D0 
	MOVE.B	18(A0),D0 
	LSL.L	#8,D0 
	MOVE.B	17(A0),D0 
	LSL.W	#8,D0 
	MOVE.B	16(A0),D0 
	MOVE.L	D0,SPEED
	RTS 

READ_EXTRA_FLI_H
	MOVEA.L	A6,A0 
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.L	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE_FRAME 
	MOVEQ	#0,D0 
	MOVE.B	5(A0),D0
	LSL.W	#8,D0 
	MOVE.B	4(A0),D0
	MOVEQ	#0,D0 
	MOVE.B	7(A0),D0
	LSL.W	#8,D0 
	MOVE.B	6(A0),D0
	MOVE.W	D0,NBRE_SS_CHUNK
	MOVEA.L	A6,A5 
	ADDA.L	#$10,A5 
NEXT_CHUNK	TST.W	NBRE_SS_CHUNK 
	BEQ.S	END_CHUNK 
	BSR	READ_CHUNK
	SUBQ.W	#1,NBRE_SS_CHUNK
	BRA.S	NEXT_CHUNK
END_CHUNK	ADDA.L	SIZE_FRAME,A6 
	RTS 

READ_CHUNK	MOVEA.L	A5,A0 
	MOVEQ	#0,D0 
	MOVE.B	3(A0),D0
	LSL.L	#8,D0 
	MOVE.B	2(A0),D0
	LSL.L	#8,D0 
	MOVE.B	1(A0),D0
	LSL.L	#8,D0 
	MOVE.B	(A0),D0 
	MOVE.L	D0,SIZE_DATA_CHUNK
	MOVEQ	#0,D0 
	MOVE.B	5(A0),D0
	LSL.W	#8,D0 
	MOVE.B	4(A0),D0
	MOVE.W	D0,TYPE_CHUNK 
	CMPI.W	#$B,TYPE_CHUNK
	BEQ	READ_PALETTE
	CMPI.W	#$C,TYPE_CHUNK
	BEQ	READ_LC 
	CMPI.W	#$F,TYPE_CHUNK
	BEQ	READ_BRUN 
	CMPI.W	#$10,TYPE_CHUNK 
	BEQ	READ_COPY 
	RTS 

READ_COPY	DC.B	'A',$ED,$00,$06,'&|'
	DC.L	BUFFER_COLOR
	DC.B	'#',$FC,$00,$00,$00,$00 
	DC.L	LINE_MIN
	DC.B	'3',$FC,$00,$C8 
	DC.L	LINE_NBRE 
            DC.B	'"|'
	DC.L	ECRAN 
	DC.B	'><',$00,$C7,'<<',$01,'?' 
	DC.B	'p',$00,$10,$18,'2',$F3,$02,$00 
	DC.B	'Q',$CE,$FF,$F6,'Q',$CF,$FF,$EE 
	ADDA.L	SIZE_DATA_CHUNK,A5
	RTS 

READ_BRUN	DC.B	'A',$ED,$00,$06,'&|'
	DC.L	BUFFER_COLOR
	DC.B	'#',$FC,$00,$00,$00,$00 
	DC.L	LINE_MIN
	DC.B	'3',$FC,$00,$C8 
	DC.L	LINE_NBRE 
	DC.B	'"|'
	DC.L	ECRAN 
	DC.B	'><',$00,$C7,'|',$00,$1C,$18
	DC.B	'SFz',$00,$1A,$18,'J',$05 
	DC.B	'm',$1E,'SEx',$00,$18,$18 
	DC.B	'2',$F3,'B',$00,'Q',$CD,$FF,$FA 
	DC.B	'Q',$CE,$FF,$E8,'Q',$CF,$FF,$DE 
	ADDA.L	SIZE_DATA_CHUNK,A5
	RTS 

	DC.B	'H',$85,'DESEx',$00 
	DC.B	$18,$18,'2',$F3,'B',$00,'Q',$CD 
	DC.B	$FF,$F8,'`',$DC 
READ_LC	DC.B	'A',$ED,$00,$06,'&|'
	DC.L	BUFFER_COLOR
	DC.B	'r',$00,'t',$00,'v',$00,$16,'(' 
	DC.B	$00,$01,$E1,$8B,$16,$10,$C6,$FC 
	DC.B	$02,$80,'#',$C3 
	DC.L	LINE_MIN
	DC.B	'~',$00,$1E,'(',$00,$03,$E1,$8F 
	DC.B	$1E,'(',$00,$02,'SG3',$C7 
	DC.L	LINE_NBRE 
	DC.B	'X',$88,'"|'
	DC.L	ECRAN 
	DC.B	$D3,$C3 
LC_LINES	DC.B	'|',$00,$1C,$18,'J',$06,'g"'
	DC.B	'SF'
LC_PACK	DC.B	'z',$00,$1A,$18,$D2,$C5,$D2,$C5 
	DC.B	$1A,$18,'J',$05,'m,SE'
	DC.B	'x',$00,$18,$18,'2',$F3,'B',$00 
	DC.B	'Q',$CD,$FF,$F6 
RETOUR_LC	DBF	D6,LC_PACK
	ADDI.L	#$280,D3
	MOVEA.L	#ECRAN,A1 
	ADDA.L	D3,A1 
	DBF	D7,LC_LINES 
	ADDA.L	SIZE_DATA_CHUNK,A5
	RTS 

	EXT.W	D5
	NEG.W	D5
	SUBQ.W	#1,D5 
	MOVEQ	#0,D4 
	MOVE.B	(A0)+,D4
LC_POINTS2	DC.B	'2',$F3 
	CLR.B	D0
	DBF	D5,LC_POINTS2 
	BRA.S	RETOUR_LC 
READ_PALETTE
	MOVEA.L	#BUFFER_COLOR,A1
	LEA	10(A0),A2 
	MOVE.W	#$FF,D0 
INSTALLE_COLORS
	MOVEQ	#0,D1 
	MOVEQ	#0,D2 
	MOVE.B	(A2)+,D2
	LSR.W	#1,D2 
	LSL.W	#8,D2 
	LSL.W	#3,D2 
	MOVE.W	D2,D1 
	MOVEQ	#0,D2 
	MOVE.B	(A2)+,D2
	LSR.W	#1,D2 
	LSL.W	#6,D2 
	OR.W	D2,D1 
	MOVEQ	#0,D2 
	MOVE.B	(A2)+,D2
	LSR.W	#1,D2 
	OR.W	D2,D1 
	MOVE.W	D1,(A1)+
	DBF	D0,INSTALLE_COLORS
	ADDA.L	SIZE_DATA_CHUNK,A5
	RTS 
	
**********************************************************************
	SECTION DATA
**********************************************************************

TEXT	DC.B	$1B,"E"
	DC.B	0
	
SAMPLE	INCBIN	A:\ATROCITY.AVR
SAMPLE_FIN

MOUSOFF	DC.B	18,0
MOUSON	DC.B	8,0

ANIMATION	INCBIN	A:\ATROCITY.FLI
	EVEN
	
			
**********************************************************************
	SECTION BSS
**********************************************************************

SIZE1	DS.W	320*200+128
SIZE2	DS.W	320*200+128
VAR	DS.W	48
PSCR	RS.W	2
LSCR	RS.W	2
REZ	RS.W	1
ECRAN1	RS.W	2
ECRAN2	RS.W	2
HBB	RS.W	1
HBL	RS.W	1
SAUVE_RES	DS.W      1 
BUFFER_COLOR	DS.B      1024
ADR_FILENAME	DS.L      1 
BUFFER	DS.B      8
FRAMES	DS.W      1 
HEIGHT	DS.W      1 
LINE_MIN	DS.L      1 
LINE_NBRE	DS.B      102 
NBRE_SS_CHUNK	DS.W      1 
OLD_SP	DS.L      1 
PAGE	DS.W      1 
SAUVE_VBL	DS.L      1 
SAVE_FICHIER	DS.W      1 
SIZE	DS.L      1 
SIZE_FRAME	DS.B      8 
SIZE_DATA_CHUNK	DS.L      1 
SPEED	DS.L      1 
TIME	DS.W      1 
TYPE_CHUNK	DS.W      1 
WIDTH	DS.W      1 
SAVE_SCREEN	DS.L      1 
SAVE_COLORS	DS.B      1024
ECRAN	DS.B      121632
L0067	DS.B      32968 
USTACK	DS.L      1 
ZUEND
	END