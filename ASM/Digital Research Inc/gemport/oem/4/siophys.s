*  siophys.s - physical level routines for sio driver			*
*	_sioinit -, sioint -, 

****************************************************************************
*  improvements:
*
*  1	driver should look at a variable defined in the C code which indicates
*	whether we are working on channel A or channel B -- dynamic handling
*	of channel.
*
*  2	move all but the interrupt code into C
*
****************************************************************************


	.text
*
*  externals
*
	.xdef _rxint
	.xdef _txint
*
*  globals
*
	.xref	_siodinit
	.xref	_sioinit

* rs232 drivers

rs232a	=	$FCD200		*  channel a
rs232b	=	$FCD1FE		*  channel b

rs232	=	rs232a		*  defines which one we will be using

* offset 3-ctl, 7-data

_sioinit:
***************************************************************************
*	clr.l	-(sp)		* Get supervisor mode
*	move	#32, -(sp)
*	trap	#1
*
*	move.l	d0, 2(sp)	* Build return to user mode on stack
*	move.w	#32, (sp)	* BDOS trashes function number
***************************************************************************

	move.w	SR, -(sp)	* save current status
	ori.w	#$700, SR	* disable interrupts

	move.l	#rs232,a0
	lea	3(a0),a0	* a0 => cntl port

* reg 9 , c2

	move.b	(a0),d0		* read ctl port (sync)
	nop
	move.b	#9,(a0)		* select reg 9 
	nop
	move.b	#$c2,(a0)	* write to reg 9 

* reg 9 , ( rs232a ? 8a : 4a )

	move.b	(a0),d0		* read ctl port (sync)
	nop
	move.b	#9,(a0)		* select reg 9
	nop

	.ifeq	rs232-rs232a
	move.b	#$8A,(a0)	* write to reg 9
	.endc
	.ifeq	rs232-rs232b
	move.b	#$4A,(a0)	* this is $8A for reg A
	.endc

* reg 11, 50

	nop
	move.b	#11,(a0)
	nop
	move.b	#$50,(a0)
	nop

* reg 14,3

	move.b	#14,(a0)
	nop
	move.b	#3,(a0)

* reg 13,0

	nop
	move.b	#13,(a0)
	nop
	move.b	#0,(a0)

* reg 12 (rs232a ? 0b : 0a ) (baud rate ?)

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

* setvec 

	move.l	$78, oldvec	* save current vector
*	move.l	#rsint,$78	* store new int vector
	move.l	#sioint,$78	* store new int vector

* reg 2,0

	move.b	#2,(a0)
	nop
	move.b	#0,(a0)		* vector reg

* explicitly enable receiver and xmit interrupts ($12 -> reg 1)

	nop
	move.b	#1,(a0)
	nop
	move.b	#$12,(a0)

	move	(sp)+, SR	* Restore interrupt context

***************************************************************************
*	trap	#1		* return to user mode
*	addq.l	#6, sp		* clean sup mode call off the stack
***************************************************************************

	rts

***************************************************************************
*
*  _siodinit -
*	restore rs232 context for uninit
*

_siodinit:
	rts

*
*_ser_dinit:
*	move.l	#rs232,a0
*	lea	3(a0),a0	* a0 => ctl port
*	move.b	(a0),d0		* read ctl port to sync
*	nop
*
*	move.b	#1, (a0)	* disable rs232 interrupts
*	nop
*	move.b	#0, (a0)
*	nop
*
*	move.l	oldvec, $78	* restore old interrupt vector
*
*	rts
***************************************************************************

*
*  sioint -
*	rs232 interrupt
* 
*	determine whether tx or rx interrupt and handle
*	by calling appropriate routine in sioint.c
*	if not tx or rx int, ignore.
*

*********************************************************************
*rsint:
*	movem.l	d0-d2/a0-a2,-(sp)	* all the regs that C will mung
*
*	move.b	rs232+3,d0		* d0 => ctl port 
*	btst	#0,d0			* test rx flag
*	beq	norxi			* if not rx, try tx
*	  bsr     _rxint		*   handle rx char
*	  move.b  rs232+3,d0		*   d0 => ctl port
*
*norxi:	btst	#2,d0			* test bit tx flag
*	beq	retint			* if not xmit, ignore
*	  bsr	  _txint		*   handle tx char
*
*retint:	movem.l	(sp)+,d0-d2/a0-a2	* restore regs
*	rte
*
*********************************************************************

sioint:	
	movem.l	d0-d2/a0-a2,-(sp)	* all the regs that C will mung
*
	move.b	rs232+3,d0		* d0 => ctl port 
	btst	#0,d0			* test rx flag
	beq	norxi			* if not rx, try tx
	  jsr	  _rxint		*   call C  intr handler
	  move.b  rs232+3,d0		*   d0 => ctl port

norxi:	btst	#2,d0			* test bit tx flag
	beq	retint			* if not xmit, ignore
	  jsr	  _txint		*   handle tx char

retint:	movem.l	(sp)+,d0-d2/a0-a2	* restore regs
	rte

*********************************************************************

		.bss

oldvec:		.ds.l	1	* save old rs232 int vector here

		.end
