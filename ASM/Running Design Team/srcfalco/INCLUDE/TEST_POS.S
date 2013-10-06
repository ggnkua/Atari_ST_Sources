;**************************************
;* test_position
;**************************************

test_position:  

	; test auf gegenstaende nur einmalig pro bild 

	ifne ivan_debug

		move.l	#$10a,ivan_code
                bsr     test_things_con
		move.l	#$20a,ivan_code
		bsr	test_monst_con

		move.l	#$30a,ivan_code
                bsr.s   test_trains_con
		move.l	#$40a,ivan_code
                bsr     test_doors_con
		move.l	#$50a,ivan_code
                bsr     test_move_it

	else

                bsr     test_things_con
		bsr	test_monst_con

                bsr.s   test_trains_con
                bsr     test_doors_con
                bsr     test_move_it

	endc
                rts


;**************************************
; test_trains_con
;**************************************

test_trains_con

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi	test_trn_no_con

		clr.w	pd_train_hit(a6)

		movea.l	big_sector_ptr,a0
		movea.l	lev_trains(a0),a0
		movea.l	trn_move(a0),a1
		movea.l	trn_data(a0),a0

		move.w	max_trains,d7
		beq	test_trn_no_con
		subq.w	#1,d7
tt_loop
		move.w	trains_visible,d5
		move.w	max_trains,d6
		subq.w	#1,d6
		sub.w	d7,d6
		btst	d6,d5
		beq.s	train_not_hit

		movem.l	d7-a1,-(sp)
		bsr.s	test_train_now
		movem.l	(sp)+,d7-a1

		tst.w	inside_ok
		bne.s	train_not_hit

		movea.l	play_dat_ptr,a6
		move.w	#1,pd_train_hit(a6)
		movea.l	(a1),a2
		move.w	6(a1),d1		; akt. streckenabschnitt
		lsl.w	#5,d1
		adda.w	d1,a2
		tst.w	mdat_type(a2)
;		beq.s	train_hit_line

train_hit_circle

		movem.l	d0-a6,-(sp)
		move.w	#100*256,d1
		jsr	pd_health_minimieren
		movem.l	(sp)+,d0-a6
		bra.s	train_not_hit

train_hit_line

		move.w	mdat_rvec_alpha(a2),direction
		move.w	mdat_akt_gesch(a2),d0
		asr.w	#1,d0
		muls	vbl_time,d0
		move.w	d0,step

		bsr	make_walk

train_not_hit

		lea	td_data_length(a0),a0
		lea	tm_data_length(a1),a1

		dbra	d7,tt_loop


test_trn_no_con
		tst.w	test_only_if
		beq.s	test_trn_out

		clr.w	test_only_if

test_trn_out

                rts

;---------------

test_train_now

		lea	inter_ptr,a1

		move.l	a0,-(sp)
		lea	28*4(a0),a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)+
		addq.l	#8,a0
		move.l	a0,(a1)
		movea.l	a0,a1

		bsr	intersect_fouredge

		move.l	(sp)+,a0

		moveq	#1,d0
		move.w	d0,inside_ok
		cmp.w	schnitt_anz,d0
		bne.s	ttn_out

ttn_in_viereck

	; spieler befindet sich innerhalb des zug-viereckes
	; -> dritte dimension (hoehe) jetzt noch ueberpruefen ...

	; a0 = trn_data

		moveq	#0,d0
		moveq	#0,d1
		move.b	8*4+11(a0),d0		; h1
		move.b	8*4+15(a0),d1		; h2
		lsl.w	#2,d0
		lsl.w	#2,d1
		movea.l	play_dat_ptr,a6
		move.l	pd_sh(a6),d2
		cmp.l	d0,d2			; keine beruehrung, wenn
		blt.s	ttn_out			; spielerhoehe unterhalb des zuges ...
		subi.l	#player_pix_hgt*2,d2
		cmp.l	d1,d2
		bgt.s	ttn_out

		clr.w	inside_ok		; flag fuer kollision setzen

ttn_out
		rts



;**************************************
;* test_door_con
;**************************************


test_doors_con

		movea.l	play_dat_ptr,a4
		tst.w	pd_health(a4)
		bmi	test_d_sec_pre_out

		movea.l	big_sector_ptr,a2
		move.w	pd_akt_sector(a4),d0
		movea.l	lev_sec_start(a2,d0.w*4),a3
		move.l	sec_doors(a3),d0
		beq	test_d_sec_pre_out

		movea.l	d0,a5
		bsr.s	test_doors_sec

		rts

;---------------

