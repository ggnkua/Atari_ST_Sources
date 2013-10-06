
mnustart_init_routs

		dc.l	mns_main_init
		dc.l	mns_new_init

	; dc.l	pointer_txt			 4 bytes
	; dc.l	screen_offset (nur y-richtung)	 4 bytes
	; dc.w	nb_of_entries			 2 bytes
	; dc.w	screen_offset (nur x-richtung)	 2 bytes
	; dc.l	pointer_routes			 4 bytes
	;					-------- 
	;					16 bytes


mnustart_info
		dc.l	mns_main_txt,640*65
		dc.w	2,100*2
		dc.l	mns_main_routs

		dc.l	mns_new_txt,640*65
er_modify_2	dc.w	2,80*2
		dc.l	mns_new_routs

;---

mns_main_routs	dc.l	mns_newgame
;		dc.l	mns_loadgame
		dc.l	mns_quit

mns_new_routs	dc.l	mns_episode0
		dc.l	mns_episode1
		dc.l	mns_episode2
		dc.l	mns_episode3
		dc.l	mns_episode4
		dc.l	mns_episode5
		dc.l	mns_episode6
		dc.l	mns_episode7
		dc.l	mns_back
		
mns_main_txt	dc.b	"NEW GAME",13
;		dc.b	"LOAD GAME",13
		dc.b	"QUIT"
		dc.b	0
		even

mns_new_txt	
		dc.b	"OUTLYING DISTRICT",13
		dc.b	"BACK TO MAIN"
		dc.b	0

		ds.b	256

		even

;---

mns_main_init	clr.w	mnu_run
		clr.w	mnu_load_run
		rts

mns_new_init	rts

;---

mns_newgame	clr.w	menue_pos_y
		move.w	#1,menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mns_loadgame	move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		jsr	menue_load
		rts

mns_quit	move.w	#1,quit_flag
		clr.w	menue_flag
		move.w	#snd_menue_deact,d0
		moveq	#0,d1
		bsr	init_sam
		rts

;---

mns_episode0	clr.l	d0
		bra	mns_episode
mns_episode1	move.l	#$00010000,d0
		bra	mns_episode
mns_episode2	move.l	#$00020000,d0
		bra	mns_episode
mns_episode3	move.l	#$00030000,d0
		bra	mns_episode
mns_episode4	move.l	#$00040000,d0
		bra	mns_episode
mns_episode5	move.l	#$00050000,d0
		bra	mns_episode
mns_episode6	move.l	#$00060000,d0
		bra	mns_episode
mns_episode7	move.l	#$00070000,d0

mns_episode
		move.l	d0,-(sp)
	; sound
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
	; startmenue
		moveq	#1,d1
		tst.w	mnu_start_flag
		bne	mnse_dlg_out
	; dialogfeld laden
		move.l	#pistol_data,file_buf_ptr
		move.l	#startdlg_file,file_name_ptr
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
mnse_loop1	move.w	#159,d1
mnse_loop2	move.w	(a0)+,(a1)+
		dbra	d1,mnse_loop2
		lea	320(a1),a1
		dbra	d0,mnse_loop1
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
mnse_wait	tst.b	$2c(a0)
		bne.s	mnse_dlg_out
		tst.b	$1c(a0)
		bne.s	mnse_dlg_out
		tst.b	$15(a0)
		bne.s	mnse_dlg_out
		tst.b	$31(a0)
		beq.s	mnse_wait
		moveq	#0,d1
mnse_dlg_out	move.l	(sp)+,d0
		move.w	#2,clear_it_flag
		movem.l	d0-d1,-(sp)
	; screen kopieren
		movea.l	screen_1,a0
		movea.l	screen_2,a1
		jsr	copy_240

		movem.l	(sp)+,d0-d1
		tst.w	d1
		bne.s	mnse_new

		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d0
		jsr	load_pistol_data
		jsr	calc_paint_pistol_immediate
		bra.s	mnse_out
mnse_new
		move.l	d0,episode
		moveq	#1,d0
		move.w	d0,quit_flag
		move.w	d0,mnu_run
		clr.w	menue_pos_y
		clr.w	menue_number
mnse_out	move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts

mns_back	clr.w	menue_pos_y
		clr.w	menue_number
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		rts





