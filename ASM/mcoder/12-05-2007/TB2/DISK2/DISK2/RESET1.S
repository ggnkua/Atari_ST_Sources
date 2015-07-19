	opt	o+,ow2-
;	opt	x+
	nolist
	output	reset.prg

DEBUG=1

NBSIN=512
HAUTEUR_FONTE=10
HAUTEUR=229		;nb de lignes r‚elles
nblines=273-2-2-1	;3*7*13=nb de lignes pour les rasters
MUSIC=1			;0=PAS DE MUSIQUE
PREMUS=0		;0=MUSIQUE PRECALC
RESO=1			;1=MOYENNE
NBCOUL=(256+2)/3*3

	IFEQ	RESO
WIDTH=40		;NB COLONNES*2
	ELSEIF
WIDTH=80		;NB COLONNES*2
	ENDC

	OUTPUT	PLASMA.PRG
;
nnop	macro
	ifgt	\1
	WAIT	\1,d0
	elseif
	IFNE	\1
	fail
	ENDC
	endc
	endm
;
; optimisations :
;	0=rien
;	1=NOP
;	2=OR.L D0,D0
;	3->???=LSR.L #,D0
;
WAIT	MACRO

	iflt	\1-(8+2*64)/4		;8+2n

	ifle	\1-2
	ifeq	\1-1
	nop
	elseif
	or.l	d0,d0
	endc
	elseif
	moveq	#(\1-3)*2,\2
	lsr.l	\2,\2
	endc
	elseif

N3	SET	(\1-7)-((\1-7)/5)*5
BEST	SET	3
MIN	SET	N3		;RECORD A BATTRE

N2	SET	(\1-6)&3
	IFLE	N2-MIN
BEST	SET	2
MIN	SET	N2
	ENDC

N1	SET	(\1-5)-((\1-5)/3)*3
	IFLE	N1-MIN
BEST	SET	1
MIN	SET	N1
	ENDC

	IFEQ	BEST-1
	MOVEQ	#(\1-5)/3,\2
\@	DBRA	\2,\@
	IFNE	N1
	DCB.W	N1,$4E71
	ENDC
	ENDC

	IFEQ	BEST-2
	MOVEQ	#(\1-6)/4,\2
\@	NOP
	DBRA	\2,\@
	IFNE	N2
	DCB.W	N2,$4E71
	ENDC
	ENDC

	IFEQ	BEST-3
	MOVEQ	#(\1-7)/5,\2
\@	NOP
	NOP
	DBRA	\2,\@
	IFNE	N3
	DCB.W	N3,$4E71
	ENDC
	ENDC
	endc
	ENDM

	OFFSET	$80
debut_offset:
ecran:	ds.l	1
ecranhelp:ds.l	1
sync:	ds.w	1

countm:	ds.w	1
affmode:ds.w	1
ptrecr:	ds.w	1
ptrlig:	ds.w	1
vbl_aff:ds.w	1
ptrmess:ds.l	1
wait_aff:ds.w	1
w_aff2:	ds.w	1
effect:	ds.w	1
palette:ds.l	1
	ifeq	PREMUS
ptr_mus:ds.l	1
	endc
bouclage:ds.w	1
curseur:ds.W	1
sin0:	ds.w	1
sin1:	ds.w	1
lastkey:ds.b	1
help:	ds.b	1
	even
curpal:	ds.l	1
fin_offset:
	SECTION	TEXT
quit:
;
;
; init prg
;
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
basemfp=$40
	move.b	#$10,$fffffa17.w
;
; initialisations avant lancement programme
;
	lea	quit(pc),a0
	lea	8.w,a1
	moveq	#($80-8)/4-1,d0
.filvec:move.l	a0,(a1)+
	dbra	d0,.filvec

.videkey
	moveq.l	#$A1,d0
	and.b	$fffffc00.w,d0
	beq.s	.vide
	tst.b	$fffffc02.w
	bra.s	.videkey
.vide
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w

.wikbd	btst	#1,$fffffc00.w
	beq.s	.wikbd
	move.b	#$12,$fffffc02.w	;d‚sactiver souris

	lea	debut_offset.w,a0
	move	#(fin_offset-debut_offset)/2-1,d0
