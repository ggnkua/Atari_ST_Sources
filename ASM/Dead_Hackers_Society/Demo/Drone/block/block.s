; Blocky movieplayer in fullscreen
;
; 2012-04-01


		section	text

block_init:
		rts

block_runtime_init_1a:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red
		bsr	block_load_data
		bsr	block_gengfx
		init_finish_green
		rts

block_runtime_init_1b:
		run_once
		init_finish_red
		jsr	black_pal
		jsr	clear_screens
		bsr	block_code_copy
		init_finish_green
		rts


block_runtime_init_2a:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red
		jsr	clear_buf
		bsr	block_load_data2
		bsr	block_gengfx
		init_finish_green
		rts

block_runtime_init_2b:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red
		jsr	black_pal
		jsr	clear_screens
		lea	block_black,a0
		rept	8
		clr.l	(a0)+
		endr
		bsr	block_code_copy
		init_finish_green
		rts


block_runtime_exit:
		run_once

		clr.b	$ffff8265.w
		clr.b	$ffff820f.w

		rts

block_runtime_exit_2:
		run_once

		clr.b	$ffff8265.w
		clr.b	$ffff820f.w

		rts

block_vbl:
		clr.b	$ffff8265.w

		move.l  screen_adr2,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;


		move.l	screen_adr,d0			;Swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;
		rts

block_vbl_fadein:
		bsr	block_vbl

		movem.l	block_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea	block_black,a0
		lea	block_pal,a1
		jsr	component_fade
		rts

block_vbl_fadeout:
		bsr	block_vbl

		movem.l	block_pal_bright,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea	block_pal_bright,a0
		lea	block_black2,a1
		jsr	component_fade
		rts


block_vbl_fadeout2:
		bsr	block_vbl

		movem.l	block_pal_bright2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea	block_pal_bright2,a0
		lea	block_black2,a1
		jsr	component_fade
		rts

block_main:
		bsr	block_animate
		bsr	block_rotate_bitplanes
		rts


block_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	66-8-13,$4e71			;Time for user to set up registers etc

		move.b	#8,$ffff8265.w			;4
		move.b	#0,$ffff820f.w			;4

		move.l	block_srcadr,a0			;5
		lea	buf+block_gfx,a1		;3
		move.l	block_dstadr,a2			;5

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts

block_normal_begin:
.lw:		set	232

	rept	7
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2

		dcb.w	26-22,$4e71
	endr

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8+.lw*7+32+8(a2),a2		;2

		dcb.w	26-22,$4e71

block_normal_end:


block_lower_begin:
.lw:		set	232
	rept	3
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2

		dcb.w	26-22,$4e71

	endr

		;------------
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2

		dcb.w	23-22,$4e71

		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-85,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4 =11


		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 26

	rept	2
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2

		dcb.w	26-22,$4e71
	endr

		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-89,$4e71

		rept	2
		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4
		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8(a2),a2			;2 = 37*2 = 74
		endr

		move.l	a1,a3				;1
		add.w	(a0)+,a3			;3
		move.w	(a3)+,(a2)			;3
		move.w	(a3)+,.lw(a2)			;4
		move.w	(a3)+,.lw*2(a2)			;4 =15


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		move.w	(a3)+,.lw*3(a2)			;4
		move.w	(a3)+,.lw*4(a2)			;4
		move.w	(a3)+,.lw*5(a2)			;4
		move.w	(a3)+,.lw*6(a2)			;4
		move.w	(a3)+,.lw*7(a2)			;4
		lea	8+.lw*7+32+8(a2),a2		;2

		dcb.w	26-22,$4e71

block_lower_end:



block_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		move.l	#block_normal_begin,d0		;Copy the first 227 scanlines
		move.l	#block_normal_end,d1		;
		move.w	#28,d2				;*8 times = 224 scans
		jsr	code_copy			;

		move.l	#block_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#block_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#block_normal_begin,d0		;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#block_normal_end,d1		;
		move.w	#5,d2				;*8 times = 40 scanlines
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


block_load_data:
		move.l	#block_anim_fn,filename
		move.l	block_anim_fl,filelength
		move.l	#buf+block_anim,filebuffer
		jsr	loader
		rts

block_load_data2:
		move.l	#block_anim_fn2,filename
		move.l	block_anim_fl2,filelength
		move.l	#buf+block_anim,filebuffer
		jsr	loader
		rts


block_gengfx:
; build blocks as combinations (two nibbles=one word block)
		lea	buf+block_gfx,a0
		lea	block_blocks,a1

		moveq	#0,d0
		moveq	#0,d1

		move.w	#16-1,d7
.l1:		move.w	#16-1,d6
.l2:

.q:		set	0

	rept	8
		move.b	.q(a1,d0.w),(a0)+
		move.b	.q(a1,d1.w),(a0)+
.q:		set	.q+1
	endr
		addq.w	#8,d1

		dbra	d6,.l2
		addq.w	#8,d0
		moveq	#0,d1
		dbra	d7,.l1
		rts


block_animate:
		lea	buf+block_anim,a0
		add.l	block_frame,a0
		move.l	a0,block_srcadr

		cmp.l	#48*34*(block_numfr-1),block_frame
		blt.s	.add
		move.l	#-48*34,block_frame
.add:		add.l	#48*34,block_frame

		rts

block_rotate_bitplanes:
		move.l	screen_adr,a0
		lea	160+8(a0),a0
		lea	block_bpl,a1
		move.w	.pos,d0
		add.w	(a1,d0.w),a0
		move.l	a0,block_dstadr

		cmp.w	#14,.pos
		blt.s	.add
		move.w	#-2,.pos
.add:		addq.w	#2,.pos

		rts
.pos:		dc.w	0



		section	data

block_bpl:	dc.w	0,0,2,2,4,4,6,6
block_srcadr:	dc.l	buf+block_anim
block_dstadr:	dc.l	0
block_frame:	dc.l	0


block_anim_fn:	dc.b	'data\block.4bc',0
		even
block_anim_fl:	dc.l	48*34*block_numfr

block_anim_fn2:	dc.b	'data\block2.4bc',0
		even
block_anim_fl2:	dc.l	48*34*block_numfr

block_blocks:	incbin	'block/blocks.1pl'
		even

block_black:	dcb.w	16,$0000
block_black2:	dcb.w	16,$0000
block_pal:
.bg:		set	$0000
.c1:		set	$0221
.c2:		set	$0344
.c3:		set	$0565
.c4:		set	$0fff
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dc.w	.c1,.c2,.c2,.c3,.c2,.c3,.c3,.c4

block_pal_bright:
.bg:		set	$0000
.c1:		set	$0554
.c2:		set	$0677
.c3:		set	$0777
.c4:		set	$0fff
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dc.w	.c1,.c2,.c2,.c3,.c2,.c3,.c3,.c4

block_pal_bright2:
.bg:		set	$0000
.c1:		set	$0554
.c2:		set	$0677
.c3:		set	$0777
.c4:		set	$0fff
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dc.w	.c1,.c2,.c2,.c3,.c2,.c3,.c3,.c4


		section	text
