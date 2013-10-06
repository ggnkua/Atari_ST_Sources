* No top or bottom border
* with a scroller in the bottom border!
* by James Ingram, March 1994

*	opt	x+
	opt	o-,ow-

no_of_screens	equ	2
b_lines	equ	228


	include	\includes\macros.s


* load in font and picture from disk!
	bsr	load_all

* get screen addresses
	move.l	#scrn,d0
	add.l	#255,d0
	clr.b	d0

	move.l	#screens,a0
	move.l	a0,a1

	moveq	#no_of_screens-1,d7
s:
	move.l	d0,(a0)+
	add.l	#42240,d0
	
	dbra	d7,s

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)	; copy last 2 screens to start of list...



* now copy the picture onto each screen in turn...
	moveq	#no_of_screens-1,d7

	move.l	#screens,a0

.all:
	move.l	(a0)+,a2
	move.l	#pic+34,a1
	move.w	#32000/4-1,d6
.pic:
	move.l	(a1)+,(a2)+
	dbra	d6,.pic

	dbra	d7,.all


	super_on
	c_off
	bsr	initialise
	keep_timers

* set up timer b
	clr.b	b_control.w	; timer B off

	move.l	#my_120,$120.w	; routine address in
	
* set timer B mask to on
	bset.b	#0,mask_a.w
	bset.b	#0,enable_a.w
* VBL will always initialise the timer B routine.


	bsr	main
	

	restore_timers
	bsr	restore
	c_on
	super_off

	clr.w	-(a7)
	trap	#1


load_all:
* load in font & pic...

	move.l	#32034,d0
	move.l	#pic,a1
	move.l	#pic_name,a0
	bsr	load_file

	move.l	#30720,d0
	move.l	#font,a1
	move.l	#font_name,a0
	bsr	load_file
	rts


main:
	calc_chars

	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	
	bsr	inp
	
	move.l	(a7)+,$70
	rts


my_70:
* interrupts off
	move.w	sr,-(a7)
	or.w	#$0700,sr

	movem.l	d0-7/a0-6,-(a7)

* get screen address of screen to work on
* and screen which was last...

	move.l	#screens,a0
	moveq	#0,d0
	move.w	screen_no,d0
	
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a6		; screen to work on
	move.l	-8(a0,d0.w),a5		; 2 screens back...

	move.l	a6,d0

	clr.b	$ffff820d.w	; this clears the STe extra byte
				; which otherwise could cause the
				; screen to look very odd on STes
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w	; slap the screen address in!
				; only those bytes are needed...

* slap the palette in...
	movem.l	pic+2,d0-7
	movem.l	d0-7,$ffff8240.w


* move screen addresses to bottom
	add.l	#32000+(160*32)+8,a5	; but 1 word to right for this one!
	add.l	#32000+(160*32),a6

coun	set	0

	rept	71

	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun(a6)

coun	set	coun+52
	endr

* done 3692 bytes...

	movem.l	(a5)+,d0-7/a0-3
	movem.l	d0-7/a0-3,coun(a6)

coun	set	coun+48

* moved 3740 bytes so far...

* into 60 Hz... dead on schedule!
	
	eor.b	#2,$ffff820a.w

	rept	8
	nop
	endr

* back into 50 Hz
	eor.b	#2,$ffff820a.w

	move.w	#$f00,$ffff8240.w

* now set up timer B to do the bottom border

	clr.b	b_control.w		; timer B off!
	move.b	#b_lines,b_data.w	; counter in
	move.b	#8,b_control.w		; timer B on!

* now do the other 1380 bytes of scroll line!

* coun has retained its value from above!

	rept	26
	movem.l	(a5)+,d0-7/a0-4
	movem.l	d0-7/a0-4,coun(a6)

coun	set	coun+52
	endr

* 28 bytes left!
	movem.l	(a5)+,d0-6
	movem.l	d0-6,coun(a6)

