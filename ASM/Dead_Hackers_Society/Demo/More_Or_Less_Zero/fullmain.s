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



; MORE OR LESS ZERO
; Atari STe-demo 2008
;
; Code by Gizmo & Evil / DHS


scr_w:		equ	230			;linewidth of fullscreen
scr_h:		equ	280			;max lines visible

hatari:		equ	0			;Hatari specific codepath (bug workarounds)
hatari_speedup:	equ	0			;Hatari specific speedup during init

music_sndh:	equ	0			;Play a sndh music file
music_ym:	equ	0			;Play an ym-music file (YM3 only)
music_mod:	equ	0
music_dma:	equ	1			;Play a DMA-sample sequence (STe only)
dmazik_505:	equ	1			;505 mainpart music

init_green:	equ	0			;1=runtime init sets bg green when done

standalone:	equ	0			;1=run without loader  0=run with loader

part_intro:	equ	1			;STe OK! finished
part_tunnel:	equ	1			;STe OK! finished trimmed init
part_twist:	equ	1			;STe OK! finished trimmed init
part_osc:	equ	1			;STe OK! finished trimmed init
part_plax:	equ	1			;STe OK! finished trimmed init
part_firehorn:	equ	1			;STe OK! finihsed trimmed init
;-
part_circles:	equ	1			;STe OK! finished trimmed init
part_plasma:	equ	1			;STe OK! finished trimmed init
part_fullofs:	equ	1			;STe OK! finished trimmed init
part_glass:	equ	1			;STe OK! finished trimmed init
;-
part_kefrens:	equ	1			;STe OK! finished trimmed init 3-5k memopt possible
part_envmap:	equ	1			;STe OK! finished trimmed init
part_ofs3d:	equ	1			;STe OK! finished trimmed init
part_scroller:	equ	1			;STe OK! finished trimmed init 3-4k memopt possible
part_green:	equ	1			;STe OK! finished trimmed init (waiting for scanline effect)



		opt	p=68000
		output .tos

		section	text
		bra.w	begin

			;0123456789012345678901234567890123456789
		dc.b	"Hey ripper, if you are so eager to read "
		dc.b	"our sourcecode, why don't you send us an"
		dc.b	" e-mail and get the full documented sour"
		dc.b	"cecode instead?  --> ae(at)dhs.nu       "
		dc.b	"            Oh and by the way, Moredhel "
		dc.b	"is a wanker!                            "

begin:		include	'sys/fullinit.s'		;setup demosystem


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM MAINLOOP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainloop:	tst.l	vbl_counter
		beq.s	mainloop
		clr.l	vbl_counter

		move.l	a0,-(sp)
		move.l	main_routine,a0
		jsr	(a0)
		move.l	(sp)+,a0
	
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
		jsr	music_dma_play
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

		addq.l	#1,vbl_counter
		addq.l	#1,global_vbl
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

dummy:		rts

clear_256k:	lea.l	generic_256k,a0
		moveq.l	#0,d0
		move.w	#1024*256/16-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

clear_128k:	lea.l	generic_128k,a0
		moveq.l	#0,d0
		move.w	#1024*128/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

clear_64k:	lea.l	generic_64k,a0
		moveq.l	#0,d0
		move.w	#1024*64/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

clear_16k:	lea.l	generic_16k,a0
		moveq.l	#0,d0
		move.w	#1024*16/4-1,d7
.clr:		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

clear_screens:	move.l	screen_adr_base,a0
		moveq.l	#0,d0
		move.w	#128*1024/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

black_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0000

white_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0fff


syncfix:	move.l	global_vbl,.vbls

.wait_first:	move.l	.vbls,d0			;vsync
		cmp.l	global_vbl,d0
		bge.s	.wait_first

		ifeq	hatari
		move.b	#1,$ffff8260.w			;medres
		endc

		move.l	global_vbl,.vbls
		add.l	#2,.vbls			;n

.more:		move.l	global_vbl,d0			;vsync n times
		cmp.l	.vbls,d0
		ble.s	.more

		ifeq	hatari
		move.b	#0,$ffff8260.w			;lowres
		endc
		rts
.vbls:		dc.l	0


lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire 
		bne.s	.waitend
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
		include	'music/dma.s'
		endc

		include	'sys/c2p.s'
		include	'sys/fade.s'
		;include	'sys/ice.s'
		include	'sys/lz77_000.s'
		include	'sys/mth68000.s'
		

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INCLUDES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		include	'midtext/midtext.s'

		ifne	part_intro
		include	'intro/intro.s'
		endc

		ifne	part_vector
		include	'vector/vector.s'
		endc

		ifne	part_green
		include	'green/green.s'
		endc

		ifne	part_firehorn
		include	'firehorn/firehorn.s'
		endc

		ifne	part_glass
		include	'glass/glass.s'
		endc

		ifne	part_envofs
		include	'envofs/envofs.s'
		endc

		ifne	part_plasma
		include	'plasma/plasma.s'
		endc

		ifne	part_twist
		include	'twist/twist.s'
		endc

		ifne	part_ofs3d
		include	'ofs3d/ofs3d.s'
		endc

		ifne	part_plax
		include	'plax/plax.s'
		endc

		ifne	part_spec4096
		include	'spec4096/spec4096.s'
		endc

		ifne	part_kefrens
		include	'kefrens/kefrens.s'
		endc

		ifne	part_fullofs
		include	'fullofs/fullofs.s'
		endc

		ifne	part_osc
		include	'osc/osc.s'
		endc

		ifne	part_atlogo
		include	'atlogo/atlogo.s'
		endc

		ifne	part_envmap
		include	'envmap/envmap.s'
		endc

		ifne	part_tunnel
		include	'tunnel/tunnel.s'
		endc

		ifne	part_scroller
		include	'scroller/scroller.s'
		endc

		ifne	part_circles
		include	'circles/circles.s'
		endc

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INIT LIST
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initlist:

		jsr	midtext_init

		ifne	part_vector
		jsr	vector_init
		endc

		ifne	part_green
		jsr	green_init
		endc

		ifne	part_firehorn
		jsr	firehorn_init
		endc

		ifne	part_glass
		jsr	glass_init
		endc

		ifne	part_envofs
		jsr	envofs_init
		endc

		ifne	part_plasma
		jsr	plasma_init
		endc

		ifne	part_twist
		jsr	twist_init
		endc

		ifne	part_ofs3d
		jsr	ofs3d_init
		endc

		ifne	part_plax
		jsr	plax_init
		endc

		ifne	part_spec4096
		jsr	spec4096_init
		endc

		ifne	part_kefrens
		jsr	kefrens_init
		endc

		ifne	part_fullofs
		jsr	fullofs_init
		endc

		ifne	part_osc
		jsr	osc_init
		endc

		ifne	part_atlogo
		jsr	atlogo_init
		endc

		ifne	part_envmap
		jsr	envmap_init
		endc

		ifne	part_tunnel
		jsr	tunnel_init
		endc

		ifne	part_scroller
		jsr	scroller_init
		endc

		ifne	part_circles
		jsr	circles_init
		endc

		ifne	part_intro
		jsr	intro_init
		endc


		rts


		section	data

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		LIST OF DEMOPARTS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sincos4000:	incbin	'shared/sin.bin'
		even

;format
;dc.l vbls,ta_delay,ta_div,vbl,ta,main

partlist:

		ifne	part_intro
		dc.l	72,99,4,intro_vbl,intro_timer_a,dummy
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main1
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main2
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main3
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main4
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main5
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main6
		dc.l	49,99,4,intro_vbl,intro_timer_a,intro_main7
		dc.l	49,99,4,intro_vbl_out,intro_timer_a,dummy
		endc	;=464

		ifne	part_tunnel
		dc.l	75,99,4,dummy,timer_a_dummy,tunnel_runtime_init		;75vbl init
		dc.l	175+75-196,99,4,tunnel_vbl_in2,tunnel_timer_a,tunnel_main2
		dc.l	50+550+4,99,4,tunnel_vbl_in,tunnel_timer_a,tunnel_main
		dc.l	150,99,4,tunnel_vbl_out,tunnel_timer_a,tunnel_main
		endc	;=883

		ifne	part_twist
		dc.l	25,99,4,dummy,timer_a_dummy,twist_runtime_init		;25vbl init
		dc.l	400+420,99,4,twist_vbl1,twist_timer_a,twist_main
		dc.l	540+5,99,4,twist_vbl2,twist_timer_a,twist_main
		dc.l	60,99,4,twist_vbl3,twist_timer_a,twist_main
		dc.l	100,99,4,twist_vbl4,twist_timer_a,twist_main
		endc	;=1545
		ifne	part_osc
		dc.l	60,99,4,dummy,timer_a_dummy,osc_runtime_init		;60vbl init
		dc.l	560-5,99,4,osc_vbl_in,osc_timer_a,osc_main
		dc.l	200,99,4,osc_vbl,osc_timer_a,osc_main
		endc	;815

		ifne	part_plax
		dc.l	30,99,4,dummy,timer_a_dummy,plax_runtime_init		;30vbl init
		dc.l	330-20,99,4,plax_vbl_fadein,plax_timer_a,plax_main_black
		dc.l	100,99,4,plax_vbl_fadeout,plax_timer_a,plax_main_black
		dc.l	330+80-20,99,4,plax_vbl_fadein2,plax_timer_a,plax_main
		dc.l	670-80+30,99,4,plax_vbl_fadein,plax_timer_a,plax_main
		dc.l	150,99,4,plax_vbl_fadeout_both,plax_timer_a,plax_main
		endc	;1580

		ifne	part_firehorn
		dc.l	45,99,4,dummy,timer_a_dummy,firehorn_runtime_init	;45vbl init
		dc.l	500,99,4,firehorn_vbl_in,firehorn_timer_a,firehorn_main
		dc.l	150,99,4,firehorn_vbl_out,firehorn_timer_a,firehorn_main
		dc.l	5,99,4,dummy,timer_a_dummy,firehorn_runtime_exit
		endc

		ifne	part_circles
		dc.l	75,99,4,dummy,timer_a_dummy,circles_runtime_init	;75vbl init
		dc.l	800+25-380+394,99,4,circles_vbl,circles_timer_a,circles_main
		dc.l	150,99,4,circles_vbl_out,circles_timer_a,circles_main
		dc.l	5,99,4,dummy,timer_a_dummy,circles_runtime_exit
		endc
		ifne	part_plasma
		dc.l	210,99,4,dummy,timer_a_dummy,plasma_runtime_init	;210vbl init
		dc.l	700-10-20-10+380-394-30-75,99,4,plasma_vbl,plasma_timer_a,plasma_main
		dc.l	100,99,4,plasma_vbl_out,plasma_timer_a,plasma_main
		endc
		ifne	part_glass
		dc.l	50+30,99,4,dummy,timer_a_dummy,glass_runtime_init		;50vbl init
		dc.l	500+25-50,99,4,glass_fadein_vbl,glass_timer_a,glass_main
		dc.l	100,99,4,glass_fadeout_vbl,glass_timer_a,glass_main
		endc
		ifne	part_fullofs
		dc.l	210+30,99,4,dummy,timer_a_dummy,fullofs_runtime_init	;210vbl init
		dc.l	196*2-10-10,99,4,fullofs_vbl2,fullofs_timer_a,fullofs_main
		dc.l	196*2,99,4,fullofs_vbl3,fullofs_timer_a,fullofs_main
		dc.l	196*2,99,4,fullofs_vbl4,fullofs_timer_a,fullofs_main
		dc.l	196*2-100,99,4,fullofs_vbl1,fullofs_timer_a,fullofs_main
		dc.l	50,99,4,fullofs_vbl_out,fullofs_timer_a,fullofs_main
		endc




		ifne	part_kefrens
		dc.l	70,99,4,dummy,timer_a_dummy,kefrens_runtime_init	;70vbl init
		dc.l	130,99,4,kefrens_vbl_in1,kefrens_timer_a,kefrens_main
		dc.l	700-150,99,4,kefrens_vbl_in2,kefrens_timer_a,kefrens_main
		dc.l	300,99,4,kefrens_vbl_out1,kefrens_timer_a,kefrens_main
		dc.l	160,99,4,kefrens_vbl_out2,kefrens_timer_a,kefrens_main
		endc

		ifne	part_envmap
		dc.l	10,99,4,dummy,timer_a_dummy,midtext_greets_runtime_init		;greets while init
		dc.l	450-20,98,4,midtext_vbl,midtext_timer_a,envmap_runtime_init
		dc.l	2,99,4,dummy,timer_a_dummy,midtext_greets_runtime_exit
		;dc.l	260,240,4,dummy,timer_a_dummy,envmap_runtime_init	;260vbl init
		dc.l	700,240,4,envmap_vbl_in,envmap_timer_a,envmap_main
		dc.l	150,240,4,envmap_vbl_out,envmap_timer_a,envmap_main
		endc
		ifne	part_ofs3d
		dc.l	70,240,4,dummy,timer_a_dummy,ofs3d_runtime_init	;220vbl init with c2pgen and 70 without 
		dc.l	1000+90,240,4,ofs3d_vbl,ofs3d_timer_a,ofs3d_main_in
		dc.l	200,240,4,ofs3d_vbl,ofs3d_timer_a,ofs3d_main_out
		endc
		
		ifne	part_scroller
		dc.l	10,99,4,dummy,timer_a_dummy,midtext_credits_runtime_init		;greets while init
		dc.l	450,98,4,midtext_vbl,midtext_timer_a,scroller_runtime_init
		dc.l	5,99,4,dummy,timer_a_dummy,midtext_credits_runtime_exit
		;dc.l	270,99,4,dummy,timer_a_dummy,scroller_runtime_init	;270vbl init (could be merged with fadein?)
		dc.l	50,99,4,scroller_vbl_fadein,timer_a_dummy,dummy
		dc.l	1300,99,4,scroller_vbl,scroller_timer_a,scroller_main
		endc

		ifne	part_green
		dc.l	50,99,4,dummy,timer_a_dummy,green_runtime_init		;50vbl init
		dc.l	800,99,4,green_vbl_in,green_timer_a,green_main
		dc.l	275-20,99,4,green_vbl_out,green_timer_a,green_main
		endc




		dc.l	-1,100,4,dummy,dummy,exit


