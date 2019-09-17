


*-----------------------------------------------------------------------*

*                          SETTIME.PRG V1.02				*

*         	  by Mike Barnard (MIC), 15th April '94			*

*-----------------------------------------------------------------------*

*                Written on DevpacST v2, tabs set to 8.			*

*           An auto folder program to set the internal clock.		*





*-----------------------------------------------------------------------*

* V1.01	- 1st March 1994.
* ----------------------
* First release. What else can I say? It had it's little problems...

* V1.02	- 12th April 1994.
* -----------------------
* Now that I've been using this for a while a few problems have emerged. I
* hope this fixes them.

* 	- Bug cure: 	Pressing a non numeric key, other than return, at
*			the option to abort caused the abort to fail. (I
*			had a couple of wrong labels in 'getval_r'.)

*	- Bug Cure:	Just a little one. The message allowing you to
*			press escape to quit didn't go away untill after
*			the second hour digit was entered, instead of
*			as soon as the first was pressed. Now it's cleared
*			immediately.

*	- Change: 	Changed the abort key. The return key is usually
*			used for accepting an option, and I found that
*			using it as an abort key wasn't natural. Using
*			<ESC> instead. Sorry.

*	- Change:	Same change for the retry option at the end. Now
*			you can press return to accept your settings, and
*			escape to retry.

*	- Change:	The contents of the text phrases, slightly.

*	- Add:		I've added leading zero's to single digit times.
*			It looks much better, I think.

* My address is at the bottom. Mic.

**********************************************************************

	output	settime2.prg

**********************************************************************

* SET UP SCREEN

start
	move.l	#mes14,-(sp)	clear the screen, display title
	move.w	#9,-(sp)	function number
	trap	#1		
	addq.l	#6,sp

**********************************************************************

* GET CURRENT INTERNAL TIME

* Xbios 22 & 23 uses a longword to pass the system time data back
* and forth. The 32 bits hold the data like this.

* 	Bits	   Total bits	data
*	0 - 4		5	seconds (2 sec. increments)
*	5 - 10		6	minutes
*	11 - 15		5	hours
*	16 - 20		5	Day of month
*	21 - 24		4	Month of year
*	25 - 31		7	Year. (An offset from 1980)

* The year offset means the year '94 is held as 14. (80 + offset of 14)

* get current stored time

	move.w	#23,-(sp)	function number
	trap	#14		XBIOS 23 - GETTIME
	addq.l	#2,-(sp)	tidy
	
	move.l	d0,oldtime	save it
	
* find the minutes data

	lsr.l	#5,d0		Removes seconds data
	bclr	#6,d0		
	bclr	#7,d0		remove hours data

	move.b	d0,c_min+1	save current minute		

* find the hours data

	move.l	oldtime,d0	get the unspoilt data
	
	lsr.l	#8,d0		removes seconds & minutes
	lsr.l	#3,d0		removes seconds & minutes
	bclr	#5,d0
	bclr	#6,d0
	bclr	#7,d0		remove day data

	move.b	d0,c_hour+1  	save hour
	
* find day data

	move.l	oldtime,d0	get the unspoilt data
	swap	d0		move d/y/m data to low word
	
	bclr	#5,d0
	bclr	#6,d0
	bclr	#7,d0		remove month data
	
	move.b	d0,c_day+1	save day
	
* find month data

	move.l	oldtime,d0	get the unspoilt data
	swap	d0		move d/y/m data to low word

	lsr.l	#5,d0		remove day data
	
	bclr	#4,d0
	bclr	#5,d0
	bclr	#6,d0
	bclr	#7,d0		remove year data
	
	move.b	d0,c_month+1	save  month
	
* find year data

	move.l	oldtime,d0	get the unspoilt data
	move.w	#0,d0		clear lower word (time) of d0
	swap	d0		move d/y/m data to low word
	
	lsr.l	#8,d0
	lsr.l	#1,d0		remove day & month
	
	move.b	d0,c_year+1	save year
	
*************************************************************************

* DISPLAY THE CURRENT TIME TO THE USER

* print 'The current time is...(cr)'

	move.l	#mes01,-(sp)	'current dtg is'
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* convert hours to decimal

	moveq.l	#0,d0		clearr d0
	move.w	c_hour,d0	number to print
	jsr	bins2dec	convert to decimal

* print hours

	move.l	#buffer,-(sp)	ascii string returned by bins2dec
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* print ':'

	move.l	#mes02,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* convert minutes to decimal

mins
	moveq.l	#0,d0		clr d0
	move.w	c_min,d0	number to print
	jsr	bins2dec	convert to decimal

* print minutes

	move.l	#buffer,-(sp)	'minutes' in decimal
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* print seperating comma

	move.l	#mes04,-(sp)	'minutes' in decimal
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp
	
