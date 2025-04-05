


stars_xx_:	equ	0+0
stars_xy_:	equ	0+2
stars_xz_:	equ	0+4
stars_yx_:	equ	6+0
stars_yy_:	equ	6+2
stars_yz_:	equ	6+4
stars_zx_:	equ	12+0
stars_zy_:	equ	12+2
stars_zz_:	equ	12+4

stars_x0_:	equ	0
stars_y0_:	equ	2
stars_z0_:	equ	4


		section	text

stars_rotate:
; a0	address to coords
; d0.w	number of verts
		move.l	a0,.coords
		move.w	d0,.num
		
		lea	stars_matrix,a0
		move.w	stars_anx,d0				;x-angle
		move.w	stars_any,d1				;y-angle
		move.w	stars_anz,d2				;z-angle
		bsr 	stars_matrix_rotate			;rotate it

		move.l	.coords,a0
		move.l	stars_rotcadr1,a1			;rotcoords
		lea	stars_matrix,a2
		move.w	.num,d7
		bsr	stars_transform_mul
		rts
.coords:	dc.l	0
.num:		dc.w	0

stars_transform_mul:
; a0	address to coords
; a1	address to rotated coords
; a2	adderss to matrix
; d7.w	number of verts
		subq.w	#1,d7

		move.l	stars_project_const,a3
.trans:		movem.w	(a0)+,d4-d6

		move.w	d4,d0		; x
		muls	stars_xx_(a2),d0
		move.w	d5,d1		; y
		muls	stars_xy_(a2),d1
		add.l	d1,d0
		move.w	d6,d1		; z
		muls	stars_xz_(a2),d1
		add.l	d1,d0		; X1

		move.w	d4,d1		; x
		muls	stars_yx_(a2),d1
		move.w	d5,d2		; y
		muls	stars_yy_(a2),d2
		add.l	d2,d1
		move.w	d6,d2		; z
		muls	stars_yz_(a2),d2
		add.l	d2,d1

		muls	stars_zx_(a2),d4
		muls	stars_zy_(a2),d5
		add.l	d5,d4
		muls	stars_zz_(a2),d6
		add.l	d6,d4

		asr.l	#8,d4
		asr.l	#8,d4
		asr.l	#8,d0
		asr.l	#8,d1

		asr.l	#1,d0
		asr.l	#1,d1

		add.l	a3,d4

		divs	d4,d0
		divs	d4,d1
	
		movem.w	d0/d1/d4,(a1)
		addq.l	#6,a1
		move.w	(a0)+,(a1)+	;sprite size

		dbra    d7,.trans
		rts



;========================================================================================
;matrix
stars_m00:	equ	0
stars_m01:	equ	2
stars_m02:	equ	4
stars_m10:	equ	6
stars_m11:	equ	6+2
stars_m12:	equ	6+4
stars_m20:	equ	12
stars_m21:	equ	12+2
stars_m22:	equ	12+4

; a0 = source
; a1 = dest
matrix_copy:
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		move.l	8(a0),8(a1)
		move.l	12(a0),12(a1)
		move.w	16(a0),16(a1)
		rts

; a0 = matrix
stars_matrix_identity:
		move.w	#$4000,stars_m00(a0)
		clr.w	stars_m01(a0)
		clr.w	stars_m02(a0)

		clr.w	stars_m10(a0)
		move.w	#$4000,stars_m11(a0)
		clr.w	stars_m12(a0)

		clr.w	stars_m20(a0)
		clr.w	stars_m21(a0)
		move.w	#$4000,stars_m22(a0)
		rts

;a0 = src1
;a1 = src2
;a2 = dest
stars_matrix_mul:
		moveq	#0,d0		;i
.matrix_loop1:	moveq	#0,d1		;j
.matrix_loop2:

;mat1[i][0] * mat2[0][j]
.bb:
		move.w	(a0,d0.w),d2
		move.w	(a1,d1.w),d7
		muls	d2,d7
		asr.l	#8,d7
		asr.l	#6,d7


;mat1[i][1] * mat2[1][j]
		move.w	2(a0,d0.w),d2
		move.w	6(a1,d1.w),d3
		muls	d2,d3
		asr.l	#8,d3
		asr.l	#6,d3
		add.w	d3,d7

