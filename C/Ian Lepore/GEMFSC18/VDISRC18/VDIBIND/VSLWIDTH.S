;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set polyline width.
;*------------------------------------------------------------------------

_vsl_width::
		  .cargs	#8,.handle.w,.width.w
		  link		a6,#-4				;* Allocate ptsout[2].

		  clr.w 	-(sp)				;* ptsin[1] = 0
		  move.w	.width(a6),-(sp)	;* ptsin[0] = width
		  move.l	sp,a0				;* Save a pointer to ptsin.

		  VContrl	#16,,#1

		  pea		-4(a6)				;* -> ptsout
		  subq.l	#4,sp				;* -> intout
		  move.l	a0,-(sp)			;* -> ptsin
		  subq.l	#4,sp				;* -> intin
		  pea		16(sp)				;* -> contrl

		  moveq.l	#$73,d0
		  move.l	sp,d1
		  trap		#2
		  move.w	-4(a6),d0			;* Return ptsout[0].
		  unlk		a6
		  rts

		  end
