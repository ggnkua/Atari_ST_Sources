* Move a big sprite around with a trail
* by James Ingram, May 1994


	opt	x+,o-,ow-

no_of_screens	equ	5

speed_x	equ	4
speed_y	equ	2

max_x	equ	320-160
max_y	equ	200-75

spr_h	equ	75
spr_w	equ	160
words	equ	spr_w/16*4	; no of words in 1 line of sprite
spr_len	equ	(words+4)*2*spr_h	; length (in bytes) of sprite line + blank bit at right hand side


	include	\includes\macros.s

	bsr	do_load

	super_on

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
	move.l	(a6),d0		; get screen number to display next (we will use it!)
	move.l	d0,a0

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

	move.w	spr_x,d0
	move.w	add_x,d1
	
	add.w	d1,d0

* is it still in range?
	bmi.s	change_x	; branch if negative co-ord

	cmp.w	#max_x,d0
	ble.s	n_c_x		; branch if less than maximum

change_x:
* change the addon value!
	not.w	d1
	addq.w	#1,d1	; invert the number.  neg -> pos or pos -> neg
	add.w	d1,d0	; take off what put it out of range
	add.w	d1,d0	; move in other direction

	move.w	d1,add_x	; keep number to add for next time

n_c_x:
* got a valid x co-ord!

	move.w	spr_y,d1
	move.w	add_y,d2
	
	add.w	d2,d1

* is it still in range?
	bmi.s	change_y	; branch if negative co-ord

	cmp.w	#max_y,d1
	ble.s	n_c_y		; branch if less than maximum

change_y:
* change the addon value!
	not.w	d2
	addq.w	#1,d2	; invert the number.  neg -> pos or pos -> neg
	add.w	d2,d1	; take off what put it out of range
	add.w	d2,d1	; move in other direction

	move.w	d2,add_y	; keep number to add for next time

n_c_y:
* got a valid y co-ord!

* x co-ord is in d0, y co-ord is in d1!
* a0 is still the screen we are going to use...

	move.w	d0,spr_x
	move.w	d1,spr_y

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


* a0 still holds screen address
* d0 still hold sprite number!
* get offset of correct sprite

	moveq	#0,d1
	move.w	d0,d1
* d1 is pixel offset!
* use it to get the correct mask LWs
	lsl.w	#3,d1
	move.l	#masks,a1
	add.l	d1,a1
	move.l	(a1)+,d1	; left hand mask
	move.l	(a1)+,d2	; right hand mask


	mulu	#6000+(8*spr_h),d0
	move.l	#pre_sprite,a1
	add.l	d0,a1		; got correct ball sprite


	moveq	#spr_h-1,d0
lines:
* do left hand side
	movem.l	(a0),d6-7	; get screen

* mask it
	and.l	d1,d6
	and.l	d1,d7

* OR in the sprite
	or.l	(a1)+,d6
	or.l	(a1)+,d7

* put it back into screen
	movem.l	d6-7,(a0)


* now do the main block... just slap it in!
* 72 bytes slapped straight in

	movem.l	(a1)+,d3-7/a2-6
	movem.l	d3-7/a2-6,8(a0)

* done 40... 32 left!
	movem.l	(a1)+,d3-7/a2-4
	movem.l	d3-7/a2-4,48(a0)

* now do the right hand side...
	movem.l	80(a0),d6-7	; get screen

	and.l	d2,d6
	and.l	d2,d7		; mask screen

* or in the sprite
	or.l	(a1)+,d6
	or.l	(a1)+,d7

* slap it onto screen
	movem.l	d6-7,80(a0)
	lea	160(a0),a0
	dbra	d0,lines


	move.w	(a7)+,$ffff8240.w
	movem.l	(a7)+,d0-7/a0-6

	rte


masks:
	dc.l	$00000000
	dc.l	$ffffffff

	dc.l	$80008000
	dc.l	$7fff7fff
	
	dc.l	$a000a000
	dc.l	$3fff3fff
	
	dc.l	$c000c000
	dc.l	$1fff1fff
	
	dc.l	$f000f000
	dc.l	$0fff0fff
	
	dc.l	$f800f800
	dc.l	$07ff07ff
	
	dc.l	$fa00fa00
	dc.l	$03ff03ff
	
	dc.l	$fc00fc00
	dc.l	$01ff01ff
	
	dc.l	$ff00ff00
	dc.l	$00ff00ff
	
	dc.l	$ff80ff80
	dc.l	$007f007f

	dc.l	$ffa0ffa0
	dc.l	$003f003f

	dc.l	$ffc0ffc0
	dc.l	$001f001f
	
	dc.l	$fff0fff0
	dc.l	$000f000f
	
	dc.l	$fff8fff8
	dc.l	$00070007
	
	dc.l	$fffafffa
	dc.l	$00030003
	
	dc.l	$fffcfffc
	dc.l	$00010001
	
	dc.l	$ffffffff
	dc.l	$00000000


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



do_pre:
* pre-shift sprite & mask

	move.l	#sprite,a0
	move.l	#pre_sprite,a1
	move.w	#words,d0
	move.w	#spr_h,d1
	bsr	pre_shift
	rts

do_load:
	move.l	#sprite_name,a0
	move.l	#sprite,a1
	move.l	#6000,d0
	bsr	load_file

	rts


	include	\includes\init.s
	include	\includes\pre_shft.s
	include	\includes\load.s


my_pal:
	incbin	\includes\spr_pal.dat

spr_x	dc.w	1
spr_y	dc.w	1

add_x	dc.w	speed_x
add_y	dc.w	speed_y


screen_no	dc.w	0

sprite_name	dc.b	"\includes\sprite.dat",0
	even

	section	bss

sprite	ds.b	6000

scrns:
	ds.b	256
	ds.b	32000*no_of_screens


	ds.l	2
screens	ds.l	no_of_screens


pre_sprite	ds.b	6000+(8*spr_h)*16

