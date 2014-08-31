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
; Dead Hackers Society Falcon Demoshell v13
; April 8, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; soundtracker replay: Bitmaster / TCE
; video save/restore : Aura & Mugwumps
;
; Slightly modified for Alive issue one in November 2000.
; Light Version (no mp2 replay, ice decrunch, 2 video modes, 
; no startup menu,...) by Matt'US Alem
;
; Please notice that this demosys is made for use within DHS
; and the way we like it to work. It might be total crap
; for others, then instead of flaming us, just erase it :)
;
; This is the main routine to run the I AM A TROLL demo
; Coded by Matt'US Alem at the ParaCon III (31/11/2001)
; look at the includes...
;
; main.s

		output	.app

		opt	p=68030/68882	;68030+68882 code allowed
		comment HEAD=%111		;fastload/loadalt/mallocalt = ON
					;setup max screensize used in the demo
scr_w:		equ	320		;width  (x - in pixels)
scr_h:		equ	240		;height (y - in pixels)
scr_d:		equ	2		;depth  (in bytes)

dspmodmusic:	equ	1		;1 = use dspmod music


; --------------------------------------------------------------
		section	text
; --------------------------------------------------------------

		include	'sys\init.s'	;init demosshell


; --------------------------------------------------------------
;		mainloop 
; --------------------------------------------------------------

mainloop:
		tst.l	vblsync		;vbl wait mode
		bne.s	.always		;

.firstonly:		tst.w	vblwait		;wait for first vbl only
		beq.s	.done		;
		clr.w	vblwait		;
		bra.s	.waitdone		;

.always:		move.w	.var,d0		;wait for next vbl always
		cmp.w	vblwait,d0		;
		beq.s	.done		;


.waitdone:		move.l	main_routine,a0	;main routine
		jsr	(a0)		;

		move.w	vblwait,.var	;later use

.nah:
		cmp.l	#2,swapscreens	;number of screens to cycle
		blt.s	.done		;
		lea.l	screen_adr1,a0	;
		bgt.s	.swap3		;

.swap2:		move.l	(a0),d0		;cycle 2 screens
		move.l	4(a0),(a0)+		;
		move.l	d0,(a0)		;
		bra.s	.done		;

.swap3:		move.l	(a0),d0		;cycle 3 screens
		move.l	4(a0),(a0)+		;
		move.l	4(a0),(a0)+		;
		move.l	d0,(a0)		;

.done:
		
		cmp.b	#$39,$fffffc02.w	;exit
		bne.w	mainloop		;
		bra.w	exit		;

.var:		ds.w	1



; --------------------------------------------------------------
;		vbl 50-100 Hz
; --------------------------------------------------------------

vbl:		movem.l	d0-a6,-(sp)

		cmp.l	#2,swapscreens	;set screen_adr
		bge.s	.no 		;
		move.l	screen_adr,d0	;single set
		cmp.l	.var,d0		;
		beq.s	.noset		;
		move.l	d0,.var		;
		bra.s	.set		;

.no:	 	move.l	screen_adr1,d0	;double/tripple set
		cmp.l	.var,d0		;
		beq.s	.noset		;
		move.l	d0,.var		;

.set:		move.l	d0,d1		;set screen
		lsr.w	#8,d0		;
		move.l	d0,$ffff8200.w	;
		move.b	d1,$ffff820d.w	;

.noset:		move.l	vbl_routine,a0	;vbl
		jsr	(a0)		;

		addq.w	#1,vblwait		;inc vbl

		bsr.w	dspmod_vbl			;modplayer

.done:		movem.l	(sp)+,d0-a6
		rte

.var:		ds.l	1



; --------------------------------------------------------------
;		timer-d 100 Hz
; --------------------------------------------------------------

timer_d:		movem.l	d0-a6,-(sp)

		move.l	current_fx,a0		;current position
		lea.l	vbl_routine,a1		;routinelist
		subq.l	#1,(a0)+			;dec
		bne.s	.done			;0=next part
		add.l	#24,current_fx		;next part
.done:		move.l	(a0)+,a2			;timer routine
		move.l	(a0)+,(a1)+			;vbl routine
		move.l	(a0)+,(a1)+			;main routine
		move.l	(a0)+,(a1)+			;screens to cycle
		move.l	(a0),(a1)			;vblwait type

		jsr	(a2)			;timer routine


.done2:		movem.l	(sp)+,d0-a6
		bclr	#4,$fffffa11.w		;clear busybit
		rte



; --------------------------------------------------------------
;		subroutines & includes
; --------------------------------------------------------------

dummy:		rts

blackpal:		lea.l	$ffff9800.w,a0		;black palette
		move.w	#256-1,d7			;
