bit	equ 	$88
dirbit	equ	$8d
direct	equ	$44
immed	equ	$55
srcdirect	equ	$33
	acall	addr
	add	a, #immed
	add	a, @ r0
	add	a, @ r1
	add	a, direct
	add	a, r0
	add	a, r1
	add	a, r2
	add	a, r3
	add	a, r4
	add	a, r5
	add	a, r6
	add	a, r7
	addc	a, #immed
	addc	a, @ r0
	addc	a, @ r1
	addc	a, direct
	addc	a, r0
	addc	a, r1
	addc	a, r2
	addc	a, r3
	addc	a, r4
	addc	a, r5
	addc	a, r6
	addc	a, r7
	ajmp	addr
	anl	a, #immed
	anl	a, @ r0
	anl	a, @ r1
	anl	a, direct
	anl	a, r0
	anl	a, r1
	anl	a, r2
	anl	a, r3
	anl	a, r4
	anl	a, r5
	anl	a, r6
	anl	a, r7
	anl	c, /bit.5
	anl	c, /dirbit
	anl	c, bit.5
	anl	c, dirbit
	anl	direct, # immed
	anl	direct, a
	cjne	@ r0, # immed, addr
	cjne	@ r1, # immed, addr
	cjne	a, #immed, addr
	cjne	a, direct, addr
	cjne	r0, # immed, addr
	cjne	r1, # immed, addr
	cjne	r2, # immed, addr
	cjne	r3, # immed, addr
	cjne	r4, # immed, addr
	cjne	r5, # immed, addr
	cjne	r6, # immed, addr
	cjne	r7, # immed, addr
	clr	a
	clr	bit.5
	clr	c
	clr	dirbit
	cpl	a
	cpl	bit.5
	cpl	c
	cpl	dirbit
	da	a
	dec	@ r0
	dec	@ r1
	dec	a
	dec	direct
	dec	r0
	dec	r1
	dec	r2
	dec	r3
	dec	r4
	dec	r5
	dec	r6
	dec	r7
	div	ab
	djnz	direct, addr
	djnz	r0, addr
	djnz	r1, addr
	djnz	r2, addr
	djnz	r3, addr
	djnz	r4, addr
	djnz	r5, addr
	djnz	r6, addr
	djnz	r7, addr
	inc	@ r0
	inc	@ r1
	inc	a
	inc	direct
	inc	dptr
	inc	r0
	inc	r1
	inc	r2
	inc	r3
	inc	r4
addr	inc	r5
	inc	r6
	inc	r7
	jb	bit.5, addr
	jb	dirbit, addr
	jbc	bit.5, addr
	jbc	dirbit, addr
	jc	addr
	jmp	@a+dptr
	jnb	bit.5, addr
	jnb	dirbit, addr
	jnc	addr
	jnz	addr
	jz	addr
	lcall	addr
	ljmp	addr
	mov	@ r0, # immed
	mov	@ r0, a
	mov	@ r0, direct
	mov	@ r1, # immed
	mov	@ r1, a
	mov	@ r1, direct
	mov	a, #immed
	mov	a, @ r0
	mov	a, @ r1
	mov	a, direct
	mov	a, r0
	mov	a, r1
	mov	a, r2
	mov	a, r3
	mov	a, r4
	mov	a, r5
	mov	a, r6
	mov	a, r7
	mov	bit.5, c
	mov	c, bit.5
	mov	c, dirbit
	mov	dirbit, c
	mov	direct, # immed
	mov	direct, @ r0
	mov	direct, @ r1
	mov	direct, a
	mov	direct, r0
	mov	direct, r1
	mov	direct, r2
	mov	direct, r3
	mov	direct, r4
	mov	direct, r5
	mov	direct, r6
	mov	direct, r7
	mov	direct, srcdirect
	mov	dptr, #immed
	mov	r0, # immed
	mov	r0, a
	mov	r0, direct
	mov	r1, # immed
	mov	r1, a
	mov	r1, direct
	mov	r2, # immed
	mov	r2, a
	mov	r2, direct
	mov	r3, # immed
	mov	r3, a
	mov	r3, direct
	mov	r4, # immed
	mov	r4, a
	mov	r4, direct
	mov	r5, # immed
	mov	r5, a
	mov	r5, direct
	mov	r6, # immed
	mov	r6, a
	mov	r6, direct
	mov	r7, # immed
	mov	r7, a
	mov	r7, direct
	movc	a, @a+dptr
saddr	movc	a, @a+pc
	movx	@dptr, a
	movx	@r0, a
	movx	@r1, a
	movx	a, @ r0
	movx	a, @ r1
	movx	a, @dptr
	mul	ab
	nop
	orl	a, #immed
	orl	a, @ r0
	orl	a, @ r1
	orl	a, direct
	orl	a, r0
	orl	a, r1
	orl	a, r2
	orl	a, r3
	orl	a, r4
	orl	a, r5
	orl	a, r6
	orl	a, r7
	orl	c, /bit.5
	orl	c, /dirbit
	orl	c, bit.5
	orl	c, dirbit
	orl	direct, # immed
	orl	direct, a
	pop	direct
	push	direct
	ret
	reti
	rl	a
	rlc	a
	rr	a
	rrc	a
	setb	bit.5
	setb	c
	setb	dirbit
	sjmp	saddr
	subb	a, #immed
	subb	a, @ r0
	subb	a, @ r1
	subb	a, direct
	subb	a, r0
	subb	a, r1
	subb	a, r2
	subb	a, r3
	subb	a, r4
	subb	a, r5
	subb	a, r6
	subb	a, r7
	swap	a
	xch	a, @ r0
	xch	a, @ r1
	xch	a, direct
	xch	a, r0
	xch	a, r1
	xch	a, r2
	xch	a, r3
	xch	a, r4
	xch	a, r5
	xch	a, r6
	xch	a, r7
	xchd	a, @ r0
	xchd	a, @ r1
	xrl	a, #immed
	xrl	a, @ r0
	xrl	a, @ r1
	xrl	a, direct
	xrl	a, r0
	xrl	a, r1
	xrl	a, r2
	xrl	a, r3
	xrl	a, r4
	xrl	a, r5
	xrl	a, r6
	xrl	a, r7
	xrl	direct, # immed
	xrl	direct, a
