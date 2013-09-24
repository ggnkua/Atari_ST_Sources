; Falcon demosystem
;
; September 11, 2011
;
; music.s

		section	text


;-------------- Include music driver
	ifne	dspmodmusic					;ProTracker player (bITmASTER / BSW)
		include	'sys/dspmod.s'				;
	endc							;

	ifne	mp2music					;MPEG Audio player (NoRing & NoBrain / NoCrew)
		include	'sys/mp2.s'				;
	endc							;

	ifne	wavemusic					;Wave Audio player
		include	'sys/wave.s'				;
	endc							;

	ifne	acemusic					;ACE Tracker player (Thomas / New Beat)
		include	'sys/replace.s'				;
	endc							;


;-------------- Init music driver
music_init:

	ifne	dspmodmusic					;
		jsr	dspmod_init_player			;
		move.l	#dspmod_module,filename			;
		jsr	dspmod_load_module			;Load module/reserve mem
		jsr	dspmod_begin				;Init musicroutine
		move.w	#1,do_restore_mod			;
	endc							;

	ifne	mp2music					;
		jsr	mp2_load				;Load mpeg file/reserve mem
		jsr	mp2_begin				;Init mpeg rout and start playing
		move.w	#1,do_restore_mp2			;
	endc							;

	ifne	wavemusic					;
		jsr	wave_load				;Load wave file/reserve mem
		jsr	wave_start				;Start playing
		move.w	#1,do_restore_wav			;
	endc							;

	ifne	acemusic					;
		jsr	ace_init				;Initialize replace
		jsr	ace_start				;Play music
		jsr	ace_stop				;
		jsr	ace_init				;Initialize replace again, to workaround a bug in ACE with first time init
		jsr	ace_start				;Play music
		move.w	#1,do_restore_ace			;
	endc							;

		rts

;-------------- Call music driver
music_play:

	ifne	dspmodmusic					;Modplayer
		bsr.w	dspmod_vbl				;
	endc							;

		rts

;-------------- Exit music driver
music_exit:

	ifne	dspmodmusic					;Restore DSPMOD
		tst.w	do_restore_mod				;
		beq.s	.no_music				;
		bsr	dspmod_end				;
.no_music:							;
	endc							;

	ifne	mp2music					;Restore MPEG Layer 2 player
		tst.w	do_restore_mp2				;
		beq.s	.no_music				;
		bsr	mp2_end					;
.no_music:							;
	endc							;

	ifne	wavemusic					;Stop WAVE player
		tst.w	do_restore_wav				;
		beq.s	.no_music				;
		bsr	wave_end				;
.no_music:							;
	endc							;

	ifne	acemusic					;Restore ACE Tracker
		tst.w	do_restore_ace				;
		beq.s	.no_music				;
		bsr	ace_stop				;
.no_music:							;
	endc							;

		rts

		section	data

	ifne	dspmodmusic
dspmod_module:	dc.b	'music\syn.mod',0
		even
	endc

	ifne	mp2music
mp2_file:	dc.b	'music\cubetro.mp2',0
		even
	endc

	ifne	wavemusic
wave_file:	dc.b	'music\cubetro.wav',0
		even
	endc

	ifne	acemusic
ace_module:	incbin	'music/waving.am'
		even
	endc

		section	text

