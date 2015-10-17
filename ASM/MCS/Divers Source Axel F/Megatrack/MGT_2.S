 	*	Mega tracker
	*      By Axel Follet
	*   Started on the november,15th 1990
	*	Falcon Only

	*	8 digitals channels (stereo) at 50 khz (if spl 8 bits mono)
	*      12                               33 khz
	*      16                               25 khz
	*      18                               20 khz
	*      24                               16 khz
	*      32                               12 khz
	
	*  You can choose the number of the digitals channels,
	*  knowing that the less you have,the more time you leave free

	*  Cool, no ?
	NOP
	OPT	D+
	OPT	O-
DEMO		EQU	1		* 1 = DEMO
FINSAMPLE	EQU	640


F_TUNE_MGT	EQU	20		* B
MONO_MGT	EQU	21		* B
DEB_MGT		EQU	22		* L
LEN_MGT		EQU	26		* L
FIN_MGT		EQU	30		* L
VOL_MGT		EQU	34		* B
LOOP_MGT	EQU	35		* B
LOOP_DEB_MGT	EQU	36		* L
BIT1_MGT	EQU	40		* B
BIT2_MGT	EQU	41		* B
NOTE_MGT	EQU	42		* B
COMMAND_MGT	EQU	43		* B
PARAM_MGT	EQU	44		* B
VIDE_MGT	EQU	45		* B

LEN_SAMPLE_MGT	EQU	46


* rt11

	JMP	BEGIN
BEGIN2	
				*Ici va se derouler tous ce qui n'est
				*pas en VBL (fileselect,input)
niet
	CMP.W	#1,fin
	BEQ.S	da
	TST	okp
	BEQ.S	niet
	MOVEQ	#0,D0
	MOVE.W	okp,D0
	LEA	SAUT,A0
	MOVE.L	(A0,D0.W*4),A0
	JSR	(A0)
	BRA.S	niet

SAUT	DC.L	0,FILESEL,INPT2,0,CLRSAM1,CLRPAT1,SPLTSPE,SCROL,TRI,LOADE
	DC.L	SAUVE,AFFPATTERN2,EFFPAT2,PATTUP3,PATTUP4,PATTDOWN2
	DC.L	DIVIDE_2,DIVIDE_3,DIVIDE_4,L_SPL_MOD,DIVIDE_ALL_BY_2	* LAST = 20
****************************** FIN **********************************
da	JSR	RESTORE
	MOVE.W  #0,$FFFF8900.W
	MOVE.B	#8,$FFFFFC02.W
	MOVE.W	#$666,$FFFF8246.W
	BSR.L	CLRKEYB
	MOVE.W	rezo,-(a7)
	MOVE.W	#3,-(a7)
	MOVE.L	$44e.w,-(a7)
	MOVE.L	$44e.w,-(a7)
	MOVE.W	#5,-(a7)
	trap 	#14
	ADD.w	#14,a7
	MOVE.L	pile,-(a7)
	MOVE.W	#$20,-(a7)
	trap #1
	ADDQ.l	#6,a7
	bsr.l	CLRKEYB
	clr.l -(a7)
	trap #1
	IFNE	DEMO
MOUSEABS	DC.B	9,02,$80-16,3,$43-16,0,0,0,0
	ELSEIF
MOUSEABS	DC.B	9,02,$80-16,3,$43-16,0,0,0,0
	ENDC
	EVEN
*********************************************************************
MY_70	MOVE.W	#$2700,SR
	MOVE.B	#$D,$FFFFFC02.W
	MOVEM.L	D0-A6,-(a7)
	MOVE.W	compt2,-(a7)
	MOVE.L	where,-(a7)
	MOVEQ	#0,D0
	MOVE.W	SCREENY,D0
	MULU	#640,D0
	ADD.L	#screen,D0
	MOVE.L	D0,-(A7)
	MOVE.B	2(A7),$ffff8203.w
	MOVE.B	1(A7),$ffff8201.w
	MOVE.B	3(A7),$ffff820D.w
	ADDQ.W	#4,A7
	MOVE.W	#$2300,SR
	CLR.W	waiting
	
	CMP.W	#0,SPRITING
	BNE.S	.PO
	MOVE.W	#1,SPRITING
	JSR	RESTITU
	JSR	FOND2
	JSR	AFFMOUSE
	MOVE.W	#0,SPRITING
	
	
.PO	JSR	TESTBORDS
	
	TST.W	okp
	BNE.S	.P1
	BSR	POSMOUSE
	
.P1	MOVE.L	(A7)+,where
	MOVE.W	(A7)+,compt2
	MOVEM.L	(A7)+,D0-A6
	MOVE.W	#$2300,SR
	RTE
SPRITING	DC.W	0	
******************************************************************
MY_134	
	MOVE.L	COLOR,$FFFF9800.W
	JSR	DAC_SYNC
	MOVE.W	#$2300,SR
	MOVEM.L	D0-A6,-(A7)
	MOVE.W	compt2,-(a7)
	MOVE.L	where,-(a7)
	
	*MOVEC	CACR,D0
	*MOVE.W	D0,-(A7)
	
	CMP.W	#0,okp
	BNE.S	.POK2
	BSR	FONCT
	BSR.L	KEYB
.POK2	CMP.B	#1,playpat
	BNE.S	.bl1
	JSR	VBLPAT
.bl1	CMP.B	#1,record
	BNE.S	.bl2
	JSR	VBLRECORD
.bl2	CMP.B	#1,playsong
	BNE.S	.bl3
	JSR	VBLPAT
.bl3	JSR	JOUEDIGIT
	BSR	FREQUENCE_030
	
	*MOVE.L	#$FF0000,$FFFF9800.W
	*BSR	AFFPATTERN3
	*MOVE.W	(A7)+,D0
	*MOVEC	D0,CACR
	
	MOVE.L	(A7)+,where
	MOVE.W	(A7)+,compt2
	MOVEM.L	(A7)+,D0-A6
	MOVE.L	#0,$FFFF9800.W
	CMP.B	#1,ASK_OFF
	BNE.S	.GH
	MOVE.L	#RTE_134,$134.W
	MOVE.B	#2,ASK_OFF
.GH	RTE
***************************************************************************
FREQUENCE_030
	TST.B	CHANGE_FRQ
	BEQ	.RT11

	MOVE.B	#0,CHANGE_FRQ	
	CMP.L	#$49170,DAC_FRQ
	BNE.S	.NOT_50
	MOVE.L	#$0003007C,VAL
	MOVE.W	#1004,OFFSET_VAL
	MOVE.B	#1,CLK
	MOVE	#1152,D5
	BSR	GEN_FRQ
	BSR	BUFFER1
	
.NOT_50	CMP.L	#$32780,DAC_FRQ
	BNE.S	.NOT_33
	MOVE.L	#$00050052,VAL
	MOVE.W	#669,OFFSET_VAL
	MOVE.B	#2,CLK
	MOVE.L	#1728,D5
	BSR	GEN_FRQ
	BSR	BUFFER1
	
.NOT_33	CMP.L	#$24585,DAC_FRQ
	BNE.S	.NOT_25	
	MOVE.L	#$0006003D,VAL
	MOVE.W	#502,OFFSET_VAL
	MOVE.B	#3,CLK
	MOVE.L	#2304,D5
	BSR	GEN_FRQ
	BSR	BUFFER1
	
.NOT_25	CMP.L	#$19668,DAC_FRQ
	BNE.S	.NOT_20
	MOVE.L	#$00020031,VAL
	MOVE.W	#402,OFFSET_VAL
	MOVE.B	#4,CLK
	MOVE.L	#2880,D5
	BSR	GEN_FRQ
	BSR	BUFFER1

.NOT_20	CMP.L	#$16390,DAC_FRQ
	BNE.S	.NOT_16
	MOVE.L	#$00070028,VAL
	MOVE.W	#335,OFFSET_VAL
	MOVE.B	#5,CLK
	MOVE.L	#3456,D5
	BSR	GEN_FRQ
	BSR	BUFFER1

.NOT_16	CMP.L	#$12292,DAC_FRQ
	BNE.S	.RT11	
	MOVE.L	#$0003001E,VAL
	MOVE.W	#251,OFFSET_VAL
	MOVE.B	#7,CLK
	MOVE.L	#4608,D5
	BSR	GEN_FRQ
	BSR	BUFFER1		
	
.RT11	RTS

DAC_FRQ		DC.L	0
OFFSET_VAL	DC.W	0
CHANGE_FRQ	DC.B	0
CLK		DC.B	0
		EVEN
***************************************************************************
GEN_FRQ
	LEA	FRQ,A0
	addq	#4,a0
	MOVEQ	#1,d0
ml1	MOVEQ	#0,d2
	move	d0,d2
	lsl.l	#4,d2
	move.l	d5,d3
	divu	d2,d3
	move	d3,(a0)+
	clr	d3
	divu	d2,d3
	move	d3,(a0)+
	addq	#1,d0
	cmp	#1024,d0
	blt	ml1
	RTS
***************************************************************************
BUFFER1	
	MOVE.W	OFFSET_VAL,D0
	MOVE.L	DEB_BUF,A0
	CMP.L	#MUSDEB,A0
	BNE.S	BUFFER2
	LEA	(A0,D0.W*4),A0
	MOVE.L	A0,DEB_BUF+4
	BRA.S	AFF_FRQ_RESTIT

BUFFER2
	MOVE.L	DEB_BUF+4,A0	
	LEA	(A0,D0.W*4),A0
	MOVE.L	A0,DEB_BUF
	
AFF_FRQ_RESTIT
	MOVE.L	DAC_FRQ,D0
	MOVEQ	#0,D1
	LEA	LENGT,A0
	LEA	hexa,A1
	
	MOVE.B	D0,D1
	AND.B	#$F,D1
	MOVE.B	(A1,D1.W),4(A0)
	MOVE.B	D0,D1
	LSR.B	#4,D1
	MOVE.B	(A1,D1.W),3(A0)
	LSR.L	#8,D0
	MOVE.B	D0,D1
	AND.B	#$F,D1
	MOVE.B	(A1,D1.W),2(A0)
	MOVE.B	D0,D1
	LSR.B	#4,D1
	MOVE.B	(A1,D1.W),1(A0)
	LSR.L	#8,D0
	AND.B	#$F,D0
	MOVE.B	(A1,D0.W),(A0)
	MOVE.L	#screen+640*72+544,where
	MOVE.W	#0,compt2
	MOVEQ	#5,D1
	BSR.L	PRINT
	RTS
	
LENGT	DC.B	'     '
	EVEN	
***************************************************************************
MOINS_FREQUENCE_030
	CMP.L	#$49170,DAC_FRQ
	BNE.S	.O1
	MOVE.L	#$12292,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O1	CMP.L	#$32780,DAC_FRQ
	BNE.S	.O2
	MOVE.L	#$49170,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O2	CMP.L	#$24585,DAC_FRQ
	BNE.S	.O3
	MOVE.L	#$32780,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O3	CMP.L	#$19668,DAC_FRQ
	BNE.S	.O4
	MOVE.L	#$24585,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O4	CMP.L	#$16390,DAC_FRQ
	BNE.S	.O5
	MOVE.L	#$19668,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O5	CMP.L	#$12292,DAC_FRQ
	BNE.S	.O6
	MOVE.L	#$16390,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
.O6	RTS

PLUS_FREQUENCE_030
	CMP.L	#$49170,DAC_FRQ
	BNE.S	.O1
	MOVE.L	#$32780,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O1	CMP.L	#$32780,DAC_FRQ
	BNE.S	.O2
	MOVE.L	#$24585,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O2	CMP.L	#$24585,DAC_FRQ
	BNE.S	.O3
	MOVE.L	#$19668,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O3	CMP.L	#$19668,DAC_FRQ
	BNE.S	.O4
	MOVE.L	#$16390,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O4	CMP.L	#$16390,DAC_FRQ
	BNE.S	.O5
	MOVE.L	#$12292,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	RTS
.O5	CMP.L	#$12292,DAC_FRQ
	BNE.S	.O6
	MOVE.L	#$49170,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
.O6	RTS
***************************************************************************
POSMOUSE
	cmp.b	#4,km			*Bouton gauche
	beq.s	.za1
	cmp.b	#2,km			*Bouton droit
	beq.s	.za2
	bra.s	.finito
.za1	LEA	pos,A0
	bra.s	.za3
.za2	LEA	pos2,A0
.za3	MOVE.B	#0,km
	LEA	jump,A1
.suite	MOVE.L	(a0)+,d0		*X min
	MOVE.L	(a0)+,d1		*Y min
	MOVE.L	(a0)+,d2		*X max
	MOVE.L	(a0)+,d3		*Y max
	MOVE.L	(a0)+,a1		*JUMP
	cmp.l	#-1,d0
	beq.s	.finito
	cmp.w	X1,d0
	bgt.s	.non
	cmp.w	X1,d2
	blt.s	.non
	cmp.w	Y1,d1
	bgt.s	.non
	cmp.w	Y1,d3
	blt.s	.non
	jmp	(a1)
.non	bra.s	.suite
.finito	RTS
	
pos	
	DC.L 163,313,246,328,EDIT,426,168,494,176,CLRSAM,426,176,494,184,CLRPAT
	DC.L 2,49,64,71,LOADER,65,49,126,71,SAUVEUR	*,281,265,311,271,MOINSFRQSPL
	DC.L 338,291,406,350,SILENT,0,0,126,30,EXIT
	DC.L 1,96,64,104,SPL,1,112,64,121,SPE,65,96,126,104,MAD
	DC.L 1,88,64,96,AVR,1,104,64,112,SAM,65,88,126,96,MOD,65,104,126,112,S3M
	DC.L 1,313,239,319,INPUT,250,328,334,342,PLAYPATT,250,313,334,328,PLAYSONG
	DC.L 163,328,246,342,RECORD,426,153,494,168,CLRALL
	DC.L 456,312,464,320,ADDNUM100,464,312,472,320,ADDNUM10,472,312,480,320,ADDNUM1
	DC.L 456,320,464,328,ADDPOS100,466,320,472,328,ADDPOS10,472,320,480,328,ADDPOS1
	DC.L 456,328,464,336,ADDPAT100,464,328,472,336,ADDPAT10,472,328,480,336,ADDPAT1
	DC.L 456,336,464,344,ADDLEN100,464,336,472,344,ADDLEN10,472,336,480,344,ADDLEN1
	DC.L 456,344,464,352,ADDLOP100,464,334,472,352,ADDLOP10,472,344,480,352,ADDLOP1
	DC.L 153,27,327,196,TEST_FILE,138,24,153,32,EXIT_REP,343,9,399,103,SUB1FS
	DC.L 343,113,399,205,ADD1FS,79,134,88,146,MOINSDRIVE,16,128,77,150,ACCEPT
	DC.L 62,240,82,248,MOINS_VOLUME_GENERAL
	
	DC.L 55,360,82,368,VS0,160,360,186,368,VS1,264,360,290,368,VS2
	DC.L 368,360,394,368,VS3,470,360,500,368,VS4,576,360,602,368,VS5
	DC.L 55,440,82,448,VS6,160,440,186,448,VS7,264,440,290,448,VS8
	DC.L 368,440,394,448,VS9,470,440,500,448,VS10,576,440,602,448,VS11
	DC.L 55,520,82,528,VS12,160,520,186,528,VS13,264,520,290,528,VS14
	DC.L 368,520,394,528,VS15,470,520,500,528,VS16,576,520,602,528,VS17
	DC.L 55,600,82,608,VS18,160,600,186,608,VS19,264,600,290,608,VS20
	DC.L 368,600,394,608,VS21,470,600,500,608,VS22,576,600,602,608,VS23
	DC.L 55,680,82,688,VS24,160,680,186,688,VS25,264,680,290,688,VS26
	DC.L 368,680,394,688,VS27,470,680,500,688,VS28,576,680,602,688,VS29
	DC.L 55,760,82,768,VS30,576,760,602,768,VS31
	
	DC.L 200,232,208,240,ON0,224,232,232,240,ON1,248,232,256,240,ON2
	DC.L 272,232,280,240,ON3,296,232,304,240,ON4,320,232,328,240,ON5
	DC.L 344,232,352,240,ON6,368,232,376,240,ON7,392,232,400,240,ON8
	DC.L 416,232,424,240,ON9,440,232,448,240,ON10,464,232,472,240,ON11
	DC.L 488,232,496,240,ON12,512,232,520,240,ON13,536,232,544,240,ON14,560,232,568,240,ON15
	DC.L 200,264,208,272,ON16,224,264,232,272,ON17,248,264,256,272,ON18
	DC.L 272,264,280,272,ON19,296,264,304,272,ON20,320,264,328,272,ON21
	DC.L 344,264,352,272,ON22,368,264,376,272,ON23,392,264,400,272,ON24
	DC.L 416,264,424,272,ON25,440,264,448,272,ON26,464,264,472,272,ON27
	DC.L 488,264,496,272,ON28,512,264,520,272,ON29,536,264,544,272,ON30,560,264,568,272,ON31

	DC.L 200+8,232,208+8,240,BR0,224+8,232,232+8,240,BR1,248+8,232,256+8,240,BR2
	DC.L 272+8,232,280+8,240,BR3,296+8,232,304+8,240,BR4,320+8,232,328+8,240,BR5
	DC.L 344+8,232,352+8,240,BR6,368+8,232,376+8,240,BR7,392+8,232,400+8,240,BR8
	DC.L 416+8,232,424+8,240,BR9,440+8,232,448+8,240,BR10,464+8,232,472+8,240,BR11
	DC.L 488+8,232,496+8,240,BR12,512+8,232,520+8,240,BR13,536+8,232,544+8,240,BR14,560+8,232,568+8,240,BR15
	DC.L 200+8,264,208+8,272,BR16,224+8,264,232+8,272,BR17,248+8,264,256+8,272,BR18
	DC.L 272+8,264,280+8,272,BR19,296+8,264,304+8,272,BR20,320+8,264,328+8,272,BR21
	DC.L 344+8,264,352+8,272,BR22,368+8,264,376+8,272,BR23,392+8,264,400+8,272,BR24
	DC.L 416+8,264,424+8,272,BR25,440+8,264,448+8,272,BR26,464+8,264,472+8,272,BR27
	DC.L 488+8,264,496+8,272,BR28,512+8,264,520+8,272,BR29,536+8,264,544+8,272,BR30,560+8,264,568+8,272,BR31
	
	DC.L 200,240,208,248,BLK0,224,240,232,248,BLK1,248,240,256,248,BLK2
	DC.L 272,240,280,248,BLK3,296,240,304,248,BLK4,320,240,328,248,BLK5
	DC.L 344,240,352,248,BLK6,368,240,376,248,BLK7,392,240,400,248,BLK8
	DC.L 416,240,424,248,BLK9,440,240,448,248,BLK10,464,240,472,248,BLK11
	DC.L 488,240,496,248,BLK12,512,240,520,248,BLK13,536,240,544,248,BLK14,560,240,568,248,BLK15
	DC.L 200,272,208,280,BLK16,224,272,240,280,BLK17,248,272,256,280,BLK18
	DC.L 272,272,280,280,BLK19,296,272,304,280,BLK20,320,272,328,280,BLK21
	DC.L 344,272,352,280,BLK22,368,272,376,280,BLK23,392,272,400,280,BLK24
	DC.L 416,272,424,280,BLK25,440,272,448,280,BLK26,464,272,472,280,BLK27
	DC.L 488,272,496,280,BLK28,512,272,520,280,BLK29,536,272,544,280,BLK30,560,272,568,280,BLK31
	
	DC.L 239,257,287,263,MONOSTEREO,289,257,312,263,SPESPL
	*DC.L 0,103,35,128,l_spl_mod
	DC.L 40,185,80,192,PIANO_DRUM
	DC.L 552,72,592,80,MOINS_FREQUENCE_030
	DC.L -1
	
pos2	DC.L 456,312,464,320,SUBNUM100,464,312,472,320,SUBNUM10,472,312,480,320,SUBNUM1
	DC.L 456,320,464,328,SUBPOS100,466,320,472,328,SUBPOS10,472,320,480,328,SUBPOS1
	DC.L 456,328,464,336,SUBPAT100,464,328,472,336,SUBPAT10,472,328,480,336,SUBPAT1
	DC.L 456,336,464,344,SUBLEN100,464,336,472,344,SUBLEN10,472,336,480,344,SUBLEN1
	DC.L 456,344,464,352,SUBLOP100,464,334,472,352,SUBLOP10,472,344,480,352,SUBLOP1
	DC.L 343,9,399,103,SUB18FS,343,113,399,205,ADD18FS,79,134,88,146,PLUSDRIVE
	*DC.L 281,265,311,271,PLUSFRQSPL
	DC.L 552,72,592,80,PLUS_FREQUENCE_030
	DC.L 62,240,82,248,PLUS_VOLUME_GENERAL
	DC.L -1
jump	dc.l	0
***************************************************************************
EXIT	MOVE.W	#1,fin
ITO	RTS

FONCT	CMP.W	#-1,touche
	BEQ.S	ITO
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	CMP.B	#1,DRUM
	BEQ	FONCT2
	
	LEA	FONCTION,A0		* D'ABORD VOIR SI C'EST UNE
	MOVE.W	touche,D1		* FONCTION
.ML1	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D0
	BEQ.S	ML2
	CMP.B	D2,D1
	BNE.S	.ML1
	LEA	FO1,A0
	MOVE.L	(A0,D0.W*4),A0
	JMP	(A0)

FO1	DC.L	ML2,SPACEBAR,CHNGCOLOR,SILENT,LEFTCURSOR,RIGHTCURSOR
	DC.L	DOWNCURSOR,UPCURSOR,UPLANCHE,DOWNPLANCHE,PLUSFRQSPL
	DC.L	SPESPL,MSKLOAD,ERASE,LOOP,INPUT,MONOSTEREO
	DC.L	ML2,ML2,DISPOSITION,ML2
	
ML2	MOVEQ	#0,D1
	MOVE.B	whatvoice,d1
	LEA	.WH1,A0
	MOVE.L	(A0,D1.W*4),A0
	JMP	(A0)
.WH1	DC.L	.DINST,.DINST,.DINST,MCOM,MCOM,MEFF,MEFF,MVOL

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
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A0
	ADD.L	D0,A0
	MOVE.L	#0,current
	CMP.L	#0,26(A0)
	BEQ.S	ML13
	MOVE.L	A0,FICI
	MOVE.L	A0,current
	MOVE.B	D1,curentnb2
	MOVE.B	D1,sampledata
	MOVE.B	D1,dernier
	MOVE.W	#0,zerotou
arb	BSR.l	CHECKPATT
	CMP.B	#1,edit
	BEQ.S	retour
	CMP.B	#1,record
	BEQ.S	retour
	JSR     DRUM_PREPA
	MOVE.L	FICI,A0
	JSR	SUM
retour	RTS	
ML13	MOVE.B	#-1,recinst
	RTS

FICI		DC.L	0
planche		dc.w	0
digiplanche	dc.w	0
yamplanche	dc.w	0
recnote		dc.b	0
recinst		dc.b	0
reccom		dc.b	0
receff		dc.b	0
recvol		dc.b	0
		even

FONCT2					* MODE FRQ
	LEA	FONCTION,A0		* D'ABORD VOIR SI C'EST UNE
	MOVE.W	touche,D1		* FONCTION
.ML3	MOVE.B	(A0)+,D2
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D0
	BEQ.S	.ML4
	CMP.B	D2,D1
	BNE.S	.ML3
	LEA	.FO2,A0
	MOVE.L	(A0,D0.W*4),A0
	JMP	(A0)
.FO2	DC.L	.ML4,SPACEBAR,CHNGCOLOR,SILENT,LEFTCURSOR,RIGHTCURSOR
	DC.L	DOWNCURSOR,UPCURSOR,UPLANCHE,DOWNPLANCHE,UPDIGIPL
	DC.L	DOWNDIGIPL,MSKLOAD,LOOP,D_ALL_BY_2,DIVIDE3,DIVIDE4
	DC.L	.ML4,MOINSSPL,PLUSSPL,DISPOSITION,.ML4

.ML4	MOVEQ	#0,D1
	MOVE.B	whatvoice,d1
	LEA	.WH,A0
	MOVE.L	(A0,D1.W*4),A0
	JMP	(A0)
.WH	DC.L	.MNOTE,MINST,MINST,MCOM,MCOM,MEFF,MEFF,MVOL,MVOL 
	
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
ARB2	BSR.L	CHECKPATT
	CMP.B	#1,edit
	BEQ.S	.retor
	CMP.B	#1,record
	BEQ.S	.retor
	JSR     FRQ_PREPA
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
	
MVOL	LEA	DATA,A0
	MOVE.W	touche,D2
.ML15	MOVE.B	(A0)+,D1
	MOVE.B	(A0)+,D0
	CMP.B	#-1,D1
	BEQ.S	.ML14
	CMP.B	D1,D2
	BNE.S	.ML15
	MOVE.B	D0,recvol
	MOVE.W	#0,zerotou
	BRA	ARB2
.ML14	MOVE.B	#-1,recvol
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
	MOVE.W	#0,touche
	MOVE.B	#0,recnote
	MOVE.B	#0,recinst
	MOVE.W	#1,zerotou
	MOVE.L	#0,current
	BRA	arb
************************************************************************
MOINS_VOLUME_GENERAL
	SUBQ.B	#1,VOLUME_GENERAL
	BNE.S	.RT
	MOVE.B	#1,VOLUME_GENERAL
.RT	*BSR.L	AFF_VOLUME_SPL	
	RTS

PLUS_VOLUME_GENERAL
	ADDQ.B	#1,VOLUME_GENERAL
	CMP.B	#64,VOLUME_GENERAL
	BNE.S	.RT
	MOVE.B	#63,VOLUME_GENERAL
.RT	*BSR.L	AFF_VOLUME_SPL	
	RTS
************************************************************************
PIANO_DRUM
	BCHG.B	#0,DRUM
	MOVEQ	#0,D0
	MOVE.B	DRUM,D0
	MULU	#5,D0
	LEA	TEXT1,A0
	ADD.W	D0,A0
	MOVE.L	#screen+32+185*640,where
	MOVE.W	#0,compt2
	MOVEQ	#5,D1
	BSR	PRINT
	RTS
TEXT1	DC.B	'DRUM ','PIANO'
************************************************************************
ON0	MOVEQ	#0,D0
	BRA	T_ON
ON1	MOVEQ	#1,D0
	BRA	T_ON
ON2	MOVEQ	#2,D0 
	BRA	T_ON
ON3	MOVEQ	#3,D0 
	BRA	T_ON
ON4	MOVEQ	#4,D0 
	BRA	T_ON
ON5	MOVEQ	#5,D0 
	BRA	T_ON
ON6	MOVEQ	#6,D0 
	BRA	T_ON
ON7	MOVEQ	#7,D0 
	BRA	T_ON
ON8	MOVEQ	#8,D0 
	BRA	T_ON
ON9	MOVEQ	#9,D0 
	BRA	T_ON
ON10	MOVEQ	#10,D0 
	BRA	T_ON
ON11	MOVEQ	#11,D0 
	BRA	T_ON
ON12	MOVEQ	#12,D0 
	BRA	T_ON
ON13	MOVEQ	#13,D0 
	BRA	T_ON
ON14	MOVEQ	#14,D0 
	BRA	T_ON
ON15	MOVEQ	#15,D0 
	BRA	T_ON
ON16	MOVEQ	#16,D0 
	BRA	T_ON
ON17	MOVEQ	#17,D0 
	BRA	T_ON
ON18	MOVEQ	#18,D0 
	BRA	T_ON
ON19	MOVEQ	#19,D0 
	BRA	T_ON
ON20	MOVEQ	#20,D0 
	BRA	T_ON
ON21	MOVEQ	#21,D0 
	BRA	T_ON
ON22	MOVEQ	#22,D0 
	BRA	T_ON
ON23	MOVEQ	#23,D0 
	BRA	T_ON
ON24	MOVEQ	#24,D0 
	BRA	T_ON
ON25	MOVEQ	#25,D0 
	BRA	T_ON
ON26	MOVEQ	#26,D0 
	BRA	T_ON
ON27	MOVEQ	#27,D0 
	BRA	T_ON
ON28	MOVEQ	#28,D0 
	BRA	T_ON
ON29	MOVEQ	#29,D0 
	BRA	T_ON
ON30	MOVEQ	#30,D0 
	BRA	T_ON
ON31	MOVEQ	#31,D0

T_ON	
	LEA	PILEVOIE,A0
	MOVE.L	(A0,D0.W*4),A0
	MOVEQ	#0,D1
	MOVE.B	25(A0),D1
	MOVE.L	A0,A5
	BSR	CLEAR2
	CMP.B	#5,D1
	BEQ.S	.TR2
	MOVE.B	#5,D1
	ADDQ.B	#1,digvoices
	BRA	.TR
	
.TR2	MOVE.B	#0,D1
	SUBQ.B	#1,digvoices
	CMP.L	#VOICE0,A0
	BEQ.S	.TR3
	CMP.L	#VOICE1,A0
	BEQ.S	.TR3
	BRA.S	.TR
	
.TR3	MOVE.B	#1,D1	

.TR	MOVE.B	D1,25(A0)
	MOVE.W	D1,D2
	CMP.B	#1,D1
	BNE.S	.MM
	MOVE.B	#0,D1
	
.MM	LEA	ON_TABLE,A1
	MOVE.L	(A1,D0.W*4),where
	MOVE.W	#0,compt2
	LEA	VTABLE,A0
	LEA	(A0,D1.W),A0
	MOVEQ	#1,D1
	BSR	PRINT
	
	LEA	VOICE_TAB,A0
	LEA	VOICE_TAB1,A1
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	CMP.B	#5,D2
	BNE.S	.ZZ
	MOVE.B	#1,D2
	BRA.S	.EE
.ZZ	MOVE.B	#0,D2
.EE	LEA	VOICE_TAB1,A1
	MOVE.B	D2,(A1,D0.W)
	BSR	SET_VS
	RTS

ON_TABLE	DC.L	screen+640*232+192,screen+640*232+223,screen+640*232+240,screen+640*232+271,screen+640*232+288,screen+640*232+319
		DC.L	screen+640*232+336,screen+640*232+367,screen+640*232+384,screen+640*232+415,screen+640*232+432,screen+640*232+463
		DC.L	screen+640*232+480,screen+640*232+511,screen+640*232+528,screen+640*232+559
		
		DC.L	screen+640*264+192,screen+640*264+223,screen+640*264+240,screen+640*264+271,screen+640*264+288,screen+640*264+319
		DC.L	screen+640*264+336,screen+640*264+367,screen+640*264+384,screen+640*264+415,screen+640*264+432,screen+640*264+463
		DC.L	screen+640*264+480,screen+640*264+511,screen+640*264+528,screen+640*264+559

VTABLE		DC.B	' VB  X'
		EVEN
***************************************************************************
SET_ON
	LEA	PILEVOIE,A1
	LEA	VTABLE,A2
	LEA	ON_TABLE,A3
	MOVEQ	#31,D0
	MOVEQ	#0,D1
	
.LIPO	MOVE.L	(A1)+,A4
	MOVE.B	25(A4),D1
	LEA	(A2,D1.W),A0
	MOVE.L	(A3)+,where
	MOVE.W	#0,compt2
	MOVEQ	#1,D1
	BSR	PRINT
	DBF	D0,.LIPO

	RTS
***************************************************************************
BLK0	MOVEQ	#0,D0
	BRA	T_BLK
BLK1	MOVEQ	#1,D0
	BRA	T_BLK
BLK2	MOVEQ	#2,D0 
	BRA	T_BLK
BLK3	MOVEQ	#3,D0 
	BRA	T_BLK
BLK4	MOVEQ	#4,D0 
	BRA	T_BLK
BLK5	MOVEQ	#5,D0 
	BRA	T_BLK
BLK6	MOVEQ	#6,D0 
	BRA	T_BLK
BLK7	MOVEQ	#7,D0 
	BRA	T_BLK
BLK8	MOVEQ	#8,D0 
	BRA	T_BLK
BLK9	MOVEQ	#9,D0 
	BRA	T_BLK
BLK10	MOVEQ	#10,D0 
	BRA	T_BLK
BLK11	MOVEQ	#11,D0 
	BRA	T_BLK
BLK12	MOVEQ	#12,D0 
	BRA	T_BLK
BLK13	MOVEQ	#13,D0 
	BRA	T_BLK
BLK14	MOVEQ	#14,D0 
	BRA	T_BLK
BLK15	MOVEQ	#15,D0 
	BRA	T_BLK
BLK16	MOVEQ	#16,D0 
	BRA	T_BLK
BLK17	MOVEQ	#17,D0 
	BRA	T_BLK
BLK18	MOVEQ	#18,D0 
	BRA	T_BLK
BLK19	MOVEQ	#19,D0 
	BRA	T_BLK
BLK20	MOVEQ	#20,D0 
	BRA	T_BLK
BLK21	MOVEQ	#21,D0 
	BRA	T_BLK
BLK22	MOVEQ	#22,D0 
	BRA	T_BLK
BLK23	MOVEQ	#23,D0 
	BRA	T_BLK
BLK24	MOVEQ	#24,D0 
	BRA	T_BLK
BLK25	MOVEQ	#25,D0 
	BRA	T_BLK
BLK26	MOVEQ	#26,D0 
	BRA	T_BLK
BLK27	MOVEQ	#27,D0 
	BRA	T_BLK
BLK28	MOVEQ	#28,D0 
	BRA	T_BLK
BLK29	MOVEQ	#29,D0 
	BRA	T_BLK
BLK30	MOVEQ	#30,D0 
	BRA	T_BLK
BLK31	MOVEQ	#31,D0

T_BLK	LEA	BLK_TAB,A0
	LEA	(A0,D0.W),A0
	BCHG.B	#1,(A0)
	MOVEQ	#0,D1
	MOVE.B	(A0),D1
	LEA	VTABLE,A0
	LEA	(A0,D1.W),A0
	LEA	BLK_TABLE,A1
	MOVE.L	(A1,D0.W*4),where
	MOVE.W	#0,compt2
	MOVEQ	#1,D1
	BSR	PRINT
	RTS
	
	
BLK_TABLE	DC.L	screen+640*240+192,screen+640*240+223,screen+640*240+240,screen+640*240+271,screen+640*240+288,screen+640*240+319
		DC.L	screen+640*240+336,screen+640*240+367,screen+640*240+384,screen+640*240+415,screen+640*240+432,screen+640*240+463
		DC.L	screen+640*240+480,screen+640*240+511,screen+640*240+528,screen+640*240+559
		
		DC.L	screen+640*272+192,screen+640*272+223,screen+640*272+240,screen+640*272+271,screen+640*272+288,screen+640*272+319
		DC.L	screen+640*272+336,screen+640*272+367,screen+640*272+384,screen+640*272+415,screen+640*272+432,screen+640*272+463
		DC.L	screen+640*272+480,screen+640*272+511,screen+640*272+528,screen+640*272+559
***************************************************************************
BR0	MOVEQ	#0,D0
	BRA	T_BR
BR1	MOVEQ	#1,D0
	BRA	T_BR
BR2	MOVEQ	#2,D0 
	BRA	T_BR
BR3	MOVEQ	#3,D0 
	BRA	T_BR
BR4	MOVEQ	#4,D0 
	BRA	T_BR
BR5	MOVEQ	#5,D0 
	BRA	T_BR
BR6	MOVEQ	#6,D0 
	BRA	T_BR
BR7	MOVEQ	#7,D0 
	BRA	T_BR
BR8	MOVEQ	#8,D0 
	BRA	T_BR
BR9	MOVEQ	#9,D0 
	BRA	T_BR
BR10	MOVEQ	#10,D0 
	BRA	T_BR
BR11	MOVEQ	#11,D0 
	BRA	T_BR
BR12	MOVEQ	#12,D0 
	BRA	T_BR
BR13	MOVEQ	#13,D0 
	BRA	T_BR
BR14	MOVEQ	#14,D0 
	BRA	T_BR
BR15	MOVEQ	#15,D0 
	BRA	T_BR
BR16	MOVEQ	#16,D0 
	BRA	T_BR
BR17	MOVEQ	#17,D0 
	BRA	T_BR
BR18	MOVEQ	#18,D0 
	BRA	T_BR
BR19	MOVEQ	#19,D0 
	BRA	T_BR
BR20	MOVEQ	#20,D0 
	BRA	T_BR
BR21	MOVEQ	#21,D0 
	BRA	T_BR
BR22	MOVEQ	#22,D0 
	BRA	T_BR
BR23	MOVEQ	#23,D0 
	BRA	T_BR
BR24	MOVEQ	#24,D0 
	BRA	T_BR
BR25	MOVEQ	#25,D0 
	BRA	T_BR
BR26	MOVEQ	#26,D0 
	BRA	T_BR
BR27	MOVEQ	#27,D0 
	BRA	T_BR
BR28	MOVEQ	#28,D0 
	BRA	T_BR
BR29	MOVEQ	#29,D0 
	BRA	T_BR
BR30	MOVEQ	#30,D0 
	BRA	T_BR
BR31	MOVEQ	#31,D0

T_BR	LEA	PILEVOIE,A0
	MOVE.L	(A0,D0.W*4),A0
	BCHG.B	#0,27(A0)
	MOVEQ	#0,D1
	MOVE.B	27(A0),D1
	LEA	VTABLE,A0
	LEA	(A0,D1.W),A0
	LEA	BR_TABLE,A1
	MOVE.L	(A1,D0.W*4),where
	MOVE.W	#0,compt2
	MOVEQ	#1,D1
	BSR	PRINT
	RTS

BR_TABLE	DC.L	screen+640*232+192+15,screen+640*232+223+1,screen+640*232+240+15,screen+640*232+271+1,screen+640*232+288+15,screen+640*232+319+1
		DC.L	screen+640*232+336+15,screen+640*232+367+1,screen+640*232+384+15,screen+640*232+415+1,screen+640*232+432+15,screen+640*232+463+1
		DC.L	screen+640*232+480+15,screen+640*232+511+1,screen+640*232+528+15,screen+640*232+559+1
		
		DC.L	screen+640*264+192+15,screen+640*264+223+1,screen+640*264+240+15,screen+640*264+271+1,screen+640*264+288+15,screen+640*264+319+1
		DC.L	screen+640*264+336+15,screen+640*264+367+1,screen+640*264+384+15,screen+640*264+415+1,screen+640*264+432+15,screen+640*264+463+1
		DC.L	screen+640*264+480+15,screen+640*264+511+1,screen+640*264+528+15,screen+640*264+559+1	
***************************************************************************
VS0	MOVEQ	#0,D0
	BRA	T_VS
