;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set color representation (set rgb values).
;*------------------------------------------------------------------------

_vs_color::
	  .cargs	  #8,.handle.w,.index.w,.rgb.l
	  link	  a6,#0

	  move.l	  .rgb(a6),a0	;* Since the rgb values and the
	  move.w	  4(a0),-(sp)	;* index are supposed to be in the
	  move.w	  2(a0),-(sp)	;* intin array, we have to copy the
	  move.w	  (a0),-(sp)	;* rgb from the user array to the
	  move.w	  .index(a6),-(sp)	;* stack, then put the index on the
	  move.l	  sp,a0		;* front.  Save a pointer to intin.

	  VContrl   #14,,,#4

	  lea	  -12(sp),sp	;* -> ptsout, intout, ptsin
	  move.l	  a0,-(sp)	;* -> intin
	  pea	  16(sp)		;* -> contrl

	  jmp	  vdicall

	end
