;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; EXIT.S : exit effect
;	need	RENDER.S
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================

;-----------------------------------------------------------------------------
; exit_init : initialise
;-----------------------------------------------------------------------------

exit_init:
	movem.l		d0-d7/a0-a6,	-(sp)
	lea			dhs_graph,		a0			; setup pal
	addq.l		#2,				a0
	lea			split_pal,		a1
	lea			ste_colors,		a2
	moveq		#15,			d0
	moveq		#15,			d3
exit_init_0:
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
	dbra		d0,exit_init_0

	lea			dhs_graph,		a0			; setup screens
	lea			34(a0),			a0
	move.l		scr_back,		a1
	move.l		scr_front,		a2
	move.w		#199,			d0
exit_init_1:
	moveq		#39,			d1
exit_init_2:
	move.l		(a0),			(a1)+
	move.l		(a0)+,			(a2)+
	dbra		d1,exit_init_2
	lea			128(a1),		a1
	lea			128(a2),		a2
	dbra		d0,exit_init_1

	moveq		#0,				d0			; setup 1st frame
	move.w		d0,exit_exit
	move.w		d0,exit_step				; setup enter fade
	lea			exit_fade,		a0
	move.w		#3840,			d0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)
	
	lea			exit_enter,	a0				; setup enter proc
	move.l		a0,exit_proc

	movem.l		(sp)+,			d0-d7/a0-a6
	rts



;-----------------------------------------------------------------------------
; exit_fini : finalise
;-----------------------------------------------------------------------------

exit_fini:
	bsr			scr_black
	bsr			scr_clear					; clear
	bsr			scr_swap
	bsr			scr_clear
	rts

;-----------------------------------------------------------------------------
; exit_main : rendering
;-----------------------------------------------------------------------------

exit_main:
	movem.l		d1-d7/a0-a6,	-(sp)
	bsr			scr_swap
	bsr			scr_show
	bsr			sys_vsync
	move.l		exit_proc,		a0			; render step
	jsr			(a0)
	move.w		exit_exit,		d0			; test exit
	cmp.b		#57,			$FFFFFC02.W
	bne.s		exit_main_0
	bsr			demo_space
	moveq		#1,				d0			; exit
exit_main_0:
	cmp.b		#129,			$FFFFFC02.W
	bne.s		exit_main_1
	moveq		#2,				d0			; quit
exit_main_1:
	movem.l		(sp)+,			d1-d7/a0-a6
	rts

exit_enter:
	move.w		exit_step,		d0
	lea			exit_fade,		a0
	bsr			pal_blend
	lea			exit_fade,	a0
	moveq		#120,			d0
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)+
	sub.w		d0,				(a0)
	move.w		exit_step,		d0			; step
	addq.w		#8,				d0
	cmpi.w		#256,			d0
	bne.s		exit_enter_0
	lea			exit_loop,		a0			; setup next step
	move.l		a0,exit_proc
	move.w		#1400,			d0
exit_enter_0:
	move.w		d0,exit_step
	rts

exit_loop:
	bsr			pal_draw
	move.w		exit_step,		d0			; step
	subq.w		#1,				d0
	bne.s		exit_loop_0
	lea			exit_leave,		a0			; setup next step
	move.l		a0,exit_proc
	moveq		#0,				d0
	lea			exit_fade,		a0
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		d0,				(a0)+
	move.w		#256,			d0
exit_loop_0:
	move.w		d0,exit_step
	rts

exit_leave:
	move.w		exit_step,		d0
	lea			exit_fade,		a0
	bsr			pal_blend
;	moveq		#60,			d0			; step
;	lea			exit_fade,		a0
;	add.w		d0,				(a0)+
;	add.w		d0,				(a0)+
;	add.w		d0,				(a0)
	move.w		exit_step,		d0			; step
	subq.w		#4,				d0
	bne.s		exit_leave_0
	moveq		#1,				d1			; exit
	move.w		d1,exit_exit
exit_leave_0:
	move.w		d0,exit_step
	rts


;=============================================================================
				SECTION BSS
;=============================================================================


exit_exit:		ds.w			1
exit_proc:		ds.l			1
exit_step:		ds.w			1
exit_fade:		ds.w			3


;=============================================================================
;				END OF FILE
;=============================================================================

