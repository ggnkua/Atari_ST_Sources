;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Input string.
;*  09/01/91 - v1.7
;*	     Fixed vXX_string per M. Jaegermann's suggestions.  The ADE
;*	     strings returned by VDI are counted, not nullterm'd, so
;*	     now the loop that copies ADE to ASCII is controlled by the
;*	     contrl[4] (intout) count.
;*------------------------------------------------------------------------

_vsm_string::
_vrq_string::
	.cargs	#8,.handle.w,.maxlen.w,.echoflag.w,.echoxy.l,.string.l
	link	a6,#-4

	move.w	.maxlen(a6),d0	;* We have to allocate 'maxlen'
	bpl.s	.notneg		;* words of stack space to hold
	neg.w	d0		;* the ADE-type string that VDI
.notneg:				;* will return to us.  The maxlen
	add.w	d0,d0		;* value may be negative (flag for
	sub.w	d0,sp		;* VDI to return scancodes), so we
	move.l	sp,-4(a6) 	;* use the abs value in that case.

	VContrl  #31,,#1,#2

	subq.l	#4,sp		;* -> ptsout
	move.l	-4(a6),-(sp)	;* -> intout
	move.l	.echoxy(a6),-(sp)	;* -> ptsin
	pea	.maxlen(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2
	lea	20(sp),sp 	;* pop vdipb gunga off of stack.

	move.l	-4(a6),a0 	;* Pointer to ADE string on stack.
	move.l	.string(a6),a1	;* Pointer to caller's string area.
	move.w	8(sp),d0		;* contrl now at top of stack, get
	move.w	d0,d2		;* contrl[4], the string length.
	beq.s	.all_done 	;* take early-out if empty string.
.copyloop:
	move.w	(a0)+,d1		;* Get a word from the ADE string,
	move.b	d1,(a1)+		;* store the low byte in the caller's
	subq.w	#1,d2		;* decrement string byte count,
	bne.s	.copyloop 	;* loop till all bytes copied.
.all_done:
	clr.b	(a1)		;* force nullterm byte onto string.

	unlk	a6		;* Dealloc all stack space.
	rts
	end
