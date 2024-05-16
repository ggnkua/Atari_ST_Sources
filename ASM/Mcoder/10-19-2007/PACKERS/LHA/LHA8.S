	opt	o+
	org	$8000
source=$40000
dest=$50000
;	opt	c-,o+,x+
;	opt	ow2-,ow5-
;
; nouvelle version avec bug corrig‚ (en read_pt_len)
; bug trouv‚ par Mr Bee
;
; autre bug : LOC11
;
MPK=0			;0=ADRESSE SOURCE PAIRE
CPU=0
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

fillbufq:MACRO
	subq.b	\1,nbbits
	bhs.s	.\@
	add.b	#16,nbbits
	RELOAD
	BRA.S	.A\@
.\@	rol.l	\1,bitbuf
.A\@
	ENDM

fillbuf:MACRO
	sub.b	\1,nbbits
	bhs.s	.\@
	add.b	#16,nbbits
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
PRINTE:	MACRO
	PEA	\1
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP
	ENDM

exehdr	=	0

CRC16	=	$A001

NC	=	$200-2
NP	=	14
NT	=	19
NPT	=	$80	;=max(NP,NT)

CBIT	=	9
PBIT	=	4
TBIT	=	5

	section	text
main:
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp

	PRINTE	cright(pc)

	lea	source,inpptr
	lea	dest,a6

	IFEQ	MPK
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

	ELSEIF
;
; get Header
;
	lea	exehdr(inpptr),a0
	moveq	#0,d1

	MOVE.b	(a0)+,d1
	beq	exit

	addq	#1,d1

	move.l	a0,a1
	add	d1,a1
	move.l	a1,inpptr

; test header sum

	subq	#2,d1
	BLO	bug

	move.b	(a0)+,d0
	move.l	a0,a1		;cpyhdr+HeadID
.loop
	sub.b	(a1)+,d0
	dbra	d1,.loop

	tst.b	d0
	bne	errhdr
;
; test header id
;
	cmp.b	#'-',(a0)+
	bne	errhdr
	cmp.b	#'l',(a0)+
	bne	errhdr
	cmp.b	#'h',(a0)+
	bne	errhdr

;	move.b	(a0)+,d0
;	sub.b	#'0',d0
;	move.b	d0,methode

;	beq.s	.loc15
;	subq.b	#4,d0
;	beq.s	.loc15
;	subq.b	#1,d0
	cmp.b	#'5',(a0)+
	bne	errhdr
;.loc15
	cmp.b	#'-',(a0)+
	bne	errhdr

	movep	7(a0),d0
	move.b	6(a0),d0
	swap	d0
	movep	5(a0),d0
	move.b	4(a0),d0
	add.l	a6,d0
	move.l	d0,ptrfin
;
; get original CRC
;
	lea	source+22,a1

	moveq	#0,d0
	move.b	-1(a1),d0

	move.l	a1,a0
	add	d0,a0

	movep	1(a0),d0
	move.b	(a0),d0
	move	d0,orgcrc

	clr.b	(a0)
;
; display file name
;
	PRINTE	source+22		;output file name
	ENDC
;
; decode
;
	MOVE.L	$466.W,-(SP)
;	tst.b	methode
;	beq.s	.copy
	bsr	decode
;	bra.s	.loc20
;.copy
;	move.l	inpptr,a0
;	move.l	ptrfin(pc),a1
;.copyall
;	move.b	(a0)+,(a6)+
;	cmp.l	a1,a0
;	blo.s	.copyall
;.loc20

	MOVE.L	$466.W,D7
	SUB.L	(SP)+,D7

	IFEQ	CHKSUM
;
; make CRC table
;
makecrc:
	lea	crctbl(pc),a0
	lea	$100(a0),a1
	moveq	#0,d2
.v1
	move	d2,d0
	moveq	#8-1,d1
.v2
	lsr	#1,d0
	bcc.s	.v3
	eor	#CRC16,d0
.v3
	dbra	d1,.v2
	move.b	d0,(a1)+
	lsr	#8,d0
	move.b	d0,(a0)+

	addq.b	#1,d2
	bne.s	.v1
;
; check CRC
;
calccrc:
	lea	dest,a0
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

	lea	dest,a0
	move.l	a6,a1
exit:
exit1:
	moveq	#0,d0
exit2:
	illegal
bug:
	illegal

errhdr:
	PRINTE	header(pc)
	bra.s	errout
errcrc:
	PRINTE	crcmess(PC)
	bra.s	errout1
brokenerr:
	PRINTE	broken(PC)
errout:
	PRINTE	error(PC)
errout1:
	moveq	#1,d0
	illegal
;
; extract routines
;
decode:


	moveq	#16,nbbits

	IFEQ	MPK
	move	(inpptr),bitbuf
	ELSEIF
	movep	(inpptr),bitbuf
	move.b	1(inpptr),bitbuf
	ENDC

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

	lea	-2(a6),a0
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

	moveq	#16,d1			;bug corrig‚
	sub	d3,d1			;ne pas scratcher d3
	lsr	d1,d0

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

;	moveq	#16,d1		;bug corrig‚
;	sub	d3,d1		;(correction inutile ici)
	lsr	d1,d0		;(mais gagne 2 octets)

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

	fillbufq	#3

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

	fillbufq	#2

	subq	#1,d1
;	blo	bug			;le programme peut passer par ici !!!
	blo.s	.not2

	moveq	#0,d0
.loc11	move.b	d0,(a4)+
	dbra	d1,.loc11

.not2
	cmp.l	a2,a4
	blo.s	.do1

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

	fillbufq	#4

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
;	bra	make_table
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

	BEQ	bug			;impossible ???

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

	BEQ	bug			;impossible ???

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

;	list

;	nolist
;
; liste des variables utilis‚es
;
	section	data
;
cright:	dc.b	"LHA 2.11 converted by MCODER",13,10,0
broken:	dc.b	'Broken file',0
header:	dc.b	'Header',0
crcmess:dc.b	'CRC'
error:	dc.b	' Error',0
	even

	section	bss

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

ptrfin:	ds.l	1

blocksize:ds.w	1

orgcrc	ds.w	1
crctbl	ds.w	$100
crctbl2	ds.w	$100
	even

;methode:ds.b	1
	even
