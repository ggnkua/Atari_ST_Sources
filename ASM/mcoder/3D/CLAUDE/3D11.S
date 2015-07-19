

VBL_COUNT	equ	$465		;adresse du compteur VBL
CLIPMAXY	equ	199-11
AFFCPU		equ	1
EFFSCR		equ	0
MUSIQUE		equ	0
AFFTEXTE	equ	0
DEBUG		equ	0
COMPTEIMAGE	equ	0

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



	IFEQ	MUSIQUE


	JMP	start
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
LA2E:	INCBIN	"TCB.2"


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

	JSR	genfastcls(PC)

repeat
	IFEQ	EFFSCR
 	jsr	ffastcls(PC)
	ENDC
	jsr	CALCPROJ(PC)
	move.l	objetcourant(PC),A2
	move.l	(A2),A2
	LEA	PROJETES,A1
	jsr	CALCOBJ(PC)
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
	bra.s	repeat
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
	addq	#4,A0
	move.l	(A0)+,VROTX
	move.l	(A0)+,VROTZ
	move.l	(A0)+,ROTX
	move	(A0),cptwaiting

	bra	repeat
passpace

	cmp.b	#$01,D0
	bne	repeat

	move.l	(SP)+,A0
	move.l	A0,USP


	rts

objetcourant
	DC.L	objets
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
	DC.W	0
cursoroffset
	DC.L	160*(199-9)
ptrtext
	DC.L	textcursor
textcursor
	incbin	'TEXTE.BIN'
	DC.B	0
	EVEN

	



************************************************************
*	routine d'affichage de polygone			   *
************************************************************

; A6 -> ADRESSE DES DATAS
; D6 -> NOMBRE DE POINTS
; D7 -> COULEUR * 8 (ATTENTION)
;

	INCLUDE	'DEFREGS.S'


vertline:
		; clipping
		
		cmp	CDX,YB
		ble.s	vlclipbas
		move	CDX,YB
vlclipbas
		tst	YA
		bge.s	vlcliphaut
		clr	YA
vlcliphaut

		cmp	MAXY,YB
		ble.s	vlpasmaxi
		move	YB,MAXY
vlpasmaxi
		cmp	MINY,YA
		bgt.s	vlpasmini	
		move	YA,MINY
vlpasmini

		move.w	YA,DY
		add	YA,YA
		add	YA,PTRY

		PLOT

		sub	YB,DY
		add	DY,DY
		lea	vljmp(PC),STEP
		add	DY,STEP
		jmp	(STEP)

		REPT	199
		PLOT
		ENDR
vljmp		
calcretour
		jmp	(RETOUR)

;------------------ calcul des points d'une droite ----------------

calcline:

;------------------ tri -------------------------------------------

		lea	tableymax(PC),PTRY
		cmp	YA,YB
		beq.s	calcretour	;ligne horizontale
		bgt.s	YBsupYA
		exg	YA,YB		;tri des 2 points
		exg	XA,XB
		lea	400(PTRY),PTRY  ;ligne montante
YBsupYA
;----------------- teste visiblilite -----------------------------

		move.w	#CLIPMAXY,CDX     ;brouillon pour test
		cmp	CDX,YA	     	  ;ligne visible ?
		bgt.s	calcretour
		tst	YB
		blt.s	calcretour

;----------------- calcul DX et DY -------------------------------

		move	XB,DX		;calcul DX
		sub	XA,DX

		beq	vertline	;ligne verticale

		move	YB,DY		;calcul	DY
		sub	YA,DY

		move	DY,REGDATA

		tst	YA		;teste YA
		bge.s	YAsup0		;si pas de clip en haut
cliphaut
		add	YA,REGDATA
		muls	DX,YA		;on clippe en haut
		divs	DY,YA		;XA=XA-(YA*DX)/DY
		sub	YA,XA
		clr	YA		;YA=0
YAsup0
		cmp	CDX,YB		;Teste YB
		ble.s	calcontinuer		
		sub	CDX,YB
		sub	YB,REGDATA
		move	CDX,MAXY
		bra.s	pasmaximum
calcontinuer

;------------ mise a jour des maximum et minimum ----------

		cmp	MAXY,YB		;tester maximum
		ble.s	pasmaximum
		move	YB,MAXY
pasmaximum
		cmp	MINY,YA		;tester minimum
		bgt.s	pasminimum
		move	YA,MINY
