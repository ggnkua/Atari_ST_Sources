* Sine Wave Wobbler
* V2
* by James Ingram, March 1994
* (slightly) optimised version!

	opt	o-,ow-
	opt	x+

spr_h	equ	75
spr_w	equ	160
words	equ	spr_w/16*4	; no of words in 1 line of sprite
spr_len	equ	(words+4)*2*spr_h	; length (in bytes) of sprite line + blank bit at right hand side


	include	\includes\macros.s

	move.l	#stack,a7
	
	super_on

	bsr	do_pre
	bsr	sine_longs
	bsr	do_screens

	bsr	initialise
	bsr	main_rout
	
	bsr	restore
	clr.w	-(a7)
	trap	#1


sine_longs:
* convert bytes in sine-wave data to longword offsets
* NOW, to save time on the routine.

	move.l	#sine_list,a0
	move.l	#offsets,a1

	move.w	#sine_len-1,d0
convert:

	move.b	(a0)+,d7
	ext.w	d7		; as a word
	
	moveq	#0,d6
	move.w	d7,d6

	and.w	#$f,d6		; d6 holds pixels in we need to go
	asr.w	#1,d7
	and.b	#$f8,d7		; equivalent to d7/16*8
				; don't believe me?
				; try it on paper!
	
* d7 now holds no of words we need to go from the centre of the screen
	ext.l	d7

	mulu	#spr_len,d6	; multiply pixel in by length of sprite

	move.l	d6,(a1)+
	move.l	d7,(a1)+

	dbra	d0,convert


	rts


do_screens:
* calculate screen addresses & wipe screens
	move.l	#screens,d0
	add.l	#255,d0
	clr.b	d0		; get screen of boundary

	move.l	d0,a0
	move.l	a0,screen1	; store 1st screen address
	lea	32000(a0),a0
	move.l	a0,screen2	; and 2nd screen address

	move.l	d0,a0
	move.w	#64000/4-1,d0
.wipe:
	clr.l	(a0)+		; ensure screens are blank
	dbra	d0,.wipe

	rts


do_pre:
* pre-shift the sprite

	move.l	#sprite,a0
	move.l	#sprites,a1
	moveq	#words,d0
	moveq	#spr_h,d1
	bsr	pre_shift

	rts

	include	includes\pre_shft.s


main_rout:
	move.l	#offsets,sine


	move.l	$70.w,old_70
	move.l	#my_70,$70.w

.loop:
	bsr	inp
	move.l	old_70,$70.w

rts:
	rts

my_70:
	movem.l	d0-7/a0-6,-(a7)

	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240.w

	move.l	#screen1,a0
	move.l	(a0),d0

* swap screen addresses so I use the other screen next time

	move.l	4(a0),d1
	move.l	d1,(a0)
	move.l	d0,4(a0)

* keep addr of screen for later... but a bit to the right
	move.l	d0,a6
	lea	40(a6),a6


* put in addr of screen I am DOING!
	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...
	

* pause to let the red band come down
	move.w	#6000,d0
.wait:
	dbra	d0,.wait

* now comes the part about putting the sprite on the screen...

	move.w	#$700,$ffff8240.w

* first we have to get the next byte from the position list.
	move.l	sine,a0		; get addr in list
	addq.l	#8,sine		; go from next position next time..


	move.l	#in_sine,a1
	addq.w	#1,(a1)		; 1 more into list
	cmp.w	#sine_len,(a1)	; at end?
	bne.s	.not_end	; if not, branch away

	clr.w	(a1)		; else go back to start
	move.l	#offsets,a0
	move.l	a0,sine

.not_end:


* a0 will hold the positions of each line of the sprite
	moveq	#0,d1		; this will be the line offset

	move.w	#spr_h-1,d0	; do all lines
line_loop:
	move.l	(a0)+,d6	; get position as LW offset
	move.l	(a0)+,d7	; and offset on screen


	move.l	a6,a5		; copy screen address
	add.l	d7,a5		; move to correct place on screen

	move.l	#sprites,a4	; get start of sprites
	add.l	d6,a4		; and get addr of sprite we want...
	add.l	d1,a4		; and the correct line...


* now we have to slap in an entire line from this sprite...
* but blank out to the left and the right

	clr.l	-8(a5)
	clr.l	-4(a5)


	movem.l	(a4)+,d2-7/a1-3
	movem.l	d2-7/a1-3,(a5)
	
	movem.l	(a4)+,d2-7/a1-3
	movem.l	d2-7/a1-3,36(a5)

	movem.l	(a4)+,d2-5
	movem.l	d2-5,72(a5)


	clr.l	88(a5)
	clr.l	92(a5)

* we've done a whole line!

* goto next line on screen
	lea	160(a6),a6

* and next line in sprite
	add.l	#(words+4)*2,d1

	dbra	d0,line_loop	; loop back again...


	move.w	#0,$ffff8240.w

	movem.l	(a7)+,d0-7/a0-6
	rte



	include	\includes\init.s
	include	\includes\misc.s


* now my sprites and stuff...

sprite	incbin	\includes\sprite.dat

my_pal	incbin	\includes\spr_pal.dat


* the SINE list...
sine_list
	ds.b	75
	incbin	\includes\wave_2.dat
sine_len	equ	*-sine_list


	even

in_sine	dc.w	0

	section	bss


sprites:
	ds.w	words*spr_h*16	; sprites
	ds.b	spr_h*8*16	; blanks at right

old_70	ds.l	1
sine	ds.l	1

screen1	ds.l	1
screen2	ds.l	1


screens	ds.b	256
	ds.b	64000

offsets	ds.l	sine_len*2
	ds.l	spr_h*2

	ds.b	5000
stack: