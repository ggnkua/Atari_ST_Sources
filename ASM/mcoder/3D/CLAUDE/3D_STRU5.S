

		output DEMO3D.PRG		

VBL_COUNT	equ	$465		;adresse du compteur VBL
CLIPMAXY	equ	199-11		;199-11
AFFCPU		equ	1
EFFSCR		equ	0     
MUSIQUE		equ	0  		
AFFTEXTE	equ	1
DEBUG		equ	0
COMPTEIMAGE	equ	0
MULS		equ	0		;0= 0 muls
					;1= 4 muls
					;2=14 muls

PCMSAMPLE	equ	1
AKEYBOARD	equ	0

CLIPPING	equ	0



CLIPSIZE	equ	4096




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
off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38 = 26	;rs.l	1	;incr‚ment pour crescendo

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
off2d = 49	;rs.b	1	;volume sonore calcul‚
off2e = 50	;rs.b	1
off3c = 52	;equ	(__RS+1)&-2

;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
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
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
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
; calcul de la note … jouer
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


;------- Convertion au format PCM 8 bits sign‚s -----------
;
;	A0 = adresse de depart
;	D0 = longueur de l'‚chantillon

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

	move	$FFFF8260.W,sys_rez

	*-------------- passage basse resolution ----
	MOVE	#37,-(SP)
	TRAP	#14
	ADDQ	#2,SP

	clr	$FFFF8260.W	

	*------------- adresse de l'ecran -----------    

	move.l	$44E.W,D0
	move.l	D0,sys_screen	sauvegarde

	*------------- detourne division par 0 ------

	lea	RTE(PC),A0
	move.l	A0,$14.W

	
	*------------- adresses ecran 1,2,3 ---------

	move.l	D0,sys_scr1		=adresse ecran visualis‚
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
	lea	palette,A0
	jsr	copy_pal(PC)


	IFEQ	DEBUG

        move.w  #$12,-(SP)    ;neutralise souris
        move.w  #4,-(SP)
        move.w  #3,-(SP)
        trap    #13
        addq    #6,SP


;-------------- sauvegarde des registre du MFP -----------


	lea	savemfp(PC),A0
	move	$100+8*4.W,(A0)+
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

	move.l	sys_vbl,$70.W		restauration vbl systŠme


	lea	savemfp(PC),A0
	move	(A0)+,$100+8*4
	move.b	(A0)+,MFP_IMRA
	move.b	(A0)+,MFP_IMRB
	move.b	(A0)+,MFP_IERA
	move.b	(A0)+,MFP_IERB
	move.b	(A0),MFP_VR


        move    #$08,-(SP)		;r‚active souris
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

	lea	$ffff8800.w,a0
	moveq	#$a,d0
.Loop:	move.b	d0,(a0)
	sf	2(a0)
	dbf	d0,.Loop	
	move.b	#7,(a0)
	st	2(a0)

	move.l	userstack,-(SP)		mode utilisateur
	move	#$20,-(SP)
	trap	#1
	addq	#6,SP
	
bye:
	clr	-(SP)			fin du programme
	move	#$4C,-(SP)	
	trap	#1			
RTE
	not	$FFFF8240.W
	rte

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
KBD_DATA	equ	$FFFFFC02		;registre donn‚e acia

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

		CLR		KBD_NBOCTET	;0 octets … lire

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
                BCLR            #6,MFP_ISRB.W    ;IT trait‚e
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


		;lit la donn‚e du clavier

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
;		CMP		MOUSE_MAXX(PC),D0
;		BLO.S		PASCLIPX
;		SGE		D0
;		EXT		D0
;		AND		MOUSE_MAXX(PC),D0		
PASCLIPX
		MOVE		D0,MOUSEX

		MOVE.B		MOUSEDY(PC),D0
		EXT.W		D0
		ADD		MOUSEY(PC),D0
;		CMP		MOUSE_MAXY(PC),D0
;		BLO.S		PASCLIPY
;		SGE		D0
;		EXT		D0
;		AND		MOUSE_MAXY(PC),D0
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
	MOVE	MOUSEX(PC),OBSX
	MOVE	MOUSEY(PC),OBSY
	ENDC

	jsr	CALCPROJ(PC)

	move.l	animcourante(PC),A3	;lire la prochaine animation
	move.l	(A3)+,D0		;adresse de l'objet


	bne.s	pasfinanim		;c'est la derniŠre image
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
	bra	repeat
pasplus
	cmp.b	#$4A,D0
	bne.s	pasmoins
	subq	#4,DIST
	bra	repeat
pasmoins
	cmp	#500,DIST
	bls.s	passpace

	move.l	objetcourant(PC),A0	;passe objet suivant 
	lea	18(A0),A0
	tst.l	(A0)
	bne.s	pasfbobj
	lea	objets,A0


pasfbobj
	move.l	A0,objetcourant

	move.l	(A0)+,animcourante
	move	(A0)+,VROTX
	move	(A0)+,VROTY
	move	(A0)+,VROTZ
	move.w	(A0)+,DIST

	move.b	(A0)+,D1
	ext.w	D1
	add	D1,D1
	add	D1,D1
	move	D1,ROTX

	move.b	(A0)+,D1
	ext.w	D1
	add	D1,D1
	add	D1,D1
	move	D1,ROTY

	move.b	(A0)+,D1
	ext.w	D1
	add	D1,D1
	add	D1,D1
	move	D1,ROTZ

	move.b	(A0)+,D1
	ext.w	D1
	move	D1,VDIST

	move	(A0),cptwaiting

	bra	repeat
passpace

	IFEQ	AKEYBOARD

	cmp.b	#$F9,MOUSEK

	ENDC


	cmp.b	#$39,$FFFFFC02.W

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

;	NOT	color1
;	MOVE	color1(PC),$FFFF8242.W

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

	tst.b	cptwaiting
	bgt.s	noincdist

	MOVE	VDIST(PC),D0
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
	DC.W	10000
