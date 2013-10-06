;**************************************
;* dsp_communication
;**************************************

dsp_s_all
		bsr	dsp_s_pts_lns
		bsr	dsp_s_trains
		bsr	dsp_s_monsters
		bsr	dsp_s_things
		bsr	dsp_s_schuss
		bsr	dsp_s_schalter
		bsr	dsp_s_doors
		bsr	dsp_s_lifts
		bsr	dsp_s_normal

		rts

;--------------------------------------

dsp_read
		btst	#0,$ffffa202.w
		beq.s	dsp_read
		move.l	$ffffa204.w,d0
		rts

;---------------

dsp_send
		btst	#1,$ffffa202.w
		beq.s	dsp_send
		move.l	d0,$ffffa204.w
		rts

;--------------------------------------

dsp_r_normal
		clr.w	dsp_error_flag
		clr.w	dsp_too_lame

		lea	dsp_puffer,a1
		lea	$ffffa204.w,a0
		lea	dsp_words_t,a2
		move.l	#$00ffffff,d6

drn_wait_for_texture

		btst	#0,-2(a0)
		bne.s	drn_can_send
		move.w	#1,dsp_too_lame
		bra.s	drn_wait_for_texture

drn_can_send
		move.l	(a0),d7			; anzahl oder error_flag
		cmp.l	d6,d7
		beq	dsp_error
		move.l	d7,(a2)
		subq.w	#1,d7
drn_read_texture
		move.l	(a0),(a1)+
		dbra	d7,drn_read_texture


drn_wait_for_boden

		btst	#0,-2(a0)
		beq.s	drn_wait_for_boden

		move.l	(a0),d7
		cmp.l	d6,d7
		beq	dsp_error
		move.l	d7,4(a2)
		subq.w	#1,d7
drn_read_boden
		move.l	(a0),(a1)+
		dbra	d7,drn_read_boden


drn_wait_for_mask

		btst	#0,-2(a0)
		beq.s	drn_wait_for_mask

		move.l	(a0),d7
		cmp.l	d6,d7
		beq.s	dsp_error
		move.l	d7,8(a2)
		subq.w	#1,d7
drn_read_mask
		move.l	(a0),(a1)+
		dbra	d7,drn_read_mask



drn_read_info
		bsr	dsp_read
		move.l	d0,min_entf

		bsr	dsp_read
		move.l	d0,dsp_calc_l_ii_anz

drn_read_hit
		btst	#0,-2(a0)
		beq.s	drn_read_hit
		move.l	(a0),d0
		beq.s	drn_no_hit

		subq.w	#1,d0
		move.w	d0,dsp_temp
		lea	shooted_mon,a1

drn_read_hit_loop

		btst	#0,-2(a0)
		beq.s	drn_read_hit_loop
		move.l	(a0),(a1)+
		dbra	d0,drn_read_hit_loop

drn_no_hit

		tst.w	dsp_error_flag
		beq.s	dsp_data_ok

		bsr	low_detail

dsp_data_ok

		rts


;---------------

dsp_error
		move.w	#1,dsp_error_flag
		lea	$ffffa204.w,a0
		bra.s	drn_read_info

;--------------------------------------

; rewritten 9/10/96

dsp_s_normal
		movea.l	play_dat_ptr(pc),a4
		lea	$ffffa204.w,a6

		moveq	#0,d0			; normal_flag
		bsr	dsp_send
		move.l	pd_sx(a4),(a6)
		move.l	pd_sy(a4),(a6)
		move.l	pd_sh(a4),(a6)
		move.l	pd_alpha(a4),(a6)

		move.w	pd_width(a4),d0
		ext.l	d0
		tst.w	pd_x_flag(a4)
		beq.s	width_no_x
		lsr.w	#1,d0
