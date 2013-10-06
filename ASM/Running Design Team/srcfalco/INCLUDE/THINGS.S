;**************************************

;* fuer alle things_routs gilt:
;*
;* a0 : pointer auf thing

things_rout01:
                bsr     tr_set_thing
                bsr     th_install_message

                rts

;-----------------------

things_rout02:
                bsr     tr_set_thing
                bsr     th_install_message

                rts

;-----------------------

things_rout03:
                bsr     tr_set_thing
                bsr     th_install_message

                rts

;-----------------------

things_rout04:
                bsr     tr_set_thing
                bsr     th_install_message

                rts

;-----------------------

things_rout05:
		movea.l	play_dat_ptr,a6
		move.w	pd_mun0_anz(a6),d0
		cmp.w	pd_munx0_anz(a6),d0
		beq.s	tr05_not_taken

                bsr     tr_delete_thing

		add.w	thing_action(a0),d0
		cmp.w	pd_munx0_anz(a6),d0
		blt.s	tr05_no_max
		move.w	pd_munx0_anz(a6),d0
tr05_no_max	move.w	d0,pd_mun0_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon
tr05_not_taken
                rts

;-----------------------

things_rout06:
		movea.l	play_dat_ptr,a6
		move.w	pd_mun1_anz(a6),d0
		cmp.w	pd_munx1_anz(a6),d0
		beq.s	tr06_not_taken

                bsr     tr_delete_thing

		add.w	thing_action(a0),d0
		cmp.w	pd_munx1_anz(a6),d0
		blt.s	tr06_no_max
		move.w	pd_munx1_anz(a6),d0
tr06_no_max	move.w	d0,pd_mun1_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon
tr06_not_taken
                rts

;-----------------------

things_rout07
		movea.l	play_dat_ptr,a6
		move.w	pd_mun2_anz(a6),d0
		cmp.w	pd_munx2_anz(a6),d0
		beq.s	tr07_not_taken

                bsr     tr_delete_thing

		add.w	thing_action(a0),d0
		cmp.w	pd_munx2_anz(a6),d0
		blt.s	tr07_no_max
		move.w	pd_munx2_anz(a6),d0
tr07_no_max	move.w	d0,pd_mun2_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon
tr07_not_taken
                rts

;-----------------------

things_rout08
		movea.l	play_dat_ptr,a6
		move.w	pd_mun3_anz(a6),d0
		cmp.w	pd_munx3_anz(a6),d0
		beq.s	tr08_not_taken

                bsr     tr_delete_thing

		add.w	thing_action(a0),d0
		cmp.w	pd_munx3_anz(a6),d0
		blt.s	tr08_no_max
		move.w	pd_munx3_anz(a6),d0
tr08_no_max	move.w	d0,pd_mun3_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon
tr08_not_taken
                rts

;-----------------------

;* ultra-scanner

things_rout09:
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* night-viewer

things_rout10
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* gas_mask

things_rout11:
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* small_medikit

things_rout12
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* big_medikit

things_rout13
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* small_medikit

things_rout14
		move.w	#10*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	thr14_out

		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message

thr14_out
                rts

;-----------------------

;* big_medikit

things_rout15
		move.w	#30*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	thr15_out

		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message

thr15_out
                rts

;-----------------------

;* small_armor

things_rout16
		move.w	#20*256,d0
		bsr	th_add_armor
		tst.w	d7
		bne.s	thr16_out

		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message

thr16_out
                rts

;-----------------------

;* big_armor

things_rout17
		move.w	#40*256,d0
		bsr	th_add_armor
		tst.w	d7
		bne.s	thr17_out

		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message

thr17_out
                rts

;-----------------------

;* invulnerability

things_rout18
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* invisibility

things_rout19
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* pistol1

things_rout20
		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_pistol1(a6)
		move.w	#1,plf_things
                rts

;-----------------------

;* pistol2

things_rout21
		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_pistol2(a6)
		move.w	#1,plf_things
                rts

;-----------------------

;* pistol3

things_rout22
		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_pistol3(a6)
		move.w	#1,plf_things
                rts

;-----------------------

;* pistol4

things_rout23
		move.w	#1,dma_speech_flag
		bsr	tr_delete_thing
		bsr	th_install_message
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_pistol4(a6)
		move.w	#1,plf_things
                rts

;-----------------------

;* radiation suit

things_rout24
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* geiger counter

things_rout25
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* jetpack

things_rout26
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* backpack

things_rout27
		bsr	tr_delete_thing
		bsr	th_install_message

		movea.l	play_dat_ptr,a6
		move.w	#munx0_backpack,pd_munx0_anz(a6)
		move.w	#munx1_backpack,pd_munx1_anz(a6)
		move.w	#munx2_backpack,pd_munx2_anz(a6)
		move.w	#munx3_backpack,pd_munx3_anz(a6)

                rts

;-----------------------

;* monster detector

things_rout28
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* full plan

things_rout29
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* munition_1

things_rout30
		movea.l	play_dat_ptr,a6
		move.w	pd_mun0_anz(a6),d0
		cmp.w	pd_munx0_anz(a6),d0
		beq.s	tr30_not_taken

                bsr     tr_delete_thing

		add.w	#mun_0_static,d0
		cmp.w	pd_munx0_anz(a6),d0
		blt.s	tr30_no_max
		move.w	pd_munx0_anz(a6),d0
tr30_no_max	move.w	d0,pd_mun0_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon

tr30_not_taken
                rts

;-----------------------

things_rout31
		movea.l	play_dat_ptr,a6
		move.w	pd_mun1_anz(a6),d0
		cmp.w	pd_munx1_anz(a6),d0
		beq.s	tr31_not_taken

                bsr     tr_delete_thing

		add.w	#mun_1_static,d0
		cmp.w	pd_munx1_anz(a6),d0
		blt.s	tr31_no_max
		move.w	pd_munx1_anz(a6),d0
tr31_no_max	move.w	d0,pd_mun1_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon

tr31_not_taken
                rts

;-----------------------

things_rout32
		movea.l	play_dat_ptr,a6
		move.w	pd_mun2_anz(a6),d0
		cmp.w	pd_munx2_anz(a6),d0
		beq.s	tr32_not_taken

                bsr     tr_delete_thing

		add.w	#mun_2_static,d0
		cmp.w	pd_munx2_anz(a6),d0
		blt.s	tr32_no_max
		move.w	pd_munx2_anz(a6),d0
tr32_no_max	move.w	d0,pd_mun2_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon

tr32_not_taken
                rts

;-----------------------

things_rout33
		movea.l	play_dat_ptr,a6
		move.w	pd_mun3_anz(a6),d0
		cmp.w	pd_munx3_anz(a6),d0
		beq.s	tr33_not_taken

                bsr     tr_delete_thing

		add.w	#mun_3_static,d0
		cmp.w	pd_munx3_anz(a6),d0
		blt.s	tr33_no_max
		move.w	pd_munx3_anz(a6),d0
tr33_no_max	move.w	d0,pd_mun3_anz(a6)
                bsr     th_install_message
		move.w	#1,plf_weapon

tr33_not_taken
                rts

;-----------------------

;* open_door

things_rout34
		movea.l	big_sector_ptr,a6
		adda.l	#lev_sec_start,a6
		movea.l	play_dat_ptr,a5
		move.w	thing_action(a0),d0	; optionales argument
		movea.l	(a6,d0.w*4),a6		; sektor
		move.l	sec_doors(a6),d0	; pointer tueren
		beq.s	tr34_out
		movea.l	d0,a1
		movea.l	(a1),a1		; bezieht sich immer nur auf die
					; erste tuer eines sektors

		btst	#0,door_status+1(a1)
		bne.s	tr34_out	; tuer ist schon offen

		move.l	a0,-(sp)	; things_ptr sichern
		move.w	#%10,door_status(a1)
		movea.l	a1,a0
		jsr	door_to_anim

		movem.l	door_pts(a0),d0-d1
		moveq	#snd_door_open,d2
		jsr	init_sam_dist

	ifne midiplay
		move.w	thing_action(a0),d0	; d0 = sektornummer
		moveq	#0,d1			; d1 = erste tuer im sektor (standard bei dieser aktion)
		jsr	mp_send_20		; midikommando schicken
	endc

		movea.l	(sp)+,a0	; things_ptr holen
		bsr	tr_delete_thing

tr34_out
		rts

;-----------------------

;* open lift

things_rout35
		movea.l	big_sector_ptr,a6
		adda.l	#lev_sec_start,a6
		movea.l	play_dat_ptr,a5
		move.w	thing_action(a0),d0	; optinales argument
		movea.l	(a6,d0.w*4),a6		; sektor
		move.l	sec_lift(a6),d0		; pointer lift
		beq.s	tr35_out
		movea.l	d0,a1

		btst	#0,lift_status+1(a1)
		bne.s	tr35_out		; lift ist schon offen

		move.l	a0,-(sp)		; things_ptr sichern
		move.w	#%10,lift_status(a1)
		movea.l	a1,a0
		jsr	lift_to_anim

		movem.l	lift_pts(a0),d0-d1
		moveq	#snd_lift_open,d2
		jsr	init_sam_dist

		movea.l	(sp)+,a0		; things_ptr holen
		bsr	tr_delete_thing

