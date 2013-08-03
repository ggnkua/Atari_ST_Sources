; Test de collision de sprites
; a l'aide du blitter
; par Patrice Mandin le 29/03/1994

; Bouton souris pour sortir
; En blanc : effacement ecran
; En vert : test de collision
; Bleu : pas de collision
; Orange : collision

; -1 si falcon
; 0 si autre machine blitter

falcon	equ	-1

; falcon video modes

_interlace	equ	256
_stcomp		equ	128
_overscan	equ	64
_pal		equ	32
_vga		equ	16
_column80	equ	8
_colorTC	equ	4
_color256	equ	3
_color16	equ	2
_color4		equ	1
_color2		equ	0

	TEXT

	move.l	a7,a5
	lea	pile,a7
	move.l	4(a5),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	add.l	#256,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr	-(sp)
	move	#74,-(sp)
	trap	#1
	lea	12(sp),sp

;	Sauver params ecran

	IFNE	falcon
	pea	$0058ffff
	trap	#14
	addq	#4,sp
	move	d0,vmode
	move	d0,-(sp)
	move	#3,-(sp)
	ELSE
	move	#4,-(sp)
	trap	#14
	addq	#2,sp
	clr	-(sp)
	move	d0,-(sp)
	ENDC
	
	move	#3,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,screen
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#5,-(sp)

;	En 320x200x16c

	IFNE	falcon
	move	vmode,d0
	and	#$fe00+_vga+_pal,d0
	or	#_stcomp+_color16,d0
	move	d0,-(sp)
	move	#$58,-(sp)
	trap	#14
	addq	#4,sp
	ELSE
	clr	-(sp)
	pea	-1
	pea	-1
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	ENDC

;	Lance programme

	pea	go
	move	#38,-(sp)
	trap	#14
	addq	#6,sp

;	Restaure l'ecran

	trap	#14
	lea	14(sp),sp

	clr	-(sp)
	trap	#1
	
;	Sauve registres

go	move	#$2700,sr
	lea	$fffffa00.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)
	lea	$ffff8240.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	$118.w,-(sp)
	move.l	$70.w,-(sp)
	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w
	move.l	#ikbd,$118.w
	move.l	#vbl,$70.w
	move.b	#8,$fffffc02.w
	move.l	#$00000f00,$ffff8240.w
	move.l	#$00f00ff0,$ffff8244.w

;	Souris

	clr	mb
	move	#80,mx
	move	#100,my

;	Affiche gros sprite sur deuxieme plan

	move.l	screen,a1
	add.l	#2+64+68*160,a1
	lea	$ffff8a20.w,a0
	move.l	#$00020000,(a0)+
	move.l	#bigboule,(a0)+
	move.l	#$ffffffff,(a0)+
	clr	(a0)+
	move.l	#$00080080,(a0)+
	move.l	a1,(a0)+
	move.l	#$00050040,(a0)+
	move.l	#$02068000,(a0)
.waitbl	tas	2(a0)
	bmi.s	.waitbl

	move	#$2300,sr
	
;	Attend la prochaine vbl

attente	tst	vsync	
	beq.s	attente

;	Attend premiere ligne

	move.b	$ffff8209.w,d0
waitlin	cmp.b	$ffff8209.w,d0
	beq.s	waitlin

	move	#$fff,$ffff8240.w

;	Cls premier plan	

	lea	$ffff8a28.w,a0
	move.l	#$ffffffff,(a0)+
	move	#$ffff,(a0)+
	move.l	#$00080000,(a0)+
	move.l	screen,(a0)+
	move.l	#$0fa00001,(a0)+
	move.l	#$00008000,(a0)
.waitbl	tas	2(a0)
	bmi.s	.waitbl

;	Affiche petit sprite sur premier plan

	move.l	screen,a1
	move	my,d0
	mulu	#160,d0
	add.l	d0,a1
	move	mx,d0
	and	#-16,d0
	lsr	#1,d0
	add	d0,a1

	move.l	#$02038000,d1
	move	mx,d0
	moveq	#-1,d2
	and	#15,d0
	lsr.l	d0,d2
	swap	d2
	move	d2,d3
	swap	d2
	not	d3
	or	d0,d1

	lea	$ffff8a20.w,a0
	move.l	#$00020000,(a0)+
	move.l	#titeboule,(a0)+
	move.l	d2,(a0)+
	move	d3,(a0)+
	move.l	#$00080090,(a0)+
	move.l	a1,(a0)+
	move.l	#$00030020,(a0)+
	move.l	d1,(a0)
.waitb1	tas	2(a0)
	bmi.s	.waitb1

; -----	Test de collision : inits

	move.l	#titeboule,cadr1
	move	mx,cx1
	move	my,cy1
	move	#32,clx1
	move	#32,cly1

;	Pour sprite 2

	move.l	#bigboule,cadr2
	move	#160-32,cx2
	move	#100-32,cy2
	move	#64,clx2
	move	#64,cly2

