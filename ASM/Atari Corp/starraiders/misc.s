*
*	MISC.S	 Miscellaneous Routines for  ST Star-Raiders
*		Copyright 1985/1986 ATARI Corp.
*
	.text

*
*	PUBLIC SYMBOLS
*
	.globl	addfleet
	.globl	badguys
	.globl	basedie
	.globl	bases
	.globl	basetime
	.globl	buzybox
	.globl	bzychange
	.globl	chooser
	.globl	computer
	.globl	delfleet
	.globl	delbase
	.globl	energyuse
	.globl	explode
	.globl	fleetime
	.globl	fleets
	.globl	hitem
	.globl	hitus
	.globl	hyperjump
	.globl	initgalx
	.globl	initsect
	.globl	initship
	.globl	insector
	.globl	keyboard
	.globl	lfqudtbl
	.globl	marines
	.globl	rtqudtbl
	.globl	shoot
	.globl	subenergy
	.globl	subkybd
	.globl	xgal
	.globl	ygal
	.globl	zipwindow


*
*	GAME CONSTANTS
*
chrgtime .equ	24	* Gun-Charging Delay (frames)
shotspd	.equ	$800000	* Guns Shot Speed (delta-Z)

fragtime .equ	$30	* Time-Out for Explosion Fragment (frames)
ushotime .equ	80	* Time-Out for Your Missiles (frames)


*
*	SUBROUTINE AREA
*

*
*	SINFINITY   Signed Infinity String Builder
*
*	Given:
*		a0 = String Ptr
*		d1 = Negative Flag (0=Positive)
*
*	Returns:
*		w/ SIX-CHAR String (0 Terminated, Leading Zero Suppression)
*
*	Register Usage:
*		destroys a0
*
*	Externals:
*		none
*
sinfinity:
	move	#$2020,(a0)+	* Leading Blanks
	tst	d1
	bne	sinfi1
	move	#$202b,(a0)+	* Positive
	bra	sinfi2
sinfi1:	move	#$202d,(a0)+	* Negative
sinfi2:	move	#$0df00,(a0)+	* Infinity Sign
	rts


*
*	BCDSTRING   Convert BCD {-9999 .. 9999} to ASCII
*
*	Given:
*		a0 = String Ptr
*		d0 = BCD Representation
*		d1 = Negative Flag (0=Positive)
*
*	Returns:
*		w/ SIX-CHAR String (0 Terminated, Leading Zero Suppression)
*
*	Register Usage:
*		destroys a0-a1 and d0-d5
*
*	Externals:
*		none
*
bcdstring:
	move	#-1,d2		* d2 = Zero Flag (Suppress Zeroes)
	move.b	#' ',(a0)
	move	#3,d3		* d3 = Loop Counter
bcdstlp:			* FOR (All Four Digits) DO
	rol	#4,d0
	move	d0,d4
	and	#$0f,d0
	bne	bcdst1		* IF (NonZero OR (KeepZeroes OR LastOne))
	move	d2,d5
	and	d3,d5
	beq	bcdst1		* ELSE
	move.b	#' ',d0		* Leading Blank
	bra	bcdsjn
bcdst1:	tst	d2		* THEN
	beq	bcdst2		* IF (First Non-Blank)
	clr	d2		* THEN Remember it
	move.l	a0,a1
bcdst2:	add.b	#'0',d0		* Convert to ASCII
bcdsjn:	addq.l	#1,a0		* Bump Ptr to Next CharField
	move.b	d0,(a0)
	move	d4,d0
	dbra	d3,bcdstlp

	tst	d1
	beq	bcdone		* IF (Negative Number)
	move.b	#'-',(a1)	* THEN Add Sign
bcdone:	addq.l	#1,a0
	move.b	#0,(a0)		* Zero-Terminate
	rts


*
*	INTOBCD   Convert Hex to BCD {-9999 .. 9999}
*
*	Given:
*		d0 = Hex Value to Convert (Word)
*
*	Returns:
*		d0 = Conversion Error Flag (0=Successful Conversion)
*		d1 = Was-Negative Flag (0=Was-Positive)
*		d2 = BCD Representation
*
*	Register Usage:
*		destroys d0-d5
*
*	Externals:
*		none
*
lo1tbl:	.dc.b	$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$10,$11,$12,$13,$14,$15
lo2tbl:	.dc.b	$00,$16,$32,$48,$64,$80,$96,$12,$28,$44,$60,$76,$92,$08,$24,$40
hi2tbl:	.dc.b	$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$02,$02,$02
lo3tbl:	.dc.b	$00,$56,$12,$68,$24,$80,$36,$92,$48,$04,$60,$16,$72,$28,$84,$40
hi3tbl:	.dc.b	$00,$02,$05,$07,$10,$12,$15,$17,$20,$23,$25,$28,$30,$33,$35,$38
lo4tbl:	.dc.b	$00,$96,$92
hi4tbl:	.dc.b	$00,$40,$81
intobcd:
	clr	d1
	clr	d2
	clr	d3		* Initialize Result
	tst	d0
	bpl	inbcd1		* Determine Original Sign
	move	#1,d1
	neg	d0
inbcd1:	cmp	#9999,d0
	bgt	bcdxit		* IF (Conversion Possible) THEN
	move	d0,d4
	and	#$0f,d0
	move.b	lo1tbl(pc,d0),d2
	move	d4,d0
	ror	#4,d0
	move	d0,d4
	and	#$0f,d0
	move.b	lo2tbl(pc,d0),d5
	andi	#$0f,ccr	* Clear Xtend Bit
	abcd	d5,d2
	move.b	hi2tbl(pc,d0),d5
	abcd	d5,d3		* Low-Byte Processed
	move	d4,d0
	ror	#4,d0
	move	d0,d4
	and	#$0f,d0
	move.b	lo3tbl(pc,d0),d5
	abcd	d5,d2
	move.b	hi3tbl(pc,d0),d5
	abcd	d5,d3		* Three Nybbles Done
	move	d4,d0
	ror	#4,d0
	and	#$0f,d0
	move.b	lo4tbl(pc,d0),d5
	abcd	d5,d2
	move.b	hi4tbl(pc,d0),d5
	abcd	d5,d3
	asl	#8,d3
	or	d3,d2		* d2 = BCD Result
	clr	d0		* Return Success
bcdxit:	rts


*
*	BUZYBOX   Maintain Main Busy Box Display
*
*	Given:
*		Control
*		TRACKNDX  = Object Index of Tracked Object
*		BZYCHANGE = Request to Change Display
*
*	Returns:
*		w/MAINBZY Updated
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
buzybox:
	move	bzymode,d0
	beq	bzbox0		* IF (not in CHANGE mode) THEN
	tst	bzychange
	beq	bzbox0		* IF (Request to Start Changing) THEN
	clr	bzymode		* Enter Change Mode
	clr	bzyimage
	clr	d0
bzbox0:	and	#$1c,d0		* "Safety First, Kiddies .. "
	movea.l	buzycase(pc,d0),a0
	jmp	(a0)		* CASE (Current BuzyBox Mode)
buzycase:
	.dc.l	bzroll,bzbomb,bzwarp,bzhypd,bztrak,bzrock,bzbase,bzdamg

*		Screen Rolling CHANGE Mode
bzroll:	addq	#1,bzyimage	* Bump to Next Image
	move	bzyimage,d0	* d0 = Current Image#
	cmp	#7,d0
	blt	bzrol0		* IF (Roll Sequence Complete) THEN
	move	bzychange,d1
	clr	bzychange	* Clear Request Flag
	tst	d1
	bmi	bzcha0		* IF (A Particular Mode Requested)
	cmp	#4,d1		* THEN Change to that Mode
	blt	bzrol2		* Special Case: Damage Report
	subq	#4,d1
	move	d1,bzyimage	* Image was Requested
	move	#28,bzymode
	move	#128,bzydelay	* Ready for Damage Mode
	bra	bzrol0
bzrol2:	add	d1,d1
	add	d1,d1		* Mode is an Index into the Case Table!
	bra	bzchjn
bzcha0:	tst	bombing		* ELSE Determine New Mode as best you can
	beq	bzcha1
	move	#4,d1		* Bombing Mode
	bra	bzchjn
bzcha1:	tst	warping
	beq	bzcha2
	move	#8,d1		* WarpSpace Mode
	bra	bzchjn
bzcha2:	tst	hyperon
	beq	bzcha3
	move	#12,d1		* Hyper-On Mode
	bra	bzchjn
