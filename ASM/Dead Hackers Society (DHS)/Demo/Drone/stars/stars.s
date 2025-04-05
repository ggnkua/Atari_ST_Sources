; One bitplane 3D-sprites in fullscreen
;
; ae/2012-03-25


stars_numspr:	equ	180
stars_numfr:	equ	256
stars_wait:	equ	15

		section	text

stars_init:
		rts

stars_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red
		jsr	clear_buf
		clr.w	stars_fadepos
		bsr	stars_init_screens
		bsr	stars_clear_screens
		bsr	stars_setup_obj_01
		bsr	stars_make_fade
		bsr	stars_load_data
		bsr	stars_preshift
		bsr	stars_code_copy
		bsr	stars_blitter_init_clear
		move.w	#stars_wait,stars_fadewait
		init_finish_green
		rts


stars_vbl:
		move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	stars_emptyadr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		lea	buf+stars_fade,a0
		add.w	stars_fadepos,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

		bsr	stars_mkblitlist
		bsr	stars_blitter_init_clear

		move.l	stars_scradr1,d0		;Swap screens
		move.l	stars_scradr2,stars_scradr1	;
		move.l	d0,stars_scradr2		;

		bsr	stars_play_anim
		bsr	stars_rotate_bitplanes

		rts

stars_vbl_in:
		bsr	stars_vbl

		subq.w	#1,stars_fadewait
		bpl.s	.no
		bsr	stars_fadein
.no:		rts

stars_vbl_out:
		bsr	stars_vbl
		bsr	stars_fadeout
		rts

stars_vbl_down:
		bsr	stars_vbl
		bsr	stars_fadedown
		rts

stars_main1:
		move.l	#buf+stars_anim1,stars_objadr
		rts

stars_main2:
		move.l	#buf+stars_anim2,stars_objadr
		rts

stars_main3:
		move.l	#buf+stars_anim3,stars_objadr
		rts


stars_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	66-11-19,$4e71			;Time for user to set up registers etc

		moveq	#3,d0				;1 Blitter lines
		move.w	#%11000000,d1			;2 Blitter start
		lea	$ffff8a38.w,a0			;2 Blitter lines
		lea	$ffff8a3c.w,a1			;2 Blitter control
		lea	$ffff8a24.w,a2			;2 Blitter src
		lea	$ffff8a32.w,a3			;2 Blitter dst

		lea	$ffff8203.w,a6			;2
		move.l	stars_scradr2,d6		;5
		add.l	#160,d6				;4
		movep.l	d6,0(a6)			;6
		lea	$ffff820a.w,a6			;2 Right border opt

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts


stars_clr_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	91-81,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+75


		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		dcb.w	26,$4e71
stars_clr_end:

stars_clr_begin_mste:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	91-82,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+75


		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		dcb.w	26,$4e71
stars_clr_end_mste:

stars_init_sprite_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-45,$4e71

		clr.b	$ffff8a3d.w			;4 Shift
		move.w	#2,$ffff8a20.w			;4 SX-inc
		move.w	#2,$ffff8a22.w			;4 SY-inc
		move.w	#8,$ffff8a2e.w			;4 DX-inc
		move.w	#224-8,$ffff8a30.w		;4 DY-inc
		move.w	#-1,$ffff8a28.w			;4 EM1
		move.w	#-1,$ffff8a2a.w			;4 EM2
		move.w	#-1,$ffff8a2c.w			;4 EM3
		move.b	#%00000010,$ffff8a3a.w		;4 HTOP
		move.b	#%00000111,$ffff8a3b.w		;4 LOP
		move.w	#2,$ffff8a36.w			;4 X-loop
		moveq	#14,d0				;1 Blitter lines

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		lea	buf+stars_blitlist,a4		;3 List of src,dst addresses

		move.l	(a4)+,(a2)			;5 src
		move.l	(a4)+,(a3)			;5 dst

		dcb.w	26-13,$4e71
stars_init_sprite_end:

stars_sprite_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		nop
		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+(6*14=84)

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		move.l	(a4)+,(a2)			;5 src
		move.l	(a4)+,(a3)			;5 dst

		dcb.w	26-10,$4e71
stars_sprite_end:

stars_sprite_begin_mste:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+(6*14=84)

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		move.l	(a4)+,(a2)			;5 src
		move.l	(a4)+,(a3)			;5 dst

		dcb.w	26-10,$4e71
stars_sprite_end_mste:



stars_lower_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		nop
		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+(6*14=84)

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		dcb.w	23,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		move.l	(a4)+,(a2)			;5 src
		move.l	(a4)+,(a3)			;5 dst

		dcb.w	26-10,$4e71

stars_lower_end:

stars_lower_begin_mste:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+(6*14=84)

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		dcb.w	23,$4e71
		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87,$4e71

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		move.l	(a4)+,(a2)			;5 src
		move.l	(a4)+,(a3)			;5 dst

		dcb.w	26-10,$4e71

stars_lower_end_mste:


stars_black_begin:
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-3,$4e71

		moveq	#0,d6				;1
		lea	$ffff8240.w,a5			;2

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26-24,$4e71

		rept	8
		move.l	d6,(a5)+			;3*8
		endr

stars_black_end:



stars_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		cmp.l	#"MSTe",computer_type
		bne	.ste

		move.l	#stars_clr_begin_mste,d0	;Clear screen
		move.l	#stars_clr_end_mste,d1		;
		move.w	#91,d2				;
		jsr	code_copy			;

		move.l	#stars_init_sprite_begin,d0	;Setup blitter for sprite drawing
		move.l	#stars_init_sprite_end,d1	;
		move.w	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin_mste,d0	;Draw one sprite per scanline
		move.l	#stars_sprite_end_mste,d1	;
		move.w	#135,d2				;
		jsr	code_copy			;

		move.l	#stars_lower_begin_mste,d0	;Copy the lower border special case (2 scanlines)
		move.l	#stars_lower_end_mste,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin_mste,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#stars_sprite_end_mste,d1	;
		move.w	#37,d2				;
		jsr	code_copy			;

		move.l	#stars_black_begin,d0		;Set all colours black (cheap ass y clip at the bottom)
		move.l	#stars_black_end,d1		;
		move.w	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin_mste,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#stars_sprite_end_mste,d1	;
		move.w	#7,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts

.ste:		move.l	#stars_clr_begin,d0		;Clear screen
		move.l	#stars_clr_end,d1		;
		move.w	#91,d2				;
		jsr	code_copy			;

		move.l	#stars_init_sprite_begin,d0	;Setup blitter for sprite drawing
		move.l	#stars_init_sprite_end,d1	;
		move.w	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin,d0		;Draw one sprite per scanline
		move.l	#stars_sprite_end,d1		;
		move.w	#135,d2				;
		jsr	code_copy			;

		move.l	#stars_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#stars_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin,d0		;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#stars_sprite_end,d1		;
		move.w	#37,d2				;
		jsr	code_copy			;

		move.l	#stars_black_begin,d0		;Set all colours black (cheap ass y clip at the bottom)
		move.l	#stars_black_end,d1		;
		move.w	#1,d2				;
		jsr	code_copy			;

		move.l	#stars_sprite_begin,d0		;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#stars_sprite_end,d1		;
		move.w	#7,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


stars_blitter_init_clear:
		clr.b	$ffff8a3d.w			;Shift
		move.w	#2,$ffff8a20.w			;SX-inc
		move.w	#2,$ffff8a22.w			;SY-inc
		move.w	#8,$ffff8a2e.w			;DX-inc
		move.w	#24+8,$ffff8a30.w		;DY-inc
		move.w	#-1,$ffff8a28.w			;EM1
		move.w	#-1,$ffff8a2a.w			;EM2
		move.w	#-1,$ffff8a2c.w			;EM3
		move.b	#%00000010,$ffff8a3a.w		;HTOP
		move.b	#%00000000,$ffff8a3b.w		;LOP
		move.w	#25,$ffff8a36.w			;X-loop

		move.l	stars_scradr2,d0
		add.l	#160,d0
		move.l	d0,$ffff8a32.w			;DST

		lea	stars_bpl,a0
		add.w	stars_bplofs,a0
		move.l	(a0),d0
		add.l	d0,$ffff8a32.w
		rts




