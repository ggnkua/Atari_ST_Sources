* Play the MAD MAX music!
* by James Ingram, April 1994

	opt	x+,o-,ow-


	include	\includes\macros.s


	super_on

	moveq	#1,d0
	bsr	music		; initialise music routines
	
	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w	; install player
	
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	
	move.l	(a7)+,$70.w
	
	super_off
	clr.w	-(a7)
	trap	#1

my_70:
	movem.l	d0-7/a0-6,-(a7)


* SYNCRONISE SCREEN!
	move.w	#$8209,a0	; get screen counter address
	moveq	#0,d0
	moveq	#16,d1		; prepare registers

.wait:
	move.b	(a0),d0
	beq.s	.wait		; wait for counter to start

	sub.w	d0,d1		; get number of rotations to do

	lsl.w	d1,d0		; now syncronise!

	move.w	$ffff8240.w,-(a7)
	move.w	#$f00,$ffff8240.w

* play music...
	bsr	music+8

	move.w	(a7)+,$ffff8240.w


	movem.l	(a7)+,d0-7/a0-6
	rte

music:
	incbin	awe.mus
	even
