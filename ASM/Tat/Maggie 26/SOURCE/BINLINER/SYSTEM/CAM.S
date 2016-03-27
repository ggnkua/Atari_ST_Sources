; CAM.S
;
; Spline-based camera movement
; 27/2/98
; Steven Tattersall
; tattersall@zetnet.co.uk
;
; Updated to allow multiple camera files, declared using the "camera"
; macro
;


; cam_set and cam_calc are provided for backwards compatibility
; use "cam_set_general" and "cam_calc_general" now
;

		opt	inconce

		include	system\spline.s

;-------------------------------------------------------------------------
camera_object	MACRO
		ds.b	cam_size
		ENDM

;-------------------------------------------------------------------------
			rsreset
cam_address		rs.l	1
cam_interval		rs.w	1
cam_interval_pos	rs.w	1
cam_restart		rs.l	1
cam_geometry_matrix:	rs.w	0
cam_start_x		rs.w	1
cam_end_x		rs.w	1
cam_start_tan_x		rs.w	1
cam_end_tan_x		rs.w	1
cam_start_y		rs.w	1
cam_end_y		rs.w	1
cam_start_tan_y		rs.w	1
cam_end_tan_y		rs.w	1
cam_start_z		rs.w	1
cam_end_z		rs.w	1
cam_start_tan_z		rs.w	1
cam_end_tan_z		rs.w	1
cam_start_anga		rs.w	1
cam_end_anga		rs.w	1
cam_start_tan_anga	rs.w	1
cam_end_tan_anga	rs.w	1
cam_start_angb		rs.w	1
cam_end_angb		rs.w	1
cam_start_tan_angb	rs.w	1
cam_end_tan_angb	rs.w	1
cam_start_angc		rs.w	1
cam_end_angc		rs.w	1
cam_start_tan_angc	rs.w	1
cam_end_tan_angc	rs.w	1
cam_start_dist		rs.w	1
cam_end_dist		rs.w	1
cam_start_tan_dist	rs.w	1
cam_end_tan_dist	rs.w	1
cam_output_matrix	rs.w	28
cam_output_values	rs.w	7
cam_old_flag		rs.w	1

cam_size		rs.w	1


		section	text
;-------------------------------------------------------------------------
cam_set:
		lea	cam_general,a6
		move.l	a0,cam_address(a6)
		move.l	a1,cam_restart(a6)
		move.w	#1,cam_old_flag
		;bra.s	cam_set_general

cam_set_general:
		move.w	(a0)+,cam_start_x(a6)
		move.w	(a0)+,cam_start_y(a6)
		move.w	(a0)+,cam_start_z(a6)
		move.w	(a0)+,cam_start_anga(a6)
		move.w	(a0)+,cam_start_angb(a6)
		move.w	(a0)+,cam_start_angc(a6)
		move.w	(a0)+,cam_start_dist(a6)

		move.w	(a0)+,cam_start_tan_x(a6)
		move.w	(a0)+,cam_start_tan_y(a6)
		move.w	(a0)+,cam_start_tan_z(a6)
		move.w	(a0)+,cam_start_tan_anga(a6)
		move.w	(a0)+,cam_start_tan_angb(a6)
		move.w	(a0)+,cam_start_tan_angc(a6)
		move.w	(a0)+,cam_start_tan_dist(a6)
		bsr	cam_get_ends
		rts

cam_calc:
		lea	cam_general,a6
		;bra	cam_calc_general

cam_calc_general:
		move.l	#$7fff,d0
		divu	cam_interval(a6),d0
		muls.w	cam_interval_pos(a6),d0

		lea	cam_output_matrix(a6),a0
		lea	cam_output_values(a6),a1
		move.w	#7,d1			;6 values
		jsr	spl_calc_spline_value

		addq.w	#1,cam_interval_pos(a6)
		move.w	cam_interval_pos(a6),d0
		cmp.w	cam_interval(a6),d0
		bne.s	.notnext
		bsr	cam_get_next
.notnext:
		rts



cam_get_next:
		move.l	cam_address(a6),a0

; Copy current end values to current start values:
		move.w	cam_end_x(a6),cam_start_x(a6)
		move.w	cam_end_y(a6),cam_start_y(a6)
		move.w	cam_end_z(a6),cam_start_z(a6)
		move.w	cam_end_anga(a6),cam_start_anga(a6)
		move.w	cam_end_angb(a6),cam_start_angb(a6)
		move.w	cam_end_angc(a6),cam_start_angc(a6)
		move.w	cam_end_dist(a6),cam_start_dist(a6)
		move.w	cam_end_tan_x(a6),cam_start_tan_x(a6)
		move.w	cam_end_tan_y(a6),cam_start_tan_y(a6)
		move.w	cam_end_tan_z(a6),cam_start_tan_z(a6)
		move.w	cam_end_tan_anga(a6),cam_start_tan_anga(a6)
		move.w	cam_end_tan_angb(a6),cam_start_tan_angb(a6)
		move.w	cam_end_tan_angc(a6),cam_start_tan_angc(a6)
		move.w	cam_end_tan_dist(a6),cam_start_tan_dist(a6)

; Get next values and put in our temporary matrix:

cam_get_ends:
		move.w	(a0)+,cam_interval(a6)
		bmi.s	cam_nomore
cam_fetch:
		clr.w	cam_interval_pos(a6)
		move.w	(a0)+,cam_end_x(a6)
		move.w	(a0)+,cam_end_y(a6)
		move.w	(a0)+,cam_end_z(a6)
		move.w	(a0)+,cam_end_anga(a6)
		move.w	(a0)+,cam_end_angb(a6)
		move.w	(a0)+,cam_end_angc(a6)
		move.w	(a0)+,cam_end_dist(a6)
		move.w	(a0)+,cam_end_tan_x(a6)
		move.w	(a0)+,cam_end_tan_y(a6)
		move.w	(a0)+,cam_end_tan_z(a6)
		move.w	(a0)+,cam_end_tan_anga(a6)
		move.w	(a0)+,cam_end_tan_angb(a6)
		move.w	(a0)+,cam_end_tan_angc(a6)
		move.w	(a0)+,cam_end_tan_dist(a6)
		move.l	a0,cam_address(a6)

; Make the matrix:
		lea	cam_geometry_matrix(a6),a0
		lea	cam_output_matrix(a6),a1
		move.w	#7,d0				;number of rows
		jsr	spl_init_matrix_hermite
		rts

cam_nomore:
		tst	cam_old_flag(a6)
		bne	.old
		;move.l	cam_address(a6),a0
		move.l	(a0)+,a0
		move.l	a0,cam_address(a6)
		bra	cam_get_ends

.old:		move.l	cam_restart(a6),a0
		move.l	a0,cam_address(a6)
		bra	cam_get_ends

;-------------------------------------------------------------------------

			section	bss
cam_general		camera_object

;-------------------------------------------------------------------------
			section	text

