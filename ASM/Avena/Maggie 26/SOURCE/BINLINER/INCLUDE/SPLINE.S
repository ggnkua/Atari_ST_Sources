; SPLINE.S
; General spline routines
; - occupy 198 bytes!
; Steven Tattersall, 1998
;

; CONTENTS
; spl_init_matrix_bezier
; spl_init_matrix_hermite
; spl_calc_spline_value
;



		;ifd	spl_start
; allows you to "include" the code more than once without an
; assembler error
		;else
		section	text
spl_start:
;--------------------------------------------------------------------
;                                              spl_init_matrix_bezier



; PURPOSE calculate a bezier basis matrix
; INPUT d0 no. of columns
;       a0 input matrix (in "downwards" format)
;       a1 output matrix


spl_init_matrix_bezier:
		movem.l	d0-a6,-(a7)
		lea	spl_matrix_bezier(pc),a2
		bra	spl_init_matrix


;--------------------------------------------------------------------
;                                             spl_init_matrix_hermite



; PURPOSE calculate a hermite basis matrix
; INPUT d0 no. of columns
;       a0 input matrix (in "downwards" format)
;       a1 output matrix

spl_init_matrix_hermite:

; Our input matrix is a set of 4 points, each with 'n' dimensions
; We therefore have a n x 4 matrix (width n, height 4)
; i.e.  [ a1 b1  ... ]
;       [ a2 b2      ]
;       [ a3 b3      ]
;       [ a4 b4      ]

; This is multiplied by the matrix ( 2 -2  1  1)
;                                  (-3  3 -2 -1)
;                                  ( 0  0  1  0)
;                                  ( 1  0  0  0) to give our ouput mtrx

; i.e. the first column is multiplied by 2,-2,1,1
;       then -3,3,-2,-1 for the next value 

		movem.l	d0-a6,-(a7)
		lea	spl_matrix_hermite(pc),a2
spl_init_matrix:
		move.w	d0,d7		;save the no of rows
		subq.w	#1,d7
		move.l	a0,a4
.row_loop:
		moveq	#4-1,d6
		move.l	a2,a6		;a6 - address of current input matrix


.column_loop:
		move.l	a4,a5		;a5 - address of current input row
; Now multiply this by our column:
		move.w	(a5)+,d0
		muls.w	(a6)+,d0
		move.w	(a5)+,d1
		muls.w	(a6)+,d1
		add.l	d1,d0
		move.w	(a5)+,d1
		muls.w	(a6)+,d1
		add.l	d1,d0
		move.w	(a5)+,d1
		muls.w	(a6)+,d1
		add.l	d1,d0
		move.w	d0,(a1)+	;output the column
; Move on to the next column:
		dbf	d6,.column_loop
; We have done each column, so move on to the next row of input
		addq.l	#4*2,a0
		move.l	a0,a4
		dbf	d7,.row_loop
		movem.l	(a7)+,d0-a6
		rts

;--------------------------------------------------------------------
;                                               spl_calc_spline_value
; PURPOSE calculate a single point on the curve, given the basis matrix
; INPUT
;       d0 value of "t" ($0000 t=0,  $7fff t=1)
;       d1 no. of columns
;       a0 basis matrix
;       a1 output matrix

spl_calc_spline_value:
					; first calculate our
					; values of "t"
					; and store in registers
		ext.l	d0
		movem.l	d0-d7,-(a7)
		move.w	d1,d7		;counter
		move.w	d0,d1		;d0 = t
		muls.w	d1,d1
		add.l	d1,d1
		swap	d1		;d1 = t*t
		move.w	d1,d2
		muls.w	d0,d2		;d2 = t*t*t
		add.l	d2,d2
		swap	d2
					; now calculate "d7" values
		subq.w	#1,d7
.calcloop:
		move.w	(a0)+,d6	;t*t*t term
		muls.w	d2,d6

		move.w	(a0)+,d5	;t*t term
		muls.w	d1,d5
		add.l	d5,d6
		move.w	(a0)+,d5	;t term
		muls.w	d0,d5
		add.l	d5,d6
		add.l	d6,d6
		swap	d6
		add.w	(a0)+,d6	;1 term
		move.w	d6,(a1)+
		dbf	d7,.calcloop
		movem.l	(a7)+,d0-d7
		rts

;--------------------------------------------------------------------
; The base matrices used

spl_matrix_hermite:
		dc.w	+2,-2,+1,+1
		dc.w	-3,+3,-2,-1
		dc.w	+0,+0,+1,+0
		dc.w	+1,+0,+0,+0

spl_matrix_bezier:
		dc.w	-1,+3,-3,+1
		dc.w	+3,-6,+3,+0
		dc.w	-3,+3,+0,+0
		dc.w	+1,+0,+0,+0
;--------------------------------------------------------------------

spl_end:

spl_size	=	spl_end-spl_start

		;endc