pasminimum
		add	YA,YA
		add	YA,PTRY

		PLOT

		add	REGDATA,REGDATA
		add	REGDATA,REGDATA

		move	DY,CUMUL
		lsr	#1,CUMUL

		tst	DX
		bgt	DXsup0
DXinf0
		neg	DX
		cmp	DY,DX
		bgt	DXinf0supDY

;------------- cas 1 : DX<DY et DX<0---------------------
DXinf0infDY
		jmp	DXinf0infDYjmp(PC,REGDATA.W)
DXinf0infDYjmp	
		incbin	'DEPLXINF.BIN'
		jmp	(RETOUR)

;------------- cas 2 ------------------------------------

DXinf0supDY
		ext.l	DX
		divu	DY,DX
		move	DX,STEP			;STEP
		swap	DX			;RESTE
		jmp	DXinf0supDYjmp(PC,REGDATA.W)
DXinf0supDYjmp
		incbin	'DEPLYINF.BIN'
		jmp	(RETOUR)

;------------- DX > 0 -----------------------------------
DXsup0
		cmp	DY,DX
		bgt	DXsup0supDY

;------------- cas 3 : DX>0 et DX<DY -------------------- 
DXsup0infDY
		jmp	DXsup0infDYjmp(PC,REGDATA.W)
DXsup0infDYjmp
		incbin	'DEPLXSUP.BIN'
		jmp	(RETOUR)

;------------- cas 4 : DX>0 et DX>DY -------------------

DXsup0supDY
		ext.l	DX
		divu	DY,DX		;CDY=DY
		move	DX,STEP		;STEP
		swap	DX		;DY=RESTE
		jmp	DXsup0supDYjmp(PC,REGDATA.W)
DXsup0supDYjmp
		incbin	'DEPLYSUP.BIN'
		jmp	(RETOUR)
nopoly		rts


polygone
		swap	MAXY
		swap	MINY
		clr	MAXY
		move.w	#CLIPMAXY,MINY
		swap	MINY
		move.l	PTRSEGMENT,COPPTRSEGMENT
		lea	lretjmp(PC),RETOUR
		lea	calcline(PC),JMP
		subq	#1,MINY
repline
		movem	(PTRSEGMENT),XA/YA/XB/YB
		addq	#4,PTRSEGMENT
		swap	MINY
		jmp	(JMP)
lretjmp
		swap	MINY
		subq	#1,MINY
		bne.s   repline
		movem	(PTRSEGMENT),XA/YA
		movem	(COPPTRSEGMENT),XB/YB
		lea	drawpolygone(PC),RETOUR
		swap	MINY
		jmp	(JMP)
drawpolygone:
		sub	MINY,MAXY
		ble.s	nopoly
		swap	MAXY
		lea	tableymax(PC),PTRTABLE		
		movem.l	colors-tableymax(PTRTABLE,MAXY.W),REG1/REG2
		swap	MAXY

		move.l	REG1,REG3
		move.l	REG2,REG4
		move.l	REG1,REG5
		move.l	REG2,REG6
		move.l	REG1,REG7
		move.l	REG2,REG8

		move	MINY,RESULT			;MINY
		add	RESULT,RESULT			;MINY*2
		lea	mask(PC),PTRMASK
		move.l	sys_scr6(PC),ECRAN
		add	muls160-mask(PTRMASK,RESULT.W),ECRAN
		add	RESULT,PTRTABLE			;debut table
dlrep

		move.w	(PTRTABLE)+,X0		;X0
		move.w	200*2-2(PTRTABLE),MINY	;X1

; partie a supprimer quand pas de clipping horizontal

		bge.s	MINYsup0
		moveq	#0,MINY
MINYsup0				
		cmp	#319,X0
		ble.s	X0sup319
		move.w	#319,X0


X0sup319
		cmp	MINY,X0		;Ö optimiser : ce test ne
					;devrais pas etre fait
		blt.s	lsuiv
lcontinuer
		moveq	#$F,RESULT			
		and	X0,RESULT			;X mod 16
		eor	RESULT,X0			;X and $FFF0
		lsr	#1,X0
		move.l	ECRAN,USP
		add	X0,ECRAN
		add	RESULT,RESULT
		add	RESULT,RESULT

		add	X0,X0
		sub	MINY,X0			;(X0 DIV 16)*16-X0
		ble.s	onelong			 
