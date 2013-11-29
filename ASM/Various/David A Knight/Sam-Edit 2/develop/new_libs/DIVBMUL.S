;Long word division (d1 divided by d0)
;ENTRY d0.l=Dividend
;      d1.l=Divisor
;EXIT  d0=Quotient
;      d1=Remainder

	SECTION	text

long_div	movem.l	d2-d3,-(sp)
	tst.l	d0	chk if div by 0
	beq	long_div6	bra if error
	move	#1,d2
long_div1	btst	#31,d0
	bne	long_div2
	lsl.l	#1,d0
	add	#1,d2
	bra	long_div1

long_div2	clr	d3
long_div3	lsl.l	#1,d3
	sub.l	d0,d1
	bcs	long_div4
	bset	#0,d3
long_div5	lsr.l	#1,d0
	sub	#1,d2
	bne	long_div3
	move.l	d3,d0
long_div6	movem.l	(sp)+,d2-d3
	rts

long_div4	add.l	d0,d1
	bra	long_div5

;Long word multiplication (d0 multiplied by d1)
;ENTRY d0.L=First operand
;      d1.L=Second operand
;EXIT  d0.L=Product

long_mul	movem.l	d1-d3,-(sp)
	move.l	d1,d3
	clr.l	d1
	move	#32-1,d2
long_mul1	lsl.l	#1,d1
	lsl.l	#1,d3
	bcc	long_mul2
	add.l	d0,d1
long_mul2	dbra	d2,long_mul1
	move.l	d1,d0
	movem.l	(sp)+,d1-d3
	rts