.cleare	clr	(a0)+
	dbra	d0,.cleare

	move.l	#screen+255,d0
	clr.b	d0
	move.l	d0,ecran.W
	add.l	#HAUTEUR*160+255,d0
	clr.b	d0
	move.l	d0,ecranhelp.w

	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	clr	$ffff8242.w

	move.l	ecran.w,a0
	move.l	ecranhelp.w,a1
	move	#(HAUTEUR*160)/4-1,d0
	moveq	#0,d1
.cls
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbra	d0,.cls

	lea	oneplane-WIDTH,a0
	lea	oneplane+200*WIDTH,a1
	moveq	#WIDTH/2-1,d0
	moveq	#-1,d1
.line	move	d1,(a0)+
	move	d1,(a1)+
	dbra	d0,.line
;
; g‚nŠre table mul
;
	lea	mul160,a0
	lea	mulwidth,a1
	moveq	#0,d0
	moveq	#0,d1
.addmul
	move	d0,(a0)+
	move	d1,(a1)+
	add	#160,d0
	add	#WIDTH,d1
	cmp	#160*200,d0
	blo.s	.addmul
;
; g‚nŠre table de conversion
;
;o:
	move.l	#-$4000,d5
	divs	#NBCOUL*3,d5
	swap	d5
	ADD	#NBCOUL*3,D5
	ext.l	d5
	divu	#3,d5
	add	d5,d5

	move	#$8000/3-1,d7

	lea	convert1-$8000,a0
	lea	convert2-$8000,a1

	moveq	#4,d0
	moveq	#2,d1
	moveq	#0,d2

	move	d2,(a0)+
	move	d5,(a1)+
.genconv
	move	d0,(a0)+
	move	d1,(a0)+
	MOVE	d2,(a0)+
	move	d5,(a1)+
	move	d5,(a1)+
	move	d5,(a1)+

	addq	#2,d5
	cmp	#NBCOUL*2,d5
	blo.s	.low
	clr	d5
.low
	dbra	d7,.genconv

	move	d0,(a0)+
	move	d5,(a1)+

	bsr	init_display
	bsr	conv_mess

	IFNE	MUSIC

	IFEQ	PREMUS
	lea	buffer_mus,a4
	BSR	fastmus

	IFEQ	DEBUG
	cmp.l	#fin_mus,a4
	beq.s	.okmus
	illegal
.okmus
	ENDC
	move.l	#buffer_mus,ptr_mus.W
	ELSEIF
	lea	musique,a0
	moveq	#MUSIC,d0
	bsr	replay_mus
	ENDC
	ENDC
	bsr	gentimera

	IFEQ	DEBUG
	cmp.l	#fintimera,a2
	beq.s	.gooda2
	move	#$700,$ffff8240.w
.gooda2
	ENDC

	bsr	gen_calc

	move.l	#blancs,palette.w
	move.l	#pal1,curpal.w 

	move.l	#shitvbl,$70.w
	move	#$2300,sr
	stop	#$2300

	IFEQ	RESO
	CLR.b	$ffff8260.w
	ELSEIF
	MOVE.b	#1,$ffff8260.w
	ENDC
	move.b	#2,$ffff820a.w
	move.l	#vbl,$70.w
	move.l	#hbl68,$68.w
	move.l	#timera,basemfp+$34.w
	clr.b	$fffffa19.w
	move.b	#%00100000,$fffffa07.w
	move.b	#%00100000,$fffffa13.w
	bra.s	.notnew
.new
	tst.b	help.w
	bne.s	.recalc
	lea	taille(a6),a6
	cmp.l	#fin_courbe,a6
	blo.s	.recalc
.notnew
	lea	courbe,a6
.recalc
	move	#2,bouclage.w
	move.l	ecran.w,d0
	tst.b	help.w
	beq.s	.nohelp
	move.l	ecranhelp.w,d0
.nohelp
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	bsr	genere_courbe

	tst.b	help.w
	beq.s	.nohlp
	bsr	affiche_help
.nohlp
	clr	sin0.w
	clr	sin1.w

	clr	sync.w
.loop
	IFEQ	DEBUG
	move	#$777,$ffff8240.w
	move	#$000,$ffff8240.w
	tst	sync.w
	bne	quit
	ENDC
.ww
	tst	sync.w		;12
	beq.s	.ww		;12
	clr	sync.w

modsin	equr	D7
dsin0	equr	A4
dsin1	equr	A5

	lea	rasters,a0
	lea	sinus0,a1
	lea	sinus1,a2

	move	#(NBSIN-1)*2,modsin
