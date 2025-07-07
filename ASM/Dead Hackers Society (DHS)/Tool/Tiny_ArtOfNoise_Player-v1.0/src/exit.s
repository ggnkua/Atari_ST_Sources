;
; TAP
; Tiny ArtOfNoise Player
; 
; May 31, 2000
;
; Anders Eriksson
; ae@dhs.nu
;
; exit.s


		section	text

exit_normal:	move.l	#exit_normal_text,exit_text		;user exit
		bra.w	exit_all				;

exit_nomodram:	move.l	#exit_nomodram_text,exit_text		;exit if no ram for module
		bra.w	exit_all				;

exit_filenotfound:						;exit if file not found
		move.l	#exit_filenotfound_text,exit_text	;
		bra.w	exit_all				;

exit_not_aon:	move.l	#exit_not_aon_text,exit_text		;not aon file
		bra.w	exit_all

exit_dsplocked:	move.l	#exit_dsplocked_text,exit_text		;exit if dsp is locked
		bra.w	dsp_unlock				;

exit_sndlocked:	move.l	#exit_sndlocked_text,exit_text		;exit if soundsystem is locked
		bra.w	unlocksnd				;	



		nop

exit_all:

dta_restore:	move.l	save_dta,-(sp)				;fsetdta()
		move.w	#$1a,-(sp)				;restore dta
		trap	#1					;
		addq.l	#6,sp					;

unlocksnd:	move.w	#$81,-(sp)				;Unlocksnd()
		trap	#14					;
		addq.l	#2,sp					;

dsp_unlock:	move.w	#$69,-(sp)				;Dsp_Unlock()
		trap	#14					;
		addq.l	#2,sp					;

		move.l	exit_text,d0
		bsr.w	print

pterm:		clr.w	-(sp)					;pterm()
		trap	#1					;




		section	data


exit_normal_text:
		dc.b	'Thank you for using TAP.',13,10,0
		even

exit_nomodram_text:
		dc.b	'Sorry, but you do not have enough free',13,10
		dc.b	'ST or TT-RAM for the selected module.',13,10,0
		even

exit_filenotfound_text:
		dc.b	'Sorry, the file could not be found.',13,10,0
		even

exit_dsplocked_text:
		dc.b	'The DSP is already in use by another application.',13,10,0
		even

exit_sndlocked_text:
		dc.b	'The soundsystem is already in use by another application.',13,10,0
		even

exit_not_aon_text:
		dc.b	'The file could not be recoginized as Art of Noise.',13,10,0
		even



exit_text:	dc.l	exit_normal_text

		section	text
