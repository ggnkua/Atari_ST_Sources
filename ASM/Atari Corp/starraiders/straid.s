*
*	ST Star-Raiders  copyright 1985 ATARI Corp.  (started 10/15/85 .. RZ)
*
	.text
*
*	PUBLIC SYMBOLS
*
	.globl	adjacent
	.globl	adjlist
	.globl	alathink
	.globl	bombing
	.globl	collrad
	.globl	dietime
	.globl	_difficult
	.globl	difficult
	.globl	dying
	.globl	endgame
	.globl	gameover
	.globl	hyperclean
	.globl	initalien
	.globl	mypal
	.globl	newgame
	.globl	quitgame
	.globl	random
	.globl	randu
	.globl	screen
	.globl	speedtbl
	.globl	_staraid
	.globl	tactics
	.globl	truespeed
	.globl	vbclock
	.globl	warping

*
*	HARDWARE CONSTANTS
*
palette	.equ	$ff8240		* color0 - palette base address
vidcnt	.equ	$ff8209		* Video Address Counter (Lo)
rezmode	.equ	$ff8260		* Hardware Resolution Mode
vidbas	.equ	$ff8201		* Video Base Address (Hi)
vblvect	.equ	$70		* System VBlank Vector

*
*	SYSTEM CONSTANTS
*
phystop	.equ	$42e		* top of physical memory
vbclock	.equ	$462		* vblank-driven clock
swv_vec	.equ	$46e		* monitor change vector

*
*	GAME CONSTANTS
*
collrad	.equ	144		* Collision-Detect Radius

dietime	.equ	32		* Time it Takes to Die ( more or less .. )

eshotime .equ	$80		* Enemy Shot Duration

alathink .equ	100		* No. of Services Between Alien Fleet Thinks

maxspeed .equ	19		* Maximum Possible True-Speed

misspd	.equ	7		* Missile Speed Multiplier
fastspd	.equ	6		* Fast Ship Speed Multiplier
medspd	.equ	5		* Medium Ship Speed Multiplier
slowspd .equ	4		* Slow Ship Speed Multiplier
fastvel	.equ	64		* Fast Ship Speed
medvel	.equ	32		* Medium Ship Speed
slowvel .equ	16		* Slow Ship Speed

*
*	System Initialization
*
_staraid:
	movem.l	d4-d7/a4-a6,-(sp)	* Paranoia Strikes Deep ..

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp	* save old ssp

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphys	* save old screen pointer

	move.l	screen1,screen	* init. double-buffers

	move.l	vblvect,oldvbl
	move.l	#vbl,vblvect	* Capture System VBlank Interrupt

	jsr	initsound	* Install and Initialize Sound Handler

	jsr	joystick	* install joystick handler

	move	#1,surgebzy
	move	#3,lifebzy
	move	#5,shieldbzy	* Initialize Re-Draw Counters

*
*	Re-Start from Here ..
*
restart:
	jsr	silence		* Stop Any Residual Sound

	movea.l	#palette,a0
	movea.l	#mypal,a1
	move	#15,d0
paloop:
	move.w	(a1)+,(a0)+	* Build StarRaiders Palette
	dbra	d0,paloop

	move	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,seed		* Initialize Random Number Generator

	clr.l	vbclock		* prevent annual overflow
	clr	gameover
	clr	newgame
	clr	endgame
	clr	quitgame	* reset game flags

	jsr	newcock		* Build a New Cockpit

	jsr	initgalx	* initialize Galactic Quadrant
	
	jsr	initship	* clean new ship
	move	#5,shipspeed
	move	#5,truespeed	* initial speed
	clr	kills		* No Kills yet
	clr	deadbases	* No Losses yet
	clr	viewing
	move	#-1,bzychange
	move	#xscrnctr,xcursor
	move	#yscrnctr,ycursor
	move	#4,xgal
	move	#7,ygal

	jsr	initsect	* initialize our local sector

	jsr	initstars	* initialize first screenful of stars

	jsr	initstaft	* initialize first viewerful of stars

	jsr	timsqinit	* initialize the Time-Square Display

	move	difficult,d0
	add	#$0c007,d0
	jsr	billbadd	* Display Current Difficulty Level

mainlp:
	move.l	vbclock,d0
	addq.l	#2,d0
	move.l	d0,frameno	* synchronization count

	movea.l	#explcycl,a0
	movea.l	#palette,a1
	move	stardate,d0
	and	#$1e,d0
	move	(a0,d0),30(a1)	* Explosion Color Cycle

	jsr	flystars	* streaming stars in flight
	jsr	moveobjs	* move all objects

	tst	gameover
	beq	gameon		* IF (Game Ended) THEN
	jsr	etcobjs		* do post-game attract
	jsr	zipwindow
	jsr	drawstars
	jsr	drawobjs
	jsr	billboard
	move	#$100,blbtimer	* Display Current Difficulty Level (forever)
	jsr	epilogue	* until (forced out)
	tst	energy
	bne	gamewon
	jsr	deadpanel	* Losers Control Panel
	bra	alljoin
gamewon:
	jsr	buzybox
	jsr	dopanel		* Winners Control Panel
	bra	alljoin

gameon:	tst	dying
	beq	living		* IF (You are Dying) THEN
	jsr	death		* .. die
	jsr	zipwindow
	bra	hyperjoin
living:				* ELSE
	tst	bombing
	beq	nobombing	* IF (Bomb Activated) THEN
	subq	#1,bombing	* Count-Down
	bne	nobombing	* .. to ZERO
	move	#dietime,dying	* .. oops .. crispy critters
	bra	hyperjoin
nobombing:
	tst	hyperon
	bne	hyperactive
	move	stardate,d1
	and	#7,d1
	cmp	#7,d1
	bne	spedok		* Update Speed Every Eighth Buffer
	move	truespeed,d0
	move	shipspeed,d1
	tst	warpdmg
	beq	spedsk
	asr	#1,d1		* Engine Damage Forces Half Speed
spedsk:	cmp	d1,d0
	beq	spedok
	blt	spedlt
	subq	#1,d0
	bra	spedjn
spedlt:	addq	#1,d0
spedjn:	move	d0,truespeed	* TrueSpeed Follows ShipSpeed
spedok:	jsr	zipwindow	* clear the window of old junk
	move	truespeed,d0
	cmp	#9,d0
	bgt	hyperjoin	* IF (Normal Space) THEN
	jsr	flystaft	* streaming stars in flight (behind)
	move.b	stick1,d0	* handle joystick
	ror.b	#1,d0
	bcc	down
	jsr	upstars		* UP
	jsr	upstaft
	jsr	upobjs
	bra	lrtest
down:	ror.b	#1,d0
	bcc	lrtest
	jsr	downstars	* DOWN
	jsr	downstaft
	jsr	downobjs
lrtest:
	move.b	stick1,d0
	ror.b	#3,d0
	bcc	right
	jsr	leftstars	* LEFT
	jsr	leftstaft
	jsr	leftobjs
	bra	trigger
right:	ror.b	#1,d0
	bcc	trigger
	jsr	rightstars	* RIGHT
	jsr	ritestaft
	jsr	rightobjs
trigger:
	move.b	stick1,d0
	move.b	oneshot,d1
	move.b	d0,oneshot
	eor.b	d1,d0
	and.b	stick1,d0	* One-Shot the Trigger
	bpl	notrigger
	jsr	shoot		* Shoot em
notrigger:
	bra	hyperjoin

hyperactive:			* ELSE (We must be in HyperSpace)
	tst	warping
	beq	hyping		* IF (Actually in WarpSpace)
	jsr	zipwindow	* THEN See Nothing
	move	#$13,d0
	jsr	subenergy	* Count Energy Usage
	subq	#1,warping
	bne	hyperdone
	tst	badguys
	beq	hypa1		* IF (Alien Infested) THEN
	move	#$0e001,d0
	jsr	billbadd	* "Red Alert"
	move.l	#redalsnd,d1
	move	#avoice,d0
	jsr	startsound	* Start Red Alert Noise
	bra	hypa2
hypa1:	move.l	#outhpsd0,d1	* ELSE Empty Sector
	move	#avoice,d0
	jsr	startsound
	move.l	#outhpsd1,d1
	move	#bvoice,d0
	jsr	startsound	* Start Normal Space Noise
hypa2:	jsr	hyperstars
	clr	hyperon		* Until Destination Reached
	bra	hyperdone

hyping:	move	truespeed,d0	* ELSE
	cmp	#maxspeed,d0
	blt	hyperbuild	* IF (Speed Maxed-Out) THEN HyperJump
	tst	bombing
	beq	hyper1		* IF (Smart Bombing) THEN
	clr	bombing		* Stop Bombing
	move	xgal,d0
	asl	#8,d0
	or	ygal,d0
	jsr	insector
	tst	d1
	bmi	hyper1
	tst	d0
	beq	hyper1		* IF (Alien Fleet Here) THEN
	move	d1,d0
	jsr	delfleet	* Wipe-Out the Alien Fleet
hyper1:	jsr	silence
	move	#avoice,d0
	move.l	#inhypsnd,d1
	jsr	startsound	* Start InHyper Noise
	jsr	hyperjump
	bra	hyperjoin

hyperbuild:			* ELSE  Clear the Window of Objects
	movea.l	#objid,a0	* a0 = object I.D.-List ptr
	movea.l	#zpos,a1	* a1 = object Zpos-List ptr
	movea.l	#zvel,a2	* a2 = object Zvel-List ptr
	movea.l	#xpos,a3	* a3 = object Xpos-List ptr
	movea.l	#ypos,a4	* a4 = object Ypos-List ptr
	clr	d2		* d2 = Object-in-Front Flag
	move	#nobjects-1,d3
hyproblp:			* FOR (all objects) DO
	clr.l	(a2)+		* Kill any Z-Velocity Component
	move	(a0)+,d0
	bmi	hyprobjn	* IF (object exists) THEN
	move	(a1),d1
	bmi	hyprb1
	cmp	#$4000,d1
	bgt	hyprb1
	cmp	(a3),d1
	blt	hyprb1
	cmp	(a4),d1
	blt	hyprb1		* IF (object visible in front)
	addq	#1,d2		* THEN Remember It's There
	bra	hyprobjn
