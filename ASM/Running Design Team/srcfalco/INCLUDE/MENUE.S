

; der speicherbereich truecolor_tab hat folgende struktur

; 0000000: zwischenspeicher screen (153600 bytes)
; 0153600: hintergrundbild loadsave (153768 bytes)
; 0307368: hintergrundbild level (160x120 pixel) (38400 bytes)
; 0345768: animation arrow

mnulf_temp	equ	0
mnulf_loadsave	equ	153600
mnulf_pic	equ	307368
mnulf_arrow	equ	345768

mnua_offi	equ	640*53+182*2
mnua_anz	equ	32
mnua_each_vbl	equ	1

mnusmp_offi	equ	640*44+13*2
mnutext_offi	equ	640*63+227*2

;---------------

; struktur runsavex.dat

rsx_kennung	equ	0
rsx_beschreib	equ	4
rsx_episode	equ	24
rsx_preview	equ	28
rsx_variables	equ	38428




;**************************************
;* menue
;**************************************

menue
		bsr	menue_keys

		tst.w	menue_flag
		beq	menue_out

		tst.w	menue_back_pic
		beq.s	mnu_back_kachel

	; es soll ein hintergrundbild gezeichnet werden

		movea.l	#dith_data+128,a0
		movea.l	screen_1,a1
		bsr	copy_240
		bra.s	mnu_back_ok

mnu_back_kachel
		move.w	#1,clear_it_flag

mnu_back_ok

		; animation des cursors ...

		bsr	mn_anim_cursor

		; die initialisierungsroutine des
		; aktuellen menues ausfuehren ...

		movea.l	mn_init_routs(pc),a0
		move.w	menue_number(pc),d0
		movea.l	0(a0,d0.w*4),a0
		jsr	(a0)

		; anzahl bytes berechnen, die pro
		; schriftzeile addiert werden

		move.l	#mnu_yoffset*640,d0
		tst.w	double_scan
		beq.s	menue_no_double
		move.l	#(mnu_yoffset/2)*640,d0
menue_no_double	move.l	d0,menue_yoffset

		; menue zeichnen

		move.w	menue_number(pc),d0
		lsl.w	#4,d0
		movea.l	mn_info(pc),a1
		movea.l	0(a1,d0.w),a0		; pointer txt

                movea.l screen_1,a6
		move.l	4(a1,d0.w),d1		; y-offset
		move.w	#mnu_yoffset,d2
		tst.w	double_scan
		beq.s	menue_no_dbl2
		lsr.l	#1,d1
		lsr.w	#1,d2
menue_no_dbl2	move.w	d2,text_height
		adda.l	d1,a6
		adda.w	10(a1,d0.w),a6
		
                move.l	a6,-(sp)
		bsr	paint_menutext
		move.l	(sp)+,a6

		suba.w	#24*2,a6
		move.w	menue_pos_y(pc),d0
		mulu	menue_yoffset+2(pc),d0
		adda.l	d0,a6
		lea	menue_crs_ascii(pc),a0
		bsr	paint_menutext

		; jetzt testen, ob ein eintrag aktiviert
		; wurde, d.h. ob space, enter, etc. gedrueckt wurde

		tst.w	menue_pos_activ
		beq.s	menue_not_activ

		move.w	menue_number(pc),d0
		lsl.w	#4,d0
		movea.l	mn_info(pc),a1
		movea.l	12(a1,d0.w),a0		; pointer routines
		move.w	menue_pos_y(pc),d0
		move.l	0(a0,d0.w*4),d0
		beq.s	menue_not_activ
		movea.l	d0,a0
		jsr	(a0)
		
menue_not_activ		

menue_out
		rts

;---------------

mn_anim_cursor
		move.w	menue_crs_time(pc),d0
		sub.w	vbl_time,d0
		bpl.s	menue_anim_ok
		addq.w	#1,menue_crs_pos
		andi.w	#$f,menue_crs_pos
		moveq	#3,d0
menue_anim_ok	move.w	d0,menue_crs_time
		move.w	menue_crs_pos(pc),d0
		addi.w	#"A"+36,d0
		move.b	d0,menue_crs_ascii

		rts

;---------------

