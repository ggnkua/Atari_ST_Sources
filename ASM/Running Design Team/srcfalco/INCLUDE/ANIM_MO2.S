;**************************************
;* animate_monster
;**************************************

; monster animation
; version 2.0 (w) 01.04.96
; version 2.2 (w) 16.03.97

animate_monster
		movea.l	big_sector_ptr,a0
		movea.l	lev_monsters(a0),a0
		movea.l	mon_sdat(a0),a0		; a0 = mon_sdat
		movea.l	mon_buf2_ptr,a1
		move.w	mon_buf2_anz,d7
		bmi.s	am_out

am_loop
		movea.l	(a1)+,a2

		movem.l	d7/a1,-(sp)
		bsr	anim_one_monst
		bsr	anim_one_monst_shoot
		movem.l	(sp)+,d7/a1

		dbra	d7,am_loop

am_out
		rts

;---------------

; a0 : zeiger auf mon_sdat
; a2 : zeiger auf ein monster

anim_one_monst_shoot

		tst.w	mon_a_died(a2)
		bne	aoms_out

	; keine schuesse von zivilisten ...

		tst.w	mon_zivilist(a2)
		bpl	aoms_out

	; keine schuesse wenn mon_sht_time1 gleich -1 ist

		cmpi.w	#-1,mon_sht_time1(a2)
		beq	aoms_out

	; dann die zeit bis zum naechsten schuss herunterzaehlen

		move.w	mon_sht_count(a2),d0
		sub.w	vbl_time,d0
		move.w	d0,mon_sht_count(a2)
		bpl	aoms_out

	; neue zeit bis zum naechsten schuss
	; bestimmen aus mon_sht_time1 und
	; mon_sht_time2

		move.w	mon_sht_time2(a2),d0
		sub.w	mon_sht_time1(a2),d0
		bsr	get_zufall_256
		mulu	d1,d0
		lsr.l	#8,d0
		add.w	mon_sht_time1(a2),d0
		move.w	d0,mon_sht_count(a2)

	; wenn spieler gestorben, keine
	; schuesse mehr

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi	aoms_out

	; wenn spieler unsichtbar, auch
	; keinen schuss abgeben ...

		tst.w	pd_invis(a6)
		bne	aoms_out

		lea	pl_leiste_act,a5
		move.w	#th_invis-1,d0
		tst.w	(a5,d0.w*2)
		bne	aoms_out

		move.w	mon_shoot_typ(a2),d0	; -1 = kein schuss
		bmi	aoms_out

		btst	#1,d0			; seitdem getroffen ?
		beq.s	aoms_getroffen_sein_ok
		btst	#4,d0			; flag bereits getroffen
		beq	aoms_out

aoms_getroffen_sein_ok

		btst	#2,d0
		beq.s	aoms_in_aktionradius_ok
                movem.l mon_line(A2),D0-D1
                bsr     calc_dist_to_player
		move.w	mon_sht_actrad(a2),d1
		ext.l	d1
		cmp.l	d1,d0
		bgt	aoms_out
		move.w	mon_shoot_typ(a2),d0	; restaurieren
		
aoms_in_aktionradius_ok

		btst	#3,d0
		beq.s	aoms_vorwaerts_ok
		movea.l	play_dat_ptr,a6
		move.b	mon_line+13(a2),d1	; alpha monster
		addi.b	#$80,d1
		sub.b	pd_alpha+3(a6),d1
		bpl.s	aomsv_positiv
		neg.b	d1
aomsv_positiv	cmpi.b	#$20,d1
		bgt	aoms_out

aoms_vorwaerts_ok

	; keinen schuss abgeben, solange monster noch
	; selbst schiesst, gerade getroffen wird oder
	; stirbt bzw. gestorben ist ...

		tst.w	mon_a_shoot(a2)
		bne.s	aoms_out
		tst.w	mon_a_died(a2)
		bne.s	aoms_out
		tst.w	mon_a_hit(a2)
		bne.s	aoms_out
		move.w  #1,mon_a_shoot(a2)

aoms_out
		rts

;---------------

; gebrauchte register werden gerettet ...
; rueckgabe: d1.w : Zufallszahl zwischen 0 und 255

get_zufall_256
		move.l	a0,-(sp)
		lea	zufall_256_tab,a0
		move.w	zuf256_pos(pc),d1
		addq.b	#1,d1
		move.w	d1,zuf256_pos
		move.b	0(a0,d1.w),d1
		movea.l	(sp)+,a0

		rts

zuf256_pos	dc.w	0


;**************************************
;* anim_one_monst
;**************************************

; a0 = zeiger auf mon_sdat
; a2 = zeiger auf ein monster

anim_one_monst

		move.w	mon_sec(a2),d0
		movea.l	big_sector_ptr,a1
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_aktion(a1),a1
		move.w	aktion_mlanz(a1),d0
		cmp.w	mon_sec_dir(a2),d0
		ble.s	aom_no_walk

	; wenn monster gerade stirbt, getroffen wird oder
	; selbst schiesst, dann keine bewegung

		tst.w	mon_a_died(a2)
		bne.s	aom_no_walk
		tst.w	mon_a_hit(a2)
		bne.s	aom_no_walk
		tst.w	mon_a_shoot(a2)
		bne.s	aom_no_walk

		tst.b	mon_walking_typ(a2)
		bmi	aom_set_position

		movem.l	mon_line(a2),d0-d1
		bsr	calc_dist_to_player

	; ist das monster in einem $180 radius um
	; den spieler, dann keine bewegung ...

		cmpi.l	#$180,d0
		blt.s	aom_no_walk

		cmp.l	mon_act_radius(a2),d0
		blt.s	aom_intel_walk

	; jetzt einfach entlang den vorbestimmten
	; linien laufen ...

		bsr	anim_walk_one_step
		bra.s	aom_no_walk

aom_set_position
		movea.l	big_sector_ptr,a1
		move.w	mon_sec(a2),d0
		movea.l	lev_sec_start(a1,d0.w*4),a1
		movea.l	sec_mon_line(a1),a1
		move.w	mon_sec_dir(a2),d0
		movea.l	(a1,d0.w*8),a1
		movem.l	(a1),d0-d1
		movem.l	d0-d1,mon_line(a2)
		move.b	9(a1),8+3(a2)		; hoehe

aom_no_walk
		bsr	anim_one_monst_now

		rts

;---------------

aom_intel_walk
		move.w	mon_react_count(a2),d0
		sub.w	vbl_time,d0
		bpl.s	aomiw_no_intel

	; wenn spieler unsichtbar ist, dann
	; nicht auf spieler reagieren ...

		movea.l	play_dat_ptr,a5
		tst.w	pd_invis(a5)
		bne	aomiw_no_intel

		lea	pl_leiste_act,a5
		move.w	#th_invis-1,d0
		tst.w	(a5,d0.w*2)
		bne	aomiw_no_intel

                bsr.s   anim_intelligent_walk
		move.w	mon_react_time(a2),d0		
		bsr	get_zufall_256
		lsr.w	#3,d1
		subi.w	#16,d1
		add.w	d1,d0
		

aomiw_no_intel
		move.w	d0,mon_react_count(a2)
		bsr	anim_walk_one_step

                bsr     anim_one_monst_now

                rts

;---------------

;* a0 : Zeiger auf mon_sdat
;* a2 : Zeiger auf ein monster

anim_intelligent_walk:

                lea     sinus_256_tab,A4
                moveq   #0,D1
                move.b  mon_line+13(A2),D1        ; aktueller alpha
                add.w   D1,D1
                addi.w  #$0080,D1
                andi.w  #$01FF,D1
                move.w  0(A4,D1.w),D3             ; sinus = dy2
                addi.w  #$0080,D1
                andi.w  #$01FF,D1
                move.w  0(A4,D1.w),D2             ; cosinus = dx2

                movem.l mon_line(A2),D4-D5
                movea.l play_dat_ptr,A3
                sub.l   pd_sx(A3),D4              ; dx1
                sub.l   pd_sy(A3),D5              ; dy1

                muls    D3,D4                     ; dx1 * dy2
                muls    D2,D5                     ; dx2 * dy1
                cmp.l   D4,D5
                bgt     aiw_same_dir

                bchg    #0,mon_walk_dir+1(A2)

aiw_same_dir:

		rts

;--------------------------------------

; a0 : Zeiger auf mon_sdat
; a2 : Zeiger auf ein monster

; bewegt ein monster einen schritt entlang der definierten linien

anim_walk_one_step

		movea.l	big_sector_ptr,a3
		move.w	mon_sec(a2),d1
		movea.l	lev_sec_start(a3,d1.w*4),a3
		movea.l	sec_mon_line(a3),a3
		move.w	mon_sec_dir(a2),d1
		movea.l	(a3,d1.w*8),a3

	; a3 = anfang der strecke, auf der sich
	;      das monster bewegt ...

		move.w	mon_sec_line(a2),d2
		lsl.w	#4,d2

		lea	walking_data,a4
		move.w	vbl_time,d1
		move.w	(a4,d1.w*8),d3		; step

	; monster bewegen sich mit halber geschwindigkeit

		asr.w	#1,d3

		tst.w	mon_walk_dir(a2)
		beq.s	awos_forward
		neg.w	d3
