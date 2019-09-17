;Bezier curve include file

;    --------------------- SIF Macros --------------------------

infinity	equ	$80000000

lcmp	MACRO	compare by (d7 - d6)
	cmp.l	\1,d7
	ENDM
; Addition
ladd	MACRO	d7 = d7 + d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	ladd_sr	do it
	ENDM
; Subtraction
lsub	MACRO	d7 = d7 - d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	lsub_sr	do it
	ENDM
; Multiplication
lmul	MACRO	d7 = d7 * d6
	IFNC	'\1','d6'
	move.l	\1,d6		load x if given
	ENDC
	bsr	lmul_sr		basic routine
	ENDM
; Division
ldiv	MACRO	d7 = d7 / d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	ldiv_sr
	ENDM

;        ---------------- End of Macros --------------------

;Draw bezier curve
;ENTRY (b_table...) holds lookup table
;      (bez_in+0) = x co-ord of start
;      (bez_in+2) = y co-ord of start
;      (bez_in+4) = x co-ord of 1st ctrl
;      (bez_in+6) = y co-ord of 1st ctrl
;      (bez_in+8) = x co-ord of 2nd ctrl
;      (bez_in+10) = y co-ord of 2nd ctrl
;      (bez_in+12) = x co-ord of end
;      (bez_in+14) = y co-ord of end
;      GEM initialised
;EXIT  Line drawn on screen

draw_bezier	movem.l	d0-d7/a0-a6,-(sp)
	lea	b_table,a6	locate bez look-up table
	lea	bez_in,a5	locate co-ords data
	lea	ptsin,a4	locate polyline buffer
	move	#12,d0	set 12 points

draw_bezier1	bsr	bez_calc	calc x/y co-ords
	add	#16,a6	next table entry
	move.l	d1,d7	fetch x co-ord sif value
	swap	d7	convert sif to int
	move	d7,(a4)+	and store in array
	move.l	d2,d7	fetch y co-ord sif value
	swap	d7	convert sif to int
	move	d7,(a4)+	and store in array
	sub	#1,d0	dec points counter
	bne	draw_bezier1	repeat till zero
	v_pline	#12	and draw curve
	movem.l	(sp)+,d0-d7/a0-a6
	rts

;Calculate next x/y co-ords
;ENTRY a5=current bez_in array address
;EXIT  d1=x co-ord in SIF format
;      d2=y co-ord in SIF format

bez_calc	movem.l	a5-a6/d0/d6/d7,-(sp)
	move.l	#0,d1	d1 = 0.0 (*x)
	move.l	#0,d2	d2 = 0.0 (*y)

	move	#4-1,d0
bez_calc1	move	(a5)+,d7	calc x co-ord
	and.l	#$ffff,d7
	swap	d7	conv to sif
	move.l	(a6),d6
	lmul	d6
	move.l	d1,d6
	ladd	d6
	move.l	d7,d1	save x value
	
	move	(a5)+,d7	calc y co-ord
	and.l	#$ffff,d7
	swap	d7
	move.l	(a6)+,d6
	lmul	d6
	move.l	d2,d6
	ladd	d6
	move.l	d7,d2	save y value
	dbra	d0,bez_calc1	repeat * 4
	movem.l	(sp)+,a5-a6/d0/d6/d7
	rts
	
;        --------- Sign Integer Fraction Routines -----------------

;SIF add

ladd_sr	lcmp	#infinity,d7
	beq	ladd_sr1
	lcmp	#infinity,d6
	beq	ladd_sr2
	add.l	d6,d7
	bvc	ladd_sr1
ladd_sr2	move.l	#infinity,d7
ladd_sr1	rts

;SIF subtract

lsub_sr	lcmp	#infinity,d7
	beq	lsub_sr1
	lcmp	#infinity,d6
	beq	lsub_sr2
	sub.l	d6,d7
	bvc	lsub_sr1
lsub_sr2	move.l	#infinity,d7
lsub_sr1	rts

;SIF multiply