hyprb1:	move	#$0a000,(a1)	* ELSE Hide It and Keep It Hidden
hyprobjn:
	addq.l	#4,a1
	addq.l	#4,a3
	addq.l	#4,a4
	dbra	d3,hyproblp

	tst	d2
	bne	hyprb2		* IF (No Objects In Window)
	tst	hyperclean	* THEN Clear two more frames
	bmi	hyprb3
	subq	#1,hyperclean
	bne	hyprb2
	move	#avoice,d0
	move.l	#uphpsnd0,d1
	jsr	startsound	* Hyper Engines Kick-In
	move	#bvoice,d0
	move.l	#uphpsnd2,d1
	jsr	startsound
hyprb2:	jsr	zipwindow	* ELSE Prevent Drawn Object Flicker
	move	truespeed,d0	* Restrain Speed Build-Up
	cmp	#10,d0
	blt	hyprb3
	subq	#1,truespeed
hyprb3:	move	stardate,d0
	and	#7,d0		* (Every Eighth Buffer)
	bne	hyperjoin
	addq	#1,truespeed	* Continue to Build Up Speed

hyperjoin:
	jsr	keyboard	* read the keyboard

	jsr	drawstars	* draw the stars
	jsr	drawobjs	* draw and sort all objects

hyperdone:
	jsr	debase		* StarBase Thinking
	jsr	strategy	* Alien Fleet Strategic
	jsr	rocky		* Rock as Needed ..

	jsr	dopanel		* Update Control Panel and its vars
	jsr	computer	* Maintain the Attack Computer
	jsr	buzybox		* Maintain the Main Busy Box
	jsr	timesqar	* run the message window marquee
	jsr	billboard	* and/or the Billboard

	jsr	etcobjs		* do all other object handling
	jsr	energyuse	* Use Energy
	tst	energy
	bne	wintest		* DEATH CONDITION #1:
	move	#1,endgame
	jsr	newcock		*  .. Out of Energy
*
*	Common End of Frame Processing
*
wintest:
	tst.l	fleets
	bne	alljoin
	move	#1,endgame	* WIN CONDITION !!
alljoin:
	move.l	screen0,d0
	move.l	screen1,d1
	cmp.l	screen,d0
	beq	scrswap
	exg.l	d0,d1		* alternate buffers every frame
scrswap:
	move.l	d1,screen
	lsr.l	#8,d0
	movea.l	#vidbas,a0
	movep	d0,0(a0)	* display finished buffer

	move.l	frameno,d0
	cmp.l	vbclock,d0
	bgt	coldframe
	move.l	vbclock,d0
	addq	#1,d0		* Increment for Frame-Synch
*	ble	hotframe	* KLUDGE!! for Framing-Rate Test
coldframe:
	cmp.l	vbclock,d0
	bgt	coldframe	* maintain synchronization
hotframe:
	tst	newgame
	bne	restart		* UNTIL(Re-Start request)
	tst	quitgame
	bne	exit		* OR(abort request)
	tst	endgame
	beq	mainlp		* OR(end request)
*
*	End of Game Evaluation
*
	clr	endgame
	jsr	evaluate	* Score the Game
	move	difficult,d0
	add	#$0c007,d0
	jsr	billbadd	* Display Current Difficulty Level
	move	#5,truespeed
	move	#2,freshmap
	clr	viewing		* Force GMap
	clr	hyperon
	clr	warping
	move	#-1,bzychange
	jsr	silence		* All Quiet on the Video Front
	move	#1,gameover
	bra	mainlp		* enter attract mode

exit:
	jsr	unsound		* Restore System 200Hz Vector

	move.l	oldvbl,vblvect	* Restore System VBlank Interrupt

	movea.l	#palette,a0
	movea.l	#mypal,a1
	move	#15,d0
xitpal:	move.w	(a1)+,(a0)+	* Restore StarRaiders Palette
	dbra	d0,xitpal

	move.l	savessp,-(sp)
	move.w	#$20,-(sp)
	trap	#1		*return to user mode
	addq.l	#6,sp

	clr	-(sp)
	move.l	oldphys,-(sp)
	move.l	oldphys,-(sp)
	move	#5,-(sp)
	trap	#14
	adda.w	#12,sp		* restore screen pointer

	jsr	unstick		* restore mouse control

abort:
	movem.l	(sp)+,d4-d7/a4-a6	* Paranoia Strikes Deep ..
	rts			* Return to Menu Manager


*
*	SUBROUTINE AREA
*

*
*	VBL	Vertical-Blank Interrupt Server
*
vbl:
	movem.l	d0/a0,-(sp)	* Save Working Registers

	addq.l	#1,vbclock	* Count a Frame

	move.b	rezmode,d0
	and	#3,d0
	cmp	#2,d0
	blt	vblrezok	* Prevent Damage to High-Resolution Monitors
	move.l	swv_vec,a0
	jmp	(a0)		* PANIC! Jump Thru Authorized Reset Vector
vblrezok:
	
	movem.l	(sp)+,d0/a0	* Restore Registers
	rte


*
*	EVALUATE   Computes Final Ranking
*
*	Given:
*		Control
*
*	Returns:
*		w/Evalstr Initialized, Parade Flag Set
*
*	Register Usage:
*		destroys a0-a3 and d0-d6??
*
*	Externals:
*		none
*
evaluate:
	clr	d0		* d0 = Score Accumulator
	move	#-1,parade
	tst.l	fleets
	bne	eval0
	move	#32,parade	* IF (All Aliens Killed) THEN Parade!
eval0:	move	kills,d1
	move	d1,d2
	and	#$0f0,d2
	asr	#1,d2
	move	d2,d3
	asr	#2,d3
	add	d3,d2
	and	#$0f,d1
	add	d2,d1		* d1 = BCD converted #Kills
	asl	#3,d1
	add	d1,d0		* 8 pts per Alien
	move	deadbases,d1
	muls	#40,d1
	sub	d1,d0		* MINUS 40 pts per StarBase
	move.l	vbclock,d1
	move	#10,d2
	asr.l	d2,d1
	and	#$7fff,d1
	sub	d1,d0		* MINUS 4 pts per Minute Played
	bmi	eval8
	tst	energy
	bne	eval1
	sub	#32,d0		* Death Penalty = -32 pts
	bpl	eval1
eval8:	clr	d0		* Bottom-Out at Zero
eval1:	cmp	#320,d0
	blt	eval9
	move	#319,d0		* Max at Rank(9) Class(1)
	bra	eval9
ranktbl:			* Rank NameString Lookup Table
	.dc.l	rankstr0,rankstr1,rankstr2,rankstr3,rankstr4
	.dc.l	rankstr5,rankstr6,rankstr7,rankstr8,rankstr9
eval9:	move	d0,d1
	asr	#3,d1
	and	#$3c,d1		* d1 = 4*(Rating)
	movea.l	#evalstr,a1
	movea.l	ranktbl(pc,d1),a0
eval2:	move.b	(a0)+,(a1)+	* Copy Rank String
	bne	eval2
	subq.l	#1,a1
	movea.l	#classtr,a0
eval3:	move.b	(a0)+,(a1)+	* Copy Class String
	bne	eval3
	subq.l	#2,a1
	move	d0,d1
	asr	#3,d1
	and	#3,d1
	eor	#3,d1
	add.b	d1,(a1)		* Add Class Number

	move	#-1,hightime	* Clear High Score Flag
	movea.l	#evalstr,a0
	movea.l	#_highscor+504,a1
scor0:	move.b	(a0)+,(a1)+
	bne	scor0		* Save this Last Score String
	cmp	#32,d0
	blt	scorxit		* IF (Halfway Decent Score) THEN
	move	difficulty,d1
	muls	#160,d1
	add	d1,d0		* d0 = Level/Rank Composite Score
	movea.l	#_highscore+502,a0
	cmp	(a0),d0
	blt	scorxit		* IF (This Score is a High Score)
	move	d0,newscore
	move	#$80,hightime	* Set High Score Flag
	movea.l	#nsdefault,a0
	movea.l	#namestr,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+	* Init Name String
	clr	nameoff
scorxit:
	rts


*
*	EPILOGUE  Displays Final Rating & Accepts High Scores
*
*	Given:
*		Control
*
*	Returns:
*		Screen
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		showrank, subkybd, goodshow,tenshun
*
epilogue:
	tst	parade
	bmi	rainedout
	subq	#1,parade	* Count Parade Wait 
	bpl	rainedout
	jsr	tenshun		* .. and Start Parade as needed ..
rainedout:
	tst	hightime
	bne	epinorm		* IF (Accepting a Name) THEN
	jsr	goodshow	* Accept It
	rts
epinorm:			* ELSE Normal Epilogue
	bmi	epskip
	subq	#1,hightime	* counting down
epskip:	jsr	showrank
	jsr	subkybd
	rts


*
*	TENSHUN	   Line Everybody Up for the Big Parade
*
*	Given:
*		Control
*
*	Returns:
*		w/ Objects Used Up
*
*	Register Usage:
*		destroys a0-a3 and d0-d6??
*
*	Externals:
*		none
*
tenpins:
	.dc.w	0,707
ninepins:
	.dc.w	1000,707,0,-707,-1000,-707,0,707
tenshun:
	movea.l	#objid,a0	* a0 = Object ID ptr
	movea.l	#xpos,a1	* a1 = Object Xpos ptr
	movea.l	#ypos,a2	* a2 = Object Xpos ptr
	movea.l	#zpos,a3	* a3 = Object Xpos ptr
	movea.l	#xvel,a4	* a4 = Object Xvel ptr
	movea.l	#yvel,a5	* a5 = Object Xvel ptr
	movea.l	#zvel,a6	* a6 = Object Xvel ptr
	move.l	#$40000000,d6	* d6 = Zpos
	move	#15,d7		* FOR (Sixteen Distances) DO
tenshlp:
	move	d7,d2
	add	d2,d2
	and	#$0e,d2
	move	tenpins(pc,d2),d0
	move	ninepins(pc,d2),d1
	ext.l	d0
	swap	d0		* d0 = new Xpos
	ext.l	d1
	swap	d1		* d1 = new Ypos
	move	#victship,(a0)+
	move	#victship,(a0)+	* Pair of Parade Ships
	move.l	d0,(a1)+
	neg.l	d0
	move.l	d0,(a1)+
	move.l	d1,(a2)+
	neg.l	d1
	move.l	d1,(a2)+
	add.l	#$2000000,d6
	move.l	d6,(a3)+
	add.l	#$2000000,d6
	move.l	d6,(a3)+	* Initialize Posn
	move.l	#0,(a4)+
	move.l	#0,(a4)+
	move.l	#0,(a5)+
	move.l	#0,(a5)+
	move.l	#$ff000000,(a6)+
	move.l	#$ff000000,(a6)+	* Initialize Velocity

	dbra	d7,tenshlp
	rts


*
*	GOODSHOW    Accepts High Score Name
*
*	Given:
*		Control
*
*	Returns:
*		Screen
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		text_blt
*
goodshow:
	move	#16,d0
	move	#28,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr0,a0
	jsr	text_blt	* .. From Starfleet
	move	#32,d0
	move	#44,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#gdstr0,a0
	jsr	text_blt	* .. Greetings
	move	#32,d0
	move	#60,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#gdstr1,a0
	jsr	text_blt	* .. You may already be a weiner
	move	#32,d0
	move	#76,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#gdstr2,a0
	jsr	text_blt	* .. Your Name
	move	#32,d0
	move	#92,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#namestr,a0
	jsr	text_blt	* .. Name String
*
*	Read Keyboard and Build Name String
*
	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13		* test for console input
	addq.l	#4,sp
	tst	d0
	bne	godkb0
	rts
godkb0:
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp		* read console, d0 = input word
*
*	CASE (key-input)
*
	cmp.b	#'C'-64,d0
	bne	godkb1		* CTRL-C
	move	#1,quitgame	* Request Game Abort
	bra	acceptor
godkb1:	cmp.b	#'S'-64,d0	
	bne	godkb2		* CTRL-S
	move	#1,newgame	* Request a New Game
	bra	acceptor
godkb2:	cmp.b	#$0d,d0
	beq	acceptor	* CARRIAGE RETURN
	cmp.b	#08,d0
	bne	godkb3		* BACK SPACE
	movea.l	#namestr,a0
	move	nameoff,d0
	beq	godbs0		* Special Case Start of String
	subq	#1,d0
godbs0:	move.b	#'_',(a0,d0)	* Remove the Old Char
	move	d0,nameoff
	rts
godkb3:	tst.b	d0
	beq	godkb4		* ALMOST ANYTHING ELSE
	move	nameoff,d1
	cmp	#12,d1
	bge	godkb4		* IF (Name Still Short) THEN
	movea.l	#namestr,a0
	move.b	d0,(a0,d1)
	addq	#1,nameoff	* Add Character to Name String
godkb4:	rts
*
*	High Score Accept and Add
*
leveltbl:			* Difficulty Level Letters
	.dc.b	"NPWC"
acceptor:			* Add this name to the High Score Table
	movea.l	#namestr,a0
	move	nameoff,d0
accpt0:	move.b	#' ',(a0,d0)	* Blank Unused Portion of Name String
	addq	#1,d0
	cmp	#16,d0
	blt	accpt0
	move	difficulty,d0
	move.b	leveltbl(pc,d0),13(a0)

	move	newscore,d0
	movea.l	#_highscores,a0
accpt1:	cmp	40(a0),d0	* Find Insertion Location
	bge	accpt2
	adda	#42,a0
	bra	accpt1

accpt2:	movea.l	#_highscore+420,a1
	movea.l	#_highscore+462,a2
accpt3:	cmpa.l	a0,a2		* WHILE (Scores Remain) DO
	beq	accpt5
	move	#20,d0
accpt4:	move	(a1)+,(a2)+	* Copy a Score
	dbra	d0,accpt4
	suba	#84,a1
	suba	#84,a2		* Bump Ptrs to Next Score
	bra	accpt3

accpt5:	move	newscore,40(a0)	* Save Actual Level/Ranking
	movea.l	#namestr,a1
	move	#14,d0
accpt6:	move.b	(a1)+,(a0)+	* Copy Name String to New Score
	dbra	d0,accpt6
	movea.l	#evalstr,a1
accpt7:	move.b	(a1)+,(a0)+	* Append Evaluation String
	bne	accpt7

	move	#-1,hightime	* Clear the High Score Request
	rts


*
*	SHOWRANK    Displays Final Rating
*
*	Given:
*		Control
*
*	Returns:
*		Screen
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		text_blt
*
showrank:
	move	#16,d0
	move	#28,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr0,a0
	tst	energy
	bne	shrnk0
	movea.l	#lostr0,a0
shrnk0:	jsr	text_blt	* .. From Starfleet
	move	#32,d0
	move	#44,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr1,a0
	tst	energy
	bne	shrnk1
	movea.l	#lostr1,a0
shrnk1:	jsr	text_blt	* .. Condition
	move	#32,d0
	move	#60,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr2,a0
	tst	energy
	bne	shrnk2
	movea.l	#lostr2,a0
shrnk2:	jsr	text_blt	* .. What One
	move	#32,d0
	move	#76,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr3,a0
	tst	energy
	bne	shrnk3
	movea.l	#lostr3,a0
shrnk3:	jsr	text_blt	* .. What Two
	move	#32,d0
	move	#92,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#wnstr4,a0
	tst	energy
	bne	shrnk4
	movea.l	#lostr4,a0
shrnk4:	jsr	text_blt	* .. New Rank
	move	#32,d0
	move	#112,d1
	move	#$0f,d2
	move	#1,d3
	movea.l	#evalstr,a0
	jsr	text_blt	* Evaluation String
	rts


*
*	NEWCOCK	   Draws a Clean Cockpit Interior
*
*	Given:
*		Control
*
*	Returns:
*		Screen0 and Screen1 Updated
*
*	Register Usage:
*		destroys a0-a1 and d0
*
*	Externals:
*		wordcopy
*
newcock:
	movea.l	#topcock,a0
	movea.l	screen0,a1
	move	#(14*80),d0
	jsr	wordcopy	* copy top of panel to screen0
	movea.l	#topcock,a0
	movea.l	screen1,a1
	move	#(14*80),d0
	jsr	wordcopy	* copy top of panel to screen1
	move.l	#botcock,a0
	movea.l	screen0,a1
	adda.l	#(134*160),a1	* offset into screen0
	move	#(66*80),d0
	jsr	wordcopy	* copy bottom of panel to screen0
	move.l	#botcock,a0
	movea.l	screen1,a1
	adda.l	#(134*160),a1	* offset into screen1
	move	#(66*80),d0
	jsr	wordcopy	* copy bottom of panel to screen1
	rts


*
*	ROCKY	Handle Rock Generation
*
*	Given:
*		Control
*
*	Returns:
*		w/ Object-List Updated as needed.
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		randu,freeobj
*
numrocks:				* Asteriod Swarms
	.dc.w	0,0,0,0,0,0,0,1,2,2,3,4,5,6,7,7
rocky:
	tst	hyperon
	bne	norocks			* Though not while in Hyper-Drive
	move	stardate,d0
	and	#$0ff,d0
	bne	norocks			* Every-Now-and-Then-DO
	movea.l	#objid,a0
	move	#7,d0
rocky0:	tst	(a0)+
	bpl	norocks
	dbra	d0,rocky0		* IF (Nothing Around) THEN

	jsr	randu			* Add Some Rocks to Spice Things Up
	swap	d0
	and	#$1e,d0
	move	numrocks(pc,d0),d7	* FOR (Random No. of Rocks) DO
rocklp:	jsr	freeobj
	move	d0,d6
	bmi	norocks			* IMPOSSIBLE, No Objects
	add	d6,d6			* d6 = Object Index
	movea.l	#distance,a0
	clr	(a0,d6)			* Clear Distance
	jsr	randu
	and	#$0e77,d0
	or	#rockid,d0
	movea.l	#objid,a0
	move	d0,(a0,d6)		* Add a Rock Object
	add	d6,d6
	jsr	randu
	tst	d0
	bmi	rocky2
	and	#$07ff,d0
	bra	rocky3
rocky2:	or	#$0f800,d0
rocky3:	swap	d0
	movea.l	#xpos,a0
	move.l	d0,(a0,d6)		* Xpos = {-$800 .. $7ff}
	jsr	randu
	tst	d0
	bmi	rocky4
	and	#$07ff,d0
	bra	rocky5
rocky4:	or	#$0f800,d0
rocky5:	swap	d0
	movea.l	#ypos,a0
	move.l	d0,(a0,d6)		* Ypos = {-$800 .. $7ff}
	jsr	randu
	tst	d0
	bmi	rocky6
	and	#$0fff,d0
	bra	rocky7
rocky6:	or	#$0f000,d0
rocky7:	add	#$4000,d0
	swap	d0
	movea.l	#zpos,a0
	move.l	d0,(a0,d6)		* Zpos = $4000 +/- $1000
	jsr	randu
	ext.l	d0
	movea.l	#xvel,a0
	move.l	d0,(a0,d6)		* Random Small Xvel
	jsr	randu
	ext.l	d0
	movea.l	#yvel,a0
	move.l	d0,(a0,d6)		* Random Small Yvel
	jsr	randu
	and	#$38,d0
	or	#$0ffc0,d0
	swap	d0
	clr	d0
	movea.l	#zvel,a0
	move.l	d0,(a0,d6)		* Random Large Zvel
	dbra	d7,rocklp
norocks:
	rts


*
*	DEBASE   Handle Starbase Surround and Die
*
*	Given:
*		Control
*
*	Returns:
*		w/ BASES, BASENDX and BASETIME Updated
*
*	Register Usage:
*		destroys a0-a2 and d0-d5??
*
*	Externals:
*		adjacent,delbase,addfleet,billbadd
*
debase:
	movea.l	#bases,a0
	move	basendx,d0	* d0 = Index to Active Base
	tst	(a0,d0)
	bne	dbase0		* IF (No Base Here)
	clr	basendx		* THEN Wrap to ListTop
	rts
dbase0:	movea.l	#basetime,a0	* ELSE
	subq	#1,(a0,d0)
	bpl	dbasjn		* IF (Timed-Out) THEN