cursoroffset
	DC.L	160*(199-9)
ptrtext
	DC.L	textcursor
textcursor
	incbin	'TEXTE.BIN'
	DC.B	0
	EVEN


*****************************************************************
*								*
*	routine d'affichage de polygones convexes               *
*	avec clipping et tramage			        *
*							        *
*	- calcul des droites dans une table 		        *
*	- remplissage par movem.l			        *
*	- tramage 16 couleurs				        *
*	- clipping automatique en X				*
*								*
*								*
* APPEL : en mode superviseur obligatoire			*
*								*
*								*
* A6 -> ADRESSE DES DATAS 	(des points projetes)		*
* D6 -> NOMBRE DE POINTS  	(du polygone)			*
* D7 -> COULEURS * 8            (ATTENTION)			*
*								*
*								*
*****************************************************************

;------------- d‚finition des registres -------------------------

MINY		equr		D6      ;r‚serv‚s dans tous le calcul
MAXY		equr		D7	
PTRTABLE	equr		A0	;pointeur table des MINX-MAXX
ECRAN		equr		A1	;adresse ecran

;------------- registres pour calcul lignes ---------------------

XA		equr		D0	;extremit‚s de la droite
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


;-------------- calcul et clipping d'une ligne verticale ---------------

CALCRETOUR2
		REPT	200
		MOVE.W	XA,(PTRY)+	;mise en place 2 nouveaux points
		ENDR
RETOURVERT
		JMP	(RETOUR)	;ligne verticale invisible
VERTLINE 
		CMP	#CLIPMAXY,YA	;clipping
		BLS.S	YASUPZERO
		BGT.S	RETOURVERT
		MOVEQ	#0,YA
YASUPZERO
		CMP	#CLIPMAXY,YB
		BLS.S	YBINFMAX
		BLT.S	RETOURVERT
		MOVE	#CLIPMAXY,YB
YBINFMAX		
		CMP	MAXY,YB		;tester maximum
		BLE.S	.PASMAXIMUM
		MOVE	YB,MAXY
.PASMAXIMUM
		CMP	MINY,YA		;tester minimum
		BGE.S	.PASMINIMUM
		move	YA,MINY
.PASMINIMUM
		SUB	YA,YB		;YB=DY
		ADD	YA,YA		
		ADD	YA,PTRY		;DEBUT TABLE

		ADD	YB,YB		;DY*2
		NEG	YB
;		ADD	#CALCRETOUR-CALCRETOUR2-2,YB
		JMP	RETOURVERT-2(PC,YB.W)

CALCRETOUR				;fin du calcul des points
		JMP	(RETOUR)

;LASTX:	DC.W	0
;-------------- d‚but calcul des points d'une ligne -----------------

CALCLINE:
		LEA	TABLEYMAX(PC),PTRY
		CMP	YA,YB		;c'est un ligne montante ?
		BEQ.S	CALCRETOUR	;ligne horizontale -> fin

		BGE.S	YBSUPYA

		EXG	XA,XB		;‚change les points
		EXG	YA,YB
		LEA	400(PTRY),PTRY  ;c'est une ligne montante
YBSUPYA
;	MOVE	XB,LASTX

		SUB	XA,XB		;DX		

		BEQ.S	VERTLINE	;c'est une ligne verticale


		MOVE	YB,REGDATA	;pr‚pare calcul du DY
		SUB	YA,REGDATA	;DY

		EXT.L	XB		;calcul de la pente
		ASL.L	#4,XB		;DX*16 (et *8)
		DIVS	REGDATA,XB	;divise par DY

;		BVC.S	.NODEBORDE	;controle d‚bordement
;		ADD	#$70,$ffff8240.w
;.NODEBORDE

		EXT.L	XB		;extention du r‚sultat
		
		CMP	#CLIPMAXY,YA	;clipping haut
		BLS.S	.YASUP0
		BGT.S	CALCRETOUR	;ligne invisible
		MULS	XB,YA		;clipping
		LSR.L	#4,YA		;divise par 16
		SUB	YA,XA		;addition … XA
		MOVEQ	#0,YA		;YA=0
		MOVE	YB,REGDATA	;nombre de ligne=YB
.YASUP0
		CMP	#CLIPMAXY,YB
		BLS.S	.YBINFMAX
		BLT.S	CALCRETOUR
		MOVE	#CLIPMAXY,YB	;moins de lignes
		MOVE	YB,REGDATA	;
		SUB	YA,REGDATA	;calcul DY
.YBINFMAX		


;------------ mise a jour des maximums et minimum ----------

		CMP	MAXY,YB		;tester maximum
		BLE.S	PASMAXIMUM
		MOVE	YB,MAXY
PASMAXIMUM
		CMP	MINY,YA		;tester minimum
		BGE.S	PASMINIMUM
		MOVE	YA,MINY
PASMINIMUM

		ADD	YA,YA		 ;adresse tableau lignes
		ADD	YA,PTRY

		ADD	REGDATA,REGDATA  ;offset pour le saut
		ADD	REGDATA,REGDATA
		NEG	REGDATA

		SWAP	XB
		SWAP	XA
		ASR.L	#4,XB

		MOVE	XB,XA
		BEQ.S	LINEENTIER	;coef de pente entier
;		ADD	#$8000,XA	;ajout de 0.5
		SWAP	XA
		SWAP	XB

		ADDQ	#4,XA

		JMP	(JMPLINE,REGDATA.W)


;---------- cas d'une ligne … coefficient entier -----------
	
LINEENTIER:	
		SWAP	XA
		SWAP	XB
		ADD	#.LINE2-.LINE1,REGDATA
		JMP	.LINE1(PC,REGDATA.W)
.LINE1
		REPT	200-1
		MOVE	XA,(PTRY)+	;stocke point
		ADD	XB,XA		;calcul avec coef entier
		ENDR
.LINE2
		MOVE	XA,(PTRY)	;plot dernier point 
		JMP	(RETOUR)	;fin de calcul

