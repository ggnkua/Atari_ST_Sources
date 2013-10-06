
FINSAMPLE	EQU	512

	MOVE.L 	4(SP),A5
	MOVE.L 	$C(A5),A4
	ADD.L 	$14(A5),A4
	ADD.L 	$1C(A5),A4
	LEA 	$100(A4),A4			; proggy size+basepage
	PEA 	(A4)
	PEA 	(A5)
	CLR 	-(SP)
	MOVE 	#$4A,-(SP)
	TRAP 	#1				; reserve some memory
	LEA 	12(SP),SP
	BSR 	appl_ini			; appli init
LOOP	BSR 	fileselect
	CLR.L 	-(SP)
	MOVE 	#$20,-(SP)
	TRAP 	#1				; supervisor mode
	TST 	int_out+2
	BEQ 	exit 			; <cancel> exits.
	BSR 	Concate_path	
	BSR	l_mod
	BSR	ANALYSE
	CLR.L 	-(SP)
	MOVE 	#$20,-(SP)
	TRAP 	#1
	BRA	LOOP

exit	MOVE.L	#0,-(A7)
	MOVE 	#$20,-(SP)
	TRAP 	#1
	MOVE.L	#0,-(A7)
	TRAP	#1
	
*************************************************************************
ANALYSE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.W	#0,YES_VOLUME
	LEA	PATTERNS,A0
	MOVE.B	maxpatt,D0
	MULU	#64,D0
	
LOOPI	MOVE.B	2(A0),D1
	CMP.B	#$5,D1
	BEQ	NIET
	CMP.B	#$6,D1
	BEQ	NIET
	CMP.B	#$A,D1
	BEQ	NIET
	CMP.B	#$C,D1
	BEQ	NIET
	CMP.B	#$15,D1
	BEQ	NIET
	CMP.B	#$1A,D1
	BEQ	NIET
	CMP.B	#$1B,D1
	BEQ	NIET
	CMP.B	#$1C,D1
	BEQ	NIET
YU	ADD.W	#4*11,A0
	SUBQ	#1,D0
	BNE	LOOPI
	RTS
	
NIET	MOVE.W	#1,YES_VOLUME
	BRA.S	YU
	
YES_VOLUME	DC.W	0	

*********************************************************************************
l_mod	LEA	path_n_name,A0
	BSR	LOAD
	MOVE.L	endaddr,A0
	CMP.L	#'MCS!',(A0)
	BNE	NOT_MOD_MCS
	
	move.l	long,d0
	MOVE.L	$42E.W,A1
	SUB.L	#$10000,A1
	add.l	d0,a0
.reco14	move.b	-(a0),-(a1)
	subq.l	#1,d0
	bne.s	.reco14
	move.l	a1,a6
	
	lea	entete,a1
	moveQ	#69,d0
.reco5	move.b	(a0)+,(a1)+
	dbf	d0,.reco5
*	lea	NAMEMUS,a1
*	moveQ	#19,d0
*.xs	move.b	(a0)+,(a1)+
*	dbf	d0,.xs

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
*	lea	YAM,a0
*	moveq	#0,d0
*	move.w	slentableyam,d0
*	cmp.w	#0,d0
*	beq.s	yy2
*	move.l	a6,a1
*	add.l	saddtableyam,a1
*.reco10	move.b	(a1)+,(a0)+
*	dbf	d0,.reco10

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
	
	BSR	coppatt

	MOVE.L	addseq,A0
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	MOVE.B	D0,curpatt
	MULU	#11*4*64,D0
	MOVE.L	debpatt,A0
	ADD.L	D0,A0
	MOVE.L	A0,addpatt
	RTS

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
	
************************************************************************
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
	MOVE.L	long,D0
	MOVE.L	$42E.W,A0
	SUB.L	#$10000,A0
	ADD.L	D0,A1
.DEPL	MOVE.B	-(A1),-(A0)
	SUBQ.L	#1,D0
	BNE.S	.DEPL
	MOVE.L	A0,A6
	
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

	RTS
	
TABLE_EFF_OKT		DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,0,0,0,0,0
			DC.B	0,$B,0,0,$F,0
			DC.B	0,0,0,0,0,0
***********************************************************************	
NOT_OKT_MOD				* ALORS C'EST UN MODULE AMIGA
	MOVE.L	endaddr,A1
	MOVE.L	#$43C-1,D0
	LEA	BUFMOD,A0
.DEPL2	MOVE.B	(A1)+,(A0)+
	DBF	D0,.DEPL2
	
	MOVE.L	endaddr,A1
	MOVE.L	long,D0
	MOVE.L	$42E.W,A0
	SUB.L	#$10000,A0
	ADD.L	D0,A1
.DEPL3	MOVE.B	-(A1),-(A0)
	SUBQ.L	#1,D0
	BNE.S	.DEPL3
	MOVE.L	A0,A6
	
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
	MOVE.W	#$81,20(a1)		* Set Default Frequency
	MOVE.L	(A2),(A1)
	MOVE.L	4(A2),4(A1)
	MOVE.L	8(A2),8(A1)
	MOVE.L	12(A2),12(A1)
	MOVE.L	16(A2),16(A1)
	MOVE.B	25(A2),34(A1)		* VOLUME
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
	CMP.L	#0,D1
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
.LI	CMP.L	#0,26(A2)
	BEQ.S	.LT
	
.LI3	MOVE.L	A2,heretoconvert
	BSR	D_2
