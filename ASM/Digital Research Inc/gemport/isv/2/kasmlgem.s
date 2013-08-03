	.text
	.globl _ser_init
	.globl _rxint
	.globl _txint
	.globl _ser_dinit
	.globl	_tim_init
	.globl	_tim_dinit
	.globl	_timer_int


* rs232 drivers
rs232a	=	$FCD200
rs232b	=	$FCD1FE

rs232	=	rs232a
* offset 3-ctl, 7-data

_ser_init:
	clr.l	-(sp)		* Get supervisor mode
	move	#32, -(sp)
	trap	#1

	move.l	d0, 2(sp)	* Build return to user mode on stack
	move.w	#32, (sp)	* BDOS trashes function number

	move.w	SR, -(sp)	* disable interrupts
	ori.w	#$700, SR

	move.l	#rs232,a0
	lea	3(a0),a0	* cntl port
	move.b	(a0),d0	* sync
	nop
	move.b	#9,(a0)
	nop
	move.b	#$c2,(a0)
	move.b	(a0),d0	* sync
	nop
	move.b	#9,(a0)	* select reg 9
	nop

	.ifeq	rs232-rs232a
	move.b	#$8A,(a0)
	.endc
	.ifeq	rs232-rs232b
	move.b	#$4A,(a0)	* this is $8A for reg A
	.endc

* reg 11, 50
	nop
	move.b	#11,(a0)
	nop
	move.b	#$50,(a0)
* reg 14,3
	nop
	move.b	#14,(a0)
	nop
	move.b	#3,(a0)
* reg 13,0
	nop
	move.b	#13,(a0)
	nop
	move.b	#0,(a0)
* reg 12,0A (baud rate, use $0B for reg A)
	nop
	move.b	#12,(a0)
	nop
	.ifeq	rs232-rs232a
	move.b	#$0B,(a0)
	.endc
	.ifeq	rs232-rs232b
	move.b	#$0A,(a0)
	.endc
* reg 4,44
	nop
	move.b	#4,(a0)
	nop
	move.b	#$44,(a0)
* reg 10,0
	nop
	move.b	#10,(a0)
	nop
	move.b	#0,(a0)
* reg 3, c1
	nop
	move.b	#3,(a0)
	nop
	move.b	#$C1,(a0)
* reg 5,ea
	nop
	move.b	#5,(a0)
	nop
	move.b	#$ea,(a0)
	move.l	$78, oldvec
	move.l	#rsint,$78	* set up int vector
	move.b	#2,(a0)
	nop
	move.b	#0,(a0)		* vector reg
* explicitly enable receiver and xmit interrupts ($12 -> reg 1)
	nop
	move.b	#1,(a0)
	nop
	move.b	#$12,(a0)

	move	(sp)+, SR	* Restore interrupt context

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack
	rts

rsint:	movem.l	d0-d2/a0-a2,-(sp)	* all the regs that C will mung
	move.b	rs232+3,d0
	btst	#0,d0
	beq	norxi
	bsr	_rxint
	move.b	rs232+3,d0
norxi:	btst	#2,d0
	beq	retint	* I don't know what it was 
	bsr	_txint
retint:	movem.l	(sp)+,d0-d2/a0-a2
	rte


_ser_dinit:
	move.l	#rs232,a0
	lea	3(a0),a0	* cntl port
	move.b	(a0),d0		* sync
	nop

	move.b	#1, (a0)	* disable rs232 interrupts
	nop
	move.b	#0, (a0)
	nop

	move.l	oldvec, $78	* restore old interrupt vector

	rts

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

	trap	#1		* return to user mode
	addq.l	#6, sp		* clean sup mode call off the stack

	move.w	#60, d0		* Return the number of ticks per second
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
oldvec	.ds.l	1
tim_chain	.ds.l	1

	.end
