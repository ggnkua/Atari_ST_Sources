*	Rename to INTERRUPT.S		9/5/90		D.Mui
*	RATRBP.S	11/06/84 - 03/27/85		Lowell Webster	
* 	Change at tikcod to check if the timer event is being recorded 
*	in the forkq			12/5/88		D.Mui
*	Use MAC to assemble	6/28/90			Derek Mui
* 	assemble with MAS 		900801 		kbad
*	Restore b_click into geminput.c	9/4/90		D.Mui
*	Restore b_delay into geminput.c	9/4/90		D.Mui

*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
 
	.text

	.globl	_far_bchange
	.globl	_bchange
	.globl	_b_delay
	.globl	_far_mchange
	.globl	_mchange
	.globl  _drwaddr
	.globl	_forkq
	.globl	_justretf
	.globl	_tiksav
	.globl	_tikaddr
	.globl	_tchange
	.globl	_tikcod
	.globl	_NUM_TICK
	.globl	_CMP_TICK
	.globl	_gl_btrue
	.globl	_gl_bdelay
	.globl	_gl_bdesired
	.globl	_gl_bpend
	.globl	_bchange
	.globl	_gl_xrat
	.globl	_gl_yrat	
	.globl	_b_click

*****************************************************************
*	  called far with d0 = button state			*
*	  interrupts should be off and in supervisor mode	*	
*	  calls b_click in geminput.c				*
*****************************************************************

_far_bchange:
	move.l	a7,gstksave		; save stack, paranoid code
	lea.l	gstack,a7
	movem.l	d0-d2/a0-a2,-(sp)	; save regs that c will crunch
	move.w	d0,-(sp)		; pass button state, only if tick in gsx
	jsr	_b_click		; register this click event
	addq.l	#2,sp
	movem.l (sp)+,d0-d2/a0-a2
	movea.l	gstksave,a7
	rts

*****************************************************************
*	called far with interrupts off				*
*	d0 = xposition, d1 = yposition in absolute pixels	*
*****************************************************************

_far_mchange:
	move.l	a7, gstksave		; save stack
	lea.l 	gstack,a7
	movem.l d0-d2/a0-a2,-(sp)	; save regs that C will crunch

	move.w	d1,-(sp)		; delta y
	move.w	d1,_gl_yrat
	move.w	d0,-(sp)		; delta x
	move.w	d0,_gl_xrat
	move.l	#_mchange,-(sp)
	jsr	_forkq			; call forkq
	addq.l	#8,sp

	movem.l (sp)+,d0-d2/a0-a2
	move.l	gstksave,a7
	rts

*********************************************************
*	call gsx with absolute x and y to draw cursor	*
*********************************************************	

*_drawrat:
*	move.w	4(a7),d0		; xrat
*	move.w	6(a7),d1		; yrat
*	move.l	_drwaddr,-(sp)
*	rts

_justretf:
	rts

*********************************************************	
*	Timer interrupt code				*
*	called far with interrupts disabled		*
*	do not need to save registers			*
*********************************************************

_tikcod:
	move.l	a7, tstksave		; save stack
	lea.l 	tstack,a7
	addq.l	#1,TICKS		; bump up the absolute clock
	tst.l	_CMP_TICK		; are we timing now?
	beq	tpollmb			; nope, go away
	addq.l	#1,_NUM_TICK		; yes, we're timing
	subq.l	#1,_CMP_TICK
	bne	tpollmb
	move.l	_NUM_TICK,-(a7)		; we need to establish a forkq
	move.l	#_tchange,-(a7)		; that will pick us up	
	jsr	_forkq
	addq.l	#8,a7
	tst.w	d0			; event recorded ?
	bne	tpollmb			; Yes
	addq.l	#1,_CMP_TICK		; No, so reset the counter

tpollmb:
	move.w	#1,-(a7)		; count down for button delay	
	jsr	_b_delay
	addq.l	#2,a7
	move.l	tstksave,a7	; Interrupt processed, restore everything

*********************************************************	
* 	Chain to next guy who wants to get ticked!	*
*********************************************************

	move.l	_tiksav,-(a7)	; Go through some other vector.
	rts


	.bss
	.even

* addr in gsx in rat draw routine

;_gl_xrat:	.ds.w	1		; commented out by HMK 03/24/93 since they 
;_gl_yrat:	.ds.w	1		; redefined in gemsigna.c !!!

_drwaddr:	.ds.l	1		; initialized to _justretf
_tikaddr:	.ds.l	1		; initialized to _tikcod
gstksave:	.ds.l	1
tstksave:	.ds.l	1
_tiksav:	.ds.l	1		; addr in gsx driver of tick service
_NUM_TICK:	.ds.l	1
_CMP_TICK:	.ds.l	1
TICKS:		.ds.l	1		; absolute number of ticks NOT GLOBAL!
		.ds.l	23		; gsx stack for mouse
gstack:		.ds.l	1
		.ds.l	100		; tick stack
tstack:		.ds.l	1

	.end