;-------------- cas d'une droite coeficient fractionnaire ----

		REPT	200-1
		MOVE	XA,(PTRY)+	;stocke point 
		ADDX.L	XB,XA		;ajout pente
		ENDR
AJMPLINE
		MOVE	XA,(PTRY)	;stocke dernier points

;	MOVE	LASTX,XB
;	EOR	XB,XA
;	AND	#-8,XA
;	BEQ.S	.GOODX
;	ADDQ	#7,$FFFF8240.W
;.GOODX

		JMP	(RETOUR)	;fin calcul


REG1		equr		D0
REG2		equr		D1
REG3		equr		D2
X1		equr		D3
OFFGAU		equr		D4
X0		equr		D5	
OFFDRO		equr		D6

REG4		equr		A2
PTRTABLE2	equr		A2

REG5		equr		A3
REG6		equr		A4
PTRCLIPX	equr		A5
LECRAN		equr		A6


POLYGONE
		SWAP	MAXY			;mise … l'ecart du nombre de
		SWAP	MINY			;points et couleur

		CLR	MAXY			;maxy=0
		MOVE	#CLIPMAXY,MINY		;miny=y maximum

		SWAP	MINY			;miny est compteur de points

		move.l	PTRSEGMENT,COPPTRSEGMENT
		LEA	LRETJMP(PC),RETOUR	;adresse de retour
		LEA	CALCLINE(PC),JMP	;adresse du calcul de droite
		LEA	AJMPLINE(PC),JMPLINE
		SUBQ	#1,MINY			;un point en moins
REPLINE
		MOVEM	(PTRSEGMENT),XA/YA/XB/YB ;lecture des points
		ADDQ	#4,PTRSEGMENT		 ;passe droite suivante
		SWAP	MINY			 ;sauve compteur
		JMP	(JMP)			 ;calcul des points
LRETJMP
		SWAP	MINY			 ;restore compteur
;		DBF	MINY,REPLINE
		SUBQ	#1,MINY			 ;un point de moins
		BNE.S   REPLINE			 ;repeter...
		MOVE	(PTRSEGMENT)+,XA	 ;derniŠre droite
		MOVE	(PTRSEGMENT),YA
		MOVE	(COPPTRSEGMENT)+,XB
		MOVE	(COPPTRSEGMENT),YB
		LEA	DRAWPOLY16COLOR(PC),RETOUR
		SWAP	MINY 
		JMP	(JMP)


;------------- remplissage du polygone -----------------------

NOPOLY
		RTS

MACRO16		MACRO
		MOVE.L	-(ECRAN),OFFGAU
		EOR.L	REG2,OFFGAU
		AND.L	X1,OFFGAU
		EOR.L	OFFGAU,(ECRAN)
		MOVE.L	-(ECRAN),OFFGAU
		EOR.L	REG1,OFFGAU
		AND.L	X1,OFFGAU
		EOR.L	OFFGAU,(ECRAN)
		ENDM



DRAWPOLY16COLOR:
		SUB	MINY,MAXY		;calcul hauteur du polyg
		BLE.S	NOPOLY			;si non affich‚ alors fin

		SWAP	MAXY			;lecture de la couleur

		TST	MAXY

		BMI	DRAWONEPLANE		;routine 1 plan

		ADD	MAXY,MAXY

		BMI	DRAWTRAME16		;tramage 16 couleurs

		LEA	TABLEYMAX(PC),PTRTABLE
		MOVEM.L	COLORS-TABLEYMAX(PTRTABLE,MAXY.W),REG1/REG2

		SWAP	MAXY
		ADD	MINY,MINY		
		ADD	MINY,PTRTABLE		

		LEA	MULS160(PC),PTRCLIPX
		MOVE.L	sys_scr6,LECRAN
		ADD	(PTRCLIPX,MINY.W),LECRAN


		MOVE.L	REG1,REG3		;charge reg couleur
		MOVE.L	REG2,REG4
		MOVE.L	REG1,REG5
		MOVE.L	REG2,REG6

		LEA	MLIMIT,PTRCLIPX

		BRA.S	DLREP16BRA2
DLREP16
		MACRO16
DLREP16BRA
		LEA	160(LECRAN),LECRAN		;place ici pour
DLREP16BRA2
		MOVE.L	LECRAN,ECRAN			;reduire MACRO 22

		MOVEQ	#-8,X0
		AND	(PTRTABLE)+,X0
		MOVEM.L	(PTRCLIPX,X0.W),X0/OFFDRO	;X0
		ADD	OFFDRO,ECRAN

		MOVEQ	#-8,X1
		AND	400-2(PTRTABLE),X1		;X1
		MOVEM.L	(PTRCLIPX,X1.W),X1/OFFGAU

		SUB	OFFGAU,OFFDRO
		BLE.S	ONELONG

		MOVE.L	(ECRAN),OFFGAU		;masque 2 mots
		EOR.L	REG2,OFFGAU
		AND.L	X0,OFFGAU
		EOR.L	REG2,OFFGAU
		MOVE.L	OFFGAU,(ECRAN)

		MOVE.L	-(ECRAN),OFFGAU		;masque 2 mots
		EOR.L	REG1,OFFGAU
		AND.L	X0,OFFGAU
		EOR.L	REG1,OFFGAU
		MOVE.L	OFFGAU,(ECRAN)

		ADD	OFFDRO,OFFDRO
		ADD	OFFDRO,OFFDRO
 		JMP	FFILL0-32(PC,OFFDRO.W)		;appel transfert par movem
ONELONG
		BNE.S	LSUIV				;a enlever
		EOR.L	X0,X1
		MOVE.L	-(ECRAN),OFFGAU			;perte 2 cycles
		EOR.L	REG1,OFFGAU
		AND.L	X1,OFFGAU
		EOR.L	OFFGAU,(ECRAN)+
		MOVE.L	(ECRAN),OFFGAU
		EOR.L	REG2,OFFGAU
		AND.L	X1,OFFGAU
		EOR.L	OFFGAU,(ECRAN)
