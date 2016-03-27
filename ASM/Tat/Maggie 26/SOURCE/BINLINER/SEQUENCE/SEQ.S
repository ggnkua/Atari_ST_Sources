;
; Sequencer September 1996, March 1997
; will require installation of routines
; to handle more than one object?
;


; Declarations of sequence usage in seqdec.s

; Init_Sequencer	a0 = sequence, a1 = misc data
;				0(a1) = sequence_routine_list,
;				4(a1) = sequence_init_list

; Sequencer		(nothing)

; Sequence_Update_Movement
;			(nothing)



		include	f:\source\tdf\sequence\seqdec.s

Init_Sequencer:
		move.l	a0,sequence_position
		move.l	(a1)+,sequence_routine_list
		move.l	(a1)+,sequence_init_list
		clr.w	sequence_counter
		clr.w	sequence_end_flag
		bsr	Sequencer
		rts

Sequencer:
		tst.w	sequence_end_flag
		bne.s	.sequence_finished

		tst.w	sequence_counter
		bmi.s	.wait_music
		bne.s	.skip_seq

; otherwise it's zero
		move.l	sequence_position,a0
		move.w	(a0)+,d0			;which command
		move.l	(sequence_event_list.l,d0.w*4),a1
		jsr	(a1)
		move.l	a0,sequence_position
		bra	Sequencer

.skip_seq:
		subq.w	#1,sequence_counter

.sequence_finished:
		rts

.wait_music:
		IFNE	Demo
		move.l	music_data,a6
		move.l	(a6),a6
		moveq	#0,d0
		move.b	aon_pos(a6),d0		;d0 - current pos
		move.w	sequence_music_position,d1 ; d1 - desired pos
		cmp.w	d1,d0
		blt.s	.keep_waiting		;curr pos is less than
						;required - so continue
		bgt.s	.finished		;gone too far - finished

		move.w	aon_patcnt(a6),d0
		and.w	#$3fc,d0
		move.w	sequence_music_patcnt,d1
		cmp.w	d1,d0
		blt.s	.keep_waiting

.finished:	move.w	#0,sequence_counter
		bra	sequencer

.keep_waiting:
		rts				;no more sequencing

		ELSE
		move.w	#100,sequence_counter
		ENDC
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

sequence_set_camera:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Camera_X
		rts

sequence_set_camera_movement:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,Camera_X_Speed
		rts

sequence_set_misc:
		move.w	(a0)+,d0		;offset
		move.l	(a0)+,d1		;data
		move.l	d1,(sequence_misc_data.l,d0.w)
		rts

sequence_wait_music:
		move.w	#-1,sequence_counter
		move.w	(a0)+,sequence_music_position
		move.w	(a0)+,d0
		asl.w	#2,d0
		and.w	#$3fc,d0
		move.w	d0,sequence_music_patcnt
		rts

sequence_wait:
		move.w	(a0)+,sequence_counter
		rts

sequence_set_routine:
		move.w	(a0)+,d0
		move.w	d0,sequence_routine_type
		move.l	sequence_routine_list,a5
		move.l	(a5,d0.w*4),sequence_routine
		rts

sequence_close:
		 ;wait_transmit
		move.l	#"RTS",$FFFFA204.W
		rts

sequence_init_routine:
		move.w	sequence_routine_type,d0
		move.l	sequence_init_list,a5
		move.l	(a5,d0.w*4),a6
		movem.l	d0-a6,-(a7)
		jsr	(a6)
		movem.l	(a7)+,d0-a6
		rts

sequence_send_object:
		move.w	(a0)+,d0		;object number
		move.l	(sequence_object_list.l,d0.w*4),a1
		move.l	a1,which_object
		wait_transmit
		MOVE.L	#"OBJ",$FFFFA204.W
		MOVE.L	(A1)+,D0
		 wait_transmit
		MOVE.L	D0,$FFFFA204.W
		SUBQ.L	#1,D0
.SendPoints:
		 wait_transmit
		MOVE.L	(A1)+,$FFFFA204.W
		DBF	D0,.SendPoints
		RTS




sequence_fetch_3:
		movem.w	(a0)+,d0/d1/d2
		ext.l	d0
		ext.l	d1
		ext.l	d2
		rts

Sequence_Update_Movement:
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

		lea	Camera_X,a1
		movem.l	Camera_X_Speed,d0/d1/d2
		add.l	d0,(a1)+
		add.l	d1,(a1)+
		add.l	d2,(a1)+
		rts

sequence_null_routine:
		rts


;-----------------------------------------------------------------------
Rotation_X_Speed:	dc.l	0
Rotation_Y_Speed:	dc.l	0
Rotation_Z_Speed:	dc.l	0

Rotation_X:		dc.l	0
Rotation_Y:		dc.l	0
Rotation_Z:		dc.l	0

LightRot_X_Speed:	dc.l	0
LightRot_Y_Speed:	dc.l	0
LightRot_Z_Speed:	dc.l	0

LightRot_X:		dc.l	0
LightRot_Y:		dc.l	0
LightRot_Z:		dc.l	0

Viewer_X_Speed:		dc.l	0
Viewer_Y_Speed:		dc.l	0
Viewer_Z_Speed:		dc.l	0

Viewer_X:		dc.l	0
Viewer_Y:		dc.l	0
Viewer_Z:		dc.l	0

Camera_X:		dc.l	0
Camera_Y:		dc.l	0
Viewer_Distance:
Camera_Z:		dc.l	$3000

Camera_X_Speed:		dc.l	0
Camera_Y_Speed:		dc.l	0
Camera_Z_Speed:		dc.l	0

sequence_misc_data:	ds.l	256
sequence_object_list	ds.l	256		;install these yourself

sequence_routine_list	ds.l	1
sequence_init_list	ds.l	1

sequence_routine_type:	ds.w	1
sequence_routine:	dc.l	sequence_null_routine

sequence_end_flag:	ds.w	1
sequence_counter:	ds.w	1
sequence_position:	ds.l	1

sequence_music_position	ds.w	1
sequence_music_patcnt	ds.w	1

;-----------------------------------------------------------------------
sequence_event_list:
			dc.l	sequence_end
			dc.l	sequence_wait
			dc.l	sequence_set_rotation
			dc.l	sequence_set_rotation_movement
			dc.l	sequence_set_lrotation
			dc.l	sequence_set_lrotation_movement
			dc.l	sequence_set_view
			dc.l	sequence_set_view_movement
			dc.l	sequence_close
			dc.l	sequence_set_routine
			dc.l	sequence_init_routine
			dc.l	sequence_set_misc
			dc.l	sequence_wait_music
			dc.l	sequence_set_camera
			dc.l	sequence_set_camera_movement
			dc.l	sequence_send_object