;	move	#1*2,dsin0
;	move	#-1*2,dsin1		;1*2
	move	distortsin0(a6),dsin0
	move	distortsin1(a6),dsin1

;	clr	d3
;	moveq	#-1,d4
	move	pente0(a6),d3
	move	pente(a6),d4

	move	sin0.w,d0
	move	sin1.w,d1
	jsr	calclines

	move	incsin0(a6),d0
	add	d0,sin0.w
	move	incsin1(a6),d0
	add	d0,sin1.w
	and	#(NBSIN-1)*2,sin0.w
	bne.s	.nobcl
	and	#(NBSIN-1)*2,sin1.w
	bne.s	.nobcl
	subq	#1,bouclage.w
	beq	.new
.nobcl
;
; d‚buggage
;
	clr	d0
	MOVE.B	$FFFFFC02.W,D0
	cmp.b	lastkey.w,d0
	beq.s	.notch
	move.b	d0,lastkey.w

	move	d0,d1
	sub	#$3b,d1
	cmp	#9,d1
	bhs.s	.notf
	add	d1,d1
	move	d1,curseur.w
	bra	.loop
.notf
	move	d0,d1
	subq	#2,d1
	cmp	#8,d1
	bhs.s	.notch
	add	#9,d1
	add	d1,d1
	move	d1,curseur.w
	bra	.loop
.notch
	cmp.b	#$62,d0
	bne.s	.nohl
	not.b	help.w
	bra	.recalc
.nohl
	tst.b	help.w
	beq	.loop

	cmp.b	#$4b,d0		;flŠche gauche
	bne.s	.notgau
	moveq	#-1,d0
	bra.s	.change
.notgau
	cmp.b	#$4d,d0		;flŠche droite
	bne	.loop
	moveq	#1,d0
.change

	move	curseur.w,d1
	cmp	#ampx1,d1
	beq.s	.ok1
	cmp	#ampx2,d1
	beq.s	.ok1
	cmp	#firstr,d1
	beq.s	.ok1
	cmp	#firstv,d1
	beq.s	.ok1
	cmp	#firstb,d1
	beq.s	.ok1
	cmp	#incsin0,d1
	beq.s	.ok1
	cmp	#incsin1,d1
	beq.s	.ok1
	cmp	#distortsin0,d1
	beq.s	.ok1
	cmp	#distortsin1,d1
	beq.s	.ok1
	cmp	#pente0,d1
	beq.s	.ok1
	cmp	#pente,d1
	beq.s	.ok1
	add	d0,d0		;non parit‚
.ok1
	add	d0,(a6,d1.w)
	IFEQ	DEBUG
	move	#$700,$ffff8240.w
	ENDC
	bra	.recalc

affiche_help
	move.l	ecranhelp.w,a5		;adresse ‚cran
	lea	(FIRST_LINE+10)*160+4*8(a5),a5
	move.l	a6,a4			;adresse d‚but
	moveq	#17-1,d6
	moveq	#17+'0'-' ',d4
	moveq	#'F'-' ',d3
.disp
	move.l	a5,a0

	move	d3,d0
	bsr.s	putc
	move	d4,d0
	sub	d6,d0
	bsr.s	putc

	addq	#4,a0

	move	(a4)+,d7
	bsr.s	hexa

	cmp	#17-8-1,d6
	bne.s	.nocr
	moveq	#17-9+'0'-' ',d4
	moveq	#' '-' ',d3
	lea	160*HAUTEUR_FONTE(a5),a5
.nocr
	lea	160*HAUTEUR_FONTE(a5),a5
	dbra	d6,.disp
	rts

hexa:
	moveq	#4-1,d5
.hexa
	rol	#4,d7
	moveq	#$f,d0
	and	d7,d0
	cmp	#10,d0
	blo.s	.low10
	addq	#7,d0
.low10
	add	#'0'-' ',d0
	bsr.s	putc
	dbra	d5,.hexa
	rts
putc:
	mulu	#HAUTEUR_FONTE*2,d0
	lea	fonte,a1
	add	d0,a1
x	set	0
	rept	HAUTEUR_FONTE
	move	(a1)+,x(a0)
x	set	x+160
	endr
	addq	#4,a0
	rts

debut_calc:
	and	modsin,d0
	and	modsin,d1

	moveq	#-2,d2
	and	d3,d2
	add	(a1,d0.w),d2
	add	(a2,d1.w),d2
	move	d2,(a0)+

	add	dsin0,d0
	add	dsin1,d1

	add	d4,d3
