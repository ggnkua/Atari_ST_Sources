* Move a sprite around leaving a trail
* (exactly the same as 1_SPRITE, but with the restoring screen bits taken out!)
* by James Ingram, May 1994


	opt	o-,ow-

no_of_screens	equ	4

speed_x	equ	4
speed_y	equ	2

max_x	equ	320-32
max_y	equ	200-31

	include	\includes\macros.s

	super_on

	bsr	do_load
	bsr	do_pre
	bsr	initialise
	bsr	init_screens

	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240.w
	
	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	move.l	(a7)+,$70.w

	
	bsr	restore

	super_off
	clr.w	-(a7)
	trap	#1


my_70:
* the sprite routine!
	movem.l	d0-7/a0-6,-(a7)
	move.w	$ffff8240.w,-(a7)
	move.w	#$f00,$ffff8240.w

* get screen address we are going to work on...
	moveq	#0,d0
	move.w	screen_no,d0
	move.w	d0,d1

	add.w	d0,d0
	add.w	d0,d0

	addq.w	#1,d1		; next screen
	cmp.w	#no_of_screens,d1
	bne.s	.not_back

* first screen again!
	moveq	#0,d1

.not_back:
	move.w	d1,screen_no

	move.l	#screens,a6
	add.l	d0,a6
	move.l	(a6),d0		; get screen number to display next
	move.l	-4(a6),a0	; get last screen address (which we will use)
	move.l	-8(a6),a2	; and 2nd last (which we will repair)


* put screen address into display register...
	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...

	moveq	#0,d0
	moveq	#0,d1


* get next co-ords from list
	move.l	pointer,a1
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	move.b	(a1)+,d1

	subq.w	#1,coord_count
	bne.s	.not_start

	move.l	#coords,a1
.not_start:
	move.l	a1,pointer


* x co-ord is in d0, y co-ord is in d1!
* a0 is still the screen we are going to use...

* use these values to get:
*	correct screen address
*	sprite number to use

	mulu	#160,d1		; get line offset
	add.l	d1,a0		; add to screen address

	move.w	d0,d1
	and.w	#$f,d0		; sprite number to use

	lsr.w	#1,d1
	and.w	#$fff8,d1	; word offset
	add.l	d1,a0		; a0 now holds correct address!



* a0 holds screen address
* d0 holds sprite number!
* get offset of correct sprite

	move.w	d0,d1

	mulu	#ball_len+(8*31),d0
	move.l	#pre_ball,a1
	add.l	d0,a1		; got correct ball sprite

	mulu	#mask_len+(2*31),d1
	move.l	#pre_mask,a2
	add.l	d1,a2		; got correct mask


* now put the sprite onto the screen!!!
	moveq	#31-1,d0	; number of lines
.lines:
	moveq	#3-1,d7		; number of word-groups
.words:
	move.w	(a2)+,d2	; get mask word
	move.w	d2,d1
	swap	d1
	move.w	d2,d1		; as a LW

	movem.l	(a1)+,d2-3	; get 4 words of sprite

	movem.l	(a0),d4-5	; get current screen data
	and.l	d1,d4
	and.l	d1,d5		; make sprite-shaped hole
	
	or.l	d2,d4
	or.l	d3,d5		; put the sprite into the hole
	
	movem.l	d4-5,(a0)
	addq.l	#8,a0

	dbra	d7,.words

	lea	160-24(a0),a0	; next line on screen
	dbra	d0,.lines

	move.w	(a7)+,$ffff8240.w
	movem.l	(a7)+,d0-7/a0-6

	rte


init_screens:
	move.l	#scrns,d0
	add.l	#255,d0
	clr.b	d0

	move.l	#screens,a0
	move.l	a0,a1

	moveq	#no_of_screens-1,d1
.loop:
	move.l	d0,(a0)+
	add.l	#32000,d0
	dbra	d1,.loop

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)


	rts

do_load:
* load co-ords!
	lea	c_name(pc),a0
	lea	coords(pc),a1
	move.l	#c_len*3,d0
	bsr	load_file
	rts

	include	\includes\load.s



do_pre:
* pre-shift sprite & mask

	move.l	#ball,a0
	move.l	#pre_ball,a1
	moveq	#8,d0
	moveq	#31,d1
	bsr	pre_shift


	move.l	#mask,a0
	move.l	#pre_mask,a1
	moveq	#2,d0
	moveq	#31,d1
	bsr	pre_shift_mask


	rts



	include	\includes\init.s
	include	\includes\pre_shft.s


ball:
	incbin	\includes\ball.dat
ball_len	equ	*-ball

mask:
	incbin	\includes\ballmas2.dat
mask_len	equ	*-mask

my_pal:
	incbin	\includes\spr_pal.dat


c_len	equ	11364/3

coord_count	dc.w	c_len
pointer	dc.l	coords

screen_no	dc.w	0

c_name:	dc.b	"oval.dat",0
	even

	section	bss

coords:	ds.b	c_len*3
	even


scrns:
	ds.b	256
	ds.b	32000*no_of_screens


	ds.l	2
screens	ds.l	no_of_screens



pre_ball	ds.b	(ball_len+(8*31))*16
pre_mask	ds.b	(mask_len+(2*32))*16