menue_keys
		tst.w	menue_no_escape
		bne	mk_no_esc

		tst.w	karte_flag
		bne	mk_no_esc

		tst.b	keytable+$1
		beq	mk_no_esc
		clr.b	keytable+$1
		jsr	init_sam_delete_all
		move.w	#snd_menue_act,d0
		bchg	#0,menue_flag+1
		beq.s	mk_its_act
		move.w	#snd_menue_deact,d0
mk_its_act	moveq	#0,d1
		bsr	init_sam


		tst.w	menue_flag
		bne.s	mk_act

		tst.w	ds_vor_karte
		beq.s	mk_deact_ok2
		move.w	#2,dont_change_scr
		move.b	#2,keytable+$21
mk_deact_ok2
		tst.w	cine_vor_karte
		beq.s	mk_deact_ok
		move.w	#2,dont_change_scr
		move.b	#2,keytable+$2e
mk_deact_ok	bra.s	mk_no_esc

mk_act		
		lea	keytable,a0
		moveq	#31,d0
mk_loop		clr.l	(a0)+
		dbra	d0,mk_loop

		move.w	cinemascope,cine_vor_karte
		move.w	double_scan,ds_vor_karte
		tst.w	cinemascope
		beq.s	mk_act_ok
		move.w	#2,dont_change_scr
		move.b	#2,keytable+$2e
mk_act_ok
		tst.w	double_scan
		beq.s	mk_no_esc
		move.w	#2,dont_change_scr
		move.b	#2,keytable+$21

mk_no_esc

		ifeq	final
		tst.b	keytable+$10
		beq.s	mk_no_q
		clr.b	keytable+$10
		move.w	#1,quit_flag
		move.w	#snd_menue_item,d0
		moveq	#0,d1
		bsr	init_sam
mk_no_q		
		endc

		; wenn jetzt das menue nicht aktiv ist,
		; dann raus ...

		clr.w	menue_pos_activ
		tst.w	menue_flag
		beq	mk_out

		lea	jagpad_routs+4,a2
		jsr	(a2)
		move.l	d0,d7

		tst.b	keytable+$48		; crsr up
		beq.s	mk_no_up
		clr.b	keytable+$48
		move.w	menue_pos_y(pc),d0
		subq.w	#1,d0
		bpl.s	mk_up_ok
		movea.l	mn_info(pc),a0
		move.w	menue_number(pc),d1
		lsl.w	#4,d1
		move.w	8(a0,d1.w),d0
		subq.w	#1,d0
mk_up_ok	move.w	d0,menue_pos_y
		move.w	#snd_menue_up,d0
		moveq	#0,d1
		bsr	init_sam
mk_no_up

		tst.b	keytable+$50		; crsr down
		beq.s	mk_no_down
		clr.b	keytable+$50
		move.w	menue_pos_y(pc),d0
		addq.w	#1,d0
		movea.l	mn_info(pc),a0
		move.w	menue_number(pc),d1
		lsl.w	#4,d1
		cmp.w	8(a0,d1.w),d0
		blt.s	mk_down_ok
		moveq	#0,d0
mk_down_ok	move.w	d0,menue_pos_y
		move.w	#snd_menue_down,d0
		moveq	#0,d1
		bsr	init_sam
mk_no_down
		
		tst.b	keytable+$39
		beq	mk_no_space
		clr.b	keytable+$39
		clr.w	menue_pos_x
		move.w	#1,menue_pos_activ
mk_no_space

		tst.b	keytable+$4b
		beq	mk_no_left
		clr.b	keytable+$4b
		move.w	#-1,menue_pos_x
		move.w	#1,menue_pos_activ
mk_no_left

		tst.b	keytable+$4d
		beq	mk_no_right
		clr.b	keytable+$4d
		move.w	#1,menue_pos_x
		move.w	#1,menue_pos_activ
mk_no_right

		tst.b	keytable+$1c
		beq	mk_no_enter
		clr.b	keytable+$1c
		clr.w	menue_pos_x
		move.w	#1,menue_pos_activ
mk_no_enter



mk_out
		rts

;---------------

quit_flag		dc.w	0
menue_flag		dc.w	0	; flag, ob menue aktiv ist oder nicht
menue_no_escape		dc.w	0	; flag, ob escape erlaubt oder nicht
menue_back_pic		dc.w	0	; flag, ob hintergrundbild oder kachel


menue_crs_ascii	dc.b	"A"+26,0
menue_crs_pos	dc.w	0
menue_crs_time	dc.w	0

menue_yoffset	dc.l	0

