; Syncscroller template
; Non-fullscreen version
; Works on both ST and STe
;
; No double buffer, using both screens for scrolling instead
; 320x265 visible area, to have 320x200, keep colours black
; and set a new palette with Timer B at the correct scanline
; and skip the lower border removal.
;
; September 8, 2011

		section	text

syncscrl_init:
		rts

syncscrl_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	syncscrl_copy_pic
		clr.l	sscrl_offset
		rts


syncscrl_vbl:
		move.l  screen_adr_base,d0		;Set screenaddress
		add.l	sscrl_offset,d0			;Scroll offset
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		jsr	black_pal			;Set colours black to hide the syncscrolling lines

		lea	syncscrl_blackpal,a0		;Fade in palette
		lea	syncscrl_picture,a1		;
		jsr	component_fade			;

		rts

syncscrl_main:
		rts

syncscrl_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border
		do_syncscroll				;Macro to run syncscrolling scanlines

		dcb.w	98,$4e71			;Wait for border before setting palette
		movem.l	syncscrl_blackpal,d0-d6/a0	;Load colours
		movem.l	d0-d6/a0,$ffff8240.w		;Set palette

		move.b	#172,$fffffa1f.w		;Timer A Delay (Data) 170
		move.b	#7,$fffffa19.w			;Timer A Div (Start)

		move.l	$134.w,syncscrl_save_ta		;Save demosys Timer A
		move.l	#syncscrl_ta_low_border,$134.w	;Install temporary Timer A for the lower border

		jsr	sscrl_setup_list		;Setup list of overscan routines for next VBL's offset
		bsr	syncscrl_do_scroll		;Make new screen offset
		rts


syncscrl_ta_low_border:
		clr.b	$fffffa19.w			;Stop Timer A
		dcb.w	48,$4e71			;Zzzz..

		clr.b	$ffff820a.w			;60 Hz
		dcb.w	6,$4e71				;Znark
		move.b	#2,$ffff820a.w			;50 Hz

		move.l	syncscrl_save_ta,$134.w		;Back to demosys Timer A
		move.w	#$2300,sr			;Enable interrupts again
		rte


syncscrl_do_scroll:
		cmp.l	#160*264,sscrl_offset		;Do the scrolling and wrap
		blt.s	.add				;
		move.l	#-160,sscrl_offset		;
.add:		add.l	#160,sscrl_offset		;
		rts


syncscrl_copy_pic:
		;Copy picture two times to allow seamless forever-scroll
		move.l	screen_adr_base,a0
		lea	160*9(a0),a0

		move.l	a0,a1
		add.l	#160*265,a1

		lea	syncscrl_picture+32,a2

		move.w	#265-1,d7
.y:		move.w	#320/2/4-1,d6
.x:
		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+

		dbra	d6,.x
		dbra	d7,.y
		rts



		section	data

syncscrl_save_ta:
		dc.l	0

syncscrl_blackpal:
		dcb.w	16,$0000			;Black palette

syncscrl_picture:
		incbin	'syncscrl/pic.4pl'		;320x265 four bitplanes and 32 byte palette at the start
		even

		section	text

