******************************************************************************
**
** mouse.s -	mouse driver for VME/10.
**		Rides on top of physical interrupt handlers for the MVME400
**		serial card (the NEC 7201 MPSCC).
**
** CREATED
** 21 oct 84 lw		Originally part of the screen driver that got
**			installed dynamically on CP/M-68K.
**
** MODIFICATIONS
**  2 may 85 rjg	Converted to GEM DOS.
**
** 27 sep 85 scc	Modified to be part of the BIOS.
**
** 30 sep 85 scc	Added '_moulox'.
**
**  9 oct 85 scc	Modified state 0 of the mouse packet machine by
**			deleting (commenting out) the 'call' to the logical
**			interrupt handler.  In the test program, this call
**			was causing the delta-x info to be cleared before
**			it could be retrieved by the main program when set
**			by the state 4 call.
**
** NAMES
**	lw	Lowell Webster
**	rjg	Richard J. Greco
**	scc	Steven C. Cavender
**
******************************************************************************


	.xref	rat_int
	.xref	rat_err
	.xref	_moulox

	.xdef	_charvec

	.text

******************************************************************************
**
** rat_int -
**	Mouse Interrupt Service Routine
**	Entered with character on stack:
**			+---------------+
**		sp+4	|	| char	|
**			+---------------+
**		sp+2	|    return	|
**			+		+
**		sp+0	|    address	|
**			+---------------+
**
******************************************************************************

rat_int:
	*	A good character was received.  If it is a delta rather than a
	*	header then check the absolute value of the delta.  If it is
	*	greater than $3F then throw it away and look for a new header
	*	byte.  This damping of the mouse movement is necessary because
	*	older models of the Mouse Systems mouse have a bug that cause
	*	them to send out impossibly large deltas, especially when one
	*	tries to perform rapid mouse movement.

	move.b	5(sp),d1		* pick up byte from stack
	move.b	d1,d0			* get the byte
	andi.b	#$F8,d0			* mask off the button bits
	cmpi.b	#$80,d0			* is it a header byte?
	beq.b	rat4			* yes

	move.b	d1,d0			* get the byte again
	bge.b	rat3			* positive delta

	neg.b	d0			* negative delta - change its sign
rat3:
	cmpi.b	#$40,d0			* is the delta too large?
	bge.w	rat_err			* yes - mouse freaked out, bail out

*
*	We received a good header or delta so call the appropriate code to
*	handle it.
*
rat4:
	lea.l	mstate,a0		* get address of mouse state variable
	move.w	(a0),d0 		* get mouse state
	addq.w	#1,(a0) 		* increment mouse state
	asl.w	#2,d0			* convert to longword index
	movea.l	state_tbl(pc,d0.w),a0	* get address of state handler
	jmp	(a0)			* jump to code for mouse state

*
*	Jump Table for Mouse Interrupts
*
state_tbl:
	dc.l	state0			* state 0
	dc.l	state1			* state 1
	dc.l	state2			* state 2
	dc.l	state3			* state 3
	dc.l	state4			* state 4

*
*	Mouse State 0 - Check for Header Byte
*
state0:
	move.b	d1,d0			* get copy of byte
	andi.b	#$F8,d0			* mask off button bits
	cmpi.b	#$80,d0			* header byte?
	bne.b	rat_err			* nope - bail out

	not.b	d1			* invert state of button bits
	andi.w	#$07,d1			* isolate button bits
	move.b	xbut_tbl(pc,d1.w),ms_buffer	* xlate the button bits
	clr.b	delta_x 		* clear x delta
	clr.b	delta_y 		* clear y delta
*	move.l	#ms_buffer,-(sp)	* set up pointer to to mouse buffer
*	move.l	#1,-(sp)		* and 'packet received' flag
*	movea.l	_charvec+$10,a0		* get address of user interrupt
*	jsr	(a0)
*	addq.l	#8,sp			* clean up stack
	rts				* done

xbut_tbl:
	dc.b	%00000000		* no buttons depressed
	dc.b	%00000100		* right button depressed
	dc.b	%00000010		* middle button depressed
	dc.b	%00000110		* right, middle buttons depressed
	dc.b	%00000001		* left button depressed
	dc.b	%00000101		* right, left buttons depressed
	dc.b	%00000011		* middle, left buttons depressed
	dc.b	%00000111		* all buttons depressed

*
*	Mouse State 1 - Save First Delta in X
*
state1:
	move.b	d1,delta_x		* save the first x delta
	rts				* done

*
*	Mouse State 2 - Save First Delta in Y
*
state2:
	move.b	d1,delta_y		* save the first y delta
	rts				* done

*
*	Mouse State 3 - Save Second Delta in X
*
state3:
	add.b	d1,delta_x		* add second x delta to first
	rts				* done

*
*	Mouse State 4 - Save Second Delta in Y and Call Mouse Interrupt
*	Service Routine
*
state4:
	lea.l	delta_y,a0		* get address of DELTA Y variable
	add.b	d1,(a0) 		* add second y delta to first
	neg.b	(a0)			* must negate the y delta
	move.l	#ms_buffer,-(sp)	* push pointer to mouse buffer
	move.l	#1,-(sp)		* and 'packet received' flag
	movea.l	_charvec+$10,a0		* get address of user handler
	jsr	(a0)
	addq.l	#8,sp			* clean up stack
*	fall through to clear mstate	* get ready for next sequence


******************************************************************************
**
** rat_err -
**	Mouse error ISR
**
******************************************************************************

rat_err:
	clr.w	mstate			* abort sequence
	rts

******************************************************************************
**
** _moulox -
**	Default mouse interrupt handler
**
******************************************************************************

_moulox:
	rts

	.data

mstate:
	.dc.w	0

ms_buffer:
	.dc.b	0
delta_x:
	.dc.b	0
delta_y:
	.dc.b	0

	.end
