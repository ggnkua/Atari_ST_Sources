;---------------

pf_pts_zeiger:  DC.L 0
pf_line_zeiger: DC.L 0
pf_line_anz:    DC.W 0
pf_buf_zeiger:  DC.L 0
pf_now_color:   DC.W 0
pf_now_bits:    DC.W 0

;---------------
             
karte:       

                tst.b   keytable+$000F
                beq	karte_inline

		tst.w	cameraview_flag
		bne	karte_inline
		tst.w	menue_flag
		bne	karte_inline

		not.w	karte_flag
                beq.s   karte_ausgesch

		; karte ist jetzt eingeschaltet worden

		clr.l	mes_buf1
		clr.l	mes_buf2

		move.w	double_scan,ds_vor_karte
		move.w	cinemascope,cine_vor_karte
		move.l	true_offi,true_vor_karte

		move.l	#640,true_offi
		clr.w	double_scan
		clr.w	cinemascope
                move.w  #2,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	kact_no_vga
		move.l	#si_320x240vga,screen_init_rout_ptr
kact_no_vga	bra.s   karte_modus_ok

karte_ausgesch:
		; karte ist jetzt ausgeschaltet worden

		clr.l	mes_buf1
		clr.l	mes_buf2
	
		move.w	ds_vor_karte,double_scan
		move.w	cine_vor_karte,cinemascope
		move.l	true_vor_karte,true_offi
		bsr	install_si_routine

		move.w	#2,dont_change_scr

karte_modus_ok:

                move.w  #2,clear_it_flag
                clr.b   keytable+$000F
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_things_flag(a6)


karte_inline:
                tst.w   karte_flag
                beq	karte_inline_out
		tst.w	cameraview_flag
		bne	karte_inline_out
		tst.w	terminal_flag
		bne	karte_inline_out

                movea.l screen_1,A0
                bsr	clear_background

                tst.b   keytable+$0043
                beq.s   k_no_smaller
		move.w	vbl_time,d0
		sub.w	d0,karten_zoom
k_no_smaller:
                tst.b   keytable+$0044
                beq.s   k_no_greater
		move.w	vbl_time,d0
		add.w	d0,karten_zoom
k_no_greater:
                move.w  karten_zoom,D0
                cmpi.w  #2,D0
                bgt.s   z_not_neg
                moveq   #2,D0
z_not_neg:
                cmpi.w  #256,D0
                blt.s   z_not_high
                move.w  #256,D0
z_not_high:
                move.w  D0,karten_zoom


                tst.b   keytable+$0021
                beq.s   k_no_follow

                nop

k_no_follow:

	; follow ggf. ein- oder ausschalten

		lea	keytable,a1
		tst.b	$6b(a1)
		beq.s	kf_no_change
		clr.b	$6b(a1)
		tst.w	karte_follow
		beq.s	kf_turn_on

		lea	sm_follow_on,a0
		jsr	install_message
		clr.w	karte_follow
		bra.s	kf_no_change

kf_turn_on
		lea	sm_follow_off,a0
		jsr	install_message
		move.w	#1,karte_follow
kf_no_change

	; jetzt die mittelposition entspr. karte_follow bestimmen

		tst.w	karte_follow
		beq.s	kf_no_follow
kf_follow
		moveq	#0,d0
		moveq	#0,d1

		tst.b	$6a(a1)
		beq.s	kf_no_6a
;		clr.b	$6a(a1)
		moveq	#-8,d0		
kf_no_6a
		tst.b	$6c(a1)
		beq.s	kf_no_6c
;		clr.b	$6c(a1)
		moveq	#8,d0
kf_no_6c
		tst.b	$68(a1)
		beq.s	kf_no_68
;		clr.b	$68(a1)
		moveq	#8,d1		
kf_no_68
		tst.b	$6e(a1)
		beq.s	kf_no_6e
;		clr.b	$6e(a1)
		moveq	#-8,d1
kf_no_6e
		move.w	vbl_time,d2
		muls	d2,d0
		muls	d2,d1
		lsl.l	#3,d0
		lsl.l	#3,d1
		add.l	d0,karte_x_offi
		add.l	d1,karte_y_offi
		bra.s	kf_ok	

kf_no_follow
		movea.l	play_dat_ptr,a6
		movem.l	pd_sx(a6),d0-d1
		movem.l	d0-d1,karte_x_offi
