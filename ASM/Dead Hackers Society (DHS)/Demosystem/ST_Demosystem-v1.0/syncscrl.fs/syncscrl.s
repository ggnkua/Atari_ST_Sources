; Syncscroller template
; Fullscreen version
; Works on both ST and STe
;
; No double buffer, using both screens for scrolling instead
; 416x265 visible area where about 8 pixels at the right will be
; trashed due to overscan stabilizer, effective width about 408 pixels
;
; September 3, 2011

		section	text

syncscrl_fs_init:
		rts

syncscrl_fs_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	syncscrl_fs_copy_pic
		bsr	syncscrl_fs_code_copy
		clr.l	sscrl_offset
		rts


syncscrl_fs_vbl:
		move.l  screen_adr_base,d0		;Set screenaddress
		add.l	sscrl_offset,d0			;Scroll offset
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		jsr	black_pal			;Set colours black to hide the syncscrolling lines

		lea	syncscrl_fs_blackpal,a0		;Fade in palette
		lea	syncscrl_fs_picture,a1		;
		jsr	component_fade			;

		rts

syncscrl_fs_main:
		rts

syncscrl_fs_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border
		do_syncscroll				;Macro to run syncscrolling scanlines

		;inits
		moveq	#2,d7				;D7 used for the overscan code
		dcb.w	128-40,$4e71			;Time for user to set up registers etc

		movem.l	syncscrl_fs_blackpal,d0-d6/a0	;21 Load colours
		movem.l	d0-d6/a0,$ffff8240.w		;19 Set palette just before overscan begins

		jsr	codebuf				;Run generated code

		jsr	sscrl_setup_list		;Setup list of overscan routines for next VBL's offset
		bsr	syncscrl_fs_do_scroll		;Make new screen offset
		move.w	#$2300,sr
		rts


syncscrl_fs_normal_begin:
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
syncscrl_fs_normal_end:


syncscrl_fs_lower_begin:
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
syncscrl_fs_lower_end:


syncscrl_fs_last_begin:
		;Code for scanlines 0-226 and 229-272
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	88,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	8,$4e71
		lea	$ffff8240.w,a0			;2
		moveq	#0,d0				;1

		move.b	d7,$ffff8260.w			;3 Stabilizer
		move.w	d7,$ffff8260.w			;3

		rept	8
		move.l	d0,(a0)+			;3*8
		endr

syncscrl_fs_last_end:


syncscrl_fs_do_scroll:
		cmp.l	#230*264,sscrl_offset		;Do the scrolling and wrap
		blt.s	.add				;
		move.l	#-230,sscrl_offset		;
.add:		add.l	#230,sscrl_offset		;
		rts

syncscrl_fs_copy_pic:
		;Copy picture two times to allow seamless forever-scroll
		move.l	screen_adr_base,a0
		lea	160*9(a0),a0

		move.l	a0,a1
		add.l	#230*265,a1

		lea	syncscrl_fs_picture+32,a2

		move.w	#265-1,d7
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


syncscrl_fs_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#syncscrl_fs_normal_begin,d0	;Copy the first 219 scanlines
		move.l	#syncscrl_fs_normal_end,d1	;
		move.w	#219,d2				;
		jsr	code_copy			;

		move.l	#syncscrl_fs_lower_begin,d0	;Copy the lower border special case (2 scanlines)
		move.l	#syncscrl_fs_lower_end,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#syncscrl_fs_normal_begin,d0	;Copy 43 scanlines
		move.l	#syncscrl_fs_normal_end,d1	;
		move.w	#43,d2				;
		jsr	code_copy			;

		move.l	#syncscrl_fs_last_begin,d0	;Copy the final scanline, setting palette black at the end
		move.l	#syncscrl_fs_last_end,d1	;Total 265 overscanned lines
		move.w	#1,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


		section	data

syncscrl_fs_blackpal:
		dcb.w	16,$0000			;Black palette

syncscrl_fs_picture:
		incbin	'syncscrl.fs/pic.4pl'		;416x265 four bitplanes and 32 byte palette at the start
		even

		section	text