tr35_out
		rts

;-----------------------

;* close door

things_rout36
		movea.l	big_sector_ptr,a6
		adda.l	#lev_sec_start,a6
		movea.l	play_dat_ptr,a5
		move.w	thing_action(a0),d0	; optinales argument

		movea.l	(a6,d0.w*4),a6		; sektor
		move.l	sec_doors(a6),d0	; pointer tueren
		beq.s	tr36_out
		movea.l	d0,a1
		movea.l	(a1),a1			; bezieht sich immer nur auf die
						; erste tuer eines sektors

		btst	#0,door_status+1(a1)
		beq.s	tr36_out	

		move.l	a0,-(sp)	
		move.w	#%101,door_status(a1)
		movea.l	a1,a0
		jsr	door_to_anim

		movem.l	door_pts(a0),d0-d1
		moveq	#snd_door_close,d2
		jsr	init_sam_dist

	ifne midiplay
		move.w	thing_action(a0),d0	; d0 = sektornummer
		moveq	#0,d1			; d1 = erste tuer im sektor (standard bei dieser aktion)
		jsr	mp_send_21		; midikommando schicken
	endc

		movea.l	(sp)+,a0		; things_ptr holen
		bsr	tr_delete_thing

tr36_out
		rts

;-----------------------

;* close lift

things_rout37
		movea.l	big_sector_ptr,a6
		adda.l	#lev_sec_start,a6
		movea.l	play_dat_ptr,a5
		move.w	thing_action(a0),d0	; optinales argument
		movea.l	(a6,d0.w*4),a6		; sektor
		move.l	sec_lift(a6),d0		; pointer lift
		beq.s	tr37_out
		movea.l	d0,a1

		clr.w	lift_need_thing(a1)

		btst	#0,lift_status+1(a1)
		beq.s	tr37_out		

		move.l	a0,-(sp)		
		move.w	#%101,lift_status(a1)
		movea.l	a1,a0
		jsr	lift_to_anim

		movem.l	lift_pts(a0),d0-d1
		moveq	#snd_lift_close,d2
		jsr	init_sam_dist

		movea.l	(sp)+,a0		; things_ptr holen
		bsr	tr_delete_thing

tr37_out
		rts

;-----------------------

;* th_teleporter
		
things_rout38

		movem.l	d0-a6,-(sp)

		move.l	a0,-(sp)

		jsr	find_vbl_time

		jsr	dsp_r_normal
		jsr	dsp_info_ausw

		movea.l	(sp),a0

		movea.l	play_dat_ptr,a4
		move.w	thing_action(a0),pd_akt_sector(a4)
		move.l	thing_action+2(a0),pd_sx(a4)
		move.l	thing_action+6(a0),pd_sy(a4)
		move.l	thing_action+10(a0),d0
		move.l	d0,pd_sh(a4)
		move.l	d0,pd_sh_real(a4)
		move.l	thing_action+14(a0),pd_alpha(a4)

		jsr	dsp_s_all

		jsr	change_colortable

		jsr	wall_animation
		jsr	animate_all

		jsr	dsp_r_normal
		jsr	dsp_info_ausw

		jsr	dsp_s_all

		bsr	paint_all

		move.w	#snd_teleporter,d0
		moveq	#0,d1
		jsr	init_sam

		moveq	#0,d0
		bsr	make_blenden

		bsr	set_speed_to_zero

		movea.l	(sp)+,a0	
		movem.l	(sp)+,d0-a6

		rts

;-----------------------

;* th_cameraview

things_rout39
		movem.l	d0-a6,-(sp)

		clr.l	mes_buf1
		clr.l	mes_buf2
		move.w	#2,clear_it_flag		

		move.w	#1,cameraview_flag
		lea	thing_action(a0),a0

		move.l	a0,-(sp)
		move.w	#snd_cameraview,d0
		moveq	#0,d1
		jsr	init_sam
		move.l	(sp)+,a0

tr39_loop
		move.w	(a0)+,d0
		bmi.s	tr39_out

		move.l	a0,-(sp)
		bsr	make_cameraview
		move.w	#snd_cameraview,d0
		moveq	#0,d1
		jsr	init_sam
		move.l	(sp)+,a0

		bra.s	tr39_loop

tr39_out
		bsr	set_speed_to_zero
		clr.w	cameraview_flag

		movem.l	(sp)+,d0-a6		

		rts

;-----------------------

;* th_terminal

things_rout40
		movem.l	d0-a6,-(sp)

		move.w	#1,terminal_flag
		lea	thing_action(a0),a0

		move.b	#1,keytable+$3c
		move.l	a0,ml_connect_addr
		jsr	make_two_180_turns
		bsr	make_laptop

		clr.w	terminal_flag

		movem.l	(sp)+,d0-a6
		rts

;-----------------------

;* th_welder

things_rout41
		bsr	tr_set_thing
		bsr	th_install_message

		rts

;-----------------------

;* th_time_deact

things_rout42

	; wenn zeitlimit nicht aktiviert ist,
	; dann auch nicht deaktivieren ...

		movea.l	play_dat_ptr,a1
		tst.b	pd_time_flag(a1)
		beq.s	tr42_out

		bsr	tr_delete_thing
		bsr	th_install_message

		movea.l	play_dat_ptr,a1
		clr.b	pd_time_flag(a1)
		
tr42_out
		rts

;-----------------------

;* th_verseuch

things_rout43
		bsr	tr_set_thing
		bsr	th_install_message

		rts

;-----------------------

;* th_level_ende

things_rout44

	; sind die missionen erfuellt ...

		move.l	a0,-(sp)

		moveq	#0,d7
		movea.l	play_dat_ptr,a1
		tst.w	pd_primary(a1)
		bne.s	tr44_pr_ok
		moveq	#1,d7
		lea	sm_prim_not,a0
		jsr	install_message
tr44_pr_ok
		tst.w	pd_secondary(a1)
		bne.s	tr44_sec_ok
		moveq	#1,d7
		lea	sm_sec_not,a0
		jsr	install_message
tr44_sec_ok
		movea.l	(sp)+,a0

		tst.w	d7
		bne.s	tr44_out

	; wir koennen den level beenden ...

		bsr	tr_delete_thing

		moveq	#1,d0

		movea.l	play_dat_ptr,a1
		move.w	d0,pd_quit_flag(a1)
		move.w	d0,quit_flag

tr44_out
		rts

;-----------------------

;* th_sample

things_rout45
		bsr	tr_delete_thing

		move.l	a0,-(sp)
		move.w	thing_action(a0),d0
		moveq	#0,d1
		jsr	init_sam
		movea.l	(sp)+,a0

		rts

;-----------------------

;* full plan

things_rout46
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* th_neverget

; nie zu erlangender gegenstand
; keine textausgabe, falls gegenstand erforderlich
; notwendig u.a. um lasersperren fuer immer unsichtbar zu machen

things_rout47
		bsr	tr_set_thing

		rts

;-----------------------

;* th_sftozero

; optionales argument: 0.w sectornummer

; setze im angegebenen sektor alle sectorfields so, dass
; keine energie mehr abgezogen wird

things_rout48
		move.w	thing_action(a0),d0
		movea.l	big_sector_ptr,a1
		movea.l	lev_sec_start(a1,d0.w*4),a1

		; a1 = pointer sektor

		movea.l	sec_sect(a1),a1

		move.w	(a1)+,d7		; anzahl sf

tr48_loop
		clr.b	sf_need_thing(a1)
		clr.b	sf_need_act(a1)

		lea	sf_cluster(a1),a1

		dbra	d7,tr48_loop

		rts

;-----------------------

;* th_changevis

; optionales argument: 0.w sectornummer
;		       2.w type_von
;		       4.w type_nach

; aendert im angegebenen sektor die sichtbarkeitsoption von
; gegenstaenden und schaltern

things_rout49
		movem.w	thing_action(a0),d0/d6-d7

		movea.l	big_sector_ptr,a1
		movea.l	lev_sec_start(a1,d0.w*4),a1

		; a1 = pointer sektor

		movea.l	sec_things(a1),a2

tr49_loop1
		move.l	(a2)+,d0
		beq.s	tr49_loop1
		bmi.s	tr49_things_out
		movea.l	d0,a3
		cmp.w	thing_vistaken(a3),d6
		bne.s	tr49_l11
		move.w	d7,thing_vistaken(a3)
tr49_l11	cmp.w	thing_visact(a3),d6
		bne.s	tr49_loop1
		move.w	d7,thing_visact(a3)
		bra.s	tr49_loop1

tr49_things_out

		move.l	sec_schalter(a1),d0
		beq.s	tr49_schalter_out
		movea.l	d0,a2

tr49_loop2
		move.l	(a2)+,d0
		bmi.s	tr49_schalter_out
		beq.s	tr49_loop2
		movea.l	d0,a3
		cmp.w	sch_vistaken(a3),d6
		bne.s	tr49_l21
		move.w	d7,sch_vistaken(a3)
tr49_l21	cmp.w	sch_visact(a3),d6
		bne.s	tr49_loop2
		move.w	d7,sch_visact(a3)
		bra.s	tr49_loop2
		
tr49_schalter_out
		
		rts


;-----------------------

;* th_laserdeact

; optionales argument: 0.w sektornummer
;                      2.w benoetigter aufgenommener gegenstand
;                      4.w benoetigter aktivierter gegenstand

; deaktiviert die lasersperre
; - th_sftozero und
; - th_changevis

things_rout50

		bra	tr50_kein_act

		move.w	thing_action+2(a0),d0	; benoetigter gegenstand
		beq.s	tr50_kein_besitz
		movea.l	play_dat_ptr,a1		; gegenstand in besitz notwendig
		movea.l	pd_things_ptr(a1),a1
		tst.w	-4(a1,d0.w*4)		; vorhanden ?
		bne.s	tr50_kein_besitz
		move.l	a0,-(sp)
		lea	need_things_ptr,a0
		move.l	-4(a0,d0.w*4),d0
		beq.s	tr50_skip1
		movea.l	d0,a0
		jsr	install_message
tr50_skip1	movea.l	(sp)+,a0
		bra.s	tr50_out
tr50_kein_besitz
		move.w	thing_action+4(a0),d0	; benoetigter aktivierter gegenstand
		beq.s	tr50_kein_act
		tst.w	-2(a1,d0.w*4)		; aktiviert ?
		bne.s	tr50_kein_act
		move.l	a0,-(sp)
		lea	need_things_ptr,a0
		move.l	-4(a0,d0.w*4),d0
		beq.s	tr50_skip2
		movea.l	d0,a0
		jsr	install_message
tr50_skip2	movea.l	(sp)+,a0
		bra.s	tr50_out
tr50_kein_act

		bsr	things_rout48		; th_sftozero

		move.w	#th_night,d0
		move.w	#th_neverget,d1
		movem.w	d0-d1,thing_action+2(a0)
		bsr	things_rout49

tr50_out
		rts

;-----------------------

;* message anzeigen

things_rout51
		bsr	tr_delete_thing

		move.l	a0,-(sp)
		lea	thing_action(a0),a0
		jsr	install_message
		movea.l	(sp)+,a0

                rts

;-----------------------

;* sprengstoff

things_rout52
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* zuender

things_rout53
		bsr	tr_set_thing
		bsr	th_install_message

                rts

;-----------------------

;* primary mission

things_rout54
		bsr	tr_delete_thing
		bsr	th_install_message

		movea.l	play_dat_ptr,a1
		move.w	#1,pd_primary(a1)

		rts

;-----------------------

;* secondary mission

things_rout55
		bsr	tr_delete_thing
		bsr	th_install_message

		movea.l	play_dat_ptr,a1
		move.w	#1,pd_secondary(a1)

		rts

;-----------------------

;* general invulnerability

things_rout56
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* general invisibility

things_rout57
                bsr	tr_set_thing
                bsr	th_install_message

                rts

;-----------------------

;* colortable0

things_rout58
		bsr	tr_delete_thing
		moveq	#0,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable1

things_rout59
		bsr	tr_delete_thing
		moveq	#1,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable2

things_rout60
		bsr	tr_delete_thing
		moveq	#2,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable3

things_rout61
		bsr	tr_delete_thing
		moveq	#3,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable4

things_rout62
		bsr	tr_delete_thing
		moveq	#4,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable5

things_rout63
		bsr	tr_delete_thing
		moveq	#5,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable6

things_rout64
		bsr	tr_delete_thing
		moveq	#6,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable7

things_rout65
		bsr	tr_delete_thing
		moveq	#7,d0
		bsr	set_colortable
		rts

;-----------------------

;* colortable

things_rout66
		bsr	tr_delete_thing
		move.w	thing_action(a0),d0
		bsr	set_colortable
		rts

;-----------------------

;* bierkrug

things_rout67
		move.w	#30*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	thr67_out

		bsr	tr_set_thing
		bsr	th_install_message
thr67_out
		rts

;-----------------------

;* train detector

things_rout68
		bsr	tr_set_thing
		bsr	th_install_message

		rts

;-----------------------

;* delete colortable0

things_rout69
		bsr	tr_delete_thing
		moveq	#0,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable1

things_rout70
		bsr	tr_delete_thing
		moveq	#1,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable2

things_rout71
		bsr	tr_delete_thing
		moveq	#2,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable3

things_rout72
		bsr	tr_delete_thing
		moveq	#3,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable4

things_rout73
		bsr	tr_delete_thing
		moveq	#4,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable5

things_rout74
		bsr	tr_delete_thing
		moveq	#5,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable6

things_rout75
		bsr	tr_delete_thing
		moveq	#6,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable7

things_rout76
		bsr	tr_delete_thing
		moveq	#7,d0
		bsr	delete_colortable
		rts

;-----------------------

;* delete colortable

things_rout77
		bsr	tr_delete_thing
		move.w	thing_action(a0),d0
		bsr	delete_colortable
		rts

;-----------------------

;* th_secchangevis

; optionales argument: wie th_changevis

; aendert die sichtbarkeiten und setzt die secondary mission
; - th_secondary und
; - th_changevis

things_rout78

		bsr	things_rout49		
		bsr	things_rout55
		rts

;-----------------------

;* burger

things_rout79
		move.w	#25*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	thr79_out

		bsr	tr_delete_thing
		bsr	th_install_message
thr79_out
		rts

;-----------------------

;* condom

things_rout80
                bsr	tr_set_thing
                bsr	th_install_message
		rts

;-----------------------

;* idcard

things_rout81
                bsr	tr_set_thing
                bsr	th_install_message
		rts

;-----------------------

;* episodeend

things_rout82
		bsr	tr_delete_thing
		movea.l	play_dat_ptr,a6
		move.w	thing_action(a0),pd_which_end(a6)

		rts


;***********************

;* macht das thing unsichtbar, d.h. es ist aufgenommen worden ...

tr_delete_thing:
                neg.w   thing_type(A0)

                rts

;---------------

; richtige message am bildschirm anzeigen
; gegenstand (item) als aufgenommen kennzeichnen
; alles nur, wenn item aufgenommen wurde

th_install_message

		move.w	thing_type(a0),d0	; aufgenommen?
		bpl.s	tim_out			; nein -> raus

		move.l	a0,-(sp)
		lea	things_txt_ptr,a1
		neg.w	d0
		move.l	-4(a1,d0.w*4),d0
		beq.s	tim_skip
		movea.l	d0,a0
		bsr	install_message
tim_skip
		movea.l	(sp)+,a0

tim_out
		rts

;---------------

; d0: gegenstand_nr

tr_remove_thing
		movea.l	play_dat_ptr,a1
		move.w	#1,pd_things_flag(a1)
		movea.l	pd_things_ptr(a1),a2
		clr.l	-4(a2,d0.w*4)

		rts

;---------------

; gegenstand als aufgenommen (falls
; noch nicht vorhanden) kennzeichnen

; a0 = pointer gegenstand

tr_set_thing
		move.w	thing_type(a0),d0
		movea.l	play_dat_ptr(pc),a1
		move.w	#1,pd_things_flag(a1)	; leiste neu zeichnen
		movea.l	pd_things_ptr(a1),a2
		subq.w	#1,d0
		lea	th_time_limits,a3

		move.w	(a3,d0.w*2),d7		; time_limit
		cmp.w	2(a2,d0.w*4),d7
		bne.s	trst_take_it
		
		tst.w	(a2,d0.w*4)		; schon aufgenommen?
		bne.s	trst_vorhanden

trst_take_it

		move.w	d7,2(a2,d0.w*4)

	; gegenstand kann jetzt aufgenommen werden
	; dazu thing_type negieren

		neg.w	thing_type(a0)

	; und als aufgenommen kennzeichnen

		move.w	#1,(a2,d0.w*4)
		move.w	d0,pd_things_pos(a1)

trst_vorhanden

                rts

;---------------

set_speed_to_zero
		
		move.l	a4,-(sp)

		lea	keytable,a4
		clr.b	$48(a4)
		clr.b	$50(a4)
		clr.b	$4b(a4)
		clr.b	$4d(a4)

		movea.l	play_dat_ptr,a4
		clr.w	pd_last_strafe(a4)
		clr.w	pd_last_alpha(a4)
		clr.w	pd_last_step(a4)
	
		move.l	(sp)+,a4

		rts

