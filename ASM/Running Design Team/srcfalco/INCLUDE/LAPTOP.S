;**************************************
;* make_laptop
;**************************************

		include	"include\codes.s"

make_laptop

		clr.b	keytable+$26

		move.l	vbl_count,-(sp)
		move.w	double_scan,-(sp)
		move.w	cinemascope,-(sp)
		move.l	true_offi,-(sp)

	; aktuellen screen zwischenspeichern
	; benutze als puffer truecolor_tab,
	; dabei ggf. die aufloesung umwandeln ...

		bsr	ml_screenshot
		bsr	ml_save_screenshot

	; richtige aufloesung setzen ...

		move.l	#640,true_offi
		clr.w	double_scan
		clr.w	cinemascope
                move.w  #1,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	ml_no_vga
		move.l	#si_320x240vga,screen_init_rout_ptr
ml_no_vga

	; grafik laden ...

		move.l	#ml_file,file_name_ptr
		move.l	#128128,file_size
		move.l	screen_1,d0
		subi.l	#128,d0
		move.l	d0,file_buf_ptr
		bsr	load_file

		bsr	plcc_now
		bsr	paint_leiste

		bsr	vsync
		bsr	swap_me

	; laptop initialisieren ...

		clr.w	ml_quit_flag
		clr.w	ml_sx
		clr.w	mlc_pos		; command 
		clr.b	ml_command	; loeschen

	; laptop hochfahren ...

		lea	ml_init_txt(pc),a0
		move.w	#2,ml_sy
		bsr	ml_paint_text
		move.l	ml_sx(pc),-(sp)

		lea	ml_commands_txt(pc),a0
		tst.l	ml_connect_addr
		beq.s	ml_hoch_no_term
		lea	ml_com_term_txt(pc),a0		
ml_hoch_no_term	clr.w	ml_sy
		move.w	#1,mlpt_mode
		bsr	ml_paint_text
		move.l	(sp)+,ml_sx

	; prompt zeichnen ...

		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

ml_main

		jsr	jagpad_simul

	; cursor zeichnen ...

		movea.l	screen_2,a6
		adda.l	#ml_offset,a6
		move.w	ml_sy(pc),d3
		mulu	#(ml_font_heigth+1)*640,d3
		adda.l	d3,a6
		move.w	ml_sx(pc),d3
		lsl.w	#3,d3
		adda.w	d3,a6

		moveq	#0,d6
		move.b	vbl_count+3,d6
		move.b	d6,d7
		lsl.w	#8,d6
		add.b	d7,d6
		move.w	d6,d7
		swap	d6
		add.w	d7,d6
		move.l	d6,d5
		moveq	#ml_font_heigth-1,d7
mlm_cursor	movem.l	d5-d6,(a6)
		lea	640(a6),a6
		dbra	d7,mlm_cursor

	; auf eingabe warten ...

		jsr	get_next_ascii
		tst.b	d0
		beq	ml_no_ascii

	; es ist eine ascii-taste

		move.w	d0,d7
		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam
		move.w	d7,d0

		cmpi.b	#13,d0
		beq	mlmc_command

		cmpi.b	#8,d0
		bne.s	ml_no_backspace

	; backspace ist nur sinnvoll, wenn noch zeichen
	; zum loeschen vorhanden sind ...

		lea	mlc_pos(pc),a0
		move.w	(a0),d1
		beq	ml_no_ascii		; nichts zu loeschen

	; ml_command abaendern ...

		subq.w	#1,d1
		move.w	d1,(a0)
		lea	ml_command(pc),a0
		clr.b	(a0,d1.w)

	; an der aktuellen cursorposition ein
	; schwarzes feld zeichnen
		
		movea.l	screen_2,a6
		adda.l	#ml_offset,a6
		move.w	ml_sy(pc),d3
		mulu	#(ml_font_heigth+1)*640,d3
		adda.l	d3,a6
		move.w	ml_sx(pc),d3
		lsl.w	#3,d3
		adda.w	d3,a6

		moveq	#ml_font_heigth-1,d7
mlback_cursor	clr.l	(a6)
		clr.l	4(a6)
		lea	640(a6),a6
		dbra	d7,mlback_cursor

	; ml_sx und ml_sy aendern ...

		lea	ml_sx(pc),a0
		movem.w	(a0),d1-d2		; ml_sx, ml_sy
		tst.w	d1
		beq.s	mlxy_change
		subq.w	#1,d1
		bra.s	mlxy_out

mlxy_change
		moveq	#ml_max_spalten-1,d1
		subq.w	#1,d2
mlxy_out
		movem.w	d1-d2,(a0)

		; damit ist backspace fertig

		bra.s	ml_no_ascii

ml_no_backspace

	; normaler buchstabe ...

		cmpi.b	#"a",d0
		blt.s	mlmc_no_small
		subi.b	#$20,d0
mlmc_no_small

		move.w	mlc_pos(pc),d1
		addq.w	#1,d1
		cmp.w	#mlc_max-1,d1
		bge.s	ml_no_ascii
		move.w	d1,mlc_pos

		move.w	d0,-(sp)
		lea	ml_buchstabe(pc),a0
		move.b	d0,(a0)
		bsr	ml_paint_text
		move.w	(sp)+,d0

		lea	ml_command(pc),a0
		move.w	mlc_pos(pc),d1
		move.b	d0,-1(a0,d1.w)
		clr.b	(a0,d1.w)
		bra.s	ml_no_ascii

