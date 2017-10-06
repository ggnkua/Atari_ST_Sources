;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire text extent.
;*------------------------------------------------------------------------

_vqt_extent::
	.cargs	#8,.handle.w,.string.l,.extent.l
	link	a6,#0

	move.l	.string(a6),a0	;* Get pointer to string.
	moveq.l	#0,d0		;* Zero out string length counter.
.strcnt:				;* Count up length of string...
	tst.b	(a0)+		;* Found end yet?
	beq.s	.strend		;* Yep, go integerize it.
	addq.w	#1,d0		;* Nope, add 1 to counter,
	bra.s	.strcnt		;* and keep looking.
.strend:
	move.w	d0,d1		;* Prime loop counter.
	moveq.l	#0,d2		;* Nice clean register.
.strcpy:				;* Copy the string to the stack,
	move.b	-(a0),d2		;* with each string byte in the
	move.w	d2,-(sp)		;* low byte of each stack word,
	dbra	d1,.strcpy	;* which is how VDI likes to see it.

	move.l	sp,a0		;* Save pointer to stacked string.

	VContrl	#116,,,d0

	move.l	.extent(a6),-(sp)	;* -> ptsout
	subq.l	#8,sp		;* -> intout, ptsin
	move.l	a0,-(sp)		;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