lmul_sr	movem.l	d3-5,-(a7)	save registers
	clr.w	d3	clear sign
	tst.l	d7
	bpl	lmul_sr1
	neg.l	d7
	bmi	lmul_sr3	d7 = infinity
	eori.w	#1,d3	d7 negative
lmul_sr1	tst.l	d6
	bpl	lmul_sr2
	neg.l	d6
	bmi	lmul_sr3	d6 = infinity
	eori.w	#1,d3	d6 negative
lmul_sr2	move.l	d7,d5	copy num_2
	move.l	d7,d4	 and again
	mulu	d6,d7	frac_2 * frac_1
	addi.l	#$00008000,d7	roundoff result
	clr.w	d7	forget least signif word
	swap	d7	shift right 16 times
	swap	d5	access int_2
	mulu	d6,d5	int_2 * frac_1
	add.l	d5,d7	add to result
	swap	d6	access int_1
	move.l	d4,d5	copy num_2
	mulu	d6,d5	frac_2 * int_1
	add.l	d5,d7	add to result
	swap	d4	access int_2
	mulu	d6,d4	int_2 * int_1
	swap	d4	shift left 16 times
	tst.w	d4	word <> 0 means overflow
	bne	lmul_sr3
	add.l	d4,d7	result
	bmi	lmul_sr3	overflow if bit #31 set
	tst.w	d3	sign
	beq	lmul_sr4	= 0 positive result
	neg.l	d7	<> 0 negative
	bra	lmul_sr4

lmul_sr3	move.l	#infinity,d7
lmul_sr4	movem.l	(a7)+,d3-5	restore registers
	rts		and return

;SIF divide

ldiv_sr	movem.l	d3-5,-(a7)	save registers
	clr.w	d3
	tst.l	d7
	bgt	ldiv_sr1	gt correct here
	beq	ldiv_sr9	as test eq here
	neg.l	d7
	bmi	ldiv_sr10
	eori.w	#1,d3
ldiv_sr1	tst.l	d6
	bgt	ldiv_sr2	gt ditto
	beq	ldiv_sr10	eq ditto
	neg.l	d6
	bmi	ldiv_sr9
	eori.w	#1,d3
ldiv_sr2	move.w	#15,d4	base count is 15
ldiv_sr3	addq.w	#1,d4
	asl.l	#1,d7	normalise d7
	bpl	ldiv_sr3
	lsr.l	#1,d7	leave a leading 0
ldiv_sr4	subq.w	#1,d4
	asl.l	#1,d6	normalise d6
	bpl	ldiv_sr4
	lsr.l	#1,d6	leave a leading 0
	cmp.w	#32,d4
	bgt	ldiv_sr9	d7 <<< d6
	tst.w	d4
	bmi	ldiv_sr10	d7 >>> d6
	swap	d4	save shift figure
	move.w	#31,d4	going to do 32 loops
ldiv_sr5	sub.l	d6,d7	dividend - divisor
	bcs	ldiv_sr6	NB use CARRY not NEGATIVE
	roxl.l	#1,d5	insert carry into quotient
	asl.l	#1,d7	dividend left
	dbra	d4,ldiv_sr5	again till done
	bra	ldiv_sr7

ldiv_sr6	roxl.l	#1,d5	insert carry into quotient
	add.l	d6,d7	divisor > dividend, add back
	asl.l	#1,d7	 and shift dividend
	dbra	d4,ldiv_sr5	again till done
ldiv_sr7	not.l	d5	1's complement quotient
	move.l	d5,d7
	swap	d4
	lsr.l	d4,d7	shift right 0 < n < 32
	bcc	ldiv_sr8	check for rounding
	addq.l	#1,d7	round
ldiv_sr8	bmi	ldiv_sr10	overflow if msb set
	tst.w	d3	check sign
	beq	ldiv_sr11       OK if positive
	neg.l	d7	negate if not
	bra	ldiv_sr11
	
ldiv_sr10	move.l	#infinity,d7	set d7 = infinity
	bra	ldiv_sr11

ldiv_sr9	move.l	#0,d7	set d7 = 0
ldiv_sr11	movem.l	(a7)+,d3-5	restore register
	rts