fin_calc:

	rsreset
rouge:	rs.w	1	;f1
firstr:	rs.w	1	;f2
vert:	rs.w	1	;f3
firstv:	rs.w	1	;f4
bleu:	rs.w	1	;f5
firstb:	rs.w	1	;f6
incr:	rs.w	1	;f7
incv:	rs.w	1	;f8
incb:	rs.w	1	;f9

ampx1:	rs.w	1	;1
ampx2:	rs.w	1	;2

incsin0	rs.w	1	;3
incsin1	rs.w	1	;4
distortsin0:rs.w 1	;5
distortsin1:rs.w 1	;6
pente0:	rs.w	1	;7
pente:	rs.w	1	;8
taille:	rs.b	0

courbe:
;
; courbe 1
;
	dc.w	2*2,6		;niveau rouge*2,valeur m‚diane
	dc.w	2*2,6		;vert
	dc.w	2*2,6		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	40		;amplitude premier sinus
	dc.w	50		;amplitude deuxieme sinus

	dc.w	3		;inc sin0
	dc.w	5		;inc sin1
	dc.w	1*2		;dsin0
	dc.w	-1*2		;dsin1
	dc.w	0		;pente0
	dc.w	0		;pente
;
; courbe 7
;
	dc.w	8,4		;niveau rouge*2,valeur m‚diane
	dc.w	8,4		;vert
	dc.w	0,7		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	$22		;amplitude premier sinus
	dc.w	$39		;amplitude deuxieme sinus

	dc.w	$f		;inc sin0
	dc.w	$fffc		;inc sin1
	dc.w	$6		;dsin0 (pair)
	dc.w	$3		;dsin1
	dc.w	$0		;pente0
	dc.w	$ffff		;pente

;
; courbe 5
;
	dc.w	0,0		;niveau rouge*2,valeur m‚diane
	dc.w	6,4		;vert
	dc.w	0,7		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	$35		;amplitude premier sinus
	dc.w	$13		;amplitude deuxieme sinus

	dc.w	9		;inc sin0
	dc.w	$a		;inc sin1
	dc.w	$11		;dsin0 (pair)
	dc.w	$fffb		;dsin1
	dc.w	$5		;pente0
	dc.w	$fffc		;pente
;
; courbe 3
;
	dc.w	6,4		;niveau rouge*2,valeur m‚diane
	dc.w	0,7		;vert
	dc.w	0,7		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	$35		;amplitude premier sinus
	dc.w	$13		;amplitude deuxieme sinus

	dc.w	6		;inc sin0
	dc.w	3		;inc sin1
	dc.w	$1		;dsin0 (pair)
	dc.w	$3		;dsin1
	dc.w	0		;pente0
	dc.w	$1		;pente
;
; courbe 4
;
	dc.w	0,0		;niveau rouge*2,valeur m‚diane
	dc.w	0,6		;vert
	dc.w	4,6		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	$35		;amplitude premier sinus
	dc.w	$13		;amplitude deuxieme sinus

	dc.w	6		;inc sin0
	dc.w	3		;inc sin1
	dc.w	$1		;dsin0 (pair)
	dc.w	$4		;dsin1
	dc.w	$5		;pente0
	dc.w	$1		;pente
;
; courbe 2
;
	dc.w	0,7		;niveau rouge*2,valeur m‚diane
	dc.w	0,6		;vert
	dc.w	4,6		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu


	dc.w	$20		;amplitude premier sinus
	dc.w	$20		;amplitude deuxieme sinus

	dc.w	7		;inc sin0
	dc.w	5		;inc sin1
	dc.w	$2		;dsin0 (pair)
	dc.w	$3		;dsin1
	dc.w	0		;pente0
	dc.w	$fffe		;pente
;
; courbe 8
;
	dc.w	0,7		;niveau rouge*2,valeur m‚diane
	dc.w	6,4		;vert
	dc.w	0,4		;bleu

	dc.w	2*16		;incr‚ment sinus rouge*2
	dc.w	2*16		;vert
	dc.w	2*16		;bleu

	dc.w	$22		;amplitude premier sinus
	dc.w	$39		;amplitude deuxieme sinus

	dc.w	$8		;inc sin0
	dc.w	$3		;inc sin1
	dc.w	$c		;dsin0 (pair)
	dc.w	$e		;dsin1
	dc.w	$9		;pente0
	dc.w	$4		;pente