bzcha3:	move	trackndx,d1
	movea.l	#objid,a0
	move	(a0,d1),d1	* d1 = Object Being Tracked
	bmi	bzcha5
	cmp	#starid,d1
	bge	bzcha4
	move	#16,bzymode	* Ship Tracking Mode
	rol	#7,d1
	and	#7,d1
	move	d1,bzyimage	* Get Picture From I.D.
	bra	bzrol0
bzcha4:	cmp	#shotid,d1
	bge	bzcha5
	move	#24,d1		* StarBase Tracking Mode
	bra	bzchjn
bzcha5:	move	#20,d1		* Thumb-Twiddling Mode

bzchjn:	move	d1,bzymode
	clr	bzydelay
	clr	bzyimage	* Ready for new Sequence next Frame
bzrol0:	add	#rollbzy,d0	* Maintain Roll Sequence
	move	d0,mainbzy
	rts
*		Smart Bombing CountDown Mode
bzbomb:	move	bombing,d1	* Use BOMBING to choose image
	bra	bzbmjn
*		WarpSpace CountDown Mode
bzwarp:	move	warping,d1	* Use WARPING to choose image
	bne	bzbmjn
	move	#-1,bzychange	* .. While in WarpSpace
bzbmjn:	cmp	#$80,d1
	ble	bzbom0		* Max-Out at "9" Count
	move	#$80,d1
bzbom0:	btst	#3,d1
	beq	bzbom2		* IF (Sweeping)
	and	#7,d1		* THEN Select Sweeper
	add	#swepbzy,d1
	move	d1,mainbzy
	rts
bzbom2:	asr	#4,d1		* ELSE Select a Number
	add	#timebzy,d1
	move	d1,mainbzy	* Select Image
	rts
*		HyperDrive CountDown Mode
bzhypd:	subq	#1,bzydelay
	bmi	bzhyp0		* Wait-Out Delay Count
	rts
bzhyp0:	move	#3,bzydelay	* Reset Delay
	move	bzyimage,d1
	addq	#1,d1
	and	#7,d1		* Bump to Next Image (MOD 8)
	move	d1,bzyimage
	add	#hyprbzy,d1
	move	d1,mainbzy	* Select Image
	rts
*		Alien Ship Tracking Mode
bztrak:	move	bzyimage,d0
	add	#shipbzy,d0
	move	d0,mainbzy	* Select an Alien Ship
	rts
*		Thumb-Twiddling Mode
bzrock:	move	#rockbzy,d0
	bra	bzanim
*		StarBase Tracking Mode Mode
bzbase:	move	#basebzy,d0
bzanim:	subq	#1,bzydelay
	bmi	bzanm0		* Wait-Out the Delay
	rts
bzanm0:	move	#3,bzydelay	* Restore Wait Count
	move	bzyimage,d1
	addq	#1,d1
	and	#7,d1		* Bump Image (MOD 8)
	move	d1,bzyimage
	add	d1,d0
	move	d0,mainbzy	* Select New Image
	rts
*		Damage Report Mode
bzdamg:	move	bzyimage,d0
	add	#damgbzy,d0
	move	d0,mainbzy	* Select a Damage Display
	subq	#1,bzydelay
	bpl	bzdmnd
	move	#-1,bzychange	* Time to Change
bzdmnd:	rts


*
*	COMPUTER   Maintain Attack Computer "Head-Up" Display
*
*	Given:
*		Control
*		TRACKNDX = Object Index of Tracked Object
*
*	Returns:
*		w/Screen Updated
*
*	Register Usage:
*		destroys a0-a5 and d0-d7 ???
*
*	Externals:
*		rplstamp,text_blt
*
computer:
	tst	computbzy
	bmi	compuxit
	tst	computon
	beq	compuxit	* IF ((Computer Working)AND(Turned On)) THEN
	clr	d2
	movea.l	#objid,a0
	move	trackndx,d1
	move	(a0,d1),d0
	cmp	#shotid,d0
	bcs	compt0		* IF (Not Base OR Enemy) THEN
	move	#xobjcntr,d0
	move	#yobjcntr,d1
	move	#acmpimg,d2
	jsr	rplstamp	* Just Draw the Infinity Sight
	rts

compt0:	add	d1,d1		* ELSE
	movea.l	#ypos,a0
	move	(a0,d1),d0	* d0 = Object Ypos
	cmp	#-99,d0
	bge	compt1
	addq	#1,d2		* Object is High
	bra	compt2
compt1:	cmp	#99,d0
	ble	compt2
	addq	#2,d2		* Object is Low
compt2:	movea.l	#xpos,a0
	move	(a0,d1),d0	* d0 = Object Xpos
	cmp	#-99,d0
	bge	compt3
	addq	#4,d2		* Object is Left
	bra	compjn
compt3:	cmp	#99,d0
	ble	compjn
	addq	#8,d2		* Object is Right
compjn:	add	#acmpimg,d2
	move	#xobjcntr,d0
	move	#yobjcntr,d1
	jsr	rplstamp	* Draw the Infinity Sight

	tst	hyperon
	bne	comprint	* IF (NOT in Hyperspace) THEN
	move	trackndx,d6
	movea.l	#distance,a0
	move	(a0,d6),d0
	add	d6,d6
	movea.l	#zpos,a0
	tst	(a0,d6)
	bpl	cmzpos
	neg	d0		* Sign Distance as Z-Pos
cmzpos:	asr	#1,d0
	jsr	intobcd
	movea.l	#disbuff,a0
	tst	d0
	beq	compt4		* IF (Cannot Convert to BCD)
	jsr	sinfinity	* THEN Use Signed Infinity
	bra	compt5
compt4:	move	d2,d0
	jsr	bcdstring	* ELSE Build DISTANCE String
compt5:	move.b	#$7f,disbuff+5

	movea.l	#xpos,a0
	move	(a0,d6),d0
	asr	#1,d0
	jsr	intobcd
	movea.l	#lrbuff,a0
	tst	d0
	beq	compt6		* IF (Cannot Convert to BCD)
	jsr	sinfinity	* THEN Use Signed Infinity
	bra	compt7
compt6:	move	d2,d0
	jsr	bcdstring	* ELSE Build XPOS String
compt7:	move.b	#$0e9,lrbuff+5

	movea.l	#ypos,a0
	move	(a0,d6),d0
	asr	#1,d0
	jsr	intobcd
	movea.l	#udbuff,a0
	tst	d0
	beq	compt8		* IF (Cannot Convert to BCD)
	jsr	sinfinity	* THEN Use Signed Infinity
	bra	compt9
compt8:	move	d2,d0
	jsr	bcdstring	* ELSE Build YPOS String
compt9:	move.b	#$0ed,udbuff+5

comprint:			* Print Results on Screen
	movea.l	#disbuff,a0
	move	#16,d0
	move	#104,d1
	move	#$0c,d2
	move	#1,d3
	jsr	text_blt	* DISTANCE String onto Screen
	movea.l	#lrbuff,a0
	move	#16,d0
	move	#112,d1
	move	#$0c,d2
	move	#1,d3
	jsr	text_blt	* XPOS String onto Screen
	movea.l	#udbuff,a0
	move	#16,d0
	move	#120,d1
	move	#$0c,d2
	move	#1,d3
	jsr	text_blt	* YPOS String onto Screen

compuxit:
	rts


*
*	AUTOTRACK   Attack Computer Auto-Target Select.
*
*	Given:
*		Control
*
*	Returns:
*		TRACKNDX Updated
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
autotrack:
	move	#-1,bzychange
	tst	badguys
	beq	autoanone	* IF (Alien Ships About) THEN
	movea.l	#objid,a0	* a0 = Ptr to Object ID List
	move	#(nobjects-1),d1	* (!SHITHOLE! Assembler)
	add	d1,d1		* d1 = Loop Count and Offset
autoalp:			* FOR (All Objects) DO
	move	(a0,d1),d0
	bmi	autoanxt
	and	#$7000,d0
	bne	autoanxt	* IF ((Object Exists)AND(Is Alien)) THEN
	move	d1,trackndx	* That's the One
	rts
autoanxt:
	subq	#2,d1
	bpl	autoalp
autoanone:
	clr	trackndx	* Take the First Object Around
	rts


*
*	MANTRACK   Attack Computer Target Selection Manual Override
*
*	Given:
*		Control
*
*	Returns:
*		TRACKNDX Updated
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		autotrack
*
mantrack:
	move	#-1,bzychange
	tst	badguys
	beq	mantrnone	* IF (Alien Ships About) THEN
	movea.l	#objid,a0	* a0 = Ptr to Object ID List
	move	trackndx,d1	* d1 = Loop Count and Offset
mantrlp:			* FOR (All Remaining Objects) DO
	subq	#2,d1
	bmi	mantrnone
	move	(a0,d1),d0
	bmi	mantrlp
	and	#$7000,d0
	bne	mantrlp		* IF ((Object Exists)AND(Is Alien)) THEN
	move	d1,trackndx	* That's the One
	rts
mantrnone:
	jmp	autotrack	* Manual Failed .. Auto-Track


*
*	HYPERJUMP   Execute a Hyperjump, Enter and Init new Sector
*
*	Given:
*		Control
*
*	Returns:
*		w/ Aliens or Starbase Initialized
*		Energy Usage Determined
*
*	Register Usage:
*		destroys a0-a3 and d0-d6 ??
*
*	Externals:
*		initsect
*
hyperjump:
	move	xgal,d0
	asl	#8,d0
	or	ygal,d0		* d0 = Composite Sector Number
	jsr	xformpts
	sub	xcursor,d0
	bpl	hprjm1
	neg	d0		* d0 = ABS(delta-X)
hprjm1:	sub	ycursor,d1
	bpl	hprjm2
	neg	d1		* d1 = ABS(delta-Y)
hprjm2:	cmp	d0,d1
	ble	hprjm3
	exg	d0,d1		* d0 = MAX(delta-X,delta-Y)
hprjm3:	asr	#2,d1
	move	d1,d2
	asr	#1,d2
	add	d2,d1
	add	d1,d0		* d0 = MAX + 3/8MIN = Distance
	addq	#1,d0
	move	d0,warping

	move	ycursor,d1
	move	d1,d2
	sub	#134,d2		* d2 = Ys - Ytop
	move	d2,d3
	ext.l	d3
	divs	#9,d3		* d3 = (Ys - Ytop)/9 = Ygrid
	move	xcursor,d0
	move	d0,d4
	ext.l	d4
	sub	#43,d4		* d4 = Xs - Xleft
	sub	d2,d4
	bpl	hprjmx
	clr	d4		* Disallow Negative
hprjmx:	divs	#18,d4		* d4 = [(Xs - Xleft)-(Ys - Ytop)]/18 = Xgrid
	move.l	d4,d0
	swap	d0		* d0 = Xrem
	move.l	d3,d1
	swap	d1		* d1 = Yrem
	move	#9,d2
	sub	d1,d2
	add	d2,d2		* d2 = 2*(9 - Yrem)
	add	d3,d3		* d3 = Actual Ygrid
	cmp	d2,d0
	ble	hprjm4
	addq	#1,d3		* Ygrid = Ygrid + 1
hprjm4:	move	d3,ygal		* New Position
	movea.l	#lfqudtbl,a0
	cmp.b	(a0,d3),d4
	bge	hprjm5
	move.b	(a0,d3),d4
	bra	hprjm6		* force to Left Boundary
hprjm5:	movea.l	#rtqudtbl,a0
	cmp.b	(a0,d3),d4
	ble	hprjm6
	move.b	(a0,d3),d4	* force to Right Boundary
hprjm6:	move	d4,xgal

	jsr	initsect	* Initialize the New Sector
	jsr	autotrack	* Initialize the Attack Computer Tracking
	move	#2,freshmap
	move	#2,bzychange

	rts


*
*	INITSECT   Initialize a Sector
*
*	Given:
*		XGAL,YGAL = Desired Sector
*
*	Returns:
*		w/ Aliens or Starbase Initialized
*
*	Register Usage:
*		destroys a0-a3 and d0-d6
*
*	Externals:
*		randompos,initalien,timsqadd
*
initsect:
	jsr	initobjs
	clr	badguys		* No Bad Guys Here
	move	xgal,d0
	asl	#8,d0
	or	ygal,d0		* d0 = Composite Location
	jsr	insector
	tst	d1
	bpl	intsct0
	move	#$0c005,d0
	jsr	timsqadd	* "Drive 55"
	rts
intsct0:			* IF (Anybody Home) THEN
	tst	d0
	bne	intsct1		* IF (Friendly Starbase) THEN
	jsr	freeobj
	move	d0,d5
	jsr	randompos	* Place Starbase at Random Posn
	add	d5,d5
	movea.l	#objid,a0
	move	#starid,(a0,d5)	* Mark as a Starbase
	add	d5,d5
	movea.l	#xvel,a0
	clr.l	(a0,d5)
	movea.l	#yvel,a0
	clr.l	(a0,d5)
	movea.l	#zvel,a0
	clr.l	(a0,d5)		* Zero Velocity
	rts
intsct1:			* ELSE Initialize an Alien Fleet
	move	#1,badguys
	and	#7,d0
	subq	#1,d0
	move	d0,d6		* FOR (All Aliens) DO
intsctlp:
	jsr	freeobj
	move	d0,d5		* d5 = Object Index
	jsr	randompos
	add	d5,d5
	jsr	initalien	* Initialize Brain and Course
	dbra	d6,intsctlp
	rts


*
*	RANDOMPOS  Generate a Random X,Y,Z Posn in a Sector
*
*	Given:
*		d0 = Object Number {0 .. nobjects-1}
*
*	Returns:
*		w/ Xpos,Ypos and Zpos Initialized
*
*	Register Usage:
*		destroys a0 and d0-d4
*
*	Externals:
*		randu
*
randompos:
	move	d0,d4
	add	d4,d4
	add	d4,d4		* d4 = index into Object Posns
	jsr	randu
	tst	d0
	bmi	rndmp1
	and	#$3fff,d0
	bra	rndmp2
rndmp1:	or	#$0c000,d0
rndmp2:	movea.l	#xpos,a0
	move	d0,(a0,d4)	* Xpos { -16K .. 16K}
	jsr	randu
	tst	d0
	bmi	rndmp3
	and	#$3fff,d0
	bra	rndmp4
rndmp3:	or	#$0c000,d0
rndmp4:	movea.l	#ypos,a0
	move	d0,(a0,d4)	* Ypos { -16K .. 16K}
	jsr	randu
	movea.l	#zpos,a0
	move	d0,(a0,d4)	* Zpos { -32K .. 32K}
	rts


*
*	RVESECTOR  Generate a Random-Valid-Empty Sector
*
*	Given:
*		control
*
*	Returns:
*		d0 = X-Y Posn of RVE Sector
*
*	Register Usage:
*		destroys a0 and d0-d3
*
*	Externals:
*		insector,randu
*
rvesector:			* REPEAT
	jsr	randu
	move.l	d0,random	* get a random number
	swap	d0
	move	d0,d1
	and	#7,d0		* d0 = {0 .. 7} = raw-Xpos
	asr	#3,d1
	and	#$0f,d1		* d1 = {0 .. 15} = raw-Ypos
	cmp	#13,d1
	ble	rvesct1
	move.b	random+2,d2
	and	#7,d2
	addq	#2,d2		* subtract {2 .. 9}
	sub	d2,d1
rvesct1:			* d1 = {0 .. 13} = True-Ypos
	movea.l	#lfqudtbl,a0
	add.b	(a0,d1),d0	* d0 = Xpos + Quadrant-Left-Edge
	movea.l	#rtqudtbl,a0
	cmp.b	(a0,d1),d0
	ble	rvesct2		* IF (Xpos > Quadrant-Right-Edge) THEN Reduce
	move.b	random+3,d2
	and	#3,d2
	addq	#2,d2		* d2 = {2 .. 5}
	sub	d2,d0
rvesct2:			* d0 = {Left-Edge .. Right-Edge}
	asl	#8,d0
	or	d1,d0
	jsr	insector
	tst	d1
	bpl	rvesector	* UNTIL (Empty Sector Generated)
	rts


*
*	INSECTOR  Find What is in This Sector
*
*	Given:
*		d0 = X-Y Posn of Desired Sector
*
*	Returns:
*		d0.w = Contents of Sector
*		       ( 0 IF Starbase, N IF Aliens, Unchanged IF EMPTY)
*		d1.w = Index to Contents ( -1 IF EMPTY)
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
insector:
	movea.l	#bases,a0	* a0 = Base-List ptr
	moveq	#0,d1
insect:				* REPEAT
	cmp	(a0,d1),d0
	bne	insct0		* IF (Sector Match) Return Success
	clr	d0
	rts
