;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; GLOKY.S : gloky mjj effect
;	need	RENDER.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================

;-----------------------------------------------------------------------------
; mjj_init : initialise
;-----------------------------------------------------------------------------

mjj_init:
	movem.l		d0-d7/a0-a6,	-(sp)
	lea			mjj_graph,		a0			; setup pal
	addq.l		#2,				a0
	lea			split_pal,		a1
	lea			ste_colors,		a2
	moveq		#15,			d0
	moveq		#15,			d3
mjj_init_0:
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
	dbra		d0,mjj_init_0

	lea			mjj_graph,		a0			; setup screens
	lea			34(a0),			a0
	move.l		scr_back,		a1
	move.l		scr_front,		a2
	move.w		#199,			d0
mjj_init_1:
	moveq		#39,			d1
mjj_init_2:
	move.l		(a0),			(a1)+
	move.l		(a0)+,			(a2)+
	dbra		d1,mjj_init_2
	lea			128(a1),		a1
	lea			128(a2),		a2
	dbra		d0,mjj_init_1

	moveq		#0,				d0			; setup 1st frame
	move.w		d0,mjj_exit
	move.w		d0,mjj_step					; setup enter fade
	lea			mjj_fade,		a0
	move.w		#3840,			d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	
	lea			mjj_enter,		a0			; setup enter proc
	move.l		a0,mjj_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts



;-----------------------------------------------------------------------------
; mjj_fini : finalise
;-----------------------------------------------------------------------------

mjj_fini:
	bsr			scr_white
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; mjj_main : rendering
;-----------------------------------------------------------------------------

mjj_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	move.l		mjj_proc,		a0			; render step
	jsr			(a0)
	move.w		mjj_exit,		d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		mjj_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
mjj_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		mjj_main_1
	moveq		#2,				d0			; quit
mjj_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

mjj_enter:
	move.w		mjj_step,		d0
	lea			mjj_fade,		a0
	bsr			pal_blend
	moveq		#120,			d0
	lea			mjj_fade,		a0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	move.w		mjj_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		mjj_enter_0
	lea			mjj_loop,		a0			; setup next step
	move.l		a0,mjj_proc
	move.w		#600,			d0
mjj_enter_0:
	move.w		d0,mjj_step
	rts

mjj_loop:
	bsr			pal_draw
	move.w		mjj_step,		d0			; step
	subq.w		#1,				d0
	bne.s		mjj_loop_0
	lea			mjj_leave,		a0			; setup next step
	move.l		a0,mjj_proc
	moveq		#0,				d0
	lea			mjj_fade,		a0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		#256,			d0
mjj_loop_0:
	move.w		d0,mjj_step
	rts

mjj_leave:
	move.w		mjj_step,		d0
	lea			mjj_fade,		a0
	bsr			pal_blend
	moveq		#120,			d0			; step
	lea			mjj_fade,		a0
	add.w		d0,				(a0)+
	add.w		d0,				(a0)+
	add.w		d0,				(a0)
	move.w		mjj_step,		d0			; step
	subq.w		#8,				d0
	bne.s		mjj_leave_0
	moveq		#1,				d1			; exit
	move.w		d1,mjj_exit
mjj_leave_0:
	move.w		d0,mjj_step
	rts


;=============================================================================
				SECTION BSS
;=============================================================================


mjj_exit:		ds.w			1
mjj_proc:		ds.l			1
mjj_step:		ds.w			1
mjj_fade:		ds.w			3


;=============================================================================
;				END OF FILE
;=============================================================================

