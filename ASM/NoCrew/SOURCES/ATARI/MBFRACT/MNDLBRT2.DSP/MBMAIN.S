; A mandelbrot fractal generator. Uses the DSP.
; Author: Fredrik Noring, February 1994.

; Main module.

A		equ	-$1d00000	; x1.
B		equ	 $1400000	; y1.
C		equ	 $0a00000	; x2.
D		equ	-$1200000	; y1.
MITER		equ	128		; Maximum iteration.
COLORS		equ	256		; Adabt 'color'!
SCREEN_W	equ	384		; Screen width.
SCREEN_H	equ	240		; Screen height.
FRACTAL_W	equ	200		; Fractal width.
FRACTAL_H	equ	200		; Fractal height.

MODE		equ	%001000100	; Falcon screen mode.

	include	macrodsp.s

	section	text

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		; Super
	addq.w	#6,sp
	move.l	d0,old_sp

	Dsp_Lock

	dc.w	$a00a		; Hide mouse.
	bsr	intrint
	bsr	get_video
	bsr	new_video
	bsr	cls

* Fractal calculations.
onemore	clr.w	again
	clr.w	stop
	clr.w	mable
	clr.w	mzoom
	bsr	mk_pal
	bsr	init_f
	bsr	initcalc
	bsr	send_param
	bsr	fractal
	tst.w	again
	bmi.s	onemore

	move.w	#1,mable
	move.w	#1,mzoom

* Wait loop.
wait	clr.w	$468.w		; Vsync
.vsync	tst.w	$468.w
	beq.s	.vsync

	bsr	intract

	tst.w	again
	bmi.s	onemore
	tst.w	exit
	beq.s	wait

	bsr	set_video
	dc.w	$a009		; Show mouse.

	Dsp_Unlock

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		; Super
	addq.w	#6,sp

	clr.w	-(sp)		; Pterm0
	trap	#1

	include	mbcalc.s	; Fractal calculation module.
	include	mbinrfce.s	; Interactive module.
	include	mbgrapic.s	; Graphic interface module.

	section	data
* External parameters.
enhanced	dc.w	0		; Enhance flag.
screen_w	dc.l	SCREEN_W
screen_h	dc.l	SCREEN_H
fractal_w	dc.l	FRACTAL_W
fractal_h	dc.l	FRACTAL_H

* Various values.
stop		dc.w	0
exit		dc.w	0
error		dc.w	0
again		dc.w	0
void		dcb.w	128,$0000

	section	bss
old_sp		ds.l	1
screen_mem	ds.b	SCREEN_W*SCREEN_H*2+256
	end


