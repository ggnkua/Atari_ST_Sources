	OPT	O+,T-,OW2-		;,OW3-
;	OUTPUT	A:\MADMAX.PRG
	output	madmax.prg
DEBUG=0
orgpres=$50000
;
; BUGS A CORRIGER :
;
;	- mettre init STE
;	- mettre acc‚l‚ration quand on appuie sur haut ou bas
;	- scrolling positionnement musique … r‚‚crire
;	- recentrer les noms des musiques
;	- bug dans packer COSO laisse des octets non compress‚s
;	- CHAM1 et CHAM3 ont ‚t‚ d‚gag‚s
;	- mettre labels Madmax dans replay
;	- param‚trer le timer du replay
;	- mettre compteur de cycles dans replay
;
FINAL=1
NOTPACKED=0		;0=PAS PACKE
;PAK=1			;0=PACKER BYTES
CHRONO=0

BASEVOL=$74C
BASEBCL=$81A
;
; F2->s‚quentiel automatique
; F3->random automatique
; F4->s‚quentiel automatique 20s
; F5->random automatique 20s
;
; nouvelle version avec scrolling vertical incr‚mental
;
; dans replay :
;	- d‚gager convertisseur volumes
;	- convertir les digits 4 bits
;	- enlever Chamber digit (les 2 derniŠres)
;
; liste des bugs :
;	- espace devant Chambers
;
FIRSTMUS=136
basemfp=$40
NBMUS=257		;NB MUSIQUES IMPLEMENTEES

longueur_musiques=390672

;	IFEQ	PAK
;longueur_packe=196110
;	ELSEIF
;longueur_packe=158674
;	ENDC
check1=$55DC1161
check2=$BCA5A15F

LARGE=32
PLANMENU=0
ramtop=$80000
hauteur=NBMUS*8+200-8
ecran1=ramtop-32000
ecran0=ecran1-32000
scroller=ecran0-(26*8*LARGE)
finscroller=ecran0
;
;	- bug dans EXTRACT (il faut d‚truire le .PRG avant de sauver le .BIN)
;
CPU	MACRO
	CMP.B	#$F,(key).W		;TAB ??
	BNE.S	.\@
	MOVE	#\1,$FFFF8240.W
.\@
	ENDM
;
	section	text

	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	LEA	$80000,A7

	MOVEM.L	TRANS(PC),D0-D7
	MOVEM.L	D0-D7,-(A7)
	LEA	CODE(PC),A1
	LEA	DEBUTCODE,A2

	IFEQ	DEBUG
	lea	fin_debugger,a3
	ELSEIF
	LEA	fin_loadmusiques,A3
	ENDC
	JMP	(A7)
TRANS:
COPYCOD:MOVE.L	(A1)+,(A2)+
	MOVE	A1,$FFFF8240.W
	CMP.L	A3,A2
	BLO.S	COPYCOD
	CLR	$FFFF8240.W
	JMP	STARTPRG

	offset	$80
debut_offset:
sync:	ds.w	1
lastchoice:ds.w	1
lastcpt:ds.w	1
newchoice:ds.w	1
vit:	ds.l	1
lastkey:ds.b	1
key:	ds.b	1
	even

cpt:	ds.l	1
ecran:	ds.l	1
;
SHIFT:	DS.W	1
CPTXT:	DS.W	1
PTRTEXT:DS.L	1
PTBUF:	DS.L	1
FLIPBUG:DS.W	1
	IFEQ	CHRONO
count:	ds.b	4
	ENDC

TBSIN:	DS.B	80
BUG1:	DS.W	80
BUG2:	DS.W	80

automatique:ds.w	1
seed:	ds.w	1
j:	ds.l	1
k:	ds.l	1
tbrnd:	ds.w	55

	ds.l	50			;la pile !!!!
pile:
fin_offset:
	section	text
CODE
	org	$3100
DEBUTCODE
;
STARTPRG
	move	#$2700,sr

	LEA	pile.w,SP		;NOUVEAU POINTEUR DE PILE !!!

	IFEQ	DEBUG

	lea	debugger,a0
	lea	$90000,a1
	move	#(fin_debugger-debugger)/2-1,d0
.movdeb
	move	(a0)+,(a1)+
	dbra	d0,.movdeb
	jsr	$90000

	ENDC 

	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)
	move.b	#$10,$fffffa17.w

	lea	debut_offset.w,a0
	lea	fin_offset.w,a1
	moveq	#0,d0
