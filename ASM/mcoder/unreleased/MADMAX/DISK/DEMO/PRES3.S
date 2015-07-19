	opt	o+,ow2-,X+
	opt	ow-
;
; enlever calcul CRC quand final
;
;	org	$80000-64000-143000
	org	$50000
return=$4000+4		;adresse retour programme appelant
ecran0=$80000-216*160
;
; org en $80000-64000
; d‚packe les musiques puis jumpe dans le programme
; avec d0=type de la musique
;	0=ST
;	1=STE
;
; entr‚e :
;	a6=adresse destination fichier d‚pack‚
; sortie :
;	d0=type ST
;
; NUM REGISTRE	NB VALEURS PRISES
;	0	8
;	1	5
;	6	3
;	7	3
;	8	13
;
; MUSIQUE DE LEAVING TERAMIS
;
; 592 OCTETS
; 494 OCTETS SANS PRG
;
	rsreset
str0	rs.w	1	;0=stable,2=descend,-2=monte
str2	rs.w	1	;ptr sur table sinus
str4	rs.w	1	;offset X+offset couleur
str6	rs.w	1	;coordy voulue
str8	rs.w	1	;ancien offset ‚cran effacement
str10	rs.b	1	;lettre … afficher
str11	rs.b	1	;direction
length	equ	(__RS+1)&-2

	jmp	maincode

source:	incbin	pak.mpk
	even
maincode:
;	lea	ecran0,sp		;pile
	move.l	a6,ptrdebut

	BSR	INITMUSIC
	bsr	initmess

	move.l	#initvbl,$70.w
	move	#$2300,sr
	stop	#$2300

	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	#ecran0+8*160,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.l	#vbl,$70.w

	bsr	main

	tst.b	flagfin
	bne.s	WW
	tst	flagste
	bne.s	WW

	bsr	initfin
WW:
;	ADDQ	#7,$FFFF8240.W
;	bra.S	WW

.end
	move	nbvbl,d0
	bne.s	.end
.fini
	move	#$2700,sr

	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W

	moveq	#0,d0
	moveq	#8-1,d1
	lea	$ffff8240.w,a0
.pal0	move.l	d0,(a0)+
	dbra	d1,.pal0

	move	flagste,d0
	rts

initfin:
	st	flagfin
	lea	moving,a0
	move	cptlet,d0
	subq	#1,d0
;	bmi.s	.fini
.endup
	move	#2,(a0)
	lea	length(a0),a0
	dbra	d0,.endup
	rts
vbl:
	movem.l	d0-d7/a0-a6,-(sp)

;	MOVE	#$700,$FFFF8240.W
	BSR	PLAYMUSIC

	bsr	anim

;	CLR	$FFFF8240.W

	tst.b	flagfin
	beq.s	.notfin

	tst	nbvbl
	beq.s	.fin
	subq	#1,nbvbl
	bra.s	.fin
.notfin
	tst	flagste
	beq.s	.fin

	moveq	#$3c,d0
	sub.b	$fffffc02.w,d0		;F1/F2
	cmp	#1,d0
	bhi.s	.fin

	move	d0,flagste
	bsr	initfin
.fin
	movem.l	(sp)+,d0-d7/a0-a6
initvbl:
	rte
initmess:
	lea	sinewave,a0
	moveq	#0,d0
	moveq	#0,d1
	move	#(fin_sinewave-sinewave)/2-1,d2
.store
	move	d0,(a0)+
	addq	#1,d1
	add	d1,d0
	dbra	d2,.store

	moveq	#0,d0
	lea	mess1,a5
	move.b	#$aa,$ffff820d.w
	cmp.b	#$aa,$ffff820d.w
	bne.s	.notste

	move.b	#0,$ffff820d.w
	tst.b	$ffff820d.w
	bne.s	.notste
	moveq	#1,d0
	lea	mess2,a5
.notste
	move	d0,flagste
	lea	moving,a6
	moveq	#0,d7		;nb lettres … g‚rer
	moveq	#0,d6		;coordX
	moveq	#100,d5		;coordY
	moveq	#-1,d3
	moveq	#0,d2

	moveq	#100,d4
