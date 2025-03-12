;
; 0=NORMAL
; 1=STE
; 2=REGISTRE 15 (MV16)
;
SORTIE_SON=0	;0=DIGIT NORMALE,1=STE
;VALUE=$48
VALUE=0
TRK=0		;0=FICHIER ALLDIG2.BIN DE DIGITS SEPAREES
TIMER=0		;0=TIMER A,1=TIMER B,2=TIMER C,3=TIMER D
FADE=1		;0=FADE,1=PAS DE FADE

	IFEQ	1
;
; CONVERSION DIGIT -> MV16
;
CONV1:	MOVE.B	(A3),D0
	EOR.B	#$80,D0
	BNE.S	1$
	MOVEQ	#1,D0
1$:	MOVE.B	D0,(A3)+
	CMP.L	A4,A3
	BLT.S	L0004
	CLR.B	-(A3)

L0065:
	MOVE.B	#$F,$FFFF8800.w
	MOVE.B	0.L,$FFFF8802.w
	BEQ.S	1$
	RTE
1$
	CLR.B	0.L		;FLAGDIGIT
	MOVE.B	#-$80,$FFFF8802.w
	AND.B	#$F,$FFFFFA1D.w
	RTE
	ENDC


	IFEQ	TIMER-0
EVENT=$FFFFFA1F
	ENDC
	IFEQ	TIMER-1
EVENT=$FFFFFA23
	ENDC

