*
*	PANEL.S   Cockpit Graphics Routines for ST StarRaiders
*		copyright 1985 ATARI Corp.
*
	.text
*
*	PUBLIC SYMBOLS
*
	.globl	linanit
	.globl	billboard
	.globl	billbadd
	.globl	blbtimer		* Slight Perversion
	.globl	timesqar
	.globl	timsqinit
	.globl	timsqadd
	.globl	text_blt
	.globl	deadpanel
	.globl	dopanel
	.globl	wall_blt
	.globl	wordcopy
	.globl	xformpts

	.globl	surgebzy
	.globl	lifebzy
	.globl	shieldbzy
	.globl	mainbzy
	.globl	aftgundmg
	.globl	aftgunchrg
	.globl	stardate
	.globl	energy
	.globl	radiobzy
	.globl	kills
	.globl	hyperon
	.globl	warpdmg
	.globl	shipspeed
	.globl	shieldon
	.globl	shieldmg
	.globl	shldefct
	.globl	computon
	.globl	computbzy
	.globl	lgundmg
	.globl	lgunchrg
	.globl	rgundmg
	.globl	rgunchrg
	.globl	nonuke
	.globl	nukerdy
	.globl	viewing
	.globl	aftvdmg
	.globl	scandmg
	.globl	xcursor
	.globl	ycursor
	.globl	freshmap


*
*	SUBROUTINE AREA
*

*
*	LINANIT	  LINE-A Init. Get ptr to 8x8 Font.
*
*	Given:
*		control
*
*	Returns:
*		w/ FONTPTR initialized
*
*	Register Usage:
*		destroys a0-a2 and d0-d2
*
*	Externals:
*		LINE-A
*
linanit:
	.dc.w	$a000		* LINE-A Init call, a1 = ptr to array of ptrs
	move.l	4(a1),a0	* a1 = ptr to 8x8 font
	move.l	76(a0),fontptr	* fontptr = ptr to 8x8 Font Data
	rts


*
*	BILLBOARD   Build/Maintain a Billboard Message.
*
*	Given:
*		control
*
*	Returns:
*		w/ message window updated in current buffer
*
*	Register Usage:
*		destroys a0-a3 and d0-d6 ??
*
*	Externals:
*		text_blt
*
billboard:
	tst	blbactive
	bmi	bilxit		* IF (Billboard Active) THEN
	bne	bilnew		* IF (Sustaining a Message) THEN
	subq	#1,blbtimer
	bpl	bilxit		* Count Timer
	move	#0,d0
	jsr	billbadd	* Turn Off Billboard
	move	#$7fff,blbtimer	* .. That Should Keep 'em Busy
	bra	bilxit
bilnew:	movea.l	#billmsgs,a0	* ELSE Adding a New Message
	move	blbmess,d2
	move	d2,d0
	and	#$0fff,d0
	add	d0,d0
	add	d0,d0		* d0 = index into message table
	move.l	(a0,d0),a0	* a0 = ptr to message
	rol	#4,d2
	and	#$0f,d2		* d2 = color
	move	#96,d0
	move	#4,d1
	clr	d3
	jsr	text_blt	* REPLACE text into current buffer 
	subq	#1,blbactive
bilxit:
	rts


*
*	BILLBADD   Initialize a Billboard Message.
*
*	Given:
*		d0 =  Message Color/Number
*
*	Returns:
*		w/ flags set to initiate a Billboard message.
*
*	Register Usage:
*		destroys a0 and d0
*
*	Externals:
*		none
*
billbadd:
	move	d0,blbmess
	tst	tsqactive
	beq	bilb0
	jsr	timsqinit	* Kill the TimesSquare Display (Cleanly)
bilb0:	move	#$100,blbtimer
	move	#2,blbactive	* start the BillBoard
	rts


*
*	TIMESQAR   Maintain and Scroll a Times-Sqare Message.
*
*	Given:
*		control
*
*	Returns:
*		w/ message window updated in current buffer
*
*	Register Usage:
*		destroys a0-a3 and d0-d6 ??
*
*	Externals:
*		rpltext
*
timesqar:
	tst	tsqactive
	beq	tsqexit		* IF (Times-Square Display Active) THEN
	tst	tsqscroll
	bne	tsqnorml	* IF (Time to Add New Text) THEN

	movea.l	#tsqbuffer,a0
	move	#70,d0		* FOR (280 words) DO
tsqrlp:	move.l	8(a0),(a0)+	* Scroll Everything Two Chars
	move.l	8(a0),(a0)+
	dbra	d0,tsqrlp

	move	tsqmsgs,d0
	beq	tsqnulls	* IF (Real Message Displaying) THEN
	clr	tsqblanks	* not a blank string
	move	d0,d1
	rol	#4,d0
	and	#$0f,d0		* d0 = text color
	and	#$0fff,d1
	asl	#2,d1
	movea.l	#msgtbl,a0
	move.l	(a0,d1),a1
	adda	tsqstrptr,a1	* a1 = ptr to new text string
	move.b	(a1)+,tsqtemp
	move.b	(a1)+,tsqtemp+1
	bne	tsqr1
	move.b	#$20,tsqtemp+1	* force strings to Even Length
	bra	tsqr2		* and this ones done
tsqr1:	tst.b	(a1)
	beq	tsqr2		* IF (text yet remaining)
	addq	#2,tsqstrptr	* THEN count some used
	bra	tsqrjn
tsqr2:	clr	tsqstrptr	* ELSE clear the offset count
	movea.l	#tsqmsgs,a0
	move	#6,d1
tsqr3:	move	2(a0),(a0)+	* Bump all Messages Up one
	dbra	d1,tsqr3
	clr	(a0)		* and replace with zeroes
tsqrjn:
	move	#64,textwide
	movea.l	#tsqtemp,a0
	movea.l	#tsqbuffer+64,a1
	jsr	rpltext		* Build new text into Image Buffer
	bra	tsqnorml	* .. and do a normal scroll

tsqnulls:			* ELSE Pad-Out with Blanks
	move	tsqblanks,d0
	cmp	#9,d0
	blt	tsqpad		* IF (full of blanks)
	clr	tsqactive	* THEN Turn-Off Display
	rts
tsqpad:	addq	#1,tsqblanks	* ELSE pad with two more blanks
	movea.l	#tsqbuffer,a0
	move	#7,d0
tsqplp:	adda.l	#64,a0		* FOR (all 8 lines)
	clr.l	(a0)+
	clr.l	(a0)+		* Clear 2 chars worth of display
	dbra	d0,tsqplp
*				  .. Fall Thru to Normal Scrolling ..

tsqnorml:			* Do a normal Scrolling blt
	movea.l	#tsqbuffer,a0	* a0 = ptr into our source buffer
	move	tsqscroll,d0	* d0 = shift count
	movea.l	screen,a1
	adda	#(4*160)+48,a1	* a1 = ptr to message window
	moveq	#7,d3
timsqhi:			* FOR (message height) DO
	move.l	a0,a2
	move.l	a1,a3		* local copies of ptrs
	moveq	#31,d2
timsqwid:			* FOR (message width*4planes) DO
	move	(a2),d1
	swap	d1
	move	8(a2),d1
	addq	#2,a2
	asl.l	d0,d1
	swap	d1		* d1 = scrolled data
	move	d1,(a3)+
	dbra	d2,timsqwid

	adda	#(18*4),a0
	adda	#160,a1		* bump pointers to next line
	dbra	d3,timsqhi

	addq	#1,tsqscroll
	and	#$0f,tsqscroll	* count a bit scrolled

tsqexit:
	rts


*
*	TIMSQADD   Add a Message to the Times-Square Message Buffer
*
*	Given:
*		d0 = message color/message number
*			(hi-nybble = color, rest is message number)
*
*	Returns:
*		w/ TSQMSGS updated
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
timsqadd:
	move	#-1,blbactive	* Stop the Billboard
	move	#1,tsqactive	* Start The TimeSquare Display!
	clr	d1
	movea.l	#tsqmsgs,a0
tsqaddlp:
	tst	(a0,d1)		* IF (this slot free)
	bne	tsqad1
	move	d0,(a0,d1)	* THEN add the new message here
	rts
