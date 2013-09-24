; Nullos Tracker Krap
;
; exit.s
;
; August 14, 2001
;
; Anders Eriksson
; ae@dhs.nu

		section	text


exit:

		move.w	#$81,-(sp)				;Unlocksnd()
		trap	#14					;
		addq.l	#2,sp					;

exit_snd_was_locked:
		move.w	#$69,-(sp)				;Dsp_Unlock()
		trap	#14					;
		addq.l	#2,sp					;

exit_dsp_was_locked:
		move.l	error_text,d0				;
		bsr.w	print					;

		move.l	save_dta,-(sp)				;fsetdta() restore dta
		move.w	#$1a,-(sp)				;
		trap	#1					;
		addq.l	#6,sp					;

		
		clr.w	-(sp)					;pterm()
		trap	#1					;


		section	data


text_dsplocked:	dc.b	'Error.',13,10,'The DSP is busy.',13,10,0
		even

text_sndlocked:	dc.b	'Error.',13,10,'The soundsystem is busy.',13,10,0
		even

text_noram:	dc.b	'Error.',13,10,'Not enough memory to load module.',13,10,0
		even

text_file:	dc.b	'Error.',13,10,'File not found.',13,10,0
		even

text_filetype:	dc.b	'Error.',13,10,'This filetype is not supported.',13,10,0

		section	text