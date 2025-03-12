; Main body

		OPT	p=68040				; 68040 code allowed
		COMMENT HEAD=%111			; fastload/loadalt/mallocalt = ON
		OUTPUT	.PRG

; global user equations
HALF_Y_RES	EQU	0				; 1: half vertical resolution
DSP_OS		EQU	1				; 1: link with DSP OS

SCR_W:		EQU	300				; width  (x - in pixels)
SCR_H:		EQU	200/(1<<HALF_Y_RES)		; height (y - in pixels)
SCR_D:		EQU	2				; depth  (in bytes)

fps:		EQU	0				; 1: enable fps display
pause:		EQU	0				; 1: enable pause on lshift
cputime:	EQU	0				; 1: enable cputime on control

earxplay:	EQU	1				; 1: enable Earx's MOD player

debug:		EQU	0

		IFEQ	debug
		OPT	D-
		ENDC
		
; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

		INCLUDE	'sys\init.s'			; init demoshell

; ------------------------------------------------------
;		mainloop 
; ------------------------------------------------------

		IFNE	debug
		bsr.w	main_3d
		bra.w	exit
		ENDC
		
mainloop:
		IFNE	pause
		cmp.b	#$2a,$fffffc02.w		; pause
		beq.w	.done				;
		ENDC

		tst.l	vblsync				; vbl wait mode
		bne.b	.always				;

.firstonly:	tst.w	vblwait				; wait for first vbl only
		beq.b	.done				;
		clr.w	vblwait				;
		bra.b	.waitdone			;

.always:	move.w	.var,d0				; wait for next vbl always
		cmp.w	vblwait,d0			;
		beq.b	.done				;


.waitdone:	move.l	main_routine,a0			; main routine
		jsr	(a0)				;
		
		IFNE	fps
		addq.l	#1,frmcnt			; update fps-counter
		move.l	$4ba.w,copy_4ba			;
		ENDC

		move.w	vblwait,.var			; later use

		cmp.l	#2,swapscreens			; number of screens to cycle
		blt.b	.done				;
		lea	screen_adr1,a0			;
		bgt.b	.swap3				;

.swap2:		move.l	(a0),d0				; cycle 2 screens
		move.l	4(a0),(a0)+			;
		move.l	d0,(a0)				;
		
.swap3:		move.l	(a0),d0				; cycle 3 screens
		move.l	4(a0),(a0)+			;
		move.l	4(a0),(a0)+			;
		move.l	d0,(a0)				;
		
.done:
		IFNE	cputime
		cmp.b	#$1d,$fffffc02.w		; control pressed?
		bne.b	.nocpu				;
		move.l	#$000000ff,$ffff9800.w		; yes
.nocpu:
		ENDC
		
		cmpi.b	#$39,$fffffc02.w		; exit
		bne.w	mainloop			;
		bra.w	exit				;

.var:		ds.w	1

; ------------------------------------------------------
;		vbl 50-100 Hz
; ------------------------------------------------------

vbl:		movem.l	d0-a6,-(sp)

		IFNE	pause
		cmp.b	#$2a,$fffffc02.w		; lshift pressed?
		beq.b	.done				; yes
		ENDC

		IFNE	cputime
		cmp.b	#$1d,$fffffc02.w		; control pressed?
		bne.b	.nocpu				;
		clr.l	$ffff9800.w			; yes
.nocpu:
		ENDC

		cmp.l	#2,swapscreens			; set screen_adr
		bge.b	.no 				;
		move.l	screen_adr,d0			; single set
		cmp.l	.var,d0				;
		beq.b	.noset				;
		move.l	d0,.var				;
		bra.b	.set				;

.no:	 	move.l	screen_adr1,d0			; double/tripple set
		cmp.l	.var,d0				;
		beq.b	.noset				;
		move.l	d0,.var				;

.set:		move.l	d0,d1				; set screen
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;
		move.b	d1,$ffff820d.w			;

.noset:		move.l	vbl_routine,a0			; vbl
		jsr	(a0)				;

		addq.w	#1,vblwait			; inc vbl

.done:		movem.l	(sp)+,d0-a6
		rte

.var:		ds.l	1

; --------------------------------------------------------------
;		timer-d 100 Hz
; --------------------------------------------------------------

timer_d:	movem.l	d0-a6,-(sp)
		
		fsave	-(sp)
		fmovem.l fpcr/fpsr/fpiar,-(sp)
		fmovem.x fp0-fp7,-(sp)

		ifne	pause
		cmpi.b	#$2a,$fffffc02.w		; pause
		beq.b	.skip_all			;
		endc

		subq.w	#1,.var				; 300->100Hz sequencer
		bne.b	.skip_sequence			;
		move.w	#3,.var				;

		movea.l	current_fx,a0			; current position
		lea	current_routine_list,a1		; routinelist
		subq.l	#1,(a0)+			; dec
		bne.b	.dont_change			; 0=next part
		addi.l	#24,current_fx			; next part
		
.dont_change:	move.l	(a0)+,(a1)+			; timer routine
		move.l	(a0)+,(a1)+			; vbl routine
		move.l	(a0)+,(a1)+			; main routine
		move.l	(a0)+,(a1)+			; screens to cycle
		move.l	(a0),(a1)			; vblwait type

.skip_sequence:	movea.l	timer_routine,a2
		jsr	(a2)				; timer routine

.skip_all:	fmovem.x (sp)+,fp0-fp7
		fmovem.l (sp)+,fpcr/fpsr/fpiar
		frestore (sp)+
	
		movem.l	(sp)+,d0-a6
		bclr	#4,$fffffa11.w			; clear busybit
		rte

.var:		dc.w	3

; ------------------------------------------------------
;		subroutines & includes
; ------------------------------------------------------

dummy:		rts
		
check_cpu:	movea.l	$5a0.w,a0
.loop:		move.l	(a0)+,d0
		bne.b	.ok				; if no cookie -> ST
		rts
		
.ok:		cmp.l	#"_CPU",d0
		beq.b	.found
		addq.l	#4,a0
		bra.b	.loop
		
.found:		move.l	(a0),cpu_type
		rts

		INCLUDE	'sys\exit.s'			; exit routines
		INCLUDE	'sys\screen.s'			; screen routines
		IFNE	DSP_OS
		INCLUDE	'sys\dsp_os.s'			; dsp os routines
		INCLUDE	'sys\dsp_fix.s'
		ENDC
		
		IFNE	fps
		INCLUDE	'sys\fps.s'			; frames per second
		ENDC
		
		IFNE	earxplay
		INCLUDE	'sys\earx.s'			; Earx's player
		ENDC
		
		include	"engine\manager.s"
		include	"misc.s"
		include	"rt_inits.s"
		include	"gfx.s"
		include	"tgen_96b.s"

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

		EVEN

; videomode settings
; see video.s for available resolutions and how to set them

monitor:	dc.w	0				; 0=vga 1=rgb/tv (init.s auto detect)

; initroutines to run before demo starts
; list ends with dc.l 0

inits:		dc.l	set_hires_screen
		dc.l	pic_show_loading
		
		dc.l	realloc_mod
		dc.l	generate_textures
		dc.l	traj_init
		dc.l	init_3d
		dc.l	set_cache
		
		
		IFNE	earxplay
		dc.l	earx_load
		dc.l	earx_begin
		ENDC
		
		dc.l	0

; demo sequencer list
;
;		dc.l ticks,timer,vbl,main,screens,vblwait
;
;	   ticks : 100Hz frames to run part
;	   timer : address to timer routine (routine runs att 300Hz)
;	     vbl : address to vbl routine
;	    main : address to main routine
;	 screens : number of screens to cycle. valid options:
;                  1 = singlebuffer
;                  2 = doublebuffer
;                  3 = tripple buffer
;                  lower vales are treated as single buffer and
;                  higher values as tripple buffer
;        vblwait : mainloop wait for vbl.
;                  0 = waitvbl if efx run faster than 1 vbl (tripplebuffer only!)
;                  1 = always waitvbl (even if efx is multivbl (always with single/doublebuffer!))

demo_parts:	dc.l	355,timer_3d,dummy,main_3d,3,0
		dc.l	335,timer_3d,dummy,pic_show0,3,0
		dc.l	335,timer_3d,dummy,pic_show1,3,0
		dc.l	335,timer_3d,dummy,pic_show2,3,0
		dc.l	335,timer_3d,dummy,pic_show3,3,0
		dc.l	335,timer_3d,dummy,pic_show4,3,0
		dc.l	330,timer_3d,dummy,pic_show5,3,0
		dc.l	335,timer_3d,dummy,pic_show6,3,0
		dc.l	280,timer_3d,dummy,main_3d,3,0
		

		dc.l	-1,dummy,dummy,rt_init0,1,1
		dc.l	-1,dummy,dummy,scene_init0,1,1
		dc.l	1450,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init1,1,1
		dc.l	-1,dummy,dummy,scene_init1,1,1
		dc.l	1600,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init2,1,1
		dc.l	-1,dummy,dummy,scene_init2,1,1
		dc.l	2150,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init3,1,1
		dc.l	-1,dummy,dummy,scene_init3,1,1
		dc.l	1000,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init4,1,1
		dc.l	-1,dummy,dummy,scene_init4,1,1
		dc.l	500,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init5,1,1
		dc.l	-1,dummy,dummy,scene_init5,1,1
		dc.l	1200,timer_3d,dummy,main_3d,3,0
		
		;dc.l	-1,dummy,dummy,rt_init6,1,1
		;dc.l	-1,dummy,dummy,scene_init6,1,1
		;dc.l	2500,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,rt_init7,1,1
		dc.l	-1,dummy,dummy,scene_init7,1,1
		dc.l	820,timer_3d,dummy,main_3d,3,0
		
		dc.l	-1,dummy,dummy,scene_init_end,1,1
		dc.l	330,timer_3d,dummy,main_3d,3,0
		dc.l	-1,timer_3d,dummy,pic_show_end,3,0
		
		dc.l	-1,dummy,dummy,exit,1,0

current_fx:	dc.l	demo_parts			; current

current_routine_list:
timer_routine:	dc.l	dummy				; timer
vbl_routine:	dc.l	dummy				; vbl
main_routine:	dc.l	dummy				; main
swapscreens:	dc.l	0				; screens
vblsync:	dc.l	0				; vblwait

		EVEN


; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

		EVEN
		;IFNE	*&2
		;ds.w	1
		;ENDC

screen_adr1:	ds.l	1				; screen address 1
screen_adr:						; WORK ADDRESS!
screen_adr2:	ds.l	1				; screen address 2
screen_adr3:	ds.l	1				; screen address 3

vblwait:	ds.w	1				; for fx in less than 1vbl

save_stack:	ds.l	1				; old stackpointer
save_usp:	ds.l	1				; old user stackpointer
save_vbl:	ds.l	1				; old vbl
save_timer_d:	ds.l	1				; old timer-d
save_mfp:	ds.b	4				; old mfp
save_dta:	ds.l	1				; old dta address
save_pal:	ds.l	256+16/2			; old colours (falcon+st/e)
save_video:	ds.b	32+12+2				; videl save
save_keymode:	ds.w	1				; old keyclick mode
save_cacr:	ds.l	1				; old cache settings
dta:		ds.l	11				; new dta buffer

cpu_type:	ds.l	1				; 000, 030, 040, 060

run_dsplock:	ds.b	1
run_locksnd:	ds.b	1
run_getdta:	ds.b	1
run_supervisor:	ds.b	1
run_setvideo:	ds.b	1
run_cache:	ds.b	1
run_keyclick:	ds.b	1
run_player:	ds.b	1
run_ints:	ds.b	1
run_fps:	ds.b	1

		END