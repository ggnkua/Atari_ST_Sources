* FASTEST scroller routine (optimised)
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
	move.l	#font,font_bit	; start with address of a space!

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
* get addresss of all chars to be printed...

	move.l	#font,d0	; 1st char address
	move.l	#chars,a0	; address of list
	moveq	#60-1,d1	; do 60 chars

.loop:
	move.l	d0,(a0)+	; put address in list
	add.l	#512,d0		; next address
	dbra	d1,.loop



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
	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240


* I have to get the screen address to display.
* this is the screen I am WORKING on
* as it won't change till next time!

	moveq	#0,d1
	move.w	screen_no,d1
	add.w	d1,d1
	add.w	d1,d1		; multiply by 4

	move.l	#screens,a6	; address of list of screens
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
	

* pause for a bit... to allow you to see whole of red line...
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

* no line loop - do ALL lines in code - thus we save time
* by not looping back all the time!

	moveq	#16,d7		; set up add for going past columns not scrolled

c	set	0

	rept	32

	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,c(a1)		; do 12 x 4 = 48 bytes

	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,c+48(a1)	; now done 96 bytes

	movem.l	(a0)+,d0-6/a2-6
	movem.l	d0-6/a2-6,c+96(a1)	; now done 144 bytes


* we skip past the last word on screen
* because it drops off anyway!
	add.l	d7,a0		; go to next screen line, 1 word to right

c	set	c+160
	endr


* I have now shifted everything except the last word on the right
* of the new screen.  This is what has to be put in later.

	lea	144(a1),a0	; to last word on right.

* now I have to put in the last word on the right.
* this might all come from one char.
* Or we might be doing the last byte of a char
* and the first byte of the next one.


* set up a macro to prevent re-typing everything every time!

putter	macro
c	set	\1

	movem.l	(a1)+,d0-7/a2-5
	movep.l	d0,c(a0)
	movep.l	d1,c+160(a0)
	movep.l	d2,c+320(a0)
	movep.l	d3,c+480(a0)
	movep.l	d4,c+640(a0)
	movep.l	d5,c+800(a0)
	movep.l	d6,c+960(a0)
	movep.l	d7,c+1120(a0)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

	movep.l	d2,c+1280(a0)
	movep.l	d3,c+1440(a0)
	movep.l	d4,c+1600(a0)
	movep.l	d5,c+1760(a0)

c	set	c+1920

* should use REPT here! But when I do, it messes the whole macro up!
* Why?  Ask HiSoft, I guess...

	movem.l	(a1)+,d0-7/a2-5
	movep.l	d0,c(a0)
	movep.l	d1,c+160(a0)
	movep.l	d2,c+320(a0)
	movep.l	d3,c+480(a0)
	movep.l	d4,c+640(a0)
	movep.l	d5,c+800(a0)
	movep.l	d6,c+960(a0)
	movep.l	d7,c+1120(a0)

	move.l	a2,d2
	move.l	a3,d3
	move.l	a4,d4
	move.l	a5,d5

	movep.l	d2,c+1280(a0)
	movep.l	d3,c+1440(a0)
	movep.l	d4,c+1600(a0)
	movep.l	d5,c+1760(a0)

c	set	c+1920


* done 24 LONGWORDs - just 8 more to do
	movem.l	(a1)+,d0-7
	movep.l	d0,c(a0)
	movep.l	d1,c+160(a0)
	movep.l	d2,c+320(a0)
	movep.l	d3,c+480(a0)
	movep.l	d4,c+640(a0)
	movep.l	d5,c+800(a0)
	movep.l	d6,c+960(a0)
	movep.l	d7,c+1120(a0)

	endm


* values in font_counter are:
*	3 = do 1st & 2nd byte
*	2 = do 2nd and 3rd byte
*	1 = do 3rd and 4th byte
*	0 = do 4th byte and one new one!

	move.l	font_bit,a1

	move.w	font_counter,d0
	dbra	d0,not_4_1

* first, put in the 4th byte of the old char..

	lea	4*32*3(a1),a1	; goto 4th byte data

	putter	0


* Now I have to get the next char in the font

	move.l	message_addr,a2	; get address in list
	moveq	#0,d0
	move.b	(a2)+,d0
	bne.s	.not_zed

* end of message!
	move.l	#message,a2
	move.b	(a2)+,d0

.not_zed:
	move.l	a2,message_addr


	sub.b	#" ",d0
	add.w	d0,d0
	add.w	d0,d0		; d0 is LW pointer

	move.l	#chars,a2
	move.l	(a2,d0.w),a1	; got address of char!

* a1 holds addr of the char I want!
* Finally!

* so now I have the address.  I no longer need
* a buffer.. I can read from the font each time.

	move.l	a1,font_bit

* now put in the 1st byte of this char.


	putter	1


* finally, alter the counter, so we don't come back here
* again for another 4 times!

	move.w	#3,font_counter
	bra	dun_right


not_4_1:
	dbra	d0,not_3_4
* do 3rd and 4th bytes of char!

	lea	4*32*2(a1),a1	; goto 3rd byte data
	bra	do_right



not_3_4:
	dbra	d0,not_2_3
	
* do 2nd and 3rd bytes of char in font!

	lea	4*32(a1),a1	; go to 2nd byte data

not_2_3:
* do 1st and 2nd!!!

do_right:
	putter	0
	putter	1

	subq.w	#1,font_counter

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

font	incbin	\includes\font.dat
my_pal	incbin	\includes\font_pal.dat


message:
	dc.b	'THIS IS THE "NEW GENERATION" SCROLLER AS OPTIMISED AS I CAN GET IT.  CAN YOU DO BETTER???  (WITHOUT USING THE BLITTER!)  IF SO, LET ME KNOW!  '
	dc.b	"OPTIMISATIONS INCLUDE:  MOVING 152 BYTES PER LINE (16 BYTES GO OFF AT THE LEFT - NO NEED TO MOVE THEM!)          ...        GETTING MORE FONT DATA IN ONE GO - JUST 3 MOVEMS NEEDED NOW TO DO 1 COLUMN IN THE FONT    ...      "
	dc.b	0
	even


font_counter	dc.w	0

message_addr	dc.l	message


	section	bss

chars	ds.l	60		; 60 chars in font - need address for each!



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

