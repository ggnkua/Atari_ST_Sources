;               ___________     ______   ______    ____________
;              !           \   !      ! !      !  /           /
;              ! !    _     \  ! !    !_!      ! / /  _______/
;           ___! !   !_\     \_! !             !_\ \         \____
;           :::!     !:/   / /:!       _     ! !::\_______  \ \:::
;           :::!          / /::!      !:!    ! !::/         / /:::
;           :::!___________/:::!______!:!______!:/___________/::::
;           ::::::::::::::::::::::::::::::::::::::::::::::::::::::
;           ::::::::::::::[ Dead Hackers Society ]::::::::::::::::
;           ::::::::::::::::::::::::::::::::::::::::::::::::::::::
; 
; Dead Hackers Society Falcon Demoshell v16
; -----------------------------------------
; November 3, 1999 - June 17, 2006. 
; Anders Eriksson <ae@dhs.nu>
;
; MP2 replay: NoRing/NoBrain, MOD replay: Bitmaster, ACE Replay: Thomas, Video save/restore: Aura & Mugwumps
;
; Recent changes/fixes, june 17, 2006: 
; 1) New variables: video_width, video_height, video_depth (readonly words)
; 2) Screenshot feature added, screendump done at exit if the flag is enabled
; 3) mainloop, vbl and timer moved to separate files
; 4) ACE Tracker player included
; 5) Aranym timer simulation added
; 6) Parameters for each routine added: main_param, vbl_param, timer_param
; 7) Added generic physical screen clear routine
; 8) Demosystem parameter added; one parameter supported: run part only once
;
; main.s


		opt	p=68030/68882,NOCASE			;68030+68882 code allowed
		comment HEAD=%111				;fastload/loadalt/mallocalt = ON

scr_w:		equ	640					;width  (x - in pixels)
scr_h:		equ	480					;height (y - in pixels)
scr_d:		equ	1					;depth  (in bytes)

XSCR	=	320
YSCR	=	180

startupmenu:	equ	0					;1 = enable startup menu

dspmodmusic:	equ	0					;1 = use dspmod music, select which mod file to load in sys/dspmod.s
mp2music:	equ	1					;1 = use mpeg1 layer 2 music, select which mp2 file to load in sys/mp2.s
acemusic:	equ	0					;1 = usr ACE Tracker musc, select which am file to play in sys/replace.s

def_vga_freq:	equ	60					;VGA frequency (60 or 100Hz)
def_rgb_freq:	equ	50					;RGB frequency (50 or 60Hz)

def_detailmode:	equ	1					;Detail mode (just a dumb flag for demos supporting more than one level of detail)

pause:		equ	0					;1 = enable pause on left-shift
cputime:	equ	0					;1 = enable vbl-time on control
screenshot:	equ	0					;0 = no screenshot 1 = save screenshot at exit (IFF for bitplane and TARGA for hicol)
aranym:		equ	0



; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------


; --------------------------------------------------------------
;		demosystem library includes
; --------------------------------------------------------------

		include	'sys\init.s'				;demosystem init
		include	'sys\mainloop.s'			;demosystem core mainloop
		ifeq	aranym
		include	'sys\vbl.s'				;demosystem core vbl
		include	'sys\timer.s'				;demosystem core timer
		endc
		ifne	aranym
		include	'sys\aranym.s'				;aranym timer emulation
		endc
		include	'sys\exit.s'				;demosystem exit
		include	'sys\video.s'				;videolib
		include	'sys\loader.s'				;file loader rout

		ifne	screenshot				;
		include	'sys\scrnshot.s'			;make screenshot at exit
		endc 						;

		ifne	dspmodmusic				;
		include	'sys\dspmod.s'				;ProTracker player
		endc						;
		ifne	mp2music				;
		include	'sys\mp2.s'				;MPEG Audio player
		endc						;
		ifne	acemusic				;
		include	'sys\replace.s'				;ACE Tracker player
		endc						;

		ifne	startupmenu				;
		include	'sys\startup.s'				;startup menu
		endc						;