.loop
	clr	d0
	move.b	(a5)+,d0
	beq.s	.fini

	bpl.s	.notchar

	addq.b	#1,d0
	bne.s	.plane
; -1,coordX,coordY
	move.b	(a5)+,d6
	move.b	(a5)+,d5
	move.b	(a5)+,d3
	bra.s	.loop
.plane
; -2,plan
	move.b	(a5)+,d2
	ext	d2
	bra.s	.loop
.notchar:
	lea	convert-$20(pc),a0
	move.b	(a0,d0.w),d0

	move.b	d0,str10(a6)
	move.b	d3,str11(a6)

	move	#-2,str0(a6)	;descend
	move	d4,str2(a6)	;ptr sinus

	move	d6,d0
	and	#-2,d0
;	lsr	#1,d0
	asl	#2,d0
	btst	#0,d6
	beq.s	.pair
	addq	#1,d0
.pair
	add	d2,d0
	move	d0,str4(a6)	;offset X+couleur
	move	d5,str6(a6)	;Y voulu
	move	#-1,str8(a6)	;ancien offset pour effa‡age

	add	#6,d4
	addq	#1,d6
	addq	#1,d7
	lea	length(a6),a6
	bra.s	.loop
.fini
	move	d7,cptlet
	rts

anim:
	lea	moving,a6
	move	cptlet,d7
	subq	#1,d7
	bmi	.fini

.loop
	move	str0(a6),d0	;immobile ????
	beq	.next

	add	str2(a6),d0
	cmp	#fin_sinewave-sinewave,d0
	blo.s	.ok
	clr	str0(a6)
	bra	.next
.ok
	move	d0,str2(a6)

	lea	sinewave,a0
	move	(a0,d0.w),d0	;depY

	tst.b	str11(a6)
	bpl.s	.descend
	neg	d0		;-depY
.descend
	add	str6(a6),d0	;+Y voulu
;
; effa‡age de l'ancienne lettre
;
	lea	ecran0,a0
	moveq	#0,d1
	move	str8(a6),d1
	cmp	#-1,d1
	beq.s	.noeff

	add.l	d1,a0
	moveq	#0,d1
x	set	0
	rept	8
	move.b	d1,x(a0)
x	set	x+160
	endr
.noeff:
	addq	#8,d0
	cmp	#208,d0
	bhs.s	.next

	mulu	#160,d0
	add	str4(a6),d0

	move	d0,str8(a6)
	lea	ecran0,a0
	add.l	d0,a0

	lea	fonte,a1
	moveq	#0,d0
	move.b	str10(a6),d0
	asl	#3,d0
	add	d0,a1
x	set	0
	rept	8
	move.b	(a1)+,x(a0)
x	set	x+160
	endr
.next
	lea	length(a6),a6
	dbra	d7,.loop
.fini
	rts

INITMUSIC:
	MOVEM.L	PSGREG+$1C(PC),D0-D6
	MOVEM.L	D0-D6,$FFFF8800.W

;	LEA	$FFFF8800.W,A0
;	MOVE.L	#$0B0B7878,(A0)	;CTE
;	MOVE.L	#$0C0C0000,(A0)	;CTE
;	MOVE.L	#$0D0D0A0A,(A0)	;CTE
	RTS
;
; calcule nouvelle note
;
PLAYMUSIC:
	LEA	PSGREG(PC),A6

	MOVEQ	#0,D0

	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	RETNEXT
	MOVE.B	#3,L80E-PSGREG(A6)

	SUBQ.B	#1,off26-PSGREG(a6)
	BPL.S	RETNEXT
	MOVE.L	off22-PSGREG(a6),A0
;	clr	d0
L26C:
	MOVE.B	(A0)+,D0
	BMI.s	L308
	MOVE.B	d0,off27-PSGREG(a6)
	subq.b	#2,d0
	BNE.S	L26C
	lea	LF9(pc),A0
	bra.s	L26C