menue_number	dc.w	0
menue_pos_x	dc.w	0
menue_pos_y	dc.w	0
menue_pos_activ	dc.w	0

mn_init_routs	dc.l	0	; pointer auf menue_init_routs
mn_info		dc.l	0	; pointer auf menue_info


		include	"include\mnuplay.s"
		include	"include\mnustart.s"


;**************************************
;* menue_start
;**************************************

; diese menue wird bei start von running angezeigt

menue_start

	; pointer fuer startmenue erstellen

		move.l	#mnustart_init_routs,mn_init_routs
		move.l	#mnustart_info,mn_info
		
		clr.w	menue_number
		clr.w	menue_pos_x
		clr.w	menue_pos_y
		clr.w	menue_pos_activ
		clr.w	mnu_run
		clr.w	mnu_load_run
		moveq	#1,d0
		move.w	d0,menue_flag
		move.w	d0,menue_no_escape
		move.w	d0,menue_back_pic
		move.w	d0,mnu_start_flag

	ifeq menueflag
		lea	dith_data+128,a0
		jsr	clear_black_240
	else
		movea.l	screen_1,a0
		lea	dith_data+128,a1
		jsr	copy_240
	endc

mns_loop
		jsr	menue

;		jsr	frames_per_second

		jsr	jagpad_simul
		jsr	find_vbl_time
		jsr	vsync
		jsr	swap_me
		
		jsr	clear_if_nessec

		tst.w	quit_flag
		beq.s	mns_loop

	; pointer fuer gamemenue erstellen

		move.l	#mnuplay_init_routs,mn_init_routs
		move.l	#mnuplay_info,mn_info

		clr.w	menue_flag
		clr.w	menue_no_escape
		clr.w	menue_back_pic
		clr.w	quit_flag
		clr.w	menue_number
		clr.w	menue_pos_x
		clr.w	menue_pos_y
		clr.w	menue_pos_activ
		clr.w	mnu_start_flag

		rts

;--- 

mnu_start_flag	dc.w	0	; flag, ob startmenue aktiv oder nicht
mnu_run		dc.w	0	; flag, ob new_game oder nicht
mnu_load_run	dc.w	0	; flag, ob load_game oder nicht
mnu_no_run	dc.w	0

;**************************************
;* menue_load
;**************************************

; benutzt wird der speicherplatz der farbtabelle 

menue_load

		clr.b	keytable+$01
		clr.w	mnul_upd_flag

	; aktuellen screen zwischenspeichern

		movea.l	screen_2,a0
		lea	truecolor_tab,a1
		bsr	copy_240

	; richtige aufloesung setzen ...

		move.w	double_scan,-(sp)
		move.w	cinemascope,-(sp)
		move.l	true_offi,-(sp)

		move.l	#640,true_offi
                move.w  #2,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	mnul_no_vga
		move.l	#si_320x240vga,screen_init_rout_ptr
mnul_no_vga

	; grafiken laden 

		bsr	mnu_load_files		

	; screen aufbauen

		jsr	vsync
		jsr	swap_me
		jsr	vsync
		jsr	swap_me

		bsr	mnul_make_screen

mnul_main
		jsr	jagpad_simul
		bsr	mnu_arrow
		bsr	mnu_keys
		bsr	mnul_update

		jsr	vsync
		jsr	swap_me

		tst.w	mnua_y_activ
		bne.s	mnul_deloop

		tst.w	mnua_escape
		beq.s	mnul_main

mnul_deloop

		clr.w	mnua_escape

	; screen wiederherstellen

		move.l	(sp)+,true_offi
		move.w	(sp)+,cinemascope
		move.w	(sp)+,double_scan
		bsr	install_si_routine
		move.w	#2,dont_change_scr
		move.w  #1,clear_it_flag

		lea	truecolor_tab,a0
		movea.l	screen_1,a1
		bsr	copy_240

		jsr	vsync
		jsr	swap_me
		jsr	vsync
		jsr	swap_me

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		bsr	copy_240

	; und jetzt feststellen ob ein level geladen
	; werden soll oder nicht

		lea	mnua_y_activ(pc),a0
		tst.w	(a0)
		beq	mnul_no_load
		clr.w	(a0)

	; einige variablen sichern

;		movea.l	play_dat_ptr,a0
;		move.l	pd_last_strafe(a0),-(sp)
;		move.l	pd_last_step(a0),-(sp)
;		move.l	pd_last_alpha(a0),-(sp)
;		move.w	pd_width(a0),-(sp)
;		move.w	pd_heigth(a0),-(sp)
;		move.w	pd_x_flag(a0),-(sp)
;		move.w	pd_width_last(a0),-(sp)
;		move.w	pd_heigth_last(a0),-(sp)
;		move.w	pd_x_flag_last(a0),-(sp)


	; spielstand laden

		move.w	mnua_y(pc),d0
		lea	loadsave_files(pc),a0
		movea.l	(a0,d0.w*4),a0
		lea	truecolor_tab,a6
		moveq	#0,d5			; alles laden
		jsr	load_game

	; einige variablen zuruecksetzen

;		movea.l	play_dat_ptr,a0
;		move.w	(sp)+,pd_x_flag_last(a0)
;		move.w	(sp)+,pd_heigth_last(a0)
;		move.w	(sp)+,pd_width_last(a0)
;		move.w	(sp)+,pd_x_flag(a0)
;		move.w	(sp)+,pd_heigth(a0)
;		move.w	(sp)+,pd_width(a0)
;		move.l	(sp)+,pd_last_alpha(a0)
;		move.l	(sp)+,pd_last_step(a0)
;		move.l	(sp)+,pd_last_strafe(a0)

	; spielstand gueltig ?

		tst.w	sg_error_flag
		bne	menue_load

		tst.w	mnu_start_flag
		beq.s	mnul_no_flag

		move.w	#1,mnu_load_run
		move.w	#1,quit_flag

mnul_no_flag

	; und level installieren - aber nicht, wenn
	; gerade das startmenue aktiv ist, dann
	; ist naemlich der dsp nicht aktiv

		tst.w	mnu_start_flag
		bne.s	mnul_no_load
		jsr	install_game

                move.w  #96,xwindow_min
                move.w  #320,xwindow_max
                move.w  #60,ywindow_min
                move.w  #200,ywindow_max

mnul_no_load

	; farbtabelle laden - aber nicht, wenn 
	; gerade das startmenue aktiv ist, dann
	; gibt es naemlich noch keine farbtabelle

		tst.w	mnu_start_flag
		bne.s	mnul_no_coltab
		move.w	#1,sc_load_flag

mnul_no_coltab

		clr.b	keytable+$01

		rts


;---------------

mnul_update

	; muss das vorschaubild neu gezeichnet werden ?

		tst.w	mnul_upd_flag
		bne	mnul_no_preview

		move.w	#1,mnul_upd_flag

	; das gespeicherte game bis zum vorschaubild laden

		move.w	mnua_y(pc),d0
		lea	loadsave_files(pc),a0
		movea.l	(a0,d0.w*4),a0
		lea	truecolor_tab,a6
		adda.l	#524288-rsx_variables,a6
		moveq	#2,d5
		jsr	load_game

		tst.w	sg_error_flag
		beq.s	mnulu_no_error

	; fehler, game konnte nicht geladen werden

		movea.l	screen_1,a5
		movea.l	screen_2,a6
		adda.l	#mnusmp_offi,a5
		adda.l	#mnusmp_offi,a6
		move.w	#119,d0
mnule_l1	move.w	#159,d1
mnule_l2	clr.w	(a5)+
		clr.w	(a6)+
		dbra	d1,mnule_l2
		lea	320(a5),a5
		lea	320(a6),a6
		dbra	d0,mnule_l1


		bra	mnul_no_preview

mnulu_no_error

	; vorschaubild in beide screens zeichnen
		
		lea	truecolor_tab,a4
		adda.l	#524288-rsx_variables+rsx_preview,a4
		movea.l	screen_1,a5
		movea.l	screen_2,a6
		adda.l	#mnusmp_offi,a5
		adda.l	#mnusmp_offi,a6
		move.w	#119,d0
mnulu_l1	move.w	#159,d1
mnulu_l2	move.w	(a4)+,d2
		move.w	d2,(a5)+
		move.w	d2,(a6)+
		dbra	d1,mnulu_l2
		lea	320(a5),a5
		lea	320(a6),a6
		dbra	d0,mnulu_l1

mnul_no_preview

	; episoden- und level-nummer

;		movea.l	screen_1,a6
;		adda.l	#640*220+80*2,a6
;		lea	loadsave_txt,a0
;		bsr	paint_text4x5

		rts

mnul_upd_flag	dc.w	0

;---------------

mnul_make_screen
		
		lea	mnul_txt,a0
		movea.l	#truecolor_tab+153600+128+640*10+45*2,a6
		bsr	paint_menutext

		movea.l	#truecolor_tab+153600+128,a0
		movea.l	screen_1,a1
		jsr	copy_240
		movea.l	#truecolor_tab+153600+128,a0
		movea.l	screen_2,a1
		jsr	copy_240

		bsr	mnu_load_beschr

		rts

;---------------

mnu_load_beschr

	; laedt alle beschreibungen und gibt sie aus ...

		moveq	#9,d7
mnulb_loop
		move.w	d7,-(sp)
		lea	truecolor_tab-rsx_preview,a6
		lea	loadsave_files(pc),a0
		movea.l	(a0,d7.w*4),a0
		moveq	#1,d5
		jsr	load_game

		tst.w	sg_error_flag
		beq.s	mnulb_no_error

		lea	mnulb_empty,a0
		move.w	(sp),d7
		lsl.w	#4,d7
		mulu	#640,d7
		movea.l	screen_1,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		bsr	paint_text4x5

		lea	mnulb_empty,a0
		move.w	(sp),d7
		lsl.w	#4,d7
		mulu	#640,d7
		movea.l	screen_2,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		bsr	paint_text4x5

	; die beschreibung auch in den speicher kopieren

		lea	mnulb_empty,a0
		lea	mnulb_beschreib(pc),a1
		move.w	(sp),d7
		mulu	#20,d7
		adda.l	d7,a1

	; 20 bytes kopieren

		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

		bra.s	mnulb_skip

mnulb_no_error
		lea	truecolor_tab-rsx_preview+rsx_beschreib,a0
		move.w	(sp),d7
		lsl.w	#4,d7
		mulu	#640,d7
		movea.l	screen_1,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		bsr	paint_text4x5

		lea	truecolor_tab-rsx_preview+rsx_beschreib,a0
		move.w	(sp),d7
		lsl.w	#4,d7
		mulu	#640,d7
		movea.l	screen_2,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		bsr	paint_text4x5

	; die beschreibung auch in den speicher kopieren

		lea	truecolor_tab-rsx_preview+rsx_beschreib,a0
		lea	mnulb_beschreib(pc),a1
		move.w	(sp),d7
		mulu	#20,d7
		adda.l	d7,a1

	; 20 bytes kopieren

		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

mnulb_skip
		move.w	(sp)+,d7
		dbra	d7,mnulb_loop

		rts

;---

mnulb_empty	dc.b	"EMPTY SLOT",0
		even
mnulb_beschreib	ds.b	20*10


;**************************************
;* menue_save
;**************************************

; benutzt wird der speicherplatz der farbtabelle 

menue_save

		clr.b	keytable+$01
		clr.w	mnul_upd_flag

	; aktuellen screen zwischenspeichern

		movea.l	screen_2,a0
		lea	truecolor_tab,a1
		bsr	copy_240

	; richtige aufloesung setzen ...

;		move.w	double_scan,-(sp)
;		move.w	cinemascope,-(sp)
;		move.l	true_offi,-(sp)

;		move.l	#640,true_offi
                move.w  #2,dont_change_scr
		move.l	#si_320x240,d0
		tst.w	vga_monitor
		beq.s	mnus_no_vga
		move.l	#si_320x240vga,d0
mnus_no_vga	move.l	d0,screen_init_rout_ptr

	; grafiken laden 

		bsr	mnu_load_files		

	; screen aufbauen

		jsr	vsync
		jsr	swap_me
		jsr	vsync
		jsr	swap_me

		bsr	mnus_make_screen
		bsr	mnus_make_preview

mnus_main
		jsr	jagpad_simul

		bsr	mnu_arrow
		bsr	mnu_keys
		bsr	mnul_update

		bsr	mnus_name

		jsr	vsync
		jsr	swap_me

		tst.w	mnua_escape
		beq.s	mnus_main

		clr.w	mnua_escape

	; screen wiederherstellen