LSUIV
		DBF	MAXY,DLREP16BRA
		RTS
FFILL0
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	10 
FFILL1
		MOVE.L	REG2,-(ECRAN)	;bof...
		MOVE.L	REG1,-(ECRAN)
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	6
FFILL2
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	6
FFILL3
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	6
FFILL4						 
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L REG1/REG2,-(ECRAN)
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	2
FFILL5
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		MACRO16
		RTS
		DS.B	2
FFILL6
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
FFILL6BRA
		MACRO16
		RTS
		DS.B	2
FFILL7
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILL6BRA
		DS.B	32-18
FFILL8
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILL6BRA
		DS.B	32-18
FFILL9	
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILL6BRA
		DS.B	32-18
FFILL10
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L REG1/REG2,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA	FFILLFIN
		DS.B	32-24
FFILL11
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA	FFILLFIN
		DS.B	32-24
FFILL12
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA	FFILLFIN
		DS.B	32-24
FFILL13
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA	FFILLFIN
		DS.B	32-28
FFILL14
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA	FFILLFIN
		DS.B	32-28
FFILL15
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILLFIN
		DS.B	32-26
FFILL16
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILLFIN
		DS.B	32-30
FFILL17
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4,-(ECRAN)
		DBF	MAXY,DLREP16
		BRA.S	FFILLFIN
		DS.B	32-30
FFILL18
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		MOVEM.L	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		DBF	MAXY,DLREP16
FFILLFIN:
		MACRO16
		RTS

;--------------- routine polygone 4 plans avec trame ---------------

DRAWTRAME16
		RTS


;------------- routine affichage de polygone 1 plan ------------------

DRAWONEPLANE:
		LEA	TABLEYMAX(PC),PTRTABLE		;adresse table
		ADD	MINY,MINY		
		ADD	MINY,PTRTABLE			;pointe table des X
		LEA	400(PTRTABLE),PTRTABLE2

		LEA	MULS160PL(PC),PTRCLIPX
		MOVE.L	sys_scr6,LECRAN
		ADD	(PTRCLIPX,MINY.W),LECRAN	;pointe ligne ecran
		MOVEQ	#$F,REG2			;decalage plan no
		AND	MAXY,REG2
		ADD	REG2,LECRAN

		ADD	MAXY,MAXY		
		BVC	ONEPLANETRAME			;un plan tram‚

		SWAP	MAXY				;recupere nombre de lignes

		MOVEQ	#-1,REG1			;pattern $FFFF

		LEA	MLIMIT+2,PTRCLIPX		;table clipping X 
DLREP1
		MOVEQ	#-8,X0				
		AND	(PTRTABLE)+,X0
		MOVE.L	(PTRCLIPX,X0.W),X0	

		MOVEQ	#-8,X1
		AND	(PTRTABLE2)+,X1
		MOVE.L	(PTRCLIPX,X1.W),X1	

		SUB	X0,X1
		BGE.S	ONELONG1

		MOVE.L	LECRAN,ECRAN
		ADD	X0,X0
		ADD	X0,ECRAN
		SWAP	X0
		NOT	X0
		OR	X0,(ECRAN)
		JMP	FFILLPLAN+4(PC,X1.W)
ONELONG1
		BNE.S	LSUIV1			
		ADD	X0,X0
		EOR.L	X0,X1		;gain 2 swap
		SWAP	X1
 		OR	X1,(LECRAN,X0.W)
LSUIV1		
		LEA	160(LECRAN),LECRAN
		DBF	MAXY,DLREP1
		RTS

CPT		SET	-18*8
		REPT	18
		MOVE	REG1,CPT(ECRAN)
CPT		SET	CPT+8
		ENDR
FFILLPLAN
		ADD	X1,X1
		ADD	X1,ECRAN
		SWAP	X1
		OR	X1,(ECRAN)	
		LEA	160(LECRAN),LECRAN
FDLREP1
		DBF	MAXY,DLREP1
		RTS

;---------------- routine polygone trame 1 plan -----------------

ONEPLANETRAME:
		SWAP	MAXY				;recupere nombre de lignes
		MOVE.L	#$BBBBEEEE,REG1
		BTST	#1,MINY
		BEQ.S	TRAMEPAIR
		SWAP 	REG1
TRAMEPAIR
		LEA	MLIMIT+2,PTRCLIPX		;table clipping X 
EDLREP1
		MOVEQ	#-8,X0				
		AND	(PTRTABLE)+,X0
		MOVE.L	(PTRCLIPX,X0.W),X0	

		MOVEQ	#-8,X1
		AND	(PTRTABLE2)+,X1
		MOVE.L	(PTRCLIPX,X1.W),X1	

		SUB	X0,X1
		BGE.S	EONELONG1

		MOVE.L	LECRAN,ECRAN
		ADD	X0,X0
		ADD	X0,ECRAN
		SWAP	X0
		NOT	X0
		AND	REG1,X0
		OR	X0,(ECRAN)
		JMP	EFFILLPLAN+4(PC,X1.W)
EONELONG1
		BNE.S	ELSUIV1			
		ADD	X0,X0
		EOR.L	X0,X1		;gain 2 swap
		SWAP	X1
		AND	REG1,X1
 		OR	X1,(LECRAN,X0.W)
ELSUIV1		
		SWAP	REG1
		LEA	160(LECRAN),LECRAN
		DBF	MAXY,EDLREP1
		RTS

CPT		SET	-18*8
		REPT	18
		MOVE	REG1,CPT(ECRAN)
CPT		SET	CPT+8
		ENDR
EFFILLPLAN
		ADD	X1,X1
		ADD	X1,ECRAN
		SWAP	X1
		AND	REG1,X1
		OR	X1,(ECRAN)	
		LEA	160(LECRAN),LECRAN
EFDLREP1
		SWAP	REG1
		DBF	MAXY,EDLREP1
		RTS


