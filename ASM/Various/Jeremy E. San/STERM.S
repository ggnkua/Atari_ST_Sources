*------------------------------------------------------------------------*
* STerminal - a communications program.                                  *
* FreeWare from Antic - the Atari Resource                               *
* (c) 1985 Antic Publishing / Jeremy E. San                              *
* Version 101785                                                         *
* Written by Jeremy E. San                                               *
* Re-Edited by Patrick Bass    Antic ST program editor                   *
* Kan ikke assembleres med HiSoft DevpacST version 2!!!			 *
*------------------------------------------------------------------------*

brate	equ	9		300 baud default baud rate
xon	equ	$11		Ctrl Q
xoff	equ	$13		Ctrl S
esc	equ	27		Escape character in vt52 mode
cr	equ	13		Carriage Return
lf	equ	10		Line Feed

* Xmodem definitions...
soh	equ	$01
eot	equ	$04
ack	equ	$06
nak	equ	$15
can	equ	$18

*-------------------------------------------------------------------------*
start	move.l	a7,a5	        * save a7 so we can get the base page address
	move.l	#ustk,a7	* set local stack
	move.l	4(a5),a5	* basepage address
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0	* skip los pageos baseos
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move	d0,-(sp)	* junk word
	move	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
*
* Now, here comes MY bit of the program, the terminal.
*

*-------------------------------------------------------------------------*
_main	
	lea.l	start(pc),a5	Master index to make program position