insct0:	cmp.b	1(a0,d1),d0
	blt	insct1
	tst	(a0,d1)
	beq	insct1		* UNTIL (No Hope OR EOList)
	addq	#2,d1
	bra	insect
insct1:	movea.l	#fleets,a0	* a0 = Fleet-List ptr
	moveq	#0,d1
insect2:			* REPEAT
	cmp	2(a0,d1),d0
	bne	insct3		* IF (Sector Match) Return Success
	move	(a0,d1),d0
	and	#$0ff,d0	* Mask-Off Number of Ships
	rts
insct3:	cmp.b	3(a0,d1),d0
	blt	insct4
	tst.l	(a0,d1)
	beq	insct4		* UNTIL (No Hope OR EOList)
	addq	#4,d1
	bra	insect2
insct4:	move	#-1,d1		* Nothing Found at That Address
	rts


*
*	CHOOSER  Choose Target Starbases for all Alien Fleets
*
*	Given:
*		Control
*
*	Returns:
*		w/ With Fleets Updated
*
*	Register Usage:
*		destroys a0-a1 and d0-d7
*
*	Externals:
*		none
*
chooser:
	movea.l	#fleets,a0
	movea.l	#bases,a1
cfleetlp:
	move.l	(a0),d0		* WHILE (Fleets Remain) DO
	beq	cfleetdn
	move	d0,d1		* d1 = Ypos
	asr	#8,d0		* d0 = Xpos
	move	#100,d2		* d2 = Best Distance
	move	#-1,d3		* d3 = Index to Closest Base
	clr	d7		* d7 = Loop Index
chbaselp:
	move	(a1,d7),d4
	beq	chbasedn	* WHILE (Bases Remain) DO
	move	d4,d5
	sub.b	d1,d5
	bpl	chdst1
	neg.b	d5		* d5 = ABS(Delta-Y)
chdst1:	asr	#8,d4
	sub	d0,d4
	bpl	chdst2
	neg	d4		* d4 = ABS(Delta-X)
chdst2:	add.b	d5,d4		* d5 = Distance = X + Y
	cmp	d2,d4
	bge	chdst3		* IF (New Distance is Smaller) THEN
	move	d4,d2		* Save New Distance
	move	d7,d3		* .. and Index
chdst3:	addq	#2,d7
	bra	chbaselp
chbasedn:
	move.b	d3,(a0)		* Save new Target Base (or -1)
	addq.l	#4,a0
	bra	cfleetlp
cfleetdn:
	tst	marines
	bne	choosone
	rts
choosone:			* Special Case of only a few survivors ..
	movea.l	#fleets,a0
	tst.l	(a0)
	bgt	choos1
	rts			* IF (Both Hunters and Prey) THEN
choos1:	movea.l	#vote,a1	* a1 = Votes Ptr.
	clr.l	(a1)
	clr.l	4(a1)
	clr.l	8(a1)		* Init. the Vote Tally
	clr	d0
votelp:
	tst.l	(a0)
	beq	votedn		* WHILE (Fleets Remain) DO
	move.b	(a0),d0
	addq	#1,(a1,d0)	* Count the Votes
	addq.l	#4,a0
	bra	votelp
votedn:				* Select the "Lucky" Winner
	clr	d0		* d0 = Best #votes
	clr	d1		* d1 = Index to that base
	move	#10,d7		* d7 = Loop Index
votally:			* FOR (All Possible Bases) DO
	cmp	(a1,d7),d0
	bge	voteno		* IF (New Total Higher) THEN New Winner
	move	(a1,d7),d0
	move	d7,d1
voteno:	subq	#2,d7
	bpl	votally
	movea.l	#fleets,a0
forcevote:
	tst.l	(a0)
	beq	forego		* WHILE (Fleets Remain) DO
	move.b	d1,(a0)		* Force Consensus Base Choice Upon Them
	addq.l	#4,a0
	bra	forcevote
forego:	rts


*
*	DELBASE  Delete a Starbase From the List of Starbases
*
*	Given:
*		d0 = Index to Starbase
*
*	Returns:
*		w/ With Base-List and Think-List Updated
*
*	Register Usage:
*		destroys a0-a2 and d0
*
*	Externals:
*		none
*
delbase:
	move	#2,freshmap
	movea.l	#bases,a0
	adda	d0,a0		* a0 = ptr to Elm in Question
	movea.l	#basetime,a1
	adda	d0,a1		* a1 = ptr to Timer
	movea.l	#basedie,a2
	add	d0,d0
	adda	d0,a2		* a2 = ptr to Death Status
delbalp:
	move	2(a1),(a1)+
	move.l	4(a2),(a2)+
	move	2(a0),(a0)+
	bne	delbalp		* Squeeze it out
	rts

*
*	DELFLEET  Delete a Starfleet From the List of Starfleets
*
*	Given:
*		d0 = Index to Starfleet
*
*	Returns:
*		w/ With Fleet-List Updated
*
*	Register Usage:
*		destroys a0-a1 and d0
*
*	Externals:
*		none
*
delfleet:
	move	#2,freshmap
	movea.l	#fleets,a0
	adda	d0,a0		* a0 = ptr to Elm in Question
	movea.l	#fleetime,a1
	asr	#1,d0
	adda	d0,a1		* a1 = ptr to Think Timer
delflep:
	move	2(a1),(a1)+
	move.l	4(a0),(a0)+
	bne	delflep		* Squeeze it out
	rts


*
*	ADDBASE  Add a Starbase to the List of Starbases
*
*	Given:
*		d0 = X,Y Posn of Starbase
*
*	Returns:
*		w/ With Base-List Updated
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		none
*
addbase:
	movea.l	#bases,a0	* a0 = ptr to Base-List
addbaslp:
	move	(a0),d1
	beq	addbasxit	* WHILE (Starbases Remain) DO
	cmp.b	d1,d0
	ble	adbinsert
	addq.l	#2,a0
	bra	addbaslp
adbinsert:			* IF (higher than other guy) THEN insert here
	move	(a0),d1
	move	d0,(a0)+
	move	d1,d0		*  .. insert element
	bne	adbinsert	* UNTIL (EOList)
	clr	(a0)		* Add EOList Marker
	rts
addbasxit:
	move	d0,(a0)+	* OR add to end of list
	clr	(a0)
	rts


*
*	ADDFLEET  Add an Alien StarFleet to the Fleet-List
*
*	Given:
*		d0 = Strength,X,Y Posn of Fleet
*
*	Returns:
*		w/ With Fleet-List Updated
*
*	Register Usage:
*		destroys a0-a1 and d0-d3
*
*	Externals:
*		none
*
addfleet:
	movea.l	#fleets,a0	* a0 = ptr to Fleet-List
	movea.l	#fleetime,a1	* a1 = ptr to Fleet-Timers
	move	#alathink,d2
addfltlp:
	move.l	(a0),d1
	beq	addfltxit	* WHILE (Starfleets Remain) DO
	cmp.b	d1,d0
	ble	adfinsert
	addq.l	#4,a0
	addq.l	#2,a1
	bra	addfltlp
adfinsert:			* IF (higher than other guy) THEN insert here
	move	(a1),d3
	move	d2,(a1)+
	move	d3,d2		*  .. insert think timer
	move.l	(a0),d1
	move.l	d0,(a0)+
	move.l	d1,d0		*  .. insert element
	bne	adfinsert	* UNTIL (EOList)
	clr.l	(a0)		* Add EOList Marker
	rts
addfltxit:
	move	d2,(a1)		* OR add to end of list
	move.l	d0,(a0)+
	clr.l	(a0)
	rts


*
*	INITGALX  Initialize Your Local Galactic Quadrant
*
*	Given:
*		control
*
*	Returns:
*		w/ With BASES and FLEETS Updated
*
*	Register Usage:
*		destroys a0-a4 and d0-d7
*
*	Externals:
*		addbase,addfleet,rvesector,randu,chooser
*
basetbl:			* Number of Bases minus one (by difficulty)
	.dc.w	2,3,4,5

initgalx:
	movea.l	#bases,a0
	clr	(a0)		* No Bases
	movea.l	#fleets,a0
	clr.l	(a0)		* No Fleets
	move	difficulty,d0
	add	d0,d0
	move	basetbl(pc,d0),d5
	move	d5,d4
