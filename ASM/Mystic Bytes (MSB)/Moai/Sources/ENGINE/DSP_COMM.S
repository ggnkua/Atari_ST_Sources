HC_RECEIVE_OBJ	EQU	0
HC_RECEIVE_TEX	EQU	1
HC_START_ENGINE	EQU	2
HC_INIT_PLAYER	EQU	3

; ------------------------------------------------------
		section	text
; ------------------------------------------------------

; send m3d scene to dsp
; input: d0.w: number of m3d scene

send_m3d_scene:	movea.l	(m3d_scenes.l,pc,d0.w*4),a0
		lea	12(a0),a0			; skip header + scene info
		move.w	scene_materials,d7
		andi.w	#$7fff,d7
		mulu.w	#3,d7
		adda.l	d7,a0				; skip materials

		moveq	#HC_RECEIVE_OBJ,d0
		bsr.w	call_dsp_subroutine

		move.w	scene_objects,d0
		bsr.w	dsp_send_unsigned_word
		move.w	scene_points,d0
		bsr.w	dsp_send_unsigned_word
		move.w	scene_faces,d0
		bsr.w	dsp_send_unsigned_word
		move.w	scene_materials,d0
		bsr.w	dsp_send_unsigned_word

		move.w	scene_objects,d0
		mulu.w	#5,d0				; dc.w points,faces,cx,cy,cz
		bsr.w	dsp_send_signed_block16

		move.w	scene_points,d0
		mulu.w	#3+3,d0				; x,y,z + nx,ny,nz
		bsr.w	dsp_send_signed_block16

		move.w	scene_materials,d0
		btst	#15,d0
		beq.b	.skip				; if planar, skip

		move.w	scene_points,d0
		mulu.w	#2,d0				; dc.b u,v
		bsr.w	dsp_send_unsigned_block8

.skip:		move.w	scene_faces,d7
		subq.w	#1,d7

.loop1:		move.w	(a0)+,d0			; vertices
		bsr.w	dsp_send_unsigned_word
		move.w	d0,d6
		subq.w	#1,d6
		
		move.w	(a0)+,d0			; face flags
		bsr.w	dsp_send_unsigned_word

		btst	#FLG_TEXMAP,d0			; texturemapped?
		sne	face_flag			; yes, set $ff (else $00)

.loop2:		move.w	(a0)+,d0			; p[i]
		bsr.w	dsp_send_unsigned_word
		tst.b	face_flag
		beq.b	.not_uv
		move.b	(a0)+,d0			; u[i]
		bsr.w	dsp_send_unsigned_byte
		move.b	(a0)+,d0			; v[i]
		bsr.w	dsp_send_unsigned_byte

.not_uv:	dbra	d6,.loop2

		dbra	d7,.loop1
		rts

; make & send inverse mul table to dsp

send_dsp_div:	move.b	#$92,$ffffa201.w		; host cmd #$24
		move.l	#$800000,d2			; 1 << 23
		moveq	#2,d1				; 1/2 ~ 1/1024
		move.w	#1023-1,d7
.loop:		move.l	d2,d0
		divs.l	d1,d0
		bsr.w	dsp_send_long
.skipdiv:	addq.l	#1,d1
		dbra	d7,.loop
		rts
		
send_render_params:
		move.w	center_x,d0			; screen center
		bsr.w	dsp_send_unsigned_word
		move.w	center_y,d0
		bsr.w	dsp_send_unsigned_word
		
		move.w	clip_left,d0			; clipping rectangle
		bsr.w	dsp_send_unsigned_word
		move.w	clip_right,d0
		bsr.w	dsp_send_unsigned_word
		move.w	clip_up,d0
		bsr.w	dsp_send_unsigned_word
		move.w	clip_down,d0
		bsr.w	dsp_send_unsigned_word
		
		move.w	focus_dist_x,d0			; distance vector
		bsr.w	dsp_send_signed_word
		move.w	focus_dist_y,d0
		bsr.w	dsp_send_signed_word
		move.w	focus_dist_z,d0
		bsr.w	dsp_send_signed_word
		rts
		
; send camera angles for generating camera matrix
; has to be just before send_obj_angles!

