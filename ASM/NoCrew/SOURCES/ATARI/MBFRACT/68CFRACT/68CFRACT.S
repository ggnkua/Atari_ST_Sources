; A mandelbrot fractal generator. Uses MC68030 only.
; This is the 'coast-walking' version.
; Author: Fredrik Noring, February 1994.

; Fractal module.

* Fractal main routine.
fractal	clr.l	dx
	clr.l	dy
	clr.l	dfx
	clr.l	dfy

.loop	move.l	dx(pc),d0
	move.l	dy(pc),d1
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	tst.b	(a5,d0.l)
	bne.s	.jump

	move.l	dfx(pc),d0
	move.l	dfy(pc),d1
	tst.w	enhanced
	beq.s	.nnhncd
	bsr	e_calc
	bra.s	.moveon
.nnhncd	bsr	calc
.moveon
	move.l	dfx(pc),d0
	move.l	dfy(pc),d1
	bsr	color

	cmp.l	cw_level(pc),d7
	blo.s	.no_way
	cmp.l	chist1(pc),d7
	bne.s	.no_way
	cmp.l	chist2(pc),d7
	bne.s	.no_way
	cmp.l	chist3(pc),d7
	bne.s	.no_way
	bsr	cwalk			; Coast walk.

.jump	clr.l	chist2			; 'Clear' history list.
	move.l	#-1,chist1
	bra.s	.resume

.no_way	move.l	dx(pc),d0
	move.l	dy(pc),d1
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	move.b	#1,(a5,d0.l)

	move.l	chist2(pc),chist3
	move.l	chist1(pc),chist2
	move.l	d7,chist1

.resume	addq.l	#1,dx			; Next x.
	addq.l	#4,dfx
	move.l	fractal_w(pc),d0
	cmp.l	dx(pc),d0
	bhi	.loop

	bsr	intract
	tst.w	stop
	bmi.s	.bye
	tst.w	exit
	bmi.s	.bye

	clr.l	dx			; Next y.
	clr.l	dfx
	addq.l	#1,dy
	addq.l	#4,dfy
	move.l	fractal_h(pc),d0
	cmp.l	dy(pc),d0
	bhi	.loop

.bye	rts

* Main calculation.
* d0 = x coordinate multiplyed by 4.
* d1 = y coordinate multiplyed by 4.
* d7 -> iterations.
calc	lea	fx_tab(pc),a1
	lea	fy_tab(pc),a2
	move.l	(a1,d0.l),d0
	move.l	(a2,d1.l),d6
	move.l	d0,a5
	move.l	d6,a6
	moveq	#1,d7		; n  -> d7
	moveq	#8,d4
	move.l	miter(pc),d3
	move.l	#$4000000,d2
.inner	move.l	d6,d1		; y
	muls.l	d1,d1:d1	; w = y * y  -> d1
	lsl.l	d4,d1
	move.l	d0,d5		; x
	add.l	d5,d5		; (Part I, should be after the `check`)
	muls.l	d6,d6:d5	; 2 * x * y -> d6 (y) (d5 is now `free`)
	muls.l	d0,d0:d0	; q = x * x  -> d0
	lsl.l	d4,d0
	move.l	d0,d5
	add.l	d1,d5		; q + w
	cmp.l	d2,d5
	bhs.s	.resume		: (q + w) > 4 ?
	cmp.l	d3,d7
	bhs.s	.resume		; n > max_iter ?
	sub.l	d1,d0
	add.l	a5,d0		; nx = q - w + r  -> x
	lsl.l	d4,d6		; (Part II, register d5 is now `free`!)
	add.l	a6,d6		; y = 2 * x * y + i  -> y
	addq.l	#1,d7		; n++
	bra.s	.inner
.resume	rts

