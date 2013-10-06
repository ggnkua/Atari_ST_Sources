;**************************************
;* action_keys
;**************************************

action_keys
		tst.w	menue_flag
		bne.s	action_keys_out

		bsr	test_shooting
		bsr	test_adrian
		bsr.s	test_ammo_change

action_keys_out
		rts

;-----------------------

test_ammo_change

		lea	jagpad_routs+4,a0
		jsr	(a0)
		move.l	d0,d7

		lea	keytable,a0
		movea.l	play_dat_ptr,a6
		tst.b	2(a0)			; "1"
		bne.s	tac_1
		btst	#17,d7			; button 1
		beq.s	tac_not_1		
tac_1		clr.b	2(a0)
		moveq	#0,d0
		bra	tac_now
tac_not_1
		tst.b	3(a0)			; "2"
		bne.s	tac_2
		btst	#18,d7			; button 2
		beq.s	tac_not_2
tac_2		clr.b	3(a0)
		tst.w	pd_pistol1(a6)
		beq.s	tac_not_2
		moveq	#1,d0
		bra	tac_now
tac_not_2
		tst.b	4(a0)			; "3"
		bne.s	tac_3
		btst	#19,d7			; button 3
		beq.s	tac_not_3
tac_3		clr.b	4(a0)
		tst.w	pd_pistol2(a6)
		beq.s	tac_not_3
		moveq	#2,d0
		bra	tac_now
tac_not_3
		tst.b	5(a0)			; "4"
		bne.s	tac_4
		btst	#20,d7
		beq.s	tac_not_4
tac_4		clr.b	5(a0)
		tst.w	pd_pistol3(a6)
		beq.s	tac_not_4
		moveq	#3,d0
		bra	tac_now
tac_not_4
		tst.b	6(a0)			; "5"
		bne.s	tac_5
		btst	#21,d7
		beq.s	tac_not_5
tac_5		tst.w	pd_pistol4(a6)
		beq.s	tac_not_5
		moveq	#4,d0
		bra	tac_now
tac_not_5
		rts

;---

; d0: waffentyp (0 - 4)

tac_now
		movea.l	play_dat_ptr,a6
		tst.w	d0
		beq.s	tac_selectable		; fuss immer moeglich ...
		tst.w	pd_mun0_anz-2(a6,d0.w*2)
		beq.s	tac_not_selectable

tac_selectable
		move.w	d0,pd_mun_type(a6)
		jsr	load_pistol_data
		bsr	calc_paint_pistol_immediate
		move.w	d1,plf_weapon		
		

tac_not_selectable
		rts



;**************************************
;* test_shooting
;**************************************


test_shooting

	; -------------------
	; wenn spieler gestorben, 
	; dann nichts moeglich

		movea.l	play_dat_ptr,a1
		tst.w	pd_health(a1)
		bmi	ts_no_shoot_all

	; -------------------
	; wenn spieler den fuss 
	; aktiv hat, dann zwischen
	; den schuessen immer eine 
	; gewisse zeit abwarten
	; -> nicht zuviel schuesse pro minute

		lea	keytable,a1
		tst.b	$2a(a1)
		beq.s	ts_no_shoot_1
		clr.b	$2a(a1)
		bsr	shooting
		bra	ts_out

ts_no_shoot_1
		tst.b	$36(a1)
		beq.s	ts_no_shoot_all
		clr.b	$36(a1)
		bsr	shooting
		bra	ts_out


ts_no_shoot_all

	; -------------------
	; es ist kein schuss 
	; ausgeloest worden, dann das
	; flag auf alle faelle 
	; loeschen und dann
	; zurueckkehren ...

                clr.l   shoot

                movea.l play_dat_ptr,A3
                clr.w   pd_hat_gesch(A3)

	; -------------------
	; ... und die zeit 
	; heraufzaehlen!

		lea	ts_time(pc),a0
		move.w	(a0),d0
		add.w	vbl_time,d0
		moveq	#foot_time,d1
		cmp.w	d1,d0
		blt.s	ts_as
		move.w	d1,d0
ts_as		move.w	d0,(a0)

ts_out
                rts


;---

