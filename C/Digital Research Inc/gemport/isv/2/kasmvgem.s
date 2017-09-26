
*	@(#)terma.s	3.1	
*
*	assembly routines for term.c using
*	interrupt driven serial input
*
*	globals
*
	.globl	_serint
	.globl	_setivecs
	.globl	_resvecs
	.globl	_seti
	.globl	_clri
	.globl	_setvmecr
	.globl	_tim_init
	.globl	_tim_dinit
	.globl	_timer_int
*
*	vectors
*
trp4vec: .equ	$90
trp5vec: .equ	$94
int4vec: .equ	$114
*
*	original vector storage
*
	.data
	.comm	trp4sav,4
	.comm	trp5sav,4
	.comm	int4sav,4
	.text
*
*	initialize vectors
*
_setivecs:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	SR, -(sp)	* disable interrupts
	ori.w	#$700, SR

	move.l	trp4vec,trp4sav
	move.l	#newtrp4,trp4vec
	move.l	trp5vec,trp5sav
	move.l	#newtrp5,trp5vec
	move.l	int4vec,int4sav
	move.l	#newint4,int4vec

	move	(sp)+, SR	* Restore interrupt context

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack
	rts
*
*	restore vectors
*
_resvecs:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	SR, -(sp)	* disable interrupts
	ori.w	#$700, SR

	move.l	trp4sav,trp4vec
	move.l	trp5sav,trp5vec
	move.l	int4sav,int4vec

	move	(sp)+, SR	* Restore interrupt context

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack
	rts
*
*	interrupt 4 entry
*
newint4:
	movem.l	a0-a6/d0-d7,-(a7)
	link	a6,#-4
	jsr	_serint
	unlk	a6
	movem.l	(a7)+,a0-a6/d0-d7
	rte
*
*	set interrupt mask
*
_seti:	move.w	#$700,d0
	trap	#4
	rts
*
*	clear interrupt mask
*
_clri:	move.w	#$0,d0
	trap	#4
	rts
*
*	trap #4 handler - change
*	interrupt mask per d0
*
newtrp4:
	move.w	(a7),d1
	and.w	#$f8ff,d1
	or.w	d0,d1
	move.w	d1,(a7)
	rte
*
*	set vme/10 control register
*	must be done in supervisor mode
*
_setvmecr:
	move.w	4(a7),d0	* control reg #
	move.l	#$f19f05,a0	* convert to addr
	asl.w	#1,d0
	add.w	d0,a0
	move.w	6(a7),d0	* contents
	trap	#5		* get to super mode
	rts
*
*	trap 5 handler - write
*	to vem/10 control register
*
newtrp5:
	move.b	d0,(a0)
	rte
*
_tim_init:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	SR, -(sp)	* disable interrupts
	ori.w	#$700, SR

	pea	timint		* My timer vector
	move.w	#$100, -(sp)	* 100 is timer vector
	move.w	#5, -(sp)	* exchange exception vector
	trap	#13

	move.l	d0, tim_chain	* Set up chain before ints go on

	addq.l	#8, sp		* clean up stack

	move	(sp)+, SR	* Restore interrupt context

	move.w	#6, -(sp)	* Get the number of milliseconds per tick
	trap	#13
	addq.l	#2, sp

	move.w	d0, sav_cnt

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack

	move.w	sav_cnt, d2	*Compute the number of ticks per second
	move.w	#1000, d0
	divs	d2, d0

	move.l	d0, d1		*Round if necessary
	swap	d1
	asl.w	#1, d1
	cmp.w	d1, d2
	blt	no_round
	addq.w	#1, d0		*Round up

no_round:
	rts

_tim_dinit:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.l	tim_chain, -(sp)	* reset timer vector
	move.w	#$100, -(sp)
	move.w	#5, -(sp)
	trap	#13
	addq.l	#8, sp

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack
	rts

timint:
	movem.l	d0-d7/a0-a6,-(sp)

	jsr	_timer_int

	movem.l (sp)+,d0-d7/a0-a6

	move.l	tim_chain, -(sp)
	rts

	.bss
oldvec		.ds.l	1
tim_chain	.ds.l	1
sav_cnt		.ds.w	1
	.end