notonelong					        
		move.l	(PTRMASK,RESULT.W),MINY	;masque
		move.l	(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	MINY,RESULT
		eor.l	REG1,RESULT
		move.l	RESULT,(ECRAN)+
		move.l	(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	MINY,RESULT
		eor.l	REG2,RESULT
		move.l	RESULT,(ECRAN)
		subq	#4,ECRAN		

		moveq	#$F,RESULT
		and	X0,RESULT		;prepare masque de fin
		eor	RESULT,X0			
		add	X0,X0
		jmp	ffill0(PC,X0.W)		;appel transfert par movem
onelong
		move.l	(PTRMASK,RESULT.W),MINY		;masque
		add	X0,X0
		add	X0,X0
		or.l    maskg-mask-4(PTRMASK,X0.W),MINY
		move.l	(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	MINY,RESULT
		eor.l	REG1,RESULT
		move.l	RESULT,(ECRAN)+
		move.l	(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	MINY,RESULT
		eor.l	REG2,RESULT
		move.l	RESULT,(ECRAN)
		move.l	USP,ECRAN
lsuiv
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts
ffill0
		bra	ffillfin
		DC.B	'HELLO, WHAT ARE YOU LOOKING '
ffill1
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DC.B	'IN MY CODE ? UMMHH !    '
ffill2
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin		
		DC.B	'1990 - ALGERNON & MCODER'
ffill3
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DC.B	'Phone no : 64571426     '
ffill4						 
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		bra	ffillfin
		DS.B	32-8
ffill5
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill6
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill7
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill8
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		bra	ffillfin
		DS.B	32-12
ffill9	
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill10
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill11
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill12
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		bra	ffillfin
		DS.B	32-16
ffill13
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill14
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill15
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
ffill16
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		bra.s	ffillfin
		DS.B	32-18
ffill17
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)		
		movem.l	REG1/REG2,-(ECRAN)
		bra.s	ffillfin
		DS.B	32-22
ffill18
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)		
		movem.l	REG1/REG2/REG3/REG4,-(ECRAN)
		bra.s	ffillfin
		DS.B	32-22
ffill19
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)		
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)

ffillfin:
		add	RESULT,RESULT
		add	RESULT,RESULT
		move.l	maskg-mask(PTRMASK,RESULT.W),MINY		;masque
		move.l	-(ECRAN),RESULT
		eor.l	REG2,RESULT
		and.l	MINY,RESULT
		eor.l	REG2,RESULT
		move.l	RESULT,(ECRAN)
		move.l	-(ECRAN),RESULT
		eor.l	REG1,RESULT
		and.l	MINY,RESULT
		eor.l	REG1,RESULT
		move.l	RESULT,(ECRAN)
		move.l	USP,ECRAN
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
fffin
		rts

		dc.l	$FFFEFFFE,$FFFCFFFC,$FFF8FFF8,$FFF0FFF0
		dc.l	$FFE0FFE0,$FFC0FFC0,$FF80FF80,$FF00FF00
		dc.l	$FE00FE00,$FC00FC00,$F800F800,$F000F000
		dc.l	$E000E000,$C000C000,$80008000,$00000000
maskg
		dc.l	$FFFFFFFF
		dc.l	$FFFEFFFE,$FFFCFFFC,$FFF8FFF8,$FFF0FFF0
		dc.l	$FFE0FFE0,$FFC0FFC0,$FF80FF80,$FF00FF00
		dc.l	$FE00FE00,$FC00FC00,$F800F800,$F000F000
		dc.l	$E000E000,$C000C000,$80008000,$00000000
mask:
		dc.l	$7FFF7FFF,$3FFF3FFF,$1FFF1FFF,$0FFF0FFF
		dc.l	$07FF07FF,$03FF03FF,$01FF01FF,$00FF00FF
		dc.l	$007F007F,$003F003F,$001F001F,$000F000F
		dc.l	$00070007,$00030003,$00010001,$00000000
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
	ADD.B	\1(PC),D0
	MOVE.B	D0,\1
	AND	#$FF,D0
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A0,D0.W),\2
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

	MOVE	VROTX(PC),D0	;ROT X
	NXTANG	ROTX,SX/CX	;SX
	MOVE	VROTY(PC),D0	;ROT Y
	NXTANG	ROTY,SY/CY	;SY
	MOVE	VROTZ(PC),D0	;ROT Z
	NXTANG	ROTZ,SZ/CZ	;SZ

;
; CALCULE LA MATRICE DE PROJECTION
;

	LEA	NEW(PC),A0

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
	MOVE	D1,(A0)
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

FAST	MACRO
	MOVE	\1,\2
	MULS	(A4)+,\2
	ENDM