dbase1:	move	#32,(a0,d0)	* Reset Timer
*
*	Individual Base Thinking
*
	movea.l	#bases,a0
	move	(a0,d0),d0
	jsr	adjacent
	move	adjlist,d0
	and	adjlist+2,d0
	and	adjlist+4,d0
	beq	dbase8		* IF (Surrounded) THEN
	move	basendx,d0
	add	d0,d0
	movea.l	#basedie,a0
	move.l	(a0,d0),d1
	beq	dbase7		* IF (Timer Already Running) THEN
	cmp.l	vbclock,d1
	bge	dbasjn
	move	xgal,d1
	asl	#8,d1
	or	ygal,d1		* d1 = Composite StarRaider Location
	move	basendx,d0
	movea.l	#bases,a0
	cmp	(a0,d0),d1
	beq	dbasjn		* IF (Timed-Out AND (No StarRaider Here)) THEN
	addq	#1,deadbases	* Another One Bytes the Dust ..
	move	(a0,d0),d1	* d1 = Old Base Location
	jsr	delbase		* Remove Old Base
	move.w	#2,d0
	swap	d0		* d0 = Two Ship Alien Fleet
	move	d1,d0
	jsr	addfleet
	jsr	chooser		* Aliens, Choose Yer Partners
	tst	radiobzy
	bpl	dbase6		* IF (Radio Working) THEN
	rts
dbase6:	move	#$0e006,d0
	jsr	billbadd	* "Base Destroyed"
	move.l	#deadsnd,d1
	jsr	startsad	* Start DeadBase Noise
	rts			* NOTE: Exit
dbase7:	moveq.l	#4,d1		* ELSE Start Timer
	sub	difficulty,d1
	ror	#5,d1		* roughly 30 seconds per difficulty level
	add.l	vbclock,d1
	move.l	d1,(a0,d0)
	tst	radiobzy
	bmi	dbasjn		* IF (Radio Working) THEN
	move	#$0e005,d0
	jsr	billbadd	* "Base Surrounded"
	move	#2,freshmap
	move.l	#surrsnd,d1
	jsr	startsad	* Start Surrounded Noise
	bra	dbasjn
dbase8:	move	basendx,d0	* ELSE Not Surrounded
	add	d0,d0
	movea.l	#basedie,a0
	tst.l	(a0,d0)
	beq	dbasjn		* IF (We Were Surrounded) THEN
	move	#2,freshmap
	clr.l	(a0,d0)		* Clear Death Timer

dbasjn:	addq	#2,basendx	* Bump Index to Next Base
	rts


*
*	STRATEGY   Handle Alien Fleet Grand Strategy
*
*	Given:
*		Control
*
*	Returns:
*		w/ FLEETS, FLEETNDX and FLEETIME Updated
*
*	Register Usage:
*		destroys a0-a2 and d0-d7 ??
*
*	Externals:
*		adjacent,delfleet,addfleet,chooser
*
strategy:
	movea.l	#fleets,a0
	move	fleetndx,d0	* d0 = Index to Active Fleet
	tst.l	(a0,d0)
	bne	strat0		* IF (No Fleet Here)
	clr	fleetndx	* THEN Wrap to ListTop
	rts
strat0:	movea.l	#fleetime,a0	* ELSE
	asr	#1,d0
	subq	#1,(a0,d0)
	bpl	strajn		* IF (Timed-Out) THEN
strat1:	move	#alathink,(a0,d0)	* Reset Timer

	tst	marines
	bne	stratok		* IF (Mainline Strategy) THEN
	movea.l	#fleets,a0
	tst.l	20(a0)		* Check for Sixth Fleet ("Hello, Moamar?")
	bne	stratok
	move	#1,marines
	jsr	chooser		* Time for a new Strategy!
*
*	Individual Alien Thinking
*
stratok:
	movea.l	#fleets,a0	* a0 = Fleets Ptr
	move	fleetndx,d0
	move.l	(a0,d0),d0	* d0 = Alien Fleet Info
	move	xgal,d1
	asl	#8,d1
	or	ygal,d1		* d1 = Composite StarRaider X-Y
	cmp	d1,d0
	beq	strajn
	jsr	adjacent
	tst	d0
	bmi	stratego	* We are next to a base
	tst	marines
	beq	strajn		* So Stay Here Unless in Marine Mode
	move	fleetndx,d1
	movea.l	#fleets,a0
	cmp.b	(a0,d1),d0
	beq	strajn		* Marines Stay Only at the Group Base

stratego:			* IF ((NOT Fighting)AND(NOT Near a Base)) THEN
	move	fleetndx,d0
	movea.l	#fleets,a0
	clr	d4
	move.b	(a0,d0),d4	* d4 = Target-Base Index (-1 ==> None)
	bmi	strandom
*
*	Build Map-Matrix
*
	movea.l	#template,a0
	movea.l	#mapmatrix,a1
	move	#11,d0
tmplay:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+	* Initialize Map-Matrix from Template
	dbra	d0,tmplay
	movea.l	#mapmatrix,a0	* a0 = Map-Matrix Ptr.
	movea.l	#fleets,a1
fmatlp:	move.l	(a1)+,d0	* WHILE (Fleets Remain) DO
	beq	fmatxit
	move	d0,d1
	asr	#4,d1		* d1 = 16*Xpos
	or.b	d0,d1
	add	#$11,d1
	move.b	#$7f,(a0,d1)	* Mark this Sector as Blocked
	bra	fmatlp
fmatxit:
	movea.l	#bases,a1
bmatlp:	move	(a1)+,d0	* WHILE (StarBases Remain) DO
	beq	bmatxit
	move	d0,d1
	asr	#4,d1		* d1 = 16*Xpos
	or.b	d0,d1
	add	#$11,d1
	move.b	#$7f,(a0,d1)	* Mark this Sector as Blocked
	bra	bmatlp
bmatxit:
	move	xgal,d0
	asl	#4,d0
	or	ygal,d0
	add	#$11,d0
	move.b	#$7f,(a0,d0)	* StarRaider is Just Another Blockage
*
*	Back-Track from Target Base
*
	move	fleetndx,d0
	movea.l	#fleets,a1
	clr	d6
	move.b	2(a1,d0),d6
	asl	#4,d6
	or.b	3(a1,d0),d6
	add	#$11,d6		* d6 = Composite Start Posn
	clr	d1
	move.b	(a1,d0),d1
	movea.l	#bases,a1
	clr	d7
	move.b	(a1,d1),d7
	asl	#4,d7
	or.b	1(a1,d1),d7
	add	#$11,d7		* d7 = Composite Target Posn
	move.b	#$80,(a0,d7)	* Mark Target Sector
backtrack:			* REPEAT
	move	#-1,d5
	movea.l	#expandtbl,a1
	btst	#0,d7
	beq	bakevn
	adda	#3,a1		* Adjust for Odd/Even Sector
bakevn:	move	#2,d3		* FOR (All Three Adjacent) DO
bakxpd:	move	d7,d0
	add.b	(a1,d3),d0	* EXPAND to Adjacent Sector
	tst.b	(a0,d0)
	bne	baknot		* IF (Unmarked Sector) THEN
	addq	#1,d5		* Count it
	move	d0,d4		* Remember it
	move.b	#$80,(a0,d0)	* Mark it as a Target Sector
baknot:	dbra	d3,bakxpd
	tst	d5
	bne	backdone	* UNTIL (Other Than a Single Sector Marked)
	move	d0,d7		* .. make that sector the target ..
	bra	backtrack
backdone:
*
*	Breadth-First Heuristic Search to Find a Path
*
	moveq.l	#0,d0
	move	#8,d1
	movea.l	#openlist,a1
openinit:			* Clear the OpenList
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbra	d1,openinit

	move	d6,d5		* d5 = Current Active Position(.b)
	move	d7,d6
	and	#$0f,d7		* d7 = Target Sector Ypos(.w)
	asr	#4,d6		* d6 = Target Sector Xpos(.w)
	move	#-1,d4		* d4 = OPENLIST Root Ptr
	movea.l	#openlist,a1	* a1 = OPENLIST
	movea.l	#expandtbl,a2
	btst	#0,d5
	beq	pthevn
	adda	#3,a2		* a2 = Proper Expansion Table
pthevn:	move	#2,d3
pthinitlp:			* FOR (First Three Adjacent) DO
	move	d5,d2
	add.b	(a2,d3),d2	* d2 = Expanded Posn(.b)
	tst.b	(a0,d2)
	beq	pthin1
	bpl	pthinx		* IF (A Target Hex!)
	move	d3,d0
	addq	#1,d0		* THEN Success, Walk This Way ..
	bra	stramove
pthin1:	move	d3,d0		* ELSE Add Unblocked Sector to OpenList
	addq	#1,d0
	move.b	d0,(a0,d2)	* Mark This Sector with Direction
	move	d2,d1
	move	d2,d0
	and	#$0f,d1
	asr	#4,d0
	sub	d6,d0
	bpl	pthin2
	neg	d0		* d0 = ABS(Delta-X)
pthin2:	sub	d7,d1
	bpl	pthin3
	neg	d1		* d1 = ABS(Delta-X)
pthin3:	add	d0,d1		* d1 = Distance
	asl	#8,d1
	or	d1,d2		* d2 = Completed Data Record
	move	#-4,d0
pthin4:	addq	#4,d0
	tst	2(a1,d0)	* search OpenList for a Free Slot
	bne	pthin4		* WARNING: No Test For Full List.
	move	d2,2(a1,d0)
	swap	d0		* d0(hi) = ptr to New Data Record

	move	d4,d1		* d1 = HerePtr
	move	d1,d0		* d0(lo) = TherePtr
	bmi	pthin6		* Special Case: Empty OpenList
pthin5:	cmp	2(a1,d0),d2	* WHILE ((new.dist > there.dist) ..
	ble	pthin6
	move	d0,d1		* HerePtr = TherePtr
	move	(a1,d1),d0	* TherePtr = here.link
	bpl	pthin5		*   .. AND (TherePtr <> NIL)) DO

pthin6:	cmp	d1,d0
	bne	pthin7		* IF (HerePtr = TherePtr)
	swap	d0		* THEN Add to Start of OpenList
	move	d4,(a1,d0)
	move	d0,d4
	bra	pthinx
pthin7:	swap	d0		* ELSE Add to Middle of OpenList
	move	(a1,d1),(a1,d0)
	move	d0,(a1,d1)