width_no_x	move.l	d0,(a6)

		move.w	pd_heigth(a4),d0	; hi-word ist noch null
		move.l	d0,(a6)
		move.l	pd_x_flag(a4),(a6)

		move.l	true_offi(pc),d0
		tst.w	karte_flag
		beq.s	dsn_no_karte
		move.l	true_vor_karte,d0
dsn_no_karte	move.l	d0,(a6)

		tst.w	pd_hat_gesch(a4)
		beq.s	dsn_no_shoot

	; schussweite feststellen

		lea	shoot_length,a5
		move.w	pd_mun_type(a4),d0
		move.l	(a5,d0.w*4),(a6)
		bra.s	dsn_shoot_ok
dsn_no_shoot
		clr.l	(a6)
dsn_shoot_ok

	; hintergrund animation

		move.w	vbl_count+2,d0
		lsr.w	#4,d0
		andi.l	#$ff,d0
		move.l	d0,(a6)

		rts


;**************************************
;* punkte und linien senden
;**************************************

dsp_s_pts_lns
		lea	$ffffa204.w,a6

		movea.l	big_sector_ptr(pc),a2
		lea	lev_sec_start(a2),a2

	; die "normalen" punkte und linien nur dann
	; rueberschicken, wenn sich der standsektor
	; veraendert hat	

		movea.l	play_dat_ptr(pc),a4
		move.w	pd_akt_sector(a4),d0
		cmp.w	pd_last_sector(a4),d0
		beq	dspl_out

		move.w	d0,pd_last_sector(a4)
                movea.l (A2,D0.w*4),A3
		movea.l	sec_aktion(a3),a4
		move.w	aktion_visible(a4),trains_visible
                movea.l sec_points(A3),A0
                movea.l sec_lines(A3),A1

                moveq   #%00000001,D0
                bsr     dsp_send

                move.l  (A0)+,D0
                move.l  D0,D1
                add.w   D1,D1
                move.w  D1,pts_offi
                subq.w  #1,D1

		move.l	d0,(a6)

s_pts_loop:     move.l  (a0)+,(a6)
                dbra    D1,s_pts_loop

                move.l  (A1)+,D0
                move.w  D0,D1
                lsl.w   #2,D1
                add.w   D0,D1
                subq.w  #1,D1

		move.l	d0,(a6)

s_lns_loop:     move.l  (a1)+,(a6)
                dbra    D1,s_lns_loop


                moveq   #sec_ext_lines,D7
s_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bmi	dspl_out

                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                movea.l sec_lines(A4),A1
                movea.l sec_points(A4),A0

                move.l  #%00000000000000000000000010000000,D0
                bsr     dsp_send

                move.l  (A1)+,D0
                move.w  D0,D1
                subq.w  #1,D1

                move.w  pts_offi(PC),D6

		move.l	d0,(a6)

s_ex_l_loop:    move.l  (A1)+,D0
                add.w   D6,D0
		move.l	d0,(a6)
                move.l  (A1)+,D0
                add.w   D6,D0
		move.l	d0,(a6)
                move.l  (A1)+,(a6)
                move.l  (A1)+,(a6)
                move.l  (A1)+,(a6)
                dbra    D1,s_ex_l_loop


                move.l  #%00000000000000000000000100000000,D0
                bsr     dsp_send

                move.l  (A0)+,D0
                move.w  D0,D1
                add.w   D1,D1
                add.w   D1,pts_offi
                subq.w  #1,D1

		move.l	d0,(a6)

s_ex_p_loop:    move.l  (A0)+,(a6)
                dbra    D1,s_ex_p_loop

                bra.s   s_ext_loop


dspl_out
		rts


;---------------

pts_offi:       DC.W 0


;**************************************
;* tabellen senden
;**************************************

dsp_s_table:    
                lea     $FFFFA204.w,A6

                movea.l play_dat_ptr(PC),A4

                moveq   #%00000100,D0
                move.l  D0,(A6)

                move.l  per_factor(PC),D0
                mulu    pd_width(A4),D0
                divu    #320,D0
                andi.l  #$0000FFFF,D0
                lsl.l   #3,D0
                move.l  D0,(A6)

                tst.w   pd_x_flag(A4)
                bne.s   send_table_double_x

                moveq   #0,D0
                move.w  pd_width(A4),D0
                move.w  D0,D1
                move.l  D0,(A6)

                moveq   #0,D2
                lea     winkel_320_tab(PC),A0

