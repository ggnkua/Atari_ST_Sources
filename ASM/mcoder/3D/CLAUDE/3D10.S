
;
;
;
;
;
;
;
;
;
;
;
;


VBL_MEMO	equ	$452		;adresse de memorisation compteur VBL
VBL_COUNT	equ	$466		;adresse du compteur VBL



CLIPMAXY	equ	199-11


	SECTION TEXT




***********************************************************
*		programme principal :			  *
*							  *
*		- basse resolution			  *
*		- sauvegarde de la palette		  *
*		- installation nouvelle VBL		  *
*							  *
***********************************************************

	JMP	start

CLRWIN
	INCBIN	'CLRSCR.BIN'

REPLAY

MUS = 2 

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
	MOVE.L	A4,off22(A0)
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
	BRA	L12C


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
	MOVE.L	off22(A0),A1
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
	MOVE.L	A1,off22(A0)
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
	MOVE.L	A1,off22(A0)
	RTS
L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	L31C
	MOVE.B	(A1)+,off1f(A0)
L31C:	MOVE.L	A1,off22(A0)
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
LA2E:	INCBIN	"WEIRD.IMG"


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

	BSR	SETMUSIC

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

	lea	$FFFF8240,A0
	lea	sys_palette,A1
	jsr	copy_pal(PC)		sauve la palette courante

	move.l	A0,A1			installe nouvelle palette
	lea	palette2,A0
	jsr	copy_pal(PC)


	move.l	$70,sys_vbl		sauve adresse IT VBL
	move.l  #new_vbl,$70		nouvelle vbl	

	jsr	main(PC)

	move.l	sys_vbl,$70		restauration vbl systäme

	lea	sys_palette,A0
	lea	$FFFF8240,A1
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




***************************************************************
*	routine de tracÇ de ligne 			      *
***************************************************************

; modif des registres	D0-D6/A0-A1

			
line:			
li_ctrlrep:

li_noctrl:

		cmp.w	D0,D2			; tri des points A et B par
		blt.s	li_x2gtx1		; x croissants
		exg		D0,D2		; echange les x et les y
		exg		D1,D3
li_x2gtx1:
		move.w	D1,D4			;calcul adresse de base
		add.w	D4,D4			;D4=y1*2
		lea	muls160(PC),A1	        ;A1->table des multiplications
		add.w	(A1,D4.w),A0		;A0->adresse du point

		move.w	D0,D4
		and.b	#$F0,D4
		lsr.w	#1,D4
		add.w	D4,A0
		
		move.w	D0,D4			;D4=reste de la division par 16
		not.w	D4
		and.w	#$F,D4
		clr.w	D5
		bset	D4,D5			;D5=pattern
		
		move.w	#160,D4			;D4=+-160
		sub.w	D1,D3			;D3=dy
		bge.s	li_dyge0
			neg.w	D4
			neg.w	D3
li_dyge0:				
		sub.w	D0,D2
		neg.w	D2
		cmp.w	D3,D2				;dx ? dy
		bge		li_dxgtdy
li_dxledy:				
			move.w	D3,D0				;D0=cumul=dy/2
			asr.w	#1,D0
			move.w	D3,D1				;D1=dy
	*---------------- si pas de deroulement ----------
			ADD	D1,D1
			ADD	D1,D1
			jmp	li1bra(PC,D1.W)
li1bra		
			INCBIN	'LI1.BIN'
			rts
li_dxgtdy:		
			move.w	D5,D6
			clr.w	D5
			
			move.w	D2,D0		;D0=cumul=dx/2
			asr.w	#1,D0
			move.w	D2,D1
			
			add	D1,D1
			add	D1,D1
			jmp	li2bra(PC,D1.W)
	li2bra:
			INCBIN 'LI2.BIN'
li_fin:
			rts		



****************** copie de palette *****************************

copy_pal:
	movem.l	(A0),D0-D7
	movem.l	D0-D7,(A1)
	rts


****************** genration du fastcls 1 plan *******************

genclearplane1:
	lea	bclearplane1,A0
	move.w	#$4268,D1
	move.w	#4000-1,D0
	swap	D1
	clr.w	D1
gpr1
	move.l	D1,(A0)+
	addq.w	#8,D1
	dbf	D0,gpr1
	move	#$4E75,(A0)		;rts
	rts

****************** generation du FASTCVLS 4 plans *****************

genfastcls:
	lea	bfastcls(PC),A0
	move.l	#$48E0FF7E,D0
	move	#400,D1
gfcrep:
	move.l	D0,(A0)+		;genere les movem
	dbf	D1,gfcrep
	move.l	#$48E0FC00,(A0)+	;dernier movem
	move	#$4E75,(A0)		;rts
	rts

*****************************************************************
*	macro de swapping des 2 ecrans 				*
*****************************************************************

SWAPPER MACRO
;	move.w	#$700,$FFFF8240.W
	move.b	VBL_MEMO,D0
vbl_wait:
	cmp.b	VBL_COUNT,D0
	beq.s	vbl_wait	
