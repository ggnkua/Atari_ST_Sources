
* How to use the IKBD to read mouse data packets, and use them to update
* program variables mousex & mousey.

* Started 14th December, 1993. Mike Barnard.

****************************************************************************

* The equals statements, for ease of changing variables.

* screen limits for mouse movement.

xmax	equ	319	low rez
ymax	equ	199
xmin	equ	0
ymin	equ	0

****************************************************************************

* Main loop.

	text

start	jsr	init		set it all up
	jsr	printmes	print messages
main	jsr	readmouse	read the mouse packet and set the variables
	jsr	printxy		print the values of the variables
	jsr	input		look for user input
*	jsr	count		print a counter to the screen to check speed
	bra	main
	
**************************************************************************

* loop counter

count
	move.l	counter,d0
	addq.l	#1,d0
	move.l	d0,counter
	
* set the cursor

	move.b	#30,cursx	set cursx
	move.b	#5,cursy	set cursy
	jsr	setcurs		set the cursor position on screen
	
* turn counter into decimal in decbuf

	jsr	bins2dec	go to convertion routine	

* print value of x in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp
	
	rts

**************************************************************************

* Change the variables using data from the mouse packet

readmouse

* load the registers with the X variable
	
	move.w	mousex,d0	put the x variable into d0
	clr.w	d1		ensure no rubbish left in the word
	move.b	mpack+1,d1	put the x data packet into d1
	
* do the calculating

	jsr	calcmouse	calculate the changes

* test the result for going beyond the screen limits
	
	cmpi.w	#xmin,d0	compare the result with the left border
	bmi	.limitl		if it's less than xmin then branch

.aa	cmpi.w	#xmax,d0	compare the result with the right border
	bgt	.limitr		if it's more than xmax then branch

* save the resulting value

.bb	move.w	d0,mousex	put new value in store
	
* load the registers with the Y variable
	
	move.w	mousey,d0	put the y variable into d0
	clr.w	d1		ensure no rubbish left in the word
	move.b	mpack+2,d1	put the y data packet into d1
	
* do the calculating

	jsr	calcmouse	calculate the changes

* test the result for going beyond the screen limits
	
	cmpi.w	#ymin,d0	compare the result with the top border
	bmi	.limitt		if it's less than ymin then branch

.cc	cmpi.w	#ymax,d0	compare the result with the bottom border
	bgt	.limitb		if it's more than ymax then branch

* save the resulting value

.dd	move.w	d0,mousey	put new value in store

* clear the data packet.

	move.l	#0,mpack	zero the 4 bytes at 'mpack'
	
	rts

* a few short subroutines from above...

.limitl	move.w	#xmin,d0	set d0 to xmin
	bra	.aa

.limitr	move.w	#xmax,d0	set d0 to xmax
	bra	.bb

.limitt	move.w	#ymin,d0	set d0 to ymin
	bra	.cc
	
.limitb	move.w	#ymax,d0	set d0 to xmax
	bra	.dd

calcmouse

* put variable to change into d0, word sized.
* put the data byte into d1, word sized.
* call here.

* multiply the data byte by this factor, for mouse sensitivity

	tst.b	d1		set the ccr for the data type
	beq	.end		if it's a zero, no change so branch out
	bmi	.neg		if it's negative then branch
	
* it must be positive, so add it to the variable

	add.w	d1,d0		add data to value. result in d0
	bra	.end		then leave
	
* it must be negative, so take the data from the variable.

.neg
	ext.w	d1		extend the byte to the word
	neg.w	d1		then 2's complement it.
	sub.w	d1,d0		take data from value. result in d0.
	
.end	rts

**************************************************************************

* look for input from the user

input

* get a scancode

	jsr	getscan		look for a keypress
	cmpi.w	#1,scancode	is it code 1 <Esc>?
	beq	exit		yes, return to desktop
	
	rts
	
**************************************************************************

* INITIALISE

init

* who cares what rez we're in...
* or where the screen is...
* or what the palette is...
* yet...

* set initial value of mousex and mousey

	move.w	#55,mousex
	move.w	#295,mousey
	
* set background colour to print text to green

	move.l	#textback2,-(sp)	address of esc string
	move.w	#9,-(sp)		function number
	trap	#1			GEMDOS 9 - PRINT A STRING
	addq.l	#6,sp			tidy

* get the keyboard vector table

	move.w	#34,-(sp)	function number
	trap	#14		XBIOS 34 - GET TABLE
	addq.l	#2,sp		tidy
	move.l	d0,keyvectable	address of keyboard vector table saved
	
* put address of my mouse handler into the table

	move.l	d0,a0			address of start of table
	lea	mhand,a1		address of my routine
	move.l	16(a0),oldmousevec	save the original mouse vector
	move.l	a1,16(a0)		and replace with my routine's address
	
* tell the IKBD to use relative mouse movement

	pea	ikcom03		address of IKbd COMmand 03 onto stack
	move.w	#0,-(sp)	length of command minus 1
	move.w	#25,-(sp)	function number
	trap	#14		XBIOS 25 - SEND IKBD COMMAND
	add.l	#8,sp		tidy

	rts
	
**************************************************************************

* display the variables

printxy

* turn mousex into decimal in decbuf

	clr.l	d0		ensure totally clear register
	move.w	mousex,d0	put mousex into d0
	jsr	bins2dec	go to convertion routine	

* set the cursor

	move.b	#19,cursx	set cursx
	move.b	#5,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print value of x in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp
	
* turn mousey into decimal in decbuf

	clr.l	d0		ensure totally clear register
	move.w	mousey,d0	put mousex into d0
	jsr	bins2dec	go to convertion routine	

* set the cursor

	move.b	#19,cursx	set cursx
	move.b	#7,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print value of y in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp

	rts

*************************************************************************

* SET THE CURSOR POSITION

* set BOTH 'cursx' & 'cursy' values before calling.  Note that if one of
* them is left from a previous call, it will have 31 added to it AGAIN.

setcurs

	movem.l	d0-d7/a0-a6,-(sp)	save registers

* ascii the cursor references

	add.b	#31,cursx	adding 31 makes it ascii for printing
	add.b	#31,cursy	adding 31 makes it ascii for printing

* print the cursor string, setting the screen cursor

	move.l	#curspos,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp
	
	movem.l	(sp)+,d0-d7/a0-a6	restore registers

	rts


*************************************************************************

* CONVERT A SIGNED, WORD-SIZED, NUMBER IN BINARY, TO A DECIMAL STRING OF
* ASCII CHARACTERS READY TO PRINT OUT. 

* The ascii result will be justified to the left, and padded out with
* spaces on the right. Negative numbers will be prefixed with a minus sign.

* Requires an 8 byte buffer. A word sized, signed, number can have values
* ranging from -32768 to +32767. That gives 5 digits, a possible minus sign
* if it is negative, and a zero byte marking the end of the string to
* be printed. (The eigth byte ensures a word boundry.)

* put the number to be printed into the low word of d0
* put the address of the 7 byte buffer into a0

bins2dec

* set up the registers

	movem.l	a0-a1/d0-d4,-(sp)	save registers

	move.l	#decbuf,a0	address of buffer into a0	
	move.l	#decbuf,a1	address of buffer into a1
	clr.l	d1		counter - number of decimal digits
	clr.l	d2		flag - leading zero found - d2=0
	
* is the number negative?
	
	tst.w	d0		is d0 negative?
	bpl	calcdg		no, branch

* if so, negate d0 & put a minus sign first on the string

	neg.w	d0		take d0 from 0. result in d0.
	move.b	#"-",(a1)+	put the ascii for a minus sign in buffer
	addq.b	#1,d1		inc number of digits counter
	
* now calculate the seperate digits
	
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

	cmpi.b	#6,d1		Has the number come up with 6 digits?
	beq	.end		Yes, branch. no spaces need to be added.
	
* add spaces

	move.w	#6,d3		d3 now holds the max number of digits
	sub.w	d1,d3		take d1 from d3. d3 now holds number of spaces

.loop	move.b	#" ",(a1)+	put ascii for a space into buffer
	subi.w	#1,d3		take one from number of spaces to be added
	tst.w	d3		test d3 for zero, all spaces entered
	bne	.loop		if not zero, branch.
	
.end	move.b	#0,(a1)+	put a terminating zero in the buffer
	movem.l	(sp)+,a0-a1/d0-d4	restore registers
	rts	

* divide a (long) number in d0 by a (word) number in d3 low word
	
divs16	divu	d3,d0		unsigned division
	move.w	d0,d4		save the answer to d4
	clr.w	d0		set low word of d0 to 0
	swap	d0		put the remainder into low word of d0
	
	tst.b	d2		test the leading zero flag
	bne	svdig		branch if the flag is not zero
	
	tst.b	d4		test this digit for zero
	beq	enddiv		yes, branch
	addq.b	#1,d2		d4 not zero, so set the flag to say so

* save the number in d4 to the buffer as ascii

svdig	add.b	#'0',d4		make into ascii
	move.b	d4,(a1)+	save ascii digit in buffer
	addq.b	#1,d1		inc number of digits		

enddiv	rts

**************************************************************************

* My mouse data packet handler.

* called by the IKBD exception routine

mhand
	move.b	#3,d0		d0=counter, 3 to 0
	lea	mpack,a1	address of buffer to store packet
.loop	move.b	(a0)+,(a1)+	store a byte of the packet
	subq.b	#1,d0		dec counter
	bne	.loop		if not zero, branch

	rts
	
*************************************************************************

* GET, (BUT DON'T EXAMINE), A KEYPRESS

* result returned as a word in 'scancode'

getscan
	movem.l	d0-d7/a0-a6,-(sp)	Save registers
	move.w	#0,scancode		Ensure a null return unless a key is found
	
* has a key been pressed?

	move.w	#$0b,-(sp)	GEMDOS $0B - KEYBOARD BUFFER STATUS?
	trap	#1		Result returned in d0.
	addq.l	#2,sp

	tst.w	d0		d0.w=0, no keys pressed, -1 = yes
	beq	.end		no keypresses in buffer, so return
	
* yes, get it's scancode

	move.w	#$08,-(sp)	GEMDOS 8 - GET A KEYPRESS
	trap	#1
	addq.l	#2,sp

	swap	d0		put scancode into low word
	move.w	d0,scancode	save the scancode for later

.end	
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	rts
	
******************************************************************************

* print the messages

printmes

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#3,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print  message(04) 'using relative pakets'

	move.l	#mes04,-(sp)	address of message
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#5,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print mes01 (x is)

	move.l	#mes01,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#7,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print mes02 (y is)

	move.l	#mes02,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#11,cursy	set cursy
	jsr	setcurs		set the cursor position on screen

* print message(03) 'press esc'

	move.l	#mes03,-(sp)	address of message
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp

	rts

**************************************************************************

* restore values to the system before exiting

exit

* Restore the original IKBD mouse vector

	move.l	keyvectable,a0	address of start of table
	move.l	oldmousevec,a1	address of original vector
	move.l	a1,16(a0)	replace original vector in the table

* restore the IKBD to relative mouse movement

	pea	ikcom03		address of IKbd COMmand 03 onto stack
	move.w	#0,-(sp)	length of command minus 1
	move.w	#25,-(sp)	function number
	trap	#14		XBIOS 25 - SEND IKBD COMMAND
	add.l	#8,sp		tidy

* Return to the desktop

	move.w	#0,-(sp)	function number
	trap	#1		GEMDOS 0 - TERMinate
	
**************************************************************************

* Storeage areas.

	data
	
curspos		dc.b	27,'Y'		Escape command - set cursor
cursy		dc.b	32
cursx		dc.b	32
		dc.b	0
		
ikcom01		dc.b	$09		IKBD command - set mouse absolute
		dc.b	$01,$3f		xmax (319)
		dc.b	$00,$c7		ymax (199)
ikcom02		dc.b	$0b,2,2		IKBD command - set threshold
ikcom03		dc.b	$08		IKBD command - set mouse relative

mes01		dc.b	'"MOUSEX" is : ',0	informative messages
mes02		dc.b	'"MOUSEY" is : ',0
mes03		dc.b	'Press <ESC> to exit...',0
mes04		dc.b	'Using "relative" IKBD data packets.',0

textback0	dc.b	27,'c','0',0	escape strings to print. will set
textback1	dc.b	27,'c','1',0	the background colour of printed
textback2	dc.b	27,'c','2',0	text to the colour register noted.
textback3	dc.b	27,'c','3',0
	
	bss
	
counter		ds.l	1	variable for a loop counter
decbuf		ds.w	4	buffer for printing a signed number in dec
keyvectable	ds.l	1	address of the keyboard vector table
mousex		ds.w	1	mouse pointer reference
mousey		ds.w	1	mouse pointer reference
mpack		ds.l	1	buffer to store mouse data packets
oldmousevec	ds.l	1	address of original mouse packet handler
random		ds.w	1	store for random numbers
scancode	ds.w	1	scancode of a keypress



