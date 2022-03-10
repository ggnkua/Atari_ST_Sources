;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set polymarker height.
;*------------------------------------------------------------------------

_vsm_height::
		  .cargs	#8,.handle.w,.height.w
		  link		a6,#-4				;* Allocate ptsout[2].

		  move.w	.height(a6),-(sp)	;* ptsin[1] = height.
		  clr.w 	-(sp)				;* ptsin[0] = 0.
		  move.l	sp,a0

		  VContrl	#19,,#1

		  pea		-4(a6)				;* -> ptsout
		  subq.l	#4,sp				;* -> intout
		  move.l	a0,-(sp)			;* -> ptsin
		  subq.l	#4,sp				;* -> intin
		  pea		16(sp)				;* -> contrl

		  jmp		vdicall 			;* Do it, return ptsout[1].

		  end