;mat1[2][1] * mat2[2][j]
		move.w	4(a0,d0.w),d2
		move.w	12(a1,d1.w),d3
		muls	d2,d3
		asr.l	#8,d3
		asr.l	#6,d3
		add.w	d3,d7

                move.w  d0,d2
                add.w   d1,d2
                move.w  d7,0(a2,d2.w)

		addq.w	#2,d1
		cmp.w	#2*3,d1
		bne.s	.matrix_loop2

		addq.w	#6,d0
		cmp.w	#6*3,d0
		bne.s	.matrix_loop1
		rts

;a0 = dst matrix
;d0 = wx
;d1 = wy
;d2 = wz
stars_matrix_rotate:
		move.l	a0,a3
		bsr	stars_matrix_identity
		lea	stars_matx,a0
		bsr	stars_matrix_identity
		lea	stars_maty,a0
		bsr	stars_matrix_identity
		lea	stars_matz,a0
		bsr	stars_matrix_identity

		lea	sincos4000,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d6		;sin(wx)
		add.w	#4096/4*2,d0
		move.w	(a1,d0.w),d7		;cos(wx)

		lea	stars_matx,a0
		move.w	d7,stars_m11(a0)	;11 cos(wx)
		move.w	d6,stars_m12(a0)	;12 sin(wx)
		neg.w	d6
		move.w	d6,stars_m21(a0)	;21 -sin(wx)
		move.w	d7,stars_m22(a0)	;22 cos(wx)
.qx:
		add.w	d1,d1
		move.w	(a1,d1.w),d6		;sin(wx)
		add.w	#4096/4*2,d1
		move.w	(a1,d1.w),d7		;cos(wx)

		lea	stars_maty,a0
		move.w	d6,stars_m20(a0)	;20 sin(wx)
		move.w	d7,stars_m22(a0)	;22 cos(wx)
		neg.w	d6
		move.w	d7,stars_m00(a0)	;00 cos(wx)
		move.w	d6,stars_m02(a0)	;02 -sin(wx)
.qy:
		add.w	d2,d2
		move.w	(a1,d2.w),d6		;sin(wx)
		add.w	#4096/4*2,d2
		move.w	(a1,d2.w),d7		;cos(wx)

		lea	stars_matz,a0
		move.w	d7,stars_m00(a0)	;00 cos(wx)
		move.w	d6,stars_m01(a0)	;01 sin(wx)
		neg.w	d6
		move.w	d6,stars_m10(a0)	;00 -sin(wx)
		move.w	d7,stars_m11(a0)	;11 cos(wx)
.qz:
		lea	(a3),a0
		lea	stars_matx,a1
		lea	stars_mat,a2
		bsr	stars_matrix_mul	;x*y => matxy

		lea	stars_mat,a0		;x rotated
		lea	stars_maty,a1
		lea	stars_mat2,a2		;dest
		bsr	stars_matrix_mul	;(x*y)*z => dest

		lea	stars_mat2,a0		;x rotated
		lea	stars_matz,a1
		lea	(a3),a2			;dest
		bsr	stars_matrix_mul	;(x*y)*z => dest
.q1:		rts



	ifne	0

stars_slowsort:
; d0.w	numverts
		move.l	stars_rotcadr1,a0
		addq.l	#4,a0			;z
		subq.w	#2,d0

.again:		move.l	a0,a1
		move.l	a0,a2
		addq.l	#8,a2
		move.w	d0,d7

.sort:		move.w	(a1),d1
		cmp.w	(a2),d1
		bgt.s	.noswap
		movem.l	-4(a1),d2-d3
		movem.l	-4(a2),d4-d5
		movem.l	d4-d5,-4(a1)
		movem.l	d2-d3,-4(a2)
.noswap:	addq.l	#8,a2

		dbra	d7,.sort
		addq.l	#8,a0
		dbra	d0,.again
		rts

	endc

		section	data

stars_rotcadr1:		dc.l	stars_rotcoords
stars_project_const:	dc.l	500
stars_extratab:		dc.l	0,0,0
stars_anx:		dc.w	0
stars_any:		dc.w	0
stars_anz:		dc.w	0


		section	bss

stars_copymatrix:	ds.w	3*3
stars_matx:		ds.w	3*3
stars_maty:		ds.w	3*3
stars_matz:		ds.w	3*3
stars_mat:		ds.w	3*3
stars_mat2:		ds.w	3*3
stars_matrix:		ds.w	9
stars_rotcoords:	ds.w	stars_numspr*4		;x,y,z,0

		section	text
