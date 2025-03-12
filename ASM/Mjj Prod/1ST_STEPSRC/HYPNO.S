;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; HYPNO.S : hypno effect
;	need	TABLES.S
;			DRAW.S
;			RENDER.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; hypno_init : initialise
;-----------------------------------------------------------------------------

hypno_init:
	movem.l		d0-d7/a0-a6,	-(sp)
	lea			hypno_disk1,	a0			; draw disk 1
	moveq		#12,			d0
	move.w		#172,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	move.l		scr_back,		a0
	moveq		#80,			d0
	moveq		#70,			d1
	bsr			draw_disk
	lea			hypno_disk1,	a1
	lea			386(a1),		a1
	moveq		#10,			d0
	move.l		#140,			d1
	moveq		#4,				d2
	bsr			copy_plan
	lea			hypno_disk1b,	a1
	moveq		#10,			d0
	move.l		#140,			d1
	moveq		#0,				d2
	bsr			store_plan

	lea			hypno_disk2,	a0			; draw disk 2
	moveq		#10,			d0
	move.w		#144,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	move.l		scr_back,		a0
	moveq		#64,			d0
	moveq		#56,			d1
	bsr			draw_disk
	lea			hypno_disk2,	a1
	lea			322(a1),		a1
	moveq		#8,				d0
	move.l		#112,			d1
	moveq		#4,				d2
	bsr			copy_plan
	lea			hypno_disk2b,	a1
	moveq		#8,				d0
	move.l		#112,			d1
	moveq		#0,				d2
	bsr			store_plan

	lea			hypno_disk3,	a0			; draw disk 3
	moveq		#8,				d0
	move.w		#116,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	move.l		scr_back,		a0
	moveq		#48,			d0
	moveq		#42,			d1
	bsr			draw_disk
	lea			hypno_disk3,	a1
	lea			258(a1),		a1
	moveq		#6,				d0
	move.l		#84,			d1
	moveq		#4,				d2
	bsr			copy_plan
	lea			hypno_disk3b,	a1
	moveq		#6,				d0
	move.l		#84,			d1
	moveq		#0,				d2
	bsr			store_plan

	lea			hypno_disk4,	a0			; draw disk 4
	moveq		#6,				d0
	move.w		#88,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	move.l		scr_back,		a0
	moveq		#32,			d0
	moveq		#28,			d1
	bsr			draw_disk
	lea			hypno_disk4,	a1
	lea			194(a1),		a1
	moveq		#4,				d0
	move.l		#56,			d1
	moveq		#4,				d2
	bsr			copy_plan
	lea			hypno_disk4b,	a1
	moveq		#4,				d0
	move.l		#56,			d1
	moveq		#0,				d2
	bsr			store_plan

	lea			sin_table,		a0			; calc curves
	lea			cos_table,		a1
	lea			hypno_curve,	a2
	lea			hypno_curveb,	a3
	lea			hypno_trans,	a4
	moveq		#0,				d1			; offset * 1
	moveq		#0,				d2			; offset * 2
	moveq		#0,				d3			; offset * 3
	moveq		#12,			d6
	move.l		#359,			d0
hypno_init_1:
	move.w		0(a1,d1),		d4			; cos(a)
	muls.w		0(a0,d2),		d4			; cos(a)*sin(a*2)
	asr.l		d6,				d4
	muls.w		#128,			d4
	asr.l		d6,				d4
	addi.w		#192,			d4
	move.w		0(a0,d1),		d5			; sin(a)
	muls.w		0(a1,d3),		d5			; sin(a)*cos(a*3)
	asr.l		d6,				d5
	muls.w		#128,			d5
	asr.l		d6,				d5
	addi.w		#144,			d5
	move.w		d4,				(a2)+
	move.w		d5,				(a2)+

	move.w		0(a1,d1),		d4			; cos(a)
	muls.w		0(a0,d2),		d4			; cos(a)*sin(a*2)
	asr.l		d6,				d4
	muls.w		#128,			d4
	asr.l		d6,				d4
	addi.w		#144,			d4
	move.w		0(a0,d1),		d5			; sin(a)
	muls.w		0(a1,d3),		d5			; sin(a)*cos(a*3)
	asr.l		d6,				d5
	muls.w		#128,			d5
	asr.l		d6,				d5
	addi.w		#192,			d5
	move.w		d5,				(a3)+
	move.w		d4,				(a3)+
	
	move.w		0(a0,d1),		d4
	muls.w		#80,			d4
	asr.l		d6,				d4
	addi.w		#80,			d4
	move.w		d4,				(a4)+

	addq.w		#2,				d1
	addq.w		#4,				d2
	cmpi.w		#720,			d2
	bne.s		hypno_init_2
	moveq		#0,				d2