kf_ok


                bsr     karte_now

karte_inline_out:

                rts


;**************************************
;* karte_now
;**************************************

karte_now:

	; zeichnen aller waende

		movea.l	big_sector_ptr,a2
		adda.l	#lev_sec_start,a2

		moveq	#0,d7
		move.l	screen_1,pf_buf_zeiger

kl_1
		move.l	(a2,d7.w*4),d0
		bmi.s	k_walls_out		; letzten sektor erreicht

	; sektor zeichnen, wenn th_plan aktiviert ist

		lea	pl_leiste_act,a3
		move.w	#th_plan,d1
		tst.w	-2(a3,d1.w*2)
		bne.s	kw_zeichnen

	; sektor nicht zeichnen, wenn th_litteplan nicht aktiviert ist 

		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kw_invissible

	; sektor nicht zeichnen, wenn er noch nicht betreten wurde

		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		btst	#0,(a3,d7.w)
		beq.s	kw_invissible

kw_zeichnen
		movem.l	d7/a2,-(sp)
		movea.l	d0,a3
		movea.l	sec_lines(a3),a1
		move.w	2(a1),d5		; anzahl linien
		addq.l	#4,a1
		movea.l	sec_points(a3),a2
		addq.l	#4,a2

		bsr	make_play_now

		movem.l	(sp)+,d7/a2
kw_invissible
		addq.w	#1,d7
		bra.s	kl_1

k_walls_out

;		bsr.s	karte_paint_things
;		bsr	karte_paint_schalter
		bsr	karte_paint_doors
		bsr	karte_paint_lifts
		bsr	karte_paint_trains
		bsr	karte_paint_monsters
		bsr	karte_paint_player

		rts


;---------------

karte_paint_trains:

		lea	pl_leiste_act,a1
		move.w	#th_trndetector,d0
		tst.w	-2(a1,d0.w*2)
		beq	kpt_out

                movea.l big_sector_ptr,A0
                movea.l lev_trains(A0),A0
                movea.l trn_data(A0),A2           ; lvx_trains_data

		move.w	max_trains,d7
		subq.w	#1,d7
		bmi.s	kpt_out
k_trains_loop:
                moveq	#4,d5
		lea	8*4(a2),a1

                movem.l D7/A2,-(SP)

                move.w  #%0110010010000111,pf_now_color
                bsr     make_play_now_color

                movem.l (SP)+,D7/A2

                lea     td_data_length(A2),A2
                dbra    D7,k_trains_loop

kpt_out
                rts

;---------------

karte_paint_things:

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

                moveq   #0,D7
k_sec_things_loop:
                move.l  0(A2,D7.w*4),D0
                bpl.s   k_sec_things_ok

                rts

k_sec_things_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq	no_things_in_sec

                movea.l D0,A3
                move.l  sec_things(A3),D0
                beq.s   no_things_in_sec

                movea.l D0,A3

things_in_sec_loop:
                move.l  (A3)+,D0
                bmi.s   no_things_in_sec
                movea.l D0,A0
                move.w  thing_type(A0),D0
                bmi.s   things_in_sec_loop

                movem.l D7/A2-A3,-(SP)

;                lea     things_colors(PC),A4
;                lsl.w   #1,D0
;                move.w  0(A4,D0.w),D7
                move.w  #%0100010000000100,D7

                lea     things_pts_ptr,A4
                move.l  thing_line(A0),D0
                move.l  thing_line+4(A0),D1

                move.l  D0,D2
                move.l  D1,D3
                move.w  thing_breite(A0),D4
                ext.l   D4

                move.l  D1,4(A4)                  ; y1
                move.l  D1,20(A4)                 ; y3
                move.l  D1,36(A4)
                move.l  D0,8(A4)
                move.l  D0,24(A4)
                add.l   D4,D0
                move.l  D0,16(A4)
                sub.l   D4,D2
                move.l  D2,(A4)
                move.l  D2,32(A4)
                add.l   D4,D1
                move.l  D1,12(A4)
                sub.l   D4,D3
                move.l  D3,28(A4)

                moveq   #3,D6
k_paint_thing_l:
                movem.l D6/A4,-(SP)

                move.l  (A4)+,D0
                move.l  (A4)+,D1
                move.l  (A4)+,D2
                move.l  (A4)+,D3

                bsr     linie_in_playcoord

                movem.l (SP)+,D6/A4
                addq.l  #8,A4
                dbra    D6,k_paint_thing_l

                movem.l (SP)+,D7/A2-A3

                bra.s   things_in_sec_loop

no_things_in_sec:
                addq.w  #1,D7
                bra     k_sec_things_loop


;---------------

karte_paint_schalter:

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

		moveq	#0,d7
k_sec_sch_loop:
                move.l  (A2,d7.w*4),D0
                bpl.s   k_sec_sch_ok

                rts

k_sec_sch_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_sch_in_sec

                movea.l D0,A3
                move.l  sec_schalter(A3),D0
                beq.s   no_sch_in_sec

                movea.l D0,A3

sch_in_sec_loop:
                move.l  (A3)+,D0
                bmi.s   no_sch_in_sec
                movea.l D0,A0
                move.w  thing_type(A0),D0

;                lea     schalter_colors(PC),A4
;                lsl.w   #1,D0
;                move.w  0(A4,D0.w),D7
                move.w  #%0100001000010100,D7

                lea     thing_line(A0),A4
                movem.l (A4),D0-D3

                movem.l A2-A3,-(SP)
                bsr     linie_in_playcoord
                movem.l (SP)+,A2-A3

                bra.s   sch_in_sec_loop

no_sch_in_sec:
		addq.w	#1,d7
                bra.s   k_sec_sch_loop


;---------------

; update 27/09/96

karte_paint_doors

		lea	pl_leiste_act,a3
		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kpd_out

		movea.l	big_sector_ptr,a2
		adda.l	#lev_sec_start,a2

		moveq	#0,d7

k_sec_doors_loop

		move.l	(a2,d7.w*4),d0
		bpl.s	k_sec_doors_ok

kpd_out
		rts

;---

k_sec_doors_ok

		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_doors_in_sec

		movea.l	d0,a3
		move.l	sec_doors(a3),d0
		beq.s	no_doors_in_sec

		movea.l	d0,a3

doors_in_sec_loop

		move.l	(a3)+,d0
		bmi.s	no_doors_in_sec

		movem.l	d7/a2-a3,-(sp)

		movea.l	d0,a2
		move.w	door_need_thing(a2),d7
		move.w	#%0111101111101111,d0
		cmpi.w	#th_red_key,d7
		bne.s	disl_no_red
		move.w	#%1111100000000000,d0
		bra.s	disl_now
disl_no_red	cmpi.w	#th_green_key,d7
		bne.s	disl_no_green
		move.w	#%0000011111100000,d0
		bra.s	disl_now
disl_no_green	cmpi.w	#th_blue_key,d7
		bne.s	disl_no_blue
		move.w	#%0000000111111111,d0
		bra.s	disl_now
disl_no_blue	cmpi.w	#th_yellow_key,d7
		bne.s	disl_now
		move.w	#%1111111111100000,d0

disl_now
		moveq	#4,d5
		lea	8*4(a2),a1

		move.w	d0,pf_now_color
		bsr	make_play_now_color
		movem.l	(sp)+,d7/a2-a3
		bra.s	doors_in_sec_loop

no_doors_in_sec
		addq.w	#1,d7
		bra.s	k_sec_doors_loop


;---------------

karte_paint_lifts:

		lea	pl_leiste_act,a3
		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kpl_out

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

                moveq   #0,D7

k_sec_lifts_loop:

                move.l  0(A2,D7.w*4),D0
                bpl.s   k_sec_lifts_ok
kpl_out
                rts

;---

k_sec_lifts_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_lifts_in_sec

                movea.l D0,A3
                move.l  sec_lift(A3),D0
                beq.s   no_lifts_in_sec

		movem.l	d7/a2-a3,-(sp)
                movea.l D0,A2

                moveq  	#4,d5
		lea	8*4(a2),a1

		move.w	#%0111101111101111,pf_now_color
                bsr     make_play_now_color

                movem.l (SP)+,D7/A2-A3

no_lifts_in_sec:
                addq.w  #1,D7
                bra.s   k_sec_lifts_loop


;**************************************
;* karte_paint_monsters (17/10/97)
;**************************************