;	clr.w	$FFFF8240.W

	lea	sys_scr1,A0
	movem.l	(A0)+,D0/D1/D2/D3
	movem.l	D0/D1/D2,-(A0)
	move.l	D3,-(A0)
	lsr	#8,D3
	move.l	D3,$FFFF8200.W	

	move.b	VBL_COUNT,VBL_MEMO
	ENDM

*****************************************************************
*	programme principal					*
*****************************************************************

main:
	move.l	USP,A0
	move.l	A0,-(SP)




	JSR	genfastcls(PC)
	JSR	genclearplane1(PC)
	BSR	PRECALCULE_Z



;	LEA	TITRE(PC),A0
;	MOVE.L	sys_scr1,A1
;	ADDQ	#2,A1
;	JSR	AFFSTRING
;	LEA	TITRE(PC),A0
;	MOVE.L	sys_scr2,A1
;	ADDQ	#2,A1
;	JSR	AFFSTRING
;	LEA	TITRE(PC),A0
;	MOVE.L	sys_scr3,A1
;	ADDQ	#2,A1
;	JSR	AFFSTRING
;	LEA	TITRE(PC),A0
;	MOVE.L	sys_scr4,A1
;	ADDQ	#2,A1
;	JSR	AFFSTRING


	IFEQ	1

	LEA	sys_scr1,A0
	MOVEQ.W	#0,D0
AAREPLINE

	MOVEM.L	D0/A0,-(SP)
	MOVE.L	(A0),A0
	ADDQ	#4,A0
	MOVE	#199,D1
	MOVE	#160,D2
	MOVE	#100,D3
AREPLINE

	MOVEM.L	D0-D3/A0,-(SP)
	JSR	line(PC)
	MOVEM.L	(SP)+,D0-D3/A0
	MOVEM.L	D0-D3/A0,-(SP)
	MOVEQ	#0,D1
	SUB	#319,D0
	NEG	D0
	JSR	line(PC)
	MOVEM.L	(SP)+,D0-D3/A0

	ADD	#16,D0
	CMP.W	#319,D0
	BLE.S	AREPLINE


	MOVEM.L	(SP)+,D0/A0

	ADDQ	#4,A0
	ADDQ	#4,D0
	CMP.W	#16,D0

	BLT.S	AAREPLINE

	ENDC


repeat

	MOVE.L	sys_scr4,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	#319,D2
	MOVE	#199-11,D3
	JSR	CLRWIN			;routine d'effacement optimisee

;	jsr	ffastcls(PC)


;	move.w	#$007,$FFFF8240.W
;	jsr	clearplane1(PC)
;	move.w	#$707,$FFFF8240.W

	jsr	CALCPROJ(PC)
;	clr	$FFFF8240.W


	move.l	objetcourant(PC),A2
	move.l	(A2),A2
	LEA	PROJETES,A1

	jsr	CALCOBJ(PC)
	jsr	TRACEOBJ(PC)

;	jsr	FILDEFER(PC)

	SWAPPER

	move.b	$FFFFFC02.W,D0
	cmp.b	#$4E,D0
	bne.s	pasplus
	addq	#1,DIST
	bra.s	repeat
pasplus
	cmp.b	#$4A,D0
	bne.s	pasmoins
	subq	#1,DIST
	bra	repeat
pasmoins
	cmp	#400,DIST
	ble.s	passpace
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


*------------- interruption vbl ----------------------------




new_vbl2:
	add.b	#1,VBL_COUNT
	rte




CURS	MACRO

	move.l	sys_scr1,A1
	add	D1,A1
	not	(A1)
	not	160*1(A1)
	not	160*2(A1)
	not	160*3(A1)
	not	160*4(A1)
	not	160*5(A1)
	not	160*6(A1)
	not	160*7(A1)
	not	160*8(A1)
	not	160*9(A1)
	move.l	sys_scr2,A1
	add	D1,A1
	not	(A1)
	not	160*1(A1)
	not	160*2(A1)
	not	160*3(A1)
	not	160*4(A1)
	not	160*5(A1)
	not	160*6(A1)
	not	160*7(A1)
	not	160*8(A1)
	not	160*9(A1)
	move.l	sys_scr3,A1
	add	D1,A1

	not	(A1)
	not	160*1(A1)
	not	160*2(A1)
	not	160*3(A1)
	not	160*4(A1)
	not	160*5(A1)
	not	160*6(A1)
	not	160*7(A1)
	not	160*8(A1)
	not	160*9(A1)
	move.l	sys_scr4,A1
	add	D1,A1
	not	(A1)
	not	160*1(A1)
	not	160*2(A1)
	not	160*3(A1)
	not	160*4(A1)
	not	160*5(A1)
	not	160*6(A1)
	not	160*7(A1)
	not	160*8(A1)
	not	160*9(A1)
	ENDM
	

