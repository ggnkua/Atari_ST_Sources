; Fullscreen template
; 224 byte linewidth (approx 408 usable pixels per line (screen is shifted about 8 pixels to the right))
; Works only on STe
;
; Double buffered screens
;
; September 3, 2011

		section	text

fullscr_ste_init:
		rts

fullscr_ste_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	fullscr_ste_copy_pic
		bsr	fullscr_ste_code_copy
		rts


fullscr_ste_vbl:
		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		movem.l	fullscr_ste_blackpal,d0-d7	;Set palette
		movem.l	d0-d7,$ffff8240.w		;

		lea	fullscr_ste_blackpal,a0		;Fade in palette
		lea	fullscr_ste_picture,a1		;
		jsr	component_fade			;

		move.l	screen_adr,d0			;Swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;
		rts

fullscr_ste_main:
		rts

fullscr_ste_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code
		dcb.w	66,$4e71			;Time for user to set up registers etc

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts


fullscr_ste_normal_begin:
		;Code for scanlines 0-226 and 229-272
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26,$4e71
fullscr_ste_normal_end:


fullscr_ste_lower_begin:
		;Code for scanline 227-228 (lower border special case)
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	23,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26,$4e71
fullscr_ste_lower_end:



fullscr_ste_copy_pic:
		;Copy picture to both workscreens
		move.l	screen_adr,a0
		lea	160(a0),a0

		move.l	screen_adr2,a1
		lea	160(a1),a1

		lea	fullscr_ste_picture+32,a2

		move.w	#273-1,d7
.y:		move.w	#416/2/4-1,d6
.x:
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+

		dbra	d6,.x
		lea	224-208(a0),a0
		lea	224-208(a1),a1
		dbra	d7,.y
		rts


fullscr_ste_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#fullscr_ste_normal_begin,d0	;Copy the first 227 scanlines
		move.l	#fullscr_ste_normal_end,d1	;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#fullscr_ste_lower_begin,d0	;Copy the lower border special case (2 scanlines)
		move.l	#fullscr_ste_lower_end,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#fullscr_ste_normal_begin,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#fullscr_ste_normal_end,d1	;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


		section	data

fullscr_ste_blackpal:
		dcb.w	16,$0000			;Black palette

fullscr_ste_picture:
		incbin	'fullscr.ste/pic.4pl'		;416x273 four bitplanes and 32 byte palette at the start
		even

		section	text