mlmc_command

	; enter wurde gedrueckt ...

		lea	ml_buchstabe(pc),a0
		move.b	d0,(a0)
		bsr	ml_paint_text

		bsr	mlc_make_com
		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

		clr.b	ml_command
		clr.w	mlc_pos

ml_no_ascii

		lea	keytable,a2
		tst.b	$3d(a2)		; F3
		bne	ml_power_off

		tst.b	$1(a2)		; ESC
		bne	ml_power_off

		tst.b	$3b(a2)		; F1
		beq	ml_no_3b
		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam
		bsr	ml_link
ml_no_3b

		lea	keytable,a2
		tst.b	$3c(a2)		; F2
		beq	ml_no_3c
		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam
		bsr	ml_connect
ml_no_3c

		lea	keytable,a2
		tst.b	$3e(a2)		; F4
		beq	ml_no_3e
		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam
		bsr	mlc18b
ml_no_3e
		bra	ml_main


;--------------------------------------

ml_screenshot

		jsr	get_resolution		; d0/d1: hardware screen resolution

	; dieses bild, dass bei screen_1 liegt und d0/d1 gross ist, muss
	; auf 160x120 verkleinert werden ...

	; bestimme verkleinerungsfaktoren ...

		move.w	d0,d2
		move.w	d1,d3
		swap	d2
		swap	d3
		clr.w	d2
		clr.w	d3
		divu.l	#160,d2
		divu.l	#120,d3

		swap	d2
		moveq	#0,d4
		moveq	#0,d5

		movea.l	screen_1,a1		; hier preview erzeugen

		move.w	#120-1,d6
mlss_loop	movea.l	screen_1,a0		; von hier preview erzeugen
		move.l	d5,d1
		swap	d1
		mulu	d0,d1
		add.l	d1,d1
		adda.l	d1,a0
		add.l	d3,d5

		move.w	#160-1,d7
		moveq	#0,d4
mlss_loop2	move.w	(a0,d4.w*2),(a1)+
		addx.l	d2,d4
		dbra	d7,mlss_loop2

		dbra	d6,mlss_loop

		rts

;---------------

ml_save_screenshot

		move.l	screen_1,file_buf_ptr
		move.l	#ml_screenfile,file_name_ptr
		move.l	#160*120*2,file_size
		jsr	save_file

		rts	

;--------------------------------------

ml_power_off
		clr.b	$3d(a2)
		clr.b	$1(a2)
		clr.b	$3b(a2)

		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam

		lea	ml_buchstabe(pc),a0
		move.b	#13,(a0)
		bsr	ml_paint_text

		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

		lea	ml_poweroff_txt,a0
		bsr	ml_paint_text


	; vorherige aufloesung wieder setzen ...

		move.l	(sp)+,true_offi
		move.w	(sp)+,cinemascope
		move.w	(sp)+,double_scan
		bsr	install_si_routine

		move.w	#2,dont_change_scr
		move.w	#1,clear_it_flag

		move.l	(sp)+,vbl_count

		clr.l	ml_connect_addr

		bsr	laptop_firsttime_out

		rts


;--------------------------------------

laptop_firsttime

		tst.w	lt_firsttime
		beq.s	lft_out
		bmi.s	lft_out

		move.b	#1,keytable+$3b
		move.b	#1,keytable+$26

		move.w	#-1,lt_firsttime

lft_out
		rts
	
;---	

laptop_firsttime_out

		tst.w	lt_firsttime
		bmi.s	lfto_now

		rts

lfto_now
		movea.l	play_dat_ptr,a0
		tst.w	pd_duke_talk(a0)
		bne.s	lfto_out
		move.w	#1,dma_speech_flag
		moveq	#snd_cool,d0
		moveq	#0,d1
		jsr	init_sam		
lfto_out
		clr.w	lt_firsttime

		rts

;---

lt_firsttime	dc.w	0

;---------------

; a0: pointer auf text
; ml_sx
; ml_sy

ml_paint_text

		clr.w	mlpt_lines_anz

ml_paint_text_now

		tst.w	ml_quit_flag
		bne	mlpt_sofort_out

	; bildschirmadresse berechnen ...

		movea.l	screen_2,a6
		adda.l	#ml_offset,a6
		move.w	ml_sy(pc),d3
		mulu	#(ml_font_heigth+1)*640,d3
		adda.l	d3,a6
		move.w	ml_sx(pc),d3
		lsl.w	#3,d3
		adda.w	d3,a6

	; buchstaben zeichnen ...

		lea	font4x5,a5
		move.b	(a0),d2
		beq	mlpt_out

		cmpi.b	#"a",d2
		blt.s	mlpt_no_small
		subi.b	#$20,d2
mlpt_no_small

		subi.b	#"!",d2
		bmi.s	mlpt_space
		ext.w	d2
		mulu	#40,d2
		adda.w	d2,a5

		tst.w	mlpt_mode
		bne.s	mlpt_mode_1

		moveq	#mt_font_heigth-1,d4
mlpt_loop	movem.l	(a5)+,d6-d7
		movem.l	d6-d7,(a6)
		lea	640(a6),a6
		dbra	d4,mlpt_loop
		bra.s	mlpt_buchst_ok
mlpt_mode_1
		moveq	#mt_font_heigth-1,d4
		move.l	#$001a001a,d5
mlpt_loop2	movem.l	(a5)+,d6-d7
		add.l	d5,d6
		add.l	d5,d7
		movem.l	d6-d7,(a6)
		lea	640(a6),a6
		dbra	d4,mlpt_loop2
		bra.s	mlpt_buchst_ok

mlpt_space
		moveq	#0,d6
		moveq	#0,d7
		moveq	#mt_font_heigth-1,d4
mlpt_loop3	movem.l	d6-d7,(a6)
		lea	640(a6),a6
		dbra	d4,mlpt_loop3

mlpt_buchst_ok

		addq.w	#1,ml_sx

	; buchstaben nochmals holen ...

		move.b	(a0)+,d2

	; wenn space, dann berechnen, ob das
	; naechste wort noch in dieselbe
	; zeile passt ...

		cmpi.b	#" ",d2			; space ?
		bne.s	mlpt_no_space

		movea.l	a0,a3
		move.w	ml_sx(pc),d3

mlpt_search_space
		move.b	(a3)+,d4
		cmpi.b	#" ",d4
		beq.s	mlpt_space_found
		cmpi.b	#13,d4
		beq.s	mlpt_space_found
		tst.b	d4
		beq.s	mlpt_space_found

		addq.w	#1,d3
		bra.s	mlpt_search_space
		
mlpt_space_found
		cmpi.w	#ml_max_spalten,d3
		bge.s	mlpt_zeilenvorschub		

mlpt_no_space
		cmpi.b	#13,d2
		bne	mlpt_no_enter

mlpt_zeilenvorschub

		move.l	a0,-(sp)
		moveq	#8,d7
mlptz_wait	jsr	vsync
		dbra	d7,mlptz_wait
		move.l	(sp)+,a0

		clr.w	ml_sx
		move.w	ml_sy(pc),d1
		addq.w	#1,d1
		move.w	d1,ml_sy
		cmpi.w	#ml_max_reihen,d1
		blt	mlpt_no_enter

		move.w	#ml_max_reihen-1,ml_sy

	; bildschirm eine zeile nach oben scrollen

		movea.l	screen_2,a6
		adda.l	#ml_offset+(ml_font_heigth+1)*640*2,a6
		move.w	#(ml_max_reihen-2)*(ml_font_heigth+1)-1,d7
mlpt_scr_loop1	movea.l	a6,a4
		lea	640*ml_font_heigth+640(a4),a5
		move.w	#ml_max_spalten-1,d6
mlpt_scr_loop2	movem.l	(a5)+,d0-d1
		movem.l	d0-d1,(a4)
		addq.l	#8,a4
		dbra	d6,mlpt_scr_loop2
		lea	640(a6),a6
		dbra	d7,mlpt_scr_loop1

	; und letzte zeile loeschen

		movea.l	screen_2,a6
		adda.l	#ml_offset+(ml_font_heigth+1)*640*(ml_max_reihen-1),a6
		move.w	#ml_font_heigth,d7
mlpt_clr_loop1	movea.l	a6,a4
		move.w	#ml_max_spalten-1,d6
mlpt_clr_loop2	clr.l	(a4)+
		clr.l	(a4)+
		dbra	d6,mlpt_clr_loop2
		lea	640(a6),a6
		dbra	d7,mlpt_clr_loop1


		lea	mlpt_lines_anz(pc),a6
		move.w	(a6),d0
		addq.w	#1,d0
		cmpi.w	#ml_aufeinmal,d0
		bne.s	mlpt_ae_no

	; auf space oder enter warten

		moveq	#0,d0

mlpt_ae_wait
		tst.b	keytable+$39
		bne.s	mlpt_ae_sam
		movem.l	d1-a6,-(sp)
		lea	jagpad_routs+4(pc),a0
		jsr	(a0)			; d0 = jagpad a
		movem.l	(sp)+,d1-a6		
		btst	#7,d0
		bne.s	mlpt_ae_sam
		tst.b	keytable+$1
		beq.s	mlpt_ae_no_esc
		move.b	#1,keytable+$3d
		bra	mlpt_sofort_out
mlpt_ae_no_esc	tst.b	keytable+$1c
		beq.s	mlpt_ae_wait		
mlpt_ae_sam

		movem.l	d0-a6,-(sp)
		moveq	#snd_schreibm,d0
		moveq	#0,d1
		jsr	init_sam
		movem.l	(sp)+,d0-a6

mlpt_ae_no	move.w	d0,(a6)



mlpt_no_enter
		move.w	ml_sx(pc),d1
		cmpi.w	#ml_max_spalten,d1
		bge	mlpt_zeilenvorschub

		bra	ml_paint_text_now

;		tst.b	keytable+$39
;		beq	ml_paint_text
;		clr.b	keytable+$39
;		move.w	#1,ml_quit_flag

mlpt_out
mlpt_sofort_out
		clr.w	mlpt_mode

		rts		

;---

mlpt_lines_anz	dc.w	0

;---------------

mlc_make_com
		tst.w	mlc_pos
		beq	mlcmc_out

		lea	mlc_commands(pc),a0

mlcmc_main
		move.l	(a0),d1
		bmi	mlcmc_not_found
		movea.l	d1,a1

		lea	ml_command(pc),a2
mlcmc_loop	move.b	(a2)+,d2
		cmp.b	(a1)+,d2
		bne.s	mlcmc_notcom

		tst.b	d2
		beq.s	mlcmc_found
		bra.s	mlcmc_loop

mlcmc_notcom
		addq.l	#8,a0
		bra.s	mlcmc_main

mlcmc_out
		rts

;---

mlcmc_found
		movea.l	4(a0),a0
		jsr	(a0)
		rts

mlcmc_not_found

		lea	ml_notfound_txt(pc),a0
		bsr	ml_paint_text
		rts

;--------------------------------------

ml_correct_cheats

		lea	mlc_commands(pc),a0
mlcc_loop
		move.l	(a0),d0
		bmi.s	mlcc_out
		movea.l	d0,a1
mlcc_loop2
		move.b	(a1),d0
		beq.s	mlcc_next
		move.b	#180,d1
		sub.b	d0,d1
		move.b	d1,(a1)+

		bra.s	mlcc_loop2

mlcc_next
		addq.l	#8,a0
		bra.s	mlcc_loop

mlcc_out
		rts

;---

mlc0b		move.b	#1,keytable+$3b
		rts
mlc1b		move.b	#1,keytable+$3c
		rts
mlc2b		move.b	#1,keytable+$3d
		rts
mlc3b		lea	mlc3_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc4b		lea	mlc4_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc6b		lea	mlc6_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc8b		lea	mlc8_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc9b		lea	mlc9_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc10b		lea	mlc10_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc12b		lea	mlc12_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc13b		lea	mlc13_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc15b		lea	mlc15_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc16b		lea	mlc16_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc17b		lea	mlc17_txt(pc),a0
		bsr	ml_paint_text
		rts
mlc18b		tst.l	ml_connect_addr(pc)	; stehen wir an einem terminal?
		bne.s	mlc18b_save		; wenn ja, dann speichern moeglich
		lea	mlc18_txt(pc),a0	; wenn nein, dann eine info-message
		bsr	ml_paint_text		; ausgeben ... und raus
		bra.s	mlc18b_out
mlc18b_save	jsr	menue_save
		clr.b	keytable+$1
mlc18b_out	rts
mlc19b		not.w	tmics_flag
		rts
mlc20b		tst.w	dv_flag
		beq.s	mlc20b_enabled
		lea	mlc20_txt2(pc),a0
		bsr	ml_paint_text
		clr.w	dv_flag
		rts
mlc20b_enabled	lea	mlc20_txt1(pc),a0
		bsr	ml_paint_text
		move.w	#1,dv_flag
		rts
mlc21b		lea	mlc21_txt,a0
		bsr	ml_paint_text
		movea.l	play_dat_ptr,a6
		lea	mlc21_txt_p0,a0
		tst.w	pd_primary(a6)
		beq.s	mlc21b_no_p
		lea	mlc21_txt_p1,a0
mlc21b_no_p	bsr	ml_paint_text
		movea.l	play_dat_ptr,a6
		lea	mlc21_txt_s0,a0
		tst.w	pd_secondary(a6)
		beq.s	mlc21b_no_s
		lea	mlc21_txt_s1,a0
mlc21b_no_s	bsr	ml_paint_text
		rts
mlc22b		movea.l	play_dat_ptr,a6
		move.w	#1,pd_which_end(a6)
		rts
mlc23b		movea.l	play_dat_ptr,a6
		move.w	#2,pd_which_end(a6)
		rts
mlcr00b		moveq	#th_red_key,d0
		bra	mlcrb
mlcr01b		moveq	#th_green_key,d0
		bra	mlcrb
mlcr02b		moveq	#th_blue_key,d0
		bra	mlcrb
mlcr03b		moveq	#th_yellow_key,d0
		bra	mlcrb
mlcr04b		moveq	#th_scanner,d0
		bra	mlcrb
mlcr05b		moveq	#th_night,d0
		bra	mlcrb
mlcr06b		moveq	#th_bmedkit_i,d0
		bra	mlcrb
mlcr07b		moveq	#th_barmor,d0
		bra	mlcrb
mlcr08b		moveq	#th_mun0_def,d0
		bra	mlcrb
mlcr09b		moveq	#th_mun1_def,d0
		bra	mlcrb
mlcr10b		moveq	#th_mun2_def,d0
		bra	mlcrb
mlcr11b		moveq	#th_mun3_def,d0
		bra	mlcrb
mlcr12b		moveq	#th_mask,d0
		bra	mlcrb
mlcr13b		moveq	#th_invul,d0
		bra	mlcrb
mlcr14b		moveq	#th_invis,d0
		bra	mlcrb
mlcr15b		moveq	#th_pistol1,d0
		bra	mlcrb
mlcr16b		moveq	#th_pistol2,d0
		bra	mlcrb
mlcr17b		moveq	#th_pistol3,d0
		bra	mlcrb
mlcr18b		moveq	#th_pistol4,d0
		bra	mlcrb
mlcr19b		moveq	#th_radsuit,d0
		bra	mlcrb
mlcr20b		moveq	#th_geigercount,d0
		bra	mlcrb
mlcr21b		moveq	#th_backpack,d0
		bra	mlcrb
mlcr22b		moveq	#th_mondetector,d0
		bra	mlcrb
mlcr23b		moveq	#th_plan,d0
		bra	mlcrb
mlcr24b		moveq	#th_welder,d0
		bra	mlcrb
mlcr25b		moveq	#th_verseuch,d0
		bra	mlcrb
mlcr26b		moveq	#th_level_ende,d0
		bra	mlcrb
mlcr27b		moveq	#th_littleplan,d0
		bra	mlcrb
mlcr28b		moveq	#th_neverget,d0
		bra	mlcrb
mlcr29b		moveq	#th_geninvul,d0
		bra	mlcrb
mlcr30b		moveq	#th_geninvis,d0
		bra	mlcrb
mlcr31b		moveq	#th_color0,d0
		bra	mlcrb
mlcr32b		moveq	#th_color1,d0
		bra	mlcrb
mlcr33b		moveq	#th_color2,d0
		bra	mlcrb
mlcr34b		moveq	#th_color3,d0
		bra	mlcrb
mlcr35b		moveq	#th_color4,d0
		bra	mlcrb
mlcr36b		moveq	#th_color5,d0
		bra	mlcrb
mlcr37b		moveq	#th_color6,d0
		bra	mlcrb
mlcr38b		moveq	#th_color7,d0
		bra	mlcrb
mlcr39b		moveq	#th_primary,d0
		bra	mlcrb
mlcr40b		moveq	#th_secondary,d0
		bra	mlcrb
mlcr41b		moveq	#th_bierkrug,d0
		bra	mlcrb
mlcr42b		moveq	#th_trndetector,d0
		bra	mlcrb
mlcr43b		moveq	#th_dcolor0,d0
		bra	mlcrb
mlcr44b		moveq	#th_dcolor1,d0
		bra	mlcrb
mlcr45b		moveq	#th_dcolor2,d0
		bra	mlcrb
mlcr46b		moveq	#th_dcolor3,d0
		bra	mlcrb
mlcr47b		moveq	#th_dcolor4,d0
		bra	mlcrb
mlcr48b		moveq	#th_dcolor5,d0
		bra	mlcrb
mlcr49b		moveq	#th_dcolor6,d0
		bra	mlcrb
mlcr50b		moveq	#th_dcolor7,d0
		bra	mlcrb
mlcr51b		moveq	#th_condom,d0
		bra	mlcrb
mlcr52b		moveq	#th_idcard,d0
		bra	mlcrb

		nop

mlcrb		lea	tos_thing,a0		
		move.w	d0,thing_type(a0)
		lea	things_routs,a1
		movea.l	-4(a1,d0.w*4),a1
		jsr	(a1)
		move.w	#1,plf_things
		lea	mlcr_txt(pc),a0
		bsr	ml_paint_text
		rts

;---------------

ml_link
		clr.b	$3b(a2)

		lea	ml_link_txt(pc),a0
		bsr	ml_paint_text

		lea	ml_line_txt(pc),a0
		bsr	ml_paint_text

		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		move.l	li_auftrag_ptr(a0),d0
		beq.s	mll_no_auftrag
		movea.l	d0,a0
		bsr	ml_paint_text

mll_close
		lea	ml_line_txt(pc),a0
		bsr	ml_paint_text

		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

		rts

mll_no_auftrag
		lea	ml_noauft_txt(pc),a0
		bsr	ml_paint_text

		bra.s	mll_close
		

;---------------

ml_connect	
		clr.b	$3c(a2)

		lea	ml_connect1_txt(pc),a0
		bsr	ml_paint_text

		tst.l	ml_connect_addr
		beq	mlcon_no_con

		lea	ml_connect2_txt(pc),a0
		bsr	ml_paint_text

		lea	ml_line_txt(pc),a0
		bsr	ml_paint_text
		
		movea.l	ml_connect_addr(pc),a0
		movea.l	(a0),a0
		bsr	ml_paint_text

		lea	ml_line_txt(pc),a0
		bsr	ml_paint_text
		
		lea	ml_close_txt(pc),a0
		bsr	ml_paint_text
		
		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

		rts

mlcon_no_con

	; wir stehen an keinem terminal

		lea	ml_connect3_txt(pc),a0
		bsr	ml_paint_text

		lea	ml_prompt_txt(pc),a0
		bsr	ml_paint_text

		rts

;---------------

ml_quit_flag	dc.w	0

ml_sx		dc.w	0
ml_sy		dc.w	0

mlpt_mode	dc.w	0

ml_connect_addr	dc.l	0

ml_buchstabe	dc.b	0,0

;---

			;12345678901234567890123456789
ml_init_txt	dc.b	"RUNNING BIOS V4.51",13
		dc.b	"SYSTEM IS BOOTING ...",13
		dc.b	"WELCOME TO RUNLAP 030",13,13,0

ml_prompt_txt	dc.b	">",0

ml_notfound_txt	dc.b	"FILE NOT FOUND",13,0

			;12345678901234567890123456789
ml_commands_txt	dc.b	"F1 LINK, F2 CONNECT, F3 EXIT",0
ml_com_term_txt	dc.b	"F1 LINK, F2 CONNECT, F3 EXIT",13
		dc.b	"F4 SAVE",0

ml_link_txt	dc.b	"LINK 132.180.15.14",13
		dc.b	"TRYING 132.180.15.14",13
		dc.b	"CONNECTED TO",13
		dc.b	"RUNNING HEADQUARTERS",13,13,0

ml_noauft_txt	dc.b	"NO MISSION AVAILABLE ...",13,0

ml_connect1_txt	dc.b	"CONNECT TERMINAL",13
		dc.b	"TRYING ...",13,0
ml_connect2_txt	dc.b	"TERMINAL STATION DOCKED",13,13,0
ml_connect3_txt	dc.b	"CONNECTION FAILED",13,13,0

ml_close_txt	dc.b	"CONNECTION CLOSED",13,0

			;12345678901234567890123456789
ml_line_txt	dc.b	"----------------------------",13,0

ml_poweroff_txt	dc.b	"EXIT",13
		dc.b	"SYSTEM HALTED",13
		dc.b	13,0
		even

;---

mlc_max		equ	128

ml_command	ds.b	mlc_max
mlc_pos		dc.w	0

mlc_commands	dc.l	mlc0,mlc0b
		dc.l	mlc1,mlc1b
		dc.l	mlc2,mlc2b
		dc.l	mlc3,mlc3b
		dc.l	mlc4,mlc4b
		dc.l	mlc5,mlc3b
		dc.l	mlc6,mlc6b
		dc.l	mlc7,mlc6b
		dc.l	mlc8,mlc8b
		dc.l	mlc9,mlc9b
		dc.l	mlc10,mlc10b
		dc.l	mlc12,mlc12b
		dc.l	mlc13,mlc13b
		dc.l	mlc15,mlc15b
		dc.l	mlc16,mlc16b
		dc.l	mlc17,mlc17b
		dc.l	mlc18,mlc18b
		dc.l	mlc19,mlc19b
		dc.l	mlc20,mlc20b
		dc.l	mlc21,mlc21b
		dc.l	mlc22,mlc22b
		dc.l	mlc23,mlc23b
		dc.l	mlcr00,mlcr00b
		dc.l	mlcr01,mlcr01b
		dc.l	mlcr02,mlcr02b
		dc.l	mlcr03,mlcr03b
		dc.l	mlcr04,mlcr04b
		dc.l	mlcr05,mlcr05b
		dc.l	mlcr06,mlcr06b
		dc.l	mlcr07,mlcr07b
		dc.l	mlcr08,mlcr08b
		dc.l	mlcr09,mlcr09b
		dc.l	mlcr10,mlcr10b
		dc.l	mlcr11,mlcr11b
		dc.l	mlcr12,mlcr12b
		dc.l	mlcr13,mlcr13b
		dc.l	mlcr14,mlcr14b
		dc.l	mlcr15,mlcr15b
		dc.l	mlcr16,mlcr16b
		dc.l	mlcr17,mlcr17b
		dc.l	mlcr18,mlcr18b
		dc.l	mlcr19,mlcr19b
		dc.l	mlcr20,mlcr20b
		dc.l	mlcr21,mlcr21b
		dc.l	mlcr22,mlcr22b
		dc.l	mlcr23,mlcr23b
		dc.l	mlcr24,mlcr24b
		dc.l	mlcr25,mlcr25b
		dc.l	mlcr26,mlcr26b
		dc.l	mlcr27,mlcr27b
		dc.l	mlcr28,mlcr28b
		dc.l	mlcr29,mlcr29b
		dc.l	mlcr30,mlcr30b
		dc.l	mlcr31,mlcr31b
		dc.l	mlcr32,mlcr32b
		dc.l	mlcr33,mlcr33b
		dc.l	mlcr34,mlcr34b
		dc.l	mlcr35,mlcr35b
		dc.l	mlcr36,mlcr36b
		dc.l	mlcr37,mlcr37b
		dc.l	mlcr38,mlcr38b
		dc.l	mlcr39,mlcr39b
		dc.l	mlcr40,mlcr40b
		dc.l	mlcr41,mlcr41b
		dc.l	mlcr42,mlcr42b
		dc.l	mlcr43,mlcr43b
		dc.l	mlcr44,mlcr44b
		dc.l	mlcr45,mlcr45b
		dc.l	mlcr46,mlcr46b
		dc.l	mlcr47,mlcr47b
		dc.l	mlcr48,mlcr48b
		dc.l	mlcr49,mlcr49b
		dc.l	mlcr50,mlcr50b
		dc.l	mlcr51,mlcr51b
		dc.l	mlcr52,mlcr52b
		dc.l	-1



mlc0		dc.b	L,i,N,K,0
mlc1		dc.b	C,O,N,N,E,C,T,0
mlc2		dc.b	E,X,i,T,0
mlc3		dc.b	D,i,R,0
mlc4		dc.b	H,E,L,P,0
mlc5		dc.b	L,S,0
mlc6		dc.b	A,U,T,O,E,X,E,C,0
mlc7		dc.b	A,U,T,O,E,X,E,C,180-".",B,A,T,0
mlc8		dc.b	C,D,SPC,S,Y,S,T,E,M,0
mlc9		dc.b	V,E,R,S,i,O,N,0
mlc10		dc.b	W,H,O,SPC,180-"-",A,0

mlc12		dc.b	H,E,L,P,SPC,L,i,N,K,0
mlc13		dc.b	H,E,L,P,SPC,C,O,N,N,E,C,T,0
mlc15		dc.b	H,E,L,P,SPC,C,D,0
mlc16		dc.b	H,E,L,P,SPC,D,i,R,0
mlc17		dc.b	H,E,L,P,SPC,E,X,i,T,0
mlc18		dc.b	S,A,V,E,0
mlc19		dc.b	R,D,T,H,G,H,T,0
mlc20		dc.b	D,O,U,B,L,E,SPC,V,B,L,0
mlc21		dc.b	S,T,A,T,U,S,0
mlc22		dc.b	S,E,T,A,N1,0
mlc23		dc.b	S,E,T,A,N2,0

		ifeq cheattable
