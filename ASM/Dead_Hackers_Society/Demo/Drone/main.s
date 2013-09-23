; DEAD HACKERS SOCIETY
;
; Atari ST/e synclock demosystem v1.0
; September 10, 2011
;
; main.s

music_sndh:	equ	0				;Play SNDH-music
music_sndh_fx:	equ	0				;0=SNDH music has no timer effects (fullscreen OK!)  1=SNDH music has timer effects (no fullscreen!)
music_ym:	equ	0				;Play YM3-music
music_dma:	equ	0				;Play DMA-sample sequence music (STe only and need sys/loader.s included)
music_stream:	equ	1				;Play DMA-streamed music (STe only and need sys/loader.s included)
music_ymdigi8:	equ	0				;Play YM 8-bit sample sequence music (need sys/loader.s included)
music_mod:	equ	0				;Play module (50 kHz STe, Lance)
code_dump:	equ	0				;Dump code buffer to file at exit (dump.bin)
init_finish:	equ	0				;Show colours during/after runtime init
ste_demo:	equ	1				;1=STe 0=ST (do some extra save/restore of STe registers if STe-demo and exit if run on ST)
falcon_compat:	equ	0				;1=Use Falcon video-setup 0=Use only ST/STe video-setup (Falcon mode works only for non-synclock stuff)
show_infos:	equ	0				;1=Show startup infos 0=Show nothing at startup
sincos:		equ	1				;1=Include sin/cos table 0=Do not include it
bufsize:	equ	1024*1200			;Size of generic bss, should be even by 1024 (for speed optimized clear loop)
codesize:	equ	1024*150			;Size of buffer for generated code
screensize:	equ	1024*64				;Size of one screen buffer (should be even by 256!)

; DRONE
; Sommarhack 2012 demo
; STe 4 MB with harddisk
;
; Streaming soundtrack "cubeism" by Cerror
; Multicolour/fullscreen pictures by Ultradialectics
; Code and other graphics by Evil


block_numfr:	equ	216

;-------------- Demo parts to enable/disable
part_logo:	equ	1
part_checker:	equ	1
part_block:	equ	1
part_29k:	equ	1
part_swirl:	equ	1
part_fulltc:	equ	1
part_pic31:	equ	1
part_crosstw:	equ	1
part_bump:	equ	1
part_stars:	equ	1
part_end:	equ	1



		section	text

		bra	begin

		dc.b	'Hey sleezebag, instead of going thru the code this way, '
		dc.b	'rename the file data\yeah.dat to yeah.zip and depack it. '
		dc.b	'It should build with vasm and produce a fully working binary.'
		even

begin:		include	'sys/init.s'			;Setup demosystem
		include	'sys/mainloop.s'		;Mainloop
		include	'sys/exit.s'			;Exit demosystem
		include	'sys/cookie.s'			;Check computer type
		include	'sys/vbl.s'			;Demo sequencer
		include	'sys/timers.s'			;Top border sync and placeholders
		include	'sys/common.s'			;Common routines
		include	'sys/music.s'			;Music includes
	ifne	falcon_compat				;
		include	'sys/falcon.s'			;Falcon video compatibility
	endc						;

;-------------- Optional includes
		include	'sys/loader.s'			;File loader
		include	'sys/fade.s'			;Generic fade routines
;		include	'sys/sscrl.s'			;Syncscroller
;		include	'sys/c2p.s'			;C2P precalc table
;		include	'sys/lz77_000.s'		;LZ77 depacker (ray/tscc)
;		include	'sys/ice.s'			;ICE depacker (axe/delight)
;		include	'sys/mth68000.s'		;Floating point library for 68000 (ray/tscc)




;-------------- User demopart includes


	ifne	part_end
		include	'end/end.s'
	endc

	ifne	part_pic31
		include	'pic31/pic31.s'
	endc

	ifne	part_logo
		include	'logo/logo.s'
	endc

	ifne	part_crosstw
		include	'crosstw/crosstw.s'
	endc

	ifne	part_swirl
		include	'swirl/swirl.s'
	endc

	ifne	part_29k
		include	'29k/29k.s'
	endc

	ifne	part_fulltc
		include	'fulltc/fulltc.s'
	endc

	ifne	part_bump
		include	'bump/bump.s'
	endc

	ifne	part_stars
		include	'stars/stars.s'
	endc

	ifne	part_block
		include	'block/block.s'
	endc

	ifne	part_checker
		include	'checker/checker.s'
	endc



;-------------- User demopart inits

initlist:
	move.l	#empty+256,d0
	clr.b	d0
	move.l	d0,empty_adr

	ifne	part_end
		jsr	end_init
	endc

	ifne	part_pic31
		jsr	pic31_init
	endc

	ifne	part_logo
		jsr	logo_init
	endc

	ifne	part_crosstw
		jsr	crosstw_init
	endc

	ifne	part_29k
		jsr	pic29k_init
	endc

	ifne	part_swirl
		jsr	swirl_init
	endc

	ifne	part_fulltc
		jsr	fulltc_init
	endc

	ifne	part_bump
		jsr	bump_init
	endc

	ifne	part_block
		jsr	block_init
	endc

	ifne	part_checker
		jsr	checker_init
	endc

	ifne	part_stars
		jsr	stars_init
	endc



		rts


		section	data

;-------------- Demopart sequence list

;format
;dc.l vbls,timer_a_delay,timer_a_div,vbl_routine,timer_a_routine,main_routine
;Timer A delay/div can be left zero for non-synclock screens

partlist:

	ifne	part_logo
		dc.l	50,0,0,dummy,dummy,logo_runtime_init
		dc.l	185,97,4,logo_fadein,logo_ta,dummy
		dc.l	535,97,4,logo_vbl,logo_ta,logo_main

		dc.l	15,0,0,white_pal,dummy,logo_small_runtime_init
		dc.l	490-75,97,4,logo_small_in,logo_small_ta,logo_small_main
		dc.l	150,97,4,logo_small_out,logo_small_ta,logo_small_main
	endc

	ifne	part_checker
		dc.l	15,0,0,dummy,dummy,checker_runtime_init
	endc

	ifne	part_block
		dc.l	60,0,0,dummy,dummy,block_runtime_init_1a
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load3
		endc


	ifne	part_checker
		dc.l	690,97,4,checker_vbl,checker_ta,checker_main
		dc.l	110,97,4,checker_vbl2,checker_ta,checker_main
		dc.l	2,0,0,dummy,dummy,checker_runtime_exit
	endc

	ifne	part_block
		dc.l	15,0,0,dummy,dummy,block_runtime_init_1b
		dc.l	770,97,4,block_vbl_fadein,block_ta,block_main
		dc.l	50,97,4,block_vbl_fadeout,block_ta,block_main
		dc.l	2,0,0,dummy,dummy,block_runtime_exit
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load4
		endc


	ifne	part_29k
		dc.l	25,0,0,dummy,dummy,pic29k_runtime_init_01
		dc.l	975-375-50-50,97,4,pic29k_fadein1_vbl,pic29k_ta,pic29k_main
		dc.l	375+50,97,4,pic29k_fadeout1_vbl,pic29k_ta,pic29k_main
	endc



	ifne	part_fulltc
		dc.l	10,0,0,dummy,dummy,fulltc_runtime_init
	endc

	ifne	part_swirl
		dc.l	145,0,0,dummy,dummy,swirl_runtime_init
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load5
		endc


	ifne	part_swirl
		dc.l	5,0,0,dummy,dummy,dummy
		dc.l	685,97,4,swirl_vbl,swirl_ta,swirl_main_in
		dc.l	80-5,97,4,swirl_vbl,swirl_ta,swirl_main_out
	endc

	ifne	part_fulltc
		dc.l	30,0,0,dummy,dummy,fulltc_runtime_init2
		dc.l	820,97,4,fulltc_vbl_in,fulltc_ta,fulltc_main
		dc.l	130,97,4,fulltc_vbl_out,fulltc_ta,fulltc_main
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load6
		endc


	ifne	part_pic31
		dc.l	20+30,0,0,dummy,dummy,pic31_runtime_init
		dc.l	500-30-15-40,97,4,pic31_vbl_in,pic31_ta,pic31_main
		dc.l	100,97,4,pic31_vbl_out,pic31_ta,pic31_main
	endc

	ifne	part_crosstw
		dc.l	150,0,0,dummy,dummy,crosstw_runtime_init
		dc.l	1425-50-200+15+40,97,4,crosstw_vbl,crosstw_ta,crosstw_main
		dc.l	200,97,4,crosstw_vbl,crosstw_ta,crosstw_main_out
	endc


		ifne	music_stream
			dc.l	75,255,4,black_pal,dummy,music_stream_load7
		endc


	ifne	part_29k
		dc.l	25,0,0,dummy,dummy,pic29k_runtime_init_02
		dc.l	500-75-60,97,4,pic29k_fadein2_vbl,pic29k_ta,pic29k_main
		dc.l	110,97,4,pic29k_fadeout2_vbl,pic29k_ta,pic29k_main
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load8
		endc


	ifne	part_block
		dc.l	60,0,0,dummy,dummy,block_runtime_init_2a
	endc

	ifne	part_bump
		dc.l	50,0,0,dummy,dummy,bump_runtime_init
		dc.l	50,97,4,bump_vbl_in,bump_ta,bump_main
		dc.l	650,97,4,bump_vbl,bump_ta,bump_main
		dc.l	50,97,4,bump_vbl_out,bump_ta,bump_main
	endc

	ifne	part_block
		dc.l	15,0,0,black_pal,dummy,block_runtime_init_2b
		dc.l	755,97,4,block_vbl_fadein,block_ta,block_main
		dc.l	50,97,4,block_vbl_fadeout2,block_ta,block_main
		dc.l	2,0,0,dummy,dummy,block_runtime_exit_2
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load9
		endc


	ifne	part_pic31
		dc.l	20+30,0,0,dummy,dummy,pic31_runtime_init_2
		dc.l	545-30-75-18,97,4,pic31_vbl_in2,pic31_ta,pic31_main
		dc.l	100,97,4,pic31_vbl_out2,pic31_ta,pic31_main
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load10
		endc


	ifne	part_stars
		dc.l	40+50,0,0,dummy,dummy,stars_runtime_init
		dc.l	18+370+75-50-50-10,97,4,stars_vbl_in,stars_ta,stars_main1
		dc.l	50+10,97,4,stars_vbl_out,stars_ta,stars_main1

		dc.l	400-50,97,4,stars_vbl_in,stars_ta,stars_main2
		dc.l	50+10,97,4,stars_vbl_out,stars_ta,stars_main2

		dc.l	400,97,4,stars_vbl_in,stars_ta,stars_main3
		dc.l	50+10,97,4,stars_vbl_out,stars_ta,stars_main3
	endc


		ifne	music_stream
			dc.l	75,255,4,dummy,dummy,music_stream_load11
		endc


	ifne	part_end
		dc.l	100,0,0,dummy,dummy,end_runtime_init
		dc.l	1700,97,4,end_vbl,end_ta,end_main
	endc


		dc.l	300,255,4,dummy,dummy,dummy
		dc.l	-1,255,4,dummy,dummy,exit


;-------------------------------------------------------------------------------
; structs



		rsreset
checker_bg:	rs.b	512*512/2*2		;256k
checker_txt:	rs.w	16*512			;16k
checker_txt2:	rs.w	16*512			;16k
checker_ylist:	rs.w	273			;1k
checker_bgch:	rs.b	512*2			;1k
block_gfx:	rs.w	16*16*8			;4k
block_anim:	rs.b	48*34*block_numfr	;350k
bump_t1:	rs.l	64*64*3			;48k
bump_t2:	rs.l	64*64*3			;48k
bump_txt:	rs.b	64*64+1024+54		;6k
bump_ofs:	rs.b	7280			;8k
bump_dl1:	rs.l	280			;2k
bump_dl2:	rs.l	280			;2k
bump_disted_dl:	rs.l	280			;2k
bump_dist:	rs.l	280*2			;4k
bump_pal:	rs.w	16			;0
bump_fades:	rs.w	16*48*2			;?

		rsreset
fulltc_bg:	rs.b	32+400/2*8		;2k	palette+4 bitplanes 400x8 pixels
fulltc_txt:	rs.w	128*128*3		;100k	128x128 16-bit texture (3 copies)
fulltc_overlay:	rs.b	32+(384*210/2)		;41k	palette+4 bitplanes 384x210 pixels
fulltc_ofs:	rs.w	48*53			;6k	ofsmap data
fulltc_chunky:	rs.w	48*53			;6k	=155k fulltc
swirl_rander:	rs.b	400/8*273*30		;410k
swirl_rander2:	rs.b	400/8*273*30		;410k
swirl_pals:	rs.w	8*1100			;18k
swirl_greets:	rs.b	368*64*10/8		;30k
swirl_greets_e:	rs.b	368*64/8		;3k
swirl_grfade:	rs.w	8*48			;1k	=872k swirl



empty_adr:	dc.l	0
empty:		dcb.b	1024+256,$00


		section	text