startup	
	bsr	init		Anything worth initialising these days?

	lea.l	welcome(a5),a0	Howdy doody pard`ner
	bsr	message		Print message

mainloop
	bsr	scankey		Try scanning for a key
	tst.l	d0		Got one?
	beq.s	notkeyu		Nope!

	swap	d0		test for help key?
	cmp.b	#$62,d0		Yes?
	beq	trymenu		Was it the menu command?

	swap	d0
	move.w	d0,d1		Transfer into d1 for output
	bsr	sendser		Yes, so send it
notkeyu	
	move.b	fileflag(a5),d0	Are we uploading?
	cmp.b	#"U",d0		Yes??
	bne.s	notkey1		Nope!

	move.l	ubufptr(a5),a0	Get upload pointer
	move.l	bufptr(a5),a1	Get normal pointer
	cmp.l	a1,a0		Have we finished yet?
	bge.s	finupl		Yup!

	clr.w	d1		Clear reggie
	move.b	(a0)+,d1	Get a byte
	move.l	a0,ubufptr(a5)	Update pointer
	bsr	sendser		Send it
	bra.s	notkey1		.. and continue!
finupl	
	clr.b	fileflag(a5)	Signal end of upload
notkey1	
	bsr	scanser		Try scanning the serial port?
	tst.l	d0		Got a character?
	bmi.s	mainloop	nope!

	and.w	#$7f,d0		Mask out parity bit
	move.w	d0,d1		Transfer to d1
	bsr	wrchar		Print it on screen

	move.b	fileflag(a5),d0	Are we downloading?
	cmp.b	#"D",d0		If not,
	bne.s	mainloop		simply continue

	move.l	bufptr(a5),a0	We ARE downloading,
	move.b	d1,(a0)+		..so put next character
	move.l	a0,bufptr(a5)	..into the buffer
	lea.l	buffer(a5),a1	Buffer overflow?
	sub.l	a1,a0		Subtract start buffer frm current buff pos
	cmp.l	#$ffff,a0	Too big(ish)?
	bge	savebuf		Yup, so force the user to save it!

	bra.s	mainloop		One Mo Time!

*-------------------------------------------------------------------------*
* Enter the menu mode from HELP being pressed
trymenu	
	move.w	#xoff,d1	Send XOFF character to stop host waffling
*	bsr	sendser		Temporarily disabled to prevent freezing.

* Menu mode selected, so go display it :
menuagn	
	lea.l	themenu(a5),a0	Display menu message
	bsr	message		etc

	bsr	rdchar		get a key
	cmp.b	#esc,d0		Escape?
	beq	menuexit		.. exits

	and.w	#$df,d0		mask out lower case
	cmp.b	#"H",d0		Help required?
	beq	menuhelp		go for it

	cmp.b	#"E",d0		E for Exit?
	beq	menuexit

	cmp.b	#"Q",d0		Q for Quit?
	beq	exitprog

	cmp.b	#"B",d0		B for Baud rate?
	beq	alterbd

	cmp.b	#"C",d0		C for clear buffer?
	beq	bufclr

	cmp.b	#"D",d0		D for download?
	beq	dodownl

	cmp.b	#"S",d0		S for save buffer?
	beq	savebuf

	cmp.b	#"L",d0		L for Load to buffer?
	beq	loadbuf

	cmp.b	#"I",d0		I for buffer Info?
	beq	showinf

	cmp.b	#"U",d0		U for Upload?
	beq	uplode

	cmp.b	#"X",d0		X for xmodem?
	beq	xmodem

	cmp.b	#"F",d0		F for Freeware?
	beq	freeware

	bra	menuagn		Print the menu again

*-------------------------------------------------------------------------*
menuhelp
	lea.l	helpmes(a5),a0	point to Help message
	bsr	message		.. and print it
	bra	menuagn		.. and back to menu again
menuexit
	move.w	#xon,d1		Ctrl Q to let host resume sending
	bsr	sendser		do it

	lea.l	exitmes(a5),a0	tell user we are
	bsr	message		... exiting the menu
	bra	mainloop		.. and exit!


exitmes	
	dc.b	cr,lf,lf,"Terminal Mode.",cr,lf,lf,0
	even

themenu	
	dc.b	cr,lf,lf," STerminal Extended Menu.",cr,lf
	dc.b	" Press ",34,"H",34," for more extensive help,",cr,lf
	dc.b	" Or: B,C,D,E,F,I,L,Q,S,U,X ?",cr,lf,0
	even

helpmes	
	dc.b	cr,lf,lf
	dc.b	" HELP, - Press a single letter as follows :",cr,lf,lf
	dc.b	" B = Set the baud rate,",cr,lf
	dc.b	" C = Clear the Capture Buffer,",cr,lf
	dc.b	" D = Download text into Capture Buffer,",cr,lf
	dc.b	" E = Exit from here back to terminal mode,",cr,lf
	dc.b	" F = Freeware information notice,",cr,lf
	dc.b	" I = Information about the Buffer,",cr,lf
	dc.b	" L = Load a file into Capture Buffer,",cr,lf
	dc.b	" Q = Quit STerminal,",cr,lf
	dc.b	" S = Save Capture Buffer to a file,",cr,lf
	dc.b	" U = Upload text from Capture Buffer,",cr,lf
	dc.b	" X = Xmodem file transfer (MODEM7).",cr,lf,0
	even

*-------------------------------------------------------------------------*
alterbd	
	lea.l	baudmes(a5),a0	Show user the baudrates available
	bsr	message

	bsr	rdchar		Get a choice
	cmp.b	#cr,d0		Return..?
	beq	exitbd

	cmp.b	#esc,d0		Escape..?
	beq	exitbd		If either, then exit!
	and.w	#$df,d0		Mask out Lower Case

	sub.w	#65,d0		Convert to numeric from ascii
	cmp.w	#15,d0		Too big?
	bgt	alterbd		Repeat it for the hard of hearing!

	bsr	setbaud		Set the baud rate!
exitbd	
	bra	menuagn		Zap back to menu

*-------------------------------------------------------------------------*
baudmes	
	dc.b	cr,lf,lf," Please select one of the following, or",cr,lf
	dc.b	" press RETURN to return to menu :",cr,lf,lf
	dc.b	" A) 19,200",cr,lf
	dc.b	" B)  9,600",cr,lf
	dc.b	" C)  4,800",cr,lf
	dc.b	" D)  3,600",cr,lf
	dc.b	" E)  2,400",cr,lf
	dc.b	" F)  2,000",cr,lf
	dc.b	" G)  1,800",cr,lf
	dc.b	" H)  1,200",cr,lf
	dc.b	" I)    600",cr,lf
	dc.b	" J)    300",cr,lf	<<--== Default!
	dc.b	" K)    200",cr,lf
	dc.b	" L)    150",cr,lf
	dc.b	" M)    134",cr,lf
	dc.b	" N)    110",cr,lf
	dc.b	" O)     75",cr,lf
	dc.b	" P)     50",cr,lf
	dc.b	lf," Your Choice ?",cr,lf,0
	even

cbufmes	
	dc.b	cr,lf,lf," Capture Buffer cleared.",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
* Clear the capture buffer
bufclr	
	lea.l	cbufmes(a5),a0	Point to message
	bsr	message		And print it

	lea.l	buffer(a5),a0	Point to start of buffer
	move.l	a0,bufptr(a5)	Adjust buffer pointer
	bsr	infobuf		Show info about buffer
	bra	menuagn		Back to menu

*-------------------------------------------------------------------------*
* Start a download...
dodownl	
	move.b	fileflag(a5),d0	Are we already downloading?
	cmp.b	#"D",d0		if so, 
	beq.s	down2		Then branch to DOWNLOAD OFF

* Turn downloading ON
	lea.l	dwnmes1(a5),a0	Point to ON message
	bsr	message		print it
	move.b	#"D",fileflag(a5)	signal download ON
	bsr	infobuf		Show capture buffer length
	bra	menuagn		Back to menu

* Turn downloading OFF
down2	
	lea.l	dwnmes2(a5),a0	Point to OFF message
	bsr	message		Print it
	clr.b	fileflag(a5)	Set download flag to OFF
	bsr	infobuf		Show length of capture buffer
	bra	menuagn		Back to menu


dwnmes1	
	dc.b	cr,lf,lf,"Downloading incoming text Now.",cr,lf,lf,0
	even
dwnmes2	
	dc.b	cr,lf,lf,"Okay, I`m not downloading anymore!",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