mlcr00		dc.b	R,F,C,R,E,D,K,E,Y,0
mlcr01		dc.b	R,F,C,G,R,N,K,E,Y,0
mlcr02		dc.b	R,F,C,B,L,U,K,E,Y,0	
mlcr03		dc.b	R,F,C,Y,L,W,K,E,Y,0
mlcr04		dc.b	R,F,C,U,T,R,S,C,N,0
mlcr05		dc.b	R,F,C,N,G,H,T,V,W,0
mlcr06		dc.b	R,F,C,E,N,E,R,G,Y,0
mlcr07		dc.b	R,F,C,S,H,i,E,L,D,0
mlcr08		dc.b	R,F,C,A,M,M,O,N1,0
mlcr09		dc.b	R,F,C,A,M,M,O,N2,0
mlcr10		dc.b	R,F,C,A,M,M,O,N3,0
mlcr11		dc.b	R,F,C,A,M,M,O,N4,0
mlcr12		dc.b	R,F,C,G,A,S,M,S,K,0
mlcr13		dc.b	R,F,C,i,N,V,U,L,N,0
mlcr14		dc.b	R,F,C,i,N,V,i,S,i,0
mlcr15		dc.b	R,F,C,W,E,A,P,N,N1,0
mlcr16		dc.b	R,F,C,W,E,A,P,N,N2,0
mlcr17		dc.b	R,F,C,W,E,A,P,N,N3,0
mlcr18		dc.b	R,F,C,W,E,A,P,N,N4,0
mlcr19		dc.b	R,F,C,R,D,S,U,i,T,0
mlcr20		dc.b	R,F,C,G,G,R,C,N,T,0
mlcr21		dc.b	R,F,C,B,K,P,A,C,K,0
mlcr22		dc.b	R,F,C,M,O,N,D,T,C,0
mlcr23		dc.b	R,F,C,F,L,P,L,A,N,0
mlcr24		dc.b	R,F,C,W,E,L,D,E,R,0
mlcr25		dc.b	R,F,C,G,i,F,T,0
mlcr26		dc.b	R,F,C,L,V,L,E,N,D,0
mlcr27		dc.b	R,F,C,S,M,P,L,A,N,0
mlcr28		dc.b	R,F,C,N,V,R,G,E,T,0
mlcr29		dc.b	R,F,C,P,R,M,i,V,U,0
mlcr30		dc.b	R,F,C,P,R,M,i,V,i,0
mlcr31		dc.b	R,F,C,S,E,T,C,L,N0,0
mlcr32		dc.b	R,F,C,S,E,T,C,L,N1,0
mlcr33		dc.b	R,F,C,S,E,T,C,L,N2,0
mlcr34		dc.b	R,F,C,S,E,T,C,L,N3,0
mlcr35		dc.b	R,F,C,S,E,T,C,L,N4,0
mlcr36		dc.b	R,F,C,S,E,T,C,L,N5,0
mlcr37		dc.b	R,F,C,S,E,T,C,L,N6,0
mlcr38		dc.b	R,F,C,S,E,T,C,L,N7,0
mlcr39		dc.b	R,F,C,P,R,M,M,S,N,0
mlcr40		dc.b	R,F,C,S,E,C,M,S,N,0
mlcr41		dc.b	R,F,C,B,E,E,R,M,G,0
mlcr42		dc.b	R,F,C,T,R,N,D,T,C,0
mlcr43		dc.b	R,F,C,D,E,L,C,L,N0,0
mlcr44		dc.b	R,F,C,D,E,L,C,L,N1,0
mlcr45		dc.b	R,F,C,D,E,L,C,L,N2,0
mlcr46		dc.b	R,F,C,D,E,L,C,L,N3,0
mlcr47		dc.b	R,F,C,D,E,L,C,L,N4,0
mlcr48		dc.b	R,F,C,D,E,L,C,L,N5,0
mlcr49		dc.b	R,F,C,D,E,L,C,L,N6,0
mlcr50		dc.b	R,F,C,D,E,L,C,L,N7,0
mlcr51		dc.b	R,F,C,C,O,N,D,O,M,0
mlcr52		dc.b	R,F,C,i,D,C,A,R,D,0
		endc
		ifeq cheattable-1
mlcr00		dc.b	R,T,R,O,T,0
mlcr01		dc.b	R,T,G,R,U,E,N,0
mlcr02		dc.b	R,T,B,L,A,U,0
mlcr03		dc.b	R,T,G,E,L,B,0
mlcr04		dc.b	R,T,S,C,A,N,N,E,R,0
mlcr05		dc.b	R,T,N,A,C,H,T,0
mlcr06		dc.b	R,T,E,N,E,R,G,i,E,0
mlcr07		dc.b	R,T,S,C,H,i,L,D,0
mlcr08		dc.b	R,T,M,U,N,N1,0
mlcr09		dc.b	R,T,M,U,N,N2,0
mlcr10		dc.b	R,T,M,U,N,N3,0
mlcr11		dc.b	R,T,M,U,N,N4,0
mlcr12		dc.b	R,T,G,A,S,M,A,S,K,E,0
mlcr13		dc.b	R,T,U,N,V,E,R,W,0
mlcr14		dc.b	R,T,U,N,S,i,C,H,T,0
mlcr15		dc.b	R,T,W,A,F,F,E,N1,0
mlcr16		dc.b	R,T,W,A,F,F,E,N2,0
mlcr17		dc.b	R,T,W,A,F,F,E,N3,0
mlcr18		dc.b	R,T,W,A,F,F,E,N4,0
mlcr19		dc.b	R,T,A,N,Z,U,G,0
mlcr20		dc.b	R,T,G,E,i,G,E,R,0
mlcr21		dc.b	R,T,R,U,C,K,S,A,C,K,0
mlcr22		dc.b	R,T,G,E,G,N,E,R,0
mlcr23		dc.b	R,T,G,E,S,A,M,T,E,K,A,R,T,E,0
mlcr24		dc.b	R,T,S,C,H,W,E,i,S,S,E,R,0
mlcr25		dc.b	R,T,G,i,F,T,0
mlcr26		dc.b	R,T,E,N,D,E,0
mlcr27		dc.b	R,T,K,A,R,T,E,0
mlcr28		dc.b	R,T,S,C,H,L,U,E,S,S,E,L,0
mlcr29		dc.b	R,T,P,R,M,U,N,V,E,R,W,0
mlcr30		dc.b	R,T,P,R,M,U,N,S,i,C,H,T,0
mlcr31		dc.b	R,T,F,A,R,B,E,N1,0
mlcr32		dc.b	R,T,F,A,R,B,E,N2,0
mlcr33		dc.b	R,T,F,A,R,B,E,N3,0
mlcr34		dc.b	R,T,F,A,R,B,E,N4,0
mlcr35		dc.b	R,T,F,A,R,B,E,N5,0
mlcr36		dc.b	R,T,F,A,R,B,E,N6,0
mlcr37		dc.b	R,T,F,A,R,B,E,N7,0
mlcr38		dc.b	R,T,F,A,R,B,E,N8,0
mlcr39		dc.b	R,T,E,R,S,T,E,S,M,Z,0
mlcr40		dc.b	R,T,Z,W,E,i,T,E,S,M,Z,0
mlcr41		dc.b	R,T,B,i,E,R,0
mlcr42		dc.b	R,T,Z,U,E,G,E,0
mlcr43		dc.b	R,T,L,F,A,R,B,E,N1,0
mlcr44		dc.b	R,T,L,F,A,R,B,E,N2,0
mlcr45		dc.b	R,T,L,F,A,R,B,E,N3,0
mlcr46		dc.b	R,T,L,F,A,R,B,E,N4,0
mlcr47		dc.b	R,T,L,F,A,R,B,E,N5,0
mlcr48		dc.b	R,T,L,F,A,R,B,E,N6,0
mlcr49		dc.b	R,T,L,F,A,R,B,E,N7,0
mlcr50		dc.b	R,T,L,F,A,R,B,E,N8,0
mlcr51		dc.b	R,T,C,O,N,D,O,M,0
mlcr52		dc.b	R,T,i,D,C,A,R,D,0
		endc

			;12345678901234567890123456789
