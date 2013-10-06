   
;  ***  *  * *  * *  * * *  *  **
;  *  * *  * ** * ** * * ** * *  *
;  *  * *  * * ** * ** * * ** *
;  ***  *  * *  * *  * * *  * * **
;  *  * *  * *  * *  * * *  * *  *
;  *  * *  * *  * *  * * *  * *  *
;  *  *  **  *  * *  * * *  *  **

; (c) 1994-1997 by RDT

; Wichtigste Flags: FINAL, MENUEFLAG und LAUFWERK

;**************************************
;* equ's
;**************************************

;---------------------------------------
final           equ 	1		; 0 = debug-version fuer e:\running
					; 1 = final-version fuer akt. verzeichnis
;---------------------------------------
menueflag	equ	1		; 0 = kein mainmenue
					; 1 = mit mainmenue
;---------------------------------------
mxalloc_flag	equ	1		; 0 = alles ein RAM-Typ
					; 1 = screen/samples aus ST-RAM
;---------------------------------------
cheattable	equ	0		; 0 = cheatcodetabelle 1 (official release)
					; 1 = special codes for someone
;---------------------------------------
registry_flag	equ	1		; 0 = keine anzeige des registrierten kaeufers
					; 1 = registrierten kaeufer anzeigen
;---------------------------------------
show_reg_hex	equ	0		; 0 = keine debug-anzeige
					; 1 = debug-anzeige
;---------------------------------------
episode_check	equ	1		; 0 = keine kontrolle von episode.dat
					; 1 = kontrolle von episode.dat
;---------------------------------------
level_max_gr	equ	315000		; maximale levelgroesse in bytes
;---------------------------------------
skip_intro_flag	equ	0		; 0 = mainmenue ist nicht ueberspringbar
					; 1 = mainmenue kann ausgelassen werden
;---------------------------------------
laufwerk	equ	4		; 4 = e:\running
					; 5 = f:\running
					; 6 = g:\running etc.
;---------------------------------------
save_in_menue	equ	0		; 0 = speichermoeglichkeit im mainmenue nicht gegeben
					; 1 = speichermoeglichkeit im mainmenue gegeben

;---------------------------------------

sc_debug	equ	0		; (spezielle debuganzeigen)

ivan_debug	equ	0

dv_bug		equ	0
dma_debug	equ	0
compile_level	equ	0
record_lauf	equ	0
play_lauf	equ	0
disk		equ	0
debug           equ 	0
debug_color     equ 	0

time_debug	equ	0

;---------------------------------------
mx_screen_len	equ	308096
mx_sample_len	equ	215000
mx_intsam_len	equ	248140
;---------------------------------------

		include	"include\const_02.s"
		include	"include\con_pist.s"

;**************************************
;**************************************
                

		text

		movea.l	sp,a5
		movea.l	4(a5),a5	; base page
		movea.l	a5,a4
		move.l	12(a5),d0	; codelaenge
		add.l	20(a5),d0	; datalaenge
		add.l	28(a5),d0	; bsslaenge
		addi.l	#2000,d0	; genuegend stack
		move.l	d0,d1
		add.l	a5,d1
		andi.l	#-2,d1		; gerade machen
		movea.l	d1,sp		; stackpointer
		move.l	d0,-(sp)	; speicherbedarf
		move.l	a5,-(sp)	; von ...
		clr.w	-(sp)		; dummy
		move.w	#74,-(sp)	; MSHRINK
		trap	#1		; GEMDOS
		lea	12(sp),sp


the_running_programme

		bsr	mxalloc
		tst.w	mxalloc_error
		bne	out_mxalloc

		bsr	quickstart

		bra	main_start

		dc.b	"RUNNING - The fastest 3D action shooter, "
		dc.b	"(C) 1997 by RDT Volker Konrad, "
		dc.b	"Georg-Thiel-Str. 13, "
		dc.b	"D-95326 Kulmbach, "
		dc.b	"Germany. "
		even

qs_intro	dc.w	0
qs_music	dc.w	0

main_start

		pea	0
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_stack

		ifne ivan_debug
		move.l	#bus_error,$8.w
		endc

		dc.w	$a00a
		jsr	mouse_off
		jsr	cursor_off

		jsr	screen_save
;		jsr	double_vbl_test

		jsr	init_directories
		jsr	ml_correct_cheats

		ifne menueflag
run_main_loop	tst.w	qs_intro
		bne.s	qs_only_game
		jsr	MODULEdsp
		jsr	screen_init
		jsr	init_stuff
		jsr	init_stuff_2
		jsr	clear_menu_dith_data
		bsr	mainmenu
		tst.w	mm_start_running
		beq.s	run_main_out
		bsr	running
		jsr	restore_system
		bra.s	run_main_loop

qs_only_game
		jsr	screen_init
		jsr	init_stuff
		jsr	init_stuff_2
		bsr	running

run_main_out
		else
		jsr	screen_init
		jsr	init_stuff
		jsr	init_stuff_2
		bsr	running
		endc

		clr.w	double_scan
		clr.w	cinemascope
		movea.l	screen_1,a0
		jsr	clear_black_240
		moveq	#3,d0
		jsr	make_blenden

run_restore
                jsr     restore_system
                jsr     stop_dma_play

		jsr	screen_restore

out
		move.l	old_stack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

out_mxalloc
		clr.w	-(sp)
		trap	#1


;**************************************
;* running
;**************************************

; der spieler hat im mainmenue running angegeben

running

	ifeq menueflag
		movea.l	screen_1,a0
		jsr	clear_black_240
		moveq	#0,d0
		jsr	make_blenden
	else
		clr.b	keytable+$1
		movea.l	screen_2,a0
		movea.l	screen_1,a1
		jsr	copy_240		
	endc

		jsr	vsync
		jsr	init_dma_play

		ifne mxalloc_flag
		move.l	#intsam_file,file_name_ptr
		move.l	samples,file_buf_ptr
		move.l	#mx_intsam_len,file_size
		jsr	load_file
		endc

		jsr	episode_read
		jsr	prepare_menufont
		jsr	menue_start

		move.w	#1,mnu_no_run

running_start_new_level

		moveq	#0,d0
		jsr	install_dsp

		jsr	init_make_grey

		tst.w	mnu_run
		beq.s	run_no_new_game

running_new
		clr.w	mnu_run
		clr.w	menue_flag
		clr.w	mnu_no_run
		jsr	load_episode_level
		jsr	install_level
		move.w	#1,lt_firsttime
		bra.s	running_start		

run_no_new_game		

		tst.w	mnu_load_run
		beq	running_out

		clr.w	mnu_no_run
		clr.w	mnu_load_run
		move.w	#1,no_dsp_flag
		jsr	install_game
		clr.w	no_dsp_flag
		clr.w	lt_firsttime

running_start

		jsr	registry_control_flag
		jsr	registry_control_main_opcode
;		jsr	registry_control_checksum
;		jsr	registry_control_rts

                jsr     dsp_s_pts_lns
                jsr     dsp_s_table
                jsr     dsp_s_init_data
                jsr     dsp_s_normal

                jsr     init_vbl_time

		moveq	#0,d0
		jsr	make_blenden

		movea.l	screen_1,a0
		jsr	make_grey_now
		movea.l	screen_2,a0
		jsr	make_grey_now


running_main

	ifne ivan_debug

		move.l	#$1,ivan_code
		jsr	change_colortable
		move.l	#$2,ivan_code
		jsr	help_screen
		move.l	#$3,ivan_code
		jsr	being_bored
		move.l	#$4,ivan_code
		jsr	laptop_firsttime
		move.l	#$5,ivan_code
		jsr	jagpad_simul

		move.l	#$6,ivan_code
		jsr	test_action_fld
		move.l	#$7,ivan_code
		jsr	wall_animation
		move.l	#$8,ivan_code
		jsr	animate_all
		move.l	#$9,ivan_code
		jsr	move_it
		move.l	#$a,ivan_code
		jsr	test_position
		move.l	#$b,ivan_code
		jsr	find_vbl_time
		move.l	#$c,ivan_code
		jsr	calc_time_limit
		move.l	#$d,ivan_code
		jsr	action_keys

		move.l	#$e,ivan_code
		jsr	dsp_r_normal
		move.l	#$f,ivan_code
		jsr	dsp_info_ausw

		move.l	#$10,ivan_code
		jsr	key_hit
		move.l	#$11,ivan_code
		jsr	keys_stuff

		move.l	#$12,ivan_code
		jsr	dsp_s_all

		move.l	#$13,ivan_code
		jsr	message_clearer
		move.l	#$14,ivan_code
		jsr	paint_all

		move.l	#$15,ivan_code
		jsr	menue
		move.l	#$16,ivan_code
		jsr	message_maker


		ifne dv_bug
		movea.l	screen_1,a2
		adda.l	#640*210+80,a2
		moveq	#3,d7
		move.w	dv_flag,d0
		jsr	paint_hex
		endc

		movea.l	play_dat_ptr,a6
		movea.l	pd_in_akt_ss_ptr(a6),a0

		moveq	#17,d7
		moveq	#0,d5
		moveq	#0,d6

id_loop		movem.l	d5-a0,-(sp)
		movea.l	screen_2,a2
		adda.l	d5,a2
		adda.l	d6,a2
		moveq	#17,d4
		sub.w	d7,d4
		move.l	(a0,d4.w*4),d0
		moveq	#7,d7
		jsr	paint_hex

		movem.l	(sp)+,d5-a0

		addi.w	#80,d5
		cmpi.w	#240,d5
		blt.s	id_l
		moveq	#0,d5
		addi.w	#6400,d6
id_l

		dbra	d7,id_loop

		tst.w	vsync_flag
		bne.s	r_no_vsync
		jsr	vsync
r_no_vsync	jsr	swap_me
		
		move.l	#$17,ivan_code
		jsr	clear_if_nessec

		lea	quit_flag,a0
		tst.w	(a0)
		beq	running_main

	else

		jsr	change_colortable
		jsr	help_screen
		jsr	being_bored
		jsr	laptop_firsttime
		jsr	jagpad_simul

		jsr	test_action_fld
		jsr	wall_animation
		jsr	animate_all
		jsr	move_it
		jsr	test_position
		jsr	find_vbl_time
		jsr	calc_time_limit
		jsr	action_keys

		jsr	dsp_r_normal
		jsr	dsp_info_ausw

		jsr	key_hit
		jsr	keys_stuff

		jsr	dsp_s_all

		jsr	message_clearer
		jsr	paint_all


		jsr	menue
		jsr	message_maker

;		jsr	frames_per_second
;		jsr	who_waited

		ifne dv_bug
		movea.l	screen_1,a2
		adda.l	#640*210+80,a2
		moveq	#3,d7
		move.w	dv_flag,d0
		jsr	paint_hex
		endc

		tst.w	vsync_flag
		bne.s	r_no_vsync
		jsr	vsync
r_no_vsync	jsr	swap_me
		
		jsr	clear_if_nessec

		lea	quit_flag,a0
		tst.w	(a0)
		beq	running_main

	endc


		clr.w	(a0)
                jsr     dsp_r_normal

running_out
		move.w	#3,karo_speed
		jsr	karo_ausblenden_sound

		tst.w	mnu_run
		bne	running_new

		jsr	close_dsp

		bsr	levelend_screen

		tst.w	le_load_next
		bne	load_next_level
lnl_out

		rts


;**************************************
;* mxalloc
;**************************************

mxalloc

	; error flag loeschen

		clr.w	mxalloc_error

		ifne mxalloc_flag

	; speicher fuer bildschirm anfordern

		move.w	#%00,-(sp)
		move.l	#mx_screen_len,-(sp)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0
		beq.s	mx_e1

	; anforderung war erfolgreich
	; berechnung der screenadressen
	; und diese eintragen

		addi.l	#256+128,d0
		andi.l	#$ffffff00,d0
		move.l	d0,screen_1
		addi.l	#153600+256,d0
		move.l	d0,screen_2

	; speicher fuer samples anfordern

		move.w	#%00,-(sp)
		move.l	#mx_sample_len,-(sp)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0
		beq.s	mx_e2

		move.l	d0,samples_data

	; speicher fuer interne sample anfordern

		move.w	#%00,-(sp)
		move.l	#mx_intsam_len,-(sp)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0
		beq.s	mx_e3

		bsr	calc_sample_addresses

		bra	mx_out

mx_e1
		pea	sm_mxalloc_1
		move.w	#9,-(sp)	
		trap	#1
		addq.l	#6,sp
		bra.s	mx_key

mx_e2
		pea	sm_mxalloc_2
		move.w	#9,-(sp)	
		trap	#1
		addq.l	#6,sp
		bra.s	mx_key

mx_e3
		pea	sm_mxalloc_3
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

mx_key
		pea	sm_mxalloc
		move.w	#9,-(sp)	
		trap	#1
		addq.l	#6,sp
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp

		move.w	#1,mxalloc_error

mx_out
		endc

		rts

mxalloc_error	dc.w	0


;**************************************
;* calc_sample_addresses
;**************************************

; d0 = durch mxalloc angeforderter speicherbereich

calc_sample_addresses

	; durchgang 1: alle samples mit positiver laenge beruecksichtigen

		lea	samples,a0
		moveq	#0,d1
csa_loop1	tst.l	(a0)
		bmi.s	sca_out1
		move.l	4(a0),d2		; samplelaenge
		bmi.s	sca_skip1
		move.l	d1,d3
		add.l	d0,d3
		move.l	d3,(a0)
		add.l	d2,d1
sca_skip1	lea	12(a0),a0
		bra.s	csa_loop1
sca_out1

	; durchgang 2: alle samples mit negativer laenge beruecksichtigen

		lea	samples,a0
		moveq	#0,d1
csa_loop2	tst.l	(a0)
		bmi.s	sca_out2
		move.l	4(a0),d2
		bpl.s	sca_skip2
		move.l	d1,d3
		add.l	d0,d3
		move.l	d3,(a0)
		neg.l	d2
		move.l	d2,4(a0)
		add.l	d2,d1
sca_skip2	lea	12(a0),a0
		bra.s	csa_loop2
sca_out2

		rts


;**************************************
;* quickstart
;**************************************

quickstart

		ifne menueflag

	; quickstart abfragen, dazu gemdos routinen verwenden ...

		pea	sm_quickstart
		move.w	#9,-(sp)		; c_conws
		trap	#1
		addq.l	#6,sp

	; tastendruck holen ...

		move.w	#7,-(sp)		; c_rawcin
		trap	#1
		addq.l	#2,sp

		swap	d0			; will den scancode in d0[7..0]

		lea	qs_intro,a0

		moveq	#0,d1
		cmpi.b	#$17,d0			; "I" ?
		bne.s	qs_no_17
		ifne	skip_intro_flag
		moveq	#1,d1
		else
		nop
		endc
qs_no_17	move.w	d1,(a0)

		moveq	#0,d1
		cmpi.b	#$32,d0
		bne.s	qs_no_32
		moveq	#1,d1
qs_no_32	move.w	d1,2(a0)

		moveq	#0,d1
		cmpi.b	#$20,d0
		bne.s	qs_no_20
		moveq	#1,d1
qs_no_20	move.w	d1,dv_flag

		cmpi.b	#$30,d0
		bne.s	qs_no_30
		moveq	#1,d1
		move.w	d1,2(a0)
		move.w	d1,dv_flag
qs_no_30

	; und los gehts ...

		endc

		rts


;**************************************
;* levelend_screen
;**************************************

		include	"include\levelend.s"


;**************************************
;* registry
;**************************************

		include	"include\registry.s"


;**************************************
;* init_point
;**************************************

		include	"include\initpnt.s"


;**************************************
;* animate_shoot
;**************************************

		include	"include\shotanim.s"


;**************************************
;* mainmenue
;**************************************

mainmenue_start
		ifne menueflag
		include	"include\menu\menuv6.txt"
		endc
mainmenue_end

;---------------

clear_menu_dith_data

		lea	dith_data,a0
		move.l	#dith_data_end,d0
		sub.l	a0,d0
		lsr.l	#4,d0
		subq.w	#1,d0
cmdd_loop
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		dbra	d0,cmdd_loop

		rts

;---------------

save_compiled_menu

	ifne menueflag

		move.l	#menu_file,file_name_ptr
		move.l	#mainmenue_end-mainmenue_start,file_size
		move.l	#mainmenue_start,file_buf_ptr

		jsr	save_file

	endc

		rts

;---------------

load_compiled_menu

	ifne menueflag

		move.l	#menu_file,file_name_ptr
		move.l	#mainmenue_end-mainmenue_start,file_size
		move.l	#mainmenue_start,file_buf_ptr

		jsr	load_file

	endc

		rts

;---------------

mm_load_options
		ifne menueflag
		move.l	#mm_options_file,file_name_ptr
		move.l	#mm_options_start,file_buf_ptr
		move.l	#mm_options_end-mm_options_start,file_size
		jsr	load_file
		endc

		rts

;---------------

mm_save_options

		ifne menueflag
		move.l	#mm_options_file,file_name_ptr
		move.l	#mm_options_start,file_buf_ptr
		move.l	#mm_options_end-mm_options_start,file_size
		jsr	save_file
		endc

		rts

;**************************************
;* dma player
;**************************************

		include	"include\dma_v307.s"


;**************************************
;* menue
;**************************************

		include	"include\menue.s"


;**************************************
;* help_screen
;**************************************

		include	"include\help.s"


;**************************************
;* being_bored
;**************************************

		include	"include\bored.s"


;**************************************
;* animate_all
;**************************************

animate_all
		tst.w	menue_flag
		bne.s	aa_out

                bsr     find_vis_monst
		bsr     animate_monster
		bsr     animate_trains
                bsr     animate_doors
                bsr     animate_lifts
		jsr	animate_shoot
aa_out
		rts


;**************************************
;* paint_pistol                       *
;**************************************

		include	"include\ppistol.s"


;--------------------------------------

change_colortable

		ifne	sc_debug
		movea.l	screen_2,a2
		adda.l	#640*4+100,a2
		moveq	#3,d7
		lea	sc_stack,a1
		moveq	#15,d6
cco_loop	move.w	(a1)+,d0
		adda.l	#640*10,a2
		movem.l	a1-a2/d6-d7,-(sp)
		jsr	paint_hex
		movem.l	(sp)+,a1-a2/d6-d7
		dbra	d6,cco_loop
		adda.l	#640*10,a2
		move.w	sc_stack_pos,d0
		jsr	paint_hex
		endc		


		tst.w	sc_load_flag
		beq.s	cco_out

		clr.w	sc_load_flag

		bsr	get_sc_with_priority
		andi.w	#%111,d0
		jsr	load_truecolor_tab

cco_out
		rts

;---------------

get_sc_with_priority

		lea	sc_stack,a0		; pointer stackbeginn
		move.w	sc_stack_pos,d2		; stackgroesse
		beq.s	gscwp_out
		move.w	-2(a0,d2.w*2),d0	; letzten eintrag holen
		lea	sc_priority,a2		; prioritaetenliste holen
		lea	(a2,d0.w*2),a1		; und auf d0-te spalte voreinstellen
gscwp_loop
		subq.w	#1,d2
		bmi.s	gscwp_out		; noch eintraege vorhanden?
		move.w	(a0,d2.w*2),d1		; eintrag holen
		lsl.w	#4,d1			; auf entspr. zeilenoffset bringen
		tst.w	(a1,d1.w)		; prioritaet vorhanden
		beq.s	gscwp_loop		; wenn nein, dann naechsten eintrag
		move.w	(a0,d2.w*2),d0		; ansonsten diese farbtabelle nehmen
		lea	(a2,d0.w*2),a1		; und damit weitervergleichen
		bra.s	gscwp_loop

gscwp_out
		rts

;--------------------------------------

frames_per_second:

		tst.w	vga_monitor
		bne.s	fps_vga
		move.l	#500,d7
		bra.s	fps_go_on
fps_vga:	move.l	#600,d7
fps_go_on:
		divu	vbl_time,d7
		move.w	d7,d0
		jsr	pl_convert_deci

		lea	pl_txt,a0
		movea.l	screen_1,a2
		movea.l	screen_2,a3
	
		move.w	true_offi+2,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lsr.w	#1,d1
		add.w	d1,d0
		adda.w	d0,a2
		adda.w	d0,a3

		move.w	#$ff0f,d1
		bsr	paint_deci
				
		rts

;---------------

; kopiert 320*240*2 bytes von (a0) nach (a1)

copy_240
		move.w	#240*10-1,d7
		moveq	#64,d4
copy_240_loop
		movem.l	(a0)+,d0-d3/a2-a5
		movem.l	d0-d3/a2-a5,(a1)
		movem.l	(a0)+,d0-d3/a2-a5
		movem.l	d0-d3/a2-a5,32(a1)
		adda.w	d4,a1
		dbra	d7,copy_240_loop

		rts


;**************************************
;* screen_abdunkeln
;**************************************

; a0 = screen

screen_abdunkeln

		move.w	#239,d0
sa_loop1	moveq	#79,d1
		btst	#0,d0
		beq.s	sal_1
sal_0		clr.w	(a0)+
		addq.w	#2,a0
		clr.w	(a0)+
		addq.w	#2,a0
		dbra	d1,sal_0
		bra.s	sal_all
sal_1		addq.w	#2,a0
		clr.w	(a0)+
		addq.w	#2,a0
		clr.w	(a0)+
		dbra	d1,sal_1
sal_all		dbra	d0,sa_loop1

		rts


;--------------

;*** change of d0-d3/a2-a5

copy_1:         moveq   #19,D4
copy_1_loop:    movem.l (A0)+,D0-D3/A2-A5
                movem.l D0-D3/A2-A5,(A1)
                lea     32(A1),A1
                dbra    D4,copy_1_loop

                rts

;***********************************************

init_vbl_time:  
                move.l  vbl_count,vbl_start

                rts

;---------------

find_vbl_time:
                move.l  vbl_count,D0
                move.l  D0,D1
                sub.l   vbl_start,D0
		bne.s	fvt_ok
		moveq	#1,d0
fvt_ok		move.w  D0,vbl_time
                move.l  D1,vbl_start

                rts


;**************************************
;* calc_time_limit
;**************************************