* convert day to decimal

	moveq.l	#0,d0		clr d0
	move.w	c_day,d0	number to print
	jsr	bins2dec	convert to decimal

* print the day

	move.l	#buffer,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* print the slash

	move.l	#mes03,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* convert month to decimal

	moveq.l	#0,d0		clr d0
	move.w	c_month,d0	number to print
	jsr	bins2dec	convert to decimal

* print the month

	move.l	#buffer,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* print the slash

	move.l	#mes03,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* add offset to give correct year

	add.w	#80,c_year	add 80
	
* convert year to decimal

	moveq.l	#0,d0		clr d0
	move.w	c_year,d0	number to print
	jsr	bins2dec	convert to decimal

* print the year

	move.l	#buffer,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* print 'return for exit or enter time/date'

	move.l	#mes05,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp
	
* print 'time?'

	move.l	#mes07,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp
	
* enable cursor

	move.l	#mes08,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

************************************************************************

* GET INPUT FROM USER.

* get hours data

hoursin

* get users input

	jsr	getval_r	get an input (number) or return (exit prog)

* 1st input is 10's, so make it so, save it and echo it to the screen

	mulu	#10,d0		times 10
	move.w	d0,n_hour	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

	move.l	#mes11,-(sp)	remove 'or return' and reset cursor
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp


* now look for second digit

	jsr	getval		get an input

* 2nd input is 1's, so save it and echo it to the screen

	add.w	d0,n_hour	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* this should give a valid hour, unless user entered silly time.

	cmpi.w	#24,n_hour	if 24 hours or more, time is invalid.
	blt	minsin		it's ok, so branch
	
	move.l	#mes10,-(sp)	clear bad input from screen and try again
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp
	bra	hoursin 	return to start
		
* get minutes input

minsin
	move.l	#mes06,-(sp)	set the cursor
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp
	
	jsr	getval		get an input

* 1st input is 10's, so make it so, save it and echo it to the screen

	mulu	#10,d0		times 10
	move.w	d0,n_mins	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* now look for second digit

	jsr	getval		get an input

* 2nd input is 1's, so save it and echo it to the screen

	add.w	d0,n_mins	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* this should give valid minutes, unless user entered silly time.

	cmpi.w	#60,n_mins	if 60 minutes or more, time is invalid.
	blt	datein		it's ok, so branch
	
	move.l	#mes10,-(sp)	else ask for input again
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

	bra	minsin 		return to start

* ask user for date (dd mm yy)

datein
	move.l	#mes12,-(sp)	'date? dd mm yy'
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

datein2
	jsr	getval		get an input

* 1st input is 10's, so make it so, save it and echo it to the screen

	mulu	#10,d0		times 10
	move.w	d0,n_day	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* now look for second digit

	jsr	getval		get an input

* 2nd input is 1's, so save it and echo it to the screen

	add.w	d0,n_day	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* this should give valid minutes, unless user entered silly time.

	cmpi.w	#32,n_day	if 32 days or more, value is invalid.
	blt	monthin		it's ok, so branch
	
	move.l	#mes10,-(sp)	else ask for input again
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

	bra	datein2 		return to start

* get the months value from user

monthin
	move.l	#mes02,-(sp)	move cursor 1 place right
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

monthin2
	jsr	getval		get an input

* 1st input is 10's, so make it so, save it and echo it to the screen

	mulu	#10,d0		times 10
	move.w	d0,n_month	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* now look for second digit

	jsr	getval		get an input

* 2nd input is 1's, so save it and echo it to the screen

	add.w	d0,n_month	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* this should give valid minutes, unless user entered silly time.

	cmpi.w	#13,n_month	if 13 months or more, value is invalid.
	blt	yearin		it's ok, so branch
	
	move.l	#mes10,-(sp)	else ask for input again
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

	bra	monthin2 		return to start

* get the users year input

yearin
	move.l	#mes02,-(sp)	move cursor 1 place right
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

yearin2
	jsr	getval		get an input

* 1st input is 10's, so make it so, save it and echo it to the screen

	mulu	#10,d0		times 10
	move.w	d0,n_year	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* now look for second digit

	jsr	getval		get an input

* 2nd input is 1's, so save it and echo it to the screen

	add.w	d0,n_year	save it

	move.w	d1,-(sp)	put ascii onto stack
	jsr	printchar	print it to the screen

* this should give valid minutes, unless user entered silly time.

	cmpi.w	#100,n_year	if 100 years or more, value is invalid.
	blt	confirm		it's ok, so branch
	
	move.l	#mes10,-(sp)	else ask for input again
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

	bra	yearin2 		return to start

***********************************************************************

