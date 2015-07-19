	output DEMO3D.PRG		



VBL_COUNT	equ	$465		;adresse du compteur VBL
CLIPMAXY	equ	199	;199-11
AFFCPU		equ	1
EFFSCR		equ	0
MUSIQUE		equ	1		
AFFTEXTE	equ	1
DEBUG		equ	1
COMPTEIMAGE	equ	1
PCMSAMPLE	equ	1
AKEYBOARD	equ	0

CLIPPING	equ	0



CLIPSIZE	equ	2048




	SECTION TEXT

MFP_BASE	EQU	$FFFFFA00

MFP_GPIP	EQU	$FFFFFA01
MFP_AER		EQU	$FFFFFA03
MFP_DDR		EQU	$FFFFFA05
MFP_IERA	EQU	$FFFFFA07
MFP_IERB	EQU	$FFFFFA09
MFP_IPRA	EQU	$FFFFFA0B
MFP_IPRB	EQU	$FFFFFA0D
MFP_ISRA	EQU	$FFFFFA0F
MFP_ISRB	EQU	$FFFFFA11
MFP_IMRA	EQU	$FFFFFA13
MFP_IMRB	EQU	$FFFFFA15
MFP_VR		EQU	$FFFFFA17
MFP_TACR	EQU	$FFFFFA19
MFP_TBCR	EQU	$FFFFFA1B
MFP_TCDCR	EQU	$FFFFFA1D
MFP_TADR	EQU	$FFFFFA1F
MFP_TBDR	EQU	$FFFFFA21
MFP_TCDR	EQU	$FFFFFA23
MFP_TDDR	EQU	$FFFFFA25





***********************************************************
*		programme principal :			  *
*							  *
*		- basse resolution			  *
*		- sauvegarde de la palette		  *
*		- installation nouvelle VBL		  *
*							  *
***********************************************************

	JMP	start


	IFEQ	MUSIQUE

REPLAY
MUS = 1 

SETMUSIC:
	LEA	LA2E,A0
	moveq	#MUS,d0
	bsr.s	initmus
	rts


voicefin:	dc.w	0
count:		dc.l	0
endvoice:	dc.l	0

	rsreset

off22 = 0	;rs.l	1	;ptr courant dans pattern
off0 = 4	;rs.l	1	;ptr base patterns
off34 = 8	;rs.l	1	;ptr fin musique

off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
offa = 14	;rs.l	1	;ptr base modulation volume
offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12 = 20	;rs.l	1	;ptr base modulation frÇquence
off30 = 24	;rs.w	1	;ptr modulation frÇquence (.W au lieu de .L)

off38 = 26	;rs.l	1	;incrÇment pour crescendo

off8 = 30	;rs.b	1
off9 = 31	;rs.b	1

off16 = 32	;rs.b	1
off17 = 33	;rs.b	1
off18 = 34	;rs.b	1
off19 = 35	;rs.b	1
off1a = 36	;rs.b	1
off1b = 37	;rs.b	1
off1c = 38	;rs.b	1
off1d = 39	;rs.b	1
off1e = 40	;rs.b	1
off1f = 41	;rs.b	1
off21 = 42	;rs.b	1

off26 = 43	;rs.b	1
off27 = 44	;rs.b	1
off28 = 45	;rs.b	1	;15-volume sonore de la voix
off2a = 46	;rs.b	1	;0,1 ou 2=type de son
off2b = 47	;rs.b	1
off2c = 48	;rs.b	1
off2d = 49	;rs.b	1	;volume sonore calculÇ
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2

;
; init musique
;
; entrÇe :
;	A0=pointe sur le texte 'COSO'
;	D0=numÇro de la musique Ö jouer
;

