;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set user-defined fill pattern.
;*------------------------------------------------------------------------

_vsf_udpat::
	  .cargs	  #8,.handle.w,.ppat.l,.planes.w
	  link	  a6,#0

	  move.w	  .planes(a6),d0	;* Length of intin array is number
	  lsl.w	   #4,d0		;* of planes * 16.

	  VContrl   #112,,,d0

	  lea	  -12(sp),sp	;* -> ptsout, intout, ptsin
	  move.l	  .ppat(a6),-(sp)	;* -> intin
	  pea	  16(sp)		;* -> contrl

	  jmp	  vdicall

	end