* Start an upload
uplode	
	move.b	fileflag(a5),d0		Are we uploading already?
	cmp.b	#"U",d0			yes?
	beq	alredu

	move.l	bufptr(a5),a0		If nothing in buffer,
	lea.l	buffer(a5),a1		.. then forget it,
	cmp.l	a0,a1			.. Bub!
	beq	exitu1

	move.b	#"U",fileflag(a5)	Say its an upload!
	lea.l	buffer(a5),a0		Point to start of buffer
	move.l	a0,ubufptr(a5)		Save it!

	lea.l	uplmes1(a5),a0		Uploading message
	bsr	message
exitu1	
	bra	menuagn

alredu	
	clr.b	fileflag(a5)		Cancel Upload!
	lea.l	uplmes2(a5),a0		Cancelled message
	bsr	message
	bra	menuagn

*-------------------------------------------------------------------------*
uplmes1	
	dc.b	cr,lf,lf,"Upload will commence when you exit.",cr,lf,lf,0
	even

uplmes2	
	dc.b	cr,lf,lf,"Upload has been cancelled, Snif.",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
showinf	
	bsr	infobuf		Shop the info,
	bra	menuagn		.. then return

*-------------------------------------------------------------------------*
* Display how many characters in buffer...
infobuf	
	bsr	newline		Start of a new ilne
	move.w	#36,d1		Print a hex $ sign
	bsr	wrchar

	move.l	bufptr(a5),a0	Current buffer pointer...
	lea.l	buffer(a5),a1	start of buffer
	sub.l	a1,a0		Subtract one from tuther,
	move.w	a0,d1		= length of buffer!
	bsr	hexword		And print it

	lea.l	infmes1(a5),a0	.. followed by nice friendly text
	bra	message		print

infmes1	
	dc.b	" characters in Capture Buffer.",cr,lf,0
	even