MULS160:
CPT		SET	4
		REPT	200
		DC.W	CPT
CPT		SET	CPT+160
		ENDR				
MULS160PL:
		INCBIN	'MULS160.BIN'
COLORS:
		DC.L	$00000000,$00000000
		DC.L	$FFFF0000,$00000000
		DC.L	$0000FFFF,$00000000
		DC.L	$FFFFFFFF,$00000000
		DC.L	$00000000,$FFFF0000
		DC.L	$FFFF0000,$FFFF0000
		DC.L	$0000FFFF,$FFFF0000
		DC.L	$FFFFFFFF,$FFFF0000
		DC.L	$00000000,$0000FFFF
		DC.L	$FFFF0000,$0000FFFF
		DC.L	$0000FFFF,$0000FFFF
		DC.L	$FFFFFFFF,$0000FFFF
		DC.L	$00000000,$FFFFFFFF
		DC.L	$FFFF0000,$FFFFFFFF
		DC.L	$0000FFFF,$FFFFFFFF
		DC.L	$FFFFFFFF,$FFFFFFFF




*****************************************************************
*             INITIALISATION DE LA TABLE DE CLIPPING EN X 	*
*			   DES POLYGONES                        *
*---------------------------------------------------------------*
*	Attention : Cette routine est scratch‚e d‚s que des	*
*	polygones sont affiches					*
*****************************************************************

TABLEYMAX:	

INITPOLY:
	LEA		LLIMIT,A0		;table limites gauches
	MOVE		#CLIPSIZE-1,D0		;taille limite gauche
RRLIMIT
	MOVE.L		#-1,(A0)+		;remplissage
	CLR.L		(A0)+			;offset=0
	DBF		D0,RRLIMIT		;dernier ?

	MOVEQ		#0,D0			;compteur pixel
	CLR.L		D1
	MOVE		#$FFFF,D1		;masque droit
	MOVEQ		#0,D2
	MOVEQ		#0,D3
RCLIMIT
	MOVE		D1,(A0)+		;stocke trame1
	MOVE		D1,(A0)+		;2 fois

	MOVE		D3,(A0)+		;stocke offset
	MOVE		D2,(A0)+

	LSR.L		#1,D1			;decalage masque

	BNE.S		.2
	MOVE		#$FFFF,D1		;mise en place masque
	ADDQ		#4,D3			;decalage offset 4
	ADDQ		#8,D2			;decalage offset 8
.2

	ADDQ		#1,D0			;un pixel de plus
	CMP		#319,D0			;pixel 319 ?
	BLE.S		RCLIMIT			;non, continuer


	MOVE		#CLIPSIZE-1,D0
RLLIMIT
	CLR.L		(A0)+			;init limite droite
	MOVE.L		#$004C0098,(A0)+
	DBF		D0,RLLIMIT
	RTS
FTABLEYMAX
	DS.B		800-(FTABLEYMAX-TABLEYMAX)




CALCPROJ:
	not	$ffff8240.w
	IFEQ	MULS-2

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

	ENDC
	IFEQ	MULS-1
Matrix_pointer	equr	a0
Trigo_table	equr	a1

X_angle		equr	d4
Y_angle		equr	d5
Z_angle		equr	d6
Trigo_mask	equr	d7

	LEA	MATRIX(PC),Matrix_pointer
	LEA	SINCOS2(PC),Trigo_table

;	MOVE	VROTX(PC),D0
	ADD	#4,ROTX
;	MOVE	VROTY(PC),D0
	ADD	#8,ROTY
;	MOVE	VROTZ(PC),D0
	ADD	#12,ROTZ

	move	ROTX(PC),X_angle
	move	ROTY(PC),Y_angle
	move	ROTZ(PC),Z_angle
	MOVE	#$3FF*4,Trigo_mask

	MOVE	Y_angle,D0		;Y
	MOVE	D0,D1
	ADD	Z_angle,D1		;Y+Z
	SUB	Z_angle,D0		;Y-Z
	AND	Trigo_mask,D0
	AND	Trigo_mask,D1
	MOVE.L	0(Trigo_table,D0),D0		;S(Y-Z)|C(Y-Z)/2
	MOVE.L	0(Trigo_table,D1),D1		;S(Y+Z)|C(Y+Z)/2

	ADD	D1,D0
	MOVE	D0,(Matrix_pointer)+		;(C(Y+Z)+C(Y-Z))/2
	;OK

;1
	SWAP	D0
	SWAP	D1
	SUB	D1,D0			
	MOVE	D0,(Matrix_pointer)+		;(S(Y+Z)-S(Y-Z))/2
	;OK