L308:
	MOVE.B	off27-PSGREG(a6),off26-PSGREG(a6)	;off27=0 ou 1

	ADD.B	D0,D0
	MOVE.L	A0,off22-PSGREG(a6)
	MOVE.L	A6,A0
	MOVE.L	A6,A1
	ADD	L64-PSGREG(A6,d0.W),A0
	ADD	L64-PSGREG+2(A6,D0.W),A1

	MOVE.L	A0,offa-PSGREG(a6)
	MOVE.L	A1,off12-PSGREG(a6)
RETNEXT:
;
; calcul de la note … jouer
;

	MOVE.L	off12-PSGREG(a6),A0
	move.b	(A0),d0

	beq.s	L49A
	bmi.s	L498

code2=0		;$ff
code4=3+2	;$e6 et $e9
code6=2		;$e5
code8=1		;$e4

	subq.b	#1,d0
	move.b	d0,off2a-PSGREG(a6)

	addq	#1,A0
L498:	addq	#1,A0
	move.l	A0,off12-PSGREG(a6)
L49A:

	moveq.l	#$F0,D7		;D7 CHANGE 3 FOIS DE VALEUR

	MOVE.b	-(A0),D0
	add.b	D0,D0
	move	L94EF-14(PC,d0.w),D0
	move	d0,PSG1+2-PSGREG(A6)
	move.b	D0,PSG0+2-PSGREG(A6)

	move.b	off2a-PSGREG(a6),D0	;0,1 ou 2
	beq.S	.L57E

	moveq	#$14^$1f,d6	;D6 CHANGE 3 FOIS DE VALEUR
	subq.b	#1,D0
	BNE.S	.L578

	move.b	(A0),d6		;d6=($02^$1f) ou ($04^$1f)

.L578:	BSET	d0,D7
	MOVE.B	D6,PSG6+2-PSGREG(A6)
.L57E:
	MOVE.B	D7,PSG7+2-PSGREG(A6)
;
; modulation volume
;
	MOVE.L	offa-PSGREG(a6),A0
	move.b	(A0)+,PSG8+2-PSGREG(A6)
	bmi.S	1$
	move.l	A0,offa-PSGREG(a6)
1$
	MOVEM.L	(A6),D0-D7/A0-A2
	MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
	RTS
;
; LISTE DE TOUTES LES FREQUENCES UTILISEES !!!!
;
L94EF:	DC.W	$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D

PSGREG:

PSG0:	DC.W	0,0
PSG1:	DC.W	$101,0
	DC.L	$02027777	;CTE
	DC.L	$03030707	;CTE
	DC.L	$0404BBBB	;CTE
	DC.L	$05050303	;CTE
PSG6:	DC.W	$606,0
PSG7:	DC.W	$707,$FFFF
PSG8:	DC.W	$808,0
	DC.L	$09091010	;CTE
	DC.L	$0A0A1010	;CTE
	DC.L	$0B0B7878	;CTE
	DC.l	$0C0C0000	;CTE
	DC.l	$0D0D0A0A	;CTE

L64:	DC.W	L74-PSGREG,L46-PSGREG
	DC.W	L80-PSGREG,L46-PSGREG
	DC.W	L95-PSGREG,L46-PSGREG
	DC.W	LA3-PSGREG,L4F-PSGREG
	DC.W	LB2-PSGREG,L4F-PSGREG
	DC.W	LC6-PSGREG,L4F-PSGREG
	DC.W	LD7-PSGREG,L46-PSGREG

off12	dc.l	0	;(3)ptr base modulation fr‚quence
offa	dc.l	0	;(3)ptr base modulation volume
off22	dc.l	LF9	;(2)ptr courant dans pattern
off27	dc.b	1	;(2)utile
off26	dc.b	0	;(2)utile
off2a	dc.b	0	;(2)0,1 ou 2=type de son
L80E:	DC.B	1

