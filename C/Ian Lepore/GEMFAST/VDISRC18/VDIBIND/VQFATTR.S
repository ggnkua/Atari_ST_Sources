;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Inquire fill area attributes.
;*------------------------------------------------------------------------

_vqf_attributes::
	.cargs	#8,.handle.w,.attrib.l
	link	a6,#-10		;* Allocate intout[5].

	VContrl	#36

	subq.l	#4,sp		;* -> ptsout
	pea	-10(a6)		;* -> intout
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	moveq.l	#$73,d0
	move.l	sp,d1
	trap	#2

	move.l	.attrib(a6),a0	;* Return values in attrib array
	lea	-10(a6),a1	;* from 1st 4 elements of intout.
	move.l	(a1)+,(a0)+	;* attr[0]=intout[0],attr[1]=intout[1]
	move.l	(a1)+,(a0)+	;* attr[2]=intout[2],attr[3]=intout[3]

	unlk	a6
	rts

	end
