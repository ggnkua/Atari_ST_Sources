 	*	Mega tracker
	*      By Axel Follet
	*   Started on the november,15th 1990
	*	 Ste Only

	*	8 digitals channels stereo
	*	3 Yamaha   channels mono

	*  You can choose the number of the digitals channels,
	*  knowing that the less you have,the more time you leave free

	*  Cool, no ?
	OPT	D+
	OPT	O-
DAC_FRQ		EQU	2		* 2 = 25033
FRQ_25		EQU	1		* 1 = 25   KHZ ACTIVE
FRQ_12		EQU	0		* 1 = 12.5 KHZ ACTIVE
FINSAMPLE	EQU	512

* rt11

	JMP	BEGIN
BEGIN2	MOVE.W	#$2700,SR
	MOVE.L	$118.w,s118
	move.l	$70.w,s70
	MOVE.b	$FFFFFA17.W,S117
	BCLR	#3,$FFFFFA17.W
	move.l	#setscreen,$70.w
	MOVE.L	#MOUSEIT,$118.W
	MOVE.W	#$2300,SR
				*Ici va se derouler tous ce qui n'est
				*pas en VBL (fileselect,input)
niet
	cmp.w	#1,fin
	beq.s	da
	tst	okp
	beq.s	niet
	moveq	#0,d0
	move.w	okp,d0
	lea	SAUT,a0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0),a0
	jsr	(a0)
	bra.s	niet

SAUT	DC.L	0,FILESEL,INPT2,0,CLRSAM1,CLRPAT1,SPLTSPE,SCROL,TRI,LOADE
	DC.L	SAUVE,AFFPATTERN2,EFFPAT2,PATTUP3,PATTUP4,PATTDOWN2
	DC.L	DIVIDE_2,DIVIDE_3,DIVIDE_4,L_SPL_MOD	* LAST = 19
****************************** FIN **********************************
s70	dc.l	0

da	move.l	s70,$70.w
	move.l	#0,$4d2.w
	move.w  #0,$FFFF8900.w          
	move.b	#8,$fffffc02.w
	MOVE.B	S117,$FFFFFA17.W
	move.l	s118,$118.W
	move.l #$8080000,$ffff8820.w		
	move.l #$9090000,$ffff8820.w		
	move.l #$a0a0000,$ffff8820.w
	move.w	#$666,$ffff8246.w
	bsr	CLRKEYB
	move.w	rezo,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap #14
	add.l	#12,a7
	move.l	pile,-(a7)
	move.w	#$20,-(a7)
	trap #1
	addq.l	#6,a7
	bsr	CLRKEYB
	clr.l -(a7)
	trap #1
s118	dc.l	0
MOUSEABS	DC.B	9,01,$40-16,2,$44+30,0,0,0,0
	even
S117		DC.B	0
	even
*********************************************************************
setscreen
	MOVE.B	#$D,$FFFFFC02.W
	move.l	D0,-(a7)
	moveq	#0,d0
	move.w	SCREENY,d0
	mulu	#160,d0
	add.l	#screen,d0
	MOVE.L	D0,-(A7)
	move.b	2(A7),$ffff8203.w
	move.b	1(A7),$ffff8201.w
	move.b	3(A7),$ffff820D.w
	ADDQ.W	#4,A7
	clr.w	waiting
	move.l	(a7)+,d0
	bsr.S	vbl
	rte	
*******************************************************************
vbl	movem.l	a0-a6/d0-d7,-(a7)
	move.l	where,-(a7)
	move.w	compt2,-(a7)
	MOVE.W	COLOR,$FFFF8240.W
	MOVE.B	#0,VOID
	MOVE.B	#0,VOIY
	JSR	DAC_SYNC
.pok3	CMP.L	#0,MADMAX
	BEQ.S	.POK2
	MOVE.L	MADMAX,A0
	JSR	(A0)
	BSR.S	REDUIT
.POK2	cmp.w	#0,okp
	bne.s	.pok1
	JSR	RESTITU
	bsr	KEYB
	bsr	FONCT
	bsr	POSMOUSE
.pok1	JSR	TESTBORDS
	cmp.b	#1,playpat
	bne.s	.bl1
	jsr	VBLPAT
.bl1	cmp.b	#1,record
	bne.s	.bl2
	JSR	VBLRECORD
.bl2	cmp.b	#1,playsong
	bne.s	.bl3
	jsr	VBLPAT
.bl3	JSR	AFFMOUSE
	;move.w	#$70,$ffff8240.w
	JSR	JOUEDIGIT
*OUTE	
	move.w	#$0,$ffff8240.w
	move.w	(a7)+,compt2
	move.l	(a7)+,where
	movem.l	(a7)+,a0-a6/d0-d7
	rts
******************************************************************
REDUIT
	moveq	#0,d0
	move.b	#8,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr.S	.reduc
	move.b	d0,$ffff8802.w

	move.b	#9,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr.S	.reduc
	move.b	d0,$ffff8802.w

	move.b	#$a,$ffff8800.w
	move.b	$ffff8800.w,d0
	bsr.S	.reduc
	move.b	d0,$ffff8802.w
	rts

.reduc	cmp.b	#16,d0
	beq.s	.redus
	subq.b	#4,d0
	cmp.b	#0,d0
	bgt.s	.redus
	moveq	#0,d0
.redus	rts
******************************************************************
POSMOUSE
	cmp.b	#4,km			*Bouton gauche
	beq.s	.za1
	cmp.b	#2,km			*Bouton droit
	beq.s	.za2
	bra.s	.finito
.za1	lea	pos,a0
	bra.s	.za3
.za2	lea	pos2,a0
.za3	move.b	#0,km
	lea	jump,a1
.suite	move.l	(a0)+,d0		*X min
	move.l	(a0)+,d1		*Y min
	move.l	(a0)+,d2		*X max
	move.l	(a0)+,d3		*Y max
	move.l	(a0)+,a1		*JUMP
	cmp.w	#-1,d0
	beq.s	.finito
	cmp.w	x1,d0
	bgt.s	.non
	cmp.w	x1,d2
	blt.s	.non
	cmp.w	y1,d1
	bgt.s	.non
	cmp.w	y1,d3
	blt.s	.non
	jmp	(a1)
.non	bra.s	.suite
.finito	rts
pos	DC.L 1,9,35,23,LOADER,37,9,74,23,SAUVEUR,281,265,311,271,MOINSFRQSPL
	DC.L 0,247,73,283,SILENT,0,201,72,215,EXIT
	DC.L 2,73,35,79,SPL,37,65,74,71,SPE,37,41,74,47,BNK
	DC.L 2,41,35,47,AVR,37,57,74,63,SAM,37,49,74,55,MOD
	DC.L 2,49,35,55,PTN,2,57,35,63,MUS,2,65,35,71,SNG
	DC.L 37,73,74,79,YAM
	DC.L 1,313,239,319,INPUT,82,281,154,295,PLAYPATT,82,265,154,279,PLAYSONG
	DC.L 162,281,234,295,RECORD,257,209,319,215,CLRALL
	DC.L 162,265,234,279,EDIT,257,217,319,224,CLRSAM,257,233,319,239,CLRPAT
	DC.L 129,209,136,215,ADDNUM100,137,209,144,215,ADDNUM10,145,209,151,215,ADDNUM1
	DC.L 129,217,136,223,ADDPOS100,137,217,144,223,ADDPOS10,145,217,151,223,ADDPOS1
	DC.L 129,225,136,231,ADDPAT100,137,225,144,231,ADDPAT10,145,225,151,231,ADDPAT1
	DC.L 129,233,136,239,ADDLEN100,137,233,144,239,ADDLEN10,145,233,151,239,ADDLEN1
	DC.L 129,241,136,247,ADDLOP100,137,241,144,247,ADDLOP10,145,241,151,247,ADDLOP1
	DC.L 88,25,264,184,TEST_FILE,78,25,87,41,EXIT_REP,280,25,319,104,SUB1FS
	DC.L 280,104,319,184,ADD1FS,48,85,56,94,MOINSDRIVE,0,85,47,94,ACCEPT
	DC.L 88,329,112,334,CHNGV0,168,329,192,334,CHNGV1,248,329,272,334,CHNGV2
	DC.L 88,402,112,407,CHNGV3,168,402,192,407,CHNGV4,248,402,272,407,CHNGV5
	DC.L 88,474,112,479,CHNGV6,168,474,192,479,CHNGV7,248,474,272,479,CHNGV8
	DC.L 88,547,112,552,CHNGV9,168,547,192,552,CHNGV10
	DC.L 239,257,287,263,MONOSTEREO,289,257,312,263,SPESPL,0,286,59,295,ADDDAC1
	DC.L 0,103,35,128,l_spl_mod
	DC.L -1
pos2	DC.L 129,209,136,215,SUBNUM100,137,209,144,215,SUBNUM10,145,209,151,215,SUBNUM1
	DC.L 129,217,136,223,SUBPOS100,137,217,144,223,SUBPOS10,145,217,151,223,SUBPOS1
	DC.L 129,225,136,231,SUBPAT100,137,225,144,231,SUBPAT10,145,225,151,231,SUBPAT1
	DC.L 129,233,136,239,SUBLEN100,137,233,144,239,SUBLEN10,145,233,151,239,SUBLEN1
	DC.L 129,241,136,247,SUBLOP100,137,241,144,247,SUBLOP10,145,241,151,247,SUBLOP1
	DC.L 280,25,319,104,SUB18FS,280,104,319,184,ADD18FS,48,85,56,94,PLUSDRIVE
	DC.L 281,265,311,271,PLUSFRQSPL,0,286,59,295,SUBDAC1
	DC.L -1
jump	dc.l	0
***************************************************************************
EXIT	move.w	#1,fin
ITO	rts

FONCT	CMP.W	#-1,touche
	BEQ.S	ITO
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	cmp.b	#1,DRUM
	beq	FONCT2
	
	LEA	FONCTION,A0		* D'ABORD VOIR SI C'EST UNE
	MOVE.W	touche,D1		* FONCTION
.ML1	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D0
	BEQ.S	ML2
	CMP.B	D2,D1
	BNE.S	.ML1
	LEA	FO1,A0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A0,D0.W),A0
	JMP	(A0)

FO1	DC.L	ML2,SPACEBAR,CHNGCOLOR,SILENT,LEFTCURSOR,RIGHTCURSOR
	DC.L	DOWNCURSOR,UPCURSOR,UPLANCHE,DOWNPLANCHE,PLUSFRQSPL
	DC.L	SPESPL,MSKLOAD,ERASE,LOOP,INPUT,MONOSTEREO
	DC.L	ML2,ML2,DISPOSITION,ML2
	
ML2	MOVEQ	#0,D1
	MOVE.B	whatvoice,d1
	LEA	.WH1,A0
	ADD.W	D1,D1	
	ADD.W	D1,D1
	MOVE.L	(A0,D1.W),A0
	JMP	(A0)
.WH1	DC.L	.DINST,.DINST,.DINST,MCOM,MCOM,MEFF,MEFF

.DINST	LEA	AZERTY,A0
	MOVE.W	touche,D2
.ML5	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ	ML13
	CMP.B	D1,D2
	BNE.S	.ML5
		
	MOVE.B	#0,recnote
	ADD.W	planche,D0
	MOVE.W	D0,D1
	MOVE.B	D0,recinst
	ADDQ.B	#1,recinst
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.L	D0,A0
	MOVE.L	#0,current
	CMP.L	#0,26(A0)
	BEQ.S	ML13
	MOVE.L	A0,current
	MOVE.B	D1,curentnb2
	MOVE.B	D1,sampledata
	MOVE.B	D1,dernier
	MOVE.W	#0,zerotou
arb	BSR	CHECKPATT
	CMP.B	#1,edit
	BEQ.S	retour
	CMP.B	#1,record
	BEQ.S	retour
	JSR     JOUESAMPLE
retour	RTS	
ML13	MOVE.B	#-1,recinst
	RTS

planche		dc.w	0
digiplanche	dc.w	0
yamplanche	dc.w	0
recnote		dc.b	0
recinst		dc.b	0
reccom		dc.b	0
receff		dc.b	0
		even

FONCT2
	LEA	FONCTION,A0		* D'ABORD VOIR SI C'EST UNE
	MOVE.W	touche,D1		* FONCTION
.ML3	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D0
	BEQ.S	.ML4
	CMP.B	D2,D1
	BNE.S	.ML3
	LEA	.FO2,A0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A0,D0.W),A0
	JMP	(A0)
.FO2	DC.L	.ML4,SPACEBAR,CHNGCOLOR,SILENT,LEFTCURSOR,RIGHTCURSOR
	DC.L	DOWNCURSOR,UPCURSOR,UPLANCHE,DOWNPLANCHE,UPDIGIPL
	DC.L	DOWNDIGIPL,MSKLOAD,LOOP,DIVIDE2,DIVIDE3,DIVIDE4
	DC.L	.ML4,MOINSSPL,PLUSSPL,DISPOSITION,.ML4

.ML4	MOVEQ	#0,D1
	MOVE.B	whatvoice,d1
	LEA	.WH,A0
	ADD.W	D1,D1	
	ADD.W	D1,D1
	MOVE.L	(A0,D1.W),A0
	JMP	(A0)
.WH	DC.L	.MNOTE,MINST,MINST,MCOM,MCOM,MEFF,MEFF
	
.MNOTE	LEA	NOTE1,A0
	MOVEQ	#0,D0
	MOVE.W	touche,D2
.ML5	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ.S	ML6
	CMP.B	D1,D2
	BNE.S	.ML5
		
	ADD.W	digiplanche,D0
	ADDQ.W	#1,D0
	MOVE.B	D0,recnote
	
	MOVE.B	curentnb2,recinst		* rectou = recinst
	ADDQ.B	#1,recinst
	MOVE.W	#0,zerotou
ARB2	BSR	CHECKPATT
	CMP.B	#1,edit
	BEQ.S	.retor
	CMP.B	#1,record
	BEQ.S	.retor
	JSR     JOUESAMPLE
.retor	MOVE.W	#-1,touche	
	RTS
ML6	MOVE.B	#-1,recinst
	RTS
	
MINST	LEA	DATA,A0
	MOVE.W	touche,D2
.ML7	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ.S	.ML8
	CMP.B	D1,D2
	BNE.S	.ML7
	MOVE.B	D0,recinst
	MOVE.W	#0,zerotou
	BRA.S	ARB2
.ML8	MOVE.B	#-1,recinst
	RTS
	
MCOM	LEA	DATA,A0
	MOVE.W	touche,D2
.ML9	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ.S	.ML10
	CMP.B	D1,D2
	BNE.S	.ML9
	MOVE.B	D0,reccom
	MOVE.W	#0,zerotou
	BRA	ARB2
.ML10	MOVE.B	#-1,reccom
	RTS
	
MEFF	LEA	DATA,A0
	MOVE.W	touche,D2
.ML11	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ.S	.ML12
	CMP.B	D1,D2
	BNE.S	.ML11
	MOVE.B	D0,receff
	MOVE.W	#0,zerotou
	BRA	ARB2
.ML12	MOVE.B	#-1,receff
	RTS
************************************************************************
SPACEBAR2
	MOVE.B	#0,KEY
	MOVE.W	#0,touche
	MOVE.B	#0,recnote
	MOVE.B	#0,recinst
	MOVE.W	#1,zerotou
	MOVE.L	#0,current
	BRA	ARB2
************************************************************************
SPACEBAR
	MOVE.B	#0,KEY
	move.w	#0,touche
	move.b	#0,recnote
	move.b	#0,recinst
	move.w	#1,zerotou
	move.l	#0,current
	BRA	arb
************************************************************************
ADDDAC1
	ADDQ.W	#1,LEN1
	RTS
SUBDAC1
	SUBQ.W	#1,LEN1
	RTS
************************************************************************
CHNGV0
	LEA	VOICE0,A0
	MOVE.L  #screen+329*160+45,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV1
	LEA	VOICE1,A0
	MOVE.L  #screen+329*160+85,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV2
	LEA	VOICE2,A0
	MOVE.L  #screen+329*160+125,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV3
	LEA	VOICE3,A0
	MOVE.L  #screen+401*160+45,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV4
	LEA	VOICE4,A0
	MOVE.L  #screen+401*160+85,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV5
	LEA	VOICE5,A0
	MOVE.L  #screen+401*160+125,where
	MOVE.W	#1,compt2
	BRA	TREAT
CHNGV6
	LEA	VOICE6,A0
	MOVE.L  #screen+474*160+45,where
	MOVE.W	#1,compt2
	BRA.S	TREAT
CHNGV7
	LEA	VOICE7,A0
	MOVE.L  #screen+474*160+85,where
	MOVE.W	#1,compt2
	BRA.S	TREAT
CHNGV8
	LEA	VOICE8,A0
	MOVE.L  #screen+474*160+125,where
	MOVE.W	#1,compt2
	BRA.S	TREAT
CHNGV9
	LEA	VOICE9,A0
	MOVE.L  #screen+546*160+45,where
	MOVE.W	#1,compt2
	BRA.S	TREAT
CHNGV10
	LEA	VOICE10,A0
	MOVE.L  #screen+546*160+85,where
	MOVE.W	#1,compt2

TREAT
	MOVEM.L	D0-D2/A0-A3,-(A7)
	MOVE.W	24(A0),D0
	ADDQ.W	#1,D0
	CMP.W	#6,D0		* ETAIT-CE UNE VOIE DIGITALE ?
	BNE.S	.TR2
	MOVE.W	#0,D0
	SUBQ.B	#1,digvoices
	BRA.S	.TR
.TR2	CMP.W	#2,D0		* ETAIT-CE UNE VOIE YAMAHA ?
	BNE.S	.TR3
	SUBQ.B	#1,yamvoices
.TR4	CMP.B	#8,digvoices	* A-T-ON DEJA 8 VOIES DIGITALES ?
	BEQ.S	.TR6
	ADDQ.B	#1,digvoices
	BRA.S	.TR
.TR6	MOVEQ	#0,D0
	BRA.S	.TR
.TR3	CMP.W	#1,D0		* EST-CE MAINTENANT UNE VOIE YAMAHA ?
	BNE.S	.TR
	CMP.B	#3,yamvoices	* SI OUI A-T-ON DEJA 3 VOIES YAM ?
	BEQ.S	.TR5
	ADDQ.B	#1,yamvoices
	BRA.S	.TR
.TR5	ADDQ.W	#1,D0
	BRA.S	.TR4

.TR	MOVE.W	D0,24(A0)
	BSR	IMPLIQ
	BSR	TESTVOI
	BSR	SILENT
	BSR	SET_DAC
	
	MULU	#2,D0
	LEA	VTABLE(PC),A0
	ADD.W	D0,A0
	MOVE.L	where,a2
	MOVEQ	#2,D1
	MOVE.W	compt2,D2
	BSR	PRINT
	MOVE.L	A2,where
	SUBQ.L	#4,where
	MOVE.W	D2,compt2
	BSR	PRINT
	MOVE.L	A2,where
	SUBQ.L	#2,where
	MOVE.W	D2,compt2
	BSR	PRINT
	MOVE.L	A2,where
	ADDQ.L	#2,where
	MOVE.W	D2,compt2
	BSR	PRINT
	MOVEM.L	(A7)+,D0-D2/A0-A3
	RTS

VTABLE	DC.B	0,0,'Y ','D ','DV','F ','FV',-1,-1
	EVEN
	
IMPLIQ	CMP.W	#0,D0			* SI C'EST VIDE
	BNE.S	.NOT0
	MOVE.L	#V_RTS,26(A0)
	RTS
.NOT0	CMP.W	#1,D0			* SI C'EST UN YAM
	BNE.S	.NOT1
	MOVE.L	#V_RTS,26(A0)		* MOVE.L #YAM_PREPA,26(A0)
	RTS
.NOT1	CMP.W	#2,D0			* SI C'EST UN DRUM
	BNE.S	.NOT2
	CMP.B	#1,digvoices	  	* S'IL N'Y A QU'UNE SEULE VOIE
	BNE.S	.TR7		
	MOVE.L	#DRUM1,26(A0)
	RTS
.TR7	MOVE.L	#DRM_PREPA,26(A0)
	RTS
.NOT2	CMP.W	#3,D0			* SI C'EST UN DRUM AVEC VARIATION DE VOLUME
	BNE.S	.NOT3
	MOVE.L 	#DRM_PREPA,26(A0)
	RTS
.NOT3	MOVE.L	#FRQ_PREPA,26(A0)	* SI  FRQ + VOL  .L OU .W
	RTS

SET_DAC	CMP.B	#0,digvoices
	BEQ.S	.GTR
	LEA	$FFFF8901.W,A1
	MOVE.L	#MUSDEB,D1
	MOVEP.L	D1,(A1)
	MOVE.L 	#MUSFIN,D1
	MOVEP.L	D1,12(A1)
	CMP.B	#1,digvoices
	BEQ.S	.SET2
	MOVE.W	#DAC_FRQ+000,$FFFF8920.W  	* 25 KHZ	STEREO
	RTS
.SET2	MOVE.W	#DAC_FRQ+128,$FFFF8920.W	* 25 KHZ	MONO
	RTS
.GTR	MOVE.W 	#0,$FFFF8900.W
	LEA	MUSDEB,A0
	MOVE.L	#(4*508*(DAC_FRQ+1))/4-1,D2
	MOVEQ	#0,D1
.CCC	MOVE.L	D1,(A0)+
	DBF	D2,.CCC
	RTS
TESTVOI	MOVEM.L	D0/A0,-(A7)
	MOVEQ	#0,D0
	MOVE.B	curvoie,D0
	LEA	PILEVOIE,A0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,A0
	MOVE.L	(A0),A0
	MOVE.W	24(A0),D0
	CMP.B	#2,D0
	BEQ.S	.SV1
	CMP.B	#3,D0
	BEQ.S	.SV2
	MOVE.B	#1,DRUM
	MOVEM.L	(A7)+,D0/A0
	RTS
.SV1	MOVE.B	#0,DRUM
	MOVEM.L	(A7)+,D0/A0
	RTS
.SV2	MOVE.B	#3,DRUM
	MOVEM.L	(A7)+,D0/A0
	RTS
************************************************************************
CHNGCOLOR
	MOVE.B	#0,KEY
	EOR.W	#6,COLOR
	RTS
COLOR	DC.W	0
************************************************************************
DISPOSITION
	MOVE.B	#0,KEY
	BCHG	#0,DISPO
	RTS
DISPO	DC.W	0
************************************************************************
PLUSSPL
	MOVE.B	#0,KEY
	addq.b	#1,sampledata
	cmp.b	#255,sampledata
	bne.s	vtt
	move.b  #254,sampledata
vtt	moveq	#0,d0
	move.b	sampledata,d0
	move.b	d0,dernier
	move.b	d0,curentnb2
	lea	SAMPLE,a0
	mulu	#40,d0
	add.l	d0,a0
	cmp.l	#0,26(a0)
	beq.s	nosum
	JSR	SUM
	rts
nosum	JSR	AFFNBSPL
	lea	oops,a0
	moveQ	#20,d1
	move.l	#screen+32000+113*160+39,where
	move.w	#1,compt2
	bsr	PRINT
	moveq	#4,d1
	move.l #screen+32000+65*160+136+6,where
	move.w	#0,compt2
	bsr	PRINT
	move.l	#screen+32000+17*160+95,where
	move.w	#1,compt2
	moveq	#7,d1
	bsr	PRINT
	move.l	#screen+32000+33*160+95,where
	move.w	#1,compt2
	moveq	#7,d1
	bsr	PRINT
	rts
oops	dc.b	'                    '
************************************************************************
MOINSSPL
	MOVE.B	#0,KEY
	subQ.b	#1,sampledata
	cmp.b	#255,sampledata
	bne	vtt
	move.b	#0,sampledata
	bra	vtt
************************************************************************
UPDIGIPL
	MOVE.B	#0,KEY
	add.w	#24,digiplanche
	cmp.w	#48,digiplanche
	bne.S	outt
	move.w	#24,digiplanche
	rts
************************************************************************
DOWNDIGIPL
	MOVE.B	#0,KEY
	sub.w	#24,digiplanche
	cmp.w	#-24,digiplanche
	bne.s	outt
	move.w	#0,digiplanche
	rts
************************************************************************
UPLANCHE
	MOVE.B	#0,KEY
	addq.w	#1,planche
	cmp.w	#255-64,planche
	blt.s	outt
	move.w	#255-64,planche
outt	rts
************************************************************************
DOWNPLANCHE
	MOVE.B	#0,KEY
	subQ.w	#1,planche
	cmp.w	#0,planche
	bge.s	outt
	move.w	#0,planche
	rts
************************************************************************
PLUSDRIVE
	ADDQ.B	#1,DRV
	CMP.B	#'P',DRV
	BLE.S	AFF_DRV
	MOVE.B	#'P',DRV
	BRA.S	AFF_DRV
************************************************************************
MOINSDRIVE
	SUBQ.B	#1,DRV
	CMP.B	#'A',DRV
	BGE.S	AFF_DRV
	MOVE.B	#'A',DRV
AFF_DRV
	LEA	DRV,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+86*160+23,where
	move.w	#1,compt2
	BSR	PRINT
	RTS
DRV	DC.B	'A'
	EVEN
************************************************************************
ACCEPT
	MOVE.B	DRV,PATH
	MOVE.B	DRV,AFFICHAGE
	MOVE.W	#0,EH_NON
	MOVE.W	#0,IN_MOD
	MOVE.W	#0,P_MOD
	MOVE.W	#1,okp
	RTS
************************************************************************
RECORD	
	cmp.b	#63,inpatt
	beq	retour
	move.b	#0,KEY
	move.w	#-1,touche
	move.b	#-1,lastkey
	bsr	INVERT_RECORD
	move.b	dernier,curentnb2
	move.b	dernier,sampledata
	bchg.b	#0,record
	move.b	#0,recinst
	move.b	#0,recnote
	move.w	#1,sync
	move.w	#0,u
	cmp.b	#1,edit
	bne.s	.rt1
	bsr	INVERT_EDIT
	move.b	#0,edit
.rt1	cmp.b	#1,playpat
	bne.s	.rt8
	move.b	#0,playpat
	bsr	INVERT_PLAYPATT
.rt8	cmp.b	#1,playsong
	bne.s	.rt12
	move.b	#0,playsong
	bsr	INVERT_PLAYSONG
.rt12	rts
record	dc.b	0
	even
************************************************************************
EDIT
	bchg.b	#0,edit
	bsr.S	INVERT_EDIT
	move.b	dernier,curentnb2
	move.b	dernier,sampledata
	cmp.b	#1,record
	bne.s	.rt3
	bsr.S	INVERT_RECORD
	move.b	#0,record
.rt3	cmp.b	#1,playpat
	bne.s	.rt11
	move.b	#0,playpat
	bsr.S	INVERT_PLAYPATT
.rt11	cmp.b	#1,playsong
	bne.s	.rt13
	move.b	#0,playsong
	bsr.S	INVERT_PLAYSONG
.rt13	rts
************************************************************************
INVERT_EDIT
	lea	screen+32000+65*160+80+2,a0
	moveQ	#14,d0
	bsr.S	INVERT
	rts
************************************************************************
INVERT_RECORD
	lea	screen+32000+81*160+80+2,a0
	moveQ	#14,d0
	bsr.S	INVERT
	rts
************************************************************************
INVERT_CLRPAT
	lea	screen+32000+33*160+128+2,a0
	moveQ	#6,d0
	bsr.S	INVERT2
	rts
************************************************************************
INVERT_CLRALL
	lea	screen+32000+9*160+128+2,a0
	moveQ	#6,d0
	bsr.S	INVERT2
	rts
************************************************************************
INVERT_CLRSAM
	lea	screen+32000+17*160+128+2,a0
	moveQ	#6,d0
	bsr.S	INVERT2
	rts
************************************************************************
INVERT_PLAYPATT
	lea	screen+32000+81*160+40+2,a0
	moveQ	#14,d0
	bsr.S	INVERT
	rts
************************************************************************
INVERT_PLAYSONG
	lea	screen+32000+65*160+40+2,a0
	moveQ	#14,d0
	bsr.S	INVERT
	rts
************************************************************************
INVERT
.i1	not.w	(a0)
	not.w	8(a0)
	not.w	16(a0)
	not.w	24(a0)
	not.w	32(a0)
	add.w	#160,a0
	dbf	d0,.i1
	rts
************************************************************************
INVERT2
.i2	not.w	(a0)
	not.w	8(a0)
	not.w	16(a0)
	not.w	24(a0)
	add.w	#160,a0
	dbf	d0,.i2
	rts
************************************************************************
PLUSFRQSPL
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	cmp.l	#0,26(a0)
	beq.s	rt7
	cmp.b	#127,21(a0)
	bls.s	.plusgrand
	addq.b	#1,21(a0)
	cmp.b	#131,21(a0)
	bls.s	plupetit
	move.b	#128,21(a0)
	bra.s	plupetit
.plusgrand
	addq.b	#1,21(a0)
	cmp.b	#3,21(a0)
	bls.s	plupetit
	move.b	#0,21(a0)
plupetit
	move.w	#4,d1
	move.l  #screen+32000+65*160+136+6,where
	move.w	#0,compt2
	move.b  21(a0),d0
	bset	#7,d0
	move.w	d0,setloadfrq
	bclr    #7,d0
	mulu	#4,d0
	lea	FREQUENCE,a0
	add.l	d0,a0
	move.l  (a0),a0
	bsr	PRINT
rt7	rts
setloadfrq	dc.w	129
*************************************************************************
MOINSFRQSPL
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	cmp.l	#0,26(a0)
	beq.s	rt7
	cmp.b	#127,21(a0)
	bls.s	.plusgrand2
	subq.b	#1,21(a0)
	cmp.b	#127,21(a0)
	bne.s	plupetit
	move.b	#131,21(a0)
	bra.s	plupetit
.plusgrand2
	subq.b	#1,21(a0)
	cmp.b	#-1,21(a0)
	bne	plupetit
	move.b	#3,21(a0)
	bra	plupetit
	
*************************************************************************
MONOSTEREO
	MOVE.B	#0,KEY
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	cmp.l	#0,26(a0)
	beq.s	rt7
	bchg	#7,21(a0)
	JSR	AFFMONO
	rts
*************************************************************************
LOOP	moveq	#0,d0
	MOVE.B	#0,KEY
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	cmp.b	#1,35(a0)
	beq.s	.loop2
	move.b	#1,35(a0)
	rts
.loop2	move.b	#3,35(a0)
	rts
************************************************************************
CLRPAT	move.w	#5,okp
	rts
CLRPAT1
	bsr	INVERT_CLRPAT
	moveq	#0,d0
	moveq	#0,d1
	cmp.b	#1,all
	beq.s	CLR_ALLPAT
	move.l	addpatt,a0
	move.b	voies,d0
	mulu	#64*4,d0		* 64 patterns de 5 octets par voie
	subq.w	#1,d0
.clrp	move.b	d1,(a0)+
	dbf	d0,.clrp
	bsr	INVERT_CLRPAT
	move.b	#0,inpatt
	bsr	AFFPATTERN2
	jsr	FOND2
	move.w	#0,okp
	rts
CLR_ALLPAT
	lea	PATTERNS,a0
	move.b	voies,d0
	move.b	maxpatt,d1
	mulu	#64*4,d0
	mulu	d1,d0
	moveq	#0,d1
.clralp	move.b	d1,(a0)+
	subq.l	#1,d0
	bne.s	.clralp
	bsr	INVERT_CLRPAT
	bsr	INVERT_CLRALL
	move.b	#0,inpatt
	move.b	#0,all
	bsr	AFFPATTERN2
	JSR	FOND2
	move.w	#0,okp
	rts
************************************************************************
CLRALL
	bsr	INVERT_CLRALL
	bchg	#0,all
	rts
all	dc.b	0
	even
************************************************************************
CLRSAM	move.w	#4,okp
	rts
CLRSAM1
	bsr	INVERT_CLRSAM
	cmp.b	#0,all
	beq	CLR_ONE
	lea	SAMPLE,a0
	moveQ	#63,d0
.clrsa	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.b	#0,(a0)+
	move.b	#129,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.w	#1,(a0)+
	move.l	#0,(a0)+
	dbf	d0,.clrsa
	move.l	addspl,endaddr
	bsr	FRE
	bsr	INVERT_CLRALL
	bsr	INVERT_CLRSAM
	move.b	#0,all
	lea	NAMESAMPLE,a0
	move.w	#(256*13)-1,d0
.wxc	move.b	#0,(a0)+
	dbf	d0,.wxc
	JSR	FOND2
	move.w	#0,okp
	rts
CLR_ONE
	bsr	ERASE
	bsr	INVERT_CLRSAM
	JSR	FOND2
	move.w	#0,okp
	rts
************************************************************************
*	IN : D0 = Nombre a convertir
*	     A0 = Adresse ou convertir
CONVERT_BYTE_DECI
	divu	#100,d0			* converti les centaines
	add.w	#'0',d0
	move.b	d0,(a0)
	move.w	#0,d0
	swap	d0
	divu	#10,d0			* converti les dizaines
	add.w	#'0',d0
	move.b	d0,1(a0)
	swap	d0			* puis les unites
	add.w	#'0',d0
	move.b	d0,2(a0)
	moveq	#2,d0			* vire les '0' en trop
.stll	cmp.b	#'0',(a0)
	bne.s	.srt
	move.b  #0,(a0)+
	subq	#1,d0
	bne.s	.stll
.srt	rts
************************************************************************
SUBPAT100
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#99,d0
	ble	re
	sub.b	#100,d0
	bra.s	fish
SUBPAT10
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#9,d0
	ble	re
	sub.b	#10,d0
	bra.s	fish
SUBPAT1
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#0,d0
	beq	re
	subq.b	#1,d0
	bra.s	fish
ADDPAT100
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#155,d0
	bge	re
	add.b	#100,d0
	bra.s	fish
ADDPAT10
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#245,d0
	bge	re
	add.b	#10,d0
	bra.s	fish
ADDPAT1
	moveq	#0,d0
	move.b	curpatt,d0
	cmp.w	#255,d0
	beq	re
	addq.b	#1,d0
fish	cmp.b	maxpatt,d0
	ble.S	.thats
	move.b	maxpatt,d0
.thats	move.b	d0,curpatt
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+25*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	moveq	#0,d0
	moveq	#0,d1
	move.b	curseq,d1
	move.b	curpatt,d0		*Place la pattern courante
	move.l	addseq,a0		*dans la sequence
	add.l	d1,a0
	move.b	d0,(a0)
yep	lea	PATTERNS,a0
	move.b	cvoies,d1		*Calcul l'adresse de la
	mulu	d1,d0			*pattern choisie
	mulu	#64,d0
	add.l	d0,a0
	move.l	a0,addpatt
	move.b	#0,inpatt
	cmp.b	#1,playsong
	beq.s	re
	bsr	AFFPATTERN
re	rts
************************************************************************
SUBPOS100
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#99,d0
	ble	re1
	sub.b	#100,d0
	bra.s	fish1
SUBPOS10
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#9,d0
	ble	re1
	sub.b	#10,d0
	bra.s	fish1
SUBPOS1
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#0,d0
	beq	re1
	subq.b	#1,d0
	bra.s	fish1
ADDPOS100
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#155,d0
	bge	re1
	add.b	#100,d0
	bra.s	fish1
ADDPOS10
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#245,d0
	bge	re1
	add.b	#10,d0
	bra.s	fish1
ADDPOS1
	moveq	#0,d0
	move.b	curseq,d0
	cmp.w	#255,d0
	beq	re1
	addq.b	#1,d0
fish1	moveq	#0,d1
	move.b	curlen,d1
	cmp.w	d1,d0
	blt.s	.fish3
	move.b	d1,d0
.fish3	move.b	d0,curseq
frigo	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+17*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	moveq	#0,d0				*puisque la postion dans
	move.b	curseq,d0			*la sequence a ete modifie
	move.l	addseq,a0			*on affiche la pattern
	add.l	d0,a0				*correspondante.
	move.b	(a0),d0				*la pattern devient donc
	move.b	d0,curpatt			*courante
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+25*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	moveq	#0,d0
	move.b	curpatt,d0
	bra	yep
re1	rts
************************************************************************
SUBNUM100
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#99,d0
	ble	re2
	sub.b	#100,d0
	bra.s	fish2
