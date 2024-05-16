;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; GLOKY.S : gloky style effect
;	need	RENDER.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================

;-----------------------------------------------------------------------------
; style_init : initialise
;-----------------------------------------------------------------------------

style_init:
	movem.l		d0-d7/a0-a6,	-(sp)
	lea			gloky_graph,	a0			; setup pal
	addq.l		#2,				a0
	lea			split_pal,		a1
	lea			ste_colors,		a2
	moveq		#15,			d0
	moveq		#15,			d3
style_init_0:
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
	dbra		d0,style_init_0

	lea			gloky_graph,	a0			; setup screens
	lea			34(a0),			a0
	move.l		scr_back,		a1
	move.l		scr_front,		a2
	move.w		#199,			d0
style_init_1:
	moveq		#39,			d1
style_init_2:
	move.l		(a0),			(a1)+
	move.l		(a0)+,			(a2)+
	dbra		d1,style_init_2
	lea			128(a1),		a1
	lea			128(a2),		a2
	dbra		d0,style_init_1

	moveq		#0,				d0			; setup 1st frame
	move.w		d0,style_exit
	move.w		d0,style_step				; setup enter fade
	lea			style_fade,		a0
	move.w		#3840,			d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	
	lea			style_enter,	a0				; setup enter proc
	move.l		a0,style_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts



;-----------------------------------------------------------------------------
; style_fini : finalise
;-----------------------------------------------------------------------------

style_fini:
	bsr			scr_black
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; style_main : rendering
;-----------------------------------------------------------------------------

style_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	move.l		style_proc,		a0			; render step
	jsr			(a0)
	move.w		style_exit,		d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		style_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
style_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		style_main_1
	moveq		#2,				d0			; quit
style_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

style_enter:
	move.w		style_step,		d0
	lea			style_fade,		a0
	bsr			pal_blend
	moveq		#120,			d0
	lea			style_fade,		a0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	move.w		style_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		style_enter_0
	lea			style_loop,		a0			; setup next step
	move.l		a0,style_proc
	move.w		#670,			d0
style_enter_0:
	move.w		d0,style_step
	rts

style_loop:
	bsr			pal_draw
	move.w		style_step,		d0			; step
	subq.w		#1,				d0
	bne.s		style_loop_0
	lea			style_leave,	a0			; setup next step
	move.l		a0,style_proc
	moveq		#0,				d0
	lea			style_fade,		a0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		#256,			d0
style_loop_0:
	move.w		d0,style_step
	rts

style_leave:
	move.w		style_step,		d0
	lea			style_fade,		a0
	bsr			pal_blend
	move.w		style_step,		d0			; step
	subq.w		#8,				d0
	bne.s		style_leave_0
	moveq		#1,				d1			; exit
	move.w		d1,style_exit
style_leave_0:
	move.w		d0,style_step
	rts


;=============================================================================
				SECTION BSS
;=============================================================================


style_exit:		ds.w			1
style_proc:		ds.l			1
style_step:		ds.w			1
style_fade:		ds.w			3


;=============================================================================
;				END OF FILE
;=============================================================================

