; DEAD HACKERS SOCIETY
;
; Falcon Demosystem v18
; (c) 1997 - 2011
;
; main.s


scr_w:		equ	640					;Width  (x - in pixels)
scr_h:		equ	480					;Height (y - in pixels)
scr_d:		equ	1					;Depth  (in bytes)

dspmodmusic:	equ	1					;1 = Use dspmod music (bITmASTER / BSW)
mp2music:	equ	0					;1 = Use mpeg1 layer 2 music (NoRing & NoBrain / NoCrew)
wavemusic:	equ	0					;1 = Use 12517 Hz 8bit-mono wave music
acemusic:	equ	0					;1 = Use ACE Tracker music (Thomas / New Beat)

def_vga_freq:	equ	60					;VGA frequency (60 or 100 Hz)
def_rgb_freq:	equ	50					;RGB frequency (50 or 60 Hz)

lutp_enable:	equ	0					;1 = Enable routine/bss for hicolour lookup table (alpha layer)
mouse:		equ	0					;1 = Enable mouse routine (exit on right mouse button)
screenshot:	equ	0					;0 = No screenshot 1 = save screenshot at exit (IFF for bitplane and TARGA for hicol)


		section	text

; --------------------------------------------------------------
;		Demosystem includes
; --------------------------------------------------------------

		include	'sys/init.s'				;Demosystem init
		include	'sys/mainloop.s'			;Demosystem core mainloop
		include	'sys/vbl.s'				;Demosystem core vbl
		include	'sys/timer.s'				;Demosystem core timer
		include	'sys/exit.s'				;Demosystem exit
		include	'sys/video.s'				;Videolib
		include	'sys/loader.s'				;File loader rout
		include	'sys/common.s'				;Common code and data used overall
		include	'sys/music.s'				;Music driver includes
		;include	'sys/fade.s'			;Generic colour routines
		;include	'sys/ice.s'			;ICE depacker
		;include	'sys/c2p_4pl.s'			;C2P routines (Kalms / TBL)
		;include	'sys/c2p_6pl.s'			;
		;include	'sys/c2p_6hi.s'			;
		;include	'sys/c2p_8pl.s'			;

	ifne	mouse						;Mouse routine
		include	'sys/mouse.s'				;
	endc							;

	ifne	screenshot					;Make screenshot at exit
		include	'sys/scrnshot.s'			;
	endc 							;


; --------------------------------------------------------------
;		Demo part includes
; --------------------------------------------------------------




		section	data

; Initroutines to run before the demo starts
inits:		dc.l	video_5					;Set initital resolution
		dc.l	black_palette				;Black palette
		dc.l	clear_all_screens			;Pretty obvious
		dc.l	0


;		dc.l Ticks,S_PAR,Timer,T_PAR,VBL,V_PAR,Main,M_PAR,Screens,VBLwait
;
;	   Ticks : 100Hz frames to run part
;	    S_PAR: Parameter to the demosystem: 0 = Nothing, 1 = Run part one time only
;	   Timer : Address to timer routine (routine runs att 300Hz)
;           T_PAR: Parameter to the timer, found in variable "timer_param", for no param use "0"
;	     VBL : Address to VBL routine
;           V_PAR: Parameter to the VBL, found in variable "vbl_param", for no param use "0"
;	    Main : Address to main routine
;           M_PAR: Parameter to the mainrout, found in variable "main_param", for no param use "0"
;	 Screens : Number of screens to cycle. Valid options: 1, 2, 3
;        VBLwait : Mainloop wait for VBL
;                  0 = WaitVBL if efx run faster than 1 VBL (tripplebuffer only!)
;                  1 = Always waitVBL (even if efx is multiVBL (always with single/doublebuffer!))
;
; video modes:
; video_1=288/144*100*16  video_2=288*200*16  video_3=288*200*8  video_4=576*400*8
; video_5=320*240*16      video_6=320*240*8   video_7=640*480*8

demo_parts:
		dc.l	-1,0,dummy,0,dummy,0,dummy,0,1,1
		dc.l	-1,0,dummy,0,dummy,0,exit,0,1,1


		end