;2
	AND	Trigo_mask,Y_angle
	MOVE	0(Trigo_table,Y_angle),D0
	ADD	D0,D0
	NEG	D0
	MOVE	D0,(Matrix_pointer)+		;-S(Y)
	;OK

	move	X_angle,D0		;X+Y
	MOVE	D0,D1
	ADD	Y_angle,D0		;X+Y
	SUB	Y_angle,D1		;X-Y
	AND	Trigo_mask,D0
	AND	Trigo_mask,D1
	MOVE.l	0(Trigo_table,D0),D0
	MOVE.l	0(Trigo_table,D1),D1
	move	d0,d2
	sub	d1,d2
	and	Trigo_mask,Z_angle
	move	0(Trigo_table,Z_angle),d3
	muls	d2,d3
	muls	2(Trigo_table,Z_angle),d2
	swap	d0
	swap	d1
	add	d1,d0
	neg	d0
	add.l	d2,d2
	add.l	d2,d2
	swap	d2
	move	d2,(Matrix_pointer)+
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move	d3,(Matrix_pointer)+
	move	d0,(Matrix_pointer)+
	move	X_angle,d0
	move	d0,d1
	add	Z_angle,d0
	sub	Z_angle,d1
	and	Trigo_mask,d0
	and	Trigo_mask,d1
	move.l	0(Trigo_table,d0),d0
	move.l	0(Trigo_table,d1),d1
	add	d1,d0
	add	d0,-4(Matrix_pointer)
	swap	d0
	swap	d1
	sub	d1,d0
	sub	d0,-6(Matrix_pointer)

	move	X_angle,D0		;X+Y
	MOVE	D0,D1
	ADD	Y_angle,D0		;X+Y
	SUB	Y_angle,D1		;X-Y
	AND	Trigo_mask,D0
	AND	Trigo_mask,D1
	MOVE.l	0(Trigo_table,D0),D0
	MOVE.l	0(Trigo_table,D1),D1
	add	d1,d0
	swap	d0
	swap	d1
	move	d0,d2
	sub	d1,d2
	move	0(Trigo_table,Z_angle),d3
	muls	d2,d3
	muls	2(Trigo_table,Z_angle),d2
	swap	d0
	add.l	d2,d2
	add.l	d2,d2
	swap	d2
	move	d2,(Matrix_pointer)+
	add.l	d3,d3
	add.l	d3,d3
	swap	d3
	move	d3,(Matrix_pointer)+
	move	d0,(Matrix_pointer)+
	move	X_angle,d0
	move	d0,d1
	add	Z_angle,d0
	sub	Z_angle,d1
	and	Trigo_mask,d0
	and	Trigo_mask,d1
	move.l	0(Trigo_table,d0),d0
	move.l	0(Trigo_table,d1),d1
	sub	d1,d0
	sub	d0,-6(Matrix_pointer)
	swap	d0
	swap	d1
	add	d1,d0
	add	d0,-4(Matrix_pointer)
	ENDC
	IFEQ	MULS
Matrix_pointer	equr	a0
Trigo_table1	equr	a1
Trigo_table2	equr	a2

Save1		equr	a3
Save2		equr	a4
Save3		equr	a5
Save4		equr	a6
Save5		equr	d3
Save6		equr	a2 (!)

X_angle		equr	d4
Y_angle		equr	d5
Z_angle		equr	d6
Trigo_mask	equr	d7

	LEA	MATRIX(PC),Matrix_pointer
	LEA	SINCOS2(PC),Trigo_table1
	LEA	$1000(Trigo_table1),Trigo_table2

;	MOVE	VROTX(PC),D0
	ADD	#4,ROTX
;	MOVE	VROTY(PC),D0
	ADD	#8,ROTY
;	MOVE	VROTZ(PC),D0
	ADD	#12,ROTZ

	move	ROTX(PC),X_angle
	move	ROTY(PC),Y_angle
	move	ROTZ(PC),Z_angle
	MOVE	#$3FF*4,Trigo_mask

	MOVE	Y_angle,D0		;Y
	MOVE	D0,D1
	ADD	Z_angle,D1		;Y+Z
	SUB	Z_angle,D0		;Y-Z
	AND	Trigo_mask,D1
	AND	Trigo_mask,D0
	MOVE.L	0(Trigo_table1,D0),D0		;S(Y-Z)|C(Y-Z)/2
	MOVE.L	0(Trigo_table1,D1),D1		;S(Y+Z)|C(Y+Z)/2

	ADD	D1,D0
	MOVE	D0,(Matrix_pointer)+		;(C(Y+Z)+C(Y-Z))/2
	;OK

;1
	SWAP	D0
	SWAP	D1
	SUB	D1,D0			
	MOVE	D0,(Matrix_pointer)+		;(S(Y+Z)-S(Y-Z))/2
	;OK

;2
	MOVE	Y_angle,D0
	AND	Trigo_mask,D0
	MOVE	(Trigo_table1,D0.W),D0
	ADD	D0,D0
	NEG	D0
	MOVE	D0,(Matrix_pointer)+		;-S(Y)
	;OK

;3
	move	X_angle,D0		;X+Y
	ADD	Y_angle,D0		;X+Y
	MOVE	D0,D1
	ADD	Z_angle,D0		;X+Y+Z
	SUB	Z_angle,D1		;X+Y-Z
	AND	Trigo_mask,D0
	AND	Trigo_mask,D1

	MOVE.L	0(Trigo_table2,D0),D0		;S(X+Y+Z)/4|C(X+Y+Z)/4
	MOVE.L	0(Trigo_table2,D1),D1		;S(X+Y-Z)/4|C(X+Y-Z)/4
	MOVE.L	D0,Save1
	MOVE.L	D1,Save2

	ADD	D1,D0		;cos	;C(X+Y+Z)+C(X+Y-Z)/4
	SWAP	D0
	SWAP	D1
	SUB	D1,D0		;sin	;C(X+Y+Z)+C(X+Y-Z)|S(X+Y+Z)-S(X+Y-Z)/4

	MOVE	X_angle,D1
	SUB	Y_angle,D1
	MOVE	D1,D2
	ADD	Z_angle,D1		;X-Y+Z
	SUB	Z_angle,D2		;X-Y-Z
	AND	Trigo_mask,D1
	AND	Trigo_mask,D2
	MOVE.L	0(Trigo_table2,D1),D1		;S(X-Y+Z)|C(X-Y+Z)/4
	MOVE.L	0(Trigo_table2,D2),D2		;S(X-Y-Z)|C(X-Y-Z)/4
	MOVE.L	D1,Save3
	MOVE.L	D2,Save4

	ADD	D2,D1		;cos
	SWAP	D1
	SWAP	D2
	SUB	D2,D1		;sin	;(C(X-Y+Z)+C(X-Y-Z))/4|(S(X-Y+Z)-S(X-Y-Z))/4

	SUB	D1,D0		;sin
	SWAP	D0
	SWAP	D1
	SUB	D1,D0		;cos

	MOVE	X_angle,D1
	MOVE	D1,D2
	ADD	Z_angle,D1		;X+Z
	SUB	Z_angle,D2		;X-Z
	AND	Trigo_mask,D1
	AND	Trigo_mask,D2
	MOVE.L	0(Trigo_table1,D1),D1		;S(X+Z)|C(X+Z)/2
	MOVE.L	0(Trigo_table1,D2),D2		;S(X-Z)|C(X-Z)/2
	MOVE.L	D1,Save5
	MOVE.L	D2,Save6

	ADD	D2,D1		;cos	;(C(X+Z)+C(X-Z))/2
	SWAP	D1
	SWAP	D2
	SUB	D2,D1		;sin	;(C(X+Z)+C(X-Z))/2|(S(X+Z)-S(X-Z))/2

	ADD	D0,D1		;cos
	SWAP	D0
	SWAP	D1

	sub	D0,d1		;sin

	MOVE.L	D1,(Matrix_pointer)+

