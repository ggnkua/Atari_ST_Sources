; A mandelbrot fractal generator. Uses MC68030 only.
; This is the 'coast-walking' version.
; Author: Fredrik Noring, February 1994.

; Interactive module.
	section	text

* This module's initialization.
intrint	dc.w	$a000
	move.l	a0,LineA	; Fetch the LineA address.
	rts

* This is the interactive part of this program.
intract	* Latest news...
	move.l	LineA,a6
	move.w	-$25a(a6),mtx
	move.w	-$258(a6),mty
	move.w	-$254(a6),d0
	move.b	d0,mkey

	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	beq	.no_key
	move.w	#8,-(sp)
	trap	#1
	addq.w	#2,sp

	cmp.b	#'e',d0
	beq.s	.enhans
	cmp.b	#'E',d0
	bne.s	.otherk
.enhans	move.w	#1,enhanced
	bsr	drawm
	move.w	#0,mable
	move.w	#-1,mx
	move.w	#-1,my
	move.w	#-1,again
	move.w	#-1,stop
	rts
.otherk	cmp.b	#'n',d0
	beq.s	.nohans
	cmp.b	#'N',d0
	bne.s	.no_key
.nohans	move.w	#0,enhanced
	bsr	drawm
	move.w	#0,mable
	move.w	#-1,mx
	move.w	#-1,my
	move.w	#-1,again
	move.w	#-1,stop
	rts
.no_key

	* Is mouse used??
	tst.w	mable
	beq.s	.nom

	* Redraw previous pointer if neccesary.
	tst.w	mx		; mx and my is = -1 if they
	bmi.s	.nrdraw		; haven't been drawn earlier.
	tst.w	my
	bmi.s	.nrdraw
	bsr	drawm		; Undraw mouse-pointer.
.nrdraw	move.w	mtx,mx
	move.w	mty,my
	bsr	drawm		; Draw mouse-pointer.

	tst.w	mzoom		; Is the zoom(able) flag set?
	beq.s	.nzoom
	btst.b	#0,mkey		; Test the left mouse button.
	beq	.nzoom
	bsr	zoomer

.nzoom
.nom	btst.b	#1,mkey		; Test the right mouse button.
	beq.s	.nexit
	move.w	#-1,exit

.nexit	rts

* Draws mouse-pointer.
* 'mable' must be set!
drawm	tst.w	mable(pc)
	beq.s	.nm

	move.l	screen(pc),a0
	moveq	#0,d0
	move.w	mx(pc),d0
	lsl.l	#1,d0
	add.l	d0,a0
	moveq	#0,d0
	move.w	my(pc),d0
	mulu.l	screen_w(pc),d0
	lsl.l	#1,d0
	add.l	d0,a0

	not.w	(a0)
.nm	rts

zoomer	move.l	screen_w(pc),d0
	sub.l	fractal_w(pc),d0
	lsr.l	#1,d0
	cmp.w	mx(pc),d0
	bhi.s	.nope
	add.l	fractal_w(pc),d0
	cmp.w	mx(pc),d0
	blo.s	.nope
	move.l	screen_h(pc),d0
	sub.l	fractal_h(pc),d0
	lsr.l	#1,d0
	cmp.w	my(pc),d0
	bhi.s	.nope
	add.l	fractal_h(pc),d0
	cmp.w	my(pc),d0
	blo.s	.nope
	bsr	drawm
	move.w	#0,mable
	bsr	re_calc
	move.w	#-1,mx
	move.w	#-1,my
	move.w	#-1,again
	bsr	cls
.nope	rts

re_calc	lea	fx_tab(pc),a1
	lea	fy_tab(pc),a2
	moveq.l	#0,d0
	move.w	mx(pc),d0
	move.l	screen_w(pc),d7
	sub.l	fractal_w(pc),d7
	lsr.l	#1,d7
	sub.l	d7,d0
	lsl.l	#2,d0
	move.l	(a1,d0.l),d0		; Fractal x coordinate.
	moveq.l	#0,d1
	move.w	my(pc),d1
	move.l	screen_h(pc),d7
	sub.l	fractal_h(pc),d7
	lsr.l	#1,d7
	sub.l	d7,d1
	lsl.l	#2,d1
	move.l	(a2,d1.l),d1		; Fractal y coordinate.

	move.l	c(pc),d2
	sub.l	a(pc),d2
	lsr.l	#2+1,d2
	move.l	b(pc),d3
	sub.l	d(pc),d3
	lsr.l	#2+1,d3

	move.l	d0,a
	sub.l	d2,a
	move.l	d1,b
	add.l	d3,b
	move.l	d0,c
	add.l	d2,c
	move.l	d1,d
	sub.l	d3,d
	rts

* Interactive parameters.
	section	data
mx		dc.w	-1		; Mouse x.
my		dc.w	-1		; Mouse y.
mkey		dc.w	0		; Mouse key.
mable		dc.w	0		; Mouse enabled flag.
mzoom		dc.w	0		; Mouse zoom flag.
	section	bss
mtx		ds.w	1		; Mouse temporary y.
mty		ds.w	1		; Mouse temporary x.

* Other parameters.
	section	bss
LineA	ds.l	1			; Line A address.
