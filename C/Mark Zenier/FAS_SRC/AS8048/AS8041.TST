	cpu	"8041"
immed	equ	$77
	add	a, # immed
	add	a, @ r0
	add	a, @ r1
	add	a, r0
	add	a, r1
	add	a, r2
	add	a, r3
	add	a, r4
	add	a, r5
	add	a, r6
	add	a, r7
	addc	a, # immed
	addc	a, @ r0
	addc	a, @ r1
	addc	a, r0
	addc	a, r1
	addc	a, r2
	addc	a, r3
	addc	a, r4
	addc	a, r5
	addc	a, r6
	addc	a, r7
	anl	a, # immed
	anl	a, @ r0
	anl	a, @ r1
	anl	a, r0
	anl	a, r1
	anl	a, r2
	anl	a, r3
	anl	a, r4
	anl	a, r5
	anl	a, r6
	anl	a, r7
	anl	p1, # immed
	anl	p2, # immed
	anld	p4, a
	anld	p5, a
	anld	p6, a
	anld	p7, a
	call	$023
	call	$123
	call	$223
	call	$323
	call	$423
	call	$523
	call	$623
	call	$723
	clr	a
	clr	c
	clr	f0
	clr	f1
	cpl	a
	cpl	c
	cpl	f0
	cpl	f1
	da	a
	dec	a
	dec	r0
	dec	r1
	dec	r2
	dec	r3
	dec	r4
	dec	r5
	dec	r6
	dec	r7
	dis	i
	dis	tcnti
	djnz	r0 , dest
	djnz	r1 , dest
	djnz	r2 , dest
	djnz	r3 , dest
	djnz	r4 , dest
	djnz	r5 , dest
	djnz	r6 , dest
	djnz	r7 , dest
	en	dma
	en	flags
	en	i
	en	tcnti
	in	a, dbb
dest	in	a, p1
	in	a, p2
	inc	@ r0
	inc	@ r1
	inc	a
	inc	r0
	inc	r1
	inc	r2
	inc	r3
	inc	r4
	inc	r5
	inc	r6
	inc	r7
	jb0	dest
	jb1	dest
	jb2	dest
	jb3	dest
	jb4	dest
	jb5	dest
	jb6	dest
	jb7	dest
	jc	dest
	jf0	dest
	jf1	dest
	jmp	$023
	jmp	$123
	jmp	$223
	jmp	$323
	jmp	$423
	jmp	$523
	jmp	$623
	jmp	$723
	jmpp	@a
	jnc	dest
	jnibf	dest
	jnt0	dest
	jnt1	dest
	jnz	dest
	jobf	dest
	jt0	dest
	jt1	dest
	jtf	dest
	jz	dest
	mov	@ r0, # immed
	mov	@ r0, a
	mov	@ r1, # immed
	mov	@ r1, a
	mov	a, # immed
	mov	a, @ r0
	mov	a, @ r1
	mov	a, psw
	mov	a, r0
	mov	a, r1
	mov	a, r2
	mov	a, r3
	mov	a, r4
	mov	a, r5
	mov	a, r6
	mov	a, r7
	mov	a, t
	mov	psw, a
	mov	r0, # immed
	mov	r0, a
	mov	r1, # immed
	mov	r1, a
	mov	r2, # immed
	mov	r2, a
	mov	r3, # immed
	mov	r3, a
	mov	r4, # immed
	mov	r4, a
	mov	r5, # immed
	mov	r5, a
	mov	r6, # immed
	mov	r6, a
	mov	r7, # immed
	mov	r7, a
	mov	sts, a
	mov	t, a
	movd	a, p4
	movd	a, p5
	movd	a, p6
	movd	a, p7
	movd	p4, a
	movd	p5, a
	movd	p6, a
	movd	p7, a
	movp	a, @a
	movp3	a, @a
	nop
	orl	a, # immed
	orl	a, @ r0
	orl	a, @ r1
	orl	a, r0
	orl	a, r1
	orl	a, r2
	orl	a, r3
	orl	a, r4
	orl	a, r5
	orl	a, r6
	orl	a, r7
	orl	p1, # immed
	orl	p2, # immed
	orld	p4, a
	orld	p5, a
	orld	p6, a
	orld	p7, a
	out	dbb, a
	outl	p1, a
	outl	p2, a
	ret
	retr
	rl	a
	rlc	a
	rr	a
	rrc	a
	sel	rb0
	sel	rb1
	stop	tcnt
	strt	cnt
	strt	t
	swap	a
	xch	a, @ r0
	xch	a, @ r1
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
	xrl	a, # immed
	xrl	a, @ r0
	xrl	a, @ r1
	xrl	a, r0
	xrl	a, r1
	xrl	a, r2
	xrl	a, r3
	xrl	a, r4
	xrl	a, r5
	xrl	a, r6
	xrl	a, r7
