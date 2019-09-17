* convert a long hex number to ascii string
* the number must be less than 10,000,000
* if it is the number defaults to 9,999,999

lhex_asc	movem.l	a0-a1,-(sp)
		cmp.l	#9999999,d0		number in range?
		ble.s	num_ok			yes
		move.l	#9999999,d0		default
num_ok		lea	num_buffer(a6),a0	buffer for ascii number
		moveq	#0,d4			clear reg
		move.l	#1000000,d1		number to divide by
		lea	div_1(pc),a1		new divider
num		moveq	#0,d2			clear counter
num0		cmp.l	d1,d0			number < divider?
		blo.s	num1			yes
		addq.w	#1,d2			inc counter
		sub.l	d1,d0			subtract divider
		bra.s	num0			loop back for more
num1		tst.w	d4			stored first digit?
		bne.s	num2			yes
		tst.w	d2			any result?
		beq.s	num4			no
		moveq	#1,d4			not first digit any more
num2		add.b	#$30,d2			convert to ascii number
num3		move.b	d2,(a0)+		number to string
num4		jmp	(a1)			get new divide number
div_1		move.l	#100000,d1		new divider
		lea	div_2(pc),a1		new divider routine
		bra.s	num
div_2		move.l	#10000,d1		new divider
		lea	div_3(pc),a1		new divider routine
		bra.s	num
div_3		move.l	#1000,d1		new divider
		lea	div_4(pc),a1		new routine
		bra.s	num
div_4		moveq	#100,d1			new divider
		lea	div_5(pc),a1		new routine
		bra.s	num
div_5		moveq	#10,d1			new divider
		lea	div_6(pc),a1		new routine
		bra.s	num
div_6		moveq	#1,d1			new divider
		lea	div_7(pc),a1		new routine
		bra.s	num

		divu	#10,d1			get new divider
		tst.w	d1			down to zero?
		bne.s	num			no

div_7		clr.b	(a0)			yes, null the string end
		movem.l	(sp)+,a0-a1
		rts

num_buffer	rs.l	3