pthinx:	dbra	d3,pthinitlp
*
*	Trace Path and Find a Working Move
*
tracing:
	tst	d4
	bmi	strandom	* WHILE (Sectors Remain on OpenList) DO
	clr	d5
	move.b	3(a1,d4),d5	* d5 = Current Active Position(.b)
	move	(a1,d4),d3
	clr.l	(a1,d4)		* Re-Cycle Used Record
	move	d3,d4		* root = root.lnk
	movea.l	#expandtbl,a2
	btst	#0,d5
	beq	trcevn
	adda	#3,a2		* a2 = Proper Expansion Table
trcevn:	move	#2,d3
tracelp:			* FOR (First Three Adjacent) DO
	move	d5,d2
	add.b	(a2,d3),d2	* d2 = Expanded Posn(.b)
	tst.b	(a0,d2)
	beq	trace1
	bpl	tracex		* IF (A Target Hex!)
	clr	d0
	move.b	(a0,d5),d0	* THEN Success, Remember How You Got Here.
	bra	stramove

trace1:	move.b	(a0,d5),(a0,d2)	* ELSE Mark Sector with Parent's Direction
	move	d2,d1		*  .. and Add to OpenList
	move	d2,d0
	and	#$0f,d1
	asr	#4,d0
	sub	d6,d0
	bpl	trace2
	neg	d0		* d0 = ABS(Delta-X)
trace2:	sub	d7,d1
	bpl	trace3
	neg	d1		* d1 = ABS(Delta-X)
trace3:	add	d0,d1		* d1 = Distance
	asl	#8,d1
	or	d1,d2		* d2 = Completed Data Record
	move	#-4,d0
trace4:	addq	#4,d0
	tst	2(a1,d0)	* search OpenList for a Free Slot
	bne	trace4		* WARNING: No Test For Full List.
	move	d2,2(a1,d0)
	swap	d0		* d0(hi) = ptr to New Data Record

	move	d4,d1		* d1 = HerePtr
	move	d1,d0		* d0(lo) = TherePtr
	bmi	trace6		* Special Case: Empty OpenList
trace5:	cmp	2(a1,d0),d2	* WHILE ((new.dist > there.dist) ..
	ble	trace6
	move	d0,d1		* HerePtr = TherePtr
	move	(a1,d1),d0	* TherePtr = here.link
	bpl	trace5		*   .. AND (TherePtr <> NIL)) DO

trace6:	cmp	d1,d0
	bne	trace7		* IF (HerePtr = TherePtr)
	swap	d0		* THEN Add to Start of OpenList
	move	d4,(a1,d0)
	move	d0,d4
	bra	tracex
trace7:	swap	d0		* ELSE Add to Middle of OpenList
	move	(a1,d1),(a1,d0)
	move	d0,(a1,d1)

tracex:	dbra	d3,tracelp
	bra	tracing
*
*	Totally Random Motion
*
strandom:			* RANDOM Motion
	jsr	randu
	and	#3,d0
	beq	strajn		* d0 = Random Direction (nomove,1,2,3)
*
*	Implement Selected Move with Double Check for Validity
*
stramove:			* MOTION - Given: d0 = Direction
	movea.l	#adjlist,a0
	subq	#1,d0
	add	d0,d0		* d0 = offset into Adjacency Table
	tst	(a0,d0)
	bne	strajn		* IF (Chosen Move UnBlocked) THEN
	movea.l	#fleets,a0
	move	fleetndx,d1
	btst.b	#0,3(a0,d1)
	beq	stram0
	addq	#6,d0		* Adjust Move for Odd/Even Triangle
stram0:	move.l	(a0,d1),d2	* d2 = Current Fleet Disposition
	add	stmovtbl(pc,d0),d2
	move	xgal,d1
	asl	#8,d1
	or	ygal,d1
	cmp	d1,d2
	beq	strajn		* DON'T Move Onto a StarRaiders
	move	fleetndx,d0
	jsr	delfleet	* Remove Old Fleet Marker
	move.l	d2,d0
	jsr	addfleet	* Place in New Posn

strajn:	addq	#4,fleetndx	* Bump Index to Next Fleet
	rts
stmovtbl:			* Word-Oriented Triangular Motion Table
	.dc.w	-1,1,$0ff01,1,-1,$0ff


*
*	ADJACENT   Tests All Adjacent Sectors for Blockage
*
*	Given:
*		d0 = X-Y Posn of Tester
*
*	Returns:
*		d0 = Adjacent-to-Base Flag (neg ==> not next to one)
*		ADJLIST Updated
*
*	Register Usage:
*		destroys a0-a2 and d0-d5
*
*	Externals:
*		insector
*
adjacent:
	move	d0,d2
	asr	#8,d2		* d2 = Base Xpos
	move	d0,d3
	and	#$0ff,d3	* d3 = Base Ypos
	move	#-1,d4		* d4 = Next-to-Base Flag
	ror	#1,d0
	bcs	adjro1
	movea.l	#evenrow,a1
	bra	adjro2
adjro1:	movea.l	#oddrow,a1	* a1 = Ptr to Movement Offsets
adjro2:	movea.l	#adjlist,a2	* a2 = Ptr to Adjacency List
	move	#2,d5
adjalp:				* FOR (All Three Adjacent) DO
	move	d2,d0
	add	(a1)+,d0
	move	d3,d1
	add	(a1)+,d1	* Compute New X-Y
	cmp	#13,d1
	bhi	adjblk		* Test New Y for Validity
	movea.l	#lfqudtbl,a0
	cmp.b	(a0,d1),d0
	blt	adjblk
	movea.l	#rtqudtbl,a0
	cmp.b	(a0,d1),d0
	bgt	adjblk		* Test New X for Validity
	asl	#8,d0
	and	#$0ff,d1
	or	d1,d0		* d0 = Valid Composite X-Y
	jsr	insector
	tst	d1
	bpl	adjblo		* IF (Sector Clear) THEN
	clr	d0		* Mark as UnBlocked
	bra	adjoin
adjblo:	tst	d0
	bne	adjblk		* IF (Starbase Adjacent) THEN
	move	d1,d4		* Remember its Index
adjblk:				* BLOCKED
	moveq	#1,d0		* Mark as Blocked
adjoin:	move	d0,(a2)+
	dbra	d5,adjalp
	move	d4,d0		* d0 = Next-to-Base Flag
	rts


*
*	INITALIEN    Initialize an Alien Brain and Course
*
*	Given:
*		d5 = Object ID Index
*
*	Returns:
*		w/ Alien Brain and Speed Updated
*
*	Register Usage:
*		destroys a0 and d0-d4
*
*	Externals:
*		randu
*
brainmask:		* Masks Limit Tactics to Difficulty
	.dc.w	$222,$666,$0eee,$0eee
initalien:
	jsr	randu
	move	difficulty,d1
	add	d1,d1
	and	brainmask(pc,d1),d0
	move	d0,d1		* d1 = Randomly Chosen Brain
	movea.l	#attack,a0
	and	#$0e,d0
	move	d0,(a0,d5)	* Init Attack
	asr	#4,d1
	move	d1,d0
	movea.l	#strafe,a0
	and	#$0e,d0
	move	d0,(a0,d5)	* Init Strafe
	cmp	#$0e,d0
	blt	intash
	move	#$0c,d0		* Allow only Seven Dwarfs
intash:	asl	#8,d0
	or	#shipid,d0	* Ship Type Follows Ferocity
	movea.l	#objid,a0
	move	d0,(a0,d5)	* Mark as an Alien Ship
	asr	#4,d1
	move	d1,d0
	movea.l	#retreat,a0
	and	#$0e,d0
	move	d0,(a0,d5)	* Init Retreat

	jsr	randu
	and	#$1ff,d0
	movea.l	#ithink,a0
	move	d0,(a0,d5)	* Random Wait (up to 16 secs)
	movea.l	#alamode,a0
	move	#-1,(a0,d5)	* In Retreat Mode ..
	movea.l	#iwait,a0
	clr	(a0,d5)		*  .. Ready to Attack
	rts


*
*	XYOFFSET   Restricted Range in X-Y Plane
*
*	Given:
*		d0 = Restriction Mask
*
*	Returns:
*		d0 = Restricted Xpos
*		d1 = Restricted Ypos
*
*	Register Usage:
*		destroys d0-d5
*
*	Externals:
*		randu
*
xyoffset:
	move	d0,-(sp)
	jsr	randu
	move.l	d0,random	* Get 24-Bit Random Number
	move	(sp)+,d3
	move	d3,d2
	eor	#-1,d2		* d2 = Inverse Mask
	btst	#11,d0
	bne	xyoff1
	and	d3,d0
	bra	xyoff2
xyoff1:	or	d2,d0		* d0 = Restricted Signed Xpos
xyoff2:	move.l	random,d1
	asl.l	#4,d1
	swap	d1
	btst	#11,d1
	bne	xyoff3
	and	d3,d1
	bra	xyoff4
xyoff3:	or	d2,d1		* d1 = Restricted Signed Ypos
xyoff4:	rts


*
*	ZXYRANDOM    Lay-In a Random Course
*
*	Given:
*		d0 = Speed (16,32,64)
*		d7 = Object ID Index
*
*	Returns:
*		w/ X,Y and Z Velocities Initialized
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		randu
*
zxyrandom:
	move	d0,-(sp)
	jsr	randu
	move.l	d0,random	* Get 24-Bit Random Number
	move	(sp)+,d4
	move	d7,d5
	add	d5,d5		* d5 = Long Index
	movea.l	#xvel,a0
	clr.l	(a0,d5)
	movea.l	#yvel,a0
	clr.l	(a0,d5)
	movea.l	#zvel,a0
	clr.l	(a0,d5)		* Zero Current Velocity
	move	d4,d1
	ext.l	d1
	swap	d1		* d1 = Long Velocity
	tst.b	d0
	bpl	zyrand		* IF (random) THEN Give Zvel
	btst	#3,d0
	beq	zxran1		* In Random Direction
	neg.l	d1
zxran1:	move.l	d1,(a0,d5)	* New Z-Velocity
	btst	#1,d0
	bne	yrando
	btst	#5,d0
	bne	zxrand
	rts
zyrand:				* Give Xvel
	tst	d0
	bpl	zxrand		* IF (random) THEN Give Yvel
yrando:	btst	#13,d0
	beq	zxran2		* In Random Direction
	neg.l	d1