EQUALISEUR=0	;0=EQUALISEUR
;
; liste des registres inutilis‚s :
;	D4,A4,A5
;
; musiques … ripper :
;
;	- NINJA REMIX
;	- INTERNATIONAL KARATE + (??)
;	- LAP MUSIQUES
;	- ANCOOL (DD 2)
;	- TANGRAM
;
; musiques non converties :
;
;	- JAMBALA DIGIT
;	- CHAMBERS OF SHAOLIN
;
; int‚grer les fonctions suivantes :
;	- chronomŠtre
;	- comptage de cycles du replay
;	- red‚finition timer (au lieu de A !!!)
;	- mettre les labels originaux !!!
;	- mettre flag STE (DIGIT)
;	- mettre flag fin musique
;	- recleaner le code (au niveau des registres)
;
; nouveau replayer Madmax
;
; r‚‚crit par Mcoder (don't spread this source)
;
; caract‚ritiques :
;	- rejoue les formats COSO et les formats digits DIGI
;	   (utiliser le moulineur DIGIT.S)
;	   les TFMX doivent etre compress‚s avec COMPCOSO.S
;	   enlever les instruments digits inutilis‚s (OPTIM7.S)
;	   changer la fr‚quence des samples (CONVSPL6.S)
;	- replay trŠs rapide (6-7 rasterlines)
;	- utilise le timer A pour la digit (reconfigurable)
;	- entiŠrement relogeable
;	- marche sous le systŠme avec les flags ci-dessous
;
; diff‚rences avec le replay original :
;	- $EB coupe la digit (au lieu de $E7)
;	- $EC-aa-bb aa=num‚ro inst (0-FF),bb=valeur timer
;	   (au lieu de $EA)
;
; problŠmes connus :
;	- BEATNIC.MUS a un problŠme si on n'ex‚cute pas le replay
;	   dans la routine VBL.
;	- les musiques de TURRICAN exploitent un bug du pr‚c‚dent
;	   replay (pr‚sentement corrig‚)
;	- les musiques digits doivent se trouver dans une zone
;	   de 32K (avant ou aprŠs) par rapport au replay.
;
; ce qu'il faut impl‚menter :
;	- mettre les inits en (An)+
;	- inverser table conversion octets (pour gagner eor.b #$80,d2)
;	- flag init registre 12/13 dans INITMUSIC
;	- ‚diteur musique
;	- optimiseur COSO :
;		extrait les patterns de la musique que l'on veut
;		 dans un fichier COSO
;	- mettre les labels 'officiels'
;	- replay STE (digit !!!)
;	- enlever les suites de 64 '00' dans les patterns (bug compacteur
;	   Madmax !!!)
;	- enlever les octets inutilis‚s (=r‚f‚rences des musiques)
;	- les fr‚quences des digits sont les suivantes :
;		$3E=chamber of shaolin
;		$7A=Turrican
;		$65=toutes les autres
;
TYPE=2			;1=MUSIQUE NORMALE,2=MUSIQUE DIGIT
PRG=1			;0=PRG,1=REPLAY BINAIRE
MONOCHROM=1		;0=REPLAY MONOCHROME,1=REPLAY COULEUR
PCRELATIF=1		;0=DIGIT PRES DU REPLAY,1=DIGIT LOIN DU REPLAY
AEI=0			;0=REPLAY MODE AEI,1=MODE SEI

	ifeq	PRG
basemfp=$100
SYSTEM=0		;0=SYSTEME,1=SANS SYSTEME
CUTMUS=0		;0=INCLUT FIN MUSIQUE,1=ON NE PEUT COUPER LA MUSIQUE
	elseif
basemfp=$40
SYSTEM=1		;0=SYSTEME,1=SANS SYSTEME
	IFEQ	TYPE-1
CUTMUS=0		;0=INCLUT FIN MUSIQUE,1=ON NE PEUT COUPER LA MUSIQUE
	ELSEIF
CUTMUS=1		;0=INCLUT FIN MUSIQUE,1=ON NE PEUT COUPER LA MUSIQUE
	ENDC
	endc

DIGIMAD=1		;0=DIGITS 4 BITS
			;1=VOLUMES MADMAX
			;2=VOLUMES HOTLINE
			;3=VOLUMES MADMAX BIT 7 INVERSE

	IFEQ	TYPE-1
DIGIT=1			;0=INCLUT REPLAY DIGIT,1=SANS
MMME=1			;0=INCLUT REPLAY MMME,1=SANS
	ELSEIF
DIGIT=0			;0=INCLUT REPLAY DIGIT,1=SANS
MMME=0			;0=INCLUT REPLAY MMME,1=SANS
	ENDC

TURRICAN=0		;0=REPLAY TURRICAN
OLD=0			;0=ANCIENNE VERSION,1=NOUVELLE

	OPT	O+,OW2-
	OUTPUT	REPLAY.PRG
	IFNE	PRG
	OPT	P+
	ENDC

	output	replay.prg
	IFEQ	PRG
	PEA	CLS(PC)
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP

;	MOVE	SR,D0
;	AND	#$2000,D0
;	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	move.l	d0,pushusp
;SUPER:
	MOVE	#$2700,SR
	MOVE.L	$70.W,SAVVBL
	MOVE.L	#VBL,$70.W
	MOVE.B	$FFFFFA07.W,SAVFA07
	MOVE.B	$FFFFFA09.W,SAVFA09
	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	clr.b	$fffffa0f.w
	clr.b	$fffffa11.w
	MOVE	#$2300,SR

	IFEQ	TRK
	LEA	MUSIC,A0
	MOVEQ	#SORTIE_SON,D0
	BSR	BASE+0
	ENDC

	MOVEQ	#1,D0
MAIN:
	LEA	MUSIC,A0
	IFEQ	TRK
	BSR	BASE+4
	ELSEIF
	BSR	BASE+0		;INIT MUSIQUE
	ENDC
LOOP:
	MOVE.L	$466.W,D0
.WW	CMP.L	$466.W,D0
	BEQ.S	.WW

;	MOVE	#5000,D0
;.WAIT	DBRA	D0,.WAIT

	LEA	$FFFF8209.W,A0
.WAIT	MOVE.B	(A0),D0
	BEQ.S	.WAIT
	NOT	D0
	LSR	D0,D0

	move	#$700,$ffff8240.w
	IFEQ	TRK
	BSR	BASE+8
	ELSEIF
	BSR	BASE+4
	ENDC
	clr	$ffff8240.w

	clr	d0
	MOVE.B	$FFFFFC02.W,D0
	CMP.B	#$39,D0
	beq.s	.fini
	SUB	#$3B,D0		;F1->F10
	CMP	#10,D0
	BHS.S	LOOP
	addq	#1,d0
	move	d0,-(sp)
	MOVEQ	#0,D0
	IFEQ	TRK
	BSR	BASE+4
	ELSEIF
	BSR.S	BASE+0
	ENDC
	move	(sp)+,d0
	bra.s	MAIN
.fini
	MOVEQ	#0,D0
	IFEQ	TRK
	BSR	BASE+4
	ELSEIF
	BSR.S	BASE+0
	ENDC

	MOVE	#$2700,SR
	MOVE.L	SAVVBL,$70.W
	MOVE.B	SAVFA07,$FFFFFA07.W
	MOVE.B	SAVFA09,$FFFFFA09.W
.IKBD	TST.B	$FFFFFC00.W
	BPL.S	.VIDE
	TST.B	$FFFFFC02.W
	BRA.S	.IKBD
.VIDE
	clr.b	$fffffa0f.w
	clr.b	$fffffa11.w
	move	#$2300,sr
	move.L	pushusp(pc),-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	illegal
	clr	-(sp)
	trap	#1
VBL:	ADDQ.L	#1,$466.W
	RTE
pushusp:ds.l	1
SAVVBL:	DS.L	1
SAVFA07:DS.B	1
SAVFA09:DS.B	1
CLS:	DC.B	27,'E',0
	EVEN
	ENDC

	rsreset

off22	rs.l	1	;ptr courant dans pattern
off0	rs.l	1	;ptr base patterns
off34	rs.w	1	;ptr fin musique

off4	rs.w	1	;ptr patterns (.W au lieu de .L)
offa	rs.l	1	;ptr base modulation volume
offe	rs.w	1	;ptr modulation volume (.W au lieu de .L)
off12	rs.l	1	;ptr base modulation fr‚quence
off30	rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

off38	rs.l	1	;incr‚ment pour crescendo

off8	rs.b	1
off9	rs.b	1

off16	rs.b	1
off17	rs.b	1
off18	rs.b	1
off19	rs.b	1
off1a	rs.b	1
off1b	rs.b	1
off1c	rs.b	1
off1d	rs.b	1
off1e	rs.b	1
off1f	rs.b	1
off21	rs.b	1

off26	rs.b	1
off27	rs.b	1
off28	rs.b	1	;15-volume sonore de la voix
off2a	rs.b	1	;0,1 ou 2=type de son
off2b	rs.b	1
off2c	rs.b	1
off2d	rs.b	1	;volume sonore calcul‚
off2e	rs.b	1
off3c	equ	(__RS+1)&-2

BASE:
	IFEQ	DIGIT
	BRA.W	INITDIGIT
	ENDC

	bra.w	INITMUSIC

	IFEQ	FADE
	BRA.W	PLAYMUSIC

	AND.B	#$1F,D0
	LEA	FADEMUS(PC),A0
	MOVE.B	D0,(A0)+
	MOVE.B	D0,(A0)+
	CLR.B	(A0)+
	RTS
	ENDC

PLAYMUSIC:
	LEA	PSGREG(PC),A6
;
; DEBUT PLAYMUSIC
;
	IFEQ	TRK
	TST.B	flagdigit-PSGREG(A6)
	BEQ.S	1$
	TST.B	SORTIE-PSGREG(A6)
	BEQ.S	1$
	BTST	#0,$FFFF8901.w
	BNE.S	1$
	CLR.B	flagdigit-PSGREG(a6)
1$
	ENDC

	IFEQ	FADE

	TST.B	FADE-PSGREG(A6)
	BEQ.S	.NOFADE
	SUBQ.B	#1,FADE+1-PSGREG(A6)
	BPL.S	.NOFADE
	MOVE.B	FADE-PSGREG(A6),FADE+1-PSGREG(A6)
	ADDQ	#1,FADE+2-PSGREG(A6)
	MOVE	FADE+2-PSGREG(A6),D0
	CMP	#10,D0
	BNE.S	.FADE
	CLR.L	FADE-PSGREG(A6)
	IFEQ	CUTMUS
	ST	BLOQUEMUS-PSGREG(A6)
	ENDC
	BRA	ZEROSND

.FADE
	LEA	L0047(PC),A0
	MOVE.B	(A0,D0.W),D0
	MOVE.B	D0,VOICE0+off28-PSGREG(A6)
	MOVE.B	D0,VOICE1+off28-PSGREG(A6)
	MOVE.B	D0,VOICE2+off28-PSGREG(A6)

.NOFADE
	ENDC

	IFEQ	CUTMUS
	TST.B	BLOQUEMUS-PSGREG(A6)
	BNE.S	L25A
;	BNE	ZEROSND
;	BEQ.S	L160
;	TAS	L813-PSGREG(A6)
;	BEQ	ZEROSND
;	BNE.S	L15E
;	clr.B	$22(A6)
;	clr.B	$26(A6)
;	clr.B	$2A(A6)
;	MOVEM.L	$1C(A6),D0-D3
;	MOVEM.L	D0-D3,$FFFF8800.W
;L15E:
;	RTS
;L160:
	ENDC

	IFEQ	MONOCHROM
	BTST	#1,$FFFF8260.W
	BEQ.S	.COULEUR
	ADD	#50*65536/70,DIVISEUR_VBL-PSGREG(A6)
	BCC.S	L25A
.COULEUR:
	ENDC

	move.b	#$C0,$1E(A6)		;pour que ‡a tienne...

	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR	L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:
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

	IFEQ	DIGIT
	TST.B	flagdigit-PSGREG(a6)
	bne.s	TRACKER
	ENDC
	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS

	IFEQ	DIGIT
TRACKER:
	or.b	#$24,$1e(a6)		;reg 7
	MOVEM.L	(A6),D1-D7/A0-A2
	IFNE	SYSTEM
	MOVE	SR,D0
	MOVE	#$2700,SR
	ENDC
	MOVEM.L	D1-D7/A0-A2,$FFFF8800.W
	IFNE	SYSTEM
	MOVE.B	#$A,$FFFF8800.W
	MOVE	D0,SR
	ENDC
	IFEQ	EQUALISEUR
	MOVE.B	#$F,$2A(A6)
	ENDC
	RTS
	ENDC
;
; calcule nouvelle note
;
L25C:	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	off22(A0),A1
L26C:	MOVE.B	(A1)+,D0
	CMP.B	#$FD,D0
	BLO.S	L308
	EXT	D0
	ADD	D0,D0
	JMP	.CODEFD+3*2(PC,D0.W)
.CODEFD:
	BRA.S	L2F4		;$FD
	BRA.S	L2E2		;$FE
				;$FF

	IFEQ	OLD
; ANCIENNE VERSION
	moveq	#$c,d1
	add	off4(a0),d1
	cmp	off34(a0),d1
	blS.S	L288
	clr	d1
	IFEQ	EQUALISEUR
	ST	BOUCLE-PSGREG(A6)
	ENDC
L288:
	MOVE.L	off0(a0),a1
	add	d1,a1
	ELSEIF
; NOUVELLE VERSION
	move	off4(a0),d1
	cmp	off34(a0),d1
	blS.S	L288
	tst.b	off21(a0)		;nouveau replay !!!!
	bne.s	L288			;pour bien boucler !!!!
	clr	d1
	move	d5,off4+off3c(a0)
	move	d5,off4+off3c*2(a0)
	IFEQ	EQUALISEUR
	ST	BOUCLE-PRGREG(A6)
	ENDC
L288:
	MOVE.L	off0(a0),a1
	add	d1,a1
	add	#$C,d1
	ENDC

	move	d1,off4(a0)

	MOVEQ	#0,D1
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
L2C4:

	ADD	D1,D1
	MOVE.L	L934(PC),A1
	ADD	$C+2(A1),D1
	ADD	(A1,D1.W),A1

	MOVE.L	A1,off22(A0)
	BRA.s	L26C

L2E2:
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA.s	L26C
L2F4:
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,off22(A0)
	RTS

L308:	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	.L31C
	MOVE.B	(A1)+,off1f(A0)
.L31C:	MOVE.L	A1,off22(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L934(PC),A1

	CMP	$26(A1),D1
	BLS.S	.NOBUG2
	move	#$700,$ffff8240.w
	ILLEGAL
.NOBUG2
	ADD	D1,D1
	ADD	8+2(A1),D1
	ADD	(A1,D1.W),A1

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
	MOVE.L	L934(PC),A1
	CMP	$24(A1),D1
	BLS.S	.NOBUG3
	move	#$070,$ffff8240.w
	ILLEGAL
.NOBUG3
	ADD	D1,D1

	ADD	4+2(A1),D1
	ADD	(A1,D1.W),A1

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
	CMP.B	#$E0,D0
	BLO	L4B0
;	CMP.B	#$EA,D0		;inutile ???
;	BHS	L4B0

	EXT	D0
	ADD	#32,D0
	MOVE.B	.CODES(PC,D0.W),D0
	JMP	.BRANCH(PC,D0.W)

.CODES
	DC.B	E0-.BRANCH
	DC.B	E1-.BRANCH
	DC.B	E2-.BRANCH
	DC.B	E3-.BRANCH
	DC.B	E4-.BRANCH
	DC.B	E5-.BRANCH
	DC.B	E6-.BRANCH
	DC.B	E7-.BRANCH
	DC.B	E8-.BRANCH
	DC.B	E9-.BRANCH
	DC.B	EA-.BRANCH
	IFEQ	DIGIT
	DC.B	EB-.BRANCH
	DC.B	EC-.BRANCH
	ENDC
	EVEN
.BRANCH:

	IFEQ	PRG
BUG:	DCB.L	2,$4A780001
;	DCB.L	$100-$EA,$4A780001
	ENDC

E1:	BRA	L4C01
E0:
	moveq	#$3f,d6		;$E0
;clr d6 … pr‚sent !!!!
	and.B	(A1),D6
	BRA.S	L3AE
E2:
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6

E9:
	IFEQ	DIGIT
	move	sr,D0
	move	#$2700,sr
	ENDC
	MOVE.B	#$B,$FFFF8800.W
	move.b	(A1)+,$FFFF8802.W
	move.l	#$0C0C0000,$FFFF8800.W
	move.l	#$0D0D0A0A,$FFFF8800.W
	IFEQ	DIGIT
	IFNE	SYSTEM
	MOVE.B	#$A,$FFFF8800.W
	ENDC
	move	D0,sr
	ENDC
	addq	#2,d6
	bra.S	L3B6
E7:
	moveq	#0,d0
	move.b	(A1),D0

	MOVE.L	L934(PC),A1
	CMP	$24(A1),D0
	BLS.S	.NOBUG4
	move	#$007,$ffff8240.w
	ILLEGAL
.NOBUG4

	ADD	D0,D0
	ADD	4+2(A1),D0
	ADD	(A1,D0.W),A1

	MOVE.L	A1,off12(A0)
	clr	d6
	BRA	L3B6
EA:	move.b	#$20,off9(a0)
	move.b	(a1)+,off1f(a0)
	addq	#2,d6
	bra	L3B6
E8:	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0

E4:	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA	L3B6		;4AE
E5:	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
E6:	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA	L3B6		;4AE

E3:	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
	bra	L3B6		;nouveau

	IFEQ	DIGIT
EB:
	CLR.B	flagdigit-PSGREG(a6)

	IFEQ	TIMER-0
	clr.b	$FFFFFA19.w
	ENDC
	IFEQ	TIMER-1
	AND.B	#$87,$FFFFFA1D.W
	ENDC
	ADDQ	#1,D6
	BRA	L3B6
EC:
	ST	flagdigit-PSGREG(a6)
	moveq	#0,d0
	move.b	(a1)+,d0

	IFEQ	TRK
	add.B	d0,d0

	BCC.S	1$

	LEA	PTRSDIG(PC),A2
	ADD	D0,A2

	TST.B	SORTIE-PSGREG(A6)
	BNE.S	.STE2
	MOVE	(A2),D0
	LEA	DIGITS(PC),A2
	ADD	D0,A2
	BRA.S	2$
1$
	ELSEIF
	add	d0,d0
	ENDC

	MOVE.L	L934(PC),A2
	ADD	28+2(A2),D0
	ADD	(A2,D0.W),A2
2$
	IFEQ	PCRELATIF
	LEA	L51(PC),A3
	SUB.L	A3,A2
	MOVE	A2,(A3)
	ELSEIF
	MOVE.L	A2,L51-PSGREG(A6)
	ENDC
;
; MADMAX INITIALISE L'EVENT APRES LE STATUS !!!!
;
	IFEQ	TIMER-0
	clr.b	$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	AND.B	#$87,$FFFFFA19.W
	ENDC

	IFEQ	VALUE
	MOVE.B	(A1)+,EVENT.W
	ELSEIF
	ADDQ	#1,A1
	MOVE.B	#VALUE,EVENT.W
	ENDC

	IFEQ	TIMER-0
	move.b	#1,$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	OR.B	#$10,$FFFFFA1D.W
	ENDC
;
; L'EVENT EST ICI CHEZ MADMAX
;
	IFEQ	TRK
	BRA.S	.SKIPSTE
.STE2
;
; JOUE DIGIT STE
;
; D0=ADRESSE DEBUT DIGIT
; D1=ADRESSE FIN DIGIT
;
	LEA	DIGITS(PC),A1
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	(A2)+,D0
	MOVE	(A2),D1
	ADD.L	A1,D0
	ADD.L	A1,D1

	LEA	$FFFF8900.w,A2
	CLR	(A2)
	AND.B	#-2,D0
	AND.B	#-2,D1
	MOVEP	D0,5(A2)
	SWAP	D0
	MOVE	D0,2(A2)
	MOVEP	D1,17(A2)
	SWAP	D1
	MOVE	D1,14(A2)
	MOVE	#$80,32(A2)
	MOVE	#1,(A2)

.SKIPSTE
	ENDC

	addq	#3,d6

	move	d6,off30(a0)

;	moveq	#0,d1
;	MOVEQ	#0,D0
	rts
	ENDC

;L4AE:	move.b	(a1)+,d0
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
; clr d6 … pr‚sent
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
	add.b	D5,D5
;	LEA	L94E(PC),A1
;	MOVE	(A1,d5.w),D0
	MOVE	L94E-PSGREG(A6,D5.W),D0

	move.b	off2a(A0),D1	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D2
	ADDQ	#3,D2

	subq.b	#1,D1
	BNE.S	L578
	subq	#3,d2
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578		;BMI impossible !!!
	add.b	off8(a0),d7
L578:

	BSET	D2,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	IFEQ	MMME
	tst.b	mmme-PSGREG(a6)
	bne	newrep
	ENDC

	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d2
	MOVE.B	off1c(A0),D2

;	bclr	#7,d2		;nouveau replay
;	beq.s	.ok		;BUG ????
;	add.b	d2,d2
;.ok

	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	off2e(a0)
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	off2e(a0)	;ou bchg
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	d2,d2
	CMP.B	d2,D1
	BCS.S	L5DA
	and.b	#$7f,off2e(a0)	;ou bchg
	MOVE.B	d2,D1
L5DA:	lsr.b	#1,d2
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	d2,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d2

	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
;;	EOR.B	#1,d6		;inutilis‚ !!!
;	MOVE.B	d6,off2e(A0)
L5FA:
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	asr.l	#4,d1		;lsr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:
	MOVE.B	off2d(A0),D1

	IFEQ	TURRICAN
	SUB.B	off28(A0),D1
	BPL.S	.NOVOL
	CLR	D1
.NOVOL:
	RTS
	ELSEIF
	MOVEQ	#-16,D2		;DEBUGGAGE VOLUME
	AND.B	D1,D2
	SUB.B	D2,D1
	SUB.B	off28(A0),D1
	BMI.S	.NOVOL
	OR.B	D2,D1
	RTS
.NOVOL:
	MOVE	D2,D1
	RTS
	ENDC

	IFEQ	MMME
newrep:
	tst.b	off1e(a0)
	beq.s	1$
	subq.b	#1,off1e(a0)
	bra.s	.quit
1$
	clr	d1
	clr	d2
	clr	d3
	move.b	off1d(a0),d1
	move.b	off1c(a0),d2
	move.b	off1b(a0),d3
;
; d3 peut-il etre lib‚r‚ comme au-dessus avec une gestion en bytes ???
;
	tst.b	off2e(a0)
	bpl.s	.monte		;OU BMI ???
	sub	d3,d1
	bpl.s	.next
	clr	d1
	bchg	#7,off2e(a0)
	bra.s	.next
.monte
	add	d2,d2
	add	d3,d1
	cmp	d2,d1
	blo.s	.next1
	move	d2,d1
	bchg	#7,off2e(a0)
.next1
	lsr	#1,d2
.next
	move.b	d1,off1d(a0)
	sub	d2,d1
	muls	d0,d1
	asl.l	#6,d1
	swap	d1
	add	d1,d0
.quit
	btst	#5,off9(a0)
	beq.s	.novol
	clr	d1
	move.b	off1f(a0),d1
	ext	d1
	ext.l	d1
	add.l	off38(a0),d1
	move.l	d1,off38(a0)
;
; manque SWAP ici ????
;  ou sinon on peut g‚rer ca en word !!!!
;
	muls	d0,d1
	asl.l	#6,d1
	swap	d1
	sub	d1,d0
.novol
	bra	L628
	ENDC

	IFEQ	CUTMUS
LCA:

	IFEQ	DIGIT
	MOVE.L	L934(PC),A0
	CMP.L	#'DIGI',(A0)
	bne.s	.nodigit
	IFEQ	TIMER-0
	clr.b	$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	AND.B	#$87,$FFFFFA1D.W
	ENDC

	IFEQ	SYSTEM
	move	sr,D1
	move	#$2700,sr

	lea	pushreg(pc),a1

	IFEQ	TIMER-0
	move.l	(a1)+,basemfp+$34.w
	move.b	(a1)+,$fffffa17.w
	move.b	(a1)+,$fffffa07.w
	move.b	(a1)+,$fffffa13.w
	ENDC

	IFEQ	TIMER-1
	move.l	(a1)+,basemfp+$14.w
	move.b	(a1)+,$fffffa17.w
	move.b	(a1)+,$fffffa09.w
	move.b	(a1)+,$fffffa15.w
	ENDC

	move.b	(a1)+,d0

;	clr.b	$fffffa19.w
	move.b	(a1)+,EVENT.W

	IFEQ	TIMER-0
	move.b	d0,$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	MOVE.B	D0,$FFFFFA1D.W
	ENDC

	IFEQ	TIMER-0
	BCLR	#5,$FFFFFA0f.W
	BCLR	#5,$FFFFFA0b.W
	ENDC
	IFEQ	TIMER-1
	BCLR	#5,$FFFFFA11.W
	BCLR	#5,$FFFFFA0D.W
	ENDC

	move	D1,sr
	ENDC
.nodigit:
	ENDC

ZEROSND:
	clr.B	$22(A6)
	clr.B	$26(A6)
	clr.B	$2A(A6)
	MOVEM.L	$1C(A6),D0-D3
	MOVEM.L	D0-D3,$FFFF8800.W
	RTS
	ENDC

INITMUSIC:
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
	LEA	PSGREG(PC),A6

	IFEQ	FADE
	CLR.L	FADEMUS-PSGREG(A6)
	ENDC

	IFEQ	CUTMUS
	ST	BLOQUEMUS-PSGREG(A6)
	ENDC

	subq	#1,d0
	IFEQ	CUTMUS
	BLT.S	LCA		;musique=0 -> cut mus
	ENDC

	IFEQ	DIGIT

	TST.B	flagdigit-PSGREG(A6)
	BEQ.S	.NODIG
	CLR.B	flagdigit-PSGREG(A6)
	IFEQ	TIMER-0
	clr.b	$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	AND.B	#$87,$FFFFFA1D.W
	ENDC
.NODIG

	CMP.L	#'DIGI',(A0)
	BNE.S	PASDIGIT

	IFNE	TRK

	CMP.L	#'XTRN',32(A0)
	BEQ.S	NOTRANS
	CMP.L	#'JOCH',32(A0)
	BEQ.S	NOTRANS
	MOVE.L	#'JOCH',32(A0)
;
; init digit replay
;
	MOVE	62(A0),D1
		IFEQ	PRG
	BLE	BUG
		ENDC

	MOVE.L	A0,A1
	ADD.L	28(A0),A1
	CLR	D2
	LEA	L4E(PC),A3
.L4B:	MOVE.L	A0,A2
	ADD	(A1)+,A2
1$
	MOVE.B	(A2),D2
	CMP.B	#-1,D2
	BEQ.S	2$
		IFEQ	DIGIMAD-1
	EOR.B	#$80,D2
	LSR.B	#4,D2
		ENDC
		IFEQ	DIGIMAD-2
	EOR.B	#$80,D2
		ENDC
		IFEQ	DIGIMAD-3
	LSR.B	#4,D2
		ENDC
	MOVE.B	(A3,D2.W),(A2)+
	BRA.S	1$
2$	MOVE.B	#$88,(A2)+
	SUBQ	#1,D1
	BNE.S	.L4B

NOTRANS:
	ENDC

	MOVE	SR,D1
	MOVE	#$2700,SR

	LEA	L51(PC),A1
	MOVE.L	A1,MODIF1+2-PSGREG(A6)
	LEA	flagdigit(PC),A1
	MOVE.L	A1,MODIF2+2-PSGREG(A6)

	IFEQ	SYSTEM+CUTMUS
	lea	pushreg(pc),a1

	IFEQ	TIMER-0
	move.l	basemfp+$34.w,(a1)+
	move.b	$fffffa17.w,(a1)+
	move.b	$fffffa07.w,(a1)+
	move.b	$fffffa13.w,(a1)+
	move.b	$fffffa19.w,(a1)+
	clr.b	$fffffa19.w
	ENDC

	IFEQ	TIMER-1
	move.l	basemfp+$14.w,(a1)+
	move.b	$fffffa17.w,(a1)+
	move.b	$fffffa09.w,(a1)+
	move.b	$fffffa15.w,(a1)+
	move.b	$fffffa1D.w,(a1)+
	AND.b	#$87,$fffffa1D.w
	ENDC

	move.b	EVENT.W,(a1)+
	ENDC

	ifeq	(basemfp-$100)+AEI
	MOVE.B	#$40,$FFFFFA17.W	;AEI
	endc

	IFEQ	TIMER-0
	OR.B	#1<<5,$FFFFFA07.W
	OR.B	#1<<5,$FFFFFA13.W
	MOVE.B	#$FF-1<<5,$FFFFFA0F.W
	MOVE.B	#$FF-1<<5,$FFFFFA0B.W
	CLR.B	$FFFFFA19.W
	ENDC

	IFEQ	TIMER-1
	OR.B	#1<<5,$FFFFFA09.W
	OR.B	#1<<5,$FFFFFA15.W
	MOVE.B	#$FF-1<<5,$FFFFFA11.W
	MOVE.B	#$FF-1<<5,$FFFFFA0D.W
	AND.B	#$87,$FFFFFA1D.W
	ENDC

	LEA	REPLAY(PC),A1

	IFEQ	TIMER-0
	MOVE.L	A1,basemfp+$34.W
	ENDC
	IFEQ	TIMER-1
	MOVE.L	A1,basemfp+$14.W
	ENDC
;	MOVE.L	#$707FFFF,$FFFF8800.W
	MOVE.B	#$A,$FFFF8800.W
	MOVE	D1,SR

PASDIGIT
	ENDC

	IFEQ	MMME
	cmp.l	#'MMME',32(a0)
	seq	mmme-PSGREG(a6)
	ENDC

	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	$10(A0),A3
	ADD.L	A0,A3
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
;	ADD	D0,D0
;	ADD	D0,A1
;	ADD	D0,D0
	MULU	#6,D0
	ADD	D0,A1
	MOVEQ	#$C,D0
	MULU	(A1)+,D0	;PREMIER PATTERN
	MOVEQ	#$C,D2
	MULU	(A1)+,D2	;DERNIER PATTERN
	SUB	D0,D2

	ADD.L	D0,A3

	MOVE.B	1(A1),L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A2
;
; REGISTRES UTILISES :
;
; D0=COMPTEUR VOIX 0-2
; D1=SCRATCH
; D2=PATTERN FIN
; A0={L934}
; A1=SCRATCH
; A2=VOICEX
; A3=PATTERN DEPART
; A6=BASE VARIABLES
;
L658:
	LEA	L7C6(PC),A1
	MOVE.L	A1,offa(A2)
	MOVE.L	A1,off12(A2)
	MOVEQ	#1,D1
	MOVE.B	D1,off17(A2)	;1
	MOVE.B	D1,off18(A2)	;1

	MOVE.B	d0,off21(A2)
	move.l	A3,off0(A2)
	move	D2,off34(A2)
	MOVE.B	#2,off2a(A2)

	moveq	#0,D1
	IFEQ	OLD
	MOVE	D1,off4(a2)
	ELSEIF
	move	#$c,off4(A2)
	ENDC

	MOVE	D1,offe(A2)
	MOVE.B	D1,off2d(A2)
	MOVE.B	D1,off8(A2)
	MOVE.B	D1,off9(A2)
	MOVE	D1,off30(A2)
	MOVE.B	D1,off19(A2)
	MOVE.B	D1,off1a(A2)
	MOVE.B	D1,off1b(A2)
	MOVE.B	D1,off1c(A2)
	MOVE.B	D1,off1d(A2)
	MOVE.B	D1,off1e(A2)
	MOVE.B	D1,off1f(A2)
	MOVE.L	D1,off38(A2)
	MOVE.B	D1,off26(A2)
	MOVE.B	D1,off27(A2)
	MOVE.B	D1,off2b(A2)

	move.b	(A3)+,D1
	ADD	D1,D1

	MOVE.L	A0,A1
	ADD	$C+2(A1),D1
	ADD	(A1,D1.W),A1

	MOVE.L	A1,off22(A2)
	move.b	(A3)+,off2c(A2)
	move.b	(A3)+,off16(A2)
	moveq	#$10,D1
	add.B	(A3)+,D1
	bcs.s	L712
	moveq	#0,D1
L712:
	MOVE.B	D1,off28(A2)
	lea	off3c(A2),A2
	ADDQ	#4,D2
	addq	#1,d0
	cmp	#3,d0
	blo	L658

	MOVE.B	#1,L80E-PSGREG(A6)
	IFEQ	CUTMUS
;	CLR	BLOQUEMUS-PSGREG(A6)
	CLR.B	BLOQUEMUS-PSGREG(A6)
;	CLR.B	L813-PSGREG(A6)
	ENDC

RETOUR1:
	RTS			;ou BRA ZEROSND

	IFEQ	TRK
INITDIGIT:
	LEA	PSGREG(PC),A6
	TAS	TRANSFORM-PSGREG(A6)
	BNE.S	RETOUR1

	LEA	DIGITS(PC),A1
	MOVE.L	A1,A2
	LEA	PTRSDIG(PC),A4

	CLR	D2
	LEA	L4E(PC),A3
	MOVE.B	D0,SORTIE-PSGREG(A6)

	BNE.S	STE

.L4B0C:
	MOVE.L	A2,D1
	SUB.L	A1,D1
	MOVE	D1,(A4)+	;CALCUL PTR DEBUT

1$
	MOVE.B	(A2),D2
	CMP.B	#-1,D2
	BEQ.S	2$
				IFEQ	DIGIMAD-1
	EOR.B	#$80,D2
	LSR.B	#4,D2
				ENDC
				IFEQ	DIGIMAD-2
	EOR.B	#$80,D2
				ENDC
				IFEQ	DIGIMAD-3
	LSR.B	#4,D2
				ENDC
	MOVE.B	(A3,D2.W),(A2)+
	BRA.S	1$
2$	MOVE.B	#$88,(A2)+

	MOVE	A2,D1
	LSR	#1,D1
	BCC.S	3$
	ADDQ	#1,A2
3$
	CMP.L	#'MEME',(A2)
	BNE.S	.L4B0C

	MOVE.L	A2,D1
	SUB.L	A1,D1
	MOVE	D1,(A4)+	;CALCUL PTR FIN
	RTS

STE:
.L4B0C:
	MOVE.L	A2,D1
	SUB.L	A1,D1
	MOVE	D1,(A4)+	;CALCUL PTR DEBUT

1$
	CMP.B	#-1,(A2)+
	BNE.S	1$

	MOVE	A2,D1
	LSR	#1,D1
	BCC.S	3$
	ADDQ	#1,A2
3$
	CMP.L	#'MEME',(A2)
	BNE.S	.L4B0C

	MOVE.L	A2,D1
	SUB.L	A1,D1
	MOVE	D1,(A4)+	;CALCUL PTR FIN
	RTS
	ENDC


	IFEQ	DIGIT
REPLAY:
	IFEQ	PRG
	MOVE	#$007,$FFFF8240.W
	ENDC
	IFEQ	SYSTEM
	MOVE.B	#$A,$FFFF8800.W
	ENDC
L50:
	IFEQ	PCRELATIF
	MOVE.B	L50(PC),$FFFF8802.W
	ELSEIF
	MOVE.B	0.L,$FFFF8802.W
	ENDC
L51	EQU	L50+2
	BMI.S	L52
MODIF1:
	IFEQ	PCRELATIF
	ADDQ	#1,0.L		;L51
	ELSEIF
	ADDQ.L	#1,0.L		;L51
	ENDC
	IFNE	AEI

	IFEQ	TIMER-0
	MOVE.B	#$FF-1<<5,$FFFFFA0F.W
	ENDC
	IFEQ	TIMER-1
	MOVE.B	#$FF-1<<5,$FFFFFA11.W
	ENDC

	ENDC
	IFEQ	PRG
	CLR	$FFFF8240.W
	ENDC
	RTE
L52:
MODIF2:	clr.b	0.L		;flagdigit
	IFEQ	TIMER-0
	clr.b	$fffffa19.w
	ENDC
	IFEQ	TIMER-1
	AND.b	#$87,$fffffa1D.w
	ENDC

	IFNE	AEI
	IFEQ	TIMER-0
	MOVE.B	#$FF-1<<5,$FFFFFA0F.W
	ENDC
	IFEQ	TIMER-1
	MOVE.B	#$FF-1<<5,$FFFFFA11.W
	ENDC

	ENDC
	IFEQ	PRG
	CLR	$FFFF8240.W
	ENDC
	RTE

	IFEQ	DIGIMAD-1
L4E:	DC.B	$00,$07,$09,$0A,$0B,$0C,$0C,$0D
	DC.B	$0D,$0D,$0E,$0E,$0E,$0F,$0F,$0F
	ENDC
	IFEQ	DIGIMAD-2
L4E:	INCBIN	CONVERT.BIN
	ENDC
	IFEQ	DIGIMAD-3
L4E:	DC.B	$0D,$0D,$0E,$0E,$0E,$0F,$0F,$0F
	DC.B	$00,$07,$09,$0A,$0B,$0C,$0C,$0D
	ENDC
	ENDC

L7C6:	DC.B	1,0,0,0,0,0,0,$E1

PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808
	IFEQ	EQUALISEUR
	LIST

	NOLIST
	ENDC
	DC.W	0,$909,0
	DC.W	$A0A,0

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
L80E:	DC.B	4
L810:	DC.B	4
	IFEQ	CUTMUS
BLOQUEMUS:DC.B	-1
	ENDC

	IFEQ	SYSTEM+DIGIT+CUTMUS
	even
pushreg:ds.b	9
	ENDC

	IFEQ	MMME
mmme:	dc.b	0
	ENDC
	IFEQ	DIGIT
flagdigit:dc.b	0
	ENDC
	IFEQ	EQUALISEUR
	LIST
BOUCLE:	DC.B	0
	NOLIST
	ENDC

	EVEN
voice0:	ds.B	off3c
voice1:	ds.B	off3c
voice2:	ds.B	off3c
L934:	DC.L	0
	IFEQ	FADE
FADEMUS:DC.L	0
L0047:
	DC.B	$00,$01,$02,$03,$04,$05,$06,$07
	DC.B	$08,$09,$0A,$0B,$0F,$0F,$0F,$0F
	DC.B	$0F,$0F
	ENDC

	IFEQ	MONOCHROM
DIVISEUR_VBL:DC.W	0
	ENDC

	IFEQ	TRK
PTRSDIG:DS.W	64		;0.W=PTR DEBUT
TRANSFORM:DC.B	0
SORTIE:	DC.B	0
	EVEN
DIGITS:	INCBIN	TRK\ALLDIG2.BIN
	DC.L	'MEME'
	ENDC

	IFEQ	PRG
MUSIC:
;	INCBIN	NEW\ens1.MUS
;	INCBIN	COSO\PREHIS6.MUS
;	INCBIN	MAD30.MUS
;	INCBIN	TEST\WINGS0.OPT
	INCBIN	TRK\wings3.TRK
	ds.b	6
	ELSEIF
	LIST
	ENDC
