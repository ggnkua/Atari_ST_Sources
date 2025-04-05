;
; SYSTEM FOR ST-DEMOSCREEN ONLINE COMPETITION
;
; Devpac and Assemble version
;
; Anders Eriksson (Evil / Dead Hackers Society)
; ae@dhs.nu
;
; July 1, 2001
;


playmusic:	equ	1	; 0 = Silent 
				; 1 = Play SNDH-music (good to see total CPU-useage)


; --------------------------------------------------------------
; ------------- Section TEXT -----------------------------------
; --------------------------------------------------------------

		section	text

		include	'devp_sys.s'	; demo system include, keep it here!

		
; --------------------------------------------------------------
; ------------- Effect INIT ------------------------------------
; --------------------------------------------------------------
		
compo_init:

; Pur your init code here.

		rts


; --------------------------------------------------------------
; ------------- Mainloop ---------------------------------------
; --------------------------------------------------------------
		
compo_mainrout:

; Put your main loop here.

		movea.l	screen_adr,a0
		lea.l	160*63(a0),a0

		lea.l	jasmin+34,a1

		add.l	scrollvar,a1
		add.l	#160,scrollvar
		cmp.l	#160*125,scrollvar
		blt.s	docopy
		clr.l	scrollvar
docopy:
		move.w	#75-1,d7
copy_y:		move.w	#160/4-1,d6
copy_x:		move.l	(a1)+,(a0)+
		dbra	d6,copy_x
		dbra	d7,copy_y



		rts

scrollvar:	ds.l	1

; --------------------------------------------------------------
; ------------- VBL 50/60Hz ------------------------------------
; --------------------------------------------------------------

compo_vblrout:

; Put your VBL routine here.

		lea.l	jasmin+2,a0
		jsr	setpal

		rts


; --------------------------------------------------------------
; ------------- Timer-C 200Hz ----------------------------------
; --------------------------------------------------------------
		
compo_timerrout:

; Put your 200Hz routine here.

		rts


		
; --------------------------------------------------------------
; ------------- Section DATA -----------------------------------
; --------------------------------------------------------------
		
		section	data

; Put your data here.

jasmin:		incbin	'jasmin.pi1'
		even

; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

		section	bss

; Put your BSS buffers here.



		end