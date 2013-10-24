;	Lynx TriSoundSequencer (GigaSong v1.0)
;
;
	include	D:\macros.s
;
executable	equ	0	0=stripped version to use while programming, 1=executable version
;
vbl		equ	$70

HZ_bn		equ	5
kb		equ	$118	vector IKBD/MIDI interrupt
KB_bn		equ	6	bit nummer IKBD/MIDI interrupt in MFP controle registers
ta		equ	$134	vector timer A
TA_bn		equ	5	bit nummer timer A

IERA		equ	$fffffa07
IERB		equ	$fffffa09
IPRA		equ	$fffffa0b
IPRB		equ	$fffffa0d
IMRA		equ	$fffffa13
IMRB		equ	$fffffa15
ISRA		equ	$fffffa0f
ISRB		equ	$fffffa11

TADR		equ	$fffffa1f
TACR		equ	$fffffa19
TBDR		equ	$fffffa21
TBCR		equ	$fffffa1a
***
meld		equ	$ffff8241
service		equ	$fffffa0f
bcontrol	equ	$fffffa1b
bdata		equ	$fffffa21
***
kb_ctrl		equ	$fffffc00
kb_data		equ	$fffffc02
md_ctrl		equ	$fffffc04
md_data		equ	$fffffc06

psgreg		equ	$ffff8800
psgwrite	equ	$ffff8802
;
;
		IFEQ	executable
max_pat		equ	16	maximum aantal patterns
		ELSEIF
max_pat		equ	32	maximum aantal patterns
		ENDC
pat_len		equ	64	lengte pattern in noten
note_len	equ	12	lengte noot (pattern regel) in bytes
;
linelen		equ	160	lengte 1 regel op het scherm
ll		equ	linelen
;
dist_hi		equ	32	hoogte distortion data
logo_hi		equ	59	hoogte logo
;		***** INSTRUMENT STRUCTURE EQUATES *****
i_noise_freq	equ	0
i_sound_mode	equ	2
i_env_type	equ	3
i_env_freq	equ	4
i_vibr_speed	equ	6
i_vibr_depth	equ	8
i_interval1	equ	252
i_interval2	equ	254
i_env_attack	equ	10
i_env_sustain	equ	12
i_env_release	equ	14
i_env_start	equ	16
i_env_len	equ	112
i_pit_attack	equ	240
i_pit_sustain	equ	242
i_pit_release	equ	244
i_pit_start	equ	128
i_pit_len	equ	112
i_total_len	equ	256
;
gemdos    = 1
crawcin   = 7
cconws    = 9
dgetdrv   = $19
dgetpath  = $47
;
YEAH	macro
	not.w	col0 .w		silly macro that inverts the background color for trace functions
	endm
YEAH2	macro
	addq.w	#1,col0
	endm
;
restore_pat_lin	macro
	st.b	pause_mode	pauseer afspelen

	move.l	pat_restor3,a0		restore buffer 3
	lea	pat_resbuf3,a2		adres restore buffer
	move.l	#pat_test,pat_restor3	bij volgende restore, in andere buffer zetten, tenzij PLAY daar zelf iets aan verandert
	move.l	(a2)+,(a0)+	zet eerste long terug
	move.l	(a2)+,(a0)+	tweede long
	move.l	(a2)+,(a0)+	derde long

	move.l	pat_restor2,a0		restore buffer 2
	lea	pat_resbuf2,a2		adres restore buffer
	move.l	#pat_test,pat_restor2	bij volgende restore, in andere buffer zetten, tenzij PLAY daar zelf iets aan verandert
	move.l	(a2)+,(a0)+	zet eerste long terug
	move.l	(a2)+,(a0)+	tweede long
	move.l	(a2)+,(a0)+	derde long

	move.l	pat_restor1,a0		restore buffer 1
	lea	pat_resbuf1,a2		adres restore buffer
	move.l	#pat_test,pat_restor1	bij volgende restore, in andere buffer zetten, tenzij PLAY daar zelf iets aan verandert
	move.l	(a2)+,(a0)+	zet eerste long terug
	move.l	(a2)+,(a0)+	tweede long
	move.l	(a2)+,(a0)+	derde long

	endm
;
clear_key	macro
	clr.b	key_raw
	clr.b	key_in
	clr.b	key_last
	endm
;
show_mouse	macro
	dc.w	$a009
	endm
;
hide_mouse	macro
	dc.w	$a00a
	endm
; macro laat AreYouSure dialog zien en springt naar no_do(RTS) nij NO als antwoord
yes_no	macro
	bsr	ask_sure	vraag of gebruiker het echt wil
	tst.w	d0		bekijk vlag
	bne	no_do		bij NO -> doe niks
	endm
;
;		***** INITIALISAITE *****
;
	startup
	IFEQ	executable
	getrez
	move.w	d0,oldrez
	setrez	#0
	ELSEIF
	getrez
	tst.w	d0		zitten we in lo-res?
	bne	wrong_rez	nee -> verkeerde resolutie
	ENDC

	super	ssp
	move.l	#mystack,sp

	hide_mouse		hide OS mouse
	bsr	get_mouse	zet muis op GEM-coordinaten
	bclr.b	#0,$484		toetsklik uit
	bclr.b	#1,$484		zet key repeat uit (in conterm)
	bclr.b	#2,$484		zet bel uit
	bsr	make_paths	maak paden aan met behulp van standaard drive en path

	bsr	wait_led	wacht tot led uitgaat met initialiseren

	getpal	oldpal
	setpal	pal1
	getphys
	move.l	d0,phys_0	sla pointer naar begin scherm op

	bsr	clear_key_buf	wis toetsenbord buffer
	bsr	pause_kb	keyboard meldingen uit
	vsync
	vsync
;
	bsr	init_mouse	muis sprite initialiseren
	clr.w	d0		x pos=0
	move.w	d0,d1		y pos=0
	bsr	put_mouse	zet muis neer


	move.w	#$2700,sr

	bsr	play3v		initialiseer play routine
	bsr	clr_all		wis alles en zet defaults
	bsr	enab_int	intstalleer eigen interrupts

	move.w	#$2300,sr
	bsr	resume_kb	keyboard meldingen weer aan

	ins_vbi	do_play_queue	zet afspeel routine in VBL Queue van TOS

	bsr	wvbl		wacht op VBL
;
	bsr	main_scr	schakel	over naar hoofdscherm
;
;
;		***** HOOFDLUS : *****
;
;		***** WACHT OP MUISKLIK OF TOETSDRUK *****
	clr.b	pause_mode	zodat eerste toets geaccepteerd wordt
retst	move.w	vbl_last_m,d0	haal vorige vbl_count van muis
	add.w	vbl_wait_m,d0	tel daarbij wachtstap van muis op
	move.w	vbl_last_k,d1	haal vorige vbl count van toets
	add.w	vbl_wait_k,d1	tel daarbij wachtstap van toets op

	cmp.w	vbl_count,d0	zijn we nu bij goede muis VBL?
	bls.s	mouse_vbl	ja -> bekijk muis
check_key
	cmp.w	vbl_count,d1	zijn we nu bij goede toets VBL?
	bls.s	key_vbl		ja -> bekijk toetsen
	bra.s	retst		check VBL's nog een keer

mouse_vbl
	move.w	vbl_count,vbl_last_m	bewaar huidige vbl count om zodirekt te vergelijken
	bsr	do_mouse		bekijk muis
	bra.s	check_key		vergeet ook de toetsen niet

key_vbl	move.w	vbl_count,vbl_last_k	bewaar huidige vbl count om zodirekt te vergelijken
	bsr	do_key			bekijk toets
	bra.s	retst
;
;		****** EINDE HOOFDLUS *****
;
exit
	tst.b	menu_mode	wordt er een Adamski geprint?
	bne.s	no_repos_yes_no	nee -> laat YES/NO op muispos komen

	move.w	#100,d0		x-positie is 100
	move.w	#5,d1		y-positie is 5
no_repos_yes_no
	yes_no
;
	bsr	led_off		doe LED uit
	jsr	disab_int

	move.w	#0,-(sp)	toetsen goed zetten
	move.w	#11,-(sp)
	trap	#13
	addq.l	#4,sp

	bsr	clear_key_buf	wis toetsenbord buffer
	bset.b	#0,$484		toetsklik aan
	bset.b	#1,$484		zet key repeat aan (in conterm)
	bset.b	#2,$484		zet bel aan
	deins_vbi		haal afspeel routine uit VBL Queue van TOS

	IFEQ	executable
	setrez	oldrez
	ENDC
	setpal	oldpal

	show_mouse
	user	ssp
	term
wrong_rez
	print	sorry_rez
	waitkey
	term
;
;
;
;
snd_init
	move.w	sr,d7		bewaar status reg
	move.w	#$2700,sr

	bclr.b	#TA_bn,IERA		zet timer A voor kanaal A stil
	bset.b	#0,Adata+silent		zet kanalen uit
	bclr.b	#1,Adata+silent		geen sample op kanaal A
	bset.b	#0,Bdata+silent
	bset.b	#0,Cdata+silent
	st.b	Adata+instr_no		maak instrumenten nummer $ff zodat bij vergelijking instrument data opnieuw geladen wordt
	st.b	Bdata+instr_no
	st.b	Cdata+instr_no

	lea	psgreg,a0
	lea	psgwrite,a1
	clr.b	(a0)		we clearen nu alle PSG registers
	clr.b	(a1)
	move.b	#1,(a0)
	clr.b	(a1)
	move.b	#2,(a0)
	clr.b	(a1)
	move.b	#3,(a0)
	clr.b	(a1)
	move.b	#4,(a0)
	clr.b	(a1)
	move.b	#5,(a0)
	clr.b	(a1)
	move.b	#6,(a0)
	clr.b	(a1)
	move.b	#7,(a0)
	move.b	(a0),d0		haal waarde reg #7
	andi.b	#%11000000,d0	laat A/B I/O staan
	or.b	#%00111111,d0	zet alles verder uit
	move.b	d0,(a1)		sla reg #7 op
	move.b	#8,(a0)
	clr.b	(a1)		volume kanaal A
	move.b	#9,(a0)
	clr.b	(a1)		volume kanaal B
	move.b	#10,(a0)
	clr.b	(a1)		volume kanaal C
	move.b	#11,(a0)
	clr.b	(a1)		envelope freq lo
	move.b	#12,(a0)
	clr.b	(a1)		envelope freq hi
	move.b	#13,(a0)
	clr.b	(a1)		envelope vorm

	move.w	d7,sr
	rts
;
enab_int
	move.w	sr,d7
	move.w	#$2700,SR		zet INTs uit
	bsr	snd_init		initialiseer PSG

	move.l	kb,old_kb		nieuwe Keyboard routine
	move.l	#own_kb,kb
	move.l	vbl,old_vbl		nieuwe VBL
	move.l	#own_vbl,vbl
	move.l	#intnorm,ta		set timer A address

	clr.b	TACR		stop timer A
	move.b	#1,TACR		start timer A
	clr.b	TADR		set speed of timer A to 0(=256=slowest)
	bset.b	#TA_bn,IMRA	timer A mask
	bclr.b	#TA_bn,IERA	timer A disable

	pea	intras		zet adres raster-rout op stack
	move.w	#50,-(sp)	data
	clr.w	-(sp)		interrupt nog niet aan
	move.w	#1,-(sp)	timer B
	move.w	#31,-(sp)	XBtimer
	trap	#14		Xbios
	lea	12(sp),sp

	bclr.b	#HZ_bn,IERB	timer C disable zodat 200 Hz timer uit is

	clr.b	mousek		wis muis knoppen status
	clr.b	mrelx		en relatieve verplaatsing
	clr.b	mrely
	clr.w	nxt_mouse	zet keyboard ontvang routine op toetsen ontvangen
	move.w	d7,SR		zet INTs weer aan
	rts
;
disab_int
	move.w	sr,d7
	move.w	#$2700,SR	zet INTs uit

	bclr	#TA_bn,IERA	timer A interrupt off
	bclr	#TA_bn,IPRA	timer A pending clear
	bclr	#TA_bn,ISRA	timer A interrupt in service clear
;	hier werd mask gezet, maar is weggehaald voor MSX tijdens Item Selector

	clr.b	bcontrol	zet Timer B controlregister op 0
	bclr	#0,service	meld Timer B af

	bset.b	#HZ_bn,IERB	timer C enable

	move.l	old_kb,kb
	move.l	old_vbl,vbl

	bsr	snd_init	wis PSG
	move.w	d7,SR		zet INTs weer aan
	rts
; haal interrupts weg voor File Selector:
disab_int_fsel
	move.w	sr,d7
	move.w	#$2700,SR	zet INTs uit

	clr.b	bcontrol	zet Timer B controlregister op 0
	bclr	#0,service	meld Timer B af

	bset.b	#HZ_bn,IERB	timer C enable

	move.l	old_kb,kb
	move.l	old_vbl,vbl

	move.w	d7,SR		zet INTs weer aan
	rts
;
; zet interrupts na File Selector
enab_int_fsel
	move.w	sr,d7
	move.w	#$2700,SR		zet INTs uit

	move.l	kb,old_kb		nieuwe Keyboard routine
	move.l	#own_kb,kb
	move.l	vbl,old_vbl		nieuwe VBL
	move.l	#own_vbl,vbl
	move.l	#intnorm,ta		set timer A address

	pea	intras		zet adres raster-rout op stack
	move.w	#50,-(sp)	data
	clr.w	-(sp)		interrupt nog niet aan
	move.w	#1,-(sp)	timer B
	move.w	#31,-(sp)	XBtimer
	trap	#14		Xbios
	lea	12(sp),sp

	bclr.b	#HZ_bn,IERB	timer C disable zodat 200 Hz timer uit is

	clr.b	mousek		wis muis knoppen status
	clr.b	mrelx		en relatieve verplaatsing
	clr.b	mrely
	clr.w	nxt_mouse	zet keyboard ontvang routine op toetsen ontvangen
	move.w	d7,SR		zet INTs weer aan
	rts
;
;
;		***** SOUND PLAY INIT ROUTINE *****
;
play3v	move.w	sr,d7
	move.w	#$2700,sr		INTs uit
	move.w	#1,last_pat		aantal patterns is eerst 1
	move.w	#max_pat-1,d0		haal aantal patterns-1 (voor dbra lus)
	lea	patterns,a0		begin adres patterns
	lea	pat_tab,a1		begin adres pattern tabel
init_pat_tab
	move.l	a0,(a1)+		sla adres pattern op
	add.l	#pat_len*note_len,a0	naar volgende pattern
	dbra	d0,init_pat_tab		net zo lang tot alle pattern geweest zijn

	move.w	#1,note_count			begin meteen met noot
	clr.w	pos_now				begin bij position #0
	move.l	#patterns,pat_ptr		pointer IN pattern goed zetten
	move.l	#patterns,pat_base		pointer NAAR pattern goed zetten
	move.l	#pat_resbuf1,pat_restor1	pointer naar BACKUP pattern goed zetten
	move.l	#pat_resbuf2,pat_restor2
	move.l	#pat_resbuf3,pat_restor3

	move.w	#1,s_step		zet stop step op 1
	move.b	#$f,ym_vol		en volume op 15
;		***** INITIALISEER VOICE STATUS STRUCTURE ******
	clr.b	Adata+sound_mode
	move.l	#env_0,Adata+env_ptr
	move.w	#2,Adata+env_att
	move.w	#5,Adata+env_sus
	move.w	#9,Adata+env_rel
	move.l	#env_0,Adata+pit_ptr
	move.w	#2,Adata+pit_att
	move.w	#5,Adata+pit_sus
	move.w	#9,Adata+pit_rel

	clr.b	Bdata+sound_mode
	move.l	#env_0,Bdata+env_ptr
	move.w	#2,Bdata+env_att
	move.w	#5,Bdata+env_sus
	move.w	#9,Bdata+env_rel
	move.l	#env_0,Bdata+pit_ptr
	move.w	#2,Bdata+pit_att
	move.w	#5,Bdata+pit_sus
	move.w	#9,Bdata+pit_rel

	clr.b	Cdata+sound_mode
	move.l	#env_0,Cdata+env_ptr
	move.w	#2,Cdata+env_att
	move.w	#5,Cdata+env_sus
	move.w	#9,Cdata+env_rel
	move.l	#env_0,Cdata+pit_ptr
	move.w	#2,Cdata+pit_att
	move.w	#5,Cdata+pit_sus
	move.w	#9,Cdata+pit_rel
;
	move.w	d7,sr		INT weer aan
	rts
;
;
;
;		***** EIGEN SOUND PLAY ROUTINE *****
;
do_play
;		***** DRIVE A LED OFF *****
	move.w	#$2700,sr	ignore MFP interrupts
	move.b	#14,psgreg	poort A
	move.b	psgreg,d0	lees data
	bset	#1,d0		zet LED uit
	move.b	d0,psgwrite	schrijf nieuwe waarde weg
	move.w	#$2500,sr	do not ignore MFP interrupts
; vanaf hier spelen in VBL queue
do_play_queue
;		***** LOOK AT MODE *****
	tst.b	pause_mode		wordt afspelen gepauseerd?
	bne	do_fx_all		ja -> doe wel effecten

	move.w	patmode,d1		haal manier rec/play mode
;					was het stopped mode?
	bne	no_stop_rp		nee -> gewoon door gaan
;		***** STOP MODE *****
	move.l	pat_base,a1	haal pointer naar begin van pattern
	move.w	pat_lin,d0	haal regel#
	mulu.w	#note_len,d0	vermenigvuldig met lengte 1 noot
	add.w	d0,a1		en tel op bij pointer in pattern
	move.l	a1,pat_ptr	sla pointer op voor later
;
	tst.b	done_something	is er iets gebeurd?
	beq	do_fx_all	nee -> doe effecten

	move.w	pat_lin,d0	haal regel#
	add.w	s_step,d0	ja -> tel stop step bij regel# op
	andi.w	#$3f,d0		en maskeer mogelijk regel# $40
	move.w	d0,pat_lin	sla regel# op
	st.b	pls_flag	print later pattern regels
	clr.b	done_something	wis 'er is iets gebeurd'-vlag
	bra	read_notes_all	lees noten
;		***** TEST PLAY *****
no_stop_rp
	cmpi.w	#6,d1			was het dan test play van YM edit screen
	bne.s	no_testplay		nee -> dan niet

	move.l	#pat_test,a1		pointer naar test pattern
	move.l	a1,pat_ptr		sla op voor later

	tst.b	asc_mode		wordt er een ASCII string ingevoerd?
	bne.s	now_asc_no_test		ja -> geen invoer hier

	clr.l	(a1)			wis test pattern
	clr.l	4(a1)			 """
	clr.l	8(a1)			 """
	lea	Bdata,a0		data veld kanaal B
	addq.l	#4,a1			naar kanaal B
	bsr	rec_note		neem noot op naar kanaal B
now_asc_no_test
	bra	read_notes_all		lees net opgenomen noten

no_testplay
	subq.w	#1,note_count		moet er een nieuwe noot gepakt worden?
	bne	do_fx_all		als niet zo -> spring over noot routine heen
;		***** VOER PATTERN REGEL UIT *****
	move.w	speed,note_count	herstel voordeler
;
;		***** BEREKEN POINTER IN PATTERN *****
	move.l	pat_base,a1	haal pointer naar begin van pattern
	move.w	pat_lin,d0	haal regel#
	mulu.w	#note_len,d0	vermenigvuldig met lengte 1 noot
	add.w	d0,a1		en tel op bij pointer in pattern
	move.l	a1,pat_ptr	sla pointer op voor later
;
	tst.b	led_mode	als LED niet mag -> mag opslaan en opnemen ook niet
	bne	now_asc_no_rec

	move.w	patmode,d0	haal pattern mode
	beq.s	no_store_lin	als mode=stop -> regel niet opslaan
	cmpi.w	#3,d0		doen we dan aan rec?
	bhs.s	no_store_lin	ja -> ook regel niet opslaan
;
	move.l	pat_restor3,a0	haal adres waar regel gerestored moet worden
	lea	pat_resbuf3,a2	adres restore buffer
	lea	pat_resbuf2,a3
	lea	pat_resbuf1,a4
;
	move.l	(a2),(a0)+	buffer 3 -> pattern
	move.l	4(a2),(a0)+
	move.l	8(a2),(a0)+

	move.l	(a3),(a2)	buffer 2 -> buffer 3
	move.l	4(a3),4(a2)
	move.l	8(a3),8(a2)

	move.l	(a4),(a3)	buffer 1 -> buffer 2
	move.l	4(a4),4(a3)
	move.l	8(a4),8(a3)

	move.l	(a1),(a4)+	pattern -> buffer 1
	move.l	4(a1),(a4)+
	move.l	8(a1),(a4)+
;
	move.l	pat_restor2,pat_restor3	ptr 2 -> ptr 3
	move.l	pat_restor1,pat_restor2	ptr 1 -> ptr 2
	move.l	a1,pat_restor1		#now -> ptr1
;
no_store_lin
;	
;
;		***** VOER RECORD ROUTINE UIT *****
	tst.b	asc_mode	wordt er nu een ASCII string ingevoerd?
	bne.s	now_asc_no_rec	ja -> geen record

	move.w	cursor,d0	haal cursor pos*4

	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern
	lea	cursor_data,a2	haal adres tabel met pointers naar data gebieden
	move.l	0(a2,d0.w),a0	haal adres data gebied

	lea	cursor_rec,a2	haal adres tabel met pointers naar routines voor verschillende RECORD routines
	move.l	0(a2,d0.w),a2	haal bij cursor pos horende routine
	jsr	(a2)		voer hem uit
;
now_asc_no_rec
	addq.w	#1,pat_lin	naar volgende regel
	move.w	pat_lin,d0	haal regel in pattern
	cmpi.w	#pat_len,d0	zijn we al bij het einde?
	bne	no_re_pat	als we het einde nog niet bereikt hebben -> ga door
	bsr	load_pos	haal nieuwe positie
no_re_pat
	st.b	pls_flag	teken later pattern regels
;
;		***** LEES NOTEN *****
read_notes_all
	clr.b	done_something	wis vlag die zegt dat er iets gebeurd is
	move.l	pat_ptr,a1	haal pointer in pattern weer terug

	lea	Adata,a0	haal adres channel A data-field
	bsr	getnote		lees noot

	lea	Bdata,a0	haal adres channel B data-field
	bsr	getnote		lees noot

	lea	Cdata,a0	haal adres channel C data-field
	bsr	getnote		lees noot

	move.b	#%11111111,d0		standaard masker voor REG #7
;	***** REG 7 : KANAAL C *****
	btst.b	#0,sound_mode(a0)	toon op kanaal C?
	beq.s	no_tone_c		nee -> niks doen
	bclr	#2,d0			ja -> wis bijhorende bit
no_tone_c
	btst.b	#1,sound_mode(a0)	ruis op kanaal C?
	beq.s	no_nois_c		nee -> niks doen
	bclr	#5,d0			ja -> wis bijhorende bit
no_nois_c
;	***** REG 7 : KANAAL B *****
	btst.b	#0,Bdata+sound_mode	toon op kanaal B?
	beq.s	no_tone_b		nee -> niks doen
	bclr	#1,d0			ja -> wis bijhorende bit
no_tone_b
	btst.b	#1,Bdata+sound_mode	ruis op kanaal B?
	beq.s	no_nois_b		nee -> niks doen
	bclr	#4,d0			ja -> wis bijheorende bit
no_nois_b
;	***** REG 7 : KANAAL A *****
	btst.b	#1,Adata+silent		wordt er een sample gespeeld?
	bne.s	no_nois_a		ja -> geen toon en geen ruis op kanaal A
	btst.b	#0,Adata+sound_mode	toon op kanaal A?
	beq.s	no_tone_a		nee -> niks doen
	bclr	#0,d0			ja -> wis bijhorende bit
no_tone_a
	btst.b	#1,Adata+sound_mode	ruis op kanaal A?
	beq.s	no_nois_a		nee -> niks doen
	bclr	#3,d0			ja -> wis bijheorende bit
no_nois_a

	move.w	#$2700,sr		MFP interrupts uit
	move.b	#7,psgreg		register 7
	move.b	d0,psgwrite		schrijf waarde weg
	move.w	#$2500,sr		MFP interrupts weer aan
;		***** GEEN NOOT, ENKEL EFFECTEN *****
do_fx_all
	lea	Cdata,a0	haal adres channel C data-field
	bsr	do_fx		doe envelope, tremolo etc.

	lea	Bdata,a0	haal adres channel B data-field
	bsr	do_fx		doe envelope, tremolo etc.

	lea	Adata,a0	haal adres channel A data-field
	bsr	do_fx		doe envelope, tremolo etc.
;		***** SCHRIJF FREQUENTIE EN VOLUME *****
	lea	psgreg,a1	adres PSG register select
	lea	psgwrite,a2	adres PSG write data
	move.w	#$2700,sr		MFP interrupts uit
;		***** KANAAL A *****
;	adres variabelen gebied kanaal A staat nog in a0
	btst.b	#1,silent(a0)		wordt er een sample gespeeld?
	bne.s	do_nout_A		ja -> doe niks met kanaal A registers
	move.w	PSGfreq(a0),d0		haal frequency both bytes
	move.b	PSGfreq(a0),d1		haal frequency hi-byte
	clr.b	(a1)			tone freq register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#1,(a1)
	move.b	d1,(a2)			schrijf hi-byte frequency

	tst.b	silent(a0)		staat dit kanaal aan?
	bne.s	no_hardw_auto_a		nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
	btst.b	#2,sound_mode(a0)	staat er uberhaupt hardware op dit kanaal?
	beq.s	no_hardw_auto_a
	btst.b	#3,sound_mode(a0)	staat hardware frequency op auto?
	beq.s	no_hardw_auto_a
	lsr.w	#4,d0			deel frequency door 16, voor hardware frequency
	move.b	#11,(a1)		hardware frequency register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#12,(a1)
	clr.b	(a2)			hi-byte frequency = 0
no_hardw_auto_a
	move.b	#8,(a1)			volume kanaal A
	move.b	PSGvol(a0),(a2)
do_nout_A
;		***** KANAAL B *****
	lea	Bdata,a0		adres variabelen gebied kanaal B
	move.w	PSGfreq(a0),d0		haal frequency both bytes
	move.b	PSGfreq(a0),d1		haal frequency hi-byte
	move.b	#2,(a1)			tone freq register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#3,(a1)
	move.b	d1,(a2)			schrijf hi-byte frequency

	tst.b	silent(a0)		staat dit kanaal aan?
	bne.s	no_hardw_auto_b		nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
	btst.b	#2,sound_mode(a0)	staat er uberhaupt hardware op dit kanaal?
	beq.s	no_hardw_auto_b
	btst.b	#3,sound_mode(a0)	staat hardware frequency op auto?
	beq.s	no_hardw_auto_b
	lsr.w	#4,d0			deel frequency door 16, voor hardware frequency
	move.b	#11,(a1)		hardware frequency register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#12,(a1)
	clr.b	(a2)			hi-byte frequency = 0
no_hardw_auto_b
	move.b	#9,(a1)			volume kanaal B
	move.b	PSGvol(a0),(a2)
;		***** KANAAL C *****
	lea	Cdata,a0		adres variabelen gebied kanaal C
	move.w	PSGfreq(a0),d0		haal frequency both bytes
	move.b	PSGfreq(a0),d1		haal frequency hi-byte
	move.b	#4,(a1)			tone freq register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#5,(a1)
	move.b	d1,(a2)			schrijf hi-byte frequency

	tst.b	silent(a0)		staat dit kanaal aan?
	bne.s	no_hardw_auto_c		nee -> laat hardware frequency dan -> voorkomt interferentie met andere kanalen
	btst.b	#2,sound_mode(a0)	staat er uberhaupt hardware op dit kanaal?
	beq.s	no_hardw_auto_c
	btst.b	#3,sound_mode(a0)	staat hardware frequency op auto?
	beq.s	no_hardw_auto_c
	lsr.w	#4,d0			deel frequency door 16, voor hardware frequency
	move.b	#11,(a1)		hardware frequency register
	move.b	d0,(a2)			schrijf lo-byte frequency
	move.b	#12,(a1)
	clr.b	(a2)			hi-byte frequency = 0
no_hardw_auto_c
	move.b	#10,(a1)			volume kanaal C
	move.b	PSGvol(a0),(a2)


	move.w	#$2500,sr			MFP interrupts weer aan
;
;		***** PRINT SPEC-O-METER, BOOTIFUL ADAMSKI EN PATTERN REGELS *****
	tst.b	pls_mode		moeten ze getekend worden?
	bne.s	no_print_pls		nee -> geen Adamski e.d.
	tst.b	menu_mode		staat menu mode op 0?(=geen menu, dus Adamski kan getekend worden)
	bne.s	no_print_adamski	nee -> geen Adamski en geen Spec-o-meter

	bsr	print_speco		teken Spec-o-meter
	bsr	print_adamski		teken adamski
no_print_adamski
	tst.b	pls_flag		moeten we regels printen?
	beq	no_print_pls		nee -> doe niks

	bsr	print_pls		print pattern lines
	clr.b	pls_flag		pattern lines getekend : niet meer tot weer update
no_print_pls
	tst.b	demo_mode		moeten we demo tekenen?
	beq.s	no_print_demo

	bsr	print_demo		ja -> print demo
no_print_demo
;
;
;
	rts				kom TERUG van routine
;
;		***** EFFECTEN *****
do_fx	tst.b	silent(a0)	kijk of dit kanaal stil moet zijn
	bne	do_silent	ja -> clear PSG volume
;
;		***** EFFECTEN : ENVELOPE *****
; volume variatie
	btst.b	#2,sound_mode(a0)	kijk of hardware envelope aan staat
	beq.s	no_he			nee -> doe niks
	move.b	#$10,PSGvol(a0)		zet volume op hardware envelope
	bra.s	to_tie			spring over rest heen

no_he	move.w	env_offs(a0),d0		haal envelope offset
	move.l	env_ptr(a0),a2		haal pointer naar envelope
	move.b	0(a2,d0.w),d1		haal lokaal volume
	move.b	g_vol(a0),d2		haal globaal volume
	asl.b	#4,d2			vermenigvuldig met 16 voor offset naar goede tabel
	add.b	d1,d2			tel lokaal volume bij globaal volume
	andi.w	#$ff,d2			maak word van volume
	lea	vols,a2			haal adres volume tabellen
	move.b	0(a2,d2.w),PSGvol(a0)	bereken volume dat uiteindelijk in PSG moet
; bereken volgende offset
	addq.w	#1,d0		verhoog offset

	cmp.w	env_sus(a0),d0	zijn we aan het begin van de release?
	bne.s	no_sus_rep	nee -> niet sustain herhalen
	move.w	env_att(a0),d0	ja -> zet offset weer op sustain
no_sus_rep
	cmp.w	env_rel(a0),d0	zijn we al (voor)bij het einde?
	blo.s	no_rel		nee -> volume niet 0 maken
	bset.b	#0,silent(a0)	zet silent bit van dit kanaal zodat dit kanaal zodirekt stil is
no_rel
	move.w	d0,env_offs(a0)	sla offset op
;
; 		***** EFFECTEN : TIE ***** 
; mooie overgang tussen twee verschillende frequenties
to_tie	move.w	tie_stp(a0),d0	haal stap voor tie
	beq.s	no_tie		als tie=0 -> geen tie
	bmi.s	tie_lo		bij negatieve stap is target lager dan huidige freq

	add.w	p_freq(a0),d0	verhoog frequentie met stap
	cmp.w	g_freq(a0),d0	is de frequentie op goede hoogte?
	blt.s	no_reach_tie_hi	als werkelijke frequentie lager is dan echte, zijn we er nog niet

	clr.w	tie_stp(a0)	wis tie stap
	move.w	g_freq(a0),d0	haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
no_reach_tie_hi
	move.w	d0,p_freq(a0)	zet frequentie weg
	bra.s	no_tie		sla tie lo over
;
tie_lo	add.w	p_freq(a0),d0	verlaag frequentie met stap
	cmp.w	g_freq(a0),d0	is de frequentie op goede hoogte?
	bgt.s	no_reach_tie_lo	als werkelijke frequentie hoger is dan echte, zijn we er nog niet

	clr.w	tie_stp(a0)	wis tie stap
	move.w	g_freq(a0),d0	haal echte frequentie -> soms wijkt de gemaakte af door scheve offsets
no_reach_tie_lo
	move.w	d0,p_freq(a0)	sla frequentie op
no_tie
;
;
;		***** EFFECTEN : VIBRATO *****
; frequentie variatie
	move.w	trem_offs(a0),d1	haal offset daarin
	add.w	vibr_speed(a0),d1	verhoog offset in tremolo tabel
	cmpi.w	#59,d1			zijn we al voorbij het einde
	bls.s	no_re_trem		nee -> ga door
	clr.w	d1			begin opnieuw aan tabel
no_re_trem
	move.w	d1,trem_offs(a0)	sla offset weer op
	asl.w	#1,d1			vermenig vuldig met 2 voor word tabel
	lea	trem_tab,a2		haal pointer naar tremolo tabel
	move.w	0(a2,d1.w),d1		pak variatie van frequentie
	move.w	vibr_depth(a0),d2	haal diepte van tremolo
	asr.w	d2,d1			maak goede diepte tremolo aan	
	add.w	p_freq(a0),d1		tel echte frequentie bij variatie op
;		***** EFFECTEN : INTERVALLEN *****
	move.b	int_now(a0),d0		bij welke interval zijn we nu?
	beq.s	intr_0			0=normale frequentie
	cmpi.b	#1,d0			1=interval #1
	beq.s	intr_1
	add.w	int_freq2(a0),d1	tel interval #2 bij huidige frequentie
	clr.b	int_now(a0)		volgende keer 0
	bra.s	intr_2
intr_1	add.w	int_freq1(a0),d1	tel interval #1 bij huidige frequentie
intr_0	addi.b	#1,int_now(a0)		verhoog interval count
intr_2	; laat frequentie in d1
;		***** EFFECTEN : PITCH ENVELOPE *****
	tst.b	pit_mode(a0)	staat pitch aan (vergelijkbaar met silent bit#0 voor amplitude envelope)
	beq.s	no_pitch	pitch uit -> tel er geen frequentie bij op

	move.w	pit_offs(a0),d0	haal pitch envelope offset
	move.l	pit_ptr(a0),a2	haal pointer naar envelope
	move.b	0(a2,d0.w),d2	haal relatieve frequentie
	ext.w	d2		sign-extend byte tot word
	add.w	d2,d1		tel relatieve frequentie bij huidige frequentie	
; bereken volgende offset
	addq.w	#1,d0		verhoog offset

	cmp.w	pit_sus(a0),d0	zijn we aan het begin van de release?
	bne.s	no_pit_sus_rep	nee -> niet sustain herhalen
	move.w	pit_att(a0),d0	ja -> zet offset weer op sustain
no_pit_sus_rep
	cmp.w	pit_rel(a0),d0	zijn we al (voor)bij het einde?
	blo.s	no_pit_rel	nee -> volume niet 0 maken
	clr.b	pit_mode(a0)	pitch afgelopen -> zet pitch afhandeling uit	
no_pit_rel
	move.w	d0,pit_offs(a0)	sla offset op
no_pitch
	move.w	d1,PSGfreq(a0)	sla frequentie op
;
	rts
;
do_silent
	clr.b	PSGvol(a0)	wis PSG volume
	rts
;
;		***** EINDE FX *****
;
;		***** LEES NOOT *****
getnote
	tst.b	(a1)		bekijk noot/octaaf
	beq	test_env	als octaaf/noot = 0 -> geen verandering, maar bekijk envelope
	bmi	sam_note	als octaaf/noot < 0 -> lees sample
;		***** NOOT : INSTRUMENT ******
	move.b	2(a1),d1	haal instrument nummer
	cmp.b	instr_no(a0),d1	hebben we dit instrument al?
	beq	same_instr	ja -> ga door

	cmp.b	#$3f,d1		vergelijk YMS# met maximum ($3f=63)
	bhi	same_instr	als d0>maximum -> verkeerd nummer en negeer dit instrument dus

	move.b	d1,instr_no(a0)	sla instrument nummer op voor vergelijking
	andi.w	#$3f,d1		maak word van YM sound
	lea	ym_sounds,a2	haal adres begin YM sounds
	asl.w	#8,d1		maal 256(=lengte 1 ym sound)
	add.w	d1,a2		tel die offset op bij start adres

	move.w	i_noise_freq(a2),d0	haal frequentie ruis
	move.w	d0,noise_freq(a0)	sla op
	btst.b	#1,i_sound_mode(a2)	heeft dit instrument noise aan?
	beq.s	no_instr_noise		nee -> zet frequentie dan niet in PSG
	move.w	#$2700,sr		disable MFP interrupts
	move.b	#6,psgreg		register #6 : noise freq
	move.b	d0,psgwrite
	move.w	#$2500,sr			re-enable MFP interrupts
no_instr_noise
	move.b	i_sound_mode(a2),sound_mode(a0)	haal sound mode
	move.w	i_env_freq(a2),h_env_freq(a0)	haal frequentie hardware envelope
	move.b	i_env_type(a2),h_env_type(a0)	haal type hardware envelope

	move.w	i_vibr_speed(a2),vibr_speed(a0)	haal snelheid van vibrato
	move.w	i_vibr_depth(a2),vibr_depth(a0)	haal diepte van vibrato
	move.w	i_interval1(a2),interval1(a0)	haal interval #1
	move.w	i_interval2(a2),interval2(a0)	haal interval #2

	clr.w	env_offs(a0)			clear envelope offset
	move.w	i_env_attack(a2),env_att(a0)	haal attack einde
	move.w	i_env_sustain(a2),env_sus(a0)	haal sustain einde
	move.w	i_env_release(a2),env_rel(a0)	haal release einde
	lea	i_env_start(a2),a3		haal start envelope tabel
	move.l	a3,env_ptr(a0)			

	clr.w	pit_offs(a0)			clear pitch envelope offset
	move.w	i_pit_attack(a2),pit_att(a0)	haal pitch attack einde
	move.w	i_pit_sustain(a2),pit_sus(a0)	haal pitch sustain einde
	move.w	i_pit_release(a2),pit_rel(a0)	haal pitch release einde
	lea	i_pit_start(a2),a3		haal start pitch envelope tabel
	move.l	a3,pit_ptr(a0)			
	st.b	pit_mode(a0)			zet pitch aan
same_instr
;		***** NOOT : OCTAAF & NOOT *****
	moveq	#0,d0		maak d0 leeg zodat we het zodirekt als word kunnen behandelen
	move.b	(a1),d0		haal octaaf(0-7) & noot (0-24 in stappen van 2)
	move.w	d0,d1		maak backup van octaaf
	lsr.w	#4,d1		haal octaaf# naar goede plaats
	lea	note_2_freq,a2	haal pointer naar noot->freq omreken tabel
	andi.w	#$f,d0		maskeer noot

	move.w	d0,d2		bewaar noot en gebruik d2
	asl.w	#1,d2		maal 2 voor offset in word tabel
	move.w	0(a2,d2.w),d2	haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
	lsr.w	d1,d2		verdubbel frequentie zovaak als octaaf nummer-1
	move.w	d2,g_freq(a0)	sla verkregen frequentie op
;
	move.w	d0,d3			bewaar noot en gebruik d3
	add.w	interval1(a0),d3	tel interval bij noot# op
	asl.w	#1,d3			maal 2 voor offset in word tabel
	move.w	0(a2,d3.w),d3		haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
	lsr.w	d1,d3			verdubbel frequentie zovaak als octaaf nummer-1
	sub.w	d2,d3			haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
	move.w	d3,int_freq1(a0)	sla interval frequency op
;
	add.w	interval2(a0),d0	tel interval bij noot# op
	asl.w	#1,d0			maal 2 voor offset in word tabel
	move.w	0(a2,d0.w),d0		haal bijhorende frequentie in octaaf 1 (is hier octaaf 0)
	lsr.w	d1,d0			verdubbel frequentie zovaak als octaaf nummer-1
	sub.w	d2,d0			haal van nieuwe frequentie oorspronkelijke frequentie af, voor relative frequentie
	move.w	d0,int_freq2(a0)	sla interval frequency op
;
;
;		***** NOOT : TIE *****
	move.b	1(a1),d1	haal tie waarde
	beq.s	no_calc_tie	als tie value=0 dan is er geen tie
calc_tie
;				in d2 zit huidige frequentie nog
	sub.w	p_freq(a0),d2	trek huidige frequentie van target freq af voor step
	ext.l	d2		maak long van step voor delen
	andi.l	#$ff,d1		maak long van aantal te 'tie'en noten
	muls.w	speed,d1	vermenigvuldig " met speed
	divs.w	d1,d2		deel d2 door snelheid*noten voor tie stap
	beq.s	no_calc_tie	als tie stap=0 zet freq meteen goed

	move.w	d2,tie_stp(a0)	sla tie stap op
	bra.s	yes_calc_tie
no_calc_tie
	move.w	g_freq(a0),p_freq(a0)	zet globale frequentie meteen als huidige frequentie
	clr.w	tie_stp(a0)		clear tie stap
yes_calc_tie
;		***** NOOT : VOLUME ******
	move.b	3(a1),d0	haal envelope/volume
	andi.w	#$1f,d0		maskeer volume en verwijder envelope en maak er tegelikertijd een word van
	move.b	d0,g_vol(a0)	sla volume op
;		***** NOOT : ENVELOPE *****
test_env
	addq.l	#3,a1
	move.b	(a1)+,d1	haal envelope value(& volume)
	lsr.b	#6,d1		verschuif hem naar de onderste bits en verwijder volume
	tst.b	d1		*******
	beq.s	same_env	als envelope value=0 (NO_CHANGE), dan niks veranderen

	btst.b	#2,sound_mode(a0)	wordt hardware envelope op dit kanaal gespeeld?
	bne.s	he_adsr			ja -> voer dat soort envelope uit

	cmpi.b	#1,d1		is envelope value dan 1?
	beq.s	attack_env	ja -> doe attack deel van envelope

	cmpi.b	#2,d1		is envelope value dan 2?
	beq.s	sustain_env	ja -> begin envelope bij sustain
********		dan maar release doen :
	move.w	env_sus(a0),env_offs(a0)	zet offset op begin release
	move.w	pit_sus(a0),pit_offs(a0)	zet pitch offset op begin release
	bclr.b	#0,silent(a0)			clear silent bit
	st.b	pit_mode(a0)			zet pitch aan
	rts
********
sustain_env
	move.w	env_att(a0),env_offs(a0)	zet offset op begin sustain
	move.w	pit_att(a0),pit_offs(a0)	zet pitch offset op begin sustain
	bclr.b	#0,silent(a0)			clear silent bit
	st.b	pit_mode(a0)			zet pitch aan
	rts
********
attack_env
	clr.w	env_offs(a0)		doe attack deel van envelope -> zet offset op 0
	clr.w	pit_offs(a0)		zet pitch envelope goed
	clr.w	trem_offs(a0)		zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
	bclr.b	#0,silent(a0)		clear silent bit
	st.b	pit_mode(a0)		zet pitch aan
	move.w	#$2700,sr		interrupts uit
	bclr.b	#1,silent(a0)		clear sample bit
	beq.s	dont_stop_sam		als er geen sample op dit kanaal gespeeld werd -> doe niks
	bclr.b	#TA_bn,IERA		wel sample hier -> zet timer A uit
********
dont_stop_sam
	move.w	#$2500,sr	interrupts weer aan
same_env
	rts			kom terug van subroutine
;
;		***** EINDE NOOT *****
;
;		***** HARDWARE ENVELOPE ADSR *****
he_adsr	tst.b	d1		is envelope value dan 0?
	beq	cont_he		ja -> laat envelope als hij is

	cmpi.b	#2,d1		is envelope value dan 2?
	beq	sustain_he	ja -> begin envelope bij sustain

	cmpi.b	#3,d1		is envelope value dan 3?
	beq	release_he	ja -> begin envelope bij release
; ATTACK:
	move.w	#$2700,sr			geen oderbreking graag
	btst.b	#3,sound_mode(a0)		staat hardware automatic frequency aan?
	bne.s	attack_hardw_auto		ja -> zet frequency niet; dat doet PSGfreq later
	move.b	#11,psgreg			hardware envelope frequency
	move.b	h_env_freq+1(a0),psgwrite
	move.b	#12,psgreg			...
	move.b	h_env_freq(a0),psgwrite
attack_hardw_auto
	move.b	#13,psgreg		selecteer hardware envelope type register
	btst.b	#0,h_env_type(a0)	is dit een enkelvoudige envelope(niet continious)
	bne.s	yes_hardw_type		ja -> zet hardware type in PSG om weer aan het begin te beginnen
	move.b	psgreg,d0		nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
	cmp.b	h_env_type(a0),d0	staat goede hardware type al in PSG?
	beq.s	no_hardw_type		ja -> laat het maar
yes_hardw_type
	move.b	h_env_type(a0),psgwrite	zet hardware envelope type in PSG
no_hardw_type
	clr.w	trem_offs(a0)			zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
	clr.w	pit_offs(a0)			zet pitch offset op begin attack
	st.b	pit_mode(a0)			zet pitch envelope aan
	bclr.b	#0,silent(a0)			clear silent bit
	bclr.b	#1,silent(a0)			clear sample bit
	beq.s	same_he				als er geen sample op dit kanaal gespeeld werd -> doe niks
	bclr.b	#TA_bn,IERA			wel sample hier -> zet timer A uit
same_he	move.w	#$2500,sr
cont_he	rts
; SUSTAIN:
sustain_he
	move.w	#$2700,sr			geen oderbreking graag
	btst.b	#3,sound_mode(a0)		staat hardware automatic frequency aan?
	bne.s	sustain_hardw_auto		ja -> zet frequency niet; dat doet PSGfreq later
	move.b	#11,psgreg			hardware envelope frequency
	move.b	h_env_freq+1(a0),psgwrite
	move.b	#12,psgreg			...
	move.b	h_env_freq(a0),psgwrite
sustain_hardw_auto
	move.b	#13,psgreg		selecteer hardware envelope type register
	btst.b	#0,h_env_type(a0)	is dit een enkelvoudige envelope(niet continious)
	bne.s	yes_sus_htype		ja -> zet hardware type in PSG om weer aan het begin te beginnen
	move.b	psgreg,d0		nee -> zet hardware frequentie alleen neer als die er niet al staat -> zet hardware freq zo min mogelijk in PSG, om kraken tegen te gaan
	cmp.b	h_env_type(a0),d0	staat goede hardware type al in PSG?
	beq.s	no_sus_htype		ja -> laat het maar
yes_sus_htype
	move.b	h_env_type(a0),psgwrite	zet hardware envelope type in PSG
no_sus_htype
	clr.w	trem_offs(a0)			zet tremolo offset op begin zodat iedere noot hetzelfde klinkt
	move.w	pit_att(a0),pit_offs(a0)	zet pitch offset op begin sustain(=einde attack)
	st.b	pit_mode(a0)			zet pitch envelope aan
	bclr.b	#0,silent(a0)			clear silent bit
	bclr.b	#1,silent(a0)			clear sample bit
	beq	same_sus_he			als er geen sample op dit kanaal gespeeld werd -> doe niks
	bclr.b	#TA_bn,IERA			wel sample hier -> zet timer A uit
same_sus_he	move.w	#$2500,sr
	rts
; RELEASE:
release_he
	bset.b	#0,silent(a0)			zet silent bit
	rts
;
;		***** LEES SAM NOOT *****
sam_note
	btst.b	#2,silent(a0)	moeten we muten?
	bne.s	no_new_sam	als mute bit=1 -> kanaal wordt gemute

	move.b	2(a1),d0	haal sample nummer

	andi.w	#$f,d0		neem alleen laagste nibble en maak er een word van
	lea	sam_tab,a2	haal adres sample tabel

	asl.w	#2,d0			voor offset in tabel met longs
	move.w	#$2700,sr		MFP interrupts uit
	move.l	0(a2,d0.w),s_start	schrijf adres sample in sample adres

	move.b	1(a1),d0		haal hertz
	andi.w	#$f,d0			neem alleen laagste nibble en maak er een word van
	lea	hertz,a2		start of hertz -> speed conversion table
	move.b	0(a2,d0.w),TADR		convert hertz into timer A data

	move.b	#%010,silent(a0)	zodat de REG 7 routine weet dat er een sample gespeeld wordt en toon en ruis dus uit moeten
	bset.b	#TA_bn,IERA		timer A weer aan

	tst.b	led_mode		moet LED niet aan?
	bne.s	no_led			ja -> hou hem zoals hij is
	move.b	#14,psgreg		poort A
	move.b	psgreg,d0		lees data
	bclr	#1,d0			zet LED aan
	move.b	d0,psgwrite		schrijf nieuwe waarde weg
no_led
	move.w	#$2500,sr		MFP interrupts weer aan
no_new_sam
	addq.l	#4,a1		schuif pointer in pattern regel op
	rts			einde	

;
;		***** RECORD YM NOOT *****
;
recA	tst.b	rec_mode	kijk hoe er opgenomen moet worden
	beq	rec_sam		als rec mode=0 -> neem sample noot op
;
rec_note
	tst.b	midi_or_kb	spelen met KeyBoard of MIDI?
	bne	rec_midi	flag gezet -> neem op van MIDI

	lea	key_2_note,a2	haal adres key->noot tabel
	moveq	#0,d7		zodat we d7 als word kunnen gebruiken
	move.b	key_raw,d7	haal toets van toetsenbord
	beq	no_ym_note	als toets=0, geen verandering

	bclr	#7,d7		toets losgelaten ?
	bne.s	loose_key	if bit#7=1 toets losgelaten
;
	move.b	0(a2,d7.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	no_ym_note	als die 0 zijn (geen noot) => doe iets anders
	move.b	octave,d1	haal basis octaaf
	asl.b	#4,d1		vermenigvuldig met 16
	add.b	d1,d0		tel op bij offset octaaf	

	move.b	d0,(a1)		sla noot en octaaf op
	move.b	ym_tie,1(a1)	zet tie in pattern
	move.b	ym_sound,2(a1)	zet instrument in pattern
	move.b	ym_vol,3(a1)	zet volume in pattern

	move.b	key_mode,d0	haal manier van opnemen (0=RELEASE,1=ATTACK,2=SUSTAIN)
	cmpi.b	#2,d0		is het sustain?
	beq.s	key_sus		ja -> zet een 2 als envelope value
	or.b	#1*64,3(a1)	envelope value is 1(*64)(=attack)
	bra.s	key_mode_end
key_sus	or.b	#2*64,3(a1)	envelope value is 2(*64)
key_mode_end

	move.b	d7,key_last	sla huidige toets weer op voor check bij volgende ingedrukte toets
	clr.b	key_raw		clear ruwe toetsen buffer
	rts
;
loose_key
	tst.b	key_mode	moet er eigenlijk wel gereleased worden?
	bne.s	no_release_rec	nee -> neem geen release op
	lea	key_2_note,a0	tabel die scancodes omrekent in octaaf/noot
	tst.b	0(a0,d7.w)	kijk of ingedrukte toets noot zou veroorzaken
	beq.s	no_release_rec	nee -> neem geen release op
	move.l	#192,(a1)	clear bytes en zet envelope op release
no_release_rec
	clr.b	key_last	er wordt nu geen toets ingedrukt
	clr.b	key_raw		clear ruwe toetsen buffer
	rts
;
no_ym_note
	moveq	#0,d0
	move.b	key,d0		wordt er eigenlijk een toets ingedrukt?
	beq.s	no_zeros	geen toets -> niks doen

	cmpi.b	#57,d0			wordt spatie ingedrukt?
	beq.s	yes_space_silent	ja -> dan geluid uitzetten

	tst.b	key_mode	kijk of we releasend inspelen
	bne.s	no_zeros	nee -> wis niks
	lea	key_2_note,a0	tabel die scancodes omrekent in octaaf/noot
	tst.b	0(a0,d0.w)	kijk of huidige toets noot zou veroorzaken
	beq.s	no_zeros	nee -> wis niks
	clr.l	(a1)		wis noot
no_zeros
	clr.b	key_raw		clear ruwe toetsen buffer
	rts
yes_space_silent
	bset.b	#0,silent(a0)	stilte graag
	clr.l	(a1)		wis noot
	clr.b	key_raw		clear ruwe toetsen buffer
	rts
;		***** EINDE YM RECORD *****
;
;		***** MIDI RECORD *****
rec_midi
	lea	midi_2_note,a2	haal adres key->noot tabel
	moveq	#0,d7		zodat we d7 als word kunnen gebruiken
	move.b	midi_note,d7	haal toets van toetsenbord
	beq.s	no_midi_note	als toets=0, geen verandering

	tst.b	midi_velo	toets los (velocity=0)
	beq.s	loose_midi
;
	move.b	0(a2,d7.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	midi_mode_end	als die 0 zijn (geen noot) => doe iets anders
	move.b	octave,d1	haal basis octaaf
	asl.b	#4,d1		vermenigvuldig met 16
	add.b	d1,d0		tel op bij offset octaaf	
	bclr	#7,d0		bij te hoge octaaf gewoon weer naar lage octaven

	move.b	d0,(a1)		sla noot en octaaf op
	move.b	ym_tie,1(a1)	zet tie in pattern
	move.b	ym_sound,2(a1)	zet instrument in pattern
	move.b	ym_vol,3(a1)	zet volume in pattern

	move.b	key_mode,d0	haal manier van opnemen (0=RELEASE,1=ATTACK,2=SUSTAIN)
	beq.s	rel_midi	0=RELEASE
	cmpi.b	#1,d0		is het ATTACK?
	beq.s	att_midi	1=ATTACK
	or.b	#2*64,3(a1)	envelope value is 2(*64)
	bra.s	midi_mode_end
rel_midi
	st.b	midi_in		MIDI toets wordt ingedrukt
att_midi
	or.b	#1*64,3(a1)	envelope value is 1(*64)(=attack)
midi_mode_end
	clr.b	midi_note	clear toetsen buffer
	rts
;
loose_midi
	tst.b	key_mode	moet er eigenlijk wel gereleased worden?
	bne.s	no_release_midi	nee -> neem geen release op
	move.l	#192,(a1)	clear bytes en zet envelope op release
no_release_midi
	clr.b	midi_note	clear toetsen buffer
	clr.b	midi_in		toets is los
	rts
;
no_midi_note
	tst.b	midi_in		wordt er een toets ingedrukt?
	beq.s	no_midi_in	nee -> zet geen nullen neer
	clr.l	(a1)		wis bytes
no_midi_in
	clr.b	midi_note	clear toetsen buffer
	rts	
;
;
;		***** SAMPLE RECORD *****
rec_sam	moveq	#0,d0
	move.b	key_in,d0	haal net ingedrukte toets
	lea	key_2_note,a2	haal adres key->noot tabel
	move.b	0(a2,d0.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	try_space	als die 0 zijn (geen noot) => misschien spatie

	lea	note_2_sam,a2	reken noot om naar sam#
	move.b	0(a2,d0.w),d0	haal sam#
	bmi.s	try_space	als sam#=-1 -> verkeerd noot# -> misschien spatie

	move.l	#$ff000000,(a1)		ten teken dat dit een sample noot is
	move.b	d0,2(a1)		sla sample nummer op
	lea	sam_rates,a2		adres sample rates voor iedere sample
	move.b	0(a2,d0.w),1(a1)	sla sample rate op

	clr.b	key_in			clear keyboard buffer
	rts
;
try_space
	move.b	key,d0		haal huidige toets
	cmpi.b	#57,d0		is het spatie?
	bne.s	no_sam_space	nee -> doe niks

	clr.l	(a1)		clear noot
no_sam_space
	clr.b	key_in		clear keyboard buffer
	rts
;
;
;
;		***** GET ROUTINES VOOR STOPPED MODE *****
getA_note
	tst.b	rec_mode	kijk hoe er opgenomen moet worden
	beq	sam_get		als rec mode=0 -> neem sample noot op
;		***** GET : YM NOTE *****
get_note
	bsr	save_undo	sla huidige pattern en block buffer op
	tst.b	midi_or_kb	moeten we opnemen van MIDI of toetsenbord
	bne.s	stop_midi	vlag gezet -> neem op van MIDI

	moveq	#0,d7		zodat we d7 als word kunnen gebruiken
	move.b	key,d7		haal toets
	lea	key_2_note,a2	haal adres key->noot tabel
	move.b	0(a2,d7.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	nada		als die 0 zijn (geen noot) => doe niets
	move.b	octave,d1	haal basis octaaf
	asl.b	#4,d1		vermenigvuldig met 16
	add.b	d1,d0		tel op bij offset octaaf	

	move.b	d0,(a1)		sla noot en octaaf op
	move.b	ym_tie,1(a1)	zet tie in pattern
	move.b	ym_sound,2(a1)	zet instrument in pattern
	move.b	ym_vol,3(a1)	zet volume in pattern
	bset	#6,3(a1)	zet envelope op attack

	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
nada	rts
;
;		***** GET : MIDI NOTE *****
stop_midi
	lea	midi_2_note,a2	haal adres key->noot tabel
	moveq	#0,d7		zodat we d7 als word kunnen gebruiken
	move.b	midi_cur,d7	haal toets van MIDI

	move.b	0(a2,d7.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	nada		als die 0 zijn (geen noot) => doe iets anders
	move.b	octave,d1	haal basis octaaf
	asl.b	#4,d1		vermenigvuldig met 16
	add.b	d1,d0		tel op bij offset octaaf
	bclr	#7,d0		bij te hoge octaaf gewoon weer naar lage octaven
		
	move.b	d0,(a1)		sla noot en octaaf op
	move.b	ym_tie,1(a1)	zet tie in pattern
	move.b	ym_sound,2(a1)	zet instrument in pattern
	move.b	ym_vol,3(a1)	zet volume in pattern
	bset	#6,3(a1)	zet envelope op attack

	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;
;
;		***** GET : SAMPLE NOOT *****
sam_get	bsr	save_undo	sla huidige pattern en block buffer op

	moveq	#0,d0
	move.b	key,d0		haal toets
	lea	key_2_note,a2	haal adres key->noot tabel
	move.b	0(a2,d0.w),d0	haal offset octaaf en noot die bij toets horen
	beq.s	nada		als die 0 zijn (geen noot) => doe niets

	lea	note_2_sam,a2	reken noot om naar sam#
	move.b	0(a2,d0.w),d0	haal sam#
	bmi.s	nada		als sam#=-1 -> verkeerd noot# -> doe niets

	move.l	#$ff000000,(a1)		ten teken dat dit een sample noot is
	move.b	d0,2(a1)		sla sample nummer op
	lea	sam_rates,a2		adres sample rates voor iedere sample
	move.b	0(a2,d0.w),1(a1)	sla sample rate op

	st.b	done_something		zodat stop routine weet dat er iets is gebeurd
	rts
;
;		***** GET : OCTAVE *****
get_octave
	tst.b	(a1)		bekijk noot/octaaf
	bmi.s	no_get_octave	<0 : sample noot -> geen octaaf invoer
	beq.s	no_get_octave	=0 : geen noot -> geen octaaf invoer

	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets
	cmpi.b	#7,d0		is het groter dan 7?
	bhi	nada		ja -> doe niets

	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_octave	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_octave
	andi.b	#$f,(a1)	bewaar noot#
	asl.b	#4,d0		verschuif waarde naar upper nibble
	or.b	d0,(a1)		voeg upper nibble(=octave) toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
no_get_octave
	rts
;
;		***** GET : TIE HIBYTE *****
get_tie_h
	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets
	cmpi.b	#3,d0		is het groter dan 3
	bhi	nada		ja -> doe niets

	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_tie_h	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_tie_h
	andi.b	#$f,1(a1)	bewaar lower nibble
	asl.b	#4,d0		verschuif waarde naar upper nibble
	or.b	d0,1(a1)	voeg upper nibble toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;		***** GET : TIE LOBYTE *****
get_tie_l
	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets

	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_tie_l	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_tie_l
	andi.b	#$f0,1(a1)	bewaar upper nibble
	or.b	d0,1(a1)	voeg lower nibble toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;		***** GET : SOUND HIBYTE *****
get_snd_h
	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets
	cmpi.b	#3,d0		is het groter dan 3
	bhi	nada		ja -> doe niets
	
	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_snd_h	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_snd_h
	andi.b	#$f,2(a1)	bewaar lower nibble
	asl.b	#4,d0		verschuif waarde naar upper nibble
	or.b	d0,2(a1)	voeg upper nibble toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;		***** GET : SOUND LOBYTE *****
get_snd_l
	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets

	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_snd_l	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_snd_l
	andi.b	#$f0,2(a1)	bewaar upper nibble
	or.b	d0,2(a1)	voeg lower nibble toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;		***** GET : VOLUME *****
get_vol	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_hex,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets

	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_vol	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_vol
	andi.b	#%11000000,3(a1)	bewaar bovenste 2 (envelope) bits
	or.b	d0,3(a1)		voeg volume toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;		***** GET : ENVELOPE *****
get_env	moveq	#0,d0		om d0 als word te gebruiken
	move.b	key,d0		bekijk toets

	lea	key_2_env,a0	tabel die scancodes omrekent in getallen
	move.b	0(a0,d0.w),d0	haal waarde
	bmi	nada		negatief -> doe niets
	
	tst.w	patmode		zijn we in stop-mode?
	bne.s	no_su_env	nee -> vul undo-buffers niet
	bsr	save_undo	sla huidige pattern en block buffer op
no_su_env
	andi.b	#$1f,3(a1)	bewaar onderste 5 volume bits
	asl.b	#6,d0		verschuif waarde naar bovenste 2 bits
	or.b	d0,3(a1)	voeg bovenste bits toe
	st.b	done_something	zodat stop routine weet dat er iets is gebeurd
	rts
;
;
;		***** EINDE GET ROUTINES *****
;
;		***** SAMPLE INTERRUPT ROUTINE *****
; Timer A interrupt routine : speelt sample af
intnorm	move.l	a5,-(sp)		sla register op
	move.l	s_start(pc),a5		haal pointer in ssample
	move.b	#8,$ffff8800.w		PSG register 8 = volume kanaal A
	move.b	(a5)+,$ffff8802.w		zet volume
	bmi.s	nextsam			if volume<0 -> sample finished -> clear interrupt
	move.l	a5,s_start		sla pointer in sample weer op
	move.l	(sp)+,a5		haal register terug
	bclr.b	#TA_bn,ISRA		clear in-service bit
	rte				return from exception

nextsam	clr.b	psgwrite		zet volume op 0
	move.b	#%001,Adata+silent	er wordt geen sample gespeeld maar wees toch stil
	bclr.b	#TA_bn,IERA		zet timer A uit
	move.l	(sp)+,a5		haal register terug
	bclr.b	#TA_bn,ISRA		clear in-service bit
	rte				return from exception
;
s_start	ds.l	1
;
;		***** EINDE SAMPLE INTERRUPT ROUTINE *****
;
;		***** ZEND TEKENS NAAR TOETSEN BORD *****
pause_kb
	move.b	#$13,d0		KeyBoardString die de keyboard meldingen stopt
	bsr	kb_send		stuur character
   	clr.w	nxt_mouse	geen tekens meer van muis ontvangen
	rts
;
resume_kb
	move.b	#$11,d0		KBS die de keyboard meldingen hervat
	bsr	kb_send		stuur character
	rts	
;
; d0.b = te sturen teken
;
kb_send	btst.b	#1,kb_ctrl	kan er een teken gezonden worden? (TDRE-bit)
	beq.s	kb_send		als bit nog 0 is -> niet zenden

	move.b	d0,kb_data	zend byte
	rts			als de byte verzonden is -> terugkomen
;
;
;		***** ONTVANG TEKENS VAN TOETSENBORD *****
own_kb	movem.l	d0-d7/a0-a6,-(sp)	sla registers op
next_int
	bsr	kb_int		kijk of er een toetsenbord interrupt gekomen is
	bsr	midi_int	kijk of er een MIDI interrupt gekomen is
	btst.b	#4,$fffffa01.w	meer interrupts?
	beq.s	next_int	ja -> doe die dan
	bclr.b	#6,$fffffa11.w	clear service-bit
	movem.l	(sp)+,d0-d7/a0-a6	restore registers
	rte
;
kb_int	lea	kb_ctrl,a0	adres KeyBoard ACIA
	move.b	(a0),d2		haal KeyBoard status
	btst	#7,d2		interrupt request?
	beq.s	no_kb_int	nee -> doe niets
	btst	#0,d2		reciever buffer vol
	beq	no_kb_full	nee -> check op error
	bsr	get_kb_byte	haal byte van toetsenbord
no_kb_full
	andi.b	#$20,d2		check op error
	beq	no_kb_int	geen error -> doe niets
	move.b	2(a0),d0	lees byte van ACIA en doe er niets mee
no_kb_int
	rts
;
get_kb_byte
	move.b	2(a0),d0	haal byte van ACIA
	tst.w	nxt_mouse	zijn er nog muis bytes op te halen?
	bne	mouse_recieve	ja -> doe het dan

	cmpi.b	#$f8,d0		is dit een relatieve muis melding?
	bhs	mouse_pos	als dat zo is -> ontvang die melding

	cmpi.b	#42,d0		is dit Shift links in?
	beq	shift_lin
	cmpi.b	#128+42,d0	is dit Shift links uit?
	beq	shift_lout
	cmpi.b	#54,d0		is dit Shift rechts in?
	beq	shift_rin
	cmpi.b	#128+54,d0	is dit Shift rechts uit?
	beq	shift_rout

	bclr	#7,d0		wordt toets losgelaten of ingedrukt?
	bne.s	dekey		los -> doe iets anders
	
	clr.b	midi_or_kb	laat opneem routine van KeyBoard zijn noten halen
	clr.w	vbl_wait_k	laat VAPOS toets meteen bekijken
	clr.b	no_key_repeat	en zet ook repeat blokkering uit
	move.b	d0,key_raw	sla zuivere data op
	move.b	d0,key_in	sla laatst ingedrukte toets op
	move.b	d0,key		zet scancode in variabele
	rts
;
dekey	cmp.b	key,d0		is dit de toets die in key staat?
	bne.s	no_cur_key	als niet zelfde -> was een vorige toets, dus niets doen
	clr.b	key		wel zelfde -> nu geen toets gedrukt, dus clear key

no_cur_key
	cmp.b	key_last,d0	is het misschien de laatste geregistreerde toets?
	beq.s	mess_key	ja -> geef bericht
	cmp.b	key_raw,d0	is het misschien de laatst ingedrukte toets deze record cycle?
	beq.s	mess_key	ja -> geef bericht
	rts

mess_key
	bset	#7,d0		zet bit #7 voor loslaat bericht
	move.b	d0,key_raw	loslaat bericht voor RECORD routine
	rts
;
shift_lin
	bset.b	#0,shiftmode	zet bit voor linker shift aan
	rts
;
shift_lout
	bclr.b	#0,shiftmode	zet bit voor linker shift uit
	rts
;
shift_rin
	bset.b	#1,shiftmode	zet bit voor rechter shift aan
	rts
;
shift_rout
	bclr.b	#1,shiftmode	zet bit voor rechter shift uit
	rts
;
;		***** ONTVANG RELATIEVE MUISPOSITIE *****
;
mouse_pos
	lea	mouse_stat,a0		adres muisstatus struct
	move.b	d0,(a0)+		sla muis knoppen op
	move.l	a0,mouse_ptr		sla pointer in muis status struct op
	move.w	#2,nxt_mouse		nog 2 bytes ontvangen
	rts
;
mouse_recieve
	move.l	mouse_ptr,a0	pointer in mouse status struct
	move.b	d0,(a0)+	sla byte op in mouse status struct
	move.l	a0,mouse_ptr	sla pointer in mouse status struct weer op
	subq.w	#1,nxt_mouse	was dit de laatste byte?
	beq.s	new_mouse_pos	ja -> bereken nieuwe muis positie
	rts
***
new_mouse_pos
	move.w	mousex,d0	haal x positie
	move.b	mrelx,d1	relatieve x positie
	ext.w	d1		maak er een word van
	add.w	d1,d0		tel er relatieve positie bij
	bmi.s	no_new_mx	als nieuwe x<0 -> laat maar zitten
	cmpi.w	#319,d0		is x pos groter dan 319?
	bhi.s	no_new_mx	als dat zo is -> laat maar zitten
	move.w	d0,mousex	sla nieuwe muis positie op
no_new_mx
	move.w	mousey,d0	haal y positie
	move.b	mrely,d1	relatieve y positie
	ext.w	d1		maak er een word van
	add.w	d1,d0		tel er relatieve positie bij
	bmi.s	no_new_my	als nieuwe y<0 -> laat maar zitten
	cmpi.w	#199,d0		is y pos groter dan maximum?
	bhi.s	no_new_my	als dat zo is -> laat maar zitten
	move.w	d0,mousey	sla nieuwe muis positie op
no_new_my
	rts
;		***** MIDI HOOFD INTERRUPT ROUTINE ****
midi_int
	lea	md_ctrl,a0	adres MIDI ACIA
	move.b	(a0),d2		haal MIDI status
	btst	#7,d2		interrupt request?
	beq.s	no_md_int	nee -> doe niets
	btst	#0,d2		reciever buffer vol
	beq	no_md_full	nee -> check op error
	bsr	get_md_byte	haal byte van toetsenbord
no_md_full
	andi.b	#$20,d2		check op error
	beq	no_md_int	geen error -> doe niets
	move.b	2(a0),d0	lees byte van ACIA en doe er niets mee
no_md_int
	rts
;
;		***** HAAL BYTE VAN MIDI ****
get_md_byte
	move.b	2(a0),d0	haal byte van MIDI-ACIA
	st.b	midi_or_kb	laat opneem routine van MIDI zijn noten halen
	move.b	md_data,d0	haal MIDI data
	btst	#7,d0		is dit een STATUS byte?
	bne.s	midi_stat	ja -> ontvang status byte
; DATA byte
	move.b	midi_mode,d1	wat moeten we van MIDI ontvangen?
	beq.s	no_midi
;
	cmpi.b	#1,d1		moeten we dan noot ontvangen?
	bne.s	get_midi_velo	<>1 : ontvang velocity

	move.b	d0,temp_note	het was een noot#
	move.b	#2,midi_mode	volgende DATA byte is velocity
	bra.s	no_midi
get_midi_velo
	move.b	#1,midi_mode	wacht weer op MIDI noot
	tst.b	d0		toets in of uit
	beq.s	get_midi_loose	velocity=0 -> toets uit

	move.b	d0,midi_velo		geef velocity door aan record routine
	move.b	temp_note,midi_note	geef noot# ook door aan record routine
	move.b	temp_note,midi_cur	velocity<>0 -> toets in -> maak daar huidige toets van
	bra.s	no_midi

get_midi_loose
	move.b	temp_note,d0	haal toets die net werd losgelaten
	cmp.b	midi_cur,d0	is huidige toets, toets die net losgelaten werd?
	bne.s	no_midi		nee -> accepteer release niet
	clr.b	midi_velo	zet velocity op 0(=RELEASE)
	st.b	midi_note	zet noot# zodat de record routine weet dat er iets ingedrukt werd
	clr.b	midi_cur	huidige MIDI toets ook wissen
no_midi
	rts
; MIDI Status byte ontvangen :
midi_stat
	andi.b	#$f0,d0		filter kanaal# weg
	cmpi.b	#$90,d0		was het een NOTE ON melding?
	bne.s	no_midi_note_on
	move.b	#1,midi_mode
	rts
no_midi_note_on
	clr.b	midi_mode	geen bytes ontvangen
	rts
;
;
;
;		***** WACHT OP VBL *****
wvbl	move.w	vbl_count,d0	haal waarde vbl teller
still_no_vbl
	cmp.w	vbl_count,d0	wacht tot hij veranderd
	beq.s	still_no_vbl

	rts
;
;		***** VBL : MUIS TEKENEN EN MUZIEK DOEN *****
;
own_vbl
	movem.l	d0-d7/a0-a6,-(sp)	sla registers op
;
	tst.b	rasmode			moeten er rasters zijn?
	bne.s	no_rasters
	move.l	#raspal,raspalptr	zet palet-teller terug
	move.b	#8,bdata		begin bij regel #8
	move.b	#8,bcontrol		zet Timer B aan
no_rasters
;
	bsr	clr_mouse	haal muis van scherm
	bsr	put_mouse	zet muis op scherm

	bsr	do_play		doe muziek routine

	addq.w	#1,vbl_count	verhoog VBL teller
	bne.s	no_vblc_0	is VBL 0 geworden?

	clr.w	vbl_last_m	zet laatste VBL van muis en toetsenbord op 0
	clr.w	vbl_last_k	zodat we niet een eeuwigheid hoeven te wachten
no_vblc_0	
	movem.l	(sp)+,d0-d7/a0-a6
;				herstel registers
	rte			einde VBL
;
;	***** TIMER B : COLOR CHANGE FOR SPEC-O-METER *****
;
intras	subq.w	#1,line_cnt		laatste regel al bereikt ?
	bmi.s	stopcol			ja -> stop rasters

	move.l	a6,-(sp)		sla a6 op
	move.l	raspalptr(pc),a6	haal pointer naar juiste rasterkleur
	move.w	(a6)+,col0+2*7		zet nieuwe kleur in kleur #7
	move.l	a6,raspalptr		zet pointer terug
	move.l	(sp)+,a6		haal a6 terug

	bclr	#0,service		meld interrupt B af
	move.b	#2,bdata		over 2 regels nog een keer
	rte				en TeruG !!!

stopcol	move.w	#17,line_cnt		aantal kleuren weer goed zetten
	move.w	#$700,col0+2*7		zet laatste kleur in kleur #7
	clr.b	bcontrol		stop rasters
	bclr	#0,service		meld deze interrupt af
	rte				en TeruG !!!
;
raspalptr	ds.l	1	pointer naar raster kleur
;
;		***** CHANGE PALLETTE *****
change_pal
	move.w	pal_count,d0
	addq.w	#1,d0		verhoog palet nummer
	cmpi.w	#10,d0		palet# te hoog?
	bne.s	pal_ok
	clr.w	d0
pal_ok	move.w	d0,pal_count	sla palet# op
	bsr	put_pal
	rts
;		***** SET PALLETTE (NORMAL OR 'DEMO' VERSION) *****
put_pal
	move.w	pal_count,d0	sla palet# op
	asl.w	#2,d0		offset in long tabel
	lea	pals,a0		adres tabel met pointers naar paletten
	tst.b	demo_mode	zitten we in help-screen met demo?
	beq.s	no_help_pal
	lea	help_pals,a0	ja -> andere tabel met paletten
no_help_pal
	move.l	0(a0,d0.w),a0	haal adres palet
	lea	col0,a1		haal adres hardware kleurenregisters
	moveq	#15,d0		16 kleuren
next_pal_col
	move.w	(a0)+,(a1)+	zet kleur
	dbra	d0,next_pal_col
	
	rts
;
;
; 		***** MUIS INITIALISATIE *****
; 		omrekenen naar 16 verschillende shifts
;
init_mouse
	lea	sprbuf,a3	haal adres grote buffer waar sprites in gezet worden
	lea	sprtab,a0	haal adres tabel met sprites

	move.l	(a0),a1		haal adres oorspronkelijke sprite-data (0ste shift)

	moveq	#0,d1		begin met shift #0

makshft	move.l	a3,(a0)+	sla pointer naar sprite met shift nummer zoveel op in SPRITE struct
	move.l	a1,a2		haal adres oorspronkelijke data
	move.w	#15,d2		haal hoogte sprite
	
makelin	moveq	#0,d4		maak d4 leeg
	move.w	(a2)+,d4	haal 1 regel
	ror.l	d1,d4		shift regel goede aantal keer
	move.w	d4,(a3)+	sla linker word op
	swap	d4		haal rechter word naar onderkant
	move.w	d4,(a3)+	en sla hem op

	dbra	d2,makelin	regel klaar -> door met volgende regel

	addq.w	#1,d1		verhoog shift met 1 voor volgende shift
	cmpi.w	#16,d1		is shift al 16
	bne	makshft		als dat niet zo is -> volgende shift berekenen

	rts			klaar met initialisatie
;
; 		***** ZET MUIS *****
;
; verpest : d0-d1,a0-a2
put_mouse
	move.l	phys_0,a0	haal scherm adres
	addq.l	#6,a0		naar 4de bitplane
	move.w	mousey,d0	haal y positie
	mulu.w	#ll,d0		vermenigvuldig y met regel-lengte voor offset op beeld	
	adda.w	d0,a0		tel y-pos maal linelen op bij physbase

	move.w	#15,d1		haal standaard teller voor hoogte
	move.w	#184,d0
	sub.w	mousey,d0	184-y
	bpl.s	no_y_clip	als dat groter dan 0 is (y<184) hoeft er niet vertikaal geclipt te worden
	add.w	d0,d1		trek overtollige hoeveelheid van hoogte af
no_y_clip
	move.w	mousex,d0	haal x pos
	lsr.w	#4,d0		d0 /16 voor word-groep
	asl.w	#3,d0		maal 8 voor bytes
	adda.w	d0,a0		tel op bij physbase
	move.l	a0,rest_mouse	sla dit adres op om later hier het scherm te restoren

	move.w	mousex,d0	haal x pos
	move.l	#ll,a2		haal waarde om over te slaan voor volgende regel
	andi.w	#$f,d0		bereken pix# (0-15)
	asl.w	#2,d0		pix#*4 voor offset in tabel met longs
	lea	sprtab,a1	adres muis sprite struct
	move.l	0(a1,d0.w),a1	haal adres sprite

	move.w	mousex,d0	haal x pos
	cmpi.w	#319-16,d0	moeten we clippen?
	bhi.s	do_clip		x pos groter dan clip pos -> dus wel clippen

putlin	move.w	(a1)+,(a0)	linker word op scherm
	move.w	(a1)+,8(a0)	rechter word op scherm

	adda.l	a2,a0		sla stuk op scherm over
	dbra	d1,putlin	volgende regel

	rts			einde subroutine

do_clip	move.w	(a1)+,(a0)	linker word op scherm
	addq.l	#2,a1		rechter word overslaan

	adda.l	a2,a0		sla stuk op scherm over
	dbra	d1,do_clip	volgende regel

	rts			einde subroutine
;
;		***** RESTORE MOUSE POINTER *****
;
clr_mouse
	move.l	rest_mouse,a0	haal adres waar muis op scherm werd gezet
	moveq	#15,d0		aantal te clearen regels

clr_lin	clr.w	(a0)		clear linker word
	clr.w	8(a0)		clear rechter word
	adda.l	#ll,a0		tel lengte 1 regel erbij op

	dbra	d0,clr_lin	volgende regel
	rts
;
;		***** BEKIJK MUISPOSITIE EN VOER ROUTS UIT *****
do_mouse
	move.l	mouse_routs,a0	haal adres button tabel
do_mouse_own		;	spring hiernaartoe als eigen button tabel adres al gepakt is (voor menu select)
	move.b	mousek,d0	wordt een muisknop ingedrukt?
	andi.b	#%11,d0		bekijk onderste bits (muisknoppen)
	beq	no_click	nee -> handel muis niet af

	tst.b	no_mouse_repeat	mag muis klikken?
	bne.s	no_mouse_click	nee -> geen geklik

	move.w	mousex,d0	haal muis x positie
	move.w	mousey,d1	en y positie
next_but
	cmp.w	(a0),d0		klopt x positie #1
	blo.s	not_this_but	te laag -> volgende button
	cmp.w	2(a0),d1	klopt y positie #1
	blo.s	not_this_but	te laag -> volgende button
	cmp.w	4(a0),d0	x positie #2
	bhi.s	not_this_but	te hoog -> volgende button
	cmp.w	6(a0),d1	y positie #2
	bhi.s	not_this_but	te hoog -> volgende button
;				wel goede button, dus:
	move.l	8(a0),a1	haal adres routine
	jsr	(a1)		en voer hem uit
	clr.b	pause_mode	stop tijdelijk pauseren tijdens commando
	move.l	update_rout,a0	haal adres button update routine
	jsr	(a0)		voer ook die uit

	tst.b	no_mouse_repeat	mag muis klikken?
	bne.s	no_mouse_click	nee -> geen geklik

	tst.w	vbl_wait_m	staat vbl wacht stap op 0?
	bne.s	no_first_click	nee -> niet eerste klik
	move.w	#16,vbl_wait_m	ja -> zet stap op 16
	rts
no_first_click
	move.w	#4,vbl_wait_m	nee -> zet stap op 4
	rts
;
not_this_but
	adda.l	#12,a0		naar volgende button
	tst.l	4(a0)		kijk naar x/y pos #2 -> als die 0 is dit laatste item
	bne.s	next_but	nee -> volgende button bekijken
no_click
	clr.b	no_mouse_repeat	muis kan weer klikken
no_mouse_click
	clr.w	vbl_wait_m	zet stap op 0 omdat er geen button geklikt is
	rts			anders zonder iets bereikt te hebben terugkomen
;		***** BEKIJK MUIS IN MENU'S *****
menu_sel
	move.l	menu_routs,a0	pointer naar button posities huidige menu
	bsr	do_mouse_own	bekijk die muisposities
	rts
;
;		***** BEKIJK TOETS EN VOER ROUTS UIT *****
do_key
	moveq	#0,d0		om toets als word te kunnen behandelen
	move.b	key,d0		haal toets en vraag "wordt er een toets ingedrukt?"
	beq	maybe_midi	nee -> wordt er dan een MIDI toets ingedrukt?

	tst.b	no_key_repeat	mag toets bekeken worden?
	bne	no_first_key	nee -> niet eerste toetsdruk -> doe niets

	tst.b	asc_mode	wordt er een ASCII string ingevoerd?
	bne	get_ascii	ja -> lees ASCII string

	move.l	key_routs,a0	haal adres button tabel

	tst.b	shiftmode	wordt er een shift toets ingedrukt?
	beq.s	next_key	nee -> doe niks
	addi.w	#256,d0		tel 256 bij toetscode
next_key
	cmp.w	(a0),d0		klopt toets?
	bne.s	not_this_key	nee -> volgende toets testen
;				wel goede toets, dus:
	move.l	2(a0),a3	haal adres routine en voer hem verderop uit
	;			maar bereken eerst de volgende pointers
	move.l	pat_base,a1	haal pointer naar begin van pattern
	move.w	pat_lin,d1	haal regel#
	mulu.w	#note_len,d1	vermenigvuldig met lengte 1 noot
	add.w	d1,a1		en tel op bij pointer in pattern

	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	lea	cursor_data,a2	haal adres tabel met pointers naar data gebieden
	move.l	0(a2,d0.w),a0	haal adres data gebied

	jsr	(a3)		voer routine uit
	clr.b	pause_mode	stop tijdelijk pauseren tijdens commando
	move.l	update_rout,a0	haal adres update routine
	jsr	(a0)		voer ook die uit

	tst.w	vbl_wait_k	staat vbl wacht stap op 0?
	bne.s	no_first_key	nee -> niet eerste toets
	move.w	#16,vbl_wait_k	ja -> zet stap op 16
	rts
no_first_key
	move.w	#4,vbl_wait_k	nee -> zet stap op 4
	rts
;
not_this_key
	addq.l	#6,a0		naar volgende toets
	tst.w	(a0)		kijk naar scancode -> als die 0 is dit laatste item
	bne.s	next_key	nee -> volgende toets bekijken
;		***** STOP MODE INPUT *****
; als toets niet in tabel staat -> misschien kan stopped er iets mee doen
stop_mode_input
	tst.w	patmode		doen we stopped mode?
	bne.s	no_key		nee -> ga door

	move.l	pat_base,a1	haal pointer naar begin van pattern
	move.w	pat_lin,d0	haal regel#
	mulu.w	#note_len,d0	vermenigvuldig met lengte 1 noot
	add.w	d0,a1		en tel op bij pointer in pattern
	move.l	a1,pat_ptr	sla pointer op voor later

	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	lea	cursor_data,a2	haal adres tabel met pointers naar data gebieden
	move.l	0(a2,d0.w),a0	haal adres data gebied

	lea	cursor_get,a2	haal adres tabel met pointers naar routines voor verschillende input routines
	move.l	0(a2,d0.w),a2	haal bij cursor pos horende routine
	jsr	(a2)		voer hem uit

	tst.b	done_something	was er een goede toets?
	beq.s	no_key		nee -> zet VBL stap op 0
;				ja -> zet VBL stap op goede waarde
	tst.w	vbl_wait_k	staat vbl wacht stap op 0?
	bne.s	no_first_stop	nee -> niet eerste toets
	move.w	#16,vbl_wait_k	ja -> zet stap op 16
	rts
no_first_stop
	move.w	#4,vbl_wait_k	nee -> zet stap op 4
	rts
;
maybe_midi
	tst.b	midi_cur	wordt er een MIDI toets ingedrukt?
	bne.s	stop_mode_input	ja -> neem die toets dan op
;
no_key	clr.w	vbl_wait_k	geen toets -> zet stap op 0
	rts			anders zonder iets bereikt te hebben terugkomen
;
;
;		***** LEES ASCII STRING *****
get_ascii
	cmpi.b	#28,d0		wordt er op Return gedrukt?
	beq	asc_end		ja -> einde invoer

	cmpi.b	#14,d0		Backspace?
	beq	asc_back

	cmpi.b	#83,d0		Delete?
	beq	asc_del

	cmpi.b	#82,d0		Insert
	beq	asc_ins

	cmpi.b	#75,d0		pijl links?
	beq	asc_left

	cmpi.b	#77,d0		pijl rechts?
	beq	asc_right

	cmpi.b	#80,d0		pijl omlaag?
	beq	asc_down

	cmpi.b	#72,d0		pijl omhoog
	beq	asc_up

	lea	key_2_asc,a0	conversie tabel : scancode -> ASCII code
	move.b	0(a0,d0.w),d0	haal ASCII byte uit tabel
	beq.s	asc_unknown	byte=0 -> onbekend teken -> negeer het
	move.l	asc_string,a0	adres string
	move.w	asc_cur,d1	haal cursor positie
	move.b	d0,0(a0,d1.w)	zet byte in string
	addq.w	#1,d1		verhoog cursor positie
	andi.w	#$7,d1		maskeer mogelijk 8
	move.w	d1,asc_cur	sla cursor positie op
asc_unknown
	move.l	update_rout,a0	haal adres update routine
	jsr	(a0)		voer die uit

	tst.w	vbl_wait_k	staat vbl wacht stap op 0?
	bne.s	no_first_asc	nee -> niet eerste ASCII toets
	move.w	#16,vbl_wait_k	ja -> zet stap op 16
	rts
no_first_asc
	move.w	#4,vbl_wait_k	nee -> zet stap op 4
	rts
;
asc_end	clr.b	asc_mode	geen invoer meer
	bra.s	asc_unknown
;
asc_back
	subq.w	#1,asc_cur	cursor terug
	andi.w	#$7,asc_cur	maskeer mogelijke -1
asc_del	moveq	#7,d0
	move.w	asc_cur,d1	haal cursor pos
	sub.w	d1,d0		7-cursor pos=lengte te copieren deel
	move.l	asc_string,a0	haal adres string
	lea	7(a0),a2	bewaar om later laatste teken te wissen
	lea	0(a0,d1.w),a1	target = huidige cursor positie
	lea	1(a1),a0	source = target+1
	bsr	copy_mem	copieer geheugen
	move.b	#32,(a2)	wis laatste teken 	
	bra.s	asc_unknown	
;	
asc_ins	moveq	#7,d0
	move.w	asc_cur,d1	haal cursor pos
	sub.w	d1,d0		7-cursor pos=lengte te copieren deel
	move.l	asc_string,a0	haal adres string
	lea	0(a0,d1.w),a2	bewaar om later laatste teken te wissen
	lea	0(a0,d1.w),a0	source = huidige cursor positie
	lea	1(a0),a1	target = source+1
	bsr	copy_mem	copieer geheugen
	move.b	#32,(a2)	wis laatste teken 	
	bra	asc_unknown	
;	
asc_left
	subq.w	#1,asc_cur	verschuif cursor naar links
	andi.w	#$7,asc_cur	maskeer mogelijke -1
	bra	asc_unknown
;
asc_right
	addq.w	#1,asc_cur	verschuif cursor naar rechts
	andi.w	#$7,asc_cur	maskeer mogelijke 8
	bra	asc_unknown
;
asc_down
	move.w	#7,asc_cur	cursor naar einde
	bra	asc_unknown
;
asc_up
	clr.w	asc_cur		cursor naar begin
	bra	asc_unknown
;
;
;		***** UP/DOWN BUTTON SUBS *****
srate_p	move.w	cur_sam,d0	haal sample#
	lea	sam_rates,a2	adres sample rates
	cmpi.b	#$f,0(a2,d0.w)	vergelijk sample rate met maximum
	beq.s	srate_l		als dat al bereikt is -> zet op minimum
	addi.b	#1,0(a2,d0.w)	verhoog sample rate
no_do
	rts
srate_l	move.b	#5,0(a2,d0.w)	zet sample rate op minimum
	rts
srate_m	move.w	cur_sam,d0	haal sample#
	lea	sam_rates,a2	adres sample rates
	cmpi.b	#5,0(a2,d0.w)	vergelijk sample rate met minimum
	beq	srate_h		als dat al bereikt is -> zet op maximum
	subi.b	#1,0(a2,d0.w)	verlaag sample rate
	rts
srate_h	move.w	cur_sam,d0	haal sample#
	lea	sam_rates,a2	adres sample rates
	move.b	#15,0(a2,d0.w)	zet sample rate op maximum
	rts
;
sampl_p	addq.w	#1,cur_sam	verhoog sam#
	andi.w	#$f,cur_sam	houdt waarde binnen grenzen
	clr.b	asc_mode	geen invoer meer
	rts
sampl_m	subq.w	#1,cur_sam	verlaag sample#
	andi.w	#$f,cur_sam	houdt waarde binnen grenzen
	clr.b	asc_mode	geen invoer meer
	rts
sampl_l	clr.w	cur_sam
	clr.b	asc_mode	geen invoer meer
	rts
;
sound_p	addi.b	#1,ym_sound	verhoog ym sound#
	andi.b	#$3f,ym_sound	houdt waarde binnen grenzen
	clr.b	asc_mode	geen invoer meer
	bsr	print_yef_first	print mogelijk YM edit field
	rts
sound_m	subi.b	#1,ym_sound	verlaag YM sound
	andi.b	#$3f,ym_sound	houdt waarde binnen grenzen
	clr.b	asc_mode	geen invoer meer
	bsr	print_yef_first	print mogelijk YM edit field
	rts
sound_l	clr.b	ym_sound	naar eerste YM sound
	clr.b	asc_mode	geen invoer meer
	bsr	print_yef_first	print mogelijk YM edit field
	rts
;
ymvol_p	addi.b	#1,ym_vol	verhoog YM volume
	andi.b	#$f,ym_vol	houdt binnen grenzen
	rts
ymvol_m	subi.b	#1,ym_vol	verlaag YM volume
	andi.b	#$f,ym_vol	houdt binnen grenzen
	rts
ymvol_h	move.b	#$f,ym_vol	zet YM volume op maximum
	rts
;
ymtie_p	addi.b	#1,ym_tie	verhoog YM tie
	andi.b	#$3f,ym_tie	houdt waarde binnen grenzen
	rts
ymtie_m	subi.b	#1,ym_tie	verlaag YM tie
	andi.b	#$3f,ym_tie	houdt waarde binnen grenzen
	rts
ymtie_l	clr.b	ym_tie		zet YM tie op 0
	rts
;
posit_p	cmpi.w	#119,pos_now	vergelijk position met maximum
	beq	posit_l		als dat al bereikt is -> zet op minimum
	addq.w	#1,pos_now	verhoog position
	bsr	calc_pos	update allerlei variabelen
	st.b	pls_flag	print verandering
	rts
posit_l	clr.w	pos_now		zet position op minimum
	bsr	calc_pos	update allerlei variabelen
	st.b	pls_flag	print verandering
	rts
posit_m	tst.w	pos_now		vergelijk position met minimum
	beq	posit_h		als dat al bereikt is -> zet op maximum
	subq.w	#1,pos_now	verlaag position
	bsr	calc_pos
	st.b	pls_flag	print verandering
	rts
posit_h	move.w	#119,pos_now	zet position op minimum
	bsr	calc_pos	update allerlei variabelen
	st.b	pls_flag	print verandering
	rts
;
patte_p	move.w	pat_now,d2	haal pattern
	addq.w	#1,d2		verhoog met 1 voor vergelijking met aantal
	cmp.w	last_pat,d2	vergelijk met maximum
	beq	patte_l		als dat al bereikt is -> zet op minimum
	move.w	pos_now,d3	haal huidige position
	lea	pos_tab,a0	haal tabel met pattern bij positions
	addi.b	#1,0(a0,d3.w)	verhoog pattern van huidige position
	bsr	calc_pos	zet alle variabelen goed
	st.b	pls_flag	print verandering
	rts
patte_l	move.w	pos_now,d3	haal huidige position
	lea	pos_tab,a0	haal tabel met pattern bij positions
	clr.b	0(a0,d3.w)	zet pattern op 0
	bsr	calc_pos	zet alle variabelen goed
	st.b	pls_flag	print verandering
	rts
;
patte_m	tst.w	pat_now		vergelijk pattern met minimum
	beq	patte_h		als dat al bereikt is -> zet op maximum
	move.w	pos_now,d3	haal huidige position
	lea	pos_tab,a0	haal tabel met pattern bij positions
	subi.b	#1,0(a0,d3.w)	verlaag pattern van huidige position
	bsr	calc_pos	zet alle variabelen goed
	st.b	pls_flag	print verandering
	rts
patte_h	move.w	last_pat,d2	haal aantal patterns
	subq.w	#1,d2		-1 = laatste pattern
	move.w	pos_now,d3	haal huidige position
	lea	pos_tab,a0	haal tabel met pattern bij positions
	move.b	d2,0(a0,d3.w)	zet pattern op maximum
	bsr	calc_pos	zet alle variabelen goed
	st.b	pls_flag	print verandering
	rts
;
resta_p	cmpi.w	#119,restart	vergelijk restart maximum
	beq	resta_l		als dat al bereikt is -> minimum
	addq.w	#1,restart
	rts
resta_l	clr.w	restart		zet restart op 0
	rts
resta_m	tst.w	restart		vergelijk restart met minimum
	beq	resta_h		als dat al bereikt is -> maximum
	subq.w	#1,restart
	rts
resta_h	move.w	#119,restart	zet restart op maximum
	rts
;
posle_p	cmpi.w	#119,last_pos	vergelijk length met maximum
	beq	posle_l		als dat al bereikt is -> minimum
	addq.w	#1,last_pos
	rts
posle_l	clr.w	last_pos	zet aantal positions op 0 
	rts
posle_m	tst.w	last_pos	vergelijk length met minimum
	beq	posle_h		als dat al bereikt is -> maximum
	subq.w	#1,last_pos
	rts
posle_h	move.w	#119,last_pos	zet aantal positions op maximum
	rts
;
speed_m	cmpi.w	#$10,speed		vergelijk speed met maximum
	beq	speed_l			als dat al bereikt is -> minimum
	addq.w	#1,speed
	move.w	speed,note_count	laat volgende noot ook met de snelhied gepakt worden
	rts
speed_l	move.w	#$2,speed
	rts
speed_p	cmpi.w	#$2,speed		vergelijk speed met minimum
	beq	speed_h			als dat al bereikt is -> maximum	
	subq.w	#1,speed
	move.w	speed,note_count	laat volgende noot ook met de snelhied gepakt worden
	rts
speed_h	move.w	#$10,speed
	rts
speed_8	move.w	#$8,speed		zet speed op default
	rts
;
sstep_p	addq.w	#1,s_step
	andi.w	#$3f,s_step	houdt waarde binnen grenzen
	rts
sstep_m	subq.w	#1,s_step
	andi.w	#$3f,s_step	houdt waarde binnen grenzen
	rts
sstep_l	move.w	#1,s_step	zet stop step op default
	rts
;
octav_p	cmpi.b	#5,octave	vergelijk ocatve met maximum
	beq	octav_l		als dat al bereikt is -> minimum
	addi.b	#1,octave	verhoog octave
	rts
octav_l	clr.b	octave
	rts
octav_m	tst.b	octave		vergelijk octave met minimum
	beq	octav_h		als dat al bereikt is -> maximum	
	subi.b	#1,octave	verlaag octave
	rts
octav_h	move.b	#5,octave
	rts
;
yef_left
	tst.w	yef_pos		vergelijk yef pos met minimum
	beq	no_do		als dat al bereikt is -> doe niks	
	subq.w	#1,yef_pos	verlaag yef pos
	bsr	print_yef	print YM edit field
	rts
yef_right
	cmpi.w	#i_env_len-72,yef_pos	vergelijk yef pos met maximum
	beq	no_do			als dat al bereikt is -> doe niks	
	addq.w	#1,yef_pos		verhoog yef pos
	bsr	print_yef		print YM edit field
	rts
;
attac_p	move.l	ym_ptr,a1		pointer naar ym sound
	tst.b	yef_mode		editen we pitch of amplitude?
	beq.s	attp_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
attp_amp
	move.w	i_env_attack(a1),d2	vergelijk einde attack met maximum
	addq.w	#1,d2
	cmp.w	i_env_sustain(a1),d2	die dus einde sustain-1 is
	beq	no_do			als dat al bereikt is -> doe niks	
	move.w	d2,i_env_attack(a1)	sla start sustain op
	bsr	print_yef	print YM edit field
	rts
attac_m	move.l	ym_ptr,a1		pointer naar ym sound
	tst.b	yef_mode		editen we pitch of amplitude?
	beq.s	attm_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
attm_amp
	tst.w	i_env_attack(a1)	vergelijk einde sustain met minimum
	beq	no_do			als dat al bereikt is -> doe niks	
	subq.w	#1,i_env_attack(a1)
	bsr	print_yef	print YM edit field
	rts
;
susta_p	move.l	ym_ptr,a1		pointer naar ym sound
	tst.b	yef_mode		editen we pitch of amplitude?
	beq.s	susp_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
susp_amp
	move.w	i_env_sustain(a1),d2	vergelijk einde sustain met maximum
	addq.w	#1,d2
	cmp.w	i_env_release(a1),d2	die dus einde release-1 is
	beq	no_do			als dat al bereikt is -> doe niks	
	move.w	d2,i_env_sustain(a1)
	bsr	print_yef	print YM edit field
	rts
susta_m	move.l	ym_ptr,a1		pointer naar ym sound
	tst.b	yef_mode		editen we pitch of amplitude?
	beq.s	susm_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
susm_amp
	move.w	i_env_sustain(a1),d2	vergelijk einde sustain met minimum
	subq.w	#1,d2
	cmp.w	i_env_attack(a1),d2	die dus einde attack+1 is
	beq	no_do			als dat al bereikt is -> doe niks	
	move.w	d2,i_env_sustain(a1)	sla einde sustain op
	bsr	print_yef	print YM edit field
	rts
;
relea_p	move.l	ym_ptr,a1			pointer naar ym sound
	tst.b	yef_mode			editen we pitch of amplitude?
	beq.s	relp_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
relp_amp
	cmpi.w	#i_env_len,i_env_release(a1)	vergelijk einde release met maximum
	beq	no_do				als dat al bereikt is -> doe niks	
	addq.w	#1,i_env_release(a1)
	bsr	print_yef	print YM edit field
	rts
relea_m	move.l	ym_ptr,a1		pointer naar ym sound
	tst.b	yef_mode		editen we pitch of amplitude?
	beq.s	relm_amp
	add.l	#i_pit_attack-i_env_attack,a1	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
relm_amp
	move.w	i_env_release(a1),d2	vergelijk einde release met minimum
	subq.w	#1,d2
	cmp.w	i_env_sustain(a1),d2	die dus einde sustain+1 is
	beq	no_do			als dat al bereikt is -> doe niks	
	move.w	d2,i_env_release(a1)
	bsr	print_yef	print YM edit field
	rts
;
henvf_p	move.l	ym_ptr,a1		pointer naar ym sound
	btst.b	#0,mousek		wordt rechter muisknop (voor sneller ophogen) ingedrukt?
	beq.s	no_rb_hep
	addi.b	#1,i_env_freq(a1)	verhoog UPPER byte
	bclr.b	#3,i_sound_mode(a1)	zet hardware automatic frequency uit
	rts
no_rb_hep	
	addq.w	#1,i_env_freq(a1)
	bclr.b	#3,i_sound_mode(a1)	zet hardware automatic frequency uit
	rts
;
henvf_m	move.l	ym_ptr,a1		pointer naar ym sound
	btst.b	#0,mousek		wordt rechter muisknop (voor sneller ophogen) ingedrukt?
	beq.s	no_rb_hem
	subi.b	#1,i_env_freq(a1)	verlaag UPPER byte
	bclr.b	#3,i_sound_mode(a1)	zet hardware automatic frequency uit
	rts
no_rb_hem
	subq.w	#1,i_env_freq(a1)
	bclr.b	#3,i_sound_mode(a1)	zet hardware automatic frequency uit
	rts
henvf_l	move.l	ym_ptr,a1		pointer naar ym sound
	clr.w	i_env_freq(a1)		hardware freq op default
	bclr.b	#3,i_sound_mode(a1)	zet hardware automatic frequency uit
	rts
;
henvt_p	move.l	ym_ptr,a1		pointer naar ym sound
	addi.b	#1,i_env_type(a1)	verhoog hardware type
	andi.b	#$7,i_env_type(a1)
	or.b	#$8,i_env_type(a1)
	rts
henvt_m	move.l	ym_ptr,a1		pointer naar ym sound
	subi.b	#1,i_env_type(a1)	verlaag hardware type
	andi.b	#$7,i_env_type(a1)
	or.b	#$8,i_env_type(a1)
	rts
henvt_l	move.l	ym_ptr,a1		pointer naar ym sound
	move.b	#$8,i_env_type(a1)	hardware type op default
	rts
;
vibrs_p	move.l	ym_ptr,a1		pointer naar ym sound
	addq.w	#1,i_vibr_speed(a1)
	andi.w	#$f,i_vibr_speed(a1)
	rts
vibrs_m	move.l	ym_ptr,a1		pointer naar ym sound
	subq.w	#1,i_vibr_speed(a1)
	andi.w	#$f,i_vibr_speed(a1)
	rts
vibrs_l	move.l	ym_ptr,a1		pointer naar ym sound
	clr.w	i_vibr_speed(a1)	vibrato speed op default
	rts
;
vibrd_p	move.l	ym_ptr,a1		pointer naar ym sound
	tst.w	i_vibr_depth(a1)	vergelijk vibrato depth met minimum
	beq	vibrd_h			als dat al bereikt is -> maximum
	subq.w	#1,i_vibr_depth(a1)
	rts
vibrd_h	move.l	ym_ptr,a1		pointer naar ym sound
	move.w	#11,i_vibr_depth(a1)
	rts
vibrd_m	move.l	ym_ptr,a1		pointer naar ym sound
	cmpi.w	#11,i_vibr_depth(a1)	vergelijk vibrato depth met maximum
	beq	vibrd_l			als dat al bereikt is -> minimum	
	addq.w	#1,i_vibr_depth(a1)
	rts
vibrd_l	clr.w	i_vibr_depth(a1)
	rts
;
noisf_p	move.l	ym_ptr,a1	pointer naar ym sound
	addq.w	#1,(a1)
	andi.w	#$1f,(a1)	houdt waarde binnen grenzen
	rts
noisf_m	move.l	ym_ptr,a1	pointer naar ym sound
	subq.w	#1,(a1)
	andi.w	#$1f,(a1)	houdt waarde binnen grenzen
	rts
noisf_l	move.l	ym_ptr,a1	pointer naar ym sound
	clr.w	(a1)		noise freq op default
	rts
;
intr1_p	move.l	ym_ptr,a1		pointer naar ym sound
	cmpi.w	#12,i_interval1(a1)	vergelijk interval met maximum
	beq	intr1_l			sla dat al bereikt is -> minimum
	addq.w	#1,i_interval1(a1)
	rts
intr1_l	move.l	ym_ptr,a1		pointer naar ym sound
	clr.w	i_interval1(a1)
	rts
;
intr1_m	move.l	ym_ptr,a1	pointer naar ym sound
	tst.w	i_interval1(a1)	vergelijk interval met minimum
	beq	intr1_h		sla dat al bereikt is -> maximum
	subq.w	#1,i_interval1(a1)
	rts
intr1_h	move.w	#12,i_interval1(a1)
	rts
;
intr2_p	move.l	ym_ptr,a1		pointer naar ym sound
	cmpi.w	#12,i_interval2(a1)	vergelijk interval met maximum
	beq	intr2_l			sla dat al bereikt is -> minimum
	addq.w	#1,i_interval2(a1)
	rts
intr2_l	move.l	ym_ptr,a1		pointer naar ym sound
	clr.w	i_interval2(a1)
	rts
;
intr2_m	move.l	ym_ptr,a1	pointer naar ym sound
	tst.w	i_interval2(a1)	vergelijk interval met minimum
	beq	intr2_h		sla dat al bereikt is -> maximum
	subq.w	#1,i_interval2(a1)
	rts
intr2_h	move.w	#12,i_interval2(a1)
	rts
;
;
hardw_mode
	move.l	ym_ptr,a1		pointer naar ym sound
	bchg.b	#2,i_sound_mode(a1)	toggle hardware ON/OFF
	rts
;
tone_mode
	move.l	ym_ptr,a1		pointer naar ym sound
	bchg.b	#0,i_sound_mode(a1)	toggle tone ON/OFF
	rts
;
noise_mode
	move.l	ym_ptr,a1		pointer naar ym sound
	bchg.b	#1,i_sound_mode(a1)	toggle noise ON/OFF
	rts
;
hardw_auto
	move.l	ym_ptr,a1		pointer naar ym sound
	bchg.b	#3,i_sound_mode(a1)	toggle hardware frequency AUTOMATIC/MANUAL
	rts
;
toggle_yef_mode
	not.b	yef_mode		Edit pitch of amplitude
	st.b	no_mouse_repeat		laat muis niet repeteren
	bsr	print_yef		print YM edit field
	rts
;
;
;
;		***** MAIN SCREEN MODES *****
r_mode	not.b	rec_mode	verander rec mode
	rts
;
k_mode	subi.b	#1,key_mode	verlaag key mode
	bpl.s	key_mode_not_lo	key mode nog niet -1 -> laat het zo
	move.b	#2,key_mode	key mode op 2
key_mode_not_lo
	rts
;	***** ZET PUNTEN IN AMPLITUDE EDIT FIELD *****
;	d0.w = x pos, d1.w = y pos
add_aef_point
	tst.b	yef_mode	editen we AMP of FRQ?
	bne.s	add_pef_point	FRQ -> voeg daar een punt toe

	move.l	ym_ptr,a0	haal pointer in geluid
	add.l	#i_env_start,a0	sla data over
	subi.w	#16,d0		haal 16 van x pos af voor offset vanaf begin yef
	lsr.w	#2,d0		deel x pos door 4
	add.w	yef_pos,d0	tel daarbij op offset van edit field voor offset in envelope

	subi.w	#20,d1		zelfde met y pos
	lsr.w	#2,d1		deel door 4 voor waarde
	not.w	d1		volume=16-volume
	andi.b	#$f,d1		maskeer overtollige bits

	btst.b	#0,mousek	wordt rechter muisknop ingedrukt?
	bne.s	ins_aef_point	ja -> voeg punt toe ne schuif rest opzij
	
	move.b	d1,0(a0,d0.w)	sla volume op in sound
	bsr	print_yef	print YM edit field
	rts
ins_aef_point
	lea	0(a0,d0.w),a2	pointer naar byte die we na verschuiven in moeten vullen
	move.l	#i_env_len,d2
	sub.w	d0,d2		i_env_len-offset = lengte te copieren deel
	lea	0(a0,d0.w),a0	source = plaats offset
	lea	1(a0),a1	target = source+1
	move.l	d2,d0		lengte te copieren deel
	bsr	copy_mem	copieer

	move.b	d1,(a2)		zet volume in envelope
	bsr	print_yef	print YM edit field
	rts
;		***** ZET PUNTEN IN PITCH EDIT FIELD *****
add_pef_point
	move.l	ym_ptr,a0	haal pointer in geluid
	add.l	#i_pit_start,a0	sla data over
	subi.w	#16,d0		haal 16 van x pos af voor offset vanaf begin yef
	lsr.w	#2,d0		deel x pos door 4
	add.w	yef_pos,d0	tel daarbij op offset van edit field voor offset in envelope

	subi.w	#19+32,d1	voor offset vanaf begin edit-field en om van bovenste punt -32 te maken
	cmpi.w	#-31,d1		zit waarde onder minimum?
	blt.s	no_pef_point	ja -> zet punt niet
	cmpi.w	#31,d1		zit waarde boven maximum?
	bgt.s	no_pef_point	ja -> zet punt niet
	asl.w	#2,d1		vermenigvuldig 4 voor waarde

	btst.b	#0,mousek	wordt rechter muisknop ingedrukt?
	bne.s	ins_pef_point	ja -> voeg punt toe ne schuif rest opzij
	
	move.b	d1,0(a0,d0.w)	sla volume op in sound
	bsr	print_yef	print YM edit field
no_pef_point
	rts
ins_pef_point
	lea	0(a0,d0.w),a2	pointer naar byte die we na verschuiven in moeten vullen
	move.l	#i_pit_len,d2
	sub.w	d0,d2		i_env_len-offset = lengte te copieren deel
	lea	0(a0,d0.w),a0	source = plaats offset
	lea	1(a0),a1	target = source+1
	move.l	d2,d0		lengte te copieren deel
	bsr	copy_mem	copieer

	move.b	d1,(a2)		zet volume in envelope
	bsr	print_yef	print YM edit field
	rts
;
;		***** WIS PUNT IN YM EDIT FIELD *****
del_aef_point
	move.w	mousex,d2	haal muis x coordinaat
	cmp.w	#16,d2		x<16?
	blo	no_dyf		ja -> geen punt wissen
	cmp.w	#304,d2		x>304?
	bhi	no_dyf		ja -> geen punt wissen

	move.w	mousey,d1	haal muis y coordinaat
	cmp.w	#20,d1		y<20?
	blo	no_dyf		ja -> geen punt wissen
	cmp.w	#83,d1		y>83?
	bhi	no_dyf		ja -> geen punt wissen
; muis op goede plaats : wis punt
	move.l	ym_ptr,a0			haal pointer in geluid
	add.l	#i_env_start,a0			sla data over
	tst.b	yef_mode			editen we pitch of amplitude?
	beq.s	del_amp
	add.l	#i_pit_start-i_env_start,a0	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
del_amp
	subi.w	#16,d2		haal 16 van x pos af voor offset vanaf begin yef
	lsr.w	#2,d2		deel x pos door 4
	add.w	yef_pos,d2	tel daarbij op offset van edit field voor offset in envelope

	move.l	#i_env_len,d0
	sub.w	d2,d0		i_env_len-offset = lengte te copieren deel
	lea	0(a0,d2.w),a1	target = plaats offset
	lea	1(a1),a0	source = target+1
	bsr	copy_mem	copieer

	bsr	print_yef	print YM edit field
no_dyf	rts
;
;		***** ZET PUNT IN YM EDIT FIELD OP 0 *****
clr_aef_point
	move.w	mousex,d2	haal muis x coordinaat
	cmp.w	#16,d2		x<16?
	blo	no_dyf		ja -> geen punt wissen
	cmp.w	#304,d2		x>304?
	bhi	no_dyf		ja -> geen punt wissen

	move.w	mousey,d1	haal muis y coordinaat
	cmp.w	#20,d1		y<20?
	blo	no_dyf		ja -> geen punt wissen
	cmp.w	#83,d1		y>83?
	bhi	no_dyf		ja -> geen punt wissen
; muis op goede plaats : wis punt
	move.l	ym_ptr,a0			haal pointer in geluid
	add.l	#i_env_start,a0			sla data over
	tst.b	yef_mode			editen we pitch of amplitude?
	beq.s	clr_amp
	add.l	#i_pit_start-i_env_start,a0	verhoog pointer naar ym sound zodat offset die eerst voor amplitude geldden nu voor pitch gelden
clr_amp
	subi.w	#16,d2		haal 16 van x pos af voor offset vanaf begin yef
	lsr.w	#2,d2		deel x pos door 4
	add.w	yef_pos,d2	tel daarbij op offset van edit field voor offset in envelope
	clr.b	0(a0,d2.w)	zet punt op 0

	bsr	print_yef	print YM edit field
	rts
;
;		***** TOETSEN ROUTS *****
rite_ar	cmpi.w	#23*4,cursor	is cursor positie al bij maximum?
	beq.s	nout_do		ja -> doe niks
	addq.w	#4,cursor	nee -> verschuif cursor
	restore_pat_lin		herstel pattern
	clear_key		wis toetsen
	bsr	print_cursor	en print hem weer
nout_do
	rts
;
left_ar	tst.w	cursor		is cursor positie al bij minimum(0)
	beq.s	nout_do		ja -> doe niks
	subq.w	#4,cursor	nee -> verschuif cursor
	restore_pat_lin		herstel pattern
	clear_key		wis toetsen
	bsr	print_cursor	en print hem weer
	rts
;
up_ar	subq.w	#1,pat_lin	verlaag pattern regel
	andi.w	#$3f,pat_lin	breng regel# binnen grenzen
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;
down_ar	addq.w	#1,pat_lin	verhoog pattern regel
	andi.w	#$3f,pat_lin	breng regel# binnen grenzen
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;
goto_00	clr.w	pat_lin		zet pattern regel op 0
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;	
goto_10	move.w	#$10,pat_lin	zet pattern regel op 10
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;	
goto_20	move.w	#$20,pat_lin	zet pattern regel op 20
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;	
goto_30	move.w	#$30,pat_lin	zet pattern regel op 30
	move.w	#1,note_count	als we aan het spelen zijn wel verandering opmerken
	st.b	pls_flag	print pattern regels
	rts
;	
space	bsr	save_undo	sla huidige pattern en block-buffer op in undo-buffer
	bset.b	#0,silent(a0)	zet silent bit
	clr.l	(a1)		wis noot
	move.w	s_step,d1	maak back-up van stop step
	move.w	#1,s_step	maak stop step 1
	st.b	done_something	er is iets gebeurd
wait_mes_recieved
	tst.b	done_something	wacht tot VBL dat doorheeft
	bne.s	wait_mes_recieved

	move.w	d1,s_step	zet stop step weer goed
	rts
;
backspace
	bsr	save_undo	sla huidige pattern en block-buffer op in undo-buffer
	bset.b	#0,silent(a0)	zet silent bit
	clr.l	(a1)		wis noot
	st.b	done_something	er is iets gebeurd
	rts
;
;		***** DELETE LINE *****
del_lin	bsr	save_undo	sla huidige pattern en block-buffer op in undo-buffer
	move.w	#$3f,d0		haal hoogst mogelijke pattern regel
	sub.w	pat_lin,d0	trek door huidige van af voor aantal te copieren pattern regels
	bra.s	del_lin_test	spring vlak voor dbra om te kijken of d0 niet al 0 is
del_lines
	move.l	12(a1),(a1)	haal volgende regel naar huidige regel
	add.l	#12,a1		ga naar volgende regel
del_lin_test
	dbra	d0,del_lines
	clr.l	(a1)		wis laatste noot van track
	st.b	pls_flag	print pattern regels
	rts
;		***** INSERT LINE *****
ins_lin	bsr	save_undo	sla huidige pattern en block-buffer op in undo-buffer
	move.w	#$3f,d0		haal hoogst mogelijke pattern regel
	sub.w	pat_lin,d0	trek door huidige van af voor aantal te copieren pattern regels
	move.w	d0,d1		voor offset
	mulu.w	#note_len,d1	vermenigvuldig met lengte 1 regel
	add.w	d1,a1		tel op bij adres in pattern
	bra.s	ins_lin_test	spring vlak voor dbra om te kijken of d0 niet al 0 is
ins_lines
	sub.l	#12,a1		ga naar vorige regel
	move.l	(a1),12(a1)	zet huidige regel op volgende regel
ins_lin_test
	dbra	d0,ins_lines
	clr.l	(a1)		wis huidige noot
	st.b	pls_flag	print pattern regels
	rts
;		***** CUT TRACK *****
cut_track
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	move.l	pat_base,a1	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern
	lea	block_buf,a0	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len noten
cut_notes
	move.l	(a1),(a0)+	sla noot op in buffer
	clr.l	(a1)+		wis noot in pattern
	addq.l	#8,a1		verhoog pointer in pattern
	dbra	d0,cut_notes

	move.w	#1,block_flag	in de block buffer staat een track
	clr.b	block_valid	block posities ongeldig
	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** PASTE TRACK *****
paste_track
	cmpi.w	#1,block_flag	staat er een track in de block buffer?
	bne.s	no_paste	nee -> doe niks

	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep	haal adres track en filter SAM's eruit bij kanaal B en C
	lea	block_buf,a1	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len noten
paste_notes
	move.l	(a1)+,(a0)+	haal noot uit buffer
	addq.l	#8,a0		verhoog pointer in pattern met 8(+4 van (a1)+=12)
	dbra	d0,paste_notes
	
	st.b	pls_flag	print verandering
no_paste
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** OVERLAY TRACK *****
overlay	cmpi.w	#1,block_flag	staat er een track in de block buffer?
	bne.s	no_paste	nee -> doe niks

	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep	haal adres track en filter SAM's eruit bij kanaal B en C
	lea	block_buf,a1	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len noten
overlay_notes
	move.l	(a1)+,d1	staat hier een noot in de buffer?
	andi.l	#$ff000000,d1	bekijk alleen octaaf/noot en envelope
	beq.s	no_overlay	nee -> zet hem dan niet in de pattern
	move.l	-4(a1),(a0)	ja -> zet noot uit buffer in pattern
no_overlay
	add.l	#12,a0		naar volgende noot in pattern
	dbra	d0,overlay_notes

	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** UNDERLAY TRACK *****
underlay
	cmpi.w	#1,block_flag	staat er een track in de block buffer?
	bne	no_paste	nee -> doe niks

	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep	haal adres track en filter SAM's eruit bij kanaal B en C
	lea	block_buf,a1	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len noten
underlay_notes
	move.l	(a0)+,d1	staat hier een noot in de pattern?
	andi.l	#$ff000000,d1	bekijk alleen octaaf/noot en envelope
	bne.s	no_underlay	ja -> haal NIET noot uit buffer
	move.l	(a1),-4(a0)	nee -> zet noot uit buffer in pattern
no_underlay
	addq.l	#8,a0		naar volgende noot in pattern
	addq.l	#4,a1		naar volgende noot in buffer
	dbra	d0,underlay_notes

	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** PASTE REVERSE TRACK *****
paste_rev_track
	cmpi.w	#1,block_flag	staat er een track in de block buffer?
	bne	no_paste	nee -> doe niks

	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep		haal adres track en filter SAM's eruit bij kanaal B en C
	lea	block_buf+4*pat_len,a1	adres kopieer buffer (aan het einde want we gaan terug)

	moveq	#pat_len-1,d0	kopieer pat_len noten
paste_rev_notes
	move.l	-(a1),(a0)+	haal noot uit buffer
	addq.l	#8,a0		verhoog pointer in pattern met 8(+4 van (a1)+=12)
	dbra	d0,paste_rev_notes
	
	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;
;		***** PREPARE TRACK TRANSFER *****
; geeft in a0 track adres terug
track_prep
	move.l	pat_base,a0	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	move.l	0(a2,d0.w),d0	haal offset huidig kanaal
	beq.s	chan_A		als offset=0 -> kanaal A -> filter SAM's er niet uit
	add.l	d0,a0		tel track offset bij pattern base op -> geef dit adres terug

	lea	block_buf,a1	haal adres block buffer
	moveq	#pat_len-1,d0	filter zoveel noten
filter_notes
	tst.l	(a1)+		bekijk noot in buffer
	bpl.s	no_filter_this1	als MSB niet 1 is -> geen sample -> filter niet
	clr.l	-4(a1)		wis noot
no_filter_this1
	dbra	d0,filter_notes
chan_A	rts
;		***** CUT PATTERN *****
cut_pat
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	move.l	pat_base,a1	haal pointer naar begin pattern
	lea	block_buf,a0	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len regels
cut_lines
	move.l	(a1),(a0)+	sla noot op in buffer
	clr.l	(a1)+		wis noot in pattern
	move.l	(a1),(a0)+
	clr.l	(a1)+
	move.l	(a1),(a0)+
	clr.l	(a1)+
	dbra	d0,cut_lines

	move.w	#2,block_flag	in de block buffer staat een pattern
	clr.b	block_valid	block posities ongeldig
	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** PASTE PATTERN *****
paste_pat
	cmpi.w	#2,block_flag	staat er een pattern in de block buffer?
	bne	no_do		nee -> doe niks

	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	move.l	pat_base,a1	haal pointer naar begin pattern
	lea	block_buf,a0	adres kopieer buffer

	moveq	#pat_len-1,d0	kopieer pat_len regels
paste_lines
	move.l	(a0)+,(a1)+	haal noot uit buffer
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,paste_lines
	
	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** START BLOCK *****
s_block	move.w	pat_now,block_spat	pattern block start
	move.w	pat_lin,block_slin	pattern regel
	move.w	cursor,block_scur	cursor positie
	bset.b	#0,block_valid		start position klopt
	clr.w	block_flag		block buffer ongeldig
	bra.s	get_block		haal mogelijk blok

e_block	move.w	pat_now,block_epat	pattern block end
	move.w	pat_lin,block_elin	pattern regel
	move.w	cursor,block_ecur	cursor positie
	bset.b	#1,block_valid		end position klopt
	clr.w	block_flag		block buffer ongeldig

get_block
	cmpi.b	#%11,block_valid	beide posities ingevoerd?
	bne	no_block		nee -> doe niets

	move.w	block_spat,d0	haal pattern# start block
	cmp.w	block_epat,d0	haal pattern# end block
	bne	no_block	niet gelijk -> geen geldig blok -> doe niets

	lea	cursor_chan,a0	adres tabel cursor->offset in pattern regel
	move.w	block_scur,d0	haal cursor positie start
	move.l	0(a0,d0.w),d0	offset voor start
	move.w	block_ecur,d1	haal cursor positie end
	cmp.l	0(a0,d1.w),d0	vergelijk offset voor end met die voor start
	bne	no_block	niet gelijk -> geen geldig blok -> doe niets

	restore_pat_lin
	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	move.l	pat_base,a0	haal start huidige pattern
	lea	cursor_chan,a1	adres tabel cursor->offset in pattern regel
	move.w	block_scur,d0	haal cursor positie start(&end)
	add.l	0(a1,d0.w),a0	tel offset voor start(&end) bij start huidige pattern
	move.w	block_slin,d0	haal regel block start
	move.w	block_elin,d1	haal regel block end

	lea	block_buf,a1	adres buffer
	clr.w	buf_len		buffer is eerst leeg
next_block_line
	move.w	d0,d2		maak backup regel
	mulu.w	#12,d2		vermenigvuldig met lengte 1 regel
	move.l	0(a0,d2.w),(a1)+	haal regel uit pattern en zet hem in buffer
	addq.w	#1,buf_len	buffer is nog een noot langer	
	cmp.w	d0,d1		zijn we al bij einde van het blok
	beq.s	end_of_block	ja -> laatste long gehaald

	addq.w	#1,d0		naar volgende regel
	andi.w	#$3f,d0		maskeer mogelijke $40
	bra.s	next_block_line

end_of_block
	move.w	#3,block_flag	er staat een blok in de buffer
no_block
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** DELETE BLOCK *****
del_block
	cmpi.b	#%11,block_valid	beide posities ingevoerd?
	bne.s	no_block		nee -> doe niets

	move.w	block_spat,d0	haal pattern# start block
	cmp.w	block_epat,d0	haal pattern# end block
	bne.s	no_block	niet gelijk -> geen geldig blok -> doe niets

	lea	cursor_chan,a0	adres tabel cursor->offset in pattern regel
	move.w	block_scur,d0	haal cursor positie start
	move.l	0(a0,d0.w),d0	offset voor start
	move.w	block_ecur,d1	haal cursor positie end
	cmp.l	0(a0,d1.w),d0	vergelijk offset voor end met die voor start
	bne.s	no_block	niet gelijk -> geen geldig blok -> doe niets

	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	move.l	pat_base,a0	haal start huidige pattern
	add.l	d0,a0		tel daarbij op offset voor kanaal
	move.w	block_slin,d0	haal regel block start
	move.w	block_elin,d1	haal regel block end

next_del_block
	move.w	d0,d2		maak backup regel#
	mulu.w	#12,d2		vermenigvuldig met lengte 1 regel
	clr.l	0(a0,d2.w)	wis regel uit pattern
	cmp.w	d0,d1		zijn we al bij einde van het blok
	beq.s	end_del_block	ja -> laatste long gehaald

	addq.w	#1,d0		naar volgende regel
	andi.w	#$3f,d0		maskeer mogelijke $40
	bra.s	next_del_block

end_del_block
	st.b	pls_flag		print verandering
	st.b	no_key_repeat		laat toetsen niet repeteren
	rts
;
;		***** PASTE BLOCK *****
paste_block
	cmpi.w	#3,block_flag		staat er een block in de buffer?
	bne	no_block		nee -> geen block

	bsr	save_undo		sla huidige pattern en block op in undo-buffers
	bsr	track_prep		bereidt buffer voor op transfer (pattern adres in a0)
	lea	block_buf,a1		adres block buffer
	move.w	pat_lin,d0		haal pattern regel
	move.w	buf_len,d1		lengte buffer
	bra.s	test_paste_block	spring midden in dbra-lus

next_paste_block
	move.w	d0,d2
	mulu.w	#12,d2			pattern regel * lengte 1 regel
	move.l	(a1)+,0(a0,d2.w)	regel uit buffer naar pattern
	addq.w	#1,d0			naar volgende regel
	andi.w	#$3f,d0			maskeer mogelijke $40
test_paste_block
	dbra	d1,next_paste_block

	st.b	pls_flag		print verandering
	st.b	no_key_repeat		laat toetsen niet repeteren
	rts
;		***** OVERLAY BLOCK *****
over_block
	cmpi.w	#3,block_flag	staat er een block in de buffer
	bne	no_block	nee -> geen block

	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep	bereidt buffer voor op transfer (pattern adres in a0)
	lea	block_buf,a1	adres block buffer
	move.w	pat_lin,d0	haal pattern regel
	move.w	buf_len,d1	lengte buffer
	bra.s	test_over_block	spring midden in dbra-lus

next_over_block
	move.l	(a1)+,d3		staat hier een noot in de buffer?
	andi.l	#$ff000000,d3		bekijk alleen octaaf/noot en envelope
	beq.s	no_over_block		nee -> laat noot in pattern staan als hij is
	move.w	d0,d2
	mulu.w	#12,d2			pattern regel * lengte 1 regel
	move.l	-4(a1),0(a0,d2.w)	regel uit buffer naar pattern
no_over_block
	addq.w	#1,d0			naar volgende regel
	andi.w	#$3f,d0			maskeer mogelijke $40
test_over_block
	dbra	d1,next_over_block

	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** UNDERLAY BLOCK *****
under_block
	cmpi.w	#3,block_flag	staat er een block in de buffer
	bne	no_block	nee -> geen block

	bsr	save_undo	sla huidige pattern en block op in undo-buffers
	bsr	track_prep	bereidt buffer voor op transfer (pattern adres in a0)
	lea	block_buf,a1	adres block buffer
	move.w	pat_lin,d0	haal pattern regel
	move.w	buf_len,d1	lengte buffer
	bra.s	test_under_block	spring midden in dbra-lus

next_under_block
	move.w	d0,d2
	mulu.w	#12,d2			pattern regel * lengte 1 regel
	move.l	0(a0,d2.w),d3		kijk of er een noot in de pattern zit
	andi.l	#$ff000000,d3		bekijk alleen octaaf/noot en envelope
	bne.s	no_under_block		ja -> laat noot in pattern staan als hij is
	move.l	(a1),0(a0,d2.w)		regel uit buffer naar pattern
no_under_block
	addq.w	#1,d0			naar volgende regel
	andi.w	#$3f,d0			maskeer mogelijke $40
	addq.l	#4,a1			naar volgende positie in buffer
test_under_block
	dbra	d1,next_under_block

	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;		***** PASTE REVERSE BLOCK *****
paste_rev_block
	cmpi.w	#3,block_flag		staat er een block in de buffer?
	bne	no_block		nee -> geen block

	bsr	save_undo		sla huidige pattern en block op in undo-buffers
	bsr	track_prep		bereidt buffer voor op transfer (pattern adres in a0)
	lea	block_buf,a1		adres block buffer
	move.w	pat_lin,d0		haal pattern regel
	move.w	buf_len,d1		lengte buffer
	move.w	d1,d2
	asl.w	#2,d2			maal 4 voor lengte buffer in bytes
	add.w	d2,a1			tel op bij adres block buffer
	bra.s	test_paste_rev_block	spring midden in dbra-lus

next_paste_rev_block
	move.w	d0,d2
	mulu.w	#12,d2			pattern regel * lengte 1 regel
	move.l	-(a1),0(a0,d2.w)	regel uit buffer naar pattern
	addq.w	#1,d0			naar volgende regel
	andi.w	#$3f,d0			maskeer mogelijke $40
test_paste_rev_block
	dbra	d1,next_paste_rev_block

	st.b	pls_flag		print verandering
	st.b	no_key_repeat		laat toetsen niet repeteren
	rts
;
;		***** TRANSPOSE TRACK UP *****
trans_up
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers

	move.l	pat_base,a1	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	move.w	#pat_len-1,d0	transponeer pat_len noten
trans_up_notes
	move.b	(a1),d1		haal noot
	beq.s	next_up		noot=0 -> lege noot -> volgende noot
	bmi.s	next_up		noot<0 -> sample noot -> volgende noot
	cmpi.b	#7*16+12,d1	is deze noot B 7 = hoogst mogelijke noot?
	beq.s	next_up		ja -> verander hem niet
	move.b	d1,d2		maak back-up
	lsr.b	#4,d1		zet octaaf op goede plaats en verwijder noot#
	andi.b	#%1111,d2	houd alleen noot over
	addi.b	#1,d2		verhoog noot
	cmpi.b	#13,d2		is noot te hoog geworden?
	bne.s	no_note_hi	nee -> laat het zo
	move.b	#1,d2		noot=1
	addi.b	#1,d1		verhoog octaaf
no_note_hi
	asl.b	#4,d1		zet octaaf weer waar hij stond
	or.b	d2,d1		doe noot erbij
	move.b	d1,(a1)		sla octaaf/noot op
next_up
	add.l	#12,a1		naar volgende noot
	dbra	d0,trans_up_notes

	st.b	pls_flag	print verandering
	rts
;		***** TRANSPOSE TRACK DOWN *****
trans_down
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers

	move.l	pat_base,a1	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	move.w	#pat_len-1,d0	transponeer pat_len noten
trans_down_notes
	move.b	(a1),d1		haal noot
	beq.s	next_down	noot=0 -> lege noot -> volgende noot
	bmi.s	next_down	noot<0 -> sample noot -> volgende noot
	cmpi.b	#0*16+1,d1	is deze noot C 0 = laagst mogelijke noot?
	beq.s	next_down	ja -> niet veranderen
	move.b	d1,d2		maak back-up
	lsr.b	#4,d1		zet octaaf op goede plaats en verwijder noot#
	andi.b	#%1111,d2	houd alleen noot over
	subi.b	#1,d2		verlaag noot
	bne.s	no_note_lo	als niet niet 0 is geworden -> laat het zo
	move.b	#12,d2		noot=12 (hoogste)
	subi.b	#1,d1		verlaag octaaf
no_note_lo
	asl.b	#4,d1		zet octaaf weer waar hij stond
	or.b	d2,d1		doe noot erbij
	move.b	d1,(a1)		sla octaaf/noot op
next_down
	add.l	#12,a1		naar volgende noot
	dbra	d0,trans_down_notes

	st.b	pls_flag	print verandering
	rts
;
;		***** TRANSPOSE VOLUME UP *****
trans_vol_up
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers

	move.l	pat_base,a1	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	move.w	#pat_len-1,d0	transponeer pat_len noten
trans_vol_up_notes
	tst.b	(a1)		staat er iets in deze noot?
	beq.s	next_vol_up	noot=0 -> lege noot -> volgende noot
	bmi.s	next_vol_up	noot<0 -> sample noot -> volgende noot

	move.b	3(a1),d1	haal envelope/volume
	move.b	d1,d2		bewaar envelope
	andi.b	#%11111,d1	bekijk volume
	cmp.b	#$f,d1		volume hoogste?
	beq.s	next_vol_up	ja -> niet transposen

	addi.b	#1,d1		verhoog volume
	andi.b	#%11000000,d2	hou envelope over
	or.b	d1,d2		zet volume daarbij
	move.b	d2,3(a1)	sla envelope/volume op
next_vol_up
	add.l	#12,a1		naar volgende noot
	dbra	d0,trans_vol_up_notes

	st.b	pls_flag	print verandering
	rts
;		***** TRANSPOSE VOLUME DOWN *****
trans_vol_down
	restore_pat_lin		herstel noten bij pattern play
	bsr	save_undo	sla huidige pattern en block op in undo-buffers

	move.l	pat_base,a1	haal pointer naar begin pattern
	move.w	cursor,d0	haal cursor pos*4
	lea	cursor_chan,a2	haal adres tabel met offsets naar kanalen in pattern regel
	add.l	0(a2,d0.w),a1	tel op bij pointer in pattern

	move.w	#pat_len-1,d0	transponeer pat_len noten
trans_vol_down_notes
	tst.b	(a1)		staat er iets in deze noot?
	beq.s	next_vol_down	noot=0 -> lege noot -> volgende noot
	bmi.s	next_vol_down	noot<0 -> sample noot -> volgende noot

	move.b	3(a1),d1	haal envelope/volume
	move.b	d1,d2		bewaar envelope
	andi.b	#%11111,d1	bekijk volume
	beq.s	next_vol_down	als volume=0 -> niet transposen

	subi.b	#1,d1		verlaag volume
	andi.b	#%11000000,d2	hou envelope over
	or.b	d1,d2		zet volume daarbij
	move.b	d2,3(a1)	sla envelope/volume op
next_vol_down
	add.l	#12,a1		naar volgende noot
	dbra	d0,trans_vol_down_notes

	st.b	pls_flag	print verandering
	rts
;
;		***** CUT YM SOUND *****
cut_yms	bsr	save_undo		sla huidige pattern, block buffer & ym sound op in undo-buffer

	lea	block_buf,a0		adres kopieer buffer
	moveq	#0,d0
	move.b	ym_sound,d0		haal nummer YM sound
	asl.w	#3,d0			iedere naam is 8 tekens lang
	lea	ym_names,a1		adres tabel met namen
	move.l	0(a1,d0.w),(a0)+	zet naam ook in block-buffer
	move.l	4(a1,d0.w),(a0)+

	move.l	ym_ptr,a1		haal pointer naar ym sound
	move.w	#i_total_len-1,d0	kopieer hele ym sound
cut_ymbytes
	move.b	(a1)+,(a0)+		sla byte uit ym sound op in buffer
	dbra	d0,cut_ymbytes


	bsr	clr_yms		wis ym sound
	bsr	print_yef	print ym edit field

	move.w	#4,block_flag	in de block buffer staat een ym sound
	clr.b	block_valid	block posities ongeldig
	st.b	pls_flag	print verandering
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;
;		***** PASTE YM SOUND *****
paste_yms
	cmpi.w	#4,block_flag	staat er een ym sound in de block buffer
	bne.s	no_ym_block	nee -> doe niets

	bsr	save_undo	sla huidige pattern, block buffer & ym sound op in undo-buffer

	lea	block_buf,a1		adres kopieer buffer
	moveq	#0,d0
	move.b	ym_sound,d0		haal nummer YM sound
	asl.w	#3,d0			iedere naam is 8 tekens lang
	lea	ym_names,a0		adres tabel met namen
	move.l	(a1)+,0(a0,d0.w)	naam staat ook in block-buffer
	move.l	(a1)+,4(a0,d0.w)

	move.l	ym_ptr,a0		haal pointer naar ym sound
	move.w	#i_total_len-1,d0	kopieer hele ym sound
paste_ymbytes
	move.b	(a1)+,(a0)+		sla byte uit ym sound op in buffer
	dbra	d0,paste_ymbytes


	clr.b	block_valid	block posities ongeldig
	bsr	print_yef	print YM edit field
no_ym_block
	st.b	no_key_repeat	laat toetsen niet repeteren
	rts
;
;		***** UNDO FUNCTIONS *****
; bewaar huidige pattern en block buffer:
save_undo
	movem.l	d0/a0-a1,-(sp)	sla register op op stack
	move.l	pat_base,a0	adres huidige pattern
	move.l	a0,undo_pat_ptr	sla dat adres op, zodat UNDO op goede plaats gedaan wordt
	lea	undo_pat,a1	adres pattern opslag
	moveq	#pat_len-1,d0	copieer zoveel noten
save_pattern
	move.l	(a0)+,(a1)+	sla noot op in undo buffer
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,save_pattern

	lea	block_var_start,a0			adres block variabelen en buffer
	lea	undo_block,a1				adres block opslag
	move.w	#block_var_end-block_var_start-1,d0	lengte block var's en buffer
save_block
	move.b	(a0)+,(a1)+	sla byte van block var's en buffer op
	dbra	d0,save_block

	lea	ym_sounds,a0	haal adres begin YM sounds
	move.b	ym_sound,d0	haal YM sound nummer
	andi.w	#$3f,d0		maak word van YM sound
	asl.w	#8,d0		maal 256(=lengte 1 ym sound)
	add.w	d0,a0		tel die offset op bij start adres
	move.l	a0,undo_yms_ptr	sla pointer naar te 'undo'en ym sound op
	lea	undo_yms,a1	adres undo-buffer ym sound
	move.w	#i_total_len-1,d0	lengte 1 ym sound
save_ymsound
	move.b	(a0)+,(a1)+	sla byte van ym sound op in undo-buffer
	dbra	d0,save_ymsound

	moveq	#0,d0
	move.b	ym_sound,d0		haal nummer YM sound
	asl.w	#3,d0			iedere naam is 8 tekens lang
	lea	ym_names,a0		adres tabel met namen
	lea	0(a0,d0.w),a0		tel offset bij basisadres
	move.l	a0,undo_name_ptr	sla adres van naam op
	lea	undo_ymsname,a1		adres ym sound name in undo-buffer
	move.l	(a0)+,(a1)+		sla naam ook in undo-buffers op
	move.l	(a0),(a1)+

	st.b	undo_valid	verklaar undo-buffers geldig	
	movem.l	(sp)+,d0/a0-a1	herstel registers
	rts
; herstel huidige pattern en block buffer:
do_undo
	tst.b	undo_valid	kloppen undo-buffers?
	beq.s	no_undo		nee -> herstel niet

	move.l	undo_pat_ptr,a1	adres te 'undo'en pattern
	lea	undo_pat,a0	adres pattern opslag
	moveq	#pat_len-1,d0	copieer zoveel noten
do_undo_pattern
	move.l	(a0)+,(a1)+	haal noot uit undo-buffer
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,do_undo_pattern

	lea	block_var_start,a1			adres block variabelen en buffer
	lea	undo_block,a0				adres block opslag
	move.w	#block_var_end-block_var_start-1,d0	lengte block var's en buffer
do_undo_block
	move.b	(a0)+,(a1)+	haal byte van block var's en buffer op uit undo-buffer
	dbra	d0,do_undo_block

	move.l	undo_yms_ptr,a1		adres te 'undo'en ym sound
	lea	undo_yms,a0		adres undo-buffer ym sound
	move.w	#i_total_len-1,d0	lengte 1 ym sound
do_undo_ymsound
	move.b	(a0)+,(a1)+		haal byte van ym sound uit undo-buffer
	dbra	d0,do_undo_ymsound

	move.l	undo_name_ptr,a1	adres te 'undo'en naam
	lea	undo_ymsname,a0		adres ym sound name in undo-buffer
	move.l	(a0)+,(a1)+		naam staat ook in undo-buffer
	move.l	(a0)+,(a1)

	st.b	pls_flag	print verandering
	clr.b	undo_valid	verklaar undo-buffers ONgeldig
no_undo
	rts
;
do_undo_yef
	bsr	do_undo		herstel alles
	bsr	print_yef	print ym edit field
	rts
;
;
;		***** HELP SCREEN ROUTS *****
scroll_down
	cmpi.w	#help_len,help_pos	zitten we al aan het einde van de HELP file?
	beq.s	no_scroll		ja -> niet scrollen
	addq.w	#1,help_pos
no_scroll
	rts
;
scroll_up
	tst.w	help_pos	zitten we aan het begin van de HELP file?
	beq.s	no_scroll	ja -> niet scrollen
	subq.w	#1,help_pos
	rts
;		***** BIG BUTTON SUBS *****
s_play	move.w	#1,patmode		zet song play aan
	clr.w	pat_lin			zet pattern regel op 0
	bra	redo_buttons
p_play	move.w	#2,patmode		zet patt play aan
	clr.w	pat_lin			zet pattern regel op 0
	bra	redo_buttons
s_rec	move.w	#3,patmode		zet song rec aan
	clr.w	pat_lin			zet pattern regel op 0
	bra	redo_buttons
p_rec	move.w	#4,patmode		zet patt rec aan
	clr.w	pat_lin			zet pattern regel op 0
	bra	redo_buttons
p_stop	clr.w	patmode			stop
	bsr	snd_init		clear sound chip	
	bra	redo_buttons
;
redo_buttons
	restore_pat_lin			zorg dat opslag buffer van polyplay terecht komt
	clr.b	pause_mode		speel gewoon door

	move.w	patmode,d0		haal afspeel modus
	asl.w	#2,d0			voor offset in long tabel
	lea	pm_2_routs,a0		tabel : patmode -> tabel met keys
	move.l	0(a0,d0.w),key_routs	zet goede toets tabel aan
	lea	pm_2_spr,a0		tabel : patmode -> sprite
	move.l	0(a0,d0.w),a1		haal adres sprite
	st.b	pls_flag		print mogelijke verandering door restore_pat_lin

	move.l	phys_0,a0	haal scherm adres
	add.l	#ll*95,a0	begin bij regel 95
	moveq	#20,d0		kopieer 21 regels
copy_but_line
	moveq	#6,d1		kopieer 7 stukken=1 regel
copy_but_part
	move.l	(a1)+,(a0)+	kopieer 1 stuk
	move.w	(a1)+,(a0)+	.
	addq.l	#2,a0		
	dbra	d1,copy_but_part
;
	add.l	#104,a0			naar volgende regel op scherm
	dbra	d0,copy_but_line	verder met volgende regel

	move.w	#1,note_count
	clear_key			wis toetsen
	rts
;
;		***** EINDE PLAY/REC BUTTONS *****
;
;		***** CHANNEL BUTTONS *****
;
chan1	clr.w	cursor		zet cursor positie op 0
	restore_pat_lin		herstel pattern
	clear_key		wis toetsen
	bsr	print_cursor	zet cursor op goede plaats
	rts	
;
chan2	move.w	#32,cursor	zet cursor pos op 8(*4=32) voor kanaal B
	restore_pat_lin		herstel pattern
	clear_key		wis toetsen
	bsr	print_cursor	zet cursor op goede plaats
	rts	
;
chan3	move.w	#64,cursor	zet cursor pos op 16(*4=64) voor kanaal C
	restore_pat_lin		herstel pattern
	clear_key		wis toetsen
	bsr	print_cursor	zet cursor op goede plaats
	rts	
;		***** MUTE BUTTONS *****
mute1	st.b	no_mouse_repeat
	bset.b	#0,Adata+silent		zet geluid uit
	bchg.b	#2,Adata+silent		toggle mute bit van kanaal A
	bne.s	no_sam_off		als bit 1 was -> gaat mute nu aan -> zet sample echt uit
	move.w	#$2700,sr		interrupts uit
	bclr.b	#1,Adata+silent
	bclr.b	#TA_bn,IERA		zet timer A uit
	move.w	#$2300,sr		interrupts weer aan
no_sam_off
	rts
;
mute2	st.b	no_mouse_repeat
	bset.b	#0,Bdata+silent		zet geluid uit
	bchg.b	#2,Bdata+silent		toggle mute bit van kanaal B
	rts
;
mute3	st.b	no_mouse_repeat
	bset.b	#0,Cdata+silent		zet geluid uit
	bchg.b	#2,Cdata+silent		toggle mute bit van kanaal C
	rts
;
;		***** SCHERM OVERSCHAKEL ROUTINES *****
;
;		***** TEKEN MAIN SCREEN *****
main_scr
	tst.w	old_speed	bekijk back-up van speed
	beq.s	speed_is_ok	als back-up=0, dan is het geen back-up
	move.w	old_speed,speed	herstel oude speed
	clr.w	old_speed	als teken dat back-up ongeldig is
speed_is_ok
	move.b	old_B_silent,d0		haal oude silent waarde van kanaal B
	andi.b	#%100,d0		hou alleen mute bit over
	beq.s	mute_B_is_ok		als mute bit=0 -> verander niks aan mute

	move.b	old_B_silent,Bdata+silent	zet goede waarde van silent van B erin
	clr.b	old_B_silent			wis oude waarde zodat dit de volgende keer niet in Bsilent gezet wordt
mute_B_is_ok
	clr.w	patmode			zet stop aan
	bsr	snd_init
;
main_from_help
	move.l	#but_main,mouse_routs	pointers naar muis-coordinaten
	move.l	#prbut_main,update_rout	en update routine goed
	clr.b	asc_mode		geen invoer meer
	clear_key			wis toetsen
	st.b	no_key_repeat		laat toetsen niet repeteren
	st.b	pls_flag		print pattern regels
	clr.b	pls_mode		en laat het ook toe
	clr.b	rasmode			wel rasters
	clr.b	led_mode		LED knippert weer en opnemen werkt weer
	clr.b	demo_mode		geen demo in help-screen
	bsr	put_pal			stel pallette in
	bsr	main_graf		teken graphics
	rts
;
; deze routine verzorgt de graphics voor het main screen
main_graf
	move.l	phys_0,a0	begin adres scherm
	lea	mainpic,a1	plaatje hoofdmenu
	move.w	#32000-1/8,d0	aantal te copieren longs
copy_main
	move.l	(a1)+,(a0)+	copieer long van plaatje op scherm
	move.w	(a1)+,(a0)+	copieer word
	clr.w	(a0)+		clear word
	dbra	d0,copy_main

	bsr	put_menu	print menu's
	bsr	redo_buttons	print PLAY/REC buttons
	bsr	prbut_main	print buttons
	bsr	print_cursor	print cursor
	bsr	print_pls	print pattern regels

	rts
; deze routine wist de message box gebruikt tijdens het file selecten van het beeld :
main_clr_box
	move.l	phys_0,a0	begin adres scherm
	lea	mainpic,a1	plaatje hoofdmenu
	move.w	#(16*20)-1,d0	aantal te copieren longs
copy_main_fsel
	move.l	(a1)+,(a0)+	copieer long van plaatje op scherm
	move.w	(a1)+,(a0)+	copieer word
	clr.w	(a0)+		clear word
	dbra	d0,copy_main_fsel

	bsr	put_menu	print menu's
	bsr	prbut_main	print buttons

	rts
;
;		***** TEKEN YM EDIT SCREEN *****
yme_scr
	move.l	#but_yme,mouse_routs	zet pointers naar muis-coordinaten
	move.l	#prbut_yme,update_rout	en update routine goed
	move.l	#test_keys,key_routs	pointer naar toetsen
	clr.b	asc_mode		geen invoer meer
	clear_key			wis toetsen
	st.b	rasmode			geen rasters
	st.b	pls_mode		en geen Adamski e.d.
	move.w	#6,patmode		zet test play aan
	bsr	snd_init
	tst.w	old_speed		bekijk opgeslagen snelheid
	bne.s	no_save_speed		<>0 -> er is al een snelheid opgelsagen
	move.w	speed,old_speed		bewaar speed
	move.w	#2,speed		nieuwe snelheid in YM edit
no_save_speed
	move.b	Bdata+silent,old_B_silent	bewaar waarde van B silent
	move.b	#%001,Bdata+silent	mute bit uit -> geluid ook uit

	bsr	yme_graf		teken YM edit screen

	rts
;
; deze routine verzorgt de graphics voor het ym edit screen
yme_graf
	move.l	phys_0,a0	begin adres scherm
	lea	ymepic,a1	plaatje ym edit screen
	move.w	#32000-1/8,d0	aantal te copieren longs
copy_yme
	move.l	(a1)+,(a0)+	copieer long van plaatje op scherm
	move.w	(a1)+,(a0)+	copieer word
	addq.l	#2,a0		sla word over
	dbra	d0,copy_yme

	bsr	print_yef_first	print YM edit field na berekenen van ym_ptr
	bsr	prbut_yme	print buttons

	rts
;
; deze routine wist de message box gebruikt tijdens het file selecten van het beeld :
yme_clr_box
	move.l	phys_0,a0	begin adres scherm
	lea	ymepic,a1	plaatje hoofdmenu
	move.w	#(16*20)-1,d0	aantal te copieren longs
copy_yme_fsel
	move.l	(a1)+,(a0)+	copieer long van plaatje op scherm
	move.w	(a1)+,(a0)+	copieer word
	clr.w	(a0)+		clear word
	dbra	d0,copy_yme_fsel

	rts
;
;		***** TEKEN HELP-SCREEN *****
help_scr
	move.l	#but_help,mouse_routs	zet pointers naar muis-coordinaten
	move.l	#print_help,update_rout	en update routine goed
	move.l	#help_keys,key_routs	pointer naar toetsen
	st.b	rasmode			geen rasters
	st.b	pls_mode		patterns regels mogen niet meer getekend worden
	clr.b	asc_mode		invoer uit
	st.b	no_key_repeat		laat toetsen niet repeteren
	st.b	led_mode		LED knippert niet en opnemen werkt niet
	st.b	demo_mode		teken demo van nu af aan
	bsr	put_pal			stel pallette in
	move.w	#1,logo_color		logo moet kleur krijgen
	move.w	#1,dist_color		distortion moet kleur krijgen

	move.l	phys_0,a0	begin adres beeldscherm
	lea	helpup,a1	begin adres bovenste deel help screen
	move.w	#(20*18)-1,d0	copieer 18 regels
copy_help_up
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq.l	#2,a0		spring over 4de bitplane heen
	dbra	d0,copy_help_up
;
	move.l	#$ffff0000,d1	voor bitplanes 1&2
	move.l	#$80000000,d2	voor bitplanes 3&4 links
	move.l	#$fffe0001,d3	voor bitplanes 1&2 rechts
	move.l	#$00010000,d4	voor bitplanes 3&4 rechts
	move.w	#200-37,d0	copieer scherm vol regels
;
copy_help_mid
	move.l	d1,(a0)+	linker lijntje
	move.l	d2,(a0)+
;
	move.l	d1,(a0)+	middelste deel
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
;
	move.l	d1,(a0)+	middelste deel
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
;
	move.l	d1,(a0)+	middelste deel
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
;
	move.l	d3,(a0)+	rechter lijntje
	move.l	d4,(a0)+
;
	dbra	d0,copy_help_mid
;
	lea	helpdn,a1	begin adres bovenste deel help screen
	move.w	#(20*18)-1,d0	copieer 18 regels
copy_help_down
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	addq.l	#2,a0		spring over 4de bitplane heen
	dbra	d0,copy_help_down

	rts
;
;
;		***** MENU CHANGE SUBS *****
da_select
	move.b	#1,menu_mode		we zitten nu in Disk Access Menu
	bra.s	put_menu		zet menu neer
;
mem_select
	move.b	#2,menu_mode		we zitten nu in Memory Menu
	bra.s	put_menu		zet menu neer
;
adam_restore
	clr.b	menu_mode		we zitten nu in Adamski Menu
;
put_menu
	moveq	#0,d0
	move.b	menu_mode,d0		haal huidig menu nummer
	asl.w	#3,d0			iedere entry 2 longs
	lea	menu_data,a0		adres data voor menu's
	move.l	0(a0,d0.w),menu_routs	adres coordinaten van dit menu
	move.l	4(a0,d0.w),a0		adres sprite dit menu
	move.l	phys_0,a1	haal schermadres
	add.l	#ll*12,a1	positie y=12
	moveq	#77,d0		hoogte=78
;
put_menu_line
	move.l	(a0)+,(a1)	1ste en 2de bitplane
	move.w	(a0)+,4(a1)	3de bitplane
	move.l	(a0)+,8(a1)
	move.w	(a0)+,12(a1)
	move.l	(a0)+,16(a1)
	move.w	(a0)+,20(a1)
;
	move.l	(a0)+,24(a1)
	move.w	(a0)+,28(a1)
	move.l	(a0)+,32(a1)
	move.w	(a0)+,36(a1)
	move.l	(a0)+,40(a1)
	move.w	(a0)+,44(a1)
	move.l	(a0)+,48(a1)
	move.w	(a0)+,52(a1)
	move.l	(a0)+,56(a1)
	move.w	(a0)+,60(a1)
;
	add.l	#ll,a1			naar volgende regel op scherm
	dbra	d0,put_menu_line	zet volgende regel van menu op scherm

	st.b	no_mouse_repeat		muis kan even niet meer klikken
	rts
;
;		***** YES_NO DIALOG BOX *****
; invoer   :
; d0.w     : x-positie
; d1.w     ; y-positie
; terug    : 
; d0.w     : 0=Yes, 1=No
; gebruikt : d0-d3/a0-a3
ask_sure
	move.l	phys_0,a1	haal schermadres
	move.w	d1,d3		sla y-positie op voor later
	mulu.w	#ll,d1		vermenigvuldig y-positie met lengte 1 regel
	cmpi.w	#192,d0		x-positie te groot?
	bls.s	x_ok
	move.w	#192,d0		voorkom dat box een stuk rechts en een stuk links te zien is
x_ok	andi.w	#$00f0,d0	snap x-positie op word groep
	move.w	d0,d2		sla ge'snap'te x-positie op voor later
	lsr.w	#1,d0		deel door 2 voor offset bij scherm adres
	add.w	d0,d1		tel beide offsets bij elkaar op
	lea	0(a1,d1.w),a1	tel beide offsets bij schermadres
	move.l	a1,a3		bewaar schermadres voor restore
	lea	yes_no_spr,a0	adres Are You Sure? sprite
	lea	misc_buf,a2	bewaar achtergrond in inlaad buffer voor samples
	move.w	#34,d1		hoogte=35
;
put_sure_line
	move.l	(a1),(a2)+	sla achtergrond op, 1ste&2de bitplane
	move.l	(a0)+,(a1)	zet sprite neer, 1ste&2de bitplane
	move.w	4(a1),(a2)+	sla achtergrond op, 3de bitplane
	move.w	(a0)+,4(a1)	zet sprite neer, 3de bitplane
;
	move.l	8(a1),(a2)+
	move.l	(a0)+,8(a1)
	move.w	12(a1),(a2)+
	move.w	(a0)+,12(a1)
;
	move.l	16(a1),(a2)+
	move.l	(a0)+,16(a1)
	move.w	20(a1),(a2)+
	move.w	(a0)+,20(a1)
;
	move.l	24(a1),(a2)+
	move.l	(a0)+,24(a1)
	move.w	28(a1),(a2)+
	move.w	(a0)+,28(a1)
;
	move.l	32(a1),(a2)+
	move.l	(a0)+,32(a1)
	move.w	36(a1),(a2)+
	move.w	(a0)+,36(a1)
;
	move.l	40(a1),(a2)+
	move.l	(a0)+,40(a1)
	move.w	44(a1),(a2)+
	move.w	(a0)+,44(a1)
;
;
	add.l	#ll,a1			naar volgende regel op scherm
	dbra	d1,put_sure_line	zet volgende regel van sure-box op scherm
;		***** WACHT OP MUISKLIK IN YES_NO *****
wait_no_mbut
	move.b	mousek,d0	haal status muisknoppen
	andi.b	#%11,d0		bekijk muisknoppen
	bne.s	wait_no_mbut	als er nog een ingedrukt is -> blijf wachten tot knoppen los zijn
;
wait_yes_mbut
	move.b	mousek,d0	haal status muisknoppen
	andi.b	#%11,d0		bekijk muisknoppen
	beq.s	wait_yes_mbut	als er geen ingedrukt is -> blijf wachten op muisklik
;
;		***** BEKIJK MUIS COORDINAAT IN YES_NO *****
	lea	yes_no_buts,a0	haal adres button tabel YES/NO dialog

	move.w	mousex,d0	haal muis x positie
	sub.w	d2,d0		trek daar x positie dialog vanaf
	move.w	mousey,d1	haal muis y positie
	sub.w	d3,d1		trek daar y positie dialog vanaf
next_yes_no
	cmp.w	(a0),d0		klopt x positie #1
	blo.s	not_yes_no	te laag -> volgende button
	cmp.w	2(a0),d1	klopt y positie #1
	blo.s	not_yes_no	te laag -> volgende button
	cmp.w	4(a0),d0	x positie #2
	bhi.s	not_yes_no	te hoog -> volgende button
	cmp.w	6(a0),d1	y positie #2
	bhi.s	not_yes_no	te hoog -> volgende button
;				wel goede button, dus:
	move.w	8(a0),d0	haal waarde om terug te geven
	bra.s	restore_sure	en herstel achtergrond
;
not_yes_no
	adda.l	#10,a0		naar volgende button
	tst.l	4(a0)		kijk naar x/y pos #2 -> als die 0 is dit laatste item
	bne.s	next_yes_no	nee -> volgende button bekijken
	bra.s	wait_yes_mbut	ja -> wacht op goede muisklik
;
;		****** HERSTEL ACHTERGROND ACHTER ARE-YOU-SURE DIALOG *****
restore_sure
	lea	misc_buf,a0	bewaar achtergrond in inlaad buffer voor samples
	move.w	#34,d1		hoogte=35
;	in a3 staat schermadres nog
;
rest_sure_line
	move.l	(a0)+,(a3)	herstel achtergrond, 1ste&2de bitplane
	move.w	(a0)+,4(a3)	herstel achtergrond, 3de bitplane
	move.l	(a0)+,8(a3)
	move.w	(a0)+,12(a3)
	move.l	(a0)+,16(a3)
	move.w	(a0)+,20(a3)
;
	move.l	(a0)+,24(a3)
	move.w	(a0)+,28(a3)
	move.l	(a0)+,32(a3)
	move.w	(a0)+,36(a3)
	move.l	(a0)+,40(a3)
	move.w	(a0)+,44(a3)
;
	add.l	#ll,a3			naar volgende regel op scherm
	dbra	d1,rest_sure_line	herstel volgende regel van achtergrond
;
	st.b	no_key_repeat		laat toetsen niet repeteren
	st.b	no_mouse_repeat		laat muisknoppen niet repeteren
;
	rts
;
;
;		***** PATTERN FUNCTIONS *****
;
;		***** INSERT PATTERN *****
ins_pat	cmpi.w	#max_pat,last_pat	vergelijk aantal patterns met maximum
	beq	no_do			als dat al bereikt is -> doe niks
;
	st.b	pause_mode	pauseer afspelen
	move.w	last_pat,d0	haal nummer te clearen pattern
	addq.w	#1,last_pat	verhoog aantal patterns

	lea	patterns,a0		basis adres patterns
	mulu.w	#note_len*pat_len,d0	nummer pattern*lengte pattern
	add.w	d0,a0			nu hebben we basisadres nieuwe pattern
	move.w	#pat_len-1,d0		haal aantal te wissen regels
clear_pat
	clr.l	(a0)+		wis kanaal A
	clr.l	(a0)+		en B
	clr.l	(a0)+		en C
	dbra	d0,clear_pat

	bsr	calc_pos		update allerlei variabelen
	st.b	pls_flag		print veranderingen
	st.b	no_mouse_repeat		laat muis niet repeaten
	rts
;
;		***** DELETE PATTERN *****
del_pat	cmpi.w	#1,last_pat	vergelijk aantal patterns met minimum
	beq	no_do		als dat al bereikt is -> doe niks
;
	yes_no
;
	st.b	pause_mode	pauseer afspelen
	subq.w	#1,last_pat	verlaag aantal patterns

	move.l	pat_base,a1	target = beginadres huidige pattern
	lea	note_len*pat_len(a1),a0	source = adres volgende pattern
	move.l	#pat_last,d0	lengte = hoogst mogelijk adres
	sub.l	a0,d0		min target adres
	bsr	copy_mem	copieer patterns

	lea	pos_tab,a0	haal adres tabel met positions
	move.w	pat_now,d0	haal huidige pattern=gewiste pattern
	moveq	#120-1,d1	doorzoek 120 positions
search_pos
	move.b	(a0),d2		haal pattern# van dit position
	beq.s	pos_ok		als position = 0 -> hoe dan ook niet verlagen
	cmp.b	d0,d2		vergelijk met maximum
	blo.s	pos_ok		als pattern# kleiner is -> doe niks
	subi.b	#1,(a0)		verlaag pattern# met 1
pos_ok	addq.l	#1,a0		naar volgende position
	dbra	d1,search_pos

	bsr	calc_pos	update allerlei variabelen
	st.b	pls_flag	print veranderingen
	st.b	no_mouse_repeat	laat muis niet repeaten
	rts	
;		***** MAIN MENU INPUT FUNCTIONS *****
ym_name_main
	move.w	#17,stringx	
	move.w	#32,stringy
	clr.w	asc_cur		zet cursor op het begin
	clear_key		wis toetsen
	st.b	asc_mode	zet invoeren aan

	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	move.l	a0,asc_string	zet dat in pointer van nu in te voeren string
	rts
;
sam_name_main
	move.w	#17,stringx	
	move.w	#22,stringy
	clr.w	asc_cur		zet cursor op het begin
	clear_key		wis toetsen
	st.b	asc_mode	zet invoeren aan

	move.w	cur_sam,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	sam_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	move.l	a0,asc_string	zet dat in pointer van nu in te voeren string
	rts
;
song_name_main
	move.w	#17,stringx	
	move.w	#12,stringy
	clr.w	asc_cur		zet cursor op het begin
	clear_key		wis toetsen
	st.b	asc_mode	zet invoeren aan

	move.l	#song_name,asc_string	zet pointer van nu in te voeren string
	rts
;
ym_name_yme
	move.w	#31,stringx	
	move.w	#101,stringy
	clr.w	asc_cur		zet cursor op het begin
	clear_key		wis toetsen
	bset.b	#0,Bdata+silent	zet geluid uit
	st.b	asc_mode	zet invoeren aan

	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	move.l	a0,asc_string	zet dat in pointer van nu in te voeren string
	st.b	no_mouse_repeat	laat muis niet herhalen
	rts
;
;
;		***** MEMORY MENU CLEAR FUNCTIONS *****
mem_all	yes_no
clr_all	bsr	clr_vst		wis voice set
	bsr	clr_song	wis song
	rts
;
;		***** INITIALISEER SONG *****
mem_song
	yes_no
clr_song
	bsr	snd_init		zet geluid uit
	restore_pat_lin			zet pattern regels goed
	move.l	#$20202020,song_name	wis naam
	move.l	#$20202020,song_name+4
	
	lea	song,a0					adres begin song
	move.w	#(patterns-song)+pat_len*note_len,d0	wis variabelen en eerste pattern
clr_notes
	clr.b	(a0)+
	dbra	d0,clr_notes

	move.w	#8,speed	snelheid
	move.w	#1,last_pat	er is 1 pattern
	clr.w	pos_now		wis huidige positie
	bsr	calc_pos	bereken pointers
	st.b	pls_flag	print verandering
	bsr	snd_init	zet geluid uit
	st.b	no_mouse_repeat	slechts enkele klik mogelijk

	rts
;		***** INITIALISEER VOICE SET *****
;
;		***** INITIALISEER YM SOUNDS ******
mem_vst	yes_no
clr_vst	st.b	pause_mode	pauseer afspelen
	lea	ym_sounds,a1	adres YM sounds
	move.w	#64-1,d0	zet defaults in 64 YM sounds
default_ym
	move.w	#i_total_len-1,d1		wis i_total_len bytes
clear_ym
	clr.b	0(a1,d1.w)
	dbra	d1,clear_ym

	move.w	#1,i_env_sustain(a1)	end sustain op 1
	move.w	#2,i_env_release(a1)	end release op 2
	move.w	#1,i_pit_sustain(a1)	end pitch sustain op 1
	move.w	#2,i_pit_release(a1)	end pitch release op 2
	move.b	#1,i_sound_mode(a1)	zet tone aan
	move.b	#8,i_env_type(a1)	hardware envelope type op 8
	move.w	#11,i_vibr_depth(a1)	vibrato depth op 11(=1(geprint)=laagst)
	add.l	#i_total_len,a1		naar volgende YM sound
	dbra	d0,default_ym
;
	lea	ym_names,a1	adres YM sound namen
	move.w	#64-1,d0	bewerk 64 YM namen
default_ym_names
	move.l	#$20202020,(a1)+	zet spaties in naam
	move.l	#$20202020,(a1)+	zet spaties in naam
	dbra	d0,default_ym_names
;
	bsr	clr_sams		wis samples
	rts
;
;		***** INITIALISEER SAMPLES *****
mem_sams
	yes_no
clr_sams
	bsr	snd_init		zet geluid uit
	st.b	pause_mode		pauseer afspelen
	lea	sam_len,a0		tabel sample lengtes
	moveq	#15,d0			16 lengtes (laat 16 loze lengtes op 0 staan)
init_sam1
	move.l	#1,(a0)+		lengte is 1
	dbra	d0,init_sam1
	bsr	calc_sam_ptrs		bereken pointers
	
	lea	sam_rates,a0		adres sample rates
	move.l	#$0f0f0f0f,(a0)+	zet sample rates standaard op 15
	move.l	#$0f0f0f0f,(a0)+
	move.l	#$0f0f0f0f,(a0)+
	move.l	#$0f0f0f0f,(a0)+

	lea	sam_first,a0		adres samples
	move.l	#$ffffffff,(a0)+	zet alle -1's, einde-sample bytes neer
	move.l	#$ffffffff,(a0)+
	move.l	#$ffffffff,(a0)+
	move.l	#$ffffffff,(a0)+

	lea	sam_names,a1	adres sample namen
	move.w	#16-1,d0	bewerk 16 sample namen
default_sam_names
	move.l	#$20202020,(a1)+	zet spaties in naam
	move.l	#$20202020,(a1)+	zet spaties in naam
	dbra	d0,default_sam_names
	st.b	no_mouse_repeat		slechts enkele klik mogelijk

	rts
;
;		***** WIS HUIDIGE SAMPLE *****
mem_sam
	yes_no
	bsr	snd_init	zet geluid uit
	st.b	pause_mode	pauseer afspelen
	move.l	#1,d4		maak er eerst lengte 1 van
	bsr	ins_sam		reserveer dat geheugen
	st.b	(a4)		en zet -1 op einde
	st.b	no_mouse_repeat	slechts enkele klik mogelijk
	rts
;
;		***** WIS HUIDIGE YM SOUND *****
mem_yms
	yes_no
	st.b	pause_mode	pauseer afspelen
clr_yms
	bsr	snd_init	zet geluid uit
	moveq	#0,d0
	move.b	ym_sound,d0	haal ym sound nummer
	move.w	d0,d1		maak back-up
	lea	ym_names,a0	adres tabel met namen
	asl.w	#3,d0		ym sound nummer * 8 = offset voor naam
	move.l	#$20202020,0(a0,d0.w)	wis naam
	move.l	#$20202020,4(a0,d0.w)	wis naam
;
	asl.w	#8,d1		ym sound nummer * 256 = offset voor sound
	lea	ym_sounds,a1	adres ym sounds
	lea	0(a1,d1.w),a1	haal adres huidige ym sound

	move.w	#i_total_len-1,d1	wis i_total_len bytes
clear_this_ym
	clr.b	0(a1,d1.w)
	dbra	d1,clear_this_ym

	move.w	#1,i_env_sustain(a1)	end sustain op 1
	move.w	#2,i_env_release(a1)	end release op 2
	move.w	#1,i_pit_sustain(a1)	end pitch sustain op 1
	move.w	#2,i_pit_release(a1)	end pitch release op 2
	move.b	#1,i_sound_mode(a1)	zet tone aan
	move.b	#8,i_env_type(a1)	hardware envelope type op 8
	move.w	#11,i_vibr_depth(a1)	vibrato depth op 11(=1(geprint)=laagst)

	st.b	no_mouse_repeat	slechts enkele klik mogelijk
	rts
;
;		***** DISK ACCESS SUBMENUS *****
;
;		***** LOAD SONG *****
load_song
	yes_no
	bsr	leave_vapos	verlaat VAP-OS
	clr.b	graf_mode	we gaan load song doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	lea	song_path,a4
	lea	song_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	st.b	pause_mode	stop geluid
	bsr	snd_init	en zet het uit

	lea	input_buf,a5
	lea	song,a6
	move.l	#'TSST',d6		merkteken song
	move.l	#pat_last-song,d7	laad maximum lengte song
	bsr	load_file		laad song

	tst.w	d0		bekijk foutcode van laad routine
	bne.s	no_name_song	<>0 = fout -> neem naam niet over

	clr.w	pos_now		zet position op nul
	clr.w	pat_lin		ga naar regel 0
	bsr	calc_pos	bereken pointers naar patterns e.d.
	lea	song_name,a0	adres song naam
	lea	song_fname,a2	plaats waar filenaam staat
	bsr	get_name	haal naam
;
no_name_song
	bsr	enter_vapos
	rts
;		***** SAVE SONG *****
save_song
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#1,graf_mode	we gaan save song doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	lea	song_name,a0	adres song naam
	lea	song_ext,a1	adres extensie YM sound
	lea	song_fname,a2	plaats waar geprepareerde naam gezet moet worden
	bsr	make_name	maak naam aan

	lea	song_path,a4
	lea	song_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	lea	input_buf,a5
	lea	song,a6
	move.l	#'TSST',d6		merkteken song
	move.l	#patterns-song,d7	save minstens alle variabelen
	move.w	last_pat,d5		haal aantal patterns
	mulu.w	#note_len*pat_len,d5	vermenigvuldig met lengte 1 pattern
	add.l	d5,d7			tel totale lengte pattersn op bij standaard lengte song
	bsr	save_file
;
	bsr	enter_vapos
	rts
;
;		***** LOAD VOICE SET *****
load_vset
	yes_no
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#2,graf_mode	we gaan load voice set doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	lea	vset_path,a4
	lea	vset_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	st.b	pause_mode	stop geluid
	bsr	snd_init	en zet het uit

	lea	input_buf,a5
	lea	voice_set,a6
	move.l	#'TSSS',d6		merkteken voice set
	move.l	#sam_last-voice_set,d7	laad maximum lengte voice set
	bsr	load_file
	bsr	calc_sam_ptrs		bereken sample pointers

	st.b	Adata+instr_no		replay routine moet data opnieuw van instrumenten halen
	st.b	Bdata+instr_no
	st.b	Cdata+instr_no
	bsr	enter_vapos
	rts
;		***** SAVE VOICE SET *****
save_vset
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#3,graf_mode	we gaan save voice set doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	lea	vset_path,a4
	lea	vset_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	lea	input_buf,a5
	lea	voice_set,a6
	move.l	#'TSSS',d6		merkteken voice set
	move.l	#sam_first-voice_set,d7	save minstens alle YM sounds en alle ander var's
	add.l	sam_tot,d7		tel daarbij op totale lengte samples
	bsr	save_file
;
	bsr	enter_vapos
	rts
;
;		***** LOAD SAMPLE *****
load_samp
	yes_no
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#6,graf_mode	sample laden
	bsr	fsel_box
	show_mouse
	lea	sam_path,a4
	lea	sam_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	clr.w	-(sp)		alleen lezen
	pea	input_buf	filenaam op stack
	move.w	#$3d,-(sp)	Fopen
	trap	#1
	addq.l	#8,sp
;
	tst.w	d0		is er een fout gebeurd?
	bmi	open_err_sam	ja -> doe niets
	move.w	d0,handle	sla handle op
;
	pea	misc_buf	laad eerst naar sample buffer
	move.l	#misc_buf_end-misc_buf,-(sp)	maximum lengte file op stack
	move.w	handle,-(sp)	handle
	move.w	#$3f,-(sp)	Fread
	trap	#1
	lea	12(sp),sp
;
	tst.l	d0		is er een fout gebeurd?
	bmi.s	load_err_sam	ja -> geef foutmelding
;
	move.l	d0,d4		reserveer zoveel ruimte als de lengte van de file+1(voor -1)
	addq.l	#1,d4		voor -1 op einde

	move.w	handle,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp
;
	st.b	pause_mode	stop geluid
	bsr	snd_init	en zet het uit
;
	bsr	ins_sam		d4 = lengte, a4 = start adres
	tst.l	d0		bekijk d0=foutcode van insert routine
	bne.s	mem_err_sam	als die negatief is -> niets doen
;
	lea	misc_buf,a0	source in a0 (target in a4)
	subq.w	#2,d4		voor dbra
conv_4b	move.b	(a0)+,d0	haal byte
	lsr.b	#4,d0		converteer naar 4 bits sample
	move.b	d0,(a4)+	sla op in sample
	dbra	d4,conv_4b
	st.b	(a4)		laatste byte op -1 zetten

	move.w	cur_sam,d0	haal nummer sample
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	sam_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige sample
	lea	sam_fname,a2	plaats waar filenaam staat
	bsr	get_name	haal naam
;	
	bsr	enter_vapos
	rts
;
mem_err_sam
	moveq	#-57,d0		eigen foutmelding : 'Memory Full'
;
load_err_sam
	move.w	d0,d6		bewaar foutnummer voor na Fclose

	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	move.w	d6,d0		haal foutnummer terug
;
open_err_sam
	bsr	print_error	print foutmelding
	bsr	enter_vapos	terug naar VAP's Operating System
	rts
;
;		***** BIJ FOUTE INVOER ITEM SELECTOR : ******
fsel_cancel
	hide_mouse
	bsr	main_graf
	show_mouse
	bsr	enter_vapos
	rts
;
;		***** LOAD YM SOUND *****
load_yms
	yes_no
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#4,graf_mode	we gaan load ym sound doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse
	lea	yms_path,a4
	lea	yms_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	st.b	pause_mode	stop geluid
	bsr	snd_init	en zet het uit

	lea	input_buf,a5
	lea	ym_sounds,a6		haal adres begin YM sounds
	move.b	ym_sound,d0		haal YM sound nummer
	andi.w	#$3f,d0			maak word van YM sound
	asl.w	#8,d0			maal 256(=lengte 1 ym sound)
	add.w	d0,a6			tel die offset op bij start adres
	move.l	#'TSSY',d6		merkteken voice set
	move.l	#256,d7			laad lengte 1 YM sound
	bsr	load_file
;
	tst.w	d0		bekijk foutcode van laad routine
	bne.s	no_name_yms	<>0 = fout -> neem naam niet over

	move.b	ym_sound,d0	haal nummer YM sound (d0 was al 0)
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	lea	yms_fname,a2	plaats waar filenaam staat
	bsr	get_name	haal naam

	st.b	Adata+instr_no		replay routine moet data opnieuw van instrumenten halen
	st.b	Bdata+instr_no
	st.b	Cdata+instr_no
;
no_name_yms
	bsr	enter_vapos
	rts
;		***** SAVE YM SOUND *****
save_yms
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#5,graf_mode	we gaan save ym sound doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	lea	yms_ext,a1	adres extensie YM sound
	lea	yms_fname,a2	plaats waar geprepareerde naam gezet moet worden
	bsr	make_name	maak naam aan

	lea	yms_path,a4
	lea	yms_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	main_graf
	bsr	fsel_box
	show_mouse

	lea	input_buf,a5
	lea	ym_sounds,a6		haal adres begin YM sounds
	move.b	ym_sound,d0		haal YM sound nummer
	andi.w	#$3f,d0			maak word van YM sound
	asl.w	#8,d0			maal 256(=lengte 1 ym sound)
	add.w	d0,a6			tel die offset op bij start adres
	move.l	#'TSSY',d6		merkteken voice set
	move.l	#i_total_len,d7			laad lengte 1 YM sound
	bsr	save_file
;
	bsr	enter_vapos
	rts
;
;
;		***** LOAD YM SOUND IN YM EDIT *****
load_yme
	yes_no
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#4,graf_mode	we gaan save ym sound doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	lea	yms_path,a4
	lea	yms_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel_yme	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	yme_graf
	bsr	fsel_box
	show_mouse

	lea	input_buf,a5
	lea	ym_sounds,a6	haal adres begin YM sounds
	move.b	ym_sound,d0	haal YM sound nummer
	andi.w	#$3f,d0		maak word van YM sound
	asl.w	#8,d0		maal 256(=lengte 1 ym sound)
	add.w	d0,a6		tel die offset op bij start adres
	move.l	#'TSSY',d6	merkteken voice set
	move.l	#i_total_len,d7		laad lengte 1 YM sound
	bsr	load_file
;
	tst.w	d0		bekijk foutcode van laad routine
	bne.s	no_name_yme	<>0 = fout -> neem naam niet over

	move.b	ym_sound,d0	haal nummer YM sound (d0 was al 0)
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	lea	yms_fname,a2	plaats waar filenaam staat
	bsr	get_name	haal naam

	st.b	Adata+instr_no	replay routine moet data opnieuw van instrumenten halen
	st.b	Bdata+instr_no
	st.b	Cdata+instr_no
;
no_name_yme	
	bsr	enter_yme
	bsr	print_yef_first	print YM edit field omdat we nieuwe sound geladen hebben
	rts
;
fsel_cancel_yme
	hide_mouse
	bsr	yme_graf
	show_mouse
	bsr	enter_yme
	rts
;
;		***** SAVE YM SOUND IN YM EDIT *****
save_yme
	bsr	leave_vapos	verlaat VAP-OS
	move.b	#5,graf_mode	we gaan save ym sound doen -> houdt daar rekening mee in de graphics
	bsr	fsel_box
	show_mouse

	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a0	adres naam huidige YM sound
	lea	yms_ext,a1	adres extensie YM sound
	lea	yms_fname,a2	plaats waar geprepareerde naam gezet moet worden
	bsr	make_name	maak naam aan

	lea	yms_path,a4
	lea	yms_fname,a5
	bsr	get_string	lees string
	tst.w	d7		is alles goed gegaan?
	beq	fsel_cancel_yme	nee -> doe niets
;
	hide_mouse
	bset.b	#4,graf_mode	we willen ook de filenaam erbij hebben
	bsr	yme_graf
	bsr	fsel_box
	show_mouse

	lea	input_buf,a5
	lea	ym_sounds,a6		haal adres begin YM sounds
	move.b	ym_sound,d0		haal YM sound nummer
	andi.w	#$3f,d0			maak word van YM sound
	asl.w	#8,d0			maal 256(=lengte 1 ym sound)
	add.w	d0,a6			tel die offset op bij start adres
	move.l	#'TSSY',d6		merkteken voice set
	move.l	#i_total_len,d7			laad lengte 1 YM sound
	bsr	save_file
;
	bsr	enter_yme
	rts
;
;		***** ALGEMENE ROUTINES VOOR DISK ACCESS SUBMENU'S : *****
;
;		***** VERLAAT VAP-OS *****
leave_vapos
	clear_key		wis toetsen van VAP-OS
	clr.b	key		ook huidige toets
	st.b	pls_mode	print Adamski e.d. niet meer
	st.b	led_mode	LED mag niet meer knipperen
	bsr	led_off		doe LED uit
	restore_pat_lin
	clr.b	pause_mode	er mag nog wel gespeeld worden

	bsr	pause_kb	keyboard meldingen uit
	move.w	#$2700,sr
	bsr	disab_int_fsel	disinstalleer eigen interrupts
	move.w	#$2300,sr
	bsr	resume_kb	keyboard meldingen weer aan

	bsr	set_mouse	zet muis op VAP-OS coordinaten
	bsr	clear_key_buf	wis toetsenbord buffer
	move.w	#0,-(sp)	toetsen goed zetten
	move.w	#11,-(sp)
	trap	#13
	addq.l	#4,sp

	rts
;
;		***** GA TERUG NAAR VAP-OS *****
enter_vapos
	clear_key		wis toetsen van VAP-OS
	clr.b	key		ook huidige toets
	bsr	clear_key_buf	wis toetsenbord buffer van TOS
	bsr	wait_led	wacht tot drive LED uitgaat
	hide_mouse		zet GEM-muis uit
	bsr	get_mouse	zet muis op GEM-coordinaten

	bsr	pause_kb	keyboard meldingen uit
	move.w	#$2700,sr
	bsr	enab_int_fsel	eigen interrupts weer aan
	move.w	#$2300,sr
	bsr	resume_kb	keyboard meldingen weer aan

	clr.b	pls_mode	Adamski e.d. weer tekenen
	clr.b	pause_mode	muziek weer aan
	clr.b	led_mode	led mag weer knipperen
	bsr	main_clr_box	teken main screen
	rts
;
;		***** GA TERUG NAAR VAP-OS EN YM EDIT *****
enter_yme
	clear_key		wis toetsen van VAP-OS
	clr.b	key		ook huidige toets
	bsr	clear_key_buf	wis toetsenbord buffer van TOS
	bsr	wait_led	wacht tot drive LED uitgaat
	hide_mouse		zet GEM-muis uit
	bsr	get_mouse	zet muis op GEM-coordinaten

	bsr	pause_kb	keyboard meldingen uit
	move.w	#$2700,sr
	bsr	enab_int_fsel	eigen interrupts weer aan
	move.w	#$2300,sr
	bsr	resume_kb	keyboard meldingen weer aan

	clr.b	pause_mode	muziek weer aan
	clr.b	led_mode	led mag weer knipperen
	bsr	yme_clr_box	print YM edit screen
	rts
;
;		***** TEKEN INFO-BOX BIJ FILE SELECTOR *****
; roep aan met BSR fsel_box
clr_ls_line	macro
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	endm
;
fsel_box
	moveq	#0,d7
	move.b	graf_mode,d7	haal nummer melding
; hier wordt een improvisorisch boxje getekend; ik wacht nog op de graphics
	move.l	phys_0,a0	haal adres scherm
	addq.l	#8,a0		naar 2de wordgroep
	moveq	#15,d0		16 regels wissen
	move.l	#$ffff0000,d5	om eerste bitpane te zetten en tweede te wissen
	moveq	#0,d6		om 2de & 3de bitplanes te wissen
clr_ls_lines
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	clr_ls_line
	add.l	#16,a0		naar volgende regel
	dbra	d0,clr_ls_lines
;
	bclr	#4,d7		moet de filenaam ook neergezet worden?
	beq.s	no_file_name
	move.w	#2,charx
	move.w	#8,chary
	lea	input_buf,a2	adres van filenaam
	bsr	print_ascii	print filenaam
no_file_name
	move.w	#2,charx
	move.w	#0,chary
	asl.w	#2,d7		het zijn longs!!!
	lea	file_mess,a2	
	move.l	0(a2,d7.w),a2	adres van meldingen
	bsr	print_ascii	print melding

	rts
;
;		***** WIS TOETSENBORD-BUFFER *****
; gebruik BSR clear_key_buf
clear_next_buf
	move.w	#2,-(sp)	CON:
	move.w	#2,-(sp)	Bconin
	trap	#13		Bios
	addq.l	#4,sp
;
clear_key_buf
	move.w	#2,-(sp)	CON:
	move.w	#1,-(sp)	Bconstat
	trap	#13		Bios
	addq.l	#4,sp

	tst.w	d0		zit er nog een toets in de buffer?
	bne.s	clear_next_buf	ja -> wis dat teken

	rts
;
;		***** INSERT SAMPLE *****
; d4.l = nieuwe lengte
; gebruikt : d0-d2/d4/a0-a4
ins_sam	lea	sam_tab,a2	adres tabel met startadressen
	lea	sam_len,a3	adres tabel met lengtes
	move.w	cur_sam,d2	nummer huidige sample
	move.w	d2,d1		back-up voor later
	asl.w	#2,d2		*4 voor long tabel

	move.l	sam_tot,d0	haal totale lengte
	sub.l	0(a3,d2.w),d0	haal daar lengte huidige sample vanaf
	add.l	d4,d0		en tel er nieuwe lengte bij op
	cmp.l	#sam_last-sam_first,d0	zitten we over de maximum grens?
	bhi.s	ins_err		ja -> insert error

	move.l	4(a2,d2.w),a0	source adres copy=start adres volgende sample
	move.l	0(a2,d2.w),a1	haal start adres huidige sample
	move.l	a1,a4		aan oproeper terug te geven start adres sample
	add.l	d4,a1		target=start huidige sample+nieuwe lengte

	move.l	d4,0(a3,d2.w)	zet lengte op nieuwe lengte

	cmpi.w	#$f,d1		als sam#=15 -> niets kopieren
	beq.s	leave_sam

	moveq	#15,d1		aantal samples om lengte van te berekenen
	moveq	#0,d0		lengte is eerst 0
calc_len
	add.l	4(a3,d2.w),d0	verhoog lengte met sample lengte (de 4 staat er omdat we de lengtes van de VOLGENDE samples willen weten)
	addq.w	#4,d2		naar volgende sample
	dbra	d1,calc_len
;
; lengte zit nu d0, source in a0, target in a1
	bsr	copy_mem	voer copieer opdracht uit
	bsr	calc_sam_ptrs	bereken sample pointers
leave_sam
	moveq	#0,d0		foutcode=0, OK
	rts

ins_err	moveq	#-1,d0		foutcode=-1, ERROR
	rts
;
;		***** COPY MEMORY RANGE *****
; a0.l = source address
; a1.l = target address
; d0.l = length
; gebruikt : d0/a0-a1
copy_mem
	tst.l	d0		is lengte 0?
	beq.s	no_copy_mem	ja -> kopieer niks
	cmp.l	a0,a1		vergelijk target en source met elkaar
	bhi.s	downcop		als target >  source -> copieer van boven naar beneden
		;		--- target <= source -> copieer van beneden naar boven

uc_loop	move.b	(a0)+,(a1)+	verplaats byte
	subq.l	#1,d0		verlaag lengte nog te gaan
	bne.s	uc_loop		lengte>0 -> ga door
	rts

downcop	add.l	d0,a0		source adres naar einde
	add.l	d0,a1		target adres ook naar einde
dc_loop	move.b	-(a0),-(a1)	verplaats byte
	subq.l	#1,d0		verlaag teller
	bne.s	dc_loop
no_copy_mem
	rts
;
;		***** CALCULATE SAMPLE POINTERS *****
; gebruikt : d0-d1/a0-a2
calc_sam_ptrs
	lea	sam_tab,a0	haal adres tabel met pointers
	lea	sam_len,a1	haal adres tabel met lengtes
	lea	sam_first,a2	haal begin adres eerste sample
	moveq	#15,d0		pointers van 16 samples berekenen
	moveq	#0,d1		lengte alle samples samen is eerst 0

calc_next_sam
	move.l	a2,(a0)+	sla pointer naar sample op
	add.l	(a1),a2		verhoog pointer met lengte sample
	add.l	(a1)+,d1	verhoog totale lengte met lengte sample
	dbra	d0,calc_next_sam

	move.l	d1,sam_tot	sla totale lengte samples op
	rts
;
;		***** ALGEMENE LAAD ROUTINE *****
;	a5.l = pointer naar filename
;	a6.l = laad adres
;	d6.l = merkteken file (bv. 'TSST')
;	d7.l = lengte file
;
load_file
	clr.w	-(sp)		alleen lezen
	move.l	a5,-(sp)	filenaam op stack
	move.w	#$3d,-(sp)	Fopen
	trap	#1
	addq.l	#8,sp
;
	tst.w	d0		is er een fout gebeurd?
	bmi.s	open_error	ja -> doe niets
	move.w	d0,d5		sla handle op
;
	pea	signtest	buffer waar teken bekeken wordt
	move.l	#4,-(sp)	teken is 4 tekens lang
	move.w	d5,-(sp)	handle
	move.w	#$3f,-(sp)	Fread
	trap	#1
	lea	12(sp),sp
;
	tst.l	d0		fout gebeurd?
	bmi.s	load_error	ja -> geef foutmelding
;
	cmp.l	signtest,d6	klopt teken?
	bne.s	wrong_sign	ja -> laad rest
;	
	move.l	a6,-(sp)	laad hiernaartoe
	move.l	d7,-(sp)	lengte file
	move.w	d5,-(sp)	handle
	move.w	#$3f,-(sp)	Fread
	trap	#1
	lea	12(sp),sp
;
	tst.l	d0		fout gebeurd?
	bmi.s	load_error	ja -> geef foutmelding
;
	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	moveq	#0,d0		ten teken dat alles goed ging
	rts
;		***** ERROR AFHANDELING LOAD ROUTINE *****
wrong_sign
	moveq	#-58,d0		eigen foutmelding : 'Wrong File Format'
;
load_error
	move.w	d0,d6		bewaar foutnummer voor na Fclose

	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	move.w	d6,d0		haal foutnummer terug
;
open_error
	bsr	print_error	print foutmelding
	moveq	#-1,d0		ten teken dat er iets fout ging
	rts
;
;
;
;		***** ALGEMENE SAVE ROUTINE *****
;	a5.l = pointer naar filename
;	a6.l = save adres
;	d6.l = merkteken file (bv. 'TSST')
;	d7.l = lengte file
;
save_file
	clr.w	-(sp)		normale file
	move.l	a5,-(sp)	filenaam op stack
	move.w	#$3c,-(sp)	Fcreate
	trap	#1
	addq.l	#8,sp
;
	tst.w	d0		is er een fout gebeurd?
	bmi.s	open_error	ja -> doe niets
	move.w	d0,d5		sla handle op
;
	move.l	d6,signtest	zet merkteken weg
	pea	signtest	schrijf teken naar schijf
	move.l	#4,-(sp)	merkteken is ook 4 bytes lang
	move.w	d5,-(sp)	handle
	move.w	#$40,-(sp)	Fwrite
	trap	#1
	lea	12(sp),sp
;
	tst.l	d0		fout gebeurd?
	bmi.s	save_error

	cmp.l	#4,d0		zijn er ook werkelijk 4 bytes geschreven?
	bne.s	full_error	nee -> foutmelding
;
	move.l	a6,-(sp)	save van hier
	move.l	d7,-(sp)	lengte file
	move.w	d5,-(sp)	handle
	move.w	#$40,-(sp)	Fwrite
	trap	#1
	lea	12(sp),sp
;
	tst.l	d0		fout gebeurd?
	bmi.s	save_error

	cmp.l	d7,d0		zijn alle bytes geschreven?
	bne.s	full_error
;
	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	moveq	#0,d0		ten teken dat alles goed ging
	rts
;		***** ERROR AFHANDELING SAVE ROUTINE *****
full_error
	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	pea	(a5)		zet filenaam op stack
	move.w	#$41,-(sp)	wis file die niet volledig op disk gezet is
	trap	#1
	addq.l	#6,sp

	moveq	#-59,d0		eigen foutmelding : Disk Full
	bsr	print_error

	moveq	#-1,d0		ten teken dat er iets fout ging
	rts
;	
save_error
	move.w	d0,d6		bewaar foutnummer tot na Fclose

	move.w	d5,-(sp)	handle
	move.w	#$3e,-(sp)	Fclose
	trap	#1
	addq.l	#4,sp

	move.w	d6,d0		haal foutnummer terug
	bsr	print_error	print foutmelding

	moveq	#-1,d0		ten teken dat er iets fout ging
	rts
;
;		***** PRINT ERROR MESSAGE *****
; d0.w = error nummer
print_error
	tst.w	d0		bekijk error#
	bpl.s	no_error	error#=>0 -> geen fout
	cmp.w	#-67,d0		error#<-67 ?
	ble.s	no_error	ja -> geen fout

	move.w	#$700,col0	maak scherm rood

	neg.w	d0			maak positief nummer van error
	asl.w	#2,d0
	lea	error_messages,a0	tabel fout-meldingen
	move.l	0(a0,d0.w),-(sp)	zet adres foutmelding op stack

	hide_mouse
	bsr	main_graf
	move.b	#7,graf_mode	print 'an error ocurred'
	bsr	fsel_box
	show_mouse

	move.l	(sp)+,a2	haal adres foutmelding terug
	move.w	#2,charx
	move.w	#8,chary
	bsr	print_ascii	print foutmelding

	bsr	clear_key_buf	wis toetsenbord buffer

	waitkey			wacht op toets
	clr.w	col0		schermkleur weer goed
no_error
	rts
;
;		***** ZET GEM MUIS OP VAP-OS COORDINATEN *****
set_mouse
	dc.w	$a000			lineA init
	move.w	mousex,-$25a(a0)	zet x-pos
	move.w	mousey,-$258(a0)	zet y-pos
	rts
;
;		***** ZET VAP-OS MUIS OP GEM COORDINATEN *****
get_mouse
	IFNE	executable
	dc.w	$a000			lineA init
	move.w	-$25a(a0),mousex	zet x-pos
	move.w	-$258(a0),mousey	zet y-pos
	ENDC
	rts
;
;		***** WACHT TOT DRIVE LED UITGAAT *****
wait_led
	vsync				wacht tot TOS drive led's herziet
	move.b	#14,psgreg		selecteer PSG register 14 : poort A I/O
	move.b	psgreg,d0		lees PSG register 14
	andi.b	#%110,d0		maskeer drive A&B select bits
	cmpi.b	#%110,d0		zijn drive A&B allebei gedeselecteerd
	bne.s	wait_led		nee -> blijf wachten tot dat wel zo is
	rts
;
;		***** ZET DRIVE-LED UIT *****
led_off
	move.w	#$2700,sr	ignore MFP interrupts
	move.b	#14,psgreg	poort A
	move.b	psgreg,d0	lees data
	bset	#1,d0		LED drive A uit
	move.b	d0,psgwrite	schrijf nieuwe waarde weg
	move.w	#$2500,sr	do not ignore MFP interrupts
	rts
;
;
;		***** MAAK DEFAULT NAAM *****
;
; a0.l = pointer naar 8-byte lange naam in ASCII
; a1.l = pointer naar extensie (bv. '.YMS')
; a2.l = pointer naar waar naam gezet moet worden
make_name
	moveq	#7,d0		begin bij einde string
search_space
	cmpi.b	#32,0(a0,d0.w)	staat hier NIET een spatie
	bne.s	found_length	ja -> lengte gevonden
	dbra	d0,search_space	positie terug en nog een keer kijken
; naam bestaat uit enkel spaties :
	move.l	#'NONA',(a2)+	naam wordt NONAME.xxx
	move.w	#'ME',(a2)+
	bra.s	add_extension

found_length
	move.b	(a0)+,d1	haal character
	cmpi.b	#32,d1		is het spatie?
	bne.s	no_conv_underline
	move.b	#'_',d1		maak van die spatie een underline
no_conv_underline
	move.b	d1,(a2)+	sla wel of niet bewerkte character op
	dbra	d0,found_length	volgende letter

add_extension
	move.b	(a1)+,(a2)+	voeg extensie toe aan naam
	bne.s	add_extension

	rts
;
;		***** HAAL FILENAAM *****
;
; a0.l = pointer waar 8-byte lange ASCII string gezet moet worden
; a2.l = pointer waar filenaam staat
get_name
	move.l	#$20202020,(a0)		vul naam met spaties
	move.l	#$20202020,4(a0)
copy_name
	move.b	(a2)+,d0		haal character
	beq.s	end_file_name		=0 -> einde string
	cmpi.b	#'.',d0			of is het een punt
	beq.s	end_file_name		ja -> einde string
	move.b	d0,(a0)+		zet character in string
	bra.s	copy_name
end_file_name
	rts	
;
;		***** LEES STRING *****
; a4 = pointer naar padnaam
; a5 = pointer naar filenaam
; Na aanroep :
; d0 = 1 als OK, 0 als Cancel
; input_buf = volledige filenaam
;
get_string
	jsr	gem_init	zet GEM aan
	jsr	select		doe item selector
	jsr	gem_exit	GEM weer uit
	rts
;
; subroutines aes

aes:      move.l    #aespb,d1        ;AES-parameterblok
          move.w    #$c8,d0          ;code voor AES
          trap      #2               ;GEM aanroepen
          rts       

;-----------------------------
; Aanmelden bij AES (appl_init):

gem_init: move.w    #10,control      ;appl_init (AES)
          clr.w     control+2
          move.w    #1,control+4
          clr.w     control+6
          clr.w     control+8
          jsr       aes
          move.w    int_out,ap_id    ;Identificatie-no bewaren

          rts       
;Aanroepen voor verlaten van programma
gem_exit:

          move.w    #19,control      ;appl_exit (AES)
          clr.w     control+2
          move.w    #1,control+4
          clr.w     control+6
          clr.w     control+8
          jsr       aes
          rts       

; ----------------------------------
;
; Deze routine toont een file-selctor.
; a4 = pointer naar standaard pad
; a5 = pointer naar default filenaam
;
; Erna in d7:		 0 -> op Cancel geklikt of fout
;                        1 -> alles OK
; aanroep van GEM-file-selector:
select	move.w	#90,control	opcode
	clr.w	control+2
	move.w	#2,control+4
          move.w    #2,control+6
          clr.w     control+8
          move.l    a4,addr_in		padnaam
          move.l    a5,addr_in+4	default-bestandsnaam

          jsr       aes
          
          tst.w     int_out+2	op Cancel geklikt i.p.v. OK?
          beq.s     fsel_err	Cancel -> fout
          tst.b     (a5)	bestandsnaam gekozen?
          beq.s     fsel_err	nee -> fout
; nu moeten de pad- en bestandsnaam worden omgezet
; in een gecombineerde pad- en bestandsnaam:
	lea	input_buf,a3	zet hier gecombineerde naam
fsel_l3	move.b	(a4)+,(a3)+	kopieer path en zoek einde van padnaam
	bne.s     fsel_l3

fsel_l4	cmpi.b    #'\',-(a3)	backslash zoeken
	bne.s     fsel_l4

	addq.l    #1,a3		backslash laten staan

fsel_l5	move.b	(a5)+,(a3)+	bestandsnaam kopieren
	bne.s	fsel_l5

	moveq	#1,d7		functiewaarde: alles OK
	rts       
;
fsel_err
	moveq	#0,d7		er is op Cancel geklikt of er was geen padnaam ingevoerd
	rts
;
; 		***** MAAK PADEN AAN *****
; paden aanmaken voor verschillende file types :
make_paths
	lea	song_path,a2	begin met maken song-path
; actieve drive bepalen:
	move.w	#dgetdrv,-(sp)	
	trap	#gemdos
	addq.l	#2,sp
	addi.b	#'A',d0		functieresultaat -> letter
	move.b	d0,(a2)
	move.b	#':',1(a2)	dubbele punt toevoegen
; pad van actieve drive bepalen:
	clr.w	-(sp)		actieve drive
	pea	2(a2)
	move.w	#dgetpath,-(sp)
	trap	#gemdos
	addq.l	#8,sp

; pad kopieren en einde zoeken:
	lea	vset_path,a3	pad van voice set
	lea	yms_path,a4	pad van YM sounds
	lea	sam_path,a5	pad van samples

	clr.w	d1		stringlengte bepalen
fsel_search_end
	move.b	0(a2,d1.w),d0	haal character
	beq.s	fsel_song_mask	nullbyte? -> einde bereikt
	move.b	d0,0(a3,d1.w)	sla hem op in voice set path en andere paden
	move.b	d0,0(a4,d1.w)	YM sound
	move.b	d0,0(a5,d1.w)	sample
	addq.w	#1,d1
	bra.s	fsel_search_end
; maskers toevoegen :
; song masker
fsel_song_mask
	move.w	d1,d3		maak back-up van lengte voor volgende masker
	move.b	#'\',0(a2,d1.w)
	lea	song_mask,a0	pointer op masker
fsel_song_mask_lp
	move.b	(a0)+,1(a2,d1.w)
	beq.s	fsel_vset_mask
	addq.w	#1,d1
	bra.s	fsel_song_mask_lp
; voice set masker
fsel_vset_mask
	move.w	d3,d1		haal lengte weer terug
	move.b	#'\',0(a3,d1.w)
	lea	vset_mask,a0	pointer op masker
fsel_vset_mask_lp
	move.b	(a0)+,1(a3,d1.w)
	beq.s	fsel_yms_mask
	addq.w	#1,d1
	bra.s	fsel_vset_mask_lp
; YM sound masker
fsel_yms_mask
	move.w	d3,d1		haal lengte weer terug
	move.b	#'\',0(a4,d1.w)
	lea	yms_mask,a0	pointer op masker
fsel_yms_mask_lp
	move.b	(a0)+,1(a4,d1.w)
	beq.s	fsel_sam_mask
	addq.w	#1,d1
	bra.s	fsel_yms_mask_lp
; sample masker
fsel_sam_mask
	move.w	d3,d1		haal lengte weer terug
	move.b	#'\',0(a5,d1.w)
	lea	sam_mask,a0	pointer op masker
fsel_sam_mask_lp
	move.b	(a0)+,1(a5,d1.w)
	beq.s	fsel_end_mask
	addq.w	#1,d1
	bra.s	fsel_sam_mask_lp
fsel_end_mask

	rts
;
;		***** LAAD NIEUWE POSITION *****
load_pos
	clr.w	pat_lin			zet regelnummer op 0
load_pos_without_0
	move.w	pos_now,d0		haal position
	move.w	patmode,d1		haal rec/play mode
	btst	#0,d1			doen we SONG play of rec?
	bne.s	next_pos		ja -> naar volgende position
;
	bra.s	no_restart		haal begin adres position
;
next_pos
	addq.w	#1,d0			naar volgende position
	cmp.w	last_pos,d0		zijn we voorbij de laatste position
	bls.s	no_restart		nee -> niet restarten
	
	move.w	restart,d0		haal restart position
no_restart
	move.w	d0,pos_now		sla position op
calc_pos
	lea	pos_tab,a0		haal adres position tabel
	move.w	pos_now,d0		haal position nummer
	move.b	0(a0,d0.w),d0		haal huidige pattern nummer (voor als we net aankomen met calc_pos)
	andi.w	#$7f,d0			maak er een word van
	move.w	d0,pat_now		sla op
	lea	pat_tab,a0		haal tabel met patterns
	asl.w	#2,d0			vermenigvuldig met 4 voor tabel met longs
	move.l	0(a0,d0.w),pat_base	haal pointer naar pattern

	rts
;
;		***** PRINT ADAMSKI *****
print_adamski
	move.l	phys_0,a0	haal schermadres
	add.l	#ll*54+8+2,a0	naar regel 54 en kolom 16, 2de bitplane
	move.l	a0,a1		sla op voor later (een zogeheten appeltje voor de dorst)
	move.w	#16-1,d0	Adamski is 32 hoog, maar om de 2 regels wordt er iets neergezet
;
clear_adamski
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
;
	add.l	#ll*2,a0	naar volgende regel
	dbra	d0,clear_adamski
;
;		***** TEKEN PUNTEN *****
	move.l	s_start,a0	haal pointer naar sample
	btst.b	#1,Adata+silent	wordt er een sample gespeeld?
	bne.s	yes_sam_adam	ja -> teken niet gewoon lijn
	lea	adam_line,a0	teken lijn in Adamski
yes_sam_adam
	move.w	#5-1,d0		zoveel kolomen horizontaal tekenen
;
adam_pnt
	moveq	#7,d2		bit is helemaal links EN tegelijk voor dbra
adam_pnt_l
	move.b	(a0)+,d1	haal byte uit sample
	bpl.s	no_adam_lin_l	als byte niet -1 is -> geen lijn tekenen
	lea	adam_line,a0	teken lijn in Adamski
	move.b	(a0)+,d1	haal byte uit rechte lijn
no_adam_lin_l
	andi.w	#$f,d1		maskeer alle overtollige bits
	mulu.w	#ll*2,d1	vermenigvuldig met 2*regellengte
	bset.b	d2,0(a1,d1.w)	zet bit in scherm
	dbra	d2,adam_pnt_l
	addq.l	#1,a1		naar volgende byte op scherm

	moveq	#7,d2		bit is helemaal links EN tegelijk voor dbra
adam_pnt_h
	move.b	(a0)+,d1	haal byte uit sample
	bpl.s	no_adam_lin_h	als byte niet -1 is -> geen lijn tekenen
	lea	adam_line,a0	teken lijn in Adamski
	move.b	(a0)+,d1	haal byte uit rechte lijn
no_adam_lin_h
	andi.w	#$f,d1		maskeer alle overtollige bits
	mulu.w	#ll*2,d1	vermenigvuldig met 2*regellengte
	bset.b	d2,0(a1,d1.w)	zet bit in scherm
	dbra	d2,adam_pnt_h
	addq.l	#7,a1		naar volgende byte op scherm

	dbra	d0,adam_pnt	volgende kolom tekenen
;
	rts	
;
;		***** PRINT SPECO *****
print_speco
	move.l	phys_0,a1	adres tweede bitplane
	add.l	#ll*17+8+2,a1	naar goede positie op beeld, 2de bitplane
;
	move.b	Adata+PSGvol,d2	haal volume kanaal A
	move.l	a1,a0		plaats Speco kanaal A
	bsr	print_1_speco
;
	move.b	Bdata+PSGvol,d2	haal volume kanaal B
	lea	16(a1),a0	plaats Speco kanaal B
	bsr	print_1_speco
;
	move.b	Cdata+PSGvol,d2	haal volume kanaal B
	lea	32(a1),a0	plaats Speco kanaal B
	bsr	print_1_speco
;
	rts
;
print_1_speco
	move.w	#15,d0		speco is 16 hoog
	moveq	#0,d1		eerst lijntjes wissen
	subi.b	#1,d2		verlaag met 1 om vergelijken makkelijker te maken
prt_spec_lin
	cmp.b	d2,d0		zijn we op regel waar volume moet beginnen?
	bne.s	no_vol_here
	move.w	#$ffff,d1	ja -> zet lijntjes vanaf hier
no_vol_here
	move.w	d1,(a0)		wis of teken regel
	move.w	d1,2(a0)	ook in 3de bitplane
	add.l	#ll*2,a0	naar volgende regel op beeld
	dbra	d0,prt_spec_lin
	rts
;	
;
;
;		***** PRINT PATTERN REGELS IN VBL *****
print_pls
	move.w	charx,-(sp)	maak backup van x pos en y pos
	move.w	chary,-(sp)
	move.w	#37,charx	x pos
	move.w	#62,chary	y pos
	move.w	pos_now,d0	huidige position
	bsr	printbyte

	move.w	pat_now,d0	huidige pattern
	move.w	#72,chary
	bsr	printbyte

	move.w	#139,chary	y positie van regel
	move.w	pat_lin,d7	haal regel#
	subq.w	#3,d7		drie regels terug
	move.l	pat_base,a5	haal pointer naar BEGIN pattern
	moveq	#6,d6		7 regels printen

print_pat_lins
	move.w	#1,charx	x positie van regel
	move.w	d7,d1		pattern offset voor berekening
	move.l	a5,a4		adres BEGIN pattern voor berekening
	andi.w	#$3f,d1		maskeer onderste 6 bits want positie kan niet hoger zijn dan $3f
	move.w	d1,d0		voor printen regel nummer
	mulu.w	#note_len,d1	vermenigvuldig met lengte 1 noot
	adda.w	d1,a4		tel op bij begin adres pattern
	
;		***** PRINT 1 REGEL *****
	bsr	printbyte	print byte
	addq.w	#3,charx	verschuif cursor
	bsr	print_chan	print kanaal A
	addq.w	#2,charx	verschuif cursor
	bsr	print_chan	print kanaal B
	addq.w	#2,charx	verschuif cursor
	bsr	print_chan	print kanaal C

	addq.w	#1,d7		verhoog regel nummer
	addq.w	#8,chary	naar volgende regel
	dbra	d6,print_pat_lins

	move.w	(sp)+,chary	zet backups van x pos en y pos terug
	move.w	(sp)+,charx
	rts
;		***** PRINT YM NOOT *****
print_chan
	moveq	#0,d5		zodat we d5 als word kunnen behandelen
	move.b	(a4)+,d5	haal octaaf/noot
	bmi.s	print_sam	als deze noot een sample is -> print 'SAM'
	move.w	d5,d0		pak noot
	lea	note_2_char,a0	van noot naar letter omzet tabel
	andi.w	#$f,d0		maskeer noot
	asl.w	#1,d0		maal 2 voor offset in word tabel
	move.w	0(a0,d0.w),d4	haal twee letters voor noot

	move.w	d4,d0		haal bovenste/linker letter
	lsr.w	#8,d0		zet hem in de onderste byte
	bsr	printchar	print letter
	addq.w	#1,charx	verschuif cursor

	move.w	d4,d0		haal onderste/rechter letter
	bsr	printchar	print letter
	addq.w	#1,charx	verschuif cursor

	move.b	d5,d0		pak OCTAAF weer
	lsr.b	#4,d0		verschuif octaaf naar onderste bits
	bsr	printchar	print als nibble
	addq.w	#1,charx	schuif cursor op
	bra.s	print_ym	sla 'SAM' printen over
;
print_sam
	lea	sam_ch1,a2	adres 'SAM' string
	bsr	print_string	print string
;
print_ym	
	move.b	(a4)+,d0	haal TIE
	bsr	printbyte	print byte
	addq.w	#2,charx	schuif cursor op
;
	move.b	(a4)+,d0	haal INSTRUMENT#
	bsr	printbyte	print byte
	addq.w	#2,charx	schuif cursor op
;
	move.b	(a4)+,d5	haal envelope/volume
	move.b	d5,d0		pak VOLUME
	andi.b	#$f,d0		isoleer volume bits
	bsr	printchar	print volume
	addq.w	#1,charx	schuif cursor op

	move.b	d5,d0		haal ENVELOPE value
	lsr.b	#6,d0		isoleer envelope value
	bsr	print_envelope	print als nibble

	rts			1 kanaal, 1 noot getekend
;
;		***** PRINT MAIN SCREEN BUTTONS *****
prbut_main
	move.w	#37,charx	x pos voor alle waarden

	move.w	cur_sam,d0	haal huidige sample#
	lea	sam_rates,a0	sample rates
	move.b	0(a0,d0.w),d0	sample rate
	move.w	#12,chary	y positie
	bsr	printbyte

	move.w	cur_sam,d0	sample #
	move.w	#22,chary
	bsr	printbyte

	move.b	ym_sound,d0	YM sound
	move.w	#32,chary
	bsr	printbyte

	move.w	#42,chary
	move.b	ym_vol,d0	YM volume
	bsr	printbyte

	move.w	#52,chary
	move.b	ym_tie,d0	YM tie
	bsr	printbyte

	move.w	#82,chary
	move.w	last_pos,d0	aantal positions
	bsr	printbyte

	move.w	#92,chary
	move.w	restart,d0	restart
	bsr	printbyte

	move.w	#102,chary
	moveq	#$10,d0		draai speed om (1 wordt $f, $10 wordt 0)
	sub.w	speed,d0	afspeel snelheid
	bsr	printbyte

	move.w	#112,chary
	move.w	s_step,d0	haal stop step
	bsr	printbyte

	move.w	#122,chary
	move.b	octave,d0	octave
	bsr	printbyte
;
	move.w	#122,chary
	move.w	#7,charx	record mode
	tst.b	rec_mode	bekijk record mode kanaal A
	bne.s	rec_mode_1
	lea	sam_ch1,a2	adres 'SAM' string
	bra.s	rec_mode_0
rec_mode_1
	lea	yms_ch1,a2	adres 'YMS' string
rec_mode_0
	bsr	print_string
;
	move.w	#19,charx
	move.b	key_mode,d0	haal key mode
	beq.s	key_mode_0
	cmpi.b	#1,d0		is key mode dan 1
	beq.s	key_mode_1
	lea	sus_yms,a2	SUSTAIN (2)
	bra.s	key_mode_2
key_mode_0
	lea	rel_yms,a2	RELEASE (0)
	bra.s	key_mode_2
key_mode_1
	lea	att_yms,a2	ATTACK	(1)
key_mode_2
	bsr	print_string
;		***** PRINT MUTES *****
	move.w	#110,chary
	move.w	#21,charx
	move.b	Adata+silent,d0	haal silent byte
	bsr	print_mute

	move.b	Bdata+silent,d0
	addq.w	#1,charx
	bsr	print_mute

	move.b	Cdata+silent,d0
	addq.w	#1,charx
	bsr	print_mute
;
;		***** PRINT NAMEN *****
	move.w	#17,charx	
	move.w	#12,chary
	lea	song_name,a2	adres song naam
	bsr	print_asc8	print ASCII string van 8 tekens

	move.w	#17,charx	
	move.w	#22,chary
	move.w	cur_sam,d0	haal sample nummer
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	sam_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a2	adres naam huidige sample
	bsr	print_asc8	print ASCII string van 8 tekens

	move.w	#17,charx	
	move.w	#32,chary
	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a2	adres naam huidige YM sound
	bsr	print_asc8	print ASCII string van 8 tekens

	tst.b	asc_mode	wordt er iets ingevoerd?
	beq.s	no_main_input	nee -> print geen cursor

	bsr	print_inv_cur	print geinverteerde cursor
no_main_input
;		***** PRINT MEMORY *****
	cmpi.b	#2,menu_mode		zitten we in memtory menu?
	bne	no_memo_menu
;
	move.w	#22,chary
	move.w	#5,charx

	move.w	last_pat,d5		haal aantal patterns
	mulu.w	#pat_len*note_len,d5	maal lengte 1 pattern
	add.l	#patterns-song,d5	tel daarbij op variabelen aan begin song
	move.l	sam_tot,d6		haal totale lengte alle samples
;
	move.l	d5,d0			ALL = lengte song
	add.l	d6,d0			+     lengte samples
	add.l	#sam_first-voice_set,d0	+     lengte YM sounds en variabelen
	bsr	print_long		print lengte
;
	move.w	#32,chary
	move.l	d5,d0			SNG = lengte song
	bsr	print_long
;
	move.w	#42,chary
	move.l	d6,d0			VST = lengte samples
	add.l	#sam_first-voice_set,d0	+     lengte YM sounds en variabelen
	bsr	print_long	
;
	move.w	#52,chary
	move.l	d5,d0			SPLS = lengte samples
	bsr	print_long
;
	move.w	#62,chary
	lea	sam_len,a0	adres tabel met lengtes
	move.w	cur_sam,d0	nummer huidige sample
	asl.w	#2,d0		*4 voor long tabel
	move.l	0(a0,d0.w),d0	haal lengte huidige sample
	bsr	print_long
;
	move.w	#72,chary
	move.l	#i_total_len,d0		lengte YMS is altijd i_total_len
	bsr	print_long
;
	move.w	#82,chary
	move.l	#(sam_last-voice_set)+(pat_last-song),d0
;						FREE = maximum lengte
	sub.l	d5,d0				-     lengte song
	sub.l	d6,d0				-     lengte samples
	sub.l	#sam_first-voice_set,d0		- standaard lengte voice set
	bsr	print_long
;
no_memo_menu
	rts
;
;
;		***** PRINT MUTE ON/OFF *****
print_mute
	btst	#2,d0		is dit kanaal gemute of niet?
	bne.s	p_mute_off	bit=0 -> kanaal  = OFF

	lea	mute_on,a2	string aan
	bsr	print_string
	rts
p_mute_off
	lea	mute_off,a2	string uit
	bsr	print_string
	rts
;
;		***** PRINT CURSOR *****
print_cursor
	move.l	phys_0,a0	haal adres 2de bitplane scherm
	add.l	#ll*163+16+2,a0	naar regel 163 en 4de letter, 2de bitplane
	move.l	a0,a1		maak back-up voor later
	move.w	#$ffff,d0	om cursors te wissen
	moveq	#6,d1		we willen 7 regels wissen
;
clear_cursor
	move.w	d0,(a0)		wis cursor posities van kanaal A
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.b	d0,32(a0)
;
	move.w	d0,40(a0)	wis cursor posities van kanaal B
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.b	d0,72(a0)
;
	move.w	d0,80(a0)	wis cursor posities van kanaal C
	move.w	d0,88(a0)
	move.w	d0,96(a0)
	move.w	d0,104(a0)
	move.b	d0,112(a0)
;
	add.l	#ll,a0		naar volgende scherm regel
	dbra	d1,clear_cursor	en wis volgende regel
;
	lea	cursor_offs,a0	haal adres offsets voor cursor
	move.w	cursor,d0	haal cursor positie(*4)
	add.l	0(a0,d0.w),a1	tel offset bij schermadres op
;
	clr.b	(a1)		zet eerste regel van cursor neer
	clr.b	ll(a1)		en tweede regel
	clr.b	ll*2(a1)
	clr.b	ll*3(a1)
	clr.b	ll*4(a1)
	clr.b	ll*5(a1)
	clr.b	ll*6(a1)
;
	rts
;	
;		***** PRINT YM EDIT FIELD *****
prbut_yme
;		***** ZET NIEUWE WAARDEN IN GELUID VARIABELEN *****
;
	move.b	ym_sound,d0		haal YM sound nummer
	lea	ym_sounds,a2		haal adres begin YM sounds
	andi.w	#$3f,d0			maak word van YM sound
	asl.w	#8,d0			maal 256(=lengte 1 ym sound)
	add.w	d0,a2			tel die offset op bij start adres
	move.l	a2,ym_ptr		sla die pointer op
;
	st.b	Bdata+instr_no		zorg dat nieuwe data in Voice status structure geladen wordt
	move.b	key,key_raw		door nieuw instrument en nieuwe noot
;
; 
;
;		***** PRINT YM EDIT BUTTONS *****
pbut_yme
	move.w	#88,chary	y pos
	move.w	#23,charx	x pos positie in YEF
	move.w	yef_pos,d0	positie in YEF
	bsr	printbyte

	move.w	#9,charx
	tst.b	yef_mode	editen we pitch of amplitude?
	bne.s	edit_pitch
;		***** BIJ AMPLITUDE EDIT ****
	lea	amp_str,a2	AMP
	bsr	print_string

	move.l	ym_ptr,a2	pointer naar ym sound
	move.w	#16,charx
	move.w	#101,chary
	move.w	i_env_attack(a2),d0	haal einde attack
	bsr	printbyte

	move.w	#111,chary
	move.w	i_env_sustain(a2),d0	haal einde sustain
	bsr	printbyte

	move.w	#121,chary
	move.w	i_env_release(a2),d0	haal einde release
	bsr	printbyte
	bra.s	edit_amp
;		***** BIJ PITCH EDIT *****
edit_pitch
	lea	pitch_str,a2	FRQ
	bsr	print_string

	move.l	ym_ptr,a2		pointer naar ym sound
	move.w	#16,charx
	move.w	#101,chary
	move.w	i_pit_attack(a2),d0	haal einde attack
	bsr	printbyte

	move.w	#111,chary
	move.w	i_pit_sustain(a2),d0	haal einde sustain
	bsr	printbyte

	move.w	#121,chary
	move.w	i_pit_release(a2),d0	haal einde release
	bsr	printbyte
;	******
edit_amp
	move.w	#31,charx	x pos
	move.w	#111,chary
	move.b	ym_sound,d0	YM sound
	bsr	printbyte

	move.w	#121,chary
	move.b	ym_vol,d0	YM volume
	bsr	printbyte

	move.w	#131,chary
	move.b	octave,d0	oktaaf
	bsr	printbyte

	move.w	#141,chary
	move.b	ym_tie,d0	YM tie
	bsr	printbyte
;
	move.w	#16,charx
	move.w	#131,chary
	btst.b	#3,i_sound_mode(a2)	staat hardware automatic aan?
	bne.s	yes_hardw_auto

	move.w	i_env_freq(a2),d0	haal h_env freq
	bsr	print_word
	bra.s	no_hardw_auto
yes_hardw_auto
	move.l	a2,a3			sla pointer naar sound op
	lea	mode_auto,a2		adres string 'AUTO'
	bsr	print_string
	move.w	#16,charx
	move.l	a3,a2
no_hardw_auto
;
	move.w	#151,chary
	move.w	(a2),d0			noise freq
	bsr	printbyte
;
	move.w	#161,chary
	move.w	i_vibr_speed(a2),d0	haal vibrato speed
	bsr	printbyte

	move.w	#171,chary
	moveq	#12,d0			draai vibrato depth om (1 wordt 11, 11 wordt 1)
	sub.w	i_vibr_depth(a2),d0	haal vibrato depth
	bsr	printbyte	
;
	move.w	#181,chary
	move.w	i_interval1(a2),d0	haal interval1
	bsr	printbyte
	
	move.w	#191,chary
	move.w	i_interval2(a2),d0	haal interval2
	bsr	printbyte
;	
	move.b	i_sound_mode(a2),d3	haal sound mode
	lea	sound_on,a3		haal adressen alle strings
	lea	sound_off,a4
	lea	mode_auto,a5

	move.w	#22,charx
	move.l	a4,a2		ga ervan uit dat modus uit is
	btst	#0,d3		toon aan?
	beq.s	no_i_tone	bit=0 -> geen toon
	move.l	a3,a2		print ON
no_i_tone
	bsr	print_string

	move.w	#26,charx
	move.l	a4,a2		ga ervan uit dat modus uit is
	btst	#2,d3		hardware aan?
	beq.s	no_i_hardw	bit=0 -> geen hardware
	move.l	a3,a2		print ON
no_i_hardw
	bsr	print_string

	move.w	#30,charx
	move.l	a4,a2		ga ervan uit dat modus uit is
	btst	#1,d3		noise aan?
	beq.s	no_i_noise	bit=0 -> geen noise
	move.l	a3,a2		print ON
no_i_noise
	bsr	print_string
;
	move.w	#16,charx
	move.w	#141,chary
	move.l	ym_ptr,a2		haal pointer naar YM sound
	moveq	#0,d7			om d7 als word te behandelen
	move.b	i_env_type(a2),d7	haal hardware envelope type
	subq.w	#8,d7			laagste envelope type = 8
	asl.w	#3,d7			maal 8, want per type zijn er 8 tekens
	lea	env_types,a5		haal adres tabel met tekens voor envelope types
	lea	0(a5,d7.w),a2		geef adres van tekens
	bsr	print_string		print string
;
	move.w	#31,charx	
	move.w	#101,chary
	moveq	#0,d0
	move.b	ym_sound,d0	haal nummer YM sound
	asl.w	#3,d0		iedere naam is 8 tekens lang
	lea	ym_names,a0	adres tabel met namen
	lea	0(a0,d0.w),a2	adres naam huidige YM sound
	bsr	print_asc8	print ASCII string van 8 tekens
;
	tst.b	asc_mode	wordt er iets ingevoerd?
	beq.s	no_input	nee -> print geen cursor

	bsr	print_inv_cur	print geinverteerde cursor
no_input
;
	move.w	#27,charx
	move.w	#151,chary
	move.b	key_mode,d0	haal key mode
	beq.s	key2mode_0
	cmpi.b	#1,d0		is key mode dan 1?
	beq.s	key2mode_1
	lea	sus_yms,a2	SUSTAIN (2)
	bra.s	key2mode_2
key2mode_0
	lea	rel_yms,a2	RELEASE (0)
	bra.s	key2mode_2
key2mode_1
	lea	att_yms,a2	ATTACK	(1)
key2mode_2
	bsr	print_string
;
;
	rts
;		***** PRINT YM EDIT FIELD *****
print_yef_first
	move.b	ym_sound,d0		haal YM sound nummer
	lea	ym_sounds,a2		haal adres begin YM sounds
	andi.w	#$3f,d0			maak word van YM sound
	asl.w	#8,d0			maal 256(=lengte 1 ym sound)
	add.w	d0,a2			tel die offset op bij start adres
	move.l	a2,ym_ptr		sla die pointer op
print_yef
	cmpi.w	#6,patmode	staat REC/PLAY mode op test-play (m.a.w. zitten we in YM edit field)
	bne	no_do		als we daar niet zijn -> doe niks
	tst.b	yef_mode	editen we AMP of FRQ?
	bne	print_pef	<>0 : FRQ
;				=0  : AMP
;
;		***** WIS AMPLITUDE EDIT FIELD *****
print_aef
	move.l	phys_0,a0	haal scherm adres
	add.l	#19*ll+8,a0	naar goede plaats
	move.l	#%01110111011101110000000000000000,d7
		; ----++++----++++----++++----++++   masker voor raster
	move.w	#15,d0		voor 16 blokken (hoogte)
next_block
; lege regel voor vierkant
	move.w	#17,d1		voor 18*16 lege stukken van 4*1
aef_clr_lin
	clr.l	(a0)+		clear bitplanes 1&2
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,aef_clr_lin
	add.l	#16,a0		naar volgende regel
; eerste regel van vierkant
	move.w	#17,d1		voor 18*16 stukken van 4*1
aef_lin1
	move.l	d7,(a0)+	zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,aef_lin1
	add.l	#16,a0		naar volgende regel
; tweede regel van vierkant
	move.w	#17,d1		voor 18*16 stukken van 4*1
aef_lin2
	move.l	d7,(a0)+	zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,aef_lin2
	add.l	#16,a0		naar volgende regel
; derde regel van vierkant
	move.w	#17,d1		voor 18*16 stukken van 4*1
aef_lin3
	move.l	d7,(a0)+	zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,aef_lin3
	add.l	#16,a0		naar volgende regel
;
	dbra	d0,next_block	volgend block
;
; lege regel onderaan YM edit field
	move.w	#17,d1		voor 18*16 lege stukken van 4*1
aef_clr_lin2
	clr.l	(a0)+		clear bitplanes 1&2
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,aef_clr_lin2
;
;
;		***** PLOT PUNTEN IN AMPLITUDE EDIT FIELD *****
	move.l	ym_ptr,a1		haal pointer naar geluid
	move.l	a1,a2			maak back-up om later kleuren te veranderen aan de hand van pointers voor attack,sustain & release
	move.w	yef_pos,d1		haal offset
	lea	i_env_start(a1,d1.w),a1	sla data over en tel offset er bij op
;
	move.l	phys_0,a0	haal scherm adres
	add.l	#20*ll+8,a0	naar goede plaats
	move.w	#%1000111111111111,d7	masker om bits te clearen
	move.w	#%0111000000000000,d6	masker om bits te zetten
	move.w	d6,d5			ook voor andere bitplanes
	move.w	d5,d4
	cmp.w	i_env_attack(a2),d1	zijn we al voorbij einde attack?
	blo.s	no_aef_sus		nee -> niet printen
	moveq	#0,d6			maak alle bitplanes 0 voor zwart
	move.w	d6,d5
	move.w	d5,d4
no_aef_sus
	cmp.w	i_env_sustain(a2),d1	zijn we all voorbij einde sustain?
	blo.s	no_aef_rel
	moveq	#0,d6			maak bitplane 0+2 0 voor wit
	move.w	d6,d4
	move.w	#%0111000000000000,d5	en bitplane 1 wordt 1
no_aef_rel
	cmp.w	i_env_release(a2),d1	zijn we al voorbij einde release?
	blo.s	no_aef_end
	move.w	#%0101000000000000,d6	masker om bits te zetten
	move.w	d6,d5			ook voor andere bitplanes
	moveq	#0,d4
no_aef_end	
		; ----++++----++++
	move.w	#72-1,d3	aantal te plotten punten
	moveq	#4,d2		hoelang nog voor we naar volgende adres moeten
;
plot_aef
	move.b	(a1)+,d0	haal punt uit geluid
	not.b	d0		punt=16-punt
	andi.w	#$f,d0		maak er een word van	
	mulu.w	#ll*4,d0	vermenigvuldig met 4 regels voor offset op goede regel
	and.w	d7,0(a0,d0.w)	en wis bits uit eerste bitplane zodat we zwarte punten krijgen
	or.w	d6,0(a0,d0.w)	en zet weer bits voor goede kleur
	or.w	d5,2(a0,d0.w)
	or.w	d4,4(a0,d0.w)
	addi.w	#ll,d0
	and.w	d7,0(a0,d0.w)	ook op volgende regels
	or.w	d6,0(a0,d0.w)
	or.w	d5,2(a0,d0.w)
	or.w	d4,4(a0,d0.w)
	addi.w	#ll,d0
	and.w	d7,0(a0,d0.w)
	or.w	d6,0(a0,d0.w)
	or.w	d5,2(a0,d0.w)
	or.w	d4,4(a0,d0.w)
;
	addq.w	#1,d1			verhoog eigen aef pos
	cmp.w	i_env_attack(a2),d1	zijn we al voorbij einde attack
	bne.s	no_ae2_sus		nee -> niet printen
	moveq	#0,d6			maak alle bitplanes 0 voor zwart
	move.w	d6,d5
	move.w	d5,d4
no_ae2_sus
	cmp.w	i_env_sustain(a2),d1	zijn we al voorbij einde release
	bne.s	no_ae2_rel
	moveq	#0,d6			maak bitplane 0+2 0 voor wit
	move.w	d6,d4
	move.w	#%0111000000000000,d5	en bitplane 1 wordt 1
	rol.w	d2,d5			zit bits op goede plaats
	rol.w	d2,d5
	rol.w	d2,d5
	rol.w	d2,d5
no_ae2_rel
	cmp.w	i_env_release(a2),d1	zijn we al bij einde release?
	bne.s	no_ae2_end
	move.w	#%0101000000000000,d6	masker om bits te zetten
	rol.w	d2,d6			zet bits op goede plaats
	rol.w	d2,d6
	rol.w	d2,d6
	rol.w	d2,d6
	move.w	d6,d5			ook voor andere bitplanes
	moveq	#0,d4
no_ae2_end	
	ror.w	#4,d7		roteer maskers naar volgende 4 punten
	ror.w	#4,d6
	ror.w	#4,d5
	ror.w	#4,d4
	subq.w	#1,d2		moeten we naar volgende word-groep?
	bne.s	no_nxt_wg	nee -> niks doen
	addq.l	#8,a0		ja -> op naar volgende word-groep
	move.w	#4,d2		herstel teller
no_nxt_wg
	dbra	d3,plot_aef

	rts
;
;		***** WIS PITCH EDIT FIELD *****
print_pef
	move.l	phys_0,a0	haal scherm adres
	add.l	#19*ll+8,a0	naar goede plaats
	move.l	#%01110111011101110000000000000000,d7
		; ----++++----++++----++++----++++   masker voor raster
; deel boven lijn
	move.w	#31,d0		wis 32 regels
next_pef_block
	move.w	#17,d1		voor 18*16 stukken van 4*1
clr_pef_lin
	move.l	d7,(a0)+	zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,clr_pef_lin

	add.l	#16,a0		naar volgende regel
	dbra	d0,next_pef_block
; teken middenlijn
	move.w	#17,d1		voor 18*16 stukken van 4*1
clr_pe2_lin
	clr.l	(a0)+		zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,clr_pe2_lin
	add.l	#16,a0		naar volgende regel
; deel onder lijn
	move.w	#31,d0		wis 32 regels
next_pe3_block
	move.w	#17,d1		voor 18*16 stukken van 4*1
clr_pe3_lin
	move.l	d7,(a0)+	zet bitplanes 1&2 neer
	clr.w	(a0)+		en 3
	addq.l	#2,a0		sla bitplane 4 over
	dbra	d1,clr_pe3_lin

	add.l	#16,a0		naar volgende regel
	dbra	d0,next_pe3_block
;
;
;		***** PLOT PUNTEN IN PITCH EDIT FIELD *****
	move.l	ym_ptr,a1		haal pointer naar geluid
	move.l	a1,a2			maak back-up om later kleuren te veranderen aan de hand van pointers voor attack,sustain & release
	move.w	yef_pos,d1		haal offset
	lea	0(a1,d1.w),a1		sla data over en tel offset er bij op
	add.l	#i_pit_start,a1		tel daarbij offset pitch envelope
;
	move.l	phys_0,a0	haal scherm adres
	add.l	#18*ll+8,a0	naar goede plaats
	move.w	#%1000111111111111,d7	masker om bits te clearen
	move.w	#%0111000000000000,d6	masker om bits te zetten
	move.w	d6,d5			ook voor andere bitplanes
	move.w	d5,d4
	cmp.w	i_pit_attack(a2),d1	zijn we al voorbij einde attack?
	blo.s	no_pef_sus		nee -> niet printen
	moveq	#0,d6			maak alle bitplanes 0 voor zwart
	move.w	d6,d5
	move.w	d5,d4
no_pef_sus
	cmp.w	i_pit_sustain(a2),d1	zijn we all voorbij einde sustain?
	blo.s	no_pef_rel
	moveq	#0,d6			maak bitplane 0+2 0 voor wit
	move.w	d6,d4
	move.w	#%0111000000000000,d5	en bitplane 1 wordt 1
no_pef_rel
	cmp.w	i_pit_release(a2),d1	zijn we al voorbij einde release?
	blo.s	no_pef_end
	move.w	#%0101000000000000,d6	masker om bits te zetten
	move.w	d6,d5			ook voor andere bitplanes
	moveq	#0,d4
no_pef_end	
		; ----++++----++++
	move.w	#72-1,d3	aantal te plotten punten
	moveq	#4,d2		hoelang nog voor we naar volgende adres moeten
;
plot_pef
	moveq	#0,d0
	move.b	(a1)+,d0	haal punt uit geluid
	addi.b	#128,d0		om goed in grafiek te krijgen
	lsr.w	#2,d0		breng getal 0-255 terug tot 0-63
	mulu.w	#ll,d0		vermenigvuldig met regellengte voor offset op goede regel
	lea	0(a0,d0.w),a3	bereken basis scherm adres
;
	and.w	d7,0(a3)	en wis bits uit eerste bitplane zodat we zwarte punten krijgen
	or.w	d6,0(a3)	en zet weer bits voor goede kleur
	or.w	d5,2(a3)
	or.w	d4,4(a3)
;
	and.w	d7,ll(a3)	ook op volgende regels
	or.w	d6,ll(a3)
	or.w	d5,ll+2(a3)
	or.w	d4,ll+4(a3)
;
	and.w	d7,ll*2(a3)
	or.w	d6,ll*2(a3)
	or.w	d5,ll*2+2(a3)
	or.w	d4,ll*2+4(a3)
;
	addq.w	#1,d1			verhoog eigen yef pos
	cmp.w	i_pit_attack(a2),d1	zijn we al voorbij einde attack
	bne.s	no_pe2_sus		nee -> niet printen
	moveq	#0,d6			maak alle bitplanes 0 voor zwart
	move.w	d6,d5
	move.w	d5,d4
no_pe2_sus
	cmp.w	i_pit_sustain(a2),d1	zijn we al voorbij einde release
	bne.s	no_pe2_rel
	moveq	#0,d6			maak bitplane 0+2 0 voor wit
	move.w	d6,d4
	move.w	#%0111000000000000,d5	en bitplane 1 wordt 1
	rol.w	d2,d5			zit bits op goede plaats
	rol.w	d2,d5
	rol.w	d2,d5
	rol.w	d2,d5
no_pe2_rel
	cmp.w	i_pit_release(a2),d1	zijn we al bij einde release?
	bne.s	no_pe2_end
	move.w	#%0101000000000000,d6	masker om bits te zetten
	rol.w	d2,d6			zet bits op goede plaats
	rol.w	d2,d6
	rol.w	d2,d6
	rol.w	d2,d6
	move.w	d6,d5			ook voor andere bitplanes
	moveq	#0,d4
no_pe2_end	
	ror.w	#4,d7		roteer maskers naar volgende 4 punten
	ror.w	#4,d6
	ror.w	#4,d5
	ror.w	#4,d4

	subq.w	#1,d2		moeten we naar volgende word-groep?
	bne.s	no_nxt_pef_wg	nee -> niks doen
	addq.l	#8,a0		ja -> op naar volgende word-groep
	move.w	#4,d2		herstel teller
no_nxt_pef_wg
	dbra	d3,plot_pef

	rts
;
;
;		***** PRINT HELP SCREEN *****
print_help
	lea	help_txt,a2	haal adres help tekst
	move.w	help_pos,d0	haal positie in help tekst
	bra.s	search_help_pos	zet pointer in a2 op goede plaats
search_next_return
	cmpi.b	#13,(a2)+	is dit een return?
	bne.s	search_next_return
search_help_pos
	dbra	d0,search_next_return
;
; print regels
	lea	asc_2_lfc,a3	haal adres conversie tabel ASCII -> LFC
	moveq	#19,d3		print 20 regels
	move.w	#4,charx	eerste x en y positie
	move.w	#21,chary
print_help_line
	moveq	#0,d0
	move.b	(a2)+,d0	haal byte uit tekst
	cmpi.b	#13,d0		is het een Return?
	beq.s	next_help_line	ja -> naar volgende regel
	move.b	0(a3,d0.w),d0	zet ASCII letter om in LFC code
	bsr	printchar	print letter
	addq.w	#1,charx	verschuif cursor
	bra.s	print_help_line		volgende teken
next_help_space
	move.w	#42,d0		code voor spatie
	bsr	printchar
	addq.w	#1,charx	verschuif cursor
next_help_line
	cmpi.w	#36,charx		is x-positie al aan einde regel?
	blo.s	next_help_space		nee -> print spatie
	addq.w	#8,chary		cursor naar beneden
	move.w	#4,charx		en naar links
	dbra	d3,print_help_line	print volgende regel
	rts
;
;		***** ROUTINE VOOR DEMO IN HELP-SCREEN *****
print_demo
	subq.w	#1,logo_color	moet de kleur van het logo veranderd worden?
	bne.s	no_new_logo_col	nee -> doe niets

	moveq	#0,d0
	move.l	cur_logo_col,a4	haal pointer in tabel met kleuren
	move.w	(a4)+,col0+5*2	haal nieuwe kleur en zet hem in kleur #5
	bpl.s	no_re_logo_col	positief -> begin NIET opnieuw

	lea	logo_cols,a4	haal BEGIN hi tabel
	move.w	(a4)+,col0+5*2	haal EERSTE kleur en zet hem in kleur #5
no_re_logo_col
	move.w	(a4)+,logo_color	haal nieuw aantal te wachten VBL's
	move.l	a4,cur_logo_col		bewaar pointer
;
no_new_logo_col
	subq.w	#1,dist_color	moet de kleur van dist veranderd worden?
	bne.s	no_new_dist_col	nee -> doe niets

	moveq	#0,d0
	move.l	cur_dist_col,a4	haal pointer in tabel met kleuren
	move.w	(a4)+,d0	haal nieuwe kleur
	bpl.s	no_re_dist_col	positief -> begin NIET opnieuw

	lea	dist_cols,a4	haal BEGIN kleuren tabel
	move.w	(a4)+,d0	haal EERSTE kleur
no_re_dist_col
	move.w	d0,col0+3*2		kleur naar #3
	move.w	d0,col0+7*2		en naar #7
	move.w	(a4)+,dist_color	haal nieuw aantal te wachten VBL's
	move.l	a4,cur_dist_col		bewaar pointer
;
no_new_dist_col
;
	bsr	print_dist	zet distortion neer
	bsr	print_logo	zet logo neer
	rts
;
;		***** DISTORTION IN HELP-SCREEN *****
; macro voor snel copieren, roep aan met BSR print_dist
bgline	macro
	move.w	d0,(a0)
	move.w	d1,8(a0)
	move.w	d0,16(a0)
	move.w	d1,24(a0)
	move.w	d0,32(a0)
;
	move.w	d1,40(a0)
	move.w	d0,48(a0)
	move.w	d1,56(a0)
	move.w	d0,64(a0)
	move.w	d1,72(a0)
;
	move.w	d0,80(a0)
	move.w	d1,88(a0)
	move.w	d0,96(a0)
	move.w	d1,104(a0)
	move.w	d0,112(a0)
;
	move.w	d1,120(a0)
	move.w	d0,128(a0)
	move.w	d1,136(a0)
	move.w	d0,144(a0)
	move.w	d1,152(a0)
;
	endm
;
print_dist
	move.l	curdist,a2	haal pointer in tabel met verschillende shift tabel pointers (distortion tabel)
	move.l	(a2)+,a1	haal pointer naar shift tabel
	cmp.l	#0,a1		vergelijk met 0
	bne.s	noredis		als <>0 niet opnieuw beginnen in tabel

	lea	distab,a2	haal BEGIN distortion tabel
	move.l	(a2)+,a1	haal EERSTE pointer naar shift tabel
noredis	move.l	a2,curdist	zet pointer in distortion tabel terug
;
	moveq	#0,d0
	move.l	curhi,a4	haal pointer in tabel met pointers naar BG data
	move.b	(a4)+,d0	haal hoogte BG data
	bpl.s	norehi		positief -> begin NIET opnieuw

	lea	hitab,a4	haal BEGIN hi tabel
	move.b	(a4)+,d0	haal EERSTE hoogte BG data
norehi	move.l	a4,curhi
	asl.w	#2,d0		maal lengte 1 regel
	move.l	dist_data,a3	adres achtergrond-data
	lea	0(a3,d0.w),a3	tel offset daarbij op
	
	move.l	phys_0,a0	haal schermadres
	add.l	#ll*18+2,a0	naar 18de regel, 2de bitplane
	move.l	#ll,a4
	moveq	#160/dist_hi-1,d7	aantal keer

patloop	moveq	#dist_hi-1,d6	zoveel regels
	move.l	a3,a2		beginadres achtergrond patroon
bgloop	move.l	(a2)+,d0	haal achtergrond
	move.w	(a1)+,d4	haal shift	
	ror.l	d4,d0		shift deel #1
	move.w	d0,d1		tweede helft naar d1
	swap	d0		eerste helft onderin
	bgline			zet lijn op beeld
	add.l	a4,a0		naar volgende regel
	dbra	d6,bgloop	nog een regel
	dbra	d7,patloop	volgende patroon

	rts
;
;		***** BOUNCING LOGO *****
clr_logo_line	macro
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	clr.w	32(a0)
	clr.w	40(a0)
	clr.w	48(a0)
	clr.w	56(a0)
	clr.w	64(a0)
;
	clr.w	72(a0)
	clr.w	80(a0)
	clr.w	88(a0)
	clr.w	96(a0)
	clr.w	104(a0)
	clr.w	112(a0)
	clr.w	120(a0)
	clr.w	128(a0)
	clr.w	136(a0)
	clr.w	144(a0)	*****
	add.l	a2,a0		naar volgende regel op beeld
	endm
;
put_logo_line	macro
	move.w	(a1)+,(a0)
	move.w	(a1)+,8(a0)
	move.w	(a1)+,16(a0)
	move.w	(a1)+,24(a0)
	move.w	(a1)+,32(a0)
	move.w	(a1)+,40(a0)
	move.w	(a1)+,48(a0)
	move.w	(a1)+,56(a0)
	move.w	(a1)+,64(a0)
;
	move.w	(a1)+,72(a0)
	move.w	(a1)+,80(a0)
	move.w	(a1)+,88(a0)
	move.w	(a1)+,96(a0)
	move.w	(a1)+,104(a0)
	move.w	(a1)+,112(a0)
	move.w	(a1)+,120(a0)
	move.w	(a1)+,128(a0)
	move.w	(a1)+,136(a0)
	move.w	(a1)+,144(a0)	*****
	endm
;
print_logo
	moveq	#0,d0
	move.l	logo_pos_ptr,a4	haal pointer in tabel met verschillende hoogtes voor logo
	move.b	(a4)+,d0	haal hoogte
	bpl.s	no_re_logo_pos	positief -> begin NIET opnieuw

	lea	logo_y,a4	haal BEGIN hi tabel
	move.b	(a4)+,d0	haal EERSTE hoogte
no_re_logo_pos
	move.l	a4,logo_pos_ptr
	mulu.w	#ll,d0		maal lengte 1 regel
	move.l	phys_0,a0	haal schermadres
	lea	8+4(a0,d0.w),a0	adres=schermadres+offset voor hoogte+2de wordgroep+3de bitplane

	move.l	logo_data,a1	haal adres huidige logo
	move.l	#ll,a2		voor snel naar volgende regel
	moveq	#logo_hi-1,d0	hoogte van het logo
;
	clr_logo_line		doe deze macro zoveel keren als de maximale vertikale verplaatsing
	clr_logo_line
	clr_logo_line

put_logo
	put_logo_line
	add.l	a2,a0		naar volgende regel op beeld
	dbra	d0,put_logo

	clr_logo_line		doe deze macro zoveel keren als de maximale vertikale verplaatsing
	clr_logo_line
	clr_logo_line
;
	rts
;
;
;		***** PRINT ROUTINES : *****
;
;		***** PRINT GEINVERTEERDE CURSOR *****
; gebruikt : d1-d2/a0
print_inv_cur
	move.l	phys_0,a0	haal scherm adres
	move.w	stringy,d2	haal y pos (x pos zit al in d1)
	mulu.w	#linelen,d2	vermenigvuldig met lengte 1 regel
	adda.w	d2,a0		tel bij schermadres op

	move.w	stringx,d1	haal x positie string
	add.w	asc_cur,d1	tel daarbij op positie cursor
	bclr	#0,d1		clear onderste bit
	sne.b	d2		als dat bit 1 was, dan is het de rechter byte
	asl.w	#2,d1		vermenigvuldig x pos met 4
	tst.b	d2		was het de rechterbyte?
	beq.s	norite2		als niet zo -> doe niks
	addq.w	#1,d1		tel 1 op bij x pos
norite2	adda.w	d1,a0		tel bij schermadres op
;
	not.b	(a0)		eerste geinverteerde byte op scherm
	not.b	ll(a0)		2de
	not.b	ll*2(a0)	etc.
	not.b	ll*3(a0)
	not.b	ll*4(a0)
	not.b	ll*5(a0)
	not.b	ll*6(a0)
	not.b	ll*7(a0)
; cursor op scherm gezet -> terug van routine
	rts
;
;
;		***** PRINT ENVELOPE *****
; d0.b = envelope value
print_envelope
	lea	env_2_char,a0	conversie tabel envelope value -> teken
	andi.w	#$f,d0		maak een word van envelope value
	move.b	0(a0,d0.w),d0	haal teken
	bsr	printchar	print teken
	rts
;
;		***** PRINT ASCII-STRING VAN 8 TEKENS *****
; a2.l = pointer naar ASCII-string van 8 tekens
; gebruikt : d0-d2/a0-a3
print_asc8
	lea	asc_2_lfc,a3	tabel: ASCII -> Lynx Font Code
	moveq	#7,d3		print 8 tekens
next_asc8
	moveq	#0,d0
	move.b	(a2)+,d0	haal ASCII teken
	move.b	0(a3,d0.w),d0	converteer naar LFC
	bsr	printchar	print LFC teken
	addq.w	#1,charx	verschuif cursor
	dbra	d3,next_asc8	volgende teken

	rts
;
;		***** PRINT ASCII-STRING *****
; a2.l = pointer naar ASCII-string met 0 op einde
; gebruikt : d0-d2/a0-a3
print_ascii
	lea	asc_2_lfc,a3	tabel: ASCII -> Lynx Font Code
next_ascii
	moveq	#0,d0
	move.b	(a2)+,d0	haal ASCII teken
	beq.s	last_ascii	als 0 -> laatste teken van string
	move.b	0(a3,d0.w),d0	converteer naar LFC
	bsr	printchar	print LFC teken
	addq.w	#1,charx	verschuif cursor
	bra.s	next_ascii	volgende teken
last_ascii
	rts
;
;		***** PRINT STRING *****
; a2.l = pointer naar string die eindigt op -1
;
; bij terugkomst verpest : d0-d2/a0-a2
print_string
	move.b	(a2)+,d0	haal letter uit string
	bmi.s	end_of_string	als negatief(-1) -> einde van string
	bsr	printchar	print letter
	addq.w	#1,charx	verschuif cursor
	bra.s	print_string	volgende letter verwerken
end_of_string
	rts
;
;		***** PRINT 3 NIBBLES VAN LONG IN HEX *****
; d0.l = hex long
; charx.w = x pos
; chary.w = y pos
; bij terugkomst verpest: d0-d2/a0-a2
print_long
	lea	long_dec,a0		adres plaats waar decimale string gezet moet worden
	move.l	#$2a2a2a2a,(a0)+	maak spaties van eerste 4 letters
	move.b	#20,(a0)	K
	move.b	#11,1(a0)	B
	st.b	2(a0)		-1 op einde string
	tst.l	d0		is getal 0?
	beq.s	long_is_0	ja -> print 0000KB
	subq.l	#1,d0		zodat 1024 bytes niet 2KB wordt
	lsr.l	#8,d0		voor aantal Kb: deel door 1024
	lsr.l	#2,d0		1024=2^10
	addq.l	#1,d0		rond aantal KB naar boven af
to_dec	move.l	d0,d1		cijfer verwerken
	divu.w	#10,d1		deel door 10
	move.w	d1,d0		bewaar resultaat
	swap	d1		haal rest
	move.b	d1,-(a0)	zet cijfer in buffer
	tst.w	d0		alle cijfers gehad?
	bne.s	to_dec		nee -> volgende cijfer
	lea	long_dec,a2	adres string met cijfers
	bsr	print_string	print LFC string
	subq.w	#6,charx	zet cursor terug
	rts
long_is_0
	lea	long_dec,a2	adres string met cijfers
	clr.b	3(a2)		maak nul van rechter digit
	bsr	print_string	print LFC string
	subq.w	#6,charx	zet cursor terug
	rts

;
;		***** PRINT WORD IN HEX *****
; d0.w = hex word
; charx.w = x pos
; chary.w = y pos
; bij terugkomst verpest: d0-d4/a0-a1
print_word
	move.w	d0,d3		maak back-up van long

	moveq	#3,d4		we printen 4 characters
print_word_nibbles
	rol.w	#4,d3		haal nibble naar onderste 4 bits
	move.b	d3,d0		naar d0
	andi.b	#%1111,d0	hou alleen onderste 4 bits over
	bsr	printchar	print teken
	addq.w	#1,charx	verschuif cursor
	dbra	d4,print_word_nibbles

	subq.w	#4,charx	zet cursor weer terug
	rts

;
;		***** PRINT EEN BYTE IN HEX *****
; d0.b    = hex byte
; charx.w = x pos
; chary.w = y pos
; bij terugkomst verpest: d0-d3/a0-a1
printbyte
	move.b	d0,d3		maak backup van byte

	andi.w	#$f,d0		gebruik alleen onderste helft van byte
	addq.w	#1,charx	verhoog x positie
	bsr	printchar	en print tweede letter

	subq.w	#1,charx	verlaag x positie
	move.b	d3,d0		haal byte weer
	lsr.b	#4,d0		haal bovenste nibble naar onderste nibble
	andi.w	#$f,d0		gebruik alleen onderste helft van byte
	bsr	printchar	en print die letter

	rts
;
;		***** PRINT EEN LETTER *****
; d0.b    = letter
; charx.w = x pos
; chary.w = y pos
; gebruikt: d0-d2/a0-a1
printchar
	move.l	phys_0,a0	haal scherm adres
	move.w	charx,d1	haal x pos
	move.w	chary,d2	haal y pos
	mulu.w	#linelen,d2	vermenigvuldig met lengte 1 regel
	adda.w	d2,a0		tel bij schermadres op

	bclr	#0,d1		clear onderste bit
	sne.b	d2		als dat bit 1 was, dan is het de rechter byte
	asl.w	#2,d1		vermenigvuldig x pos met 4
	tst.b	d2		was het de rechterbyte?
	beq.s	noright		als niet zo -> doe niks
	addq.w	#1,d1		tel 1 op bij x pos
noright	adda.w	d1,a0		tel bij schermadres op
;
	lea	font1,a1	haal adres font
	andi.w	#$ff,d0		maak word van char#
	asl.w	#3,d0		char# *8 voor offset in font
	adda.w	d0,a1		tel offset op bij beginadres font
;
	move.b	(a1)+,(a0)	eerste byte op scherm
	move.b	(a1)+,ll(a0)	2de
	move.b	(a1)+,ll*2(a0)	etc.
	move.b	(a1)+,ll*3(a0)
	move.b	(a1)+,ll*4(a0)
	move.b	(a1)+,ll*5(a0)
	move.b	(a1)+,ll*6(a0)
	move.b	(a1)+,ll*7(a0)
; letter op scherm gezet -> terug van routine
	rts
;		***** HIER BEGINT HET DATA GEBIED *****
;
	section	DATA
;
;
	even
;
;
vols	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
	dc.b	0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
	dc.b	0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
	dc.b	0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
	dc.b	0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
	dc.b	0,0,1,1,2,2,2,3,3,4,4,4,5,5,6,6
	dc.b	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b	0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
	dc.b	0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
	dc.b	0,1,1,2,3,3,4,5,5,6,7,7,8,8,9,10
	dc.b	0,1,1,2,3,4,4,5,6,7,7,8,9,10,10,11
	dc.b	0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12
	dc.b	0,1,2,3,3,4,5,6,7,8,9,10,10,11,12,13
	dc.b	0,1,2,3,4,5,6,7,7,8,9,10,11,12,13,14
	dc.b	0,1,2,3,4,5,6,7,8,9,$a,$b,$c,$d,$e,$f
;
;
	even
note_2_freq
	ds.w	1	lege ruimte want als noot=0 -> geen verandering
;		C    C#   D    D#   E    F
	dc.w	3822,3607,3405,3214,3033,2863
	dc.w	2702,2551,2407,2272,2145,2024
;		F#   G    G#   A    A#   B
;		zelfde noten in volgende octaaf voor intervallen
	dc.w	1991,1804,1703,1607,1517,1432
	dc.w	1351,1276,1204,1136,1073,1012
;
	even
note_2_char	;	tabel die nootnummers omrekent naar letters
	dc.b	51,51	tekens voor geen noot
;		C     C#    D     D#    E     F
	dc.b	$c,42,$c,36,$d,42,$d,36,$e,42,$f,42
	dc.b	$f,36,16,42,16,36,$a,42,$a,36,$b,42
;		F#    G     G#    A     A#    B
;
	even
env_types
	dc.b	38,38,38,38,-1	down*4
	ds.b	3		vul op tot 8 tekens
	dc.b	38,40,40,40,-1	down,lo*3
	ds.b	3
	dc.b	38,39,38,39,-1	down,up,down,up
	ds.b	3
	dc.b	38,41,41,41,-1	down,hi*3
	ds.b	3
	dc.b	39,39,39,39,-1	up*4
	ds.b	3
	dc.b	39,41,41,41,-1	up,hi*3
	ds.b	3
	dc.b	39,38,39,38,-1	up,down,up,down
	ds.b	3
	dc.b	39,40,40,40,-1	up,lo*3
;
env_2_char
	dc.b	0,10,28,27	0,A,S,R
;
;
;
;	***** CONVERTEERT ASCII -> LFC *****
asc_2_lfc
	dc.b	42				; ascii 0(=spatie)
	ds.b	31				; ascii 1-31
	dc.b	42				; spatie
	dc.b	44				; !
	ds.b	1				; ascii 34
	dc.b	36				; #
	dc.b	59				; $
	ds.b	1				; ascii 37
	dc.b	56				; arrow
	ds.b	1				; ascii 39
	dc.b	49,50				; (,)
	dc.b	55				; *
	dc.b	57				; +
	dc.b	45				; ,
	dc.b	51				; -
	dc.b	46				; .
	dc.b	48				; /
	dc.b	0,1,2,3,4,5,6,7,8,9		; 0-9
	dc.b	52				; :
	dc.b	53				; ;
	ds.b	1				; ascii 60
	dc.b	58				; =
	ds.b	1				; ascii 62
	dc.b	43				; ?
	ds.b	1				; ascii 64
	dc.b	10,11,12,13,14,15,16,17,18,19	; A-J
	dc.b	20,21,22,23,24,25,26,27,28,29	; K-T
	dc.b	30,31,32,33,34,35		; U-Z
	ds.b	1				; ascii 91
	dc.b	54				; \ (acieed)
	ds.b	2				; ascii 93-94
	dc.b	37				; _
	ds.b	1				; ascii 96
	dc.b	10,11,12,13,14,15,16,17,18,19	; a-j
	dc.b	20,21,22,23,24,25,26,27,28,29	; k-t
	dc.b	30,31,32,33,34,35		; u-z
	ds.b	256-(*-asc_2_lfc)		vul rest tabel
;		***** CONVERTEERT SCANCODE -> ASCII *****
key_2_asc
	ds.b	2			; xxx,Esc
	dc.b	49,50,51,52,53		; 1...5
	dc.b	54,55,56,57,48		; 6...9,0
	dc.b	95			; underline
	ds.b	3			; =,Backspace,TAB
	dc.b	81,87,69,82,84		; QWERT
	dc.b	89,85,73,79,80		; YUIOP
	ds.b	4			; [,],Return,Control
	dc.b	65,83,68,70,71		; ASDFG
	dc.b	72,74,75,76		; HJKL
	ds.b	5
	dc.b	90,88,67,86,66		; ZXCVB
	dc.b	78,77			; NM
	ds.b	6			; komma,.,/,Shift Rechts,xxx,Alternate
	dc.b	32			; Spatiebalk
	ds.b	256-(*-key_2_asc)	vul rest tabel
;
;
;	***** CONVERTEERT MIDI -> OCTAAF/NOOT *****
midi_2_note
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12		; eerste octaaf
	dc.b	16+1,16+2,16+3,16+4,16+5,16+6		; 1ste helft 2de octaaf
	dc.b	16+7,16+8,16+9,16+10,16+11,16+12	; 2de helft 2de octaaf
	dc.b	32+1,32+2,32+3,32+4,32+5,32+6		; 1ste helft 3de octaaf
	dc.b	32+7,32+8,32+9,32+10,32+11,32+12	; 2de helft 3de octaaf
;		************
	dc.b	1,2,3,4,5,6,7,8,9,10,11,12		; eerste octaaf
	dc.b	16+1,16+2,16+3,16+4,16+5,16+6		; 1ste helft 2de octaaf
	dc.b	16+7,16+8,16+9,16+10,16+11,16+12	; 2de helft 2de octaaf
	dc.b	32+1,32+2,32+3,32+4,32+5,32+6		; 1ste helft 3de octaaf
	dc.b	32+7,32+8,32+9,32+10,32+11,32+12	; 2de helft 3de octaaf
;		************
	dc.b	48+1,48+2,48+3,48+4,48+5,48+6		; 1ste helft 4de octaaf
	dc.b	48+7,48+8,48+9,48+10,48+11,48+12	; 2de helft 4de octaaf
	dc.b	64+1,64+2,64+3,64+4,64+5,64+6		; 1ste helft 5de octaaf
	dc.b	64+7,64+8,64+9,64+10,64+11,64+12	; 2de helft 5de octaaf
	dc.b	80+1,80+2,80+3,80+4,80+5,80+6		; 1ste helft 6de octaaf
	dc.b	80+7,80+8,80+9,80+10,80+11,80+12	; 2de helft 6de octaaf
;		*************
	dc.b	96+1,96+2,96+3,96+4,96+5,96+6		; 1ste helft 7de octaaf
	dc.b	96+7,96+8,96+9,96+10,96+11,96+12	; 2de helft 7de octaaf
	dc.b	112+1,112+2,112+3,112+4,112+5,112+6	; 1ste helft 8de octaaf
	dc.b	112+7,112+8,112+9,112+10,112+11,112+12	; 2de helft 8de octaaf
;
;	
;	
	even
key_2_note
	ds.b	3	; xxx,ESC,1
	dc.b	16+7	; 2
	dc.b	16+9	; 3
	dc.b	16+11	; 4
	ds.b	1	; 5	***
	dc.b	32+2	; 6
	dc.b	32+4	; 7
	ds.b	1	; 8	***
	dc.b	32+7	; 9
	dc.b	32+9	; 0
	dc.b	32+11	; -
	ds.b	3	; =,Backspace,TAB

	dc.b	16+6	; Q
	dc.b	16+8	; W
	dc.b	16+10	; E
	dc.b	16+12	; R
	dc.b	32+1	; T
	dc.b	32+3	; Y
	dc.b	32+5	; U
	dc.b	32+6	; I
	dc.b	32+8	; O
	dc.b	32+10	; P
	dc.b	32+12	; [
	ds.b	4	; ],Return,Control,A

	dc.b	2	; S
	dc.b	4	; D
	ds.b	1	; F	***
	dc.b	7	; G
	dc.b	9	; H
	dc.b	11	; J
	ds.b	1	; K	***
	dc.b	16+2	; L
	dc.b	16+4	; ;
	ds.b	4	; ',#,Shift links,\

	dc.b	1	; Z
	dc.b	3	; X
	dc.b	5	; C
	dc.b	6	; V
	dc.b	8	; B
	dc.b	10	; N
	dc.b	12	; M
	dc.b	16+1	; ,
	dc.b	16+3	; .
	dc.b	16+5	; /
fill_rest	equ	*-key_2_note
	ds.b	128-fill_rest
;
;
note_2_sam
	ds.b	1	; noot#0 bestaat niet
	dc.b	0	; C 0
	dc.b	-1	; C#0
	dc.b	1	; D 0
 	dc.b	-1	; D#0
	dc.b	2	; E 0
	dc.b	3	; F 0
	dc.b	-1	; F#0
	dc.b	4	; G 0
	dc.b	-1	; G#0
	dc.b	5	; A 0
	dc.b	-1	; A#0
	dc.b	6	; B 0
	ds.b	4	; vul op tot volgende octaaf
;
	dc.b	7	; C 1
	dc.b	-1	; C#1
	dc.b	8	; D 1
	dc.b	-1	; D#1
	dc.b	9	; E 1
	dc.b	10	; F 1
	dc.b	-1	; F#1
	dc.b	11	; G 1
	dc.b	-1	; G#1
	dc.b	12	; A 1
	dc.b	-1	; A#1
	dc.b	13	; B 1
	ds.b	4	; vul op tot volgende octaaf
;
	dc.b	14	; C 1
	dc.b	-1	; C#1
	dc.b	15	; D 1
	dc.b	-1	; D#1
	dc.b	-1	; E 1
	dc.b	-1	; F 1
	dc.b	-1	; F#1
	dc.b	-1	; G 1
	dc.b	-1	; G#1
	dc.b	-1	; A 1
	dc.b	-1	; A#1
	dc.b	-1	; B 1
;
;
key_2_hex
	dc.b	-1,-1	; xxx, Esc
	dc.b	1	; 1
	dc.b	2	; 2
	dc.b	3	; 3
	dc.b	4	; 4
	dc.b	5	; 5
	dc.b	6	; 6
	dc.b	7	; 7
	dc.b	8	; 8
	dc.b	9	; 9
	dc.b	0	; 0
	dcb.b	-1,6	; -,=,`,Backspace,TAB,Q,W
	dc.b	$e	; E
	dcb.b	-1,11	; R t/m Control
	dc.b	$a	; A
	dc.b	-1	; S
	dc.b	$d	; D
	dc.b	$f	; F
	dcb.b	-1,12	; G t/m X
	dc.b	$c	; C
	dc.b	-1	; V
	dc.b	$b	; B
	dcb.b	-1,128 
;
key_2_env
	dc.b	-1,-1	; xxx, Esc
	dcb.b	-1,9	; 1 t/m 9
	dc.b	0	; 0
	dcb.b	-1,7	; -,=,`,Backspace,TAB,Q,W,E
	dc.b	3	; R
	dcb.b	-1,10	; T t/m Control
	dc.b	1	; A
	dc.b	2	; S
	dcb.b	-1,128 	; de rest
;
hertz	dc.b	110,110,110,110
	dc.b	110,110,94,82
	dc.b	73,66,60,55
	dc.b	51,47,44,41
;
	even
trem_tab
	dc.w	   0, 428, 852,1266,1666,2048,2408,2741,3044,3314
	dc.w	3547,3742,3896,4006,4074,4096,4074,4006,3896,3742
	dc.w	3547,3314,3044,2741,2408,2048,1666,1266,0852,0428
	dc.w	    0, -428, -852,-1266,-1666,-2048,-2408,-2741,-3044,-3314
	dc.w	-3547,-3742,-3896,-4006,-4074,-4096,-4074,-4006,-3896,-3742
	dc.w	-3547,-3314,-3044,-2741,-2408,-2048,-1666,-1266, -852, -428

	even
;		***** MUIS & BUTTONS *****
;
;
cursor_rec
	dc.l	recA,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
	dc.l	rec_note,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
	dc.l	rec_note,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
cursor_get
	dc.l	getA_note,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
	dc.l	get_note,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
	dc.l	get_note,get_octave,get_tie_h,get_tie_l,get_snd_h,get_snd_l,get_vol,get_env
;
cursor_chan
	dc.l	0,0,0,0,0,0,0,0
	dc.l	4,4,4,4,4,4,4,4
	dc.l	8,8,8,8,8,8,8,8
cursor_data
	dc.l	Adata,Adata,Adata,Adata,Adata,Adata,Adata,Adata
	dc.l	Bdata,Bdata,Bdata,Bdata,Bdata,Bdata,Bdata,Bdata
	dc.l	Cdata,Cdata,Cdata,Cdata,Cdata,Cdata,Cdata,Cdata
;
cursor_offs
	dc.l	0,8,9,16,17,24,25,32
	dc.l	40,48,49,56,57,64,65,72
	dc.l	80,88,89,96,97,104,105,112
;
;		***** BUTTON TABEL *****
but_main	;	tabel met button x/y coordinaten en routines die uitgevoerd moeten worden bij aanklikken op hoofdscherm
	dc.w	214,12,226,19	sample rate minus
	dc.l	srate_m
	dc.w	229,12,241,19	sample rate plus
	dc.l	srate_p
	dc.w	244,12,289,19	sample rate low
	dc.l	srate_h
;
	dc.w	214,22,226,29	sample # minus
	dc.l	sampl_m
	dc.w	229,22,241,29	sample # plus
	dc.l	sampl_p
	dc.w	244,22,289,29	sample # low
	dc.l	sampl_l
;
	dc.w	214,32,226,39	YM sound minus
	dc.l	sound_m
	dc.w	229,32,241,39	YM sound plus
	dc.l	sound_p
	dc.w	244,32,289,39	YM sound low
	dc.l	sound_l
;
	dc.w	214,42,226,49	YM volume minus
	dc.l	ymvol_m
	dc.w	229,42,241,49	YM volume plus
	dc.l	ymvol_p
	dc.w	244,42,289,49	YM volume high
	dc.l	ymvol_h
;
	dc.w	214,52,226,59	YM tie minus
	dc.l	ymtie_m
	dc.w	229,52,241,59	YM tie plus
	dc.l	ymtie_p
	dc.w	244,52,289,59	YM tie low
	dc.l	ymtie_l
;
	dc.w	214,62,226,69	position minus
	dc.l	posit_m
	dc.w	229,62,241,69	position plus
	dc.l	posit_p
	dc.w	244,62,289,69	position low
	dc.l	posit_l
;
	dc.w	214,72,226,79	pattern minus
	dc.l	patte_m
	dc.w	229,72,241,79	pattern plus
	dc.l	patte_p
	dc.w	244,72,289,79	pattern low
	dc.l	patte_l
;
	dc.w	214,82,226,89	length minus
	dc.l	posle_m
	dc.w	229,82,241,89	length plus
	dc.l	posle_p
	dc.w	244,82,289,89	length low
	dc.l	posle_l
;
	dc.w	214,92,226,99	restart minus
	dc.l	resta_m
	dc.w	229,92,241,99	restart plus
	dc.l	resta_p
	dc.w	244,92,289,99	restart low
	dc.l	resta_l
;
	dc.w	214,102,226,109	speed minus
	dc.l	speed_m
	dc.w	229,102,241,109	speed plus
	dc.l	speed_p
	dc.w	244,102,289,109	speed low
	dc.l	speed_8
;
	dc.w	214,112,226,119	stop step minus
	dc.l	sstep_m
	dc.w	229,112,241,119	stop step plus
	dc.l	sstep_p
	dc.w	244,112,289,119	stop step low
	dc.l	sstep_l
;
	dc.w	214,122,226,129	octave minus
	dc.l	octav_m
	dc.w	229,122,241,129	octave plus
	dc.l	octav_p
	dc.w	244,122,289,129	octave low
	dc.l	octav_l
;
	dc.w	1,92,27,119	song play
	dc.l	s_play
	dc.w	30,92,56,119	patt play
	dc.l	p_play
	dc.w	59,92,85,119	song rec
	dc.l	s_rec
	dc.w	88,92,114,119	patt rec
	dc.l	p_rec
	dc.w	117,92,161,119	stop
	dc.l	p_stop
;
	dc.w	1,122,85,129	record mode channel 1
	dc.l	r_mode
;
	dc.w	88,122,211,129	key mode all channels
	dc.l	k_mode
;
	dc.w	29,132,106,198	channel 1 select
	dc.l	chan1
	dc.w	109,132,186,198	channel 2 select
	dc.l	chan2
	dc.w	189,132,266,198	channel 3 select
	dc.l	chan3
;
	dc.w	164,92,177,119	channel 1 mute
	dc.l	mute1
	dc.w	180,92,193,119	channel 2 mute
	dc.l	mute2
	dc.w	196,92,211,119	channel 3 mute
	dc.l	mute3
;
	dc.w	117,12,211,19	Enter Song Name
	dc.l	song_name_main
;
	dc.w	117,22,211,29	Enter Sample Name
	dc.l	sam_name_main
;
	dc.w	117,32,211,39	Enter YM Sound Name
	dc.l	ym_name_main
;
	dc.w	117,42,211,49	Disk Access
	dc.l	da_select
;
	dc.w	117,52,211,59	Memory
	dc.l	mem_select
;
	dc.w	117,62,211,69	YM Sound Edit screen
	dc.l	yme_scr
;
	dc.w	117,72,211,79	Insert pattern
	dc.l	ins_pat
;
	dc.w	117,82,211,89	Delete pattern
	dc.l	del_pat
;
	dc.w	1,12,114,89	Menu select
	dc.l	menu_sel
;
	dc.w	292,1,318,9	Help
	dc.l	help_scr
;
	dc.w	1,1,13,9	programma beeindigen (eigenlijk alleen nodig tijdens programmeren, verder wil je nooit stoppen)
	dc.l	exit
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;		***** BUTTON POSITIES YM EDIT SCREEN *****
but_yme
;
	dc.w	163,111,176,118	YM sound minus
	dc.l	sound_m
	dc.w	179,111,191,118	YM sound plus
	dc.l	sound_p
	dc.w	194,111,239,118	YM sound low
	dc.l	sound_l
;
	dc.w	163,121,176,128	volume minus
	dc.l	ymvol_m
	dc.w	179,121,191,128	volume plus
	dc.l	ymvol_p
	dc.w	194,121,239,128	volume high
	dc.l	ymvol_h
;
	dc.w	163,131,176,138	octave minus
	dc.l	octav_m
	dc.w	179,131,191,138	octave plus
	dc.l	octav_p
	dc.w	194,131,239,138	octave low
	dc.l	octav_l
;
	dc.w	163,141,176,148	YM tie minus
	dc.l	ymtie_m
	dc.w	179,141,191,148	YM tie plus
	dc.l	ymtie_p
	dc.w	194,141,239,148	YM tie low
	dc.l	ymtie_l
;
	dc.w	163,101,318,108	YM sound name edit
	dc.l	ym_name_yme
;
	dc.w	163,151,267,158	key mode all channels
	dc.l	k_mode
;
	dc.w	163,161,267,168	load ym sound
	dc.l	load_yme
;
	dc.w	163,171,267,178	save ym sound
	dc.l	save_yme
;
	dc.w	1,20,14,82	scroll left
	dc.l	yef_left
	dc.w	305,20,318,82	scroll right
	dc.l	yef_right
;
	dc.w	16,20,303,83	YM edit field
	dc.l	add_aef_point
;
	dc.w	1,101,13,108	einde attack minus
	dc.l	attac_m
	dc.w	15,101,28,108	einde attack plus
	dc.l	attac_p
;
	dc.w	1,111,13,118	einde sustain minus
	dc.l	susta_m
	dc.w	15,111,28,118	einde sustain plus
	dc.l	susta_p
;
	dc.w	1,121,13,128	einde release minus
	dc.l	relea_m
	dc.w	15,121,28,128	einde release plus
	dc.l	relea_p
;
	dc.w	1,131,13,138	h_env freq minus
	dc.l	henvf_m
	dc.w	15,131,28,138	h_env freq plus
	dc.l	henvf_p
	dc.w	31,131,108,138	h_env freq low
	dc.l	henvf_l
;
	dc.w	1,141,13,148	h_env type minus
	dc.l	henvt_m
	dc.w	15,141,28,148	h_env type plus
	dc.l	henvt_p
	dc.w	31,141,117,148	h_env type low
	dc.l	henvt_l
;
	dc.w	1,151,13,158	noise freq minus
	dc.l	noisf_m
	dc.w	15,151,28,158	noise freq plus
	dc.l	noisf_p
	dc.w	31,151,117,158	noise freq low
	dc.l	noisf_l
;
	dc.w	1,161,13,168	vibrato speed minus
	dc.l	vibrs_m
	dc.w	15,161,28,168	vibrato speed plus
	dc.l	vibrs_p
	dc.w	31,161,117,168	vibrato speed low
	dc.l	vibrs_l
; 
	dc.w	1,171,13,178	vibrato depth minus
	dc.l	vibrd_m
	dc.w	15,171,28,178	vibrato depth plus
	dc.l	vibrd_p
	dc.w	31,171,117,178	vibrato depth low(=high internally)
	dc.l	vibrd_h
;
	dc.w	1,181,13,188	interval 1 minus
	dc.l	intr1_m
	dc.w	15,181,28,188	interval 1 plus
	dc.l	intr1_p
	dc.w	31,181,117,188	interval 1 low
	dc.l	intr1_l
;
	dc.w	1,191,13,198	interval 2 minus
	dc.l	intr2_m
	dc.w	15,191,28,198	interval 2 plus
	dc.l	intr2_p
	dc.w	31,191,117,198	interval 2 low
	dc.l	intr2_l
;
	dc.w	163,181,197,198	tone mode toggle
	dc.l	tone_mode
;
	dc.w	200,181,234,198	hardware mode toggle
	dc.l	hardw_mode
;
	dc.w	237,181,271,198	noise mode toggle
	dc.l	noise_mode
;
	dc.w	111,131,117,138	hardware automatic frequency
	dc.l	hardw_auto
;
	dc.w	1,85,150,98	toggle edit mode
	dc.l	toggle_yef_mode
;
	dc.w	305,1,318,9	exit ym edit screen
	dc.l	main_scr
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;	***** BUTTON POSITIES HELP SCREEN *****
but_help
;
	dc.w	0,0,303,11	Scroll Up
	dc.l	scroll_up
;
	dc.w	0,188,303,199	Scroll Down
	dc.l	scroll_down
;
	dc.w	304,0,319,11	Exit
	dc.l	main_from_help
;
	dc.w	304,188,319,199	Exit
	dc.l	main_from_help
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;
;	***** BUTTON POSITIES MENUS *****
;
;	***** BUTTON POSITIES HOOFDMENU(=ADAMSKI) *****
but_adam
; er valt niks te klikken op de Adamski:
;
	dc.w	0,0,0,0
	dc.l	0
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;	***** BUTTON POSITIES DISK ACCESS MENU *****
but_da
	dc.w	103,12,114,19	main menu (& screen)
	dc.l	adam_restore
;
	dc.w	1,22,114,29	load song
	dc.l	load_song
;
	dc.w	1,32,114,39	save song
	dc.l	save_song
;
	dc.w	1,42,114,49	load voice set
	dc.l	load_vset
;
	dc.w	1,52,114,59	save voice set
	dc.l	save_vset
;
	dc.w	1,62,114,69	load ym sound
	dc.l	load_yms
;
	dc.w	1,72,114,79	save ym sound
	dc.l	save_yms
;
	dc.w	1,82,114,89	load sample
	dc.l	load_samp
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;
;		***** BUTTON POSITIES MEMORY MENU *****
but_mem
	dc.w	103,12,114,19	main menu (& screen)
	dc.l	adam_restore
;
	dc.w	93,22,114,29	Clear All
	dc.l	mem_all
;
	dc.w	93,32,114,39	Clear Song
	dc.l	mem_song
;
	dc.w	93,42,114,49	Clear Voice Set
	dc.l	mem_vst
;
	dc.w	93,52,114,59	Clear Samples
	dc.l	mem_sams
;
	dc.w	93,62,114,69	Clear Sample
	dc.l	mem_sam
;
	dc.w	93,72,114,79	Clear YM Sound
	dc.l	mem_yms
;
;
;	laatste item:
	dc.w	0,0,0,0
	dc.l	0
;
;
;		***** TOETSENTABEL *****
stop_keys	;	alle toetsen vanaf hier kunnen worden gedrukt bij STOP
;
	dc.w	82		Insert
	dc.l	ins_lin
;
	dc.w	83		Delete
	dc.l	del_lin
;
	dc.w	57		Space
	dc.l	space
;
	dc.w	14		Backspace
	dc.l	backspace
;
	dc.w	256+59		shift-F1 : Start Block
	dc.l	s_block
;
	dc.w	256+60		shift-F2 : End Block
	dc.l	e_block
;
	dc.w	256+61		shift-F3 : Paste Block
	dc.l	paste_block
;
	dc.w	256+62		shift-F4 : Delete Block
	dc.l	del_block
;
	dc.w	256+63		shift-F5 : Overlay Block
	dc.l	over_block
;
	dc.w	256+64		shift-F6 : Underlay Block
	dc.l	under_block
;
	dc.w	256+67		shift-F9 : Paste Reverse Block
	dc.l	paste_rev_block
;
	dc.w	109		1 op NumKeyPad : Start Block
	dc.l	s_block
;
	dc.w	110		2 op NumKeyPad : End Block
	dc.l	e_block
;
	dc.w	111		3 op NumKeyPad  : Paste Block
	dc.l	paste_block
;
	dc.w	106		4 op NumKeyPad  : Delete Block
	dc.l	del_block
;
	dc.w	107		5 op NumKeyPad  : Overlay Block
	dc.l	over_block
;
	dc.w	108		6 op NumKeyPad  : Underlay Block
	dc.l	under_block
;
	dc.w	256+99		shift-( op NumKeyPad : Overlay Block
	dc.l	over_block
;
	dc.w	256+100		shift-) op NumKeyPad : Underlay Block
	dc.l	under_block
;
;
;
;
play_keys	;	alle toetsen vanaf hier worden gebruit bij PLAY of REC
;
	dc.w	59		F1 : Cut Track
	dc.l	cut_track
;
	dc.w	60		F2 : Paste Track
	dc.l	paste_track
;
	dc.w	61		F3 : Cut Pattern
	dc.l	cut_pat
;
	dc.w	62		F4 : Paste Pattern
	dc.l	paste_pat
;
	dc.w	63		F5 : Overlay Track
	dc.l	overlay
;
	dc.w	64		F6 : Underlay track
	dc.l	underlay
;
	dc.w	256+65		shift-F7 : Transpose Track Down
	dc.l	trans_down
;
	dc.w	256+66		shift-F8 : Tranpose Track Up
	dc.l	trans_up
;
	dc.w	256+68		shift-F10 : Paste Reverse Track
	dc.l	paste_rev_track
;
	dc.w	99		( op NumKeyPad : Overlay Track
	dc.l	overlay
;
	dc.w	100		) op NumKeyPad : Underlay Track
	dc.l	underlay
;
	dc.w	101		/ op NumKeyPad : YM Sound Minus
	dc.l	sound_m
;
	dc.w	102		* op NumKeyPad : YM Sound Plus
	dc.l	sound_p
;
	dc.w	74		- op NumKeyPad : Transpose Track Down
	dc.l	trans_down
;
	dc.w	78		+ op NumKeyPad : Transpose Track Up
	dc.l	trans_up
;
	dc.w	256+74		- op NumKeyPad : Transpose Volume Down
	dc.l	trans_vol_down
;
	dc.w	256+78		+ op NumKeyPad : Transpose Volume Up
	dc.l	trans_vol_up
;
	dc.w	112		0 op NumKeyPad : Stop
	dc.l	p_stop
;
	dc.w	114		Enter op NumKeyPad : Pattern Play
	dc.l	p_play
;
	dc.w	77		Right Arrow
	dc.l	rite_ar
;
	dc.w	75		Left Arrow
	dc.l	left_ar
;
	dc.w	72		Up Arrow
	dc.l	up_ar
;
	dc.w	80		Down Arrow
	dc.l	down_ar
;
	dc.w	256+72		Up Arrow
	dc.l	up_ar
;
	dc.w	256+80		Down Arrow
	dc.l	down_ar
;
	dc.w	71		Clr Home : goto 00
	dc.l	goto_00
;
	dc.w	65		F7 : goto 00
	dc.l	goto_00
;
	dc.w	66		F8 : goto 10
	dc.l	goto_10
;
	dc.w	67		F9 : goto 20
	dc.l	goto_20
;
	dc.w	68		F10 : goto 30
	dc.l	goto_30
;
	dc.w	96		Backslash
	dc.l	change_pal
;
	dc.w	98		Help
	dc.l	help_scr
;
	dc.w	97		Undo
	dc.l	do_undo
;
;	laatste item
	dc.w	0
	dc.l	0
;
test_keys	;	toetsen vanaf hier worden gebruikt bij TEST PLAY in YM edit screen
	dc.w	83		Delete
	dc.l	del_aef_point
;
	dc.w	14		Backspace
	dc.l	clr_aef_point
;
	dc.w	59		F1 : Cut YM Sound
	dc.l	cut_yms
;
	dc.w	60		F2 : Paste YM Sound
	dc.l	paste_yms
;
	dc.w	101		/ op NumKeyPad : YM Sound Minus
	dc.l	sound_m
;
	dc.w	102		* op NumKeyPad : YM Sound Plus
	dc.l	sound_p
;
	dc.w	96		Backslash
	dc.l	change_pal
;
	dc.w	97		Undo
	dc.l	do_undo_yef
;
;	laatste item
	dc.w	0
	dc.l	0
;
help_keys
;
	dc.w	72		Scroll Up
	dc.l	scroll_up
;
	dc.w	80		Scroll Down
	dc.l	scroll_down
;
	dc.w	96		Backslash
	dc.l	change_pal
;
;	laatste item
	dc.w	0
	dc.l	0
;
;
;		****** BUTTON POSITIES YES_NO *****
yes_no_buts
	dc.w	6,16,24,29	Yes
	dc.w	0
;
	dc.w	70,16,88,29	No
	dc.w	1
;
;	laatste item
	dc.w	0,0,0,0
	dc.w	0
;
;
;
;		***** GRAPHICS *****
pals	dc.l	pal1,pal2,pal3,pal4,pal5,pal6,pal7,pal8,pal9,pal10

pal1	dc.w	$000,$320,$764,$542,$653,$210,$431,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal2	dc.w	$000,$121,$565,$343,$454,$010,$232,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal3	dc.w	$000,$222,$666,$444,$555,$111,$333,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal4	dc.w	$000,$021,$065,$043,$054,$010,$032,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal5	dc.w	$000,$200,$630,$410,$520,$100,$300,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal6	dc.w	$000,$622,$766,$744,$755,$711,$733,$700
	dc.w	$202,$707,$707,$707,$707,$707,$707,$707
pal7	dc.w	$000,$136,$577,$357,$467,$025,$247,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal8	dc.w	$000,$202,$606,$404,$505,$101,$303,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
pal9	dc.w	$000,$555,$222,$333,$222,$666,$444,$700
	dc.w	$777,$222,$666,$444,$555,$111,$333,$700
pal10	dc.w	$000,$220,$660,$440,$550,$110,$330,$700
	dc.w	$002,$006,$006,$006,$006,$006,$006,$006
;		***** HELP-SCREEN PALETTEN *****
help_pals
	dc.l	hpal1,pal2,pal3,pal4,pal5,pal6,pal7,pal8,pal9,pal10
hpal1	dc.w	$000,$320,$000,$700,$000,$077,$000,$700
	dc.w	$006,$006,$006,$006,$006,$006,$006,$006
;		***** RASTER PALET *****
raspal	dc.w	$777	loze kleur
	dc.w	$777,$766,$755,$744,$733,$722,$711,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100,$000
;		***** KLEUREN VAN LOGO *****
cur_logo_col
	dc.l	logo_cols
logo_cols	; kleur, aantal VBL's
	dc.w	$777,200,$666,6,$555,5,$444,4,$333,3,$222,2,$111,1
	dc.w	$000,1,$111,1,$222,2,$333,3,$444,4,$555,5,$666,6
	dc.w	-1
;
;		***** KLEUREN VAN DIST ****
cur_dist_col
	dc.l	dist_cols
dist_cols	; kleur, aantal VBL's
	dc.w	$700,100,$600,10,$500,10,$400,10,$300,10,$200,10,$100,10
	dc.w	$000,10,$010,10,$020,10,$030,10,$040,10,$050,10,$060,10
	dc.w	$070,100,$060,10,$050,10,$040,10,$030,10,$020,10,$010,10
	dc.w	$000,10,$001,10,$002,10,$003,10,$004,10,$005,10,$006,10
	dc.w	$007,100,$006,10,$005,10,$004,10,$003,10,$002,10,$001,10
	dc.w	$000,10,$100,10,$200,10,$300,10,$400,10,$500,10,$600,10
	dc.w	-1
;

;
mainpic		incbin	D:\DATA\MAIN.BP3	picture hoofdmenu
ymepic		incbin	D:\DATA\YMEDIT.BP3	picture ym edit screen
helpup		incbin	D:\DATA\HELPUP.BP3	bovenste deel help screen
helpdn		incbin	D:\DATA\HELPDOWN.BP3	onderste deel help screen
font1		incbin	D:\DATA\FONT1		font
yes_no_spr	incbin	D:\DATA\YES_NO.BP3	AreYouSure sprite
;
sprtab	dc.l	mouse_g			pointer naar muis pointer data
	ds.l	15
mouse_g	incbin	D:\DATA\M.MON		muis pointer
;
pm_2_spr
	dc.l	but_st,but_sp,but_pp,but_sr,but_pr,but_st,but_st
pm_2_routs
	dc.l	stop_keys,play_keys,play_keys,play_keys,play_keys,test_keys,test_keys

but_sp		incbin	D:\DATA\SONGPLAY.BP3
but_pp		incbin	D:\DATA\PATTPLAY.BP3
but_sr		incbin	D:\DATA\SONGREC.BP3
but_pr		incbin	D:\DATA\PATTREC.BP3
but_st		incbin	D:\DATA\NOPLAY.BP3
;
;
;
menu_data
	dc.l	but_adam,adam_spr	adamski
	dc.l	but_da,da_spr		disk access
	dc.l	but_mem,mem_spr		memory

da_spr		incbin	D:\DATA\DA.BP3		Disk Access Menu sprite
mem_spr		incbin	D:\DATA\MEMORY.BP3	Memory Menu sprite
adam_spr	incbin	D:\DATA\ADAMSKI.BP3	Adamski sprite
;
adam_line	dcb.b	8,5*16			stille lijn voor Adamski
;
;		***** DATA VOOR DEMO IN HELP-SCREEN *****
;
;		***** DISTORTION *****
curhi	dc.l	hitab

hitab	dc.b	0
	dc.b	-1
	dc.b	1,2,3,4,5,6,7,8,9,10,12,13,14,15,16
	dc.b	17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc.b	-1

dist_data	dc.l	chara

chara	incbin	D:\DATA\A_32_32.MON
	incbin	D:\DATA\A_32_32.MON
;
;
curdist	dc.l	distab

distab	dc.l	shiftab,shiftab+2,shiftab+4,shiftab+6,shiftab+8
	dc.l	shiftab+10,shiftab+12,shiftab+14,shiftab+16,shiftab+18
	dc.l	shiftab+20,shiftab+22,shiftab+24,shiftab+26,shiftab+28
	dc.l	shiftab+30,shiftab+32,shiftab+34,shiftab+36,shiftab+38
	dc.l	0

shiftab
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
	dc.w	4,5,6,7,8,8,8,7,6,5,4,3,2,1,0,0,0,1,2,3
;
;		***** BOUNCING LOGO *****
logo_pos_ptr
	dc.l	logo_y		pointer in y-tabel voor bouncing logo
logo_y	dc.b	20,21,22,23,25,28,31,28,25,23,22,21,20,-1
;
logo_data
	dc.l	logo1
logo1	incbin	D:\DATA\INSIGNIA.MON	logo van INSIGNIA
;
;
;		***** STRINGS IN LYNX FONT CODE ****
;
sam_ch1		dc.b	61,62,63,-1		SAMPLE bij channel 1 mode
yms_ch1		dc.b	34,22,28,-1		YMS bij channel 1 mode
rel_yms		dc.b	27,14,21,14,10,28,14,-1	RELEASE
att_yms		dc.b	10,29,29,10,12,20,42,-1	ATTACK (+spatie)
sus_yms		dc.b	28,30,28,29,10,18,23,-1	SUSTAIN
mute_on		dc.b	60,-1			speakertje bij mutes
mute_off	dc.b	42,-1			spatie bij mutes
sound_on	dc.b	24,23,42,-1		ON  bij YM edit screen
sound_off	dc.b	24,15,15,-1		OFF bij YM edit screen
mode_auto	dc.b	10,30,29,24,-1		AUTO op YM edit screen
pitch_str	dc.b	15,27,14,26,30,14,23,12,34,-1		FREQUENCY op YM edit screen bij Edit mode
amp_str		dc.b	10,22,25,21,18,29,30,13,14,-1		AMPLITUDE op YM edit screen bij Edit mode
;
;		***** LOAD/SAVE DATA *****
;
	even
file_mess
	dc.l	mess_lsong,mess_ssong,mess_lvset,mess_svset
	dc.l	mess_lyms,mess_syms,mess_lssam,error_occur
;	
mess_lsong	dc.b	'Load Song         :',0
mess_ssong	dc.b	'Save Song         :',0
mess_lvset	dc.b	'Load Voice Set    :',0
mess_svset	dc.b	'Save Voice Set    :',0
mess_lyms	dc.b	'Load YM Sound     :',0
mess_syms	dc.b	'Save YM Sound     :',0
mess_lssam	dc.b	'Load Sample       :',0
error_occur	dc.b	'An Error Occured  :',0
;
song_mask	dc.b	'*'
song_ext	dc.b	'.TRI',0
vset_mask	dc.b	'*.TVS',0
yms_mask	dc.b	'*'
yms_ext		dc.b	'.YMS',0
sam_mask	dc.b	'*.SPL',0
;
	even
error_messages
	dc.l	err1,err1,err2,err1,err11,err1,err1,err1,err1,err1	; Errors 0-9
	dc.l	err10,err11,err1,err13,err1,err15,err1,err1,err1,err1	; Errors 10-19
	dc.l	err1,err1,err1,err1,err1,err1,err1,err1,err1,err1	; Errors 20-29
	dc.l	err1,err1,err1,err33,err1,err1,err1,err1,err1,err1	; Errors 30-39
	dc.l	err1,err1,err1,err1,err1,err1,err15,err1,err1,err1	; Errors 40-49
	dc.l	err1,err1,err1,err1,err1,err1,err1,err57,err58,err59	; Errors 50-59
	dc.l	err1,err1,err1,err1,err1,err1,err1,err1,err1,err1	; Errors 60-69
;
err1	dc.b	'Disk Error',0
err2	dc.b	'Drive not Ready',0
err10	dc.b	'Write Fault',0
err11	dc.b	'Read Fault',0
err13	dc.b	'Write Protected Disk',0
err15	dc.b	'Unknown Device',0
err33	dc.b	'File not Found',0
err57	dc.b	'Memory Full',0
err58	dc.b	'Wrong File Format',0
err59	dc.b	'Disk Full',0                                        
;
;		***** HELP TEXT *****
;
help_len	equ	111
;
;		'12345678901234567890123456789012',13
help_txt
	dc.b	'Insignia Trisound Sequencer',13
	dc.b	'v1.0 nl',13
	dc.b	13
	dc.b	'main super def Coding:',13
	dc.b	' visible Perfexxion',13
	dc.b	'Additional Coding: MIQ',13
	dc.b	'Graphics: WIZ and MIQ',13
	dc.b	13,13
	dc.b	'Features:',13
	dc.b	13
	dc.b	'- fully MIDI compatible',13
	dc.b	'- first program ever to use',13
	dc.b	'  the magnificent VIP-OS',13
	dc.b	'- GEM item selector which allows',13
	dc.b	'  you to use Universal Item',13
	dc.b	'  Selector III and profit from',13
	dc.b	'  two(!) sooper dooper programs',13
	dc.b	'  at once!',13
	dc.b	'- Ability to mix samples',13
	dc.b	'  and ym sounds',13
	dc.b	'- very little CPU time needed',13
	dc.b	13,13,13
	dc.b	'**** Keyboard Shortcuts: ****',13
	dc.b	'F1  - Cut Track/YM sound',13
	dc.b	'F2  - Paste Track/ym sound',13
	dc.b	'F3  - Cut Pattern',13
	dc.b	'F4  - Paste Pattern',13
	dc.b	'F5  - Overlay Track',13
	dc.b	'F6  - Underlay Track',13
	dc.b	'F7  - Goto 00',13
	dc.b	'F8  - Goto 10',13
	dc.b	'F9  - Goto 20',13
	dc.b	'F10 - Goto 30',13
	dc.b	13
	dc.b	'Shifted:',13
	dc.b	'F1  - Start Block',13
	dc.b	'F2  - End Block',13
	dc.b	'F3  - Paste Block',13
	dc.b	'F4  - Delete Block',13
	dc.b	'F5  - Overlay block',13
	dc.b	'F6  - Underlay block',13
	dc.b	'F7  - Transpose up',13
	dc.b	'F8  - Transpose down',13
	dc.b	'F9  - Paste reverse block',13
	dc.b	'F10 - paste reverse track',13
	dc.b	13
	dc.b	'Numeric Key block:',13
	dc.b	'1   - Start Block',13
	dc.b	'2   - End Block',13
	dc.b	'3   - Paste Block',13
	dc.b	'4   - Delete Block',13
	dc.b	'5   - Overlay block',13
	dc.b	'6   - Underlay block',13
	dc.b	'+   - Transpose up',13
	dc.b	'-   - Transpose down',13
	dc.b	'shift + - transpose volume up',13
	dc.b	'shift - - transpose volume down',13
	dc.b	'/       - previous YM sound',13
	dc.b	'*       - next YM sound',13
	dc.b	'(       - overlay track',13
	dc.b	')       - underlay track',13
	dc.b	'shift ( - overlay track',13
	dc.b	'shift ) - underlay track',13
	dc.b	'0       - Stop',13
	dc.b	'Enter   - Pattern play',13
	dc.b	13
	dc.b	'Other keyboard shortcuts:',13
	dc.b	'\         - ACIEEeeeeeeeeeeeeEED',13
	dc.b	'ClrHome   - goto 00',13
	dc.b	'Space     - clear current note',13
	dc.b	'Backspace - clear with Step(!)',13
	dc.b	'Delete    - delete current note',13
	dc.b	'insert    - insert note',13
	dc.b	'arrows    - move cursor',13
	dc.b	'help      - enter help screen',13
	dc.b	'Undo      - undo last operation',13
	dc.b	13
	dc.b	13
	dc.b	'**** The digits: ****',13
	dc.b	'ym sound note:',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'&',13
	dc.b	'note',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'  &',13
	dc.b	'octave - range 0-7',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'   &&',13
	dc.b	'Portamento (tie) speed',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'     &&',13
	dc.b	'ym sound number - range 0-3f',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'       &',13
	dc.b	'ym sound volume - range 0-f',13
	dc.b	13
	dc.b	'c#2001dfA',13
	dc.b	'        &',13
	dc.b	'envelope value:',13
	dc.b	'A - start attack',13
	dc.b	'S - start sustain',13
	dc.b	'R - start release',13
	dc.b	'0 - continue',13
	dc.b	13
	dc.b	13
	dc.b	'sample note:',13
	dc.b	13
	dc.b	'SPL0c0100',13
	dc.b	'&&&',13
	dc.b	'signify sample note',13
	dc.b	13
	dc.b	'SPL0c0100',13
	dc.b	'    &',13
	dc.b	'replay frequency (hertz) 5-f',13
	dc.b	13
	dc.b	'SPL0c0100',13
	dc.b	'      &',13
	dc.b	'sample nummer - range 0-f',13
	dc.b	13
	dc.b	'SPL0c0100',13
	dc.b	'   & & &&',13
	dc.b	'all these digits are ignored',13
;
	dcb.b	13,25
;
sorry_rez
	dc.b	27,'E',10,' This program only runs in lo-res.',13,10
	dc.b	' Reboot in lo-res using preferences.',13,10
	dc.b	' Press any key...',13,10,0
;
;		***** AES CONTROL BLOCKS *****
;
	even
aespb	DC.l	control
	DC.l	global
	DC.l	int_in
	DC.l	int_out
	DC.l	addr_in
	DC.l	addr_out
;
;
;
	even
	section	BSS
;
	even
;
; channel B data-field
Bdata	
PSGfreq		equ	*-Bdata
		ds.w	1		frequentie die uiteindelijk in PSG moet
g_freq		equ	*-Bdata
		ds.w	1		globale (noot-) frequentie (waarom long? -upper word gaat naar PSG, lower word is achter de komma)
p_freq		equ	*-Bdata
		ds.w	1		huidige frequentie zonder tremolo(bij TIE belangrijk)
tie_stp		equ	*-Bdata
		ds.w	1		stap van tie
;
trem_offs	equ	*-Bdata
		ds.w	1		offset in tremolo tabel
vibr_speed	equ	*-Bdata
		ds.w	1		snelheid van tremolo
vibr_depth	equ	*-Bdata
		ds.w	1		diepte van tremolo
;
PSGvol		equ	*-Bdata
		ds.b	1		volume dat uiteindelijk in PSG moet
g_vol		equ	*-Bdata
		ds.b	1		globaal volume
;
		even
env_ptr		equ	*-Bdata
		ds.l	1		pointer naar envelope tabel
env_offs	equ	*-Bdata
		ds.w	1		offset in die tabel
env_att		equ	*-Bdata
		ds.w	1		offset einde attack
env_sus		equ	*-Bdata
		ds.w	1		offset einde sustain
env_rel		equ	*-Bdata
		ds.w	1		offset einde release
;
		even
pit_ptr		equ	*-Bdata
		ds.l	1		pointer naar pitch envelope tabel
pit_offs	equ	*-Bdata
		ds.w	1		offset in pitch envelope tabel
pit_att		equ	*-Bdata
		ds.w	1		offset einde pitch attack
pit_sus		equ	*-Bdata
		ds.w	1		offset einde pitch sustain
pit_rel		equ	*-Bdata
		ds.w	1		offset einde pitch release
pit_mode	equ	*-Bdata
		ds.b	1		<>0 : pitch staat aan
;
		even
noise_freq	equ	*-Bdata
		ds.w	1		frequentie ruis voor PSG
sound_mode	equ	*-Bdata
		ds.b	1		masker voor reg #7
;
h_env_type	equ	*-Bdata
		ds.b	1		type hardware envelope
		even
h_env_freq	equ	*-Bdata
		ds.w	1		frequentie hardware envelope
;
interval1	equ	*-Bdata
		ds.w	1		interval #1 in aantal noten
interval2	equ	*-Bdata
		ds.w	1		interval #2 in aantal noten
int_freq1	equ	*-Bdata
		ds.w	1		interval #1 in relatieve frequency
int_freq2	equ	*-Bdata
		ds.w	1		interval #2 in relatieve frequency
int_now		equ	*-Bdata
		ds.b	1		welke interval zijn we? (0=normaal, 1=interval #1, 2=interval #2)
;
instr_no	equ	*-Bdata		nummer huidige instrument (om te vergelijken)
		ds.b	1
silent		equ	*-Bdata		als byte<>0 moeten we sil zijn
		ds.b	1
		
v_s_s_len	equ	*-Bdata		lengte hele tabel om zo in 1 keer voice status structure voor channel C te definieren
;
	even
Cdata	ds.b	v_s_s_len		zelfde tabel als boven voor kanaal C
	even
Adata	ds.b	v_s_s_len		en nog een keer voor kanaal A
;
;	***** VOOR INTERRUPT VECTORS E.D. *****
	even
old_vbl		ds.l	1	oude VBL-interrupt pointer
old_kb		ds.l	1	oude KB-interrupt pointer
vbl_count	ds.w	1	aantal uitgevoerde VBL's van eigen soort
vbl_last_m	ds.w	1	vorige waarde van vbl_count van muis
vbl_wait_m	ds.w	1	hoeveel muis VBL's gewacht moet worden tot de volgende test van muis of toetsenbord
vbl_last_k	ds.w	1	vorige waarde van vbl_count van toetsen
vbl_wait_k	ds.w	1	hoeveel toets VBL's gewacht moet worden tot de volgende test van muis of toetsenbord
;
line_cnt	ds.w	1	hoeveel kleuren Timer B nog moet veranderen
rasmode		ds.b	1	=0 : wel rasters, <>0 : geen rasters
;
;	***** TOETSEN BORD VARIABELEN *****
key		ds.b	1	toets die nu ingedrukt wordt
key_raw		ds.b	1	waarde van keyboard
key_in		ds.b	1	laatst ingedrukte toets voor opneem routine
key_last	ds.b	1	laatst bekeken toets door record routine (wordt gebuikt voor attack/sustain/release check)
shiftmode	ds.b	1	status shift toetsen: 0=shift links, 1=shift rechts
no_key_repeat	ds.b	1	als dit <>0 is, wordt toets niet gecheckt (moet gezet worden bij functies zonder key-repeat)
;
;
;	***** MIDI VARIABELEN *****
midi_or_kb	ds.b	1	0=KeyBoard, 1=MIDI
;
midi_mode	ds.b	1	0=negeer data bytes, 1=data bytes zijn noot#, 2=velocity
midi_note	ds.b	1	noot# van midi
temp_note	ds.b	1	tijdelijke opslagplaats voor noot# van midi tot velocity komt
midi_velo	ds.b	1	velocity 
midi_in		ds.b	1	gezet = MIDI toets wordt ingedrukt
midi_cur	ds.b	1	toets van midi die nu ingedrukt wordt
;
;	***** MUIS VARIABELEN *****
mouse_stat	;		adres nu volgende structure
mousek		ds.b	1	muis knop status
mrelx		ds.b	1	relatieve x positie muis
mrely		ds.b	1	relatieve y positie muis
		even
mousex		ds.w	1	x positie muis
mousey		ds.w	1	y positie muis
mouse_ptr	ds.l	1	pointer naar mouse_stat
nxt_mouse	ds.w	1	aftel register voor aantal bytes
rest_mouse	ds.l	1	pointer naar waar muis geupdate wordt
no_mouse_repeat	ds.b	1	als dit <>0 is, kan er met de muis niet geklikt worden
;
;	***** ALGEMENE UPDATE EN BUTTON VARIABELEN *****
		even
mouse_routs	ds.l	1	pointer naar button/rout tabel scherm
menu_routs	ds.l	1	pointer naar button/rout tabel menu's
key_routs	ds.l	1	pointer naar key/rout tabel toetsen
update_rout	ds.l	1	pointer naar update routine

menu_mode	ds.b	1	geeft menu nummer aan
pls_flag	ds.b	1	als deze vlag gezet wordt, worden in de VBL de pattern regels getekend
pls_mode	ds.b	1	als deze vlag gezet is, worden de pattern regels niet getekend
led_mode	ds.b	1	als deze vlag gezet is, mag LED niet knipperen i.v.m. TOS
graf_mode	ds.b	1	geeft aan of er laad/save meldingen neergezet moeten worden (bit 4=geef ook filenaam)
demo_mode	ds.b	1	als deze vlag gezet is. moet het demo getekend worden
done_something	ds.b	1	als een opneem routine data neergezet heeft wordt deze vlag gezet zodat stop routine weet dat er doorgegaan moet worden
;
;	***** VOOR LAAD EN SAVE ROUTINES *****
		even
handle		ds.w	1	file handle
signtest	ds.l	1	merkteken voor file wordt hier bekeken
input_buf	ds.b	128	file naam
;
song_path	ds.b	128	path voor song
song_fname	ds.b	14	naam voor song
vset_path	ds.b	128	etc.
vset_fname	ds.b	14	etc.
yms_path	ds.b	128
		even
yms_fname	ds.b	14
sam_path	ds.b	128
		even
sam_fname	ds.b	14
;	***** AES VARIABELEN *****
	even
ap_id		ds.w	1	ap_id, wordt door appl_init teruggegeven
;
global		ds.w	16		AES
control		ds.w	10
int_in		ds.w	128
int_out		ds.w	128
addr_in		ds.l	128
addr_out	ds.l	128
;
;
;	***** VOOR BLOCK FUNCTIONS *****
block_var_start
block_flag	ds.w	1	geeft inhoud van block buffer aan :
;				0 = leeg, 1 = track, 2 = pattern, 3 = block
block_valid	ds.b	1	geeft een of volgende variabelen kloppen :
;				bits : 0=start OK, 1=end OK
		even
block_spat	ds.w	1	pattern block start
block_slin	ds.w	1	pattern regel block start
block_scur	ds.w	1	cursor positie block start

block_epat	ds.w	1	pattern block end
block_elin	ds.w	1	pattern regel block end
block_ecur	ds.w	1	cursor positie block end

buf_len		ds.w	1	lengte block buffer
		even
block_buf	ds.b	note_len*pat_len	ruimte voor blocks bij kopieren
block_var_end
;
;	***** VOOR UNDO FUNCTIONS *****
undo_block	ds.b	block_var_end-block_var_start
		even
undo_name_ptr	ds.l	1			wijst naar plaats waar naam van ym sound geresotred moet worden
undo_yms_ptr	ds.l	1			wijst naar plaats waar ym sound gerestored moet worden
undo_pat_ptr	ds.l	1			wijst naar plaats waar pattern gerestored moet worden

undo_ymsname	ds.b	8			naam van opgeslagen ym sound
undo_pat	ds.b	note_len*pat_len	undo-buffer voor pattern
undo_yms	ds.b	i_total_len		undo-buffer voor ym sound
undo_valid	ds.b	1			=0 : deze buffers zijn ONgeldig, <>0 : deze buffers zijn geldig
;
;	***** VOOR YmEditField ROUTINES *****
		even
yef_pos		ds.w	1	positie van YEF (0 t/m 196)
ym_ptr		ds.l	1	pointer naar YM sound
old_speed	ds.w	1	opslag voor speed bij ingaan YM edit screen
old_B_silent	ds.b	1	opslag voor B mute mode bij ingaan YM edit
yef_mode	ds.b	1	0=edit amplitude, -1=edit pitch
;
;
;	***** VOOR HELP SCREEN *****
		even
help_pos	ds.w	1	regel nummer in HELP file
logo_color	ds.w	1	als deze teller 0 wordt, wordt er een nieuwe kleur voor het logo gebruikt
dist_color	ds.w	1	als deze teller 0 wordt, wordt er een nieuwe kleur voor de dist gebruikt
;
;	***** VOOR PRINT & ASCII INVOER ROUTINES *****
		even
charx		ds.w	1	voor letter printen: x pos
chary		ds.w	1	y pos

stringx		ds.w	1	x positie string
stringy		ds.w	1	y positie string
asc_cur		ds.w	1	cursor positie binnen string
asc_string	ds.l	1	pointer naar invoer string
asc_mode	ds.b	1	0=normaal, <>0=er wordt een string ingevoerd
		even
long_dec	ds.b	7	hier wordt decimale string gezet bij dec-uitvoer
;
;	***** VOOR REC & PLAY ROUTINES : *****
		even
note_count	ds.w	1		voordeler voor noot-snelheid (ALTIJD beginnen met 1)
cursor		ds.w	1		positie inspeel cursor
;
patmode		ds.w	1		pattern mode (0=stop, 1=song play, 2=pattern play, 3=song rec, 4=pattern rec, 6=test play)
rec_mode	ds.b	1		hoe er opgenomen moet worden op kanaal 1(0=SAM, 1=YMS)
key_mode	ds.b	1		hoe moeten YM sounds opgenomen worden : (0=Attack & Release, 1=Attack only, 2=Sustain only)
pause_mode	ds.b	1		als dit gezet is, wordt er niet verder gespeeld, FX worden wel gedaan
;
ym_sound	ds.b	1		nummer huidige ym sound
ym_vol		ds.b	1		volume ym sound
ym_tie		ds.b	1		aantal noten dat getied moet worden
octave		ds.b	1		base octave; er kunnen maar 3 octaven op toetsenbord 
		even
s_step		ds.w	1		stap die gemaakt wordt als bij stop een teken wordt ingevoerd
cur_sam		ds.w	1		nummer huidige sample
;
;	***** POSITION/PATTERN VARIABELEN *****
		even
pos_now		ds.w	1		huidige POSITION
pat_now		ds.w	1		huidige PATTERN
pat_tab		ds.l	120		tabel met pointers naar patterns
pat_base	ds.l	1		pointer naar BEGIN huidige pattern
pat_lin		ds.w	1		pattern regel
pat_ptr		ds.l	1		pointer naar huidige plaats in patter(=pat_base+14*

pat_restor1	ds.l	1		pointer naar pattern regel waar restore buffer naar toe gekopieerd moet worden
pat_resbuf1	ds.b	note_len	pseudo buffer om met muziek mee te kunnen spelen
		even
pat_restor2	ds.l	1		copieer volgorde: 3->restore, 2->3, 1->2, now->1
pat_resbuf2	ds.b	note_len	pointers        : restor2->restor3, restor1->restor2, #now->restor1
		even
pat_restor3	ds.l	1
pat_resbuf3	ds.b	note_len
		even
pat_test	ds.b	note_len	buffer voor noten van test play
;
env_0		ds.b	10		10 lege bytes als valse envelope
;
;		***** ALGEMENE VARIABELEN *****
		even
phys_0		ds.l	1
		IFEQ	executable
oldrez		ds.w	1
		ENDC
oldpal		ds.w	16
pal_count	ds.w	1	geeft palet nummer aan

ssp	ds.l	1
	ds.b	4096
mystack	ds.b	32
	even
sprbuf	ds.b	32*32	buffer voor muis pointer
;
	even
sam_tab		ds.l	32	pointers naar samples (laatste 16 zijn loze pointers)
sam_tot		ds.l	1	totale lengte samples
;
;		***** YM SOUND DATA & SAMPLES *****
		even
voice_set
ym_names	ds.b	64*8		ym sound namen
ym_sounds	ds.b	64*i_total_len	reserveer ruimte voor ym sounds
;			64		=  aantal ym sounds (0-$3f)
;			i_total_len	=  ruimte voor YM sound
sam_names	ds.b	16*8	sample namen
;			16   =  aantal samples
;			8    =  lengte 1 naam
		even
sam_len		ds.l	32		sample lengtes (laaste 16 zijn loze lengtes)
sam_rates	ds.b	16		sample rates
		IFEQ	executable
sam_first	ds.b	20*1024		buffer voor samples (20K-stripped version)
		ELSEIF
sam_first	ds.b	128*1024	buffer voor samples (128K)
		ENDC
sam_last	;			adres voorbij sample
;		***** SONG DATA *****
		even
song_name	ds.b	8		naam van liedje in ASCII
		even
song
speed		ds.w	1		snelheid
restart		ds.w	1		restart position
last_pos	ds.w	1		aantal positions (max. 120)
last_pat	ds.w	1		aantal patterns
pos_tab		ds.b	120		positions
		even
patterns	ds.b	max_pat*pat_len*note_len	de patterns
pat_last
;
		even
misc_buf	ds.b	32*1024		buffer voor verschillende doeleinden: sample laden, achtergrond opslaan, scherm opbouwen
misc_buf_end
;
;
	end 
;






