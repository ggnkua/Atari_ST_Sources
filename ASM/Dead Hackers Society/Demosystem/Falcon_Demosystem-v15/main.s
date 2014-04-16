; oOOOOOOOo     oOOo     oOOo  oOOOOOOOOOOo
; OOOO   OOOo   OOOO     OOOO  OOOOO
; OOOO    OOOo  OOOO     OOOO  OOOOO
; OOOOOo  OOOO  OOOOOOOOOOOOO  OOOOOOOOOOOo
; OOOOOO  OOOO  OOOOOo   OOOO        OOOOOO
; OOOOOO  OOOO  OOOOOO   OOOO        OOOOOO
; OOOOOO  OOOO  OOOOOO   OOOO        OOOOOO
; OOOOOO OOOO   OOOOOO   OOOO        OOOOOO
; OOOOOOOOO     OOOOOO   OOOO  oOOOOOOOOOOO
;
; Dead Hackers Society Falcon Demoshell v15
; November 3, 1999 - February 8, 2004
;
; Recent changes/fixes:
;
; November 16, 2003: CT60-fixed DSPMOD
; January  20, 2004: Fixed Dsp_Lock(), Locksnd() and fgetdta()
; February 07, 2004: Timer routines run at 300Hz rather than 100Hz 
;                    (even by 100, 60 and 50Hz-VBL's) should make
;                    varaible-framerate effects look a bit smoother.
;                    Timing table for sequencer stands att 100Hz.
; February 07, 2004: Removed lame buggy FPS counting, will make a new
;		     better one later.
; February 08, 2004: I introduced a silly bug in v14 that made no
;		     timer routines run! Argh. Fixed now.
;		     Additionally I had put the wrong timer-divide
;		     value.. Error errors errors.. I hope it's OK now!
;
;
; Bugreports to:
;
; Anders Eriksson
; ae@dhs.nu
;
;
;  mpeg 1 layer 2 player: Noring and Nobrain of NoCrew
;    soundtracker replay: Bitmaster / TCE
;     video save/restore: Aura & Mugwumps
;
; main.s
;
; Check at the bottom of this file for init-list, includes,
; and demo sequencer part-list.



		opt	p=68030/68882,NOCASE			;68030+68882 code allowed
		comment HEAD=%111				;fastload/loadalt/mallocalt = ON

scr_w:		equ	640					;width  (x - in pixels)
scr_h:		equ	480					;height (y - in pixels)
scr_d:		equ	1					;depth  (in bytes)

startupmenu:	equ	0					;1 = enable startup menu

dspmodmusic:	equ	0					;1 = use dspmod music
mp2music:	equ	0					;1 = use mpeg1 layer 2 music
								;select which mod or mp2 file
								;to load in sys/dspmod.s or
								;sys/mp2.s

pause:		equ	0					;1 = enable pause on left-shift
cputime:	equ	0					;1 = enable vbl-time on control

def_vga_freq:	equ	60					;VGA frequency (60 or 100Hz)
def_rgb_freq:	equ	50					;RGB frequency (50 or 60Hz)

def_detailmode:	equ	1					;Detail mode (just a dumb flag for demos
								;supporting more than one level of detail)



; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------

		include	'sys\init.s'				;init demosshell


; --------------------------------------------------------------
;		mainloop 
; --------------------------------------------------------------

mainloop:
		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done					;
		endc

		tst.l	vblsync					;vbl wait mode
		bne.s	.always					;
.firstonly:	tst.w	vblwait		
								;wait for first vbl only
		beq.s	.done					;
		clr.w	vblwait					;
		bra.s	.waitdone				;

.always:	move.w	.var,d0					;wait for next vbl always
		cmp.w	vblwait,d0				;
		beq.s	.done					;


.waitdone:	move.l	main_routine,a0				;main routine
		jsr	(a0)					;

		move.w	vblwait,.var				;later use

		cmp.l	#2,swapscreens				;number of screens to cycle
		blt.s	.done					;
		lea.l	screen_adr1,a0				;
		bgt.s	.swap3					;

.swap2:		move.l	(a0),d0					;cycle 2 screens
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;
		bra.s	.done					;

.swap3:		move.l	(a0),d0					;cycle 3 screens
		move.l	4(a0),(a0)+				;
		move.l	4(a0),(a0)+				;
		move.l	d0,(a0)					;

.done:
		ifne	cputime
		cmp.b	#$1d,$fffffc02.w
		bne.s	.nocpu
		move.l	#$000000ff,$ffff9800.w
.nocpu:
		endc
		
		cmp.b	#$39,$fffffc02.w			;exit
		bne.w	mainloop				;
		bra.w	exit					;

.var:		ds.w	1



; --------------------------------------------------------------
;		vbl 50-100 Hz
; --------------------------------------------------------------

vbl:		movem.l	d0-a6,-(sp)

		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done					;
		endc

		ifne	cputime
		cmp.b	#$1d,$fffffc02.w
		bne.s	.nocpu
		clr.l	$ffff9800.w
.nocpu:
		endc


		cmp.l	#2,swapscreens				;set screen_adr
		bge.s	.no 					;
		move.l	screen_adr,d0				;single set
		cmp.l	.var,d0					;
		beq.s	.noset					;
		move.l	d0,.var					;
		bra.s	.set					;

.no:	 	move.l	screen_adr1,d0				;double/tripple set
		cmp.l	.var,d0					;
		beq.s	.noset					;
		move.l	d0,.var					;

.set:		move.l	d0,d1					;set screen
		lsr.w	#8,d0					;
		move.l	d0,$ffff8200.w				;
		move.b	d1,$ffff820d.w				;

.noset:		move.l	vbl_routine,a0				;vbl
		jsr	(a0)					;

		addq.w	#1,vblwait				;inc vbl

		ifne	dspmodmusic
		bsr.w	dspmod_vbl				;modplayer
		endc

.done:		movem.l	(sp)+,d0-a6
		rte

.var:		ds.l	1



; --------------------------------------------------------------
;		timer-d 100 Hz
; --------------------------------------------------------------

timer_d:	movem.l	d0-a6,-(sp)

		ifne	pause
		cmp.b	#$2a,$fffffc02.w			;pause
		beq.s	.done2					;
		endc

		subq.w	#1,.var					;300->100Hz sequencer
		bne.s	.skip_sequence				;
		move.w	#3,.var					;

		move.l	current_fx,a0				;current position
		lea.l	timer_routine,a1			;routinelist
		subq.l	#1,(a0)+				;dec
		bne.s	.done					;0=next part
		add.l	#24,current_fx				;next part
.done:		move.l	(a0)+,(a1)+				;timer routine
		move.l	(a0)+,(a1)+				;vbl routine
		move.l	(a0)+,(a1)+				;main routine
		move.l	(a0)+,(a1)+				;screens to cycle
		move.l	(a0),(a1)				;vblwait type

.skip_sequence:	move.l	timer_routine,a2		
		jsr	(a2)					;timer routine

.nah:

.done2:		movem.l	(sp)+,d0-a6
		bclr	#4,$fffffa11.w				;clear busybit
		rte
.var:		dc.w	3



; --------------------------------------------------------------
;		subroutines & includes
; --------------------------------------------------------------

dummy:		rts

blackpal:	lea.l	$ffff9800.w,a0				;black palette
		move.w	#256-1,d7				;
.loop:		clr.l	(a0)+					;
		dbra	d7,.loop				;
		rts						;



		include	'sys\exit.s'				;exit routines
		include	'sys\video.s'				;videolib
		include	'sys\loader.s'				;loader rout

		ifne	dspmodmusic				;
		include	'sys\dspmod.s'				;tracker player
		endc						;

		ifne	mp2music				;
		include	'sys\mp2.s'				;mpeg player
		endc						;

		ifne	startupmenu				;
		include	'sys\startup.s'				;startup menu
		endc						;

		


		
; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even


; videomode settings
; see video.s for available resolutions and how to set them

monitor:	dc.w	0					;0=vga 1=rgb/tv (init.s auto detect)

vga_freq:	dc.w	def_vga_freq				;60/100 Hz
rgb_freq:	dc.w	def_rgb_freq				;50/60 Hz

detail:		dc.w	def_detailmode				;0=low 1=high



; initroutines to run before demo starts
;
; REMEMBER!
; Always start music at the end! Or you will get unsynced
; with the music on machines with different speed than your own!
; 
; list ends with dc.l 0

inits:
		dc.l	video_2					;set resolution
		dc.l	blackpal				;black palette


		ifne	dspmodmusic				;
		dc.l	dspmod_load				;load module/reserve mem
		dc.l	dspmod_begin				;init musicroutine
		endc						;

		ifne	mp2music				;
		dc.l	mp2_load				;load mpeg file/reserve mem
		dc.l	mp2_begin				;init mpeg rout and start playing
		endc

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


;-------------- small test routines - remove them
red:		move.l	#$ff000000,$ffff9800.w
		rts
green:		move.l	#$00ff0000,$ffff9800.w
		rts
blue:		move.l	#$000000ff,$ffff9800.w 
		rts
not:		not.l	$ffff9800.w
		rts
;------------------------------------------------

demo_parts:
		; test so that timer and vbl works normally
		dc.l	500,not,red,dummy,1,1
		dc.l	500,not,green,dummy,1,1
		dc.l	500,not,blue,dummy,1,1


		;dummy effect doing nothing 
		dc.l	-1,dummy,dummy,dummy,1,1

		;exit demo
		dc.l	-1,dummy,dummy,exit,1,1



current_fx:	dc.l	demo_parts				;current
timer_routine:	dc.l	dummy					;timer
vbl_routine:	dc.l	dummy					;vbl
main_routine:	dc.l	dummy					;main
swapscreens:	ds.l	1					;screens
vblsync:	ds.l	1					;vblwait


; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even

runlevel:	ds.w	1
vblwait:	ds.w	1					;for fx in less than 1vbl
screen_adr1:	ds.l	1					;screen address 1
screen_adr:							;WORK ADDRESS!
screen_adr2:	ds.l	1					;screen address 2
screen_adr3:	ds.l	1					;screen address 3
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
