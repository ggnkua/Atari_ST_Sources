
INSTALLS	equ	0



		text


; ---------------------------------------------------------
; level installieren
; an position level liegt ein neuer level zur
; neuinitialisierung bereit
installLevel
		move.l	#level,levelPtr

		bsr	ilSetDspGenau

		bsr	setColortableInit

		bsr	loadLevelFiles			; .\src\install.s

		bsr	ilSetPlayerStart
		bsr	ilSetWeapons

		bsr	ilResetMap

		bsr	ilResetConsole
		bsr	ilResetScanner
		bsr	ilResetGeiger
		bsr	ilResetAltTab

		bsr	setWeaponStrings		; .\src\things\wpnstrin.s

		rts


; ---------------------------------------------------------
; setzt die standard-farbtabelle (standard)
; initialisierung des colortable-stacks
; (muss vor dem laden der leveldateien aufgerufen werden)
setColortableInit
		clr.w	setColortableStackPos		; index des naechsten freien eintrags
		moveq	#0,d0
		bsr	setColortable

		rts


; ---------------------------------------------------------
; setzt die dsp-genauigkeit
; dsp-genauigkeit bei der milan-engine auf 16 fest
; eingestellt
ilSetDspGenau
		movea.l	playerDataPtr,a6
		move.w	#4,PDDSPEXPONENT(a6)
		move.l	#$112400*2,d1
		move.l	d1,PDINTERDIST1(a6)
		add.l	d1,d1
		move.l	d1,PDINTERDIST2(a6)

		rts


; ---------------------------------------------------------
; setzt die parameter der karte/map zurueck
; (zoomfaktor)
ilResetMap
		movea.l	playerDataPtr,a6
		move.w	#100,PDMAPZOOM(a6)
		rts


; ---------------------------------------------------------
; setzt den startpunkt des spielers.
ilSetPlayerStart
		movea.l	levelPtr,a6			; adresse des levels
		movea.l	LEVSTARTPOINT(a6),a0
		adda.l	a6,a0

		movea.l	playerDataPtr,a1

		move.l	STARTX(a0),PDSX(a1)
		move.l	STARTY(a0),PDSY(a1)
		move.l	STARTH(a0),d0			; sh und alpha sind im level .l, in interner
		move.w	d0,PDSH(a1)			; datenstruktur (playerdata) aber .w
		move.w	d0,PDSHREAL(a1)
		move.l	STARTALPHA(a0),d0
		move.w	d0,PDALPHA(a1)

		move.w	STARTSECTOR(a0),PDCURRENTSECTOR(a1)
		move.w	#-1,PDLASTSECTOR(a1)

		rts


; ---------------------------------------------------------
; 30.07.00/vk
; setzt dem spieler die korrekten waffen.
ilSetWeapons
		movea.l	levelPtr,a6
		movea.l	LEVINITLEVEL(a6),a0
		adda.l	a6,a0
		movea.l	ILEVWEAPONS(a0),a0
		adda.l	a6,a0

		movea.l	playerDataPtr,a5
		moveq	#0,d1

		moveq	#10-1,d0
ilswLoop	movea.l	(a0)+,a1
		adda.l	a6,a1

		clr.w	PDPISTOL0(a5,d1.w*2)			; waffe auf nicht vorhanden setzen
		clr.w	PDMUN0ANZ(a5,d1.w*2)			; aktuelle munitionsanzahl auf null setzen
		move.w	ILEVWPNMAX(a1),PDMUNX0ANZ(a5,d1.w*2)	; maximalanzahl an munition setzen

		tst.w	ILEVWPNSTARTFLAG(a1)
		beq.s	ilswNotAtStart

		move.w	#1,PDPISTOL0(a5,d1.w*2)
		move.w	ILEVWPNSTART(a1),PDMUN0ANZ(a5,d1.w*2)
ilswNotAtStart

		addq.w	#1,d1
		dbra	d0,ilswLoop		

		rts


; ---------------------------------------------------------
; 10.06.00/vk
ilResetScanner

		lea	scanner,a0
		move.w	#SCANNERSTARTPOSX,SCANNERPOSX(a0)
		move.w	#SCANNERSTARTPOSY,SCANNERPOSY(a0)
		move.w	#SCANNERSTARTRADIUS,SCANNERRADIUS(a0)
		move.w	#SCANNERSTARTRANGE,SCANNERRANGE(a0)
		move.w	#SCANNERSTARTNBOFCIRCLES,SCANNERNBOFCIRCLES(a0)

		bsr	scannerResetFields
		rts


; ---------------------------------------------------------
; 12.08.00/vk
ilResetGeiger

		lea	geiger,a0
		move.w	#GEIGERSTARTPOSX,GEIGERPOSX(a0)
		move.w	#GEIGERSTARTPOSY,GEIGERPOSY(a0)
		move.w	#GEIGERSTARTRADIUS,GEIGERRADIUS(a0)
		move.w	#GEIGERSTARTMINALPHA,GEIGERMINALPHA(a0)
		move.w	#GEIGERSTARTMAXALPHA,GEIGERMAXALPHA(a0)
		move.w	#GEIGERSTARTCOLOR,GEIGERCOLOR(a0)

		clr.w	GEIGERCURRENTPOS(a0)
		clr.w	GEIGERTOREACHREALPOS(a0)

		bsr	geigerResetFields
		rts


; ---------------------------------------------------------
; 13.08.00/vk
ilResetAltTab
		lea	altTab,a0
		move.l	#altTabBitmap,ALTTABBITMAP(a0)

		move.w	#CALTTABNB,d0
		lsr.w	#1,d0
		move.w	d0,ALTTABNBLEFTORRIGHT(a0)

		mulu.w	#2*(CALTTABDX+CALTTABCELLSPACING),d0
		move.w	d0,ALTTABMIDOFFSET(a0)

		bsr	hideAltTab				; .\src\console\alttab.s
		rts


; ---------------------------------------------------------
; 11.06.00/vk
ilResetConsole
		lea	console,a0
		move.w	#CONSOLESTARTSTRETCHP1,CONSOLESTRETCHP1(a0)
		move.w	#CONSOLESTARTSTRETCHP2,CONSOLESTRETCHP2(a0)
		move.w	#CONSOLESTARTSPACEENERGY,CONSOLESPACEENERGY(a0)
		move.w	#CONSOLESTARTSPACESHIELD,CONSOLESPACESHIELD(a0)
		move.w	#CONSOLESTARTSPACEBAG,CONSOLESPACEBAG(a0)

		bsr	consoleResetFields
		rts








		ifne INSTALLS

;**************************************
;* install_level
;**************************************

; es liegt an position level ein
; brandneuer level zur kompletten
; neuinitialisierung bereit ...


install_level

		move.l	#per_vga,d0
		tst.w	vga_monitor
		bne.s	il_no_vga
		move.l	#per_rgb,d0
il_no_vga	move.l	d0,per_factor


		move.l	#level,big_sector_ptr
		bsr	set_play_dat_ptr

	; -------------------
	; hintergrundbild laden
	; in den logischen screen ...

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
il_copyfile_lop	move.b	(a1)+,d0
		move.b	d0,(a0)+
		cmpi.b	#" ",d0
		beq.s	il_copyfile_out
		tst.b	d0
		bne.s	il_copyfile_lop
il_copyfile_out	clr.b	-(a0)
		
		move.l	#init_file,file_name_ptr
		bsr	load_file

		movea.l	big_sector_ptr,a1
		movea.l	lev_infos(a1),a1
		move.l	li_name_ptr(a1),a0
		movea.l	screen_1,a6
		adda.l	#640*225+8*2,a6
		jsr	paint_text
		
	; -------------------
	; ... und ueberblenden

		moveq	#0,d0
		bsr	make_blenden

	; -------------------
	; dann kann es ja mit
	; dem initialisieren der
	; einzelnen teilbereiche losgehen

		movea.l	big_sector_ptr,a0

	; -------------------
	; zuege

		movea.l	lev_trains(a0),a1
		move.w	trn_max_anz(a1),d0
		ext.l	d0
		move.w	d0,max_trains
		move.l	d0,nb_of_trains

		moveq	#0,d1
		subq.w	#1,d0
		bmi.s	il_no_trains
il_trn_loop	lsl.w	#1,d1
		bset	#0,d1
		dbra	d0,il_trn_loop
il_no_trains
		move.w	d1,trains_aktive
		move.w	d1,trains_visible

	; -------------------
	; anzahl sichtbarer 
	; monster auf null

		moveq	#-1,d0
		move.w	d0,mon_buf1_anz
		move.w	d0,mon_buf2_anz

	; -------------------
	; initialisierung
	; der hauptconsole

		move.w	#1,pl_console_mode

	; -------------------
	; true_offset initialisieren

		move.l	#true,true_offi

	; -------------------
	; und dann halt
	; noch den rest ...

		bsr	delete_animated_doors
		bsr	set_monsters		; keine animationsphasen, gesundheit
		bsr	set_player_energy	; energy, shield
		bsr	set_player_view
		bsr	set_player_start
		bsr	set_backpack

		bsr	set_pd_things_ptr	
		bsr	set_no_things		; keine gegenstaende
		bsr	set_initlevel		; spezielle levelanpassungen

		bsr	set_pl_things_ptr

		move.w	#-1,pl_left_nb
		bsr	set_pl_to_init

		bsr	set_no_flags_from_former_events
		bsr	set_dsp_genau
		bsr	set_menu_to_running
	
	; -------------------
	; truecolor-tabellen 
	; erstellen

		bsr	create_truecolor_tabs

	; -------------------
	; grafiken und samples 
	; des levels laden

		bsr	load_lev_files
		jsr	set_colortable_init

		movea.l	screen_1,a0
		bsr	clear_black_240
		moveq	#2,d0
		bsr	make_blenden


                rts


;**************************************
;* install_game
;**************************************

; es liegt an addresse 'truecolor_tab' ein
; spielstand zur reinitialisierung bereit

install_game

		tst.w	no_dsp_flag		; flag, ob aus standard- 
		beq.s	ig_no_backpic		; oder startmenue
						; startmenue -> no_dsp -> no_backpic

	; -------------------
	; leveladresse bestimmen

		lea	truecolor_tab,a0
		adda.l	#rsx_variables,a0
		adda.l	#loadsave_end-loadsave_start+4,a0

		movea.l	screen_1,a1
		suba.w	#128,a1
		move.l	a1,file_buf_ptr
		move.l	#153728,file_size
		lea	init_file_modi,a1
		clr.l	(a1)
		clr.l	4(a1)
		clr.l	8(a1)
		clr.l	12(a1)
		movea.l	lev_infos(a0),a0
		lea	li_file(a0),a0
ig_copyfile_lop	move.b	(a0)+,d0
		move.b	d0,(a1)+
		cmpi.b	#" ",d0
		beq.s	ig_copyfile_out
		tst.b	d0
		bne.s	ig_copyfile_lop
ig_copyfile_out	clr.b	-(a1)
		move.l	#init_file,file_name_ptr
		jsr	load_file


		moveq	#0,d0
		bsr	make_blenden

ig_no_backpic

		bsr	set_play_dat_ptr

	; -------------------
	; leveladresse bestimmen

		lea	truecolor_tab,a0
		adda.l	#rsx_variables,a0
		adda.l	#loadsave_end-loadsave_start,a0

		lea	level,a1
		move.l	a1,big_sector_ptr

	; -------------------
	; level kopieren

		move.l	(a0)+,d0	; lev_groesse
		lsr.l	#4,d0
ig_copy_level
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d0,ig_copy_level

	; -------------------
	; leveladressen anpassen

		lea	level,a0
		move.l	a0,d0
		bsr	convert_level_addresses_for_load

	; -------------------
	; variablenblock kopieren

		lea	truecolor_tab,a0
		adda.l	#rsx_variables,a0
		move.w	#loadsave_end-loadsave_start-1,d0
		lea	loadsave_start,a1
ig_copy_variables
		move.b	(a0)+,(a1)+
		dbra	d0,ig_copy_variables

		move.l	big_sector_ptr,d0
		bsr	convert_game_addresses_for_load

	; -------------------
	; anzahl sichtbarer 
	; monster auf null

		moveq	#-1,d0
		move.w	d0,mon_buf1_anz
		move.w	d0,mon_buf2_anz

	; -------------------
	; sonstiges

		bsr	set_pl_things_ptr
		bsr	set_player_view_part_ii
		bsr	set_pd_things_ptr
		bsr	set_pl_to_init

	; -------------------
	; truecolor-tabellen 
	; erstellen

		bsr	create_truecolor_tabs

	; -------------------
	; grafiken und samples 
	; des levels laden

                bsr     load_lev_files
		move.w	#1,sc_load_flag

		bsr	calc_paint_pistol_immediate
		bsr	install_si_routine

		movea.l	play_dat_ptr,a6
		move.b	#$ff,pd_time_limit1+1(a6)
		move.b	#$ff,pd_time_limit2+1(a6)
		move.b	#$ff,pd_time_limit3+1(a6)
		move.b	#$ff,pd_time_limit4+1(a6)

		movea.l	big_sector_ptr,a5
		movea.l	lev_infos(a5),a5
		move.w	li_episode(a5),d0
		swap	d0
		move.w	li_level(a5),d0
		move.l	d0,episode

		tst.w	no_dsp_flag
		bne.s	ig_no_dsp

		jsr	dsp_r_normal

                jsr     dsp_s_table
                jsr     dsp_s_init_data
		jsr	dsp_s_all

		jsr	dsp_r_normal

		jsr	dsp_s_all

ig_no_dsp

		tst.w	no_dsp_flag
		beq.s	ig_no_blend

		movea.l	screen_1,a0
		bsr	clear_black_240
		moveq	#0,d0
		bsr	make_blenden

ig_no_blend

		move.w	#1,clear_it_flag

		rts


no_dsp_flag	dc.w	0


;**************************************
;* delete_animated_doors
;**************************************

delete_animated_doors

		clr.w	an_doors_flag
		clr.w	an_lifts_flag

		moveq	#15,d0
		lea	an_doors_ptr,a0
dad_loop1	clr.l	(a0)+
		dbra	d0,dad_loop1

		moveq	#15,d0
		lea	an_lifts_ptr,a0
dad_loop2	clr.l	(a0)+
		dbra	d0,dad_loop2

;**************************************
;* set_menu_to_running
;**************************************

set_menu_to_running

		ifne menueflag

; 0 = use vsync
; 1 = no

		tst.w	detail_control+12	; use vsync
		beq.s	smtr_uvsync_yes
		move.w	#1,vsync_flag
		bra.s	smtr_vsync_ok
smtr_uvsync_yes	clr.w	vsync_flag
smtr_vsync_ok

; 0 = paint weapon
; 1 = no

		tst.w	detail_control+18	; paint weapon
		beq.s	smtr_pweap_yes
		move.w	#1,pp_flag
		bra.s	smtr_pweapon_ok
smtr_pweap_yes	clr.w	pp_flag
smtr_pweapon_ok

; 0 = high volume
; 1 = low volume

		tst.w	sound_control		; volume
		beq.s	smtr_vol_high
		move.w	#$0660,$ffff893a.w
		bra.s	smtr_volume_ok
smtr_vol_high	clr.w	$ffff893a.w
smtr_volume_ok

; 0 = speaker off
; 1 = speaker on

		move.b	#14,$ffff8800.w
		move.b	$ffff8800.w,d0
		btst	#6,d0
		beq.s	smtr_speak_is_on
		tst.w	sound_control+6		; speaker
		beq.s	smtr_speaker_ok
		bchg	#6,d0
		move.b	d0,$ffff8802.w
		bra.s	smtr_speaker_ok
smtr_speak_is_on
		tst.w	sound_control+6
		bne.s	smtr_speaker_ok
		bchg	#6,d0
		move.b	d0,$ffff8802.w
smtr_speaker_ok

; 0 = low frequency
; 1 = high frequency

		move.w	spl_system,d0
		btst	#0,d0
		beq.s	smtr_snd_is_25
		tst.w	sound_control+12	; frequency
		beq.s	smtr_frequency_ok
		bchg	#0,d0
		move.w	d0,spl_system
		bra.s	smtr_frequency_ok
smtr_snd_is_25	tst.w	sound_control+12
		bne.s	smtr_frequency_ok
		bchg	#0,d0
		move.w	d0,spl_system
smtr_frequency_ok

; 0 = voice on
; 1 = voice off

		movea.l	play_dat_ptr,a0
		tst.w	sound_control+18	; voice
		beq.s	smtr_voice_on
		move.w	#1,pd_duke_talk(a0)
		bra.s	smtr_voice_ok
smtr_voice_on	clr.w	pd_duke_talk(a0)
smtr_voice_ok

		endc

		rts


;**************************************
;* set_play_dat_ptr
;**************************************

set_play_dat_ptr

		move.l	#play_dat_p0,play_dat_ptr

		rts


;**************************************
;* set_pl_to_init
;**************************************

set_pl_to_init

		move.w	#5,pl_must_copy

		moveq	#1,d0
		move.w	d0,plf_weapon
		move.w	d0,plf_things
		move.w	d0,plf_time_limit
		move.w	d0,plf_energy
		move.w	d0,plf_shield

	; -------------------
	; message-pointer loeschen

		clr.l	mes_buf1
		clr.l	mes_buf2

		rts



;**************************************
;* create_truecolor_tabs (06/10/97)
;**************************************

create_truecolor_tabs

		movea.l	big_sector_ptr,a0
		movea.l	lev_init_data(a0),a0
		movea.l	init_needed_tt(a0),a0

ctt_loop
		move.w	(a0)+,d0
		bmi.s	ctt_out
	
		move.w	d0,ctt_number
		lea	truetabs_routs,a1
		move.l	0(a1,d0.w*4),d1
		beq.s	ctt_loop
		
		move.l	a0,-(sp)
		movea.l	d1,a2

	; --------------------
	; tabelle nur dann erzeugen, 
	; wenn nicht schon im 
	; temp-ordner vorhanden

		movem.l	d1-a6,-(sp)
		clr.w	-(sp)

		movea.l	big_sector_ptr,a0
		movea.l	lev_color_tab(a0),a0
		move.l	(a0,d0.w*4),-(sp)	; pointer filename

		move.w	#61,-(sp)	
		trap	#1			; f_open
		addq.l	#8,sp
		movem.l	(sp)+,d1-a6
		tst.w	d0
		bmi.s	ctt_make_it

	; -------------------
	; tabelle ist schon 
	; vorhanden, also
	; file wieder schliessen

		move.w	d0,-(sp)
		move.w	#62,-(sp)
		trap	#1
		addq.l	#4,sp
		
		bra.s	ctt_skip

ctt_make_it

	; -------------------
	; tabelle erzeugen ...

		jsr	(a2)

	; -------------------
	; ... und abspeichern

		movea.l	big_sector_ptr,a0
		movea.l	lev_color_tab(a0),a0
		move.w	ctt_number,d0
		movea.l	(a0,d0.w*4),a0

		bsr	save_truecolor_tab

ctt_skip
		movea.l	(sp)+,a0

		bra.s	ctt_loop

ctt_out

	; -------------------
	; jetzt sicherheitshalber den
	; speicherbereich truecolor_tab
	; auf null setzen

		lea	truecolor_tab,a0
		moveq	#7,d0
ctt_cl1		move.w	#8191,d1
ctt_cl2		clr.l	(a0)+
		clr.l	(a0)+
		dbra	d1,ctt_cl2
		dbra	d0,ctt_cl1

		rts

;--

ctt_number	dc.w	0



;**************************************
;* set_initlevel (06/10/97)
;**************************************

; initialisierungswerte aus der
; leveldatei selbst uebernehmen

; - gegenstaende
; - munition

set_initlevel

	; -------------------
	; zuerst die gegenstaende 
	; anpassen ...

		movea.l	big_sector_ptr,a0
		movea.l	lev_initlevel(a0),a0
		movea.l	ilev_lostthings(a0),a1

		movea.l	play_dat_ptr,a2
		clr.w	pd_primary(a2)		; auftraege
		clr.w	pd_secondary(a2)	; loeschen

		movea.l	pd_things_ptr(a2),a3
		lea	pl_leiste_act,a4
sil_lt_loop	move.w	(a1)+,d0
		bmi.s	sil_lt_out
		clr.l	-4(a3,d0.w*4)		; gegenstand loeschen
		clr.w	-2(a4,d0.w*2)		; als nicht aktiviert setzen
		bra.s	sil_lt_loop

sil_lt_out

	; -------------------
	; jetzt die munition 
	; anpassen ...
	; dazu zuerst die gesamte 
	; munition loeschen, die
	; der spieler hat ...

		clr.w	pd_mun_type(a2)		; weapon auf fuss einstellen ...
		clr.w	pd_pistol1(a2)		; waffen auf nicht vorhanden ...
		clr.w	pd_pistol2(a2)
		clr.w	pd_pistol3(a2)
		clr.w	pd_pistol4(a2)
		clr.w	pd_mun0_anz(a2)		; munition auf null ...
		clr.w	pd_mun1_anz(a2)
		clr.w	pd_mun2_anz(a2)
		clr.w	pd_mun3_anz(a2)

	; -------------------
	; und jetzt vielleicht
	; wieder etwas ammo
	; dazu ...

		movea.l	ilev_munition(a0),a0

sil_mun_loop
		move.w	(a0)+,d0			; waffentyp oder -1
		bmi.s	sil_out

		move.w	d0,d2
		addq.w	#1,d2
		move.w	d2,pd_mun_type(a2)
		move.w	d0,d2
		add.w	d2,d2
		addi.w	#pd_pistol1,d2
		move.w	#1,(a2,d2.w)			; waffe als vorhanden ...
		move.w	(a0)+,pd_mun0_anz(a2,d0.w*2)	; ... mit richtiger munition
		bra.s	sil_mun_loop

sil_out		
		rts



;**************************************
;* set_backpack
;**************************************

set_backpack

		movea.l	play_dat_ptr,a6
		move.w	#munx0_beg,pd_munx0_anz(a6)
		move.w	#munx1_beg,pd_munx1_anz(a6)
		move.w	#munx2_beg,pd_munx2_anz(a6)
		move.w	#munx3_beg,pd_munx3_anz(a6)

		rts



;**************************************
;* set_player_start (06/10/97)
;**************************************

set_player_start

		movea.l	big_sector_ptr,a0
		movea.l	lev_startpoint(a0),a0
		movea.l	play_dat_ptr,a1

		move.l	start_x(a0),pd_sx(a1)
		move.l	start_y(a0),pd_sy(a1)
		move.l	start_h(a0),d0
		move.l	d0,pd_sh(a1)
		move.l	d0,pd_sh_real(a1)
		move.l	start_alpha(a0),pd_alpha(a1)
		move.w	start_sector(a0),pd_akt_sector(a1)
		move.w	#-1,pd_last_sector(a1)

		rts



;**************************************
;* set_no_flags_from_former_events (06/10/97)
;**************************************

set_no_flags_from_former_events


		movea.l	play_dat_ptr,a1

	; -------------------
	; keine bewegung mehr von 
	; vorherigen tastaturevents ...

		clr.l	pd_last_strafe(a1)
		clr.l	pd_last_alpha(a1)
		clr.l	pd_last_step(a1)

	; -------------------
	; flags loeschen ...

		clr.w	pd_things_flag(a1)
		clr.w	pd_jump_flag(a1)

		clr.w	pd_timeout_flag(a1)
		clr.w	pd_killed_flag(a1)
		clr.w	pd_cursor_flag(a1)
		clr.w	pd_quit_flag(a1)

		clr.w	pd_which_end(a1)

		rts


;**************************************
;* set_player_view (06/10/97)
;**************************************

set_player_view
		
		movea.l	play_dat_ptr,a1

		ifne menueflag
		move.w	detail_control,d3	; screen_size
		else
		moveq	#0,d3
		endc

		bne.s	spv_ss_no0
		move.w	#320,d0
		move.w	#200,d1
		bra.s	spv_size_ok
spv_ss_no0	cmpi.w	#1,d3
		bne.s	spv_ss_no1
		move.w	#192,d0
		moveq	#120,d1
		bra.s	spv_size_ok
spv_ss_no1	moveq	#96,d0
		moveq	#60,d1
spv_size_ok
		ifne menueflag
		tst.w	detail_control+6	; detail (x-flag)
		else
		moveq	#0,d2
		endc

		bne.s	spv_det_high
		moveq	#1,d2
		bra.s	spv_detail_ok
spv_det_high	moveq	#0,d2

spv_detail_ok
		move.w	d0,pd_width(a1)
		move.w	d0,pd_width_last(a1)
		move.w	d1,pd_heigth(a1)
		move.w	d1,pd_heigth_last(a1)
		move.w	d2,pd_x_flag(a1)
		move.w	d2,pd_x_flag_last(a1)

		clr.w	pd_paint_x_offi(a1)

		move.w	#96,xwindow_min
		move.w	#320,xwindow_max
		move.w	#60,ywindow_min
		move.w	#200,ywindow_max

		move.w	#320,screen_x_full
		move.w	#120,screen_y_full

		tst.w	vga_monitor
		beq.s	spv_cine_rgb

		move.w	#160,screen_x_cine
		move.w	#200,screen_y_cine
		clr.w	screen_flag_cine
		bra.s	spv_cine_all
spv_cine_rgb
		move.w	#256,screen_x_cine
		move.w	#200,screen_y_cine
		move.w	#1,screen_flag_cine
spv_cine_all

		move.w	#256,screen_x_cifu
		move.w	#120,screen_y_cifu

        	move.w	#1,clear_it_flag
		move.w	#5,pl_must_copy
	
		rts


;---------------

set_player_view_part_ii

		movea.l	play_dat_ptr,a1
		move.w	#-1,pd_last_sector(a1)
		move.w	#-2,pd_wall_anim_sec(a1)

		tst.w	vga_monitor
		beq.s	spvp2_cine_rgb

		move.w	#160,screen_x_cine
		move.w	#200,screen_y_cine
		clr.w	screen_flag_cine
		bra.s	spvp2_cine_all
spvp2_cine_rgb
		move.w	#256,screen_x_cine
		move.w	#200,screen_y_cine
		move.w	#1,screen_flag_cine
spvp2_cine_all
		move.w	#320,pd_width(a1)
		move.w	#320,pd_width_last(a1)
		move.w	#200,pd_heigth(a1)
		move.w	#200,pd_heigth_last(a1)
		move.w	#1,pd_x_flag(a1)
		move.w	#1,pd_x_flag_last(a1)

		move.w  #96,xwindow_min
                move.w  #320,xwindow_max
                move.w  #60,ywindow_min
                move.w  #200,ywindow_max


                rts



;**************************************
;* set_monsters (06/10/97)
;**************************************

; die vertragende schussanzahl aller
; gegner zuruecksetzen, saemtliche
; flags fuer die animationsphasen loeschen

set_monsters
		movea.l	big_sector_ptr,a0
		movea.l	lev_monsters(a0),a0
		movea.l	mon_dat(a0),a0
smh_loop
		move.l	(a0)+,d0
		bmi.s	smh_out

		movea.l	d0,a1
		clr.w	mon_a_walk(a1)
		clr.w	mon_a_walk_pos(a1)
		clr.w	mon_a_shoot(a1)
		clr.w	mon_a_shoot_pos(a1)
		clr.w	mon_a_hit(a1)
		clr.w	mon_a_died(a1)
		clr.w	mon_a_died_pos(a1)
		move.w	mon_health_orig(a1),mon_health(a1)
		bra.s	smh_loop

smh_out
		rts


;**************************************
;* set_pd_things_ptr (06/10/97)
;**************************************

set_pd_things_ptr

		movea.l	play_dat_ptr,a6
		move.l	#play_thg_p0,pd_things_ptr(a6)

		rts


;**************************************
;* set_pl_things_ptr (06/10/97)
;**************************************

set_pl_things_ptr

                move.l  #things_gfx+128,pl_thg_gfx_ptr

                rts


;**************************************
;* set_player_energy (06/10/97)
;**************************************

set_player_energy

		movea.l	play_dat_ptr,a6
		move.w	#100*256,d0
		move.w	d0,pd_health(a6)
		move.w	d0,pd_armor(a6)

		move.l	#player_height_1,pd_player_height(a6)	; ????
		move.w	#-1,pd_wall_anim_sec(a6)

		rts


;**************************************
;* set_no_things (06/10/97)
;**************************************

set_no_things

		movea.l	play_dat_ptr,a6
		movea.l	pd_things_ptr(a6),a0
		moveq	#things_max-1,d7
snt_loop	clr.l	(a0)+
		dbra	d7,snt_loop

		rts



		endc
