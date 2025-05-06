immed	equ	98h
srcreg	equ	38h
dstreg	equ	30h
longoff	equ	7654h
shortoff	equ	33h
extern	equ	1234h
srcreg2	equ	44h
shiftcount	equ	10
	add	dstreg, #immed
	add	dstreg, [ srcreg ]
	add	dstreg, [ srcreg ] +
	add	dstreg, extern
	add	dstreg, longoff [ srcreg ]
	add	dstreg, shortoff [ srcreg ]
	add	dstreg, srcreg
	add	dstreg, srcreg2, #immed
	add	dstreg, srcreg2, [ srcreg ]
	add	dstreg, srcreg2, [ srcreg ] +
	add	dstreg, srcreg2, extern
	add	dstreg, srcreg2, longoff [ srcreg ]
	add	dstreg, srcreg2, shortoff [ srcreg ]
	add	dstreg, srcreg2, srcreg
	addb	dstreg, #immed
	addb	dstreg, [ srcreg ]
	addb	dstreg, [ srcreg ] +
	addb	dstreg, extern
	addb	dstreg, longoff [ srcreg ]
	addb	dstreg, shortoff [ srcreg ]
	addb	dstreg, srcreg
	addb	dstreg, srcreg2, #immed
	addb	dstreg, srcreg2, [ srcreg ]
	addb	dstreg, srcreg2, [ srcreg ] +
	addb	dstreg, srcreg2, extern
	addb	dstreg, srcreg2, longoff [ srcreg ]
	addb	dstreg, srcreg2, shortoff [ srcreg ]
	addb	dstreg, srcreg2, srcreg
	addc	dstreg, #immed
	addc	dstreg, [ srcreg ]
	addc	dstreg, [ srcreg ] +
	addc	dstreg, extern
	addc	dstreg, longoff [ srcreg ]
	addc	dstreg, shortoff [ srcreg ]
	addc	dstreg, srcreg
	addcb	dstreg, #immed
	addcb	dstreg, [ srcreg ]
	addcb	dstreg, [ srcreg ] +
	addcb	dstreg, extern
	addcb	dstreg, longoff [ srcreg ]
	addcb	dstreg, shortoff [ srcreg ]
	addcb	dstreg, srcreg
	and	dstreg, #immed
	and	dstreg, [ srcreg ]
	and	dstreg, [ srcreg ] +
	and	dstreg, extern
	and	dstreg, longoff [ srcreg ]
	and	dstreg, shortoff [ srcreg ]
	and	dstreg, srcreg
	and	dstreg, srcreg2, #immed
	and	dstreg, srcreg2, [ srcreg ]
	and	dstreg, srcreg2, [ srcreg ] +
	and	dstreg, srcreg2, extern
	and	dstreg, srcreg2, longoff [ srcreg ]
	and	dstreg, srcreg2, shortoff [ srcreg ]
	and	dstreg, srcreg2, srcreg
	andb	dstreg, #immed
	andb	dstreg, [ srcreg ]
	andb	dstreg, [ srcreg ] +
	andb	dstreg, extern
	andb	dstreg, longoff [ srcreg ]
	andb	dstreg, shortoff [ srcreg ]
	andb	dstreg, srcreg
	andb	dstreg, srcreg2, #immed
	andb	dstreg, srcreg2, [ srcreg ]
	andb	dstreg, srcreg2, [ srcreg ] +
	andb	dstreg, srcreg2, extern
	andb	dstreg, srcreg2, longoff [ srcreg ]
	andb	dstreg, srcreg2, shortoff [ srcreg ]
	andb	dstreg, srcreg2, srcreg
	br	[ srcreg ]
	clrc
	clr	dstreg
	clrb	dstreg
	clrvt
	cmp	dstreg, #immed
	cmp	dstreg, [ srcreg ]
	cmp	dstreg, [ srcreg ] +
	cmp	dstreg, extern
	cmp	dstreg, longoff [ srcreg ]
	cmp	dstreg, shortoff [ srcreg ]
	cmp	dstreg, srcreg
	cmpb	dstreg, #immed
	cmpb	dstreg, [ srcreg ]
	cmpb	dstreg, [ srcreg ] +
	cmpb	dstreg, extern
	cmpb	dstreg, longoff [ srcreg ]
	cmpb	dstreg, shortoff [ srcreg ]
	cmpb	dstreg, srcreg
	dec	dstreg
	decb	dstreg
	di
	div	dstreg, #immed
	div	dstreg, [ srcreg ]
	div	dstreg, [ srcreg ] +
	div	dstreg, extern
	div	dstreg, longoff [ srcreg ]
	div	dstreg, shortoff [ srcreg ]
	div	dstreg, srcreg
	divb	dstreg, #immed
	divb	dstreg, [ srcreg ]
	divb	dstreg, [ srcreg ] +
	divb	dstreg, extern
	divb	dstreg, longoff [ srcreg ]
	divb	dstreg, shortoff [ srcreg ]
	divb	dstreg, srcreg
	divu	dstreg, #immed
	divu	dstreg, [ srcreg ]
	divu	dstreg, [ srcreg ] +
	divu	dstreg, extern
	divu	dstreg, longoff [ srcreg ]
	divu	dstreg, shortoff [ srcreg ]
	divu	dstreg, srcreg
	divub	dstreg, #immed
	divub	dstreg, [ srcreg ]
	divub	dstreg, [ srcreg ] +
	divub	dstreg, extern
	divub	dstreg, longoff [ srcreg ]
	divub	dstreg, shortoff [ srcreg ]
	divub	dstreg, srcreg
	djnz	srcreg, jmpdst
	ei
	ext	dstreg
	extb	dstreg
	inc	dstreg
	incb	dstreg
	jbc	srcreg, 0, jmpdst
	jbc	srcreg, 1, jmpdst
	jbc	srcreg, 2, jmpdst
	jbc	srcreg, 3, jmpdst
	jbc	srcreg, 4, jmpdst
	jbc	srcreg, 5, jmpdst
	jbc	srcreg, 6, jmpdst
	jbc	srcreg, 7, jmpdst
	jbs	srcreg, 0, jmpdst
	jbs	srcreg, 1, jmpdst
	jbs	srcreg, 2, jmpdst
	jbs	srcreg, 3, jmpdst
	jbs	srcreg, 4, jmpdst
	jbs	srcreg, 5, jmpdst
	jbs	srcreg, 6, jmpdst
	jbs	srcreg, 7, jmpdst
	jc	jmpdst