* ALLOW USER TO CONFIRM THAT HIS/HER INPUT IS CORRECT

confirm

* ask user his views

	move.l	#mes13,-(sp)	'confirm' message
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

* and wait for his reply

wait
	jsr	waitkey		look for press
	cmpi.w	#0,d0		yes or no?
	beq	wait		no, loop back
	jsr	getchar		yes, get it
	
* if it's <return> start again

	swap	d0		get scancode
	cmpi.w	#1,d0		is it 1 (ESCAPE)
	beq	start		if so return to start

* set 'newtime' with new data

* year data
test
	move.w	n_year,d0	get year data (7 bits)
	sub.w	#80,d0		taking 80 gives the offset needed
	move.b	d0,d7		store it in 'newtime'

* month data

	lsl.l	#4,d7		make room for the next 4 bits
	move.w	n_month,d0	get month data (4 bits)
	
	move.l	#3,d1		d1=counter. value-1 for dbra
	jsr	copybit		copy n bits from d0 to d7 (lo bits to hi)	

* day data

	lsl.l	#5,d7		make room for the next 5 bits
	move.w	n_day,d0	get day data (5 bits)
	
	move.l	#4,d1		d1=counter. value-1 for dbra
	jsr	copybit		copy n bits from d0 to d7 (lo bits to hi)	

* hour data

	lsl.l	#5,d7		make room for the next 5 bits
	move.w	n_hour,d0	get month data (5 bits)
	
	move.l	#4,d1		d1=counter. value-1 for dbra
	jsr	copybit		copy n bits from d0 to d7 (lo bits to hi)	

* minute data

	lsl.l	#6,d7		make room for the next 6 bits
	move.w	n_mins,d0	get minutes data (6 bits)
	
	move.l	#5,d1		d1=counter. value-1 for dbra
	jsr	copybit		copy n bits from d0 to d7 (lo bits to hi)	

* no seconds data, so shift left to clear last 5 bits

	lsl.l	#5,d7

* save it to tos

	move.l	d7,-(sp)	new time data
	move.w	#22,-(sp)	function number
	trap	#14		XBIOS 22 - SETTIME
	addq.l	#6,sp		tidy
	
* and exit to the desktop. Job done.
	
	bra	exit

************************************************************************

* COPY BITS FROM D0 TO D7

* d1 is a counter and pointer for the number of bits to copy -1 (dbra)

copybit	
	btst.l	d1,d0		examine bit 'n' in d0
	beq	.clr		if it's 0, branch
	bset	d1,d7		else set same bit in d7
	bra	.loop		jump past .clr
.clr	bclr	d1,d7		clear same bits in d7 as is in d1
.loop	dbra	d1,copybit	dec d1. if not -1, branch.

	rts

************************************************************************

* GET A VALUE FROM 1-9 FROM THE USER

* return the value in d0.w
* return the ascii in d1.w

getval
	jsr	waitkey		look for press
	cmpi.w	#0,d0		yes or no?
	beq	getval		no, loop back
	jsr	getchar		yes, get it

	cmp.b	#'0',d0		compare with 0
	blt	getval		lower than 0, not a digit. try again
	
	cmp.b	#'9',d0		compare with 9 
	bgt	getval		higher than 9, not a digit. try again
	
	move.w	d0,d1		save ascii to d1
	sub.w	#'0',d0		convert d0 from ascii to integer value

	rts

************************************************************************

* GET A VALUE FROM 1-9 OR <RETURN> FROM THE USER

* return the value in d0.w
* return ascii in d1

getval_r
	jsr	waitkey		look for press
	cmpi.w	#0,d0		yes or no?
	beq	getval_r	no, loop back
	jsr	getchar		yes, get it
	
	swap	d0		get scancode
	cmpi.w	#1,d0		is it 1 (ESCAPE)
	beq	exit		if so, exit the program

	swap	d0		get ascii again
	cmp.b	#'0',d0		compare with 0
	blt	getval_r	lower than 0, not a digit. try again
	
	cmp.b	#'9',d0		compare with 9 
	bgt	getval_r	higher than 9, not a digit. try again
	
	move.w	d0,d1		save ascii to d1
	sub.w	#'0',d0		convert d0 from ascii to integer value

	rts

************************************************************************

* PRINT A CHARACTER AT THE CURRENT CURSOR POSITION

printchar

	move.w	4(sp),-(sp)	move the char up the stack
	move.w	#2,-(sp)	specify the keyboard
	move.w	#3,-(sp)	function number
	trap	#13		BIOS 3 - BCONOUT
	addq.l	#6,sp		tidy
	
	rts

************************************************************************

* GET A CHARACTER FROM THE KEYBOARD