;
; courbe 6
;
	dc.w	6,4		;niveau rouge*2,valeur m‚diane
	dc.w	6,4		;vert
	dc.w	6,4		;bleu

	dc.w	$22		;incr‚ment sinus rouge*2
	dc.w	$06		;vert
	dc.w	$66		;bleu

	dc.w	$b		;amplitude premier sinus
	dc.w	$39		;amplitude deuxieme sinus

	dc.w	$15		;inc sin0
	dc.w	$fffc		;inc sin1
	dc.w	$4		;dsin0 (pair)
	dc.w	$ffff		;dsin1
	dc.w	$14		;pente0
	dc.w	$ffff		;pente

fin_courbe:

genere_courbe:
;
; g‚nŠre table de sinus
;
	move	ampx1(a6),d7	;coef 1
	lea	sinus0,a0
	bsr	gensin
	move	ampx2(a6),d7	;coef 2
	lea	sinus1,a0
	bsr	gensin
;
; g‚n‚rateur de palette
;
	lea	table_sinus,a2
	move.l	curpal.w,a0
	lea	NBCOUL*2(a0),a1
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move	#NBCOUL-1,d4
.genpal
	and	#(NBSIN-1)*2,d5
	and	#(NBSIN-1)*2,d6
	and	#(NBSIN-1)*2,d7

	move	(a2,d5.w),d0
	muls	rouge(a6),d0
	swap	d0
	add	firstr(a6),d0
	AND	#7,D0
	asl	#4,d0

	move	(a2,d6.w),d1
	muls	vert(a6),d1
	swap	d1
	add	firstv(a6),d1
	AND	#7,D1
	add	d1,d0
	asl	#4,d0

	move	(a2,d7.w),d1
	muls	bleu(a6),d1
	swap	d1
	add	firstb(a6),d1
	AND	#7,D1
	add	d1,d0

	move	d0,(a0)+
	move	d0,(a1)+

	add	incr(a6),d5
	add	incv(a6),d6
	add	incb(a6),d7

	dbra	d4,.genpal

	moveq	#100-1,d0
	move	#$777,d1
.filpal	move	d1,(a1)+
	dbra	d0,.filpal

	move.l	curpal.w,palette.w
	move.l	#pal1,d0
	eor.l	#pal2,d0
	eor.l	d0,curpal.w
	rts

gensin:
	lea	table_sinus,a1
	move	#NBSIN-1,d6
.gen
	move	(a1)+,d0
	muls	d7,d0
	add.l	d0,d0
	add.l	#$8000,d0
	swap	d0

	add	d0,d0
;	and	#-2,d0

	move	d0,(a0)+
	dbra	d6,.gen
	rts

gen_calc:
	move	#nblines-1,d7
	lea	calclines,a2
.gen1
	lea	debut_calc,a0
	lea	fin_calc,a1
	bsr.S	copie
	dbra	d7,.gen1
	move	#$4e75,(a2)+
	rts

gentimera:
	lea	timera,a2
	lea	timera1(pc),a0
	lea	fintimera1(pc),a1
	bsr.s	copie
	move	#nblines-1,d7
.gen	lea	ligne(pc),a0
	lea	finligne(pc),a1
	bsr.s	copie
	dbra	d7,.gen
	lea	timera3(pc),a0
	lea	fintimera3(pc),a1
copie:	move	(a0)+,(a2)+
	cmp.l	a1,a0
	blo.s	copie
	rts

shitvbl:
	addq	#1,sync.w
	rte
vbl:
	move.b	#$65-1,$fffffa1f.w	;meilleure valeur possible !!!
	move.b	#4,$fffffa19.w
;	move.b	#79,$fffffa1f.w		;pas bon
;	move.b	#5,$fffffa19.w
hbl68:	rte

timera1:
	move	#$2100,sr
;	dcb.w	10,$4e71

	stop	#$2100			;Synchro HBL
	move	#$2700,sr

	clr.b	$fffffa19.w		;4 NOPs
	movem.l	d0-d7/a0-a6,-(sp)	;8+8*15=32 nops

	nnop	50-4
	move.b	#0,$ffff820a.w
	nnop	16
	move.b	#2,$ffff820a.w

	nnop	24			;Synchro SHIFTER
	move.b	$ffff8209.w,d0
	neg.b	d0
	lsr	d0,d0
	nnop	45+4
;	move	#$000,$ffff8240.w

	lea	$ffff8240.w,a6
