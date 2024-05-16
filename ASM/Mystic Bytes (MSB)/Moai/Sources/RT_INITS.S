; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

; b-spline interpolation realtime inits
; sets d[0-3]f[xyz] paramters, checks segments, checks end of spline

rt_init0:	move.w	#0,trajectory_current
		bsr.w	rt_spline_init
		rts
		
rt_init1:	move.w	#1,trajectory_current
		bsr.w	rt_spline_init
		rts

rt_init2:	move.w	#2,trajectory_current
		bsr.w	rt_spline_init
		rts

rt_init3:	move.w	#3,trajectory_current
		bsr.w	rt_spline_init
		rts

rt_init4:	move.w	#4,trajectory_current
		bsr.w	rt_spline_init
		rts

rt_init5:	move.w	#5,trajectory_current
		bsr.w	rt_spline_init
		rts

rt_init6:	move.w	#6,trajectory_current
		bsr.w	rt_spline_init
		rts
		
rt_init7:	move.w	#7,trajectory_current
		bsr.w	rt_spline_init
		rts
		
rt_spline_init:	move.w	trajectory_current,d0
		movea.l	(trajectory_param_pointers.l,pc,d0.w*4),a0
		lea	bspline_deltas,a1

		move.w	4(a0),d2			; current segment
		adda.l	#20,a0				; skip shit
		mulu.w	#4*3*4,d2			; size of segment parameter
		adda.l	d2,a0
		
		moveq	#4*3-1,d7			; copy deltas
.copy_loop:	move.l	(a0)+,(a1)+			;
		dbra	d7,.copy_loop			;
		
		addi.l	#24,current_fx
		rts


; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