send_wtab_loop: move.w  D2,D3
                mulu    #320,D3
                divu    D1,D3
                move.w  D3,D5
                add.w   D5,D5

                move.w  0(A0,D5.w),D0
                ext.l   D0
                move.l  D0,(A6)

                addq.w  #1,D2
                cmp.w   D1,D2
                blt.s   send_wtab_loop

                moveq   #0,D2
                lea     tangens_tab(PC),A0

send_tab_loop:  move.w  D2,D3
                mulu    #320,D3
                divu    D1,D3
                move.w  D3,D5
                add.w   D5,D5
                add.w   D5,D5

                move.l  0(A0,D5.w),(A6)

                addq.w  #1,D2
                cmp.w   D1,D2
                blt.s   send_tab_loop

                rts


send_table_double_x:
                moveq   #0,D0
                move.w  pd_width(A4),D0
                lsr.w   #1,D0
                move.w  D0,D1
                move.l  D0,(A6)

                moveq   #0,D2
                lea     winkel_320_tab(PC),A0

                bra.s   send_wtab_loop

;---------------

per_factor:     DC.L 0


;**************************************
;* initialisierungswerte senden
;**************************************

dsp_s_init_data:

                movea.l big_sector_ptr(PC),A6
                movea.l lev_init_data(A6),A6

                move.l  #%00000000000000000000000000000010,D0
                bsr     dsp_send

                moveq   #8,D7
dsp_id_loop:
                move.l  (A6)+,D0
                bsr     dsp_send

                dbra    D7,dsp_id_loop

                rts


;**************************************
;* monster senden
;**************************************

dsp_s_monsters
		lea	$ffffa204.w,a6

		movea.l	mon_buf1_ptr(pc),a1
		move.w	mon_buf1_anz,d7
		bmi.s	dsp_sm_out

dsp_sm_loop
		movea.l	(a1)+,a0	; pointer monster

		moveq	#%00001000,d0
		bsr	dsp_send

		moveq	#5,d1		; 6 long senden
dsp_mon_loop
		move.l	(a0)+,d0
		bsr	dsp_send
		
		dbra	d1,dsp_mon_loop

		dbra	d7,dsp_sm_loop

dsp_sm_out
		rts


;**************************************
;* trains senden
;**************************************
          
dsp_s_trains:   

                lea     $FFFFA204.w,A6

                move.w  trains_visible,D7

                movea.l big_sector_ptr(PC),A0
                movea.l lev_trains(A0),A0
                movea.l trn_data(A0),A0

                moveq   #0,D6
                move.w  max_trains,D5
		beq.s	dspst_out
		subq.w	#1,d5
s_trains_loop:
                btst    D6,D7
                beq.s   train_inaktiv

                move.l  A0,-(SP)

                bsr     send_one_door

                movea.l (SP)+,A0


train_inaktiv:
                lea     td_data_length(A0),A0
                addq.w  #1,D6

                dbra    D5,s_trains_loop
dspst_out
                rts


;**************************************
;* gegenstaende senden
;**************************************

; sowohl die vordefinierten als auch
; die von gegner liegengelassenen gegenstaende

dsp_s_things:   

                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_things(A3),D1
                beq.s   send_t_no_t

                movea.l D1,A1
                bsr.s   send_things_sec

send_t_no_t:

                moveq   #sec_ext_lines,D7
things_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   things_extended

	; -----------------------------

	; und jetzt noch die gegenstaende von den
	; sichtbaren monstern senden ...

		move.w	mon_buf2_anz,d7
		bmi.s	st_out
		movea.l	mon_buf2_ptr,a6
st_left_loop
		movea.l	(a6)+,a0
		tst.w	mon_a_died(a0)
		beq.s	st_l_skip

	; monster ist gestorben, gibt es
	; einen liegengelassenen gegenstand ?
		
		move.l	mon_thing_typ(a0),d0
		beq.s	st_l_skip

		movea.l	d0,a0
		bsr.s	send_one_thing

st_l_skip
		dbra	d7,st_left_loop

st_out
		rts

;---

things_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_things(A4),D1
                beq.s   things_ext_loop

                movea.l D1,A1
                bsr.s   send_things_sec

                bra.s   things_ext_loop

;---------------

send_things_sec
                move.l  (A1)+,D0
                beq.s   send_things_sec
                bmi.s   send_things_sec_end

                movea.l D0,A0
                bsr.s   send_one_thing
                bra.s   send_things_sec

send_things_sec_end

                rts


;---------------

send_one_thing:

; a0: zeiger auf thing

		; nur senden, wenn noch nicht aufgenommen,
		; d.h. thing_type(a0) = -1, wenn aufgenommen

                tst.w   thing_type(A0)
                bmi.s   sot_out		

		; nur senden, wenn gegenstand zur
		; sichtbarkeit vorhanden ist

		tst.w	thing_vistaken(a0)
		beq.s	sot_no_vistaken

		movea.l	play_dat_ptr,a5
		movea.l	pd_things_ptr(a5),a5
		move.w	thing_vistaken(a0),d0
		tst.w	-4(a5,d0.w*4)
		beq.s	sot_out

sot_no_vistaken
		; nur senden, wenn gegenstand zur
		; sichtbarkeit aktiviert ist

		tst.w	thing_visact(a0)
		beq.s	sot_no_visact

		lea	pl_leiste_act,a5
		move.w	thing_visact(a0),d0
		tst.w	-2(a5,d0.w*2)
		beq.s	sot_out

sot_no_visact
		bra.s	send_one_thing_now
sot_out
                rts

send_one_thing_now:
                move.l  #%00000000000000000000001000000000,D0
                bsr     dsp_send

                adda.l  #thing_line,A0

                moveq   #4,D1
send_thing_loop	move.l  (A0)+,D0
                bsr     dsp_send

                dbra    D1,send_thing_loop

                rts


;**************************************
;* schussanimation senden
;**************************************

dsp_s_schuss
		movea.l	play_dat_ptr,a4
		lea	$ffffa204.w,a6
		lea	as_thing,a5

		moveq	#3,d7
dsp_ss_loop	
		tst.w	pd_as_send_flag(a4,d7.w*2)
		beq.s	dsp_ss_skip

		clr.w	pd_as_send_flag(a4,d7.w*2)

		move.l	#%1000000000,d0
		bsr	dsp_send

		movea.l	(a5,d7.w*4),a0
		moveq	#4,d1
send_schus_loop	move.l	(a0)+,d0
		bsr	dsp_send
		dbra	d1,send_schus_loop

dsp_ss_skip
		dbra	d7,dsp_ss_loop

		rts


;**************************************
;* schalter senden
;**************************************

dsp_s_schalter: 
                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_schalter(A3),D1
                beq.s   send_s_no_s

                movea.l D1,A1
                bsr.s   send_schalt_sec

send_s_no_s:

                moveq   #sec_ext_lines,D7
schalt_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   schalt_extended

                rts


schalt_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_schalter(A4),D1
                beq.s   schalt_ext_loop

                movea.l D1,A1
                bsr.s   send_schalt_sec

                bra.s   schalt_ext_loop

;---------------

send_schalt_sec:
                move.l  (A1)+,D0
                beq.s   send_schalt_sec
                bmi.s   send_schalt_sec_end

                movea.l D0,A0
                bsr.s   send_one_schalt
                bra.s   send_schalt_sec

send_schalt_sec_end:

                rts


;---------------

