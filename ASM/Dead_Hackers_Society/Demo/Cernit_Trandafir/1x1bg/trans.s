; Altparty 2009 STe demo
; Texturemapper on top of 1x1 background
;
; trans.s

	section	text

;---------------------------------------------------------------
;		Rotate
;---------------------------------------------------------------

; input for matrix rotation
;
; bg1x1_coordsadr.l	=	address to vertexlist
; bg1x1_ecoordsadr.l	=	address to env vertexlist
; bg1x1_numvertex.w	=	numbero f vertexes

bg1x1_mul_rotate:
		lea	bg1x1_matrix,a0
		move.w	bg1x1_anx,d0		;x-angle
		move.w	bg1x1_any,d1		;y-angle
		move.w	bg1x1_anz,d2		;z-angle 
		bsr 	bg1x1_matrix_rotate	;rotate it

		move.l	bg1x1_coordsadr,a0
		lea	bg1x1_rotcoords,a1
		lea	bg1x1_matrix,a2
		move.w	bg1x1_numvertex,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		bsr	bg1x1_transform_mul6_pro ;fast!!

		rts

		ifne	0
bg1x1_mul_rotate_env:
		lea	bg1x1_matrix,a0
		move.w	bg1x1_anx,d0		;x-angle
		move.w	bg1x1_any,d1		;y-angle
		move.w	bg1x1_anz,d2		;z-angle 
		bsr 	bg1x1_matrix_rotate	;rotate it
		
		move.l	bg1x1_coordsadr,a0
		lea	bg1x1_rotcoords,a1
		lea	bg1x1_matrix,a2
		move.w	bg1x1_numvertex,d0
		moveq.l	#0,d1
		moveq.l	#0,d2
		moveq.l	#0,d3
		bsr	bg1x1_transform_mul6_pro ;fast!!

;		ifne	ENVMAPPER
		; Rotate the env coordinates
		move.l	bg1x1_ecoordsadr,a0
		lea	bg1x1_envcoords,a1
		lea	bg1x1_matrix,a2
		move.w	bg1x1_numvertex,d0
		moveq.l	#0,d1	
		moveq.l	#0,d2
		moveq.l	#0,d3
		bsr	bg1x1_transform_mul6
;		endc
		rts
		endc
		
; s[i] = (i*i/4)>>SHIFTDOWN
; x = s[a+x0] - s[a-x0] + s[b+y0] - s[b-y0] + s[c+z0] - s[c-z0]
; y = s[d+x0] - s[d-x0] + s[e+y0] - s[e-y0] + s[f+z0] - s[f-z0]
; z = s[g+x0] - s[g-x0] + s[h+y0] - s[h-y0] + s[i+z0] - s[i-z0]

; in   d0      number of vertices
;      a0      source vertices (x,y,z), pre-scaled by 2
;      a1      dest vertices (x,y,z)
;      a2      coeff table (9 words)

;      d1      origin x
;      d2      origin y
;      d3      origin z

XX_	=	 0+0
XY_	=	 0+2
XZ_	=	 0+4
YX_	=	 6+0
YY_	=	 6+2
YZ_	=	 6+4
ZX_	=	12+0
ZY_	=	12+2
ZZ_	=	12+4

X0_	=	0
Y0_	=	2
Z0_	=	4

		section	text

		ifne	0
bg1x1_transform_mul6:
		move.w  d0,d7
		subq.w	#1,d7
		clr.l	d0
		lea.l	bg1x1_copymatrix,a2
		lea.l	bg1x1_extratab,a4
