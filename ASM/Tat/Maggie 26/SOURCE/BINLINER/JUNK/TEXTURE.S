; TEXTURE.S
;
;
;

bytesperline	=	640
lines		=	200





ltest
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

		move.l	#screen+256,d0
		move.l	#bytesperline*lines,d1

		sub.b	d0,d0

		move.l	d0,physic
		add.l	d1,d0
		move.l	d0,logic
		add.l	d1,d0
		move.l	d0,third

		move.w	#$2300,sr

;--------------------------------------------------------------
;
;
;	general initialisation
;
;
;--------------------------------------------------------------

initialize_routine:
		move.l	$44e.w,old_44e

		move.w	#$24,-(a7)
		move.w	#3,-(a7)
		move.l	physic(pc),-(a7)
		move.l	logic(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea.l	14(a7),a7

;--------------------------------------------------------------
		bsr	calc_textures
		;bsr	per_init
		;bsr	per_calc

		lea	texture_envmap,a0
		moveq	#0,d0
		moveq	#0,d1
		bsr	show_texture

;--------------------------------------------------------------
.no
		cmp.b	#$39,$fffffc02.w
		bne	.no

		move.w	#1,-(a7)
		move.l	old_44e(pc),-(a7)
		move.l	old_44e(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	12(a7),a7

		clr.w	-(a7)
		trap	#1

		illegal

;-------------------------------------------------------------------
show_texture:
		move.l	physic,a1
		mulu.w	#128,d0
		mulu.w	#BytesPerLine*64,d1
		add.l	d0,a1
		add.l	d1,a1
		lea	tex_default_palette,a2

		moveq	#64-1,d0
.row:		moveq	#64-1,d1
		move.l	a1,a3
.col:		move.w	(a0)+,d2
		and.w	#$ff,d2
		move.w	(a2,d2.w*2),(a3)+
		dbf	d1,.col
		lea	bytesperline(a1),a1
		dbf	d0,.row
		rts

show_per:
		move.l	physic,a1
		lea	tex_default_palette,a2

		move.w	#200-1,d0
.row:		move.w	#320-1,d1
		move.l	a1,a3
.col:		move.w	(a0)+,d2
		asr.w	#3,d2
		add.w	#$80,d2
		;and.w	#$ff,d2
		move.w	(a2,d2.w*2),(a3)+
		dbf	d1,.col
		lea	bytesperline(a1),a1
		dbf	d0,.row
		rts

;-------------------------------------------------------------------
calc_textures:
		bsr	tex_calc_random
		bsr	tex_calc_circles

		lea	texture_circles,a0
		bsr	tex_calc_blur

		rept	10
		lea	texture_blur,a0
		bsr	tex_calc_blur
		endr
		bsr	tex_calc_relief
		bsr	tex_calc_envmap
		rts


tex_calc_relief:
		lea	texture_blur,a0
		lea	texture_relief,a1
		moveq	#0,d0
		move.w	#64*64-1,d7

.pix:		move.w	d0,d1
		add.w	#2,d1
		and.w	#64*64-1,d1

		move.w	d0,d2
		add.w	#64*2,d2
		and.w	#64*64-1,d2

		move.w	(a0,d0.w*2),d3		;current
		move.w	(a0,d1.w*2),d4		;down one
		move.w	(a0,d2.w*2),d5		;across one
; (d0-d1) + (d0 - d2)
		add.w	d3,d3
		sub.w	d4,d3
		sub.w	d5,d3
		;asr.w	#1,d3
		add.w	#$80,d3
		move.w	d3,(a1)+
		addq.l	#1,d0
		dbf	d7,.pix
		rts

tex_calc_blur:

		lea	texture_blur,a1

		moveq	#0,d0
		moveq	#1,d1
		move.w	#64,d2
		move.w	#65,d3

		move.w	#64*64-1,d7

.pix:
		move.w	(a0,d0.w*2),d4
		add.w	(a0,d1.w*2),d4
		add.w	(a0,d2.w*2),d4
		add.w	(a0,d3.w*2),d4
		asr.w	#2,d4
		and.w	#$ff,d4
		move.w	d4,(a1)+

		addq.l	#1,d0
		addq.l	#1,d1
		and.w	#64*64-1,d1
		addq.l	#1,d2
		and.w	#64*64-1,d2
		addq.l	#1,d3
		and.w	#64*64-1,d3
		dbf	d7,.pix
		rts


tex_calc_circles:
		lea	texture_circles,a0
		move.w	#150-1,d7

.circle:
		bsr	tex_random
		and.w	#255,d0
		move.w	d0,tex_circle_colour
		bsr	tex_random

		and.w	#15,d0			;d0 - radius
		moveq	#0,d1			;d1 - x coord
		move.w	d0,-(a7)
		lea	tex_circle_buffer(pc),a0
		bsr	tex_calc_circle

		move.w	(a7)+,d6		;d6 - radius
		lea	tex_circle_buffer(pc),a0
		subq.w	#1,d6
		bmi.s	.nocircle
		bsr	tex_random
		move.w	d0,d1
		sub.w	#64,d1
.row:
		move.w	(a0),d5			;d5 - radius
		move.w	d0,d3			;copy position left
		move.w	d0,d4			;copy position right
		bsr	.draw_row
		move.w	(a0)+,d5		;d5 - radius
		move.w	d1,d3			;copy position left
		move.w	d1,d4			;copy position right
		bsr	.draw_row

		add.w	#64,d0
		sub.w	#64,d1
		dbf	d6,.row
.nocircle:	dbf	d7,.circle
		rts

.draw_row:
		subq.w	#1,d4
		subq.w	#1,d5
		bmi.s	.nodraw
		move.w	tex_circle_colour(pc),d2
		lea	texture_circles(pc),a1
.pixel:		and.w	#64*64-1,d3
		and.w	#64*64-1,d4
		add.w	d2,(a1,d3.w*2)
		add.w	d2,(a1,d4.w*2)
		addq.w	#1,d3
		subq.w	#1,d4
		dbf	d5,.pixel
.nodraw:	rts

;-------------------------------------------------------------------
tex_calc_random:
		lea	texture_random,a0
		move.w	#64*64-1,d7
.get:		bsr	tex_random
		move.w	d0,d1
		asr.w	d1
		bsr	tex_random
		and.w	#$ff,d0
		add.w	d1,d0
		asr.w	d0
		and.w	#$ff,d0
		move.w	d0,(a0)+
		dbf	d7,.get
		rts


;-------------------------------------------------------------------
tex_calc_envmap:
		lea	texture_envmap,a0
		move.w	#-32,d7
.row
		move.w	#-32,d6
.col
		move.w	d6,d0
		muls	d0,d0
		move.w	d7,d1
		muls	d1,d1
		add.l	d1,d0
		asr.l	#3,d0
		neg.w	d0
		add.w	#127,d0
		bge.s	.ok
		moveq	#0,d0
.ok
		move.w	d0,(a0)+
		addq.w	#1,d6
		cmp.w	#32,d6
		bne.s	.col
		addq.w	#1,d7
		cmp.w	#32,d7
		bne.s	.row
		rts



;-------------------------------------------------------------------
tex_random:	movem.l	d1-d2,-(a7)
		movem.w	tex_random_seed,d0/d1/d2
		add.w	d2,d1
		add.w	d1,d0

		add.w	#13,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		add.w	#7,d2
		;mulu.w	#9,d2

		movem.w	d0/d1/d2,tex_random_seed
		asr.w	#2,d0
		movem.l	(a7)+,d1-d2
		rts


;-------------------------------------------------------------------
tex_circles:
		movem.l	d1-d2,-(a7)
		movem.w	tex_random_seed,d0/d1/d2
		add.w	d1,d0
		add.w	#13,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		mulu.w	#9,d2
		add.w	#7,d2
		movem.w	d0/d1/d2,tex_random_seed
		asr.w	#2,d0
		movem.l	(a7)+,d1-d2
		rts



; --------------------------------------------------------------------
; Calculate circle:
; a0=start of buffer - left right, left right
; d0=radius
; d1=central x coord

tex_calc_circle:
		movem.l	d0-d7,-(a7)
		lea	(a0,d0.w*2),a0
		move.w	d0,d3

		add.w	d3,d3

		moveq	#0,d2		;central coord
		move.w	d3,d4		; d4= x subtract
		moveq	#0,d5		; d5= y add

.circle_iter1:
		;subq.w	#1,d1
		addq.w	#1,d2		; right coord in
		addq.w	#2,d5		; x subtract decreases
		sub.w	d5,d3
		bgt	.circle_iter1
		dbf	d0,.circle_iter2
.circle_done:
		movem.l	(a7)+,d0-d7
		rts

.circle_iter2:
		move.w	d2,-(a0)	;left right at top
		subq.w	#2,d4		;increase y add
		add.w	d4,d3
		bgt	.circle_iter1
		dbf	d0,.circle_iter2
		bra	.circle_done


;-------------------------------------------------------------------
; per textures
;
;

per_grid		equ	32		(of grid)
per_x_count		equ	320/per_grid
per_y_count		equ	200/per_grid
per_inc			equ	$8000/per_grid	(fractional)

			rsreset
per_val			rs.w	1
per_xgrad		rs.w	1
per_ygrad		rs.w	1
per_size		rs.b	1

		include	spline.s

per_init:
		lea	per_buffer_1,a0
		move.w	#(per_x_count+1)*(per_y_count+1)-1,d7
.pi:
		bsr	tex_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		moveq	#0,d0
		move.w	d0,(a0)+		;value

		bsr	tex_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		move.w	d0,(a0)+		;gradient x

		bsr	tex_random
		and.w	#$1fff,d0
		sub.w	#$1000,d0
		move.w	d0,(a0)+		;gradient x


		dbf	d7,.pi
		rts

per_calc:
		lea	per_buffer_1,a0
		lea	per_buffer_2,a1

		move.w	#per_y_count-1,d7
.prrow:
		movem.l	d0-a6,-(a7)
		bsr	per_calc_row
		movem.l	(a7)+,d0-a6
		lea	(per_x_count+1)*per_size(a0),a0
		lea	(per_x_count*per_grid*per_grid)*2(a1),a1
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

; Do a value clamp here?
;		move.w	-(a1),d1
;
;		cmp.w	#-$1ff,d1
;		bgt.s	.ok2
;		move.w	#-$1ff,d1
;		moveq	#0,d1
;.ok1:		cmp.w	#$1ff,d1
;		blt.s	.ok2
;		move.w	#$1ff,d1
;.ok2:
;		move.w	d1,(a1)+


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


; --------------------------------------------------------------------

per_temp_matrix:		ds.w	4
per_temp_matrix_2:		ds.w	4
per_val_buffer_left:		ds.w	per_grid	;for left values
per_val_buffer_right:		ds.w	per_grid	;for right values
per_xgrad_buffer_left:		ds.w	per_grid
per_xgrad_buffer_right:		ds.w	per_grid


per_xgrad_tl:			ds.w	1
per_xgrad_tr:			ds.w	1
per_xgrad_bl:			ds.w	1
per_xgrad_br:			ds.w	1

; --------------------------------------------------------------------






; --------------------------------------------------------------------
			section	bss
; --------------------------------------------------------------------
tex_random_seed:	ds.w	3

;-------------------------------------------------------------------
			section data
;-------------------------------------------------------------------
tex_default_palette:
o			set	0		;grey palette
			rept	32
			dcb.w	8,o
o			set	o+$841
			endr

;-------------------------------------------------------------------
			section	bss
;-------------------------------------------------------------------
old_44e			ds.l	1
logic			ds.l	1
physic			ds.l	1
third			ds.l	1

tex_circle_colour	ds.w	1
tex_circle_buffer	ds.w	32

texture_random		ds.w	64*64
texture_circles		ds.w	64*64
texture_relief		ds.w	64*64
texture_blur		ds.w	64*64
texture_envmap		ds.w	64*64

per_buffer_1		ds.w	3*(per_x_count+1)*(per_y_count+1)
per_buffer_2		ds.w	per_x_count*per_y_count*per_grid*per_grid


screen			ds.w	256
