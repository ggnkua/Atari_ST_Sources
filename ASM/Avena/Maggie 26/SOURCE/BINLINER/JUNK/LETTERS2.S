;
; would be far quicker to calculate the letters to memory
; in advance
;


pixels		=	640
height		=	400

bytesperline	=	80
lines		=	400

letter_splcount	=	7

line		=	0
spline		=	1
fill		=	2
 
ltest
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

		move.l	#bytesperline*(lines+40)+256,d1
		move.l	$44e.w,d0
		sub.l	d1,d0
		sub.b	d0,d0
		move.l	d0,logic
		sub.l	d1,d0
		sub.b	d0,d0
		move.l	d0,physic
		sub.l	d1,d0
		sub.b	d0,d0
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

		move.w	#$120+$8,-(a7)
		move.w	#3,-(a7)
		move.l	physic(pc),-(a7)
		move.l	logic(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea.l	14(a7),a7
;--------------------------------------------------------------

		;move.w	#500*2,letter_size_x
		;move.w	#500*2,letter_size_y
		bsr	letter_make_buffer

.letterloop:
		;bsr	make_palette
		move.l	#0,$ffff9800.w
		move.l	#-1,$ffff9804.w

		bsr	draw_one_word
		bsr	draw_screen
		bsr	screen_Swap

		;rept	4
		bsr	wait_vbl
		;endr

		;moveq	#0,d0
		;move.w	#8,-(a7)
		;trap	#1
		;addq.l	#2,a7

		move.w	#$ff,-(a7)
		move.w	#6,-(a7)
		trap	#1
		addq.l	#4,a7

		;cmp.w	#"z",letter_number
		;beq	exit
		;addq.w	#1,letter_number

		cmp.b	#" ",d0
		bne.s	.letterloop

exit:
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
draw_screen:
		;move.w	letter_bitplane,d0
		;add.w	#2,d0
		;and.w	#6,d0
		;move.w	d0,letter_bitplane
		
		lea	buffer,a0
		move.l	logic,a1
		;add.w	d0,a1

		move.w	#pixels/16-1,d0
		moveq	#0,d4
.column:	move.l	a1,a2
		move.w	#height-1,d1
		moveq	#0,d2
.block:		move.w	(a0),d3
		eor.w	d3,d2
		move.w	d2,(a2)
		move.w	d4,(a0)+		; clear it
		lea	bytesperline(a2),a2
		dbf	d1,.block
		lea	2(a1),a1		; next bitplane

		dbf	d0,.column
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

tex_random_seed	ds.w	3


draw_one_word:
		bsr	tex_random
		and.w	#15,d0
		add.w	#120,d0
		move.w	d0,letter_size_x		
		move.w	d0,letter_size_y
		move.w	#-200,letter_pos_x
		move.w	#0,letter_pos_y
		lea	code(pc),a0

		rept	8
		moveq	#0,d0
		move.b	(a0)+,d0
		pea	(a0)
		;clr.l	$ffff9800.w
		bsr	make_letter_data
		;move.l	#-1,$ffff9800.w
		bsr	a_rout
		move.l	(a7)+,a0
		endr

		rts

code:		dc.b	"binliner",0
		even

a_rout:
		lea	letter_buffer(pc),a1
		bsr	draw_poly
		add.w	#$1000,d0
		muls.w	letter_size_x,d0
		swap	d0
		add.w	d0,letter_pos_x
		rts

;-------------------------------------------------------------------


make_letter_data:
		lea	letter_buffer,a1
		sub.w	#"a",d0
		move.w	(fontoffsets,pc,d0.w*2),a0
		add.l	#fontdata,a0		; get data addr

		pea	(a1)
		addq.w	#2,a1

		moveq	#0,d7			;number of lines...

		move.w	(a0)+,d0
		subq.w	#1,d0
.lineloop:
		move.w	(a0)+,d1

		cmp.w	#spline,d1
		beq.s	.spline
		cmp.w	#fill,d1
		beq.s	.noline

		movem.w	(a0)+,d1/d2/d3/d4	;x1,y1,x2,y2
		move.w	d1,(a1)+
		move.w	d2,(a1)+
		move.w	d3,(a1)+		;simply copy to
		move.w	d4,(a1)+		;the output buffer
		addq.l	#1,d7
.noline:
.splinedone:
		dbf	d0,.lineloop
		move.w	(a0)+,(a1)+
		move.l	(a7)+,a1
		move.w	d7,(a1)			;save line counter
		rts

.spline:
		movem.l	d0-d7/a2-a6,-(a7)
		move.l	(a0),(a1)+		;copy 1st value....

		pea	(a1)
		lea	letter_spline_matrix_in,a1
		move.w	(a0)+,(a1)
		move.w	(a0)+,8(a1)
		move.w	(a0)+,2(a1)
		move.w	(a0)+,10(a1)
		move.w	(a0)+,4(a1)
		move.w	(a0)+,12(a1)

		move.w	(a0),letter_lastx
		move.w	(a0)+,6(a1)

		move.w	(a0),letter_lasty
		move.w	(a0)+,14(a1)

		pea	(a0)
		lea	letter_spline_matrix_in,a0
		lea	letter_spline_matrix_out,a1
		moveq	#2,d0
		bsr	spl_init_matrix_bezier
		move.l	(a7)+,a0

		move.l	(a7)+,a1
		pea	(a0)

; Now calc #10 values (or 9 + our original)

		move.w	#$8000/letter_splcount,d0
		moveq	#letter_splcount-1-1,d7
.calcloop:
		lea	letter_spline_matrix_out,a0
		move.w	#2,d1			;x,y
		bsr	spl_calc_spline_value
		move.l	-4(a1),(a1)+		;double value
		add.w	#$8000/letter_splcount,d0
		dbf	d7,.calcloop

		move.w	letter_lastx,(a1)+
		move.w	letter_lasty,(a1)+

; update the counter!

		move.l	(a7)+,a0

; copy the lines now.
		movem.l	(a7)+,d0-d7/a2-a6
		add.w	#letter_splcount,d7
		bra	.splinedone


; make x data:


letter_make_buffer:
		lea	letter_x_data,a0

		move.l	#-20*height,d2
		move.l	#$8000,d1
		move.w	#pixels-1,d0

.makeloop:	move.w	d1,(a0)+
		move.w	d2,(a0)+
		ror.w	d1
		bcc.s	.nonext
		add.l	#height,d2

.nonext:	dbf	d0,.makeloop

		moveq.l	#$0,d1
		;bsr.s	.copy_buffer
.copy_buffer:
		rts

;-------------------------------------------------------------------
draw_poly
		move.w	(a1)+,d6		;line count
		subq.w	#1,d6
		bmi	.nolines

		;lea	letter_rotated_points(pc),a1
.lineloop:
		movem.w	(a1)+,d0/d1		;x1,y1
		muls.w	letter_size_x,d0
		muls.w	letter_size_y,d1
		swap	d0
		swap	d1
		add.w	letter_pos_x,d0
		add.w	letter_pos_y,d1

		movem.w	(a1),d2/d3		;x2,y2
		muls.w	letter_size_x,d2
		muls.w	letter_size_y,d3
		swap	d2
		swap	d3
		add.w	letter_pos_x,d2
		add.w	letter_pos_y,d3


		ext.l	d0		
		ext.l	d1		
		ext.l	d2		
		ext.l	d3		

; right, we *always* go from left to right.

		cmp.l	d2,d0
		ble.s	.noswap
		move.l	d0,d2
		move.l	d1,d3
		movem.w	(a1),d0/d1
		muls.w	letter_size_x,d0
		muls.w	letter_size_y,d1
		swap	d0
		swap	d1
		add.w	letter_pos_x,d0
		add.w	letter_pos_y,d1
		ext.l	d0		
		ext.l	d1		
.noswap:

; now get the width and height sorted:
		sub.l	d0,d2			;d2 = width offset
		ble.s	.noline

		sub.l	d1,d3			;d3 = height offset

; get the "one over" value
		move.l	#$0ffff,d4
		divs.l	d2,d4			;that's the offset
; now multiply by the height offset
		muls	d3,d4

		lea	buffer+(height*2*20)+(2*height/2),a3
						;middle strip, centre

; buffer is organised in downward strips
; so it's a0 we want.
; the horizontal offset is y/16 * (height*2)

		lea	(letter_x_data+(pixels/2*4),pc,d0.w*4),a2

		moveq	#0,d5
		move.w	d1,d5			;d5 current height
		
		subq.w	#1,d2			;d2 = width counter

.pixelloop:
		movem.w	(a2)+,d0/d3		;data/offset
		move.l	d5,d1
		add.w	d3,d1			;add the horizontal offset
		eor.w	d0,(a3,d1.w*2)
		swap	d5
		add.l	d4,d5			;horrible
		swap	d5
		dbf	d2,.pixelloop
.noline:
		addq.l	#4,a1			;skip end point
		dbf	d6,.lineloop
.nolines:
		;subq.w	#2,a1
		moveq	#0,d0
		move	(a1)+,d0
		rts


screen_swap:
		move.l	logic,d0
		move.l	third,logic
		move.l	physic,third
		move.l	d0,physic
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts

wait_vbl:
		move.w	#37,-(a7)
		trap	#14
		addq.l	#2,a7
		rts


make_palette:
		lea	$ffff9800.w,a0
		moveq	#0,d4
		move.w	#$100-1,d0
.copy:		move.w	d0,d1
		not.b	d1			;invert bits
		move.l	d4,d2

		moveq	#8-1,d3
.sumit		roxr.b	d1
		addx.w	d4,d2
		dbf	d3,.sumit

		;seq	d2
		mulu.w	#$1f1f,d2
		move.w	d2,(a0)+
		move.w	d2,(a0)+
		dbf	d0,.copy
		rts

;-------------------------------------------------------------------
letter_number:	dc.w	"a"
;-------------------------------------------------------------------

			include	spline.s

			section data

;-------------------------------------------------------------------
			include	include\outfont.s

;-------------------------------------------------------------------

			section	bss
letter_spline_matrix_in:ds.w	4*2
letter_spline_matrix_out:	ds.w	4*2
letter_lastx		ds.w	1
letter_lasty		ds.w	1
letter_bitplane		ds.w	1

logic			ds.l	1
physic			ds.l	1
third			ds.l	1

old_44e			ds.l	1

letter_offset		ds.w	1
			ds.w	1

letter_size_x		ds.w	1
letter_size_y		ds.w	1
letter_pos_x		ds.w	1
letter_pos_y		ds.w	1

letter_x_data:		ds.w	pixels*2

letter_spline_output:	ds.w	2*200

letter_buffer:		ds.w	4*2000

buffer:			ds.w	(pixels/16)*height

