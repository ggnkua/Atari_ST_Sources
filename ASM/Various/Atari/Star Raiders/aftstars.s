*
*	AFTSTARS.S	Viewer Star-Handling package for  ST Star-Raiders
*
	.text

*
*	PUBLIC SYMBOLS
*

	.globl	initstaft
	.globl	drawstaft
	.globl	flystaft
	.globl	upstaft
	.globl	downstaft
	.globl	leftstaft
	.globl	ritestaft

*
*	GAME CONSTANTS
*
nstaft	.equ	16		* number of AFT stars

starlife .equ	$7fff		* Aft-Star Duration

*
*	SUBROUTINE AREA
*

*
*	TURNSTAR   Moves AFT stars in response to joystick
*
*	Given:
*		nothing
*
*	Returns:
*		all stars updated and replaced as needed
*
*	Register Usage:
*		destroys a0-a4 and d0-d7
*
*	Externals:
*		randu
*
ritestaft:			* move stars when joystick right
	move.l	#$d000,d4
	move.l	#$ffc4ffff,d7	* Turning Stars Replacement Position
	bra	xmstar
leftstaft:			* move stars when joystick left
	move.l	#$ffff3000,d4
	move.l	#$3c0000,d7	* Turning Stars Replacement Position
	bra	xmstar
upstaft:			* move stars when joystick up
	move.l	#$d000,d4
	move.l	#$ffe4ffff,d7	* Turning Stars Replacement Position
	bra	ymstar
downstaft:			* move stars when joystick down
	move.l	#$ffff3000,d4
	move.l	#$1c0000,d7	* Turning Stars Replacement Position
	bra	ymstar

xmstar:				* move stars in x-direction
	movea.l	#startime,a3
	movea.l	#starlist,a4
	move	#(nstaft-1),d6	* FOR (all star x-positions) DO
xmstarlp:
	add.l	d4,(a4)		* compute new Xpos
	move	(a4),d0
	bpl	xmst1
	neg	d0
xmst1:	cmp	#xmaxscrn,d0	* test new Xpos for validity
	blt	xmstok

	jsr	randu		* get 24-bit random number
	swap	d0
	ext	d0
	bpl	xmnu1		* restrict range of Xpos
	ori	#$0fc,d0
	bra	xmnu2
xmnu1:	andi	#3,d0
xmnu2:	swap	d0		* sign-extended 32-bit random = {-4 .. 3}
	add.l	d7,d0
	move.l	d0,(a4)		* new Xpos
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	swap	d0		* sign-extended 32-bit random
	asr.l	#2,d0
	move.l	d0,4(a4)	* Ypos = {-32 .. 31}
	and	#$7fff,d0
	move	d0,(a3)		* Start Star Timer

xmstok:	addq.l	#2,a3
	addq.l	#8,a4
	dbra	d6,xmstarlp
	rts

ymstar:				* move stars in y-direction
	movea.l	#startime,a3
	movea.l	#starlist,a4
	move	#(nstaft-1),d6	* FOR (all star y-positions) DO
ymstarlp:
	add.l	d4,4(a4)	* compute new Ypos
	move	4(a4),d0
	bpl	ymst1
	neg	d0
ymst1:	cmp	#ymaxscrn,d0	* test new Ypos for validity
	blt	ymstok

	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	swap	d0		* sign-extended to a 32-bit random
	asr.l	#1,d0
	move.l	d0,(a4)		* Xpos = {-64 .. 64}
	jsr	randu		* get 24-bit random number
	swap	d0
	ext	d0
	bpl	ymnu1		* restrict range of Ypos
	ori	#$0fc,d0
	bra	ymnu2
ymnu1:	andi	#3,d0
ymnu2:	swap	d0		* sign-extended 32-bit random = {-4 .. 3}
	add.l	d7,d0
	move.l	d0,4(a4)	* new Ypos
	and	#$7fff,d0
	move	d0,(a3)		* Start Star Timer

ymstok:	addq.l	#2,a3
	addq.l	#8,a4
	dbra	d6,ymstarlp
	rts


*
*	FLYSTAFT   Flies AFT stars past at rate determined by speed
*
*	Given:
*		STARLIST = address of list of stars X,Y,Color
*		TRUESPEED = address of current true speed
*
*	Returns:
*		all stars X,Y updated
*
*	Register Usage:
*		destroys a0-a1 and d0-d7
*
*	Externals:
*		randu
*
flystaft:
	move	truespeed,d6
	beq	flstxit		* IF (not moving) SKIP
	movea.l	#starmove,a0
	add	d6,d6
	move	(a0,d6),d6	* d6 = Star Movement Multiplier
	move	d6,d5
	asr	#1,d5		* d5 = Star Decay Rate

	movea.l	#startime,a3
	movea.l	#starlist,a4
	move	#(nstaft-1),d7	* FOR (all stars) DO
flstarlp:
	move	(a4),d0
	muls	d6,d0
	sub.l	d0,(a4)		* Xpos=Xpos-Multiplier(Xpos)

	move	4(a4),d0
	muls	d6,d0
	sub.l	d0,4(a4)	* Ypos=Ypos-Multiplier(Ypos)

	sub	d5,(a3)		* Count Time Relative to Speed
	bpl	flstok

*   Create a new star to replace an old one
flstnew:
	jsr	randu		* get 24-bit random number
	tst	d0
	bpl	ynewstar
*	Randomly positioned along Y-axis
	swap	d0
	ext	d0
	bpl	newst1
	or	#$0ffc0,d0
	and	#$0ffc7,d0	* Xpos = {-64 .. -56}
	bra	newst2
newst1:	and	#$3f,d0
	or	#$38,d0		* Xpos = {63 .. 56}
newst2:	swap	d0
	move.l	d0,(a4)
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#4,d0		* ensure non-zero
	ext	d0
	swap	d0		* sign-extended to a 32-bit random
	asr.l	#2,d0
	move.l	d0,4(a4)	* Ypos = {-32 .. 31}
	and	#$7ff,d0
	eor	#starlife,d0	* Leftover Randomization
	move	d0,(a3)		* Start Star Timer
	bra	flstok

ynewstar:
*	Randomly positioned along X-axis
	swap	d0
	ext	d0
	bpl	newst4
	or	#$0ffe0,d0
	and	#$0ffe7,d0	* Ypos = {-32 .. -28}
	bra	newst5
newst4:	and	#$1f,d0
	or	#$18,d0		* Ypos = {31 .. 27}
newst5:	swap	d0
	move.l	d0,4(a4)
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#2,d0		* ensure non-zero
	ext	d0
	asr	#1,d0
	swap	d0		* sign-extended to a 32-bit random
	move.l	d0,(a4)		* Xpos = {-64 .. 63}
	and	#$7ff,d0
	eor	#starlife,d0	* Leftover Randomization
	move	d0,(a3)		* Start Star Timer

flstok:
	addq.l	#2,a3
	addq.l	#8,a4		* point to next star info
	dbra	d7,flstarlp
flstxit:
	rts


*
*	DRAWSTAFT   Draws a VIEWERful of stars on a zeroed background
*
*	Given:
*		STARLIST = address of list of stars X,Y,Color
*
*	Returns:
*		all stars drawn in current buffer
*
*	Register Usage:
*		destroys a0-a2 and d0-d3
*
*	Externals:
*		none
*
drawstaft:
	movea.l	#starlist,a0
	movea.l	screen,a1
	movea.l	#x160tbl,a2
	move	#(nstaft-1),d3	* FOR (all stars) DO
drstarlp:
	move	(a0),d0
	add	#xscrnctr,d0	* d0 = star screen Xpos
	move	4(a0),d1
	add	#yscrnctr,d1	* d1 = star screen Ypos
*
*	draw the star
*
	add	d1,d1
	move	(a2,d1),d1	* d1 = line-offset into screen(bytes)
	move	d0,d2
	asr	#1,d2
	andi	#$fff8,d2	* d2 = (xpos/16)*8=row-offset(bytes)
	btst	#3,d0
	beq	astarjn1
	addq	#1,d2		* adjust to byte boudary
astarjn1:
	add	d1,d2		* d2 = offset into bitmap
	eori	#7,d0		* d0 = bit offset into byte
	bset	d0,(a1,d2)	* set the proper pixel

	addq.l	#8,a0		* bump pointer to next star
	dbra	d3,drstarlp
	rts


*
*	INITSTAFT   Initializes AFT stars
*
*	Given:
*		STARLIST = address of list of stars X and Y
*
*	Returns:
*		all stars X and Y randomly initialized
*
*	Register Usage:
*		destroys a0 and d0-d6
*
*	Externals:
*		randu
*
initstaft:
	movea.l	#starlist,a0
	movea.l	#startime,a1
	move	#(nstaft-1),d6	* FOR (all stars) DO
instarlp:
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#2,d0		* ensure non-zero
	ext	d0
	asr	#1,d0
	swap	d0		* sign-extended to a 32-bit random
	move.l	d0,(a0)+	* Xpos = {-64 .. 63}

	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#4,d0		* ensure non-zero
	ext	d0
	asr	#2,d0
	swap	d0		* sign-extended to a 32-bit random
	move.l	d0,(a0)+	* Ypos = {-32 .. 31}

	jsr	randu
	and	#starlife,d0
	move	d0,(a1)+	* Start Star Timer

	dbra	d6,instarlp
	rts


*
*	DATA STORAGE
*

	.bss

starlist:
	.ds.l	nstaft		* X-position (lo-word=fractional part)
	.ds.l	nstaft		* Y-position (lo-word=fractional part)
startime:
	.ds.w	nstaft		* Star Lifetime Counter

	.end
