;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*	09/06/89 v1.3:
;*				Fixed DRI bug in vsl_ends. This function returns 2 words,
;*				but the DRI docs don't mention that.  The binding was
;*				fixed to provide a pointer to a stack-allocated area to
;*				hold the 2 words, but the words are not returned to the
;*				caller since the DRI docs don't allow for that.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set polyline end styles.
;*------------------------------------------------------------------------

_vsl_ends::
		  .cargs	#8,.handle.w,.begstyle.w,.endstyle.w
		  link		a6,#-4

		  VContrl	#108,,,#2

		  subq.l	#4,sp				;* -> ptsout
		  pea		-4(a6)				;* -> intout
		  subq.l	#4,sp				;* -> ptsin
		  pea		.begstyle(a6)		;* -> intin
		  pea		16(sp)				;* -> contrl

		  jmp		vdicall

		  end