* now put in the word at the right of the screen...
* values in font_counter are:
*	3 = do 1st & 2nd byte
*	2 = do 2nd and 3rd byte
*	1 = do 3rd and 4th byte
*	0 = do 4th byte and one new one!

* but first, go to the right!!!
	lea	160-8(a6),a0

	move.l	font_bit,a1

	move.w	font_counter,d0
	dbra	d0,not_4_1

* first, put in the 4th byte of the old char..

	lea	4*32*3(a1),a1	; goto 4th byte data

	put1


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


* If I _REALLY_ wanted to push processor time, I could replace
* this next small piece of code, by pre-calculating
* the end results of all message bytes.
* That is, I could go throught the message when initialising,
* subtract " " and multiply by 4.  I could then just lift out the offset
* which is required.  But since these 3 lines take only 16 cycles, 
* is it really worth it?

	sub.b	#" ",d0
	add.w	d0,d0
	add.w	d0,d0		; d0 is LW pointer

	move.l	#chars,a2
	move.l	(a2,d0.w),a1	; got address of char!

* a1 holds addr of the char I want!
* Finally!

* so now I have the address, keep it for next time.  I no longer need
* a buffer.. I can read from the font each time.

	move.l	a1,font_bit

* now put in the 1st byte of this char.

	put2


* finally, alter the counter, so we don't come back here
* again for another 4 times!

	move.w	#3,font_counter
	bra	dun_right


not_4_1:
	dbra	d0,not_3_4
* do 3rd and 4th bytes of char!

	lea	4*32*2(a1),a1	; goto 3rd byte data

	put1
	put2

	sub.w	#1,font_counter
	bra	dun_right


not_3_4:
	dbra	d0,not_2_3
	
* do 2nd and 3rd bytes of char in font!

	lea	4*32(a1),a1	; go to 2nd byte data

	put1
	put2

	sub.w	#1,font_counter

	bra	dun_right



not_2_3:
* do 1st and 2nd!!!

	put1
	put2

	sub.w	#1,font_counter



dun_right:
	move.l	#screen_no,a0	; get screen counter address

	addq.w	#1,(a0)		; go to next screen

	cmp.w	#no_of_screens,(a0)
	bne.s	.not_end	; branch if not done last one

	clr.w	(a0)		; back to first one

.not_end:


	clr.w	$ffff8240.w

	movem.l	(a7)+,d0-7/a0-6

	move.w	(a7)+,sr

	rte


my_120:
* I arrive here somewhere in the middle of the bottom line!

	movem.l	d0-7/a0,-(a7)

	move.w	#b_data,a0	; get timer B counter address

	move.b	(a0),d0		; get count value
.pause:
	cmp.b	(a0),d0		; wait for it to change
	beq.s	.pause		; (EXACTLY on next line now!)


* into 60 Hz
	eor.b	#2,$ffff820a.w

	rept	15
	nop
	endr

* back into 50 Hz
	eor.b	#2,$ffff820a.w


* palette for bottom of screen
	movem.l	font_pal,d0-7
	movem.l	d0-7,$ffff8240.w


	movem.l	(a7)+,d0-7/a0
	bclr	#0,$fffffa0f.w
	rte

screen_no	dc.w	0

	include	\includes\load.s
	include	\includes\misc.s
	include	\includes\init.s

	section	data

font_pal	incbin	includes\font_pal.dat

font_counter	dc.w	0
font_bit	dc.l	font
message_addr	dc.l	message

message:
	dc.b	"SCROLLING MESSAGE IN THE BOTTOM BORDER... EASY, HUH?   "
	dc.b	0

pic_name	dc.b	"\includes\pic.pi1",0
font_name	dc.b	"\includes\font.dat",0
	even


	section	bss

	old

chars	ds.l	60		; 60 chars in font - need address for each!


	ds.l	1
	ds.l	1
screens	ds.l	no_of_screens+1


scrn:
	ds.b	256		; STFM byte boundary

	rept	no_of_screens
	ds.b	32*160
	ds.b	32000
	ds.b	32*160
	endr



pic	ds.b	32034
font	ds.b	30720