;		move.l	(sp)+,true_offi
;		move.w	(sp)+,cinemascope
;		move.w	(sp)+,double_scan
		bsr	install_si_routine
		move.w	#2,dont_change_scr
                move.w  #1,clear_it_flag

		lea	truecolor_tab,a0
		movea.l	screen_1,a1
		bsr	copy_240

		jsr	vsync
		jsr	swap_me
		jsr	vsync
		jsr	swap_me

		movea.l	screen_2,a0
		movea.l	screen_1,a1
		bsr	copy_240

	; und jetzt feststellen ob ein level gespeichert
	; werden soll oder nicht

;		movea.l	play_dat_ptr,a0
;		tst.w	pd_on_terminal(a0)
;		bne.s	mnus_no_save

		lea	mnua_y_activ(pc),a0
		tst.w	(a0)
		beq.s	mnus_no_save
		clr.w	(a0)

	; nehme noch verschiedene anpassungen vor

		nop

	; jetzt speichern

		move.w	mnua_y(pc),d0
		lea	loadsave_files(pc),a0
		movea.l	(a0,d0.w*4),a0
		jsr	save_game

		tst.w	sg_error_flag
		bne	menue_save

		move.b	#1,keytable+$01

mnus_no_save

	; farbtabelle laden

		moveq	#1,d0
		move.w	d0,sc_load_flag
		move.w	d0,clear_it_flag

		rts

;---------------

; routine, die die bezeichnung des slots ermittelt

mnus_name
		tst.w	mnua_y_activ
		beq	mnusn_no_slot

	; ok - ein slot ist aktiviert worden

	; die aktuelle beschreibung uebernehmen

		lea	mnulb_beschreib(pc),a0
		move.w	mnua_y(pc),d0
		mulu	#20,d0
		adda.l	d0,a0
		lea	mnu_beschreibung(pc),a1

		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+


mnusn_loop

		bsr	mnu_arrow

	; beschreibung zeichnen
	; dazu vorher hintergrund loeschen (80x5)

		move.w	mnua_y(pc),d7
		mulu	#640*16,d7
		addi.l	#mnutext_offi,d7
		movea.l	screen_1,a5
		adda.l	d7,a5
		moveq	#4,d7
mnusn_bc_loop	moveq	#19,d6
mnusn_bc_loop2	clr.l	(a5)+
		clr.l	(a5)+
		dbra	d6,mnusn_bc_loop2
		lea	640-80*2(a5),a5
		dbra	d7,mnusn_bc_loop

		lea	mnu_beschreibung(pc),a0
		move.l	a0,-(sp)
		move.w	mnua_y(pc),d7
		mulu	#640*16,d7
		movea.l	screen_1,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		bsr	paint_text4x5

	; laenge feststellen

		move.l	a0,d0
		sub.l	(sp)+,d0	
		subq.w	#1,d0
		move.w	d0,mnusn_pos

	; cursor zeichnen

		move.w	mnua_y(pc),d7
		mulu	#640*16,d7
		movea.l	screen_1,a6
		adda.l	#mnutext_offi,a6
		adda.l	d7,a6
		lsl.w	#3,d0
		adda.w	d0,a6
		move.b	vbl_count+3,d0
		moveq	#4,d1
mnusn_cursor_l	move.b	d0,(a6)
		move.b	d0,1(a6)
		move.b	d0,2(a6)
		move.b	d0,3(a6)
		lea	640(a6),a6
		dbra	d1,mnusn_cursor_l

	; tastatureingabe

		bsr	get_next_ascii

		tst.b	d0
		beq	mnusn_skip_ascii

		lea	mnusn_pos(pc),a0
		lea	mnu_beschreibung(pc),a1

		cmpi.b	#$08,d0		; backspace
		bne.s	mnusn_no_08

		move.w	(a0),d1
		clr.b	-1(a1,d1.w)
		move.w	#snd_schreibm,d0
		moveq	#0,d1
		bsr	init_sam
		bra.s	mnusn_skip_ascii

mnusn_no_08

		cmpi.b	#$0d,d0		; enter
		bne.s	mnusn_no_1c

		move.w	#1,mnua_escape
		move.w	#snd_menue_item,d0
		moveq	#0,d1
		bsr	init_sam
		bra	mnusn_no_slot
mnusn_no_1c

	; alles andere ausser $08 und $0d ist
	; ein normales zeichen

		move.w	(a0),d1
		addq.w	#1,d1
		cmpi.w	#19,d1
		blt.s	mnusn_ascii_ok
		moveq	#19,d1
mnusn_ascii_ok	move.w	d1,(a0)

		move.b	d0,-1(a1,d1.w)	; buchstabe eintragen
		clr.b	(a1,d1.w)	; endkennung richtig setzen

		move.w	#snd_schreibm,d0
		moveq	#0,d1
		bsr	init_sam

mnusn_skip_ascii

		jsr	vsync
		jsr	swap_me

		bra	mnusn_loop
		
mnusn_no_slot
		rts

;---

mnusn_pos	dc.w	0

;---

; eine scheiss routine - und alles nur, weil
; ich bisher mit scancodes wunderbar zurecht
; gekommen bin - und jetzt brauche ich eben den
; ascii-code. routine geht ueber tabellen ...

; rueckgabe in d0: ascii-code

get_next_ascii
		lea	keytable,a0
		lea	scan_to_ascii_tab,a1

		tst.b	$2a(a0)
		beq.s	gna_no_shift_l
		addq.l	#1,a1
		bra.s	gna_start
gna_no_shift_l	tst.b	$36(a0)
		beq.s	gna_start
		addq.l	#1,a1

gna_start
		moveq	#$7f,d7
		moveq	#0,d0
gna_loop		
		tst.b	(a0,d7.w)
		beq.s	gna_not_pressed

	; taste x ist gedrueckt
	; hat taste x einen ascii-code ?

		move.b	(a1,d7.w*2),d0
		beq.s	gna_not_pressed

		clr.b	(a0,d7.w)
		bra.s	gna_out

gna_not_pressed
		dbra	d7,gna_loop

gna_out
		rts

;---

mnu_keys
		tst.b	keytable+$48
		beq.s	mnuk_no48
		clr.b	keytable+$48
		move.w	#snd_menue_up,d0
		moveq	#0,d1
		bsr	init_sam
		move.w	mnua_y(pc),d0
		subq.w	#1,d0
		bpl.s	mnuk_48_ok
		moveq	#9,d0
mnuk_48_ok	move.w	d0,mnua_y
		clr.w	mnul_upd_flag
mnuk_no48

		tst.b	keytable+$50
		beq.s	mnuk_no50
		clr.b	keytable+$50
		move.w	#snd_menue_down,d0
		moveq	#0,d1
		bsr	init_sam
		move.w	mnua_y(pc),d0
		addq.w	#1,d0
		cmpi.w	#10,d0
		blt.s	mnuk_50_ok
		moveq	#0,d0
mnuk_50_ok	move.w	d0,mnua_y
		clr.w	mnul_upd_flag
mnuk_no50

		clr.w	mnua_y_activ
		tst.b	keytable+$1c
		beq.s	mnuk_no1c
		clr.b	keytable+$1c
		move.w	#1,mnua_y_activ
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
mnuk_no1c

		tst.b	keytable+$01
		beq.s	mnuk_no01
		move.w	#snd_menue_enter,d0
		moveq	#0,d1
		bsr	init_sam
		clr.b	keytable+$01
		move.w	#1,mnua_escape
mnuk_no01

		rts

;---

mnus_make_preview

	; erzeugen der 160x120 preview-grafik

		move.l	mnu_pic_ptr(pc),file_buf_ptr
		move.l	#ml_screenfile,file_name_ptr
		move.l	#160*120*2,file_size
		jsr	load_file

		rts

;---

mnus_make_screen
		
		lea	mnus_txt,a0
		movea.l	#truecolor_tab+153600+128+640*10+45*2,a6
		bsr	paint_menutext

		movea.l	#truecolor_tab+153600+128,a0
		movea.l	screen_1,a1
		jsr	copy_240
		movea.l	#truecolor_tab+153600+128,a0
		movea.l	screen_2,a1
		jsr	copy_240

		bsr	mnu_load_beschr

		rts

;---------------

mnu_load_files
		move.l	#loadsave_pic,file_name_ptr
		move.l	#153768,file_size
		move.l	#truecolor_tab+mnulf_loadsave,file_buf_ptr
		jsr	load_file

		move.l	#arrow_pic,file_name_ptr
		move.l	#49280,file_size
		move.l	#truecolor_tab+mnulf_arrow,file_buf_ptr
		jsr	load_file

		rts

;---------------

mnu_arrow
		move.w	mnua_count(pc),d0
		add.w	vbl_time,d0
		cmpi.w	#mnua_each_vbl,d0
		blt.s	mnua_no_change
		moveq	#0,d0
		move.w	mnua_pos(pc),d1
		addq.w	#1,d1
		cmpi.w	#mnua_anz,d1
		blt.s	mnua_no_start
		moveq	#0,d1
mnua_no_start	move.w	d1,mnua_pos
mnua_no_change	move.w	d0,mnua_count

		move.w	mnua_y(pc),d0
		lsl.w	#4,d0		; 16 zeilen
		mulu	#640,d0
		movea.l	screen_1,a6
		adda.l	#mnua_offi,a6
		movea.l	a6,a5
		adda.l	d0,a6

	; hintergrund loeschen

		lea	truecolor_tab+mnulf_loadsave+128,a4
		adda.l	#mnua_offi,a4

		move.w	#167,d7
mnua_clear_loop	movem.l	(a4),d0-d6/a0-a1
		movem.l	d0-d6/a0-a1,(a5)
		movem.l	36(a4),d0-d6/a0-a1
		movem.l	d0-d6/a0-a1,36(a5)
		lea	640(a4),a4
		lea	640(a5),a5
		dbra	d7,mnua_clear_loop

	; pfeil kopieren

		move.w	mnua_pos(pc),d0
		mulu	#32*2*24,d0
		lea	truecolor_tab+mnulf_arrow+128,a5
		adda.l	d0,a5

		moveq	#23,d6			; 24 zeilen
mnua_copy_loop	moveq	#31,d7
mnua_copy_loop2	move.w	(a5)+,d0
		cmpi.w	#%0000000000100000,d0
		beq.s	mnua_no_copy
		move.w	d0,(a6)
mnua_no_copy	addq.l	#2,a6
		dbra	d7,mnua_copy_loop2
		lea	640-64(a6),a6
		dbra	d6,mnua_copy_loop

		rts

;---

mnua_pos	dc.w	0
mnua_count	dc.w	0
mnua_y		dc.w	0
mnua_y_activ	dc.w	0
mnua_escape	dc.w	0

mnu_beschreibung
		dc.b	"RUNNING SAVE 4",0
		ds.b	20
		even
mnu_pic_ptr
		dc.l	truecolor_tab+mnulf_pic

;---------------

; a6: screen
; a0: text

paint_text4x5

		movem.l	d4/d6-d7/a5,-(sp)
pt4x5_loop
		move.b	(a0)+,d2
		beq.s	pt4x5_out
		bsr	paint_letter4x5
		bra.s	pt4x5_loop
pt4x5_out
		movem.l	(sp)+,d4/d6-d7/a5
		rts

;---

; a6: screen
; d2: ascii-zeichen

paint_letter4x5

		cmpi.b	#"a",d2
		blt.s	pl4x5_no_small
		subi.b	#$20,d2
pl4x5_no_small

		lea	font4x5,a5
		subi.b	#"!",d2
		bmi.s	pl4x5_space

		ext.w	d2
		mulu	#40,d2
		adda.w	d2,a5

		move.l	a6,-(sp)
		moveq	#mt_font_heigth-1,d4
pl4x5_loop	movem.l	(a5)+,d6-d7
		movem.l	d6-d7,(a6)
		lea	640(a6),a6
		dbra	d4,pl4x5_loop
		movea.l	(sp)+,a6

pl4x5_space
		addq.l	#8,a6

		rts


;---------------

loadsave_txt	dc.b	"EPISODE: "
ls_episode	dc.b	"00 / LEVEL: "
ls_level	dc.b	"00",0
		even

mnul_txt	dc.b	"LOAD GAME",0
mnus_txt	dc.b	"SAVE GAME",0
		even

loadsave_files
		dc.l	ls0
		dc.l	ls1
		dc.l	ls2
		dc.l	ls3
		dc.l	ls4
		dc.l	ls5
		dc.l	ls6
		dc.l	ls7
		dc.l	ls8
		dc.l	ls9

ls0		dc.b	"save\runsave0.dat",0
ls1		dc.b	"save\runsave1.dat",0
ls2		dc.b	"save\runsave2.dat",0
ls3		dc.b	"save\runsave3.dat",0
ls4		dc.b	"save\runsave4.dat",0
ls5		dc.b	"save\runsave5.dat",0
ls6		dc.b	"save\runsave6.dat",0
ls7		dc.b	"save\runsave7.dat",0
ls8		dc.b	"save\runsave8.dat",0
ls9		dc.b	"save\runsave9.dat",0
		even