; --------------------------------------------------------------
;		basic subroutines
; --------------------------------------------------------------

		include	'sys\fade.s'			;basic bitplane related routines
		;include	'sys\ice.s'			;ice depacker
		include	'c2p\c2p6high.s'
		include	'c2p\c2p_6pl.s'
		include	'c2p\c2p_8pl.s'


black_palette:	lea.l	$ffff9800.w,a0				;black palette
		move.w	#256-1,d7				;
.loop:		clr.l	(a0)+					;
		dbra	d7,.loop				;
dummy:		rts						;

clear_all_screens:						;clear all three workscreens
		move.l	screen_adr1,a0				;clears the physical size of the current resolution
		move.l	screen_adr2,a1
		move.l	screen_adr3,a2
		move.w	video_height,d7
		subq.w	#1,d7
.y:		move.w	video_width,d6
		cmp.w	#16,video_depth
		bne.s	.eight
		lsr.w	#1,d6
		bra.s	.sub
.eight:		lsr.w	#2,d6
.sub:		subq.w	#1,d6
.x:		clr.l	(a0)+
		clr.l	(a1)+
		clr.l	(a2)+
		dbra	d6,.x
		dbra	d7,.y
		rts


; --------------------------------------------------------------
;		demo part includes
; --------------------------------------------------------------


		include	'intro\intro.s'		;buildup of q pic in sync to drums
		include	'sun\sun.s'		;Parallax part
		include	'voxtwist\voxtwist.s'	;"Voxel" twister
		include	'water\water.s'		;Water-thingy
		include	'scaryq\scaryq.s'	;hires pic by crazy with 3d-obj
		include	'end\end.s'
		include	'hands\hands.s'
		include	'greets\greets.s'

		include	'real3d\eng_main.s'
		include	'land\eng_land.s'
		include	'neuron\eng_neu.s'
		include	'sal\eng_sal.s'
;		include	'vein\eng_vein.s'
		include	'house\eng_hous.s'
		

; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even




; Initroutines to run before the demo starts
;
; REMEMBER!
; Always start music at the end! Or you will get unsynced!
; 
; The list ends with dc.l 0

fake_monitor:	move.w	#1,monitor
		rts

inits:
*		dc.l	fake_monitor
		dc.l	video_6					;set resolution
		dc.l	black_palette				;black palette

		dc.l	intro_init
		dc.l	sun_init
		dc.l	voxtwist_init
		dc.l	water_init
		dc.l	scaryq_init
		dc.l	real3d_init_land
		dc.l	end_init
		dc.l	greets_init

		;Music inits, leave at the end!
		ifne	dspmodmusic				;
		dc.l	dspmod_load				;load module/reserve mem
		dc.l	dspmod_begin				;init musicroutine
		endc						;
		ifne	mp2music				;
		dc.l	mp2_load				;load mpeg file/reserve mem
		dc.l	mp2_begin				;init mpeg rout and start playing
		endc
		ifne	acemusic				;
		dc.l	ace_initsong1				;initialize replace
		dc.l	ace_start				;play music
		dc.l	ace_stop				;
		dc.l	ace_initsong1				;initialize replace again, to workaround a bug in ACE with first time init
		dc.l	ace_start				;play music
		endc
		
		dc.l	0




; demo sequencer list
;
;		dc.l ticks,s_par,timer,t_par,vbl,v_par,main,m_par,screens,vblwait
;
;	   ticks : 100Hz frames to run part
;	    s_par: parameter to the demosystem: 0 = nothing, 1 = run part one time only
;	   timer : address to timer routine (routine runs att 300Hz)
;           t_par: parameter to the timer, found in variable "timer_param", for no param use "0"
;	     vbl : address to vbl routine
;           v_par: parameter to the vbl, found in variable "vbl_param", for no param use "0"
;	    main : address to main routine
;           m_par: parameter to the mainrout, found in variable "main_param", for no param use "0"
;	 screens : number of screens to cycle. valid options: 1, 2, 3
;        vblwait : mainloop wait for vbl.
;                  0 = waitvbl if efx run faster than 1 vbl (tripplebuffer only!)
;                  1 = always waitvbl (even if efx is multivbl (always with single/doublebuffer!))

; video modes:
; video_1=288/144*100*16  video_2=288*200*16  video_3=288*200*8  video_4=576*400*8
; video_5=320*240*16      video_6=320*240*8   video_7=640*480*8



;-------------- part 1
part_intro:	equ	1
part_land:	equ	1
part_water:	equ	1
part_parallax:	equ	1
part_hands:	equ	1


;-------------- part 2
part_zik2:	equ	1
part_tvangs:	equ	1
part_neuron:	equ	1
part_voxtwist:	equ	1
part_scaryq:	equ	1
part_sal:	equ	1
part_greets:	equ	1
part_house:	equ	1

;-------------- part 3
part_zik3:	equ	1
part_end:	equ	1





demo_parts:
		ifne	part_intro
		dc.l	67,1,dummy,0,video_6,0,real3d_runtime_init_land,0,1,1
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs01,3,1	;01
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs02,3,1	;02
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs03,3,1	;03
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs04,3,1	;04
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs05,3,1	;05
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs06,3,1	;06
		dc.l	50,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs07,3,1	;07
		dc.l	50,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs08,3,1	;08
		dc.l	50,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs09,3,1	;09
		dc.l	100,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs10,3,1	;10
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs11,3,1	;11
		dc.l	200,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs12,3,1	;12
		dc.l	50,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs13,3,1	;13
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs14,3,1	;14
		dc.l	133,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs15,3,1	;15
		dc.l	80,0,intro_timer,land_clip01,intro_vbl,0,intro_main,intro_ofs16,3,1	;16
		dc.l	220,0,intro_timer,land_clip01,intro_vbl,1,intro_main,intro_ofs16,3,1	;16 + fadeout
		endc


		ifne	part_land
			ifeq	part_intro
				dc.l	50,1,dummy,0,video_6,0,real3d_runtime_init_land,0,1,1
			endc
		dc.l	533,0,land_timer,land_clip02,land_vbl,0,real3d_main_land,0,3,0
		dc.l	533,0,land_timer,land_clip03,land_vbl,0,real3d_main_land,0,3,0
		dc.l	533,0,land_timer,land_clip04,land_vbl,0,real3d_main_land,0,3,0
		dc.l	533,0,land_timer,land_clip05,land_vbl,0,real3d_main_land,0,3,0
		endc


		ifne	part_water
		dc.l	10,1,dummy,0,black_palette,0,water_runtime_init,0,1,1
		dc.l	500,0,water_timer,0,water_vbl,2,water_main,0,3,0 ;fadein only water
		dc.l	500,0,water_timer,0,water_vbl,1,water_main,1,3,0 ;flash +show obj
		dc.l	500,0,water_timer,1,water_vbl,0,water_main,1,3,0 ;scale down obj
		dc.l	240,0,water_timer,2,water_vbl,0,water_main,1,3,0 ;zoom up obj
		dc.l	270,0,water_timer,2,water_vbl,3,water_main,1,3,0 ;fadeout and zoom up
		endc


		ifne	part_parallax	;total 4615 +300 +200
		dc.l	5,1,dummy,0,video_6,0,dummy,0,1,1
		dc.l	5,1,dummy,0,black_palette,0,dummy,0,1,1

		dc.l	2133,0,sun_timer,0,sun_vbl_fadein,0,sun_main,0,3,1

		dc.l	300,0,sun_timer_crazyq,0,sun_vbl,0,sun_main,0,3,1
		dc.l	233,0,sun_timer_crazyq,0,sun_vbl,0,sun_main,1,3,1

		dc.l	300,0,sun_timer_gizmo,0,sun_vbl,0,sun_main,0,3,1
		dc.l	233,0,sun_timer_gizmo,0,sun_vbl,0,sun_main,1,3,1

		dc.l	300,0,sun_timer_evil,0,sun_vbl,0,sun_main,0,3,1
		dc.l	233,0,sun_timer_evil,0,sun_vbl,0,sun_main,1,3,1

		dc.l	167,0,sun_timer,0,sun_vbl_fadeout,0,sun_main,0,3,1
		endc


		ifne	part_hands
		dc.l	5,1,dummy,0,video_7,0,dummy,0,1,1
		dc.l	300,1,dummy,0,dummy,0,hands_runtime_init,0,1,1
		dc.l	1050,0,dummy,0,hands_fadein_vbl,0,dummy,0,1,1
		endc