hypno_init_2:
	addq.w		#6,				d3
	cmpi.w		#720,			d3
	bne.s		hypno_init_3
	moveq		#0,				d3
hypno_init_3:
	dbra		d0,hypno_init_1

	lea			hypno_scroll,	a0			; draw scroll
	moveq		#72,			d0
	move.w		#88,			d1			; 56
	moveq		#0,				d2
	bsr			bplan_clear2
	lea			hypno_text,		a2
	lea			hypno_scroll,	a3
	lea			2304(a3),		a3
	lea			hypno_offset,	a4
	lea			hypno_size,		a5
	moveq		#56,			d1
	moveq		#21,			d3
	moveq		#0,				d4
hypno_init_4:
	move.l		(a2)+,			a0
	lea			0(a3,d4.w),		a1
	move.w		(a5)+,			d0
	move.w		#144,			d2
	sub.w		d0,				d2
	sub.w		d0,				d2
	bsr			bplan_copy
	add.w		(a4)+,			d4
	dbra		d3,hypno_init_4

	moveq		#0,				d0			; setup 1st frame
	move.w		d0,hypno_crv_o
	move.w		#4,hypno_crv_ob
	move.w		d0,hypno_pos_o
	move.w		d0,hypno_trs_o
	move.w		d0,hypno_exit
	move.w		d0,hypno_step
	move.w		#2,hypno_trs_i
	lea			hypno_fade,		a0			; setup enter fade
	move.w		#3840,			d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)
	
	move.l		#hypno_entera,hypno_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; hypno_fini : finalise
;-----------------------------------------------------------------------------

hypno_fini:
	bsr			scr_white
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; hypno_main : rendering
;-----------------------------------------------------------------------------

hypno_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	lea			hypno_angles,	a0			; render palette
	lea			hypno_colors,	a1
	lea			hypno_incr,		a2
	bsr			pal_rotate2
	lea			hypno_colors,	a0
	bsr			pal_add
	move.l		hypno_proc,		a0			; render step
	jsr			(a0)
	move.w		hypno_exit,		d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		hypno_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
hypno_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		hypno_main_1
	moveq		#2,				d0			; quit
hypno_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

; ----------------------------------------------------------

hypno_entera:
	move.w		#8,hypno_trs_i
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_rendera
	lea			hypno_fade,		a0
	moveq		#60,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		hypno_step,		d0			; step
	addq.w		#4,				d0
	cmpi.w		#128,			d0
	bne.s		hypno_entera_0
	move.l		#hypno_loopa,hypno_proc
	move.w		#225,			d0
hypno_entera_0:
	move.w		d0,hypno_step
	rts

hypno_loopa:
	move.w		#128,			d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_rendera
	move.w		hypno_step,		d0			; step
	subq.w		#1,				d0
	bne.s		hypno_loopa_0
	move.l		#hypno_leavea,hypno_proc
	move.w		#128,			d0
hypno_loopa_0:
	move.w		d0,hypno_step
	rts

hypno_leavea:
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_rendera
	moveq		#120,			d0			; step
	lea			hypno_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		hypno_step,		d0
	subq.w		#8,				d0
	bne.s		hypno_leavea_0
	bsr			scr_white
	move.l		#hypno_enterb,hypno_proc
hypno_leavea_0:
	move.w		d0,hypno_step
	rts

; ----------------------------------------------------------

hypno_enterb:
	move.w		#8,hypno_trs_i
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderb
	lea			hypno_fade,		a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		hypno_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#128,			d0
	bne.s		hypno_enterb_0
	move.l		#hypno_loopb,hypno_proc
	move.w		#350,			d0
hypno_enterb_0:
	move.w		d0,hypno_step
	rts

hypno_loopb:
	move.w		#128,			d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderb
	move.w		hypno_step,		d0			; step
	subq.w		#1,				d0
	bne.s		hypno_loopb_0
	move.l		#hypno_leaveb,hypno_proc
	move.w		#128,			d0
hypno_loopb_0:
	move.w		d0,hypno_step
	rts

hypno_leaveb:
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderb
	moveq		#120,			d0			; step
	lea			hypno_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		hypno_step,		d0
	subq.w		#8,				d0
	bne.s		hypno_leaveb_0
	bsr			scr_white
	move.l		#hypno_enterc,hypno_proc
hypno_leaveb_0:
	move.w		d0,hypno_step
	rts

; ----------------------------------------------------------

