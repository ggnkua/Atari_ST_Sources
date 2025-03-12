; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

camera_timer:	move.w	trajectory_current,d0
		movea.l	(trajectory_param_pointers.l,pc,d0.w*4),a0
		move.l	8(a0),d0			; tick counter
		move.l	12(a0),d1			; total ticks
		movea.l	16(a0),a1			; command sequencer
		
		cmp.l	d0,d1
		bne.b	.tick_ok
		rts
		
.tick_ok:	addq.l	#1,8(a0)			; tick++ (d0: old tick)
		
.command_loop:	move.l	(a1)+,d1			; starting tick
		bmi.b	.no_command			; no more commands
		cmp.l	d0,d1				; too little starting tick
		bgt.b	.no_command
		
		move.l	(a1)+,d2			; length in ticks
		movea.l	(a1)+,a0			; command
		
		subq.l	#1,d2				; tick--
		bmi.b	.command_loop			; check next command
		
		move.l	d2,-8(a1)			; save decreased length
		
		move.l	d0,-(sp)
		move.l	a1,-(sp)
		
		jsr	(a0)
		
		movea.l	(sp)+,a1
		move.l	(sp)+,d0
		
		bra.b	.command_loop
.no_command:	rts

; set new camera target to look at
; input: d0.w: x
;        d1.w: y
;        d2.w: z

camera_look_at:
		move.w	d0,cam_target_x
		move.w	d1,cam_target_y
		move.w	d2,cam_target_z
		rts

; calc new alpha and beta angles according to camera target we are looking at

camera_calc_angles:
		move.w	cam_target_x,d0
		sub.w	cam_pos_x,d0
		move.w	cam_target_y,d1
		sub.w	cam_pos_y,d1
		move.w	cam_target_z,d2
		sub.w	cam_pos_z,d2
		
		fmove.w	d0,fp0				; dx
		fmove.w	d1,fp1				; dy
		fmove.w	d2,fp2				; dz
		move.l	#$007fffff,d3
		
		fmove.x	fp0,fp3
		fmul.x	fp3,fp3				; dx^2
		fmove.x	fp1,fp4
		fmul.x	fp4,fp4				; dy^2
		fmove.x	fp2,fp5
		fmul.x	fp5,fp5				; dz^2
		
		fmove.x	fp3,fp6
		fadd.x	fp4,fp6
		fadd.x	fp5,fp6
		fsqrt.x	fp6				; sqrt(dx^2+dy^2+dz^2)
		
		fmove.x	fp3,fp7
		fadd.x	fp5,fp7
		fsqrt.x	fp7				; sqrt(dx^2+dz^2)
		
		fdiv.x	fp7,fp2				; sin(beta) = dz / sqrt(dx^2+dz^2)
		fneg.x	fp2				; 3d patch
		fscale.w	#23,fp2
		fintrz.x	fp2
		fmove.l	fp2,d0
		cmp.l	d3,d0
		ble.b	.no_fix1
		move.l	d3,d0
.no_fix1:	move.l	d0,cam_sin_beta

		fdiv.x	fp7,fp0				; cos(beta) = dx / sqrt(dx^2+dz^2)
		fscale.w	#23,fp0
		fintrz.x	fp0
		fmove.l	fp0,d0
		cmp.l	d3,d0
		ble.b	.no_fix2
		move.l	d3,d0
.no_fix2:	move.l	d0,cam_cos_beta

		fdiv.x	fp6,fp1				; sin(alpha) = dy / sqrt(dx^2+dy^2+dz^2)
		fscale.w	#23,fp1
		fintrz.x	fp1
		fmove.l	fp1,d0
		cmp.l	d3,d0
		ble.b	.no_fix3
		move.l	d3,d0
.no_fix3:	move.l	d0,cam_sin_alpha

		fdiv.x	fp6,fp7				; cos(alpha) = sqrt(dx^2+dz^2) / sqrt(dx^2+dy^2+dz^2)
		fneg.x	fp7				; 3d patch
		fscale.w	#23,fp7
		fintrz.x	fp7
		fmove.l	fp7,d0
		cmp.l	d3,d0
		ble.b	.no_fix4
		move.l	d3,d0
.no_fix4:	move.l	d0,cam_cos_alpha
		rts


; set camera rolling
; input: d0.w: destination focus point x
;        d1.w: destination focus point y
;        d2.w: destination focus point x
;        d3.w: steps

camera_init_rolling:
		fmove.w	d0,fp0
		fmove.w	d1,fp1
		fmove.w	d2,fp2
		fmove.w	cam_target_x,fp3
		fmove.w	cam_target_y,fp4
		fmove.w	cam_target_z,fp5
		fsub.x	fp3,fp0
		fsub.x	fp4,fp1
		fsub.x	fp5,fp2
		fdiv.w	d3,fp0
		fdiv.w	d3,fp1
		fdiv.w	d3,fp2
		fmove.s	fp0,camera_add_target_x
		fmove.s	fp1,camera_add_target_y
		fmove.s	fp2,camera_add_target_z
		fmove.s	fp3,camera_float_target_x
		fmove.s	fp4,camera_float_target_y
		fmove.s	fp5,camera_float_target_z
		rts

; interpolate to the next focus position
; be sure 'camera_init_rolling' is done

camera_interpolate:
		fmove.s	camera_float_target_x,fp0
		fmove.s	camera_float_target_y,fp1
		fmove.s	camera_float_target_z,fp2
		fadd.s	camera_add_target_x,fp0
		fadd.s	camera_add_target_y,fp1
		fadd.s	camera_add_target_z,fp2
		fmove.s	fp0,camera_float_target_x
		fmove.s	fp1,camera_float_target_y
		fmove.s	fp2,camera_float_target_z
		fintrz.x	fp0
		fintrz.x	fp1
		fintrz.x	fp2
		fmove.w	fp0,cam_target_x
		fmove.w	fp1,cam_target_y
		fmove.w	fp2,cam_target_z
		rts

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

cam_angles:
cam_ang_alpha:	dc.w	sincos_entries/2
cam_ang_beta:	dc.w	0&(sincos_entries-1)
cam_ang_gama:	dc.w	0&(sincos_entries-1)

; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

camera_float_target_x:
		ds.l	1
camera_float_target_y:
		ds.l	1
camera_float_target_z:
		ds.l	1

camera_add_target_x:
		ds.l	1
camera_add_target_y:
		ds.l	1
camera_add_target_z:
		ds.l	1
		
camera_angle_mode:
		ds.w	1				; 0: angles, 1: look at
		
focus_dist_x:	ds.w	1
focus_dist_y:	ds.w	1
focus_dist_z:	ds.w	1

cam_pos_x:	ds.w	1
cam_pos_y:	ds.w	1
cam_pos_z:	ds.w	1

cam_target_x:	ds.w	1
cam_target_y:	ds.w	1
cam_target_z:	ds.w	1

cam_cos_alpha:	ds.l	1
cam_sin_alpha:	ds.l	1

cam_cos_beta:	ds.l	1
cam_sin_beta:	ds.l	1

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
