;    ___      ___      ___   
;   /\  \    /\__\    /\  \  
;  /::\  \  /:/__/_  /::\  \ 
; /:/\:\__\/::\/\__\/\:\:\__\
; \:\/:/  /\/\::/  /\:\:\/__/
;  \::/  /   /:/  /  \::/  / 
;   \/__/    \/__/    \/__/  
;
;    DEAD HACKERS SOCIETY
;
; Atari ST/e synclock demosystem v0.3
; January 6, 2008
;
; fullmain.s
; 
; Anders Eriksson
; ae@dhs.nu
;

; Alternative Party 2009 STe demo - "Cernit Trandafir"
;
; Music - 505
; Graphics - Proteque
; Code - Nerve, Gizmo, Evil


scr_w:		equ	230			;linewidth of fullscreen
scr_h:		equ	280			;max lines visible

hatari:		equ	0			;Hatari specific codepath (bug workarounds)
hatari_speedup:	equ	0			;Hatari specific speedup during init

music_sndh:	equ	0			;Play a sndh music file
music_ym:	equ	0			;Play an ym-music file (YM3 only)
music_mod:	equ	0
music_dma:	equ	1			;Play a DMA-sample sequence (STe only)
music_ofs:	equ	0			;0 = play music from the beginning or ffwd to #VBL

floppy:		equ	0			;1=build floppy version with force media change and 12 kHz music
init_finish:	equ	0			;show colours when runtime init is working and finished

;		enable/disable parts
part_parall:	equ	1 ;music_ofs 0		;fullscreen tripple layer parallax credits
part_linezoom:	equ	1 ;music_ofs 1970	;fullscreen scanline zoomer
part_skyline:	equ	1 ;3088			;fullscreen skyline silhouette
part_kube:	equ	1 ;4638			;fullscreen repeated twisted kubes
part_spr3d_a:	equ	1 ;7208			;3D BLiTTER sprites
part_spec29k:	equ	1 ;9382			;320x273 29k colour image
part_spr3d_b:	equ	1			;for ffwd
part_shadevec:	equ	1			;fullscreen shaded vectors
part_bg1x1:	equ	1			;1x1 background with 2x2 texturemapper on top (9k bss to kill)
part_fullrot:	equ	1			;fullscreen rotozoom (possibly pack ofsmaps with ice ?)

part_spr3d:	equ	1
		section	text

begin:		include	'sys/fullinit.s'		;setup demosystem


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM MAINLOOP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainloop:	tst.w	vbl_counter
		beq.s	mainloop

		move.l	a0,-(sp)
		move.l	main_routine,a0
		jsr	(a0)
		move.l	(sp)+,a0

		clr.w	vbl_counter
	
		cmp.b	#$39,$fffffc02.w		;space?
		bne.s	mainloop

		include	'sys/fullexit.s'		;exit demosystem

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM VBL
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl:
		clr.b	$fffffa19.w			;timer-a setup
		move.b	timera_delay+3,$fffffa1f.w	;
		move.b	timera_div+3,$fffffa19.w	;

	
		movem.l	d0-a6,-(sp)

		ifne	music_ym
		jsr	music_ym_play
		endc
		
		ifne	music_sndh
		jsr	music_sndh_play
		endc
		
		move.l	vbl_routine,a0
		jsr	(a0)

		ifne	music_dma
		tst.w	play_music
		beq.s	.no_music
		jsr	music_dma_play
.no_music:
		endc

;		Micro demopart sequencer
		move.l	part_position,a0
		subq.l	#1,(a0)+
		bne.s	.no_switch
		add.l	#24,part_position
.no_switch:	move.l	(a0)+,timera_delay
		move.l	(a0)+,timera_div
		move.l	(a0)+,vbl_routine
		move.l	(a0)+,timera_routine
		move.l	(a0)+,main_routine

		addq.w	#1,vbl_counter
		addq.w	#1,global_vbl
		movem.l	(sp)+,d0-a6
		rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM HBL (PLACEHOLDER)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hbl:		rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM TIMER A
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timer_a:	movem.l	d0-a6,-(sp)
		move.l	timera_routine,a0
		jsr	(a0)
		movem.l	(sp)+,d0-a6
		rte

timer_a_dummy:	clr.b	$fffffa19.w			;stop ta
		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		MISC COMMON ROUTINES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

music_on:	move.w	#1,play_music
		rts
		
dummy:		rts

clear_256k:	lea.l	generic_256k,a0
		move.l	#1024*256,d0
		bra.w	generic_clear
clear_128k:	lea.l	generic_128k,a0
		move.l	#1024*128,d0
		bra.w	generic_clear
clear_64k1:	lea.l	generic_64k1,a0
		move.l	#1024*64,d0
		bra.s	generic_clear
clear_64k2:	lea.l	generic_64k2,a0
		move.l	#1024*64,d0
		bra.s	generic_clear
clear_32k1:	lea.l	generic_32k1,a0
		move.l	#1024*32,d0
		bra.s	generic_clear
clear_32k2:	lea.l	generic_32k2,a0
		move.l	#1024*32,d0
		bra.s	generic_clear
clear_code:	lea.l	generic_code,a0
		move.l	#1024*64,d0
		;bra.w	generic_clear
generic_clear:
;in:	d0.l = bytes to clear
;	a0 = address to clear from

		moveq.l	#0,d1
.clr:		move.b	d1,(a0)+
		subq.l	#1,d0
		bgt.s	.clr
		rts

clear_screens:	move.l	screen_adr_base,a0
		moveq.l	#0,d0
		move.w	#128*1024/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

black_pal:	lea.l	$ffff8240.w,a0
		moveq.l	#0,d0
		rept	8
		move.l	d0,(a0)+
		endr
		rts

white_pal:	lea.l	$ffff8240.w,a0
		move.l	#$0fff0fff,d0
		rept	8
		move.l	d0,(a0)+
		endr
		rts


syncfix:	move.w	global_vbl,.vbls

.wait_first:	move.w	.vbls,d0			;vsync
		cmp.w	global_vbl,d0
		bge.s	.wait_first

		ifeq	hatari
		move.b	#1,$ffff8260.w			;medres
		endc

		move.w	global_vbl,.vbls
		add.w	#2,.vbls			;n

.more:		move.w	global_vbl,d0			;vsync n times
		cmp.w	.vbls,d0
		ble.s	.more

		ifeq	hatari
		move.b	#0,$ffff8260.w			;lowres
		endc
		rts
.vbls:		dc.w	0


lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire 
		bne.s	.waitend
		rts

pause:
;d0.w	nops+dbra to pause
.pause:		nop
		dbra	d0,.pause
		rts

xbios_vsync:	move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		rts



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM INCLUDES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		ifne	hatari_speedup
		include	'hatari/hatari.s'
		endc

		ifne	music_sndh
		include	'music/sndh.s'
		endc

		ifne	music_ym
		include	'music/ym.s'
		endc
		
		ifne	music_dma
		include	'loader/loader.s'
		include	'music/dma.s'
		endc

		include	'sys/c2p.s'
		include	'sys/fade.s'
		include	'sys/ice.s'
		include	'sys/lz77_000.s'
		;include	'sys/mth68000.s'
		

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INCLUDES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


		ifne	part_parall
		include	'parall/parall.s'
		endc

		ifne	part_bg1x1
		include	'1x1bg/1x1bg.s'
		endc

		ifne	part_skyline
		include	'skyline/skyline.s'
		endc

		ifne	part_linezoom
		include	'linezoom/linezoom.s'
		endc

		ifne	part_shadevec
		include	'shadevec/shadevec.s'
		endc

		ifne	part_kube
		include	'kube/kube.s'
		endc

		ifne	part_spr3d
		include	'spr3d/spr3d.s'
		endc

		ifne	part_fullrot
		include	'fullrot/fullrot.s'
		endc

		ifne	part_spec29k
		include	'spec29k/spec29k.s'
		endc

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INIT LIST
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initlist:
		move.l	#empty,d0
		clr.b	d0
		move.l	d0,empty_adr
		move.l	d0,a0
		move.l	#230*5*4,d0
		jsr	generic_clear

		ifne	part_parall
		jsr	parall_init
		endc

		ifne	part_bg1x1
		jsr	bg1x1_init
		endc

		ifne	part_skyline
		jsr	skyline_init
		endc

		ifne	part_linezoom
		jsr	linezoom_init
		endc

		ifne	part_shadevec
		jsr	shadevec_init
		endc

		ifne	part_kube
		jsr	kube_init
		endc

		ifne	part_spr3d
		jsr	spr3d_init
		endc

		ifne	part_fullrot
		jsr	fullrot_init
		endc

		ifne	part_spec29k
		jsr	spec29k_init
		endc

		ifne	music_dma
		jsr	loader
			ifeq	part_parall
			jsr	music_on
			endc
			if music_ofs > 0
			jsr	music_dma_ffwd
			endc
		endc

		rts


		section	data

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		LIST OF DEMOPARTS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;format
;dc.l vbls,ta_delay,ta_div,vbl,ta,main



