TCHAMP: EQU	985000

MADE:	EQU	32
MIDE:	EQU	-32
DECPL:	EQU	8
HAUTEUR: EQU	-128
DEMAR:	EQU	-65

VMSUP:	EQU	5
VCSUP:	EQU	7
MINSUP: EQU	21000  ;980*32
CINSUP: EQU	980*128
VCOSUP: EQU	880*128
MAXECR: EQU	700

OCCENT: EQU	32
OCNMSK: EQU	$3FF
JLLEQU: EQU	960000

MGAME:	dc.w	2,2
nevt:	dc.b	"cir?.vro",0
	even
CURSCR: dc.l	0
CRCEVT: equ	950000
fievt:	equ	958000-8
FEVTAD: dc.l	CRCEVT
F1SRT:	dc.l	30
CRCLAP: DC.L	580000
F1DEP:	 dc.l	 0
LAP:	dc.w	0
MAIN:	move.w	#-1,CRCEVT
	move.l	CRCLAP(PC),CRCEVT+2
	clr.w	CRCEVT+6

	move.l	#nfic,a1
	move.l	#10000,tfic
	move.l	#adchrg,adfic
	jsr	lofic
	tst.w	err
	beq.s	bis1
ille:	illegal
bis1:	move.l	#pagvoit,a1
	move.l	#32500,tfic
	move.l	#842000,adfic
	jsr	lofic
	tst.w	err
	bne.s	ille
	move.l	#roues,a1
	move.l	#32500,tfic
	move.l	#874034,adfic
	jsr	lofic
	tst.w	err
	bne.s	ille
	move.l	#spri,a1
	move.l	#16000,tfic
	move.l	#820000,adfic
	jsr	lofic
	tst.w	err
	bne.s	ille
	move.l	#tbrout,a1
	move.l	#18500,tfic
	move.l	#960000,adfic
	jsr	lofic
	tst.w	err
	bne.L	ille
	move.l	#tabt,a1
	move.l	#4100,tfic
	move.l	#985000,adfic
	jsr	lofic
	tst.w	err
	bne	ille
	move.w	#0,nolog
	jsr	ESSAI
	tst.w	err
	bne.L	ille
	move.w	#1,nolog
	jsr	ESSAI
	tst.w	err
	bne.L	ille
bis:	clr.w	topvib
	jsr	INIVOI
	jsr	INISCL
	jsr	meptig
	move.l	#160,JOY
	move.w	#100,JOY+4
	clr.l	JOY+6
	clr.l	JOY+10
	clr.w	JOY+12
; a inserer dans init de vroom
	move.w	#1338,d0
	move.l	#JLLEQU+2050+8000,a0
	move.l	#JLLEQU+2050+16004,a1
	move.l	#JLLEQU+2050+16004+2678,a2
bi3v:	move.w	(a0)+,d1
	lsr.w	#6,d1
	addq.w	#2,a0
	move.b	d1,(a1)+
	move.w	#256,d2
	sub.w	d1,d2
	cmp.w	#256,d2
	bne.s	sbi3v
	move.w	#255,d2
sbi3v:	move.b	d2,-(a2)
	dbf	d0,bi3v

	move.l	#JLLEQU+2050+16004,admodr
main1:
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#842002,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp 
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
      
	
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,adecr

;	 move.l	d0,CURSCR
	move.l	#906000,CURSCR
	move.l	adecr,a0
	move.l	#842034+21440,a1
	move.w	#2639,d0
bafban: move.l	(a1)+,(a0)+
	dbf	d0,bafban


	move.w	#5,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,sp 
	jsr	INICLAV
tutu:		   clr.l   figam
	move.l	#esevt1,figam+4
  
	bsr	valio
bgend:	move.l	#tein,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp 
bgen:	moveq	#0,d0
	move.w	cptvbl+2,d0
	beq.s	pafvv
	clr.w	cptvbl+2
	moveq	#1,d6
	move.l	#tevi+10,a0
	jsr	ecrit
	move.l	#tevi,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
pafvv:
	move.w	JOY+2,d0
	sub.w	#160,d0
	blt.s	tourg
	cmp.w	#271,d0
	ble.s	strg
	move.w	#271,d0
tourg:	cmp.w	#-271,d0
	bge.s	strg
	move.w	#-271,d0
strg:	move.w	d0,volant
	ADD.W	#271,D0
	lsr.w	#3,d0
	lea.l	tpvo(pc),a0
	move.b	0(a0,d0.w),d0
	MOVE.W	D0,PVOL
	move.w	JOY,d0
	beq.s	pavites
	cmp.w	#1,d0
	beq.s	decel
	move.w	F1DEP,d0
	cmp.w	#526,d0
	bge	pavites
	add.w	#12,F1DEP
	bra	pavites
decel:	move.w	F1DEP,d0
	ble	pavites
	sub.w	#12,F1DEP
pavites:
; trt du mvt des roues
	move.w	F1DEP,d0
	MOVE.W	D0,D1
	LSR.W	#1,D1
	ADD.W	D1,D0
	cmp.w	#128+16,d0
	ble.s	mvtrm
	move.w	#128+16,d0
mvtrm:	add.w	d0,PANIM
;************************
	MOVE.W	JOY+6,D0
	tst.w	d0
	beq	s0bgen
	cmp.w	#$62,d0
	beq	cmp11
	CLR.W	JOY+6
	btst	#7,d0
	bne	s0bgen
	JSR	CNVASCI
	cmp.b	#" ",d0
	beq	cmp11
	cmp.b	#"P",d0
	bne.s	cmpgt
	move.l	Y1(pc),say1
	bra	s0bgen
say1:	dc.l	0
but:	dc.l	0
cmpgt:	cmp.b	#"G",d0
	bne.s	cmpre
	move.l	say1(pc),but
	bsr	rtrepo
	bra	bgen
rtrepo: move.w	#1,typtrt
	move.l	but(pc),d0
	cmp.l	Y1(pc),d0
	beq.s	frtrpo
	bgt.s	srepo
	add.l	CRCLAP(PC),d0
srepo:	sub.l	Y1(pc),d0
	cmp.l	#16000,d0
	ble.s	s1repo
	move.w	#16000,d0
s1repo: move.w	d0,F1DEP
	bsr	s1bgen
	clr.l	haldco
	clr.w	inild
	clr.l	decaco
	clr.w	dafec
	clr.w	rafec
	bra.s	rtrepo
frtrpo: clr.w	typtrt
	clr.w	F1DEP
	rts

cmpre:	cmp.b	#"R",d0
	bne.s	cmpav
	move.l	Y1(pc),d0
	sub.l	#5000,d0
	bge.s	srecul
	add.l	CRCLAP(PC),d0
srecul: move.l	d0,but
	bsr	rtrepo
	bra	bgen
cmpav:	cmp.b	#"A",d0
	bne.s	cmpde
	move.l	Y1(pc),d0
	add.l	#20000,d0
	cmp.l	CRCLAP(PC),d0
	blt.s	savan
	sub.l	CRCLAP(PC),d0
savan:	move.l	d0,but
	bsr	rtrepo
	bra	bgen
cmpde:	cmp.b	#"I",d0
	bne.s	cmpex
	clr.l	but
	bsr	rtrepo
	bra	bgen
cmpex:	cmp.b	#"X",d0
	bne.s	cmpec
	move.w	#1,erase
	bra.s	erasco
erase:	dc.w	0
cmpec:	cmp.b	#"D",d0
	bne	cmedi
	clr.w	erase
erasco: move.l	#tede,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	FEVTAD(pc),a5
	move.l	a5,sfevt
	clr.w	F1DEP
sdelo:	cmp.w	#-1,(a5)
	bne.s	s1delo
	move.l	#CRCEVT,a5
s1delo: move.w	(a5),d0
	and.w	#$3,d0
	tst.w	erase
	beq.s	eras1
	cmp.w	#1,d0
	ble.s	s2delo
	bra.s	seras
eras1:	subq.w	#2,d0
	bge.s	s2delo
seras:	lea.l	8(a5),a5
	bra.s	sdelo
s2delo: move.l	#fievt,d7
	sub.l	a5,d7
	lsr.w	#3,d7
	subq.w	#1,d7
	move.l	a5,a0
	lea.l	8(a0),a1
bdelo:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,bdelo
	cmp.l	sfevt(pc),a5
	bge.s	pcha5
	subq.l	#8,FEVTAD
pcha5:	move.l	a5,-(sp)
	bsr	s1bgen
	move.l	(sp)+,a5
bde:	MOVE.W	JOY+6,D0
	tst.w	d0
	beq.s	bde
	CLR.W	JOY+6
	btst	#7,d0
	bne.s	bde
	cmp.b	#$4e,d0
	bne.s	s3del
	bsr	annul
	move.l	sfevt(pc),FEVTAD
	lea.l	8(a5),a5
	bra	sdelo
s3del:	cmp.b	#$61,d0
	bne.s	s5del
	bsr	annul
	move.l	sfevt(pc),FEVTAD
	bra	bgend
s5del:	cmp.b	#$62,d0
	bne.s	s4del
	move.l	sfevt(pc),FEVTAD
	bsr	annul
	bra	cmp11
s4del:	cmp.b	#$1c,d0
	bne.s	bde
	bsr	valio
	bra	bgend
sfevt:	dc.l	0
cmedi:	cmp.b	#"E",d0
	bne	cmpsa
	clr.w	pavoi
	move.l	#tedi,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	FEVTAD(pc),a5
	clr.w	F1DEP
sedi0:	cmp.w	#-1,(a5)
	bne.s	sedi1
	move.l	#CRCEVT,a5
sedi1:	move.w	(a5),d0
	and.w	#$3,d0
	beq.s	sedi2
	lea.l	8(a5),a5
	bra.s	sedi0
sedi2:	move.l	2(a5),but
	sub.l	#10,but
	bge.s	sedi2b
	clr.l	but
sedi2b:	move.l	a5,-(sp)
	bsr	rtrepo
	move.l	(sp)+,a5
	move.b	(a5),valdg
	clr.w	d0
	move.b	1(a5),d0
	lsr.w	#5,d0
	move.w	d0,posco+24
	move.b	1(a5),pavoi+1
	and.b	#$f,pavoi+1
	move.l	a5,-(sp)
	bsr	afpoto
	bsr	s1bgen
	move.l	(sp)+,a5
sedi3:	MOVE.W	JOY+6,D0
	tst.w	d0
	beq.s	sedi3
	CLR.W	JOY+6
	btst	#7,d0
	bne.s	sedi3
	cmp.b	#$4e,d0
	bne.s	sedi4
	lea.l	8(a5),a5
	bra	sedi0
sedi4:	cmp.b	#$61,d0
	bne.s	sedi5
	bra	bgend
sedi5:	cmp.b	#$62,d0
	bne.s	sedi6
	bra	cmp11
sedi6:	cmp.b	#$1c,d0	;edit courb
	bne.s	sedi3
	move.l	a5,sava5
sedi7:	lea.l	posco(pc),a5
	move.w	valdg(pc),d1
	move.b	pavoi+1(pc),d1
	move.w	24(a5),d4
	lsl.w	#5,d4
	or.b	d4,d1
	move.l	sava5(pc),a0
	move.w	d1,(a0)
	bsr	s1bgen
	bsr	rtcurt
	bsr	annul
	bra.s	sedi7
sava5:	dc.l	0
cmpsa:	cmp.b	#"S",d0
	bne.s	cmplo
	jsr	sacir
	tst.w	err
	beq	bgend
	clr.w	err
	bra	bgen
cmplo:	cmp.b	#"L",d0
	bne.s	cmptt
	tst.l	Y1
	bne	bgen
	jsr	locir
	tst.w	err
	beq.s	scmplo
	clr.w	err
	bra	bgen
scmplo: bsr	valio
	move.l	#CRCEVT,a0
scol:	move.w	(a0),d0
	lea.l	8(a0),a0
	cmp.w	#-1,d0
	beq	bgen
	and.w	#$3,d0
	cmp.w	#2,d0
	bne.s	scol
	move.b	-8(a0),nolog+1
	move.l	a0,-(sp)
	jsr	ESSAI
	move.l	(sp)+,a0
	tst.w	err
	beq.s	scol
	jsr	error2
	clr.w	err
	bra	bgen
cmptt:	cmp.b	#"T",d0
	bne	cmpob
	move.l	#CRCEVT,a1
	move.l	#ttobj,a5
	move.l	#dejo,a4
	moveq	#0,d7
	moveq	#8,d6
btt:	cmp.w	#-1,(a1)
	beq	fbtt
	move.w	(a1),d0
	and.w	#$3,d0
	cmp.w	#2,d0
	beq.s	sbtt
s1btt:	addq.w	#8,d6
	lea.l	8(a1),a1
	bra.s	btt
sbtt:	move.l	#adchrg,a0
	clr.w	d0
	move.b	(a1),d0
	cmp.w	#200,d0
	bgt.s	s1btt
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	beq.s	s1btt
	add.w	d0,a0
	clr.w	d0
	move.b	6(a0),d0
	beq.s	s1btt
	clr.w	d1
	move.b	7(a0),d1
	blt.s	s2btt
	tst.b	0(a4,d1.w)
	bne.s	s2btt
	move.b	#1,0(a4,d1.w)
	add.w	d1,d1
	moveq	#0,d5
	move.w	0(a5,d1.w),d5
	add.l	d5,d7
s2btt:	addq.w	#8,a0
	subq.w	#2,d0
	blt.s	s1btt
bbtt:	clr.w	d1
	move.b	(a0),d1
	blt.s	sbbtt
	tst.b	0(a4,d1.w)
	bne.s	sbbtt
	move.b	#1,0(a4,d1.w)
	add.w	d1,d1
	moveq	#0,d5
	move.w	0(a5,d1.w),d5
	add.l	d5,d7
sbbtt:	lea.l	4(a0),a0
	dbf	d0,bbtt
	bra.s	s1btt
fbtt:	move.w	#31,d5
rafrai: clr.l	(a4)+
	dbf	d5,rafrai
	moveq	#0,d5
	move.w	(a5)+,d5
	add.l	d5,d7
	moveq	#0,d5
	move.w	(a5)+,d5
	add.l	d5,d7
	moveq	#0,d5
	move.w	(a5),d5
	add.l	d5,d7
	lea.l	teci+10(pc),a0
	moveq	#0,d0
	move.w	d6,d0
	move.w	#3,d6
	bsr	ecrit
	lea.l	teot+10(pc),a0
	move.w	#5,d6
	move.l	d7,d0
	bsr	ecrit
	lea.l	teto+10(pc),a0
	move.w	#2,d6
	moveq	#0,d0
	move.w	nbob,d0
	bsr	ecrit
	lea.l	tets+10(pc),a0
	move.w	#2,d6
	moveq	#0,d0
	move.w	nbsprit,d0
	bsr	ecrit
	move.l	#teci,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bra	bgen
teci:	dc.b	$1b,"Y",32+2,32+20,"T CIR ",0,0,0,0
teot:	dc.b	$1b,"Y",32+3,32+20,"T OBJ ",0,0,0,0,0,0
teto:	dc.b	$1b,"Y",32+4,32+20,"N OBJ ",0,0,0
tets:	dc.b	$1b,"Y",32+5,32+20,"N SPR ",0,0,0,0,0
	EVEN
cmpob:	cmp.b	#"O",d0
	bne	cmp0T2
	move.l	#teob,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#2,d1
	move.l	#100,d2
	moveq	#0,d3
bob:	MOVE.W	JOY+6,D0
	tst.w	d0
	beq.s	bob
	CLR.W	JOY+6
	btst	#7,d0
	bne.s	bob
	JSR	CNVASCI
	cmp.b	#"0",d0
	blt.s	bob
	cmp.b	#"9",d0
	bgt.s	bob
	movem.l d0-d3,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l (sp)+,d0-d3
	sub.b	#"0",d0
	mulu	d2,d0
	add.w	d0,d3
	divu	#10,d2
	ext.l	d2
	dbf	d1,bob
	move.w	d3,nolog
	jsr	ESSAI
	tst.w	err
	beq.s	crobj
	jsr	error2
	clr.w	err
	bra	bgend
crobj:	clr.w	F1DEP
	move.w	nolog,d1
	cmp.w	#220,d1
	bge	crob3d
	lea.l	caddbl(pc),a0
	move.w	(a0)+,d0
bcadd:	cmp.b	(a0)+,d1
	bne.s	sbcadd
	lsl.w	#8,d1
	move.b	#2+8,d1
	move.w	d1,pavoi
	bra.s	fbcadd
sbcadd: dbf	d0,bcadd
	lsl.w	#8,d1
	move.b	#2,d1
	move.w	d1,pavoi
	bsr	afposco
fbcadd: lea.l	posco(pc),a5
	move.w	18(a5),d7
	subq.w	#1,d7
	moveq	#0,d0
	move.w	(a5),d0
	move.w	d_g(pc),d4
	move.w	6(a5),d3
bchmu:	bsr	affevt
	moveq	#0,d5
	move.w	12(a5),d5
	add.l	d5,d0
	dbf	d7,bchmu
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	move.w	pavoi(pc),d1
	bra.s	fbcadd

tpvo:	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2
	dc.b	3,3
	dc.b	4,4,4,4,4,4
	dc.b	5,5,5,5,5,5,5,5,5,5,5,5,5,5
	dc.b	6,6,6,6,6,6,6,6,6,6,6,6,6
teob:	dc.b	$1b,"Y",32+1,32+1,"OBJET ",0
tede:	dc.b	$1b,"Y",32+1,32+1,"DELETE",0
tedi:	dc.b	$1b,"Y",32+1,32+1,"EDIT COURBE ",0
tein:	dc.b	$1b,"Y",32+1,32+1,"	 CONDUITE		    ",0
	even
caddbl: dc.w	28	;nb pied dbl - 1
	dc.b	10,11,15,18,19,21,22,55,61,62,63,67	;no logiq
        dc.b    100,101,102,103,104,105,106,107,108
        dc.b    109,111,112,113,115,125,126,127
	even
crob3d: cmp.b	#220,d1
	bne.s	cmpp3
crpt1:	move.b	#220,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	move.w	#1,d4
	move.w	#-64,d3
	bsr	affevt
	move.b	#221,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	moveq	#0,d5
	move.w	12(a5),d5
	add.l	d5,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra.s	crpt1
cmpp3:	cmp.b	#232,d1
	bne.s	cmp0p
crpt3:	move.b	#232,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	move.w	#1,d4
	move.w	#-64,d3
	bsr	affevt
	move.b	#233,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	moveq	#0,d5
	move.w	12(a5),d5
	add.l	d5,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra.s	crpt3
cmp0p:	
	cmp.b	#222,d1
	bne	cmp0G
crsta:	lea.l	posco(pc),a5
	moveq	#0,d5
	move.w	(a5),d5
	move.w	#$2f,d1
	move.l	d5,d0
	bsr	affevt
	move.b	#222,d1
	lsl.w	#8,d1
	move.b	#2,d1
	move.l	d5,d0
	add.l	#6000,d0
	clr.w	d3
	move.w	#0,d4
	bsr	affevt
	move.b	#223,d1
	lsl.w	#8,d1
	move.b	#2,d1
	move.l	d5,d0
	add.l	#6000+4400,d0
	clr.w	d3
	move.w	#0,d4
	bsr	affevt
	move.b	#20,d1
	lsl.w	#8,d1
	move.b	#2,d1
	move.l	d5,d0
	add.l	#6000+100,d0
	move.w	#8,d3
	move.w	#0,d4
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+700,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+1300,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+1900,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+2500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+3100,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+3700,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#6000+4300,d0
	bsr	affevt
	move.w	#$3f,d1
	move.l	d5,d0
	add.l	#6000+4400+800,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra	crsta
cmp0G:	
	cmp.b	#224,d1
	bne.s	cmp0T1
crtr1:	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	moveq	#0,d5
	move.w	12(a5),d5
	move.b	#224,d1
	lsl.w	#8,d1
	move.b	#2,d1
	MOVE.W	#670,d3
	move.w	#0,d4
	bsr	affevt
	move.b	#225,d1
	lsl.w	#8,d1
	move.b	#2,d1
	add.l	d5,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra.s	crtr1
cmp0T1: 
	cmp.b	#226,d1
	bne.s	CMPW
crtr2:	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	moveq	#0,d5
	move.w	12(a5),d5
	move.b	#226,d1
	lsl.w	#8,d1
	move.b	#2,d1
	MOVE.W	#-670,d3
	move.w	#1,d4
	bsr	affevt
	move.b	#227,d1
	lsl.w	#8,d1
	move.b	#2,d1
	add.l	d5,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra.s	crtr2
CMPW:	cmp.b	#228,d1
	bne	CMPX
crpt2:	lea.l	posco(pc),a5
	moveq	#0,d5
	move.w	(a5),d5
	move.b	#228,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	move.l	d5,d0
	MOVE.W	#-64,d3
	move.w	#1,d4
	bsr	affevt
	move.b	#229,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	move.l	d5,d0
	add.l	#500,d0
	bsr	affevt
	move.b	#23,d1
	lsl.w	#8,d1
	move.b	#2,d1
	move.l	d5,d0
	add.l	#100,d0
	move.w	#-32,d3
	move.w	#1,d4
	bsr	affevt
	move.l	d5,d0
	add.l	#250,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#400,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#100,d0
	move.w	#32,d3
	move.w	#0,d4
	bsr	affevt
	move.l	d5,d0
	add.l	#250,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#400,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra.L	crpt2
CMPX:	cmp.b	#230,d1
	bne	s0bgen
crpla:	lea.l	posco(pc),a5
	moveq	#0,d5
	move.w	(a5),d5
	move.b	#230,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	move.l	d5,d0
	MOVE.W	#-128,d3
	move.w	#1,d4
	bsr	affevt
	move.b	#231,d1
	lsl.w	#8,d1
	move.b	#2+8,d1
	move.l	d5,d0
	add.l	#4000,d0
	bsr	affevt
	move.b	#23,d1
	lsl.w	#8,d1
	move.b	#2,d1
	move.w	#-64,d3
	move.w	#1,d4
	move.l	d5,d0
	add.l	#500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#1000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#1500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#2000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#2500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#3000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#3500,d0
	bsr	affevt
	move.w	#64,d3
	move.w	#0,d4
	move.l	d5,d0
	add.l	#500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#1000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#1500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#2000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#2500,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#3000,d0
	bsr	affevt
	move.l	d5,d0
	add.l	#3500,d0
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	bra	crpla
cmp0T2: 
	cmp.b	#"V",d0
	bne.L	cmp0m
	clr.w	F1DEP
	move.l	#tevo,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#2,d1
bvoi:	MOVE.W	JOY+6,D0
	tst.w	d0
	beq.s	bvoi
	CLR.W	JOY+6
	btst	#7,d0
	bne.s	bvoi
	JSR	CNVASCI
	cmp.b	#"0",d0
	blt.s	bvoi
	cmp.b	#"3",d0
	bgt.s	bvoi
	movem.l d0-d3,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l (sp)+,d0-d3
	sub.b	#"0",d0
	clr.w	d1
	move.b	tvoi(pc,d0.w),d1
	move.w	d1,pavoi
crvoi:	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	clr.w	d3
	clr.w	d4
	bsr	affevt
	bsr	s1bgen
	bsr	rtcur
	bsr	annul
	move.w	pavoi(pc),d1
	bra	crvoi
pavoi:	dc.w	0
tevo:	dc.b	$1b,"Y",32+1,32+1,"VOIES ",0
tvoi:	dc.b	$0f,$1f,$0b,$1b,$2f,$3f
	even
cmp0m:	cmp.b	#"M",d0
	bne.L	cmp0x
	clr.w	F1DEP
	move.l	#texo,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#2,d1
btop:	MOVE.W	JOY+6,D0
	tst.w	d0
	beq.s	btop
	CLR.W	JOY+6
	btst	#7,d0
	bne.s	btop
	JSR	CNVASCI
	cmp.b	#"0",d0
	blt.s	btop
	cmp.b	#"5",d0
	bgt.s	btop
	movem.l d0-d3,-(sp)
	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	movem.l (sp)+,d0-d3
	sub.b	#"0",d0
	clr.w	d1
	move.b	ttop(pc,d0.w),d1
	move.w	d1,pavoi
	cmp.w	#2,d0
	bgt	trtcourb
crmd:	lea.l	posco(pc),a5
	bsr	derevt
	moveq	#0,d0
	move.w	(a5),d0
	clr.w	d3
	clr.w	d4
	move.w	valmd(pc),d1
	move.b	pavoi+1(pc),d1
	bsr	affevt
	bsr	s1bgen
	bsr	rtcurt
	bsr	annul
	bra.s	crmd
texo:	dc.b	$1b,"Y",32+1,32+1,"TOPOLOGIE ",0
ttop:	dc.b	5,1,9,4,0,8
	even
trtcourb:
	lea.l	posco(pc),a5
	moveq	#0,d0
	move.w	(a5),d0
	clr.w	d3
	move.w	valdg(pc),d1
	move.b	pavoi+1(pc),d1
	move.w	24(a5),d4
	lsl.w	#5,d4
	or.b	d4,d1
	clr.w	d4
	bsr	affevt
	bsr	s1bgen
	bsr	rtcurt
	bsr	annul
	bra	trtcourb
derevt: move.l	#CRCEVT,a0
	moveq	#0,d0
	move.w	(a5),d0
	add.l	Y1(pc),d0
	moveq	#0,d6	;y du der evt
	moveq	#0,d5	;inclin
	clr.w	d1	;type plat
	clr.w	d2	;degre courb
bdern:	move.w	(a0),d3
	cmp.l	2(a0),d0
	blt.s	fdern
	cmp.w	#-1,d3
	beq.s	f1dern
	and.w	#$3,d3
	cmp.w	#1,d3
	bne.s	sdern
	move.l	2(a0),d3
	sub.l	d6,d3	;taille der evt
	cmp.w	#1,d1
	blt.s	s1dern
	beq.s	s0dern
	neg.l	d3
s0dern: move.w	#VMSUP,d7
	sub.w	d2,d7
	asl.l	d7,d3
	add.l	d3,d5
s1dern: move.w	(a0),d1
	and.w	#$f,d1
	lsr.w	#2,d1
	move.b	(a0),d2
	move.l	2(a0),d6
sdern:	lea.l	8(a0),a0
	bra.s	bdern
f1dern: tst.w	d1
	beq.s	f2dern
	move.l	#9999999,incli
	rts
fdern:	sub.l	d6,d0	;taille der evt
	tst.w	d1
	beq	f2dern
	clr.w	d4
	move.b	d2,d4
	add.w	d4,d4
	add.w	d4,d4
	moveq	#0,d7
	move.w	recala(pc,d4.w),d7
	move.l	d0,d3
	add.l	d7,d0
	and.w	recala+2(pc,d4.w),d0
	sub.l	d0,d3
	sub.w	d3,(a5)
	cmp.w	#1,d1
	beq.s	s3dern
	neg.l	d0
s3dern: move.w	#VMSUP,d7
	sub.w	d2,d7
	asl.l	d7,d0
	add.l	d0,d5
f2dern: move.w	#VMSUP,d7
	sub.b	valmd(pc),d7
	asr.l	d7,d5
	move.l	d5,incli
	rts
recala: dc.w	0,$ffff,1,$fffe,3,$fffc,7,$fff8,15,$fff0,31,$ffe0
	dc.w	63,$ffc0,127,$ff80
cmp0x:	cmp.b	#"0",d0
	bne.s	cmp00
	clr.l	degre
	bra	s0bgen
cmp00:	cmp.b	#"J",d0
	bne.L	cmp0g1
	clr.w	JUMPE+2
	move.w	F1DEP,JUMPE+4
	bra	s0bgen
cmp0g1: cmp.b	#"C",d0
	bne.s	cmp0
	move.w	F1DEP,CRASHE+4
	CLR.W	F1DEP
	move.w	#0,CRASHE+2
	bra	s0bgen
cmp0:	cmp.b	#")",d0
	bne.s	cmp2
	move.w	X2,d0
;	cmp.w	#6,d0
;	bge	s0bgen
	add.w	#1,X2
	bra	s0bgen
cmp2:	cmp.b	#"(",d0
	bne	s0bgen
	move.w	X2,d0
	cmp.w	#0,d0
	ble	s0bgen
	sub.w	#1,X2
	bra	s0bgen
cmp11:	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.w	#$777,-(sp)
	move.w	#3,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	#$000,-(sp)
	move.w	#0,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	old_clav,$118
	move.l	sav_vbl,$70
	move.w	#5,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq.l	#4,sp 
	illegal
savd0:	dc.l	0
affevt: move.l	FEVTAD(pc),a0
	move.l	d0,savd0
	add.l	Y1(pc),d0
	cmp.l	CRCLAP(PC),d0
	blt.s	vmila
	move.l	savd0(pc),d0
	rts
;	 move.l	#CRCEVT,a0
;	 sub.l	 CRCLAP(PC),d0
vmila:	cmp.l	2(a0),d0
	blt.s	mila
	lea.l	8(a0),a0
	bra.s	vmila
mila:	move.l	#fievt,d2
	sub.l	a0,d2
	lsr.w	#3,d2
	subq.w	#2,d2
	move.l	#fievt-8,a1
bdepev: move.l	-8(a1),(a1)
	move.l	-4(a1),4(a1)
	lea.l	-8(a1),a1
	dbf	d2,bdepev

	move.w	d1,(a0)
	move.l	d0,2(a0)
	bclr	#15,d3
	tst.b	d4
	beq.s	pobga
	bset	#15,d3
pobga:	move.w	d3,6(a0)
	move.l	savd0(pc),d0
	rts
affev1: move.l	#32700,d0
	clr.w	d4
	clr.w	d3
	bsr	affevt
	bsr	s1bgen
	bra	bgen

rtcur:	move.w	JOY+6,d0
	beq.s	rtcur
	clr.w	JOY+6
	btst	#7,d0
	bne.s	rtcur
	cmp.w	#$61,d0
	bne.s	cures
	bsr	annul
	move.l	#bgend,(a7)
	rts
cures:	cmp.w	#$62,d0
	bne.s	sorpa
	bsr	annul
	move.l	#cmp11,(a7)
	rts
sorpa:	cmp.w	#$1c,d0
	bne.s	casci
	bsr	valio
	move.l	#bgend,(a7)
	rts
casci:	jsr	CNVASCI
	cmp.b	#"D",d0
	bne.s	curga
	clr.w	d_g
	bra	afposco
curga:	cmp.b	#"G",d0
	bne.s	curpo
	move.w	#1,d_g
	bra	afposco
curpo:	cmp.b	#"P",d0
	bne.s	curla
	clr.w	dco
	bra	rtcur
curla:	cmp.b	#"L",d0
	bne.s	curec
	move.w	#6,dco
	bra	rtcur
curec:	cmp.b	#"E",d0
	bne.s	curqu
	move.w	#12,dco
	bra	rtcur
curqu:	cmp.b	#"Q",d0
	bne.s	curpa
	move.w	#18,dco
	bra	rtcur
curpa:	cmp.b	#"1",d0
	blt.s	curmvt
	cmp.b	#"9",d0
	bgt.s	curmvt
	sub.w	#"1",d0
	add.w	d0,d0
	move.w	pcu(pc,d0.w),pascur
	bra	rtcur
pcu:	dc.w	1,10,50,100,200,500,800,1000,1500
curmvt: cmp.b	#"+",d0
	bne.s	curmo
	lea.l	posco(pc),a0
	move.w	dco(pc),d0
	add.w	d0,a0
	move.w	pascur(pc),d0
	add.w	(a0),d0
	cmp.w	4(a0),d0
	ble.s	curpv
	move.w	4(a0),d0
curpv:	move.w	d0,(a0)
	bra	afposco
curmo:	cmp.b	#"-",d0
	bne	rtcur
	lea.l	posco(pc),a0
	move.w	dco(pc),d0
	add.w	d0,a0
	move.w	(a0),d0
	sub.w	pascur(pc),d0
	cmp.w	2(a0),d0
	bge.s	curmv
	move.w	2(a0),d0
curmv:	move.w	d0,(a0)
	bra	afposco
annul:	move.l	#950000,a0
	move.l	#940000,a1
	move.w	#624,d0
bann:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d0,bann
	rts
valio:	move.l	#950000,a1
	move.l	#940000,a0
	move.w	#624,d0
bvali:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d0,bvali
	rts
pascur: dc.w	1
d_g:	dc.w	0
dco:	dc.w	0
posco:	dc.w	1000,1,31000
	dc.w	0,-16384,16383
	dc.w	100,1,30000
	dc.w	1,1,60
	dc.w	7,0,7	;infuence courbe
incli:	dc.l	0
rtcurt: bsr	afpoto
rtcurm: move.w	JOY+6,d0
	beq.s	rtcurm
	clr.w	JOY+6
	btst	#7,d0
	bne.s	rtcurm
	cmp.w	#$61,d0
	bne.s	curesm
	bsr	annul
	move.l	#bgend,(a7)
	rts
curesm: cmp.w	#$62,d0
	bne.s	sorpam
	bsr	annul
	move.l	#cmp11,(a7)
	rts
sorpam: cmp.w	#$1c,d0
	bne.s	cascim
	bsr	valio
	move.l	#bgend,(a7)
	rts
cascim: move.w	d0,d6
	sub.w	#$3b,d6
	blt.s	curppp
	cmp.w	#8,d6
	bgt.s	curppp
	blt.s	scmp10
	move.w	#7,d6
scmp10: move.b	d6,valdg
	cmp.b	#VMSUP,d6
	ble.s	supo
	move.b	#VMSUP,d6
supo:	move.b	d6,valmd
	rts
curppp: jsr	CNVASCI
	cmp.b	#"P",d0
	bne.s	curlam
	clr.w	dco
	bra	rtcurm
curlam: cmp.b	#"I",d0
	bne.s	curpam
	move.w	#24,dco
	bra	rtcurm
curpam: cmp.b	#"1",d0
	blt.s	curmvm
	cmp.b	#"9",d0
	bgt.s	curmvm
	sub.w	#"1",d0
	add.w	d0,d0
	move.w	pcum(pc,d0.w),pascur
	bra	rtcurm
pcum:	dc.w	1,8,32,128,256,512,512+256,1024,1024+512
curmvm: cmp.b	#"+",d0
	bne.s	curmom
	lea.l	posco(pc),a0
	move.w	dco(pc),d0
	add.w	d0,a0
	move.w	pascur(pc),d0
	add.w	(a0),d0
	cmp.w	4(a0),d0
	ble.s	curpvm
	move.w	4(a0),d0
curpvm: move.w	d0,(a0)
	rts
curmom: cmp.b	#"-",d0
	bne	rtcurm
	lea.l	posco(pc),a0
	move.w	dco(pc),d0
	add.w	d0,a0
	move.w	(a0),d0
	sub.w	pascur(pc),d0
	cmp.w	2(a0),d0
	bge.s	curmvx
	move.w	2(a0),d0
curmvx: move.w	d0,(a0)
	rts
afpoto:
	lea.l	tetop+10(pc),a0
	move.w	#5,d6
	moveq	#0,d0
	move.w	posco(pc),d0
	bsr	ecrit
	lea.l	tecou+10(pc),a0
	move.b	valmd(pc),d0
	btst	#0,pavoi+1
	bne.s	pvalm
	move.b	valdg(pc),d0
pvalm:	add.b	#"0",d0
	move.b	d0,(a0)
	lea.l	teinc+10(pc),a0
	move.w	#4,d6
	move.b	#"+",(a0)+
	move.l	incli(pc),d0
	bge.s	spoto
	neg.l	d0
	move.b	#"-",-1(a0)
spoto:	cmp.l	#9999999,d0
	bne.s	spoto2
	move.b	#"E",-1(a0)
	move.b	#"E",(a0)+
	move.b	#"E",(a0)+
	move.b	#"E",(a0)+
	move.b	#"E",(a0)+
	move.b	#"E",(a0)
	bra.s	spoto3
spoto2:	bsr	ecrit
spoto3:	lea.l	tinfl+10(pc),a0
	move.w	#0,d6
	moveq	#0,d0
	move.w	posco+24(pc),d0
	bsr	ecrit
	move.l	#tetop,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
tetop:	dc.b	$1b,"Y",32+2,32+1,"POSIT ",0,0,0,0,0,0
tecou:	dc.b	$1b,"Y",32+3,32+1,"COURB ",0,"	     "
teinc:	dc.b	$1b,"Y",32+4,32+1,"INCLI ",0,0,0,0,0,0
tinfl:	dc.b	$1b,"Y",32+5,32+1,"INFLU ",0,"	   ",0
	even
afposco:
	lea.l	tepo+10(pc),a0
	move.w	#5,d6
	moveq	#0,d0
	move.w	posco(pc),d0
	bsr	ecrit
	lea.l	tela+10(pc),a0
	move.w	#4,d6
	moveq	#0,d0
	move.b	#"+",(a0)+
	move.w	posco+6(pc),d0
	bge.s	sapoc
	neg.w	d0
	move.b	#"-",-1(a0)
sapoc:	bsr	ecrit
	lea.l	5(a0),a0
	move.b	#" ",(a0)+
	move.b	#"D",(a0)
	tst.w	d_g
	beq.s	sapoc1
	move.b	#"G",(a0)
sapoc1: lea.l	tedc+10(pc),a0
	move.w	#4,d6
	moveq	#0,d0
	move.w	posco+12(pc),d0
	bsr	ecrit
	lea.l	tequ+10(pc),a0
	move.w	#1,d6
	moveq	#0,d0
	move.w	posco+18(pc),d0
	bsr	ecrit
	move.l	#tepo,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
ecrit:	divu	#10,d0
	move.l	d0,d2
	swap	d2
	andi.l	#$0000ffff,d0
	addi.b	#48,d2
	move.b	d2,0(a0,d6.w)
	dbf	d6,ecrit
	rts
tepo:	dc.b	$1b,"Y",32+2,32+1,"POS Y ",0,0,0,0,0,0
tela:	dc.b	$1b,"Y",32+3,32+1,"POS X ",0,0,0,0,0,0,0,0
tedc:	dc.b	$1b,"Y",32+4,32+1,"ECART ",0,0,0,0,0
tequ:	dc.b	$1b,"Y",32+5,32+1,"QUANT ",0,0,0
	even
valdg:	dc.b	4,0
valmd:	dc.b	4,0
XB:	dc.w	0
SHOCKE: DC.W	-1,-1,-1
CRASHE: DC.W	-1,-1,-1,-1
JUMPE:	DC.W	-1,-1,-1,-1

	DC.W	-2
CARSRT: DC.W	480*2,448*2,416*2,384*2,352*2,320*2,288*2,256*2
	DC.W	224*2,192*2,160*2,128*2,96*2,64*2,32*2,0
	DC.W	-1
OCCUR:	dc.w	2
Y1:	dc.l	0
	blk.w	29
F2:	dc.w	$002
	dc.l	1000
	dc.w	0,64
	blk.w	27
	dc.w	$202
	dc.l	1200
	dc.w	0,-160
	blk.w	27
	dc.w	$402
	dc.l	1600
	dc.w	0,0
	blk.w	27
	dc.w	$202  ;5
	dc.l	15600
	dc.w	0,-128
	blk.w	27
	dc.w	$602  ;6
	dc.l	55600
	dc.w	0,-200
	blk.w	27
	dc.w	$402  ;7
	dc.l	55650
	dc.w	0,32
	blk.w	27
	dc.w	$202  ;8
	dc.l	155600
	dc.w	0,92
	blk.w	27
	dc.w	$202  ;9
	dc.l	155800
	dc.w	0,92
	blk.w	27
	dc.w	$202  ;10
	dc.l	156000
	dc.w	0,92
	blk.w	27
	dc.w	$602  ;11
	dc.l	256000
	dc.w	0,-128
	blk.w	27
	dc.w	$402  ;12
	dc.l	256100
	dc.w	0,0
	blk.w	27
	dc.w	$402  ;13
	dc.l	356000
	dc.w	0,92
	blk.w	27
	dc.w	$202  ;14
	dc.l	359000
	dc.w	0,-64
	blk.w	27
	dc.w	$602  ;15
	dc.l	360000
	dc.w	0,32
	blk.w	27
	dc.w	$402  ;16
	dc.l	368000
	dc.w	0,-32
	blk.w	27

RODEQU: BLK.L	600,0
s0bgen: bsr	s1bgen
	bra	bgen
s1bgen: moveq	#0,d0
	move.w	F1DEP(pc),d0
	add.l	d0,Y1
	move.l	CRCLAP(PC),d1
	cmp.l	Y1,d1
	bgt.s	padeci
	move.w	#1,LAP
	sub.l	d1,Y1
	clr.l	fievt
padeci:
	move.w	F1DEP(pc),OCCUR+18
	lea.l	zafvo(pc),a1
	move.l	Y1(pc),(a1)+
	lea.l	OCCUR+64(pc),a0
	move.w	#14,d1
	move.l	CRCLAP(pc),d2
bvoitu: add.l	#349,2(a0)
	move.w	#349,18(a0)
	cmp.l	2(a0),d2
	bgt.s	svoitu
	sub.l	d2,2(a0)
svoitu: move.l	2(a0),(a1)+
	lea.l	64(a0),a0
	dbf	d1,bvoitu
	lea.l	CARSRT(pc),a2
	move.w	#15,d1
	lea.l	zafvo(pc),a1
btrvo:	moveq	#-1,d2
	move.w	#15,d3
	clr.w	d4
b1trvo: cmp.l	(a1)+,d2
	bge.s	s1trvo
	move.l	-4(a1),d2
	move.w	d4,d5
s1trvo: add.w	#64,d4
	dbf	d3,b1trvo
	move.w	d5,(a2)+
	bne.s	pasf1
	move.l	a2,d6
	sub.l	#CARSRT,d6
	subq.w	#2,d6
	move.l	d6,F1SRT
pasf1:	lsr.w	#4,d5
	lea.l	zafvo(pc),a1
	move.l	#-1,0(a1,d5.w)
	dbf	d1,btrvo

	addq.w	#1,compt
	clr.l	cracra
	bsr	CMPROD
	tst.w	typtrt
	beq.s	trtnorm
	clr.w	LAP
	rts
typtrt: dc.w	0
trtnorm:
	bsr	rtsvoit
	clr.l	d7
	tst.w	cracra
	bne.s	nafno
	tst.w	datvoit
	blt.s	unnoi
	move.w	#-1,d7
unnoi:	tst.w	datvoit+16
	blt.s	afnoi
	or.l	#$ffff0000,d7
	bra.s	afnoi
nafno:	move.w	#-1,d7
	swap	d7
	move.w	cracra+2,d7
afnoi:	move.w	#15,d0
	move.l	adecr,a0
	add.w	#152,a0
bafnoi: move.l	d7,(a0)+
	move.l	d7,(a0)+
	lea.l	152(a0),a0
	dbf	d0,bafnoi
	clr.l	cracra
       
	clr.w	LAP
	BSR   DSPROD
	move.l	usp,a5
	jsr	SPRITE
	jsr	AFIPNE
	jsr	AFICAR
	jsr	AFIRET
	jsr	recrec
	rts
compt:	dc.w	0
rtsvoit:
	move.l	Y1(pc),d7
	move.l	d7,d6
	lea.l	CARSRT,a0
	add.l	F1SRT(pc),a0
	lea.l	2(a0),a1
	bsr	recdev
	move.w	d0,d1
	bsr	recder
	lea.l	OCCUR,a2
	move.l	a2,a3
	add.w	d1,a2
	add.w	d0,a3
	move.w	d0,d4
	move.l	2(a2),d2
	sub.l	d7,d2
	move.l	d6,d3
	sub.l	2(a3),d3
	cmp.l	d2,d3
	blt.s	fder
	bsr	recdev	      ;d1 et d2 ok
	lea.l	OCCUR,a4
	add.w	d0,a4
	move.l	2(a4),d5
	sub.l	d7,d5
	cmp.l	d5,d3
	bge.s	votro	     ;d0 et d5
	neg.l	d3
	move.l	d3,d5
	move.w	d4,d0
	bra.s	votro	     ;d4 et d3
fder:	bsr	recder	     ;d4 et d3 ok
	lea.l	OCCUR,a4
	add.w	d0,a4
	move.l	d6,d5
	sub.l	2(a4),d5
	cmp.l	d2,d5
	blt.s	fder1
	neg.l	d3	;d1 et d2
	move.l	d3,d5
	move.w	d4,d0
	bra.s	votro
fder1:	neg.l	d5	;d0 et d5
	neg.l	d3
	move.l	d3,d2
	move.w	d4,d1
votro:	lea.l	OCCUR,a0
	move.w	18(a0),d7
	move.w	18(a0,d1.w),d3
	move.w	18(a0,d0.w),d4
	lsr.w	#6,d1
	lsr.w	#6,d0
	lea.l	datvoit,a1
	cmp.b	4(a1),d1
	bne.s	tes2
	lea.l	16(a1),a2
	bra.s	afson
tes2:	cmp.b	4+16(a1),d1
	bne.s	tes3
tes4:	move.l	a1,a2
	lea.l	16(a1),a1
	bra.s	afson
tes3:	cmp.b	4(a1),d0
	beq.s	tes4
	lea.l	12(a1),a2
afson:	tst.l	d2
	blt.s	son1n
	cmp.l	#12800,d2
	bgt.s	pason1
	move.b	d1,4(a1)
	move.w	d3,d6
	bsr	regmot
	sub.w	d7,d3
	asr.w	#7,d3
	cmp.w	#450,d2
	bgt.s	dop1
	asr.w	#1,d3
dop1:	sub.w	d3,d6
snoup:	bsr	verd6
	move.b	d3,7(a1)
	move.w	d6,(a1)
	bra.s	afso2
son1n:	cmp.l	#-12800,d2
	blt.s	pason1
	move.b	d1,4(a1)
	move.w	d3,d6
	bsr	regmot
	sub.w	d7,d3
	asr.w	#7,d3
	cmp.w	#-450,d2
	blt.s	dop2
	asr.w	#1,d3
dop2:	add.w	d3,d6
	neg.w	d2
	bra.s	snoup
pason1: move.w	#-8,(a1)
	move.b	#-1,4(a1)
afso2:	tst.l	d5
	blt.s	son2n
	cmp.l	#12800,d5
	bgt.s	pason2
	move.b	d0,4(a2)
	move.w	d4,d6
	bsr	regmot
	sub.w	d7,d4
	asr.w	#7,d4
	cmp.w	#450,d5
	bgt.s	dop3
	asr.w	#1,d4
dop3:	sub.w	d4,d6
	move.w	d5,d2
snoup2: bsr	verd6
	move.b	d3,7(a2)
	move.w	d6,(a2)
	bra.s	fafson
son2n:	cmp.l	#-12800,d5
	blt.s	pason2
	move.b	d0,4(a2)
	move.w	d4,d6
	bsr	regmot
	sub.w	d7,d4
	asr.w	#7,d4
	cmp.w	#-450,d5
	blt.s	dop4
	asr.w	#1,d4
dop4:	add.w	d4,d6
	move.w	d5,d2
	neg.w	d2
	bra.s	snoup2
pason2: move.w	#-8,(a2)
	move.b	#-1,4(a2)
fafson: rts
regmot: sub.w	#148,d6
	bge.s	sregmo
	add.w	#148,d6
	lsr.w	#2,d6
	rts
sregmo: move.w	d0,-(sp)
	move.w	#730,d0
	sub.w	d6,d0
	mulu	d6,d0
	lsl.l	#1,d0
	rol.w	#4,d0
	and.w	#$f,d0
	move.w	#25,d6
	add.w	d0,d6
	swap	d0
	sub.w	d0,d6
	move.w	(sp)+,d0
	rts
verd6:	tst.w	d6
	bgt.s	sverd6
	clr.w	d6
	bra.s	verdis
sverd6: cmp.w	#45,d6
	ble.s	fverd6
	move.w	#45,d6
fverd6: nop
verdis: move.w	#6400,d1
	moveq	#4,d3
bvdis:	cmp.w	d1,d2
	bgt.s	fvdis
	subq.w	#1,d3
	ble.s	fvdis
	lsr.w	#1,d1
	bra.s	bvdis
fvdis:	rts
recdev: move.w	-(a0),d0
	bge.s	pchtd
	lea.l	34(a0),a0
	sub.l	CRCLAP(pc),d7
brpvd:	move.w	-(a0),d0
	blt.s	brpvd
pchtd:	rts
recder: move.w	(a1)+,d0
	bge.s	pchtr
	lea.l	CARSRT,a1
	add.l	CRCLAP(pc),d6
	move.w	(a1)+,d0
pchtr:	rts
datvoit: dc.l	-1,-1,0,0
		dc.l	-1,-1,0,0
objdiv: move.w	(a0),d2
	btst	#3,d2
	bne	objdivr
	addq.w	#4,adgam+6
	and.w	#$003f,adgam+6
	move.w	(a0),d2
	and.w	#$4,d2
	lsr.w	#1,d2
	move.w	d2,colban
	bra	procevt
objdivr:
	and.w	#$fffc,d2
	move.w	d2,comodr
	move.l	betrou1(pc),etrou1
	move.l	betrou2(pc),etrou2
	move.w	d7,depmod
	bra	procevt1
vo3ou:	move.w	4(a3),d5
	sub.w	depmod(pc),d5
	lsr.w	#1,d5
	cmp.w	#2677,d5
	ble.s	pacht1
	clr.w	comodr
	move.w	#2677,d5
pacht1: move.l	admodr(pc),a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	sub.w	d5,-8(a0)
	tst.b	-1(a0)
	bne.s	pa2b
	move.b	#-2,-2(a0)
pa2b:	movem.l (sp)+,d5/a5
	rts
vo3fe:	move.w	depmod(pc),d5
	sub.w	4(a3),d5
	asr.w	#1,d5
	cmp.w	#-2678,d5
	bge.s	pacht2
	move.l	metrou1(pc),etrou1
	move.l	metrou2(pc),etrou2
	move.w	#-2678,d5
pacht2: move.l	admodr(pc),a5
	add.w	#2678,a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	sub.w	d5,-8(a0)
	tst.b	-1(a0)
	bne.s	pa2b1
	move.b	#-2,-2(a0)
pa2b1:	movem.l (sp)+,d5/a5
	rts
vo3co:	
	tst.b	-1(a0)
	bne.s	pa2b2
	move.b	#-2,-2(a0)
pa2b2:	sub.w	d2,-8(a0)
	movem.l (sp)+,d5/a5
	rts
garou:	move.w	4(a3),d5
	sub.w	depmod(pc),d5
	lsr.w	#1,d5
	cmp.w	#2677,d5
	ble.s	pacht5
	move.w	#$20,comodr
	move.w	#2677,d5
pacht5: move.l	admodr(pc),a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	add.w	d5,-6(a0)
	tst.b	-1(a0)
	bne.s	pa2bg
	move.b	#-1,-2(a0)
pa2bg:	movem.l (sp)+,d5/a5
	rts
garfe:	move.w	depmod(pc),d5
	sub.w	4(a3),d5
	asr.w	#1,d5
	cmp.w	#-2678,d5
	bge.s	pacht6
	move.l	metrou1(pc),etrou1
	move.l	metrou2(pc),etrou2
	move.w	#-2678,d5
pacht6: move.l	admodr(pc),a5
	add.w	#2678,a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	add.w	d5,-6(a0)
	tst.b	-1(a0)
	bne.s	pa2b1g
	move.b	#-1,-2(a0)
pa2b1g: movem.l (sp)+,d5/a5
	rts
garco:
	tst.b	-1(a0)
	bne.s	pa2b1c
	move.b	#-1,-2(a0)
pa2b1c: add.w	d2,-6(a0)
	movem.l (sp)+,d5/a5
	rts
chiou:	move.w	4(a3),d5
	sub.w	depmod(pc),d5
	lsr.w	#1,d5
	cmp.w	#2677,d5
	ble.s	pacht3
	move.w	#4,comodr
	move.w	#2677,d5
pacht3: move.l	admodr(pc),a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	add.w	d5,-8(a0)
	move.b	#1,-2(a0)
	movem.l (sp)+,d5/a5
	rts
chife:	move.w	depmod(pc),d5
	sub.w	4(a3),d5
	asr.w	#1,d5
	cmp.w	#-2678,d5
	bge.s	pacht4
	move.l	metrou1(pc),etrou1
	move.l	metrou2(pc),etrou2
	move.w	#-2678,d5
pacht4: move.l	admodr(pc),a5
	add.w	#2678,a5
	move.b	0(a5,d5.w),d5
	and.w	#$ff,d5
	mulu	d2,d5
	lsr.l	#8,d5
	add.w	d5,-8(a0)
	move.b	#1,-2(a0)
	movem.l (sp)+,d5/a5
	rts
chico:	
	add.w	d2,-8(a0)
	move.b	#1,-2(a0)
	movem.l (sp)+,d5/a5
	rts
metrou1: dc.l	$30fa0146
metrou2: dc.l	$30fa011c
betrou1: dc.l	$61000148
betrou2: dc.l	$6100011e
* CMPROD - Stripes and Road Computation
CMPROD: 
;  TRT TABLES MULTIPL
	MOVE.W	p_champ(PC),D0
	CMP.W	p_champ+2(PC),D0
	BEQ.S	PCHCH
	MOVE.W	D0,p_champ+2
	MOVE.W	D0,D1
	ADD.W	D1,D1
	LEA.L	vchamp(pc),A0
	MOVE.W	0(A0,D1.W),p_champ+4
	MOVE.L	#JLLEQU,A0
	MOVE.L	#TCHAMP,A1
	SWAP	D0
	CLR.W	D0
	LSR.L	#6,D0
	ADD.W	D0,A1
	MOVE.W	(A1),D1
	MOVE.W	D1,D0
	MOVE.W	#254,D2
	SUB.W	D1,D2
	SUBQ.W	#1,D0
	ADD.W	D1,D1
	ADD.W	D1,A1
B1CHCH: MOVE.W	(A1),(A0)+
	MOVE.W	#$7FFF,(A0)+
	DBF	D0,B1CHCH
	ADDQ.W	#2,A1
	MOVE.W	#32768-128,D1
BCHCH:	MOVE.W	(A1)+,(A0)+
	MOVE.W	D1,(A0)+
	SUB.W	#128,D1
	DBF	D2,BCHCH
	ADDQ.W	#4,A0
	MOVE.W	#255,D2
B2CHCH: MOVE.W	(A1)+,(A0)+
	DBF	D2,B2CHCH
PCHCH:	clr.l	nbob	  ;virer 
	move.l	#JLLEQU+2050+16004,admodr
	move.l	FEVTAD(pc),a0
	move.l	Y1(pc),posvoit
	tst.w	LAP
	beq.s	pchtour
	move.l	CRCLAP(pc),d0
	add.l	d0,posvoit
pchtour:
	moveq	#0,d2
	move.w	F1DEP(pc),d2
	tst.w	topmod
	beq.s	pamodro
	blt.s	tmodco
	sub.w	d2,topdep
	cmp.w	#-5356,topdep
	bgt.s	t0modc
	move.w	topcod(pc),d3
	btst	#4,d3
	beq.s	oumod
	clr.w	topmod
	bra.s	pamodro
oumod:	move.w	#-1,topmod
	move.w	#4,topcod
	btst	#2,d3
	beq.s	t0modc
	clr.w	topcod
	btst	#5,d3
	beq.s	t0modc
	move.w	#$20,topcod
t0modc: move.w	topdep(pc),depmod
tmodco: move.l	betrou1(pc),etrou1
	move.l	betrou2(pc),etrou2
	move.w	topcod(pc),comodr
	bra.s	fmodro
pamodro:
	move.l	metrou1(pc),etrou1
	move.l	metrou2(pc),etrou2
fmodro: 
	tst.w	MGAME+2
	bne	angul
; mode parallele
	tst.b	evnco
	bne.s	tourne
	clr.w	mvtscrol
	bra.s	ftour
tourne: clr.w	d7
	move.b	vaco(pc),d7
	add.w	d7,d7
	move.w	ttour(pc,d7.w),d7
	muls	d2,d7
	move.w	#2,d0	  ; ****** a voir
	asr.l	d0,d7
	move.w	reste(pc),d5
	ext.l	d5
	add.l	d5,d7
	divs	#450,d7
	neg.w	d7
	move.w	d7,mvtscrol   ;****** move.w
	swap	d7
	move.w	d7,reste
	bra.s	ftour
ttour:	dc.w	512,256,128,64,32,16,8,4
ftour:
	moveq	#0,d3
	tst.b	evnmo
	beq.s	avavt
	bgt.s	nhau
	move.w	d2,d3
	neg.w	d3
	bra.s	snhau
nhau:	move.w	d2,d3
snhau:	move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
	asl.w	d7,d3
	ext.l	d3

avavt:	move.l	2(a0),d0
	sub.l	posvoit(pc),d0
	bgt	fava
	move.w	(a0),d1
	cmp.w	#-1,d1
	bne.s	ppchto
	move.l	Y1(pc),posvoit
	move.l	#CRCEVT,a0
	move.l	a0,FEVTAD
	bra.s	avavt
ppchto: and.w	#$3,d1
	lsl.w	#2,d1
	jmp	ptevn(pc,d1.w)
ptevn:	bra.l	pcourco
	bra.l	pinclco
	bra.l	pobjco
	bra.l	pmroco
	nop
pobjco: cmp.b	#4,(a0)
	bgt	psava
;	 movem.l d0-d7/a0-a6,-(sp)
;	 move.l	#940002,-(sp)
;	 move.w	#6,-(sp)
;	 trap	 #14
;	 addq.l	#6,sp
;	 movem.l (sp)+,d0-d7/a0-a6
	bra	psava
pmroco: move.w	(a0),comodr
	and.w	#$fffc,comodr
	move.l	betrou1(pc),etrou1
	move.l	betrou2(pc),etrou2
	move.w	d0,depmod
	move.w	#1,topmod
	move.w	depmod(pc),topdep
	move.w	comodr(pc),topcod
	bra	psava
pcourco: move.w  (a0),d1
	lsr.w	#2,d1
	and.w	#$3,d1
	move.b	(a0),vaco
	move.b	pcorr(pc,d1.w),evnco
	bra.s	psava
pinclco: move.w  (a0),d1	
	lsr.w	#2,d1
	and.w	#$3,d1
	move.w	d0,d4
	tst.b	evnmo
	beq.s	pstabl
	bgt.s	pinhau1
	neg.w	d4
pinhau1: asl.w	 d7,d4
	ext.l	d4
	add.l	d4,d3
pstabl: move.b	(a0),vamo
	move.b	pcorr(pc,d1.w),evnmo
	beq.s	psava
	bgt.s	pinhau2
	neg.w	d0
pinhau2: move.w  #VMSUP,d7
	sub.b	vamo(pc),d7
	asl.w	d7,d0
	ext.l	d0
	sub.l	d0,d3
	bra.s	psava
pcorr:	dc.b	0,1,-1,0
	
psava:	 addq.l #8,a0
	move.l	a0,FEVTAD
	bra.L	avavt

angul:	move.w	volant(pc),d7
	tst.w	JUMPE+2
	blt.s	angnor
	clr.w	d7
angnor: muls	d2,d7
	move.w	#2,d0	  ; ****** a voir
	asr.l	d0,d7
	sub.l	d7,haldco
	move.w	reste(pc),d5
	ext.l	d5
	add.l	d5,d7
	divs	p_champ+4(pc),d7
	neg.w	d7
	move.w	d7,mvtscrol   ;****** move.w
	swap	d7
	move.w	d7,reste
	bsr	contro1

	moveq	#0,d5
	tst.b	evnco
	bne.s	indrg
	bsr	cacinc
	muls	d2,d4
	asr.l	#DECPL,d4
	add.l	d4,decaco
	bra.s	modhau		    
indrg:	bgt.s	indro
	move.w	d2,d5
	neg.l	d5
	move.w	#VCSUP,d6
	sub.b	vaco(pc),d6
	asl.l	d6,d5
	bsr	cdepet
	move.l	d4,d7
	add.l	d5,haldco
	bsr	contro1
	bsr	cacdec
	move.l	d4,d5
	sub.l	d4,d7
	add.l	d7,decaco
	bra.s	modhau
indro:	move.w	d2,d5
	move.w	#VCSUP,d6
	sub.b	vaco(pc),d6
	asl.l	d6,d5
	bsr	cdepet
	move.l	d4,d7
	add.l	d5,haldco
	bsr	contro1
	bsr	cacdec
	move.l	d4,d5
	sub.l	d7,d4
	add.l	d4,decaco

modhau: move.l	haldco(pc),d3	;limit angul voit
	cmp.l	#VCOSUP,d3
	ble.s	lvco1
	move.l	#VCOSUP,haldco
	bra.s	flvco
lvco1:	cmp.l	#-VCOSUP,d3
	bge.s	flvco
	move.l	#-VCOSUP,haldco
flvco:	moveq	#0,d3
	tst.b	evnmo
	beq.s	avaevt
	bgt.s	inhau
	move.w	d2,d3
	neg.w	d3
	bra.s	sinhau
inhau:	move.w	d2,d3
sinhau: move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
	asl.w	d7,d3
	ext.l	d3

avaevt: move.l	2(a0),d0
	sub.l	posvoit(pc),d0
	bgt	fava
	move.w	(a0),d1
	cmp.w	#-1,d1
	bne.s	pchto
	move.l	Y1(pc),posvoit
	move.l	#CRCEVT,a0
	move.l	a0,FEVTAD
	bra.s	avaevt
pchto:	and.w	#$3,d1
	lsl.w	#2,d1
	jmp	tevn(pc,d1.w)
tevn:	bra.l	courco
	bra.l	inclco
	bra.l	objco
	bra.l	mroco
	nop
objco:	
	movem.l d0-d7/a0-a6,-(sp)
	move.l	a0,a4
	jsr	tstcra	   ;a virer
	movem.l (sp)+,d0-d7/a0-a6
	bra	sava
mroco:	move.w	(a0),comodr
	and.w	#$fffc,comodr
	move.l	betrou1(pc),etrou1
	move.l	betrou2(pc),etrou2
	move.w	d0,depmod
	move.w	#1,topmod
	move.w	depmod(pc),topdep
	move.w	comodr(pc),topcod
	bra	sava

courco: move.w	(a0),d1 
	lsr.w	#2,d1
	and.w	#$3,d1
	move.w	d0,d6
	tst.b	evnco
	bne.s	pstal
	muls	inild(pc),d6
	asr.l	#DECPL,d6
	add.l	d6,decaco
	bra.s	stabld
pstal:	bgt.s	indro1
	neg.w	d6
	move.w	#VCSUP,d7
	sub.b	vaco(pc),d7
	ext.l	d6
	asl.l	d7,d6
	add.l	d6,haldco
	bsr	cacdec
	sub.l	d4,d5
	add.l	d5,decaco
	move.l	d4,d5
	bra.s	stabld
indro1: move.w	#VCSUP,d7
	sub.b	vaco(pc),d7
	ext.l	d6
	asl.l	d7,d6
	add.l	d6,haldco
	bsr	cacdec
	move.l	d4,d6
	sub.l	d5,d4
	add.l	d4,decaco
	move.l	d6,d5
	
stabld: move.b	(a0),vaco
	move.b	corr1(pc,d1.w),evnco
	bne.s	pstab2
	bsr	cacinc
	muls	d4,d0
	asr.l	#DECPL,d0
	sub.l	d0,decaco
	bra	sava
pstab2: bgt.s	indro2
	neg.w	d0
	move.w	#VCSUP,d7
	sub.b	vaco(pc),d7
	ext.l	d0
	asl.l	d7,d0
	bsr	cdepet
	move.l	d4,d6
	sub.l	d0,haldco
	bsr	contro1
	bsr	cacdec
	move.l	d4,d5
	sub.l	d4,d6
	add.l	d6,decaco
	bra	sava
indro2: move.w	#VCSUP,d7
	sub.b	vaco(pc),d7
	ext.l	d0
	asl.l	d7,d0
	bsr	cdepet
	move.l	d4,d6
	sub.l	d0,haldco
	bsr	contro1
	bsr	cacdec
	move.l	d4,d5
	sub.l	d6,d4
	add.l	d4,decaco
	bra.s	sava
corr1:	dc.b	0,1,-1,0

inclco: move.w	(a0),d1 
	lsr.w	#2,d1
	and.w	#$3,d1
	move.w	d0,d4
	tst.b	evnmo
	beq.s	stabl
	bgt.s	inhau1
	neg.w	d4
inhau1: move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
	asl.w	d7,d4
	ext.l	d4
	add.l	d4,d3
stabl:	
	move.b	(a0),vamo
	move.b	corr(pc,d1.w),evnmo
	beq.s	sava
	bgt.s	inhau2
	neg.w	d0
inhau2: move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
	asl.w	d7,d0
	ext.l	d0
	sub.l	d0,d3
	bra.s	sava
corr:	dc.b	0,1,-1,0
sava:	addq.l	#8,a0
	move.l	a0,FEVTAD
	bra.L	avaevt

cacinc: move.l	haldco(pc),d4
	and.w	#$ffc0,d4
	asr.l	#4,d4
	move.l	#JLLEQU+2050+8000,a4
	lea.l	0(a4,d4.w),a4
	move.w	32(a4),d4
	add.w	32-4(a4),d4
	add.w	32-8(a4),d4
	add.w	32-12(a4),d4
	add.w	32-16(a4),d4
	add.w	32+4(a4),d4
	add.w	32+8(a4),d4
	add.w	32+12(a4),d4
	sub.w	-32(a4),d4
	sub.w	-32-4(a4),d4
	sub.w	-32-8(a4),d4
	sub.w	-32-12(a4),d4
	sub.w	-32-16(a4),d4
	sub.w	-32+4(a4),d4
	sub.w	-32+8(a4),d4
	sub.w	-32+12(a4),d4
	asr.w	#3,d4
	move.w	d4,inild
	rts
cdepet: lea.l	vetdec(pc),a4
	clr.w	d4
	move.b	vaco(pc),d4
	lsl.w	#1,d4
	move.w	0(a4,d4.w),-4(a4)
cacdec: move.l	haldco(pc),d4
	and.w	#$ffc0,d4
	asr.l	#4,d4
	move.l	#JLLEQU+2050+8000,a4
	move.w	0(a4,d4.w),d4
	ext.l	d4
etdec:	nop
	rts
vetdec: asr.w	#5,d4
	asr.w	#4,d4
	asr.w	#3,d4
	asr.w	#2,d4
	asr.w	#1,d4
	nop
	add.w	d4,d4
	asl.l	#2,d4
contro1:
	move.l	haldco(pc),d5
	cmp.l	#CINSUP,d5
	ble.s	degmax2
	move.l	#CINSUP,haldco
	rts
degmax2: cmp.l	 #-CINSUP,d5
	bge.s	fdeg2
	move.l	#-CINSUP,haldco
fdeg2:	rts
fava:
;trt ecras
	move.w	rafec(pc),d2
	bge.s	ecrap
	neg.w	d2
ecrap:	asr.w	#2,d2
	add.w	#MAXECR,d2
	move.w	d2,d7
	neg.w	d7
	move.w	d3,d0
	add.w	rafec(pc),d0
	move.w	d0,d4
	move.w	dafec(pc),d1
	sub.w	d1,d0
	blt.s	ecra1
	cmp.w	d2,d0
	bgt.s	ecra2
	add.w	d0,d1
	bra.s	ecra3
ecra2:	add.w	d2,d1
	bra.s	ecra3
ecra1:	cmp.w	d7,d0
	blt.s	ecra4
	add.w	d0,d1
	bra.s	ecra3
ecra4:	add.w	d7,d1
ecra3:	move.w	d1,dafec
	sub.w	d1,d4
	move.w	d4,rafec
	
	ext.l	d3
	add.l	degre(pc),d3
	move.l	d3,degre


	move.l	Y1(pc),d7
	move.w	F1DEP(pc),d2   
	lea.l	CARSRT,a0
	lea.l	OCCUR(pc),a1
	add.l	F1SRT(pc),a0
	lea.l	zafvo(pc),a4
	move.l	a4,adgam+8
safvo1: move.w	-(a0),d0
	bge.s	pchtv
	lea.l	34(a0),a0
	sub.l	CRCLAP(pc),d7
brpvo:	move.w	-(a0),d0
	blt.s	brpvo
pchtv:	move.l	a1,a2
	add.w	d0,a2
	move.w	(a2)+,d0
	move.l	(a2),d1
	move.w	6(a2),d3
	sub.l	d7,d1
	cmp.l	#32767,d1
	blt.s	safvo
	move.w	d0,(a4)+
	move.w	#32767,(a4)
	bra.s	fafvoi
safvo:	move.l	a4,a3
	clr.w	d4
bafvo:	cmp.w	-4(a3),d1
	bge.s	safvo2
	addq.w	#1,d4
	lea.l	-6(a3),a3
	bra.s	bafvo
safvo2: subq.w	#1,d4
	blt.s	safvo3
	move.l	a4,a3
bafvo2: subq.w	#6,a3
	move.l	(a3),6(a3)
	move.w	4(a3),10(a3)
	dbf	d4,bafvo2
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d3,(a3)
	lea.l	6(a4),a4
	bra.s	safvo4
safvo3: move.w	d0,(a4)+
	move.w	d1,(a4)+
	move.w	d3,(a4)+
safvo4: cmp.w	#2000,d1
	bgt.s	safvo1
	add.w	#$100,d0
	move.w	d0,(a4)+
	add.w	#100,d1
	move.w	d1,(a4)+
;	 sub.w	 #28,d3
	move.w	d3,(a4)+
	bra	safvo1
fafvoi:
	lea.l	esevt1(pc),a0
	move.l	deevt1(pc),d0
	move.w	#6,d1
bpoba:	sub.w	d2,2(a0,d0.w)
	addq.w	#4,d0
	and.w	#$3f,d0
	sub.w	d2,2(a0,d0.w)
	addq.w	#4,d0
	and.w	#$3f,d0
	dbf	d1,bpoba
roba:	move.l	deevt1(pc),d0
	move.w	0(a0,d0.w),d1
	swap	d1
	move.w	2(a0,d0.w),d1
	bgt.s	fpoba
	add.w	#7000,d1
	clr.w	inico
	cmp.w	#3,0(a0,d0.w)
	beq.s	bldeb
	move.w	#2,inico
bldeb:	move.l	#$7fff,0(a0,d0.w)
	subq.w	#4,d0
	and.w	#$3f,d0
	move.l	#$71b59,0(a0,d0.w)
	subq.w	#4,d0
	and.w	#$3f,d0
	move.l	d1,0(a0,d0.w)
	move.w	deevt1+2(pc),d0
	addq.w	#4,d0
	and.w	#$3f,d0
	move.w	d0,deevt1+2
	bra.s	roba
fpoba:
	move.l	deevt1(pc),adgam+4
	move.l	FEVTAD(pc),adgam
	moveq	#0,d7
	lea.l	adgam(pc),a1
	move.l	20(a1),a0
	add.w	6(a1),a0
	move.w	2(a0),d7
	move.l	(a1),a0
	cmp.w	#-1,(a0)
	bne.s	pchto1
	move.l	#CRCEVT,a0
	move.l	a0,(a1)
	move.l	CRCLAP(pc),d0
	sub.l	d0,posvoit
pchto1:
	move.l	2(a0),d0
	sub.l	posvoit(pc),d0
	cmp.l	d0,d7
	bgt.s	gam13b
	move.l	8(a1),a0
	cmp.w	2(a0),d7
	bgt.s	gam3b
	move.w	d7,evt
	move.w	#4,tevt
	bra.s	frevt
gam3b:	move.w	2(a0),evt
	move.w	#8,tevt
	bra.s	frevt
gam13b: move.l	d0,d7
	move.l	8(a1),a0
	move.w	2(a0),d0
	ext.l	d0
	cmp.l	d0,d7
	bgt.s	gam3b
	move.w	d7,evt
	clr.w	tevt
frevt:

	move.w	inico(pc),colban
;	clr.l	decaco
	tst.w	MGAME+2
	bne.s	trang
	move.w	XB(pc),d0	 ;Middle of Road
	cmp.w	#256*6,d0
	ble.s	suibo
	move.w	#256*6,d0
	move.w	d0,XB
	bra.s	finbo
suibo:	cmp.w	#-768*2,d0
	bge.s	finbo
	move.w	#-768*2,d0
	move.w	d0,XB
finbo:	
	ext.l	d0
	clr.l	haldco
	clr.w	inild
	bra.s	fang
trang:	move.l	decaco(pc),d0
	cmp.l	#256*24,d0
	ble.s	suibo1
	move.l	#256*24,d0
	move.l	d0,decaco
	bra.s	finbo1
suibo1: cmp.l	#-3072*2,d0
	bge.s	finbo1
	move.l	#-3072*2,d0
	move.l	d0,decaco
finbo1: 
	 asr.l	 #1,d0
	move.w	d0,d1
	asr.w	#1,d1
	move.w	d1,XB
fang:
****
	tst.w	typtrt	;a virer
	beq.s	trttrt
	rts
trttrt: move.w	#HAUTEUR,d3
	move.l	#JLLEQU+2050+8000,a4
	move.l	#$ffff,-8004(a4)
	move.l	#zafevt,a5
	MOVE.L	A5,USP		;MA6
	MOVE.W	#DEMAR,A5
	move.l	#JLLEQU,a3

	clr.l	rupmd
	clr.l	tevco1
	clr.l	hald
	clr.l	pdeld
	clr.w	sdem
	clr.l	sdec
********************
tjump1: tst.w	JUMPE+2
	blt	pajump
	bgt.s	jumpco		
	clr.w	crasco 
	move.w	JUMPE+4,D1
	cmp.w	#400,d1
	ble.s	saupo
	move.w	#400,d1
saupo:	move.w	d1,CRASHE+4
	move.w	#1,JUMPE+2
	move.w	d1,valhau
	move.w	d1,saucra
	move.w	#HAUTEUR,hautco
jumpco: cmp.w	#2,JUMPE+2	  
	bgt.L	tjump
	beq.s	djump
pjump:	move.w	CRASHE+4(pc),d1
	bgt.s	epjump
	move.w	crasco(pc),d1
	ext.l	d1
	move.w	valhau(pc),d4
	ext.l	d4
tyty:	divs	#20,d4
	divs	d4,d1
	move.w	d1,CRASHE+4
	move.w	#2,JUMPE+2
djump:	move.w	CRASHE+4(pc),d1
	sub.w	d1,crasco
	bra.s	pdjump
epjump: 
	asr.w	#2,d1
	muls	d1,d1
	sub.w	d1,crasco
	sub.w	#80,CRASHE+4
pdjump: 
	move.w	crasco(pc),hapl
	move.w	valhau(pc),d1
	ext.l	d1
	asr.w	#3,d1
	move.w	d1,d3
	asr.w	#1,d3
	add.w	d3,d1
	asr.w	#1,d1	
spdjs:	sub.w	#48,valhau   ; nb fois hauteur
	sub.w	d1,hautco
	move.w	hautco(pc),d3
	cmp.w	#HAUTEUR,d3
	bge.s	ssjmp
	bra	pavbi
ssjmp:
	move.w	#3,JUMPE+2
	move.w	JUMPE+4,d1
	cmp.w	#350,d1
	blt.s	sssjmp
	move.w	#4,JUMPE+4
sssjmp:
	move.w	#1,CRASHE+2
	clr.w	CRASHE+4
	bra	scrash
tjump:	
	move.w	#-1,JUMPE+2
	bra	craco
pajump: tst.w	CRASHE+2
	blt.L	pacras
	bgt.s	craco
	move.w	#1,CRASHE+2
	clr.w	crasco
	move.w	CRASHE+4(pc),d1
	cmp.w	#340,d1
	ble.s	bvj
	move.w	#340,d1
bvj:	move.w	d1,CRASHE+4
	move.w	d1,saucra
	bra.s	scrash
craco:	cmp.w	#1,CRASHE+2
	bgt.s	encscr
	sub.w	#60,CRASHE+4 
scrash: move.w	CRASHE+4(pc),d1
	asr.w	#2,d1
	bge.s	crapo
	muls	d1,d1
	neg.w	d1
	bra.s	cracco
crapo:	muls	d1,d1
cracco: move.w	d1,d4
	asr.w	#2,d4
	sub.w	d4,d1
	add.w	d1,crasco
	move.w	crasco(pc),d1
	asr.w	#8,d1
	asr.w	#1,d1
	sub.w	d1,d3
	move.w	crasco(pc),hapl
	ble.s	sscra
	bra	pavbi
sscra:	move.w	#HAUTEUR,d3
	move.w	#2,CRASHE+2
	moveq	#0,d1
	move.w	saucra(pc),d1
	divu	#6,d1
	move.w	d1,CRASHE+4
	clr.w	crasco
	clr.w	hapl
	bra	pavbi
encscr: subq.w	#8,CRASHE+4
	move.w	CRASHE+4(pc),d1
	bge.s	crapo1
	muls	d1,d1
	neg.w	d1
	bra.s	cracc1
crapo1: muls	d1,d1
cracc1: 
	add.w	d1,crasco
	move.w	crasco(pc),d1
	ble.s	pchha
	asr.w	#8,d1
	asr.w	#1,d1
	sub.w	d1,d3
pchha:	move.w	crasco(pc),hapl
	cmp.w	#-200,hapl
	bgt.s	pavbi
	move.w	#-1,CRASHE+2
	move.w	#-200,hapl
pavbi:
	move.w	#HAUTEUR,d5
	sub.w	d3,d5
	asr.w	#1,d5
	move.w	#20,d4
	sub.w	d5,d4
	cmp.w	#24,d4
	ble.s	rho
	move.w	#24,d4
	bra.s	rbo
rho:	cmp.w	#16,d4
	bge.s	rbo
	move.w	#16,d4
rbo:	move.w	d4,d5
	bra	pavib	
pacras: move.w	vitco(pc),d1
	sub.w	F1DEP(pc),d1
	move.w	F1DEP(pc),vitco
	move.w	d1,d5
	sub.w	haplco(pc),d5
	blt.s	extim
	cmp.w	#5,d5
	ble.s	telqu
	addq.w	#5,haplco
	bra.s	fafhap
extim:	cmp.w	#-5,d5
	bge.s	telqu
	subq.w	#5,haplco
	bra.s	fafhap
telqu:	move.w	d1,haplco
fafhap: move.w	haplco(pc),d1
;	ble.s	pviec
	move.w	d1,d5
	asr.w	#2,d5
;	add.w	d1,d5
;	bge.s	bbb
;	neg.w	d5
;	asr.w	#1,d5
bbb:	move.w	rafec(pc),d4
	asr.w	#7,d4
	add.w	d4,d3
	add.w	d5,d3
	move.w	#HAUTEUR,d5
	sub.w	d3,d5
	asr.w	#1,d5
	move.w	#20,d4
	sub.w	d5,d4
	cmp.w	#25,d4
	ble.s	rhok
	move.w	#25,d4
	bra.s	rbok
rhok:	cmp.w	#14,d4
	bge.s	rbok
	move.w	#14,d4
rbok:	asl.w	#6,d1
	move.w	d1,d5
	asr.w	#1,d5
	add.w	d5,d1
	add.w	rafec(pc),d1
	move.w	d1,hapl

facc:	move.w	d4,d5
	move.w	topvib(pc),d1
	beq.s	pavib
	cmp.w	#50,F1DEP
	ble.s	pavib
	subq.w	#1,d1
	or.w	topvib-2(pc),d1
	add.w	d1,d1
	lea.l	teor1(pc),a1
	move.w	0(a1,d1.w),d7
	eor.w	d7,vigch
	add.w	d1,d1
	lea.l	16(a1),a1
	add.w	d1,a1
	move.b	vigch(pc),d1
	move.b	0(a1,d1.w),d7
	ext.w	d7
	add.w	d7,d4
	move.b	vidrt(pc),d1
	move.b	2(a1,d1.w),d7
	ext.w	d7
	add.w	d7,d5
	
	eor.w	#$ffff,vibco
	beq.s	pavib
	move.w	#-150,d1
	mulu	topvib(pc),d1
	sub.w	#50,d1
	add.w	d1,hapl
pavib:	move.w	d4,HAUT
	move.w	d5,HAUT+2
	move.w	hapl(pc),d1
	cmp.w	#MINSUP,d1
	ble.s	stdegr
	move.w	#MINSUP,d1
	move.w	d1,hapl
	bra.s	ftde
stdegr: cmp.w	#-MINSUP,d1
	bge.s	ftde
	move.w	#-MINSUP,d1
	move.w	d1,hapl
ftde:
	move.w	d1,sdem
	move.l	degre(pc),d4
	neg.l	d4
	ext.l	d1
	add.l	d1,d4
	cmp.l	#MINSUP,d4
	ble.s	stdeg1
	move.w	#MINSUP,d4
	bra.s	ftde1
stdeg1: cmp.l	#-MINSUP,d4
	bge.s	ftde1
	move.w	#-MINSUP,d4
ftde1:
	and.w	#$fff0,d4
	asr.w	#2,d4
	bsr	rt_pmd
	move.w	1016(a3),d4
	muls	d7,d4
	asr.l	#DECPL,d4
	add.w	d3,d4
	muls	1018(a3),d4
	swap	d4
	neg.w	d4
	muls	#160,d4
	add.l	#21600,d4
	move.l	d4,adscrol

	move.w	d3,htprl
*******************
	clr.w	d2
	move.w	#1,evtrup
	tst.b	evnmo
	bgt.L	montee
	blt.s	descen
	move.w	#$7fff,evtrup+2
	move.w	hapl(pc),d4
	and.w	#$fff0,d4
	asr.w	#2,d4
	bsr	rt_pmd
	move.w	d7,d1
	lea.l	plat0(pc),a1
	bra.L	tinvir
;iii:	dc.l	0
descen: 
	MOVE.W	sdem(PC),d1
	move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
; rupt
	move.l	#MINSUP,d4
	add.w	d1,d4
	lsr.w	d7,d4
	cmp.l	#$7fff,d4
	ble.s	rudeo
	move.w	#$7fff,d4
rudeo:	move.w	d4,evtrup+2
	asr.w	d7,d1
	move.b	vamo(pc),d2
	move.b	d2,vcohb
	bsr	rt_md
	add.w	d7,d3
	move.w	#$20,tevco1
	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetd1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),18(a1)
	lea.l	desc1(pc),a1
	bra.s	tinvir
montee: 
	MOVE.W	sdem(PC),d1
	move.w	#VMSUP,d7
	sub.b	vamo(pc),d7
; rupt
	move.l	#MINSUP,d4
	sub.w	d1,d4
	lsr.w	d7,d4
	cmp.l	#$7fff,d4
	ble.s	rumoo
	move.w	#$7fff,d4
rumoo:	move.w	d4,evtrup+2
	asr.w	d7,d1
	move.b	vamo(pc),d2
	move.b	d2,vcohb
	bsr	rt_md
	sub.w	d7,d3
	move.w	#$10,tevco1
	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetm1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),16(a1)
	lea.l	mont1(pc),a1
tinvir: clr.w	adgam+14
	tst.b	evnco
	bgt.s	drote
	blt.L	gauch
	move.w	#$7fff,evtrup+6
	lea.l	droit1(pc),a2
	move.l	haldco(pc),sdec
	move.w	inild(pc),d5
	move.w	#254,d2
	MOVE.L	#RODEQU,a0
	bra	contevt
;	jmp	(a1)
drote:	move.w	#$10,tevco2
	move.b	vaco(pc),d2
	move.b	d2,vcodg
	move.l	haldco(pc),d5
; rupt
	move.w	#VCSUP,d6
	sub.b	d2,d6
	move.l	#CINSUP,d4
	sub.l	d5,d4
	asr.l	d6,d4
	cmp.l	#$7fff,d4
	ble.s	ruco1
	move.w	#$7fff,d4
ruco1:	move.w	d4,evtrup+6
	cmp.w	evtrup+2(pc),d4
	bge.s	fruco1
	move.w	#4,adgam+14
fruco1:
	asr.l	d6,d5
	bsr	rt_dg
	sub.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecd1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),18(a2)
	lea.l	vird1(pc),a2
	move.w	#254,d2
	MOVE.L	#RODEQU,a0
	bra	contevt
;	jmp	(a1)
gauch:	move.w	#$20,tevco2
	move.b	vaco(pc),d2
	move.b	d2,vcodg
	move.l	haldco(pc),d5
; rupt
	move.w	#VCSUP,d6
	sub.b	d2,d6
	move.l	#CINSUP,d4
	add.l	d5,d4
	asr.l	d6,d4
	cmp.l	#$7fff,d4
	ble.s	ruco2
	move.w	#$7fff,d4
ruco2:	move.w	d4,evtrup+6
	cmp.w	evtrup+2(pc),d4
	bge.s	fruco2
	move.w	#4,adgam+14
fruco2:
	asr.l	d6,d5
	bsr	rt_dg
	add.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecg1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),20(a2)
	lea.l	virg1(pc),a2
	move.w	#254,d2
	MOVE.L	#RODEQU,a0
	bra	contevt
;	jmp	(a1)
	bra.l	omont1
mont2:	subq.w	#1,-8002(a4)
	ble.s	mont1
	addq.w	#4,a3
	dbf	d2,smont2
	bra	ffrou
smont2: move.w	evt(pc),d7
	cmp.w	(a3),d7
	bge.s	mont2
	bra	strevt
	bra.l	omont1
mont1:	move.w	(a3)+,d4
	sub.w	rupmd(pc),d4
	add.w	d1,d4
	move.w	d4,d7
	and.w	#$ffff,d7
eetm1:	sub.w	d7,d4
	asr.w	#4,d7
	muls	2(a4,d7.w),d4
	asr.w	#4,d4
eetm2:	add.w	0(a4,d7.w),d4
	asl.w	#4,d4
	add.w	d3,d4
	muls	(a3)+,d4
	swap	d4
	sub.w	a5,d4
	bgt.s	oklim
	move.w	d4,-8006(a4)
	lea.l	mont1(pc),a1
	dbf	d2,contevt
	bra	ffrou
oklim:	move.w	-8004(a4),d7
	move.w	d2,-8004(a4)
	sub.w	d2,d7
	asr.w	#1,d7
;	 addq.w	#1,d7
	move.w	d7,-8002(a4)
	lea.l	mont2(pc),a1
	jmp	(a2)
	bra.l	odes1
desc2:	subq.w	#1,-8002(a4)
	ble.s	desc1
	addq.w	#4,a3
	dbf	d2,sdesc2
	bra	ffrou
sdesc2: move.w	evt(pc),d7
	cmp.w	(a3),d7
	bge.s	desc2
	bra	strevt
	bra.l	odes1
desc1:	move.w	rupmd(pc),d4
	sub.w	(a3)+,d4
trude:	add.w	d1,d4
	move.w	d4,d7
	and.w	#$ffff,d7
eetd1:	sub.w	d7,d4
	asr.w	#4,d7
	muls	2(a4,d7.w),d4
	asr.w	#4,d4
eetd2:	add.w	0(a4,d7.w),d4
	neg.w	d4
	asl.w	#4,d4
	add.w	d3,d4
erude:	muls	(a3)+,d4
	swap	d4
	sub.w	a5,d4
	bgt.s	oklid
	move.w	d4,-8006(a4)
	lea.l	desc1(pc),a1
	dbf	d2,contevt
	bra	ffrou
oklid:	move.w	-8004(a4),d7
	move.w	d2,-8004(a4)
	sub.w	d2,d7
	subq.w	#1,d7
	move.w	d7,-8002(a4)
	lea.l	desc2(pc),a1
	jmp	(a2)
	bra.l	odrt1
plat2:	subq.w	#2,-8002(a4)
	ble.s	plat1
	addq.w	#4,a3
	dbf	d2,splat2
	bra	ffrou
splat2: move.w	evt(pc),d7
	cmp.w	(a3),d7
	bge.s	plat2
	bra	strevt
	bra.l	odrt1
plat1:	move.w	(a3)+,d4
	sub.w	pdepl(pc),d4
	muls	d1,d4
	asr.l	#DECPL,d4
	add.w	d3,d4
	muls	(a3)+,d4
	swap	d4
	sub.w	a5,d4
	bgt.s	oklip
	move.w	d4,-8006(a4)
	lea.l	plat1(pc),a1
	dbf	d2,contevt
	bra	ffrou
oklip:	move.w	-8004(a4),d7
	move.w	d2,-8004(a4)
	sub.w	d2,d7
	add.w	d7,d7
	subq.w	#1,d7
	add.w	d7,-8002(a4)
	lea.l	plat2(pc),a1
	jmp	(a2)
	bra.l	odrt1
plat0:	move.w	(a3)+,d4
	sub.w	pdepl(pc),d4
	muls	d1,d4
	asr.l	#DECPL,d4
	add.w	d3,d4
	muls	(a3)+,d4
	swap	d4
	sub.w	a5,d4
	bgt.s	oklip2
	dbf	d2,contevt
	bra	ffrou
oklip2: move.w	d2,-8004(a4)
	lea.l	plat1(pc),a1
	jmp	(a2)

	bra.l	odrot1
vird1:	move.w	-4(a3),d7
	sub.w	rupco(pc),d7
	ext.l	d7
	add.l	d5,d7
	move.l	d7,d6
	and.w	#$ffff,d6
eecd1:	sub.w	d6,d7
	asr.l	#4,d6
	muls	2(a4,d6.w),d7
	asr.w	#4,d7
eecd2:	add.w	0(a4,d6.w),d7
	ext.l	d7
	asl.l	#4,d7
	add.l	d0,d7
	blt.s	vdneg
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	subq.w	#1,d7
	blt.s	fvdr
svdr:	add.w	-2(a3),d6
;	 dbf	 d7,svdr
fvdr:	add.w	#160,d6
	bra.L	eclig
vdneg:	
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	neg.w	d7
	subq.w	#1,d7
	sub.w	-2(a3),d6
	dbf	d7,snvdr
	add.w	#160,d6
	bra.l	eclig
snvdr:	sub.w	-2(a3),d6
	add.w	#160,d6
	bra	eclig
	bra.l	ogch1
virg1:	move.w	rupco(pc),d7
	sub.w	-4(a3),d7
	ext.l	d7
	add.l	d5,d7
	move.l	d7,d6
	and.w	#$ffff,d6
eecg1:	sub.w	d6,d7
	asr.l	#4,d6
	muls	2(a4,d6.w),d7
	asr.w	#4,d7
eecg2:	add.w	0(a4,d6.w),d7
	neg.w	d7
	ext.l	d7
	asl.l	#4,d7
	add.l	d0,d7
	blt.s	vgneg
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	subq.w	#1,d7
	blt.s	fvgr
svgr:	add.w	-2(a3),d6
;	 dbf	 d7,svgr
fvgr:	add.w	#160,d6
	bra.L	eclig
vgneg:	
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	neg.w	d7
	subq.w	#1,d7
	sub.w	-2(a3),d6
	dbf	d7,snvgr
	add.w	#160,d6
	bra.l	eclig
snvgr:	sub.w	-2(a3),d6
	add.w	#160,d6
	bra.s	eclig
	bra.l	odrit
droit1: move.w	-4(a3),d7
	sub.w	pdeld(pc),d7
	muls	d5,d7
	asr.l	#DECPL,d7
	add.l	d0,d7
	blt.s	vneg
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	subq.w	#1,d7
	blt.s	fvr
svr:	add.w	-2(a3),d6
;	 dbf	 d7,svr
fvr:	add.w	#160,d6
	bra.s	eclig
vneg:	
;	asl.l	#1,d7
	move.w	d7,d6
	mulu	-2(a3),d6
	swap	d6
	swap	d7
	neg.w	d7
	subq.w	#1,d7
	sub.w	-2(a3),d6
	dbf	d7,snvr
	add.w	#160,d6
	bra.l	eclig
snvr:	sub.w	-2(a3),d6
	add.w	#160,d6
eclig:	subq.w	#1,d4
	ble.L	ecligb
	cmp.w	#DEMAR,a5
	bne.s	pdemar
	add.w	d4,a5
	mulu	#10,d4
	move.w	d4,-8008(a4)
	add.w	d4,a0
	bra	ecligb
pdemar: cmp.w	#DEMAR+140,a5
	bge	ffrou
	addq.w	#1,d4
	add.w	d4,a5
	swap	d1
	move.w	-6(a0),d7
	sub.w	-10(a0),d7
	subq.w	#6,d7
	cmp.w	d2,d7
	ble.s	prolin
	move.l	a1,-(a7)
	lea.l	eclig(pc),a1
	move.w	#$4e75,(a1)
	subq.w	#4,a3
	swap	d3
	move.w	d6,d3
	jsr	(a2)
	move.w	#$5344,(a1)
	move.l	(a7)+,a1
	addq.w	#4,a3
	moveq	#0,d7
	move.w	d6,d7
	move.w	d3,d6
	sub.w	d7,d6
	ext.l	d6
	asl.l	#7,d6
	swap	d7
	move.w	-8006(a4),d3
	neg.w	d3
	move.w	d3,d1
	add.w	d4,d3
	divs	d3,d6
	swap	d3
	swap	d6
	clr.w	d6
	asr.l	#7,d6
	bra.s	plicac
licac:	add.l	d6,d7
plicac: dbf	d1,licac
	bra.s	caccom
prolin: 
	moveq	#0,d7
	move.w	-10(a0),d7
	sub.w	d7,d6
	ext.l	d6
	asl.l	#7,d6
	swap	d7
	divs	d4,d6
	swap	d6
	clr.w	d6
	asr.l	#7,d6
caccom: subq.w	#1,d4
	move.w	d2,d1
	lsr.w	#3,d1
	addq.w	#1,d2
	addq.w	#1,d1
beclig: add.l	d6,d7
	swap	d7
	move.w	d7,(a0)+
	move.w	d7,(a0)
	sub.w	d2,(a0)+
	move.w	d7,(a0)
	add.w	d2,(a0)+
	move.w	d1,(a0)+
etrou1: 
	move.w	colban(pc),(a0)+
;	 BSR	 MODROU
	swap	d7
	dbf	d4,beclig
	swap	d1
	subq.w	#1,d2
	dbf	d2,contevt
	bra.s	ffrou

ecligb: addq.w	#1,a5
	move.w	d2,d7
	lsr.w	#3,d7
	addq.w	#1,d7
	addq.w	#1,d2
	move.w	d6,(a0)+
	move.w	d6,(a0)
	sub.w	d2,(a0)+
	add.w	d2,d6
	move.w	d6,(a0)+
	move.w	d7,(a0)+
etrou2: 
	move.w	colban(pc),(a0)+
;	 BSR	 MODROU
feclig: subq.w	#1,d2
	dbf	d2,contevt
ffrou:	move.b	#-1,9(a0)
;calcul de adsky
	move.l	a0,d0
	sub.l	#RODEQU,d0
	lsl.w	#4,d0
	move.l	#32000,d1
	sub.l	d0,d1
	cmp.l	adscrol(pc),d1
	ble.s	pmosky
	move.l	adscrol(pc),d1
pmosky: move.l	d1,adsky

	move.w	-8008(a4),d3
	beq.s	demnor
	lsr.w	#4,d0
	sub.w	#10,d0
	move.w	d3,d1
	move.w	d3,d2
	add.w	d1,d1
	sub.w	d0,d1
	ble.s	nblisu
	sub.w	d1,d2
	bgt.s	nblisu
	clr.w	d0
	bra.s	nblis1
nblisu: move.w	d2,d0
	add.w	#10,d0
nblis1: move.l	#RODEQU,a0
	clr.w	-8008(a4)
	add.w	d3,a0
	lea.l	-10(a0),a0
bfrou:	move.w	10(a0),d1
	add.w	0(a0,d2.w),d1
	sub.w	0(a0,d0.w),d1
	move.w	d1,(a0)+
	move.w	10(a0),d1
	add.w	0(a0,d2.w),d1
	sub.w	0(a0,d0.w),d1
	move.w	d1,(a0)+
	move.w	10(a0),d1
	add.w	0(a0,d2.w),d1
	sub.w	0(a0,d0.w),d1
	move.w	d1,(a0)+
	move.w	10(a0),d1
	add.w	0(a0,d2.w),d1
	sub.w	0(a0,d0.w),d1
	move.w	d1,(a0)+
	move.w	10(a0),(a0)
	lea.l	-18(a0),a0
	sub.w	#10,d3
	bgt.s	bfrou
demnor: MOVE.L	#RODEQU,A0
	moveq	#0,d0
	cmp.w	#78,2(a0)
	blt.s	tdrr
	cmp.w	#78+32+17,2(a0)
	blt.s	tbande
	cmp.w	#242-17,2(a0)
	blt.s	verd1
	cmp.w	#242+32,2(a0)
	blt.s	tband1
verd2:	bset	#2,d0
	bra.s	pvibry
tdrr:	moveq	#4,d0
	swap	d0
	cmp.w	#242,4(a0)
	bgt.s	pvibry
	cmp.w	#242-32-17,4(a0)
	bgt.s	tbande
	cmp.w	#78+17,4(a0)
	bgt.s	verd1
	cmp.w	#78-32,4(a0)
	bgt.s	tband1
	bra.s	verd2
tbande: bset	#1,d0
	bra.s	pvibry
tband1: move.w	#3,d0
	bra.s	pvibry
verd1:	bset	#0,d0
pvibry: move.l	d0,topvib-2
	move.b	#-1,1320+9(A0)
	RTS
colban: dc.w	0
MODROU: move.w	colban(pc),(a0)+
	movem.l d5/a5,-(sp)
	move.w	comodr(pc),d5
	jmp	tmodr(pc,d5.w)
tmodr:	bra.l	vo3co
	bra.l	chico
	bra.l	chiou
	bra.l	vo3ou
	bra.l	vo3co
	bra.l	vo3co
	bra.l	chife
	bra.l	vo3fe
	bra.l	garco
	bra.l	garco
	bra.l	garco
	bra.l	garou
	bra.l	garco
	bra.l	garco
	bra.l	garco
	bra.l	garfe
inclin: move.w	(a0),d2
	and.w	#$000c,d2
	or.w	tevco1(pc),d2
	jmp	ancnou(pc,d2.w)
ancnou: 
	bra.l	procevt1
	bra.l	plamon
	bra.l	plades
	bra.l	procevt1

	bra.l	monpla
	bra.l	monmon
	bra.l	mondes
	bra.l	procevt1

	bra.l	despla
	bra.l	desmon
	bra.l	desdes
	bra.l	sommet
monmon: sub.w	rupmd(pc),d7
	add.w	d7,d1
	move.b	vcohb(pc),d2
	bsr	rt_md
	add.w	d7,d3
	move.w	#VMSUP,d7
	sub.b	d2,d7
	asl.w	d7,d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
; rupt
	move.w	#MINSUP,d4
	sub.w	d1,d4
	bsr	rumond
	asr.w	d7,d1
	bsr	rt_md
	sub.w	d7,d3
	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetm1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),16(a1)
	move.w	evt(pc),rupmd
	clr.w	-8004(a4)
	lea.l	mont1(pc),a1
	bra	procevt1
desdes: sub.w	rupmd(pc),d7
	sub.w	d7,d1
	move.b	vcohb(pc),d2
	bsr	rt_md
	sub.w	d7,d3
	move.w	#VMSUP,d7
	sub.b	d2,d7
	asl.w	d7,d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
	move.w	d1,-(a7)
	move.w	d7,-(a7)
	asr.w	d7,d1
	bsr	rt_md
	add.w	d7,d3
; rupt
	move.w	(a7)+,d7
	move.w	d1,d6
	ext.l	d6
	add.l	evt-2(pc),d6
	move.w	d3,d4
	bge.s	moi1
	neg.w	d4
	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi1
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#16000,d4
	bgt.s	pmoi1
	neg.w	d4
	bra.s	cmoi1
moi1:	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi1
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#19000,d4
	bgt.s	pmoi1
cmoi1:	cmp.w	(a7),d4
	bgt.s	pmoi1
	move.w	d4,-8010(a4)
	sub.w	(a7)+,d4
	neg.w	d4
	bsr	rudes2
	bra.s	smoi1
pmoi1:	move.w	#MINSUP,d4
	add.w	(a7)+,d4
	bsr	rumond
smoi1:	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetd1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),18(a1)
	move.w	evt(pc),rupmd
	move.l	#$ffff,-8004(a4)
	lea.l	desc1(pc),a1
	bra	procevt1
sommet: 
	lea.l	-9026(a4),a0
	moveq	#0,d6
	move.w	(a0)+,d6
	move.w	d6,d4
	add.w	(a3),d6
	swap	d6
	lsr.l	#1,d6
	add.w	d7,d4
	divu	d4,d6
	sub.w	#32768,d6
	move.w	#254,d4
	sub.w	2(a7),d4
	add.w	d4,d4
	mulu	0(a0,d4.w),d6
	swap	d6
	add.w	2(a3),d6
	lea.l	contevt(pc),a0
	move.w	#$4e75,(a0)
	lea.l	ffrou(pc),a0
	move.w	#$4e75,(a0)
	movem.l (a7)+,a0/d2
	move.l	(a3),-(a7)
	move.w	d7,(a3)
	move.w	d6,2(a3)
	bsr	desc1
	move.l	(a7)+,-(a3)
	addq.w	#1,d2
	movem.l a0/d2,-(a7)
	lea.l	contevt(pc),a0
	move.w	#$3e3a,(a0)
	lea.l	ffrou(pc),a0
	move.w	#$117c,(a0)

	move.w	#VMSUP,d7
	clr.w	d2
	move.b	vcohb(pc),d2
	sub.b	d2,d7
	move.w	#MINSUP,d4
	add.w	-8010(a4),d4
	bsr	rumond
	bra	procevt1
rumond:
	lsr.w	d7,d4
	and.l	#$ffff,d4
	add.l	evt-2(pc),d4
	cmp.l	#$7fff,d4
	ble.s	rumo3
	move.w	#$7fff,d4
rumo3:	move.w	d4,evtrup+2
	move.w	#1,evtrup
	cmp.w	evtrup+6(pc),d4
	bge.s	srumo3
	clr.w	adgam+14
	rts
srumo3: move.w	#4,adgam+14
	rts
rudes2: 
	lsr.w	d7,d4
	ext.l	d4
	add.l	evt-2(pc),d4
	cmp.l	#$7fff,d4
	ble.s	rumo4
	move.w	#$7fff,d4
rumo4:	move.w	d4,evtrup+2
	move.w	#$d,evtrup
	cmp.w	evtrup+6(pc),d4
	bge.s	srumo4
	clr.w	adgam+14
	rts
srumo4: move.w	#4,adgam+14
	rts
plamon: move.w	d7,rupmd
	sub.w	pdepl(pc),d7
	muls	d1,d7
	asr.l	#DECPL,d7
	add.w	d7,d3
	move.w	sdem(pc),d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
; rupt
	move.w	#MINSUP,d4
	sub.w	d1,d4
	bsr	rumond
	asr.w	d7,d1
	bsr	rt_md
	sub.w	d7,d3
	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetm1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),16(a1)
	clr.w	-8004(a4)
	lea.l	mont1(pc),a1
	move.w	#$10,tevco1
procevt1:
	addq.l	#8,adgam
procevt:
	moveq	#0,d7
	move.l	figam+4(pc),a0
	add.w	adgam+6(pc),a0
	move.w	2(a0),d7
	move.l	adgam(pc),a0
	cmp.w	#-1,(a0)
	bne.s	pchto2
	move.l	#CRCEVT,a0
	move.l	a0,adgam
	move.l	CRCLAP(pc),d2
	sub.l	d2,posvoit
pchto2:
	move.l	2(a0),d2
	sub.l	posvoit(pc),d2
	cmp.l	d2,d7
	bgt.L	gam13
	move.l	adgam+8(pc),a0
	move.w	2(a0),d2
	cmp.w	d2,d7
	bgt.s	gam3
	lea.l	evtrup(pc),a0
	add.w	adgam+14(pc),a0
	cmp.w	2(a0),d7
	bgt.s	tevtrup
	move.w	d7,evt
	move.w	#4,tevt
	movem.l (a7)+,a0/d2
	bra	contevt
tevtrup:
	subq.l	#8,adgam
	move.w	2(a0),evt
	move.w	#12,tevt
	movem.l (a7)+,a0/d2
	bra	contevt
gam3:	lea.l	evtrup(pc),a0
	add.w	adgam+14(pc),a0
	cmp.w	2(a0),d2
	bgt.s	tevtrup
	move.w	d2,evt
	move.w	#8,tevt
	movem.l (a7)+,a0/d2
	bra	contevt
gam13:	move.l	d2,d7
	move.l	adgam+8(pc),a0
	move.w	2(a0),d2
	ext.l	d2
	cmp.l	d2,d7
	bgt.s	gam3
	lea.l	evtrup(pc),a0
	add.w	adgam+14(pc),a0
	cmp.w	2(a0),d7
	bgt.s	tevtrup
	move.w	d7,evt
	clr.w	tevt
	movem.l (a7)+,a0/d2
	bra	contevt
plades: move.w	d7,rupmd
	sub.w	pdepl(pc),d7
	muls	d1,d7
	asr.l	#DECPL,d7
	add.w	d7,d3
	move.w	sdem(pc),d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
	move.w	d1,-(a7)
	move.w	d7,-(a7)
	asr.w	d7,d1
	bsr	rt_md
	add.w	d7,d3
; rupt
	move.w	(a7)+,d7
	move.w	d1,d6
	ext.l	d6
	add.l	evt-2(pc),d6
	move.w	d3,d4
	bge.s	moi2
	neg.w	d4
	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi2
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#16000,d4
	bgt.s	pmoi2
	neg.w	d4
	bra.s	cmoi2
moi2:	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi2
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#19000,d4
	bgt.s	pmoi2
cmoi2:	cmp.w	(a7),d4
	bgt.s	pmoi2
	move.w	d4,-8010(a4)
	sub.w	(a7)+,d4
	neg.w	d4
	bsr	rudes2
	bra.s	smoi2
pmoi2:	move.w	#MINSUP,d4
	add.w	(a7)+,d4
	bsr	rumond
smoi2:	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetd1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),18(a1)
	move.l	#$ffff,-8004(a4)
	lea.l	desc1(pc),a1
	move.w	#$20,tevco1
	bra	procevt1
mondes: sub.w	rupmd(pc),d7
	add.w	d7,d1
	move.b	vcohb(pc),d2
	bsr	rt_md
	add.w	d7,d3
	move.w	#VMSUP,d7
	sub.b	d2,d7
	asl.w	d7,d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
	move.w	d1,-(a7)
	move.w	d7,-(a7)
	asr.w	d7,d1
	bsr	rt_md
	add.w	d7,d3
; rupt
	move.w	(a7)+,d7
	move.w	d1,d6
	ext.l	d6
	add.l	evt-2(pc),d6
	move.w	d3,d4
	bge.s	moi3
	neg.w	d4
	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi3
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#16000,d4
	bgt.s	pmoi3
	neg.w	d4
	bra.s	cmoi3
moi3:	ext.l	d4
	cmp.l	d6,d4
	bge.s	pmoi3
	mulu	#36000,d4
	divu	d6,d4
	cmp.w	#19000,d4
	bgt.s	pmoi3
cmoi3:	cmp.w	(a7),d4
	bgt.s	pmoi3
	move.w	d4,-8010(a4)
	sub.w	(a7)+,d4
	neg.w	d4
	bsr	rudes2
	bra.s	smoi3
pmoi3:	move.w	#MINSUP,d4
	add.w	(a7)+,d4
	bsr	rumond
smoi3:	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetd1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),18(a1)
	move.l	#$ffff,-8004(a4)
	lea.l	desc1(pc),a1
	move.w	evt(pc),rupmd
	move.w	#$20,tevco1
	bra	procevt1
desmon: sub.w	rupmd(pc),d7
	sub.w	d7,d1
	move.b	vcohb(pc),d2
	bsr	rt_md
	sub.w	d7,d3
	move.w	#VMSUP,d7
	sub.b	d2,d7
	asl.w	d7,d1
	move.b	(a0),d2
	move.b	d2,vcohb
	move.w	#VMSUP,d7
	sub.b	d2,d7
; rupt
	move.w	#MINSUP,d4
	sub.w	d1,d4
	bsr	rumond
	asr.w	d7,d1
	bsr	rt_md
	sub.w	d7,d3
	lsl.w	#3,d2
	lea.l	tasrl(pc),a0
	add.w	d2,a0
	lea.l	eetm1-2(pc),a1
	move.w	(a0)+,(a1)
	move.w	(a0)+,4(a1)
	move.w	(a0)+,10(a1)
	move.w	(a0),16(a1)
	clr.w	-8004(a4)
	lea.l	mont1(pc),a1
	move.w	evt(pc),rupmd
	move.w	#$10,tevco1
	bra	procevt1
monpla: move.b	vcohb(pc),d2
	move.w	d7,pdepl
	sub.w	rupmd(pc),d7
	add.w	d7,d1
	bsr	rt_md
	add.w	d7,d3
	bsr	rt_pmd
	move.w	#VMSUP,d6
	sub.w	d2,d6
	asl.w	d6,d1
	move.w	d1,sdem
	move.w	d7,d1
	move.l	#$ffff,-8004(a4)
	lea.l	plat0(pc),a1
	clr.w	tevco1
	move.w	#4,adgam+14
	move.w	#$7fff,evtrup+2
	bra	procevt1
despla: move.b	vcohb(pc),d2
	move.w	d7,pdepl
	sub.w	rupmd(pc),d7
	sub.w	d7,d1
	bsr	rt_md
	sub.w	d7,d3
	bsr	rt_pmd
	move.w	#VMSUP,d6
	sub.w	d2,d6
	asl.w	d6,d1
	move.w	d1,sdem
	move.w	d7,d1
	move.l	#$ffff,-8004(a4)
	lea.l	plat0(pc),a1
	clr.w	tevco1
	move.w	#4,adgam+14
	move.w	#$7fff,evtrup+2
	bra	procevt1
courbu: move.w	(a0),d2
	and.w	#$000c,d2
	or.w	tevco2(pc),d2
	jmp	ancno2(pc,d2.w)
ancno2: 
	bra.l	procevt1
	bra.l	pladrt
	bra.l	plagch
	bra.l	procevt1

	bra.l	drtpla
	bra.l	drtdrt
	bra.l	drtgch
	bra.l	procevt1

	bra.l	gchpla
	bra.l	gchdrt
	bra.l	gchgch
	bra.l	procevt1
drtdrt: sub.w	rupco(pc),d7
	ext.l	d7
	add.l	d7,d5
	move.b	vcodg(pc),d2
	bsr	rt_dg
	add.l	d7,d0
	move.w	#VCSUP,d7
	sub.b	d2,d7
	asl.l	d7,d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	sub.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	sub.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecd1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),18(a2)
	move.w	evt(pc),rupco
	lea.l	vird1(pc),a2
	bra	procevt1
rucond:
	asr.l	d7,d4
	add.l	evt-2(pc),d4
	cmp.l	#$7fff,d4
	ble.s	ruco3
	move.w	#$7fff,d4
ruco3:	move.w	d4,evtrup+6
	cmp.w	evtrup+2(pc),d4
	bge.s	sruco3
	move.w	#4,adgam+14
	rts
sruco3: clr.w	adgam+14
	rts
gchgch: sub.w	rupco(pc),d7
	ext.l	d7
	sub.l	d7,d5
	move.b	vcodg(pc),d2
	bsr	rt_dg
	sub.l	d7,d0
	move.w	#VCSUP,d7
	sub.b	d2,d7
	asl.l	d7,d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	add.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	add.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecg1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),20(a2)
	move.w	evt(pc),rupco
	lea.l	virg1(pc),a2
	bra	procevt1
pladrt: move.w	d7,rupco
	sub.w	pdeld(pc),d7
	muls	d5,d7
	asr.l	#DECPL,d7
	add.l	d7,d0
	move.l	sdec(pc),d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	sub.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	sub.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecd1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),18(a2)
	lea.l	vird1(pc),a2
	move.w	#$10,tevco2
	bra	procevt1
plagch: move.w	d7,rupco
	sub.w	pdeld(pc),d7
	muls	d5,d7
	asr.l	#DECPL,d7
	add.l	d7,d0
	move.l	sdec(pc),d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	add.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	add.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecg1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),20(a2)
	lea.l	virg1(pc),a2
	move.w	#$20,tevco2
	bra	procevt1
drtgch: sub.w	rupco(pc),d7
	ext.l	d7
	add.l	d7,d5
	move.b	vcodg(pc),d2
	bsr	rt_dg
	add.l	d7,d0
	move.w	#VCSUP,d7
	sub.b	d2,d7
	asl.l	d7,d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	add.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	add.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecg1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),20(a2)
	lea.l	virg1(pc),a2
	move.w	evt(pc),rupco
	move.w	#$20,tevco2
	bra	procevt1
gchdrt: sub.w	rupco(pc),d7
	ext.l	d7
	sub.l	d7,d5
	move.b	vcodg(pc),d2
	bsr	rt_dg
	sub.l	d7,d0
	move.w	#VCSUP,d7
	sub.b	d2,d7
	asl.l	d7,d5
	move.b	(a0),d2
	move.b	d2,vcodg
	move.w	#VCSUP,d7
	sub.b	d2,d7
; rupt
	move.l	#CINSUP,d4
	sub.l	d5,d4
	bsr	rucond
	asr.l	d7,d5
	bsr	rt_dg
	sub.l	d7,d0
	lsl.w	#3,d2
	lea.l	tasrl+64(pc),a0
	add.w	d2,a0
	lea.l	eecd1-2(pc),a2
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,10(a2)
	move.w	(a0),18(a2)
	lea.l	vird1(pc),a2
	move.w	evt(pc),rupco
	move.w	#$10,tevco2
	bra	procevt1
drtpla: move.b	vcodg(pc),d2
	move.w	d7,pdeld
	sub.w	rupco(pc),d7
	ext.l	d7
	add.l	d7,d5
	bsr	rt_dg
	add.l	d7,d0
	bsr	rt_pdg
	move.w	#VCSUP,d6
	sub.w	d2,d6
	asl.l	d6,d5
	move.l	d5,sdec
	move.w	d7,d5
	lea.l	droit1(pc),a2
	clr.w	tevco2
	move.w	#$7fff,evtrup+6
	clr.w	adgam+14
	bra	procevt1
gchpla: move.b	vcodg(pc),d2
	move.w	d7,pdeld
	sub.w	rupco(pc),d7
	ext.l	d7
	sub.l	d7,d5
	bsr	rt_dg
	sub.l	d7,d0
	bsr	rt_pdg
	move.w	#VCSUP,d6
	sub.w	d2,d6
	asl.l	d6,d5
	move.l	d5,sdec
	move.w	d7,d5
	lea.l	droit1(pc),a2
	clr.w	tevco2
	move.w	#$7fff,evtrup+6
	clr.w	adgam+14
	bra	procevt1

objet1: MOVE.W	A5,-(SP) ;MA6
	MOVE.L	USP,A5
	move.w	4(a7),d6 ;MA6
	addq.w	#1,nbob	    ;virer
	addq.w	#2,d6
	move.w	(a0),(a5)
	clr.b	8(a5)
	cmp.w	#8,tevt
	bne.s	patut
	clr.b	5(a5)
	move.w	4(a0),d2
	asl.w	#1,d2
	bra.s	spatut
patut:	move.w	6(a0),d2
	lsl.w	#1,d2
	asr.w	#1,d2
	btst	#7,6(a0)
	bne.s	left
	clr.b	5(a5)
	add.w	#255,d2
	bra.s	spat
left:	sub.w	#255,d2
	move.b	#1,5(a5)
spat:	asl.w	#1,d2
	btst	#3,1(a0)
	beq.s	spatut	;trt obj dbl pied
	move.w	d2,6+8(a5)
	neg.w	6+8(a5)
	move.b	#254,8(a5)
spatut: move.w	d2,6(a5)
	move.b	d6,1(a5)
	bne.s	vhorl
	move.b	#$ff,1(a5)
vhorl:	lea.l	-9026(a4),a0
	moveq	#0,d6
	move.w	(a0)+,d6
	move.w	d6,d4
	add.w	(a3),d6
	swap	d6
	lsr.l	#1,d6
	add.w	d7,d4
	divu	d4,d6
	sub.w	#32768,d6
	move.w	#254,d4
	sub.w	4(a7),d4 ;MA6
	add.w	d4,d4
	mulu	0(a0,d4.w),d6
	swap	d6
	add.w	2(a3),d6
	jmp	-4(a1)
retobj: add.w	#160,6(a5)
	lea.l	8(a5),a5
	tst.b	(a5)
	beq.s	sreto
	clr.b	8(a5)
	jmp	-4(a2)
sreto:	MOVE.L	A5,USP	;MA6
	MOVE.W	(SP)+,A5
	cmp.w	#8,tevt
	bne	procevt1
	addq.l	#6,adgam+8
	bra	procevt
omont1: move.w	d1,d4
	sub.w	rupmd(pc),d4
	add.w	d7,d4
	clr.w	d2
	move.b	vcohb(pc),d2
	bsr	rt_omd
	add.w	d3,d7
	muls	d6,d7
	bra.s	omonco
odes1:	move.w	d1,d4
	sub.w	d7,d4
	add.w	rupmd(pc),d4
	clr.w	d2
	move.b	vcohb(pc),d2
	bsr	rt_omd
	neg.w	d7
	add.w	d3,d7
	muls	d6,d7
	bra.s	omonco
odrt1:	
	sub.w	pdepl(pc),d7
	muls	d1,d7
	asr.l	#DECPL,d7
	add.w	d3,d7
	muls	d6,d7
omonco: swap	d7
	neg.w	d7
	add.w	#199+DEMAR,d7
	move.w	d7,2(a5)
	move.w	(A7),d4 ;MA6
	neg.w	d4
	add.w	#200+DEMAR,d4
	move.b	d4,4(a5)
	jmp	-4(a2)

odrot1: move.w	evt(pc),d4
	sub.w	rupco(pc),d4
	ext.l	d4
	add.l	d5,d4
	clr.w	d2
	move.b	vcodg(pc),d2
	bsr	rt_odg
	bra.s	ocouco
ogch1:	move.w	rupco(pc),d4
	sub.w	evt(pc),d4
	ext.l	d4
	add.l	d5,d4
	clr.w	d2
	move.b	vcodg(pc),d2
	bsr	rt_odg
	neg.l	d7
	bra.s	ocouco
odrit:	
	move.w	evt(pc),d7
	sub.w	pdeld(pc),d7
	muls	d5,d7
	asr.l	#DECPL,d7
ocouco: add.l	d0,d7
	move.w	6(a5),d4
	ext.l	d4
	add.l	d4,d7
	blt.s	vdnego
;	asl.l	#1,d7
	move.w	d7,d4
	mulu	d6,d4
	swap	d4
	swap	d7
	subq.w	#1,d7
	blt.s	fvdro
svdro:	add.w	d6,d4
;	 dbf	 d2,svdro
fvdro:	move.w	d4,6(a5)
	bra.L	retobj
vdnego:
;	asl.l	#1,d7
	move.w	d7,d4
	mulu	d6,d4
	swap	d4
	swap	d7
	neg.w	d7
	subq.w	#1,d7
	sub.w	d6,d4
	dbf	d7,snvdro
	move.w	d4,6(a5)
	bra	retobj
snvdro: sub.w	d6,d4
	move.w	d4,6(a5)
	bra	retobj
contevt:
	move.w	evt(pc),d7
	cmp.w	(a3),d7
	blt.s	strevt
	jmp	(a1)
strevt: movem.l a0/d2,-(a7)
	move.w	tevt(pc),d2
	move.l	adgam(pc,d2.w),a0
	add.l	figam(pc,d2.w),a0
	move.w	(a0),d2
	and.w	#$0003,d2
	add.w	d2,d2
	add.w	d2,d2
	jmp	natur(pc,d2.w)
	dc.w	0
evt:	dc.w	0
tevt:	dc.w	0
adgam:	dc.l	0,0,0,0
figam:	dc.l	0,0,0
	dc.l	evtrup
natur:	bra.l	courbu
	bra.l	inclin
	bra.l	objet1
	bra.l	objdiv
rt_omd: add.w	d2,d2
	add.w	d2,d2
	move.w	d4,d7
	jmp	ta_omd(pc,d2.w)
ta_omd:	
	bra.l	mo0
	bra.l	mo1
	bra.l	mo2
	bra.l	mo3
	bra.l	mo4
	bra.l	mo5
	bra.l	mo6
	bra.l	mo7
mo0:	asl.w	#3,d4
	move.w	0(a4,d4.w),d7
	asr.w	#5,d7
	rts
mo1:	asl.w	#2,d4
	move.w	0(a4,d4.w),d7
	asr.w	#4,d7
	rts
mo2:	and.w	#$fffe,d4
	sub.w	d4,d7
	add.w	d4,d4
	muls	2(a4,d4.w),d7
	asr.w	#1,d7
	add.w	0(a4,d4.w),d7
	asr.w	#3,d7
	rts
mo3:	and.w	#$fffc,d4
	sub.w	d4,d7
	muls	2(a4,d4.w),d7
	asr.w	#2,d7
	add.w	0(a4,d4.w),d7
	asr.w	#2,d7
	rts
mo4:	and.w	#$fff8,d4
	sub.w	d4,d7
	asr.w	#1,d4
	muls	2(a4,d4.w),d7
	asr.w	#3,d7
	add.w	0(a4,d4.w),d7
	asr.w	#1,d7
	rts
mo5:	and.w	#$fff0,d4
	sub.w	d4,d7
	asr.w	#2,d4
	muls	2(a4,d4.w),d7
	asr.w	#4,d7
	add.w	0(a4,d4.w),d7
	rts
mo6:	and.w	#$ffe0,d4
	sub.w	d4,d7
	asr.w	#3,d4
	muls	2(a4,d4.w),d7
	asr.w	#5,d7
	add.w	0(a4,d4.w),d7
	add.w	d7,d7
	rts
mo7:	and.w	#$ffc0,d4
	sub.w	d4,d7
	asr.w	#4,d4
	muls	2(a4,d4.w),d7
	asr.w	#6,d7
	add.w	0(a4,d4.w),d7
	asl.w	#2,d7
	rts
rt_md:	move.w	d2,d4
	add.w	d4,d4
	add.w	d4,d4
	jmp	ta_md(pc,d4.w)
ta_md:	
	bra.l	md0
	bra.l	md1
	bra.l	md2
	bra.l	md3
	bra.l	md4
	bra.l	md5
	bra.l	md6
	bra.l	md7
md0:	move.w	d1,d4
	asl.w	#3,d4
	move.w	0(a4,d4.w),d7
	asr.w	#5,d7
	rts
md1:	move.w	d1,d4
	asl.w	#2,d4
	move.w	0(a4,d4.w),d7
	asr.w	#4,d7
	rts
md2:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$fffe,d4
	sub.w	d4,d7
	add.w	d4,d4
	muls	2(a4,d4.w),d7
	asr.w	#1,d7
	add.w	0(a4,d4.w),d7
	asr.w	#3,d7
	rts
md3:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$fffc,d4
	sub.w	d4,d7
	muls	2(a4,d4.w),d7
	asr.w	#2,d7
	add.w	0(a4,d4.w),d7
	asr.w	#2,d7
	rts
md4:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$fff8,d4
	sub.w	d4,d7
	asr.w	#1,d4
	muls	2(a4,d4.w),d7
	asr.w	#3,d7
	add.w	0(a4,d4.w),d7
	asr.w	#1,d7
	rts
md5:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$fff0,d4
	sub.w	d4,d7
	asr.w	#2,d4
	muls	2(a4,d4.w),d7
	asr.w	#4,d7
	add.w	0(a4,d4.w),d7
	rts
md6:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$ffe0,d4
	sub.w	d4,d7
	asr.w	#3,d4
	muls	2(a4,d4.w),d7
	asr.w	#5,d7
	add.w	0(a4,d4.w),d7
	add.w	d7,d7
	rts
md7:	move.w	d1,d4
	move.w	d1,d7
	and.w	#$ffc0,d4
	sub.w	d4,d7
	asr.w	#4,d4
	muls	2(a4,d4.w),d7
	asr.w	#6,d7
	add.w	0(a4,d4.w),d7
	asl.w	#2,d7
	rts
rt_odg: add.w	d2,d2
	add.w	d2,d2
	move.l	d4,d7
	jmp	ta_odg(pc,d2.w)
ta_odg:	
	bra.l	do0
	bra.l	do1
	bra.l	do2
	bra.l	do3
	bra.l	do4
	bra.l	do5
	bra.l	do6
	bra.l	do7
do0:	asl.w	#3,d4
	move.w	0(a4,d4.w),d7
	asr.w	#5,d7
	ext.l	d7
	rts
do1:	asl.w	#2,d4
	move.w	0(a4,d4.w),d7
	asr.w	#4,d7
	ext.l	d7
	rts
do2:	and.w	#$fffe,d4
	sub.w	d4,d7
	add.w	d4,d4
	muls	2(a4,d4.w),d7
	asr.w	#1,d7
	add.w	0(a4,d4.w),d7
	asr.w	#3,d7
	ext.l	d7
	rts
do3:	and.w	#$fffc,d4
	sub.w	d4,d7
	muls	2(a4,d4.w),d7
	asr.w	#2,d7
	add.w	0(a4,d4.w),d7
	asr.w	#2,d7
	ext.l	d7
	rts
do4:	and.w	#$fff8,d4
	sub.w	d4,d7
	asr.w	#1,d4
	muls	2(a4,d4.w),d7
	asr.w	#3,d7
	add.w	0(a4,d4.w),d7
	asr.w	#1,d7
	ext.l	d7
	rts
do5:	and.w	#$fff0,d4
	sub.w	d4,d7
	asr.w	#2,d4
	muls	2(a4,d4.w),d7
	asr.w	#4,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	rts
do6:	and.w	#$ffe0,d4
	sub.w	d4,d7
	asr.l	#3,d4
	muls	2(a4,d4.w),d7
	asr.w	#5,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	add.w	d7,d7
	rts
do7:	and.w	#$ffc0,d4
	sub.w	d4,d7
	asr.l	#4,d4
	muls	2(a4,d4.w),d7
	asr.w	#6,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	asl.l	#2,d7
	rts
rt_dg:	move.w	d2,d4
	add.w	d4,d4
	add.w	d4,d4
	jmp	ta_dg(pc,d4.w)
ta_dg:	
	bra.l	dg0
	bra.l	dg1
	bra.l	dg2
	bra.l	dg3
	bra.l	dg4
	bra.l	dg5
	bra.l	dg6
	bra.l	dg7
dg0:	move.l	d5,d4
	asl.w	#3,d4
	move.w	0(a4,d4.w),d7
	asr.w	#5,d7
	ext.l	d7
	rts
dg1:	move.l	d5,d4
	asl.w	#2,d4
	move.w	0(a4,d4.w),d7
	asr.w	#4,d7
	ext.l	d7
	rts
dg2:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$fffe,d4
	sub.w	d4,d7
	add.w	d4,d4
	muls	2(a4,d4.w),d7
	asr.w	#1,d7
	add.w	0(a4,d4.w),d7
	asr.w	#3,d7
	ext.l	d7
	rts
dg3:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$fffc,d4
	sub.w	d4,d7
	muls	2(a4,d4.w),d7
	asr.w	#2,d7
	add.w	0(a4,d4.w),d7
	asr.w	#2,d7
	ext.l	d7
	rts
dg4:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$fff8,d4
	sub.w	d4,d7
	asr.w	#1,d4
	muls	2(a4,d4.w),d7
	asr.w	#3,d7
	add.w	0(a4,d4.w),d7
	asr.w	#1,d7
	ext.l	d7
	rts
dg5:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$fff0,d4
	sub.w	d4,d7
	asr.w	#2,d4
	muls	2(a4,d4.w),d7
	asr.w	#4,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	rts
dg6:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$ffe0,d4
	sub.w	d4,d7
	asr.l	#3,d4
	muls	2(a4,d4.w),d7
	asr.w	#5,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	add.w	d7,d7
	rts
dg7:	move.l	d5,d4
	move.l	d5,d7
	and.w	#$ffc0,d4
	sub.w	d4,d7
	asr.l	#4,d4
	muls	2(a4,d4.w),d7
	asr.w	#6,d7
	add.w	0(a4,d4.w),d7
	ext.l	d7
	asl.l	#2,d7
	rts
rt_pdg: lea.l	0(a4,d4.w),a2
	move.w	MADE(a2),d7
	add.w	MADE-4(a2),d7
	add.w	MADE-8(a2),d7
	add.w	MADE-12(a2),d7
	add.w	MADE-16(a2),d7
	add.w	MADE+4(a2),d7
	add.w	MADE+8(a2),d7
	add.w	MADE+12(a2),d7
	sub.w	MIDE(a2),d7
	sub.w	MIDE-4(a2),d7
	sub.w	MIDE-8(a2),d7
	sub.w	MIDE-12(a2),d7
	sub.w	MIDE-16(a2),d7
	sub.w	MIDE+4(a2),d7
	sub.w	MIDE+8(a2),d7
	sub.w	MIDE+12(a2),d7
	asr.w	#3,d7
	rts
rt_pmd: lea.l	0(a4,d4.w),a1
	move.w	MADE(a1),d7
	add.w	MADE-4(a1),d7
	add.w	MADE-8(a1),d7
	add.w	MADE-12(a1),d7
	add.w	MADE-16(a1),d7
	add.w	MADE+4(a1),d7
	add.w	MADE+8(a1),d7
	add.w	MADE+12(a1),d7
	sub.w	MIDE(a1),d7
	sub.w	MIDE-4(a1),d7
	sub.w	MIDE-8(a1),d7
	sub.w	MIDE-12(a1),d7
	sub.w	MIDE-16(a1),d7
	sub.w	MIDE+4(a1),d7
	sub.w	MIDE+8(a1),d7
	sub.w	MIDE+12(a1),d7
	asr.w	#3,d7
	rts
evtrup: dc.w	1,$7fff,0,$7fff
degre:	dc.l	0
vites:	dc.w	0
rupmd:	dc.w	0
rupco:	dc.w	0
tevco1: dc.w	0
tevco2: dc.w	0
	dc.w	0
topvib: dc.w	0
vitco:	dc.w	0
vibco:	dc.w	0
hautco: dc.w	0
valhau: dc.w	0
saucra: dc.w	0
crasco: dc.w	0
inild:	dc.w	0
decaco: dc.l	0
haplco: dc.w	0
haldco: dc.l	0
hald:	dc.w	0
hapl:	dc.w	0
pdeld:	dc.w	0
pdepl:	dc.w	0
sdem:	dc.w	0
sdec:	dc.l	0
inico:	dc.w	2
evnmo:	dc.b	0
evnco:	dc.b	0
vamo:	dc.b	0
vaco:	dc.b	0
vcohb:	dc.b	0
vcodg:	dc.b	0
X2:	DC.W	451
p_champ: dc.w	0,0,970
vchamp: dc.w	970,797,622,506
esevt1: dc.w	7,0,3,500
	dc.w	7,1000,3,1500
	dc.w	7,2000,3,2500
	dc.w	7,3000,3,3500
	dc.w	7,4000,3,4500
	dc.w	7,5000,3,5500
	dc.w	7,6000,3,6500
	dc.w	7,7001,0,$7fff
deevt1:	dc.l	 0
adscrol: dc.l	0
posvoit: dc.l	0
	dc.l	0
zafvo:	blk.w	30*3,0
vigch:	dc.b	0
vidrt:	dc.b	0
teor1:	dc.w	$100,$100,$101,$101,1,1,$101,$101
	dc.b	1,-1,0,0,1,0,0,0,1,-1,1,0,1,-2,1,-2
	dc.b	0,0,1,-1,0,0,1,0,1,0,1,-1,1,-2,1,-2
admodr:	dc.l	0
topcod:	dc.w	0
topdep:	dc.w	0
topmod:	dc.w	0
comodr:	dc.w	0
depmod:	dc.w	0
mvtscrol:   dc.w	  0
reste:	dc.w	0
volant: dc.w	0
dafec:	dc.w	0
rafec:	dc.w	0
tasrl:
	dc.w	$ffff
	asl.w	#3,d7
	nop
	asr.w	#5,d4
	dc.w	$ffff
	asl.w	#2,d7
	nop
	asr.w	#4,d4
	dc.w	$fffe
	add.w	d7,d7
	asr.w	#1,d4
	asr.w	#3,d4
	dc.w	$fffc
	nop
	asr.w	#2,d4
	asr.w	#2,d4
	dc.w	$fff8
	asr.w	#1,d7
	asr.w	#3,d4
	asr.w	#1,d4
	dc.w	$fff0
	asr.w	#2,d7
	asr.w	#4,d4
	nop
	dc.w	$ffe0
	asr.w	#3,d7
	asr.w	#5,d4
	add.w	d4,d4
	dc.w	$ffc0
	asr.w	#4,d7
	asr.w	#6,d4
	asl.w	#2,d4
* table courbe
	dc.w	$ffff
	asl.w	#3,d6
	nop
	asr.w	#5,d7
	dc.w	$ffff
	asl.w	#2,d6
	nop
	asr.w	#4,d7
	dc.w	$fffe
	add.w	d6,d6
	asr.w	#1,d7
	asr.w	#3,d7
	dc.w	$fffc
	nop
	asr.w	#2,d7
	asr.w	#2,d7
	dc.w	$fff8
	asr.w	#1,d6
	asr.w	#3,d7
	asr.w	#1,d7
	dc.w	$fff0
	asr.w	#2,d6
	asr.w	#4,d7
	nop
	dc.w	$ffe0
	asr.l	#3,d6
	asr.w	#5,d7
	add.w	d7,d7
	dc.w	$ffc0
	asr.l	#4,d6
	asr.w	#6,d7
	asl.l	#2,d7
;* Display Road

DSPROD: MOVE.L	#RODEQU,A0
	MOVE.L	CURSCR(PC),A1
	ADD.L	#32000,A1
	CLR.W	D4
	MOVE.L	#$0000FFFF,A5
	MOVE.L	A5,A2
	MOVEQ	#0,D6
	MOVE.L	D6,A4
	MOVE.L	#-1,D5
	MOVE.L	D5,A3
	BRA.L	BDSPRO
QUEVERT:
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	BRA.L	FINLIG
RESTGRI:
	BCLR	D6,D3
	BEQ.S	GRIS2
	MOVEM.L A5/A3,-(A1)
GRIS2:	NEG.W	D3
	ADD.W	D3,D3
	JMP	FGRIS2(PC,D3.W)
QUEGRIS:
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
FGRIS2: TST.W	8(A0)
	BGT	FINLIG
	MOVE.L	A1,D7
	MOVE.W	(A0),D0
	MOVE.W	D0,D1
	MOVE.W	6(A0),D3
	LSR.W	#2,D3
	BEQ	FINLIG
	SUB.W	D3,D0
	ADD.W	D3,D1
	BLE.L	BLANC2
	MOVE.W	D1,D2
	LSR.W	#1,D1
	AND.W	#$FFF8,D1
	CMP.W	#160,D1
	BLT.S	BLANCOK
	CMP.W	#320,D0
	BGE.L	BLANC2
	MOVE.W	#160,D1
	LEA.L	162(A1),A1
	BRA.S	SBL3
BLANCOK:
	ADD.W	D1,A1
	addq.w	#2,a1
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX1+32(PC,D2.W),(A1)
SBL3:	MOVE.W	D0,D2
	BGE.S	SBL0
	CLR.W	D0
	CLR.W	D2
	BRA.S	SBL1
SBL0:	LSR.W	#1,D0
	AND.W	#$FFF8,D0
SBL1:	SUB.W	D0,D1
	BGT.S	SBLANC
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX1(PC,D2.W),D2
	OR.W	D2,(A1)
	BRA.S	PABLANC
SBLANC: SUB.W	D1,A1
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX1(PC,D2.W),(A1)
SBL2:	SUBQ.W	#8,D1
	BLE.S	PABLANC
	LEA.L	8(A1),A1
	MOVE.W	TBPIX1(PC),(A1)
	BRA.S	SBL2
TBPIX1:	DC.W	$0000,$8000,$C000,$E000
	 DC.W	$F000,$F800,$FC00,$FE00
	 DC.W	$FF00,$FF80,$FFC0,$FFE0
	 DC.W	$FFF0,$FFF8,$FFFC,$FFFE

	 DC.W	$FFFF,$7FFF,$3FFF,$1FFF
	 DC.W	$0FFF,$07FF,$03FF,$01FF
	 DC.W	$00FF,$007F,$003F,$001F
	 DC.W	$000F,$0007,$0003,$0001  
PABLANC:
	MOVE.L	D7,A1
BLANC2: CMP.B	#-1,8(A0)
	BGT.L	FINLIG
	BLT.S	BANGAU
	MOVE.W	(A0),D2
	MOVE.W	D2,D0
	SUB.W	2(A0),D2
	ADD.W	D2,D0
	BRA.S	BANCOM
BANGAU: MOVE.W	(A0),D2
	SUB.W	2(A0),D2
	MOVE.W	4(A0),D0
	SUB.W	D2,D0
BANCOM: MOVE.L	A1,D7
	MOVE.W	D0,D1
	MOVE.W	6(A0),D3
	LSR.W	#2,D3
	SUB.W	D3,D0
	ADD.W	D3,D1
	BLE.L	FINLIG
	MOVE.W	D1,D2
	LSR.W	#1,D1
	AND.W	#$FFF8,D1
	CMP.W	#160,D1
	BLT.S	BLANCOK1
	CMP.W	#320,D0
	BGE.L	FINLIG
	MOVE.W	#160,D1
	LEA.L	162(A1),A1
	BRA.S	S1BL3
BLANCOK1:
	ADD.W	D1,A1
	addq.w	#2,a1
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX2+32(PC,D2.W),D2
	AND.W	D2,(A1)
S1BL3:	MOVE.W	D0,D2
	BGE.S	S1BL0
	CLR.W	D0
	CLR.W	D2
	BRA.S	S1BL1
S1BL0:	LSR.W	#1,D0
	AND.W	#$FFF8,D0
S1BL1:	SUB.W	D0,D1
	BGT.S	SBLANC1
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX2(PC,D2.W),D2
	OR.W	D2,(A1)
	BRA.S	PABLANC1
SBLANC1: SUB.W	 D1,A1
	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX2(PC,D2.W),D2
	AND.W	D2,(A1)
S1BL2:	SUBQ.W	#8,D1
	BLE.S	PABLANC1
	LEA.L	8(A1),A1
	MOVE.W	TBPIX2(PC),(A1)
	BRA.S	S1BL2
TBPIX2:	DC.W	$0000,$8000,$C000,$E000
	 DC.W	$F000,$F800,$FC00,$FE00
	 DC.W	$FF00,$FF80,$FFC0,$FFE0
	 DC.W	$FFF0,$FFF8,$FFFC,$FFFE

	 DC.W	$FFFF,$7FFF,$3FFF,$1FFF
	 DC.W	$0FFF,$07FF,$03FF,$01FF
	 DC.W	$00FF,$007F,$003F,$001F
	 DC.W	$000F,$0007,$0003,$0001  
PABLANC1:
	MOVE.L	D7,A1
FINLIG: LEA.L	10(A0),A0
BDSPRO: MOVE.B	9(A0),D4
	BLT	FDSPRO
	MOVE.L	TMM(PC,D4.W),D7
	MOVE.W	4(A0),D0
	MOVE.W	D0,D3
	BGE.S	CCLR1
	CLR.W	D3
CCLR1:	ADD.W	6(A0),D0
	BLE.L	QUEVERT
	MOVE.W	D0,D2
	LSR.W	#4,D0
	MOVE.W	#20,D1
	SUB.W	D0,D1
	BGT.S	PVERT1
* TRT DEPASS 319
	EOR.B	#2,D4
	MOVE.W	D3,D2
	LSR.W	#4,D3
	SUB.W	D3,D0
	ADD.W	D1,D0
	BGT.L	REPR1
	MOVE.W	2(A0),D0
	BLE	QUEGRIS
	MOVE.W	D0,D1
	MOVE.W	D1,D2
	LSR.W	#4,D1
	MOVE.W	#20,D3
	SUB.W	D1,D3
	BGT.L	REPR2
	SUB.W	6(A0),D0
	MOVE.W	D0,D2
	LSR.W	#4,D0
	MOVE.W	#20,D1
	SUB.W	D0,D1
	BGT	REPR3
	BRA	QUEVERT
PVERT1: BCLR	D6,D1
	BEQ.S	VERT1
	MOVEM.L A5/A4,-(A1)
VERT1:	NEG.W	D1
	ADD.W	D1,D1
	JMP	FVERT1(PC,D1.W)
TMM:	DC.W	$FFFF,$0000,$FFFF
TBPIX3:	DC.W	$0000,$8000,$C000,$E000
	 DC.W	$F000,$F800,$FC00,$FE00
	 DC.W	$FF00,$FF80,$FFC0,$FFE0
	 DC.W	$FFF0,$FFF8,$FFFC,$FFFE
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
FVERT1: AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX3(PC,D2.W),0(A1,D4.W)
	MOVE.W	D3,D2
	LSR.W	#4,D3
	EOR.B	#2,D4
	SUB.W	D3,D0
	BEQ.S	PINT1
REPR1:	SUBQ.W	#1,D0
BINT1:	MOVEM.L A5/D7,-(A1)
	DBF	D0,BINT1
PINT1:	AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX3(PC,D2.W),0(A1,D4.W)
	MOVE.W	2(A0),D0
	BLE	RESTGRI
	MOVE.W	D0,D1
	MOVE.W	D1,D2
	LSR.W	#4,D1
	SUB.W	D1,D3
* PREMIER RECOUV
	BEQ.S	PGRIS1
REPR2:	BCLR	D6,D3
	BEQ.S	GRIS1
	MOVEM.L A5/A3,-(A1)
GRIS1:	NEG.W	D3
	ADD.W	D3,D3
	JMP	FGRIS1(PC,D3.W)
PGRIS1: AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX4(PC,D2.W),D2
	AND.W	D2,0(A1,D4.W)
	SUB.W	6(A0),D0
	BGE.S	CCLR4
	CLR.W	D0
CCLR4:	MOVE.W	D0,D2
	LSR.W	#4,D0
	SUB.W	D0,D1
* DEUXIEM RECOUVR
	BGT.S	REPR3
	AND.W	#$F,D2
	ADD.W	D2,D2
	EOR.B	#2,D4
	MOVE.W	TBPIX4(PC,D2.W),D2
	AND.W	D2,0(A1,D4.W)
	BRA.S	REPR4
TBPIX4:	DC.W	$FFFF,$7FFF,$3FFF,$1FFF
	 DC.W	$0FFF,$07FF,$03FF,$01FF
	 DC.W	$00FF,$007F,$003F,$001F
	 DC.W	$000F,$0007,$0003,$0001  
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
	MOVEM.L A5/A3/A2/D5,-(A1)
FGRIS1: AND.W	#$F,D2
	ADD.W	D2,D2
	MOVE.W	TBPIX4(PC,D2.W),0(A1,D4.W)
	SUB.W	6(A0),D0
	BGE.S	CCLR3
	CLR.W	D0
CCLR3:	MOVE.W	D0,D2
	LSR.W	#4,D0
	SUB.W	D0,D1
	BEQ.S	PINT2
REPR3:	SUBQ.W	#1,D1
BINT2:	MOVEM.L A5/D7,-(A1)
	DBF	D1,BINT2
PINT2:	AND.W	#$F,D2
	ADD.W	D2,D2
	EOR.B	#2,D4
	MOVE.W	TBPIX4(PC,D2.W),0(A1,D4.W)
REPR4:	TST.W	D0
	BEQ	FGRIS2
	BCLR	D6,D0
	BEQ.S	VERT2
	MOVEM.L A5/A4,-(A1)
VERT2:	NEG.W	D0
	ADD.W	D0,D0
	JMP	FVERT2(PC,D0.W)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
	MOVEM.L A5/A4/A2/D6,-(A1)
FVERT2: BRA	FGRIS2
FDSPRO: 
;	 move.l	a1,d0
;	 sub.l	 adscrol(pc),d0
;	 sub.l	 CURSCR,d0
;	 ble.s	 fciel
;	 divu	 #160,d0
;	 move.l	d6,d4
;	 move.l	d6,d2
;	 move.l	a2,d5
;	 move.l	d5,d3
;	 subq.w	#1,d0
;bvert:	
;	 movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
;	 movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
;	 movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
;	 movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
;	 movem.l a5/a4/a2/d6/d5/d4/d3/d2,-(a1)
;	 dbf	 d0,bvert
; ******
	clr.l	d5
	move.l	a1,d0
	sub.l	adscrol(pc),d0
	sub.l	CURSCR,d0
	bgt.s	scsup
	neg.w	d0
	move.w	d0,d5
	move.w	#80,d1
	lsr.w	#5,d0
	sub.w	d0,d1
	ble.s	pascr
	move.w	d1,d0
	subq.w	#1,d0
	bra.s	afscr	
scsup:	lsr.w	#5,d0
	subq.w	#1,d0
bvert:	
	move.l	A5,-(a1)
	move.l	D6,-(a1)
	move.l	A5,-(a1)
	move.l	D6,-(a1)
	move.l	A5,-(a1)
	move.l	D6,-(a1)
	move.l	A5,-(a1)
	move.l	D6,-(a1)
	dbf	d0,bvert
afscr:	move.l	a1,d7
	sub.l	CURSCR(pc),d7
	move.l	d7,adsky+4	
	cmp.l	CURSCR(pc),a1
	ble.s	fciel
	move.w	mvtscrol(pc),d7
	neg.w	d7
	divu	#160,d5
	jsr	PANBCK	
	MOVE.L	A0,A1
pascr: move.l  CURSCR,a0
	add.l	#10560,a0
	move.l	a1,d0
	sub.l	a0,d0
	ble.s	fciel
	lsr.w	#5,d0
	subq.w	#1,d0
	move.l	#$ffffffff,d1
bbleu:	
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	dbf	d0,bbleu
fciel:	
	RTS
adsky:	dc.l	0,0

	dc.b	0,255,0,199,200,0,0,160
	dc.l	-1,-1
zafevt: blk.l	 256,0

HAUT:	DC.W	20
	DC.W	20
PVOL:	DC.W	3
BTIR:	DC.W	0
NTIR:	DC.W	0
PUNCH:	DC.W	0
PANIM:	DC.W	0 
;DATA VROOM
ADVOIT: DC.L	0,0,0,0,0,0,0
ADRETG: DC.L	0
ADRETD: DC.L	0
ADPBAS: DC.L	0,0,0,0,0,0,0,0,0
ADPANA: DC.L	0,0,0,0,0,0,0,0,0
	DC.L	0,0,0,0,0,0,0,0,0
	DC.L	0,0,0,0,0,0,0,0,0
	DC.L	0,0,0,0,0,0,0,0,0
ADPCRA: DC.L	0,0,0,0,0,0,0
	DC.L	0,0,0,0,0,0,0
ADPING: DC.L	0
ADPIND: DC.L	0
OFVOIT: DC.W	4320,4368,4416,8800,8848,8896,13280
	DC.W	2064,4144     ;OFFSET RETRO
	DC.W	0,24,48,72,96,120,3200,3224,3248	 ;OFF PNEU BASE
	DC.W	6400,10560,14720,18880	;OFF PNEU ANIM
	DC.W	6424,10584,14744,18904
	DC.W	6448,10608,14768,18928
	DC.W	6472,8552,10632,12712
	DC.W	6496,8576,10656,12736
	DC.W	6520,8600,10680,12760
	DC.W	8480,12640,16800,20960
	DC.W	8504,12664,16824,20984
	DC.W	8528,12688,16848,21008
	DC.W	23040,27200		;OFF PNEU CREV
	DC.W	23064,27224
	DC.W	23088,27248
	DC.W	23112,27272
	DC.W	23136,27296
	DC.W	23160,27320
	DC.W	25120,29280
	DC.W	14816,14792    ;PNEU INCLIN G ET D
ECRVOIT: EQU	842034
ECRPNEU: EQU	842034+32034

;*************
INIVOI:	LEA.L	  TINIV(PC),A3
	 MOVE.L	 #ECRVOIT,A0
	 LEA.L	  OFVOIT(PC),A2
	 LEA.L	  ADVOIT(PC),A5
	 MOVE.L	 #MSKCAR,A4
	 MOVE.W	 #6,D0
BINIV:	 MOVE.L	A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A3/A5/D0,-(SP)
	 BSR		CHVOI
	 MOVEM.L  (SP)+,A0/A2/A3/A5/D0
	 DBF		D0,BINIV
;*************INIT RETRO G ET D
	 MOVE.L	 A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A3/A5/D0,-(SP)
	 BSR		INIRET1
	 MOVEM.L  (SP)+,A0/A2/A3/A5/D0
	 MOVE.L	 A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A3/A5/D0,-(SP)
	 BSR		INIRET1
	 MOVEM.L  (SP)+,A0/A2/A3/A5/D0
;********* INIT PNEU
	 MOVE.L	 #ECRPNEU,A0
	 MOVE.W	 #9-1,D0
BINIPB:	MOVE.L	A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A5/D0,-(SP)
	 MOVE.W	 #12-1,D0
	 BSR		INIPN1
	 MOVEM.L  (SP)+,A0/A2/A5/D0
	 DBF		D0,BINIPB
	 MOVE.W	 #36-1,D0
BINIPA:	MOVE.L	A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A5/D0,-(SP)
	 MOVE.W	 #13-1,D0
	 BSR		INIPN1
	 MOVEM.L  (SP)+,A0/A2/A5/D0
	 DBF		D0,BINIPA
	 MOVE.W	 #14-1,D0
BINIPC:	MOVE.L	A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A5/D0,-(SP)
	 MOVE.W	 #13-1,D0
	 BSR		INIPCR
	 MOVEM.L  (SP)+,A0/A2/A5/D0
	 DBF		D0,BINIPC
	 MOVE.W	 #2-1,D0
BINIPI:	MOVE.L	A4,(A5)+
	 MOVE.L	 A0,A1
	 ADD.W	  (A2)+,A1
	 MOVEM.L  A0/A2/A5/D0,-(SP)
	 MOVE.W	 #20-1,D0
	 BSR		INIPCR
	 MOVEM.L  (SP)+,A0/A2/A5/D0
	 DBF		D0,BINIPI
	RTS

CHVOI:	 ;A4 ADR DE CHARG  A1 ADR ECRAN
	 LEA.L	  AFICAR(PC),A0
	 MOVEQ	  #28-1,D0
	 MOVEQ	  #0,D1
INIVOI2: MOVE		#2,D4
	 MOVE.L	 A1,A2
INIVOI3: LEA.L	  2(A4),A5
	 CLR.W	  D7
	 MOVE.L	 (A2)+,D5
	 MOVE.L	 (A2)+,D6
	 MOVE.L	 D6,D2
	 SWAP	  D2
	 OR.L	  D6,D2
	 MOVE.L	 D5,D3
	 SWAP	  D3
	 OR.L	  D5,D3
	 OR.L	  D3,D2
	 BEQ.S	  INIVOI4
	 MOVEQ	  #1,D7
	 NOT.L	  D2
	 BEQ.S	  INIVO4B
	 MOVEQ	  #2,D7
	 MOVE.L	 D2,(A5)+
INIVO4B: MOVE.L	D5,(A5)+
	 MOVE.L	 D6,(A5)+
INIVOI4: MOVE.L	(A2)+,D5
	 MOVE.L	 (A2)+,D6
	 MOVE.L	 D6,D2
	 SWAP	  D2
	 OR.L	  D6,D2
	 MOVE.L	 D5,D3
	 SWAP	  D3
	 OR.L	  D5,D3
	 OR.L	  D3,D2
	 BEQ.S	  INIVOI5
	 OR.W	  #$4,D7
	 NOT.L	  D2
	 BEQ.S	  INIVO5B
	 AND.W	  #$3,D7
	 OR.W	  #$8,D7
	 MOVE.L	 D2,(A5)+
INIVO5B: MOVE.L	D5,(A5)+
	 MOVE.L	 D6,(A5)+
INIVOI5: LSL.W	  #2,D7
	 MOVE.L	 0(A3,D7.W),D2
	 ADD.L	  D1,D2
	 MOVEQ	  #0,D1
	 MOVE.L	 D2,D3
	 SUB.L	  A0,D3
	 MOVE.L	 D2,A0
	 MOVE.W	 D3,(A4)
	 MOVE.L	 A5,A4
	 DBF		D4,INIVOI3
	 MOVE.L	 #-2,D1
	 LEA.L	  -160(A1),A1
	 DBF		D0,INIVOI2
	 MOVE.L	 #F_F,D2
	 SUB.L	  A0,D2
	 MOVE.W	 D2,(A4)+
	 RTS

INIPN1: MOVEM.W (A1)+,D4-D7
	OR.W	D4,D5
	OR.W	D6,D5
	OR.W	D7,D5
	NOT.W	D5
	MOVE.W	D5,(A4)+
	MOVE.W	D4,(A4)+
	MOVE.W	D7,(A4)+
	MOVE.W	(A1)+,(A4)+
	ADDQ.W	#4,A1
	MOVE.W	(A1)+,(A4)+
	MOVEM.W (A1)+,D4-D7
	OR.W	D4,D5
	OR.W	D6,D5
	OR.W	D7,D5
	NOT.W	D5
	MOVE.W	D5,(A4)+
	MOVE.W	D4,(A4)+
	MOVE.W	D7,(A4)+
	LEA.L	160-24(A1),A1
	DBF	D0,INIPN1
	RTS
INIPCR: MOVE.W	#2,D1
IPCR:	MOVEM.W (A1)+,D4-D7
	OR.W	D4,D5
	OR.W	D6,D5
	OR.W	D7,D5
	NOT.W	D5
	MOVE.W	D5,(A4)+
	MOVE.W	D4,(A4)+
	MOVE.W	D7,(A4)+
	DBF	D1,IPCR
	LEA.L	160-24(A1),A1
	DBF	D0,INIPCR
	RTS

INIRET1: LEA.L	  AFICAR(PC),A0
	 MOVEQ	  #13-1,D0
	 MOVEQ	  #0,D1
INIRET2: MOVE.L	A1,A2
	 LEA.L	  2(A4),A5
	 CLR.W	  D7
	 MOVE.L	 (A2)+,D5
	 MOVE.L	 (A2)+,D6
	 MOVE.L	 D6,D2
	 SWAP	  D2
	 OR.L	  D6,D2
	 MOVE.L	 D5,D3
	 SWAP	  D3
	 OR.L	  D5,D3
	 OR.L	  D3,D2
	 BEQ.S	  INIRET4
	 MOVEQ	  #1,D7
	 NOT.L	  D2
	 BEQ.S	  INIRE4B
	 MOVEQ	  #2,D7
	 MOVE.L	 D2,(A5)+
INIRE4B: MOVE.L	D5,(A5)+
	 MOVE.L	 D6,(A5)+
INIRET4: MOVE.L	(A2)+,D5
	 MOVE.L	 (A2)+,D6
	 MOVE.L	 D6,D2
	 SWAP	  D2
	 OR.L	  D6,D2
	 MOVE.L	 D5,D3
	 SWAP	  D3
	 OR.L	  D5,D3
	 OR.L	  D3,D2
	 BEQ.S	  INIRET5
	 OR.W	  #$4,D7
	 NOT.L	  D2
	 BEQ.S	  INIRE5B
	 AND.W	  #$3,D7
	 OR.W	  #$8,D7
	 MOVE.L	 D2,(A5)+
INIRE5B: MOVE.L	D5,(A5)+
	 MOVE.L	 D6,(A5)+
INIRET5: LSL.W	  #2,D7
	 MOVE.L	 0(A3,D7.W),D2
	 ADD.L	  D1,D2
	 MOVEQ	  #0,D1
	 MOVE.L	 D2,D3
	 SUB.L	  A0,D3
	 MOVE.L	 D2,A0
	 MOVE.W	 D3,(A4)
	 MOVE.L	 A5,A4
	 MOVE.L	 #-2,D1
	 LEA.L	  -160(A1),A1
	 DBF		D0,INIRET2
	 MOVE.L	 #F_F,D2
	 SUB.L	  A0,D2
	 MOVE.W	 D2,(A4)+
	 RTS
TINIV:	DC.L	V_V
	DC.L	P_V
	DC.L	T_V
	DC.L	0  
	DC.L	V_P
	DC.L	P_P
	DC.L	T_P
	DC.L	0
	DC.L	V_T
	DC.L	P_T
	DC.L	T_T
PDBL:	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A3)+,(A4)+
	RTS
INISCL: BSR	INIBCK
	MOVE.L	#842034+21440+2560,A0
	MOVE.W	#17-1,D0   ;NB LIGNE
	MOVE.L	#BCK2EQU,A4
BINSCL: MOVE.L	A0,A2
	LEA.L	8(A2),A3
	MOVE.W	#18,D1
B1SCL:	BSR	PDBL
	DBF	D1,B1SCL
	LEA.L	2720(A0),A3
	BSR	PDBL
;BLOC TYPE A RAJOUTER
;	LEA.L	-8(A3),A2
;	 19 FOIS
;	LEA.L	2720*NUM DU BLOC(A0),A3
;	1 FOIS
;2EME BLOC DE 17
	LEA.L	-8(A3),A2
	MOVE.W	#18,D1
B2SCL:	BSR	PDBL
	DBF	D1,B2SCL
	MOVE.L	A0,A3
	BSR	PDBL
;RETOUR BLOC DEBUT
	LEA.L	-8(A3),A2
	MOVE.W	#18,D1
B3SCL:	BSR	PDBL
	DBF	D1,B3SCL
	LEA.L	2720(A0),A3
	BSR	PDBL
	LEA.L	-160(A0),A0
	DBF	D0,BINSCL
	RTS
;* INIBCK - Init Background
INIBCK:	MOVE.L	#BCK2EQU,BCKADR2
	 CLR.W	  BCKINC2
	 RTS

;* PANBCK - Pan Background Routine
;*	  Input : D7 Contains # of Bits to Shift R/L + Sign
;*		  D7 Can be Greater than 16

PANBCK:
;  MOVE.L   adscrol(PC),A0
	MOVE.L	A1,A0
	MOVE.W	D5,D6
;ICI CONTROLE CLIP
; ATTENTION EVOLUTION DU SCROL SI PAS AFFIC

PANBCK0:
; ADDA.L   CURSCR(PC),A0

	 LEA.L	  BCKADR2(PC),A5 ;Get Pointer to BCK and INC (2)
	 MOVE.L	 (A5),A1  ;Get BCKADR2 Content
	 MOVE.W	 4(A5),D5	 ;Get BCKINC2 Content (0 TO 15)
	 TST		D7		 ;Test for R/L Move		 
	 BMI.S	  PANBCK12

	 ADD		D7,D5	 ;Here D7 >=0
PANBCK1: CMPI		#16,D5
	 BLT.S	  PANBCK16
	 LEA.L	  16(A1),A1
	 CMPA.L	 #BCK2EQU+640,A1 ;End of Mem Right?
	 BLE.S	  PANBCK2
	 LEA.L	  -640(A1),A1  ;NB BLOC *320
PANBCK2: SUB	  #16,D5
	 BRA.S	  PANBCK1

PANBCK12: ADD		 D7,D5	  ;Here D7 <0
	 BPL.S	  PANBCK16
PANBCK13: LEA.L	-16(A1),A1
	 CMPA.L	 #BCK2EQU,A1
	 BGE.S	  PANBCK14	 ;If PL, No
	 LEA.L	  640(A1),A1	;NB BLOC *320
PANBCK14: ADD		 #16,D5
	 BLT.S	  PANBCK13

PANBCK16: MOVE.L	 A1,(A5)   ;Update BCKADR2
	 MOVE.W	 D5,4(A5)	 ;Update BCKINC2 (0 to 15)
	
	MOVE.W	D6,D0
	MULU	#960,D0
	ADD.W	D0,A1

	 MOVE	  D5,D0	 ;D0 from 0 to 15
	 CMPI	  #8,D0
	 BLT.S	  PLBCK	 ;Low
	 SUB		#16,D0	 ;High : D1 From 16 to 1
	 NEG		D0
	 BRA		PHBCK 
       
PLBCK:	SWAP	D0 
	MOVE.W	#17-1,D0
	SUB.W	D6,D0
PLBCK2: SWAP	D0
	MOVEM.L 292(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 264(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 236(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 208(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 180(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 152(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 124(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 96(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 68(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 40(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 12(A1),D1-D7
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	LSL.L	D0,D4
	LSL.L	D0,D5
	LSL.L	D0,D6
	LSL.L	D0,D7
	SWAP	D1
	SWAP	D2
	SWAP	D3
	SWAP	D4
	SWAP	D5
	SWAP	D6
	SWAP	D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L (A1),D1-D3
	LSL.L	D0,D1
	LSL.L	D0,D2
	LSL.L	D0,D3
	SWAP	D1
	SWAP	D2
	SWAP	D3
	MOVEM.W D1-D3,-(A0)
	LEA.L	960(A1),A1  ;960=NB BLOC+1*320
	SWAP	D0 
	DBF	D0,PLBCK2
	RTS   
PHBCK:	SWAP	D0 
	MOVE.W	#17-1,D0
	SUB.W	D6,D0
PHBCK2: SWAP	D0
	MOVEM.L 292(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 264(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 236(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 208(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 180(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 152(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 124(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 96(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 68(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 40(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L 12(A1),D1-D7
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	LSR.L	D0,D4
	LSR.L	D0,D5
	LSR.L	D0,D6
	LSR.L	D0,D7
	MOVEM.W D1-D7,-(A0)
	MOVEM.L (A1),D1-D3
	LSR.L	D0,D1
	LSR.L	D0,D2
	LSR.L	D0,D3
	MOVEM.W D1-D3,-(A0)
	LEA.L	960(A1),A1  ;960=NB BLOC+1*320
	SWAP	D0 
	DBF	D0,PHBCK2
	RTS

;* Background Pointers
BCKADR2:  DC.L	   0	 ;Pointer to Background 2
BCKINC2:  DC.W	   0	 ;Bit increment From BCKADR2


CHAXE:	MOVE.W	D6,D7
	NOT.W	D7
	AND.W	D7,160(A0)
	AND.W	D7,320(A0)
	OR.W	D6,(A0)+
	OR.W	D6,160(A0)
	OR.W	D6,320(A0)
	AND.W	D7,(A0)+
	OR.W	D6,160(A0)
	OR.W	D6,320(A0)
	AND.W	D7,(A0)+
	OR.W	D6,160(A0)
	AND.W	D7,320(A0)
	OR.W	D6,(A0)+
	CLR.W	D6
	RTS
AFIPNE: 
;AFFI PNEU
	MOVE.W	PUNCH(PC),D1
	BNE	PNINCL
	MOVE.W	NTIR(PC),D1
	BLT	PNCAC1
	LEA.L	ADPANA(PC),A2	;PARTIE HAUTE GCH ANIM
	MOVE.W	PVOL(PC),D1
	ADDQ.W	#2,D1
	LSL.W	#4,D1
	MOVE.W	PANIM(PC),D2
	AND.W	#$FF,D2
	LSR.W	#6,D2
	ADD.W	D2,D2
	ADD.W	D2,D2
	ADD.W	D2,D1
	MOVE.L	0(A2,D1.W),A2
	MOVEQ	#12,D1
	MOVE.W	HAUT(PC),D2
	CMP.W	#13,D2
	BGE.S	HTENT
	MOVE.W	D2,D1
	SUBQ.W	#1,D1
HTENT:	SUBQ.W	#1,D2
	MULU	#160,D2
	MOVE.L	CURSCR(PC),A4
	ADD.W	#32000-160+56-24,A4
	SUB.W	D2,A4
	MOVEQ	#-1,D7
	BSR	AFIPN1
	LEA.L	ADPBAS(PC),A2	;PARTIE BASSE GCH
	MOVE.W	PVOL(PC),D1
	ADDQ.W	#2,D1
	LSL.W	#2,D1
	MOVE.L	0(A2,D1.W),A2
	MOVE.W	HAUT(PC),D1
	SUBQ.W	#1,D1
	SUB.W	#13,D1
	BLT.S	PNCAC1
	BSR	AFIPN1
PNCAC1: MOVE.W	NTIR(PC),D1
	BGT	PNCAC2
	LEA.L	ADPANA(PC),A2	;PARTIE HAUTE DRT ANIM
	LEA.L	AFIPN1(PC),A0
	MOVE.W	PVOL(PC),D1
	LSL.W	#4,D1
	MOVE.W	PANIM(PC),D2
	AND.W	#$FF,D2
	LSR.W	#6,D2
	MOVE.W	BTIR(PC),D0
	BEQ.S	PCREV
	LEA.L	AFIPCR(PC),A0
	LEA.L	ADPCRA(PC),A2
	LSR.W	#1,D2
	LSR.W	#1,D1
PCREV:	ADD.W	D2,D2
	ADD.W	D2,D2
	ADD.W	D2,D1
	MOVE.L	0(A2,D1.W),A2
	MOVEQ	#12,D1
	MOVE.W	HAUT+2(PC),D2
	CMP.W	#13,D2
	BGE.S	HTENT1
	MOVE.W	D2,D1
	SUBQ.W	#1,D1
HTENT1: SUBQ.W	#1,D2
	MULU	#160,D2
	MOVE.L	CURSCR(PC),A4
	ADD.W	#32000-160+56+48,A4
	SUB.W	D2,A4
	MOVEQ	#-1,D7
	JSR	(A0)
	LEA.L	ADPBAS(PC),A2	;PARTIE BASS DRT
	MOVE.W	PVOL(PC),D1
	LSL.W	#2,D1
	MOVE.L	0(A2,D1.W),A2
	MOVE.W	HAUT+2(PC),D1
	SUBQ.W	#1,D1
	SUB.W	#13,D1
	BLT.S	PNCAC2
	BSR	AFIPN1
PNCAC2:
;AFFI AXES
	LEA.L	TCACH(PC),A3
	MOVE.W	NTIR(PC),D0
	BGT	AXGCH	;AXE DRT
	MOVE.L	CURSCR(PC),A0
	ADD.L	#32000-1280+56+40,A0
	MOVE.W	#$100,D4
	MOVEQ	#0,D1
	MOVE.W	HAUT+2(PC),D0
	SUB.W	#17,D0
	BLT.S	AXDI
	BGT.S	AXDS
	MOVE.W	#23,A2
	CLR.W	D2
	CLR.W	D0
	BRA.S	REPAXD
AXDI:	MOVE.W	#160,A1
	NEG.W	D0
	BRA.S	SAXD
AXDS:	MOVE.W	#-160,A1
SAXD:	MOVE.W	#24*16,D1
	ADDQ.W	#1,D0
	DIVU	D0,D1
	SUBQ.W	#1,D0
	MOVE.W	D1,D2
	LSR.W	#4,D1
	SUBQ.W	#1,D1
	AND.W	#$F,D2
	MOVE.W	D1,A2
REPAXD: MOVE.W	D2,D3
	CLR.W	D6
	MOVE.W	PVOL(PC),D1
	ADD.W	D1,D1
	MOVE.W	0(A3,D1.W),D1
	ADD.W	#23,D1
BAXD:	MOVE.W	A2,D5
	ADD.W	D2,D3
	BCLR	#4,D3
	BEQ.S	SBAXD
	ADDQ.W	#1,D5
SBAXD:	OR.W	D4,D6
	ROR.W	#1,D4
	BCC.S	S1BAXD
	BSR	CHAXE
	DBF	D1,CAX1
	BRA.S	AXGCH
CAX1:	DBF	D5,SBAXD
	BRA.S	S2BAXD
S1BAXD: DBF	D1,CAX2
	BSR	CHAXE
	BRA.S	AXGCH
CAX2:	DBF	D5,SBAXD
	BSR	CHAXE
	LEA.L	-8(A0),A0
S2BAXD: ADD.W	A1,A0
	DBF	D0,BAXD

AXGCH:	MOVE.W	NTIR(PC),D1
	BEQ	AXGCHS
	RTS
AXGCHS: MOVE.L	CURSCR(PC),A0
	ADD.L	#32000-1280+56,A0
	MOVE.W	#$80,D4
	MOVEQ	#0,D1
	MOVE.W	HAUT(PC),D0
	SUB.W	#17,D0
	BLT.S	AXGI
	BGT.S	AXGS
	MOVE.W	#23,A2
	CLR.W	D2
	CLR.W	D0
	BRA.S	REPAXG
AXGI:	MOVE.W	#160,A1
	NEG.W	D0
	BRA.S	SAXG
AXGS:	MOVE.W	#-160,A1
SAXG:	MOVE.W	#24*16,D1
	ADDQ.W	#1,D0
	DIVU	D0,D1
	SUBQ.W	#1,D0
	MOVE.W	D1,D2
	LSR.W	#4,D1
	SUBQ.W	#1,D1
	AND.W	#$F,D2
	MOVE.W	D1,A2
REPAXG: MOVE.W	D2,D3
	CLR.W	D6
	MOVE.W	PVOL(PC),D1
	ADD.W	D1,D1
	MOVE.W	14(A3,D1.W),D1
	ADD.W	#23,D1
BAXG:	MOVE.W	A2,D5
	ADD.W	D2,D3
	BCLR	#4,D3
	BEQ.S	SBAXG
	ADDQ.W	#1,D5
SBAXG:	OR.W	D4,D6
	ROL.W	#1,D4
	BCC.S	S1BAXG
	BSR	CHAXE
	LEA.L	-16(A0),A0
	DBF	D1,CAX3
	RTS
CAX3:	DBF	D5,SBAXG
	BRA.S	S2BAXG
S1BAXG: DBF	D1,CAX4
	BSR	CHAXE
	RTS
CAX4:	DBF	D5,SBAXG
	BSR	CHAXE
	LEA.L	-8(A0),A0
S2BAXG: ADD.W	A1,A0
	DBF	D0,BAXG
	RTS
TCACH:	DC.W	0,0,-1,-2,-4,-6,-8	;CACHE PNEU DRT
	DC.W	-8,-6,-4,-2,-1,0,0  ;CACHE PNEU GCH
PNINCL: MOVE.L	ADPING(PC),A2	;GCH INCLINEE
	MOVE.W	HAUT(PC),D1
	MOVE.W	D1,D2
	SUBQ.W	#1,D1
	SUBQ.W	#1,D2
	MULU	#160,D2
	MOVE.L	CURSCR(PC),A4
	ADD.W	#32000-160+56-24,A4
	SUB.W	D2,A4
	MOVEQ	#-1,D7
	BSR	AFIPCR
	MOVE.L	ADPIND(PC),A2	;DRT INCLINEE
	MOVE.W	HAUT(PC),D1
	MOVE.W	D1,D2
	SUBQ.W	#1,D1
	SUBQ.W	#1,D2
	MULU	#160,D2
	MOVE.L	CURSCR(PC),A4
	ADD.W	#32000-160+56+48,A4
	SUB.W	D2,A4
	MOVEQ	#-1,D7
	BSR	AFIPCR
	RTS
AFIPN1: MOVE.W	(A2)+,D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	NOT.W	D0
	OR.W	D0,(A4)+
	OR.W	D0,(A4)+
	NOT.W	D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.L	D7,(A4)+
	MOVE.W	(A2)+,(A4)+
	MOVE.W	(A2)+,D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	NOT.W	D0
	OR.W	D0,(A4)+
	OR.W	D0,(A4)+
	NOT.W	D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	LEA.L	160-24(A4),A4
	DBF	D1,AFIPN1
	RTS
AFIPCR: MOVE.W	(A2)+,D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	NOT.W	D0
	OR.W	D0,(A4)+
	OR.W	D0,(A4)+
	NOT.W	D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+

	MOVE.W	(A2)+,D0
	BNE.S	PNMSK
	MOVE.W	(A2)+,(A4)+
	MOVE.L	D7,(A4)+
	MOVE.W	(A2)+,(A4)+
	BRA.S	SPNCR
PNMSK:	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	NOT.W	D0
	OR.W	D0,(A4)+
	OR.W	D0,(A4)+
	NOT.W	D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+

SPNCR:	MOVE.W	(A2)+,D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	NOT.W	D0
	OR.W	D0,(A4)+
	OR.W	D0,(A4)+
	NOT.W	D0
	MOVE.W	(A4),D5
	AND.W	D0,D5
	OR.W	(A2)+,D5
	MOVE.W	D5,(A4)+
	LEA.L	160-24(A4),A4
	DBF	D1,AFIPCR
	RTS
AFICAR: LEA.L	ADVOIT(PC),A2
	MOVE.W	PVOL(PC),D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	0(A2,D0.W),A2
	LEA.L	AFICAR(PC),A0
	MOVE.L	CURSCR(PC),A4
	MOVE.W	#208,D0
	ADD.W	#32000-160+56,A4
	ADD.W	(A2)+,A0
	JMP	(A0)
AFIRET: MOVE.L	ADRETG(PC),A2
	LEA.L	AFICAR(PC),A0
	MOVE.L	CURSCR(PC),A4
	MOVE.W	#176,D0
	ADD.W	#32000-160+56-16,A4
	ADD.W	(A2)+,A0
	JSR	(A0)
	MOVE.L	ADRETD(PC),A2
	LEA.L	AFICAR(PC),A0
	MOVE.L	CURSCR(PC),A4
	ADD.W	#32000-160+56+48,A4
	ADD.W	(A2)+,A0
	JMP	(A0)
;*************
	SUB.W	D0,A4
V_V:	LEA.L	16(A4),A4
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
V_P:	ADDQ.W	#8,A4
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
V_T:	ADDQ.W	#8,A4
	MOVE.L	(A2)+,D2
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
P_V:	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	ADDQ.W	#8,A4
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
P_P:	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
P_T:	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,D2
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
T_V:	MOVE.L	(A2)+,D2
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	ADDQ.W	#8,A4
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
T_P:	MOVE.L	(A2)+,D2
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	MOVE.L	(A4),D3
	AND.L	D2,D3
	OR.L	(A2)+,D3
	MOVE.L	D3,(A4)+
	MOVE.L	(A2)+,(A4)+
	MOVE.L	(A2)+,(A4)+
	ADD.W	(A2)+,A0
	JMP	(A0)

	SUB.W	D0,A4
T_T:	MOVEM.L (A4)+,D4-D7
	MOVE.L	(A2)+,D2
	AND.L	D2,D4
	OR.L	(A2)+,D4
	AND.L	D2,D5
	OR.L	(A2)+,D5
	MOVE.L	(A2)+,D2
	AND.L	D2,D6
	OR.L	(A2)+,D6
	AND.L	D2,D7
	OR.L	(A2)+,D7
	MOVEM.L D4-D7,-16(A4)
	ADD.W	(A2)+,A0
	JMP	(A0)
F_F:	RTS
;**********
BCK2EQU: BLK.L	 4100,0
MSKCAR:	BLK.L	 6600,0


meptig: lea.l	ttail(pc),a0
	moveq	#0,d0
	moveq	#0,d3
	move.w	#15,d1
btail:	move.w	d3,(a0)+
	addq.w	#4,d0
	move.w	d0,d3
	add.w	-2(a0),d3
	dbf	d1,btail
	
	move.l	#842034+13440,a0
	lea.l	tigdat(pc),a1
	move.l	a1,hgauch
	move.w	#15,d0
btig1:	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
	move.w	d0,d2
	eor.b	#$0f,d2
	move.w	d2,d3
	mulu	#160,d3
	add.l	d3,a2
atig1:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-160(a2),a2
	dbf	d2,atig1
	dbf	d0,btig1

	add.l	#160*16,a0
	move.l	a1,tgauch
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig2:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig2

	add.l	#160*1,a0
	move.l	a1,tgauch1
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig21: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig21

	add.l	#160*1,a0
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig22: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig22

	add.l	#160*1,a0
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig23: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig23

	add.l	#160*1,a0
	move.l	a1,hdroit
	move.w	#15,d0
btig3:	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
	move.w	d0,d2
	eor.b	#$0f,d2
	move.w	d2,d3
	mulu	#160,d3
	add.l	d3,a2
atig3:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-160(a2),a2
	dbf	d2,atig3
	dbf	d0,btig3

	add.l	#160*16,a0
	move.l	a1,tdroit
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig4:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig4

	add.l	#160*1,a0
	move.l	a1,tdroit1
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig41: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig41

	add.l	#160*1,a0
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig42: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig42

	add.l	#160*1,a0
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig43: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig43

	add.l	#160*1,a0
	move.l	a1,lampa
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig5:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig5

	add.l	#160*1,a0
	move.l	a1,lampaf
	move.w	#15,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig5f: move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig5f

	add.l	#160*1,a0
	move.l	a1,hpot
	move.w	#5,d0
btig6:	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
	move.w	#5,d2
	sub.w	d0,d2
	move.w	d2,d3
	mulu	#160,d3
	add.l	d3,a2
atig6:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-160(a2),a2
	dbf	d2,atig6
	dbf	d0,btig6

	add.l	#160*6,a0
	move.l	a1,tpot
	move.w	#5,d0
	move.l	a0,a2
	move.w	d0,d1
	lsl.w	#3,d1
	add.w	d1,a2
btig7:	move.w	(a2),(a1)+
	move.w	6(a2),(a1)+
	lea.l	-8(a2),a2
	dbf	d0,btig7
	rts
vecteur:
	move.b	(a5),d0
	ext.w	d0
	neg.w	d0
	lea.l	coorbas+12(pc),a3
	subq.w	#2,d0
	bge.s	rafft		 ;obj vide
	clr.w	-10(a3)
	move.w	#256,-12(a3)
objvi:	rts
vecteub:
	move.b	(a5),d0
	ext.w	d0
	neg.w	d0
	lea.l	coorbas+12(pc),a3
	subq.w	#2,d0
	cmp.w	#48,d0
	bge	rectang
;ici trt vecteur second
	rts
;affichage metal	d0=no obj pos - 2
rafft: 
	addq.w	#1,nbsprit	;virer
	cmp.w	#48,d0
	bge	rectang
	clr.w	d1
	move.b	1(a5),d1
	move.w	d1,(a3)
	move.w	6(a5),2(a3)
	move.w	6+8(a5),d6	;2eme x
	clr.w	d1
	move.b	4(a5),d1
	subq.w	#1,d1
	move.w	d1,6(a3)
	move.w	2(a5),4(a3)
	add.w	d0,d0
	move.w	jpaf(pc,d0.w),d0
	jmp	jpaf(pc,d0.w)
touch1: move.b	#1,-8(a3)
touche: rts
jpaf:	dc.w	cadra1-jpaf
	dc.w	cadra2-jpaf
	dc.w	cadra3-jpaf
	dc.w	cadrb1-jpaf
	dc.w	cadrb2-jpaf
	dc.w	cadrb3-jpaf
	dc.w	lampa16-jpaf
	dc.w	lampa8-jpaf
	dc.w	lampb16-jpaf
	dc.w	lampb8-jpaf
	dc.w	pdbl1-jpaf
	dc.w	pdbl2-jpaf
	dc.w	pdbl3-jpaf
	dc.w	pspl1-jpaf
	dc.w	pspl2-jpaf
	dc.w	pspl3-jpaf
	dc.w	lampc16-jpaf
	dc.w	pdbl4-jpaf
	dc.w	pdbl5-jpaf
	dc.w	pdbl6-jpaf
	dc.w	pdbl7-jpaf
rectang:
	sub.w	#48,d0
	add.w	d0,d0
	add.w	d0,d0
	lea.l	trect(pc),a0
	add.w	d0,a0
	move.w	-12+10(a3),d0
	move.w	d0,d4
	mulu	(a0)+,d0
	lsr.l	#8,d0
	mulu	(a0)+,d4
	lsr.l	#8,d4
	move.w	2(a5),d5
	move.w	6(a5),d1

	tst.w	d6
	bne.s	rsecon
	move.w	d0,-12(a3)
	move.w	d4,-12+2(a3)
	tst.b	5(a5)
	beq	fprect
	sub.w	d4,d1
	bra	fprect
rsecon: move.b	-12+5(a3),d3
	move.w	-12+10(a3),d7
	btst	#1,d3
	beq.s	rorout
	sub.w	-12(a3),d5
	btst	#0,d3
	beq.s	rocom
	add.w	d0,d5
	bra.s	rocom
rorout: btst	#0,d3
	beq.s	rocom
	sub.w	d7,d5
	add.w	d0,d5
rocom:	muls	-12+8(a3),d7
	asr.w	#8,d7
	add.w	d7,d5

	tst.b	5(a5)
	beq.s	rscal
	sub.w	-12+2(a3),d1
rscal:	move.w	-12+10(a3),d2
	muls	-12+6(a3),d2
	asr.w	#8,d2
	move.b	-12+5(a3),d3
	btst	#4,d3
	bne.s	ralctr
	add.w	d2,d1
	btst	#3,d3
	bne.s	ralgch
	add.w	-12+2(a3),d1
	btst	#2,d3
	bne.s	rdrgc
	sub.w	d4,d1
	bra.s	fprect
rdrgc:	addq.w	#1,d1
	bra.s	fprect
ralgch: btst	#2,d3
	beq.s	fprect
	sub.w	d4,d1
	subq.w	#1,d1
	bra.s	fprect
ralctr: move.w	-12+2(a3),d3
	lsr.w	#1,d3
	add.w	d3,d2
	move.w	d4,d3
	lsr.w	#1,d3
	sub.w	d3,d2
	add.w	d2,d1
fprect:
	MOVE.W	D0,D7
	JSR	CLIVECT
	BRA.S	III
	MOVE.L	#RODEQU,A0
	MOVE.W	D1,(A0)
	ADD.W	D1,D4
	MOVE.W	D4,2(A0)
	MOVE.B	EFSP(PC),D6
	AND.W	#$F0,D6
	LSR.W	#1,D6
	JSR	XPOLY
	RTS
III:	MOVE.B	#1,coorbas+4
	RTS

trect:  dc.w     100,100,120,120,140,140,180,180,220,220
        dc.w     60,120,80,160,120,240,80,200,120,160
        dc.w     120,60,160,80,240,120,200,80,47,47

cadra1: cmp.w	#20,(a3)
	ble	cadrb1
	move.w	(a3),d0
	move.w	2(a3),d7
	add.w	d0,d7
	move.w	d7,2(a3)
	move.w	d7,6(a5)
	sub.w	d7,d6
	move.w	d6,-10(a3)
	bra.s	cadrac
cadra3: cmp.w	#20,(a3)
	ble	cadrb3
	move.w	(a3),d0
	move.w	2(a3),d7
	sub.w	d0,d7
	move.w	d7,2(a3)
	move.w	d7,6(a5)
	sub.w	d7,d6
	move.w	d6,-10(a3)
	bra.s	cadrac
cadra2: cmp.w	#20,(a3)
	ble	cadrb2
	move.w	(a3),d0
	sub.w	2(a3),d6
	move.w	d6,-10(a3)
cadrac: move.w	d0,d7
	add.w	d7,d7
	add.w	d0,d7
	lsr.w	#2,d7
	move.w	d7,-12(a3)
	clr.b	5(a5)
	move.w	(a3),d0
	move.w	d0,d7
	add.w	d7,d7
	add.w	d7,d0
	lsr.w	#5,d0
	cmp.w	#16,d0
	blt.s	laok1
	move.w	#15,d0
laok1:	move.w	d0,larti

	lea.l	preti(pc),a4
	move.w	4(a3),d0
	bsr	prclip
	mulu	#160,d0
	move.l	CURSCR,a1
	add.l	d0,a1
	move.l	a1,42(a4)
	move.w	2(a3),d7
	sub.w	larti(pc),d7
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	cliga
	add.w	d2,a1
	bsr	aftia
	move.w	18(a4),a2
	move.w	-12(a3),d7
	move.w	larti(pc),d0
	sub.w	d0,d7
	subq.w	#1,d7
	ble	touch1
	lsl.w	#2,d0
	move.w	d0,4(a4)
	move.w	d7,2(a4)
	and.w	#$3,2(a4)
	lsr.w	#2,d7
	move.w	d7,(a4)
	move.l	tgauch(pc),a0
	add.w	d0,a0
	subq.w	#1,2(a4)
	bge.s	raj1
	subq.w	#1,d7
raj1:	bsr	cliphb
	bra.s	tpa1
	bsr	aftib
tpa1:	move.w	#1,d7
	bsr	cliphb
	bra.s	tpa1b
	bsr	rupti
tpa1b:
	move.w	(a4),d7
	move.l	tgauch1(pc),a0
	add.w	4(a4),a0
	subq.w	#1,2(a4)
	bge.s	raj2
	subq.w	#1,d7
raj2:	bsr	cliphb
	bra.s	tpa2
	bsr	aftib
tpa2:	move.w	#1,d7
	bsr	cliphb
	bra.s	tpa2b
	bsr	rupti
tpa2b:
	move.w	(a4),d7
	move.l	tgauch(pc),a0
	add.w	4(a4),a0
	subq.w	#1,2(a4)
	bge.s	raj3
	subq.w	#1,d7
raj3:	bsr	cliphb
	bra.s	tpa3
	bsr	aftib
tpa3:	move.w	#1,d7
	bsr	cliphb
	bra.s	tpa3b
	bsr	rupti
tpa3b:
	move.w	(a4),d7
	subq.w	#1,d7
	move.l	tgauch1(pc),a0
	add.w	4(a4),a0
	bsr	cliphb
	bra.s	tpa4
	bsr	aftib
tpa4:	move.w	#1,d7
	bsr	cliphb
	bra.s	tpa4b
	bsr	rupti
tpa4b:
	lea.l	ttail(pc),a0
	move.w	larti(pc),d7
	move.w	d7,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hgauch(pc),a0
	add.w	d0,a0
	bsr	cliphb1
	bra.s	colodb
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
	move.w	d7,8(a4)
	move.l	a1,10(a4)
colodb:	      
	move.l	42(a4),a1
	move.w	-10(a3),d7
	add.w	2(a3),d7
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	clidr
	add.w	d2,a1
	bsr	aftia
	move.w	20(a4),a2
	move.l	tdroit(pc),a0
	add.w	4(a4),a0
	move.w	22(a4),d7
	blt.s	tpa5
	bsr	aftib
tpa5:	move.w	24(a4),d7
	blt.s	tpa5b
	bsr	rupti
tpa5b:
	move.l	tdroit1(pc),a0
	add.w	4(a4),a0
	move.w	26(a4),d7
	blt.s	tpa6
	bsr	aftib
tpa6:	move.w	28(a4),d7
	blt.s	tpa6b
	bsr	rupti
tpa6b:
	move.l	tdroit(pc),a0
	add.w	4(a4),a0
	move.w	30(a4),d7
	blt.s	tpa7
	bsr	aftib
tpa7:	move.w	32(a4),d7
	blt.s	tpa7b
	bsr	rupti
tpa7b:
	move.l	tdroit1(pc),a0
	add.w	4(a4),a0
	move.w	34(a4),d7
	blt.s	tpa8
	bsr	aftib
tpa8:	move.w	36(a4),d7
	blt.s	tpa8b
	bsr	rupti
tpa8b:
	move.w	38(a4),d7
	blt	touche
	lea.l	ttail(pc),a0
	move.w	larti(pc),d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hdroit(pc),a0
	add.w	d0,a0
	move.w	40(a4),d0
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
	bra	tighor
cadrb1: move.w	(a3),d0
	move.w	2(a3),d7
	add.w	d0,d7
	move.w	d7,2(a3)
	move.w	d7,6(a5)
	sub.w	d7,d6
	move.w	d6,-10(a3)
	bra.s	cadrac2
cadrb3: move.w	(a3),d0
	move.w	2(a3),d7
	sub.w	d0,d7
	move.w	d7,2(a3)
	move.w	d7,6(a5)
	sub.w	d7,d6
	move.w	d6,-10(a3)
	bra.s	cadrac2
cadrb2: move.w	(a3),d0
	sub.w	2(a3),d6
	move.w	d6,-10(a3)
cadrac2: move.w  d0,d7
	add.w	d7,d7
	add.w	d0,d7
	lsr.w	#2,d7
	move.w	d7,-12(a3)
	clr.b	5(a5)
	move.w	(a3),d0
	move.w	d0,d7
	add.w	d7,d7
	add.w	d7,d0
	lsr.w	#5,d0
	cmp.w	#16,d0
	blt.s	laok2
	move.w	#15,d0
laok2:	move.w	d0,larti

	lea.l	preti(pc),a4
	move.w	4(a3),d0
	bsr	prclip
	mulu	#160,d0
	move.l	CURSCR,a1
	add.l	d0,a1
	move.l	a1,42(a4)
	move.w	2(a3),d7
	sub.w	larti(pc),d7
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	cliga
	add.w	d2,a1
	bsr	aftia
	move.w	18(a4),a2
	move.w	-12(a3),d7
	move.w	larti(pc),d0
	sub.w	d0,d7
	subq.w	#1,d7
	ble	touch1
	bsr	cliphb
	bra.s	tetga
	lsl.w	#2,d0
	move.l	tgauch(pc),a0
	add.w	d0,a0
	bsr	aftib
tetga:	lea.l	ttail(pc),a0
	move.w	larti(pc),d7
	move.w	d7,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hgauch(pc),a0
	add.w	d0,a0
	bsr	cliphb1
	bra.s	colodr
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
	move.w	d7,8(a4)
	move.l	a1,10(a4)
colodr:	      
	move.l	42(a4),a1
	move.w	-10(a3),d7
	add.w	2(a3),d7
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	clidr
	add.w	d2,a1
	bsr	aftia
	move.w	20(a4),a2
	move.w	22(a4),d7
	blt.s	tetdr
	move.w	larti(pc),d0
	lsl.w	#2,d0
	move.l	tdroit(pc),a0
	add.w	d0,a0
	bsr	aftib
tetdr:	move.w	38(a4),d7
	blt	touche
	lea.l	ttail(pc),a0
	move.w	larti(pc),d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hdroit(pc),a0
	add.w	d0,a0
	move.w	40(a4),d0
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
tighor:
	cmp.w	#4,a2
	beq	touche
	move.l	a1,d0
	move.l	10(a4),a1
	move.w	larti(pc),d2
	cmp.w	2(a3),d2
	ble.s	gasup
	tst.w	2(a3)
	bge.s	ga1sup
	clr.w	d2
	bra.s	prmot
ga1sup: subq.l	#8,a1
gasup:	add.w	8(a4),d2
	addq.w	#1,d2
	bclr	#4,d2
	beq.s	prmot
	addq.l	#8,a1
prmot:	lea.l	tmas1(pc),a5
	lsl.w	#2,d2
	move.w	0(a5,d2.w),d4
	swap	d4
	move.w	0(a5,d2.w),d4
	move.l	d4,d5
	not.l	d5
	move.w	-10(a3),d1
	add.w	2(a3),d1
	cmp.w	#319,d1
	ble.s	drsup
	clr.w	d7
drsup:	sub.l	a1,d0
	subq.l	#8,d0
	lsr.w	#1,d0
	move.w	#80,d1
	sub.w	d0,d1
	
	lsl.w	#2,d7
	move.w	0(a5,d7.w),d0
	swap	d0
	move.w	0(a5,d7.w),d0
	move.l	d0,d7
	not.l	d7
	move.w	larti(pc),d6
	lea.l	seqti(pc),a5
	lsl.w	#4,d6
	add.w	larti(pc),d6
	sub.w	38(a4),d6
	sub.w	40(a4),d6
	add.w	d6,a5
	move.w	38(a4),d6
	lea.l	coulti(pc),a0
	lea.l	160(a1),a1
	tst.w	d1
	blt	usmot
	lea.l	tjuli(pc),a4
	add.w	d1,a4
	move.l	a1,a2
	clr.w	d1
btiho:	move.b	(a5)+,d1
	move.l	0(a0,d1.w),d2
	move.l	4(a0,d1.w),d3
	and.l	d5,d2
	and.l	d5,d3
	and.l	d4,(a1)
	or.l	d2,(a1)+
	and.l	d4,(a1)
	or.l	d3,(a1)+
	move.l	0(a0,d1.w),d2
	move.l	4(a0,d1.w),d3
	jmp	(a4)
tjuli:
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	move.l	d3,(a1)+
	and.l	d0,d2
	and.l	d0,d3
	and.l	d7,(a1)
	or.l	d2,(a1)+
	and.l	d7,(a1)
	or.l	d3,(a1)+
	lea.l	160(a2),a2
	move.l	a2,a1
	dbf	d6,btiho
retrout:
	rts
usmot:	clr.w	d1
	and.l	d5,d0
	or.l	d4,d7
btihos: move.b	(a5)+,d1
	move.l	0(a0,d1.w),d2
	move.l	4(a0,d1.w),d3
	and.l	d0,d2
	and.l	d0,d3
	and.l	d7,(a1)
	or.l	d2,(a1)+
	and.l	d7,(a1)
	or.l	d3,(a1)+
	lea.l	152(a1),a1
	dbf	d6,btihos
	rts
lampb8: move.l	lampaf(pc),-6(a3)
	bra.s	l8cb
lampa8: move.l	lampa(pc),-6(a3)
l8cb:	move.w	(a3),d0
	move.w	d0,-12(a3)
	add.w	d0,d0
	add.w	(a3),d0
	lsr.w	#7,d0
	bra.s	lampc
lampc16: move.l  lampaf(pc),-6(a3)
	move.w	(a3),d0
	move.w	d0,d7
	lsl.w	#2,d7
	add.w	d0,d7
	lsr.w	#3,d7
	bra.s	l16c 
lampb16: move.l  lampaf(pc),-6(a3)
	move.w	(a3),d0
	move.w	d0,d7
	lsl.w	#3,d7
	add.w	d0,d7
	lsr.w	#4,d7
	bra.s	l16c 
lampa16: move.l  lampa(pc),-6(a3)
	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#1,d7
	add.w	d0,d7
	add.w	d0,d0
	add.w	(a3),d0
	lsr.w	#6,d0
	move.w	d7,-12(a3)
	bra.s	lampc
l16c:	move.w	d7,-12(a3)
	lsr.w	#4,d0
lampc:	move.w	d0,larti
	move.w	d0,-10(a3)

	lea.l	preti(pc),a4
	move.w	2(a3),d7
	tst.b	5(a5)
	beq.s	lamdrt
	sub.w	larti(pc),d7
lamdrt: move.w	4(a3),d0
	bsr	prclip
	mulu	#160,d0
	move.l	CURSCR,a1
	add.l	d0,a1
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	cliga
	add.w	d2,a1
	bsr	aftia
	move.w	18(a4),a2
	move.w	-12(a3),d7
	ble	touch1
	move.w	larti(pc),d0
	bsr	cliphb
	bra.s	touch2
	lsl.w	#2,d0
	move.l	-6(a3),a0
	add.w	d0,a0
	bsr	aftib
touch2: rts
pdbl7:	move.w	#200,d7
	bra.s	rdbl
pdbl6:	move.w	#160,d7
	bra.s	rdbl
pdbl5:	move.w	#120,d7
	bra.s	rdbl
pdbl4:	move.w	#80,d7
rdbl:	move.w	(a3),d0
	mulu	d0,d7
	lsr.w	#8,d7
	move.w	d7,-10(a3)
	move.w	d0,d7
	add.w	d7,d7
	add.w	d0,d7
	lsr.w	#5,d7
	move.w	d7,-12(a3)  ;haut
	bra.s	pdblc
pdbl1:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#3,d7
	move.w	d7,-10(a3)  ;larg
	move.w	d7,-12(a3)  ;haut
	bra.s	pdblc
pdbl2:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#2,d7
	move.w	d7,-10(a3)
	lsr.w	#1,d7
	move.w	d7,-12(a3)
	bra.s	pdblc
pdbl3:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#2,d7
	move.w	d7,-12(a3)
	move.w	d0,d7
	lsl.w	#3,d7
	move.w	d7,d2
	lsl.w	#1,d7
	add.w	d2,d7
	sub.w	d0,d7
	lsr.w	#6,d7
	move.w	d7,-10(a3)
pdblc:	lsr.w	#5,d0
	subq.w	#1,d0
	bge.s	tsu6
	clr.w	d0
	bra.s	fsu6
tsu6:	cmp.w	#5,d0
	ble.s	fsu6
	move.w	#5,d0
fsu6:	move.w	d0,larti
	move.w	2(a3),d7
	tst.b	5(a5)
	beq.s	piedr
	sub.w	-10(a3),d7
	move.w	d7,2(a3)
piedr:	lea.l	preti(pc),a4
	move.w	4(a3),d0
	bsr	prclip
	mulu	#160,d0
	move.l	CURSCR,a1
	add.l	d0,a1
	move.l	a1,42(a4)
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	cliga
	add.w	d2,a1
	bsr	aftia
	move.w	18(a4),a2
	move.w	-12(a3),d7
	move.w	larti(pc),d0
	sub.w	d0,d7
	subq.w	#1,d7
	ble	touche
	bsr	cliphb
	bra.s	tetgab
	lsl.w	#2,d0
	move.l	tpot(pc),a0
	add.w	d0,a0
	bsr	aftib
tetgab: lea.l	ttail(pc),a0
	move.w	larti(pc),d7
	move.w	d7,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hpot(pc),a0
	add.w	d0,a0
	bsr	cliphb1
	bra.s	colodp
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
	move.w	d7,8(a4)
	move.l	a1,10(a4)
colodp:	      
	move.l	42(a4),a1
	move.w	-10(a3),d7
	add.w	2(a3),d7
	sub.w	larti(pc),d7
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	clidr
	add.w	d2,a1
	bsr	aftia
	move.w	20(a4),a2
	move.w	22(a4),d7
	blt.s	tetdrp
	move.w	larti(pc),d0
	lsl.w	#2,d0
	move.l	tpot(pc),a0
	add.w	d0,a0
	bsr	aftib
tetdrp: move.w	38(a4),d7
	blt	touche
	lea.l	ttail(pc),a0
	move.w	larti(pc),d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hpot(pc),a0
	add.w	d0,a0
	move.w	40(a4),d0
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	rts
pspl1:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#3,d7
	move.w	d7,d2
	lsr.w	#1,d2
	add.w	d2,d7
	move.w	d7,-12(a3)
	bra.s	psplc
pspl2:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#3,d7
	move.w	d7,-12(a3)
	bra.s	psplc
pspl3:	move.w	(a3),d0
	move.w	d0,d7
	lsr.w	#2,d7
	move.w	d7,d2
	lsr.w	#1,d2
	add.w	d2,d7
	move.w	d7,-12(a3)
psplc:	lsr.w	#5,d0
	subq.w	#1,d0
	bge.s	tsu6b
	clr.w	d0
	bra.s	fsu6b
tsu6b:	cmp.w	#5,d0
	ble.s	fsu6b
	move.w	#5,d0
fsu6b:	move.w	d0,larti
	move.w	d0,-10(a3)
	move.w	2(a3),d7
	tst.b	5(a5)
	beq.s	piedb
	sub.w	d0,d7
piedb:	lea.l	preti(pc),a4
	move.w	4(a3),d0
	bsr	prclip
	mulu	#160,d0
	move.l	CURSCR,a1
	add.l	d0,a1
	move.w	d7,d2
	and.w	#$000f,d7
	and.w	#$fff0,d2
	asr.w	#1,d2
	bsr	cliga
	add.w	d2,a1
	bsr	aftia
	move.w	18(a4),a2
	move.w	-12(a3),d7
	move.w	larti(pc),d0
	sub.w	d0,d7
	ble	touche
	bsr	cliphb
	bra.s	tetgap
	lsl.w	#2,d0
	move.l	tpot(pc),a0
	add.w	d0,a0
	bsr	aftib
tetgap: lea.l	ttail(pc),a0
	move.w	larti(pc),d7
	move.w	d7,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.l	hpot(pc),a0
	add.w	d0,a0
	bsr	cliphb1
	bra.s	coldb
	lsl.w	#2,d0
	add.w	d0,a0
	bsr	afhti
	swap	d7
	move.w	d7,8(a4)
	move.l	a1,10(a4)
coldb:	rts	  
cliga:
	clr.l	18(a4)
	cmp.w	#-8,d2
	bgt.s	tdr
	blt.s	tga
	clr.w	d2
	move.w	#1*4,18(a4)
	bra.s	tcomot
tga:	clr.w	d2
	bra.s	tcomot
tdr:	cmp.w	#152,d2
	blt.s	pacent
	beq.s	bodrt
	move.l	#retrout,(a7)
	rts
bodrt:	move.w	#3*4,18(a4)
	bra.s	tcomot
pacent: move.w	#2*4,18(a4)
tcomot: move.w	larti(pc),d0
	add.w	d7,d0
	cmp.w	#16,d0
	blt.s	unmo
	rts
unmo:	bset	#4,19(a4)
	rts
clidr:
	cmp.w	#-8,d2
	bgt.s	tdrb
	blt.s	tgab
	clr.w	d2
	move.w	#1*4,20(a4)
	rts
tgab:	move.l	#retrout,(a7)
	rts
tdrb:	cmp.w	#152,d2
	blt.s	pacentb
	beq.s	bodrtb
	move.w	#160,d2
	bra.s	tcomotb
bodrtb: move.w	#3*4,20(a4)
	bra.s	tcomotb
pacentb:
	move.w	#2*4,20(a4)
tcomotb: move.w  larti(pc),d0
	add.w	d7,d0
	cmp.w	#16,d0
	blt.s	unmob
	rts
unmob:	bset	#4,21(a4)
	rts

prclip:
	move.w	6(a3),d1
	sub.w	d0,d1
	blt.s	cpba1
	clr.w	14(a4)
	bra.s	cpbco1
cpba1:	move.w	d1,14(a4)
	move.w	6(a3),d0
cpbco1: move.w	d0,16(a4)
	sub.w	#banner,16(a4)
	move.l	14(a4),18(a4)
	lea.l	22(a4),a5
	rts
cliphb:
	tst.w	14(a4)
	beq.s	cpbx2
	add.w	14(a4),d7
	bgt.s	cpbx1
	move.w	d7,14(a4)
	bra.s	cpby2
cpbx1:	clr.w	14(a4)
cpbx2:	sub.w	d7,16(a4)
	blt.s	cpby1
cpby0:	addq.l	#2,(a7)
cpby2:	subq.w	#1,d7
	move.w	d7,(a5)+
	rts
cpby1:	add.w	16(a4),d7
	bgt.s	cpby0
	bra.s	cpby2
cliphb1:
	move.w	larti(pc),d0
	tst.w	14(a4)
	beq.s	cpbx21
	add.w	14(a4),d7
	bge.s	cpbx11
	move.w	d7,14(a4)
	bra.s	cpby21
cpbx11: clr.w	14(a4)
cpbx21: subq.w	#1,16(a4)
	sub.w	d7,d0
	sub.w	d7,16(a4)
	blt.s	cpby11
cpby01: addq.l	#2,(a7)
cpby21: move.w	d7,38(a4)
	move.w	d0,40(a4)
	rts
cpby11: add.w	16(a4),d7
	bge.s	cpby01
	bra.s	cpby21
aftia:	move.w	larti(pc),d3
	lea.l	tmas(pc),a2
	lsl.w	#2,d3
	move.l	0(a2,d3.w),d6
	ror.l	d7,d6
	move.w	d6,d4
	swap	d4
	move.w	d6,d4
	swap	d6
	move.w	d6,d5
	swap	d5
	move.w	d6,d5
	move.w	d6,d1
	not.w	d1
	swap	d6
	not.l	d6
	swap	d7
	rts
aftib:	swap	d7
	move.l	(a0),d0
	ror.l	d7,d0
	swap	d7
	move.l	d0,d2
	and.l	d5,d0
	and.l	d4,d2
	swap	d0
	move.w	d0,d3
	move.w	d2,d0
	swap	d2
	jmp	tchti(pc,a2.w)
tchti:	bra.l	calecr
	bra.l	duphd
	bra.l	duph
	bra.l	duphg
	bra.l	calecr
	bra.l	calecr
	bra.l	duphg
	bra.l	duphg
afhti:
	jmp	tchhti(pc,a2.w)
tchhti: bra.l	calecr
	bra.l	afhtid
	bra.l	afhtic
	bra.l	afhtig
	bra.l	calecr
	bra.l	calecr
	bra.l	afhtig
	bra.l	afhtig
afhtic: move.l	(a0)+,d0
	swap	d7
	ror.l	d7,d0
	swap	d7
	move.l	d0,d2
	and.l	d5,d0
	and.l	d4,d2
	swap	d0
	move.w	d0,d3
	move.w	d2,d0
	swap	d2
	and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.l	d6,(a1)
	or.l	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-174(a1),a1
	dbf	d7,afhtic
	rts
afhtig: move.l	(a0)+,d0
	swap	d7
	ror.l	d7,d0
	swap	d7
	and.l	d5,d0
	move.l	d0,d3
	swap	d3
	and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.w	d1,(a1)
	or.w	d0,(a1)
	lea.l	-166(a1),a1
	dbf	d7,afhtig
	rts
afhtid: move.l	(a0)+,d0
	swap	d7
	ror.l	d7,d0
	swap	d7
	move.l	d0,d2
	and.l	d4,d2
	move.w	d2,d0
	swap	d2
	and.w	d6,(a1)
	or.w	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-166(a1),a1
	dbf	d7,afhtid
	rts
rupti:	move.l	128(a0),d0
	swap	d7
	ror.l	d7,d0
	swap	d7
	move.l	d0,d2
	and.l	d5,d0
	and.l	d4,d2
	swap	d0
	move.w	d0,d3
	move.w	d2,d0
	swap	d2
	jmp	tchmti(pc,a2.w)
tchmti: bra.l	calecb
	bra.l	afmtid
	bra.l	afmtic
	bra.l	afmtig
	bra.l	calecb
	bra.l	calecb
	bra.l	afmtig
	bra.l	afmtig
afmtic: and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.l	d6,(a1)
	or.l	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-174(a1),a1
	rts
afmtig: swap	d0
	and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.w	d1,(a1)
	or.w	d0,(a1)
	lea.l	-166(a1),a1
	rts
afmtid:	
	and.w	d6,(a1)
	or.w	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-166(a1),a1
	rts
calecr: move.w	d7,d0
	addq.w	#1,d0
	mulu	#160,d0
	sub.l	d0,a1
	rts
calecb: 
	lea.l	-160(a1),a1
	rts
duph:
	lsr.w	#1,d7
	bcc.s	duph1
duph0:	and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.l	d6,(a1)
	or.l	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-174(a1),a1
duph1:	and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.l	d6,(a1)
	or.l	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-174(a1),a1
	dbf	d7,duph0
	rts
duphg:	swap	d0
	lsr.w	#1,d7
	bcc.s	duphg1
duphg0: and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.w	d1,(a1)
	or.w	d0,(a1)
	lea.l	-166(a1),a1
duphg1: and.w	d1,(a1)
	or.w	d3,(a1)+
	or.l	d5,(a1)+
	and.w	d1,(a1)
	or.w	d0,(a1)
	lea.l	-166(a1),a1
	dbf	d7,duphg0
	rts
duphd:	
	lsr.w	#1,d7
	bcc.s	duphd1
duphd0:	
	and.w	d6,(a1)
	or.w	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-166(a1),a1
duphd1: 
	and.w	d6,(a1)
	or.w	d0,(a1)+
	or.l	d4,(a1)+
	and.w	d6,(a1)
	or.w	d2,(a1)
	lea.l	-166(a1),a1
	dbf	d7,duphd0
	rts
ttail:	blk.w	16,0
tmas1:	dc.w	0,0
tmas:	dc.w	$8000,0,$c000,0,$e000,0,$f000,0
	dc.w	$f800,0,$fc00,0,$fe00,0,$ff00,0
	dc.w	$ff80,0,$ffc0,0,$ffe0,0,$fff0,0
	dc.w	$fff8,0,$fffc,0,$fffe,0,$ffff,0
coulti: dc.w	0,-1,-1,0,-1,-1,-1,0,0,-1,-1,-1,-1,-1,-1,-1
seqti:	
	dc.b	8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,8,8,16,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,0,8,8,16,0,0,0,0,0,0,0,0,0,0,0
	dc.b	16,0,8,8,8,16,0,0,0,0,0,0,0,0,0,0
	dc.b	16,8,0,8,8,16,8,0,0,0,0,0,0,0,0,0
	dc.b	16,8,0,8,8,8,16,8,0,0,0,0,0,0,0,0
	dc.b	16,8,0,8,8,8,8,16,8,0,0,0,0,0,0,0
	dc.b	16,8,0,8,8,8,8,16,8,8,0,0,0,0,0,0
	dc.b	16,8,8,0,8,8,8,8,16,8,8,0,0,0,0,0
	dc.b	16,8,8,0,8,8,8,8,8,16,8,8,0,0,0,0
	dc.b	16,8,8,0,8,8,8,8,8,16,8,8,8,0,0,0
	dc.b	16,8,8,8,0,8,8,8,8,8,16,8,8,8,0,0
	dc.b	16,8,8,8,0,8,8,8,8,8,16,8,8,8,0,0
coorbas: dc.l	0,0,0,0,0,0
larti:	dc.w	0
hgauch: dc.l	0
hdroit: dc.l	0
tgauch: dc.l	0
tdroit: dc.l	0
tgauch1: dc.l	 0
tdroit1: dc.l	 0
lampaf: dc.l	0
lampa:	dc.l	0
hpot:	dc.l	0
tpot:	dc.l	0
	blk.l	5,0
preti:	blk.l	14,0
tigdat: blk.l	500,0

;	A3=COORBAS  A5=ZAFEVT
AVPNTR: MOVE.L	#RODEQU,A0
	CLR.W	D0
	MOVE.B	1(A5),D0
	MOVE.W	D0,D1
	MOVE.W	D0,D3
	LSR.W	#2,D1
	LSL.W	#1,D3
	SUB.W	D1,D0
	BEQ	FAVPNTR
	MOVE.W	6(A5),D2
	MOVE.W	D2,2(A0)

	MOVE.W	6+8(A5),D5
	MOVE.W	D5,4(A0)
	ADD.W	D3,D5
	MOVE.W	D5,6(A0)
	SUB.W	D3,D2
	MOVE.W	D2,(A0)
	MOVE.W	D0,D7
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	COT1
	MOVE.L	#RODEQU,A0
	MOVE.W	#14*8,D6
	MOVEM.L D0/D1/D5/D7/A5,-(SP)
	BSR	XPOLY
	MOVEM.L (SP)+,D0/D1/D5/D7/A5
	MOVE.L	#RODEQU+4,A0
	MOVE.W	#14*8,D6
	MOVEM.L D0/D1/A5,-(SP)
	BSR	XPOLY
	MOVEM.L (SP)+,D0/D1/A5
COT1:	
	MOVE.W	D1,D7
	MOVE.W	2(A5),D5
	SUB.W	D0,D5
	BSR	CLIVECT
	BRA.S	FAVPNTR
	MOVE.L	#RODEQU,A0
	MOVE.W	6(A0),2(A0)
	MOVE.W	#14*8,D6
	MOVE.L	A5,-(SP)
	BSR	XPOLY
	MOVE.L	(SP)+,A5
FAVPNTR: RTS
;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARPNTR: 
	CMP.L	#-1,8(A4)
	BNE.S	AVAR7
	SUB.W	#255+64,6(A4)
	ADD.W	#255+64,6+8(A4)
AVAR7:	LEA.L	preti(PC),A3
	CLR.W	D7
	MOVE.B	1(A4),D7
	MOVE.W	D7,D6
	MOVE.W	D6,D5
	LSL.W	#1,D6
	LSR.W	#2,D5

	CLR.W	D4
	MOVE.B	1(A5),D4
	MOVE.W	D4,D3
	MOVE.W	D3,D2
	LSL.W	#1,D3
	LSR.W	#2,D2

	MOVE.W	2(A4),D0
	SUB.W	D7,D0
	MOVE.W	D0,(A3)+
	ADD.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	2(A5),D0
	SUB.W	D4,D0
	MOVE.W	D0,(A3)+
	ADD.W	D2,D0
	MOVE.W	D0,(A3)+

	MOVE.W	6(A4),D0
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6+8(A4),D0
	MOVE.W	D0,(A3)+
	ADD.W	D6,D0
	MOVE.W	D0,(A3)+

	MOVE.W	6(A5),D0
	SUB.W	D3,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6+8(A5),D0
	MOVE.W	D0,(A3)+
	ADD.W	D3,D0
	MOVE.W	D0,(A3)

	LEA.L	preti(PC),A3
;PREM BLOC
APO1:	LEA.L	preti+20(PC),A2
	MOVE.W	#6*8,(A2)+
	MOVE.W	6(A4),D1
	CMP.W	6(A5),D1
	BGE.S	APO2
	MOVE.W	6(A5),(A2)+	   ;5
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;1
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;1
	MOVE.W	2(A4),(A2)+
	MOVE.W	#14*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC5
	MOVE.W	#16*4,-2(A2)
BRDC5:	MOVE.W	D1,(A2)+ ;1-5
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;5
	BSR	TRLIG
;BLOC 2
APO2:	LEA.L	preti+20(PC),A2
	MOVE.W	#6*8,(A2)+
	MOVE.W	10(A3),D0
	CMP.W	16(A3),D0
	BLE.S	APO3
	MOVE.W	D0,(A2)+ ;2
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	16(A3),(A2)+	    ;6
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	16(A3),(A2)+	    ;6
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;2-6
	MOVE.W	2(A5),(A2)+
	MOVE.W	#14*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC6
	MOVE.W	#15*4,-2(A2)
BRDC6:	MOVE.L	22(A3),(A2)	;2
	BSR	TRLIG
;BLOC 3
APO3:	CLR.W	-2(A3)
	LEA.L	preti+20(PC),A2
	MOVE.W	#7*8,(A2)+
	MOVE.W	8(A3),D0
	CMP.W	14(A3),D0
	BLE.S	APO4
;	MOVE.W	#1,-2(A3)
	MOVE.W	D0,(A2)+ ;9
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	14(A3),(A2)+	    ;11
	MOVE.W	2(A5),(A2)+
	MOVE.W	#1*4,(A2)+
	MOVE.W	14(A3),(A2)+	    ;13
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;15
	MOVE.W	(A3),(A2)+
	MOVE.W	#1*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC7
	MOVE.W	#12*4,-2(A2)
BRDC7:	MOVE.L	22(A3),(A2)	;9
	BSR	TRLIG
; BLOC 4
APO4:	LEA.L	preti+20(PC),A2
	MOVE.W	#7*8,(A2)+
	MOVE.W	18(A3),D1
	CMP.W	12(A3),D1
	BLE.S	APO5
;	MOVE.W	#1,-2(A3)
	MOVE.W	D1,(A2)+ ;12
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	12(A3),(A2)+	    ;10
	MOVE.W	2(A4),(A2)+
	MOVE.W	#1*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC8
	MOVE.W	#13*4,-2(A2)
BRDC8:	MOVE.W	12(A3),(A2)+	    ;16
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;14
	MOVE.W	4(A3),(A2)+
	MOVE.W	#1*4,(A2)+
	MOVE.L	22(A3),(A2)	;12
	BSR	TRLIG
;BLOC 5
APO5:	MOVE.W	6(A5),D0
	MOVE.L	#RODEQU,A0
	MOVE.W	6(A4),(A0)
	CMP.L	#-1,8(A4)
	BNE.S	BRDC9
	CLR.W	(A0)
BRDC9:	MOVE.W	D0,2(A0)
	CMP.W	6(A4),D0
	BLE.S	APO6
	MOVE.W	2(A5),D7
	SUB.W	6(A3),D7
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	APO7
	MOVE.L	#RODEQU,A0
	MOVE.W	#6*8,D6
	MOVEM.L A3-A5,-(SP)
	BSR	XPOLY
	MOVEM.L (SP)+,A3-A5
APO6:	MOVE.W	10(A3),D0
	MOVE.L	#RODEQU+4,A0
	MOVE.W	16(A3),(A0)
	MOVE.W	D0,2(A0)
	CMP.L	#-1,8(A4)
	BNE.S	BRDCA
	MOVE.W	#319,2(A0)
BRDCA:	CMP.W	16(A3),D0
	BLE.S	APO7
	MOVE.W	2(A5),D7
	SUB.W	6(A3),D7
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	APO7
	MOVE.L	#RODEQU+4,A0
	MOVE.W	#6*8,D6
	MOVEM.L A3-A5,-(SP)
	BSR	XPOLY
	MOVEM.L (SP)+,A3-A5
APO7:	MOVE.W	6(A3),D0
	CMP.W	2(A3),D0
	BLT.S	FARPNTR
;	TST.W	-2(A3)
;	BNE.S	FARPNTR
	MOVE.L	#RODEQU,A0
	MOVE.W	6(A0),2(A0)
	MOVE.W	6(A3),D7
	SUB.W	2(A3),D7
	MOVE.W	6(A3),D5
	BSR	CLIVECT
	BRA.S	FARPNTR
	MOVE.L	#RODEQU,A0
	MOVE.W	#6*8,D6
	MOVEM.L A3-A5,-(SP)
	BSR	XPOLY
	MOVEM.L (SP)+,A3-A5
FARPNTR: RTS

;	A3=COORBAS  A5=ZAFEVT
AVPONT: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D1,D0
	LSR.W	#2,D0
	BEQ	FAVPONT
	SUB.W	D0,D1
	MOVE.W	6(A5),D2
	LEA.L	1000(A1),A0
	MOVE.W	D0,D7
	MOVEQ	#1,D6
	BSR	CHLVER
	MOVE.L	A1,A0
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#2,D6
	MOVE.W	10(A3),D2
	ADD.W	D2,D2
	SUBQ.W	#2,D2
	MOVE.W	6(A5),D4
	SUB.W	D2,D4
	BSR	CHLHOR
	MOVE.W	D0,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	PAV1
	MOVE.W	#13*8,D6
	MOVEM.L D0/D1/A1/A3/A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,D0/D1/A1/A3/A5
PAV1:	
	MOVE.W	6+8(A5),D2
	MOVE.W	10(A3),D3
	ADD.W	D3,D3
	SUBQ.W	#2,D3
	MOVE.W	D2,D4
	ADD.W	D3,D4
	MOVE.L	A1,A0
	MOVE.W	D0,D7
	MOVEQ	#-1,D6
	BSR	CHLVER
	LEA.L	1000(A1),A0
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#-2,D6
	BSR	CHLHOR
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	FAVPONT
	MOVE.W	#13*8,D6
	MOVE.L	A5,-(SP)
	BSR	POLY
	MOVE.L	(SP)+,A5
FAVPONT: RTS

;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARPONT: 
	CMP.L	#-1,8(A4)
	BNE.S	AVAR1
	SUB.W	#255+64,6(A4)
	ADD.W	#255+64,6+8(A4)
AVAR1:	LEA.L	preti-20(PC),A3
	CLR.W	D7
	MOVE.B	1(A4),D7
	ADDQ.W	#1,D7
	MOVE.W	D7,D6
	MOVE.W	D6,D5
	ADD.W	D6,D6
	ADD.W	D7,D6
	LSR.W	#2,D6
	BEQ.S	FAVPONT
	SUB.W	D6,D5
	CLR.W	D4
	MOVE.B	1(A5),D4
	ADDQ.W	#1,D4
	MOVE.W	D4,D3
	MOVE.W	D3,D2
	ADD.W	D3,D3
	ADD.W	D4,D3
	LSR.W	#2,D3
	SUB.W	D3,D2

	MOVE.W	2(A4),D0
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	2(A5),D0
	SUB.W	D3,D0
	MOVE.W	D0,(A3)+
	SUB.W	D2,D0
	MOVE.W	D0,(A3)+

	MOVE.W	6(A4),D0
	SUB.W	D7,D0
	SUB.W	D7,D0
	ADDQ.W	#2,D0
	MOVE.W	D0,(A3)+
	ADD.W	D6,D0
	ADD.W	D6,D0
	ADD.W	D5,D0
	ADD.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	D6,D0
	LSR.W	#1,D0
	ADD.W	6(A4),D0
	MOVE.W	D0,(A3)+
	SUBQ.W	#1,D7
	MOVE.W	6+8(A4),D0
	MOVE.W	D0,(A3)+
	MOVE.W	D0,D1
	ADD.W	D7,D0
	ADD.W	D7,D0
	MOVE.W	D0,(A3)+
	SUB.W	D6,D0
	SUB.W	D6,D0
	SUB.W	D5,D0
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	D6,D0
	LSR.W	#1,D0
	NEG.W	D0
	ADD.W	D1,D0
	MOVE.W	D0,(A3)+

	MOVE.W	6(A5),D0
	SUB.W	D4,D0
	SUB.W	D4,D0
	ADDQ.W	#2,D0
	MOVE.W	D0,(A3)+
	ADD.W	D3,D0
	ADD.W	D3,D0
	ADD.W	D2,D0
	ADD.W	D2,D0
	MOVE.W	D0,(A3)+
	MOVE.W	D3,D0
	LSR.W	#1,D0
	ADD.W	6(A5),D0
	MOVE.W	D0,(A3)+
	SUBQ.W	#1,D4
	MOVE.W	6+8(A5),D0
	MOVE.W	D0,(A3)+
	MOVE.W	D0,D1
	ADD.W	D4,D0
	ADD.W	D4,D0
	MOVE.W	D0,(A3)+
	SUB.W	D3,D0
	SUB.W	D3,D0
	SUB.W	D2,D0
	SUB.W	D2,D0
	MOVE.W	D0,(A3)+
	MOVE.W	D3,D0
	LSR.W	#1,D0
	NEG.W	D0
	ADD.W	D1,D0
	MOVE.W	D0,(A3)

	LEA.L	preti-20(PC),A3
;PREM BLOC
APON1:	LEA.L	preti+20(PC),A2
	MOVE.W	#11*8,(A2)+
	MOVE.W	2(A4),D1
	SUB.W	2(A5),D1
	ASR.W	#1,D1
	ADD.W	6(A4),D1
	CMP.W	6(A5),D1
	BGE.S	APON2
	MOVE.W	6(A5),(A2)+	   ;9
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;1
	MOVE.W	2(A4),(A2)+
	MOVE.W	#2*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC0
	MOVE.W	#13*4,-2(A2)
BRDC0:	MOVE.W	12(A3),(A2)+	    ;5
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	26(A3),(A2)+		 ;15
	MOVE.W	4(A3),(A2)+
	MOVE.W	#2*4,(A2)+
	MOVE.L	22+20(A3),(A2)	   ;9
	BSR	TRLIG
;BLOC 2
APON2:	LEA.L	preti+20(PC),A2
	MOVE.W	#10*8,(A2)+
	MOVE.W	2(A5),D0
	SUB.W	2(A4),D0
	ASR.W	#1,D0
	ADD.W	14(A3),D0
	CMP.W	28(A3),D0
	BLE.S	APON3
	MOVE.W	14(A3),(A2)+		 ;3
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	28(A3),(A2)+		 ;11
	MOVE.W	2(A5),(A2)+
	MOVE.W	#3*4,(A2)+
	MOVE.W	34(A3),(A2)+		 ;16
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	20(A3),(A2)+		 ;6
	MOVE.W	(A3),(A2)+
	MOVE.W	#3*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC1
	MOVE.W	#12*4,-2(A2)
BRDC1:	MOVE.L	22+20(A3),(A2)		;3
	BSR	TRLIG
;BLOC 3
APON3:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	4(A3),D0
	CMP.W	(A3),D0
	BLT.S	APON4
	MOVE.W	26(A3),(A2)+		 ;15
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	12(A3),(A2)+		 ;5
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	20(A3),(A2)+		 ;6
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	34(A3),(A2)+		 ;16
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.L	22+20(A3),(A2)	   ;15
	BSR	TRLIG
; BLOC 4
APON4:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	2(A4),D1
	SUB.W	2(A5),D1
	ADD.W	D1,D1
	ADD.W	8(A3),D1
	CMP.W	22(A3),D1
	BLE.S	APON5
	MOVE.W	8(A3),(A2)+	   ;2
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	22(A3),(A2)+		 ;10
	MOVE.W	2(A5),(A2)+
	MOVE.W	#9*4,(A2)+
	MOVE.W	24(A3),(A2)+		 ;13
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	10(A3),(A2)+		 ;7
	MOVE.W	2(A3),(A2)+
	MOVE.W	#9*4,(A2)+
	MOVE.L	22+20(A3),(A2)	   ;2
	BSR	TRLIG
;BLOC 5
APON5:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	2(A5),D0
	SUB.W	2(A4),D0
	ADD.W	D0,D0
	ADD.W	16(A3),D0
	CMP.W	30(A3),D0
	BGE.S	APON6
	MOVE.W	30(A3),(A2)+		 ;12
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	16(A3),(A2)+		 ;4
	MOVE.W	2(A4),(A2)+
	MOVE.W	#6*4,(A2)+
	MOVE.W	18(A3),(A2)+		 ;8
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	32(A3),(A2)+		 ;14
	MOVE.W	6(A3),(A2)+
	MOVE.W	#6*4,(A2)+
	MOVE.L	22+20(A3),(A2)	   ;12
	BSR	TRLIG
;BLOC 6
APON6:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	2(A3),D0
	CMP.W	6(A3),D0
	BLT.S	FAPON
	MOVE.W	10(A3),(A2)+		 ;7
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	24(A3),(A2)+		 ;13
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	32(A3),(A2)+		 ;14
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	18(A3),(A2)+		 ;8
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.L	22+20(A3),(A2)	   ;7
	BSR	TRLIG
FAPON:	RTS

;	A3=COORBAS  A5=ZAFEVT
AVTRBD: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D1
	MOVE.W	D1,D3
	LSR.W	#1,D3
	MOVE.W	D3,D5
	LSR.W	#1,D5
	MOVE.L	A1,A0
	MOVE.W	D5,D6
	MOVE.W	6(A5),D2
	CMP.W	#319,D2
	BGT.S	PTRID
	BSR	CREALVM
	MOVE.W	D2,D4
	MOVEQ	#4,D6
	MOVE.W	D3,D7
	BSR	CHLHOR
	LEA.L	1000(A1),A0
	MOVE.W	D3,D6
	ADD.W	D5,D6
	MOVE.W	D6,D7
	ADD.W	D1,D1
	ADD.W	6(A5),D1
	BLT.S	PTRID
	MOVE.W	D1,D2
	BSR	CREALVM
	MOVE.W	2(A5),D5
	MOVE.L	A1,A0
	BSR	CLIVECT
	BRA.S	PTRID
	MOVE.W	#2*8,D6
	MOVE.L	A5,-(SP)
	BSR	POLY
	MOVE.L	(SP)+,A5
PTRID:	RTS
;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARTRBD: 
	CMP.L	#-1,8(A4)
	BNE.S	AVAR2
	ADD.W	#255*3,6(A4)
AVAR2:	LEA.L	preti(PC),A3
	CMP.W	#319,6(A5)
	BGT.S	PTRID
	CLR.W	D7
	MOVE.B	1(A4),D7
	ADDQ.W	#1,D7
	MOVE.W	D7,D6
	LSR.W	#1,D6
	MOVE.W	D6,D5
	LSR.W	#1,D5
	CLR.W	D4
	MOVE.B	1(A5),D4
	ADDQ.W	#1,D4
	MOVE.W	D4,D3
	LSR.W	#1,D3
	MOVE.W	D3,D2
	LSR.W	#1,D2
	MOVE.W	2(A4),D0
	MOVE.W	D0,D1
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	SUB.W	D7,D1
	MOVE.W	D1,(A3)+
	ADD.W	D7,D7
	ADD.W	6(A4),D7
	BLT.S	PTRID
	MOVE.W	D7,(A3)+
	MOVE.W	2(A5),D0
	MOVE.W	D0,D1
	SUB.W	D2,D0
	MOVE.W	D0,(A3)+
	SUB.W	D3,D0
	MOVE.W	D0,(A3)+
	SUB.W	D4,D1
	MOVE.W	D1,(A3)+
	ADD.W	D4,D4
	ADD.W	6(A5),D4
	MOVE.W	D4,(A3)
	LEA.L	preti(PC),A3
;PREM BLOC
ATRD1:	LEA.L	preti+20(PC),A2
	MOVE.W	#10*8,(A2)+
	MOVE.W	6(A4),D0
	MOVE.W	6(A5),D1
	CMP.W	D1,D0
	BLE.S	ATRD2
	MOVE.W	D0,(A2)+ ;1
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;5
	MOVE.W	2(A5),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D1,(A2)+ ;6
	MOVE.W	8(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;4
	MOVE.W	(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;1
	BSR	TRLIG
;BLOC 2
ATRD2:	LEA.L	preti+20(PC),A2
	MOVE.W	#11*8,(A2)+
	MOVE.W	(A3),D0
	SUB.W	8(A3),D0
	ASL.W	#2,D0
	ADD.W	6(A4),D0
	CMP.W	6(A5),D0
	BLE.S	ATRD3
	MOVE.W	6(A4),(A2)+	   ;4
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;6
	MOVE.W	8(A3),(A2)+
	MOVE.W	#44,(A2)+
	MOVE.W	14(A3),(A2)+		 ;7
	MOVE.W	10(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A3),(A2)+	   ;3
	MOVE.W	2(A3),(A2)+
	MOVE.W	#44,(A2)+
	MOVE.L	22(A3),(A2)	;4
	BSR	TRLIG
;BLOC 3
ATRD3:	LEA.L	preti+20(PC),A2
	MOVE.W	#14*8,(A2)+
	MOVE.W	6(A3),D0
	MOVE.W	14(A3),D1
	CMP.W	D1,D0
	BLE.S	ATRD4
	MOVE.W	D0,(A2)+ ;3
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;7
	MOVE.W	10(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D1,(A2)+ ;11
	MOVE.W	12(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;8
	MOVE.W	4(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;3
	BSR	TRLIG
;BLOC 4
ATRD4:	LEA.L	preti+20(PC),A2
	MOVE.W	#13*8,(A2)+
	MOVE.W	12(A3),D0
	CMP.W	4(A3),D0
	BLE.S	FATRD
	MOVE.W	6(A3),(A2)+	   ;8
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	14(A3),(A2)+		 ;11
	MOVE.W	12(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;10
	MOVE.W	12(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;9
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;8
	BSR	TRLIG
FATRD:	RTS

;	A3=COORBAS  A5=ZAFEVT
AVTRBG: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D1
	MOVE.W	D1,D3
	LSR.W	#1,D3
	MOVE.W	D3,D5
	LSR.W	#1,D5
	LEA.L	1000(A1),A0
	MOVE.W	D5,D6
	MOVE.W	6(A5),D2
	BLT.S	FATRD
	BSR	CREALVM
	MOVE.W	D2,D4
	MOVEQ	#-4,D6
	MOVE.W	D3,D7
	BSR	CHLHOR
	MOVE.L	A1,A0
	MOVE.W	D3,D6
	ADD.W	D5,D6
	MOVE.W	D6,D7
	ADD.W	D1,D1
	MOVE.W	6(A5),D3
	SUB.W	D1,D3
	CMP.W	#319,D3
	BGT.S	FATRD
	MOVE.W	D3,D2
	BSR	CREALVM
	MOVE.W	2(A5),D5
	MOVE.L	A1,A0
	BSR	CLIVECT
	BRA.S	PTRIG
	MOVE.W	#2*8,D6
	MOVE.L	A5,-(SP)
	BSR	POLY
	MOVE.L	(SP)+,A5
PTRIG:	RTS
;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARTRBG:	
	CMP.L	#-1,8(A4)
	BNE.S	AVAR3
	SUB.W	#255*3,6(A4)
AVAR3:	LEA.L	preti(PC),A3
	TST.W	6(A5)
	BLT.S	PTRIG
	CLR.W	D7
	MOVE.B	1(A4),D7
	ADDQ.W	#1,D7
	MOVE.W	D7,D6
	LSR.W	#1,D6
	MOVE.W	D6,D5
	LSR.W	#1,D5
	CLR.W	D4
	MOVE.B	1(A5),D4
	ADDQ.W	#1,D4
	MOVE.W	D4,D3
	LSR.W	#1,D3
	MOVE.W	D3,D2
	LSR.W	#1,D2
	MOVE.W	2(A4),D0
	MOVE.W	D0,D1
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	SUB.W	D7,D1
	MOVE.W	D1,(A3)+
	ADD.W	D7,D7
	MOVE.W	6(A4),D0
	SUB.W	D7,D0
	CMP.W	#319,D0
	BGT.S	PTRIG
	MOVE.W	D0,(A3)+
	MOVE.W	2(A5),D0
	MOVE.W	D0,D1
	SUB.W	D2,D0
	MOVE.W	D0,(A3)+
	SUB.W	D3,D0
	MOVE.W	D0,(A3)+
	SUB.W	D4,D1
	MOVE.W	D1,(A3)+
	MOVE.W	6(A5),D0
	ADD.W	D4,D4
	SUB.W	D4,D0
	MOVE.W	D0,(A3)
	LEA.L	preti(PC),A3
;PREM BLOC
ATRG1:	LEA.L	preti+20(PC),A2
	MOVE.W	#10*8,(A2)+
	MOVE.W	6(A4),D0
	MOVE.W	6(A5),D1
	CMP.W	D1,D0
	BGE.S	ATRG2
	MOVE.W	D1,(A2)+ ;5
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;1
	MOVE.W	2(A4),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D0,(A2)+ ;4
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;6
	MOVE.W	8(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;5
	BSR	TRLIG
;BLOC 2
ATRG2:	LEA.L	preti+20(PC),A2
	MOVE.W	#11*8,(A2)+
	MOVE.W	8(A3),D0
	SUB.W	(A3),D0
	ASL.W	#2,D0
	ADD.W	6(A4),D0
	CMP.W	6(A5),D0
	BGE.S	ATRG3
	MOVE.W	6(A5),(A2)+	   ;6
	MOVE.W	8(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;4
	MOVE.W	(A3),(A2)+
	MOVE.W	#16,(A2)+
	MOVE.W	6(A3),(A2)+	   ;3
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	14(A3),(A2)+		 ;7
	MOVE.W	10(A3),(A2)+
	MOVE.W	#16,(A2)+
	MOVE.L	22(A3),(A2)	;6
	BSR	TRLIG
;BLOC 3
ATRG3:	LEA.L	preti+20(PC),A2
	MOVE.W	#14*8,(A2)+
	MOVE.W	6(A3),D0
	MOVE.W	14(A3),D1
	CMP.W	D1,D0
	BGE.S	ATRG4
	MOVE.W	D1,(A2)+ ;7
	MOVE.W	10(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;3
	MOVE.W	2(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D0,(A2)+ ;8
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D1,(A2)+ ;11
	MOVE.W	12(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;7
	BSR	TRLIG
;BLOC 4
ATRG4:	LEA.L	preti+20(PC),A2
	MOVE.W	#13*8,(A2)+
	MOVE.W	12(A3),D0
	CMP.W	4(A3),D0
	BLE.S	FATRG
	MOVE.W	14(A3),(A2)+		 ;11
	MOVE.W	12(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A3),(A2)+	   ;8
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;9
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;10
	MOVE.W	12(A3),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;11
	BSR	TRLIG
FATRG:	RTS

;	A3=COORBAS  A5=ZAFEVT
AVGARA: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D0
	MOVE.W	D0,D1
	MOVE.W	D1,D3
	LSR.W	#4,D3
	ADD.W	D1,D1
	ADD.W	D1,D1
	ADD.W	D0,D1
	LSR.W	#3,D1
	MOVE.L	A1,A0
	MOVE.W	D1,D6
	SUB.W	D3,D6
	SUBQ.W	#1,D6
	MOVE.W	6(A5),D2
	ADD.W	D0,D2
	BSR	CREALVM
	MOVE.W	D3,D6
	ADDQ.W	#2,D6
	MOVE.W	6(A5),D2
	CMP.W	#319,D2
	BGT.S	PGAR
	BSR	CREALVM
	LEA.L	1000(A1),A0
	ADD.W	D0,D2
	ADD.W	D1,D2
	MOVE.W	D2,D4
	BLT.S	PGAR
	MOVEQ	#-1,D6
	ADDQ.W	#1,D1
	MOVE.W	D1,D7
	BSR	CHLHOR
	MOVE.W	D1,D7
	MOVE.W	2(A5),D5
	MOVE.L	A1,A0
	BSR	CLIVECT
	RTS
	MOVE.W	#10*8,D6
	MOVE.L	A5,-(SP)
	BSR	POLY
	MOVE.L	(SP)+,A5
PGAR:	RTS
;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARGARA:
	CMP.L	#-1,8(A4)
	BNE.S	AVAR4
	ADD.W	#255,6(A4)
AVAR4:	LEA.L	preti(PC),A3
	CMP.W	#319,6(A5)
	BGT.S	PGAR
	CLR.W	D7
	MOVE.B	1(A4),D7
	MOVE.W	D7,D6
	MOVE.W	D6,D5
	LSR.W	#4,D5
	ADD.W	D6,D6
	ADD.W	D6,D6
	ADD.W	D7,D6
	LSR.W	#3,D6
	CLR.W	D4
	MOVE.B	1(A5),D4
	MOVE.W	D4,D3
	MOVE.W	D3,D2
	LSR.W	#4,D2
	ADD.W	D3,D3
	ADD.W	D3,D3
	ADD.W	D4,D3
	LSR.W	#3,D3
	MOVE.W	2(A4),D0
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	ADD.W	D5,D0
	MOVE.W	D0,(A3)+
	ADD.W	6(A4),D7
	MOVE.W	D7,(A3)+
	ADD.W	D6,D7
	BLT.S	PGAR
	MOVE.W	D7,(A3)+
	MOVE.W	2(A5),D0
	SUB.W	D3,D0
	MOVE.W	D0,(A3)+
	ADD.W	D2,D0
	MOVE.W	D0,(A3)+
	ADD.W	6(A5),D4
	MOVE.W	D4,(A3)+
	ADD.W	D3,D4
	MOVE.W	D4,(A3)

	LEA.L	preti(PC),A3
;PREM BLOC
AGAR1:
	MOVE.L	#RODEQU,A0
	MOVE.W	2(A5),D6
	SUB.W	8(A3),D6
	MOVE.W	D6,D7
	MOVE.W	12(A3),D2
	BSR	CREALVM
	MOVE.L	#RODEQU+1000,A0
	MOVE.W	14(A3),D2
	MOVEQ	#-1,D6
	MOVE.W	D7,D0
	BSR	CHLHOR
	MOVE.W	D0,D7
	MOVE.W	2(A5),D5
	MOVE.L	#RODEQU,A0
	BSR	CLIA4
	BRA.S	AGAR2
	MOVE.W	#10*8,D6
	MOVEM.L A3-A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,A3-A5
;BLOC 2
AGAR2:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	6(A3),D0
	ADD.W	2(A5),D0
	SUB.W	2(A4),D0
	CMP.W	14(A3),D0
	BLE.S	AGAR3
	MOVE.W	6(A3),D0
	MOVE.W	D0,(A2)+ ;2
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	14(A3),(A2)+		 ;8
	MOVE.W	2(A5),(A2)+
	MOVE.W	#28,(A2)+
	MOVE.W	12(A3),(A2)+		 ;9
	MOVE.W	8(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	4(A3),(A2)+	   ;3
	MOVE.W	(A3),(A2)+
	MOVE.W	#28,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC2
	MOVE.W	#12*4,-2(A2)
BRDC2:	MOVE.L	22(A3),(A2)	;2
	BSR	TRLIG
;BLOC 3
AGAR3:	LEA.L	preti+20(PC),A2
	MOVE.W	#11*8,(A2)+
	MOVE.W	10(A3),D0
	MOVE.W	2(A3),D1
	CMP.W	D1,D0
	BLT.S	AGAR4
	SUBQ.W	#1,D1
	MOVE.W	12(A3),(A2)+		 ;12
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;11
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;5
	MOVE.W	D1,(A2)+
	CLR.W	(A2)+
	MOVE.W	4(A3),(A2)+	   ;6
	MOVE.W	D1,(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;12
	BSR	TRLIG
;BLOC 4
AGAR4:	LEA.L	preti+20(PC),A2
	MOVE.W	#5*8,(A2)+
	MOVE.W	6(A4),D0
	CMP.W	6(A5),D0
	BLE.S	AGAR5
	MOVE.W	D0,(A2)+ ;5
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;11
	MOVE.W	10(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	6(A5),(A2)+	   ;10
	MOVE.W	8(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;4
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;5
	BSR	TRLIG
;BLOC 5
AGAR5:	LEA.L	preti+20(PC),A2
	MOVE.W	#5*8,(A2)+
	MOVE.W	4(A3),D0
	CMP.W	12(A3),D0
	BGE.S	FAGAR
	MOVE.W	12(A3),(A2)+		 ;12
	MOVE.W	10(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;6
	MOVE.W	2(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D0,(A2)+ ;3
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	12(A3),(A2)+		 ;9
	MOVE.W	8(A3),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;12
	BSR	TRLIG
FAGAR:	RTS

;	A3=COORBAS  A5=ZAFEVT
AVPNT2: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D1,D0
	LSR.W	#3,D0
	BEQ.S	FAGAR
	LSR.W	#3,D1
	ADDQ.W	#1,D1
	MOVE.W	6(A5),D4
	LEA.L	1000(A1),A0
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#-1,D6
	BSR	CHLHOR
	MOVE.L	A1,A0
	MOVE.W	10(A3),D2
	ADD.W	D2,D2
	ADD.W	10(A3),D2
	ADD.W	D0,D2
	ADD.W	D1,D2
	MOVE.W	6(A5),D4
	SUB.W	D2,D4
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#4,D6
	BSR	CHLHOR
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	PAN1
	MOVE.W	#3*8,D6
	MOVEM.L D0/D1/A1/A3/A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,D0/D1/A1/A3/A5
PAN1:	
	MOVE.L	A1,A0
	MOVE.W	6+8(A5),D2
	MOVE.W	D2,D4
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#1,D6
	BSR	CHLHOR
	LEA.L	1000(A1),A0
	MOVE.W	10(A3),D7
	ADD.W	D7,D7
	ADD.W	10(A3),D7
	ADD.W	D1,D7
	ADD.W	D0,D7
	MOVE.W	D2,D4
	ADD.W	D7,D4
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVEQ	#-4,D6
	BSR	CHLHOR
	MOVE.W	D0,D7
	ADD.W	D1,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	BSR	CLIVECT
	BRA.S	PAN2
	MOVE.W	#3*8,D6
	MOVEM.L D0/D1/D2/A1/A3/A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,D0/D1/D2/A1/A3/A5
PAN2:
	MOVE.W	6(A5),D4
	MOVE.L	A1,A0
	SUB.W	D0,D4
	MOVE.W	D1,D7
	MOVEQ	#-1,D6
	BSR	CHLHOR
	LEA.L	1000(A1),A0
	MOVE.W	D2,D4
	ADD.W	D0,D4
	MOVE.W	D1,D7
	MOVEQ	#1,D6
	BSR	CHLHOR
	MOVE.W	D1,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	SUB.W	D0,D5
	BSR	CLIVECT
	BRA.S	FAVPT2
	MOVE.W	#11*8,D6
	MOVE.L	A5,-(SP)
	BSR	POLY
	MOVE.L	(SP)+,A5
FAVPT2: RTS
;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARPNT2: 
	CMP.L	#-1,8(A4)
	BNE.S	AVAR5
	SUB.W	#255+64,6(A4)
	ADD.W	#255+64,6+8(A4)
AVAR5:	LEA.L	preti(PC),A3
	CLR.W	D7
	MOVE.B	1(A4),D7
	ADDQ.W	#1,D7
	MOVE.W	D7,D6
	ADD.W	D7,D7
	ADD.W	D7,D7
	ADD.W	D6,D7
	LSR.W	#3,D7
	BEQ.S	FAVPT2
	LSR.W	#3,D6
	CLR.W	D5
	MOVE.B	1(A5),D5
	ADDQ.W	#1,D5
	MOVE.W	D5,D4
	ADD.W	D5,D5
	ADD.W	D5,D5
	ADD.W	D4,D5
	LSR.W	#3,D5
	LSR.W	#3,D4

	MOVE.W	2(A4),D0
	SUB.W	D7,D0
	MOVE.W	D0,(A3)+
	MOVE.W	2(A5),D0
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6+8(A4),D0
	MOVE.W	D0,(A3)+
	ADD.W	D7,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6(A4),D0
	SUB.W	D7,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6+8(A5),D0
	MOVE.W	D0,(A3)+
	ADD.W	D5,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6(A5),D0
	SUB.W	D5,D0
	MOVE.W	D0,(A3)	

	LEA.L	preti(PC),A3
;PREM BLOC
APT21:	LEA.L	preti+20(PC),A2
	MOVE.W	#13*8,(A2)+
	MOVE.W	6(A4),D1
	ADD.W	2(A5),D1
	SUB.W	2(A4),D1
	CMP.W	6(A5),D1
	BGE.S	APT22
	MOVE.W	6(A5),(A2)+	   ;2
	MOVE.W	2(A5),(A2)+
	CLR.W	(A2)  +
	MOVE.W	6(A4),(A2)+	   ;1
	MOVE.W	2(A4),(A2)+
	MOVE.W	#7*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC3
	MOVE.W	#13*4,-2(A2)
BRDC3:	MOVE.W	8(A3),(A2)+	   ;5
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	14(A3),(A2)+		 ;6
	MOVE.W	2(A3),(A2)+
	MOVE.W	#7*4,(A2)+
	MOVE.L	22(A3),(A2)	;2
	BSR	TRLIG
;BLOC 2
APT22:	LEA.L	preti+20(PC),A2
	MOVE.W	#13*8,(A2)+
	MOVE.W	4(A3),D0
	ADD.W	2(A4),D0
	SUB.W	2(A5),D0
	CMP.W	10(A3),D0
	BLE.S	APT23
	MOVE.W	4(A3),(A2)+	   ;3
	MOVE.W	2(A4),(A2)+
	CLR.W	(A2)+
	MOVE.W	10(A3),(A2)+		 ;4
	MOVE.W	2(A5),(A2)+
	MOVE.W	#8*4,(A2)+
	MOVE.W	12(A3),(A2)+		 ;8
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A3),(A2)+	   ;7
	MOVE.W	(A3),(A2)+
	MOVE.W	#8*4,(A2)+
	CMP.L	#-1,8(A4)
	BNE.S	BRDC4
	MOVE.W	#12*4,-2(A2)
BRDC4:	MOVE.L	22(A3),(A2)	;3
	BSR	TRLIG
;BLOC 3
APT23:	LEA.L	preti+20(PC),A2
	MOVE.W	#10*8,(A2)+
	MOVE.W	(A3),D0
	CMP.W	2(A3),D0
	BGT.S	FAPT2
	MOVE.W	14(A3),(A2)+		 ;6
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	8(A3),(A2)+	   ;5
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A3),(A2)+	   ;7
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	12(A3),(A2)+		 ;8
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;6
	BSR	TRLIG
FAPT2:	RTS

;	A3=COORBAS  A5=ZAFEVT
AVPLAQ: MOVE.L	#RODEQU,A1
	MOVE.W	10(A3),D0
	MOVE.W	D0,D1
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	D1,D0
	LSR.W	#3,D0
	BEQ.S	FAPT2
	LSR.W	#3,D1
	MOVE.W	6(A5),D2
	MOVE.L	A1,A0
	MOVE.W	D1,D6
	BSR	CREALVM
	LEA.L	1000(A1),A0
	MOVE.W	6+8(A5),D2
	MOVE.W	D1,D6
	BSR	CREALVM
	MOVE.W	D1,D7
	MOVE.L	A1,A0
	MOVE.W	2(A5),D5
	SUB.W	D0,D5
	BSR	CLIVECT
	BRA.S	FAVPLA
	MOVE.W	#5*8,D6
	MOVEM.L D0/D1/A1/A3/A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,D0/D1/A1/A3/A5
FAVPLA: RTS

;	A4=ZAFEVT DEVANT	 A5=ZAFEVT DERR
ARPLAQ: 
	CMP.L	#-1,8(A4)
	BNE.S	AVAR6
	SUB.W	#255+128,6(A4)
	ADD.W	#255+128,6+8(A4)
AVAR6:	LEA.L	preti(PC),A3
	CLR.W	D7
	MOVE.B	1(A4),D7
	ADDQ.W	#1,D7
	MOVE.W	D7,D6
	ADD.W	D7,D7
	ADD.W	D7,D7
	ADD.W	D6,D7
	LSR.W	#3,D7
	BEQ.S	FAVPLA
	LSR.W	#3,D6

	CLR.W	D5
	MOVE.B	1(A5),D5
	ADDQ.W	#1,D5
	MOVE.W	D5,D4
	ADD.W	D5,D5
	ADD.W	D5,D5
	ADD.W	D4,D5
	LSR.W	#3,D5
	LSR.W	#3,D4

	MOVE.W	2(A4),D0
	SUB.W	D7,D0
	MOVE.W	D0,(A3)+
	SUB.W	D6,D0
	MOVE.W	D0,(A3)+
	MOVE.W	2(A5),D0
	SUB.W	D5,D0
	MOVE.W	D0,(A3)+
	SUB.W	D4,D0
	MOVE.W	D0,(A3)+
	MOVE.W	6+8(A4),(A3)+
	MOVE.W	6+8(A5),(A3)

	LEA.L	preti(PC),A3
;PREM BLOC
APLA1:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	4(A3),D1
	CMP.W	(A3),D1
	BLT.S	APLA2
	MOVE.W	6(A5),(A2)+	   ;4
	MOVE.W	D1,(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;1
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	8(A3),(A2)+	   ;2
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	10(A3),(A2)+		 ;3
	MOVE.W	D1,(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;4
	BSR	TRLIG
;BLOC 2
APLA2:	LEA.L	preti+20(PC),A2
	MOVE.W	#9*8,(A2)+
	MOVE.W	6(A5),D0
	CMP.W	6(A4),D0
	BGT.S	APLA3
	MOVE.W	6(A4),(A2)+	   ;1
	MOVE.W	(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;4
	MOVE.W	4(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	6(A5),(A2)+	   ;7
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A4),(A2)+	   ;5
	MOVE.W	2(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;1
	BSR	TRLIG
;BLOC 3
APLA3:	LEA.L	preti+20(PC),A2
	MOVE.W	#9*8,(A2)+
	MOVE.W	8(A3),D0
	CMP.W	10(A3),D0
	BGT.S	APLA4
	MOVE.W	10(A3),(A2)+		 ;3
	MOVE.W	4(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	D0,(A2)+ ;2
	MOVE.W	(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.W	D0,(A2)+ ;6
	MOVE.W	2(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	10(A3),(A2)+		 ;8
	MOVE.W	6(A3),(A2)+
	MOVE.W	#4,(A2)+
	MOVE.L	22(A3),(A2)	;3
	BSR	TRLIG
;BLOC 4
APLA4:	LEA.L	preti+20(PC),A2
	MOVE.W	#4*8,(A2)+
	MOVE.W	2(A3),D0
	CMP.W	6(A3),D0
	BLT.S	FAPLA
	MOVE.W	6(A4),(A2)+	   ;5
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.W	6(A5),(A2)+	   ;7
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	10(A3),(A2)+		 ;8
	MOVE.W	6(A3),(A2)+
	CLR.W	(A2)+
	MOVE.W	8(A3),(A2)+	   ;6
	MOVE.W	D0,(A2)+
	CLR.W	(A2)+
	MOVE.L	22(A3),(A2)	;7
	BSR	TRLIG
FAPLA:	RTS

TRLIG:	LEA.L	preti+22(PC),A2
	MOVE.L	A2,A1
	MOVE.L	#RODEQU,A0
	MOVE.W	#3,D0
	MOVE.W	2(A2),D6
	SUB.W	8(A2),D6
	BGE.S	PODEPB
	LEA.L	6(A2),A2
	MOVE.L	A2,A1
	MOVE.L	(A2),24(A2)
	MOVE.W	-2(A2),22(A2)
	MOVE.W	2(A2),D6
	SUB.W	8(A2),D6
	BRA.S	PODEPB
TRMONT: MOVE.W	2(A2),D6
	SUB.W	8(A2),D6
	BLT.S	TRDES1
PODEPB: BGT.S	S1TRMON
	TST.W	4(A2)
	BEQ.S	STRMONT
S1TRMON: MOVE.W  (A2),D2
	MOVE.W	6(A2),D5
	SUB.W	D2,D5
	MOVE.W	4(A2),D3
	JSR	RTTR(PC,D3.W)
STRMONT:
	LEA.L	6(A2),A2
	DBF	D0,TRMONT
ERROR:	RTS
TRDES1: LEA.L	18(A1),A2
	MOVE.L	#RODEQU+1000,A0
TRDESC: MOVE.W	8(A2),D6
	SUB.W	2(A2),D6
	BLT.S	ERROR	;A VIRER
	BGT.S	S1TRDE
	TST.W	4(A2)
	BEQ.S	STRDES
S1TRDE: MOVE.W	6(A2),D2
	MOVE.W	(A2),D5
	SUB.W	D2,D5
	MOVE.W	4(A2),D3
	JSR	RTTR(PC,D3.W)
STRDES: LEA.L	-6(A2),A2
	DBF	D0,TRDESC
;	 MOVE.W	-1002(A0),D7
;	 CMP.W	 -2(A0),D7
;	 BLE.S	 POINTO
;	 MOVE.W	D7,-2(A0)
POINTO: MOVE.L	A0,D7
	MOVE.L	#RODEQU,A0
	MOVE.W	2(A1),D5
	SUB.L	#RODEQU+1000,D7
	LSR.W	#1,D7
	BSR	CLIA4
	RTS
	MOVE.W	preti+20(PC),D6
	MOVEM.L A3-A5,-(SP)
	BSR	POLY
	MOVEM.L (SP)+,A3-A5
	RTS
RTTR:	BRA.L	CREAL
	BRA.L	CREALV
	BRA.L	RCHV1
	BRA.L	RCHVM1
	BRA.L	RCHHM4
	BRA.L	RCHHM3
	BRA.L	RCHHM2
	BRA.L	RCHHM1
	BRA.L	RCHH1
	BRA.L	RCHH2
	BRA.L	RCHH3
	BRA.L	RCHH4
	BRA.L	TTDRT
	BRA.L	TTGCH
	BRA.L	CREALVM
	BRA.L	TTDRTM
	BRA.L	TTGCHM
TTDRTM: SUBQ.W #1,D6
	BLT.S	FTTDG
TTDRT:	MOVE.W	#640,D2
	LSR.W	#1,D6
	BCC.S	B3LV
B2LV:	MOVE.W	D2,(A0)+
B3LV:	MOVE.W	D2,(A0)+
	DBF	D6,B2LV
FTTDG:	RTS
TTGCHM: SUBQ.W #1,D6
	BLT.S	FTTDG
TTGCH:	MOVE.W	#-320,D2
	LSR.W	#1,D6
	BCC.S	B5LV
B4LV:	MOVE.W	D2,(A0)+
B5LV:	MOVE.W	D2,(A0)+
	DBF	D6,B4LV
	RTS
RCHV1:	MOVE.W	D6,D7
	MOVEQ	#1,D6
	BRA	CHLVERB
RCHVM1: MOVE.W	D6,D7
	MOVEQ	#-1,D6
	BRA	CHLVERB
RCHHM4: MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#-4,D6
	BRA	CHLHORB
RCHHM3: MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#-3,D6
	BRA	CHLHORB
RCHHM2: MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#-2,D6
	BRA	CHLHORB
RCHHM1: MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#-1,D6
	BRA	CHLHORB
RCHH1:	MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#1,D6
	BRA	CHLHORB
RCHH2:	MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#2,D6
	BRA	CHLHORB
RCHH3:	MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#3,D6
	BRA	CHLHORB
RCHH4:	MOVE.W	D2,D4
	MOVE.W	D6,D7
	MOVEQ	#4,D6
	BRA	CHLHORB

CREALVM: SUBQ.W #1,D6
	BGE.S	CREALV
	RTS
CREALV: LSR.W	#1,D6
	BCC.S	B1LV
B0LV:	MOVE.W	D2,(A0)+
B1LV:	MOVE.W	D2,(A0)+
	DBF	D6,B0LV
	RTS

CREAL:	TST.W	D5
	BLT.S	CREALG
	BEQ.S	CREALVM
	ADDQ.W	#1,D5
	ADDQ.W	#1,D6
	CMP.W	D5,D6
	BGE.S	LVERD
	SUBQ.W	#1,D2
	EXT.L	D5
	LSL.W	#5,D5
	DIVU	D6,D5
	SUBQ.W	#2,D6
	MOVE.W	D5,D4
	LSR.W	#5,D5
	AND.W	#$1F,D4
	MOVEQ	#-16,D3
BCLHD:	ADD.W	D5,D2
	ADD.W	D4,D3
	BLT.S	SCLHD
	SUB.W	#32,D3
	ADDQ.W	#1,D2
SCLHD:	MOVE.W	D2,(A0)+
	DBF	D6,BCLHD
	RTS
LVERD:	MOVE.W	D5,D3
	SUB.W	D6,D3
	ADD.W	D3,D3
	ADD.W	D5,D5
	MOVE.W	D3,D4
	SUBQ.W	#2,D6
BCLVD:	MOVE.W	D2,(A0)+
	TST.W	D4
	BLT.S	SCLVD
	ADD.W	D3,D4
	ADDQ.W	#1,D2
	DBF	D6,BCLVD
	RTS
SCLVD:	ADD.W	D5,D4
	DBF	D6,BCLVD
	RTS
CREALG: NEG.W	D5
	ADDQ.W	#1,D5
	ADDQ.W	#1,D6
	CMP.W	D5,D6
	BGE.S	LVERG
	ADDQ.W	#1,D2
	EXT.L	D5
	LSL.W	#5,D5
	DIVU	D6,D5
	SUBQ.W	#2,D6
	MOVE.W	D5,D4
	LSR.W	#5,D5
	AND.W	#$1F,D4
	MOVEQ	#-16,D3
BCLHG:	SUB.W	D5,D2
	ADD.W	D4,D3
	BLT.S	SCLHG
	SUB.W	#32,D3
	SUBQ.W	#1,D2
SCLHG:	MOVE.W	D2,(A0)+
	DBF	D6,BCLHG
	RTS
LVERG:	MOVE.W	D5,D3
	SUB.W	D6,D3
	ADD.W	D3,D3
	ADD.W	D5,D5
	MOVE.W	D3,D4
	SUBQ.W	#2,D6
BCLVG:	MOVE.W	D2,(A0)+
	TST.W	D4
	BLT.S	SCLVG
	ADD.W	D3,D4
	SUBQ.W	#1,D2
	DBF	D6,BCLVG
	RTS
SCLVG:	ADD.W	D5,D4
	DBF	D6,BCLVG
	RTS

CHLVER: SUBQ.W	#1,D7
	BGE.S	CHLVERB
	RTS
CHLVERB: LSR.W	 #1,D7
	BCC.S	B1VER
B0VER:	MOVE.W	D2,(A0)+
B1VER:	MOVE.W	D2,(A0)+
	ADD.W	D6,D2
	DBF	D7,B0VER
	RTS
CHLHOR: SUBQ.W	#1,D7
	BGE.S	CHLHORB
	RTS
CHLHORB: LSR.W	 #1,D7
	BCC.S	B1HOR
B0HOR:	MOVE.W	D4,(A0)+
	ADD.W	D6,D4
B1HOR:	MOVE.W	D4,(A0)+
	ADD.W	D6,D4
	DBF	D7,B0HOR
	RTS
CLIVECT:
	CLR.W	D3
	MOVE.B	4(A5),D3
	BRA.S	CLI45
CLIA4:	CLR.W	D3
	MOVE.B	4(A4),D3
CLI45:	SUB.W	D5,D3
	BGT.S	CLIHVE
	NEG.W	D3
	ADDQ.W	#1,D3
	SUB.W	D3,D5
	SUB.W	D3,D7
	BLE.S	FCLIVE
	ADD.W	D3,D3
	ADD.W	D3,A0
CLIHVE: MOVE.W	D5,D6
	SUB.W	D7,D6
	SUB.W	#banner,D6
	BGE.S	CLIST
	ADD.W	D6,D7
	BLE.S	FCLIVE
CLIST:	ADDQ.L	#2,(A7)
FCLIVE: RTS
XPOLY:	LEA.L	COULEUR(PC),A4
	ADD.W	D6,A4
	MOVE.L	(A4)+,D2
	MOVE.L	(A4),D3
	MOVE.L	D2,A2
	MOVE.L	D3,A3
	LEA.L	MPOLY(PC),A4
	LEA.L	IPOLY(PC),A1
	ADD.W	D6,A1
	MOVE.L	(A1),XMAF1-MPOLY(A4)
	MOVE.L	128(A1),XMAF2-MPOLY(A4)
	MOVE.L	(A1),XMAF3-MPOLY(A4)
	MOVE.L	128(A1),XMAF5-MPOLY(A4)
	MOVE.L	(A1)+,XMAF4-MPOLY(A4)
	MOVE.L	(A1),XMAF1-MPOLY+4(A4)
	MOVE.L	128(A1),XMAF2-MPOLY+4(A4)
	MOVE.L	(A1),XMAF3-MPOLY+4(A4)
	MOVE.L	128(A1),XMAF5-MPOLY+4(A4)
	MOVE.L	(A1),XMAF4-MPOLY+4(A4)
	MOVE.L	CURSCR,A5
	MULU	#160,D5
	ADDQ.W	#8,D5
	ADD.W	D5,A5
	SUBQ.W	#1,D7
	BGE.S	XAFLIG
	RTS
XAF0:	CLR.W	D0
	MOVE.W	D0,D1
	BRA.S	XAF1
XFAF2:
;  MOVE.B  #1,coorbas+4
	RTS
XAF2:	MOVEQ	#19,D6
	MOVEQ	#30,D1
	BRA.S	XAF3
XAFLIG: MOVE.L	A5,A1
	MOVE.W	(A0)+,D0
	BLT.S	XAF0
	CMP.W	#319,D0
	BGT.S	XFAF2
	MOVE.W	D0,D1
	LSR.W	#4,D0
	AND.W	#$F,D1
	ADD.W	D1,D1
XAF1:	MOVE.W	0(A4,D1.W),D4
	MOVE.W	(A0),D6
	BLT.S	XFAF2
	CMP.W	#319,D6
	BGT.S	XAF2
	MOVE.W	D6,D1
	LSR.W	#4,D6
	AND.W	#$F,D1
	ADD.W	D1,D1
XAF3:	MOVE.W	2(A4,D1.W),D5
	SUB.W	D6,D0
	BGE.L	XAF4
	MOVE.W	D5,D1
	NOT.W	D5
	LSL.W	#3,D6
	ADD.W	D6,A1
	MOVE.W	D4,D6
	NOT.W	D6
	ADDQ.W	#1,D0
	BEQ.S	XMAF4
	BCLR	#0,D0
	BEQ.S	XSAF5
	ADDQ.W	#2,D0
	LEA.L	AFIMP(PC),A4
	ADD.W	D0,D0
	LEA.L	XMAF2(PC,D0.W),A0
	BRA.S	XSSAF5
XSAF5:	ADD.W	D0,D0
	LEA.L	XMAF2(PC,D0.W),A4
XSSAF5: MOVE.L	A1,A5

XMAF1:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	JMP	(A4)
	NOP
AFIMP:	MOVE.L	D3,-(A1)
	MOVE.L	D2,-(A1)
	JMP	(A0)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
XMAF2:	AND.W	D4,-(A1)
	OR.W	D6,-(A1)
	AND.W	D4,-(A1)
	OR.W	D6,-(A1)
	LEA.L	-160(A5),A5
	MOVE.L	A5,A1
	DBF	D7,XMAF1
	RTS
;AFF SANS MOT COMPLET
XMAF4:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
XMAF5:	AND.W	D4,-(A1)
	OR.W	D6,-(A1)
	AND.W	D4,-(A1)
	OR.W	D6,-(A1)
	LEA.L	-144(A1),A1
	DBF	D7,XMAF4
	RTS

;AFF SUR PREM MOT
XAF4:	NOT.W	D4
	OR.W	D4,D5	 
	MOVE.W	D5,D1
	NOT.W	D5
	LSL.W	#3,D6
	ADD.W	D6,A1
XMAF3:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	LEA.L	-152(A1),A1
	DBF	D7,XMAF3
	RTS
POLY:	LEA.L	COULEUR(PC),A4
	ADD.W	D6,A4
	MOVE.L	(A4)+,D2
	MOVE.L	(A4),D3
	MOVE.L	D2,A2
	MOVE.L	D3,A3
	LEA.L	MPOLY(PC),A4
	LEA.L	IPOLY(PC),A1
	ADD.W	D6,A1
	MOVE.L	(A1),MAF1-MPOLY(A4)
	MOVE.L	(A1),MAF3-MPOLY(A4)
	MOVE.L	(A1)+,MAF2-MPOLY(A4)
	MOVE.L	(A1),MAF1-MPOLY+4(A4)
	MOVE.L	(A1),MAF3-MPOLY+4(A4)
	MOVE.L	(A1),MAF2-MPOLY+4(A4)
	MOVE.L	CURSCR,A5
	MULU	#160,D5
	ADDQ.W	#8,D5
	ADD.W	D5,A5
	SUBQ.W	#1,D7
	BGE.S	AFLIG
	RTS
AF0:	CLR.W	D0
	MOVE.W	D0,D1
	BRA.S	AF1
FAF2:	LEA.L	-160(A5),A5
	DBF	D7,AFLIG
	RTS
AF2:	MOVEQ	#19,D6
	MOVEQ	#30,D1
	BRA.S	AF3
AFLIG:	MOVE.L	A5,A1
	MOVE.W	(A0)+,D0
	BLT.S	AF0
	CMP.W	#319,D0
	BGT.S	FAF2
	MOVE.W	D0,D1
	LSR.W	#4,D0
	AND.W	#$F,D1
	ADD.W	D1,D1
AF1:	MOVE.W	0(A4,D1.W),D4
	MOVE.W	998(A0),D6
	BLT.S	FAF2
	CMP.W	#319,D6
	BGT.S	AF2
	MOVE.W	D6,D1
	LSR.W	#4,D6
	AND.W	#$F,D1
	ADD.W	D1,D1
AF3:	MOVE.W	2(A4,D1.W),D5
	SUB.W	D6,D0
	BGE.S	AF4
	MOVE.W	D5,D1
	NOT.W	D5
	LSL.W	#3,D6
	ADD.W	D6,A1
MAF1:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	ADDQ.W	#1,D0
	BEQ.S	AF6
AF5:	BCLR	#0,D0
	BEQ.S	SAF5
	ADDQ.W	#2,D0
	MOVE.L	D3,-(A1)
	MOVE.L	D2,-(A1)
SAF5:	ADD.W	D0,D0
	JMP	AF6(PC,D0.W)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
	MOVEM.L D2-D3/A2-A3,-(A1)
AF6:	MOVE.W	D4,D5
	MOVE.W	D4,D1
	NOT.W	D1
MAF2:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
FAF:	LEA.L	-160(A5),A5
	DBF	D7,AFLIG
	RTS
AF4:	NOT.W	D4
	OR.W	D4,D5	 
	MOVE.W	D5,D1
	NOT.W	D5
	LSL.W	#3,D6
	ADD.W	D6,A1
MAF3:	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	AND.W	D5,-(A1)
	OR.W	D1,-(A1)
	LEA.L	-160(A5),A5
	DBF	D7,AFLIG
	RTS
IPOLY:	
;0000
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
;0001
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
;0010
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
;0011
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
;0100
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
;0101
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
;0110
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
;0111
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
;1000
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
;1001
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
;1010
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
;1011
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
;1100
	AND.W	D1,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
;1101
	OR.W	D5,-(A1)
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
;1110
	AND.W	D1,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
;1111
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
	OR.W	D5,-(A1)
;0000
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
;0001
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
;0010
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
;0011
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
;0100
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
;0101
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
;0110
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
;0111
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
;1000
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
;1001
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
;1010
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
;1011
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
;1100
	AND.W	D6,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
;1101
	OR.W	D4,-(A1)
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
;1110
	AND.W	D6,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
;1111
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)
	OR.W	D4,-(A1)

MPOLY:	DC.W	$FFFF,$7FFF,$3FFF,$1FFF
	DC.W	$0FFF,$07FF,$03FF,$01FF
	DC.W	$00FF,$007F,$003F,$001F
	DC.W	$000F,$0007,$0003,$0001
	DC.W	$0000
COULEUR:
	DC.W	0,0,0,0
	DC.W	0,0,0,-1
	DC.W	0,0,-1,0
	DC.W	0,0,-1,-1
	DC.W	0,-1,0,0
	DC.W	0,-1,0,-1
	DC.W	0,-1,-1,0
	DC.W	0,-1,-1,-1
	DC.W	-1,0,0,0
	DC.W	-1,0,0,-1
	DC.W	-1,0,-1,0
	DC.W	-1,0,-1,-1
	DC.W	-1,-1,0,0
	DC.W	-1,-1,0,-1
	DC.W	-1,-1,-1,0
	DC.W	-1,-1,-1,-1
banner: equ	67
MWD2D6: EQU	$3C02
MWA1D3: EQU	$3611
SWPD7:	EQU	$4847
MLA1D3: EQU	$2611
MQ0D3:	EQU	$7600
MWA1D5: EQU	$3A11
MLA1D5: EQU	$2A11
SWMWD7: EQU	$48473E3A
MWD0D3: EQU	$3600
MWX1D6: EQU	$3C29
MLX1D6: EQU	$2C29
ORD3:	EQU	$876B
AND0:	EQU	$C16B
AND2:	EQU	$C56B
obj3d:	cmp.b	#254,d0
	beq	SPRITE
;	 cmp.w	 #1,10(a3)
;	 ble	 SPRITE
	addq.w	#1,nbsprit	;virer
	btst	#0,d0
	beq.s	oavant
	move.l	a5,a4
	move.w	d0,d1
	subq.w	#1,d1
bro3d:	lea.l	-8(a4),a4
	cmp.b	(a4),d1
	beq.s	oavant
	cmp.l	#-1,(a4)
	bne.s	bro3d
	lea.l	-8(a4),a4
	move.w	XB,d1
	add.w	#160,d1
	move.w	d1,6(a4)
	move.w	d1,6+8(a4)
	move.w	htprl(pc),d1
	asr.w	#1,d1
	neg.w	d1
	add.w	#199-64,d1
	cmp.w	#199,d1
	bge.s	prlac
	move.w	#199,d1
prlac:	move.w	d1,2(a4)
oavant: sub.w	#220,d0
	add.w	d0,d0
	add.w	d0,d0
	jsr	to3d(pc,d0.w)
	bra.s	SPRITE
htprl:	dc.w	HAUTEUR
to3d:	BRA.L	AVPONT
	BRA.L	ARPONT
	BRA.L	AVGARA
	BRA.L	ARGARA
	BRA.L	AVTRBD
	BRA.L	ARTRBD
	BRA.L	AVTRBG
	BRA.L	ARTRBG
	BRA.L	AVPNT2
	BRA.L	ARPNT2
	BRA.L	AVPLAQ
	BRA.L	ARPLAQ
	BRA.L	AVPNTR
	BRA.L	ARPNTR
SPRITE: lea.l	-8(a5),a5
	cmp.l	#-1,(a5)
	bne.s	srafft
	rts
srafft: lea.l	coorbas(pc),a3
	clr.b	4(a3)
	clr.w	d6
	clr.w	d2
	move.b	1(a5),d2
	addq.w	#1,d2
	move.w	d2,10(a3)
	clr.w	d0
	move.b	(a5),d0
	cmp.w	#200,d0
	bge	obj3d
	move.b	d0,nolog+1
	MOVE.B	D0,820000+7	;A VIRER 
	move.l	#adchrg,a0   ;adr du fichier logi
	add.w	d0,d0
	add.w	0(a0,d0.w),a0
	clr.w	d0
	move.b	6(a0),d0
	MOVE.B	5(A0),EFSP
	move.b	7(a0),(a5)
	bge.s	syaob0
	movem.l a0/a3/a5/d0,-(a7)
	bsr	vecteur
	movem.l (a7)+,d0/a0/a3/a5
	bra.s	syaob1
syaob0: movem.l a0/a3/d0,-(a7)
	bsr	afspri		;affi obj base
	movem.l (a7)+,d0/a0/a3
syaob1: tst.b	4(a3)
	bne	SPRITE
	addq.w	#8,a0
	subq.w	#2,d0
	blt	SPRITE
	tst.b	-5(a0)
	beq	byaob1
	move.l	a0,a1
	move.l	a0,a2
	move.b	-2(a0),d0
	subq.b	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a1
	move.b	1(a1),d0
	beq.s	yaob3
	subq.w	#1,d0
byaob2: move.b	3(a0),5(a3)
	move.b	1(a0),d1
	ext.w	d1
	move.w	d1,6(a3)
	move.b	2(a0),d1
	ext.w	d1
	move.w	d1,8(a3)
	moveq	#1,d6
	move.b	(a0),(a5)
	bge.s	pvect0
	movem.l a0-a3/a5/d0,-(a7)
	bsr	vecteub
	movem.l (a7)+,d0/a0-a3/a5
	bra.s	s1yaob2
pvect0: movem.l a0-a3/d0,-(a7)
	bsr	afspri	;affi obj fixe avec anim
	movem.l (a7)+,d0/a0-a3
s1yaob2: lea.l	 4(a0),a0
	dbf	d0,byaob2
yaob3:	clr.w	d0
	tst.b	3(a1)
	bne.s	seqbcl
	tst.b	5(a1)
	beq.s	pchsan
	subq.b	#1,4(a1)
	bge.s	pchsan
	move.b	(a1),4(a1)
	move.b	5(a1),d0
	addq.b	#1,d0
	move.w	d0,d1
	add.b	2(a1),d1
	cmp.b	-5(a2),d1
	blt.s	prus1
	clr.w	d0
	addq.b	#1,4(a1)
prus1:	move.b	d0,5(a1)
	bra.s	pchsan
seqbcl: subq.b	#1,4(a1)
	bge.s	pchsan
	move.b	(a1),4(a1)
	move.b	5(a1),d0
	add.b	3(a1),d0
	move.w	d0,d1
	add.b	2(a1),d1
	cmp.b	-5(a2),d1
	blt.s	pruse
	clr.w	d0
pruse:	move.b	d0,5(a1)
pchsan: move.b	2(a1),d0
	clr.w	d2
	move.b	5(a1),d2
	lea.l	6(a1),a1
	add.w	d2,a1
byaob3: clr.w	d1
	move.b	(a1)+,d1
	add.w	d1,d1
	add.w	d1,d1
	lea.l	0(a2,d1.w),a0
	move.b	3(a0),5(a3)
	move.b	1(a0),d1
	ext.w	d1
	move.w	d1,6(a3)
	move.b	2(a0),d1
	ext.w	d1
	move.w	d1,8(a3)
	moveq	#1,d6
	move.b	(a0),(a5)
	bge.s	pvect1
	movem.l a0-a3/a5/d0,-(a7)
	bsr	vecteub
	movem.l (a7)+,d0/a0-a3/a5
	bra.s	s1yaob3
pvect1: movem.l a1-a3/d0,-(a7)
	bsr	afspri	  ;affi anim
	movem.l (a7)+,d0/a1-a3
s1yaob3: dbf	 d0,byaob3
	bra	SPRITE
;trt normal
byaob1: move.b	3(a0),5(a3)
	move.b	1(a0),d1
	ext.w	d1
	move.w	d1,6(a3)
	move.b	2(a0),d1
	ext.w	d1
	move.w	d1,8(a3)
	moveq	#1,d6
	move.b	(a0),(a5)
	bge.s	pvect2
	movem.l a0-a3/a5/d0,-(a7)
	bsr	vecteub
	movem.l (a7)+,d0/a0-a3/a5
	bra.s	s1yaob1
pvect2: movem.l a0/a3/d0,-(a7)
	bsr	afspri	;affi obj sans anim
	movem.l (a7)+,d0/a0/a3
s1yaob1: lea.l	 4(a0),a0
	dbf	d0,byaob1
FSPRI:	bra	SPRITE

afspri: lea.l	tabobj(pc),a0
	addq.w	#1,nbsprit	;virer
	clr.w	d0
	move.b	(a5),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a0
	move.l	a0,a1
	move.l	a0,a4
	move.l	a0,a2
	clr.w	d4
	move.b	1(a5),d4
	cmp.w	2(a0),d4
	bge	paaf2
	move.b	4(a0,d4.w),d4
	bge.s	posaf
	cmp.b	#-1,d4
	beq	paaf2
posaf:	add.w	2(a0),a0
	addq.w	#4,a0
	add.w	d4,d4
	add.w	(a0)+,a2
	add.w	6(a0,d4.w),a4
	clr.w	d0
	move.b	(a4)+,d0
	lsl.w	#3,d0
	add.w	d0,a2
	add.w	(a2)+,a1
	clr.w	d0
	move.b	(a4)+,d0
	move.w	2(a5),d1
	tst.w	d6
	beq.s	ybas
	move.b	5(a3),d3
	move.w	10(a3),d7
	btst	#1,d3
	beq.s	porout
	sub.w	(a3),d1
	btst	#0,d3
	beq.s	pocom
	add.w	d0,d1
	bra.s	pocom
porout: btst	#0,d3
	beq.s	pocom
	sub.w	d7,d1
	add.w	d0,d1
pocom:	muls	8(a3),d7
	asr.w	#8,d7
	add.w	d7,d1
	bra.s	pcom1  
ybas:	move.w	d0,(a3)
pcom1:	move.w	d1,d3
	sub.w	d0,d3
	sub.w	#banner,d3
	bge.L	enthaut
	cmp.w	#banner,d1
	ble.L	paaf2
	add.w	d3,d0
	move.l	a4,a3
	move.w	6+2(a0,d4.w),d7
	sub.w	6(a0,d4.w),d7
	subq.w	#3,d7
	add.w	d7,a3
	btst	#0,d7
	beq.s	lidbl
lispl:	move.b	-(a3),d7
	add.w	d7,d3
	blt.s	lidbl
	addq.w	#1,sseq
	move.b	1(a3),-(a7)
	move.b	d7,-(a7)
	move.l	a3,-(a7)
	move.w	#1,-(a7)
	move.b	d3,(a3)+
	clr.b	(a3)
	bra.s	enthaut
lidbl:	move.b	-(a3),d7
	add.w	d7,d3
	add.w	d7,d3
	blt.s	lispl
	lsr.w	#1,d3
	bcs.s	sdbls
	addq.w	#1,sseq
	move.b	1(a3),-(a7)
	move.b	d7,-(a7)
	move.l	a3,-(a7)
	move.w	#1,-(a7)
	move.b	d3,(a3)+
	clr.b	(a3)
	bra.s	enthaut
sdbls:	addq.w	#1,sseq
	tst.b	d3
	bne.s	sdbl2
	move.b	d7,-(a7)
	move.b	-(a3),-(a7)
	move.l	a3,-(a7)
	move.w	#1,-(a7)
	addq.b	#1,(a3)+
	clr.b	(a3)
	bra.s	enthaut
sdbl2:	move.b	3(a3),-(a7)
	move.b	2(a3),-(a7)
	move.b	1(a3),-(a7)
	move.b	d7,-(a7)
	move.l	a3,-(a7)
	move.w	#3,-(a7)
	move.b	d3,(a3)+
	move.b	#1,(a3)+
	clr.b	(a3)
enthaut:
	clr.w	d3
	move.b	4(a5),d3
	sub.w	d1,d3
	bgt	entbas
	neg.w	d3
	addq.w	#1,d3
	cmp.w	d3,d0
	bgt.s	ppaaf
paaf:	tst.w	d6
	bne	rfspr
	move.b	2(a2),coorbas+3
	bra	rfspr
paaf2:	move.b	#1,4(a3)
	rts
ppaaf:	sub.w	d3,d1
	clr.w	d0
	clr.w	d7
lispl1: move.b	(a4)+,d7
	add.w	d7,d0
	sub.w	d7,d3
	bgt.s	lidbl1
	add.w	d3,d0
	addq.w	#1,sseq
	move.b	(a4),-(a7)
	move.b	-(a4),-(a7)
	move.l	a4,-(a7)
	move.w	#1,-(a7)
	neg.w	d3
	move.b	d3,(a4)
	bra.s	fli1
lidbl1: move.b	(a4)+,d7
	add.w	d7,d0
	sub.w	d7,d3
	sub.w	d7,d3
	bgt.s	lispl1
	neg.w	d3
	lsr.w	#1,d3
	bcs.s	sdbl1
	tst.w	d3
	beq.s	fli1
	sub.w	d3,d0
	addq.w	#1,sseq
	move.b	-(a4),-(a7)
	move.b	-(a4),-(a7)
	move.l	a4,-(a7)
	move.w	#1,-(a7)
	clr.b	(a4)
	move.b	d3,1(a4)
	bra.s	fli1
sdbl1:	sub.w	d3,d0
	addq.w	#1,sseq
	subq.w	#1,d0
	tst.w	d3
	bne.s	sdbl3
	tst.b	(a4)
	bne.s	sdbx
	move.b	1(a4),-(a7)
	move.b	(a4),-(a7)
	move.l	a4,-(a7)
	move.w	#1,-(a7)
	move.b	#1,(a4)
	clr.b	1(a4)
	bra.s	fli1
sdbx:	move.b	1(a4),-(a7)
	move.b	(a4),-(a7)
	move.l	a4,-(a7)
	move.w	#1,-(a7)
	addq.b	#1,(a4)
	bra.s	fli1
sdbl3:	move.b	-(a4),-(a7)
	move.b	-(a4),-(a7)
	move.l	a4,-(a7)
	move.w	#1,-(a7)
	move.b	#1,(a4)
	move.b	d3,1(a4)
fli1:	mulu	4(a2),d0
	add.w	d0,a1
entbas: move.l	CURSCR,a3
	lsl.w	#5,d1
	move.w	d1,d4
	lsl.w	#2,d4
	add.w	d4,d1
	add.w	d1,a3
	clr.w	d4
	move.b	2(a2),d4
	move.w	6(a5),d1
	tst.w	d6
	beq.s	xbas
	move.l	a0,d5
	lea.l	coorbas(pc),a0
	tst.b	5(a5)
	beq.s	scal
	sub.w	2(a0),d1
scal:	move.w	10(a0),d2
	muls	6(a0),d2
	asr.w	#8,d2
	move.b	5(a0),d3
	btst	#4,d3
	bne.s	calctr
	add.w	d2,d1
	btst	#3,d3
	bne.s	calgch
	add.w	2(a0),d1
	btst	#2,d3
	bne.s	drgc
	sub.w	d4,d1
calcom: move.l	d5,a0
	bra.s	objdrt
drgc:	addq.w	#1,d1
	move.l	d5,a0
	bra.s	objdrt
calgch: btst	#2,d3
	beq.s	calcom
	sub.w	d4,d1
	subq.w	#1,d1
	move.l	d5,a0
	bra.s	objdrt
calctr: move.w	2(a0),d3
	lsr.w	#1,d3
	add.w	d3,d2
	move.w	d4,d3
	lsr.w	#1,d3
	sub.w	d3,d2
	add.w	d2,d1
	move.l	d5,a0
	bra.s	objdrt
xbas:	move.w	d4,coorbas+2
	tst.b	5(a5)
	beq.s	objdrt
	sub.w	d4,d1
objdrt: move.w	d4,d5
	lsr.w	#4,d5
	subq.w	#1,d5
	move.w	d1,d2
	move.w	d4,d3
	add.w	d1,d3
	and.w	#$f,d2
	and.w	#$f,d3
	move.w	#$7,d6
	moveq	#16,d7
	cmp.w	d2,d3
	blt.s	trplv
	bclr	#2,d6
	subq.w	#8,d7
trplv:	tst.w	d1
	bge.s	spr1
	add.w	d1,d4
	blt	paaf
	move.w	d1,d4
	asr.w	#4,d4
	addq.w	#1,d4
	add.w	d4,d5
	asl.w	#1,d4
	sub.w	d4,a1
	bclr	#0,d6
	subq.w	#8,d7
	move.w	d2,d1
	move.w	#16,d2
	sub.w	d1,d2
	bra.s	sprc
spr1:	cmp.w	#320,d1
	bge	paaf
	add.w	d1,d4
	sub.w	#320,d4
	blt.s	spr2
	lsr.w	#4,d4
	sub.w	d4,d5
	subq.w	#8,d7
	or.w	#$ff00,d6
	bclr	#2,d6
	bne.s	spr2
	addq.w	#8,d7
	subq.w	#1,d5
spr2:	move.w	d1,d4
	lsr.w	#1,d4
	and.w	#$fff8,d4
	add.w	d4,a3
	move.w	d2,d1
	move.w	#16,d2
	sub.w	d1,d2
sprc:	btst	#1,1(a0)
	beq.s	pcarre
	move.l	a0,-(sp)
	lea.l	TBMK(pc),a0
	move.w	d1,d4
	add.w	d4,d4
	move.w	0(a0,d4.w),d4
	move.w	d4,d0
	swap	d0
	move.w	d4,d0
	tst.w	d6
	bge.s	mskex
;	 clr.l	 -(a0)
	CLR.L	820000+2 ;A VIRER
	move.l	(sp)+,a0
	bra.s	pcarre
mskex:	add.w	d3,d3
;	 move.w	32(a0,d3.w),-(a0)
;	 move.w	34(a0,d3.w),-(a0)
	move.w	32(a0,d3.w),820000+4	  ;A VIRER
	move.w	34(a0,d3.w),820000+2
	move.l	(sp)+,a0
	btst	#2,d6
	bne.s	pcarre
	tst.w	d5
	blt.s	pcarre
	addq.w	#8,d7
	subq.w	#1,d5
	bset	#3,d6
pcarre: move.w	(a2),d4
	move.w	4(a2),a2
	tst.w	d5
	blt.s	pap2
;	 move.w	d5,VD7
	MOVE.W	D5,820000	;A VIRER
	addq.w	#1,d5
	add.w	d5,d5
	add.w	d5,a1
	add.w	d5,a2
	add.w	d5,d5
	add.w	d5,d5			
	bra.s	spap2
pap2:	bclr	#1,d6
	clr.w	d5
spap2:	add.w	d7,d5
	add.w	d5,a3
	MOVE.W	EFSP(PC),820000+8 ;A VIRER
	MOVE.W	(A0)+,D7
	ADD.W	D7,D7

	MOVE.L	#820000+10,A6	;A VIRER
	MOVE.W	-24(A6,D7.W),D7 ;
	JSR	0(A6,D7.W)	;

;	 MOVE.W	TRTSP-24(PC,D7.W),D7
;	 JSR	 R1234(PC,D7.W)
rfspr:	move.w	sseq(pc),d0
	beq.s	fsprit
	clr.w	sseq
	subq.w	#1,d0
bsprc:	move.w	(a7)+,d1
	move.l	(a7)+,a3
b1spr:	move.b	(a7)+,(a3)+
	dbf	d1,b1spr
	dbf	d0,bsprc
fsprit: rts
sseq:	dc.w	0
MSKD2:	DC.L	0
TBMK:	DC.W	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
	DC.W	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE
	DC.W	$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF
	DC.W	$007F,$003F,$001F,$000F,$0007,$0003,$0001,$0000
VD7:	DC.W	0

EFSP:	DC.W	0
;data pour vroom
nolog:	dc.w	0
naobj:	dc.w	0
adhaut: dc.l	adchrg+3200
tabobj: blk.l	128,0
ztrav:	blk.l	3500,0
sacir:	clr.w	err
	move.l	#sfic,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
bsac:	move.w	JOY+6,d0
	beq.s	bsac
	clr.w	JOY+6
	btst	#7,d0
	bne.s	bsac
	cmp.b	#$15,d0
	beq.s	sbac
	move.l	#bgend,(a7)
	rts
sbac:	clr.w	-(sp)
	move.l	#xdta+30,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	error2
	move.w	d0,handle
	move.l	#CRCEVT,-(sp)
	move.l	#8000,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	error2
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	error2
	rts
locir:	clr.w	err
	move.l	#lfic,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
bloc:	move.w	JOY+6,d0
	beq.s	bloc
	clr.w	JOY+6
	btst	#7,d0
	bne.s	bloc
	cmp.b	#$15,d0
	beq.s	sloc
	move.l	#bgend,(a7)
	rts
sloc:	
	clr.l	xdta+30	 
	clr.l	xdta+34	 
	clr.l	xdta+38	 
	clr.l	xdta+42	 
	clr.l	xdta+46
	move.l	#xdta,-(sp)
	move.w	#$1a,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#0,-(sp)
	move.l	#nevt,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bne	error2

	clr.w	-(sp)
	move.l	#xdta+30,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	error2
	move.w	d0,handle
	move.l	#CRCEVT,-(sp)
	move.l	#8000,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	error2
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	error2
	move.l	#CRCEVT,a0
brclong: cmp.w	#-1,(a0)
	beq.s	fbrlon
	addq.l	#8,a0
	bra.s	brclong
fbrlon:	move.l	2(a0),CRCLAP
	rts
xdta:	blk.l	15,0
lofic:	clr.w	err
	clr.w	-(sp)
	move.l	a1,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	error2
	move.w	d0,handle
	move.l	adfic(pc),-(sp)
	move.l	tfic(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bmi	error2
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	error2
	rts
handle: dc.w	0
error2: move.l	#terr,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#1,err
	rts
tfic:	dc.l	0
adfic:	dc.l	0
err:	dc.w	0
nfic:	dc.b	"obj.log",0
pagvoit: dc.b	"pagvoit.pi1",0
roues:	dc.b	"roues.pi1",0
spri:	dc.b	"sprit.img",0
tbrout: dc.b	"route.dat",0
tabt:	dc.b	"modtab.dat",0
terr:	dc.b	$1b,"Y",32+1,32+1,"	 E R R E U R   ",0,0
sfic:	dc.b	$1b,"Y",32+1,32+1,"save circuit (y/n): ",0,0
lfic:	dc.b	$1b,"Y",32+1,32+1,"load circuit (y/n): ",0,0
nob:	dc.b	"o***.phy",0
	EVEN
tamp:	blk.l	20,0 
chargt: clr.w	err
	moveq	#0,d0
	move.w	naobj,d0
	lea.l	nob+1(pc),a0
	move.w	#2,d6
	jsr	ecrit
	clr.w	-(sp)
	move.l	#nob,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bge.s	perr1
	move.w	#1,err
	rts
perr1:	move.w	d0,handl
	move.l	adhaut(pc),-(sp)
	move.l	#20000,-(sp)
	move.w	handl,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.w	d0
	bge.s	perr2
	move.w	#1,err
	rts
perr2:	move.w	handl,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
handl:	dc.w	0
**********
iniobj: lea.l	tabobj(pc),a0
	move.w	naobj(pc),d0
	lsl.w	#2,d0
	tst.l	0(a0,d0.w)
	beq.s	siniob
	rts
siniob: move.l	adhaut(pc),0(a0,d0.w)
	bsr	chargt
	tst.w	err
	beq.s	fichr
	lea.l	4(a7),a7
	rts
fichr:	move.l	adhaut(pc),a0
	add.w	(a0),a0
	move.l	#ztrav,a1	;zone de trav
	move.w	(a0),d0
	subq.w	#1,d0
rechom: move.b	(a0)+,(a1)+
	dbf	d0,rechom
	move.l	a1,a2
	move.w	#21,d0
	add.w	4(a0),d0
	add.w	6(a0),d0
	bclr	#0,d0
	subq.w	#1,d0
recomp: move.b	(a0)+,(a1)+
	dbf	d0,recomp
	
	move.l	#1,-(a7)
	move.l	a1,-(a7)
	move.l	a2,-(a7)
	clr.l	-(a7)
	clr.l	-(a7)
	move.l	adecr,-(a7)
	bsr	DECOMP

	move.w	#15,d0
	lea.l	tabinst(pc),a4
	lea.l	tabins2(pc),a3
	move.l	adhaut(pc),a0
	add.w	2(a0),a0
	addq.w	#4,a0
	btst	#0,3(a0)
	beq.s	biins1
	lea.l	tabins3(pc),a3
biins1: move.l	(a3)+,(a4)+
	dbf	d0,biins1
;trt homo
	lea.l	zbuf(pc),a3
	lea.l	tabinst(pc),a4
	moveq	#0,d1
	move.w	6(a3),d1
	addq.w	#2,d1
	lsr.w	#1,d1
	move.l	d1,10(a3)
	addq.w	#1,d1
	move.w	8(a3),d7
	addq.w	#1,d7
	mulu	d7,d1
	add.l	adcomp(pc),d1
	bclr	#0,d1
	move.l	d1,a6
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	clr.l	(a6)+
	move.w	2(a0),d7
	move.w	(a0),a0
	add.l	adhaut(pc),a0
	move.l	#ztrav,a2    ;meme zone de trav
	move.w	(a2)+,d0
	subq.w	#2,d0
bhom:	movem.l d0/d7/a0/a6,-(sp)
	bsr	thomo
	movem.l (sp)+,d0/d7/a0/a6
	move.l	adhaut(pc),a5
	add.w	(a0),a5
	move.w	6(a0),d1
	move.w	d1,d2
	lsl.w	#2,d1
	lsr.w	#1,d2
	subq.w	#1,d2
	sub.w	d1,a1
	add.w	d1,d1
	move.l	a1,d3
	btst	#5,d7
	beq.s	d2hom
b1hom:	clr.w	d4
	move.b	5(a0),d4
	subq.w	#1,d4
sb1ho:	move.w	d2,d5
sb1ho1: move.w	(a1),(a5)+
	lea.l	8(a1),a1
	dbf	d5,sb1ho1
	sub.w	d1,a1
	dbf	d4,sb1ho
d2hom:	btst	#4,d7
	beq.s	d3hom
b2hom:	clr.w	d4
	move.b	5(a0),d4
	subq.w	#1,d4
	move.l	d3,a1
	addq.w	#2,a1
sb2ho:	move.w	d2,d5
sb2ho1: move.w	(a1),(a5)+
	lea.l	8(a1),a1
	dbf	d5,sb2ho1
	sub.w	d1,a1
	dbf	d4,sb2ho
d3hom:	btst	#3,d7
	beq.s	d4hom
b3hom:	clr.w	d4
	move.b	5(a0),d4
	subq.w	#1,d4
	move.l	d3,a1
	addq.w	#4,a1
sb3ho:	move.w	d2,d5
sb3ho1: move.w	(a1),(a5)+
	lea.l	8(a1),a1
	dbf	d5,sb3ho1
	sub.w	d1,a1
	dbf	d4,sb3ho
d4hom:	btst	#2,d7
	beq.s	b5hom
b4hom:	clr.w	d4
	move.b	5(a0),d4
	subq.w	#1,d4
	move.l	d3,a1
	addq.w	#6,a1
sb4ho:	move.w	d2,d5
sb4ho1: move.w	(a1),(a5)+
	lea.l	8(a1),a1
	dbf	d5,sb4ho1
	sub.w	d1,a1
	dbf	d4,sb4ho
b5hom:	lea.l	8(a0),a0
	lea.l	6(a2),a2
	subq.w	#6,d0
	bgt	bhom
	move.l	a5,d2
	sub.l	adhaut(pc),d2
	lea.l	ttobj(pc),a2
	move.w	naobj(pc),d1
	add.w	d1,d1
	move.w	d2,0(a2,d1.w)
	move.l	a5,adhaut
	rts

thomo:	move.l a6,a1 
	move.l #$80008000,d7
	move.l #$80000000,d5
	move.w 8(a3),boucy 
	move.l adcomp(pc),a0 
	moveq	#0,d3 
	move.l	d3,d4
	move.w	(a2),d6
	moveq	#0,d2
	move.w	d6,d2
	moveq	#0,d0
	move.b	4(a2),d0
	mulu	d0,d2
	lsr.l	#6,d2
	move.w	d2,16(a3)
	moveq	#0,d1
	move.w	2(a2),d1
	move.b	5(a2),d0
	mulu	d0,d1
	lsr.l	#6,d1
	move.w	d1,14(a3)
	clr.w	d0
	tst.w	2(a2)
	beq	ggross
 
	lea.l	dchet1,a5
	lea.l	dchet2,a6
	move.w	2(a2),d1
drep1:	add.w	#128,14(a3)
	cmp.w	14(a3),d1
	bgt.s	dcopr4
	sub.w	d1,14(a3)
	add.l	10(a3),a0
	subq.w	#1,boucy
	bge.s	drep1
	rts
dcopr4: move.w	6(a3),d1
dbitaf: add.w	#128,d2
	cmp.w	d6,d2
	blt.s	dcopr1
	sub.w	d6,d2
	bra.s	dbaf5
dcopr1: move.b	(a0),d0
	and.w	#$f0,d0 
	lsr.w	#2,d0
	move.l	0(a4,d0.w),(a5) 
	nop
dchet1: nop
	nop
	ror.l	#1,d5
	ror.l	#1,d7 
	bcc.s	dbaf5 
	swap	d5
	move.l	d3,(a1)+  
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
	dbf	d1,dbaf6
	addq.l	#1,a0
	bra.s	dfilib
dbaf5:	dbf	d1,dbaf6
	addq.l	#1,a0
	bra.s	dfili
dbaf6:	add.w	#128,d2
	cmp.w	d6,d2
	blt.s	dcopr2
	sub.w	d6,d2
	addq.l	#1,a0
	dbf	d1,dbitaf
	bra.s	dfili
dcopr2: move.b	(a0)+,d0
	and.w	#$f,d0
	lsl.w	#2,d0
	move.l	0(a4,d0.w),(a6)
	nop
dchet2: nop
	nop
dbaf7:	ror.l	#1,d5
	ror.l	#1,d7 
	bcc.s	dbafx 
	swap	d5
	move.l	d3,(a1)+
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
	dbf	d1,dbitaf
	bra.s	dfilib
dbafx:	dbf	d1,dbitaf
dfili:	tst.w	d7
	blt.s	dfilib
	move.l	d3,(a1)+  
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
dfilib: 
	move.l	#$80008000,d7
	move.l	#$80000000,d5
	move.w	16(a3),d2
	move.w	2(a2),d1
drep2:	add.w	#128,14(a3)
	cmp.w	14(a3),d1
	bgt.s	dcopr3
	sub.w	d1,14(a3)
	add.l	10(a3),a0
	subq.w	#1,boucy
	bge.s	drep2
	rts
dcopr3: move.w	6(a3),d1
	subq.w	#1,boucy 
	bge	dbitaf
	rts

ggross: move.w	6(a3),d1
	lea.l	gchet1,a5
	lea.l	gchet2,a6
gbitaf: move.b	(a0),d0
	and.b	#$f0,d0 
	lsr.b	#2,d0
	move.l	0(a4,d0.w),(a5) 
	nop
gchet1: nop
	nop
	ror.l	#1,d5
	ror.l	#1,d7
	bcc.s	gbaf5
	swap	d5
	move.l	d3,(a1)+  
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
gbaf5:	add.w	#128,d2
	cmp.w	d6,d2
	blt.s	gcopr1
	sub.w	d6,d2
	bra.s	gchet1
gcopr1: dbf	d1,gbaf6
	addq.l	#1,a0
	bra.s	gfili
gbaf6:	move.b	(a0)+,d0
	and.b	#$f,d0
	lsl.b	#2,d0
	move.l	0(a4,d0.w),(a6)
	nop
gchet2: nop
	nop
	ror.l	#1,d5
	ror.l	#1,d7 
	bcc.s	gbafx 
	swap	d5
	move.l	d3,(a1)+  
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
gbafx:	add.w	#128,d2
	cmp.w	d6,d2
	blt.s	gcopr2
	sub.w	d6,d2
	bra.s	gchet2
gcopr2: dbf	d1,gbitaf 
gfili:	tst.w	d7
	blt.s	gfilib
	move.l	d3,(a1)+
	move.l	d4,(a1)+ 
	moveq	#0,d3 
	move.l	d3,d4
gfilib: move.l	#$80008000,d7
	move.l	#$80000000,d5
	move.w	16(a3),d2
	move.w	6(a3),d1
	subq.w	#1,boucy
	bge	gbitaf
	rts
DECOMP:
    move.l 4(a7),adecr
    move.w 10(a7),ycoor
    move.w 14(a7),xcoor
    move.l 16(a7),adfi
    move.l 20(a7),plcomp
	move.l	24(a7),flsprite
    movem.l d0-d7/a0-a6,-(sp)
    move.l adfi(pc),a0
    move.b (a0),typfi
    move.b 1(a0),nbcar
    add.l #2,adfi
	move.w	#15,d0
	lea.l	tabinst(pc),a4
	lea.l	tabins2(pc),a3
bins:	move.l	(a3)+,(a4)+
	dbf	d0,bins
    tst.b typfi
    bne fiani
;voir palette
    add.l #32,adfi
    bra inicont
fiani:
    clr.w  d0
    move.b 2(a0),d0
    lsl.b #2,d0
;    move.w  d0,vamsk
    lea.l  tabinst(pc),a0
    move.l codanim(pc),0(a0,d0.w)
    add.l #2,adfi
inicont:
    move.l plcomp(pc),tailcou
    move.l plcomp(pc),plaff
    lea.l zbuf(pc),a3
    move.l adfi(pc),a4
    move.l 10(a4),6(a3)
    move.w xcoor(pc),10(a3)
    move.w ycoor(pc),12(a3)
    move.l a4,adcomp
    addi.l #14,adcomp
    move.w 4(a4),d0
    add.w d0,10(a3)
    move.w 6(a4),d0
    add.w d0,12(a3)
    tst.b 8(a4)
    beq afficha
    move.l adcomp(pc),adanc
    move.l adcomp(pc),adanq
    move.l adcomp(pc),adcoc
    move.l adcomp(pc),adcoq
    move.l plaff(pc),adcomp
    clr.l d0
    move.w (a4),d0
    add.l d0,adanq
    add.l d0,adcoq
    add.w 2(a4),d0
    btst #0,d0
    beq.s bonfron
    add.l #1,adanq
    add.l #1,adcoq
bonfron:
    btst #0,9(a4)
    beq.s tst1
    bsr repanac
    move.l adfi(pc),a4
tst1:
    btst #1,9(a4)
    beq.s tst2
    bsr repanav
    move.l adfi(pc),a4
tst2:
    clr.w d6
    move.b 8(a4),d6
    lea.l zbuf(pc),a3
    lsl.b #2,d6
    move.w d6,14(a3)
    lea.l tabadcb(pc),a6
    jsr 0(a6,d6.w)
afficha:
	tst.l	flsprite
	bne	atcara1
    lea.l zbuf(pc),a3
    lea.l tabinst(pc),a4
    lea.l chet1(pc),a5
    lea.l chet2(pc),a6 
    move.l adecr,a1 
    move.w 10(a3),d1 
    move.w 12(a3),d2 
    move.w d1,d3 
    mulu #160,d2 
    lsr.w #1,d1 
    andi.b #$f8,d1 
    add.w d1,d2 
    andi.w #$000f,d3 
    eori.b #$0f,d3 
    adda.l d2,a1 
    moveq  #0,d7 
    bset d3,d7
    swap d7
    move.l d7,d5
    bset d3,d7 
    move.w d7,4(a3) 
    move.w d7,d3 
    eor.w #$ffff,d3 
    move.w #$ffff,maskdeb 
mepmade:
    and.w d3,maskdeb 
    ror.w #1,d3 
    bcs.s mepmade 
    move.w maskdeb(pc),d2
    swap  d2
    move.w maskdeb(pc),d2 
    move.w 6(a3),d1 
    lsr.w #1,d1 
    move.w 8(a3),boucy 
    move.l a1,(a3) 
    move.l adcomp(pc),a0 
    clr.w filin 
    moveq	#0,d3 
    moveq	#0,d4
    clr.w d0 
    move.b (a0),d0
    bra.s bitaf 
bafx:
    ror.l #1,d5
    ror.l #1,d7 
    bcc.s bitaf 
    swap  d5
    and.l d2,(a1)
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+ 
    moveq	#0,d2	  
    move.l	d2,d3 
    move.l	d2,d4 
bitaf:
    and.b  #$f0,d0 
    lsr.b  #2,d0
    move.l 0(a4,d0.w),(a5)
    move.b (a0)+,d0 
chet1:
    nop
    nop
    ror.l #1,d5
    ror.l #1,d7 
    bcc.s baf5
    swap  d5 
    and.l d2,(a1)
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+  
    moveq	#0,d2	  
    move.l	d2,d3 
    move.l	d2,d4 
baf5:
    and.b  #$f,d0
    lsl.b #2,d0
    move.l 0(a4,d0.w),(a6)
    move.b (a0),d0
chet2:
    nop
    nop
    dbf d1,bafx 
    btst #0,7(a3) 
    bne.s xpaiaf 
    move.l d7,d1 
    eor.l #$ffffffff,d1 
    and.l d1,d3 
    and.l d1,d4 
xpaiaf:
    tst.w filin 
    bne.s seclig 
    move.w #1,filin 
    move.w d7,d1 
    eor.w #$ffff,d1 
    move.w #$ffff,maskfi 
    btst #0,7(a3) 
    bne.s mepmafi 
    rol.w #1,d1 
    bcc.s seclig 
mepmafi:
    and.w d1,maskfi 
    rol.w #1,d1 
    bcs.s mepmafi 
seclig:
    or.w maskfi(pc),d2
    swap d2
    or.w maskfi(pc),d2 
    and.l d2,(a1) 
    or.l d3,(a1)+  
    and.l d2,(a1) 
    or.l d4,(a1)+ 
    moveq	#0,d3 
    moveq	#0,d4 
    move.w maskdeb(pc),d2
    swap  d2
    move.w maskdeb(pc),d2 
    addi.l #160,(a3)
    move.l (a3),a1 
    move.w 4(a3),d7
    swap   d7
    move.l d7,d5
    clr.w  d5
    move.w 4(a3),d7 
    move.w 6(a3),d1 
    lsr.w #1,d1 
    move.b (a0),d0
    subq.w #1,boucy 
    bge bitaf
atcara:
    subi.b #1,nbcar
    ble.s atcara1
    move.l adfi(pc),a4
    clr.l d0
    move.w (a4),d0
    add.w 2(a4),d0
    add.l #15,d0
    bclr #0,d0
    add.l d0,adfi
    bra inicont
atcara1:
    movem.l (sp)+,d0-d7/a0-a6
    move.l (a7),24(a7)
    add.l #24,a7
    rts
codanim:
	or.l	d7,d2
	nop
tabinst: blk.l	64,0
tabins2: 
	nop		;0000
	nop
	nop		;0001
	or.w	d7,d4
	nop		;0010
	or.l	d5,d4
	nop		;0011
	or.l	d7,d4
	or.w	d7,d3	;0100
	nop
	or.w	d7,d3	;0101
	or.w	d7,d4
	or.w	d7,d3	;0110
	or.l	d5,d4
	or.w	d7,d3	;0111
	or.l	d7,d4
	or.l	d5,d3	;1000
	nop
	or.l	d5,d3	;1001
	or.w	d7,d4
	or.l	d5,d3	;1010
	or.l	d5,d4
	or.l	d5,d3	;1011
	or.l	d7,d4
	or.l	d7,d3	;1100
	nop
	or.l	d7,d3	;1101
	or.w	d7,d4
	or.l	d7,d3	;1110
	or.l	d5,d4
	or.l	d7,d3	;1111
	or.l	d7,d4
tabins3: 
	or.l	d7,d3	;1111
	or.l	d7,d4
	or.l	d7,d3	;1110
	or.l	d5,d4
	or.l	d7,d3	;1101
	or.w	d7,d4
	or.l	d7,d3	;1100
	nop
	or.l	d5,d3	;1011
	or.l	d7,d4
	or.l	d5,d3	;1010
	or.l	d5,d4
	or.l	d5,d3	;1001
	or.w	d7,d4
	or.l	d5,d3	;1000
	nop
	or.w	d7,d3	;0111
	or.l	d7,d4
	or.w	d7,d3	;0110
	or.l	d5,d4
	or.w	d7,d3	;0101
	or.w	d7,d4
	or.w	d7,d3	;0100
	nop
	nop		;0011
	or.l	d7,d4
	nop		;0010
	or.l	d5,d4
	nop		;0001
	or.w	d7,d4
	nop		;0000
	nop

remqut:
    clr.w d6
    clr.w d7
    move.b (a0),d7
    bchg #0,d0
    beq.s abq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s abq02
abq01:
    lsr.b #4,d7
abq02:
    cmp.b #15,d7
    blt.s wbq02
bqut:
    clr.w d7
    move.b (a0),d7
    bchg #0,d0
    beq.s bq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s bq02
bq01:
    lsr.b #4,d7
bq02:
    add.w d7,d6
    cmpi.b #15,d7
    beq.s bqut
    mulu #15,d6
    move.b (a0),d7
    bchg #0,d0
    beq.s wbq01
    addq.l #1,a0
    andi.b #$0f,d7
    bra.s wbq02
wbq01:
    lsr.b #4,d7
wbq02:
    add.w d7,d6
    subq.w #1,d6
    rts
repanac:
    move.l adanc(pc),a0
    move.l plcomp(pc),a1
    move.l a1,adcoc
    clr.b d1
    clr.b d0
    move.l adfi(pc),a5
    move.l a0,a4
    move.w (a5),d7
    ext.l d7
    adda.l d7,a4
    subq.l #1,a4
bgenc:
    bsr remqut
    move.w d6,d5
    bsr remqut
bremc:
    move.w d6,d4
    move.l a0,a2
    move.b d0,d3
bremc1:
    move.b (a2),d7
    bchg #0,d3
    beq.s bremc10
    addq.l #1,a2
    andi.b #$0f,d7
    bra.s bremc11
bremc10:
    lsr.b #4,d7
bremc11:
    bchg #0,d1
    beq.s bremc12
    or.b d7,(a1)+
    bra.s bremc13
bremc12:
    lsl.b #4,d7
    move.b d7,(a1)
bremc13:
    dbf d4,bremc1
    dbf d5,bremc
    move.l a2,a0
    move.b d3,d0
    cmpa.l a4,a0
    blt bgenc
    addq.l #1,a1
    move.l a1,tailcou
    move.l a1,adcomp
    rts
repanav:
    move.l adanq(pc),a0
    move.l tailcou(pc),a1
    move.l tailcou(pc),adcoq
    clr.b d0
    move.l adfi(pc),a5
    move.l a0,a4
    move.w 2(a5),d7
    ext.l d7
    adda.l d7,a4
    subq.l #1,a4
bgencb:
    bsr remqut
    move.w d6,d5
    bsr remqut
    btst #0,d0
    beq.s bremcb
    clr.b d0
    addq.l #1,a0
bremcb:
    move.w d6,d4
    move.l a0,a2
bremc1b:
    move.b (a2)+,(a1)+
    dbf d4,bremc1b
    dbf d5,bremcb
    move.l a2,a0
    cmpa.l a4,a0
    blt bgencb
    move.l a1,adcomp
    rts
dcomphl:
    bsr initb
dbyc1hl:
    move.w d7,d1
    subq.w #1,d1
dbxc1hl:
    dbf d5,ee00
    bsr tracoulb
ee00:
    move.b d4,(a0)
    dbf d5,ee01
    bsr tracoulb
ee01:
    or.b d3,(a0)+
    dbf d1,dbxc1hl
    dbf d0,dbyc1hl
    rts
dcompvl:
    bsr initb
    move.w 6(a3),d1
    move.l a0,16(a3)
dbxc1vl:
    move.w d0,d6
dbyc1vl:
    dbf d5,ee02
    bsr tracoulb
ee02:
    tst.l d7
    blt.s dremontl
    or.b d4,(a0)
    adda.l d7,a0
    bra.s dcomml
dremontl:
    or.b d3,(a0)
    suba.l d7,a0
dcomml:
    dbf d6,dbyc1vl
    neg.l d7
    tst.l d7
    blt.s dremocl
    addq.l #1,16(a3)
dremocl:
    move.l 16(a3),a0
    dbf d1,dbxc1vl
    rts
dcomph:
    lea.l zbuf(pc),a3
    clr.w 14(a3)
    bra hcomm
dcompv:
    bsr initb
    move.w 6(a3),d1
dbxc1v:
    move.w d0,d6
dbyc1v:
    dbf d5,ee03
    bsr tracoulb
ee03:
    tst.l d7
    blt.s dremont
    or.b d4,(a0)
    bra.s dcomm
dremont:
    or.b d3,(a0)
dcomm:
    adda.l d7,a0
    dbf d6,dbyc1v
    neg.l d7
    adda.l d7,a0
    tst.l d7
    blt.s dremoc
    addq.l #1,a0
dremoc:
    dbf d1,dbxc1v
    rts
dcomph1:
    lea.l zbuf(pc),a3
    move.w #1,14(a3)
    bra hcomm
dcompv1:
    bsr initb
    move.w 6(a3),d1
dbxc1v1:
    move.w d0,d6
dbyc1v1:
    dbf d5,ee04
    bsr tracoulb
ee04:
    or.b d4,(a0)
    tst.w d1
    beq.s dunig1
    dbf d5,ee05
    bsr tracoulb
ee05:
    or.b d3,(a0)
dunig1:
    tst.w d6
    beq.s dfunigd
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dunid1
    dbf d5,ee06
    bsr tracoulb
ee06:
    or.b d3,(a0)
dunid1:
    dbf d5,ee07
    bsr tracoulb
ee07:
    or.b d4,(a0)
dfunigd:
    adda.l d7,a0
    dbf d6,dbyc1v1
    neg.l d7
    adda.l d7,a0
    addq.l #1,a0
    subq.w #1,d1
    bge.s dd1nf
    clr.w d1
dd1nf:
    dbf d1,dbxc1v1
    rts
dcomph2:
    lea.l zbuf(pc),a3
    move.w #2,14(a3)
    bra hcomm
dcompv2:
    bsr initb
    move.w 6(a3),d1
dbxc1v2:
    move.w d0,d6
dbyc1v2:
    dbf d5,ee08
    bsr tracoulb
ee08:
    or.b d4,(a0)
    tst.w d1
    beq.s dunig2
    dbf d5,ee09
    bsr tracoulb
ee09:
    or.b d3,(a0)
    cmpi.w #1,d1
    beq.s dunig2
    dbf d5,ee10
    bsr tracoulb
ee10:
    or.b d4,1(a0)
    cmpi.w #2,d1
    beq.s dunig2
    dbf d5,ee11
    bsr tracoulb
ee11:
    or.b d3,1(a0)
dunig2:
    tst.w d6
    beq.s dfunigd2
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dunid23
    cmpi.w #1,d1
    beq.s dunid22
    cmpi.w #2,d1
    beq.s dunid21
    dbf d5,ee12
    bsr tracoulb
ee12:
    or.b d3,1(a0)
dunid21:
    dbf d5,ee13
    bsr tracoulb
ee13:
    or.b d4,1(a0)
dunid22:
    dbf d5,ee14
    bsr tracoulb
ee14:
    or.b d3,(a0)
dunid23:
    dbf d5,ee15
    bsr tracoulb
ee15:
    or.b d4,(a0)
dfunigd2:
    adda.l d7,a0
    dbf d6,dbyc1v2
    neg.l d7
    adda.l d7,a0
    addq.l #2,a0
    subq.w #3,d1
    bge.s dd1nf2
    clr.w d1
dd1nf2:
    dbf d1,dbxc1v2
    rts
dcomph3:
    lea.l zbuf(pc),a3
    move.w #3,14(a3)
    bra.s hcomm
dcomph4:
    lea.l zbuf(pc),a3
    move.w #5,14(a3)
hcomm:
    bsr initb
dbyc1h4:
    move.w d7,d1
    subq.w #1,d1
dbxc1h4:
    tst.l d6
    blt dpartdr4
    dbf d5,ee16
    bsr tracoulb
ee16:
    or.b d4,(a0)
    tst.w d0
    beq dgniv4
    tst.w 14(a3)
    beq dgniv4
    dbf d5,ee17
    bsr tracoulb
ee17:
    or.b d4,0(a0,d7.w)
    cmpi.w #1,d0
    beq dgniv40
    cmpi.w #1,14(a3)
    beq dgniv40
    dbf d5,ee18
    bsr tracoulb
ee18:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #2,d0
    beq dgniv41
    cmpi.w #2,14(a3)
    beq dgniv41
    dbf d5,ee19
    bsr tracoulb
ee19:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s dgniv42
    cmpi.w #3,14(a3)
    beq.s dgniv42
    dbf d5,ee20
    bsr tracoulb
ee20:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s dgniv43
    dbf d5,ee21
    bsr tracoulb
ee21:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    dbf d5,ee22
    bsr tracoulb
ee22:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv43:
    dbf d5,ee23
    bsr tracoulb
ee23:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv42:
    dbf d5,ee24
    bsr tracoulb
ee24:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv41:
    dbf d5,ee25
    bsr tracoulb
ee25:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgniv40:
    dbf d5,ee26
    bsr tracoulb
ee26:
    or.b d3,0(a0,d7.w)
dgniv4:
    dbf d5,ee27
    bsr tracoulb
ee27:
    or.b d3,(a0)
    bra dpartcom4
dpartdr4:
    dbf d5,ee28
    bsr tracoulb
ee28:
    or.b d3,(a0)
    tst.w d0
    beq ddniv4
    tst.w 14(a3)
    beq ddniv4
    dbf d5,ee29
    bsr tracoulb
ee29:
    or.b d3,0(a0,d7.w)
    cmpi.w #1,d0
    beq ddniv40
    cmpi.w #1,14(a3)
    beq ddniv40
    adda.l d7,a0
    dbf d5,ee30
    bsr tracoulb
ee30:
    or.b d3,0(a0,d7.w)
    cmpi.w #2,d0
    beq ddniv41
    cmpi.w #2,14(a3)
    beq ddniv41
    adda.l d7,a0
    dbf d5,ee31
    bsr tracoulb
ee31:
    or.b d3,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s ddniv42
    cmpi.w #3,14(a3)
    beq.s ddniv42
    adda.l d7,a0
    dbf d5,ee32
    bsr tracoulb
ee32:
    or.b d3,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s ddniv43
    adda.l d7,a0
    dbf d5,ee33
    bsr tracoulb
ee33:
    or.b d3,0(a0,d7.w)
    dbf d5,ee34
    bsr tracoulb
ee34:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv43:
    dbf d5,ee35
    bsr tracoulb
ee35:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv42:
    dbf d5,ee36
    bsr tracoulb
ee36:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv41:
    dbf d5,ee37
    bsr tracoulb
ee37:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddniv40:
    dbf d5,ee38
    bsr tracoulb
ee38:
    or.b d4,0(a0,d7.w)
ddniv4:
    dbf d5,ee39
    bsr tracoulb
ee39:
    or.b d4,(a0)
dpartcom4:
    adda.l d6,a0
    dbf d1,dbxc1h4
    sub.w 14(a3),d0
    bge.s dd0nf4
    clr.w d0
dd0nf4:
    adda.l d7,a0
    tst.w 14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #1,14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #2,14(a3)
    beq.s addfin
    adda.l d7,a0
    cmpi.w #3,14(a3)
    beq.s addfin
    adda.l d7,a0
    adda.l d7,a0
addfin:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyc1h4
    rts
dcompdi:
    bsr initb
    clr.w d0
    clr.w d1
    move.w 6(a3),ppt
    move.w 8(a3),pga
    move.w 6(a3),savbcg
    move.w 8(a3),d6
    cmp.w 6(a3),d6
    bge.s zdiboa
    move.w 8(a3),ppt
    move.w 6(a3),pga
zdiboa:
    add.w d6,savbcg
    clr.w savbc1
    clr.w d6
    bra.s ddiok
ddiabc:
    adda.l d7,a0
    bchg #0,d0
    beq.s ddipach
    addq.l #1,a0
ddipach:
    tst.l d7
    blt.s ddiok
    subq.l #1,a0
ddiok:
    dbf d5,ee40
    bsr tracoulb
ee40:
    tst.b d0
    bne.s ddicd
       or.b	d4,(a0)
       dbf	d6,ddiabc
	bra.s	sddicd
ddicd:
    or.b d3,(a0)
    dbf d6,ddiabc
sddicd:
    addq.w #1,d1
    cmp.w savbcg(pc),d1
    bgt ddifin
    cmp.w ppt(pc),d1
    bgt.s ddipac1
    add.w #1,savbc1
ddipac1:
    cmp.w pga(pc),d1
    ble.s ddipac2
    sub.w #1,savbc1
ddipac2:
    tst.l d7
    bge.s ddirem
    cmp.w 6(a3),d1
    ble.s ddipl1
    sub.l d7,a0
    bra.s ddicom1
ddipl1:
    bchg #0,d0
    beq.s ddicom1
    addq.l #1,a0
    bra.s ddicom1
ddirem:
    cmp.w 8(a3),d1
    bgt.s ddipl2
    add.l d7,a0
    bra.s ddicom1
ddipl2:
    bchg #0,d0
    beq.s ddicom1
    addq.l #1,a0
ddicom1:
    neg.l d7
    move.w savbc1(pc),d6
    bra ddiok
ddifin:
    rts
dcomdh0:
    bsr initb
dbyc1h1i:
    move.w d7,d1
    subq.w #1,d1
dbxc1h1i:
    tst.l d6
    blt.s dpartdri
    dbf d5,ee41
    bsr tracoulb
ee41:
    or.b d4,(a0)
    tst.w d0
    beq.s dgniv1i
    dbf d5,ee42
    bsr tracoulb
ee42:
    or.b d3,0(a0,d7.w)
    bra.s dpartcoi
dgniv1i:
    dbf d5,ee43
    bsr tracoulb
ee43:
    or.b d3,(a0)
    bra.s dpartcoi
dpartdri:
    dbf d5,ee44
    bsr tracoulb
ee44:
    or.b d3,(a0)
    dbf d5,ee45
    bsr tracoulb
ee45:
    or.b d4,0(a0,d7.w)
dpartcoi:
    adda.l d6,a0
    dbf d1,dbxc1h1i
    tst.l d6
    bge.s daaddoo
    adda.l d7,a0
    adda.l d7,a0
daaddoo:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyc1h1i
    rts
dcomdv1:
    bsr initb
    move.w 6(a3),d1
dbxd1v1:
    move.w d0,d6
dbyd1v1:
    dbf d5,ee46
    bsr tracoulb
ee46:
    or.b d4,(a0)
    tst.w d1
    beq.s dundig1
    tst.w d6
    beq.s dundih1
    adda.l d7,a0
    dbf d5,ee47
    bsr tracoulb
ee47:
    or.b d3,(a0)
    suba.l d7,a0
dundih1:
    dbf d5,ee48
    bsr tracoulb
ee48:
    or.b d3,(a0)
dundig1:
    tst.w d6
    beq.s dfundigd
    subq.w #1,d6
    adda.l d7,a0
    dbf d5,ee49
    bsr tracoulb
ee49:
    or.b d4,(a0)
dfundigd:
    adda.l d7,a0
    dbf d6,dbyd1v1
    neg.l d7
    adda.l d7,a0
    addq.l #1,a0
    subq.w #1,d1
    bge.s dd1dnf
    clr.w d1
dd1dnf:
    dbf d1,dbxd1v1
    rts
dcomdv2:
    bsr initb
    move.w 6(a3),d1
dbxd1v2:
    move.w d0,d6
dbyd1v2:
    dbf d5,ee50
    bsr tracoulb
ee50:
    or.b d4,(a0)
    tst.w d1
    beq.s dundig2
    tst.w d6
    beq.s donfaca
    adda.l d7,a0
    dbf d5,ee51
    bsr tracoulb
ee51:
    or.b d3,(a0)
    suba.l d7,a0
    bra.s dfofaca
donfaca:
    dbf d5,ee52
    bsr tracoulb
ee52:
    or.b d3,(a0)
dfofaca:
    cmpi.w #1,d1
    beq.s dundig2
    dbf d5,ee53
    bsr tracoulb
ee53:
    or.b d4,1(a0)
    cmpi.w #2,d1
    beq.s dundig2
    tst.w d6
    beq.s donfaca1
    adda.l d7,a0
    dbf d5,ee54
    bsr tracoulb
ee54:
    or.b d3,1(a0)
    suba.l d7,a0
    bra.s dundig2
donfaca1:
    dbf d5,ee55
    bsr tracoulb
ee55:
    or.b d3,1(a0)
dundig2:
    tst.w d6
    beq.s dfundig2
    subq.w #1,d6
    adda.l d7,a0
    tst.w d1
    beq.s dundid23
    cmpi.w #1,d1
    beq.s dundid22
    cmpi.w #2,d1
    beq.s dundid21
    suba.l d7,a0
    dbf d5,ee56
    bsr tracoulb
ee56:
    or.b d3,1(a0)
    adda.l d7,a0
dundid21:
    dbf d5,ee57
    bsr tracoulb
ee57:
    or.b d4,1(a0)
dundid22:
    suba.l d7,a0
    dbf d5,ee58
    bsr tracoulb
ee58:
    or.b d3,(a0)
    adda.l d7,a0
dundid23:
    dbf d5,ee59
    bsr tracoulb
ee59:
    or.b d4,(a0)
dfundig2:
    adda.l d7,a0
    dbf d6,dbyd1v2
    neg.l d7
    adda.l d7,a0
    addq.l #2,a0
    subq.w #3,d1
    bge.s dd1ndf2
    clr.w d1
dd1ndf2:
    dbf d1,dbxd1v2
    rts
dcomdh1:
    lea.l zbuf(pc),a3
    move.w #1,14(a3)
    bra hdomm
dcomdh2:
    lea.l zbuf(pc),a3
    move.w #2,14(a3)
    bra hdomm
dcomdh3:
    lea.l zbuf(pc),a3
    move.w #3,14(a3)
    bra hdomm
dcomdh4:
    lea.l zbuf(pc),a3
    move.w #5,14(a3)
hdomm:
    bsr initb
dbyd1h4:
    move.w d7,d1
    subq.w #1,d1
dbxd1h4:
    tst.l d6
    blt dparddr4
    dbf d5,ee60
    bsr tracoulb
ee60:
    or.b d4,(a0)
    tst.w d0
    beq dgndiv4
    dbf d5,ee61
    bsr tracoulb
ee61:
    or.b d3,0(a0,d7.w)
    cmpi.w #1,d0
    beq dgndiv40
    cmpi.w #1,14(a3)
    beq	dgndiv40
    dbf d5,ee62
    bsr tracoulb
ee62:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #2,d0
    beq.s dgndiv41
    cmpi.w #2,14(a3)
    beq.s dgndiv41
    dbf d5,ee63
    bsr tracoulb
ee63:
    adda.l d7,a0
    or.b d3,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s dgndiv42
    cmpi.w #3,14(a3)
    beq.s dgndiv42
    dbf d5,ee64
    bsr tracoulb
ee64:
    adda.l d7,a0
    or.b d4,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s dgndiv43
    dbf d5,ee65
    bsr tracoulb
ee65:
    adda.l d7,a0
    or.b d3,0(a0,d7.w)
    dbf d5,ee66
    bsr tracoulb
ee66:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
dgndiv43:
    dbf d5,ee67
    bsr tracoulb
ee67:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgndiv42:
    dbf d5,ee68
    bsr tracoulb
ee68:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
dgndiv41:
    dbf d5,ee69
    bsr tracoulb
ee69:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
dgndiv40:
    dbf d5,ee70
    bsr tracoulb
ee70:
    or.b d4,0(a0,d7.w)
dgndiv4:
    dbf d5,ee71
    bsr tracoulb
ee71:
    or.b d3,(a0)
    bra dpardcom4
dparddr4:
    dbf d5,ee72
    bsr tracoulb
ee72:
    or.b d3,(a0)
    tst.w d0
    beq ddndiv4
    dbf d5,ee73
    bsr tracoulb
ee73:
    or.b d4,0(a0,d7.w)
    cmpi.w #1,d0
    beq ddndiv40
    cmpi.w #1,14(a3)
    beq	ddndiv40
    adda.l d7,a0
    dbf d5,ee74
    bsr tracoulb
ee74:
    or.b d3,0(a0,d7.w)
    cmpi.w #2,d0
    beq.s ddndiv41
    cmpi.w #2,14(a3)
    beq.s ddndiv41
    adda.l d7,a0
    dbf d5,ee75
    bsr tracoulb
ee75:
    or.b d4,0(a0,d7.w)
    cmpi.w #3,d0
    beq.s ddndiv42
    cmpi.w #3,14(a3)
    beq.s ddndiv42
    adda.l d7,a0
    dbf d5,ee76
    bsr tracoulb
ee76:
    or.b d3,0(a0,d7.w)
    cmpi.w #4,d0
    beq.s ddndiv43
    adda.l d7,a0
    dbf d5,ee77
    bsr tracoulb
ee77:
    or.b d4,0(a0,d7.w)
    dbf d5,ee78
    bsr tracoulb
ee78:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
ddndiv43:
    dbf d5,ee79
    bsr tracoulb
ee79:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddndiv42:
    dbf d5,ee80
    bsr tracoulb
ee80:
    or.b d3,0(a0,d7.w)
    suba.l d7,a0
ddndiv41:
    dbf d5,ee81
    bsr tracoulb
ee81:
    or.b d4,0(a0,d7.w)
    suba.l d7,a0
ddndiv40:
    dbf d5,ee82
    bsr tracoulb
ee82:
    or.b d3,0(a0,d7.w)
ddndiv4:
    dbf d5,ee83
    bsr tracoulb
ee83:
    or.b d4,(a0)
dpardcom4:
    adda.l d6,a0
    dbf d1,dbxd1h4
    sub.w 14(a3),d0
    bge.s dd0dnf4
    clr.w d0
dd0dnf4:
    adda.l d7,a0
    adda.l d7,a0
    cmpi.w #1,14(a3)
    beq.s daddfin
    adda.l d7,a0
    cmpi.w #2,14(a3)
    beq.s daddfin
    adda.l d7,a0
    cmpi.w #3,14(a3)
    beq.s daddfin
    adda.l d7,a0
    adda.l d7,a0
daddfin:
    neg.l d6
    adda.l d6,a0
    dbf d0,dbyd1h4
    rts
initb:
    lea.l zbuf(pc),a3
    move.l adcoq(pc),a1
    move.l adcoc(pc),a2
    move.w 8(a3),d0
    clr.l d7
    move.w 6(a3),d7
    addq.w #2,d7
    lsr.w #1,d7
	move.l	adcomp(pc),a0
	move.l	a0,d5
	btst	#0,d5
	beq.s	dapair
	clr.b	(a0)+
dapair: move.w	d7,d5
	mulu	d0,d5
	add.l	d7,d5
	addq.l	#4,d5
	lsr.l	#6,d5
	moveq	#0,d6
bef:	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	move.l	d6,(a0)+
	dbf	d5,bef
    move.l #1,d6
    move.l adcomp(pc),a0
    clr.l d5
    clr.b d2
    rts
tracoulb:
    clr.w d5
    clr.w d4
bchgtco:
    bchg #1,d2
    beq.s demgau
    move.b (a1)+,d4
    andi.b #$0f,d4
    bra.s demfin
demgau:
    move.b (a1),d4
    lsr.b #4,d4
demfin:
    add.w d4,d5
    cmpi.b #$0f,d4
    beq.s bchgtco
    bchg #0,d2
    beq.s pcada2
    move.b (a2)+,d3
    andi.b #$0f,d3
	move.b	d3,d4
	lsl.b	#4,d4
	subq.w	#1,d5
	rts
pcada2:
    move.b (a2),d3
	move.b	d3,d4
	and.b	#$f0,d4
    lsr.b #4,d3
	subq.w	#1,d5
	rts
tabadcb:
    bra atcara
    bra dcomph
    bra dcompv
    bra dcomph1
    bra dcompv1
    bra dcomph2
    bra dcompv2
    bra dcomphl
    bra dcompvl
    bra dcomph3
    bra dcomph4
    bra dcompdi
    bra dcomdh1
    bra dcomdh0
    bra dcomdv1
    bra dcomdh2
    bra dcomdv2
    bra dcomdh3
    bra dcomdh4
    bra atcara

flsprite:	dc.l	0
adfi:  dc.l 0
xcoor: dc.w 0
ycoor: dc.w 0
tailx:	blk.w 1,0
taily:	blk.w 1,0
adcomp:	 blk.l 1,0
adecr:	dc.l	0
adcoc:	  blk.l 1,0
adcoq:	  blk.l 1,0
adanc:	  blk.l 1,0
adanq:	  blk.l 1,0
plcomp:	 blk.l 1,0
plaff:	  blk.l 1,0
tailcou:  blk.l 1,0
typfi:	  dc.b 0
nbcar:	  dc.b 0
filin:	  dc.w 0
boucy:	  dc.w 0
maskdeb:  dc.w 0
maskfi:	 dc.w 0
ppt:	  dc.w 0
pga:	  dc.w 0
savbcg:	 dc.w 0
savbc1:	 dc.w 0
zbuf:		blk.l 6,0

ESSAI:	move.l	#adchrg,a0   ;adr du fichier logi
	move.w	nolog,d0
	clr.w	err
	cmp.w	#200,d0
	ble.s	SESSA
	rts
SESSA:	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	beq.s	ESSER
	add.w	d0,a0
	clr.w	d0
	move.b	6(a0),d0
	bne.s	yaob
ESSER:	move.w	#1,err
	rts
yaob:	clr.w	d1
	move.b	7(a0),d1
	blt.s	syaob
	move.w	d1,naobj
	movem.l a0/d0,-(a7)
	jsr	iniobj
	movem.l (a7)+,d0/a0
syaob:	addq.w	#8,a0
	subq.w	#2,d0
	bge.s	byaob
	rts
byaob:	clr.w	d1
	move.b	(a0),d1
	blt.s	s1yaob
	move.w	d1,naobj
	movem.l a0/a1/d0,-(a7)
	jsr	iniobj
	movem.l (a7)+,d0/a0/a1
s1yaob: lea.l	4(a0),a0
	dbf	d0,byaob
	rts
;********* ROUT TEST CRASH  
;	A4 EN ENTREE SUR OCNUR
;	SORTIE
;	D7	NO DE RT CRAS OU ZERO
;	D4	-80=GCHE  0=CTRE	80  DRTE
tstcra:
	move.l	#adchrg,a0   ;adr du fichier logi
	clr.w	d0
	move.b	(a4),d0	    ;pointe sur ocnur
	cmp.w	#200,d0
	bge	cra3d
	add.w	d0,d0
	add.w	0(a0,d0.w),a0
	clr.w	d7	;init cras
	move.b	(a0),d7
	beq.s	adrcra
	tst.w	JUMPE+2
	blt.s	paju
	bclr	#6,d7
	bne.s	paju
	cmp.w	#-188,htprl
	blt.s	fcra
paju:	move.b	7(a0),d0    ;no phys
	ext.w	d0
	bge.s	craobj
	bra	cravec
fcra:	clr.w	d7
adrcra:
	move.w	d7,cracra	;a virer
	move.w	d4,cracra+2	;a virer
	rts
cracra: dc.w	0,0
craobj: lea.l	tabobj(pc),a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a0
	move.w	2(a0),d4
	subq.w	#1,d4

	move.l	a0,a1	;seq
	move.l	a0,a2	;obj
	add.w	2(a0),a0
	addq.w	#4,a0
	add.w	d4,d4
	add.w	(a0)+,a2
	add.w	6(a0,d4.w),a1
	clr.w	d0
	move.b	(a1)+,d0  ;no sprit
	lsl.w	#3,d0
	add.w	d0,a2
	clr.w	d0
	move.b	4(a2),d0    ;larg-1
creccr: move.w	XB,d2
	move.w	6(a4),d1
	blt.s	tgaob
	add.w	#255,d2
	bra.s	tgdob
tgaob:	sub.w	#255,d2
	sub.w	d0,d2
tgdob:	lsl.w	#1,d1
	asr.w	#1,d1
	add.w	d1,d2
	bsr	tcrcoo
	bra	adrcra
tcrcoo: tst.w	d2
	blt.s	tcrga
	cmp.w	#80,d2
	bgt.s	patouc
tcrdr:	move.w	#80,d0
	sub.w	d2,d0
	lsr.w	#1,d0
	move.w	#80,d4
	sub.w	d0,d4
	rts
tcrga:	add.w	d0,d2
	cmp.w	#-80,d2
	blt.s	patouc
	cmp.w	#80,d2
	ble.s	tcrga1
	sub.w	d0,d2
	cmp.w	#-80,d2
	bge.s	tcrdr
	clr.w	d4
	rts
tcrga1: move.w	#-80,d0
	sub.w	d2,d0
	asr.w	#1,d0
	move.w	#-80,d4
	sub.w	d0,d4
touc:	rts
patouc: clr.w	d7
	rts
cra3d:	clr.w	d7
	cmp.b	#254,d0
	beq.s	sorcra
	sub.w	#220,d0
	lea.l	trtc3d(pc),a0
	move.b	0(a0,d0.w),d7
	beq.s	sorcra	   
	lea.l	tcra3d(pc),a0
	lsl.w	#3,d0
	add.w	d0,a0
	move.w	XB,d2
	add.w	(a0)+,d2
	move.w	(a0)+,d0
	blt.s	sorcra
	move.w	d7,d6
	bsr	tcrcoo
	tst.w	d7
	bne	adrcra
	move.w	d6,d7
	move.w	XB,d2
	add.w	(a0)+,d2
	move.w	(a0),d0
	blt.s	sorcra
	bsr	tcrcoo
	bra	adrcra
cravec: lea.l	tcrave(pc),a0
	neg.w	d0
	subq.w	#2,d0
	bge.s	crapv
sorcra: clr.w	d7
	bra	adrcra
crapv:	cmp.w	#48,d0
	bge.s	crarec
	lsl.w	#3,d0
	add.w	d0,a0
	move.w	2(a0),d0    ;larg-1
	blt.s	sorcra
	move.w	XB,d2
	move.w	6(a4),d1
	blt.s	tgave
	add.w	#255,d2
	bra.s	tgdve
tgave:	sub.w	#255,d2
	sub.w	d0,d2
tgdve:	lsl.w	#1,d1
	asr.w	#1,d1
	add.w	d1,d2
	add.w	(a0),d2
	lea.l	4(a0),a0
	move.w	d7,d6
	bsr	tcrcoo
	tst.w	d7
	bne	adrcra
	move.w	d6,d7
	move.w	2(a0),d0    ;larg-1
	blt.s	sorcra
	move.w	XB,d2
	move.w	6(a4),d1
	blt.s	tgave1
	add.w	#255,d2
	bra.s	tgdve1
tgave1: sub.w	#255,d2
	sub.w	d0,d2
tgdve1: lsl.w	#1,d1
	asr.w	#1,d1
	add.w	d1,d2
	add.w	(a0),d2
	bsr	tcrcoo
	bra	adrcra
crarec: sub.w	#48,d0
	add.w	d0,d0
	add.w	d0,d0
	lea.l	trect,a0
	move.w	2(a0,d0.w),d0
	bra	creccr
trtc3d: dc.b	1,0,1,1,1,0,1,0,1,0,0,0,1,0
tcra3d: DC.W	-829,510,319,510	 ;AV PONT
	DC.W	0,-1,0,-1	    ;AR PONT
	DC.W	510,160,0,-1	    ;AV GARA
	DC.W	510,160,0,-1	    ;AR GARA
	DC.W	0,-1,0,-1	    ;AV TRBD
	DC.W	0,-1,0,-1	    ;AR TRBD
	DC.W	0,-1,0,-1	    ;AV TRBG
	DC.W	0,-1,0,-1	    ;AR TRBG
	DC.W	-1279,960,319,960   ;AV PONT2
	DC.W	0,-1,0,-1	    ;AR PONT2
	DC.W	0,-1,0,-1	    ;AV PLAQ
	DC.W	0,-1,0,-1	    ;AR PLAQ
	DC.W	-382,63,319,63	    ;AV PNTR
	DC.W	0,-1,0,-1	    ;AR PNTR
tcrave: DC.W	255,16,654,16	;CADRA1
	DC.W	0,16,654,16   ;CADRA2
	DC.W	-255,16,654,16	 ;CADRA3
	DC.W	255,16,654,16	;CADRB1
	DC.W	0,16,654,16   ;CADRB2
	DC.W	-255,16,654,16	 ;CADRB3
	DC.W	0,12,0,-1	;LAMPA16
	DC.W	0,6,0,-1 ;LAMPA8 
	DC.W	0,16,0,-1	;LAMPB16
	DC.W	0,6,0,-1 ;LAMPB8
	DC.W	0,32,0,-1	;PDBL1 
	DC.W	0,64,0,-1	;PDBL2
	DC.W	0,96,0,-1	;PDBL3
	DC.W	0,6,0,-1 ;PSPL1
	DC.W	0,6,0,-1 ;PSPL2
	DC.W	0,6,0,-1 ;PSPL3
	DC.W	0,16,0,-1	;LAMPC16
	DC.W	0,80,0,-1	;PDBL4
	DC.W	0,120,0,-1	 ;PDBL5 
	DC.W	0,160,0,-1	 ;PDBL6
	DC.W	0,200,0,-1	 ;PDBL7

recrec: move.l	adecr(pc),a0
	add.l	#10560+320,a0
	move.l	#906000,a1
	add.l	#10560+320,a1
	move.w	#535-8,d0
bre:	
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d0,bre
	rts
JOY:	dc.w	0,160,100,0,0,0,0,0
*********************
*  GESTION CLAVIER  *
*********************
*
* Buffer Clavier
*
* 0 = bouton  (0=Rien, 1=Souris G, 2=Souris D ou Fire, 3=1+2)
* 2 = X Mouse
* 4 = Y Mouse
* 6 = ScanCode Clavier 
* 8 = Joystick 
* 10= N/A

* INICLAV - Init Clavier
* 
INICLAV: clr	  flagprog
	bclr	#3,$fffa17
	move.l	$70,sav_vbl
	move.l	#RTE,$70
	move.l	 #JOY,tab_clav
	move.l	 $118,old_clav
	move.l	 #new_clav,$118
	move.l	 #-1,-(A7)
	move.l	 #-1,-(A7)
	move.l	 #-1,-(A7)
	move.w	 #$10,-(A7)
	trap	 #14
	adda.l	 #14,A7
	move.l	 D0,A0
	move.l	 4(A0),TASCII
	rts
RTE:	subq.w	#1,nbvbl
	bgt.s	FRTE
	move.w	#52,nbvbl
	movem.l d0/d1,-(sp)
	move.w	compt,d1
	move.w	d1,d0
	sub.w	cptvbl(pc),d0
	move.w	d1,cptvbl
	move.w	d0,cptvbl+2
	movem.l (sp)+,d0/d1
FRTE:	rte
nbvbl:	dc.w	50*5
cptvbl: dc.w	0,0
tevi:	dc.b	$1b,"Y",32+6,32+12,"VITES ",0,0,0
	EVEN
* CNVACSI - Convert to ASCII Routine
* Input :	 D0.W Contains ScanCode

CNVASCI: MOVEQ	  #0,D6
	move.l	 TASCII(pc),A0
	btst	 #7,D0
	bne.s	 CNVASC1
	move.b	 0(A0,D0.w),D6
	SWAP	D0
	MOVE.W	D6,D0
CNVASC1: rts

TASCII:	dc.l		0    ;Adresse tableau de conversion (128 Octets)

* New Clavier Interrupt Routine
*

new_clav:     andi    #$2500,SR
	      movem.l D0/A0,-(A7)
	      move.l  tab_clav(PC),A0
clav01:	     clr.w   D0
	      move.b  $fffffc00,D0
	      btst    #7,D0
	      beq     finclav
	      btst    #0,D0
	      beq     fin1clav
	      move.b  $fffffc02,D0
	      tst.w   10(A0)
	      bne.s   clav6
	      cmpi.w  #$00ff,D0
	      beq     clav4
clav6:	      cmpi.w  #4,10(A0)
	      bne.s   clav5
	      move.w  D0,8(A0)
	      clr     10(A0)
	      bra     finclav
clav5:	      cmpi.w  #$f8,D0
	      blt.s   clav1
	      tst.w   10(A0)
	      bne.s   clav1
	      move.w  #1,10(A0)
	      andi.w  #3,D0
	      move.b  chngbit(PC,D0.W),1(A0)
	      bra     finclav
chngbit:      dc.b    0,2,1,3
clav1:	      cmpi.w  #1,10(A0)
	      bne.s   clav2
	      addq.w  #1,10(A0)
	      ext.w   D0
	      add.w   D0,2(A0)
	      bra     finclav
clav2:	      cmpi.w  #2,10(A0)
	      bne.s   clav3
	      clr     10(A0)
	      ext.w   D0
	      add.w   D0,4(A0)	    ;SUB.W   D0,4(A0)********
	      bra     finclav
clav3:	      move.w  D0,6(A0)
	      cmpi.w  #$61,D0	   ;<UNDO> = Return to Bureau
	      bne.s   clav8
	      move.w  #1,flagprog	 
	      bra     finclav
clav8:	      cmp.w	#$44,d0
	      bne.s	cla62
	      subq.w	#1,p_champ
	      bge.s	finclav
	      move.w	#3,p_champ
	      bra.s	finclav
cla62:	      cmpi.w  #$62,D0		;<HELP> = Return to Debug 
	      bne.s   finclav 
	      move.l  old_clav(PC),$118
	      move.l  sav_vbl(PC),$70
	      bra.s   finclav
clav4:	      move.w  #4,10(A0)
	      bra.s   finclav
fin1clav:     and.b   #$20,D0
	      beq.s   finclav
	      move.b  $fffc02,D0
finclav:      btst    #4,$fffa01
	      beq     clav01
	      movem.l (A7)+,D0/A0
	      rte

tab_clav:     dc.l    0	     
old_clav:     dc.l    0
nbob:	dc.w	0
nbsprit: dc.w	0
sav_tic: dc.l	0
sav_vbl:      dc.l    0
flagprog:     dc.w    00
finprog:      dc.w    $4AFC    ;illegal Instruction
ttobj:	blk.l	64,0
dejo:	blk.l	32,0
adchrg: blk.l	800,0

