

; routinen zum laden, speichern und
; konvertieren von levels

; vorhandene routinen

; - convert_level_addresses_for_save
; - convert_level_addresses_for_load
; - convert_game_addresses_for_save
; - convert_game_addresses_for_load

; - load_episode_level
; - load_level
; - save_level
; - load_game
; - save_game

;**************************************
;* convert_level_addresses_for_save
;**************************************

; uebergabe: a0: adresse level
;            d0: zu korrigierendes offset 

convert_level_addresses_for_save

		movem.l	d0-a6,-(sp)

		bsr	cla_trains
		bsr	cla_monsters
		bsr	cla_files
		bsr	cla_boden
		bsr	cla_startpoint
		bsr	cla_init_data
		bsr	cla_color_tab
		bsr	cla_pistol
		bsr	cla_initlevel
		bsr	cla_cameras
		bsr	cla_infos
		bsr	cla_timelimit
		bsr	cla_sectors

		movem.l	(sp)+,d0-a6

		rts

;--------------------------------------

cla_trains
		movea.l	lev_trains(a0),a1
		sub.l	d0,lev_trains(a0)

		sub.l	d0,trn_data(a1)
		movea.l	trn_move(a1),a2
		sub.l	d0,trn_move(a1)
		move.w	trn_max_anz(a1),d7
		subq.w	#1,d7
		bmi.s	clat_out
clat_loop	sub.l	d0,tm_pointer_mdat(a2)
		lea	tm_data_length(a2),a2
		dbra	d7,clat_loop
clat_out
		rts

;--------------------------------------

cla_monsters
		movea.l	lev_monsters(a0),a1
		sub.l	d0,lev_monsters(a0)

		movea.l	mon_dat(a1),a2
clamd_loop	move.l	(a2)+,d3
		bmi.s	clamd_out
		sub.l	d0,-4(a2)
		movea.l	d3,a3
		move.l	mon_thing_typ(a3),d3
		beq.s	clamd_loop
		sub.l	d0,mon_thing_typ(a3)
		movea.l	d3,a4
		move.l	thing_animation(a4),d5
		beq.s	clamdos_tnoanim
		sub.l	d0,thing_animation(a4)
		movea.l	d5,a5
		sub.l	d0,animation_data(a5)
clamdos_tnoanim	bra.s	clamd_loop

clamd_out

		movea.l	mon_sdat(a1),a2
clamsd_loop	move.l	(a2)+,d3
		bmi.s	clamsd_out
		sub.l	d0,-4(a2)
		bra.s	clamsd_loop
clamsd_out

		sub.l	d0,mon_dat(a1)
		sub.l	d0,mon_sdat(a1)

		rts		

;--------------------------------------

cla_files

	; zuerst die grafiken ...

		movea.l	lev_files(a0),a1
		sub.l	d0,lev_files(a0)
claf_loop
		move.l	(a1)+,d1
		beq.s	claf_fertig
		sub.l	d0,-4(a1)
		addq.l	#4,a1
		bra.s	claf_loop

claf_fertig

	; jetzt die samples ...

clafs_loop
		move.l	(a1)+,d1
		beq.s	claf_out
		sub.l	d0,-4(a1)
		addq.l	#4,a1
		bra.s	clafs_loop

claf_out
		rts		

;--------------------------------------

cla_boden
		movea.l	lev_boden(a0),a1
		sub.l	d0,lev_boden(a0)
		moveq	#7,d7
clab_loop	sub.l	d0,(a1)+
		dbra	d7,clab_loop

		rts		

;--------------------------------------

cla_startpoint
		sub.l	d0,lev_startpoint(a0)
		rts		

;--------------------------------------

cla_init_data
		movea.l	lev_init_data(a0),a1
		sub.l	d0,lev_init_data(a0)
		sub.l	d0,init_as0(a1)
		sub.l	d0,init_as1(a1)
		sub.l	d0,init_as2(a1)
		sub.l	d0,init_as3(a1)
		sub.l	d0,init_as4(a1)
		sub.l	d0,init_vissec_ptr(a1)
		sub.l	d0,init_needed_tt(a1)

		rts		

;--------------------------------------

cla_color_tab
		movea.l	lev_color_tab(a0),a1
		sub.l	d0,lev_color_tab(a0)
		moveq	#7,d7
