; Big logo scrolling by
; and later showing a 31-colour version


		section	text

logo_init:
		rts

logo_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens
		bsr	logo_init_displaylists
		bsr	logo_load_data
		bsr	logo_doublecopy
		bsr	logo_code_copy
		bsr	logo_small_copy_gfx

		init_finish_green
		rts


logo_small_runtime_init:
		run_once				;Macro to ensure the runtime init only run once

		jsr	white_pal
		bsr	logo_small_code_copy

		rts


logo_small_vbl:
		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		movem.l	logo_whitepal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		clr.l	logo_hpos
		clr.w	logo_hscr

		rts

logo_small_in:
		bsr	logo_small_vbl

		subq.w	#1,.wait
		bpl.s	.no

		lea	logo_whitepal,a0
		lea	buf+logo_small,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	4

logo_small_out:
		bsr	logo_small_vbl

		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait

		lea	logo_whitepal,a0
		lea	logo_black2,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	3

logo_small_main:
		rts


logo_vbl:
		;move.l  screen_adr,d0			;Set screenaddress
		;lsr.w	#8,d0				;
		;move.l	d0,$ffff8200.w			;

		move.l	screen_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		movem.l	logo_black,d0-d7
		movem.l	d0-d7,$ffff8240.w


		rts


logo_fadein:
		bsr	logo_vbl
		move.l	#buf+logo_bg,logo_src
		bsr	logo_blitter_init

		subq.w	#1,.wait
		bne.s	.no
		move.w	#4,.wait

		lea	logo_black,a0
		lea	buf+logo_big,a1
		jsr	component_fade

.no:		rts
.wait:		dc.w	1


logo_main:	bsr	logo_scroll
		move.l	#buf+logo_bg,logo_src
		bsr	logo_blitter_init
		rts


logo_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	60-46,$4e71			;Time for user to set up registers etc

		move.l	logo_src,$ffff8a24.w		;8 Blitter src
		moveq	#1,d0				;1 Blitter lines
		move.w	#%11000000,d1			;2 Blitter start
		lea	$ffff8a38.w,a0			;2 Blitter lines
		lea	$ffff8a3c.w,a1			;2 Blitter control
		move.l	logo_dl1adr,a2			;5 Display list
		lea	$ffff8203.w,a3			;2
		move.l	(a2)+,d2			;3 Get display address base
		add.l	logo_hpos,d2			;8 Screenpointer scroll
		move.l	d2,d3				;1
		move.b	logo_hscr,$ffff8265.w		;6 Hscroll
		add.l	#1776/2+6,d3			;4 Blit on next line + fourth bitplane
		move.l	d3,$ffff8a32.w			;4 Blitter dst

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		clr.b	$ffff8265.w
		rts

logo_normal_begin:
		movep.l	d2,0(a3)			;6

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-60,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+54

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	20-9,$4e71
		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll

logo_normal_end:


logo_lower_begin:
		movep.l	d2,0(a3)			;6

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-60,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+50

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	17-9,$4e71

		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll
		movep.l	d2,0(a3)			;6

		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-60,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+50

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	20-9,$4e71
		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll

logo_lower_end:


logo_normal_begin_mste:
		movep.l	d2,0(a3)			;6

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-61,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+54

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	20-9,$4e71
		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll

logo_normal_end_mste:


logo_lower_begin_mste:
		movep.l	d2,0(a3)			;6

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-61,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+50

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	17-9,$4e71

		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll
		movep.l	d2,0(a3)			;6

		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-61,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+50

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	20-9,$4e71
		move.l	(a2)+,d2			;3
		add.l	logo_hpos,d2			;5 Screenpointer scroll

logo_lower_end_mste:



logo_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		cmp.l	#"MSTe",computer_type
		bne.s	.ste

		move.l	#logo_normal_begin_mste,d0	;Copy the first 227 scanlines
		move.l	#logo_normal_end_mste,d1	;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#logo_lower_begin_mste,d0	;Copy the lower border special case (2 scanlines)
		move.l	#logo_lower_end_mste,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#logo_normal_begin_mste,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#logo_normal_end_mste,d1	;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


.ste:		move.l	#logo_normal_begin,d0		;Copy the first 227 scanlines
		move.l	#logo_normal_end,d1		;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#logo_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#logo_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#logo_normal_begin,d0		;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#logo_normal_end,d1		;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