send_one_schalt:

		; nur senden, wenn gegenstand zur
		; sichtbarkeit vorhanden ist

		tst.w	sch_vistaken(a0)
		beq.s	sos_no_vistaken

		movea.l	play_dat_ptr,a5
		movea.l	pd_things_ptr(a5),a5
		move.w	sch_vistaken(a0),d0
		tst.w	-4(a5,d0.w*4)
		beq.s	sos_out

sos_no_vistaken
		; nur senden, wenn gegenstand zur
		; sichtbarkeit aktiviert ist

		tst.w	sch_visact(a0)
		beq.s	sos_no_visact

		lea	pl_leiste_act,a5
		move.w	sch_visact(a0),d0
		tst.w	-2(a5,d0.w*2)
		beq.s	sos_out

sos_no_visact
		bra.s	send_one_schalter_now
sos_out
                rts

;---

send_one_schalter_now

                moveq   #%00010000,D0
                bsr     dsp_send

                adda.l  #sch_line,A0

                moveq   #6,D1
sos_loop:       move.l  (A0)+,D0
                bsr     dsp_send
                dbra    D1,sos_loop

                rts

                
;**************************************
;* tueren senden
;**************************************

dsp_s_doors:    
                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_doors(A3),D1
                beq.s   send_d_no_d

                movea.l D1,A1
                bsr.s   send_doors_sec

send_d_no_d:

                moveq   #sec_ext_lines,D7
doors_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   doors_extended

                rts


doors_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_doors(A4),D1
                beq.s   doors_ext_loop

                movea.l D1,A1
                bsr.s   send_doors_sec

                bra.s   doors_ext_loop

;---------------

send_doors_sec:
                move.l  (A1)+,D0
                beq.s   send_doors_sec
                bmi.s   send_doors_sec_end

                movea.l D0,A0
                bsr.s   send_one_door
                bra.s   send_doors_sec

send_doors_sec_end:

                rts


;---------------

send_one_door:

; a0: zeiger auf door_linie (7 longs)

                moveq   #%00100000,D0
                bsr     dsp_send

                adda.l  #door_pts,A0

                moveq   #7,D1
send_door_pts:  move.l  (A0)+,D0
                bsr     dsp_send
                dbra    D1,send_door_pts

                moveq   #19,D1
send_door_line: move.l  (A0)+,D0
                bsr     dsp_send
                dbra    D1,send_door_line

                rts

 
;**************************************
;* lifte senden
;**************************************

dsp_s_lifts:    
                lea     $FFFFA204.w,A6

                movea.l big_sector_ptr(PC),A2
                adda.l  #lev_sec_start,A2

                movea.l play_dat_ptr(PC),A4
                move.w  pd_akt_sector(A4),D0

                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                move.l  sec_lift(A3),D1
                beq.s   send_l_no_l

                movea.l D1,A1
                bsr.s   send_lift_sec

send_l_no_l:

                moveq   #sec_ext_lines,D7
lifts_ext_loop:
                move.w  0(A3,D7.w),D6
                tst.w   D6
                bpl.s   lifts_extended

                rts


lifts_extended:
                addq.w  #2,D7

                lsl.w   #2,D6
                movea.l 0(A2,D6.w),A4
                move.l  sec_lift(A4),D1
                beq.s   lifts_ext_loop

                movea.l D1,A1
                bsr.s   send_lift_sec

                bra.s   lifts_ext_loop

;---------------

send_lift_sec:

; a1: zeiger auf lift

                moveq   #%00100000,D0
                bsr     dsp_send

                adda.l  #lift_pts,A1

                moveq   #7,D1
send_lift_pts:  move.l  (A1)+,D0
                bsr     dsp_send
                dbra    D1,send_lift_pts

                moveq   #19,D1
send_lift_line: move.l  (A1)+,D0
                bsr     dsp_send
                dbra    D1,send_lift_line

no_lift_to_send:
                rts



dsp_temp:	dc.w	0