;	Le test

	move	#$264,$ffff8240.w
	bsr	collision_test
	move	#$246,$ffff8240.w

;	Desactive cache si falcon

	IFNE	falcon
	movec	cacr,d0
	move	d0,-(sp)
	bclr	#8,d0
	movec	d0,cacr
	ENDC

;	Ya collision ?

	tst	colflag
	beq.s	notacollision
	move	#$642,$ffff8240.w
notacollision

;	Reactive cache

	IFNE	falcon
	move	(sp)+,d0
	movec	d0,cacr
	ENDC

;	Encore ?

	clr	vsync
	move	mx,mx1
	move	my,my1
	btst.b	#1,mb
	beq	attente

;	Restaurations

	move	#$2700,sr
	move.b	#8,$fffffc02.w
	move.l	(sp)+,$70.w
	move.l	(sp)+,$118.w
	lea	$ffff8260.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	lea	$fffffa20.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	move	#$2300,sr
	
videkbd	btst	#0,$fffffc00.w
	beq.s	fin
	move.b	$fffffc02.w,d0
	bra.s	videkbd
fin	rts

; ------------------------------
; Test de collision
; ------------------------------
; pour les deux sprites :
;	cadr(n) : adr du masque
;	cx(n)   : posx du sprite
;	cy(n)   : posy du sprite
;	clx(n)  : largeur du sprite
;	cly(n)  : hauteur du sprite

collision_test
	clr	colflag

; -- Collision verticale ?

	move	cy1,d0
	cmp	cy2,d0
	bhi.s	no_colver1
	add	cly1,d0
	cmp	cy2,d0
	bls.s	no_colver1
	clr	csy2
	move	cy2,d0
	sub	cy1,d0
	move	d0,csy1
	move	cly1,d1
	sub	d0,d1
	bra.s	col_ver

no_colver1	
	move	cy2,d0
	cmp	cy1,d0
	bhi	no_collision
	add	cly2,d0
	cmp	cy1,d0
	bls	no_collision
	clr	csy1
	move	cy1,d0
	sub	cy2,d0
	move	d0,csy2
	move	cly2,d1
	sub	d0,d1

col_ver	cmp	cly1,d1
	ble.s	colver_ty1
	move	cly1,d1
colver_ty1
	cmp	cly2,d1
	ble.s	colver_ty2
	move	cly2,d1
colver_ty2
	move	d1,cty

; -- Collision horizontale ?

	move	cx1,d0
	cmp	cx2,d0
	bhi.s	no_colhor1
	add	clx1,d0
	cmp	cx2,d0
	bls.s	no_colhor1
	clr	csx2
	move	cx2,d0
	sub	cx1,d0
	move	d0,csx1
	move	clx1,d1
	sub	d0,d1
	bra.s	col_hor

no_colhor1
	move	cx2,d0
	cmp	cx1,d0
	bhi	no_collision
	add	clx2,d0
	cmp	cx1,d0
	bls	no_collision
	clr	csx1
	move	cx1,d0
	sub	cx2,d0
	move	d0,csx2
	move	clx2,d1
	sub	d0,d1

col_hor	cmp	clx1,d1
	ble.s	colhor_tx1
	move	clx1,d1
colhor_tx1
	cmp	clx2,d1
	ble.s	colhor_tx2
	move	clx2,d1
colhor_tx2
	move	d1,ctx

;	d2 = midmask , rightmask
;	d3 = largeur de la ZI en mots

	moveq	#-1,d2
	move	ctx,d3
	move	d3,d0
	neg	d0
	and	#15,d0
	beq.s	col_nomult16
	add	#16,d3
	and	#-16,d3
col_nomult16
	lsl	d0,d2
	lsr	#4,d3

; -- Copie sprite 1 dans buffer
;	dest = source

	lea	cx1,a0
	move.l	#$02038000,d0
	jsr	col_blitter
	
; -- And sprite 2 dans buffer
;	dest = source and dest

	lea	cx2,a0
	move.l	#$02018000,d0
	jsr	col_blitter

; -- Or buffer dans flag

	moveq	#-1,d1
	move	ctx,d4
	neg	d4
	and	#15,d4
	lsl	d4,d1
	moveq	#-1,d2

	move	d3,d0
	cmp	#1,d0
	bne.s	col_1wrdwide
	move	d1,d2