.loop:		clr.l	(a0)+			;
		dbra	d7,.loop			;
		rts				;


		include	'sys\exit.s'		;exit routines
		include	'sys\video.s'		;light videolib
		include	'sys\loader.s'		;loader rout
		include	'sys\dspmod.s'					;

		include	'tc_line.s'			;trace lines 
		include	'3d.s'			;3D rotation engine
		include	'logo.s'			;TC logo
		include	'com_eff.s'			;fade, text effect...
		include	'rotozoom.s'		;rotozoomer
		include	'flame.s'			;flame effect


; --------------------------------------------------------------
		section	data
; --------------------------------------------------------------

		even


; videomode settings
; see video.s for available resolutions and how to set them

monitor:		dc.w	0			;0=vga 1=rgb/tv (init.s auto detect)

vga_freq:		dc.w	60			;60/100 Hz
rgb_freq:		dc.w	50			;50/60 Hz

detail:		dc.w	1			;0=low 1=high


; initroutines to run before demo starts
; list ends with dc.l 0

inits:
		dc.l	video_2			;set resolution
		dc.l	blackpal			;black palette

		dc.l	dspmod_load			;load module/reserve mem
		dc.l	dspmod_begin		;init musicroutine						;
		dc.l	init_fade			;create fade table
		dc.l	Init_rotozoomer		;create texture
		dc.l	init_3Drot			;create mul tables
		dc.l	Init_Flame1			;create text logo
		dc.l	Init_Flame2			;bis

		dc.l	0


; demoparts list
;
; dc.l ticks,timer,vbl,main,screens,vblwait
;
;	   ticks : 100Hz frames to run part
;	   timer : address to timer routine
;	     vbl : address to vbl routine
;	    main : address to main routine
;	 screens : number of screens to cycle. valid options:
;                  1 = singlebuffer
;                  2 = doublebuffer
;                  3 = tripple buffer
;                  lower vales are treated as single buffer and
;                  higher values as tripple buffer
;        vblwait : mainloop wait for vbl.
;                  0 = waitvbl only if efx <1vbl (valid for tripbuf only)
;                  1 = always waitvbl

demo_parts:
;
; 505 music breakpoints (in sec) : 0s 11s 31s
;		
		dc.l	20,dummy,video_5,buffers_clear,1,1	;set res=320x200xTC
	
		dc.l	300,dummy,dummy,intro_text,1,1

		dc.l	250,dummy,dummy,table_fade,1,1

		dc.l	520,dummy,dummy,copy_logo1,1,1

		dc.l	300,dummy,dummy,table_fade,1,1

		dc.l	2425,dummy,dummy,Main_RZ,1,1

		dc.l	300,dummy,dummy,table_fade,1,1
		
		dc.l	20,dummy,video_5,buffers_clear,1,1
		
		dc.l	30,dummy,dummy,sb3D_back,2,1
		dc.l	2440,dummy,dummy,sb3D_Main,2,1

		dc.l	300,dummy,dummy,table_fade,1,1

		REPT 2
		dc.l	500,dummy,dummy,FlameCredits,1,1
		dc.l	500,dummy,dummy,Text_Flames1,1,1
		dc.l	500,dummy,dummy,FlameCredits,1,1
		dc.l	500,dummy,dummy,Text_Flames2,1,1
		ENDR

		dc.l	300,dummy,dummy,table_fade,1,1

		dc.l	300,dummy,dummy,credits1,1,1
		dc.l	300,dummy,dummy,table_fade,1,1

		dc.l	300,dummy,dummy,credits2,1,1
		dc.l	300,dummy,dummy,table_fade,1,1
		
		dc.l	300,dummy,dummy,credits3,1,1
		dc.l	300,dummy,dummy,table_fade,1,1

		dc.l	300,dummy,dummy,credits4,1,1
		dc.l	300,dummy,dummy,table_fade,1,1
		
		dc.l	300,dummy,dummy,endtext,1,1
		dc.l	700,dummy,dummy,table_fade,1,1

		dc.l	-1,dummy,dummy,exit,1,1			;exit


current_fx:		dc.l	demo_parts				;current
vbl_routine:	dc.l	dummy					;vbl
main_routine:	dc.l	dummy					;main
swapscreens:	ds.l	1					;screens
vblsync:		ds.l	1					;vblwait



; --------------------------------------------------------------
		section	bss
; --------------------------------------------------------------

		even

runlevel:		ds.w	1
vblwait:		ds.w	1					;for fx in less than 1vbl
screen_adr1:	ds.l	1					;screen address 1
screen_adr:							;WORK ADDRESS!
screen_adr2:	ds.l	1					;screen address 2
screen_adr3:	ds.l	1					;screen address 3
save_stack:		ds.l	1					;old stackpointer
save_timer_d:	ds.l	1					;old timer-d
save_vbl:		ds.l	1					;old vbl
save_mfp:		ds.l	1					;old mfp
save_dta:		ds.l	1					;old dta address
save_pal:		ds.l	256+8					;old colours (falcon+st/e)
save_video:		ds.b	32+12+2					;videl save
save_keymode:	ds.w	1					;old keyclick mode
dta:		ds.l	11					;new dta buffer

		end