;
;
;
; INCLUDES.S
;
; a list of all the .s files that should be included from \system
;
;
;

		opt	inconce
		include	system\shared.s		;equates

include_init:
		jsr	mal_init
		jsr	scr_init
		jsr	t3d_init
		rts

include_deinit:
		jsr	mal_deinit
		rts

		include	system\malloc.s
		include	system\new_os3.s	;dsp OS
		include	system\screens.s	;screen res
		include	system\spline.s		;splines
		include	system\cam.s		;camera calculation
		include	system\t3d.s		;tat's 3d

