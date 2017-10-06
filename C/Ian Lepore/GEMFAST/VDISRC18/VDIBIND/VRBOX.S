;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*------------------------------------------------------------------------
;* Rounded and filled rounded rectangle.
;*------------------------------------------------------------------------

_v_rbox::
	.cargs	#4,.handle.w,.pxy.l
	moveq.l	#11,d0
	moveq.l	#8,d1
	moveq.l	#2,d2
	move.l	.pxy(sp),a0
	jmp	vout_pxy

_v_rfbox::
	.cargs	#4,.handle.w,.pxy.l
	moveq.l	#11,d0
	moveq.l	#9,d1
	moveq.l	#2,d2
	move.l	.pxy(sp),a0
	jmp	vout_pxy

	end
