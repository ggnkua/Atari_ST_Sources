; CAM.S
;
; Spline-based camera movement
; 27/2/98
; Steven Tattersall
; tattersall@zetnet.co.uk
;
;
; An example of using the code in SPLINE.S
; One camera position consists of 7 values:

; - the x,y,z point in the world
; - the 3 rotation angles about this point
; - the distance of the camera from the x,y,z point

; cam_set initialises a table of camera positions, plus
; a "speed" of movement between each point
;
; cam_calc works out the next value of the camera position
; when called continually
; the 7 current values are stored in "cam_output_values"
; each time.



		section	text
cam_set:
		move.w	(a0)+,cam_start_x
		move.w	(a0)+,cam_start_y
		move.w	(a0)+,cam_start_z
		move.w	(a0)+,cam_start_anga
		move.w	(a0)+,cam_start_angb
		move.w	(a0)+,cam_start_angc
		move.w	(a0)+,cam_start_dist

		move.w	(a0)+,cam_start_tan_x
		move.w	(a0)+,cam_start_tan_y
		move.w	(a0)+,cam_start_tan_z
		move.w	(a0)+,cam_start_tan_anga
		move.w	(a0)+,cam_start_tan_angb
		move.w	(a0)+,cam_start_tan_angc
		move.w	(a0)+,cam_start_tan_dist

		move.l	a0,cam_address
		move.l	a1,cam_restart

		bsr	cam_get_ends
		;bsr	cam_calc
		rts

cam_calc:
		move.l	#$7fff,d0
		divu	cam_interval,d0
		muls.w	cam_interval_pos,d0

		lea	cam_output_matrix,a0
		lea	cam_output_values,a1
		move.w	#7,d1			;6 values
		jsr	spl_calc_spline_value

		addq.w	#1,cam_interval_pos
		move.w	cam_interval_pos,d0
		cmp.w	cam_interval,d0
		bne.s	.notnext
		bsr	cam_get_next
.notnext:
		rts



cam_get_next:
		move.l	cam_address,a0

; Copy current end values to current start values:
		move.w	cam_end_x,cam_start_x
		move.w	cam_end_y,cam_start_y
		move.w	cam_end_z,cam_start_z
		move.w	cam_end_anga,cam_start_anga
		move.w	cam_end_angb,cam_start_angb
		move.w	cam_end_angc,cam_start_angc
		move.w	cam_end_dist,cam_start_dist


		move.w	cam_end_tan_x,cam_start_tan_x
		move.w	cam_end_tan_y,cam_start_tan_y
		move.w	cam_end_tan_z,cam_start_tan_z
		move.w	cam_end_tan_anga,cam_start_tan_anga
		move.w	cam_end_tan_angb,cam_start_tan_angb
		move.w	cam_end_tan_angc,cam_start_tan_angc
		move.w	cam_end_tan_dist,cam_start_tan_dist

; Get next values and put in our temporary matrix:

cam_get_ends:
		move.w	(a0)+,cam_interval
		bmi.s	cam_nomore
cam_fetch:
		clr.w	cam_interval_pos

		move.w	(a0)+,cam_end_x
		move.w	(a0)+,cam_end_y
		move.w	(a0)+,cam_end_z
		move.w	(a0)+,cam_end_anga
		move.w	(a0)+,cam_end_angb
		move.w	(a0)+,cam_end_angc
		move.w	(a0)+,cam_end_dist

		move.w	(a0)+,cam_end_tan_x
		move.w	(a0)+,cam_end_tan_y
		move.w	(a0)+,cam_end_tan_z
		move.w	(a0)+,cam_end_tan_anga
		move.w	(a0)+,cam_end_tan_angb
		move.w	(a0)+,cam_end_tan_angc
		move.w	(a0)+,cam_end_tan_dist

		move.l	a0,cam_address

; Make the matrix:
		lea	cam_geometry_matrix,a0
		lea	cam_output_matrix,a1
		move.w	#7,d0				;number of rows
		jsr	spl_init_matrix_hermite
		rts

cam_nomore:
		move.l	cam_restart,a0
		move.l	a0,cam_address
		bra	cam_get_ends

		include	spline.s


;-------------------------------------------------------------------------

			section	bss
cam_address		ds.l	1
cam_interval		ds.w	1
cam_interval_pos	ds.w	1

cam_restart		ds.l	1

cam_geometry_matrix:	
cam_start_x		ds.w	1
cam_end_x		ds.w	1
cam_start_tan_x		ds.w	1
cam_end_tan_x		ds.w	1

cam_start_y		ds.w	1
cam_end_y		ds.w	1
cam_start_tan_y		ds.w	1
cam_end_tan_y		ds.w	1

cam_start_z		ds.w	1
cam_end_z		ds.w	1
cam_start_tan_z		ds.w	1
cam_end_tan_z		ds.w	1

cam_start_anga		ds.w	1
cam_end_anga		ds.w	1
cam_start_tan_anga	ds.w	1
cam_end_tan_anga	ds.w	1

cam_start_angb		ds.w	1
cam_end_angb		ds.w	1
cam_start_tan_angb	ds.w	1
cam_end_tan_angb	ds.w	1

cam_start_angc		ds.w	1
cam_end_angc		ds.w	1
cam_start_tan_angc	ds.w	1
cam_end_tan_angc	ds.w	1

cam_start_dist		ds.w	1
cam_end_dist		ds.w	1
cam_start_tan_dist	ds.w	1
cam_end_tan_dist	ds.w	1

cam_output_matrix	ds.w	28
cam_output_values	ds.w	7

			section	text