;----------------------------------------------------------------------
;-------------- PART 2 ------------------------------------------------
;----------------------------------------------------------------------

		ifne	part_zik2
		; begin main music
		dc.l	10,1,dummy,0,dummy,0,mp2_end,0,1,1
		dc.l	300-20,1,dummy,0,dummy,0,mp2_load2,0,1,1
		dc.l	10,1,dummy,0,dummy,0,mp2_begin,0,1,1
		endc




		ifne	part_tvangs	;1036
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,4,1,1
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,3,1,1
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,2,1,1
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,1,1,1
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,0,1,1
		dc.l	64,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	64,0,dummy,0,dummy,0,hands_changepic_main,5,1,1
		dc.l	100,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	144+20+24,0,dummy,0,handstvangs_vbl,0,dummy,0,1,1
		endc


		ifne	part_neuron	;2032
		dc.l	35,1,dummy,0,video_6,0,real3d_runtime_init_neuron,0,1,1
		dc.l	262,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip01,3,0
		dc.l	262,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip02,3,0
		dc.l	262,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip03,3,0
		dc.l	262,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip04,3,0
		dc.l	262,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip05,3,0
		dc.l	537,0,neuron_timer,0,neuron_vbl,0,real3d_main_neuron,neuron_clip06,3,0
		dc.l	150,0,neuron_timer,0,neuron_vbl,1,real3d_main_neuron,neuron_clip06,3,0
		endc

		
		ifne	part_voxtwist	;2050
		dc.l	20-8,1,dummy,0,video_6,0,voxtwist_runtime_init,0,1,1
		dc.l	1850,0,voxtwist_timer,0,voxtwist_vbl,0,voxtwist_main,0,3,1
		dc.l	180+8,0,voxtwist_timer,0,voxtwist_vbl,1,voxtwist_main,0,3,1
		endc


		ifne	part_scaryq	;1010
		dc.l	5,1,dummy,0,video_7,0,dummy,0,1,1
		dc.l	15,1,dummy,0,dummy,0,scaryq_runtime_init,0,1,1
		dc.l	840,0,scaryq_timer,0,scaryq_vbl,0,scaryq_main,0,1,1
		dc.l	250,0,scaryq_timer,0,scaryq_vbl,1,scaryq_main,0,1,1
		endc

		ifne	part_sal	;4060
		dc.l	20,1,dummy,0,video_6,0,real3d_runtime_init_sal,0,1,1
		dc.l	2020-20,0,sal_timer,sal_clip01,sal_vbl,0,real3d_main_sal,0,3,0
		dc.l	1010+20,0,sal_timer,sal_clip02,sal_vbl,0,real3d_main_sal,0,3,0
		dc.l	1010,0,sal_timer,sal_clip03,sal_vbl,0,real3d_main_sal,0,3,0
		endc


;		ifne	part_empty
;		dc.l	2070,0,dummy,0,dummy,0,dummy,0,1,1
;		endc

;		ifne	part_vein
;		dc.l	70,1,dummy,0,video_6,0,real3d_runtime_init_vein,0,1,1
;		dc.l	2000,0,real3d_timer,0,real3d_vbl,0,real3d_main_vein,0,3,0
;		endc


		ifne	part_greets	;2088
		dc.l	5,0,dummy,0,video_6,0,dummy,0,1,1
		dc.l	10,1,dummy,0,dummy,0,greets_runtime_init,0,1,1
		dc.l	2050-150,0,greets_timer,0,greets_vbl,0,greets_main,0,3,0
		dc.l	150,0,greets_timer,0,greets_vbl,1,greets_main,0,3,0
		;dc.l	450,0,greets_timer,0,greets_vbl,1,greets_main,0,3,0
		endc

		ifne	part_house
		dc.l	50-30,1,dummy,0,video_6,0,real3d_runtime_init_house,0,1,1
		dc.l	5,0,house_timer,house_clip01,black_palette,0,real3d_main_house,0,3,0
		dc.l	1010-5+20+30,0,house_timer,house_clip01,house_vbl,0,real3d_main_house,0,3,0
		dc.l	1010-20,0,house_timer,house_clip02,house_vbl,0,real3d_main_house,0,3,0
		dc.l	430+115+115-100+20-30,0,house_timer,house_clip02,house_vbl,1,real3d_main_house,0,3,0
		;dc.l	430+115+115,0,dummy,0,dummy,0,dummy,0,1,1
		endc










