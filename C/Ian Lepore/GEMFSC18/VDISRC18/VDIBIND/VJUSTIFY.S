;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Justified text.
;*------------------------------------------------------------------------

_v_justified::

	.cargs	#8,.handle.w,.x.w,.y.w,.p_str.l,.length.w,.wspace.w,.cspace.w
	link	a6,#0

	move.l	.p_str(a6),a0	;* Get the string pointer.
	jsr	vstr_stack	;* Go integerize and stack string.

	move.w	.cspace(a6),-(sp)	;* The character and word spacing
	move.w	.wspace(a6),-(sp)	;* flags are the 1st 2 intin words.
	addq.w	#2,d0		;* Count the 2 extra words in length.
	move.l	sp,a0		;* Save pointer to intin.

	clr.w	-(sp)		;* Build the ptsin array on the stack,
	move.w	.length(a6),-(sp)	;* because it has an extra null word
	move.l	.x(a6),-(sp)	;* after the x/y/length.
	move.l	sp,a1		;* Save pointer to ptsin.

	VContrl	#11,#10,#2,d0

	subq.l	#8,sp		;* -> ptsout, intout
	move.l	a1,-(sp)		;* -> ptsin
	move.l	a0,-(sp)		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
