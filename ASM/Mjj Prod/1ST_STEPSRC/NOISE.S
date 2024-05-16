;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; NOISE.S : noisy binary effect
;	need	TABLES.S
;			DRAW.S
;			RENDER.S
;=============================================================================


noise_count:	equ				10
noise_rect:		equ				(noise_count/2)-1


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; noise_init : initialise
;-----------------------------------------------------------------------------

noise_init:
	movem.l		d0-d7/a0-a6,	-(sp)

	lea			noise_hrect,	a0			; setup hrects
	lea			noise_hincr,	a1
	move.w		#$01FF,			d4
	move.w		#320,			d5
	move.w		#13,			d6
	moveq		#noise_count-1,	d7
noise_init_0:
	bsr			int_rnd
	and.w		d4,				d0
	cmp.w		d5,				d0
	blt.s		noise_init_1
	sub.w		d5,				d0
noise_init_1:
	move.w		d0,				(a0)+
	bsr			int_rnd
	asr.w		d6,				d0
	bne.s		noise_init_2
	addq.w		#1,				d0
noise_init_2:
	move.w		d0,				(a1)+
	dbra		d7,noise_init_0

	lea			noise_vrect,	a0			; setup vrects
	lea			noise_vincr,	a1
	move.w		#$00FF,			d4
	move.w		#200,			d5
	move.w		#14,			d6
	moveq		#noise_count-1,	d7
noise_init_3:
	bsr			int_rnd
	and.w		d4,				d0
	cmp.w		d5,				d0
	blt.s		noise_init_4
	sub.w		d5,				d0
noise_init_4:
	move.w		d0,				(a0)+
	bsr			int_rnd
	asr.w		d6,				d0
	bne.s		noise_init_5
	addq.w		#1,				d0
noise_init_5:
	move.w		d0,				(a1)+
	dbra		d7,noise_init_3
	
	lea			noise_dither,	a0
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	not.l		(a0)+
	bsr			noise_dither_on

	lea			noise_gfxs,		a0			; setup pal
	lea			split_pal,		a1
	lea			ste_colors,		a2
	moveq		#15,			d0
	moveq		#15,			d3
noise_init_6:
	move.w		(a0)+,			d1
	move.w		d1,				d2
	lsr.w		#8,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	move.w		d1,				d2
	lsr.w		#4,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	move.w		d1,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	dbra		d0,noise_init_6

	lea			noise_gfxs+32,	a0			; create masks
	lea			noise_headm,	a1
	move.w		#120,			d0
noise_init_7:
	move.l		480(a0),		d1
	or.l		(a0)+,			d1
	not.l		d1
	move.l		d1,				(a1)+
	dbra.w		d0,noise_init_7

	lea			noise_gfxs+992,	a0
	lea			noise_bodym,	a1
	moveq		#72,			d0
noise_init_8:
	move.l		288(a0),		d1
	or.l		(a0)+,			d1
	not.l		d1
	move.l		d1,				(a1)+
	dbra		d0,noise_init_8

	lea			sin_table,		a0			; head curve
	lea			noise_trans,	a1
	moveq		#12,			d2
	moveq		#89,			d0
noise_init_9:
	move.w		(a0),			d1
	addq.w		#8,				a0
	muls.w		#6,				d1
	asr.w		d2,				d1
	add.w		#10,			d1
	move.w		d1,				(a1)+
	dbra		d0,noise_init_9

	lea			noise_page1,	a0			; convert txt
	bsr			noise_conv
	lea			noise_page2,	a0
	bsr			noise_conv
	lea			noise_page3,	a0
	bsr			noise_conv

	lea			noise_fade,		a0			; setup enter fade
	move.w		#0,				d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)
	move.w		#0,noise_step

	move.l		#noise_enter,noise_proc

	move.w		#0,noise_pos_o
	move.w		#0,noise_exit
	movem.l		(sp)+,			d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; noise_fini : finalise
