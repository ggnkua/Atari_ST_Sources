
levelend_screen

	; --------------
	; flags loeschen

		clr.w	le_sam_to_play
		clr.w	le_load_next

	; --------------
	; soundsystem ausschalten

		jsr	init_sam_delete_all

	; --------------
	; files einladen

		ifeq mxalloc_flag
		lea	le_files(pc),a0
		jsr	load_file_list
		else
		move.l	#endsam_file,file_name_ptr
		move.l	samples,file_buf_ptr
		move.l	#mx_intsam_len,file_size
		jsr	load_file
		endc

		tst.w	mnu_no_run
		bne	le_sofort_out

		clr.w	mnu_run
		clr.w	mnu_load_run

	; --------------
	; logischen screen loeschen

		movea.l	screen_1,a0
		jsr	clear_black_240

	; --------------
	; richtige aufloesung setzen

		move.l	#640,true_offi
		clr.w	double_scan
		clr.w	cinemascope
		move.w	#1,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	le_no_vga
		move.l	#si_320x240vga,screen_init_rout_ptr
le_no_vga	jsr	vsync
		jsr	swap_me


		movea.l	screen_1,a0
		suba.w	#128,a0
		move.l	a0,file_buf_ptr
		move.l	#153728,file_size

		lea	init_file_modi,a0
		clr.l	(a0)
		clr.l	4(a0)
		clr.l	8(a0)
		clr.l	12(a0)

		movea.l	big_sector_ptr,a1
		movea.l	lev_infos(a1),a1
		lea	li_file(a1),a1
le_copyfile_lop	move.b	(a1)+,d0
		move.b	d0,(a0)+
		cmpi.b	#" ",d0
		beq.s	le_copyfile_out
		tst.b	d0
		bne.s	le_copyfile_lop
le_copyfile_out	clr.b	-(a0)
		
		move.l	#init_file,file_name_ptr
		jsr	load_file

	; --------------
	; level_name zeichnen

		movea.l	big_sector_ptr,a1
		movea.l	lev_infos(a1),a1
		move.l	li_name_ptr(a1),a0
		movea.l	screen_1,a6
		adda.l	#640*4+8*2,a6
		jsr	paint_text
		
	; --------------
	; 'press_space' zeichnen

		lea	le_space_txt,a0
		movea.l	screen_1,a6
		adda.l	#640*222+116*2,a6
		jsr	paint_text

	; --------------
	; und verzweigen ...

		movea.l	play_dat_ptr,a0
		tst.w	pd_killed_flag(a0)
		bne	le_killed
		tst.w	pd_timeout_flag(a0)
		bne	le_timeout
		tst.w	pd_quit_flag(a0)
		bne	le_quit

;---

	; level wurde einfach nur durch das
	; menue beendet

		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		movea.l	li_len_txt_ptr(a0),a0
		movea.l	screen_1,a6
		adda.l	(a0)+,a6
		move.w	#10,text_height
		jsr	paint_text

		move.w	#snd_adios,le_sam_to_play

		bra	le_out

;---

le_killed
		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		movea.l	li_lek_txt_ptr(a0),a0
		movea.l	screen_1,a6
		adda.l	(a0)+,a6
		move.w	#10,text_height
		jsr	paint_text

		move.w	#snd_adios,le_sam_to_play

		bra	le_out

;---

le_timeout
		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		movea.l	li_let_txt_ptr(a0),a0
		movea.l	screen_1,a6
		adda.l	(a0)+,a6
		move.w	#10,text_height
		jsr	paint_text

		move.w	#snd_adios,le_sam_to_play

		bra	le_out

;---

le_quit

	; level wurde durch th_levelend beendet

		movea.l	big_sector_ptr,a0
		movea.l	lev_infos(a0),a0
		movea.l	li_leq_txt_ptr(a0),a0
		movea.l	screen_1,a6
		adda.l	(a0)+,a6
		move.w	#10,text_height
		jsr	paint_text

		move.l	vbl_count,d0
		moveq	#snd_welldone,d1
		btst	#0,d0
		beq.s	leq_default
		moveq	#snd_yipi,d1
leq_default	move.w	d1,le_sam_to_play

		move.w	#1,le_load_next

		bra	le_out

		nop

;---

le_out		movea.l	play_dat_ptr,a0
		clr.w	pd_quit_flag(a0)
		clr.w	pd_killed_flag(a0)
		clr.w	pd_timeout_flag(a0)

	; --------------

		lea	level_files,a4
		lea	lf_episode_ptr(a4),a5
		move.l	episode,d0

		move.w	d0,d1
		swap	d0

		movea.l	(a5,d0.w*4),a6
		addq.w	#1,d1
		cmp.w	lf_nb_level(a6),d1
		beq.s	le_level_ok
		blt.s	le_level_ok

		tst.w	d0
		beq.s	le_out_now

le_level_ok

	; --------------

		moveq	#0,d0
		jsr	make_blenden

		move.w	le_sam_to_play,d0
		moveq	#0,d1
		jsr	init_sam

		lea	keytable+$39,a0
le_wait		tst.b	(a0)
		beq.s	le_wait
		clr.b	(a0)

le_sofort_out

		movea.l	screen_1,a0
		jsr	clear_black_240

		moveq	#0,d0
		jsr	make_blenden

		movea.l	screen_1,a0
		jsr	clear_black_240

		jsr	init_sam_delete_all

le_out_now
		rts

;---------------

load_next_level

		lea	level_files,a4
		lea	lf_episode_ptr(a4),a5
		move.l	episode,d0			; d0 (hi) = episode
							; d0 (lo) = level

		move.w	d0,d1
		swap	d0

	; zuerst versuchen, den level um eins zu erhoehen ...

		movea.l	(a5,d0.w*4),a6
		addq.w	#1,d1

		cmp.w	lf_nb_level(a6),d1
		beq.s	lnl_level_ok
		blt.s	lnl_level_ok

	; level ist nicht mehr moeglich, also keinen
	; neuen laden und einfach zurueckkehren

		bsr	episodeend_screen

		bra	lnl_out

lnl_level_ok
		swap	d0
		move.w	d1,d0
		move.l	d0,episode

		move.w	#1,mnu_run

		bra	running_start_new_level		
		

;**************************************
;* episodeend_screen
;**************************************

episodeend_screen

		movea.l	play_dat_ptr,a0
		tst.w	pd_which_end(a0)
		beq	es_out

	; --------------
	; filenamen erzeugen
	; und einladen

		movea.l	screen_1,a0
		suba.w	#128,a0
		move.l	a0,file_buf_ptr
		move.l	#153728,file_size
		move.l	#eend_file_1,d0
		movea.l	play_dat_ptr,a6
		move.w	pd_which_end(a6),d2
		cmpi.w	#1,d2
		beq.s	es_no_second
		move.l	#eend_file_2,d0
es_no_second	move.l	d0,file_name_ptr
		jsr	load_file

	; --------------
	; einblenden

		moveq	#0,d0
		jsr	make_blenden

	; --------------
	; 2 sek. warten

		moveq	#100,d0
es_w2_loop	move.w	d0,-(sp)
		jsr	vsync
		move.w	(sp)+,d0
		dbra	d0,es_w2_loop

	; --------------
	; sample abspielen

		movea.l	play_dat_ptr,a0
		move.w	pd_which_end(a0),d0
		addi.w	#snd_end1-1,d0
		moveq	#0,d1
		jsr	init_sam

	; --------------
	; 2 sek. warten

		moveq	#100,d0
es_w2_loop2	move.w	d0,-(sp)
		jsr	vsync
		move.w	(sp)+,d0
		dbra	d0,es_w2_loop2

	; --------------
	; space

		lea	keytable,a0
es_wait		tst.b	$39(a0)
		beq.s	es_wait

	; --------------
	; ausblenden

		movea.l	screen_1,a0
		jsr	clear_black_240

		moveq	#0,d0
		jsr	make_blenden

	; --------------

		lea	episodeend_text,a0
		movea.l	play_dat_ptr,a1
		move.w	pd_which_end(a1),d0
		movea.l	-4(a0,d0.w*4),a0
		movea.l	screen_1,a6
		move.w	#9,text_height
		jsr	paint_text

		moveq	#0,d0
		jsr	make_blenden

	; --------------
	; space

		lea	keytable,a0
es_wait_2	tst.b	$39(a0)
		beq.s	es_wait_2

	; --------------
	; ausblenden

		movea.l	screen_1,a0
		jsr	clear_black_240

		moveq	#0,d0
		jsr	make_blenden


es_out
		rts




;--------------------------------------

le_sam_to_play	dc.w	0
le_load_next	dc.w	0

le_space_txt	dc.b	"PRESS SPACE",0
		even


le_files
		dc.w	3-1
		dc.l	le_sam_file_1,12931,dith_data
		dc.l	le_sam_file_2,7316,dith_data+12931
		dc.l	le_sam_file_3,9798,dith_data+20247

le_sam_file_1	dc.b	"data\samples\adios.sam",0
le_sam_file_2	dc.b	"data\samples\welldone.sam",0
le_sam_file_3	dc.b	"data\samples\yipi.sam",0

		even




