; Swirl effect in fullscreen with greetings on top
;
; 2012-03-14

		section	text

swirl_init:
		rts

swirl_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens
		bsr	swirl_load_data
		bsr	swirl_make_fade
		bsr	swirl_greets_makefade
		bsr	swirl_code_copy

		init_finish_green
		rts


swirl_vbl:
		move.l  empty_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		move.l	empty_adr,d0
		lea	$ffff8203.w,a0
		movep.l	d0,0(a0)

		lea	buf+swirl_grfade,a0		;Set palette for greets
		add.w	swirl_grfade_pos,a0
		movem.l	(a0),d0-d3
		movem.l	d0-d3,$ffff8250.w


		move.l	screen_adr,d0			;Swap screens
		move.l	screen_adr2,screen_adr		;
		move.l	d0,screen_adr2			;
		rts

swirl_main_in:	bsr	swirl_fadein
		bsr	swirl_movement
		bsr	swirl_cycle_greets
		bsr	swirl_blitter_greets
		bsr	swirl_blitter_init_overscan

		rts

swirl_main_out:	bsr	swirl_fadeout
		bsr	swirl_movement
		bsr	swirl_cycle_greets
		bsr	swirl_blitter_greets
		bsr	swirl_blitter_init_overscan

		rts

swirl_ta:
		do_hardsync_top_border			;Macro to syncronize into exact cycle and remove top border

		;inits
		moveq	#2,d7				;D7 used for the overscan code

		dcb.w	66-23-10-13,$4e71		;Time for user to set up registers etc

		move.l	swirl_source,$ffff8a24.w	;8 Blitter src
		move.l	swirl_destination,$ffff8a32.w	;8 Blitter dst
		moveq	#1,d0				;1 Blitter lines
		move.w	#%11000000,d1			;2 Blitter start
		lea	$ffff8a38.w,a0			;2 Blitter lines
		lea	$ffff8a3c.w,a1			;2 Blitter control

		lea	$ffff8240.w,a2			;2
		lea	buf+swirl_pals,a3		;3
		add.w	swirl_fadepos,a3		;5

		move.l	screen_adr,d2			;5
		lea	$ffff8203.w,a4			;2
		movep.l	d2,0(a4)			;6

		jsr	codebuf				;Run generated code
		jsr	black_pal			;Set colours black in case some emulator show >274 lines
		rts

swirl_normal_begin:
		;Code for scanlines 0-226 and 229-272
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-56,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+50


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2
swirl_normal_end:


swirl_lower_begin:
		;Code for scanline 227-228 (lower border special case)
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-56,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+50

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	23-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2

		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-56,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+50

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2

swirl_lower_end:

swirl_normal_begin_mste:
		;Code for scanlines 0-226 and 229-272
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-57,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+50


		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2
swirl_normal_end_mste:


swirl_lower_begin_mste:
		;Code for scanline 227-228 (lower border special case)
		move.b	d7,$ffff8260.w			;3 Left border
		move.w	d7,$ffff8260.w			;3

		dcb.w	90-57,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+50

		move.w	d7,$ffff820a.w			;3 Right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	23-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2

		move.w	d7,$ffff820a.w			;3 left border

		;-----------------------------------

		move.b	d7,$ffff8260.w			;3 lower border
		move.w	d7,$ffff8260.w			;3
		move.b	d7,$ffff820a.w			;3

		dcb.w	87-57,$4e71

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+50

		move.w	d7,$ffff820a.w			;3 right border
		move.b	d7,$ffff820a.w			;3

		dcb.w	26-22,$4e71

		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		move.l	(a3)+,(a2)+			;5
		lea	-16(a2),a2			;2

swirl_lower_end_mste:


swirl_code_copy:
		;Copy code to the code buffer
		jsr	code_copy_reset			;Reset code copier variables

		cmp.l	#"MSTe",computer_type
		bne.s	.ste

		move.l	#swirl_normal_begin_mste,d0	;Copy the first 227 scanlines
		move.l	#swirl_normal_end_mste,d1	;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#swirl_lower_begin_mste,d0	;Copy the lower border special case (2 scanlines)
		move.l	#swirl_lower_end_mste,d1	;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#swirl_normal_begin_mste,d0	;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#swirl_normal_end_mste,d1	;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts

.ste:		move.l	#swirl_normal_begin,d0		;Copy the first 227 scanlines
		move.l	#swirl_normal_end,d1		;
		move.w	#227,d2				;
		jsr	code_copy			;

		move.l	#swirl_lower_begin,d0		;Copy the lower border special case (2 scanlines)
		move.l	#swirl_lower_end,d1		;
		moveq	#1,d2				;
		jsr	code_copy			;

		move.l	#swirl_normal_begin,d0		;Copy the last 44 scanlines = total 273 overscanned lines
		move.l	#swirl_normal_end,d1		;
		move.w	#44,d2				;
		jsr	code_copy			;

		jsr	code_copy_rts			;Make sure the code buffer does rts :)
		rts


swirl_blitter_init_overscan:
		clr.b	$ffff8a3d.w			;Shift
		move.w	#2,$ffff8a20.w			;SX-inc
		move.w	#2,$ffff8a22.w			;SY-inc
		move.w	#8,$ffff8a2e.w			;DX-inc
		move.w	#24+8,$ffff8a30.w		;DY-inc
		move.w	#-1,$ffff8a28.w			;EM1
		move.w	#-1,$ffff8a2a.w			;EM2
		move.w	#-1,$ffff8a2c.w			;EM3
		move.b	#%00000010,$ffff8a3a.w		;HTOP
		move.b	#%00000011,$ffff8a3b.w		;LOP
		move.w	#25,$ffff8a36.w			;X-loop
		rts

swirl_blitter_greets:
		clr.b	$ffff8a3d.w			;Shift
		move.w	#2,$ffff8a20.w			;SX-inc
		move.w	#2,$ffff8a22.w			;SY-inc
		move.w	#8,$ffff8a2e.w			;DX-inc
		move.w	#24+8+16,$ffff8a30.w		;DY-inc
		move.w	#-1,$ffff8a28.w			;EM1
		move.w	#-1,$ffff8a2a.w			;EM2
		move.w	#-1,$ffff8a2c.w			;EM3
		move.b	#%00000010,$ffff8a3a.w		;HTOP
		move.b	#%00000011,$ffff8a3b.w		;LOP
		move.w	#23,$ffff8a36.w			;X-loop

		move.l	swirl_greets_adr,$ffff8a24.w	;Src
		move.l	screen_adr,$ffff8a32.w		;Dst
		;add.l	#166+8+224*100,$ffff8a32.w	;Dst adjust
		add.l	#6+8+224*100,$ffff8a32.w	;Dst adjust
		move.w	#64,$ffff8a38.w			;Lines
		move.b	#%11000000,$ffff8a3c.w		;BltCnt

		rts


swirl_movement:
		move.l	#buf+swirl_rander,swirl_source

		move.l	screen_adr2,a0
		;lea	160(a0),a0
		lea	swirl_bpl,a1
		add.w	.bpl,a1
		add.w	(a1),a0
		move.l	a0,swirl_destination

		cmp.w	#10,.bpl
		blt.s	.addbpl
		move.w	#-2,.bpl
.addbpl:	addq.w	#2,.bpl

		cmp.l	#400/8*273*58,.frame
		ble.s	.add
		move.l	#-400/8*273,.frame
.add:		add.l	#400/8*273,.frame

		move.l	.frame,d0
		add.l	d0,swirl_source

		rts
.frame:		dc.l	0
.bpl:		dc.w	0


swirl_load_data:
		move.l	#swirl_rander1_fn,filename
		move.l	swirl_rander1_fl,filelength
		move.l	#buf+swirl_rander,filebuffer
		jsr	loader

		move.l	#swirl_rander2_fn,filename
		move.l	swirl_rander2_fl,filelength
		move.l	#buf+swirl_rander2,filebuffer
		jsr	loader

		move.l	#swirl_greets_fn,filename
		move.l	swirl_greets_fl,filelength
		move.l	#buf+swirl_greets,filebuffer
		jsr	loader

		rts

swirl_make_fade:

		move.l	#swirl_pal01,.storesrc
		move.w	#48-1,.cnt
.p1:		lea	swirl_pal01,a0
		lea	swirl_pal02,a1
		jsr	component_fade
		bsr	.store
		subq.w	#1,.cnt
		bpl.s	.p1

		move.l	#swirl_pal02,.storesrc
		move.w	#48-1,.cnt
.p2:		lea	swirl_pal02,a0
		lea	swirl_pal03,a1
		jsr	component_fade
		bsr	.store
		subq.w	#1,.cnt
		bpl.s	.p2

		move.w	#288-1,.cnt
.fill:		movem.l	d0-d3,(a1)
		lea	16(a1),a1
		subq.w	#1,.cnt
		bpl.s	.fill
		add.w	#16*287,.pos

		move.l	#swirl_pal03,.storesrc
		move.w	#48-1,.cnt
.p3:		lea	swirl_pal03,a0
		lea	swirl_black,a1
		jsr	component_fade
		bsr	.store
		subq.w	#1,.cnt
		bpl.s	.p3

		move.w	#288-1,.cnt
