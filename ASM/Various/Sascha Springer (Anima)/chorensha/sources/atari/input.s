
	xdef ikbd_handler

	xdef program_exit_request

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

; IKBD/MIDI interrupt routine (works only for the IKBD standard mode configuration).

ikbd_handler:
	btst	#0,$fffffc00.w
	bne		.process_ikbd_data

	rte

.process_ikbd_data:
	move.l	d0,-(sp)

	move.b	$fffffc02.w,d0

	move.l	.processing_routine,-(sp)

	rts

.process_key_code:
	cmp.b	#$f6,d0 ; Key?
	bhs		.check_joystick

	cmp.b	#$01+$80,d0 ; "ESC" released?
	bne		.no_exit_request

	move	#-1,program_exit_request

	move.l	(sp)+,d0

	rte

.no_exit_request:
	; Joystick emulation.

	cmp.b	#$2a,d0 ; "Left SHIFT" pressed?
	bne		.skip_left_shift1

	bclr	#6,iocs_joystick_data+3 ; Joystick button #1 down.

	move.l	(sp)+,d0

	rte

.skip_left_shift1:
	cmp.b	#$2a+$80,d0 ; "Left SHIFT" released?
	bne		.skip_left_shift2

	bset	#6,iocs_joystick_data+3 ; Joystick button #1 up.

	move.l	(sp)+,d0

	rte

.skip_left_shift2:
	cmp.b	#$1d,d0 ; "CONTROL" pressed?
	bne		.skip_control1

	bclr	#5,iocs_joystick_data+3 ; Joystick button #2 down.

	move.l	(sp)+,d0

	rte

.skip_control1:
	cmp.b	#$1d+$80,d0 ; "CONTROL" released?
	bne		.skip_control2

	bset	#5,iocs_joystick_data+3 ; Joystick button #2 up.

	move.l	(sp)+,d0

	rte

.skip_control2:
	cmp.b	#$4b,d0 ; "Left arrow" pressed?
	bne		.skip_left_arrow1

	bclr	#2,iocs_joystick_data+3 ; Joystick left.
	bset	#3,iocs_joystick_data+3 ; Not joystick right.

	move.l	(sp)+,d0

	rte

.skip_left_arrow1:
	cmp.b	#$4b+$80,d0 ; "Left arrow" released?
	bne		.skip_left_arrow2

	bset	#2,iocs_joystick_data+3 ; Not joystick left.

	move.l	(sp)+,d0

	rte

.skip_left_arrow2:
	cmp.b	#$4d,d0 ; "Right arrow" pressed?
	bne		.skip_right_arrow1

	bclr	#3,iocs_joystick_data+3 ; Joystick right.
	bset	#2,iocs_joystick_data+3 ; Not joystick left.

	move.l	(sp)+,d0

	rte

.skip_right_arrow1:
	cmp.b	#$4d+$80,d0 ; "Right arrow" released?
	bne		.skip_right_arrow2

	bset	#3,iocs_joystick_data+3 ; Not joystick right.

	move.l	(sp)+,d0

	rte

.skip_right_arrow2:
	cmp.b	#$48,d0 ; "Up arrow" pressed?
	bne		.skip_up_arrow1

	bclr	#0,iocs_joystick_data+3 ; Joystick up.
	bset	#1,iocs_joystick_data+3 ; Not joystick down.

	move.l	(sp)+,d0

	rte

.skip_up_arrow1:
	cmp.b	#$48+$80,d0 ; "Up arrow" released?
	bne		.skip_up_arrow2

	bset	#0,iocs_joystick_data+3 ; Not joystick up.

	move.l	(sp)+,d0

	rte

.skip_up_arrow2:
	cmp.b	#$50,d0 ; "Down arrow" pressed?
	bne		.skip_down_arrow1

	bclr	#1,iocs_joystick_data+3 ; Joystick down.
	bset	#0,iocs_joystick_data+3 ; Not joystick up.

	move.l	(sp)+,d0

	rte

.skip_down_arrow1:
	cmp.b	#$50+$80,d0 ; "Down arrow" released?
	bne		.skip_down_arrow2

	bset	#1,iocs_joystick_data+3 ; Not joystick down.

	move.l	(sp)+,d0

	rte

.skip_down_arrow2:
	cmp.b	#$39,d0 ; "SPACE" pressed?
	bne		.skip_space1

	move.l	(sp)+,d0

	rte

.skip_space1:
	cmp.b	#$39+$80,d0 ; "SPACE" released?
	bne		.skip_space2

	move.l	(sp)+,d0

	rte

.skip_space2:
	move.l	(sp)+,d0

	rte

.check_joystick:
	cmp.b	#$fe,d0 ; Joystick?
	blo		.check_mouse

	; d0.b = %1111111n (n = joystick number).

	move.l	#.process_joystick_data,.processing_routine

	move.l	(sp)+,d0

	rte

.process_joystick_data:
	; d0.b = %t000dddd (t = trigger, d = directions).

	and.b	#$f,d0
	not.b	d0
	move.b	d0,iocs_joystick_data+3
	
	move.l	#.process_key_code,.processing_routine
	
	move.l	(sp)+,d0

	rte

.check_mouse:
	cmp.b	#$f8,d0 ; Mouse?
	blo		.unsupported_code

	; d0.b = %111110lr (l = left button, r = right button).

	bset	#5,iocs_joystick_data+3 ; Joystick button #2 up.

	btst	#0,d0
	beq		.not_button_down

	bclr	#5,iocs_joystick_data+3 ; Joystick button #2 down.

.not_button_down:
	move.l	#.process_mouse_delta_x,.processing_routine

	move.l	(sp)+,d0

	rte

.process_mouse_delta_x:
	; d0.b = x.

	move.l	#.process_mouse_delta_y,.processing_routine

	move.l	(sp)+,d0

	rte

.process_mouse_delta_y:
	; d0.b = y.

	move.l	#.process_key_code,.processing_routine

	move.l	(sp)+,d0

	rte

.unsupported_code:
	illegal

.processing_routine:
	dc.l	.process_key_code

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

program_exit_request:
	ds		1

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------

