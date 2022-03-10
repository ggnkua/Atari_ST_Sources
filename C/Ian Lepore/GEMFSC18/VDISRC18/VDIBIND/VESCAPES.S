;*========================================================================
;* VDIFAST Public Domain VDI bindings.
;*========================================================================

	.include	"vdimacro.s"

;*************************************************************************
;*
;* Escape functions 1.
;*  This random collection is all in one module because if you use any
;*  one of these functions the overhead of having them all linked in is
;*  only about 50 bytes.
;*
;*************************************************************************

;*------------------------------------------------------------------------
;*-----------------------------------------------------------------------
;* vesc_honly
;*  For VDI escape calls that use a handle only.
;*  Entry:  d0.w = VDI function number.
;*-----------------------------------------------------------------------
;*------------------------------------------------------------------------

vesc_honly:
	.cargs	#8,.handle.w
	link	a6,#-2

	VContrl	#5,d0

	subq.l	#4,sp		;* -> ptsout
	pea	-2(a6)		;* -> intout (most don't use this)
	subq.l	#8,sp		;* -> ptsin, intin
	pea	16(sp)		;* -> contrl

	jmp	vdicall

;*------------------------------------------------------------------------
;* Escape functions using just the vdi handle...
;*------------------------------------------------------------------------

_v_exit_cur::			;* Exit alpha/cursor mode.
	moveq.l	#2,d0
	bra	vesc_honly
_v_enter_cur::			;* Enter alpha/cursor mode.
	moveq.l	#3,d0
	bra	vesc_honly
_v_curup::			;* Alpha cursor up.
	moveq.l	#4,d0
	bra	vesc_honly
_v_curdown::			;* Alpha cursor down.
	moveq.l	#5,d0
	bra	vesc_honly
_v_curright::			;* Alpha cursor right.
	moveq.l	#6,d0
	bra	vesc_honly
_v_curleft::			;* Alpha cursor left.
	moveq.l	#7,d0
	bra	vesc_honly
_v_curhome::			;* Alpha cursor home.
	moveq.l	#8,d0
	bra	vesc_honly
_v_eeos:: 			;* Erase to end of screen (alpha mode).
	moveq.l	#9,d0
	bra	vesc_honly
_v_eeol:: 			;* Erase to end of line (alpha mode).
	moveq.l	#10,d0
	bra	vesc_honly
_v_rvon:: 			;* Alpha reverse video on.
	moveq.l	#13,d0
	bra	vesc_honly
_v_rvoff::			;* Alpha reverse video off.
	moveq.l	#14,d0
	bra	vesc_honly
_vq_tabstatus::			;* Inquire tablet status.
	moveq.l	#16,d0
	bra	vesc_honly
_v_hardcopy::			;* Output hardcopy.
	moveq.l	#17,d0
	bra	vesc_honly
_v_rmcur::			;* Remove last graphic cursor.
	moveq.l	#19,d0
	bra	vesc_honly
_v_form_adv::			;* Form advance.
	moveq.l	#20,d0
	bra	vesc_honly
_v_clear_disp_list::		;* Clear display list.
	moveq.l	#22,d0
	bra	vesc_honly

;*	end of code

