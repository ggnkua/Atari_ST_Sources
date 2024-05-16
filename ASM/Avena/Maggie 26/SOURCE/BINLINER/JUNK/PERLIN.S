;-------------------------------------------------------------------
; per textures
;
;

per_grid		equ	64		(of grid)
per_x_count		equ	384/per_grid
per_y_count		equ	256/per_grid
per_inc			equ	$8000/per_grid	(fractional)

			rsreset
per_val			rs.w	1
per_xgrad		rs.w	1
per_ygrad		rs.w	1
per_size		rs.b	1

		include	spline.s


per_start:

per_init:
		lea	per_buffer_1,a0
		move.w	#(per_x_count+1)*(per_y_count+1)-1,d7
.pi:
		bsr	per_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		move.w	d0,(a0)+		;value

		bsr	per_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		move.w	d0,(a0)+		;gradient x

		bsr	per_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		move.w	d0,(a0)+		;gradient y
		dbf	d7,.pi
		rts

per_calc:
		lea	per_buffer_1,a0
		move.w	#per_y_count-1,d7
.prrow:
		movem.l	d0-a6,-(a7)
		bsr	per_calc_row
		movem.l	(a7)+,d0-a6
		lea	(per_x_count+1)*per_size(a0),a0
		lea	((per_x_count*per_grid*per_grid*2).l,a1),a1
		dbf	d7,.prrow
		rts

; calc a block of a row
; a0 - input values
; a1 - output values

per_calc_row:
		move.w	#per_x_count-1,d7
.pblock:
		movem.l	d0-a6,-(a7)
		bsr	per_calc_block
		movem.l	(a7)+,d0-a6
		lea	per_size(a0),a0
						;move across in input
		lea	per_grid*2(a1),a1	;move across in output
		dbf	d7,.pblock
		rts


; each strip of 16 values is a cubic spline
; the values at each side are also splines using spl_calc etcetc

; So: calc the downward values into a buffer, then interpolate
; the horizontal gradients
; Finally calc 16 splines acrossways

per_calc_block:

; Calc downward values:
		movem.l	a0/a1,-(a7)

		pea	(a0)
		move.l	a0,a2				;a2 block 1
		lea	per_size*(per_x_count+1)(a2),a3	;a3 block 2

		lea	per_temp_matrix,a0
		move.w	per_val(a2),(a0)
		move.w	per_val(a3),2(a0)
		move.w	per_ygrad(a2),4(a0)
		move.w	per_ygrad(a3),6(a0)

; Save the x gradients too...
		move.w	per_xgrad(a2),per_xgrad_tl
		move.w	per_xgrad(a3),per_xgrad_bl
		lea	per_val_buffer_left,a4		;output addr
		bsr	per_calc_values
		move.l	(a7)+,a0

		lea	per_size(a0),a2
		lea	per_size*(per_x_count+1)(a2),a3	;a3 block 2

		lea	per_temp_matrix,a0
		move.w	per_val(a2),(a0)
		move.w	per_val(a3),2(a0)
		move.w	per_ygrad(a2),4(a0)
		move.w	per_ygrad(a3),6(a0)
		move.w	per_xgrad(a2),per_xgrad_tr
		move.w	per_xgrad(a3),per_xgrad_br

		lea	per_val_buffer_right,a4	;output addr
		bsr	per_calc_values

; Now interpolate the horizontal gradients.
; This is 
;      Interpolate_Square := g0 + x * (g1-g0)

; Do tl to bl first
		move.w	per_xgrad_tl(pc),d0
		move.w	per_xgrad_bl(pc),d1
		lea	per_xgrad_buffer_left(pc),a0
		bsr	per_calc_xgrads

; Now tr to br
		move.w	per_xgrad_tr(pc),d0
		move.w	per_xgrad_br(pc),d1
		lea	per_xgrad_buffer_right(pc),a0
		bsr	per_calc_xgrads

; OK now we have the l/r values, l/r xgradients
; We can now calc the actual values!
		movem.l	(a7)+,a5/a6		;pop 'em
						;a5 input (unused)
						;a6 output
		lea	per_val_buffer_left(pc),a2
		lea	per_val_buffer_right(pc),a3
		lea	per_xgrad_buffer_left(pc),a4
		lea	per_xgrad_buffer_right(pc),a5
		move.w	#per_grid-1,d7
.pstrip:
		lea	per_temp_matrix,a0
		move.w	(a2)+,(a0)
		move.w	(a3)+,2(a0)
		move.w	(a4)+,4(a0)
		move.w	(a5)+,6(a0)
		movem.l	a2-a5,-(a7)
		move.l	a6,a4			;output
		bsr	per_calc_values
		movem.l	(a7)+,a2-a5
		lea	(per_x_count*per_grid*2)(a6),a6	;move down
		dbf	d7,.pstrip
		rts

; a0 matrix address
; a4 output address
per_calc_values:
		movem.l	d0-a6,-(a7)
		lea	per_temp_matrix_2,a1
		moveq	#1,d0
		bsr	spl_init_matrix_hermite
; Now calc the values:
		move.w	#0,d0
		move.w	#per_grid-1,d7
		move.l	a4,a1			;output address
.cv:		lea	per_temp_matrix_2,a0
		move.w	#1,d1			;only 1 value!
		bsr	spl_calc_spline_value
		add.w	#per_inc,d0
		dbf	d7,.cv
		movem.l	(a7)+,d0-a6
		rts


;      Interpolate_Square := g0 + x * (g1-g0)

per_calc_xgrads:
		movem.l	d0-a6,-(a7)
		sub.w	d0,d1
		moveq	#0,d2
		move.w	#per_grid-1,d3
.px:
		move.w	d1,d4
		muls.w	d2,d4
		add.l	d4,d4
		swap	d4
		add.w	d0,d4
		move.w	d4,(a0)+
		add.w	#per_inc,d2		;doh!
		dbf	d3,.px
		movem.l	(a7)+,d0-a6
		rts

;-------------------------------------------------------------------
per_random:	movem.l	d1-d2,-(a7)
		movem.w	per_random_seed,d0/d1/d2
		add.w	d2,d1
		add.w	d1,d0

		add.w	#13,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		add.w	#7,d2
		;mulu.w	#9,d2

		movem.w	d0/d1/d2,per_random_seed
		asr.w	#2,d0
		movem.l	(a7)+,d1-d2
		rts

per_end:

; --------------------------------------------------------------------
			section	bss
per_temp_matrix:	ds.w	4
per_temp_matrix_2:	ds.w	4
per_val_buffer_left:	ds.w	per_grid	;for left values
per_val_buffer_right:	ds.w	per_grid	;for right values
per_xgrad_buffer_left:	ds.w	per_grid
per_xgrad_buffer_right:	ds.w	per_grid

per_xgrad_tl:		ds.w	1
per_xgrad_tr:		ds.w	1
per_xgrad_bl:		ds.w	1
per_xgrad_br:		ds.w	1
per_random_Seed		ds.w	3

per_buffer_1		ds.w	3*(per_x_count+1)*(per_y_count+1)
per_buffer_2		ds.w	per_x_count*per_y_count*per_grid*per_grid

			section	text