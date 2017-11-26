* Sine Wave Wobbler
* V1
* by James Ingram, March 1994

	opt	o-,ow-
	opt	x+

spr_h	equ	75
spr_w	equ	160
words	equ	spr_w/16*4	; no of words in 1 line of sprite
spr_len	equ	(words+4)*2*spr_h	; length (in bytes) of sprite line + blank bit at right hand side


	include	\includes\macros.s

	move.l	#stack,a7
	
	super_on

	bsr	pre_shift
	bsr	do_screens

	bsr	initialise

	bsr	main_rout
	
	bsr	restore
	clr.w	-(a7)
	trap	#1

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


pre_shift:
* pre-shift the sprite

* I need to have 16 copies of the sprite in memory - one for each position
* it COULD be on a word.
* This is why my SPR_CONV program saved an extra word for each plane
* at the start of each line - we are going to shift the sprite 15 times
* to the left, and the final sprite will go from the left part of the
* first word.


* first, copy the old sprite to the first new sprite position
* but create a blank word at the right of each line...

	move.l	#sprites,a0
	move.l	#sprite,a1
	move.w	#spr_h-1,d0	; no of lines to do

.line:
	moveq	#words-1,d1	; no of words to do
.copy:
	move.w	(a1)+,(a0)+
	dbra	d1,.copy

	clr.l	(a0)+
	clr.l	(a0)+		; blank word on each plane!
	dbra	d0,.line


* now I am ready for the REAL pre-shifting code

* a0 points to the 1st word of the 2nd sprite now.
	move.l	#sprites,a1

	moveq	#15-1,d0	; do 15 shifts althogether
				; to make 16 sprites (1 unshifted)
sprite_loop:
* do an entire sprite...
	moveq	#spr_h-1,d1	; do all lines

sprite_line:
* do the line...
* first, copy the old line

	move.l	a0,a2		; keep addr of plane

	moveq	#words+4-1,d7
.copy:
	move.w	(a1)+,(a0)+
	dbra	d7,.copy


	moveq	#4-1,d2		; 4 planes to do!

plane_loop:
* shift the entire plane left by 1 bit...

* a whole lot of ROXR commands
* to do the plane by 1 bit.


	moveq	#0,d7
	addx.w	d7,d7		; clear the X flag

c	set	0

	rept	(words)/4+1	; do 1/4 of the words - just 1 plane

	roxr	c(a2)
c	set	c+8		; go to next plane back

	endr

* go to next plane
	addq.l	#2,a2
	dbra	d2,plane_loop

* a1 points to next line of sprite already.
* a0 points to next line of new sprite.

	dbra	d1,sprite_line	; go back & do next line

* both a0 and a1 are in the correct places.
* a0 points to next sprite to rotate,
* a1 points to the one we just did
	dbra	d0,sprite_loop

	rts



main_rout:
	move.l	#sine_list,sine


	move.l	$70.w,old_70
	move.l	#my_70,$70.w
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
	addq.l	#1,sine		; go from next position next time..

	move.l	#in_sine,a1

	addq.w	#1,(a1)		; 1 more into list
	cmp.w	#sine_len,(a1)	; at end?
	bne.s	.not_end	; if not, branch away

	clr.w	(a1)		; else go back to start
	move.l	#sine_list,a0
	move.l	a0,sine

.not_end:

* a0 will hold the positions of each line of the sprite
	moveq	#0,d1		; this will be the line offset

	move.w	#spr_h-1,d0	; do all lines
line_loop:
	move.b	(a0)+,d7	; get position as byte

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

	move.l	a6,a5		; copy screen address
	add.l	d7,a5		; move to correct place on screen

	mulu	#spr_len,d6	; multiply pixel in by length of sprite
	move.l	#sprites,a4	; get start of sprites
	add.l	d6,a4		; and get addr of sprite we want...
	add.l	d1,a4		; and the correct line...

* now we have to slap in an entire line from this sprite...
* but blank out to the left and the right

	clr.l	-8(a5)
	clr.l	-4(a5)

	moveq	#(words+4)/4-1,d6
.line:
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	dbra	d6,.line

	clr.l	(a5)+
	clr.l	(a5)+

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
	incbin	\includes\wave_1.dat
sine_len	equ	*-sine_list

* after the list, we have 0s for every line of the sprite.
* so when we get to the end of the line, they are all on 0!
	ds.b	spr_h

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


	ds.b	5000
stack: