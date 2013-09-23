
;
; DUMP
; 
; September 21, 2003
; Anders Eriksson
; ae@dhs.nu
;
; exit.s


		section	text

exit_normal:							;user exit
		bsr.w	dta_restore				;
		bsr.w	dsp_unlock				;
		bsr.w	unlocksnd				;
		move.l	#exit_normal_text,d0			;
		bsr.w	print					;
		bra.w	pterm					;

exit_nostram:							;exit if no stram for dma buffer
		bsr.w	dta_restore				;
		bsr.w	dsp_unlock				;
		bsr.w	unlocksnd				;
		move.l	#exit_nostram_text,d0			;
		bsr.w	print					;
		bra.w	pterm

exit_nomodram:							;exit if no ram for module
		bsr.w	dta_restore				;
		bsr.w	dsp_unlock				;
		bsr.w	unlocksnd				;
		move.l	#exit_nomodram_text,d0			;
		bsr.w	print					;
		bra.w	pterm					;

exit_filenotfound:						;exit if file not found
		bsr.w	dta_restore				;
		bsr.w	dsp_unlock				;
		bsr.w	unlocksnd				;		
		move.l	#exit_filenotfound_text,d0		;
		bsr.w	print					;
		bra.w	pterm					;

exit_unknown:							;exit if fileformat unknown
		bsr.w	dta_restore				;
		bsr.w	dsp_unlock				;
		bsr.w	unlocksnd				;
		move.l	#exit_unknown_text,d0			;
		bsr.w	print					;
		bra.w	pterm					;

exit_dsplocked:							;exit if dsp is locked
		move.l	#exit_dsplocked_text,d0			;
		bsr.w	print					;
		bra.w	pterm					;

exit_sndlocked:							;exit if soundsystem is locked
		bsr.w	dsp_unlock				;
		move.l	#exit_sndlocked_text,d0			;
		bsr.w	print					;
		bra.w	pterm					;


; exit subroutines

dta_restore:	move.l	save_dta,-(sp)				;fsetdta()
		move.w	#$1a,-(sp)				;restore dta
		trap	#1					;
		addq.l	#6,sp					;
		rts

dsp_unlock:	move.w	#$69,-(sp)				;Dsp_Unlock()
		trap	#14					;
		addq.l	#2,sp					;
		rts

unlocksnd:	move.w	#$81,-(sp)				;Unlocksnd()
		trap	#14					;
		addq.l	#2,sp					;
		rts						;


pterm:		clr.w	-(sp)					;pterm()
		trap	#1					;




		section	data


exit_normal_text:
		dc.b	'Thank you for using DUMP.',13,10,0
		even

exit_nostram_text:
		dc.b	'Sorry, this program needs 8000 bytes ST-RAM, it',13,10
		dc.b	'looks like you do not have that.',13,10,0
		even

exit_nomodram_text:
		dc.b	'Sorry, but you do not have enough free',13,10
		dc.b	'ST or TT-RAM for the selected module.',13,10,0
		even

exit_filenotfound_text:
		dc.b	'Sorry, the file could not be found.',13,10,0
		even

exit_unknown_text:
		dc.b	'Sorry, this moduleformat could not be recognized.',13,10,0
		even


exit_dsplocked_text:
		dc.b	'The DSP is already in use by another application.',13,10,0
		even

exit_sndlocked_text:
		dc.b	'The soundsystem is already in use by another application.',13,10,0
		even


		section	text