col_1wrdwide
	swap	d0
	move	cty,d0

	lea	$ffff8a20.w,a0
	move.l	#$00020002,(a0)+
	move.l	#collision,(a0)+
	move	d2,(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	#colflag,(a0)+
	move.l	d0,(a0)+
	move.l	#$02078000,(a0)
.waitbl	tas	2(a0)
	bmi.s	.waitbl

no_collision
	rts

; ------------------------------
;	Blitter ops.
; ------------------------------

col_blitter

;	d5 sourceinc x et y

	moveq	#2,d5
	swap	d5
	move	clx1-cx1(a0),d5
	move	d5,d1
	and	#15,d1
	beq.s	col_nomind5
	add	#16,d5
	and	#-16,d5
col_nomind5
	lsr	#3,d5

;	d1 taille 1 ligne source

	move	d5,d1
	sub	d3,d5
	sub	d3,d5

;	a1 adresse source

	move.l	cadr1-cx1(a0),a1
	mulu	csy1-cx1(a0),d1
	add	d1,a1
	move	csx1-cx1(a0),d1
	and	#-16,d1
	lsr	#3,d1
	add	d1,a1
	
;	a2 adresse destination

	lea	collision-2,a2
	
;	d4 masque gauche

	moveq	#0,d4

;	d6 taille x et y

	move	d3,d6
	addq	#1,d6

;	d7 destinc x et y

	moveq	#2,d7
	swap	d7

	move	csx1-cx1(a0),d1
	neg	d1
	and	#15,d1
	tst	d1
	bne.s	col_bltna15
	addq	#2,a2
	addq	#2,d5
	moveq	#-1,d4
	addq	#2,d7
	subq	#1,d6
	cmp	#1,d6
	bne.s	col_bltna15
	move	d2,d4

col_bltna15
	swap	d6
	move	cty,d6

;	d0 blitter operation
	
	or	d1,d0
	
	lea	$ffff8a20.w,a3
	move.l	d5,(a3)+
	move.l	a1,(a3)+
	move	d4,(a3)+
	move.l	d2,(a3)+
	move.l	d7,(a3)+
	move.l	a2,(a3)+
	move.l	d6,(a3)+
	move.l	d0,(a3)
.waitbl	tas	2(a3)
	bmi.s	.waitbl
	
	rts

; -------------	Interruptions

vbl	move	#-1,vsync
	rte

;	Clavier

ikbd	move.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$f8,d0
	bmi.s	ikbd_no_ms
	cmp.b	#$fb,d0
	bpl.s	ikbd_no_ms
ikbd_yes_ms
	and	#3,d0
	move.b	d0,mb
	move.l	#mousex,$118.w
ikbd_no_ms
	move.l	(sp)+,d0
	bclr	#6,$fffffa11.w
	rte

mousex	move.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	ext	d0
	add	d0,mx
	bpl.s	minmx
	clr	mx
minmx	cmp	#320-16,mx
	bmi.s	maxmx
	move	#320-16,mx
maxmx	move.l	#mousey,$118.w
	move.l	(sp)+,d0
	bclr	#6,$fffffa11.w
	rte

mousey	move.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	ext	d0
	add	d0,my
	bpl.s	minmy
	clr	my
minmy	cmp	#200-16,my
	bmi.s	maxmy
	move	#200-16,my
maxmy	move.l	#ikbd,$118.w
	move.l	(sp)+,d0
	bclr	#6,$fffffa11.w
	rte

	DATA

;	Sprites
	
titeboule	
	rept	4
	dc.w	$f003,$ff0f
	endr
	rept	10
	dc.w	$0000,$000f
	endr
	rept	4
	dc.w	$ffff,$ffff
	endr
	rept	10
	dc.w	$f000,$0000
	endr
	rept	4
	dc.w	$f00f,$ffff
	endr

bigboule	
	rept	4
	dc.w	$ffff,$ffff,$ffff,$ffff
	endr
	rept	12
	dc.w	$f000,$0003,$c000,$0000
	endr
	rept	14
	dc.w	$0000,$0003,$c000,$0000
	endr
	rept	4
	dc.w	$ffff,$ffff,$ffff,$ffff
	endr
	rept	14
	dc.w	$0000,$0003,$c000,$0000
	endr
	rept	12
	dc.w	$0000,$0000,$0000,$000f
	endr
	rept	4
	dc.w	$f00f,$f00f,$ffff,$ffff
	endr

;	Divers

	BSS

vmode	ds.w	1
vsync	ds.w	1
screen	ds.l	1
mx	ds.w	1
my	ds.w	1
mx1	ds.w	1
my1	ds.w	1
mb	ds.w	1

;	Donn‚es du test de collision

cx1	ds.w	1	; position x
cy1	ds.w	1	; position y
clx1	ds.w	1	; largeur
cly1	ds.w	1	; hauteur
csx1	ds.w	1	; pos x zi dans sprite
csy1	ds.w	1	; pos y zi dans sprite
cadr1	ds.l	1	; adr du masque

cx2	ds.w	1
cy2	ds.w	1
clx2	ds.w	1
cly2	ds.w	1
csx2	ds.w	1
csy2	ds.w	1
cadr2	ds.l	1

ctx	ds.w	1	; largeur zi
cty	ds.w	1	; hauteur zi

colflag	ds.w	1	; flag de test

;	Buffer pour zone intersection

collision	ds.b	4000

	ds.l	256
pile	ds.l	1