zxran2:	movea.l	#yvel,a0
	move.l	d1,(a0,d5)	* New Y-Velocity
	btst	#10,d0
	bne	zxrand
	rts
zxrand:				* Give Xvel
	btst	#21,d0
	beq	zxran3		* In Random Direction
	neg.l	d1
zxran3:	movea.l	#xvel,a0
	move.l	d1,(a0,d5)	* New X-Velocity
	rts


*
*	CHARGEM   Lay-In a Course Toward Opponent
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List Ptr
*		a2 = Ypos List Ptr
*		a3 = Zpos List Ptr
*
*	Returns:
*		w/ Velocities Initialized, Z Velocity Matched
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		setcourse
*
chargem:
	clr	d0
	clr	d1
	clr	d2
	move	#fastspd,d3
	jsr	setcourse	* Charge Him!
	move	truespeed,d0
	add	d0,d0
	movea.l	#speedtbl,a0
	move	(a0,d0),d0	* d0 = Starraider's Speed
	movea.l	#zvel,a0
	move	d7,d1
	add	d1,d1
	tst	(a3,d1)
	bmi	charg0		* Match Z Velocity
	sub	d0,(a0,d1)
	rts
charg0:	add	d0,(a0,d1)
	rts


*
*	XYRANDOM    Lay-In a Random Course in the X-Y Plane
*
*	Given:
*		d0 = Speed (16,32,64)
*		d7 = Object ID Index
*		a3 = Object Zpos
*
*	Returns:
*		w/ X and Y Velocities Randomized, Z Velocity Matched
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		randu
*
xyrandom:
	move	d0,-(sp)
	jsr	randu
	move.l	d0,random	* Get 24-Bit Random Number
	move	(sp)+,d4
	move	d7,d5
	add	d5,d5		* d5 = Long Index
	move	truespeed,d0
	add	d0,d0
	movea.l	#speedtbl,a0
	move	(a0,d0),d0	* d0 = Starraider's Speed
	tst	(a3,d5)
	bmi	xyran0
	neg	d0
xyran0:	movea.l	#zvel,a0
	move	d0,(a0,d5)	* Match Z Velocity
	movea.l	#xvel,a0
	clr.l	(a0,d5)
	movea.l	#yvel,a0
	clr.l	(a0,d5)		* Zero Current X-Y Velocity
	move	d4,d1
	ext.l	d1
	swap	d1		* d1 = Long Velocity
	tst	d0
	bpl	xrandu		* IF (random) THEN Give Yvel
	btst	#13,d0
	beq	xyran1		* In Random Direction
	neg.l	d1
xyran1:	move.l	d1,(a0,d5)	* New Y-Velocity
	btst	#11,d0
	bne	xrandu
	rts
xrandu:				* Give Xvel
	tst.b	d0
	bpl	xyran2		* In Random Direction
	neg.l	d1
xyran2:	movea.l	#xvel,a0
	move.l	d1,(a0,d5)	* New X-Velocity
	rts


*
*	DEADAHEAD   Lay-In a Course Straight Ahead
*
*	Given:
*		d6 = Strafe Index
*		d7 = Object ID Index
*		a3 = Object Zpos
*
*	Returns:
*		w/ Velocities Initialized
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		none
*
deadahead:
	move	d7,d5
	add	d5,d5		* d5 = Long Index
	movea.l	#xvel,a0
	clr.l	(a0,d5)
	movea.l	#yvel,a0
	clr.l	(a0,d5)
	movea.l	#strspd,a0
	move	(a0,d6),d0	* d0 = Strafing Speed
	move	truespeed,d1
	add	d1,d1
	movea.l	#speedtbl,a0
	add	(a0,d1),d0	* d0 = Starraider's Speed + Desired Speed
	tst	(a3,d5)
	bmi	dead1
	neg	d0		* Correct for Relative Position
dead1:	ext.l	d0
	swap	d0
	movea.l	#zvel,a0
	move.l	d0,(a0,d5)	* Initialize Velocity
	rts


*
*	SETCOURSE   Compute and Lay-In a New Course
*
*	Given:
*		d0 = Target Xpos
*		d1 = Target Ypos
*		d2 = Target Zpos
*		d3 = Speed Multiplier
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ X,Y and Z Velocities
*
*	Register Usage:
*		destroys a0 and d0-d5
*
*	Externals:
*		none
*
setcourse:
	move	d6,-(sp)
	move	d3,temp		* Temp = Speed Multiplier
	move	d7,d6
	add	d6,d6		* d6 = Index into Pos'ns
	sub	(a1,d6),d0	* d0 = X-delta
	bvc	setco2
	bcc	setco1
	move	#$7fff,d0	* Positive Overflow
	bra	setco2
setco1:	move	#$8000,d0	* Negative Overflow
setco2:	sub	(a2,d6),d1	* d1 = Y-delta
	bvc	setco4
	bcc	setco3
	move	#$7fff,d1	* Positive Overflow
	bra	setco4
setco3:	move	#$8000,d1	* Negative Overflow
setco4:	sub	(a3,d6),d2	* d2 = Z-delta
	bvc	setco6
	bcc	setco5
	move	#$7fff,d2	* Positive Overflow
	bra	setco6
setco5:	move	#$8000,d2	* Negative Overflow
setco6:
	move	d0,d3
	bpl	scdst1
	neg	d3		* d3 = ABS(X-delta)
scdst1:	move	d1,d4
	bpl	scdst2
	neg	d4		* d4 = ABS(Y-delta)
scdst2:	move	d2,d5
	bpl	scdst3
	neg	d5		* d5 = ABS(Z-delta)
scdst3:	cmp	d3,d4
	bgt	scdst4
	exg	d3,d4		* d4 = MAX(X-delta,Y-delta)
scdst4:	cmp	d4,d5
	bgt	scdst5
	exg	d4,d5		* d5 = MAX(X-delta,Y-delta,Z-delta)
scdst5:	asr	#2,d3
	asr	#2,d4
	add	d3,d4
	move	d4,d3
	asr	#1,d3
	add	d3,d4
	add	d4,d5		* d5 = MAX + 3/8*MIN + 3/8*MIN
	bvc	okdist
	move	#$7fff,d5	* oops, overflow
okdist:				* d5 = approximate 3D Distance
	move	temp,d3		* d3 = Speed Multiplier
	asr	d3,d5
	bne	okshft
	move	#1,d5		* Guarantee no divide-by-zero
okshft:	ext.l	d0
	divs	d5,d0
	ext.l	d1
	divs	d5,d1
	ext.l	d2
	divs	d5,d2		* Compute Unit-Vector
	ext.l	d0
	swap	d0
	movea.l	#xvel,a0
	move.l	d0,(a0,d6)	* Save New Xvel
	ext.l	d1
	swap	d1
	movea.l	#yvel,a0
	move.l	d1,(a0,d6)	* Save New Yvel
	ext.l	d2
	swap	d2
	movea.l	#zvel,a0
	move.l	d2,(a0,d6)	* Save New Zvel
	move	(sp)+,d6	* Restore d6
	rts


*
*	BADSHOT	  Fire an Enemy Shot
*
*	Given:
*		d0 = Target Xpos
*		d1 = Target Ypos
*		d2 = Target Zpos
*		d7 = Shooter's Object Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ New Shot Initialized
*
*	Register Usage:
*		destroys a0 and d0-d7
*
*	Externals:
*		setcourse
*
badshot:
	move	d0,-(sp)
	move	dying,d0
	or	endgame,d0
	or	gameover,d0
	bne	badsh9		* Aww.. Leave Him Alone, He's Dead.
	jsr	freeobj		* Find the Next Free Object Slot
	tst	d0
	bpl	badsh1
badsh9:	move	(sp)+,d0	* IF (No Objects Available) THEN Exit
	rts
badsh1:	add	d0,d0		* d0 = New Shot Object Index
	movea.l	#objid,a0
	move	#eshotid+eshotime,(a0,d0)
	move	d7,d6
	add	d6,d6		* d6 = Shooters Posn Index
	move	d0,d7
	add	d0,d0		* d0 = New Shot Posn Index
	move.l	(a1,d6),(a1,d0)
	move.l	(a2,d6),(a2,d0)
	move.l	(a3,d6),(a3,d0)	* Initialize Shot Position
	move	(sp)+,d0
	move	#misspd,d3
	jsr	setcourse	* Initialize Velocity
	rts

*
*	LEDSHOT	  Lead Target and Fire an Enemy Shot
*
*	Given:
*		d7 = Shooter's Object Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ New Shot Initialized
*
*	Register Usage:
*		destroys a0 and d0-d7
*
*	Externals:
*		badshot
*
ledshot:
	movea.l	#distance,a0
	move	(a0,d7),d2		* d2 = Distance to Target
	asr	#7,d2			* d2 = delta-Time to Target
	movea.l	#speedtbl,a0
	move	truespeed,d1
	add	d1,d1
	muls	(a0,d1),d2		* d2 = Target's delta-Z
	clr	d0
	clr	d1
	jsr	badshot			* Fire!
	rts

*
*	TACTICS   Tactical Logic for Aliens
*
*	Given:
*		d7 = Object ID Index
*		a0 = Object ID List ptr
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Aliens Brain and Velocity Updated, Shots Launched
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		do_attack,do_strafe,do_retreat
*
tactics:
	tst	gameover
	bne	nothink		* Disable Brain at Game End
	movea.l	#ithink,a0
	subq	#1,(a0,d7)
	bmi	thinking	* Count-Down Think Timer
nothink:
	rts
thinking:
	movea.l	#alamode,a0
	tst	(a0,d7)		* CASE (Current Mode)
	beq	do_strafe
	bmi	do_retreat
	bra	do_attack


*
*	PRE_ATTACK   Attack Run Initialization.
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Aliens Velocity and Timers Initialized
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		xyoffset,do_attack
*
pre_attack:
	movea.l	#alamode,a0
	move	#1,(a0,d7)	* Enter Attack Mode
	movea.l	#attack,a0
	move	(a0,d7),d6	* d6 = Attack Index
	movea.l	#attmask,a0
	move	(a0,d6),d0	* d0 = XY Offset Mask
	jsr	xyoffset	* Generate Desired XY Posn
	movea.l	#xalien,a0
	move	d0,(a0,d7)	* Save Desired Xpos
	movea.l	#yalien,a0
	move	d1,(a0,d7)	* Save Desired Ypos
	movea.l	#attzpos,a0
	movea.l	#zalien,a4
	move	(a0,d6),(a4,d7)	* Save Desired Zpos
	movea.l	#attspd,a0
	movea.l	#spdalien,a4
	move	(a0,d6),(a4,d7)	* Save Desired Speed
	movea.l	#attwait,a0
	movea.l	#iwait,a4
	move	(a0,d6),(a4,d7)	* Initialize Impatience Factor
	jmp	join_attack	* EXIT thru DO_ATTACK ..