partlist:

		ifne	part_parall
		dc.l	100,99,4,dummy,timer_a_dummy,parall_runtime_init	;music has not started here
		dc.l	24,99,4,music_on,dummy,dummy
		dc.l	150,99,4,parall_vbl_in,parall_timer_a,dummy
		dc.l	350,99,4,parall_vbl,parall_timer_a,parall_main_nerve
		dc.l	350,99,4,parall_vbl,parall_timer_a,parall_main_gizmofr
		dc.l	350,99,4,parall_vbl,parall_timer_a,parall_main_505
		dc.l	350,99,4,parall_vbl,parall_timer_a,parall_main_gizmo
		dc.l	200,99,4,parall_vbl,parall_timer_a,parall_main_evil
		dc.l	96,99,4,parall_vbl_out,parall_timer_a,parall_main_evil
		endc
;deduct 100 from timecode due to parall_runtime_init!

;1870

		ifne	part_linezoom
		dc.l	24,99,4,dummy,dummy,linezoom_runtime_init	
		dc.l	372,99,4,linezoom_fadein,linezoom_timer_a,linezoom_main
		dc.l	100,99,4,linezoom_fadein2,linezoom_timer_a,linezoom_main
		dc.l	430,99,4,linezoom_vbl,linezoom_timer_a,linezoom_main ;590
		dc.l	150,99,4,linezoom_fadeout2,linezoom_timer_a,linezoom_main
		dc.l	150,99,4,linezoom_fadeout,linezoom_timer_a,linezoom_main
		endc
;1218 + 1870 = 3088
		
		ifne	part_skyline
		dc.l	204,99,4,dummy,dummy,skyline_runtime_init	
		dc.l	204,99,4,skyline_fadein1,skyline_timer_a,skyline_main
		dc.l	240,99,4,skyline_fadein2,skyline_timer_a,skyline_main
		dc.l	695+150,99,4,skyline_vbl,skyline_timer_a,skyline_main
		dc.l	50,99,4,skyline_fadeout,skyline_timer_a,skyline_main
		endc
;1550 + 3088 = 4638

		ifne	part_kube
		dc.l	300,99,4,dummy,dummy,kube_runtime_init_single	
		dc.l	585-75+25,99,4,kube_vbl_single,kube_timer_a,kube_main

		dc.l	160,99,4,kube_fadein12bit,dummy,kube_runtime_init_12bit	
		dc.l	285-50,99,4,kube_vbl_12bit,kube_timer_a_12bit,kube_main
		dc.l	150,99,4,kube_vbl_12bit_out,kube_timer_a_12bit,kube_main

		dc.l	320,99,4,dummy,dummy,kube_runtime_init_field
		dc.l	645-75,99,4,kube_vbl,kube_timer_a,kube_main
		dc.l	120+25,99,4,kube_vbl_out,kube_timer_a,kube_main

		dc.l	10,99,4,dummy,dummy,kube_runtime_exit
		endc
;2570 + 4638 = 7208

		ifne	part_spr3d_a
		;2pl roses
		dc.l	20,99,4,dummy,dummy,spr3d_runtime_init_2pl
		dc.l	320,99,4,spr3d_fadein_2pl,dummy,spr3d_init_megaobj
		dc.l	480+87,99,4,spr3d_vbl_megaobj,dummy,spr3d_main
		dc.l	150,99,4,spr3d_vbl_megaobj_fadeout1,dummy,spr3d_main
		dc.l	210-80,99,4,spr3d_vbl_megaobj_fadeout2,dummy,spr3d_main
		dc.l	14,99,4,dummy,dummy,spr3d_runtime_exit
		endc
;1294 + 7208 = 8502

		ifne	part_spec29k
		dc.l	100,99,4,dummy,dummy,spec29k_runtime_init	
		dc.l	10,99,4,spec29k_vbl,dummy,spec29k_main ; establish display 
		dc.l	530+80+115,99,4,spec29k_vbl,spec29k_timer_a,spec29k_main ;fadein/display
		dc.l	120,99,4,spec29k_vbl,spec29k_timer_a,spec29k_main_out ;fadeout
		endc
;880 + 8502 = 9382		

		ifne	part_spr3d_b
		;with starfield
		dc.l	80,99,4,dummy,dummy,spr3d_stars_runtime_init
		dc.l	2,99,4,dummy,dummy,clear_screens
		dc.l	100,99,4,spr3d_4pl_fadein,dummy,spr3d_runtime_init_4pl
		dc.l	100,99,4,spr3d_4pl_fadein,dummy,spr3d_init_64

		dc.l	565,99,4,spr3d_vbl_64,dummy,spr3d_main

		dc.l	325-55,99,4,greets_in1,dummy,spr3d_init_cubs
		dc.l	100,99,4,greets_out1,dummy,spr3d_init_cubs
		dc.l	630,99,4,spr3d_vbl_cubs,dummy,spr3d_main

		dc.l	300-55,99,4,greets_in2,dummy,spr3d_init_str1
		dc.l	100,99,4,greets_out2,dummy,spr3d_init_str1
		dc.l	530,99,4,spr3d_vbl_str1,dummy,spr3d_main

		dc.l	130-20,99,4,spr3d_4pl_fadeout,dummy,dummy
		dc.l	4,99,4,dummy,dummy,spr3d_runtime_exit
		endc

		ifne	part_shadevec
		dc.l	100,99,4,dummy,dummy,shadevec_runtime_init	
		dc.l	210,99,4,shadevec_fadein,shadevec_timer_a,shadevec_main		
		dc.l	930+20,99,4,shadevec_vbl,shadevec_timer_a,shadevec_main
		dc.l	210,99,4,shadevec_fadeout,shadevec_timer_a,shadevec_main		
		endc


		ifne	part_bg1x1
		;full 4bpl grid version
		dc.l	40,99,4,dummy,dummy,bg1x1_runtime_init_pic
		dc.l	350,99,4,bg1x1_copypic_vbl,dummy,bg1x1_runtime_init	
		dc.l	40+50,99,4,dummy,dummy,bg1x1_runtime_init_scramble
		dc.l	150-50,99,4,bg1x1_scroll_in,dummy,bg1x1_main
		dc.l	20,99,4,bg1x1_flash,dummy,bg1x1_main
		dc.l	430+100-20-10,99,4,bg1x1_vbl,dummy,bg1x1_main
		dc.l	150,99,4,bg1x1_scroll_out,dummy,bg1x1_main
		dc.l	50,99,4,bg1x1_fade_out,dummy,bg1x1_main
		endc


		ifne	part_fullrot
		dc.l	150,99,4,dummy,dummy,fullrot_runtime_init	
		dc.l	100,99,4,fullrot_fadein,fullrot_timer_a,fullrot_main
		dc.l	595,99,4,fullrot_vbl_spiral,fullrot_timer_a,fullrot_main
		dc.l	700,99,4,fullrot_vbl_tunnel,fullrot_timer_a,fullrot_main
		dc.l	700,99,4,fullrot_vbl_polar,fullrot_timer_a,fullrot_main
		dc.l	630-70,99,4,fullrot_vbl_wave,fullrot_timer_a,fullrot_main
		dc.l	120,99,4,fullrot_fadeout1,fullrot_timer_a,fullrot_main
		dc.l	50,99,4,fullrot_fadeout2,fullrot_timer_a,fullrot_main
		endc

		;just a dummy to let music play to the end
		dc.l	250,100,4,black_pal,dummy,music_dma_exit	;5 seconds silence at end

		;exit demo
		dc.l	-1,100,4,dummy,dummy,exit


