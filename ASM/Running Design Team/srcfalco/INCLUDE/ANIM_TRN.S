;**************************************
;* animate_trains
;**************************************

animate_trains

		clr.w	at_calc_again

		movea.l	big_sector_ptr,a0
		movea.l	lev_trains(a0),a0
		movea.l	trn_data(a0),a6
		movea.l	trn_move(a0),a0

		move.w	max_trains,d0
		beq	at_out
		subq.w	#1,d0

at_loop
		movem.l	d0/a0/a6,-(sp)

		move.w	max_trains,d1
		subq.w	#1,d1
		sub.w	d0,d1
		move.w	trains_aktive,d2
		btst	d1,d2
		beq.s	at_not_activ

		bsr.s	anim_train_now
at_not_activ
		movem.l	(sp)+,d0/a0/a6


		tst.w	at_calc_again
		beq.s	at_not_again
		clr.w	at_calc_again
		bra.s	at_loop

at_not_again

		lea	tm_data_length(a0),a0
		lea	td_data_length(a6),a6

		dbra	d0,at_loop


at_out
		rts

;-----------------------

at_calc_again	dc.w	0

;-----------------------

; a0 = trn_move
; a6 = trn_data

anim_train_now:

		movea.l	tm_pointer_mdat(a0),a1	; trn_move kopieren

		move.w	tm_abschnitt(a0),d0	; streckenabschnitt
		lsl.w	#5,d0
		adda.w	d0,a1

		tst.w	mdat_type(a1)
		beq	atn_linie

;---

atn_circle
		move.w	tm_distance(a0),d0		; aktueller winkel
		move.w	mdatc_winkelgeschw(a1),d1	; drehgeschwindigkeit
		mulu	vbl_time,d1
		add.w	d1,d0

		move.w	mdatc_winkel_anz(a1),d2
		bpl.s	atnc_pos
		neg.w	d2
atnc_pos	cmp.w	d2,d0
		blt.s	atnc_circ_no_end

		clr.w	tm_distance(a0)
		move.w	tm_abschnitt(a0),d0
		addq.w	#1,d0
		cmp.w	tm_abschnitt_anz(a0),d0
		blt.s	atnc_nend
		moveq	#0,d0
atnc_nend	move.w	d0,tm_abschnitt(a0)
		move.w	#1,at_calc_again
		bra	atn_out

atnc_circ_no_end
		move.w	d0,tm_distance(a0)

		tst.w	mdatc_winkel_anz(a1)
		bmi.s	atnccne_neg
		move.w	mdatc_winkel_start(a1),d5
		sub.w	d0,d5
		move.w	d5,d0
		bra.s	atnccne_ok
atnccne_neg	add.w	mdatc_winkel_start(a1),d0
atnccne_ok	
		move.w	d0,d1
		asr.w	#4,d0
		lea	sinus_256_tab,a5
		andi.w	#$ff,d0
		move.w	(a5,d0.w*2),d5		; sinus
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a5,d0.w*2),d4		; cosinus

		move.w	d1,d0
		asr.w	#4,d0
		addq.w	#1,d0
		andi.w	#$ff,d0
		move.w	(a5,d0.w*2),d7		; sinus
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a5,d0.w*2),d6		; cosinus

		sub.w	d4,d6
		sub.w	d5,d7
		andi.w	#%1111,d1
		muls	d1,d6
		muls	d1,d7
		asr.l	#4,d6
		asr.l	#4,d7
		add.w	d6,d4
		add.w	d7,d5

		muls	mdatc_radius(a1),d4
		muls	mdatc_radius(a1),d5
		lsl.l	#2,d4
		lsl.l	#2,d5
		swap	d4
		swap	d5
		ext.l	d4
		ext.l	d5
		add.l	mdatc_x(a1),d4
		add.l	mdatc_y(a1),d5
		move.w	mdatc_winkel_start(a1),d6
		move.w	tm_distance(a0),d0
		tst.w	mdatc_winkel_anz(a1)
		bmi.s	atnccnes_neg
		sub.w	d0,d6
		asr.w	#4,d6
		subi.w	#$40,d6
		bra.s	atnccnes_ok
atnccnes_neg	add.w	d0,d6
		asr.w	#4,d6
		addi.w	#$40,d6
atnccnes_ok
		move.l	a6,-(sp)
		bsr	calc_train_position
		bsr	calc_train_sec_position
		movea.l	(sp)+,a6

		bra	atn_out

;---

atn_linie
		moveq	#0,d3
		move.w	mdat_akt_gesch(a1),d4

		tst.w	mdat_anh_flag(a1)
		beq.s	atnl_kein_anhalten
		tst.w	mdat_besch_flag(a1)
		bne.s	atnl_zug_beschleunigt

		move.w	d4,d0			; akt. geschwindigkeit
		move.w	vbl_time,d1
		move.w	d1,d3
		addq.w	#1,d3
		mulu	d1,d3			; x = (n*(n+1))/2
		lsr.w	#1,d3
		neg.w	d3
		sub.w	d1,d0
		bpl.s	atnl_noch_verzoegern
		clr.w	mdat_anh_count(a1)
		move.w	#1,mdat_besch_flag(a1)
		moveq	#0,d0
		moveq	#0,d3
