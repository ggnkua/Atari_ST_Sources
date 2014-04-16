; Overscan truecolour mode
;
; Ofsmap plasma-a-like-thing
;
; ae@dhs.nu
; 2011-12-14


		section	text

fulltc_init:
		rts

fulltc_runtime_init:
		run_once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens
		jsr	clear_buf
		bsr	fulltc_load_data
		bsr	fulltc_triple_txt
		bsr	fulltc_init_smc

		init_finish_green
		rts

fulltc_runtime_init2:
		run_once
		init_finish_red

		jsr	black_pal
		jsr	clear_screens
		bsr	fulltc_code_copy
		bsr	fulltc_blitter_init
		bsr	fulltc_copy_bg
		bsr	fulltc_copy_overlay
		clr.w	buf+fulltc_overlay

		init_finish_green
		rts


fulltc_vbl:
		move.l  screen_adr,d0
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w

		rts

fulltc_vbl_in:
		bsr	fulltc_vbl

		movem.l	fulltc_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea	fulltc_black,a0
		lea	buf+fulltc_overlay,a1
		jsr	component_fade

		rts

fulltc_vbl_out:
		bsr	fulltc_vbl

		movem.l	fulltc_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		subq.w	#1,.cnt
		bpl.s	.no

		lea	fulltc_black,a0
		lea	fulltc_black2,a1
		jsr	component_fade

.no:		bsr	fulltc_clear_texture

		rts
.cnt:		dc.w	30

fulltc_main:
		bsr	fulltc_effect
		;jsr	rastertime
		rts

fulltc_ta:
		do_hardsync_top_border

		move.b	#52,$fffffa1f.w		;timera_delay+3	delay (data)
		move.b	#4,$fffffa19.w		;timera_div+3	prediv (start Timer-A)

		move.l	#fulltc_ta_effect,$134.w
		rts

fulltc_ta_effect:
		movem.l	d0-a6,-(sp)

		do_hardsync

		;inits
		dcb.w	66-22-24-2-2,$4e71			;


		lea	$ffff8a38.w,a0			;2 Blitter lines
		lea	$ffff8a3c.w,a1			;2 Blitter control
		lea	$ffff8a26.w,a2			;2 Blitter src
		move.w	#%11000000,d1			;2 Start blitter
		move.l	#buf+fulltc_chunky,-2(a2)	;6 Src blitter
		lea	buf+fulltc_chunky+84,a3		;3 Src special case
		lea	$ffff8240+20.w,a4		;2 Dst special case
		lea	fulltc_dline,a5			;4
		moveq	#14,d0				;1 Blitter lines
		;moveq	#96-84,d6			;1 Blitter src modulo
		moveq	#2,d7				;1 Overscan
		lea	$ffff820a.w,a6			;2 Right border opt

		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)+			;5
		lea	-12(a4),a4			;2
		lea	84-12(a3),a3			;2
		move.w	(a5)+,d6			;2 Modulo
		add.w	d6,a3				;2 Special src

		move.w	d0,(a0)				;2


		jsr	codebuf				;5
		jsr	black_pal

		movem.l	(sp)+,d0-a6

		move.l	#timer_a,$134.w

		rte


fulltc_normal_begin:
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3

		nop
		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+2+84

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)			;5
		subq.w	#8,a4				;2
		lea	84-12(a3),a3			;2

		add.w	d6,(a2)				;3 Blitter src
		move.w	(a5)+,d6			;2 Modulo
		add.w	d6,a3				;2 Special src
fulltc_normal_end:


fulltc_normal_begin_mste:
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3

		move.w	d0,(a0)				;2
		move.b	d1,(a1)				;2+3+84

		move.w	d7,(a6)				;2
		nop
		move.b	d7,(a6)				;2

		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)+			;5
		move.l	(a3)+,(a4)			;5
		subq.w	#8,a4				;2
		lea	84-12(a3),a3			;2

		add.w	d6,(a2)				;3 Blitter src
		move.w	(a5)+,d6			;2 Modulo
		add.w	d6,a3				;2 Special src
fulltc_normal_end_mste:


fulltc_code_copy:
		jsr	code_copy_reset

		cmp.l	#"MSTe",computer_type
		bne.s	.ste

		move.l	#fulltc_normal_begin_mste,d0
		move.l	#fulltc_normal_end_mste,d1
		bra.s	.copy

.ste:		move.l	#fulltc_normal_begin,d0
		move.l	#fulltc_normal_end,d1
.copy:		move.w	#199+10,d2
		jsr	code_copy


		jsr	code_copy_rts
		rts


fulltc_blitter_init:
		clr.b	$ffff8a3d.w				;Shift
		move.w	#2,$ffff8a20.w				;SX-inc
		move.w	#2,$ffff8a22.w				;SY-inc
		move.w	#2,$ffff8a2e.w				;DX-inc
		move.w	#-4,$ffff8a30.w				;DY-inc
		move.w	#-1,$ffff8a28.w				;EM1
		move.w	#-1,$ffff8a2a.w				;EM2
		move.w	#-1,$ffff8a2c.w				;EM3
		move.b	#%00000010,$ffff8a3a.w			;HTOP
		move.b	#%00000011,$ffff8a3b.w			;LOP
		move.w	#3,$ffff8a36.w				;X-loop
		move.l	#$ffff8240+14,$ffff8a32.w		;Dest

		rts

