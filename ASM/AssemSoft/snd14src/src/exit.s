;
; SNDH testprogram
; 
; January 4, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; exit.s

		section	text


exit:		move.l	save_dta,-(sp)				;fsetdta()
		move.w	#$1a,-(sp)				;restore dta
		trap	#1					;
		addq.l	#6,sp					;

		clr.w	-(sp)					;pterm()
		trap	#1					;

