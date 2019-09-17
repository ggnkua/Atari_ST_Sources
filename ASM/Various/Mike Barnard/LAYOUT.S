*
* Written with DevpacST 2, Medium rez, tabs set to 8.
*
* By, Mike Barnard, December 1st to 4th 1993. 
*
* This program is not about 'how to display a picture on-screen', although
* that's what it does. It's about how I like to write and comment my
* source code so a stranger can read and understand it. So many listings
* I've seen have been continuous. Line after line of mnemonics, operands
* and data. No breaks, separations or logical structure. Trying to find
* out how the author was thinking takes hours of reading each line,
* deciding what it does, commenting it myself, finding where the routines
* start and end, inserting blank lines for clarity... what a time waste.
*
* I'm nowhere near good, I'm a learner. This is just MY idea of how code
* CAN be commented. Except for one thing. A neighbour of mine once told
* me about the 'Rule of Seven'. It basically means that when writing code,
* no single chunk of code should be longer than 7 lines if you can help
* it. It's not absolute! In programming, what's right is what works. But
* it's true that the human brain finds it difficult to digest more than
* that amount of information at a time. (If you can read a whole 
* listing at a glance then lucky you, but I can't, and I don't know of
* anyone else who can...).
*
* So anyway. This little program loads a Degas picture file from disk
* and displays it to the standard screen memory. Then it looks for the
* escape key to be pressed and returns to the desktop. Remember, It's not
* WHAT it does, just how I've listed the source. Adding comments may
* swell the source file, but the end program won't be hurt for it. I'm
* just learning how to make this machine do what I want it to, and I TRY
* to understand other peoples listings when they release them. Please try
* to make them readable. For others, and for yourself. Thanks.
*
* Oh, you'll have to supply a degas low res picture yourself. I don't
* want to waste too much disk space.
*
* Any comments, good, bad or indifferent...
*
* Mike Barnard
* 52 Westbourne Avenue
* Worthing
* West Sussex
* BN14 8DF
*
* (NO CALLING AT THE DOOR! Please.)
*
* I hope my ideas are useful.
* 
*************************************************************************
*									*
*				LAYOUT.S				*
*									*
*************************************************************************

		TEXT
		
start		jsr	init	goto the initialise routine
		jsr	loadit	get the picture from the disk
keyloop		jsr	getkey	if key pressed, get it's scancode
		jsr	whatkey	find if it's <esc>
		bra	keyloop	if not go back and look again...			

*************************************************************************

* IS THE SCANCODE THE <ESC> KEY?

whatkey

	move.w	scancode,d0	put current code into d0
	cmpi.w	#1,d0		is it 1? (<ESCAPE> key)
	beq	exit		yes, branch
	
	rts			no, go back
	
*************************************************************************

* RESTORE AND RETURN TO DESKTOP

exit

* restore screen resolution
	
	move.w	oldrez,-(sp)	screen rez required. (0=low, 1=med.)
	move.l	#-1,-(sp)	negative number, no change to addresses
	move.l	#-1,-(sp)	negative number, no change to addresses
	move.w	#5,-(sp)	function number
	trap	#14		XBIOS 14 - SETSCREEN
	add.l	#12,sp		tidy

* restore palette

	move.l	#oldpal,-(sp)		palette to load
	move.w	#6,-(sp)		function number
	trap	#14			XBIOS 14 - SETPALETTE
	addq.l	#6,sp 			tidy
	
* exit to desktop

	move.w	#0,-(sp)	function number
	trap	#1		byeeeeeeee.....

*************************************************************************

* HAS A KEY BEEN PRESSED?

getkey

	movem.l	d0-d7/a0-a6,-(sp)	Save registers
	move.w	#0,scancode		Ensure null return unless key found
	
* has a key been pressed?

	move.w	#$0b,-(sp)	GEMDOS $0B - KEYBOARD BUFFER STATUS?
	trap	#1		Result returned in d0.
	addq.l	#2,sp		tidy

	tst.w	d0		d0.w=0, no keys pressed, -1 = yes
	beq	.end		no keypresses in buffer, so return
	
* yes, found a keypress. Now get it's scancode

	move.w	#$08,-(sp)	GEMDOS 8 - GET A KEYPRESS
	trap	#1
	addq.l	#2,sp

	swap	d0		put scancode into low word
	move.w	d0,scancode	save the scancode for later

.end	
	movem.l	(sp)+,d0-d7/a0-a6	restore registers

	rts

*************************************************************************

* LOAD A DEGAS PICTURE FROM A DISK AND DISPLAY

loadit

