	cpu	"r65c"
immed	equ	$55
direct	equ	$44
extend	equ	$1234
	adc	# immed
	adc	( direct, x )
	adc	(direct)
	adc	(direct),y
	adc	direct
	adc	direct,x
	adc	extend
	adc	extend,x
	adc	extend,y
	and	# immed
	and	( direct, x )
	and	(direct)
	and	(direct),y
	and	direct
	and	direct,x
	and	extend
	and	extend,x
	and	extend,y
	asl	a
	asl	direct
	asl	direct,x
	asl	extend
	asl	extend,x
	bbr0	direct, jmpdst
	bbr1	direct, jmpdst
	bbr2	direct, jmpdst
	bbr3	direct, jmpdst
	bbr4	direct, jmpdst
	bbr5	direct, jmpdst
	bbr6	direct, jmpdst
	bbr7	direct, jmpdst
	bbs0	direct, jmpdst
	bbs1	direct, jmpdst
	bbs2	direct, jmpdst
	bbs3	direct, jmpdst
	bbs4	direct, jmpdst
	bbs5	direct, jmpdst
	bbs6	direct, jmpdst
	bbs7	direct, jmpdst
jmpdst	bcc	jmpdst
	bcs	jmpdst
	beq	jmpdst
	bge	jmpdst
	bit	# immed
	bit	direct
	bit	direct ,x
	bit	extend
	bit	extend, x
	blt	jmpdst
	bmi	jmpdst
	bne	jmpdst
	bpl	jmpdst
	bra	jmpdst
	brk
	brk	#99
	bvc	jmpdst
	bvs	jmpdst
	clc
	cld
	cli
	clv
	cmp	# immed
	cmp	( direct, x )
	cmp	(direct)
	cmp	(direct),y
	cmp	direct
	cmp	direct,x
	cmp	extend
	cmp	extend,x
	cmp	extend,y
	cpx	# immed
	cpx	direct
	cpx	extend
	cpy	# immed
	cpy	direct
	cpy	extend
	dec	a
	dec	direct
	dec	direct,x
	dec	extend
	dec	extend,x
	dex
	dey
	eor	# immed
	eor	( direct, x )
	eor	(direct)
	eor	(direct),y
	eor	direct
	eor	direct,x
	eor	extend
	eor	extend,x
	eor	extend,y
	inc	a
	inc	direct
	inc	direct,x
	inc	extend
	inc	extend,x
	inx
	iny
	jmp	(jmpdst)
	jmp	(jmpdst,x)
	jmp	jmpdst
	jsr	jmpdst
	lda	# immed
	lda	( direct, x )
	lda	(direct)
	lda	(direct),y
	lda	direct
	lda	direct,x
	lda	extend
	lda	extend,x
	lda	extend,y
	ldx	# immed
	ldx	direct
	ldx	direct ,y
	ldx	extend
	ldx	extend, y
	ldy	# immed
	ldy	direct
	ldy	direct ,x
	ldy	extend
	ldy	extend, x
	lsr	a
	lsr	direct
	lsr	direct,x
	lsr	extend
	lsr	extend,x
	mul
	nop
	ora	# immed
	ora	( direct, x )
	ora	(direct)
	ora	(direct),y
	ora	direct
	ora	direct,x
	ora	extend
	ora	extend,x
	ora	extend,y
	pha
	php
	phx
	phy
	pla
	plp
	plx
	ply
	rmb0	direct
	rmb1	direct
	rmb2	direct
	rmb3	direct
	rmb4	direct
	rmb5	direct
	rmb6	direct
	rmb7	direct
	rol	a
	rol	direct
	rol	direct,x
	rol	extend
	rol	extend,x
	ror	a
	ror	direct
	ror	direct,x
	ror	extend
	ror	extend,x
	rti
	rts
	sbc	# immed
	sbc	( direct, x )
	sbc	(direct)
	sbc	(direct),y
	sbc	direct
	sbc	direct,x
	sbc	extend
	sbc	extend,x
	sbc	extend,y
	sec
	sed
	sei
	smb0	direct
	smb1	direct
	smb2	direct
	smb3	direct
	smb4	direct
	smb5	direct
	smb6	direct
	smb7	direct
	sta	( direct, x )
	sta	(direct)
	sta	(direct),y
	sta	direct
	sta	direct,x
	sta	extend
	sta	extend,x
	sta	extend,y
	stx	direct
	stx	direct,y
	stx	extend
	sty	direct
	sty	direct,x
	sty	extend
	stz	direct
	stz	direct ,x
	stz	extend
	stz	extend, x
	tax
	tay
	trb	direct
	trb	extend
	tsb	direct
	tsb	extend
	tsx
	txa
	txs
	tya