clact_loop	sub.l	d0,(a1)+
		dbra	d7,clact_loop

		rts		

;--------------------------------------

cla_pistol
		movea.l	lev_pistol(a0),a1
		sub.l	d0,lev_pistol(a0)

		movea.l	pistol_files(a1),a2
		sub.l	d0,pistol_files(a1)
		moveq	#4,d7
clapf_loop	sub.l	d0,(a2)+
		dbra	d7,clapf_loop

		movea.l	pistol_info(a1),a2
		sub.l	d0,pistol_info(a1)
		moveq	#4,d7
clapi_loop	sub.l	d0,(a2)+
		dbra	d7,clapi_loop

		rts		

;--------------------------------------

cla_initlevel
		movea.l	lev_initlevel(a0),a1
		sub.l	d0,lev_initlevel(a0)
		sub.l	d0,ilev_lostthings(a1)
		sub.l	d0,ilev_munition(a1)

		rts		

;--------------------------------------

cla_infos
		movea.l	lev_infos(a0),a1
		sub.l	d0,lev_infos(a0)

		sub.l	d0,li_name_ptr(a1)
		sub.l	d0,li_len_txt_ptr(a1)
		sub.l	d0,li_leq_txt_ptr(a1)
		sub.l	d0,li_lek_txt_ptr(a1)
		sub.l	d0,li_let_txt_ptr(a1)
		sub.l	d0,li_auftrag_ptr(a1)
		rts

;--------------------------------------

cla_cameras
		movea.l	lev_cameras(a0),a1
		sub.l	d0,lev_cameras(a0)

		moveq	#15,d7
clac_loop	sub.l	d0,(a1)+
		dbra	d7,clac_loop

		rts		

;--------------------------------------

cla_timelimit
		sub.l	d0,lev_timelimit(a0)
		rts		

;--------------------------------------

cla_sectors
		lea	lev_sec_start(a0),a1

clas_loop
		move.l	(a1),d1
		bmi.s	clas_out

		sub.l	d0,(a1)+
		movea.l	d1,a2
		bsr	clas_one_sector
		bra.s	clas_loop

clas_out
		rts		

;---

clas_one_sector

		bsr	clasos_aktion
		bsr	clasos_lines
		bsr	clasos_points
		bsr	clasos_doors
		bsr	clasos_lift
		bsr	clasos_things
		bsr	clasos_mon_line
		bsr	clasos_schalter
		bsr	clasos_sect
		bsr	clasos_osect

		rts

;---

clasos_aktion

	; aktion

		sub.l	d0,sec_aktion(a2)
		rts

;---

clasos_lines

	; linien

		sub.l	d0,sec_lines(a2)
		rts

;---

clasos_points

	; punkte

		sub.l	d0,sec_points(a2)
		rts

;---

clasos_doors

	; tueren eines sektors

		move.l	sec_doors(a2),d3
		beq.s	clasos_no_doors

		sub.l	d0,sec_doors(a2)
		movea.l	d3,a3
clasos_dloop	tst.l	(a3)
		bmi.s	clasos_no_doors
		sub.l	d0,(a3)+
		bra.s	clasos_dloop
clasos_no_doors
		rts

;---

clasos_lift

	; lift eines sektors

		move.l	sec_lift(a2),d3
		beq.s	clasos_no_lift

		sub.l	d0,sec_lift(a2)
		movea.l	d3,a3
		sub.l	d0,lift_sec_ptr(a3)

clasos_no_lift	
		rts

;---

clasos_things

	; gegenstaende eines sektors

		move.l	sec_things(a2),d3
		beq.s	clasos_no_things

		sub.l	d0,sec_things(a2)
		movea.l	d3,a3
clasos_tloop	move.l	(a3)+,d3
		bmi.s	clasos_no_things

		sub.l	d0,-4(a3)
		movea.l	d3,a4
		move.l	thing_animation(a4),d5
		beq.s	clasos_tnoanim
		sub.l	d0,thing_animation(a4)
		movea.l	d5,a5
		sub.l	d0,animation_data(a5)
clasos_tnoanim

		cmpi.w	#th_terminal,thing_type(a4)
		bne.s	clasos_tnoterm
		sub.l	d0,thing_action(a4)