;skipped stuff
		;hispeed 2bpl version
		;dc.l	400,99,4,dummy,dummy,bg1x1_2_runtime_init	
		;dc.l	1000,99,4,bg1x1_2_vbl,dummy,bg1x1_2_main


		;ifne	part_vector
		;dc.l	120,99,4,dummy,dummy,vector_runtime_init	
		;dc.l	700,99,4,vector_vbl,vector_timer_a,vector_main
		;dc.l	70,99,4,dummy,dummy,vector_runtime_init2
		;dc.l	700,99,4,vector_vbl,vector_timer_a,vector_main
		;endc

		;ifne	part_bitbend
		;dc.l	100,99,4,dummy,dummy,bitbend_runtime_init	
		;dc.l	500,99,4,bitbend_vbl,bitbend_timer_a,bitbend_main
		;dc.l	4,99,4,dummy,dummy,bitbend_runtime_exit	
		;endc



;		Do not shift order of these variables
part_position:	dc.l	partlist
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
vbl_counter:	dc.w	0
global_vbl:	dc.w	0


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		GENERIC MEMORY BUFFERS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

play_music:	dc.w	0
sincos4000:	incbin	'shared/sin.bin'
		even



		section	bss

;-------------- 256k generic buffer ----
generic_256k:
spec29k_pic1:	;ds.b 69888
predivs:	;ds.l	MAX_STARS*256	;200k
fullrot_chunky:	;ds.b	104*68
c2ptable:
skyline_data:	;spans over 256k, 128k, 64k1, 64k2 !
kube_data:	;spans over 256k, 128k
shadevec_addtab:	;ds.w	(274+1)*128
		ds.b	1024*256

;-------------- 128k generic buffer ----
generic_128k:
spec29k_pic2:	;ds.b 69888
linezoom_fade:	;ds.b (208+208+48)*208 = 96512
spr3d_vertanim:	;ds.w	spr3d_maxvertex*8*spr3d_frames ;40*8*2*256 = 128000
fullrot_ofstxt:
c2pmask:	;spans over 128k, 64k1, 64k2 !
parall_layer3:
shadevec_scanlines:
		ds.b	1024*128

;-------------- 64k generic buffer -----
generic_64k1:
spr3d_multab192:	;ds.w	400
rnd_coords		;ds.w	MAX_STARS*3 ofs 800
fullrot_texture:
linezoom_data:
kube_rasters:	;ds.w	273*3
parall_text:
vector_colours:	;spans over 64k1, 64k2 !
shadevec_fade:	;ds.l	8*96
		ds.b	1024*64

;-------------- 64k generic buffer 2 -----
generic_64k2:
kube_displist12bit:	;ds.l	280	;*10*80
fullrot_tmp:
fullrot_fadein_list:	;ds.w	16*48
shadevec_slope:
spr3d_sprites:
		ds.b	1024*64


;-------------- 32k generic buffer 1 -----
generic_32k1:
shadevec_displist:	;ds.b	273+1+100
fullrot_fadeout_list:	;ds.w	16*48
loader_gfx	;ds.b	320x60/4
spr3d_2plbg:	;ds.b	16000
greets_data:	;ds.b	240*400/4
skyline_bgshift: ;ds.b	832*32*8/8 = 26624
kube_chunky:		;ds.w	36*29
parall_plotofs:	;ds.w	36*44
bg1x1_pic:	;ds.b 32066
		ds.b	1024*32

;-------------- 32k generic buffer 2 -----
generic_32k2:
fullrot_displist:	;ds.l	273
spr3d_masks:	
bitbend_rasters:
bg1x1_textures: ;ds.b	128*128*2
kube_displist:	;ds.l   432*2 
		ds.b	1024*32


;-------------- 64k generic code -----
generic_code:
		ds.b	1024*64

;-------------- 128k screen buffers -----
screen_buffer:
bg1x1_inv_table:	;ds.b	1024*128
		ds.b	1024*64*2+256
		
empty:		ds.l	230*5+64
empty_adr:	ds.l	1
global_dump:	ds.l	16

		section	text