*-------------------------------------------------------------------------*
* Save file from buffer
savebuf	
	lea.l	savmes1(a5),a0	Tell `em were saving the file
	bsr	message		and print it

	lea.l	buffer(a5),a0	If buffer is empty...
	move.l	bufptr(a5),a1	.. then dont bother...
	cmp.l	a0,a1		.. saving it!
	beq	skipsav

	bsr	infobuf		Show length of buffer
	bsr	askfile		Get a filename
	tst.w	d0		nothing typed?
	beq.s	skipsav		Ignore file save then!

	bsr	savefile		Save actual file
	lea.l	sbufmes(a5),a0	Buffer saved message
	bsr	message		Print it
skipsav	
	bra	menuagn		Back to menu

*-------------------------------------------------------------------------*
* Load file to buffer
loadbuf	
	lea.l	lodmes1(a5),a0	Tell em about it, honeybun
	bsr	message

	bsr	infobuf		Show length of buffer
	bsr	askfile		Get a filename
	tst.w	d0		Nothing typed?
	beq	skiplod

	bsr	loadfile		Load it pronto!
	bsr	infobuf		Show new size of buffer
skiplod	
	bra	menuagn


savmes1	
	dc.b	cr,lf,lf,"Save the Buffer to a diskfile.",cr,lf,0
	even

lodmes1	
	dc.b	cr,lf,lf,"Load a diskfile into the Buffer.",cr,lf,0
	even

filemes	
	dc.b	cr,lf,lf,"Filename ?",0
	even

*-------------------------------------------------------------------------*
freeware
	lea.l	freemes(a5),a0
	bsr	message

	bsr	rdchar
	bra	menuagn

freemes	
	dc.b	cr,lf
  dc.b	"   A limited license is granted to all users of this program to make copies",cr,lf
  dc.b	" of STerminal and distribute them to other users on the following conditions...",cr,lf
  dc.b	" 1.) All Freeware and copyright notices contained in the",cr,lf
  dc.b	"     program are not to be altered or removed.  Anyone doing so may",cr,lf
  dc.b	"     be regarded as a contributory copyright violator.",cr,lf
  dc.b	" 2.) The program is not to be distributed to others in",cr,lf
  dc.b	"     modified form.",cr,lf
  dc.b	" 3.) No fee is to be charged for copying or distributing the",cr,lf
  dc.b	"     program without an express written agreement with Antic",cr,lf
  dc.b	"     Publishing, Inc.",cr,lf
  dc.b	" STerminal is the copyrighted work of Jeremy E. San and is not in the public",cr,lf
  dc.b	" domain.  The author grants permission to users of this program to",cr,lf
  dc.b	" make as many copies of the program as they wish and to give these",cr,lf
  dc.b	" copies to others.  STerminal may also be uploaded to and downloaded from",cr,lf
  dc.b	" free, public BBS' and commercial systems such as Compuserve by subscribers",cr,lf
  dc.b	" so long as the only charge paid by the subscriber is for on-line time and",cr,lf
  dc.b	" there is no charge for the program.  If you have recieved a copy of STerminal",cr,lf
  dc.b	" free, from a source other than Antic, and you find that this program",cr,lf
  dc.b	" is useful, you are invited to make a donation of $6.00 to the author.",cr,lf
  dc.b	"  The donation is voluntary and should not be considered payment for software",cr,lf
  dc.b	" or services.  The author is:",cr,lf
  dc.b	"             Jeremy E. San",cr,lf
  dc.b	"             129,  The Broadway",cr,lf
  dc.b	"             Mill Hill,  London",cr,lf
  dc.b	"             NW7  4RN,  England",0
	even

*-------------------------------------------------------------------------*
* Flush the serial input buffer, in 1 easy lesson
flushser
	bsr	scanser
	bpl.s	flushser
	rts

*-------------------------------------------------------------------------*
* Xmodem file transfer bits...
xmodem	
	lea.l	xmes1(a5),a0
	bsr	message

	bsr	rdchar
	and.w	#$df,d0

	cmp.b	#"U",d0
	beq	xmodemup
	cmp.b	#"D",d0
	beq	xmodemdn
	bra	menuagn

xmes1	
	dc.b	cr,lf,lf,"Xmodem transfer, <U>pload or <D>ownload ?",cr,lf,0
	even

upmes1	
	dc.b	cr,lf,"Waiting for receiver...",cr,lf,0
	even

uperr1	
	dc.b	cr,lf,"Receiver not happy, retrying...",cr,lf,0
	even

updun1	
	dc.b	cr,lf,"File transferred safely.",cr,lf,0
	even


*-------------------------------------------------------------------------*
* Send file using Xmodem...
xmodemup
	bsr	warnmess
	lea.l	buffer(a5),a4		start of buffer
	moveq	#1,d2			block number in d2, default=1

* Start by waiting for an initial NAK from the receive side.
xmodeup0
	lea.l	upmes1(a5),a0
	bsr	message

	move.w	#12,d6			timeout
	bsr	waitser			wait for a char for a bit?
	bmi.s	xsendblk

	cmp.b	#nak,d0			any luck?
	bne.s	xmodeup0

* Check for End of File here...
xsendblk
	bsr	scankey			does user want to cancel?
	bne	xcancel			yup

	move.l	bufptr(a5),a0		are we at end of buffer!?
	cmpa.l	a4,a0
	ble	finxup			show an end of file, if we are

* Send a block, Xmodem fashion...
	bsr	prblock
	clr.b	d3			checksum
	move.b	#soh,d1			start of block
	bsr	sendser
	move.b	d2,d1			block number
	bsr	sendser
	move.b	d2,d1
	not.b	d1			invert it to be sure
	bsr	sendser
	move.w	#127,d4			counter for number of bytes
xmodeulp
	move.b	(a4)+,d1		get a byte
	add.b	d1,d3			compute checksum
	bsr	sendser			send it
	dbra	d4,xmodeulp		and go back for more
	move.b	d3,d1			send checksum
	bsr	sendser

wait10s	
	move.w	#10,d6			wait 10 secs...
	bsr	waitser
	bmi.s	upnogood

	cmp.b	#ack,d0			acknowledged.. whee...
	beq.s	upgonext

	cmp.b	#can,d0			cancelled, hmmm!
	beq.s	xcancel

	cmp.b	#nak,d0
	bne.s	wait10s

upnogood
	lea.l	uperr1(a5),a0
	bsr	message
uretry	
	sub.l	#128,a4			subtract a block number and retry
	bra.s	xsendblk

upgonext
	addq.b	#1,d2
	bra.s	xsendblk

finxup	
	move.b	#eot,d1			send end of file control
	bsr	sendser

finxup1	
	move.w	#10,d6
	bsr	waitser
	bmi.s	finxup

	cmp.b	#ack,d0			did they accept?
	beq.s	finxup2

	bra.s	finxup1

finxup2	
	lea.l	updun1(a5),a0
	bsr	message
	bra	menuagn

*-------------------------------------------------------------------------*
xcancel	
	lea.l	cancmes(a5),a0
	bsr	message
	bsr	rdchar
	bsr	newline
	and.w	#$df,d0
	cmp.b	#"Y",d0
	beq	uretry

	move.b	#can,d1
	bsr	sendser
	bra	menuagn

*-------------------------------------------------------------------------*
xrcancel
	lea.l	cancmes(a5),a0
	bsr	message
	bsr	rdchar
	bsr	newline
	and.w	#$df,d0
	cmp.b	#"Y",d0
	beq	xreclp0		with Nak

	move.b	#can,d1
	bsr	sendser
	bra	menuagn

cancmes	
	dc.b	cr,lf,"For some reason, the transfer has been Cancelled."
	dc.b	cr,lf,"Bearing in mind that this could have been line"
	dc.b	cr,lf,"noise, you may press Y to continue, or any other"
	dc.b	cr,lf,"key to abort this transfer.",cr,lf,lf,0
	even

rstart1	
	dc.b	cr,lf,lf,"Initiating the transfer (NAK sent).",cr,lf,0
	even

ret1mes	
	dc.b	cr,lf,"No response, re-requesting block.",cr,lf,0
	even

*-------------------------------------------------------------------------*
xmodemdn
	bsr	warnmess
	lea.l	buffer(a5),a4

	moveq	#1,d2			block number default
	lea.l	rstart1(a5),a0
	bsr	message

* Send initial NAK
xreclp0	
	move.b	#nak,d1			send a NAK
	bsr	sendser

xreclp1a
	bsr	scankey
	bne	xrcancel

	move.w	#12,d6			wait for block...
	bsr	waitser
	bpl.s	xrecok1			keep doing it, if nothing going

	lea.l	ret1mes(a5),a0		print up retry message
	bsr	message
	bra.s	xreclp0

xrecok1	
	cmp.b	#soh,d0			start of block coming in?
	beq.s	xrecrcv

	cmp.b	#eot,d0			end of file?
	beq	xreceot

	cmp.b	#can,d0
	beq	xrcancel

	bra.s	xreclp1a

* Block coming in...
xrecrcv	
	bsr	prblock
	move.w	#6,d6		get block number
	bsr	waitser
	bmi	xrslowr

	cmp.b	d0,d2		same?
	bne	xrbadblk	was a bad, or previously-repeated block

	move.w	#6,d6		get inverse block number
	bsr	waitser
	bmi	xrslowr

	not.b	d0
	cmp.b	d0,d2		okay?
	bne	xrbadbl2	definitely a bad block, not a repeat

* Get the 128 data bytes
	move.w	#127,d4		byte count
	clr.b	d3		checksum
xrecrclp
	move.w	#6,d6		timeout for each character
	bsr	waitser
	bmi.s	xrecnop3	missed a character, perhaps!?

	move.b	d0,(a4)+	store it
	add.b	d0,d3		compute checksum
	dbra	d4,xrecrclp	loop back for more

	move.w	#6,d6
	bsr	waitser		get checksum
	bmi.s	xrcheckm	not good?

	cmp.b	d0,d3		checksum any good?
	bne.s	xrchecks

* Block was okay, so increment block number and go on...
	addq.b	#1,d2
	bsr	sendack
	bra	xreclp1a

* A character was missed from inside a block
xrecnop3
	lea.l	misschm(a5),a0
	bsr	message
	addq.w	#1,d4		adjust for partly inside a block
	ext.l	d4
	add.l	d4,a4
	sub.l	#128,a4
	bsr	waitfin
	bra	xreclp0

* Missed checksum
xrcheckm
	lea.l	xchksm2(a5),a0
	bsr	message

xrchecks
	sub.l	#128,a4		backtrack some bytes
	lea.l	xchksm(a5),a0
	bsr	message
	move.b	d3,d1		real checksum
	bsr	hexbyte
	lea.l	xchksm1(a5),a0
	bsr	message
	move.b	d0,d1
	bsr	hexbyte
	bsr	newline
	bsr	waitfin
	bra	xreclp0		and go back for more, with a Nak!

xrslowr	
	bsr	waitfin		Does not need any backtracking of a4
	lea.l	slowm1(a5),a0
	bsr	message
	bra	xreclp0

*-------------------------------------------------------------------------*
xrbadblk
	addq.b	#1,d1		check for previous block being repeated
	cmp.b	d1,d2		are they the same now?
	beq.s	xrbbb1
xrbadbl2
	bsr	waitfin		must have been a genuine bad block
	lea.l	badblkm(a5),a0
	bsr	message
	bra	xreclp0

* If previous block was repeated, then do an ACK to get it up to date
xrbbb1	
	bsr	sendack		and go back for more
	bra	xreclp1a	dont send NAK

*-------------------------------------------------------------------------*
xreceot	
	move.b	#ack,d1
	bsr	sendser
	move.l	a4,bufptr(a5)	reflect new buffer value

	lea.l	xrecm2(a5),a0
	bsr	message

	bra	menuagn


xrecm2	
	dc.b	cr,lf,"File downloaded successfully.",cr,lf,lf,0
	even

slowm1	
	dc.b	cr,lf,"Slow (or not enough) response.",cr,lf,0
	even

badblkm	
	dc.b	cr,lf,"Bad block received.",cr,lf,0
	even

misschm	
	dc.b	cr,lf,"Missed character in block.",cr,lf,0
	even

xchksm	
	dc.b	cr,lf,"Checksum Error, should be $",0
	even

xchksm1	
	dc.b	", was $",0
	even

xchksm2	
	dc.b	cr,lf,"Checksum missing.",cr,lf,0
	even

*-------------------------------------------------------------------------*
sendack	
	move.b	#ack,d1
	bra	sendser

waitfin	move.w	#2,d6		wait until entire block is sent
	bsr	waitser
	bpl.s	waitfin

	rts

*-------------------------------------------------------------------------*
warnmess
	lea.l	warnmes(a5),a0
	bra	message

warnmes	
	dc.b	cr,lf,lf,"To exit: hit a key, and be patient.",cr,lf,lf,0
	even


*-------------------------------------------------------------------------*
* Print up a block...
prblock	
	movem.l	d0-a6,-(sp)
	lea.l	pblokm(a5),a0
	bsr	message
	move.w	d2,d1
	bsr	hexbyte
	move.b	#cr,d1		do a carriage ret ONLY to keep on same line
	bsr	wrchar
	movem.l	(sp)+,d0-a6
	rts

pblokm	
	dc.b	"Current block $",0
	even

*-------------------------------------------------------------------------*
askfile	
	lea.l	filemes(a5),a0	Point to message
	bsr	message		print it
	bsr	getline		gets a line of text, in our case a filename
	clr.l	d0		Zero the counter
	move.b	ibuff+1(a5),d0	How many characters typed?
	beq	endfile		Exit now!

	lea.l	whatfile(a5),a0	Point to filename
	lea.l	ibuff+2(a5),a1	Point to input buffer text
	subq.w	#1,d0		decrement count ready for a dbra
copyfn	
	move.b	(a1)+,(a0)+	Copy input buffer to filename buffer
	dbra	d0,copyfn	continue with loop

	clr.b	(a0)+		Set the terminator to NULL
	moveq	#$ff,d0		Set TRUE flag
endfile	
	rts			And zzzap!

*-------------------------------------------------------------------------*
loadfile
	bsr	openrd		Open file for reading
	tst.l	d0
	bmi.s	exitlod		Did it open ok?

	bsr	rdfile		Read it
	bra	closfile	Close it

exitlod	
	lea.l	lodmes(a5),a0	point to error mess
	bra	message


lodmes	
	dc.b	cr,lf,lf,"You sure it exists??",cr,lf
	dc.b	"I`m having trouble locating it!",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