getchar

	move.w	#2,-(sp)	specify the keyboard
	move.w	#2,-(sp)	function number
	trap	#13		BIOS 2 - CONIN
	addq.l	#4,sp		tidy
	
	rts
	
************************************************************************

* WAIT FOR A KEYPRESS

waitkey

	move.w	#2,-(sp)	specify the keyboard
	move.w	#1,-(sp)	function number
	trap	#13		BIOS 1 - BCONSTAT
	addq.l	#4,sp		tidy
	
	rts
	
************************************************************************

* RETURN TO DESKTOP

exit

* disable cursor

	move.l	#mes09,-(sp)
	move.w	#9,-(sp)
	trap	#1		print it
	addq.l	#6,sp

	move.w	#0,-(sp)
	trap	#1
	
*************************************************************************

* CONVERT A SIGNED, WORD-SIZED, NUMBER TO AN ASCII STRING FOR PRINTING.

* requires a 7 byte buffer
* byte 1 - header, number of digits in the string
* byte 2 to 7 - space for a 6 digit string. (A minus sign if needed, and
* 		up to five numeric digits).

* put the number to be printed into the low word of d0

bins2dec

* set up the registers

	movem.l	a0-a1/d0-d4,-(sp)	save registers
	
	move.l	#buffer,a0	ensure the buffer is empty
	move.l	#0,buffer
	move.l	#0,buffer+4
	
	lea	1(a0),a1	point a1 to where the neg sign is to go
	clr.l	d1		counter - number of decimal digits
	clr.l	d2		flag - no leading nonzero digit found d2=0
	
* is the number negative?
	
	tst.w	d0		is d0 negative?
	bpl	calcdg		no, branch

* if so, negate d0 & put a minus sign first on the string

	neg.w	d0		take d0 from 0. result in d0.
	move.b	#"-",(a1)+	put the ascii for a minus sign in buffer
	addq.b	#1,d1		increment the number of digits counter
	
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
	move.b	d0,(a1)+	always save the units digit, even 0.
	addq.b	#1,d1		inc number of digits
	move.b	d1,(a0)		put the number of digits at the front of buffer

* If there is only one digit in the buffer, add a leading zero.

	cmpi.b	#1,d1		is d1.b one?
	bgt	.end		it's more than one, so branch
	
	move.b	1(a0),2(a0)	copy the digit to the next byte
	move.b	#48,1(a0)	make the 1st digit ascii zero
	
.end
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
	
buffer	ds.l	2

************************************************************************	

* variables

mes01		dc.b	10,10,10,"Your computers current time & date is...",13,10
		dc.b	'',0
mes02		dc.b	":",0
mes03		dc.b	"/",0
mes04		dc.b	" - ",0
mes05		dc.b	13,10,10,"Please enter a new time & date, OR"
		dc.b	13,10,"press <ESCAPE> to abort.",0
mes06		dc.b	27,'Y',41,49,0
mes07		dc.b	13,10,10,"Time? (HH:MM) --:--",8,8,8,8,8,0
mes08		dc.b	27,'e',0
mes09		dc.b	27,'f',0
mes10		dc.b	8,8,'--',8,8,0
mes11		dc.b	27,'Y',38,62,'...       '
		dc.b	27,'B',27,'l',27,'Y',41,47,0
mes12		dc.b	13,10,'Date? (DD:MM:YY) --:--:--',8,8,8,8,8,8,8,8,0
mes13		dc.b	13,10,10,'Press any key to accept, OR'
		dc.b	13,10,'press <ESCAPE> to retry...',0
mes14		dc.b	27,'E',13,10,27,'p',"       TIMESETTER v1.02 by MIC, '94        ",27,'q',13,27,'A',0
	
c_hour		ds.w	1	current setting
c_min		ds.w	1	
c_year		ds.w	1
c_month		ds.w	1
c_day		ds.w	1

n_hour		ds.w	1	new setting
n_mins		ds.w	1	
n_year		ds.w	1
n_month		ds.w	1
n_day		ds.w	1

oldtime		ds.l	1	return from OS

* copyright notice.

 	dc.b	'Time.prg, by Mike Barnard. 12th April '
 	dc.b	'1994. I declare this program Public Domain, and NO-ONE '
 	dc.b	"may charge for it. Hope it's useful. I wrote it for my own "
 	dc.b	"use as I didn't have a simple time setter. (The control "
 	dc.b	'panel keeps changing my STE colour settings. Wierd.) '
 	dc.b	'My address is - 52 Westbourne avenue, Worthing, '
  	dc.b	'West Sussex, BN14 8DF. Any correspondance is welcome '
 	dc.b	"as long as it's not foul. Also - if this program causes '"
 	dc.b	'any problems, You use it at your own risk. ',0