ADDFAST	MACRO
	MOVE	\1,\3
	MULS	(A4)+,\3
	ADD.L	\3,\2
	ENDM


CALCOBJ

;	LEA	BUFFERZ(PC),A5

	LEA	NEW(PC),A6
	MOVE.L	A6,A4
	MOVE	DIST(PC),D4
	MOVE	(A2)+,D1
	BEQ.S	FCALCOBJ
BCPTS:
	MOVEM	(A2)+,D2/D3	

	FAST	D1,D6		;X
	ADDFAST	D2,D6,D0
	ADDFAST	D3,D6,D0

	FAST	D1,D7		;Y
	ADDFAST	D2,D7,D0
	ADDFAST	D3,D7,D0

	FAST	D1,D5		;Z
	ADDFAST	D2,D5,D0
	ADDFAST	D3,D5,D0

	SWAP	D5

	SUB	D4,D5

	ASR.L	#8,D7
	ASR.L	#8,D6
	
	DIVS	D5,D6
	DIVS	D5,D7


;	ADD.L	D5,D5
;	SWAP	D5
;	ADD.L	D7,D7
;	ADD.L	D6,D6
;	SWAP	D6
;	SWAP	D7
;	ADD	D5,D5
;	MOVE	(A5,D5.W),D5
;	MULS	D5,D7
;	MULS	D5,D6
;	ADD.L	D7,D7
;	ADD.L	D7,D7
;	ADD.L	D6,D6
;	ADD.L	D6,D6
;	SWAP	D7
;	SWAP	D6

	ADD	#320/2,D6
	ADD	#(200-12)/2,D7


	MOVE	D6,(A1)+
	MOVE	D7,(A1)+

	MOVE.L	A6,A4
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

	ADD.L	D7,D6
	
	BLE.S	HIDEFACETTE

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
VROTY	DC.W	2
VROTZ	DC.W	0
DIST	DC.W	200
ROTX	DC.B	$30
ROTY	DC.B	$0
ROTZ	DC.B	$0
VDIST   DC.B	$4

	even