clasos_tnoterm

		bra.s	clasos_tloop

clasos_no_things
		rts

;---

clasos_mon_line

	; bewegungslinien eines sektors

		move.l	sec_mon_line(a2),d3
		beq.s	clasos_no_monline

		sub.l	d0,sec_mon_line(a2)
		movea.l	d3,a3
clasos_mloop	tst.l	(a3)
		bmi.s	clasos_no_monline

		sub.l	d0,(a3)
		addq.l	#8,a3
		bra.s	clasos_mloop

clasos_no_monline
		rts

;---

clasos_schalter

	; schalter eines sektors

		move.l	sec_schalter(a2),d3
		beq.s	clasos_no_schalter

		sub.l	d0,sec_schalter(a2)
		movea.l	d3,a3
clasos_sloop	move.l	(a3)+,d3
		bmi.s	clasos_no_schalter

		sub.l	d0,-4(a3)
		movea.l	d3,a4
		move.l	sch_animation(a4),d5
		beq.s	clasos_snoanim
		movea.l	d5,a5
		sub.l	d0,animation_data(a5)
		sub.l	d0,sch_animation(a4)
clasos_snoanim
		
		move.w	sch_zustand_anz(a4),d7
		beq.s	clasos_seinfach

		; wir haben einen schalter
		; mit mehreren zustaenden

		subq.w	#1,d7
		lea	sch_action_ptr(a4),a5
clasos_smloop	move.l	(a5)+,d6
		sub.l	d0,-4(a5)
		movea.l	d6,a6
		cmpi.w	#th_terminal,(a6)
		bne.s	clasos_sm_noterm
		sub.l	d0,2(a6)
clasos_sm_noterm
		dbra	d7,clasos_smloop
		bra.s	clasos_zustand_ok

clasos_seinfach
		; wir haben einen schalter
		; mit einem einfachen zustand

		cmpi.w	#th_terminal,sch_type(a4)
		bne.s	clasos_s_noterm
		sub.l	d0,sch_action_ptr(a4)
clasos_s_noterm

clasos_zustand_ok

		bra.s	clasos_sloop

clasos_no_schalter

		rts

;---

clasos_sect

	; laufbereiche eines sektors

		sub.l	d0,sec_sect(a2)
		rts

;---

clasos_osect

	; uebergangsbereiche eines sektors

		sub.l	d0,sec_osect(a2)
		rts



;**************************************
;* convert_level_addresses_for_load
;**************************************

; uebergabe: a0: adresse level
;            d0: zu korrigierendes offset 

convert_level_addresses_for_load

		movem.l	d0-a6,-(sp)

		bsr	clal_trains
		bsr	clal_monsters
		bsr	clal_files
		bsr	clal_boden
		bsr	clal_startpoint
		bsr	clal_init_data
		bsr	clal_color_tab
		bsr	clal_pistol
		bsr	clal_initlevel
		bsr	clal_cameras
		bsr	clal_infos
		bsr	clal_timelimit
		bsr	clal_sectors

		movem.l	(sp)+,d0-a6

		rts

;--------------------------------------

clal_trains
		add.l	d0,lev_trains(a0)
		movea.l	lev_trains(a0),a1
		add.l	d0,trn_data(a1)
		add.l	d0,trn_move(a1)
		movea.l	trn_move(a1),a2
		move.w	trn_max_anz(a1),d7
		subq.w	#1,d7
		bmi.s	clalt_out
clalt_loop	add.l	d0,tm_pointer_mdat(a2)
		lea	tm_data_length(a2),a2
		dbra	d7,clalt_loop
clalt_out
		rts

;--------------------------------------

clal_monsters
		add.l	d0,lev_monsters(a0)
		movea.l	lev_monsters(a0),a1

		add.l	d0,mon_dat(a1)
		movea.l	mon_dat(a1),a2
clalmd_loop	tst.l	(a2)
		bmi.s	clalmd_out
		add.l	d0,(a2)
		movea.l	(a2)+,a3
		tst.l	mon_thing_typ(a3)
		beq.s	clalmd_loop
		add.l	d0,mon_thing_typ(a3)
		movea.l	mon_thing_typ(a3),a4
		tst.l	thing_animation(a4)
		beq.s	clalmdos_tnoan
		add.l	d0,thing_animation(a4)
		movea.l	thing_animation(a4),a5
		add.l	d0,animation_data(a5)
clalmdos_tnoan	bra.s	clalmd_loop

clalmd_out

		add.l	d0,mon_sdat(a1)
		movea.l	mon_sdat(a1),a2
		moveq	#0,d7
clalmsd_loop	tst.l	(a2)
		bmi.s	clalmsd_out
		addq.w	#1,d7
		add.l	d0,(a2)+
		bra.s	clalmsd_loop
clalmsd_out

		rts		

;--------------------------------------

clal_files

	; zuerst die grafiken ...

		add.l	d0,lev_files(a0)
		movea.l	lev_files(a0),a1
		
clalf_loop
		tst.l	(a1)+
		beq.s	clalf_fertig
		add.l	d0,-4(a1)
		addq.l	#4,a1
		bra.s	clalf_loop

clalf_fertig

	; jetzt die samples ...

clalfs_loop
		tst.l	(a1)+
		beq.s	clalf_out
		add.l	d0,-4(a1)
		addq.l	#4,a1
		bra.s	clalfs_loop

clalf_out
		rts		

;--------------------------------------

clal_boden
		add.l	d0,lev_boden(a0)
		movea.l	lev_boden(a0),a1
		moveq	#7,d7
clalb_loop	add.l	d0,(a1)+
		dbra	d7,clalb_loop

		rts		

;--------------------------------------

clal_startpoint
		add.l	d0,lev_startpoint(a0)
		rts		

;--------------------------------------

clal_init_data
		add.l	d0,lev_init_data(a0)
		movea.l	lev_init_data(a0),a1
		add.l	d0,init_as0(a1)
		add.l	d0,init_as1(a1)
		add.l	d0,init_as2(a1)
		add.l	d0,init_as3(a1)
		add.l	d0,init_as4(a1)
		add.l	d0,init_vissec_ptr(a1)
		add.l	d0,init_needed_tt(a1)

		rts		

;--------------------------------------

clal_color_tab
		add.l	d0,lev_color_tab(a0)
		movea.l	lev_color_tab(a0),a1
		moveq	#7,d7
clalct_loop	add.l	d0,(a1)+
		dbra	d7,clalct_loop

		rts		

;--------------------------------------

clal_pistol
		add.l	d0,lev_pistol(a0)
		movea.l	lev_pistol(a0),a1

		add.l	d0,pistol_files(a1)
		movea.l	pistol_files(a1),a2
		moveq	#4,d7
clalpf_loop	add.l	d0,(a2)+
		dbra	d7,clalpf_loop

		add.l	d0,pistol_info(a1)
		movea.l	pistol_info(a1),a2
		moveq	#4,d7
clalpi_loop	add.l	d0,(a2)+
		dbra	d7,clalpi_loop

		rts		

;--------------------------------------

clal_initlevel
		add.l	d0,lev_initlevel(a0)
		movea.l	lev_initlevel(a0),a1
		add.l	d0,ilev_lostthings(a1)
		add.l	d0,ilev_munition(a1)

		rts		

;--------------------------------------

clal_infos
		add.l	d0,lev_infos(a0)
		movea.l	lev_infos(a0),a1

		add.l	d0,li_name_ptr(a1)
		add.l	d0,li_len_txt_ptr(a1)
		add.l	d0,li_leq_txt_ptr(a1)
		add.l	d0,li_let_txt_ptr(a1)
		add.l	d0,li_lek_txt_ptr(a1)
		add.l	d0,li_auftrag_ptr(a1)
		rts

;--------------------------------------

clal_cameras
		add.l	d0,lev_cameras(a0)
		movea.l	lev_cameras(a0),a1

		moveq	#15,d7
clalc_loop	add.l	d0,(a1)+
		dbra	d7,clalc_loop

		rts		

;--------------------------------------

clal_timelimit
		add.l	d0,lev_timelimit(a0)
		rts		

;--------------------------------------

clal_sectors
		lea	lev_sec_start(a0),a1

clals_loop
		tst.l	(a1)
		bmi.s	clals_out

		add.l	d0,(a1)
		movea.l	(a1)+,a2
		bsr	clals_one_sector
		bra.s	clals_loop

clals_out
		rts		

;---

clals_one_sector

		bsr	clalsos_aktion
		bsr	clalsos_lines
		bsr	clalsos_points
		bsr	clalsos_doors
		bsr	clalsos_lift
		bsr	clalsos_things
		bsr	clalsos_mon_line
		bsr	clalsos_schalter
		bsr	clalsos_sect
		bsr	clalsos_osect

		rts

;---

clalsos_aktion

	; aktion

		add.l	d0,sec_aktion(a2)
		rts

;---

clalsos_lines

	; linien

		add.l	d0,sec_lines(a2)
		rts

;---

clalsos_points

	; punkte

		add.l	d0,sec_points(a2)
		rts

;---

clalsos_doors

	; tueren eines sektors

		tst.l	sec_doors(a2)
		beq.s	clalsos_no_doors

		add.l	d0,sec_doors(a2)
		movea.l	sec_doors(a2),a3
clalsos_dloop	tst.l	(a3)
		bmi.s	clalsos_no_doors
		add.l	d0,(a3)+
		bra.s	clalsos_dloop
clalsos_no_doors
		rts

;---

clalsos_lift

	; lift eines sektors

		tst.l	sec_lift(a2)
		beq.s	clalsos_no_lift

		add.l	d0,sec_lift(a2)
		movea.l	sec_lift(a2),a3
		add.l	d0,lift_sec_ptr(a3)
clalsos_no_lift	
		rts

;---

clalsos_things

	; gegenstaende eines sektors

		tst.l	sec_things(a2)
		beq.s	clalsos_no_things

		add.l	d0,sec_things(a2)
		movea.l	sec_things(a2),a3
clalsos_tloop	tst.l	(a3)
		bmi.s	clalsos_no_things

		add.l	d0,(a3)
		movea.l	(a3)+,a4
		tst.l	thing_animation(a4)
		beq.s	clalsos_tnoanim
		add.l	d0,thing_animation(a4)
		movea.l	thing_animation(a4),a5
		add.l	d0,animation_data(a5)
clalsos_tnoanim

		cmpi.w	#th_terminal,thing_type(a4)
		bne.s	clalsos_tnoterm
		add.l	d0,thing_action(a4)
clalsos_tnoterm

		bra.s	clalsos_tloop

clalsos_no_things
		rts

;---

clalsos_mon_line

	; bewegungslinien eines sektors

		tst.l	sec_mon_line(a2)
		beq.s	clalsos_no_monline

		add.l	d0,sec_mon_line(a2)
		movea.l	sec_mon_line(a2),a3
clalsos_mloop	tst.l	(a3)
		bmi.s	clalsos_no_monline

		add.l	d0,(a3)
		addq.l	#8,a3
		bra.s	clalsos_mloop

clalsos_no_monline
		rts

;---

clalsos_schalter

	; schalter eines sektors

		tst.l	sec_schalter(a2)
		beq.s	clalsos_no_schalter

		add.l	d0,sec_schalter(a2)
		movea.l	sec_schalter(a2),a3
clalsos_sloop	tst.l	(a3)
		bmi.s	clalsos_no_schalter

		add.l	d0,(a3)
		movea.l	(a3)+,a4
		tst.l	sch_animation(a4)
		beq.s	clalsos_snoanim
		add.l	d0,sch_animation(a4)
		movea.l	sch_animation(a4),a5
		add.l	d0,animation_data(a5)
clalsos_snoanim
		
		move.w	sch_zustand_anz(a4),d7
		beq.s	clalsos_seinfach

		; wir haben einen schalter
		; mit mehreren zustaenden

		subq.w	#1,d7
		lea	sch_action_ptr(a4),a5
clalsos_smloop	add.l	d0,(a5)
		movea.l	(a5)+,a6
		cmpi.w	#th_terminal,(a6)
		bne.s	clalsos_sm_noterm
		add.l	d0,2(a6)
clalsos_sm_noterm
		dbra	d7,clalsos_smloop
		bra.s	clalsos_zustand_ok

clalsos_seinfach
		; wir haben einen schalter
		; mit einem einfachen zustand

		cmpi.w	#th_terminal,sch_type(a4)
		bne.s	clalsos_s_noterm
		add.l	d0,sch_action_ptr(a4)
clalsos_s_noterm

clalsos_zustand_ok

		bra.s	clalsos_sloop

clalsos_no_schalter

		rts

;---

clalsos_sect

	; laufbereiche eines sektors

		add.l	d0,sec_sect(a2)
		rts

;---

clalsos_osect

	; uebergangsbereiche eines sektors

		add.l	d0,sec_osect(a2)
		rts


;**************************************
;* convert_game_addresses_for_save
;**************************************

; d0: offset-wert

convert_game_addresses_for_save

	; an_doors_ptr

		lea	an_doors_ptr,a0
		move.w	#anim_doors_max-1,d1
cgasad_loop	tst.l	(a0)+
		beq.s	cgasad_skip
		sub.l	d0,-4(a0)
cgasad_skip	dbra	d1,cgasad_loop

	; an_lifts_ptr

		lea	an_lifts_ptr,a0
		move.w	#anim_lifts_max-1,d1
cgasal_loop	tst.l	(a0)+
		beq.s	cgasal_skip
		sub.l	d0,-4(a0)
cgasal_skip	dbra	d1,cgasal_loop

		rts


;**************************************
;* convert_game_addresses_for_load
;**************************************

; d0: offset-wert

convert_game_addresses_for_load

	; an_doors_ptr

		lea	an_doors_ptr,a0
		move.w	#anim_doors_max-1,d1
cgalad_loop	tst.l	(a0)+
		beq.s	cgalad_skip
		add.l	d0,-4(a0)
cgalad_skip	dbra	d1,cgalad_loop

	; an_lifts_ptr

		lea	an_lifts_ptr,a0
		move.w	#anim_lifts_max-1,d1
cgalal_loop	tst.l	(a0)+
		beq.s	cgalal_skip
		add.l	d0,-4(a0)
cgalal_skip	dbra	d1,cgalal_loop

		rts


;**************************************
;* load_level
;**************************************

; a0 = filename

load_level

		move.l	a0,file_name_ptr
		move.l	#level_max_gr,file_size
		move.l	#level,file_buf_ptr

		bsr	load_file

		lea	level,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_load

		rts


;**************************************
;* save_level
;**************************************

; a0: filename

save_level

		move.l	a0,file_name_ptr
		movea.l	big_sector_ptr,a0
		move.l	lev_groesse(a0),file_size
		move.l	a0,file_buf_ptr

		movea.l	big_sector_ptr,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_save

		bsr	save_file

		movea.l	big_sector_ptr,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_load

		rts


;**************************************
;* save_game
;**************************************

; a0: filename

save_game
		clr.w	sg_error_flag

	; file oeffnen

		clr.w	-(sp)
		move.l	a0,-(sp)
		move.w	#60,-(sp)	; f_create
		trap	#1
		addq.l	#8,sp
		tst.w	d0
		bmi	sg_error
		move.w	d0,d7

	; kennung schreiben

		pea	sg_kennung(pc)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; beschreibung schreiben

		pea	mnu_beschreibung
		moveq	#20,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; episode und level schreiben

		pea	episode
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; vorschaubild schreiben

		move.l	mnu_pic_ptr,-(sp)
		move.l	#38400,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; interne variablen schreiben

		move.l	big_sector_ptr,d0
		bsr	convert_game_addresses_for_save

		pea	loadsave_start
		move.l	#loadsave_end-loadsave_start,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

		move.l	big_sector_ptr,d0
		bsr	convert_game_addresses_for_load
			
	; levelgroesse schreiben

		movea.l	big_sector_ptr,a0
		pea	lev_groesse(a0)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; leveldaten konvertieren und schreiben		

		movea.l	big_sector_ptr,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_save
		
		move.l	a0,-(sp)
		move.l	lev_groesse(a0),d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error
		
		movea.l	big_sector_ptr,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_load

	; endkennung schreiben

		pea	sg_endkennung(pc)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#64,-(sp)
		trap	#1
		lea	12(sp),sp
		cmp.l	d0,d6
		bne	sg_error

	; file schliessen

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		tst.w	d0
		bmi	sg_error

		rts


;**************************************
;* load_game
;**************************************

; a0: filename
; a6: buffer
; d5: 0 = gesamt
;     1 = nur bis beschreibung
;     2 = nur bis vorschaubild
;     3 = nur bis interne variablen

