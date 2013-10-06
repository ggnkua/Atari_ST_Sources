

;--------------------------------------

; keine registerbeschraenkung

being_bored

	; wenn eine gewisse zeit vergangen ist, in der
	; der spieler keine bewegung gemacht hat, dann
	; einen bloeden spruch abgeben ...

	; jedoch nicht, wenn menue aktiv ist ...
	; ebenso nicht, wenn spieler bereits gestorben ...

		tst.w	menue_flag
		bne	bb_out

		movea.l	play_dat_ptr,a1
		tst.w	pd_health(a1)
		bmi	bb_out

		tst.w	pd_duke_talk(a1)
		bne	bb_out

	; entscheidung anhand (sx,sy,alpha) ...

	; neue koordinaten holen ...

		movem.l	pd_sx(a1),d0-d1
		move.l	pd_alpha(a1),d2

	; ... und mit vorherigen vergleichen!

		moveq	#0,d3

		lea	bb_sx(pc),a0
		cmp.l	(a0),d0
		bne.s	bb_new_position
		cmp.l	4(a0),d1
		bne.s	bb_new_position
		cmp.l	8(a0),d2
		bne.s	bb_new_position
		

	; position hat sich zum vorherigen durchgang
	; nicht veraendert ...

	; a0 zeigt auf bb_sx !!!

		move.w	-2(a0),d3		; bb_time
		add.w	vbl_time,d3
		cmpi.w	#bored_vbl,d3
		blt.s	bb_no_comment

	; die zeit waere reich fuer einen spruch ...

		moveq	#0,d3

	; bringe noch den zufall 50-50 herein durch vbl_count ...

		move.l	vbl_count,d4
		move.l	d4,d5
		not.w	d5
		mulu	d5,d4
		btst	#2,d4
		beq.s	bb_no_comment

	; entscheide anhand bit 1 von vbl_count, ob
	; kommentar 1 oder 2 gestartet wird ...

		movem.l	d0-d3/a0,-(sp)
		move.w	#snd_bored,d0
		btst	#1,d4
		beq.s	bb_second_case
		move.w	#snd_asses,d0
bb_second_case	moveq	#0,d1
		move.w	#1,dma_speech_flag
		jsr	init_sam
		movem.l	(sp)+,d0-d3/a0

bb_no_comment
bb_new_position

		move.w	d3,-2(a0)

	; neue position abspeichern ...

		movem.l	d0-d2,(a0)

bb_out
		rts


;---

	; reihenfolge der variablen beachten !!!

bb_time		dc.w	0
bb_sx		dc.l	0
bb_sy		dc.l	0
bb_alpha	dc.l	0