savefile
	bsr	createit	Create file if necessary
	tst.l	d0		If error, must already exist..
	bpl.s	notexist

	bsr	openwrt		File xfer, the idjut way!
	tst.l	d0		Did file open ok?
	bmi.s	exitsav
notexist
	bsr	wrtfile		write the file
	bra	closfile	Close it now!

exitsav	
	lea.l	ferrmes(a5),a0	Show a file error
	bra	message


ferrmes	
	dc.b	cr,lf,lf,"File Error, not saved!",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
createit
	move.w	#0,-(sp)	zero attributes, for a normal file
	pea	whatfile(a5)	address of filename
	move.w	#$3c,-(sp)	code to create a file
	trap	#1		GEMDOS Bios
	move.w	d0,handle(a5)	Remember handle reference
	addq.l	#8,sp		Correct stack
	rts			Ignore errors, cos I dont give-a-damn!

*-------------------------------------------------------------------------*
openrd	
	move.w	#0,-(sp)	open for read
	pea	whatfile(a5)	Address of filename
	move.w	#$3d,-(sp)	code for open
	trap	#1		GEMDOS Bios
	move.w	d0,handle(a5)	File reference
	addq.l	#8,sp		Correct stack
	rts			Dun!

*-------------------------------------------------------------------------*
openwrt	
	move.w	#1,-(sp)	Means open for WRITE
	pea	whatfile(a5)	Address of filename
	move.w	#$3d,-(sp)	Code for `open`
	trap	#1		GEMDOS Bios function
	move.w	d0,handle(a5)	file reference returned
	addq.l	#8,sp		Correct Stack
	rts			Powee!

