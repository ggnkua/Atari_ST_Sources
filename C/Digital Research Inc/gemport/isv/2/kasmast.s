	.text
	.globl	_tim_init	* Global entries defined here
	.globl	_tim_dinit
	.globl	_sputc
	.globl	_rx1
	.globl	_auxstat
	.globl	_cputc
	.globl	_cgetc
	.globl	_constat

	.xref	_timer_int	* Global routines used

_auxstat:			* Return status of RS232 port
	move.w	#1, handle
	bra.s	stat

_constat:			* Return status of the console
	move.w	#2, handle
	bra.s	stat

_rx1:				* Get a character from the RS232 port
	move.w	#1, handle
	bra.s	get

_cputc:				* Put a character to the console
	move.w	#2, handle
	bra.s	put

_sputc:				* Put a character to the RS232 port
	move.w	#1, handle
	bra.s	put

_cgetc:				* Get a character from the console
	move.w	#2, handle
	bra.s	get

stat:				* Get status of a device
	subq.l	#2, sp		* save a word on the stack for return status

	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	handle, -(sp)	* see if a character present
	move.w	#1, -(sp)
	trap	#13

	addq.l	#4, sp		* clean the bios call off the stack
	move.w	d0, 6(sp)	* sup call will trash d0 so save status

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack

	move.w	(sp)+, d0	* pop back status and return
	rts

get:				* Get a character from a device
	subq.l	#2, sp		* save a word on the stack for character

	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	handle, -(sp)	* Get the character
	move.w	#2, -(sp)
	trap	#13

	addq.l	#4, sp		* clean the bios call off the stack
	move.w	d0, 6(sp)	* sup call will trash d0 so save character

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack

	move.w	(sp)+, d0	* pop back character and return
	rts

put:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.b	11(sp), d0	* get the character from the stack
	andi.w	#$00FF, d0

	move.w	d0, -(sp)	* put the character
	move.w	handle, -(sp)
	move.w	#3, -(sp)
	trap	#13
	addq.l	#6, sp		* clean put char call off the stack

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack
	rts



_tim_init:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	SR, -(sp)	* disable interrupts
	ori.w	#700, SR

	pea	timint		* My timer vector
	move.w	#$100, -(sp)	* 100 is timer vector
	move.w	#5, -(sp)	* exchange exception vector
	trap	#13

	move.l	d0, tim_chain	* Set up chain before ints go on

	addq.l	#8, sp		* clean up stack

	move	(sp)+, SR	* Restore interrupt context

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack

	move.w	#6, -(sp)	* Get number of milliseconds per tick
	trap	#13
	addq.l	#2, sp

	move.w	d0, d2		* Compute the number of ticks per second
	move.w	#1000, d0
	divs	d2, d0

	move.l	d0, d1		* round if necessary
	swap	d1
	asl.w	#1, d1

	cmp.w	d1, d2
	blt	no_round

	addq.w	#1, d0
no_round:
	rts

_tim_dinit:
	move.l	tim_chain, -(sp)	* reset timer vector
	move.w	#$100, -(sp)
	move.w	#5, -(sp)
	trap	#13
	addq.l	#8, sp
	rts

timint:
	jsr	_timer_int	* Invoke the Kermit timer code

	move.l	tim_chain, -(sp)
	rts

	.bss
handle:		ds.w	1
tim_chain:	ds.l	1
	.end
