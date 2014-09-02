*
*	OBJECTS.S   3-Space Object Handling Subroutines
*		copyright 1985 ATARI Corp.
*		 (started 11/11/85 .. RZ)
*
	.text

*
*	PUBLIC SYMBOLS
*
	.globl	nobjects
	.globl	xobjcntr
	.globl	yobjcntr

	.globl	shipid
	.globl	starid
	.globl	shutid
	.globl	rockid
	.globl	shotid
	.globl	eshotid
	.globl	fragid
	.globl	bigid
	.globl	victship

	.globl	objid
	.globl	distance
	.globl	xpos
	.globl	ypos
	.globl	zpos
	.globl	xvel
	.globl	yvel
	.globl	zvel

	.globl	freeobj
	.globl	initobjs
	.globl	upobjs
	.globl	rightobjs
	.globl	downobjs
	.globl	leftobjs
	.globl	moveobjs
	.globl	aftobjs
	.globl	drawobjs
	.globl	etcobjs

	.globl	scrntop
	.globl	scrnbot
	.globl	scrnleft
	.globl	scrnrigh
	.globl	xscrnctr
	.globl	yscrnctr
	.globl	scrnhigh
	.globl	scrnsize
	.globl	scrnbyte
	.globl	ymaxscrn
	.globl	xmaxscrn


*
*	GAME CONSTANTS
*
nobjects .equ	32		* number of independent objects
xobjcntr .equ	159		* X-window Center
yobjcntr .equ	78		* Y-window Center

*	NOTE: Some of these are re-declared in AFTSTARS.S
scrnsize .equ	64		* View-Screen Size ("height" and "width")
scrnhigh .equ	64		* View-Screen Height
xscrnctr .equ	160		* View-Screen X Center
yscrnctr .equ	166		* View-Screen Y Center
scrnleft .equ	xscrnctr-(scrnsize)
scrnrigh .equ	xscrnctr+(scrnsize)
scrntop  .equ	yscrnctr-(scrnhigh/2)
scrnbot  .equ	yscrnctr+(scrnhigh/2)
scrnbyte .equ	(scrnleft/2)	* byte offset within line to view-screen
ymaxscrn .equ	scrnhigh/2
xmaxscrn .equ	scrnsize

shipid	 .equ	$0000		* Object I.D. for Enemy Ship
starid	 .equ	$1000		* Object I.D. for Star Base
shotid	 .equ	$2000		* Object I.D. for Friendly Shot
eshotid	 .equ	$3000		* Object I.D. for Enemy Shot
shutid	 .equ	$4000		* Object I.D. for Shuttle Craft
rockid	 .equ	$5000		* Object I.D. for Rock
fragid	 .equ	$6000		* Object I.D. for Explosion Fragment
bigid	 .equ	$7000		* Object I.D. for BIG Explosion Fragment
victship .equ	$0e00		* Object I.D. for Victory Ship

shutspd	.equ	$fffa0000	* Speed of Shuttle Craft

*
*	SUBROUTINE AREA
*

*
*	INITOBJS   Initializes Object Data-Base
*
*	Given:
*		control
*
*	Returns:
*		w/ Object-Arrays cleared.
*
*	Register Usage:
*		destroys a0-a1 and d0
*
*	Externals:
*		none
*
initobjs:
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	moveq.l	#-1,d0
	move	#(nobjects-1),d1	* FOR (all objects) DO
objinitlp:
	move	d0,(a0)+		* mark this object as unused
	dbra	d1,objinitlp
	rts


*
*	FREEOBJ    Finds the Next Free Object Location in Obj-List
*		   (If no free location found, HALT AND CATCH FIRE!)
*
*	Given:
*		control
*
*	Returns:
*		d0 = Index into Obj-list.
*		   (-1 if no free object available)
*
*	Register Usage:
*		destroys a0 and d0
*
*	Externals:
*		none
*
freeobj:
	move	#(nobjects-1),d0
	movea.l	#objid,a0
freeoblp:				* FOR(all objects)DO
	tst	(a0)+
	bmi	freefound		* test for a unused one
	dbra	d0,freeoblp
	rts				* ERROR - No Free Objects!
freefound:
	sub	#(nobjects-1),d0
	neg	d0			* d0 = Index of free object
	rts


*
*	RIGHTOBJS   Finds new position and velocity when stick is RIGHT.
*	UPOBJS      Finds new position and velocity when stick is UP.
*
*	Given:
*		control
*
*	Returns:
*		w/ All Objects positions and velocities Updated.
*
*	Register Usage:
*		destroys a0-a2 and d0-d3
*
*	Externals:
*		none
*
upobjs:
	movea.l	#ypos,a1		* a1 = object Ypos-List ptr
	movea.l	#yvel,a3		* a3 = object Yvel-List ptr
	bra	rtobjoin
rightobjs:
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#xvel,a3		* a3 = object Xvel-List ptr
rtobjoin:
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#zpos,a2		* a2 = object Zpos-List ptr
	movea.l	#zvel,a4		* a4 = object Zvel-List ptr
	move	#(nobjects-1),d3	* FOR (all objects) DO
objritlp:
	move	(a0),d0
	bmi	rtobjnot		* IF (object exists) THEN

	move.l	(a1),d0			* d0 = Xpos
	move.l	(a2),d1			* d1 = Zpos
	asr.l	#6,d1
	sub.l	d1,d0			* d0 = Xpos - Zpos/Factor
	bvc	rtobjok
	tst	(a1)			* oops, overflow
	bmi	rtobj1
	move.l	#$7fffffff,d0		* maximum positive
	bra	rtobjok