* Main calculation. Enhanced!
* d0 = x coordinate multiplyed by 4.
* d1 = y coordinate multiplyed by 4.
* d7 -> iterations.
e_calc	lea	fx_tab(pc),a1
	lea	fy_tab(pc),a2
	move.l	(a1,d0.l),d0
	move.l	(a2,d1.l),d6
	move.l	d0,a5
	move.l	d6,a6
	moveq	#1,d7		; n  -> d7
	moveq	#8,d4
	move.l	miter(pc),a0
	move.l	#$4000000,a1
.inner	move.l	d6,d3		; y
	muls.l	d3,d1:d3	; w = y * y  -> d1
	lsl.l	d4,d1
	clr.w	d3
	swap.w	d3
	add.w	#%0000000010000000,d3
	lsr.w	d4,d3
	add.l	d3,d1
	move.l	d0,d5		; Save x in d5
	move.l	d0,d3		; Save x in d5
	muls.l	d0,d0:d3	; q = x * x  -> d0
	lsl.l	d4,d0
	clr.w	d3
	swap.w	d3
	add.w	#%0000000010000000,d3
	lsr.w	d4,d3
	add.l	d3,d0
	move.l	d0,d2
	add.l	d1,d2		; q + w
	cmp.l	a1,d2
	bhs.s	.resume		: (q + w) > 4 ?
	cmp.l	a0,d7
	bhs.s	.resume		; n > max_iter ?
	add.l	d5,d5		; (Part I, should be after the `check`)
	muls.l	d6,d6:d5	; 2 * x * y -> d6 (y) (d5 is now `free`)
	lsl.l	d4,d6		; (Part II, register d5 is now `free`!)
	clr.w	d5
	swap.w	d5
	add.w	#%0000000010000000,d5
	lsr.w	d4,d5
	add.l	d5,d6
	add.l	a6,d6		; y = 2 * x * y + i  -> y
	sub.l	d1,d0
	add.l	a5,d0		; nx = q - w + r  -> x
	addq.l	#1,d7		; n++
	bra.s	.inner
.resume	rts

* Color cache, checks a pixel and takes appropriate mesures.
* This routine got a little fractal map.
* d7 -> Status, 0 = failure.
c_cache	cmp.w	#5,turner
	bhs	f_fill

	tst.l	d0
	bmi	.no
	tst.l	d1
	bmi	.no
	cmp.l	fractal_w(pc),d0
	bhs	.no
	cmp.l	fractal_h(pc),d1
	bhs	.no

	cmp.l	dx(pc),d0
	bne.s	.no_way
	cmp.l	dy(pc),d1
	beq	f_fill

.no_way	move.l	d0,tcwx		; Save for future use.
	move.l	d1,tcwy
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	add.l	d0,a5
	cmp.b	#1,(a5) 	; Has this pixel already been drawn?
	beq.s	.no		; .no = yes it has!
	cmp.b	#3,(a5) 	; Has this pixel already been drawn
	beq.s	.ok		;  by this routine? .ok = yes it has!

	* The pixel is not recorded in the cache table,
	* It simply HAS to be calculated.
	move.l	tcwx(pc),d0
	move.l	tcwy(pc),d1
	lsl.l	#2,d0
	lsl.l	#2,d1
	tst.w	enhanced
	beq.s	.nnhncd
	bsr	e_calc
	bra.s	.moveon
.nnhncd	bsr	calc
.moveon
	move.l	tcwx(pc),d0
	move.l	tcwy(pc),d1
	lsl.l	#2,d0
	lsl.l	#2,d1
	bsr	color
	cmp.l	citer(pc),d7	; Is it our color?
	bne.s	.nope
	move.l	tcwx(pc),d0
	move.l	tcwy(pc),d1
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	move.b	#3,(a5,d0.l)	; Mark it as one to fill.
.ok	moveq.l	#1,d7
	rts
.no	moveq.l	#0,d7
	rts
.nope	move.l	tcwx(pc),d0
	move.l	tcwy(pc),d1
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	move.b	#1,(a5,d0.l)	; This is an alien pixel.
	moveq.l	#0,d7
	rts

