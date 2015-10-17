***********************************
*         little 3D cube          * 
*     by Cristalion/Hydroxid      *
***********************************

	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
*	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	BSR	VBL
	BSR	INITS
*	LEA     song1,A0
*	LEA     voice,A1
*	BSR    	player          ; Init the player
*	MOVE.L  #player+8,$4D2.w ; VBL
	BSR	CLS
*	BSR	FULL
**************************BOUCLE PRINCIPALE*************************************************
LOOP
	move.w	#$203,$ffff8240.w
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT3
 	move.w 	#777,$ffff8240.w
NO_ALT3
	bsr	EFFA
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT2
 	move.w 	#$577,$ffff8240.w
NO_ALT2
	bsr	READ_CURVE
	bsr	TRACE_LIGNES
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
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b affecr+1,$ffff8201.w
	move.b affecr+2,$ffff8203.w
*	move.w	#7,-(sp)
*	trap	#1
*	addq.l	#2,sp
	addq.l #2,affecr
	move.w affecr+2,d0
	andi.w #8,d0			; si on a fait les 4 plans			
	cmpi.w	#8,d0
	bne.s trainee			; on boucle
 	subq.w #8,affecr+2
trainee
	cmpi.b 	#56,$fffffc02
 	bne.s 	NO_ALT
 	move.w 	#$5,$ffff8240.w
NO_ALT
	bsr	VBL
	cmpi.b	#57,$ffffc02
	bne	LOOP
	bra	fin
***************************INITIALISATIONS*********************************************************
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
	subi.l #$9B00,d0
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
******************************************************************************************
******************************SOUS ROUTINES***********************************************
******************************************************************************************
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
	rts

READ_CURVE
	movem.l	d0-d1/a0-a3,-(sp)
	lea	X_CURVE,a0
	lea	Y_CURVE,a1
	addq.w	#1,compt
	cmpi.w	#360,compt
	bne.s	SUITE
	clr.w	compt
SUITE
	lea	DX,A2
	lea	DY,A3
	moveq.w	#15,d0
 	move.w	compt,d1
	add	d1,d1
SAVE_CURVE
	move.w	(a0,d1.w),(a2)
	move.w	(a1,d1.w),(a3)
	add.w	#370*2,a0
	add.w	#370*2,a1
	addq.w	#2,a2
	addq.w	#2,a3
	dbf	d0,SAVE_CURVE
	movem.l	(SP)+,d0-d1/a0-a3
	rts
CLS
	movem.l	D0/A0-a1,-(SP)
	move.l	AFFECR,A0
	move.l 	WORKECR,a1
	move.w	#7999,D0
OK
	clr.l	(a0)+
	clr.l 	(a1)+
	dbf	d0,OK
	movem.l	(SP)+,D0/A0-a1
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
;sur F30
EFFA
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

*******************c'est FI-NI********************************************************************

FIN	
	CLR.L	$4D2
*	BSR     player+4        ; Quit the replay
*	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	BSR	VBL
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#0,$FFFF8246.W
	
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	INCLUDE	"C:\UTILS\GEN_ASM\LINEROUT\LINEROUT.S"
*********************SECTION DATAS*************************************
FORME	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\V.INL"	
Y_TABLE	INCBIN	"C:\UTILS\GEN_ASM\FALCBOBS.S\YTABLE.INL"	
X_CURVE INCBIN	"C:\UTILS\GFABASIC\X.INL"
Y_CURVE INCBIN	"C:\UTILS\GFABASIC\Y.INL"
*player:	INCBIN 	"A:REPLAY.S\REPLAYER.BIN"
*song1:	INCBIN 	"A:\SONGS\ELECTRA.TRI"
*voice:	INCBIN 	"A:\VOICESET\ELECTRA.TVS"
CX1		DC.W	0
CY1		DC.W	0
CX2		DC.W	0
CY2		DC.W	0
DX		DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DY		DC.W	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
SAV_CY1		DC.W	0
IND		DC.B	0
AFFECR:		DC.L 	0
WORKECR:	DC.L 	0
OLDXBIOS2:	DC.L	0
OLDMODECODE	DC.W	0
COMPT		DC.W	0
CLR		DC.L	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
colors 		dc.w 	$023,$034,$045,$067
	DS.L 2000
PILE	DS.L 10
	END

												