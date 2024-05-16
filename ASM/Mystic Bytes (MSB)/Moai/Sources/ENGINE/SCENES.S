; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

scene_init_start:
		move.w	#0,camera_angle_mode		; rotate angles
		bsr.w	set_hires_rendering

		moveq	#0,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		move.w	#300,d2
		bsr.w	scene_set_focus
		
		move.w	#1,obj_angle_add+0*2
		move.w	#1,obj_angle_add+1*2
		move.w	#1,obj_angle_add+2*2
		clr.w	cam_angle_add+0*2
		clr.w	cam_angle_add+1*2
		clr.w	cam_angle_add+2*2
		
		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#400,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#23,d3				; max shade
		move.w	#23,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		rts

scene_init0:	tst.w	scene_init_flag0
		bne.w	.done
		addq.w	#1,scene_init_flag0

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#1,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles
		
		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		move.w	#-41,cam_target_x
		move.w	#79,cam_target_y
		move.w	#710,cam_target_z
		
		lea	scene_textable0,a0
		bsr.w	scene_set_alpha_textures
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#400,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#23,d3				; max shade
		move.w	#23,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts
		
scene_init1:	tst.w	scene_init_flag1
		bne.w	.done
		addq.w	#1,scene_init_flag1
		
		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#2,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles

		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		move.w	#-12,cam_target_x
		move.w	#247,cam_target_y
		move.w	#7,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#800,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#63,d3				; max shade
		move.w	#63,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts
		
scene_init2:	tst.w	scene_init_flag2
		bne.w	.done
		addq.w	#1,scene_init_flag2

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#3,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#4,d0
		bsr.w	scene_send_dsptex1
		
		lea	scene_textable2,a0
		bsr.w	scene_set_alpha_textures
		
		move.w	#-12,cam_target_x
		move.w	#147,cam_target_y
		move.w	#7,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#1,d0				; trava1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#4,d0				; okno1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#600,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#33,d3				; max shade
		move.w	#33,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts
		
scene_init3:	tst.w	scene_init_flag3
		bne.w	.done
		addq.w	#1,scene_init_flag3

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#1,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles

		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		lea	scene_textable3,a0
		bsr.w	scene_set_alpha_textures
		
		move.w	#69,cam_target_x
		move.w	#95,cam_target_y
		move.w	#486,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#400,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#23,d3				; max shade
		move.w	#23,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts

scene_init4:	tst.w	scene_init_flag4
		bne.w	.done
		addq.w	#1,scene_init_flag4

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#2,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles
		
		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		move.w	#-12,cam_target_x
		move.w	#247,cam_target_y
		move.w	#7,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#800,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#63,d3				; max shade
		move.w	#63,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts
		
scene_init5:	tst.w	scene_init_flag5
		bne.w	.done
		addq.w	#1,scene_init_flag5

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#2,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles

		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		move.w	#-12,cam_target_x
		move.w	#247,cam_target_y
		move.w	#7,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#800,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#63,d3				; max shade
		move.w	#63,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts

		ifne	0
scene_init6:	tst.w	scene_init_flag6
		bne.w	.done
		addq.w	#1,scene_init_flag6

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#1,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles

		moveq	#0,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex1
		
		lea	scene_textable3,a0
		bsr.w	scene_set_alpha_textures
		
		move.w	#69,cam_target_x
		move.w	#95,cam_target_y
		move.w	#486,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#0,d0				; kamen1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#1,d0				; trava
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#400,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#23,d3				; max shade
		move.w	#23,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts
		endc

scene_init7:	tst.w	scene_init_flag7
		bne.w	.done
		addq.w	#1,scene_init_flag7

		move.w	#1,camera_angle_mode		; 'look at'
		bsr.w	set_lowres_rendering

		moveq	#3,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		clr.w	d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles
		
		moveq	#1,d0
		bsr.w	scene_send_dsptex0
		
		moveq	#4,d0
		bsr.w	scene_send_dsptex1
		
		lea	scene_textable2,a0
		bsr.w	scene_set_alpha_textures
		
		move.w	#-77,cam_target_x
		move.w	#13,cam_target_y
		move.w	#-44,cam_target_z
		
		lea	dsp_current_alpha_tables,a0
		moveq	#1,d0				; trava1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		moveq	#4,d0				; okno1
		move.l	(dsp_alpha_tables.l,pc,d0.l*4),(a0)+
		
		move.w	#1,d0				; min z
		move.w	#600,d1				; max z
		move.w	#0,d2				; min shade
		move.w	#33,d3				; max shade
		move.w	#33,d4				; starting shade
		bsr.w	calc_shading
		
		move.w	#3,texture_repeat		; 2^3
		
		addi.l	#24,current_fx
