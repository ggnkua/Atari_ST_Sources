LOAD=$40000
MUS=1
; JOUE TOUTES LES MUSIQUES D'UN FICHIER !!!
;
; NOUVELLE VERSION :
;	CALCULE LES INSTRUMENTS UTILISES
;
;	MODFREQ
;	MODVOL
;
;	opt	o+
;	opt	ow-
;
; replay COSO
;
; ce qu'il faut rajouter :
;	compteur de notes (permet de calculer la longueur des musiques)
;	cf count
;	calculer fin des musiques … sauver (cf L930)
;	cf endvoice
;	TFMX->COSO
;
; ‚diteur :
;	MadMax n'utilise pas les fonctions de vibrato de Whittaker
;	 ni sa batterie !!!
;
; optimisations en minuscules
; … faire :
;
; a2->a1
;
; exemple :
;
	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	moveq	#MUS,d0
MEGACNT:
	clr.l	count
	LEA	LOAD,A0
	MOVE	D0,CURMUS
	bsr	initmus
	clr	voicefin
BOUCLE:
	cmp.b	#$38,$fffffc02.w
	beq.s	nowait

	MOVE	#37,-(SP)
	TRAP	#14
	ADDQ	#2,SP

	MOVE	#5000,D0
WAIT:	DBRA	D0,WAIT
nowait:
	addq.l	#1,count
	MOVE	#$700,$FFFF8240.W
	BSR	PLAYMUS
	CLR	$FFFF8240.W

	cmp	#3,voicefin
	beq.s	finito

	MOVE	#$FF,-(SP)
	MOVE	#6,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	TST	D0
	BEQ.S	BOUCLE
	BRA	FINISH
finito:

	moveq	#0,d0
	bsr	initmus

	move.l	count,d7
	add.l	d7,d7
	move.l	d7,d6
	add.l	#50,d6		;arrondit … la seconde
	divu	#100,d6
	bvs	BUG
	swap	d6
	clr	d6
	swap	d6