.fill2:		movem.l	d0-d3,(a1)
		lea	16(a1),a1
		subq.w	#1,.cnt
		bpl.s	.fill2
		add.w	#16*288,.pos

		rts

.store:		lea	buf+swirl_pals,a1
		add.w	.pos,a1
		add.w	#16,.pos
		move.l	.storesrc,a0
		movem.l	(a0),d0-d3
		movem.l	d0-d3,(a1)
		rts

.storesrc:	dc.l	0
.pos:		dc.w	16*288
.cnt:		dc.w	0


swirl_fadein:
		cmp.w	#16*384,swirl_fadepos
		blt.s	.add
		sub.w	#16*4,swirl_fadepos
.add:		add.w	#16*4,swirl_fadepos
		rts

swirl_fadeout:
		cmp.w	#16*720,swirl_fadepos
		blt.s	.add
		sub.w	#16*4,swirl_fadepos
.add:		add.w	#16*4,swirl_fadepos
		rts

; 0-287 	black
; 288-383	fade
; 384-671	pal
; 672-719	fade
; 720-1008	black

swirl_greets_makefade:
		move.w	#48-1,.cnt
.l:
		lea	swirl_white,a0
		lea	swirl_textpal,a1
		jsr	component_fade

		movem.l	swirl_white+16,d0-d3
		lea	buf+swirl_grfade,a0
		add.w	.pos,a0
		add.w	#16,.pos
		movem.l	d0-d3,(a0)

		subq.w	#1,.cnt
		bpl.s	.l

		rts
.cnt:		dc.w	0
.pos:		dc.w	0


swirl_cycle_greets:
		cmp.w	#47*16,swirl_grfade_pos
		blt.s	.add
		clr.w	swirl_grfade_pos
		bra.s	.cycle
.add:		add.w	#16,swirl_grfade_pos
		rts

.cycle:		lea	swirl_greetslist,a0
		add.w	.pos,a0
		tst.l	(a0)
		beq.s	.empty

		move.l	(a0),swirl_greets_adr
		addq.w	#4,.pos
.no:		rts

.empty:		move.l	#buf+swirl_greets_e,swirl_greets_adr
		rts
.pos:		dc.w	0



		section	data

swirl_grfade_pos:
		dc.w	0
swirl_greets_adr:
		dc.l	buf+swirl_greets_e

swirl_fadepos:	dc.w	0

swirl_pal01:
.bg:		set	$0000
.c1:		set	$0000
.c2:		set	$0000
.c3:		set	$0000
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dcb.w	8,$0000

swirl_pal02:
.bg:		set	$0000
.c1:		set	$0fff
.c2:		set	$0fff
.c3:		set	$0fff
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dcb.w	8,$0000

swirl_pal03:
.bg:		set	$0000
.c1:		set	$0199
.c2:		set	$0a33
.c3:		set	$0c55
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dcb.w	8,$0000

swirl_textpal:
.bg:		set	$0000
.c1:		set	$0199
.c2:		set	$0a33
.c3:		set	$0c55
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3
		dc.w	.bg,.c1,.c1,.c2,.c1,.c2,.c2,.c3

swirl_black:	dcb.w	16,$0000
swirl_white:	dcb.w	16,$0fff

swirl_bpl:		dc.w	0,0,2,2,4,4,0,0,2,2,4,4

swirl_greets_fn:	dc.b	'data\greets.1pl'
			even
swirl_greets_fl:	dc.l	368*64*10/8

swirl_rander1_fn:	dc.b	'data\rander1.1pl'
			even
swirl_rander1_fl:	dc.l	400/8*273*30

swirl_rander2_fn:	dc.b	'data\rander2.1pl'
			even
swirl_rander2_fl:	dc.l	400/8*273*30

swirl_greetslist:
		dc.l	buf+swirl_greets+368*64/8*10	;empty
		dc.l	buf+swirl_greets+368*64/8*10	;empty
		dc.l	buf+swirl_greets+368*64/8*10	;empty
		dc.l	buf+swirl_greets+368*64/8*10	;empty
		dc.l	buf+swirl_greets+368*64/8*0
		dc.l	buf+swirl_greets+368*64/8*1
		dc.l	buf+swirl_greets+368*64/8*2
		dc.l	buf+swirl_greets+368*64/8*3
		dc.l	buf+swirl_greets+368*64/8*4
		dc.l	buf+swirl_greets+368*64/8*5
		dc.l	buf+swirl_greets+368*64/8*6
		dc.l	buf+swirl_greets+368*64/8*7
		dc.l	buf+swirl_greets+368*64/8*8
		dc.l	buf+swirl_greets+368*64/8*9
		dc.l	0

		section	bss

swirl_source:		ds.l	1
swirl_destination:	ds.l	1

		section	text