*-------------------------------------------------------------------------*
rdfile	
	pea	buffer(a5)	Address of where to put it!
	move.l	#$7f00,-(sp)	Number of bytes (max) to read
	move.w	handle(a5),-(sp) File reference
	move.w	#$3f,-(sp)	Code for READ FILE
	trap	#1		GEMDOS Bios
	add.l	#12,sp		Correct stack
	tst.l	d0		How many bytes?
	bmi	exitrd		.. or file error

	add.l	d0,bufptr(a5)	update buffer size to new value
exitrd	
	rts

*-------------------------------------------------------------------------*
wrtfile	
	pea	buffer(a5)	Address of start of file
	lea.l	buffer(a5),a1	Determine length
	move.l	bufptr(a5),a0
	sub.l	a1,a0		File`s length
	move.l	a0,-(sp)	stack it
	move.w	handle(a5),-(sp) File`s reference code
	move.w	#$40,-(sp)	Code for Write File
	trap	#1		GEMDOS Bios
	add.l	#12,sp		Correct Stack
	rts			Dunit, sire!

*-------------------------------------------------------------------------*
closfile
	move.w	handle(a5),-(sp) What file was dat?
	move.w	#$3e,-(sp)	Code for CLOSE
	trap	#1		GEMDOS Bios
	addq.l	#4,sp		Correct Stack
	rts			now what?

