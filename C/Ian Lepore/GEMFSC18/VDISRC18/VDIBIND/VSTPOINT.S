;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set character height, points mode.
;*------------------------------------------------------------------------

_vst_point::

	  .cargs	  #8,.handle.w,.height.w,.charw.l,.charh.l,.cellw.l,.cellh.l
	  link	  a6,#-10 	 ;* Allocate ptsout[4], intout[1].

	  VContrl   #107,,,#1

	  pea	  -8(a6)	         ;* -> ptsout
	  pea	  -10(a6)          ;* -> intout
	  subq.l	  #4,sp	         ;* -> ptsin
	  pea	  .height(a6)      ;* -> intin
	  pea	  16(sp)	         ;* -> contrl

	  moveq.l   #$73,d0
	  move.l	  sp,d1
	  trap	  #2

	  move.w	  -10(a6),d0	;* Return pt size from intout[0]

	  lea	  -8(a6),a1	;* a1 -> ptsout[0] on stack.
	  move.l	  .charw(a6),a0	;* Return character width
	  move.w	  (a1)+,(a0)	;* from ptsout[0].
	  move.l	  .charh(a6),a0	;* Return character height
	  move.w	  (a1)+,(a0)	;* from ptsout[1].
	  move.l	  .cellw(a6),a0	;* Return cell width
	  move.w	  (a1)+,(a0)	;* from ptsout[2].
	  move.l	  .cellh(a6),a0	;* Return cell height
	  move.w	  (a1),(a0)	;* from ptsout[3].

	  unlk	  a6
	  rts

	end
