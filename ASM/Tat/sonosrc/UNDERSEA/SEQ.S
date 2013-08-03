









;          a     _     v     _      e     _     n     _     a










;
; Sequencer for undersea section, September 1996
; will require installation of routines
; to handle more than one object?
;


Init_Sequencer:
		move.l	a0,sequence_position
		clr.w	sequence_counter
		clr.w	sequence_end_flag
		bsr	Sequencer
		rts

Sequencer:
		tst.w	sequence_end_flag
		bne.s	.sequence_finished

		tst.w	sequence_counter
		bne.s	.skip_seq

		bsr	next_sequence
.skip_seq:
		subq.w	#1,sequence_counter
	IFEQ	keys
		bsr	update_movement
	ENDC
.sequence_finished:
	IFNE	keys
		bsr	handle_keyboard
	ENDC
		rts



next_sequence:
		move.l	sequence_position,a0
sequence_again:
		move.w	(a0)+,d0
		move.l	(sequence_event_list.l,d0.w*4),a1

		jsr	(a1)

		move.w	(a0)+,sequence_counter
		beq	sequence_again

		move.l	a0,sequence_position
		rts


sequence_end:
		st	sequence_end_flag
		rts

sequence_set_rotation:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Rotation_X
		rts

sequence_set_rotation_movement:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Rotation_X_Speed
		rts

sequence_set_lrotation:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,LightRot_X
		rts

sequence_set_lrotation_movement:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,LightRot_X_Speed
		rts


sequence_set_view:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Viewer_X
		rts

sequence_set_view_movement:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Viewer_X_Speed
		rts

sequence_set_routine_type:
		move.w	(a0)+,d0
		move.w	d0,sequence_routine_type
		move.l	(sequence_routine_list.l,d0.w*4),sequence_routine
		rts

sequence_set_rays:
		move.w	(a0)+,sequence_ray_move
		move.w	(a0)+,sequence_ray_move_speed
		rts

sequence_set_fade:
		st	sequence_fade
		rts


sequence_set_zoom:
		moveq	#0,d0
		move.w	(a0)+,d0
		move.l	d0,sequence_zoom
		rts

sequence_close_old_routine:
		 wait_transmit
		move.l	#"RTS",$FFFFA204.W
		rts

sequence_init_routine_type:
		move.w	sequence_routine_type,d0
		move.l	(sequence_init_list.l,d0.w*4),a6
		movem.l	d0-a6,-(a7)
		jsr	(a6)
		movem.l	(a7)+,d0-a6
		rts

sequence_routine_list:
		dc.l	Do_Normal_Routine
		dc.l	Do_Blur_Routine
		dc.l	Do_Dolphin_Routine
sequence_init_list:
		dc.l	Init_Normal_Routine
		dc.l	Init_Blur_Routine
		dc.l	Init_Dolphin_Routine


sequence_fetch_3:
		movem.w	(a0)+,d0/d1/d2
		ext.l	d0
		ext.l	d1
		ext.l	d2
		rts


update_movement:
		lea	Viewer_X,a1
		movem.l	Viewer_X_Speed,d0/d1/d2
		add.l	d0,(a1)+
		add.l	d1,(a1)+
		add.l	d2,(a1)+

		lea	Rotation_X,a1
		movem.l	Rotation_X_Speed,d0/d1/d2
		add.l	d0,(a1)+
		add.l	d1,(a1)+
		add.l	d2,(a1)+

		lea	LightRot_X,a1
		movem.l	LightRot_X_Speed,d0/d1/d2
		add.l	d0,(a1)+
		add.l	d1,(a1)+
		add.l	d2,(a1)+

		movem.w	sequence_ray_pos,d0/d1
		move.w	sequence_ray_move_speed,d2
		cmp.w	d1,d0
		beq.s	.ok2
		bgt.s	.dosub
		add.w	d2,d0
		bra.s	.ok2
.dosub		sub.w	d2,d0
.ok2		movem.w	d0/d1,sequence_ray_pos
		rts

sequence_null_routine:
		rts

;--------------------------------------------------------------
	IFNE	keys
Handle_Keyboard:
		LEA	Keyboard_Tests,A0
.loop		MOVE.L	(A0)+,D0
		BMI.S	.done
		MOVE.L	(A0)+,D1		;val to add
		MOVE.L	(A0)+,A1		;address
		TST.B	(Keyboard_Matrix.L,D0.w)
		BEQ.S	.nochange
		ADD.L	D1,(A1)			;along longword values
.nochange:
		BRA.S	.loop
.done:		RTS

movespeed	equ 16*4
movespeed2	equ $40

Keyboard_Tests:
		DC.L	$02,+movespeed2,viewer_x
		DC.L	$03,-movespeed2,viewer_x

		DC.L	$67,+movespeed,rotation_x
		DC.L	$6a,-movespeed,rotation_x
		DC.L	$68,+movespeed,rotation_y
		DC.L	$6B,-movespeed,rotation_y
		DC.L	$69,+movespeed,rotation_z
		DC.L	$6C,-movespeed,rotation_z

		DC.L	$4E,+movespeed2,Viewer_Distance
		DC.L	$4A,-movespeed2,Viewer_Distance
		DC.L	-1
	ENDC


;-----------------------------------------------------------------------
sequence_event_list:
		dc.l	sequence_end

		dc.l	sequence_set_rotation
		dc.l	sequence_set_rotation_movement

		dc.l	sequence_set_lrotation
		dc.l	sequence_set_lrotation_movement

		dc.l	sequence_set_view
		dc.l	sequence_set_view_movement

		dc.l	sequence_close_old_routine
		dc.l	sequence_set_routine_type
		dc.l	sequence_init_routine_type

		dc.l	sequence_set_rays
		dc.l	sequence_set_fade
		dc.l	sequence_set_zoom

		rsreset
seq_end		rs.b	1

seq_set_rot	rs.b	1
seq_set_rotmov	rs.b	1

seq_set_lrot	rs.b	1
seq_set_lrotmov	rs.b	1

seq_set_view	rs.b	1
seq_set_viewmov	rs.b	1

seq_close	rs.b	1
seq_set_rout	rs.b	1
seq_init_rout	rs.b	1

seq_set_rays	rs.b	1
seq_set_fade	rs.b	1
seq_set_zoom	rs.b	1

;-----------------------------------------------------------------------
Rotation_X_Speed:	dc.l	0
Rotation_Y_Speed:	dc.l	0
Rotation_Z_Speed:	dc.l	0

LightRot_X_Speed:	dc.l	0
LightRot_Y_Speed:	dc.l	0
LightRot_Z_Speed:	dc.l	0

Viewer_X_Speed:		dc.l	0
Viewer_Y_Speed:		dc.l	0
Viewer_Z_Speed:		dc.l	0

sequence_routine_type:	ds.w	1
sequence_routine:	dc.l	sequence_null_routine

sequence_end_flag:	ds.w	1
sequence_counter:	ds.w	1
sequence_position:	ds.l	1

sequence_ray_pos	dc.w	rays_top
sequence_ray_move	dc.w	1
sequence_ray_move_speed	dc.w	0
sequence_fade		dc.w	0
sequence_zoom		dc.l	$20