ts_time		dc.w	0

tsa_time	dc.w	tsa_time_value
tsa_time_count	dc.w	0
tsa_anz		dc.w	tsa_anz_value
tsa_anz_count	dc.w	0



;**************************************
;* test_adrian
;**************************************


test_adrian

		movea.l	play_dat_ptr,a0
		tst.w	pd_health(a0)
		bmi	ta_out
		tst.w	pd_duke_talk(a0)
		bne	ta_out

		lea	tsa_time,a0	; pointer initialisieren
		move.w	2(a0),d0	; tsa_time_count holen
		add.w	vbl_time,d0	; und vergangene zeit addieren
		cmp.w	(a0),d0		; mit tsa_time vergleichen
		blt.s	ta_no_time	; zeitgrenze ueberschritten?

	; zeitgrenze erreicht
	; sind auch genuegend schusse erfolgt?

		moveq	#0,d0		; tsa_time_count (zaehler) wieder auf null
		move.w	6(a0),d1	; tsa_anz_count holen
		clr.w	6(a0)		; auf alle faelle loeschen (tsa_anz_count)
		cmp.w	4(a0),d1	; mit tsa_anz vergleichen
		blt.s	ta_no_anz	; sind genuegend schuss erfolgt?

	; zeitgrenze erreicht
	; und auch genuegend schuesse erfolgt
	; -> sample abspielen

		movem.l	d0/a0,-(sp)

		jsr	get_zufall_256
		ext.l	d1
		divu	#86,d1
		move.w	#snd_adrian,d0
		add.w	d1,d0
		moveq	#0,d1
		move.w	#1,dma_speech_flag
		jsr	init_sam

		movem.l	(sp)+,d0/a0

	; werte neu initialisieren

		; <nicht implementiert>

ta_no_anz

ta_no_time
		move.w	d0,2(a0)

ta_out
		rts



;**************************************
;* shooting
;**************************************

shooting

	; -------------------
	; hat der spieler den fuss, 
	; so ist der schuss nur moeglich,
	; wenn ts_time den 
	; angegebenen wert erreicht hat ...

		movea.l	play_dat_ptr,a6
		tst.w	pd_mun_type(a6)
		bne.s	shooting_no_foot

		lea	ts_time(pc),a0
		move.w	(a0),d0
		cmpi.w	#foot_time,d0
		beq.s	shooting_foot_can

	; -------------------
	; ... und heraufzaehlen ...

		add.w	vbl_time,d0
		move.w	d0,(a0)
		bra	shooting_out		; und raus ...

shooting_foot_can

		clr.w	ts_time

shooting_no_foot

		movea.l	play_dat_ptr,a6
		clr.w	pd_hat_gesch(a6)	; sicherheitshalber loeschen,
		clr.l	shoot			; falls doch kein schuss moeglich

		move.w	pd_mun_type(a6),d0
		beq	shooting_now			; fuss geht immer
		tst.w	pd_mun0_anz-2(a6,d0.w*2)	; noch munition vorhanden ?
		beq	shooting_out
		lea	plf_ammo1,a6
		move.w	#1,-2(a6,d0.w*2)
shooting_now

	; -------------------
	; dann kann der schuss 
	; ja losgehen ...

		addq.w	#1,tsa_anz_count

		movea.l	big_sector_ptr,a6		; sample abspielen ...
		movea.l	lev_pistol(a6),a6
		movea.l	pistol_info(a6),a6
		movea.l	(a6,d0.w*4),a6
		move.w	pistol_sam_sht(a6),d0
		moveq	#0,d1
		bsr	init_sam

		moveq	#1,d0
		move.l	d0,shoot			; flags setzen ...
		movea.l	play_dat_ptr,a6
		move.w	d0,pd_hat_gesch(a6)

	; jetzt die munition um einen schuss herunterzaehlen ...

		move.w	pd_mun_type(a6),d0
		beq.s	shooting_out			; fuss hat unbegrenzt ...
		subq.w	#1,pd_mun0_anz-2(a6,d0.w*2)
		bne.s	shooting_out

		lea	sm_out_of_ammo,a0
		jsr	install_message

shooting_out
                rts

