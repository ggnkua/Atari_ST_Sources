;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; BUBBLES.S : boucing bubbles effect
;	need	TABLES.S
;			DRAW.S
;			RENDER.S
;=============================================================================


bubbles_max:	equ				140

;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; bubbles_init : initialise
;-----------------------------------------------------------------------------

bubbles_init:
	movem.l		d0-d7/a0-a6,	-(sp)

	lea			bubbles_disk1,	a0			; clear disks
	moveq		#16,			d0
	move.w		#266,			d1
	moveq		#0,				d2
	bsr			bplan_clear2
	lea			bubbles_disk2,	a0
	bsr			bplan_clear2
	lea			bubbles_disk3,	a0
	bsr			bplan_clear2
	lea			bubbles_disk4,	a0
	bsr			bplan_clear2

	move.l		scr_back,		a0			; draw disks
	moveq		#80,			d0
	move.l		#128,			d1
	bsr			draw_disk
	lea			bubbles_disk1,	a1
	lea			322(a1),		a1
	moveq		#10,			d0
	move.l		#256,			d1
	moveq		#12,			d2
	bsr			copy_plan
	lea			bubbles_disk2,	a1
	lea			322(a1),		a1
	bsr			copy_plan
	lea			bubbles_disk3,	a1
	lea			322(a1),		a1
	bsr			copy_plan
	lea			bubbles_disk4,	a1
	lea			322(a1),		a1
	bsr			store_plan
	
	lea			bubbles_gfxs,	a0			; draw pseudos
	lea			bubbles_disk1,	a1
	lea			2628(a1),		a1
	moveq		#8,				d0
	moveq		#112,			d1
	moveq		#16,			d2
	bsr			bplan_copy
	lea			1792(a0),		a0
	lea			bubbles_disk2,	a1
	lea			2628(a1),		a1
	bsr			bplan_copy
	lea			1792(a0),		a0
	lea			bubbles_disk3,	a1
	lea			2628(a1),		a1
	bsr			bplan_copy
	lea			1792(a0),		a0
	lea			bubbles_disk4,	a1
	lea			2628(a1),		a1
	bsr			bplan_copy

	lea			sin_table,		a0			; calc curves
	lea			bubbles_curve,	a1
	moveq		#0,				d1
	moveq		#12,			d2
	move.l		#359,			d0
bubbles_init_1:
	move.w		0(a0,d1),		d3			; cos(a)
	muls.w		#80,			d3
	asr.l		d2,				d3
	addi.w		#80,			d3
	move.w		d3,				(a1)+
	addq.w		#2,				d1
	cmpi.w		#720,			d1
	blt.s		bubbles_init_2
	moveq		#0,				d1
bubbles_init_2:
	dbra		d0,bubbles_init_1

	move.w		#0,bubbles_exit

	move.w		#0,bubbles_crv_1
	move.w		#120,bubbles_crv_2
	move.w		#240,bubbles_crv_3
	move.w		#360,bubbles_crv_4

	move.w		#0,bubbles_pos_1
	move.w		#0,bubbles_pos_2
	move.w		#0,bubbles_pos_3
	move.w		#80,bubbles_pos_4

	moveq		#2,d0
	move.w		d0,bubbles_dir_1
	move.w		d0,bubbles_dir_2
	move.w		d0,bubbles_dir_3
	move.w		d0,bubbles_dir_4
	move.w		#0,bubbles_inter

	lea			bubbles_fade,	a0			; setup enter fade
	move.w		#3840,			d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)
	move.w		#0,bubbles_step

	move.l		#bubbles_entera,bubbles_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; bubbles_fini : finalise
;-----------------------------------------------------------------------------

bubbles_fini:
	bsr			scr_white
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; bubbles_main : rendering
;-----------------------------------------------------------------------------

bubbles_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
;	lea			bubbles_angles,	a0			; render palette
;	lea			bubbles_colors,	a1
;	lea			bubbles_incr,	a2
;	bsr			pal_rotate2
	lea			bubbles_colors,	a0
	bsr			pal_mix
	move.l		bubbles_proc,	a0			; render step
	jsr			(a0)
	not.w		bubbles_inter
	move.w		bubbles_exit,	d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		bubbles_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
bubbles_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		bubbles_main_1
	moveq		#2,				d0			; quit
bubbles_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

; ----------------------------------------------------------

bubbles_entera:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_rendera
	lea			bubbles_fade,	a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		bubbles_step,	d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		bubbles_entera_0
	move.l		#bubbles_loopa,bubbles_proc
	move.w		#200,			d0
