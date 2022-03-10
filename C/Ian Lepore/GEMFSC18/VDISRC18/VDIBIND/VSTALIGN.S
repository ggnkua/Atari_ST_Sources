;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set text alignment.
;*------------------------------------------------------------------------

_vst_alignment::
	  .cargs	  #8,.handle.w,.hin.w,.vin.w,.hout.l,.vout.l
	  link	  a6,#-4		;* Allocate intout[2].

	  VContrl   #39,,,#2

	  subq.l	  #4,sp	         ;* -> ptsout
	  pea	  -4(a6)	         ;* -> intout
	  subq.l	  #4,sp	         ;* -> ptsin
	  pea	  .hin(a6)         ;* -> intin
	  pea	  16(sp)	         ;* -> contrl

	  moveq.l   #$73,d0
	  move.l	  sp,d1
	  trap	  #2

	  move.l	  .hout(a6),a0	;* Return horizontal
	  move.w	  -4(a6),(a0)	;* from intout[0].
	  move.l	  .vout(a6),a0	;* Return vertical
	  move.w	  -2(a6),(a0)	;* from intout[1].

	  unlk	  a6
	  rts
	end