rtobj1:	move.l	#$80000000,d0		* maximum negative
rtobjok:
	move.l	d0,(a1)			* new Xpos
	move.l	(a2),d1			* d1 = Zpos
	asr.l	#6,d0
	add.l	d0,d1			* d1 = Zpos + newXpos/Factor
	bvc	rtobjok2
	tst	(a2)			* oops, overflow
	bmi	rtobj2
	move.l	#$7fffffff,d1		* maximum positive
	bra	rtobjok2
rtobj2:	move.l	#$80000000,d1		* maximum negative
rtobjok2:
	move.l	d1,(a2)			* new Zpos

	move.l	(a3),d0			* d0 = Xvel
	move.l	(a4),d1			* d1 = Zvel
	asr.l	#6,d1
	sub.l	d1,d0			* d0 = Xvel - Zvel/Factor
	bvc	rtobjok3
	tst	(a3)			* oops, overflow
	bmi	rtobj3
	move.l	#$7fffffff,d0		* maximum positive
	bra	rtobjok3
rtobj3:	move.l	#$80000000,d0		* maximum negative
rtobjok3:
	move.l	d0,(a3)			* new Xvel
	move.l	(a4),d1			* d1 = Zvel
	asr.l	#6,d0
	add.l	d0,d1			* d1 = Zvel + newXvel/Factor
	bvc	rtobjok4
	tst	(a4)			* oops, overflow
	bmi	rtobj4
	move.l	#$7fffffff,d1		* maximum positive
	bra	rtobjok4
rtobj4:	move.l	#$80000000,d1		* maximum negative
rtobjok4:
	move.l	d1,(a4)			* new Zvel

rtobjnot:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3
	addq.l	#4,a4			* bump all pointers to new data
	dbra	d3,objritlp
	rts


*
*	LEFTOBJS    Finds new position and velocity when stick is LEFT.
*	DOWNOBJS      Finds new position and velocity when stick is DOWN.
*
*	Given:
*		control
*
*	Returns:
*		w/ All Objects positions and velocities Updated.
*
*	Register Usage:
*		destroys a0-a2 and d0-d3
*
*	Externals:
*		none
*
downobjs:
	movea.l	#ypos,a1		* a1 = object Ypos-List ptr
	movea.l	#yvel,a3		* a3 = object Yvel-List ptr
	bra	lfobjoin
leftobjs:
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#xvel,a3		* a3 = object Xvel-List ptr
lfobjoin:
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#zpos,a2		* a2 = object Zpos-List ptr
	movea.l	#zvel,a4		* a4 = object Zvel-List ptr
	move	#(nobjects-1),d3	* FOR (all objects) DO
objleftlp:
	move	(a0),d0
	bmi	lftobjnot		* IF (object exists) THEN

	move.l	(a1),d0			* d0 = Xpos
	move.l	(a2),d1			* d1 = Zpos
	asr.l	#6,d1
	add.l	d0,d1			* d1 = Xpos + Zpos/Factor
	bvc	lftobjok
	tst.l	d0			* oops, overflow
	bmi	lfobj1
	move.l	#$7fffffff,d1		* maximum positive
	bra	lftobjok
lfobj1:	move.l	#$80000000,d1		* maximum negative
lftobjok:
	move.l	d1,(a1)			* new Xpos
	move.l	(a2),d0			* d0 = Zpos
	asr.l	#6,d1
	sub.l	d1,d0			* d0 = Zpos - newXpos/Factor
	bvc	lfobjok2
	tst	(a2)			* oops, overflow
	bmi	lfobj2
	move.l	#$7fffffff,d0		* maximum positive
	bra	lfobjok2
lfobj2:	move.l	#$80000000,d0		* maximum negative
lfobjok2:
	move.l	d0,(a2)			* new Zpos

	move.l	(a3),d0			* d0 = Xvel
	move.l	(a4),d1			* d1 = Zvel
	asr.l	#6,d1
	add.l	d0,d1			* d1 = Xvel + Zvel/Factor
	bvc	lfobjok3
	tst.l	d0			* oops, overflow
	bmi	lfobj3
	move.l	#$7fffffff,d1		* maximum positive
	bra	lfobjok3
lfobj3:	move.l	#$80000000,d1		* maximum negative
lfobjok3:
	move.l	d1,(a3)			* new Xvel
	move.l	(a4),d0			* d0 = Zvel
	asr.l	#6,d1
	sub.l	d1,d0			* d0 = Zvel - newXvel/Factor
	bvc	lfobjok4
	tst	(a4)			* oops, overflow
	bmi	lfobj4
	move.l	#$7fffffff,d0		* maximum positive
	bra	lfobjok4
lfobj4:	move.l	#$80000000,d0		* maximum negative
lfobjok4:
	move.l	d0,(a4)			* new Zvel

lftobjnot:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3
	addq.l	#4,a4			* bump all pointers to new data
	dbra	d3,objleftlp
	rts


*
*	MOVEOBJS    Finds new position from own and ships velocity.
*
*	Given:
*		control
*
*	Returns:
*		w/ All Objects X,Y and Z positions Updated.
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		none
*
moveobjs:
	move	truespeed,d0
	add	d0,d0
	movea.l	#speedtbl,a0
	move	(a0,d0),d4		* d4 = ShipSpeed (hi-word)
	swap	d4
	clr	d4			* d4 = Players Delta-Z
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	movea.l	#xvel,a4		* a4 = object Xvel-List ptr
	movea.l	#yvel,a5		* a5 = object Yvel-List ptr
	movea.l	#zvel,a6		* a6 = object Zvel-List ptr
	move	#(nobjects-1),d7	* FOR (all objects) DO
objmovelp:
	move	(a0),d0
	bmi	movobjnot		* IF (object exists) THEN
	move.l	(a1),d1			* d1 = Xpos
	add.l	(a4),d1
	move.l	d1,(a1)			* Xpos = Xpos + Xvel
	move.l	(a2),d2			* d2 = Ypos
	add.l	(a5),d2
	move.l	d2,(a2)			* Ypos = Ypos + Yvel
	move.l	(a3),d3			* d3 = Zpos
	sub.l	d4,d3
	add.l	(a6),d3
	move.l	d3,(a3)			* Zpos = Zpos - ShipSpeed + Zvel
