; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

; 0 <= t <= 1
;
; p[i] = [T]*[C] = [T]*[M]*[G]
;
; [T] = [ t^3 t^2 t^1 t^0 ]
;
; B-Spline
; ========
;
; [M] = 1/6 * [ -1  3 -3  1 ]
;             [  3 -6  3  0 ]
;             [ -3  0  3  0 ]
;             [  1  4  1  0 ]
;
; [G] = [ p0 ]
;       [ p1 ]
;       [ p2 ]
;       [ p3 ]

; b-spline interpolation init
; input: d0.w: number of points
;        d1.w: number of interpolation steps (1/step)
;        fp0:  interpolation step
;        a0:   src buffer of control points (all x, all y, all z)
;        a1:   dst buffer for b-spline interpolation deltas

bspline_init:	fmove.s	fp0,bspline_dt1			; (dt)^1

		fmove.x	fp0,fp1
		fmul.x	fp1,fp1				; (dt)^2
		fmove.s	fp1,bspline_dt2

		fmul.x	fp0,fp1				; (dt)^3
		fmove.s	fp1,bspline_dt3

		move.w	d0,bspline_points
		subq.w	#3,d0				; n-3
		move.w	d0,bspline_segments
		move.w	d1,bspline_steps
		move.l	a0,bspline_control_points
		move.l	a1,bspline_delta_buffer

		movea.l	bspline_control_points,a0
		lea	bspline_base_matrix,a1
		movea.l	bspline_delta_buffer,a6
		move.w	bspline_points,d2
		move.w	bspline_segments,d7
		subq.w	#1,d7

.seg_loop:	lea	bspline_matrix,a2
		movea.l	a0,a3				; control points
		moveq	#3-1,d6				; [x y z]

.col_loop:	movea.l	a1,a4				; base matrix
		moveq	#4-1,d5				; 4 rows

.row_loop:	movea.l	a3,a5				; control points

		move.w	(a4)+,d0
		muls.w	(a5)+,d0
		move.w	(a4)+,d1
		muls.w	(a5)+,d1
		add.l	d1,d0
		move.w	(a4)+,d1
		muls.w	(a5)+,d1
		add.l	d1,d0
		move.w	(a4)+,d1
		muls.w	(a5)+,d1
		add.l	d1,d0
		move.w	d0,(a2)+

		dbra	d5,.row_loop
		lea	(a3,d2.w*2),a3			; move to the next column

		dbra	d6,.col_loop
		addq.l	#2,a0				; i++

		lea	bspline_matrix,a2
		moveq	#3-1,d6				; [x y z]

; f(t) = 1/6 * ( a * t^3 + b * t^2 + c * t^1 + d * t^0 )
; [d^0]f(0) = f(0) = d / 6
; [d^1]f(0) = c * dt / 6
; [d^2]f(0) = 2 * b * dt^2 / 6
; [d^3]f(0) = 6 * a * dt^3 / 6

.delta_loop:	fmove.w	(a2)+,fp0			; a
		fmove.w	(a2)+,fp1			; b
		fmove.w	(a2)+,fp2			; c
		fmove.w	(a2)+,fp3			; d

		fdiv.w	#6,fp3				; d / 6
		fmove.s	fp3,(a6)+			; [d^0]f(0)

		fmul.s	bspline_dt1,fp2			; c * dt^1 / 6
		fdiv.w	#6,fp2				;
		fmove.s	fp2,(a6)+			; [d^1]f(0)

		fmul.s	bspline_dt2,fp1			; 2 * b * dt^2 / 6 = b * dt^2 / 3
		fdiv.w	#3,fp1				;
		fmove.s	fp1,(a6)+			; [d^2]f(0)

		fmul.s	bspline_dt3,fp0			; 6 * a * dt^3 / 6 = a * dt^3
		fmove.s	fp0,(a6)+			; [d^3]f(0)

		dbra	d6,.delta_loop

		dbra	d7,.seg_loop
		rts

; b-spline interpolation using forward differencing

