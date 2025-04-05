; Zooming checkerboard in fullscreen
; 2012-05-05

checker_zoom_speed:	equ	28
checker_scroll_speed:	equ	44

		section	text

checker_init:
		rts

checker_runtime_init:
		run_once
		init_finish_red
		
		jsr	clear_buf
		bsr	checker_load_data
		bsr	checker_code_copy

		init_finish_green

		rts

checker_runtime_exit:
		run_once
		clr.b	$ffff8265.w
		rts



checker_vbl:
		bsr	checker_draw_txt
		rts

checker_vbl2:
		bsr	checker_erase_txt
		rts


checker_main:
		bsr	checker_xzoom
		bsr	checker_yzoom
		bsr	checker_xscroll
		bsr	checker_yscroll

		rts


checker_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	60-37,$4e71			;Time for user to set up registers etc

		lea	$ffff8203.w,a1			;2
		move.l	checker_dl,d0			;5
		move.l	checker_dl2,d1			;5
		move.w	#450,d2				;2 30*15
		sub.w	checker_ystart,d2		;5
		lea	buf+checker_txt+119*30,a0	;3
		add.w	checker_ypos,a0			;5
		lea	$ffff8242.w,a2			;2
		lea	buf+checker_ylist,a5		;3
		move.b	checker_hscroll,$ffff8265.w	;4

		jsr	codebuf				;5
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		clr.b	$ffff8265.w
		rts


checker_normal_begin:
		movep.l	d0,0(a1)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-12-23,$4e71

		sub.w	-2(a5),d2			;3

		bgt.s	.no_swap			;3 taken 2 not taken
		exg	d0,d1				;2
		move.w	#450,d2				;2
		bra.s	.done_swap			;3
.no_swap:	dcb.w	6,$4e71

.done_swap:
		move.l	a2,a3				;1
		move.l	a0,a4				;1
		add.w	(a5)+,a0			;3 yzoom

		move.w	(a4)+,(a3)+			;3
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5

		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3

		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
checker_normal_end:

checker_lower_begin:
		movep.l	d0,0(a1)			;6
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-12-28,$4e71


		sub.w	-2(a5),d2			;3

		bgt.s	.no_swap			;3 taken 2 not taken
		exg	d0,d1				;2
		move.w	#450,d2				;2
		bra.s	.done_swap			;3
.no_swap:	dcb.w	6,$4e71

.done_swap:
		move.l	a2,a3				;1
		move.l	a0,a4				;1
		add.w	(a5)+,a0			;3 yzoom

		move.w	(a4)+,(a3)+			;3
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5


		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3

		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5

		dcb.w	17-15,$4e71
		;---

		movep.l	d0,0(a1)			;6
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-0-12-23,$4e71

		sub.w	-2(a5),d2			;3

		bgt.s	.no_swap2			;3 taken 2 not taken
		exg	d0,d1				;2
		move.w	#450,d2				;2
		bra.s	.done_swap2			;3
.no_swap2:	dcb.w	6,$4e71

.done_swap2:
		move.l	a2,a3				;1
		move.l	a0,a4				;1
		add.w	(a5)+,a0			;3 yzoom

		move.w	(a4)+,(a3)+			;3
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5

		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3

		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
		move.l	(a4)+,(a3)+			;5
checker_lower_end:


checker_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#checker_normal_begin,d0	;Copy the first 227 scanlines
		move.l	#checker_normal_end,d1		;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#checker_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#checker_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#checker_normal_begin,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#checker_normal_end,d1		;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts

checker_load_data:
		move.l	#checker_bg_fn,filename
		move.l	checker_bg_fl,filelength
		move.l	#buf+checker_bg,filebuffer
		jsr	loader

		move.l	#checker_txt_fn,filename
		move.l	checker_txt_fl,filelength
		move.l	#buf+checker_txt+32*512,filebuffer
		jsr	loader

		rts

