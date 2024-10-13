* FASTEST scroller routine
* by James Ingram, Feb 1994

	opt	o-,ow-		; optimise off
	opt	x+		; labels on


* minimum value is 2!
no_of_screens	equ	2


	move.l	#stack,a7


* now clear the screens!
	move.l	#scrn,a0
	move.w	#((no_of_screens*32000)+256)/4-1,d0

clr:
	clr.l	(a0)+
	dbra	d0,clr

* now we have to calculate the address of the screens we will
* be using.
* This is because the STFM will only allow screens on a 256 byte
* address (ie $70000, $70100...   $70004 is RIGHT OUT)
* we cannot guarantee WHERE our screens will be in memory

	move.l	#screen1,d0	; get the address of the 1st screen
	clr.b	d0		; and it is now slightly less
				; but on the boundary!

	move.l	#screens,a0	

	moveq	#no_of_screens-1,d1
.loop:
	move.l	d0,(a0)+	; keep screen address
	add.l	#32000,d0	; go to next screen
	dbra	d1,.loop

* now put in the last 2 screen addresses at the start of the list...
	move.l	#last_screens,a1
	move.l	-8(a0),(a1)+
	move.l	-4(a0),(a1)+


	clr.w	screen_no	; start on screen 0!
	move.l	#font+34,font_bit	; start with address of a space!

* into SUPER mode
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,-(a7)	; keep value returned

* now I will initialise the graphics...
	bsr	initialise

* and now, the routine itself...
	bsr	main_rout

* restore screen to how it was
	bsr	restore

* out of SUPER mode
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

* and exit...
	clr.w	-(a7)
	trap	#1


main_rout:

* keep old interupt address
	move.l	$70,old_70

* and install mine...
	move.l	#my_70,$70


* now just wait for a keypress
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7


* and de-stall my routine
	move.l	old_70,$70

rts:
	rts


my_70:
* this is my routine!!!!!
* to do all the stuff!!!!

	movem.l	d0-7/a0-6,-(a7)	; keep regs


* first, put my palette in!
	movem.l	font+2,d0-7
	movem.l	d0-7,$ffff8240

* I have to get the screen address to display.
* this is the screen I am WORKING on
* as it won't change till next time!

	moveq	#0,d1
	move.w	screen_no,d1
	add.w	d1,d1
	add.w	d1,d1		; multiply by 4

	move.l	#screens,a6	; get list of screen addresses
	add.l	d1,a6		; go to correct screen address
	move.l	(a6),a5		; and put it into a1

* put in screen address to screen register

	move.l	a5,d0
	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...

* pause for a bit.. to let you see whole of red line
	move.w	#3000,d7
wait:
	nop
	nop
	dbra	d7,wait

	move.w	#$700,$ffff8240


* now.. the old screen is being displayed,
* so I have to draw the new screen.
*
* First, copy everything from 2 screens ago, but put it 1 word to the left

	move.l	-8(a6),a0	; 2 screens back
	move.l	a5,a1

* a0 = 2 screens ago
* a1 = screen now

	addq.l	#8,a0		; go 1 word to the right on the old screen

	moveq	#32-1,d7	; do all lines

* keep screen address for putting in new char later
	pea	(a1)

line_loop:
	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,(a1)		; do 12 x 4 = 48 bytes

	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,48(a1)	; now done 96 bytes

	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,96(a1)	; now done 144 bytes


* I have now shifted everything except the last word on the right
* of the new screen.  This is what has to be put in later.

	add.l	#160,a1
	add.l	#160-144,a0	; both new lines

	dbra	d7,line_loop

	move.l	(a7)+,a0	; screen address back again
	add.l	#144,a0		; to last word on right.

* now I have to put in the last word on the right.
* this might all come from the font data.
* Or we might be doing the last byte of a char
* and the first byte of the next one.

* values in font_counter are:
*	3 = do 1st & 2nd byte
*	2 = do 2nd and 3rd byte
*	1 = do 3rd and 4th byte
*	0 = do 4th byte and one new one!

	move.l	font_bit,a1

	move.w	font_counter,d0
	beq	do_4_1

	subq.w	#1,d0
	beq	do_3_4
	
	subq.w	#1,d0
	beq	do_2_3

* do 1st and 2nd!!!

	moveq	#32-1,d1