movobjnot:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3
	addq.l	#4,a4
	addq.l	#4,a5
	addq.l	#4,a6			* bump all pointers to new data
	dbra	d7,objmovelp
	rts


*
*	MULDIV16
*
*	N = (X*Y)/Z
*  calculate intermediate 32 bit product, return 16 bit quotient.
*  One of the multipliers and the divisor may be signed.
*
*	Given:
*		d0 = multiplier1, signed word
*		d1 = multiplier2, unsigned word (15 bits)
*		d2 = divisor, signed word
*
*	Returns:
*		d0 = (d0*d1)/d2 (fru)
*
*	Register Usage:
*		clobbers d0-d2
*
*	Externals:
*		none
*
muldiv16:
	muls	d1,d0
	divs	d2,d0		*d0=(d0*d1)/d2
	bvc	mdokdiv
	move	#$7fff,d0
	rts			* oops, OVERFLOW
mdokdiv:
	move.l	d0,d1
	swap	d1		*d1=remainder
	tst	d1
	bpl	mdabs1
	neg	d1		*d1=ABS(remainder)
mdabs1:	tst	d2
	bpl	mdabs2
	neg	d2		*d2=ABS(divisor)
mdabs2:	asr	d2
	cmp	d2,d1
	blt	mdexit		*exit if (remainder<divisor/2)
	tst	d0		*test sign of quotient
	bpl	mdpos
	subq	#1,d0		*negative, decrement
	rts
mdpos:	addq	#1,d0		*positive, increment
mdexit:	rts


*
*	FA_INSERT    Inserts an object-entry into FORE or AFT list.
*
*	Given:
*		d0 = Object Number {0,2,4 .. 2*(nobjects-1)}
*		d1 = Next-Free Record in Proper List
*		a0 = Ptr to Proper List
*
*	Returns:
*		w/ FORELIST and AFTLIST altered
*		d1 bumped to next free location
*
*	Register Usage:
*		destroys a0-a1 and d0-d5
*
*	Externals:
*		none
*
fa_insert:
	tst	d1
	bne	fasome		* IF (list is empty) THEN
	move	#$0ffff,(a0)+
	move	d0,(a0)+	* add this record at the top
	bra	faend
fasome:				* ELSE
	movea.l	#distance,a1	* a1 = distance ptr
	move	(a1,d0),d2	* d2 = distance of thisobject
	clr	d3		* d3 = last ptr = root
	move	(a0),d4		* d4 = here ptr = root.nxt
	move	2(a0),d5
	cmp	(a1,d5),d2
	ble	fasearch	* IF (thisobj.dist > root.dist) THEN
	move	d0,2(a0)
	move	d5,d0		* swap-out root-object and insert it
	bra	fafound
fasearch:			* ELSE
	tst	d4
	bmi	fafound
	move	2(a0,d4),d5
	cmp	(a1,d5),d2
	bge	fafound		* WHILE (dist[here.obj] > thisobj.dist)
	move	d4,d3		* last = here
	move	(a0,d4),d4	* here = here.nxt
	bra	fasearch
fafound:
	move	d1,(a0,d3)	* last.nxt = free
	move	d4,(a0,d1)	* free.nxt = this
	move	d0,2(a0,d1)	* free.obj = thisobj
faend:
	addq	#4,d1		* bump free ptr to next slot
	rts


*
*	SORTOBJS   Sorts all objects by absolute distance prior to drawing.
*
*	Given:
*		control
*
*	Returns:
*		w/ DISTANCE, FORELIST and AFTLIST initialized
*
*	Register Usage:
*		destroys a0-a4 and d0-d7
*
*	Externals:
*		fa_insert
*
sortobjs:
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	movea.l	#distance,a4		* a4 = object Distance-List ptr
	move	#(nobjects-1),d4	* FOR (all objects) DO
objdistlp:
	move	(a0),d0
	bmi	distnobj		* IF (object exists) THEN
	move	(a1),d0
	bpl	obdst1
	neg	d0			* d0 = ABS(Xpos)
	bvc	obdst1
	move	#$7fff,d0
obdst1:	move	(a2),d1
	bpl	obdst2
	neg	d1			* d1 = ABS(Ypos)
	bvc	obdst2
	move	#$7fff,d1
obdst2:	move	(a3),d2
	bpl	obdst3
	neg	d2			* d2 = ABS(Zpos)
	bvc	obdst3
	move	#$7fff,d2
obdst3:	cmp	d0,d1
	bgt	obdst4
	exg	d0,d1			* d1 = MAX(Xpos,Ypos)
obdst4:	cmp	d1,d2
	bgt	obdst5
	exg	d1,d2			* d2 = MAX(Xpos,Ypos,Zpos)
obdst5:	asr	#2,d0
	asr	#2,d1
	add	d0,d1
	move	d1,d0
	asr	#1,d0
	add	d0,d1
	add	d1,d2			* d2 = MAX + 3/8*MIN + 3/8*MIN
	bvc	okdist
	move	#$7fff,d2		* oops, overflow
okdist:	move	d2,(a4)			* save approximate 3D Distance
distnobj:
	addq.l	#2,a0
	addq.l	#4,a1
	addq.l	#4,a2
	addq.l	#4,a3
	addq.l	#2,a4			* bump all pointers to new data
	dbra	d4,objdistlp

	clr	aftfree
	clr	forefree		* init free-list ptrs
	movea.l	#objid,a2		* a2 = object I.D.-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	clr	d6			* d6 = index of current object
	move	#(nobjects-1),d7	* FOR (all objects) DO
