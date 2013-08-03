	opt	l5
UPLOAD	equ	0	;0=down load

;	OUTPUT	A:\AUTO\TOKI.PRG
	output	presente.prg
	opt	o+,ow-
;
; pr‚sentation de Toki
;
; 25/04/90 la routine de sprite est g‚n‚r‚e par programme
;
DEBUG = 0			;0=debug on
ylogo = 40
CPU	MACRO
	tst.b	touches+$f
	beq.s	.\@
	move	#\1,$ffff8240.w
.\@
	ENDM
nbspr = 4		;nb sprites maximum
XSORCIER = 176
nbvbl= 1
typemus= 1			;1=musique on
ecran1	equ	$80000-32000
ecran0	equ	ecran1-32000
ecranfond:equ	ecran0-32000
ramtop	equ	ecranfond
hauteur= 176
largeur= 224
offsety= 0
	ifne	UPLOAD
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	$80000,sp
	movem.l	mover(pc),d0-d7
	movem.l	d0-d7,-(sp)
	lea	code(pc),a0
	LEA	DEBUTCODE\W,A1
	LEA	FINCODE,A2
	jmp	(sp)
mover:
	move.l	(a0)+,(a1)+
	move	a1,$ffff8240.w
	cmp.l	a2,a1
	blo.s	mover
	JMP	STARTCODE\W
code:
	endc

	offset	$100
touches		ds.b	$80-2
joystick0	ds.b	1
joystick1	ds.b	1
	section	text

	ORG	$500
DEBUTCODE:
	bra	STARTCODE
mul160	ds.w	hauteur		;offsety*160+24
lastmusic:dc.w	0
sync:	dc.w	0
ecran:	dc.l	0
effacelogo:dc.w	0
ptr1	ds.l	1
ptr2	ds.l	1
buffer1:ds.b	6*nbspr+4
buffer2:ds.b	6*nbspr+4
STARTCODE
	move	#$2700,sr
	lea	stack,sp	;superstack
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	IFEQ	DEBUG
	jsr	debugger
	ENDC

	bsr	initkbd

	move.l	#vbl,$70.w

	move	#$2300,sr

	move.l	#vbl2,$70.w

	lea	ecranfond,a0
	lea	$80000,a1
	moveq	#0,d0
clrmem:
	move.l	d0,(a0)+
	cmp.L	a1,a0
	blo.s	clrmem

	lea	mul160,a0
	move	#hauteur-1,d0
	move	#offsety*160+24,d1
setmul:
	move	d1,(a0)+
	add	#160,d1
	dbra	d0,setmul

	move.l	#ecranfond,ecran
	bsr	copyscreen
	move.l	#ecran0,ecran
	bsr	copyscreen
	move.l	#ecran1,ecran
	bsr	copyscreen

	move.l	#ecran0,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	buffer1,a0
	clr.l	(a0)
	move.l	a0,ptr1
	lea	buffer2,a0
	clr.l	(a0)
	move.l	a0,ptr2

	ifne	typemus
	moveq	#2,d0
	jsr	musique
	endc

	lea	ondes,a0
	lea	finondes,a1
.modif	sub	#366,(a0)+
	cmp.l	a1,a0
	blo.s	.modif

	bsr	genere_sprites

;	lea	generespr,a0
;.plante	dc.l	$4a780001
;	bra.s	.plante

	move.l	#ecran1,ecran

	clr	effacelogo
	move.l	#prgvbl,$70.w
rejoue:
	clr.b	flagfemme
	clr	anim
;
; g‚n‚ration de la femme en pr‚d‚cal‚
;
	moveq	#2,d0
	moveq	#1,d1		;pas du pr‚d‚calage
	lea	IMAGEFEMME,A5
	LEA	FASTFEMME,A4
	move.l	a4,$200.w
	bsr	predecale
	move.l	a6,$204.w
	CMP.L	#FINBUFFERFEMME,A6
	BEQ.S	.goodgen
	moveq	#-1,d0
.flash	move	d0,$ffff8240.w
	dbra	d0,.flash
.goodgen
	st	flagfemme
.wait2
	tst.b	flagfemme	;attend la fin d'utilisation de la femme
	bne.s	.wait2

	moveq	#2,d0		;les 2 boules de feu
	moveq	#1,d1		;pas du pr‚d‚calage
	lea	IMAGERAYON,A5
	LEA	FASTRAYON,A4
	move.l	a4,$208.w
	bsr	predecale
	move.l	a6,$20c.w

;	BEQ.S	.goodgen
;	moveq	#-1,d0
;.flash2:move	d0,$ffff8240.w
;	dbra	d0,.flash2
;.goodgen

	st	flagfemme
.wait3
	tst.b	flagfemme
	bne.s	.wait3

	moveq	#1,d0		;le logo
	moveq	#1,d1		;pas du pr‚d‚calage
	lea	IMAGELOGO,A5
	LEA	FASTLOGO,A4
	move.l	a4,$210.w
	bsr	predecale_logo
	move.l	a6,$214.w

;	MOVE	#100,D0
;.FLASH	MOVE	D0,$FFFF8240.W
;	DBRA	D0,.FLASH

	clr.b	replay
.loop	tst.b	replay
	beq.s	.loop
	bra	rejoue

copyscreen:
	lea	FOND,a6
	move.l	ecran,a5
	lea	24(a5),a5

	move	#176-1,d7
1$
	move.L	a5,a0
	move	#224/2/4-1,d0
2$
	move.l	(a6)+,(a0)+
	dbra	d0,2$
	lea	160(a5),a5
	dbra	d7,1$
	rts
;	move.l	#retr,$80.w
;	move	#$300,sr
;	move.l	ecran,a7
;x	set	24
;	rept	176
;	movem.l	(a6)+,d0-d7/a0-a5
;	movem.l	d0-d7/a0-a5,x(a7)
;	movem.l	(a6)+,d0-d7/a0-a5
;	movem.l	d0-d7/a0-a5,x+56(a7)
;x	set	x+160
;	endr
;
;	trap	#0
;	rts

;retr:	rtr

vbl2:
	movem.l	d0-d7,-(sp)
	movem.l	palette,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	movem.l	(sp)+,d0-d7