awos_forward

		add.w	mon_sec_dist(a2),d3	; dist + step
		bpl.s	awos_dist_pos

	; monster hat den anfang einer einzelnen
	; linie unterschritten ...

		moveq	#0,d3

	; walking_typ: 0 = umkehren (d.h. nur auf dieser linie bewegen)
	;              1 = nicht umkehren

		tst.b	mon_walking_typ(a2)
		bne	awos_line_back

	; monster muss also umkehren
	; laufrichtung also wieder vorwaerts ...

		clr.w	mon_walk_dir(a2)	; laufrichtung wieder vorwaerst
		bra	awos_not_end

awos_dist_pos

	; jetzt die distanz auf dieser linie nach
	; oben ueberpruefen

		cmp.w	ml_length(a3,d2.w),d3
		blt.s	awos_not_end

	; monster hat das ende der linie ueberschritten

		move.w	ml_length(a3,d2.w),d3

		tst.b	mon_walking_typ(a2)
		bne	awos_line_forw

	; monster muss also umkehren
	; laufrichtung also wieder rueckwaerts ...

		move.w	#1,mon_walk_dir(a2)	; laufrichtung wieder rueckwaerst

awos_not_end
		move.w	d3,mon_sec_dist(a2)	; neue distanz

	; jetzt die genaue position berechnen ...

		move.w	mon_sec_line(a2),d2
		lsl.w	#4,d2
		movem.l	ml_x(a3,d2.w),d5-d6	; x,y
		move.w	10(a3,d2.w),d4		; alpha

		lea	sinus_256_tab,a4
		move.w	(a4,d4.w*2),d0		; sinus
		addi.w	#$40,d4
		andi.w	#$ff,d4
		move.w	(a4,d4.w*2),d1		; cosinus

		muls	d3,d0
		muls	d3,d1
		moveq	#14,d3
		asr.l	d3,d0
		asr.l	d3,d1
		add.l	(a3,d2.w),d1		; x_neu
		add.l	4(a3,d2.w),d0		; y_neu
		exg.l	d0,d1
		movem.l	d0-d1,mon_line(a2)	; und die werte eintragen

		move.b	ml_alpha(a3,d2.w),d1	; alpha
		tst.w	mon_walk_dir(a2)
		beq.s	awos_alpha_ok
		addi.b	#$80,d1
awos_alpha_ok	move.b	d1,mon_line+13(a2)
		move.b	ml_sh(a3,d2.w),mon_line+11(a2)	; sh

		rts

;---------------

; a0: sdat
; a2: zeiger auf monster
; a3: zeiger auf mon_dir_lines (anfang)
; d2: mon_sec_line * 16
; d3: mon_sec_dist


awos_line_forw

		addi.w	#16,d2
		tst.w	ml_length(a3,d2.w)
		beq	awoslf_new_sector

	; nur innerhalb des sektors eine
	; linie vorwaerts

		addq.w	#1,mon_sec_line(a2)
		moveq	#0,d3			; dist

		bra	awos_not_end

awoslf_new_sector

	; a6 = ptr uebergangspunkt

		lea	(a3,d2.w),a6

		movea.l	big_sector_ptr,a4
		move.w	mon_sec(a2),d1
		movea.l	lev_sec_start(a4,d1.w*4),a4
		movea.l	sec_mon_line(a4),a4
		move.w	mon_sec_dir(a2),d1
		movea.l	ml_ptr(a4,d1.w*8),a5
		move.w	ml_sektor_nach(a4,d1.w*8),an_mon_new_sec

		move.w	d3,an_mon_new_dis

		bra	awos_sec_chg

;---------------

awos_line_back
		subi.w	#16,d2
		bmi	awoslb_new_sector

		; nur innerhalb des sektors eine
		; linie rueckwaerts

		subq.w	#1,mon_sec_line(a2)
		move.w	ml_length(a3,d2.w),d3		; dist

		bra	awos_not_end

awoslb_new_sector

		lea	(a3),a6				; ptr. uebergangspunkt

		movea.l	big_sector_ptr,a4
		move.w	mon_sec(a2),d4
		movea.l	lev_sec_start(a4,d4.w*4),a4
		movea.l	sec_mon_line(a4),a4
		move.w	mon_sec_dir(a2),d1
		movea.l	ml_ptr(a4,d1.w*8),a5
		move.w	ml_sektor_von(a4,d1.w*8),an_mon_new_sec

		move.w	d3,an_mon_new_dis


; a2             = pointer monster
; a6             = pointer uebergangspoints
; an_mon_new_sec = neuer sektor
; an_mon_new_dis = zurueckgelegte distanz auf aktueller linie (zwischengespeichert)

awos_sec_chg

		movea.l	big_sector_ptr,a3
		move.w	an_mon_new_sec,d1
		movea.l	lev_sec_start(a3,d1.w*4),a4
		move.l	sec_mon_line(a4),d1
		beq	awossc_out			; dann halt nichts ...
		movea.l	d1,a4

		moveq	#0,d4
		movem.l	(a6),d0-d1			; d0-d1 = uebergangspunkte

awos_f_lp
		move.l	(a4,d4.w*8),d3
		bmi.s	awossc_out		; keine weitere monster_linie vorhanden ...

	; jetzt die uebergangspunkte mit den
	; anfangspunkten der strecke vergleichen

		movea.l	d3,a5
		bsr	awos_cmp_points
		tst.w	d3
		bne.s	alsc_begin

	; jetzt die uebergangspunkte mit den
	; endpunkten der strecke vergleichen.
	; dazu zuerst den pointer der endpunkte
	; bestimmen ...

		bsr	awos_cmp_find_end
		bsr	awos_cmp_points
		tst.w	d3
		bne.s	alsc_ending

		addq.w	#1,d4
		bra.s	awos_f_lp

;---

alsc_begin
		move.w	an_mon_new_sec,d1
		move.w	d1,mon_sec(a2)
		movea.l	lev_sec_start(a3,d1.w*4),a3
		movea.l	sec_mon_line(a3),a3
		movea.l	(a3,d4.w*8),a3
		move.w	d4,mon_sec_dir(a2)
		clr.w	mon_sec_line(a2)
		moveq	#0,d3
		clr.w	mon_walk_dir(a2)

		bra	awos_not_end

;---

alsc_ending
		move.w	an_mon_new_sec,d1
		move.w	d1,mon_sec(a2)
		movea.l	lev_sec_start(a3,d1.w*4),a3
		movea.l	sec_mon_line(a3),a3
		movea.l	(a3,d4.w*8),a3
		move.w	d4,mon_sec_dir(a2)
		move.w	d2,mon_sec_line(a2)
		move.l	-4(a5),d3		; mon_sec_dist
		move.w	#1,mon_walk_dir(a2)

		bra	awos_not_end

;---

; a3 = big_sector_ptr

awossc_out

	; keine neue linie gefunden, bei
	; alter also stehenbleiben ...

		move.w	mon_sec(a2),d1
		movea.l	lev_sec_start(a3,d1.w*4),a3
		movea.l	sec_mon_line(a3),a3
		move.w	mon_sec_dir(a2),d1
		movea.l	(a3,d1.w*8),a3
		move.w	an_mon_new_dis,d3

		bra	awos_not_end

;---

; d2 = rueckgabe mon_sec_line (ending)

awos_cmp_find_end

		moveq	#-1,d2
acfe_loop
		tst.w	ml_length(a5)
		beq.s	acfe_found
		addq.w	#1,d2
		lea	16(a5),a5
		bra.s	acfe_loop
acfe_found
		rts

;---

; d0,d1 = point x,y
;    a5 = pointer auf zu vergleichenden point

awos_cmp_points

		moveq	#0,d3

		cmp.l	(a5),d0
		bne.s	acp_out
		cmp.l	4(a5),d1
		bne.s	acp_out

		moveq	#1,d3
acp_out
		rts

;---------------

; a0 = Zeiger auf mon_sdat
; a1 = Reserviert
; a2 = Zeiger auf ein monster
; d7 = Reserviert

; setzen der richtigen grafikdaten des monsters ...

anim_one_monst_now

		tst.w	mon_a_died(a2)
		bne.s	aomn_died

		tst.w	mon_a_hit(a2)
		bne	aomn_hit

		tst.w	mon_a_shoot(a2)
		bne	aomn_shoot

	; keiner sonderbewegung, also nur normal laufen lassen ...

		move.w	mon_a_walk(a2),d4
		add.w	vbl_time,d4
		cmpi.w	#mon_walk_time,d4
		blt.s	aomn_walk_same
		moveq	#0,d4
		move.w	mon_grafik_typ(a2),d1
		movea.l	(a0,d1.w*4),a3		; richtige sdat (mon_grafik_typ)
		move.w	mon_a_walk_pos(a2),d0
		addq.w	#1,d0
		cmp.w	sdat_walk_anz(a3),d0
		blt.s	aomn_wp_beg
		moveq	#0,d0
aomn_wp_beg	move.w	d0,mon_a_walk_pos(a2)
		add.w	sdat_walk_ptr(a3),d0
		bsr	aomn_set_anim_stufe
aomn_walk_same	move.w	d4,mon_a_walk(a2)

		rts

;---

aomn_died
		move.w	mon_a_died(a2),d4
		bmi.s	aomn_died_same

		move.w	mon_grafik_typ(a2),d1
		movea.l	(a0,d1.w*4),a3
		cmpi.w	#1,d4
		bne.s	aomn_died_cnt

		move.w	mon_a_died_pos(a2),d0
		add.w	sdat_died_ptr(a3),d0
		bsr	aomn_set_anim_stufe

aomn_died_cnt
		add.w	vbl_time,d4
		cmpi.w	#mon_died_time,d4
		blt.s	aomn_died_same
		moveq	#1,d4
		move.w	mon_a_died_pos(a2),d2
		addq.w	#1,d2
		move.w	d2,mon_a_died_pos(a2)
		cmp.w	sdat_died_anz(a3),d2
		blt.s	aomn_died_same
		moveq	#-1,d4
aomn_died_same	
		move.w	d4,mon_a_died(a2)

		rts

;---

aomn_shoot
		move.w	mon_grafik_typ(a2),d1
		movea.l	(a0,d1.w*4),a3

		move.w	mon_a_shoot(a2),d4
		cmpi.w	#1,d4
		bne.s	aomn_shoot_cnt

	; animationsphase erreicht, in der dem spieler tatsaechlich
	; nun energie abgezogen wird ...

		move.w	mon_a_shoot_pos(a2),d0
		cmpi.w	#3,d0
		bne.s	aomn_sh_only_a

		bsr	mon_to_player_getroffen
		tst.w	d0
		bne.s	aomn_sh_only_a

		movem.l	mon_line(a2),d0-d1
		move.w	mon_shoot_snd(a2),d2
		bsr	init_sam_dist
		
	; spieler nicht generell energie abziehen, sondern
	; mit einer x:y wahrscheinlichkeit

		bsr	get_zufall_256
		andi.w	#$ff,d1
		cmpi.w	#210,d1
		bgt	aomn_sh_only_a

		bsr	mon_to_player_shoot

aomn_sh_only_a
		move.w	mon_a_shoot_pos(a2),d0
		add.w	sdat_sht_d_ptr(a3),d0
		bsr.s	aomn_set_anim_stufe

aomn_shoot_cnt
		add.w	vbl_time,d4
		cmpi.w	#mon_shoot_time,d4
		blt.s	aomn_shoot_same
		moveq	#1,d4
		move.w	mon_a_shoot_pos(a2),d2
		addq.w	#1,d2
		move.w	d2,mon_a_shoot_pos(a2)
		cmp.w	sdat_sht_d_anz(a3),d2
		blt.s	aomn_shoot_same
		clr.w	d4
		clr.w	mon_a_shoot_pos(a2)
aomn_shoot_same
		move.w	d4,mon_a_shoot(a2)

		rts

;---

aomn_hit
		move.w	mon_grafik_typ(a2),d1
		movea.l	(a0,d1.w*4),a3

		move.w	mon_a_hit(a2),d0
		add.w	vbl_time,d0
		cmpi.w	#mon_hit_time,d0
		blt.s	aomn_hit_same
		moveq	#0,d0

	; flag fuer bereits einmal getroffen setzen

		bset	#4,mon_shoot_typ+1(a2)

	; wenn monster sofort zurueckschiessen soll, dann dieses ausloesen ...

		tst.w	mon_shoot_typ(a2)
		bmi.s	aomn_hit_same
		btst	#0,mon_shoot_typ+1(a2)
		beq.s	aomn_hit_same

		move.w	#1,mon_a_shoot(a2)

aomn_hit_same
		move.w	d0,mon_a_hit(a2)

		move.w	sdat_hit_ptr(a3),d0
		bsr.s	aomn_set_anim_stufe

		rts

;---------------

;* a0 : Reserviert
;* a2 : Zeiger auf ein monster
;* a3 : Zeiger auf sdat fuer mon_grafik_typ
;* a4 : Reserviert
;* d0 : Animationsstufe
;* uses d0-d2/a6