calc_time_limit

		ifeq	final
		tst.b	keytable+$12
		beq.s	ctl_no_key

		clr.b	keytable+$12

		tst.b	pd_time_flag(a6)
		beq.s	ctl_final_ein

		clr.b	pd_time_flag(a6)

		moveq	#2,d0
		jsr	delete_colortable

		bra.s	ctl_no_key

ctl_final_ein
		movea.l	play_dat_ptr,a6
		move.b	#1,pd_time_flag(a6)
		move.l	#30*50,pd_time_limit(a6)
		move.b	#$ff,pd_time_limit1+1(a6)
		move.b	#$ff,pd_time_limit2+1(a6)
		move.b	#$ff,pd_time_limit3+1(a6)
		move.b	#$ff,pd_time_limit4+1(a6)

		moveq	#2,d0
		jsr	set_colortable
ctl_no_key
		endc


		tst.w	menue_flag
		bne.s	ctl_out

		movea.l	play_dat_ptr,a6
		tst.w	pd_health(a6)
		bmi	ctl_out

	; zeitlimit, wenn aktiviert, herunterzaehlen

		tst.b	pd_time_flag(a6)
		beq	ctl_out

		move.l	pd_time_limit(a6),d0
		move.w	vbl_time,d1
		ext.l	d1
		sub.l	d1,d0
		bpl.s	ctl_no_end

	; zeitlimit ist abgelaufen

		move.w	#1,quit_flag
		move.w	#1,pd_timeout_flag(a6)

		moveq	#0,d0
		move.l	d0,pd_time_limit(a6)
		move.b	d0,pd_time_limit1(a6)
		move.b	d0,pd_time_limit2(a6)
		move.b	d0,pd_time_limit3(a6)
		move.b	d0,pd_time_limit4(a6)

		bra	ctl_out

ctl_no_end
		move.l	d0,pd_time_limit(a6)

		divu	#50,d0
		ext.l	d0

		divu	#600,d0
		move.b	d0,pd_time_limit1(a6)
		swap	d0
		ext.l	d0

		divu	#60,d0
		move.b	d0,pd_time_limit2(a6)
		swap	d0
		ext.l	d0

		divu	#10,d0
		move.b	d0,pd_time_limit3(a6)
		swap	d0
		move.b	d0,pd_time_limit4(a6)


ctl_out
		rts

;**************************************

karo_blend:     
                moveq   #14,D7
                movea.l screen_1,A0
karo_loop2:
                moveq   #19,D6
karo_loop1:
                bsr     karo_karo_blend
                lea     32(A0),A0

                dbra    D6,karo_loop1

                adda.w  #640*15+32,A0

                dbra    D7,karo_loop2

                move.w  karo_pos(PC),D0
                addq.w  #1,D0
                cmpi.w  #16,D0
                ble.s   karo_not_end

                moveq   #0,D0
karo_not_end:
                move.w  D0,karo_pos

                rts

;---------------

karo_blend_phys:
                moveq   #14,D7
                movea.l screen_2,A0
karo_loop_p2:
                moveq   #19,D6
karo_loop_p1:
                bsr.s   karo_karo_blend
                lea     32(A0),A0

                dbra    D6,karo_loop_p1

                adda.w  #640*15+32,A0

                dbra    D7,karo_loop_p2

                move.w  karo_pos(PC),D0
                addq.w  #1,D0
                cmpi.w  #16,D0
                ble.s   karo_not_end_p

                moveq   #0,D0
karo_not_end_p:
                move.w  D0,karo_pos

                rts

;---------------

karo_ausblenden:
                moveq   #15,D4
                bsr.s   karo_blend_init
intro_karo_l:
                bsr.s   karo_blend_phys

                movem.l D0-A6,-(SP)
                move.w  karo_speed(PC),D3
karo_spe_l:
                jsr     vsync

                dbra    D3,karo_spe_l
                movem.l (SP)+,D0-A6

                dbra    D4,intro_karo_l

                rts

;---------------

karo_ausblenden_sound:

                moveq   #15,D4
                bsr.s   karo_blend_init
intro_karo_snd:
                bsr.s   karo_blend_phys

                movem.l D0-A6,-(SP)

                btst    #0,D4
                beq.s   kbs_only_first
                bsr.s   volume_down_all
kbs_only_first:

                move.w  karo_speed(PC),D3
karo_spe_snd:
                jsr     vsync

                dbra    D3,karo_spe_snd
                movem.l (SP)+,D0-A6

                dbra    D4,intro_karo_snd

                rts

;---------------

; a0 = screenadresse obere linke ecke
; a1/a2  changed
; d0/d1 changed

karo_karo_blend:
                move.w  karo_pos(PC),D0
                move.w  D0,D1
                add.w   D1,D1
                movea.l A0,A1
                adda.w  D1,A1
                moveq   #15,D1
                sub.w   D0,D1
                add.w   D1,D1
                movea.l A0,A2
                adda.w  D1,A2
                adda.w  #640*16,A2
kk_loop:
                clr.w   (A1)
                clr.w   (A2)
                lea     640-2(A1),A1
                lea     -640+2(A2),A2

                dbra    D0,kk_loop

                rts

;---------------

karo_blend_init:
                clr.w   karo_pos

                rts

;---------------

karo_pos:       DC.W 0
karo_speed:     DC.W 0

;**************************************

volume_down_all:
		rts

;                lea     sam_dat,A0
                moveq   #3,D0
vol_down_loop:
                move.b  14(A0),D1
                addq.b  #1,D1
                cmpi.b  #$0F,D1
                blt.s   in_slide_down

                moveq   #$0f,D1
in_slide_down:
                move.b  D1,14(A0)

                lea     16(A0),A0
                dbra    D0,vol_down_loop

                rts


;**************************************
;* wall_animation
;**************************************

; wall_animation versieht things oder schalter
; mit beliebigen animationen. die funktionalitaet
; der things bzw. schalter bleibt voll erhalten.
; zuerst werden alle sichtbaren things und schalter
; bestimmt, die sichtbar sind (sein koennen) - vorausgesetzt,
; dass der sektor gewechselt wurde. anschliessend
; werden diese things und schalter animiert.

wall_animation:

		bsr	wa_find_walls
		bsr.s	wa_animation

		rts

;---------------

wa_animation:
		move.w	wall_anim_t_anz(pc),d0
		bmi.s	waa_schalter

		lea	wall_anim_t_ptr(pc),a0
waa_loop:
		move.l	(a0)+,a2		; a2 = thing
		move.l	thing_animation(a2),a1

		move.w	animation_count(a1),d1
		add.w	vbl_time,d1
		move.w	d1,animation_count(a1)
		cmp.w	animation_speed(a1),d1
		blt.s	waa_no_change

		clr.w	animation_count(a1)
		move.w	animation_pos(a1),d1
		addq.w	#1,d1
		cmp.w	animation_anz(a1),d1
		blt.s	waa_no_begin
		moveq	#0,d1
waa_no_begin:	move.w	d1,animation_pos(a1)

		movea.l	animation_data(a1),a3
		lsl.w	#2,d1
		move.w	2(a3,d1.w),thing_line+18(a2)
		move.b	1(a3,d1.w),thing_line+9(a2)
		
waa_no_change:
		dbra	d0,waa_loop

		; und jetzt alle
		; schalter animieren ...

waa_schalter:
		move.w	wall_anim_s_anz(pc),d0
		bmi.s	waa_out

		lea	wall_anim_s_ptr(pc),a0
waas_loop:
		move.l	(a0)+,a2		; a2 = schalter
		move.l	sch_animation(a2),a1

		move.w	animation_count(a1),d1
		add.w	vbl_time,d1
		move.w	d1,animation_count(a1)
		cmp.w	animation_speed(a1),d1
		blt.s	waas_no_change

		clr.w	animation_count(a1)
		move.w	animation_pos(a1),d1
		addq.w	#1,d1
		cmp.w	animation_anz(a1),d1
		blt.s	waas_no_begin
		moveq	#0,d1
waas_no_begin:	move.w	d1,animation_pos(a1)

		movea.l	animation_data(a1),a3
		lsl.w	#2,d1
		move.w	2(a3,d1.w),sch_line+26(a2)
		move.b	1(a3,d1.w),sch_line+17(a2)
		
waas_no_change:
		dbra	d0,waas_loop

waa_out:
		rts

;---------------

wa_find_walls:
		movea.l	play_dat_ptr,a0
		move.w	pd_akt_sector(a0),d0
		cmp.w	pd_wall_anim_sec(a0),d0
		beq	wafw_out		

		move.w	d0,pd_wall_anim_sec(a0)
		lea	wall_anim_s_ptr(pc),a5
		lea	wall_anim_t_ptr(pc),a6
		moveq	#-1,d1
		move.l	d1,wall_anim_s_anz

		movea.l	big_sector_ptr,a1
		move.w	d0,d1
		lsl.w	#2,d1
		addi.w	#lev_sec_start,d1
		adda.w	d1,a1
		move.l	(a1),a2				; a2 = sector
		move.l	a2,a3

		bsr	wafw_one_sector			; things
		bsr	wafw_s_one_sector		; schalter

		lea	sec_ext_lines(a2),a2
wafw_loop:
		move.w	(a2)+,d1
		bmi.s	wafw_sector_out
		lsl.w	#2,d1
		addi.w	#lev_sec_start,d1
		movea.l	big_sector_ptr,a1
		adda.w	d1,a1
		move.l	(a1),a3

		bsr	wafw_one_sector
		bsr	wafw_s_one_sector

		bra.s	wafw_loop	

wafw_sector_out

	; jetzt zuerst wieder die richtige
	; adresse zum eintragen bestimmen

		lea	wall_anim_t_ptr(pc),a6
		move.w	wall_anim_t_anz(pc),d4
		bmi.s	wafw_no_monsters
		lea	4(a6,d4.w*4),a6

		move.w	mon_buf2_anz,d7
		bmi.s	wafw_no_monsters
		movea.l	mon_buf2_ptr,a5

wafw_monst_loop

		movea.l	(a5)+,a4
		move.l	mon_thing_typ(a4),d1
		beq.s	wafw_monst_skip
		movea.l	d1,a4
		tst.l	thing_animation(a4)
		beq.s	wafw_monst_skip
		tst.w	thing_type(a4)
		bmi.s	wafw_monst_skip
		move.l	a4,(a6)+
		addq.w	#1,wall_anim_t_anz

wafw_monst_skip
		dbra	d7,wafw_monst_loop

wafw_no_monsters

wafw_out:
		rts

;---

wafw_one_sector:

		move.l	a3,-(sp)
		move.l	sec_things(a3),d2
		beq.s	wafwos_out

		move.l	d2,a3
wafwos_loop:
		move.l	(a3)+,d2
		beq.s	wafwos_no_thing
		bmi.s	wafwos_out
		move.l	d2,a4
		tst.l	thing_animation(a4)
		beq.s	wafwos_no_thing
		tst.w	thing_type(a4)
		bmi.s	wafwos_no_thing

		move.l	a4,(a6)+
		addq.w	#1,wall_anim_t_anz

wafwos_no_thing:
		bra.s	wafwos_loop

wafwos_out:
		move.l	(sp)+,a3
		rts

;---

wafw_s_one_sector:

		move.l	sec_schalter(a3),d2
		beq.s	wafwsos_out

		move.l	d2,a3
wafwsos_loop:
		move.l	(a3)+,d2
		beq.s	wafwsos_no_thing
		bmi.s	wafwsos_out
		move.l	d2,a4
		tst.l	sch_animation(a4)
		beq.s	wafwsos_no_thing
		tst.w	sch_zustand_anz(a4)
		bne.s	wafwsos_no_thing
		move.l	a4,(a5)+
		addq.w	#1,wall_anim_s_anz

wafwsos_no_thing:
		bra.s	wafwsos_loop

wafwsos_out:
		rts

;---------------

wall_anim_s_anz	dc.w	-1
wall_anim_t_anz	dc.w	-1
wall_anim_s_ptr	ds.l	animation_max
wall_anim_t_ptr	ds.l	animation_max


;**************************************
;* dsp_info_auswerten
;**************************************

dsp_info_ausw

		move.w	mon_buf1_anz,d7

		tst.w	d7
		bmi	dia_out

		lea	shooted_mon,a0
		movea.l	mon_buf1_ptr,a1
		moveq	#23,d3
dia_loop
		movea.l	(a1)+,a2		; a2 = pointer monster
		move.l	(a0)+,d1		; d1 = dsp_info
		btst	d3,d1
		beq.s	dia_no_hit

		movem.l	d3/d7/a0-a1,-(sp)
		bsr	mon_is_hit
		movem.l	(sp)+,d3/d7/a0-a1

dia_no_hit
		dbra	d7,dia_loop


dia_out
		movem.l	mon_buf1_ptr,a0-a1
		exg	a0,a1
		movem.l	a0-a1,mon_buf1_ptr

		movem.w	mon_buf1_anz,d0-d1
		exg	d0,d1
		movem.w	d0-d1,mon_buf1_anz

		rts


;**************************************
;* mon_is_hit
;**************************************

; routine zieht dem monster entsprechend
; dem munitionstyp ( -1 = staerke mun0 ) energie
; ab, spielt zugeh”rige samples ab und
; steuert die animationsphasen ...

; a2: pointer monster
; alle register frei ...


mon_is_hit

	; ist ein zivilist angeschossen worden ...

		movem.l	d0-a6,-(sp)
		move.w	mon_zivilist(a2),d0
		bmi.s	mih_no_civilian

	; natuerlich nur, wenn der zivilist noch nicht stirbt
	; oder gestorben ist ...

		tst.w	mon_a_died(a2)
		bne.s	mih_no_civilian

	; meldung ausgeben ...		

		lea	sm_civilian,a0
		bsr	install_message

	; ... und entsprechend energie abziehen

	; d0 ist immer noch mon_zivilist(a2)

		lea	civilian_staerke_tab,a0
		move.w	(a0,d0.w*2),d1
		lsl.w	#8,d1
		jsr	pd_health_minimieren

mih_no_civilian
		movem.l	(sp)+,d0-a6

	; -----------------------------

	; jetzt tatsaechlich energie abziehen ...	

		move.w	mon_health(a2),d0
		movea.l	play_dat_ptr,a6
		move.w	pd_mun_type(a6),d1
		lea	player_staerke_tab,a6
		sub.w	(a6,d1.w*2),d0
		bpl	mih_only_health

	; monster stirbt oder ist schon tot ...

		tst.w	mon_a_died(a2)
		bne	mih_out			; monster schon im sterben ...

	; das monster beginnt nun zu sterben ...

		clr.w	mon_health(a2)
		clr.w	mon_a_hit(a2)
		move.w	#1,mon_a_died(a2)

	; -----------------------------

	; soll das monster einen gegenstand
	; hinterlassen ?

		move.l	mon_thing_typ(a2),d0
		beq.s	mih_no_thing

		movem.l	mon_line(a2),d1-d2	; x-/y-koordinate
		moveq	#$60,d3
		add.l	d3,d1			; koordinate etwas
		add.l	d3,d2			; korrigieren ...
		move.b	mon_line+11(a2),d3	; hoehe

		movea.l	d0,a1			; a1 = gegenstand

		movem.l	d1-d2,thing_line(a1)
		move.b	d3,thing_line+11(a1)		; h1
		add.b	d3,thing_line+15(a1)		; h2

mih_no_thing

	; -----------------------------

		move.w	mon_died_snd(a2),d2
		bra.s	mih_play_snd

mih_only_health
		move.w	#1,mon_a_hit(a2)
		move.w	d0,mon_health(a2)

		move.w	mon_hit_snd(a2),d2
mih_play_snd
 		movem.l	mon_line(a2),d0-d1
		bsr	init_sam_dist

mih_out
		rts


;**************************************
;* find_visible_monsters
;**************************************
              
find_vis_monst:
                lea     fvm_secs,A0

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2
                movea.l play_dat_ptr,A4
                move.w  pd_akt_sector(A4),D0
                move.w  D0,(A0)+                  ; sector eintragen
                moveq   #0,D7
                lsl.w   #2,D0
                movea.l 0(A2,D0.w),A3
                adda.l  #sec_ext_lines,A3
fvm_fs_loop:
                addq.w  #1,D7
                move.w  (A3)+,(A0)+               ; sector eintragen
                bpl.s   fvm_fs_loop

                subq.w  #1,D7                     ; fvm_secs_anz

                lea     fvm_secs,A0

                movea.l big_sector_ptr,A1
                movea.l lev_monsters(A1),A1
                movea.l mon_dat(A1),A1
                movea.l mon_buf2_ptr,A4
                moveq   #0,D5

fvm_dat_loop:
                move.l  (A1)+,D0
                bmi.s   fvm_out

                movea.l D0,A2
                move.w  mon_sec(A2),D1

                movea.l A0,A3
                move.w  D7,D6

fvm_find_loop:
                cmp.w   (A3)+,D1
                beq.s   fvm_mon_vis

                dbra    D6,fvm_find_loop
                bra.s   fvm_dat_loop

fvm_mon_vis:
                move.l  A2,(A4)+                  ; in mon_send_buf2 eintragen
                addq.w  #1,D5
                bra.s   fvm_dat_loop

fvm_out:
                subq.w  #1,D5
                move.w  D5,mon_buf2_anz
                rts



;**************************************
;* animate_monster
;**************************************

		include	"include\anim_mo2.s"


;**************************************
;* animate_trains
;**************************************

		include	"include\anim_trn.s"


;**************************************
;* animate_doors / animate_lifts
;**************************************

		include	"include\anim_doo.s"


;**************************************

;* a0 = textpointer
;* a6 = screenadresse
;* text_height

paint_text:
                movem.l D3-A0/A3-A5,-(SP)
                move.l  A6,text_start_adr

paint_text_loop:
                move.b  (A0)+,D7
                beq.s   paint_text_out
                cmpi.b  #13,D7
                bne.s   paint_now

                move.w  text_height(PC),D7
                mulu    true_offi+2,D7
                movea.l text_start_adr(PC),A6
                adda.l  D7,A6
                move.l  A6,text_start_adr
                bra.s   paint_text_loop

paint_now:      bsr.s   paint_one_letter
                bra.s   paint_text_loop

paint_text_out:
                movem.l (SP)+,D3-A0/A3-A5

                rts

text_start_adr: DC.L 0
text_height:    DC.W 0

;---------------

; d7 = asciicode
; a6 = screenadresse

; register: a3-a6, d3-d7

paint_one_letter:
                movea.l A6,A3

		cmpi.b	#$60,d7
		blt.s	pol_big_letter
		subi.b	#$20,d7
pol_big_letter

		cmpi.w	#320,true_offi+2
		beq.s	pol_font4x8

                lea     font,A5
                andi.w  #$00FF,D7
                subi.b  #"!",D7
                bmi.s   its_space

                lsl.w   #7,D7
                adda.w  D7,A5

		move.w	true_offi+2,d7
		subi.w	#16,d7

                moveq   #7,D4
fn1:            moveq   #7,D5
fn2:            move.w  (A5)+,D6
                beq     pol_no_paint
                move.w  D6,(A6)
pol_no_paint    addq.l  #2,A6
                dbra    D5,fn2
		adda.w	d7,a6
                dbra    D4,fn1
its_space
                adda.w  #16,A3
                movea.l A3,A6

                rts

;---

pol_font4x8
		lea	font4x8,a5
		andi.w	#$ff,d7
		subi.b	#"!",d7
		bmi.s	pol_space4x8

		lsl.w	#6,d7
		adda.w	d7,a5

		moveq	#7,d4
fn1_4x8_loop	moveq	#3,d5
fn2_4x8_loop	move.w	(a5)+,d6
		beq.s	pol_no_pnt_4x8
		move.w	d6,(a6)
pol_no_pnt_4x8	addq.l	#2,a6
		dbra	d5,fn2_4x8_loop
		lea	320-4*2(a6),a6
		dbra	d4,fn1_4x8_loop
pol_space4x8
		adda.w	#8,a3
		movea.l	a3,a6

		rts

;---------------

;* a0 = textpointer
;* a6 = screenadresse
;* text_height

paint_menutext
                movem.l D3-A0/A3-A6,-(SP)
                move.l  A6,text_start_adr

paint_menutext_loop:
                move.b  (A0)+,D7
                beq.s   paint_menutext_out
                cmpi.b  #13,D7
                bne.s   paint_menu_now

                move.w  text_height(PC),D7
                mulu    true_offi+2,D7
                movea.l text_start_adr(PC),A6
                adda.l  D7,A6
                move.l  A6,text_start_adr
                bra.s   paint_menutext_loop

paint_menu_now	bsr.s   paint_one_menuletter
                bra.s   paint_menutext_loop

paint_menutext_out:
                movem.l (SP)+,D3-A0/A3-A6

                rts

;---------------

; d7 = asciicode
; a6 = screenadresse

; register: a3-a6, d3-d7

paint_one_menuletter:

                movea.l A6,A3

                lea     menufont+128,A5
                andi.w  #$00FF,D7
                cmpi.w  #"0",D7
                blt	its_menuspace
		cmpi.w	#"9"+1,d7
		blt	pmf_number
		cmpi.w	#"A"+36,d7
		blt.s	pmf_letter_or_number
		subi.w	#"A"+36,d7
		mulu	#16*2,d7
		addi.w	#36*11*2,d7

                adda.w  D7,A5

		tst.w	double_scan
		beq.s	pmfola_normal

                moveq   #7,D4
fnm21a          moveq   #15,D5
fnm22a          move.w  (A5)+,D6
                beq     pola_mno_paint2
                move.w  D6,(A6)
pola_mno_paint2
		addq.l  #2,A6
                dbra    D5,fnm22a
                lea     640-16*2(A6),A6
                lea     menufont_offi*2-16*2(A5),A5
                dbra    D4,fnm21a

                adda.w  #32,A3
                movea.l A3,A6
                rts


pmfola_normal
                moveq   #15,D4
fnm1a           moveq   #15,D5
fnm2a           move.w  (A5)+,D6
                beq     pola_mno_paint
                move.w  D6,(A6)
pola_mno_paint    
		addq.l  #2,A6
                dbra    D5,fnm2a
                lea     640-16*2(A6),A6
                lea     menufont_offi-16*2(A5),A5
                dbra    D4,fnm1a

                adda.w  #32,A3
                movea.l A3,A6
                rts


pmf_letter_or_number

		cmpi.w	#"A",d7
		blt.s	pmf_number
		subi.w	#"A",d7
		mulu	#11*2,d7
		bra	its_menunormal
pmf_number
		subi.w	#"0",d7
		mulu	#11*2,d7
		addi.w	#26*11*2,d7


its_menunormal
                adda.w  D7,A5

		tst.w	double_scan
		beq.s	pmfol_normal

                moveq   #8,D4
fnm21           moveq   #10,D5
fnm22           move.w  (A5)+,D6
                beq     pol_mno_paint2
                move.w  D6,(A6)
pol_mno_paint2
		addq.l  #2,A6
                dbra    D5,fnm22
                lea     640-11*2(A6),A6
                lea     menufont_offi*2-11*2(A5),A5
                dbra    D4,fnm21

                adda.w  #20,A3
                movea.l A3,A6
                rts


pmfol_normal
                moveq   #17,D4
fnm1            moveq   #10,D5
fnm2            move.w  (A5)+,D6
                beq     pol_mno_paint
                move.w  D6,(A6)
pol_mno_paint    
		addq.l  #2,A6
                dbra    D5,fnm2
                lea     640-11*2(A6),A6
                lea     menufont_offi-11*2(A5),A5
                dbra    D4,fnm1

                adda.w  #20,A3
                movea.l A3,A6
                rts

;---------------

its_menuspace:
                adda.w  #20,A3
                movea.l A3,A6

                rts

;---------------------------------------

; a0 = textpointer
; a6 = screenadresse

paint_text_no_mask:

                movem.l D3-A0/A3-A6,-(SP)
                move.l  A6,text_start_adr

paint_noma_loop:
                move.b  (A0)+,D7
                beq.s   paint_noma_out
                cmpi.b  #13,D7
                bne.s   paint_noma_now

                move.w  text_height(PC),D7
                mulu    true_offi+2,D7
                movea.l text_start_adr(PC),A6
                adda.l  D7,A6
                move.l  A6,text_start_adr
                bra.s   paint_noma_loop

paint_noma_now: bsr.s   paint_one_letter_nm
                bra.s   paint_noma_loop

paint_noma_out:
                movem.l (SP)+,D3-A0/A3-A6

                rts

;---------------

; d7 = asciicode
; a6 = screenadresse

; register: a3-a6, d3-d7

paint_one_letter_nm:

                movea.l A6,A3

                lea     font,A5
                andi.w  #$00FF,D7
                subi.b  #"!",D7
                bmi.s   its_space_nm

                lsl.w   #7,D7
                adda.w  D7,A5

                moveq   #7,D4
fn1_nm:
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+

                lea     640-8*2(A6),A6
                dbra    D4,fn1_nm

                adda.w  #16,A3
                movea.l A3,A6

                rts

;---------------

its_space_nm:
                moveq   #7,D4
p_space_nm:
                clr.l   (A6)+
                clr.l   (A6)+
                clr.l   (A6)+
                clr.l   (A6)+

                lea     640-8*2(A6),A6

                dbra    D4,p_space_nm

                adda.w  #16,A3
                movea.l A3,A6

                rts


;**************************************

who_waited:     
                tst.w   dsp_too_lame
                bne.s   who_make

                rts

who_make:       movea.l screen_1,A0

                movea.l play_dat_ptr,A6
                move.w  pd_heigth_last(A6),D0
                move.w  #200,D1
                sub.w   D0,D1
                lsr.w   #1,D1
                mulu    true_offi+2,D1
                adda.l  D1,A0

                move.l  #$F0E0F0E0,D7
                adda.l  #640*4+316,A0

                move.l  D7,(A0)
                move.l  D7,true(A0)
                move.l  D7,2*true(A0)
                move.l  D7,3*true(A0)
                move.l  D7,4(A0)
                move.l  D7,true+4(A0)
                move.l  D7,2*true+4(A0)
                move.l  D7,3*true+4(A0)
                rts

dsp_too_lame:   DC.W 0


;**************************************
;* paint_deci / paint_hex
;**************************************

		include	"include\deci_hex.s"


;**************************************
;* test_action_fld
;**************************************

		include	"include\t_field.s"


;**************************************
;* move_it
;**************************************

		include	"include\move_it.s"


;**************************************
;* test_position
;**************************************

		include	"include\test_pos.s"


;**************************************
;* keys_stuff
;**************************************


keys_stuff:     
                bsr.s   internal_speaker

                rts

;----

internal_speaker:
                lea     keytable,A1
                tst.b   $0072(A1)
                beq.s   no_speaker_on_off

                clr.b   $0072(A1)

                move.b  #14,$FFFF8800.w
                move.b  $FFFF8800.w,D0
                bchg    #6,D0
                move.b  D0,$FFFF8802.w

no_speaker_on_off:

                tst.b   $004A(A1)
                beq.s   no_speaker_minus

		clr.b	$4a(a1)
                move.w  $FFFF893A.w,D0
                cmpi.w  #$0ff0,D0
                beq.s   no_speaker_minus
                addi.w  #$0110,D0
                move.w  D0,$FFFF893A.w

no_speaker_minus:
                tst.b   $004E(A1)
                beq.s   no_speaker_plus

		clr.b	$4e(a1)
                move.w  $FFFF893A.w,D0
		tst.w	d0
                beq.s   no_speaker_plus
                subi.w  #$0110,D0
                move.w  D0,$FFFF893A.w

no_speaker_plus:

                rts


;**************************************
;* action_keys
;**************************************

		include	"include\act_keys.s"




;**************************************
;* key_hit
;**************************************

		include	"include\key_hit2.s"


;**************************************
;* loesch- und kopierroutinen
;**************************************

; bildschirm 320x200 loeschen,
; uebergabe screenadresse in a0

clear_black
		adda.l	#200*true,a0
		move.w	#614,d0
		moveq	#0,d1
		move.l	d1,d2
		move.l	d2,d3
		move.l	d3,d4
		move.l	d4,d5
		move.l	d5,d6
		move.l	d6,d7
		suba.l	a1,a1
		suba.l	a2,a2
		suba.l	a3,a3
		suba.l	a4,a4
		suba.l	a5,a5
		suba.l	a6,a6

cb_200_loop
		movem.l	d1-d7/a1-a6,-(a0)
		movem.l	d1-d7/a1-a6,-(a0)
		movem.l	d1-d7/a1-a6,-(a0)
		movem.l	d1-d7/a1-a6,-(a0)
		dbra	d0,cb_200_loop

		movem.l	d1-d7/a1-a6,-(a0)
		movem.l	d1-d7,-(a0)

		rts

;---------------

clear_black_240:
                adda.l  #240*true,A0
                move.w  #737,D0
                moveq	#0,d1
                move.l  D1,D2
                move.l  D1,D3
                move.l  D1,D4
                move.l  D1,D5
                move.l  D1,D6
                move.l  D1,D7
                movea.l D1,A1

                movea.l D1,A2
                movea.l D1,A3
                movea.l D1,A4
                movea.l D1,A5
                movea.l D1,A6
clear_11:
                movem.l D1-D7/A1-A6,-(A0)
                movem.l D1-D7/A1-A6,-(A0)
                movem.l D1-D7/A1-A6,-(A0)
                movem.l D1-D7/A1-A6,-(A0)
                dbra    D0,clear_11

                movem.l D1-D7/A1-A6,-(A0)
                movem.l D1-D7/A1-A4,-(A0)
                rts

;---------------

clear_it_flag:  DC.W 0

;---

clear_if_nessec

                move.w  clear_it_flag(PC),D0
                bne.s   clear_if_now

                rts

clear_if_now:
                cmpi.w  #1,D0
                beq.s   first_clear

                bsr     clear_background
                clr.w   clear_it_flag

                rts

first_clear:
                bsr     clear_background
                move.w  #2,clear_it_flag

                rts

;---------------

copy_phys2log:  

                movea.l screen_2,A0
                movea.l screen_1,A1

                move.w  #239,D0
copy_p2l_loop1: move.w  #79,D1
copy_p2l_loop2: move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D1,copy_p2l_loop2
                dbra    D0,copy_p2l_loop1

                rts


;**************************************
;* gfx_routs
;**************************************

		include	"include\gfxrouts.s"


;**************************************
;* karte
;**************************************

;**************************************


make_play_now

; d5/a1-a2
; pf_buf_zeiger  : zeiger auf buffer


		subq.w	#1,d5
		movea.l	pf_buf_zeiger(pc),a0
mploop
		move.w	d5,-(sp)

		move.w	2(a1),d5
		move.w	6(a1),d6
		movem.l	(a2,d5.w*4),d0/d5
		movem.l	(a2,d6.w*4),d2/d6		

		movem.l	karte_x_offi,d1/d3
		sub.l	d1,d0
		sub.l	d3,d5
		sub.l	d1,d2
		sub.l	d3,d6

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d5
		divs	d4,d2
		divs	d4,d6

		moveq	#199-100,d1
		move.w	d1,d3
		sub.w	d5,d1
		sub.w	d6,d3

		move.l	#320*2,d4

		move.w	12+2(a1),d5
		andi.w	#%0000110000000000,d5
		cmpi.w	#%0000110000000000,d5
		beq.s	mpl_11
		cmpi.w	#%0000100000000000,d5
		beq.s	mpl_10
		cmpi.w	#%0000010000000000,d5
		beq.s	mpl_01

	; alte farben

;mpl_00		move.w	#%1100001000000000,d7
;		bra.s	mploop_go_on
;mpl_10		move.w	#%0100001000000000,d7
;		bra.s	mploop_go_on
;mpl_01		move.w	#%0100001100000000,d7
;		bra.s	mploop_go_on
;mpl_11		move.w	#%1111100000000000,d7	; mit boden und decke

	; neue farben ...

mpl_00		move.w	#%0110001100001100,d7
		bra.s	mploop_go_on
mpl_10		move.w	#%1000010000010000,d7
		bra.s	mploop_go_on
mpl_01		move.w	#%1010010100010100,d7
		bra.s	mploop_go_on
mpl_11		move.w	#%1100011000011000,d7	; mit boden und decke

mploop_go_on
		addi.w	#160,d0
		addi.w	#160,d2
		bsr	linie

		lea	20(a1),a1
		move.w	(sp)+,d5
		dbra	d5,mploop

		rts


;---------------

; d5,a1-a2

make_play_now_color

		subq.w	#1,d5
		movea.l	pf_buf_zeiger(pc),a0

mploop_color
		move.w	d5,-(sp)

		move.w	2(a1),d5
		move.w	6(a1),d6
		movem.l	(a2,d5.w*4),d0/d5
		movem.l	(a2,d6.w*4),d2/d6		

		movem.l	karte_x_offi,d1/d3
		sub.l	d1,d0
		sub.l	d3,d5
		sub.l	d1,d2
		sub.l	d3,d6

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d5
		divs	d4,d2
		divs	d4,d6

		moveq	#199-100,d1
		move.w	d1,d3
		sub.w	d5,d1
		sub.w	d6,d3

		move.l	#320*2,d4
		move.w	pf_now_color(pc),d7

		addi.w	#160,d0
		addi.w	#160,d2

		bsr	linie

		lea	20(a1),a1
		move.w	(sp)+,d5
		dbra	d5,mploop_color

		rts


;---------------

linie_in_playcoord

; d0-d3: anfangs- und endpunkt
;    d7: linienfarbe

		movem.l	karte_x_offi,d5-d6
		sub.l	d5,d0
		sub.l	d5,d2
		sub.l	d6,d1
		sub.l	d6,d3

		move.w	karten_zoom,d4
		divs	d4,d0
		divs	d4,d1
		divs	d4,d2
		divs	d4,d3

		moveq	#199-100,d4
		move.w	d4,d5
		sub.w	d1,d4
		sub.w	d3,d5

		move.w	d4,d1
		move.w	d5,d3

		addi.w	#160,d0
		addi.w	#160,d2

		move.l	#320*2,d4
		movea.l	screen_1,a0
		bsr	linie

		rts


;---------------

; rueckgabe in d0/d1: hardwaremaessige aufloesung
; gemaess double_scan, cinemascope und vga_monitor

get_resolution

		move.w	double_scan,d2
		move.w	cinemascope,d3
		tst.w	vga_monitor
		bne.s	gr_vga

	; rgb-monitor

gr_rgb		tst.w	d2
		beq.s	grr_no_double
		move.w	#120,d1
		tst.w	d3
		beq.s	grr_320x120
		move.w	#256,d0
		rts
grr_320x120	move.w	#320,d0
		rts

grr_no_double	tst.w	d3
		beq.s	grr_320x240
		move.w	#256,d0
		move.w	#200,d1
		rts
grr_320x240	move.w	#320,d0
		move.w	#240,d1
		rts

	; vga-monitor

gr_vga		tst.w	d3
		beq.s	grv_320x240
		move.w	#160,d0
		move.w	#200,d1
		rts
grv_320x240	move.w	#320,d0
		move.w	#240,d1
		rts

;---------------

; installiert die richtige bildschirmroutine
; entsprechend double_scan und cinemascope

install_si_routine

		tst.w	vga_monitor
		bne.s	isr_vga

		tst.w	double_scan
		beq.s	isr_no_double

		tst.w	cinemascope
		beq.s	isr_320x120

		move.l	#si_256x120,screen_init_rout_ptr
		rts

isr_320x120
		move.l	#si_320x120,screen_init_rout_ptr
		rts

isr_no_double
		tst.w	cinemascope
		beq.s	isr_320x240

		move.l	#si_256x200,screen_init_rout_ptr
		rts

isr_320x240	
		tst.w	wide_screen
		beq.s	isr_320x240_nowide

		move.l	#si_320x240wide,screen_init_rout_ptr
		rts

isr_320x240_nowide
		move.l	#si_320x240,screen_init_rout_ptr
		rts

isr_vga
		tst.w	cinemascope
		beq.s	isr_320x240vga

		move.l	#si_160x200vga,screen_init_rout_ptr
		rts

isr_320x240vga
		move.l	#si_320x240vga,screen_init_rout_ptr
		rts


;---------------

pf_pts_zeiger:  DC.L 0
pf_line_zeiger: DC.L 0
pf_line_anz:    DC.W 0
pf_buf_zeiger:  DC.L 0
pf_now_color:   DC.W 0
pf_now_bits:    DC.W 0

;---------------
             
karte:       

                tst.b   keytable+$000F
                beq	karte_inline

		tst.w	cameraview_flag
		bne	karte_inline
		tst.w	menue_flag
		bne	karte_inline

		not.w	karte_flag
                beq.s   karte_ausgesch

		; karte ist jetzt eingeschaltet worden

		clr.l	mes_buf1
		clr.l	mes_buf2

		move.w	double_scan,ds_vor_karte
		move.w	cinemascope,cine_vor_karte
		move.l	true_offi,true_vor_karte

		move.l	#640,true_offi
		clr.w	double_scan
		clr.w	cinemascope
                move.w  #2,dont_change_scr
		move.l	#si_320x240,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	kact_no_vga
		move.l	#si_320x240vga,screen_init_rout_ptr
kact_no_vga	bra.s   karte_modus_ok

karte_ausgesch:
		; karte ist jetzt ausgeschaltet worden

		clr.l	mes_buf1
		clr.l	mes_buf2
	
		move.w	ds_vor_karte,double_scan
		move.w	cine_vor_karte,cinemascope
		move.l	true_vor_karte,true_offi
		bsr	install_si_routine

		move.w	#2,dont_change_scr

karte_modus_ok:

                move.w  #2,clear_it_flag
                clr.b   keytable+$000F
		movea.l	play_dat_ptr,a6
		move.w	#1,pd_things_flag(a6)


karte_inline:
                tst.w   karte_flag
                beq	karte_inline_out
		tst.w	cameraview_flag
		bne	karte_inline_out
		tst.w	terminal_flag
		bne	karte_inline_out

                movea.l screen_1,A0
                bsr	clear_background

                tst.b   keytable+$0043
                beq.s   k_no_smaller
		move.w	vbl_time,d0
		sub.w	d0,karten_zoom
k_no_smaller:
                tst.b   keytable+$0044
                beq.s   k_no_greater
		move.w	vbl_time,d0
		add.w	d0,karten_zoom
k_no_greater:
                move.w  karten_zoom,D0
                cmpi.w  #2,D0
                bgt.s   z_not_neg
                moveq   #2,D0
z_not_neg:
                cmpi.w  #256,D0
                blt.s   z_not_high
                move.w  #256,D0
z_not_high:
                move.w  D0,karten_zoom


                tst.b   keytable+$0021
                beq.s   k_no_follow

                nop

k_no_follow:

	; follow ggf. ein- oder ausschalten

		lea	keytable,a1
		tst.b	$6b(a1)
		beq.s	kf_no_change
		clr.b	$6b(a1)
		tst.w	karte_follow
		beq.s	kf_turn_on

		lea	sm_follow_on,a0
		jsr	install_message
		clr.w	karte_follow
		bra.s	kf_no_change

kf_turn_on
		lea	sm_follow_off,a0
		jsr	install_message
		move.w	#1,karte_follow
kf_no_change

	; jetzt die mittelposition entspr. karte_follow bestimmen

		tst.w	karte_follow
		beq.s	kf_no_follow
kf_follow
		moveq	#0,d0
		moveq	#0,d1

		tst.b	$6a(a1)
		beq.s	kf_no_6a
;		clr.b	$6a(a1)
		moveq	#-8,d0		
kf_no_6a
		tst.b	$6c(a1)
		beq.s	kf_no_6c
;		clr.b	$6c(a1)
		moveq	#8,d0
kf_no_6c
		tst.b	$68(a1)
		beq.s	kf_no_68
;		clr.b	$68(a1)
		moveq	#8,d1		
kf_no_68
		tst.b	$6e(a1)
		beq.s	kf_no_6e
;		clr.b	$6e(a1)
		moveq	#-8,d1
kf_no_6e
		move.w	vbl_time,d2
		muls	d2,d0
		muls	d2,d1
		lsl.l	#3,d0
		lsl.l	#3,d1
		add.l	d0,karte_x_offi
		add.l	d1,karte_y_offi
		bra.s	kf_ok	

kf_no_follow
		movea.l	play_dat_ptr,a6
		movem.l	pd_sx(a6),d0-d1
		movem.l	d0-d1,karte_x_offi
kf_ok


                bsr     karte_now

karte_inline_out:

                rts

;---------------

clear_background:

		tst.w	karte_flag
		bne.s	cb_no_mes_clear
		clr.l	mes_buf1
		clr.l	mes_buf2
cb_no_mes_clear

		tst.w	pl_console_mode
		beq.s	cb_no_console

		move.w	#5,pl_must_copy
cb_no_console

                lea     kartback_pic+128,A5
                movea.l screen_1,A6

                tst.w   double_scan
                beq.s   clear_background_now

                move.w  #31,D0
                bsr     clear_back2_lines
                move.w  #31,D0
                bsr     clear_back2_lines
                move.w  #31,D0
                bsr     clear_back2_lines
                move.w  #31,D0
                bsr     clear_back2_lines

                rts

clear_background_now:

                move.w  #63,D0
                bsr.s   clear_back_lines
                move.w  #63,D0
                bsr.s   clear_back_lines
                move.w  #63,D0
                bsr.s   clear_back_lines
                move.w  #7,D0
                bsr.s   clear_back_lines

                rts

;---

;* a5: kartback_pic
;* a6: screen_1
;* d0: anzahl lines

clear_back_lines:

		cmpi.l	#512,true_offi
		beq	clear_back_lines_512
		cmpi.l	#320,true_offi
		beq	clear_back_lines_320

		; version fuer true_offi 640 ohne double_scan
	
                lea     128(A6),A1
                lea     256(A6),A2
                lea     384(A6),A3
                lea     512(A6),A4
                movem.l A5,-(SP)

cbl_loop:

                movem.l (A5)+,D1-A0
                movem.l D1-A0,(A1)
                movem.l D1-A0,(A2)
                movem.l D1-A0,(A3)
                movem.l D1-A0,(A4)
                movem.l D1-A0,(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,32(A1)
                movem.l D1-A0,32(A2)
                movem.l D1-A0,32(A3)
                movem.l D1-A0,32(A4)
                movem.l D1-A0,32(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,64(A1)
                movem.l D1-A0,64(A2)
                movem.l D1-A0,64(A3)
                movem.l D1-A0,64(A4)
                movem.l D1-A0,64(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,96(A1)
                movem.l D1-A0,96(A2)
                movem.l D1-A0,96(A3)
                movem.l D1-A0,96(A4)
                movem.l D1-A0,96(A6)

                lea     640(A1),A1
                lea     640(A2),A2
                lea     640(A3),A3
                lea     640(A4),A4
                lea     640(A6),A6

                dbra    D0,cbl_loop

                movem.l (SP)+,A5
                rts

clear_back_lines_512

		; version fuer true_offi 512 ohne double_scan
	
                lea     128(A6),A1
                lea     256(A6),A2
                lea     384(A6),A3

                movem.l A5,-(SP)

cbl_loop512

                movem.l (A5)+,D1-A0
                movem.l D1-A0,(A1)
                movem.l D1-A0,(A2)
                movem.l D1-A0,(A3)
                movem.l D1-A0,(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,32(A1)
                movem.l D1-A0,32(A2)
                movem.l D1-A0,32(A3)
                movem.l D1-A0,32(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,64(A1)
                movem.l D1-A0,64(A2)
                movem.l D1-A0,64(A3)
                movem.l D1-A0,64(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,96(A1)
                movem.l D1-A0,96(A2)
                movem.l D1-A0,96(A3)
                movem.l D1-A0,96(A6)

                lea     512(A1),A1
                lea     512(A2),A2
                lea     512(A3),A3
                lea     512(A6),A6

                dbra    D0,cbl_loop512

                movem.l (SP)+,A5
                rts

clear_back_lines_320

		; version fuer true_offi 320 ohne double_scan
	
                lea     64(A6),A1
                lea     128(A6),A2
                lea     192(A6),A3
                lea     256(A6),A4

                movem.l A5,-(SP)

cbl_loop320

                movem.l (A5)+,D1-A0
                movem.w D1-A0,(A1)
                movem.w D1-A0,(A2)
                movem.w D1-A0,(A3)
                movem.w D1-A0,(A4)
                movem.w D1-A0,(A6)
                movem.l (A5)+,D1-A0
                movem.w D1-A0,16(A1)
                movem.w D1-A0,16(A2)
                movem.w D1-A0,16(A3)
                movem.w D1-A0,16(A4)
                movem.w D1-A0,16(A6)
                movem.l (A5)+,D1-A0
                movem.w D1-A0,32(A1)
                movem.w D1-A0,32(A2)
                movem.w D1-A0,32(A3)
                movem.w D1-A0,32(A4)
                movem.w D1-A0,32(A6)
                movem.l (A5)+,D1-A0
                movem.w D1-A0,48(A1)
                movem.w D1-A0,48(A2)
                movem.w D1-A0,48(A3)
                movem.w D1-A0,48(A4)
                movem.w D1-A0,48(A6)

                lea     320(A1),A1
                lea     320(A2),A2
                lea     320(A3),A3
                lea     320(A4),A4
                lea     320(A6),A6

                dbra    D0,cbl_loop320

                movem.l (SP)+,A5
                rts

;---

clear_back2_lines:

		cmpi.l	#512,true_offi
		beq	clear_back2_lines_512

                lea     128(A6),A1
                lea     256(A6),A2
                lea     384(A6),A3
                lea     512(A6),A4
                movem.l A5,-(SP)

cb2l_loop:

                movem.l (A5)+,D1-A0
                movem.l D1-A0,(A1)
                movem.l D1-A0,(A2)
                movem.l D1-A0,(A3)
                movem.l D1-A0,(A4)
                movem.l D1-A0,(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,32(A1)
                movem.l D1-A0,32(A2)
                movem.l D1-A0,32(A3)
                movem.l D1-A0,32(A4)
                movem.l D1-A0,32(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,64(A1)
                movem.l D1-A0,64(A2)
                movem.l D1-A0,64(A3)
                movem.l D1-A0,64(A4)
                movem.l D1-A0,64(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,96(A1)
                movem.l D1-A0,96(A2)
                movem.l D1-A0,96(A3)
                movem.l D1-A0,96(A4)
                movem.l D1-A0,96(A6)

                lea     128(A5),A5

                lea     640(A1),A1
                lea     640(A2),A2
                lea     640(A3),A3
                lea     640(A4),A4
                lea     640(A6),A6

                dbra    D0,cb2l_loop

                movem.l (SP)+,A5
                rts

clear_back2_lines_512

		; version fuer true_offi 512 mit double_scan
	
                lea     128(A6),A1
                lea     256(A6),A2
                lea     384(A6),A3

                movem.l A5,-(SP)

cb2l_loop512

                movem.l (A5)+,D1-A0
                movem.l D1-A0,(A1)
                movem.l D1-A0,(A2)
                movem.l D1-A0,(A3)
                movem.l D1-A0,(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,32(A1)
                movem.l D1-A0,32(A2)
                movem.l D1-A0,32(A3)
                movem.l D1-A0,32(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,64(A1)
                movem.l D1-A0,64(A2)
                movem.l D1-A0,64(A3)
                movem.l D1-A0,64(A6)
                movem.l (A5)+,D1-A0
                movem.l D1-A0,96(A1)
                movem.l D1-A0,96(A2)
                movem.l D1-A0,96(A3)
                movem.l D1-A0,96(A6)

		lea	128(a5),a5

                lea     512(A1),A1
                lea     512(A2),A2
                lea     512(A3),A3
                lea     512(A6),A6

                dbra    D0,cb2l_loop512

                movem.l (SP)+,A5
                rts

;**************************************
;* routinen zum ein- und ausblenden
;**************************************

		include	"include\blenden.s"


;**************************************
;* karte_now
;**************************************

karte_now:

	; zeichnen aller waende

		movea.l	big_sector_ptr,a2
		adda.l	#lev_sec_start,a2

		moveq	#0,d7
		move.l	screen_1,pf_buf_zeiger

kl_1
		move.l	(a2,d7.w*4),d0
		bmi.s	k_walls_out		; letzten sektor erreicht

	; sektor zeichnen, wenn th_plan aktiviert ist

		lea	pl_leiste_act,a3
		move.w	#th_plan,d1
		tst.w	-2(a3,d1.w*2)
		bne.s	kw_zeichnen

	; sektor nicht zeichnen, wenn th_litteplan nicht aktiviert ist 

		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kw_invissible

	; sektor nicht zeichnen, wenn er noch nicht betreten wurde

		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		btst	#0,(a3,d7.w)
		beq.s	kw_invissible

kw_zeichnen
		movem.l	d7/a2,-(sp)
		movea.l	d0,a3
		movea.l	sec_lines(a3),a1
		move.w	2(a1),d5		; anzahl linien
		addq.l	#4,a1
		movea.l	sec_points(a3),a2
		addq.l	#4,a2

		bsr	make_play_now

		movem.l	(sp)+,d7/a2
kw_invissible
		addq.w	#1,d7
		bra.s	kl_1

k_walls_out

;		bsr.s	karte_paint_things
;		bsr	karte_paint_schalter
		bsr	karte_paint_doors
		bsr	karte_paint_lifts
		bsr	karte_paint_trains
		bsr	karte_paint_monsters
		bsr	karte_paint_player

		rts


;---------------

karte_paint_trains:

		lea	pl_leiste_act,a1
		move.w	#th_trndetector,d0
		tst.w	-2(a1,d0.w*2)
		beq	kpt_out

                movea.l big_sector_ptr,A0
                movea.l lev_trains(A0),A0
                movea.l trn_data(A0),A2           ; lvx_trains_data

		move.w	max_trains,d7
		subq.w	#1,d7
		bmi.s	kpt_out
k_trains_loop:
                moveq	#4,d5
		lea	8*4(a2),a1

                movem.l D7/A2,-(SP)

                move.w  #%0110010010000111,pf_now_color
                bsr     make_play_now_color

                movem.l (SP)+,D7/A2

                lea     td_data_length(A2),A2
                dbra    D7,k_trains_loop

kpt_out
                rts

;---------------

karte_paint_things:

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

                moveq   #0,D7
k_sec_things_loop:
                move.l  0(A2,D7.w*4),D0
                bpl.s   k_sec_things_ok

                rts

k_sec_things_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq	no_things_in_sec

                movea.l D0,A3
                move.l  sec_things(A3),D0
                beq.s   no_things_in_sec

                movea.l D0,A3

things_in_sec_loop:
                move.l  (A3)+,D0
                bmi.s   no_things_in_sec
                movea.l D0,A0
                move.w  thing_type(A0),D0
                bmi.s   things_in_sec_loop

                movem.l D7/A2-A3,-(SP)

;                lea     things_colors(PC),A4
;                lsl.w   #1,D0
;                move.w  0(A4,D0.w),D7
                move.w  #%0100010000000100,D7

                lea     things_pts_ptr,A4
                move.l  thing_line(A0),D0
                move.l  thing_line+4(A0),D1

                move.l  D0,D2
                move.l  D1,D3
                move.w  thing_breite(A0),D4
                ext.l   D4

                move.l  D1,4(A4)                  ; y1
                move.l  D1,20(A4)                 ; y3
                move.l  D1,36(A4)
                move.l  D0,8(A4)
                move.l  D0,24(A4)
                add.l   D4,D0
                move.l  D0,16(A4)
                sub.l   D4,D2
                move.l  D2,(A4)
                move.l  D2,32(A4)
                add.l   D4,D1
                move.l  D1,12(A4)
                sub.l   D4,D3
                move.l  D3,28(A4)

                moveq   #3,D6
k_paint_thing_l:
                movem.l D6/A4,-(SP)

                move.l  (A4)+,D0
                move.l  (A4)+,D1
                move.l  (A4)+,D2
                move.l  (A4)+,D3

                bsr     linie_in_playcoord

                movem.l (SP)+,D6/A4
                addq.l  #8,A4
                dbra    D6,k_paint_thing_l

                movem.l (SP)+,D7/A2-A3

                bra.s   things_in_sec_loop

no_things_in_sec:
                addq.w  #1,D7
                bra     k_sec_things_loop


;---------------

karte_paint_schalter:

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

		moveq	#0,d7
k_sec_sch_loop:
                move.l  (A2,d7.w*4),D0
                bpl.s   k_sec_sch_ok

                rts

k_sec_sch_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_sch_in_sec

                movea.l D0,A3
                move.l  sec_schalter(A3),D0
                beq.s   no_sch_in_sec

                movea.l D0,A3

sch_in_sec_loop:
                move.l  (A3)+,D0
                bmi.s   no_sch_in_sec
                movea.l D0,A0
                move.w  thing_type(A0),D0

;                lea     schalter_colors(PC),A4
;                lsl.w   #1,D0
;                move.w  0(A4,D0.w),D7
                move.w  #%0100001000010100,D7

                lea     thing_line(A0),A4
                movem.l (A4),D0-D3

                movem.l A2-A3,-(SP)
                bsr     linie_in_playcoord
                movem.l (SP)+,A2-A3

                bra.s   sch_in_sec_loop

no_sch_in_sec:
		addq.w	#1,d7
                bra.s   k_sec_sch_loop


;---------------

; update 27/09/96

karte_paint_doors

		lea	pl_leiste_act,a3
		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kpd_out

		movea.l	big_sector_ptr,a2
		adda.l	#lev_sec_start,a2

		moveq	#0,d7

k_sec_doors_loop

		move.l	(a2,d7.w*4),d0
		bpl.s	k_sec_doors_ok

kpd_out
		rts

;---

k_sec_doors_ok

		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_doors_in_sec

		movea.l	d0,a3
		move.l	sec_doors(a3),d0
		beq.s	no_doors_in_sec

		movea.l	d0,a3

doors_in_sec_loop

		move.l	(a3)+,d0
		bmi.s	no_doors_in_sec

		movem.l	d7/a2-a3,-(sp)

		movea.l	d0,a2
		move.w	door_need_thing(a2),d7
		move.w	#%0111101111101111,d0
		cmpi.w	#th_red_key,d7
		bne.s	disl_no_red
		move.w	#%1111100000000000,d0
		bra.s	disl_now
disl_no_red	cmpi.w	#th_green_key,d7
		bne.s	disl_no_green
		move.w	#%0000011111100000,d0
		bra.s	disl_now
disl_no_green	cmpi.w	#th_blue_key,d7
		bne.s	disl_no_blue
		move.w	#%0000000111111111,d0
		bra.s	disl_now
disl_no_blue	cmpi.w	#th_yellow_key,d7
		bne.s	disl_now
		move.w	#%1111111111100000,d0

disl_now
		moveq	#4,d5
		lea	8*4(a2),a1

		move.w	d0,pf_now_color
		bsr	make_play_now_color
		movem.l	(sp)+,d7/a2-a3
		bra.s	doors_in_sec_loop

no_doors_in_sec
		addq.w	#1,d7
		bra.s	k_sec_doors_loop


;---------------

karte_paint_lifts:

		lea	pl_leiste_act,a3
		move.w	#th_littleplan,d1
		tst.w	-2(a3,d1.w*2)
		beq.s	kpl_out

                movea.l big_sector_ptr,A2
                adda.l  #lev_sec_start,A2

                moveq   #0,D7

k_sec_lifts_loop:

                move.l  0(A2,D7.w*4),D0
                bpl.s   k_sec_lifts_ok
kpl_out
                rts

;---

k_sec_lifts_ok:
		movea.l	big_sector_ptr,a3
		movea.l	lev_init_data(a3),a3
		movea.l	init_vissec_ptr(a3),a3
		tst.b	(a3,d7.w)
		beq.s	no_lifts_in_sec

                movea.l D0,A3
                move.l  sec_lift(A3),D0
                beq.s   no_lifts_in_sec

		movem.l	d7/a2-a3,-(sp)
                movea.l D0,A2

                moveq  	#4,d5
		lea	8*4(a2),a1

		move.w	#%0111101111101111,pf_now_color
                bsr     make_play_now_color

                movem.l (SP)+,D7/A2-A3

no_lifts_in_sec:
                addq.w  #1,D7
                bra.s   k_sec_lifts_loop


;**************************************
;* karte_paint_monsters (17/10/97)
;**************************************

karte_paint_monsters

		lea	pl_leiste_act,a1
		move.w	#th_mondetector,d0
		tst.w	-2(a1,d0.w*2)
		beq.s	kpm_out

		move.w	mon_buf2_anz,d7
		bmi	kpm_out

		movea.l	mon_buf2_ptr,a1
kpm_loop
		movea.l	(a1)+,a0

		movem.l	d7/a1,-(sp)
                lea     figur_data_buf,A1
                move.l  mon_line(A0),(A1)+
                move.l  mon_line+4(A0),(A1)+
                moveq   #0,D0
                move.b  mon_line+13(A0),D0
                move.l  D0,(A1)+
                move.w  #karte_fig_einh,(A1)+
		move.w	#%0111101111101111,d0
		tst.w	mon_a_shoot(a0)
		beq.s	kpml_no_shoot
		move.w	#%0000001111101111,d0
kpml_no_shoot	tst.w	mon_a_died(a0)
		beq.s	kpml_skip
		move.w	#%0111100000000000,d0
kpml_skip	move.w	d0,(a1)+		; farbe

                bsr.s   karte_paint_figur

                movem.l	(sp)+,d7/a1
		dbra	d7,kpm_loop

kpm_out
		rts

;-----------------------

;* zeichnet die spielerposition in die karte ein
;* farbe: weiss
;* form: dreieck

karte_paint_player:

                lea     figur_data_buf,A0

                movea.l play_dat_ptr,A6
                move.l  pd_sx(A6),(A0)+
                move.l  pd_sy(A6),(A0)+
                move.l  pd_alpha(A6),(A0)+
                move.w  #karte_fig_einh,(A0)+
                move.w  #$FFFF,(A0)+              ; farbe

                bsr.s   karte_paint_figur

                rts

;-----------------------

karte_paint_figur:

                lea     figur_data_buf,A6
                move.l  (A6),D6                   ; sx
                move.l  4(A6),D7                  ; sy
                lea     karte_player(PC),A4
                lea     sinus_256_tab,A5

                move.w  12(A6),D2                 ; karte_fig_einheit
                moveq   #14,D3
                move.l  8(A6),D0                  ; alpha

                bsr.s   karte_player_point

                move.l  8(A6),D0
                addi.w  #$0070,D0
                bsr.s   karte_player_point

                move.l  8(A6),D0
                addi.w  #$0090,D0
                bsr.s   karte_player_point

                lea     karte_player(PC),A4
                move.l  (A4),24(A4)
                move.l  4(A4),28(A4)

                moveq   #2,D1
karte_pp_loop:
                movem.l D1/A4,-(SP)
                move.l  (A4)+,D0
                move.l  (A4)+,D1
                move.l  (A4)+,D2
                move.l  (A4)+,D3
                move.w  14(a6),d7		; farbe
                bsr     linie_in_playcoord
                movem.l (SP)+,D1/A4
                addq.l  #8,A4

                dbra    D1,karte_pp_loop

                rts

;----

karte_player_point:

;* d0: winkel
;* d2: #karte_fig_einh
;* d3: #14
;* d6: pd_sx
;* d7: pd_sy
;* a5: sinus_256_tab
;* a4: karte_player

                move.w  #$0040,D1
                sub.w   D0,D1
                move.w  D1,D0

                lsl.w   #1,D0
                andi.w  #$01FF,D0
                move.w  0(A5,D0.w),D4             ; sinus
                addi.w  #$0080,D0
                andi.w  #$01FF,D0
                move.w  0(A5,D0.w),D5             ; cosinus

                muls    D2,D4
                muls    D2,D5
                asr.l   D3,D4
                asr.l   D3,D5
                add.l   D6,D4
                add.l   D7,D5

                move.l  D4,(A4)+
                move.l  D5,(A4)+

                rts


;**************************************
;* install_level & install_game
;**************************************

		include	"include\install.s"
	

;**************************************
;* stop_system
;**************************************

stop_system

	; -------------------
	; zuerst die richtige 
	; aufloesung setzen

		move.l	#640,true_offi
		clr.w	double_scan
		clr.w	cinemascope
                move.w  #2,dont_change_scr
		move.l	#si_320x200,screen_init_rout_ptr
		tst.w	vga_monitor
		beq.s	ss_no_vga
		move.l	#si_320x200vga,screen_init_rout_ptr
ss_no_vga

	; -------------------
	; hintergrundbild
	; einladen in logischen
	; bildschirm

		clr.w	-(sp)
		pea	syserror_pic
		move.w	#61,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,d7

		movea.l	screen_1,a0
		suba.w	#128,a0
		move.l	a0,-(sp)
		move.l	#128128,-(sp)
		move.w	d7,-(sp)	
		move.w	#63,-(sp)
		trap	#1
		lea	12(sp),sp
		
		move.w	d7,-(sp)	
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp

	; -------------------
	; logischen bildschirm
	; zur anzeige bringen

		bsr	vsync
		bsr	swap_me
		bsr	vsync
		bsr	swap_me
		bsr	vsync
		bsr	swap_me
		clr.w	clear_it_flag

	; -------------------
	; fehlermeldung anzeigen

		move.w	sst_code,d0
		bmi.s	ss_no_code
		beq.s	ss_no_code
		cmp.w	sst_code_anz,d0
		bgt.s	ss_no_code
		lea	stop_system_txt,a0
		movea.l	-4(a0,d0.w*4),a0	; anfang text
		movea.l	screen_1(pc),a6
		adda.l	sst_position,a6
		bsr	paint_text
ss_no_code
		
		lea	sst_data,a5
		moveq	#2,d7
ss_txt_loop
		movea.l	screen_1(pc),a6
		adda.l	(a5)+,a6
		movea.l	(a5)+,a0
		movem.l	d7/a5,-(sp)
		bsr	paint_text
		movem.l	(sp)+,d7/a5
		dbra	d7,ss_txt_loop

		
		movea.l	screen_1(pc),a6
		adda.l	-16(a5),a6
		adda.l	#6*8*2,a6
		movea.l	sst_message,a0
		bsr	paint_text


		bsr	vsync		
		bsr	swap_me


		ifeq	final
ss_wait
		tst.b	keytable+$39
		beq.s	ss_wait
		rts

		else

ss_endless_loop
		nop
		bra.s	ss_endless_loop

		endc


;**************************************
;* message_maker
;**************************************

message_maker
		move.l	mes_buf1,d0
		beq.s	mes_no_buf1

		movea.l	d0,a0
		movea.l	screen_1(pc),a6
		move.w	true_offi+2,d0
		move.w	d0,d1
		lsl.w	#2,d0
		add.w	d1,d0
		addi.w	#10,d0
		adda.w	d0,a6			; adda.l #640*5+10,a6
		bsr	paint_text

		lea	mes_time1,a0
		move.w	(a0),d0			; und zeit abziehen ...
		sub.w	vbl_time(pc),d0
		bpl.s	mes_time1_still
		moveq	#0,d0
		clr.l	-4(a0)			; clr.l mes_buf1
		move.w	#1,2(a0)		; move.w #1,mes_clearflag1
mes_time1_still	move.w	d0,(a0)


mes_no_buf1

	; jetzt dasselbe nochmal fuer die zweite zeile ...

		move.l	mes_buf2,d0
		beq.s	mes_no_buf2

		movea.l	d0,a0
		movea.l	screen_1(pc),a6
		move.w	true_offi+2,d0
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		addi.w	#10,d0
		adda.w	d0,a6			; adda.l #640*15+10,a6
		bsr	paint_text

		lea	mes_time2,a0
		move.w	(a0),d1
		sub.w	vbl_time(pc),d1
		bpl.s	mes_time2_still
		moveq	#0,d1
		clr.l	-4(a0)			; clr.l mes_buf2
		move.w	#1,2(a0)		; move.w #1,mes_clearflag2
mes_time2_still	move.w	d1,(a0)

mes_no_buf2
		rts

;---------------

; prinzip:
;  mes_clearflag = 0: kein loeschen erforderlich
;                = 1: loeschen erforderlich, setzen auf 2
;                = 2: loeschen erforderlich, setzen auf 0
; damit ist ein zweimaliges loeschen der bildschirme erreicht

message_clearer

		lea	mes_clearflag1,a0
		move.w	(a0),d0
		beq.s	mc_no_clear1

		clr.w	(a0)
		cmpi.w	#1,d0
		bne.s	mc_1_2
		move.w	#2,(a0)
mc_1_2		movea.l	screen_1(pc),a6
		bsr	mc_clear_back1

mc_no_clear1

		lea	mes_clearflag2,a0
		move.w	(a0),d0
		beq.s	mc_no_clear2

		clr.w	(a0)
		cmpi.w	#1,d0
		bne.s	mc_2_2
		move.w	#2,(a0)
mc_2_2		movea.l	screen_1(pc),a6
		bsr	mc_clear_back2

mc_no_clear2
		rts

;---------------

; setzt hintergrund fuer erste messagezeile

mc_clear_back1
		move.w	true_offi+2,d0
		move.w	d0,d1
		lsl.w	#2,d0
		add.w	d1,d0			; mulu #5,d0
		adda.w	d0,a6

		moveq	#7,d0			; 8 zeilen zu loeschen
		
		tst.w	double_scan
		beq.s	mccb1_now

		lea	kartback_pic+128+64*2*10,a5
		bsr	clear_back2_lines
		rts

mccb1_now
		lea	kartback_pic+128+64*2*5,a5
		bsr	clear_back_lines
		rts

;---------------

mc_clear_back2
		move.w	true_offi+2,d0
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0			; mulu #15,d0
		adda.w	d0,a6		

		moveq	#7,d0

		tst.w	double_scan
		beq.s	mccb2_now

		lea	kartback_pic+128+64*2*30,a5
		bsr	clear_back2_lines
		rts

mccb2_now
		lea	kartback_pic+128+64*2*15,a5
		bsr	clear_back_lines

		rts

;---------------

; a0: zeiger auf text
; sonst kein gebrauch von registern

install_message

	; ist die message schon vorhanden, dann raus ...

		cmpa.l	mes_buf1,a0
		bne.s	im_1
		rts
im_1		cmpa.l	mes_buf2,a0
		bne.s	im_2
		rts
im_2

		tst.l	mes_buf1
		bne.s	im_buf1_full

	; buffer 1 ist frei, also rein damit
	; und raus aus der routine ...

		move.l	a0,mes_buf1
		move.w	#message_time,mes_time1
		rts

im_buf1_full

	; versuchen wir doch den zweiten buffer

		tst.l	mes_buf2
		bne.s	im_buf2_full

	; buffer 2 ist frei, also rein damit ...

		move.l	a0,mes_buf2
		move.w	#message_time,mes_time2
		rts

im_buf2_full

	; beide buffer voll, also die aeltere message (1)
	; rausschmeissen, message 2 zur 1 machen und
	; die neue wird die 2 ...
	; flags fuer hintergrund loeschen setzen ...

		move.l	mes_buf2,mes_buf1
		move.w	mes_time2,mes_time1
		move.l	a0,mes_buf2
		move.w	#message_time,mes_time2
		move.w	#1,mes_clearflag1
		move.w	#1,mes_clearflag2
		rts


;**************************************
;* paint
;**************************************

paint
		movea.l	play_dat_ptr,a6
		movea.l	screen_1(pc),a1
		adda.w	pd_paint_x_offi(a6),a1
		move.w	ywindow_max,d1
		sub.w	pd_heigth_last(a6),d1
		lsr.w	#1,d1
		mulu	true_offi+2,d1
		adda.l	d1,a1
		move.w	xwindow_max,d1
		sub.w	pd_width_last(a6),d1
		lsr.w	#1,d1
		add.w	d1,d1
		adda.w	d1,a1
		move.l	a1,paint_links_oben


		tst.w	vga_monitor
		bne.s	paint_on_vga

		tst.w	cinemascope
		beq	paint640
		cmpi.w	#512,true_offi+2
		bne.s	paint_out
		bra	paint512

paint_on_vga
		tst.w	cinemascope
		beq	paint640
		cmpi.w	#320,true_offi+2
		bne.s	paint_out
		bra	paint320

paint_out
		rts

;---------------

paint_all
                bsr     paint
		bsr	paint_pistol
                bsr     karte
                bsr     paint_leiste
		bsr	paint_cursor
		bsr	paint_tod_escape

		rts

;---------------

		include	"include\paint640.s"
		include	"include\paint512.s"
		include	"include\paint320.s"

;---------------

paint_links_oben	
		dc.l	0
paint_lo_left	dc.l	0


;**************************************
;* paint_tod_escape
;**************************************

paint_tod_escape

		movea.l	play_dat_ptr,a4
		tst.w	pd_killed_flag(a4)
		beq.s	pte_out

		tst.w	menue_flag
		bne.s	pte_out

		lea	sm_press_esc,a0
		tst.w	karte_flag
		beq.s	pte_no_karte
		lea	sm_press_esc,a0
pte_no_karte	jsr	install_message

pte_out
		rts


;**************************************
;* paint_cursor
;**************************************

paint_cursor
		movea.l	play_dat_ptr,a6
		tst.w	pd_cursor_flag(a6)
		beq	pc_out
		tst.w	karte_flag
		bne	pc_out
		tst.w	cameraview_flag
		bne	pc_out
		tst.w	terminal_flag
		bne	pc_out

		movea.l	paint_links_oben(pc),a1
		move.w	pd_width_last(a6),d6

		adda.w	d6,a1
		move.w	pd_heigth_last(a6),d5
		lsr.w	#1,d5
		mulu	true_offi+2,d5
		adda.l	d5,a1

		lsr.w	#4,d6

		move.w	#%1100011000011000,d7
		movea.l	a1,a2
		move.w	d6,d5
		andi.w	#$fffe,d6
		suba.w	d6,a1

		
pc_loop_horizontal
		move.w	d7,(a1)+
		dbra	d6,pc_loop_horizontal
		
		tst.w	double_scan
		beq.s	pc_no_double
		lsr.w	#1,d5
pc_no_double
		lsr.w	#1,d5
		move.w	true_offi+2,d4
		move.w	d4,d3
		mulu	d5,d4
		suba.l	d4,a2

pc_loop_vertical
		move.w	d7,(a2)
		adda.w	d3,a2
		move.w	d7,(a2)
		adda.w	d3,a2
		dbra	d5,pc_loop_vertical

pc_out
		rts

;**************************************
;* paint_leiste
;**************************************

		include	"include\pleiste.s"


;**************************************
;* inclevel
;**************************************

		include	"include\inclevel.s"


;**************************************
;* make_cameraview
;**************************************

; uebergabeparameter:
; d0: nummer der camera
; sonst alle register frei

make_cameraview
		movea.l	big_sector_ptr,a0
		movea.l	lev_cameras(a0),a0
		movea.l	(a0,d0.w*4),a0

		move.l	a0,-(sp)
		bsr	vsync
		bsr	dsp_r_normal
		bsr	vsync
		move.l	(sp)+,a0

		movea.l	play_dat_ptr,a4
		move.w	pd_invis(a4),-(sp)

		move.w	#1,pd_invis(a4)

	; aktuelle position des spielers zwischenspeichern

		move.w	pd_akt_sector(a4),-(sp)
		move.l	pd_sx(a4),-(sp)
		move.l	pd_sy(a4),-(sp)
		move.l	pd_sh(a4),-(sp)
		move.l	pd_sh_real(a4),-(sp)
		move.l	pd_alpha(a4),-(sp)

	; camerakoordinaten setzen

		move.w	cam_sektor(a0),pd_akt_sector(a4)
		move.l	cam_sx(a0),pd_sx(a4)
		move.l	cam_sy(a0),pd_sy(a4)
		move.l	cam_sh(a0),d0
		move.l	d0,pd_sh(a4)
		move.l	d0,pd_sh_real(a4)
		move.w	cam_alpha_start(a0),d0
		move.w	d0,pd_alpha+2(a4)

	; camera auf anfangswinkel

		move.l	a0,mcv_cam_address
		move.w	d0,mcv_cam_pos
		clr.w	mcv_cam_flag

		bsr	vsync
		bsr	dsp_s_all
		bsr	vsync

		jsr	animate_all

		bsr	vsync
		bsr	dsp_r_normal
		bsr	vsync

mcv_loop
                jsr     dsp_info_ausw
		jsr	jagpad_simul

		bsr	dsp_s_all

		jsr	animate_all

	; gesamtes bild zeichnen

		bsr	paint_all

		ifeq	final
		jsr	frames_per_second
		endc

                jsr     find_vbl_time
		jsr	calc_time_limit

	; nun das blinkende rec-symbol
	; eventuell einblenden ...

		move.w	mcv_rec_count(pc),d0
		add.w	vbl_time,d0
		cmpi.w	#25,d0
		blt.s	mcv_no_rec_chg
		moveq	#0,d0
		not.w	mcv_rec_flag
mcv_no_rec_chg	move.w	d0,mcv_rec_count

		tst.w	mcv_rec_flag
		beq.s	mcv_no_rec
		lea	mcv_rec_txt(pc),a0
		movea.l	paint_links_oben,a6
		move.w	true_offi+2,d0
		add.w	d0,d0
		add.w	d0,d0
		addi.w	#8,d0
		adda.w	d0,a6
		jsr	paint_text
mcv_no_rec

		bsr	dsp_r_normal

	; und bildschirme vertauschen

		tst.w	vsync_flag
		bne.s	mcv_no_sync
		bsr	vsync
mcv_no_sync	jsr	swap_me


	; neuen camerawinkel bestimmen ...

		move.w	mcv_cam_pos(pc),d0
		movea.l	mcv_cam_address(pc),a0
		move.w	vbl_time,d1
		lsr.w	#1,d1
		bne.s	mcvn_bne
		moveq	#1,d1
mcvn_bne

		tst.w	mcv_cam_flag
		beq.s	mcv_forward

	; camera dreht sich zurueck

		sub.w	d1,d0
		cmp.w	cam_alpha_start(a0),d0
		bgt.s	mcv_cam_ok

		clr.w	mcv_cam_flag
		move.w	cam_alpha_start(a0),d0
		bra.s	mcv_cam_ok

mcv_forward

	; camera dreht sich vorwaerts

		add.w	d1,d0
		cmp.w	cam_alpha_end(a0),d0
		blt.s	mcv_cam_ok

		move.w	#1,mcv_cam_flag
		move.w	cam_alpha_end(a0),d0

mcv_cam_ok
		move.w	d0,mcv_cam_pos
		andi.w	#$ff,d0
		movea.l	play_dat_ptr,a4
		move.w	d0,pd_alpha+2(a4)
		

		tst.b	keytable+$39
		beq	mcv_loop

		clr.b	keytable+$39

		movea.l	play_dat_ptr,a4
		move.l	(sp)+,pd_alpha(a4)
		move.l	(sp)+,pd_sh_real(a4)
		move.l	(sp)+,pd_sh(a4)
		move.l	(sp)+,pd_sy(a4)
		move.l	(sp)+,pd_sx(a4)
		move.w	(sp)+,pd_akt_sector(a4)

		move.w	(sp)+,pd_invis(a4)

		bsr	vsync
		bsr	dsp_s_all
		bsr	vsync

mcv_out
		rts

;---

mcv_cam_address	dc.l	0
mcv_cam_pos	dc.w	0
mcv_cam_flag	dc.w	0

;---

mcv_rec_txt	dc.b	"REC",0
mcv_rec_flag	dc.w	0
mcv_rec_count	dc.w	0


;**************************************
;* make_two_180_turns
;**************************************

make_two_180_turns

		bsr	vsync
		bsr	dsp_r_normal
		bsr	vsync

		movea.l	play_dat_ptr,a4
		move.l	pd_alpha(a4),d0
		addi.l	#128,d0
		andi.l	#$ff,d0
		move.l	d0,pd_alpha(a4)

		bsr	vsync
		bsr	dsp_s_all
		bsr	vsync

		bsr	vsync
		bsr	dsp_r_normal
		bsr	vsync

		bsr	vsync
		bsr	dsp_s_all
		bsr	vsync

		bsr	paint_all

		bsr	vsync
		bsr	dsp_r_normal
		bsr	vsync

		movea.l	play_dat_ptr,a4
		move.l	pd_alpha(a4),d0
		addi.l	#128,d0
		andi.l	#$ff,d0
		move.l	d0,pd_alpha(a4)

		bsr	vsync
		bsr	dsp_s_all
		bsr	vsync

mt180t_out
		rts


;**************************************
;* make_laptop
;**************************************

		include	"include\laptop.s"


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
		move.w	thing_action(a0),d0	; optinales argument
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

		movea.l	(sp)+,a0	; things_ptr holen
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

th_install_message:

                move.w  thing_type(A0),D0
                bpl.s   tim_not_taken

                lea     things_txt_ptr,A1
                neg.w   D0
                subq.w  #1,D0

                move.l  A0,-(SP)
                move.l 	0(A1,D0.w*4),d0
		beq.s	tim_skip
		movea.l	d0,a0
                bsr     install_message
tim_skip
                movea.l (SP)+,A0

tim_not_taken:
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


;**************************************
;* activate_left_ptr
;**************************************

; d0 = zu aktvierende routine (0..)

activate_left_ptr

		tst.w	d0
		bmi.s	alp_out

		lea	pl_left_routines,a2
		tst.l	(a2,d0.w*8)
		beq.s	alp_out

		move.w	d0,pl_left_nb

alp_out
		rts		

;**************************************
;* deactivate_left_ptr
;**************************************

deactivate_left_ptr

		lea	pl_left_nb,a6
		move.w	(a6),d0			; aktuelle routinennummer holen
		bmi.s	dlp_out			; keine da -> raus

		move.w	#-1,(a6)
		lea	pl_left_routines,a2
		move.w	6(a2,d0.w*8),d1		; zu deaktivierender gegenstand
		beq.s	dlp_out
		bmi.s	dlp_out
		lea	pl_deaction_routs,a2
		move.l	-4(a2,d1.w*4),d1
		beq.s	dlp_out
		movea.l	d1,a0
		jsr	(a0)

dlp_out
		rts


;**************************************

; 8 verschiedene routinen fuer farbtabellen

truetabs_routs	dc.l	truetab_0
		dc.l	truetab_1
		dc.l	truetab_2
		dc.l	truetab_3
		dc.l	truetab_4
		dc.l	0
		dc.l	0
		dc.l	0

;---------------

; normale farbtabelle

truetab_0 

		lea	abdunkel_tab(pc),a6
		lea	truecolor_tab,a0

		moveq	#7,d0

tt0_loop
		move.w	d0,-(sp)
		move.w	(a6)+,d6	; abdunkelungswerte (0..31)
		movem.l	a0/a6,-(sp)
		bsr	tt0_now
		movem.l	(sp)+,a0/a6
		adda.l	#32768*2,a0
		move.w	(sp)+,d0
	
		dbra	d0,tt0_loop

                rts

tt0_now
		adda.l	#32768*2,a0
		move.w	#31,d7
		
		move.w	#31,d0
tt0n_loop1	move.w	#31,d1
tt0n_loop2	move.w	#31,d2
tt0n_loop3	move.w	d2,d5
		mulu	d6,d5
		divu	d7,d5

		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	d7,d4

		move.w	d0,d3
		mulu	d6,d3
		divu	d7,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		andi.w	#%0000000000111111,d4
		add.w	d4,d3
		lsl.w	#5,d3
		andi.w	#%0000000000011111,d5
		add.w	d5,d3

		move.w	d3,-(a0)

		dbra	d2,tt0n_loop3
		dbra	d1,tt0n_loop2
		dbra	d0,tt0n_loop1

		rts

;---------------

; nachtsichtgeraet

truetab_1

		lea	abdunkel_tab(pc),a6
		lea	truecolor_tab,a0

		moveq	#7,d0

tt1_loop
		move.w	d0,-(sp)
		move.w	(a6)+,d6	; abdunkelungswerte (0..31)
		movem.l	a0/a6,-(sp)
		bsr	tt1_now
		movem.l	(sp)+,a0/a6
		adda.l	#32768*2,a0
		move.w	(sp)+,d0
	
		dbra	d0,tt1_loop

                rts

tt1_now
		adda.l	#32768*2,a0
		
		move.w	#31,d0
tt1n_loop1	move.w	#31,d1
tt1n_loop2	move.w	#31,d2
tt1n_loop3	
		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	#31,d4

		andi.w	#%0000000000111111,d4
		lsl.w	#5,d4

		move.w	d4,-(a0)

		dbra	d2,tt1n_loop3
		dbra	d1,tt1n_loop2
		dbra	d0,tt1n_loop1

		rts

;---------------

; infrarotsichtgeraet

truetab_2

		lea	abdunkel_tab(pc),a6
		lea	truecolor_tab,a0

		moveq	#7,d0

tt2_loop
		move.w	d0,-(sp)
		move.w	(a6)+,d6	; abdunkelungswerte (0..31)
		movem.l	a0/a6,-(sp)
		bsr	tt2_now
		movem.l	(sp)+,a0/a6
		adda.l	#32768*2,a0
		move.w	(sp)+,d0
	
		dbra	d0,tt2_loop

                rts

tt2_now
		adda.l	#32768*2,a0
		
		move.w	#31,d0
tt2n_loop1	move.w	#31,d1
tt2n_loop2	move.w	#31,d2
tt2n_loop3	move.w	d2,d5
		mulu	d6,d5
		divu	#31,d5

		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	#31,d4

		move.w	d0,d3
		mulu	d6,d3
		divu	#31,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		andi.w	#%0000000000111111,d4
		add.w	d4,d3
		lsl.w	#5,d3
		andi.w	#%0000000000011111,d5
		add.w	d5,d3

		andi.w	#%1111100000000000,d3

		move.w	d3,-(a0)

		dbra	d2,tt2n_loop3
		dbra	d1,tt2n_loop2
		dbra	d0,tt2n_loop1

		rts

;---------------

; nebel (ok, 8.6.96)

truetab_3

		lea	abdunkel_tab,a6
		lea	nebel_abdunkel_tab,a5
		lea	truecolor_tab,a0

		moveq	#7,d0

tt3_loop
		move.w	d0,-(sp)
		move.w	(a6)+,d6	; abdunkelungswerte (0..31)
		move.w	(a5)+,d7
		movem.l	a0/a5-a6,-(sp)
		bsr	tt3_now
		movem.l	(sp)+,a0/a5-a6
		adda.l	#32768*2,a0
		move.w	(sp)+,d0
	
		dbra	d0,tt3_loop

                rts

tt3_now
		move.w	#31,d5
		sub.w	d7,d5
		move.w	#%01111,d4
		mulu	d7,d4
		divu	#31,d4

		adda.l	#32768*2,a0
		
		move.w	#31,d0
tt3n_loop1	move.w	#31,d1
tt3n_loop2	move.w	#31,d2
tt3n_loop3	
		movem.w	d0-d2,-(sp)

		mulu	d6,d2
		divu	#31,d2
		mulu	d5,d2
		divu	#31,d2
		add.w	d4,d2		

		lsl.w	#1,d1
		addq.w	#1,d1
		mulu	d6,d1
		divu	#31,d1
		mulu	d5,d1
		divu	#31,d1
		add.w	d4,d1	
		add.w	d4,d1	

		mulu	d6,d0
		divu	#31,d0
		mulu	d5,d0
		divu	#31,d0
		add.w	d4,d0

		andi.w	#%0000000000011111,d0
		lsl.w	#6,d0
		andi.w	#%0000000000111111,d1
		add.w	d1,d0
		lsl.w	#5,d0
		andi.w	#%0000000000011111,d2
		add.w	d2,d0

		move.w	d0,-(a0)

		movem.w	(sp)+,d0-d2

		dbra	d2,tt3n_loop3
		dbra	d1,tt3n_loop2
		dbra	d0,tt3n_loop1

		rts

nebel_abdunkel_tab

		dc.w	0,2,4,6,8,10,12,14
;		dc.w	0,5,9,14,18,22,27,31

;---------------

; farbtabelle: "licht aus"

truetab_4

		lea	lichtaus_abdunkel_tab(pc),a6
		lea	truecolor_tab,a0

		moveq	#7,d0

tt4_loop
		move.w	d0,-(sp)
		move.w	(a6)+,d6		; abdunkelungswerte (0..31)
		movem.l	a0/a6,-(sp)
		bsr	tt4_now
		movem.l	(sp)+,a0/a6
		adda.l	#32768*2,a0
		move.w	(sp)+,d0
	
		dbra	d0,tt4_loop

                rts

tt4_now
		adda.l	#32768*2,a0
		move.w	#31,d7
		
		move.w	#31,d0
tt4n_loop1	move.w	#31,d1
tt4n_loop2	move.w	#31,d2
tt4n_loop3	move.w	d2,d5
		mulu	d6,d5
		divu	d7,d5

		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	d7,d4

		move.w	d0,d3
		mulu	d6,d3
		divu	d7,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		andi.w	#%0000000000111111,d4
		add.w	d4,d3
		lsl.w	#5,d3
		andi.w	#%0000000000011111,d5
		add.w	d5,d3

		move.w	d3,-(a0)

		dbra	d2,tt4n_loop3
		dbra	d1,tt4n_loop2
		dbra	d0,tt4n_loop1

		rts

lichtaus_abdunkel_tab

;		dc.w	11,10,9,8,7,6,5,4
		dc.w	7,6,5,4,3,2,1,0

;---------------

paint_rectangle:
		lea	rectangle_datas,a1
		moveq	#3,d6
pr_loop:
		movem.l	d6/a1,-(sp)

		movea.l	screen_1(pc),a0
		move.w	#$f000,d7
		move.w	#640,d4
		move.w	(a1),d0
		move.w	2(a1),d1
		move.w	4(a1),d2
		move.w	6(a1),d3

		movem.w	d0-d4/d7,-(sp)
		bsr	linie
		movem.w	(sp)+,d0-d4/d7

		movea.l	screen_2(pc),a0
		bsr	linie

		movem.l	(sp)+,d6/a1
		addq.l	#8,a1
		dbra	d6,pr_loop

		rts

;---------------

rectangle_datas:
		dc.w	30,188,290,188
		dc.w	290,188,290,195
		dc.w	290,195,30,195
		dc.w	30,195,30,188	

;---------------

abdunkel_tab:	dc.w	31,29,27,25,23,21,19,17


;---------------

make_true_now:
                adda.l	#32768*2,a0

                move.w  #31,D0
make_true_lp1:  move.w  #31,D1
make_true_lp2:  move.w  #31,D2
make_true_lp3:
                move.w  D2,D5
                mulu    D6,D5
                divu    #31,D5

                move.w  D1,D4
		lsl.w	#1,d4
		addq.w	#1,d4
                mulu    D6,D4
                divu    #31,D4

                move.w  D0,D3
                mulu    D6,D3
                divu    #31,D3

                andi.w  #%0000000000011111,D3
                lsl.w   #6,D3
                andi.w  #%0000000000111111,D4
                add.w   D4,D3
                lsl.w   #5,D3
                andi.w  #%0000000000011111,D5
                add.w   D5,D3

		andi.w	#%0000011111100000,d3

                move.w  D3,-(A0)

                dbra    D2,make_true_lp3
                dbra    D1,make_true_lp2
                dbra    D0,make_true_lp1

                rts

;---------------

; d0: nummer der farbtabelle

load_truecolor_tab:

		move.l	vbl_count,-(sp)

		move.w	d0,ltt_actual_tab

		movea.l	big_sector_ptr,a0
		movea.l	lev_color_tab(a0),a0
		move.l	0(a0,d0.w*4),file_name_ptr
		move.l	#524288,file_size
		move.l	#truecolor_tab,file_buf_ptr

		bsr	load_file

		move.w	ltt_actual_tab(pc),d0
		movea.l	big_sector_ptr,a0
                move.l  lev_boden(A0),a0
		move.l	(a0,d0.w*4),boden_col_ptr

		move.l	(sp)+,vbl_count

		rts

;---

ltt_actual_tab	dc.w	0

;---------------

save_truecolor_tab:

		move.l	a0,file_name_ptr
		move.l	#524288,file_size
		move.l	#truecolor_tab,file_buf_ptr
		bsr	save_file
		
		rts


;**************************************


make_walk_data:
                move.w  #120,D0
                move.w  #18,D1
                move.w  #7,D2
                move.w  #3,D3

                bsr.s   make_walk_dat_now

                rts


;---------------

;* d0: Schrittweite
;* d1: Anzahl Bilder Abbremsen
;* d2: Drehwinkel
;* d3: Anzahl Bilder Abbremsen (Drehen)

;* Referenz sind 10 Bilder pro Sekunde (= 5 VBL's)

make_walk_dat_now:

                lea     walking_data,A0
                moveq   #31,D7
mwdn_loop:
                moveq   #31,D6
                sub.w   D7,D6
                move.w  D6,D5
                mulu    D0,D5
                divu    #5,D5
                tst.w   D5
                bne.s   schritt_ok
                moveq   #1,D5
schritt_ok:     move.w  D5,(A0)+

                move.w  D6,D5
                mulu    D1,D5
                divu    #5,D5
                tst.w   D5
                bne.s   abbrems_ok
                moveq   #1,D5
abbrems_ok:     move.w  D5,(A0)+

                move.w  D6,D5
                mulu    D2,D5
                divu    #5,D5
                tst.w   D5
                bne.s   schritt2_ok
                moveq   #1,D5
schritt2_ok:    move.w  D5,(A0)+

                move.w  D6,D5
                mulu    D3,D5
                divu    #5,D5
                bne.s   abbrems2_ok
                moveq   #1,D5
abbrems2_ok:    move.w  D5,(A0)+

                dbra    D7,mwdn_loop

                rts

;---------------

prepare_menufont
		lea	menufont+128,a0
		move.l	#menufont_end,d0
		sub.l	#menufont,d0
		subi.l	#128,d0
		lsr.l	#1,d0
		subq.l	#1,d0
pmf_loop
		cmpi.w	#%0000000000100000,(a0)+
		bne.s	pmf_ok
		clr.w	-2(a0)
pmf_ok
		dbra	d0,pmf_loop

		rts

;---------------

init_make_grey
		lea	leiste_gfx+128,a2
		move.w	#320*9-1,d0
mg_loop:
		cmpi.w	#%100000,(a2)+
		bne.s	mg_not_black
		clr.w	-2(a2)
mg_not_black:
		dbra	d0,mg_loop

                rts

;---

make_grey_now:
		lea	leiste_gfx+128+640*9,a1
                adda.l  #200*true,A0
                move.w  #39,D0
grey_loop1:     move.w  #39,D1
grey_loop2:     move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D1,grey_loop2
                dbra    D0,grey_loop1

                rts


;**************************************
;* dsp kommunikationsroutinen
;**************************************

		include	"include\dsp_comm.s"


;**************************************
;* init routines ...
;**************************************

		include	"include\init.s"
                


;**************************************
;* new_key
;**************************************


new_key
		movem.l	d0/a0,-(sp)

		lea	$fffffc00.w,a0
		move.b	(a0),d0			; $fffffc00 lesen = sr
		btst	#7,d0
		beq.s	nk_midi_irq

		move.b	2(a0),d0		; data out
		move.b	d0,key
		bsr.s	nk_instkeytable

nk_out
		movem.l	(sp)+,d0/a0

		rte

;---

nk_instkeytable

		lea	keytable(pc),a0
		andi.w	#$ff,d0
		tst.b	d0
		bmi.s	nkik_losgelassen

		ifeq final
		cmpi.b	#$6b,d0
		bne.s	nkik_ok
		movem.l	d7/a1,-(sp)
		movea.l	screen_2,a1
		move.w	#159,d7
nkik_debug	not.l	(a1)+
		dbra	d7,nkik_debug
		movem.l	(sp)+,d7/a1
nkik_ok
		endc

		move.b	#$ff,(a0,d0.w)
		rts

nkik_losgelassen

		andi.b	#%01111111,d0
		clr.b	(a0,d0.w)
		rts

;---------------

nk_midi_irq

	; der ausgeloeste irq war durch midi bedingt ...

		bra.s	nk_out

;--------------------------------------

; original version bis maerz 1997

;new_key:        
;                movem.l D0/A0,-(SP)
;
;                lea     $FFFFFC00.w,A0
;                move.b  (A0),D0
;                btst    #7,D0
;                beq.s   must_be_midi
;
;                cmpi.b  #$FF,2(A0)
;                bne.s   test_2
;i1a:            move.b  (A0),D0
;                btst    #7,D0
;                beq.s   i1a
;i1:             move.b  2(A0),D0
;                cmpi.b  #$FF,D0
;                beq.s   i1
;                move.b  D0,port
;
;                bra.s   new_key_out
;
;;---
;
;test_2:         cmpi.b  #$FE,2(A0)
;                bne.s   only_a_key
;i1a2:           move.b  (A0),D0
;                btst    #7,D0
;                beq.s   i1a2
;i12:            move.b  2(A0),D0
;                cmp.b   #$FE,D0
;                beq.s   i12
;                move.b  D0,port+1
;
;                bra.s   new_key_out
;
;---
;
;only_a_key:
;                move.b  2(A0),D0
;                move.b  D0,key
;                bsr.s   convert_key_code
;
;                bra.s   new_key_out
;
;                nop
;
;new_key_out:
;                movem.l (SP)+,D0/A0
;
;                rte
;
;;---------------
;
;must_be_midi:
;                movea.l midi_rout_ptr,A0
;                jsr     (A0)
;
;                bra.s   new_key_out
;
;;---------------
;
;include_quick:
;                lea     play_dat_p2,A0
;                move.l  midi_record(PC),pd_sx(A0)
;                move.l  midi_record+4(PC),pd_sy(A0)
;                move.l  midi_record+8(PC),pd_sh(A0)
;                move.l  midi_record+12(PC),pd_alpha(A0)
;
;                rts
;
;;---------------
;
;convert_key_code
;
;		lea	keytable(pc),a0
;		andi.w	#$ff,d0
;		tst.b	d0
;		bmi.s	ckc_losgelassen
;
;		ifeq final
;		cmpi.b	#$6b,d0
;		bne.s	nk_ok
;		movem.l	d0-a6,-(sp)
;		movea.l	screen_2,a1
;		move.w	#159,d7
;ckc_debug_loop	not.l	(a1)+
;		dbra	d7,ckc_debug_loop
;		movem.l	(sp)+,d0-a6
;
;nk_ok
;		endc
;
;		move.b	#$ff,(a0,d0.w)
;		rts
;
;ckc_losgelassen
;		andi.b	#%01111111,d0
;		clr.b	(a0,d0.w)
;		rts


;---------------

keytable	ds.b	128
keytable_help	ds.b	128
port		dc.w	0
last_time_joy	dc.w	0

;---------------

midi_nothing

		rts


;**************************************
;* my_vbl
;**************************************

my_vbl
                addq.l  #1,vbl_count
                addq.w  #1,vbl_checker

		tst.w	dv_flag
		beq.s	mv_no_dv
		move.l	#dummy_vbl,$70.w
mv_no_dv
                rte
      
;---------------

dummy_vbl	
		move.l	#my_vbl,$70.w
		rte          

;**************************************
;* jagpad.inc
;**************************************

jagpad_routs
		incbin	"include\jagpad.inc"
		even

;--------------------------------------
; simulation des jaguarpads

jagpad_simul

		lea	keytable,a1
		moveq	#1,d4

		lea	jagpad_routs+4(pc),a0
		jsr	(a0)			; d0 = jagpad a
		move.l	jagpad_last(pc),d1	; d1 = jagpad a (letztes bild ...)

		tst.w	menue_flag
		bne	js_menue
		tst.w	cameraview_flag
		bne	js_cameraview
		tst.w	terminal_flag
		bne	js_terminal

		moveq	#$f,d2			; taste tab
		moveq	#25,d3			; zugehoeriges bit fuer jagpad
		bsr	jps_now

		moveq	#$1,d2			; taste esc
		moveq	#28,d3
		bsr	jps_now

		moveq	#$39,d2			; taste space
		moveq	#10,d3
		bsr	jps_now

		moveq	#$2a,d2			; taste shift
		moveq	#9,d3
		bsr	jps_now

		moveq	#$60,d2			; taste <
		moveq	#23,d3
		bsr	jps_now

		moveq	#$62,d2
		moveq	#31,d3
		bsr	jps_now

		moveq	#$61,d2
		moveq	#30,d3
		bsr	jps_now

		moveq	#$1c,d2
		moveq	#16,d3
		bsr	jps_now

		bra	js_out

	; -----------------------------

js_terminal

		moveq	#$1,d2
		moveq	#7,d3
		bsr	jps_now

		bra	js_out

	; -----------------------------

js_cameraview

		moveq	#$39,d2
		moveq	#7,d3
		bsr	jps_now

		bra	js_out

	; -----------------------------

js_menue
		moveq	#$48,d2
		moveq	#0,d3
		bsr	jps_now

		moveq	#$50,d2
		moveq	#1,d3
		bsr	jps_now

		moveq	#$4b,d2
		moveq	#2,d3
		bsr	jps_now

		moveq	#$4d,d2
		moveq	#3,d3
		bsr	jps_now

		moveq	#$39,d2
		moveq	#9,d3
		bsr	jps_now

js_out
		move.l	d0,jagpad_last

		rts

;--------------------------------------

; d0 = jagpad a
; d1 = jagpad a (last)
; d2 = scancode
; d3 = bit fuer jagpad
; d4 = #1
; a1 = keytable

; setze das flag in keytable, falls das jagpad-bit gesetzt ist, beim
; vorherigen durchlauf aber geloescht war. also setze das flag in 
; keytable genau dann, wenn immoment der jagpad-button gedrueckt wurde.
; loesche umgekehrt das flag in keytable genau dann ...

jps_now

	; muss das flag in keytable gesetzt werden?

		btst	d3,d0			; gesetzt?
		beq.s	jps_no_set		; wenn nein, dann raus
		btst	d3,d1			; vorher gesetzt gewesen?
		bne.s	jps_no_set		; wenn ja, dann raus

	; das flag muss gesetzt werden, koennen keytable einfach
	; setzen, egal was fuer ein wert keytable hat. denn bis
	; hier hin kommt die routine nur, wenn der jagpad wirklich
	; angeschlossen ist ...

		move.b	d4,(a1,d2.w)

jps_no_set		

	; muss das flag in keytable geloescht werden?

		btst	d3,d0			; geloescht?
		bne.s	jps_no_clear		; wenn nein, dann raus
		btst	d3,d1			; vorher geloescht gewesen?
		beq.s	jps_no_clear		; wenn ja, dann raus

	; das flag muss geloescht werden, koennen keytable einfach
	; loeschen, egal was fuer ein wert keytable hat. denn bis
	; hier hin kommt die routine nur, wenn der jagpad wirklich
	; angeschlossen ist ...

		clr.b	(a1,d2.w)

jps_no_clear


		rts

;---------------

		include	"include\episread.s"

;---------------

		ifne ivan_debug
bus_error
		movea.l	screen_2,a1
		move.w	#199,d0
be_loop1	movea.l	a1,a0
		move.w	#159,d1
		move.w	d1,d2
		andi.w	#$0001,d2
		add.w	d2,d2
		adda.w	d2,a0
be_loop2	clr.w	(a0)
		addq.l	#4,a0
		dbra	d1,be_loop2
		lea	640(a0),a0
		dbra	d0,be_loop1

;		move.l	15*4+10(sp),a0		; pc bei bus_error
;		lea	dith_data,a1
;		move.l	a0,(a1)+
;		lea	-16384(a0),a0
;		move.w	#32767,d7
;be_loop1	move.b	(a0)+,(a1)+
;		dbra	d7,be_loop1

		move.l	sp,file_buf_ptr
		move.l	#32768+4,file_size
		move.l	#be_file,file_name_ptr
		jsr	save_file

		lea	be_message,a0
		movea.l	screen_2,a6
		adda.l	#80*2+640*50,a6
		move.w	#9,text_height
		jsr	paint_text

		moveq	#15,d1
be_ziffer_loop	movea.l	screen_2,a2
		move.w	d1,d2
		mulu	true_offi+2,d2
		lsl.l	#3,d2
		adda.l	d2,a2
		moveq	#3,d7
		movea.l	sp,a6
		move.w	d1,d2
		add.w	d2,d2
		ext.l	d2
		adda.l	d2,a6
		move.w	(a6),d0	
		move.w	d1,-(sp)
		jsr	paint_hex
		move.w	(sp)+,d1
		dbra	d1,be_ziffer_loop

		movea.l	screen_2,a2
		adda.l	#640*160+320,a2
		move.l	ivan_code,d0
		moveq	#7,d7
		jsr	paint_hex

;		lea	be_message,a0
;		jsr	install_message

be_end		nop
		bra.s	be_end

ivan_code	dc.l	0
be_message	dc.b	"BUS ERROR EXCEPTION",0
be_file		dc.b	"buserror.dat",0
		even

		endc


;***********************************************************
;***********************************************************


                DATA

counter:        DC.W 0

true_offi:      DC.L true
karte_flag:     DC.W 0
jagpad_last	dc.l	0

cameraview_flag	dc.w	0
terminal_flag	dc.w	0

screen_1	dc.l	0
screen_2	dc.l	0

		ifne mxalloc_flag
samples_data	dc.l	0
		endc

;--------------------------------------

sc_priority	dc.w	0,0,0,0,0,0,0,0		; 0 hat gegenueber keiner anderen prioritaet
		dc.w	1,0,0,1,1,0,0,0		
		dc.w	1,0,1,1,1,0,0,0
		dc.w	1,0,0,0,0,0,0,0
		dc.w	1,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0
		dc.w	0,0,0,0,0,0,0,0

;**************************************
;* dma_player
;**************************************

spl_pos		dc.w	0	; freier speicher
spl_play_len	dc.l	0	; samplewerte pro intervall
spl_play_len_25	dc.l	0	; vergleichswert bei 25 kHz
spl_add_len	dc.l	0	; buffergroesse (frequenz/modi)

spl_vol_counter	dc.w	0	; nicht jedes mal die lautstaerken
				; neu bestimmen

spl_system	dc.w	%001

;---

spl_dat
		dc.l	0	; length
		dc.l	0	; offset
		dc.l	0	; frac
		dc.l	0	; address
		dc.l	0	; info
		dc.l	0	; x
		dc.l	0	; y
		dc.w	0	; speed
		dc.l	0	; voltab
		dc.l	0	; vorkomma
		dc.w	0	; nachkomma
		dc.l	0	; play_offi
		dc.l	0	; voltab_left

		dc.l	0	; length
		dc.l	0	; offset
		dc.l	0	; frac
		dc.l	0	; address
		dc.l	0	; info
		dc.l	0	; x
		dc.l	0	; y
		dc.w	0	; speed
		dc.l	0	; voltab
		dc.l	0	; vorkomma
		dc.w	0	; nachkomma
		dc.l	0	; play_offi
		dc.l	0	; voltab_left

		dc.l	0	; length
		dc.l	0	; offset
		dc.l	0	; frac
		dc.l	0	; address
		dc.l	0	; info
		dc.l	0	; x
		dc.l	0	; y
		dc.w	0	; speed
		dc.l	0	; voltab
		dc.l	0	; vorkomma
		dc.w	0	; nachkomma
		dc.l	0	; play_offi
		dc.l	0	; voltab_left

		dc.l	0	; length
		dc.l	0	; offset
		dc.l	0	; frac
		dc.l	0	; address
		dc.l	0	; info
		dc.l	0	; x
		dc.l	0	; y
		dc.w	0	; speed
		dc.l	0	; voltab
		dc.l	0	; vorkomma
		dc.w	0	; nachkomma
		dc.l	0	; play_offi
		dc.l	0	; voltab_left


spl_leer_sam
		dc.l	max_play_buffer
		dc.l	0
		dc.l	0
		dc.l	sam_leer
		dc.l	0
		dc.l	0
		dc.l	0
		dc.w	0
		dc.l	vol_tab
		dc.l	1
		dc.w	0
		dc.l	0
		dc.l	vol_tab

;---------------

vbl_start	dc.l	0
vbl_time	dc.w	0

;---------------

step		dc.w	0
direction	dc.w	0
has_moved	dc.w	0

;---------------

schnitt_flags:  DS.W 4
ccw_erg:        DC.W 0
test_points:    DS.L 4
stand_rot:      DS.L 5*2

schnitt_anz:    DC.W 0
ccw_temp:       DC.W 0
                DC.W 0

sx_test:        DC.L 0
sy_test:        DC.L 0
sh_found:       DC.L 0

inside_ok:      DC.W 0
durchstoss_anz: DC.W 0

inter_ptr:      DS.L 5


;---------------

; load_file & save_file

file_name_ptr	dc.l	0
file_size	dc.l	0
file_buf_ptr	dc.l	0

;---------------

; karte

karte_x_offi:   DC.L 0
karte_y_offi:   DC.L 0

karte_follow:   DC.W 0
karte_tab_last: DC.W 0

karten_zoom:    DC.W 64

karte_player:   DS.L 8
things_pts_ptr: DS.L 10

karte_screen:   DC.L 0



mon_buf1_ptr:   DC.L mon_send_buf1
mon_buf2_ptr:   DC.L mon_send_buf2




;**************************************
;* paint_leiste
;**************************************


pl_mun_soffs:   DC.L 640*201+289*2
                DC.L 640*207+289*2
                DC.L 640*213+289*2
                DC.L 640*219+289*2

pl_munx_soffs:  DC.L 640*207+596
                DC.L 640*214+596
                DC.L 640*221+596
                DC.L 640*228+596

pl_munl_soffs	dc.l	640*200+278*2
		dc.l	640*206+278*2
		dc.l	640*212+278*2
		dc.l	640*218+278*2

;---

pl_thg_color:   DC.W $F800,$D100,$B200,$9300
                DC.W $7400,$5500,$3600,$1700

pl_thg_soffs
		dc.l	640*212+129*2
		dc.l	640*212+147*2
		dc.l	640*212+165*2
		dc.l	640*212+111*2
		dc.l	640*212+93*2

;---------------

phex_routs:
                DC.L paint_0,paint_1,paint_2,paint_3
                DC.L paint_4,paint_5,paint_6,paint_7
                DC.L paint_8,paint_9,paint_a,paint_b
                DC.L paint_c,paint_d,paint_e,paint_f

;---

pdeci_routs:    DC.L pdeci_0
                DC.L pdeci_1
                DC.L pdeci_2
                DC.L pdeci_3
                DC.L pdeci_4
                DC.L pdeci_5
                DC.L pdeci_6
                DC.L pdeci_7
                DC.L pdeci_8
                DC.L pdeci_9

;---

pdeci512_routs
		dc.l	pdeci512_0,pdeci512_1,pdeci512_2
		dc.l	pdeci512_3,pdeci512_4,pdeci512_5
		dc.l	pdeci512_6,pdeci512_7,pdeci512_8
		dc.l	pdeci512_9

;---------------

midi_record:    DS.B 16

midi_rec_pos:   DC.W 0
midi_rec_len:   DC.W 16

old_vbl:        DC.L 0
old_stack:      DC.L 0
old_res:        DC.W 0
old_screen:     DC.L 0
vbl_count:      DC.L 0
vbl_checker:    DC.W 1

dsp_words_t	dc.l	0
dsp_words_b	dc.l	0
dsp_words_m	dc.l	0

min_entf	dc.l	0

dsp_calc_l_ii_anz:
                DC.L 0

;**************************************
;* mainmenue
;**************************************

		ifne menueflag
		include	"include\menu\fire.dat"
		include	"include\menu\gouraud.dat"
		include	"include\menu\texture.dat"
		endc

;**************************************
;* tables
;**************************************

		include	"include\tables.s"


;**************************************
;* dsp assembler programm
;**************************************

dsp_ads_file	dc.b	"data\dsp\running.dsp",0
dsp_mads_file	dc.b	"data\dsp\fast_dtm.ads",0

dsp_inl_file	dc.b	"data\dsp\system.dsp",0

		even


;**************************************
;* level daten (pointer)
;**************************************

big_sector_ptr	dc.l	0
boden_col_ptr	dc.l	0
play_dat_ptr	dc.l	0


;**************************************
;* level
;**************************************

		ifne	compile_level
		include	"e:\running\kanal.s"
		endc


;**************************************

pl_thg_offs:    DC.L	640*0+0
                DC.L	640*0+32*1
                DC.L 	640*0+32*2
                DC.L 	640*0+32*3
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	640*0+32*4		; th_scanner
		dc.l	640*0+32*5		; th_night
		dc.l	640*0+32*6		; th_mask
		dc.l	640*0+32*7		; th_smallmedkit
		dc.l	640*0+32*8		; th_bigmedkit
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	640*0+32*9		; th_invul
		dc.l	640*0+32*10		; th_invis
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	640*0+32*11
		dc.l	640*0+32*12
		dc.l	640*0+32*13
		dc.l	0
		dc.l	640*0+32*15		; th_mondetector
		dc.l	640*0+32*18		; th_plan
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0			; 33
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0			; 37
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	640*0+32*16		; th_welder
		dc.l	0
		dc.l	640*0+32*17		; th_verseuch
		dc.l	0
		dc.l	0			; 45
		dc.l	640*0+32*14
		dc.l	0
		dc.l	0
		dc.l	0			; 49
		dc.l	0
		dc.l	0
		dc.l	640*0+32*19
		dc.l	0			; 53
		dc.l	0
		dc.l	0			; 55
		dc.l	640*16+32*1		; th_geninvul
		dc.l	640*16+32*2		; th_geninvis	(57)
		dc.l	0			; th_color0
		dc.l	0			; th_color1
		dc.l	0			; th_color2	(60)
		dc.l	0			; th_color3
		dc.l	0			; th_color4
		dc.l	0			; th_color5
		dc.l	0			; th_color6
		dc.l	0			; th_color7
		dc.l	0			; th_color	(66)
		dc.l	640*16+32*3		; th_bierkrug
		dc.l	640*16+32*4		; th_trndetector
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0			; (77)
		dc.l	0
		dc.l	0
		dc.l	640*16+32*5		; th_condom
		dc.l	640*16+32*6		; th_idcard
		dc.l	0

;---

things_samples
		dc.w	snd_item		; (1)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item		; (5)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item		; (10)
		dc.w	snd_item
		dc.w	snd_item		; th_small_medikit
		dc.w	snd_item		; th_big_medikit
		dc.w	snd_like		; th_small_medikit
		dc.w	snd_dope		; th_big_medikit
		dc.w	snd_good		; th_small_armor
		dc.w	snd_like		; th_big_armor
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_dont		; th_pistol1
		dc.w	snd_check		; th_pistol2
		dc.w	snd_nice		; th_pistol3
		dc.w	snd_dont		; th_pistol4
		dc.w	snd_item
		dc.w	snd_item		; (25)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item		; (30)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item		; (35)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	-1
		dc.w	snd_item		; (40)
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	-1			; (45)
		dc.w	snd_item
		dc.w	-1
		dc.w	-1
		dc.w	-1			; (49)		
		dc.w	snd_item
		dc.w	snd_item		; (51)
		dc.w	snd_item
		dc.w	snd_item		; (53)
		dc.w	snd_item
		dc.w	snd_item		; (55)
		dc.w	snd_item
		dc.w	snd_item		; (57)	(th_geninvis)
		dc.w	-1
		dc.w	-1
		dc.w	-1			; (60)
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1			; (66)
		dc.w	snd_like
		dc.w	snd_item		; (68) (th_trndetector)
		dc.w	-1
		dc.w	-1			; (70)
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1			; (76)
		dc.w	-1
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item
		dc.w	snd_item		; (81)
		dc.w	-1

;---

; diese routinen werden ausgefuehrt, wenn
; ein gegenstand aufgenommen wird

things_routs:
                DC.L 	things_rout01
                DC.L 	things_rout02
                DC.L 	things_rout03
                DC.L 	things_rout04
                DC.L 	things_rout05
                DC.L 	things_rout06
                DC.L 	things_rout07
                DC.L 	things_rout08
                DC.L 	things_rout09
		dc.l	things_rout10
		dc.l	things_rout11
		dc.l	things_rout12
		dc.l	things_rout13
		dc.l	things_rout14
		dc.l	things_rout15
		dc.l	things_rout16
		dc.l	things_rout17
		dc.l	things_rout18
		dc.l	things_rout19
		dc.l	things_rout20
		dc.l	things_rout21
		dc.l	things_rout22
		dc.l	things_rout23
		dc.l	things_rout24
		dc.l	things_rout25
		dc.l	things_rout26
		dc.l	things_rout27
		dc.l	things_rout28
		dc.l	things_rout29
		dc.l	things_rout30
		dc.l	things_rout31
		dc.l	things_rout32
		dc.l	things_rout33
		dc.l	things_rout34
		dc.l	things_rout35
		dc.l	things_rout36
		dc.l	things_rout37
		dc.l	things_rout38
		dc.l	things_rout39
		dc.l	things_rout40
		dc.l	things_rout41
		dc.l	things_rout42
		dc.l	things_rout43
		dc.l	things_rout44
		dc.l	things_rout45
		dc.l	things_rout46
		dc.l	things_rout47
		dc.l	things_rout48
		dc.l	things_rout49
		dc.l	things_rout50
		dc.l	things_rout51
		dc.l	things_rout52
		dc.l	things_rout53
		dc.l	things_rout54
		dc.l	things_rout55
		dc.l	things_rout56
		dc.l	things_rout57
		dc.l	things_rout58
		dc.l	things_rout59
		dc.l	things_rout60
		dc.l	things_rout61
		dc.l	things_rout62
		dc.l	things_rout63
		dc.l	things_rout64
		dc.l	things_rout65
		dc.l	things_rout66
		dc.l	things_rout67
		dc.l	things_rout68
		dc.l	things_rout69
		dc.l	things_rout70
		dc.l	things_rout71
		dc.l	things_rout72
		dc.l	things_rout73
		dc.l	things_rout74
		dc.l	things_rout75
		dc.l	things_rout76
		dc.l	things_rout77
		dc.l	things_rout78
		dc.l	things_rout79
		dc.l	things_rout80
		dc.l	things_rout81
		dc.l	things_rout82

;---------------

; diese routinen werden ausgefuehrt, wenn
; ein bereits aufgenommener gegenstand
; mit <enter> aktiviert wird

pl_action_routs:

                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	th_action_09
		dc.l	th_action_10
		dc.l	th_action_11
		dc.l	th_action_12
		dc.l	th_action_13
		dc.l	0
		dc.l	0
		dc.l	0		; 16
		dc.l	0	
		dc.l	th_action_18
		dc.l	th_action_19
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 23
		dc.l	th_action_24
		dc.l	th_action_25
		dc.l	th_action_26
		dc.l	0
		dc.l	th_action_28
		dc.l	th_action_29	; 29
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 33
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 37
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0	; th_action_41
		dc.l	0
		dc.l	th_action_43
		dc.l	0
		dc.l	0		; 45
		dc.l	th_action_46
		dc.l	0
		dc.l	0
		dc.l	0		; 49
		dc.l	0
		dc.l	0		; 51
		dc.l	0
		dc.l	0		; 53 (zuender)
		dc.l	0
		dc.l	0		; 55
		dc.l	th_action_56	; 56 (general invulnerability)
		dc.l	th_action_57	; 57 (general invisibility)
		dc.l	0
		dc.l	0
		dc.l	0		; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 66
		dc.l	0
		dc.l	th_action_68
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 81
		dc.l	0

;---------------

; diese routinen werden ausgefuehrt, wenn
; ein bereits aufgenommener gegenstand
; mit <enter> deaktiviert wird

pl_deaction_routs:

                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	th_deaction_09
		dc.l	th_deaction_10
		dc.l	th_deaction_11
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 16
		dc.l	0	
		dc.l	th_deaction_18
		dc.l	th_deaction_19
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 23
		dc.l	th_deaction_24
		dc.l	th_deaction_25
		dc.l	0
		dc.l	0
		dc.l	th_deaction_28
		dc.l	th_deaction_29	; 29
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 33
		dc.l	0		
		dc.l	0
		dc.l	0
		dc.l	0		; 37
		dc.l	0		
		dc.l	0
		dc.l	0
		dc.l	0	; th_deaction_41
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 45
		dc.l	th_deaction_46
		dc.l	0
		dc.l	0
		dc.l	0		; 49
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 53 (zuender)
		dc.l	0
		dc.l	0		; 55
		dc.l	th_deaction_56
		dc.l	th_deaction_57
		dc.l	0
		dc.l	0
		dc.l	0		; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 66
		dc.l	0
		dc.l	th_deaction_68
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 81
		dc.l	0

;---------------

need_things_ptr:
                DC.L 	need_01_txt
                DC.L 	need_02_txt
                DC.L 	need_03_txt
                DC.L 	need_04_txt
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	0
                DC.L 	need_09_txt
		dc.l	0
		dc.l	need_11_txt
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 15
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 19
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 23
		dc.l	need_24_txt
		dc.l	need_25_txt
		dc.l	need_26_txt
		dc.l	0
		dc.l	0
		dc.l	0		; 29
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 33
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 37
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	need_41_txt
		dc.l	0		; 42
		dc.l	need_43_txt
		dc.l	0
		dc.l	0		; 45
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 49
		dc.l	0
		dc.l	0		; 51
		dc.l	need_52_txt
		dc.l	need_53_txt
		dc.l	need_54_txt
		dc.l	need_55_txt
		dc.l	0
		dc.l	0		; 57
		dc.l	0
		dc.l	0
		dc.l	0		; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 64
		dc.l	0
		dc.l	0		; 66
		dc.l	need_67_txt
		dc.l	need_68_txt
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	need_80_txt
		dc.l	need_81_txt	; 81
		dc.l	0

need_01_txt	dc.b	"YOU NEED THE RED KEY ...",0
need_02_txt	dc.b	"YOU NEED THE GREEN KEY ...",0
need_03_txt	dc.b	"YOU NEED THE BLUE KEY ...",0
need_04_txt	dc.b	"YOU NEED THE YELLOW KEY ...",0
need_09_txt	dc.b	"YOU NEED THE ULTRA-SCANNER",0
need_11_txt	dc.b	"YOU NEED THE GAS MASK ...",0
need_24_txt	dc.b	"YOU NEED THE RADIATION SUIT",0
need_25_txt	dc.b	"YOU NEED THE GEIGER COUNTER",0
need_26_txt	dc.b	"YOU NEED THE JETPACK ...",0
need_41_txt	dc.b	"YOU NEED THE WELDING TORCH ...",0
need_43_txt	dc.b	"YOU NEED THE TOXIC SUBSTANCE",0
need_52_txt	dc.b	"YOU NEED THE DYNAMITE ...",0
need_53_txt	dc.b	"YOU NEED THE DETONATOR ...",0
need_54_txt	dc.b	"PRIMARY MISSION NOT COMPLETED",0
need_55_txt	dc.b	"SECONDARY MISSION NOT COMPLETED",0
need_67_txt	dc.b	"YOU NEED THE BIER-MUG ...",0
need_68_txt	dc.b	"YOU NEED THE TRAIN DETECTOR ...",0
need_80_txt	dc.b	"YOU NEED A CONDOM ...",0
need_81_txt	dc.b	"YOU NEED THE ID-CARD ...",0
		even

; diese texte werden angezeigt, wenn
; der gegenstand aufgenommen wird

things_txt_ptr: DC.L 	things_txt01
                DC.L 	things_txt02
                DC.L 	things_txt03
                DC.L 	things_txt04
                DC.L 	things_txt05
                DC.L 	things_txt06
                DC.L 	things_txt07
                DC.L 	things_txt08
                DC.L 	things_txt09
		dc.l	things_txt10
		dc.l	things_txt11
		dc.l	things_txt12
		dc.l	things_txt13
		dc.l	things_txt14
		dc.l	things_txt15
		dc.l	things_txt16
		dc.l	things_txt17
		dc.l	things_txt18
		dc.l	things_txt19
		dc.l	things_txt20
		dc.l	things_txt21
		dc.l	things_txt22
		dc.l	things_txt23
		dc.l	things_txt24
		dc.l	things_txt25
		dc.l	things_txt26
		dc.l	things_txt27
		dc.l	things_txt28
		dc.l	things_txt29
		dc.l	things_txt30
		dc.l	things_txt31
		dc.l	things_txt32
		dc.l	things_txt33
		dc.l	0			; th_opendoor
		dc.l	0			; th_openlift
		dc.l	0
		dc.l	0			
		dc.l	0			; th_teleporter
		dc.l	0			; th_cameraview
		dc.l	0			; th_terminal
		dc.l	things_txt41
		dc.l	things_txt42
		dc.l	things_txt43
		dc.l	0
		dc.l	0			; th_sample
		dc.l	things_txt46		; th_littleplan
		dc.l	0
		dc.l	0
		dc.l	0			; 49
		dc.l	0
		dc.l	0
		dc.l	things_txt52
		dc.l	things_txt53
		dc.l	things_txt54
		dc.l	things_txt55
		dc.l	things_txt56
		dc.l	things_txt57
		dc.l	0
		dc.l	0
		dc.l	0			; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0			; 66
		dc.l	things_txt67
		dc.l	things_txt68
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0			; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	things_txt80
		dc.l	things_txt81
		dc.l	0

things_txt01:   DC.B 	"RED KEY FOUND",0
things_txt02:   DC.B 	"GREEN KEY FOUND",0
things_txt03:   DC.B 	"BLUE KEY FOUND",0
things_txt04:   DC.B 	"YELLOW KEY FOUND",0
things_txt05:   DC.B 	"AMMO FOR PISTOL FOUND",0
things_txt06:   DC.B 	"AMMO FOR SHOTGUN FOUND",0
things_txt07:   DC.B 	"AMMO FOR MACHINEGUN FOUND",0
things_txt08:   DC.B 	"AMMO FOR FLAME-THROWER FOUND",0
things_txt09:   DC.B 	"ULTRA-SCANNER FOUND",0
things_txt10:	dc.b	"NIGHTVIEWER FOUND",0
things_txt11	dc.b	"GAS MASK FOUND",0
things_txt12	dc.b	"SMALL MEDIKIT FOUND",0
things_txt13	dc.b	"BIG MEDIKIT FOUND",0
things_txt14	dc.b	"SMALL MEDIKIT FOUND",0
things_txt15	dc.b	"BIG MEDIKIT FOUND",0
things_txt16	dc.b	"SMALL SHIELD BONUS",0
things_txt17	dc.b	"BIG SHIELD BONUS",0
things_txt18	dc.b	"INVULNERABILITY FOUND",0
things_txt19	dc.b	"INVISIBILITY FOUND",0
things_txt20	dc.b	"PISTOL FOUND",0
things_txt21	dc.b	"SHOTGUN FOUND",0
things_txt22	dc.b	"MACHINEGUN FOUND",0
things_txt23	dc.b	"FLAME-THROWER FOUND",0
things_txt24	dc.b	"RADIATION SUIT FOUND",0
things_txt25	dc.b	"GEIGER COUNTER FOUND",0
things_txt26	dc.b	"JETPACK FOUND",0
things_txt27	dc.b	"BACKPACK FOUND",0
things_txt28	dc.b	"MONSTER DETECTOR FOUND",0
things_txt29	dc.b	"FULL PLAN FOUND",0
things_txt30	dc.b	"AMMO FOR PISTOL FOUND",0
things_txt31	dc.b	"AMMO FOR SHOTGUN FOUND",0
things_txt32	dc.b	"AMMO FOR MACHINEGUN FOUND",0
things_txt33	dc.b	"AMMO FOR FLAME-THROWER FOUND",0
things_txt41	dc.b	"WELDING TORCH FOUND",0
things_txt42	dc.b	"TIME LIMIT DEACTIVATED",0
things_txt43	dc.b	"TOXIC SUBSTANCE FOUND",0
things_txt46	dc.b	"PLAN FOUND",0
things_txt52	dc.b	"DYNAMITE FOUND",0
things_txt53	dc.b	"DETONATOR FOUND",0
things_txt54	dc.b	"PRIMARY MISSION COMPLETED",0
things_txt55	dc.b	"SECONDARY MISSION COMPLETED",0
things_txt56	dc.b	"PERMANENT INVULNERABILITY FOUND",0
things_txt57	dc.b	"PERMANENT INVISIBILITY FOUND",0
things_txt67	dc.b	"BEER-MUG FOUND",0
things_txt68	dc.b	"TRAIN DETECTOR FOUND",0
things_txt80	dc.b	"CONDOM FOUND",0
things_txt81	dc.b	"ID-CARD FOUND",0
		even

;---------------

; meldungen, wenn gegenstand aktiviert wird

things_act_txt_ptr

		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	th_act_txt09
		dc.l	th_act_txt10
		dc.l	th_act_txt11
		dc.l	th_act_txt12
		dc.l	th_act_txt13
		dc.l	0
		dc.l	0		; 15
		dc.l	0
		dc.l	0
		dc.l	th_act_txt18
		dc.l	th_act_txt19
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 23
		dc.l	th_act_txt24
		dc.l	th_act_txt25
		dc.l	0
		dc.l	0
		dc.l	th_act_txt28
		dc.l	th_act_txt29	; 29
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 33
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		
		dc.l	0		; 38
		dc.l	0
		dc.l	0
		dc.l	0		; th_act_txt41
		dc.l	0		; 42
		dc.l	th_act_txt43
		dc.l	0
		dc.l	0		; 45
		dc.l	th_act_txt46
		dc.l	0
		dc.l	0
		dc.l	0		; 49
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 53
		dc.l	0
		dc.l	0
		dc.l	th_act_txt56
		dc.l	th_act_txt57
		dc.l	0
		dc.l	0
		dc.l	0		; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 66
		dc.l	0
		dc.l	th_act_txt68
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 81
		dc.l	0

th_act_txt09   	dc.b 	"ULTRA-SCANNER ACTIVATED",0
th_act_txt10	dc.b	"NIGHTVIEWER ACTIVATED",0
th_act_txt11	dc.b	"GAS MASK SET ON",0
th_act_txt12	dc.b	"ENERGY INCREASED",0
th_act_txt13	dc.b	"ENERGY INCREASED",0
th_act_txt18	dc.b	"INVULNERABILITY ACTIVATED",0
th_act_txt19	dc.b	"INVISIBILITY ACTIVATED",0
th_act_txt24	dc.b	"RADIATION SUIT PUT ON",0
th_act_txt25	dc.b	"GEIGER COUNTER ACTIVATED",0
th_act_txt28	dc.b	"MONSTER DETECTOR ACTIVATED",0
th_act_txt29	dc.b	"FULL PLAN ACTIVATED",0
th_act_txt41	dc.b	"WELDING TORCH ACTIVATED",0
th_act_txt43	dc.b	"TOXIC SUBSTANCE RELEASED",0
th_act_txt46	dc.b	"PLAN ACTIVATED",0
th_act_txt56	dc.b	"PERM. INVULNERABILITY ACT.",0
th_act_txt57	dc.b	"PERM. INVISIBILITY ACTIVATED",0
th_act_txt68	dc.b	"TRAIN DETECTOR ACTIVATED",0

		even

;---------------

; meldungen, wenn gegenstand deaktiviert wird

things_deact_txt_ptr

		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	th_deact_txt09
		dc.l	th_deact_txt10
		dc.l	th_deact_txt11
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 15
		dc.l	0
		dc.l	0
		dc.l	th_deact_txt18
		dc.l	th_deact_txt19
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 23
		dc.l	th_deact_txt24
		dc.l	th_deact_txt25
		dc.l	0
		dc.l	0
		dc.l	th_deact_txt28
		dc.l	th_deact_txt29	; 29
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 33
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 37
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; th_deact_txt41
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 45
		dc.l	th_deact_txt46
		dc.l	0
		dc.l	0
		dc.l	0		; 49
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 53
		dc.l	0
		dc.l	0
		dc.l	th_deact_txt56
		dc.l	th_deact_txt57
		dc.l	0
		dc.l	0
		dc.l	0		; 60
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 66
		dc.l	0
		dc.l	th_deact_txt68
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 76
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0
		dc.l	0		; 81
		dc.l	0

th_deact_txt09	dc.b	"ULTRA-SCANNER DEACTIVATED",0
th_deact_txt10	dc.b	"NIGHTVIEWER DEACTIVATED",0
th_deact_txt11	dc.b	"GAS MASK TAKEN OFF",0
th_deact_txt18	dc.b	"INVULNERABILITY DEACTIVATED",0
th_deact_txt19	dc.b	"INVISIBILITY DEACTIVATED",0
th_deact_txt24	dc.b	"RADIATION SUIT TAKEN OFF",0
th_deact_txt25	dc.b	"GEIGER COUNTER DEACTIVATED",0
th_deact_txt28	dc.b	"MONSTER DETECTOR DEACTIVATED",0
th_deact_txt29	dc.b	"FULL PLAN DEACTIVATED",0
th_deact_txt41	dc.b	"WELDING TORCH DEACTIVATED",0
th_deact_txt46	dc.b	"PLAN DEACTIVATED",0
th_deact_txt56	dc.b	"PERM. INVULNERABILITY DEACT.",0
th_deact_txt57	dc.b	"PERM. INVISIBILITY DEACTIVATED",0
th_deact_txt68	dc.b	"TRAIN DETECTOR DEACTIVATED",0

		even

;---------------

pl_left_routines
		dc.l	pl_scanner,th_scanner
		dc.l	pl_geiger,th_geigercount
		dc.l	0

;---------------

th_time_limits: DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	-1
                DC.W 	$7FFF		; th_scanner
		dc.w	-1
		dc.w	-1		; th_mask
		dc.w	-1
		dc.w	-1		; 13
		dc.w	-1		; 14
		dc.w	-1		; 15
		dc.w	-1
		dc.w	-1
		dc.w	$7fff		; th_invul
		dc.w	$7fff		; th_invis
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 23
		dc.w	$7fff		; th_radsuit
		dc.w	$7fff		; th_geigercounter
		dc.w	-1		; th_jetpack
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 29
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 33
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 37
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 41
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 45
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 49
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 53
		dc.w	-1
		dc.w	-1
		dc.w	-1		; th_geninvul
		dc.w	-1		; th_geninvis
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 60
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 66
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 76
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1		; 81
		dc.w	-1

;---------------

; angabe fuer time_speed

;  0 = 650 sek
;  1 = 327 sek
;  2 = 163 sek
;  3 =  82 sek
;  4 =  41 sek
;  5 =  20 sek

th_time_speed
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; th_scanner
		dc.w	0		; 10
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	4		; th_invul
		dc.w	4		; th_invis
		dc.w	0		; 20
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	1		; th_radsuit
		dc.w	0		; th_geigercount
		dc.w	0		; th_jetpack
		dc.w	0
		dc.w	0
		dc.w	0		; 29
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 33
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 37
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	3		; 41
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 45
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 49
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 53
		dc.w	0
		dc.w	0		; 55
		dc.w	0
		dc.w	0		; 57
		dc.w	0
		dc.w	0
		dc.w	0		; 60
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 66
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 76
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0
		dc.w	0		; 81
		dc.w	0

;**************************************
;* schussanimation
;**************************************

; schussanimation (virtuelle gegenstaende)

as_thing	dc.l	as_thing0
		dc.l	as_thing1
		dc.l	as_thing2
		dc.l	as_thing3

as_thing0	dc.l	0,0				; position (x/y)
		dc.l	$00ff00,$006300,$000000		; lineflags
as_thing1	dc.l	0,0				; position (x/y)
		dc.l	$00ff00,$006300,$000000		; lineflags
as_thing2	dc.l	0,0				; position (x/y)
		dc.l	$00ff00,$006300,$000000		; lineflags
as_thing3	dc.l	0,0				; position (x/y)
		dc.l	$00ff00,$006300,$000000		; lineflags


;**************************************
;* sonstige meldungen
;**************************************

sm_follow_on	dc.b	"FOLLOW MODE ON",0
sm_follow_off	dc.b	"FOLLOW MODE OFF",0
sm_sh_on	dc.b	"HEIGHT MODE ON",0
sm_sh_off	dc.b	"HEIGHT MODE OFF",0
sm_timelimit	dc.b	"TIMELIMIT ACTIVATED",0
sm_civilian	dc.b	"CIVILIAN HIT",0
sm_press_esc	dc.b	"PRESS ESCAPE",0
sm_press_tab	dc.b	"PRESS TABULATOR",0
sm_share	dc.b	13,"RUNNING FULL RELEASE 1997",0
sm_no_fuel	dc.b	"NO FUEL ...",0
sm_save		dc.b	"YOU MUST STAY AT A TERMINAL",13
		dc.b	"TO SAVE A GAME ...",0
sm_prim_not	dc.b	"PRIMARY MISSION NOT COMPLETED",0
sm_sec_not	dc.b	"SECONDARY MISSION NOT COMPLETED",0
sm_run_mode_on	dc.b	"RUN MODE ON",0
sm_run_mode_off	dc.b	"RUN MODE OFF",0
sm_quickstart	dc.b	27,69,13,10,13,10
		dc.b	27,112
		dc.b	"RUNNING QUICK MENU",27,113,13,10,13,10
		dc.b	"PRESS",13,10
		dc.b	"  (M) NO MUSIC IN THE INTRO",13,10
		dc.b	"  (D) ACTIVATE DOUBLE VBL-FIX",13,10
		dc.b	"  (B) NO MUSIC/ACTIVATE DOUBLE VBL-FIX",13,10,13,10
		dc.b	"... AND ANY OTHER KEY TO START!",13,10,0

sm_out_of_ammo	dc.b	"OUT OF AMMO",0

sm_mxalloc_1	dc.b	27,69,13,10,13,10
		dc.b	"Could not allocate memory",13,10
		dc.b	"for screens (ST-RAM).",13,10,13,10,0
sm_mxalloc_2	dc.b	27,69,13,10,13,10
		dc.b	"Could not allocate memory",13,10
		dc.b	"for samples (ST-RAM).",13,10,13,10,0
sm_mxalloc_3	dc.b	27,69,13,10,13,10
		dc.b	"Could not allocate memory",13,10
		dc.b	"for internal samples (ST-RAM).",13,10,13,10,0
sm_mxalloc	dc.b	"At all RUNNING needs about 3.8 MB",13,10
		dc.b	"of free RAM (of that 0.8 MB ST-RAM).",13,10
		dc.b	"Please reboot your computer and",13,10
		dc.b	"make sure you have enough free RAM,",13,10
		dc.b	"i. e. boot your computer without",13,10
		dc.b	"any accessories or programmes in",13,10
		dc.b	"the auto-folder...",13,10,13,10
		dc.b	"Press any key to quit.",13,10,0
 
sm_scde		dc.b	"ERROR: SC_DELETE_ENTRY",0

sm_registry	dc.b	"B. "
sm_registry_nm	dc.b	"GATES IS BACK",0,0,0

sm_switch	dc.b	"SWITCH TO FULL CONSOLE MODE",0
		even


;**************************************
;* episodeend_text
;**************************************

episodeend_text	dc.l	et_1
		dc.l	et_2

et_1		
		dc.b	13,13,13,13,13,13,13
	; ---------------01234567890123456789012345678901234567890------------
		dc.b	"      hey agent, congratulations.",13
		dc.b	"      that was not your last mission...",13,13,13,13
		dc.b	13,13,13,13,13,13,13,13,13,13,13
		dc.b	"                 game over",0

et_2		
		dc.b	13,13,13,13,13,13,13
	; ---------------01234567890123456789012345678901234567890------------
		dc.b	"  what a deal!",13
		dc.b	"  enjoy the hawaii trip and the girls...",13,13,13,13
		dc.b	13,13,13,13,13,13,13,13,13,13,13
		dc.b	"                 game over",0

		even

;**************************************
;* staerken
;**************************************

mon_staerke_tab
		;dc.w	4,6,8,12,16,20,24,48
		dc.w	4,6,7,8,14,18,25,40

player_staerke_tab
		dc.w	1,2,4,6,12

sf_staerke_tab
		dc.w	4*256/50
		dc.w	6*256/50
		dc.w	10*256/50
		dc.w	20*256/50
		dc.w	30*256/50
		dc.w	40*256/50
		dc.w	50*256/50
		dc.w	-1		; stirbt sofort ...

civilian_staerke_tab
		;dc.w	4,8,12,16,24,32,40,48
		dc.w	4,6,7,8,10,12,20,40

;**************************************
;* grafix
;**************************************

things_gfx:     incbin 	"tpi\things.tpi"
leiste_gfx:     incbin	"tpi\console.tpi"

kartback_pic:   incbin	"tpi\back_002.tpi"

 
;**************************************
;* font
;**************************************

menufont_offi	equ	656*2

font		incbin	"fnt\fn_8x8-2.fnt"
font4x8		incbin	"fnt\fn_4x8-3.fnt"
font4x5		incbin	"fnt\fn_4x5.fnt"
menufont	incbin	"tpi\menufont.tpi"
menufont_end

mm_options_file	dc.b	"running.inf",0
		even

;**************************************
;* fehlermeldungen
;**************************************

stop_system_txt	
		dc.l	sst01
		dc.l	sst02
		dc.l	sst03
		dc.l	sst04
		dc.l	sst05
		dc.l	sst06
		dc.l	sst07
		dc.l	sst08

sst01		dc.b	"CREATING FOLDER FAILED.",0
sst02		dc.b	"OPENING FILE FAILED.",0
sst03		dc.b	"READING FILE FAILED.",0
sst04		dc.b	"CLOSING FILE FAILED.",0
sst05		dc.b	"SAVING FILE FAILED.",0
sst06		dc.b	"CREATING FILE FAILED.",0
sst07		dc.b	"OPENING LEVEL FAILED.",0
sst08		dc.b	"BINARY ACCESS FAILED.",0
		even

sst_data
		dc.l	640*80+40*2
		dc.l	sst_d0
		dc.l	640*105+40*2
		dc.l	sst_d1
		dc.l	640*130+40*2
		dc.l	sst_d2

sst_d0		dc.b	"AN ERROR OCCURED:",0
sst_d1		dc.b	"FILE:",0
sst_d2		dc.b	"SYSTEM STOPPED...",0
		even

sst_message	dc.l	0
sst_code	dc.w	0
sst_code_anz	dc.w	8
sst_position	dc.l	640*95+40*2		; fuer errornachricht


;**************************************
;* samples
;**************************************

; tabellenformat: zeiger auf anfang, laenge, frequenzzahl

samples
		ifeq mxalloc_flag

		dc.l	sam_s0,sam_s1-sam_s0,19		; jump
		dc.l	sam_s1,sam_s2-sam_s1,19		; footer
		dc.l	sam_s2,sam_s3-sam_s2,19		; pistol1
		dc.l	sam_s3,sam_s4-sam_s3,19		; pistol2
		dc.l	sam_s4,sam_s5-sam_s4,19		; open
		dc.l	sam_s5,sam_s6-sam_s5,19		; item
		dc.l	sam_s6,sam_s7-sam_s6,19		; locked
		dc.l	sam_s7,sam_s8-sam_s7,19		; menue 1
		dc.l	sam_s8,sam_s9-sam_s8,19		; menue 2
		dc.l	sam_s9,sam_s10-sam_s9,19	; menue 3
		dc.l	sam_s10,sam_s11-sam_s10,19	; menue 4
		dc.l	sam_s11,sam_s12-sam_s11,19	; menue 5
		dc.l	sam_s12,sam_s13-sam_s12,19	; menue 6
		dc.l	sam_s13,sam_s14-sam_s13,19	; laptop (tastatur)
		dc.l	sam_s14,sam_s15-sam_s14,19	; teleporter
		dc.l	sam_s15,sam_s16-sam_s15,19	; eingerastet
		dc.l	0,0,0
		dc.l	0,0,0
		dc.l	0,0,0
		dc.l	0,0,0
		dc.l	sam_s20,sam_s21-sam_s20,19	; adrian
		dc.l	sam_s21,sam_s22-sam_s21,19	; diehard
		dc.l	sam_s22,sam_s23-sam_s22,19	; hasta
		dc.l	sam_s23,sam_s24-sam_s23,19	; asses
		dc.l	sam_s24,sam_s25-sam_s24,19	; bored
		dc.l	dith_data,12931,19		; adios
		dc.l	dith_data+12931,7316,19		; welldone
		dc.l	dith_data+20247,9798,19		; yipi
		dc.l	sam_s28,sam_s29-sam_s28,19	; dope
		dc.l	sam_s29,sam_s30-sam_s29,19	; good
		dc.l	sam_s30,sam_s31-sam_s30,19	; like
		dc.l	sam_s31,sam_s32-sam_s31,19	; dont
		dc.l	sam_s32,sam_s33-sam_s32,19	; nice
		dc.l	sam_s33,sam_s34-sam_s33,19	; check
		dc.l	sam_s34,sam_s35-sam_s34,19	; ahh
		dc.l	sam_s35,sam_s36-sam_s35,19	; arghh
		dc.l	sam_s36,sam_s37-sam_s36,19	; cool

		dc.l	sam_s37,sam_s38-sam_s37,19	; ubahn

sam_s0          incbin	"samples\player\jump.sam"
sam_s1          incbin	"samples\player\footer.sam"
sam_s2          incbin	"samples\player\pistol1.sam"
sam_s3          incbin	"samples\player\pistol2.sam"
sam_s4          incbin	"samples\misc\open5.sam"
sam_s5          incbin	"samples\misc\get.sam"
sam_s6          incbin	"samples\misc\locked.sam"
sam_s7		incbin	"samples\menu\mnuon.sam"
sam_s8		incbin	"samples\menu\mnuoff.sam"
sam_s9		incbin	"samples\menu\mnuclick.sam"
sam_s10		incbin	"samples\menu\mnuright.sam"
sam_s11		incbin	"samples\menu\mnuleft.sam"
sam_s12		incbin	"samples\menu\mnuchoos.sam"
sam_s13		incbin	"samples\computer\tasta030.sam"
sam_s14		incbin	"samples\misc\teleporter.sam"
sam_s15		incbin	"samples\misc\eingeras.sam"
sam_s16

; "Angriff"-Samples
sam_s20		incbin	"samples\angriff\adrian3.sam"
sam_s21		incbin	"samples\angriff\diehard.sam"
sam_s22		incbin	"samples\angriff\hasta.sam"

; "Boring"-Samples
sam_s23		incbin	"samples\boring\asses.sam"
sam_s24		incbin	"samples\boring\bored.sam"
sam_s25		

; "Medizin"-Samples
sam_s28		incbin	"samples\medizin\dope.sam"
sam_s29		incbin	"samples\medizin\good2.sam"
sam_s30		incbin	"samples\medizin\like.sam"

; "Waffe"-Samples
sam_s31		incbin	"samples\waffe\dont.sam"
sam_s32		incbin	"samples\waffe\nice.sam"
sam_s33		incbin	"samples\waffe\check2.sam"

; "Other"-Samples
sam_s34		incbin	"samples\other\ahh.sam"
sam_s35		incbin	"samples\other\arghh.sam"
sam_s36		incbin	"samples\other\cool.sam"

sam_s37		incbin	"samples\misc\ubahn.sam"
sam_s38

sam_end
		even

		else

		dc.l	0,3008,19		; 0
		dc.l	0,2265,19		; 1
		dc.l	0,2553,19		; 2
		dc.l	0,16470,19		; 3
		dc.l	0,12171,19		; 4
		dc.l	0,1845,19		; 5
		dc.l	0,3089,19
		dc.l	0,2800,19
		dc.l	0,2672,19
		dc.l	0,468,19
		dc.l	0,1939,19		; 10
		dc.l	0,2058,19
		dc.l	0,8480,19
		dc.l	0,804,19
		dc.l	0,7038,19
		dc.l	0,6158,19		; 15
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,11807,19		; 20
		dc.l	0,6268,19
		dc.l	0,11806,19
		dc.l	0,12515,19
		dc.l	0,22683,19
		dc.l	0,-12931,19		; 25
		dc.l	0,-7316,19
		dc.l	0,-9798,19
		dc.l	0,14194,19
		dc.l	0,19108,19
		dc.l	0,8926,19		; 30
		dc.l	0,10788,19
		dc.l	0,9917,19
		dc.l	0,6730,19
		dc.l	0,3904,19
		dc.l	0,7490,19		; 35
		dc.l	0,21848,19
		dc.l	0,6318,19
		dc.l	0,-14461,19		; 38
		dc.l	0,-63098,19
		dc.l	-1

		endc

;---------------

loadsave_pic	dc.b	"data\pictures\loadsave.pct",0
syserror_pic	dc.b	"data\pictures\syserror.pct",0
arrow_pic	dc.b	"data\pictures\arrow.pct",0
help_pic	dc.b	"data\pictures\help.pct",0
ml_file		dc.b	"data\pictures\laptop20.pct",0
mt_file		dc.b	"data\pictures\laptop20.pct",0
startdlg_file	dc.b	"data\pictures\startdlg.pct",0
quitdlg_file	dc.b	"data\pictures\quitdlg.pct",0

menu_file	dc.b	"temp\menu.dat",0
intsam_file	dc.b	"data\samples\sampack1.dat",0
endsam_file	dc.b	"data\samples\sampack2.dat",0
		even
registry_file	dc.b	"registry.inf",0

		even

;---------------

		include "include\ueber1.s"


;**************************************
;* paint
;**************************************

screen:         DC.L 0
screen_x:       DC.L 0

;**************************************
;* registry
;**************************************

registry_was_done	dc.w	0
registry_length		dc.w	registry_get_name_end-registry_get_name
registry_checksum	dc.w	$d46e

;**************************************
;* several
;**************************************

init_file	dc.b	"DATA\PICTURES\"
init_file_modi	dc.b	0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0

eend_file_1	dc.b	"data\finals\final1.pct",0
eend_file_2	dc.b	"data\finals\final2.pct",0

		even

;**************************************
;* loadsave
;**************************************

; speicherbereich, der beim level laden/speichern
; zu beruecksichtigen ist

loadsave_start

vsync_flag	dc.w	0

text_address	dc.l	0

;---

shoot		dc.l	0
shooted_mon	ds.l	monsters_max

;---

; paint_pistol


pp_flag		dc.w	0
pp_data_ok	dc.w	0

pp_pos:		dc.w	0
pp_xoffset:	dc.w	0
pp_yoffset:	dc.w	0
pp_zoom:	dc.l	0
pp_zoomx	dc.l	0
pp_zoom_12:	dc.w	0

pp_screen_end:	dc.l	0
pp_breite_z:	dc.w	0
pp_hoehe_z:	dc.w	0

pp_animstufe	dc.w	0

pp_last_width	dc.w	0
pp_last_heigth	dc.w	0

pp_startyline	dc.l	0

pp_anim2_time	dc.w	0,10
pp_anim3_time	dc.w	0,20
pp_anim4_time	dc.w	0,20

pp_number_sht	dc.w	0,1			; anzahl schuss pro reload

has_turned	dc.w	0

;---

; paint_leiste

pl_leiste_act	ds.w	things_max		

pl_console_mode	dc.w	0
pl_display_flag	dc.w	0
pl_must_copy	dc.w	0

;---

pl_scan_radius	dc.w	0

pl_scan_mon_anz	dc.w	0
pl_scan_mon_ptr	ds.w	monsters_max*2

pl_small	dc.w	0

;---

pl_left_nb	dc.w	-1		; nummer der routine
pl_txt		dc.l	0

;---

; reihenfolge beachten ...

plg_real_pos	dc.w	0
plg_act_pos	dc.w	0
plg_to_pos	dc.w	0

;---

pl_mun_last	dc.w	0

pl_mun0_last	dc.w	0
pl_mun1_last	dc.w	0
pl_mun2_last	dc.w	0
pl_mun3_last	dc.w	0
pl_mun4_last	dc.w	0

pl_vmun_last	dc.w	0

pl_vmun0_last	dc.w	0
pl_vmun1_last	dc.w	0
pl_vmun2_last	dc.w	0
pl_vmun3_last	dc.w	0
pl_vmun4_last	dc.w	0

pl_munx0_last	dc.w	0
pl_munx1_last	dc.w	0
pl_munx2_last	dc.w	0
pl_munx3_last	dc.w	0
pl_munx4_last	dc.w	0

;---

play_dat_p0	ds.b	2048

play_thg_p0	ds.l	things_max

xwindow_min:    DC.W 64
xwindow_max:    DC.W 192
ywindow_min:    DC.W 40
ywindow_max:    DC.W 200

max_trains:     DC.W 0
nb_of_trains:   DC.L 0
trains_aktive:  DC.W %0000000000000000
trains_visible: DC.W %0000000000000000

;---

dont_change_scr	dc.w	0
double_scan	dc.w	0
wide_screen	dc.w	0
cinemascope	dc.w	0
ds_vor_karte	dc.w	0
cine_vor_karte	dc.w	0
true_vor_karte	dc.l	0

;---

screen_x_norm		dc.w 	0
screen_y_norm		dc.w	0
screen_flag_norm	dc.w 	0

screen_x_full		dc.w	0
screen_y_full		dc.w	0

screen_x_cine		dc.w	0
screen_y_cine		dc.w	0
screen_flag_cine	dc.w	0

screen_x_cifu		dc.w	0
screen_y_cifu		dc.w	0

;---------------

an_doors_flag:  DS.W 1
an_doors_ptr:   DS.L anim_doors_max

;---

an_lifts_flag:  DS.W 1
an_lifts_ptr:   DS.L anim_lifts_max

;---------------

sh_last		dc.l	0

;---------------

dsp_error_flag	dc.w	0

;---------------

sc_stack_pos	dc.w	0
sc_stack	ds.w	32
sc_load_flag	dc.w	0


loadsave_end


;**************************************
;* scan_to_ascii_tab
;**************************************

scan_to_ascii_tab

		dc.b	0,0
		dc.b	0,0
		dc.b	"1!"		; 02
		dc.b	"2",34
		dc.b	"3",0
		dc.b	"4$"
		dc.b	"5%"
		dc.b	"6&"
		dc.b	"7/"
		dc.b	"8("
		dc.b	"9)"		; 0a
		dc.b	"0="
		dc.b	0,"?"
		dc.b	"'",0
		dc.b	8,0		; 0e
		dc.b	0,0
		dc.b	"qQ"
		dc.b	"wW"
		dc.b	"eE"
		dc.b	"rR"
		dc.b	"tT"
		dc.b	"zZ"
		dc.b	"uU"
		dc.b	"iI"
		dc.b	"oO"
		dc.b	"pP"
		dc.b	0,0
		dc.b	0,0		; 1b
		dc.b	13,0
		dc.b	0,0
		dc.b	"aA"
		dc.b	"sS"
		dc.b	"dD"
		dc.b	"fF"
		dc.b	"gG"
		dc.b	"hH"
		dc.b	"jJ"
		dc.b	"kK"
		dc.b	"lL"
		dc.b	0,0
		dc.b	0,0		; 28
		dc.b	"#",0
		dc.b	0,0		; 2a
		dc.b	0,0
		dc.b	"yY"
		dc.b	"xX"
		dc.b	"cC"
		dc.b	"vV"
		dc.b	"bB"
		dc.b	"nN"
		dc.b	"mM"
		dc.b	",;"
		dc.b	".:"
		dc.b	"-_"		; 35
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0		; 38
		dc.b	" ",0
		dc.b	0,0
		dc.b	0,0		; 3b (F1)
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0
		dc.b	0,0		; 44 (F10)
		ds.b	59*2

;---

video_data	ds.b	34

;---------------

zufall_256_tab	
		include	"include\zuf256.s"

		include	"include\levfiles.s"



;***********************************************************
;***********************************************************




                BSS

bss_start:

;---------------

sam_leer	ds.b	max_play_buffer
nullbuffer:     DS.B 	max_play_buffer*2*2
play_buffer1:   DS.B 	max_play_buffer*2*2
play_buffer2:   DS.B 	max_play_buffer*2*2
play_buffer_end:

		ds.b	1024

;---------------

episode		ds.b	4

;---------------

mon_buf1_anz:   DS.W 1
mon_buf2_anz:   DS.W 1

mon_send_buf1:  DS.L monsters_max
mon_send_buf2:  DS.L monsters_max

fvm_secs:       DS.W vis_sectors_max

;---

an_mon_dat_tmp: DS.W 5
an_mon_pts_tmp: DS.L 2
an_mon_alp_tmp: DS.W 1
an_mon_sh_tmp:  DS.W 1

an_mon_real_al: DS.W 1

an_mon_new_sec: DS.W 1
an_mon_new_dir: DS.W 1
an_mon_new_lin: DS.W 1
an_mon_new_dis: DS.W 1

tmp:            DS.W 1

;---------------

; message_maker

mes_buf1	ds.l	1
mes_time1	ds.w	1
mes_clearflag1	ds.w	1

mes_buf2	ds.l	1
mes_time2	ds.w	1
mes_clearflag2	ds.w	1

;---------------

dv_hbl_cnt	ds.l	1

;---------------
                ;>PART 'main_midi_buf'
;main_midi_buf:
                DS.L 1          ; figur 0 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 1 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 2 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 3 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

main_midi_buf_end:
                ;ENDPART

                ;>PART 'test_position_routs'

;---

which_side_mem: DS.L 14

;---

                ;ENDPART

                ;>PART 'walking_data'

walking_data:   DS.W 32*4

                ;ENDPART
                ;>PART 'karte'

karte_modus:    DS.W 1          ; truecolor oder 16 farben ...
figur_data_buf: DS.L 4

                ;ENDPART
                ;>PART 'paint_leiste'

pl_thg_gfx_ptr: DS.L 1
pl_thg_indizes: DS.W 4

;---------------

midi_rout_ptr:  DS.L 1

dsp_puffer	ds.b	48000

truecolor_tab:  ds.b	32768*2*8

mouse_pos:      DS.B 8
key:            DS.W 1
midi:           DS.W 1
save_mfp:       DS.L 6
save_system:    DS.L 9
black:          DS.L 8

menue_anim_ptr	ds.l	1
menue_anim_buf	ds.w	16*16

;---------------

pistol_lines:	ds.l	128*4
pistol_offsets:	ds.w	128*4
pistol_pixel:	ds.w	128*4

pistol_data:	ds.b	70320


;---------------

lev_samples	ds.l	3*128

;---------------

; der speicherbereich fuer die texturen (dith_data) von der groesse 
; von 2 MB wird gleichzeitig als bss-bereich fuer das
; mainmenue genutzt ...

dith_data			
		ifne menueflag

		include	"include\menu\fire.bss"
		include	"include\menu\gouraud.bss"
		include	"include\menu\texture.bss"
		include	"include\menu\data.bss"

		include	"include\menu\parts\player.bss"

		endc

dith_data_end
		ds.b	256*256*2*14-(dith_data_end-dith_data)

		ifeq	compile_level
level		ds.b	level_max_gr
		endc
level_end

;---

		ifeq mxalloc_flag

		ds.b	256
		ds.b	128
screen_mem:	ds.b	153600
		ds.b	256
		ds.b	153600
		ds.b	256

samples_data	ds.b	mx_sample_len

		endc

bss_end:
                END