;	OK


;45
	MOVE	X_angle,D0
	MOVE	D0,D1
	ADD	Y_angle,D0
	SUB	Y_angle,D1
	AND	Trigo_mask,D0
	AND	Trigo_mask,D1

	MOVE	0(Trigo_table1,D0),D0
	ADD	0(Trigo_table1,D1),D0

	NEG	D0
	MOVE	D0,(Matrix_pointer)+
	;OK

;6
	move.l	Save1,d1
	move.l	Save2,d0
	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0		;C(X+Y-Z)-C(X+Y+Z)/4|S(X+Y-Z)+S(X+Y+Z)/4

	move.l	Save3,d1
	move.l	Save4,d2
	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1

	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0
	neg	d0

	move.l	Save5,d1
	move.l	Save6,d2

	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1

	add	d1,d0
	swap	d0
	swap	d1
	sub	d1,d0

	SWAP	D0
	MOVE.L	D0,(Matrix_pointer)+

	MOVE	X_angle,D0	
	ADD	Y_angle,D0
	SUB	Y_angle,X_angle
	AND	Trigo_mask,D0
	AND	Trigo_mask,X_angle
	MOVE	2(Trigo_table1,d0),D0
	ADD	2(Trigo_table1,X_angle),D0
	MOVE	D0,(Matrix_pointer)


	ENDC
	not	$ffff8240.w

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
	LEA	MATRIX(PC),A6
	MOVE	(A2)+,D5

; OCCUPES :
;	D0/D1/D2/D3/D4/D6/D7
;	A1/A2/A4/A6
; LIBRES :
;	D5
;	A0/A3/A5 TRANSLATION X,Y,Z

	MOVE.L	OBSX,A0
	MOVE.L	OBSY,A3
	MOVE	OBSZ,A5
	SUB	DIST(PC),A5
	MOVEQ	#-8,D4
BCPT:
	MOVE.L	A6,A4
	MOVEM	(A2)+,D1/D2/D3

	MOVE	D1,D6
	MULS	(A4)+,D6	;X
	MOVE	D2,D7
	MULS	(A4)+,D7
	ADD.L	D7,D6
	MOVE	D3,D7
	MULS	(A4)+,D7
	ADD.L	D7,D6

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

	SWAP	D1
	ADD	A5,D1

	ADD.L	A0,D6
	ADD.L	A3,D7

	ASR.L	#5,D6
	ASR.L	#8,D7
	
	DIVS	D1,D6
	DIVS	D1,D7

	AND	D4,D6
	ADD	#200/2,D7

	MOVE	D7,(A1)+		
	MOVE	D6,(A1)+
FBCPT
	DBF	D5,BCPT
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
	
	MOVE.L	(A1,D0.W),D0	;XA/YA
	MOVE	(A2)+,D1
	MOVE.L	(A1,D1.W),D1	;XB/YB
	MOVE	(A2)+,D2
	MOVE.L	(A1,D2.W),D2	;XC/YC

	MOVE	D1,D5
	SUB	D0,D5		;XB-XA
	MOVE	D2,D6
	SUB	D1,D6		;XC-XB

	SWAP	D0
	SWAP	D1
	SWAP	D2

	MOVE	D0,D3
	SUB	D1,D3		;YA-YB
	MOVE	D2,D4	
	SUB	D1,D4		;YC-YB

	MOVE	D5,D7
	EOR	D4,D7
	BMI.S	F1INF
F1SUP				;optimisation calcul
	MOVE	D6,D7		;du determinant
	EOR	D3,D7
	BMI.S	PCALCUL
	BRA.S	SHOW
F1INF
	MOVE	D6,D7
	EOR	D3,D7
	BMI.S	HIDEFACETTE
PCALCUL
	MULS	D4,D5
	MULS	D3,D6
	ADD.L	D5,D6
	BMI.S	HIDEFACETTE
SHOW
	MOVE.L	A2,A5
	MOVEQ	#3,D6
	LEA	SEGMENTS(PC),A4
	MOVE.L	A4,A6
	MOVEM.L	D0/D1/D2,(A4)			;gain
	LEA	12(A4),A4
LRPOINT
	REPT	4
	MOVE	(A5)+,D0
	BLT.S	FRPOINT
	MOVE.L	(A1,D0.W),D1		;26
	SWAP	D1
	MOVE.L	D1,(A4)+
	ADDQ	#1,D6
	ENDR

	MOVE	(A5)+,D0
	BLT.S	FRPOINT
	MOVE.L	(A1,D0.W),D1
	SWAP	D1
	MOVE.L	D1,(A4)
	ADDQ	#1,D6

FRPOINT
	LEA	10(A2),A2
	MOVE	(A2)+,D7

	MOVE.L	A2,-(SP)
	JSR	POLYGONE(PC)
	MOVE.L	(SP)+,A2

	MOVE.L	(A2)+,D0
	BGT.S	SOUSOBJDRAW

	MOVE	(A2)+,D0
	BGE	RFACETTE2
FFACETTES
	RTS

;----------- gestion des sous facettes avec points suppl -------

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
	JSR	POLYGONE(PC)
	MOVE.L	(SP)+,A2
	MOVE	(A2)+,D0
	BGE	SOUSOBJREP

FINSOUSOBJ
	MOVE.L	(SP)+,A2
	MOVE	(A2)+,D0
	BGE	RFACETTE2	
	RTS

;------------ gestion des antifacettes -------------------------

ANTIFACETTE




FONT16X10
	INCBIN	'FONT16X10.BIN'

	even	        		

OBSX	DC.L	0
OBSY	DC.L	0
OBSZ	DC.W	0

VROTX	DC.W	1
VROTY	DC.W	2
VROTZ	DC.W	3
DIST	DC.W	250
ROTX	DC.W	$0
ROTY	DC.W	$0
ROTZ	DC.W	$0
VDIST   DC.W	$4

	even

	IFEQ	MULS-2
SINCOS	incbin		'SINCOS.BIN'
	ENDC
	IFEQ	MULS-1
SINCOS2	incbin		'SINCOS2.BIN'
	ENDC
	IFEQ	MULS
SINCOS2	incbin		'SINCOS4.BIN'
SINCOS4	incbin		'SINCOS8.BIN'
	ENDC


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
	DC.L		strange		;objets
	DC.W		4*4,8*4,12*4			;rotations
	DC.W		100		;distance
	DC.B		64,0,0,4	;xrot,yrot,zrot,eloign
	DC.W		1000		;temps

	DC.L		rcube		;objets
	DC.W		4*4,8*4,12*4		;rotations
	DC.W		100		;distance
	DC.B		64,0,0,4	;xrot,yrot,zrot,eloign
	DC.W		1000		;temps

	DC.L		0



FACE	MACRO	
	DC.W	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM
COUL	MACRO	
	DC.W	\1*4
	ENDM
COULT	MACRO
	DC.W	\1*64+\2*4+$4000
	ENDM

PLAN	MACRO
	DC.W	\1*2+$8000
	ENDM
PLANT	MACRO
	DC.W	\1*2+$C000
	ENDM

strange
	DC.L	pstrange
	DC.L	0
	DC.L	strange
pstrange
	DC.W	16
	DC.W	50,-30,0		;aile droite
	DC.W	-50,-50,-40
	DC.W	-50,-10,40
	DC.W	50,30,0			;aile gauche
	DC.W	-50,50,-40
	DC.W	-50,10,40
	DC.W	-50,-30,0		;reacteur droit
	DC.W	0,-30,0
	DC.W	-50,-15,10
	DC.W	0,-15,10
	DC.W	-50,0,-10		;dessous cockpit
	DC.W	0,0,-10
	DC.W	-50,30,0		;reacteur gauche
	DC.W	0,30,0
	DC.W	-50,15,10
	DC.W	0,15,10
	DC.W	70,0,0			;pointe
	DC.L	fstrange
fstrange
	;bouclier droit interne

	FACE	0,1,2,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;bouclier gauche interne

	FACE	5,4,3,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;entree d'air

	FACE	9,7,11,-1,-1,-1,-1,-1
	COUL	6
	DC.L	0

	FACE	13,15,11,-1,-1,-1,-1,-1
	COUL	6
	DC.L	0

	;pointe

	FACE	9,11,16,-1,-1,-1,-1,-1
	COUL	4
	DC.L	0

	FACE	15,16,11,-1,-1,-1,-1,-1
	COUL	4
	DC.L	0
	
	FACE	15,9,16,-1,-1,-1,-1,-1
	COUL	12
	DC.L	0



	;reacteur droit

	FACE	9,8,6,7,-1,-1,-1,-1
	COUL	4
	DC.L	0
	FACE	11,7,6,10,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;reacteur gauche

	FACE	15,13,12,14,-1,-1,-1,-1
	COUL	4
	DC.L	0
	FACE	12,13,11,10,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;dessus

	FACE	15,14,8,9,-1,-1,-1,-1
	COUL	2
	DC.L	0

	;arriere

	FACE	10,6,8,14,12,-1,-1,-1
	COUL	14
	DC.L	0




	;bouclier droit externe

	FACE	2,1,0,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	;bouclier gauche externe

	FACE	3,4,5,-1,-1,-1,-1,-1
	PLANT	0
	DC.L	0

	DC.W	-1
	
rcube:
	DC.L	prcube
	DC.L	0
	DC.L	rcube

prcube
	DC.W	 7	

	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40

	DC.L	frcube


frcube

	;faces externes

	FACE	1,0,3,2,-1,-1,-1,-1,-1,-1
	PLAN	0
	DC.L	0

	FACE	5,6,7,4,-1,-1,-1,-1,-1,-1
	PLAN	0
	DC.L	0

	FACE	5,4,0,1,-1,-1,-1,-1,-1,-1
	PLANT	1
	DC.L	0

	FACE	0,4,7,3,-1,-1,-1,-1,-1,-1
	PLAN	1
	DC.L	0

	FACE	3,7,6,2,-1,-1,-1,-1,-1,-1
	PLANT	1
	DC.L	0

	FACE	2,6,5,1,-1,-1,-1,-1,-1,-1
	PLAN	1
	DC.L	0
	
	DC.W	-1



palette:
	INCBIN	'CYP.COL'


************************************************************
    SECTION 	BSS
************************************************************
MATRIX:
	DS.W	9		
PROJETES2:
	DS.L	128
PROJETES:
	DS.L	128
SEGMENTS
	DS.L	128
sys_vbl:
	ds.l	1		;adresse ancienne vbl
sys_rez:
 	ds.w	1		;resolution systŠme
sys_palette:
	ds.w	16		;couleurs du systŠme
sys_screen:
	ds.l	1		;adresse ecran systŠme
sys_scr1:
	ds.l	1		;adresse ecran visualis‚
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

;----------- table de clipping en X ---------------------

LLIMIT
	DS.L	CLIPSIZE*2
TLIMIT
	DS.L	160*2
MLIMIT
	DS.L	160*2
RLIMIT
	DS.L	CLIPSIZE*2


userstack:
	ds.l	1
endstack:
	ds.l	1000
mystack:		
	end