atnl_noch_verzoegern
		move.w	d0,mdat_akt_gesch(a1)
		bra.s	atnl_kein_anhalten

atnl_zug_beschleunigt
		move.w	mdat_anh_count(a1),d0
		cmp.w	mdat_anh_time(a1),d0
		bgt.s	atnl_jetzt_beschl

		move.w	vbl_time,d0
		add.w	d0,mdat_anh_count(a1)
		bra.s	atnl_kein_anhalten

atnl_jetzt_beschl
		move.w	d4,d0
		move.w	vbl_time,d1
		move.w	d1,d3
		addq.w	#1,d3
		mulu	d1,d3
		lsr.w	#1,d3
		add.w	d1,d0
		cmp.w	mdat_norm_gesch(a1),d0
		blt.s	atnl_noch_beschl
		move.w	mdat_norm_gesch(a1),d0
		moveq	#0,d3
atnl_noch_beschl
		move.w	d0,mdat_akt_gesch(a1)

atnl_kein_anhalten

		move.w	tm_distance(a0),d2	; zurueckgelegte distanz
		move.w	d4,d1
		mulu	vbl_time,d1
		add.w	d3,d1			; aus beschl / anhalten
		asr.w	#1,d1
		add.w	d1,d2
		cmp.w	mdat_rvec_len(a1),d2
		ble.s	atnl_no_anim_end

		move.w	mdat_norm_gesch(a1),mdat_akt_gesch(a1)
		clr.w	mdat_besch_flag(a1)
		clr.w	tm_distance(a0)
		move.w	tm_abschnitt(a0),d0
		addq.w	#1,d0
		cmp.w	tm_abschnitt_anz(a0),d0
		blt.s	atnl_anim_no_end

		moveq	#0,d0
atnl_anim_no_end
		move.w	d0,tm_abschnitt(a0)
		move.w	#1,at_calc_again
		bra	atn_out

atnl_no_anim_end

		move.w	d2,tm_distance(a0)
		move.w	d2,d0

		move.w	mdat_rvec_x(a1),d1
		muls	d0,d1
		divs	mdat_rvec_len(a1),d1
		ext.l	d1

		move.w	mdat_rvec_y(a1),d2
		muls	d0,d2
		divs	mdat_rvec_len(a1),d2
		ext.l	d2

		movem.l	mdat_anfang_x(a1),d4-d5
		add.l	d1,d4
		add.l	d2,d5
		move.w	mdat_rvec_alpha(a1),d6

		move.l	a6,-(sp)
		bsr.s	calc_train_position
		bsr.s	calc_train_sec_position
		movea.l	(sp)+,a6

atn_out
		rts

;-----------------------

; d4 = x
; d5 = y
; d6 = winkel
; a6 = trn_data

calc_train_position

		lea	45(a6),a5		; 8 * 4 + 13
		move.w	#$40,d0
		move.w	d6,d1
		addi.b	#$80,d1
		moveq	#3,d2
ctp_loop	
		move.b	d1,(a5)
		add.b	d0,d1
		lea	5*4(a5),a5
		dbra	d2,ctp_loop


                lea     sinus_256_tab,A5
                andi.w  #$00FF,D6
                add.w   D6,D6
                move.w  0(A5,D6.w),D0             ; sinus
                add.w   #$0080,D6
                andi.w  #$01FF,D6
                move.w  0(A5,D6.w),D1             ; cosinus

		move.w	tm_dy(a0),d6
		move.w	tm_dx(a0),d7

                bsr.s   calc_train_position_now

                rts

;---

calc_train_sec_position:

                lea     sinus_256_tab,A5
                andi.w  #$00FF,D6
                add.w   D6,D6
                move.w  0(A5,D6.w),D0             ; sinus
                add.w   #$0080,D6
                andi.w  #$01FF,D6
                move.w  0(A5,D6.w),D1             ; cosinus

		move.w	tm_dy(a0),d6
		move.w	tm_dx(a0),d7
		addi.w	#$20,d6
		addi.w	#$20,d7

                lea     20*4(A6),A6

                bsr.s   calc_train_position_now

                rts

;---

;* d4 : xm
;* d5 : ym
;* d6 : x-radius
;* d7 : y-radius

calc_train_position_now:

                move.w  D6,D2
                move.w  D7,D3

                bsr.s   calc_tpos_now

                move.w  D6,D2
                move.w  D7,D3
		neg.w	d3

                bsr.s   calc_tpos_now

                move.w  D6,D2
                move.w  D7,D3
                neg.w   D2
		neg.w	d3

                bsr.s   calc_tpos_now

                move.w  D6,D2
                move.w  D7,D3
                neg.w   D2

                bsr.s   calc_tpos_now

                rts
;----

calc_tpos_now

		movem.w	d2-d3,-(sp)

		muls	d0,d3
		muls	d1,d2
		add.l	d2,d3
		lsl.l	#2,d3
		swap	d3
		ext.l	d3
		add.l	d4,d3
		move.l	d3,(a6)+

		movem.w	(sp)+,d2-d3
		muls	d0,d2
		muls	d1,d3
		sub.l	d3,d2
		lsl.l	#2,d2
		swap	d2
		ext.l	d2
		add.l	d5,d2
		move.l	d2,(a6)+

		rts


