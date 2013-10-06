;**************************************
;* move_it
;**************************************

move_it

	; ganze unterroutine: d7 = joypad

		lea	jagpad_routs+4,a2
		jsr	(a2)
		move.l	d0,d7

	; run mode simulieren

		lea	keytable,a1
		tst.b	$60(a1)
		beq.s	mirm_no_keypress

		clr.b	$60(a1)
		lea	sm_run_mode_on,a0
		move.w	rm_flag(pc),d0
		bchg	#0,d0
		beq.s	mirm_on
		lea	sm_run_mode_off,a0
		clr.b	$1d(a1)
mirm_on		move.w	d0,rm_flag
		jsr	install_message

mirm_no_keypress

		tst.w	rm_flag(pc)
		beq.s	mirm_out
		move.b	#1,keytable+$1d

mirm_out

	; -----------------------------

		movea.l	play_dat_ptr,a6

		movem.l	pd_sx(a6),d0-d1
		movem.l	d0-d1,sx_test

		clr.w	has_moved
		clr.w	has_turned
		clr.w	pd_hat_gesch(a6)

	; wenn spieler gestorben, dann keine bewegung.
	; ebenso nicht, wenn menue aktiv ist ...

		tst.w	pd_health(a6)
		bmi	move_it_out
		tst.w	menue_flag
		bne	move_it_out

	; schrittweiten aus vbl_time bestimmen

		lea	walking_data,a0
		lea	keytable,a1
		move.w	vbl_time,d0
		lea	(a0,d0.w*8),a0

	; status jagpad a holen ...


	; springt spieler?

		tst.b	$1e(a1)
		bne.s	move_make_jump
		btst	#8,d7
		beq.s	move_no_jump
move_make_jump
		bsr	move_jump
move_no_jump

	; registerbelegung:
	;   d7: status jagpad a
	;   a0: walking_data
	;   a1: keytable
	;   a6: play_dat_ptr

	; vorwaerts- und rueckwaertsbewegung ...

		tst.b	$48(a1)
		bne.s	mi_forward
		btst	#0,d7
		beq.s	mi_no_forward
mi_forward	bsr	forward
		bra.s	mi_no_slower_step
mi_no_forward
		tst.b	$50(a1)
		bne.s	mi_backward
		btst	#1,d7
		beq.s	mi_no_backward
mi_backward	bsr	backwrd
		bra.s	mi_no_slower_step
mi_no_backward
		tst.w	pd_last_step(a6)
		beq.s	mi_no_slower_step
		bsr	slower_step
mi_no_slower_step

	; seitwaertsbewegung ...

		tst.b	$38(a1)		; alternate
		bne.s	mi_strafe
		btst	#10,d7		; button c
		beq.s	mi_no_strafe
mi_strafe
		tst.b	$4b(a1)
		bne.s	mi_strafe_left
		btst	#2,d7
		beq.s	mi_no_strafe_l
mi_strafe_left	bra	strafe_left
mi_no_strafe_l	tst.b	$4d(a1)
		bne.s	mi_strafe_right
		btst	#3,d7
		beq.s	mi_no_strafe_r
mi_strafe_right	bra	strafe_right
mi_no_strafe_r	bra	no_slower_alpha
mi_no_strafe

	; drehbewegung links- oder rechtsherum ...

		tst.b	$4b(a1)
		bne.s	move_left
		btst	#2,d7
		beq.s	mi_no_move_l
move_left	bsr	left
		bra.s	no_slower_alpha
mi_no_move_l	tst.b	$4d(a1)
		bne.s	move_right
		btst	#3,d7
		beq.s	mi_no_move_r
move_right	bsr	right
		bra.s	no_slower_alpha
mi_no_move_r
		tst.w	pd_last_alpha(a6)
		beq.s	no_slower_alpha
		bsr	slower_alpha
no_slower_alpha

		tst.w	pd_last_strafe(a6)
;		bne.s	slower_strafestep

move_it_out

		rts

;---------------

last_vbl_count	dc.l	0

;---------------

move_jump
		move.l	d7,-(sp)

		clr.b	$1e(a1)

	; kein sprung moeglich, wenn
	; spieler gerade in einem sprung
	; sich befindet ...

		movea.l	play_dat_ptr,a6
		tst.w	pd_jump_flag(a6)
		bne.s	mj_out

	; kein sprung moeglich, wenn
	; spieler nicht auf dem
	; boden steht. dazu muss die
	; differenz zwischen tatsaechlicher
	; bodenhoehe und hoehe des spielers
	; zwischen -3 und 3 liegen ...

		move.l	pd_sh(a6),d7
		sub.l	pd_sh_real(a6),d7
		bpl.s	mj_dif_pos
		neg.l	d7
mj_dif_pos	lsr.l	#1,d7
		bne.s	mj_out

	; spieler kann jetzt springen

		move.w	#1,pd_jump_flag(a6)
		move.l	pd_sh_real(a6),pd_jump_startsh(a6)
		clr.w	pd_jump_pos(a6)
		
mj_out
		move.l	(sp)+,d7

		rts

;--------------------------------------

strafe_left
		move.w	(a0),d0			; step
		move.w	d0,step
		move.w	d0,pd_last_strafe(a6)
		move.l	pd_alpha(a6),d0
		addi.w	#$40,d0
		move.w	d0,direction
		bsr	make_walk
		bra	no_slower_alpha

strafe_right
		move.w	(a0),d0			; step
		move.w	d0,step
		neg.w	d0
		move.w	d0,pd_last_strafe(a6)
		move.l	pd_alpha(a6),d0
		subi.w	#$40,d0
		move.w	d0,direction
		bsr	make_walk
		bra	no_slower_alpha

;--------------------------------------

forward
		move.w  pd_last_step(A6),D0
                bpl.s   forward_pd_ok
                moveq   #0,D0
forward_pd_ok:  add.w   2(A0),D0
                cmp.w   (A0),D0
                blt.s   forward_ok
                move.w  (A0),D0
forward_ok:     tst.b   $001D(A1)
                bne.s   ctrl_for
		btst	#22,d7			; jagpad button a
		beq.s	no_ctrl_for
ctrl_for        lsl.w   #1,D0
no_ctrl_for:    move.w  D0,step
                move.w  D0,pd_last_step(A6)
                move.w  pd_alpha+2(A6),direction
                bsr     make_walk

                rts

backwrd:       	move.w  pd_last_step(A6),D0
                bmi.s   backward_pd_ok
                moveq   #0,D0
backward_pd_ok: neg.w   D0
                add.w   2(A0),D0
                cmp.w   (A0),D0
                blt.s   backward_ok
                move.w  (A0),D0
backward_ok:    tst.b   $001D(A1)
                bne.s   ctrl_back
		btst	#22,d7			; jagpad button a
		beq.s	no_ctrl_back
ctrl_back	lsl.w   #1,D0
no_ctrl_back:   move.w  D0,step
                neg.w   D0
                move.w  D0,pd_last_step(A6)
                move.l  pd_alpha(A6),D0
                addi.w  #$0080,D0
                move.w  D0,direction
                bsr     make_walk

                rts

;---------------

slower_step:    move.w  pd_last_step(A6),D0
                bmi.s   slower_backward

                move.w  2(A0),D1
                tst.b   $001D(A1)
                beq.s   no_ctrl_slower
                lsl.w   #1,D1
no_ctrl_slower: sub.w   D1,D0
                bmi.s   sl_step_end

                move.w  D0,pd_last_step(A6)
                move.w  D0,step
                move.l  pd_alpha+2(A6),direction
                bsr     make_walk
                rts
sl_step_end:
                clr.w   pd_last_step(A6)
                rts

slower_backward:
                neg.w   D0
                move.w  2(A0),D1
                tst.b   $001D(A1)
                beq.s   no_ctrl_slo_b
                lsl.w   #1,D1
no_ctrl_slo_b:  sub.w   D1,D0
                bmi.s   sl_step_end

                move.w  D0,step
                neg.w   D0
                move.w  D0,pd_last_step(A6)
                move.l  pd_alpha(A6),D0
                addi.w  #$0080,D0
                move.w  D0,direction
                bsr     make_walk
                rts

;---------------

left:           move.l  pd_alpha(A6),D0
                move.w  pd_last_alpha(A6),D1
                bpl.s   left_pd_ok
                moveq   #0,D1
left_pd_ok:     add.w   6(A0),D1
                cmp.w   4(A0),D1
                blt.s   left_ok
                move.w  4(A0),D1
left_ok:        tst.b   $001D(A1)
                bne.s   ctrl_left
		btst	#22,d7
		beq.s	no_ctrl_left
ctrl_left       lsl.w   #1,D1
no_ctrl_left:   move.w  D1,pd_last_alpha(A6)
		move.w	#1,has_turned
                add.w   D1,D0
                andi.w  #$00FF,D0
                move.l  D0,pd_alpha(A6)

                rts

right:          move.l  pd_alpha(A6),D0
                move.w  pd_last_alpha(A6),D1
                bmi.s   right_pd_ok
                moveq   #0,D1
right_pd_ok:    neg.w   D1
                add.w   6(A0),D1
                cmp.w   4(A0),D1
                blt.s   right_ok
                move.w  4(A0),D1
right_ok:       tst.b   $001D(A1)
                bne.s   ctrl_right
		btst	#22,d7
		beq.s	no_ctrl_right
ctrl_right      lsl.w   #1,D1
no_ctrl_right:  sub.w   D1,D0
                neg.w   D1
                move.w  D1,pd_last_alpha(A6)
		move.w	#-1,has_turned
                andi.w  #$00FF,D0
                move.l  D0,pd_alpha(A6)

                rts

;---------------

slower_alpha:   move.w  pd_last_alpha(A6),D0
                bmi.s   slower_right

                move.l  pd_alpha(A6),D1
                move.w  6(A0),D2
                tst.b   $001D(A1)
                beq.s   no_ctrl_sl_al
                lsl.w   #1,D2
no_ctrl_sl_al:  sub.w   D2,D0
                bmi.s   sl_alpha_end
                move.w  D0,pd_last_alpha(A6)
                add.w   D0,D1
                andi.w  #$00FF,D1
                move.l  D1,pd_alpha(A6)
                rts

sl_alpha_end:
                clr.w   pd_last_alpha(A6)
                rts

slower_right:   move.l  pd_alpha(A6),D1
                neg.w   D0
                move.w  6(A0),D2
                tst.b   $001D(A1)
                beq.s   no_ctrl_sl_ri
                lsl.w   #1,D2
no_ctrl_sl_ri:  sub.w   D2,D0
                bmi.s   sl_alpha_end
                sub.w   D0,D1
                neg.w   D0
                move.w  D0,pd_last_alpha(A6)
                andi.w  #$00FF,D1
                move.l  D1,pd_alpha(A6)
                rts

;---------------

; a0 = walking_data (reserviert)
; a1 = keytable (reserviert)
; d3 = key (reserviert)
; d7 = jagpad a (reserviert)

make_walk:
                lea     sinus_256_tab,A2
                move.w  direction,D0
                andi.w  #$00FF,D0
                add.w   D0,D0
                move.w  0(A2,D0.w),D1             ;sinus
                addi.w  #$0040*2,D0
                andi.w  #$01FF,D0
                move.w  0(A2,D0.w),D2             ;cosinus

                move.w  step,D0
                moveq   #14,D4

                muls    D0,D2
                asr.l   D4,D2
                add.l   pd_sx(A6),D2
                move.l  D2,sx_test

                muls    D0,D1
                asr.l   D4,D1
                add.l   pd_sy(A6),D1
                move.l  D1,sy_test

                move.w  #1,has_moved

                rts

;---------------

rm_flag		dc.w	0