VS1	MOVEQ	#1,D0
	BRA	T_VS
VS2	MOVEQ	#2,D0 
	BRA	T_VS
VS3	MOVEQ	#3,D0 
	BRA	T_VS
VS4	MOVEQ	#4,D0 
	BRA	T_VS
VS5	MOVEQ	#5,D0 
	BRA	T_VS
VS6	MOVEQ	#6,D0 
	BRA	T_VS
VS7	MOVEQ	#7,D0 
	BRA	T_VS
VS8	MOVEQ	#8,D0 
	BRA	T_VS
VS9	MOVEQ	#9,D0 
	BRA	T_VS
VS10	MOVEQ	#10,D0 
	BRA	T_VS
VS11	MOVEQ	#11,D0 
	BRA	T_VS
VS12	MOVEQ	#12,D0 
	BRA	T_VS
VS13	MOVEQ	#13,D0 
	BRA	T_VS
VS14	MOVEQ	#14,D0 
	BRA	T_VS
VS15	MOVEQ	#15,D0 
	BRA	T_VS
VS16	MOVEQ	#16,D0 
	BRA	T_VS
VS17	MOVEQ	#17,D0 
	BRA	T_VS
VS18	MOVEQ	#18,D0 
	BRA	T_VS
VS19	MOVEQ	#19,D0 
	BRA	T_VS
VS20	MOVEQ	#20,D0 
	BRA	T_VS
VS21	MOVEQ	#21,D0 
	BRA	T_VS
VS22	MOVEQ	#22,D0 
	BRA	T_VS
VS23	MOVEQ	#23,D0 
	BRA	T_VS
VS24	MOVEQ	#24,D0 
	BRA	T_VS
VS25	MOVEQ	#25,D0 
	BRA	T_VS
VS26	MOVEQ	#26,D0 
	BRA	T_VS
VS27	MOVEQ	#27,D0 
	BRA	T_VS
VS28	MOVEQ	#28,D0 
	BRA	T_VS
VS29	MOVEQ	#29,D0 
	BRA	T_VS
VS30	MOVEQ	#30,D0 
	BRA	T_VS
VS31	MOVEQ	#31,D0

T_VS	LEA	VOICE_TAB,A0
	LEA	(A0,D0.W),A0
	BCHG.B	#0,(A0)
	
	LEA	V_TAB_SCR,A0
	MOVE.L	(A0,D0.W*4),A0
	BTST	#0,D0
	BNE.S	.M2
	MOVEQ	#7,D0
.LOPO	NOT.B	1(A0)
	NOT.W	16(A0)
	LEA	640(A0),A0
	DBF	D0,.LOPO
	RTS
.M2	MOVEQ	#7,D0
.LOP2	NOT.W	(A0)
	NOT.B	16(A0)
	LEA	640(A0),A0
	DBF	D0,.LOP2
	RTS
		
	
V_TAB_SCR	DC.L	screen+640*360+48+8,screen+640*360+160+8,screen+640*360+256+8,screen+640*360+368+8,screen+640*360+464+8,screen+640*360+576+8
		DC.L	screen+640*440+48+8,screen+640*440+160+8,screen+640*440+256+8,screen+640*440+368+8,screen+640*440+464+8,screen+640*440+576+8
		DC.L	screen+640*520+48+8,screen+640*520+160+8,screen+640*520+256+8,screen+640*520+368+8,screen+640*520+464+8,screen+640*520+576+8
		DC.L	screen+640*600+48+8,screen+640*600+160+8,screen+640*600+256+8,screen+640*600+368+8,screen+640*600+464+8,screen+640*600+576+8
		DC.L	screen+640*680+48+8,screen+640*680+160+8,screen+640*680+256+8,screen+640*680+368+8,screen+640*680+464+8,screen+640*680+576+8
		DC.L	screen+640*760+48+8,screen+640*760+576+8
***************************************************************************
CHNGCOLOR
	MOVE.B	#0,KEY
	EOR.L	#$FF,COLOR
	RTS
COLOR	DC.L	0
***************************************************************************
DISPOSITION
	MOVE.B	#0,KEY
	BCHG	#0,DISPO
	RTS
DISPO	DC.W	0
***************************************************************************
PLUSSPL
	MOVE.B	#0,KEY
	ADDQ.b	#1,sampledata
	cmp.b	#255,sampledata
	BNE.S	vtt
	MOVE.B  #254,sampledata
vtt	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MOVE.B	d0,dernier
	MOVE.B	d0,curentnb2
	LEA	SAMPLE,a0
	MULU	#LEN_SAMPLE_MGT,d0
	ADD.l	d0,a0
	*CMP.L	#0,LEN_MGT(a0)
	*beq.s	nosum
	JSR	SUM
	RTS
nosum	JSR	AFF_NB_SPL
	LEA	oops,a0
	MOVEQ	#20,d1
	MOVE.L	#screen+32000+113*160+39,where
	MOVE.W	#1,compt2
	BSR	PRINT
	MOVEQ	#4,d1
	MOVE.L #screen+32000+65*160+136+6,where
	MOVE.W	#0,compt2
	BSR	PRINT
	MOVE.L	#screen+32000+17*160+95,where
	MOVE.W	#1,compt2
	MOVEQ	#7,d1
	BSR	PRINT
	MOVE.L	#screen+32000+33*160+95,where
	MOVE.W	#1,compt2
	MOVEQ	#7,d1
	BSR	PRINT
	RTS
oops	dc.b	'                    '
************************************************************************
MOINSSPL
	MOVE.B	#0,KEY
	subQ.b	#1,sampledata
	cmp.b	#255,sampledata
	bne	vtt
	MOVE.B	#0,sampledata
	bra	vtt
************************************************************************
UPDIGIPL
	MOVE.B	#0,KEY
	ADD.W	#24,digiplanche
	CMP.W	#48,digiplanche
	BNE.S	outt
	MOVE.W	#24,digiplanche
	RTS
************************************************************************
DOWNDIGIPL
	MOVE.B	#0,KEY
	SUB.W	#24,digiplanche
	CMP.W	#-24,digiplanche
	BNE.S	outt
	MOVE.W	#0,digiplanche
	RTS
************************************************************************
UPLANCHE
	MOVE.B	#0,KEY
	ADDQ.w	#1,planche
	CMP.W	#255-64,planche
	blt.s	outt
	MOVE.W	#255-64,planche
outt	RTS
************************************************************************
DOWNPLANCHE
	MOVE.B	#0,KEY
	subQ.w	#1,planche
	CMP.W	#0,planche
	bge.s	outt
	MOVE.W	#0,planche
	RTS
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
	MOVE.L	#screen+137*640+64+1,where
	MOVE.W	#1,compt2
	BSR	PRINT
	RTS
DRV	DC.B	'A'
	EVEN
************************************************************************
ACCEPT
	MOVE.B	DRV,PATH
	MOVE.L	#'\*.*',PATH+2
	MOVE.L	#0,PATH+6
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
	MOVE.B	#0,KEY
	MOVE.W	#-1,touche
	MOVE.B	#-1,lastkey
	BSR	INVERT_RECORD
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata
	bchg.b	#0,record
	MOVE.B	#0,recinst
	MOVE.B	#0,recnote
	MOVE.W	#1,sync
	MOVE.W	#0,u
	cmp.b	#1,edit
	BNE.S	.rt1
	BSR	INVERT_EDIT
	MOVE.B	#0,edit
.rt1	cmp.b	#1,playpat
	BNE.S	.rt8
	MOVE.B	#0,playpat
	BSR	INVERT_PLAYPATT
.rt8	cmp.b	#1,playsong
	BNE.S	.rt12
	MOVE.B	#0,playsong
	BSR	INVERT_PLAYSONG
.rt12	RTS
record	dc.b	0
	even
************************************************************************
EDIT
	bchg.b	#0,edit
	BSR.S	INVERT_EDIT
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata
	cmp.b	#1,record
	BNE.S	.rt3
	BSR.S	INVERT_RECORD
	MOVE.B	#0,record
.rt3	cmp.b	#1,playpat
	BNE.S	.rt11
	MOVE.B	#0,playpat
	BSR.S	INVERT_PLAYPATT
.rt11	cmp.b	#1,playsong
	BNE.S	.rt13
	MOVE.B	#0,playsong
	BSR.S	INVERT_PLAYSONG
.rt13	RTS
************************************************************************
INVERT_EDIT
	LEA	screen+640*313+160+8,A0
	MOVEQ	#14,d0
	BSR.S	INVERT_2
	RTS
************************************************************************
INVERT_RECORD
	LEA	screen+640*328+160+8,A0
	MOVEQ	#14,d0
	BSR.S	INVERT_2
	RTS
************************************************************************
INVERT_CLRPAT
	LEA	screen+640*176+416+8,A0
	MOVEQ	#6,d0
	BSR.S	INVERT2
	RTS
***************************************************************************
INVERT_CLRALL
	LEA	screen+640*160+416+8,A0
	MOVEQ	#6,D0
	BSR.S	INVERT2
	RTS
***************************************************************************
INVERT_CLRSAM
	LEA	screen+640*168+416+8,A0
	MOVEQ	#6,d0
	BSR.S	INVERT2
	RTS
***************************************************************************
INVERT_PLAYPATT
	LEA	screen+640*328+240+8,A0
	MOVEQ	#14,d0
	BSR.S	INVERT
	RTS
***************************************************************************
INVERT_PLAYSONG
	LEA	screen+640*313+240+8,A0
	MOVEQ	#14,D0
	BSR.S	INVERT
	RTS
***************************************************************************
INVERT
.i1	NOT.B	1(a0)
	NOT.W	16(a0)
	NOT.W	32(a0)
	NOT.W	48(a0)
	NOT.W	64(a0)
	NOT.W	80(a0)
	LEA	640(A0),A0
	DBF	D0,.i1
	RTS
***************************************************************************
INVERT_2
.i3	NOT.W	(a0)
	NOT.W	16(a0)
	NOT.W	32(a0)
	NOT.W	48(a0)
	NOT.W	64(a0)
	NOT.B	80(a0)
	LEA	640(A0),A0
	DBF	D0,.i3
	RTS
***************************************************************************
INVERT2
.i2	NOT.B	1(a0)
	NOT.W	16(a0)
	NOT.W	32(a0)
	NOT.W	48(a0)
	NOT.W	64(a0)
	LEA	640(A0),A0
	DBF	D0,.i2
	RTS
***************************************************************************
INVERT_4
	MOVEQ	#8,D1
	MOVE.L	WHERE_MASK,A0
.i4	NOT.W	(a0)
	NOT.W	16(a0)
	NOT.W	32(a0)
	NOT.W	48(a0)
	LEA	640(A0),A0
	DBF	D1,.i4
	RTS
***************************************************************************
PLUSFRQSPL
*	MOVEQ	#0,d0
*	MOVE.B	sampledata,d0
*	MULU	#LEN_SAMPLE_MGT,d0
*	LEA	SAMPLE,a0
*	ADD.l	d0,a0
*	CMP.L	#0,LEN_MGT(a0)
*	beq.s	rt7
*	cmp.b	#127,MONO_MGT(a0)
*	bls.s	.plusgrand
*	ADDQ.b	#1,MONO_MGT(a0)
*	cmp.b	#131,MONO_MGT(a0)
*	bls.s	plupetit
*	MOVE.B	#128,MONO_MGT(a0)
*	bra.s	plupetit
*.plusgrand
*	ADDQ.b	#1,MONO_MGT(a0)
*	cmp.b	#3,MONO_MGT(a0)
*	bls.s	plupetit
*	MOVE.B	#0,MONO_MGT(a0)
plupetit
*	MOVE.W	#4,d1
*	MOVE.L  #screen+32000+65*160+136+6,where
*	MOVE.W	#0,compt2
*	MOVE.B  MONO_MGT(a0),d0
*	bset	#7,d0
*	MOVE.W	d0,setloadfrq
*	bclr    #7,d0
*	MULU	#4,d0
*	LEA	FREQUENCE,a0
*	ADD.l	d0,a0
*	MOVE.L  (a0),a0
*	BSR	PRINT
rt7	RTS
setloadfrq	dc.w	129
*************************************************************************
MOINSFRQSPL
*	MOVEQ	#0,d0
*	MOVE.B	sampledata,d0
*	MULU	#LEN_SAMPLE_MGT,d0
*	LEA	SAMPLE,a0
*	ADD.l	d0,a0
*	CMP.L	#0,LEN_MGT(a0)
*	beq.s	rt7
*	cmp.b	#127,MONO_MGT(a0)
*	bls.s	.plusgrand2
*	subq.b	#1,MONO_MGT(a0)
*	cmp.b	#127,MONO_MGT(a0)
*	BNE.S	plupetit
*	MOVE.B	#131,MONO_MGT(a0)
*	bra.s	plupetit
*.plusgrand2
*	subq.b	#1,MONO_MGT(a0)
*	cmp.b	#-1,MONO_MGT(a0)
*	bne	plupetit
*	MOVE.B	#3,MONO_MGT(a0)
	bra	plupetit
	
*************************************************************************
MONOSTEREO
	MOVE.B	#0,KEY
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	CMP.L	#0,LEN_MGT(a0)
	beq.s	rt7
	bchg	#7,MONO_MGT(a0)
	JSR	AFF_MONO_SPL
	RTS
*************************************************************************
LOOP	MOVEQ	#0,d0
	MOVE.B	#0,KEY
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	cmp.b	#1,LOOP_MGT(a0)
	beq.s	.loop2
	MOVE.B	#1,LOOP_MGT(a0)
	RTS
.loop2	MOVE.B	#3,LOOP_MGT(a0)
	RTS
************************************************************************
CLRPAT	MOVE.W	#5,okp
	RTS
CLRPAT1
	BSR	INVERT_CLRPAT
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	cmp.b	#1,all
	beq.s	CLR_ALLPAT
	MOVE.L	ADDPATT,a0
	MOVE.B	voies,d0
	MULU	#64*4,d0		* 64 patterns de 5 octets par voie
	subq.w	#1,d0
.clrp	MOVE.B	d1,(a0)+
	DBF	d0,.clrp
	BSR	INVERT_CLRPAT
	MOVE.B	#0,inpatt
	BSR.L	AFFPATTERN2
	MOVE.W	#0,okp
	RTS
CLR_ALLPAT
	LEA	PATTERNS,a0
	MOVE.B	voies,d0
	MOVE.B	maxpatt,d1
	MULU	#64*4,d0
	MULU	d1,d0
	MOVEQ	#0,d1
.clralp	MOVE.B	d1,(a0)+
	subq.l	#1,d0
	BNE.S	.clralp
	BSR	INVERT_CLRPAT
	BSR	INVERT_CLRALL
	MOVE.B	#0,inpatt
	MOVE.B	#0,all
	BSR.L	AFFPATTERN2
	MOVE.W	#0,okp
	RTS
************************************************************************
CLRALL
	BSR	INVERT_CLRALL
	bchg	#0,all
	RTS
all	dc.b	0
	even
************************************************************************
CLRSAM	MOVE.W	#4,okp
	RTS
CLRSAM1
	BSR	INVERT_CLRSAM
	cmp.b	#0,all
	beq	CLR_ONE
	LEA	SAMPLE,a0
	MOVEQ	#63,d0
.clrsa	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.B	#0,(a0)+
	MOVE.B	#129,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.W	#1,(a0)+
	MOVE.L	#0,(a0)+
	dbf	d0,.clrsa
	MOVE.L	ADDSPL,ENDADDR
	BSR	FRE
	BSR	INVERT_CLRALL
	BSR	INVERT_CLRSAM
	MOVE.B	#0,all
	LEA	NAMESAMPLE,a0
	MOVE.W	#(256*13)-1,d0
.wxc	MOVE.B	#0,(a0)+
	DBF	D0,.wxc
	MOVE.W	#0,okp
	RTS
CLR_ONE
	BSR	ERASE
	BSR	INVERT_CLRSAM
	MOVE.W	#0,okp
	RTS
************************************************************************
*	IN : D0 = Nombre a convertir
*	     A0 = Adresse ou convertir
CONVERT_BYTE_DECI
	divu	#100,d0			* converti les centaines
	ADD.w	#'0',d0
	MOVE.B	d0,(a0)
	MOVE.W	#0,d0
	swap	d0
	divu	#10,d0			* converti les dizaines
	ADD.w	#'0',d0
	MOVE.B	d0,1(a0)
	swap	d0			* puis les unites
	ADD.w	#'0',d0
	MOVE.B	d0,2(a0)
	MOVEQ	#2,d0			* vire les '0' en trop
.stll	cmp.b	#'0',(a0)
	BNE.S	.srt
	MOVE.B  #0,(a0)+
	subq	#1,d0
	BNE.S	.stll
.srt	RTS
************************************************************************
SUBPAT100
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#99,d0
	ble	re
	sub.b	#100,d0
	bra.s	fish
SUBPAT10
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#9,d0
	ble	re
	sub.b	#10,d0
	bra.s	fish
SUBPAT1
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#0,d0
	beq	re
	subq.b	#1,d0
	bra.s	fish
ADDPAT100
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#155,d0
	bge	re
	ADD.b	#100,d0
	bra.s	fish
ADDPAT10
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#245,d0
	bge	re
	ADD.b	#10,d0
	bra.s	fish
ADDPAT1
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	CMP.W	#255,d0
	beq	re
	ADDQ.b	#1,d0
fish	cmp.b	maxpatt,d0
	ble.S	.thats
	MOVE.B	maxpatt,d0
.thats	MOVE.B	d0,curpatt
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*328+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	curseq,d1
	MOVE.B	curpatt,d0		*Place la pattern courante
	MOVE.L	ADDSEQ,a0		*dans la sequence
	ADD.l	d1,a0
	MOVE.B	d0,(a0)
yep	LEA	PATTERNS,a0
	MOVE.B	cvoies,d1		*Calcul l'adresse de la
	MULU	d1,d0			*pattern choisie
	MULU	#64,d0
	ADD.l	d0,a0
	MOVE.L	a0,ADDPATT
	MOVE.B	#0,inpatt
	*cmp.b	#1,playsong
	*beq.s	re
	BSR	AFFPATTERN
re	RTS
************************************************************************
SUBPOS100
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#99,d0
	ble	re1
	sub.b	#100,d0
	bra.s	fish1
SUBPOS10
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#9,d0
	ble	re1
	sub.b	#10,d0
	bra.s	fish1
SUBPOS1
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#0,d0
	beq	re1
	subq.b	#1,d0
	bra.s	fish1
ADDPOS100
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#155,d0
	bge	re1
	ADD.b	#100,d0
	bra.s	fish1
ADDPOS10
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#245,d0
	bge	re1
	ADD.b	#10,d0
	bra.s	fish1
ADDPOS1
	MOVEQ	#0,d0
	MOVE.B	curseq,d0
	CMP.W	#255,d0
	beq	re1
	ADDQ.b	#1,d0
fish1	MOVEQ	#0,d1
	MOVE.B	curlen,d1
	CMP.W	d1,d0
	blt.s	.fish3
	MOVE.B	d1,d0
.fish3	MOVE.B	d0,curseq
frigo	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*320+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	MOVEQ	#0,d0				*puisque la postion dans
	MOVE.B	curseq,d0			*la sequence a ete modifie
	MOVE.L	ADDSEQ,a0			*on affiche la pattern
	ADD.l	d0,a0				*correspondante.
	MOVE.B	(a0),d0				*la pattern devient donc
	MOVE.B	d0,curpatt			*courante
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*328+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	MOVEQ	#0,d0
	MOVE.B	curpatt,d0
	bra	yep
re1	RTS
************************************************************************
SUBNUM100
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#99,d0
	ble	re2
	sub.b	#100,d0
	bra.s	fish2
SUBNUM10
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#9,d0
	ble	re2
	sub.b	#10,d0
	bra.s	fish2
SUBNUM1
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#0,d0
	beq	re2
	subq.b	#1,d0
	bra.s	fish2
ADDNUM100
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#155,d0
	bge	re2
	ADD.b	#100,d0
	bra.s	fish2
ADDNUM10
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#245,d0
	bge	re2
	ADD.b	#10,d0
	bra.s	fish2
ADDNUM1
	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	CMP.W	#255,d0
	beq	re2
	ADDQ.b	#1,d0
fish2	cmp.b	maxzic,d0
	blt.s	.mm
	MOVE.B	maxzic,d0
.mm	MOVE.B	d0,curnum
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*312+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	MOVEQ	#0,d0			*puisqu'on change de zik
	MOVE.B	d0,curseq		*on remet a zero les compteurs 
					*de position (sequence)
	MOVE.B	curnum,d0
	lsl	#8,d0			* 256
	LEA	SEQUENCE,a0
	ADD.l	d0,a0
	MOVE.L	a0,ADDSEQ
	MOVE.B	(a0),curpatt		*et de pattern

	MOVEQ	#0,d0
	MOVE.B	curnum,d0
	MULU	#2,d0
	LEA	MUSIQUE,a1
	ADD.w	d0,a1
	MOVEQ	#0,d0
	MOVE.B	(a1),d0			* on reaffiche la longueur
	MOVE.B	d0,curlen
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*336+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	MOVEQ	#0,d0
	MOVE.B	1(a1),d0			* et le loop
	MOVE.B	d0,curlop
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*344+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	bra	frigo			*puis on va afficher le tout
re2	RTS
char3:	dc.b 	'  0'
	even
***************************************************************************
SUBLEN100
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#99,d0
	ble.s	re2
	sub.b	#100,d0
	bra.s	rabbit
SUBLEN10
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#9,d0
	ble.S	re2
	sub.b	#10,d0
	bra.s	rabbit
SUBLEN1
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#0,d0
	beq.S	re2
	subq.b	#1,d0
	bra.s	rabbit
ADDLEN100
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#155,d0
	bge.S	re2
	ADD.b	#100,d0
	bra.s	rabbit
ADDLEN10
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#245,d0
	bge.S	re2
	ADD.b	#10,d0
	bra.s	rabbit
ADDLEN1
	MOVEQ	#0,d0
	MOVE.B	curlen,d0
	CMP.W	#255,d0
	beq.S	re2
	ADDQ.b	#1,d0
rabbit	LEA	MUSIQUE,a0
	MOVEQ	#0,d1
	MOVE.B	curnum,d1
	MULU	#2,d1
	ADD.w	d1,a0
	MOVE.B	d0,(a0)
	MOVE.B	d0,curlen
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*336+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	RTS
************************************************************************
SUBLOP100
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#99,d0
	ble	re2
	sub.b	#100,d0
	bra.s	cow
SUBLOP10
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#9,d0
	ble	re2
	sub.b	#10,d0
	bra.s	cow
SUBLOP1
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#0,d0
	beq	re2
	subq.b	#1,d0
	bra.s	cow
ADDLOP100
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#155,d0
	bge	re2
	ADD.b	#100,d0
	bra.s	cow
ADDLOP10
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#245,d0
	bge	re2
	ADD.b	#10,d0
	bra.s	cow
ADDLOP1
	MOVEQ	#0,d0
	MOVE.B	curlop,d0
	CMP.W	#255,d0
	beq	re2
	ADDQ.b	#1,d0
cow	LEA	MUSIQUE,a0
	MOVEQ	#0,d1
	MOVE.B	curnum,d1
	MULU	#2,d1
	ADD.w	d1,a0
	MOVE.B	d0,1(a0)
	MOVE.B	d0,curlop
	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*344+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	RTS
************************************************************************
SILENT:
	MOVEM.L	d0-a0,-(a7)
	MOVE.B	#0,KEY
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata

	LEA	VOICE0,a0
	BSR	CLEAR1
	LEA	VOICE1,a0
	BSR	CLEAR1
	LEA	VOICE2,a0
	BSR	CLEAR1
	LEA	VOICE3,a0
	BSR	CLEAR1
	LEA	VOICE4,a0
	BSR	CLEAR1
	LEA	VOICE5,a0
	BSR	CLEAR1
	LEA	VOICE6,a0
	BSR	CLEAR1
	LEA	VOICE7,a0
	BSR	CLEAR1
	LEA	VOICE8,a0
	BSR	CLEAR1
	LEA	VOICE9,a0
	BSR	CLEAR1
	LEA	VOICE10,a0
	BSR	CLEAR1
	LEA	VOICE11,a0
	BSR	CLEAR1
	LEA	VOICE12,a0
	BSR	CLEAR1
	LEA	VOICE13,a0
	BSR	CLEAR1
	LEA	VOICE14,a0
	BSR	CLEAR1
	LEA	VOICE15,a0
	BSR	CLEAR1
	LEA	VOICE16,a0
	BSR	CLEAR1
	LEA	VOICE17,a0
	BSR	CLEAR1
	LEA	VOICE18,a0
	BSR	CLEAR1
	LEA	VOICE19,a0
	BSR	CLEAR1
	LEA	VOICE20,a0
	BSR	CLEAR1
	LEA	VOICE21,a0
	BSR	CLEAR1
	LEA	VOICE22,a0
	BSR	CLEAR1
	LEA	VOICE23,a0
	BSR	CLEAR1
	LEA	VOICE24,a0
	BSR	CLEAR1
	LEA	VOICE25,a0
	BSR	CLEAR1
	LEA	VOICE26,a0
	BSR	CLEAR1
	LEA	VOICE27,a0
	BSR	CLEAR1
	LEA	VOICE28,a0
	BSR.S	CLEAR1
	LEA	VOICE29,a0
	BSR.S	CLEAR1
	LEA	VOICE30,a0
	BSR.S	CLEAR1
	LEA	VOICE31,a0
	BSR.S	CLEAR1

	cmp.b	#1,playpat
	BNE.S	.rt6
	MOVE.B	#0,playpat
	BSR	INVERT_PLAYPATT
.rt6	cmp.b	#1,record
	BNE.S	.rt4
	MOVE.B	#0,record
	BSR	INVERT_RECORD
.rt4	cmp.b	#1,edit
	BNE.S	.rt2
	BSR	INVERT_EDIT
	MOVE.B	#0,edit
.rt2	cmp.b	#1,playsong
	BNE.S	.rt14
	MOVE.B	#0,playsong
	BSR	INVERT_PLAYSONG
.rt14	BSR	AFFPATTERN
	MOVEM.L	(A7)+,D0-A0
	RTS
dernier	dc.b	0
	even
CLEAR1	
	MOVE.L	#0,(a0)
	MOVE.L	#0,4(a0)
	MOVE.L	#0,8(a0)
	MOVE.L	#0,12(a0)
	MOVE.L	#0,16(a0)
	MOVE.L	#0,20(a0)
	*MOVE.L	#0,24(A0)
	MOVE.L	#0,28(A0)
	MOVE.L	#0,32(A0)
	MOVE.L	#0,36(A0)
	MOVE.B	#$40,21(a0)
	MOVE.B	#$40,37(a0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	RTS
************************************************************************
SPESPL	MOVE.B	#0,KEY
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a1
	ADD.l	d0,a1
	CMP.L	#0,LEN_MGT(a1)
	beq.s	.pasdutout
	MOVE.L	a1,heretoconvert
	MOVE.W	#6,okp
.pasdutout
	RTS
heretoconvert
	dc.l	0
**************************************************************************
SPL	MOVE.B  #2,curentmask
	MOVE.W	#0,EH_NON
	bra	pasretourne
SPE	MOVE.B	#5,curentmask
	MOVE.W	#0,EH_NON
	bra	pasretourne	
AVR	MOVE.B	#0,curentmask
	MOVE.W	#0,EH_NON
	bra	pasretourne	
MOD	MOVE.B	#3,curentmask
	MOVE.W	#1,EH_NON
	bra.s	pasretourne	
SAM	MOVE.B	#4,curentmask
	MOVE.W	#0,EH_NON
	bra.s	pasretourne
MAD	MOVE.B	#6,curentmask
	MOVE.W	#1,EH_NON
	bra.s	pasretourne
S3M	MOVE.B	#1,curentmask
	MOVE.W	#1,EH_NON
	bra.s	pasretourne

MSKLOAD
	MOVE.B	#0,KEY
	MOVEQ	#0,d0
	MOVE.B	curentmask,d0
	ADDQ.b	#1,d0
	cmp.b	#10,d0
	BNE.S	.pasr
	MOVE.B	#0,d0
.pasr	MOVE.B	d0,curentmask
pasretourne
	MOVEQ	#0,D0
	MOVE.B	curentmask,D0
	LEA	maskdata,A0
	MOVE.L	(A0,D0.W*4),A0
	LEA	MASQUE,a1
	MOVE.L	(a0)+,(a1)+
	MOVE.B	(a0)+,(a1)+

	BSR	INVERT_4
        
	LEA	dataicone,a0
	MOVE.L	 (A0,D0.W*4),WHERE_MASK
	
	BSR	INVERT_4
	
	MOVE.W	#0,IN_MOD
	MOVE.W	#0,P_MOD
	*MOVE.W	#1,CHANGREP
	MOVE.W	#8,okp
	RTS
	

maskdata	dc.l	maskavr,masks3m,maskspl
		dc.l	maskmod,masksam,maskspe,maskmad,-1
maskavr		dc.b	'*.AVR',0
masks3m		dc.b 	'*.S3M',0
maskspl		dc.b 	'*.SPL',0
maskmod		dc.b 	'*.MOD',0
masksam		dc.b	'*.SAM',0
maskspe		dc.b 	'*.SPE',0
maskmad		dc.b 	'*.MTM',0
		dc.l	-1
dataicone
		DC.L	screen+640*88+8
		DC.L	screen+640*104+64+8
		DC.L	screen+640*96+8
		DC.L	screen+640*88+64+8
		DC.L	screen+640*104+8
		DC.L	screen+640*112+8
		DC.L	screen+640*96+64+8
		
WHERE_MASK	DC.L	0
**************************************************************************
SAUVEUR				* oh! mon sauveur
	MOVE.W	#10,okp
	RTS
SAUVE
	MOVE.L	#DEFAULT,string
	MOVE.B	#12,maxlet
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	curentmask,d1
	LEA	maskavr,a2
	MULU	#6,d1
	ADDQ.W	#2,d1
	ADD.L	d1,a2
	LEA	FILE_LOADED,a0
	MOVE.B	#'*',(a0)
	MOVE.B	#'.',1(a0)
	MOVE.B	(a2),2(a0)
	MOVE.B	1(a2),3(a0)
	MOVE.B	2(a2),4(a0)
	MOVE.B	#0,5(a0)
	LEA	NAMESAMPLE,a0
	MOVE.B	sampledata,d0
	MULU	#13,d0
	ADD.l	d0,a0
	ADDQ.w	#1,a0
	LEA	DEFAULT,a1
	MOVE.L	#0,(a1)+
	MOVE.L	#0,(a1)+
	MOVE.L	#0,(a1)+
	MOVEQ	#8,d0
	LEA	DEFAULT,a1
.ls	cmp.b	#'.',(a0)
	beq.s	.sl
	MOVE.B	(a0)+,(a1)+
	subq	#1,d0
	beq.s	.sl
	bra.s	.ls
.sl	MOVE.B	#'.',(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	#0,(a1)+

sel	MOVEQ	#22,D1
	LEA	rrien,A0
	MOVE.L	#screen+160*9+46,where
	MOVE.W	#0,compt2
	BSR	PRINT

	MOVEQ	#12,d1
	LEA	DEFAULT,a0
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

	CMP.W	#5,erreur
	beq.s	.je_veux_pas
	LEA	PATH,a0
	LEA	AFFICHAGE,a1
	LEA	DEFAULT,a2
.tt2	cmp.b	#0,(a0)
	beq.s	.tt1
	MOVE.B	(a0)+,(a1)+
	bra.s	.tt2
.tt1	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	(a2)+,(a1)+
	MOVE.B	#0,(a1)+
	MOVE.L	#skindata,kind		
	BSR	KIND_OF_LOADED_FILE
.je_veux_pas
	MOVE.W	#0,okp
	MOVE.W	#0,erreur
	RTS
rrien	dc.b	'                      '
**************************************************************************	
LOADER:	MOVE.W	#9,okp
	RTS
LOADE
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+137*640+64+1,where
	MOVE.W	#1,compt2
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
	
	MOVE.B	#$20,(A0)
	LEA	PATH+3,A1
	
	LEA	AFFICHAGE+3,A2
	MOVEQ	#64+8,D0
.CLEAN5	MOVE.B	#0,(A2)+
	DBF	D0,.CLEAN5
	LEA	AFFICHAGE+3,A2
.OUPS	TST.B	(A1)
	BEQ.S	.FOLL
	MOVE.B	(A1)+,(A2)+
	BRA.S	.OUPS
.FOLL	LEA	-3(A2),A2
	MOVE.B	2(A0),(A2)+
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
	MOVE.L	#screen+640*17+144,where
	MOVE.W	#0,compt
	MOVE.W	#0,compt2
	BSR	PRINT
	BSR.S	CHARGE
	MOVEM.L	(A7)+,D0-D7/A0-A6
	CMP.W	#2,erreur
	BEQ.S	ALL_FOLKS
	CMP.B	#3,curentmask
	BEQ.S	ALL_FOLKS
.NON	LEA	18(A0),A0
	BRA	.OUI

CHARGE	
	CMP.W	#-1,IN_MOD
	beq	L_SPL_MOD
	MOVEQ	#0,d1
	MOVE.L	#lkindata,kind		
	BSR	KIND_OF_LOADED_FILE
        MOVEQ	#0,d0
	CMP.W	#0,erreur
	BNE.S	.pascharge
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
        BSR.L	SUM
        BSR	FRE
.pascharge
	MOVE.B	sampledata,dernier
	RTS
ALL_FOLKS
	*MOVE.W	#0,$ffff8240.w
	LEA	FILES_TO_SORT,A0
	MOVEQ	#18,D0
.CLEAN6	BCLR.B	#0,(A0)
	LEA	18(A0),A0
	DBF	D0,.CLEAN6
	JSR	AFF_FS
	
	MOVE.L	#screen+640*32+432,where
	MOVE.W	#0,compt2
	LEA	NAMEMUS,A0
	MOVEQ	#20,D1
	BSR	PRINT
	
	MOVE.W	#0,erreur
	MOVE.B	#0,touche
	MOVE.W	#0,okp
	RTS				* Fin

KIND_OF_LOADED_FILE
	LEA	FILE_LOADED,a0
	MOVE.L	maskdata,a1
	MOVE.L	kind,a2
.icii	MOVE.B	2(a0),d0
	MOVE.B	2(a1),d1
	cmp.b	d0,d1
	BNE.S	.c_pas_ca
	MOVE.B 3(a0),d0
	MOVE.B 3(a1),d1
	cmp.b	d0,d1
	BNE.S	.c_pas_ca
	MOVE.B 4(a0),d0
	MOVE.B 4(a1),d1
	cmp.b	d0,d1
	BNE.S	.c_pas_ca
	MOVE.L	(a2),a2
	jmp	(a2)
.c_pas_ca
	ADDQ.L	#6,a1
	CMP.L	#-1,(a1)
	beq.s	.c_la_fin
	ADDQ.L	#4,a2
	bra.s	.icii
.c_la_fin
	CMP.L	#skindata,kind
	beq.s	.saver
	bra.s	l_spl
.saver	MOVE.W	#4,erreur
	RTS

l_spl:	ADDQ.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	LEA	AFFICHAGE,a0
	BSR	LOAD
	BSR	SEARCHFREESPL
	MOVE.L	a1,a2
	MOVE.B	#$40,VOL_MGT(a1)
	MOVE.L	ENDADDR,DEB_MGT(a1)
	MOVE.L	ENDADDR,LOOP_DEB_MGT(a1)
	MOVE.L	long,d0
	subq.l	#8,d0
	bclr	#0,d0			* Adresse paire
	MOVE.L	d0,LEN_MGT(a1)		* LENGHT
	ADD.l	d0,ENDADDR		* END in memory
	MOVE.L	ENDADDR,FIN_MGT(a1)	* END
	ADD.l	#FINSAMPLE,d0
	ADD.l	#FINSAMPLE,ENDADDR
	MOVE.L	d0,long			* pour la fin du sample
	ADD.l	d0,lensamples
	MOVE.B	setloadfrq,MONO_MGT(a1)	* Set Default Frequency
	BSET.B	#7,MONO_MGT(A1)
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	MOVE.B	#20,NOTE_MGT(A1)
	BSR	SPLTOSPE		* Convertit le spl au ste
	BSR	ZEROFINSPL		* Rajoute 1024 octets nuls
ff4	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#13,d0
	LEA	NAMESAMPLE,a2
	ADD.l	d0,a2
	ADDQ.l	#1,a2
	LEA	AFFICHAGE,a0
.ff1	cmp.b  #0,(a0)+
	BNE.S	.ff1
.ff2	cmp.b  #'\',-(a0)
	BNE.S	.ff2
	ADDQ.l	#1,a0
.ff3	MOVE.B	(a0),(a1)+
	MOVE.B	(a0)+,(a2)+
	cmp.b  #0,(a0)
	beq.s	pasplus
	bra.s	.ff3
pasplus RTS

l_sam:	ADDQ.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	LEA	AFFICHAGE,a0
	BSR	LOAD
	BSR	SEARCHFREESPL
	MOVE.L	a1,a2
	BSET.B	#7,MONO_MGT(A1)
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	MOVE.B	#20,NOTE_MGT(A1)
	MOVE.B	#$40,VOL_MGT(a1)
	MOVE.L	ENDADDR,DEB_MGT(a1)
	MOVE.L	ENDADDR,LOOP_DEB_MGT(a1)
	MOVE.L	long,d0
	SUB.L	#12,d0
	MOVE.L	ENDADDR,a0
	LEA	12(a0),a2
	MOVE.L	d0,d1
.ccc1	MOVE.B	(a2)+,(a0)+
	subq.l	#1,d1
	BNE.S	.ccc1
	MOVE.L	d0,LEN_MGT(a1)
	ADD.l	#FINSAMPLE,d0
	MOVE.L	d0,long
	ADD.l	d0,ENDADDR
	MOVE.L	ENDADDR,FIN_MGT(a1)
	SUB.L	#FINSAMPLE,FIN_MGT(a1)
	BSR	ZEROFINSPL
	bra	ff4
	
l_spe	ADDQ.b	#1,totalsample
	cmp.b	#254,totalsample
	beq	toomuch
	LEA	AFFICHAGE,a0
	BSR	LOAD
	MOVE.L	ENDADDR,a0
	BSR	SEARCHFREESPL
	ADDQ.l	#4,a0
	MOVE.L	a1,a2
	MOVE.L	a1,a4
	
	MOVE.L	#LEN_SAMPLE_MGT-1,D0
.ICI	MOVE.B	(a0)+,(a2)+
	DBF	D0,.ICI
	
	MOVE.L	ENDADDR,d0
	MOVE.L	d0,a0
	MOVE.L	d0,a3
	ADD.l	d0,DEB_MGT(a1)
	ADD.l   d0,FIN_MGT(a1)
	ADD.l	d0,LOOP_DEB_MGT(a1)
	MOVE.L	LEN_MGT(a1),d0
	ADD.l	#FINSAMPLE,d0
	MOVE.L	d0,long
	ADD.l	d0,ENDADDR		*Ou se chargera le prochain sample
	ADD.l	d0,lensamples
	MOVE.L	LEN_MGT(a1),a1		*a1 = longeur
	LEA	LEN_SAMPLE_MGT(a3),a2	*a2 = debut du sample
					*a0 = debut memoire
.conti	MOVE.B	(a2)+,(a0)+		
	subq.l	#1,a1			* et on recopie le sample 40 octets
	BNE.S	.conti			* en arriere
	MOVE.L	a4,a1
	BSR	ZEROFINSPL
	MOVEQ	#0,d0
gff4	MOVE.B	sampledata,d0
	MULU	#13,d0
	LEA	NAMESAMPLE,a2
	ADD.l	d0,a2
	ADDQ.l	#1,a2
	LEA	AFFICHAGE,a0
gff1	cmp.b  #0,(a0)+
	BNE.S	gff1
.gff2	cmp.b  #'\',-(a0)
	BNE.S	.gff2
	ADDQ.l	#1,a0
.gff3	MOVE.B	(a0)+,(a2)+
	cmp.b  #0,(a0)
	beq.s	.pasps
	bra.s	.gff3
.pasps   RTS
	
l_bnk	LEA	AFFICHAGE,a0
	MOVE.L	ADDSPL,ENDADDR
	BSR	LOAD
	BSR	FRE
	LEA	SAMPLE,a1		* replace data
	MOVE.L	ADDSPL,a0
	MOVE.B	4(a0),totalsample
	MOVE.B	5(a0),totalyam
	MOVE.L	6(a0),d0
	subq.l	#1,d0
	LEA	22(a0),a2
.l_bnk1	MOVE.B	(a2)+,(a1)+
	dbf	d0,.l_bnk1

	LEA	SAMPLE,a1		* reloge data
	MOVE.L	ADDSPL,d0
	MOVE.L	#255,d3
.l_bnk2	CMP.L	#0,26(a1)
	beq.s	.l_bnk3
	ADD.l	d0,22(a1)
	ADD.l	d0,30(a1)
	ADD.l	d0,36(a1)
.l_bnk3	ADD.l	#LEN_SAMPLE_MGT,a1
	dbf	d3,.l_bnk2
	;MOVE.L	d1,long
	MOVE.L	14(a0),d1
	ADD.l	d1,ENDADDR
	MOVE.L	18(a0),d1
	ADD.l	d1,ENDADDR
	MOVE.L	d0,lensamples
	MOVE.L	ADDSPL,a2		* replace sample
	ADD.l	6(a0),a2
	ADD.l	10(a0),a2
	MOVE.L	ADDSPL,a1
	MOVE.L	14(a0),d1
	ADD.l	#22,a1
	ADD.l	6(a0),a1
	ADD.l	10(a0),a1
l_bnk4	MOVE.L	(a1)+,(a0)+
	subq.l	#4,d1
	CMP.L	#0,d1
	bgt.s	l_bnk4
	LEA	AFFICHAGE,a0
	LEA	NAMEBANK,a2
	bra	gff1
	RTS
***************************************************************************
l_avr:	ADDQ.B	#1,totalsample
	CMP.B	#254,totalsample
	BEQ	toomuch
	
	LEA	AFFICHAGE,a0
	BSR	LOAD
	
	MOVE.L	ENDADDR,a0
	BSR	SEARCHFREESPL
	
	MOVE.L	a1,a2
	MOVE.L	a1,a4
	MOVE.B	#$40,VOL_MGT(a1)
	MOVE.L	4(a0),(a1)		* ecrit le nom de 8 lettres
	MOVE.L	8(a0),4(a1)
	
	CMP.W	#0,12(a0)
	BNE.S	stereo
	MOVE.B	#129,MONO_MGT(a1)
	BRA.S	mono
stereo	MOVE.B	#1,MONO_MGT(a1)
mono	CMP.W	#8,14(a0)		* sample  8 bits ?
	BEQ.S	bit8
	CMP.W	#16,14(a0)		* sample 16 bits ?
	BEQ.S	bit16
	
	LEA	128(a0),a2		* sinon  12 bits
	MOVE.L	long,d0			
	SUB.L	#128,d0
cvert1	MOVE.B	(a2),d1
	LSR.B	#2,d1			* convertit 12 bits to 8 bits
	MOVE.B d1,(a2)+
	SUBQ.L	#1,d0
	BNE.S	cvert1
	BRA.S	bit8
	BRA	signe
*--------------------------------------------------------------------------	
bit16	MOVE.B	#16,BIT1_MGT(A1)
	MOVE.B	#16,BIT2_MGT(A1)
	
	CMP.W	#-1,16(A0)
	BEQ.S	signe
	
	LEA	128(A0),A2		
	MOVE.L	long,D0
	SUB.L	#128,D0
	MOVE.W	#$8000,D1
	
cvert2	ADD.W	D1,(A2)+
	SUBQ.L	#1,D0
	BNE.S	cvert2
	BRA	signe
*--------------------------------------------------------------------------	
bit8	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	
	CMP.W	#-1,16(A0)
	BEQ.S	signe
	
	LEA	128(A0),A2
	MOVE.L	long,D0
	SUB.L	#128,D0
	MOVE.B	#$80,D1
	
cvert3	ADD.B	D1,(A2)+		* convertit non signe to signe
	SUBQ.L	#1,D0
	BNE.S	cvert3
	
*--------------------------------------------------------------------------	
signe	CMP.W	#0,18(A0)
	BEQ.S	noloop
	MOVE.B	#3,LOOP_MGT(a1)
	MOVE.L	30(a0),d1
	CMP.W	#-1,12(a0)		* loop point
	BNE.S	c_stereo
	ADD.L	D1,D1
c_stereo
	MOVE.L	d1,LOOP_DEB_MGT(a1)	
	MOVE.L	ENDADDR,d1
	ADD.L	d1,LOOP_DEB_MGT(a1)
	MOVE.L	ENDADDR,36(a0)
noloop	MOVE.L	ENDADDR,DEB_MGT(a1)
	MOVE.L	long,LEN_MGT(a1)
	SUB.L	#128,LEN_MGT(a1)
	MOVE.L	LEN_MGT(a1),d1
	ADD.L	DEB_MGT(a1),d1
	MOVE.L	d1,FIN_MGT(a1)
	
	MOVE.L	ENDADDR,a0		* Et on deplace le tout
	MOVE.L	LEN_MGT(a1),d0		* 128 octets en arriere
	LEA	128(A0),A1
	
copii	MOVE.B	(a1)+,(a0)+
	SUBQ.L	#1,D0
	BNE.S	copii
	
	MOVE.L	a4,a1
	BSR	ZEROFINSPL
	MOVE.L	long,d1
	ADD.L	#FINSAMPLE-128,d1
	ADD.L	d1,ENDADDR
	ADD.L	d1,lensamples
	BCLR.B	#0,ENDADDR+3
	BCLR.B	#0,lensamples+3
	BRA	gff4
***************************************************************************	
l_s3m					* LOAD FORMAT S3M
	LEA	AFFICHAGE,A0
	BSR	LOAD
	
	BSR	INITMEG
	BSR	ZEROVOICE
	BSR	DEPLACE
	
	CMP.B	#16,29(A2)		* SONG
	BNE	ZZTOP
	
	MOVE.B	$25(A2),D0		* PATTNUM
	LSL.L	#8,D0
	MOVE.B	$24(A2),D0
	MOVE.B	D0,maxpatt
	
	MOVE.B	#1,maxzic
	
	MOVE.L	ADDSEQ,a0	
	LEA	$60(A2),A1
	MOVE.B	$21(A2),D0		* ORDNUM
	LSL.L	#8,D0
	MOVE.B	$20(A2),D0
	MOVE.B	D0,curseq
	SUBQ.W	#1,D0
.LL	MOVE.B	(A1)+,(A0)+		* sequence des patterns
	DBF	D0,.LL
	MOVE.L	ADDSEQ,A3
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	CMP.B	#-1,-1(A0)
	BNE.S	.MM
	MOVE.B	#0,-1(A0)

.MM	MOVEQ	#0,D0			* DATA SAMPLE
	MOVE.B	$23(A2),D0		* D0 = NB OF SAMPLE
	LSL.L	#8,D0
	MOVE.B	$22(A2),D0
	SUBQ.W	#1,D0
	LEA	SAMPLE,A3
	MOVE.L	#0,lensamples
	MOVE.B	#0,totalsample
	
.PP	MOVEQ	#0,D1
	MOVE.B	1(A1),D1
	LSL.L	#8,D1
	MOVE.B	(A1),D1
	MULU	#16,D1
	LEA	(A2,D1.W),A0		* A0 = INSTRUMENT S3M
	ADDQ.B	#1,totalsample
	
	MOVEQ	#0,D2			* LEN S3M
	MOVE.B	17(A0),D2
	LSL.L	#8,D2
	MOVE.B	16(A0),D2
	*ADD.L	D2,D2
	
	MOVE.L	lensamples,DEB_MGT(A3)
	MOVE.L	D2,LEN_MGT(A3)
	ADD.L	D2,lensamples
	MOVE.L	22(A3),FIN_MGT(A3)
	ADD.L	D2,FIN_MGT(A3)
	ADD.L	#FINSAMPLE,lensamples
	
	MOVEQ	#0,D2			* LOOP START S3M
	MOVE.B	19(A0),D2
	LSL.L	#8,D2
	MOVE.B	18(A0),D2
	*ADD.L	D2,D2
	MOVE.L	D2,LOOP_DEB_MGT(A3)	* LOOP START MGT
	
	MOVE.B	$1C(A0),VOL_MGT(A3)	* VOLUME
	
	LEA	LEN_SAMPLE_MGT(A3),A3
	ADDQ.W	#2,A1
	DBF	D0,.PP
	
	MOVEQ	#0,D0			* PATTERN
	MOVE.B	$25(A2),D0		* D0 = NB OF PATTERN
	LSL.L	#8,D0
	MOVE.B	$24(A2),D0
	MOVE.L	debpatt,A3

L6	MOVEQ	#0,D1
	MOVE.B	1(A1),D1
	LSL.L	#8,D1
	MOVE.B	(A1),D1
	MULU	#16,D1	
	LEA	(A2,D1.W),A0		* A0 = PATTERN S3M
	
L4	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVEQ	#0,D7
	
	MOVE.B	(A0)+,D2
	BEQ	NEW_ROW
	MOVE.B	D2,D3
	AND.B	#$1F,D3			* D3 = # OF VOICE
	
	MOVE.B	D2,D4
	AND.B	#$20,D4
	BEQ.S	.L1
	MOVE.W	(A0)+,(A3,D3.W*4)	* D5 = INSTR + NOTE
	
.L1	MOVE.B	D2,D4
	AND.B	#$40,D4
	BEQ.S	.L2
	MOVE.B	(A0)+,D6		* D6 = VOLUME
	
.L2	AND.B	#$80,D2
	BEQ.S	.L3
	MOVE.B	(A0)+,3(A3,D3.W*4)	* D7 = COMMAND + PARAMETER
	MOVE.B	(A0)+,2(A3,D3.W*4)
	BRA	L4
	
.L3	CMP.B	#0,D6
	BEQ.S	.L5
	MOVE.B	#$C,2(A3,D3.W*4)
	MOVE.B	D6,3(A3,D3.W*4)
	
.L5	BRA	L4

NEW_ROW MOVEQ	#0,D0
	MOVE.B	cvoies,D0
	MULU	#64,D0
	ADD.W	D0,A3
	ADDQ.W	#1,ROW
	CMP.W	#64,ROW
	BEQ.S	NEW_PATT
	BRA	L4
	
NEW_PATT
	ADDQ.W	#2,A1
	ADDQ.W	#1,J
	MOVE.W	J,D0
	CMP.W	maxpatt,D0
	BNE	L6
	

ZZTOP	RTS	
***************************************************************************
L178	MOVE.W	#1,LASTCHAN
L179	MOVE.W	#1,J
L183	MOVE.W	#0,I
L184	MOVE.W	#0,ROW
	
I		DC.W	0
ROW		DC.W	0
J		DC.W	0
LASTCHAN	DC.W	0
MAXCHANS	DC.W	0
***************************************************************************	
l_sng
l_yam
	RTS
toomuch	MOVE.W	#2,erreur
	RTS
	
l_mus
	LEA	AFFICHAGE,A0
	BSR	LOAD
	MOVEQ	#1,D0
	MOVE.L	ENDADDR,A0
	MOVE.L	A0,MADMAX
	ADDQ.L	#8,MADMAX
	JSR	(a0)
	MOVE.L	long,D0
	ADD.L	D0,ENDADDR
	RTS
MADMAX	DC.L	0
*--------------------------------------------------------------------------
l_mad:
l_mod:	LEA	AFFICHAGE,A0
	BSR	LOAD
	MOVE.L	ENDADDR,A0
	CMP.W	#'if',(A0)
	BNE	NOT_MOD_669
	BSR	OFF_134
	BSR	INITMEG
	MOVE.L	ENDADDR,A0
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
	LEA	VOICE11,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE12,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE13,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE14,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE15,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE16,A1
	MOVE.B	#0,25(A1)
	LEA	VOICE17,A1
	MOVE.B	#0,25(A1)
	MOVE.L	long,d0
	MOVE.L	$42E.W,A1
	MOVE.L	a1,a2
	ADD.l	d0,a0
	SUB.L	d0,a2
.reco16	MOVE.L	-(a0),-(a1)
	MOVE.L	-(a0),-(a1)
	subq.l	#8,d0
	bpl.s	.reco16
	MOVE.L	a2,a1
	MOVE.L	a1,a6
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
	MOVE.L	(A0),(A2)
	MOVE.L	4(A0),4(A2)
	MOVE.L	8(A0),8(A2)
	MOVE.B	12(A0),12(A2)
	BSET.B	#7,MONO_MGT(A2)
	MOVE.B	#8,BIT1_MGT(A2)
	MOVE.B	#8,BIT2_MGT(A2)
	MOVE.L	D2,DEB_MGT(A2)		* START
	ADD.W	D3,D2
	MOVE.L	D3,LEN_MGT(A2)
	MOVE.L	D2,FIN_MGT(A2)		* END
	MOVE.B	16(A0),D3
	LSL	#8,D3
	MOVE.B	17(A0),D3
	ADD.L	DEB_MGT(A2),D3
	MOVE.L	D3,LOOP_DEB_MGT(A2)
	MOVE.B	#$40,VOL_MGT(A2)
	ADD.L	#FINSAMPLE,D2
.NOM	ADD.W	#LEN_SAMPLE_MGT,A2
	ADD.W	#25,A0
	DBF	D0,.RECO18
	
	LEA	$71(A1),A2
	MOVE.L	ADDSEQ,A3
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
	MOVE.B	#0,(A2)+
	DBF	D5,.RECO21
	
	REPT	18-8
	MOVE.L	#0,(A2)+
	MOVE.B	#0,(A2)+
	ENDR
	
	DBF	D4,.RECO22
	DBF	D0,.RECO19
	
	MOVE.L	A2,ADDSPL
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
.reco18	ADD.W	#LEN_SAMPLE_MGT,A3
	DBF	D0,.reco17
	MOVE.L	A2,ENDADDR
	SUB.L	ADDSPL,A2
	MOVE.L	A2,lensamples
	
	
	MOVE.W	#5,VOICE0+24
	MOVE.W	#5,VOICE1+24
	MOVE.W	#5,VOICE2+24
	MOVE.W	#5,VOICE3+24
	MOVE.W	#5,VOICE4+24
	MOVE.W	#5,VOICE5+24
	MOVE.W	#5,VOICE6+24
	MOVE.W	#5,VOICE7+24
	MOVE.W	#0,VOICE8+24
	MOVE.W	#0,VOICE9+24
	MOVE.W	#0,VOICE10+24
	MOVE.W	#0,VOICE11+24
	MOVE.W	#0,VOICE12+24
	MOVE.W	#0,VOICE13+24
	MOVE.W	#0,VOICE14+24
	MOVE.W	#0,VOICE15+24
	MOVE.W	#0,VOICE16+24
	MOVE.W	#0,VOICE17+24
	MOVE.B	#8,digvoices
	
	MOVE.B	#0,inpatt
	MOVE.B	#0,yamvoices
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	ADDSEQ,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MULU	#64,D0
	ADD.L	D0,A2
	MOVE.L	A2,ADDPATT
	BSR	NB_VOICE_FRQ
	BSR	SETT
	BSR	AFFPATTERN3
	MOVE.L	#MY_134,$134.W
	RTS
TABLE_669_EFFECT	DC.B	1,2,3,$11,4,$F,0,0
***************************************************************************	
OFF_134:
	MOVEM.L	A0/D0-D1,-(A7)
	MOVE.B	#1,ASK_OFF
.WAIT	CMP.B	#2,ASK_OFF
	BNE.S	.WAIT
	MOVE.B	#0,ASK_OFF
	LEA	MUSDEB,A0
	MOVE.L	#2008-1,D0
	MOVEQ	#0,D1
.OFF	MOVE.L	D1,(A0)+
	DBF	D0,.OFF	
	MOVEM.L	(A7)+,A0/D0-D1
	RTS
ASK_OFF	DC.W	0	
***************************************************************************	
NOT_MOD_669

	IFNE	DEMO
	
	BRA	NOT_MOD_MCS
	
	ELSEIF
	
	CMP.L	#'MCS!',(A0)
	BNE	NOT_MOD_MCS
	
	BSR	OFF_134
	BSR	INITMEG
	BSR	ZEROVOICE
	BSR	DEPLACE
	BSR	ENTETE
	BSR	RECOP_ZIK
	BSR	RECOP_SEQ
	BSR	RECOP_TABLE_SAMPLE
	BSR	RECOP_TABLE_YAM
	BSR	RELOGE_TABLE_SAMPLE
	BSR	RECOP_PATT
	BSR	RECOP_SAMPLE
	BSR	INIT_VOICE
	BSR	NB_VOICE_FRQ
	BSR	SETT
	BSR	AFFPATTERN3
	MOVE.L	#MY_134,$134.W
	RTS
	
	ENDC
*--------------------------------------------------------------------------	
DEPLACE:
	MOVE.L	long,D0
	MOVE.L	$42E.W,A1
	SUB.L	#50,A1
	MOVE.L	A1,A2
	MOVE.L	ENDADDR,A0
	ADD.L	D0,A0
	SUB.L	D0,A2
.reco14	MOVE.L	-(A0),-(A1)
	MOVE.L	-(A0),-(A1)
	SUBQ.L	#8,D0
	BPL.S	.reco14
	RTS
*--------------------------------------------------------------------------	
ENTETE	MOVE.L	A2,A1
	LEA	entete,A0
	MOVEQ	#69,D0
.reco5	MOVE.B	(A1)+,(A0)+
	DBF	D0,.reco5
	LEA	NAMEMUS,A0
	MOVEQ	#19,D0
.xs	MOVE.B	(A1)+,(A0)+
	DBF	D0,.xs
	RTS
*--------------------------------------------------------------------------	
RECOP_ZIK
	MOVE.L	A2,A1
	MOVE.B	snbzic,maxzic
	LEA	MUSIQUE,A0
	MOVEQ	#0,D0
	MOVE.W	slenzic,D0
	ADD.L	sADDzic,A1
.reco6	MOVE.B	(A1)+,(A0)+
	DBF	D0,.reco6
	RTS
*--------------------------------------------------------------------------	
RECOP_SEQ
	MOVE.L	A2,A1
	MOVE.L	ADDSEQ,A0
	MOVE.W	slenseq,D0
	ADD.L	sADDSEQ,A1
.reco7	MOVE.B	(A1)+,(A0)+
	DBF	D0,.reco7
	RTS
*--------------------------------------------------------------------------	
RECOP_TABLE_SAMPLE
	MOVE.L	A2,A1
	MOVE.B	stotalsample,totalsample
	LEA	SAMPLE,A0
	MOVEQ	#0,D0
	MOVE.W	slentablespl,D0
	CMP.W	#0,D0
	BEQ.S	yY1
	ADD.L	sADDtablespl,A1
.reco9	MOVE.B	(A1)+,(A0)+
	DBF	D0,.reco9
yY1	RTS
*--------------------------------------------------------------------------	
RECOP_TABLE_YAM
*	MOVE.L	A2,A1
*	MOVE.B	stotalyam,totalyam
*	LEA	YAM,A0
*	MOVEQ	#0,D0
*	MOVE.W	slentableyam,D0
*	CMP.W	#0,D0
*	BEQ.S	yY1
*	MOVE.L	A2,A1
*	ADD.L	sADDtableyam,A1
*.reco10	MOVE.B	(A1)+,(A0)+
*	DBF	D0,.reco10
	RTS
*--------------------------------------------------------------------------
RELOGE_TABLE_SAMPLE
	LEA	SAMPLE,A0
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	smaxpatt,D1
	ADDQ.B	#1,D1
	MOVE.B	cvoies,D0
	MULU	D0,D1
	MULU	#64,D1
	ADD.L	debpatt,D1
	MOVE.L	#255,D0
.reco12	CMP.L	#0,LEN_MGT(A0)
	BEQ.S	.reco13
	ADD.L	D1,DEB_MGT(A0)
	ADD.L	D1,FIN_MGT(A0)
	ADD.L	D1,LOOP_DEB_MGT(A0)
.reco13	ADD.W	#LEN_SAMPLE_MGT,A0
	DBF	D0,.reco12
	MOVE.L	D1,ADDSPL
	MOVE.L	slensamples,lensamples
	MOVE.L	slenyams,lenyams
	RTS
*--------------------------------------------------------------------------
RECOP_PATT
	MOVE.L	A2,A1
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	MOVEQ	#0,d3
	MOVE.B	smaxpatt,D1
	MOVE.B	D1,maxpatt
	ADDQ.W	#1,D1			* D1 = NB DE PATTERN
	MOVE.L	debpatt,A0		* A0 = ADD DEBUT DEST
	ADD.L	sADDPATT,A1		* A1 = ADD DEBUT SOURCE
	
	MULU	#64,D1
	SUBQ	#1,D1
	MOVE.B	sdigvoices,D0
	ADD.B	syamvoices,D0
	MOVE.L	D0,D3
	MULU	#5,D0
	SUBQ	#1,D0
	
	MOVEQ	#0,D2
	MOVE.B	voies,D2
	SUB.W	D3,D2
	MULU	#5,D2			* 11 - nb voie
	MOVE.L	D0,D3
	MOVEQ	#0,D4
	
.cuisse	MOVE.L	A0,A4

	REPT	18
	MOVE.L	D4,(A4)+
	MOVE.B	D4,(A4)+
	ENDR
	
.orteil	MOVE.B	(A1)+,(A0)+
	DBF	D0,.orteil
	ADD.W	D2,A0
	MOVE.L	D3,D0
	DBF	D1,.cuisse
	RTS
*--------------------------------------------------------------------------
RECOP_SAMPLE
	MOVE.L	A2,A1
	ADD.L	sADDSPL,a1
	MOVE.L	ADDSPL,A5
	MOVE.L	slensamples,D0
	ADD.L	slenyams,D0
.reco15	MOVE.B	(A1)+,(A5)+
	SUBQ.L	#1,D0
	BNE.S	.reco15
	MOVE.L	A5,ENDADDR
	MOVEQ	#0,D1
	MOVE.L	#1023,D0
.reco16	MOVE.L	D1,(a5)+
	DBF	D0,.reco16
	RTS
*--------------------------------------------------------------------------
INIT_VOICE	
	MOVE.B	sdigvoices,digvoices
	MOVE.B	syamvoices,yamvoices
	LEA	VOICE0,A0
	MOVE.B	ssv0,25(A0)
	LEA	VOICE1,A0
	MOVE.B	ssv1,25(A0)
	LEA	VOICE2,A0
	MOVE.B	ssv2,25(A0)
	LEA	VOICE3,A0
	MOVE.B	ssv3,25(A0)
	LEA	VOICE4,A0
	MOVE.B	ssv4,25(A0)
	LEA	VOICE5,A0
	MOVE.B	ssv5,25(A0)
	LEA	VOICE6,A0
	MOVE.B	ssv6,25(A0)
	LEA	VOICE7,A0
	MOVE.B	ssv7,25(A0)
	LEA	VOICE8,A0
	MOVE.B	ssv8,25(A0)
	LEA	VOICE9,A0
	MOVE.B	ssv9,25(A0)
	LEA	VOICE10,A0
	MOVE.B	ssv10,25(A0)
	LEA	VOICE11,A0
	MOVE.B	ssv11,25(A0)
	LEA	VOICE12,A0
	MOVE.B	ssv12,25(A0)
	LEA	VOICE13,A0
	MOVE.B	ssv13,25(A0)
	LEA	VOICE14,A0
	MOVE.B	ssv14,25(A0)
	LEA	VOICE15,A0
	MOVE.B	ssv15,25(A0)
	LEA	VOICE16,A0
	MOVE.B	ssv16,25(A0)
	LEA	VOICE17,A0
	MOVE.B	ssv17,25(A0)
	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	ADDSEQ,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MULU	#64,D0
	ADD.L	D0,A2
	MOVE.L	A2,ADDPATT
	MOVE.B	#0,inpatt
	RTS	
***************************************************************************	
SETT:	*MOVEQ	#0,D0
	*LEA	VOICE0,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+329*160+45,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE1,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+329*160+85,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE2,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+329*160+125,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE3,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+401*160+45,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE4,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+401*160+85,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE5,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+401*160+125,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE6,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+474*160+45,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE7,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+474*160+85,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE8,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+474*160+125,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE9,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+546*160+45,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE10,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+546*160+85,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE11,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+546*160+125,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE12,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+618*160+45,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE13,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+618*160+85,where
	*MOVE.W	#1,compt2
	*BSR	STYL
	*LEA	VOICE14,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+618*160+125,where
	*MOVE.W	#1,compt2
	*BSR.S	STYL
	*LEA	VOICE15,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+690*160+45,where
	*MOVE.W	#1,compt2
	*BSR.S	STYL
	*LEA	VOICE16,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+690*160+85,where
	*MOVE.W	#1,compt2
	*BSR.S	STYL
	*LEA	VOICE17,A0
	*MOVE.B	25(A0),D0
	*MOVE.L  #screen+690*160+125,where
	*MOVE.W	#1,compt2
	*BSR.S	STYL	
	
	BSR	SILENT
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
	MOVE.L	ADDSEQ,A0
	MOVE.B	(A0),curpatt
	
	MOVE.B	curpatt,D0
	MOVE.L  #screen+640*328+448,where
	BSR.S	pouet
	MOVE.B	curseq,d0
	MOVE.L  #screen+640*320+448,where
	BSR.S	pouet
	MOVE.B	curnum,d0
	MOVE.L  #screen+640*312+448,where
	BSR.S	pouet
	MOVE.B	curlen,d0
	MOVE.L  #screen+640*336+448,where
	BSR.S	pouet
	MOVE.B	curlop,d0
	MOVE.L  #screen+640*344+448,where
	BSR.S	pouet
	RTS
pouet	LEA	char3,a0
	BSR	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	RTS
***************************************************************************	
NOT_MOD_MCS				* ALORS C'EST UN MODULE OKTALISER
	MOVE.L	ENDADDR,A1
	CMP.L	#'OKTA',(A1)
	BNE	NOT_OKT_MOD
	
	BSR	OFF_134
	BSR	INITMEG
	MOVE.L	long,D0
	MOVE.L	$42E.W,A0
	MOVE.L	a0,a2
	SUB.L	d0,a2
	ADD.L	D0,A1
.DEPL	MOVE.L	-(A1),-(A0)
	MOVE.L	-(A1),-(A0)
	SUBQ.L	#8,D0
	BPL.S	.DEPL
	MOVE.L	a2,a0
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
	
	BSET.B	#7,MONO_MGT(A1)
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	
	MOVE.W	22(A0),D1
	BCLR	#0,D1
	MOVE.L	D2,DEB_MGT(A1)		* DEB
	MOVE.L	D1,LEN_MGT(A1)		* LEN
	MOVE.L	D2,FIN_MGT(A1)
	ADD.L	D1,FIN_MGT(A1)		* END
	MOVE.L	22(A1),LOOP_DEB_MGT(A1)		* LOOP DEB
	MOVE.B	29(A0),VOL_MGT(A1)		* VOLUME
	ADD.L	D1,D2
	ADD.L	#FINSAMPLE,D2
.NXT	LEA	32(A0),A0
	LEA	LEN_SAMPLE_MGT(A1),A1
	DBF	D0,.NEXT2
	*MOVE.L	D2,lenspl
	*MOVE.L	#0,lenyam
	
	MOVE.L	A6,A0
	ADD.L	#32+36*32,A0
	MOVE.W	#0,u				* SPEED
	MOVE.W	8(A0),v
	MOVE.B	29(A0),MUSIQUE			* LEN  ZIC
	MOVE.B	#0,MUSIQUE+1			* LOOP ZIC
	MOVE.L	ADDSEQ,A1
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
	MOVEQ	#0,D6
	MOVE.B	cvoies,D6
	MULU	D6,D2
	MULU	#64,D2
	MOVE.L	debpatt,A1
	ADD.L	D2,A1
	MOVE.L	A1,ADDSPL
	
	MOVE.L	A1,D1
	MOVEQ	#35,D0
	LEA	SAMPLE,A2
.SXC3	CMP.L	#0,LEN_MGT(A2)
	BEQ.S	.SXC4
	ADD.L	D1,DEB_MGT(A2)
	ADD.L	D1,FIN_MGT(A2)
	ADD.L	D1,LOOP_DEB_MGT(A2)
.SXC4	ADD.W	#LEN_SAMPLE_MGT,A2
	DBF	D0,.SXC3
	
	MOVE.L	A6,A0
.CW2	CMP.L	#'PBOD',(A0)+
	BNE.S	.CW2
	MOVE.L	(A0)+,D1
	MOVE.W	(A0)+,D1
	MOVE.L	debpatt,a1
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d5
	LEA	TABLE_EFF_OKT,A2
	MOVE.B	#8-1,d0			* nb de voies utilisees
	MOVE.B	maxpatt,d1
	MOVEQ	#10*5,d2		* nb de voies restantes
	MOVE.L	d0,d3
	MOVEQ	#63,d4
	
.ecuiss	MOVE.L	a1,a4

	rept	18
	MOVE.L	d5,(a4)+
	MOVE.B	d5,(a4)+
	endr
	
.eortei	MOVEQ	#0,d5
	MOVEQ	#0,d6
	MOVE.B	(a0)+,(a1)+		* note
	MOVE.B	(a0)+,(a1)+		* instrument
	MOVEQ	#0,D5
	MOVE.B	(A0)+,D5		* commande
	MOVE.B	(A2,D5.W),(A1)+
	MOVE.B	(A0)+,(A1)+		* parametre
	MOVE.B	#0,(A1)+
	dbf	d0,.eortei
	ADD.W	d2,a1
	MOVE.L	d3,d0
	dbf	d4,.ecuiss
	ADD.w	#10,a0
	MOVEQ	#63,d4
	dbf	d1,.ecuiss
	
.CW1	CMP.L	#'SBOD',(A6)+
	BNE.S	.CW1
	MOVE.L	(A6)+,D1
	
	MOVE.L	ADDSPL,A1
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
.NOLPS	LEA	LEN_SAMPLE_MGT(A2),A2
	DBF	D0,.SXC
	

REINIT8:

	BSR	DIVIDE_ALL_BY_2

	MOVE.B	#0,inpatt
	MOVE.B	#8,digvoices
	MOVE.B	#0,yamvoices
	MOVE.B	#0,inpatt
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.L	ADDSEQ,A3
	MOVE.L	debpatt,A2
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MULU	#64,D0
	ADD.L	D0,A2
	MOVE.L	A2,ADDPATT
	
	LEA	VOICE0,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE1,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE2,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE3,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE4,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE5,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE6,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	LEA	VOICE7,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	MOVE.B	#0,VOICE8+25
	MOVE.B	#0,VOICE9+25
	MOVE.B	#0,VOICE10+25
	MOVE.B	#0,VOICE11+25
	MOVE.B	#0,VOICE12+25
	MOVE.B	#0,VOICE13+25
	MOVE.B	#0,VOICE14+25
	MOVE.B	#0,VOICE15+25
	MOVE.B	#0,VOICE16+25
	MOVE.B	#0,VOICE17+25
	MOVE.B	#0,VOICE18+25
	MOVE.B	#0,VOICE19+25
	MOVE.B	#0,VOICE20+25
	MOVE.B	#0,VOICE21+25
	MOVE.B	#0,VOICE22+25
	MOVE.B	#0,VOICE23+25
	MOVE.B	#0,VOICE25+25
	MOVE.B	#0,VOICE25+25
	MOVE.B	#0,VOICE26+25
	MOVE.B	#0,VOICE27+25
	MOVE.B	#0,VOICE28+25
	MOVE.B	#0,VOICE29+25
	MOVE.B	#0,VOICE30+25
	MOVE.B	#0,VOICE31+25
	BSR	SET_ON
	
	MOVE.L	#$01010101,VOICE_TAB1
	MOVE.L	#$01010101,VOICE_TAB1+4
	MOVE.L	#$00000000,VOICE_TAB1+8
	MOVE.L	#$00000000,VOICE_TAB1+12
	MOVE.L	#$00000000,VOICE_TAB1+16
	MOVE.L	#$00000000,VOICE_TAB1+20
	MOVE.L	#$00000000,VOICE_TAB1+24
	MOVE.L	#$00000000,VOICE_TAB1+28
	BSR	SET_VS
	
	BSR	NB_VOICE_FRQ
	BSR	SETT
	BSR	AFFPATTERN3
	MOVE.L	#MY_134,$134.W
	RTS
	
TABLE_EFF_OKT		DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,$B,0,0,$F,0
			DC.B	0,0,0,0,0,0
***************************************************************************
NOT_OKT_MOD				* MADISON MODULE ?
	CMP.L	#'M.8.',(A1)
	BNE	NOT_MAD_MOD
	
	BSR	OFF_134
	BSR	INITMEG
	BSR	DEPLACE_MOD
	ADDQ.W	#4,A6
	ADDQ.W	#4,A0
	BSR	INIT_MOD8
	BSR	DATASAMPLE
	ADD.W	#$7E,A_MOD
	BSR	DATAPATT8
	
	MOVE.L	ADDSPL,A0
	LEA	SAMPLE,A1
	LEA	BUFMOD+24,A2	
	BSR	DEP8			* DEPLACE SAMPLE
	BRA	REINIT8
*--------------------------------------------------------------------------
INIT_MOD8
	MOVE.W	#31,MAX_INS
	MOVE.W	#$3B8,W_MOD
	MOVE.W	#$43C,A_MOD
	MOVE.W	#1,IN_MOD
	ADD.W	W_MOD,A0
	MOVE.B	-2(A0),MUSIQUE			* LEN  ZIC
	MOVE.B	#0,MUSIQUE+1			* LOOP ZIC
	MOVE.L	ADDSEQ,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	#($80*2)-1,D0			* ON S'OCCUPE DE LA SEQUENCE
	SUBQ.B	#1,D0
.DRCO8	MOVE.B	(A0),D1
	MOVE.B	(A0)+,(A1)+
	CMP.B	D2,D1
	BLE.S	.DRECO8
	MOVE.B	D1,D2
.DRECO8	DBF	D0,.DRCO8
	MOVE.B	D2,maxpatt
	MOVE.B	#1,maxzic
	ADDQ.L	#1,D2
	MOVE.L	D2,D1
	MOVEQ	#0,D3
	MOVE.B	cvoies,D3
	MULU	D3,D1
	MULU	#64,D1
	MOVE.L	debpatt,A0
	MOVE.L	A0,ADDPATT
	
	MOVE.L	ADDSEQ,A2
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVE.B	(A2),D3
	MOVE.B	cvoies,D2
	MULU	D2,D3
	MULU	#64,D3
	ADD.L	D3,ADDPATT
	
	ADD.L	D1,A0
	MOVE.L	A0,ADDSPL
	MOVE.L	A0,ENDADDR
	MULU	#1024,D2			
	MOVEQ	#0,D0
	ADD.W	A_MOD,D0
	ADD.W	#$80,D0
	ADD.L	D2,D0
	MOVE.L	D0,FIRST_SPL
	RTS
*--------------------------------------------------------------------------
DATAPATT8				* ON S'OCCUPE DES PATTERN
	MOVE.L	A6,A0
	MOVE.L	debpatt,A1
	ADD.W	A_MOD,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE.B	maxpatt,D1
	ADDQ.B	#1,D1
	MULU	#64,D1
	SUBQ	#1,D1
	MOVE.B	#8-1,D0			* nb de voies utilisees
	MOVEQ	#(32-8)*5,D2		* nb de voies restantes
	MOVE.L	D0,D3
	
.dcuisse8
	MOVEQ	#0,D4
	MOVE.L	A1,A4
	
	REPT	32
	MOVE.L	D4,(A4)+
	MOVE.B	D4,(A4)+
	ENDR
	
.dorteil8
	MOVE.B	(a0)+,d5		* note poids fort
	AND.B	#$f,d5
	LSL.W	#8,d5
	MOVE.B	(a0)+,d5		* note poids faible
	LEA	DIGINOTE1,a2
	MOVEQ	#0,d6
	MOVEQ	#53,d4
.fgb8	ADDQ.B	#1,d6
	CMP.W	(a2)+,d5
	BEQ.S	.fga8
	DBF	d4,.fgb8
	MOVEQ	#0,d6
.fga8	MOVE.B	d6,(a1)+
	
	MOVE.B	-2(a0),d5
	AND.B	#$f0,d5
	MOVE.B	(a0)+,d6		* instrument + commande
	MOVE.B	d6,d7
	AND.B	#$f0,d6
	AND.B	#$0f,d7
	LSR.W	#4,d6
	ADD.B	d5,d6
	MOVE.B	d6,(a1)+		* instru
	CMP.B	#$E,d7
	BEQ.S	.e_com8
	MOVE.B	d7,(a1)+		* comm
	MOVE.B	(a0)+,(a1)+		* parametre de commande
	MOVE.B	#0,(A1)+		* VOLUME
.ui8	DBF	d0,.dorteil8
	ADD.W	d2,a1
	MOVE.L	d3,d0
	DBF	d1,.dcuisse8
	RTS
	