SINCOS		;TABLE DE SINUS/COSINUS

	DC.W	$0,$7FFF,$324,$7FF5,$647,$7FD7,$96A,$7FA6
	DC.W	$C8B,$7F61,$FAB,$7F08,$12C7,$7E9C,$15E1,$7E1C
	DC.W	$18F8,$7D89,$1C0B,$7CE2,$1F19,$7C29,$2223,$7B5C
	DC.W	$2527,$7A7C,$2826,$7989,$2B1E,$7883,$2E10,$776B
	DC.W	$30FB,$7640,$33DE,$7503,$36B9,$73B5,$398C,$7254
	DC.W	$3C56,$70E1,$3F16,$6F5E,$41CD,$6DC9,$447A,$6C23
	DC.W	$471C,$6A6C,$49B3,$68A5,$4C3F,$66CE,$4EBF,$64E7
	DC.W	$5133,$62F1,$539A,$60EB,$55F4,$5ED6,$5842,$5CB3
	DC.W	$5A81,$5A81,$5CB3,$5842,$5ED6,$55F4,$60EB,$539A
	DC.W	$62F1,$5133,$64E7,$4EBF,$66CE,$4C3F,$68A5,$49B3
	DC.W	$6A6C,$471C,$6C23,$447A,$6DC9,$41CD,$6F5E,$3F16
	DC.W	$70E1,$3C56,$7254,$398C,$73B5,$36B9,$7503,$33DE
	DC.W	$7640,$30FB,$776B,$2E10,$7883,$2B1E,$7989,$2826
	DC.W	$7A7C,$2527,$7B5C,$2223,$7C29,$1F19,$7CE2,$1C0B
	DC.W	$7D89,$18F8,$7E1C,$15E1,$7E9C,$12C7,$7F08,$FAB
	DC.W	$7F61,$C8B,$7FA6,$96A,$7FD7,$647,$7FF5,$324
	DC.W	$7FFF,$0,$7FF5,$FCDB,$7FD7,$F9B8,$7FA6,$F695
	DC.W	$7F61,$F374,$7F08,$F054,$7E9C,$ED38,$7E1C,$EA1E
	DC.W	$7D89,$E707,$7CE2,$E3F4,$7C29,$E0E6,$7B5C,$DDDC
	DC.W	$7A7C,$DAD8,$7989,$D7D9,$7883,$D4E1,$776B,$D1EF
	DC.W	$7640,$CF04,$7503,$CC21,$73B5,$C946,$7254,$C673
	DC.W	$70E1,$C3A9,$6F5E,$C0E9,$6DC9,$BE32,$6C23,$BB85
	DC.W	$6A6C,$B8E3,$68A5,$B64C,$66CE,$B3C0,$64E7,$B140
	DC.W	$62F1,$AECC,$60EB,$AC65,$5ED6,$AA0B,$5CB3,$A7BD
	DC.W	$5A81,$A57E,$5842,$A34C,$55F4,$A129,$539A,$9F14
	DC.W	$5133,$9D0E,$4EBF,$9B18,$4C3F,$9931,$49B3,$975A
	DC.W	$471C,$9593,$447A,$93DC,$41CD,$9236,$3F16,$90A1
	DC.W	$3C56,$8F1E,$398C,$8DAB,$36B9,$8C4A,$33DE,$8AFC
	DC.W	$30FB,$89BF,$2E10,$8894,$2B1E,$877C,$2826,$8676
	DC.W	$2527,$8583,$2223,$84A3,$1F19,$83D6,$1C0B,$831D
	DC.W	$18F8,$8276,$15E1,$81E3,$12C7,$8163,$FAB,$80F7
	DC.W	$C8B,$809E,$96A,$8059,$647,$8028,$324,$800A
	DC.W	$0,$8001,$FCDB,$800A,$F9B8,$8028,$F695,$8059
	DC.W	$F374,$809E,$F054,$80F7,$ED38,$8163,$EA1E,$81E3
	DC.W	$E707,$8276,$E3F4,$831D,$E0E6,$83D6,$DDDC,$84A3
	DC.W	$DAD8,$8583,$D7D9,$8676,$D4E1,$877C,$D1EF,$8894
	DC.W	$CF04,$89BF,$CC21,$8AFC,$C946,$8C4A,$C673,$8DAB
	DC.W	$C3A9,$8F1E,$C0E9,$90A1,$BE32,$9236,$BB85,$93DC
	DC.W	$B8E3,$9593,$B64C,$975A,$B3C0,$9931,$B140,$9B18
	DC.W	$AECC,$9D0E,$AC65,$9F14,$AA0B,$A129,$A7BD,$A34C
	DC.W	$A57E,$A57E,$A34C,$A7BD,$A129,$AA0B,$9F14,$AC65
	DC.W	$9D0E,$AECC,$9B18,$B140,$9931,$B3C0,$975A,$B64C
	DC.W	$9593,$B8E3,$93DC,$BB85,$9236,$BE32,$90A1,$C0E9
	DC.W	$8F1E,$C3A9,$8DAB,$C673,$8C4A,$C946,$8AFC,$CC21
	DC.W	$89BF,$CF04,$8894,$D1EF,$877C,$D4E1,$8676,$D7D9
	DC.W	$8583,$DAD8,$84A3,$DDDC,$83D6,$E0E6,$831D,$E3F4
	DC.W	$8276,$E707,$81E3,$EA1E,$8163,$ED38,$80F7,$F054
	DC.W	$809E,$F374,$8059,$F695,$8028,$F9B8,$800A,$FCDB
	DC.W	$8001,$FFFF,$800A,$324,$8028,$647,$8059,$96A
	DC.W	$809E,$C8B,$80F7,$FAB,$8163,$12C7,$81E3,$15E1
	DC.W	$8276,$18F8,$831D,$1C0B,$83D6,$1F19,$84A3,$2223
	DC.W	$8583,$2527,$8676,$2826,$877C,$2B1E,$8894,$2E10
	DC.W	$89BF,$30FB,$8AFC,$33DE,$8C4A,$36B9,$8DAB,$398C
	DC.W	$8F1E,$3C56,$90A1,$3F16,$9236,$41CD,$93DC,$447A
	DC.W	$9593,$471C,$975A,$49B3,$9931,$4C3F,$9B18,$4EBF
	DC.W	$9D0E,$5133,$9F14,$539A,$A129,$55F4,$A34C,$5842
	DC.W	$A57E,$5A81,$A7BD,$5CB3,$AA0B,$5ED6,$AC65,$60EB
	DC.W	$AECC,$62F1,$B140,$64E7,$B3C0,$66CE,$B64C,$68A5
	DC.W	$B8E3,$6A6C,$BB85,$6C23,$BE32,$6DC9,$C0E9,$6F5E
	DC.W	$C3A9,$70E1,$C673,$7254,$C946,$73B5,$CC21,$7503
	DC.W	$CF04,$7640,$D1EF,$776B,$D4E1,$7883,$D7D9,$7989
	DC.W	$DAD8,$7A7C,$DDDC,$7B5C,$E0E6,$7C29,$E3F4,$7CE2
	DC.W	$E707,$7D89,$EA1E,$7E1C,$ED38,$7E9C,$F054,$7F08
	DC.W	$F374,$7F61,$F695,$7FA6,$F9B8,$7FD7,$FCDB,$7FF5


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

	DC.L		dodecaedre
	DC.W		1,2,3
	DC.W		200	
	DC.B		0,0,0,4
	DC.W		100

	DC.L		dodecaedre
	DC.W		1,2,2
	DC.W		200
	DC.B		$0,0,0,1
	DC.W		500

	DC.L		car
	DC.W		0,2,0
	DC.W		150	
	DC.B		$40,0,$0,1
	DC.W		500



	DC.L		scareface
	DC.W		1,2,3
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
	DC.B		0,0,$80,-2
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

	DC.L		damier
	DC.W		0,2,0
	DC.W		15	
	DC.B		0,0,$80,4
	DC.W		100

	DC.L		chiffre8
	DC.W		0,2,0
	DC.W		290	
	DC.B		$20,0,0,-4
	DC.W		100

	DC.L		scareface
	DC.W		1,2,3
	DC.W		45
	DC.B		0,0,0,4
	DC.W		300

	DC.L		dalle
	DC.W		1,2,3
	DC.W		60	
	DC.B		0,0,0,$FF
	DC.W		300

	DC.L		lettrea
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,$FF
	DC.W		400

	DC.L		mine
	DC.W		1,2,3
	DC.W		30	
	DC.B		0,0,$80,$FF
	DC.W		400


	DC.L		damier
	DC.W		0,3,0
	DC.W		15	
	DC.B		0,0,$80,$FF
	DC.W		400


	DC.L		grille
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,$FF
	DC.W		250

	DC.L		scareface
	DC.W		1,3,2
	DC.W		45
	DC.B		0,0,0,$FF
	DC.W		300

	DC.L		torus
	DC.W		1,2,3
	DC.W		30
	DC.B		0,0,0,$FF
	DC.W		300

	DC.L		spider2
	DC.W		1,2,3
	DC.W		100
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		car
	DC.W		0,2,0
	DC.W		140	
	DC.B		$40,0,$0,$FF
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
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0

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
	DC.W	 40,-40,-40
	DC.W	 40, 40,-40
	DC.W	-40, 40,-40
	DC.W	-40,-40,-40
	DC.W	 40,-40, 40
	DC.W	 40, 40, 40
	DC.W	-40, 40, 40
	DC.W	-40,-40, 40
	DC.W	0

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





