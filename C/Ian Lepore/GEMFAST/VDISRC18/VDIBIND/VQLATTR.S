;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire polyline attributes.
;*------------------------------------------------------------------------

_vql_attributes::
	.cargs	#8,.handle.w,.attrib.l
	link	a6,#-14		;* Allocate intout[5], ptsout[2].

	VContrl	#35

	pea	-14(a6)		;* -> ptsout
	pea	-10(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.attrib(a6),a0	;* Return values in attrib array...
	move.l	-10(a6),(a0)+	;* attr[0]=intout[0],attr[1]=intout[1]
	move.w	-6(a6),(a0)+	;* attr[2]=intout[2]
	move.w	-14(a6),(a0)	;* attr[3]=ptsout[0]

	unlk	a6
	rts

	end
