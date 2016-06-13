; A mandelbrot fractal generator. Uses the DSP. (Not opitimized!)
; Author: Fredrik Noring, February 1994.

; Fractal module.

initcalc
	Dsp_RequestUniqueAbility
	move.w	d0,dsp_abil
	Dsp_ExecProg #dsp_prog_start,#(dsp_prog_end-dsp_prog_start)/3,dsp_abil
	rts

send_param
;	Dsp_BlkUnpacked #dsp_param,#1+FRACTAL_W+FRACTAL_H,#0,#0
	Dsp_BlkUnpacked #dsp_param,#3+FRACTAL_W+FRACTAL_H,#0,#0
;	Dsp_BlkHandShake #dsp_param,#3+2*240,#0,#0
	rts

* Fractal main routine.
fractal	clr.l	dx
	clr.l	dy
	clr.l	dfx
	clr.l	dfy

.loop	Dsp_BlkHandShake #0,#0,#pixels,#FRACTAL_W

	move.l	screen(pc),a0
	lea	sy_tab(pc),a4
	move.l	dfy(pc),d1
	move.l	(a4,d1.l),d0
	add.l	d0,a0
	add.l	sbx(pc),a0
	lea	palett(pc),a6

	lea	pixels,a1
	move.w	#FRACTAL_W/2-1,d5
.1	moveq	#0,d7
	addq.w	#1,a1
	move.b	(a1)+,d7
	lsl.w	#8,d7
	move.b	(a1)+,d7
	cmp.l	miter(pc),d7
	bhs.s	.no1
	move.w	(a6,d7.w*2),(a0)
.no1	addq.w	#2,a0

	moveq	#0,d7
	addq.w	#1,a1
	move.b	(a1)+,d7
	lsl.w	#8,d7
	move.b	(a1)+,d7
	cmp.l	miter(pc),d7
	bhs.s	.no2
	move.w	(a6,d7.w*2),(a0)
.no2	addq.w	#2,a0
	dbra	d5,.1

	bsr	intract
	tst.w	stop
	bmi.s	.bye
	tst.w	exit
	bmi.s	.bye

	addq.l	#1,dy
	addq.l	#4,dfy
	move.l	fractal_h(pc),d0
	cmp.l	dy(pc),d0
	bhi	.loop
.bye	rts

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

	move.l	d(pc),d0		; fx1			a
	move.l	b(pc),d1		; fx2			c
	sub.l	d0,d1			; fx2 - fx1		c - a
	move.l	fractal_h(pc),d2	; Fractal width		fractal_w
	divs.l	d2,d1			;      (c - a)
	move.l	d1,delta		; ----------------- = delta
					;  (Fractal width)

	lea	dsp_fx_tab(pc),a0	; Fractal x table.
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
	asr.l	#4,d5	; DSP 24 bit fix
	move.l	d5,(a0)+
	move.l	d6,(a1)+
	addq.l	#1,d4
	addq.l	#2,d6
	dbra	d0,.x_loop

	lea	dsp_fy_tab(pc),a0	; Fractal y table.
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
	asr.l	#4,d5	; DSP 24 bit fix
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
; DSP section
dsp_param
dsp_miter	dc.l	MITER
dsp_fractal_dx	dc.l	FRACTAL_W
dsp_fractal_dy	dc.l	FRACTAL_H
dsp_fx_tab	ds.l	FRACTAL_W	; Precalculated fractal x and y.
dsp_fy_tab	ds.l	FRACTAL_H	;  Fractal width must be narrower.

dsp_n		dc.l	0

dsp_abil	dc.w	0
dsp_prog_start	incbin	mndlbrt2.p56
dsp_prog_end

		even

		section	bss
sx_tab		ds.l	FRACTAL_W	; Precalculated screen x and y.
sy_tab		ds.l	FRACTAL_H	;  Fractal width must be narrower.
pixels		ds.l	1024
fmapy_tab	ds.l	FRACTAL_H
fractal_map	ds.b	FRACTAL_W*FRACTAL_H	; Used when filling etc.