;		Do not shift order of these variables
part_position:	dc.l	partlist
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
vbl_counter:	dc.l	0
global_vbl:	dc.l	0



empty:			dcb.b	160*32+256,$00
empty_adr:		dc.l	0

		section	bss

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		GENERIC MEMORY BUFFERS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



;-------------- 256k generic buffer ----
twist_scanlist:				;+0		ds.w	112*3
osc_tex:				;+0		ds.w	256*256*2
plasma_anim:				;+0		ds.w	512*256
kefrens_sin:				;+0
scroller_bg_depack:			;+0
tunnel_1pl_depack:			;+0
atlogo_depack:				;+0
firehorn_depack:			;+0
spec4096_depack:			;+0
glass_depack:				;+0
tunnel_depack:				;+0
vector_mul160:				;+0		ds.l	65536
c2ptable:				;+0
generic_256k:
		ds.b	1024*256

;-------------- 128k generic buffer ----
ofs3d_txt1:				;+0		ds.b	256*256*2
twist_scanlist2:			;+0		ds.w	512+512
green_dispcurve:			;+0		ds.l	2048*4 
scroller_font:				;+0		dcb.w	15*300,$0fff
scroller_fontdata:			;+9000	
plasma_chunky:				;+0		ds.w	160*273
circles_pic_depack:			;+0
plax_hrast_depack:			;+0
plax_vrast_depack:			;+70000
env_inv_table:				;+0
fullofs_txt_depacked:			;+0
generic_128k:
		ds.b	1024*128

;-------------- 64k generic buffer -----
intro_depack:				;+0		ds.b	208*273
osc_chunky:				;+0		dcb.w	26*28
ofs3d_txt2:				;+0		ds.b	256*256*2 -- will overflow into 16k and generic code!!
plasma_basegfx:				;+0		ds.b	1024
green_depack:				;+0
glass_pal:				;+0		ds.w	274*96
plasma_xlist:				;+0		ds.l	1024
twist_gfx:				;+0
circles_1pl_depack:			;+0
envmap_texture:				;+0
envmap_chunky:				;+32768
ofs3d_texture_depack:			;+0
vector_mul15i:				;+0		ds.w	1024*32
chunky:
generic_64k:
		ds.b	1024*64


;-------------- 16k generic buffer -----
osc_gfxtab:				;+0		ds.l	536	;256+280
fullofs_adrs:				;+0		ds.l	70*5
twist_reallist:				;+0		ds.w	112*4
glass_ofs_rnd:				;+0		ds.l	20*20
green_displist:				;+0		ds.l	273
envmap_bgcols:				;+0		960*4 bytes
envmap_bgcols2:				;+3840		960*4 bytes
generic_16k:
		ds.b	1024*16


;-------------- 50k generic code -----
generic_code:	ds.b	1024*50



global_dump:	ds.l	16

		section	text