* open the file, store the handle

	move.w	#0,-(sp)	file attribute (0=nornal, read\write)
	move.l	#filename,-(sp)	address of file name string
	move.w	#61,-(sp)	function number
	trap	#1		GEMDOS 61 - OPEN A FILE
	addq.l	#8,sp		tidy
	
	tst	d0		check for error
	bmi	file_error	yes, branch

	move.w	d0,handle	store the file handle

* read the picture header to a buffer

	move.l	#headbuf,-(sp)	where to put the data
	move.l	#34,-(sp)	how many bytes to read
	move.w	handle,-(sp)	file handle
	move.w	#63,-(sp)	function number
	trap	#1		GEMDOS 63 - READ BYTES
	add.l	#12,sp		tidy
	
* set the palette from the header

	move.l	#headbuf+2,-(sp)	palette starts 2 bytes into header
	move.w	#6,-(sp)		function number
	trap	#14			XBIOS 14 - SETPALETTE
	addq.l	#6,sp 			tidy

* read the picture data

	move.l	scrnp,-(sp)	where to put the data
	move.l	#32000,-(sp)	how many bytes to read
	move.w	handle,-(sp)	file handle
	move.w	#63,-(sp)	function number
	trap	#1		GEMDOS 63 - READ BYTES
	add.l	#12,sp		tidy

* close the file

	move.w	handle,-(sp)	file handle
	move.w	#62,-(sp)	function number
	trap	#1		GEMDOS 62 - CLOSE A FILE
	addq.l	#4,sp		tidy
	
	rts

*************************************************************************

* INITIALISE THE PROGRAM

init
	
* find current rez. Returned in d0

	move.w	#4,-(sp)	function number
	trap	#14		XBIOS 4 - GETREZ
	addq.l	#2,sp		tidy
	
	move.w	d0,oldrez	save it
	
* is it low? If not set it to low. 

* (If you are intending to trace this program from within MONST to watch
* it at work, you may get screen corruption when you attempt to run a
* trace through this bit, changing the screen resolution. It took me ages
* to find out how to cure it but a good read of the manual (page 107 for
* version 2 users) shows the reason, and how to cure it. You haven't got
* the manual? I hope you're not one of the thieves who have helped to ruin
* the ST market!).

	cmpi.w	#0,d0		is d0 = 0? (low rez?)
	beq	getpal		Yes, branch
	
	move.w	#0,-(sp)	screen rez required. (0=low)
	move.l	#-1,-(sp)	negative number, no change to addresses
	move.l	#-1,-(sp)	negative number, no change to addresses
	move.w	#5,-(sp)	function number
	trap	#14		XBIOS 14 - SETSCREEN
	add.l	#12,sp		tidy
	
* get current palette and store it

getpal	

	move.l	#oldpal,a3	address of palette save buffer into a3
	move.w	#0,d3		counter for 16 colour registers
	
.loop	move.w	#-1,-(sp)	negative means read not write
	move.w	d3,-(sp)	the colour register to read
	move.w	#7,-(sp)	function number
	trap	#14		XBIOS 7 - SETCOLOR
	addq.l	#6,sp		tidy
	
	move.w	d0,(a3)+	put the colour data into the buffer.
	addq.w	#1,d3		point d3 to the next colour register
	cmpi.w	#16,d3		is d3 pointing to colour register 16 yet?
	blt	.loop		No, branch
	
* get screen start address and store it

	move.w	#2,-(sp)	function number
	trap	#14		XBIOS 2 - PHYSBASE
	addq.l	#2,sp		tidy
	
	move.l	d0,scrnp	save the physical screen address
	
	rts
	
*************************************************************************

* DEAL WITH FILE ERRORS

file_error
	
* set the character colour to blue. (I found the error messages were
* being printed in yellow, difficult to read, so this allows them to be
* read).

	move.l	d0,errnumf	save the error code

	move.l	#setbl,-(sp)	address of string to set character colour
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy

	move.l	errnumf,d0	return the error code

* is the error 'file not found'?

	cmpi.l	#-33,d0		is the error code -33?
	bne	.1		no, branch
	
* if so, say so

	move.b	#9,cursx	select the x cursor position
	move.b	#5,cursy	select the Y cursor position
	jsr	setcurs		set the cursor

	move.l	#ermes01,-(sp)	address of message (file not found)
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy
	
	bra	.2		goto next message

* else say general file error
	
.1	move.b	#8,cursx	select the x cursor position
	move.b	#5,cursy	select the Y cursor position
	jsr	setcurs		set the cursor

	move.l	#ermes02,-(sp)	address of message (file error)
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy
	
* and print the error code number

	move.b	#8,cursx	select the x cursor position
	move.b	#7,cursy	select the Y cursor position
	jsr	setcurs		set the cursor

	move.l	#ermes04,-(sp)	address of message (error code is :)
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy
	
	clr.l	d0		ensure d0 has no stray data
	move.w	errnumf+2,d0	put the (word) error code into d0
	move.l	#bidebuf,a0	load address of the binary/decimal buffer
	jsr	bins2dec	convert signed bin. num to decimal string
	
	move.l	#bidebuf+1,-(sp)	address of ascii error code string
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy

* say 'press escape'

.2	move.b	#8,cursx	select the x cursor position
	move.b	#9,cursy	select the Y cursor position
	jsr	setcurs		set the cursor

	move.l	#ermes03,-(sp)	address of message (press escape)
	move.w	#9,-(sp)	function number
	trap	#1		GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp		tidy
	
* go to exit routine

	bra	keyloop

*************************************************************************

* PRINT A SIGNED, WORD-SIZED, NUMBER TO THE SCREEN, IN DECIMAL.

* requires a 7 byte buffer
* byte 1 - header, number of digits in the string
* byte 2 to 7 - space for a 6 digit string. (A minus sign if needed, and
* 		up to five numeric digits).

* put the number to be printed into the low word of d0
* put the address of the 7 byte buffer into a0

bins2dec

* set up the registers

	movem.l	a0-a1/d0-d4,-(sp)	save registers
	
	lea	1(a0),a1	point a1 to where the neg sign is to go
	clr.l	d1		counter - number of decimal digits
	clr.l	d2		flag - no leading nonzero digit found d2=0
	
* is the number negative?
	
	tst.w	d0		is d0 negative?
	bpl	calcdg		no, branch

* if so, negate d0 & put a minus sign first on the string

	neg.w	d0		take d0 from 0. result in d0.
	move.b	#"-",(a1)+	put the ascii for a minus sign in buffer
	addq.b	#1,d1		inc number of digits counter
	
* now calculate the separate digits
	
calcdg	move.w	#10000,d3	d3 = the divisor
	bsr	divs16		divide d0 by d3 and save ascii in buffer

	move.w	#1000,d3
	bsr	divs16

	move.w	#100,d3
	bsr	divs16	

	move.w	#10,d3
	bsr	divs16	
	
	add.b	#'0',d0		convert the units digit to ascii
	move.b	d0,(a1)+	always save the units digit
	addq.b	#1,d1		inc number of digits
	move.b	d1,(a0)		put the number of digits at the front of buffer

	movem.l	(sp)+,a0-a1/d0-d4	restore registers
	
	rts	

* divide a (long) number in d0 by a (word) number in d3 low word
	
divs16	divu	d3,d0		unsigned division
	move.w	d0,d4		save the answer to d4
	clr.w	d0		set low word of d0 to 0
	swap	d0		put the remainder into low word of d0
	
	tst.b	d2		test the leading zero flag
	bne	svdig		branch if the flag is not zero
	
	tst.b	d4		it is, so test this digit for zero
	beq	enddiv		it is. No numbers left, so branch
	addq.b	#1,d2		d4 not zero, so set the flag to say so

* save the number in d4 to the buffer as ascii

svdig	add.b	#'0',d4		make into ascii
	addq.b	#1,d1		inc number of digits
	move.b	d4,(a1)+	save ascii digit in buffer
	
enddiv	rts	
	
*************************************************************************

* SET THE CURSOR POSITION

* ALWAYS set BOTH 'cursx' & 'cursy' values before calling.  Note that if 
* one of them is left from a previous call to this subroutine, it will have
* #31 added to it AGAIN!

setcurs

	movem.l	d0-d7/a0-a6,-(sp)	save registers

* ascii the cursor references

	add.b	#31,cursx	adding #31 makes it an ascii code
	add.b	#31,cursy	adding #31 makes it an ascii code

* print the cursor string, setting the screen cursor

	move.l	#curspos,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp
	
	movem.l	(sp)+,d0-d7/a0-a6	restore registers

	rts

*************************************************************************

* RESERVED MEMORY

		DATA

ermes01		dc.b	"Can't find the file...",0
ermes02		dc.b	"File problem... oh dear!",0
ermes03		dc.b	"Press <ESCAPE> to exit...",0
ermes04		dc.b	"The error code is : ",0
errnumf		dc.l	0,0		error code store and printing string
filename	dc.b	"PIC.PI1",0
setbl		dc.b	27,"b",8,0	set character print to colour blue

curspos		dc.b	27,"Y"		print this string to place the
cursy		dc.b	32		cursor where you want it.
cursx		dc.b	32
		dc.b	0
		
		BSS

		even
bidebuf		ds.b	8	buffer for printing signed numbers in dec
handle		ds.w	1	file handle
headbuf		ds.w	17	picture header
oldrez		ds.w	1	original screen rez
oldpal		ds.w	16	original colour palette
scancode	ds.w	1	code from a keypress
scrnp		ds.l	1	physical screen address

****************************** T H E   E N D ******************************