aomn_set_anim_stufe:

		move.w	d3,-(sp)

		moveq	#0,d3

                lsl.w   #5,D0		; 32 bytes pro animationsstufe

                cmpi.l  #-1,sdat_sdat+4(A3,D0.w)	; wenn -1, dann kein
                beq.s   asas_now_set			; seitentest ...

                move.b  mon_line+13(A2),D1                 ; alpha
                movea.l play_dat_ptr,A6
                move.l  pd_alpha(A6),D2
                sub.b   D1,D2
                bmi.s   asas_w_neg

                cmpi.b  #$20,D2
                bgt.s   asas_p_l1

                addq.w  #8,D0			; hinten (nicht sicher)
                bra.s   asas_now_set

asas_p_l1:      cmpi.b  #$60,D2
                bgt.s   asas_now_set

                addi.w  #12,D0			; links (?)
		moveq	#%01000000,d3
                bra.s   asas_now_set

asas_w_neg:
                neg.b   D2
                cmpi.b  #$20,D2
                bgt.s   asas_n_l1

                addq.w  #8,D0			; hinten (?)
                bra.s   asas_now_set

asas_n_l1:      cmpi.b  #$60,D2
                bgt.s   asas_now_set

		addq.w	#4,d0			; rechts (?)


asas_now_set:
                move.w  sdat_sdat(A3,D0.w),18(A2)	; xyoffi
                move.b  sdat_sdat+2(A3,D0.w),9(A2)	; text_nr
                move.b  8+3(A2),D2
                add.b   sdat_sdat+3(A3,D0.w),D2
                move.b  D2,12+3(A2)
                move.w  sdat_sdat+16(A3,D0.w),22(A2)	; left_right
                move.b  sdat_sdat+18(A3,D0.w),17(A2)	; breite
		move.b	d3,21(a2)			; side_change

		move.w	(sp)+,d3

                rts

;---------------

;*    d0 : X-wert objekt
;*    d1 : Y-wert objekt
;*    d0 : Rueckgabe entfernung (in maximumnorm)

;* uses a6

calc_dist_to_player

		movea.l	play_dat_ptr,a6
		sub.l	pd_sx(a6),d0
		bpl.s	cdtp_x_ok
		neg.l	d0
cdtp_x_ok	sub.l	pd_sy(a6),d1
		bpl.s	cdtp_y_ok
		neg.l	d1
cdtp_y_ok	cmp.l	d0,d1
		blt.s	cdtp_y_smaller
		move.l	d1,d0
cdtp_y_smaller
		rts

;---------------

; d0: x-wert objekt
; d1: y-wert objekt
; d0: rueckgabe alpha (256er winkel)

; uses a6

calc_alpha_to_player

		movea.l	play_dat_ptr,a6
		sub.l	pd_sx(a6),d0		; delta_x
		bmi.s	catp_23
		beq.s	catp_x_null

	; sind im quadranten 1 oder 4, da delta_x positiv

		sub.l	pd_sy(a6),d1		; delta_y
		bmi.s	catp_4
		beq.s	catp_y_null

	; sind im quadranten 1, also delta_x und delta_y positiv

		bsr.s	catp_calc_now
		rts

catp_4
		neg.l	d1
		bsr.s	catp_calc_now
		move.w	#256,d1
		sub.w	d0,d1
		andi.w	#255,d1
		move.w	d1,d0
		rts

catp_23

	; sind im quadranten 2 oder 3, da delta_x negativ

		sub.l	pd_sy(a6),d1		; delta_y
		bmi.s	catp_3
		beq.s	catp_y_null

catp_2

	; sind im quadranten 2

		neg.l	d0
		bsr.s	catp_calc_now
		move.w	#128,d1
		sub.w	d0,d1
		move.w	d1,d0
		rts

catp_3

	; sind im quadranten 3

		neg.l	d0
		neg.l	d1
		bsr.s	catp_calc_now
		addi.w	#128,d0
		rts

catp_x_null

	; sonderfall: delta_x = null

		moveq	#64,d0
		sub.l	pd_sy(a6),d1
		bpl.s	catpxn_ok
		move.w	#192,d0
catpxn_ok
		rts

catp_y_null

	; sonderfall: delta_y = null

		moveq	#0,d1
		tst.l	d0
		bpl.s	catpyn_ok
		move.w	#128,d1
catpyn_ok	move.w	d1,d0

		rts

;---

; d0: delta_x (positiv)
; d1: delta_y (positiv)
; d0: rueckgabe winkel (0..64)