karte_paint_monsters

	; sollen die gegner ueberhaupt gezeichnet werden?
	; th_mondetector nicht aufgenommen -> keine
	; gegner zeichnen...

		lea	pl_leiste_act,a1
		move.w	#th_mondetector,d0
		tst.w	-2(a1,d0.w*2)
		beq	kpm_out

	; (1) gegneranzahl (leveldaten) holen.
	; keine sichtbar -> ueberspringen

		move.w	mon_buf2_anz,d7
		bmi	kpm_no_levmonst

	; zeichnen aller standardgegner des levels
	; (ohne midi-gegner)

		movea.l	mon_buf2_ptr,a1
kpm_loop
		movea.l	(a1)+,a0

		movem.l	d7/a1,-(sp)
                lea     figur_data_buf,A1
                move.l  mon_line(A0),(A1)+
                move.l  mon_line+4(A0),(A1)+
                moveq   #0,D0
                move.b  mon_line+13(A0),D0
                move.l  D0,(A1)+
                move.w  #karte_fig_einh,(A1)+
		move.w	#%0111101111101111,d0
		tst.w	mon_a_shoot(a0)
		beq.s	kpml_no_shoot
		move.w	#%0000001111101111,d0
kpml_no_shoot	tst.w	mon_a_died(a0)
		beq.s	kpml_skip
		move.w	#%0111100000000000,d0
kpml_skip	move.w	d0,(a1)+		; farbe

                bsr.s   karte_paint_figur

                movem.l	(sp)+,d7/a1
		dbra	d7,kpm_loop
kpm_no_levmonst

	; (2) zeichnen aller midi-gegner in
	; die karte...

		ifne midiplay
		move.w	mmon_buf2_anz,d7
		bmi	kpm_no_midi
		movea.l	mmon_buf2_ptr,a1
		
kpm_midi_loop
		movea.l	(a1)+,a0
		movem.l	d7/a1,-(sp)
		lea	figur_data_buf,a1
		move.l	mon_line(a0),(a1)+
		move.l	mon_line+4(a0),(a1)+
		moveq	#0,d0
		move.b	mon_line+13(a0),d0		; alpha
		move.l	d0,(a1)+
		move.w	#karte_fig_einh,(a1)+
		move.w	#%1010010100010100,(a1)+	; farbe
                bsr.s   karte_paint_figur
                movem.l	(sp)+,d7/a1
		dbra	d7,kpm_midi_loop
kpm_no_midi
		endc

kpm_out
		rts

;-----------------------

;* zeichnet die spielerposition in die karte ein
;* farbe: weiss
;* form: dreieck

karte_paint_player:

                lea     figur_data_buf,A0

                movea.l play_dat_ptr,A6
                move.l  pd_sx(A6),(A0)+
                move.l  pd_sy(A6),(A0)+
                move.l  pd_alpha(A6),(A0)+
                move.w  #karte_fig_einh,(A0)+
                move.w  #$FFFF,(A0)+              ; farbe

                bsr.s   karte_paint_figur

                rts

;-----------------------

karte_paint_figur:

                lea     figur_data_buf,A6
                move.l  (A6),D6                   ; sx
                move.l  4(A6),D7                  ; sy
                lea     karte_player,A4
                lea     sinus_256_tab,A5

                move.w  12(A6),D2                 ; karte_fig_einheit
                moveq   #14,D3
                move.l  8(A6),D0                  ; alpha

                bsr.s   karte_player_point

                move.l  8(A6),D0
                addi.w  #$0070,D0
                bsr.s   karte_player_point

                move.l  8(A6),D0
                addi.w  #$0090,D0
                bsr.s   karte_player_point

                lea     karte_player,A4
                move.l  (A4),24(A4)
                move.l  4(A4),28(A4)

                moveq   #2,D1
karte_pp_loop:
                movem.l D1/A4,-(SP)
                move.l  (A4)+,D0
                move.l  (A4)+,D1
                move.l  (A4)+,D2
                move.l  (A4)+,D3
                move.w  14(a6),d7		; farbe
                bsr     linie_in_playcoord
                movem.l (SP)+,D1/A4
                addq.l  #8,A4

                dbra    D1,karte_pp_loop

                rts

;----

karte_player_point:

;* d0: winkel
;* d2: #karte_fig_einh
;* d3: #14
;* d6: pd_sx
;* d7: pd_sy
;* a5: sinus_256_tab
;* a4: karte_player

                move.w  #$0040,D1
                sub.w   D0,D1
                move.w  D1,D0

                lsl.w   #1,D0
                andi.w  #$01FF,D0
                move.w  0(A5,D0.w),D4             ; sinus
                addi.w  #$0080,D0
                andi.w  #$01FF,D0
                move.w  0(A5,D0.w),D5             ; cosinus

                muls    D2,D4
                muls    D2,D5
                asr.l   D3,D4
                asr.l   D3,D5
                add.l   D6,D4
                add.l   D7,D5

                move.l  D4,(A4)+
                move.l  D5,(A4)+

                rts



;**************************************
;* make_play_now
;**************************************


make_play_now

; d5/a1-a2
; pf_buf_zeiger  : zeiger auf buffer


		subq.w	#1,d5
		movea.l	pf_buf_zeiger(pc),a0
mploop
		move.w	d5,-(sp)

		move.w	2(a1),d5
		move.w	6(a1),d6
		movem.l	(a2,d5.w*4),d0/d5
		movem.l	(a2,d6.w*4),d2/d6		

		movem.l	karte_x_offi,d1/d3
		sub.l	d1,d0
		sub.l	d3,d5
		sub.l	d1,d2
		sub.l	d3,d6

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d5
		divs	d4,d2
		divs	d4,d6

		moveq	#199-100,d1
		move.w	d1,d3
		sub.w	d5,d1
		sub.w	d6,d3

		move.l	#320*2,d4

		move.w	12+2(a1),d5
		andi.w	#%0000110000000000,d5
		cmpi.w	#%0000110000000000,d5
		beq.s	mpl_11
		cmpi.w	#%0000100000000000,d5
		beq.s	mpl_10
		cmpi.w	#%0000010000000000,d5
		beq.s	mpl_01

	; alte farben

;mpl_00		move.w	#%1100001000000000,d7
;		bra.s	mploop_go_on
;mpl_10		move.w	#%0100001000000000,d7
;		bra.s	mploop_go_on
;mpl_01		move.w	#%0100001100000000,d7
;		bra.s	mploop_go_on
;mpl_11		move.w	#%1111100000000000,d7	; mit boden und decke

	; neue farben ...

mpl_00		move.w	#%0110001100001100,d7
		bra.s	mploop_go_on
mpl_10		move.w	#%1000010000010000,d7
		bra.s	mploop_go_on
mpl_01		move.w	#%1010010100010100,d7
		bra.s	mploop_go_on
mpl_11		move.w	#%1100011000011000,d7	; mit boden und decke

mploop_go_on
		addi.w	#160,d0
		addi.w	#160,d2
		bsr	linie

		lea	20(a1),a1
		move.w	(sp)+,d5
		dbra	d5,mploop

		rts


;---------------

; d5,a1-a2

make_play_now_color

		subq.w	#1,d5
		movea.l	pf_buf_zeiger(pc),a0

mploop_color
		move.w	d5,-(sp)

		move.w	2(a1),d5
		move.w	6(a1),d6
		movem.l	(a2,d5.w*4),d0/d5
		movem.l	(a2,d6.w*4),d2/d6		

		movem.l	karte_x_offi,d1/d3
		sub.l	d1,d0
		sub.l	d3,d5
		sub.l	d1,d2
		sub.l	d3,d6

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d5
		divs	d4,d2
		divs	d4,d6

		moveq	#199-100,d1
		move.w	d1,d3
		sub.w	d5,d1
		sub.w	d6,d3

		move.l	#320*2,d4
		move.w	pf_now_color(pc),d7

		addi.w	#160,d0
		addi.w	#160,d2

		bsr	linie

		lea	20(a1),a1
		move.w	(sp)+,d5
		dbra	d5,mploop_color

		rts


;---------------

linie_in_playcoord

; d0-d3: anfangs- und endpunkt
;    d7: linienfarbe

		movem.l	karte_x_offi,d5-d6
		sub.l	d5,d0
		sub.l	d5,d2
		sub.l	d6,d1
		sub.l	d6,d3

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d1
		divs	d4,d2
		divs	d4,d3

		moveq	#199-100,d4
		move.w	d4,d5
		sub.w	d1,d4
		sub.w	d3,d5

		move.w	d4,d1
		move.w	d5,d3

		addi.w	#160,d0
		addi.w	#160,d2

		move.l	#320*2,d4
		movea.l	screen_1,a0
		bsr	linie

		rts


