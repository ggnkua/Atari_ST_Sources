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


		;bsr	clearscreen
		move.w	#$1000,d0
		bsr	main_loop
		rts

main_loop:
		move.l	d0,-(a7)

		move.l	(a7)+,d0
repeat:
		move.w	#100,d0
		subq.w	#4,d0
.main_loop
		move.w	d0,-(a7)
		bsr	create_frame
		move.w	(a7)+,d0
		dbf	d0,.main_loop
		bra	repeat
		rts



create_frame:
		bsr	screen_swap
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



;--------------------------------------------------------------


;--------------------------------------------------------------
;--------------------------------------------------------------

			ds.l	300
stack