.LT	ADD.W	#40,A2
	DBF	D5,.LI

	MOVE.B	#4,digvoices
	MOVE.B	#0,yamvoices
	RTS
**********************************************************************
DIVIDE2
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ.S	oout
	MOVE.L	A0,heretoconvert
oout	RTS
DIVIDE_2
	BSR.S	D_2
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
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ	oout
	MOVE.L	A0,heretoconvert
	RTS
DIVIDE_3
	BSR.S	D_3
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
	MOVEQ	#0,D0
	MOVE.B	sampledata,d0
	MULU	#40,D0
	LEA	SAMPLE,A0
	ADD.W	D0,A0
	CMP.L	#0,26(A0)
	BEQ	oout
	MOVE.L	A0,heretoconvert
	RTS
DIVIDE_4
	BSR.S	D_4
	RTS
D_4	MOVE.L	heretoconvert,A1
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
LOAD
	MOVE.W	#2,-(SP)		
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
PASFICHIER	
	RTS

DEC_23R		INCBIN	DATA\DEC_23R.BIN
DEC_AT35	INCBIN	DATA\DEC_AT35.BIN

**************************************************************************
; Routines for VDI and AES access By Martin Griffiths 1990
; Call appl_ini at start of a program and appl_exi before terminating.

; AES call for gemdos fileselector routine.

fileselect	LEA control(PC),A0
		MOVE.W #90,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #2,(A0)+
		MOVE.W #2,(A0)+
		MOVE.L #path,addr_in
		MOVE.L #filename,addr_in+4
		BSR AES
		RTS

dummy:		DC.B '*.*',0
path		DC.B "\*.MOD",0
		DS.B 100
		EVEN
loading		DC.B "Loading : "
filename	DS.B 64
path_n_name	DS.W 64

; VDI subroutine call.

VDI		LEA VDIparblock(PC),A0
		MOVE.L #contrl,(A0)
		MOVE.L A0,D1
		MOVEQ #115,D0
		TRAP #2
		RTS

; AES subroutine call.

AES		LEA AESparblock(PC),A0
		MOVE.L #control,(A0)
		MOVE.L A0,D1
		MOVE.L #200,D0
		TRAP #2
		RTS

; 1st BDOS call is APPL_INI

appl_ini	LEA control(PC),A0
		MOVE #10,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BRA AES

; Last BDOS call is APPL_EXI

appl_exi	LEA control(PC),A0
		MOVE #19,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BRA AES

; VDI & AES Reserved arrays

VDIparblock	DC.L contrl
		DC.L intin
		DC.L ptsin
		DC.L intout
		DC.L ptsout
		
contrl		DS.W 12
intin		DS.W 30
ptsin		DS.W 30
intout		DS.W 45
ptsout		DS.W 12

AESparblock	DC.L control
		DC.L global
		DC.L int_in
		DC.L int_out
		DC.L addr_in
		DC.L addr_out 
control		DS.W 5
global		DS.W 16
int_in		DS.W 16
int_out		DS.W 7
addr_in		DS.L 2
addr_out	DS.L 1

; The Gem Fileselector returns a path and filename as seperate strings
; - this rout concatenates the two strings together into one (for loading).

Concate_path	LEA path(PC),A1
		MOVE.L A1,A0
.find_end	TST.B (A0)+		; search for end of path
		BNE.S .find_end
.foundit	CMP.B #'\',-(A0)	; now look back for slash
		BEQ.S .foundslash	
		CMP.L A1,A0		; (or if we reach start of path)
		BNE.S .foundit
.foundslash	SUB.L A1,A0		; number of bytes
		MOVE.W A0,D0
		LEA path_n_name(PC),A0
		TST.W D0
		BEQ.S .nonetodo		; if zero then not in subdir
.copypath	MOVE.B (A1)+,(A0)+	; copy path
		DBF D0,.copypath	
.nonetodo	LEA filename(PC),A1
.copy_filename	MOVE.B (A1),(A0)+	; concatenate file name
		TST.B (A1)+
		BNE.S .copy_filename
		RTS
**************************************************************************
*	Table of (number of note) to (note)
DIGINOTE1
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453 * $358
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113 * $71
	dc.w	107,101,095,090,085,080,075,071,067,063,060,056
	dc.w	053,050,047,045,042,040				* $28

CANAL_MOD	DC.W	0	* # CANAL DU FICHIER
MAX_INS		DC.W	0		* NB MAX D'INSTRUMENTS
IN_MOD		DC.W	0		* SI = 1 ALORS ON EST DANS UN MODULE
A_MOD		DC.W	0		* POINTEUR DANS MOD (ADD_PARTITION)
P_MOD		DC.W	0		* POINTEUR FILESELECT
W_MOD		DC.W	0		* POINTEUR DANS MOD (ADD_SEQUENCE)
FIRST_SPL	DC.L	0	* ADRESSE PREMIER SPL DANS MOD (RELATIF)
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
heretoconvert	dc.l	0

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
		dc.b	'BNK!'
	SECTION BSS
		DS.B	2		* Nb SAMPLE & YAM
		DS.L	2		* Len DATA SAMPLE & YAM
SAMPLE		DS.L	10*256
YAMAHA		DS.L	10*256
MUSIQUE		ds.w	256
SEQUENCE	ds.b	256*2
BUFMOD		DS.L	$43C
PATTERNS	ds.b	4*64*11*3
s1