hypno_enterc:
	move.w		#8,hypno_trs_i
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderc
	lea			hypno_fade,		a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		hypno_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#128,			d0
	bne.s		hypno_enterc_0
	move.l		#hypno_loopc,hypno_proc
	move.w		#1470,			d0
hypno_enterc_0:
	move.w		d0,hypno_step
	rts

hypno_loopc:
	move.w		#128,			d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderc
	move.w		hypno_step,		d0			; step
	subq.w		#1,				d0
	bne.s		hypno_loopc_0
	move.l		#hypno_leavec,hypno_proc
	move.w		#128,			d0
hypno_loopc_0:
	move.w		d0,hypno_step
	rts

hypno_leavec:
	move.w		hypno_step,		d0
	lea			hypno_fade,		a0
	bsr			pal_blend
	bsr			hypno_renderc
	moveq		#60,			d0			; step
	lea			hypno_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		hypno_step,		d0
	subq.w		#4,				d0
	bne.s		hypno_leavec_0
	move.w		#1,hypno_exit			; exit
hypno_leavec_0:
	move.w		d0,hypno_step
	rts

; ----------------------------------------------------------

hypno_rendera:
	lea			hypno_trans,	a2
	lea			yoff_table,		a3
	move.w		hypno_trs_o,	d6
	move.w		0(a2,d6.w),		d0
	lsl.w		#2,				d0
	move.l		scr_back,		a1
	lea			-6914(a1),		a1
	adda.l		0(a3,d0.w),		a1
	lea			xoff2_table,	a4
	move.w		hypno_pos_o,	d4			; x
	move.w		d4,				d5
	add.w		d5,				d5
	lea			hypno_scroll,	a0			; render scroll
	adda.w		0(a4,d5.w),		a0
	moveq		#104,			d0
	moveq		#88,			d1			; 56
	move.w		d4,				d2
	andi.w		#$F,			d2
	move.w		#$0203,			d3
	bsr			bplan_scroll
	addq.w		#2,				d4
	cmpi.w		#784,			d4
	blt.s		hypno_rendera_0
	moveq		#0,				d4
hypno_rendera_0:
	move.w		d4,hypno_pos_o
	add.w		hypno_trs_i,	d6
	cmpi.w		#720,			d6
	blt.s		hypno_rendera_1
	moveq		#0,				d6
hypno_rendera_1:
	move.w		d6,hypno_trs_o
	rts


hypno_renderb:
	lea			yoff_table,		a3
	lea			xoff8_table,	a4
	move.l		scr_back,		a1			; draw first disks
	suba.l		#36928,			a1
	lea			hypno_curveb,	a2
	move.w		#$0203,			d3
	move.w		hypno_crv_o,	d5
	lea			0(a2,d5.w),		a2
	move.w		(a2)+,			d2			; x
	move.w		(a2),			d6			; y
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		d2,				d6
	andi.w		#$F,			d2
	add.w		d6,				d6
	adda.w		0(a4,d6.w),		a1
	lea			hypno_disk1,	a0
	moveq		#12,			d0
	move.w		#172,			d1
	move.w		#192,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk2,	a0
	moveq		#10,			d0
	move.w		#144,			d1
	move.w		#208,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk3,	a0
	moveq		#8,				d0
	move.w		#116,			d1
	move.w		#224,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk4,	a0
	moveq		#6,				d0
	move.w		#88,			d1
	move.w		#$0100,			d3
	move.w		#240,			d4
	bsr			bplan_blit

	movem.l		d0-d5/a0-a4,	-(sp)
	bsr			hypno_rendera
	movem.l		(sp)+,			d0-d5/a0-a4

	move.w		#$0207,			d3
	move.w		#240,			d4
	bsr			bplan_blit
	addq.w		#4,				d5			; next frame
	cmpi.w		#1440,			d5
	bcs.s		hypno_renderb_2
	subi.w		#1440,			d5
hypno_renderb_2:
	move.w		d5,hypno_crv_o
	
	move.w		hypno_crv_ob,	d5
	addi.w		#8,				d5			; next frame
	cmpi.w		#1440,			d5
	bcs.s		hypno_renderb_3
	subi.w		#1440,			d5
hypno_renderb_3:
	move.w		d5,hypno_crv_ob
	rts


hypno_renderc:
	lea			yoff_table,		a3
	lea			xoff8_table,	a4

	move.l		scr_back,		a1			; clear second disks
	suba.l		#32312,			a1
	lea			hypno_curve,	a2
	move.w		#$0100,			d3
	move.w		hypno_crv_ob,	d5
	subi.w		#16,			d5
	bge.s		hypno_render_0
	addi.w		#1440,			d5
