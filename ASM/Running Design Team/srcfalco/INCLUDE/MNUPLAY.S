
mnuplay_init_routs

		dc.l	mn_main_init
		dc.l	mn_opt_init
		dc.l	mn_sndopt_init
		dc.l	mns_new_init

	; dc.l	pointer_txt			 4 bytes
	; dc.l	screen_offset (nur y-richtung)	 4 bytes
	; dc.w	nb_of_entries			 2 bytes
	; dc.w	screen_offset (nur x-richtung)	 2 bytes
	; dc.l	pointer_routes			 4 bytes
	;					-------- 
	;					16 bytes

mnuplay_info
		ifeq	save_in_menue
		dc.l	mn_main_txt,640*25
		dc.w	6,90*2
		dc.l	mn_main_routs
		else
		dc.l	mn_main_txt,640*20
		dc.w	7,90*2
		dc.l	mn_main_routs
		endc

		dc.l	mn_opt_txt,640*40
		dc.w	5,80*2
		dc.l	mn_opt_routs

		dc.l	mn_sndopt_txt,640*30
		dc.w	6,80*2
		dc.l	mn_sndopt_routs

		dc.l	mns_new_txt,640*65		; daten in mnustart.s
er_modify_1	dc.w	2,80*2
		dc.l	mns_new_routs

;---

mn_main_routs	
		ifeq	save_in_menue
		dc.l	mn_newgame
		dc.l	mn_loadgame
		dc.l	mn_options
		dc.l	mn_sndoptions
		dc.l	mn_backtogame
		dc.l	mn_quit
		else
		dc.l	mn_newgame
		dc.l	mn_loadgame
		dc.l	mn_savegame
		dc.l	mn_options
		dc.l	mn_sndoptions
		dc.l	mn_backtogame
		dc.l	mn_quit
		endc
		
mn_opt_routs	dc.l	mn_screensize
		dc.l	mn_detail
		dc.l	mn_vsync
		dc.l	mn_pistol
		dc.l	mn_optreturn

mn_sndopt_routs	dc.l	mn_volume
		dc.l	mn_speaker
		dc.l	mn_sndstereo
		dc.l	mn_sndsurround
		dc.l	mn_sndsystem
		dc.l	mn_sndoptreturn

mn_main_txt	
		ifeq	save_in_menue
		dc.b	"NEW GAME",13
		dc.b	"LOAD GAME",13
		dc.b	"OPTIONS",13
		dc.b	"SOUND OPTIONS",13
		dc.b	"BACK TO GAME",13
		dc.b	"QUIT"
		else
		dc.b	"NEW GAME",13
		dc.b	"LOAD GAME",13
		dc.b	"SAVE GAME",13
		dc.b	"OPTIONS",13
		dc.b	"SOUND OPTIONS",13
		dc.b	"BACK TO GAME",13
		dc.b	"QUIT"
		endc
		dc.b	0
		even

mn_opt_txt	dc.b	"SCREEN SIZE",13
		dc.b	"DETAIL "
mno_det_txt	dc.b	"MIDDLE",13
		dc.b	"VSYNC "
mno_vsync_txt	dc.b	"YES",13
		dc.b	"PAINT PISTOL "
mno_pis_txt	dc.b	"YES",13
		dc.b	"BACK TO MAIN"
		dc.b	0
		even

mn_sndopt_txt
		dc.b	"VOLUME "
mnso_vol_txt	dc.b	" 0",13
		dc.b	"SPEAKER "
mnso_speak_txt	dc.b	"OFF",13
		dc.b	"SOUND "
mnso_sys_txt	dc.b	"MONO  ",13
		dc.b	"SURROUND "
mnso_sur_txt	dc.b	"OFF",13
		dc.b	"FREQUENCY "
mnso_snd_txt	dc.b	"25 KHZ",13
		dc.b	"BACK TO MAIN"
		dc.b	0
		even

;--------------------------------------

mn_main_init	clr.w	mnu_run
		rts

mn_opt_init	clr.b	keytable+$3c
		clr.b	keytable+$3d
		clr.b	keytable+$3e
		clr.b	keytable+$3f

		lea	mno_vsync_txt(pc),a1
		btst	#0,vsync_flag+1
		beq.s	mnoi_vsyes
		move.b	#"N",(a1)+
		move.b	#"O",(a1)+
		move.b	#" ",(a1)
		bra.s	mnoi_vsync_ok
mnoi_vsyes	move.b	#"Y",(a1)+
		move.b	#"E",(a1)+
		move.b	#"S",(a1)
mnoi_vsync_ok

		lea	mno_pis_txt(pc),a1
		btst	#0,pp_flag+1
		beq.s	mnoi_pyes
		move.b	#"N",(a1)+
		move.b	#"O",(a1)+
		move.b	#" ",(a1)
		bra.s	mnoi_p_ok
mnoi_pyes	move.b	#"Y",(a1)+
		move.b	#"E",(a1)+
		move.b	#"S",(a1)
mnoi_p_ok

		lea	mno_det_txt(pc),a1
		movea.l	play_dat_ptr,a0
		tst.w	pd_x_flag_last(a0)
		beq.s	mnoi_its_high
		tst.w	double_scan
		beq.s	mnoi_its_mid
		bra.s	mnoi_its_low	
mnoi_its_high	move.b	#"H",(a1)+
		move.b	#"I",(a1)+
		move.b	#"G",(a1)+
		move.b	#"H",(a1)+
		move.b	#" ",(a1)+
		move.b	#" ",(a1)
		rts
mnoi_its_mid	move.b	#"M",(a1)+
		move.b	#"I",(a1)+
		move.b	#"D",(a1)+
		move.b	#"D",(a1)+
		move.b	#"L",(a1)+
		move.b	#"E",(a1)
		rts
mnoi_its_low	move.b	#"L",(a1)+
		move.b	#"O",(a1)+
		move.b	#"W",(a1)+
		move.b	#" ",(a1)+
		move.b	#" ",(a1)+
		move.b	#" ",(a1)
		rts

mn_sndopt_init	
		move.w	$ffff893a.w,d1
		andi.w	#$00f0,d1
		ext.l	d1
		lsr.l	#4,d1
		moveq	#16,d0
		sub.w	d1,d0
		divu	#10,d0
		addi.w	#"0",d0
		move.b	d0,mnso_vol_txt
		swap	d0
		addi.w	#"0",d0
		move.b	d0,mnso_vol_txt+1

		lea	mnso_speak_txt,a0
                move.b  #14,$FFFF8800.w
                move.b  $FFFF8800.w,D0
		btst	#6,d0
		beq.s	mnso_spe_on
		move.b	#"O",(a0)+
		move.b	#"F",(a0)+
		move.b	#"F",(a0)
		bra.s	mnso_speak_ok
mnso_spe_on	move.b	#"O",(a0)+
		move.b	#"N",(a0)+
		move.b	#" ",(a0)+
mnso_speak_ok

		lea	mnso_snd_txt,a0
		btst	#0,spl_system+1
		bne.s	mnso_ss1
		move.b	#"2",(a0)+
		move.b	#"5",(a0)
		bra.s	mnso_snd_ok
mnso_ss1	move.b	#"1",(a0)+
		move.b	#"2",(a0)
mnso_snd_ok

		lea	mnso_sur_txt,a0
		btst	#2,spl_system+1
		bne.s	mnso_sur
		move.b	#"O",(a0)+
		move.b	#"F",(a0)+
		move.b	#"F",(a0)
		bra.s	mnso_sur_ok
mnso_sur	move.b	#"O",(a0)+
		move.b	#"N",(a0)+
		move.b	#" ",(a0)
mnso_sur_ok

		lea	mnso_sys_txt,a0
		btst	#1,spl_system+1
		bne.s	mnso_sys1
		move.b	#"M",(a0)+
		move.b	#"O",(a0)+
		move.b	#"N",(a0)+
		move.b	#"O",(a0)+
		move.b	#" ",(a0)+
		move.b	#" ",(a0)
		bra.s	mnso_sys_ok
mnso_sys1	move.b	#"S",(a0)+
		move.b	#"T",(a0)+
		move.b	#"E",(a0)+
		move.b	#"R",(a0)+
		move.b	#"E",(a0)+
		move.b	#"O",(a0)
mnso_sys_ok
		rts

;--------------------------------------

mn_newgame	clr.w	menue_pos_y
		move.w	#3,menue_number
		moveq	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_loadgame	move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		jsr	menue_load
		rts

mn_savegame	move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		jsr	menue_save
		rts

mn_options	clr.w	menue_pos_y
		move.w	#1,menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_backtogame	move.b	#1,keytable+$01
		rts

mn_quit		
	; dialogfeld laden
		move.l	#pistol_data,file_buf_ptr
		move.l	#quitdlg_file,file_name_ptr
		move.l	#35328,file_size
		jsr	load_file
	; screen kopieren
		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240
	; screen abdunkeln
		movea.l	screen_1,a0
		jsr	screen_abdunkeln
	; dialogfeld in screen kopieren
		lea	pistol_data+128,a0
		movea.l	screen_1,a1
		adda.l	#640*60+80*2,a1
		moveq	#109,d0
mnsq_loop1	move.w	#159,d1
mnsq_loop2	move.w	(a0)+,(a1)+
		dbra	d1,mnsq_loop2
		lea	320(a1),a1
		dbra	d0,mnsq_loop1
	; screen anzeigen
		clr.w	dont_change_scr
		jsr	swap_me
	; alle tasten loeschen
		lea	keytable,a0
		clr.b	$2c(a0)		; Y
		clr.b	$15(a0)		; Z
		clr.b	$1c(a0)		; RET
		clr.b	$31(a0)		; N
	; auf tastendruck warten
		moveq	#1,d1
mnsq_wait	tst.b	$2c(a0)
		bne.s	mnsq_dlg_out
		tst.b	$1c(a0)
		bne.s	mnsq_dlg_out
		tst.b	$15(a0)
		bne.s	mnsq_dlg_out
		tst.b	$31(a0)
		beq.s	mnsq_wait
		moveq	#0,d1
mnsq_dlg_out	
		move.w	#2,clear_it_flag
		move.w	d1,-(sp)
	; screen kopieren
		movea.l	screen_1,a0
		movea.l	screen_2,a1
		jsr	copy_240

		move.w	(sp)+,d1
		tst.w	d1
		bne.s	mnsq_quit

		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d0
		jsr	load_pistol_data
		jsr	calc_paint_pistol_immediate
		bra.s	mnsq_skip
mnsq_quit

		move.w	#1,quit_flag
mnsq_skip
		bclr	#0,menue_flag
		move.w	#snd_menue_deact,d0
		moveq	#0,d1
		bsr	init_sam
		rts

;---------------

mn_sndoptions	clr.w	menue_pos_y
		move.w	#2,menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_screensize	tst.w	menue_pos_x
		beq.s	mn_ss_out
		bmi.s	mn_ss_smaller
		move.b	#1,keytable+$3f
		move.w	#snd_menue_left,d0
		moveq	#0,d1
		bsr	init_sam
		rts
mn_ss_smaller	move.b	#1,keytable+$3e
		move.w	#snd_menue_right,d0
		moveq	#0,d1
		bsr	init_sam
mn_ss_out	rts

mn_detail	move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
;		tst.w	vga_monitor
;		beq.s	mn_detail_rgb
		movea.l	play_dat_ptr,a0
		tst.w	pd_x_flag_last(a0)
		beq.s	mnd_set_mid
		bra.s	mnd_set_high
mn_detail_rgb	tst.w	double_scan
		bne.s	mnd_set_high
		movea.l	play_dat_ptr,a0
		tst.w	pd_x_flag_last(a0)
		beq.s	mnd_set_mid
		bra.s	mnd_set_low
mnd_set_high	tst.w	double_scan
		beq.s	mnsh_only_f3
		move.b	#1,keytable+$21
mnsh_only_f3	move.b	#1,keytable+$3c
		rts
mnd_set_mid	tst.w	double_scan
		beq.s	mnsm_only_f3
		move.b	#1,keytable+$21
mnsm_only_f3	move.b	#1,keytable+$3d
		rts
mnd_set_low	tst.w	double_scan
		bne.s	mnsl_still_sc
		move.b	#1,keytable+$21
mnsl_still_sc	move.b	#1,keytable+$3d
		rts

mn_vsync	bchg	#0,vsync_flag+1
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_pistol	bchg	#0,pp_flag+1
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_optreturn	move.w	#3,menue_pos_y
		clr.w	menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

;---------------

mn_volume	tst.w	menue_pos_x
		bmi.s	mn_vol_down
		move.w	#snd_menue_left,d0
		moveq	#0,d1
		bsr	init_sam
		move.b	#1,keytable+$4a
		rts
mn_vol_down	move.w	#snd_menue_right,d0
		moveq	#0,d1
		bsr	init_sam
		move.b	#1,keytable+$4e
mn_vd_out	rts

mn_speaker	move.b	#1,keytable+$72
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mn_sndstereo	
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		bchg	#1,spl_system+1
		bsr	init_sound_system
		rts

mn_sndsurround
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		bchg	#2,spl_system+1
		bsr	init_sound_system
		rts

mn_sndsystem	
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		bchg	#0,spl_system+1
		bsr	init_sound_system
		rts

mn_sndoptreturn	move.w	#4,menue_pos_y
		clr.w	menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

