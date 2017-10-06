;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire font face name and index.
;*  09/01/91 v1.7
;*	   Fixed vqt_name per M. Jaegermann's suggestions.  The length
;*	   of the returned ADE string from contrl[4] is now used to
;*	   build the return ascii string, since ADE strings are counted,
;*	   not nullterm'd.  Also, made sure there was room for 33 chars
;*	   of output in the intout array, due to the proposed fsmgdos
;*	   change which adds an extra byte of return info to the string.
;*------------------------------------------------------------------------

_vqt_name::
	.cargs	#8,.handle.w,.element.w,.namestr.l
	link	a6,#-68		;* Allocate intout[34].

	VContrl	#130,,,#1

	subq.l	#4,sp		;* -> ptsout
	pea	-68(a6)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.element(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2
	lea	20(sp),sp 	;* clean off vdipb groodah.

	lea	-68(a6),a0	;* Pointer to intout.
	move.l	.namestr(a6),a1	;* Pointer to caller's string.
	move.w	(a0)+,d0		;* Return status from intout[0].
	move.w	8(sp),d2		;* load contrl[4]: outstr length.
	subq.w	#1,d2		;* account for intout[0] done already.
.strloop:
	move.w	(a0)+,d1		;* Return normal string from
	move.b	d1,(a1)+		;* intout[1-34].  Copy low byte of
	subq.w	#1,d2		;* decrement string count.
	bne.s	.strloop		;* each word to string byte.
	clr.b	(a1)		;* force nullterm onto string.

	unlk	a6
	rts

	end