obsortlp:
	move	(a2),d0
	bmi	sortnobj		* IF (object exists) THEN
	move	(a3),d0
	beq	sortnobj		* IF (Zpos = 0) THEN skipit
	bmi	sortnegz		* IF (Zpos > 0) THEN
	movea.l	#forelist,a0
	move	d6,d0
	move	forefree,d1
	jsr	fa_insert		* add object to FORELIST
	move	d1,forefree
	bra	sortnobj
sortnegz:				* ELSE
	movea.l	#aftlist,a0
	move	d6,d0
	move	aftfree,d1
	jsr	fa_insert		* add object to AFTLIST
	move	d1,aftfree
sortnobj:
	addq	#2,d6
	addq.l	#2,a2
	addq.l	#4,a3			* bump all pointers to new data
	dbra	d7,obsortlp
	rts


*
*	AFTOBJS   Locates on screen, finds perspective and draws Object.
*
*	Given:
*		control
*		NOTE: SORTOBJS must have been called to init AFTLIST
*
*	Returns:
*		w/ VIEWER Screen updated to display all after objects
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		muldiv16,xorstamp,viewstamp,x160tbl
*
aftobjs:
	tst	aftfree
	beq	draftxit		* IF (any objects behind) THEN

	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	movea.l	#distance,a4		* a4 = object Distance ptr
	movea.l	#aftlist,a5		* a5 = list of after objects ptr
	clr	d7			* d7 = ptr into forelist
aftdrawlp:
	tst	d7
	bmi	draftxit		* WHILE (objects remain) DO
	move	2(a5,d7),d6		* d6 = object number
	move	(a5,d7),d7
	move	d6,d5
	add	d5,d5
	move	(a3,d5),d3
	neg	d3			* d3 = Zpos (invert for rear-view)
	move	(a1,d5),d4		* d4 = Xpos
	move	(a2,d5),d0		* d0 = Ypos
	move	#scrnsize,d1
	move	d3,d2
	jsr	muldiv16
	add	#yscrnctr,d0
	exg	d0,d4			* d4 = scrnsize*Ypos/Zpos+Ycenter = Ys
	move	#scrnsize,d1
	move	d3,d2
	jsr	muldiv16
	add	#xscrnctr,d0		* d0 = scrnsize*Xpos/Zpos+Xcenter = Xs
	move	d4,d1			* Xs,Ys ready for drawing

	move	(a4,d6),d3		* d3 = distance
	cmp	#$4000,d3
	bge	aftdrawlp		* skip anything too far to see
	cmp	#$1c00,d3
	blt	aftobj1
	move	#-1,d3			* IF (far-away) THEN use Furthest image
	bra	aftobj2
aftobj1:
	add	#$400,d3		* (objects in mirror appear farther)
aftobj2:
	move	(a0,d6),d2		* d2 = object I.D.
	move	d2,d4
	rol	#6,d4
	and	#$1c,d4
	movea.l	afratbl(pc,d4),a6
	asr	#1,d4			* d4 = Object-Type Index
	jmp	(a6)			* Branch to Proper Object Handler
afratbl:
	.dc.l	aftship,aftanim,aftanim,aftanim
	.dc.l	aftshut,aftanim,aftexpl,aftbigx

aftanim:				* Draw 8-Perspective Animated Object
	rol	#6,d3
	and	#7,d3			* d3 = proper perspective choice
	lsr	#6,d2
	and	#$38,d2			* d2 = 8*(current animation state)
	or	d3,d2
	bra	aftdrjoin
aftshut:				* Draw ShuttleCraft
	cmp	#$200,d3
	blt	afshok
	move	#$1ff,d3
afshok:	asr	#5,d3
	move	d3,d2			* d2 = proper perspective choice
	bra	aftdrjoin
aftship:				* Draw 16-Perspective Ship
	rol	#7,d3
	and	#$0f,d3			* d3 = Proper Perspective Choice
	lsr	#5,d2
	and	#$70,d2			* d2 = 16*(Ship Type)
	or	d3,d2			* NOTE: Fall Thru
aftdrjoin:
	add	aftyptbl(pc,d4),d2	* d2 = completed image number
	movem.l	d7/a0-a5,-(sp)
	jsr	viewstamp		* draw in REPLACE mode on VIEWER
	movem.l	(sp)+,d7/a0-a5
	bra	aftdrawlp
aftyptbl:
	.dc.w	shipimg,baseimg,shotimg,shatimg
	.dc.w	shutimg,rockimg