new_vbl:
	add.b	#1,VBL_COUNT
	MOVEM.L	D0-D7/A0/A1/A2/A6,-(SP)
	BSR	PLAYMUSIC
	MOVEM.L	(SP)+,D0-D7/A0/A1/A2/A6 
	tst	cptwaiting
	bne.s	noincdist
	ADDQ	#2,DIST
	bra.s	vblcont
noincdist
	subq	#1,cptwaiting
vblcont
	subq	#1,cptvbl
	ble.s	gescurseur
	rte
gescurseur
	move	#1,cptvbl
	movem.l	D0-D1/A0-A2,-(SP)
	move.l	ptrtext(PC),A0
	clr	D0
	move.b	(A0)+,D0
	bne.s	pasfcurs
	lea	textcursor(PC),A0
	move.l	A0,ptrtext
	bra	fgestcurs
pasfcurs
	move.l	A0,ptrtext
	cmp.b	#'w',D0
	bne.s	paswaitcurs
	add	#10,cptvbl
	bra	fgestcurs
paswaitcurs

	move.l	cursoroffset(PC),D1

	CURS

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

	MOVE.L	sys_scr1,A2
	ADD	D1,A2
	MOVE	(A1)+,(A2)
	MOVE	(A1)+,160*1(A2)
	MOVE	(A1)+,160*2(A2)
	MOVE	(A1)+,160*3(A2)
	MOVE	(A1)+,160*4(A2)
	MOVE	(A1)+,160*5(A2)
	MOVE	(A1)+,160*6(A2)
	MOVE	(A1)+,160*7(A2)
	MOVE	(A1)+,160*8(A2)
	MOVE	(A1),160*9(A2)
	SUB	#18,A1
	MOVE.L	sys_scr2,A2
	ADD	D1,A2
	MOVE	(A1)+,(A2)
	MOVE	(A1)+,160*1(A2)
	MOVE	(A1)+,160*2(A2)
	MOVE	(A1)+,160*3(A2)
	MOVE	(A1)+,160*4(A2)
	MOVE	(A1)+,160*5(A2)
	MOVE	(A1)+,160*6(A2)
	MOVE	(A1)+,160*7(A2)
	MOVE	(A1)+,160*8(A2)
	MOVE	(A1),160*9(A2)
	SUB	#18,A1
	MOVE.L	sys_scr3,A2
	ADD	D1,A2
	MOVE	(A1)+,(A2)
	MOVE	(A1)+,160*1(A2)
	MOVE	(A1)+,160*2(A2)
	MOVE	(A1)+,160*3(A2)
	MOVE	(A1)+,160*4(A2)
	MOVE	(A1)+,160*5(A2)
	MOVE	(A1)+,160*6(A2)
	MOVE	(A1)+,160*7(A2)
	MOVE	(A1)+,160*8(A2)
	MOVE	(A1),160*9(A2)
	SUB	#18,A1
	MOVE.L	sys_scr4,A2
	ADD	D1,A2
	MOVE	(A1)+,(A2)
	MOVE	(A1)+,160*1(A2)
	MOVE	(A1)+,160*2(A2)
	MOVE	(A1)+,160*3(A2)
	MOVE	(A1)+,160*4(A2)
	MOVE	(A1)+,160*5(A2)
	MOVE	(A1)+,160*6(A2)
	MOVE	(A1)+,160*7(A2)
	MOVE	(A1)+,160*8(A2)
	MOVE	(A1),160*9(A2)
	ADDQ	#8,D1

affcurseur

	CURS

	MOVE.L	D1,cursoroffset

fgestcurs

	MOVEM.L	(SP)+,D0-D1/A0-A2
	RTE

waiting
	DC.W	0
cptwaiting
	DC.W	0
cptvbl
	DC.W	25
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
		cmp	CDX,YA	     ;ligne visible ?
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
		blt.s	nopoly
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
		move.l	sys_scr4(PC),ECRAN
		add	muls160-mask(PTRMASK,RESULT.W),ECRAN
		add	RESULT,PTRTABLE			;debut table
dlrep
		move.w	(PTRTABLE)+,X0		;X1
		move.w	200*2-2(PTRTABLE),MINY	;X0

		cmp	#319,X0
		ble.s	X0sup319
		move.w	#319,X0
X0sup319
		tst	MINY
		bge	MINYsup0
		moveq	#0,MINY
MINYsup0				
		cmp	MINY,X0
		bge.s	lcontinuer
		lea	160(ECRAN),ECRAN
		dbf	MAXY,dlrep
		rts
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
		DC.B	'1990 BY ALGERNON        '
ffill3
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6,-(ECRAN)
		bra	ffillfin
		DC.B	'                        '
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
		DC.B	'            '
ffill16
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		movem.l	REG1/REG2/REG3/REG4/REG5/REG6/REG7/REG8,-(ECRAN)
		bra	ffillfin
		DS.B	32-20
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
	LEA	BUFFER_Z,A5
	LEA	NEW(PC),A6
	MOVE.L	A6,A4
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
	SUB	DIST,D5

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
	ADD	#200/2,D7


	MOVE	D6,(A1)+
	MOVE	D7,(A1)+

	MOVE.L	A6,A4
	MOVE	(A2)+,D1
	BNE.S	BCPTS