.e_com8	MOVE.B	(a0)+,d6
	MOVE.B	d6,d7
	LSR.B	#4,d6
	ADD.B	#$10,d6
	AND.B	#$f,d7
	MOVE.B	d6,(a1)+
	MOVE.B	d7,(a1)+
	MOVE.B	#0,(A1)+
	BRA.S	.ui8
***************************************************************************
NOT_MAD_MOD
	CMP.L	#'8CHN',$438(A1)	* 8 VOIES FAST TRACKER ?
	BEQ	CHN8_MOD
	CMP.L	#'FA08',$438(A1)
	BEQ	CHN8_MOD
	CMP.L	#'CD81',$438(A1)
	BEQ	CHN8_MOD
	BRA	NOT_8CHN_MOD
	
CHN8_MOD
	BSR	OFF_134
	BSR	INITMEG
	BSR	DEPLACE_MOD
	BSR	INIT_MOD_8_V2
	BSR	DATASAMPLE
	BSR	DATAPATT8
	BSR	DEPLACE_SAMPLE
	BRA	REINIT8
***************************************************************************
INIT_MOD_8_V2
	MOVE.W	#31,MAX_INS
	MOVE.W	#$3B8,W_MOD
	MOVE.W	#$43C,A_MOD
	MOVE.W	#1,IN_MOD
	ADD.W	W_MOD,A0
	MOVE.B	-2(A0),MUSIQUE			* LEN  ZIC
	MOVE.B	#0,MUSIQUE+1			* LOOP ZIC
	MOVE.L	ADDSEQ,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	#$7F,D0			* ON S'OCCUPE DE LA SEQUENCE
	SUBQ.B	#1,D0
.DRCO3	MOVE.B	(A0),D1
	MOVE.B	(A0)+,(A1)+
	CMP.B	D2,D1
	BLE.S	.DRECO3
	MOVE.B	D1,D2
.DRECO3	DBF	D0,.DRCO3
	MOVE.B	D2,maxpatt
	MOVE.B	#1,maxzic
	ADDQ.L	#1,D2
	MOVE.L	D2,D1
	MOVEQ	#0,D4
	MOVE.B	cvoies,D4
	MULU	D4,D1
	MULU	#64,D1
	MOVE.L	debpatt,A0
	MOVE.L	A0,ADDPATT
	
	MOVE.L	ADDSEQ,A2
	MOVEQ	#0,D3
	MOVE.B	(A2),D3
	MULU	D4,D3
	MULU	#64,D3
	ADD.L	D3,ADDPATT
	
	ADD.L	D1,A0
	MOVE.L	A0,ADDSPL
	MOVE.L	A0,ENDADDR
	MULU	#2048,D2			
	MOVEQ	#0,D0
	ADD.W	A_MOD,D0
	ADD.L	D2,D0
	MOVE.L	D0,FIRST_SPL
	RTS
***************************************************************************
NOT_8CHN_MOD
	MOVE.L	(A1),D0
	MOVE.B	#' ',D0
	CMP.L	#'MTM ',D0
	BNE	NOT_MTM_MOD

	BSR	OFF_134
	BSR	INITMEG
	BSR	DEPLACE_MOD
	BSR	INIT_MTM
	BSR	DATAPATT_MTM
	BSR	DATASAMPLE_MTM
	BSR	REINIT_MTM
	MOVE.L	#MY_134,$134.W
	RTS
	
PATTERN_ORDER_DATA	DC.L	0
TRACK_DATA		DC.L	0
TRACK_SEQUENCING_DATA	DC.L	0
EXTRA_COMMENT_FIELD	DC.L	0
RAW_SAMPLE_DATA		DC.L	0

*--------------------------------------------------------------------------
REINIT_MTM
	MOVEQ	#0,D0
	MOVE.B	digvoices,D0
	
	CMP.B	#6,D0
	BLT.S	.MM
	
	BSR	DIVIDE_ALL_BY_2
	
.MM	MOVEQ	#0,D0
	MOVE.B	digvoices,D0
	MOVE.L	D0,D1
	MOVE.L	D0,D2
	SUBQ	#1,D1
	SUB.W	#33,D2
	NOT.W	D2
	
	LEA	PILEVOIE,A1
	LEA	VOICE_TAB1,A2
.ZZ	MOVE.L	(A1)+,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#1,(A2)+
	DBF	D1,.ZZ
	
.EE	MOVE.L	(A1)+,A0
	MOVE.B	#0,25(A0)
	MOVE.B	#0,(A2)+
	DBF	D2,.EE
	
	BSR	SET_ON
	BSR	SET_VS

	MOVE.B	#0,yamvoices
	MOVE.B	#0,inpatt
	MOVEQ	#0,D0
	MOVE.L	debpatt,A2
	MOVE.L	ADDSEQ,A3
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MOVEQ	#0,D1
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MULU	#64,D0
	ADD.L	D0,A2
	MOVE.L	A2,ADDPATT
	BSR	NB_VOICE_FRQ
	BSR	SETT
	BSR	AFFPATTERN3
	RTS
*--------------------------------------------------------------------------
DATAPATT_MTM
	MOVE.L	TRACK_SEQUENCING_DATA,A1
	MOVE.L	TRACK_DATA,A2
	MOVE.L	debpatt,A3
	MOVE.L	debpatt,A6
	MOVEQ	#0,D0
	MOVE.B	26(A0),D0
	
BCL2_MTM
	MOVEQ	#32-1,D7
BCL1_MTM
	MOVE.L	A3,A5
	MOVEQ	#0,D1
	MOVEQ	#64-1,D2
	
	MOVE.B	1(A1),D1
	LSL.W	#8,D1
	MOVE.B	(A1),D1
	CMP.B	#0,D1
	BEQ.S	NULL_PATT
	
	SUBQ.L	#1,D1
	MULU.L	#192,D1
	LEA	(A2,D1.L),A4
	
.BCL_MTM
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	MOVE.B	(A4),D3
	LSR.B	#2,D3			* NOTE
	BEQ.S	.MM
	SUB.B	#11,D3
.MM	MOVE.B	D3,(A5)
	MOVE.B	(A4)+,D3
	MOVE.B	(A4),D4
	AND.B	#3,D3
	LSL.B	#4,D3
	LSR.B	#4,D4
	OR.B	D4,D3			* INSTRUMENT
	MOVE.B	D3,1(A5)
	MOVE.B	(A4)+,D3
	AND.B	#$F,D3			* COMMANDE
	MOVE.B	D3,2(A5)
	MOVE.B	(A4)+,3(A5)		* PARAMETRE
	MOVE.B	#0,4(A5)		* VOLUME
	LEA	32*5(A5),A5
	DBF	D2,.BCL_MTM

ICIC	ADDQ.W	#2,A1	
	LEA	5(A3),A3
	MOVE.L	A3,A4
	DBF	D7,BCL1_MTM

	LEA	32*5*64(A6),A6
	MOVE.L	A6,A3	
	DBF	D0,BCL2_MTM
	MOVE.L	A6,ENDADDR
	
	RTS
	
NULL_PATT
	MOVE.L	#0,(A5)
	MOVE.B	#0,4(A5)
	LEA	32*5(A5),A5
	DBF	D2,NULL_PATT
	BRA.S	ICIC
*--------------------------------------------------------------------------
INIT_MTM

	LEA	4(A0),A1
	LEA	NAMEMUS,A2
	MOVEQ	#20-1,D0
.COPO	MOVE.B	(A1)+,(A2)+
	DBF	D0,.COPO

	MOVEQ	#0,D0
	MOVE.B	33(A0),digvoices
	MOVE.B	26(A0),D0
	MOVE.B	D0,maxpatt
	MULU.L	#32*5*64,D0
	MOVE.L	debpatt,A1
	ADD.L	D0,A1
	MOVE.L	A1,ADDSPL
	MOVE.L	A1,ENDADDR
	MOVE.B	#1,maxzic
	LEA	MUSIQUE,A1
	MOVE.B	27(A0),(A1)
	*SUBQ.B	#1,(A1)
	MOVE.B	#0,1(A1)
	
	LEA	66(A0),A1
	MOVEQ	#0,D0
	MOVE.B	30(A0),D0
	MULU	#37,D0
	ADD.L	D0,A1
	MOVE.L	A1,PATTERN_ORDER_DATA
	ADD.L	#128,A1
	MOVE.L	A1,TRACK_DATA
	
	MOVEQ	#0,D0
	MOVE.B	25(A0),D0
	LSL.W	#8,D0
	MOVE.B	24(A0),D0
	MULU.L	#192,D0
	ADD.L	D0,A1
	MOVE.L	A1,TRACK_SEQUENCING_DATA
	MOVEQ	#0,D0
	MOVE.B	26(A0),D0
	ADDQ.W	#1,D0
	MULU	#32*2,D0
	ADD.L	D0,A1
	MOVE.L	A1,EXTRA_COMMENT_FIELD
	
	MOVEQ	#0,D0
	MOVE.B	29(A0),D0
	LSL.W	#8,D0
	MOVE.B	28(A0),D0
	ADD.L	D0,A1
	MOVE.L	A1,RAW_SAMPLE_DATA

	MOVE.L	PATTERN_ORDER_DATA,A1
	MOVE.L	ADDSEQ,A2
	MOVEQ	#$7F,D0
.LL	MOVE.B	(A1)+,(A2)+
	DBF	D0,.LL
	
	LEA	BUFMOD,A1
	LEA	66(A0),A2
	MOVEQ	#0,D0
	MOVE.B	30(A0),D0
	SUBQ.W	#1,D0
	MULU	#37,D0
.SS	MOVE.B	(A2)+,(A1)+
	DBF	D0,.SS
	
	RTS
*--------------------------------------------------------------------------
DATASAMPLE_MTM
	MOVEQ	#0,D0
	MOVEQ	#0,D7
	MOVE.B	30(A0),D0
	SUBQ.W	#1,D0
	LEA	SAMPLE,A1
	LEA	BUFMOD,A2
	MOVE.L	RAW_SAMPLE_DATA,A3
	MOVE.L	ENDADDR,D5
	
SPL_MTM	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)

	MOVE.B	25(A2),D1
	LSL.L	#8,D1
	MOVE.B	24(A2),D1
	LSL.L	#8,D1
	MOVE.B	23(A2),D1
	LSL.L	#8,D1
	MOVE.B	22(A2),D1		* D1 = SAMPLE LENGTH
	CMP.B	#0,D1
	BEQ	.FINT
	
	MOVE.B	29(A2),D2
	LSL.L	#8,D2
	MOVE.B	28(A2),D2
	LSL.L	#8,D2
	MOVE.B	27(A2),D2
	LSL.L	#8,D2
	MOVE.B	26(A2),D2		* D2 = LOOP DEB
	
	MOVE.B	33(A2),D3
	LSL.L	#8,D3
	MOVE.B	32(A2),D3
	LSL.L	#8,D3
	MOVE.B	31(A2),D3
	LSL.L	#8,D3
	MOVE.B	30(A2),D3		* D3 = LOOP END
	
	MOVE.L	D3,D4			* D4 = REAL SAMPLE LENGTH
	*SUB.L	D3,D4
	CMP.L	#2,D4
	BGT.S	.WW
	MOVE.L	D1,D4
	
.WW	MOVE.L	D7,DEB_MGT(A1)	
	MOVE.L	D7,FIN_MGT(A1)	
	MOVE.L	D7,LOOP_DEB_MGT(A1)
	ADD.L	D5,DEB_MGT(A1)
	ADD.L	D5,FIN_MGT(A1)
	ADD.L	D5,LOOP_DEB_MGT(A1)
	
	MOVE.L  D4,LEN_MGT(A1)
	ADD.L	D4,FIN_MGT(A1)
	
	MOVE.L	DEB_MGT(A1),A4
	MOVE.L	A3,A5
	MOVE.L	D4,-(A7)
	
.UU	MOVE.B	(A5)+,D6
	ADD.B	#$80,D6
	MOVE.B	D6,(A4)+
	SUBQ.L	#1,D4
	BNE.S	.UU
	
	MOVE.L	(A7)+,D4
	ADD.L	D2,LOOP_DEB_MGT(A1)
	
	CMP.L	#0,D2
	BNE.S	.LLOOPP
	
	MOVE.B	#1,LOOP_MGT(A1)
	BSR	ZEROFINSPL
	BRA.S	.MLML
	
.LLOOPP	MOVE.B	#3,LOOP_MGT(A1)
	BSR	BCLFINSPL
	
.MLML	MOVE.B	34(A2),F_TUNE_MGT(A1)
	MOVE.B	35(A2),VOL_MGT(A1)
	MOVE.B	#20,NOTE_MGT(A1)
	MOVE.B	#0,COMMAND_MGT(A1)
	MOVE.B	#0,PARAM_MGT(A1)
	BTST.B	#0,36(A2)
	BEQ.S	.MTM_8
	
	MOVE.B	#16,BIT1_MGT(A1)
	MOVE.B	#16,BIT2_MGT(A1)
	BRA.S	.MM
	
.MTM_8	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	
.MM	ADD.L	D4,lensamples
	ADD.L	#FINSAMPLE,D4
	ADD.L	D4,D7
	
.FINT	ADD.L	D1,A3
	LEA	37(A2),A2
	LEA	LEN_SAMPLE_MGT(A1),A1
	DBF	D0,SPL_MTM
	
	MOVE.L	A4,ENDADDR
	ADD.L	#FINSAMPLE,ENDADDR
	
	RTS
***************************************************************************
NOT_MTM_MOD				* ALORS C'EST UN MODULE AMIGA

	BSR	OFF_134
	BSR	INITMEG
	BSR	DEPLACE_MOD
	BSR	INIT_MOD
	BSR	DATASAMPLE
	BSR	DATAPATT
	BSR	DEPLACE_SAMPLE
	BSR	REINIT
	MOVE.L	#MY_134,$134.W
	RTS
*--------------------------------------------------------------------------	
DEPLACE_MOD:
	MOVE.L	ENDADDR,A1
	MOVE.L	#$43C-1,D0
	LEA	BUFMOD,A0
.DEPL2	MOVE.B	(A1)+,(A0)+
	DBF	D0,.DEPL2
	
	MOVE.L	ENDADDR,A1
	MOVE.L	long,D0
	BCLR	#0,D0
	MOVE.L	$42E.W,A0
	SUB.L	#50,A0
	MOVE.L	A0,A2
	SUB.L	D0,A2
	ADD.L	D0,A1
.DEPL3	MOVE.L	-(A1),-(A0)
	MOVE.L	-(A1),-(A0)
	SUBQ.L	#8,D0
	BPL.S	.DEPL3
	MOVE.L	A2,A0
	MOVE.L	A2,A6
	BSR	ZEROVOICE
	RTS
*--------------------------------------------------------------------------
INIT_MOD
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
	MOVE.L	ADDSEQ,A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	#$7F,D0			* ON S'OCCUPE DE LA SEQUENCE
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
	MOVEQ	#0,D4
	MOVE.B	cvoies,D4
	MULU	D4,D1
	MULU	#64,D1
	MOVE.L	debpatt,A0
	MOVE.L	A0,ADDPATT
	
	MOVE.L	ADDSEQ,A2
	MOVEQ	#0,D3
	MOVE.B	(A2),D3
	MULU	D4,D3
	MULU	#64,D3
	ADD.L	D3,ADDPATT
	
	ADD.L	D1,A0
	MOVE.L	A0,ADDSPL
	MOVE.L	A0,ENDADDR
	MULU	#1024,D2			
	MOVEQ	#0,D0
	ADD.W	A_MOD,D0
	ADD.L	D2,D0
	MOVE.L	D0,FIRST_SPL
	
	MOVE.L	A6,A2
	LEA	NAMEMUS,A0
	MOVEQ	#20-1,D0
.COP	MOVE.B	(A2)+,(A0)+
	DBF	D0,.COP
	RTS
*--------------------------------------------------------------------------
DATASAMPLE	
	MOVE.L	A6,A2			* ON S'OCCUPE DES DATA SAMPLE
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
	
	MOVE.L	ENDADDR,DEB_MGT(a1)	* START
	MOVEQ	#0,D2
	MOVE.W	26(A2),D2		* FIRST LOOP POINT
	ADD.L	D2,D2			* ON DOUBLE
	ADD.L	22(A1),D2
	MOVE.L	D2,LOOP_DEB_MGT(A1)
	CMP.W	#1,28(a2)
	BEQ.S	.dnolop1
	MOVE.B	#3,LOOP_MGT(A1)
	MOVEQ	#0,d0			* Ici je retablie la fin
	MOVE.W	28(a2),d0		* du sample en fonction
	ADD.L	d0,d0			* de son debut,de son point
	ADD.L	LOOP_DEB_MGT(a1),d0	* de loop et de la longueur
	MOVE.L	DEB_MGT(a1),d2		* du loop
	SUB.L	d2,d0
	BRA.S	.dnolop
.dnolop1	MOVE.B	#1,LOOP_MGT(A1)
	
.dnolop	MOVE.L	D0,LEN_MGT(A1)
	ADD.L	D0,ENDADDR
	MOVE.L	ENDADDR,FIN_MGT(A1)
	ADD.L	#FINSAMPLE,D0
	ADD.L	#FINSAMPLE,ENDADDR
	ADD.L	D0,lensamples
	MOVE.B	#$81,MONO_MGT(a1)	* Set Default Frequency
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	MOVE.B	#20,NOTE_MGT(A1)
	MOVE.B	#0,COMMAND_MGT(A1)
	MOVE.B	#0,PARAM_MGT(A1)
	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)
	MOVE.B	24(A2),20(A1)		* FINE TUNE
	MOVE.B	25(A2),VOL_MGT(A1)	* VOLUME
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
	LEA	LEN_SAMPLE_MGT(A1),A1
	DBF	D3,DPETIT
	RTS
*--------------------------------------------------------------------------
DATAPATT				* ON S'OCCUPE DES PATTERN
	MOVE.L	A6,A0
	MOVE.L	debpatt,A1
	ADD.W	A_MOD,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D5
	MOVEQ	#0,D6
	MOVE.B	maxpatt,D1
	ADDQ.B	#1,D1
	MULU	#64,D1
	SUBQ	#1,D1
	MOVEQ	#4-1,D0			* nb de voies utilisees
	MOVE.L	#(32-4)*5,D2		* nb de voies restantes
	MOVE.L	D0,D3
	
.dcuisse
	MOVEQ	#0,D4
	MOVE.L	A1,A4
	
	REPT	32
	MOVE.L	D4,(A4)+
	MOVE.B	D4,(A4)+
	ENDR
	
.dorteil
	MOVE.B	(a0)+,d5		* note poids fort
	AND.B	#$f,d5
	LSL.W	#8,d5
	MOVE.B	(a0)+,d5		* note poids faible
	LEA	DIGINOTE1,a2
	MOVEQ	#0,d6
	MOVEQ	#53,d4
.fgb	ADDQ.B	#1,d6
	CMP.W	(a2)+,d5
	BEQ.S	.fga
	DBF	d4,.fgb
	MOVEQ	#0,d6
.fga	MOVE.B	d6,(a1)+
	
	MOVE.B	-2(a0),d5
	AND.B	#$f0,d5
	MOVE.B	(a0)+,d6		* instrument + commande
	MOVE.B	d6,d7
	AND.B	#$f0,d6
	AND.B	#$0f,d7
	LSR.W	#4,d6
	ADD.B	d5,d6
	MOVE.B	d6,(a1)+		* instru
	CMP.B	#$E,d7
	BEQ.S	.e_com
	MOVE.B	d7,(a1)+		* comm
	MOVE.B	(a0)+,(a1)+		* parametre de commande
	MOVE.B	#0,(A1)+
.ui	DBF	d0,.dorteil
	ADD.W	d2,a1
	MOVE.L	d3,d0
	DBF	d1,.dcuisse
	RTS
	
.e_com	MOVE.B	(a0)+,d6
	MOVE.B	d6,d7
	LSR.B	#4,d6
	ADD.B	#$10,d6
	AND.B	#$f,d7
	MOVE.B	d6,(a1)+
	MOVE.B	d7,(a1)+
	MOVE.B	#0,(A1)+
	BRA.S	.ui
*--------------------------------------------------------------------------
DEPLACE_SAMPLE				* ON S'OCCUPE DES SAMPLE
.sspl	MOVE.L	ADDSPL,A0
	LEA	SAMPLE,A1
	LEA	BUFMOD+20,A2
DEP8	ADD.L	FIRST_SPL,A6
	MOVE.L	A6,A5
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.W	MAX_INS,D0
	SUBQ	#1,D0
.TROU	MOVE.L	LEN_MGT(A1),D1
	BEQ.S	.NO_LEN
.PAU	MOVE.B	(A6)+,(A0)+
	SUBQ.L	#1,D1
	BNE.S	.PAU
	CMP.B	#3,LOOP_MGT(A1)
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
	LEA	LEN_SAMPLE_MGT(A1),A1
	DBF	D0,.TROU
	
*	MOVEQ	#31,D5
*	LEA	SAMPLE,A2
*.LI	TST.L	26(A2)
*	BEQ.S	.LT
*.LI3	MOVE.L	A2,heretoconvert
*	BSR	D_2
*.LT	ADD.W	#LEN_SAMPLE_MGT,A2
*	DBF	D5,.LI
	RTS
*--------------------------------------------------------------------------
REINIT
	LEA	PILEVOIE,A1
	MOVE.L	(A1)+,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	MOVE.L	(A1)+,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	MOVE.L	(A1)+,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	MOVE.L	(A1)+,A0
	MOVE.B	#5,25(A0)
	MOVE.B	#8,38(A0)
	MOVE.B	#$80,31(A0)
	
	MOVEQ	#32-4-1,D0
	
.COP	MOVE.L	(A1)+,A0
	MOVE.B	#0,25(A0)
	MOVE.B	#0,(A2)+
	DBF	D0,.COP
	BSR	SET_ON
	
	MOVE.L	#$01010101,VOICE_TAB1
	MOVE.L	#$00000000,VOICE_TAB1+4
	MOVE.L	#$00000000,VOICE_TAB1+8
	MOVE.L	#$00000000,VOICE_TAB1+12
	MOVE.L	#$00000000,VOICE_TAB1+16
	MOVE.L	#$00000000,VOICE_TAB1+20
	MOVE.L	#$00000000,VOICE_TAB1+24
	MOVE.L	#$00000000,VOICE_TAB1+28
	BSR	SET_VS

	MOVE.B	#4,digvoices
	MOVE.B	#0,yamvoices
	MOVE.B	#0,inpatt
	MOVEQ	#0,D0
	MOVE.L	debpatt,A2
	MOVE.L	ADDSEQ,A3
	MOVE.B	(A3),D0
	MOVE.B	D0,curpatt
	MOVEQ	#0,D1
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MULU	#64,D0
	ADD.L	D0,A2
	MOVE.L	A2,ADDPATT
	BSR	NB_VOICE_FRQ
	BSR	SETT
	BSR	AFFPATTERN3
	RTS
***************************************************************************
NB_VOICE_FRQ
	MOVEQ	#0,D0
	MOVE.B	digvoices,D0
	LEA	VOL_GEN,A0
	*MOVE.B	(A0,D0.W),VOLUME_GENERAL
	LEA	VGA_FRQ_TAB,A0
	MOVE.L	(A0,D0.W*4),DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	BSR	FREQUENCE_030
	RTS
	
VGA_FRQ_TAB
	DC.L	$49170,$49170,$49170,$49170,$49170,$49170,$49170,$49170
	DC.L	$32780,$32780,$32780,$32780
	DC.L	$24585,$24585,$24585
	DC.L	$19668,$19668,$19668,$19668,$19668
	DC.L	$16390,$16390,$16390,$16390
	DC.L	$12292,$12292,$12292,$12292,$12292,$12292,$12292,$12292,$12292
	
VOL_GEN DC.B	0,0,0,0,0,7,7,7,7,15,15,15,15,15,15,15
	DC.B	15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
***************************************************************************
SET_VS
	LEA	VOICE_TAB,A0
	LEA	VOICE_TAB1,A1
	LEA	V_TAB_SCR,A2
	MOVEQ	#31,D0
	
.ILI	MOVE.B	(A0)+,D1
	MOVE.B	(A1)+,D2
	MOVE.L	(A2)+,A3
	CMP.B	D1,D2
	BEQ.S	.FIN
	
	MOVE.B	D2,-1(A0)
	BTST	#0,D0
	BEQ.S	.SV1
	MOVEQ	#7,D3
.LOPO	NOT.B	1(A3)
	NOT.W	16(A3)
	LEA	640(A3),A3
	DBF	D3,.LOPO
	BRA	.FIN
.SV1	MOVEQ	#7,D3
.LOP2	NOT.W	(A3)
	NOT.B	16(A3)
	LEA	640(A3),A3
	DBF	D3,.LOP2
.FIN	DBF	D0,.ILI
	RTS
***************************************************************************
ZEROVOICE
	LEA	VOICE0,A5
	BSR	CLEAR2
	LEA	VOICE1,A5
	BSR	CLEAR2
	LEA	VOICE2,A5
	BSR	CLEAR2
	LEA	VOICE3,A5
	BSR	CLEAR2
	LEA	VOICE4,A5
	BSR.S	CLEAR2
	LEA	VOICE5,A5
	BSR.S	CLEAR2
	LEA	VOICE6,A5
	BSR.S	CLEAR2
	LEA	VOICE7,A5
	BSR.S	CLEAR2
	LEA	VOICE8,A5
	BSR.S	CLEAR2
	LEA	VOICE9,A5
	BSR.S	CLEAR2
	LEA	VOICE10,A5
	BSR.S	CLEAR2
	LEA	VOICE11,A5
	BSR.S	CLEAR2
	LEA	VOICE12,A5
	BSR.S	CLEAR2
	LEA	VOICE13,A5
	BSR.S	CLEAR2
	LEA	VOICE14,A5
	BSR.S	CLEAR2
	LEA	VOICE15,A5
	BSR.S	CLEAR2
	LEA	VOICE16,A5
	BSR.S	CLEAR2
	LEA	VOICE17,A5
	BSR.S	CLEAR2
	LEA	MUSDEB,A5
	MOVE.L	#(4*1004*2)/4-1,D2
	MOVEQ	#0,D1
.CC1	MOVE.L	D1,(A5)+
	DBF	D2,.CC1
	RTS
CLEAR2
	MOVE.L	#0,(A5)
	MOVE.L	#0,4(A5)
	MOVE.L	#0,8(A5)
	MOVE.L	#0,12(A5)
	MOVE.L	#0,16(A5)
	MOVE.L	#0,20(A5)
	MOVE.L	#0,24(A5)
	MOVE.L	#0,28(A5)
	MOVE.L	#0,32(A5)
	MOVE.L	#0,36(A5)
	MOVE.L	#0,38(A5)
	MOVE.L	#0,42(A5)
	MOVE.L	#0,46(A5)
	MOVE.L	#0,50(A5)
	MOVE.L	#0,54(A5)
	MOVE.L	#0,58(A5)
	MOVE.L	#0,62(A5)
	MOVE.B	#$40,21(A5)
	MOVE.B	#$40,37(A5)
	MOVE.B	#8,38(A5)
	MOVE.B	#$80,31(A5)
	RTS
***************************************************************************
l_spl_mod
	CMP.W	#1,IN_MOD
	BEQ.S	.L_
	MOVE.W	#-1,IN_MOD
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
	MOVE.W	#0,okp
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
	;ADD.w	#$111,$ff8240
	BCLR.B	#0,24(A2)
	MOVE.L	ENDADDR,-(a7)
	MOVE.L	D2,-(A7)
	MOVE.W	CANAL_MOD,-(A7)
	MOVE.W	#$3F,-(SP)
	TRAP	#1
	ADDA.L	#$C,SP
	BSR	SEARCHFREESPL
	ADDQ.b	#1,totalsample
	MOVE.L	ENDADDR,DEB_MGT(a1)	* START

	MOVEQ	#0,D2
	MOVE.W	26(A2),D2		* FIRST LOOP POINT
	ADD.L	D2,D2			* ON DOUBLE
	ADD.L	DEB_MGT(A1),D2
	MOVE.L	D2,LOOP_DEB_MGT(A1)
	MOVE.B	25(a2),VOL_MGT(a1)

	CMP.W	#1,28(a2)
	beq.s	.nolop1
	MOVE.B	#3,LOOP_MGT(a1)
	MOVEQ	#0,d0			* Ici je retablie la fin
	MOVE.W	28(a2),d0		* du sample en fonction
	ADD.l	d0,d0			* de son debut,de son point
	ADD.l	LOOP_DEB_MGT(a1),d0	* de loop et de la longueur
	MOVE.L	DEB_MGT(a1),d2		* du loop
	SUB.L	d2,d0
	ADD.l	d0,ENDADDR
	MOVE.L	ENDADDR,FIN_MGT(a1)		* END
	BSR	BCLFINSPL
	BRA.S	.nolop
.nolop1	ADD.l	d0,ENDADDR
	MOVE.L	ENDADDR,FIN_MGT(a1)
	BSR	ZEROFINSPL
.nolop	MOVE.L	D0,LEN_MGT(A1)

	ADD.l	#FINSAMPLE,d0
	ADD.l	d0,lensamples
	ADD.l	#FINSAMPLE,ENDADDR
	MOVE.L	d0,long
	MOVE.B	#$81,MONO_MGT(a1)		* Set Default Frequency
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#13,d0
	LEA	NAMESAMPLE,a3
	ADD.l	d0,a3
	ADDQ.l	#1,a3
	MOVE.B	(A2),(A3)
	MOVE.B	1(A2),1(A3)
	MOVE.B	2(A2),2(A3)
	MOVE.B	3(A2),3(A3)
	MOVE.B	4(A2),4(A3)
	MOVE.B	5(A2),5(A3)
	MOVE.B	6(A2),6(A3)
	MOVE.B	7(A2),7(A3)
	MOVE.L	a1,a0
        BSR	SUM
	BSR	FRE
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
	*MOVE.W	#0,$ffff8240.w
	MOVE.W	#0,okp
	RTS



CANAL_MOD	DC.W	0	* # CANAL DU FICHIER
MAX_INS	DC.W	0		* NB MAX D'INSTRUMENTS
IN_MOD	DC.W	0		* SI = 1 ALORS ON EST DANS UN MODULE
A_MOD	DC.W	0		* POINTEUR DANS MOD (ADD_PARTITION)
P_MOD	DC.W	0		* POINTEUR FILESELECT
W_MOD	DC.W	0		* POINTEUR DANS MOD (ADD_SEQUENCE)
FIRST_SPL	DC.L	0	* ADRESSE PREMIER SPL DANS MOD (RELATIF)
BUFMOD	DS.L	$4D0
kind	dc.l	lkindata
lkindata	
	dc.l	l_avr,l_s3m,l_spl,l_mod,l_sam,l_spe,l_mad
skindata
	dc.l	s_avr,s_s3m,s_spl,s_mod,s_sam,s_spe,s_mad


	IFNE	DEMO
s_avr
s_s3m
s_spl
s_mod
s_sam
s_spe
s_mad	RTS

	ELSEIF
	
s_spl	MOVEQ	#0,D0
	MOVE.B	sampledata,D0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	MOVE.L	a0,a1
	MOVE.L	a0,a2
	BSR	SPLTOSPE
	MOVE.L	22(a2),a1
	MOVE.L	26(a2),d1
	LEA	AFFICHAGE,a0
	BSR	SAVE
	MOVE.L	a2,a1
	BSR	SPLTOSPE
	RTS
s_spe	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	MOVE.L	a0,hihi
	MOVE.L	DEB_MGT(a0),a1		*
	SUB.L	#44,a1			*
	MOVE.L	a1,haha			*Recopie de l'adresse du sample -40
	LEA	buffer,a2		*dans un buffer
	MOVE.W	#10,d0			*
.recop1	MOVE.L	(a1)+,(a2)+		*
	dbf	d0,.recop1		*

	MOVE.L	haha,a1			*
	MOVE.L	#'SPE!',(a1)+		*
	MOVE.W	#9,d0			*Recopie des donnes sur le sample
.recop2	MOVE.L	(a0)+,(a1)+		*40 octets avant le sample
	dbf	d0,.recop2		*
	MOVE.L	hihi,a0
	MOVE.L	haha,a1
	ADDQ.w	#4,a1
	MOVE.L	DEB_MGT(a0),d0		*Servira pour le relogeage
	SUB.L	d0,DEB_MGT(a1)		*lors d'un prochain load
	SUB.L	d0,FIN_MGT(a1)		*de ce sample
	SUB.L	d0,LOOP_DEB_MGT(a1)	*A la limite on peut mettre 0 (sauf a celui la)
	MOVE.L	LEN_MGT(a1),d1
	ADD.l	#44,d1
	MOVE.L	haha,a1
	LEA	AFFICHAGE,a0
	BSR	SAVE
	LEA	buffer,a0		*
	MOVE.L	haha,a1			*Replace les donnees du buffer
	MOVE.W	#10,d0			*a 40 octets du sample
.recop3	MOVE.L	(a0)+,(a1)+		*sauvgarde
	dbf	d0,.recop3		*
	RTS
hihi	dc.l	0
haha	dc.l	0
buffer	ds.b	44


s_bnk	LEA	SAMPLE,a0		* deloge data
	MOVE.L	#s1,d0
	MOVE.L  #255,d1

.s_bnk1	CMP.L	#0,26(a0)
	beq.s	.s_bnk2
	SUB.L	d0,22(a0)
	SUB.L	d0,30(a0)
	SUB.L	d0,36(a0)
	MOVE.L	a0,d3			* Adresse dernier SAMPLE
.s_bnk2	ADD.l	#LEN_SAMPLE_MGT,a0
	dbf	d1,.s_bnk1
	MOVE.L	#SAMPLE,d4
	SUB.L	d4,d3			* Len SAMPLE
	ADD.l	#LEN_SAMPLE_MGT,d3

	clr.w 	-(sp)			* Sauve data SAMPLE
 	pea	AFFICHAGE
 	MOVE.W #$3c,-(sp)
 	trap 	#1
 	ADDQ.l 	#8,sp
 	MOVE.W d0,d2

	LEA	SAMPLE-22,a0
	MOVE.L	#'BNK!',(a0)+
	MOVE.B	totalsample,(a0)+
	MOVE.B	totalyam,(a0)+
	MOVE.L	d3,(a0)+		* Len DATA SAMPLE
	MOVE.L	#0,(a0)+		* Len DATA YAMAHA
	MOVE.L	lensamples,(a0)+
	MOVE.L	lenyams,(a0)+

	ADD.l	#22,d3
 	pea	SAMPLE-22
 	MOVE.L d3,-(sp)
 	MOVE.W d2,-(sp)
 	MOVE.W #$40,-(sp)
 	trap 	#1
 	ADD.l 	#12,sp

	LEA	SAMPLE,a0		* reloge data
	MOVE.L	#s1,d0
	MOVEQ	#0,d1
	MOVE.L	#255,d3
.s_bnk3	CMP.L	#0,26(a0)
	beq.s	.s_bnk4
	ADD.l	d0,22(a0)
	ADD.l	d0,30(a0)
	ADD.l	d0,36(a0)
.s_bnk4	ADD.l	#LEN_SAMPLE_MGT,a0
	dbf	d3,.s_bnk3

	MOVE.L	lensamples,d1
	ADD.l	lenyams,d1
 	pea	s1		* sauve sample
 	MOVE.L d1,-(sp)
 	MOVE.W d2,-(sp)
 	MOVE.W #$40,-(sp)
 	trap 	#1
 	ADD.l 	#12,sp

 	MOVE.W d2,-(sp)			* ferme fichier
 	MOVE.W #$3e,-(sp)
 	trap 	#1
 	ADDQ.l #4,sp
	BSR	SAVENAME
	RTS

s_ptn
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	curpatt,d0
	MOVE.L	ADDPATT,a1
	MOVE.B	cvoies,d1
	MULU	d1,d0
	MULU	#64,d0			
	MULU	#64,d1			* longueur d'une ptn
	;ADD.l	d0,a1
	MOVE.L	-(a1),-(a7)
	MOVE.W	-(a1),-(a7)
	MOVE.L	#'PTN!',(a1)
	MOVE.B	yamvoices,4(a1)	
	MOVE.B	digvoices,5(a1)	
	LEA	AFFICHAGE,a0
	BSR	SAVE
	MOVE.W	(a7)+,(a1)+
	MOVE.L	(a7)+,(a1)+
	RTS
*--------------------------------------------------------------------------
s_mod	MOVEQ	#0,d0
	MOVE.L	#'MCS!',entete

	LEA	VOICE0,a0
	MOVE.B	25(a0),ssv0
	LEA	VOICE1,a0
	MOVE.B	25(a0),ssv1
	LEA	VOICE2,a0
	MOVE.B	25(a0),ssv2
	LEA	VOICE3,a0
	MOVE.B	25(a0),ssv3
	LEA	VOICE4,a0
	MOVE.B	25(a0),ssv4
	LEA	VOICE5,a0
	MOVE.B	25(a0),ssv5
	LEA	VOICE6,a0
	MOVE.B	25(a0),ssv6
	LEA	VOICE7,a0
	MOVE.B	25(a0),ssv7
	LEA	VOICE8,a0
	MOVE.B	25(a0),ssv8
	LEA	VOICE9,a0
	MOVE.B	25(a0),ssv9
	LEA	VOICE10,a0
	MOVE.B	25(a0),ssv10
	LEA	VOICE11,a0
	MOVE.B	25(a0),ssv11
	LEA	VOICE12,a0
	MOVE.B	25(a0),ssv12
	LEA	VOICE13,a0
	MOVE.B	25(a0),ssv13
	LEA	VOICE14,a0
	MOVE.B	25(a0),ssv14
	LEA	VOICE15,a0
	MOVE.B	25(a0),ssv15
	LEA	VOICE16,a0
	MOVE.B	25(a0),ssv16
	LEA	VOICE17,a0
	MOVE.B	25(a0),ssv17

	LEA	SAMPLE,A0
	MOVE.L	A0,A1
	CMP.B	#0,totalsample
	BEQ.S	.sm7
	ADD.L	#254*LEN_SAMPLE_MGT,A0
.sm2	CMP.L	#0,LEN_MGT(A0)
	BNE.S	.sm3
	SUB.L	#LEN_SAMPLE_MGT,A0
	BRA.S	.sm2
.sm3	ADD.L	#LEN_SAMPLE_MGT,A0
.sm7	SUB.L	A1,A0
	MOVE.W	A0,slentablespl
	MOVE.L	#90,sADDtablespl