*
*	DO_ATTACK    Maintain Attack Until Satisfied with Position
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Velocity Updated, Think Timer Reset
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		pre_strafe,setcourse
*
do_attack:
	move	d7,d6
	add	d6,d6		* d6 = Long Index
	move	(a3,d6),d0
	bpl	doaps1
	tst	difficulty
	beq	doatt1		* IF (Novice) THEN Disallow Rear Shots
	neg	d0
doaps1:	move	(a2,d6),d1	* d0 = ABS(Zpos)
	bpl	doaps2
	neg	d1		* d1 = ABS(Ypos)
doaps2:	tst	difficulty
	bne	doaps4
	asr	#1,d1		* Novice, restrict Viewing Pyramid
doaps4:	cmp	d1,d0
	blt	doatt1
	move	(a1,d6),d1
	bpl	doaps3
	neg	d1
doaps3:	cmp	d1,d0		* d1 = ABS(Xpos)
	blt	doatt1		* IF (Within Viewing Pyramid) THEN

	movea.l	#attack,a0
	move	(a0,d7),d6	* d6 = Attack Index
	movea.l	#distance,a0
	move	(a0,d7),d0	* d0 = Distance to Ship
	movea.l	#attrange,a0
	cmp	(a0,d6),d0
	bgt	doatt1		* IF (Distance <= RANGE)
	jmp	pre_strafe	* THEN Begin to Shoot
doatt1:	movea.l	#iwait,a0
	subq	#1,(a0,d7)
	bne	join_attack	* IF (Waited Long Enuff)
	movea.l	#spdalien,a0	* THEN goto Fast Speed!
	move	#fastspd,(a0,d7)
join_attack:		* NOTE: Entry Point for Pre-Attack
	movea.l	#atthink,a0
	movea.l	#ithink,a4
	move	(a0,d6),d0
	move	difficulty,d1
	cmp	#3,d1
	bne	doatt2		* COMMANDER Difficulty
	subq	#6,d0
doatt2:	move	d0,(a4,d7)	* Reset Think Timer
	movea.l	#xalien,a0
	move	(a0,d7),d0
	movea.l	#yalien,a0
	move	(a0,d7),d1
	movea.l	#zalien,a0
	move	(a0,d7),d2
	movea.l	#spdalien,a0
	move	(a0,d7),d3
	jsr	setcourse	* Lay-In Course
	rts


*
*	PRE_STRAFE   Initialize for Strafing Run
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Aliens Velocity Updated
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		do_strafe,setcourse,deadahead,xyrandom,randu
*
pre_strafe:
	movea.l	#alamode,a0
	clr	(a0,d7)		* Enter Strafe Mode
	movea.l	#strafe,a0
	move	(a0,d7),d6	* d6 = Strafe Index
	jsr	randu
	tst	d0
	bmi	straf2		* 50% XY-Random
	tst.b	d0
	bmi	straf1		* 25% Dead Ahead
	jsr	chargem		* 25% Charge Him
	bra	do_strafe	* EXIT
straf1:	jsr	deadahead	* Forward!
	bra	do_strafe	* EXIT
straf2:	movea.l	#strspd,a0
	move	(a0,d6),d0
	jsr	xyrandom	* Random in XY Plane ..
	bra	do_strafe	* EXIT


*
*	DO_STRAFE    Shoot Until He's Had Enuff ..
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Shots Launched, Think Timer Reset
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		pre_attack,pre_retreat,badshot,ledshot,setcourse,xyrandom,randu
*
do_strafe:
	move	d7,-(sp)
	tst	difficulty
	bne	dostr2
	clr	d0
	clr	d1
	clr	d2
	jsr	badshot		* Novice: Regular Shot
	bra	dostr3