basinglp:			* FOR (All Bases) DO
	jsr	rvesector
	cmp	#$301,d0
	beq	basinglp
	cmp	#$801,d0
	beq	basinglp	* Reject Either 'Safe' Corner
	movem	d0-d5,-(sp)
	jsr	adjacent
	movem	(sp)+,d0-d5
	move	adjlist,d1
	and	adjlist+2,d1
	and	adjlist+4,d1
	bne	basinglp	* Reject Any Already Surrounded
	jsr	addbase		* Add a Starbase in a Random Location
	dbra	d4,basinglp
	movea.l	#basetime,a0
	movea.l	#basedie,a1
	clr	d0
bsinitlp:			* FOR (All Bases) DO
	move	d0,(a0)+
	add	#$10,d0
	clr.l	(a1)+		* Alive and Ready
	dbra	d5,bsinitlp

	move	difficulty,d0
	add	d0,d0
	move	fleetbl(pc,d0),d5
	move	d5,d4
fltinglp:			* FOR (All Alien Fleets) DO
	jsr	rvesector
	clr	d1		* Zero Spare Bits
	move.b	fleetsize(pc,d4),d1
	swap	d1
	move	d0,d1
	move.l	d1,d0		* d0 = Composite Fleet Strength and Location
	jsr	addfleet
	dbra	d4,fltinglp
	movea.l	#fleetime,a0
flinitlp:			* FOR (All Alien Fleets) DO
	jsr	randu
	and	#$7f,d0
	move	d0,(a0)+	* Randomly Init Think Time
	dbra	d5,flinitlp
	clr	marines		* Plenty of Aliens .. so ..
	jsr	chooser		* Choose a Target Base
	rts
fleetbl:			* Number of Fleets minus one (by difficulty)
	.dc.w	8,11,14,17
fleetsize:			* Fleet Sizes
	.dc.b	2,2,2,3,3,4,4,5,6
	.dc.b	2,3,4
	.dc.b	3,4,5
	.dc.b	4,5,6
	.even			* Just in Case ...


*
*	ENERGYUSE  Consume Energy for Active Devices
*
*	Given:
*		control
*
*	Returns:
*		w/ With ENERGY Updated
*
*	Register Usage:
*		destroys a0 and d0-d2 ???
*
*	Externals:
*		subenergy
*
warpnrgy:			* Warp Engine Usage (by Speed)
	.dc.w	0,$800,$c00,$1000,$1400
	.dc.w	$1800,$1f00,$4000,$7fff,$ffff
energyuse:
	move.l	#0,d0
	move	nrgyacc,d0	* d0 = Accumulating Energy Usage
	add.l	#$200,d0	* Life-Support And Background Usage
	tst	computon
	beq	nrgy1		* IF (Computer on) THEN Add Computer Usage
	add.l	#$400,d0
nrgy1:	tst	shieldon
	beq	nrgy2		* IF (Shields on) THEN Add Shield Usage
	add.l	#$1000,d0
nrgy2:	move.b	stick1,d1
	and	#$0f,d1
	beq	nrgy3		* IF (Thrusters on) THEN Add Thruster Usage
	add.l	#$800,d0
nrgy3:	tst	hyperon
	beq	nrgy4		* IF (Hyperdrive on) THEN Add Hyperdrive Usage
	add.l	#$10000,d0
	bra	nrgyjn
nrgy4:	move	shipspeed,d1	* ELSE Warp-Drive Drain
	add	d1,d1		* d1 = Index into Warp-Costs
	move.l	#0,d2
	move	warpnrgy(pc,d1),d2
	add.l	d2,d0
nrgyjn:	move	d0,nrgyacc	* Save Accumulated Usage
	swap	d0
*				  .. and fall thru to subtract energy usage ..


*
*	SUBENERGY  Subtract Energy From Available (in BCD)
*
*	Given:
*		d0 = Energy Used (BCD,word)
*
*	Returns:
*		w/ With ENERGY Updated
*
*	Register Usage:
*		destroys d0 and d1
*
*	Externals:
*		billbadd,startsound
*
subenergy:
	move	d0,temp
	move.b	energy+1,d1
	andi	#$0f,ccr
	sbcd	d0,d1
	move.b	d1,energy+1	* Lo-Byte of Energy
	move.b	energy,d1
	move.b	temp,d0
	sbcd	d0,d1
	bcc	sbnrg2
	clr	energy		* Oops, Underflow!
	rts
sbnrg2:	move.b	energy,d0
	move.b	d1,energy	* Hi-Byte of Energy
	and	#$0f0,d1
	bne	sbnrg9
	and	#$0f0,d0
	beq	sbnrg9		* IF (Just Below 1000) THEN
	move.l	a0,-(sp)
	move	#$0d015,d0	* Better Warn About Low Energy
	jsr	billbadd
	move	#cvoice,d0
	move.l	#damagsnd,d1
	jsr	startsound
	move.l	(sp)+,a0
sbnrg9:	rts


*
*	INITSHIP   Initialize all Ship Variables
*
*	Given:
*		control
*
*	Returns:
*		w/ All Ship Variables Initialized, A new Ship
*
*	Register Usage:
*		destroys a0 and d0-d2
*
*	Externals:
*		none
*
initship:
	move	#1,radiobzy	* Sub-Space Radio Working
	move	#2,freshmap
	clr	bombing
	clr	warping
	clr	hyperon		* HyperDrive off
	clr	warpdmg		* WarpDrive Ready
	move	#-1,shldefct
	clr	shieldon
	clr	shieldmg	* Shields off, No damage
	clr	trackndx
	clr	computon
	move	#2,computbzy	* Computer Off but Functional
	clr	shotleft
	clr	lgunchrg
	clr	rgunchrg
	clr	aftgunchrg
	clr	lgundmg
	clr	rgundmg
	clr	aftgundmg	* Repair and Charge the Guns
	clr	nonuke
	clr	nukerdy		* Emergency Atomics Available and Safe
	clr	aftvdmg
	clr	scandmg		* Aft-Viewer and Scanner Working
	move	#$9999,energy	* fully charged and ready to go
	rts


*
*	HITEM	Hit an Alien Ship.
*
*	Given:
*		a1 = Xpos-List ptr
*		a2 = Ypos-List ptr
*		a3 = Zpos-List ptr
*		d7 = Index of Missile which hit
*		d6 = Index of Position of Missile which hit (2*d7)
*		d5 = Index of Alien that was hit.
*		d4 = Index of Position of Alien which was hit (2*d5)
*
*	Returns:
*		w/ Alien Dealt With
*
*	Register Usage:
*		destroys a0-a6 and d0-d5 !!??
*
*	Externals:
*		bigexplo,explode,delfleet
*
hitem:
*
*	NOTE: Hits Always Kill ...
*
killedem:		* Nailed the Sucker
	move	kills,d0
	move	#1,d1
	and	#$0f,ccr
	abcd	d1,d0
	move	d0,kills	* Count a kill
	move	#-1,(a0,d5)	* Remove it from Object-List

	move	xgal,d0
	asl	#8,d0
	or	ygal,d0
	jsr	insector
	tst	d1
	bmi	killdm1
	tst	d0
	beq	killdm1		* IF (Alien Fleet Here) THEN

	move	#2,freshmap	* Update the Map
	move	d1,d0
	movea.l	#fleets,a0
	subq.b	#1,1(a0,d0)	* Remove it from it's Fleet
	move	(a0,d0),d1
	and	#7,d1
	bne	killdm1		* IF (Fleet Eliminated)
	move.l	a1,-(sp)
	jsr	delfleet	* THEN Remove Fleet
	move.l	(sp)+,a1
	clr	badguys
killdm1:
	cmp	trackndx,d5
	bne	kildm2		* IF (Was the Tracked Alien)
	jsr	autotrack	* THEN Re-Target
kildm2:	move	(a1,d4),d0
	move	(a2,d4),d1
	move	(a3,d4),d2	* Start an Explosion Here
	movea.l	#distance,a0
	move	(a0,d5),d3
	cmp	#$1000,d3
	bgt	kildm3
	jsr	bigexplo	* .. Make it a BIG One
	bra	kildm4
kildm3:	jsr	explode

kildm4:	move	#avoice,d0
	move.l	#explsnd2,d1
	jsr	startsound
	move	#bvoice,d0
	move.l	#explsnd3,d1
	jsr	startsound	* Make PROPER Explosion Noise
	rts