FCALCOBJ:
	RTS

TRACEOBJ:
	LEA	PROJETES(PC),A1
	BRA.S	RFACETTES
HIDEFACETTE
	LEA	12(A2),A2
RFACETTES
	MOVE.B	(A2)+,D0
	BEQ	FFACETTES			;Derniäre facette ?
RFACETTE2
	AND.B	DETAIL(PC),D0		
	BNE.S	REDETAIL			;C'est un detail ?
	LEA	15(A2),A2
	BRA.S	RFACETTES	
REDETAIL

	LEA	PROJETES(PC),A1

	CLR	D0
	MOVE.B	(A2)+,D0
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A1,D0.W),D1/D2			;lire XA,YA

	CLR	D0
	MOVE.B	(A2)+,D0
	ADD	D0,D0
	ADD	D0,D0
	MOVEM	(A1,D0.W),D3/D4			;lire XB,YB

	CLR	D0
	MOVE.B	(A2)+,D0
	ADD	D0,D0
	ADD	D0,D0
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
	REPT	7
	CLR	D0
	MOVE.B	(A5)+,D0
	BEQ.S	FRPOINT
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),(A4)+
	ADDQ	#1,D6
	ENDR

	CLR	D0
	MOVE.B	(A5)+,D0
	BEQ.S	FRPOINT
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),(A4)
	ADDQ	#1,D6

FRPOINT
	ADDQ	#6,A2
	MOVE	(A2)+,D7

	MOVE.L	A2,-(SP)
	JSR	polygone(PC)
	MOVE.L	(SP)+,A2

	MOVE.L	(A2)+,D0
	BNE.S	SOUSOBJDRAW

	MOVE.B	(A2)+,D0
	BNE	RFACETTE2
FFACETTES
	RTS

SOUSOBJDRAW
	MOVE.L	A2,-(SP)
	MOVE.L	D0,A2

	LEA	PROJETES2(PC),A1
	JSR	CALCOBJ(PC)

	MOVE.W	(A2)+,D7
	BLT	FINSOUSOBJ		; < 0 stop

SOUSOBJREP
	
	LEA	PROJETES2(PC),A1
	LEA	SEGMENTS(PC),A6
	MOVE.L	A6,A4
	MOVE.L	A2,A3
	

	REPT	3
	CLR	D0
	MOVE.B	(A3)+,D0
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),(A4)+
	ENDR
	MOVEQ	#3,D6

	REPT	4
	CLR	D0
	MOVE.B	(A3)+,D0
	BLT.S	FSOUSOBJ
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),(A4)+
	ADDQ	#1,D6
	ENDR

	CLR	D0
	MOVE.B	(A3)+,D0
	BLT.S	FSOUSOBJ
	ADD	D0,D0
	ADD	D0,D0
	MOVE.L	(A1,D0.W),(A4)
	ADDQ	#1,D6


FSOUSOBJ

	MOVE.L	A2,-(SP)
	jsr	polygone(PC)
	MOVE.L	(SP)+,A2

	ADDQ	#8,A2
	MOVE.W	(A2)+,D7

	BGE	SOUSOBJREP

FINSOUSOBJ
	MOVE.L	(SP)+,A2

	MOVE.B	(A2)+,D0
	BNE	RFACETTE2	
	RTS

;--------- affiche un objet fil de fer ------------

FILDEFER
	LEA	PROJETES2(PC),A1
	JSR	CALCOBJ(PC)
	LEA	PROJETES2(PC),A1

	CLR	D7
	MOVE.B	(A2)+,D7
FILDEFERREP
	ADD	D7,D7
	ADD	D7,D7
	MOVEM	(A1,D7.W),D0-D1

	CLR	D7
	MOVE.B	(A2)+,D7
	ADD	D7,D7
	ADD	D7,D7
	MOVEM	(A1,D7.W),D2-D3

	MOVE.L	sys_scr4(PC),A0
	MOVEM.L	A1-A2,-(SP)
	JSR	line(PC)
	MOVEM.L	(SP)+,A1-A2

	MOVE.B	(A2)+,D7
	BNE.S	FILDEFERREP
	RTS





COULEUR:
	DC.W	1

PRECALCULE_Z

	LEA	BUFFER_Z-512,A0
	MOVE	#-256,d5
PRECZ
	MOVE	D5,D0
	ADD	#-$12C,D0
	MOVE.L	#32767/2*($1F0/1),D1
	DIVS	D0,D1
	MOVE	D1,(A0)+
	ADDQ	#1,D5
	CMP	#256,D5
	BNE.S	PRECZ
	RTS








****************************************************************
;	A0 -> adresse de la chaine 
;	A1 -> adresse ecran
;

AFFSTRING:
	lea	FONT16X10(PC),A2
	MOVE.L	A1,A4