.trans:
		movem.w	(a0)+,d4-d6	; x/y/z
				
		move.w	d5,d1
		add.w	(a2)+,d1
		move.w	d4,d0		; x
		add.w	(a2)+,d0
		muls	d1,d0
		move.w	d6,d1
		muls	(a2)+,d1
		add.l	d1,d0
		sub.l	(a4)+,d0

		move.w	d5,d2
		add.w	(a2)+,d2
		move.w	d4,d1		; y
		add.w	(a2)+,d1
		muls	d2,d1
		move.w	d6,d2
		muls	(a2)+,d2
		add.l	d2,d1
		sub.l	(a4)+,d1

		move.w	d5,d3
		add.w	(a2)+,d3
		move.w	d4,d2		; z
		add.w	(a2)+,d2
		muls	d3,d2
		move.w	d6,d3
		muls	(a2)+,d3
		add.l	d3,d2
		sub.l	(a4),d2

		;shift down 8+3 steps
		lsl.l	#4,d0
		lsl.l	#4,d1
		swap	d0
		swap	d1
		
		move.w	d0,(a1)+
		move.w	d1,(a1)+
		subq.l	#2*4,a4
		sub.l	#18,a2
		dbra    d7,.trans
		rts
		endc

bg1x1_transform_mul6_pro:
		move.w  d0,d7
		subq.w	#1,d7

		lea.l	bg1x1_copymatrix,a5
		rept	9
		move.w	(a2)+,d0
		asr.w	#1,d0
		move.w	d0,(a5)+
		endr

		lea.l	bg1x1_copymatrix,a2
		lea.l	bg1x1_extratab,a4
		move.w	XX_(a2),d0
		muls	XY_(a2),d0
		move.l	d0,(a4)
		move.w	YX_(a2),d0
		muls	YY_(a2),d0
		move.l	d0,4(a4)
		move.w	ZX_(a2),d0
		muls	ZY_(a2),d0
		move.l	d0,8(a4)

		move.l	bg1x1_project_const,a3
.trans:
		movem.w	(a0)+,d4-d6	; x/y/z

		move.w	d5,d1
		add.w	(a2)+,d1
		move.w	d4,d0		; x
		add.w	(a2)+,d0
		muls	d1,d0
		move.w	d6,d1
		muls	(a2)+,d1
		add.l	d1,d0
		sub.l	(a4)+,d0

		move.w	d5,d2
		add.w	(a2)+,d2
		move.w	d4,d1		; y
		add.w	(a2)+,d1
		muls	d2,d1
		move.w	d6,d2
		muls	(a2)+,d2
		add.l	d2,d1
		sub.l	(a4)+,d1

		move.w	d5,d3
		add.w	(a2)+,d3
		move.w	d4,d2		; z
		add.w	(a2)+,d2
		muls	d3,d2
		move.w	d6,d3
		muls	(a2)+,d3
		add.l	d3,d2
		sub.l	(a4),d2

		swap	d2		;z
		asr.l	#8,d0		;x
		asr.l	#8,d1		;y
		add.w	a3,d2
		divs	d2,d0
		divs	d2,d1

		movem.w	d0/d1/d2,(a1)
		addq.l	#8,a1
		subq.l	#2*4,a4
		sub.l	#18,a2
		dbra    d7,.trans
		rts

project_const:	dc.l	400

;--- Matrix vector algebra --------------------------------------

m00		equ 0
m01		equ 2
m02		equ 4
m10		equ 6
m11		equ 6+2
m12		equ 6+4
m20		equ 12
m21		equ 12+2
m22		equ 12+4

; a0 = source 3x3 matrix
; a1 = dest 3x3 matrix
bg1x1_matrix_copy:
		move.l	(a0),(a1)
		move.l	4(a0),4(a1)
		move.l	8(a0),8(a1)
		move.l	12(a0),12(a1)
		move.w	16(a0),16(a1)
		rts

; a0 = matrix
bg1x1_matrix_identity:
		move.w	#$4000,m00(a0)		; 1st row
		clr.w	m01(a0)
		clr.w	m02(a0)
		clr.w	m10(a0)			; 2nd row
		move.w	#$4000,m11(a0)
		clr.w	m12(a0)
		clr.w	m20(a0)			; 3rd row
		clr.w	m21(a0)
		move.w	#$4000,m22(a0)
		rts

;a0 = src1
;a1 = src2
;a2 = dest
bg1x1_matrix_mul:
		moveq	#0,d0			; i
.matrix_row:
		moveq	#0,d1			; j
.matrix_col:
		move.w	0(a0,d0.w),d2		; mat1[i][0] * mat2[0][j]
		move.w	0(a1,d1.w),d7
		muls	d2,d7
		asr.l	#8,d7
		asr.l	#6,d7

		move.w	2(a0,d0.w),d2		; mat1[i][1] * mat2[1][j]
		move.w	6(a1,d1.w),d3
		muls	d2,d3
		asr.l	#8,d3
		asr.l	#6,d3
		add.w	d3,d7

		move.w	4(a0,d0.w),d2		; mat1[2][1] * mat2[2][j]
		move.w	12(a1,d1.w),d3
		muls	d2,d3
		asr.l	#8,d3
		asr.l	#6,d3
		add.w	d3,d7

		move.w	d0,d2			; add row
		add.w	d1,d2
		move.w	d7,0(a2,d2.w)		; done

		addq.w	#2,d1
		cmp.w	#2*3,d1
		bne.s	.matrix_col		; next column
		addq.w	#6,d0
		cmp.w	#6*3,d0
		bne.s	.matrix_row		; next row
		rts

;a0 = dst matrix
;d0 = wx
;d1 = wy
;d2 = wz
bg1x1_matrix_rotate:
		movea.l a0,a3
		bsr	bg1x1_matrix_identity
		lea.l	bg1x1_matx,a0
		bsr	bg1x1_matrix_identity
		lea.l	bg1x1_maty,a0
		bsr	bg1x1_matrix_identity
		lea.l	bg1x1_matz,a0
		bsr	bg1x1_matrix_identity

		lea.l	sincos4000,a1
		add.w	d0,d0
		move.w	m00(a1,d0.w),d6		;sin(wx)
		add.w	#4096/4*2,d0
		move.w	m00(a1,d0.w),d7		;cos(wx)

		lea.l	bg1x1_matx,a0
		move.w	d7,m11(a0)		;cos(wx)
		move.w	d6,m12(a0)		;sin(wx)
		neg.w	d6
		move.w	d6,m21(a0)		;-sin(wx)
		move.w	d7,m22(a0)		;cos(wx)
.qx:

		add.w	d1,d1
		move.w	m00(a1,d1.w),d6		;sin(wx)
		add.w	#4096/4*2,d1
		move.w	m00(a1,d1.w),d7		;cos(wx)

		lea.l	bg1x1_maty,a0
		move.w	d6,m20(a0)		;sin(wx)
		move.w	d7,m22(a0)		;cos(wx)
		neg.w	d6
		move.w	d7,m00(a0)		;cos(wx)
		move.w	d6,m02(a0)		;-sin(wx)
.qy:
		add.w	d2,d2
		move.w	m00(a1,d2.w),d6		;sin(wx)
		add.w	#4096/4*2,d2
		move.w	m00(a1,d2.w),d7		;cos(wx)

		lea.l	bg1x1_matz,a0
		move.w	d7,m00(a0)		;cos(wx)
		move.w	d6,m01(a0)		;sin(wx)
		neg.w	d6
		move.w	d6,m10(a0)		;00 -sin(wx) ??????????????
		move.w	d7,m11(a0)		;cos(wx)
.qz:
		lea.l	(a3),a0
		lea.l	bg1x1_matx,a1
		lea.l	bg1x1_mat,a2
		bsr	bg1x1_matrix_mul	;x*y => matxy

		lea.l	bg1x1_mat,a0	    	;x rotated
		lea.l	bg1x1_maty,a1
		lea.l	bg1x1_mat2,a2     	;dest
		bsr	bg1x1_matrix_mul	;(x*y)*z => dest

		lea.l	bg1x1_mat2,a0     	;x rotated
		lea.l	bg1x1_matz,a1
		lea.l	(a3),a2 		;dest
		bsr	bg1x1_matrix_mul	;(x*y)*z => dest
.q1:
		rts

;--- Data ---------------------------------------------------------

		section	data

bg1x1_project_const:	dc.l	800

		section	bss
		
bg1x1_extratab:		ds.l	4
bg1x1_copymatrix:	ds.w	3*3
bg1x1_matx:		ds.w	3*3
bg1x1_maty:		ds.w	3*3
bg1x1_matz:		ds.w	3*3
bg1x1_mat:		ds.w	3*3
bg1x1_mat2:		ds.w	3*3
bg1x1_matrix:		ds.w	9

		section	text