;-----------------------------------------------------------------------------

noise_fini:
	bsr			scr_white
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; noise_main : rendering
;-----------------------------------------------------------------------------

noise_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	bsr			pal_draw

	move.l		noise_proc,	a0			; render step
	jsr			(a0)
	bsr			noise_dither_rot

	move.w		noise_exit,	d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		noise_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
noise_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		noise_main_1
	moveq		#2,				d0			; quit
noise_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

;-----------------------------------------------------------------------------

noise_enter:
	move.w		noise_step,		d0
	lea			noise_fade,		a0
	bsr			pal_blend
	bsr			noise_render
	lea			noise_fade,	a0
	move.w		noise_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		noise_enter_0
	lea			noise_page1,	a0
	move.w		(a0)+,noise_txt_c
	move.l		a0,noise_txt_p
	move.w		#-1,noise_txt_x
	move.w		#0,noise_txt_y
	move.l		#noise_loopa,noise_proc
	move.w		#90,			d0
noise_enter_0:
	move.w		d0,noise_step
	rts

noise_loopa:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopa_0
	move.w		#0,noise_blt_o
	move.w		#0,noise_blt_1
	move.w		#0,noise_blt_2
	move.w		#200,noise_blt_3
	move.l		#noise_loopb,noise_proc
	move.w		#200,			d0
noise_loopa_0:
	move.w		d0,noise_step
	rts

noise_loopb:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtin
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopb_0
	move.l		#noise_loopc,noise_proc
	move.w		#200,			d0
noise_loopb_0:
	move.w		d0,noise_step
	rts

noise_loopc:
	bsr			pal_draw
	bsr			noise_render
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopc_0
	move.l		#noise_loopd,noise_proc
	move.w		#200,			d0
noise_loopc_0:
	move.w		d0,noise_step
	rts

noise_loopd:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtout
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopd_0
	lea			noise_page2,	a0
	move.w		(a0)+,noise_txt_c
	move.l		a0,noise_txt_p
	move.w		#-1,noise_txt_x
	move.w		#0,noise_txt_y
	move.l		#noise_loope,noise_proc
	move.w		#90,			d0
noise_loopd_0:
	move.w		d0,noise_step
	rts

noise_loope:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loope_0
	move.w		#0,noise_blt_o
	move.w		#0,noise_blt_1
	move.w		#0,noise_blt_2
	move.w		#200,noise_blt_3
	move.l		#noise_loopf,noise_proc
	move.w		#200,			d0
noise_loope_0:
	move.w		d0,noise_step
	rts

noise_loopf:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtin
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopf_0
	move.l		#noise_loopg,noise_proc
	move.w		#200,			d0
noise_loopf_0:
	move.w		d0,noise_step
	rts

noise_loopg:
	bsr			pal_draw
	bsr			noise_render
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopg_0
	move.l		#noise_looph,noise_proc
	move.w		#200,			d0
noise_loopg_0:
	move.w		d0,noise_step
	rts

noise_looph:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtout
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_looph_0
	lea			noise_page3,	a0
	move.w		(a0)+,noise_txt_c
	move.l		a0,noise_txt_p
	move.w		#-1,noise_txt_x
	move.w		#0,noise_txt_y
	move.l		#noise_loopi,noise_proc
	move.w		#90,			d0
noise_looph_0:
	move.w		d0,noise_step
	rts

noise_loopi:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	bsr			noise_print
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopi_0
	move.w		#0,noise_blt_o
	move.w		#0,noise_blt_1
	move.w		#0,noise_blt_2
	move.w		#200,noise_blt_3
	move.l		#noise_loopj,noise_proc
	move.w		#200,			d0
noise_loopi_0:
	move.w		d0,noise_step
	rts

noise_loopj:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtin
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopj_0
	move.l		#noise_loopk,noise_proc
	move.w		#200,			d0
