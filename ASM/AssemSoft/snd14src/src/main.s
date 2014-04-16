;
; SNDH testprogram
; 
; January 4, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; main.s

		output .ttp

		comment	HEAD=%111

MAX_HEADER:	equ	200


		section	text

begin:
		include	'init.s'				;init


		bsr.w	load_song				;load snd file
		bcs.s	.loaded_ok				;ok


		move.l	a2,a0					;loading failed
		bsr.w	print_text				;
		bsr.w	get_key					;
		bra.w	exit					;
		
.loaded_ok:	bsr.w	get_songinfo				;get sndh infos
		bsr.w	start_play				;start replay
		
		lea.l	composer_m(pc),a0			;print sndh info
		bsr.w	print_text				;
		move.l	composer_txt,a0				;
		bsr.w	print_text_cl				;

		lea.l	title_m(pc),a0				;
		bsr.w	print_text				;
		move.l	title_txt,a0				;
		bsr.w	print_text_cl				;

		lea.l	ripper_m(pc),a0				;
		bsr.w	print_text				;
		move.l	ripper_txt,a0				;
		bsr.w	print_text_cl				;

		lea.l	conversion_m(pc),a0			;
		bsr.w	print_text				;
		move.l	conversion_txt,a0			;
		bsr.w	print_text_cl				;
		
		lea.l	method_m(pc),a0				;
		bsr.w	print_text				;
		move.l	method_txt,a0				;
		bsr.w	print_text_cl				;

		lea.l	songs_m(pc),a0				;
		bsr.w	print_text				;
		move.l	songs_txt,a0				;
		bsr.w	print_text_cl				;
		

		move.w	#7,-(sp)				;crawkin() wait for key
		trap	#1					;
		addq.l	#2,sp					;


		bsr.w	stop_play				;stop music

		include	'exit.s'				;exit


; includes for sndh playing

		include	snd_load.s				;load/depack snd file
		include	ice_unpa.s				;ice depacker
		include	snd_head.s				;parse sndh header
		include	snd_play.s				;setup irq and play




		section	data

title_text:	dc.b	'SNDH Testplayer v1.4',13,10		;title
		dc.b	'Press any key to stop',13,10,13,10,0	;
		even

composer_m:	dc.b	'  Composer: ',0
title_m:	dc.b	'     Title: ',0
ripper_m:	dc.b	' Ripped by: ',0
conversion_m:	dc.b	'Conversion: ',0
method_m:	dc.b	'    Method: ',0
songs_m:	dc.b	'# of songs: ',0
		even

t_no_inf:	dc.b	'?',0
t_songs:	ds.b	6
t_timer:	dc.b	'Timer ',0
		even

t_vblon		dc.b	"VBI, ?? Hz",0
t_vbloff:	dc.b	'Off!',0
t_vbiovr:	dc.b	", VBL override!",0
t_method:	ds.b	40					;30 char buffer for constructin method info
t_musicmon	dc.b	"Can't play MusicMon tunes!",0
		even


		section	bss


save_dta:	ds.l	1					;old dta
dta:		ds.l	11					;new dta
filename:	ds.l	1					;filename address
song_address:	ds.l	1					;Address of loaded tune
MiNT_domain:	ds.b	1					;are we in mint domain?
		ds.b	1

		end