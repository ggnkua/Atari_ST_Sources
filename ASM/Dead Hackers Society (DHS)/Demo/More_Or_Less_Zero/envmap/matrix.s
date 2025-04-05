
		section	text

m00             equ 0
m01             equ 2
m02             equ 4
m10             equ 6
m11             equ 6+2
m12             equ 6+4
m20             equ 12
m21             equ 12+2
m22             equ 12+4

; a0 = source
; a1 = dest
matrix_copy:
                move.l  (a0),(a1)
                move.l  4(a0),4(a1)
                move.l  8(a0),8(a1)
                move.l  12(a0),12(a1)
                move.w  16(a0),16(a1)
                rts

; a0 = matrix
matrix_identity:
                move.w  #$4000,m00(a0)
                clr.w   m01(a0)
                clr.w   m02(a0)

                clr.w   m10(a0)
                move.w  #$4000,m11(a0)
                clr.w   m12(a0)

                clr.w   m20(a0)
                clr.w   m21(a0)
                move.w  #$4000,m22(a0)
                rts

;a0 = src1
;a1 = src2
;a2 = dest
matrix_mul:
                moveq   #0,d0           ;i
.matrix_loop1:
                moveq   #0,d1           ;j
.matrix_loop2:

;mat1[i][0] * mat2[0][j]
.bb:
                move.w  0(a0,d0.w),d2
                move.w  0(a1,d1.w),d7
                muls    d2,d7
                asr.l   #8,d7
                asr.l   #6,d7


;mat1[i][1] * mat2[1][j]
                move.w  2(a0,d0.w),d2
                move.w  6(a1,d1.w),d3
                muls    d2,d3
                asr.l   #8,d3
                asr.l   #6,d3
                add.w   d3,d7

;mat1[2][1] * mat2[2][j]
                move.w  4(a0,d0.w),d2
                move.w  12(a1,d1.w),d3
                muls    d2,d3
                asr.l   #8,d3
                asr.l   #6,d3
                add.w   d3,d7

                move.w  d0,d2
                add.w   d1,d2
                move.w  d7,0(a2,d2.w)

                addq.w  #2,d1
                cmp.w   #2*3,d1
                bne.s   .matrix_loop2

                addq.w  #6,d0
                cmp.w   #6*3,d0
                bne.s   .matrix_loop1
                rts

;a0 = dst matrix
;d0 = wx
;d1 = wy
;d2 = wz
matrix_rotate:
                movea.l a0,a3
		bsr	matrix_identity
                lea     matx,a0
                bsr     matrix_identity
                lea     maty,a0
                bsr     matrix_identity
                lea     matz,a0
                bsr     matrix_identity

                lea     sincos4000,a1
                add.w   d0,d0
                move.w  0(a1,d0.w),d6   ;sin(wx)
                add.w   #4096/4*2,d0
                move.w  0(a1,d0.w),d7   ;cos(wx)

                lea     matx,a0
                move.w  d7,m11(a0)      ;11 cos(wx)
                move.w  d6,m12(a0)      ;12 sin(wx)
                neg.w   d6
                move.w  d6,m21(a0)      ;21 -sin(wx)
                move.w  d7,m22(a0)      ;22 cos(wx)
.qx:
                add.w   d1,d1
                move.w  0(a1,d1.w),d6   ;sin(wx)
                add.w   #4096/4*2,d1
                move.w  0(a1,d1.w),d7   ;cos(wx)

                lea     maty,a0
                move.w  d6,m20(a0)      ;20 sin(wx)
                move.w  d7,m22(a0)      ;22 cos(wx)
                neg.w   d6
                move.w  d7,m00(a0)      ;00 cos(wx)
                move.w  d6,m02(a0)      ;02 -sin(wx)
.qy:
                add.w   d2,d2
                move.w  0(a1,d2.w),d6   ;sin(wx)
                add.w   #4096/4*2,d2
                move.w  0(a1,d2.w),d7   ;cos(wx)

                lea     matz,a0
                move.w  d7,m00(a0)      ;00 cos(wx)
                move.w  d6,m01(a0)      ;01 sin(wx)
                neg.w   d6
                move.w  d6,m10(a0)      ;00 -sin(wx)
                move.w  d7,m11(a0)      ;11 cos(wx)
.qz:
                lea     (a3),a0
                lea     matx,a1
                lea     mat,a2
                bsr     matrix_mul      ;x*y => matxy

                lea     mat,a0      ;x rotated
                lea     maty,a1
                lea     mat2,a2     ;dest
                bsr     matrix_mul      ;(x*y)*z => dest

                lea     mat2,a0     ;x rotated
                lea     matz,a1
                lea     (a3),a2         ;dest
                bsr     matrix_mul      ;(x*y)*z => dest
.q1:
                rts

		section	bss

matx:           ds.w 3*3
maty:           ds.w 3*3
matz:           ds.w 3*3
mat:            ds.w 3*3
mat2:           ds.w 3*3
matrix:		ds.w	9

		section	text