;----------------------------------------------------------------------
;-------------- PART 3 ------------------------------------------------
;----------------------------------------------------------------------


		ifne	part_zik3
		; begin endpart music
		dc.l	10,1,dummy,0,dummy,0,mp2_end,0,1,1
		dc.l	300,1,dummy,0,dummy,0,mp2_load3,0,1,1
		dc.l	10,1,dummy,0,dummy,0,mp2_begin,0,1,1
		endc


		ifne	part_end
		dc.l	150,0,dummy,0,house_endfadeout,0,dummy,0,1,1
		;dc.l	150,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	5,1,dummy,0,video_6,0,dummy,0,1,1
		dc.l	1920-150,1,dummy,0,dummy,0,end_runtime_init,0,1,1
		dc.l	9050-100,0,end_timer,0,end_vbl,0,end_main,0,2,1
		dc.l	450+100,0,end_timer,0,end_vbl,1,end_main,0,2,1

		dc.l	5,1,dummy,0,video_7,0,dummy,0,1,1
		dc.l	50,1,dummy,0,dummy,0,endlogo_runtime_init,0,1,1
		dc.l	1970,0,dummy,0,endlogo_vbl,0,dummy,0,1,1 ;endpic later
		dc.l	880,0,dummy,0,endlogo_vbl,1,dummy,0,1,1 ;endpic later
		endc



				


		;exit demo
		dc.l	-1,0,dummy,0,dummy,0,exit,0,1,1





;-------------- core demosystem variables ----------------------
current_fx:	dc.l	demo_parts				;current
sys_param:	dc.l	0					;demo system parameter
timer_routine:	dc.l	dummy					;timer
timer_param:	dc.l	0					;timer parameter
vbl_routine:	dc.l	dummy					;vbl
vbl_param:	dc.l	0					;vbl parameter
main_routine:	dc.l	dummy					;main
main_param:	dc.l	0					;main parameter
swapscreens:	dc.l	0					;screens
vblsync:	dc.l	0					;vblwait


;-------------- video parameters -------------------------------
monitor:	dc.w	0					;0=vga 1=rgb/tv (init.s auto detect)
vga_freq:	dc.w	def_vga_freq				;60/100 Hz
rgb_freq:	dc.w	def_rgb_freq				;50/60 Hz
detail:		dc.w	def_detailmode				;0=low 1=high

runlevel:	dc.w	0


; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even

vblwait:	ds.w	1					;for fx in less than 1vbl
screen_adr1:	ds.l	1					;screen address 1
screen_adr:							;WORK ADDRESS!
screen_adr2:	ds.l	1					;screen address 2
screen_adr3:	ds.l	1					;screen address 3
video_width:	ds.w	1					;current X resolution
video_height:	ds.w	1					;current Y resolution
video_depth:	ds.w	1					;current number of bits/pixel on screen
save_stack:	ds.l	1					;old stackpointer
save_timer_d:	ds.l	1					;old timer-d
save_vbl:	ds.l	1					;old vbl
save_mfp:	ds.l	1					;old mfp
save_dta:	ds.l	1					;old dta address
save_pal:	ds.l	256+8					;old colours (falcon+st/e)
save_video:	ds.b	32+12+2					;videl save
save_keymode:	ds.w	1					;old keyclick mode
dta:		ds.l	11					;new dta buffer

		end
