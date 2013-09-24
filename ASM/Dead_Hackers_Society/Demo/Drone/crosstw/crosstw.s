; Horizontal twister with shaded vectors on top
;
; ae@dhs.nu
; 2011-12-02

		section	text

crosstw_init:	rts

crosstw_runtime_init:
		run_once
		init_finish_red

		bsr	clear_screens
		jsr	clear_buf
		bsr	crosstw_load_data
		clr.w	buf+crosstw_gfx4
		bsr	crosstw_init_str
		bsr	crosstw_code_copy
		bsr	crosstw_blitter_init

		init_finish_green
		rts


crosstw_main:	bsr	crosstw_update_gfx
		bsr	crosstw_scroll
		bsr	crosstw_animate_str

		lea	crosstw_black,a0
		lea	buf+crosstw_gfx4,a1
		jsr	component_fade
		rts


crosstw_vbl:	lea	$ffff8203.w,a0
		move.l	screen_adr,d0
		movep.l	d0,0(a0)

		movem.l	crosstw_black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

crosstw_main_out:
		move.l	#buf+crosstw_gfx12b+196,crosstw_gfxadr
		bsr	crosstw_update_gfx
		bsr	crosstw_scroll
		bsr	crosstw_animate_str

		subq.w	#1,.wait
		bpl.s	.no

		lea	crosstw_black,a0
		lea	crosstw_black2,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	120

crosstw_shift:	dc.w	3

crosstw_ta:
		do_hardsync_top_border

		move.w	crosstw_shifts,d0
		lsl.w	d0,d1

		dcb.w	55-32-6,$4e71

		lea	buf+crosstw_cols+200,a0		;3 Source
		add.w	crosstw_scrofs,a0		;5
		add.w	crosstw_xsin,a0			;5
		move.l	a0,$ffff8a24.w			;4

		lea	$ffff8a38.w,a0			;2 Blitter lines
		lea	$ffff8a3c.w,a1			;2 Blitter control
		lea	$ffff8203.w,a2			;2 Screen address counter
		;lea	crosstw_scradrs,a3		;3
		lea	buf+crosstw_str,a3		;3
		add.l	crosstw_frame,a3		;6

		moveq	#1,d0				;1 Lines
		move.w	#%11000000,d1			;2 Start blitter
		move.l	(a3)+,d2			;3

		jsr	codebuf

		move.l	screen_adr,d2
		movep.l	d2,0(a2)

		clr.w	$ffff8240.w
		jsr	black_pal
		rts


crosstw_both_start:
		nop
		movep.l	d2,0(a2)			;6
		move.l	(a3)+,d2			;3

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+106
		dcb.w	128-122,$4e71
crosstw_both_end:


crosstw_both_start_mste:
		movep.l	d2,0(a2)			;6
		move.l	(a3)+,d2			;3

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+106
		dcb.w	128-122,$4e71
crosstw_both_end_mste:



crosstw_single_start:
		movep.l	d2,0(a2)			;6
		move.l	(a3)+,d2			;3

		dcb.w	128-9,$4e71
crosstw_single_end:


crosstw_lowerborder_start:
		movep.l	d2,0(a2)			;6
		move.l	(a3)+,d2			;3

		clr.w	$ffff8240.w			;4

		dcb.w	128-13-6,$4e71
		movep.l	d2,0(a2)			;6
		;-----

		clr.b	$ffff820a.w			;4
		move.l	(a3)+,d2			;3
		move.b	#2,$ffff820a.w			;4

		;setup for twister copy
		lea	buf+crosstw_cols,a0		;3
		add.w	crosstw_scrofs,a0		;5
		;lea	buf+crosstw_gfx12+196,a1	;3
		move.l	crosstw_gfxadr,a1		;5
		add.l	crosstw_tofs,a1			;6

		dcb.w	128-11-19,$4e71
crosstw_lowerborder_end:

crosstw_copytwist_start:
		movep.l	d2,0(a2)			;6
		move.l	(a3)+,d2			;3

		rept	10
		move.w	(a1)+,d0			;2
		move.w	d0,(a0)				;2
		move.w	d0,512(a0)			;3
		lea	1024(a0),a0			;2 = 9
		endr

		dcb.w	128-9-90,$4e71
crosstw_copytwist_end:


crosstw_code_copy:
		jsr	code_copy_reset

		move.l	#crosstw_single_start,d0
		move.l	#crosstw_single_end,d1
		move.w	#27,d2
		jsr	code_copy

		cmp.l	#"MSTe",computer_type
		bne.s	.ste

		move.l	#crosstw_both_start_mste,d0
		move.l	#crosstw_both_end_mste,d1
		bra.s	.doit

.ste:		move.l	#crosstw_both_start,d0
		move.l	#crosstw_both_end,d1
.doit:		move.w	#200,d2
		jsr	code_copy

		move.l	#crosstw_lowerborder_start,d0
		move.l	#crosstw_lowerborder_end,d1
		move.w	#1,d2
		jsr	code_copy

		move.l	#crosstw_copytwist_start,d0
		move.l	#crosstw_copytwist_end,d1
		move.w	#20,d2
		jsr	code_copy

		move.l	#crosstw_single_start,d0
		move.l	#crosstw_single_end,d1
		move.w	#44-20,d2
		jsr	code_copy

		jsr	code_copy_rts
		rts