.done:		rts

scene_init_end:	tst.w	scene_init_flag_end
		bne.w	.done
		addq.w	#1,scene_init_flag_end

		move.w	#0,camera_angle_mode		; rotate angles
		bsr.w	set_hires_rendering
		
		moveq	#4,d0
		bsr.w	scene_set
		
		clr.w	d0
		clr.w	d1
		move.w	#200,d2
		bsr.w	scene_set_focus
		
		bsr.w	scene_reset_angles
		
		clr.w	cam_pos_x
		move.w	#60,cam_pos_y
		clr.w	cam_pos_z
		
		move.w	#1,obj_angle_add+0*2
		move.w	#2,obj_angle_add+1*2
		move.w	#3,obj_angle_add+2*2
		
		clr.w	cam_angle_add+0*2
		move.w	#1,cam_angle_add+1*2
		clr.w	cam_angle_add+2*2		
		
		moveq	#0,d0
		movea.l	(dsp_env_textures.l,pc,d0.l*4),a0
		bsr.w	send_texture
		
		moveq	#1,d0
		movea.l	(dsp_env_textures.l,pc,d0.l*4),a0
		bsr.w	send_texture
		
		addi.l	#24,current_fx
.done:		rts

		
; calc shade constants for dsp
; current shade = max_shade << 14 + z * (min_shade-max_shade)/(max_z-min_z) << 14
;                 ^^^^^^^^^^^^^^^       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;                 shading_adder         shading_ratio
; d0.w: min z
; d1.w: max z
; d2.w: min shade
; d3.w: max shade
; d4.w: starting shade

calc_shading:	muls.w	#1<<14,d4
		move.l	d4,shading_adder
		
		sub.w	d3,d2				; min_shade - max_shade
		sub.w	d0,d1				; max_z - min_z
		ext.l	d1
		muls.w	#1<<14,d2
		divs.l	d1,d2
		move.l	d2,shading_ratio
		rts
		
; set current alpha textures
; input: a0: texture table

scene_set_alpha_textures:
		lea	current_alpha_textures,a1
		clr.l	d0
		moveq	#CPU_TEXTURES-1,d7
		
.loop:		move.b	(a0)+,d0
		move.l	(alpha_textures.l,pc,d0.l*4),(a1)+
		
		dbra	d7,.loop
		rts
		
; set all that stuff & send scene to dsp
; input: d0.w: number of scene

scene_set:	move.w	d0,-(sp)
		bsr.w	m3d_set_scene
		move.w	(sp),d0
		bsr.w	send_m3d_scene
		move.w	(sp)+,d0
		move.l	(m3d_palettes.l,pc,d0.w*4),scene_pal
		move.l	(m3d_colortabs.l,pc,d0.w*4),scene_colortab
		rts
		
; send first dsp texture
; input: d0.w: number of dsp texture

scene_send_dsptex0:
		movea.l	(dsp_alpha_textures.l,pc,d0.l*4),a0
		moveq	#0,d0				; dsp texture #0
		bsr.w	send_alpha_texture
		rts
		
; send second dsp texture
; input: d0.w: number of dsp texture

scene_send_dsptex1:
		movea.l	(dsp_alpha_textures.l,pc,d0.l*4),a0
		moveq	#1,d0				; dsp texture #1
		bsr.w	send_alpha_texture
		rts

; set focus distance for scene		
; input: d0.w: focus x
;        d1.w: focus y
;        d2.w: focus z

scene_set_focus:
		move.w	d0,focus_dist_x
		move.w	d1,focus_dist_y
		move.w	d2,focus_dist_z
		rts
		
; reset rotation angles for the current scene

scene_reset_angles:
		lea	obj_angles,a0
		move.w	scene_objects,d7
		subq.w	#1,d7

.loop:		clr.w	(a0)+
		clr.w	(a0)+
		clr.w	(a0)+

		dbra	d7,.loop
		rts
		
; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

scene_textable0:
		dc.b	0,1,0,0				; -,stena1,-,-
scene_textable2:
		dc.b	0,1,3,0				; -,stena1,tehla1,-
scene_textable3:
		dc.b	0,1,0,0				; -,stena1,-,-
		EVEN
		
; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

shading_adder:	ds.l	1
shading_ratio:	ds.l	1

texture_repeat:	ds.w	1

scene_init_flag0:
		ds.w	1
scene_init_flag1:
		ds.w	1
scene_init_flag2:
		ds.w	1
scene_init_flag3:
		ds.w	1
scene_init_flag4:
		ds.w	1
scene_init_flag5:
		ds.w	1
scene_init_flag6:
		ds.w	1
scene_init_flag7:
		ds.w	1
scene_init_flag_end:
		ds.w	1

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
