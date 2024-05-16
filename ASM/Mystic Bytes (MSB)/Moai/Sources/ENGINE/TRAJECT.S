; C3D1
; dc.s speed
; dc.w steps
; dc.w points
; ds.w vertices (x)
; ds.w vertices (y)
; ds.w vertices (z)

TRAJ_COUNT	EQU	8
TRAJ_MAX_POINTS	EQU	100

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

traj_init:	lea	trajectory_pointers,a0
		lea	trajectory_param_pointers,a1
		move.w	#TRAJ_COUNT-1,d7

.loop:		move.w	d7,-(sp)
		
		movea.l	(a0)+,a2
		move.l	a0,-(sp)

		movea.l	(a2)+,a3			; command sequencer
		
		cmpi.l	#'C3D1',(a2)+
		beq.b	.ok
		move.l	#bad_m3d_text,error_adr
		bra.w	exit
		
.ok:		fmove.s	(a2)+,fp0			; interpolation step
		move.w	(a2)+,d1			; number of steps
		move.w	(a2)+,d0			; number of points
		movea.l	a2,a0				; control points
		
		movea.l	(a1)+,a2			; params buffer
		move.l	a1,-(sp)
		
		clr.w	(a2)+				; current step = 0;
		move.w	d1,(a2)+			; steps per segment
		clr.w	(a2)+				; current segment = 0
		move.w	d0,d2
		subq.w	#3,d2
		move.w	d2,(a2)+			; segments = points - 3
		clr.l	(a2)+				; tick counter = 0
		mulu.w	d1,d2				; steps per segment * segments
		move.l	d2,(a2)+			; ticks
		move.l	a3,(a2)+			; command sequencer
		movea.l	a2,a1				; delta buffer
		
		bsr.w	bspline_init
		
		movea.l	(sp)+,a1
		movea.l	(sp)+,a0
		move.w	(sp)+,d7
		
		dbra	d7,.loop
		rts

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

trajectory_pointers:
		dc.l	trajectory0
		dc.l	trajectory1
		dc.l	trajectory2
		dc.l	trajectory3
		dc.l	trajectory4
		dc.l	trajectory5
		dc.l	trajectory6
		dc.l	trajectory7

trajectory_param_pointers:
		dc.l	trajectory_params0
		dc.l	trajectory_params1
		dc.l	trajectory_params2
		dc.l	trajectory_params3
		dc.l	trajectory_params4
		dc.l	trajectory_params5
		dc.l	trajectory_params6
		dc.l	trajectory_params7
		
trajectory0:	dc.l	trajectory0_commands
		incbin	"trajects\kanon1.c3d"
trajectory1:	dc.l	trajectory1_commands
		incbin	"trajects\stlpy1.c3d"
trajectory2:	dc.l	trajectory2_commands
		incbin	"trajects\kostol1.c3d"
trajectory3:	dc.l	trajectory3_commands
		incbin	"trajects\kanon2.c3d"
trajectory4:	dc.l	trajectory4_commands
		incbin	"trajects\stlpy2.c3d"
trajectory5:	dc.l	trajectory5_commands
		incbin	"trajects\stlpy3.c3d"
trajectory6:	dc.l	trajectory6_commands
		incbin	"trajects\kanon3.c3d"
trajectory7:	dc.l	trajectory7_commands
		incbin	"trajects\kostol2.c3d"

		
; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

trajectory_current:
		ds.w	1

trajectory_params0:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params1:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params2:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params3:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params4:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params5:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params6:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]
trajectory_params7:
		ds.w	1				; current step
		ds.w	1				; steps per segment
		ds.w	1				; current segment
		ds.w	1				; segments
		ds.l	1				; tick counter
		ds.l	1				; total ticks
		ds.l	1				; command sequencer
		ds.l	(TRAJ_MAX_POINTS-3)*4*3		; segments * d[0-3]f[x y z]


; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

		include	"engine\commands.s"