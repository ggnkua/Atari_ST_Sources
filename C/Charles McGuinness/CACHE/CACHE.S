*************************************************************************
*									*
*	PROGRAM								*
*		cache		Provide disk sector caching for TOS	*
*									*
*									*
*									*
*	This program works by catching the TRAP #13 (BIOS) interrupt,	*
*	and checking to see if the call is RWABS.  If it is, then the	*
*	call is handled locally.  If not, then we just pass the call	*
*	on through...							*
*									*
*	This program links with CCACHE.O and CLIB.O			*
*									*
*************************************************************************
*									*
*	Copyright 1987, Charles McGuinness.  Distribution beyond	*
*	the CompuServe Information Service prohibited.			*
*									*
*************************************************************************

	.xdef	rwabs		* Routine to call to get a real RWABS

	.xref	myrwabs
	.xref	dchange
	.xref	xrwflag
	.xref	xnumber
	.xref	xrecno
	.xref	xdev
	.xref	xbuffer
	.xref	xchar
	.xref	lru_startup
	
start:	move.l	#banner,-(sp)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	#-1,-(sp)
	move.w	#32+13,-(sp)
	move.w	#5,-(sp)	
	trap	#13
	move.l	d0,oldvector
	addq.l	#8,sp

	move.l	#trap13,-(sp)
	move.w	#32+13,-(sp)
	move.w	#5,-(sp)	
	trap	#13
	addq.l	#8,sp


	move.l	#$ffffff,d0
wait:
	sub	#1,d0
	bne	wait

	move.w	#0,-(sp)	* No error
	jsr	lru_startup	* Get size of buffers
	add.l	#$1000,d0	* + 4k (THIS IS GENEROUS)
	move.l	d0,-(sp)	* Total size of .S + .C ...
	move.w	#$31,-(sp)	* TSR
	trap	#1



rwabs:
	move.w	xdev,-(sp)
	move.w	xrecno,-(sp)
	move.w	xnumber,-(sp)
	move.l	xbuffer,-(sp)
	move.w	xrwflag,-(sp)
	move.w	#32,-(sp)		* This gets changed to 4 below
	trap	#13
	add.l	#14,sp
	rts

saveret:	.ds.l	1
oldvector:	.ds.l	1

*************************************************************************
*									*
*	Vector for TRAP #13 intercept code....				*
*									*
*************************************************************************

*	Step 1: We want to get A0 pointing to the base of the arguments
*		to the BIOS function.  This involves figuring out which
*		stack pointer points to the arguments (since we are now
*		in supervisor mode but the TRAP could have been done in
*		user mode), and then adjusting the correct stack pointer
*		to point to the arguments.

trap13:
	move.w	(sp),d0
	btst	#13,d0		* Were we in Super mode?
	bne	super

	move.l	usp,a0
	bra	next

super:
	move.l	sp,a0
	addq.l	#6,a0		* Get past SR, pushed PC

*
*	Step 2:	See if this was a RWABS..
*
	
next:
	move.w	0(a0),d0
	cmpi.w	#4,d0		* Is this a RWABS?
	bne	trapend		* Nope, we're done...

*
*	Step 3:	If there's been a media change, call the LRU routine
*		that will flush the cache and perform the rwabs

	move.l	a0,-(sp)	* Save the stack frame...
	move.w	10(a0),-(sp)	* Copy the device...
	move.w	#9,-(sp)	* meadiach ...
	trap	#13		* OK, so this IS recursive...
	addq.l	#4,sp
	move.l	(sp)+,a0	* get the stack frame back

	cmpi.l	#2,d0		* Did the media change???
	beq	xdchange	* Yes, flush the buffers

*
*	Step 4:	Call our routine to fetch from cache, if we can
*

	move.w	12(a0),xdev
	move.w	10(a0),xrecno
	move.w	8(a0),xnumber
	move.l	4(a0),xbuffer
	move.w	2(a0),xrwflag

	jsr	myrwabs

	rte			* We're done....


*
*	Step 4b: The disk has changed ... oops!
*

xdchange:

	move.w	12(a0),xdev
	move.w	10(a0),xrecno
	move.w	8(a0),xnumber
	move.l	4(a0),xbuffer
	move.w	2(a0),xrwflag

	jsr	dchange

	rte			* We're done....

*
*	TRAPEND:	If the BIOS call was 32 (which is undefined),
*			it really is a 4 (rwabs), but wants to bypass
*			the cache...

trapend:
	cmpi.w	#32,d0		* Unfiltered RWABS
	bne	notmine
	move.w	#4,0(a0)	* Modify the arguments on the stack

notmine:
	move.l	oldvector,a0
	jmp	(a0)

banner:	.dc.b	"Disk Caching System, Version 0.0",$0d,$0a
	.dc.b	"Copyright 1987, Charles McGuinness.  All rights reserved"
	.dc.b	13,10
	.dc.b	"Support of this program can be found in "
	.dc.b	"the Atari ST forums on CompuServe",13,10
	.dc.b	0
	.end