mlc3_txt	dc.b	"D-WX-WX       0   SYSTEM",13
		dc.b	"-RWXR-X     407 AUTOEXEC.BAT",13
		dc.b	"-RW-R--    3049   CONFIG.SYS",13
		dc.b	"-RW-R--   94576  RUNNING.DAT",13
		dc.b	"          98032 BYTES USED",13
		dc.b	"        6712474 BYTES FREE",13,0

mlc4_txt	dc.b	"AVAILABLE COMMANDS:",13
		dc.b	"  LINK",13
		dc.b	"  CONNECT",13
		dc.b	"  VERSION",13
		dc.b	"  STATUS",13
		dc.b	"  EXIT",13
		dc.b	"  DIR",13
		dc.b	"  CD",13
		dc.b	"  SAVE (ONLY AT TERMINALS)",13
		dc.b	"TRY 'HELP <COMMAND>'",13,0

mlc6_txt	dc.b	"ECHO OFF",13
		dc.b	"MODE CON PAGE 31 PRESENT",13,13
		dc.b	"EGA.SYS NOT FOUND",13,13
		dc.b	"VESA BIOS INSTALLED",13
		dc.b	"ERROR: NO MOUSE PRESENT",13,0

mlc8_txt	dc.b	"OPERATION NOT PERMITTED",13,0

mlc9_txt	dc.b	"RUNNING                    ",13
		dc.b	"(W) 1994-1997              ",13
		dc.b	"RELEASE OKTOBER 1997       ",13,0

			;12345678901234567890123456789
mlc10_txt	dc.b	"  KX0029  ON SINCE 14:45 s0",13
		dc.b	"    ROOT  ON SINCE  2:23 s1",13,0

mlc12_txt	dc.b	"LINK <RETURN>: CONNECTS YOU TO "
		dc.b	"THE RUNNING HEADQUARTERS. THIS "
		dc.b	"WILL PRINT OUT YOUR MISSION.",13,0

mlc13_txt	dc.b	"CONNECT <RETURN>: CONNECTS YOU TO "
		dc.b	"THE TERMINAL IN FRONT OF YOU. "
		dc.b	"THE TERMINAL PRINTS OUT A MESSAGE.",13,0

mlc15_txt	dc.b	"CD 'DIRECTORY' <RETURN>: CHANGES "
		dc.b	"THE CURRENT DIRECTORY.",13,0

mlc16_txt	dc.b	"DIR <RETURN>: LISTS ALL FILES "
		dc.b	"IN THE CURRENT DIRECTORY.",13,0

mlc17_txt	dc.b	"EXIT <RETURN>: SHUTS DOWN THE "
		dc.b	"SYSTEM AND RETURNS TO THE GAME.",13,0

mlc18_txt	dc.b	"SAVE <RETURN>: SAVING A GAME IS ONLY POSSIBLE "
		dc.b	"WHILE STANDING AT A TERMINAL. "
		dc.b	"CHECK OUT FOR THE NEXT ONE ...",13,0

mlc20_txt1	dc.b	"DOUBLE VBL BUG SET ENABLED",13,0
mlc20_txt2	dc.b	"DOUBLE VBL BUG SET DISABLED",13,0

mlc21_txt	dc.b	"MISSION STATUS:",13,0
mlc21_txt_p0	dc.b	"PRIMARY MISSION NOT COMPLETED",13,0
mlc21_txt_p1	dc.b	"PRIMARY MISSION COMPLETED",13,0
mlc21_txt_s0	dc.b	"SECONDARY MISSION NOT COMPLETED",13,0
mlc21_txt_s1	dc.b	"SECONDARY MISSION COMPLETED",13,0

mlcr_txt	dc.b	"RUNNING CHEAT - WELL DONE",13,0

		even

;---------------

ml_screenfile	dc.b	"temp\picture.dat",0
		
		even