RRAFFSTR
	CLR	D0
	MOVE.B	(A0)+,D0
	BEQ.S	FAFFSTRING
RAFFSTRING
	CMP	#13,D0
	BNE	NOTCHR13
	LEA	160*10(A1),A1
	MOVE.L	A1,A4
	BRA.S	RRAFFSTR
NOTCHR13
	SUB.B	#32,D0
	MOVE	D0,D1
	ADD	D1,D1
	ADD	D1,D1
	LSL	#4,D0
	ADD	D1,D0
	MOVE.L	A2,A3
	ADD	D0,A3
	MOVE.W	(A3)+,(A4)
	MOVE.W	(A3)+,160*1(A4)
	MOVE.W	(A3)+,160*2(A4)
	MOVE.W	(A3)+,160*3(A4)
	MOVE.W	(A3)+,160*4(A4)
	MOVE.W	(A3)+,160*5(A4)
	MOVE.W	(A3)+,160*6(A4)
	MOVE.W	(A3)+,160*7(A4)
	MOVE.W	(A3)+,160*8(A4)
	MOVE.W	(A3)+,160*9(A4)
	ADDQ	#8,A4	
	
	CLR	D0
	MOVE.B	(A0)+,D0
	BNE.S	RAFFSTRING
FAFFSTRING
	RTS
FONT16X10
	INCBIN	'FONT16X10.BIN'
	        		



************* AFFICHE UNE CHAINE FONT **************************

TEXTSCROLLER:
		lea	190*160(A0),A0
		REPT	10
		MOVEM.L	(A1)+,D0-D7/A1-A6
		MOVEM.L D0-D7/A1-A6,-64(A0)
		MOVEM.L	(A1)+,D0-D7/A1-A6
		MOVEM.L D0-D7/A1-A6,-64(A0)
		MOVEM.L	(A1)+,D0-D7/A1-A2
		MOVEM.L D0-D7/A1-A2,-48(A0)
		ENDR
		MOVE.L	textptr(PC),A0
		MOVE	textcpt(PC),D0
		ADDQ	#4,D0
		AND	#$F,D0
		BEQ.S	NOTNEWCARACT
		ADDQ	#1,A0
NOTNEWCARACT
		MOVE.B	(A0)+,D1
		BNE.S	PASWRAP
		LEA	texte(PC),A0
		MOVE.B	(A0)+,D1
PASWRAP
		MOVE.L	A0,textptr
		MOVE	D1,D2
		LSL	#4,D1
		ADD	D2,D2
		ADD	D2,D2
		ADD	D2,D1	;*20
		
;		MOVE.L	XXX,A0
		LEA	190*160+152(A0),A0

		LEA	FONT16X10(PC),A1
		MOVEM	(A1,D2.W),D1-D5
		LSR	D0,D1
		LSR	D0,D2
		LSR	D0,D3
		LSR	D0,D4
		LSR	D0,D5
		MOVE.W	D1,0*160(A0)
		MOVE.W	D1,1*160(A0)
		MOVE.W	D2,2*160(A0)
		MOVE.W	D3,3*160(A0)
		MOVE.W	D4,4*160(A0)
		MOVEM	10(A1,D2.W),D1-D5
		LSR	D0,D1
		LSR	D0,D2
		LSR	D0,D3
		LSR	D0,D4
		LSR	D0,D5
		MOVE.W	D1,5*160(A0)
		MOVE.W	D1,6*160(A0)
		MOVE.W	D2,7*160(A0)
		MOVE.W	D3,8*160(A0)
		MOVE.W	D4,9*160(A0)
		RTS
textcpt:	
		DC.W	0
textptr:
		DC.L	texte
texte:
		DC.B 	'          CECI EST UN ESSAI DE SCROLLING '
		DC.B	'					  ',0
		even

VROTX	DC.W	0
VROTY	DC.W	2
VROTZ	DC.W	0
DIST	DC.W	30
ROTX	DC.B	$30
ROTY	DC.B	$0
ROTZ	DC.B	$0
DETAIL  DC.B	$FF
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



;----------------- effacement de l'ecran 1 plans --------------
clearplane1
	move.l		sys_scr4(PC),A0
	bra		bclearplane1

;----------------- effacement de l'ecran 4 plans --------------



ffastcls:
	move.l		sys_scr4(PC),A0
	lea		160*(199-12)(A0),A0
	moveq.l		#0,D0
	move.l		D0,D1
	move.l		D0,D2
	move.l		D0,D3
	move.l		D0,D4
	move.l		D0,D5
	move.l		D0,D6
	move.l		D0,D7
	move.l		D0,A1
	move.l		D0,A2
	move.l		D0,A3
	move.l		D0,A4
	move.l		D0,A5
	move.l		D0,A6
	bra		bfastcls

************************************************************
	SECTION DATA
************************************************************

