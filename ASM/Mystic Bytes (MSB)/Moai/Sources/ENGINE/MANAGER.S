sincos_entries	equ	256<<4				; size of cos/sin table

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

init_3d:	move.l	#set_ssp,$80.w			; install new trap

mul_tab_y:	lea	mul_y,a0
		moveq	#0,d0
		move.w	#SCR_H-1,d7
.loop:		move.l	d0,(a0)+
		add.l	#SCR_W*SCR_D,d0
		dbra	d7,.loop
		
		bsr.w	realloc_tex
		
		bsr.w	send_dsp_div
		
		bsr.w	m3d_init_scenes
		
		move.w	#16<<11|32<<5|16,d0
		bsr.w	set_background
		
		bsr.w	init_alpha_tables
		bsr.w	init_alpha_textures
		
		bsr.w	scene_init_start
		;bsr.w	scene_init0			; init object #0
		;bsr.w	scene_init1			; init object #1
		;bsr.w	scene_init2			; init object #2
		;bsr.w	scene_init3			; init object #3
		;bsr.w	scene_init4			; init object #4
		;bsr.w	scene_init5			; init object #5

sin_cos_gen:	lea	cos_table,a0
		lea	sin_table,a1
		fmovecr.x	#$00,fp0		; ã
		fdiv.w		#sincos_entries/2,fp0	; 2ã/256 = ã/128
		fmove.w		#0,fp1
		move.l	#$007fffff,d6
		move.w	#sincos_entries-1,d7		; 0 ~ 255
.loop:		fsincos.x	fp1,fp2:fp3		; cos:sin
		fscale.w	#23,fp2			; cos << 23
		fscale.w	#23,fp3			; sin << 23
		fintrz.x	fp2
		fintrz.x	fp3
		fmove.l		fp2,d0
		fmove.l		fp3,d1
		cmp.l	d6,d0
		ble.b	.nofix1
		move.l	d6,d0
.nofix1:	cmp.l	d6,d1
		ble.b	.nofix2
		move.l	d6,d1
.nofix2:	move.l	d0,(a0)+
		move.l	d1,(a1)+
		fadd.x		fp0,fp1
		dbra	d7,.loop

		rts
		
set_lowres_rendering:
		move.w	#0,clip_left
		move.w	#300,clip_right
		move.w	#0,clip_up
		move.w	#100,clip_down
		move.w	#300/2,center_x
		move.w	#100/2,center_y
		bsr.w	set_lowres_screen
		move.w	#1,half_y_flag
		rts

set_hires_rendering:
		move.w	#0,clip_left
		move.w	#300,clip_right
		move.w	#0,clip_up
		move.w	#200,clip_down
		move.w	#300/2,center_x
		move.w	#200/2,center_y
		bsr.w	set_hires_screen
		clr.w	half_y_flag
		rts
		
; ======================================================

timer_3d:	tst.w	camera_angle_mode
		bne.b	.camera
		
		lea	obj_angles,a0
		lea	obj_angle_add,a1
		move.w	scene_objects,d7
		subq.w	#1,d7
.loop:		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		dbra	d7,.loop

		lea	cam_angles,a0
		lea	cam_angle_add,a1
		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		move.w	(a1)+,d0
		add.w	d0,(a0)
		andi.w	#sincos_entries-1,(a0)+
		rts
		
.camera:	bsr.w	bspline_timer
		bsr.w	camera_timer
		rts

; =====================================================

main_3d:	tst.w	camera_angle_mode
		beq.b	.no_camera
		bsr.w	camera_calc_angles
.no_camera:
		bsr.w	send_engine_start
		bsr.w	send_render_params
		
		bsr.w	send_cam_angles
		bsr.w	send_obj_angles

		bsr.w	send_cam_pos
		bsr.w	send_obj_centers

; DSP is preparing for rendering...

		movea.l	screen_adr,a0
		bsr.w	movem_screen_clear

		movea.l	screen_adr,a0
		bsr.w	rendering_init
		tst.w	d7
		bpl.b	.ok
		rts

.ok:		bsr.w	rendering_main

		rts

; this is an exception after trap #0 -> we're in
; supervisor and we set S bit to get into supervisor
; after receiving from exception

set_ssp:	bset	#5,(a7)				; set S flag
		rte

; ------------------------------------------------------
		section	bss
; ------------------------------------------------------

		EVEN

		;IFNE	*&2
		;ds.w	1
		;ENDC
		
cos_table:	ds.l	sincos_entries
sin_table:	ds.l	sincos_entries

save_sr:	ds.w	1

center_x:	ds.w	1
center_y:	ds.w	1

clip_left:	ds.w	1
clip_right:	ds.w	1
clip_up:	ds.w	1
clip_down:	ds.w	1

half_y_flag:	ds.w	1
		EVEN

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

		include	"engine\dsp_comm.s"
		include	"engine\render.s"
		include	"engine\m3d.s"
		include "engine\alpha.s"
		include	"engine\b_spline.s"
		include	"engine\traject.s"
		include	"engine\camera.s"
		include	"engine\scenes.s"