SUBNUM10
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#9,d0
	ble	re2
	sub.b	#10,d0
	bra.s	fish2
SUBNUM1
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#0,d0
	beq	re2
	subq.b	#1,d0
	bra.s	fish2
ADDNUM100
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#155,d0
	bge	re2
	add.b	#100,d0
	bra.s	fish2
ADDNUM10
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#245,d0
	bge	re2
	add.b	#10,d0
	bra.s	fish2
ADDNUM1
	moveq	#0,d0
	move.b	curnum,d0
	cmp.w	#255,d0
	beq	re2
	addq.b	#1,d0
fish2	cmp.b	maxzic,d0
	blt.s	.mm
	move.b	maxzic,d0
.mm	move.b	d0,curnum
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+9*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	moveq	#0,d0			*puisqu'on change de zik
	move.b	d0,curseq		*on remet a zero les compteurs 
					*de position (sequence)
	move.b	curnum,d0
	lsl	#8,d0			* 256
	lea	SEQUENCE,a0
	add.l	d0,a0
	move.l	a0,addseq
	move.b	(a0),curpatt		*et de pattern

	moveq	#0,d0
	move.b	curnum,d0
	mulu	#2,d0
	lea	MUSIQUE,a1
	add.w	d0,a1
	moveq	#0,d0
	move.b	(a1),d0			* on reaffiche la longueur
	move.b	d0,curlen
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+33*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	moveq	#0,d0
	move.b	1(a1),d0			* et le loop
	move.b	d0,curlop
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+41*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	bra	frigo			*puis on va afficher le tout
re2	rts
char3	dc.b 	'  0'			* 3 characteres
	even
************************************************************************
SUBLEN100
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#99,d0
	ble.s	re2
	sub.b	#100,d0
	bra.s	rabbit
SUBLEN10
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#9,d0
	ble.S	re2
	sub.b	#10,d0
	bra.s	rabbit
SUBLEN1
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#0,d0
	beq.S	re2
	subq.b	#1,d0
	bra.s	rabbit
ADDLEN100
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#155,d0
	bge.S	re2
	add.b	#100,d0
	bra.s	rabbit
ADDLEN10
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#245,d0
	bge.S	re2
	add.b	#10,d0
	bra.s	rabbit
ADDLEN1
	moveq	#0,d0
	move.b	curlen,d0
	cmp.w	#255,d0
	beq.S	re2
	addq.b	#1,d0
rabbit	lea	MUSIQUE,a0
	moveq	#0,d1
	move.b	curnum,d1
	mulu	#2,d1
	add.w	d1,a0
	move.b	d0,(a0)
	move.b	d0,curlen
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+33*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	rts
************************************************************************
SUBLOP100
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#99,d0
	ble	re2
	sub.b	#100,d0
	bra.s	cow
SUBLOP10
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#9,d0
	ble	re2
	sub.b	#10,d0
	bra.s	cow
SUBLOP1
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#0,d0
	beq	re2
	subq.b	#1,d0
	bra.s	cow
ADDLOP100
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#155,d0
	bge	re2
	add.b	#100,d0
	bra.s	cow
ADDLOP10
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#245,d0
	bge	re2
	add.b	#10,d0
	bra.s	cow
ADDLOP1
	moveq	#0,d0
	move.b	curlop,d0
	cmp.w	#255,d0
	beq	re2
	addq.b	#1,d0
cow	lea	MUSIQUE,a0
	moveq	#0,d1
	move.b	curnum,d1
	mulu	#2,d1
	add.w	d1,a0
	move.b	d0,1(a0)
	move.b	d0,curlop
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+41*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	rts
************************************************************************
SILENT  movem.l	d0-a0,-(a7)
	MOVE.B	#0,KEY
	move.w	#0,$FFFF8900.W          
	move.b	dernier,curentnb2
	move.b	dernier,sampledata

	lea	VOICE0,a0
	bsr	clear1
	lea	VOICE1,a0
	bsr	clear1
	lea	VOICE2,a0
	bsr	clear1
	lea	VOICE3,a0
	bsr	clear1
	lea	VOICE4,a0
	bsr	clear1
	lea	VOICE5,a0
	bsr	clear1
	lea	VOICE6,a0
	bsr	clear1
	lea	VOICE7,a0
	bsr	clear1
	lea	VOICE8,a0
	bsr.S	clear1
	lea	VOICE9,a0
	bsr.S	clear1
	lea	VOICE10,a0
	bsr.S	clear1

	cmp.b	#1,playpat
	bne.s	.rt6
	move.b	#0,playpat
	bsr	INVERT_PLAYPATT
.rt6	cmp.b	#1,record
	bne.s	.rt4
	move.b	#0,record
	bsr	INVERT_RECORD
.rt4	cmp.b	#1,edit
	bne.s	.rt2
	bsr	INVERT_EDIT
	move.b	#0,edit
.rt2	cmp.b	#1,playsong
	bne.s	.rt14
	move.b	#0,playsong
	BSR	INVERT_PLAYSONG
.rt14	BSR	AFFPATTERN
	JSR	FOND2
	movem.l	(a7)+,d0-a0
	rts
dernier	dc.b	0
	even
clear1	
	move.l	#0,(a0)
	move.l	#0,4(a0)
	move.l	#0,8(a0)
	move.l	#0,12(a0)
	move.l	#0,16(a0)
	move.l	#0,20(a0)
	move.b	#$40,21(a0)
	move.b	#$40,37(a0)
	rts
************************************************************************
SPESPL	MOVE.B	#0,KEY
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a1
	add.l	d0,a1
	cmp.l	#0,26(a1)
	beq.s	.pasdutout
	move.l	a1,heretoconvert
	move.w	#6,okp
.pasdutout
	rts	
heretoconvert
	dc.l	0
**************************************************************************
SPL	move.b  #4,curentmask
	move.w	#0,EH_NON
	bra	pasretourne
SPE	move.b	#8,curentmask
	move.w	#0,EH_NON
	bra	pasretourne	
BNK	move.b	#5,curentmask
	move.w	#1,EH_NON
	bra	pasretourne	
AVR	move.b	#0,curentmask
	move.w	#0,EH_NON
	bra	pasretourne	
MOD	move.b	#6,curentmask
	move.w	#1,EH_NON
	bra.s	pasretourne	
PTN	move.b	#1,curentmask
	move.w	#0,EH_NON
	bra.s	pasretourne	
SNG	move.b	#3,curentmask
	move.w	#1,EH_NON
	bra.s	pasretourne	
YAM	move.b	#9,curentmask
	move.w	#0,EH_NON
	bra.s	pasretourne	
MUS	move.b	#2,curentmask
	move.w	#1,EH_NON
	bra.s	pasretourne	
SAM	move.b	#7,curentmask
	move.w	#0,EH_NON
	bra.s	pasretourne	

MSKLOAD
	MOVE.B	#0,KEY
	moveq	#0,d0
	move.b	curentmask,d0
	addq.b	#1,d0
	cmp.b	#10,d0
	bne.s	.pasr
	move.b	#0,d0
.pasr	move.b	d0,curentmask
pasretourne
	moveq	#0,d0
	move.b	curentmask,d0
	lea	maskdata,a0
	mulu	#4,d0
	add.l	d0,a0
	move.l	(a0),a0
	lea	MASQUE,a1
	move.l	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	MOVE.W	#0,XS
	MOVE.W	#0,YS
	MOVE.W	#8,LS
	MOVE.W	#8,X
	MOVE.W	#7,Y
        MOVE.L	#FLECHEFOND,SOURCE
        MOVE.L	#screen,DEST
        MOVE.W	#160,LD
        MOVE.W	oldx,XD
        MOVE.W	oldy,YD
        JSR	blit_it
	lea	dataicone,a0
	add.l	d0,a0
	move.w	(a0)+,oldx
	move.w	(a0)+,oldy
	lea	dg,a0
	add.l	d0,a0
	MOVE.L	(A0),SOURCE
	MOVE.W	oldx,XD
        MOVE.W	oldy,YD
        JSR	blit_it
	MOVE.W	#0,IN_MOD
	MOVE.W	#0,P_MOD
	MOVE.W	#1,CHANGREP
	MOVE.W	#8,okp
	rts
	

maskdata	dc.l	maskavr,maskptn,maskmus,masksng,maskspl
		dc.l	maskbnk,maskmod,masksam,maskspe,maskyam,-1
maskavr	dc.b	'*.AVR',0
maskptn	dc.b 	'*.PTN',0
maskmus dc.b	'*.MUS',0
masksng	dc.b 	'*.SNG',0
maskspl	dc.b 	'*.SPL',0
maskbnk	dc.b 	'*.BNK',0
maskmod	dc.b 	'*.MOD',0
masksam	dc.b	'*.SAM',0
maskspe	dc.b 	'*.SPE',0
maskyam dc.b	'*.YAM',0
	dc.l	-1
dataicone
	dc.w 	26,41,26,49,26,57,26,65,26,73,39,41,39,49,39,57,39,65,39,73
dg	dc.l	FLECHEGAUCHE,FLECHEGAUCHE,FLECHEGAUCHE,FLECHEGAUCHE,FLECHEGAUCHE
	dc.l	FLECHEDROITE,FLECHEDROITE,FLECHEDROITE,FLECHEDROITE,FLECHEDROITE
oldx	dc.w	26
oldy	dc.w	73
**************************************************************************
SAUVEUR				* oh! mon sauveur
	move.w	#10,okp
	rts
SAUVE
	move.l	#DEFAULT,string
	move.b	#12,maxlet
	moveq	#0,d0
	moveq	#0,d1
	move.b	curentmask,d1
	lea	maskavr,a2
	mulu	#6,d1
	addq.w	#2,d1
	add.l	d1,a2
	lea	FILE_LOADED,a0
	move.b	#'*',(a0)
	move.b	#'.',1(a0)
	move.b	(a2),2(a0)
	move.b	1(a2),3(a0)
	move.b	2(a2),4(a0)
	move.b	#0,5(a0)
	lea	NAMESAMPLE,a0
	move.b	sampledata,d0
	mulu	#13,d0
	add.l	d0,a0
	addq.w	#1,a0
	lea	DEFAULT,a1
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	move.l	#0,(a1)+
	moveq	#8,d0
	lea	DEFAULT,a1
.ls	cmp.b	#'.',(a0)
	beq.s	.sl
	move.b	(a0)+,(a1)+
	subq	#1,d0
	beq.s	.sl
	bra.s	.ls
.sl	move.b	#'.',(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	#0,(a1)+

sel	MOVEQ	#22,D1
	LEA	rrien,A0
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt2
	BSR	PRINT

	moveq	#12,d1
	lea	DEFAULT,a0
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt2
	BSR	PRINT

	MOVE.W	#1,compt
	MOVE.L	#screen+160*9+47,where2
	MOVE.B	#0,lastouche
	BSR	INPT

	MOVEQ	#22,D1
	LEA	PATH+3,A0
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt2
	BSR	PRINT

	cmp.w	#5,erreur
	beq.s	.je_veux_pas
	lea	PATH,a0
	lea	AFFICHAGE,a1
	lea	DEFAULT,a2
.tt2	cmp.b	#0,(a0)
	beq.s	.tt1
	move.b	(a0)+,(a1)+
	bra.s	.tt2
.tt1	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	move.b	#0,(a1)+
	move.l	#skindata,kind		
	bsr	KIND_OF_LOADED_FILE
.je_veux_pas
	move.w	#0,okp
	move.w	#0,erreur
	bsr	AFFMOUSE
	rts
rrien	dc.b	'                      '
**************************************************************************	
LOADER	move.w	#9,okp
	rts
LOADE	
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+86*160+23,where
	move.w	#1,compt2
	BSR	PRINT

	CMP.W	#1,IN_MOD
	BEQ	L_SPL_MOD
	
	LEA	DIR_FILES,A0
.OUI	CMP.B	#'*',(A0)
	BEQ	.NON
	CMP.B	#0,(A0)
	BEQ	ALL_FOLKS	
	CMP.B	#$21,(A0)
	BNE	.NON
	MOVEQ	#0,D0
	MOVE.B	#$20,(A0)
	MOVE.B	1(A0),D0
	LEA	ADD_REP,A1
	ADD.L	D0,D0
	ADD.L	D0,D0
	ADD.L	D0,A1
	MOVE.L	(A1),A1
	LEA	AFFICHAGE+3,A2
	MOVEQ	#64+8,D0
.CLEAN5	MOVE.B	#0,(A2)+
	DBF	D0,.CLEAN5
	LEA	AFFICHAGE+3,A2
.OUPS	TST.B	(A1)
	BEQ.S	.FOLL
	MOVE.B	(A1)+,(A2)+
	BRA.S	.OUPS
.FOLL	MOVE.B	2(A0),(A2)+
	MOVE.B	3(A0),(A2)+
	MOVE.B	4(A0),(A2)+
	MOVE.B	5(A0),(A2)+
	MOVE.B	6(A0),(A2)+
	MOVE.B	7(A0),(A2)+
	MOVE.B	8(A0),(A2)+
	MOVE.B	9(A0),(A2)+
	MOVE.B	10(A0),(A2)+
	MOVE.B	11(A0),(A2)+
	MOVE.B	12(A0),(A2)+
	MOVE.B	13(A0),(A2)+
	MOVE.B	14(A0),(A2)+
	LEA	FILE_LOADED,A3
.ML	CMP.B	#'\',(A2)
	BEQ.S	.NO_EXT
	CMP.B	#'.',(A2)
	BEQ.S	.RIGHT
	LEA	-1(A2),A2
	BRA.S	.ML
.RIGHT	MOVE.B	#'*',(A3)+
	MOVE.B	(A2)+,(A3)+
	MOVE.B	(A2)+,(A3)+
	MOVE.B	(A2)+,(A3)+
	MOVE.B	(A2)+,(A3)+
	BRA.S	.ON_CHARGE
.NO_EXT	MOVE.B	#'*',(A3)+
	MOVE.B	#'.',(A3)+
	MOVE.B	#'B',(A3)+
	MOVE.B	#'O',(A3)+
	MOVE.B	#'F',(A3)+
.ON_CHARGE
	MOVEM.L	D0-D7/A0-A6,-(A7)
	LEA	AFFICHAGE+3,A0
	MOVEQ	#22,D1
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt
	MOVE.W	#0,compt2
	BSR	PRINT
	BSR.S	CHARGE
	MOVEM.L	(A7)+,D0-D7/A0-A6
	cmp.w	#2,erreur
	beq.s	ALL_FOLKS
.NON	LEA	18(A0),A0
	BRA	.OUI

CHARGE	
	cmp.w	#-1,IN_MOD
	beq	L_SPL_MOD
	moveq	#0,d1
	move.l	#lkindata,kind		
	bsr.S	KIND_OF_LOADED_FILE
        moveq	#0,d0
	cmp.w	#0,erreur
	bne.S	.pascharge
	bsr	RESTITU
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
        bsr	SUM
        bsr	FRE
.pascharge
	move.b	sampledata,dernier
	RTS
ALL_FOLKS
	MOVE.w	#0,$ffff8240.w
	LEA	FILES_TO_SORT,A0
	MOVEQ	#17,D0
.CLEAN6	BCLR.B	#0,(A0)
	LEA	18(A0),A0
	DBF	D0,.CLEAN6
	JSR	AFF_FS
	move.w	#0,erreur
	move.b	#0,touche
	move.w	#0,okp
	rts				* Fin

KIND_OF_LOADED_FILE
	lea	FILE_LOADED,a0
	move.l	maskdata,a1
	move.l	kind,a2
.icii	move.b	2(a0),d0
	move.b	2(a1),d1
	cmp.b	d0,d1
	bne.s	.c_pas_ca
	move.b 3(a0),d0
	move.b 3(a1),d1
	cmp.b	d0,d1
	bne.s	.c_pas_ca
	move.b 4(a0),d0
	move.b 4(a1),d1
	cmp.b	d0,d1
	bne.s	.c_pas_ca
	move.l	(a2),a2
	jmp	(a2)
.c_pas_ca
	addq.l	#6,a1
	cmp.l	#-1,(a1)
	beq.s	.c_la_fin
	addq.l	#4,a2
	bra.s	.icii
.c_la_fin
	cmp.l	#skindata,kind
	beq.s	.saver
	bra.s	l_spl
.saver	move.w	#4,erreur
	rts

l_spl	addq.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	lea	AFFICHAGE,a0
	bsr	LOAD
	bsr	SEARCHFREESPL
	move.l	a1,a2
	move.b	#$40,34(a1)
	move.l	endaddr,22(a1)	* START
	move.l	endaddr,36(a1)	* LOOP
	move.l	long,d0
	*subq.l	#8,d0
	bclr	#0,d0			*Adresse paire
	move.l	d0,26(a1)		* LENGHT
	add.l	d0,endaddr		* END in memory
	move.l	endaddr,30(a1)		* END
	add.l	#FINSAMPLE,d0
	add.l	#FINSAMPLE,endaddr
	move.l	d0,long			* pour la fin du sample
	add.l	d0,lensamples
	move.b	setloadfrq,21(a1)	* Set Default Frequency
	bsr	SPLTOSPE		* Convertit le spl au ste
	bsr	ZEROFINSPL		* Rajoute 1024 octets nuls
ff4	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#13,d0
	lea	NAMESAMPLE,a2
	add.l	d0,a2
	addq.l	#1,a2
	lea	AFFICHAGE,a0
.ff1	cmp.b  #0,(a0)+
	bne.s	.ff1
.ff2	cmp.b  #'\',-(a0)
	bne.s	.ff2
	addq.l	#1,a0
.ff3	move.b	(a0),(a1)+
	move.b	(a0)+,(a2)+
	cmp.b  #0,(a0)
	beq.s	pasplus
	bra.s	.ff3
pasplus rts

l_sam	addq.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	lea	AFFICHAGE,a0
	bsr	LOAD
	bsr	SEARCHFREESPL
	move.l	a1,a2
	move.b	#$40,34(a1)
	move.l	endaddr,22(a1)	* START
	move.l	endaddr,36(a1)	* LOOP
	move.l	long,d0
	sub.l	#12,d0
	move.l	endaddr,a0
	lea	12(a0),a2
	move.l	d0,d1
.ccc1	move.b	(a2)+,(a0)+
	subq.l	#1,d1
	bne.s	.ccc1
	move.l	d0,26(a1)		* LENGHT
	add.l	#FINSAMPLE,d0
	move.l	d0,long
	add.l	d0,endaddr		* END in memory
	move.l	endaddr,30(a1)		* END
	sub.l	#FINSAMPLE,30(a1)
	bsr	ZEROFINSPL
	bra	ff4
	
l_spe	addq.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	lea	AFFICHAGE,a0
	bsr	LOAD
	move.l	endaddr,a0
	bsr	SEARCHFREESPL
	addq.l	#4,a0
	move.l	a1,a2
	move.l	a1,a4
	rept 10
	move.l	(a0)+,(a2)+
	endr
	move.l	endaddr,d0
	move.l	d0,a0
	move.l	d0,a3
	add.l	d0,22(a1)		*reloge START
	add.l   d0,30(a1)		*	 END
	add.l	d0,36(a1)		*	 LOOP
	move.l	26(a1),d0
	add.l	#FINSAMPLE,d0
	move.l	d0,long
	add.l	d0,endaddr		*Ou se chargera le prochain sample
	add.l	d0,lensamples
	move.l	26(a1),a1		*a1 = longeur
	lea	40(a3),a2		*a2 = debut du sample
					*a0 = debut memoire
.conti	move.b	(a2)+,(a0)+		
	subq.l	#1,a1			* et on recopie le sample 40 octets
	bne.s	.conti			* en arriere
	move.l	a4,a1
	bsr	ZEROFINSPL
	moveq	#0,d0
gff4	move.b	sampledata,d0
	mulu	#13,d0
	lea	NAMESAMPLE,a2
	add.l	d0,a2
	addq.l	#1,a2
	lea	AFFICHAGE,a0
gff1	cmp.b  #0,(a0)+
	bne.s	gff1
.gff2	cmp.b  #'\',-(a0)
	bne.s	.gff2
	addq.l	#1,a0
.gff3	move.b	(a0)+,(a2)+
	cmp.b  #0,(a0)
	beq.s	.pasps
	bra.s	.gff3
.pasps   rts
	
l_bnk	lea	AFFICHAGE,a0
	move.l	addspl,endaddr
	bsr	LOAD
	bsr	FRE
	lea	SAMPLE,a1		* replace data
	move.l	addspl,a0
	move.b	4(a0),totalsample
	move.b	5(a0),totalyam
	move.l	6(a0),d0
	subq.l	#1,d0
	lea	22(a0),a2
.l_bnk1	move.b	(a2)+,(a1)+
	dbf	d0,.l_bnk1

	lea	SAMPLE,a1		* reloge data
	move.l	addspl,d0
	move.l	#255,d3
.l_bnk2	cmp.l	#0,26(a1)
	beq.s	.l_bnk3
	add.l	d0,22(a1)
	add.l	d0,30(a1)
	add.l	d0,36(a1)
.l_bnk3	add.l	#40,a1
	dbf	d3,.l_bnk2
	;move.l	d1,long
	move.l	14(a0),d1
	add.l	d1,endaddr
	move.L	18(a0),d1
	add.l	d1,endaddr
	move.l	d0,lensamples
	move.l	addspl,a2		* replace sample
	add.l	6(a0),a2
	add.l	10(a0),a2
	move.l	addspl,a1
	move.l	14(a0),d1
	add.l	#22,a1
	add.l	6(a0),a1
	add.l	10(a0),a1
l_bnk4	move.l	(a1)+,(a0)+
	subq.l	#4,d1
	cmp.l	#0,d1
	bgt.s	l_bnk4
	lea	AFFICHAGE,a0
	lea	NAMEBANK,a2
	bra	gff1
	rts

l_avr	addq.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	lea	AFFICHAGE,a0
	bsr	LOAD
	move.l	endaddr,a0
	bsr	SEARCHFREESPL
	move.l	a1,a2
	move.l	a1,a4
	move.b	#$40,34(a1)
	move.l	4(a0),(a1)		* ecrit le nom de 8 lettres
	move.l	8(a0),4(a1)
	cmp.w	#0,12(a0)
	bne.s	stereo
	move.b	#129,21(a1)
	bra.S	mono
stereo	move.b	#1,21(a1)
mono	cmp.w	#8,14(a0)		* sample  8 bits ?
	beq.s	bit8
	cmp.w	#10,14(a0)		* sample 16 bits ?
	beq.s	bit16
	lea	128(a0),a2		* sinon  12 bits
	move.l	long,d0			
	sub.l	#128,d0
cvert1	move.b	(a2),d1
	lsr.b	#2,d1			* convertit 12 bits to 8 bits
	move.b d1,(a2)+
	subq.l	#1,d0
	bne.s	cvert1
	bra.s	bit8
bit16	lea	128(a0),a2		
	move.l	long,d0
	sub.l	#128,d0
cvert2	move.b	(a2),d1
	lsr.b	#3,d1			* convertit 16 bits to 8 bits
	move.b	d1,(a2)+
	subq.l	#1,d0
	bne.s	cvert2
bit8	cmp.w	#-1,16(a0)
	beq.s	signe
	lea	128(a0),a2
	move.l	long,d0
	sub.l	#128,d0
	move.b	#$80,d1
cvert3	add.b	d1,(a2)+		* convertit non signe to signe
	subq.l	#1,d0
	bne.s	cvert3
signe	cmp.w	#0,18(a0)
	beq.s	noloop
	move.b	#3,35(a1)
	move.l	30(a0),d1
	cmp.w	#-1,12(a0)		* loop point
	bne.s	c_stereo
	mulu	#2,d1
c_stereo
	move.l	d1,36(a1)	
	move.l	endaddr,d1
	add.l	d1,36(a1)
	move.l	endaddr,36(a0)
noloop	move.l	endaddr,22(a1)		* Start
	move.l	long,26(a1)		* Lenght
	sub.l	#128,26(a1)
	move.l	26(a1),d1
	add.l	22(a1),d1		* End
	move.l	d1,30(a1)
	move.l	endaddr,a0		* Et on deplace le tout
	move.l	26(a1),d0		* 128 octets en arriere
	lea	128(a0),a1		
copii	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	copii
	move.l	a4,a1
	bsr	ZEROFINSPL
	move.l	long,d1
	add.l	#FINSAMPLE-128,d1
	add.l	d1,endaddr
	add.l	d1,lensamples
	bclr.b	#0,endaddr+3
	bclr.b	#0,lensamples+3
	bra	gff4
l_ptn
	lea	AFFICHAGE,a0
	bsr	LOAD
	move.l	endaddr,a0
	cmp.l	#'PTN!',(a0)
	bne.S	l_mus
	moveq	#0,d0
	move.b	4(a0),d0
	add.b	5(a0),d0
	mulu	#64*5,d0
	move.l	addpatt,a1
	lea	6(a0),a0
.c_ptn	move.b	(a0)+,(a1)+
	subq.w	#1,d0
	bne.s	.c_ptn
	rts
l_sng
l_yam
	rts
toomuch	move.w	#2,erreur
	rts
l_mus
	LEA	AFFICHAGE,A0
	BSR	LOAD
	MOVEQ	#1,D0
	MOVE.L	endaddr,A0
	MOVE.L	A0,MADMAX
	ADDQ.L	#8,MADMAX
	JSR	(a0)
	MOVE.L	long,D0
	ADD.L	D0,endaddr
	RTS
MADMAX	DC.L	0
		
l_mod	LEA	AFFICHAGE,A0
	BSR	LOAD
	MOVE.L	endaddr,A0
	CMP.W	#'if',(A0)
	BNE	NOT_MOD_669
	BSR	INITMEG
	MOVE.L	endaddr,A0
	LEA	VOICE0,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE1,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE2,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE3,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE4,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE5,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE6,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE7,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE8,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE9,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE10,A1
	MOVE.B	#0,25(A1)
	move.l	long,d0
	MOVE.L	$42E.W,A1
	move.l	a1,a2
	add.l	d0,a0
	sub.L	d0,a2
.reco16	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	subq.l	#8,d0
	bpl.s	.reco16
	move.l	a2,a1
	move.l	a1,a6
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.B	$6E(A1),D0
	SUBQ.B	#1,D0
	LEA	$1F1(A1),A0
	LEA	SAMPLE,A2
	
.RECO18	
	MOVEQ	#0,D3
	MOVE.B	14(A0),D3
	LSL	#8,D3
	MOVE.B	15(A0),D3
	CMP.W	#0,D3
	BEQ.S	.NOM
	MOVE.B	(A0),(A2)
	MOVE.B	1(A0),1(A2)
	MOVE.B	2(A0),2(A2)
	MOVE.B	3(A0),3(A2)
	MOVE.B	4(A0),4(A2)
	MOVE.B	5(A0),5(A2)
	MOVE.B	6(A0),6(A2)
	MOVE.B	7(A0),7(A2)
	MOVE.B	8(A0),8(A2)
	MOVE.B	9(A0),9(A2)
	MOVE.B	10(A0),10(A2)
	MOVE.B	11(A0),11(A2)
	MOVE.B	12(A0),12(A2)
	MOVE.L	D2,22(A2)		* START
	ADD.W	D3,D2
	MOVE.L	D3,26(A2)
	MOVE.L	D2,30(A2)		* END
	MOVE.B	16(A0),D3
	LSL	#8,D3
	MOVE.B	17(A0),D3
	ADD.L	22(A2),D3
	MOVE.L	D3,36(A2)
	MOVE.B	#$40,34(A2)
	ADD.L	#FINSAMPLE,D2
.NOM	ADD.W	#40,A2
	ADD.W	#25,A0
	DBF	D0,.RECO18
	
	LEA	$71(A1),A2
	MOVE.L	addseq,A3
	LEA	MUSIQUE,A4
	MOVEQ	#127,D0
.RECO24	MOVE.B	(A2)+,D1
	CMP.B	#$FF,D1
	BEQ.S	.CONT3
	MOVE.B	D1,(A3)+
	DBF	D0,.RECO24
	BRA.S	.RECO25
.CONT3	MOVE.B	#127,(A4)
	SUB.B	D0,(A4)
.CONT4	MOVE.B	#0,(A3)+
	DBF	D0,.CONT4
	MOVE.B	$70(A1),1(A4)
	
.RECO25	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	$6F(A1),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,maxpatt
	MOVE.L	debpatt,A2
	LEA	TABLE_669_EFFECT,A3
.RECO19	MOVEQ	#63,D4
.RECO22	MOVEQ	#7,D5
.RECO21	MOVE.B	(A0)+,D1
	MOVE.B	D1,D2
	CMP.B	#$FF,D1
	BNE.S	.GF3
	MOVEQ	#0,D1
.GF3	CMP.B	#$FE,D1
	BNE.S	.GF5
	MOVEQ	#0,D1
	MOVEQ	#-1,D2
.GF5	LSR.B	#2,D1
	MOVE.B	D1,(A2)+		* NOTE
	AND.B	#3,D2
	LSL.B	#4,D2
	MOVE.B	(A0)+,D1
	MOVE.B	D1,D3
	LSR.B	#4,D1
	ADD.B	D2,D1
	CMP.B	#63,D1
	BNE.S	.GF4
	MOVEQ.B	#-1,D1
.GF4	ADDQ.B	#1,D1
	MOVE.B	D1,(A2)+		* INSTRU
	AND.B	#$F,D3			* VOLUME	?
	MOVE.B	(A0)+,D1
	MOVE.B	D1,D2
	LSR.B	#4,D1
	CMP.B	#$F,D1
	BNE.S	.GF1
	MOVEQ	#6,D1			* = NO COM
.GF1	MOVE.B	(A3,D1.W),(A2)+		* COMMAND
	AND.B	#$F,D2
	CMP.B	#$F,D2
	BNE.S	.GF2
	MOVEQ	#0,D2
.GF2	MOVE.B	D2,(A2)+		* PARAMETRE
	DBF	D5,.RECO21
	MOVE.L	#0,(A2)+
	MOVE.L	#0,(A2)+
	MOVE.L	#0,(A2)+
	DBF	D4,.RECO22
	DBF	D0,.RECO19
	
	MOVE.L	A2,addspl
	MOVE.L	A2,D1
	LEA	SAMPLE,A3
	MOVEQ.B	#-$80,D7
	MOVE.L	#255,D0
.reco17	CMP.L	#0,26(A3)
	BEQ.S	.reco18
	ADD.L	D1,22(A3)
	ADD.L	D1,30(A3)
	ADD.L	D1,36(A3)
	MOVE.L	26(A3),D2
	SUBQ	#1,D2
.reco19	MOVE.B	(A0)+,D6
	ADD.B	D7,D6
	MOVE.B	D6,(A2)+
	DBF	D2,.reco19
	ADD.L	#FINSAMPLE,A2
	MOVE.L	A3,A1
	MOVE.L	A3,heretoconvert
	CMP.B	#3,35(A3)
	BEQ.S	.RECO20
	BSR	ZEROFINSPL
	BRA.S	.RECO23
.RECO20	BSR	BCLFINSPL
.RECO23	BSR	D_4
.reco18	ADD.W	#40,A3
	DBF	D0,.reco17
	MOVE.L	A2,endaddr
	SUB.L	addspl,A2
	MOVE.L	A2,lensamples
	
	
	LEA	VOICE0,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE1,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE2,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE3,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE4,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE5,A0
	MOVE.W	#4,24(A0)
	
	IFNE	FRQ_25	
	MOVE.B	#6,digvoices
	ENDC
	
	IFNE	FRQ_12	
	LEA	VOICE6,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE7,A0
	MOVE.W	#4,24(A0)
	MOVE.B	#8,digvoices
	ENDC
	
	MOVE.B	#0,inpatt
	MOVE.B	#0,yamvoices
	MOVEQ	#0,D0
	MOVE.L	addseq,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MULU	#64*4*11,D0
	ADD.L	D0,A2
	MOVE.L	A2,addpatt
	BSR	SETT
	BSR	AFFPATTERN2
	RTS
TABLE_669_EFFECT	DC.B	1,2,3,$11,4,$F,0,0
***************************************************************************	
NOT_MOD_669
	CMP.L	#'MCS!',(A0)
	BNE	NOT_MOD_MCS
	
	BSR	INITMEG
	MOVE.L	endaddr,A0
	LEA	VOICE0,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE1,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE2,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE3,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE4,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE5,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE6,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE7,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE8,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE9,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE10,A1
	MOVE.B	#0,25(A1)
	
	
	move.l	long,d0
	MOVE.L	$42E.W,A1
	move.l	a1,a2
	add.l	d0,a0
	sub.l	d0,a2
.reco14	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	subq.l	#8,d0
	bpl.s	.reco14
	move.l	a2,a1
	move.l	a2,a6
	move.l	a2,a0
	
	lea	entete,a1
	moveQ	#69,d0
.reco5	move.b	(a0)+,(a1)+
	dbf	d0,.reco5
	lea	NAMEMUS,a1
	moveQ	#19,d0
.xs	move.b	(a0)+,(a1)+
	dbf	d0,.xs

	move.b	snbzic,maxzic
	lea	MUSIQUE,a0
	moveq	#0,d0
	move.w	slenzic,d0
	move.l	a6,a1
	add.l	saddzic,a1
.reco6	move.b	(a1)+,(a0)+
	dbf	d0,.reco6

	move.l	addseq,a0
	move.w	slenseq,d0
	move.l	a6,a1
	add.l	saddseq,a1
.reco7	move.b	(a1)+,(a0)+
	dbf	d0,.reco7
	
	move.b	stotalsample,totalsample
	lea	SAMPLE,a0
	moveq	#0,d0
	move.w	slentablespl,d0
	cmp.w	#0,d0
	beq.s	yy1
	move.l	a6,a1
	add.l	saddtablespl,a1
.reco9	move.b	(a1)+,(a0)+
	dbf	d0,.reco9

yy1	move.b	stotalyam,totalyam
	lea	YAM,a0
	moveq	#0,d0
	move.w	slentableyam,d0
	cmp.w	#0,d0
	beq.s	yy2
	move.l	a6,a1
	add.l	saddtableyam,a1
.reco10	move.b	(a1)+,(a0)+
	dbf	d0,.reco10

yy2	lea	SAMPLE,a0		* reloge la table des samples
	moveq	#0,d1
	move.b	smaxpatt,d1
	addq.b	#1,d1
	mulu	#11*4*64,d1
	add.l	debpatt,d1
	move.l	#255,d0
.reco12	cmp.l	#0,26(a0)
	beq.s	.reco13
	add.l	d1,22(a0)
	add.l	d1,30(a0)
	add.l	d1,36(a0)
.reco13	add.w	#40,a0
	dbf	d0,.reco12
	move.l	d1,addspl
	move.l	slensamples,lensamples
	move.l	slenyams,lenyams
	
	BSR	coppatt
	
	;move.b	svoies,voies
	move.b	#11,voies
	move.b	sdigvoices,digvoices
	move.b	syamvoices,yamvoices
	lea	VOICE0,a0
	move.b	ssv0,25(a0)
	lea	VOICE1,a0
	move.b	ssv1,25(a0)
	lea	VOICE2,a0
	move.b	ssv2,25(a0)
	lea	VOICE3,a0
	move.b	ssv3,25(a0)
	lea	VOICE4,a0
	move.b	ssv4,25(a0)
	lea	VOICE5,a0
	move.b	ssv5,25(a0)
	lea	VOICE6,a0
	move.b	ssv6,25(a0)
	lea	VOICE7,a0
	move.b	ssv7,25(a0)
	lea	VOICE8,a0
	move.b	ssv8,25(a0)
	lea	VOICE9,a0
	move.b	ssv9,25(a0)
	lea	VOICE10,a0
	move.b	ssv10,25(a0)
	
	MOVEQ	#0,D0
	MOVE.L	addseq,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MULU	#64*4*11,D0
	ADD.L	D0,A2
	MOVE.L	A2,addpatt
	MOVE.B	#0,inpatt
	BSR.S	SETT
	BSR	AFFPATTERN2
	RTS
