;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; INTRO.S : intro effect
;	need	TABLES.S
;			DRAW.S
;			RENDER.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; intro_init : initialise intro
;-----------------------------------------------------------------------------

intro_init:
	movem.l		d0-d7/a0-a6,	-(sp)

	lea			intro_disk,		a0			; draw disk
	moveq		#16,			d0
	move.w		#200,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	move.l		scr_back,		a0
	moveq		#96,			d0
	moveq		#84,			d1
	bsr			draw_disk
	lea			intro_disk,		a1
	lea			516(a1),		a1
	moveq		#12,			d0
	move.l		#168,			d1
	moveq		#8,				d2
	bsr			store_plan

	lea			sin_table,		a0			; calc curves
	lea			cos_table,		a1
	lea			intro_curve,	a2
	lea			intro_rotate,	a3
	lea			1440(a3),		a4
	lea			intro_trans,	a5
	moveq		#0,				d1			; offset * 1
	moveq		#0,				d2			; offset * 4
	moveq		#13,			d5
	moveq		#12,			d6
	move.l		#359,			d0
intro_init_1:
	move.w		0(a0,d1),		d3			; sin(a)
	add.w		0(a0,d2),		d3			; sin(a)+sin(a*4)
	muls.w		#112,			d3
	asr.l		d5,				d3
	addi.w		#112,			d3
	move.w		d3,				(a2)+
	move.w		0(a1,d1),		d4			; cos(a)
	add.w		0(a1,d2),		d4			; cos(a)+cos(a*4)
	muls.w		#58,			d4
	asr.l		d5,				d4
	addi.w		#58,			d4
	move.w		d4,				(a2)+
	move.w		0(a0,d1),		d3			; sin(a)
	muls.w		#48,			d3
	asr.l		d6,				d3
	addi.w		#48,			d3
	move.w		d3,				(a3)+
	move.w		d3,				(a4)+
	move.w		0(a1,d1),		d4			; cos(a)
	muls.w		#42,			d4
	asr.l		d6,				d4
	addi.w		#42,			d4
	move.w		d4,				(a3)+
	move.w		d4,				(a4)+
	move.w		0(a0,d1),		d3			; sin(a)
	muls.w		#312,			d3
	asr.l		d6,				d3
	addi.w		#312,			d3
	move.w		d3,				(a5)+
	addq.w		#2,				d1
	addq.w		#8,				d2
	cmpi.w		#720,			d2
	bne.s		intro_init_2
	moveq		#0,				d2
intro_init_2:
	dbra		d0,intro_init_1

	lea			intro_scroll,	a0			; draw scroll
	moveq		#59,			d0
	move.w		#96,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	lea			intro_tobe,		a2
	lea			intro_scroll,	a3
	lea			intro_offset,	a4
	lea			intro_size,		a5
	moveq		#96,			d1
	moveq		#10,			d3
intro_init_3:
	move.l		(a2)+,			a0
	move.w		(a4)+,			d4
	lea			0(a3,d4.w),		a1
	move.w		(a5)+,			d0
	moveq		#118,			d2
	sub.w		d0,				d2
	sub.w		d0,				d2
	bsr			bplan_copy
	dbra		d3,intro_init_3

	moveq		#0,				d0			; setup 1st frame
	move.w		d0,intro_crv_o
	move.w		d0,intro_rtt_o
	move.w		d0,intro_trs_o
	
	move.w		#200,intro_opn_i

	move.w		d0,intro_exit
	move.w		#256,intro_step				; setup enter fade
	lea			intro_fade,		a0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+

	move.l		#intro_gem,intro_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; intro_fini : finalise intro
;-----------------------------------------------------------------------------

intro_fini:
	bsr			scr_white
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; intro_main : intro rendering
;-----------------------------------------------------------------------------

intro_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	move.l		intro_proc,		a0			; render step
	jsr			(a0)
	move.w		intro_exit,		d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		intro_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
intro_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		intro_main_1
	moveq		#2,				d0			; quit
intro_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

; ----------------------------------------------------------

intro_gem:
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	move.w		intro_step,		d0			; step
	subq.w		#4,				d0
	bne.s		intro_gem_0
	move.l		#intro_enter,intro_proc
intro_gem_0:
	move.w		d0,intro_step
	rts

intro_enter:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_setpal
	bsr			intro_render_s
	bsr			intro_open
	move.w		intro_step,		d0			; step
	addq.w		#4,				d0
	cmpi.w		#256,			d0
	bne.s		intro_enter_0
	move.l		#intro_loop,intro_proc
	move.w		#560,			d0
intro_enter_0:
	move.w		d0,intro_step
	rts

intro_loop:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	bsr			pal_draw
	bsr			intro_setpal
	bsr			intro_render_s
	bsr			intro_open
	move.w		intro_step,		d0			; step
	subq.w		#1,				d0
	bne.s		intro_loop_0
	move.l		#intro_leave,intro_proc
	move.w		#256,			d0
intro_loop_0:
	move.w		d0,intro_step
	rts

intro_leave:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_setpal
	bsr			intro_render_s
	move.w		#240,			d0			; step
	lea			intro_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		intro_step,		d0
	subi.w		#16,			d0
	bne.s		intro_leave_0
	bsr			scr_white
	move.l		#intro_enterb,intro_proc
	moveq		#0,				d0
intro_leave_0:
	move.w		d0,intro_step
	rts

; ----------------------------------------------------------

intro_enterb:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_setpal
	bsr			intro_render
	lea			intro_fade,		a0
	move.w		#240,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		intro_step,		d0			; step
	addi.w		#16,			d0
	cmpi.w		#256,			d0
	bne.s		intro_enterb_0
	move.l		#intro_loopb,intro_proc
	move.w		#1120,			d0
intro_enterb_0:
	move.w		d0,intro_step
	rts

intro_loopb:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	bsr			pal_draw
	bsr			intro_setpal
	bsr			intro_render
	move.w		intro_step,		d0			; step
	subq.w		#1,				d0
	bne.s		intro_loopb_0
	move.l		#intro_leaveb,intro_proc
	move.w		#256,			d0
intro_loopb_0:
	move.w		d0,intro_step
	rts

intro_leaveb:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_setpal
	bsr			intro_render
	move.w		#240,			d0			; step
	lea			intro_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		intro_step,		d0
	subi.w		#16,			d0
	bne.s		intro_leaveb_0
	bsr			scr_white
	move.l		#intro_enterc,intro_proc
	moveq		#0,				d0
intro_leaveb_0:
	move.w		d0,intro_step
	rts

; ----------------------------------------------------------

intro_enterc:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_render
	lea			intro_fade,		a0
	move.w		#240,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		intro_step,		d0			; step
	addi.w		#16,			d0
	cmpi.w		#256,			d0
	bne.s		intro_enterc_0
	move.l		#intro_loopc,intro_proc
	move.w		#700,			d0
intro_enterc_0:
	move.w		d0,intro_step
	rts

intro_loopc:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	bsr			pal_draw
	bsr			intro_render
	move.w		intro_step,		d0			; step
	subq.w		#1,				d0
	bne.s		intro_loopc_0
	move.l		#intro_leavec,intro_proc
	move.w		#256,			d0
intro_loopc_0:
	move.w		d0,intro_step
	rts

intro_leavec:
	lea			intro_angles,	a0			; render palette
	lea			intro_colors,	a1
	lea			intro_incr,		a2
	bsr			pal_rotate2
	lea			intro_colors,	a0
	bsr			pal_mix
	move.w		intro_step,		d0
	lea			intro_fade,		a0
	bsr			pal_blend
	bsr			intro_render
	lea			intro_fade,		a0
	moveq		#120,			d0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		intro_step,		d0
	subq.w		#8,				d0
	bne.s		intro_leavec_0
	move.w		#1,intro_exit				; exit
intro_leavec_0:
	move.w		d0,intro_step
	rts

; ----------------------------------------------------------

intro_setpal:
	lea			$FFFF8240.W,	a0
	move.w		(a0),			d0
	move.w		d0,				04(a0)
	move.w		d0,				08(a0)
	move.w		d0,				12(a0)
	move.w		d0,				16(a0)
	move.w		d0,				20(a0)
	move.w		d0,				24(a0)
	move.w		d0,				28(a0)
	rts

intro_render:
	lea			intro_disk,		a0			; render disks
	move.l		scr_back,		a6
	lea			-28864(a6),		a6
	lea			intro_curve,	a2
	lea			intro_rotate,	a3
	lea			yoff_table,		a4
	lea			xoff8_table,	a5
	moveq		#16,			d0
	move.w		#200,			d1
	move.w		#$0203,			d3
	move.w		#160,			d4
	move.w		intro_crv_o,	d5
	move.w		intro_rtt_o,	d6

	addq.l		#2,				a6
	move.w		0(a2,d5.w),		d2			; x
	move.w		2(a2,d5.w),		d7			; y
	add.w		0(a3,d6.w),		d2
	add.w		2(a3,d6.w),		d7
	lsl.w		#2,				d7
	move.l		a6,				a1
	adda.l		0(a4,d7.w),		a1
	move.w		d2,				d7
	andi.w		#$F,			d2
	add.w		d7,				d7
	adda.w		0(a5,d7.w),		a1
	bsr			bplan_blit

	addq.l		#2,				a6
	adda.w		#480,			a3
	move.w		0(a2,d5.w),		d2			; x
	move.w		2(a2,d5.w),		d7			; y
	add.w		0(a3,d6.w),		d2
	add.w		2(a3,d6.w),		d7
	lsl.w		#2,				d7
	move.l		a6,				a1
	adda.l		0(a4,d7.w),		a1
	move.w		d2,				d7
	andi.w		#$F,			d2
	add.w		d7,				d7
	adda.w		0(a5,d7.w),		a1
	bsr			bplan_blit

	addq.l		#2,				a6
	adda.w		#480,			a3
	move.w		0(a2,d5.w),		d2			; x
	move.w		2(a2,d5.w),		d7			; y
	add.w		0(a3,d6.w),		d2
	add.w		2(a3,d6.w),		d7
	lsl.w		#2,				d7
	move.l		a6,				a1
	adda.l		0(a4,d7.w),		a1
	move.w		d2,				d7
	andi.w		#$F,			d2
	add.w		d7,				d7
	adda.w		0(a5,d7.w),		a1
	bsr			bplan_blit

	addq.w		#4,				d5
	cmpi.w		#1440,			d5
	bcs.s		intro_render_0
	subi.w		#1440,			d5
intro_render_0:
	addi.w		#16,			d6
	cmpi.w		#1440,			d6
	bcs.s		intro_render_1
	subi.w		#1440,			d6
intro_render_1:
	move.w		d5,intro_crv_o
	move.w		d6,intro_rtt_o

intro_render_s:
	lea			intro_scroll,	a0			; render scroll
	move.l		scr_back,		a1
	lea			568(a1),		a1			; -8
	lea			intro_trans,	a2
	lea			yoff_table,		a3
	lea			xoff2_table,	a4

	moveq		#78,			d0
	moveq		#96,			d1
	move.w		#$0203,			d3

	move.w		intro_trs_o,	d4			; x
	move.w		0(a2,d4.w),		d5
	move.w		#623,			d6			; inverse x
	sub.w		d5,				d6

	move.w		d5,				d2
	andi.w		#$F,			d2
	add.w		d5,				d5
	adda.w		0(a4,d5.w),		a0
	bsr			bplan_scroll

	lea			intro_scroll,	a0			; render inverse scroll
	lea			28800(a1),		a1			; 29952
	move.w		d6,				d2
	andi.w		#$F,			d2
	add.w		d6,				d6
	adda.w		0(a4,d6.w),		a0
	bsr			bplan_scroll

	addq.w		#2,				d4
	cmpi.w		#720,			d4
	bcs.s		intro_render_2
	moveq		#0,				d4
intro_render_2:
	move.w		d4,intro_trs_o

	rts

intro_open:
	move.l		scr_back,		a0
	moveq		#20,			d0
	move.w		intro_opn_i,	d1
	move.w		d1,				d4
	lsr.w		#1,				d1
	beq.s		intro_open_rts
	move.w		#128,			d2
	bsr			bplan_clear8

	move.w		#200,			d3
	sub.w		d1,				d3
	mulu.w		#288,			d3
	adda.l		d3,				a0
	bsr			bplan_clear8

	subq.w		#1,				d4
	move.w		d4,intro_opn_i

intro_open_rts:
	rts

;=============================================================================
				SECTION DATA
;=============================================================================


intro_angles:	dc.w			105, 105,  70	; black
				dc.w			  0,   0,   0	; white
				dc.w			  0, 180, 135	; red
				dc.w			135,   0, 180	; green
				dc.w			180, 135,   0	; blue

intro_incr:		dc.w			0, 0, 0			; angles incr
				dc.w			0, 0, 0
				dc.w			0, 4, 0
				dc.w			0, 0, 4
				dc.w			4, 0, 0

intro_tobe:		dc.l			intro_gfxs+0	; t
				dc.l			intro_gfxs+768	; o
				dc.l			intro_gfxs+1536	; b
				dc.l			intro_gfxs+2304	; e

intro_mjjp:		dc.l			intro_gfxs+6144	; m
				dc.l			intro_gfxs+3072	; j
				dc.l			intro_gfxs+3072	; j
				dc.l			intro_gfxs+3840	; p
				dc.l			intro_gfxs+4608	; r
				dc.l			intro_gfxs+768	; o
				dc.l			intro_gfxs+5376	; d

							;	T   O   B   E   M   J   J   P   R   O   D
intro_offset:	dc.w			0, 10, 20, 30, 44, 60, 70, 80, 90, 100, 110
intro_size:		dc.w			4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4


;=============================================================================
				SECTION BSS
;=============================================================================


intro_exit:		ds.w			1
intro_proc:		ds.l			1
intro_step:		ds.w			1
intro_fade:		ds.w			3

intro_crv_o:	ds.w			1
intro_rtt_o:	ds.w			1
intro_trs_o:	ds.w			1
intro_opn_i:	ds.w			1

intro_colors:	ds.w			15

; 32  192  32     = 256 pixels
; +-+-----+-+  16 * 256 =  4096 pixels		=  512 bytes
; +-+-----+-+
; | |     | |
; | |     | | 168 * 256 = 43008 pixels		= 5376 bytes
; +-+-----+-+
; +-+-----+-+  16 * 256 =  4096 pixels		=  512 bytes
;											-------
intro_disk:		ds.b			6400		; 6400 bytes

;   80    80    80     112     128     80    80    80    80    80    64
; +-----+-----+-----+-------+--------+-----+-----+-----+-----+-----+----+
; |TTTT |OOOO |BBBB |EEEE   |MMMMMMM |JJJJ |JJJJ |PPPP |RRRR |OOOO |DDDD| 96
; +-----+-----+-----+-------+--------+-----+-----+-----+-----+-----+----+
; 80 * 8 + 112 + 128 + 64 = 944 * 96		= 90624 pixels
;											---------
intro_scroll:	ds.b			11328		; 11328 bytes

intro_curve:	ds.l			360			; 360 [x.w,y.w]
intro_rotate:	ds.l			720			; 360 [x.w,y.w] * 2
intro_trans:	ds.w			360			; 360 [x.w]


;=============================================================================
;				END OF FILE
;=============================================================================