L74:	DC.B	$D,$F,$F,$F,$D,0+$80
L80:	DC.B	$A,$D,$D,$A,9,8,7,6,5,4,3,2,2,1,0+$80
L95:	DC.B	4,$A,$A,4,3,2,1,0+$80
LA3:	DC.B	$D,$F,$F,$F,$D,$A,9,8,0+$80
LB2:	DC.B	$A,$D,$D,$A,9,8,7,6,5,4,3,2,1,0+$80
LC6:	DC.B	$A,$B,$B,7,6,5,4,3,2,1,0+$80
LD7:	DC.B	$A,$A,$A,5,4,3,2,1,0+$80

L46:
	DC.B	code6			;$E5
	DC.B	$02^$1f
	DC.B	code4			;$E6
	DC.B	$97,$93,$8F,$87
	DC.B	code2			;$ff
L4F:
	DC.B	code6			;$E5
	DC.B	$04^$1f
	DC.B	code4			;$E6
	DC.B	$9D,$9F
	DC.B	code8			;$E4
	DC.B	$97,$95,$93,$92,$91,$90
	DC.B	code2			;$ff
LF9:
	DC.B	$00+1
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	2*2+$80
	DC.B	1*2+$80
	DC.B	3*2+$80
	DC.B	4*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	3*2+$80
	DC.B	5*2+$80
	DC.B	4*2+$80
	DC.B	6*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	2*2+$80
	DC.B	1*2+$80
	DC.B	3*2+$80
	DC.B	4*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	3*2+$80
	DC.B	5*2+$80
	DC.B	4*2+$80
	DC.B	6*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	2*2+$80
	DC.B	1*2+$80
	DC.B	3*2+$80
	DC.B	4*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	3*2+$80
	DC.B	5*2+$80
	DC.B	4*2+$80
	DC.B	6*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	2*2+$80
	DC.B	1*2+$80
	DC.B	3*2+$80
	DC.B	4*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	0*2+$80
	DC.B	1*2+$80
	DC.B	0*2+$80
	DC.B	3*2+$80
	DC.B	3*2+$80
	DC.B	$00+0
	DC.B	4*2+$80
	DC.B	5*2+$80
	DC.B	$00+1
	DC.B	3*2+$80
	DC.B	$00+2
	even
fonte:	incbin	fonte1.bin
	dcb.b	8,0

nbvbl:	dc.w	60
palette:
	dc.w	0
	dc.w	$555
	dc.w	$700
	dc.w	-1
	dc.w	$070
	dcb.w	12,-1

;	DC.B	'0123456789'
;	DC.B	'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
;	DC.B	"?!:;,'()-+ "
convert:
	dc.b	$2e			;' '
	dc.b	37			;!
	dc.b	0,0,0,0,0
	dc.b	41
	dc.b	0,0,0,0
	dc.b	40			;,
	dc.b	44
	dc.b	0,0
	dc.b	0,1,2,3,4,5,6,7,8,9
	dc.b	0,0,0,0,0,0,0
	dc.b	10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26
	dc.b	27,28,29,30,31,32,33,34,35
mess2:
	dc.b	-1,0+1,90,-2
	dc.b	"WOW, STE OWNER, IF YOU WANT TO LISTEN"
	dc.b	-1,0+3,100,2
	DC.B	"TO "
	DC.B	-2,2
	DC.B	"REAL"
	DC.B	-2,0
	DC.B	" DIGI-SOUNDS THEN PRESS "
	DC.B	-2,2
	DC.B	"F1"
	DC.B	-2,0
	dc.b	-1,0+13,108,2
	DC.B	"ELSE PRESS "
	DC.B	-2,2
	DC.B	"F2"
	DC.B	-2,0,0

mess1:
	dc.b	-1,0+6,90,-2
	dc.b	"PLEASE WAIT, I'M DECRUNCHING"
	dc.b	-1,3+6,110,2
	dc.b	"THE "
	dc.b	-2,2
	dc.b	"MEGA-MAD-MIX DEMO",0
	EVEN