***************************************************************************	
SETT	MOVEQ	#0,D0
	LEA	VOICE0,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+329*160+45,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE1,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+329*160+85,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE2,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+329*160+125,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE3,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+401*160+45,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE4,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+401*160+85,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE5,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+401*160+125,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE6,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+474*160+45,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR	STYL
	LEA	VOICE7,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+474*160+85,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR.S	STYL
	LEA	VOICE8,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+474*160+125,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR.S	STYL
	LEA	VOICE9,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+546*160+45,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR.S	STYL
	LEA	VOICE10,A0
	MOVE.B	25(A0),D0
	MOVE.L  #screen+546*160+85,where
	MOVE.W	#1,compt2
	BSR	IMPLIQ
	BSR.S	STYL
	BSR	TESTVOI
	BSR	SILENT
	BSR	SET_DAC
	BSR.S	ADVICE
	RTS
STYL	MULU	#2,D0
	LEA	VTABLE(PC),A0
	ADD.W	D0,A0
	MOVE.L	A0,A3
	MOVE.L	where,a2
	MOVEQ	#2,D1
	MOVE.W	compt2,D2
	BSR	PRINT
	MOVE.L	A2,where
	ADDQ.L	#2,where
	MOVE.W	D2,compt2
	BSR	PRINT
	MOVE.L	A2,where
	SUBQ.L	#2,where
	MOVE.W	D2,compt2
	BSR	PRINT
	MOVE.L	A2,where
	SUBQ.L	#4,where
	MOVE.W	D2,compt2
	BSR	PRINT
	RTS
ADVICE	LEA	MUSIQUE,A0
	MOVEQ	#0,D0
	MOVE.B	D0,curnum
	MOVE.B	D0,curseq
	MOVE.B	(A0),curlen
	MOVE.B	1(A0),curlop
	MOVE.L	addseq,A0
	MOVE.B	(A0),curpatt
	
	move.b	curpatt,D0
	move.l  #screen+32000+25*160+63,where
	bsr.S	pouet
	move.b	curseq,d0
	move.l  #screen+32000+17*160+63,where
	bsr.S	pouet
	move.b	curnum,d0
	move.l  #screen+32000+9*160+63,where
	bsr.S	pouet
	move.b	curlen,d0
	move.l  #screen+32000+33*160+63,where
	bsr.S	pouet
	move.b	curlop,d0
	move.l  #screen+32000+41*160+63,where
	bsr.S	pouet
	rts
pouet	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	rts
***************************************************************************	
coppatt
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	smaxpatt,d1
	move.b	d1,maxpatt
	addq	#1,d1
	move.l	debpatt,a0
	move.l	a6,a1
	add.l	saddpatt,a1
	bsr.S	tut
	move.b	sdigvoices,d2
	add.b	syamvoices,d2
	mulu	#64*4,d2
	addq	#1,d1
	mulu	d1,d2
	add.l	d2,a6
	move.l	addspl,a5
	move.l	slensamples,d0
	add.l	slenyams,d0
.reco15	move.b	(a6)+,(a5)+
	subq.l	#1,d0
	bne.s	.reco15
	move.l	a5,endaddr
	moveq	#0,d1
	move.l	#1023,d0
.reco16	move.l	d1,(a5)+
	dbf	d0,.reco16
	rts
***************************************************************************
*	d1 = nb de patt
*	a0 = saddpatt
*	a1 = debpatt
tut	movem.l	d0-d4/a4,-(a7)
	mulu	#64,d1
	subq	#1,d1
	move.b	sdigvoices,d0
	add.b	syamvoices,d0
	move.l	d0,d3
	mulu	#4,d0			* nb voie
	subq	#1,d0
	moveq	#11,d2
	sub.w	d3,d2
	mulu	#4,d2			* 11 - nb voie
	move.l	d0,d3
	moveq	#0,d4
	
.cuisse	move.l	a0,a4
	rept	44
	move.l	d4,(a4)+
	endr
.orteil	move.b	(a1)+,(a0)+
	dbf	d0,.orteil
	add.w	d2,a0
	move.l	d3,d0
	dbf	d1,.cuisse
	movem.l	(a7)+,d0-d4/a4
	rts
*************************************************************************	
NOT_MOD_MCS				* ALORS C'EST UN MODULE OKTALISER
	MOVE.L	endaddr,A1
	CMP.L	#'OKTA',(A1)
	BNE	NOT_OKT_MOD
	BSR	INITMEG
	MOVE.L	long,D0
	MOVE.L	$42E.W,A0
	move.l	a0,a2
	sub.l	d0,a2
	ADD.L	D0,A1
.DEPL	MOVE.L	-(A1),-(A0)
	MOVE.L	-(A1),-(A0)
	SUBQ.L	#8,D0
	BPL.S	.DEPL
	move.l	a2,a0
	MOVE.L	A0,A6
	BSR	ZEROVOICE
	
	MOVE.L	A6,A0
	ADD.W	#32,A0
	LEA	SAMPLE,A1
	MOVEQ	#35,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
.NEXT2	CMP.W	#0,22(A0)
	BEQ.S	.NXT
	MOVEQ	#0,D1
	MOVE.L	(A0),(A1)
	MOVE.L	4(A0),4(A1)
	MOVE.L	8(A0),8(A1)
	MOVE.L	12(A0),12(A1)
	MOVE.L	16(A0),16(A1)
	MOVE.W	22(A0),D1
	BCLR	#0,D1
	MOVE.L	D2,22(A1)		* DEB
	MOVE.L	D1,26(A1)		* LEN
	MOVE.L	D2,30(A1)
	ADD.L	D1,30(A1)		* END
	MOVE.L	22(A1),36(A1)		* LOOP DEB
	MOVE.B	29(A0),34(A1)		* VOLUME
	ADD.L	D1,D2
	ADD.L	#FINSAMPLE,D2
.NXT	LEA	32(A0),A0
	LEA	40(A1),A1
	DBF	D0,.NEXT2
	*MOVE.L	D2,lenspl
	*MOVE.L	#0,lenyam
	
	MOVE.L	A6,A0
	ADD.L	#32+36*32,A0
	MOVE.W	#0,u				* SPEED
	MOVE.W	8(A0),v
	MOVE.B	29(A0),MUSIQUE			* LEN  ZIC
	MOVE.B	#0,MUSIQUE+1			* LOOP ZIC
	MOVE.L	addseq,A1
	LEA	38(A0),A0			* SEQ PATT
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
.DROM	MOVE.B	(A0),D1
	MOVE.B	(A0)+,(A1)+
	CMP.B	D2,D1
	BLE.S	.DREOM
	MOVE.B	D1,D2
.DREOM	DBF	D0,.DROM
	MOVE.B	D2,maxpatt
	MULU	#11*4*64,D2
	MOVE.L	debpatt,A1
	ADD.L	D2,A1
	MOVE.L	A1,addspl
	
	MOVE.L	A1,D1
	MOVEQ	#35,D0
	LEA	SAMPLE,A2
.SXC3	CMP.L	#0,26(A2)
	BEQ.S	.SXC4
	ADD.L	D1,22(A2)
	ADD.L	D1,30(A2)
	ADD.L	D1,36(A2)
.SXC4	ADD.W	#40,A2
	DBF	D0,.SXC3
	
	MOVE.L	A6,A0
.CW2	CMP.L	#'PBOD',(A0)+
	BNE.S	.CW2
	MOVE.L	(A0)+,D1
	MOVE.W	(A0)+,D1
	move.l	debpatt,a1
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5
	LEA	TABLE_EFF_OKT,A2
	move.b	#8-1,d0			* nb de voies utilisees
	move.b	maxpatt,d1
	moveq	#3*4,d2			* nb de voies restantes
	move.l	d0,d3
	moveq	#63,d4
	
.ecuiss	move.l	a1,a4
	rept	11
	move.l	d5,(a4)+
	endr
.eortei	moveq	#0,d5
	moveq	#0,d6
	move.b	(a0)+,(a1)+		* note
	move.b	(a0)+,(a1)+		* instrument
	MOVEQ	#0,D5
	MOVE.B	(A0)+,D5		* commande
	MOVE.B	(A2,D5.W),(A1)+
	MOVE.B	(A0)+,(A1)+		* parametre
	dbf	d0,.eortei
	add.w	d2,a1
	move.l	d3,d0
	dbf	d4,.ecuiss
	add.w	#10,a0
	moveq	#63,d4
	dbf	d1,.ecuiss
	
.CW1	CMP.L	#'SBOD',(A6)+
	BNE.S	.CW1
	MOVE.L	(A6)+,D1
	
	MOVE.L	addspl,A1
	LEA	SAMPLE,A2
	MOVEQ	#35,D0
.SXC	MOVE.L	26(A2),D2
	CMP.L	#0,D2
	BEQ.S	.NOLPS
.SXC2	MOVE.B	(A6)+,(A1)+
	SUBQ.L	#1,D2
	BNE.S	.SXC2
	MOVE.L	#FINSAMPLE-1,D2			* 1023
.SXX	MOVE.B	#0,(A1)+
	DBF	D2,.SXX
	LEA	8(A6),A6
.NOLPS	LEA	40(A2),A2
	DBF	D0,.SXC
	
	MOVEQ	#35,D5
	LEA	SAMPLE,A2
.LI4	CMP.L	#0,26(A2)
	BEQ.S	.LI5
	MOVE.L	A2,heretoconvert
	BSR	D_4
.LI5	ADD.W	#40,A2
	DBF	D5,.LI4

	MOVE.B	#0,inpatt
.LI6	CMP.W	#0,okp
	BNE.S	.LI6
	LEA	VOICE0,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE1,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE2,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE3,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE4,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE5,A0
	MOVE.W	#4,24(A0)
	
	IFNE	FRQ_25	
	MOVE.B	#6,digvoices
	ENDC
	
	IFNE	FRQ_12	
	LEA	VOICE6,A0
	MOVE.W	#4,24(A0)
	LEA	VOICE7,A0
	MOVE.W	#4,24(A0)
	MOVE.B	#8,digvoices
	ENDC
	
	MOVE.B	#0,yamvoices
	MOVE.B	#0,inpatt
	MOVEQ	#0,D0
	MOVE.L	addseq,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MULU	#64*4*11,D0
	ADD.L	D0,A2
	MOVE.L	A2,addpatt
	BSR	SETT
	BSR	AFFPATTERN2
	RTS
	
TABLE_EFF_OKT		DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,$B,0,0,$F,0
			DC.B	0,0,0,0,0,0
***********************************************************************	
NOT_OKT_MOD				* ALORS C'EST UN MODULE AMIGA
	BSR	INITMEG
	MOVE.L	endaddr,A1
	MOVE.L	#$43C-1,D0
	LEA	BUFMOD,A0
.DEPL2	MOVE.B	(A1)+,(A0)+
	DBF	D0,.DEPL2
	
	MOVE.L	endaddr,A1
	MOVE.L	long,D0
	MOVE.L	$42E.W,A0
	sub.L	#50*1024,a0
	move.l	a0,a2
	sub.l	d0,a2
	BCLR	#0,D0
	ADD.L	D0,A1
.DEPL3	MOVE.L	-(A1),-(A0)
	MOVE.L	-(A1),-(A0)
	SUBQ.L	#8,D0
	BPL.S	.DEPL3
	move.l	a2,a0
	MOVE.L	A0,A6
	BSR	ZEROVOICE
	
	CMP.L	#'M.K.',$438(A0)
	BEQ.S	.DINS31
	MOVE.W	#15,MAX_INS
	MOVE.W	#$1D8,W_MOD
	MOVE.W	#$258,A_MOD
	BRA.S	.DINS16
.DINS31	MOVE.W	#31,MAX_INS
	MOVE.W	#$3B8,W_MOD
	MOVE.W	#$43C,A_MOD
.DINS16	MOVE.W	#1,IN_MOD
	ADD.W	W_MOD,A0
	MOVE.B	-2(A0),MUSIQUE			* LEN  ZIC
	MOVE.B	#0,MUSIQUE+1			* LOOP ZIC
	MOVE.L	addseq,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	#$7F,D0				* ON S'OCCUPE DE LA SEQUENCE
	SUBQ.B	#1,D0
.DRCOM	MOVE.B	(A0),D1
	MOVE.B	(A0)+,(A1)+
	CMP.B	D2,D1
	BLE.S	.DRECOM
	MOVE.B	D1,D2
.DRECOM	DBF	D0,.DRCOM
	MOVE.B	D2,maxpatt
	MOVE.B	#1,maxzic
	ADDQ.L	#1,D2
	MOVE.L	D2,D1
	MULU	#11*4*64,D1
	MOVE.L	debpatt,A0
	MOVE.L	A0,addpatt
	
	MOVE.L	addseq,A2
	MOVEQ	#0,D3
	MOVE.B	(A2),D3
	MULU	#11*64*4,D3
	ADD.L	D3,addpatt
	
	ADD.L	D1,A0
	MOVE.L	A0,addspl
	MOVE.L	A0,endaddr
	MULU	#1024,D2			
	MOVEQ	#0,D0
	ADD.W	A_MOD,D0
	ADD.L	D2,D0
	MOVE.L	D0,FIRST_SPL
	
	MOVE.L	A6,A2				* ON S'OCCUPE DES DATA SAMPLE
	ADD.W	#20,A2
	LEA	SAMPLE,A1
	MOVE.W	MAX_INS,D3
	SUBQ.W	#1,D3
DPETIT	MOVEQ	#0,D0
	MOVE.W	22(A2),D0
	ADD.L	D0,D0
	CMP.L	#0,D0
	BEQ	DBBOUCL
	
	ADDQ.B	#1,totalsample
	MOVE.L	endaddr,22(a1)		* START
	MOVEQ	#0,D2
	MOVE.W	26(A2),D2		* FIRST LOOP POINT
	ADD.L	D2,D2			* ON DOUBLE
	ADD.L	22(A1),D2
	MOVE.L	D2,36(A1)
	CMP.W	#1,28(a2)
	BEQ.S	.dnolop1
	MOVE.B	#3,35(A1)
	MOVEQ	#0,d0			* Ici je retablie la fin
	MOVE.W	28(a2),d0		* du sample en fonction
	ADD.L	d0,d0			* de son debut,de son point
	ADD.L	36(a1),d0		* de loop et de la longueur
	MOVE.L	22(a1),d2		* du loop
	SUB.L	d2,d0
	BRA.S	.dnolop
.dnolop1	MOVE.b	#1,35(A1)
	
.dnolop	MOVE.L	D0,26(A1)
	ADD.L	D0,endaddr
	MOVE.L	endaddr,30(A1)
	ADD.L	#FINSAMPLE,D0
	ADD.L	#FINSAMPLE,endaddr
	ADD.L	D0,lensamples
	MOVE.B	#$81,21(a1)		* Set Default Frequency
	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)
	MOVE.B	24(A2),20(A1)		* FINE TUNE
	MOVE.B	25(A2),34(A1)		* VOLUME
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#13,d0
	LEA	NAMESAMPLE,a3
	ADD.L	d0,a3
	ADDQ.L	#1,a3
	MOVE.B	(A2),(A3)
	MOVE.B	1(A2),1(A3)
	MOVE.B	2(A2),2(A3)
	MOVE.B	3(A2),3(A3)
	MOVE.B	4(A2),4(A3)
	MOVE.B	5(A2),5(A3)
	MOVE.B	6(A2),6(A3)
	MOVE.B	7(A2),7(A3)
	MOVE.L	a1,a0
DBBOUCL	LEA	30(A2),A2
	LEA	40(A1),A1
	DBF	D3,DPETIT
						* ON S'OCCUPE DES PATTERN
	move.l	a6,a0
	move.l	debpatt,a1
	add.w	A_MOD,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5
	moveq	#0,d6
	move.b	maxpatt,d1
	addq.b	#1,d1
	mulu	#64,d1
	subq	#1,d1
	move.b	#4-1,d0			* nb de voies utilisees
	moveq	#7*4,d2			* nb de voies restantes
	move.l	d0,d3
	
.dcuisse
	moveq	#0,d4
	move.l	a1,a4
	rept	44
	move.l	d4,(a4)+
	endr
.dorteil
	move.b	(a0)+,d5		* note poids fort
	and.b	#$f,d5
	lsl.w	#8,d5
	move.b	(a0)+,d5		* note poids faible
	lea	DIGINOTE1,a2
	moveq	#0,d6
	moveq	#53,d4
.fgb	addq.b	#1,d6
	cmp.w	(a2)+,d5
	beq.s	.fga
	dbf	d4,.fgb
	moveq	#0,d6
.fga	move.b	d6,(a1)+
	
	move.b	-2(a0),d5
	and.b	#$f0,d5
	move.b	(a0)+,d6		* instrument + commande
	move.b	d6,d7
	and.b	#$f0,d6
	and.b	#$0f,d7
	lsr.w	#4,d6
	add.b	d5,d6
	move.b	d6,(a1)+		* instru
	cmp.b	#$E,d7
	beq.s	.e_com
	move.b	d7,(a1)+		* comm
	move.b	(a0)+,(a1)+		* parametre de commande
.ui	dbf	d0,.dorteil
	add.w	d2,a1
	move.l	d3,d0
	dbf	d1,.dcuisse
	bra.s	.sspl
	
.e_com	move.b	(a0)+,d6
	move.b	d6,d7
	lsr.b	#4,d6
	add.b	#$10,d6
	and.b	#$f,d7
	move.b	d6,(a1)+
	move.b	d7,(a1)+
	bra.s	.ui
					* ON S'OCCUPE DES SAMPLE
.sspl	MOVE.L	addspl,A0
	LEA	SAMPLE,A1
	LEA	BUFMOD+20,A2
	ADD.L	FIRST_SPL,A6
	MOVE.L	A6,A5
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	MAX_INS,D0
	SUBQ	#1,D0
.TROU	MOVE.L	26(A1),D1
	BEQ.S	.NO_LEN
.PAU	MOVE.B	(A6)+,(A0)+
	SUBQ.L	#1,D1
	BNE.S	.PAU
	CMP.B	#3,35(A1)
	BNE.S	.PALOP
	BSR	BCLFINSPL
	BRA.S	.LOP
.PALOP	BSR	ZEROFINSPL
.LOP	ADD.W	#FINSAMPLE,A0
.NO_LEN	MOVE.W	22(A2),D2
	ADD.L	D2,D2
	ADD.L	D2,A5
	MOVE.L	A5,A6
	LEA	30(A2),A2
	LEA	40(A1),A1
	DBF	D0,.TROU
	
	MOVEQ	#31,D5
	LEA	SAMPLE,A2
.LI	TST.L	26(A2)
	BEQ.S	.LT
.LI3	MOVE.L	A2,heretoconvert
	BSR	D_2
.LT	ADD.W	#40,A2
	DBF	D5,.LI

	LEA	VOICE0,A0
	MOVE.B	#5,25(A0)
	LEA	VOICE1,A0
	MOVE.B	#5,25(A0)
	LEA	VOICE2,A0
	MOVE.B	#5,25(A0)
	LEA	VOICE3,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#4,digvoices
	MOVE.B	#0,yamvoices
	MOVE.B	#0,inpatt
	MOVEQ	#0,D0
	MOVE.L	addseq,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MULU	#64*4*11,D0
	ADD.L	D0,A2
	MOVE.L	A2,addpatt
	BSR	SETT
	BSR	AFFPATTERN2
	RTS
**********************************************************************
ZEROVOICE
	LEA	VOICE0,A5
	BSR.S	.CLEAR2
	LEA	VOICE1,A5
	BSR.S	.CLEAR2
	LEA	VOICE2,A5
	BSR.S	.CLEAR2
	LEA	VOICE3,A5
	BSR.S	.CLEAR2
	LEA	VOICE4,A5
	BSR.S	.CLEAR2
	LEA	VOICE5,A5
	BSR.S	.CLEAR2
	LEA	VOICE6,A5
	BSR.S	.CLEAR2
	LEA	VOICE7,A5
	BSR.S	.CLEAR2
	LEA	VOICE8,A5
	BSR.S	.CLEAR2
	LEA	VOICE9,A5
	BSR.S	.CLEAR2
	LEA	VOICE10,A5
	BSR.S	.CLEAR2
	LEA	MUSDEB,A5
	MOVE.L	#(4*508*(DAC_FRQ+1))/4-1,D2
	MOVEQ	#0,D1
.CC1	MOVE.L	D1,(A5)+
	DBF	D2,.CC1
	RTS
.CLEAR2
	move.l	#0,(A5)
	move.l	#0,4(A5)
	move.l	#0,8(A5)
	move.l	#0,12(A5)
	move.l	#0,16(A5)
	move.l	#0,20(A5)
	move.l	#0,24(A5)
	move.l	#0,28(A5)
	move.l	#0,32(A5)
	move.l	#0,36(A5)
	move.b	#$40,21(A5)
	move.b	#$40,37(A5)
	rts
**********************************************************************
l_spl_mod
	CMP.W	#1,IN_MOD
	BEQ.S	.L_
	move.w	#-1,IN_MOD
.L_	bra	LOADER
L_SPL_MOD
	CMP.W	#1,IN_MOD
	BEQ	LOAD_SPL_MOD
	MOVE.W	#2,-(SP)
	PEA	AFFICHAGE
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	MOVE.W	D0,CANAL_MOD
	MOVE.L	#BUFMOD,-(a7)
	PEA	$43C.W
	MOVE.W	CANAL_MOD,-(SP)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	ADDA.L	#$C,SP
	MOVE.W	CANAL_MOD,-(SP)
	MOVE.W	#$3E,-(SP)
	TRAP	#1
 	ADDQ.L	#4,SP
	LEA	BUFMOD,A0
	CMP.L	#'M.K.',$438(A0)
	BEQ.S	.INS31
	MOVE.W	#15,MAX_INS
	MOVE.W	#$1D8,W_MOD
	MOVE.W	#$258,A_MOD
	BRA.S	.INS16
.INS31	MOVE.W	#31,MAX_INS
	MOVE.W	#$3B8,W_MOD
	MOVE.W	#$43C,A_MOD
.INS16	MOVE.W	#1,IN_MOD
	BSR	AFF_FS
	LEA	BUFMOD,A0
	ADD.W	W_MOD,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	#$7F,D0	
	SUBQ.B	#1,D0
.RCOM	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BLE.S	.RECOM
	MOVE.B	D1,D2
.RECOM	DBF	D0,.RCOM
	ADDQ.L	#1,D2
	MULU	#FINSAMPLE,D2
	MOVEQ	#0,D0
	ADD.W	A_MOD,D0
	ADD.L	D2,D0
	MOVE.L	D0,FIRST_SPL
	move.w	#0,okp
	RTS

LOAD_SPL_MOD
	MOVE.W	#2,-(SP)
	PEA	AFFICHAGE
	MOVE.W	#$3D,-(SP)
	TRAP	#1
	ADDQ.L	#8,SP
	MOVE.W	D0,CANAL_MOD
	MOVE.W	#1,-(A7)	
	MOVE.W	CANAL_MOD,-(SP)
	MOVE.L	FIRST_SPL,-(A7)
	MOVE.W	#$42,-(A7)
	TRAP	#1
	ADD.L	#10,A7

	LEA	BUFMOD+20,A2
	MOVEQ	#0,D3
	MOVE.W	MAX_INS,D3
	SUBQ.W	#1,D3

PETIT	MOVEQ	#0,D2
	MOVE.W	22(A2),D2
	ADD.L	D2,D2	
	CMP.L	#0,D2
	BEQ	BBOUCL
	CMP.B	#1,24(A2)
	BNE	GRAND
	;add.w	#$111,$ff8240
	BCLR.B	#0,24(A2)
	MOVE.L	endaddr,-(a7)
	MOVE.L	D2,-(A7)
	MOVE.W	CANAL_MOD,-(A7)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	ADDA.L	#$C,SP
	BSR	SEARCHFREESPL
	addq.b	#1,totalsample
	move.l	endaddr,22(a1)		* START

	MOVEQ	#0,D2
	MOVE.W	26(A2),D2		* FIRST LOOP POINT
	ADD.L	D2,D2			* ON DOUBLE
	ADD.L	22(A1),D2
	MOVE.L	D2,36(A1)
	move.b	25(a2),34(a1)

	cmp.w	#1,28(a2)
	beq.s	.nolop1
	move.b	#3,35(a1)
	moveq	#0,d0			* Ici je retablie la fin
	move.w	28(a2),d0		* du sample en fonction
	add.l	d0,d0			* de son debut,de son point
	add.l	36(a1),d0		* de loop et de la longueur
	move.l	22(a1),d2		* du loop
	sub.l	d2,d0
	add.l	d0,endaddr
	move.l	endaddr,30(a1)		* END
	bsr	BCLFINSPL
	BRA.S	.nolop
.nolop1	add.l	d0,endaddr
	move.l	endaddr,30(a1)
	bsr	ZEROFINSPL
.nolop	MOVE.L	D0,26(A1)

	add.l	#FINSAMPLE,d0
	add.l	d0,lensamples
	add.l	#FINSAMPLE,endaddr
	move.l	d0,long
	move.b	#$81,21(a1)		* Set Default Frequency

	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#13,d0
	lea	NAMESAMPLE,a3
	add.l	d0,a3
	addq.l	#1,a3
	MOVE.B	(A2),(A3)
	MOVE.B	1(A2),1(A3)
	MOVE.B	2(A2),2(A3)
	MOVE.B	3(A2),3(A3)
	MOVE.B	4(A2),4(A3)
	MOVE.B	5(A2),5(A3)
	MOVE.B	6(A2),6(A3)
	MOVE.B	7(A2),7(A3)
	move.l	a1,a0
        bsr	SUM
	bsr	FRE
	bra.s	BBOUCL

GRAND	MOVE.W	#1,-(A7)
	MOVE.W	CANAL_MOD,-(A7)
	MOVE.L	D2,-(A7)
	MOVE.W	#$42,-(A7)
	TRAP 	#1
	ADD.L	#10,A7
BBOUCL	LEA	30(A2),A2
	DBF	D3,PETIT
	BSR	AFF_FS
	MOVE.w	#0,$ffff8240.w
	move.w	#0,okp
	RTS



CANAL_MOD	DC.W	0	* # CANAL DU FICHIER
MAX_INS	DC.W	0		* NB MAX D'INSTRUMENTS
IN_MOD	DC.W	0		* SI = 1 ALORS ON EST DANS UN MODULE
A_MOD	DC.W	0		* POINTEUR DANS MOD (ADD_PARTITION)
P_MOD	DC.W	0		* POINTEUR FILESELECT
W_MOD	DC.W	0		* POINTEUR DANS MOD (ADD_SEQUENCE)
FIRST_SPL	DC.L	0	* ADRESSE PREMIER SPL DANS MOD (RELATIF)
BUFMOD	DS.L	$43C
kind	dc.l	lkindata
lkindata	
	dc.l	l_avr,l_ptn,l_mus,l_sng,l_spl,l_bnk,l_mod,l_sam,l_spe,l_yam
skindata
	dc.l	s_avr,s_ptn,s_mus,s_sng,s_spl,s_bnk,s_mod,s_sam,s_spe,s_yam

s_spl	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	move.l	a0,a1
	move.l	a0,a2
	bsr	SPLTOSPE
	move.l	22(a2),a1
	move.l	26(a2),d1
	lea	AFFICHAGE,a0
	bsr	SAVE
	move.l	a2,a1
	bsr	SPLTOSPE
	rts
s_spe	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	move.l	a0,hihi
	move.l	22(a0),a1		*
	sub.l	#44,a1			*
	move.l	a1,haha			*Recopie de l'adresse du sample -40
	lea	buffer,a2		*dans un buffer
	move.w	#10,d0			*
.recop1	move.l	(a1)+,(a2)+		*
	dbf	d0,.recop1		*

	move.l	haha,a1			*
	move.l	#'SPE!',(a1)+		*
	move.w	#9,d0			*Recopie des donnes sur le sample
.recop2	move.l	(a0)+,(a1)+		*40 octets avant le sample
	dbf	d0,.recop2		*
	move.l	hihi,a0
	move.l	haha,a1
	addq.w	#4,a1
	move.l	22(a0),d0		*Servira pour le relogeage
	sub.l	d0,22(a1)		*lors d'un prochain load
	sub.l	d0,30(a1)		*de ce sample
	sub.l	d0,36(a1)		*A la limite on peut mettre 0 (sauf a celui la)
	move.l	26(a1),d1
	add.l	#44,d1
	move.l	haha,a1
	lea	AFFICHAGE,a0
	bsr	SAVE
	lea	buffer,a0		*
	move.l	haha,a1			*Replace les donnees du buffer
	move.w	#10,d0			*a 40 octets du sample
.recop3	move.l	(a0)+,(a1)+		*sauvgarder
	dbf	d0,.recop3		*
	rts
hihi	dc.l	0
haha	dc.l	0
buffer	ds.b	44
ecran	dc.l	0
rezo	dc.w	0

s_bnk	lea	SAMPLE,a0		* deloge data
	move.l	#s1,d0
	move.l  #255,d1

.s_bnk1	cmp.l	#0,26(a0)
	beq.s	.s_bnk2
	sub.l	d0,22(a0)
	sub.l	d0,30(a0)
	sub.l	d0,36(a0)
	move.l	a0,d3			* Adresse dernier SAMPLE
.s_bnk2	add.l	#40,a0
	dbf	d1,.s_bnk1
	move.l	#SAMPLE,d4
	sub.l	d4,d3			* Len SAMPLE
	add.l	#40,d3

	clr.w 	-(sp)			* Sauve data SAMPLE
 	pea	AFFICHAGE
 	move.w #$3c,-(sp)
 	trap 	#1
 	addq.l 	#8,sp
 	move.w d0,d2

	lea	SAMPLE-22,a0
	move.l	#'BNK!',(a0)+
	move.b	totalsample,(a0)+
	move.b	totalyam,(a0)+
	move.l	d3,(a0)+		* Len DATA SAMPLE
	move.l	#0,(a0)+		* Len DATA YAMAHA
	move.l	lensamples,(a0)+
	move.l	lenyams,(a0)+

	add.l	#22,d3
 	pea	SAMPLE-22
 	move.l d3,-(sp)
 	move.w d2,-(sp)
 	move.w #$40,-(sp)
 	trap 	#1
 	add.l 	#12,sp

	lea	SAMPLE,a0		* reloge data
	move.l	#s1,d0
	moveq	#0,d1
	move.l	#255,d3
.s_bnk3	cmp.l	#0,26(a0)
	beq.s	.s_bnk4
	add.l	d0,22(a0)
	add.l	d0,30(a0)
	add.l	d0,36(a0)
.s_bnk4	add.l	#40,a0
	dbf	d3,.s_bnk3

	move.l	lensamples,d1
	add.l	lenyams,d1
 	pea	s1		* sauve sample
 	move.l d1,-(sp)
 	move.w d2,-(sp)
 	move.w #$40,-(sp)
 	trap 	#1
 	add.l 	#12,sp

 	move.w d2,-(sp)			* ferme fichier
 	move.w #$3e,-(sp)
 	trap 	#1
 	addq.l #4,sp
	bsr	SAVENAME
	rts

s_ptn
	moveq	#0,d0
	moveq	#0,d1
	move.b	curpatt,d0
	move.l	addpatt,a1
	move.b	cvoies,d1
	mulu	d1,d0
	mulu	#64,d0			
	mulu	#64,d1			* longueur d'une ptn
	;add.l	d0,a1
	move.l	-(a1),-(a7)
	move.w	-(a1),-(a7)
	move.l	#'PTN!',(a1)
	move.b	yamvoices,4(a1)	
	move.b	digvoices,5(a1)	
	lea	AFFICHAGE,a0
	bsr	SAVE
	move.w	(a7)+,(a1)+
	move.l	(a7)+,(a1)+
	rts

s_mod	moveq	#0,d0
	move.l	#'MCS!',entete

	lea	VOICE0,a0
	move.b	25(a0),ssv0
	lea	VOICE1,a0
	move.b	25(a0),ssv1
	lea	VOICE2,a0
	move.b	25(a0),ssv2
	lea	VOICE3,a0
	move.b	25(a0),ssv3
	lea	VOICE4,a0
	move.b	25(a0),ssv4
	lea	VOICE5,a0
	move.b	25(a0),ssv5
	lea	VOICE6,a0
	move.b	25(a0),ssv6
	lea	VOICE7,a0
	move.b	25(a0),ssv7
	lea	VOICE8,a0
	move.b	25(a0),ssv8
	lea	VOICE9,a0
	move.b	25(a0),ssv9
	lea	VOICE10,a0
	move.b	25(a0),ssv10

	lea	SAMPLE,a0
	move.l	a0,a1
	cmp.b	#0,totalsample
	beq.s	.sm7
	add.l	#254*40,a0
.sm2	cmp.l	#0,26(a0)
	bne.s	.sm3
	sub.l	#40,a0
	bra.s	.sm2
.sm3	add.l	#40,a0
.sm7	sub.l	a1,a0
	move.w	a0,slentablespl
	move.l	#90,saddtablespl

	lea	YAMAHA,a0
	move.l	a0,a1
	cmp.b	#0,totalyam
	beq.s	.sm6
	add.l	#254*40,a0
.sm4	cmp.l	#0,26(a0)
	bne.s	.sm5
	sub.l	#40,d0
	bra.s	.sm4
.sm5	add.l	#40,a0
.sm6	sub.l	a1,a0
	move.w	a0,slentableyam
	move.l	saddtablespl,d0
	add.w	slentablespl,d0
	move.l	d0,saddtableyam

	move.b	yamvoices,syamvoices
	move.b	digvoices,sdigvoices
	move.b	yamvoices,d0
	add.b	digvoices,d0
	move.b	d0,svoies
	move.b	#0,sarrang		*
	moveq	#0,d0
	move.b	maxzic,d0
	move.w	d0,d1
	move.b	d0,snbzic
	mulu	#2,d0
	move.w	d0,slenzic
	move.w	slentableyam,d0
	add.l	saddtableyam,d0
	move.l	d0,saddzic		*
	mulu	#256,d1
	move.w	d1,slenseq
	moveq	#0,d0
	move.w	slenzic,d0
	add.l	saddzic,d0
	move.l	d0,saddseq
	moveq	#0,d0
	subq	#1,d1
	
	move.l	addseq,a0		* ne sauve que les patterns
.find	cmp.b	(a0),d0			* utilisees
	bge.s	.find2
	move.b	(a0),d0
.find2	addq.w	#1,a0
	dbf	d1,.find
	move.b	d0,smaxpatt
	
	move.b	digvoices,d0
	add.b	yamvoices,d0
	move.l	d0,d1
	mulu	#4,d0
	move.b	d0,scvoies
	mulu	#4*64,d1
	move.w	d1,sonepatt
	moveq	#0,d0
	move.b	smaxpatt,d0
	addq.b	#1,d0
	mulu	d1,d0
	move.l	d0,slenpatt
	moveq	#0,d0
	move.w	slenseq,d0
	add.l	saddseq,d0
	move.l	d0,saddpatt
	move.b	totalsample,stotalsample
	moveq	#0,d0
	move.l	slenpatt,d0
	add.l	saddpatt,d0
	move.l	d0,saddspl
	move.l	lensamples,slensamples
	move.l	lenyams,slenyams
	
	lea	SAMPLE,a0		* deloge la table des samples
	move.l	addspl,d1
	move.l	#255,d0
.rco12	cmp.l	#0,26(a0)
	beq.s	.rco13
	sub.l	d1,22(a0)
	sub.l	d1,30(a0)
	sub.l	d1,36(a0)
.rco13	add.w	#40,a0
	dbf	d0,.rco12

	LEA	AFFICHAGE,A1
	BSR	FOPEN
	LEA	entete,A1
	MOVEQ	#70,D1
	BSR	FWRITE
	
	LEA	NAMEMUS,A1
	MOVEQ	#20,D1
	BSR	FWRITE

	LEA	SAMPLE,A1
	MOVE.W	slentablespl,D1
	BSR	FWRITE

	LEA	YAMAHA,A1
	MOVE.W	slentableyam,D1
	BSR	FWRITE

	LEA	MUSIQUE,A1	
	MOVE.W	slenzic,D1
	BSR	FWRITE

	MOVE.L	addseq,A1
	MOVE.W	slenseq,D1
	BSR	FWRITE

	BSR.S	save_patt

	MOVE.L	addspl,A1
	MOVE.L	lensamples,D1
	ADD.L	lenyams,D1
	BSR	FWRITE
	BSR	FCLOSE
	
	lea	SAMPLE,a0		* reloge la table des samples
	move.l	addspl,d1
	move.l	#255,d0