;**************************************
;* ta_activate_text
;**************************************

; d0 = nummer gegenstand

ta_activate_text

		lea	things_act_txt_ptr,a0	; pointer auf aktivierungstexte
		movea.l	-4(a0,d0.w*4),a0	; entsprechenden text holen
		bsr	install_message		; message installieren

		lea	pl_leiste_act,a0	; pointer fuer aktivierte gegenstaende
		move.w	#1,-2(a0,d0.w*2)	; und als aktiviert setzen

		movea.l	play_dat_ptr,a0		; flags fuer update der console
		move.w	#1,pd_things_flag(a0)	; sowohl alte flags
		move.w	#1,plf_things		; als auch neue

		rts

;**************************************
;* ta_deactivate_text
;**************************************

; d0: nummer gegenstand

ta_deactivate_text

		lea	things_deact_txt_ptr,a0
		movea.l	-4(a0,d0.w*4),a0
		bsr	install_message

		lea	pl_leiste_act,a0
		clr.w	-2(a0,d0.w*2)		

		movea.l	play_dat_ptr,a0
		move.w	#1,pd_things_flag(a0)
		move.w	#1,plf_things

		rts

;**************************************
;* th_action_routs
;**************************************

th_action_09
		move.w	#th_scanner,d0
		bsr	ta_activate_text

		bsr	deactivate_left_ptr
		moveq	#plr_scanner,d0
		bsr	activate_left_ptr

		lea	leiste_gfx+128+640*56+206*2,a0
		bsr	pl_install_info

		rts

;---

th_action_10
		move.w	#th_night,d0
		bsr	ta_activate_text

		moveq	#1,d0
		bsr	set_colortable

                rts

;---

th_action_11
		move.w	#th_mask,d0
		bsr	ta_activate_text

                rts

;---

th_action_12
		move.w	#10*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	tha12_no_use

		move.w	#th_smedkit_i,d0
		bsr	ta_activate_text

		move.w	#th_smedkit_i,d0
		bsr	tr_remove_thing

		move.w	#th_smedkit_i,d0
		lea	pl_leiste_act,a2
		clr.w	-2(a2,d0.w*2)

		move.w	#1,dma_speech_flag
		move.w	#snd_like,d0
		moveq	#0,d1
		jsr	init_sam
tha12_no_use
		rts

;---

th_action_13
		move.w	#30*256,d0
		bsr	th_add_health
		tst.w	d7
		bne.s	tha13_no_use

		move.w	#th_bmedkit_i,d0
		bsr	ta_activate_text

		move.w	#th_bmedkit_i,d0
		bsr	tr_remove_thing

		move.w	#th_bmedkit_i,d0
		lea	pl_leiste_act,a2
		clr.w	-2(a2,d0.w*2)

		move.w	#1,dma_speech_flag
		move.w	#snd_good,d0
		moveq	#0,d1
		jsr	init_sam
tha13_no_use
		rts

;---

th_action_18
		move.w	#th_invul,d0
		bsr	ta_activate_text
		movea.l	play_dat_ptr,a1
		move.w	#1,pd_invul(a1)
		rts

;---

th_action_19
		move.w	#th_invis,d0
		bsr	ta_activate_text
		movea.l	play_dat_ptr,a1
		move.w	#1,pd_invis(a1)
		rts

;---

th_action_24					
		move.w	#th_radsuit,d0
		bsr	ta_activate_text
		rts

;---

th_action_25
		move.w	#th_geigercount,d0
		bsr	ta_activate_text

		clr.w	plg_real_pos
		clr.w	plg_act_pos
		clr.w	plg_to_pos

		bsr	deactivate_left_ptr
		moveq	#plr_geiger,d0
		bsr	activate_left_ptr

		lea	leiste_gfx+128+640*49+272*2,a0
		bsr	pl_install_info

		tst.w	cinemascope
		bne.s	tha25_info
		tst.w	double_scan
		beq.s	tha25_out
tha25_info	lea	sm_switch,a0
		jsr	install_message

tha25_out
		rts

;---

th_action_26
		lea	sm_no_fuel,a0
		jsr	install_message
		rts

;---

th_action_28
		move.w	#th_mondetector,d0
		bsr	ta_activate_text

                rts

;---

th_action_29
		move.w	#th_plan,d0
		bsr	ta_activate_text

                rts

