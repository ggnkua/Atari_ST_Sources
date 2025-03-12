* maths library

	ifd	link_library
	MODULE	input_num
	XDEF	input_num

	XREF	read_line
	endc

input_num:
* input a number & return binary value
* returns number in d0

	lea	inp_num_buff(pc),a0
	move.b	#20,(a0)
	clr.b	1(a0)
	bsr	read_line

	tst.w	d0
	bne.s	.calc_num
	moveq	#0,d0

.got_num:
	rts

.calc_num:
	moveq	#0,d0

.loop:
	move.b	(a0)+,d1
	beq.s	.got_num

	sub.b	#"0",d1
	mulu	#10,d0
	add.l	d1,d0
	bra.s	.loop


	ifd	link_library
	section	bss
	endc

inp_num_buff:
	ds.b	23
	even


	ifd	link_library
	MODULE	print_num
	
	XREF	num_to_asc,print_mes
	XDEF	print_num
	endc

print_num:
* enter with d0.L as number to print
	bsr	num_to_asc
	bra	print_mes
	rts


	ifd	link_library
	MODULE	convert_nums
	XDEF	num_to_asc,asc_to_num

	XREF	long_divide,long_multiply
	endc


asc_to_num:
* enter with:
* a0 = addr of string
*
* RETURNS:
* d0.L = binary number

	moveq	#0,d0
	moveq	#10,d1

.loop:
	moveq	#0,d2
	move.b	(a0)+,d2
	beq.s	.end_num

	bsr	long_multiply	; mult d0 by 10
	sub.b	#"0",d2
	add.l	d2,d0

	bra.s	.loop

.end_num:
	rts


num_to_asc:
* enter with d0.L as number to convert
* exits with a0 pointing to string

	lea	.num(pc),a0
	clr.b	-(a0)

	tst.l	d0
	bne.s	.not_zed

	move.b	#"0",-(a0)

.dun_num:
	rts


.not_zed:

* enter the divide loop
* first - divide by 10
	moveq	#10,d1

.do_loop:
	bsr	long_divide

	add.b	#"0",d2
	move.b	d2,-(a0)

	tst.l	d0
	bne.s	.do_loop

	bra.s	.dun_num


	ifd	link_library
	section	bss
	endc

	ds.b	100
.num:



	ifd	link_library
	MODULE	long_mathc
	XDEF	long_divide,long_multiply
	endc

long_divide:
* enter with d0.L = num
* d1.L = divisor
* exits with:
* d0.L = result
* d1.L unchanged
* d2.L = remainder

	move.l	d3,-(a7)
	moveq	#0,d3

	move.l	d0,d2

.loop:
	rept	15
	sub.l	d1,d2
	bmi.s	.dun_div
	beq.s	.dun_div_1
	addq.l	#1,d3
	endr

	bra.s	.loop

.dun_div_1:
	addq.l	#1,d3
.dun_div:
	tst.l	d2
	beq.s	.no_remainder

* is negative - so we've got a remainder!
	add.l	d1,d2
.no_remainder:
	move.l	d3,d0

	move.l	(a7)+,d3
	rts


long_multiply:
* d0 = number to multiply
* d1 = number to mult by
*
* RETURNS
* d0.L = result

	movem.l	d2-3,-(a7)

	moveq	#0,d3		; bit count to 0
	moveq	#0,d2		; 0 so far...

.mult:
	btst	d3,d1
	beq.s	.no_add		; branch if next lowest bit is 0

* bit is set, so add!
	add.l	d0,d2		; add original no to total

.no_add:
	add.l	d0,d0		; shift no along by 1

	addq.b	#1,d3
	and.b	#31,d3
	bne.s	.mult

	move.l	d2,d0

	movem.l	(a7)+,d2-3
	rts