noise_loopj_0:
	move.w		d0,noise_step
	rts

noise_loopk:
	bsr			pal_draw
	bsr			noise_render
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopk_0
	move.l		#noise_loopl,noise_proc
	move.w		#200,			d0
noise_loopk_0:
	move.w		d0,noise_step
	rts

noise_loopl:
	bsr			pal_draw
	bsr			noise_render
	bsr			noise_txtout
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopl_0
	move.l		#noise_loopm,noise_proc
	move.w		#100,			d0
noise_loopl_0:
	move.w		d0,noise_step
	rts

noise_loopm:
	bsr			pal_draw
	bsr			noise_render
	move.w		noise_step,		d0			; step
	subq.w		#1,				d0
	bne.s		noise_loopm_0
	move.l		#noise_leave,noise_proc
	move.w		#256,			d0
noise_loopm_0:
	move.w		d0,noise_step
	rts

noise_leave:
	move.w		noise_step,		d0
	lea			noise_fade,		a0
	bsr			pal_blend
	bsr			noise_render
	moveq		#60,			d0			; step
	lea			noise_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		noise_step,		d0
	subq.w		#4,				d0
	bne.s		noise_leave_0
	move.w		#1,noise_exit				; exit
noise_leave_0:
	move.w		d0,noise_step
	rts

;-----------------------------------------------------------------------------

noise_render:
	move.l		scr_back,		a0			; clear hrect
	moveq		#20,			d0
	move.w		#200,			d1
	move.w		#128,			d2
	bsr			bplan_clear8

	lea			noise_hrect,	a1			; compute hrect
	lea			noise_hincr,	a2
	lea			noise_line,		a3
	move.w		#320,			d6
	moveq		#noise_count-1,	d7
noise_render_0:
	move.w		(a1),			d0
	add.w		(a2),			d0
	bge.s		noise_render_1
	neg.w		(a2)
	move.w		(a1),			d0
noise_render_1:
	cmp.w		d6,				d0
	blt.s		noise_render_2
	neg.w		(a2)
	move.w		(a1),			d0
noise_render_2:
	addq.w		#2,				a2
	move.w		d0,				(a1)+
	move.w		d0,				(a3)+
	dbra		d7,noise_render_0

	bsr			noise_sort					; sort hrect

	moveq		#0,				d1			; draw hrect
	move.w		#200,			d3
	move.w		#288,			d4
	move.w		#$0103,			d5
	move.l		scr_back,		a0
	lea			noise_line,		a1
	moveq		#noise_rect,	d7
noise_render_3:
	move.w		(a1)+,			d0
	move.w		(a1)+,			d2
	cmp.w		d0,				d2
	beq.s		noise_render_4
	bsr			draw_rect
noise_render_4:
	dbra		d7,noise_render_3

	move.l		scr_back,		a0			; clear vrect
	addq.w		#2,				a0
	moveq		#20,			d0
	move.w		#200,			d1
	move.w		#128,			d2
	bsr			bplan_clear8

	lea			noise_vrect,	a1			; compute vrect
	lea			noise_vincr,	a2
	lea			noise_line,		a3
	move.w		#200,			d6
	moveq		#noise_count-1,	d7
noise_render_5:
	move.w		(a1),			d0
	add.w		(a2),			d0
	bge.s		noise_render_6
	neg.w		(a2)
	move.w		(a1),			d0
noise_render_6:
	cmp.w		d6,				d0
	blt.s		noise_render_7
	neg.w		(a2)
	move.w		(a1),			d0
noise_render_7:
	addq.w		#2,				a2
	move.w		d0,				(a1)+
	move.w		d0,				(a3)+
	dbra		d7,noise_render_5

	bsr			noise_sort					; sort vrect

	moveq		#0,				d0			; draw vrect
	move.w		#320,			d2
	move.w		#288,			d4
	move.w		#$0103,			d5
	move.l		scr_back,		a0
	addq.w		#2,				a0
	lea			noise_line,		a1
	moveq		#noise_rect,	d7