.rco1	cmp.l	#0,26(a0)
	beq.s	.rco2
	add.l	d1,22(a0)
	add.l	d1,30(a0)
	add.l	d1,36(a0)
.rco2	add.w	#40,a0
	dbf	d0,.rco1
	RTS

s_avr
s_mus
s_sng
s_sam
s_yam
	rts
save_patt
	moveq	#0,d3
	move.b	smaxpatt,d3
	*subq	#1,d3
	move.l	debpatt,a0
	subq.w	#4,a0
	move.l	a0,pat
	
newpat	moveq	#0,d0
	moveq	#0,d1
	move.l	pat,a0
	lea	emptypatt,a1
	move.l	a1,a5
	move.b	digvoices,d0
	add.b	yamvoices,d0
	move.b	d0,d1
	subq	#1,d0
	mulu	#4,d1			* longueur d'1 ligne
	lea	PILEVOIE,a2
	
pied	move.l	(a2)+,a3
	addq.w	#4,a0
	move.l	a0,a4
	cmp.b	#0,25(a3)
	beq.s	pied
	moveq	#63,d2
.main	move.b	(a4),(a5)
	move.b	1(a4),1(a5)
	move.b	2(a4),2(a5)
	move.b	3(a4),3(a5)
	add.w	#11*4,a4
	add.w	d1,a5
	dbf	d2,.main
	addq.w	#4,a1
	move.l	a1,a5
	dbf	d0,pied
	
	moveq	#0,d1
	move.b	digvoices,d1
	add.b	yamvoices,d1
	mulu	#4*64,d1
	lea	emptypatt,a1
	bsr	FWRITE
	lea	emptypatt,a1
	move.l	#64*11*4-1,d1
	moveq	#0,d0
.beurk	move.b	d0,(a1)+
	dbf	d1,.beurk
	add.l	#64*11*4,pat
	dbf	d3,newpat
	rts
	
emptypatt	ds.b	64*11*4

SAVENAME
	lea	AFFICHAGE,a0
	lea	SNAME,a1
	moveQ	#15,d0
.sn1	move.l	(a0)+,(a1)+
	dbf	d0,.sn1
.sn2	cmp.b	#'\',-(a1)
	bne.s	.sn2
	move.l	a1,a2
.sn3	cmp.b	#'.',(a1)+
	bne.s	.sn3
	move.b	#'N',(a1)+
	move.b	#'A',(a1)+
	move.b	#'M',(a1)+
	lea	NAMEBANK,a0
	addq.l	#1,a2
	rept	12
	move.b	(a2)+,(a0)+
	endr
	
	move.l	#'NAM!',NAME
	
	clr.w 	-(sp)
 	pea	SNAME
 	move.w	#$3c,-(sp)
 	trap 	#1
 	addq.l 	#8,sp
 	move.w	d0,d2
	
	pea	NAME
 	move.l	#4+12+13*256,-(sp)
 	move.w	d2,-(sp)
 	move.w	#$40,-(sp)
 	trap 	#1
 	add.l 	#12,sp

	move.w d2,-(sp)
 	move.w #$3e,-(sp)
 	trap 	#1
 	addq.l #4,sp
	rts

SNAME	ds.b	64		
*************************************************************************
INITMEG	movem.l	d0-d1/a1,-(a7)

	LEA	VOICE0,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE1,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE2,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE3,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE4,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE5,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE6,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE7,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE8,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE9,A5
	MOVE.L	#0,2(A5)
	LEA	VOICE10,A5
	MOVE.L	#0,2(A5)

	lea	SAMPLE,a1
	move.l	#254,d0
.mega1	move.l	#0,(a1)
	move.l	#0,4(a1)
	move.l	#0,8(a1)
	move.l	#0,12(a1)
	move.l	#0,16(a1)
	move.w	#129,20(a1)
	move.l	#0,22(a1)
	move.l	#0,26(a1)
	move.l	#0,30(a1)
	move.w	#1,34(a1)
	move.l	#0,36(a1)
	lea	40(a1),a1
	dbf	d0,.mega1
	
	moveq	#0,d0
	moveq	#0,d1
	move.l	debpatt,a1
	move.b	maxpatt,d0
	addq	#1,d0
	mulu	#64*11,d0		* 64*11*4
	subq.l	#1,d0
.fr	move.l	d1,(a1)+
	dbf	d0,.fr
	
	moveq	#0,d0
	move.l	addseq,a1
	move.b	maxzic,d0
	mulu	#256,d0
	subq.l	#1,d0
.fr1	move.b	d1,(a1)+
	dbf	d0,.fr1
	move.w	#0,u
	move.w	#6,v
	movem.l	(a7)+,d0-d1/a1
	rts
*************************************************************************
*	A1 = ADD FILENAME
FOPEN	CLR.W	-(A7)
 	MOVE.L	A1,-(A7)
 	MOVE.W	#$3C,-(A7)
 	TRAP	#1
 	ADDQ.L 	#8,A7
 	MOVE.W	D0,HANDLE
	RTS
HANDLE	DC.W	0
*************************************************************************
*	A1 = ADD DATA
*	D1 = LEN DATA
FWRITE	MOVE.W	HANDLE,D2
	MOVE.L	A1,-(A7)
 	MOVE.L	D1,-(A7)
 	MOVE.W	d2,-(A7)
 	MOVE.W	#$40,-(A7)
 	TRAP 	#1
 	ADD.L 	#12,A7
	RTS
*************************************************************************
FCLOSE	MOVE.W	HANDLE,D2
	MOVE.W	D2,-(A7)
 	MOVE.W	#$3E,-(A7)
 	TRAP 	#1
 	ADDQ.L	#4,A7
	RTS
*************************************************************************
*	A1 = DATA SAMPLE
ZEROFINSPL
	movem.l	d0-d1/a0,-(a7)
	move.l	30(a1),a0		* on prend la fin
	moveQ	#0,d0
	move.l	#FINSAMPLE-1,d1
.ajou1	move.b	d0,(a0)+
	dbf	d1,.ajou1
	movem.l	(a7)+,d0-d1/a0
	rts
*************************************************************************
*	A1 = DATA SAMPLE
BCLFINSPL
	movem.l	d0/a0-a2,-(a7)
	move.l	30(a1),a0
	move.l	36(a1),a2		* on prend le deb de la bcl
	move.l	#FINSAMPLE-1,d0
.ajou2	move.b	(a2)+,(a0)+
	dbf	d0,.ajou2
	movem.l	(a7)+,d0/a0-a2
	rts
*************************************************************************
FRE	move.l	$42e.w,d0			*FRE(0)
	move.l	endaddr,d1
	sub.l	d1,d0
	move.l	d0,freemem
	lea	freem,a0
	bsr	CONVERT_HEXA_DECIASCII
	move.l	#screen+32000+97*160+127,where
	move.w	#1,compt2
	lea	freem,a0
	moveq	#7,d1
	bsr	PRINT
	RTS
*************************************************************************
*	Recherche d'une place libre pour un sample
*	Retour : A1 = Adresse libre dans SAMPLE
*	       here = Numero de l'emplacement libre
SEARCHFREESPL
	move.b	#0,sampledata
	lea	SAMPLE,a1
.next	cmp.l	#0,26(a1)
	beq.s	.good
	add.l	#40,a1
	addq.b	#1,sampledata
	bra.s	.next
.good	move.b	sampledata,curentnb2
	rts
here	dc.b	0
	even
	
**************************************************************************
*	Saver
*	A0 = Adresse ou se trouve le nom du fichier
*	A1 = Adresse de debut
*	D1 = Longueur
SAVE 	clr.w 	-(sp)
 	move.l	a0,-(a7)
 	move.W #$3c,-(sp)
 	trap 	#1
 	addq.l 	#8,sp

 	move.w d0,d2
 	move.l a1,-(sp)
 	move.l d1,-(sp)
 	move.w d2,-(sp)
 	move.w #$40,-(sp)
 	trap 	#1
 	add.l 	#12,sp

	move.w d2,-(sp)
 	move.w #$3e,-(sp)
 	trap 	#1
 	addq.l #4,sp
	rts
***********************************************************************
*	Loader
*	A0 = Adresse ou se trouve le nom du fichier
*  endaddr = Adresse ou charger le fichier
LOAD
	CMP.B	#'A',DRV
	BEQ.S	.NOT_TIME
	CMP.B	#'B',DRV
	BEQ.S	.NOT_TIME
	MOVE.B	playsong,D0
	ADD.B	playpat,D0
	CMP.B	#0,D0
	BEQ.S	.NOT_TIME
	BRA	.TIME	
.NOT_TIME
	LEA	VOICE0,A1
	MOVE.B	25(A1),ssv0
	LEA	VOICE1,A1
	MOVE.B	25(A1),ssv1
	LEA	VOICE2,A1
	MOVE.B	25(A1),ssv2
	LEA	VOICE3,A1
	MOVE.B	25(A1),ssv3
	LEA	VOICE4,A1
	MOVE.B	25(A1),ssv4
	LEA	VOICE5,A1
	MOVE.B	25(A1),ssv5
	LEA	VOICE6,A1
	MOVE.B	25(A1),ssv6
	LEA	VOICE7,A1
	MOVE.B	25(A1),ssv7
	LEA	VOICE8,A1
	MOVE.B	25(A1),ssv8
	LEA	VOICE9,A1
	MOVE.B	25(A1),ssv9
	LEA	VOICE10,A1
	MOVE.B	25(A1),ssv10
	BSR	ZEROVOICE
	MOVE.W	#1,POL
	
.TIME	MOVE.W	#2,-(SP)		
	MOVE.L 	A0,-(SP)
	MOVE.W	#$3D,-(SP)		
	TRAP	#1		
	ADDQ.L	#8,SP		
	MOVE.W	D0,D7		
	TST.W	D0		
	BMI.S	PASFICHIER
	move.l	endaddr,-(a7)
	PEA	$FFFFF		
	MOVE.W	D0,-(SP)	
	MOVE.W	#$3F,-(SP)	
	TRAP	#1		
	ADDA.L	#$C,SP
	move.l	d0,long
	MOVE.W	D7,-(SP)	
	MOVE.W	#$3E,-(SP)	
	TRAP	#1		
	ADDQ.L	#4,SP
	MOVE.L	long,d0
	MOVE.L	endaddr,a0
	BSR	DEC_23R
	MOVE.L	endaddr,a0
	BSR	DEC_AT35
	move.l	d0,long
	BRA.S	PAS1
PASFICHIER	
	move.w	#1,erreur
PAS1	CMP.W	#1,POL
	BEQ.S	.PAS2
	RTS
.PAS2	LEA	VOICE0,A1
	MOVE.B	ssv0,25(A1)
	LEA	VOICE1,A1
	MOVE.B	ssv1,25(A1)
	LEA	VOICE2,A1
	MOVE.B	ssv2,25(A1)
	LEA	VOICE3,A1
	MOVE.B	ssv3,25(A1)
	LEA	VOICE4,A1
	MOVE.B	ssv4,25(A1)
	LEA	VOICE5,A1
	MOVE.B	ssv5,25(A1)
	LEA	VOICE6,A1
	MOVE.B	ssv6,25(A1)
	LEA	VOICE7,A1
	MOVE.B	ssv7,25(A1)
	LEA	VOICE8,A1
	MOVE.B	ssv8,25(A1)
	LEA	VOICE9,A1
	MOVE.B	ssv9,25(A1)
	LEA	VOICE10,A1
	MOVE.B	ssv10,25(A1)
	MOVE.W	#0,POL
	RTS

DEC_23R		INCBIN	DATA\DEC_23R.BIN
DEC_AT35	INCBIN	DATA\DEC_AT35.BIN
POL		DC.W	0
********************************************************************
*	d0 = # of sample in memory
SEARCHSAMPLE
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
;	cmp.l	#0,26(a0)
;	beq.s	nosample	
	move.l	a0,current
	rts
;nosample
;	move.l	#0,current
;	rts
**********************************************************************
		ds.l	100
pile2		ds.l	100
pile		dc.l	0	*Sauvegarde de la pile
pile1		dc.l	0	*Adresse de la pile superviseur
touche		dc.w	0	*Numero de la derniere touche pressee
curentnb	dc.b	1	*Numero du sample actuel
	even
current         dc.l    0       *Adresse des donnees sur le sample actuel
endaddr         dc.l    s1      *Start adress of free memory
freemem		dc.l	0	*Free memory
fin		dc.w	0	*Quit prg
long		dc.l 	0	*Longueur d'un fichier charge
waiting         dc.w	0       *Wait VBL
lastkey     	dc.b	23	*evite la repetition des touches
sampledata	dc.b	0	*Numero du sample affiche sur l'ecran
erreur		dc.w	0	*Code d'erreur : 1 - File not found
				*		 2 - Too much sample in memory
				*                3 - Not enough memory
				*		 4 - Incorrect filename
				*		 5 - Esc pressed

okp		dc.w	0	*Code		 : 1 - Fileselect en cours
				*		   2 - Input en cours
				*		   3 - Traitement du fichier charge
				*		   4 - Erase sample
				*		   5 - Erase pattern
				*		   6 - Convert SPE - SPL
				*		   7 - Scroll Fileselect
				*		   8 - Tri des fichiers
				*		   9 - Loading
				*		  10 - Saving
				*		  11 - Printing pattern
				*		  12 - Efface contour pattern
				*		  13 - Print pattern while playing
				*		  14 - Up pattern
				*		  15 - Down pattern
				*		  16 - Divise par 2
				*		  17 - Divise par 3
				*		  18 - Divise par 4

totalsample	dc.b	0	*Nombre total de sample in memory
totalyam	dc.b	0	*Nombre total de yamaha sound
curentnb2	dc.b	1
curentmask	dc.b	4	*Mask actuel
voies		dc.b	11 	*Nb de voies activees
cvoies		dc.b	11*4	*voies * octets dans 1 lignes pattern
yamvoices	dc.b	0	*Nb de voies yamaha
digvoices	dc.b	1	*Nb de voies digitales
curvoie		dc.b	3	*Voie courante    (0 -> 10)
curpatt		dc.b	0	*Pattern courante (0 -> 255)
curspl		dc.b	0	*Sample courant   (0 -> 255)
curyam		dc.b	0	*Yamaha sound     (0 -> 255)
curseq		dc.b	0	*Sequence courante(0 -> 255)
curnum		dc.b	0	*Musique courante (0 -> 255)
curlen		dc.b	0	*Longueur de la zic courante (0 -> 255)
curlop		dc.b    0       *Loop de la zic courante     (0 -> 255)
maxpatt		dc.b	2	*Pattern maximum
maxzic		dc.b	2	*Nb de zic maximum
	even
addpatt		dc.l	PATTERNS 	*Adresse pattern courante
debpatt		dc.l	PATTERNS	*Adresse debut pattern
addseq		dc.l	SEQUENCE
addspl		dc.l	s1	 	*Adresse debut spl
lensamples	dc.l	0		*Longueur de tous les samples
lenyams		dc.l	0		*Longueur de tous les yams

		even
**************************************************************************
SPLTSPE
	MOVEM.L	D0-A0/A1,-(A7)
	move.l	heretoconvert,a1
	bsr.S	SPLTOSPE
	MOVEM.L	(A7)+,D0-A0/A1
	move.w	#0,okp
	rts
**************************************************************************
*	SPL to SPE convertor
*	A1 = Adress of data sample	* en entree
*	A0 = Adress of the sample	* interne
*	D0 = Lenght of the sample	* interne
SPLTOSPE
	move.l	22(a1),a0
	move.l  26(a1),d0
	move.b	#$80,d1
.again	add.b	d1,(a0)+
	subq.l	#1,d0
	bne.s	.again
oout	rts
********************************************************************
DIVIDE2
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ.S	oout
	MOVE.L	A0,heretoconvert
	MOVE.W	#16,okp
	RTS
DIVIDE_2
	BSR.S	D_2
	MOVE.W	#0,okp
	RTS
D_2	MOVE.L	heretoconvert,A1
	MOVE.L	22(A1),A0
	MOVE.L	26(A1),D0
	ADD.L	#FINSAMPLE,D0
	MOVE.B	#$40,D1
	MOVE.B	#$80,D3
	MOVEQ	#1,D4
.AGAIN1	MOVE.B	(A0),D2
	SUB.B	D3,D2
	LSR.B	D4,D2
	SUB.B	D1,D2
	MOVE.B	D2,(A0)+
	SUBQ.L	#1,D0
	BNE.S	.AGAIN1
	RTS
	
DIVIDE3
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ	oout
	MOVE.L	A0,heretoconvert
	MOVE.W	#17,okp
	RTS
DIVIDE_3
	BSR.S	D_3
	MOVE.W	#0,okp
	RTS
D_3	MOVE.L	heretoconvert,A1
	MOVE.L	22(A1),A0
	MOVE.L	26(A1),D0
	ADD.L	#FINSAMPLE,D0
	MOVE.B	#$2A,D1
	MOVE.B	#$80,D3
	MOVEQ	#3,D4
.AGAIN2	MOVE.B	(A0),D2
	SUB.B	D3,D2
	DIVU	D4,D2
	SUB.B	D1,D2
	MOVE.B	D2,(A0)+
	MOVEQ	#0,D2
	SUBQ.L	#1,D0
	BNE.S	.AGAIN2
	RTS
	
DIVIDE4
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ	oout
	MOVE.L	A0,heretoconvert
	MOVE.W	#18,okp
	RTS
DIVIDE_4
	BSR.S	D_4
	MOVE.W	#0,okp
	RTS
D_4	MOVEM.L	D0-D4/A0-A1,-(A7)
	MOVE.L	heretoconvert,A1
	MOVE.L	22(A1),A0
	MOVE.L	26(A1),D0
	ADD.L	#FINSAMPLE,D0
	MOVE.B	#$20,D1
	MOVE.B	#$80,D3
	MOVEQ	#2,D4
.AGAIN3	MOVE.B	(A0),D2
	SUB.B	D3,D2
	LSR.B	D4,D2
	SUB.B	D1,D2
	MOVE.B	D2,(A0)+
	SUBQ.L	#1,D0
	BNE.S	.AGAIN3
	MOVEM.L	(A7)+,D0-D4/A0-A1
	RTS
********************************************************************
*	Erase a sample
ERASE	MOVE.B	#0,KEY
	movem.l	a0-a3/d0-d4,-(a7)
	bsr	SILENT
	moveq	#0,d0
	moveq	#0,d1
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	move.l	22(a0),a3		*Debut de l'ancien sample   = A3
	move.l	26(a0),d3		*Longeur de l'ancien sample = D3
	cmp.l	#0,d3			*Veut-il effacer un sample qui n'est pas en memoire
	beq	.nospl
	add.l	#FINSAMPLE,d3
	move.b	totalsample,d1
	cmp.b	#1,d1			*1 seul sample en memoire
	beq.s	.pasdesuite
	cmp.b	#0,d1			*Aucun sample en memoire
	beq	.nospl
	move.l	#255,d1
	moveq	#0,d4
	;subq.w	#1,d1	
	lea	SAMPLE,a1
.rep2	cmp.l	#0,22(a1)		*Y a-t-il un sample ?
	beq.s	.oncontinu
	move.l	22(a1),a2
	cmp.l	a3,a2			*Est-il avant celui qu'on efface ?
	bls.s	.oncontinu
	sub.l	d3,22(a1)		*Calcul la nouvelle START ADRESS
	sub.l	d3,30(a1)		*idem pour END ADRESS
	sub.l	d3,36(a1)		*idem pour LOOP ADRESS
	add.l	26(a1),d4		*On calcul la longeur total des spl suivants
	add.l	#FINSAMPLE,d4
.oncontinu
	add.l	#40,a1
	dbf	d1,.rep2
	cmp.l	#0,d4			* C'etait le dernier sample ?
	beq.s	.pasdesuite
	move.l	a3,a2
	add.l	d3,a2
.rep3	move.b	(a2)+,(a3)+		*Et on recopie tout le reste la ou
	subq.l	#1,d4			*l'ancien sample etait
	cmp.l	#0,d4
	bne.s	.rep3
.pasdesuite
	sub.l	d3,endaddr
	sub.l	d3,lensamples
	move.l	a0,a1
	move.w	#40-1,d1
.rep5	move.b	#0,(a0)+		*on efface ses donnees
	dbf	d1,.rep5
	move.w	#129,20(a1)
	move.b	#1,35(a1)
.rep4	move.b	#0,(a3)+		*on efface le sample
	subq.l	#1,d3
	bne.s	.rep4
	subq.b	#1,totalsample
	bsr	FRE
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#12,d0
	lea	NAMESAMPLE,a0
	add.l	d0,a0
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.l	#0,(a0)+
	move.b	#0,(a0)+
.nospl	movem.l	(a7)+,a0-a3/d0-d4
	rts
	
*************************************************************************
*	Keyboard rout
*	touche = # of the sample, or space bar
KEYB	
	MOVEQ	#0,D0
	MOVE.B	KEY,D0
	BEQ	.KEYB5
	CMP.B	lastkey,D0
	BEQ.S	.KEYB1
	MOVE.B	D0,lastkey
	MOVE.W	D0,touche
	MOVE.B	#0,WAIT3
	MOVE.B	#0,WAIT2
	RTS
.KEYB1	CMP.B	#1,WAIT2
	BEQ.S	.KEYB4
	ADDQ.B	#1,WAIT3
	CMP.B	#12,WAIT3
	BEQ.S	.KEYB2
	MOVE.W	#-1,touche
	RTS
.KEYB2	MOVE.B	#1,WAIT2
	MOVE.B	#0,WAIT3
	MOVE.W	D0,touche
	RTS
.KEYB4	ADDQ.B	#1,WAIT3
	CMP.B	#4,WAIT3
	BNE.S	.KEYB5
	MOVE.B	#0,WAIT3
	MOVE.W	D0,touche
	RTS
.KEYB5	MOVE.W	#-1,touche
	RTS
	
WAIT2	DC.B	0
WAIT3	DC.B	0
DRUM	DC.B	1		* SI = 0 ALORS ON EST EN MODE DRUM
	EVEN			* SI = 1 ALORS ON EST EN MODE FRQ
				* SI = 2 		      YAM
				* SI = 3		      DRUM + V
				* Ne pas oublier de nettoyer touche
*	touche = note or space bar
**************************************************************************
INPUT			*	Le retour
	MOVE.B	#0,KEY
	cmp.w	#0,okp
	bne.s	.cokp
	bsr	RESTITU
	moveq	#0,d0
	move.b	sampledata,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	move.l	a0,string
	move.l	#screen+32000+113*160+46,where2
	move.w	#0,compt
	move.b	#20,maxlet
	move.w	#2,okp
.cokp	rts
string	dc.l	0
where2	dc.l	0
maxlet	dc.b	0
	even

INPT2	move.b	#0,lastouche
	bsr.S	INPT
	move.b	#0,touche
	move.w	#0,okp
	bsr	AFFMOUSE
	rts
INPT	movem.l	d0-d1/a0-a2,-(a7)
	move.l	string,a0
	move.l	a0,a1
	moveq	#0,d1
	move.b	maxlet,d1
.onyva	move.b	#'Š',d0
	move.l	where2,where
	bsr	AFFICHE
.onyva2	bsr	INPUT2
	cmp.b	#$d,d0			* Si c'est RETURN ou ENTER
	beq.s	.fini1			* on va a la fin
	cmp.b	#$7f,d0			* Si c'est DEL
	beq.S	.del
	cmp.b	#8,d0			* ou BACKSPACE
	beq.S	.del			* on va en 'del'
	cmp.b	#$fd,d0			* Si c'est 'ESC'
	beq	.echap			* on annule tout
	cmp.b	#0,d0
	beq.s	.onyva2
	move.b	d0,(a0)
	move.l	where2,where
	bsr	AFFICHE
	subq.b	#1,d1			* Nb caracteres +1
	cmp.b  #0,d1
	bne.s	.go
	moveq	#1,d1	
	bra.s	.onyva
.go	addq.l	#1,a0
	addq.w	#1,compt
	cmp.w	#2,compt
	beq.s	.com2
	addq.l	#1,where2
	bra.s	.com1
.com2	addq.l	#7,where2
	move.w	#0,compt
.com1	bra.s	.onyva
.fini1	move.b #'Š',d0
	move.l	where2,where
	bsr	AFFICHE
	movem.l	(a7)+,d0-d1/a0-a2
	rts
.del	cmp.b	#20,D1
	bge	.onyva
	addq.b	#1,D1
	move.b	#0,d0
	move.l	where2,where
	bsr AFFICHE
	subq.l	#1,a0
	move.b	#0,(A0)
	addq.w	#1,compt
	cmp.w	#2,compt
	beq.s	.co1
	subq.l	#7,where2
	bra.s	.co2
.co1	subq.l	#1,where2
	move.w	#0,compt
.co2	bra	.onyva
.echap	move.w	#5,erreur
	movem.l	(a7)+,d0-d1/a0-a2
	rts

compt	dc.w	0
************************************************************************
*	Simule la fonction   #A  du  trap #1
*	Retour : D0 = Caractere
INPUT2	movem.l	d1/a1,-(a7)
	moveq	#0,d0
	moveq	#0,d1
	move.b	KEY,d1
.gti	move.b	KEY,d0
	cmp.b	d0,d1
	beq.s	.gti
.ici	lea	SCANCODE,a1
.deja	move.b	KEY,d0
	cmp.b	#0,d0
	bne.s	.deja2
	move.b	d0,lastouche
	bra.s	.deja
.deja2	cmp.b	lastouche,d0
	beq.s	.deja
	move.b	d0,lastouche
.cont2	cmp.b	#-1,(a1)
	beq.s	.findescodes
	cmp.b	(a1)+,d0
	beq.s	.ca
	addq.l	#1,a1
	bra.s	.cont2
.ca	move.b	(a1),d0
	movem.l	(a7)+,d1/a1
	rts
.findescodes
	moveq	#0,d0
	movem.l	(a7)+,d1/a1
	rts

compt2		dc.w	0
lastouche	dc.b	0
	even
**************************************************************************
AFFICHE			* D0 = Numero du caractere
	movem.l	a2-a3,-(a7)
	move.l	where,a2
	move.l	ADDFONT,a3
	
	cmp.b	#'Š',d0
	beq.S	.cursor
	cmp.b	#0,d0
	beq.S	.blank
	cmp.b	#' ',d0
	beq.S	.blank
	add.w	d0,a3
	
	move.b	(a3),(a2)
	move.b	$100(a3),160(a2)
	move.b	$200(a3),320(a2)
	move.b	$300(a3),480(a2)
	move.b	$400(a3),640(a2)
	move.b	$500(a3),800(a2)
	move.b	$600(a3),960(a2)
.zeend	movem.l	(a7)+,a2-a3
	rts
	
.blank	moveq	#0,d0
	move.b	d0,(a2)
	move.b	d0,160(a2)
	move.b	d0,320(a2)
	move.b	d0,480(a2)
	move.b	d0,640(a2)
	move.b	d0,800(a2)
	move.b	d0,960(a2)
	bra.s	.zeend
	
.cursor  not.b	(a2)
	not.b	160(a2)
	not.b	320(a2)
	not.b	480(a2)
	not.b	640(a2)
	not.b	800(a2)
	not.b	960(a2)
	bra.s	.zeend

where	dc.l	0		* Adresse ou afficher le caractere
**********************************************************************
CLRKEYB
	move.w #$b,-(a7)		*
	trap #1		        	*
	addq.l	#2,a7			*
	tst.w	d0			*
	beq.s	.gogo			* Ici c'est pour vider le tampon	
	move.w	#7,-(a7)		* du clavier
	trap #1			        *
	addq.l	#2,a7			*
	bra.s	CLRKEYB		        *
.gogo	rts


**************************************************************************
* Simule la fonction PRINT
* A0=Adresse ou se trouve le text
* A1=Adresse ou afficher sur l'ecran
* D1=Longueur du TXT

PRINT	movem.l	a0/d0-d2,-(a7)
	moveq	#0,d0
.again2	addq.w	#1,compt2
	cmp.w	#2,compt2
	beq.s	.cco1
	addq.l	#1,where
	bra.s	.cco2
.cco1	addq.l	#7,where
	move.w	#0,compt2
.cco2	move.b	(a0)+,d0
	bsr	AFFICHE
	subq.w	#1,d1
	cmp.w	#0,d1
	bne.s	.again2
	movem.l (a7)+,a0/d0-d2
	rts
**************************************************************************
AFFICHE2		* D0 = Numero du caractere
	cmp.b	#'Š',d0
	beq	ccursor
	cmp.b	#0,d0
	beq.s	cblank
	cmp.b	#' ',d0
	beq.s	cblank
	move.l	a1,a3
	add.w	d0,a3
cblok	move.b	(a3),(a2)
	move.b	(a3),160(a2)
	move.b	$100(a3),320(a2)
	move.b	$100(a3),480(a2)
	move.b	$200(a3),640(a2)
	move.b	$200(a3),800(a2)
	move.b	$300(a3),960(a2)
	move.b	$300(a3),1120(a2)
	move.b	$400(a3),1280(a2)
	move.b	$400(a3),1440(a2)
	move.b	$500(a3),1600(a2)
	move.b	$500(a3),1760(a2)
	move.b	$600(a3),1920(a2)
	move.b	$600(a3),2080(a2)
	rts
cblank	moveq	#0,d0
	move.b	d0,(a2)
	move.b	d0,160(a2)
	move.b	d0,320(a2)
	move.b	d0,480(a2)
	move.b	d0,640(a2)
	move.b	d0,800(a2)
	move.b	d0,960(a2)
	move.b	d0,1120(a2)
	move.b	d0,1440(a2)
	move.b	d0,1600(a2)
	move.b	d0,1760(a2)
	move.b	d0,1920(a2)
	move.b	d0,2080(a2)
	rts
ccursor not.b	(a2)
	not.b	160(a2)
	not.b	320(a2)
	not.b	480(a2)
	not.b	640(a2)
	not.b	800(a2)
	not.b	960(a2)
	not.b	1120(a2)
	not.b	1440(a2)
	not.b	1600(a2)
	not.b	1760(a2)
	not.b	1920(a2)
	not.b	2080(a2)
	rts
**********************************************************************
* Simule la fonction PRINT
* A0=Adresse ou se trouve le text
* A1=Adresse ou afficher sur l'ecran
* D1=Longueur du TXT
PRINT2	movem.l	a0-a3/d0-d1,-(a7)
	moveq	#0,d0
	move.l	ADDFONT,a1
	move.l	where,a2
.cagain2	addq.w	#1,compt2
	cmp.w	#2,compt2
	beq.s	.ccco1
	addq.w	#1,a2
	bra.s	.ccco2
.ccco1	addq.w	#7,a2
	move.w	#0,compt2
.ccco2	move.b	(a0)+,d0
	bsr	AFFICHE2
	subq.w	#1,d1
	cmp.w	#0,d1
	bne.s	.cagain2
	move.l	a2,where
	movem.l (a7)+,a0-a3/d0-d1
	rts
**********************************************************************
UPCURSOR
	CMP.B	#1,record
	BEQ.S	.rr
	CMP.B	#1,playpat
	BEQ.S	.rr
	CMP.B	#1,playsong
	BEQ.S	.rr
	CMP.B	#63,inpatt
	BEQ.S	.rr2
	BSR	PATTUP
	ADDQ.B	#1,inpatt
.rr	RTS
.rr2	MOVE.B	#0,inpatt
	BSR	AFFPATTERN
	RTS
**********************************************************************#
DOWNCURSOR
	CMP.B	#1,record
	BEQ.S	.rr3
	CMP.B	#1,playpat
	BEQ.S	.rr3
	CMP.B	#1,playsong
	BEQ.S	.rr3
	CMP.B	#0,inpatt
	BEQ.S	.rr4
	BSR.S	PATTDOWN
	SUBQ.B	#1,inpatt
.rr3	RTS
.rr4	MOVE.B	#63,inpatt
	BSR	AFFPATTERN
	RTS
**********************************************************************
PATTDOWN
	MOVE.W	#15,okp
	RTS
PATTDOWN2
	move.w	#0,okp
	MOVE.L	#VOICEDOWN,A2
	MOVEQ	#0,D0
	MOVEQ	#3,D2
DO3	MOVE.L	(A2)+,A0
	MOVE.L	A0,A1
	SUB.W	#8*160,a1
	MOVEQ	#8*2-1,D1
.DO1	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)
	
	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)

	LEA	-160(A0),A0
	LEA	-160(A1),A1
	DBF	D1,.DO1

	SUB.W	#160,A1
	MOVEQ	#6,D1
.DO2	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)
	
	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)

	LEA	-160(A0),A0
	LEA	-320(A1),A1
	DBF	D1,.DO2

	SUB.W	#160,A0
	SUB.W	#160,A1
	MOVEQ	#7,D1