f_fill	lea	sx_tab(pc),a3
	lea	sy_tab(pc),a4

	move.l	citer(pc),d7
	move.l	d7,d2
	and.l	#$ff,d2		; Only 256 colors.
	lea	palett(pc),a6
	lsl.l	#1,d2
	move.w	(a6,d2.l),d6

	lea	fractal_map(pc),a5
	move.l	fractal_h(pc),d0
	subq.l	#1,d0
	moveq.l	#0,d3
.1	move.l	fractal_w(pc),d1
	subq.l	#1,d1
	moveq.l	#0,d2
.2	cmp.b	#3,(a5)
	bne.s	.no
	move.b	#1,(a5)+
	addq.l	#4,d2
	dbra	d1,.3
	bra.s	.resume
.3	cmp.b	#1,(a5)
	beq.s	.no
	bsr	scolor
	move.b	#1,(a5)+
	addq.l	#4,d2
	dbra	d1,.3
	bra.s	.resume
.no	addq.l	#1,a5
	addq.l	#4,d2
	dbra	d1,.2
.resume	moveq.l	#0,d2
	addq.l	#4,d3
	dbra	d0,.1
	moveq.l	#-1,d7
	rts

* Coast walk routine.
* The rule: 'Always try to turn to the left.'
cwalk	move.l	dx(pc),cwx
	move.l	dy(pc),cwy
	move.l	d7,citer

	move.l	cwx(pc),d0
	move.l	cwy(pc),d1
	lea	fmapy_tab(pc),a5
	lsl.l	#2,d1
	move.l	(a5,d1.l),a5
	move.b	#3,(a5,d0.l)	; Mark it as one to fill.

	clr.w	turner

f_right	addq.w	#1,turner
	move.l	cwx(pc),d0
	move.l	cwy(pc),d1
	subq.l	#1,d1
	bsr	c_cache
	tst.l	d7
	bmi	f_quit
	beq.s	f_down
	subq.l	#1,cwy
	clr.w	turner
	bra.s	f_up
f_down	addq.w	#1,turner
	move.l	cwx(pc),d0
	move.l	cwy(pc),d1
	addq.l	#1,d0
	bsr	c_cache
	tst.l	d7
	bmi.s	f_quit
	beq.s	f_left
	addq.l	#1,cwx
	clr.w	turner
	bra.s	f_right
f_left	addq.w	#1,turner
	move.l	cwx(pc),d0
	move.l	cwy(pc),d1
	addq.l	#1,d1
	bsr	c_cache
	tst.l	d7
	bmi.s	f_quit
	beq.s	f_up
	addq.l	#1,cwy
	clr.w	turner
	bra.s	f_down
f_up	addq.w	#1,turner
	move.l	cwx(pc),d0
	move.l	cwy(pc),d1
	subq.l	#1,d0
	bsr	c_cache
	tst.l	d7
	bmi.s	f_quit
	beq	f_right
	subq.l	#1,cwx
	clr.w	turner
	bra.s	f_left
f_quit	rts

* Fractal initialization.
init_f	* Calculate screen start as address offset's in x and y.
	move.l	screen_w(pc),d0
	sub.l	fractal_w(pc),d0
	and.b	#%11111110,d0	: d0 / 2 * 2 (1 pixel = 1 word)
	move.l	d0,sbx
	move.l	screen_h(pc),d0
	sub.l	fractal_h(pc),d0
*	lsr.l	#1,d0		; d0 / 2
	mulu.l	screen_w(pc),d0
	and.b	#%11111110,d0