test_doors_sec
		move.l	(a5)+,d1
		beq.s	test_doors_sec
		bmi	test_d_sec_pre_out

		movea.l	d1,a0
		clr.w	door_under(a0)

		lea	door_sec(a0),a1
		lea	inter_ptr,a0
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+
		lea	12(a1),a1
		move.l	a1,(a0)+

		bsr	intersect_fouredge

		cmpi.w	#1,schnitt_anz
		bne.s	test_doors_sec

		moveq	#0,d0
		movea.l	-4(a5),a0		; tuerpointer nochmals holen
		move.w	#1,door_under(a0)
		move.b	door_line+11(a0),d0
		sub.w	door_h1(a0),d0
		cmpi.w	#$18,d0
		bgt.s	test_d_sec_pre_out

	; spieler befindet unerlaubt sich in einem tuerbereich

		tst.w	test_only_if
		bne.s	test_doors_out

		lea	sinus_256_tab,a2
		move.w	direction,d0
		sub.w	door_angle(a0),d0
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a2,d0.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2

		move.w	d2,step
		move.w	door_angle(a0),direction
		bsr	make_walk

		bra.s	test_doors_out


test_d_sec_pre_out

		tst.w	test_only_if
		beq.s	test_doors_out

		clr.w	test_only_if

test_doors_out
		rts


;**************************************
;* test_monst_con
;**************************************


test_monst_con

		movea.l	play_dat_ptr,a4
		tst.w	pd_health(a4)
		bmi	tmc_out

		movea.l	mon_buf2_ptr,a5
		move.w	mon_buf2_anz,d7
		bmi	tmc_out

tmc_loop
		move.l	(a5)+,a0

	; nur testen, wenn gegner noch nicht gestorben ist ...

		tst.w	mon_a_died(a0)
		bne	tmc_ok

		movem.l	mon_line(a0),d0-d1		; mx/my

		sub.l	sx_test,d0
		bpl.s	tmc_xdif_pos
		neg.l	d0
tmc_xdif_pos
		move.l	#$80,d2
		cmp.l	d2,d0
		bgt	tmc_ok

		sub.l	sy_test,d1
		bpl.s	tmc_ydif_pos
		neg.l	d1