noise_render_8:
	move.w		(a1)+,			d1
	move.w		(a1)+,			d3
	cmp.w		d1,				d3
	beq.s		noise_render_9
	bsr			draw_rect
noise_render_9:
	dbra		d7,noise_render_8
	
	move.l		scr_back,		a0			; clear body
	adda.l		#34396,			a0
	moveq		#5,				d0
	move.w		#60,			d1
	move.w		#248,			d2
	bsr			bplan_clear8
	addq.w		#2,				a0
	bsr			bplan_clear8

	lea			noise_bodym,	a0			; draw body
	move.l		scr_back,		a1
	adda.l		#47360,			a1
	moveq		#4,				d0
	moveq		#36,			d1
	moveq		#0,				d2
	move.w		#$0201,			d3
	move.w		#256,			d4
	bsr			bplan_blit
	addq.w		#2,				a1
	bsr			bplan_blit
	lea			noise_gfxs+992,	a0
	addq.w		#2,				a1
	move.w		#$0207,			d3
	bsr			bplan_blit
	lea			288(a0),		a0
	addq.w		#2,				a1
	bsr			bplan_blit

	lea			noise_trans,	a2			; draw head
	move.w		noise_pos_o,	d5
	lea			noise_headm+360,a0
	move.l		scr_back,		a1
	adda.l		#47356,			a1
	moveq		#4,				d0
	moveq		#15,			d1
	move.w		0(a2,d5.w),		d2
	move.w		#$0201,			d3
	move.w		#256,			d4
	bsr			bplan_blit
	addq.w		#2,				a1
	bsr			bplan_blit
	lea			noise_headm,	a0
	move.l		scr_back,		a1
	adda.l		#34392,			a1
	moveq		#4,				d0
	moveq		#60,			d1
	move.w		#$0201,			d3
	move.w		#256,			d4
	bsr			bplan_blit
	addq.w		#2,				a1
	bsr			bplan_blit
	lea			noise_gfxs+32,	a0
	addq.w		#2,				a1
	move.w		#$0207,			d3
	bsr			bplan_blit
	lea			480(a0),		a0
	addq.w		#2,				a1
	bsr			bplan_blit

	addq.w		#8,				d5
	cmpi.w		#180,			d5
	blt.s		noise_render_a
	subi.w		#180,			d5
noise_render_a:
	move.w		d5,noise_pos_o
	rts

noise_txtin:
	moveq		#15,			d0
	move.w		noise_blt_1,	d1
	move.w		noise_blt_2,	d2
	move.w		noise_blt_3,	d3
	move.w		#168,			d4
	lea			noise_text,		a0
	move.w		noise_blt_o,	d5
	adda.w		d5,				a0
	move.l		scr_back,		a1
	addq.w		#4,				a1
	bsr			bplan_stretch
	tst.w		d3
	beq.s		noise_txtin_0
	addq.w		#1,				d2
	subq.w		#1,				d3
	move.w		d1,noise_blt_1
	move.w		d2,noise_blt_2
	move.w		d3,noise_blt_3
	move.w		d5,noise_blt_o
noise_txtin_0:
	rts

noise_txtout:
	moveq		#15,			d0
	move.w		noise_blt_1,	d1
	move.w		noise_blt_2,	d2
	move.w		noise_blt_3,	d3
	move.w		#168,			d4
	lea			noise_text,		a0
	move.w		noise_blt_o,	d5
	adda.w		d5,				a0
	move.l		scr_back,		a1
	addq.w		#4,				a1
	bsr			bplan_stretch
	tst.w		d2
	beq.s		noise_txtout_0
	addq.w		#1,				d1
	subq.w		#1,				d2
	addi.w		#30,			d5
	move.w		d1,noise_blt_1
	move.w		d2,noise_blt_2
	move.w		d3,noise_blt_3
	move.w		d5,noise_blt_o