palette
	DC.W	$000,$777,$770,$777,$504,$777,$770,$777
	DC.W	$007,$777,$770,$777,$504,$777,$770,$777
palette2:
	DC.W	$000,$FF0,$013,$024,$035,$046,$057,$700
	DC.W	$720,$740,$760,$770,$212,$434,$656,$777

;--------------------------------------------------------
lettrea:
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
	DC.W	50,50,0
	DC.W	50,-50,0
	DC.W	-50,-50,0
	DC.W	-50,50,0
	DC.W	0
	FACE	3,2,1,0,-1,-1,-1,-1,-1,-1
	DC.W	3*8
	DC.L	0
	FACE	0,1,2,3,-1,-1,-1,-1,-1,-1
	DC.W	7*8
	DC.L	0
	DC.W	$FFFF
;------------------------------------------------------
uncube
	DC.W	-35,35,15
	DC.W	-5,35,15
	DC.W	-5,5,15
	DC.W	-35,5,15
	DC.W	-35,35,-15
	DC.W	-5,35,-15
	DC.W	-5,5,-15
	DC.W	-35,5,-15
	
	DC.W	0

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
	DC.W	-20,40,0
	DC.W	20,40,0
	DC.W	-40,-40,0
	DC.W	40,-40,0
	DC.W	-20,-40,10
	DC.W	20,-40,10
	DC.W	-20,-40,-10
	DC.W	20,-40,-10
	DC.W	0

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
	FACE	0,6,7,1,-1,-1,-1,-1
	DC.W	6*8
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
	




************************************************************
    SECTION 	BSS
************************************************************

bfastcls:
	DS.L	4000
NEW	DS.W	9		
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
screen2:	
	ds.b	96256+32000*2	;buffer ecran 2
userstack:
	ds.l	1	
endstack:
	ds.l	100
mystack:		
	end