;	lea	pal,a3
	move.l	palette.w,a3

	lea	rasters,a4
	moveq	#6,d2
	lea	convert1,a1
	lea	convert2,a2

fintimera1:

ligne:
	move	(a4)+,d0
	move.l	a3,a5
	add	(a2,d0.w),a5
	move	(a1,d0.w),d0

	lsr	d0,d1			;6+2n=8
	rept	36
	move	(a5)+,(a6)		;12
	endr
	eor	d2,d0			;8
	lsr	d0,d1			;16
finligne:

init_display:
	move	#$8000,vbl_aff.w
	clr	countm.w
	move	#4,affmode.w		;‚cran d‚j… effac‚...
	move.l	#message,ptrmess.w
	clr	ptrecr.w
	clr	ptrlig.w
	clr	w_aff2.w
	clr	wait_aff.w
	clr	effect.w
	rts

conv_mess:
	lea	message,a0
	move.l	a0,a1
.conv
	clr	d0
	move.b	(a0)+,d0
	bmi.s	.fini
	cmp.b	#$d,d0
	beq.s	.conv
	cmp.b	#$a,d0
	bne.s	.noa
	move.b	#-2,(a1)+	;-2=CR
	bra.s	.conv
.noa
	cmp.b	#']',d0
	bne.s	.nosc

	move.b	#-3,(a1)+	;-3=fin ‚cran
	addq	#2,a0		;skippe CR
	bra.s	.conv
.nosc
	sub.b	#' ',d0
	move.b	d0,(a1)+
	bra.s	.conv

.fini	move.b	#-1,(a1)+	;-1=fin
	rts


timera3:
	CLR	(a6)

	addq	#1,sync.w
	addq	#1,vbl_aff.w

	IFNE	MUSIC

	IFNE	PREMUS
	jsr	replay_mus+4
	ELSEIF

	move.l	ptr_mus.W,a0
	LEA	$FFFF8800.W,A1
	LEA	2(A1),A2

	move.b	(a0)+,d0
	beq.s	.none
	move.b	#$b,(A1)
	move.b	d0,(A2)
	move.l	#$0C0C0000,(A1)
	move.l	#$0D0D0A0A,(A1)
.none

x	set	0
	rept	11
	move.b	#x,(A1)			;5
	move.b	(a0)+,(A2)		;5
x	set	x+1
	endr

	cmp.l	#fin_mus,a0
	blo.s	.goodmus
	lea	buffer_mus,a0
.goodmus
	move.l	a0,ptr_mus.W

	ENDC
	ENDC

FIRST_LINE=30-5-2

	tst.b	help.w
	bne	quitvbl

	lea	mul160,a4
	lea	mulwidth,a5

	move	affmode.w,d0
	jmp	.modus(pc,d0.w)
.modus
	bra.w	aff_mode0
	bra.w	aff_mode1
	bra.w	aff_mode2
	IFEQ	DEBUG
	illegal
	illegal
	ENDC

;
; premiŠre partie effacement de l'‚cran r‚duit
;  ligne par ligne
;
aff_mode0
	move	countm.w,d0
	add	d0,d0
	move	(a5,d0.w),d0

	lea	oneplane,a0
	add	d0,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	lea	WIDTH*2(A0),A0

	rept	WIDTH*2/16
	movem.l	d0-d3,-(a0)
	endr
	addq	#2,countm.w
	cmp	#200,countm.w
	blo	quitvbl
	addq	#4,affmode.w
	clr	ptrecr.w
	clr	ptrlig.w
	clr	wait_aff.w
	bra	quitvbl

aff_mode2
	move	vbl_aff.w,d0
	cmp	w_aff2.w,d0
	blo	quitvbl

	move	countm.w,d0
	add	d0,d0
	lea	oneplane,a0
	move.l	ecran.w,a2

	move	effect.w,d1
	jmp	.effects(pc,d1.w)
.effects:
	bra.w	effet2
	bra.w	effet3


;	bra.w	effet2
;	bra.w	effet2
	bra.w	effet1
	bra.w	effet0
effet2:
	add	d0,d0
	add	(a5,d0.w),a0
	lea	WIDTH(a0),a1

	lea	(FIRST_LINE)*160(a2),a2
	add	(a4,d0.w),a2
	lea	160(a2),a3
	bra.s	disp_effet