clearmem
	move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	clearmem

	lea	ecran0,a0
	move	#(ramtop-ecran0)/4-1,d1
	moveq	#0,d0
.cls	move.l	d0,(a0)+
	dbra	d1,.cls


	IFNE	FINAL
.ikb1	btst	#1,$fffffc00.w
	beq.s	.ikb1
	move.b	#$12,$fffffc02.w	;cut mouse
	move	#1000,d0
.ikb3	dbra	d0,.ikb3
.ikb2	btst	#1,$fffffc00.w
	beq.s	.ikb2
	move.b	#$1a,$fffffc02.w	;cut joysticks
	ENDC
;
; d‚placement du code de la musique
;
	lea	loadmusiques,a0
	lea	fin_loadmusiques,a1
	lea	orgpres+fin_loadmusiques-loadmusiques,a6
.moveall
	move	-(a1),-(a6)
	move	a1,$ffff8240.w
	cmp.l	a0,a1
	bhi.s	.moveall
;
; d‚packer ici le code
;
; envoyer adresse d‚packing dans A6
; retour D0=type de ST
;
	lea	loadmusiques,a6
	jsr	orgpres

;.plante
;	addq	#7,$ffff8240.w
;	bra.s	.plante
;
; init rasters
;
;	clr.b	$fffffa1b.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
;
;
;	MOVEQ	#1,D0
	BSR	REPLAY+0		;INIT ST

	move.l	#ecran1,d0
	move.l	d0,ecran.w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	ecran0,a0
	move	#(ramtop-ecran0)/4-1,d1
	moveq	#0,d0
.cls2	move.l	d0,(a0)+
	dbra	d1,.cls2

	bsr	INITSINE

x	set	(200-8)/2*160+4+8	;dans PLANMENU
	lea	ecran0+x,a0
	lea	6*160(a0),a1

	lea	motif1,a2
	moveq	#4-1,d7
.copy
	move	(a2)+,d0
	move	d0,(a0)
	move	d0,ecran1-ecran0(a0)
	move	d0,(a1)
	move	d0,ecran1-ecran0(a1)

	move	(a2)+,d0
	move	d0,144-16+8(a0)
	move	d0,ecran1-ecran0+144-16+8(a0)
	move	d0,144-16+8(a1)
	move	d0,ecran1-ecran0+144-16+8(a1)

	lea	160(a0),a0
	lea	-160(a1),a1

	dbra	d7,.copy
;
;	move.l	#ecran0,ecran.w

	move	#-1,lastchoice.w
	move	#$8000,lastcpt.w

	bsr	init_refresh
	move	#(FIRSTMUS-1)*8,d0
	move	d0,cpt.w		;premiŠre musique
	bsr	inverse

	lea	tbrnd.w,a0
	moveq	#55-1,d0
	moveq	#1,d1
fillrnd:
	move	d1,(a0)+
	add	#65536/55,d1
	dbra	d0,fillrnd
	move.l	#23*2+tbrnd,j.w
	move.l	#54*2+tbrnd,k.w

	clr	automatique.w

	IFEQ	CHRONO
	clr.l	count.w
	ENDC

	IFNE	FINAL
	bsr	checke
	ENDC

	move.l	#init_vbl,$70.w
;	stop	#$2300
	move	#$2300,sr
;	stop	#$2300
;	clr.b	$ffff8260.w
;	move.b	#2,$ffff820a.w
	move.l	#prgvbl,$70.w

mainloop
;
; genrnd
;
	move.l	k.w,a0
	move.l	j.w,a1
	move	(a1),d0
	add	d0,(a0)
	move	(a0),d0
	mulu	#NBMUS,d0
	swap	d0
	move	d0,seed.w

	subq.l	#2,j.w
	cmp.l	#tbrnd,j.w
	bhs.s	ok1
	add.l	#55*2,j.w
ok1:
	subq.l	#2,k.w
	cmp.l	#tbrnd,k.w
	bhs.s	ok2
	add.l	#55*2,k.w
ok2:

	IFEQ	CHRONO
	move.l	ecran.w,a6
	addq	#2,a6		;2Šme plan
	clr	d0
	move.b	count.w,d0
	bsr	bigfnt
	moveq	#10,d0
	bsr	bigfnt
	clr	d0
	move.b	count+1.w,d0
	bsr	bigfnt
	clr	d0
	move.b	count+2.w,d0
	bsr	bigfnt
	ENDC
	BRA.S	mainloop

inverse:
	move	d0,newchoice.w
	move	lastchoice.w,d0
	bmi.s	.nochoice
	bsr	invert_line
.nochoice:
	move	newchoice.w,d0
	addq	#7,d0		;arrondi
	and	#-8,d0		;d0=num‚ro du pav‚ … inverser*8
	move	d0,lastchoice.w
	bsr	invert_line

	move	newchoice.w,d0
	addq	#7,d0
	lsr	#3,d0
	clr.l	count.w
	bra	INITMUS
;vbl:	addq	#1,sync.w
;	rte
prgvbl:
	movem.l	d0-d7/a0-a6,-(sp)

	movem.l	palette(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w

	eor.l	#ecran0^ecran1,ecran.w
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.b	$fffffc02.w,key.w

	moveq	#0,d0
	move	cpt.w,d0
	lsr	#3,d0
	divu	#(lasthbl-hbl1)/14,d0
	swap	d0
	mulu	#14,d0
	add.l	#hbl1,d0

	IFNE	FINAL
	cmp.l	#lasthbl,d0
	blo.s	.ok
	illegal
.ok
	ENDC

	clr.b	$fffffa1b.w
	move.l	d0,branche+2

	move	cpt.w,d1
	and	#7,d1
	neg	d1
	addq	#8,d1
	move.b	d1,$fffffa21.w
	move.l	#hbl0,basemfp+$20.w
	move.b	#8,$fffffa1b.w

	sub.l	#14,d0
	cmp.l	#hbl1,d0
	bhs.s	.ok2
	add.l	#lasthbl-hbl1,d0
.ok2

	IFNE	FINAL
	cmp.l	#lasthbl,d0
	blo.s	.ok3
	illegal
.ok3
	ENDC

	move.l	d0,a0
	move	2(a0),$ffff8242.w

	moveq	#7,d0
	and	cpt.w,d0	;s'arrete aux multiples de 8 !!!
	bne.s	.paclrvit
	clr	vit.w
.paclrvit

	move.b	key.w,d0
	cmp.b	#$48,d0
	bne.s	.paup
	move	#-2,vit.w
	clr	automatique.w
.paup
	cmp.b	#$50,d0
	bne.s	.padn
	move	#2,vit.w
	clr	automatique.w
.padn

	move	automatique.w,d0
	add	d0,d0
	add	d0,d0
	jmp	.auto(pc,d0.w)
.auto
	bra.w	.nodict
	bra.w	.auto1
	bra.w	.auto2
	bra.w	.auto3
	bra.w	.auto4

.auto3	cmp.l	#$00020000,count.w	;20 secondes ???
	bhs.s	.BCL1
.auto1
	TST.B	REPLAY+BASEBCL
	beq.s	.deplace
.BCL1
	move	lastchoice.w,d0
	addq	#8,d0
	cmp	#NBMUS*8,d0
	blo.s	.low8
	clr	d0
.low8
	bsr	inverse
	bra.s	.deplace
.auto4
	cmp.l	#$00020000,count.w	;20 secondes ???
	bhs.s	.BCL2
.auto2
	TST.B	REPLAY+BASEBCL
	beq.s	.deplace
.BCL2
	move	seed.w,d0
	asl	#3,d0
	bsr	inverse
 .deplace:
	moveq	#0,d0
	move	lastchoice.w,d1
	move	cpt.w,d3
	move	d1,d2
	asr	d2
	move.l	vit.w,d4
	beq.s	.noadd
	
	cmp	d3,d2
	bgt.s	.sub
	addq.l	#10,d4
	bra.s	.noadd
.sub:
	subq.l	#10,d4
.noadd:
	move.l	d4,vit.w

	move	vit.w,d0
	add	cpt.w,d0
	cmp	#hauteur-200,d0
	bls.s	1$
	neg	vit.w
	add	vit.w,d0
1$
	move	d0,cpt.w

	clr.b	REPLAY+BASEBCL
;
	move.b	key.w,d0
	cmp.b	lastkey.w,d0
	beq.s	.notspc
	move.b	d0,lastkey.w

	cmp.b	#$3b,d0		;F1
	bne.s	.pamod0
	st	REPLAY+BASEBCL
	bra.s	.notspc
.pamod0

	cmp.b	#$44,d0
	bne.s	.paquit
	move.l	4.w,a0
	jmp	(a0)
.paquit
	move	d0,d1
	sub.b	#$3C,d1		;F2-F5
	cmp.b	#4,d1
	bhs.s	.pamod
	ext	d1
	addq	#1,d1
	move	d1,automatique.w
	bra.s	.notspc
.pamod:

	cmp.b	#$39,d0
	bne.s	.notspc
	clr	automatique.w
	move	cpt.w,d0
	bsr	inverse
;
; rajout d‚buggage
;
	moveq	#0,d0
	move	lastchoice.w,d1
	sub	cpt.w,d1
	beq.s	.mov0
	bpl.s	.mov1
	subq	#4,d0
.mov1	addq	#2,d0
.mov0
	move	d0,vit.w
;
;
	bra.s	.newmus
.notspc
	bsr	REPLAY+4+4
.newmus

	move.l	ecran.w,a6

x	set	(200-8)/2*160+PLANMENU*2		;dans PLANMENU
;
; affichage des curseurs
;
	IFEQ	1
	MOVEQ	#0,D0
	move	#%0000001111000000,d1
	move	d1,x+8(a6)
	move	#%0000000011110000,d2
	move	d2,x+8+160(a6)
	move	#%1111111000111100,d3
	move	d3,x+8+160*2(a6)
	move	#%0111111111111111,x+8+160*3(a6)
	move	d3,x+8+160*4(a6)
	move	d2,x+8+160*5(a6)
	move	d1,x+8+160*6(a6)

	move	#%0000001111000000,d1
	move	d1,x+144(a6)
	move	#%0000111100000000,d2
	move	d2,x+144+160(a6)
	move	#%0011110001111111,d3
	move	d3,x+144+160*2(a6)
	move	#%1111111111111110,x+144+160*3(a6)
	move	d3,x+144+160*4(a6)
	move	d2,x+144+160*5(a6)
	move	d1,x+144+160*6(a6)

.no3d:
	ENDC

	bsr	aff_scroll

	IFEQ	CHRONO
	addq.b	#1,count+3.w
	cmp.b	#50,count+3.w
	blo.s	.low50
	clr.b	count+3.w
	addq.b	#1,count+2.w
	cmp.b	#10,count+2.w
	blo.s	.low50
	clr.b	count+2.w
	addq.b	#1,count+1.w
	cmp.b	#6,count+1.w
	blo.s	.low50
	clr.b	count+1.w
	addq.b	#1,count.w
	cmp.b	#10,count.w
	blo.s	.low50
	clr.b	count.w
.low50
	ENDC

	BSR	SINE

	CPU	$444

	movem.l	(sp)+,d0-d7/a0-a6
init_vbl:
	rte

	IFEQ	CHRONO
bigfnt:
	asl	#5,d0
	lea	bigfonte,a0
	add	d0,a0
	moveq	#8-1,d1
.aff
	move.l	(a0)+,d0
	move	d0,8(a6)
	move	d0,8+160(a6)
	move	d0,8+160*2(a6)
	move	d0,8+160*3(a6)
	swap	d0
	move	d0,(a6)
	move	d0,160(a6)
	move	d0,160*2(a6)
	move	d0,160*3(a6)
	lea	4*160(a6),a6
	dbra	d1,.aff
	lea	-4*160*8+16(a6),a6
	rts
	ENDC

	IFNE	FINAL
checke:
	IFEQ	NOTPACKED
	RTS
	ENDC

	lea	loadmusiques,a0
	move.l	a0,a1
	add.l	#(longueur_musiques)&-4,a1
	moveq	#0,d0
	moveq	#0,d1
sum:
	move.l	(a0)+,d2
	eor.l	d2,d0
	add.l	d2,d1
	cmp.l	a1,a0
	blo.s	sum

	cmp.l	#check1,d0
	bne.s	.no
	cmp.l	#check2,d1
	beq.s	.ok
.no:	moveq	#-1,d7
	illegal
.ok:
	RTS
	ENDC

invert_line:
	add	#12*8,d0

	move	d0,d1
	sub	lastcpt.w,d0
	cmp	#26*8,d0
	bhs	degage

	moveq	#0,d0
	move	d1,d0

	lsr	#3,d0
	divu	#26,d0
	swap	d0

	mulu	#LARGE*8,d0
	lea	scroller,a0
	add	d0,a0
notl:
	rept	LARGE*8/4
	not.l	(a0)+
	endr

	IFNE	FINAL
	cmp.l	#finscroller,a0
	bls.s	degage
	illegal
	ENDC
degage
	rts

cnt=26+1
init_refresh:
	move	#(FIRSTMUS-1-cnt)*8,cpt.w
	move	#cnt,-(sp)
.loop	bsr	rafraichit
	addq	#8,cpt.w
	subq	#1,(sp)
	bne.s	.loop
	addq	#2,sp
	rts

aff_scroll:
	bsr	rafraichit
	moveq	#0,d0
	move	cpt.w,d0
	divu	#26*8,d0
	swap	d0
	move	d0,d1
	mulu	#LARGE,d0
	lea	scroller,a0
	add	d0,a0

	MOVE.L	ecran.w,a1
	lea	PLANMENU*2+16(A1),A1
	lea	32000(a1),a2

	move	#26*8-1,d0
	sub	d1,d0
	blo.s	.noscr1

	cmp	#25*8-1,d0
	bls.s	.scr1
	move	#25*8-1,d0
.scr1:
x	set	0
	rept	LARGE/2
	move	(a0)+,x(a1)
x	set	x+8
	endr
	lea	160(a1),a1
	dbra	d0,.scr1

	IFNE	FINAL
	cmp.l	a2,a1
	bhi.s	.bug1
	cmp.l	#finscroller,a0
	bls.s	.noscr1
.bug1	illegal
	ENDC
.noscr1

	sub	#8+1,d1
	blo.s	.noscr2
	lea	scroller,a0
.scr2:
x	set	0
	rept	LARGE/2
	move	(a0)+,x(a1)
x	set	x+8
	endr
	lea	160(a1),a1
	dbra	d1,.scr2

	IFNE	FINAL
	cmp.l	a2,a1
	bhi.s	.bug2
	cmp.l	#finscroller,a0
	bls.s	.noscr2
.bug2	illegal
	ENDC
.noscr2
	IFNE	FINAL
	cmp.l	a2,a1
	beq.s	.nobug
	illegal
.nobug
	ENDC
	rts

rafraichit:
	moveq	#-8,d0
	and	cpt.w,d0
	cmp	lastcpt.w,d0
	beq	norefresh
	bmi.s	refreshhaut

	move	d0,lastcpt.w

	add	#25*8,d0
	bra.s	refresh
refreshhaut:
	move	d0,lastcpt.w
refresh:
	move	d0,d1

	lsr	#3,d0
	ext.l	d0
	divu	#26,d0
	swap	d0
;
; d0=num‚ro de la ligne … rafraichir dans le buffer
;
	lea	scroller,a1
	mulu	#LARGE*8,d0
	add	d0,a1

	move	d1,d0
	lsr	#3,d0
	sub	#12,d0
	blo.s	fill0
	cmp	#NBMUS,d0
	bhs.s	fill0

	lea	menu+NBMUS*2,a0
	asl	#5,d0
	add	d0,a0
;
; a0=source
; a1=buffer scroller
;
	moveq	#LARGE-1,d0
.print:
	clr	d2
	move.b	(a0)+,d2
	asl	#3,d2
	lea	fonte(pc),a2
	add	d2,a2
	move.b	(a2)+,(a1)+
	move.b	(a2)+,LARGE-1(a1)
	move.b	(a2)+,LARGE*2-1(a1)
	move.b	(a2)+,LARGE*3-1(a1)
	move.b	(a2)+,LARGE*4-1(a1)
	move.b	(a2)+,LARGE*5-1(a1)
	move.b	(a2)+,LARGE*6-1(a1)
	move.b	(a2)+,LARGE*7-1(a1)

	dbra	d0,.print
	lea	LARGE*7(a1),a1
	bra.s	finref
fill0:
	move	#LARGE*8/4-1,d0
	moveq	#0,d2
.fill	move.l	d2,(a1)+
	dbra	d0,.fill
finref:
	sub	#12*8,d1
	cmp	lastchoice.w,d1
	bne.s	.noinv
	lea	-8*LARGE(a1),a0
	bsr	notl
.noinv:
	IFNE	FINAL
	cmp.l	#finscroller,a1
	bls.s	norefresh
	illegal
	ENDC
norefresh:
	rts

hbl0:
	clr.b	$fffffa1b.w
	move.b	#8,$fffffa21.w
	move.b	#8,$fffffa1b.w
branche:jmp	0.L

HBL:	macro
hbl\<X>:move	#\1,$ffff8242.w
X	SET	X+1
	move	#hbl\<X>,basemfp+$22.w
	rte
	endm
HBLF:	macro
hbl\<X>:move	#\1,$ffff8242.w
	move	#hbl1,basemfp+$22.w
	rte
	endm

X	SET	1
	HBL	$700
	HBL	$710
	HBL	$720
	HBL	$730
	HBL	$740
	HBL	$750
	HBL	$760
	HBL	$770
	HBL	$670
	HBL	$570
	HBL	$470
	HBL	$370
	HBL	$270
	HBL	$170
	HBL	$070
	HBL	$071
	HBL	$072
	HBL	$073
	HBL	$074
	HBL	$075
	HBL	$076
	HBL	$077
	HBL	$067
	HBL	$057
	HBL	$047
	HBL	$037
	HBL	$027
	HBL	$017
	HBL	$007
	HBL	$107
	HBL	$207
	HBL	$307
	HBL	$407
	HBL	$507
	HBL	$607
	HBL	$707
	HBL	$706
	HBL	$705
	HBL	$704
	HBL	$703
	HBL	$702
	HBLF	$701
lasthbl:

;
; ON NE STOCKE PLUS QUE 2 PREDECALAGES EN BYTES !!!!
;
TAILLESOURCE=16
MIDDLE=4
TAILLEDEST=TAILLESOURCE+(MIDDLE*2)
;BUFFER=$50000			;BUFFER PRECALCULS FONTE
;FINBUFFER=BUFFER+[TAILLEDEST*2*80]
FINBUFFER=scroller-4
BUFFER=FINBUFFER-TAILLEDEST*2*80

INITSINE:
	LEA	BUFFER,A0
	MOVE	#(FINBUFFER-BUFFER)/4-1+1,D7	;+1 pour corriger bug
	MOVEQ	#0,D0
CLRBUF:
	MOVE.L	D0,(A0)+
	DBRA	D7,CLRBUF
;	CLR.L	(A0)+		;POUR CORRIGER BUG !!!

	MOVE.L	#BUFFER,PTBUF.w
	MOVE.L	#TEXTE,PTRTEXT.w
	MOVE	#4,CPTXT.w
	CLR	SHIFT.w
	CLR	FLIPBUG.w
	LEA	BUG1.w,A0
	LEA	BUG2.w,A1
	MOVEQ	#80-1,D0
.CLRW	CLR	(A0)+
	CLR	(A1)+
	DBRA	D0,.CLRW
	RTS

GENERE:
	CMP	#16,D0
	BLS.S	.OK
	MOVEQ	#16,D0
.OK
	MULU	#26,D0
	LEA	SINUS(pc),A0
	ADD	D0,A0
	MOVEQ	#26-1,D0
COPGEN:	MOVE.B	(A0)+,(A6)+
	DBRA	D0,COPGEN
	RTS

SINE:
	LEA	TBSIN.w,A6	;GENERATION DE LA TABLE DE RELIEF
	MOVEQ	#0,D0		;PREMIERE VALEUR
	MOVE.B	REPLAY+BASEVOL(pc),D0
	BSR.S	GENERE
	CLR.B	(A6)+

	CLR	D0
	MOVE.B	REPLAY+BASEVOL+4(pc),D0
	BSR.S	GENERE
	CLR.B	(A6)+

	CLR	D0
	MOVE.B	REPLAY+BASEVOL+8(pc),D0
	BSR.S	GENERE
;
; AFFICHAGE
;
	LEA	BUG1.w,A3
	NOT	FLIPBUG.w
	BEQ.S	.OK
	LEA	BUG2.w,A3
.OK
	MOVEQ	#40-1,D7
	MOVE.L	PTBUF.w,A5		;SOURCE
	move.L	ecran.w,a6
	LEA	(196-TAILLESOURCE)*160+2(a6),A6	;DEST
	LEA	TBSIN.w,A4
LOOP1:
	MOVE.L	A5,A0
	LEA	TAILLEDEST*2+TAILLEDEST(A5),A1
	CMP.L	#FINBUFFER,A1
	BLO.S	.LOWA1
	LEA	BUFFER-FINBUFFER(A1),A1
.LOWA1:
	MOVE.L	A6,USP

	CLR	D0
	MOVE.B	(A4)+,D0
	CLR	D1
	MOVE.B	(A4)+,D1

	MOVE	D0,D5
	CMP	D1,D5
	BLS.S	.MIN
	MOVE	D1,D5
.MIN:
	SUB	D5,D0
	ADD	D0,A0

	SUB	D5,D1
	ADD	D1,A1

	SUB	D1,D0
	BPL.S	.ABS
	NEG	D0
.ABS
	MOVEQ	#TAILLESOURCE+MIDDLE-1,D6
	ADD	D0,D6
;	MOVEQ	#TAILLESOURCE+MIDDLE-1,D6
;	TST	D0
;	BEQ.S	.0
;	MOVEQ	#TAILLESOURCE-1,D6
;	ADD	D0,D6
;	ADD	D0,D6
;.0
	MULU	#160,D5

	CMP	(A3),D5
	BNE.S	CHANGE
	CMP	2(A3),D6
	BEQ.S	SKIP
CHANGE:
	CLR	D0
	MOVE.L	A6,A2
	SUB	(A3),A2		;OFFSET

	MOVE	2(A3),D1	;HAUTEUR
	ADD	D1,D1
	ADD	D1,D1
	NEG	D1
	JMP	CLEARE(PC,D1.W)

X	SET	(TAILLEDEST-1)*160
	REPT	TAILLEDEST-1
	MOVE.B	D0,X(A2)
X	SET	X-160
	ENDR
CLEARE:
	MOVE.B	D0,(A2)

	MOVE	D5,(A3)		;PUSH LAST OFFSET
	MOVE	D6,2(A3)

SKIP:	ADDQ	#4,A3
	SUB	D5,A6
AFF1:
	MOVE.B	(A0)+,D0
	OR.B	(A1)+,D0
	MOVE.B	D0,(A6)
	LEA	160(A6),A6
	DBRA	D6,AFF1
	MOVE.L	USP,A6
	ADDQ	#1,A6
	MOVE	A6,D0
	LSR	#1,D0
	BCS.S	IMPAIR
	ADDQ	#8-2,A6
IMPAIR:
	LEA	TAILLEDEST*2*2(A5),A5
	CMP.L	#FINBUFFER,A5
	BLO.S	LOWA5
	LEA	BUFFER-FINBUFFER(A5),A5
LOWA5:
	DBRA	D7,LOOP1
;
; REFRESH
;
	MOVE.L	PTBUF.w,A6		;RAFRAICHIR ICI !!!
	ADD.L	#TAILLEDEST*2,PTBUF.w
	CMP.L	#FINBUFFER,PTBUF.w
	BLO.S	LOW
	MOVE.L	#BUFFER,PTBUF.w
LOW:
	MOVE.L	PTRTEXT.w,A0
	CLR	D0
	MOVE.B	(A0),D0
	BPL.S	NOLOOPTXT
	LEA	TEXTE,A0
	MOVE.L	A0,PTRTEXT.w
	MOVE.B	(A0),D0
NOLOOPTXT:
	MULU	#TAILLESOURCE*2*2,D0
	LEA	FONTE32(PC),A5
	ADD.L	D0,A5		;SOURCE
;
; CPTXT=4,3
; CPTXT=2,1
;
	TST	SHIFT.w
	BEQ.S	.NOSH
	LEA	TAILLESOURCE*2(A5),A5	;DEUXIEME PARTIE DE LA FONTE
.NOSH:

	LEA	MIDDLE(A6),A6

	MOVE	CPTXT.w,D0

	SUBQ	#1,CPTXT.w	;DERRIERE REFRESH
	BNE.S	NOINC
	MOVE	#4,CPTXT.w

	TST.B	(A0)		;A0 POINTE SUR PTRTEXT
	BEQ.S	.NOSHIFT

	NOT	SHIFT.w
	BNE.S	NOINC
.NOSHIFT:
	ADDQ.L	#1,PTRTEXT.w
NOINC:

	ADD	D0,D0
;	ADD	D0,D0
	MOVEQ	#TAILLESOURCE-1,D6
	JMP	BRANCH-2(PC,D0.W)
BRANCH:
	BRA.S	MASKF
	BRA.S	MASKF0
	BRA.S	MASKF00
	BRA.S	MASKF000

MASKF:
	ADDQ	#1,A5
MASKF00:
	MOVEQ	#$F,D0
	AND.B	(A5),D0
	MOVE.B	D0,TAILLEDEST*1(A6)
	ASL.B	#4,D0
	MOVE.B	D0,(A6)+
	ADDQ	#2,A5
	DBRA	D6,MASKF00
	BRA.S	ENDREF
MASKF0:
	ADDQ	#1,A5
MASKF000:
	MOVEQ.L	#$F0,D0
	AND.B	(A5),D0
	MOVE.B	D0,(A6)+
	LSR.B	#4,D0
	MOVE.B	D0,TAILLEDEST*1-1(A6)
	ADDQ	#2,A5
	DBRA	D6,MASKF000
ENDREF:
	RTS


SINUS:
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0
 dc.b 0,0,1,1,2,2,2,3,3,3,3,4,4,4,4,3,3,3,3,2,2,2,1,1,0,0
 dc.b 0,0,1,2,2,3,4,4,5,5,5,5,6,6,5,5,5,5,4,4,3,2,2,1,0,0
 dc.b 0,1,2,3,3,4,5,6,6,7,7,7,8,8,7,7,7,6,6,5,4,3,3,2,1,0
 dc.b 0,1,2,3,4,5,6,7,8,9,9,9,10,10,9,9,9,8,7,6,5,4,3,2,1,0
 dc.b 0,1,3,4,5,7,8,9,10,10,11,11,12,12,11,11,10,10,9,8,7,5,4,3,1,0
 dc.b 0,1,3,5,6,8,9,10,11,12,13,13,14,14,13,13,12,11,10,9,8,6,5,3,1,0
 dc.b 0,2,4,5,7,9,11,12,13,14,15,15,16,16,15,15,14,13,12,11,9,7,5,4,2,0
 dc.b 0,2,4,6,8,10,12,13,15,16,17,17,18,18,17,17,16,15,13,12,10,8,6,4,2,0
 dc.b 0,2,5,7,9,11,13,15,16,18,19,19,20,20,19,19,18,16,15,13,11,9,7,5,2,0
 dc.b 0,2,5,8,10,13,15,17,18,20,21,21,22,22,21,21,20,18,17,15,13,10,8,5,2,0
 dc.b 0,3,6,8,11,14,16,18,20,21,22,23,24,24,23,22,21,20,18,16,14,11,8,6,3,0
 dc.b 0,3,6,9,12,15,17,20,22,23,24,25,26,26,25,24,23,22,20,17,15,12,9,6,3,0
 dc.b 0,3,7,10,13,16,19,21,23,25,26,27,28,28,27,26,25,23,21,19,16,13,10,7,3,0
 dc.b 0,3,7,11,14,17,20,23,25,27,28,29,30,30,29,28,27,25,23,20,17,14,11,7,3,0
 dc.b 0,4,8,11,15,18,22,24,27,29,30,31,32,32,31,30,29,27,24,22,18,15,11,8,4,0

TEXTE:
	INCBIN	SCROLL.COD
	EVEN

FONTE32	INCBIN	FNT3216.BIN

palette:dc.w	0	;%000
	dc.w	$545	;%001
	DCB.W	14,$777

motif1:
	dc.w	%0000000010000000,%0000000100000000
	dc.w	%0000000011000000,%0000001100000000
	dc.w	%0000000011100000,%0000011100000000
	dc.w	%0000000011110000,%0000111100000000

menu:	INCBIN	MENU.COD		;MESSAGES
fonte:	incbin	fonte1.bin
	dcb.b	8,0
	IFEQ	CHRONO
bigfonte:incbin	fntzoom.bin
	ENDC

INITMUS
;
; replay COSO-MMME
;
; D0=musique choisie
;
	lea	menu.w,a0
	add	d0,d0
	add	d0,a0
	moveq	#0,d1
	move.b	(a0)+,d1	;type de musique
	clr	d0
	move.b	(a0),d0		;num‚ro de musique
	LEA	loadmusiques,A0
	add	d1,d1
	add	d1,d1
	IFNE	FINAL
	CMP.L	(A0),D1
	BLO.S	.GOOD
	ILLEGAL
.GOOD
	ENDC
	ADD.L	(A0,D1.W),A0
	BRA.S	REPLAY+4

REPLAY:	INCBIN	REPLAY5.BIN
	even

loadmusiques:
	INCBIN	PRESENTE.BIN
	even
fin_loadmusiques:
	LIST

	NOLIST
	IFEQ	DEBUG
debugger:incbin	debugger.bin
fin_debugger
	ENDC
