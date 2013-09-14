*
*	noise.s	program to set bios variables for control panel sound
*
	.text
	.globl	_donoise
	.globl	_rsave
	.globl	_set_state
	.globl	_remap2

conterm	equ	$0484
ucr	equ	$FFFA29
tddr	equ	$FFFA25
tdcr	equ	$FFFA1D

*
*	donoise	Set console noise bits
*
*	param 0 = click on/off (word)
*	param 1 = bell on/off (word)
*
_donoise:
	bsr	super
	move.w	4(sp),d0
	lsl.w	#2,d0
	or.w	6(sp),d0
	and.b	#$0fa,conterm
	or.b	d0,conterm	*set new bell and click values
	bsr	unsuper
	rts


* ==================================================
*  	SET STATE OF RS232 PORT
* ==================================================

_set_state:
	move.w	#$ffff,-(sp)	* scr
	move.w	#$ffff,-(sp)	* tsr
	move.w	#$ffff,-(sp)	* rsc
	move.w	#$ffff,-(sp)	* ucr
*
	lea	_rsave,a0	* flow control
	move.b	4(a0),d0
	ext.w	d0
	move.w	d0,-(sp)	* flow control to stack
*
	clr.w	d0
	move.b	1(a0),d0	* baud rate
	lea	_remap2,a1
	move.b	(a1,d0.w),d0
	ext.w	d0
	move.w	d0,-(sp)	* baud rate to stack
	move.w	#15,-(sp)
	trap	#14
	adda.w	#$e,sp		* clean up the stack	

	bsr	super		* into supervisor

	clr.w	d0
	lea	_rsave,a0	* flow control
	move.b	1(a0),d0	* get baud rate
	cmp.b	#14,d0		* This code is necessary in order to fix
	blt	no_bugfix	* the bug in the 11/20/85 release of the roms.
	movea.l	#tdcr,a0	* Timer d+c control reg
	move.b	(a0),d1		* involving baud rates of 50 and 75.
	and.b	#$f0,d1		* mask out old value
	or.b	#$02,d1		* or in new value
	move.b	d1,(a0)		* stuff it in
	movea.l	#tddr,a0	* a0 ->timer d data reg
	cmp.w	#14,d0
	bne	do_50
	move.b	#102,(a0)	* set new data value for 75 baud
	bra	no_bugfix
do_50:
	move.b	#154,(a0)	* set new data value for 50 baud
no_bugfix:
	movea.l	#ucr,a0
	move.b	(a0),d0		* get ucr byte
	lea	_rsave,a0
	moveq	#0,d1
	move.b	3(a0),d1	* bits/char
	asl.b	#5,d1
	and.b	#$99,d0		* clear bits 1,2,5,6
	or.b	d1,d0
	moveq	#0,d1
	move.b	2(a0),d1	* parity
	bne	prty1
	bclr	#2,d0		* disable parity
	bra	prtyout
prty1:
	bset	#2,d0		* enable parity
	bclr	#1,d0		* clear odd/even
	cmp.b	#2,d1
	bne	prtyout		* since bit=0 odd parity
	bset	#1,d0		* select even parity
prtyout:
	move.b	d0,ucr		* store new state
	bsr unsuper
	rts

* =================================================
* GET INTO SUPERVISOR MODE
* =================================================

super:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1		* enter supervisor mode
	addq.l	#6,sp
	move.l	d0,savessp
	rts

* =================================================
* GET OUT OF SUPERVISOR MODE
* =================================================

unsuper:
	move.l	savessp,-(sp)
	move.w	#$20,-(sp)
	trap	#1			* return to user mode
	addq.l	#6,sp
	rts


* ================================================
*	data
* ================================================

	.bss
savessp:
	.ds.l	1		*storage for supervisor stack pointer

	.end