MPK=0			;0=ADRESSE SOURCE PAIRE
CPU=1
CHKSUM=0
;
;	PAK.LZH	: 365 Vbls avec CPU=0
;		: 344 Vbls avec CPU=1
;
; optimisations … effectuer :
;
;	- copier read_c_len (appel‚ une seule fois)
;	- copier read_pt_len (2 appels->optimisations)
;	- enlever derniers accŠs pile
;
bitbuf:	equr	d7
nbbits:	equr	d6
inpptr:	equr	a5
;
; shift bitbuf n bits left, read n bits
;
; rafraichit bitbuf avec d0 bits
;
; scratche d0
;
RELOAD:	MACRO
	addq	#2,inpptr
	IFEQ	MPK
	move.l	(inpptr),bitbuf
	ELSEIF
	movep	(inpptr),bitbuf
	move.b	1(inpptr),bitbuf
	swap	bitbuf
	movep	2(inpptr),bitbuf
	move.b	3(inpptr),bitbuf
	ENDC
	ror.l	nbbits,bitbuf
	ENDM

fillbuf:MACRO	\1

	sub.B	\1,nbbits
	bhs.s	.\@

	add.B	#16,nbbits

	RELOAD
	BRA.S	.A\@
.\@	rol.l	\1,bitbuf
.A\@
	ENDM
;
; liste des registres :
;
;	d7 inutilis‚
;	d6 inutilis‚
;	d5 utilis‚ 1 fois dans init
;	d4 utilis‚ dans init
;
;	d0/d1/d2/d3 utilis‚s partout
;
;	a6 utilis‚ dans main seulement
;	a5 inutilis‚
;	a4 utilis‚ dans init
;	a3 utilis‚ dans init
;	a2 utilis‚ 1 fois dans init
;	a1 utilis‚ dans init
;	a0 utilis‚ partout
;

CRC16	=	$A001

NC	=	$200-2
NP	=	14
NT	=	19
NPT	=	$80	;=max(NP,NT)

CBIT	=	9
PBIT	=	4
TBIT	=	5

main:
	lea	source,inpptr
	move.l	ptrdebut(pc),a6
;
; get Header
;
	move.l	(inpptr)+,d0
	add.l	a6,d0
	move.l	d0,ptrfin
;
; get original CRC
;
	move	(inpptr)+,orgcrc
;
; decode
;
	bsr	decode

	IFEQ	CHKSUM
;
; make CRC table
;
makecrc:
	lea	crctbl(pc),a0
	lea	$100(a0),a1
	moveq	#0,d2
1$
	move	d2,d0
	moveq	#8-1,d1
2$
	lsr	#1,d0
	bcc.s	3$
	eor	#CRC16,d0
3$
	dbra	d1,2$
	move.b	d0,(a1)+
	lsr	#8,d0
	move.b	d0,(a0)+

	addq.b	#1,d2
	bne.s	1$
;
; check CRC
;
calccrc:
	move.l	ptrdebut(pc),a0
	move.l	ptrfin(pc),a1
	moveq	#0,d1
	moveq	#0,d2
	lea	crctbl(pc),a2
	LEA	$100(A2),A3

	clr	d0
.do
	move.b	(a0)+,d0
	eor.b	d1,d0

	move.b	(a3,d0.w),d1
	eor.b	d2,d1
	move.b	(a2,d0.w),d2

	cmp.l	a1,a0
	blo.s	.do

	ASL	#8,D2
	ADD	D2,D1

	cmp	orgcrc(pc),d1
	bne.s	errcrc
	ENDC

	rts
bug:
errhdr:
errcrc:
brokenerr:
errout:
errout1:
	illegal
;
; extract routines
;
decode:


	moveq	#16,nbbits

	IFEQ	MPK
	move.l	(inpptr),bitbuf
	ELSEIF
	movep	(inpptr),bitbuf
	move.b	1(inpptr),bitbuf
	swap	bitbuf
	movep	2(inpptr),bitbuf
	move.b	3(inpptr),bitbuf
	ENDC

	swap	bitbuf

;	bra	.entry

