; DEAD HACKERS SOCIETY
;
; Atari ST/e synclock demosystem v1.0
; September 10, 2011
;
; main.s

music_sndh:	equ	1				;Play SNDH-music
music_sndh_fx:	equ	0				;0=SNDH music has no timer effects (fullscreen OK!)  1=SNDH music has timer effects (no fullscreen!)
music_ym:	equ	0				;Play YM3-music
music_dma:	equ	0				;Play DMA-sample sequence music (STe only and need sys/loader.s included)
music_ymdigi8:	equ	0				;Play YM 8-bit sample sequence music (need sys/loader.s included)
music_mod:	equ	0				;Play module (50 kHz STe, Lance)
code_dump:	equ	0				;Dump code buffer to file at exit (dump.bin)
init_finish:	equ	0				;Show colours during/after runtime init
ste_demo:	equ	1				;1=STe 0=ST (do some extra save/restore of STe registers if STe-demo and exit if run on ST)
falcon_compat:	equ	0				;1=Use Falcon video-setup 0=Use only ST/STe video-setup (Falcon mode works only for non-synclock stuff)
show_infos:	equ	1				;1=Show startup infos 0=Show nothing at startup
sincos:		equ	0				;1=Include sin/cos table 0=Do not include it
bufsize:	equ	1024*0				;Size of generic bss, should be even by 1024 (for speed optimized clear loop)
codesize:	equ	1024*100			;Size of buffer for generated code
screensize:	equ	1024*64				;Size of one screen buffer (should be even by 256!)

;-------------- Demo parts to enable/disable
stlow_dblbuf:	equ	1				;
stlow_tribuf:	equ	1				;Need sys/c2p.s included
fullscr_st:	equ	1				;Need sys/fade.s included
fullscr_ste:	equ	1				;Need sys/fade.s included
syncscrl:	equ	1				;Need sys/sscrl.s and sys/fade.s included
syncscrl_fs:	equ	1				;Need sys/sscrl.s and sys/fade.s included
spec512:	equ	1				;


		section	text

begin:		include	'sys/init.s'			;Setup demosystem
		include	'sys/mainloop.s'		;Mainloop
		include	'sys/exit.s'			;Exit demosystem
		include	'sys/cookie.s'			;Check computer type
		include	'sys/vbl.s'			;Demo sequencer
		include	'sys/timers.s'			;Top border sync and placeholders
		include	'sys/music.s'			;Music includes
		include	'sys/common.s'			;Common routines
	ifne	falcon_compat				;
		include	'sys/falcon.s'			;Falcon video compatibility
	endc						;

;-------------- Optional includes
;		include	'sys/loader.s'			;File loader
		include	'sys/fade.s'			;Generic fade routines
		include	'sys/sscrl.s'			;Syncscroller
		include	'sys/c2p.s'			;C2P precalc table
;		include	'sys/lz77_000.s'		;LZ77 depacker (ray/tscc)
;		include	'sys/ice.s'			;ICE depacker (axe/delight)
;		include	'sys/mth68000.s'		;Floating point library for 68000 (ray/tscc)




;-------------- User demopart includes

	ifne	stlow_dblbuf
		include	'stlow.dbl/stlow.s'
	endc

	ifne	stlow_tribuf
		include	'stlow.tri/stlow.s'
	endc

	ifne	fullscr_st
		include	'fullscr.st/fullscr.s'
	endc

	ifne	fullscr_ste
		include	'fullscr.ste/fullscr.s'
	endc

	ifne	syncscrl
		include	'syncscrl/syncscrl.s'
	endc

	ifne	syncscrl_fs
		include	'syncscrl.fs/syncscrl.s'
	endc

	ifne	spec512
		include	'spec512/spec512.s'
	endc

;-------------- User demopart inits

initlist:
	ifne	stlow_dblbuf
		jsr	stlow_init			;Do inits before demo begin
	endc

	ifne	stlow_tribuf
		jsr	stlow_tri_init
	endc

	ifne	fullscr_st
		jsr	fullscr_st_init
	endc

	ifne	fullscr_ste
		jsr	fullscr_ste_init
	endc

	ifne	syncscrl
		jsr	sscrl_init
		jsr	syncscrl_init
	endc

	ifne	syncscrl_fs
		jsr	sscrl_init
		jsr	syncscrl_fs_init
	endc

	ifne	spec512
		jsr	spec512_init
	endc

		rts


		section	data

;-------------- Demopart sequence list

;format
;dc.l vbls,timer_a_delay,timer_a_div,vbl_routine,timer_a_routine,main_routine
;Timer A delay/div can be left zero for non-synclock screens

partlist:

;------------- ST-LOW double buffer example
	ifne	stlow_dblbuf
		dc.l	10,0,0,dummy,dummy,stlow_runtime_init			;Do inits needed while demo runs
		dc.l	1000,0,0,stlow_vbl,dummy,stlow_main			;Run demopart
	endc

;------------- ST-LOW tripple buffer example
	ifne	stlow_tribuf
		dc.l	200,0,0,dummy,dummy,stlow_tri_runtime_init
		dc.l	1000,0,0,stlow_tri_vbl,dummy,stlow_tri_main
	endc

;------------- Fullscreen example
	ifne	fullscr_st
		dc.l	30,0,0,dummy,dummy,fullscr_st_runtime_init
		dc.l	1000,97,4,fullscr_st_vbl,fullscr_st_ta,fullscr_st_main
	endc

;------------- Optimized fullscreen example (STe only)
	ifne	fullscr_ste
		dc.l	30,0,0,dummy,dummy,fullscr_ste_runtime_init
		dc.l	1000,97,4,fullscr_ste_vbl,fullscr_ste_ta,fullscr_ste_main
	endc

;------------- Syncscroll example
	ifne	syncscrl
		dc.l	20,0,0,dummy,dummy,syncscrl_runtime_init
		dc.l	1000,97,4,syncscrl_vbl,syncscrl_ta,syncscrl_main
	endc

;------------- Syncscroll in fullscreen example
	ifne	syncscrl_fs
		dc.l	30,0,0,dummy,dummy,syncscrl_fs_runtime_init
		dc.l	1000,97,4,syncscrl_fs_vbl,syncscrl_fs_ta,syncscrl_fs_main
	endc

;------------- Spectrum 512 displayer example
	ifne	spec512
		dc.l	20,0,0,dummy,dummy,spec512_runtime_init
		dc.l	1000,190,4,spec512_vbl,spec512_ta,spec512_main
	endc


		dc.l	-1,255,4,black_pal,dummy,dummy
		dc.l	-1,255,4,dummy,dummy,exit



		section	text