send_cam_angles:
		lea	cos_table,a0
		lea	sin_table,a1
		clr.l	d1
		
		tst.w	camera_angle_mode
		bne.b	.camera
		
		lea	cam_angles,a2
		move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(alpha)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(alpha)
		bsr.w	dsp_send_long
		move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(beta)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(beta)
		bsr.w	dsp_send_long
		move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(gama)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(gama)
		bsr.w	dsp_send_long
		rts
		
.camera:	move.l	cam_cos_alpha,d0		; cos(alpha)
		bsr.w	dsp_send_long
		move.l	cam_sin_alpha,d0		; sin(alpha)
		bsr.w	dsp_send_long
		move.l	cam_sin_beta,d0			; cos(beta)
		bsr.w	dsp_send_long
		move.l	cam_cos_beta,d0			; sin(beta)
		bsr.w	dsp_send_long
		
		move.w	cam_ang_gama,d1
		move.l	(a0,d1.l*4),d0			; cos(gama)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(gama)
		bsr.w	dsp_send_long
		rts
		
; send camera position

send_cam_pos:	move.w	cam_pos_x,d0
		bsr.w	dsp_send_signed_word
		move.w	cam_pos_y,d0
		bsr.w	dsp_send_signed_word
		move.w	cam_pos_z,d0
		bsr.w	dsp_send_signed_word		
		rts

; send cos/sin values for generating object matrices

send_obj_angles:
		lea	cos_table,a0
		lea	sin_table,a1
		lea	obj_angles,a2
		move.w	scene_objects,d7
		subq.w	#1,d7
		clr.l	d1
		
.send_loop:	move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(alpha)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(alpha)
		bsr.w	dsp_send_long
		move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(beta)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(beta)
		bsr.w	dsp_send_long
		move.w	(a2)+,d1
		move.l	(a0,d1.l*4),d0			; cos(gama)
		bsr.w	dsp_send_long
		move.l	(a1,d1.l*4),d0			; sin(gama)
		bsr.w	dsp_send_long
		dbra	d7,.send_loop		
		rts
		
; send (cx, cy, cz) center for each object

send_obj_centers:
		lea	obj_centers,a0
		move.w	scene_objects,d0
		mulu.w	#3,d0				; cx, cy, cz
		bsr.w	dsp_send_signed_block16
		rts
		
; send an init command & y-resolution size

send_engine_start:
		moveq	#HC_START_ENGINE,d0
		bsr.w	call_dsp_subroutine
		
		move.w	half_y_flag,d0
		bsr.w	dsp_send_unsigned_word
		
		move.l	shading_adder,d0
		bsr.w	dsp_send_long
		move.l	shading_ratio,d0
		bsr.w	dsp_send_long
		move.w	texture_repeat,d0
		bsr.w	dsp_send_unsigned_word
		rts
		
; send a high color texture
; input: a0:   64x64 'TRUP' texture
;        d0.w: number of texture

send_texture:	move.w	d0,d1				; save

		moveq	#HC_RECEIVE_TEX,d0
		bsr.w	call_dsp_subroutine
		
		move.w	d1,d0
		bsr.w	dsp_send_unsigned_word
		
		addq.l	#8,a0				; skip header
		move.w	#64*64,d0
		bsr.w	dsp_send_unsigned_block16
		rts
		
; send aa 8-bit alpha texture
; input: a0:   64x64 '256' texture
;        d0.w: number of texture

send_alpha_texture:
		move.w	d0,d1				; save

		moveq	#HC_RECEIVE_TEX,d0
		bsr.w	call_dsp_subroutine
		
		move.w	d1,d0
		bsr.w	dsp_send_unsigned_word
		
		adda.l	#8+256*2,a0			; skip header + palette
		
		move.w	#64*64-1,d0
		
.loop:		wait_send
		clr.l	d1				; clear hi word
		move.b	(a0)+,d1
		lsl.l	#1,d1				; cheating for faster version
		move.l	d1,$ffffa204.w			; i/o data path 00:hi:mi:lo

		dbra	d0,.loop
		rts
		
; ------------------------------------------------------
		section	bss
; ------------------------------------------------------

		EVEN
face_flag:	ds.b	1
		EVEN

; ------------------------------------------------------
		section	text
; ------------------------------------------------------