.reinit
;
***********************************************
*
*    init
*
***********************************************
;
;	pea	(a6)

	IFEQ	CPU
	move	#$700,$ffff8240.w
	ENDC

	move	bitbuf,blocksize
;
; on peut optimiser le code ici parce qu'on doit sauter 16 bits
;
;	moveq	#16,d0
;	fillbuf	d0
	RELOAD

	moveq	#NT,d4
	moveq	#TBIT,d3
	moveq	#3,d2
	bsr	read_pt_len

	bsr	read_c_len

	moveq	#NP,d4
	moveq	#PBIT,d3
	moveq	#-1,d2
	bsr	read_pt_len

;	move.l	(sp)+,a6

	IFEQ	CPU
	clr	$ffff8240.w
	ENDC

.loop
;
; sous-programme de d‚codage de caractŠre
;
;decode_c_st1
	subq	#1,blocksize
	blo.s	.reinit

	IFEQ	CPU
	move	#$007,$ffff8240.w
	ENDC

;	move	bitbuf,d1
;	lsr	#4,d1
;	add	d1,d1

	moveq	#-16,d1
	and	bitbuf,d1
	lsr	#3,d1

	lea	c_table(pc),a0
	move	(a0,d1.w),d1

	cmp	#NC,d1
	blo.s	.decode_c_st1_1

	move	bitbuf,d0
	asl.b	#4,d0
.tree0:
	lea	left(pc),a0
	add.b	d0,d0
	bcc.s	.loc1
	lea	right(pc),a0
.loc1
	move	(a0,d1.w),d1
	cmp	#NC,d1
	bhs.s	.tree0

.decode_c_st1_1
	lea	c_len(pc),a0
;	clr	d0
	move.b	(a0,d1.w),d0
	fillbuf	d0

	IFEQ	CPU
	clr	$ffff8240.w
	ENDC

	cmp	#$100,d1
	bhs.s	.loc50

	move.b	d1,(a6)+
;.entry
	cmp.l	ptrfin(pc),a6
	blo.s	.loop
	rts
.loc50
;
; sous-programme de d‚codage de pointeur
;
; ne pas scratcher D1
;decode_p_st1
	move	bitbuf,d2
	lsr	#8,D2
	add	d2,d2
	lea	pt_table(pc),a0
	move	(a0,d2.w),d2
	cmp	#NP,d2
	blo.s	.decode_p_st1_1

	move	bitbuf,d0
.tree00:
	lea	left(pc),a0
	add.b	d0,d0
	bcc.s	.loc10
	lea	right(pc),a0
.loc10
	move	(a0,d2.w),d2
	cmp	#NP,d2
	bhs.s	.tree00

.decode_p_st1_1
	lea	pt_len(pc),a0
;	clr	d0
	move.b	(a0,d2.w),d0
	fillbuf	d0

	move	d2,d0
	subq	#1,d0
	bls.s	.loc3

	moveq	#16,d2
	sub	d0,d2
	move	bitbuf,d3
	lsr	d2,d3
	bset	d0,d3

	fillbuf	d0

	move	d3,d0
	subq	#1,d0
.loc3:
	sub	#$100-3+1,d1

	lea	-1-1(a6),a0
	sub	d0,a0
.do1	move.b	(a0)+,(a6)+
	dbra	d1,.do1

	cmp.l	ptrfin(pc),a6
	blo	.loop
	rts
;
; initialise tableaux pour d‚codage pointeurs
;
; entr‚e :
;	d2 -> d1
;	d3
;	d4
;
read_pt_len
	move	bitbuf,d0
	fillbuf	d3
	neg	d3
	add	#16,d3
	lsr	d3,d0

	cmp	d4,d0
	bhi	brokenerr

	lea	pt_len(pc),a4

	tst	d0
	bne.s	.loc1

	subq	#1,d4
.loc2	move.b	d0,(a4)+
	dbra	d4,.loc2

	move	bitbuf,d0
	fillbuf	d3
	neg	d3
	add	#16,d3
	lsr	d3,d0

	move	#256-1,d1
	lea	pt_table(pc),a4