tmc_ydif_pos
		cmp.l	d2,d1
		bgt	tmc_ok

	; spieler befindet sich zu nahe am gegner ...

		tst.w	test_only_if
		bne	tmc_out

	; jetzt bestimmen, welche seite "durchlaufen" wurden ...

		lea	which_side_mem,a1
		movem.l	mon_line(a0),d0-d1

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,(a1)
		movem.l	d3-d4,48(a1)
		move.l	#$40,8(a1)

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,12(a1)
		clr.l	20(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,24(a1)
		move.l	#$c0,32(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,36(a1)
		move.l	#$80,44(a1)

		movea.l	a1,a0
		bsr	test_which_side

		lea	sinus_256_tab,a2
		move.w	direction,d1		; vorherige laufrichtung
		sub.w	d0,d1
		addi.w	#$40,d1
		andi.w	#$ff,d1
		move.w	(a2,d1.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2
		move.w	d2,step
		move.w	d0,direction

		bsr	make_walk
		bra.s	tmc_out

tmc_ok
		dbra	d7,tmc_loop

tmc_pre_out
		tst.w	test_only_if
		beq.s	tmc_out
		clr.w	test_only_if

tmc_out
		rts



;**************************************
;* test_things_con
;**************************************


test_things_con

		movea.l	play_dat_ptr,a4
		tst.w	pd_health(a4)
		bmi	ttc_out

		movea.l	big_sector_ptr,a2
		move.w	pd_akt_sector(a4),d0
		movea.l	lev_sec_start(a2,d0.w*4),a3
		move.l	sec_things(a3),d0
		beq	ttc_out

		movea.l	d0,a5

ttc_loop
		move.l	(a5)+,d1
		beq.s	ttc_loop
		bmi	ttc_pre_out

	; gegenstand nur testen, wenn typ = 0

		movea.l	d1,a0
		tst.w	thing_type(a0)
		bne.s	ttc_loop

		movem.l	thing_line(a0),d0-d1	; tx, ty

		sub.l	sx_test,d0
		bpl.s	ttc_xdif_pos
		neg.l	d0
ttc_xdif_pos
		move.w	thing_breite(a0),d2
		ext.l	d2
		cmp.l	d2,d0
		bgt.s	ttc_loop

		sub.l	sy_test,d1
		bpl.s	ttc_ydif_pos
		neg.l	d1
ttc_ydif_pos
		cmp.l	d2,d1
		bgt.s	ttc_loop

	; spieler befindet sich innerhalb des gegenstandes

		tst.w	test_only_if
		bne	ttc_out

	; jetzt bestimmen, welche seite "durchlaufen" wurden ...

		lea	which_side_mem,a1
		movem.l	thing_line(a0),d0-d1

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,(a1)
		movem.l	d3-d4,48(a1)
		move.l	#$40,8(a1)

		move.l	d0,d3
		move.l	d1,d4
		sub.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,12(a1)
		clr.l	20(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		add.l	d2,d4
		movem.l	d3-d4,24(a1)
		move.l	#$c0,32(a1)

		move.l	d0,d3
		move.l	d1,d4
		add.l	d2,d3
		sub.l	d2,d4
		movem.l	d3-d4,36(a1)
		move.l	#$80,44(a1)

		movea.l	a1,a0
		bsr.s	test_which_side

		lea	sinus_256_tab,a2
		move.w	direction,d1		; vorherige laufrichtung
		sub.w	d0,d1
		addi.w	#$40,d1
		andi.w	#$ff,d1
		move.w	(a2,d1.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2
		move.w	d2,step
		move.w	d0,direction

		bsr	make_walk
		bra.s	ttc_out

ttc_pre_out
		tst.w	test_only_if
		beq.s	ttc_out
		clr.w	test_only_if
ttc_out
		rts


;**************************************
;* test_which_side
;**************************************

; a0 = zeiger auf sein sektor_field
; d0 = winkel (rueckgabe)

test_which_side

		move.l	a0,-(sp)

		lea	inter_ptr,a1
		move.l	a0,16(a1)
		move.l	a0,(a1)+
		lea	12(a0),a0
		move.l	a0,(a1)+
		lea	12(a0),a0
		move.l	a0,(a1)+
		lea	12(a0),a0
		move.l	a0,(a1)+

		lea	test_points,a0
		movea.l	play_dat_ptr,a1
		movem.l	pd_sx(a1),d0-d1
		movem.l	d0-d1,(a0)
		movem.l	sx_test,d0-d1
		movem.l	d0-d1,8(a0)

		clr.w	schnitt_anz
		moveq	#3,d7
		lea	inter_ptr,a0

inter4which_loop

		bsr	intersect

		tst.w	schnitt_anz
		bne.s	found_side

		lea	4(a0),a0

		dbra	d7,inter4which_loop

		movea.l	(sp)+,a0
		moveq	#0,d0

		rts

found_side

		movea.l	(sp)+,a0
		moveq	#3,d6
		sub.w	d7,d6
		lsl.w	#2,d6
		move.w	d6,d7
		add.w	d6,d6
		add.w	d7,d6
		move.l	8(a0,d6.w),d0

		rts


;**************************************
;* test_move_it
;**************************************

test_move_it

		ifne ivan_debug
		move.l	#$0001050a,ivan_code
		endc

	; -----------------------------
	; der sichtbare sektor wird als
	; bereits besucht gekennzeichnet ...

		movea.l	big_sector_ptr,a6
		movea.l	lev_init_data(a6),a5
		movea.l	init_vissec_ptr(a5),a5
		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d0
		bset	#0,(a5,d0.w)

		ifne ivan_debug
		move.l	#$0002050a,ivan_code
		endc

	; -----------------------------
	; muss in diesem sektor eine aktion ausgefuehrt werden?
	; benutze immernoch a4/a6 und d0 !!!

		movem.l	d0/a4/a6,-(sp)			; zwischenspeichern

		movea.l	lev_sec_start(a6,d0.w*4),a0	; a0 = pointer sektor
		move.l	sec_aktion(a0),d1
		beq.s	tmi_aktion_out
		movea.l	d1,a0
		move.w	aktion_type(a0),d1
		beq.s	tmi_aktion_out
		tst.w	aktion_onceflag(a0)
		beq.s	tmia_make_it

	; aktion soll nur einmalig ausgefuehrt werden!
	; ist diese aktion bereits einmal ausgefuehrt worden?

		tst.w	aktion_flag(a0)
		bne.s	tmi_aktion_out

tmia_make_it

	; aktion wird nun ausgefuehrt - dazu wird ein virtueller
	; gegenstand erzeugt ...

		move.w	#1,aktion_flag(a0)
		lea	tos_thing,a1
		move.w	d1,thing_type(a1)
		movem.l	pd_sx(a4),d2-d3
		movem.l	d2-d3,thing_line(a1)

	; optionales argument nun kopieren (128 bytes) ...

		lea	aktion_optarg(a0),a2
		lea	thing_action(a1),a0
		moveq	#15,d2
tmiami_loop	move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
		dbra	d2,tmiami_loop

	; und nun die aktion ausfuehren ...

		movea.l	a1,a0

	; a0 = pointer gegenstand
	; d1 = thing_type(a0)

		lea	things_routs,a1
		move.l	-4(a1,d1.w*4),d1
		beq.s	tmi_aktion_out
		movea.l	d1,a2
		jsr	(a2)		

tmi_aktion_out

		movem.l	(sp)+,d0/a4/a6

		ifne ivan_debug
		move.l	#$0003050a,ivan_code
		endc

	; -----------------------------
	; timelimit - benutzt werden immernoch a4/a6 und d0

		movea.l	lev_timelimit(a6),a5
		tst.w	timelimit_flag(a5)
		beq.s	tmi_no_timelimit
		bmi.s	tmi_no_timelimit

		cmp.w	timelimit_sec(a5),d0
		bne.s	tmi_no_timelimit

	; timelimit wird aktiviert

		move.b	#1,pd_time_flag(a4)

		move.w	#-1,timelimit_flag(a5)
		move.l	timelimit_vbl(a5),pd_time_limit(a4)
		move.b	#$ff,pd_time_limit1+1(a4)
		move.b	#$ff,pd_time_limit2+1(a4)
		move.b	#$ff,pd_time_limit3+1(a4)
		move.b	#$ff,pd_time_limit4+1(a4)

		lea	sm_timelimit,a0
		bsr	install_message

		moveq	#2,d0
		bsr	set_colortable

tmi_no_timelimit

		ifne ivan_debug
		move.l	#$0004050a,ivan_code
		endc

	; -----------------------------
	; los gehts mit dem testen

		movea.l	play_dat_ptr,a6
                tst.w   pd_health(A6)
                bpl.s   test_move_it_now

	; -----------------------------
	; spieler ist gestorben, hoehe absenken bzw. tiefer lassen

		movea.l	pd_in_akt_ss_ptr(a6),a0
		move.l	#$38,d1
		move.w	sf_sh(a0),d0
		ext.l	d0
		bpl.s	tm_died_ok
		neg.l	d1
tm_died_ok	sub.l	d1,d0
		move.l	d0,sh_found
		bra	test_move_out

	; -----------------------------
	; jetzt koennen wir die position austesten

test_move_it_now

		ifne ivan_debug
		move.l	#$0005050a,ivan_code
		endc

		movea.l	big_sector_ptr,a0		; teste zuerst
		move.w	pd_akt_sector(a6),d0		; alle (normalen)
		movea.l	lev_sec_start(a0,d0.w*4),a0	; sektor fields
		movea.l	sec_sect(a0),a0			; des aktuellen
		bsr	test_of_inside			; sektors ...
		tst.w	inside_ok			; haben wir gueltige
		beq	test_move_out			; position -> raus

		ifne ivan_debug
		move.l	#$0006050a,ivan_code
		endc

		movea.l	big_sector_ptr,a0		; haben wir vielleicht
		move.w	pd_akt_sector(a6),d0		; ein uebergangs-
		movea.l	lev_sec_start(a0,d0.w*4),a0	; sektor field betreten
		movea.l	sec_osect(a0),a0
		bsr	test_of_inside
		tst.w	inside_ok			; nichts gefunden
		bne.s	no_sector_change		; -> verzweigen

		ifne ivan_debug
		move.l	#$0007050a,ivan_code
		endc

	; -----------------------------
	; spieler hat den sektor gewechselt

		move.w	-sf_cluster+sf_other_sec(a0),d0
		move.w	d0,pd_akt_sector(a6)		; neuen sektor eintragen
		bra	test_move_out			; und dann -> raus

	; -----------------------------
	; spieler befindet sich ein keinem zulaessigen
	; sektor field und hat auch den sektor nicht
	; gewechselt -> bewegung "an der wand lang"

no_sector_change

		ifne ivan_debug
		move.l	#$0008050a,ivan_code
		endc

		bsr	calc_side_step

	; ist der slide_step ueberhaupt erlaubt ?

		ifne ivan_debug
		move.l	#$0009050a,ivan_code
		endc

		move.w	#1,test_only_if
		bsr	test_doors_con

		ifne ivan_debug
		move.l	#$000a050a,ivan_code
		endc

		tst.w	test_only_if
		bne.s	again_not_in

		ifne ivan_debug
		move.l	#$000b050a,ivan_code
		endc

	; side step wurde berechnet und durchgefuehrt
	; teste, ob diese neue position nun wiederum
	; zulaessig ist oder nicht

		movea.l	big_sector_ptr,a0
		move.w	pd_akt_sector(a6),d0
		movea.l	lev_sec_start(a0,d0.w*4),a0
		movea.l	sec_sect(a0),a0
		bsr	test_of_inside
		tst.w	inside_ok			; position zulaessig
		beq.s	test_move_out			; -> dann raus

		ifne ivan_debug
		move.l	#$000c050a,ivan_code
		endc

		movea.l	big_sector_ptr,a0
		move.w	pd_akt_sector(a6),d0
		movea.l	lev_sec_start(a0,d0.w*4),a0
		movea.l	sec_osect(a0),a0
		bsr	test_of_inside

		ifne ivan_debug
		move.l	#$000d050a,ivan_code
		endc

		tst.w	inside_ok
		bne.s	again_not_in

	; waehrend des side steps wurde ein sektorwechsel
	; durchgefuehrt. neuen sektor eintragen und dann -> raus

		move.w	-sf_cluster+sf_other_sec(a0),d0
		move.w	d0,pd_akt_sector(a6)
		bra	test_move_out

	; -----------------------------
	; side step wurde berechnet, die position
	; ist aber nicht zulaessig

again_not_in
                movea.l	pd_in_akt_ss_ptr(a6),a0	; vorheriges sf nehmen
		move.w	sf_sh(a0),d0
		ext.l	d0
		move.l	d0,sh_found		; und die hoehe eintragen

		bsr	tmi_need_thing
		bsr	tmi_calc_sh
		bsr	tmi_calc_sh_sound

                rts

	; -----------------------------
	; die neu berechnete position ist zulaessig
	; egal ob sie eine normale bewegung ist, ein side
	; step oder ueber sektorgrenzen hinausging

test_move_out

		ifne ivan_debug
		move.l	#$000e050a,ivan_code
		endc

	; a6 = play_dat_ptr

	; -----------------------------
	; die neu berechnete spielerposition
	; ist zulaessig (bzw. spieler ist gestorben)

		movea.l	pd_akt_ss_ptr(a6),a0
		move.l	a0,pd_in_akt_ss_ptr(a6)

		movem.l	sx_test,d0-d1
		movem.l	d0-d1,pd_sx(a6)

		bsr	tmi_need_thing
		bsr	tmi_calc_sh
		bsr	tmi_calc_sh_sound

		rts

;**************************************
;* tmi_calc_sh_sound
;**************************************

; a6 = play_dat_ptr

tmi_calc_sh_sound

		lea	tcss_sh(pc),a0
		move.l	(a0),d0
		move.l	pd_sh(a6),d1
		move.l	d1,(a0)
		sub.l	d0,d1
		bpl.s	tcss_bok1
		neg.l	d1			; d1 = neue differenz
tcss_bok1
		cmp.l	8(a0),d1
		bgt.s	tcss_set_flag

		tst.w	12(a0)
		bne.s	tcss_play_it

		move.l	d1,4(a0)
		rts

tcss_play_it
		move.w	pd_jump_pos(a6),d0
		cmpi.w	#24,d0
		blt.s	tcsspi_out

		move.w	#snd_jump,d0
		moveq	#0,d1
		jsr	init_sam
tcsspi_out
		clr.w	12(a0)
		rts


tcss_set_flag
		move.w	#1,12(a0)
		move.l	d1,4(a0)

		rts

;---

tcss_sh		dc.l	0
tcss_last	dc.l	0
tcss_grenze	dc.l	8
tcss_flag	dc.w	0

;---

tmics_flag	dc.w	0

;**************************************
;* tmics_height
;**************************************

; spielerhoehe nicht automatisch festsetzen, sondern
; durch tastatureingaben -> zum debuggen

; a6 = play_dat_ptr

tmics_height
		lea	keytable,a0
		tst.b	$1b(a0)			; hoeher
		beq.s	tmicsh_no_1b
		move.w	vbl_time,d0
		lsl.w	#2,d0
		ext.l	d0
		add.l	d0,pd_sh(a6)
tmicsh_no_1b

		tst.b	$28(a0)			; tiefer
		beq.s	tmicsh_no_28
		move.w	vbl_time,d0
		lsl.w	#2,d0
		ext.l	d0
		sub.l	d0,pd_sh(a6)
tmicsh_no_28

		rts


;**************************************
;* tmi_calc_sh
;**************************************

; a6 = play_dat_ptr

tmi_calc_sh
		ifeq	final
		tst.b	keytable+$29
		beq.s	tmics_no_29
		clr.b	keytable+$29
		not.w	tmics_flag
		beq.s	tmics_on
		lea	sm_sh_off,a0
		jsr	install_message
		bra.s	tmics_no_29
tmics_on	lea	sm_sh_on,a0
		jsr	install_message
tmics_no_29
		endc

		tst.w	tmics_flag
		beq.s	tmics_normal
		bsr	tmics_height
		bra	tmics_out
tmics_normal

		move.l	sh_found,d7
		bpl.s	tmics_sh_ok
		neg.l	d7
tmics_sh_ok	move.l	d7,pd_sh_real(a6)

		tst.w	pd_jump_flag(a6)
		beq	tmics_no_jump

	; spieler befindet sich gerade in
	; einem sprung ...

		move.l	pd_jump_startsh(a6),d5
		cmp.l	pd_sh_real(a6),d5
		bge.s	tmicsj_same_sh

	; im sprung ging der spieler eine
	; treppenstufe nach oben ...

		clr.w	pd_jump_flag(a6)

		move.l	pd_sh(a6),d4
		cmp.l	pd_sh_real(a6),d4
		bgt.s	tmicsj_same_sh
		bra	tmics_no_jump
		

tmicsj_same_sh

	; gleiche bodenhoehe wie beim absprung -
	; also einfach den sprung normal durchlaufen ...

	; oder

	; im sprung ging der spieler eine
	; treppenstufe herunter - (same case) ...

		move.w	pd_jump_pos(a6),d0
		add.w	vbl_time,d0
		cmpi.w	#32,d0
		bgt	tmicsjs_jump_end

		move.w	d0,pd_jump_pos(a6)
		lea	sinus_256_tab,a4
		move.w	(a4,d0.w*8),d6
		ext.l	d6
		divu	#303,d6
		ext.l	d6
		add.l	d5,d6

	; d6 ist jetzt die neue hoehe. nun noch
	; vergleichen, ob der spieler nicht an
	; die decke gestossen ist ...

		move.w	sf_sh(a0),d5
		ext.l	d5
		subi.l	#player_pix_hgt*2,d5
		add.w	sf_height(a0),d5
		cmp.w	d5,d6
		bls.s	tmicsjs_no_decke

	; spieler ist an die decke gestossen ...

;		movem.l	d0/a4,-(sp)
;		move.w	#5*256,d1
;		bsr	pd_health_minimieren
;		movem.l	(sp)+,d0/a4

		bra	tmicsjs_jump_end

		moveq	#32,d1
		sub.w	d0,d1		; d0 = pd_jump_pos(a6)
		addq.w	#1,d1
		cmpi.w	#32,d1
		bgt.s	tmicsjs_jump_end
		move.w	d1,pd_jump_pos(a6)
		move.w	(a4,d1.w*8),d6
		lsr.w	#8,d6
		ext.l	d6
		add.l	d5,d6

tmicsjs_no_decke
		move.l	d6,pd_sh(a6)
		bra.s	tmics_out

tmicsjs_jump_end
		clr.w	pd_jump_flag(a6)
		move.l	pd_jump_startsh(a6),pd_sh(a6)

		bra.s	tmics_out

		
tmics_no_jump
		move.l	pd_sh(a6),d3
		cmp.l	d3,d7			; d7 = pd_sh_real(a6)
		bgt.s	tmicsnj_higher

	; spieler faellt herunter ...

		move.l	d3,d4
		sub.l	d7,d3
		cmpi.l	#max_sh_change*2,d3
		bgt.s	tmicsnj_too_big

		add.l	d4,d7
		lsr.l	#1,d7
		move.l	d7,pd_sh(a6)
		bra.s	tmics_out

tmicsnj_too_big
		subi.l	#max_sh_change,d4
		move.l	d4,pd_sh(a6)
		bra.s	tmics_out

tmicsnj_higher

	; spieler macht einen schritt nach oben

		add.l	d3,d7
		lsr.l	#1,d7
		move.l	d7,pd_sh(a6)

tmics_out
		rts


;-----------------------

; a6: play_dat_ptr

tmi_need_thing
		movem.l	a0/a6,-(sp)

		tst.w	pd_health(a6)
		bmi.s	tmint_out

	; brauchen wir in diesem sf einen bestimmen gegenstand ?

		moveq	#0,d7
                move.b  sf_need_thing(A0),D7
                beq	tmint_no_besitz

	; der gegenstand muss nur im besitz sein

		tst.w	pd_jump_flag(a6)
		beq.s	tmint_you_can
		cmpi.b	#7,d7
		bne.s	tmint_no_besitz
tmint_you_can	movea.l	pd_things_ptr(a6),a5
		tst.w	-4(a5,d7.w*4)
		beq.s	tmint_reduce_energy

tmint_no_besitz

	; muss in diesem sf ein gegenstand aktiviert sein ?

		moveq	#0,d7
		move.b	sf_need_act(a0),d7
		beq.s	tmint_no_activ

		tst.w	pd_jump_flag(a6)
		beq.s	tmint_you_can2
		cmpi.b	#7,d7
		bne.s	tmint_no_activ
tmint_you_can2	lea	pl_leiste_act,a5
		tst.w	-2(a5,d7.w*2)
		beq	tmint_reduce_energy		

tmint_no_activ

		move.w	sf_energy(a0),d7
		beq.s	tmint_no_bodenplatte
		bmi.s	tmint_no_bodenplatte

		movem.l	d0-a6,-(sp)
		move.w	vbl_time,d0
		mulu	#25,d0
		sub.w	d0,d7
		bpl.s	tmint_b_ok
		moveq	#0,d7
tmint_b_ok	move.w	d7,sf_energy(a0)
		jsr	th_add_health
tmint_b_out	movem.l	(sp)+,d0-a6

tmint_no_bodenplatte

tmint_out
		movem.l	(sp)+,a0/a6
		rts

tmint_reduce_energy

	; spieler wird jetzt energie gemaess sf_staerke abgezogen!

		move.w	sf_need_staerke(a0),d6
		lea	sf_staerke_tab,a1
		move.w	(a1,d6.w*2),d1
		bmi	tmintre_sofort
		mulu	vbl_time,d1
		bra.s	tmintre_ok

tmintre_sofort
		move.w	#100*256,d1

tmintre_ok
		move.w	#1,pdhm_sound_flag		; keinen sound ...
		bsr	pd_health_minimieren

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi.s	tmint_out

		tst.w	pd_invul(a6)
		bne.s	tmint_out

;		lea	pl_leiste_act,a5
;		move.w	#th_invul-1,d0
;		tst.w	(a5,d0.w*2)
;		bne.s	tmint_out

		lea	need_things_ptr,a5
		movea.l	-4(a5,d7.w*4),a0
		bsr	install_message

		movem.l	a0-a2,-(sp)
		move.w	#snd_need_thing,d0
		moveq	#0,d1
		bsr	init_sam_nd
		movem.l	(sp)+,a0-a2

		bra.s	tmint_out


;**************************************
;* test_of_inside
;**************************************

; a0 = pointer auf sector field-struktur
; a6 = play_dat_ptr

test_of_inside
		move.l	a0,d7			; nullpointer?
		beq	toi_not_possible	; ja -> raus

		move.w	(a0)+,d7		; schleifenzaehler
		bmi	toi_not_possible	; anzahl null -> raus

toi_loop
		move.l	a0,pd_akt_ss_ptr(a6)	; naechstes sektor
						; als zu testendes eintragen

		movem.l	d7-a0,-(sp)	; register retten

		lea	inter_ptr,a4	; pointer auf die
		move.l	a0,(a4)+	; vier koordinaten berechnen
		lea	12(a0),a0	; und fuer die testroutine
		move.l	a0,(a4)+	; eintragen
		lea	12(a0),a0
		move.l	a0,(a4)+
		lea	12(a0),a0
		move.l	a0,(a4)+

		bsr.s	intersect_fouredge	; testroutine (inner- oder ausserhalb?)

		movem.l	(sp)+,d7-a0		; register zurueckholen

		lea	sf_cluster(a0),a0	; sf_pointer um eines erhoehen

	; ist eine position innerhalb des vierecks moeglich

		cmpi.w	#1,schnitt_anz
		bne.s	toi_not_in_this

	; spieler kann sector_field nur betreten, wenn
	; oben genug hoehe vorhanden ist

		move.w	-sf_cluster+sf_sh(a0),d2
		ext.l	d2
		move.l	d2,sh_found
		bpl.s	toi_height_ok
		neg.l	d2
toi_height_ok	move.l	d2,d3
		sub.l	#max_sh_change,d2
		move.l	pd_sh(a6),d4
		cmp.l	d4,d2
		bgt.s	toi_not_in_this
		move.w	-sf_cluster+sf_height(a0),d1
		ext.l	d1
		subi.l	#player_pix_hgt*2,d1
		add.l	d1,d3
		cmp.l	d4,d3
		blt.s	toi_not_in_this

	; spielerposition ist in diesem
	; sector_field erlaubt ...

		clr.w	inside_ok
		rts

toi_not_in_this
		dbra	d7,toi_loop

toi_not_possible
		move.w	#1,inside_ok
		rts


;**************************************
;* intersect_fouredge
;**************************************

; inter_ptr: vier pointer auf vier koordinaten (x/y)

;*** uses d0-d3/d7/a0-a4

intersect_fouredge

	; hilfslinie erstellen (horizontale linie nach rechts vom
	; zu testenden standpunkt aus ...)

		lea	test_points,a2
		movem.l	sx_test,d0-d1
		movem.l	d0-d1,(a2)
		move.l	d1,12(a2)
		movea.l	play_dat_ptr,a4
		add.l	pd_inter_entf2(a4),d0
		move.l	d0,8(a2)

		lea	inter_ptr,a0		; erste koordinate
		move.l	(a0),16(a0)		; ist gleich der
		clr.w	schnitt_anz		; fuenften

		movea.l	(a0),a1			; ersten koordinatenpointer holen
		movem.l	(a1),d2-d3		; x1,y1
		sub.l	(a2),d2			; d2 = dx
		bpl.s	if_dx_ok
		neg.l	d2
if_dx_ok	sub.l	d1,d3			; d3 = dy
		bpl.s	if_dy_ok
		neg.l	d3
if_dy_ok	cmp.l	pd_inter_entf1(a4),d2
		bgt.s	if_out
		cmp.l	pd_inter_entf1(a4),d3
		bgt.s	if_out

		moveq	#3,d7
if_loop		bsr.s	intersect
		addq.l	#4,a0
		dbra	d7,if_loop

if_out
		rts

;**************************************
;* intersect
;**************************************

;            a0: pointer p1
;         4(a0): pointer p2
;   test_points: pointer p3
; test_points+4: pointer p4

;*** uses d0-d3/a0-a4
;*** no change of a0

intersect
		lea	test_points,a4

		movea.l	(a0),a1
		movea.l	4(a0),a2
		movea.l	a4,a3
		bsr.s	ccw
		move.w	d0,ccw_erg

		addq.l	#8,a3
		bsr.s	ccw
		muls	ccw_erg,d0
		bmi.s	inter_second

		rts

inter_second
		movea.l	a3,a2			; a2 = a4 + 4
		movea.l	a4,a1
		movea.l	(a0),a3
		bsr.s	ccw
		move.w	d0,ccw_erg

		movea.l	4(a0),a3
		bsr.s	ccw
		muls	ccw_erg,d0
		bmi.s	inter_third

		rts

inter_third
		addq.w	#1,schnitt_anz

		rts

;-----------------------

;*** a1: pointer p1
;*** a2: pointer p2
;*** a3: pointer p3

;*** uses d0-d3
;*** no change of a1-a3
;*** result d0

ccw
		movem.l	(a2),d0-d1
		movem.l	(a3),d2-d3
		sub.l	d0,d2
		sub.l	d1,d3
		sub.l	(a1),d0			; dx1
		sub.l	4(a1),d1		; dy1

		movem.w	d2-d3,ccw_temp
;                move.w  D2,ccw_temp
;                move.w  D3,ccw_temp+2

		muls	d0,d3
		muls	d1,d2

		cmp.l	d2,d3
		bmi.s	ccw_kleiner
		beq.s	ccw_gleich

ccw_groesser
		moveq	#1,d0
		rts

ccw_kleiner
		moveq	#-1,d0
		rts

ccw_gleich
		movem.w	ccw_temp,d2-d3
		muls	d0,d2
		bmi.s	ccw_kleiner
		muls	d1,d3
		bmi.s	ccw_kleiner

		muls	d0,d0
		muls	d1,d1
		muls	d2,d2
		muls	d3,d3
		add.l	d0,d1
		add.l	d2,d3
		cmp.l	d3,d2
		blt.s	ccw_groesser

		moveq	#0,d0
		rts


;**************************************
;* calc_side_step
;**************************************

; berechnung der richtung und gehen in
; der richtung, die die wand darstellt -> side step

; a6 = play_dat_ptr

calc_side_step

		bsr	css_which_line
		tst.w	inside_ok
		bmi	css_out

		movea.l	pd_in_akt_ss_ptr(a6),a0
		moveq	#12,d0
		mulu	inside_ok,d0
		adda.l	d0,a0

		lea	sinus_256_tab,a2
		move.w	direction,d0
		sub.w	10(a0),d0		; winkel der linie
		addi.w	#$40,d0
		andi.w	#$ff,d0
		move.w	(a2,d0.w*2),d2		; cosinus

		muls	step,d2
		moveq	#14,d1
		asr.l	d1,d2
		move.w	d2,step
		move.w	10(a0),direction
		bsr	make_walk

css_out
		rts


;**************************************
;* css_which_line
;**************************************

; hole das zuletzt gueltige sektor field und
; berechne, welche seite des vierecks durch-
; gangen wurde.

; a6 = play_dat_ptr

; rueckgabe: d1 = -1	Fehler
;	     d1 = 0	Seite 0
;         .. d1 = 3	Seite 3

css_which_line

		moveq	#-1,d1			; flag auf fehler setzen

		lea	test_points,a1		; aufbau der testlinie
		move.l	pd_sx(a6),(a1)		; vom alten zum neuen
		move.l	pd_sy(a6),4(a1)		; standort
		move.l	sx_test,8(a1)
		move.l	sy_test,12(a1)

		movea.l	pd_in_akt_ss_ptr(a6),a0

		moveq	#3,d6
		lea	schnitt_flags,a4
test_which_l
		lea	test_points,a1
		lea	test_points+8,a2
		movea.l	a0,a3
		bsr	ccw
		move.w	d0,ccw_erg

		lea	12(a3),a3
		bsr	ccw
		muls	ccw_erg,d0
		bmi.s	w_first_ccw_ok
		beq.s	w_first_ccw_ok

		move.b	#-1,(a4)+
		bra.s	w_all_four_lines

w_first_ccw_ok
		movea.l	a1,a3
		movea.l	a0,a1
		movea.l	a1,a2
		lea	12(a2),a2
		bsr	ccw
		move.w	d0,ccw_erg

		lea	test_points+8,a3
		bsr	ccw
		muls	ccw_erg,d0
		bmi.s	w_second_ccw_ok
		beq.s	w_second_ccw_ok

		move.b	#-1,(a4)+
		bra.s	w_all_four_lines

w_second_ccw_ok
		clr.b	(a4)+

w_all_four_lines

		lea	12(a0),a0

		dbra	d6,test_which_l


		moveq	#0,d0
		moveq	#3,d1
		lea	schnitt_flags,a4
w_test_anz
		tst.b	(a4)+
		bne.s	w_no_schnitt
		addq.w	#1,d0
		moveq	#3,d2
		sub.w	d1,d2
		move.w	d2,inside_ok
w_no_schnitt
		dbra	d1,w_test_anz

		cmpi.w	#1,d0
		beq.s	which_out_viereck

		move.w	#-1,inside_ok

which_out_viereck

		rts



;---------------

test_only_if	dc.w	0

