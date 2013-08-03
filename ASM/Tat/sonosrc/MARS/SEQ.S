









;          avena










;
; Sequencer for mars/water section, September-December 1996
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
		bsr	update_movement
.sequence_finished:
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

sequence_set_eye:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,eye_x
		rts

sequence_set_eye_dydx:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,eye_dydx
		rts

sequence_set_eye_d2ydx2:
		bsr	sequence_fetch_3
		movem.l	d0/d1/d2,eye_d2ydx2
		rts

sequence_set_theta:
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,theta
		rts

sequence_set_theta_dydx:
		move.w	(a0)+,d0
		ext.l	d0
		move.l	d0,theta_dydx
		rts

sequence_close:
		wait_transmit
		move.l	#"RTS",$FFFFA204.W
		rts

sequence_fetch_3:
		movem.w	(a0)+,d0/d1/d2
		ext.l	d0
		ext.l	d1
		ext.l	d2
		rts


update_movement:
		lea	eye_d2ydx2,a0
		lea	eye_dydx,a1
		bsr	.update_3

		lea	eye_dydx,a0
		lea	eye_x,a1
		bsr	.update_3

		move.l	theta_dydx,d0
		add.l	d0,theta

		move.w	colour_offset,d0
		add.w	colour_add,d0
		cmp.w	#128,d0
		blt.s	.ok
		move.w	#128,d0
.ok		move.w	d0,colour_offset
		rts


.update_3:	movem.l	(a0),d0/d1/d2
		add.l	d0,(a1)+
		add.l	d1,(a1)+
		add.l	d2,(a1)+
		rts

sequence_null_routine:
		rts

sequence_set_colour
		move.w	(a0)+,colour_add
		rts

;-----------------------------------------------------------------------
sequence_event_list:
		dc.l	sequence_end
		dc.l	sequence_set_eye
		dc.l	sequence_set_eye_dydx
		dc.l	sequence_set_eye_d2ydx2
		dc.l	sequence_set_theta
		dc.l	sequence_set_theta_dydx
		dc.l	sequence_close
		dc.l	sequence_set_colour

			rsreset
seq_end			rs.b	1

seq_set_eye		rs.b	1
seq_set_eye_dydx	rs.b	1
seq_set_eye_d2ydx2	rs.b	1

seq_set_theta		rs.b	1
seq_set_theta_dydx	rs.b	1

seq_close		rs.b	1
seq_set_colour_add	rs.b	1
;-----------------------------------------------------------------------

sequence_end_flag:	ds.w	1
sequence_counter:	ds.w	1
sequence_position:	ds.l	1

colour_offset		dc.w	0
colour_add		dc.w	0




