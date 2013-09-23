; Fullscreen template
; 230 byte linewidth (approx 408 usable pixels per line (8 most-right pixels is trashed on real machines))
; Works on both ST and STe
;
; Double buffered screens
;
; September 3, 2011

		section	text

fullscr_st_init:
		rts

fullscr_st_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	fullscr_st_copy_pic
		bsr	fullscr_st_code_copy
		rts


fullscr_st_vbl:
		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		movem.l	fullscr_st_blackpal,d0-d7	;Set palette
		movem.l	d0-d7,$ffff8240.w		;

		lea	fullscr_st_blackpal,a0		;Fade in palette
		lea	fullscr_st_picture,a1		;
		jsr	component_fade			;

		move.l	screen_adr,d0			;Swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;
		rts

fullscr_st_main:
		rts

fullscr_st_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code
		dcb.w	68,$4e71			;Time for user to set up registers etc

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts


fullscr_st_normal_begin:
		;Code for scanlines 0-226 and 229-272
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	88,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11,$4e71
fullscr_st_normal_end:


fullscr_st_lower_begin:
		;Code for scanline 227-228 (lower border special case)
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	88,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	8,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	85,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	11,$4e71

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		dcb.w	11,$4e71
fullscr_st_lower_end:



fullscr_st_copy_pic:
		;Copy picture to both workscreens
		move.l	screen_adr,a0
		lea	160(a0),a0

		move.l	screen_adr2,a1
		lea	160(a1),a1

		lea	fullscr_st_picture+32,a2

		move.w	#273-1,d7
.y:		move.w	#416/2/4-1,d6
.x:
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+

		dbra	d6,.x
		lea	230-208(a0),a0
		lea	230-208(a1),a1
		dbra	d7,.y
		rts


fullscr_st_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#fullscr_st_normal_begin,d0	;Copy the first 227 scanlines
		move.l	#fullscr_st_normal_end,d1	;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#fullscr_st_lower_begin,d0	;Copy the lower border special case (2 scanlines)
		move.l	#fullscr_st_lower_end,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#fullscr_st_normal_begin,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#fullscr_st_normal_end,d1	;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


		section	data

fullscr_st_blackpal:
		dcb.w	16,$0000			;Black palette

fullscr_st_picture:
		incbin	'fullscr.st/pic.4pl'		;416x273 four bitplanes and 32 byte palette at the start
		even

		section	text