logo_blitter_init:
		;clr.b	$ffff8a3d.w			;Shift
		move.b	logo_hscr,$ffff8a3d.w
		move.w	#2,$ffff8a20.w			;SX-inc
		move.w	#2,$ffff8a22.w			;SY-inc
		move.w	#8,$ffff8a2e.w			;DX-inc
		move.w	#(1776/2)-216+8,$ffff8a30.w	;DY-inc
		move.w	#-1,$ffff8a28.w			;EM1
		move.w	#-1,$ffff8a2a.w			;EM2
		move.w	#-1,$ffff8a2c.w			;EM3
		move.b	#%00000010,$ffff8a3a.w		;HTOP
		move.b	#%00000011,$ffff8a3b.w		;LOP
		move.w	#27,$ffff8a36.w			;X-loop
		rts


logo_load_data:
		move.l	#logo_big_fn,filename
		move.l	logo_big_fl,filelength
		move.l	#buf+logo_big,filebuffer
		jsr	loader

		move.l	#logo_bg_fn,filename
		move.l	logo_bg_fl,filelength
		move.l	#buf+logo_bg,filebuffer
		jsr	loader

		move.l	#logo_small_fn,filename
		move.l	logo_small_fl,filelength
		move.l	#buf+logo_small,filebuffer
		jsr	loader

		rts

logo_doublecopy:
		lea	buf+logo_big,a0
		lea	buf+logo_big2,a1

		move.w	#1776*273/2/4-1,d7
.l:		move.l	(a0)+,(a1)+
		dbra	d7,.l

		rts

logo_init_displaylists:
		move.l	logo_dl1adr,a0
		move.l	logo_dl2adr,a1
		lea	buf+logo_big+32,a2
		lea	buf+logo_big2+32,a3

		move.w	#273-1,d7
.l:
		move.l	a2,(a0)+
		move.l	a3,(a1)+

		lea	1776/2(a2),a2
		lea	1776/2(a3),a3

		dbra	d7,.l

		rts


logo_scroll:
		cmp.w	#944+416,.pos
		bge.s	.done
		addq.w	#2,.pos

		move.w	.pos,d0
		moveq	#0,d1
		move.w	d0,d1

		and.w	#$000f,d0
		move.b	d0,logo_hscr

		and.w	#$fff0,d1
		lsr.w	#1,d1
		move.l	d1,logo_hpos

.done:		rts
.pos:		dc.w	0


logo_small_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	66,$4e71			;Time for user to set up registers etc

		jsr	codebuf				;Run generated code
		;jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts

logo_small_normal_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90,$4e71

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26,$4e71
logo_small_normal_end:


logo_small_lower_begin:
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
logo_small_lower_end:


logo_small_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#logo_small_normal_begin,d0	;Copy the first 227 scanlines
		move.l	#logo_small_normal_end,d1	;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#logo_small_lower_begin,d0	;Copy the lower border special case (2 scanlines)
		move.l	#logo_small_lower_end,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#logo_small_normal_begin,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#logo_small_normal_end,d1	;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


logo_small_copy_gfx:
		lea	buf+logo_small+32,a0
		move.l	screen_adr,a1
		move.l	screen_adr2,a2
		lea	160(a1),a1
		lea	160(a2),a2
		move.w	#273-1,d7
.y:		move.w	#400/2/4-1,d6
.x:
		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+

		dbra	d6,.x
		lea	224-200(a1),a1
		lea	224-200(a2),a2
		dbra	d7,.y

		rts

		section	data

logo_hpos:	dc.l	0
logo_hscr:	dc.w	0
logo_src:	dc.l	0
logo_dst:	dc.l	0

logo_whitepal:	dcb.w	16,$0fff
logo_black:	dcb.w	16,$0000
logo_black2:	dcb.w	16,$0000

logo_big_fn:	dc.b	'data\big.4pl'
		even
logo_big_fl:	dc.l	1776*273/2+32

logo_bg_fn:	dc.b	'data\logobg.1pl'
		even
logo_bg_fl:	dc.l	432*273/8

logo_small_fn:	dc.b	'data\logo.4pl'
		even
logo_small_fl:	dc.l	400*273/2+32


logo_dl1adr:	dc.l	buf+logo_dl1
logo_dl2adr:	dc.l	buf+logo_dl2

		rsreset
logo_bg:	rs.b	432*273/8
logo_big:	rs.b	1776*273/2+32
logo_big2:	rs.b	1776*273/2+32
logo_dl1:	rs.l	273
logo_dl2:	rs.l	273
logo_small:	rs.b	400*273/2+32

		section	text