effet3:
	add	d0,d0
	lea	(200-2)*WIDTH(a0),a0
	sub	(a5,d0.w),a0
	lea	WIDTH(a0),a1

	add.l	#(FIRST_LINE+200-2)*160,a2
	sub	(a4,d0.w),a2
	lea	160(a2),a3
	bra.s	disp_effet

effet1:
	move	(a5,d0.w),d1
	lea	199*WIDTH(a0),a1
	add	d1,a0
	sub	d1,a1

	move	(a4,d0.w),d1
	lea	(FIRST_LINE)*160(a2),a2
	lea	199*160(a2),a3
	add	d1,a2
	sub	d1,a3
	bra.s	disp_effet

effet0:
	move	(a5,d0.w),d1
	lea	99*WIDTH(a0),a0
	lea	WIDTH(a0),a1
	sub	d1,a0
	add	d1,a1

	move	(a4,d0.w),d1
	lea	(FIRST_LINE+100)*160(a2),a3
	lea	-160(a3),a2
	sub	d1,a2
	add	d1,a3
disp_effet
x	set	0
	rept	WIDTH/2
	move	(a0)+,x(a2)
	move	(a1)+,x(a3)
x	set	x+320/WIDTH
	endr

	addq	#1,countm.w
	cmp	#100,countm.w
	blo	quitvbl

	move	wait_aff.w,w_aff2.w

	clr	affmode.w
	clr	vbl_aff.w
	clr	countm.w
;	addq	#4,effect.w
;	and	#4*3,effect.w
	bra	quitvbl

aff_mode1:
	moveq	#3-1,d1
.disp

	move.l	ptrmess.w,a0
	addq.l	#1,ptrmess.w
	move.b	(a0)+,d0
	ext	d0
	bpl.s	.ok

	add	d0,d0
	jmp	.ff+2(pc,d0.w)

	bra.s	.chmod
	bra.s	.0a
.ff
	move.l	#message,ptrmess.w
	bra.s	.disp
.0a
	clr	ptrecr.w
	add	#WIDTH*(HAUTEUR_FONTE),ptrlig.w
	cmp	#200*WIDTH,ptrlig.w
	blo.s	.nodisp
	clr	ptrlig.w
	bra.s	.nodisp
.chmod
	addq	#4,affmode.w
	clr	countm.w
	bra.s	quitvbl

.ok
	addq	#3,wait_aff.w
	mulu	#HAUTEUR_FONTE*2,d0
	lea	fonte,a0
	add	d0,a0

	lea	oneplane,a1
	add	ptrecr.w,a1
	add	ptrlig.w,a1

x	set	0
	rept	HAUTEUR_FONTE
	move	(a0)+,x(a1)
x	set	x+WIDTH
	endr

	addq	#2,ptrecr.w
.nodisp
	dbra	d1,.disp

quitvbl:
	movem.l	(sp)+,d0-d7/a0-a6
	rte

fintimera3:

	IFNE	MUSIC

	ifne	PREMUS
replay_mus:	INCBIN	REPLAY.BIN
musique:	incbin	prehis5.mus
	elseif
fastmus:incbin	FAST.BIN
	endc
	ENDC

table_sinus:	incbin	sin
fonte:	incbin	fonte16.bin
message:
	IFEQ	RESO
	incbin	reset.txt
	ELSEIF
	incbin	reset1.txt
	ENDC
	dc.b	-1
	even
blancs:	dcb.w	36,$777

	section	bss

pal1:	ds.w	NBCOUL*2
	DS.W	100
pal2:	ds.w	NBCOUL*2
	DS.W	100

rasters:
	ds.w	nblines

	IFNE	MUSIC
	IFEQ	PREMUS
buffer_mus:
	ds.b	$bd0c
fin_mus
	ENDC
	ENDC

sinus0:	ds.w	NBSIN
sinus1:	ds.w	NBSIN
mul160:	ds.w	200
mulwidth:ds.w	200

	DS.B	WIDTH
oneplane:ds.b	200*WIDTH
	DS.B	WIDTH
screen:
	ds.b	HAUTEUR*160+256
	ds.b	HAUTEUR*160+256

	ds.w	16384
convert1:
	ds.w	16384
	ds.w	16384
convert2:
	ds.w	16384

timera:
	ds.b	(fintimera1-timera1)+(fintimera3-timera3)
	ds.b	(finligne-ligne)*nblines
fintimera:

calclines:
	ds.b	(fin_calc-debut_calc)*nblines
