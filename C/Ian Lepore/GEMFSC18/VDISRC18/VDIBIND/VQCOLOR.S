;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire color representation.
;*------------------------------------------------------------------------

_vq_color::
	.cargs	#8,.handle.w,.color.w,.setflag.w,.rgb.l
	link	a6,#-8		;* Allocate intout[4].

	VContrl	#26,,,#2

	subq.l	#4,sp		;* -> ptsout
	pea	-8(a6)		;* -> intout
	subq.l	#4,sp		;* -> ptsin
	pea	.color(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.rgb(a6),a0	;* Return rgb array...
	move.l	-6(a6),(a0)+	;* rgb[0]=intout[1], rgb[1]=intout[2]
	move.w	-2(a6),(a0)	;* rgb[2]=intout[3]

	unlk	a6
	rts

	end
