;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Eliptical arc and pie.
;*------------------------------------------------------------------------

_v_ellarc::
	moveq.l	#6,d1
	bra.s	ellarcpie
_v_ellpie::
	moveq.l	#7,d1
ellarcpie:
	.cargs	#8,.handle.w,.x.w,.y.w,.xradius.w,.yradius.w,.begang.w,.endang.w
	link	a6,#0

	VContrl	#11,d1,#2,#2

	subq.l	#8,sp		;* -> ptsout, intout
	pea	.x(a6)		;* -> ptsin
	pea	.begang(a6)	;* -> intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

	end
