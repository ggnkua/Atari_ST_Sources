;
;
;
; INCLUDE2.S
;
; Space invaders includes
;
;

		opt	inconce
		include	system\shared.s		;equates

include_init:
		jsr	mal_init
		jsr	scr_init
		rts

include_deinit:
		jsr	mal_deinit
		rts

		include	system\malloc.s
		include	system\new_os3.s	;dsp OS
		include	system\screens.s	;screen res
		include	system\spline.s		;splines
		include	system\cam.s		;camera calculation