bspline_timer:	fmove.s	bspline_d0fx,fp0
		fmove.s	bspline_d0fy,fp1
		fmove.s	bspline_d0fz,fp2

		fmove.x	fp0,fp3
		fintrz.x	fp3
		fmove.w	fp3,d0				; x

		fmove.x	fp1,fp3
		fintrz.x	fp3
		fmove.w	fp3,d1				; y

		fmove.x	fp2,fp3
		fintrz.x	fp3
		fmove.w	fp3,d2				; z

		; DO STUFF HERE
		move.w	d0,cam_pos_x
		move.w	d1,cam_pos_y
		move.w	d2,cam_pos_z

		fmove.s	bspline_d1fx,fp3
		fmove.s	bspline_d1fy,fp4
		fmove.s	bspline_d1fz,fp5

		fadd.x	fp3,fp0				; fx += [d^1]fx
		fadd.x	fp4,fp1				; fy += [d^1]fy
		fadd.x	fp5,fp2				; fz += [d^1]fz

		fmove.s	fp0,bspline_d0fx
		fmove.s	fp1,bspline_d0fy
		fmove.s	fp2,bspline_d0fz

		fmove.s	bspline_d2fx,fp0
		fmove.s	bspline_d2fy,fp1
		fmove.s	bspline_d2fz,fp2

		fadd.x	fp0,fp3				; [d^1]fx += [d^2]fx
		fadd.x	fp1,fp4				; [d^1]fy += [d^2]fy
		fadd.x	fp2,fp5				; [d^1]fz += [d^2]fz

		fmove.s	fp3,bspline_d1fx
		fmove.s	fp4,bspline_d1fy
		fmove.s	fp5,bspline_d1fz

		fadd.s	bspline_d3fx,fp0		; [d^2]fx += [d^3]fx
		fadd.s	bspline_d3fy,fp1		; [d^2]fy += [d^3]fy
		fadd.s	bspline_d3fz,fp2		; [d^2]fz += [d^3]fz

		fmove.s	fp0,bspline_d2fx
		fmove.s	fp1,bspline_d2fy
		fmove.s	fp2,bspline_d2fz

		move.w	trajectory_current,d0
		movea.l	(trajectory_param_pointers.l,pc,d0.w*4),a0
		move.w	(a0),d0				; current step
		move.w	2(a0),d1			; steps per segment
		move.w	4(a0),d2			; current segment
		move.w	6(a0),d3			; segments

		addq.w	#1,d0
		cmp.w	d0,d1
		bne.b	.steps_ok
		clr.w	d0
		addq.w	#1,d2				; segment++
		cmp.w	d3,d2
		bne.b	.segments_ok
		clr.w	d2
		
.segments_ok:	move.w	d0,(a0)
		move.w	d2,4(a0)

		lea	bspline_deltas,a1

		adda.l	#20,a0				; skip shit
		mulu.w	#4*3*4,d2			; size of segment parameter
		adda.l	d2,a0

		moveq	#4*3-1,d7			; copy deltas
.copy_loop:	move.l	(a0)+,(a1)+			;
		dbra	d7,.copy_loop			;
		rts

.steps_ok:	move.w	d0,(a0)
		move.w	d2,4(a0)
		rts

; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

bspline_base_matrix:
		dc.w	-1,+3,-3,+1
		dc.w	+3,-6,+3,+0
		dc.w	-3,+0,+3,+0
		dc.w	+1,+4,+1,+0

; ------------------------------------------------------
		SECTION	BSS
; ------------------------------------------------------

bspline_points:	ds.w	1
bspline_segments:
		ds.w	1
bspline_steps:
		ds.w	1
bspline_control_points:
		ds.l	1
bspline_delta_buffer:
		ds.l	1

; spline matrix is:
; [ ax ay az ]
; [ bx by bz ]
; [ cx cy cz ]
; [ dx dy dz ]
; but stored as: ax, bx, cx, dx, ay, by, cy, dy, az, bz, cz, dz

bspline_matrix:	ds.w	4*3				; 4 rows * [x y z]

bspline_dt1:	ds.l	1
bspline_dt2:	ds.l	1
bspline_dt3:	ds.l	1

bspline_deltas:

bspline_d0fx:	ds.l	1
bspline_d1fx:	ds.l	1
bspline_d2fx:	ds.l	1
bspline_d3fx:	ds.l	1

bspline_d0fy:	ds.l	1
bspline_d1fy:	ds.l	1
bspline_d2fy:	ds.l	1
bspline_d3fy:	ds.l	1

bspline_d0fz:	ds.l	1
bspline_d1fz:	ds.l	1
bspline_d2fz:	ds.l	1
bspline_d3fz:	ds.l	1

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------