;---

th_action_41
		move.w	#th_welder,d0
		bsr	ta_activate_text

                rts

;---

th_action_43
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3

		movea.l	play_dat_ptr,a4
		move.w	pd_akt_sector(a4),d7
		bset	#1,(a3,d7.w)

		move.w	#th_verseuch,d0
		bsr	ta_activate_text

		move.w	#th_verseuch,d0
		bsr	tr_remove_thing

		rts

;---

th_action_46
		move.w	#th_littleplan,d0
		bsr	ta_activate_text

                rts

;---

th_action_56
		move.w	#th_geninvul,d0
		bsr	ta_activate_text
		movea.l	play_dat_ptr,a1
		move.w	#1,pd_invul(a1)
		rts

;---

th_action_57
		move.w	#th_geninvis,d0
		bsr	ta_activate_text
		movea.l	play_dat_ptr,a1
		move.w	#1,pd_invis(a1)
		rts

;---

th_action_67
		move.w	#th_bierkrug,d0
		bsr	ta_activate_text

                rts

;---

th_action_68
		move.w	#th_trndetector,d0
		bsr	ta_activate_text

                rts


;**************************************

th_deaction_09:   
		move.w	#-1,pl_left_nb

		moveq	#1,d0
		bsr	pls_remove

		move.w	#th_scanner,d0
		bsr	ta_deactivate_text

		bsr	pl_clear_info

                rts

;---

th_deaction_10
		move.w	#th_night,d0
		bsr	ta_deactivate_text

		moveq	#1,d0
		bsr	delete_colortable
		rts

;---

th_deaction_11
		move.w	#th_mask,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_18
		move.w	#th_invul,d0
		bsr	ta_deactivate_text
		movea.l	play_dat_ptr,a1
		clr.w	pd_invul(a1)
		rts
				
;---

th_deaction_19
		move.w	#th_invis,d0
		bsr	ta_deactivate_text
		movea.l	play_dat_ptr,a1
		clr.w	pd_invis(a1)
		rts

;---

th_deaction_24					
		move.w	#th_radsuit,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_25
		move.w	#-1,pl_left_nb

		moveq	#1,d0
		bsr	pls_remove

		move.w	#th_geigercount,d0
		bsr	ta_deactivate_text

		bsr	pl_clear_info

		rts

;---

th_deaction_28
		move.w	#th_mondetector,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_29
		move.w	#th_plan,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_41
		move.w	#th_welder,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_46
		move.w	#th_littleplan,d0
		bsr	ta_deactivate_text
		rts

;---

th_deaction_56
		move.w	#th_geninvul,d0
		bsr	ta_deactivate_text
		movea.l	play_dat_ptr,a1
		clr.w	pd_invul(a1)
		rts
				
;---

th_deaction_57
		move.w	#th_geninvis,d0
		bsr	ta_deactivate_text
		movea.l	play_dat_ptr,a1
		clr.w	pd_invis(a1)
		rts

;---

th_deaction_67
		move.w	#th_bierkrug,d0
		bsr	ta_deactivate_text

                rts

;---

th_deaction_68
		move.w	#th_trndetector,d0
		bsr	ta_deactivate_text

                rts

;-----------------------

; d0: health
; d7: health_schon_100 (0 = nein, 1 = ja)

th_add_health
		move.w	#1,plf_energy
		movea.l	play_dat_ptr,a1
		move.w	pd_health(a1),d1
		cmpi.w	#100*256,d1
		beq.s	thah_still_100
		ext.l	d1
		ext.l	d0
		add.l	d0,d1
		cmpi.l	#100*256,d1
		blt.s	thah_ok
		move.w	#100*256,d1
thah_ok		move.w	d1,pd_health(a1)
		moveq	#0,d7
		rts

thah_still_100
		moveq	#1,d7
		rts

;-----------------------

; d0: armor
; d7: armor_schon_100 (0 = nein, 1 = ja)

th_add_armor
		move.w	#1,plf_shield
		movea.l	play_dat_ptr,a1
		move.w	pd_armor(a1),d1
		cmpi.w	#100*256,d1
		beq.s	thaa_still_100
		ext.l	d1
		ext.l	d0
		add.w	d0,d1
		cmpi.l	#100*256,d1
		blt.s	thaa_ok
		move.w	#100*256,d1
thaa_ok		move.w	d1,pd_armor(a1)
		moveq	#0,d7
		rts

thaa_still_100
		moveq	#1,d7
		rts