bubbles_entera_0:
	move.w		d0,bubbles_step
	rts

bubbles_loopa:
	bsr			pal_draw
	bsr			bubbles_rendera
	move.w		bubbles_step,	d0			; step
	subq.w		#1,				d0
	bne.s		bubbles_loopa_0
	move.l		#bubbles_leavea,bubbles_proc
	move.w		#256,			d0
bubbles_loopa_0:
	move.w		d0,bubbles_step
	rts

bubbles_leavea:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_rendera
	moveq		#120,			d0			; step
	lea			bubbles_fade,	a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		bubbles_step,	d0
	subq.w		#8,				d0
	bne.s		bubbles_leavea_0
	bsr			scr_white
	move.l		#bubbles_enterb,bubbles_proc
bubbles_leavea_0:
	move.w		d0,bubbles_step
	rts

; ----------------------------------------------------------

bubbles_enterb:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderb
	lea			bubbles_fade,	a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		bubbles_step,	d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		bubbles_enterb_0
	move.l		#bubbles_loopb,bubbles_proc
	move.w		#200,			d0
bubbles_enterb_0:
	move.w		d0,bubbles_step
	rts

bubbles_loopb:
	bsr			pal_draw
	bsr			bubbles_renderb
	move.w		bubbles_step,	d0			; step
	subq.w		#1,				d0
	bne.s		bubbles_loopb_0
	move.l		#bubbles_leaveb,bubbles_proc
	move.w		#256,			d0
bubbles_loopb_0:
	move.w		d0,bubbles_step
	rts

bubbles_leaveb:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderb
	moveq		#120,			d0			; step
	lea			bubbles_fade,	a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		bubbles_step,	d0
	subq.w		#8,				d0
	bne.s		bubbles_leaveb_0
	bsr			scr_white
	move.l		#bubbles_enterc,bubbles_proc
bubbles_leaveb_0:
	move.w		d0,bubbles_step
	rts

; ----------------------------------------------------------

bubbles_enterc:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderc
	lea			bubbles_fade,	a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		bubbles_step,	d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		bubbles_enterc_0
	move.l		#bubbles_loopc,bubbles_proc
	move.w		#200,			d0
bubbles_enterc_0:
	move.w		d0,bubbles_step
	rts

bubbles_loopc:
	bsr			pal_draw
	bsr			bubbles_renderc
	move.w		bubbles_step,	d0			; step
	subq.w		#1,				d0
	bne.s		bubbles_loopc_0
	move.l		#bubbles_leavec,bubbles_proc
	move.w		#256,			d0
bubbles_loopc_0:
	move.w		d0,bubbles_step
	rts

bubbles_leavec:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderc
	moveq		#120,			d0			; step
	lea			bubbles_fade,	a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		bubbles_step,	d0
	subq.w		#8,				d0
	bne.s		bubbles_leavec_0
	bsr			scr_white
	move.l		#bubbles_enterd,bubbles_proc
bubbles_leavec_0:
	move.w		d0,bubbles_step
	rts

; ----------------------------------------------------------

bubbles_enterd:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderd
	lea			bubbles_fade,	a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		bubbles_step,	d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		bubbles_enterd_0
	move.l		#bubbles_loopd,bubbles_proc
	move.w		#850,			d0
bubbles_enterd_0:
	move.w		d0,bubbles_step
	rts

bubbles_loopd:
	bsr			pal_draw
	bsr			bubbles_renderd
	move.w		bubbles_step,	d0			; step
	subq.w		#1,				d0
	bne.s		bubbles_loopd_0
	move.l		#bubbles_leaved,bubbles_proc
	move.w		#256,			d0
bubbles_loopd_0:
	move.w		d0,bubbles_step
	rts

bubbles_leaved:
	move.w		bubbles_step,	d0
	lea			bubbles_fade,	a0
	bsr			pal_blend
	bsr			bubbles_renderd
	moveq		#60,			d0			; step
	lea			bubbles_fade,	a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		bubbles_step,	d0
	subq.w		#4,				d0
	bne.s		bubbles_leaved_0
	move.w		#1,bubbles_exit			; exit
bubbles_leaved_0:
	move.w		d0,bubbles_step
	rts

;-----------------------------------------------------------------------------

bubbles_rendera:
	lea			bubbles_curve,	a2
	lea			yoff_table,		a3
	lea			xoff8_table,	a4
	move.w		#$0203,			d3
	bsr			bubbles_tobe
	rts

bubbles_renderb:
	lea			bubbles_curve,	a2
	lea			yoff_table,		a3
	lea			xoff8_table,	a4
	move.w		#$0203,			d3
	bsr			bubbles_tobe
	bsr			bubbles_crem
	rts