sbufmes	
	dc.b	cr,lf,"Buffer Saved.",cr,lf,lf,0
	even

*-------------------------------------------------------------------------*
* Welcome message
welcome	
	dc.b	" ----------------------------------------",cr,lf
	dc.b	" STerminal VT52 3.0,     By Jeremy E. San",cr,lf,lf
	dc.b	" Freeware from Antic - the Atari Resource",cr,lf,lf
	dc.b	" Copyright 1985 -- Argonaut Software Ltd.",cr,lf,lf
	dc.b	" Press HELP for the Extended Menu.       ",cr,lf
	dc.b	" ----------------------------------------",cr,lf,lf,0
	even

* Exit current program and Return to GEM/desktop...
exitprog
	bsr	newline		Give a carriage Return
	move.w	#0,-(sp)		code for `exit`
	clr.l	d0		Not sure I need this in? but just in case!
	trap	#1		GEMDOS Bios

* Shouldn`t ever get to here:
	addq.l	#2,sp		Correct stack in case it ever gets here!
	rts			Unnecessary, but -- just in case!
*				Ya never know, with these ATARI...
*				...(hehehe) products!

*-------------------------------------------------------------------------*
* Initialise various bits of memory etc ....
* Entry: Nothing special
* Exit: Sets up hardware registers, if needed, and other things.
init	
	move.w	#brate,d0		Default baudrate = 300
	bsr	setbaud			Set it
	lea.l	buffer(a5),a0		Default buffer pointer
	move.l	a0,bufptr(a5)		ie: clear buffer

	move.w	#esc,d1			Set auto-wrap to occur
	bsr	wrchar
	move.w	#$76,d1			...in Atari VT52 mode
	bsr	wrchar
	move.w	#esc,d1			clear the screen
	bsr	wrchar
	move.w	#"E",d1
	bsr	wrchar			... and return
	bra	flushser			get rid of extraneous data

*-------------------------------------------------------------------------*
* Wait for a character from the TOS console (keyboard)
* Entry: Nothing special
* Exit: Keyboard character in d0.b  Also possible register loss
rdchar	
	movem.l	d1-a6,-(sp)	Save all reggies
	move.w	#1,-(sp)		Get character from keyboard via BIOS
	trap	#1		GEMDOS Bios call
	addq.l	#2,sp		Correct Stack
	movem.l	(sp)+,d1-a6	Get Dem reggies
	rts			Yahooo!

*-------------------------------------------------------------------------*
* Prints up a message pointed to by a0.  Terminated by a 0.
* Entry: a0 = point to start of text.
* Exit: No register damage
message	
	movem.l	d1/a0,-(sp)		Save reggies
	clr.w	d1			Clear a word
messag2	
	move.b	(a0)+,d1		Get a character
	beq.s	mesfin			Terminator=0?
	
	bsr.s	wrchar			Display it
	bra.s	messag2			.. and loop back for more
mesfin	
	movem.l	(sp)+,d1/a0		Restore reggies
	rts				Zapow!

*-------------------------------------------------------------------------*
* Write a character in to console using TOS.
* Entry: d1 = character to display
* Exit: No register damage (methinks: movem overkill!?)
wrchar	
	movem.l	d0-d7/a0-a6,-(sp)	Save all known reggies
	move.w	d1,-(sp)		Stack character to be printed
	move.w	#2,-(sp)		Code for Write Character
	trap	#1			GEMDOS Bios
	addq.l	#4,sp			Correct the Stack
	movem.l	(sp)+,d0-d7/a0-a6	Restore Dem Dere Reggies
	rts				Wheee

*-------------------------------------------------------------------------*
scankey	
	move.w	#$0b,-(sp)		Is a key pending?
	trap	#1			GEMDOS Bios
	addq.l	#2,sp			Correct Stack
	tst.l	d0			Any key in buffer?
	bpl.s	skipkey			Nope, so quit while going`s good!
getkey	
	move.w	#$07,-(sp)		Get a key from buff without echo!
	trap	#1			GEMDOS Bios
	addq.l	#2,sp			Correct Stack
	rts				Return the key pressed

skipkey	
	moveq	#0,d0			Signal No key pressed
	rts				.. and exit.

*-------------------------------------------------------------------------*
* Enter with d6 = to number of seconds to wait...
waitser	
	subq.w	#1,d6
waitser1
	move.w	#10000,d7		wait for char for one second