catp_calc_now

		lsl.l	#8,d1			; fuer nachkommastellen (faktor 256)
		divu.l	d0,d1			; d1.l = tangens alpha
		lea	arctangens_mitte,a6
		moveq	 #3,d2			; anzahl schritte
catpcn_loop
		move.w	d2,d3
		addq.w	#1,d3
		cmp.l	(a6),d1
		bgt.s	catpcn_ok
		beq.s	catpcn_found
		neg.w	d3
catpcn_ok	lsl.w	#4,d3
		adda.w	d3,a6
		dbra	d2,catpcn_loop

catpcn_found
		move.l	4(a6),d0
		rts

;---------------

;* a0/a1 : Reserviert
;*    a2 : Zeiger auf ein monster
;*    a3 : Zeiger auf sdat fuer mon_grafik_typ

mon_to_player_shoot

		lea	mon_staerke_tab,a5
		move.w	mon_staerke(a2),d2
		move.w	(a5,d2.w*2),d1	
		lsl.w	#8,d1

		bsr	pd_health_minimieren

                rts

;---------------

; reservierte register:
; a0/a1 : reserviert
;    a2 : zeiger auf ein monster
;    a3 : zeiger auf sdat fuer mon_grafik_typ
;    d6 : hoehe des schusses

; rueckgabe: d0 = 1: schuss geht durch wand
;            d0 = 0: schuss geht nicht durch wand, ist also moeglich

mon_to_player_getroffen

		movem.l	a0-a3,-(sp)

	; test_points (verbindungslinie monster - spieler) aufbauen ...

		movea.l	play_dat_ptr,a5
		movem.l	pd_sx(a5),d0-d1		; sx/sy
		movem.l	mon_line(a2),d2-d3	; mx/my
		movem.l	d0-d3,test_points

	; schusshoehe feststellen ...

		moveq	#0,d6
		move.b	mon_line+15(a2),d6		; h2
		sub.b	mon_line+11(a2),d6
		lsr.w	#2,d6
		move.w	d6,d7
		add.w	d6,d6
		add.w	d7,d6
		add.b	mon_line+11(a2),d6		; schusshoehe

		movea.l	big_sector_ptr,a0
		movea.l	play_dat_ptr,a1
		move.w	pd_akt_sector(a1),d7
		movea.l	lev_sec_start(a0,d7.w*4),a6
		movem.l	d7-a0,-(sp)
		bsr.s	mtpg_one_sector
		movem.l	(sp)+,d7-a0
		tst.w	d0			; wenn wand getroffen, dann
		bne.s	mtpg_out		; sofort raus ...

	; jetzt die anderen sichtbaren sektoren testen ...

		movea.l	lev_sec_start(a0,d7.w*4),a1
		lea	sec_ext_lines(a1),a1

mtpgo_loop
		move.w	(a1)+,d1
		bmi.s	mtpg_out
		movea.l	lev_sec_start(a0,d1.w*4),a6
		movem.l	a0-a1,-(sp)
		bsr.s	mtpg_one_sector
		movem.l	(sp)+,a0-a1

		tst.w	d0
		bne.s	mtpg_out
		bra.s	mtpgo_loop

mtpg_out
		movem.l	(sp)+,a0-a3

		rts

;---

; a6 = pointer auf sektor
; d6 = schusshoehe

mtpg_one_sector

		move.l	sec_lines(a6),a1
		move.l	sec_points(a6),a2
		addq.l	#4,a2
		move.l	(a1)+,d7		; anzahl linien
		subq.w	#1,d7
		lea	inter_ptr,a0

mtpgos_loop
		move.w	2(a1),d0		; p1
		lea	(a2,d0.w*4),a3
		move.l	a3,(a0)
		move.w	6(a1),d0		; p2
		lea	(a2,d0.w*4),a3
		move.l	a3,4(a0)

		clr.w	schnitt_anz
		movem.l	a0-a2/a6/d6-d7,-(sp)
		bsr	intersect
		movem.l	(sp)+,a0-a2/a6/d6-d7
		cmpi.w	#1,schnitt_anz
		beq.s	mtpgos_schnitt

mtpgos_no_schnitt

		lea	20(a1),a1

		dbra	d7,mtpgos_loop
		moveq	#0,d0		

		bra	mtpg_one_sector_doors

mtpgos_schnitt

		move.b	14(a1),d0
		moveq	#0,d1
		move.b	11(a1),d1
		cmp.w	d1,d6
		bgt.s	mtpgoss_no_boden
		beq.s	mtpgoss_no_boden
		btst	#2,d0			; boden_flag
		beq.s	mtpgos_no_schnitt
mtpgoss_no_boden
		move.b	15(a1),d1
		cmp.w	d1,d6
		blt.s	mtpgos_no_decke
		beq.s	mtpgos_no_decke
		btst	#3,d0			; decke_flag
		beq.s	mtpgos_no_schnitt
mtpgos_no_decke

		moveq	#1,d0
		rts	

;---

mtpg_one_sector_doors

	; a6 = pointer auf sektor

		move.l	sec_doors(a6),d1
		beq	mtpgosd_out
		movea.l	d1,a5
mtpgosd_loop
		move.l	(a5)+,d1
		beq.s	mtpgosd_loop
		bmi	mtpgosd_out

	; -----------------------------
	; es kann jetzt eine tuer getestet werden ...
	; d1 ist der pointer auf diese tuer ...

		movea.l	d1,a0
		lea	door_line(a0),a1
		lea	door_pts(a0),a2

		lea	inter_ptr,a0
		moveq	#3,d7			; anzahl linien

mtpgosd_line_loop

		move.w	2(a1),d0		; offset p1
		lea	(a2,d0.w*4),a3
		move.l	a3,(a0)
		move.w	6(a1),d0
		lea	(a2,d0.w*4),a3
		move.l	a3,4(a0)

		clr.w	schnitt_anz
		movem.l	a0-a2/a5/d6-d7,-(sp)
		bsr	intersect
		movem.l	(sp)+,a0-a2/a5/d6-d7
		cmpi.w	#1,schnitt_anz
		bne.s	mtpgosd_no_schnitt

		moveq	#0,d1
		move.b	11(a1),d1
		cmp.w	d1,d6
		blt.s	mtpgosd_no_schnitt
		move.b	15(a1),d1
		cmp.w	d1,d6
		bgt.s	mtpgosd_no_schnitt

		moveq	#1,d0
		rts	

mtpgosd_no_schnitt

		lea	20(a1),a1

		dbra	d7,mtpgosd_line_loop
		

mtpgosd_skip_door

		bra	mtpgosd_loop


mtpgosd_out
		moveq	#0,d0
		rts


		
;**************************************
;* pd_health_minimieren
;**************************************

; d1 = absoluter wert, der abgezogen wird (0*256..100*256)

; benutzte register
;  d0-d2
;  a4

pd_health_minimieren

		tst.w	pl_leiste_act+(th_invul-1)*2
		bne	pdhm_out 

		movea.l	play_dat_ptr,a4
		tst.w	pd_invul(a4)
		bne	pdhm_out

		move.w	#1,plf_energy
		move.w	#1,plf_shield

		cmpi.w	#100*256,d1
		beq.s	pdhm_sofort

		lea	pdhm_sound_flag,a4
		tst.w	(a4)
		bne.s	pdhm_no_sound

		clr.w	(a4)
		movem.l	d0-a6,-(sp)
		moveq	#snd_ahh,d0
		cmpi.w	#5*256,d2
		blt.s	pdhm_default
		moveq	#snd_arghh,d0
pdhm_default	moveq	#0,d1
		move.w	#1,dma_speech_flag
		jsr	init_sam
		movem.l	(sp)+,d0-a6
pdhm_no_sound

		movea.l	play_dat_ptr,a4
		move.w	pd_health(a4),d0

		move.w	#128*256,d2
		sub.w	pd_armor(a4),d2
		lsr.w	#7,d2			; d2/128 werden abgezogen
		mulu	d1,d2
		lsr.l	#8,d2
		sub.w	d2,d0
		bpl.s	mph_health_ok
 
pdhm_sofort
		movem.l	a0-a2,-(sp)
		move.w	#1,dma_speech_flag
		moveq	#snd_player_died,d0
		moveq	#0,d1
		bsr	init_sam
		movem.l	(sp)+,a0-a2

		movea.l	play_dat_ptr,a4
		move.w	#-1,pd_health(a4)
		move.w	#-1,pd_armor(a4)
		move.w	#1,pd_killed_flag(a4)
		rts

mph_health_ok
		move.w	d0,pd_health(a4)

		; und jetzt noch pd_armor verkleinern ...

		move.w	pd_armor(a4),d0
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		lsr.w	#1,d1	; 3/2 von pd_health werden pd_armor abgezogen
		sub.w	d1,d0
		bpl.s	mph_armor_ok
		moveq	#-1,d0
mph_armor_ok	move.w	d0,pd_armor(a4)

pdhm_out
		rts

;--

pdhm_sound_flag	dc.w	0