tsqad1:	addq	#2,d1
	cmp	#16,d1
	blt	tsqaddlp	* UNTIL (all slots tried)
	rts			* Oh Well ..


*
*	TIMSQINIT   Initialize Times-Square Variables
*
*	Given:
*		control
*
*	Returns:
*		w/ Times-Square Vars initialized
*
*	Register Usage:
*		destroys a0 and d0
*
*	Externals:
*		none
*
timsqinit:
	move	#-1,blbactive	* Kill the Billboard for Spite
	clr	tsqactive
	clr	tsqscroll
	clr	tsqblanks
	clr	tsqstrptr
	clr.l	tsqtemp		* clear all random vars
	movea.l	#tsqmsgs,a0
	move	#3,d0
tsqin1:	clr.l	(a0)+		* no messages pending
	dbra	d0,tsqin1
	movea.l	#tsqbuffer,a0
	move	#143,d0
tsqin2:	clr.l	(a0)+		* blank the display buffer
	dbra	d0,tsqin2
	rts


*
*	TEXT_BLT   Special Case Text-blt of 8x8 Font to Word-Aligned Boundary
*
*	Given:
*		d0 = Screen Xpos (must be word-aligned)
*		d1 = Screen Ypos
*		d2 = Color of Text (0-F)
*		d3 = Mode flag (0=Total Replacement)
*		a0 = ptr to Text String
*
*	Returns:
*		w/ Screen updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		rpltext,overtext
*
text_blt:
	move	#152,textwide
	movea.l	#x160tbl,a1
	add	d1,d1
	move	(a1,d1),d1		* d1 = line offset into screen(bytes)
	movea.l	screen,a1
	and	#$0fff0,d0		* force word-alignment on Xpos
	lsr	#1,d0			* d0 = byte offset within line
	add	d0,d1
	adda	d1,a1			* a1 = ptr to display memory
	move	d2,d0			* d0 = color requested
	tst	d3
	beq	rpltext
	bra	overtext		* select drawing mode and exit thru it


*
*	RPLTEXT   REPLACING Text-blt of 8x8 Font to Word-Aligned Boundary
*
*	Given:
*		d0 = Color of Text (0-F)
*		a0 = ptr to Text String (zero terminated)
*		a1 = ptr to Destination Memory
*		TEXTWIDE = width of destination form
*
*	Returns:
*		w/ Screen updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d4
*
*	Externals:
*		none
*
rpltext:
	movea.l	fontptr,a2	* a2 = ptr to Font Data
rplstring:
	clr	d1
	move.b	(a0)+,d1
	beq	rtxtexit
	clr	d2
	move.b	(a0)+,d2
	beq	rpllast		* WHILE (two or more characters remain) DO
	move.l	a1,a3		* a3 = ptr to Destination
	move	#7,d4
rpltxtlp:			* FOR (8 lines) DO
	move.b	(a2,d1),d3	* d3 = char1 data
	asl	#8,d3
	move.b	(a2,d2),d3	* d3 = combined char data
	btst	#0,d0
	bne	rtxt0
	clr	(a3)+
	bra	rtxt1
rtxt0:	move	d3,(a3)+	* add charstamp to plane0
rtxt1:	btst	#1,d0
	bne	rtxt2
	clr	(a3)+
	bra	rtxt3
rtxt2:	move	d3,(a3)+	* add charstamp to plane1
rtxt3:	btst	#2,d0
	bne	rtxt4
	clr	(a3)+
	bra	rtxt5
rtxt4:	move	d3,(a3)+	* add charstamp to plane2
rtxt5:	btst	#3,d0
	bne	rtxt6
	clr	(a3)+
	bra	rtxt7
rtxt6:	move	d3,(a3)+	* add charstamp to plane3
rtxt7:	adda	textwide,a3
	add	#$100,d1
	add	#$100,d2	* bump all pointers
	dbra	d4,rpltxtlp
	addq.l	#8,a1		* bump destination ptr
	bra	rplstring

rpllast:			* one character remains to be done
	move	#7,d4
rtxtlast:			* FOR (eight lines) DO
	move.b	(a2,d1),d2
	asl	#8,d2		* d2(hi) = character data
	move	(a1),d3
	and	#$0ff,d3	* d3(lo) = screen data
	btst	#0,d0
	beq	rtxtl0
	or	d2,d3
rtxtl0:	move	d3,(a1)+	* add charstamp to plane0
	move	(a1),d3
	and	#$0ff,d3	* d3(lo) = screen data
	btst	#1,d0
	beq	rtxtl1
	or	d2,d3
rtxtl1:	move	d3,(a1)+	* add charstamp to plane1
	move	(a1),d3
	and	#$0ff,d3	* d3(lo) = screen data
	btst	#2,d0
	beq	rtxtl2
	or	d2,d3
rtxtl2:	move	d3,(a1)+	* add charstamp to plane2
	move	(a1),d3
	and	#$0ff,d3	* d3(lo) = screen data
	btst	#3,d0
	beq	rtxtl3
	or	d2,d3
rtxtl3:	move	d3,(a1)+	* add charstamp to plane3
	add	#$100,d1
	adda	textwide,a1	* bump pointers to new data
	dbra	d4,rtxtlast
rtxtexit:
	rts


*
*	OVERTEXT   OVERLAYING Text-blt of 8x8 Font to Word-Aligned Boundary
*
*	Given:
*		d0 = Color of Text (0-F)
*		a0 = ptr to Text String
*		a1 = ptr to Destination Memory
*		TEXTWIDE = width of destination form
*
*	Returns:
*		w/ Screen updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		none
*
overtext:
	movea.l	fontptr,a2	* a2 = ptr to Font Data
overstring:
	clr	d1
	move.b	(a0)+,d1
	beq	overexit
	clr	d2
	move.b	(a0)+,d2
	beq	overlast	* WHILE (two or more characters remain) DO
	move.l	a1,a3		* a3 = ptr to Destination
	move	#7,d6
ovrtxtlp:			* FOR (8 lines) DO
	move.b	(a2,d1),d3	* d3 = char1 data
	asl	#8,d3
	move.b	(a2,d2),d3	* d3 = combined char data
	move	d3,d4
	eor	#$0ffff,d4	* d4 = combined char mask
	move	(a3),d5
	and	d4,d5		* d5 = masked screen data
	btst	#0,d0
	beq	ovtxt0
	or	d3,d5
ovtxt0:	move	d5,(a3)+	* add charstamp to plane0
	move	(a3),d5
	and	d4,d5		* d5 = masked screen data
	btst	#1,d0
	beq	ovtxt1
	or	d3,d5
ovtxt1:	move	d5,(a3)+	* add charstamp to plane1
	move	(a3),d5
	and	d4,d5		* d5 = masked screen data
	btst	#2,d0
	beq	ovtxt2
	or	d3,d5
ovtxt2:	move	d5,(a3)+	* add charstamp to plane2
	move	(a3),d5
	and	d4,d5		* d5 = masked screen data
	btst	#3,d0
	beq	ovtxt3
	or	d3,d5
ovtxt3:	move	d5,(a3)+	* add charstamp to plane3
	adda	textwide,a3
	add	#$100,d1
	add	#$100,d2	* bump all pointers
	dbra	d6,ovrtxtlp
	addq.l	#8,a1		* bump destination ptr
	bra	overstring

overlast:			* one character remains to be done
	move	#7,d5
otxtlast:			* FOR (eight lines) DO
	move.b	(a2,d1),d2
	asl	#8,d2		* d2(hi) = character data
	move	d2,d3
	eor	#$0ffff,d3	* d3 = character data mask
	move	(a1),d4
	and	d3,d4		* d4 = masked screen data
	btst	#0,d0
	beq	otxtl0
	or	d2,d4
otxtl0:	move	d4,(a1)+	* add charstamp to plane0
	move	(a1),d4
	and	d3,d4		* d4 = masked screen data
	btst	#1,d0
	beq	otxtl1
	or	d2,d4
otxtl1:	move	d4,(a1)+	* add charstamp to plane1
	move	(a1),d4
	and	d3,d4		* d4 = masked screen data
	btst	#2,d0
	beq	otxtl2
	or	d2,d4
otxtl2:	move	d4,(a1)+	* add charstamp to plane2
	move	(a1),d4
	and	d3,d4		* d4 = masked screen data
	btst	#3,d0
	beq	otxtl3
	or	d2,d4
otxtl3:	move	d4,(a1)+	* add charstamp to plane3

	add	#$100,d1
	adda	textwide,a1	* bump pointers to new data
	dbra	d5,otxtlast
overexit:
	rts


*
*	WALL_BLT   Word-Aligned Block Transfer
*
*	Given:
*		d0 = Screen Xpos (must be word-aligned)
*		d1 = Screen Ypos
*		a0 = ptr to Image Data
*		        ( IMAGE = Height (in lines), Width (in words)
*				  Image Data )
*
*	Returns:
*		w/ Screen updated
*
*	Register Usage:
*		destroys a0-a2 and d0-d2
*
*	Externals:
*		none
*
wall_blt:
	and	#$0fff0,d0	* force Xpos to Word-Align
	lsr	#1,d0		* d0 = byte offset within line
	movea.l	#x160tbl,a1
	add	d1,d1
	move	(a1,d1),d1
	add	d0,d1		* d1 = line-offset into screen(bytes)
	movea.l	screen,a2
	adda	d1,a2		* a2 = pointer into display memory
	move	(a0)+,d2
	subq	#1,d2		* d2 = Height (modified for looping)
	move	(a0)+,d1
	lsr	#2,d1
	subq	#1,d1		* d1 = Width (longword pairs, loop modified)
wallhigh:			* FOR (Height of Image) DO
	move	d1,d0		* d0 = width count
	movea.l	a2,a1		* a1 = ptr to screen memory
wallwide:			* FOR (Width of Image) DO
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+	* copy 16 pixels
	dbra	d0,wallwide
	adda.l	#160,a2
	dbra	d2,wallhigh
	rts


*
*	WORDCOPY   Copies entire 16-bit words from source to destination.
*
*	Given:
*		a0 = ptr. to Source
*		a1 = ptr. to Destination
*		d0 = number of words to transfer (unsigned word)
*
*	Returns:
*		w/ Source copied to Destination
*
*	Register Usage:
*		destroys a0-a1 and d0-d1
*
*	Externals:
*		none
*
wordcopy:
	move.l	a0,d1
	addq.l	#1,d1
	andi.l	#-2,d1
	move.l	d1,a0		* force Source to word boundary

	move.l	a1,d1
	addq.l	#1,d1
	andi.l	#-2,d1
	move.l	d1,a1		* force Destination to word boundary

	move	d0,d1
	lsr	#1,d0
	beq	wcskip		* IF (less than two words to copy) skip
	subq	#1,d0
wlcopylp:
	move.l	(a0)+,(a1)+
	dbra	d0,wlcopylp	* copy long words to save time
wcskip:
	btst	#0,d1
	beq	wcexit
	move	(a0)+,(a1)+	* copy last word as needed
wcexit:
	rts


*
*	AFTVIEWER   Clear and Build Aft-Viewer Display
*		 NOTE: must be called after window objects drawn!
*
*	Given:
*		control
*
*	Returns:
*		w/ Aft-Viewer Display Updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		zipviewer,drawstaft,aftobjs,rplstamp,viewstamp
*
aftviewer:
	jsr	zipviewer	* clear the VIEWER screen
	tst	aftvdmg
	beq	aftvw1		* IF (Aft-Viewer Working) THEN
	rts
aftvw1:	tst	hyperon
	bne	aftvw2
	move	truespeed,d0
	cmp	#9,d0
	bgt	aftvw2		* IF (In Normal Space) THEN
	jsr	drawstaft	* draw the Aft-Viewer stars
	jsr	aftobjs		* draw all aft-view objects

	move	shldefct,d2
	bmi	aftvw2		* IF (Shields Turning On) THEN
	asr	#1,d2
	add	#shefimg+8,d2	* d2 = Proper Shield Image
	move	#26,d3		* FOR (All Shield Blips) DO
afshlp:	move	ashdxpos(pc,d3),d0
	move	ashdypos(pc,d3),d1
	movem	d2-d3,-(sp)
	jsr	viewstamp	* Draw a Aft-Viewer-Clipped Shield Blip
	movem	(sp)+,d2-d3
	subq	#2,d3
	bpl	afshlp
aftvw2:
	move	#123,d0
	move	#165,d1
	move	#aretimg,d2
	jsr	rplstamp
	move	#158,d0
	move	#154,d1
	move	#aretimg+1,d2
	jsr	rplstamp	* draw-in Aft-Viewer Reticle
	rts

ashdxpos:
	.dc.w	107,131,159,187,211,97,124,159,194,221,108,132,186,210
ashdypos:
	.dc.w	135,145,135,145,135,169,166,164,166,169,196,187,187,196


*
*	XFORMPTS   Transform Points from Galactic to Screen Co-ords
*
*	Given:
*		d0 = Galactic Xpos/Ypos
*			(Hi-Byte: Xpos, Lo-Byte: Ypos)
*
*	Returns:
*		d0 = Screen Xpos
*		d1 = Screen Ypos
*
*	Register Usage:
*		destroys a0 and d0-d2
*
*	Externals:
*		none
*
xxformtbl:
	.dc.w	106,115,115,106
yxformtbl:
	.dc.w	137,140,146,149,155,158,164,167,173,176,182,185,191,194
xformpts:
	move	d0,d1
	and	#$0ff,d1	* d1 = Galactic Ypos
	asr	#8,d0		* d0 = Galactic Xpos
	movea.l	#lfqudtbl,a0
	sub.b	(a0,d1),d0	* d0 = Absolute Galactic Xpos
	add	d0,d0
	move	d0,d2
	asl	#3,d0
	add	d2,d0		* d0 = 18*(Absolute Galactic Xpos)
	add	d1,d1
	move	d1,d2
	and	#6,d2		* d2 = (Galactic Ypos) MOD 4
	add	xxformtbl(pc,d2),d0
	move	yxformtbl(pc,d1),d1
	rts


*
*	MAKEGMAP   Build a Galactic Map into Current Buffer
*
*	Given:
*		control
*
*	Returns:
*		w/ Control Panel Display Updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		xorstamp,wall_blt,rplstamp,xformpts ???
*
makegmap:
	move	#96,d0
	move	#134,d1
	movea.l	#gmapwal,a0
	jsr	wall_blt	* Draw Grid on Main Viewer

	tst	gameover
	bne	mgmust		* Force Valid GMap at Game End
	tst	radiobzy
	bmi	mgmskip		* IF (Radio Functioning) THEN

mgmust:	movea.l	#bases,a0
	movea.l	#mgmbases,a1
	movea.l	#basedie,a2
	movea.l	#mgmdie,a3
mgmlp1:	move.l	(a2)+,(a3)+	* Copy Endangered Flags Over
	move	(a0)+,(a1)+	* Copy All StarBases Over
	bne	mgmlp1
	movea.l	#fleets,a0
	movea.l	#mgmfleets,a1
mgmlp2:	move.l	(a0)+,(a1)+	* Copy All Alien Fleets Over
	bne	mgmlp2
mgmskip:
	movea.l	#mgmbases,a1
	movea.l	#mgmdie,a2
mgmlp3:	move	(a1)+,d0	* WHILE (Bases Remain) DO
	beq	mgmxit1
	jsr	xformpts
	move	#lrscimg+4,d2
	tst.l	(a2)+
	beq	mgmbok		* IF (Endangered) THEN Use Yellow
	addq	#1,d2
mgmbok:	movem.l	a1-a2,-(sp)
	jsr	xorstamp	* Draw In the Base
	movem.l	(sp)+,a1-a2
	bra	mgmlp3
mgmxit1:
	movea.l	#mgmfleets,a1
mgmlp4:	move.l	(a1),d0		* WHILE (Alien Fleets Remain) DO
	beq	mgmxit2
	jsr	xformpts
	move	(a1),d2
	and	#7,d2
	add	#plotimg,d2
	btst.b	#0,3(a1)
	beq	mgmskp
	addq	#6,d2		* Select Proper Orientation
mgmskp:	move.l	a1,-(sp)
	jsr	xorstamp	* Draw In the Proper Size Fleet
	move.l	(sp)+,a1
	addq.l	#4,a1
	bra	mgmlp4
mgmxit2:
	move	xgal,d0
	asl	#8,d0
	move.b	ygal+1,d0	* Build Galactic X,Y Posn
	jsr	xformpts
	move	ygal,d2
	and	#1,d2
	add	#triimg,d2
	jsr	rplstamp	* You Are Here

	move	xcursor,d0
	move	ycursor,d1
	move	#gcsrimg,d2
	jsr	xorstamp	* Add the Cursor	
	rts


*
*	DOPANEL  Build Control Panel Display, Draw any Changed Objects
*		 Maintain time for Blinkers and Chargers
*
*	Given:
*		control
*
*	Returns:
*		w/ Control Panel Display Updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		rplstamp,text_blt,scanner,aftviewer,wall_blt
*
dopanel:
	move.l	screen,d0
	cmp.l	screen0,d0
	beq	dopan1
	movea.l	#panel0,a6
	bra	dopan2
dopan1:	movea.l	#panel1,a6	* a6 = ptr to correct Panel Old State
dopan2:
	movea.l	#panelvars,a5	* a5 = ptr to current variables

	addq	#1,(a5)		* count a frame drawn as StarTime
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	cmp	#32,d1
	blt	dopnrg		* IF (Stardate Changed) THEN

	movea.l	#textbuff,a0	* Build Stardate string
	rol	#2,d0
	move	d0,d1
	and	#3,d1		* d1 = highest digit
	add.b	#$0e1,d1
	move.b	d1,(a0)+	* add to string
	rol	#3,d0
	move	d0,d1
	and	#7,d1		* d1 = next-highest digit
	add.b	#'0',d1
	move.b	d1,(a0)+	* add to string
	rol	#3,d0
	move	d0,d1
	and	#7,d1		* d1 = next-to-last digit
	add.b	#$0e5,d1
	move.b	d1,(a0)+	* add to string
	rol	#3,d0
	move	d0,d1
	and	#7,d1		* d1 = last digit
	add.b	#$0e5,d1
	move.b	d1,(a0)+	* add to string
	clr	(a0)+		* add an EOS
	move	#272,d0
	move	#4,d1
	move	#$0d,d2
	move	#0,d3
	movea.l	#textbuff,a0
	jsr	text_blt	* Do Stardate (Z-Time) Display

dopnrg:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopsrg		* IF (Energy Changed) THEN
	movea.l	#textbuff,a0	* Build Energy string
	rol	#4,d0
	move	d0,d1
	and	#$0f,d1		* d1 = highest digit
	move	d1,d2		* d2 = raw hi-order digit
	add.b	#'0',d1
	move.b	d1,(a0)+	* add to string
	rol	#4,d0
	move	d0,d1
	and	#$0f,d1		* d1 = next-highest digit
	add.b	#'0',d1
	move.b	d1,(a0)+	* add to string
	rol	#4,d0
	move	d0,d1
	and	#$0f,d1		* d1 = next-to-last digit
	add.b	#'0',d1
	move.b	d1,(a0)+	* add to string
	rol	#4,d0
	move	d0,d1
	and	#$0f,d1		* d1 = last digit
	add.b	#'0',d1
	move.b	d1,(a0)+	* add to string
	clr	(a0)+		* add an EOS
	movea.l	#textbuff,a0
	moveq	#2,d1
dpnrg1:	move.b	(a0),d0		* do leading zero suppression
	cmp.b	#'0',d0
	bne	dpnrg2
	move.b	#' ',(a0)+
	dbra	d1,dpnrg1
dpnrg2:	move	#16,d0
	move	#4,d1
	neg	d2
	add	#$0e,d2
	cmp	#$0c,d2
	bge	dpnrg3
	move	#$0c,d2		* Color Energy Text
dpnrg3:	move	#0,d3
	movea.l	#textbuff,a0
	jsr	text_blt	* Do Energy Display

dopsrg:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#4,d1		* count and test
	beq	doprad
	asr	#2,d0
	and	#3,d0		* 4-state, 8Hz busy box
	add	#surgimg,d0
	tst	hyperon
	beq	dopsg1
	addq	#8,d0		* Maximum Energy Use
	bra	dopsg2
dopsg1:	move	truespeed,d1
	cmp	#7,d1
	blt	dopsg2
	addq	#4,d0		* Medium Energy Use
dopsg2:	move	d0,d2
	move	#63,d0
	move	#4,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do SURGE Busy Box Here
	movem.l	(sp)+,a5-a6

doprad:	move	(a6)+,d1
	move	(a5)+,d0
	bmi	dopkil		* IF (Radio Working) THEN
	addq	#1,d0
	and	#$7fff,d0
	move	d0,radiobzy
	eor	d0,d1
	and	#$4,d1		* count and test
	beq	dopkil
	asr	#2,d0
	and	#7,d0		* 8-state, 8Hz busy box
	add	#radoimg,d0
	move	d0,d2
	move	#238,d0
	move	#4,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do RADIO Busy Box Here
	movem.l	(sp)+,a5-a6

dopkil:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	doplif		* IF (#Kills Changed) THEN
	clr.l	textbuff
	move	d0,d1
	asr	#4,d0
	add.b	#'0',d0		* d0 = high digit
	move.b	d0,textbuff
	and	#$0f,d1
	add.b	#'0',d1		* d1 = low digit
	move.b	d1,textbuff+2	* build messages
	move	#272,d0
	move	#150,d1
	move	#$0e,d2
	move	#0,d3
	movea.l	#textbuff,a0
	jsr	text_blt	* Do #Kills (hi-digit)
	move	#272,d0
	move	#158,d1
	move	#$0e,d2
	move	#0,d3
	movea.l	#textbuff+2,a0
	jsr	text_blt	* Do #Kills (lo-digit)

doplif:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#$4,d1		* count and test
	beq	dophyp
	asr	#2,d0
	and	#7,d0		* 8-state, 8Hz busy box
	add	#alifimg,d0
	move	d0,d2
	move	#304,d0
	move	#142,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do LIFE-SUPPORT Busy Box Here
	movem.l	(sp)+,a5-a6


dophyp:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopwdm		* IF (HyperWarp Status Changed) THEN
	tst	d0
	beq	dphyp0		* IF (HyperWarp is On)
	cmp	#$18,d0
	blt	dphyp1
	move	#1,hyperon	* circular timer
dphyp1:
	move	hyperon,d2
	asr	#2,d2
	add	#hyplimg,d2
	move	#57,d0
	move	#170,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do HyperWarp Spinning Light
	move	#50,d0
	move	#179,d1
	move	#hypsimg+1,d2
	jsr	rplstamp	* Do HyperWarp ON
	movem.l	(sp)+,a5-a6
	addq	#2,hyperon
	bra	dopwdm		* .. and go to next item
dphyp0:				* ELSE
	move	#50,d0
	move	#179,d1
	move	#hypsimg,d2
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do HyperWarp OFF
	move	#hyplimg,d2
	move	#57,d0
	move	#170,d1
	jsr	rplstamp	* Turn-Off HyperWarp Spinning Light
	movem.l	(sp)+,a5-a6

dopwdm:	move	(a5)+,d0
	move	(a6)+,d1
	cmp	d0,d1
	beq	dopspd		* IF (WarpDrive Damage Status Changed) THEN
	tst	d0
	beq	dpwrp1		* IF (WarpDrive Damaged) THEN
	addq	#1,d0
	bne	dpwrp0
	addq	#1,d0
dpwrp0:	move	d0,warpdmg	* count and test blink count
	tst	d1
	bne	dpwrp2		* IF (WarpDrive Was OK) THEN
dpwrp1:	addq.l	#2,a5
	addq.l	#2,a6		* bump ptrs
	bra	dpwrp3		*   .. and re-draw all
dpwrp2:	eor	d0,d1
	and	#$10,d1		* 2 Hz blink rate
	beq	dopspd
	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dpwrp9		* IF (WarpSpeed Changed) THEN
	bra	dpwrp3		* Redraw All
dopspd:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopson		* IF (WarpSpeed Changed) THEN
dpwrp3:				* Redraw WARPSPEED Here
	move	#72,d0
	move	#138,d1
	move	#warpimg,d2
	tst	warpdmg
	beq	dpwrp4
	addq	#1,d2		* Select proper color warp image
dpwrp4:	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do WarpDrive Board
	movem.l	(sp)+,a5-a6
dpwrp9:	move	#72,d0
	move	#9,d1
	sub	shipspeed,d1
	move	d1,d2
	asl	#2,d1
	add	d2,d1		* d1 = 5*(9-warpspeed)
	add	#142,d1
	move	#swrpimg,d2
	btst	#4,warpdmg+1
	beq	dpwrp5
	addq	#1,d2		* Select proper color selector image
dpwrp5:	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do WarpDrive Selector
	movem.l	(sp)+,a5-a6

dopson:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopsbz		* IF (Shield-On Status Changed) THEN
	addq.l	#6,a5
	addq.l	#6,a6		* skip next three words
	tst	shieldon
	bne	dpshl0		* IF (Shields Off) THEN Stop Busy Box
	move	#6,d0
	move	#136,d1
	move	#shbzimg,d2
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Box Displays State Zero
	movem.l	(sp)+,a5-a6
dpshl0:	move	#21,d0
	move	#140,d1
	move	#shldimg,d2
	tst	shieldon
	beq	dpshld
	addq	#1,d2
dpshld:	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do Shield Switch
	movem.l	(sp)+,a5-a6
	bra	dpshield	*  .. and redraw lights
dopsbz:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	tst	shieldon
	beq	dopsdm		* IF (Shields Off) THEN Skip
	eor	d0,d1
	and	#$4,d1		* count and test
	beq	dopsdm
	asr	#2,d0
	and	#7,d0		* 8-state, 8Hz busy box
	add	#shbzimg,d0
	move	d0,d2
	move	#6,d0
	move	#136,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do Shield Systems Busy Box
	movem.l	(sp)+,a5-a6
dopsdm:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopsbl		* IF (Shield Damage Status Changed) THEN
	addq.l	#2,a5
	addq.l	#2,a6		* skip next word
	bra	dpshield	*  .. and redraw
dopsbl:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#8,d1
	beq	dopcon
	tst	shieldon
	beq	dopcon
	tst	shieldmg
	beq	dopcon		* IF (On & Damaged & ReadyTo) THEN
dpshield:			* Re-Draw Shield Lights
	movem.l	a5-a6,-(sp)
	tst	shieldon
	bne	dpshd0		* IF (Shields Off)
	move	#bshlimg,d2	* THEN Both Lights Black
	bra	dpshjn
dpshd0:	tst	shieldmg	* ELSE
	bne	dpshd1		* IF (Shields O.K.)
	move	#bshlimg+1,d2	* THEN Both Lights Green
	bra	dpshjn
dpshd1:	bpl	dpshd2		* ELSE IF (Shields Destroyed)
	move	#bshlimg+3,d0	* THEN Blink Yellow/Red
	move	#bshlimg+2,d2
	bra	dpshd3
dpshd2:	move	#bshlimg+3,d0	* ELSE Blink Yellow/Green
	move	#bshlimg+1,d2
dpshd3:	btst	#3,shieldblk+1
	beq	dpshjn
	exg	d2,d0		* Lights Alternate Blinking
dpshjn:	move	d2,-(sp)
	move	#54,d0
	move	#155,d1
	jsr	rplstamp	* Lower Light
	move	#54,d0
	move	#144,d1
	move	(sp)+,d2
	jsr	rplstamp	* Upper Light
	movem.l	(sp)+,a5-a6

dopcon:	move	(a6)+,d1
	move	(a5)+,d0
	bpl	dopcok		* IF (Computer Destroyed)
	cmp	#-4,d0		* THEN Draw a Dead Computer
	ble	dpcdmg
	subq	#1,computbzy
	move	#24,d0
	move	#167,d1
	move	#dedcimg,d2
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Draw DEAD Computer
	movem.l	(sp)+,a5-a6
dpcdmg:	addq.l	#2,a5
	addq.l	#2,a6		* Bump Ptrs and Exit
	bra	dopblu
dopcok:	addq	#1,d0		* ELSE Run the Computer Display
	and	#$7fff,d0
	move	d0,computbzy
	eor	d0,d1		* d1 = Busy-Timer Delta
	move	(a5)+,d0
	cmp	(a6)+,d0
	bne	dopcmp
	and	#4,d1		* 8-Hz Timer Frequency
	beq	dopblu		* IF ((Computer On/Off)OR(Timed-Out)) THEN
dopcmp:	move	#bzfcimg,d2	* Draw a Working Computer
	tst	computon
	beq	dpcmp2
	move	#bzncimg,d2
dpcmp2:	move	computbzy,d0
	asr	#2,d0
	and	#$0f,d0		* 8-Hz, 16-State Busy Box
	add	d0,d2
	move	#24,d0
	move	#167,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Draw WORKING Computer
	movem.l	(sp)+,a5-a6

dopblu:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopdgl		* IF (Main Buzy Box Needs Changing) THEN
	add	d0,d0		* Maintain Main Buzy Box
	add	d0,d0
	movea.l	#bzimgtbl,a0
	move.l	(a0,d0),a0	* a0 = Image Data Ptr
	move.l	screen,a1
	adda	#(181*160)+120,a1	* a1 = Screen Ptr
	move	#14,d0		* FOR (All Lines) DO
drablp:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda	#144,a1		* Copy a Single Raster Line
	dbra	d0,drablp

dopdgl:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopchl		* IF (Left Gun Damage Status Changed) THEN
	addq.l	#4,a5
	addq.l	#4,a6		* skip next two entries
	move	#vgunimg,d2
	tst	d0
	beq	dplgun		* IF (Left Gun O.K.) THEN Green Light
	addq	#1,d2 		* ELSE Red Light
	bra	dplgun		* .. and re-draw the light
dopchl:	tst	d0
	bne	dopbll		* ELSE IF (undamaged)
	move	(a5)+,d0	* THEN test for meaningful change
	beq	dpchl0
	subq	#1,lgunchrg	* count charging time down
	tst	(a6)+
	beq	dpchl2
	bra	dpchl1
dpchl0:	tst	(a6)+
	beq	dpchl2
dpchl1:	addq.l	#2,a5		* no meaningful change
	addq.l	#2,a6
	bra	dopdgr
dpchl2:	addq.l	#2,a5		* noticeable change
	addq.l	#2,a6
	move	#vgunimg,d2
	tst	d0
	beq	dplgun		* IF (charged) THEN Green
	addq	#2,d2		* ELSE Yellow
	bra	dplgun
dopbll:	addq.l	#2,a5		* ELSE do blinker and skip charge
	addq.l	#2,a6
	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	cmp	#8,d1
	blt	dopdgr		* count and test blinker-count
	move	#vgunimg+1,d2
	btst	#3,d0
	beq	dplgun		* blink red and yellow
	addq	#1,d2
dplgun:	move	#92,d0		* redraw left gun light (d2 = image#)
	move	#137,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do Left-Gun Indicator Light
	movem.l	(sp)+,a5-a6

dopdgr:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopchr		* IF (Right Gun Damage Status Changed) THEN
	addq.l	#4,a5
	addq.l	#4,a6		* skip next two entries
	move	#vgunimg,d2
	tst	d0
	beq	dprgun		* IF (Right Gun O.K.) THEN Green Light
	addq	#1,d2 		* ELSE Red Light
	bra	dprgun		* .. and re-draw the light
dopchr:	tst	d0
	bne	dopblr		* ELSE IF (undamaged)
	move	(a5)+,d0	* THEN test for meaningful change
	beq	dpchr0
	subq	#1,rgunchrg	* count charging time down
	tst	(a6)+
	beq	dpchr2
	bra	dpchr1
dpchr0:	tst	(a6)+
	beq	dpchr2
dpchr1:	addq.l	#2,a5		* no meaningful change
	addq.l	#2,a6
	bra	dopnuk
dpchr2:	addq.l	#2,a5		* noticeable change
	addq.l	#2,a6
	move	#vgunimg,d2
	tst	d0
	beq	dprgun		* IF (charged) THEN Green
	addq	#2,d2		* ELSE Yellow
	bra	dprgun
dopblr:	addq.l	#2,a5		* ELSE do blinker and skip charge
	addq.l	#2,a6
	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	cmp	#8,d1
	blt	dopnuk		* count and test blinker-count
	move	#vgunimg+1,d2
	btst	#3,d0
	beq	dprgun		* blink red and yellow
	addq	#1,d2
dprgun:	move	#225,d0		* redraw right gun light (d2 = image#)
	move	#137,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Do Right-Gun Indicator Light
	movem.l	(sp)+,a5-a6

dopnuk:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopnrd		* IF (Nuke-Available Status Changed) THEN
	tst	d0
	bne	dpnuk0		* IF (Nuke Available) THEN
	move	#305,d0		* THEN restore to Ready State
	move	#170,d1
	move	#bnukimg,d2
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Nuke Light Yellow
	move	#299,d0
	move	#178,d1
	move	#dnukimg,d2
	jsr	rplstamp	* Nuke Switch Up, Door Closed
	movem.l	(sp)+,a5-a6
	addq.l	#4,a5
	addq.l	#4,a6		* skip other nuke stuff
	bra	dopvwn
dpnuk0:	move	#8,nukerdy	* ELSE no nuke, so switch just thrown ..
	btst	#0,stardate+1
	beq	dopnrd
	addq	#1,nukerdy
dopnrd:	move	(a5)+,d0
	cmp	(a6)+,d0
	bne	dpnuk1		* IF (Nuke-Ready Status UNChanged)
	addq.l	#2,a5		* THEN just skip blinker
	addq.l	#2,a6
	bra	dopvwn
dpnuk1:	tst	d0
	beq	dpnuk2
	subq	#1,nukerdy	* count NUKERDY down to zero
dpnuk2:	tst	nonuke
	beq	dpnrdy		* IF (no more nukes)
	move	#9,d2		* THEN throw switch
	sub	d0,d2
	asr	#1,d2
	add	#snukimg,d2	* d2 = current switch state
	move	#8,nukeblk	* blinker to red state
	bra	dpnkjn		*  .. and redraw
dpnrdy:	cmp	#9,d0
	ble	dpnuk3		* IF (door closing)
	sub	#60,d0		* ELSE
	neg	d0
	cmp	#9,d0
	bgt	dopnbl		* IF (door opening)
	clr	nukeblk		* THEN blinker to yellow state
dpnuk3:	asr	#1,d0
	move	#dnukimg,d2
	add	d0,d2		* d2 = image number
dpnkjn:	move	#299,d0		* Redraw the Nuke Switch and Door
	move	#178,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Nuke Switch/Door
	movem.l	(sp)+,a5-a6
dopnbl:	addq	#1,(a5)		* Nuke Blinker
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#8,d1
	beq	dopvwn		* IF (blinker changed enuff) THEN
	move	#bnukimg,d2
	btst	#3,d0
	beq	dpnuk9
	addq	#1,d2		* Flash Red/Yellow
dpnuk9:	move	#305,d0
	move	#170,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Nuke Light
	movem.l	(sp)+,a5-a6

dopvwn:	move	(a5)+,d0
	move	(a6)+,d1
	cmp	d0,d1
	beq	dopafv		* IF (Viewing Status Changed) THEN
	tst	d1
	bne	dpvwn0
	move	#157,d1
	move	#gmapimg+1,d2
	move	#2,freshmap	* Gmap now, get a Clean Gmap
	bra	dpvwn2
dpvwn0:	bmi	dpvwn1
	tst	aftvdmg
	bne	dpvnew
	move	#167,d1
	move	#aftvimg+1,d2
	bra	dpvwn2
dpvwn1:	tst	scandmg
	bne	dpvnew
	move	#147,d1
	move	#scanimg+1,d2
dpvwn2:			* IF (was Gmap OR still working) THEN
	move	#228,d0
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* De-Select the Old Scan
	movem.l	(sp)+,a5-a6
dpvnew:			* ELSE Redraw the New Selection
	tst	viewing
	bne	dpvwn4
	move	#157,d1
	move	#gmapimg,d2
	bra	dpvwn6
dpvwn4:	bmi	dpvwn5
	tst	aftvdmg
	bne	dopafv
	move	#167,d1
	move	#aftvimg,d2
	bra	dpvwn6
dpvwn5:	tst	scandmg
	bne	dopafv
	move	#147,d1
	move	#scanimg,d2
dpvwn6:			* IF (was Gmap OR still working) THEN
	move	#228,d0
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Select the New Scan
	movem.l	(sp)+,a5-a6

dopafv:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	dopavb		* IF (Aft-Viewer Damage Status Changed) THEN
	tst	d0
	beq	dpafv0		* IF (Aft-Viewer Damaged)
	move	#aftvimg+2,d2	* THEN draw red
	bra	dpafv2
dpafv0:	move	#aftvimg,d2	* ELSE draw white
	move	viewing,d0
	cmp	#1,d0
	beq	dpafv2		* IF (Not Selected) THEN draw purple
	addq	#1,d2
dpafv2:	move	#228,d0
	move	#167,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Redraw the Aft-Viewer Select
	movem.l	(sp)+,a5-a6
dopavb:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#8,d1
	beq	doplrs
	tst	aftvdmg
	beq	doplrs		* IF (Damaged AND ReadyTo) THEN
	move	#aftvimg+2,d2
	btst	#3,d0
	bne	dpavb2
	addq	#1,d2		* Blink Red and Black
dpavb2:	move	#228,d0
	move	#167,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Redraw the Aft-Viewer Select
	movem.l	(sp)+,a5-a6

doplrs:	move	(a5)+,d0
	cmp	(a6)+,d0
	beq	doplrb		* IF (LR Scanner Damage Status Changed) THEN
	tst	d0
	beq	dplrs0		* IF (LR Scanner Damaged)
	move	#scanimg+2,d2	* THEN draw red
	bra	dplrs2
dplrs0:	move	#scanimg,d2	* ELSE draw white
	tst	viewing
	bmi	dplrs2		* IF (Not Selected) THEN draw purple
	addq	#1,d2
dplrs2:	move	#228,d0
	move	#147,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Redraw the LR Scanner Select
	movem.l	(sp)+,a5-a6
doplrb:	addq	#1,(a5)
	move	(a5)+,d0
	move	(a6)+,d1
	eor	d0,d1
	and	#8,d1
	beq	dopgmp
	tst	scandmg
	beq	dopgmp		* IF (Damaged AND ReadyTo) THEN
	move	#scanimg+2,d2
	btst	#3,d0
	bne	dplrb2
	addq	#1,d2		* Blink Red and Black
dplrb2:	move	#228,d0
	move	#147,d1
	movem.l	a5-a6,-(sp)
	jsr	rplstamp	* Redraw LR Scanner Select
	movem.l	(sp)+,a5-a6

dopgmp:	tst	viewing
	bne	dopngm		* IF (Viewing the Galactic Map) THEN
	tst	freshmap
	beq	dpgmp2		* IF (Fresh Galactic Map Requested) THEN
	jsr	makegmap	* THEN make a Fresh GMAP
	subq	#1,freshmap
	bra	dopdone
dpgmp2:	move	(a6)+,d0	* ELSE Handle the Cursor
	move	(a6),d1
	cmp	(a5)+,d0
	bne	dpgmp3
	cmp	(a5),d1
	beq	dopdone		* IF (Cursor has Moved) THEN
dpgmp3:	move	#gcsrimg,d2
	jsr	xorstamp	* Wipe-Out the Old Cursor
	move	xcursor,d0
	move	ycursor,d1
	move	#gcsrimg,d2
	jsr	xorstamp	* Add the New Cursor
	bra	dopdone

dopngm:	bmi	dopvlr		* ELSE Build Other Viewer Display
	jsr	aftviewer
	bra	dopdone
dopvlr:	jsr	scanner
dopdone:


*	Special Case Aft-Gun Lights (and a cherry on top)
	move	aftgundmg,d0
	bne	dpaftd		* IF (Aft Gun O.K.)
	move	aftgunchrg,d0	* THEN IF (Aft Gun Charging)
	beq	dpaft0
	subq	#1,aftgunchrg	* count charging time down
	move	#hgunimg+2,d2
	bra	dpagun		* Yellow If Charging
dpaft0:	move	#hgunimg,d2
	bra	dpagun		* Green If Ready
dpaftd:	addq	#1,aftgunblk	* ELSE count the blinker
	move	#hgunimg+1,d2
	btst	#3,aftgunblk+1
	beq	dpagun
	addq	#1,d2		* blink red and yellow
dpagun:	move	#154,d0		* redraw aft gun light (d2 = image#)
	move	#195,d1
	jsr	rplstamp	* Do Aft-Gun Indicator Light

	move.l	screen,d0
	cmp.l	screen0,d0
	beq	dopan3
	movea.l	#panel0,a1
	bra	dopan4
dopan3:	movea.l	#panel1,a1	* a1 = ptr to correct Panel Old State
dopan4:
	movea.l	#panelvars,a0	* a0 = ptr to current variables
	move	#32,d0
	jsr	wordcopy	* save current Panel State

	tst	hyperon
	bne	dpnosh
	move	shldefct,d2
	bmi	dpnosh		* IF (Shields Turning On) THEN
	asr	#1,d2
	add	#shefimg,d2	* d2 = Proper Shield Image
	move	#24,d3		* FOR (All Shield Blips) DO
dpshlp:	move	shldxpos(pc,d3),d0
	move	shldypos(pc,d3),d1
	movem	d2-d3,-(sp)
	jsr	windstamp	* Draw a Window-Clipped Shield Blip
	movem	(sp)+,d2-d3
	subq	#2,d3
	bpl	dpshlp
	subq	#1,shldefct	* Count-Down Timer
dpnosh:
	move	#12,d0
	move	#130,d1
	move	#vlapimg,d2
	jsr	rplstamp	* Top of Life-Support Box
	move	#92,d0
	move	#130,d1
	move	#vlapimg+1,d2
	jsr	rplstamp	* Top of Viewer

	rts

shldxpos:
	.dc.w	10,85,233,308,1,72,159,246,317,24,91,227,294
shldypos:
	.dc.w	14,26,26,14,78,73,68,73,78,132,119,119,132


*
*	DEADPANEL  Build Control Panel Display, No Flashy Stuff
*
*	Given:
*		control
*
*	Returns:
*		w/ Control Panel Display Updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		rplstamp
*
deadpanel:
	addq	#1,stardate	* Mark Time

	jsr	makegmap	* Build a GalacticMap
	move	#154,d0
	move	#195,d1
	move	#hgunimg+1,d2
	jsr	rplstamp	* Do Aft-Gun Indicator Light

	move	kills,d0	
	clr.l	textbuff
	move	d0,d1
	asr	#4,d0
	add.b	#'0',d0		* d0 = high digit
	move.b	d0,textbuff
	and	#$0f,d1
	add.b	#'0',d1		* d1 = low digit
	move.b	d1,textbuff+2	* build messages
	move	#272,d0
	move	#150,d1
	move	#$0e,d2
	move	#0,d3
	movea.l	#textbuff,a0
	jsr	text_blt	* Do #Kills (hi-digit)
	move	#272,d0
	move	#158,d1
	move	#$0e,d2
	move	#0,d3
	movea.l	#textbuff+2,a0
	jsr	text_blt	* Do #Kills (lo-digit)

	move	#12,d0
	move	#130,d1
	move	#vlapimg,d2
	jsr	rplstamp	* Top of Life-Support Box
	move	#92,d0
	move	#130,d1
	move	#vlapimg+1,d2
	jsr	rplstamp	* Top of Viewer
	rts


*
*	SCANNER   Build Scanner Display, Draw Important Objects
*
*	Given:
*		control
*
*	Returns:
*		w/ Long-Range Scanner updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		viewstamp,rplstamp,zipviewer
*
scnobjtbl:	* Object# to Image# Table
	.dc.w	lrscimg+1,lrscimg+4,lrscimg+6,lrscimg+7,0,0,0,0
scanner:
	jsr	zipviewer		* clear the scanner
	tst	scandmg
	beq	scanok			* IF (scanner functioning)
	rts
scanok:
	move	#xscrnctr,d0
	move	#yscrnctr,d1
	move	#lrscimg+8,d2
	jsr	viewstamp		* draw our ship in center
	tst	hyperon
	bne	scanend			* Turn-Off Scanner In HyperSpace

	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#zpos,a2		* a2 = object Zpos-List ptr
	movea.l	#ypos,a3		* a3 = object Ypos-List ptr
	move	#(nobjects-1),d7	* d7 = Loop Counter
scanlp:					* FOR (all objects) DO
	move	(a0),d0
	bmi	scanskip		* IF (object exists) THEN
	cmp	#shutid,d0
	bge	scanskip		* IF (not interesting enuff) THEN skip
	rol	#4,d0
	and	#7,d0			* d0 = Object Type
	add	d0,d0
	move	scnobjtbl(pc,d0),d2	* d2 = Object Image Base#
	cmp	#lrscimg+6,d2
	bge	scanjn
	move	(a3),d0			* Color Code Scanner
	cmp	#100,d0
	ble	scan1
	subq	#1,d2			* Below the Plane, Use Red
	bra	scanjn
scan1:	cmp	#-100,d0
	bge	scanjn
	addq	#1,d2			* Above the Plane, Use Yellow

scanjn:	move.b	(a1),d0			* d2 = Image Index
	ext.w	d0
	asr	#1,d0			* d0 = scaled Xpos
	add	#xscrnctr,d0
	move.b	(a2),d1
	ext.w	d1
	neg	d1
	asr	#1,d1			* d1 = scaled Ypos (Zpos)
	add	#yscrnctr,d1
	movem.l	d7/a0-a3,-(sp)
	jsr	viewstamp		* draw figure into the scanner
	movem.l	(sp)+,d7/a0-a3
scanskip:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3			* bump all pointers to new data
	dbra	d7,scanlp
scanend:
	move	#98,d0
	move	#135,d1
	move	#lrscimg+9,d2
	jsr	rplstamp		* Draw LR-Scanner Reticle
	rts


*
*	ZIPVIEWER  Clears display memory of the VIEWER.
*
*	Given:
*		screen=current screen address
*
*	Returns:
*		with viewer display zeroed
*
*	Register Usage:
*		destroys d0-d4 and a0-a4
*
*	Externals:
*		none
*
zipviewer:
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	a0
	clr.l	a1
	clr.l	a2
	clr.l	a3

	movea.l	screen,a4
	adda	#((197*160)+112),a4	* a4 = ptr to bottom right corner
	move.w	#63,d4			* clear 64 lines
zipvwlp:
	movem.l	d0-d3/a0-a3,-(a4)
	movem.l	d0-d3/a0-a3,-(a4)	* clear 32 words each line
	suba	#96,a4
	dbra	d4,zipvwlp
	rts


*
*	DATA STORAGE
*
	.data

*
*	BILLBOARD Messages
*		Text Strings (Zero-Terminated)
*		Length of SIXTEEN to Fill Message Window.
*
nullmsg:
	.dc.b	"                ",0
redlrtmsg:
	.dc.b	"R E D  A L E R T",0
dockedmsg:
	.dc.b	"STARSHIP DOCKED ",0
dokabomsg:
	.dc.b	"DOCKING ABORTED ",0
xferdnmsg:
	.dc.b	" REFIT COMPLETE ",0
bsurrmsg:
	.dc.b	"BASE SURROUNDED ",0
bdestmsg:
	.dc.b	" BASE DESTROYED ",0
levlmsg0:
	.dc.b	"     NOVICE     ",0
levlmsg1:
	.dc.b	"      PILOT     ",0
levlmsg2:
	.dc.b	"     WARRIOR    ",0
levlmsg3:
	.dc.b	"    COMMANDER   ",0
agndmgmsg:
	.dc.b	"AFT GUN DAMAGED ",0
lgndmgmsg:
	.dc.b	"PORT GUN DAMAGED",0
rgndmgmsg:
	.dc.b	"STBD GUN DAMAGED",0
shldmgmsg:
	.dc.b	"SHIELDS DAMAGED ",0
shldstmsg:
	.dc.b	"SHIELD DESTROYED",0
raddmgmsg:
	.dc.b	" RADIO DAMAGED  ",0
wrpdmgmsg:
	.dc.b	"ENGINES DAMAGED ",0
afvdmgmsg:
	.dc.b	"AFT VIEW DAMAGED",0
lrsdmgmsg:
	.dc.b	"SCANNER DAMAGED ",0
comdmgmsg:
	.dc.b	"COMPUTER DAMAGED",0
energymsg:
	.dc.b	"   LOW ENERGY   ",0
shootmsg:
	.dc.b	"  CEASE FIRING  ",0
shoffmsg:
	.dc.b	"   SHIELD OFF   ",0
shonmsg:
	.dc.b	"   SHIELDS ON   ",0

*
*	TIMESQUARE Messages
*		Text Strings (Zero-Terminated)
*		Should append a Blank (in case next message is close behind)
*
agluckmsg:
	.dc.b	"Good Luck, Star-Raider! ",0
bgluckmsg:
	.dc.b	"Happy Hunting, Star-Raider! ",0
cgluckmsg:
	.dc.b	"Our Hopes Go With You, Comrade. ",0
dgluckmsg:
	.dc.b	"We'll Keep a Cool One on Ice for You, Buddy. ",0
starbsmsg:
	.dc.b	" STARFLEET COMMAND ",0
speedmsg:
	.dc.b	" 186,000 miles per second, it's not just a good idea .."
	.dc.b	" it's the law. ",0

	.even

billmsgs:
	.dc.l	nullmsg
	.dc.l	redlrtmsg
	.dc.l	dockedmsg
	.dc.l	dokabomsg
	.dc.l	xferdnmsg
	.dc.l	bsurrmsg
	.dc.l	bdestmsg
	.dc.l	levlmsg0
	.dc.l	levlmsg1
	.dc.l	levlmsg2
	.dc.l	levlmsg3
	.dc.l	agndmgmsg
	.dc.l	lgndmgmsg
	.dc.l	rgndmgmsg
	.dc.l	shldmgmsg
	.dc.l	shldstmsg
	.dc.l	raddmgmsg
	.dc.l	wrpdmgmsg
	.dc.l	afvdmgmsg
	.dc.l	lrsdmgmsg
	.dc.l	comdmgmsg
	.dc.l	energymsg
	.dc.l	shootmsg
	.dc.l	shoffmsg
	.dc.l	shonmsg

msgtbl:
	.dc.l	agluckmsg
	.dc.l	bgluckmsg
	.dc.l	cgluckmsg
	.dc.l	dgluckmsg
	.dc.l	starbsmsg
	.dc.l	speedmsg

*
*	DATA STORAGE
*

	.bss

fontptr:
	.ds.l	1		* ptr to 8x8 system font
textwide:
	.ds.w	1		* width of text destination line(bytes)

blbactive:
	.ds.w	1		* Billboard Active flag (0=Timing Out)
*				*		  ( >0 ==> Making Display)
*				*		  ( <0 ==> Disabled)
blbtimer:
	.ds.w	1		* Billboard Display Timer
blbmess:
	.ds.w	1		* Current Message# and Color
*				* Hi-Nybble = Color, rest Message#

tsqactive:
	.ds.w	1		* Times-Square Active flag (0=off)
tsqscroll:
	.ds.w	1		* Current Scroll-Count (0-15)
tsqstrptr:
	.ds.w	1		* Offset within the Current string
tsqblanks:
	.ds.w	1		* Number of Blank Pairs Output in a Row
tsqtemp:
	.ds.w	2		* Buffer for Character data
tsqmsgs:
	.ds.w	8		* Array of Pending Messages
*				  (hi-nybble = color, rest is message no.)
tsqbuffer:
	.ds.w	288		* Image Data Buffer (18 chars wide)

textbuff:
	.ds.l	2		* Temporary Text Buffer (7 chars long)

aftgundmg:
	.ds.w	1		* AFT Gun Damaged flag (0=not damaged)
aftgunchrg:
	.ds.w	1		* AFT Gun Charged flag (0=charged)
aftgunblk:
	.ds.w	1		* AFT Gun Blinker Counter

freshmap:
	.ds.w	1		* Reqest for a Newly Drawn GMap (>0 ==> please)
mgmbases:
	.ds.w	8		* Local Report on Starbases
mgmdie:
	.ds.l	8		* Local Status of Starbases
mgmfleets:
	.ds.l	26		* Local Report on Alien Fleet Disposition

shldefct:
	.ds.w	1		* Shield Effect Counter (-1 ==> OFF)

*
*	STARSHIP PANEL VISIBLES
*
*	Note: Must maintain order for DOPANEL
*		and length for the following buffers
*
panel0:
	.ds.w	32		* buffer for state of screen0's Panel
panel1:
	.ds.w	32		* buffer for state of screen1's Panel

panelvars:
stardate:
	.ds.w	1		* Current Startime (number of frames drawn)
energy:
	.ds.w	1		* !BCD! ENERGY remaining in ships batteries
surgebzy:
	.ds.w	1		* Energy-Surge Busy-Box Counter
radiobzy:
	.ds.w	1		* Sub-Etha Radio Busy-Counter (neg=dead)
kills:
	.ds.w	1		* !BCD! Number of DRI employees dusted
lifebzy:
	.ds.w	1		* Life-Support System Busy-Box Counter
hyperon:
	.ds.w	1		* HyperDrive Activated flag (0=off)
warpdmg:
	.ds.w	1		* Warp-Drive Damaged Flag (0=O.K.)
shipspeed:
	.ds.w	1		* Our ships speed (0-9)
shieldon:
	.ds.w	1		* Shields on flag (0=off)
shieldbzy:
	.ds.w	1		* Shield Busy-Box Counter
shieldmg:
	.ds.w	1		* Shield damage level
*				  0 = Shields OK
*				  1 = Shields damaged
*				 -1 = Shields destroyed
shieldblk:
	.ds.w	1		* Shields Damaged Blinker Counter
computbzy:
	.ds.w	1		* Battle-Computer Busy-Box Counter (neg=dead)
computon:
	.ds.w	1		* Battle-Computer Activated flag (0=off)
mainbzy:
	.ds.w	1		* Main Busy-Box Current Image Index
lgundmg:
	.ds.w	1		* LEFT Gun Damaged flag (0=not damaged)
lgunchrg:
	.ds.w	1		* LEFT Gun Charged flag (0=charged)
lgunblk:
	.ds.w	1		* LEFT Gun Blinker Counter
rgundmg:
	.ds.w	1		* RIGHT Gun Damaged flag (0=not damaged)
rgunchrg:
	.ds.w	1		* RIGHT Gun Charged flag (0=charged)
rgunblk:
	.ds.w	1		* RIGHT Gun Blinker Counter
nonuke:
	.ds.w	1		* No more Emergency Atomics Available flag
nukerdy:
	.ds.w	1		* Nuclear Safety flag/counter (0=Safe)
nukeblk:
	.ds.w	1		* Nuke Blinker Counter
viewing:
	.ds.w	1		* Thing Currently being Viewed
*				  1 = Aft-Viewer
*				  0 = Galactic Chart
*				 -1 = Long-Range Scanner
aftvdmg:
	.ds.w	1		* Aft-Viewer Damaged Flag (0=O.K.)
aftvblk:
	.ds.w	1		* Aft-Viewer Damaged Blinker Counter
scandmg:
	.ds.w	1		* LR Scanner Damaged Flag (0=O.K.)
scanblk:
	.ds.w	1		* LR Scanner Damaged Blinker Counter
xcursor:
	.ds.w	1		* Galactic Cursor X-position
ycursor:
	.ds.w	1		* Galactic Cursor Y-position

	.end