waitser2
	bsr	scanser
	dbpl	d7,waitser2
	
	bpl.s	retwait1
	
	dbra	d6,waitser1
retwait1
	rts

*-------------------------------------------------------------------------*
* Scans for input from the serial port, returns with d0=0 if nothing!
scanser	
	move.w	#1,-(sp)		Code for serial port
	move.w	#1,-(sp)		Code for Pending?
	trap	#13		Is a char waiting in serial port?
	addq.l	#4,sp		Correct Stack
	tst.l	d0		Yes...?
	bpl.s	skipser		Nope, snif!

	move.w	#1,-(sp)		Serial port code
	move.w	#2,-(sp)		Code for Get character
	trap	#13		Extended Bios function
	addq.l	#4,sp		Correct Stack
	rts			Dun!

skipser	
	moveq	#-1,d0		Signal no character there
	rts			.. and go back again

*-------------------------------------------------------------------------*
* Sends character in d1 to serial port
sendser	
	move.w	d1,-(sp)		Stack character to be sent
	move.w	#4,-(sp)		Code for SEND SERIAL
	trap	#1		GEMDOS Bios call
	addq.l	#4,sp		Correct Stack
	rts			Dun!


*-------------------------------------------------------------------------*
* gets a line of text via BIOS
getline	
	pea	ibuff(a5)	Point to input buffer
	move.b	#32,ibuff(a5)	maximum of 32 characters
	move.w	#$0a,-(sp)	code for get a line
	trap	#1		GEMDOS BIOS
	addq.l	#6,sp		Correct stack
	rts

*-------------------------------------------------------------------------*
* Hex printout routines,
* Entry: Prints hex string of d1.w as hexascii digits.
* Exit: No register damage.
hexbyte	
	move.w	d1,-(sp)	Stack our byte
	bra.s	dobyte		Print up just a byte-long
hexlong	
	swap	d1		Get top word at bottom
	bsr	hexword		Print up top word
	swap	d1		Get low word again to fall into hexword
hexword	
	move.w	d1,-(sp)		Stack our Word
	lsr.w	#8,d1		Shift word 12 places to right
	lsr.w	#4,d1		. . .
	bsr.s	hexnibbl		Print a nybble
	move.w	(sp),d1		Get
	lsr.w	#8,d1		 next
	bsr.s	hexnibbl	    	  digit...
dobyte	
	move.w	(sp),d1		Print
	lsr.w	#4,d1		 up
	bsr.s	hexnibbl	    	  a
	move.w	(sp)+,d1	    	   byte
hexnibbl	and.w	#15,d1		Mask useless contents
	cmp.b	#9,d1		Is it a non numeric digit?
	bls.s	hexnib2		Yes, so dont correct for ALpha
	
	add.b	#7,d1		Skip symbols in ASCII, to get alphas
hexnib2	
	add.b	#$30,d1		Convert to ASCII from numeric
	bra	wrchar		Prnit character


*-------------------------------------------------------------------------*
* Print a SPACE.  Corrupts d1
dospace	
	move.w	#32,d1		Dats a SSSSpace?
	bra	wrchar		Print it!

*-------------------------------------------------------------------------*
* Print a carriage return and a linefeed.  Corrupts d1
newline	
	move.w	#cr,d1		Carriage Return, folks
	bsr	wrchar		Print
	move.w	#lf,d1		Line Feed
	bra	wrchar		Print

*-------------------------------------------------------------------------*
* Sets the baud rate :
setbaud	
	move.w	#-1,-(sp)		scr
	move.w	#-1,-(sp)		tsr
	move.w	#-1,-(sp)		rsr
	move.w	#-1,-(sp)		ucr	
	move.w	#-1,-(sp)		flowctrl
	move.w	d0,-(sp)			baud rate

	move.w	#15,-(sp)		Code for rsconf
	trap	#14			Extended Atari function
	add.w	#14,sp			Correct Stack

	rts

*-------------------------------------------------------------------------*
* Storage locations and other misc variables...

whatfile
	dc.b	"SERIAL.TXT"
	even
	dc.l	0,0,0,0,0,0,0,0,0,0,0,0	< Buffer space!

*-------------------------------------------------------------------------*
* Long words

bufptr	
	dc.l	buffer	Pointer to current buffer position
ubufptr	
	dc.l	buffer	Uploading buffer pointer

*-------------------------------------------------------------------------*
* Words
handle	
	dc.w	0	Filename handle (reference code)

*-------------------------------------------------------------------------*
* Bytes
fileflag 
	dc.b	0	Uploading/Downloading flag?
	even

	bss
	even

*-------------------------------------------------------------------------*
	ds.l	256	256 stack entries
ustk	
	ds.l	1	^ Local Stack area (goes backwards)
ibuff	
	ds.b	82	80 byte input buffer
buffer	
	ds.b	65536	64k`s worth of capture buffer
	even

	end
dddddddddddddddddddddddddddd