noise_txtout_0:
	rts

noise_sort:
	lea			noise_line,		a0
	moveq		#0,				d2
	moveq		#noise_count-2,	d7
noise_sort_0:
	move.w		(a0),			d0
	move.w		2(a0),			d1
	cmp.w		d0,				d1
	bge.s		noise_sort_1
	move.w		d1,				(a0)
	move.w		d0,				2(a0)
	moveq		#1,				d2
noise_sort_1:
	addq.w		#2,				a0
	dbra		d7,noise_sort_0
	tst.w		d2
	bne.s		noise_sort
	rts


noise_dither_on:
	move.l		a0,				-(sp)
	move.l		a1,				-(sp)
	lea			noise_dither,	a0
	lea			$FFFF8A00.W,	a1
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(a0)+,			(a1)+
	move.l		(sp)+,			a1
	move.l		(sp)+,			a0
	rts

noise_dither_rot:
	move.l		a0,				-(sp)
	lea			$FFFF8A00.W,	a0
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	rol.w		(a0)+
	move.l		(sp)+,			a0
	rts


noise_print:
	move.w		noise_txt_c,	d7
	bne.s		noise_print_0
	moveq		#0,				d0
	rts
noise_print_0:
	subq.w		#1,				d7
	move.w		d7,noise_txt_c
	move.l		noise_txt_p,	a0
	move.b		(a0)+,			d7
	move.l		a0,noise_txt_p
	ext.w		d7
	move.w		noise_txt_x,	d6
	bge.s		noise_print_1
	moveq		#15,			d0
	move.w		d7,				d1
	move.w		#0,				d2
	lea			noise_text,		a0
	move.w		noise_txt_y,	d5
	move.w		d5,				d6
	mulu.w		#30,			d6
	adda.w		d6,				a0
	bsr			bplan_clear2
	add.w		d7,				d5
	move.w		d5,noise_txt_y
	move.w		#0,noise_txt_x
	moveq		#1,				d0
	rts
noise_print_1:
	moveq		#1,				d0
	moveq		#20,			d1
	move.w		#28,			d2
	lea			noise_gfxs,		a0
	lea			1568(a0),		a0
	mulu.w		#40,			d7
	adda.w		d7,				a0
	lea			noise_text,		a1
	move.w		noise_txt_y,	d5
	move.w		d5,				d7
	mulu.w		#30,			d7
	adda.w		d7,				a1
	adda.w		d6,				a1
	bsr			bplan_copy
	addq.w		#2,				d6
	cmpi.w		#30,			d6
	bne.s		noise_print_2
	addi.w		#20,			d5
	moveq		#-1,			d6
noise_print_2:
	move.w		d5,noise_txt_y
	move.w		d6,noise_txt_x
	moveq		#1,				d0
	rts

noise_conv:
	lea			noise_table,	a1
	move.w		(a0)+,			d0
	subq.w		#1,				d0
	clr.w		d1
noise_conv_0:
	move.b		(a0),			d1
	cmpi.w		#32,			d1
	blt.s		noise_conv_1
	move.b		0(a1,d1.w),		(a0)
noise_conv_1:
	addq.w		#1,				a0
	dbra		d0,noise_conv_0
	rts


;=============================================================================
				SECTION DATA
;=============================================================================


noise_dither:	dc.w			$3333, $5555, $6666, $0000
				dc.w			$3232, $5656, $6262, $0000
				dc.w			$2323, $6565, $2626, $0000
				dc.w			$2222, $6666, $2222, $0000

noise_table:	dcb.b			40, 40				; [0-39]
				dc.b			38, 39				; ()
				dcb.b			3, 40				; [42-44]
				dc.b			36, 40, 40			; - [46,47]
				dc.b			26, 27, 28, 29, 30	; 01234
				dc.b			31, 32, 33, 34, 35	; 56789
				dc.b			37					; :
				dcb.b			6, 40				; [59-64]
				dc.b			0, 1, 2, 3, 4		; abcde
				dc.b			5, 6, 7, 8, 9		; fghij
				dc.b			10, 11, 12, 13, 14	; klmno
				dc.b			15, 16, 17, 18, 19	; pqrst
				dc.b			20, 21, 22, 23, 24	; uvwxy
				dc.b			25					; z
				dcb.b			37, 40				; [91-127]
				EVEN

noise_page1:	dc.w			129
				dc.b			4					;  1
				dc.b			"CODE:          "	; 15
				dc.b			2					;  1
				dc.b			"           TOBE"	; 15
				dc.b			8					;  1
				dc.b			"GRAPHS:        "	; 15
				dc.b			2					;  1
				dc.b			"          C-REM"	; 15
				dc.b			8					;  1
				dc.b			"MUSIC:         "	; 15
				dc.b			2					;  1
				dc.b			"         FLOOPY"	; 15
				dc.b			8					;  1
				dc.b			"512 DOTS:      "	; 15
				dc.b			2					;  1
				dc.b			"          GLOKY"	; 15
				dc.b			4					;  1
				EVEN

noise_page2:	dc.w			145
				dc.b			4					;  1
				dc.b			"MJJ PROD:      "	; 15
				dc.b			5					;  1
				dc.b			"BIGFOOT   C-REM"	; 15
				dc.b			1					;  1
				dc.b			"FELX     FLOOPY"	; 15
				dc.b			1					;  1
				dc.b			"GLOKY GOLDENBOY"	; 15
				dc.b			1					;  1
				dc.b			"HERRV   KIKSOFT"	; 15
				dc.b			1					;  1
				dc.b			"MIKOU  MR-NOURS"	; 15
				dc.b			1					;  1
				dc.b			"SHAZZ    SQUALE"	; 15
				dc.b			1					;  1
				dc.b			"STRIDER    TOBE"	; 15
				dc.b			1					;  1
				dc.b			"TOOSEB WILFRIED"	; 15
				dc.b			4					;  1
				EVEN

noise_page3:	dc.w			145
				dc.b			4
				dc.b			"GREETINGS:     "
				dc.b			5
				dc.b			" CAMILLE ATARI "
				dc.b			1
				dc.b			"TOUFOU    (MJJ)"
				dc.b			1
				dc.b			"5O5  CHECKPOINT"
				dc.b			1
				dc.b			"COOPER PARADIZE"
				dc.b			1
				dc.b			"GIZMO       DHS"
				dc.b			1
				dc.b			"BRUME        AL"
				dc.b			1
				dc.b			"KEOPS   EQUINOX"
				dc.b			1
				dc.b			"GT-TURBO     CV"
				dc.b			4
				EVEN


;=============================================================================
				SECTION BSS
;=============================================================================


noise_pos_o:	ds.w			1

noise_txt_c:	ds.w			1
noise_txt_p:	ds.l			1
noise_txt_x:	ds.w			1
noise_txt_y:	ds.w			1

noise_blt_o:	ds.w			1
noise_blt_1:	ds.w			1
noise_blt_2:	ds.w			1
noise_blt_3:	ds.w			1

noise_exit:		ds.w			1
noise_proc:		ds.l			1
noise_step:		ds.w			1
noise_fade:		ds.w			3

noise_hrect:	ds.w			noise_count
noise_vrect:	ds.w			noise_count
noise_hincr:	ds.w			noise_count
noise_vincr:	ds.w			noise_count

noise_line:		ds.w			noise_count

noise_trans:	ds.w			90

noise_headm:	ds.b			480
noise_bodym:	ds.b			288

;  240
; +---+
; |   | 200
; +---+
noise_text:		ds.b			6000

;=============================================================================
;				END OF FILE
;=============================================================================