initmus:
	TST	D0		;musique=0 -> cut mus
	BEQ	LCA
	subq	#1,d0

	LEA	PSGREG(PC),A6
	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	4(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L938-PSGREG(A6)
	MOVE.L	8(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L93C-PSGREG(A6)
	MOVE.L	$C(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L91A-PSGREG(A6)
	MOVE.L	$10(A0),A1
	ADD.L	A0,A1
	MOVE.L	A1,L916-PSGREG(A6)
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
	move.l	a1,endvoice
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D1,D0
	ADD	D0,A1
	MOVEQ	#$C,D7
	MULU	(A1)+,D7	;PREMIER PATTERN
	MOVE	(A1)+,D6
	ADDQ	#1,D6
	MULU	#$C,D6		;DERNIER PATTERN
	MOVE	(A1)+,D0
	MOVE.B	D0,L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A0
	LEA	L7C6(PC),A1
L658:	MOVE.L	A1,offa(a0)
	clr	offe(a0)
	CLR.B	off2d(A0)
	CLR.B	off8(a0)
	CLR.B	off9(a0)
	MOVE.L	A1,off12(A0)
	clr	off30(a0)
	MOVE.B	#1,off17(A0)
	MOVE.B	#1,off18(A0)
	CLR.B	off19(A0)
	clr.b	off1a(a0)
	clr.b	off1b(a0)
	clr.b	off1c(a0)
	clr.b	off1d(a0)
	clr.b	off1e(A0)
	clr.b	off1f(a0)
	move.l	d0,d3
	MOVE.B	d3,off21(A0)
	ADD	D3,D3
	ADD	D3,D3
	MOVE.L	L916(PC),d1
	add.l	D7,d1
	add.l	D3,d1
	move.l	d1,off0(A0)
	move.l	d1,a3
	MOVE.L	L916(PC),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,off34(A0)
	move	#$C,off4(a0)
	moveq	#0,d1
	move.b	(A3)+,D1
	ADD	D1,D1
	MOVE.L	L91A(PC),A4
	MOVE	(A4,D1.W),A4
	ADD.L	L934(PC),A4
	MOVE.L	A4,(A0)
	clr.b	off26(A0)
	clr.b	off27(A0)
	MOVE.B	#2,off2a(A0)
	move.b	(A3)+,off2c(A0)
	CLR.B	off2b(A0)
	move.b	(A3)+,off16(A0)
	moveq	#$10,d1
	add.B	(A3),D1
	bcs.s	L712
	moveq	#0,d1
L712:
	MOVE.B	D1,off28(A0)
	CLR.L	off38(A0)
	lea	off3c(a0),A0
	addq	#1,d0
	cmp	#3,d0
	blo	L658
	MOVE.B	#1,L80E-PSGREG(A6)
	CLR	L812-PSGREG(A6)

	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	RTS
LCA:	LEA	L812(PC),A0
	ST	(A0)

PLAYMUSIC:
L12C:
	LEA	PSGREG(PC),A6
	TST.B	L812-PSGREG(A6)
	BEQ.S	L160
	TAS	L813-PSGREG(A6)
	BNE.S	L15E
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
L15E:	RTS
L160:	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR.s	L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:	move.b	#$C0,$1E(A6)
	LEA	voice0(PC),A0
	BSR	L39A
	move	d0,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,$22(A6)
	LEA	voice1(PC),A0
	BSR	L39A
	move	d0,$E(A6)
	MOVE.B	D0,$A(A6)
	MOVE.B	D1,$26(A6)
	LEA	voice2(PC),A0
	BSR	L39A
	move	D0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS

;
; calcule nouvelle note
;

L25C:	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	(A0),A1
L26C:	MOVE.B	(A1)+,D0
	CMP.B	#$FF,D0
	BNE.S	L2E2
	MOVE.L	off0(a0),a1
	add	off4(a0),a1
	cmp.l	off34(a0),a1
	blo.S	L288
	addq	#1,voicefin
	move	d5,off4(a0)
	MOVE.L	off0(a0),a1
L288:	MOVEQ	#0,D1
	move.b	(a1)+,D1
	move.b	(a1)+,off2c(A0)
	move.b	(a1)+,off16(A0)
	moveq	#$10,d0
	add.b	(a1)+,D0
	bcc.s	L2B4
	move.b	d0,off28(A0)		;F0-FF=volume Ö soustraire
	BRA.S	L2C4
L2B4:	add.b	#$10,d0
	bcc.S	L2C4
	move.B	d0,L810-PSGREG(A6)	;E0-EF=vitesse
L2C4:	ADD	D1,D1
	MOVE.L	L91A(PC),A1
	MOVE	(A1,D1.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,(A0)
	add	#$C,off4(a0)
	BRA.s	L26C
L2E2:	CMP.B	#$FE,D0
	BNE.S	L2F4
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA.s	L26C
L2F4:	CMP.B	#$FD,D0
	BNE.S	L308
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,(A0)
	RTS
L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	L31C
	MOVE.B	(A1)+,off1f(A0)
L31C:	MOVE.L	A1,(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI.S	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L93C(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	move	d5,offe(A0)
	MOVE.B	(a1)+,d1
	move.b	d1,off17(A0)
	MOVE.B	d1,off18(A0)
	MOVEQ	#0,D1
	MOVE.B	(a1)+,D1
	MOVE.B	(a1)+,off1b(A0)
;	MOVE.B	#$40,off2e(A0)
	clr.b	off2e(a0)
	MOVE.B	(a1)+,D2
	MOVE.B	D2,off1c(A0)
	MOVE.B	D2,off1d(A0)
	MOVE.B	(a1)+,off1e(A0)
	MOVE.L	a1,offa(A0)
	add.b	d0,d0			;test bit 6
	bpl.s	L37A
	MOVE.B	off1f(A0),D1
L37A:	MOVE.L	L938(PC),a1
	ADD	D1,D1
	MOVE	(a1,D1.W),a1
	ADD.L	L934(PC),a1
	MOVE.L	a1,off12(A0)
	move	d5,off30(A0)
	MOVE.B	D5,off1a(A0)
	MOVE.B	D5,off19(A0)
L398:	RTS

;
; calcul de la note Ö jouer
;

L39A:	MOVEQ	#0,D7
	MOVE	off30(a0),d6
L3A0:	TST.B	off1a(A0)
	BEQ.S	L3AE
	SUBQ.B	#1,off1a(A0)
	BRA	L4C01
L3AE:	MOVE.L	off12(A0),A1
	add	d6,a1
L3B6:	move.b	(a1)+,d0
	cmp.b	#$E1,d0
	BEQ	L4C01
	cmp.b	#$E0,d0
	BNE.S	L3D8
	moveq	#$3f,d6
	and.B	(A1),D6
	MOVE.L	off12(A0),A1
	add	d6,A1
	move.b	(a1)+,d0
L3D8:	cmp.b	#$E2,d0
	BNE.S	L3EE
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6
L3EE:	cmp.b	#$E9,d0
	BNE.s	L422
	MOVE.B	#$B,$FFFF8800.W
	move.b	(A1)+,$FFFF8802.W
	move.l	#$0C0C0000,$FFFF8800.W
	move.l	#$0D0D0A0A,$FFFF8800.W
	addq	#2,d6
	bra.s	L3B6
L422:	cmp.b	#$E7,d0
	BNE.S	L44A
	clr	d0
	move.b	(A1),D0
	ADD	D0,D0
	MOVE.L	L938(PC),A1
	MOVE	(A1,D0.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off12(A0)
	clr	d6
	BRA.s	L3B6
L44A:	cmp.b	#$E8,d0
	BNE.S	L45E
	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0
L45E:	cmp.b	#$E4,d0
	BNE.S	L474
	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA.S	L4AE
L474:	cmp.b	#$E5,d0
	BNE.S	L488
	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
L488:	cmp.b	#$E6,d0
	BNE.S	L49A
	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA.S	L4AE
L49A:	cmp.b	#$E3,d0
	BNE.S	L4B0
	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:	move	d6,off30(a0)
;
; modulation volume
;
	move	offe(a0),d6
L4C0:	TST.B	off19(A0)
	BEQ.S	L4CC
	SUBQ.B	#1,off19(A0)
	BRA.S	L51A
L4CC:	SUBQ.B	#1,off17(A0)
	BNE.S	L51A
	MOVE.B	off18(A0),off17(A0)

	MOVE.L	offa(A0),A1
	add	d6,a1
	move.b	(A1)+,D0
	CMP.B	#$E0,D0
	BNE.S	L512
	moveq	#$3f,d6
	and.b	(A1),D6
	subq	#5,D6
	move.l	offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
L512:
	CMP.B	#$E8,D0
	BNE.S	L4F4
	addq	#2,d6
	move.b	(A1)+,off19(A0)
	BRA.S	L4C0
L4F4:	CMP.B	#$E1,D0
	BEQ.S	L51A
	MOVE.B	d0,off2d(A0)
	addq	#1,d6
L51A:	move	d6,offe(a0)

	clr	d5
	MOVE.B	off2b(A0),D5
	BMI.S	L528
	ADD.B	off8(a0),D5
	ADD.B	off2c(A0),D5
L528:
	LEA	L94E(PC),A1
	add.b	D5,D5
	MOVE	(A1,d5.w),D0

	move.b	off2a(A0),D2	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D3
	ADDQ	#3,D3

	subq.b	#1,D2
	BNE.S	L578
	subq	#3,d3
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578
	add.b	off8(a0),d7
L578:	BSET	D3,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	MOVE.B	off2e(A0),d6
	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d4
	MOVE.B	off1c(A0),D4
	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	d6
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	d6
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	D4,D4
	CMP.B	D4,D1
	BCS.S	L5DA
	bclr	#7,d6
	MOVE.B	D4,D1
L5DA:	lsr.b	#1,d4
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	D4,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d4

	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d4,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
L5FA:	EOR.B	#1,d6
	MOVE.B	d6,off2e(A0)
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	lsr.l	#4,d1		;asr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:	MOVE.B	off2d(A0),D1
	SUB.B	off28(A0),D1
	BPL.S	L634
	MOVEQ	#0,D1
L634:
	RTS

L94E:	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F
L7C6:	DC.B	1,0,0,0,0,0,0,$E1
PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808,0,$909,0
	DC.W	$A0A,0

L80E:	DC.B	4
L810:	DC.B	4
L812:	DC.B	-1
L813:	DC.B	0

voice0:	ds.B	off3c
voice1:	ds.B	off3c
voice2:	ds.B	off3c
L916:	DC.L	0
L91A:	DC.L	0
L934:	DC.L	0
L938:	DC.L	0
L93C:	DC.L	0
LA2E:	INCBIN	"ATOMIX.PAK"


	ENDC

	IFEQ	PCMSAMPLE

;
;	Utilisation du processeur sonore PCM du STE
;

PCM_STARTA	EQU	$FFFF8903
PCM_STARTB	EQU	$FFFF8905
PCM_STARTC	EQU	$FFFF8907

PCM_ENDA	EQU	$FFFF890F
PCM_ENDB	EQU	$FFFF8911
PCM_ENDC	EQU	$FFFF8913


KHZ_6		EQU	0
KHZ_12		EQU	1
KHZ_25		EQU	2
KHZ_50		EQU	3

PCMMONO		EQU	$A0

PCM_FREQUENCY	EQU	$FFFF8920

PCM_MODE	EQU	$FFFF8900

PCM_VOLUME	EQU	$FFFF8922



	

;-------- Initialisation du PCM ----------------------------
;

initPCM:
	lea	sample(PC),A0
	lea	fsample,A1
	jsr	convertPCM(PC)

	move.l	#sample,D0		;init adresse de depart
	swap	D0
	move.b	D0,PCM_STARTA
	swap	D0
	move.b	D0,PCM_STARTC
	lsr	#8,D0
	move.b	D0,PCM_STARTB

	move.l	#fsample,D0		;init adresse de fin
	swap	D0
	move.b	D0,PCM_ENDA
	swap	D0
	move.b	D0,PCM_ENDC
	lsr	#8,D0
	move.b	D0,PCM_ENDB

	move.w	#$A1,PCM_FREQUENCY

	move.w	#$3,PCM_MODE

	rts 	


;------- Convertion au format PCM 8 bits signÇs -----------
;
;	A0 = adresse de depart
;	D0 = longueur de l'Çchantillon

convertPCM:
crm:
	sub.b	#128,(A0)+
	cmp.l	A0,A1
	bne.s	crm
	rts
		
pile:
	DC.L	0

sample:
	incbin	'E:\TOUT.SPL'
fsample:
	EVEN	


	ENDC


start:
	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1				shrink memory
	lea	12(sp),sp

	*--------------- mode superviseur -----------
	clr.l	-(SP)			
	move	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	move.l	D0,userstack

	*-------------- init de la musique ----------
	IFEQ	MUSIQUE
	BSR	SETMUSIC
	ENDC

	IFEQ	PCMSAMPLE
	JSR	initPCM
	ENDC

	IFEQ	AKEYBOARD
	JSR	KBD_ON
	ENDC

	*-------------- sauve resolution ------------
	move	#4,-(SP)		
	trap	#14				
	addq.l	#2,SP
	move	D0,sys_rez

	*-------------- passage basse resolution ----
	clr	-(SP)		
    	move.l	#-1,-(SP)	
    	move.l	#-1,-(SP)
    	move	#5,-(SP)
    	trap	#14
    	lea	12(SP),SP

	*------------- adresse de l'ecran -----------    
	move	#3,-(SP)		
	trap	#14				
	addq.l	#2,SP
	move.l	D0,sys_screen	sauvegarde
	
	*------------- adresses ecran 1,2,3 ---------

	move.l	D0,sys_scr1		=adresse ecran visualisÇ
	move.l	#screen2,D0		adresse de l'ecran2 dans
	add.l	#255,D0			le buffer 2
	clr.b   D0		
	move.l	D0,sys_scr2
	add.l	#32000,D0
	move.l	D0,sys_scr3
	add.l	#32000,D0
	move.l	D0,sys_scr4
	add.l	#32000,D0
	move.l	D0,sys_scr5
	add.l	#32000,D0
	move.l	D0,sys_scr6

	lea	$FFFF8240.W,A0
	lea	sys_palette,A1
	jsr	copy_pal(PC)		sauve la palette courante

	move.l	A0,A1			installe nouvelle palette
	lea	palette2,A0
	jsr	copy_pal(PC)


	IFEQ	DEBUG

        move.w  #$12,-(SP)    ;neutralise souris
        move.w  #4,-(SP)
        move.w  #3,-(SP)
        trap    #13
        addq    #6,SP


;-------------- sauvegarde des registre du MFP -----------


	lea	savemfp(PC),A0
	move	$100+8*4,(A0)+
	move.b	MFP_IMRA,(A0)+
	move.b	MFP_IMRB,(A0)+
	move.b	MFP_IERA,(A0)+
	move.b	MFP_IERB,(A0)+
	move.b	MFP_VR,(A0)

	clr.b	MFP_IERA
	clr.b	MFP_IERB

	clr.b	MFP_TBCR
	move.b	#$40,MFP_VR
	
	lea	it1_timerb(PC),A0
	move.l	A0,$100+8*4
	or.b	#1,MFP_IERA
	or.b	#1,MFP_IMRA

	move.l	$70.W,sys_vbl		sauve adresse IT VBL
	move.l  #new_vbl,$70.W		nouvelle vbl	

	ENDC

	jsr	main(PC)

	IFEQ	DEBUG

	move.l	sys_vbl,$70.W		restauration vbl systäme


	lea	savemfp(PC),A0
	move	(A0)+,$100+8*4
	move.b	(A0)+,MFP_IMRA
	move.b	(A0)+,MFP_IMRB
	move.b	(A0)+,MFP_IERA
	move.b	(A0)+,MFP_IERB
	move.b	(A0),MFP_VR


        move    #$08,-(SP)		;rÇactive souris
        move    #4,-(SP)
        move    #3,-(SP)
        trap    #13
        addq    #6,SP

	ENDC

	IFEQ	AKEYBOARD
	JSR	KBD_OFF
	ENDC



	lea	sys_palette,A0
	lea	$FFFF8240.W,A1
	jsr	copy_pal(PC)		restore la palette courante

	move	sys_rez,-(SP)		resolution d'origine
    	move.l	sys_screen,-(SP)	et ecran d'origine
    	move.l	sys_screen,-(SP)
    	move	#5,-(SP)
    	trap	#14
    	lea	12(SP),SP

	move.l	userstack,-(SP)		mode utilisateur
	move	#$20,-(SP)
	trap	#1
	addq.l	#6,SP
	
bye:
	clr	-(SP)			fin du programme
	move	#$4C,-(SP)	
	trap	#1			


savemfp
	DS.W	4


****************** copie de palette *****************************

copy_pal:
	movem.l	(A0),D0-D7
	movem.l	D0-D7,(A1)
	rts



***********************************************************************
*								      *
*		ROUTINE CLAVIER					      *
*								      *
***********************************************************************

	IFEQ	AKEYBOARD


KBD_CPU		equ	0
KBD_SOFT_IT	equ	1

KBD_VECTOR	equ	$118			;adresse IT midi clavier
KBD_CTRL	equ	$FFFFFC00		;registre controle acia
KBD_DATA	equ	$FFFFFC02		;registre donnÇe acia

;MFP_ISRB        equ	$FFFFFA11		;IT in service register


*--------------- envoie une sequence de commande au clavier ------------
*
*	A0-> adresse de la chaine (format pascal)
*



KBD_SEND:
		MOVEM.L		D1/A1,-(SP)
		MOVE.B		(A0)+,D0

		LEA		KBD_CTRL.W,A1	;adresse ACIA CLAVIER
SENDWAIT:
		MOVE.B		(A1),D1		;attente clavier pret
		BTST		#1,D1		;pret ?
		BEQ.S		SENDWAIT	;non attendre

		MOVE.B		(A0)+,2(A1)	;envoie de l'octet
		SUBQ.B		#1,D0		;un octet de moins
		BGT.S		SENDWAIT	;passe octet suivant ?

		MOVEM.L		(SP)+,D1/A1
		RTS

CMD_MOUSEABS	DC.B		5		;souris mode absolu
		DC.B		$09	
		DC.W		319	
		DC.W		199

CMD_MOUSEREL	DC.B		1,$08		;souris mode relatif


*----------------- routine d'initialisation de IT clavier --------------

KBD_ON:
		MOVEM.L		D0/A0,-(SP)
KBD_ONW
		MOVE.B		KBD_CTRL.W,D0	;attente disponibilite
		BTST		#1,D0
		BEQ.S		KBD_ONW

		CLR		KBD_NBOCTET	;0 octets Ö lire

		MOVE.L		KBD_VECTOR.W,KBD_SAVE
		LEA		KBD_IT(PC),A0
		MOVE.L		A0,KBD_VECTOR.W

		MOVEM.L		(SP)+,D0/A0
		RTS

;----------- restauration de l'ancienne routine ------------------------

KBD_OFF:
		MOVE.W		D0,-(SP)

KBD_OFFR		
		BTST.B		#1,KBD_CTRL.W
		BEQ.S		KBD_OFFR
		MOVE.L		KBD_SAVE(PC),KBD_VECTOR.W

		MOVE.W		(SP)+,D0
		RTS

*---------------- variables routine clavier -----------------------

KBD_SAVE:	DC.L		0		;adresse ancienne routine
KBD_NBOCTET:	DC.W		0		;nombre d'octets

MOUSEK		DC.B		0		;touches souris
MOUSEDX:	DC.B		0		;deplacement en X souris
MOUSEDY:	DC.B		0		;deplacement en Y souris

KEY:		DC.B		0
MOUSEX:		DC.W		0		;position X absolue
MOUSEY:		DC.W		0		;position Y absolue


MOUSE_MAXX	DC.W		1023		;position X maxi
MOUSE_MAXY	DC.W		1023		;position Y maxi


KBDRETOUR	MACRO
		MOVEM.L		(SP)+,D0/A0
		IFEQ		KBD_CPU-1
		CLR.W		$FFFF8240.W
		ENDC
		IFEQ		KBD_SOFT_IT-1
                BCLR            #6,MFP_ISRB.W    ;IT traitÇe
		ENDC
		RTE
		ENDM


KBD_IT:
		MOVEM.L		D0/A0,-(SP)
 
		IFEQ		KBD_CPU-1
		MOVE.W		#$700,$FFFF8240.W
		ENDC

		;controle l'etat du clavier
 
;               TST.B           KBD_CTRL.W	 ;etat du clavier

;               BPL.S           FIN_2            ;si non fin 2


		;lit la donnÇe du clavier

                MOVE.B          KBD_DATA.W,D0      ;D1=donnee du clavier

                TST             KBD_NBOCTET

		BLT.S		LIT_MOUSE	   ;si < 0 lecture souris
                BGT.S           LIT_1OCTET         ;si > 0 lecture octet

		;determination du HEADER

		CMP.B		#$F8,D0
		BLT.S		PASSOURIS
		CMP.B		#$FB,D0
		BGT.S		PASSOURIS

		;souris mode relatif

		MOVE.B		D0,MOUSEK
		MOVE		#-2,KBD_NBOCTET

		KBDRETOUR
PASSOURIS

LIT_1OCTET
                MOVE.B	        D0,KEY           ;ecriture de l'octet
		KBDRETOUR
LIT_MOUSE:
		LEA		MOUSEDY+1(PC),A0
		ADD		KBD_NBOCTET(PC),A0
		MOVE.B		D0,(A0)		;lecture autre octet
		ADDQ		#1,KBD_NBOCTET  ;un octet de plus
		BEQ.S		FINSOURIS	 
		KBDRETOUR
FINSOURIS
		MOVE.B		MOUSEDX(PC),D0	;si 0 alors addition pos abs
		EXT.W		D0
		ADD		MOUSEX(PC),D0
		CMP		MOUSE_MAXX(PC),D0
		BLO.S		PASCLIPX
		SGE		D0
		EXT		D0
		AND		MOUSE_MAXX(PC),D0		
PASCLIPX
		MOVE		D0,MOUSEX

		MOVE.B		MOUSEDY(PC),D0
		EXT.W		D0
		ADD		MOUSEY(PC),D0
		CMP		MOUSE_MAXY(PC),D0
		BLO.S		PASCLIPY
		SGE		D0
		EXT		D0
		AND		MOUSE_MAXY(PC),D0
PASCLIPY
		MOVE		D0,MOUSEY

FIN_2		
		KBDRETOUR

	ENDC


****************** generation du FASTCVLS 4 plans *****************

genfastcls:
	lea	bfastcls,A0
	move.l	#$48E0FF7E,D0
	move	#539,D1
gfcrep:
	move.l	D0,(A0)+		;genere les movem
	dbf	D1,gfcrep
	move.l	#$48E00300,(A0)+	;dernier movem
	move	#$4E75,(A0)		;rts
	rts

*****************************************************************
*	macro de swapping des 2 ecrans 				*
*****************************************************************

SWAPPER MACRO

	IFEQ	AFFCPU
	move.w	#$700,$FFFF8240.W
	ENDC

vbl_wait:
	tst.b	VBL_COUNT
	beq.s	vbl_wait	
	clr.b	VBL_COUNT

	IFEQ	AFFCPU
	clr.w	$FFFF8240.W
	ENDC

	lea	sys_scr1,A0
	movem.l	(A0)+,D0/D1/D2/D3/D4/D5
	move.l	D0,D6
	movem.l	D1/D2/D3/D4/D5/D6,-(A0)
		
	lsr	#8,D5
	move.l	D5,$FFFF8200.W	

	ENDM

*****************************************************************
*	programme principal					*
*****************************************************************

main:
	move.l	USP,A0
	move.l	A0,-(SP)

	JSR	INITPOLY
	JSR	genfastcls(PC)

	move.l	objetcourant(PC),A2	;descripteur d'objet
	move.l	(A2),animcourante

repeat
	IFEQ	EFFSCR
 	jsr	ffastcls(PC)
	ENDC

	IFEQ	AKEYBOARD


	MOVE	MOUSEX(PC),ROTY
	MOVE	MOUSEY(PC),ROTX


	ENDC

	jsr	CALCPROJ(PC)

	move.l	animcourante(PC),A3	;lire la prochaine animation
	move.l	(A3)+,D0		;adresse de l'objet


	bne.s	pasfinanim		;c'est la derniäre image
	move.l	(A3),A3			;retour image boucle
	move.l	(A3)+,D0
pasfinanim:
	move.l	A3,animcourante

	move.l	D0,A2

	LEA	PROJETES,A1

	jsr	CALCOBJ(PC)
	move.l	(A2),A2

	jsr	TRACEOBJ(PC)


	SWAPPER

	add	#1,compteurimage

	move.b	$FFFFFC02.W,D0

	cmp.b	#$4E,D0
	bne.s	pasplus
	addq	#4,DIST
	bra.s	repeat
pasplus
	cmp.b	#$4A,D0
	bne.s	pasmoins
	subq	#4,DIST
	bra	repeat
pasmoins
	cmp	#500,DIST
	bls.s	passpace
	move.l	objetcourant(PC),A0
	lea	18(A0),A0
	tst.l	(A0)
	bne.s	pasfbobj
	lea	objets,A0
pasfbobj
	move.l	A0,objetcourant
	move.l	(A0),animcourante

	addq	#4,A0

	move	(A0)+,VROTX
	move	(A0)+,VROTY
	move	(A0)+,VROTZ
	clr	D1
	move.b	(A0)+,D1
	move	D1,ROTX
	move.b	(A0)+,D1
	move	D1,ROTY
	move.b	(A0)+,D1
	move	D1,ROTZ
	
	move	(A0),cptwaiting

	bra	repeat
passpace

	IFEQ	AKEYBOARD

	cmp.b	#$F9,MOUSEK

	ENDC


	bne	repeat

	move.l	(SP)+,A0
	move.l	A0,USP


	rts

objetcourant:
	DC.L	objets
animcourante:
	DC.L	0
compteurimage:
	DC.W	0
compteurvbl:
	DC.W	0
nombreimage
	DC.W	0

*------------- interruption vbl ----------------------------


CURSAFF	MACRO
	MOVE	#$FFFF,D0
	ADD	#160*9,D1
	MOVE.L	sys_scr1,A1
	MOVE	D0,(A1,D1.W)
	MOVE.L	sys_scr2,A1
	MOVE	D0,(A1,D1.W)
	MOVE.L	sys_scr3,A1
	MOVE	D0,(A1,D1.W)
	MOVE.L	sys_scr4,A1
	MOVE	D0,(A1,D1.W)
	MOVE.L	sys_scr5,A1
	MOVE	D0,(A1,D1.W)
	MOVE.L	sys_scr6,A1
	MOVE	D0,(A1,D1.W)
	SUB	#160*9,D1
	ENDM

CURSEFF	MACRO
	ADD	#160*9,D1
	MOVE.L	sys_scr1,A1
	CLR	(A1,D1.W)
	MOVE.L	sys_scr2,A1
	CLR	(A1,D1.W)
	MOVE.L	sys_scr3,A1
	CLR	(A1,D1.W)
	MOVE.L	sys_scr4,A1
	CLR	(A1,D1.W)
	MOVE.L	sys_scr5,A1
	CLR	(A1,D1.W)
	MOVE.L	sys_scr6,A1
	CLR	(A1,D1.W)
	SUB	#160*9,D1
	ENDM

new_vbl:
	add.b	#1,VBL_COUNT



	clr	$FFFF8240.W
	NOT	color1
	MOVE	color1(PC),$FFFF8242.W
	MOVE	#$013,$FFFF8244.W
	MOVE	#$035,$FFFF8248.W
	MOVE	#$720,$FFFF8250.W
	clr.b	MFP_TBCR
	move.b	#199-10,MFP_TBDR
	move.b	#8,MFP_TBCR

	MOVEM.L	D0-D7/A0/A1/A2/A3/A6,-(SP)

	IFEQ	COMPTEIMAGE

	sub	#1,compteurvbl
	bgt	pas50vbl
	move	#50,compteurvbl
	move	compteurimage(PC),nombreimage
	clr	compteurimage
pas50vbl

	MOVE.L	sys_scr6,A0
	ADDQ	#2,A0
	MOVE	nombreimage(PC),D0
	ADD	D0,D0
	ADD	D0,D0
	jmp	zeroa99(PC,D0.W)
zeroa99
	INCBIN	'ZEROA99.BIN'
	ENDC



	IFEQ	MUSIQUE
	BSR	PLAYMUSIC
	ENDC	

	tst	cptwaiting
	bne.s	noincdist
	MOVE.B	VDIST(PC),D0
	EXT.W	D0
	ADD	D0,DIST
	bra.s	gescurseur
noincdist
	subq	#1,cptwaiting
gescurseur

	IFEQ	AFFTEXTE
	
	move.l	ptrtext(PC),A0
	clr	D0
	move.b	(A0)+,D0
	bne.s	pasfcurs
	lea	textcursor(PC),A0
	move.l	A0,ptrtext
	bra	fgestcurs
pasfcurs
	move.l	A0,ptrtext
	move.l	cursoroffset(PC),D1
	
	CURSEFF

	cmp.b	#'h',D0
	bne.s	pashcurs
	sub	#10*160,D1
	bra	affcurseur
pashcurs
	cmp.b	#'b',D0
	bne.s	pasbcurs
	add	#10*160,D1
	bra	affcurseur
pasbcurs
	cmp.b	#'g',D0
	bne.s	pasgcurs
	subq	#8,D1
	bra	affcurseur
pasgcurs
	cmp.b	#'d',D0
	bne.s	pasdcurs
	addq	#8,D1
	bra	affcurseur
pasdcurs
	lea	FONT16X10(PC),A1	
	SUB.B	#32,D0
	move	D0,A2
	add	A2,A2
	add	A2,A2
	add	A2,A1
	LSL	#4,D0
	ADD	D0,A1

	MOVEM.W	(A1)+,D0/D2/D3/D4/D5/D6/D7/A0/A3/A6

	MOVE.L	sys_scr1,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	MOVE.L	sys_scr2,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	MOVE.L	sys_scr3,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	MOVE.L	sys_scr4,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	MOVE.L	sys_scr5,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	MOVE.L	sys_scr6,A2
	ADD	D1,A2
	MOVE	D0,(A2)
	MOVE	D2,160*1(A2)
	MOVE	D3,160*2(A2)
	MOVE	D4,160*3+2(A2)
	MOVE	D5,160*4+2(A2)
	MOVE	D6,160*5+4(A2)
	MOVE	D7,160*6+4(A2)
	MOVE	A0,160*7+6(A2)
	MOVE	A3,160*8+6(A2)

	ADDQ	#8,D1

affcurseur

	CURSAFF

	MOVE.L	D1,cursoroffset
fgestcurs
	ENDC
	
	MOVEM.L	(SP)+,D0-D7/A0/A1/A2/A3/A6 
	RTE

it1_timerb:
	MOVE	#$002,$FFFF8240.W
	MOVE	#$077,$FFFF8242.W
	MOVE	#$055,$FFFF8244.W
	MOVE	#$044,$FFFF8248.W
	MOVE	#$033,$FFFF8250.W

	CLR.B	MFP_TBCR
	RTE

color1:
	DC.W	$FF0
waiting
	DC.W	0
cptwaiting
	DC.W	500
cursoroffset
	DC.L	160*(199-9)
ptrtext
	DC.L	textcursor
textcursor
	incbin	'TEXTE.BIN'
	DC.B	0
	EVEN


**************** INITIALISATION DE LA TABLE DES POLYGONES **********


INITPOLY:

	LEA		llimit,A0		
	MOVE		#CLIPSIZE-1,D0		;init limite gauche
RRLIMIT
	move.L		#-1,(A0)+
	CLR.L		(A0)+
	DBF		D0,RRLIMIT

	MOVEQ		#0,D0
	moveq	#0,d1
	moveq	#0,d2
RCLIMIT
	not d1
	MOVE		D1,(A0)+
	MOVE		D1,(A0)+
	not d1
	move.l	d2,(a0)+

	lsr	#1,d1
	or	#$8000,d1
	cmp	#-1,d1
	bne.s	.2
	clr	d1
	addq	#8,d2
.2

	ADDQ		#1,D0
	CMP		#319,D0
	BLE.S		RCLIMIT


	MOVE		#CLIPSIZE-1,D0
RLLIMIT
	clr.L		(A0)+		;init limite droite
	MOVE.L		#19*8,(A0)+
	DBF		D0,RLLIMIT

	RTS





		



***********************************************************************
*	routine d'affichage de polygones convexes                     *
*	avec clipping et pas de tramage			              *
*							              *
*	- calcul des droites dans une table 		              *
*	- remplissage par movem.l			              *
*							              *
***********************************************************************

;
; APPEL : en mode superviseur
;
; A6 -> ADRESSE DES DATAS 	(des points projetes)
; D6 -> NOMBRE DE POINTS  	(du polygone)
; D7 -> COULEUR * 8             (ATTENTION)
;
;
;------------- dÇfinition des registres --------------------
;


MINY		equr		D6      ;rÇservÇs dans tous le calcul

MAXY		equr		D7	

PTRTABLE	equr		A0

ECRAN		equr		A1




;------------- registres pour calcul lignes ------------------

XA		equr		D0	;extremitÇs de la droite
YA		equr		D1
XB		equr		D2
YB		equr		D3

PTRSEGMENT	equr		A6	;pointeur sur segment
COPPTRSEGMENT	equr		A0	;copie pointeur sur segment

JMPLINE		equr		A3	;adresse routine de droite
RETOUR		equr		A1	;adresse de retour droite

PTRY		equr		A2	;pointeur tabley

DY		equr		D4

REGDATA		equr		D5

JMP		equr		A5	;adresse debut du saut
					;pour calcul des points


;-------------- cas d'une ligne verticale -----------------------

retourvert
		JMP	(RETOUR)


vertline 
		; clipping

		CMP	#CLIPMAXY,YA
		BLS.S	YAsup0
		BGT.S	retourvert
		moveq	#0,YA
YAsup0
		CMP	#CLIPMAXY,YB
		BLS.S	YBinfmax
		BLT.S	retourvert
		MOVE	#CLIPMAXY,YB
YBinfmax		
		cmp	MAXY,YB		;tester maximum
		ble.s	.pasmaximum
		move	YB,MAXY
.pasmaximum
		cmp	MINY,YA		;tester minimum
		bgt.s	.pasminimum
		move	YA,MINY
.pasminimum
		SUB	YA,YB

		ADD	YA,YA
		ADD	YA,PTRY

		ADD	YB,YB
		NEG	YB
		ADD	#calcretour-calcretour2-2,YB
		JMP	calcretour2(PC,YB.W)
calcretour2
		REPT	200
		MOVE	XA,(PTRY)+	;mise en place nouveau points
		ENDR
calcretour				;fin du calcul des points
		jmp	(RETOUR)

;-------------- dÇbut calcul d'une ligne -------------------------

calcline:
		lea	tableymax(PC),PTRY

		cmp	YA,YB

		beq.s	calcretour	;ligne horizontale

		bge.s	YBsupYA

		exg	XA,XB		;echange les points
		exg	YA,YB

		lea	400(PTRY),PTRY  ;c'est une ligne montante
YBsupYA
		sub	XA,XB		;DX		

		beq	vertline

		move	YB,REGDATA
		sub	YA,REGDATA	;DY


		ext.l	XB		;calcul de la pente
		asl.l	#7-3,XB		;DX*128
		divs	REGDATA,XB	;divise par DY
;		bvc.s	.nodeborde
;		addq	#7,$ffff8240.w
;.nodeborde


;		swap	XB		;test si coefficient entier
;		tst	XB
;		bne	nolineentier	; a garder ?
;
;		addq	#1,$FFFF8240.W
;nolineentier
;		swap	XB		


		ext.l	XB		

		CMP	#CLIPMAXY,YA
		BLS.S	.YAsup0
		BGT.S	calcretour
		muls	XB,YA
		lsr.l	#7-3,YA
		sub	YA,XA
		moveq	#0,YA
		move	YB,REGDATA
.YAsup0
		CMP	#CLIPMAXY,YB
		BLS.S	.YBinfmax
		BLT.S	calcretour
		MOVE	#CLIPMAXY,YB
		move	YB,REGDATA
		sub	YA,REGDATA	;DY
.YBinfmax		

		asl.l	#8,XB		;recuperation virgule 1/128eme
		asl.l	#1+3,XB


;------------ mise a jour des maximums et minimum ----------

		cmp	MAXY,YB		;tester maximum
		ble.s	pasmaximum
		move	YB,MAXY
pasmaximum
		cmp	MINY,YA		;tester minimum
		bgt.s	pasminimum
		move	YA,MINY
pasminimum

		add	YA,YA		 ;adresse tableau lignes
		add	YA,PTRY

		add	REGDATA,REGDATA  ;offset pour le saut
		add	REGDATA,REGDATA
		neg	REGDATA

		swap	XA
		move	XB,XA
		beq	lineentier
		add	#$8000,XA
		swap	XA
		swap	XB		;poids fort = virgule
					;poids faible = partie entiere

		jmp	(JMPLINE,REGDATA.W)

		REPT	200
		MOVE	XA,(PTRY)+
		ADDX.L	XB,XA
		ENDR
jmpline
		MOVE	XA,(PTRY)


		jmp	(RETOUR)


nopoly		rts

;---------- cas d'une ligne Ö coefficient entier -----------
	
lineentier:	
;	addq	#7,$ffff8240.w
		swap	XA
		swap	XB
		ADD	#.line2-.line1,REGDATA
		JMP	.line1(PC,REGDATA.W)
.line1
		REPT	200
		MOVE	XA,(PTRY)+
		ADD	XB,XA
		ENDR
.line2
		MOVE	XA,(PTRY)

		JMP	(RETOUR)

RESULT		equr		D4	;registre de stockage temporaire
X0		equr		D5	
OFFDRO		equr		A6		
X1		equr		D3
OFFGAU		equr		D6

REG1		equr		D0
REG2		equr		D1
REG3		equr		D2
REG4		equr		A2
REG5		equr		A3	;registres utilisÇs dans movem
REG6		equr		A4

PTRCLIPX	equr		A5

polygone
		swap	MAXY			;mise Ö l'ecart du nombre de
		swap	MINY			;points et couleur

		clr	MAXY			;maxy=0
		move.w	#CLIPMAXY,MINY		;miny=y maximum

		swap	MINY			;miny est compteur de points

		move.l	PTRSEGMENT,COPPTRSEGMENT
		lea	lretjmp(PC),RETOUR	;adresse de retour
		lea	calcline(PC),JMP	;adresse du calcul de droite
		lea	jmpline(PC),JMPLINE
		subq	#1,MINY			;un point en moins
repline
		movem	(PTRSEGMENT),XA/YA/XB/YB ;lecture des points
		addq	#4,PTRSEGMENT		 ;passe droite suivante
		swap	MINY			 ;sauve compteur
		jmp	(JMP)			 ;calcul des points
lretjmp
		swap	MINY			 ;restore compteur
		subq	#1,MINY			 ;un point de moins
		bne.s   repline			 ;repeter...
		movem	(PTRSEGMENT),XA/YA	 ;derniäre droite
		movem	(COPPTRSEGMENT),XB/YB
		lea	drawpolygone(PC),RETOUR
		swap	MINY
		jmp	(JMP)

;------------- remplissage du polygone -----------------------


drawpolygone:
		sub	MINY,MAXY		;calcul hauteur du polyg
		ble	nopoly			;si non affichÇ alors fin

		swap	MAXY			;lecture de la couleur
		lea	tableymax(PC),PTRTABLE

		movem.l	colors-tableymax(PTRTABLE,MAXY.W),REG1/REG2
		swap	MAXY

		move.l	REG1,REG3			;charge reg couleur
		move.l	REG2,REG4
		move.l	REG1,REG5
		move.l	REG2,REG6
;		move.l	REG1,REG7			;deux registres libres
;		move.l	REG2,REG8


		add	MINY,MINY			;MINY*2

		lea	muls160(PC),PTRCLIPX

		move.l	sys_scr6,ECRAN
		add	(PTRCLIPX,MINY.W),ECRAN

		add	MINY,PTRTABLE			;debut table

		lea	mlimit,PTRCLIPX

dlrep
		MOVE.L	ECRAN,USP

		moveq	#-8,X0
		and	(PTRTABLE)+,X0
		MOVEM.L	(PTRCLIPX,X0.W),X0/OFFDRO
		ADD	OFFDRO,ECRAN

		moveq	#-8,X1
		and	200*2-2(PTRTABLE),X1		;X0
		MOVEM.L	(PTRCLIPX,X1.W),X1/OFFGAU

		SUB	OFFDRO,OFFGAU
		BGE.S	ONELONG

		move.l	(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	X0,RESULT
		eor.l	REG1,RESULT
		move.l	RESULT,(ECRAN)+

		move.l	(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	X0,RESULT
		eor.l	REG2,RESULT
		move.l	RESULT,(ECRAN)

		subq	#4,ECRAN		

		ADD	OFFGAU,OFFGAU
		ADD	OFFGAU,OFFGAU
		neg	OFFGAU
		jmp	ffill0-32(PC,OFFGAU.W)		;appel transfert par movem

ONELONG
		BNE.S	LSUIV
;	not.l	X1
;	or.l	X0,X1
;		move.l	(ECRAN),RESULT
;		eor.l	REG1,RESULT
;		and.l	X1,RESULT
;		eor.l	REG1,RESULT
;		move.l	RESULT,(ECRAN)+
;		move.l	(ECRAN),RESULT
;		eor.l	REG2,RESULT
;		and.l	X1,RESULT
;		eor.l	REG2,RESULT
;		move.l	RESULT,(ECRAN)

	not.l	X0
	and.l	X0,X1

	move.l	(ECRAN),RESULT
	eor.l	REG1,RESULT
	and.l	X1,RESULT
	eor.l	RESULT,(ECRAN)+
	move.l	(ECRAN),RESULT
	eor.l	REG2,RESULT
	and.l	X1,RESULT
	eor.l	RESULT,(ECRAN)
LSUIV
		move.l	USP,ECRAN
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts

MACRO28		MACRO
		move.l	-(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	X1,RESULT
		eor.l	RESULT,(ECRAN)
		move.l	-(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	X1,RESULT
		eor.l	RESULT,(ECRAN)

		move.l	USP,ECRAN
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts
		ENDM

ffill0
		MACRO28
		DS.B	4
;		bra	ffillfin
;		DS.B	32-4
ffill1
		movem.l	REG1/REG2,-(ECRAN)
		MACRO28
;		bra	ffillfin
;		DS.B	32-8
ffill2
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		MACRO28
;		bra	ffillfin		
;		DS.B	32-8
ffill3
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MACRO28
;		bra	ffillfin
;		DS.B	32-8
ffill4						 
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill5
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill6
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill7
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill8
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill9	
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill10
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill11
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill12
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill13
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill14
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill15
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-24
ffill16
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill17
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill18
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-28
ffill19
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
ffillfin:
;	not.L	X1
;		move.l	-(ECRAN),RESULT
;		eor.l	REG2,RESULT
;		and.l	X1,RESULT
;		eor.l	REG2,RESULT
;		move.l	RESULT,(ECRAN)
;		move.l	-(ECRAN),RESULT
;		eor.l	REG1,RESULT
;		and.l	X1,RESULT
;		eor.l	REG1,RESULT
;		move.l	RESULT,(ECRAN)

	MACRO28


muls160:
cpt		SET	0
		REPT	200
		DC.W	cpt
cpt		SET	cpt+160
		ENDR
colors:
		dc.l	$00000000,$00000000
		dc.l	$FFFF0000,$00000000
		dc.l	$0000FFFF,$00000000
		dc.l	$FFFFFFFF,$00000000
		dc.l	$00000000,$FFFF0000
		dc.l	$FFFF0000,$FFFF0000
		dc.l	$0000FFFF,$FFFF0000
		dc.l	$FFFFFFFF,$FFFF0000
		dc.l	$00000000,$0000FFFF
		dc.l	$FFFF0000,$0000FFFF
		dc.l	$0000FFFF,$0000FFFF
		dc.l	$FFFFFFFF,$0000FFFF
		dc.l	$00000000,$FFFFFFFF
		dc.l	$FFFF0000,$FFFFFFFF
		dc.l	$0000FFFF,$FFFFFFFF
		dc.l	$FFFFFFFF,$FFFFFFFF

tableymax:
		ds.w	200
tableymin:
		ds.w	200




NXTANG	MACRO
	MOVE	\1(PC),D0	;ROT
	ADD	\2(PC),D0
	AND	#$3FF,D0
	MOVE	D0,\2
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A0,D0.W),\3
	ENDM

; SX=SIN/COS ANGLE X,SY=SIN/COS ANGLE Y,SZ=SIN/COS ANGLE Z
; L14=ANGLE ROT X,L16=ANGLE ROT Y,L3C=ANGLE ROT Z
; ROTX,ROTY,ROTZ=ANGLES COURANTS


SX	EQUR	D2
CX	EQUR	D3
SY	EQUR	D4
CY	EQUR	D5
SZ	EQUR	D6
CZ	EQUR	D7

;
; CHANGEMENT D'ANGLE DE ROTATION
;

CALCPROJ
	LEA	SINCOS(PC),A0
	NXTANG	VROTX,ROTX,SX/CX	;SX
	NXTANG	VROTY,ROTY,SY/CY	;SY
	NXTANG	VROTZ,ROTZ,SZ/CZ	;SZ
;
; CALCULE LA MATRICE DE PROJECTION
;
	LEA	MATRIX(PC),A0

	MOVE	CY,D0
	MULS	CZ,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+

	MOVE	SY,(A0)+

	MOVE	CY,D0
	MULS	SZ,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+

	MOVE	SX,D1
	MULS	SZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+

	MOVE	CX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$10

	MOVE	SX,D1
	MULS	CZ,D1
	MOVE	CX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$14

	MOVE	CX,D1
	MULS	SZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	CZ,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVE	D0,(A0)+	;$18

	MOVE	SX,D0
	MULS	CY,D0
	ADD.L	D0,D0
	SWAP	D0
	NEG	D0
	MOVE	D0,(A0)+	;$1C

	MOVE	CX,D1
	MULS	CZ,D1
	MOVE	SX,D0
	MULS	SY,D0
	ADD.L	D0,D0
	SWAP	D0
	MULS	SZ,D0
	SUB.L	D0,D1
	ADD.L	D1,D1
	SWAP	D1
	MOVE	D1,(A0)+



	RTS



; REGISTRES UTILISES :
;	A0-A6 SAUF A1
;	A2 PEUT ETRE LIBERE
;
; 	D1-D7 SAUF D4
;
; registres libres :
;
;	A1,D0,D4
;

CALCOBJ

;	LEA	BUFFERZ(PC),A5

	LEA	MATRIX(PC),A6
	MOVE	DIST(PC),D4
	MOVE	(A2)+,D1
	BEQ.S	FCALCOBJ
;
; OCCUPES :
;	D0/D1/D2/D3/D4/D6/D7
;	A1/A2/A4/A6
; LIBRES :
;	D5
;	A0/A3/A5 TRANSLATION X,Y,Z
BCPTS:
	MOVE.L	A6,A4
	MOVE	(A2)+,D2
	MOVE	(A2)+,D3

	MOVE	D1,D6
	MULS	(A4)+,D6	;X
	MOVE	D2,D0
	MULS	(A4)+,D0
	ADD.L	D0,D6
	MOVE	D3,D0
	MULS	(A4)+,D0
	ADD.L	D0,D6

	MOVE	D1,D7
	MULS	(A4)+,D7	;Y
	MOVE	D2,D0
	MULS	(A4)+,D0
	ADD.L	D0,D7
	MOVE	D3,D0
	MULS	(A4)+,D0
	ADD.L	D0,D7

	MULS	(A4)+,D1	;Z
	MULS	(A4)+,D2
	ADD.L	D2,D1
	MULS	(A4)+,D3
	ADD.L	D3,D1

;	ADD.L	A0,D6		;X
;	ADD.L	A3,D7		;Y

	SWAP	D1
	SUB	D4,D1

	ASR.L	#8,D7
	ASR.L	#5,D6
	
	DIVS	D1,D6
	DIVS	D1,D7

;	ADD	#320/2*8,D6		;A DEGAGER !!!
	ADD	#200/2,D7

	MOVE	D6,(A1)+
	MOVE	D7,(A1)+

	MOVE	(A2)+,D1
	BNE.S	BCPTS
FCALCOBJ:
	RTS


**************** TRACE D'UN OBJET ****************************

HIDEFACETTE
	LEA	16(A2),A2

TRACEOBJ
RFACETTES
	MOVE	(A2)+,D0
	BLT	FFACETTES
RFACETTE2
	LEA	PROJETES(PC),A1
	MOVEM	(A1,D0.W),D1/D2			;lire XA,YA

	MOVE	(A2)+,D0
	MOVEM	(A1,D0.W),D3/D4			;lire XB,YB

	MOVE	(A2)+,D0
	MOVEM	(A1,D0.W),D5/A3			;lire XC,YC

	MOVE	D5,D0
	SUB	D3,D0				;XC-XB
	MOVE	D2,D7
	SUB	D4,D7				;YA-YB
	MULS	D0,D7					

	MOVE	D3,D0				;XB-XA
	SUB	D1,D0
	MOVE	A3,D6			        ;YC-YB
	SUB	D4,D6	
	MULS	D0,D6

	ADD.L	D6,D7
	
	BLT.S	HIDEFACETTE

	MOVE.L	A2,A5
	MOVEQ	#3,D6
	LEA	SEGMENTS(PC),A4
	MOVE.L	A4,A6
	MOVEM	D1/D2/D3/D4/D5/A3,(A4)
	LEA	12(A4),A4
LRPOINT
	REPT	4
	MOVE	(A5)+,D0
	BLT.S	FRPOINT
	MOVE.L	(A1,D0.W),(A4)+
	ADDQ	#1,D6
	ENDR

	MOVE	(A5)+,D0
	BLT.S	FRPOINT
	MOVE.L	(A1,D0.W),(A4)
	ADDQ	#1,D6

FRPOINT
	LEA	10(A2),A2
	MOVE	(A2)+,D7

	MOVE.L	A2,-(SP)
	JSR	polygone(PC)
	MOVE.L	(SP)+,A2

	MOVE.L	(A2)+,D0
	BNE.S	SOUSOBJDRAW

	MOVE	(A2)+,D0
	BGE	RFACETTE2
FFACETTES
	RTS



SOUSOBJDRAW
	MOVE.L	A2,-(SP)
	MOVE.L	D0,A2

	LEA	PROJETES2(PC),A1
	JSR	CALCOBJ(PC)

	MOVE	(A2)+,D0
	BLT	FINSOUSOBJ
SOUSOBJREP
	LEA	SEGMENTS(PC),A4
	MOVE.L	A4,A6
	LEA	PROJETES2(PC),A1

	MOVE.L	(A1,D0.W),(A4)+
	REPT	2
	MOVE	(A2)+,D0
	MOVE.L	(A1,D0.W),(A4)+
	ENDR
	MOVEQ	#3,D6

	MOVE.L	A2,A3
	REPT	4
	MOVE	(A3)+,D0
	BLT.S	FSOUSOBJ
	MOVE.L	(A1,D0.W),(A4)+
	ADDQ	#1,D6
	ENDR

	MOVE	(A3),D0
	BLT.S	FSOUSOBJ
	MOVE.L	(A1,D0.W),(A4)+
	ADDQ	#1,D6
FSOUSOBJ
	LEA	10(A2),A2
	MOVE	(A2)+,D7
	MOVE.L	A2,-(SP)
	jsr	polygone(PC)
	MOVE.L	(SP)+,A2
	MOVE	(A2)+,D0
	BGE	SOUSOBJREP

FINSOUSOBJ


	MOVE.L	(SP)+,A2
	MOVE	(A2)+,D0
	BGE	RFACETTE2	
	RTS




****************************************************************
;	A0 -> adresse de la chaine 
;	A1 -> adresse ecran
;



FONT16X10
	INCBIN	'FONT16X10.BIN'

	even	        		

VROTX	DC.W	0
VROTY	DC.W	5
VROTZ	DC.W	0
DIST	DC.W	250
ROTX	DC.W	$80
ROTY	DC.W	$0
ROTZ	DC.W	$0
VDIST   DC.W	$4

	even

SINCOS
        DC.W    $0000,$7FFF,$001F,$7FFE,$003F,$7FFE,$005F,$7FFE       ;0
        DC.W    $0324,$7FF5,$0344,$7FF4,$0364,$7FF3,$0384,$7FF2       ;4
        DC.W    $0647,$7FD7,$0667,$7FD5,$0687,$7FD4,$06A7,$7FD2       ;8
        DC.W    $096A,$7FA6,$098A,$7FA3,$09AA,$7FA1,$09CA,$7F9F       ;12
        DC.W    $0C8B,$7F61,$0CAB,$7F5E,$0CCB,$7F5A,$0CEB,$7F57       ;16
        DC.W    $0FAB,$7F08,$0FCA,$7F04,$0FEA,$7F00,$100A,$7EFC       ;20
        DC.W    $12C7,$7E9C,$12E7,$7E97,$1307,$7E92,$1326,$7E8E       ;24
        DC.W    $15E1,$7E1C,$1601,$7E17,$1620,$7E11,$1640,$7E0C       ;28
        DC.W    $18F8,$7D89,$1917,$7D83,$1937,$7D7C,$1956,$7D76       ;32
        DC.W    $1C0B,$7CE2,$1C2A,$7CDB,$1C49,$7CD4,$1C68,$7CCD       ;36
        DC.W    $1F19,$7C29,$1F38,$7C21,$1F57,$7C19,$1F76,$7C11       ;40
        DC.W    $2223,$7B5C,$2242,$7B53,$2261,$7B4A,$227F,$7B42       ;44
        DC.W    $2527,$7A7C,$2546,$7A72,$2564,$7A69,$2583,$7A60       ;48
        DC.W    $2826,$7989,$2844,$797F,$2863,$7975,$2881,$796A       ;52
        DC.W    $2B1E,$7883,$2B3C,$7878,$2B5B,$786D,$2B79,$7863       ;56
        DC.W    $2E10,$776B,$2E2E,$775F,$2E4C,$7754,$2E6A,$7748       ;60
        DC.W    $30FB,$7640,$3118,$7634,$3136,$7628,$3154,$761B       ;64
        DC.W    $33DE,$7503,$33FB,$74F6,$3419,$74E9,$3436,$74DC       ;68
        DC.W    $36B9,$73B5,$36D6,$73A7,$36F3,$7399,$3710,$738B       ;72
        DC.W    $398C,$7254,$39A8,$7245,$39C5,$7237,$39E2,$7228       ;76
        DC.W    $3C56,$70E1,$3C72,$70D2,$3C8E,$70C3,$3CAA,$70B4       ;80
        DC.W    $3F16,$6F5E,$3F32,$6F4E,$3F4E,$6F3E,$3F6A,$6F2E       ;84
        DC.W    $41CD,$6DC9,$41E9,$6DB8,$4204,$6DA8,$421F,$6D97       ;88
        DC.W    $447A,$6C23,$4495,$6C12,$44B0,$6C01,$44CB,$6BEF       ;92
        DC.W    $471C,$6A6C,$4736,$6A5A,$4751,$6A49,$476C,$6A37       ;96
        DC.W    $49B3,$68A5,$49CD,$6893,$49E7,$6880,$4A01,$686E       ;100
        DC.W    $4C3F,$66CE,$4C58,$66BB,$4C72,$66A8,$4C8C,$6695       ;104
        DC.W    $4EBF,$64E7,$4ED8,$64D4,$4EF1,$64C0,$4F0A,$64AC       ;108
        DC.W    $5133,$62F1,$514B,$62DC,$5164,$62C8,$517D,$62B4       ;112
        DC.W    $539A,$60EB,$53B2,$60D6,$53CA,$60C1,$53E3,$60AC       ;116
        DC.W    $55F4,$5ED6,$560C,$5EC1,$5624,$5EAB,$563C,$5E96       ;120
        DC.W    $5842,$5CB3,$5859,$5C9D,$5870,$5C87,$5887,$5C71       ;124
        DC.W    $5A81,$5A81,$5A98,$5A6B,$5AAE,$5A54,$5AC5,$5A3D       ;128
        DC.W    $5CB3,$5842,$5CC9,$582A,$5CDF,$5813,$5CF5,$57FC       ;132
        DC.W    $5ED6,$55F4,$5EEC,$55DD,$5F01,$55C5,$5F17,$55AD       ;136
        DC.W    $60EB,$539A,$6100,$5382,$6115,$536A,$612A,$5351       ;140
        DC.W    $62F1,$5133,$6305,$511A,$6319,$5101,$632E,$50E8       ;144
        DC.W    $64E7,$4EBF,$64FB,$4EA6,$650F,$4E8C,$6522,$4E73       ;148
        DC.W    $66CE,$4C3F,$66E1,$4C25,$66F4,$4C0B,$6707,$4BF2       ;152
        DC.W    $68A5,$49B3,$68B8,$4999,$68CA,$497F,$68DC,$4964       ;156
        DC.W    $6A6C,$471C,$6A7E,$4701,$6A90,$46E7,$6AA1,$46CC       ;160
        DC.W    $6C23,$447A,$6C34,$445F,$6C45,$4444,$6C56,$4429       ;164
        DC.W    $6DC9,$41CD,$6DD9,$41B2,$6DEA,$4196,$6DFA,$417B       ;168
        DC.W    $6F5E,$3F16,$6F6D,$3EFA,$6F7D,$3EDF,$6F8D,$3EC3       ;172
        DC.W    $70E1,$3C56,$70F0,$3C3A,$7100,$3C1D,$710F,$3C01       ;176
        DC.W    $7254,$398C,$7262,$396F,$7270,$3953,$727F,$3936       ;180
        DC.W    $73B5,$36B9,$73C2,$369C,$73D0,$367F,$73DD,$3662       ;184
        DC.W    $7503,$33DE,$7510,$33C1,$751D,$33A4,$752A,$3386       ;188
        DC.W    $7640,$30FB,$764C,$30DD,$7659,$30C0,$7665,$30A2       ;192
        DC.W    $776B,$2E10,$7776,$2DF2,$7782,$2DD4,$778D,$2DB7       ;196
        DC.W    $7883,$2B1E,$788E,$2B00,$7899,$2AE2,$78A3,$2AC4       ;200
        DC.W    $7989,$2826,$7993,$2808,$799D,$27E9,$79A7,$27CB       ;204
        DC.W    $7A7C,$2527,$7A85,$2509,$7A8E,$24EA,$7A97,$24CB       ;208
        DC.W    $7B5C,$2223,$7B64,$2204,$7B6D,$21E5,$7B75,$21C6       ;212
        DC.W    $7C29,$1F19,$7C30,$1EFA,$7C38,$1EDB,$7C40,$1EBC       ;216
        DC.W    $7CE2,$1C0B,$7CE9,$1BEC,$7CF0,$1BCC,$7CF7,$1BAD       ;220
        DC.W    $7D89,$18F8,$7D8F,$18D9,$7D95,$18B9,$7D9B,$189A       ;224
        DC.W    $7E1C,$15E1,$7E22,$15C2,$7E27,$15A2,$7E2C,$1583       ;228
        DC.W    $7E9C,$12C7,$7EA1,$12A8,$7EA5,$1288,$7EAA,$1268       ;232
        DC.W    $7F08,$0FAB,$7F0C,$0F8B,$7F10,$0F6B,$7F14,$0F4B       ;236
        DC.W    $7F61,$0C8B,$7F64,$0C6B,$7F67,$0C4C,$7F6A,$0C2C       ;240
        DC.W    $7FA6,$096A,$7FA8,$094A,$7FAA,$092A,$7FAD,$090A       ;244
        DC.W    $7FD7,$0647,$7FD9,$0627,$7FDA,$0607,$7FDC,$05E7       ;248
        DC.W    $7FF5,$0324,$7FF5,$0304,$7FF6,$02E4,$7FF7,$02C4       ;252
        DC.W    $7FFF,$0000,$7FFE,$FFE1,$7FFE,$FFC1,$7FFE,$FFA1       ;256
        DC.W    $7FF5,$FCDC,$7FF4,$FCBC,$7FF3,$FC9C,$7FF2,$FC7C       ;260
        DC.W    $7FD7,$F9B9,$7FD5,$F999,$7FD4,$F979,$7FD2,$F959       ;264
        DC.W    $7FA6,$F696,$7FA3,$F676,$7FA1,$F656,$7F9F,$F636       ;268
        DC.W    $7F61,$F375,$7F5E,$F355,$7F5A,$F335,$7F57,$F315       ;272
        DC.W    $7F08,$F055,$7F04,$F036,$7F00,$F016,$7EFC,$EFF6       ;276
        DC.W    $7E9C,$ED39,$7E97,$ED19,$7E92,$ECF9,$7E8E,$ECDA       ;280
        DC.W    $7E1C,$EA1F,$7E17,$E9FF,$7E11,$E9E0,$7E0C,$E9C0       ;284
        DC.W    $7D89,$E708,$7D83,$E6E9,$7D7C,$E6C9,$7D76,$E6AA       ;288
        DC.W    $7CE2,$E3F5,$7CDB,$E3D6,$7CD4,$E3B7,$7CCD,$E398       ;292
        DC.W    $7C29,$E0E7,$7C21,$E0C8,$7C19,$E0A9,$7C11,$E08A       ;296
        DC.W    $7B5C,$DDDD,$7B53,$DDBE,$7B4A,$DD9F,$7B42,$DD81       ;300
        DC.W    $7A7C,$DAD9,$7A72,$DABA,$7A69,$DA9C,$7A60,$DA7D       ;304
        DC.W    $7989,$D7DA,$797F,$D7BC,$7975,$D79D,$796A,$D77F       ;308
        DC.W    $7883,$D4E2,$7878,$D4C4,$786D,$D4A5,$7863,$D487       ;312
        DC.W    $776B,$D1F0,$775F,$D1D2,$7754,$D1B4,$7748,$D196       ;316
        DC.W    $7640,$CF05,$7634,$CEE8,$7628,$CECA,$761B,$CEAC       ;320
        DC.W    $7503,$CC22,$74F6,$CC05,$74E9,$CBE7,$74DC,$CBCA       ;324
        DC.W    $73B5,$C947,$73A7,$C92A,$7399,$C90D,$738B,$C8F0       ;328
        DC.W    $7254,$C674,$7245,$C658,$7237,$C63B,$7228,$C61E       ;332
        DC.W    $70E1,$C3AA,$70D2,$C38E,$70C3,$C372,$70B4,$C356       ;336
        DC.W    $6F5E,$C0EA,$6F4E,$C0CE,$6F3E,$C0B2,$6F2E,$C096       ;340
        DC.W    $6DC9,$BE33,$6DB8,$BE17,$6DA8,$BDFC,$6D97,$BDE1       ;344
        DC.W    $6C23,$BB86,$6C12,$BB6B,$6C01,$BB50,$6BEF,$BB35       ;348
        DC.W    $6A6C,$B8E4,$6A5A,$B8CA,$6A49,$B8AF,$6A37,$B894       ;352
        DC.W    $68A5,$B64D,$6893,$B633,$6880,$B619,$686E,$B5FF       ;356
        DC.W    $66CE,$B3C1,$66BB,$B3A8,$66A8,$B38E,$6695,$B374       ;360
        DC.W    $64E7,$B141,$64D4,$B128,$64C0,$B10F,$64AC,$B0F6       ;364
        DC.W    $62F1,$AECD,$62DC,$AEB5,$62C8,$AE9C,$62B4,$AE83       ;368
        DC.W    $60EB,$AC66,$60D6,$AC4E,$60C1,$AC36,$60AC,$AC1D       ;372
        DC.W    $5ED6,$AA0C,$5EC1,$A9F4,$5EAB,$A9DC,$5E96,$A9C4       ;376
        DC.W    $5CB3,$A7BE,$5C9D,$A7A7,$5C87,$A790,$5C71,$A779       ;380
        DC.W    $5A81,$A57F,$5A6B,$A568,$5A54,$A552,$5A3D,$A53B       ;384
        DC.W    $5842,$A34D,$582A,$A337,$5813,$A321,$57FC,$A30B       ;388
        DC.W    $55F4,$A12A,$55DD,$A114,$55C5,$A0FF,$55AD,$A0E9       ;392
        DC.W    $539A,$9F15,$5382,$9F00,$536A,$9EEB,$5351,$9ED6       ;396
        DC.W    $5133,$9D0F,$511A,$9CFB,$5101,$9CE7,$50E8,$9CD2       ;400
        DC.W    $4EBF,$9B19,$4EA6,$9B05,$4E8C,$9AF1,$4E73,$9ADE       ;404
        DC.W    $4C3F,$9932,$4C25,$991F,$4C0B,$990C,$4BF2,$98F9       ;408
        DC.W    $49B3,$975B,$4999,$9748,$497F,$9736,$4964,$9724       ;412
        DC.W    $471C,$9594,$4701,$9582,$46E7,$9570,$46CC,$955F       ;416
        DC.W    $447A,$93DD,$445F,$93CC,$4444,$93BB,$4429,$93AA       ;420
        DC.W    $41CD,$9237,$41B2,$9227,$4196,$9216,$417B,$9206       ;424
        DC.W    $3F16,$90A2,$3EFA,$9093,$3EDF,$9083,$3EC3,$9073       ;428
        DC.W    $3C56,$8F1F,$3C3A,$8F10,$3C1D,$8F00,$3C01,$8EF1       ;432
        DC.W    $398C,$8DAC,$396F,$8D9E,$3953,$8D90,$3936,$8D81       ;436
        DC.W    $36B9,$8C4B,$369C,$8C3E,$367F,$8C30,$3662,$8C23       ;440
        DC.W    $33DE,$8AFD,$33C1,$8AF0,$33A4,$8AE3,$3386,$8AD6       ;444
        DC.W    $30FB,$89C0,$30DD,$89B4,$30C0,$89A7,$30A2,$899B       ;448
        DC.W    $2E10,$8895,$2DF2,$888A,$2DD4,$887E,$2DB7,$8873       ;452
        DC.W    $2B1E,$877D,$2B00,$8772,$2AE2,$8767,$2AC4,$875D       ;456
        DC.W    $2826,$8677,$2808,$866D,$27E9,$8663,$27CB,$8659       ;460
        DC.W    $2527,$8584,$2509,$857B,$24EA,$8572,$24CB,$8569       ;464
        DC.W    $2223,$84A4,$2204,$849C,$21E5,$8493,$21C6,$848B       ;468
        DC.W    $1F19,$83D7,$1EFA,$83D0,$1EDB,$83C8,$1EBC,$83C0       ;472
        DC.W    $1C0B,$831E,$1BEC,$8317,$1BCC,$8310,$1BAD,$8309       ;476
        DC.W    $18F8,$8277,$18D9,$8271,$18B9,$826B,$189A,$8265       ;480
        DC.W    $15E1,$81E4,$15C2,$81DE,$15A2,$81D9,$1583,$81D4       ;484
        DC.W    $12C7,$8164,$12A8,$815F,$1288,$815B,$1268,$8156       ;488
        DC.W    $0FAB,$80F8,$0F8B,$80F4,$0F6B,$80F0,$0F4B,$80EC       ;492
        DC.W    $0C8B,$809F,$0C6B,$809C,$0C4C,$8099,$0C2C,$8096       ;496
        DC.W    $096A,$805A,$094A,$8058,$092A,$8056,$090A,$8053       ;500
        DC.W    $0647,$8029,$0627,$8027,$0607,$8026,$05E7,$8024       ;504
        DC.W    $0324,$800B,$0304,$800B,$02E4,$800A,$02C4,$8009       ;508
        DC.W    $0000,$8001,$FFE1,$8002,$FFC1,$8002,$FFA1,$8002       ;512
        DC.W    $FCDC,$800B,$FCBC,$800C,$FC9C,$800D,$FC7C,$800E       ;516
        DC.W    $F9B9,$8029,$F999,$802B,$F979,$802C,$F959,$802E       ;520
        DC.W    $F696,$805A,$F676,$805D,$F656,$805F,$F636,$8061       ;524
        DC.W    $F375,$809F,$F355,$80A2,$F335,$80A6,$F315,$80A9       ;528
        DC.W    $F055,$80F8,$F036,$80FC,$F016,$8100,$EFF6,$8104       ;532
        DC.W    $ED39,$8164,$ED19,$8169,$ECF9,$816E,$ECDA,$8172       ;536
        DC.W    $EA1F,$81E4,$E9FF,$81E9,$E9E0,$81EF,$E9C0,$81F4       ;540
        DC.W    $E708,$8277,$E6E9,$827D,$E6C9,$8284,$E6AA,$828A       ;544
        DC.W    $E3F5,$831E,$E3D6,$8325,$E3B7,$832C,$E398,$8333       ;548
        DC.W    $E0E7,$83D7,$E0C8,$83DF,$E0A9,$83E7,$E08A,$83EF       ;552
        DC.W    $DDDD,$84A4,$DDBE,$84AD,$DD9F,$84B6,$DD81,$84BE       ;556
        DC.W    $DAD9,$8584,$DABA,$858E,$DA9C,$8597,$DA7D,$85A0       ;560
        DC.W    $D7DA,$8677,$D7BC,$8681,$D79D,$868B,$D77F,$8696       ;564
        DC.W    $D4E2,$877D,$D4C4,$8788,$D4A5,$8793,$D487,$879D       ;568
        DC.W    $D1F0,$8895,$D1D2,$88A1,$D1B4,$88AC,$D196,$88B8       ;572
        DC.W    $CF05,$89C0,$CEE8,$89CC,$CECA,$89D8,$CEAC,$89E5       ;576
        DC.W    $CC22,$8AFD,$CC05,$8B0A,$CBE7,$8B17,$CBCA,$8B24       ;580
        DC.W    $C947,$8C4B,$C92A,$8C59,$C90D,$8C67,$C8F0,$8C75       ;584
        DC.W    $C674,$8DAC,$C658,$8DBB,$C63B,$8DC9,$C61E,$8DD8       ;588
        DC.W    $C3AA,$8F1F,$C38E,$8F2E,$C372,$8F3D,$C356,$8F4C       ;592
        DC.W    $C0EA,$90A2,$C0CE,$90B2,$C0B2,$90C2,$C096,$90D2       ;596
        DC.W    $BE33,$9237,$BE17,$9248,$BDFC,$9258,$BDE1,$9269       ;600
        DC.W    $BB86,$93DD,$BB6B,$93EE,$BB50,$93FF,$BB35,$9411       ;604
        DC.W    $B8E4,$9594,$B8CA,$95A6,$B8AF,$95B7,$B894,$95C9       ;608
        DC.W    $B64D,$975B,$B633,$976D,$B619,$9780,$B5FF,$9792       ;612
        DC.W    $B3C1,$9932,$B3A8,$9945,$B38E,$9958,$B374,$996B       ;616
        DC.W    $B141,$9B19,$B128,$9B2C,$B10F,$9B40,$B0F6,$9B54       ;620
        DC.W    $AECD,$9D0F,$AEB5,$9D24,$AE9C,$9D38,$AE83,$9D4C       ;624
        DC.W    $AC66,$9F15,$AC4E,$9F2A,$AC36,$9F3F,$AC1D,$9F54       ;628
        DC.W    $AA0C,$A12A,$A9F4,$A13F,$A9DC,$A155,$A9C4,$A16A       ;632
        DC.W    $A7BE,$A34D,$A7A7,$A363,$A790,$A379,$A779,$A38F       ;636
        DC.W    $A57F,$A57F,$A568,$A595,$A552,$A5AC,$A53B,$A5C3       ;640
        DC.W    $A34D,$A7BE,$A337,$A7D6,$A321,$A7ED,$A30B,$A804       ;644
        DC.W    $A12A,$AA0C,$A114,$AA23,$A0FF,$AA3B,$A0E9,$AA53       ;648
        DC.W    $9F15,$AC66,$9F00,$AC7E,$9EEB,$AC96,$9ED6,$ACAF       ;652
        DC.W    $9D0F,$AECD,$9CFB,$AEE6,$9CE7,$AEFF,$9CD2,$AF18       ;656
        DC.W    $9B19,$B141,$9B05,$B15A,$9AF1,$B174,$9ADE,$B18D       ;660
        DC.W    $9932,$B3C1,$991F,$B3DB,$990C,$B3F5,$98F9,$B40E       ;664
        DC.W    $975B,$B64D,$9748,$B667,$9736,$B681,$9724,$B69C       ;668
        DC.W    $9594,$B8E4,$9582,$B8FF,$9570,$B919,$955F,$B934       ;672
        DC.W    $93DD,$BB86,$93CC,$BBA1,$93BB,$BBBC,$93AA,$BBD7       ;676
        DC.W    $9237,$BE33,$9227,$BE4E,$9216,$BE6A,$9206,$BE85       ;680
        DC.W    $90A2,$C0EA,$9093,$C106,$9083,$C121,$9073,$C13D       ;684
        DC.W    $8F1F,$C3AA,$8F10,$C3C6,$8F00,$C3E3,$8EF1,$C3FF       ;688
        DC.W    $8DAC,$C674,$8D9E,$C691,$8D90,$C6AD,$8D81,$C6CA       ;692
        DC.W    $8C4B,$C947,$8C3E,$C964,$8C30,$C981,$8C23,$C99E       ;696
        DC.W    $8AFD,$CC22,$8AF0,$CC3F,$8AE3,$CC5C,$8AD6,$CC7A       ;700
        DC.W    $89C0,$CF05,$89B4,$CF23,$89A7,$CF40,$899B,$CF5E       ;704
        DC.W    $8895,$D1F0,$888A,$D20E,$887E,$D22C,$8873,$D249       ;708
        DC.W    $877D,$D4E2,$8772,$D500,$8767,$D51E,$875D,$D53C       ;712
        DC.W    $8677,$D7DA,$866D,$D7F8,$8663,$D817,$8659,$D835       ;716
        DC.W    $8584,$DAD9,$857B,$DAF7,$8572,$DB16,$8569,$DB35       ;720
        DC.W    $84A4,$DDDD,$849C,$DDFC,$8493,$DE1B,$848B,$DE3A       ;724
        DC.W    $83D7,$E0E7,$83D0,$E106,$83C8,$E125,$83C0,$E144       ;728
        DC.W    $831E,$E3F5,$8317,$E414,$8310,$E434,$8309,$E453       ;732
        DC.W    $8277,$E708,$8271,$E727,$826B,$E747,$8265,$E766       ;736
        DC.W    $81E4,$EA1F,$81DE,$EA3E,$81D9,$EA5E,$81D4,$EA7D       ;740
        DC.W    $8164,$ED39,$815F,$ED58,$815B,$ED78,$8156,$ED98       ;744
        DC.W    $80F8,$F055,$80F4,$F075,$80F0,$F095,$80EC,$F0B5       ;748
        DC.W    $809F,$F375,$809C,$F395,$8099,$F3B4,$8096,$F3D4       ;752
        DC.W    $805A,$F696,$8058,$F6B6,$8056,$F6D6,$8053,$F6F6       ;756
        DC.W    $8029,$F9B9,$8027,$F9D9,$8026,$F9F9,$8024,$FA19       ;760
        DC.W    $800B,$FCDC,$800B,$FCFC,$800A,$FD1C,$8009,$FD3C       ;764
        DC.W    $8001,$0000,$8002,$001F,$8002,$003F,$8002,$005F       ;768
        DC.W    $800B,$0324,$800C,$0344,$800D,$0364,$800E,$0384       ;772
        DC.W    $8029,$0647,$802B,$0667,$802C,$0687,$802E,$06A7       ;776
        DC.W    $805A,$096A,$805D,$098A,$805F,$09AA,$8061,$09CA       ;780
        DC.W    $809F,$0C8B,$80A2,$0CAB,$80A6,$0CCB,$80A9,$0CEB       ;784
        DC.W    $80F8,$0FAB,$80FC,$0FCA,$8100,$0FEA,$8104,$100A       ;788
        DC.W    $8164,$12C7,$8169,$12E7,$816E,$1307,$8172,$1326       ;792
        DC.W    $81E4,$15E1,$81E9,$1601,$81EF,$1620,$81F4,$1640       ;796
        DC.W    $8277,$18F8,$827D,$1917,$8284,$1937,$828A,$1956       ;800
        DC.W    $831E,$1C0B,$8325,$1C2A,$832C,$1C49,$8333,$1C68       ;804
        DC.W    $83D7,$1F19,$83DF,$1F38,$83E7,$1F57,$83EF,$1F76       ;808
        DC.W    $84A4,$2223,$84AD,$2242,$84B6,$2261,$84BE,$227F       ;812
        DC.W    $8584,$2527,$858E,$2546,$8597,$2564,$85A0,$2583       ;816
        DC.W    $8677,$2826,$8681,$2844,$868B,$2863,$8696,$2881       ;820
        DC.W    $877D,$2B1E,$8788,$2B3C,$8793,$2B5B,$879D,$2B79       ;824
        DC.W    $8895,$2E10,$88A1,$2E2E,$88AC,$2E4C,$88B8,$2E6A       ;828
        DC.W    $89C0,$30FB,$89CC,$3118,$89D8,$3136,$89E5,$3154       ;832
        DC.W    $8AFD,$33DE,$8B0A,$33FB,$8B17,$3419,$8B24,$3436       ;836
        DC.W    $8C4B,$36B9,$8C59,$36D6,$8C67,$36F3,$8C75,$3710       ;840
        DC.W    $8DAC,$398C,$8DBB,$39A8,$8DC9,$39C5,$8DD8,$39E2       ;844
        DC.W    $8F1F,$3C56,$8F2E,$3C72,$8F3D,$3C8E,$8F4C,$3CAA       ;848
        DC.W    $90A2,$3F16,$90B2,$3F32,$90C2,$3F4E,$90D2,$3F6A       ;852
        DC.W    $9237,$41CD,$9248,$41E9,$9258,$4204,$9269,$421F       ;856
        DC.W    $93DD,$447A,$93EE,$4495,$93FF,$44B0,$9411,$44CB       ;860
        DC.W    $9594,$471C,$95A6,$4736,$95B7,$4751,$95C9,$476C       ;864
        DC.W    $975B,$49B3,$976D,$49CD,$9780,$49E7,$9792,$4A01       ;868
        DC.W    $9932,$4C3F,$9945,$4C58,$9958,$4C72,$996B,$4C8C       ;872
        DC.W    $9B19,$4EBF,$9B2C,$4ED8,$9B40,$4EF1,$9B54,$4F0A       ;876
        DC.W    $9D0F,$5133,$9D24,$514B,$9D38,$5164,$9D4C,$517D       ;880
        DC.W    $9F15,$539A,$9F2A,$53B2,$9F3F,$53CA,$9F54,$53E3       ;884
        DC.W    $A12A,$55F4,$A13F,$560C,$A155,$5624,$A16A,$563C       ;888
        DC.W    $A34D,$5842,$A363,$5859,$A379,$5870,$A38F,$5887       ;892
        DC.W    $A57F,$5A81,$A595,$5A98,$A5AC,$5AAE,$A5C3,$5AC5       ;896
        DC.W    $A7BE,$5CB3,$A7D6,$5CC9,$A7ED,$5CDF,$A804,$5CF5       ;900
        DC.W    $AA0C,$5ED6,$AA23,$5EEC,$AA3B,$5F01,$AA53,$5F17       ;904
        DC.W    $AC66,$60EB,$AC7E,$6100,$AC96,$6115,$ACAF,$612A       ;908
        DC.W    $AECD,$62F1,$AEE6,$6305,$AEFF,$6319,$AF18,$632E       ;912
        DC.W    $B141,$64E7,$B15A,$64FB,$B174,$650F,$B18D,$6522       ;916
        DC.W    $B3C1,$66CE,$B3DB,$66E1,$B3F5,$66F4,$B40E,$6707       ;920
        DC.W    $B64D,$68A5,$B667,$68B8,$B681,$68CA,$B69C,$68DC       ;924
        DC.W    $B8E4,$6A6C,$B8FF,$6A7E,$B919,$6A90,$B934,$6AA1       ;928
        DC.W    $BB86,$6C23,$BBA1,$6C34,$BBBC,$6C45,$BBD7,$6C56       ;932
        DC.W    $BE33,$6DC9,$BE4E,$6DD9,$BE6A,$6DEA,$BE85,$6DFA       ;936
        DC.W    $C0EA,$6F5E,$C106,$6F6D,$C121,$6F7D,$C13D,$6F8D       ;940
        DC.W    $C3AA,$70E1,$C3C6,$70F0,$C3E3,$7100,$C3FF,$710F       ;944
        DC.W    $C674,$7254,$C691,$7262,$C6AD,$7270,$C6CA,$727F       ;948
        DC.W    $C947,$73B5,$C964,$73C2,$C981,$73D0,$C99E,$73DD       ;952
        DC.W    $CC22,$7503,$CC3F,$7510,$CC5C,$751D,$CC7A,$752A       ;956
        DC.W    $CF05,$7640,$CF23,$764C,$CF40,$7659,$CF5E,$7665       ;960
        DC.W    $D1F0,$776B,$D20E,$7776,$D22C,$7782,$D249,$778D       ;964
        DC.W    $D4E2,$7883,$D500,$788E,$D51E,$7899,$D53C,$78A3       ;968
        DC.W    $D7DA,$7989,$D7F8,$7993,$D817,$799D,$D835,$79A7       ;972
        DC.W    $DAD9,$7A7C,$DAF7,$7A85,$DB16,$7A8E,$DB35,$7A97       ;976
        DC.W    $DDDD,$7B5C,$DDFC,$7B64,$DE1B,$7B6D,$DE3A,$7B75       ;980
        DC.W    $E0E7,$7C29,$E106,$7C30,$E125,$7C38,$E144,$7C40       ;984
        DC.W    $E3F5,$7CE2,$E414,$7CE9,$E434,$7CF0,$E453,$7CF7       ;988
        DC.W    $E708,$7D89,$E727,$7D8F,$E747,$7D95,$E766,$7D9B       ;992
        DC.W    $EA1F,$7E1C,$EA3E,$7E22,$EA5E,$7E27,$EA7D,$7E2C       ;996
        DC.W    $ED39,$7E9C,$ED58,$7EA1,$ED78,$7EA5,$ED98,$7EAA       ;1000
        DC.W    $F055,$7F08,$F075,$7F0C,$F095,$7F10,$F0B5,$7F14       ;1004
        DC.W    $F375,$7F61,$F395,$7F64,$F3B4,$7F67,$F3D4,$7F6A       ;1008
        DC.W    $F696,$7FA6,$F6B6,$7FA8,$F6D6,$7FAA,$F6F6,$7FAD       ;1012
        DC.W    $F9B9,$7FD7,$F9D9,$7FD9,$F9F9,$7FDA,$FA19,$7FDC       ;1016
        DC.W    $FCDC,$7FF5,$FCFC,$7FF5,$FD1C,$7FF6,$FD3C,$7FF7       ;1020


;----------------- effacement de l'ecran 4 plans --------------


ffastcls:
	move.l		sys_scr6(PC),A0
	lea		160*(199-10)(A0),A0
	moveq		#0,D0
	move.l		D0,D1
	move.l		D0,D2
	move.l		D1,D3
	move.l		D0,D4
	move.l		D1,D5
	move.l		D0,D6
	move.l		D1,D7
	move.l		D0,A1
	move.l		D1,A2
	move.l		D0,A3
	move.l		D1,A4
	move.l		D0,A5
	move.l		D1,A6
	bra		bfastcls

************************************************************
	SECTION DATA
************************************************************

objets:


	DC.L		scareface
	DC.W		0,2,0
	DC.W		100	
	DC.B		$38,0,0,1
	DC.W		1000


	DC.L		helice
	DC.W		1,2,3
	DC.W		100	
	DC.B		0,0,0,1
	DC.W		1000

	DC.L		interph
	DC.W		0,2,0
	DC.W		100	
	DC.B		$38,0,0,1
	DC.W		1000

	DC.L		nscarre
	DC.W		1,2,3
	DC.W		100	
	DC.B		0,0,0,1
	DC.W		1000

	DC.L		raie
	DC.W		0,2,0
	DC.W		100	
	DC.B		$3A,0,0,1
	DC.W		500

	DC.L		dodecaedre
	DC.W		1,2,3
	DC.W		90
	DC.B		$0,0,0,1
	DC.W		500
 
	DC.L		car
	DC.W		0,1,0
	DC.W		120	
	DC.B		$38,$40,0,1
	DC.W		500

	DC.L		scareface
	DC.W		3,2,1
	DC.W		45
	DC.B		0,0,0,4
	DC.W		300

	DC.L		glider2
	DC.W		1,2,3
	DC.W		100 
	DC.B		0,0,0,4
	DC.W		200		


	DC.L		spider2
	DC.W		1,2,3 
	DC.W		70	
	DC.B		0,0,0,1
	DC.W		300


	DC.L		pyramide
	DC.W		1,2,3
	DC.W		50	
	DC.B		0,0,$80,4
	DC.W		50

	DC.L		deuxcube
	DC.W		1,2,3
	DC.W		40	
	DC.B		0,0,$80,4
	DC.W		200

	DC.L		mine
	DC.W		1,2,3
	DC.W		255	
	DC.B		0,0,$80,2
	DC.W		100

	DC.L		rcube
	DC.W		1,2,3
	DC.W		55	
	DC.B		0,0,$80,4
	DC.W		100


	DC.L		torus
	DC.W		1,2,3
	DC.W		30
	DC.B		0,0,0,4
	DC.W		300

	DC.L		dalle
	DC.W		0,1,0
	DC.W		70	
	DC.B		0,0,0,2
	DC.W		100

	DC.L		lettrea
	DC.W		1,2,3
	DC.W		40	
	DC.B		0,0,0,4
	DC.W		200

	DC.L		chiffre8
	DC.W		0,2,0
	DC.W		290	
	DC.B		$20,0,0,-8
	DC.W		100

	DC.L		scareface
	DC.W		1,2,3
	DC.W		45
	DC.B		0,0,0,4
	DC.W		300

	DC.L		dalle
	DC.W		1,2,3
	DC.W		60	
	DC.B		0,0,0,1
	DC.W		300

	DC.L		lettrea
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,1
	DC.W		400

	DC.L		mine
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,1
	DC.W		400


	DC.L		grille
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,1
	DC.W		250

	DC.L		scareface
	DC.W		1,3,2
	DC.W		45
	DC.B		0,0,0,1
	DC.W		300

	DC.L		torus
	DC.W		1,2,3
	DC.W		30
	DC.B		0,0,0,1
	DC.W		300

	DC.L		spider2
	DC.W		1,2,3
	DC.W		100
	DC.B		0,0,0,1
	DC.W		200

	DC.L		car
	DC.W		0,2,0
	DC.W		140	
	DC.B		$40,0,0,1
	DC.W		0

	DC.L		vcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$F0
	DC.W		200

	DC.L		rcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		0


FACE	MACRO	
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM

ICOF	MACRO	
	DC.W	\1*4-4,\2*4-4,\3*4-4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM


fildemo:
	DC.W	-45,-15,-20
	DC.W	-45,15,-20
	DC.W	-25,0,-20
	DC.W	-20,-15,-20
	DC.W	-20,0,-20
	DC.W	-20,15,-20
	DC.W	-1,-15,-20
	DC.W	-1,0,-20
	DC.W	-1,15,-20
	DC.W	5,-15,-20
	DC.W	5,15,-20
	DC.W	15,0,-20
	DC.W	25,-15,-20
	DC.W	25,15,-20
	DC.W	30,15,-20
	DC.W	30,-15,-20
	DC.W	50,15,-20
	DC.W	50,-15,-20
	DC.W	0

	DC.B	1,0,1,2,2,0
	DC.B	3,5,3,6,4,7,5,8
	DC.B	9,10,9,11,11,12,12,13
	DC.B	14,16,15,17,14,15,16,17
	DC.B	0
	EVEN

filalgernon:
	DC.W	-85,-20,0
	DC.W	-80,0,0
	DC.W	-75,15,0
	DC.W	-70,0,0
	DC.W	-65,-20,0
	DC.W	-60,15,0
	DC.W	-60,-20,0
	DC.W	-45,-20,0
	DC.W	-40,15,0
	DC.W	-40,-20,0
	DC.W	-25,15,0
	DC.W	-25,0,0
	DC.W	-25,-20,0
	DC.W	-10,15,0
	DC.W	-10,0,0
	DC.W	-10,-20,0
	DC.W	5,15,0
	DC.W	5,0,0
	DC.W	5,-20,0
	DC.W	10,15,0
	DC.W	10,0,0
	DC.W	10,-20,0
	DC.W	25,15,0
	DC.W	25,0,0
	DC.W	25,-20,0
	DC.W    30,15,0
	DC.W	30,-20,0
	DC.W    45,15,0
	DC.W	45,-20,0
	DC.W	50,15,0
	DC.W	50,-20,0
	DC.W	65,15,0
	DC.W	65,-20,0
	DC.W	70,15,0
	DC.W	70,-20,0
	DC.W	85,15,0
	DC.W	85,-20,0

	
	DC.W	0
	
	DC.B	2,0,2,4,1,3			;A
	DC.B	5,6,6,7				;L
	DC.B	8,9,8,10,9,12,11,12		;G
	DC.B	13,16,14,17,15,18,13,15		;E
	DC.B	19,22,20,23,21,19,22,23,20,24	;R
	DC.B	25,26,27,28,25,28		;N
	DC.B	29,30,31,32,29,31,30,32		;O
	DC.B	33,34,35,36,33,36		;N
	DC.B	0
	EVEN


algenon:
	DC.W	-90,20,0
	DC.W	-90,-25,0
	DC.W	90,-25,0
	DC.W	90,20,0
	DC.W	-90,20,-20
	DC.W	-90,-25,-20
	DC.W	90,-25,-20
	DC.W	90,20,-20
	DC.W	0
	
	DC.B	$FF,2,3,0,1,0,0,0,0,0
	DC.W	2*8
	DC.L	fildemo

	DC.B	$FF,4,7,6,5,0,0,0,0,0
	DC.W	2*8
	DC.L	filalgernon

	DC.B	$FF,3,2,6,7,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	
	DC.B	$FF,1,0,4,5,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,1,5,6,2,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,4,0,3,7,0,0,0,0,0
	DC.W	5*8
	DC.L	0
	



	DC.W	0



filcube:
	DC.W	50,50,-50
	DC.W	50,-50,-50
	DC.W	-50,-50,-50
	DC.W	-50,50,-50
	DC.W	50,50,50
	DC.W	50,-50,50
	DC.W	-50,-50,50
	DC.W	-50,50,50
	DC.W	0
	DC.B	1,0,1,2,2,3,3,0
	DC.B	4,5,5,6,6,7,7,4
	DC.B	4,0,5,1,6,2,7,3
	DC.B	0
	EVEN
	
motifa
	DC.W	1,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0
	DC.W	0
	DC.B	2,0,1,0,0
	EVEN



	DC.W	-50,50,0
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	0

	DC.B	$FF,1,0,3,2,0,0,0,0,0
	DC.W	5*8
	DC.L	motifa
	DC.B	$FF,3,0,1,2,0,0,0,0,0
	DC.W	6*8
	DC.L	0

	DC.W	0

spider2:

	DC.L	pspider2
	DC.L	0
	DC.L	spider2

pspider2


	DC.W	-15,40,0
	DC.W	15,40,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-50,-30,-50
	DC.W	-50,-50,-50
	DC.W	50,-30,-50
	DC.W	50,-50,-50
	DC.W	5,-80,-20
	DC.W	-5,-80,-20
	DC.W	-10,40,-10
	DC.W	10,40,-10


	DC.W	0

	DC.L	fspider2


fspider2


;	ailes dessous

	FACE	7,2,11,6,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,10,3,5,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

;       cotes      


	FACE	3,10,9,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	11,2,8,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

;	dessous

	FACE	11,8,9,10,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

;      reacteurs

	FACE	10,0,1,11,-1,-1,-1,-1
	DC.W	1*8
	DC.L	0

	FACE	6,11,1,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	4,0,10,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0



;	dessus
	
	FACE	1,0,3,2,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

;	ailes dessus

	FACE	6,1,2,7,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,0,4,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

;	cockpit

	FACE	2,3,9,8,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	DC.W	-1

spiper2trapppe

	DC.W	-5,30,0
	DC.W	5,30,0
	DC.W	1,-10,0
	DC.W	0

	FACE	2,1,0,-1,-1,-1,-1,-1
	DC.W	1*8
	DC.W	-1
	EVEN


vcube:
	DC.L	pvcube
	DC.L	0
	DC.L	vcube

pvcube

	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0

	DC.L	fvcube

fvcube


        ;faces internes

	FACE	5,1,0,4,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,3,7,4,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	3,2,6,7,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	2,1,5,6,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

	;faces externes

	FACE	5,4,0,1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	2,6,5,1,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

	DC.W	-1					


	even


rcube:
	DC.L	prcube
	DC.L	0
	DC.L	rcube

prcube
	

	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0


	DC.L	frcube


frcube


	;faces externes

	FACE	1,0,3,2,-1,-1,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0

	FACE	5,6,7,4,-1,-1,-1,-1,-1,-1
	DC.W	15*8
	DC.L	0

	FACE	5,4,0,1,-1,-1,-1,-1,-1,-1
	DC.W	14*8
	DC.L	0

	FACE	0,4,7,3,-1,-1,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0

	FACE	3,7,6,2,-1,-1,-1,-1,-1,-1
	DC.W	12*8
	DC.L	0

	FACE	2,6,5,1,-1,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	
	DC.W	-1


	even






ZZCAR	MACRO
	DC.W	\1,\2+100,\3*2/3
	ENDM	
ZZROU	MACRO
	DC.W	\1,\2+100,\3*3/4
	ENDM


cube


car:

	DC.L	pcar
	DC.L	0
	DC.L	car

pcar



	; points flanc droit

	ZZCAR	-60,-25,30
	ZZCAR	-60,-25,10
	ZZCAR	-50,-25,3
	ZZCAR	65,-25,3	
	ZZCAR	65,-25,10
	ZZCAR	30,-25,30

	; points flanc gauche

	ZZCAR	-60,25,30
	ZZCAR	-60,25,10
	ZZCAR	-50,25,3
	ZZCAR	65,25,3
	ZZCAR	65,25,10
	ZZCAR	30,25,30


	; point cockpit droit bas

	ZZCAR	-45,-25,30
	ZZCAR	-25,-25,30
	ZZCAR	-5,-25,30

	; point cockpit gauche bas

	ZZCAR	-45,25,30
	ZZCAR	-25,25,30
	ZZCAR	-5,25,30

	; point cockpit droit haut

	ZZCAR	-30,-20,45
	ZZCAR	-20,-20,45
	ZZCAR	-10,-20,45
	
	; point cockpit gauche haut

	ZZCAR	-30,20,45
	ZZCAR	-20,20,45
	ZZCAR	-10,20,45

	DC.W	0

	DC.L	fcar

fcar

	; coffre arriere

	FACE	6,0,12,15,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0


	; lunette arriere

	FACE	18,21,15,12,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; flanc droit	
	
	FACE	5,0,1,2,3,4,-1,-1
	DC.W	2*8
	DC.L	roued

	; flanc gauche

	FACE	7,6,11,10,9,8,-1,-1
	DC.W	2*8
 	DC.L	roueg

	; capot

	FACE	11,5,4,10,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; calandre

	FACE	10,4,3,9,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; feux arriere

	FACE	1,0,6,7,-1,-1,-1,-1
	DC.W	4*8
	DC.L	feuxar

	; bas de caisse arriäre

	FACE	2,1,7,8,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	
	; pare brise 

	FACE	20,5,11,23,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; pare brise droit

	FACE	20,14,5,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; pare brise gauche

	FACE	23,11,17,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette droit

	FACE	18,12,13,19,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette gauche

	FACE	21,22,16,15,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	; lunette toit

	FACE	18,19,22,21,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	; toit cockpit

	FACE	19,20,23,22,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; cockpit droit

	FACE	13,14,20,19,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; cockpit gauche

	FACE	22,23,17,16,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	; bas de caisse

;	FACE	3,2,8,9,-1,-1,-1,-1
;	DC.W	4*8
;	DC.L	0

	DC.W	-1

feuxar
	ZZCAR	-60,-22,15
	ZZCAR	-60,-22,25
	ZZCAR	-60,22,15
	ZZCAR	-60,22,25
	ZZCAR	-60,-15,15
	ZZCAR	-60,-15,25
	ZZCAR	-60,15,15
	ZZCAR	-60,15,25
	DC.W	0
	FACE	0,1,5,4,-1,-1,-1,-1
	DC.W	7*8
	FACE	6,7,3,2,-1,-1,-1,-1
	DC.W	7*8
	DC.W	-1

	
roued	
	; roues arriere droite

	ZZROU	-45,-25,0
	ZZROU	-35,-25,0
	ZZROU	-30,-25,5
	ZZROU	-30,-25,15
	ZZROU	-35,-25,20
	ZZROU	-45,-25,20
	ZZROU	-50,-25,15
	ZZROU	-50,-25,5

	ZZROU	-45+70,-25,0
	ZZROU	-35+70,-25,0
	ZZROU	-30+70,-25,5
	ZZROU	-30+70,-25,15
	ZZROU	-35+70,-25,20
	ZZROU	-45+70,-25,20
	ZZROU	-50+70,-25,15
	ZZROU	-50+70,-25,5
	DC.W	0

	FACE	0,1,2,3,4,5,6,7
	DC.W	15*8
	FACE	8,9,10,11,12,13,14,15
	DC.W	15*8
	DC.W	-1

roueg	
	; roues arriere droite

	ZZROU	-45,25,0
	ZZROU	-35,25,0
	ZZROU	-30,25,5
	ZZROU	-30,25,15
	ZZROU	-35,25,20
	ZZROU	-45,25,20
	ZZROU	-50,25,15
	ZZROU	-50,25,5

	ZZROU	-45+70,25,0
	ZZROU	-35+70,25,0
	ZZROU	-30+70,25,5
	ZZROU	-30+70,25,15
	ZZROU	-35+70,25,20
	ZZROU	-45+70,25,20
	ZZROU	-50+70,25,15
	ZZROU	-50+70,25,5


	DC.W	0

	FACE	7,6,5,4,3,2,1,0
	DC.W	15*8
	FACE	15,14,13,12,11,10,9,8
	DC.W	15*8
	DC.W	-1


;-----------------------------------------------------
mine:
	DC.L	pmine
	DC.L	0
	DC.L	mine
pmine
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	20,10,0
	DC.W	20,-10,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-20,-10,0
	DC.W	-20,10,0
	DC.W	1,1,30
	DC.W	0
	DC.L	fmine
fmine
	FACE	0,1,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	10*8
	DC.L	0

	FACE	2,3,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	4,5,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	10*8
	DC.L	0

	FACE	6,7,8,-1,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	0,8,1,-1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	2,8,3,-1,-1,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	4,8,5,-1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	6,8,7,-1,-1,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	DC.W	-1


;---------------------------------------------------
torus

	DC.L	ptorus
	DC.L	0
	DC.L	torus

ptorus

	DC.W	-10,20,5
	DC.W	10,20,5
	DC.W	20,10,5
	DC.W	20,-10,5
	DC.W	10,-20,5
	DC.W	-10,-20,5
	DC.W	-20,-10,5
	DC.W	-20,10,5

	DC.W	-15,35,0
	DC.W	15,35,0
	DC.W	35,15,0
	DC.W	35,-15,0
	DC.W	15,-35,0
	DC.W	-15,-35,0
	DC.W	-35,-15,0
	DC.W	-35,15,0

	DC.W	-10,20,-5
	DC.W	10,20,-5
	DC.W	20,10,-5
	DC.W	20,-10,-5
	DC.W	10,-20,-5
	DC.W	-10,-20,-5
	DC.W	-20,-10,-5
	DC.W	-20,10,-5

	DC.W	0

	DC.L	ftorus

ftorus

	;faces internes

	FACE	16,0,7,23,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	17,1,0,16,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	18,2,1,17,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	19,3,2,18,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	20,4,3,19,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	21,5,4,20,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	22,6,5,21,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0
	FACE	23,7,6,22,-1,-1,-1,-1,-1,-1
	DC.W	9*4
	DC.L	0
	FACE	16,0,7,23,-1,-1,-1,-1,-1,-1
	DC.W	8*4
	DC.L	0

	;faces dessus

	FACE	0,1,9,8,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	1,2,10,9,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	2,3,11,10,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	3,4,12,11,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	4,5,13,12,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	5,6,14,13,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	6,7,15,14,-1,-1,-1,-1,-1,-1
	DC.W	4*4
	DC.L	0
	FACE	7,0,8,15,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0

	;faces dessous

	FACE	9,17,16,8,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	10,18,17,9,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	11,19,18,10,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	12,20,19,11,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	13,21,20,12,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	14,22,21,13,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0
	FACE	15,23,22,14,-1,-1,-1,-1,-1,-1
	DC.W	5*4
	DC.L	0
	FACE	8,16,23,15,-1,-1,-1,-1,-1,-1
	DC.W	6*4
	DC.L	0



	DC.W	-1
	

scareface

	DC.L	pscareface
	DC.L	0
	DC.L	scareface
pscareface

	DC.W	-35,10,0
	DC.W	-15,10,0
	DC.W	15,10,0
	DC.W	35,10,0
	DC.W	-25,0,0
	DC.W	-5,0,0
	DC.W	5,0,0
	DC.W	25,0,0
	DC.W	-10,15,5
	DC.W	10,15,5
	DC.W	-35,15,5
	DC.W	35,15,5
	DC.W	-20,30,-5
	DC.W	20,30,-5
	DC.W	-15,-40,-20
	DC.W	15,-40,-20
	DC.W	-40,10,-20
	DC.W	40,10,-20
	DC.W	-15,-40,-40
	DC.W	15,-40,-40
	DC.W	-40,10,-50
	DC.W	40,10,-50

	DC.W	-20,30,-50
	DC.W	20,30,-50
	
	DC.W	-15,5,-60
	DC.W	15,5,-60	

	
	DC.W	0

	DC.L	fscareface

fscareface


	;yeux

	FACE	1,0,4,5,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0
	FACE	2,6,7,3,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0
	FACE	8,1,5,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	9,6,2,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	10,0,1,8,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,11,9,2,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	8,5,6,9,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,10,8,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	13,9,11,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	;face

	FACE	4,14,15,7,-1,-1,-1,-1
	DC.W	5*8
	DC.L	scarebouche

	FACE	4,0,14,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	16,14,0,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0


	FACE	7,15,3,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,15,17,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0

	FACE	16,0,10,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	11,3,17,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	10,12,16,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	11,17,13,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	13,12,8,9,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	14,18,19,15,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	16,20,18,14,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	21,17,15,19,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	22,12,13,23,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	22,20,16,12,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	23,13,17,21,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	22,23,25,24,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	22,24,20,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	23,21,25,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	20,24,18,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	21,19,25,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	24,25,19,18,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	DC.W	$FFFF

scarebouche	
	DC.W	-10,-20,-10
	DC.W	10,-20,-10
	DC.W	10,-30,-15
	DC.W	-10,-30,-15
	DC.W	0
	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	0*8
	DC.W	-1


chiffre8:
	DC.L	pchiffre8
	DC.L	0
	DC.L	chiffre8

pchiffre8

	DC.W	-20,30,0
	DC.W	20,30,0
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	-10,5,0
	DC.W	10,5,0
	DC.W	-20,0,0
	DC.W	20,0,0
	DC.W	-10,-5,0
	DC.W	10,-5,0
	DC.W	-10,-20,0
	DC.W	10,-20,0
	DC.W	-20,-30,0
	DC.W	20,-30,0
	DC.W	0

	DC.L	fchiffre8

fchiffre8

	FACE	1,0,2,3,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	0,6,4,2,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	1,3,5,7,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	5,4,6,8,9,7,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	6,12,10,8,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	9,11,13,7,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0

	FACE	10,12,13,11,-1,-1,-1,-1,-1,-1
	DC.W	9*8
	DC.L	0


	DC.W	-1


;------------------------------------------------------
grille:
	DC.L	pgrille
	DC.L	0
	DC.L	grille

pgrille	

        DC.W    -40,-40,0
        DC.W    -20,-40,0
        DC.W    1,-40,0
        DC.W    20,-40,0
        DC.W    40,-40,0
        DC.W    -40,-20,0
        DC.W    -20,-20,0
        DC.W    1,-20,0
        DC.W    20,-20,0
        DC.W    40,-20,0
        DC.W    -40,0,0
        DC.W    -20,0,0
        DC.W    1,0,0
        DC.W    20,0,0
        DC.W    40,0,0
        DC.W    -40,20,0
        DC.W    -20,20,0
        DC.W    1,20,0
        DC.W    20,20,0
        DC.W    40,20,0
        DC.W    -40,40,0
        DC.W    -20,40,0
        DC.W    1,40,0
        DC.W    20,40,0
        DC.W    40,40,0
        DC.W    0

	DC.L	fgrille

fgrille


        FACE    0,5,6,1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    1,6,7,2,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    2,7,8,3,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    3,8,9,4,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    5,10,11,6,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    6,11,12,7,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    7,12,13,8,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    8,13,14,9,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    10,15,16,11,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    11,16,17,12,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    12,17,18,13,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    13,18,19,14,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    15,20,21,16,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    16,21,22,17,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    17,22,23,18,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    18,23,24,19,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    6,5,0,1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    7,6,1,2,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    8,7,2,3,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    9,8,3,4,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    11,10,5,6,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    12,11,6,7,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    13,12,7,8,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    14,13,8,9,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    16,15,10,11,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    17,16,11,12,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    18,17,12,13,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    19,18,13,14,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    21,20,15,16,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    22,21,16,17,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    23,22,17,18,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    24,23,18,19,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        DC.W    -1


	IFEQ	1

;-----------------------------------------------------------
damier:
        DC.W    -90,-90,0
        DC.W    -70,-90,0
        DC.W    -50,-90,0
        DC.W    -30,-90,0
        DC.W    -10,-90,0
        DC.W    10,-90,0
        DC.W    30,-90,0
        DC.W    50,-90,0
        DC.W    70,-90,0
        DC.W    90,-90,0
        DC.W    -90,-70,0
        DC.W    -70,-70,0
        DC.W    -50,-70,0
        DC.W    -30,-70,0
        DC.W    -10,-70,0
        DC.W    10,-70,0
        DC.W    30,-70,0
        DC.W    50,-70,0
        DC.W    70,-70,0
        DC.W    90,-70,0
        DC.W    -90,-50,0
        DC.W    -70,-50,0
        DC.W    -50,-50,0
        DC.W    -30,-50,0
        DC.W    -10,-50,0
        DC.W    10,-50,0
        DC.W    30,-50,0
        DC.W    50,-50,0
        DC.W    70,-50,0
        DC.W    90,-50,0
        DC.W    -90,-30,0
        DC.W    -70,-30,0
        DC.W    -50,-30,0
        DC.W    -30,-30,0
        DC.W    -10,-30,0
        DC.W    10,-30,0
        DC.W    30,-30,0
        DC.W    50,-30,0
        DC.W    70,-30,0
        DC.W    90,-30,0
        DC.W    -90,-10,0
        DC.W    -70,-10,0
        DC.W    -50,-10,0
        DC.W    -30,-10,0
        DC.W    -10,-10,0
        DC.W    10,-10,0
        DC.W    30,-10,0
        DC.W    50,-10,0
        DC.W    70,-10,0
        DC.W    90,-10,0
        DC.W    -90,10,0
        DC.W    -70,10,0
        DC.W    -50,10,0
        DC.W    -30,10,0
        DC.W    -10,10,0
        DC.W    10,10,0
        DC.W    30,10,0
        DC.W    50,10,0
        DC.W    70,10,0
        DC.W    90,10,0
        DC.W    -90,30,0
        DC.W    -70,30,0
        DC.W    -50,30,0
        DC.W    -30,30,0
        DC.W    -10,30,0
        DC.W    10,30,0
        DC.W    30,30,0
        DC.W    50,30,0
        DC.W    70,30,0
        DC.W    90,30,0
        DC.W    -90,50,0
        DC.W    -70,50,0
        DC.W    -50,50,0
        DC.W    -30,50,0
        DC.W    -10,50,0
        DC.W    10,50,0
        DC.W    30,50,0
        DC.W    50,50,0
        DC.W    70,50,0
        DC.W    90,50,0
        DC.W    -90,70,0
        DC.W    -70,70,0
        DC.W    -50,70,0
        DC.W    -30,70,0
        DC.W    -10,70,0
        DC.W    10,70,0
        DC.W    30,70,0
        DC.W    50,70,0
        DC.W    70,70,0
        DC.W    90,70,0
        DC.W    -90,90,0
        DC.W    -70,90,0
        DC.W    -50,90,0
        DC.W    -30,90,0
        DC.W    -10,90,0
        DC.W    10,90,0
        DC.W    30,90,0
        DC.W    50,90,0
        DC.W    70,90,0
        DC.W    90,90,0
        DC.W    0

        FACE    1,11,12,2,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    3,13,14,4,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    5,15,16,6,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    7,17,18,8,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    10,20,21,11,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    12,22,23,13,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    14,24,25,15,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    16,26,27,17,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    18,28,29,19,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    21,31,32,22,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        FACE    23,33,34,24,-1,-1,-1,-1,-1,-1
        DC.W    8*8
        DC.L    0
        FACE    25,35,36,26,-1,-1,-1,-1,-1,-1
        DC.W    8*10
        DC.L    0
        FACE    27,37,38,28,-1,-1,-1,-1,-1,-1
        DC.W    8*12
        DC.L    0
        FACE    30,40,41,31,-1,-1,-1,-1,-1,-1
        DC.W    8*14
        DC.L    0
        FACE    32,42,43,33,-1,-1,-1,-1,-1,-1
        DC.W    8*1
        DC.L    0
        FACE    34,44,45,35,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    36,46,47,37,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    38,48,49,39,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    41,51,52,42,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    43,53,54,44,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    45,55,56,46,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    47,57,58,48,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    50,60,61,51,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    52,62,63,53,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    54,64,65,55,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        FACE    56,66,67,57,-1,-1,-1,-1,-1,-1
        DC.W    8*8
        DC.L    0
        FACE    58,68,69,59,-1,-1,-1,-1,-1,-1
        DC.W    8*10
        DC.L    0
        FACE    61,71,72,62,-1,-1,-1,-1,-1,-1
        DC.W    8*12
        DC.L    0
        FACE    63,73,74,64,-1,-1,-1,-1,-1,-1
        DC.W    8*14
        DC.L    0
        FACE    65,75,76,66,-1,-1,-1,-1,-1,-1
        DC.W    8*1
        DC.L    0
        FACE    67,77,78,68,-1,-1,-1,-1,-1,-1
        DC.W    8*3
        DC.L    0
        FACE    70,80,81,71,-1,-1,-1,-1,-1,-1
        DC.W    8*5
        DC.L    0
        FACE    72,82,83,73,-1,-1,-1,-1,-1,-1
        DC.W    8*7
        DC.L    0
        FACE    74,84,85,75,-1,-1,-1,-1,-1,-1
        DC.W    8*9
        DC.L    0
        FACE    76,86,87,77,-1,-1,-1,-1,-1,-1
        DC.W    8*11
        DC.L    0
        FACE    78,88,89,79,-1,-1,-1,-1,-1,-1
        DC.W    8*13
        DC.L    0
        FACE    81,91,92,82,-1,-1,-1,-1,-1,-1
        DC.W    8*15
        DC.L    0
        FACE    83,93,94,84,-1,-1,-1,-1,-1,-1
        DC.W    8*2
        DC.L    0
        FACE    85,95,96,86,-1,-1,-1,-1,-1,-1
        DC.W    8*4
        DC.L    0
        FACE    87,97,98,88,-1,-1,-1,-1,-1,-1
        DC.W    8*6
        DC.L    0
        DC.W    -1


	ENDC



palette
	DC.W	$000,$777,$770,$777,$504,$777,$770,$777
	DC.W	$007,$777,$770,$777,$504,$777,$770,$777
palette2:
	DC.W	$000,$FF0,$013,$024,$035,$046,$057,$700
	DC.W	$720,$740,$760,$770,$212,$434,$656,$777

;--------------------------------------------------------

lettrea:

	DC.L	plettrea
	DC.L	0
	DC.L	lettrea

plettrea

	DC.W	-5,20,5
	DC.W	5,20,5
	DC.W	1,10,5
	DC.W	-8,-5,5
	DC.W	8,-5,5
	DC.W	-10,-10,5
	DC.W	10,-10,5
	DC.W	-25,-20,5
	DC.W	-15,-20,5
	DC.W	15,-20,5
	DC.W	25,-20,5

	DC.W	0

	DC.L	flettrea

flettrea

	FACE	0,7,8,1,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	9,10,1,0,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	3,5,6,4,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,1,8,7,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0
	FACE	9,0,1,10,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0
	FACE	3,4,6,5,-1,-1,-1,-1,-1,-1
	DC.W	8*8
	DC.L	0

	DC.W	-1

;-----------------------------------------------------
dalle:
	DC.L	pdalle
	DC.L	0
	DC.L	dalle
pdalle


	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0
	DC.W	0

	DC.L	fdalle

fdalle

	FACE	3,2,1,0,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,1,2,3,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0
	DC.W	$FFFF

;------------------------------------------------------
uncube
	DC.L	puncube
	DC.L	0
	DC.L	uncube
puncube
	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15
	
	DC.W	0

	DC.L	funcube

funcube

	FACE	1,2,6,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0


	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	1,5,4,0,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,5,6,7,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0

	DC.W	-1

;------------------------------------------------------
deuxcube
	DC.L	pdeuxcube
	DC.L	0
	DC.L	deuxcube
pdeuxcube



	DC.W	-40,40,15
	DC.W	-10,40,15
	DC.W	-10,10,15
	DC.W	-40,10,15
	DC.W	-40,40,-15
	DC.W	-10,40,-15
	DC.W	-10,10,-15
	DC.W	-40,10,-15

	DC.W	10,40,15
	DC.W	40,40,15
	DC.W	40,10,15
	DC.W	10,10,15
	DC.W	10,40,-15
	DC.W	40,40,-15
	DC.W	40,10,-15
	DC.W	10,10,-15
	
	DC.W	0
	DC.L	fdeuxcube
fdeuxcube



	FACE	1,2,6,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	8,12,15,11,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0


	FACE	3,2,1,0,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	1,5,4,0,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,4,7,3,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	3,7,6,2,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,5,6,7,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	11,10,9,8,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	9,13,12,8,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	11,15,14,10,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	12,13,14,15,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0
	FACE	9,10,14,13,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0

	DC.W	-1


pyramide
	DC.L	ppyramide
	DC.L	0
	DC.L	pyramide
ppyramide

	DC.W	-30,30,0
	DC.W	30,30,0
	DC.W	30,-30,0
	DC.W	-30,-30,0
	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20
	DC.W	-15,15,30
	DC.W	15,15,30
	DC.W	15,-15,30
	DC.W	-15,-15,30
	DC.W	1,0,60
	DC.W	0
	DC.L	fpyramide

fpyramide

	FACE	7,6,5,4,-1,-1,-1,-1
	DC.W	12*8
	DC.L	0

	FACE	8,9,10,11,-1,-1,-1,-1
	DC.W	13*8
	DC.L	0


	FACE	0,1,2,3,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	12,9,8,-1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	5,1,0,4,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	12,10,9,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	6,2,1,5,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	12,11,10,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	7,3,2,6,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,8,11,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	4,0,3,7,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0


	DC.W	-1


glider2:
	DC.L	pglider2
	DC.L	0
	DC.L	glider2
pglider2	


	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10
	DC.W	0
	DC.L	fglider2
fglider2

	FACE	0,4,5,1,-1,-1,-1,-1
	DC.W	2*8
	DC.L	0
	FACE	0,2,4,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	1,5,3,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,1,7,6,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	0,6,2,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	1,3,7,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	4,2,6,7,3,5,-1,-1
	DC.W	1*8
	DC.L	0
	
	DC.W	-1	

	
DODE	MACRO
	IFEQ	\1
	DC.W	1,\2/6,\3/6
	ELSEIF
	DC.W	\1/6,\2/6,\3/6
	ENDC
	ENDM


dodecaedre
	DC.L	pdodecaedre
	DC.L	0
	DC.L	dodecaedre


pdodecaedre:

	DODE	283,631,390
	DODE	458,631,-149
	DODE	0,631,-482
	DODE	-458,631,-149
	DODE	-283,631,390
	DODE	-458,149,631
	DODE	0,-149,780
	DODE	458,149,631
	DODE	742,-149,241
	DODE	742,149,-241
	DODE	458,-149,-631
	DODE	0,149,-780
	DODE	-458,-149,-631
	DODE	-742,149,-241
	DODE	-742,-149,241
	DODE	-283,-631,-390
	DODE	-458,-631,149
	DODE	0,-631,482
	DODE	458,-631,149
	DODE	283,-631,-390

	DC.W	0

	DC.L	fdodecaedre

fdodecaedre
	FACE	0,1,2,3,4,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	0,4,5,6,7,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	0,7,8,9,1,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	1,9,10,11,2,-1,-1,-1
	DC.W	4*8
	DC.L	0

	FACE	2,11,12,13,3,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	3,13,14,5,4,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	12,15,16,14,13,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	14,16,17,6,5,-1,-1,-1
	DC.W	5*8
	DC.L	0

	FACE	6,17,18,8,7,-1,-1,-1
	DC.W	2*8
	DC.L	0

	FACE	8,18,19,10,9,-1,-1,-1
	DC.W	3*8
	DC.L	0

	FACE	11,10,19,15,12,-1,-1,-1
	DC.W	6*8
	DC.L	0

	FACE	17,16,15,19,18,-1,-1,-1
	DC.W	4*8
	DC.L	0


	DC.W	-1
	
	
	EVEN

helice:
	DC.L	phelice1
	DC.L	phelice3
	DC.L	phelice5
	DC.L	phelice7
	DC.L	phelice9
	DC.L	phelice11
	DC.L	phelice13
	DC.L	phelice15
	DC.L	phelice17
	DC.L	phelice19
	DC.L	phelice21
	DC.L	phelice23
	DC.L	phelice25
	DC.L	phelice27
	DC.L	phelice29
	DC.L	0
	DC.L	helice
phelice1
        DC.W  50,5,0
        DC.W  50,-5,0
        DC.W  5,-50,0
        DC.W  -5,-50,0
        DC.W  -50,-5,0
        DC.W  -50,5,0
        DC.W  -5,50,0
        DC.W  5,50,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice3
        DC.W  49,10,0
        DC.W  50,0,0
        DC.W  10,-49,0
        DC.W  1,-50,0
        DC.W  -49,-10,0
        DC.W  -50,0,0
        DC.W  -10,49,0
        DC.W  1,50,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice5
        DC.W  47,15,0
        DC.W  49,5,0
        DC.W  15,-47,0
        DC.W  5,-49,0
        DC.W  -47,-15,0
        DC.W  -49,-5,0
        DC.W  -15,47,0
        DC.W  -5,49,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice7
        DC.W  46,20,0
        DC.W  49,10,0
        DC.W  20,-46,0
        DC.W  10,-49,0
        DC.W  -46,-20,0
        DC.W  -49,-10,0
        DC.W  -20,46,0
        DC.W  -10,49,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice9
        DC.W  43,24,0
        DC.W  47,15,0
        DC.W  24,-43,0
        DC.W  15,-47,0
        DC.W  -43,-24,0
        DC.W  -47,-15,0
        DC.W  -24,43,0
        DC.W  -15,47,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice11
        DC.W  40,29,0
        DC.W  45,20,0
        DC.W  29,-40,0
        DC.W  20,-45,0
        DC.W  -40,-29,0
        DC.W  -45,-20,0
        DC.W  -29,40,0
        DC.W  -20,45,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice13
        DC.W  37,33,0
        DC.W  43,25,0
        DC.W  33,-37,0
        DC.W  25,-43,0
        DC.W  -37,-33,0
        DC.W  -43,-25,0
        DC.W  -33,37,0
        DC.W  -25,43,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice15
        DC.W  33,37,0
        DC.W  40,29,0
        DC.W  37,-33,0
        DC.W  29,-40,0
        DC.W  -33,-37,0
        DC.W  -40,-29,0
        DC.W  -37,33,0
        DC.W  -29,40,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice17
        DC.W  29,40,0
        DC.W  37,33,0
        DC.W  40,-29,0
        DC.W  33,-37,0
        DC.W  -29,-40,0
        DC.W  -37,-33,0
        DC.W  -40,29,0
        DC.W  -33,37,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice19
        DC.W  25,43,0
        DC.W  33,37,0
        DC.W  43,-25,0
        DC.W  37,-33,0
        DC.W  -25,-43,0
        DC.W  -33,-37,0
        DC.W  -43,25,0
        DC.W  -37,33,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice21
        DC.W  20,45,0
        DC.W  29,40,0
        DC.W  45,-20,0
        DC.W  40,-29,0
        DC.W  -20,-45,0
        DC.W  -29,-40,0
        DC.W  -45,20,0
        DC.W  -40,29,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice23
        DC.W  15,47,0
        DC.W  24,43,0
        DC.W  47,-15,0
        DC.W  43,-24,0
        DC.W  -15,-47,0
        DC.W  -24,-43,0
        DC.W  -47,15,0
        DC.W  -43,24,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice25
        DC.W  10,49,0
        DC.W  20,46,0
        DC.W  49,-10,0
        DC.W  46,-20,0
        DC.W  -10,-49,0
        DC.W  -20,-46,0
        DC.W  -49,10,0
        DC.W  -46,20,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice27
        DC.W  5,49,0
        DC.W  15,47,0
        DC.W  49,-5,0
        DC.W  47,-15,0
        DC.W  -5,-49,0
        DC.W  -15,-47,0
        DC.W  -49,5,0
        DC.W  -47,15,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
phelice29
        DC.W  1,50,0
        DC.W  10,49,0
        DC.W  50,0,0
        DC.W  49,-10,0
        DC.W  1,-50,0
        DC.W  -10,-49,0
        DC.W  -50,0,0
        DC.W  -49,10,0
	DC.W  1,0,0
	DC.W  -10,15,-40
	DC.W  10,15,-40
	DC.W  10,-15,-40
	DC.W  -10,-15,-40
	DC.W  0
	DC.L  fhelice
fhelice:

	;helice interne

	FACE	1,8,0,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	7,8,6,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	5,8,4,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	3,8,2,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0

	;face internes

	FACE	9,8,10,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	11,8,12,-1,-1,-1,-1,-1
	DC.W	4*8
	DC.L	0
	FACE	12,8,9,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0
	FACE	10,8,11,-1,-1,-1,-1,-1
	DC.W	5*8
	DC.L	0



	;helice externe

	FACE	0,8,1,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	6,8,7,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	4,8,5,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0
	FACE	2,8,3,-1,-1,-1,-1,-1
	DC.W	11*8
	DC.L	0


	FACE	9,10,11,12,-1,-1,-1,-1
	DC.W	6*8
	DC.L	0


	DC.W	-1


raie:
        DC.L  praie1
        DC.L  praie2
        DC.L  praie3
        DC.L  praie4
        DC.L  praie5
        DC.L  praie6
        DC.L  praie7
        DC.L  praie8
        DC.L  praie9
        DC.L  praie10
        DC.L  praie11
        DC.L  praie12
        DC.L  praie13
        DC.L  praie14
        DC.L  praie15
        DC.L  praie16
        DC.L  praie17
        DC.L  praie18
        DC.L  praie19
        DC.L  praie20
        DC.L  praie21
        DC.L  praie22
        DC.L  praie23
        DC.L  praie24
        DC.L  0
        DC.L  raie
praie1
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-22
        DC.W  -30,10,-9
        DC.W  -30,-10,-9
        DC.W  30,10,-9
        DC.W  30,-10,-9
        DC.W  50,0,-22
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie2
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-23
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-23
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie3
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-24
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-24
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie4
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-25
        DC.W  -30,10,-7
        DC.W  -30,-10,-7
        DC.W  30,10,-7
        DC.W  30,-10,-7
        DC.W  50,0,-25
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie5
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-24
        DC.W  -30,10,-6
        DC.W  -30,-10,-6
        DC.W  30,10,-6
        DC.W  30,-10,-6
        DC.W  50,0,-24
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie6
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-23
        DC.W  -30,10,-5
        DC.W  -30,-10,-5
        DC.W  30,10,-5
        DC.W  30,-10,-5
        DC.W  50,0,-23
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie7
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-22
        DC.W  -30,10,-4
        DC.W  -30,-10,-4
        DC.W  30,10,-4
        DC.W  30,-10,-4
        DC.W  50,0,-22
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie8
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-20
        DC.W  -30,10,-2
        DC.W  -30,-10,-2
        DC.W  30,10,-2
        DC.W  30,-10,-2
        DC.W  50,0,-20
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie9
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-17
        DC.W  -30,10,-1
        DC.W  -30,-10,-1
        DC.W  30,10,-1
        DC.W  30,-10,-1
        DC.W  50,0,-17
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie10
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-15
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-15
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie11
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-12
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-12
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie12
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-10
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-10
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie13
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-7
        DC.W  -30,10,1
        DC.W  -30,-10,1
        DC.W  30,10,1
        DC.W  30,-10,1
        DC.W  50,0,-7
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie14
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-6
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-6
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie15
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie16
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,0
        DC.W  -30,-10,0
        DC.W  30,10,0
        DC.W  30,-10,0
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie17
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-5
        DC.W  -30,10,-1
        DC.W  -30,-10,-1
        DC.W  30,10,-1
        DC.W  30,-10,-1
        DC.W  50,0,-5
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie18
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-6
        DC.W  -30,10,-2
        DC.W  -30,-10,-2
        DC.W  30,10,-2
        DC.W  30,-10,-2
        DC.W  50,0,-6
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie19
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-7
        DC.W  -30,10,-3
        DC.W  -30,-10,-3
        DC.W  30,10,-3
        DC.W  30,-10,-3
        DC.W  50,0,-7
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie20
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-9
        DC.W  -30,10,-5
        DC.W  -30,-10,-5
        DC.W  30,10,-5
        DC.W  30,-10,-5
        DC.W  50,0,-9
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie21
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-12
        DC.W  -30,10,-6
        DC.W  -30,-10,-6
        DC.W  30,10,-6
        DC.W  30,-10,-6
        DC.W  50,0,-12
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie22
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-14
        DC.W  -30,10,-7
        DC.W  -30,-10,-7
        DC.W  30,10,-7
        DC.W  30,-10,-7
        DC.W  50,0,-14
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie23
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-17
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-17
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie
praie24
        DC.W  -10,20,0
        DC.W  10,20,0
        DC.W  10,-30,0
        DC.W  -10,-30,0
        DC.W  -50,0,-19
        DC.W  -30,10,-8
        DC.W  -30,-10,-8
        DC.W  30,10,-8
        DC.W  30,-10,-8
        DC.W  50,0,-19
        DC.W  1,-25,-10
	DC.W  1,10,-10
	DC.W  1,50,-5
        DC.W  0
        DC.L  fraie


fraie:

	; ailes dessous

	FACE  0,3,6,5,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  7,8,2,1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  5,6,4,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  9,8,7,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0


	; corps


 	FACE  2,3,10,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  10,3,0,11,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  11,1,2,10,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  12,11,0,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  12,1,11,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  1,12,0,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0

	; dessus

	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  0,5,6,3,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  7,1,2,8,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  5,4,6,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  9,7,8,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0





	DC.W  -1


nscarre:
	DC.L	pnscarre
	DC.L	0
	DC.L	nscarre

pnscarre

	DC.W	-10,10,-30
	DC.W	10,10,-30
	DC.W	10,-10,-30
	DC.W	-10,-10,-30

	DC.W	-20,20,-20
	DC.W	20,20,-20
	DC.W	20,-20,-20
	DC.W	-20,-20,-20

	DC.W	-30,30,-10
	DC.W	30,30,-10
	DC.W	30,-30,-10
	DC.W	-30,-30,-10

	DC.W	-40,40,0
	DC.W	40,40,0
	DC.W	40,-40,0
	DC.W	-40,-40,0

	DC.W	-30,30,10
	DC.W	30,30,10
	DC.W	30,-30,10
	DC.W	-30,-30,10

	DC.W	-20,20,20
	DC.W	20,20,20
	DC.W	20,-20,20
	DC.W	-20,-20,20

	DC.W	-10,10,30
	DC.W	10,10,30
	DC.W	10,-10,30
	DC.W	-10,-10,30


	DC.W	0

	DC.L  fnscarre

fnscarre:
	
	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  7,6,5,4,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  11,10,9,8,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  15,14,13,12,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  19,18,17,16,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  23,22,21,20,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  27,26,25,24,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	;faces autre cote

	FACE  24,25,26,27,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	FACE  20,21,22,23,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  16,17,18,19,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  12,13,14,15,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  8,9,10,11,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  4,5,6,7,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  0,1,2,3,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0

	DC.W  -1

interph
        DC.L  pinterph0
        DC.L  pinterph1
        DC.L  pinterph2
        DC.L  pinterph3
        DC.L  pinterph4
        DC.L  pinterph5
        DC.L  pinterph6
        DC.L  pinterph7
        DC.L  pinterph8
        DC.L  pinterph9
        DC.L  pinterph10
        DC.L  pinterph11
        DC.L  pinterph12
        DC.L  pinterph13
        DC.L  pinterph14
        DC.L  pinterph15
        DC.L  pinterph16
        DC.L  pinterph17
        DC.L  pinterph18
        DC.L  pinterph19
        DC.L  pinterph20
        DC.L  pinterph19
        DC.L  pinterph18
        DC.L  pinterph17
        DC.L  pinterph16
        DC.L  pinterph15
        DC.L  pinterph14
        DC.L  pinterph13
        DC.L  pinterph12
        DC.L  pinterph11
        DC.L  pinterph10
        DC.L  pinterph9
        DC.L  pinterph8
        DC.L  pinterph7
        DC.L  pinterph6
        DC.L  pinterph5
        DC.L  pinterph4
        DC.L  pinterph3
        DC.L  pinterph2
        DC.L  pinterph1
        DC.L  0
        DC.L  interph
pinterph0
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,10
        DC.W  20,0,10
        DC.W  0
        DC.L  finterph
pinterph1
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,12
        DC.W  20,0,12
        DC.W  0
        DC.L  finterph
pinterph2
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,14
        DC.W  20,0,14
        DC.W  0
        DC.L  finterph
pinterph3
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,16
        DC.W  20,0,16
        DC.W  0
        DC.L  finterph
pinterph4
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,18
        DC.W  20,0,18
        DC.W  0
        DC.L  finterph
pinterph5
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,20
        DC.W  20,0,20
        DC.W  0
        DC.L  finterph
pinterph6
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,22
        DC.W  20,0,22
        DC.W  0
        DC.L  finterph
pinterph7
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,24
        DC.W  20,0,24
        DC.W  0
        DC.L  finterph
pinterph8
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,26
        DC.W  20,0,26
        DC.W  0
        DC.L  finterph
pinterph9
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,28
        DC.W  20,0,28
        DC.W  0
        DC.L  finterph
pinterph10
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,30
        DC.W  20,0,30
        DC.W  0
        DC.L  finterph
pinterph11
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,32
        DC.W  20,0,32
        DC.W  0
        DC.L  finterph
pinterph12
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,34
        DC.W  20,0,34
        DC.W  0
        DC.L  finterph
pinterph13
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,36
        DC.W  20,0,36
        DC.W  0
        DC.L  finterph
pinterph14
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,38
        DC.W  20,0,38
        DC.W  0
        DC.L  finterph
pinterph15
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,40
        DC.W  20,0,40
        DC.W  0
        DC.L  finterph
pinterph16
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,42
        DC.W  20,0,42
        DC.W  0
        DC.L  finterph
pinterph17
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,44
        DC.W  20,0,44
        DC.W  0
        DC.L  finterph
pinterph18
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,46
        DC.W  20,0,46
        DC.W  0
        DC.L  finterph
pinterph19
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,48
        DC.W  20,0,48
        DC.W  0
        DC.L  finterph
pinterph20
        DC.W  -20,10,10
        DC.W  20,10,10
        DC.W  20,-10,10
        DC.W  -20,-10,10
        DC.W  -30,20,0
        DC.W  30,20,0
        DC.W  30,-20,0
        DC.W  -30,-20,0
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  1,0,10
        DC.W  -20,0,50
        DC.W  20,0,50
        DC.W  0
        DC.L  finterph


finterph:
	FACE  3,2,1,0,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0

	FACE  3,7,6,2,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  1,5,4,0,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0

	FACE  0,4,7,3,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  2,6,5,1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0

	FACE  3,0,8,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0

	FACE  1,2,9,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0


	FACE  10,12,11,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  11,12,10,-1,-1,-1,-1,-1
	DC.W  1*8
	DC.L  0

	FACE  8,0,3,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0

	FACE  9,2,1,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0



	DC.W	-1


icosaedre:
	DC.L	picosaedre
	DC.L	0
	DC.L	icosaedre

picosaedre
	DC.W	89,0,44
	DC.W	27,85,44
	DC.W	-72,52,44
	DC.W	-72,-52,44
	DC.W	27,-85,44
	DC.W	1,0,100
	DC.W	1,0,-100
	DC.W	72,52,-44
	DC.W	-27,85,-44
	DC.W	-89,0,-44
	DC.W	-27,-85,-44
	DC.W	72,-52,-44

	DC.W	0
	DC.L	ficosaedre


ficosaedre:
	ICOF  1,2,6,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0
	ICOF  2,3,6,-1,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0
	ICOF  3,4,6,-1,-1,-1,-1,-1
	DC.W  2*8
	DC.L  0
	ICOF  4,5,6,-1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0
	ICOF  5,1,6,-1,-1,-1,-1,-1
	DC.W  6*8
	DC.L  0
	ICOF  12,1,5,-1,-1,-1,-1,-1
	DC.W  7*8
	DC.L  0
	ICOF  12,8,1,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0
	ICOF  8,2,1,-1,-1,-1,-1,-1
	DC.W  9*8
	DC.L  0
	ICOF  9,2,8,-1,-1,-1,-1,-1
	DC.W  10*8
	DC.L  0
	ICOF  9,3,2,-1,-1,-1,-1,-1
	DC.W  11*8
	DC.L  0
	ICOF  9,10,3,-1,-1,-1,-1,-1
	DC.W  12*8
	DC.L  0
	ICOF  10,4,3,-1,-1,-1,-1,-1
	DC.W  13*8
	DC.L  0
	ICOF  10,11,4,-1,-1,-1,-1,-1
	DC.W  14*8
	DC.L  0
	ICOF  11,5,4,-1,-1,-1,-1,-1
	DC.W  15*8
	DC.L  0
	ICOF  11,12,5,-1,-1,-1,-1,-1
	DC.W  3*8
	DC.L  0
	ICOF  7,8,12,-1,-1,-1,-1,-1
	DC.W  4*8
	DC.L  0
	ICOF  7,9,8,-1,-1,-1,-1,-1
	DC.W  5*8
	DC.L  0
	ICOF  7,10,9,-1,-1,-1,-1,-1
	DC.W  6*8
	DC.L  0
	ICOF  7,11,10,-1,-1,-1,-1,-1
	DC.W  7*8
	DC.L  0
	ICOF  7,12,11,-1,-1,-1,-1,-1
	DC.W  8*8
	DC.L  0

	DC.W  -1















	




************************************************************
    SECTION 	BSS
************************************************************
MATRIX:
	DS.W	9		
PROJETES:
	DS.L	128
PROJETES2:
	DS.L	128
SEGMENTS
	DS.L	128
sys_vbl:
	ds.l	1		;adresse ancienne vbl
sys_rez:
 	ds.w	1		;resolution systäme
sys_palette:
	ds.w	16		;couleurs du systäme
sys_screen:
	ds.l	1		;adresse ecran systäme
sys_scr1:
	ds.l	1		;adresse ecran visualisÇ
sys_scr2:
	ds.l	1		;adresse ecran a visualiser
sys_scr3:
	ds.l	1
sys_scr4:
	ds.l	1
sys_scr5:
	ds.l	1
sys_scr6:
	ds.l	1
bfastcls:
	DS.L	4000
screen2:	
	ds.b	96256+32000*2	;buffer ecran 2
llimit:
	DS.L	CLIPSIZE*2
tlimit
	DS.L	160*2
mlimit
	DS.L	160*2
rlimit
	DS.L	CLIPSIZE*2

userstack:
	ds.l	1
endstack:
	ds.l	1000
mystack:		
	end