;
; temps en secondes
;
	move.l	d6,d0
	bsr	affiche
	pea	cr(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move.l	d6,d0
	divu	#60,d0
	swap	d0
	clr	d0
	swap	d0
	bsr	affiche
	move	#"'",-(sp)
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	move.l	d6,d0
	divu	#60,d0
	clr	d0
	swap	d0
	bsr	affiche

	pea	cr(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	MOVE	CURMUS,D0
	ADDQ	#1,D0

	CMP	LOAD+$30,D0
	BLS	MEGACNT

	PEA	COUNT1(PC)
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP

	LEA	MODFREQ,A6
	BSR	COMPUTE

	PEA	COUNT2(PC)
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP

	LEA	MODVOL,A6
	BSR	COMPUTE

FINISH:
	lea	LOAD,a0
	move.l	endvoice,a1

NOT0:
	ADDQ	#6,A1
	TST.L	(A1)
	BNE.S	NOT0
	TST	4(A1)
	BNE.S	NOT0

	move.l	count,d0
	add.l	d0,d0		;en centiŠmes

	illegal

BUG:
	MOVEQ	#-1,D0
	ILLEGAL

COMPUTE:
	moveq	#0,d6
	MOVEQ	#0,D7
TESTCP:
	TST.B	(A6)+
	BEQ.S	NOTUSED

	tst	d6
	beq.s	none
	MOVE	#',',-(SP)
	MOVE	#2,-(SP)
	TRAP	#1
	ADDQ	#4,SP
none:
	addq	#1,d6
	MOVE.L	D7,D0
	BSR	affiche
NOTUSED:
	ADDQ.B	#1,D7
	BNE.S	TESTCP

	pea	cr(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	RTS
COUNT1:	DC.B	"MODFREQ USED :",13,10,0
COUNT2:	DC.B	"MODVOL USED :",13,10,0
	EVEN
;
; traduit un nombre en d‚cimal
;
affiche:
	clr	-(sp)
deci1:
	divu	#10,d0
	swap	d0
	add	#'0',d0
	move	d0,-(sp)
	clr	d0
	swap	d0
	bne.s	deci1
deci2:
	move	#2,-(sp)
	trap	#1
	addq	#4,sp
	tst	(sp)
	bne.s	deci2
	addq	#2,sp
	rts
cr:	dc.b	13,10,0
	even

CURMUS:	DC.W	0
voicefin:dc.w	0
count:	dc.l	0
endvoice:dc.l	0
;	rsreset

off22=0	;rs.l	1	;ptr courant dans pattern
off0=4	;rs.l	1	;ptr base patterns
off34=8	;rs.l	1	;ptr fin musique

off4=12	;rs.w	1	;ptr patterns (.W au lieu de .L)
offa=14	;rs.l	1	;ptr base modulation volume
offe=18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12=20	;rs.l	1	;ptr base modulation fr‚quence
off30=24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38=26	;rs.l	1	;incr‚ment pour crescendo

off8=30	;rs.b	1
off9=31	;rs.b	1

off16=32	;rs.b	1
off17=33	;rs.b	1
off18=34	;rs.b	1
off19=35	;rs.b	1
off1a=36	;rs.b	1
off1b=37	;rs.b	1
off1c=38	;rs.b	1
off1d=39	;rs.b	1
off1e=40	;rs.b	1
off1f=41	;rs.b	1
off21=42	;rs.b	1

off26=43	;rs.b	1
off27=44	;rs.b	1
off28=45	;rs.b	1	;15-volume sonore de la voix
off2a=46	;rs.b	1	;0,1 ou 2=type de son
off2b=47	;rs.b	1
off2c=48	;rs.b	1
off2d=49	;rs.b	1	;volume sonore calcul‚
off2e=50	;rs.b	1
off3c=52	;equ	(__RS+1)&-2
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

	cmp.l	#'MMME',32(a0)
	seq	mmme-PSGREG(a6)

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
PLAYMUS:
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
	move	d0,$16(A6)
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
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
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
	BMI	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	LEA	MODVOL(PC),A1
	ADDQ.B	#1,(A1,D1.W)
	BNE.S	L31D
	ST	(A1,D1.W)
L31D:
	CMP	LOAD+$26,D1
	BLS.S	L311C
;
; WINGS1.PAK PLANTE ICI AVEC D1=$13
;
	CLR	$FFFF8240.W
	ILLEGAL
L311C:

	MOVE.L	L93C(PC),a1
	ADD	D1,D1

	TST	(A1,D1.W)
	BEQ	BUG

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
L37A:
	LEA	MODFREQ(PC),A1
	ADDQ.B	#1,(A1,D1.W)
	BNE.S	L37B
	ST	(A1,D1.W)
L37B:

	CMP	LOAD+$24,D1
	BLS.S	L311D
;
; CHAM1.MUS PLANTE ICI AVEC D1=$FF
;  contenu de off1f(a0)
;
	CLR	$FFFF8240.W
	ILLEGAL
L311D:

	MOVE.L	L938(PC),a1
	ADD	D1,D1

	TST	(A1,D1.W)
	BEQ	BUG

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

	LEA	MODFREQ(PC),A1
	ADDQ.B	#1,(A1,D1.W)
	BNE.S	L423
	ST	(A1,D1.W)
L423:
	CMP	LOAD+$24,D1
	BLS.S	L4302
	CLR	$FFFF8240.W
	ILLEGAL
L4302:

	ADD	D0,D0
	MOVE.L	L938(PC),A1

	TST	(A1,D0.W)
	BEQ	BUG

	MOVE	(A1,D0.W),A1
	ADD.L	L934(PC),A1
	MOVE.L	A1,off12(A0)
	clr	d6
	BRA	L3B6
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
L49A:
	CMP.B	#$EA,D0
	BNE.S	L49B
;	ILLEGAL
	move.b	#$20,off1f(a0)
	move.b	(a1)+,off9(a0)
	addq	#2,d6
	BRA	L3B6
L49B:
	CMP.B	#$EB,D0
	BLO.S	NODIG

	CMP.B	#$EC,D0
	BNE.S	PAEC
	ADDQ	#3,D6
	move	d6,off30(a0)
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	RTS
PAEC:
	CMP.B	#$EB,D0
	BNE.S	PAEB
	ADDQ	#1,D6
	BRA	L3B6
PAEB:
	CLR	$FFFF8240.W
	ILLEGAL
NODIG:
	cmp.b	#$E3,d0
	BNE.S	L4B0
	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:
	move	d6,off30(a0)

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
	tst.b	mmme-PSGREG(a6)
	bne	newrep

	MOVE.B	off2e(A0),d6
	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d4
	MOVE.B	off1c(A0),D4

	bclr	#7,d4		;nouveau replay
	beq.s	L1
	add.b	d4,d4
L1:

	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	d6
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	d6		;ou bchg
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	D4,D4
	CMP.B	D4,D1
	BCS.S	L5DA
	bchg	#7,d6
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
L5FA:
;	EOR.B	#1,d6		;inutilis‚ !!!
	MOVE.B	d6,off2e(A0)
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	asr.l	#4,d1		;lsr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:	MOVE.B	off2d(A0),D1

	MOVEQ	#-16,D4		;DEBUGGAGE VOLUME
	AND.B	D1,D4
	SUB.B	D4,D1

	SUB.B	off28(A0),D1
	BMI.S	NOVOL
	OR.B	D4,D1
	RTS
NOVOL:
	MOVE	D4,D1
	RTS
newrep:
	tst.b	off1e(a0)
	beq.s	L2
	subq.b	#1,off1e(a0)
	bra.s	L3
L2:
	clr	d1
	clr	d2
	clr	d3
	move.b	off1d(a0),d1
	move.b	off1c(a0),d2
	move	d2,d5
	add	d5,d5
	move.b	off1b(a0),d3
	move.b	off2e(a0),d4
	btst	#7,d4
	beq.s	L4
	sub	d3,d1
	bpl.s	L5
	clr	d1
	bchg	#7,d4
	bra.s	L5
L4:
	add	d3,d1
	cmp	d5,d1
	blo.s	L5
	move	d5,d1
	bchg	#7,d4
L5:
	move.b	d1,off1d(a0)
	move.b	d4,off2e(a0)
	sub	d2,d1
	muls	d0,d1
;	asr.l	#8,d1
;	asr.l	#2,d1
	asl.l	#6,d1
	swap	d1
	add	d1,d0
L3:
	btst	#5,off9(a0)
	beq.s	L6
	clr	d1
	move.b	off1f(a0),d1
	ext	d1
	ext.l	d1
	add.l	off38(a0),d1
	move.l	d1,off38(a0)
	muls	d0,d1
;	asr.l	#8,d1
;	asr.l	#2,d1
	asl.l	#6,d1
	swap	d1
	sub	d1,d0
L6:
	bra	L628

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
mmme:	dc.b	0
	even

voice0:	blk.B	off3c
voice1:	blk.B	off3c
voice2:	blk.B	off3c
L916:	DC.L	0
L91A:	DC.L	0
L934:	DC.L	0
L938:	DC.L	0
L93C:	DC.L	0

X:
MODFREQ:BLK.B	256,0
MODVOL:	BLK.B	256,0

