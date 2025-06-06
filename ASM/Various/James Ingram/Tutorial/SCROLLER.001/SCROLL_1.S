* SLOW scroller routine
* by James Ingram, Feb 1994

	opt	o-,ow-		; optimise off
	opt	x+		; labels on

	move.l	#stack,a7


* now clear the screens!
	move.l	#scrn,a0
	move.w	#64512/4-1,d0

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
	
	move.l	d0,addr_1
	move.l	d0,last_screen

	add.l	#32000,d0
	move.l	d0,addr_2	; keep the 2 screen addresses
	move.l	d0,next_screen

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
	rts


my_70:
* this is my routine!!!!!
* to do all the stuff!!!!

	movem.l	d0-7/a0-6,-(a7)	; keep regs

* first, put my palette in!
	movem.l	font+2,d0-7
	movem.l	d0-7,$ffff8240


* next, scroll the entire top part of the screen along
* by 1 pixel...

* which screen did I do last???
	move.l	last_screen,a0

* and which one am I going to do now?
	move.l	next_screen,a1


* swap them over for next time
	move.l	a0,next_screen
	move.l	a1,last_screen

* Put the address of the screen I am doing
* into the screen address register.
* It will not be displayed until the next time around.


	move.l	a1,d0

	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...
	

* pause for a bit.. to let you see whole of red line
	move.w	#1000,d7
wait:
	nop
	nop
	dbra	d7,wait

	move.w	#$700,$ffff8240

* now.. the old screen is being displayed,
* so I have to draw the new screen.
*
* The first thing to do is to work out whether I have to
* get a new character from the font or not.


	sub.w	#1,font_counter		; font_counter starts at 0
	bpl	no_new_char	; take branch if >= 0

* font_counter is -1!  Get a new character from the font!
* but which one???

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
	move.l	#font+34,a2
	add.l	d0,a2
	add.l	d1,a2


* a0 holds addr of the char I want!
* Finally!

* put this char's data into a buffer
* we can rotate it in...

	move.l	#buffer,a3

	moveq	#32-1,d0	; do 32 lines
copy:
	movem.l	(a2),d1-4
	movem.l	d1-4,(a3)	; copy a whole line

	add.l	#160,a2		; next screen line
	add.l	#16,a3		; next bit of buffer
	dbra	d0,copy

* finally, alter the counter, so we don't come back here
* again for another 32 times!

	move.w	#31,font_counter

no_new_char:
* however we get here, we still have old screen in a0
* new screen in a1, and some stuff in the buffer!

* copy the old screen to the new screen
	move.l	a0,a2
	move.l	a1,a3

	move.w	#32*160/4-1,d0
.copy:
	move.l	(a2)+,(a3)+
	dbra	d0,.copy



* now our task is to rotate the top 32 lines of screen one pixel to the left.
* also, we have to slap in the character data sitting in the buffer.

	add.l	#152,a0
	add.l	#152,a1		; go to right hand side of screens

	move.l	#buffer,a2	; get ready with the buffer...

	moveq	#32-1,d1	; do 32 lines

line_loop:

	moveq	#4-1,d0		; do 4 planes...

plane_loop:
	roxl.w	8(a2)		; rotate left the right hand word of 1st plane
	roxl.w	(a2)		; and shift the bit into the lefthand word

	roxl	(a1)		; shift the screen to the left
	roxl	-8(a1)		; all the way along a plane!
	roxl	-16(a1)
	roxl	-24(a1)
	roxl	-32(a1)
	roxl	-40(a1)
	roxl	-48(a1)
	roxl	-56(a1)
	roxl	-64(a1)
	roxl	-72(a1)
	roxl	-80(a1)
	roxl	-88(a1)
	roxl	-96(a1)
	roxl	-104(a1)
	roxl	-112(a1)
	roxl	-120(a1)
	roxl	-128(a1)
	roxl	-136(a1)
	roxl	-144(a1)
	roxl	-152(a1)

	addq.l	#2,a1		; go to next colour plane
	addq.l	#2,a2		; and next plane in buffer
	dbra	d0,plane_loop

	add.l	#152,a1		; go to end of next line
	addq.l	#8,a2		; and next line in buffer
	dbra	d1,line_loop	; and loop back


	move.w	#0,$ffff8240

	movem.l	(a7)+,d0-7/a0-6
	rte


* include my routines...
	include	\includes\init.s



	section	data

font:
	incbin	\includes\font.pi1

message:
	dc.b	"VERY SLOW SCROLLER... ",0
	even

font_counter	dc.w	0

message_addr	dc.l	message


	section	bss

buffer	ds.b	32*16
* 32 lines * 16 bytes per line

last_screen	ds.l	1
next_screen	ds.l	1


old_70	ds.l	1

addr_1	ds.l	1
addr_2	ds.l	1

scrn:
	ds.b	512
screen1	ds.b	32000
screen2	ds.b	32000

	ds.b	5000
stack:

