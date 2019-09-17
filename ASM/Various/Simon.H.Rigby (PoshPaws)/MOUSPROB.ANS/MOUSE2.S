
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
;WHY NOT USE BSR (UNLESS PROGRAM IS HUGE!) AND BSR.S FOR SHORT JUMPS
start	bsr	init		set it all up
	bsr	printmes	print messages
main	bsr.s	readmouse	read the mouse packet and set the variables
	bsr	printxy		print the values of the variables
	bsr	input		look for user input
*	bsr	count		print a counter to the screen to check speed
	bra.s	main
	
**************************************************************************
;PRESUME NONE OF THIS IS USED
* loop counter

count
;	move.l	counter,d0
;	addq.l	#1,d0
;	move.l	d0,counter
;WHY NOT USE THIS INSTEAD?
	addq.l	#1,counter

	
* set the cursor

	move.b	#30,cursx	set cursx
	move.b	#5,cursy	set cursy
;	jsr	setcurs		set the cursor position on screen
;USE BSR
	bsr	setcurs
	
* turn counter into decimal in decbuf

	bsr	bins2dec	go to convertion routine	

* print value of x in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;USE WORD LENGTH TO ADD TO ADDRESS REGISTERS
	addq.w	#6,sp
	
	rts

**************************************************************************
;DON'T LIKE ALL THE JUMPS IN THIS - RE-ARRANGED TO PUT SUB-ROUTINES
;IN-LINE - COMPARE THIS WITH ORIGINAL CODE
* Change the variables using data from the mouse packet

readmouse

* load the registers with the X variable
	
	move.w	mousex,d0	put the x variable into d0
;	clr.w	d1		ensure no rubbish left in the word
	move.w	mpack+2,d1	put the x data packet into d1
	SUB.W	D1,mpack+2	subtract read value from pool
;NOTE: CHANGED TO WORD NOW AS INTERRUPTS ADD THE X OFFSET TO THIS VALUE
;AND VALUE TAKEN OUT IS SUBTRACTED FROM MPACK IN CASE INTERRUPT ADDS
;AGAIN AFTER READING BUT BEFORE CLEARING!
;USE EXT.W AFTER MOVE.B IF DATA IS SIGNED, INSTEAD OF CLR.W BEFORE
;	ext.w	d1
* do the calculating

;USE BSR, NOT JSR
;THIS IS NOT NEEDED - JUST ADD THE SIGNED VALUE - SEE COMMENTS IN CALCMOUSE
;	bsr	calcmouse	calculate the changes
	add.w	d1,d0

* test the result for going beyond the screen limits
	
	cmpi.w	#xmin,d0	compare the result with the left border
;SHORT JUMP
;CHANGED TO OPPOSITE CONDITION AND PUT SUB-ROUTINE INSIDE GAP!
	bpl.s	.aa		if it's more than xmin then branch past
	move.w	#xmin,d0	set d0 to xmin

.aa	cmpi.w	#xmax,d0	compare the result with the right border
;SHORT JUMP
	ble.s	.bb		if it's not more than xmax then branch past
	move.w	#xmax,d0	set d0 to xmax

* save the resulting value

.bb	move.w	d0,mousex	put new value in store
	
* load the registers with the Y variable
	
	move.w	mousey,d0	put the y variable into d0
;	clr.w	d1		ensure no rubbish left in the word
	move.w	mpack+4,d1	put the y data packet into d1
	SUB.W	D1,mpack+4	and subtract it from the pool
;NOTE: MPACK NOW HAS 3 WORDS FOR BUTTONS,X & Y AS EACH INTERRUPT ADDS TO THIS VALUE
;AND YOU SHOULD SUBTRACT EACH VALUE YOU TAKE OUT IN CASE IT ADDS WHILE YOU ARE
;IN THE MIDDLE OF CLEARING (YOU'D LOSE THE NEW VALUE)
;MAKE IT A SIGNED WORD FOR ADDING
;	ext.w	d1
	
* do the calculating
;BSR INSTEAD OF JSR - JUST ADD VALUE (SINCE IT IS SIGNED)
;	bsr	calcmouse	calculate the changes
	add.w	d1,d0

* test the result for going beyond the screen limits
	
	cmpi.w	#ymin,d0	compare the result with the top border
;SHORT JUMP
	bpl.s	.cc		if it's not less than ymin then branch past
	move.w	#ymin,d0	set d0 to ymin

.cc	cmpi.w	#ymax,d0	compare the result with the bottom border
;SHORT JUMP
	ble.s	.dd		if it's not more than ymax then branch past
	move.w	#ymax,d0	set d0 to xmax

* save the resulting value

.dd	move.w	d0,mousey	put new value in store

* DON'T clear the data packet - YOU DON'T KNOW WHEN IT IS BEING USED!.
;USE CLR INSTEAD OF MOVE
;	clr.l	mpack	zero the 4 bytes at 'mpack'
	
	rts

calcmouse
;NOTE: LOOK AT COMMENTS - THIS ROUTINE IS NO LONGER USED
* put variable to change into d0, word sized.
* put the data byte into d1, word sized.
* call here.

* multiply the data byte by this factor, for mouse sensitivity
;SHORT JUMPS USED
	tst.b	d1		set the ccr for the data type
	beq.s	.end		if it's a zero, no change so branch out
	bmi.s	.neg		if it's negative then branch
	
* it must be positive, so add it to the variable

	add.w	d1,d0		add data to value. result in d0
	bra.s	.end		then leave
	
* it must be negative, so take the data from the variable.
;THIS IS NON-SENSICAL - ADDING A NEGATIVE NUMBER IS THE SAME AS 
;SUBTRACTING A POSITIVE NUMBER
.neg
	ext.w	d1		extend the byte to the word
	neg.w	d1		then 2's complement it.
	sub.w	d1,d0		take data from value. result in d0.
	
.end	rts

**************************************************************************

* look for input from the user

input

* get a scancode
;USE BRANCH RATHER THAN JUMP
	bsr	getscan		look for a keypress
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
;	addq.l	#6,sp			tidy
;QUICKER TO ADD WORDS TO ADDRESS REGISTERS AS ALL 32 BITS OF ADDRESS REGISTER
;ARE STILL AFFECTED!
	addq.w	#6,sp


* get the keyboard vector table

	move.w	#34,-(sp)	function number
	trap	#14		XBIOS 34 - GET TABLE
;	addq.l	#2,sp		tidy
;AS ABOVE - USE WORDS WHEN ADDING TO ADDRESS REGISTERS
	addq.w	#2,sp
	move.l	d0,keyvectable	address of keyboard vector table saved
	
* put address of my mouse handler into the table

	move.l	d0,a0			address of start of table
;	lea	mhand,a1		address of my routine
;DON'T NEED TO USE A1 - JUST PUT THE ADDRESS AS IMMEDIATE DATA INTO 16(A0)
	move.l	16(a0),oldmousevec	save the original mouse vector
;	move.l	a1,16(a0)		and replace with my routine's address
;SEE ABOVE - USE BELOW INSTEAD
	move.l	#mhand,16(a0)
	
* tell the IKBD to use relative mouse movement

	pea	ikcom03		address of IKbd COMmand 03 onto stack
;	move.w	#0,-(sp)	length of command minus 1
;WHY NOT USE CLR INSTEAD?
	clr.w	-(sp)
	move.w	#25,-(sp)	function number
	trap	#14		XBIOS 25 - SEND IKBD COMMAND
;	add.l	#8,sp		tidy
;AND ADDQ AGAIN WITH .W
	addq.w	#8,sp
	rts
	
**************************************************************************

* display the variables

printxy

* turn mousex into decimal in decbuf

	clr.l	d0		ensure totally clear register
	move.w	mousex,d0	put mousex into d0
;NOTE
	Bsr.S	bins2dec	go to convertion routine	

* set the cursor

	move.b	#19,cursx	set cursx
	move.b	#5,cursy	set cursy
;NOTE
	Bsr.S	setcurs		set the cursor position on screen

* print value of x in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
	addq.l	#6,sp
	
* turn mousey into decimal in decbuf

	clr.l	d0		ensure totally clear register
	move.w	mousey,d0	put mousex into d0
;NOTE
	Bsr.S	bins2dec	go to convertion routine	

* set the cursor

	move.b	#19,cursx	set cursx
	move.b	#7,cursy	set cursy
;NOTE
	Bsr.S	setcurs		set the cursor position on screen

* print value of y in decimal

	move.l	#decbuf,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;NOTE
	addq.W	#6,sp

	rts

*************************************************************************

* SET THE CURSOR POSITION

* set BOTH 'cursx' & 'cursy' values before calling.  Note that if one of
* them is left from a previous call, it will have 31 added to it AGAIN.

setcurs
;NOTE: GEMDOS USES ONLY D0-D2/A0-A2
	movem.l	d0-d2/a0-a2,-(sp)	save registers

* ascii the cursor references

	add.b	#31,cursx	adding 31 makes it ascii for printing
	add.b	#31,cursy	adding 31 makes it ascii for printing

* print the cursor string, setting the screen cursor

	move.l	#curspos,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;NOTE
	addq.W	#6,sp
	
	movem.l	(sp)+,d0-d2/a0-a2	restore registers

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
;quicker to move a0 to a1
;	move.l	#decbuf,a1	address of buffer into a1
	move.l	a0,a1
;MOVEQ IS QUICKER FOR A DATA REGISTER THAN CLR
	moveq	#0,d1		counter - number of decimal digits
	moveq	#0,d2		flag - leading zero found - d2=0
	
* is the number negative?
;REMEMBER D0 IS A WORD - SO CONVERT IT TO A LONG FIRST
;AFTER THAT DIV16 MAKES SURE IT IS EXTENDED TO A LONG
;	tst.w	d0		is d0 negative?
	ext.l	d0		;STILL SETS N BIT (TESTED BY BPL)
;SHORT JUMPS
	bpl.s	calcdg		no, branch

* if so, negate d0 & put a minus sign first on the string
;NOTE
	neg.L	d0		take d0 from 0. result in d0.
	move.b	#"-",(a1)+	put the ascii for a minus sign in buffer
	addq.b	#1,d1		inc number of digits counter
	
* now calculate the seperate digits
;SHORT JUMPS	
calcdg	move.w	#10000,d3	d3 = the divisor
	bsr.s	divs16		divide d0 by d3 and save ascii in buffer

	move.w	#1000,d3
	bsr.s	divs16

	move.w	#100,d3
	bsr.s	divs16	

	move.w	#10,d3
	bsr.s	divs16	
	
	add.b	#'0',d0		convert the units digit to ascii
	move.b	d0,(a1)+	always save the units digit
	addq.b	#1,d1		inc number of digits

	cmpi.b	#6,d1		Has the number come up with 6 digits?
;SHORT JUMPS
	beq.s	.end		Yes, branch. no spaces need to be added.
	
* add spaces

	move.w	#6,d3		d3 now holds the max number of digits
	sub.w	d1,d3		take d1 from d3. d3 now holds number of spaces

.loop	move.b	#" ",(a1)+	put ascii for a space into buffer
	subi.w	#1,d3		take one from number of spaces to be added
	tst.w	d3		test d3 for zero, all spaces entered
;SHORT JUMPS
	bne.s	.loop		if not zero, branch.
;USE CLR INSTEAD OF MOVE	
.end	clr.b	(a1)+	put a terminating zero in the buffer
	movem.l	(sp)+,a0-a1/d0-d4	restore registers
	rts	

* divide a (long) number in d0 by a (word) number in d3 low word
;SHORT JUMPS	
divs16	divu	d3,d0		unsigned division
	move.w	d0,d4		save the answer to d4
	clr.w	d0		set low word of d0 to 0
	swap	d0		put the remainder into low word of d0
	
	tst.b	d2		test the leading zero flag
	bne.s	svdig		branch if the flag is not zero
	
	tst.b	d4		test this digit for zero
	beq.s	enddiv		yes, branch
	addq.b	#1,d2		d4 not zero, so set the flag to say so

* save the number in d4 to the buffer as ascii

svdig	add.b	#'0',d4		make into ascii
	move.b	d4,(a1)+	save ascii digit in buffer
	addq.b	#1,d1		inc number of digits		

enddiv	rts

**************************************************************************
;BIG BOO BOO!
;THE PACKETS ARE BEING OVERWRITTEN EACH TIME THIS INTERRUPT IS CALLED!
;YOU NEED TO ADD THE X & Y HERE AND SUBTRACT IT WHEN YOU ADD IT TO YOUR VALUE!
* My mouse data packet handler.

* called by the IKBD exception routine
;DON'T FORGET TO SAVE ALL REGISTERS USED!!!
mhand
;***NOTE:
	movem.l	d0/a0-a1,-(sp)
;NOT WORTH LOOPING FOR LESS THAN SAY 5 REALLY
;	move.b	#3,d0		d0=counter, 3 to 0
	lea	mpack,a1	address of buffer to store packets (as words) in
	move.b	(a0)+,d0	mouse button status byte
	AND.W	#$3,d0		;MANY CHOICES OF OPCODE BUT CLEAR DOWN TO
				;BUTTON VALUES ONLY - 0=NONE/1=L/2=R/3=BOTH
	MOVE.W	D0,(A1)+
	MOVE.B	(A0)+,D0	;X VALUE TO ADD TO EXISTING VALUES NOT YET DEALT WITH
	EXT.W	D0		;EXTEND IT TO SIGNED WORD
	ADD.W	D0,(A1)+	;IF POSITIVE IT ADDS, IF NEGATIVE IT SUBTRACTS!
	MOVE.B	(A0)+,D0	;Y VALUE TO ADD TO EXISTING VALUES NOT YET DEALT WITH
	EXT.W	D0		;EXTEND IT TO SIGNED WORD
	ADD.W	D0,(A1)+	;IF POSITIVE IT ADDS, IF NEGATIVE IT SUBTRACTS!
;***NOTE:
	movem.l	(sp)+,d0/a0-a1
;ESPECIALLY USE SHORT JUMPS IN LOOPS LIKE THIS USED TO HAVE IN IT!
	rts
	
*************************************************************************

* GET, (BUT DON'T EXAMINE), A KEYPRESS

* result returned as a word in 'scancode'

getscan
;ONLY NEED TO SAVE A0-A2/D0-D2 FOR GEMDOS!
	movem.l	d0-d2/a0-a2,-(sp)	Save registers
	move.w	#0,scancode		Ensure a null return unless a key is found
	
* has a key been pressed?

	move.w	#$0b,-(sp)	GEMDOS $0B - KEYBOARD BUFFER STATUS?
	trap	#1		Result returned in d0.
;NOTE
	addq.w	#2,sp

	tst.w	d0		d0.w=0, no keys pressed, -1 = yes
;SHORT JUMPS
	beq.s	.end		no keypresses in buffer, so return
	
* yes, get it's scancode

	move.w	#$08,-(sp)	GEMDOS 8 - GET A KEYPRESS
	trap	#1
;NOTE
	addq.w	#2,sp

	swap	d0		put scancode into low word
	move.w	d0,scancode	save the scancode for later

.end	
	movem.l	(sp)+,d0-d2/a0-a2	restore registers
	rts
	
******************************************************************************

* print the messages

printmes

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#3,cursy	set cursy
;USE BSR NOT JSR
	bsr	setcurs		set the cursor position on screen

* print  message(04) 'using relative pakets'

	move.l	#mes04,-(sp)	address of message
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;USE ADDQ.W FOR ADDRESS REGISTERS
;	addq.l	#6,sp
	addq.w	#6,sp
* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#5,cursy	set cursy
;USE BSR NOT JSR
	bsr	setcurs		set the cursor position on screen

* print mes01 (x is)

	move.l	#mes01,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;NOTE
	addq.w	#6,sp

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#7,cursy	set cursy
;NOTE
	bsr	setcurs		set the cursor position on screen

* print mes02 (y is)

	move.l	#mes02,-(sp)	address of string onto stack
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;NOTE
	addq.w	#6,sp

* set the cursor

	move.b	#5,cursx	set cursx
	move.b	#11,cursy	set cursy
;NOTE
	bsr	setcurs		set the cursor position on screen

* print message(03) 'press esc'

	move.l	#mes03,-(sp)	address of message
	move.w	#9,-(sp)	GEMDOS 9 - PRINT A STRING
	trap	#1
;NOTE
	addq.w	#6,sp

	rts

**************************************************************************

* restore values to the system before exiting

exit

* Restore the original IKBD mouse vector

	move.l	keyvectable,a0	address of start of table
;	move.l	oldmousevec,a1	address of original vector
;JUST SHOVE IT STRAIGHT INTO 16(A0)
;	move.l	a1,16(a0)	replace original vector in the table
	move.l	oldmousevec,16(a0)

* restore the IKBD to relative mouse movement

	pea	ikcom03		address of IKbd COMmand 03 onto stack
;USE CLR
;	move.w	#0,-(sp)	length of command minus 1
	clr.w	-(sp)
	move.w	#25,-(sp)	function number
	trap	#14		XBIOS 25 - SEND IKBD COMMAND
;	add.l	#8,sp		tidy
;USE QUICK FORM AND WORD LENGTH FOR ADDRESS REGISTERS
	addq.w	#8,sp

* Return to the desktop
;USE CLR
;	move.w	#0,-(sp)	function number
	clr.w	-(sp)
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
mpack		ds.W	3	buffer to store mouse UNpackED data
				;BUTTONS.W,X.W AND Y.W
oldmousevec	ds.l	1	address of original mouse packet handler
random		ds.w	1	store for random numbers
scancode	ds.w	1	scancode of a keypress