aftexpl:				* ELSE draw an explosion fragment
	cmp	#scrnleft,d0
	blt	aftdrawlp
	cmp	#scrnrigh,d0
	bge	aftdrawlp
	cmp	#scrntop,d1
	blt	aftdrawlp
	cmp	#scrnbot,d1
	bge	aftdrawlp		* clip explosion to screen
	movea.l	#x160tbl,a6
	add	d1,d1
	move	(a6,d1),d1		* d1 = line-offset into screen(bytes)
	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	aftable(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	aftdrawlp
aftable:
	.dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	.dc.w	$80,$40,$20,$10,$8,$4,$2,$1
aftbigx:				* Draw a BIG explosion fragment
	cmp	#scrnleft,d0
	blt	aftdrawlp
	cmp	#scrnrigh-1,d0
	bge	aftdrawlp
	cmp	#scrntop,d1
	blt	aftdrawlp
	cmp	#scrnbot-1,d1
	bge	aftdrawlp		* clip explosion to screen
	movea.l	#x160tbl,a6
	add	d1,d1
	move	(a6,d1),d1		* d1 = line-offset into screen(bytes)
	move	stardate,d2
	asl	#1,d2
	eor	d6,d2
	and	#2,d2
	bne	aftbig1			* Alternate Graphic Each Frame

	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	aftable2(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	adda	#152,a6
	ror	d0
	bcc	aftbg0
	addq.l	#8,a6
aftbg0:	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	aftdrawlp
aftable2:
	.dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	.dc.w	$80,$40,$20,$10,$8,$4,$2,$1
aftbig1:
	addq	#1,d0
	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	aftable2(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	adda	#152,a6
	rol	#1,d0
	bcc	aftbg1
	subq.l	#8,a6
aftbg1:	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	aftdrawlp
draftxit:
	rts


*
*	DRAWOBJS   Locates on screen, finds perspective and draws Object.
*
*	Given:
*		control
*
*	Returns:
*		w/ Screen updated to display all objects
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		sortobjs,muldiv16,xorstamp,windstamp,x160tbl
*
drawobjs:
	jsr	sortobjs		* sort objects prior to drawing
	tst	forefree
	beq	drobjexit		* IF (any objects in front) THEN

	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	movea.l	#distance,a4		* a4 = object Distance ptr
	movea.l	#forelist,a5		* a5 = list of forward objects ptr
	clr	d7			* d7 = ptr into forelist
objdrawlp:
	tst	d7
	bmi	drobjexit		* WHILE (objects remain) DO
	move	2(a5,d7),d6		* d6 = object number
	move	(a5,d7),d7
	move	d6,d5
	add	d5,d5
	move	(a3,d5),d3		* d3 = Zpos
	move	(a1,d5),d4		* d4 = Xpos
	move	(a2,d5),d0		* d0 = Ypos
	move	#160,d1
	move	d3,d2
	jsr	muldiv16
	add	#yobjcntr,d0
	exg	d0,d4			* d4 = 160*Ypos/Zpos+Ycenter = Ys
	move	#160,d1
	move	d3,d2
	jsr	muldiv16
	add	#xobjcntr,d0		* d0 = 160*Xpos/Zpos+Xcenter = Xs
	move	d4,d1			* Xs,Ys ready for drawing

	move	(a4,d6),d3		* d3 = distance
	cmp	#$4000,d3
	bge	objdrawlp		* skip anything too far to see
	cmp	#$1c00,d3
	blt	drobjz
	move	#-1,d3			* IF (far-away) THEN use Furthest image
drobjz:	move	(a0,d6),d2		* d2 = object I.D.
	move	d2,d4
	rol	#6,d4
	and	#$1c,d4
	movea.l	obratbl(pc,d4),a6
	asr	#1,d4			* d4 = Object-Type Index
	jmp	(a6)			* Branch to Proper Object Handler
obratbl:
	.dc.l	drawship,drawanim,drawanim,drawanim
	.dc.l	drawshut,drawanim,drawexpl,drawbigx

drawanim:				* Draw 8-Perspective Animated Object
	rol	#6,d3
	and	#7,d3			* d3 = proper perspective choice
	lsr	#6,d2
	and	#$38,d2			* d2 = 8*(current animation state)
	or	d3,d2
	bra	drobjoin
drawshut:				* Draw ShuttleCraft
	cmp	#$200,d3
	blt	drshok
	move	#$1ff,d3
drshok:	asr	#5,d3
	move	d3,d2			* d2 = proper perspective choice
	bra	drobjoin
drawship:				* Draw 16-Perspective Ship
	rol	#7,d3
	and	#$0f,d3			* d3 = Proper Perspective Choice
	lsr	#5,d2
	and	#$70,d2			* d2 = 16*(Ship Type)
	or	d3,d2			* NOTE: Fall Thru
drobjoin:
	add	objtyptbl(pc,d4),d2	* d2 = completed image number
	movem.l	d7/a0-a5,-(sp)
	jsr	windstamp		* draw in REPLACE mode
	movem.l	(sp)+,d7/a0-a5
	bra	objdrawlp
objtyptbl:
	.dc.w	shipimg,baseimg,shotimg,shatimg
	.dc.w	shutimg,rockimg

drawexpl:				* Draw an Explosion Fragment
	tst	d0
	bmi	objdrawlp
	cmp	#320,d0
	bge	objdrawlp
	cmp	#14,d1
	blt	objdrawlp
	cmp	#134,d1
	bge	objdrawlp		* clip explosion to screen
	movea.l	#x160tbl,a6
	add	d1,d1
	move	(a6,d1),d1		* d1 = line-offset into screen(bytes)
	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	rotable(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	objdrawlp
rotable:
	.dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	.dc.w	$80,$40,$20,$10,$8,$4,$2,$1
drawbigx:				* Draw a BIG Explosion Fragment
	tst	d0
	bmi	objdrawlp
	cmp	#319,d0
	bge	objdrawlp
	cmp	#14,d1
	blt	objdrawlp
	cmp	#133,d1
	bge	objdrawlp		* clip explosion to screen
	movea.l	#x160tbl,a6
	add	d1,d1
	move	(a6,d1),d1		* d1 = line-offset into screen(bytes)
	move	stardate,d2
	asl	#1,d2
	eor	d6,d2
	and	#2,d2
	bne	drawbig1		* Alternate Graphic Each Frame

	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	rotable2(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	adda	#152,a6
	ror	d0
	bcc	drabg0
	addq.l	#8,a6
drabg0:	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	objdrawlp
rotable2:
	.dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100
	.dc.w	$80,$40,$20,$10,$8,$4,$2,$1
drawbig1:
	addq	#1,d0
	move	d0,d3
	asr	#1,d3
	andi	#$fff8,d3		* d3 = (xpos/16)*8=row-offset(bytes)
	add	d1,d3			* d3 = offset into bitmap
	movea.l	screen,a6
	adda	d3,a6			* a6 = pointer into display memory
	and	#$0f,d0
	add	d0,d0
	move	rotable2(pc,d0.w),d0	* d0 = rotated mask
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	adda	#152,a6
	rol	d0
	bcc	drabg1
	subq.l	#8,a6
drabg1:	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+
	or	d0,(a6)+		* set pixel to color "F"
	bra	objdrawlp
drobjexit:
	rts


*
*	ETCOBJS   Handle miscellaneous functions for all objects.
*
*	Given:
*		control
*
*	Returns:
*		w/ all objects updated
*
*	Register Usage:
*		destroys a0-a6 and d0-d7
*
*	Externals:
*		none
*
etctable:
	.dc.l	etcship,etcbase,etcours,etctheirs
	.dc.l	etcshut,etcrock,etcexpl,etcexpl
etcobjs:
	movea.l	#objid,a0		* a0 = object I.D.-List ptr
	movea.l	#xpos,a1		* a1 = object Xpos-List ptr
	movea.l	#ypos,a2		* a2 = object Ypos-List ptr
	movea.l	#zpos,a3		* a3 = object Zpos-List ptr
	move	#2*(nobjects-1),d7	* d7 = index into I.D.-List
etcoblp:
	move	(a0,d7),d0
	bmi	etcjoin			* IF (object exists) THEN
	rol	#6,d0	
	and	#$1c,d0			* d0 = 4*(Object Type)
	move.l	etctable(pc,d0),a4
	jmp	(a4)			* CASE (Object Type)

etcbase:				* STARBASE
	move	(a0,d7),d0
	and	#$0f1ff,d0
	move	stardate,d1
	asl	#8,d1
	and	#$0e00,d1
	or	d1,d0			* Compute New Animation State
	move	d0,(a0,d7)
	and	#7,d0			* Get Current FSM State
	add	d0,d0
	add 	d0,d0
	move.l	etcbasfsm(pc,d0),a4
	jmp	(a4)			* Goto Current FSM State
etcbasfsm:
	.dc.l	etcbas0,etcbas1,etcbas2,etcbas3,etcbas4
etcbas0:		* STARBASE STATE (0)
	jsr	docked
	tst	d0
	beq	etcjoin			* IF (Starship Docked) THEN
	addq	#1,(a0,d7)		* THEN Goto State (1)
	move	#$0c002,d0
	jsr	billbadd		* Send "Docked" Message
	movea.l	#objid,a0		* Restore A0
	bra	etcjoin
etcbas1:		* STARBASE STATE (1)
	addq	#1,(a0,d7)		* Goto State (2)
	clr	refueled
	jsr	freeobj			* Get Next Free Object
	tst	d0
	bpl	etbs11
	move	#13,d0			* OOPS, No Free Objects!
etbs11:	movea.l	#objid,a0		* Restore A0
	add	d0,d0
	move	d0,shutindx
	move	#shutid,(a0,d0)		* Launch the Shuttle
	add	d0,d0
	move	d7,d1
	add	d1,d1			* d1 = Starbase Posn Index
	move.l	(a1,d1),(a1,d0)
	move.l	(a2,d1),(a2,d0)
	move.l	(a3,d1),d2
	sub.l	#$100000,d2
	move.l	d2,(a3,d0)		* Shuttle Starts near Starbase
	movea.l	#xvel,a4
	clr.l	(a4,d0)
	movea.l	#yvel,a4
	clr.l	(a4,d0)
	movea.l	#zvel,a4
	move.l	#shutspd,(a4,d0)	* Initial Velocity Toward Starship
	bra	etcjoin
etcbas2:		* STARBASE STATE (2)
	move	d7,d0
	add	d0,d0
	move	(a3,d0),d2		* d2 = Starbase ZPosn
	move	shutindx,d0
	move	d0,d1
	add	d1,d1
	sub	(a3,d1),d2		* d2 = Starbase ZPosn - Shuttle ZPosn
	cmp	#$10,d2
	bge	etbs22			* IF (Shuttle Too Close) THEN
	move	#-1,(a0,d0)		* Remove the Shuttle
	tst	refueled
	beq	etbs21			* IF (Successful Refit)
	addq	#1,(a0,d7)		* THEN Goto State (3)
	bra	etcjoin
etbs21:	move	(a0,d7),d0		* ELSE Goto State (0)
	and	#$0fff8,d0
	move	d0,(a0,d7)
etbs22:	bra	etcjoin
etcbas3:		* STARBASE STATE (3)
	jsr	randu
	and	#$3,d0			* get a random number
	or	#$0c000,d0
	jsr	timsqadd		* Random Well Wishing
	move	#$0e004,d0
	jsr	timsqadd		* "Starfleet Command"
	movea.l	#objid,a0
	addq	#1,(a0,d7)		* Goto State (4)
	bra	etcjoin
etcbas4:		* STARBASE STATE (4)
	jsr	docked
	tst	d0
	bne	etcjoin			* IF (Starship NOT Docked)
	move	(a0,d7),d0		* THEN Goto State (0)
	and	#$0fff8,d0
	move	d0,(a0,d7)
	bra	etcjoin

etctheirs:				* ENEMY MISSILE
	move	(a0,d7),d0
	and	#$1ff,d0
	subq	#1,d0			* count-down missile timer
	move	d0,d1
	ror	#7,d1
	and	#$0e00,d1
	or	d1,d0			* maintain animation state
	or	#eshotid,d0
	move	d0,(a0,d7)		* new enemy missile timer and I.D.
	bmi	etcjoin
	tst	gameover
	bne	etcjoin			* Lock-Out Collisions After Game
	move	d7,d6
	add	d6,d6			* d6 = index into position lists
	move	(a1,d6),d0
	bpl	etcth1
	neg	d0			* d0 = ABS(Xpos)
etcth1:	cmp	#collrad,d0
	bgt	etcjoin
	move	(a2,d6),d0
	bpl	etcth2
	neg	d0			* d0 = ABS(Ypos)
etcth2:	cmp	#collrad,d0
	bgt	etcjoin
	move	(a3,d6),d0
	bpl	etcth3
	neg	d0			* d0 = ABS(Zpos)
etcth3:	cmp	#collrad,d0
	bgt	etcjoin			* IF(ship within Collision Radius)THEN
	movem.l	d7/a0-a3,-(sp)
	jsr	hitus			* Oh shit, They Hit Us
	movem.l	(sp)+,d7/a0-a3
	move	#-1,(a0,d7)		* Remove the Shot
	bra	etcjoin

etcours:				* FRIENDLY MISSILE
	move	(a0,d7),d0
	and	#$1ff,d0
	subq	#1,d0			* count-down missile timer
	move	d0,d1
	ror	#7,d1
	and	#$0e00,d1
	or	d1,d0			* maintain animation state
	or	#shotid,d0
	move	d0,(a0,d7)		* new enemy missile I.D.
	bmi	etcjoin
	move	d7,d6
	add	d6,d6			* d6 = index into position lists
	move	#2*(nobjects-1),d5	* d5 = index into I.D.-List
*					NOTE: could search fewer objects here!!
etcourlp:				* FOR (all objects) DO
	move	(a0,d5),d0
	bmi	etourjn
	cmp	#fragid,d0
	bge	etourjn			* IF (not a fragment) THEN
	move	d5,d4
	add	d4,d4			* d4 = index into position lists
	move	(a1,d6),d0
	sub	(a1,d4),d0
	bpl	etcou1
	neg	d0			* d0 = ABS(delta-X)
etcou1:	cmp	#collrad,d0
	bgt	etourjn
	move	(a2,d6),d0
	sub	(a2,d4),d0
	bpl	etcou2
	neg	d0			* d0 = ABS(delta-Y)
etcou2:	cmp	#collrad,d0
	bgt	etourjn
	move	(a3,d6),d0
	sub	(a3,d4),d0
	bpl	etcou3
	neg	d0			* d0 = ABS(delta-Z)
etcou3:	cmp	#collrad,d0
	bgt	etourjn

	move	(a0,d5),d0
	and	#$0f000,d0		* Well .. what did we hit?
	cmp	#shotid,d0
	beq	etourjn
	cmp	#shutid,d0
	beq	etourjn			* can't hit our shots or shuttle
	movem.l	d7/a0-a3,-(sp)
	tst	d0
	bne	etcou4
	jsr	hitem			* HA! Hit one of the suckers
	bra	etcou5
etcou4:	cmp	#starid,d0		* Hit Something Else
	bne	etcou6			* IF (StarBase)
	move	#$0d016,d0
	jsr	billbadd		* "Cease Firing"
	bra	etcou7
etcou6:	move	#-1,(a0,d5)		* ELSE Hit Something Else, Remove it
etcou7:	move	(a1,d6),d0
	move	(a2,d6),d1
	move	(a3,d6),d2
	jsr	explode			* Start an Explosion Here
etcou5:	movem.l	(sp)+,d7/a0-a3
	move	#-1,(a0,d7)		* Remove the Shot
	bra	etcjoin
etourjn:
	subq	#2,d5			* bump index to new data
	bpl	etcourlp
	bra	etcjoin

etcship:				* ENEMY SHIP
	jsr	tactics
	movea.l	#objid,a0		* Restore a0
	bra	etcjoin

etcshut:				* SHUTTLE CRAFT
	move	(a0,d7),d0
	and	#7,d0			* Get Current FSM State
	add	d0,d0
	add 	d0,d0
	move.l	etcshtfsm(pc,d0),a4
	jmp	(a4)			* Goto Current FSM State
etcshtfsm:
	.dc.l	etcsht0,etcsht1,etcsht2,etcsht3,etcsht4,etcsht5
etcsht0:		* SHUTTLE STATE (0)
	jsr	docked
	tst	d0
	bne	etsh01			* IF (Starship NOT Docked) THEN
	move	(a0,d7),d0
	and	#$0fff8,d0
	or	#3,d0
	move	d0,(a0,d7)		* Goto State (3)
	bra	etcjoin
etsh01:	move	d7,d0			* ELSE
	add	d0,d0
	move	(a3,d0),d0
	cmp	#8,d0
	bge	etcjoin			* IF (Close to Starship) THEN
	addq	#1,(a0,d7)		* Goto State (1)
	bra	etcjoin
etcsht1:		* SHUTTLE STATE (1)
	move.l	#refitsnd,d1		* Refit Sound
	jsr	startsad
	jsr	initship		* Refit Starship
	move	#$0c004,d0
	jsr	billbadd		* Send "Complete" Message
	move	#1,refueled
	movea.l	#objid,a0		* Restore A0
	move	d7,d0
	add	d0,d0
	movea.l	#zvel,a4
	neg.l	(a4,d0)			* Reverse Course - To StarBase
	addq	#1,(a0,d7)		* Goto State (2)
	bra	etcjoin
etcsht2:		* SHUTTLE STATE (2)
	bra	etcjoin			* Await Capture by StarBase
etcsht3:		* SHUTTLE STATE (3)
	move	#$0c003,d0
	jsr	billbadd		* Send "Aborted" Message
	movea.l	#objid,a0		* Restore A0
	move	d7,d0
	add	d0,d0
	movea.l	#zvel,a4
	neg.l	(a4,d0)			* Reverse Course - To StarBase
	addq	#1,(a0,d7)		* Goto State (4)
	bra	etcjoin
etcsht4:		* SHUTTLE STATE (4)
	jsr	docked
	tst	d0
	beq	etcjoin			* IF (StarShip Re-Docked) THEN
	addq	#1,(a0,d7)		* Goto State (5)
	bra	etcjoin
etcsht5:		* SHUTTLE STATE (5)
	move	#$0c002,d0
	jsr	billbadd		* Send "Docked" Message
	movea.l	#objid,a0		* Restore A0
	move	(a0,d7),d0
	and	#$0fff8,d0
	move	d0,(a0,d7)		* Goto State (0)
	move	d7,d0
	add	d0,d0
	movea.l	#xvel,a4
	clr.l	(a4,d0)
	movea.l	#yvel,a4
	clr.l	(a4,d0)
	movea.l	#zvel,a4
	move.l	#shutspd,(a4,d0)	* Velocity Toward Starship Again
	bra	etcjoin

etcexpl:				* EXPLOSION FRAGMENT
	move	(a0,d7),d0
	move	d0,d1
	and	#$1ff,d0
	subq	#1,d0			* count-down explosion timer
	and	#$0f000,d1
	or	d1,d0
	move	d0,(a0,d7)		* new Fragment I.D.
	bra	etcjoin

etcrock:				* ROCK
	movea.l	#distance,a4
	move	(a4,d7),d0		* d0 = Distance
	cmp	#$5800,d0
	blt	etrck0			* IF (Rock Too Far) THEN
	move	#-1,(a0,d7)		* Remove the Rock
	bra	etcjoin
etrck0:	move	d7,d6			* ELSE
	add	d6,d6			* d6 = index into position lists
	move	(a1,d6),d0
	bpl	etrck1
	neg	d0			* d0 = ABS(Xpos)
etrck1:	cmp	#collrad,d0
	bgt	etrockjn
	move	(a2,d6),d0
	bpl	etrck2
	neg	d0			* d0 = ABS(Ypos)
etrck2:	cmp	#collrad,d0
	bgt	etrockjn
	move	(a3,d6),d0
	bpl	etrck3
	neg	d0			* d0 = ABS(Zpos)
etrck3:	cmp	#collrad,d0
	bgt	etrockjn		* IF(ship within Collision Radius)THEN
	movem.l	d7/a0-a3,-(sp)
	jsr	hitus			* Oh shit, Hit By a Rock
	movem.l	(sp)+,d7/a0-a3
	move	#-1,(a0,d7)		* Remove the Rock
	bra	etcjoin
etrockjn:
	move	(a0,d7),d0		* ELSE Do Normal Rock Processing
	and	#$0f,d0
	subq	#1,d0
	bpl	etrck4			* IF (Counted Down) THEN
	move	(a0,d7),d0
	asr	#4,d0
	and	#$0f,d0			* d0 = Counter Reset
	move	(a0,d7),d1
	add	#$200,d1
	and	#$0e00,d1		* d1 = New Animation State
	move	(a0,d7),d2
	and	#$0f0f0,d2
	or	d1,d2
	or	d0,d2
	move	d2,(a0,d7)		* Save New Rock State
	bra	etcjoin
etrck4:	move	(a0,d7),d1		* ELSE
	and	#$0fff0,d1		* Save Current Count
	or	d0,d1
	move	d1,(a0,d7)		* .. Fall Thru !!
etcjoin:
	subq	#2,d7			* bump index to new data
	bpl	etcoblp
	rts


*
*	DOCKED	 Test Whether the Starship is Docked w/Base
*
*	Given:
*		NOTE: Assumes StarBase is Object Number ZERO
*		a1 = Xpos Ptr
*		a2 = Ypos Ptr
*		a3 = Zpos Ptr
*
*	Returns:
*		d0 = Docked Flag (0=FALSE)
*
*	Register Usage:
*		destroys d0-d1
*
*	Externals:
*		none
*
docked:
	clr	d0
	move	(a1),d1
	bpl	dockd1
	neg	d1
dockd1:	cmp	#$20,d1
	bgt	nodocked	* Check X-Pos
	move	(a2),d1
	bpl	dockd2
	neg	d1
dockd2:	cmp	#$20,d1
	bgt	nodocked	* Check Y-Pos
	move	(a3),d1
	cmp	#$400,d1
	bgt	nodocked
	cmp	#$30,d1
	ble	nodocked	* Check Z-Pos
	tst	truespeed
	bne	nodocked	* Check Speed
	move	#1,d0
nodocked:
	rts


*
*	DATA STORAGE
*

	.bss
	.even

refueled:
	.ds.w	1		* Starship Refueled Flag (0=not yet)
shutindx:
	.ds.w	1		* Index to Shuttle Objid

*
*	OBJECT Data-Base
*
objid:
	.ds.w	nobjects	* Object I.D.
*				  bit 15 = unused object (1=true)
*				  bits 12-14 = Type Bits (0 = Enemy Ship)
*							 (1 = Star Base)
*							 (2 = Friendly Missile)
*							 (3 = Enemy Missile)
*							 (4 = Shuttle Craft)
*							 (5 = Rock)
*							 (6 = Expl. Fragment)
*							 (7 = BIG Fragment)
*				  bits 9-11 = Current Animation State
*				  bits 0- 8 = Naughty Bits
xpos:
	.ds.l	nobjects	* Object X-position
ypos:
	.ds.l	nobjects	* Object Y-position
zpos:
	.ds.l	nobjects	* Object Z-position
xvel:
	.ds.l	nobjects	* Object X-velocity
yvel:
	.ds.l	nobjects	* Object Y-velocity
zvel:
	.ds.l	nobjects	* Object Z-velocity
distance:
	.ds.w	nobjects	* Objects approximate 3D Distance
aftlist:
	.ds.l	nobjects	* After-View Object-List
forelist:
	.ds.l	nobjects	* Fore-View Object-List
*				  hi-word = index to next list-elm
*				  lo-word = index to associated object
forefree:
	.ds.w	1		* index to next free item in fore-list
aftfree:
	.ds.w	1		* index to next free item in aft-list

	.end