*
*	HITUS	They Hit Us!
*
*	Given:
*		d7 = Index of Missile which hit
*		d6 = Index of Position of Missile which hit (2*d7)
*		a1 = Xpos-List ptr
*		a2 = Ypos-List ptr
*		a3 = Zpos-List ptr
*
*	Returns:
*		w/ With New Damage Inflicted
*
*	Register Usage:
*		destroys a0-a6 and d0-d5 !!??
*
*	Externals:
*		explode,subenergy,billbadd,randu
*
hitus:
	move	(a1,d6),d0
	move	(a2,d6),d1
	move	#144,d2
	jsr	explode		* Start an Explosion Here
	move	#avoice,d0
	move.l	#explsnd0,d1
	jsr	startsound
	move	#bvoice,d0
	move.l	#explsnd1,d1
	jsr	startsound	* Make PROPER Explosion Noise
	jsr	randu
	move.l	d0,random	* get a random number
	tst	shieldon
	beq	killedus
	tst	shieldmg
	bmi	killedus
	beq	hitus1
	move	random,d0
	and	#3,d0
	bne	luckyus		* IF (Damaged Shields Collapse)
	move	#$100,d0	* THEN Destroy Shields
	jsr	subenergy
	bra	dmgshd
luckyus:
	move	#$0d00e,d0	* ELSE Better Warn About the Damaged Shields
	jsr	billbadd
	move	#cvoice,d0
	move.l	#damagsnd,d1
	jsr	startsound
hitus1:	move	#$100,d0	* IF (Shields On AND Working) THEN
	jsr	subenergy	* Lose energy
	move.b	random+2,d0
	and	#$7f,d0
	move	difficult,d1
	cmp.b	dmghitbl(pc,d1),d0
	blt	damage		* IF (Novice OR Lucky) THEN skip
	rts

dmghitbl:			* Chance of Damage by Difficulty Level (BYTE)
	.dc.b	0,13,38,64	* Out-of-128
damagtbl:			* Location of Damaged Sub-System
	.dc.w	$2e,$5c,$82,$0a6,$0c2,$0dc,$0ee,$0fb
damage:				* Inflict Damage on Random Sub-System
	move	#cvoice,d0
	move.l	#damagsnd,d1
	jsr	startsound	* Damage Alert Sound

	clr	d0
	move.b	random+3,d0
*				  CASE (Which System Damaged)
	cmp	damagtbl(pc),d0
	blt	dmgunl
	cmp	damagtbl+2(pc),d0
	blt	dmgunr
	cmp	damagtbl+4(pc),d0
	blt	dmguna
	cmp	damagtbl+6(pc),d0
	blt	dmgshd
	cmp	damagtbl+8(pc),d0
	blt	dmgrad
	cmp	damagtbl+10(pc),d0
	blt	dmgwrp
	cmp	damagtbl+12(pc),d0
	blt	dmgafv
	cmp	damagtbl+14(pc),d0
	blt	dmglrs
dmgcmp:				* Damage the Attack Computer
	move	#-1,computbzy
	move	#$0d014,d0
	jsr	billbadd
	move	#4,bzychange
	rts
dmgunl:				* Damage the Left Gun
	move	#1,lgundmg
	move	#$0d00c,d0
	jsr	billbadd
	move	#5,bzychange
	rts
dmgunr:				* Damage the Right Gun
	move	#1,rgundmg
	move	#$0d00d,d0
	jsr	billbadd
	move	#6,bzychange
	rts
dmguna:				* Damage the Aft Gun
	move	#1,aftgundmg
	move	#$0d00b,d0
	jsr	billbadd
	move	#7,bzychange
	rts
dmgshd:				* Damage the Shields
	move	#8,bzychange
	tst	shieldmg
	beq	dmshd0
	move	#-1,shieldmg	* Already Damaged, So Gone
	move	#$0e00f,d0
	jsr	billbadd
	rts
dmshd0:	move	#1,shieldmg	* Just Now Damaged
	move	#$0d00e,d0
	jsr	billbadd
	rts
dmgrad:				* Damage the SubSpace Radio
	move	#-1,radiobzy
	move	#$0d010,d0
	jsr	billbadd
	move	#9,bzychange
	rts
dmgwrp:				* Damage the Warp Engines
	tst	warpdmg
	bne	dmwrp0		* IF (not already damaged) THEN Damage 'em
	move	#1,warpdmg
	move	#$0d011,d0
	jsr	billbadd
	move	#10,bzychange
dmwrp0:	rts
dmgafv:				* Damage the Aft-Viewer
	move	#1,aftvdmg
	move	#$0d012,d0
	jsr	billbadd
	move	#11,bzychange
	rts
dmglrs:				* Damage the Long-Range Scanner
	move	#1,scandmg
	move	#$0d013,d0
	jsr	billbadd
	move	#12,bzychange
	rts

killedus:			* ELSE whimper, whimper, you're dead
	move	#dietime,dying
	rts


*
*	BIGEXPLO  Starts a BIG explosion at a given position.
*
*	Given:
*		d0 = Xpos of Explosion
*		d1 = Ypos of Explosion
*		d2 = Zpos of Explosion
*
*	Returns:
*		w/ New Objects Added to List
*
*	Register Usage:
*		destroys a0-a6 and d0-d5
*
*	Externals:
*		explode
*
bigexplo:
	jsr	explode			* Start a Normal Explosion
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	move	#(nobjects-1),d5
bigxplp:				* FOR (All Objects) DO
	move	(a0),d0
	cmp	#fragid,d0
	blt	bigskp			* IF (Object is a fragment) THEN
	or	#bigid,d0		* Make it a BIG Fragement
bigskp:	move	d0,(a0)+
	dbra	d5,bigxplp
	rts


*
*	EXPLODE   Starts an explosion at a given position.
*
*	Given:
*		d0 = Xpos of Explosion
*		d1 = Ypos of Explosion
*		d2 = Zpos of Explosion
*
*	Returns:
*		w/ New Objects Added to List
*
*	Register Usage:
*		destroys a0-a6 and d0-d5
*
*	Externals:
*		randu
*
explode:	
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	movea.l	#xvel,a4		* a4 = object Xvel-List ptr
	movea.l	#yvel,a5		* a5 = object Yvel-List ptr
	movea.l	#zvel,a6		* a6 = object Zvel-List ptr
	move	#(nobjects-1),d5
exploop:
	move	(a0),d3
	bmi	explgo
	cmp	#fragid,d3
	blt	explnogo		* IF (Object just being wasted) THEN
explgo:	move	#(fragid+fragtime),(a0)
	movem.l	d0-d3,-(sp)
	jsr	randu
	move.l	d0,random		* get a random number
	movem.l	(sp)+,d0-d3
	move.b	random+1,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg1
	or	#$0fff8,d3
explg1:	add	d0,d3
	move	d3,(a1)
	move.b	random+2,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg2
	or	#$0fff8,d3
explg2:	add	d1,d3
	move	d3,(a2)
	move.b	random+3,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg3
	or	#$0fff8,d3
explg3:	add	d2,d3
	move	d3,(a3)			* assign new position

	move.b	random+1,d3
	asr	#4,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg4
	or	#$0fff8,d3
explg4:	move	d3,(a4)
	move.b	random+2,d3
	asr	#4,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg5
	or	#$0fff8,d3
explg5:	move	d3,(a5)
	move.b	random+3,d3
	asr	#4,d3
	and	#$0f,d3
	btst	#3,d3
	beq	explg6
	or	#$0fff8,d3
explg6:	move	d3,(a6)		* assign new velocity vector

explnogo:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3
	addq.l	#4,a4
	addq.l	#4,a5
	addq.l	#4,a6			* bump all ptrs to next object
	dbra	d5,exploop

	move.l	#explsnd4,d1
	jsr	startsad		* Make Explosion Noise

	rts


*
*	NUKE_EM	  Detonates Emergency Atomics Charge and Warps Out
*
*	Given:
*		control
*
*	Returns:
*		w/ Nuke Activated
*
*	Register Usage:
*		destroys a0-a3 and d0-d3 ???
*
*	Externals:
*		rvesector,xformpts,randu
*
nuke_em:
	move	#1,nonuke	* use up the atomics
	jsr	randu
	asr	#4,d0
	and	#$1ff,d0	* get a random Delay
	move	d0,bombing	* Start the Countdown
	jsr	rvesector
	jsr	xformpts
	move	d0,xcursor
	move	d1,ycursor	* Randomly Select a HyperJump Destination
	move	#1,hyperclean
	move	#1,hyperon	* Initiate a HyperJump
	move	#1,bzychange
	rts