vbl:
;	addq	#1,sync
	rte

basemfp	equ	$40
;
; am‚liorations possible :
;	- mettre le tableau touches … une adresse multiple de 256
;	  (ca fait gagner l'empilement de a0)
;	- mettre ces routines dans le bas de la m‚moire
;	  (changement du vecteur par MOVE.W)
;	- d‚gager TST.B au d‚but
;	- enlever la routine JOYST0 !!!
;
;
; nouvelle routine de clavier (trŠs) optimis‚e
;
initkbd:
	move.b	#$10,$fffffa17.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w

.wikbd	btst	#1,$fffffc00.w
	beq.s	.wikbd
	move.b	#$12,$fffffc02.w	;d‚sactiver souris

	move.l	#kbd,basemfp+$18.w
	or.b	#$40,$fffffa09.w
	or.b	#$40,$fffffa15.w

	lea	touches\w,a0
	moveq	#($80-2)/2-1,d0
	moveq	#0,d1
.clear	move	d1,(a0)+
	dbra	d0,.clear
	clr.b	joystick0
	clr.b	joystick1
	rts

bug:	move	#$2700,sr
1$	addq	#7,$ffff8240.w
	bra.s	1$
kbd:
	tst.b	$fffffc00.w
	bpl.s	bug
	move	d0,-(sp)
	clr	d0
	move.b	$fffffc02.w,d0
	addq.b	#2,d0
	bcs.s	codefe

	ifeq	DEBUG
	move	#$700,$ffff8240.w
	endc
	pea	(a0)
	lea	touches\w,a0
	bclr	#7,d0
	seq	-2(a0,d0.w)
	move.l	(sp)+,a0
	move	(sp)+,d0
	ifeq	DEBUG
	clr	$ffff8240.w
	endc
	rte
codefe:
	bne.s	keyff
	move.l	#joyst0,basemfp+$18.w
	move	(sp)+,d0
	rte
keyff	move.l	#joyst1,basemfp+$18.w
	move	(sp)+,d0
	rte
joyst0:
	ifeq	DEBUG
	move	#$070,$ffff8240.w
	endc
	move.b	$fffffc02.w,joystick0
	move.l	#kbd,basemfp+$18.w
	ifeq	DEBUG
	clr	$ffff8240.w
	endc
	rte
joyst1:
	ifeq	DEBUG
	move	#$007,$ffff8240.w
	endc
	move.b	$fffffc02.w,joystick1
	move.l	#kbd,basemfp+$18.w
	ifeq	DEBUG
	clr	$ffff8240.w
	endc
	rte

prgvbl:
	movem.l	d0-d7/a0-a6,-(sp)

	ifne	typemus
	moveq	#0,d0

	tst.b	touches+$3b
	beq.s	.paf1
	moveq	#1,d0
.paf1
	tst.b	touches+$3c
	beq.s	.paf2
	moveq	#2,d0
.paf2
	tst.b	touches+$3d
	beq.s	.paf3
	moveq	#3,d0
.paf3
	tst.b	touches+$3e
	beq.s	.paf4
	moveq	#4,d0
.paf4
	tst.b	touches+$3f
	beq.s	.paf5
	moveq	#5,d0
.paf5
	tst.b	touches+$40
	beq.s	.paf6
	moveq	#6,d0
.paf6
	tst.b	touches+$41
	beq.s	.paf7
	moveq	#7,d0
.paf7
	tst.b	touches+$42
	beq.s	.paf8
	moveq	#8,d0
.paf8
	tst.b	touches+$43
	beq.s	.paf9
	moveq	#9,d0
.paf9
	tst.b	touches+$44
	beq.s	.paf10
	moveq	#10,d0
.paf10
	cmp	lastmusic,d0
	beq.s	.same
	move	d0,lastmusic
	beq.s	.same
	jsr	musique
	bra.s	.notsame
.same
	jsr	musique+8
.notsame
	endc
;
; effacement des sprites
;
	move.l	ptr1,a6
.bcl
	move.l	(a6)+,d0
	beq.s	.fini

	move.l	d0,a2
	lea	ecranfond,a0
	move.l	ecran,a1
	move	(a6)+,d0
	add	d0,a0
	add	d0,a1
	jsr	(a2)
	bra.s	.bcl
.fini
	tst	effacelogo
	beq	.nologo
	subq	#1,effacelogo
	CPU	$077
	move.l	ecran,a5
	lea	FOND+ylogo*224/2,a6
x	set	ylogo*160+24
	rept	64
	movem.l	(a6)+,d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,x(a5)
	movem.l	(a6)+,d0-d7/a0-a4
	movem.l	d0-d7/a0-a4,x+52(a5)
	move.l	(a6)+,x+104(a5)
	move.l	(a6)+,x+108(a5)
x	set	x+160
	endr
.nologo
	clr.b	flagroc

	CPU	$300
	move.l	ptr1,a6		;pour pusher les sprites
	bsr	demo
	clr.l	(a6)
	CPU	$333

	tst.b	flagroc
	beq	noroc
	move.L	ecran,a6
	add	#(176-$91-16+4+1)*160+24,a6

	incbin	INCLUDES\AFFROC.BIN
noroc:
	move.l	ecran,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	ptr2,a0		;swappe les pointeurs d'effacement
	move.l	ptr1,ptr2
	move.l	a0,ptr1
	eor.l	#ecran0^ecran1,ecran

	CLR	$FFFF8240.W
	movem.l	(sp)+,d0-d7/a0-a6
	rte
;
; routines d'affichage pour chaque sprite...
;
; (m‚morisent les coordonn‚es et les tailles pour l'effacement)
;
affiche_sorcier
	CPU	$070		;vert
	move	xsorc,d1
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGESORCIER,a5
	move	numsorc,d0	;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bsr	bob
	rts
;
; entr‚e : d1=X,d2=Y
;
affiche_femme
	CPU	$700		;rouge
	lea	IMAGEFEMME,a5
	lea	FASTFEMME,A0
	move	numfemme,d0	;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bsr	fast_bob
	rts

affiche_homme:
	CPU	$007		;bleu
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGECOURSE,a5
	move	xhomme,d1
	move	numhomme,d0		;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bsr	bob
	rts

affiche_trans:
	CPU	$007		;bleu
	move	#hauteur/2-2+80-1,d2	;Y
	lea	IMAGETRANS,a5
	move	xhomme,d1
	move	numhomme,d0		;num‚ro de sprite
	asl	#3,d0
	clr	d3
	move.b	5(a5,d0.w),d3
	sub	d3,d2
	lsr	#3,d0
	bsr	bob
	rts

affiche_tir
	CPU	$700		;rouge
	move	xtir,d1
	move	#hauteur/2-2+80-64-1-8,d2
	lea	IMAGERAYON,a5
	lea	FASTRAYON,A0
	move	numtir,d0		;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bsr	fast_bob
	rts
;
; entr‚e : d1=X logo
;
affiche_logo
	CPU	$700		;rouge
	move	#hauteur/2-2+80-64-1-50,d2
	lea	IMAGELOGO,a5
	lea	FASTLOGO,A0
	CLR	D0		;num‚ro de sprite
	moveq	#-1,d5		;n'arrondit pas en X
	bsr	fast_bob
	rts

anim:	dc.w	0

modesorc:dc.w	0
xsorc:	dc.w	0
numsorc:dc.w	0
cptsorc:dc.w	0
flagsorc:dc.w	0

ptrfemme:dc.w	0
numfemme:dc.w	0
cptfemme:dc.w	0

xhomme:dc.w	0
numhomme:dc.w	0
cpthomme:dc.w	0

xtir:	dc.w	0
numtir:	dc.w	0
cpttir:	dc.w	0

flagfemme:dc.b	0
flagroc:dc.b	0	;si roc … afficher
replay:	dc.b	0
	even

demo:
	move	anim,d0
	add	d0,d0
	add	d0,d0
	jmp	test(pc,d0.w)
test:	bra.w	initanim
	bra.w	anim0
	bra.w	anim1
	bra.w	anim2
	bra.w	anim3
	bra.w	anim4

initanim:
	move	#6-1,cptsorc
	move	#largeur,xsorc
	move	#3,numsorc
	clr	modesorc

	clr	ptrfemme
	clr	numfemme
	move	#16-1,cptfemme
	addq	#1,anim
	rts

anim0:
	bsr	gere_sorcier
	bsr	affiche_sorcier

	tst.b	flagfemme
	bne.s	.goodmeuf
	rts
.goodmeuf
	subq	#1,cptfemme
	bge.s	.bob
	move	#16-1,cptfemme
	eor	#1,numfemme
.bob
	move	ptrfemme,d0
	lea	coords,a0
	add	d0,a0
	addq	#4,d0
	cmp	#fincoords-coords,d0
	blo.s	.okcoords
	clr	d0
	addq	#1,anim
	clr.b	flagfemme
	move	#-30,xhomme
	clr	cpthomme
	clr	numhomme
.okcoords
	move	d0,ptrfemme

	clr	d1
	move.b	(a0)+,d1
	addq	#2,d1		;X
	clr	d2
	move.b	(a0)+,d2
	sub	#100,d2		;Y
	bsr	affiche_femme
	rts

anim1:
	bsr	gere_sorcier
	bsr	affiche_sorcier
	bsr	gere_homme
	bsr	affiche_homme
	rts

anim2:
	bsr	gere_sorcier
	bsr	affiche_sorcier
	bsr	gere_homme
	bsr	affiche_homme

	subq	#3,xtir
	move	xhomme,d0
	add	#32,d0
	sub	xtir,d0
	blt.s	.goodx
	addq	#1,anim
	move	#10-1,cpthomme	;transformation
	clr	numhomme
	clr	flagsorc
	clr.b	flagfemme
.goodx
	subq	#1,cpttir
	bge.s	.bob
	move	#2-1,cpttir
	eor	#1,numtir
.bob
	bsr	affiche_tir
	rts

anim3:
	bsr	gere_sorcier
	add	#65536/3,flagsorc
	bcs.s	1$
	bsr	affiche_sorcier
1$
	subq	#1,cpthomme
	bpl.s	.nonew
	move	#5-1,cpthomme
	cmp	#15,numhomme
	bne.s	.nobob
	addq	#1,anim
	clr	ptronde
	bra.s	.nonew
.nobob
	addq	#1,numhomme
.nonew
	bsr	affiche_trans
	rts
ptronde:dc.w	0
anim4:
	move	ptronde,d0
	lea	ondes,a0
	add	d0,a0
	cmp.l	#finondes-2*64,a0
	blo.s	.good
	st	replay
	clr	anim
	rts
.good
	addq	#6,ptronde
;	move	(a0)+,d1	;X
;	sub	#366,d1
;	bsr	affiche_logo
	move	#2,effacelogo
	pea	(a6)
	bsr	distort_logo
	move.l	(sp)+,a6
	rts

gere_sorcier:
	move	modesorc,d0
	add	d0,d0
	add	d0,d0
	jmp	gestsorci(pc,d0.w)
gestsorci:
	bra.w	sorcier0
	bra.w	sorcier1
	bra.w	sorcier2

sorcier0:
	cmp	#XSORCIER,xsorc
	bgt.s	.newx1
	cmp	#3,numsorc
	bne.s	.newx1
	addq	#1,modesorc
	clr	numsorc		;reset anim sorcier
	move	#150-1,cptsorc
	rts
.newx1
	subq	#1,cptsorc
	bpl.s	.new1
	move	#6-1,cptsorc

	addq	#1,numsorc
	cmp	#7,numsorc
	blo.s	.new1
	move	#3,numsorc
.new1
	cmp	#XSORCIER,xsorc
	ble.s	.newx
	subq	#1,xsorc
.newx
	rts
sorcier1:
	subq	#1,cptsorc
	bpl.s	.finanim
	move	#20-1,cptsorc
	cmp	#2,numsorc
	blo.s	.bob2
	addq	#1,anim
	move	xsorc,xtir	;tir du sorcier
	sub	#16,xtir
	clr	numtir		;initialise le tir
	addq	#1,modesorc
	move	#2-1,cpttir
	bra.s	.finanim
.bob2
	addq	#1,numsorc
.finanim
	rts
sorcier2:
	subq	#1,cptsorc
	bge.s	.finanim
	move	#20-1,cptsorc
	tst	numsorc
	beq.s	.finanim
	subq	#1,numsorc
.finanim
	rts

gere_homme:
	addq	#1,xhomme
	subq	#1,cpthomme
	bge.s	.bob
	move	#7-1,cpthomme
	addq	#1,numhomme
	cmp	#6,numhomme
	blo.s	.bob
	clr	numhomme
.bob
	rts

;
; nouvelle routine de sprite d‚calant
;
; a0=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
CLIPPE4	MACRO			;macro clipping 4 plans

	moveq	#$f,d5
	and	d1,d5
	add	d3,d5

	moveq	#15,d7		;D7=$F (gain=4 cycles)
	add	d7,d5
	add	d7,d3
	not	d7		;D7=$FFF0 (gain=4 cycles)
	and	d7,d5
	and	d7,d3
	lsr	#1,d5		;d5=nb octets pour effacement
	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	A0=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	sub.l	a3,a3

	cmp	#hauteur,d2
	blo.s	cliphau\@
	bge	retsp\@		;trop en bas
	neg	d2
	sub	d2,d4
	bls	retsp\@
	mulu	d3,d2
	add	d2,a0

;	moveq	#0,d2		;d2=offset ‚cran
	move	mul160,d2
	bra.s	noclipbas\@
cliphau\@
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160,a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	noclipbas\@
	sub	d0,d4
noclipbas\@

	move	#160,a2
	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	clipgau\@
	bge.s	retsp\@		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
;	bls.s	retsp\@
	blo.s	retsp\@
	sub	d1,d5

	move	d1,a3

	add	a3,a0

	or.b	#$40,d0		;indique clipping … gauche
	bra.s	noclipdro\@
clipgau\@
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	noclipdro\@
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	sub	d1,d5
	move	d1,a3

noclipdro\@
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d5=nb plans*8 … effacer
;	d4=nb lignes
;
	cmp	d3,d5
	bne.s	pacl\@
	btst	#6,d0
	bne.s	pacl\@
	tas	d0
pacl\@
	move.l	ecran,a1
	add	d2,a1

	sub	d3,a2
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	lea	branche-16+8+16(pc),a4
	add	d3,a4
	add	d3,a4

	move	(a4)+,d6
	sub	d4,d6
	mulu	(a4)+,d6
	add.l	(a4),d6		;offset effacement

	move.l	d6,(a6)+	;adresse effacement
	move	d2,(a6)+	;poke offset ‚cran

	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a0=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	LEA	newsprite,a4
	jsr	(a4,d0.w)
retsp\@
	ENDM
cliproc:
	cmp	#32+16,d1
	bge.s	1$
	st	flagroc
	CPU	$700
1$	rts

fast_bob:
	asl	#3,d0		;num‚ro spr*8
	clr	d3
	move.b	6(a5,d0.w),d3
	add	d3,d1
	and	d5,d1
	clr	d4
	move.b	4(a5,d0.w),d3
	move.b	5(a5,d0.w),d4

	bsr	cliproc

	add	d0,d0		;num‚ro spr*16
	moveq	#$f,d5
	and	d1,d5
	add	d5,d0		;+d‚calage=ptr sprite
	asl	#2,d0
	add	d0,a0
	move.l	(a0),a0
	bra	aff_fast
;
; proc‚dure d‚buggage
;
	add	#15,d3
	and	#$fff0,d3
	lsr	#4,d3		;d3=nb plans
				;d4=nb lignes
	move.l	ecran,a6
.aff1:
	move.l	a6,a1
	move	d3,d0
.aff2:
	addq	#4,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	subq	#1,d0
	bne.s	.aff2
	move.l	#-1,(a1)+
	move.l	#-1,(a1)+
	lea	160(a6),a6
	subq	#1,d4
	bne.s	.aff1
	rts

bob:
	asl	#3,d0		;*8
	add	d0,a5
	move.l	(a5)+,a0	;adresse image

	clr	d3
	move.b	(a5)+,d3	;taille x
	clr	d4
	move.b	(a5)+,d4	;taille Y

	move.b	(a5)+,d0	;calage en X
	ext	d0
	add	d0,d1
	move.b	(a5)+,d0	;calage en Y
	ext	d0
	add	d0,d2

	bsr	cliproc
;
; a0=d‚but du sprite
;
	CLIPPE4
;
; d0=num‚ro du sprite ???
; a0=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	rts	
coords:
 dc.b 1,172,2,172
 dc.b 3,172,4,172,5,172,6,172,7,172,9,172
 dc.b 10,171,11,171,13,171,14,171,15,171,17,171
 dc.b 18,171,20,170,21,170,22,170,24,170,25,169
 dc.b 27,169,29,169,30,168,32,168,33,168,35,167
 dc.b 37,167,38,167,40,166,42,166,43,166,45,165
 dc.b 47,165,48,164,50,163,52,163,54,162,55,162
 dc.b 57,161,59,161,61,160,62,159,64,159,66,158
 dc.b 68,158,69,157,71,156,73,155,74,155,76,154
 dc.b 78,153,79,152,81,152,83,151,84,150,86,149
 dc.b 88,149,89,148,91,147,92,146,94,145,95,144
 dc.b 97,144,98,143,100,142,101,141,103,140,104,139
 dc.b 105,139,107,138,108,137,109,136,110,135,112,134
 dc.b 113,134,114,133,115,132,116,131,117,130,118,130
 dc.b 119,129,120,128,121,127,122,126,123,126,124,125
 dc.b 125,124,125,123,126,123,127,122,128,121,128,120
 dc.b 129,120,129,119,130,118,130,117,131,117,131,116
 dc.b 132,115,132,115,132,114,133,114,133,113,133,112
 dc.b 133,112,134,111,134,111,134,110,134,110,134,109
 dc.b 134,108,134,108,134,108,134,107,134,107,134,106
 dc.b 133,106,133,105,133,105,133,104,133,104,132,104
 dc.b 132,104,132,103,131,103,131,103,131,103,130,102
 dc.b 130,102,129,102,129,102,128,102,128,101,127,101
 dc.b 127,101,126,101,126,101,125,101,125,101,124,101
 dc.b 124,101,123,101,123,101,122,101,121,101,121,101
 dc.b 120,102,120,102,119,102,118,102,118,102,117,102
 dc.b 117,103,116,103,115,103,115,103,114,104,114,104
 dc.b 113,104,113,105,112,105,112,106,111,106,111,107
 dc.b 110,107,110,107,109,108,109,109,108,109,108,110
 dc.b 108,110,107,111,107,111,107,112,106,112,106,113
 dc.b 106,114,106,114,105,115,105,115,105,116,105,117
 dc.b 105,118,105,118,105,119,105,119,105,120,105,121
 dc.b 105,122,105,123,105,123,105,124,105,125,106,126
 dc.b 106,126,106,127,107,128,107,129,107,129,108,130
 dc.b 108,131,109,132,109,132,110,133,110,134,111,135
 dc.b 112,136,112,137,113,137,114,138,115,139,115,140
 dc.b 116,140,117,141,118,142,119,143,120,143,121,144
 dc.b 122,145,123,146,124,146,125,147,126,148,128,149
 dc.b 129,149,130,150,131,151,132,151,134,152,135,153
 dc.b 136,153,138,154,139,154,141,155,142,156,143,156
 dc.b 145,157,147,157,148,158,150,159,151,159,153,159
 dc.b 154,160,156,161,157,161,159,161,161,162,162,162
 dc.b 164,163,165,163,167,163,169,164,170,164,172,164
 dc.b 174,165,175,165,177,165,179,165,180,165,182,166
 dc.b 184,166,185,166,187,166,189,166,190,166,192,166
 dc.b 194,166,195,166,197,167,198,167,200,167,201,167
 dc.b 203,167,204,166,206,166,207,166,209,166,210,166
 dc.b 211,166,213,166,214,166,215,166,217,165,218,165
 dc.b 219,165,220,165,222,164,223,164,224,164,225,163
fincoords:
	dc.b	1,172
	even
;
; routine efficace de pr‚d‚calage de sprites...
;
; entr‚e :
;	d0=nb sprites … pr‚d‚caler
;	d1=nb d‚calages d‚sir‚s
;	a5=adresse ptr table … pr‚d‚caler
;	a4=m‚mo des pointeurs (taille X,taille Y,bitmap)
;	   suivis du bitmap des sprites
;
nbdecale:dc.w	0
predecale
	move	d0,-(sp)
	move	d1,nbdecale
	MULU	#4*16,D0
	MOVE.L	A4,A6
	ADD.L	D0,A6
decale
	moveq	#0,d6
1$
	clr	d0
	clr	d1
	move.b	4(a5),d0
	move.b	5(a5),d1
	add	d6,d0
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3
	move.b	4(a5),d2
	subq.b	#1,d2
	and	#$f,d2		;nb pixels … droite
	clr	d0
	move.b	4(a5),d0
	clr	d1
	move.b	5(a5),d1

	add	#15,d0
	lsr	#4,d0

	movem	d0-d1,nbplan	;nbplan=d0 et nblig=d1

	clr	onemore
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
	blo.s	7$
	st	onemore
	addq	#1,d0
7$
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
const	equr	d2
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan

	move	nblig,d1
2$
	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	move	nbplan,cptplan
	bmi.s	4$
3$
	swap	reste1
	swap	reste2

	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	dbra	cptplan,3$
4$
	tst	onemore
	beq.s	5$

	swap	reste1
	swap	reste2

	move.l	reste1,d0
	or.l	reste2,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,(a6)+
	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
5$
	subq	#1,d1		;dec nblig
	bne	2$

;	ADDQ	#7,$FFFF8240.W

	move	nbdecale,d1
.zero	addq	#1,d6
	cmp	#16,d6
	bhs.s	.xx
	subq	#1,d1
	beq	1$
	move.L	-4(a4),(a4)+
	bra.s	.zero
.xx
	addq	#8,a5
	subq	#1,(sp)
	bne	decale
	addq	#2,sp
	rts
planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
nbplan:	ds.w	1
nblig:	ds.w	1
onemore:ds.w	1


predecale_logo
	lea	4*16(a4),a6
	moveq	#0,d6
1$
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3
	move.b	4(a5),d2
	subq.b	#1,d2
	and	#$f,d2		;nb pixels … droite
	clr	d0
	move.b	4(a5),d0
	clr	d1
	move.b	5(a5),d1

	add	#15,d0
	lsr	#4,d0

	subq	#2,d0
	move	d0,nbplan	;nbplan=d0 et nblig=d1
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

2$
	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	move	nbplan,cptplan
	bmi.s	4$
3$
	swap	reste1
	swap	reste2

	addq	#4,a6

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+
	move.l	d0,d3

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+
	or.l	d3,d0
	move.l	d0,d3
	swap	d0
	or.l	d3,d0
	not.l	d0
	move.l	d0,-12(a6)

	dbra	cptplan,3$
4$
	move.l	reste1,d0
	or.l	reste2,d0
	swap	reste1
	swap	reste2
	or.l	reste1,d0
	or.l	reste2,d0
	not.l	d0
	move.l	d0,(a6)+
	move.l	reste1,(a6)+
	move.l	reste2,(a6)+

	subq	#1,d1		;dec nblig
	bne	2$

	addq	#1,d6
	cmp	#16,d6
	blo	1$
	rts
;
; entr‚e :
;	a0 pointe sur la table de d‚formation
;
distort_logo:
	CPU	$770
	moveq	#64-1,d7
	move.l	ecran,a6
	lea	ylogo*160+24(a6),a6
	moveq	#0,d6
	lea	FASTLOGO,A4
.ligne
	move.l	a6,a2
	move	(a0)+,d0	;X

	moveq	#15,d1
	and	d0,d1
	eor	d1,d0

	add	d1,d1
	add	d1,d1
	move.l	(a4,d1.w),a1
	add.l	d6,a1

	cmp	#224-192,d0
	blo.s	.pasclip
	bge.s	.clipgauche
;
; on doit clipper … gauche
;
	neg	d0
	cmp	#192,d0		;d0=nb pixels … clipper
	bhs	.noaff

	lsr	#1,d0
	move	d0,d1
	lsr	#1,d0
	add	d1,d0
	add	d0,a1
	jmp	.noclip(pc,d0.w)
.clipgauche
	cmp	#224,d0
	bhs	.noaff
;
; on doit clipper … droite
;
	lsr	#1,d0
	add	d0,a2		;offset horizontal
	lea	.aff(pc),a3
	sub	#224/2,d0	;d0=-(nb plans … afficher*8)
	add	d0,a3
	asr	#1,d0
	add	d0,a3
	jmp	(a3)
.pasclip
	lsr	#1,d0
	add	d0,a2
.noclip
	rept	192/16
	movem.l	(a1)+,d0-d2
	and.l	d0,(a2)
	or.l	d1,(a2)+
	and.l	d0,(a2)
	or.l	d2,(a2)+
	endr
.aff
.noaff
	lea	160(a6),a6
	add	#192/8*12/2,d6
	dbra	d7,.ligne
	rts
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	a0=d‚but bitmap sprite
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;	a6=m‚mo effacement sprite
;
fin_fast:rts
aff_fast:
	moveq	#$f,d5
	and	d1,d5
	add	d5,d3		;nb pixels de largeur
	eor	d5,d1

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	fin_fast

	neg	d2
	sub	d2,d4
	bls.s	fin_fast
	mulu	d3,d2
	add	d2,a0
	lsr	#1,d2
	add	d2,a0		;+1/2 pour les masques
	move	mul160,d2
	bra.s	2$
1$
	move	d2,d0
	add	d4,d0

	lea	mul160,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	fin_fast
	neg	d1
	sub	d1,d3
	bls.s	fin_fast
	move	d1,a3		;coefficient de clipping
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
	add	a3,a0		;+1/2 pour mask
	bra.s	4$
3$
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub.l	a3,a3
	sub	#largeur/2,d1
	blo.s	4$
	move	d1,a3
	sub	d1,d3
	lsr	#1,d1
	add	d1,a3		;a3=multiple de 12 !!!
4$
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	add	d3,d3
	lea	branche-16(pc),a1
	add	d3,a1

	move	(a1)+,d5
	sub	d4,d5
	mulu	(a1)+,d5
	add.l	(a1)+,d5	;offset affichage

	move	(a1)+,d6
	sub	d4,d6
	mulu	(a1)+,d6
	add.l	(a1),d6		;offset effacement

	move.l	d6,(a6)+	;adresse effacement
	move	d2,(a6)+	;poke offset ‚cran
;	move.l	d5,(a6)+	;adresse effacement
;	move	d2,(a6)+	;offset ‚cran

	move.l	ecran,a1
	add	d2,a1		;adresse ‚cran
	move.l	d5,a4
	jmp	(a4)
;
;	LA ROUTINE DE SPRITES !!!!
;
; toujours le meme principe...
;
msk	macro
	move.l	(a0)+,\1
	move.l	\1,\2
	and.l	(a1)+,\1
	or.l	(a0)+,\1
	and.l	(a1)+,\2
	or.l	(a0)+,\2
	endm
;
; structure de BRANCHE
;
;	0.w=nombre de lignes qu'on peut afficher au maximum
;	2.w=longueur en octets de chaque affichage
;	4.w=offset d'affichage
;	6.w=nombre de lignes qu'on peut effacer au maximum
;	8.w=longueur en octets de chaque effacement
;	10.w=offset d'effacement
;	12.w=unused
;	14.w=unused
;
lgsp16	equ	12*1+8+2	;nb octets de chaque routine
lgsp32	equ	12*2+8+2	;12*n pour msk
lgsp48	equ	12*3+8+2	;+8 pour movem.l et lea
lgsp64	equ	12*4+8+2	;+2 pour clipping
lgsp80	equ	12*5+8+2+6	;+2 pour clipping
lgsp96	equ	12*6+8+2+6	;+2 pour clipping
lgsp112	equ	12*7+8+2+6	;+2 pour clipping
lgsp128	equ	12*8+8+2+6	;+2 pour clipping
lgsp144	equ	12*9+8+2+6*2	;+2 pour clipping
lgsp160	equ	12*10+8+2+6*2	;+2 pour clipping
lgsp176	equ	12*11+8+2+6*2	;+2 pour clipping
lgsp192	equ	12*12+8+2+6*2	;+2 pour clipping
;
; la plus grande valeur fixe les valeurs (clipping)
;
nblig192 equ	64
nblig176 equ	64
nblig160 equ	64
nblig144 equ	64
nblig128 equ	64
nblig112 equ	64
nblig96	equ	64
nblig80	equ	$66
nblig16	equ	nblig80
nblig32	equ	nblig80
nblig48	equ	nblig80
nblig64	equ	nblig80
;
; d0=adresse effacement du sprite
; a0=‚cran source
; a1=‚cran destination
; a2=adresse de retour
;
lgeff16	equ	12
lgeff32	equ	12
lgeff48	equ	12
lgeff64	equ	12
lgeff80	equ	12
lgeff96	equ	12
lgeff112 equ	12*2
lgeff128 equ	12*2
lgeff144 equ	12*2
lgeff160 equ	12*2
lgeff176 equ	12*2
lgeff192 equ	12*2

branche
	dc.w	nblig16,lgsp16
	dc.l	plante
	dc.w	nblig16,lgeff16
	dc.l	plante

	dc.w	nblig32,lgsp32
	dc.l	plante
	dc.w	nblig32,lgeff32
	dc.l	plante

	dc.w	nblig48,lgsp48
	dc.l	plante
	dc.w	nblig48,lgeff48
	dc.l	plante

	dc.w	nblig64,lgsp64
	dc.l	plante
	dc.w	nblig64,lgeff64
	dc.l	plante

	dc.w	nblig80,lgsp80
	dc.l	plante
	dc.w	nblig80,lgeff80
	dc.l	plante

	dc.w	nblig96,lgsp96
	dc.l	plante
	dc.w	nblig96,lgeff96
	dc.l	plante

	dc.w	nblig112,lgsp112
	dc.l	plante
	dc.w	nblig112,lgeff112
	dc.l	plante

	dc.w	nblig128,lgsp128
	dc.l	plante
	dc.w	nblig128,lgeff128
	dc.l	plante

	dc.w	nblig144,lgsp144
	dc.l	plante
	dc.w	nblig144,lgeff144
	dc.l	plante

	dc.w	nblig160,lgsp160
	dc.l	plante
	dc.w	nblig160,lgeff160
	dc.l	plante

	dc.w	nblig176,lgsp176
	dc.l	plante
	dc.w	nblig176,lgeff176
	dc.l	plante

	dc.w	nblig192,lgsp192
	dc.l	plante
	dc.w	nblig192,lgeff192
	dc.l	plante

	dc.w	0,0
	dc.l	plante
	dc.w	0,0
	dc.l	plante

plante:	dc.l	$4a780001
;
; routines de sprite
;
; a0=pointeur en lecture (BITMAP)
; a1=pointeur en ‚criture (ECRAN)
; a2=adresse de retour (gain 12 cycles)
;
genere_sprites
	lea	generespr,a6
	lea	branche(pc),a5

	lea	spr16,a0
	bsr	genere
	lea	spr32,a0
	bsr	genere
	lea	spr48,a0
	bsr	genere
	lea	spr64,a0
	bsr	genere
	lea	spr80,a0
	bsr	genere
	ifeq	1
	lea	spr96,a0
	bsr	genere
	lea	spr112,a0
	bsr	genere
	lea	spr128,a0
	bsr	genere
	lea	spr144,a0
	bsr	genere
	lea	spr160,a0
	bsr	genere
	lea	spr176,a0
	bsr	genere
	lea	spr192,a0
	bsr	genere
	endc
	rts
genere
;
; g‚n‚ration affichage...
;
	move	(a5)+,d0	;nb lignes
	move	(a5)+,d1	;longueur spr routine
	move.l	a6,(a5)+	;adresse d‚but routine
	subq	#2,d0
.gen1	move.l	a0,a2
	move	d1,d7
.gen2	move.b	(a2)+,(a6)+
	subq	#1,d7
	bne.s	.gen2
	dbra	d0,.gen1

.gen3
	move.b	(a0)+,(a6)+
	subq	#1,d1
	bne.s	.gen3
	subq	#6,a6
	move	#$4e75,(a6)+
;
; g‚n‚ration effacement
;
	move	(a5)+,d0	;nb lignes
	move	(a5)+,d1	;longueur spr routine
	move.l	a6,(a5)+
	subq	#1,d0
	mulu	#160,d0		;offset ‚cran
.gen4
	move.L	a0,a2
	move	d1,d6
	lsr	#1,d6
	move	d0,d5
	clr	d4
.gen5
	move	(a2)+,d2
	bne.s	.gen6
	move	d5,(a6)+
	not	d4
	bne.s	.gen7
	addq	#4,d5
	cmp.l	#eff32,a2
	blo.s	.gen7
	add	#48-4,d5
	bra.s	.gen7
.gen6	move	d2,(a6)+
.gen7
	subq	#1,d6
	bne.s	.gen5
	sub	#160,d0
	bne.s	.gen4

.gen8	move	(a2)+,(a6)+
	bne.s	.gen8
	move	#$4e75,-2(a6)
	rts

spr16					;sprite 16 de large
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1

	opt	o-
eff16
	move.l	0(a0),0(a1)
	move.l	0(a0),0(a1)

	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	dc.w	0
spr32					;sprite 32 de large
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
eff32
	movem.l	0(a0),d0-d3
	movem.l	d0-d3,0(a1)

	movem.l	(a0),d0-d3
	movem.l	d0-d3,(a1)
	dc.w	0
spr48					;sprite 48 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
eff48
	movem.l	0(a0),d0-d5
	movem.l	d0-d5,0(a1)

	movem.l	(a0),d0-d5
	movem.l	d0-d5,(a1)
	dc.w	0
spr64					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160(a1),a1
eff64
	movem.l	0(a0),d0-d7
	movem.l	d0-d7,0(a1)

	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	dc.w	0
spr80					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1

eff80
	movem.l	0(a0),d0-d7/a2/a3
	movem.l	d0-d7/a2/a3,0(a1)

	movem.l	(a0),d0-d7/a2/a3
	movem.l	d0-d7/a2/a3,(a1)
	dc.w	0
spr96					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1

eff96
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	dc.w	0
spr112					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1

eff112
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d1
	movem.l	d0-d1,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d1
	movem.l	d0-d1,48(a1)
	dc.w	0

spr128					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-32(a1),a1

eff128
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d3
	movem.l	d0-d3,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d3
	movem.l	d0-d3,48(a1)
	dc.w	0

spr144					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	movem.l	d0-d1,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-64(a1),a1

eff144
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d5
	movem.l	d0-d5,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d5
	movem.l	d0-d5,48(a1)
	dc.w	0

spr160					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	movem.l	d0-d3,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-64(a1),a1

eff160
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d7
	movem.l	d0-d7,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d7
	movem.l	d0-d7,48(a1)
	dc.w	0

spr176					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	movem.l	d0-d5,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-64(a1),a1

eff176
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,48(a1)
	dc.w	0

spr192					;sprite 64 de large
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-32(a1)
	msk	d0,d1
	msk	d2,d3
	msk	d4,d5
	msk	d6,d7
	movem.l	d0-d7,-(a1)
	add.l	a3,a0			;clippe en X
	lea	160-64(a1),a1
eff192
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)
	movem.l	0(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,0(a1)

	movem.l	(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,(a1)
	movem.l	48(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,48(a1)
	dc.w	0
	OPT	O+

	ifne	UPLOAD
	SECTION	DATA
	endc
palette:
	DC.W	$000,$004,$027,$047,$414,$765,$006,$000
	DC.W	$040,$150,$314,$030,$643,$631,$520,$300
newsprite:incbin INCLUDES\SPRITE18.BIN
	ds.l	100
stack:
	ifne	typemus
musique:
	incbin	INCLUDES\MAX.BIN
	endc
ondes:
 dc.w 405,386,368,350,333,316,299,283,267,252,237
 dc.w 223,209,196,184,172,161,150,140,131,122
 dc.w 114,107,100,95,90,85,82,79,77,75
 dc.w 75,74,75,77,79,81,85,89,93,98
 dc.w 104,110,117,125,132,141,150,159,168,178
 dc.w 189,199,210,222,233,245,257,269,281,293
 dc.w 306,318,331,343,356,368,380,392,405,416
 dc.w 428,440,451,462,473,484,494,504,513,523
 dc.w 531,540,548,556,563,570,576,582,588,593
 dc.w 597,602,605,608,611,613,615,617,617,618
 dc.w 618,617,616,615,613,611,608,605,602,598
 dc.w 594,589,585,580,574,568,562,556,550,543
 dc.w 536,529,522,514,507,499,491,484,476,468
 dc.w 460,452,444,436,428,420,412,405,397,389
 dc.w 382,375,368,361,354,348,342,335,330,324
 dc.w 319,314,309,304,300,296,292,289,286,283
 dc.w 280,278,276,274,273,272,271,271,271,271
 dc.w 271,272,273,274,275,277,279,281,284,286
 dc.w 289,292,296,299,303,306,310,314,319,323
 dc.w 327,332,337,341,346,351,356,361,366,371
 dc.w 375,380,385,390,395,400,404,409,414,418
 dc.w 423,427,431,435,439,443,446,450,453,456
 dc.w 460,462,465,468,470,472,474,476,478,479
 dc.w 480,482,482,483,484,484,484,484,484,484
 dc.w 483,483,482,481,480,479,477,476,474,472
 dc.w 470,468,466,464,462,460,457,455,452,449
 dc.w 447,444,441,438,435,433,430,427,424,421
 dc.w 418,415,413,410,407,405,402,399,397,394
 dc.w 392,390,387,385,383,381,379,377,376,374
 dc.w 372,371,370,368,367,366,365,364,364,363
 dc.w 362,362,362,362,361,361,361,362,362,362
 dc.w 363,363,364,364,365,366,367,368,369,370
 dc.w 371,372,374,375,376,377,379,380,382,383
 dc.w 385,386,387,389,390,392,393,395,396,398
 dc.w 399,400,402,403,404,406,407,408,409,411
 dc.w 412,413,414,415,415,416,417,418,419,419
 dc.w 420,420,421,421,422,422,422,422,423,423
 dc.w 423,423,423,423,423,422,422,422,422,421
 dc.w 421,421,420,420,420,419,419,418,418,417
 dc.w 416,416,415,415,414,414,413,412,412,411
 dc.w 411,410,410,409,409,408,408,407,407,406
 dc.w 406,405,405,405,404,404,404,403,403,403
 dc.w 403,402,402,402,402,402,402,402,402,402
 dc.w 402,402,402,402,402,402,402,402,403,403
 dc.w 403,403,403,403,404,404,404,404,404,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405,405,405,405
 dc.w 405,405,405,405,405,405,405
finondes:
;
IMAGELOGO:
	dc.l	LOGO+0,$AD400000
IMAGERAYON:
	dc.l	RAYON+0,$10400000+1*256
	dc.l	RAYON+$200,$10400000
	dc.l	RAYON+$400,$260B0000
	dc.l	RAYON+$508,$2C0C0000
	dc.l	RAYON+$628,$300C0000
	dc.l	RAYON+$748,$2F0A0000
IMAGESORCIER:
	dc.l	SORCIER+0,$1C3F0000+4*256
	dc.l	SORCIER+$3F0,$1D3F0000+3*256
	dc.l	SORCIER+$7E0,$20490000+0*256
	dc.l	SORCIER+$C70,$1D3F0000+3*256
	dc.l	SORCIER+$1060,$1C3F0000+4*256
	dc.l	SORCIER+$1450,$1B400000+5*256
	dc.l	SORCIER+$1850,$1C3F0000+4*256
IMAGETRANS:
	dc.l	TRANS+0,$315B0000
	dc.l	TRANS+$B60,$2F5A0000
	dc.l	TRANS+$13D0,$30590000
	dc.l	TRANS+$1C28,$30510000
	dc.l	TRANS+$23C0,$30520000
	dc.l	TRANS+$2B70,$304F0000
	dc.l	TRANS+$32D8,$30430000
	dc.l	TRANS+$3920,$38460000
	dc.l	TRANS+$41E0,$303C0000
	dc.l	TRANS+$4780,$2F3E0000
	dc.l	TRANS+$4D50,$2F370000
	dc.l	TRANS+$5278,$33360000
	dc.l	TRANS+$5938,$2B310000
	dc.l	TRANS+$5DD0,$2C310000
	dc.l	TRANS+$6268,$2B300000
	dc.l	TRANS+$66E8,$2A300000

IMAGEFEMME:
	dc.l	FEMME+0,$3F660000+1*256
	dc.l	FEMME+$CC0,$40630000
IMAGECOURSE:
	dc.l	COURSE+0,$244F0000+7*256
	dc.l	COURSE+$768,$24500000+4*256
	dc.l	COURSE+$EE8,$304A0000+2*256
	dc.l	COURSE+$15D8,$204F0000+8*256
	dc.l	COURSE+$1AC8,$26500000+5*256
	dc.l	COURSE+$2248,$304B0000+0*256

IMAGEFOND:
	dc.l	FOND+0,$E0B00000

TRANS:	INCBIN	INCLUDES\TRANS.DAT
LOGO:	INCBIN	INCLUDES\LOGO.DAT
RAYON:	INCBIN	INCLUDES\RAYON.DAT
SORCIER:INCBIN	INCLUDES\SORCIER.DAT

COURSE:	INCBIN	INCLUDES\COURSE.DAT
FEMME:	INCBIN	INCLUDES\FEMME.DAT
FOND:	INCBIN	INCLUDES\FOND.DAT

	IFEQ	DEBUG
debugger:incbin	E:\INCLUDES\debugger.bin
	ENDC

;	SECTION	BSS
FASTFEMME:EQU	ramtop-2*16*4-189324
;	ds.b	2*16*4+189324
FINBUFFERFEMME:EQU	FASTFEMME+2*16*4+189324
FASTRAYON:EQU	FASTFEMME
FASTLOGO:EQU	FASTFEMME
	ifne	UPLOAD
	SECTION	DATA
	endc
FINCODE:
generespr:
