; kefrens.s
;
; Fullscreen Kefrensbars

		section	text

;--- Init ----------------------------------------------------------------------------

kefrens_init:

.barinit:	bsr.w	kefrens_raster_update
		subq.w	#1,.count
		bpl.s	.barinit
		rts
.count:		dc.w	1024-1

;--- Runtime Init ---------------------------------------------------------------------

kefrens_runtime_init:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal
		jsr	kefrens_mk_sin			;calc long complicated sin list
		jsr	kefrens_sinpos			;calc a new offset for every line

		move.l	screen_adr,a0
		lea.l	160(a0),a0
		move.l	a0,kef_adr1
		lea.l	208(a0),a0
		move.l	a0,kef_adr2

		lea.l	kefrens_barlist,a0
		lea.l	kefrens_rast+228,a1
		move.w	#32*8-1,d7
.barlist:	move.l	a1,(a0)+
		dbra	d7,.barlist

;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#kefrens_code1_end,d0	;top 226 lines
		sub.l	#kefrens_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#113-1,d7
.code1a:	move.l	d0,d6
		lea.l	kefrens_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#kefrens_code2_end,d0	;4 midlines
		sub.l	#kefrens_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code2a:	move.l	d0,d6
		lea.l	kefrens_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		dbra	d7,.code2a

		move.l	#kefrens_code1_end,d0	;lower 42 lines (uses same code as top lines) 
		sub.l	#kefrens_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#21-1,d7
.code3a:	move.l	d0,d6
		lea.l	kefrens_code1_start,a1
.code3b:	move.w	(a1)+,(a0)+
		dbra	d6,.code3b
		dbra	d7,.code3a

		move.l	#kefrens_code3_end,d0	;final line
		sub.l	#kefrens_code3_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#1-1,d7
.code4a:	move.l	d0,d6
		lea.l	kefrens_code3_start,a1
.code4b:	move.w	(a1)+,(a0)+
		dbra	d6,.code4b
		dbra	d7,.code4a
		
		move.w	dummy,(a0)+
;-------------- end of overscan code -----------

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

;--- VBL ----------------------------------------------------------------------------
kefrens_vbl_in1:
		movem.l	kefrens_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#3,.wait
		lea.l	kefrens_mainpal,a0
		lea.l	kefrens_pal,a1
		jsr	component_fade
.nofade:	tst.l	kefrens_scroll_pos
		beq.s	.scroll_done
		subq.l	#2,kefrens_scroll_pos
.scroll_done:	bsr.s	kefrens_vbl
		rts
.wait:		dc.w	3
kefrens_vbl_in2:
		tst.l	kefrens_scroll_pos
		beq.s	.scroll_done
		subq.l	#2,kefrens_scroll_pos
.scroll_done:	bsr.s	kefrens_vbl
		bsr.w	kefrens_raster_update
		rts


kefrens_vbl_out1:
		cmp.l	#274*3,kefrens_scroll_pos
		bgt.s	.scroll_done
		addq.l	#2,kefrens_scroll_pos
.scroll_done:	bsr.s	kefrens_vbl
		bsr.w	kefrens_raster_update
		rts
kefrens_vbl_out2:
		movem.l	kefrens_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		subq.w	#1,.wait
		bne.s	.nofade
		move.w	#3,.wait
		lea.l	kefrens_mainpal,a0
		lea.l	kefrens_blackpal,a1
		jsr	component_fade
.nofade:

		bsr.s	kefrens_vbl
		rts
.wait:		dc.w	3


kefrens_vbl:
		lea.l	$ffff8203.w,a6
		move.l	screen_adr,d1
		movep.l	d1,(a6)

		move.l	screen_adr,a0
		lea.l	160(a0),a0
		move.l	a0,kef_adr1
		lea.l	208(a0),a0
		move.l	a0,kef_adr2

		jsr	kefrens_sinpos		;calc a new offset for every line

		move.l	#kefrens_positions,kefrens_posadr
		
		move.l	kef_adr1,a0
		move.l	kef_adr2,a1

		moveq.l	#0,d0
		move.w	#208/4-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a1)+
		dbra	d7,.clr

		lea.l	kefrens_spritepos,a3	;3
		move.l	kefrens_posadr,a4	;5

		move.l	kef_adr1,a5		;5
		move.l	a5,a1			;1	restore base addr
		move.l	a5,a2			;1
		move.w	(a4)+,d0		;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		move.w	(a0),d1			;2	get mask2
		swap	d1			;1
		move.w	(a0)+,d1		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		and.l	d1,(a1)+		;5
		and.l	d1,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		move.l	(a0)+,d1		;3
		move.l	(a0)+,d2		;3
		move.l	(a0)+,d3		;3
		or.l	d0,(a2)+		;5	fill gfx
		or.l	d1,(a2)+		;5
		or.l	d2,(a2)+		;5
		or.l	d3,(a2)+		;5	=62

		rts


kefrens_raster_update:
		

		lea.l	kefrens_rast,a0
		moveq.l	#0,d0
		rept	137
		move.l	d0,(a0)+
		endr

		lea.l	sincos4000,a2
		add.l	#54,.sin
		and.l	#$1fff,.sin
		move.l	.sin,d0
		move.w	(a2,d0.l),d1
               	muls.w	#128*2,d1
		asr.l	#8,d1
		asr.l	#7,d1
		add.l	d1,d1

		;add.l	#46,.sin2
		;and.l	#$1fff,.sin2
		;move.l	.sin2,d0
		;move.w	(a2,d0.l),d2
               	;muls.w	#128,d2
		;asr.l	#8,d2
		;asr.l	#7,d2
		;add.l	d2,d2
		;add.l	d2,d1
		
		lea.l	kefrens_barlist,a0
		add.l	.pos,a0
		move.l	d1,(a0)


		lea.l	kefrens_barlist,a0
		add.l	.pos7,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-20,a0
		add.l	d0,a0
		lea.l	kefrens_bar7,a1
		rept	10
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos7
		cmp.l	#32*8,.pos7
		blt.s	.noreset7
		clr.l	.pos7
.noreset7:
		lea.l	kefrens_barlist,a0
		add.l	.pos6,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-22,a0
		add.l	d0,a0
		lea.l	kefrens_bar6,a1
		rept	11
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos6
		cmp.l	#32*8,.pos6
		blt.s	.noreset6
		clr.l	.pos6
.noreset6:
		lea.l	kefrens_barlist,a0
		add.l	.pos5,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-24,a0
		add.l	d0,a0
		lea.l	kefrens_bar5,a1
		rept	12
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos5
		cmp.l	#32*8,.pos5
		blt.s	.noreset5
		clr.l	.pos5
.noreset5:
		lea.l	kefrens_barlist,a0
		add.l	.pos4,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-26,a0
		add.l	d0,a0
		lea.l	kefrens_bar4,a1
		rept	13
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos4
		cmp.l	#32*8,.pos4
		blt.s	.noreset4
		clr.l	.pos4
.noreset4:
		lea.l	kefrens_barlist,a0
		add.l	.pos3,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-28,a0
		add.l	d0,a0
		lea.l	kefrens_bar3,a1
		rept	14
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos3
		cmp.l	#32*8,.pos3
		blt.s	.noreset3
		clr.l	.pos3
.noreset3:

		lea.l	kefrens_barlist,a0
		add.l	.pos2,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-30,a0
		add.l	d0,a0
		lea.l	kefrens_bar2,a1
		rept	15
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos2
		cmp.l	#32*8,.pos2
		blt.s	.noreset2
		clr.l	.pos2
.noreset2:

		lea.l	kefrens_barlist,a0
		add.l	.pos,a0
		move.l	(a0),d0
		add.l	kefrens_scroll_pos,d0
		lea.l	kefrens_rast+274-32,a0
		add.l	d0,a0
		lea.l	kefrens_bar1,a1
		rept	16
		move.l	(a1)+,(a0)+
		endr
		add.l	#4,.pos
		cmp.l	#32*8,.pos
		blt.s	.noreset
		clr.l	.pos
.noreset:




.sin:		dc.l	0
.sin2:		dc.l	0
.pos:		dc.l	224
.pos2:		dc.l	192
.pos3:		dc.l	160
.pos4:		dc.l	128
.pos5:		dc.l	96
.pos6:		dc.l	64
.pos7:		dc.l	32



;--- Main ----------------------------------------------------------------------------

kefrens_main:	rts
		
;--- Timer A ------------------------------------------------------------------------------

kefrens_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-2-18,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1

		move.l	kef_adr1,d5		;5
		move.l	kef_adr2,d4		;5
		lea.l	kefrens_spritepos,a3	;3
		move.l	kefrens_posadr,a4	;5


		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a6
		moveq.l	#127,d3
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a6)				;hardsync
		beq.s	.sync				;
		move.b	(a6),d2				;
		sub.b	d2,d3				;
		lsr.l	d3,d3				;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-5-5,$4e71


		lea.l	kefrens_rast,a5		;3
		lea.l	$ffff8203.w,a6		;2

		jsr	generic_code		;5
		
		move.l	empty_adr,d0
		movep.l	d0,(a6)
		clr.w	$ffff8240.w

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts


kefrens_code1_start:
;line 1-226
		;rept	226/2
		movep.l	d5,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4)+,d0		;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5
		and.l	d0,(a1)+		;5	mask background
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-19,$4e71		;20
		move.l	kef_adr1,d0		;5
		move.l	kef_adr2,kef_adr1	;9
		move.l	d0,kef_adr2		;5
		;-------------------------------
		movep.l	d5,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4),d0			;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-10,$4e71		;20	
		move.l	kef_adr1,d5		;5
		move.l	kef_adr2,d4		;5
		;endr
kefrens_code1_end:


kefrens_code2_start:
;227+228
		movep.l	d5,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4)+,d0		;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-19,$4e71		;20
		move.l	kef_adr1,d0		;5
		move.l	kef_adr2,kef_adr1	;9
		move.l	d0,kef_adr2		;5
		;-------------------------------
		movep.l	d5,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4),d0			;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-13,$4e71		;20	
		move.l	kef_adr1,d5		;5
		move.l	kef_adr2,d4		;5
		movep.l	d5,(a6)			;3	+3 next scan

;line 229+230
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		;dcb.w	87-4-83,$4e71		;87
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4)+,d0		;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-19,$4e71		;20
		move.l	kef_adr1,d0		;5
		move.l	kef_adr2,kef_adr1	;9
		move.l	d0,kef_adr2		;5
		;-------------------------------
		movep.l	d5,(a6)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4),d0			;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5	mask background
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-10,$4e71		;20	
		move.l	kef_adr1,d5		;5
		move.l	kef_adr2,d4		;5
kefrens_code2_end:


kefrens_code3_start:
;273
		movep.l	d5,(a6)			;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-4-83,$4e71		;90
		move.w	(a5)+,$ffff8240.w	;4
		move.l	d4,a1			;1	restore base addr
		move.l	d4,a2			;1
		move.w	(a4),d0			;2	x-position
		lsl.w	#3,d0			;3
		move.l	(a3,d0.w),d1		;5	xofset
		add.l	d1,a1			;2
		add.l	d1,a2			;2
		move.l	4(a3,d0.w),a0		;5	=21 address to sprite mask/gfx
		move.w	(a0),d0			;2	get mask1
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.w	(a0),d0			;2	get mask2
		swap	d0			;1
		move.w	(a0)+,d0		;2
		and.l	d0,(a1)+		;5	mask background
		and.l	d0,(a1)+		;5
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.l	(a0)+,d0		;3	get gfx
		or.l	d0,(a2)+		;5	fill gfx
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-19,$4e71		;20
		move.l	kef_adr1,d0		;5
		move.l	kef_adr2,kef_adr1	;9
		move.l	d0,kef_adr2		;5
kefrens_code3_end:






kefrens_mk_sin:		
		lea	kefrens_sin,a1	
		lea	sincos4000,a0
		move.w	#$2000*2+273*8-1,d7	;$1fff=8192-1
.sl:
		; see movement.gcx for a graph
		add.l	#16,.sin1
		and.l	#$1ffe,.sin1
		add.l	#32,.sin2
		and.l	#$1ffe,.sin2
		move.l	.sin1,d0
		move.w	(a0,d0.w),d1	; +/- 3f00
		muls	d0,d1		;$2000 * 3f00 = $0800 0000
		swap	d1		;$0800
		asr.w	#1,d1
		add.w	#$0400,d1
		and.w	#4096-1,d1
		add.w	d1,d1
		move.w	(a0,d1.w),d1
		move.l	.sin2,d0
		add.w	(a0,d0.w),d1
               	muls.w	#320,d1		;scale to screen
		asr.l	#8,d1		;swap-1
		asr.l	#7,d1
		add.w	#80,d1		;center
		move.w	d1,(a1)+	;save sin value
		dbra	d7,.sl
		rts

.sin1:		dc.l	0
.sin2:		dc.l	0

kefrens_sinpos:
		lea	kefrens_sin,a0
		add.l	.pos,a0
		lea	2*273(a0),a2
		add.l	#2,.pos
		and.l	#$4000-1-1,.pos
		lea	kefrens_positions,a1
		move.w	#273/2+1-1,d7
.cs:
		move.w	(a0)+,d0
		add.w	-(a2),d0
		lsr.w	#1,d0
		move.w	d0,(a1)+
		addq.l	#2*4,a0		;skip 4 values
		dbra	d7,.cs
		rts

.pos:		dc.l	0

;--- Data ---------------------------------------------------------------------------------------------
		
		section	data

kefrens_spritepos:
q:			set	0
			rept	416/16
			;	xbyteofset,spriteofset
			dc.l	q,kefrens_sprite+20*0
			dc.l	q,kefrens_sprite+20*1
			dc.l	q,kefrens_sprite+20*2
			dc.l	q,kefrens_sprite+20*3
			dc.l	q,kefrens_sprite+20*4
			dc.l	q,kefrens_sprite+20*5
			dc.l	q,kefrens_sprite+20*6
			dc.l	q,kefrens_sprite+20*7
			dc.l	q,kefrens_sprite+20*8
			dc.l	q,kefrens_sprite+20*9
			dc.l	q,kefrens_sprite+20*10
			dc.l	q,kefrens_sprite+20*11
			dc.l	q,kefrens_sprite+20*12
			dc.l	q,kefrens_sprite+20*13
			dc.l	q,kefrens_sprite+20*14
			dc.l	q,kefrens_sprite+20*15
q:			set	q+8
			endr

kefrens_positions:	dcb.w	273,$0000
kefrens_posadr:		dc.l	kefrens_positions
kefrens_scroll_pos:	dc.l	274*3+50

kefrens_sprite:	incbin	'kefrens/kefgfx.4pl'
			even

kefrens_blackpal:	dcb.w	16,$0000
kefrens_mainpal:	dcb.w	16,$0000
kefrens_pal:		dc.w	$0000,$0100,$0210,$0321,$0432,$0543,$0664,$0776
			dc.w	$0777,$0677,$0466,$0345,$0234,$0123,$0012,$0001


kefrens_bar1:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd,$0466,$0cee,$0577,$0eff,$0fff
			dc.w	$0ffe,$0775,$0eec,$0664,$0ddb,$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar2:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd,$0466,$0cee,$0577,$0eff
			dc.w	$0775,$0eec,$0664,$0ddb,$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar3:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd,$0466,$0cee,$0577
			dc.w	$0eec,$0664,$0ddb,$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar4:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd,$0466,$0cee
			dc.w	$0664,$0ddb,$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar5:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd,$0466
			dc.w	$0ddb,$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar6:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355,$0bdd
			dc.w	$0553,$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000

kefrens_bar7:		dc.w	$0088,$0011,$0099,$0022,$08aa,$0133,$09bb,$0244
			dc.w	$0acc,$0355
			dc.w	$0cca,$0442
			dc.w	$0bb9,$0331,$0aa8,$0220,$0990,$0110,$0880,$0000





			section	bss

kefrens_barlist:	ds.l	32*8

kefrens_sinbuf:		ds.l	4

			ds.w	274
kefrens_rast:		ds.w	274
			ds.w	274
			ds.w	274*2

kef_adr1:		ds.l	1
kef_adr2:		ds.l	1
		
			section	text