dostr2:	jsr	ledshot		* Other: Lead Target
dostr3:	move	(sp)+,d7
	movea.l	#strafe,a0
	move	(a0,d7),d6	* d6 = Strafing Index
	jsr	randu
	move.l	d0,random
	and	#$7fff,d0	* Get Positive 16-Bit Random Number
	movea.l	#strange,a0
	cmp	(a0,d6),d0
	bgt	dostr4		* IF (Random# < Range)
	jmp	pre_retreat	* THEN Begin Retreat
dostr4:	move	random,d0	* ELSE Continue to Shoot
	cmp	#160,d0
	ble	dostr9		* IF (Random)
	cmp	#$0f0,d0	* THEN Go Evasive
	blt	dostr5
	jsr	chargem		* Charge!
	bra	dostr9
dostr5:	movea.l	#strspd,a0
	move	(a0,d6),d0
	jsr	xyrandom	* Random in XY Plane
dostr9:	movea.l	#strthink,a0
	movea.l	#ithink,a4
	move	(a0,d6),d0
	move	difficulty,d1
	cmp	#3,d1
	bne	dostrz		* COMMANDER Difficulty
	subq	#6,d0
dostrz:	move	d0,(a4,d7)	* Reset Think Timer
	rts


*
*	PRE_RETREAT   Initialize for Retreat Run
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Alien Velocity Updated
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		setcourse,zxyrandom
*
pre_retreat:
	movea.l	#alamode,a0
	move	#-1,(a0,d7)	* Enter Retreat Mode
	movea.l	#strafe,a0
	move	(a0,d7),d6	* d6 = Strafe Index
	cmp	#4,d6
	blt	preat2
	cmp	#8,d6
	bge	preat2
	clr	d0
	clr	d1
	clr	d2
	move	#fastspd,d3
	jsr	setcourse	* Charge Straight At Him!!
	bra	preat4
preat2:	movea.l	#retvel,a0
	move	(a0,d6),d0
	jsr	zxyrandom	* Random Course
preat4:	movea.l	#retwait,a0
	movea.l	#iwait,a4
	move	(a0,d6),(a4,d7)	* Init Wait Counter
	bra	join_retreat	* EXIT thru Retreat


*
*	DO_RETREAT   Maintain Retreat Until Satisfied with Position
*
*	Given:
*		d7 = Object ID Index
*		a1 = Xpos List ptr
*		a2 = Ypos List ptr
*		a3 = Zpos List ptr
*
*	Returns:
*		w/ Aliens Brain Updated, Think Timer Reset
*
*	Register Usage:
*		destroys a0,a4 and d0-d6
*
*	Externals:
*		pre_attack,zxyrandom
*
do_retreat:
	movea.l	#retreat,a0
	move	(a0,d7),d6	* d6 = Retreat Index
	movea.l	#iwait,a0
	subq	#1,(a0,d7)
	bmi	dortr1
	movea.l	#distance,a0
	move	(a0,d7),d0	* d0 = Distance
	movea.l	#retrange,a0
	cmp	(a0,d6),d0
	ble	dortr2		* IF ((Waited Long Enuff)OR(Range OK))
dortr1:	jmp	pre_attack	* THEN Attack!
dortr2:	cmp	#8,d6
	blt	join_retreat	* IF (Desired) THEN Variable Retreat
	movea.l	#retvel,a0
	move	(a0,d6),d0
	jsr	zxyrandom	* Lay-In New Escape Course
join_retreat:		* Entry Point for Pre-Retreat
	movea.l	#rethink,a0
	movea.l	#ithink,a4
	move	(a0,d6),d0
	move	difficulty,d1
	cmp	#3,d1
	bne	dortr8		* COMMANDER Difficulty
	subq	#6,d0
dortr8:	move	d0,(a4,d7)	* Reset Think Timer
	rts


*
*	DEATH	Spectacular Death Scene with Blood Spurting ...
*
*	Given:
*		Control
*
*	Returns:
*		Palette Updated
*
*	Register Usage:
*		destroys a0-a3 and d0-d6 ??
*
*	Externals:
*		none
*
bkgdeadtbl:
	.dc.w	0
	.dc.w	$000,$777,$000,$776,$000,$766,$000,$765
	.dc.w	$000,$755,$000,$754,$000,$744,$000,$743
	.dc.w	$000,$733,$000,$732,$000,$722,$000,$721
	.dc.w	$000,$711,$000,$710,$000,$710,$000,$700
death:
	movea.l	#palette,a0
	move	dying,d0
	add	d0,d0
	and	#$3e,d0		* BKG Color Cycle
	move	bkgdeadtbl(pc,d0),(a0)+
	move	dying,d0
	subq	#1,dying	* Mark Time (Jeez this code is a mess!)
	bne	dedskip
	clr	energy
	move	#1,endgame	* .. its all over now, baby blue
	movea.l	#palette,a0
	movea.l	#deadpal,a1
	move	#15,d0
dedpal:	move.w	(a1)+,(a0)+	* Build Black&White Palette
	dbra	d0,dedpal
	rts
dedskip:
	cmp	#28,d0
	ble	deadup		* IF (Early Stages) THEN
	rts
deadup:				* ELSE
	subq	#1,deathctr
	bmi	dedup0
	rts
dedup0:	move	#13,d1		* FOR (All Other Colors) DO
deaduplp:			* Ramp-Up to White
	move	(a0),d0
	and	#$777,d0
	cmp	#$700,d0
	bge	dedup1
	add	#$100,d0	* Ramp-Up RED
dedup1:	move	d0,d2
	and	#$70,d2
	cmp	#$70,d2
	beq	dedup2
	add	#$10,d0		* Ramp-Up GREEN
dedup2:	move	d0,d2
	and	#$7,d2
	cmp	#$7,d2
	bge	dedup3
	addq	#1,d0		* Ramp-Up BLUE
dedup3:	move	d0,(a0)+
	dbra	d1,deaduplp
	move	#3,deathctr	* Reset Wait Count
	rts


*
*	RANDU	Generate a 24-Bit Psuedo Random Number
*
*	Given:
*		nothing
*
*	Returns:
*		d0 = Random Number
*
*	Register Usage:
*		destroys d0-d3
*
*	Externals:
*		none
*
randu:
	move.l	#3141592621,d0
	move.l	seed,d1

*		Unsigned 32-bit Multiply w/ 32-bit Result

	move.l	d0,d3
	mulu	d1,d0		* d0=Lo*Lo
	move.l	d3,d2
	swap	d2
	mulu	d1,d2		* d2=Hi*Lo
	swap	d1
	mulu	d3,d1		* d1=Lo*Hi
	add.l	d2,d1
	swap	d0
	add	d1,d0
	swap	d0		* d0=result

	addq.l	#1,d0
	move.l	d0,seed		* new seed
	lsr.l	#8,d0
	rts


*
*	DATA STORAGE
*
	.data

mypal:	.dc.w	0		* STraiders color palette
	.dc.w	$777
	.dc.w	$300
	.dc.w	$410
	.dc.w	$520
	.dc.w	$630
	.dc.w	$212
	.dc.w	$033
	.dc.w	$044
	.dc.w	$055
	.dc.w	$066
	.dc.w	$477
	.dc.w	$040
	.dc.w	$750
	.dc.w	$730
	.dc.w	$660

deadpal:			* Black&White palette
	.dc.w	0
	.dc.w	$777
	.dc.w	$222
	.dc.w	$333
	.dc.w	$444
	.dc.w	$555
	.dc.w	$111
	.dc.w	$333
	.dc.w	$444
	.dc.w	$555
	.dc.w	$666
	.dc.w	$777
	.dc.w	$222
	.dc.w	$777
	.dc.w	$666
	.dc.w	$0

explcycl:			* Explosion Fragment Color Cycling Table
	.dc.w	$777
	.dc.w	$660
	.dc.w	$650
	.dc.w	$640
	.dc.w	$620
	.dc.w	$610
	.dc.w	$500
	.dc.w	$300
	.dc.w	$202
	.dc.w	$400
	.dc.w	$600
	.dc.w	$720
	.dc.w	$730
	.dc.w	$740
	.dc.w	$750
	.dc.w	$770

speedtbl:			* Ship Velocity Table (hi-word)
	.dc.w	0,11,14,18,21,28,42,62,84,110
*				* Hyperwarp Velocities
	.dc.w	160,214,265,311,358,409,462,511,550,596

*
*	Strategic LookAhead Tables
*
evenrow:			* Adjacent Sectors for EvenRows (X-Y Pairs)
	.dc.w	0,-1,0,1,-1,1
oddrow:				* Adjacent Sectors for OddRows (X-Y Pairs)
	.dc.w	0,1,0,-1,1,-1

template:			* Map-Matrix Template X:[12], Y:[16]
	.dc.b	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.dc.b	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$00,$00,$00,$7f
	.dc.b	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$00,$00,$00,$00,$00,$00,$00,$7f
	.dc.b	$7f,$7f,$7f,$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$7f,$7f,$7f,$7f,$7f
	.dc.b	$7f,$00,$00,$00,$00,$00,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.dc.b	$7f,$00,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
	.dc.b	$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f

expandtbl:			* Byte Sector Adjacent Table
	.dc.b	1,$0ff,$0f,$0ff,1,$0f1


*
*	TACTICAL Logic Tables
*
attmask:			* Attack XYOffset Mask
	.dc.w	$03ff,$01ff,$03ff,$0ff,$01ff,$0ff,$07f,$0ff
attzpos:			* Attack Desired Zpos
	.dc.w	$1400,$1000,$1800,$0c00,$0f000,$800,$400,$0f800
attspd:				* Attack Speed Multiplier
	.dc.w	slowspd,slowspd,medspd,medspd,medspd,fastspd,fastspd,fastspd
attwait:			* Attack Wait Duration
	.dc.w	25,16,20,32,40,60,60,60
attrange:			* Attack Range
	.dc.w	$1600,$1200,$1c00,$1000,$1200,$0a00,$600,$0c00
atthink:			* Attack Think Duration
	.dc.w	40,36,44,28,24,16,12,16

strthink:			* Strafe Think Duration
	.dc.w	24,32,24,40,16,24,24,32
strspd:				* Strafe Velocity/Speed Multiplier
	.dc.w	slowvel,slowvel,medvel,slowvel,medvel,medvel,fastvel,medvel
strange:			* Strafe Range (Percentage of $7fff)
	.dc.w	29490,26213,19660,16383,13107,9830,9830,6553

retrange:			* Retreat Range
	.dc.w	$1c00,$1400,$1000,$1800,$0e00,$0c00,$0a00,$800
rethink:			* Retreat Think Duration
	.dc.w	40,36,32,48,24,20,16,12
retwait:			* Retreat Wait Duration
	.dc.w	30,24,30,24,40,48,30,40
retvel:				* Retreat Velocity
	.dc.w	slowvel,slowvel,medvel,fastvel,medvel,fastvel,fastvel,medvel


nsdefault:			* Default Name String
	.dc.b	"____________",0,0,0,0

*
*	Rating Messages
*
gdstr0:	.dc.b	"GREETINGS AND FELICITATIONS,",0
gdstr1:	.dc.b	"YOU QUALIFY FOR THE HALL OF FAME.",0
gdstr2:	.dc.b	"PLEASE ENTER YOUR NAME:",0
wnstr0:	.dc.b	"STARFLEET TO STARCRUISER 7 ..",0
wnstr1:	.dc.b	"CONGRATULATIONS,",0
wnstr2:	.dc.b	"THE ALIEN ROBOT FLEET IS VANQUISHED.",0
wnstr3:	.dc.b	"KATSAURII QUADRANT HAS BEEN SAVED.",0
wnstr4:	.dc.b	"YOUR NEW RANK IS:",0
lostr0:	.dc.b	"STARFLEET TO ALL UNITS ..",0
lostr1:	.dc.b	"CONDITION RED,",0
lostr2:	.dc.b	"KATSAURII QUADRANT HAS BEEN OVERRUN.",0
lostr3:	.dc.b	"STARCRUISER 7 LOST IN ACTION.",0
lostr4:	.dc.b	"POSTHUMOUS RANK IS:",0
rankstr0:	.dc.b	"GARBAGE SCOW CAPTAIN",0
rankstr1:	.dc.b	"ROOKIE",0
rankstr2:	.dc.b	"NOVICE",0
rankstr3:	.dc.b	"LIEUTENANT",0
rankstr4:	.dc.b	"PILOT",0
rankstr5:	.dc.b	"ACE",0
rankstr6:	.dc.b	"WARRIOR",0
rankstr7:	.dc.b	"CENTURION",0
rankstr8:	.dc.b	"COMMANDER",0
rankstr9:	.dc.b	"STAR COMMANDER",0
classtr:	.dc.b	", CLASS 1",0

*
*	RANDOM DATA STORAGE
*

	.bss

oneshot:
	.ds.b	1		* last Trigger value (for one-shotting)

	.even

oldvbl:
	.ds.l	1		* Old VBlank Handler

oldphys:
	.ds.l	1		* Old Screen Base


screen:
	.ds.l	1		* Current DRAW Screens Address

frameno:
	.ds.l	1		* current frame number

_difficult:
difficult:
	.ds.w	1		* Difficulty Level Selected (0=Easy - 3=Hard)

evalstr:
	.ds.w	20		* Evaluation String
namestr:
	.ds.w	8		* Name/Level String
nameoff:
	.ds.w	1		* Offset to Current Posn in Name String
hightime:
	.ds.w	1		* High Score Display Counter/Flag (neg=none)
newscore:
	.ds.w	1		* Rank/Level Composite High Score

newgame:
	.ds.w	1		* Request to start a NEW game flag.
endgame:
	.ds.w	1		* Request to END the game flag.
gameover:
	.ds.w	1		* Game-Over flag.
quitgame:
	.ds.w	1		* Request to ABORT the game flag.
parade:
	.ds.w	1		* Request to Start a Parade (neg. ==> don't)

truespeed:
	.ds.w	1		* Real Current Speed ( .vs. requested speed)

deathctr:
	.ds.w	1		* Death-Sequence Delay Counter
dying:
	.ds.w	1		* Death-Sequence Activated Flag (0=Not)
bombing:
	.ds.w	1		* Nuclear Smart Bomb Activated Counter (0=Not)
warping:
	.ds.w	1		* In Warp-Space Energy Counter (0=normal space)
hyperclean:			* Screen Wipe Counter in Hyperwarp Mode
	.ds.w	1

adjlist:
	.ds.w	3		* List of Flags for Adjacent Sectors

deadbases:
	.ds.w	1		* Number of Bases Eaten by Aliens this Game

basendx:
	.ds.w	1		* Index to Currently Active StarBase
fleetndx:
	.ds.w	1		* Index to Currently Active Alien Fleet

*
*	Alien Strategic Brain Variables
*
mapmatrix:
	.ds.b	12*16		* Map of Current Galaxy for LookAhead
*				*       0 ==> Empty Sector
*				*     $7f ==> Blocked Sector
*				*     $80 ==> Target Sector
*				* {1,2,3} ==> Direction Moved

openlist:
	.ds.l	90		* List of Sectors Remaining to be Checked
*				* hi-word: Link Field (-1 = NIL)
*				* lo-word = 0 ==> Free Element
*				*  .. hi-byte = Distance
*				*  .. lo-byte = Location

*
*	Alien Tactical Brain Variables
*
xalien:
	.ds.w	8		* Desired X-posn
yalien:
	.ds.w	8		* Desired Y-posn
zalien:
	.ds.w	8		* Desired Z-posn
spdalien:
	.ds.w	8		* Desired Speed Multiplier
ithink:
	.ds.w	8		* Think-Time Wait Counter (neg ==> Think)
iwait:
	.ds.w	8		* #Thinks to Wait Counter (neg ==> Act)
attack:
	.ds.w	8		* Chosen ATTACK State
strafe:
	.ds.w	8		* Chosen STRAFING State
retreat:
	.ds.w	8		* Chosen RETREAT State
alamode:
	.ds.w	8		* Current MODE (1=Attack,0=Strafe,-1=Retreat)

*
*	Miscellaneous Storage
*
temp:
	.ds.w	1		* Lowest-Level Local TEMPORARY storage

random:
	.ds.l	1		* Temp Storage for a Random Long
seed:
	.ds.l	1		* Random Number Generator Seed

	.end