*	LEA	YAMAHA,a0
*	MOVE.L	a0,a1
*	CMP.B	#0,totalyam
*	BEQ.S	.sm6
*	ADD.L	#254*40,a0
*.sm4	CMP.L	#0,26(a0)
*	BNE.S	.sm5
*	SUB.L	#LEN_SAMPLE_MGT,d0
*	BRA.S	.sm4
*.sm5	ADD.L	#LEN_SAMPLE_MGT,a0
*.sm6	SUB.L	a1,a0
*	MOVE.W	a0,slentableyam
*	MOVE.W	slentablespl,d0
*	ADD.L	sADDtablespl,d0
*	MOVE.L	d0,sADDtableyam

	MOVE.B	yamvoices,syamvoices
	MOVE.B	digvoices,sdigvoices
	MOVE.B	yamvoices,d0
	ADD.B	digvoices,d0
	MOVE.B	d0,svoies
	MOVE.B	#0,sarrang		*
	MOVEQ	#0,d0
	MOVE.B	maxzic,d0
	MOVE.W	d0,d1
	MOVE.B	d0,snbzic
	MULU	#2,d0
	MOVE.W	d0,slenzic
	MOVE.W	slentableyam,d0
	ADD.L	sADDtableyam,d0
	MOVE.L	d0,sADDzic		*
	MULU	#256,d1
	MOVE.W	d1,slenseq
	MOVEQ	#0,d0
	MOVE.W	slenzic,d0
	ADD.L	sADDzic,d0
	MOVE.L	d0,sADDSEQ
	MOVEQ	#0,d0
	SUBQ.W	#1,d1
	
	MOVE.L	ADDSEQ,a0		* ne sauve que les patterns
.find	CMP.B	(a0),d0			* utilisees
	BGE.S	.find2
	MOVE.B	(a0),d0
.find2	ADDQ.W	#1,a0
	DBF	d1,.find
	MOVE.B	d0,smaxpatt
	
	MOVE.B	digvoices,d0
	ADD.B	yamvoices,d0
	MOVE.L	d0,d1
	MULU	#5,d0
	MOVE.B	d0,scvoies
	MULU	#5*64,d1
	MOVE.W	d1,sonepatt
	MOVEQ	#0,d0
	MOVE.B	smaxpatt,d0
	ADDQ.b	#1,d0
	MULU	d1,d0
	MOVE.L	d0,slenpatt
	MOVEQ	#0,d0
	MOVE.W	slenseq,d0
	ADD.L	sADDSEQ,d0
	
	MOVE.L	d0,sADDPATT
	MOVE.B	totalsample,stotalsample
	MOVEQ	#0,d0
	MOVE.L	slenpatt,d0
	ADD.L	sADDPATT,d0
	
	MOVE.L	d0,sADDSPL
	MOVE.L	lensamples,slensamples
	MOVE.L	lenyams,slenyams
	
	LEA	SAMPLE,a0		* deloge la table des samples
	MOVE.L	ADDSPL,d1
	MOVE.L	#255,d0
.rco12	CMP.L	#0,LEN_MGT(a0)
	BEQ.S	.rco13
	SUB.L	d1,DEB_MGT(a0)
	SUB.L	d1,FIN_MGT(a0)
	SUB.L	d1,LOOP_DEB_MGT(a0)
.rco13	ADD.W	#LEN_SAMPLE_MGT,a0
	DBF	d0,.rco12

	LEA	AFFICHAGE,A1
	BSR	FOPEN
	LEA	entete,A1
	MOVEQ	#70,D1
	BSR	FWRITE
	
	LEA	NAMEMUS,A1
	MOVEQ	#20,D1
	BSR	FWRITE

	LEA	SAMPLE,A1
	MOVEQ	#0,D1
	MOVE.W	slentablespl,D1
	BSR	FWRITE

*	LEA	YAMAHA,A1
*	MOVEQ	#0,D1
*	MOVE.W	slentableyam,D1
*	BSR	FWRITE

	LEA	MUSIQUE,A1	
	MOVEQ	#0,D1
	MOVE.W	slenzic,D1
	BSR	FWRITE

	MOVE.L	ADDSEQ,A1
	MOVEQ	#0,D1
	MOVE.W	slenseq,D1
	BSR	FWRITE

	BSR.S	save_patt

	MOVE.L	ADDSPL,A1
	MOVE.L	lensamples,D1
	ADD.L	lenyams,D1
	BSR	FWRITE
	BSR	FCLOSE
	
	LEA	SAMPLE,a0		* reloge la table des samples
	MOVE.L	ADDSPL,d1
	MOVE.L	#255,d0
.rco1	CMP.L	#0,LEN_MGT(a0)
	beq.s	.rco2
	ADD.l	d1,DEB_MGT(a0)
	ADD.l	d1,FIN_MGT(a0)
	ADD.l	d1,LOOP_DEB_MGT(a0)
.rco2	ADD.w	#LEN_SAMPLE_MGT,a0
	dbf	d0,.rco1
	RTS

s_avr
s_sam
s_s3m
s_mad
	RTS
save_patt
	MOVEQ	#0,d3
	MOVE.B	smaxpatt,d3
	*subq	#1,d3
	MOVE.L	debpatt,a0
	subq.w	#5,a0
	MOVE.L	a0,pat
	
newpat	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.L	pat,a0
	LEA	emptypatt,a1
	MOVE.L	a1,a5
	MOVE.B	digvoices,d0
	ADD.b	yamvoices,d0
	MOVE.B	d0,d1
	subq	#1,d0
	MULU	#5,d1			* longueur d'1 ligne
	LEA	PILEVOIE,a2
	
pied	MOVE.L	(a2)+,a3
	ADDQ.W	#5,a0
	MOVE.L	a0,a4
	cmp.b	#0,25(a3)
	beq.s	pied
	MOVEQ	#63,d2
.main	MOVE.B	(a4),(a5)
	MOVE.B	1(a4),1(a5)
	MOVE.B	2(a4),2(a5)
	MOVE.B	3(a4),3(a5)
	MOVE.B	4(a4),4(a5)
	ADD.w	#18*5,a4
	ADD.w	d1,a5
	dbf	d2,.main
	ADDQ.w	#4,a1
	MOVE.L	a1,a5
	dbf	d0,pied
	
	MOVEQ	#0,d1
	MOVE.B	digvoices,d1
	ADD.b	yamvoices,d1
	MULU	#5*64,d1
	LEA	emptypatt,a1
	BSR	FWRITE
	LEA	emptypatt,a1
	MOVE.L	#64*18*5-1,d1
	MOVEQ	#0,d0
.beurk	MOVE.B	d0,(a1)+
	dbf	d1,.beurk
	ADD.l	#64*18*5,pat
	dbf	d3,newpat
	RTS
	
emptypatt	ds.b	64*18*5

SAVENAME
	LEA	AFFICHAGE,a0
	LEA	SNAME,a1
	MOVEQ	#15,d0
.sn1	MOVE.L	(a0)+,(a1)+
	dbf	d0,.sn1
.sn2	cmp.b	#'\',-(a1)
	BNE.S	.sn2
	MOVE.L	a1,a2
.sn3	cmp.b	#'.',(a1)+
	BNE.S	.sn3
	MOVE.B	#'N',(a1)+
	MOVE.B	#'A',(a1)+
	MOVE.B	#'M',(a1)+
	LEA	NAMEBANK,a0
	ADDQ.l	#1,a2
	
	rept	12
	MOVE.B	(a2)+,(a0)+
	endr
	
	MOVE.L	#'NAM!',NAME
	
	clr.w 	-(sp)
 	pea	SNAME
 	MOVE.W	#$3c,-(sp)
 	trap 	#1
 	ADDQ.l 	#8,sp
 	MOVE.W	d0,d2
	
	pea	NAME
 	MOVE.L	#4+12+13*256,-(sp)
 	MOVE.W	d2,-(sp)
 	MOVE.W	#$40,-(sp)
 	trap 	#1
 	ADD.l 	#12,sp

	MOVE.W d2,-(sp)
 	MOVE.W #$3e,-(sp)
 	trap 	#1
 	ADDQ.l #4,sp
	RTS
SNAME	DS.B	64

	ENDC
*************************************************************************
INITMEG:	
	MOVEM.L	D0-D1/A1,-(A7)
	BSR	SILENT
	LEA	SAMPLE,a1
	MOVE.L	#254,d0
.mega1	MOVE.L	#0,(a1)
	MOVE.L	#0,4(a1)
	MOVE.L	#0,8(a1)
	MOVE.L	#0,12(a1)
	MOVE.L	#0,16(a1)
	MOVE.B	#0,F_TUNE_MGT(a1)
	MOVE.B  #129,MONO_MGT(a1)
	MOVE.L	#0,DEB_MGT(a1)
	MOVE.L	#0,LEN_MGT(a1)
	MOVE.L	#0,FIN_MGT(a1)
	MOVE.B	#64,VOL_MGT(a1)
	MOVE.B	#1,LOOP_MGT(a1)
	MOVE.L	#0,LOOP_DEB_MGT(a1)
	MOVE.B	#8,BIT1_MGT(A1)
	MOVE.B	#8,BIT2_MGT(A1)
	LEA	LEN_SAMPLE_MGT(a1),a1
	dbf	d0,.mega1
	
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	MOVE.L	debpatt,a1
	MOVE.B	maxpatt,d0
	ADDQ	#1,d0
	MOVE.B	voies,D2
	MULU	D2,D0
	MULU	#64,D0
	subq.l	#1,d0
.fr	MOVE.L	d1,(a1)+
	dbf	d0,.fr
	
	MOVEQ	#0,d0
	MOVE.L	ADDSEQ,a1
	MOVE.B	maxzic,d0
	MULU	#256,d0
	subq.l	#1,d0
.fr1	MOVE.B	d1,(a1)+
	dbf	d0,.fr1
	MOVE.W	#0,u
	MOVE.W	#6,v
	MOVEM.L	(A7)+,D0-D1/A1
	RTS
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
	MOVEM.L	D0-D1/A0,-(A7)
	MOVE.L	FIN_MGT(A1),A0		* on prend la fin
	MOVEQ	#0,D0
	MOVE.L	#FINSAMPLE-1,D1
.ajou1	MOVE.B	D0,(A0)+
	DBF	D1,.ajou1
	MOVEM.L	(A7)+,D0-D1/A0
	RTS
*************************************************************************
*	A1 = DATA SAMPLE
BCLFINSPL
	MOVEM.L	d0/a0-a2,-(a7)
	MOVE.L	FIN_MGT(a1),a0
	MOVE.L	LOOP_DEB_MGT(a1),a2		* on prend le deb de la bcl
	MOVE.L	#FINSAMPLE-1,d0
.ajou2	MOVE.B	(a2)+,(a0)+
	dbf	d0,.ajou2
	MOVEm.l	(a7)+,d0/a0-a2
	RTS
*************************************************************************
FRE:	MOVE.L	$42E.W,D0			*FRE(0)
	MOVE.L	ENDADDR,D1
	SUB.L	D1,D0
	MOVE.L	D0,freemem
	LEA	freem,A0
	BSR	CONVERT_HEXA_DECIASCII
	MOVE.L	#screen+640*72+432+1,where
	MOVE.W	#1,compt2
	LEA	freem,A0
	MOVEQ	#8,D1
	BSR	PRINT
	RTS
*************************************************************************
*	Recherche d'une place libre pour un sample
*	Retour : A1 = Adresse libre dans SAMPLE
*	       here = Numero de l'emplacement libre
SEARCHFREESPL
	MOVE.B	#0,sampledata
	LEA	SAMPLE,a1
.next	CMP.L	#0,LEN_MGT(a1)
	beq.s	.good
	ADD.l	#LEN_SAMPLE_MGT,a1
	ADDQ.b	#1,sampledata
	bra.s	.next
.good	MOVE.B	sampledata,curentnb2
	RTS
here	dc.b	0
	even
	
**************************************************************************
*	Saver
*	A0 = Adresse ou se trouve le nom du fichier
*	A1 = Adresse de debut
*	D1 = Longueur
SAVE 	clr.w 	-(sp)
 	MOVE.L	a0,-(a7)
 	MOVE.W #$3c,-(sp)
 	trap 	#1
 	ADDQ.l 	#8,sp

 	MOVE.W d0,d2
 	MOVE.L a1,-(sp)
 	MOVE.L d1,-(sp)
 	MOVE.W d2,-(sp)
 	MOVE.W #$40,-(sp)
 	trap 	#1
 	ADD.l 	#12,sp

	MOVE.W d2,-(sp)
 	MOVE.W #$3e,-(sp)
 	trap 	#1
 	ADDQ.l #4,sp
	RTS
***********************************************************************
*	Loader
*	A0 = Adresse ou se trouve le nom du fichier
*  ENDADDR = Adresse ou charger le fichier
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
	
	BSR	OFF_134
	MOVE.W	#1,POL
	
.TIME	MOVE.W	#2,-(SP)		
	MOVE.L 	A0,-(SP)
	MOVE.W	#$3D,-(SP)		
	TRAP	#1		
	ADDQ.L	#8,SP		
	MOVE.W	D0,D7		
	TST.W	D0		
	BMI.S	PASFICHIER
	MOVE.L	ENDADDR,-(a7)
	PEA	$FFFFF		
	MOVE.W	D0,-(SP)	
	MOVE.W	#$3F,-(SP)	
	TRAP	#1		
	ADDA.L	#$C,SP
	MOVE.L	d0,long
	MOVE.W	D7,-(SP)	
	MOVE.W	#$3E,-(SP)	
	TRAP	#1		
	ADDQ.L	#4,SP
	MOVE.L	long,d0
	MOVE.L	ENDADDR,a0
	BSR	DEC_23R
	MOVE.L	ENDADDR,a0
	BSR	DEC_AT35
	MOVE.L	d0,long
	BRA.S	PAS1
PASFICHIER	
	MOVE.W	#1,erreur
PAS1	CMP.W	#1,POL
	BEQ.S	.PAS2
	RTS
.PAS2	
	MOVE.L	#MY_134,$134.W
	MOVE.W	#0,POL
	RTS
RTE_134	RTE	
	LEA	VOICE0,A1
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
	LEA	VOICE11,A1
	MOVE.B	ssv11,25(A1)
	LEA	VOICE12,A1
	MOVE.B	ssv12,25(A1)
	LEA	VOICE13,A1
	MOVE.B	ssv13,25(A1)
	LEA	VOICE14,A1
	MOVE.B	ssv14,25(A1)
	LEA	VOICE15,A1
	MOVE.B	ssv15,25(A1)
	LEA	VOICE16,A1
	MOVE.B	ssv16,25(A1)
	LEA	VOICE17,A1
	MOVE.B	ssv17,25(A1)
	MOVE.W	#0,POL
	RTS

DEC_23R		INCBIN	DATA\DEC_23R.BIN
DEC_AT35	INCBIN	DATA\DEC_AT35.BIN
POL		DC.W	0
********************************************************************
*	d0 = # of sample in memory
SEARCHSAMPLE
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
;	CMP.L	#0,LEN_MGT(a0)
;	beq.s	nosample	
	MOVE.L	a0,current
	RTS
;nosample
;	MOVE.L	#0,current
;	RTS
**********************************************************************
		ds.l	100
pile2		ds.l	100
pile		dc.l	0	*Sauvegarde de la pile
pile1		dc.l	0	*Adresse de la pile superviseur
touche		dc.w	0	*Numero de la derniere touche pressee
curentnb	dc.b	1	*Numero du sample actuel
	even
current         dc.l    0       *Adresse des donnees sur le sample actuel
ENDADDR         dc.l    s1      *Start adress of free memory
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
curentmask	dc.b	3	*Mask actuel
voies		dc.b	32 	*Nb de voies activees
cvoies		dc.b	32*5	*voies * octets dans 1 lignes pattern
yamvoices	dc.b	0	*Nb de voies yamaha
digvoices	dc.b	2	*Nb de voies digitales
curvoie		dc.b	3	*Voie courante    (0 -> 31)
curpatt		dc.b	0	*Pattern courante (0 -> 255)
curspl		dc.b	0	*Sample courant   (0 -> 255)
curyam		dc.b	0	*Yamaha sound     (0 -> 255)
curseq		dc.b	0	*Sequence courante(0 -> 255)
curnum		dc.b	0	*Musique courante (0 -> 255)
curlen		dc.b	0	*Longueur de la zic courante (0 -> 255)
curlop		dc.b    0       *Loop de la zic courante     (0 -> 255)
maxpatt		dc.b	2	*Pattern maximum - 1
maxzic		dc.b	2	*Nb de zic maximum
	even
ADDPATT		dc.l	PATTERNS 	*Adresse pattern courante
debpatt		dc.l	PATTERNS	*Adresse debut pattern
ADDSEQ		dc.l	SEQUENCE
ADDSPL		dc.l	s1	 	*Adresse debut spl
lensamples	dc.l	0		*Longueur de tous les samples
lenyams		dc.l	0		*Longueur de tous les yams

		even
**************************************************************************
SPLTSPE
	MOVEM.L	D0-A0/A1,-(A7)
	MOVE.L	heretoconvert,a1
	BSR.S	SPLTOSPE
	MOVEM.L	(A7)+,D0-A0/A1
	MOVE.W	#0,okp
	RTS
**************************************************************************
*	SPL to SPE convertor
*	A1 = Adress of data sample	* en entree
*	A0 = Adress of the sample	* interne
*	D0 = Lenght of the sample	* interne
SPLTOSPE
	MOVE.L	DEB_MGT(a1),a0
	MOVE.L  LEN_MGT(a1),d0
	MOVE.B	#$80,d1
.again	ADD.b	d1,(a0)+
	subq.l	#1,d0
	BNE.S	.again
oout	RTS
***************************************************************************
DIVIDE2
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,LEN_MGT(A0)
	BEQ.S	oout
	MOVE.L	A0,heretoconvert
	MOVE.W	#16,okp
	RTS
	
D_ALL_BY_2
	MOVE.W	#20,okp
	RTS

DIVIDE_ALL_BY_2
	MOVE.L	#254,D5
	LEA	SAMPLE,A2
.LI4	CMP.L	#0,26(A2)
	BEQ.S	.LI5
	MOVE.L	A2,heretoconvert
	BSR	D_2
.LI5	ADD.W	#LEN_SAMPLE_MGT,A2
	DBF	D5,.LI4	
	MOVE.W	#0,okp
	RTS
	
DIVIDE_2
	BSR.S	D_2
	MOVE.W	#0,okp
	RTS
	
D_2	MOVE.L	heretoconvert,A1
	MOVE.L	DEB_MGT(A1),A0
	MOVE.L	LEN_MGT(A1),D0
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
	
*--------------------------------------------------------------------------
DIVIDE3
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,LEN_MGT(A0)
	BEQ	oout
	MOVE.L	A0,heretoconvert
	MOVE.W	#17,okp
	RTS
DIVIDE_3
	BSR.S	D_3
	MOVE.W	#0,okp
	RTS
D_3	MOVE.L	heretoconvert,A1
	MOVE.L	DEB_MGT(A1),A0
	MOVE.L	LEN_MGT(A1),D0
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
	
*--------------------------------------------------------------------------
DIVIDE4
	MOVE.B	#0,KEY
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,LEN_MGT(A0)
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
	MOVE.L	DEB_MGT(A1),A0
	MOVE.L	LEN_MGT(A1),D0
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
	MOVEm.l	a0-a3/d0-d4,-(a7)
	BSR	SILENT
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	MOVE.L	DEB_MGT(a0),a3		*Debut de l'ancien sample   = A3
	MOVE.L	LEN_MGT(a0),d3		*Longeur de l'ancien sample = D3
	CMP.L	#0,d3			*Veut-il effacer un sample qui n'est pas en memoire
	beq	.nospl
	ADD.l	#FINSAMPLE,d3
	MOVE.B	totalsample,d1
	cmp.b	#1,d1			*1 seul sample en memoire
	beq.s	.pasdesuite
	cmp.b	#0,d1			*Aucun sample en memoire
	beq	.nospl
	MOVE.L	#255,d1
	MOVEQ	#0,d4
	;subq.w	#1,d1	
	LEA	SAMPLE,a1
.rep2	CMP.L	#0,DEB_MGT(a1)		*Y a-t-il un sample ?
	beq.s	.oncontinu
	MOVE.L	DEB_MGT(a1),a2
	CMP.L	a3,a2			*Est-il avant celui qu'on efface ?
	bls.s	.oncontinu
	SUB.L	d3,DEB_MGT(a1)		*Calcul la nouvelle START ADRESS
	SUB.L	d3,FIN_MGT(a1)		*idem pour END ADRESS
	SUB.L	d3,LOOP_DEB_MGT(a1)	*idem pour LOOP ADRESS
	ADD.l	LEN_MGT(a1),d4		*On calcul la longeur total des spl suivants
	ADD.l	#FINSAMPLE,d4
.oncontinu
	ADD.l	#LEN_SAMPLE_MGT,a1
	dbf	d1,.rep2
	CMP.L	#0,d4			* C'etait le dernier sample ?
	beq.s	.pasdesuite
	MOVE.L	a3,a2
	ADD.l	d3,a2
.rep3	MOVE.B	(a2)+,(a3)+		*Et on recopie tout le reste la ou
	subq.l	#1,d4			*l'ancien sample etait
	CMP.L	#0,d4
	BNE.S	.rep3
.pasdesuite
	SUB.L	d3,ENDADDR
	SUB.L	d3,lensamples
	MOVE.L	a0,a1
	MOVE.W	#LEN_SAMPLE_MGT-1,d1
.rep5	MOVE.B	#0,(a0)+		*on efface ses donnees
	dbf	d1,.rep5
	MOVE.B	#129,MONO_MGT(a1)
	MOVE.B	#1,LOOP_MGT(a1)
.rep4	MOVE.B	#0,(a3)+		*on efface le sample
	subq.l	#1,d3
	BNE.S	.rep4
	subq.b	#1,totalsample
	BSR	FRE
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#12,d0
	LEA	NAMESAMPLE,a0
	ADD.l	d0,a0
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.L	#0,(a0)+
	MOVE.B	#0,(a0)+
.nospl	MOVEm.l	(a7)+,a0-a3/d0-d4
	RTS
	
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
				* Ne pas oublier de nettoyer touche
*	touche = note or space bar
**************************************************************************
INPUT			*	Le retour
	MOVE.B	#0,KEY
	CMP.W	#0,okp
	BNE.S	.cokp
	MOVEQ	#0,d0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,d0
	LEA	SAMPLE,a0
	ADD.l	d0,a0
	MOVE.L	a0,string
	MOVE.L	#screen+32000+113*160+46,where2
	MOVE.W	#0,compt
	MOVE.B	#20,maxlet
	MOVE.W	#2,okp
.cokp	RTS
string	dc.l	0
where2	dc.l	0
maxlet	dc.b	0
	even

INPT2	MOVE.B	#0,lastouche
	BSR.S	INPT
	MOVE.B	#0,touche
	MOVE.W	#0,okp
	RTS
INPT	MOVEM.L	d0-d1/a0-a2,-(a7)
	MOVE.L	string,a0
	MOVE.L	a0,a1
	MOVEQ	#0,d1
	MOVE.B	maxlet,d1
.onyva	MOVE.B	#'Š',d0
	MOVE.L	where2,where
	
	MOVEM.L	A2-A3,-(A7)
	BSR	AFFICHE
	MOVEM.L	(A7)+,A2-A3
	
.onyva2	BSR	INPUT2
	cmp.b	#$d,d0			* Si c'est RETURN ou ENTER
	beq.s	.fini1			* on va a la fin
	cmp.b	#$7f,d0			* Si c'est DEL
	beq	.del
	cmp.b	#8,d0			* ou BACKSPACE
	beq	.del			* on va en 'del'
	cmp.b	#$fd,d0			* Si c'est 'ESC'
	beq	.echap			* on annule tout
	cmp.b	#0,d0
	beq.s	.onyva2
	MOVE.B	d0,(a0)
	MOVE.L	where2,where
	
	MOVEM.L	A2-A3,-(A7)
	BSR	AFFICHE
	MOVEM.L	(A7)+,A2-A3
	
	subq.b	#1,d1			* Nb caracteres +1
	cmp.b  #0,d1
	BNE.S	.go
	MOVEQ	#1,d1	
	bra.s	.onyva
.go	ADDQ.l	#1,a0
	ADDQ.w	#1,compt
	CMP.W	#2,compt
	beq.s	.com2
	ADDQ.l	#1,where2
	bra.s	.com1
.com2	ADD.L	#15,where2
	MOVE.W	#0,compt
.com1	bra	.onyva
.fini1	MOVE.B #'Š',d0
	MOVE.L	where2,where
	
	MOVEM.L	A2-A3,-(A7)
	BSR	AFFICHE
	MOVEM.L	(A7)+,A2-A3
	
	MOVEM.L	(a7)+,d0-d1/a0-a2
	RTS
	
.del	cmp.b	#20,D1
	bge	.onyva
	
	ADDQ.b	#1,D1
	MOVE.B	#0,d0
	MOVE.L	where2,where
	
	MOVEM.L	A2-A3,-(A7)
	BSR 	AFFICHE
	MOVEM.L	(A7)+,A2-A3
	
	subq.l	#1,a0
	MOVE.B	#0,(A0)
	ADDQ.w	#1,compt
	CMP.W	#2,compt
	beq.s	.co1
	sub.l	#15,where2
	bra.s	.co2
.co1	subq.l	#1,where2
	MOVE.W	#0,compt
.co2	bra	.onyva
.echap	MOVE.W	#5,erreur
	MOVEm.l	(a7)+,d0-d1/a0-a2
	RTS

compt	dc.w	0
************************************************************************
*	Simule la fonction   #A  du  trap #1
*	Retour : D0 = Caractere
INPUT2	MOVEm.l	d1/a1,-(a7)
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	KEY,d1
.gti	MOVE.B	KEY,d0
	cmp.b	d0,d1
	beq.s	.gti
.ici	LEA	SCANCODE,a1
.deja	MOVE.B	KEY,d0
	cmp.b	#0,d0
	BNE.S	.deja2
	MOVE.B	d0,lastouche
	bra.s	.deja
.deja2	cmp.b	lastouche,d0
	beq.s	.deja
	MOVE.B	d0,lastouche
.cont2	cmp.b	#-1,(a1)
	beq.s	.findescodes
	cmp.b	(a1)+,d0
	beq.s	.ca
	ADDQ.l	#1,a1
	bra.s	.cont2
.ca	MOVE.B	(a1),d0
	MOVEm.l	(a7)+,d1/a1
	RTS
.findescodes
	MOVEQ	#0,d0
	MOVEm.l	(a7)+,d1/a1
	RTS

compt2		dc.w	0
lastouche	dc.b	0
	even
**************************************************************************
AFFICHE			* D0 = Numero du caractere
	MOVE.L	where,a2
	MOVE.L	ADDFONT,a3
	
	cmp.b	#'Š',d0
	beq.S	.cursor
	cmp.b	#0,d0
	beq.S	.blank
	cmp.b	#' ',d0
	beq.S	.blank
	ADD.w	d0,a3
	
	MOVE.B	(a3),(a2)
	MOVE.B	$100(a3),640(a2)
	MOVE.B	$200(a3),640*2(a2)
	MOVE.B	$300(a3),640*3(a2)
	MOVE.B	$400(a3),640*4(a2)
	MOVE.B	$500(a3),640*5(a2)
	MOVE.B	$600(a3),640*6(a2)
	RTS
	
.blank	MOVEQ	#0,d0
	MOVE.B	d0,(a2)
	MOVE.B	d0,640(a2)
	MOVE.B	d0,640*2(a2)
	MOVE.B	d0,640*3(a2)
	MOVE.B	d0,640*4(a2)
	MOVE.B	d0,640*5(a2)
	MOVE.B	d0,640*6(a2)
	RTS
	
.cursor not.b	(a2)
	not.b	640(a2)
	not.b	640*2(a2)
	not.b	640*3(a2)
	not.b	640*4(a2)
	not.b	640*5(a2)
	not.b	640*6(a2)
	RTS

where	dc.l	0		* Adresse ou afficher le caractere
**********************************************************************
CLRKEYB
	MOVE.W #$b,-(a7)		*
	trap #1		        	*
	ADDQ.l	#2,a7			*
	tst.w	d0			*
	beq.s	.gogo			* Ici c'est pour vider le tampon	
	MOVE.W	#7,-(a7)		* du clavier
	trap #1			        *
	ADDQ.l	#2,a7			*
	bra.s	CLRKEYB		        *
.gogo	RTS


**************************************************************************
* Simule la fonction PRINT
* A0=Adresse ou se trouve le text
* A1=Adresse ou afficher sur l'ecran
* D1=Longueur du TXT

PRINT:	MOVEM.L	A0/A2-A3/D0-D2,-(A7)
	MOVEQ	#0,d0
.again2	ADDQ.W	#1,compt2
	CMP.W	#2,compt2
	beq.S	.cco1
	ADDQ.l	#1,where
	bra.S	.cco2
.cco1	ADD.L	#15,where
	MOVE.W	#0,compt2
.cco2	MOVE.B	(a0)+,d0
	BSR	AFFICHE
	subq.W	#1,d1
	CMP.W	#0,d1
	BNE.S	.again2
	MOVEM.L (a7)+,A0/A2-A3/D0-D2
	RTS
**************************************************************************
AFFICHE2		* D0 = Numero du caractere
	cmp.b	#'Š',d0
	beq	ccursor
	cmp.b	#0,d0
	beq.s	cblank
	cmp.b	#' ',d0
	beq.s	cblank
	MOVE.L	a1,a3
	ADD.w	d0,a3
cblok	MOVE.B	(a3),(a2)
	MOVE.B	(a3),640(a2)
	MOVE.B	$100(a3),640*2(a2)
	MOVE.B	$100(a3),640*3(a2)
	MOVE.B	$200(a3),640*4(a2)
	MOVE.B	$200(a3),640*5(a2)
	MOVE.B	$300(a3),640*6(a2)
	MOVE.B	$300(a3),640*7(a2)
	MOVE.B	$400(a3),640*8(a2)
	MOVE.B	$400(a3),640*9(a2)
	MOVE.B	$500(a3),640*10(a2)
	MOVE.B	$500(a3),640*11(a2)
	MOVE.B	$600(a3),640*12(a2)
	MOVE.B	$600(a3),640*13(a2)
	RTS
cblank	MOVEQ	#0,d0
	MOVE.B	d0,(a2)
	MOVE.B	d0,640(a2)
	MOVE.B	d0,640*2(a2)
	MOVE.B	d0,640*3(a2)
	MOVE.B	d0,640*4(a2)
	MOVE.B	d0,640*5(a2)
	MOVE.B	d0,640*6(a2)
	MOVE.B	d0,640*7(a2)
	MOVE.B	d0,640*8(a2)
	MOVE.B	d0,640*9(a2)
	MOVE.B	d0,640*10(a2)
	MOVE.B	d0,640*11(a2)
	MOVE.B	d0,640*12(a2)
	MOVE.B	d0,640*13(a2)
	RTS
ccursor not.b	(a2)
	not.b	640(a2)
	not.b	640*2(a2)
	not.b	640*3(a2)
	not.b	640*4(a2)
	not.b	640*5(a2)
	not.b	640*6(a2)
	not.b	640*7(a2)
	not.b	640*8(a2)
	not.b	640*9(a2)
	not.b	640*10(a2)
	not.b	640*11(a2)
	not.b	640*12(a2)
	not.b	640*13(a2)
	RTS
**********************************************************************
* Simule la fonction PRINT
* A0=Adresse ou se trouve le text
* A1=Adresse ou afficher sur l'ecran
* D1=Longueur du TXT
PRINT2	MOVEm.l	a0-a3/d0-d1,-(a7)
	MOVEQ	#0,d0
	MOVE.L	ADDFONT,a1
	MOVE.L	where,a2
.cagain2	ADDQ.w	#1,compt2
	CMP.W	#2,compt2
	beq.s	.ccco1
	ADDQ.w	#1,a2
	bra.s	.ccco2
.ccco1	ADD.W	#15,a2
	MOVE.W	#0,compt2
.ccco2	MOVE.B	(a0)+,d0
	BSR	AFFICHE2
	subq.w	#1,d1
	CMP.W	#0,d1
	BNE.S	.cagain2
	MOVE.L	a2,where
	MOVEm.l (a7)+,a0-a3/d0-d1
	RTS
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
**********************************************************************
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
PATTDOWN:
	MOVE.W	#15,okp
	RTS
PATTDOWN2

	MOVE.L	#VOICEDOWN,A2
	MOVEQ	#0,D0
	MOVEQ	#4,D2		* 5
DO3	MOVE.L	(A2)+,A0
	MOVE.L	A0,A1
	SUB.W	#8*640,a1
	MOVEQ	#8*2-1,D1
	
.DO1	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)

	LEA	-640(A0),A0
	LEA	-640(A1),A1
	DBF	D1,.DO1

	SUB.W	#640,A1
	MOVEQ	#6,D1
	
.DO2	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)


	LEA	-640(A0),A0
	LEA	-1280(A1),A1
	DBF	D1,.DO2

	SUB.W	#640,A0
	SUB.W	#640,A1
	MOVEQ	#7,D1
	
