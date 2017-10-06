;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Set character height, absolute mode.
;*------------------------------------------------------------------------

_vst_height::
	  .cargs	  #8,.handle.w,.height.w,.charw.l,.charh.l,.cellw.l,.cellh.l
	  link	  a6,#-8		;* Allocate ptsout[4].

	  move.w	  .height(a6),-(sp) ;* ptsin[1] = height.
	  clr.w	   -(sp)		;* ptsin[0] = 0.
	  move.l	  sp,a0		;* Save a pointer to ptsin.

	  VContrl   #12,,#1

	  pea	  -8(a6)		;* -> ptsout
	  subq.l	  #4,sp		;* -> intout
	  move.l	  a0,-(sp)	;* -> ptsin
	  subq.l	  #4,sp		;* -> intin
	  pea	  16(sp)		;* -> contrl

	  moveq.l   #$73,d0
	  move.l	  sp,d1
	  trap	  #2

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