jmpdst	je	jmpdst
	jge	jmpdst
	jgt	jmpdst
	jh	jmpdst
	jle	jmpdst
	jlt	jmpdst
	jnc	jmpdst
	jne	jmpdst
	jnh	jmpdst
	jnst	jmpdst
	jnv	jmpdst
	jnvt	jmpdst
	jst	jmpdst
	jv	jmpdst
	jvt	jmpdst
	lcall	jmpdst
	ld	dstreg, #immed
	ld	dstreg, [ srcreg ]
	ld	dstreg, [ srcreg ] +
	ld	dstreg, extern
	ld	dstreg, longoff [ srcreg ]
	ld	dstreg, shortoff [ srcreg ]
	ld	dstreg, srcreg
	ldb	dstreg, #immed
	ldb	dstreg, [ srcreg ]
	ldb	dstreg, [ srcreg ] +
	ldb	dstreg, extern
	ldb	dstreg, longoff [ srcreg ]
	ldb	dstreg, shortoff [ srcreg ]
	ldb	dstreg, srcreg
	ldbse	dstreg, #immed
	ldbse	dstreg, [ srcreg ]
	ldbse	dstreg, [ srcreg ] +
	ldbse	dstreg, extern
	ldbse	dstreg, longoff [ srcreg ]
	ldbse	dstreg, shortoff [ srcreg ]
	ldbse	dstreg, srcreg
	ldbze	dstreg, #immed
	ldbze	dstreg, [ srcreg ]
	ldbze	dstreg, [ srcreg ] +
	ldbze	dstreg, extern
	ldbze	dstreg, longoff [ srcreg ]
	ldbze	dstreg, shortoff [ srcreg ]
	ldbze	dstreg, srcreg
	ljmp	jmpdst
	mul	dstreg, #immed
	mul	dstreg, [ srcreg ]
	mul	dstreg, [ srcreg ] +
	mul	dstreg, extern
	mul	dstreg, longoff [ srcreg ]
	mul	dstreg, shortoff [ srcreg ]
	mul	dstreg, srcreg
	mul	dstreg, srcreg2, #immed
	mul	dstreg, srcreg2, [ srcreg ]
	mul	dstreg, srcreg2, [ srcreg ] +
	mul	dstreg, srcreg2, extern
	mul	dstreg, srcreg2, longoff [ srcreg ]
	mul	dstreg, srcreg2, shortoff [ srcreg ]
	mul	dstreg, srcreg2, srcreg
	mulb	dstreg, #immed
	mulb	dstreg, [ srcreg ]
	mulb	dstreg, [ srcreg ] +
	mulb	dstreg, extern
	mulb	dstreg, longoff [ srcreg ]
	mulb	dstreg, shortoff [ srcreg ]
	mulb	dstreg, srcreg
	mulb	dstreg, srcreg2, #immed
	mulb	dstreg, srcreg2, [ srcreg ]
	mulb	dstreg, srcreg2, [ srcreg ] +
	mulb	dstreg, srcreg2, extern
	mulb	dstreg, srcreg2, longoff [ srcreg ]
	mulb	dstreg, srcreg2, shortoff [ srcreg ]
	mulb	dstreg, srcreg2, srcreg
	mulu	dstreg, #immed
	mulu	dstreg, [ srcreg ]
	mulu	dstreg, [ srcreg ] +
	mulu	dstreg, extern
	mulu	dstreg, longoff [ srcreg ]
	mulu	dstreg, shortoff [ srcreg ]
	mulu	dstreg, srcreg
	mulu	dstreg, srcreg2, #immed
	mulu	dstreg, srcreg2, [ srcreg ]
	mulu	dstreg, srcreg2, [ srcreg ] +
	mulu	dstreg, srcreg2, extern
	mulu	dstreg, srcreg2, longoff [ srcreg ]
	mulu	dstreg, srcreg2, shortoff [ srcreg ]
	mulu	dstreg, srcreg2, srcreg
	mulub	dstreg, #immed
	mulub	dstreg, [ srcreg ]
	mulub	dstreg, [ srcreg ] +
	mulub	dstreg, extern
	mulub	dstreg, longoff [ srcreg ]
	mulub	dstreg, shortoff [ srcreg ]
	mulub	dstreg, srcreg
	mulub	dstreg, srcreg2, #immed
	mulub	dstreg, srcreg2, [ srcreg ]
	mulub	dstreg, srcreg2, [ srcreg ] +
	mulub	dstreg, srcreg2, extern
	mulub	dstreg, srcreg2, longoff [ srcreg ]
	mulub	dstreg, srcreg2, shortoff [ srcreg ]
	mulub	dstreg, srcreg2, srcreg
	neg	dstreg
	negb	dstreg
	nop
	norml	dstreg, srcreg
	not	dstreg
	notb	dstreg
	or	dstreg, #immed
	or	dstreg, [ srcreg ]
	or	dstreg, [ srcreg ] +
	or	dstreg, extern
	or	dstreg, longoff [ srcreg ]
	or	dstreg, shortoff [ srcreg ]
	or	dstreg, srcreg
	orb	dstreg, #immed
	orb	dstreg, [ srcreg ]
	orb	dstreg, [ srcreg ] +
	orb	dstreg, extern
	orb	dstreg, longoff [ srcreg ]
	orb	dstreg, shortoff [ srcreg ]
	orb	dstreg, srcreg
	pop	[ srcreg ]
	pop	[ srcreg ] +
	pop	extern
	pop	longoff [ srcreg ]
	pop	shortoff [ srcreg ]
	pop	srcreg
	popf
	push	#immed
	push	[ srcreg ]
	push	[ srcreg ] +
	push	extern
	push	longoff [ srcreg ]
	push	shortoff [ srcreg ]
	push	srcreg
	pushf
	ret
	rst
	scall	jmpdst
	setc
	shl	dstreg, # shiftcount
	shl	dstreg, srcreg
	shlb	dstreg, # shiftcount
	shlb	dstreg, srcreg
	shll	dstreg, # shiftcount
	shll	dstreg, srcreg
	shr	dstreg, # shiftcount
	shr	dstreg, srcreg
	shra	dstreg, # shiftcount
	shra	dstreg, srcreg
	shrab	dstreg, # shiftcount
	shrab	dstreg, srcreg
	shral	dstreg, # shiftcount
	shral	dstreg, srcreg
	shrb	dstreg, # shiftcount
	shrb	dstreg, srcreg
	shrl	dstreg, # shiftcount
	shrl	dstreg, srcreg
	sjmp	jmpdst
	skip	dstreg
	st	dstreg, [ srcreg ]
	st	dstreg, [ srcreg ] +
	st	dstreg, extern
	st	dstreg, longoff [ srcreg ]
	st	dstreg, shortoff [ srcreg ]
	st	dstreg, srcreg
	stb	dstreg, [ srcreg ]
	stb	dstreg, [ srcreg ] +
	stb	dstreg, extern
	stb	dstreg, longoff [ srcreg ]
	stb	dstreg, shortoff [ srcreg ]
	stb	dstreg, srcreg
	sub	dstreg, #immed
	sub	dstreg, [ srcreg ]
	sub	dstreg, [ srcreg ] +
	sub	dstreg, extern
	sub	dstreg, longoff [ srcreg ]
	sub	dstreg, shortoff [ srcreg ]
	sub	dstreg, srcreg
	sub	dstreg, srcreg2, #immed
	sub	dstreg, srcreg2, [ srcreg ]
	sub	dstreg, srcreg2, [ srcreg ] +
	sub	dstreg, srcreg2, extern
	sub	dstreg, srcreg2, longoff [ srcreg ]
	sub	dstreg, srcreg2, shortoff [ srcreg ]
	sub	dstreg, srcreg2, srcreg
	subb	dstreg, #immed
	subb	dstreg, [ srcreg ]
	subb	dstreg, [ srcreg ] +
	subb	dstreg, extern
	subb	dstreg, longoff [ srcreg ]
	subb	dstreg, shortoff [ srcreg ]
	subb	dstreg, srcreg
	subb	dstreg, srcreg2, #immed
	subb	dstreg, srcreg2, [ srcreg ]
	subb	dstreg, srcreg2, [ srcreg ] +
	subb	dstreg, srcreg2, extern
	subb	dstreg, srcreg2, longoff [ srcreg ]
	subb	dstreg, srcreg2, shortoff [ srcreg ]
	subb	dstreg, srcreg2, srcreg
	subc	dstreg, #immed
	subc	dstreg, [ srcreg ]
	subc	dstreg, [ srcreg ] +
	subc	dstreg, extern
	subc	dstreg, longoff [ srcreg ]
	subc	dstreg, shortoff [ srcreg ]
	subc	dstreg, srcreg
	subcb	dstreg, #immed
	subcb	dstreg, [ srcreg ]
	subcb	dstreg, [ srcreg ] +
	subcb	dstreg, extern
	subcb	dstreg, longoff [ srcreg ]
	subcb	dstreg, shortoff [ srcreg ]
	subcb	dstreg, srcreg
	xor	dstreg, #immed
	xor	dstreg, [ srcreg ]
	xor	dstreg, [ srcreg ] +
	xor	dstreg, extern
	xor	dstreg, longoff [ srcreg ]
	xor	dstreg, shortoff [ srcreg ]
	xor	dstreg, srcreg
	xorb	dstreg, #immed
	xorb	dstreg, [ srcreg ]
	xorb	dstreg, [ srcreg ] +
	xorb	dstreg, extern
	xorb	dstreg, longoff [ srcreg ]
	xorb	dstreg, shortoff [ srcreg ]
	xorb	dstreg, srcreg