objets:
	DC.L		chiffre
	DC.W		0,2,0
	DC.W		20
	DC.B		10,0,0,$EF
	DC.W		100

	DC.L		chiffre
	DC.W		0,2,0
	DC.W		20
	DC.B		10,0,0,$FD
	DC.W		100 

	DC.L		chiffre
	DC.W		0,2,0
	DC.W		20
	DC.B		10,0,0,$F
	DC.W		100



	DC.L		car
	DC.W		0,2,0
	DC.W		110	
	DC.B		40,0,0,$FF
	DC.W		400

	DC.L		grille
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		scareface
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,$FF
	DC.W		300

	DC.L		torus
	DC.W		1,2,3
	DC.W		40
	DC.B		0,0,0,$FF
	DC.W		300

	DC.L		spider2
	DC.W		1,2,3
	DC.W		100
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		car
	DC.W		0,3,0
	DC.W		110	
	DC.B		40,0,0,$FF
	DC.W		500


	DC.L		vcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		rcube
	DC.W		1,2,3
	DC.W		60
	DC.B		0,0,0,$FF
	DC.W		200

	DC.L		0

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

	DC.B	$FF,7,2,11,6,0,0,0,0,0
	DC.W	5*8
	DC.L	0
	DC.B	$FF,4,10,3,5,0,0,0,0,0
	DC.W	5*8
	DC.L	0

;       cotes      


	DC.B	$FF,3,10,9,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	DC.B	$FF,11,2,8,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0

;	dessous

	DC.B	$FF,11,8,9,10,0,0,0,0,0
	DC.W	3*8
	DC.L	0

;      reacteurs

	DC.B	$FF,10,0,1,11,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,6,11,1,0,0,0,0,0,0
	DC.W	1*8
	DC.L	0

	DC.B	$FF,4,0,10,0,0,0,0,0,0
	DC.W	1*8
	DC.L	0



;	dessus
	
	DC.B	$FF,1,0,3,2,0,0,0,0,0
	DC.W	4*8
	DC.L	spiper2trapppe

;	ailes dessus

	DC.B	$FF,6,1,2,7,0,0,0,0,0
	DC.W	3*8
	DC.L	0
	DC.B	$FF,3,0,4,5,0,0,0,0,0
	DC.W	3*8
	DC.L	0

;	cockpit

	DC.B	$FF,2,3,9,8,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.W	0

spiper2trapppe

	DC.W	-5,30,0
	DC.W	5,30,0
	DC.W	1,-10,0
	DC.W	0
	DC.W	12*8
	DC.B	2,1,0,$FF,$FF,$FF,$FF,$FF
	DC.W	$FFFF
	EVEN

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

	DC.B	$F0,5,1,0,4,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$F0,0,3,7,4,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$F0,3,2,6,7,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$F0,2,1,5,6,0,0,0,0,0
	DC.W	6*8
	DC.L	0

	;faces externes

	DC.B	$0F,1,0,3,2,0,0,0,0,0
	DC.W	2*8
	DC.L	0

	DC.B	$0F,5,6,7,4,0,0,0,0,0
	DC.W	15*8
	DC.L	0

	DC.B	$FF,5,4,0,1,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,0,4,7,3,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,3,7,6,2,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,2,6,5,1,0,0,0,0,0
	DC.W	6*8
	DC.L	0
	



	DC.B	$00					


	even


un
	DC.W	 30,-30,-40
	DC.W	 30, 30,-40
	DC.W	-30, 30,-40
	DC.W	-30,-30,-40
	DC.W	0
	DC.W	15*8
	DC.B	1,0,3,2,$FF,$FF,$FF,$FF
	DC.W	$FFFF
	

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

	DC.B	$FF,1,0,3,2,0,0,0,0,0
	DC.W	13*8
	DC.L	un

	DC.B	$FF,5,6,7,4,0,0,0,0,0
	DC.W	15*8
	DC.L	0

	DC.B	$FF,5,4,0,1,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,0,4,7,3,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,3,7,6,2,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,2,6,5,1,0,0,0,0,0
	DC.W	6*8
	DC.L	0
	
	DC.W	0


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

	DC.B	$FF,6,0,12,15,0,0,0,0,0
	DC.W	3*8
	DC.L	0


	; lunette arriere

	DC.B	$FF,18,21,15,12,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	; flanc droit	
	
	DC.B	$FF,5,0,1,2,3,4,0,0,0
	DC.W	2*8
	DC.L	roued

	; flanc gauche

	DC.B	$FF,7,6,11,10,9,8,0,0,0
	DC.W	2*8
 	DC.L	roueg

	; capot

	DC.B	$FF,11,5,4,10,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	; calandre

	DC.B	$FF,10,4,3,9,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	; feux arriere

	DC.B	$FF,1,0,6,7,0,0,0,0,0
	DC.W	4*8
	DC.L	feuxar

	; bas de caisse arriäre

	DC.B	$FF,2,1,7,8,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	
	; pare brise 

	DC.B	$FF,20,5,11,23,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	; pare brise droit

	DC.B	$FF,20,14,5,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	; pare brise gauche

	DC.B	$FF,23,11,17,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	


	; lunette droit

	DC.B	$FF,18,12,13,19,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	; lunette gauche

	DC.B	$FF,21,22,16,15,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	; lunette toit

	DC.B	$FF,18,19,22,21,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	; toit cockpit

	DC.B	$FF,19,20,23,22,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	; cockpit droit

	DC.B	$FF,13,14,20,19,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	; cockpit gauche

	DC.B	$FF,22,23,17,16,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	; bas de caisse