*
*	AFTSHOOT   Launches a Mine (dependent upon charge and damage)
*
*	Given:
*		control
*
*	Returns:
*		w/ New Object Added to Obj-List
*
*	Register Usage:
*		destroys a0 and d0-d2
*
*	Externals:
*		freeobj,subenergy
*
aftshoot:
	tst	aftgundmg		* IF(aft gun damaged)OR(still charging)
	bne	noshaft
	tst	aftgunchrg
	bne	noshaft			* THEN skipit

	move.l	#shotsnd,d1
	jsr	startsad		* Make Shooting Noise

	move	#chrgtime,aftgunchrg	* reset charging time
	jsr	freeobj			* d0 = new Object Index
	tst	d0
	bpl	aftsh1			* IF (no free objects)
	move	#(nobjects-1),d0	* THEN Steal One
aftsh1:	add	d0,d0
	movea.l	#objid,a0
	move	#(shotid+ushotime),(a0,d0)	* initialize state and identity
	add	d0,d0
	movea.l	#xpos,a0
	clr.l	(a0,d0)
	movea.l	#ypos,a0
	clr.l	(a0,d0)
	movea.l	#zpos,a0
	move.l	#$fff00000,d1
	move.l	d1,(a0,d0)		* initialize position
	movea.l	#xvel,a0
	clr.l	(a0,d0)
	movea.l	#yvel,a0
	clr.l	(a0,d0)
	movea.l	#speedtbl,a0
	move	shipspeed,d1
	add	d1,d1
	move	(a0,d1),d1
	ext.l	d1
	swap	d1
	add.l	#-shotspd,d1		* initialize velocity
	movea.l	#zvel,a0
	move.l	d1,(a0,d0)
	move	#$10,d0
	jsr	subenergy		* use energy
noshaft:
	rts


*
*	SHOOT   Launches a Missile (dependent upon charge and damage)
*
*	Given:
*		control
*
*	Returns:
*		w/ New Object Added to Obj-List
*
*	Register Usage:
*		destroys a0 and d0-d1
*
*	Externals:
*		freeobj,subenergy
*
shoot:
	move.l	#$00100000,d1
	tst	shotleft
	beq	shoot0			* IF (last shot was left-hand)
	tst	rgundmg
	bne	shootleft		* IF (right gun functioning)
	bra	shootrite		* THEN shoot from right
shoot0:	tst	lgundmg
	beq	shootleft		* ELSE shoot from left
shootrite:
	tst	rgundmg			* THEN fire right-hand shot
	bne	noshot
	tst	rgunchrg
	bne	noshot			* IF(right-gun is charged)THEN
	move	#chrgtime,rgunchrg	* reset charging time
	clr	shotleft
	bra	shootjn
shootleft:				* ELSE fire left-hand shot
	tst	lgundmg
	bne	noshot
	tst	lgunchrg
	bne	noshot			* IF(left-gun charged and working)THEN
	neg.l	d1
	move	#chrgtime,lgunchrg	* reset charging time
	move	#-1,shotleft
shootjn:
	move.l	#shotsnd,d1
	jsr	startsad		* Make Shooting Noise

	jsr	freeobj			* d0 = new Object Index
	tst	d0
	bpl	oshit1			* IF (no free objects)
	move	#(nobjects-1),d0	* THEN Steal One
oshit1:	add	d0,d0
	movea.l	#objid,a0
	move	#(shotid+ushotime),(a0,d0)	* initialize state and identity
	add	d0,d0
	movea.l	#xpos,a0
	move.l	d1,(a0,d0)
	movea.l	#ypos,a0
	clr.l	(a0,d0)
	movea.l	#zpos,a0
	clr.l	(a0,d0)			* initialize position
	movea.l	#xvel,a0
	clr.l	(a0,d0)
	movea.l	#yvel,a0
	clr.l	(a0,d0)
	movea.l	#speedtbl,a0
	move	shipspeed,d1
	add	d1,d1
	move	(a0,d1),d1
	ext.l	d1
	swap	d1
	add.l	#shotspd,d1	* initialize velocity
	movea.l	#zvel,a0
	move.l	d1,(a0,d0)
	move	#$10,d0
	jsr	subenergy		* use energy
noshot:					* sorry, no functioning guns
	rts


*
*	SUBKYBD   Monitors Limited Subset of IKBD (Start and Stop)
*
*	Given:
*		nothing
*
*	Returns:
*		all input locations updated as needed
*
*	Register Usage:
*		destroys a0-a3 and d0-d3
*
*	Externals:
*		none
*
subkybd:
	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13		* test for console input
	addq.l	#4,sp
	tst	d0
	bne	subkb0
	rts
subkb0:
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp		* read console, d0 = input word
*
*	CASE (key-input)
*
	cmp.b	#'C'-64,d0
	bne	subkb1
	move	#1,quitgame	* Request Game Abort
	rts
subkb1:	cmp.b	#'S'-64,d0	
	bne	subkb2		* CTRL-S
	move	#1,newgame	* Request a New Game
subkb2:	rts


*
*	KEYBOARD   Monitors IKBD and sets game flags as needed.
*
*	Given:
*		nothing
*
*	Returns:
*		all input locations updated as needed
*
*	Register Usage:
*		destroys a0-a3 and d0-d3
*
*	Externals:
*		none
*
keyboard:
	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13		* test for console input
	addq.l	#4,sp
	tst	d0
	bne	kybdwhat
	rts
kybdwhat:
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp		* read console, d0 = input word
*
*	CASE (key-input)
*
	swap	d0		* test absolute scan-codes
	cmp.b	#2,d0
	blt	kbdxit
	cmp.b	#$0b,d0
	ble	kybdnum		* {0 .. 9}
	cmp.b	#$70,d0
	bgt	kbdxit
	cmp.b	#$67,d0
	bge	kybdpad		* {KEYPAD 0 .. 9}
	cmp.b	#$10,d0
	beq	kybdqut		* Q
	cmp.b	#$14,d0
	beq	kybdt		* T
	cmp.b	#$19,d0
	beq	kybdp		* P
	cmp.b	#$1e,d0
	beq	kybda		* A
	cmp.b	#$1f,d0
	beq	kybds		* S
	cmp.b	#$32,d0
	beq	kybdg		* M
	cmp.b	#$23,d0
	beq	kybdh		* H
	cmp.b	#$26,d0
	beq	kybdl		* L
	cmp.b	#$1c,d0
	beq	kybdcr		* <CR>
	cmp.b	#$2e,d0
	beq	kybdc		* C
	cmp.b	#$39,d0
	beq	kybdspa		* <SPACE>
	cmp.b	#$48,d0
	beq	kybdup		* <UPARROW>
	cmp.b	#$50,d0
	beq	kybddn		* <DOWNARROW>
	cmp.b	#$4b,d0
	beq	kybdlf		* <LEFTARROW>
	cmp.b	#$4d,d0
	beq	kybdrt		* <RIGHTARROW>
kbdxit:	rts
kybdqut:
	swap	d0		* CTRL-Q
	cmp.b	#'Q'-64,d0	
	bne	kbdq2
	move	#1,endgame	* Request Game Exit
kbdq2:	rts
kybdpad:			* KEYPAD
	sub	#$67,d0
	move.b	padvert(pc,d0),d0
	bra	kbd0		* Convert and Treat Like Any Other Numeric
padvert:
	.dc.b	7,8,9,4,5,6,1,2,3,0
kybdnum:
	subq	#1,d0
	cmp	#10,d0
	blt	kbd0
	clr	d0		* convert scan-code to number
kbd0:	tst	hyperon
	beq	kbnumz		* IF (Were in HyperSpace) THEN
	clr	hyperon		* Normal Speed, Halt any HyperDrive action
	move	#-1,bzychange
kbnumz:	cmp	shipspeed,d0
	blt	kbnump		* Choose Appropriate Sound
	move.l	#upengsnd,d1
	bra	kbnumj
kbnump:	move.l	#dnengsnd,d1
kbnumj:	move	d0,shipspeed	* Set new ship speed
	jsr	startsad	* Make Engine Noise
	rts
kybdt:
	move.l	#togglsnd,d1
	jsr	startsad	* Make Tracking Toggle Noise
	jmp	mantrack	* Alternate Target Tracking
kybdp:
	move.l	vbclock,pawstime
	jsr	silence
	move.l	#pausnd,d1
	jsr	startsad	* Make Tick-Tock Noise
