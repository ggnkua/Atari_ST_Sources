.globl _mouse_button_handler
.globl _mouse_coords_handler
.globl _timer_handler

_mouse_button_handler:
	tstw	_button_state
	bne	mbh_bs

	movew	d0,_button_state
	movew	_mx,_rmx
	movew	_my,_rmy

mbh_bs:
	movel	a5,a7@-
	movel	_old_mouse_button_vector,a5
	jsr	a5@
	movel	a7@+,a5
	tstw	d0
	beq	mbh_nots

	addqw	#1,_c_count

mbh_nots:
	rts


_mouse_coords_handler:
	movew	d0,_mx
	movew	d1,_my

	movel	a5,a7@-
	movel	_old_mouse_coords_vector,a5
	jsr	a5@
	movel	a7@+,a5

	rts

_timer_handler:
	addqw	#1,_vdi_timer
	movel	a5,a7@-
	movel	_old_timer_vector,a5
	jsr	a5@
	movel	a7@+,a5

	rts