;	DC.B	$FF,3,2,8,9,0,0,0,0,0
;	DC.W	4*8
;	DC.L	0

	DC.W	0

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
	DC.W	7*8
	DC.B	0,1,5,4,$FF,$FF,$FF,$FF
	DC.W	7*8
	DC.B	6,7,3,2,$FF,$FF,$FF,$FF
	DC.W	$FFFF

	
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
	DC.W	15*8
	DC.B	0,1,2,3,4,5,6,7
	DC.W	15*8
	DC.B	8,9,10,11,12,13,14,15
	DC.W	$FFFF

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
	DC.W	15*8
	DC.B	7,6,5,4,3,2,1,0
	DC.W	15*8
	DC.B	15,14,13,12,11,10,9,8
	DC.W	$FFFF


mine:
	DC.W	-10,20,0
	DC.W	10,20,0
	DC.W	20,10,0
	DC.W	20,-10,0
	DC.W	10,-20,0
	DC.W	-10,-20,0
	DC.W	-20,-10,0
	DC.W	-20,10,0
	DC.W	1,1,50
	DC.W	0

	DC.B	$FF,0,1,8,0,0,0,0,0
	DC.W	10*8
	DC.L	0

	DC.B	$FF,2,3,8,0,0,0,0,0
	DC.W	7*8
	DC.L	0

	DC.B	$FF,4,5,8,0,0,0,0,0
	DC.W	10*8
	DC.L	0

	DC.B	$FF,6,7,8,0,0,0,0,0
	DC.W	7*8
	DC.L	0

	DC.B	$FF,0,8,1,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,2,8,3,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,4,8,5,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,6,8,7,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.W	0

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

	DC.B	$FF,16,0,7,23,0,0,0,0,0
	DC.W	8*4
	DC.L	0
	DC.B	$FF,17,1,0,16,0,0,0,0,0
	DC.W	9*4
	DC.L	0
	DC.B	$FF,18,2,1,17,0,0,0,0,0
	DC.W	8*4
	DC.L	0
	DC.B	$FF,19,3,2,18,0,0,0,0,0
	DC.W	9*4
	DC.L	0
	DC.B	$FF,20,4,3,19,0,0,0,0,0
	DC.W	8*4
	DC.L	0
	DC.B	$FF,21,5,4,20,0,0,0,0,0
	DC.W	9*4
	DC.L	0
	DC.B	$FF,22,6,5,21,0,0,0,0,0
	DC.W	8*4
	DC.L	0
	DC.B	$FF,23,7,6,22,0,0,0,0,0
	DC.W	9*4
	DC.L	0
	DC.B	$FF,16,0,7,23,0,0,0,0,0
	DC.W	8*4
	DC.L	0

	;faces dessus

	DC.B	$FF,0,1,9,8,0,0,0,0,0
	DC.W	4*4
	DC.L	0
	DC.B	$FF,1,2,10,9,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,2,3,11,10,0,0,0,0,0
	DC.W	4*4
	DC.L	0
	DC.B	$FF,3,4,12,11,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,4,5,13,12,0,0,0,0,0
	DC.W	4*4
	DC.L	0
	DC.B	$FF,5,6,14,13,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,6,7,15,14,0,0,0,0,0
	DC.W	4*4
	DC.L	0
	DC.B	$FF,7,0,8,15,0,0,0,0,0
	DC.W	5*4
	DC.L	0

	;faces dessous

	DC.B	$FF,9,17,16,8,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,10,18,17,9,0,0,0,0,0
	DC.W	6*4
	DC.L	0
	DC.B	$FF,11,19,18,10,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,12,20,19,11,0,0,0,0,0
	DC.W	6*4
	DC.L	0
	DC.B	$FF,13,21,20,12,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,14,22,21,13,0,0,0,0,0
	DC.W	6*4
	DC.L	0
	DC.B	$FF,15,23,22,14,0,0,0,0,0
	DC.W	5*4
	DC.L	0
	DC.B	$FF,8,16,23,15,0,0,0,0,0
	DC.W	6*4
	DC.L	0



	DC.W	0
	

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

	DC.B	$FF,1,0,4,5,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$FF,2,6,7,3,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$FF,8,1,5,0,0,0,0,0,0
	DC.W	2*8
	DC.L	0
	DC.B	$FF,9,6,2,0,0,0,0,0,0
	DC.W	2*8
	DC.L	0
	DC.B	$FF,10,0,1,8,0,0,0,0,0
	DC.W	3*8
	DC.L	0
	DC.B	$FF,3,11,9,2,0,0,0,0,0
	DC.W	3*8
	DC.L	0
	DC.B	$FF,8,5,6,9,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	DC.B	$FF,12,10,8,0,0,0,0,0,0
	DC.W	5*8
	DC.L	0
	DC.B	$FF,13,9,11,0,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	;face

	DC.B	$FF,4,14,15,7,0,0,0,0,0
	DC.W	5*8
	DC.L	scarebouche

	DC.B	$FF,14,4,0,16,0,0,0,0,0
	DC.W	4*8
	DC.L	0
	DC.B	$FF,7,15,17,3,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,16,0,10,0,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,11,3,17,0,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,10,12,16,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,11,17,13,0,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,13,12,8,9,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,14,18,19,15,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,16,20,18,14,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,21,17,15,19,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,22,12,13,23,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,22,20,16,12,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,23,13,17,21,0,0,0,0,0
	DC.W	5*8
	DC.L	0

	DC.B	$FF,22,23,25,24,0,0,0,0,0
	DC.W	4*8
	DC.L	0

	DC.B	$FF,22,24,20,0,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,23,21,25,0,0,0,0,0,0
	DC.W	3*8
	DC.L	0

	DC.B	$FF,20,24,18,0,0,0,0,0,0
	DC.W	2*8
	DC.L	0

	DC.B	$FF,21,19,25,0,0,0,0,0,0
	DC.W	2*8
	DC.L	0

	DC.B	$FF,24,25,19,18,0,0,0,0,0
	DC.W	3*8
	DC.L	0


	DC.W	0

