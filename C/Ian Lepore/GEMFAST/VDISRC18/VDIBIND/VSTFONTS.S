;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*
;* 07/18/91 v1.6
;*      The DRI manual shows these two functions taking a parm 'select',
;*      but it also says that the 1 intin parm is 'reserved, s/b 0'.
;*      Further confusing matters, the original Alcyon bindings set the
;*      intin count to zero, not one.  And finally, users report that
;*      the vst_load_fonts() call dies with 3 bombs.  None of that makes
;*      any sense to me, but the intin count has been changed to zero,
;*      we'll see if that fixes the problem.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Load fonts.
;*------------------------------------------------------------------------

_vst_load_fonts::
	.cargs	#8,.handle.w
	link	a6,#-2

	VContrl	#119

	subq.l	#4,sp		;* -> ptsout
	pea	-2(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

;*------------------------------------------------------------------------
;* Unload fonts.
;*------------------------------------------------------------------------

_vst_unload_fonts::
	.cargs	#8,.handle.w
	link	a6,#-2

	VContrl	#120

	subq.l	#4,sp		;* -> ptsout
	pea	-2(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> control

	jmp	vdicall
	end