.loc3	move	d0,(a4)+
	dbra	d1,.loc3
	rts
.loc1
	move.l	a4,a1
	add	d2,a1

	move.l	a4,a2
	add	d0,a2
.do1
	move	bitbuf,d1
	rol	#3,d1
	and	#7,d1

	fillbuf	#3

	cmp	#7,d1
	bne.s	.not1

	move	bitbuf,d0
	bpl.s	.endw
.while1
	addq	#1,d1
	add	d0,d0
	bmi.s	.while1
.endw
	move	d1,d0
	subq	#6,d0
	fillbuf	d0
.not1
	move.b	d1,(a4)+
	cmp.l	a1,a4
	bne.s	.not2

	move	bitbuf,d1
	rol	#2,d1
	and	#3,d1

	fillbuf	#2

	subq	#1,d1
	blo	bug
	moveq	#0,d0
.loc11	move.b	d0,(a4)+
	dbra	d1,.loc11

.not2
	cmp.l	a2,a4
	blo	.do1

	lea	pt_len(pc),a3
;
; efface la fin du tableau
;
	move.l	a3,d1
	sub.l	a4,d1
	add	d4,d1
	beq.s	.none1
	moveq	#0,d0
	subq	#1,d1
.loc12	move.b	d0,(a4)+
	dbra	d1,.loc12
.none1:

	move	d4,d0
	moveq	#8,d2
	lea	pt_table(pc),a4
;	lea	pt_len(pc),a3
	bra	make_table
;
; initialise tableaux pour d‚codage caractŠres
;
; entr‚e :
;	rien
;
read_c_len
	move	bitbuf,d1
	lsr	#16-CBIT,d1

	moveq	#CBIT,d0
	fillbuf	d0

	cmp	#NC,d1
	bhi	brokenerr

	lea	c_len(pc),a4

	tst	d1
	bne.s	.not1

	move	#NC-1,d0
.lop1	move.b	d1,(a4)+
	dbra	d0,.lop1

	move	bitbuf,d1
	lsr	#16-CBIT,d1

	moveq	#CBIT,d0
	fillbuf	d0

	move	#4096-1,d0
	lea	c_table(pc),a4
.lop2	move	d1,(a4)+
	dbra	d0,.lop2
	rts
.not1
	move.l	a4,a1
	add	d1,a1
do100
	move	bitbuf,d1
	lsr	#8,D1

	add	d1,d1
	lea	pt_table(pc),a0
	move	(a0,d1.w),d1

	cmp	#NT,d1
	blo.s	read_c_len_1

	move	bitbuf,d0

.tree0:
	lea	left(pc),a0
	add.b	d0,d0
	bcc.s	.loc1
	lea	right(pc),a0
.loc1
	move	(a0,d1.w),d1
	cmp	#NT,d1
	bhs.s	.tree0

read_c_len_1:
	lea	pt_len(pc),a0
;	CLR	D0
	move.b	(a0,d1.w),d0
	fillbuf	d0
	move	d1,d0

	subq	#2,d0
	bhi.s	.loc68

	bne.s	.loc65

	move	bitbuf,d1
	lsr	#16-CBIT,d1
	add	#20-1,d1

	moveq	#CBIT,d0
	fillbuf	d0

	bra.s	.loc67
.loc65
	addq	#1,d0
	bne.s	.loc66

	move	bitbuf,d1
	rol	#4,d1
	and	#$f,d1

	fillbuf	#4

	addq	#3-1,d1
.loc67
	moveq	#0,d0
.lopxx1	move.b	d0,(a4)+
	dbra	d1,.lopxx1
	bra.s	.loc69

.loc66
	moveq	#0,d0
.loc68
	move.b	d0,(a4)+
.loc69
	cmp.l	a1,a4
	blo	do100
;
; efface la fin du tableau
;
	move.l	#c_len+NC,d1
	sub.l	a4,d1
	BEQ.S	.NONE2
	moveq	#0,d0
	subq	#1,d1