scarebouche	
	DC.W	-10,-20,-10
	DC.W	10,-20,-10
	DC.W	10,-30,-15
	DC.W	-10,-30,-15
	DC.W	0
	DC.W	0*8
	DC.B	0,3,2,1,0,0,0,0
	DC.W	$FFFF


chiffre:
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

	DC.B	$01,1,0,2,3,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$02,0,6,4,2,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$04,1,3,5,7,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$08,5,4,6,8,9,7,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$10,6,12,10,8,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$20,9,11,13,7,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.B	$40,10,12,13,11,0,0,0,0,0
	DC.W	9*8
	DC.L	0
	DC.W	0
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
        DC.B    $FF,0,5,6,1,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,1,6,7,2,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,2,7,8,3,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,3,8,9,4,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,5,10,11,6,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,6,11,12,7,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,7,12,13,8,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,8,13,14,9,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,10,15,16,11,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,11,16,17,12,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,12,17,18,13,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,13,18,19,14,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,15,20,21,16,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,16,21,22,17,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,17,22,23,18,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,18,23,24,19,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,6,5,0,1,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,7,6,1,2,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,8,7,2,3,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,9,8,3,4,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,11,10,5,6,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,12,11,6,7,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,13,12,7,8,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,14,13,8,9,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,16,15,10,11,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.B    $FF,17,16,11,12,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,18,17,12,13,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,19,18,13,14,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,21,20,15,16,0,0,0,0,0
        DC.W    8*5
        DC.L    0
        DC.B    $FF,22,21,16,17,0,0,0,0,0
        DC.W    8*2
        DC.L    0
        DC.B    $FF,23,22,17,18,0,0,0,0,0
        DC.W    8*3
        DC.L    0
        DC.B    $FF,24,23,18,19,0,0,0,0,0
        DC.W    8*4
        DC.L    0
        DC.W     0



palette
	DC.W	$000,$777,$770,$777,$504,$777,$770,$777
	DC.W	$007,$777,$770,$777,$504,$777,$770,$777
palette2:
	DC.W	$000,$777,$013,$024,$035,$046,$057,$700
	DC.W	$720,$740,$760,$770,$212,$434,$656,$777



TITRE:	
	;        XXXXXXXXXXXXXXXXXXXX

	DC.B	13
	DC.B	'THE ALGERNON CONCEPT',13,13,13
	DC.B	' F1          SPIDER',13
	DC.B	' F2            CUBE',13
	DC.B	' F3            CUBE',13
	DC.B	' F4            CUBE',13
	DC.B	' F5            CUBE',13
	DC.B	' F6            CUBE',13
	DC.B	' F7            CUBE',13
	DC.B	' F8            CUBE',13
	DC.B	' F9            CUBE',13
	DC.B	' F10           CUBE',13,13,13,13,13
	DC.B	'  PRESS ESC TO QUIT ',0

	
	

************************************************************
    SECTION 	BSS
************************************************************

bfastcls:
	DS.L	4000
NEW	DS.W	9		
PROJETES:
	DS.L	64
PROJETES2:
	DS.L	64
SEGMENTS
	DS.L	128
	DS.W	512
BUFFER_Z
 	DS.W	512	;BUFFER CONTIENT LES DIFFERENTES PROFONDEURS
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
bclearplane1:
	DS.L	4002
screen2:	
	ds.b	96256	;buffer ecran 2
userstack:
	ds.l	1	
endstack:
	ds.l	100
mystack:		
	end
	    
    








