fulltc_copy_bg:
		move.l	screen_adr,a0
		lea	160*19(a0),a0
		move.w	#256/8-1,d7
.y:		move.w	#8-1,d5
		lea	buf+fulltc_bg+32,a1
.y2:		move.w	#200/4-1,d6
.x:
		move.l	(a1)+,(a0)+
		dbra	d6,.x
		lea	224-200(a0),a0
		dbra	d5,.y2
		dbra	d7,.y

		rts

fulltc_copy_overlay:
.lift:		equ	20
		move.l	screen_adr,a0
		lea	160*19(a0),a0

		;lea	buf+fulltc_overlay+32,a1
		lea	buf+fulltc_overlay+32+(192*.lift),a1

		move.w	#210-.lift-1,d7
.y:		move.w	#384/16-1,d6
.x:
		movem.w	(a1)+,d0-d3
		move.w	d0,d4
		or.w	d1,d4
		or.w	d2,d4
		or.w	d4,d4
		not.w	d4
		and.w	d4,(a0)+
		and.w	d4,(a0)+
		and.w	d4,(a0)+
		and.w	d4,(a0)+
		subq.l	#8,a0
		or.w	d0,(a0)+
		or.w	d1,(a0)+
		or.w	d2,(a0)+
		or.w	d3,(a0)+

		dbra	d6,.x
		lea	224-192(a0),a0
		dbra	d7,.y
		rts

fulltc_triple_txt:
		lea	buf+fulltc_txt,a1
		move.l	a1,a2
		add.l	#128*128*2,a2
		move.l	a2,a3
		add.l	#128*128*2,a3
		move.w	#128*128/2-1,d7
.l:		move.l	(a1)+,d0
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		dbra	d7,.l

		rts

fulltc_effect:
		add.l	#2+256,fulltc_pos
		and.l	#$7fff,fulltc_pos

		lea	buf+fulltc_txt+128*128*2,a1
		add.l	fulltc_pos,a1
		lea	buf+fulltc_chunky,a2
fulltc_smc:
		rept	48*43
		move.w	1234(a1),(a2)+	;4
		endr

		rts
fulltc_pos:	dc.l	0


fulltc_init_smc:
		lea	fulltc_smc+2,a0
		lea	buf+fulltc_ofs,a1
		move.w	#48*43-1,d7
.l:		moveq	#0,d0
		move.w	(a1)+,d0
		add.w	d0,d0
		move.w	d0,(a0)
		addq.l	#4,a0
		dbra	d7,.l
		rts


fulltc_load_data:
		move.l	#fulltc_bg_fn,filename
		move.l	fulltc_bg_fl,filelength
		move.l	#buf+fulltc_bg,filebuffer
		jsr	loader

		move.l	#fulltc_tx_fn,filename
		move.l	fulltc_tx_fl,filelength
		move.l	#buf+fulltc_txt,filebuffer
		jsr	loader

		move.l	#fulltc_ol_fn,filename
		move.l	fulltc_ol_fl,filelength
		move.l	#buf+fulltc_overlay,filebuffer
		jsr	loader

		move.l	#fulltc_of_fn,filename
		move.l	fulltc_of_fl,filelength
		move.l	#buf+fulltc_ofs,filebuffer
		jsr	loader

		rts

fulltc_clear_texture:
		lea	buf+fulltc_txt,a0
		lea	buf+fulltc_txt+128*128*2,a1
		lea	buf+fulltc_txt+128*128*2*2,a2

		add.w	.pos,a0
		add.w	.pos,a1
		add.w	.pos,a2

		moveq	#0,d0

		rept	128*2/4
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		endr

		cmp.w	#128*2*127,.pos
		bge.s	.ok
		add.w	#128*2,.pos

.ok:		rts
.pos:		dc.w	0

		section	data

fulltc_black:	dcb.w	16,$0000
fulltc_black2:	dcb.w	16,$0000

fulltc_dline:
		rept	60
		dc.w	12,-84-96,12,-84-96,12
		;dc.w	-84,-84,-84,-84,12
		endr


fulltc_bg_fn:	dc.b	'data\fulltcbg.4pl',0
		even
fulltc_bg_fl:	dc.l	32+400/2*8

fulltc_tx_fn:	dc.b	'data\fulltctx.12b',0
		even
fulltc_tx_fl:	dc.l	128*128*2

fulltc_ol_fn:	dc.b	'data\fulltcol.4pl',0
		even
fulltc_ol_fl:	dc.l	32+(384*210/2)

fulltc_of_fn:	dc.b	'data\fulltcof.bin',0
		even
fulltc_of_fl:	dc.l	48*53*2


		section	text