.DO4	MOVE.W	-18(A1),-18(A0)
	MOVE.W	-18(A1),-18+640(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	16(A1),16+640(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	32(A1),32+640(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	48(A1),48+640(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	64(A1),64+640(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.W	80(A1),80+640(A0)
	MOVE.B	96(A1),96(A0)
	MOVE.B	96(A1),96+640(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.B	113(A1),113+640(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	128(A1),128+640(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	144(A1),144+640(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	160(A1),160+640(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	176(A1),176+640(A0)
	MOVE.W	192(A1),192(A0)
	MOVE.W	192(A1),192+640(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	224(A1),224+640(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	240(A1),240+640(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	256(A1),256+640(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	272(A1),272+640(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.W	288(A1),288+640(A0)
	MOVE.B	304(A1),304(A0)
	MOVE.B	304(A1),304+640(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.B	321(A1),321+640(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	336(A1),336+640(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	352(A1),352+640(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	368(A1),368+640(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	384(A1),384+640(A0)
	MOVE.W	400(A1),400(A0)
	MOVE.W	400(A1),400+640(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	432(A1),432+640(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	448(A1),448+640(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	464(A1),464+640(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	480(A1),480+640(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.W	496(A1),496+640(A0)
	MOVE.B	512(A1),512(A0)
	MOVE.B	512(A1),512+640(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.B	529(A1),529+640(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	544(A1),544+640(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	560(A1),560+640(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	576(A1),576+640(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	592(A1),592+640(A0)
	MOVE.W	608(A1),608(A0)
	MOVE.W	608(A1),608+640(A0)
	
	LEA	-1280(A0),A0
	LEA	-640(A1),A1
	DBF	D1,.DO4
	
	MOVEQ	#15,D1
	
.DO5	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)
	
	LEA	-640(A0),A0
	LEA	-640(A1),A1
	DBF	D1,.DO5
	DBF	D2,DO3
	
	LEA	patt,A1
	LEA	ccompt2,A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	
	MOVE.B	voies,D2
	SUBQ.B	#1,D2
	MOVE.B	inpatt,D0
	SUBQ.B	#3,D0
	MOVE.B	D0,D3
	MOVE.B	cvoies,D1
	MULU	D1,D0
	MOVE.L	ADDPATT,A0
	ADD.L	D0,A0

.DO7	CMP.B	#0,D3
	BGE.S	.PAVIDE
	MOVE.L	#-1,A0
.PAVIDE	MOVE.L	(A1)+,where
	MOVE.W	(A2)+,compt2
	BSR	AFFPARTIPATT
	ADDQ.W	#5,A0
	DBF	D2,.DO7

	MOVE.L	#screen+640*369-11,where
	MOVE.W	#1,compt2
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
	
	MOVE.L	#screen+640*369+4,A0
	MOVE.L	a0,a1
	MOVE.L	a0,a2
	MOVE.L	a0,a3
	MOVE.L	a0,a4
	MOVE.L	a0,a5
	ADD.L	#640*80,a1
	ADD.L	#640*160,a2
	ADD.L	#640*240,a3
	ADD.L	#640*320,a4
	ADD.L	#640*400,a5
	MOVE.L	#8-1,D0
	
.COP1	MOVE.W	(A0),(A1)	
	MOVE.W	(A0),(A2)
	MOVE.W	(A0),(A3)
	MOVE.W	(A0),(A4)
	MOVE.W	(A0),(A5)
	LEA	640(A0),A0
	LEA	640(A1),A1
	LEA	640(A2),A2
	LEA	640(A3),A3
	LEA	640(A4),A4
	LEA	640(A5),A5
	DBF	D0,.COP1

	CMP.W	#15,okp
	BNE.S	.SORTIR
	MOVE.W	#0,okp
.SORTIR	RTS

VOICEDOWN	DC.L	VOICED
		DC.L	VOICED+640*80
		DC.L	VOICED+640*160
		DC.L	VOICED+640*240
		DC.L	VOICED+640*320
		DC.L	VOICED+640*400
***************************************************************************
PATTUP:	MOVE.W	#14,okp
	RTS
	
PATTUP4	CMP.B	#1,playsong
	BRA	PATTUP6				*BEQ	PATTUP6
	
	LEA	VOICEUP,A2
	MOVEQ	#0,D0
	MOVEQ	#5,D2			* NB OF VOICE /6 -1
	
.UP3	MOVE.L	(A2)+,A0
	MOVE.L	A0,A1
	ADD.W	#8*640,A1
	MOVEQ	#8*2-1,D1
	
.UP1	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)
	
	LEA	640(A0),A0
	LEA	640(A1),A1
	DBF	D1,.UP1

	LEA	640(A1),A1
	MOVEQ	#7,D1
.UP4	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)
	
	LEA	 640(A0),A0
	LEA	1280(A1),A1
	DBF	D1,.UP4

	LEA	640(A0),A0
	MOVEQ	#7,D1

.UP5	MOVE.W	-18(A1),-18(A0)
	MOVE.W	-18(A1),-18+640(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	16(A1),16+640(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	32(A1),32+640(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	48(A1),48+640(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	64(A1),64+640(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.W	80(A1),80+640(A0)
	MOVE.B	96(A1),96(A0)
	MOVE.B	96(A1),96+640(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.B	113(A1),113+640(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	128(A1),128+640(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	144(A1),144+640(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	160(A1),160+640(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	176(A1),176+640(A0)
	MOVE.W	192(A1),192(A0)
	MOVE.W	192(A1),192+640(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	224(A1),224+640(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	240(A1),240+640(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	256(A1),256+640(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	272(A1),272+640(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.W	288(A1),288+640(A0)
	MOVE.B	304(A1),304(A0)
	MOVE.B	304(A1),304+640(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.B	321(A1),321+640(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	336(A1),336+640(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	352(A1),352+640(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	368(A1),368+640(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	384(A1),384+640(A0)
	MOVE.W	400(A1),400(A0)
	MOVE.W	400(A1),400+640(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	432(A1),432+640(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	448(A1),448+640(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	464(A1),464+640(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	480(A1),480+640(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.W	496(A1),496+640(A0)
	MOVE.B	512(A1),512(A0)
	MOVE.B	512(A1),512+640(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.B	529(A1),529+640(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	544(A1),544+640(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	560(A1),560+640(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	576(A1),576+640(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	592(A1),592+640(A0)
	MOVE.W	608(A1),608(A0)
	MOVE.W	608(A1),608+640(A0)

	LEA	1280(A0),A0
	LEA	 640(A1),A1
	DBF	D1,.UP5

	MOVEQ	#8*2-1,D1
.UP6	MOVE.W	-18(A1),-18(A0)

	MOVE.W	16(A1),16(A0)
	MOVE.W	32(A1),32(A0)
	MOVE.W	48(A1),48(A0)
	MOVE.W	64(A1),64(A0)
	MOVE.W	80(A1),80(A0)
	MOVE.B	96(A1),96(A0)

	MOVE.B	113(A1),113(A0)
	MOVE.W	128(A1),128(A0)
	MOVE.W	144(A1),144(A0)
	MOVE.W	160(A1),160(A0)
	MOVE.W	176(A1),176(A0)
	MOVE.W	192(A1),192(A0)

	MOVE.W	224(A1),224(A0)
	MOVE.W	240(A1),240(A0)
	MOVE.W	256(A1),256(A0)
	MOVE.W	272(A1),272(A0)
	MOVE.W	288(A1),288(A0)
	MOVE.B	304(A1),304(A0)
	
	MOVE.B	321(A1),321(A0)
	MOVE.W	336(A1),336(A0)
	MOVE.W	352(A1),352(A0)
	MOVE.W	368(A1),368(A0)
	MOVE.W	384(A1),384(A0)
	MOVE.W	400(A1),400(A0)

	MOVE.W	432(A1),432(A0)
	MOVE.W	448(A1),448(A0)
	MOVE.W	464(A1),464(A0)
	MOVE.W	480(A1),480(A0)
	MOVE.W	496(A1),496(A0)
	MOVE.B	512(A1),512(A0)
	
	MOVE.B	529(A1),529(A0)
	MOVE.W	544(A1),544(A0)
	MOVE.W	560(A1),560(A0)
	MOVE.W	576(A1),576(A0)
	MOVE.W	592(A1),592(A0)
	MOVE.W	608(A1),608(A0)

	LEA	640(A0),A0
	LEA	640(A1),A1
	DBF	D1,.UP6

	ADD.W	#5*4,A2	
	DBF	D2,.UP3

	LEA	patt,A1
	LEA	ccompt2,A2
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE.B	voies,D2
	SUBQ.B	#1,D2
	MOVE.L	ADDPATT,A0
	MOVE.B	inpatt,D0
	ADDQ.B	#3,D0
	MOVE.B	D0,D3
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.L	D0,A0
	
.UP7	CMP.B	#64,D3
	BLT.S	.PVIDE
	MOVE.L	#-1,A0
.PVIDE	MOVE.L	(A1)+,where
	ADD.L	#640*8*7+640,where
	MOVE.W	(A2)+,compt2
	BSR	AFFPARTIPATT
	ADDQ.W	#5,A0
	DBF	D2,.UP7

	MOVE.L	#screen+640*(369+8*7)-11+640,where
	MOVE.W	#1,compt2
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
	
	MOVE.L	#screen+640*(369+8*7)+4,A0
	MOVE.L	a0,a1
	MOVE.L	a0,a2
	MOVE.L	a0,a3
	MOVE.L	a0,a4
	MOVE.L	a0,a5
	ADD.L	#640*80,a1
	ADD.L	#640*160,a2
	ADD.L	#640*240,a3
	ADD.L	#640*320,a4
	ADD.L	#640*400,a5
	MOVE.L	#8-1,D0
	
.COP1	MOVE.W	(A0),(A1)	
	MOVE.W	(A0),(A2)
	MOVE.W	(A0),(A3)
	MOVE.W	(A0),(A4)
	MOVE.W	(A0),(A5)
	LEA	640(A0),A0
	LEA	640(A1),A1
	LEA	640(A2),A2
	LEA	640(A3),A3
	LEA	640(A4),A4
	LEA	640(A5),A5
	DBF	D0,.COP1

OUP	CMP.W	#14,okp
	BNE.S	.PO
	MOVE.W	#0,okp
.PO	RTS

VOICEUP	DC.L	VOICEU,VOICEU+96,VOICEU+208,VOICEU+304,VOICEU+416,VOICEU+512
	DC.L	VOICEU+640*80,VOICEU+640*80+96,VOICEU+640*80+208,VOICEU+640*80+304,VOICEU+640*80+416,VOICEU+640*80+512
	DC.L	VOICEU+640*160,VOICEU+640*160+96,VOICEU+640*160+208,VOICEU+640*160+304,VOICEU+640*160+416,VOICEU+640*160+512
	DC.L	VOICEU+640*240,VOICEU+640*240+96,VOICEU+640*240+208,VOICEU+640*240+304,VOICEU+640*240+416,VOICEU+640*240+512
	DC.L	VOICEU+640*320,VOICEU+640*320+96,VOICEU+640*320+208,VOICEU+640*320+304,VOICEU+640*320+416,VOICEU+640*320+512
	DC.L	VOICEU+640*400,VOICEU+640*400+512
**********************************************************************************************************************
PATTUP6
	MOVE.L	ADDPATT,A0
	LEA	VOICEUP,A2
	LEA	VOICE_TAB,A3
	LEA	ccompt2,A4
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	MOVEQ	#0,D4
	
	MOVE.B	voies,D2
	SUBQ.W	#1,D2
	MOVE.B	inpatt,D0
	ADDQ.B	#3,D0
	MOVE.B	D0,D4
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.L	D0,A0
	
UP20	MOVE.L	(A2)+,A5
	MOVE.L	A5,where
	ADDQ.L	#1,where
	MOVE.W	(A4)+,D3
	MOVE.W	D3,compt2
	MOVE.B	(A3)+,D0
	BEQ.S	BCL_UP6
	
	TST.B	D3
	BEQ.S	.V2
	BSR	UP_V1
	BRA	BCL_UP7
	
.V2	BSR	UP_V2
	ADD.L	#15,where
	
BCL_UP7 MOVE.L	A0,A6
	CMP.B	#64,D4
	BLT.S	.PAVIDE
	MOVE.L	#-1,A0
.PAVIDE	ADD.L	#640*8*7+640,where
	BSR	AFFPARTIPATT
	MOVE.L	A6,A0
	
BCL_UP6 ADDQ.W	#5,A0
	DBF	D2,UP20
	
	BSR	NB_UP
	BRA	OUP
	
*****************************************************************************************
UP_V1					* POUR LES VOIES 0,2,4,6
	MOVE.L	A5,A1
	ADD.W	#8*640,A1
	MOVEQ	#8*2-1,D1
	
.UP15	MOVE.W	16(A1),16(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.B	96(A1),96(A5)
	
	LEA	640(A5),A5
	LEA	640(A1),A1
	DBF	D1,.UP15

	LEA	640(A1),A1
	MOVEQ	#7,D1
	
.UP8	MOVE.W	16(A1),16(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.B	96(A1),96(A5)
	
	LEA	 640(A5),A5
	LEA	1280(A1),A1
	DBF	D1,.UP8

	LEA	640(A5),A5
	MOVEQ	#7,D1

.UP9	MOVE.W	16(A1),16(A5)
	MOVE.W	16(A1),16+640(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	32(A1),32+640(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	48(A1),48+640(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	64(A1),64+640(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.W	80(A1),80+640(A5)
	MOVE.B	96(A1),96(A5)
	MOVE.B	96(A1),96+640(A5)

	LEA	1280(A5),A5
	LEA	 640(A1),A1
	DBF	D1,.UP9

	MOVEQ	#8*2-1,D1
	
.UP10	MOVE.W	16(A1),16(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.B	96(A1),96(A5)

	LEA	640(A5),A5
	LEA	640(A1),A1
	DBF	D1,.UP10
	RTS
*****************************************************************************************
UP_V2					* POUR LES VOIES 1,3,5
	MOVE.L	A5,A1
	ADD.W	#8*640,a1
	MOVEQ	#8*2-1,D1
	
.UP11	MOVE.B	17(A1),17(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.W	96(A1),96(A5)
	
	LEA	640(A5),A5
	LEA	640(A1),A1
	DBF	D1,.UP11

	LEA	640(A1),A1
	MOVEQ	#7,D1
	
.UP12	MOVE.B	17(A1),17(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.W	96(A1),96(A5)
	
	LEA	 640(A5),A5
	LEA	1280(A1),A1
	DBF	D1,.UP12

	LEA	640(A5),A5
	MOVEQ	#7,D1

.UP13	MOVE.B	17(A1),17(A5)
	MOVE.B	17(A1),17+640(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	32(A1),32+640(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	48(A1),48+640(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	64(A1),64+640(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.W	80(A1),80+640(A5)
	MOVE.W	96(A1),96(A5)
	MOVE.W	96(A1),96+640(A5)

	LEA	1280(A5),A5
	LEA	 640(A1),A1
	DBF	D1,.UP13

	MOVEQ	#8*2-1,D1
	
.UP14	MOVE.B	17(A1),17(A5)
	MOVE.W	32(A1),32(A5)
	MOVE.W	48(A1),48(A5)
	MOVE.W	64(A1),64(A5)
	MOVE.W	80(A1),80(A5)
	MOVE.W	96(A1),96(A5)

	LEA	640(A5),A5
	LEA	640(A1),A1
	DBF	D1,.UP14
	RTS
*****************************************************************************************
NB_UP
	LEA	VOICE_TAB,A2
	
	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ	NB_LIN2
	MOVE.L	#screen+640*369+4,A0
	BSR	NBUP
	
NB_LIN2	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ	NB_LIN3
	MOVE.L	#screen+640*(369+80)+4,A0
	BSR	NBUP
	
NB_LIN3	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ	NB_LIN4
	MOVE.L	#screen+640*(369+160)+4,A0
	BSR	NBUP
	
NB_LIN4	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ	NB_LIN5
	MOVE.L	#screen+640*(369+240)+4,A0
	BSR	NBUP
	
NB_LIN5	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ	NB_LIN6
	MOVE.L	#screen+640*(369+320)+4,A0
	BSR	NBUP

NB_LIN6	MOVEQ	#0,D0
	ADD.B	(A2)+,D0
	ADD.B	(A2)+,D0
	TST.B	D0
	BEQ.S	.RT
	MOVE.L	#screen+640*(369+400)+4,A0
	BSR	NBUP
.RT	RTS
	
*--------------------------------------------------------------------------	
NBUP	MOVE.L	A0,A1
	MOVE.L	A0,A3
	ADD.L	#640*8,A1

	MOVE.L	#8*2-1,D0
.COP1	MOVE.W	(A1),(A0)
	LEA	640(A0),A0
	LEA	640(A1),A1
	DBF	D0,.COP1
	
	LEA	640(A1),A1
	MOVEQ	#8-1,D0
.COP2	MOVE.W	(A1),(A0)
	LEA	 640(A0),A0
	LEA	1280(A1),A1
	DBF	D0,.COP2
	
	LEA	640(A0),A0
	MOVEQ	#8-1,D0
.COP3	MOVE.W	(A1),(A0)
	MOVE.W	(A1),640(A0)
	LEA	1280(A0),A0
	LEA	 640(A1),A1
	DBF	D0,.COP3
	
	MOVEQ	#8*2-1,D0
.COP4	MOVE.W	(A1),(A0)
	LEA	640(A0),A0
	LEA	640(A1),A1
	DBF	D0,.COP4
	
	ADD.L	#640*8*7-15+640,A3
	MOVE.L	A3,where
	MOVE.W	#1,compt2
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
	RTS
*****************************************************************************************
PATTUP2	MOVE.W	#13,okp
	RTS
PATTUP3
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	LEA	wa,a3
	LEA	wb,a6
	MOVE.B	inpatt,d1
	MOVE.B	cvoies,d2
	MULU	d2,d1
	MOVE.L	ADDPATT,a5
	ADD.W	d1,a5
	MOVE.B	voies,d2
	SUBQ.B	#1,d2

.patup	LEA	pat,a2
	MOVE.B	(a5),d0
	BSR	CHECKNOTE
	LEA	hexa,a1
	MOVEQ	#0,d0
	
	MOVE.B	1(a5),d0
	MOVE.W	d0,d1
	AND.B	#$f,d0
	MOVE.B  (a1,d0.w),4(a2)
	LSR.B	#4,d1
	MOVE.B	(a1,d1.w),3(a2)
	
	MOVE.B	2(a5),d0
	MOVE.W	d0,d1
	AND.B	#$f,d0
	MOVE.B  (a1,d0.w),6(a2)
	LSR.B	#4,d1
	MOVE.B	(a1,d1.w),5(a2)
	
	MOVE.B	3(a5),d0
	MOVE.W	d0,d1
	AND.B	#$f,d0
	MOVE.B  (a1,d0.w),8(a2)
	LSR.B	#4,d1
	MOVE.B	(a1,d1.w),7(a2)
	
	MOVE.W	#'00',9(A2)
	
	MOVEQ	#0,d1
	MOVE.B	(a6)+,d1
	MOVE.W	d1,compt2
	MOVE.L	(a3)+,where
	LEA	pat,a0
	MOVEQ	#11,d1
	BSR	PRINT2
	ADDQ.W	#5,a5
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

	MOVE.L	#screen+640*(369+8*5)+4,A0
	MOVE.L	a0,a1
	MOVE.L	a0,a2
	MOVE.L	a0,a3
	MOVE.L	a0,a4
	MOVE.L	a0,a5
	ADD.L	#640*80,a1
	ADD.L	#640*160,a2
	ADD.L	#640*240,a3
	ADD.L	#640*320,a4
	ADD.L	#640*400,a5
	MOVE.L	#8-1,D0
	
.COP	MOVE.W	(A0),(A1)	
	MOVE.W	(A0),(A2)
	MOVE.W	(A0),(A3)
	MOVE.W	(A0),(A4)
	MOVE.W	(A0),(A5)
	LEA	640(A0),A0
	LEA	640(A1),A1
	LEA	640(A2),A2
	LEA	640(A3),A3
	LEA	640(A4),A4
	LEA	640(A5),A5
	DBF	D0,.COP
	
	MOVE.W	#0,okp
	RTS
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
	CMP.L	#-1,a0
	beq	.empty
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	LEA	pattt,a2
	MOVE.B	(a0),d0
	BSR.S	CHECKNOTE
	LEA	hexa,a1
	
	MOVE.B	1(a0),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),4(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),3(a2)

	MOVE.B	2(a0),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),6(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),5(a2)

	MOVE.B	3(a0),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),8(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),7(a2)
	
	MOVE.B	4(a0),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),10(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),9(a2)
	
	
	MOVEQ	#11,d1
	LEA	pattt,a0
	BSR	PRINT
	LEA	cp,a0
	LEA	pattt,a1
	MOVE.L	(a0)+,(a1)+
	MOVE.L	(a0)+,(a1)+
	MOVE.W	(a0)+,(a1)+
	MOVE.B	(a0)+,(a1)+
	MOVEM.L	(A7)+,D0-D1/A0-A2
	RTS
.empty	LEA	vvide,a0
	MOVEQ	#11,d1
	BSR	PRINT
	MOVEM.L	(A7)+,D0-D1/A0-A2
	RTS
pattt	dc.b '---00000000',0
cp	dc.b '---00000000',0
vvide	dc.b '           '
	even	
**********************************************************************
AFFPATTERN:
	MOVE.W	#11,okp
	RTS
	
AFFPATTERN2
	BSR	AFFPATTERN3
	CMP.W	#11,okp
	BNE.S	.OUT
	MOVE.W	#0,okp
.OUT	RTS

AFFPATTERN3
	MOVEQ	#0,d0
	MOVEQ	#8,d2			* Nb de lignes a afficher par voie
	MOVEQ	#0,d3			
	MOVEQ	#0,d4			
	MOVEQ	#0,d5			
	MOVEQ	#0,d6			
	MOVEQ	#0,d7
	MOVE.B	voies,d3
	SUBQ.B	#1,d3			* Nb de voies a afficher
	MOVE.B	cvoies,d6
	MOVE.B	inpatt,d0		* Ou dans la pattern
	MULU	d6,d0			* fois ce que prend 1 ligne 
	ADD.L	ADDPATT,d0		* plus l'adresse de la pattern courante
	SUB.L	d6,d0
	SUB.L	d6,d0
	SUB.L	d6,d0
	MOVE.L	d0,ADDPATT2		* egale la position dans la pattern
	MOVEQ	#0,d0
	LEA	patt,a1
	LEA	VOICE_TAB,A5		* TABLE DES VOIES ACTIVES
	LEA	ccompt2,a6


ja2	MOVE.L	(a1)+,where		* Ou afficher sur l'ecran/voie
	MOVE.W	(a6)+,bo
	MOVE.L	ADDPATT2,a3
	MOVE.B	inpatt,d7
	
	*CMP.B	#1,playsong		* Si on est en play song
	*BNE.S	.ja			* alors on affiche que les
	MOVE.B	(A5)+,D0		* voies utiles (gain de temps)
	BEQ	.za

.ja	MOVE.W	bo,compt2		* on affiche la voie
	CMP.B	#2,d7
	BLE.S	.crien
	CMP.B	#67,d7
	BGE.S	.crien
	BRA.S	.cquel
	
.crien	LEA	vvide,a0
	BRA.S	.ssss
	
.cquel	LEA	pattt,a2		* Calcul ce que l'on va
	MOVE.B	(a3),d0			* Afficher
	BSR	CHECKNOTE
	LEA	hexa,a4
	
	MOVE.B	1(a3),d5
	MOVE.L	d5,d4
	and.b	#$f,d5
	MOVE.B  (a4,d5.w),4(a2)
	lsr.b	#4,d4
	MOVE.B	(a4,d4.w),3(a2)
	
	MOVE.B	2(a3),d5
	MOVE.W	d5,d4
	and.b	#$f,d5
	MOVE.B  (a4,d5.w),6(a2)
	lsr.b	#4,d4
	MOVE.B	(a4,d4.w),5(a2)
	
	MOVE.B	3(a3),d5
	MOVE.W	d5,d4
	and.b	#$f,d5
	MOVE.B  (a4,d5.w),8(a2)
	lsr.b	#4,d4
	MOVE.B	(a4,d4.w),7(a2)
	
	MOVE.B	4(a3),d5
	MOVE.W	d5,d4
	and.b	#$f,d5
	MOVE.B  (a4,d5.w),10(a2)
	lsr.b	#4,d4
	MOVE.B	(a4,d4.w),9(a2)
	
	LEA	pattt,a0

.ssss	SUBQ.B	#1,d2
	CMP.B	#4,d2
	BEQ.S	.s16
	CMP.B	#0,d2
	BEQ.S	.za
	
	MOVEQ	#11,d1
	BSR	PRINT
	ADD.L	#640*7+561-16,where
	CMP.W	#1,bo
	BEQ.S	.PL
	ADD.L	#14,where
.PL	ADD.W	d6,a3
	ADDQ.B	#1,d7
	BRA	.ja
	
.s16	ADD.L	#640,where
	MOVEQ	#11,d1
	BSR	PRINT2
	ADD.L	#640*15+561-16,where
	CMP.W	#1,bo
	BEQ.S	.LP
	ADD.L	#14,where
.LP	ADD.W	d6,a3
	ADDQ.B	#1,d7
	BRA	.ja

.za	ADDQ.L	#5,ADDPATT2
	MOVEQ	#8,d2
	LEA	cp,a0
	LEA	pattt,a2
	MOVE.L	(a0)+,(a2)+
	MOVE.L	(a0)+,(a2)+
	MOVE.B	(a0)+,(a2)+
	DBF	d3,ja2



	MOVEQ	#0,D0
	MOVEQ	#0,D3
	MOVE.B	inpatt,D0
	SUBQ.B	#3,D0
	MOVE.L	#screen+640*369-11,where
	
.thro	MOVE.W	#1,compt2
	CMP.W	#0,D0
	BLT.S	.negatif
	CMP.W	#63,d0
	BGT.S	.negatif
	
	LEA	cs,a0
	MOVE.L	d0,d4
	DIVU	#10,d4
	ADD.B	#'0',d4
	MOVE.B	d4,(a0)+
	SWAP	d4
	ADD.B	#'0',d4
	MOVE.B	d4,(a0)+
	LEA	cs,a0
	BRA.S	.positif
	
.negatif
	LEA	cv,A0

.positif
	CMP.B	#3,D3
	BEQ.S	.af16
	MOVEQ	#2,d1
	BSR	PRINT
	ADD.L	#640*7+624,where
	BRA.S	.trou
	
.af16	MOVEQ	#2,d1
	ADD.L	#640,where
	BSR	PRINT2
	ADD.L	#640*15+624,where
	
.trou	ADDQ.B	#1,d3
	ADDQ.B	#1,d0
	CMP.B	#7,d3
	BEQ.S	.nif
	BRA.S	.thro
	
.nif	MOVE.L	#screen+640*369+4,A0
	MOVE.L	a0,a1
	MOVE.L	a0,a2
	MOVE.L	a0,a3
	MOVE.L	a0,a4
	MOVE.L	a0,a5
	ADD.L	#640*80,a1
	ADD.L	#640*160,a2
	ADD.L	#640*240,a3
	ADD.L	#640*320,a4
	ADD.L	#640*400,a5
	MOVE.L	#8*8-1,D0
	
.COP	MOVE.W	(A0),(A1)	
	MOVE.W	(A0),(A2)
	MOVE.W	(A0),(A3)
	MOVE.W	(A0),(A4)
	MOVE.W	(A0),(A5)
	LEA	640(A0),A0
	LEA	640(A1),A1
	LEA	640(A2),A2
	LEA	640(A3),A3
	LEA	640(A4),A4
	LEA	640(A5),A5
	DBF	D0,.COP
	
	RTS
	
patt:	DC.L	VOICE,VOICE+111,VOICE+208,VOICE+319,VOICE+416,VOICE+527
	DC.L	VOICE+640*80,VOICE+640*80+111,VOICE+640*80+208,VOICE+640*80+319,VOICE+640*80+416,VOICE+640*80+527
	DC.L	VOICE+640*160,VOICE+640*160+111,VOICE+640*160+208,VOICE+640*160+319,VOICE+640*160+416,VOICE+640*160+527
	DC.L	VOICE+640*240,VOICE+640*240+111,VOICE+640*240+208,VOICE+640*240+319,VOICE+640*240+416,VOICE+640*240+527
	DC.L	VOICE+640*320,VOICE+640*320+111,VOICE+640*320+208,VOICE+640*320+319,VOICE+640*320+416,VOICE+640*320+527
	DC.L	VOICE+640*400,VOICE+640*400+527
	DC.L	-1
	
ccompt2	DC.W	1,0,1,0,1,0
	DC.W	1,0,1,0,1,0
	DC.W	1,0,1,0,1,0
	DC.W	1,0,1,0,1,0
	DC.W	1,0,1,0,1,0
	DC.W	1,0

ADDPATT2	dc.l	0
wherevoice2	dc.w	0
ADDition	dc.w	0
bo		dc.w	0
cv		dc.b    '  '
cs		dc.b    '00'

**********************************************************************
AFFDATA
	MOVEM.L	D0-D1/A0-A1,-(A7)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	LEA	pat,A2
	MOVE.B	#'-',(A2)
	MOVE.B	#'-',1(A2)
	MOVE.B	#'-',2(A2)
	MOVE.B	(A3),D0
	BSR	CHECKNOTE
	LEA	hexa,a1
	MOVE.B	1(a3),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),4(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),3(a2)
	MOVE.B	2(a3),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),6(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),5(a2)
	MOVE.B	3(a3),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),8(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),7(a2)
	MOVE.B	4(a3),d0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B  (a1,d0.w),10(a2)
	lsr.b	#4,d1
	MOVE.B	(a1,d1.w),9(a2)
	
	MOVE.W	wherevoice,d0
	DIVU	#5,D0
	LEA	wb,A0
	MOVE.B	(A0,D0.W),D1
	MOVE.W	D1,compt2
	LEA	wa,A0
	MOVE.L	(A0,D0.W*4),where
	ADDQ.L	#2,where
	LEA	pat,a0
	MOVEQ	#11,d1
	BSR	PRINT2
	MOVEm.l	(a7)+,d0-d1/a0-a1
	RTS
hexa	dc.b 	'0123456789ABCDEF'
pat	dc.b 	'---00000000'
	even	
	
wa	dc.l	CUR-2,CUR+109,CUR+206,CUR+317,CUR+414,CUR+525,CUR+622

wb	dc.b	1,0,1,0,1,0

	even
zerotou	dc.w	0
**********************************************************************
CHECKPATT
	CMP.B	#0,edit			* si = 1 alors edit
	BEQ	.paricilasortie
	
.on_edit	
	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	MOVE.L	ADDPATT,a0
	MOVE.B	inpatt,d1
	MOVE.B	cvoies,d2
	MULU	d2,d1
	ADD.W	wherevoice,d1
	ADD.W	d1,a0
	
	CMP.W	#1,zerotou
	BNE.S	.gou
	
	MOVE.B	d0,(a0)
	MOVE.B	d0,1(a0)
	MOVE.B	d0,2(a0)
	MOVE.B	d0,3(a0)
	MOVE.B	d0,4(a0)
	MOVE.B	d0,recnote
	MOVE.B	d0,recinst
	BRA	.BOU
	
.gou	CMP.B	#1,DRUM
	BEQ	.GUO

	MOVEQ	#0,D0	
	MOVE.B	recinst,D0
	MOVE.B	D0,D1
	SUBQ.B	#1,D0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A1
	ADD.L	D0,A1
	CMP.L	#0,LEN_MGT(A1)
	BEQ	.paricilasortie
	
	MOVE.B	NOTE_MGT(A1),(A0)
	MOVE.B	D1,1(A0)
	MOVE.B	COMMAND_MGT(A1),2(A0)
	MOVE.B	PARAM_MGT(A1),3(A0)
	MOVE.B	#0,4(A0)
	BRA	.BOU

.GUO	MOVEQ	#0,D1
	LEA	datawhat,A1
	MOVE.B	whatvoice,D1
	MOVE.L	(A1,D1.W*4),A1
	JSR	(A1)
	
	MOVE.B	#0,recnote
	MOVE.B	#0,recinst
	MOVE.B	#0,reccom
	MOVE.B	#0,receff
	MOVE.B	#0,recvol
	
.BOU	MOVE.L	a0,a3
	BSR	AFFDATA
	
	CMP.B	#0,playpat		* si on est en mode
	BNE.S	.rdd			* play pattern  alors
	CMP.B	#63,inpatt
	BGE.S	.paricilasortie2
	BSR	JOUEVOIE
	ADDQ.B	#1,inpatt		* on incremente pas
.rdd	BSR	PATTUP
	RTS
.paricilasortie2
	BSR.L	INVERT_EDIT
	MOVE.B	#0,edit
.paricilasortie
	RTS
	
edit	dc.b	0			* Etat de l'editeur
inpatt:	dc.b	0			* Compteur dans la patt
**********************************************************************
PLAYPATT
	cmp.b	#1,playpat
	beq.s	.rt5
	
	*BSR	EFFPAT
	MOVE.B	#0,inpatt
	BRA.S	.RT11
	
.rt5	BSR	AFFPATTERN

.RT11	BCHG	#0,playpat
	MOVE.W	#0,u
	BSR.L	INVERT_PLAYPATT
	
	CMP.B	#1,playsong
	BNE.S	RT14
	
	MOVE.B	#0,playsong
	BSR.L	INVERT_PLAYSONG
	
RT14	CMP.B	#1,record
	BNE.S	.rt9
	
	MOVE.B	#0,record
	BSR.L	INVERT_RECORD
	
.rt9	CMP.B	#1,edit
	BNE.S	.rt10
	
	MOVE.B	#0,edit
	BSR.L	INVERT_EDIT
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata
.rt10	RTS

v	dc.w	6			* Vitesse de la zik (tempo)
u	dc.w	6
playpat	dc.b	0			* Si = 1  alors mode PLAY PATT
playsong	dc.b	0		* Si = 1  alors mode PLAY SONG
**********************************************************************
PLAYSONG
	CMP.B	#1,playsong
	BEQ.S	.RT12
	*BSR	EFFPAT
	MOVE.B	#0,inpatt
	BRA.S	.RT13
.RT12	BSR	AFFPATTERN
.RT13	BCHG	#0,playsong
	MOVE.W	#0,u
	BSR.L	INVERT_PLAYSONG
	CMP.B	#1,playpat
	BNE.S	.RT15
	MOVE.B	#0,playpat
	BSR.L	INVERT_PLAYPATT
.RT15	BRA	RT14
**********************************************************************
VBLPAT  ADDQ.W	#1,u
	MOVE.W	u,D0
	CMP.W	v,D0
	BLO	.sor
	MOVE.W	#0,u
	
	CMP.B	#1,playsong
	BNE.S	.ssre
	BSR	SONG1
	
.ssre	BSR	JOUEVOIE

	CMP.B	#0,inpatt
	BEQ.S	.ssre2
	
	BSR	PATTUP				* PATTUP3
	
.ssre2	CMP.B	#63,inpatt
	BNE.S	.ros
	
	CMP.B	#1,playpat
	BNE.S	.ros
	MOVE.B	#0,playpat
	BSR.L	INVERT_PLAYPATT
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata
	MOVE.W	#0,u
	BRA.S	.SOR2
	
.ros	ADDQ.B	#1,inpatt

.SOR2	CMP.B	#-1,BREAK
	BNE.S	.SRO
	MOVE.B	#0,BREAK
	MOVEQ	#0,D0
	MOVE.B	BREAKPOS,inpatt
	MOVE.B	#0,BREAKPOS
	BSR	sng1
.SRO	RTS
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
	MOVE.L	ADDPATT,A0
	MOVE.B	inpatt,D0
	MOVE.B	cvoies,D1
	MULU	D1,D0
	ADD.W	D0,A0
	
	LEA	VOICE0,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE1,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE2,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE3,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE4,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE5,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE6,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE7,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE8,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE9,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE10,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE11,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE12,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE13,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE14,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE15,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE16,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE17,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE18,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE19,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE20,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE21,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE22,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE23,A1
	BSR	TREAT_ONE_VOICE
	LEA	VOICE24,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE25,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE26,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE27,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE28,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE29,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE30,A1
	BSR.S	TREAT_ONE_VOICE
	LEA	VOICE31,A1
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
	ADDQ.W	#5,A0
	RTS

SET_P	MOVE.B	1(A0),D0			* verifie INSTRUMENT
						* si non alors verifie
	BEQ.S	SET_PERIODE			* la note
	MOVE.B	D0,34(A1)
	BSR	INSTR
SET_PERIODE
	MOVE.B	(A0),D1				* NOTE
	BNE.S	GFD
	TST.B	1(A0)				* INSTRU
	BEQ.S	TREAT_EFFECT
	MOVE.W	32(A1),(A1)
	MOVE.B	63(A1),D1
	
GFD	LEA	TABLE_DIGINOTE,A2
	MOVEQ	#0,D0
	MOVE.B	58(A1),D0			* FINE TUNE
	MOVE.L	(A2,D0.W*4),A2
	MOVE.B	D1,63(A1)
	SUBQ.W	#1,D1
	ADD.W	D1,D1
	*ADD.W	D0,D1
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
	MOVE.B	4(A0),53(A1)
	BEQ.S	TREAT_EFF
	MOVE.B	53(A1),22(A1)
	MOVE.B	53(A1),37(A1)
	
TREAT_EFF
	MOVE.B	2(A0),D0			* EFFECT NUMBER
	CMP.B	#$20,D0
	BGE.S	PON1
	MOVE.B	D0,35(A1)
	MOVE.B	3(A0),36(A1)
	LEA	TABLE_EFFECT,A2
	MOVE.L	(A2,D0.W*4),A2
	JSR	(A2)
PON1	ADDQ.W	#5,A0				* NEXT VOICE
NO_EFFECT
	RTS
**********************************************************************
INSTR	LEA	SAMPLE,A3
	SUBQ.B	#1,D0
	MULU	#LEN_SAMPLE_MGT,D0
	ADD.L	D0,A3
	
	CMP.B	#0,(A0)
	BNE.S	DS
	CMP.B	#$A,2(A0)
	BNE.S	DS
	BRA	SD
	
DS	MOVE.L	DEB_MGT(A3),2(A1)		* ADD DEBUT
	MOVE.L	DEB_MGT(A3),18(A1)		* DANS ADD DEBUT SPL
	*MOVE.L	LEN_MGT(A3),38(A1)
	MOVE.B	F_TUNE_MGT(A3),58(A1)		* FINE TUNE
	MOVE.B	VOL_MGT(A3),37(A1)		* VOLUME
	MOVE.B	VOL_MGT(A3),22(A1)
	MOVE.B	LOOP_MGT(A3),23(A1)		* LOOP OR NOT
	MOVE.B	MONO_MGT(A3),31(A1)		* FRQ DU SPL (6.25,12.5,25,50)
	MOVE.L	LOOP_DEB_MGT(A3),6(A1)		* ADD LOOP DEBUT
	MOVE.L	LOOP_DEB_MGT(A3),14(A1)		* DANS WAVE START
	MOVE.L	FIN_MGT(A3),10(A1)		* FIN LOOP = FIN DU SAMPLE
	MOVE.B	BIT1_MGT(A3),38(A1)		* NB DE BIT (8 OU 16)
	RTS
SD	MOVE.B	VOL_MGT(A3),37(A1)		* VOLUME
	MOVE.B	VOL_MGT(A3),22(A1)
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
	MOVE.L	(A2,D1.W*4),A2
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
	LEA	TABLE_DIGINOTE,A2
	MOVE.L	(A2,D0.W*4),A2
	ADD.W	D2,D2
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
	LEA	TABLE_DIGINOTE,A2
	MOVE.L	(A2,D0.W*4),A2
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
	CMP.W	#$1F,D0
	BGE	VOL_OK
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
	BSR	OUT_PAT
	LEA	VOICE1,A1
	BSR	OUT_PAT
	LEA	VOICE2,A1
	BSR	OUT_PAT
	LEA	VOICE3,A1
	BSR	OUT_PAT
	LEA	VOICE4,A1
	BSR	OUT_PAT
	LEA	VOICE5,A1
	BSR	OUT_PAT
	LEA	VOICE6,A1
	BSR	OUT_PAT
	LEA	VOICE7,A1
	BSR	OUT_PAT
	LEA	VOICE8,A1
	BSR	OUT_PAT
	LEA	VOICE9,A1
	BSR	OUT_PAT
	LEA	VOICE10,A1
	BSR	OUT_PAT
	LEA	VOICE11,A1
	BSR	OUT_PAT
	LEA	VOICE12,A1
	BSR	OUT_PAT
	LEA	VOICE13,A1
	BSR	OUT_PAT
	LEA	VOICE14,A1
	BSR	OUT_PAT
	LEA	VOICE15,A1
	BSR	OUT_PAT
	LEA	VOICE16,A1
	BSR	OUT_PAT
	LEA	VOICE17,A1
	BSR	OUT_PAT
	LEA	VOICE18,A1
	BSR	OUT_PAT
	LEA	VOICE19,A1
	BSR	OUT_PAT
	LEA	VOICE20,A1
	BSR.S	OUT_PAT
	LEA	VOICE21,A1
	BSR.S	OUT_PAT
	LEA	VOICE22,A1
	BSR.S	OUT_PAT
	LEA	VOICE23,A1
	BSR.S	OUT_PAT
	LEA	VOICE24,A1
	BSR.S	OUT_PAT
	LEA	VOICE25,A1
	BSR.S	OUT_PAT
	LEA	VOICE26,A1
	BSR.S	OUT_PAT
	LEA	VOICE27,A1
	BSR.S	OUT_PAT
	LEA	VOICE28,A1
	BSR.S	OUT_PAT
	LEA	VOICE29,A1
	BSR.S	OUT_PAT
	LEA	VOICE30,A1
	BSR.S	OUT_PAT
	LEA	VOICE31,A1
	BSR.S	OUT_PAT
	RTS

OUT_PAT	MOVEQ	#0,D0
	MOVE.B	35(A1),D0
	CMP.B	#$20,D0
	BGE.S	OK_RTS
	LEA	TABLE_EFFECT2,A2
	MOVE.L	(A2,D0.W*4),A2
	JSR	(A2)
OK_RTS	RTS
**********************************************************************
SONG1	cmp.b	#64,inpatt
	beq.s	sng1
	RTS
sng1	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	MOVE.B	curseq,d0
	MOVE.B	curlen,d1
	cmp.B	d0,d1
	beq	finsong
	ADDQ.B	#1,d0
LLOP	MOVE.B	d0,curseq
	MOVE.L	d0,d3
	LEA	char3,a0
	BSR.L	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*320+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT

	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVE.B	curseq,d0
	MOVE.B	curnum,d1
	MULU	#256,d1
	MOVE.L	ADDSEQ,a0
	ADD.w	d1,a0
	ADD.w	d0,a0
	MOVE.B	(a0),d2
	MOVE.B	d2,curpatt

	MOVE.B	d2,d0
	LEA	char3,a0
	BSR.L	CONVERT_BYTE_DECI
	LEA	char3,a0
	MOVE.L  #screen+640*328+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT

	MOVEQ	#0,d0
	MOVE.B	cvoies,d0
	MULU	d0,d2
	MULU	#64,d2
	MOVE.L	debpatt,a0
	ADD.L	d2,a0
	MOVE.L	a0,ADDPATT
	MOVE.B	#0,inpatt
	BSR	AFFPATTERN
	RTS
finsong 
	MOVE.B	curlop,d0
	BRA	LLOP
**********************************************************************
VBLRECORD
	CMP.W	#1,sync
	BEQ	.ross
.rio	MOVEQ	#0,d0
	MOVEQ	#0,d1
	MOVEQ	#0,d2
	MOVE.L	ADDPATT,a0
	MOVE.B	inpatt,d0
	MOVE.B	cvoies,d2
	MULU	d2,d0
	ADD.W	wherevoice,d0
	ADD.W	d0,a0
	
	CMP.W	#1,zerotou
	BNE.S	.ter
	
	MOVE.B	d1,(a0)
	MOVE.B	d1,1(a0)
	MOVE.B	d1,2(a0)
	MOVE.B	d1,3(a0)
	MOVE.B	d1,recinst
	bra.s	.zer

.ter	CMP.B	#1,DRUM
	BEQ	.GUO

	MOVEQ	#0,D0	
	MOVE.B	recinst,D0
	MOVE.B	D0,D1
	SUBQ.B	#1,D0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A1
	ADD.L	D0,A1
	CMP.L	#0,LEN_MGT(A1)
	BEQ	.zer
	
	MOVE.B	NOTE_MGT(A1),(A0)
	MOVE.B	D1,1(A0)
	MOVE.B	COMMAND_MGT(A1),2(A0)
	MOVE.B	PARAM_MGT(A1),3(A0)
	BRA	.zer


.GUO	MOVEQ	#0,d1
	LEA	datawhat,a1
	MOVE.B	whatvoice,d1
	MOVE.L	(a1,d1.w*4),a1
	JSR	(a1)
	
.zer	ADDQ.W	#1,u
	MOVE.W	u,D0
	CMP.W	v,D0
	BLO	.ssor
	MOVE.W	#0,u
	
	MOVE.B	#0,recnote
	MOVE.B	#0,recinst
	MOVE.B	#0,reccom
	MOVE.B	#0,receff
	MOVE.B	#0,recvol
	
	MOVE.L	A0,A3
	BSR	AFFDATA
	BSR	JOUEVOIE
	CMP.B	#63,inpatt
	BGE.S	.sre
	ADDQ.B	#1,inpatt
	BSR	PATTUP
	bra.s	.ssor
.sre	MOVE.B	#0,record
	BSR.L	INVERT_RECORD
	MOVE.B	dernier,curentnb2
	MOVE.B	dernier,sampledata
.ssor	RTS
.ross	cmp.b	#0,KEY
	beq.s	.iop
	MOVE.W	#0,sync
	bra	.rio
.iop	RTS
sync	dc.w	0
datawhat	dc.l	w0,w1,w2,w3,w4,w5,w6,w8,w9
**********************************************************************
* whatvoice = 0  (Note)
w0	cmp.b	#-1,recinst
	beq.s	w7
	MOVE.B	recnote,(a0)
	MOVE.B	recinst,1(a0)
w7	RTS
* whatvoice = 1  (Instrument - haut)
w1	cmp.b	#-1,recinst
	beq.s	w7
	MOVE.B	recinst,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,1(a0)
	or.b	d0,1(a0)
	RTS
* whatvoice = 2  (Instrument - bas )
w2	cmp.b	#-1,recinst
	beq.s	w7
	MOVE.B	recinst,d0
	and.b	#$f,d0
	and.b	#$f0,1(a0)
	or.b	d0,1(a0)
	RTS
* whatvoice = 3  (Commande - haut)
w3	cmp.b	#-1,reccom
	beq.s	w7
	MOVE.B	reccom,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,2(a0)
	or.b	d0,2(a0)
	RTS
* whatvoice = 4  (Commande - bas)
w4	cmp.b	#-1,reccom
	beq.s	w7
	MOVE.B	reccom,d0
	and.b	#$f,d0
	and.b	#$f0,2(a0)
	or.b	d0,2(a0)
	RTS
* whatvoice = 5  (Donnees - haut)
w5	cmp.b	#-1,receff
	beq	w7
	MOVE.B	receff,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,3(a0)
	or.b	d0,3(a0)
	RTS
* whatvoice = 6  (Donnees - bas )
w6	cmp.b	#-1,receff
	beq	w7
	MOVE.B	receff,d0
	and.b	#$f,d0
	and.b	#$f0,3(a0)
	or.b	d0,3(a0)
	RTS
* whatvoice = 7  (Volume - haut)
w8	cmp.b	#-1,recvol
	beq	w7
	MOVE.B	recvol,d0
	and.b	#$f,d0
	lsl.b	#4,d0
	and.b	#$f,4(a0)
	or.b	d0,4(a0)
	RTS
* whatvoice = 8  (Volume - bas )
w9	cmp.b	#-1,recvol
	beq	w7
	MOVE.B	recvol,d0
	and.b	#$f,d0
	and.b	#$f0,4(a0)
	or.b	d0,4(a0)
	RTS
**********************************************************************
LEFTCURSOR
	cmp.W	#0,curpos
	beq.S	.leftout
	MOVEQ	#0,d0
	BSR	OPTI
	subq.W	#1,curpos	
	BSR	OPTI
	RTS
.leftout	MOVEQ	#0,d0
	BSR	OPTI
	MOVE.W	#287,curpos
	BSR	OPTI
	RTS
RIGHTCURSOR
	cmp.W	#287,curpos
	beq.s	.rightout
	MOVEQ	#0,d0
	BSR	OPTI
	ADDQ.W	#1,curpos	
	BSR	OPTI
	RTS
.rightout
	MOVEQ	#0,d0
	BSR	OPTI
	MOVE.W	#0,curpos
	BSR	OPTI
	RTS
dataposcur
	dc.l	CUR+15,CUR+32,CUR+47,CUR+48,CUR+63,CUR+64,CUR+79,CUR+80,CUR+95
	dc.l	CUR+112,CUR+143,CUR+144,CUR+159,CUR+160,CUR+175,CUR+176,CUR+191,CUR+192
	dc.l	CUR+223,CUR+240,CUR+255,CUR+256,CUR+271,CUR+272,CUR+287,CUR+288,CUR+303
	dc.l	CUR+320,CUR+351,CUR+352,CUR+367,CUR+368,CUR+383,CUR+384,CUR+399,CUR+400
	dc.l	CUR+431,CUR+448,CUR+463,CUR+464,CUR+479,CUR+480,CUR+495,CUR+496,CUR+511
	dc.l	CUR+528,CUR+559,CUR+560,CUR+575,CUR+576,CUR+591,CUR+592,CUR+607,CUR+608
	
	dc.l	CUR+640*80+15,CUR+640*80+32,CUR+640*80+47,CUR+640*80+48,CUR+640*80+63,CUR+640*80+64,CUR+640*80+79,CUR+640*80+80,CUR+640*80+95
	dc.l	CUR+640*80+112,CUR+640*80+143,CUR+640*80+144,CUR+640*80+159,CUR+640*80+160,CUR+640*80+175,CUR+640*80+176,CUR+640*80+191,CUR+640*80+192
	dc.l	CUR+640*80+223,CUR+640*80+240,CUR+640*80+255,CUR+640*80+256,CUR+640*80+271,CUR+640*80+272,CUR+640*80+287,CUR+640*80+288,CUR+640*80+303
	dc.l	CUR+640*80+320,CUR+640*80+351,CUR+640*80+352,CUR+640*80+367,CUR+640*80+368,CUR+640*80+383,CUR+640*80+384,CUR+640*80+399,CUR+640*80+400
	dc.l	CUR+640*80+431,CUR+640*80+448,CUR+640*80+463,CUR+640*80+464,CUR+640*80+479,CUR+640*80+480,CUR+640*80+495,CUR+640*80+496,CUR+640*80+511
	dc.l	CUR+640*80+528,CUR+640*80+559,CUR+640*80+560,CUR+640*80+575,CUR+640*80+576,CUR+640*80+591,CUR+640*80+592,CUR+640*80+607,CUR+640*80+608
	
	dc.l	CUR+640*160+15,CUR+640*160+32,CUR+640*160+47,CUR+640*160+48,CUR+640*160+63,CUR+640*160+64,CUR+640*160+79,CUR+640*160+80,CUR+640*160+95
	dc.l	CUR+640*160+112,CUR+640*160+143,CUR+640*160+144,CUR+640*160+159,CUR+640*160+160,CUR+640*160+175,CUR+640*160+176,CUR+640*160+191,CUR+640*160+192
	dc.l	CUR+640*160+223,CUR+640*160+240,CUR+640*160+255,CUR+640*160+256,CUR+640*160+271,CUR+640*160+272,CUR+640*160+287,CUR+640*160+288,CUR+640*160+303
	dc.l	CUR+640*160+320,CUR+640*160+351,CUR+640*160+352,CUR+640*160+367,CUR+640*160+368,CUR+640*160+383,CUR+640*160+384,CUR+640*160+399,CUR+640*160+400
	dc.l	CUR+640*160+431,CUR+640*160+448,CUR+640*160+463,CUR+640*160+464,CUR+640*160+479,CUR+640*160+480,CUR+640*160+495,CUR+640*160+496,CUR+640*160+511
	dc.l	CUR+640*160+528,CUR+640*160+559,CUR+640*160+560,CUR+640*160+575,CUR+640*160+576,CUR+640*160+591,CUR+640*160+592,CUR+640*160+607,CUR+640*160+608

	dc.l	CUR+640*240+15,CUR+640*240+32,CUR+640*240+47,CUR+640*240+48,CUR+640*240+63,CUR+640*240+64,CUR+640*240+79,CUR+640*240+80,CUR+640*240+95
	dc.l	CUR+640*240+112,CUR+640*240+143,CUR+640*240+144,CUR+640*240+159,CUR+640*240+160,CUR+640*240+175,CUR+640*240+176,CUR+640*240+191,CUR+640*240+192
	dc.l	CUR+640*240+223,CUR+640*240+240,CUR+640*240+255,CUR+640*240+256,CUR+640*240+271,CUR+640*240+272,CUR+640*240+287,CUR+640*240+288,CUR+640*240+303
	dc.l	CUR+640*240+320,CUR+640*240+351,CUR+640*240+352,CUR+640*240+367,CUR+640*240+368,CUR+640*240+383,CUR+640*240+384,CUR+640*240+399,CUR+640*240+400
	dc.l	CUR+640*240+431,CUR+640*240+448,CUR+640*240+463,CUR+640*240+464,CUR+640*240+479,CUR+640*240+480,CUR+640*240+495,CUR+640*240+496,CUR+640*240+511
	dc.l	CUR+640*240+528,CUR+640*240+559,CUR+640*240+560,CUR+640*240+575,CUR+640*240+576,CUR+640*240+591,CUR+640*240+592,CUR+640*240+607,CUR+640*240+608

	dc.l	CUR+640*320+15,CUR+640*320+32,CUR+640*320+47,CUR+640*320+48,CUR+640*320+63,CUR+640*320+64,CUR+640*320+79,CUR+640*320+80,CUR+640*320+95
	dc.l	CUR+640*320+112,CUR+640*320+143,CUR+640*320+144,CUR+640*320+159,CUR+640*320+160,CUR+640*320+175,CUR+640*320+176,CUR+640*320+191,CUR+640*320+192
	dc.l	CUR+640*320+223,CUR+640*320+240,CUR+640*320+255,CUR+640*320+256,CUR+640*320+271,CUR+640*320+272,CUR+640*320+287,CUR+640*320+288,CUR+640*320+303
	dc.l	CUR+640*320+320,CUR+640*320+351,CUR+640*320+352,CUR+640*320+367,CUR+640*320+368,CUR+640*320+383,CUR+640*320+384,CUR+640*320+399,CUR+640*320+400
	dc.l	CUR+640*320+431,CUR+640*320+448,CUR+640*320+463,CUR+640*320+464,CUR+640*320+479,CUR+640*320+480,CUR+640*320+495,CUR+640*320+496,CUR+640*320+511
	dc.l	CUR+640*320+528,CUR+640*320+559,CUR+640*320+560,CUR+640*320+575,CUR+640*320+576,CUR+640*320+591,CUR+640*320+592,CUR+640*320+607,CUR+640*320+608
	
	dc.l	CUR+640*400+15,CUR+640*400+32,CUR+640*400+47,CUR+640*400+48,CUR+640*400+63,CUR+640*400+64,CUR+640*400+79,CUR+640*400+80,CUR+640*400+95
	dc.l	CUR+640*400+528,CUR+640*400+559,CUR+640*400+560,CUR+640*400+575,CUR+640*400+576,CUR+640*400+591,CUR+640*400+592,CUR+640*400+607,CUR+640*400+608

curpos	DC.W	0
whatvoice			* Qu'est-ce dans la voie ?
	dc.b	0		* 0 = Note
				* 1 = Instrument (hexa - haut)
				* 2 = Instrument (hexa - bas)
				* 3 = Commande   (hexa - haut)
				* 4 = Commande   (hexa - bas)
				* 5 = Donnees sur Commande (hexa - haut)
				* 6 = Donnees sur Commande (hexa - bas)
				* 7 = Volume     (hexa - haut)
				* 8 = Volume     (hexa - bas)
postyle	dc.b	0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8
	dc.b	5,0,5,1,5,2,5,3,5,4,5,5,5,6,5,7,5,8
	dc.b	10,0,10,1,10,2,10,3,10,4,10,5,10,6,10,7,10,8
	dc.b	15,0,15,1,15,2,15,3,15,4,15,5,15,6,15,7,15,8
	dc.b	20,0,20,1,20,2,20,3,20,4,20,5,20,6,20,7,20,8
	dc.b	25,0,25,1,25,2,25,3,25,4,25,5,25,6,25,7,25,8
	dc.b	30,0,30,1,30,2,30,3,30,4,30,5,30,6,30,7,30,8
	dc.b	35,0,35,1,35,2,35,3,35,4,35,5,35,6,35,7,35,8
	dc.b	40,0,40,1,40,2,40,3,40,4,40,5,40,6,40,7,40,8
	dc.b	45,0,45,1,45,2,45,3,45,4,45,5,45,6,45,7,45,8
	dc.b	50,0,50,1,50,2,50,3,50,4,50,5,50,6,50,7,50,8
	dc.b	55,0,55,1,55,2,55,3,55,4,55,5,55,6,55,7,55,8
	dc.b	60,0,60,1,60,2,60,3,60,4,60,5,60,6,60,7,60,8
	dc.b	65,0,65,1,65,2,65,3,65,4,65,5,65,6,65,7,65,8
	dc.b	70,0,70,1,70,2,70,3,70,4,70,5,70,6,70,7,70,8
	dc.b	75,0,75,1,75,2,75,3,75,4,75,5,75,6,75,7,75,8
	dc.b	80,0,80,1,80,2,80,3,80,4,80,5,80,6,80,7,80,8
	dc.b	85,0,85,1,85,2,85,3,85,4,85,5,85,6,85,7,85,8
	dc.b	90,0,90,1,90,2,90,3,90,4,90,5,90,6,90,7,90,8
	dc.b	95,0,95,1,95,2,95,3,95,4,95,5,95,6,95,7,95,8
	dc.b	100,0,100,1,100,2,100,3,100,4,100,5,100,6,100,7,100,8
	dc.b	105,0,105,1,105,2,105,3,105,4,105,5,105,6,105,7,105,8
	dc.b	110,0,110,1,110,2,110,3,110,4,110,5,110,6,110,7,110,8
	dc.b	115,0,115,1,115,2,115,3,115,4,115,5,115,6,115,7,115,8
	dc.b	120,0,120,1,120,2,120,3,120,4,120,5,120,6,120,7,120,8
	dc.b	125,0,125,1,125,2,125,3,125,4,125,5,125,6,125,7,125,8
	dc.b	130,0,130,1,130,2,130,3,130,4,130,5,130,6,130,7,130,8
	dc.b	135,0,135,1,135,2,135,3,135,4,135,5,135,6,135,7,135,8
	dc.b	140,0,140,1,140,2,140,3,140,4,140,5,140,6,140,7,140,8
	dc.b	145,0,145,1,145,2,145,3,145,4,145,5,145,6,145,7,145,8
	dc.b	150,0,150,1,150,2,150,3,150,4,150,5,150,6,150,7,150,8
	dc.b	155,0,155,1,155,2,155,3,155,4,155,5,155,6,155,7,155,8
	EVEN
wherevoice
	DC.W	0			* Position de la voie dans la pattern
***************************************************************************
CURSOR
m	set 0
	rept	14
	not.b	m(a0)
m	set m+640
	endr
	RTS
OPTI	MOVEQ	#0,d0
	MOVEQ	#0,d1
	LEA	dataposcur,a0
	LEA	postyle,a1
	MOVE.W	curpos,d0
	ADD.L	d0,d0
	ADD.L	d0,a1
	MOVE.B	(a1)+,d1
	MOVE.W	d1,wherevoice
	DIVU	#5,d1
	MOVE.B	d1,curvoie
	MOVE.B	(a1)+,whatvoice
	ADD.L	d0,d0
	ADD.L	d0,a0
	MOVE.L	(a0),a0
	SUBQ.W	#2,a0
	BSR.S	CURSOR
	RTS
alors	dc.b	0
	even
**********************************************************************
EFFPAT	MOVE.W	#12,okp
	RTS
EFFPAT2
	MOVE.L	#VOICEUP,A2
	MOVEQ	#0,D0
	MOVEQ	#5,D2
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

	LEA	640(A0),A0
	DBF	D1,.EF1
	LEA	640*17(A0),A0
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
	MOVE.W	#0,okp
	RTS
***************************************************************************
*	A0 = ou mettre le resultat de la conversion
*	D0 = nombre a convertir
*	     Le nombre est a 7 chiffres Hexa
*			     8 chiffres Deci  
CONVERT_HEXA_DECIASCII:
	MOVEM.L	D0-D1/A0-A1,-(A7)
	MOVEQ	#0,D1
	MOVE.L	A0,A1
	DIVU	#10000,d0
	MOVE.L	d0,d1		
	SWAP	d0		
	MOVE.W	#0,d0
	SWAP	d0
	
	DIVU	#1000,D0
	ADD.W	#'0',D0
	MOVE.B	D0,(A0)+
	MOVE.W	#0,D0
	SWAP	D0
	DIVU	#100,d0
	ADD.W	#'0',d0
	MOVE.B	D0,(A0)+
	MOVE.W	#0,d0
	SWAP	D0
	DIVU	#10,d0
	ADD.W	#'0',d0
	MOVE.B	d0,(a0)+
	SWAP	d0
	ADD.W	#'0',d0
	MOVE.B	d0,(a0)+
	MOVE.W	#0,d1
	SWAP	d1
	DIVU	#1000,d1
	ADD.W	#'0',d1
	MOVE.B	d1,(a0)+
	MOVE.W	#0,d1
	SWAP	d1
	DIVU	#100,d1
	ADD.W	#'0',d1
	MOVE.B	d1,(a0)+
	MOVE.W	#0,d1
	SWAP	d1
	DIVU	#10,d1
	ADD.W	#'0',d1
	MOVE.B	D1,(A0)+
	SWAP	D1	
	ADD.W	#'0',D1
	MOVE.B	D1,(A0)+
	MOVE.W	#8,D1
.still	CMP.B	#'0',(A1)
	BNE.S	.sortie
	MOVE.B	#' ',(A1)+
	SUBQ	#1,D1
	CMP.B	#0,D1
	BNE.S	.still
.sortie	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS
**********************************************************************	
*	Affiche les donnees sur le sample
SUM:    MOVEM.L	D0-D1/A0-A1,-(A7)

	BSR	AFF_NAME_SPL
	BSR	AFF_VOLUME_SPL
	BSR	AFF_LOOP_DEB_SPL
	BSR	AFF_LEN_SPL
	BSR	AFF_NB_SPL
	BSR	AFF_MONO_SPL
	BSR	AFF_FRQ_SPL
	BSR	AFF_COM_SPL
	BSR	AFF_PARAM_SPL
	BSR	AFF_BITS_SPL
	BSR	AFF_F_TUNE_SPL
	
	MOVEM.L	(A7)+,D0-D1/A0-A1
	RTS

AFF_F_TUNE_SPL
	MOVEQ	#0,D0
	MOVE.B	F_TUNE_MGT(A1),D0
	LEA	TAB_FT,A2
	LEA	(A2,D0.W*2),A0
	MOVE.L	#screen+640*336+81,where
	MOVE.W	#1,compt2
	MOVEQ	#2,D1
	BSR	PRINT
	RTS
TAB_FT	DC.W	' 0',' 1',' 2',' 3',' 4',' 5',' 6',' 7'
	DC.W	'-8','-7','-6','-5','-4','-3','-2','-1'
	
AFF_PARAM_SPL
	MOVEQ	#0,D0
	MOVE.B	PARAM_MGT(A1),D0
	MOVE.L	#screen+640*304+81,where
	MOVE.W	#1,compt2
	BSR	COM_PARAM
	RTS
	
AFF_COM_SPL
	MOVEQ	#0,D0
	MOVE.B	COMMAND_MGT(A1),D0
	MOVE.L	#screen+640*297+112,where
	MOVE.W	#0,compt2
	BSR	COM_PARAM
	RTS
	
COM_PARAM	
	LEA	nume,A0
	DIVU	#10,D0
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)
	SWAP	D0
	ADD.B	#'0',D0
	MOVE.B	D0,1(A0)
	MOVEQ	#2,D1
	BSR	PRINT
	RTS
		
AFF_BITS_SPL
	MOVEQ	#0,D0
	MOVE.B	BIT1_MGT(A1),D0
	MOVE.L	#screen+640*312+81,where
	BSR	BITS2
	MOVEQ	#0,D0
	MOVE.B	BIT2_MGT(A1),D0
	MOVE.L	#screen+640*320+81,where
	BSR	BITS2
	RTS
BITS2	LEA	nume,A0
	DIVU	#10,D0
	BEQ	.B1
	ADD.B	#'0',D0
	MOVE.B	D0,(A0)
	BRA.S	.B2
	
.B1	MOVE.B	#' ',(A0)
.B2	SWAP	D0
	ADD.B	#'0',D0
	MOVE.B	D0,1(A0)
	MOVE.W	#1,compt2
	MOVEQ	#2,D1
	BSR	PRINT
	RTS
	
AFF_FRQ_SPL
	MOVEQ	#0,D0
	MOVE.B	NOTE_MGT(A1),D0
	LEA	pattt,A2
	BSR	CHECKNOTE
	MOVE.L	#screen+640*297+32,where
	MOVE.W	#0,compt2
	LEA	pattt,A0
	MOVEQ	#3,D1
	BSR	PRINT
	RTS

AFF_LEN_SPL
	MOVE.L	LEN_MGT(a1),D0
	LEA	lengt,A0			* LEN
	BSR	CONVERT_HEXA_DECIASCII
	MOVE.L	#screen+640*233+49,where
	MOVE.W	#1,compt2
	LEA	lengt+1,A0		
	MOVEQ	#7,D1
	BSR	PRINT
	RTS


AFF_LOOP_DEB_SPL
	MOVE.L	LOOP_DEB_MGT(A1),D0
	BEQ.S	.nn2
	SUB.L	DEB_MGT(A1),D0
	LEA	lengt,A0			* LOOB DEB
	BSR	CONVERT_HEXA_DECIASCII
	CMP.B	#3,LOOP_MGT(a1)
	BNE.S	.nn1
	MOVE.L	LOOP_DEB_MGT(a1),d0
	SUB.L	DEB_MGT(a1),d0
	CMP.L	#0,d0
	BNE.S	.nn1
	MOVE.B	#'0',lengt+7
	BRA	.nn1
.nn2	MOVE.L	#'    ',lengt
	MOVE.L	#'    ',lengt+4
.nn1	MOVE.L	#screen+640*266+49,where
	MOVE.W	#1,compt2
	LEA	lengt+1,A0		
	MOVEQ	#7,D1
	BSR	PRINT
	RTS
	
AFF_VOLUME_SPL	
	MOVEQ	#0,D0
	MOVE.B	VOL_MGT(A1),D0
	*MOVE.B	VOLUME_GENERAL,D0
	LEA	hexa,a2
	LEA	nume,a0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B	(a2,d0.w),1(a0)
	lsr.b	#4,d1
	MOVE.B	(a2,d1.w),d1
	cmp.b	#'0',d1
	BNE.S	.sum2
	MOVE.B	#' ',d1
.sum2	MOVE.B	d1,(a0)				* VOLUME
	MOVE.L 	#screen+640*241+49,where
	MOVE.W	#1,compt2
	MOVEQ	#2,d1
	BSR	PRINT
	RTS

AFF_NAME_SPL
	MOVE.L	a0,a1				* NAME
	MOVE.W	#20,d1
	MOVE.L	#screen+640*345,where
	MOVE.W	#0,compt2
	BSR	PRINT
	RTS

AFF_NB_SPL
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	ADDQ.b	#1,d0
	LEA	hexa,A2
	LEA	nume,A0
	MOVE.W	d0,d1
	and.b	#$f,d0
	MOVE.B	(a2,d0.w),1(a0)
	lsr.b	#4,d1
	MOVE.B	(a2,d1.w),d1
	cmp.b	#'0',d1
	BNE.S	.sum1
	MOVE.B	#' ',d1
.sum1	MOVE.B	d1,(a0)				* NUMERO DU SAMPLE
	MOVE.L #screen+640*224+49,where
	MOVE.W	#1,compt2
	MOVEQ	#2,d1
	BSR	PRINT
	RTS
	
AFF_MONO_SPL
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	BTST.B	#7,MONO_MGT(A0)
	BNE.S	.MMONO
	LEA	STEREO,A0
	BRA.S	.SSTEREO
.MMONO	LEA	MONO,A0
.SSTEREO	MOVE.L #screen+640*328,where
	MOVE.W	#0,compt2
	MOVEQ	#6,D1
	BSR	PRINT
	RTS
STEREO		DC.B 'STEREO'
MONO		DC.B 'MONO  '
nume		dc.b ' 0'
lengt		dc.b '        '
freem		dc.b '        '
	even
***************************************************************************
FRQ_PREPA
	MOVEQ	#0,D0	
	MOVEQ	#0,D1
	MOVE.B	curentnb2,D0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A1
	ADD.L	D0,A1
	CMP.L	#0,LEN_MGT(A1)
	BEQ.S	.nno
	MOVE.B	curvoie,D1
	LEA	PILEVOIE,A0
	MOVE.L	(A0,D1.W*4),A0
	
	MOVEQ	#0,d0
	MOVE.B	recnote,d0
	beq.s	.jjj
	subq.w	#1,d0
	LEA	DIGINOTE1,a4
	MOVE.W	(a4,d0.w*2),(a0)		* note
	bra.s	.kkk
.jjj	MOVE.W	#0,(a0)
.kkk	MOVE.L	DEB_MGT(a1),2(a0)		* adresse debut
	MOVE.L	LOOP_DEB_MGT(a1),6(a0)		* loop debut
	MOVE.L	FIN_MGT(a1),10(a0)		* fin du sample
	MOVE.B	LOOP_MGT(a1),23(a0)		* LOOP 1 = non   3 = oui
	MOVE.B	MONO_MGT(a1),31(a0)		* frq spl (for drum)
	MOVE.B	BIT1_MGT(A1),38(A0)
.nno	RTS
***************************************************************************
DRUM_PREPA
	MOVEQ	#0,D0	
	MOVEQ	#0,D1
	MOVE.B	curentnb2,D0
	MULU	#LEN_SAMPLE_MGT,D0
	LEA	SAMPLE,A1
	ADD.L	D0,A1
	
	CMP.L	#0,LEN_MGT(A1)
	BEQ.S	.nno
	
	MOVE.B	curvoie,D1
	LEA	PILEVOIE,A0
	MOVE.L	(A0,D1.W*4),A0
	
	MOVEQ	#0,D0
	MOVE.B	NOTE_MGT(A1),D0
	BEQ.S	.LLL
	
	SUBQ.W	#1,D0
	LEA	DIGINOTE1,A4
	MOVE.W	(A4,D0.W*2),(A0)		* note
	BRA.S	.MMM
	
.LLL	MOVE.W	#0,(A0)

.MMM	MOVE.L	DEB_MGT(A1),2(A0)		* adresse debut
	MOVE.L	LOOP_DEB_MGT(A1),6(A0)		* loop debut
	MOVE.L	FIN_MGT(A1),10(A0)		* fin du sample
	MOVE.B	LOOP_MGT(A1),23(A0)		* LOOP 1 = non   3 = oui
	MOVE.B	MONO_MGT(A1),31(A0)		* frq spl (for drum)
	MOVE.B	BIT1_MGT(A1),38(A0)
.nno	RTS
***************************************************************************
SAV		DC.L	MUSDEB+504
CONTEUR		DC.W	0
CONTEUR2	DC.W	1
BOUCLE		DC.W	0
BOUCLE1		DC.W	0
DAC_SYNC
	*CMP.B	#1,digvoices
	*BNE.S	.OOK
	*CMP.B	#0,DRUM
	*BNE.S	.OOK
	*RTS
.OOK	MOVEM.L	A0-A1/D0,-(A7)
	MOVE.L	DEB_BUF+4,A0
	MOVE.W	OFFSET_VAL,D0
	LEA	(A0,D0.W*4),A1
	PEA	(A1)
	PEA	(A0)
	CLR.W	D0
	MOVE.B	3(A7),D0
	MOVE.W	D0,$FFFF8906
	MOVE.B	2(A7),D0
	MOVE.W	D0,$FFFF8904
	MOVE.B	1(A7),D0
	MOVE.W	D0,$FFFF8902
	MOVE.B	7(A7),D0
	MOVE.W	D0,$FFFF8912
	MOVE.B	6(A7),D0
	MOVE.W	D0,$FFFF8910
	MOVE.B	5(A7),D0
	MOVE.W	D0,$FFFF890E
	ADDQ.W	#8,A7
	BCLR	#7,$FFFF8901.W
	MOVE.B	CLK,$FFFF8935.W
	MOVEM.L DEB_BUF,A0-A1
	EXG.L	A1,A0
	MOVEM.L A0-A1,DEB_BUF
	MOVEM.L	(A7)+,A0-A1/D0
	RTS
*************************************************************************
CHOIX_REPLAY	MOVEQ	#0,D0
		MOVE.B	38(A6),D0
		CMP.B	#16,D0
		BEQ.S	R_16_BITS
		CMP.B	#8,D0
		BEQ.S	R_8_BITS
		LEA	NO_EFFECT,A1
		RTS
	
R_8_BITS	MOVE.B	31(A6),D0
		BTST	#7,D0
		BEQ.S	STEREO_8
		CMP.W	#1,D1
		BEQ.S	MONO_8_ADD
		LEA	FRQ_8_TO_16_MONO,A1
		RTS
MONO_8_ADD	LEA	FRQ_8_TO_16_MONO_ADD,A1
		RTS
		
STEREO_8	CMP.W	#1,D1
		BEQ.S	STEREO_8_ADD		
		LEA	FRQ_8_TO_16_STEREO,A1
		RTS
STEREO_8_ADD	LEA	FRQ_8_TO_16_STEREO_ADD,A1
		RTS
		
R_16_BITS	MOVE.B	31(A6),D0
		BTST	#7,D0
		BEQ.S	STEREO_16
		CMP.W	#1,D1
		BEQ.S	MONO_16_ADD
		LEA	FRQ_16_TO_16_MONO,A1
		RTS
MONO_16_ADD	LEA	FRQ_16_TO_16_MONO_ADD,A1
		RTS

STEREO_16	CMP.W	#1,D1
		BEQ.S	STEREO_16_ADD
		LEA	FRQ_16_TO_16_STEREO,A1
		RTS
STEREO_16_ADD	LEA	FRQ_16_TO_16_STEREO_ADD,A1
		RTS		
	
*************************************************************************
JOUEDIGIT
	MOVEM.L	D0-A6,-(SP)
	TST.W	DISPO
	BEQ	DISPO1
	
	LEA	VOICE0,A6
	MOVEQ	#0,D1			* 0 = normal rout  1 = ADD rout
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1			* 0 = channel 0    2 = channel 1
	BSR	CHOIX
	
	LEA	VOICE2,A6
	MOVEQ	#0,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE1,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE3,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE4,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE6,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE5,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE7,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE8,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE10,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE9,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE11,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE12,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE14,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE13,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE15,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE16,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE17,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX

	LEA	VOICE19,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE18,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE20,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE21,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE23,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE22,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE24,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE25,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE27,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE26,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE28,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE29,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE31,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX

	LEA	VOICE30,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	BRA	FINDI
*--------------------------------------------------------------------------	
DISPO1	LEA	VOICE0,A6
	MOVEQ	#0,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE1,A6
	MOVEQ	#0,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE2,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE3,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE4,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE5,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE6,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE7,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE8,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE9,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE10,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE11,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE12,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE13,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE14,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE15,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE16,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE17,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX

	LEA	VOICE18,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE19,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE20,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE21,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE22,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE23,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE24,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE25,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR	CHOIX
	
	LEA	VOICE26,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR	CHOIX
	
	LEA	VOICE27,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR.S	CHOIX
	
	LEA	VOICE28,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR.S	CHOIX
	
	LEA	VOICE29,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR.S	CHOIX
	
	LEA	VOICE30,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#0,D1
	BSR.S	CHOIX
	
	LEA	VOICE31,A6
	MOVEQ	#1,D1
	BSR	CHOIX_REPLAY
	MOVEQ	#2,D1
	BSR.S	CHOIX
FINDI	
	MOVEM.L	(A7)+,D0-A6
FINVBL	RTS
***************************************************************************
VOLUME_GENERAL	DS.B	1
		EVEN
***************************************************************************

CHOIX	*CMP.W	#0,COLOR
	*BEQ.S	.O1
	*SUBQ.W	#1,$FFFF8240.W
.O1	LEA	TABLE_CHOIX,A0
	MOVE.W	24(A6),D0
	MOVE.L	(A0,D0.W*4),A0
	JMP	(A0)
	
CHOIXFRQ
	MOVE.L	2(A6),A0		* ADRESSE DEBUT
	TST.L	2(A6)
	BNE.S	PASZERO
NULL_V	LEA	RIEN,A0
PASZERO	MOVE.L	DEB_BUF,A5
	ADD.W	D1,A5
	MOVEM.L	RIEN,D0/D2-D4/D7
	LEA	FRQ,A4
	MOVE.W	(A6),D7			* NOTE
	MOVE.W	(A4,D7.W*4),D2
	MOVE.W	2(A4,D7.W*4),D0
	
	MOVE.B	37(A6),D4		* VOLUME
	SUB.B	VOLUME_GENERAL,D4
	BMI.S	.V_NUL1
	LSL	#8,D4			* MULU	#$200,D4
	LSL	#1,D4
	BRA.S	.V_NUL
	
.V_NUL1	MOVE.B	#0,D4

.V_NUL	LEA	VOLUME,A4
	ADD.L	D4,A4
	
ROUTINE	JSR	(A1)

.TERR	TST.L	2(A6)
	BEQ.S	.RRETT
	ADD.W	D3,A0
	MOVE.L	A0,2(A6)
	MOVE.L	A0,D0
	MOVE.L	10(A6),D1
	CMP.L	D0,D1
	BGE.S	.PARES
	BRA.S	.CALCRESTE
.RRETT	
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

V_RTS	RTS

TABLE_CHOIX	DC.L	FINVBL,NULL_V,FINVBL,FINVBL,CHOIXFRQ,CHOIXFRQ

*************************************************************************
*	DATA MOUSE

X1	dc.w	3
X2	dc.w	3
Y1	dc.w	74
Y2	dc.l	74
km	dc.b	0
	even
***************************************************************************
RESTITU
	LEA	FOND,A0
	MOVE.L	(A0)+,A1		* ADDR
	MOVEQ	#14,D0
.REST	
	MOVE.W	(A0)+,14(A1)
	
	MOVE.W	(A0)+,30(A1)
	ADD.W	#640,A1
	DBF	D0,.REST
	RTS
***************************************************************************
FOND2
	MOVEQ	#0,D1
	LEA	FOND,A0
	MOVE.W	X1,D0
	MOVE.W	D0,X2
	MOVE.W	Y1,D1
	AND.L	#$3F0,D0
	MULU.L	#640,D1
	MOVE.L	D1,Y2
	MOVE.L	#screen,A1
	ADD.L	D0,A1
	ADD.L	D1,A1
	MOVE.L	A1,(A0)+
	MOVEQ	#14,D0
.SAUVE	
	MOVE.W	14(A1),(A0)+
	
	MOVE.W	30(A1),(A0)+
	ADD.W	#640,A1
	DBF	D0,.SAUVE
	RTS
***************************************************************************
AFFMOUSE
	MOVE.L	Y2,D0
	MOVE.W	X2,D1
	MOVE.W	D1,D7
	AND.L	#$3F0,D1
	ADD.L	D1,D0
	AND.L	#15,D7
	LEA	mousemask,A3
	MOVE.L	#screen,A1
	ADD.L	D0,A1
	MOVEQ	#14,D6
AFF1	MOVEQ	#0,D4
	MOVE.L	(A3)+,D4
	ROR.L	D7,D4
	AND.W	D4,14(A1)
	NOT.W	D4
	OR.W	D4,14(A1)
	SWAP	D4
	AND.W	D4,30(A1)
	NOT.W	D4
	OR.W	D4,30(A1)
	ADD.W	#640,A1
	DBRA	D6,AFF1
	RTS
******************************************************************************
TESTBORDS
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	Y1,D0
	MOVE.W	SCREENY,D1
	CMP.W	D1,D0
	BGT.S	.SCRIN1
	MOVE.W	D0,SCREENY
	BRA.S	.SCRIN2
.SCRIN1	ADD.W	OFFSET,D1
	CMP.W	D1,D0
	BLT.S	.SCRIN2
	SUB.W	OFFSET,D0
	MOVE.W	D0,SCREENY
.SCRIN2	RTS
SCREENY	DC.W	0
OFFSET	DC.W	304-15
**************************************************************************	
MOUSEIT	CMP.B	#$F7,$FFFFFC02.W
	BNE.S	.TSTKEY
	MOVE.L	#.IT2,$118.W
	RTE	
.TSTKEY	MOVE.B	$FFFFFC02.W,KEY
	RTE	
.IT2	MOVE.W	D0,-(A7)
	MOVE.B	$FFFFFC02.W,D0
	CMP.B	#2,D0
	BEQ.S	.BB
	CMP.B	#4,D0
	BEQ.S	.BB
.UU	MOVE.L	#.IT3,$118.W
	MOVE.W	(A7)+,D0
	RTE
.BB	MOVE.B	D0,km
	BRA.S	.UU	
.IT3	MOVE.B	$FFFFFC02.W,X1
	MOVE.L	#.IT4,$118.W
	RTE
.IT4	MOVE.B	$FFFFFC02.W,X1+1
	MOVE.L	#.IT5,$118.W
	RTE
.IT5	MOVE.B	$FFFFFC02.W,Y1
	MOVE.L	#.IT6,$118.W
	RTE
.IT6	MOVE.B	$FFFFFC02.W,Y1+1
	MOVE.L	#MOUSEIT,$118.W
	RTE

KEY	DC.B	0
	EVEN
***************************************************************************
FILESELECT
	MOVE.W	#1,okp
	RTS
FILESEL:
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
	MOVE.L	#(400*20)/4-1,D0
	MOVEQ	#0,D1
.NET	MOVE.L	D1,(A0)+
	DBF	D0,.NET
	
	MOVE.L	#ZERO,CURRENTREP
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
	
	TST.W	D0				* D'AUTRES FICHIERS ?
	BEQ.S	.TINU				* OUI
	
	MOVE.W	#0,NB_PAGE_DEB
	MOVE.W	#0,NB_PAGE_FIN
	MOVE.L	#DIR_FILES,TOP_IN_LIST
	BSR	COUNT_MASKED_FILE
	BSR	SORT
	BSR	AFF_FS
	MOVE.W	#0,okp
	RTS
	
*--------------------------------------------------------------------------
STOCKAGE
	CMP.B	#$10,DTA_BUFFER+21		*TEST ATTRIBUT
	BEQ.S	REPERT

	LEA	maskavr+2,A4			*TEST SI EXTENSION CONNU
	LEA	DTA_BUFFER+30,A1
	MOVEQ	#8,D0
PAS_PT	CMP.B	#'.',(A1)+
	BEQ.S	POINT
	DBF	D0,PAS_PT
	BRA.S	LA				*SI PAS EXTENSION ON DEGAGE

POINT	MOVE.B	(A1),D0
	MOVE.B	(A4),D2
	CMP.B	D0,D2
	BNE.S	SUIVANT
	MOVE.B	1(A1),D0
	MOVE.B	1(A4),D2
	CMP.B	D0,D2
	BNE.S	SUIVANT
	MOVE.B	2(A1),D0
	MOVE.B	2(A4),D2
	CMP.B	D0,D2
	BNE.S	SUIVANT
	BRA.S	C_UN_BON
	
SUIVANT	ADDQ.W	#6,A4
	CMP.B	#-1,(A4)			* SI FIN DES EXTENSIONS
	BEQ.S	LA				* ON SORT
	BRA.S	POINT
	
C_UN_BON
	MOVE.B	#$20,(A2)+
	MOVE.B	#$20,(A2)+
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
	
.COPY	MOVE.L	-(A4),-(A3)		* DECALE D'1 ENTREE VERS LE BAS
	CMP.L	A5,A3			* POUR INSERER LE FOLDER EN HAUT
	BGT.S	.COPY
	
	LEA	DTA_BUFFER+30,A0
	MOVE.L	ADD_DEB_THIS_REP,A1
	LEA	ADD_REP,A3
	MOVE.B	#'*',(A1)+
	MOVE.B	#'0',(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	#0,(A1)+
	
	BRA	LA


DTA_BUFFER	DS.B	44
DEFAULT		DC.L	0,0,0,0,0
POINTFIL	DC.L	0		*POINTEUR TABLE ADD_FIL
PATH		DC.B	'A:\*.*'
		DS.B	64
AFFICHAGE	DC.B	'C:\asig-klf.MTM'
		DS.B	64+12		*CHEMIN+NOMFICH
MASQUE		DC.B	'*.MOD',0
FILE_LOADED	DC.B    '*.MOD',0
NUMREP		DC.B	0
NBREP		DC.B	0
CURRENTREP	DC.L	0
ADD_DEB_THIS_REP DC.L   0
ZERO		DC.W	0
	EVEN
***************************************************************************
COUNT_MASKED_FILE
	LEA	DIR_FILES+2,A2
	LEA	MASQUE+2,A1
	MOVE.W	#0,D3
	
.XW	MOVE.L	A2,A0
	CMP.B	#0,-1(A0)
	BEQ	.LEAVE
	CMP.B	#'*',-2(A0)
	BEQ	.COUNT

.WX	CMP.B	#'.',(A0)+
	BNE.S	.WX
	
	MOVE.B	(A1),D1
	CMP.B	(A0),D1
	BNE.S	.NEIN
	MOVE.B	1(A1),D1
	CMP.B	1(A0),D1
	BNE.S	.NEIN
	MOVE.B	2(A1),D1
	CMP.B	2(A0),D1
	BNE.S	.NEIN
.COUNT	ADDQ.W	#1,D3
.NEIN	LEA	18(A2),A2
	BRA	.XW
	
.LEAVE	MOVE.W	D3,NNB2
	SUB.W	#19,D3
	BGE.S	.OK
	MOVEQ	#0,D3
.OK	MOVE.W	D3,BOTTOM	
	RTS
***************************************************************************
AFF_FS:
	LEA	FILES,A0
	MOVEQ	#22,D0
.CLEAN3	MOVE.B	#0,(A0)+
	DBF	D0,.CLEAN3
	LEA	FILES_TO_SORT,A1
	MOVE.L	#screen+640*27+144,where
	MOVEQ	#18,D2
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
	BSR	CONVERT_HEXA_DECIASCII
	ADDQ.L	#8,A0
	LEA	FILES,A0
	MOVE.W	#0,compt2
	MOVEQ	#22,D1
	BSR	PRINT
	BTST	#0,D6
	BEQ.S	.PAS_INVERT
	BSR	INVERT3
.PAS_INVERT
	ADD.L	#640*8+464,where
	DBF	D2,.NB1
	RTS
	
*--------------------------------------------------------------------------
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
.SPOU	ADD.L	#640*8+464,where
	LEA	30(A0),A0
	DBF	D2,.PSSOU
	RTS
	
FILES		DS.B	23
DEJA_REP	DC.W	0
*************************************************************************
SORT:
	LEA	MASQUE+1,A0
	LEA	FILES_TO_SORT,A4
	MOVEQ	#(22*19)/4-1,D0
	MOVEQ	#0,D1
.CLEAN2	MOVE.L	D1,(A4)+
	DBF	D0,.CLEAN2
	
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#12,D2
	LEA	FILES_TO_SORT,A4
	MOVE.L	TOP_IN_LIST,A2
	MOVE.W	#-1,NB
	MOVE.W	#0,DEJA_REP
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
	
	CMP.W	#18,NB
	BNE.S	.HERE_NEXT
.ENDTHE	MOVE.W	#0,DEJA_REP
	MOVE.L	A2,BOTTOM_IN_LIST
	RTS

*--------------------------------------------------------------------------
VERIFY	MOVE.L	A2,A3
	CMP.B	#'*',(A3)
	BEQ.S	.C_EST_UN_REP
	
	CMP.B	#0,(A3)
	BEQ	NDTHE
	
	MOVE.W	#1,DEJA_REP
	ADDQ.L	#2,A3
	MOVE.L	A3,A5
	
.REPARTI
	CMP.B	(A3)+,(A0)+		*TEST SI = AU MASQUE
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
	LEA	PILEADD,A5
	LEA	(A5,D3.W*4),A5
	MOVE.L	A2,(A5)
	MOVE.L	A2,A3
	MOVE.L	(A3)+,(A4)+		*C'EST = ALORS ON RECOPIE
	MOVE.L	(A3)+,(A4)+	
	MOVE.L	(A3)+,(A4)+	
	MOVE.L	(A3)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	BRA.S	WIZZ
	
.PAS_BON
	SUBQ.B	#1,D2
	BEQ.S	WIZZ
	LEA	MASQUE+1,A0
	ADDQ.W	#1,A5
	MOVE.L	A5,A3
	BRA.S	.REPARTI
	
.C_EST_UN_REP
	*CMP.W	#1,DEJA_REP
	*BEQ.S	WIZZ
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.L	(A3)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	MOVE.L	#0,(A4)+
	ADDQ.W	#1,NB
	ADDQ.W	#1,NB_PAGE_FIN
	
	MOVEQ	#0,D3
	MOVE.W	NB,D3
	LEA	PILEADD,A5
	LEA	(A5,D3.W*4),A5
	MOVE.L	A2,(A5)
WIZZ	RTS

NDTHE	MOVEQ	#-1,D2
	RTS


	


TOP_IN_LIST	 DC.L	0
BOTTOM_IN_LIST	 DC.L	0

NB		DC.W	0		* # OF FILE IN WINDOW < 19
NNB2		DC.W	0		* # OF MASKED FILE IN LIST < 400
BOTTOM		DC.W	0
FILES_TO_SORT	DS.B	22*19
PILEADD 	DS.L	20
NB_PAGE_DEB	DC.W	0		* # (IN LIST) OF FIRST FILE PRINTED
NB_PAGE_FIN	DC.W	0		* # (IN LIST) OF LAST  FILE PRINTED
QUE_FAIRE	DC.W	0		* + = ON DESCEND DANS LE FILESELECT
					* - = ON MONTE
*************************************************************************
SCROLL_FILESELECT
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+640*137+64+1,where
	MOVE.W	#1,compt2
	BSR	PRINT
	
	CMP.W	#1,IN_MOD
	BEQ	SCROLL_MOD
	
	LEA	MASQUE+1,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D2
	MOVE.W	NNB2,D1
	MOVE.W	QUE_FAIRE,D0
	BGE	ADDITION
	
.SOUSTR	MOVE.W	NB_PAGE_DEB,D2
	*CMP.W	#0,D2			* SI ON EST DEJA TOUT EN HAUT
	BEQ	RIEN_FAIRE		* ON NE FAIT RIEN
	
	ADD.W	D2,D0			* SINON
	BGE.S	NO_PRBM
	MOVE.W	#0,D0
	
NO_PRBM

	LEA	DIR_FILES+2,A2
	MOVE.W	D0,NB_PAGE_DEB
	MOVE.W	D0,D2
	BEQ	.OK
	
.HERE	CMP.B	#'*',-2(A2)
	BEQ.S	.PLUS_1
	
	MOVEQ	#12,D0
	MOVE.L	A2,A3
.EREH	LEA	MASQUE+1,A0
	CMP.B	(A3)+,(A0)+		*TEST SI = AU MASQUE
	BNE.S	.PAS_BON2
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON2
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON2
	CMP.B	(A3)+,(A0)+
	BNE.S	.PAS_BON2
	BRA.S	.PLUS_1

.PAS_BON2
	SUBQ.W	#1,D0
	BNE.S	.EREH
	LEA	18(A2),A2		* SI NON
	BRA	.HERE
	
.PLUS_1	
	LEA	18(A2),A2
	SUBQ.W	#1,D2			* SI OUI
	BNE.S	.HERE	
	
.OK	MOVE.L	A2,TOP_IN_LIST
	SUBQ.L	#2,TOP_IN_LIST
	MOVE.W	NB_PAGE_DEB,NB_PAGE_FIN
	BSR	SORT

RIEN_FAIRE
	RTS
*--------------------------------------------------------------------------
ADDITION:
	MOVE.W	NB_PAGE_DEB,D2
	CMP.W	BOTTOM,D2
	BEQ	RIEN_FAIRE
	
	ADD.W	D2,D0
	CMP.W	BOTTOM,D0
	BLE	NO_PRBM
	
	MOVE.W	BOTTOM,D0
	BRA	NO_PRBM
*--------------------------------------------------------------------------
SCROLL_MOD
	CMP.W	#19,MAX_INS
	BLE.S	.RETOUR_
	MOVEQ	#0,D0
	MOVE.W	QUE_FAIRE,D0
	CMP.W	#0,D0
	BMI.S	.NNEG

	ADD.W	D0,P_MOD	*POSITIF
	MOVE.W	P_MOD,D0
	MOVE.W	MAX_INS,D1
	SUB.W	#20,D1
	CMP.W	D0,D1
	BGT.S	.RETOUR_
	MOVE.W	MAX_INS,P_MOD
	SUB.W	#20,P_MOD
	BRA.S	.RETOUR_

.NNEG	ADD.W	D0,P_MOD
	MOVE.W	P_MOD,D0
	CMP.W	#0,D0
	BGE.S	.RETOUR_
	MOVE.W	#0,P_MOD
.RETOUR_ RTS
*************************************************************************
TEST_FILE:
	LEA	AFFICHAGE,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+640*137+64+1,where
	MOVE.W	#1,compt2
	BSR	PRINT
	CMP.W	#1,IN_MOD
	BEQ	TEST_MOD
	MOVEQ	#0,D0
	MOVE.W	Y1,D0
	SUB.L	#27,D0
	DIVU	#9,D0
	LEA	FILES_TO_SORT,A0
	LEA	PILEADD,A1
	LEA	screen+144,A2
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
	MOVE.L	(A1,D0.L*4),A1
	MOVE.L	A1,ADD_MOD
	MOVE.B	(A1),D3
	BCHG	#0,D3
	MOVE.B	D3,(A1)
	MULU	#9,D2
	ADD.L	#27,D2
	MULU	#640,D2
	ADD.L	D2,A2
	BSR	INVERT3
	RTS

.YA_PRBM	BTST.B	#0,(A0)
	BEQ.S	.WQA
	MOVE.W	#1,EH_NON
	BRA.S	.NICHT_PRBM
	
.WQA	LEA	FILES_TO_SORT,A3
	MOVEQ	#19,D4
	LEA	screen+640*27+144,A2

.WQS	BTST.B	#0,(A3)
	BEQ.S	.WQZ
	BSR	INVERT3
	BCLR.B	#0,(A3)	
.WQZ	LEA	18(A3),A3
	ADD.L	#640*9,A2
	DBF	D4,.WQS

	MOVE.L	ADD_MOD,A3
	BCLR.B	#0,(A3)
	LEA	screen+144,A2
	BRA	.NICHT_PRBM

ADD_MOD	DC.L	0

OH_UN_REP
	ADDQ.B	#1,POINREP
	
	LEA	PATH,A1
	
.NON	TST.B	(A1)+
	BNE.S	.NON
	
	LEA	-4(A1),A1
	MOVE.L	A1,A2
	LEA	2(A0),A0
	
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	MOVE.B	(A0)+,(A1)+
	
.NON2	CMP.B	#0,(A2)+
	BNE.S	.NON2
	
	MOVE.L	#'\*.*',-1(A2)
	MOVE.B	#0,3(A2)
	
	MOVE.W	#1,okp
	RTS
	
TRI:	BSR	COUNT_MASKED_FILE
	BSR	SORT
	BSR	AFF_FS
	MOVE.W	#0,okp
	RTS

TEST_MOD
	MOVEQ	#0,D0
	MOVE.W	Y1,D0
	SUB.L	#27,D0
	DIVU	#9,D0
	LEA	BUFMOD+20,A0
	LEA	screen+144,A2
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
	ADD.L	#27,D2
	MULU	#640,D2
	ADD.L	D2,A2
	BSR.S	INVERT3
	RTS

INVERT3	MOVEQ	#6,D3
.INVERT1
	NOT.B	1(A2)
	NOT.W	16(A2)
	NOT.W	32(A2)
	NOT.W	48(A2)
	NOT.W	64(A2)
	NOT.W	80(A2)
	NOT.W	96(A2)
	NOT.W	112(A2)
	NOT.W	128(A2)
	NOT.W	144(A2)
	NOT.W	160(A2)
	NOT.B	176(A2)
	LEA	640(A2),A2
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
	
	LEA	PATH+3,A0
.NON	TST.B	(A0)+
	BNE.S	.NON
	LEA	-5(A0),A0
	
.NON2	CMP.B	#'\',-(A0)
	BNE.S	.NON2
	MOVE.L	#'\*.*',(A0)+
	MOVE.L	#0,(A0)+
	
	*MOVE.W	#0,EH_NON
	MOVE.W	#1,okp
NO_EXIT	RTS

EXIT_MOD
	MOVE.W	#0,IN_MOD
	SUBQ.W	#1,EH_NON
	*MOVE.W	#1,CHANGREP
	MOVE.W	#8,okp
	RTS
*************************************************************************
ADD1FS	MOVE.W	#1,QUE_FAIRE
	BRA.S	SCROLL
ADD18FS MOVE.W	#18,QUE_FAIRE
	BRA.S	SCROLL
SUB1FS	MOVE.W	#-1,QUE_FAIRE
	BRA.S	SCROLL
SUB18FS MOVE.W	#-18,QUE_FAIRE
SCROLL	MOVE.W	#0,DEJA_REP
	MOVE.W	#7,okp
	RTS
SCROL
	BSR	SCROLL_FILESELECT
	BSR	AFF_FS
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
	MOVE.L	#pile2,-(a7)		*SUPERVISOR
	MOVE.W	#$20,-(a7)
	trap #1
	MOVE.L	d0,pile
	BSR	FRE
	
	LEA	PATH,A0
	MOVEQ	#1,D1
	MOVE.L	#screen+640*137+64+1,where
	MOVE.W	#1,compt2
	BSR	PRINT

	
	MOVE.W	#2,-(a7)
	trap	#14
	ADDQ.l 	#2,a7
	MOVE.L 	d0,ecran
	
	MOVE.W	#-1,-(A7)
	MOVE.W	#88,-(A7)
	TRAP	#14
	ADDQ.W 	#2,A7
	MOVE.W	D0,rezo

	MOVE.L	$42E.W,D0
	SUB.L	#153600,D0
	
	MOVE.W	#$2B,-(A7)	
	MOVE.W	#3,-(a7)
	MOVE.L	D0,-(a7)
	MOVE.L	D0,-(a7)
	MOVE.W	#5,-(a7)
	TRAP 	#14
	ADD.W	#14,a7
	
	DC.W	$A00A
	BCLR	#0,$484.W
	
	LEA	palet,A0
	LEA	$FFFF9800.W,A1
*	MOVE.L	#$0030005A,4*5(A0)
	MOVE.L	#255,D0
.O1	MOVE.L (A0)+,(A1)+
	DBF	D0,.O1
	
	LEA	$FFFF9800+64*4,A1
	MOVE.L	#255-64,D0
.O2	MOVE.L	#$FF000000,(A1)+
	DBF	D0,.O2

	BSR	INITMEG
        
        LEA	VOICE_TAB,A0
        MOVE.L	#$01010101,(A0)
        MOVE.L	#$01010101,4(A0)
        MOVE.L	#$01010101,8(A0)
        MOVE.L	#$01010101,12(A0)
        MOVE.L	#$01010101,16(A0)
        MOVE.L	#$01010101,20(A0)
        MOVE.L	#$01010101,24(A0)
        MOVE.L	#$01010101,28(A0)
	BSR	AFFPATTERN3
        MOVE.L	#$00000000,(A0)
        MOVE.L	#$00000000,4(A0)
        MOVE.L	#$00000000,8(A0)
        MOVE.L	#$00000000,12(A0)
        MOVE.L	#$00000000,16(A0)
        MOVE.L	#$00000000,20(A0)
        MOVE.L	#$00000000,24(A0)
        MOVE.L	#$00000000,28(A0)
	
	BSR.L	VS0
	BSR.L	VS1

	MOVE.L	#screen+640*88+64+8,WHERE_MASK
	BSR.L	INVERT_4
        
	
	LEA	char3,a0
	MOVE.L  #screen+640*312+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT	
	LEA	char3,a0
	MOVE.L  #screen+640*320+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	LEA	char3,a0
	MOVE.L  #screen+640*328+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	LEA	char3,a0
	MOVE.L  #screen+640*336+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	LEA	char3,a0
	MOVE.L  #screen+640*344+448,where
	MOVE.W	#0,compt2
	MOVEQ	#3,d1
	BSR	PRINT
	
	BCHG.B	#0,DRUM
	BSR.L	PIANO_DRUM
	
	BSR	OPTI
	
	MOVE.B	#5,VOICE0+25
	MOVE.B	#8,VOICE0+38
	MOVE.B	#$80,VOICE0+31
	
	MOVE.B	#5,VOICE1+25
	MOVE.B	#8,VOICE1+38
	MOVE.B	#$80,VOICE1+31
	BSR.L	SET_ON
	
	MOVE.L	#MUSDEB,DEB_BUF
	MOVE.L	#MUSDEB+4016,DEB_BUF+4
	MOVE.L	#$49170,DAC_FRQ
	MOVE.B	#1,CHANGE_FRQ
	JSR	FREQUENCE_030
	BSR	DAC_SYNC
	
	MOVE.W	#$80,-(A7)		* LOCK SOUND
	TRAP	#14
	ADDQ.W	#2,A7
	MOVE.W	#6,-(A7)
	MOVE.W	#6,-(A7)
	MOVE.W	#$82,-(A7)		* SOUND COMMAND
	TRAP	#14
	ADDQ.W	#6,A7
	MOVE.W	#1,-(A7)		* 16 BITS STEREO
	MOVE.W	#$84,-(A7)		* SET MODE
	TRAP	#14
	ADDQ.W	#4,A7
	MOVE.W	#0,-(A7)		* 0 PLAY TRACK
	MOVE.W	#0,-(A7)		* 0 RECORD TRACK
	MOVE.W	#$85,-(A7)		* SET TRACKS
	TRAP	#14
	ADDQ.W	#6,A7
	MOVE.W	#0,-(A7)		* # OF TRACK OUTPUT TO INTERNAL SPEAKER
	MOVE.W	#$86,-(A7)		* SETMONTRACK
	TRAP	#14
	ADDQ.W	#4,A7	
	MOVE.W	#1,-(A7)		* 
	MOVE.W	#0,-(A7)		* 
	MOVE.W	#$87,-(A7)		* SET INTERRUPT
	TRAP	#14
	ADDQ.W	#6,A7	
	MOVE.W	#3,-(A7)		* PLAY ENABLE , PLAY REPEAT
	MOVE.W	#$88,-(A7)		* BUFFOPER
	TRAP	#14
	ADDQ.W	#4,A7
	
	MOVEQ	#0,D0
	MOVE.B	CLK,D0
	MOVE.W	#1,-(A7)		* PROTOCOL = DISABLE HANDSHAKING 
	MOVE.W	D0,-(A7)		* PRESCALE = 49.1 KHZ
	MOVE.W	#0,-(A7)		* SRCLK    = INTERNAL 25.175 MHZ CLOCK
	MOVE.W	#8,-(A7)		* DEST     = DAC (HEADPHONE)
	MOVE.W	#0,-(A7)		* SRC      = DMA PLAY
	MOVE.W	#$8B,-(A7)		* DEVCONNECT
	TRAP	#14
	ADD.W	#12,A7
	

	MOVE.W	SR,-(A7)
	MOVE.W	#$2700,SR
	JSR	STORE
	BCLR	#3,$FFFFFA17.W
	BSET	#5,$FFFFFA07.W
	BSET	#5,$FFFFFA13.W
	MOVE.B	#0,$FFFFFA19.W
	MOVE.B	#1,$FFFFFA1F.W
	MOVE.B	#8,$FFFFFA19.W
	MOVE.L	#MY_70,$70.W
	MOVE.L	#MY_134,$134.W
	MOVE.L	#MOUSEIT,$118.W
	JSR	OVERSCAN
	MOVE.W	(A7)+,SR
	
	BSR	FOND2
	MOVE.W	#1,okp
	BSR	FILESEL
	JMP	niet
OVERSCAN
	MOVE.W	rezo,D0
	BTST	#4,D0
	BNE.S	VGA
	BTST	#5,D0
	BEQ.S	NTSC
	MOVE.W	#$F+14,$FFFF82A6.W
	MOVE.W	#$F+15,$FFFF82A8.W
	MOVE.W	#$271-18,$FFFF82A4.W
	MOVE.W	#$271-18,$FFFF82AA.W
	MOVE.W	#$26B,$FFFF82AC.W
	MOVE.W	#290-15,OFFSET				* 308
	RTS
VGA	MOVE.W	#$23,$FFFF82A6.W
	MOVE.W	#$23,$FFFF82A8.W
	MOVE.W	#$403,$FFFF82A4.W
	MOVE.W	#$403,$FFFF82AA.W
	MOVE.W	#$415,$FFFF82AC.W
	MOVE.W	#248-15,OFFSET
	RTS
NTSC	MOVE.W	#$3,$FFFF82A6.W
	MOVE.W	#$1,$FFFF82A8.W
	MOVE.W	#$1F1,$FFFF82A4.W
	MOVE.W	#$1FE,$FFFF82AA.W
	MOVE.W	#$1F2,$FFFF82AC.W
	MOVE.W	#248-15,OFFSET
	RTS
***************************************************************************
STORE	LEA	SAVE_REGISTER,A0
	MOVE.L	$70.W,(A0)+
	MOVE.L	$118.W,(A0)+
	MOVE.L	$134.W,(A0)+
	MOVE.L	$FFFFFA06.W,(A0)+
	MOVE.L	$FFFFFA12.W,(A0)+
	MOVE.L	$FFFFFA16.W,(A0)+
	MOVE.B	$FFFFFA1F.W,(A0)+
	MOVE.B	$FFFFFA25.W,(A0)+
	RTS
RESTORE LEA	SAVE_REGISTER,A0
	MOVE.W	#$2700,SR
	MOVE.L	(A0)+,$70.W
	MOVE.L	(A0)+,$118.W
	MOVE.L	(A0)+,$134.W
	MOVE.L	(A0)+,$FFFFFA06.W
	MOVE.L	(A0)+,$FFFFFA12.W
	MOVE.L	(A0)+,$FFFFFA16.W
	MOVE.B	(A0)+,$FFFFFA1F.W
	MOVE.B	(A0)+,$FFFFFA25.W
	MOVE.W	#$2300,SR
	RTS
***************************************************************************
SAVE_REGISTER	DCB.L	7
ADDFONT	DC.L	0
AD	DC.B	3
	EVEN
***************************************************************************
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
	dc.l	-1
***************************************************************************
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

***************************************************************************
*	Table of (scancode) to (hexa -> Commande & Donnees)
DATA
	dc.b	$70,0,$6d,1,$6e,2,$6f,3,$6a,4,$6b,5
	dc.b	$6c,6,$67,7,$68,8,$69,9,$10,$A,$30,$B
	dc.b	$2E,$C,$20,$D,$12,$E,$21,$F
	dc.l	-1


***************************************************************************
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

***************************************************************************
*	Table of (number of note) to (note)
DIGINOTE1
Tuning_0 ; Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453 * $358
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113 * $71
	
	dc.w	107,101,095,090,085,080,075,071,067,063,060,056
	dc.w	053,050,047,045,042,040				* $28
Tuning_1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
	dc.w	107,101,095,090,085,080,075,071,067,063,060,056
	dc.w	053,050,047,045,042,040
Tuning_2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
	dc.w	106,100,094,089,084,079,075,071,067,063,059,056
	dc.w	053,050,047,044,042,040
Tuning_3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
	dc.w	105,099,094,088,083,078,074,070,066,063,059,055
	dc.w	053,050,047,045,042,040
Tuning_4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
	dc.w	104,098,092,087,082,078,073,069,065,063,058,055
	dc.w	052,049,046,043,041,039
Tuning_5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
	dc.w	103,097,092,087,082,077,073,069,065,061,058,054
	dc.w	051,048,046,043,041,039
Tuning_6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
	dc.w	102,096,091,086,081,077,072,068,064,061,057,054
	dc.w	051,048,046,043,040,038
Tuning_7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
	dc.w	102,096,090,085,080,076,072,068,064,060,057,054
	dc.w	051,048,045,042,040,038
	
Tuning__8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
	dc.w	113,107,101,095,090,085,080,075,071,067,063,060
	dc.w	056,053,050,047,045,042
Tuning__7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
	dc.w	112,106,100,094,089,084,079,075,071,067,063,059
	dc.w	056,053,050,047,044,042
Tuning__6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
	dc.w	111,105,099,094,088,083,079,074,070,066,062,059
	dc.w	056,053,050,047,044,042
Tuning__5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
	dc.w	111,104,099,093,088,083,078,074,070,066,062,059
	dc.w	056,052,049,047,044,042
Tuning__4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
	dc.w	110,104,098,092,087,082,078,073,069,065,061,058
	dc.w	055,052,049,046,043,041
Tuning__3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
	dc.w	109,103,097,092,087,082,077,073,069,065,061,058
	dc.w	055,051,049,046,043,041
Tuning__2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
	dc.w	108,102,096,091,086,081,077,072,068,064,061,057
	dc.w	054,051,048,046,043,041
Tuning__1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
	dc.w	108,101,099,090,085,080,076,072,068,064,060,057
	dc.w	054,051,048,045,043,040
	
TABLE_DIGINOTE	
	DC.L	Tuning_0,Tuning_1,Tuning_2,Tuning_3,Tuning_4
	DC.L	Tuning_5,Tuning_6,Tuning_7,Tuning__8,Tuning__7
	DC.L	Tuning__6,Tuning__5,Tuning__4,Tuning__3,Tuning__2
	DC.L	Tuning__1
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

palet	INCBIN	C:\DESSIN\MGT.PAL
	even
screen	INCBIN	C:\DESSIN\MGT_2.IMG
	
	
VOLUME		INCBIN	DATA\16_BIT
FRQ		DS.L	1024
*--------------------------------------------------------------------------
FRQ_8_TO_16_MONO
		MOVE.L	VAL,D6
		MOVEQ	#0,D3
		MOVEQ	#0,D5
		SWAP	D2
		MOVE.W	D0,D2
		SWAP	D2
BB2		
M		SET	0
		REPT	8
		 *SUB.W	 D0,D1
		 ADDX.L	 D2,D3
		 MOVE.B	 (A0,D3.W),D5
		 MOVE.W	 (A4,D5.W*2),M(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB2
		
		SWAP	D6
	
BBB2		*SUB.W	D0,D1
		ADDX.L	D2,D3
		MOVE.B	(A0,D3.W),D5
		MOVE.W	(A4,D5.W*2),(A5)
		ADDQ.W	#4,A5
		DBF	D6,BBB2
		
		RTS
*--------------------------------------------------------------------------
FRQ_8_TO_16_MONO_ADD
		MOVE.L	VAL,D6
		MOVEQ	#0,D5
BB3
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.B	 (A0,D3.W),D5
		 MOVE.W	 (A4,D5.W*2),D4
		 ADD.W	 D4,M(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB3
		
		SWAP	D6
	
BBB3		SUB.W	D0,D1
		ADDX.W	D2,D3
		MOVE.B	(A0,D3.W),D5
		MOVE.W	(A4,D5.W*2),D4
		ADD.W	D4,(A5)
		ADDQ.W	#4,A5
		DBF	D6,BBB3
		
		RTS
*--------------------------------------------------------------------------
FRQ_16_TO_16_MONO
		MOVE.L	VAL,D6
		MOVEQ	#0,D5
BB4		
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.W	 (A0,D3.W*2),M(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB4
		
		SWAP	D6
	
BBB4		SUB.W	D0,D1
		ADDX.W	D2,D3
		MOVE.W	(A0,D3.W*2),(A5)
		ADDQ.W	#4,A5
		DBF	D6,BBB4
		
		ADD.W	D3,D3
		RTS
*--------------------------------------------------------------------------
FRQ_16_TO_16_MONO_ADD
		MOVE.L	VAL,D6
		MOVEQ	#0,D5
BB5
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.W	 (A0,D3.W*2),D5
		 ADD.W	 D5,M(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB5
		
		SWAP	D6
	
BBB5		SUB.W	D0,D1
		ADDX.W	D2,D3
		MOVE.W	(A0,D3.W*2),D5
		ADD.W	D5,(A5)
		ADDQ.W	#4,A5
		DBF	D6,BBB5
		
		ADD.W	D3,D3
		RTS
*--------------------------------------------------------------------------		
FRQ_8_TO_16_STEREO
		MOVE.L	#(1004/8)-1,D6
		MOVEQ	#0,D5
BB7		
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.B	 (A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),M(A5)
		 MOVE.B	 1(A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),M+2(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB7
	
M		SET	0
		REPT	4
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.B	 (A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),M(A5)
		 MOVE.B	 1(A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),M+2(A5)
M		SET	M+4
		ENDR
		ADD.W	D3,D3
		RTS
*--------------------------------------------------------------------------
FRQ_8_TO_16_STEREO_ADD
		MOVE.L	#(1004/8)-1,D6
		MOVEQ	#0,D5
BB8		
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.B	 (A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),D4
		 ADD.W	 D4,M(A5)
		 MOVE.B	 1(A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),D4
		 ADD.W	 D4,M+2(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB8
	
M		SET	0
		REPT	4
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.B	 (A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),D4
		 ADD.W	 D4,M(A5)
		 MOVE.B	 1(A0,D3.W*2),D5
		 MOVE.W	 (A4,D5.W*2),D4
		 ADD.W	 D4,M+2(A5)
M		SET	M+4
		ENDR
		ADD.W	D3,D3
		RTS
*--------------------------------------------------------------------------
FRQ_16_TO_16_STEREO
		MOVE.W	#$700,$FFFF8240.W
		MOVE.L	#(1004/8)-1,D6
		MOVEQ	#0,D5
BB6		
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.W	 (A0,D3.W*4),M(A5)
		 MOVE.W	 2(A0,D3.W*4),M+2(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB6
	
M		SET	0
		REPT	4
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.W	 (A0,D3.W*4),M(A5)
		 MOVE.W	 2(A0,D3.W*4),M+2(A5)
M		SET	M+4
		ENDR
		ADD.W	D3,D3
		ADD.W	D3,D3
		RTS
*--------------------------------------------------------------------------
FRQ_16_TO_16_STEREO_ADD
		MOVE.L	VAL,D6
		MOVEQ	#0,D5
BB9
M		SET	0
		REPT	8
		 SUB.W	 D0,D1
		 ADDX.W	 D2,D3
		 MOVE.W	 (A0,D3.W*4),D4
		 ADD.W	 D4,M(A5)
		 MOVE.W	 2(A0,D3.W*4),D4
		 ADD.W	 D4,M+2(A5)
M		SET	M+4
		ENDR
		LEA	32(A5),A5
		DBF	D6,BB9
		
		SWAP	D6	
	
BBB9		SUB.W	D0,D1
		ADDX.W	D2,D3
		MOVE.W	(A0,D3.W*4),D4
		ADD.W	D4,(A5)
		MOVE.W	2(A0,D3.W*4),D4
		ADD.W	D4,2(A5)
		ADDQ.W	#4,A5
		DBF	D6,BBB9	 
		 
		ADD.W	D3,D3
		ADD.W	D3,D3
		RTS

VAL	DC.L	$0004007C
*--------------------------------------------------------------------------		
mousemask	incbin	data\mouse.msk
*mousedat	incbin	data\copyb11.img
FOND		DCB.L	62


FLECHEGAUCHE
*    pixels/scanline    = $0008 (bytes/scanline: $0008)
*  # scanlines (height) = $0007
		DC.B	$EF,$10,$10,$10,$CF,$38,$30,$30
		DC.B	$83,$7C,$7C,$7C,$FF,$02,$FC,$FC
		DC.B	$FF,$02,$7C,$7C,$CF,$0E,$30,$30
		DC.B	$EF,$08,$10,$10
FLECHEDROITE
		DC.B	$EF,$10,$10,$10,$E7,$18,$18,$18
		DC.B	$83,$7C,$7C,$7C,$FF,$00,$7E,$7E
		DC.B	$FF,$03,$7C,$7C,$E7,$06,$18,$18
		DC.B	$EF,$0C,$10,$10
FLECHEFOND
*    pixels/scanline    = $0009 (bytes/scanline: $0008)
*  # scanlines (height) = $0007
		DC.B	$FF,$00,$00,$00,$FF,$00,$00,$00
		DC.B	$FF,$00,$00,$00,$FF,$00,$00,$00
		DC.B	$FF,$00,$00,$00,$FF,$00,$00,$00
		DC.B	$FF,$00,$00,$00

CUR		EQU screen+640*394+17+6
VOICE		EQU screen+640*369+17+6
VOICEU		EQU screen+640*369+17+6-1
VOICED		EQU screen+640*432+17+6-1

PILEVOIE	DC.L	VOICE0,VOICE1,VOICE2,VOICE3,VOICE4,VOICE5
		DC.L	VOICE6,VOICE7,VOICE8,VOICE9,VOICE10,VOICE11
		DC.L	VOICE12,VOICE13,VOICE14,VOICE15,VOICE16,VOICE17
		DC.L	VOICE18,VOICE19,VOICE20,VOICE21,VOICE22,VOICE23
		DC.L	VOICE24,VOICE25,VOICE26,VOICE27,VOICE28,VOICE29
		DC.L	VOICE30,VOICE31
		
ecran	dc.l	0
rezo	dc.w	0		

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
ssv11		dc.b	0
ssv12		dc.b	0
ssv13		dc.b	0
ssv14		dc.b	0
ssv15		dc.b	0
ssv16		dc.b	0
ssv17		dc.b	0
sdigvoices	dc.b	1		* nb de voies digital
syamvoices	dc.b	0		* nb de voies yamaha
snbzic		dc.b	1		* nb de zics
smaxpatt	dc.b	0		* nb de patt
scvoies		dc.b	18*5		* nb d'octets par ligne
stotalsample	dc.b	0		* nb de sample en memoire
stotalyam	dc.b	0		* nb de son yamaha en memoire
slenzic		dc.w	0		* Longueur data zic
slenseq		dc.w	0		* Longueur des sequences
sonepatt	dc.w	18*5*64		* Longueur d'une patt
slentablespl	dc.w	0		* Longueur de la table des instruments
slentableyam	dc.w	0		* Longueur de la table des sons yam
sADDzic		dc.l	0		* ADD debut data zic (relatif)
sADDSEQ		dc.l	0		* ADD debut seq
slenpatt	dc.l	0		* Longueur des patt
sADDPATT	dc.l	0		* ADD debut patt
sADDtablespl	dc.l	0		* ADD table sample
sADDtableyam	dc.l	0		* ADD table des sons yam
slensamples	dc.l	0		* Longueur des samples
slenyams	dc.l	0		* Longueur des son yam
sADDSPL		dc.l	0		* ADD debut spl+yam
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
	DS.B	LEN_SAMPLE_MGT*256
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

BLK_TAB		DS.B	32
VOICE_TAB	DS.B	32
VOICE_TAB1	DS.B	32
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
VOICE11		DS.B	66
VOICE12		DS.B	66
VOICE13		DS.B	66
VOICE14		DS.B	66
VOICE15		DS.B	66
VOICE16		DS.B	66
VOICE17		DS.B	66
VOICE18		DS.B	66
VOICE19		DS.B	66
VOICE20		DS.B	66
VOICE21		DS.B	66
VOICE22		DS.B	66
VOICE23		DS.B	66
VOICE24		DS.B	66
VOICE25		DS.B	66
VOICE26		DS.B	66
VOICE27		DS.B	66
VOICE28		DS.B	66
VOICE29		DS.B	66
VOICE30		DS.B	66
VOICE31		DS.B	66
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

ADD_FIL		DS.L	400
ADD_REP		DS.L	50
DIR_FILES	DS.B	18*400
DIR_REP		DS.B	64*50

DEB_BUF		DS.L	1
		DS.L	1
MUSDEB
	DS.B	2008*2*2
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
	
*	(1 pattern = 5 octets * 64 lignes * nb voies ) * nb patterns
PATTERNS
	ds.b	5*64*32*3
*	Sample
s1	

 