checker_xzoom:

		add.l	#checker_zoom_speed,.sin
		and.l	#$1fff,.sin

		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#488,d1	;511
		asr.l	#8,d1
		asr.l	#7,d1
		move.l	d1,d2

		asl.l	#8,d1
		lea	buf+checker_bg+(512/2*256)+24,a0
		add.l	d1,a0
		move.l	a0,checker_dl
		add.l	#512/2*512,a0
		move.l	a0,checker_dl2

		;for yzoom
		add.l	#256,d2				;Unsign
		move.l	d2,checker_yzoom_val

		rts
.sin:		dc.l	0

checker_yzoom:
		lea	buf+checker_ylist,a0
		move.w	#512,d0
		move.l	checker_yzoom_val,d1

		moveq	#0,d2				;Zoom
		moveq	#30,d3				;No zoom

		move.w	#273-1,d7
.l:
		sub.w	d1,d0
		bmi.s	.next

		move.w	d2,(a0)+

		dbra	d7,.l
		rts
.next:
		move.w	d3,(a0)+
		add.w	#512,d0

		dbra	d7,.l
		rts


checker_xscroll:
		add.l	#checker_scroll_speed,.sin
		and.l	#$1fff,.sin

		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#44,d1
		asr.l	#8,d1
		asr.l	#7,d1

		add.w	#40,d1	;unsign
		move.l	d1,d0
		and.w	#$000f,d0			;Save finescroll
		move.b	d0,checker_hscroll
		and.w	#$fff0,d1			;Skip finescroll
		asr.w	#1,d1

		add.w	d1,checker_dl+2
		add.w	d1,checker_dl2+2


		rts
.sin:		dc.l	0

checker_yscroll:

		add.l	#checker_zoom_speed,.sin
		and.l	#$1fff,.sin

		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#220,d1
		asr.l	#8,d1
		asr.l	#7,d1

		move.l	d1,d0
		muls	#30,d1
		add.w	#30*10,d1
		move.w	d1,checker_ypos


		lea	checker_yscroll_tab+128*2,a0
		add.w	d0,d0
		move.w	(a0,d0.w),d0

		cmp.w	#16,d0
		blt.s	.no_swap

		move.l	checker_dl,d3
		move.l	checker_dl2,checker_dl
		move.l	d3,checker_dl2

		sub.w	#15,d0
.no_swap:
		mulu	#30,d0
		move.w	d0,checker_ystart

		rts
.sin:		dc.l	1000


checker_draw_txt:
		lea	buf+checker_txt,a0
		lea	buf+checker_txt2,a1
		add.w	.pos,a0
		add.w	.pos,a1

.q:		set	0
		rept	4
		movem.l	.q(a1),d0-d7
		movem.l	d0-d7,.q(a0)
.q:		set	.q+32
		endr

		tst.w	.pos
		ble.s	.done
		sub.w	#32*4,.pos
.done:		rts
.pos:		dc.w	32*511

checker_erase_txt:
		lea	buf+checker_txt,a0
		add.w	.pos,a0
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7

.q:		set	0
		rept	4
		movem.l	d0-d7,.q(a0)
.q:		set	.q+32
		endr

		tst.w	.pos
		ble.s	.done
		sub.w	#32*4,.pos
.done:		rts
.pos:		dc.w	32*511

		rts

		section	data


checker_yscroll_tab:

		rept	10

.q:		set	1
		rept	30
		dc.w	.q
.q:		set	.q+1
		endr

		endr

checker_hscroll:dc.w	0
checker_ystart:	dc.w	0
checker_ypos:	dc.w	0


checker_yzoom_val:
		dc.l	512

checker_pal:	dc.w	$0700,$0110,$0220,$0330,$0440,$0550,$0660,$0770
		dc.w	$0ff0,$0ff1,$0ff2,$0ff3,$0ff4,$0ff5,$0ff6,$0ff7

checker_bg_fn:	dc.b	'data\chkbg.4pl',0
		even
checker_bg_fl:	dc.l	512*512*2/2

checker_txt_fn:	dc.b	'data\chktxt.12b',0
		even
checker_txt_fl:	dc.l	16*512*2

checker_dl:	dc.l	buf+checker_bg+256*254
checker_dl2:	dc.l	buf+checker_bg+256*254+256*512

		section	text