crosstw_update_gfx:

		add.l	#10,.sin
		and.l	#$1fff,.sin
		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#180*3-1,d1
		asr.l	#8,d1
		asr.l	#7,d1

		lea	crosstw_sinofs+180*4*5,a0
		asl.l	#2,d1
		move.l	(a0,d1.l),crosstw_tofs

.ok:		rts
.sin:		dc.l	0


crosstw_blitter_init:
		clr.b	$ffff8a3d.w				;Shift
		move.w	#2,$ffff8a20.w				;SX-inc
		move.w	#2+918,$ffff8a22.w			;SY-inc
		clr.w	$ffff8a2e.w				;DX-inc
		clr.w	$ffff8a30.w				;DY-inc
		move.w	#-1,$ffff8a28.w				;EM1
		move.w	#-1,$ffff8a2a.w				;EM2
		move.w	#-1,$ffff8a2c.w				;EM3
		move.b	#%00000010,$ffff8a3a.w			;HTOP
		move.b	#%00000011,$ffff8a3b.w			;LOP
		move.w	#53,$ffff8a36.w				;X-loop
		move.l	#$ffff8240,$ffff8a32.w			;Dest

		rts


crosstw_scroll:
		addq.w	#2,crosstw_scrofs
		cmp.w	#512*2,crosstw_scrofs
		blt.s	.ok
		clr.w	crosstw_scrofs
.ok:

		add.l	#64,.sin
		and.l	#$1fff,.sin

		lea	sincos4000,a0
		move.l	.sin,d0
		move.w	(a0,d0.l),d1
		muls.w	#199,d1
		asr.l	#8,d1
		asr.l	#7,d1

		move.w	d1,crosstw_xsin

		btst	#0,d1
		beq.s	.shift1
		move.w	#1,crosstw_shifts
		rts
.shift1:	move.w	#2,crosstw_shifts
		rts
.sin:		dc.l	0


crosstw_init_str:
		lea	buf+crosstw_str8,a0
		lea	buf+crosstw_str,a1
		lea	buf+crosstw_gfx4+32,a2

		move.l	#273*256-1,d7
.l:
		moveq	#0,d0
		move.b	(a0)+,d0
		mulu	#160,d0
		move.l	a2,d1
		add.l	d1,d0
		move.l	d0,(a1)+

		subq.l	#1,d7
		bpl.s	.l

		rts

crosstw_animate_str:
		cmp.l	#273*4*255,crosstw_frame
		blt.s	.add
		clr.l	crosstw_frame
		rts
.add:		add.l	#273*4,crosstw_frame
		rts


crosstw_load_data:
		move.l	#crosstw_str_fn,filename
		move.l	crosstw_str_fl,filelength
		move.l	#buf+crosstw_str8,filebuffer
		jsr	loader
		;----------
		move.l	#crosstw_g4_fn,filename
		move.l	crosstw_g4_fl,filelength
		move.l	#buf+crosstw_gfx4,filebuffer
		jsr	loader
		;----------
		move.l	#crosstw_tw_fn,filename
		move.l	crosstw_tw_fl,filelength
		move.l	#buf+crosstw_gfx12,filebuffer
		jsr	loader

		rts



		section	data

crosstw_shifts:	dc.w	0
crosstw_xsin:	dc.w	0
crosstw_frame:	dc.l	0
crosstw_tofs:	dc.l	0


crosstw_scradrs:
.q:		set	0
		rept	160
		dc.l	buf+crosstw_gfx4+32+.q
.q:		set	.q+160
		endr

.q:		set	0
		rept	160
		dc.l	buf+crosstw_gfx4+32+.q
.q:		set	.q+160
		endr

crosstw_sinofs:
		rept	10
.w:		set	0
		rept	180
		dc.l	.w
.w:		set	.w+384*2
		endr
		endr

crosstw_scrofs:	dc.w	0

crosstw_str_fn:	dc.b	'data\str.bin'				;3D raw data
		even
crosstw_str_fl:	dc.l	256*273

crosstw_g4_fn:	dc.b	'data\strgfx.4pl'			;320x160 4-bit bitplanes plus 32 byte palette
		even
crosstw_g4_fl:	dc.l	320*160/2+32

crosstw_tw_fn:	dc.b	'data\twist.12b'
		even
crosstw_tw_fl:	dc.l	384*180*2

crosstw_gfxadr:	dc.l	buf+crosstw_gfx12+196

crosstw_black:	dcb.w	16,$0000
crosstw_black2:	dcb.w	16,$0000


		section	bss


		rsreset
crosstw_str8:	rs.b	256*273					;~70k
crosstw_str:	rs.l	256*273					;~280k
crosstw_cols:	rs.w	512*256					;~256k
crosstw_gfx12:	rs.w	384*180					;~150k
crosstw_gfx12b:	rs.w	384*180					;~150k
crosstw_gfx4:	rs.b	320*160/2+32				;~26k

		section	text