kybdp0:	move.w	#2,-(sp)
	move.w	#1,-(sp)
	trap	#13		* test for console input
	addq.l	#4,sp
	tst	d0
	beq	kybdp0		* wait for console input
	move.w	#2,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.l	#4,sp		* Read Console, d0 = Char. Code
	cmp.b	#'C'-64,d0
	bne	kybdp1
	move	#1,quitgame	* Request Game Abort
	rts
kybdp1:	cmp.b	#'Q'-64,d0
	bne	kybdp2
	jsr	silence
	move	#1,endgame	* Request Game Exit
	move.l	pawstime,vbclock
	rts
kybdp2:	cmp.b	#'S'-64,d0
	bne	kybdp3
	move	#1,newgame	* Request a New Game
	rts
kybdp3:	swap	d0		* d0 = scan-code
	cmp.b	#$19,d0
	bne	kybdp0		* pause until another P
	move.l	pawstime,vbclock
	jsr	silence		* Stop Tick-Tock
	rts
kybda:
	move	#1,viewing	* Use the Aft-Viewer
	move.l	#scansnd,d1
	jsr	startsad	* Make Scanner Noise
	rts
kybds:
	swap	d0
	cmp.b	#'S'-64,d0	
	bne	kbds1		* CTRL-S
	move	#1,newgame	* Request a New Game
	rts
kbds1:	eor	#1,shieldon	* Toggle Shield On Status
	tst	shieldon
	beq	kbds2
	move	#15,shldefct	* Start Shield Effect
	move	#$0c018,d0	* "SHIELD ON"
	move.l	#shonsnd,d1
	bra	kbds3
kbds2:	move	#$0d017,d0	* "SHIELD OFF"
	move.l	#shoffsnd,d1
kbds3:	jsr	billbadd
	jsr	startsad	* Make Shield Noise
	rts
kybdg:
	clr	viewing		* Use the Galactic-Chart
	move.l	#scansnd,d1
	jsr	startsad	* Make Scanner Noise
	rts
kybdh:
	tst	hyperon
	bne	kybdh1
	move	#1,hyperclean
	move	#1,hyperon	* Turn on HyperDrive
	move	#3,bzychange
	move	#bvoice,d0
	move.l	#uphpsnd1,d1
	jsr	startsound
	move	#avoice,d0
	move.l	#uphpsnd0,d1
	jsr	startsound	* Turn On HyperSound
kybdh1:	rts
kybdl:
	move	#-1,viewing	* Use the Long-Range Scanner
	move.l	#scansnd,d1
	jsr	startsad	* Make Scanner Noise
	rts
kybdcr:
	tst	nonuke
	beq	kbdcr0		* IF (Nuke Available)
	rts
kbdcr0:	tst	nukerdy
	beq	kbdcr1		* IF ((Nuke Safety is Off)
	move	nukerdy,d0
	cmp	#52,d0		* .. AND (Door is Open))
	blt	kbdcr9
	rts
kbdcr9:	move	#bvoice,d0	* THEN Nuke-Em
	move.l	#uphpsnd1,d1
	jsr	startsound
	move	#avoice,d0
	move.l	#uphpsnd0,d1
	jsr	startsound	* Turn On HyperSound
	jmp	nuke_em
kbdcr1:	move	#60,nukerdy	* ELSE Nuke Safety Off for awhile
	move.l	#nukesnd,d1
	move	#cvoice,d0
	jsr	startsound	* Make Danger Noise
	rts
kybdc:
	swap	d0
	cmp.b	#'C'-64,d0	
	bne	kbd1		* CTRL-C
	move	#1,quitgame	* Request Game Abort
	rts
kbd1:	eor	#1,computon	* Toggle Attack-Computer On/Off
	move	#-1,bzychange
	move.l	#cmponsnd,d1
	tst	computon
	bne	kybdc1
	move.l	#cmpofsnd,d1
kybdc1:	move	#cvoice,d0
	jsr	startsound	* Make Computer Noise
	rts
kybdspa:
	jmp	aftshoot
kybdup:
	move	ycursor,d0
	subq	#1,d0
	cmp	#scrntop+2,d0
	bgt	kbd3
	move	#scrntop+2,d0
kbd3:	move	d0,ycursor	* Cursor UP, but not off veiwer
	rts
kybddn:
	move	ycursor,d0
	addq	#1,d0
	cmp	#scrnbot-6,d0
	blt	kbd4
	move	#scrnbot-6,d0
kbd4:	move	d0,ycursor	* Cursor DOWN, but not off veiwer
	rts
kybdlf:
	move	xcursor,d0
	subq	#1,d0
	cmp	#scrnleft+2,d0
	bgt	kbd5
	move	#scrnleft+2,d0
kbd5:	move	d0,xcursor	* Cursor LEFT, but not off veiwer
	rts
kybdrt:
	move	xcursor,d0
	addq	#1,d0
	cmp	#scrnrigh-3,d0
	blt	kbd6
	move	#scrnrigh-3,d0
kbd6:	move	d0,xcursor	* Cursor RIGHT, but not off veiwer
	rts


*
*	ZIPWINDOW   Clears display memory in the Window.
*
*	Given:
*		screen=current screen address
*
*	Returns:
*		with window display zeroed
*
*	Register Usage:
*		destroys all registers except the stack
*
*	Externals:
*		none
*
zipwindow:
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	a0
	clr.l	a1
	clr.l	a2
	clr.l	a3
	clr.l	a4
	clr.l	a5

	movea.l	screen,a6
	adda	#(134*160),a6
	move.w	#22,d7		* clear (23*16*52)+64 bytes = 160*120 bytes
zipwlp:
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d6/a0-a5,-(a6)
	dbra	d7,zipwlp		*clear the window
	movem.l	d0-d6/a0-a5,-(a6)
	movem.l	d0-d2,-(a6)		* clear 12 bytes
	rts


*
*	DATA STORAGE
*
	.data

lfqudtbl:			* Quadrant-Left-Edge Numbering Table
	.dc.b	3,3,3,2,2,2,2,1,1,1,1,0,0,0
rtqudtbl:			* Quadrant-Right-Edge Numbering Table
	.dc.b	9,8,8,8,8,7,7,7,7,6,6,6,6,5


*
*	RANDOM STORAGE
*

	.bss

temp:
	.ds.w	1		* Lowest-Level Local TEMPORARY storage

pawstime:
	.ds.l	1		* Time at Start of PAUSE (saved VBCLOCK)

shotleft:
	.ds.w	1		* Last Shot from Left-Hand Gun (0=right)

xgal:
	.ds.w	1		* Your Galactic Xpos
ygal:
	.ds.w	1		* Your Galactic Ypos

nrgyacc:
	.ds.w	1		* Energy Accumulator, Saves Fractional Usage

disbuff:
	.ds.w	4		* Six Character Buffer (Plus Zero-Terminater)
lrbuff:
	.ds.w	4		* Six Character Buffer (Plus Zero-Terminater)
udbuff:
	.ds.w	4		* Six Character Buffer (Plus Zero-Terminater)

trackndx:
	.ds.w	1		* Index to Who is Being Computer-Tracked

bzymode:
	.ds.w	1		* Current Busy Box Mode
bzyimage:
	.ds.w	1		* Image Offset
bzydelay:
	.ds.w	1		* Display Duration Counter
bzychange:
	.ds.w	1		* Request For Main Busy Box Change
*				* ( zero ==> no request )
*				* ( pos. ==> requested mode )
*				* ( neg. ==> do your worst )

badguys:
	.ds.w	1		* Alien Fleet Present Flag (0=No Fleet)

vote:
	.ds.w	6		* Vote Tally Area for CHOOSER
marines:
	.ds.w	1		* The Few, the Proud (End-Game Strategy Flag)

basetime:			* Base Relative Think Timers
	.ds.w	8
basedie:			* Base Absolute Death Timers
	.ds.l	8
bases:				* StarBase List (Sorted by Ypos)
	.ds.w	8		* Hi-Byte = Xpos
*				  Lo-Byte = Ypos
*				* 0 = EOList Marker
*
* NOTE: Due to Fuckups Beyond my control .. 
*       #bases and #fleets must be Hand-Carried to PANEL.S Shadows
*
fleetime:			* Fleet Relative Think Timer
	.ds.w	26
fleets:				* Alien StarFleet List (Sorted by Ypos)
	.ds.l	26		* 1st Byte = Spare
*				* 2nd Byte = Fleet Size
*				* 3rd Byte = Xpos
*				* 4th Byte = Ypos
*				* 0 = EOList Marker

	.end