stars_load_data:
		move.l	#stars_ob02_fn,filename
		move.l	stars_ob02_fl,filelength
		move.l	#buf+stars_anim1,filebuffer
		jsr	loader

		move.l	#stars_ob03_fn,filename
		move.l	stars_ob03_fl,filelength
		move.l	#buf+stars_anim2,filebuffer
		jsr	loader

		move.l	#stars_ob01_fn,filename
		move.l	stars_ob01_fl,filelength
		move.l	#buf+stars_anim3,filebuffer
		jsr	loader

		rts

stars_preshift:
		;copy unshifted sprite
		lea	stars_sprite,a0
		lea	buf+stars_shifted,a1
		move.w	#14-1,d7
.copy:		move.w	(a0)+,(a1)
		addq.l	#4,a1
		dbra	d7,.copy

		;shift it 15 times
		lea	buf+stars_shifted,a0
		move.w	#15-1,d7
.shift:		move.w	#14-1,d6
.y:
		move.l	(a0)+,d0
		lsr.l	#1,d0
		move.l	d0,(a1)+

		dbra	d6,.y
		dbra	d7,.shift

		rts


stars_mkblitlist:
		;create a ready blitter list from the animation
		lea	buf+stars_blitlist,a0
		move.l	stars_frameadr,a1
		lea	buf+stars_shifted,a3

		move.l	stars_scradr2,d0
		add.l	#160+96+(224*134),d0

		lea	stars_bpl,a4
		add.w	stars_bplofs,a4
		add.l	(a4),d0

		move.w	#stars_numspr-1,d7
.l:
		move.l	a3,a4			;src
		add.w	(a1)+,a4		;shift
		move.l	a4,(a0)+

		move.l	d0,a2			;dst
		add.w	(a1)+,a2
		move.l	a2,(a0)+

		dbra	d7,.l


		rts

stars_rotate_bitplanes:
		cmp.w	#20,stars_bplofs
		blt.s	.add
		move.w	#-4,stars_bplofs
.add:		addq.w	#4,stars_bplofs
		rts



stars_play_anim:
		;lea	buf+stars_anim1,a0
		move.l	stars_objadr,a0
		add.l	stars_anipos,a0
		move.l	a0,stars_frameadr

		cmp.l	#4*stars_numspr*(stars_numfr-1),stars_anipos
		blt.s	.add
		move.l	#-4*stars_numspr,stars_anipos
.add:		add.l	#4*stars_numspr,stars_anipos

		rts

stars_init_screens:
		move.l	screen_adr_base,d0
		add.l	#32000,d0
		move.l	d0,stars_scradr1

		move.l	#buf+stars_scr2+256,d0
		clr.b	d0
		add.l	#32000,d0
		move.l	d0,stars_scradr2

		move.l	#buf+stars_empty+256,d0
		clr.b	d0
		move.l	d0,stars_emptyadr

		move.l	d0,a0
		moveq	#0,d0
		move.w	#160*2/4-1,d7
.l:		move.l	d0,(a0)+
		dbra	d7,.l

		rts


stars_setup_obj_01:
		move.l	#buf+stars_anim1,stars_frameadr
		move.l	#buf+stars_anim1,stars_objadr
		;clr.l	stars_anipos
		rts

stars_setup_obj_02:
		move.l	#buf+stars_anim2,stars_frameadr
		move.l	#buf+stars_anim2,stars_objadr
		;clr.l	stars_anipos
		rts

stars_setup_obj_03:
		move.l	#buf+stars_anim3,stars_frameadr
		move.l	#buf+stars_anim3,stars_objadr
		;clr.l	stars_anipos
		rts

stars_clear_screens:
		move.l	stars_scradr1,a0
		move.l	stars_scradr2,a1
		moveq	#0,d0
		move.w	#224*273/4-1,d7
.l:		move.l	d0,(a0)+
		move.l	d0,(a1)+
		dbra	d7,.l

		rts

stars_make_fade:
		move.l	.dst,a0
		moveq	#0,d0
		move.w	#16*16/2-1,d7
.black:		move.l	d0,(a0)+
		dbra	d7,.black

		add.l	#16*16*2,.dst

		move.w	#48-1,.cnt

.l:		move.l	.dst,a0					;black>pal
		movem.l	stars_black,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.dst

		lea	stars_black,a0
		lea	stars_pal,a1
		jsr	component_fade

		subq.w	#1,.cnt
		bpl.s	.l


		move.w	#48-1,.cnt

.l2:		move.l	.dst,a0					;pal>white
		movem.l	stars_black,d0-d7
		movem.l	d0-d7,(a0)
		add.l	#32,.dst

		lea	stars_black,a0
		lea	stars_white,a1
		jsr	component_fade

		subq.w	#1,.cnt
		bpl.s	.l2


		rts
.dst:		dc.l	buf+stars_fade
.cnt:		dc.w	0


stars_fadein:
		cmp.w	#32*63,stars_fadepos
		blt.s	.add
		rts
.add:		add.w	#32,stars_fadepos
		rts

stars_fadeout:
		tst.w	stars_fadepos
		bgt.s	.sub
		rts
.sub:		sub.w	#32,stars_fadepos
		rts

stars_fadedown:
		cmp.w	#32*63,stars_fadepos
		bgt.s	.sub
		rts
.sub:		sub.w	#32,stars_fadepos
		rts

		section	data


stars_ob01_fn:	dc.b	'data\stars01.bin',0
		even
stars_ob01_fl:	dc.l	2*stars_numspr*stars_numfr*2

stars_ob02_fn:	dc.b	'data\stars02.bin',0
		even
stars_ob02_fl:	dc.l	2*stars_numspr*stars_numfr*2

stars_ob03_fn:	dc.b	'data\stars03.bin',0
		even
stars_ob03_fl:	dc.l	2*stars_numspr*stars_numfr*2


stars_bplofs:	dc.w	0

stars_frameadr:	dc.l	buf+stars_anim1
stars_objadr:	dc.l	buf+stars_anim1
stars_anipos:	dc.l	0

stars_fadepos:	dc.w	0
stars_fadewait:	dc.w	0

stars_source:		dc.l	buf
stars_destination:	dc.l	buf

stars_sprite:	incbin	'stars/star.1pl'
		even

stars_black:	dcb.w	16,$0000
stars_white:	dcb.w	15,$0fff

;08192a3b4c5d6e7f
stars_pal:
.bg:		set	$0000
.c1:		set	$0922
.c2:		set	$0c55
.c3:		set	$07ff
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dcb.w	8,$0000

stars_bpl:	dc.l	0,0,2,2,4,4

		section	bss

stars_scradr1:	ds.l	1
stars_scradr2:	ds.l	1
stars_emptyadr:	ds.l	1

		rsreset
stars_empty:	rs.b	160*2+256			;1
stars_shifted:	rs.l	14*16				;1
stars_blitlist:	rs.l	2*stars_numspr			;2 src,dst "blitter display list"
stars_anim1:	rs.w	2*stars_numspr*stars_numfr	;185
stars_anim2:	rs.w	2*stars_numspr*stars_numfr	;185
stars_anim3:	rs.w	2*stars_numspr*stars_numfr	;185
stars_scr2:	rs.b	1024*128+256			;129
		rs.b	1024*64				;64
stars_fade:	rs.w	16*16				;1
		rs.w	16*48*2				;3
							;=756

		section	text

