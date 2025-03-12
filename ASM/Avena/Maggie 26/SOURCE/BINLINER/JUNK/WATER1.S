;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;

messageon		equ	0
loadtex			equ	1

rgb			equ	1
flash			equ	0
vblwait			equ	1
keys			equ	1
tracker_on		equ	0

screenlines		equ	240
bytesperline		equ	384*2
lines			equ	240
pixels			equ	384

direction		equ	1		;(motion blur)







back_colour	equ	0
noscreens	equ	2
demo		equ	0



start:

	ifne	demo
		include	f:\source\tdf\main\equates.s

		opt	nodebug
	endc


	ifeq	demo
		include equates.s
		include	tosstart.i
	else
		include	demstart.i
	endc


;--------------------------------------------------------------
preload:	rts

display_routine:
		bsr	do_effects
		illegal

initialize_routine:
		bsr	set_res
		rts

do_effects:
		bsr	clearscreens
		moveq.l	#$9,d0
		movec	d0,cacr

		;bsr	clearscreen
		move.w	#$1000,d0
		bsr	main_loop
		rts

main_loop:
repeat:
		bsr	get_random
		move.w	d0,d1
		bsr	get_random
		mulu.w	#100*2,d1
		swap	d1
		mulu.w	#192,d1
		mulu.w	#192*2,d0
		swap	d0
		ext.l	d0
		add.l	d0,d1
		
		move.l	water_buffers,a0
		lea	(a0,d1.l*2),a0
		add.w	#2*192,(a0)
		add.w	#2*192/4,-2(a0)
		add.w	#2*192/4,2(a0)
		add.w	#2*192/4,-192*2(a0)
		add.w	#2*192/4,+192*2(a0)
		bsr	create_frame
		bra	repeat
		rts

create_frame:
		bsr	draw_water
		bsr	screen_swap
		rts

draw_water:
		move.l	logic,a0
		movem.l	water_buffers,a1/a2
		exg.l	a1,a2
		movem.l	a1/a2,water_buffers
		lea	water_colour_table+8*16,a3
		lea	water_damping_table,a4
		move.w	#100*192-1,d0
		addq.l	#2,a2

.loop:		move.w	-192*2-2(a2),d2
		add.w	+192*2-2(a2),d2
		add.w	-1*2-2(a2),d2
		add.w	(a2)+,d2
		asr.w	d2
		sub.w	(a1),d2
		move.w	(a4,d2.w*2),(a1)+
		move.l	(a3,d2.w*2),(a0)+
		dbf	d0,.loop
		rts


;--------------------------------------------------------------
set_res
;		move.w	#(384-320),$ffff820e.w	;line width in words

		move.w	#$64,-(a7)
		move.w	#$3,-(a7)
		move.l	logic(pc),-(a7)
		move.l	logic(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	14(a7),a7

		ori.w	#1,$ffff82c2.w	
		clr.l	$ffff9800.w
		rts

get_random:
		move.w	random_seed,d0
		mulu.w	#4433,d0
		addq.l	#7,d0
		move.w	d0,random_seed
		and.w	#$7fff,d0
		rts

random_seed	ds.w	1
;--------------------------------------------------------------
			section	data
water_buffers:		dc.l	water_buffer_1
			dc.l	water_buffer_2		;+water_buffer_size

;--------------------------------------------------------------
o			set	-511
			rept	512
			dc.w	o
o			set	o+1
			endr
			dc.w	0,0
water_damping_table:
			dc.w	0,0
o			set	1
			rept	512
			dc.w	o
o			set	o+1
			endr


			dcb.w	8*32,0
water_colour_table:
o			set	0
			rept	31
			dcb.w	4,o
o			set	o+1
			endr
		
			dcb.w	8*32,31

water_buffer_size	equ	192*100*2

			ds.l	5000
water_buffer_1:		ds.b	water_buffer_size
water_buffer_2:		ds.b	water_buffer_size
			ds.l	5000

			ds.l	300
stack:
