*
*	STARS.S	Star-Handling package for  ST Star-Raiders
*
	.text

*
*	PUBLIC SYMBOLS
*

	.globl	initstars
	.globl	hyperstars
	.globl	drawstars
	.globl	flystars
	.globl	upstars
	.globl	downstars
	.globl	leftstars
	.globl	rightstars
	.globl	starmove

*
*	GAME CONSTANTS
*
nstars	.equ	32		* number of stars

*
*	SUBROUTINE AREA
*

*
*	TURNSTAR   Moves stars in response to joystick
*
*	Given:
*		nothing
*
*	Returns:
*		all stars updated and replaced as needed
*
*	Register Usage:
*		destroys a0 and d0-d6
*
*	Externals:
*		randu
*
leftstars:			* move stars when joystick left
	move.l	#$20000,d4
	move	truespeed,d0
	add	d0,d0
	move	xstarmov(pc,d0),d5	* table lookup of replace pos
	neg	d5
	bra	xmstar
rightstars:			* move stars when joystick right
	move.l	#$fffe0000,d4
	move	truespeed,d0
	add	d0,d0
	move	xstarmov(pc,d0),d5	* table lookup of replace pos
	bra	xmstar
xstarmov:			* Turning Stars Replacement Positions X-Table
	.dc.w	152		* slowest speed
	.dc.w	151
	.dc.w	150
	.dc.w	149
	.dc.w	148
	.dc.w	144
	.dc.w	136
	.dc.w	104
	.dc.w	 92
	.dc.w	 88		* fastest speed
downstars:			* move stars when joystick down
	move.l	#$20000,d4
	move	truespeed,d0
	add	d0,d0
	move	ystarmov(pc,d0),d5	* table lookup of replace pos
	neg	d5
	bra	ymstar
upstars:			* move stars when joystick up
	move.l	#$fffe0000,d4
	move	truespeed,d0
	add	d0,d0
	move	ystarmov(pc,d0),d5	* table lookup of replace pos
	bra	ymstar
ystarmov:			* Turning Stars Replacement Positions Y-Table
	.dc.w	56		* slowest speed
	.dc.w	56
	.dc.w	55
	.dc.w	55
	.dc.w	54
	.dc.w	54
	.dc.w	53
	.dc.w	53
	.dc.w	52
	.dc.w	48		* fastest speed

xmstar:				* move stars in x-direction
	ext.l	d5
	swap	d5		* d5 = replace position
	movea.l	#starlist,a0
	move	#(nstars-1),d6	* FOR (all star x-positions) DO
xmstarlp:
	add.l	d4,(a0)		* compute new Xpos
	move	(a0),d0
	bpl	xmst1
	neg	d0
xmst1:	cmp	#160,d0		* test new Xpos for validity
	blt	xmstok
*				  Create a New Star
	jsr	randu		* get 24-bit random number
	swap	d0
	ext	d0
	bpl	xmnu1		* restrict range of Xpos
	ori	#$0f8,d0
	bra	xmnu2
xmnu1:	andi	#$07,d0
xmnu2:	swap	d0		* sign-extended 32-bit random = {-8 .. 7}
	add.l	d5,d0
	move.l	d0,(a0)		* new Xpos
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0
	ext	d0
	asr	#1,d0
	swap	d0		* Ypos = {-64 .. 63}
	move.l	d0,4(a0)	

xmstok:	addq.l	#8,a0
	dbra	d6,xmstarlp
	rts

ymstar:				* move stars in y-direction
	swap	d5
	clr	d5		* d5 = replace position
	movea.l	#starlist,a0
	move	#(nstars-1),d6	* FOR (all star y-positions) DO
ymstarlp:
	add.l	d4,4(a0)	* compute new Ypos
	move	4(a0),d0
	bpl	ymst1
	neg	d0
ymst1:	cmp	#64,d0		* test new Ypos for validity
	blt	ymstok
*				  Create a New Star
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0
	ext	d0
	swap	d0		* sign-extended 32-bit random
	move.l	d0,(a0)		* Xpos = {-128 .. 127}
	jsr	randu		* get 24-bit random number
	swap	d0
	ext	d0
	bpl	ymnu1		* restrict range of Ypos
	ori	#$0f8,d0
	bra	ymnu2
ymnu1:	andi	#$07,d0
ymnu2:	swap	d0		* sign-extended 32-bit random = {-8 .. 7}
	add.l	d5,d0
	move.l	d0,4(a0)	* new Ypos

ymstok:	addq.l	#8,a0
	dbra	d6,ymstarlp
	rts


*
*	FLYSTARS   Flies stars past at rate determined by speed
*
*	Given:
*		STARLIST = address of list of stars X,Y,Color
*		TRUESPEED = address of current true speed
*
*	Returns:
*		all stars X,Y updated
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		randu
*
starmove:			* Star-Speed Multiplier Table
	.dc.w	0,256,326,419,489,652,977,1443,1956,2560
	.dc.w	$0c00,$1000,$1400,$1800,$1c00,$2000,$2400,$2800,$2c00,$3000
flystars:
	move	truespeed,d4
	beq	flstxit		* IF (not moving) SKIP
	add	d4,d4
	move	starmove(pc,d4),d4	* d4=speed multiplier

	movea.l	#starlist,a4
	move	#(nstars-1),d5	* FOR (all stars) DO
flstarlp:
	move	(a4),d0
	muls	d4,d0
	add.l	d0,(a4)		* Xpos=Xpos+Multiplier(Xpos)

	move	4(a4),d0
	muls	d4,d0
	add.l	d0,4(a4)	* Ypos=Ypos+Multiplier(Ypos)

	move	(a4),d0
	bpl	flst1
	neg	d0
flst1:	cmp	#160,d0		* test new Xpos for validity
	bge	flstnew
	move	4(a4),d0
	bpl	flst2
	neg	d0
flst2:	cmp	#64,d0		* test new Ypos for validity
	ble	flstok
flstnew:
*   Create a New Star to Replace a Lost One
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	bpl	nusta1		* restrict range of Xpos
	ori	#$0c0,d0
	bra	nusta2
nusta1:	andi	#$3f,d0
nusta2:	swap	d0		* sign-extended 32-bit random
	move.l	d0,(a4)		* Xpos = {-64 .. 63}
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	bpl	nusta3		* restrict range of Ypos
	ori	#$0e0,d0
	bra	nusta4
nusta3:	andi	#$01f,d0
nusta4:	swap	d0		* sign-extended 32-bit random
	move.l	d0,4(a4)	* Ypos = {-32 .. 31}

flstok:
	addq.l	#8,a4		* point to next star info
	dbra	d5,flstarlp
flstxit:
	rts


*
*	DRAWSTARS   Draws a  screenful of stars on a zeroed background
*
*	Given:
*		STARLIST = address of list of stars X,Y,Color
*
*	Returns:
*		all stars drawn into current buffer
*
*	Register Usage:
*		destroys a0-a2 and d0-d3
*
*	Externals:
*		none
*
drawstars:
	movea.l	#starlist,a0
	movea.l	screen,a1
	movea.l	#x160tbl,a2
	move	#(nstars-1),d3	* FOR (all stars) DO
drstarlp:
	move	(a0),d0
	add	#160,d0		* d0 = star screen Xpos
	move	4(a0),d1
	add	#78,d1		* d1 = star screen Ypos
	cmp	#133,d1
	bgt	drstarskip	* IF (Ypos acceptable) THEN
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
drstarskip:
	addq.l	#8,a0		* bump pointer to next star
	dbra	d3,drstarlp
	rts


*
*	HYPERSTARS   Initializes Stars for Hyper-Return
*
*	Given:
*		Control
*
*	Returns:
*		all stars X and Y randomly localized
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
hyperstars:
	movea.l	#starlist,a0
	move	#(nstars-1),d1	* FOR (all stars) DO
hypstarlp:
	move.l	(a0),d0
	bpl	hypst1
	or.l	#$0fff00000,d0
	bra	hypst2
hypst1:	and.l	#$0fffff,d0
	add.l	#$10000,d0	* Ensure Non-Zero
hypst2:	move.l	d0,(a0)+	* Reduce Xposn to {-16 .. 15}
	move.l	(a0),d0
	bpl	hypst3
	or.l	#$0fff80000,d0
	bra	hypst4
hypst3:	and.l	#$7ffff,d0
hypst4:	move.l	d0,(a0)+	* Reduce Yposn to {-8 .. 7}
	dbra	d1,hypstarlp
	rts


*
*	INITSTARS   Initializes a  screenful of stars
*
*	Given:
*		STARLIST = address of list of stars X,Y
*
*	Returns:
*		all stars X and Y randomly initialized
*
*	Register Usage:
*		destroys a0 and d0-d4
*
*	Externals:
*		none
*
initstars:
	movea.l	#starlist,a0
	move	#(nstars-1),d4	* FOR (all stars) DO
instarlp:
	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	swap	d0		* sign-extended 32-bit random
	move.l	d0,(a0)+	* Xpos = {-128 .. 127}

	jsr	randu		* get 24-bit random number
	swap	d0
	ori	#1,d0		* ensure non-zero
	ext	d0
	asr	#1,d0
	swap	d0
	move.l	d0,(a0)+	* Ypos = {-64 .. 63}

	dbra	d4,instarlp
	rts


*
*	DATA STORAGE
*

	.bss

starlist:
	.ds.l	nstars		* X-position (lo-word=fractional part)
	.ds.l	nstars		* Y-position (lo-word=fractional part)

	.end