hypno_render_0:
	lea			0(a2,d5.w),		a2
	move.w		(a2)+,			d2			; x
	move.w		(a2),			d6			; y
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		d2,				d6
	andi.w		#$F,			d2
	add.w		d6,				d6
	adda.w		0(a4,d6.w),		a1

	lea			hypno_disk1b,	a0
	moveq		#10,			d0
	move.w		#140,			d1
	move.w		#208,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk2b,	a0
	moveq		#8,				d0
	move.w		#112,			d1
	move.w		#224,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk3b,	a0
	moveq		#6,				d0
	move.w		#84,			d1
	move.w		#240,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk4b,	a0
	moveq		#4,				d0
	move.w		#56,			d1
	move.w		#256,			d4
	bsr			bplan_blit

	move.l		scr_back,		a1			; draw first disks
	suba.l		#36928,			a1
	lea			hypno_curveb,	a2
	move.w		#$0203,			d3
	move.w		hypno_crv_o,	d5
	lea			0(a2,d5.w),		a2

	move.w		(a2)+,			d2			; x
	move.w		(a2),			d6			; y
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		d2,				d6
	andi.w		#$F,			d2
	add.w		d6,				d6
	adda.w		0(a4,d6.w),		a1

	lea			hypno_disk1,	a0
	moveq		#12,			d0
	move.w		#172,			d1
	move.w		#192,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk2,	a0
	moveq		#10,			d0
	move.w		#144,			d1
	move.w		#208,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk3,	a0
	moveq		#8,				d0
	move.w		#116,			d1
	move.w		#224,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk4,	a0
	moveq		#6,				d0
	move.w		#88,			d1
	move.w		#$0100,			d3
	move.w		#240,			d4
	bsr			bplan_blit

	movem.l		d0-d5/a0-a4,	-(sp)
	bsr			hypno_rendera
	movem.l		(sp)+,			d0-d5/a0-a4


	move.w		#$0207,			d3
	move.w		#240,			d4
	bsr			bplan_blit

	addq.w		#4,				d5			; next frame
	cmpi.w		#1440,			d5
	bcs.s		hypno_render_2
	subi.w		#1440,			d5
hypno_render_2:
	move.w		d5,hypno_crv_o
	
	move.l		scr_back,		a1			; draw second disks
	suba.l		#32312,			a1
	lea			hypno_curve,	a2
	move.w		#$0207,			d3
	move.w		hypno_crv_ob,	d5
	lea			0(a2,d5.w),		a2
	move.w		(a2)+,			d2			; x
	move.w		(a2),			d6			; y
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		d2,				d6
	andi.w		#$F,			d2
	add.w		d6,				d6
	adda.w		0(a4,d6.w),		a1

	lea			hypno_disk1b,	a0
	moveq		#10,			d0
	move.w		#140,			d1
	move.w		#208,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk2b,	a0
	moveq		#8,				d0
	move.w		#112,			d1
	move.w		#224,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk3b,	a0
	moveq		#6,				d0
	move.w		#84,			d1
	move.w		#240,			d4
	bsr			bplan_blit
	lea			4042(a1),		a1
	lea			hypno_disk4b,	a0
	moveq		#4,				d0
	move.w		#56,			d1
	move.w		#256,			d4
	bsr			bplan_blit

	addi.w		#8,				d5			; next frame
	cmpi.w		#1440,			d5
	bcs.s		hypno_render_3
	subi.w		#1440,			d5
hypno_render_3:
	move.w		d5,hypno_crv_ob

	rts


;=============================================================================
				SECTION DATA
;=============================================================================


hypno_angles:	dc.w			185, 140,  95
				dc.w			 90, 135, 180
				dc.w			120, 120, 120
				dc.w			120, 120, 120
				dc.w			120, 120, 120

hypno_incr:		dc.w			0, 0, 0			; angles incr
				dc.w			0, 0, 3
				dc.w			0, 0, 0
				dc.w			0, 0, 0
				dc.w			0, 0, 0

hypno_text:		dc.l			hypno_gfxs+0	; d
				dc.l			hypno_gfxs+336	; h
				dc.l			hypno_gfxs+672	; s
				dc.l			hypno_gfxs+1008	; 1
				dc.l			hypno_gfxs+2912	; 0
				dc.l			hypno_gfxs+1232	; y
				dc.l			hypno_gfxs+1568	; e
				dc.l			hypno_gfxs+1904	; a
				dc.l			hypno_gfxs+2240	; r
				dc.l			hypno_gfxs+672	; s
				dc.l			hypno_gfxs+2576	; c
				dc.l			hypno_gfxs+2912	; o
				dc.l			hypno_gfxs+3248	; m
				dc.l			hypno_gfxs+3696	; p
				dc.l			hypno_gfxs+2912	; o

				dc.l			hypno_gfxs+0	; d
				dc.l			hypno_gfxs+336	; h
				dc.l			hypno_gfxs+672	; s
				dc.l			hypno_gfxs+1008	; 1
				dc.l			hypno_gfxs+2912	; 0
				dc.l			hypno_gfxs+1232	; y
				dc.l			hypno_gfxs+1568	; e

							;	D  H  S  1  0  Y  E  A  R  S
hypno_offset:	dc.w			6, 6, 8, 4, 8, 6, 6, 6, 6, 8
							;	C  O  M  P  O  D  H  S  1  0  Y  E
				dc.w			6, 6, 8, 6, 8, 6, 6, 8, 4, 8, 6, 6

hypno_size:		dc.w			3, 3, 3, 2, 3, 3, 3, 3, 3, 3
				dc.w			3, 3, 4, 3, 3, 3, 3, 3, 2, 3, 3, 3


;=============================================================================
				SECTION BSS
;=============================================================================


hypno_exit:		ds.w			1
hypno_proc:		ds.l			1
hypno_step:		ds.w			1
hypno_fade:		ds.w			3

hypno_crv_o:	ds.w			1
hypno_crv_ob:	ds.w			1
hypno_pos_o:	ds.w			1
hypno_trs_o:	ds.w			1
hypno_trs_i:	ds.w			1

hypno_colors:	ds.w			15

hypno_curve:	ds.l			360			; 360 [x.w,y.w]
hypno_curveb:	ds.l			360			; 360 [x.w,y.w]
hypno_trans:	ds.w			360			; 360 [x.w]

; 16  160  16     = 192 pixels
; +-+-----+-+  16 * 192 =  3072 pixels		=  384 bytes
; +-+-----+-+
; | |     | |
; | |     | | 140 * 192 = 26880 pixels		= 3360 bytes
; +-+-----+-+
; +-+-----+-+  16 * 192 =  3072 pixels		=  384 bytes
;											-------
hypno_disk1:	ds.b			4128		; 4128 bytes
hypno_disk1b:	ds.b			2800

; 16  128  16     = 160 pixels
; +-+-----+-+  16 * 160 =  2560 pixels		=  320 bytes
; +-+-----+-+
; | |     | |
; | |     | | 112 * 160 = 17920 pixels		= 2240 bytes
; +-+-----+-+
; +-+-----+-+  16 * 160 =  2560 pixels		=  320 bytes
;											-------
hypno_disk2:	ds.b			2880		; 2880 bytes
hypno_disk2b:	ds.b			1792

; 16   96  16     = 128 pixels
; +-+-----+-+  16 * 128 =  2048 pixels		=  256 bytes
; +-+-----+-+
; | |     | |
; | |     | |  84 * 128 = 10752 pixels		= 1344 bytes
; +-+-----+-+
; +-+-----+-+  16 * 128 =  2048 pixels		=  256 bytes
;											-------
hypno_disk3:	ds.b			1856		; 1856 bytes
hypno_disk3b:	ds.b			1008

; 16   64  16     =  96 pixels
; +-+-----+-+  16 *  96 =  1536 pixels		=  192 bytes
; +-+-----+-+
; | |     | |
; | |     | |  56 *  96 =  5376 pixels		=  672 bytes
; +-+-----+-+
; +-+-----+-+  16 *  96 =  1536 pixels		=  192 bytes
;											-------
hypno_disk4:	ds.b			1056		; 1056 bytes
hypno_disk4b:	ds.b			448

;   48  48  64  48  64   48  48  48  48  64   48  48  64   48  64
; +---+---+----+--+----+---+---+---+---+----+---+---+----+---+----+ 16
; +---+---+----+--+----+---+---+---+---+----+---+---+----+---+----+
; |DDD|HHH|SSS |11|000 |YYY|EEE|AAA|RRR|SSS |CCC|OOO|MMMM|PPP|OOO | 56
; +---+---+----+--+----+---+---+---+---+----+---+---+----+---+----+
; +---+---+----+--+----+---+---+---+---+----+---+---+----+---+----+ 16
; (48 * 10 + 64 * 5)		= 800 + 352		= 1152  pixels
;							* 56			= 64512 pixels
;											---------
hypno_scroll:	ds.b			12672	;	8064		;  8064 bytes


;=============================================================================
;				END OF FILE
;=============================================================================