.do_right:
	movep.l	(a1),d0
	movep.l	d0,(a0)
	
	movep.l	1(a1),d0
	movep.l	d0,1(a0)

	add.l	#160,a0		; next screen line
	add.l	#160,a1		; next line in font
	dbra	d1,.do_right

	sub.w	#1,font_counter

	bra	dun_right

do_2_3:
* do 2nd and 3rd bytes of char in font!

	moveq	#32-1,d1

.do_right:

	movep.l	1(a1),d0
	movep.l	d0,(a0)

	movep.l	8(a1),d0
	movep.l	d0,1(a0)

	add.l	#160,a0
	add.l	#160,a1
	dbra	d1,.do_right

	sub.w	#1,font_counter

	bra	dun_right


do_3_4:
* do 3rd and 4th bytes of char!

	moveq	#32-1,d1

.do_right:

	movep.l	8(a1),d0
	movep.l	d0,(a0)

	movep.l	9(a1),d0
	movep.l	d0,1(a0)

	add.l	#160,a0
	add.l	#160,a1
	dbra	d1,.do_right

	sub.w	#1,font_counter

	bra	dun_right


do_4_1:
* first, put in the 4th byte of the old char..

	move.l	a0,a2

	moveq	#32-1,d1

.do_1st:
	movep.l	9(a1),d0
	movep.l	d0,(a2)

	add.l	#160,a2
	add.l	#160,a1
	dbra	d1,.do_1st

* Now I have to get the next char in the font

	move.l	message_addr,a2		; get address of next char to use

	moveq	#0,d0		; clear d0
	move.b	(a2)+,d0	; get the next char
	bne	not_zero	; branch if it isn't zero

* I have got a zero... end of message!
	move.l	#message,a2
	move.b	(a2)+,d0

not_zero:
* Ok.. now I have definately got a byte from the message.
	move.l	a2,message_addr


	sub.b	#" ",d0		; space is at position 0 in my font
				; so if I had a space, I now have 0!
	
* I have 10 chars per line in my font... so get the line number...
	divu	#10,d0

	moveq	#0,d1		; start with 0
	swap	d0		; get remainder from division
	move.w	d0,d1		; keep it - it's the char number on the line
	clr.w	d0		; now get rid of it
	swap	d0		; and swap back so we're looking at line no

* now I multiply the line number by the size of a line
	mulu	#32*160,d0	; (32 lines all of 160 bytes)

* and multiply the char along by the width of a char
	mulu	#16,d1


* now add these values to the addr of the font
	move.l	#font+34,a1
	add.l	d0,a1
	add.l	d1,a1


* a0 holds addr of the char I want!
* Finally!

* so now I have the address, keep it for next time.  I no longer need
* a buffer.. I can read from the font each time.

	move.l	a1,font_bit

* now put in the 1st byte of this char.
	moveq	#32-1,d1

.do_1st:
	movep.l	(a1),d0
	movep.l	d0,1(a0)

	add.l	#160,a0
	add.l	#160,a1
	dbra	d1,.do_1st

* finally, alter the counter, so we don't come back here
* again for another 4 times!

	move.w	#3,font_counter

dun_right:
	move.l	#screen_no,a0	; get screen counter address

	addq.w	#1,(a0)		; go to next screen

	cmp.w	#no_of_screens,(a0)
	bne.s	.not_end	; branch if not done last one

	clr.w	(a0)		; back to first one

.not_end:
	move.w	#0,$ffff8240

	movem.l	(a7)+,d0-7/a0-6
	rte


* include my routines...
	include	\includes\init.s



	section	data

font:
	incbin	\includes\font.pi1

message:
	dc.b	'THIS IS MY "NEW GENERATION" SCROLLER, USING MOVEMS!  CAN ONLY BE USED WITH A MINIMUM OF 2 SCREENS THOUGH...    '
	dc.b	0
	even

font_counter	dc.w	0

message_addr	dc.l	message


	section	bss

buffer	ds.b	32*16
* 32 lines * 16 bytes per line

font_bit	ds.l	1

old_70	ds.l	1

screen_no	ds.w	1

last_screens	ds.l	2
screens	ds.l	no_of_screens



scrn:
	ds.b	512
screen1	ds.b	no_of_screens*32000

	ds.b	5000
stack:

