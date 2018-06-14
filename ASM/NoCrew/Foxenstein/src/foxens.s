; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - Foxenstein -
;    a NoCrew production MCMXCV
;
;    (c) Copyright NoCrew 1995
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Main module.

	section	text

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp
	move.l	d0,old_sp

	lea	texture1+128,a0
	lea	extended1,a1
	bsr.w	extend
	lea	texture2+128,a0
	lea	extended2,a1
	bsr.w	extend

	bsr	foxenstein

	move.l	old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		* Super
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1		* Pterm0

foxenstein	bsr.w	save_video
	bsr.w	new_video
	bsr.w	init_DSP
	bsr.w	init_blitter
	bsr.w	DMA_flipp

main	bsr.w	flipp
	bsr.w	DMA_flipp
	clr.w	$468.w
.vsync	tst.w	$468.w
	beq.s	.vsync

;	not.l	$ffff9800.w
	move.l	DMA_physic,a0
	bsr	BLiTTER_copy
;	not.l	$ffff9800.w

	move.b	$fffffc02.w,key_code
	moveq	#0,d0
	move.b	key_code,d0
	bsr.w	DSP_key

	cmp.b	#$b9,key_code		* space
	bne.s	main

	bsr.w	restore_video
	bsr.w	exit_DSP
	rts

* Initialize blitter.
init_blitter	move.w	#$ffff,$ffff8a28.w	* endmask 1
	move.w	#$ffff,$ffff8a2a.w	* endmask 2
	move.w	#$ffff,$ffff8a2c.w	* endmask 3
	move.w	#2,$ffff8a20.w	* source x increment
	move.w	#2,$ffff8a2e.w	* destination x increment
	move.l	real_screen_w,d0
	lsl	d0
	move.w	d0,$ffff8a30.w	* destination y increment
	move.b	#2,$ffff8a3a.w	* hop
	move.b	#%00000000,$ffff8a3d.w
	rts

BLiTTER_copy	move.l	logic,a1
	move.w	#1,d2
	lea	textures,a3
	moveq	#0,d0
.again	move.w	(a0)+,d0
	move.w	(a0)+,d1
	bmi.s	.end_sync
	move.l	(a3,d1.w*4),a4
	move.w	(a0)+,d1
	lea	(a1,d0.l*2),a2
	lea	(a4,d1.w),a4
;.wait	btst.b	#7,$ffff8a3c.w
;	bne.s	.wait
	move.w	(a0)+,$ffff8a38.w	* y count
	move.w	(a0)+,$ffff8a22.w	* source y increment
	move.l	a4,$ffff8a24.w	* source address
	move.l	a2,$ffff8a32.w	* destination address
	move.w	d2,$ffff8a36.w	* x count
	move.w	(a0)+,$ffff8a3b.w
	bra.s	.again
.end_sync	rts

extend	move.w	#60-1,d0
.1	move.w	#16-1,d1
.2	move.l	a0,a2
	move.w	#80-1,d2
.3	move.w	(a2)+,(a1)+
	dbra	d2,.3
	dbra	d1,.2
	lea	2*80(a0),a0
	dbra	d0,.1
	rts

	include	dsp.s
	include	graphic.s

	section	data
screen
screen_w	dc.l	320
screen_h	dc.l	200
real_screen_w	dc.l	320
real_screen_h	dc.l	200

textures	dc.l	extended1
	dc.l	extended2

texture1	incbin	cheeta.tpi
texture2	incbin	mist4.tpi

	section	bss
key_code	ds.w	1
old_sp	ds.l	1		* old stack pointer
extended1	ds.b	2*80*60*16
extended2	ds.b	2*80*60*16
	end



