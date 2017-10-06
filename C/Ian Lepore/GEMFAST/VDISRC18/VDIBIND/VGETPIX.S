;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Get pixel.
;*------------------------------------------------------------------------

_v_get_pixel::
	.cargs	#8,.handle.w,.x.w,.y.w,.pel.l,.index.l
	link	a6,#-4		;* Allocate intout[2].

	VContrl	#105,,#1

	subq.l	#4,sp		;* -> ptsout
	pea	-4(a6)		;* -> intout
	pea	.x(a6)		;* -> ptsin
	subq.l	#4,sp		;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.pel(a6),a0	;* Return pixel value
	move.w	-4(a6),(a0)	;* from intout[0].
	move.l	.index(a6),a0	;* Return index value
	move.w	-2(a6),(a0)	;* from intout[1].

	unlk	a6
	rts

	end