.DO4	MOVE.B	-7(A1),-7(A0)
	MOVE.B	-7(A1),153(A0)
	MOVE.B	(A1),(A0)
	MOVE.B	(A1),160(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	8(A1),168(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	16(A1),176(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	24(A1),184(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	32(A1),192(A0)
	MOVE.B	40(A1),40(A0)
	MOVE.B	40(A1),200(A0)
	
	MOVE.W	48(A1),48(A0)
	MOVE.W	48(A1),208(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	56(A1),216(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	64(A1),224(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.W	72(A1),232(A0)
	MOVE.B	80(A1),80(A0)
	MOVE.B	80(A1),240(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	88(A1),248(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	96(A1),256(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	104(A1),264(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.W	112(A1),272(A0)
	MOVE.B	120(A1),120(A0)
	MOVE.B	120(A1),280(A0)
	
	LEA	-320(A0),A0
	LEA	-160(A1),A1
	DBF	D1,.DO4
	
	MOVEQ	#15,D1
.DO5	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)
	
	LEA	-160(A0),A0
	LEA	-160(A1),A1
	DBF	D1,.DO5
	DBF	D2,DO3

	LEA	patt,A1
	LEA	ccompt2,A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	voies,D2
	SUBQ.B	#1,D2
	MOVE.L	addpatt,A0
	MOVE.B	inpatt,D0
	SUBQ.B	#3,D0
	MOVE.B	D0,D3
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.L	D0,A0

.DO7	CMP.B	#0,D3
	BGE.S	.PAVIDE
	MOVE.L	#-1,A0
.PAVIDE	MOVE.L	(A1)+,where
	MOVE.W	(A2)+,compt2
	BSR	AFFPARTIPATT
	ADDQ.W	#4,A0
	DBF	D2,.DO7

	MOVE.L	patt,where
	ADD.L	#-9,where
	MOVE.W	#0,compt2
	MOVEQ	#0,D0
	MOVE.B	inpatt,D0
	SUBQ.W	#3,D0
	CMP.B	#0,D0
	BMI.S	.DNEG
	LEA	cs,A0
	MOVE.L	D0,D4
	DIVU	#10,D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	SWAP	D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	LEA	cs,A0
	BRA.S	.DPOSI
.DNEG	LEA	cv,A0
.DPOSI	MOVEQ	#2,D1
	BSR	PRINT

	MOVE.L	patt,a0
	ADD.W	#-8,A0
	MOVE.L	A0,A1
	MOVE.L	A0,A2
	MOVE.L	A0,A3
	ADD.W	#160*73,A1
	ADD.W	#160*145,A2
	ADD.L	#160*217,A3
M	SET	0
	REPT	8
	MOVE.B	M(a0),M(a1)
	MOVE.B	M+7(a0),M+7(a1)
	MOVE.B	M(a0),M(a2)
	MOVE.B	M+7(a0),M+7(a2)
	MOVE.B	M(a0),M(a3)
	MOVE.B	M+7(a0),M+7(a3)
M	SET M+160
	ENDR

	RTS
VOICEDOWN	DC.L	VOICED,VOICED+160*73,VOICED+160*145,VOICED+160*217
**************************************************************************
PATTUP
	move.w	#14,okp
	rts
PATTUP4
	move.w	#0,okp
	MOVE.L	#VOICEUP,A2
	MOVEQ	#0,D0
	MOVEQ	#3,D2
.UP3	MOVE.L	(A2)+,A0
	MOVE.L	A0,A1
	ADD.W	#8*160,a1
	MOVEQ	#8*2-1,D1
.UP1	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)
	
	LEA	160(A0),A0
	LEA	160(A1),A1
	DBF	D1,.UP1

	LEA	160(A1),A1
	MOVEQ	#7,D1
.UP4	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)
	
	LEA	160(A0),A0
	LEA	320(A1),A1
	DBF	D1,.UP4

	LEA	160(A0),A0
	MOVEQ	#7,D1

.UP5	MOVE.B	-7(A1),-7(A0)
	MOVE.B	-7(A1),153(A0)
	MOVE.B	(A1),(A0)
	MOVE.B	(A1),160(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	8(A1),168(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	16(A1),176(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	24(A1),184(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	32(A1),192(A0)
	MOVE.B	40(A1),40(A0)
	MOVE.B	40(A1),200(A0)
	
	MOVE.W	48(A1),48(A0)
	MOVE.W	48(A1),208(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	56(A1),216(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	64(A1),224(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.W	72(A1),232(A0)
	MOVE.B	80(A1),80(A0)
	MOVE.B	80(A1),240(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	88(A1),248(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	96(A1),256(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	104(A1),264(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.W	112(A1),272(A0)
	MOVE.B	120(A1),120(A0)
	MOVE.B	120(A1),280(A0)
	
	LEA	320(A0),A0
	LEA	160(A1),A1
	DBF	D1,.UP5

	MOVEQ	#8*2-1,D1
.UP6	MOVE.B	-7(A1),-7(A0)
	MOVE.B	(A1),(A0)
	MOVE.W	8(A1),8(A0)
	MOVE.W	16(A1),16(A0)
	MOVE.W	24(A1),24(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.B	40(A1),40(A0)

	MOVE.W	48(A1),48(A0)
	MOVE.W	56(A1),56(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	72(A1),72(A0)
	MOVE.B	80(A1),80(A0)

	MOVE.W	88(A1),88(A0)
	MOVE.W	96(A1),96(A0)
	MOVE.W	104(A1),104(A0)
	MOVE.W	112(A1),112(A0)
	MOVE.B	120(A1),120(A0)

	LEA	160(A0),A0
	LEA	160(A1),A1
	DBF	D1,.UP6
	DBF	D2,.UP3

	LEA	patt,A1
	LEA	ccompt2,A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	voies,D2
	SUBQ.B	#1,D2
	MOVE.L	addpatt,A0
	MOVE.B	inpatt,D0
	ADDQ.B	#3,D0
	MOVE.B	D0,D3
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.L	D0,A0

.UP7	CMP.B	#64,D3
	BLT.S	.PASVIDE
	MOVE.L	#-1,A0
.PASVIDE	MOVE.L	(A1)+,where
	ADD.L	#160*8*7+160,where
	MOVE.W	(A2)+,compt2
	BSR	AFFPARTIPATT
	ADDQ.W	#4,A0
	DBF	D2,.UP7

	MOVE.L	patt,where
	ADD.L	#-9+160*8*7+160,where
	MOVE.W	#0,compt2
	MOVEQ	#0,D0
	MOVE.B	inpatt,D0
	ADDQ.B	#3,D0
	CMP.B	#63,D0
	BGT.S	.NEG
	LEA	cs,A0
	MOVE.L	D0,D4
	DIVU	#10,D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	SWAP	D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	LEA	cs,A0
	BRA.S	.POSI
.NEG	LEA	cv,A0
.POSI	MOVEQ	#2,D1
	BSR	PRINT

	MOVE.L	patt,a0
	ADD.L	#-8+160*8*7+160,A0
	MOVE.L	A0,A1
	MOVE.L	A0,A2
	MOVE.L	A0,A3
	ADD.W	#160*73,A1
	ADD.W	#160*145,A2
	ADD.L	#160*217,A3
M	SET	0
	REPT	8
	MOVE.B	M(a0),M(a1)
	MOVE.B	M+7(a0),M+7(a1)
	MOVE.B	M(a0),M(a2)
	MOVE.B	M+7(a0),M+7(a2)
	MOVE.B	M(a0),M(a3)
	MOVE.B	M+7(a0),M+7(a3)
M	SET M+160
	ENDR

	RTS

VOICEUP	DC.L	VOICEU,VOICEU+160*73,VOICEU+160*145,VOICEU+160*217
**********************************************************************
PATTUP2
	move.w	#13,okp
	rts
PATTUP3
	move.w	#0,okp
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	lea	wa,a3
	lea	wb,a6
	move.b	inpatt,d1
	move.b	cvoies,d2
	mulu	d2,d1
	move.l	addpatt,a5
	add.w	d1,a5
	move.b	voies,d2
	subq.b	#1,d2

.patup	lea	pat,a2
	move.b	(a5),d0
	bsr	CHECKNOTE
	lea	hexa,a1
	moveq	#0,d0
	move.b	1(a5),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),4(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),3(a2)
	move.b	2(a5),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),6(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),5(a2)
	move.b	3(a5),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),8(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),7(a2)
	moveq	#0,d1
	move.b	(a6)+,d1
	move.w	d1,compt2
	move.l	(a3)+,where
	lea	pat,a0
	moveq	#9,d1
	bsr	PRINT2
	addq.w	#4,a5
	dbf	d2,.patup

	MOVE.L	patt,where
	ADD.L	#-9+160*8*3+160,where
	MOVE.W	#0,compt2
	MOVEQ	#0,D0
	MOVE.B	inpatt,D0
	CMP.B	#63,D0
	BGT.S	.NEG2
	LEA	cs,A0
	MOVE.L	D0,D4
	DIVU	#10,D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	SWAP	D4
	ADD.B	#'0',D4
	MOVE.B	D4,(A0)+
	LEA	cs,A0
	BRA.S	.POSI2
.NEG2	LEA	cv,A0
.POSI2	MOVEQ	#2,D1
	BSR	PRINT2

	MOVE.L	patt,a0
	ADD.L	#-8+160*8*3+160,A0
	MOVE.L	A0,A1
	MOVE.L	A0,A2
	MOVE.L	A0,A3
	ADD.W	#160*73,A1
	ADD.W	#160*145,A2
	ADD.L	#160*217,A3
M	SET	0
	REPT	16
	MOVE.B	M(a0),M(a1)
	MOVE.B	M+7(a0),M+7(a1)
	MOVE.B	M(a0),M(a2)
	MOVE.B	M+7(a0),M+7(a2)
	MOVE.B	M(a0),M(a3)
	MOVE.B	M+7(a0),M+7(a3)
M	SET M+160
	ENDR
	rts
**********************************************************************
CHECKNOTE
	MOVEM.L	D0-D1/A1,-(A7)
	LEA	DIGICORRES,A1
	TST.B	D0
	BEQ.S	.FL
	SUBQ.W	#1,D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	ADD.W	D0,A1
	MOVE.B	(A1),(A2)
	MOVE.B	1(A1),1(A2)
	MOVE.B	2(A1),2(A2)
	BRA.S	.FINLOOP
.FL	MOVE.B	#'-',(A2)
	MOVE.B	#'-',1(A2)
	MOVE.B	#'-',2(A2)
.FINLOOP	
	MOVEM.L	(A7)+,D0-D1/A1
	RTS
**********************************************************************
AFFPARTIPATT
	MOVEM.L	D0-D1/A0-A2,-(A7)
	cmp.l	#-1,a0
	beq	.empty
	moveq	#0,d0
	moveq	#0,d1
	lea	pattt,a2
	move.b	(a0),d0
	bsr.S	CHECKNOTE
	lea	hexa,a1
	
	move.b	1(a0),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),4(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),3(a2)

	move.b	2(a0),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),6(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),5(a2)

	move.b	3(a0),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),8(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),7(a2)
	
	moveq	#9,d1
	lea	pattt,a0
	bsr	PRINT
	lea	cp,a0
	lea	pattt,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	MOVEM.L	(A7)+,D0-D1/A0-A2
	rts
.empty	lea	vvide,a0
	moveq	#9,d1
	bsr	PRINT
	MOVEM.L	(A7)+,D0-D1/A0-A2
	rts
pattt	dc.b '---000000',0
cp	dc.b '---000000',0
vvide	dc.b '         '
	even	
**********************************************************************
AFFPATTERN
	move.w	#11,okp
	rts
AFFPATTERN2
	moveq	#0,d0
	moveq	#8,d2			* Nb de lignes a afficher par voie
	moveq	#0,d3			
	moveq	#0,d4			
	moveq	#0,d5			
	moveq	#0,d6			
	moveq	#0,d7
	move.b	voies,d3
	subq.b	#1,d3			* Nb de voies a afficher
	move.b	cvoies,d6
	move.b	inpatt,d0		* Ou dans la pattern
	mulu	d6,d0			* fois ce que prend 1 ligne 
	add.l	addpatt,d0		* plus l'adresse de la pattern courante
	sub.l	d6,d0
	sub.l	d6,d0
	sub.l	d6,d0
	move.l	d0,addpatt2		* egale la position dans la pattern
	moveq	#0,d0
	lea	patt,a1
	lea	ccompt2,a6

.ja2	move.l	(a1)+,where		* Ou afficher sur l'ecran/voie
	move.w	(a6)+,bo
	move.l	addpatt2,a3
	move.b	inpatt,d7

.ja	move.w	bo,compt2
	cmp.b	#2,d7
	ble.s	.crien
	cmp.b	#67,d7
	bge.s	.crien
	bra.s	.cquel
.crien	lea	vvide,a0
	bra.s	.ssss
.cquel	lea	pattt,a2		* Calcul ce que l'on va
	move.b	(a3),d0			* Afficher
	bsr	CHECKNOTE
	lea	hexa,a4
	
	move.b	1(a3),d5
	move.l	d5,d4
	and.b	#$f,d5
	move.b  (a4,d5.w),4(a2)
	lsr.b	#4,d4
	move.b	(a4,d4.w),3(a2)
	
	move.b	2(a3),d5
	move.w	d5,d4
	and.b	#$f,d5
	move.b  (a4,d5.w),6(a2)
	lsr.b	#4,d4
	move.b	(a4,d4.w),5(a2)
	
	move.b	3(a3),d5
	move.w	d5,d4
	and.b	#$f,d5
	move.b  (a4,d5.w),8(a2)
	lsr.b	#4,d4
	move.b	(a4,d4.w),7(a2)
	
	lea	pattt,a0

.ssss	subq.b	#1,d2
	cmp.b	#4,d2
	beq.s	.s16
	cmp.b	#0,d2
	beq.s	.za
	moveq	#9,d1
	bsr	PRINT
	add.l	#121+7*160,where
	add.w	d6,a3
	addq.b	#1,d7
	bra	.ja
.s16	add.l	#160,where
	moveq	#9,d1
	bsr	PRINT2
	add.l	#121+15*160,where
	add.w	d6,a3
	addq.b	#1,d7
	bra	.ja

.za	addq.l	#4,addpatt2
	moveq	#8,d2
	lea	cp,a0
	lea	pattt,a2
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.b	(a0)+,(a2)+
	dbf	d3,.ja2

.axel	moveq	#0,d0
	moveq	#0,d3
	move.b	inpatt,d0
	subQ.w	#3,d0
	move.l	patt,where
	sub.l	#9,where
.thro	move.w	#0,compt2
	cmp.w	#0,d0
	blt.S	.negatif
	cmp.w	#63,d0
	bgt.S	.negatif
	lea	cs,a0
	move.l	d0,d4
	divu	#10,d4
	add.b	#'0',d4
	move.b	d4,(a0)+
	swap	d4
	add.b	#'0',d4
	move.b	d4,(a0)+
	lea	cs,a0
	bra.S	.positif
.negatif	lea	cv,a0
.positif	cmp.b	#3,d3
	beq.S	.af16
	moveq	#2,d1
	bsr	PRINT
	add.l	#7*160+152,where
	bra.S	.trou
.af16	moveq	#2,d1
	add.l	#160,where
	bsr	PRINT2
	add.l	#15*160+152,where
.trou	addq.b	#1,d3
	addq.w	#1,d0
	cmp.b	#7,d3
	beq.s	.nif
	bra.S	.thro
.nif	move.l	patt,a0
	subQ.w	#8,a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,a3
	add.w	#160*73,a1
	add.w	#160*145,a2
	add.l	#160*217,a3
	bsr	dupliq
	
	bsr	FOND2
	move.w	#0,okp
	rts
patt	DC.L	VOICE,VOICE+40,VOICE+80
	DC.L	VOICE+160*73,VOICE+160*73+40,VOICE+160*73+80
	DC.L	VOICE+160*145,VOICE+160*145+40,VOICE+160*145+80
	DC.L	VOICE+160*217,VOICE+160*217+40
	DC.L	-1
ccompt2 DC.W	1,1,1,1,1,1,1,1,1,1,1
addpatt2	dc.l	0
wherevoice2	dc.w	0
addition	dc.w	0
bo		dc.w	0
cv		dc.b    '  '
cs		dc.b    '00'

**********************************************************************
AFFDATA
	movem.l	d0-d1/a0-a1,-(a7)
	moveq	#0,d0
	moveq	#0,d1
	lea	pat,a2
	move.b	#'-',(a2)
	move.b	#'-',1(a2)
	move.b	#'-',2(a2)
	move.b	(a3),d0
	bsr	CHECKNOTE
	lea	hexa,a1
	move.b	1(a3),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),4(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),3(a2)
	move.b	2(a3),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),6(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),5(a2)
	move.b	3(a3),d0
	move.w	d0,d1
	and.b	#$f,d0
	move.b  (a1,d0.w),8(a2)
	lsr.b	#4,d1
	move.b	(a1,d1.w),7(a2)
	
	move.w	wherevoice,d0
	divu	#4,d0
	lea	wb,a0
	add.w	d0,a0
	move.b	(a0),d1
	move.w	d1,compt2
	add.w	d0,d0
	add.w	d0,d0
	lea	wa,a0
	add.w	d0,a0
	move.l	(a0),where
	lea	pat,a0
	moveq	#9,d1
	bsr	PRINT2
	movem.l	(a7)+,d0-d1/a0-a1
	rts
hexa	dc.b 	'0123456789ABCDEF'
pat	dc.b 	'---000000'
	even	
wa	dc.l	CUR+1,CUR+41,CUR+81
	dc.l	CUR+160*73+1,CUR+160*73+41,CUR+160*73+81
	dc.l	CUR+160*145+1,CUR+160*145+41,CUR+160*145+81
	dc.l	CUR+160*217+1,CUR+160*217+41
wb	dc.b	1,1,1,1,1,1,1,1,1,1,1
zerotou	dc.w	0
**********************************************************************
CHECKPATT
	cmp.b	#1,edit			* si = 1 alors edit
	beq.S	.on_edit
	bra	.paricilasortie
.on_edit	
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	addpatt,a0
	move.b	inpatt,d1
	move.b	cvoies,d2
	mulu	d2,d1
	add.w	wherevoice,d1
	add.w	d1,a0
	cmp.w	#1,zerotou
	bne.s	.gou
	move.b	d0,(a0)
	move.b	d0,1(a0)
	move.b	d0,2(a0)
	move.b	d0,3(a0)
	move.b	d0,recnote
	move.b	d0,recinst
	
.gou	moveq	#0,d1
	lea	datawhat,a1
	move.b	whatvoice,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a1,d1.w),a1
	jsr	(a1)
	move.b	#0,recnote
	move.b	#0,recinst
	move.b	#0,reccom
	move.b	#0,receff
	move.l	a0,a3
	bsr	AFFDATA
	
	cmp.b	#0,playpat		* si on est en mode
	bne.s	.rdd			* play pattern  alors
	cmp.b	#63,inpatt
	bge.S	.paricilasortie2
	BSR	JOUEVOIE
	addq.b	#1,inpatt		* on incremente pas
.rdd	bsr	PATTUP
	rts
.paricilasortie2
	bsr	INVERT_EDIT
	move.b	#0,edit
.paricilasortie
	rts
edit	dc.b	0			* Etat de l'editeur
inpatt	dc.b	0			* Compteur dans la patt
**********************************************************************
PLAYPATT
	cmp.b	#1,playpat
	beq.s	.rt5
	bsr	EFFPAT
	move.b	#0,inpatt
	BRA.S	.RT11
.rt5	BSR	AFFPATTERN
.RT11	bchg	#0,playpat
	move.w	#0,u
	bsr	INVERT_PLAYPATT
	cmp.b	#1,playsong
	bne.s	RT14
	move.b	#0,playsong
	bsr	INVERT_PLAYSONG
RT14	cmp.b	#1,record
	bne.s	.rt9
	move.b	#0,record
	bsr	INVERT_RECORD
.rt9	cmp.b	#1,edit
	bne.s	.rt10
	move.b	#0,edit
	bsr	INVERT_EDIT
	move.b	dernier,curentnb2
	move.b	dernier,sampledata
.rt10	bsr	FOND2
	rts
v	dc.w	6			* Vitesse de la zik (tempo)
u	dc.w	6
playpat	dc.b	0			* Si = 1  alors mode PLAY PATT
playsong	dc.b	0		* Si = 1  alors mode PLAY SONG
**********************************************************************
PLAYSONG
	CMP.B	#1,playsong
	BEQ.S	.RT12
	BSR	EFFPAT
	MOVE.B	#0,inpatt
	BRA.S	.RT13
.RT12	BSR	AFFPATTERN
.RT13	BCHG	#0,playsong
	MOVE.W	#0,u
	BSR	INVERT_PLAYSONG
	CMP.B	#1,playpat
	BNE.S	.RT15
	MOVE.B	#0,playpat
	BSR	INVERT_PLAYPATT
.RT15	BRA	RT14
**********************************************************************
VBLPAT  ADDQ.W	#1,u
	MOVE.W	u,D0
	CMP.W	v,D0
	BLO	.sor
	MOVE.W	#0,u
	
	cmp.b	#1,playsong
	bne.s	.ssre
	BSR	SONG1
	
.ssre	BSR	JOUEVOIE
	cmp.b	#63,inpatt
	bge.s	.ssre2
	bsr	PATTUP2
.ssre2	cmp.b	#63,inpatt
	bne.S	.ros
	
	cmp.b	#1,playpat
	bne.s	.ros
	move.b	#0,playpat
	bsr	INVERT_PLAYPATT
	move.b	dernier,curentnb2
	move.b	dernier,sampledata
	move.w	#0,u
	bsr	FOND2
	bsr	AFFPATTERN
	bra.s	.SOR2
.ros	addq.b	#1,inpatt
.SOR2	CMP.B	#-1,BREAK
	BNE.S	.SRO
	MOVE.B	#0,BREAK
	MOVEQ	#0,D0
	MOVE.B	BREAKPOS,inpatt
	MOVE.B	#0,BREAKPOS
	BSR	sng1
.SRO	rts
.sor	BSR	EFFECT
	BRA.S	.SOR2
scurvoie	DC.B	0
BREAK		DC.B	0
	even
**********************************************************************
JOUEVOIE
	MOVE.L	A0,-(A7)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	addpatt,A0
	MOVE.B	inpatt,D0
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.W	D0,A0
	
	LEA	VOICE0,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE1,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE2,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE3,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE4,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE5,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE6,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE7,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE8,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE9,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE10,A1
	BSR.S	TREAT_ONE_VOICE

	MOVE.B	PATTDELTIME,D0
	BEQ.S	.DSKC
	MOVE.B	D0,PATTDELTIME2
	MOVE.B	#0,PATTDELTIME
.DSKC	TST.B	PATTDELTIME2
	BEQ.S	.DSKA
	SUBQ.B	#1,PATTDELTIME2
	BNE.S	.DSKA
	SUBQ.B	#1,inpatt
.DSKA	MOVE.L	(A7)+,A0
	RTS
**********************************************************************
TREAT_ONE_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	
	CMP.B	#$15,2(A0)
	BEQ.S	DOSETFINETUNE
	CMP.B	#3,2(A0)
	BEQ.S	CHECK_TONE
	CMP.B	#5,2(A0)
	BEQ.S	CHECK_TONE
	BRA.S	SET_P
DOSETFINETUNE
	BSR	SET_FINE_TUNE
	BRA.S	SET_P
CHECK_TONE
	BSR	SET_PORTAMENTO_TONE
	MOVE.B	2(A0),35(A1)
	MOVE.B	3(A0),36(A1)
	ADDQ.W	#4,A0
	RTS

SET_P	MOVE.B	1(A0),D0			* verifie INSTRUMENT
						* si non alors verifie
	BEQ.S	SET_PERIODE			* la note
	MOVE.B	D0,34(A1)
	BSR	INSTR
SET_PERIODE
	MOVE.B	(A0),D1				* NOTE
	BNE.S	GFD
	TST.B	1(A0)			* INSTRU
	BEQ.S	TREAT_EFFECT
	MOVE.W	32(A1),(A1)
	MOVE.B	63(A1),D1
	
GFD	LEA	DIGINOTE1,A2
	MOVEQ	#0,D0
	MOVE.B	58(A1),D0
	MULU	#54*2,D0
	MOVE.B	D1,63(A1)
	SUBQ.W	#1,D1
	ADD.W	D1,D1
	ADD.W	D0,D1
	MOVE.W	(A2,D1.L),D0
	MOVE.W	D0,D1
	LSR.W	#8,D0
	AND.W	#$FF,D1
	MOVE.B	D0,(A1)
	MOVE.B	D0,32(A1)
	MOVE.B	D1,1(A1)
	MOVE.B	D1,33(A1)
DFG	
	MOVE.B	2(A0),D0
	CMP.B	#$1D,D0 			; Notedelay
	BEQ.S	TREAT_EFFECT			* mt_CheckMoreEfx

	BTST	#2,51(A1)
	BNE.S	VIBNOC
	CLR.B	52(A1)
VIBNOC	BTST	#6,51(A1)
	BNE.S	TRENOC
	CLR.B	50(A1)
TRENOC	BSR	UPDATE_FUNK
	TST.B	1(A0)
	BNE.S	TREAT_EFFECT
	MOVE.B	34(A1),D0
	BSR.S	INSTR
	
TREAT_EFFECT
	MOVEQ	#0,D0
	MOVE.B	2(A0),D0			* EFFECT NUMBER
	CMP.B	#$20,D0
	BGE.S	ON1
	MOVE.B	D0,35(A1)
	MOVE.B	3(A0),36(A1)
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	TABLE_EFFECT,A2
	MOVE.L	(A2,D0.W),A2
	JSR	(A2)
ON1	ADDQ.W	#4,A0				* NEXT VOICE
NO_EFFECT
	RTS
**********************************************************************
INSTR	LEA	SAMPLE,A3
	SUBQ.B	#1,D0
	MOVE.W	D0,D1
	LSL.W	#5,D0				* MULU	#32
	LSL.W	#3,D1				* MULU	#8
	ADD.W	D1,D0
	ADD.W	D0,A3
	MOVE.L	22(A3),2(A1)			* ADD DEBUT
	MOVE.L	22(A3),18(A1)			* DANS ADD DEBUT SPL
	MOVE.L	26(A3),38(A1)
	MOVE.B	20(A3),58(A1)			* FINE TUNE
	MOVE.B	34(A3),37(A1)			* VOLUME
	MOVE.B	34(A3),22(A1)
	MOVE.B	35(A3),23(A1)			* LOOP OR NOT
	MOVE.B	21(A3),31(A1)			* FRQ DU SPL (6.25,12.5,25,50)
	MOVE.L	36(A3),6(A1)			* ADD LOOP DEBUT
	MOVE.L	36(A3),14(A1)			* DANS WAVE START
	MOVE.L	30(A3),10(A1)			* FIN LOOP
	RTS
**********************************************************************
ARPEGGIO
	TST.B	36(A1)
	BEQ	NO_EFFECT
	LEA	AD,A2
	MOVE.B	(A2),D0
	SUBQ.B	#1,D0
	BEQ.S	.ARP1
	MOVE.B	D0,(A2)
	CMP.B	#1,D0
	BEQ.S	.ARP2
	
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	LSR.B	#4,D0
	BRA.S	.ARP3
	
.ARP1	MOVE.B	#3,(A2)
	MOVE.B	36(A1),D0
	AND.W	#$F,D0
	BRA.S	.ARP3
	
.ARP2	MOVE.W	32(A1),(A1)
	RTS
	
.ARP3	LEA	TABLE_DIGINOTE,A2
	ADD.B	63(A1),D0
	ADD.W	D0,D0
	SUBQ.W	#2,D0
	MOVEQ	#0,D1
	MOVE.B	58(A1),D1
	ADD.W	D1,D1
	ADD.W	D1,D1
	MOVE.L	(A2,D1.W),A2
	MOVE.W	(A2,D0.W),(A1)
	RTS
	
**********************************************************************
PORTAMENTO_UP
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	SUB.W	D0,(A1)
	SUB.W	D0,32(A1)
	MOVE.W	(A1),D0
	CMP.W	#$28,D0
	BPL	VOL_OK
	MOVE.W	#$28,(A1)
	MOVE.W	#$28,32(A1)
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	RTS
**********************************************************************
PORTAMENTO_DOWN
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	ADD.W	D0,(A1)
	ADD.W	D0,32(A1)
	MOVE.W	(A1),D0
	CMP.W	#$358,D0
	BMI	VOL_OK
	MOVE.W	#$358,(A1)
	MOVE.W	#$358,32(A1)
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	RTS
**********************************************************************
SET_PORTAMENTO_TONE
	MOVE.B	(A0),D2
	BEQ	VOL_OK
	MOVEQ	#0,D0
	MOVE.B	58(A1),D0
	MULU	#54*2,D0
	ADD.W	D2,D2
	ADD.W	D0,D2
	LEA	DIGINOTE1,A2
	*MOVE.B	58(A1),D0
	*AND.B	#8,D0
	*BEQ.S	.STPGOSS
	*TST.W	D2
	*BEQ.S	.STPGOSS
	SUBQ.W	#2,A2
.STPGOSS
	MOVE.W	(A2,D2.W),D2

	MOVE.W	D2,60(A1)
	MOVE.W	32(A1),D0
	MOVE.B	#0,59(A1)
	CMP.W	D0,D2
	BEQ.S	.CLEARTONEPORTA
	BGE	VOL_OK
	MOVE.B	#1,59(A1)
	RTS
.CLEARTONEPORTA
	MOVE.W	#0,60(A1)
	RTS
**********************************************************************
PORTAMENTO_TONE
	MOVE.B	36(A1),D0
	BEQ.S	TONEPORTNOCHANGE
	MOVE.B	D0,62(A1)
	MOVE.B	#0,36(A1)
TONEPORTNOCHANGE
	TST.W	60(A1)
	BEQ	VOL_OK
	MOVEQ	#0,D0
	MOVE.B	62(A1),D0
	TST.B	59(A1)
	BNE.S	.TONEPORTAUP
.TONEPORTADOWN
	ADD.W	D0,(A1)
	ADD.W	D0,32(A1)
	MOVE.W	60(A1),D0
	CMP.W	(A1),D0
	BGT.S	.TONEPORTASETPER
	MOVE.W	60(A1),(A1)
	MOVE.W	#0,60(A1)
	BRA.S	.TONEPORTASETPER

.TONEPORTAUP
	SUB.W	D0,(A1)
	SUB.W	D0,32(A1)
	MOVE.W	60(A1),D0
	CMP.W	(A1),D0
	BLT.S	.TONEPORTASETPER
	MOVE.W	60(A1),(A1)
	MOVE.W	#0,60(A1)

.TONEPORTASETPER
	MOVE.W	(A1),D2
	MOVE.B	55(A1),D0
	AND.B	#$0F,D0
	BEQ.S	.GLISSKIP
	MOVEQ	#0,D0
	MOVE.B	58(A1),D0
	MULU	#54*2,D0
	LEA	DIGINOTE1,A2
	ADD.L	D0,A2
	MOVEQ	#0,D0
.GLISSLOOP
	CMP.W	(A2,D0.W),D2
	BHS.S	.GLISSFOUND
	ADDQ.W	#2,D0
	CMP.W	#54*2,D0
	BLO.S	.GLISSLOOP
	MOVEQ	#53*2,D0
.GLISSFOUND
	MOVE.W	(A2,D0.W),D2
.GLISSKIP
	MOVE.W	D2,(A1) 			; Set period
	MOVE.W	D2,32(A1)
	RTS
**********************************************************************
VIBRATO	
	MOVE.B	36(A1),D0
	BEQ.S	VIBRATO2
	MOVE.B	46(A1),D2
	AND.B	#$0F,D0
	BEQ.S	.VIBSKIP
	AND.B	#$F0,D2
	OR.B	D0,D2
.VIBSKIP
	MOVE.B	36(A1),D0
	AND.B	#$F0,D0
	BEQ.S	.VIBSKIP2
	AND.B	#$0F,D2
	OR.B	D0,D2
.VIBSKIP2
	MOVE.B	D2,46(A1)
VIBRATO2
	MOVE.B	47(A1),D0
	LEA	SINUS,A5
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	51(A1),D2
	AND.B	#$03,D2
	BEQ.S	.VIB_SINE
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	.VIB_RAMPDOWN
	MOVE.B	#255,D2
	BRA.S	.VIB_SET
.VIB_RAMPDOWN
	TST.B	47(A1)
	BPL.S	.VIB_RAMPDOWN2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	.VIB_SET
.VIB_RAMPDOWN2
	MOVE.B	D0,D2
	BRA.S	.VIB_SET
.VIB_SINE
	MOVE.B	0(A5,D0.W),D2
.VIB_SET
	MOVE.B	46(A1),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	32(A1),D0			* PERIODE
	TST.B	47(A1)
	BMI.S	.VIBRATONEG
	ADD.W	D2,D0
	BRA.S	.VIBRATO3
.VIBRATONEG
	SUB.W	D2,D0
.VIBRATO3
	MOVE.W	D0,(A1)				* PERIODE
	MOVE.B	46(A1),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,47(A1)
	RTS
**********************************************************************
PORT_SLID
	BSR	TONEPORTNOCHANGE
	BRA	VOLUME_SLIDE
	
**********************************************************************
VIB_SLID
	BSR.S	VIBRATO2
	BRA	VOLUME_SLIDE
**********************************************************************
TREMOLO
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVE.B	36(A1),D0
	BEQ.S	.TREMOLO2
	MOVE.B	49(A1),D2
	AND.B	#$0F,D0
	BEQ.S	.TRESKIP
	AND.B	#$F0,D2
	OR.B	D0,D2
.TRESKIP
	MOVE.B	36(A1),D0
	AND.B	#$F0,D0
	BEQ.S	.TRESKIP2
	AND.B	#$0F,D2
	OR.B	D0,D2
.TRESKIP2
	MOVE.B	D2,49(A1)
.TREMOLO2
	MOVE.B	50(A1),D0
	LEA	SINUS,A5
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	51(A1),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	.TRE_SINE
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	.TRE_RAMPDOWN
	MOVE.B	#255,D2
	BRA.S	.TRE_SET
.TRE_RAMPDOWN
	TST.B	52(A1)
	BPL.S	.TRE_RAMPDOWN2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	.TRE_SET
.TRE_RAMPDOWN2
	MOVE.B	D0,D2
	BRA.S	.TRE_SET
.TRE_SINE
	MOVE.B	0(A5,D0.W),D2
.TRE_SET
	MOVE.B	49(A1),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	37(A1),D0		* VOLUME
	TST.B	50(A1)
	BMI.S	.TREMOLONEG
	ADD.W	D2,D0
	BRA.S	.TREMOLO3
.TREMOLONEG
	SUB.W	D2,D0
.TREMOLO3
	BPL.S	.TREMOLOSKIP
	CLR.W	D0
.TREMOLOSKIP
	CMP.W	#$40,D0
	BLS.S	.TREMOLOK
	MOVE.W	#$40,D0
.TREMOLOK
	MOVE.W	D0,22(A1)
	MOVE.B	49(A1),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,50(A1)
	RTS
**********************************************************************
SAMPLEOFFSET
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	BEQ.S	.NONEW
	MOVE.B	D0,48(A1)
.NONEW	MOVE.B	48(A1),D0
	LSL.W	#8,D0
	ADD.L	D0,2(A1)
	MOVE.L	2(A1),D0
	MOVE.L	10(A1),D1
	CMP.L	D0,D1
	BLT.S	.NOOK
	RTS
.NOOK	MOVE.L	D1,2(A1)
	SUB.L	#10,2(A1)
	RTS
**********************************************************************
VOLUME_SLIDE
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	VOL_DOWN
VUP	ADD.B	D0,37(A1)
	CMP.B	#$40,37(A1)
	BMI.S	VOL_OK
	MOVE.B	#$40,37(A1)
	RTS
VOL_DOWN
	MOVE.B	36(A1),D0
	AND.B	#$F,D0
VDO	SUB.B	D0,37(A1)
	BPL.S	VOL_OK
	MOVE.B	#0,37(A1)
	RTS
	
**********************************************************************
POS_JUMP
	MOVE.B	#-1,BREAK
	MOVE.B	36(A1),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,curseq
JPP	MOVE.B	#0,BREAKPOS
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	RTS
	
**********************************************************************
SET_VOLUME
	MOVE.B	36(A1),37(A1)
	MOVE.B	36(A1),22(A1)
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	CMP.B	#$40,37(A1)
	BMI.S	VOL_OK
	MOVE.B	#$40,37(A1)
	MOVE.B	#$40,22(A1)
VOL_OK	RTS
	
**********************************************************************
PATT_BREAK
	MOVE.B	#-1,BREAK
	MOVE.B	3(A0),D0
	CMP.B	#63,D0
	BHI.S	JPP
	MOVE.B	D0,BREAKPOS
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	RTS
	
**********************************************************************
SET_SPEED
	MOVE.B	3(A0),D0
	AND.W	#$1F,D0
	MOVE.W	#0,u
	MOVE.W	D0,v
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	TST.W	v
	BNE.S	VOL_OK
	MOVE.W	#1,v
	RTS
**********************************************************************
LOWMASK	DC.B	0
	EVEN
FINE_PORT_UP
	TST.W	u
	BNE.S	VOL_OK
	MOVE.B	#$0F,LOWMASK
PORTAUP MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	AND.B	LOWMASK,D0
	MOVE.B	#$FF,LOWMASK
	SUB.W	D0,(A1)
	MOVE.W	(A1),D0
	CMP.W	#113,D0
	BPL	VOL_OK
	AND.W	#$F000,(A1)
	OR.W	#113,(A1)
	RTS
**********************************************************************
FINE_PORT_DOWN
	TST.W	u
	BNE	VOL_OK
	MOVE.B	#$0F,LOWMASK
PORTADOWN
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	AND.B	LOWMASK,D0
	MOVE.B	#$FF,LOWMASK
	ADD.W	D0,(A1)
	MOVE.W	(A1),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI	VOL_OK
	AND.W	#$F000,(A1)
	OR.W	#856,(A1)
	RTS
**********************************************************************
SET_GLISSANDO_CONTROL
	MOVE.B	3(A0),D0
	AND.B	#$F0,55(A1)
	OR.B	D0,55(A1)
	RTS
**********************************************************************
SET_VIBRATO_CONTROL
	MOVE.B	3(A0),D0
	AND.B	#$F0,51(A1)
	OR.B	D0,51(A1)
	RTS
**********************************************************************
SET_FINE_TUNE
	MOVE.B	3(A0),58(A1)
	RTS
**********************************************************************
JUMP_LOOP
	TST.B	u
	BNE	VOL_OK
	MOVE.B	3(A0),D0
	AND.B	#$0F,D0
	BEQ.S	.SETLOOP
 	TST.B	64(A0)
	BEQ.S	.JUMPCNT
	SUBQ.B	#1,64(A0)
	BEQ	VOL_OK
.JMPLOOP	MOVE.B	65(A0),BREAKPOS
	MOVE.B	#-1,BREAK
	RTS
.JUMPCNT	MOVE.B	D0,64(A0)
	BRA.S	.JMPLOOP
.SETLOOP	MOVE.B	inpatt,65(A0)
	RTS
BREAKPOS	DC.W	0
**********************************************************************
SET_TREMOLO_CONTROL
	MOVE.B	3(A0),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,51(A1)
	OR.B	D0,51(A1)
	RTS
**********************************************************************
RETRIG_NOTE
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	BEQ	VOL_OK
	MOVEQ	#0,D1
	MOVE.W	u,D1
	BNE.S	.RTNSKP
	MOVE.W	32(A1),D1				* ???
	BNE	VOL_OK
	MOVEQ	#0,D1
	MOVE.W	u,D1
.RTNSKP	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE	VOL_OK
	MOVE.L	18(A1),2(A1)			* ADD DEBUT SPL
	RTS
**********************************************************************
VOLUME_FINE_UP
	TST.W	u
	BNE	VOL_OK
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	AND.B	#$F,D0
	BRA	VUP
**********************************************************************
VOLUME_FINE_DOWN
	TST.W	u
	BNE	VOL_OK
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	AND.B	#$0F,D0
	BRA	VDO
**********************************************************************
NOTE_CUTE
	MOVEQ	#0,D0
	MOVE.B	36(A1),D0
	CMP.W	u,D0
	BNE	VOL_OK
	MOVE.B	#0,37(A1)
	RTS
**********************************************************************
NOTE_DELAY
	MOVEQ	#0,D0
	MOVE.L	D0,2(A1)
	MOVE.B	36(A1),D0
	CMP.W	u,D0
	BNE	VOL_OK
	MOVE.L	18(A1),2(A1)
	MOVE.B	#0,35(A1)
	MOVE.B	#0,36(A1)
	RTS
**********************************************************************
PATTERN_DELAY
	TST.W	u
	BNE	VOL_OK
	MOVEQ	#0,D0
	MOVE.B	3(A0),D0
	TST.B	PATTDELTIME2
	BNE	VOL_OK
	ADDQ.B	#1,D0
	MOVE.B	D0,PATTDELTIME
	RTS
PATTDELTIME	DC.B	0
PATTDELTIME2	DC.B	0
**********************************************************************
FUNK_IT
	TST.W	u
	BNE	VOL_OK
	MOVE.B	3(A0),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,55(A1)
	OR.B	D0,55(A1)
	TST.B	D0
	BEQ	VOL_OK
UPDATE_FUNK
	MOVEQ	#0,D0
	MOVE.B	55(A1),D0
	LSR.B	#4,D0
	BEQ.S	.FUNKEND
	LEA	FUNK_TABLE,A2
	MOVE.B	(A2,D0.W),D0
	ADD.B	D0,56(A1)
	BTST	#7,56(A1)
	BEQ.S	.FUNKEND
	CLR.B	56(A1)
	MOVE.L	10(A1),D0			* FIN DU SAMPLE
	MOVE.L	14(A1),A2
	ADDQ.L	#1,A2
	CMP.L	D0,A2
	BLO.S	.FUNKOK
	MOVE.L	10(A1),A2
.FUNKOK	MOVE.L	A2,14(A1)
	MOVEQ	#-1,D0
	SUB.B	(A2),D0
	MOVE.B	D0,(A2)
.FUNKEND	RTS
**********************************************************************
TABLE_EFFECT	DC.L	NO_EFFECT,NO_EFFECT,NO_EFFECT,SET_PORTAMENTO_TONE
		DC.L	NO_EFFECT,NO_EFFECT,NO_EFFECT,NO_EFFECT
		DC.L	NO_EFFECT,SAMPLEOFFSET,NO_EFFECT,POS_JUMP
		DC.L	SET_VOLUME,PATT_BREAK,NO_EFFECT,SET_SPEED
		DC.L	NO_EFFECT,FINE_PORT_UP,FINE_PORT_DOWN,SET_GLISSANDO_CONTROL
		DC.L	SET_VIBRATO_CONTROL,SET_FINE_TUNE,JUMP_LOOP,SET_TREMOLO_CONTROL
		DC.L	NO_EFFECT,RETRIG_NOTE,VOLUME_FINE_UP,VOLUME_FINE_DOWN
		DC.L	NOTE_CUTE,NOTE_DELAY,PATTERN_DELAY,FUNK_IT
		
TABLE_EFFECT2	DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,PORTAMENTO_TONE
		DC.L	VIBRATO,PORT_SLID,VIB_SLID,TREMOLO
		DC.L	NO_EFFECT,NO_EFFECT,VOLUME_SLIDE,NO_EFFECT
		DC.L	NO_EFFECT,NO_EFFECT,NO_EFFECT,NO_EFFECT
		DC.L	NO_EFFECT,NO_EFFECT,NO_EFFECT,NO_EFFECT
		DC.L	NO_EFFECT,NO_EFFECT,NO_EFFECT,NO_EFFECT
		DC.L	NO_EFFECT,RETRIG_NOTE,NO_EFFECT,NO_EFFECT
		DC.L	NOTE_CUTE,NOTE_DELAY,NO_EFFECT,NO_EFFECT
		
SINUS		DC.B	$00,$18,$31,$4A,$61,$78,$8B,$A1
		DC.B	$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
		DC.B	$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1
		DC.B	$8B,$78,$61,$4A,$31,$18
		
FUNK_TABLE	DC.B	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
		EVEN
**********************************************************************
* 0  - ARPEGGIO
* 1  - PORTAMENTO UP
* 2  - PORTAMENTO DOWN
* 3  - PORTAMENTO TONE
* 4  - VIBRATO
* 5  - PORTAMENTO TONE + VOLUME SLIDE
* 6  - VIBRATO + VOLUME SLIDE
* 7  - TREMOLO
* 8  -
* 9  - SAMPLE OFFSET
* A  - VOLUME SLIDE
* B  - POSITION JUMP
* C  - SET VOLUME
* D  - PATTERN BREAK
* E  - 
* F  - SET SPEED
* 10 -
* 11 - FINE PORTAMENTO UP
* 12 - FINE PORTAMENTO DOWN
* 13 - SET GLISSANDO CONTROL
* 14 - SET VIBRATO CONTROL
* 15 - SET FINE TUNE
* 16 - JUMP LOOP
* 17 - SET TREMOLO CONTROL
* 18 - 
* 19 - RETRIG NOTE
* 1A - VOLUME FINE UP
* 1B - VOLUME FINE DOWN
* 1C - NOTE CUT
* 1D - NOTE DELAY
* 1E - PATTERN DELAY
* 1F - FUNK IT
**********************************************************************
EFFECT	LEA	VOICE0,A1
	BSR.S	OUT_PAT
	LEA	VOICE1,A1
	BSR.S	OUT_PAT
	LEA	VOICE2,A1
	BSR.S	OUT_PAT
	LEA	VOICE3,A1
	BSR.S	OUT_PAT
	LEA	VOICE4,A1
	BSR.S	OUT_PAT
	LEA	VOICE5,A1
	BSR.S	OUT_PAT
	LEA	VOICE6,A1
	BSR.S	OUT_PAT
	LEA	VOICE7,A1
	BSR.S	OUT_PAT
	LEA	VOICE8,A1
	BSR.S	OUT_PAT
	LEA	VOICE9,A1
	BSR.S	OUT_PAT
	LEA	VOICE10,A1
	BSR.S	OUT_PAT
	RTS

OUT_PAT	MOVEQ	#0,D0
	MOVE.B	35(A1),D0
	CMP.B	#$20,D0
	BGE.S	OK_RTS
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	TABLE_EFFECT2,A2
	MOVE.L	(A2,D0.W),A2
	JSR	(A2)
OK_RTS	RTS
**********************************************************************
SONG1	cmp.b	#64,inpatt
	beq.s	sng1
	rts
sng1	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.b	curseq,d0
	move.b	curlen,d1
	cmp.b	d0,d1
	beq	finsong
	addq.b	#1,d0
LLOP	move.b	d0,curseq
	move.l	d0,d3
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+17*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT

	moveq	#0,d0
	moveq	#0,d1
	move.b	curseq,d0
	move.b	curnum,d1
	mulu	#256,d1
	move.l	addseq,a0
	add.w	d1,a0
	add.w	d0,a0
	move.b	(a0),d2
	move.b	d2,curpatt

	move.b	d2,d0
	lea	char3,a0
	bsr	CONVERT_BYTE_DECI
	lea	char3,a0
	move.l  #screen+32000+25*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT

	moveq	#0,d0
	move.b	cvoies,d0
	mulu	d0,d2
	mulu	#64,d2
	move.l	debpatt,a0
	add.l	d2,a0
	move.l	a0,addpatt
	move.b	#0,inpatt
	rts
finsong 
	move.b	curlop,d0
	bra	LLOP
**********************************************************************
VBLRECORD
	CMP.W	#1,sync
	BEQ	.ross
.rio	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	addpatt,a0
	move.b	inpatt,d0
	move.b	cvoies,d2
	mulu	d2,d0
	add.w	wherevoice,d0
	add.w	d0,a0
	cmp.w	#1,zerotou
	bne.s	.ter
	move.b	d1,(a0)
	move.b	d1,1(a0)
	move.b	d1,2(a0)
	move.b	d1,3(a0)
	move.b	d1,recinst
	bra.s	.zer

.ter	moveq	#0,d1
	lea	datawhat,a1
	move.b	whatvoice,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a1,d1.w),a1
	jsr	(a1)
	
.zer	ADDQ.W	#1,u
	MOVE.W	u,D0
	CMP.W	v,D0
	BLO	.ssor
	MOVE.W	#0,u
	
	move.b	#0,recnote
	move.b	#0,recinst
	move.b	#0,reccom
	move.b	#0,receff
	
	MOVE.L	A0,A3
	BSR	AFFDATA
	BSR	JOUEVOIE
	CMP.B	#63,inpatt
	BGE.S	.sre
	ADDQ.B	#1,inpatt
	BSR	PATTUP
	bra.s	.ssor
.sre	move.b	#0,record
	bsr	INVERT_RECORD
	move.b	dernier,curentnb2
	move.b	dernier,sampledata
	bsr	FOND2
.ssor	rts
.ross	cmp.b	#0,KEY
	beq.s	.iop
	move.w	#0,sync
	bra	.rio
.iop	rts
sync	dc.w	0
datawhat	dc.l	w0,w1,w2,w3,w4,w5,w6
**********************************************************************
* whatvoice = 0  (Note)
w0	cmp.b	#-1,recinst
	beq.s	w7
	move.b	recnote,(a0)
	move.b	recinst,1(a0)
w7	rts
* whatvoice = 1  (Instrument - haut)
w1	cmp.b	#-1,recinst
	beq.s	w7
	move.b	recinst,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,1(a0)
	or.b	d0,1(a0)
	rts
* whatvoice = 2  (Instrument - bas )
w2	cmp.b	#-1,recinst
	beq.s	w7
	move.b	recinst,d0
	and.b	#$f,d0
	and.b	#$f0,1(a0)
	or.b	d0,1(a0)
	rts
* whatvoice = 3  (Commande - haut)
w3	cmp.b	#-1,reccom
	beq.s	w7
	move.b	reccom,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,2(a0)
	or.b	d0,2(a0)
	rts
* whatvoice = 4  (Commande - bas)
w4	cmp.b	#-1,reccom
	beq.s	w7
	move.b	reccom,d0
	and.b	#$f,d0
	and.b	#$f0,2(a0)
	or.b	d0,2(a0)
	rts
* whatvoice = 5  (Donnees - haut)
w5	cmp.b	#-1,receff
	beq	w7
	move.b	receff,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,3(a0)
	or.b	d0,3(a0)
	rts
* whatvoice = 6  (Donnees - bas )
w6	cmp.b	#-1,receff
	beq	w7
	move.b	receff,d0
	and.b	#$f,d0
	and.b	#$f0,3(a0)
	or.b	d0,3(a0)
	rts
**********************************************************************
LEFTCURSOR
	cmp.b	#0,curpos
	beq.S	.leftout
	moveq	#0,d0
	bsr	OPTI
	subq.b	#1,curpos	
	bsr	OPTI
	rts
.leftout	moveq	#0,d0
	bsr	OPTI
	move.b	#75,curpos
	bsr	OPTI
	rts
RIGHTCURSOR
	cmp.b	#75,curpos
	beq.s	.rightout
	moveq	#0,d0
	bsr	OPTI
	addq.b	#1,curpos	
	bsr	OPTI
	rts
.rightout
	moveq	#0,d0
	bsr	OPTI
	move.b	#0,curpos
	bsr	OPTI
	rts
dataposcur
	dc.l	CUR+8,CUR+17,CUR+24,CUR+25,CUR+32,CUR+33,CUR+40
	dc.l	CUR+48,CUR+57,CUR+64,CUR+65,CUR+72,CUR+73,CUR+80
	dc.l	CUR+88,CUR+97,CUR+104,CUR+105,CUR+112,CUR+113,CUR+120

	dc.l	CUR+11680+8,CUR+11680+17,CUR+11680+24,CUR+11680+25,CUR+11680+32,CUR+11680+33,CUR+11680+40
	dc.l	CUR+11680+48,CUR+11680+57,CUR+11680+64,CUR+11680+65,CUR+11680+72,CUR+11680+73,CUR+11680+80
	dc.l	CUR+11680+88,CUR+11680+97,CUR+11680+104,CUR+11680+105,CUR+11680+112,CUR+11680+113,CUR+11680+120

	dc.l	CUR+23200+8,CUR+23200+17,CUR+23200+24,CUR+23200+25,CUR+23200+32,CUR+23200+33,CUR+23200+40
	dc.l	CUR+23200+48,CUR+23200+57,CUR+23200+64,CUR+23200+65,CUR+23200+72,CUR+23200+73,CUR+23200+80
	dc.l	CUR+23200+88,CUR+23200+97,CUR+23200+104,CUR+23200+105,CUR+23200+112,CUR+23200+113,CUR+23200+120

	dc.l	CUR+34720+8,CUR+34720+17,CUR+34720+24,CUR+34720+25,CUR+34720+32,CUR+34720+33,CUR+34720+40
	dc.l	CUR+34720+48,CUR+34720+57,CUR+34720+64,CUR+34720+65,CUR+34720+72,CUR+34720+73,CUR+34720+80
	
curpos	dc.b	0
whatvoice			* Qu'est-ce dans la voie ?
	dc.b	0		* 0 = Note
				* 1 = Instrument (hexa - haut)
				* 2 = Instrument (hexa - bas)
				* 3 = Commande   (hexa - haut)
				* 4 = Commande   (hexa - bas)
				* 5 = Donnees sur Commande (hexa - haut)
				* 6 = Donnees sur Commande (hexa - bas)
postyle	dc.b	0,0,0,1,0,2,0,3,0,4,0,5,0,6
	dc.b	4,0,4,1,4,2,4,3,4,4,4,5,4,6
	dc.b	8,0,8,1,8,2,8,3,8,4,8,5,8,6
	dc.b	12,0,12,1,12,2,12,3,12,4,12,5,12,6
	dc.b	16,0,16,1,16,2,16,3,16,4,16,5,16,6
	dc.b	20,0,20,1,20,2,20,3,20,4,20,5,20,6
	dc.b	24,0,24,1,24,2,24,3,24,4,24,5,24,6
	dc.b	28,0,28,1,28,2,28,3,28,4,28,5,28,6
	dc.b	32,0,32,1,32,2,32,3,32,4,32,5,32,6
	dc.b	36,0,36,1,36,2,36,3,36,4,36,5,36,6
	dc.b	40,0,40,1,40,2,40,3,40,4,40,5,40,6
wherevoice
	dc.w	0			* Position de la voie dans la pattern
***************************************************************************
CURSOR
m	set 0
	rept	14
	not.b	m(a0)
m	set m+160
	endr
	rts
OPTI	moveq	#0,d0
	moveq	#0,d1
	lea	dataposcur,a0
	lea	postyle,a1
	move.b	curpos,d0
	add.w	d0,d0
	add.l	d0,a1
	move.b	(a1)+,d1
	move.w	d1,wherevoice
	divu	#4,d1
	move.b	d1,curvoie
	move.b	(a1)+,whatvoice
	add.w	d0,d0
	add.l	d0,a0
	move.l	(a0),a0
	subq.w	#2,a0
	bsr.S	CURSOR
	JSR	TESTVOI
	rts
alors	dc.b	0
	even
**********************************************************************
EFFPAT
	MOVE.W	#12,okp
	RTS
EFFPAT2
	MOVE.L	#VOICEUP,A2
	MOVEQ	#0,D0
	MOVEQ	#3,D2
.EF3	MOVE.L	(A2)+,A0
	MOVEQ	#8*3-2,D1
.EF1	MOVE.B	D0,-7(A0)
	MOVE.B	D0,(A0)
	MOVE.W	D0,8(A0)
	MOVE.W	D0,16(A0)
	MOVE.W	D0,24(A0)
	MOVE.W	D0,32(A0)
	MOVE.B	D0,40(A0)

	MOVE.W	D0,48(A0)
	MOVE.W	D0,56(A0)
	MOVE.W	D0,64(A0)
	MOVE.W	D0,72(A0)
	MOVE.B	D0,80(A0)

	MOVE.W	D0,88(A0)
	MOVE.W	D0,96(A0)
	MOVE.W	D0,104(A0)
	MOVE.W	D0,112(A0)
	MOVE.B	D0,120(A0)

	LEA	160(A0),A0
	DBF	D1,.EF1
	LEA	160*17(A0),A0
	MOVEQ	#8*3-1,D1
.EF2	MOVE.B	D0,-7(A0)
	MOVE.B	D0,(A0)
	MOVE.W	D0,8(A0)
	MOVE.W	D0,16(A0)
	MOVE.W	D0,24(A0)
	MOVE.W	D0,32(A0)
	MOVE.B	D0,40(A0)

	MOVE.W	D0,48(A0)
	MOVE.W	D0,56(A0)
	MOVE.W	D0,64(A0)
	MOVE.W	D0,72(A0)
	MOVE.B	D0,80(A0)

	MOVE.W	D0,88(A0)
	MOVE.W	D0,96(A0)
	MOVE.W	D0,104(A0)
	MOVE.W	D0,112(A0)
	MOVE.B	D0,120(A0)
	
	LEA	160(A0),A0
	DBF	D1,.EF2
	LEA	160*9(A0),A0
	DBF	D2,.EF3
	BSR	FOND2
	move.w	#0,okp
	bsr	AFFMOUSE
	RTS
**********************************************************************

**********************************************************************
*	A0 = ou mettre le resultat de la conversion
*	D0 = nombre a convertir
*	     Le nombre est a 6 chiffres Hexa
*			     7 chiffres Deci  
CONVERT_HEXA_DECIASCII
	movem.l	d0-d1/a0-a1,-(a7)
	moveq	#0,d1
	move.l	a0,a1
	divu	#10000,d0
	move.l	d0,d1		
	swap	d0		
	move.w	#0,d0
	swap	d0		
	divu	#100,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	move.w	#0,d0
	swap	d0
	divu	#10,d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	swap	d0
	add.w	#'0',d0
	move.b	d0,(a0)+
	move.w	#0,d1
	swap	d1
	divu	#1000,d1
	add.w	#'0',d1
	move.b	d1,(a0)+
	move.w	#0,d1
	swap	d1
	divu	#100,d1
	add.w	#'0',d1
	move.b	d1,(a0)+
	move.w	#0,d1
	swap	d1
	divu	#10,d1
	add.w	#'0',d1
	move.b	d1,(a0)+
	swap	d1	
	add.w	#'0',d1
	move.b	d1,(a0)+
	move.w	#7,d1
.still	cmp.b	#'0',(a1)
	bne.s	.sortie
	move.b #0,(a1)+
	subq	#1,d1
	cmp.b	#0,d1
	bne.s	.still
.sortie	movem.l	(a7)+,d0-d1/a0-a1
	rts
**********************************************************************	
*	Affiche les donnees sur le sample
SUM     MOVEM.L	D0-D1/A0-A1,-(A7)
	moveq	#0,d0
	moveq	#0,d1
	move.l	a0,a1
	move.w	#20,d1
	move.l	#screen+32000+113*160+39,where
	move.w	#1,compt2
	bsr	PRINT
	moveq	#4,d1
	move.l 	#screen+32000+65*160+136+6,where
	move.w	#0,compt2
	move.b 	21(a0),d0
	bclr   	#7,d0
	mulu	#4,d0
	lea	FREQUENCE,a0
	add.l	d0,a0
	move.l	(a0),a0
	bsr	PRINT
	
	moveq	#0,d0
	move.b	34(a1),d0
	lea	hexa,a2
	lea	nume,a0
	move.w	d0,d1
	and.b	#$f,d0
	move.b	(a2,d0.w),1(a0)
	lsr.b	#4,d1
	move.b	(a2,d1.w),d1
	cmp.b	#'0',d1
	bne.s	.sum2
	move.b	#' ',d1
.sum2	move.b	d1,(a0)	
	move.l 	#screen+32000+73*160+136+6+8,where
	move.w	#0,compt2
	moveq	#2,d1
	bsr	PRINT

	move.l	26(a1),d0
	lea	lengt,a0
	bsr	CONVERT_HEXA_DECIASCII
	move.l	#screen+32000+17*160+95,where
	move.w	#1,compt2
	lea	lengt,a0		
	moveq	#7,d1
	bsr	PRINT
	
	cmp.l	#0,36(a1)
	beq.s	.nn2
	move.l	36(a1),d0
	sub.l	22(a1),d0
	lea	lengt,a0
	bsr	CONVERT_HEXA_DECIASCII
	cmp.b	#3,35(a1)
	bne.s	.nn1
	move.l	36(a1),d0
	sub.l	22(a1),d0
	cmp.l	#0,d0
	bne.s	.nn1
	move.b	#'0',lengt+6
	bra.s	.nn1
.nn2	move.l	#'    ',lengt
	move.w	#'  ',lengt+4
	move.b	#' ',lengt+6
.nn1	move.l	#screen+32000+33*160+95,where
	move.w	#1,compt2
	lea	lengt,a0		
	moveq	#7,d1
	bsr	PRINT
	bsr.S	AFFNBSPL
	bsr.S	AFFMONO
	MOVEM.L	(A7)+,D0-D1/A0-A1
	rts

AFFNBSPL
	MOVEQ	#0,D0
	move.b	sampledata,d0
	addq.b	#1,d0
	lea	hexa,a1
	lea	nume,a0
	move.w	d0,d1
	and.b	#$f,d0
	move.b	(a1,d0.w),1(a0)
	lsr.b	#4,d1
	move.b	(a1,d1.w),d1
	cmp.b	#'0',d1
	bne.s	.sum1
	move.b	#' ',d1
.sum1	move.b	d1,(a0)	
	move.l #screen+32000+9*160+118,where
	move.w	#0,compt2
	moveq	#2,d1
	bsr	PRINT
	rts
AFFMONO
	MOVEQ	#0,D0
	move.b	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	BTST.B	#7,21(A0)
	BNE.S	.MMONO
	LEA	STEREO,A0
	BRA.S	.SSTEREO
.MMONO	LEA	MONO,A0
.SSTEREO	move.l #screen+32000+57*160+119,where
	move.w	#1,compt2
	MOVEQ	#6,D1
	bsr	PRINT
	RTS
STEREO		DC.B 'STEREO'
MONO		DC.B 'MONO  '
FREQUENCE	dc.l l6,l12,l25,l50
l6		dc.b '6.25'
l12		dc.b '12.5'
l25		dc.b '  25'
l50		dc.b '  50'
nume		dc.b ' 0'
lengt		dc.b '       '
freem		dc.b '       '
	even
***********************************************************************
JOUESAMPLE		* PREPARE LE SAMPLE
	MOVEQ	#0,D0
	MOVE.B	curvoie,D0
	LEA	PILEVOIE,A0
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D0,A0
	MOVE.L	(A0),A0
	MOVE.W	24(A0),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	LEA	TBL,A0
	MOVE.L	(A0,D0.W),A0
	CMP.B	#8,D0
	BEQ.S	.DDRUM
.GGO	JSR	(A0)
	RTS
.DDRUM	CMP.B	#1,digvoices
	BNE.S	.GGO
	MOVE.L	#DRUM1,A0
	BRA.S	.GGO
TBL	DC.L	V_RTS,V_RTS,DRM_PREPA,DRM_PREPA,FRQ_PREPA,FRQ_PREPA,FRQ_PREPA,FRQ_PREPA

DRUM1	 move.l		current,a0
	 cmp.l		#0,a0
	 beq.s		paslapeine
	 cmp.b		#1,playpat
	 beq.s		.th
	 move.b  	curentnb2,sampledata
	 moveq		#0,d0
	 bsr		SUM
	 move.l		current,a0
.th	MOVEQ		#0,D0
	MOVE.B		21(A0),D0 
	MOVE.W    	D0,$FFFF8920.W  ;sound-mode
					;00 6250  hz
					;1  12517 hz
					;2  25033 hz
					;3  50066 hz
					;mono +128
	  LEA		$FFFF8901.W,A1
	  MOVE.L	22(A0),D0
	  MOVEP.L	D0,(A1)
	  MOVE.L	30(A0),D0
	  MOVEP.L	D0,12(A1)
	  MOVE.B	35(A0),D0
	  AND.B		#$FF,D0
	  MOVE.W  	D0,$FFFF8900.W          
	  CMP.B		#3,D0
	  BNE.S		.PASLA
	  MOVE.L	36(a0),DA
	  MOVE.B	DA+1,$FFFF8903.W
	  MOVE.B	DA+2,$FFFF8905.W
	  MOVE.B	DA+3,$FFFF8907.W
.PASLA	  MOVE.B  	#0,curentnb2
paslapeine 	        rts

PLAY_SAMP:        move.w  #$7FF,$FFFF8924.W  ;    MASK PROCESSEUR SON
                  cmpi.w  #$7FF,$FFFF8924.W  ;    PRET A RECEVOIR ??
                  bne.s   PLAY_SAMP       
                  move.w  d0,$FFFF8922.W     ;    REGLAGE VOLUME + FILTRES
                  rts 
DA		  DC.L	0
*************************************************************************
FRQ_PREPA
	moveq	#0,d0	
	moveq	#0,d1
	move.b	curentnb2,d0
	mulu	#40,d0
	lea	SAMPLE,a1
	add.l	d0,a1
	cmp.l	#0,26(a1)
	beq.S	.nno
	move.b	curvoie,d1
	lea	PILEVOIE,a0
	add.w	d1,d1	
	add.w	d1,d1
	move.l	(a0,d1.w),a0
	
	moveq	#0,d0
	move.b	recnote,d0
	beq.s	.jjj
	subq.w	#1,d0
	lea	DIGINOTE1,a4
	add.w	d0,d0
	move.w	(a4,d0.w),(a0)		* note
	bra.s	.kkk
.jjj	move.w	#0,(a0)
.kkk	move.l	22(a1),2(a0)		* adresse debut
	move.l	36(a1),6(a0)		* loop debut
	move.l	30(a1),10(a0)		* fin du sample
	move.b	35(a1),23(a0)		* LOOP 1 = non   3 = oui
	move.b	21(a1),31(a0)		* frq spl (for drum)
.nno	rts
*************************************************************************
DRM_PREPA
	moveq	#0,d0	
	move.b	curentnb2,d0
	mulu	#40,d0
	lea	SAMPLE,a0
	add.l	d0,a0
	cmp.l	#0,26(a0)
	beq.s	.nnno
	move.l	a0,a1
	CMP.B	#1,playpat
	BEQ.S	.TH1
	MOVE.B 	curentnb2,sampledata
	MOVEQ	#0,D0
	BSR	SUM
.TH1	moveq	#0,d1
	move.b	curvoie,d1
	lea	PILEVOIE,a0
	add.w	d1,d1	
	add.w	d1,d1
	move.l	(a0,d1.w),a0
	move.w	#0,(a0)
	move.l	22(a1),2(a0)		* adresse debut
	move.l	36(a1),6(a0)		* loop debut
	move.l	30(a1),10(a0)		* fin du sample
	move.b	35(a1),23(a0)		* LOOP 1 = non   3 = oui
	move.b	21(a1),31(a0)		* frq spl (for drum)
.nnno	rts
**************************************************************************
SAV		DC.L	MUSDEB+504
CONTEUR		DC.W	0
CONTEUR2	DC.W	1
BOUCLE		DC.W	0
BOUCLE1		DC.W	0
DAC_SYNC
	CMP.B	#1,digvoices
	BNE.S	.OOK
	CMP.B	#0,DRUM
	BNE.S	.OOK
	RTS
.OOK	ADDQ.W		#1,CONTEUR
	CMP.W		#1,CONTEUR
	BEQ.S		.ENCORVBL2
	CMP.W		#2,CONTEUR
	BEQ.S		.ENCORVBL3
	CMP.W		#3,CONTEUR
	BEQ.S		.ENCORVBL4
	CMP.W		#4,CONTEUR
	BEQ.S		.ENCORVBL5
.ENCORVBL2	
	MOVE.W 	#0,$FFFF8900.W
	MOVE.W 	#3,$FFFF8900.W
	MOVE.W	LEN1,BOUCLE
	MOVE.W	LEN1,BOUCLE1
	RTS
.ENCORVBL3	
	MOVE.W	LEN2,BOUCLE
	MOVE.W	LEN2,BOUCLE1
	RTS
.ENCORVBL4
	MOVE.W	LEN3,BOUCLE
	MOVE.W	LEN3,BOUCLE1
	RTS
.ENCORVBL5
	MOVE.W	LEN4,BOUCLE
	MOVE.W	LEN4,BOUCLE1
	MOVE.L	POINT1,SAV
	MOVE.W	#0,CONTEUR
	RTS
*************************************************************************
JOUEDIGIT
	MOVEM.L	D0-A6,-(SP)
	TST.W	DISPO
	BEQ.S	DISPO1
	
	LEA	VOICE0,A6
	BSR	CHOIX
	LEA	VOICE2,A6
	BSR	CHOIX
	LEA	VOICE1,A6
	BSR	CHOIX
	LEA	VOICE3,A6
	BSR	CHOIX
	LEA	VOICE4,A6
	BSR	CHOIX
	LEA	VOICE6,A6
	BSR	CHOIX
	LEA	VOICE5,A6
	BSR	CHOIX
	LEA	VOICE7,A6
	BSR	CHOIX
	LEA	VOICE8,A6
	BSR	CHOIX
	LEA	VOICE10,A6
	BSR	CHOIX
	LEA	VOICE9,A6
	BSR	CHOIX
	BRA.S	FINDI
	
DISPO1	LEA	VOICE0,A6
	BSR.S	CHOIX
	LEA	VOICE1,A6
	BSR.S	CHOIX
	LEA	VOICE2,A6
	BSR.S	CHOIX
	LEA	VOICE3,A6
	BSR.S	CHOIX
	LEA	VOICE4,A6
	BSR.S	CHOIX
	LEA	VOICE5,A6
	BSR.S	CHOIX
	LEA	VOICE6,A6
	BSR.S	CHOIX
	LEA	VOICE7,A6
	BSR.S	CHOIX
	LEA	VOICE8,A6
	BSR.S	CHOIX
	LEA	VOICE9,A6
	BSR.S	CHOIX
	LEA	VOICE10,A6
	BSR.S	CHOIX
	
FINDI	MOVE.L	SAV,A5
	MOVEQ	#0,D5
	MOVE.W	BOUCLE1,D5
	CMP.B	#1,digvoices
	BEQ.S	.YT
	ADD.W	D5,A5
.YT	ADD.W	D5,A5
	MOVE.L	A5,SAV
	MOVEM.L	(A7)+,D0-A6
FINVBL	RTS
*************************************************************************
RESTE	DC.W	0
VOID	DC.B	0	* NB DE VOIES DIGITALES RENCONTREES
VOIY	DC.B	0	* NB DE VOIES YAMAHA    RENCONTREES

CHOIX	
	MOVE.W	BOUCLE1,BOUCLE
	LEA	TABLE_CHOIX,A0
	MOVE.W	24(A6),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A0,D0.W),A0
	JMP	(A0)
	
TABLE_CHOIX	DC.L	FINVBL,FINVBL,CHOIXDRUM,CHOIXDRUM,CHOIXFRQ,CHOIXFRQ,CHOIXFRQ,CHOIXFRQ
	
CHOIXFRQ	
	CMP.B	#1,digvoices		* SI 1 VOIE DIGITAL
	BNE.S	.PAS1
	LEA	PIL1,A0
	BRA	CALCVOICE
	
.PAS1	TST.B	VOID
	BNE.S	.CH2
	LEA	PIL2,A0
	BRA.S	CALCVOICE
	
.CH2	CMP.B	#1,VOID
	BNE.S	.CH3
	LEA	PIL2,A0
	BRA.S	CALCVOICE
	
.CH3	LEA	PIL3,A0

CALCVOICE
	BSR	CHOIX_ROUT
	MOVE.L	SAV,A5
	MOVEQ	#0,D0
	MOVE.B	VOID,D0
	SUBQ	#1,D0
	BTST	#0,D0
	BEQ.S	.FIST
	ADDQ.W	#1,A5
.FIST	MOVE.L	2(A6),A0		* ADRESSE DEBUT
	TST.L	2(A6)
	BNE.S	.PASZERO
	MOVE.L  #RIEN,A0
.PASZERO MOVE.W	BOUCLE,D3
AARGH	LEA	FRQ1W,A1
MULT	MULU	#8,D3
	ADD.L	D3,A1
	MOVE.W	(A1),TOWER1		* SAUVE L'ANCIENNE INSTRUCTION
	MOVE.L	A1,TOWER2		* AVANT DE PLACER LE  RTS
	MOVE.W	#$4E75,(A1)
	
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D7
	LEA	FRQ,A4
	MOVE.W	(A6),D7			* NOTE
	BEQ.S	.RFV
	ADD.W	D7,D7
	ADD.W	D7,D7
	MOVE.L	(A4,D7.W),D7
.RFV	MOVE.W	D7,D0
	SWAP	D7
	MOVE.W	D7,D2
	SWAP	D7
	MOVE.B	37(A6),D4
	BEQ.S	.V_NUL
	SUBQ.W	#1,D4
	LSL.W	#8,D4
.V_NUL	MOVE.L	VOLUME,A4
	ADD.L	A4,D4
ROUTINE	JSR	FRQ1W
	MOVE.L	TOWER2,A1		* REPLACE L'ANCIEN INSTRUCTION
	CMP.L	#0,A1
	BEQ.S	.TERR
	MOVE.W	TOWER1,(A1)

.TERR	TST.L	2(A6)
	BEQ.S	.RRETT
	ADD.W	D3,A0
	MOVE.L	A0,2(A6)
	MOVE.L	A0,D0
	MOVE.L	10(A6),D1
	CMP.L	D0,D1
	BGE.S	.PARES
	BRA.S	.CALCRESTE
.RRETT	MOVE.L	#0,TOWER2
	MOVE.W	#0,TOWER1
	RTS
	

.CALCRESTE
	CMP.B	#1,23(A6)
	BNE.S	.UNLOOP
	MOVE.W	#0,(A6)
	MOVE.L	#0,2(A6)
.PARES	RTS

.UNLOOP	MOVE.L	2(A6),D0
	MOVE.L	10(A6),D1
	SUB.L	D1,D0
	MOVE.L	6(A6),2(A6)
	ADD.L	D0,2(A6)
.YET	MOVE.L	2(A6),D1
	MOVE.L	10(A6),D2
	CMP.L	D2,D1
	BGE.S	.RECAL
	RTS
.RECAL	
	SUB.L	6(A6),D1
	SUB.L	6(A6),D2
	SUB.L	D2,D1
	MOVE.L	6(A6),2(A6)
	ADD.L	D1,2(A6)
	BRA.S	.YET

CHOIX_ROUT
	ADDQ.B	#1,VOID
	MOVEQ	#0,D0
	MOVE.B	25(A6),D0
	SUBQ.W	#4,D0
	MULU	#8,D0
	ADD.W	D0,A0
	MOVE.L	(A0),ROUTINE+2
	MOVE.L	(A0)+,AARGH+2
	MOVE.L	(A0)+,D0
	MOVE.W	D0,MULT+2
	RTS

PIL1	DC.L	FRQ1W,8,VFRQ1W,12
PIL2	DC.L	FRQ2W,10,VFRQ2W,14
PIL3	DC.L	FRQ3W,12,VFRQ3W,16

TOWER1		DC.W	0
TOWER2		DC.L	0
***************************************************************************
CHOIXDRUM
	CMP.B	#1,digvoices		* SI 1 VOIE DIGITAL
	BNE.S	.PAS2
	CMP.W	#2,24(A6)		* ET SI JUST DRUM
	BEQ	DRUM2
	LEA	DPIL1,A0
	BRA.S	.CALCVOICE_D
	
.PAS2	TST.B	VOID
	BNE.S	.CH4
	LEA	DPIL2,A0
	BRA.S	.CALCVOICE_D
	
.CH4	CMP.B	#1,VOID
	BNE.S	.CH5
	LEA	DPIL2,A0
	BRA.S	.CALCVOICE_D
	
.CH5	LEA	DPIL3,A0

.CALCVOICE_D
	BSR	CHOIX_ROUT_D
	MOVE.L	SAV,A5
	MOVEQ	#0,D0
	MOVE.B	VOID,D0
	SUBQ	#1,D0
	BTST	#0,D0
	BEQ.S	.DFIST
	ADDQ.W	#1,A5
.DFIST	MOVE.L	2(A6),A0		* ADRESSE DEBUT
	TST.L	2(A6)
	BNE.S	.DPAZERO
	MOVE.L  #RIEN,A0
	
.DPAZERO
	BSR	TEST_FIN_DRM
	MOVEQ	#0,D4
	MOVE.B	37(A6),D4
	BEQ.S	.VOL_NUL
	SUBQ.W	#1,D4
	LSL.W	#8,D4
.VOL_NUL	MOVE.L	VOLUME,A4
	ADD.L	A4,D4
DROUT	JSR	FRQ1W
	MOVE.L	TOWER2,A1		* REPLACE L'ANCIEN INSTRUCTION
	CMP.L	#0,A1
	BEQ.S	.DTERR
	MOVE.W	TOWER1,(A1)
.DTERR	TST.L	2(A6)
	BEQ.S	DRRETT
ADI	ADD.L	#0,A0
	MOVE.L	A0,2(A6)
	MOVE.L	A0,D0
	MOVE.L	10(A6),D1
	CMP.L	D0,D1
	BGE.S	DFF
	BRA.S	DCALCRESTE
DRRETT	MOVE.L	#0,TOWER2
	MOVE.W	#0,TOWER1
DFF	RTS

DCALCRESTE
	CMP.B	#1,23(A6)
	BNE.S	.DUNLOOP
	MOVE.W	#0,(A6)
	MOVE.L	#0,2(A6)
	RTS
.DUNLOOP	
	MOVE.L	2(A6),D0
	MOVE.L	10(A6),D1
	SUB.L	D1,D0
	MOVE.L	6(A6),2(A6)
.DYET	MOVE.L	2(A6),D1
	MOVE.L	10(A6),D2
	ADD.L	D0,D1
	CMP.L	D2,D1
	BGE.S	.DRECAL
	RTS
.DRECAL	
	SUB.L	6(A6),D1
	SUB.L	6(A6),D2
	SUB.L	D2,D1
	MOVE.L	6(A6),2(A6)
	ADD.L	D1,2(A6)
	BRA.S	.DYET	

TEST_FIN_DRM
	MOVEQ	#0,D0
	MOVE.W	BOUCLE,D0
DCALC	LEA	FRQ1W,A1
MULTIP	MULU	#8,D0
	ADD.L	D0,A1
.TTST	CMP.W	#$1B68,(A1)
	BEQ.S	.RRIGHT
	CMP.W	#$1828,(A1)
	BEQ.S	.RRIGHT
	LEA	-2(A1),A1
	BRA.S	.TTST	
.RRIGHT	MOVE.W	(A1),TOWER1
	MOVE.W	2(A1),ADI+4
	MOVE.L	A1,TOWER2
	MOVE.W	#$4E75,(A1)
	RTS

CHOIX_ROUT_D
	ADDQ.B	#1,VOID			* FAUDRA VOIR LA FRQ DU DAC, AUSSI
	MOVEQ	#0,D0			* ICI DEFAUT A 25 KHZ
	MOVE.W	24(A6),D0		* QUEL STYLE DE VOIE ?
	SUBQ.W	#2,D0
	MULU	#4,D0
	MOVE.L	(A0,D0.W),A0

	MOVE.B	31(A6),D0		* QUELLE FREQUENCE ?
	BCLR	#7,D0
	MULU	#8,D0
	ADD.W	D0,A0

	MOVE.L	(A0),DROUT+2
	MOVE.L	(A0)+,DCALC+2
	MOVE.L	(A0)+,D0
	MOVE.W	D0,MULTIP+2
	RTS

DPIL1		DC.L	0,NORM_VOL1		* 0 CAR DRUM DU DAC
DPIL2		DC.L	NORM2,NORM_VOL2
DPIL3		DC.L	ADD_,ADD_VOL

NORM_VOL1					* 0 CAR PAS FAIT
		
NORM2		DC.L	D625R25,6		* DRUM A  6.25
		DC.L	D625R125,6		* DRUM A 12.5
		DC.L	D625R625,6		* DRUM A 25 
		DC.L	D125R625,6		* DRUM A 50
NORM_VOL2	DC.L	D625R25_VOL,10
		DC.L	D625R125_VOL,10
		DC.L	D625R625_VOL,10
		DC.L	D125R625_VOL,10
ADD_		DC.L	D625R25_ADD,8
		DC.L	D625R125_ADD,8
		DC.L	D625R625_ADD,8
		DC.L	D125R625_ADD,8
ADD_VOL		DC.L	D625R25_VOL_ADD,12
		DC.L	D625R125_VOL_ADD,12
		DC.L	D625R625_VOL_ADD,12
		DC.L	D125R625_VOL_ADD,12
CA_SERT		DC.W	0
*************************************************************************
DRUM2	
	TST.L	18(A6)
	BEQ	paslapeine
	MOVE.L	#-1,18(A6)
	MOVEQ	#0,D0
	MOVE.B	31(A6),D0
	MOVE.W 	D0,$FFFF8920.W			* FRQ
	LEA	$FFFF8901.W,A1
	MOVE.L	2(A6),D0			* DEBUT
	MOVEP.L	D0,(A1)
	ADD.L	18(A6),D0			* + LEN = FIN
	MOVEP.L	D0,12(A1)
	MOVE.B	23(A6),D0
	AND.W	#$FF,D0
	MOVE.W  D0,$FFFF8900.W			* LOOP OR NOT
	MOVE.L	#0,18(A6)
	CMP.W	#3,D0
	BNE	paslapeine
	MOVE.L	6(A6),DA			* DEBUT LOOP
	MOVE.B	DA+1,$FFFF8903.W
	MOVE.B	DA+2,$FFFF8905.W
	MOVE.B	DA+3,$FFFF8907.W
	RTS
*************************************************************************
YAM_CALC
	rts
V_RTS
	rts
*************************************************************************
*	DATA MOUSE

x1	dc.w	3
x2	dc.w	3
y1	dc.w	74
y2	dc.w	74
km	dc.b	0
	even
**************************************************************************
AFFMOUSE
	cmp.w	#0,okp
	bne	.finaffmouse
	MOVE.W	x1,XS
	MOVE.W	y1,YS
	MOVE.W	x1,x2
	MOVE.W	y1,y2
	LEA	souris,A1
	MOVE.W 8(a1),X
	MOVE.W 10(a1),Y
	MOVE.W #160,LS
	MOVE.L #screen,SOURCE
	MOVE.L #FOND,DEST
	MOVE.W 12(A1),LD
	MOVE.W #0,XD
	MOVE.W #0,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it

	MOVE.W x1,XD
	MOVE.W y1,YD
	MOVE.L #screen,DEST
	MOVE.L 18(A1),SOURCE
	MOVE.W 4(A1),XS	
	MOVE.W 6(A1),YS
	MOVE.W 8(A1),X
	MOVE.W 10(A1),Y
	MOVE.W #2,LS
	MOVE.W #160,LD
	MOVE.W #4,PLAN
	MOVE.W #4,FONC
	MOVE.W #1,MASK
	BSR    blit_it
	MOVE.L (A1),SOURCE
	MOVE.W 12(A1),LS
	MOVE.W #4,PLAN
	MOVE.W #6,FONC
	MOVE.W #0,MASK
	BSR    blit_it
.finaffmouse
	RTS
**********************************************************************
FOND2
	MOVE.W	x2,XS
	MOVE.W	y2,YS
	LEA	souris,A1
	MOVE.W 8(a1),X
	MOVE.W 10(a1),Y
	MOVE.W #160,LS
	MOVE.L #screen,SOURCE
	MOVE.L #FOND,DEST
	MOVE.W 12(A1),LD
	MOVE.W #0,XD
	MOVE.W #0,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it
	RTS
**********************************************************************
RESTITU
	cmp.w	#0,okp
	bne.S	.finrestitu
	LEA	souris,A1
	MOVE.W 8(a1),X
	MOVE.W 10(a1),Y
	MOVE.W	#0,XS
	MOVE.W	#0,YS
	MOVE.W 12(A1),LS
	MOVE.L #FOND,SOURCE
	MOVE.L #screen,DEST
	MOVE.W #160,LD
	MOVE.W x2,XD
	MOVE.W y2,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it
.finrestitu
	RTS
******************************************************************************
TESTBORDS
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	y1,D0
	MOVE.W	SCREENY,D1
	CMP.W	D1,D0
	BGT.S	.SCRIN1
	MOVE.W	D0,SCREENY
	BRA.S	.SCRIN2
.SCRIN1	ADD.W	#200-15,D1
	CMP.W	D1,D0
	BLT.S	.SCRIN2
	SUB.W	#200-15,d0
	MOVE.W	D0,SCREENY
.SCRIN2	RTS
SCREENY	DC.W	0
**************************************************************************	
MOUSEIT	CMP.B	#$F7,$FFFFFC02.W
	BNE.S	.TSTKEY
	MOVE.L	#.IT2,$118.W
	RTE	
.TSTKEY	MOVE.B	$FFFFFC02.W,KEY
	RTE	
.IT2	MOVE.B	$FFFFFC02.W,km
	MOVE.L	#.IT3,$118.W
	RTE
.IT3	MOVE.B	$FFFFFC02.W,x1
	MOVE.L	#.IT4,$118.W
	RTE
.IT4	MOVE.B	$FFFFFC02.W,x1+1
	MOVE.L	#.IT5,$118.W
	RTE
.IT5	MOVE.B	$FFFFFC02.W,y1
	MOVE.L	#.IT6,$118.W
	RTE
.IT6	MOVE.B	$FFFFFC02.W,y1+1
	MOVE.L	#MOUSEIT,$118.W
	RTE

KEY	DC.B	0
	EVEN
**************************************************************************	
BLITTER        equ       $FF8A00
demiteinte     equ       0         
Src_Xinc       equ       32        
Src_Yinc       equ       34        
Src_Addr       equ       36        
Endmask1       equ       40        
Endmask2       equ       42        
Endmask3       equ       44        
Dst_Xinc       equ       46        
Dst_Yinc       equ       48        
Dst_Addr       equ       50        
largeur        equ       54        
hauteur        equ       56        
HOP            equ       58        
OP             equ       59        
Line_Num       equ       60        
Oblique        equ       61        
fHOP_Source   	equ       1
fHOP_demiteinte  	equ       0
fObliqueFXSR      	equ       7
fObliqueNFSR      	equ       6
fLineBusy      	equ       7
fLineHog       	equ       6
fLineSmudge    	equ       5
mHOP_Source    	equ       $02
mHOP_demiteinte  	equ       $01
mObliqueFXSR      	equ       $80
mObliqueNFSR      	equ       $40
mLineBusy      	equ       $80
mLineHog       	equ       $40
mLineSmudge    	equ       $20
lf_endmask
     dc.w      $FFFF
rt_endmask
     dc.w      $7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF			
     dc.w      $00FF,$007F,$003F,$001F,$000F,$0007,$0003,$0001,0			
blit_it:
	movem.l a0-a6/d0-d7,-(a7)
     lea       BLITTER,a5       
     lea	 PARA,a4
     move.w    WIDTH(a4),d6
     subq.w    #1,d6            
     move.w    SRC_XMIN(a4),d0  
     move.w    d0,d1            
     add.w     d6,d1            
     move.w    DST_XMIN(a4),d2  
     move.w    d2,d3            
     add.w     d6,d3            
     moveq     #$0F,d6          
     move.w    d2,d4            
     and.w     d6,d4            
     add.w     d4,d4            
     move.w    lf_endmask(pc,d4.w),d4
     move.w    d3,d5            
     and.w     d6,d5            
     add.w     d5,d5            
     move.w    rt_endmask(pc,d5.w),d5
     not.w     d5               
     move.w    d2,d7            
     and.w     d6,d7            
     and.w     d0,d6            
     sub.w     d6,d7            
     clr.w     d6               
     addx.w    d6,d6            
     lsr.w     #4,d0            
     lsr.w     #4,d1            
     sub.w     d0,d1            
     lsr.w     #4,d2            
     lsr.w     #4,d3            
     sub.w     d2,d3            
     bne.s     .set_endmasks     
     and.w     d5,d4            
     addq.w    #4,d6            
.set_endmasks:
     move.w    d4,Endmask1(a5)  
     move.w    #$FFFF,Endmask2(a5)
     move.w    d5,Endmask3(a5)  
     cmp.w     d1,d3            
     bne.s     .set_count        
     addq.w    #2,d6            
.set_count:
     move.w    d3,d4
     addq.w    #1,d4            
     move.w    d4,largeur(a5)   
     move.l    SRC_BASE(a4),a0  
     move.w    SRC_YMIN(a4),d4  
     move.w    SRC_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a0            
     move.w    SRC_NXWD(a4),d4  
     move.w    d4,Src_Xinc(a5)  
     mulu      d4,d0            
     add.l     d0,a0            
     mulu      d4,d1            
     sub.w     d1,d5            
     move.w    d5,Src_Yinc(a5)  
     move.l    DST_BASE(a4),a1  
     move.w    DST_YMIN(a4),d4  
     move.w    DST_NXLN(a4),d5  
     mulu      d5,d4            
     add.l     d4,a1            
     move.w    DST_NXWD(a4),d4  
     move.w    d4,Dst_Xinc(a5)  
     mulu      d4,d2            
     add.l     d2,a1            
     mulu      d4,d3            
     sub.w     d3,d5            
     move.w    d5,Dst_Yinc(a5)  
     and.b     #$0F,d7          	       
     or.b      Oblique_flags(pc,d6.w),d7  
     move.b    d7,Oblique(a5)      	
     move.b    #mHOP_Source,HOP(a5)	
     move.W	 FONC,d6
     move.b    d6,OP(a5)        		
     lea       Line_Num(a5),a2  		
     move.b    #6,d2    		;partage ou occupation du bus
     move.w    PLANES(a4),d7    		
     bra.s     begin
Oblique_flags:
     dc.b      mObliqueNFSR        
     dc.b      mObliqueFXSR        
     dc.b      0                   
     dc.b      mObliqueNFSR+mObliqueFXSR 
     dc.b      0                
     dc.b      mObliqueFXSR     
     dc.b      0                
     dc.b      0                
next_plane:
     move.l    a0,Src_Addr(a5)  		
     move.l    a1,Dst_Addr(a5)  		
     move.w    HEIGHT(a4),hauteur(a5)	
     move.b    #mLineBusy,(a2)  		
     CMP.W #1,MASK
     BEQ.S	.SSD
     add.w     SRC_NXPL(a4),a0  		
.SSD  add.w     DST_NXPL(a4),a1  		
.restart:
     bset.b    d2,(a2)          
     nop                        
     bne.s     .restart          
begin:
     dbra      d7,next_plane    
	movem.l (a7)+,a0-a6/d0-d7
     rts
MASK		 DC.W 	    0
SRC_BASE       equ       0
SRC_NXWD       equ       4
SRC_NXLN       equ       6
SRC_NXPL       equ       8
SRC_XMIN       equ      10
SRC_YMIN       equ      12
DST_BASE       equ      14
DST_NXWD       equ      18
DST_NXLN       equ      20
DST_NXPL       equ      22
DST_XMIN       equ      24
DST_YMIN       equ      26
WIDTH          equ      28
HEIGHT         equ      30
PLANES         equ      32
PARA	
SOURCE	dc.l	FOND
	dc.w	8
LS	dc.w   16
	dc.w   2
XS	dc.w  	0
YS	dc.w	100

DEST	dc.l	$F8000
	dc.w	8
LD	dc.w	160
	dc.w	2
XD	dc.w	0
YD	dc.w	0

X	dc.w	16
Y	dc.w	15
PLAN	dc.w	3
FONC	dc.w	3
*************************************************************************	
FILESELECT	
	MOVE.W	#1,okp
	RTS
FILESEL
	MOVEQ	#0,D0
	MOVE.B	DRV,D0
	SUB.B	#'A',D0
	CMP.B	#2,D0
	BGE.S	.HJ2
	MOVE.W	D0,-(A7)
	MOVE.W	#7,-(A7)
	TRAP	#13			* GET BPB
	ADDQ.W	#4,A7
	
.HJ2	LEA	DIR_FILES,A0
	MOVE.L	#1799,D0
	MOVEQ	#0,D1
.NET	MOVE.L	D1,(A0)+
	DBF	D0,.NET
	LEA	DIR_REP,A0
	MOVE.L	#319,D0
.NET2	MOVE.L	D1,(A0)+
	DBF	D0,.NET2

	MOVE.L	#ZERO,CURRENTREP
	MOVE.B	#'*',PATH+3
	MOVE.B	#'.',PATH+4
	MOVE.B	#'*',PATH+5
	MOVE.B	#0,PATH+6
	MOVE.L	#ADD_FIL+4,POINTFIL
	MOVE.L	#ZERO,ADD_REP
	MOVE.L	#DIR_REP,ADD_REP+4
	MOVE.L	#DIR_FILES,ADD_FIL
	MOVE.L	#DIR_FILES,ADD_FIL+4
	MOVE.L	#DIR_FILES,ADD_DEB_THIS_REP
	MOVE.B	#0,NBREP
	MOVE.B	#0,NUMREP
	LEA	DIR_FILES,A2

	PEA	DTA_BUFFER
	MOVE.W	#$1A,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP

REPRISE	MOVE.W	#$19,-(SP)
	PEA	PATH
	MOVE.W	#$4E,-(SP)
	TRAP	#1
	ADDA.L	#8,A7
.TINU	BSR	STOCKAGE
	MOVE.W	#$4F,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	TST.W	D0
	BEQ.S	.TINU
	MOVE.L	POINTFIL,A0
	MOVE.L	A2,(A0)+
	MOVE.L	A0,POINTFIL
	ADDQ.B	#1,NUMREP
	MOVE.B	NBREP,D0
	CMP.B	#0,D0
	BEQ.S	FIN1
	CMP.B	NUMREP,D0
	BLT.B	FIN1
	MOVEQ	#0,D0
	MOVE.B	NUMREP,D0
	ADD.L	D0,D0
	ADD.L	D0,D0
	LEA	ADD_REP,A0
	ADD.L	D0,A0
	MOVE.L	(A0),A0
	MOVE.L	A0,CURRENTREP
	LEA	PATH+3,A1
	MOVE.W	#60,D0
.NET1	CLR.B	(A1)+
	DBF	D0,.NET1
	LEA	PATH+3,A1
.VF	TST.B	(A0)
	BEQ.S	.FV
	MOVE.B	(A0)+,(A1)+
	BRA.S	.VF
.FV	MOVE.B	#'*',(A1)+
	MOVE.B	#'.',(A1)+
	MOVE.B	#'*',(A1)+
	MOVE.L	A2,ADD_DEB_THIS_REP
	BRA	REPRISE

FIN1	MOVE.B	#0,NUMREP		* 1 er DIRECTORY
	MOVE.W	#1,CHANGREP		* C'EST UN NOUVEAU DIRECTORY
	BSR	SORT
	BSR	AFF_FS
	MOVE.W	#0,okp
	RTS


STOCKAGE
	CMP.B	#$10,DTA_BUFFER+21		*TEST ATTRIBUT
	BEQ.S	REPERT

;	LEA	maskavr+2,A4
;	LEA	DTA_BUFFER+30,A1
;	MOVEQ	#8,D0
;PAS_PT	CMP.B	#'.',(A1)+
;	BEQ.S	POINT
;	DBF	D0,PAS_PT
;	BRA.S	LA
;
;POINT	MOVE.B	(A1),D0
;	MOVE.B	(A4),D2
;	CMP.B	D0,D2
;	BNE.S	SUIVANT
;	MOVE.B	1(A1),D0
;	MOVE.B	1(A4),D2
;	CMP.B	D0,D2
;	BNE.S	SUIVANT
;	MOVE.B	2(A1),D0
;	MOVE.B	2(A4),D2
;	CMP.B	D0,D2
;	BNE.S	SUIVANT
;	BRA.S	C_UN_BON
;SUIVANT	ADDQ.W	#6,A4
;	CMP.B	#-1,(A4)
;	BEQ.S	LA
;	BRA.S	POINT	
;C_UN_BON
	MOVE.B	#$20,(A2)+
	MOVE.B	NUMREP,(A2)+
	LEA	DTA_BUFFER+30,A1		*NOM FICHIER
	MOVE.L	(A1)+,(A2)+
	MOVE.L	(A1)+,(A2)+
	MOVE.L	(A1)+,(A2)+
	LEA	DTA_BUFFER+26,A1		*TAILLE FICHIER
	MOVE.L	(A1)+,(A2)+
LA	LEA	DTA_BUFFER+30,A1
	MOVEQ	#$D,D0
.L0003:	CLR.B	(A1)+	
	DBF	D0,.L0003
	RTS

REPERT	LEA	DTA_BUFFER+30,A3
	CMP.B	#'.',(A3)
	BEQ.S	LA
	LEA	18(A2),A3
	LEA	(A2),A4
	LEA	18(A2),A2
	MOVE.L	ADD_DEB_THIS_REP,A5
.COPY	MOVE.L	-(A4),-(A3)
	CMP.L	A5,A3
	BGT.S	.COPY
	ADDQ.B	#1,NBREP
	LEA	DTA_BUFFER+30,A0
	MOVE.L	ADD_DEB_THIS_REP,A1
	LEA	ADD_REP,A3
	MOVEQ	#0,D0
	MOVE.B	NBREP,D0
	ADD.B	D0,D0	
	ADD.B	D0,D0
	ADD.L	D0,A3
	MOVE.L	(A3),A3
	MOVE.B	#'*',(A1)+
	MOVE.B	NBREP,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	#0,(A1)+
	MOVE.L	CURRENTREP,A0
.NUTI2	TST.B	(A0)
	BEQ.S	.ZRO2
	MOVE.B	(A0)+,(A3)+
	BRA.S	.NUTI2
.ZRO2	LEA	DTA_BUFFER+30,A0
.NUTI	TST.B	(A0)
	BEQ.S	.ZRO
	MOVE.B	(A0)+,(A3)+
	BRA.S	.NUTI
.ZRO	MOVE.B	#'\',(A3)+
	MOVE.B	#0,(A3)+

	LEA	ADD_REP,A0
	ADDQ.L	#4,D0
	ADD.L	D0,A0
	MOVE.L	A3,(A0)
	BRA	LA


DTA_BUFFER	DS.B	44
DEFAULT		DC.L	0,0,0,0,0
POINTFIL	DC.L	0		*POINTEUR TABLE ADD_FIL
PATH		DC.B	'A:\*.*'
		DS.B	64
AFFICHAGE	DC.B	'A:\*'
		DS.B	64+12		*CHEMIN+NOMFICH
MASQUE		DC.B	'*.SPL',0
FILE_LOADED	DC.B    '*.SPL',0
NUMREP		DC.B	0
NBREP		DC.B	0
CURRENTREP	DC.L	0
ADD_DEB_THIS_REP DC.L   0
ZERO		DC.W	0
	EVEN
*************************************************************************
AFF_FS
	LEA	FILES,A0
	MOVEQ	#22,D0
.CLEAN3	MOVE.B	#0,(A0)+
	DBF	D0,.CLEAN3
	LEA	FILES_TO_SORT,A1
	MOVE.L	#screen+160*25+46,where
	MOVEQ	#17,D2
	CMP.W	#1,IN_MOD
	BEQ.S	AFF_FILE_MOD
.NB1	MOVE.L	where,A2
	MOVEQ	#0,D0
	LEA	FILES,A0
	MOVE.B	(A1)+,D0
	MOVE.B	D0,D6
	BCLR	#0,D0
	MOVE.B	D0,(A0)+
	ADDQ.L	#1,A0
	ADDQ.L	#1,A1
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,(A0)+
	MOVE.L	(A1)+,D0
	ADDQ.L	#1,A0
	BSR	CONVERT_HEXA_DECIASCII
	ADDQ.L	#7,A0
	LEA	FILES,A0
	MOVE.W	#0,compt2
	MOVEQ	#22,D1
	BSR	PRINT
	BTST	#0,D6
	BEQ.S	.PAS_INVERT
	BSR	INVERT3
.PAS_INVERT
	ADD.L	#72+160*8,where
	DBF	D2,.NB1
	RTS

AFF_FILE_MOD
	LEA	BUFMOD+20,A0
	MOVEQ	#0,D0
	MOVE.W	P_MOD,D0
	MULU	#30,D0
	ADD.L	D0,A0
.PSSOU	MOVE.W	#0,compt2
	MOVEQ	#22,D1
	MOVE.L	where,A2
	BSR	PRINT
	CMP.B	#1,24(A0)
	BNE.S	.SPOU
	BSR	INVERT3
.SPOU	ADD.L	#72+160*8,where
	LEA	30(A0),A0
	DBF	D2,.PSSOU
	RTS
	
FILES	DS.B	23
DEJA_REP	DC.W	0
*************************************************************************
SORT
	CMP.W	#1,CHANGREP
	BNE.S	NOT_INIT_REP
	BSR	INIT_REP
NOT_INIT_REP
	LEA	MASQUE+1,A0
	LEA	FILES_TO_SORT,A4
	MOVEQ	#80,D0
	MOVEQ	#0,D1
.CLEAN2	MOVE.L	D1,(A4)+
	DBF	D0,.CLEAN2	
	LEA	FILES_TO_SORT,A4
	MOVEQ	#0,D0
	MOVE.L	P_IN_CUR_FIL_DEB,A2
	MOVE.W	#-1,NB
	MOVE.W	#0,DEJA_REP
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#12,D2
.HERE_NEXT
	BSR.S	VERIFY
	CMP.L	#-1,D2			* Y A PLUS DE FICHIER = MASQUE ?
	BEQ.S	.ENDTHE			* SI OUI => THE END
	MOVEQ	#12,D2
	LEA	MASQUE+1,A0
	LEA	18(A2),A2
	;MOVE.W	NB_PAGE_FIN,D0
	;MOVE.W	NNB2,D1
	;CMP.B	D1,D0
	;BGT.S	.ENDTHE
	CMP.W	#17,NB
	BNE.S	.HERE_NEXT
.ENDTHE	MOVE.W	#0,DEJA_REP
	MOVE.L	A2,P_IN_CUR_FIL_FIN
	RTS


VERIFY	MOVE.L	A2,A3
	CMP.B	#'*',(A3)
	BEQ.S	.C_EST_UN_REP
	CMP.B	#0,(A3)
	BEQ	NDTHE
	MOVE.B	1(A3),D0
	CMP.B	NUMREP,D0
	BNE	NDTHE
	MOVE.W	#1,DEJA_REP
	ADDQ.L	#2,A3
	MOVE.L	A3,A5
.REPARTI	CMP.B	(A3)+,(A0)+		*TEST SI = AU MASQUE
	BNE.S	.PAS_BON
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON
	ADDQ.W	#1,NB
	ADDQ.W	#1,NB_PAGE_FIN
	MOVEQ	#0,D3
	MOVE.W	NB,D3
	ADD.L	D3,D3
	ADD.L	D3,D3
	LEA	PILEADD,A5
	ADD.L	D3,A5
	MOVE.L	A2,(A5)
	MOVE.L	A2,A3
	MOVE.L	(A3)+,(A4)+		*C'EST = ALORS ON RECOPIE
	MOVE.L	(A3)+,(A4)+	
	MOVE.L	(A3)+,(A4)+	
	MOVE.L	(A3)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	BRA.S	WIZZ
.PAS_BON SUBQ.B	#1,D2
	BEQ.S	WIZZ
	LEA	MASQUE+1,A0
	ADDQ.L	#1,A5
	MOVE.L	A5,A3
	BRA.S	.REPARTI
.C_EST_UN_REP
	CMP.W	#1,DEJA_REP
	BEQ.S	WIZZ
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	MOVE.L	#0,(A4)+
	ADDQ.W	#1,NB
	ADDQ.W	#1,NB_PAGE_FIN
	MOVEQ	#0,D3
	MOVE.W	NB,D3
	ADD.L	D3,D3
	ADD.L	D3,D3
	LEA	PILEADD,A5
	ADD.L	D3,A5
	MOVE.L	A2,(A5)
WIZZ	RTS
NDTHE	MOVEQ	#-1,D2
	RTS

INIT_REP
	MOVE.W	#0,NNB2
	MOVE.W	#0,NB_PAGE_DEB
	MOVE.W	#0,NB_PAGE_FIN
	LEA	MASQUE+1,A0
	MOVEQ	#0,D0
	MOVE.B	NUMREP,D0
	ADD.L	D0,D0
	ADD.L	D0,D0
	LEA	ADD_REP,A1
	ADD.L	D0,A1
	MOVE.L	D0,D7
	MOVE.L	(A1),A1
	LEA	PATH+3,A2
	MOVE.W	#60,D1
.CLEAN7	MOVE.B	#0,(A2)+
	DBF	D1,.CLEAN7
	LEA	PATH+3,A2
.GGOTO2	TST.B	(A1)
	BEQ.S	.GGOTO1
	MOVE.B	(A1)+,(A2)+
	BRA.S	.GGOTO2
.GGOTO1	MOVEQ	#22,D1
	LEA	PATH+3,A0
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt2
	BSR	PRINT
	LEA	ADD_FIL,A1
	ADD.L	D7,A1
	MOVE.L	(A1),A1
	MOVE.L	A1,CURENT_FIL
	MOVE.L	A1,P_IN_CUR_FIL_DEB
	LEA	-18(A1),A4
.NEXT2	LEA	18(A4),A4
	MOVE.L	A4,A1
	CMP.B	#'*',(A1)
	BEQ.S	.REP2
	CMP.B	#0,(A1)
	BEQ	WIZZ
	MOVE.B	NUMREP,D0
	CMP.B	1(A1),d0
	BNE	WIZZ
	MOVE.W	#1,DEJA_REP
	MOVEQ	#12,D2
	ADDQ.L	#2,A1
	MOVE.L	A1,A5
.REPART2	CMP.B	(A1)+,(A0)+
	BNE.S	.PAS_BON2
	CMP.B	(A1)+,(A0)+
	BNE.S	.PAS_BON2
	CMP.B	(A1)+,(A0)+
	BNE.S	.PAS_BON2
	CMP.B	(A1)+,(A0)+
	BNE.S	.PAS_BON2
	ADDQ.W	#1,NNB2
	BRA.S	.NEXT2
.PAS_BON2
	SUBQ.B	#1,D2
	BEQ.S	.NEXT2
	LEA	MASQUE+1,A0
	ADDQ.L	#1,A5
	MOVE.L	A5,A1
	BRA.S	.REPART2
.REP2	CMP.W	#1,DEJA_REP
	BEQ	WIZZ
	ADDQ.W	#1,NNB2
	BRA.S	.NEXT2

NB		DC.W	0		
NNB2		DC.W	0		*NB DE FICHIERS = MASQUE DANS REP
FILES_TO_SORT	DS.B	18*22
PILEADD 	DS.L	22
CHANGREP	DC.W	0		*CHANGEMENT DE REP ? 1 = OUI
CURENT_FIL	DC.L	0		*ADRESSE DU DEBUT DES FILES DANS CE REP
P_IN_CUR_FIL_DEB DC.L	0		*ADRESSE DU 1 ER FILE AFFICHE
P_IN_CUR_FIL_FIN DC.L	0
NB_PAGE_DEB	DC.W	0		*NUMERO,DANS LE REP ACTUEL, DU 1 ER FILE AFFICHE
NB_PAGE_FIN	DC.W	0
QUE_FAIRE	DC.W	0		* + = ON DESCEND DANS LE FILESELECT
					* - = ON MONTE
*************************************************************************
SCROLL_FILESELECT
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+86*160+23,where
	move.w	#1,compt2
	BSR	PRINT
	CMP.W	#1,IN_MOD
	BEQ	SCROLL_MOD
	LEA	MASQUE+1,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVE.W	QUE_FAIRE,D0
	MOVE.W	NNB2,D1
	CMP.W	#0,D0
	BGE	ADDITION
.SOUSTR	MOVE.W	NB_PAGE_DEB,D2
	CMP.W	#0,D2
	BEQ	RIEN_FAIRE
	CMP.W	#19,D2
	BGE.S	.NO_PRBM
	ADD.W	D2,D0
	CMP.W	#0,D0
	BGE.S	.NO_PRBM
	NEG.W	D0
	ADD.W	D0,QUE_FAIRE
.NO_PRBM
	MOVE.W	QUE_FAIRE,D0
	MOVE.W	NB_PAGE_DEB,D2
	ADD.W	D0,D2
	LEA	FILES_TO_SORT,A4
	MOVEQ	#80,D4
	MOVEQ	#0,D5
.CLEAN1	MOVE.L	D5,(A4)+
	DBF	D4,.CLEAN1	
	LEA	FILES_TO_SORT,A4
	MOVE.W	#-1,NB
	MOVEQ	#0,D0
	MOVEQ	#0,D3
	MOVE.B	NUMREP,D0
	ADD.L	D0,D0
	ADD.L	D0,D0
	LEA	ADD_FIL,A2
	ADD.L	D0,A2
	MOVE.L	(A2),A2

.VER1	MOVEQ	#12,D3
	MOVE.L	A2,A3
	CMP.B	#'*',(A3)
	BEQ.S	.UN_REP
	MOVE.B	1(A3),D0
	CMP.B	NUMREP,D0
	BNE.S	.DTHE
	ADDQ.L	#2,A3
	MOVE.L	A3,A5
.REPAR	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON3
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON3
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON3
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON3
	ADDQ.W	#1,NB
	BRA.S	.WIZZ1
.PAS_BON3 SUBQ.B	#1,D3
	BEQ.S	.WIZZ1
	LEA	MASQUE+1,A0
	ADDQ.L	#1,A5
	MOVE.L	A5,A3
	BRA.S	.REPAR
.UN_REP	ADDQ.W	#1,NB
.WIZZ1	CMP.W	NB,D2
	BEQ.S	.DTHE
	LEA	18(A2),A2
	BRA.S	.VER1
.DTHE	MOVE.W	NB,NB_PAGE_DEB
	MOVE.W	NB,NB_PAGE_FIN
	MOVE.L	A2,P_IN_CUR_FIL_DEB
	BRA	NOT_INIT_REP
RIEN_FAIRE
	RTS

ADDITION
	CMP.W	#18,D1
	BLT	NO_EXIT
	MOVE.W	NB_PAGE_FIN,D2
	SUBQ.W	#1,D2
	CMP.W	D2,D1
	BEQ	NO_EXIT
	MOVE.W	NB_PAGE_FIN,D2
	;SUBQ.W	#1,D2
	SUB.W	D2,D1
	CMP.W	#18,D1
	BGE.S	.PAS_DE_PRBM
	CMP.W	D1,D0
	BLE.S	.PAS_DE_PRBM
	MOVE.W	NNB2,D1
	ADD.W	D0,D2			* QUE_FAIRE + NB_PAGE_FIN
	SUB.W	D2,D1			* - NB DE FILE RESTANT
	NEG.W	D1
	SUB.W	D1,D0			* D0=NB DE FILE A SAUTER
.PAS_DE_PRBM
	LEA	FILES_TO_SORT,A4
	MOVEQ	#80,D4
	MOVEQ	#0,D5
.CLEAN4	MOVE.L	D5,(A4)+
	DBF	D4,.CLEAN4
	LEA	FILES_TO_SORT,A4
	MOVE.L	#PILEADD,A2
	MOVEQ	#0,D3
	MOVE.W	D0,D3
	ADD.L	D3,D3
	ADD.L	D3,D3
	ADD.L	D3,A2
	MOVE.L	(A2),A2
	MOVE.L	A2,P_IN_CUR_FIL_DEB
	ADD.W	D0,NB_PAGE_DEB
	MOVE.W	NB_PAGE_DEB,NB_PAGE_FIN
	
	MOVE.W	#-1,NB
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#12,D2
.HERE_NEXT1
	BSR	VERIFY
	CMP.L	#-1,D2
	BEQ.S	.ENDTHE1
	MOVEQ	#12,D2
	LEA	MASQUE+1,A0
	LEA	18(A2),A2
	;MOVE.W	NB_PAGE_FIN,D0
	;MOVE.W	NNB2,D1
	;CMP.B	D1,D0
	;BGT.S	ENDTHE1
	CMP.W	#17,NB
	BNE.S	.HERE_NEXT1
.ENDTHE1	MOVE.L	A2,P_IN_CUR_FIL_FIN
	RTS

SCROLL_MOD
	CMP.W	#17,MAX_INS
	BLE.S	.RETOUR_
	MOVEQ	#0,D0
	MOVE.W	QUE_FAIRE,D0
	CMP.W	#0,D0
	BMI.S	.NNEG

	ADD.W	D0,P_MOD	*POSITIF
	MOVE.W	P_MOD,D0
	MOVE.W	MAX_INS,D1
	SUB.W	#18,D1
	CMP.W	D0,D1
	BGT.S	.RETOUR_
	MOVE.W	MAX_INS,P_MOD
	SUB.W	#18,P_MOD
	BRA.S	.RETOUR_

.NNEG	ADD.W	D0,P_MOD
	MOVE.W	P_MOD,D0
	CMP.W	#0,D0
	BGE.S	.RETOUR_
	MOVE.W	#0,P_MOD
.RETOUR_ RTS
*************************************************************************
TEST_FILE
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+86*160+23,where
	move.w	#1,compt2
	BSR	PRINT
	CMP.W	#1,IN_MOD
	BEQ	TEST_MOD
	MOVEQ	#0,D0
	MOVE.W	y1,D0
	SUB.L	#25,D0
	DIVU	#9,D0
	LEA	FILES_TO_SORT,A0
	LEA	PILEADD,A1
	LEA	screen+46,A2
	SWAP	D0
	MOVE.W	#0,D0
	SWAP	D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	MULU	#18,D1
	ADD.L	D1,A0
	CMP.B	#'*',(A0)
	BEQ	OH_UN_REP
	CMP.W	#2,EH_NON
	BEQ.S	.YA_PRBM
	CMP.W	#1,EH_NON
	BNE.S	.NICHT_PRBM
	MOVE.W	#2,EH_NON
.NICHT_PRBM
	MOVEQ	#0,D3
	MOVE.B	(A0),D3
	BCHG	#0,D3
	MOVE.B	D3,(A0)
	ADD.L	D0,D0
	ADD.L	D0,D0
	ADD.L	D0,A1
	MOVE.L	(A1),A1
	MOVE.L	A1,ADD_MOD
	MOVE.B	(A1),D3
	BCHG	#0,D3
	MOVE.B	D3,(A1)
	MULU	#9,D2
	ADD.L	#25,D2
	MULU	#160,D2
	ADD.L	D2,A2
	BSR	INVERT3
	RTS

.YA_PRBM	BTST.B	#0,(A0)
	BEQ.S	.WQA
	MOVE.W	#1,EH_NON
	BRA.S	.NICHT_PRBM
	
.WQA	LEA	FILES_TO_SORT,A3
	MOVEQ	#18,D4
	LEA	screen+46+25*160,A2

.WQS	BTST.B	#0,(A3)
	BEQ.S	.WQZ
	BSR	INVERT3
	BCLR.B	#0,(A3)	
.WQZ	LEA	18(A3),A3
	ADD.L	#160*9,A2
	DBF	D4,.WQS

	MOVE.L	ADD_MOD,A3
	BCLR.B	#0,(A3)
	LEA	screen+46,A2
	BRA	.NICHT_PRBM
	


ADD_MOD	DC.L	0

OH_UN_REP
	ADDQ.B	#1,POINREP
	LEA	PILEREP,A1
	MOVEQ	#0,D0
	MOVE.B	POINREP,D0
	ADD.L	D0,D0
	ADD.L	D0,D0
	ADD.L	D0,A1
	MOVE.B  1(A0),(A1)
	MOVE.B	1(A0),NUMREP
	MOVE.W	#1,CHANGREP
	MOVE.W	#8,okp
	RTS
TRI	BSR	SORT
	BSR	AFF_FS
	bsr	FOND2
	MOVE.W	#0,okp
	RTS

TEST_MOD
	MOVEQ	#0,D0
	MOVE.W	y1,D0
	SUB.L	#25,D0
	DIVU	#9,D0
	LEA	BUFMOD+20,A0
	LEA	screen+46,A2
	SWAP	D0
	MOVE.W	#0,D0
	SWAP	D0
	MOVE.L	D0,D2
	ADD.W	P_MOD,D0
	MOVE.L	D0,D1
	MULU	#30,D1
	ADD.L	D1,A0
	BCHG.B	#0,24(A0)
	MULU	#9,D2
	ADD.L	#25,D2
	MULU	#160,D2
	ADD.L	D2,A2
	BSR.S	INVERT3
	RTS

INVERT3	MOVEQ	#6,D3
.INVERT1	NOT.B	1(A2)
	NOT.W	8(A2)
	NOT.W	16(A2)
	NOT.W	24(A2)
	NOT.W	32(A2)
	NOT.W	40(A2)
	NOT.W	48(A2)
	NOT.W	56(A2)
	NOT.W	64(A2)
	NOT.W	72(A2)
	NOT.W	80(A2)
	NOT.B	88(A2)
	LEA	160(A2),A2
	DBF	D3,.INVERT1
	RTS

EH_NON	DC.W	0
PILEREP	DS.B	10
POINREP	DC.B	0
	EVEN
*************************************************************************
EXIT_REP
	CMP.W	#1,IN_MOD
	BEQ.S	EXIT_MOD
	CMP.B	#0,POINREP
	BEQ.S	NO_EXIT
	SUBQ.B	#1,POINREP
	LEA	PILEREP,A0
	MOVEQ	#0,D0
	MOVE.B	POINREP,D0
	ADD.L	D0,D0
	ADD.L	D0,D0
	ADD.L	D0,A0
	MOVE.B	(A0),NUMREP
	MOVE.W	#0,EH_NON
	MOVE.W	#1,CHANGREP
	MOVE.W	#8,okp
NO_EXIT	RTS
EXIT_MOD
	MOVE.W	#0,IN_MOD
	SUBQ.W	#1,EH_NON
	MOVE.W	#1,CHANGREP	
	MOVE.W	#8,okp
	RTS
*************************************************************************
ADD1FS	MOVE.W	#1,QUE_FAIRE
	BRA.S	SCROLL
ADD18FS MOVE.W	#17,QUE_FAIRE
	BRA.S	SCROLL
SUB1FS	MOVE.W	#-1,QUE_FAIRE
	BRA.S	SCROLL
SUB18FS MOVE.W	#-17,QUE_FAIRE
SCROLL	MOVE.W	#0,DEJA_REP
	MOVE.W	#7,okp
	RTS
SCROL
	BSR	SCROLL_FILESELECT
	BSR	AFF_FS
	bsr	FOND2
	MOVE.W	#0,okp
	RTS
*************************************************************************
BEGIN
	MOVE.L	A7,A5
	MOVE.L	4(A5),A5
	MOVE.L	$C(A5),D0
	ADD.L	$14(A5),D0
	ADD.L	$1C(A5),D0
	ADD.L	#$100,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#1
	ADD.L	#12,A7
	
	DC.W	$A000			* RECHERCHE ADD FONT SYS
	MOVE.L	-$1C4(A0),A0
	MOVE.L	$4C(A0),ADDFONT
	
	MOVE.W	#$19,-(A7)		* DGETDRIVE
	TRAP 	#1
	ADDQ.L	#2,A7
	ADD.W	#'A',D0
	MOVE.B	D0,PATH
	MOVE.B	D0,AFFICHAGE
	MOVE.B	D0,DRV
	;CLR.W	-(A7)
	;PEA	PATH+2
	;MOVE.W	#$47,-(A7)		*DGETPATH
	;TRAP	#1
	;ADDQ.L	#8,A7
	PEA	MOUSEABS		*INIT MOUSE ABSOLUTE
	MOVE.W	#8,-(A7)
	MOVE.W	#25,-(A7)
	TRAP	#14
	ADDQ.L	#8,A7
	move.l	#pile2,-(a7)		*SUPERVISOR
	move.w	#$20,-(a7)
	trap #1
	move.l	d0,pile
	bsr	FRE
	LEA	PATH,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+86*160+23,where
	move.w	#1,compt2
	BSR	PRINT
	move.w	#2,-(a7)
	trap	#14
	addq.l 	#2,a7
	move.l 	d0,ecran
	move.w	#4,-(a7)
	trap	#14
	addq.l 	#2,a7
	move.w	d0,rezo
	move.w	#0,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap #14
	add.l	#12,a7
	dc.w	$a00a
	bclr	#0,$484.w
	
	lea	palet,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l (a0)+,(a1)+
	endr

	move.w  #$48b,d0    ;aigu maxi-1
        bsr	PLAY_SAMP
        ;move.w	#$446,d0    ;grave med
        ;bsr   	PLAY_SAMP
	BSR	INITMEG
	MOVE.W	x1,XS
	MOVE.W	y1,YS
	LEA     souris,A1
	MOVE.W 8(a1),X
	MOVE.W 10(a1),Y
	MOVE.W #160,LS
	MOVE.L #screen,SOURCE
	MOVE.L #FOND,DEST
	MOVE.W 12(A1),LD
	MOVE.W #0,XD
	MOVE.W #0,YD
	MOVE.W #4,PLAN
	MOVE.W #3,FONC
	BSR	blit_it
	MOVE.W	#0,XS
	MOVE.W	#0,YS
	MOVE.W	#8,LS
	MOVE.W	#8,X
	MOVE.W	#7,Y
        MOVE.L	#FLECHEGAUCHE,SOURCE
        MOVE.L	#screen,DEST
        MOVE.W	#160,LD
        MOVE.W	#26,XD
        MOVE.W	#73,YD
        BSR	blit_it
	BSR	AFFPATTERN2
	lea	char3,a0
	move.l  #screen+32000+17*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT	
	lea	char3,a0
	move.l  #screen+32000+25*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	lea	char3,a0
	move.l  #screen+32000+9*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	lea	char3,a0
	move.l  #screen+32000+33*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	lea	char3,a0
	move.l  #screen+32000+41*160+63,where
	move.w	#1,compt2
	moveq	#3,d1
	bsr	PRINT
	bsr	OPTI
	MOVE.W	#4,VOICE0+24
	MOVE.L	#FRQ_PREPA,VOICE0+26
	LEA	VOLUM,A0
	MOVE.L	A0,D0
	MOVE.B	#0,D0
	MOVE.L	D0,A1
	MOVE.L	D0,VOLUME
	MOVE.W	#64*256-1,D0
.SIG	MOVE.B	(A0)+,(A1)+
	DBF	D0,.SIG
	

	MOVE.W	#$2700,SR
	MOVE.L	$118.w,s118
	move.l	$70.w,s70
	MOVE.b	$FFFFFA17.w,S117
	BCLR	#3,$FFFFFA17.w
	MOVE.L	#MOUSEIT,$118.w
TEST_DAC
	LEA		$FFFF8901.W,A0
	MOVE.L		#MUSDEB,D0
	MOVEP.L	D0,(A0)
	MOVE.L 	#MUSFIN,D0
	MOVEP.L	D0,12(A0)
	MOVE.W	#DAC_FRQ+128,$FFFF8920.W  	* 25 khz	mono
	MOVE.W	#$7FF,$FFFF8924.W
	MOVE.W	#$486,$FFFF8922.W
	MOVE.W	#0,COMPT
	MOVE.W	#0,WAIT
	MOVE.L	#VBL_DAC,$70.W
	MOVE.W	#$2300,SR
.ON_ATTEND
	CMP.W	#1,WAIT
	BNE.S	.ON_ATTEND
	MOVE.L	POINT1,D0
	MOVE.L	POINT2,D1
	SUB.L	D0,D1
	SUBQ.W	#2,D1
	MOVE.W	D1,LEN1
	MOVE.L	POINT2,D0
	MOVE.L	POINT3,D1
	SUB.L	D0,D1
	MOVE.W	D1,LEN2
	MOVE.L	POINT3,D0
	MOVE.L	POINT4,D1
	SUB.L	D0,D1
	SUBQ.W	#3,D1
	MOVE.W	D1,LEN3
	MOVE.L	POINT4,D0
	MOVE.L	POINT5,D1
	SUB.L	D0,D1
	MOVE.W	D1,LEN4
	MOVE.L	POINT5,D0
	MOVE.L	POINT6,D1
	SUB.L	D0,D1
	MOVE.W	D1,LEN5
	MOVE.L	POINT6,D0
	MOVE.L	POINT7,D1
	SUB.L	D0,D1
	MOVE.W	D1,LEN6
	MOVE.L	POINT7,D0
	MOVE.L	POINT8,D1
	SUB.L	D0,D1
	MOVE.W	D1,LEN7
	
	MOVEQ	#0,D0
	MOVE.W	LEN1,D0
	ADD.W	LEN2,D0
	ADD.W	LEN3,D0
	ADD.W	LEN4,D0
	ADD.W	LEN5,D0
	ADD.W	LEN6,D0
	ADD.W	LEN7,D0
	DIVU	#7,D0
	MOVE.W	D0,LEN1
	MOVE.W	D0,LEN2
	MOVE.W	D0,LEN3
	MOVE.W	D0,LEN4
	MOVE.W	#0,D0
	SWAP	D0
	DIVU	#4,D0
	ADD.W	D0,LEN1
	ADD.W	D0,LEN2
	ADD.W	D0,LEN3
	ADD.W	D0,LEN4
	MOVE.W	#0,D0
	SWAP	D0
	ADD.W	D0,LEN2
	MOVE.W	LEN1,D0
	ADD.L	D0,SAV
	MOVE.W	#1,okp
	BSR	FILESEL
	JMP	niet

COMPT	DC.W	0
WAIT	DC.W	0

VBL_DAC
	MOVEM.L	D0/A0,-(A7)
	MOVE.W #3,$FFFF8900.W
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS2,$70.W
	RTE
.POS2	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT2
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS3,$70.W
	RTE
.POS3	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT3
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS4,$70.W
	RTE
.POS4	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT4
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS5,$70.W
	RTE
.POS5	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT5
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS6,$70.W
	RTE
.POS6	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT6
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS7,$70.W
	RTE
.POS7	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT7
	MOVEM.L	(A7)+,D0/A0
	MOVE.L	#.POS8,$70.W
	RTE
.POS8	MOVEM.L	D0/A0,-(A7)
	LEA	$FFFF8907.W,A0
	MOVEP.L	0(A0),D0
	AND.L	#$FFFFFF,D0
	MOVE.L	D0,POINT8
	MOVE.W	#0,$FFFF8900.W
	MOVE.W	#1,WAIT
	MOVEM.L	(A7)+,D0/A0
	move.l	#setscreen,$70.W
	RTE
POINT1	DC.L	MUSDEB
POINT2	DC.L	0
POINT3	DC.L	0
POINT4	DC.L	0
POINT5	DC.L	0
POINT6	DC.L	0
POINT7	DC.L	0
POINT8	DC.L	0
LEN1	DC.W	0
LEN2	DC.W	0
LEN3	DC.W	0
LEN4	DC.W	0
LEN5	DC.W	0
LEN6	DC.W	0
LEN7	DC.W	0
*************************************************************************
ADDFONT	DC.L	0
AD	DC.B	3
	EVEN

dupliq	
	INCBIN	DATA\DUPLIQ

**************************************************************************
*	Table of (Scancode) to (number of sample)
AZERTY
* Pave alphanumerique
	dc.b	$10,0,$11,1,$12,2,$13,3,$14,4,$15,5,$16,6,$17,7,$18,8
	dc.b	$19,9,$1a,10,$1b,11,$1e,12,$1f,13,$20,14,$21,15,$22,16
	dc.b	$23,17,$24,18,$25,19,$26,20,$27,21,$28,22,$2c,23,$2d,24
	dc.b	$2e,25,$2f,26,$30,27,$31,28,$32,29,$33,30,$34,31
	dc.b	$35,32
* Pave numerique
	dc.b	$63,33,$64,34,$65,35,$66,36,$67,37,$68,38,$69,39
	dc.b	$4a,40,$6a,41,$6b,42,$6c,43,$4e,44,$6d,45,$6e,46,$6f,47
	dc.b	$72,48,$70,49,$71,50
* Numero du pave alphanumerique
	dc.b	254,51,2,52,3,53,4,54,5,55,6,56,7,57,8,58,9,59,$a,60,$b,61,$c,62,$d,63

**************************************************************************
FONCTION	
* Touches de fonctions  (inchangees)
	dc.b	$3b,8,$3c,9,$3d,10,$3e,11,$3f,12,$40,13,$41,14,$42,15,$43,16,$44,17
* Fleches 
	dc.b	$48,6,$4b,4,$50,7,$4d,5
	dc.b   	1,3			* TAB = ESC
	dc.b	$39,1			* Space bar
	dc.b	$62,2			* help
	dc.b	$61,20			* undo
	dc.b	$52,18,$47,19		* insert,clr home
	dc.l	-1

**************************************************************************
*	Table of (scancode) to (hexa -> Commande & Donnees)
DATA
	dc.b	$70,0,$6d,1,$6e,2,$6f,3,$6a,4,$6b,5
	dc.b	$6c,6,$67,7,$68,8,$69,9,$10,$A,$30,$B
	dc.b	$2E,$C,$20,$D,$12,$E,$21,$F
	dc.l	-1


**************************************************************************
*	Table of (scancode) to (number of note)
NOTE1
*	Octave 1
	dc.b	$2c,0,$1f,1,$2d,2,$20,3,$2e,4,$2f,5
	dc.b	$22,6,$30,7,$23,8,$31,9,$24,10,$32,11
*	octave 2
	dc.b	$33,12,$26,13,$34,14,$27,15,$35,16,$10,17
	dc.b	$3,18,$11,19,$4,20,$12,21,$5,22,$13,23
*	octave 3
	dc.b	$14,24,$7,25,$15,26,$8,27,$16,28,$17,29,$a,30,$18,31
	dc.b	$b,32,$19,33,$c,34,$1a,35
*	octave 4
	dc.b	$1b,36,$29,37
	dc.l	-1

**************************************************************************
*	Table of (number of note) to (note)
DIGINOTE1
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453 * $358
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113 * $71
	
	dc.w	107,101,095,090,085,080,075,071,067,063,060,056
	dc.w	053,050,047,045,042,040				* $28
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	107,101,095,090,085,080,075,071,067,063,060,056
	dc.w	053,050,047,045,042,040
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	106,100,094,089,084,079,075,071,067,063,059,056
	dc.w	053,050,047,044,042,040
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	105,099,094,088,083,078,074,070,066,063,059,055
	dc.w	053,050,047,045,042,040
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	104,098,092,087,082,078,073,069,065,063,058,055
	dc.w	052,049,046,043,041,039
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	103,097,092,087,082,077,073,069,065,061,058,054
	dc.w	051,048,046,043,041,039
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	102,096,091,086,081,077,072,068,064,061,057,054
	dc.w	051,048,046,043,040,038
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	102,096,090,085,080,076,072,068,064,060,057,054
	dc.w	051,048,045,042,040,038
	
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	113,107,101,095,090,085,080,075,071,067,063,060
	dc.w	056,053,050,047,045,042
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	112,106,100,094,089,084,079,075,071,067,063,059
	dc.w	056,053,050,047,044,042
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	111,105,099,094,088,083,079,074,070,066,062,059
	dc.w	056,053,050,047,044,042
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	111,104,099,093,088,083,078,074,070,066,062,059
	dc.w	056,052,049,047,044,042
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	110,104,098,092,087,082,078,073,069,065,061,058
	dc.w	055,052,049,046,043,041
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	109,103,097,092,087,082,077,073,069,065,061,058
	dc.w	055,051,049,046,043,041
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	108,102,096,091,086,081,077,072,068,064,061,057
	dc.w	054,051,048,046,043,041
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	108,101,099,090,085,080,076,072,068,064,060,057
	dc.w	054,051,048,045,043,040
	
TABLE_DIGINOTE	
	DC.L	DIGINOTE1,DIGINOTE1+108,DIGINOTE1+216,DIGINOTE1+324
	DC.L	DIGINOTE1+432,DIGINOTE1+540,DIGINOTE1+648,DIGINOTE1+756
	DC.L	DIGINOTE1+864,DIGINOTE1+972,DIGINOTE1+1080,DIGINOTE1+1188
	DC.L	DIGINOTE1+1296,DIGINOTE1+1404,DIGINOTE1+1512,DIGINOTE1+1620
***************************************************************************
*	Table of (number of note) to (note)
YAMNOTE1
*	Octave -3
	dc.w	3822,3607,3405,3214,3033,2863,2702,2551,2407,2272,2145,2024
*	Octave -2
	dc.w	1911,1803,1702,1607,1516,1431,1351,1275,1203,1136,1072,1012
*	Octave -1
	dc.w	955,901,851,803,758,715,675,637,601,568,536,506
*	Octave 0
	dc.w	477,450,425,401,379,357,337,318,300,284,268,253
*	Octave 1
	dc.w	238,225,212,200,189,178,168,159,150,142,134,126
*	Octave 2
	dc.w	119,112,106,100,94,89,84,79,75,71,67,63
*	Octave 3
	dc.w	59,56,53,50,47,44,42,39,37,35,33,31
*	Octave 4
	dc.w	29,28,26,25,23,22,21,19,18,17,16,15
	dc.w	0,0,0

**************************************************************************
DIGICORRES
	DC.B	'C-1','C#1','D-1','D#1','E-1'
	DC.B	'F-1','F#1','G-1','G#1','A-1','A#1','B-1'
	DC.B	'C-2','C#2','D-2','D#2','E-2'
	DC.B	'F-2','F#2','G-2','G#2','A-2','A#2','B-2'
	DC.B	'C-3','C#3','D-3','D#3','E-3'
	DC.B	'F-3','F#3','G-3','G#3','A-3','A#3','B-3'
	DC.B	'C-4','C#4','D-4','D#4','E-4'
	DC.B	'F-4','F#4','G-4','G#4','A-4','A#4','B-4'
	DC.B	'C-5','C#5','D-5','D#5','E-5','F-5'
	DC.B	-1,-1,-1,-1,-1
	EVEN

**************************************************************************
*	Table of scancode to AZERTY
SCANCODE
	DC.B	$10,'A',$11,'Z',$12,'E',$13,'R',$14,'T',$15,'Y',$16,'U',$17,'I',$18,'O',$19,'P',$1B,'*'
	DC.B    $1E,'Q',$1F,'S',$20,'D',$21,'F',$22,'G',$23,'H',$24,'J',$25,'K',$26,'L',$27,'M'
	DC.B	$2C,'W',$2D,'X',$2E,'C',$2F,'V',$30,'B',$31,'N',$32,'?'
	DC.B	$6D,'1',$6E,'2',$6F,'3',$6A,'4',$6B,'5',$6C,'6',$67,'7',$68,'8',$69,'9',$70,'0',$66,'*'
	DC.B	$1C,$D,$72,$D,$71,'.',$33,'.',$39,' ',$28,'\'
	DC.B	1,$FD,$53,$FC,$4B,$FB,$4D,$FA,$E,8,$53,8
	DC.B	-1,-1
**************************************************************************

txt	dc.b	" Mega Track",$d,$a
	dc.b    " By Axel F.",$d,$a
	DC.B	"A day he wasn't asleep",0

palet	dc.w	$0000,$0233,$0011,$0022,$0133,$0624,$0513,$0413
	dc.w	$0244,$0004,$0006,$0007,$0633,$0643,$0754,$0555
screen	incbin	C:\dessin\mtx1.img
	incbin	C:\dessin\mtx2.img
	incbin	C:\dessin\mtx3.img
	incbin	C:\dessin\mtx4.img
	*DS.L	40
VOLUME	DC.L	0
	DS.B	256
VOLUM		INCBIN	DATA\VOLUME.FOR
	IFNE	FRQ_25
FRQ		*DS.L	3
		INCBIN	DATA\25.KHZ\25_KHZ.FRQ
FRQ1W		*INCBIN	DATA\25.KHZ\FRQ1W
FRQ2W		*INCBIN	DATA\25.KHZ\FRQ2W
FRQ3W		INCBIN	DATA\25.KHZ\FRQ3W
VFRQ1W		*INCBIN	DATA\25.KHZ\VFRQ1W
VFRQ2W		*INCBIN	DATA\25.KHZ\VFRQ2W
VFRQ3W		INCBIN	DATA\25.KHZ\VFRQ3W
	RTS
D625R25 	*INCBIN	DATA\25.KHZ\D625R25
D625R125	*INCBIN	DATA\25.KHZ\D625R125
D625R625	*INCBIN	DATA\25.KHZ\D625R625
D125R625	*INCBIN	DATA\25.KHZ\D125R625
D625R25_ADD 	*INCBIN	DATA\25.KHZ\D625R25.A
D625R125_ADD	*INCBIN	DATA\25.KHZ\D625R125.A
D625R625_ADD	*INCBIN	DATA\25.KHZ\D625R625.A
D125R625_ADD	*INCBIN	DATA\25.KHZ\D125R625.A
D625R25_VOL 	*INCBIN	DATA\25.KHZ\D625R25.V
D625R125_VOL	*INCBIN	DATA\25.KHZ\D625R125.V
D625R625_VOL	*INCBIN	DATA\25.KHZ\D625R625.V
D125R625_VOL	*INCBIN	DATA\25.KHZ\D125R625.V
D625R25_VOL_ADD 	*INCBIN	DATA\25.KHZ\D625R25.VA
D625R125_VOL_ADD	*INCBIN	DATA\25.KHZ\D625R125.VA
D625R625_VOL_ADD	*INCBIN	DATA\25.KHZ\D625R625.VA
D125R625_VOL_ADD	INCBIN	DATA\25.KHZ\D125R625.VA
	RTS
	ENDC
	
	IFNE	FRQ_12
FRQ		DC.L	0
		INCBIN	DATA\12_5.KHZ\12_5KHZ.FRQ
FRQ1W		INCBIN	DATA\12_5.KHZ\FRQ1W
FRQ2W		INCBIN	DATA\12_5.KHZ\FRQ2W
FRQ3W		INCBIN	DATA\12_5.KHZ\FRQ3W
VFRQ1W		INCBIN	DATA\12_5.KHZ\VFRQ1W
VFRQ2W		INCBIN	DATA\12_5.KHZ\VFRQ2W
VFRQ3W		INCBIN	DATA\12_5.KHZ\VFRQ3W
	RTS
FRQ1L		INCBIN	DATA\12_5.KHZ\FRQ1L
FRQ2L		INCBIN	DATA\12_5.KHZ\FRQ2L
FRQ3L		INCBIN	DATA\12_5.KHZ\FRQ3L
VFRQ1L		INCBIN	DATA\12_5.KHZ\VFRQ1L
VFRQ2L		INCBIN	DATA\12_5.KHZ\VFRQ2L
VFRQ3L		INCBIN	DATA\12_5.KHZ\VFRQ3L
	RTS
D625R25 	*INCBIN	DATA\12_5.KHZ\D625R25
D625R125	INCBIN	DATA\12_5.KHZ\D625R125
D625R625	INCBIN	DATA\12_5.KHZ\D625R625
D125R625	INCBIN	DATA\12_5.KHZ\D125R625
D625R25_ADD 	*INCBIN	DATA\12_5.KHZ\D625R25.A
D625R125_ADD	INCBIN	DATA\12_5.KHZ\D625R125.A
D625R625_ADD	INCBIN	DATA\12_5.KHZ\D625R625.A
D125R625_ADD	INCBIN	DATA\12_5.KHZ\D125R625.A
D625R25_VOL 	;INCBIN	DATA\12_5.KHZ\D625R25.V
D625R125_VOL	;INCBIN	DATA\12_5.KHZ\D625R125.V
D625R625_VOL	;INCBIN	DATA\12_5.KHZ\D625R625.V
D125R625_VOL	;INCBIN	DATA\12_5.KHZ\D125R625.V
D625R25_VOL_ADD 	;INCBIN	DATA\12_5.KHZ\D625R25.VA
D625R125_VOL_ADD	;INCBIN	DATA\12_5.KHZ\D625R125.VA
D625R625_VOL_ADD	;INCBIN	DATA\12_5.KHZ\D625R625.VA
D125R625_VOL_ADD	*INCBIN	DATA\12_5.KHZ\D125R625.VA
	RTS
	ENDC

mousemask	include	data\copyb11.m
mousedat	incbin	data\copyb11.img

	******************************************
	*           tiens du blitter !!!!!       *
	******************************************

	*	NOM DU DESSIN SOURCE
	*	XS , YS = POSITION DANS DESSIN SOURCE
	*	X  , Y  = TAILLE DU BOB
	*	LS      = (LARGEUR DU DESSIN SOURCE)/2
	*	PLAN	 = NBR DE PLANS A TRANSFERER
	*	FONC	 : 3=REPLACE , 6=OR , 7=EOR
	*	NOM DU MASK
	*	XS,YS,X,Y,LS,PLAN,FONC
souris
	dc.l	mousedat
	dc.w	0,0,16,15,8,2,7
	dc.l	mousemask
FOND
	ds.b	130


FLECHEGAUCHE
*    pixels/scanline    = $0008 (bytes/scanline: $0008)
*  # scanlines (height) = $0007
		dc.w	$EF00,$1000,$1000,$1000,$CF00,$3800,$3000,$3000
		dc.w	$8300,$7C00,$7C00,$7C00,$FF00,$0200,$FC00,$FC00
		dc.w	$FF00,$0200,$7C00,$7C00,$CF00,$0E00,$3000,$3000
		dc.w	$EF00,$0800,$1000,$1000
FLECHEDROITE
		dc.w	$EF00,$1000,$1000,$1000,$E700,$1800,$1800,$1800
		dc.w	$8300,$7C00,$7C00,$7C00,$FF00,$0000,$7E00,$7E00
		dc.w	$FF00,$0300,$7C00,$7C00,$E700,$0600,$1800,$1800
		dc.w	$EF00,$0C00,$1000,$1000
FLECHEFOND
*    pixels/scanline    = $0009 (bytes/scanline: $0008)
*  # scanlines (height) = $0007
		dc.w	$FF00,$0000,$0080,$0000,$FF00,$0000,$0080,$0000
		dc.w	$FF00,$0000,$0080,$0000,$FF00,$0000,$0080,$0000
		dc.w	$FF00,$0000,$0080,$0000,$FF00,$0000,$0080,$0000
		dc.w	$FF00,$0000,$0080,$0000

CUR		EQU screen+32000+161*160+28
VOICE		EQU screen+32000+136*160+29
VOICED		EQU screen+32000+199*160+28
VOICEU		EQU screen+32000+136*160+28

PILEVOIE	DC.L	VOICE0,VOICE1,VOICE2,VOICE3,VOICE4,VOICE5
		DC.L	VOICE6,VOICE7,VOICE8,VOICE9,VOICE10

entete		dc.l	'MCS!'
svoies		dc.b	1		* nb de voies
sarrang		dc.b	0		* Voies arrangees ? (1=oui , 0=non)
ssv0		dc.b	0		* Style de voies
ssv1		dc.b	0		* 0 = rien
ssv2		dc.b	0		* 1 = Yamaha
ssv3		dc.b	0		* 2 = Drum
ssv4		dc.b	0		* 3 = Drum + Vol
ssv5		dc.b	0		* 4 = Frq.w
ssv6		dc.b	0		* 5 = Frq.w + Vol
ssv7		dc.b	0		* 6 = Frq.l
ssv8		dc.b	0		* 7 = Frq.l + Vol
ssv9		dc.b	0
ssv10		dc.b	0
sdigvoices	dc.b	1		* nb de voies digital
syamvoices	dc.b	0		* nb de voies yamaha
snbzic		dc.b	1		* nb de zics
smaxpatt	dc.b	0		* nb de patt
scvoies		dc.b	11*5		* nb d'octets par ligne
stotalsample	dc.b	0		* nb de sample en memoire
stotalyam	dc.b	0		* nb de son yamaha en memoire
slenzic		dc.w	0		* Longueur data zic
slenseq		dc.w	0		* Longueur des sequences
sonepatt	dc.w	11*5*64		* Longueur d'une patt
slentablespl	dc.w	0		* Longueur de la table des instruments
slentableyam	dc.w	0		* Longueur de la table des sons yam
saddzic		dc.l	0		* Add debut data zic (relatif)
saddseq		dc.l	0		* Add debut seq
slenpatt	dc.l	0		* Longueur des patt
saddpatt	dc.l	0		* Add debut patt
saddtablespl	dc.l	0		* Add table sample
saddtableyam	dc.l	0		* Add table des sons yam
slensamples	dc.l	0		* Longueur des samples
slenyams	dc.l	0		* Longueur des son yam
saddspl		dc.l	0		* Add debut spl+yam
					* = 70 octets

*************************************************************************	
	dc.b	'BNK!'
	SECTION BSS
	DS.B	2		* Nb SAMPLE & YAM
	DS.L	2		* Len DATA SAMPLE & YAM
	
*	Table of sample   (256 samples)
SAMPLE
*	A sample for the drum mode will be defined by :
*0	- 5.L	Name
*20	- 1.W   Mono or stereo,frequency
*22	- 1.L	Start   >
*26	- 1.L	Lenght  >=>  In relative with the start adress of the 
*30	- 1.L	End     >    module
*34	- 1.W	Loop or not
*36	- 1.L   If yes,where is the loop (relative)
*40     = end
	DS.L	10*256
YAMAHA
	DS.L	10*256
*************************************************************************	
*	1 VOIE DEFINIE PAR :
*0	2 OCTETS  : FREQUENCE (NOTE)
*2	4 OCTETS  : ADRESSE DE DEBUT
*6	4 OCTETS  : ADRESSE LOOP DEBUT
*10	4 OCTETS  : LONGUEUR LOOP
*14	4 OCTETS  : POINTEUR POSITION DANS LA VBL
*18	4 OCTETS  : LONGEUR RESTANTE
*22	2 OCTETS  : LOOP OR NOT
*24	2 OCTETS  : STYLE DE VOIE
*26	4 OCTETS  : ADRESSE DE LA ROUTINE QUI PREPARE LA VOIE
*30	2 OCTETS  : FRQ DU SAMPLE (SERT POUR UN DRUM)
*
* STYLE DE VOIE : 0 = RIEN   1 = YAMAHA
*	          2 = DRUM   3 = DRUM  + VOL
*		  4 = FRQ.W  6 = FRQ.W + VOL
*		  5 = FRQ.L  7 = FRQ.L + VOL

VOICE0		DS.B	66
VOICE1		DS.B	66
VOICE2		DS.B	66
VOICE3		DS.B	66
VOICE4		DS.B	66
VOICE5		DS.B	66
VOICE6		DS.B	66
VOICE7		DS.B	66
VOICE8		DS.B	66
VOICE9		DS.B	66
VOICE10		DS.B	66
*************************************************************************	
	
RIEN		DS.L	1024/4
	
MUSIQUE			
*	256 musiques possibles, reparties en sequences 
*	1.B = sa longeur
*	1.B = restart
	ds.w	256

SEQUENCE		* pour l'instant, 2 sequences
* 	La sequence correspond a la succession des patterns pour
*	former la musique. 1 octet = le numero de la pattern (0 -> 255)
	ds.b	256*2

*************************************************************************	

ADD_FIL		DS.L	50
ADD_REP		DS.L	50
DIR_FILES	DS.B	18*600
DIR_REP		DS.B	64*50

MUSDEB
	DS.B	4*508*(DAC_FRQ+1)
MUSFIN
	DS.B	20

NAME	ds.l	0
*	Name of bank if loaded	
NAMEBANK
	ds.l	3
*	Name of sample loaded	
NAMESAMPLE
	ds.b	13*256

*	Name of yamaha sound loaded
NAMEYAM
	ds.b	13*256
NAMEMUS
	ds.b	20
	
*	(1 pattern = 4 octets * 64 lignes * nb voies ) * nb patterns
PATTERNS
	ds.b	4*64*11*3
*	Sample
s1	

 