*	lsl.l	#1,d2
	move.l	d0,sby

	move.l	#CWALK_LEVEL,cw_level

	move.l	d(pc),d0		; fx1			a
	move.l	b(pc),d1		; fx2			c
	sub.l	d0,d1			; fx2 - fx1		c - a
	move.l	fractal_h(pc),d2	; Fractal width		fractal_w
	divs.l	d2,d1			;      (c - a)
	move.l	d1,delta		; ----------------- = delta
					;  (Fractal width)

	lea	fx_tab(pc),a0		; Fractal x table.
	lea	sx_tab(pc),a1		; Screen x table.
	move.l	a(pc),d1
	moveq.l	#0,d4			; Counter (0 -> (screen width))
	move.l	sbx(pc),d6
	move.l	fractal_w(pc),d0
	subq.l	#1,d0
	move.l	delta(pc),d7
.x_loop	move.l	d7,d5
	muls.l	d4,d5		; delta * counter
	add.l	d1,d5		; a + delta * counter
	move.l	d5,(a0)+
	move.l	d6,(a1)+
	addq.l	#1,d4
	addq.l	#2,d6
	dbra	d0,.x_loop

	lea	fy_tab(pc),a0		; Fractal y table.
	lea	sy_tab,a1		; Screen y table.
	move.l	b(pc),d1
	move.l	screen_w(pc),d2
	lsl.l	#1,d2
	moveq.l	#0,d4			; Counter (0 -> (screen height))
	move.l	sby(pc),d6
	move.l	fractal_h(pc),d0
	subq.l	#1,d0
	move.l	delta(pc),d7
	neg.l	d7
.y_loop	move.l	d7,d5
	muls.l	d4,d5		; delta * counter
	add.l	d1,d5		; b + delta * counter
	move.l	d5,(a0)+
	move.l	d6,(a1)+
	addq.l	#1,d4
	add.l	d2,d6
	dbra	d0,.y_loop

	lea	fractal_map(pc),a0
	move.l	fractal_h(pc),d0
	subq.l	#1,d0
.1	move.l	fractal_w(pc),d1
	subq.l	#1,d1
.2	clr.b	(a0)+
	dbra	d1,.2
	dbra	d0,.1

	move.l	#fractal_map,d1
	lea	fmapy_tab(pc),a0
	move.l	fractal_h(pc),d0
	subq.l	#1,d0
.fmapy	move.l	d1,(a0)+
	add.l	fractal_w(pc),d1
	dbra	d0,.fmapy
	rts

	section	data
* External parameters.
a		dc.l	A
b		dc.l	B
c		dc.l	C
d		dc.l	D
miter		dc.l	MITER

* Internal parameters.
n		dc.l	0			; n iterations.
x		dc.l	0			; x.
y		dc.l	0			; y.
r		dc.l	0			; r.
i		dc.l	0			; i.
dx		dc.l	0			; dx.
dy		dc.l	0			; dy.
dfx		dc.l	0			; d4x.
dfy		dc.l	0			; d4y.
sbx		dc.l	0			; Screen begin x.
sby		dc.l	0			; Screen begin y.
delta		dc.l	0			; (c - a) / (fractal width)
* The coast walk parameters.
cwx		dc.l	0			; Coast walk x.
cwy		dc.l	0			; Coast walk y.
tcwx		dc.l	0			; Temporary coast walk x.
tcwy		dc.l	0			; Temporary coast walk y.
chist1		dc.l	0			; Color history, one step.
chist2		dc.l	0			; Color history, two steps.
chist3		dc.l	0			; Color history, three steps.
citer		dc.l	0			; Current iteration level.
ccolor		dc.w	0			; Current color used.
turner		dc.w	0			; Keeps track of the turns.
cw_level	dc.l	0			; Iteration-level before
						;  `coast-walking`.
		section	bss
fx_tab		ds.l	FRACTAL_W	; Precalculated fractal x and y.
fy_tab		ds.l	FRACTAL_H	;  Fractal width must be narrower.
sx_tab		ds.l	FRACTAL_W	; Precalculated screen x and y.
sy_tab		ds.l	FRACTAL_H	;  Fractal width must be narrower.
fmapy_tab	ds.l	FRACTAL_H
fractal_map	ds.b	FRACTAL_W*FRACTAL_H	; Used when filling etc.