bubbles_renderc:
	lea			bubbles_curve,	a2
	lea			yoff_table,		a3
	lea			xoff8_table,	a4
	move.w		#$0203,			d3
	bsr			bubbles_tobe
	bsr			bubbles_crem
	bsr			bubbles_floopy
	rts

bubbles_renderd:
	lea			bubbles_curve,	a2
	lea			yoff_table,		a3
	lea			xoff8_table,	a4
	move.w		#$0203,			d3
	bsr			bubbles_tobe
	bsr			bubbles_crem
	bsr			bubbles_floopy
	bsr			bubbles_gloky
	rts

;-----------------------------------------------------------------------------

bubbles_tobe:
	move.w		bubbles_crv_1,	d5
	move.w		0(a2,d5.w),		d6
	moveq		#12,			d0
	move.w		#240,			d1
	sub.w		d6,				d1
	cmpi.w		#bubbles_max,	d1
	ble.s		bubbles_tobe_0
	move.w		#bubbles_max,	d1
bubbles_tobe_0:
	move.w		#192,			d4
	lea			bubbles_disk1,	a0
	move.l		scr_back,		a1
	lea			-14472(a1),		a1
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		bubbles_pos_1,	d6
	move.w		d6,				d7
	add.w		d7,				d7
	adda.w		0(a4,d7.w),		a1
	move.w		d6,				d2
	andi.w		#$F,			d2
	bsr			bplan_zoom
	addq.w		#8,				d5
	cmpi.w		#720,			d5
	blt.s		bubbles_tobe_1
	subi.w		#720,			d5
bubbles_tobe_1:
	move.w		d5,bubbles_crv_1
	cmpi.w		#bubbles_max,	d1
	blt.s		bubbles_tobe_2
	add.w		bubbles_dir_1,	d6
	bra.s		bubbles_tobe_4
bubbles_tobe_2:
	cmpi.w		#128,			d6
	bge.s		bubbles_tobe_3
	move.w		#2,bubbles_dir_1
bubbles_tobe_3:
	cmpi.w		#288,			d6
	ble.s		bubbles_tobe_4
	move.w		#-2,bubbles_dir_1
bubbles_tobe_4:
	move.w		d6,bubbles_pos_1
	rts

;-----------------------------------------------------------------------------

bubbles_crem:
	move.w		bubbles_crv_2,	d5
	move.w		0(a2,d5.w),		d6
	moveq		#12,			d0
	move.w		#240,			d1
	sub.w		d6,				d1
	cmpi.w		#bubbles_max,	d1
	ble.s		bubbles_crem_0
	move.w		#bubbles_max,	d1
bubbles_crem_0:
	move.w		#192,			d4
	lea			bubbles_disk2,	a0
	move.l		scr_back,		a1
	lea			-14470(a1),		a1
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		bubbles_pos_2,	d6
	move.w		d6,				d7
	add.w		d7,				d7
	adda.w		0(a4,d7.w),		a1
	move.w		d6,				d2
	andi.w		#$F,			d2
	bsr			bplan_zoom
	addq.w		#8,				d5
	cmpi.w		#720,			d5
	blt.s		bubbles_crem_1
	subi.w		#720,			d5
bubbles_crem_1:
	move.w		d5,bubbles_crv_2
	cmpi.w		#bubbles_max,	d1
	blt.s		bubbles_crem_2
	add.w		bubbles_dir_2,	d6
	bra.s		bubbles_crem_4
bubbles_crem_2:
	cmpi.w		#128,			d6
	bge.s		bubbles_crem_3
	move.w		#2,bubbles_dir_2
bubbles_crem_3:
	cmpi.w		#288,			d6
	ble.s		bubbles_crem_4
	move.w		#-2,bubbles_dir_2
bubbles_crem_4:
	move.w		d6,bubbles_pos_2
	rts

;-----------------------------------------------------------------------------

bubbles_floopy:
	move.w		bubbles_crv_3,	d5
	move.w		0(a2,d5.w),		d6
	moveq		#12,			d0
	move.w		#240,			d1
	sub.w		d6,				d1
	cmpi.w		#bubbles_max,	d1
	ble.s		bubbles_floopy_0
	move.w		#bubbles_max,	d1
bubbles_floopy_0:
	move.w		#192,			d4
	lea			bubbles_disk4,	a0
	move.l		scr_back,		a1
	lea			-14468(a1),		a1
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		bubbles_pos_3,	d6
	move.w		d6,				d7
	add.w		d7,				d7
	adda.w		0(a4,d7.w),		a1
	move.w		d6,				d2
	andi.w		#$F,			d2
	bsr			bplan_zoom
	addq.w		#8,				d5
	cmpi.w		#720,			d5
	blt.s		bubbles_floopy_1
	subi.w		#720,			d5
bubbles_floopy_1:
	move.w		d5,bubbles_crv_3
	cmpi.w		#bubbles_max,	d1
	blt.s		bubbles_floopy_2
	add.w		bubbles_dir_3,	d6
	bra.s		bubbles_floopy_4
bubbles_floopy_2:
	cmpi.w		#128,			d6
	bge.s		bubbles_floopy_3
	move.w		#2,bubbles_dir_3
bubbles_floopy_3:
	cmpi.w		#288,			d6
	ble.s		bubbles_floopy_4
	move.w		#-2,bubbles_dir_3
bubbles_floopy_4:
	move.w		d6,bubbles_pos_3
	rts

;-----------------------------------------------------------------------------

bubbles_gloky:
	move.w		bubbles_crv_4,	d5
	move.w		0(a2,d5.w),		d6
	moveq		#12,			d0
	move.w		#240,			d1
	sub.w		d6,				d1
	cmpi.w		#bubbles_max,	d1
	ble.s		bubbles_gloky_0
	move.w		#bubbles_max,	d1
bubbles_gloky_0:
	move.w		#192,			d4
	lea			bubbles_disk3,	a0
	move.l		scr_back,		a1
	lea			-14466(a1),		a1
	lsl.w		#2,				d6
	adda.l		0(a3,d6.w),		a1
	move.w		bubbles_pos_4,	d6
	move.w		d6,				d7
	add.w		d7,				d7
	adda.w		0(a4,d7.w),		a1
	move.w		d6,				d2
	andi.w		#$F,			d2
	bsr			bplan_zoom
	addq.w		#8,				d5
	cmpi.w		#720,			d5
	blt.s		bubbles_gloky_1
	subi.w		#720,			d5
bubbles_gloky_1:
	move.w		d5,bubbles_crv_4
	cmpi.w		#bubbles_max,	d1
	blt.s		bubbles_gloky_2
	add.w		bubbles_dir_4,	d6
	bra.s		bubbles_gloky_4
bubbles_gloky_2:
	cmpi.w		#128,			d6			; 128
	bge.s		bubbles_gloky_3
	move.w		#2,bubbles_dir_4
bubbles_gloky_3:
	cmpi.w		#288,			d6			; 288
	ble.s		bubbles_gloky_4
	move.w		#-2,bubbles_dir_4
bubbles_gloky_4:
	move.w		d6,bubbles_pos_4
	rts


;=============================================================================
				SECTION DATA
;=============================================================================


bubbles_colors:	dc.w			 7,  6, 10
				dc.w			15, 13, 10
				dc.w			13, 10, 15
				dc.w			10, 14, 15
				dc.w			11, 15, 11

;bubbles_colors:	dc.w			 7,  6, 10
;				dc.w			15, 13, 10
;				dc.w			13, 10, 15
;				dc.w			10, 14, 15
;				dc.w			11, 15, 11


;=============================================================================
				SECTION BSS
;=============================================================================


bubbles_exit:	ds.w			1
bubbles_proc:	ds.l			1
bubbles_step:	ds.w			1
bubbles_fade:	ds.w			3

bubbles_crv_1:	ds.w			1
bubbles_crv_2:	ds.w			1
bubbles_crv_3:	ds.w			1
bubbles_crv_4:	ds.w			1

bubbles_pos_1:	ds.w			1
bubbles_pos_2:	ds.w			1
bubbles_pos_3:	ds.w			1
bubbles_pos_4:	ds.w			1

bubbles_dir_1:	ds.w			1
bubbles_dir_2:	ds.w			1
bubbles_dir_3:	ds.w			1
bubbles_dir_4:	ds.w			1

bubbles_inter:	ds.w			1

bubbles_curve:	ds.w			360			; 360 [y.w]

; 16  160 16 64      = 256 pixels
; +-+-----+-+--+
; +-+-----+-+--+  10 * 256	= 2560
; | |     | |  |
; | |     | |  | 256 * 256	= 65536 pixels
; | |     | |  |			= 68096 pixels
; +-+-----+-+--+			=  8512 bytes
bubbles_disk1:	ds.b			8512
bubbles_disk2:	ds.b			8512
bubbles_disk3:	ds.b			8512
bubbles_disk4:	ds.b			8512


;=============================================================================
;				END OF FILE
;=============================================================================