.fil0	move.b	d0,(a4)+
	dbra	d1,.fil0
.NONE2
	move	#NC,d0
	moveq	#12,d2
	lea	c_len(pc),a3
	lea	c_table(pc),a4
	bra	make_table
;
; entr‚e :
;	d0
;	d2
;	a3
;	a4
;
make_table
	move	d0,nchar
	add	d0,d0
	move	d0,avail_mt
	move	d2,tablebits
	move.l	a4,table

	moveq	#16,d0
	sub	d2,d0
	move	d0,restbits

	clr	d1
	bset	d2,d1

	moveq	#0,d0
	subq	#1,d1
.stos	move	d0,(a4)+
	dbra	d1,.stos

	moveq	#0,d4
	move	#$8000,d1
	moveq	#1,d3
do200
	move.l	a3,a4
	move	nchar(pc),d2
	subq	#1,d2
.do2
;	move	d3,d0
.scasb
	cmp.b	(a4)+,d3
	dbeq	d2,.scasb
	bne	mt1

	move.l	a4,d0
	sub.l	a3,d0
	subq	#1,d0		;d0=nchar-d2+1

	move	d2,-(sp)
	pea	(a4)
;
; d1=weight
; d4=code
; d3=len
;
	move	restbits(pc),d2
	move	d4,d5
	lsr	d2,d5
	add	d5,d5
	move.l	table(pc),a4
	add	d5,a4

	move	d1,-(sp)

	cmp	tablebits(pc),d3
	bhi.s	.loc1
	lsr	d2,d1
	BEQ	bug
	subq	#1,d1
.stosw1	move	d0,(a4)+
	dbra	d1,.stosw1
	bra.s	.loc2
.loc1
;
; a4=taddr
; d0=char
;
	move	d4,-(sp)
	move	tablebits(pc),d2
	asl	d2,d4

	neg	d2
	add	d3,d2
	BEQ	bug
	subq	#1,d2
.do3
	move	(a4),d1
	bne.s	.loo
	move	avail_mt(pc),d1
	lea	right(pc),a0
	clr	(a0,d1.w)
	lea	left(pc),a0
	clr	(a0,d1.w)

	move	d1,(a4)
	addq	#2,avail_mt
.loo
	lea	left(pc),a4
	ADD	D4,D4
	bcc.s	.noc1
	lea	right(pc),a4
.noc1
	add	d1,a4

	dbra	d2,.do3
	move	d0,(a4)

	move	(sp)+,d4
.loc2
	move	(sp)+,d1
	move.l	(sp)+,a4
	move	(sp)+,d2
	add	d1,d4
	bcs.s	mt2

	dbra	d2,.do2
mt1:
	addq	#1,d3
	lsr	#1,d1
	bcc	do200
mt2:
	rts
;
; liste des variables utilis‚es
;
;	section	data
;
;cright:	dc.b	"LHA 2.11 converted by MCODER",13,10,0
;broken:	dc.b	'Broken file',0
;header:	dc.b	'Header',0
;crcmess:dc.b	'CRC'
;error:	dc.b	' Error',0
;	even

;	section	bss

	section	bss
	list

	nolist
	even
flagste:ds.w	1
cptlet:	ds.w	1
sinewave:ds.w	400
fin_sinewave:

moving:
	ds.b	length*100

flagfin:ds.b	1
	even

left	ds.w	2*NC-1
right	ds.w	2*NC-1
c_table:ds.w	4096
pt_table:ds.w	256
c_len:	ds.b	NC
pt_len:	ds.b	NPT

avail_mt:ds.w	1
nchar:	ds.w	1
tablebits:ds.w	1
table:	ds.l	1
restbits:ds.w	1
	even

; words,longs...

ptrdebut:ds.l	1
ptrfin:	ds.l	1

blocksize:ds.w	1

orgcrc	ds.w	1
crctbl	ds.w	$100
crctbl2	ds.w	$100
	even

methode:ds.b	1
	even

	list

	nolist