load_game

		clr.w	sg_error_flag

	; file oeffnen

		clr.w	-(sp)
		move.l	a0,-(sp)
		move.w	#61,-(sp)	
		trap	#1
		addq.l	#8,sp
		move.w	#10,sg_error_code
		tst.w	d0
		bmi	sg_error
		move.w	d0,d7

	; kennung lesen

		move.l	a6,-(sp)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#11,sg_error_code
		cmp.l	d0,d6
		bne	sg_error
		adda.l	d6,a6
	
	; kennung ueberpruefen

		move.l	-4(a6),d0
		move.w	#12,sg_error_code
		cmp.l	sg_kennung,d0
		bne	sg_error

	; beschreibung lesen

		move.l	a6,-(sp)
		moveq	#20,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#13,sg_error_code
		cmp.l	d0,d6
		bne	sg_error
		adda.l	d6,a6

	; episode und level lesen

		move.l	a6,-(sp)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#14,sg_error_code
		cmp.l	d0,d6
		bne	sg_error
		adda.l	d6,a6
	
		cmpi.w	#1,d5
		beq	lg_close

	; vorschaubild lesen

		move.l	a6,-(sp)
		move.l	#38400,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#15,sg_error_code
		cmp.l	d0,d6
		bne	sg_error
		adda.l	d6,a6

		cmpi.w	#2,d5
		beq	lg_close

	; interne variablen lesen

		move.l	a6,-(sp)
		move.l	#loadsave_end-loadsave_start,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#16,sg_error_code
		cmp.l	d0,d6
		bne	sg_error
		adda.l	d6,a6

		cmpi.w	#3,d5
		beq.s	lg_close
			
	; levelgroesse lesen

		move.l	a6,-(sp)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#17,sg_error_code
		cmp.l	d0,d6
		bne.s	sg_error
		adda.l	d6,a6

	; leveldaten lesen		

		move.l	a6,-(sp)
		move.l	-4(a6),d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#18,sg_error_code
		cmp.l	d0,d6
		bne.s	sg_error
		adda.l	d6,a6
		
	; endkennung lesen

		move.l	a6,-(sp)
		moveq	#4,d6
		move.l	d6,-(sp)
		move.w	d7,-(sp)
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		move.w	#19,sg_error_code
		cmp.l	d0,d6
		bne.s	sg_error
		adda.l	d6,a6

	; endkennung ueberpruefen

		move.l	-4(a6),d0
		move.w	#20,sg_error_code
		cmp.l	sg_endkennung,d0
		bne.s	sg_error

lg_close

	; file schliessen

		move.w	d7,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		move.w	#21,sg_error_code
		tst.w	d0
		bmi.s	sg_error

		rts

;---

sg_error	
		move.w	#-1,sg_error_code

		move.w	#1,sg_error_flag
		rts


;**************************************
;* load_episode_level
;**************************************

; laedt den richtigen level 
; entsprechend den variablen 
; episode und level in den speicher ...

load_episode_level

		lea	episode,a6
		movem.w	(a6),d6-d7		; episode und level

		ifeq	compile_level		
		lea	level_files,a0
		movea.l	lf_episode_ptr(a0,d6.w*4),a0
		movea.l	lf_level_ptr(a0,d7.w*4),a0
		bsr	load_level
		endc

		nop

		ifne	episode_check

		movem.w	episode,d2-d3
		lea	level,a0		; spiel liegt bei level
		movea.l	lev_infos(a0),a0	; und nicht bei big_sector_ptr
		move.w	li_episode(a0),d0
		move.w	li_level(a0),d1

	; -------------------
	; episode vergleichen

		cmp.w	d0,d2
		beq.s	lel_epi_ok

		move.l	file_name_ptr(pc),sst_message
		move.w	#7,sst_code
		bsr	stop_system
lel_epi_ok

		cmp.w	d1,d3
		beq.s	lel_lev_ok

		move.l	file_name_ptr(pc),sst_message
		move.w	#7,sst_code
		bsr	stop_system
lel_lev_ok

		endc

		
		rts

;-----------------------

sg_kennung	dc.b	"RUNX"
sg_endkennung	dc.b	"FICK"
sg_32bit_temp	ds.b	4

sg_error_code	dc.w	-1
sg_error_flag	dc.w	0

