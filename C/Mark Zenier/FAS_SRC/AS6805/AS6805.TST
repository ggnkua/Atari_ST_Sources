	org	$1234
immed	equ	$55
direct	equ	$22
extend	equ	$7654
index1	equ	$77
index2	equ	$3333

	adc	#immed
	adc	direct
	adc	extend
	adc	,x
	adc	index1,x
	adc	index2,x
	add	#immed
	add	direct
	add	extend
	add	,x
	add	index1,x
	add	index2,x
	and	#immed
	and	direct
	and	extend
	and	,x
	and	index1,x
	and	index2,x
	asl	direct
	asl	,x
	asl	index1,x
	asla
	aslx
	asr	direct
	asr	,x
	asr	index1,x
	asra
	asrx
	bcc	*-23
	bclr	0,direct
	bclr	1,direct
	bclr	2,direct
	bclr	3,direct
	bclr	4,direct
	bclr	5,direct
	bclr	6,direct
	bclr	7,direct
	bcs	*-23
	beq	*-23
	bhcc	*-23
	bhcs	*-23
	bhi	*-23
	bhs	*-23
	bih	*-23
	bil	*-23
	bit	#immed
	bit	direct
	bit	extend
	bit	,x
	bit	index1,x
	bit	index2,x
	blo	*-23
	bls	*-23
	bmc	*-23
	bmi	*-23
	bms	*-23
	bne	*-23
	bpl	*-23
	bra	*-23
	brclr	0,direct,*-23
	brclr	1,direct,*-23
	brclr	2,direct,*-23
	brclr	3,direct,*-23
	brclr	4,direct,*-23
	brclr	5,direct,*-23
	brclr	6,direct,*-23
	brclr	7,direct,*-23
	brn	*-23
	brset	0,direct,*-23
	brset	1,direct,*-23
	brset	2,direct,*-23
	brset	3,direct,*-23
	brset	4,direct,*-23
	brset	5,direct,*-23
	brset	6,direct,*-23
	brset	7,direct,*-23
	bset	0,direct
	bset	1,direct
	bset	2,direct
	bset	3,direct
	bset	4,direct
	bset	5,direct
	bset	6,direct
	bset	7,direct
	bsr	*-23
	clc
	cli
	clr	direct
	clr	,x
	clr	index1,x
	clra
	clrx
	cmp	#immed
	cmp	direct
	cmp	extend
	cmp	,x
	cmp	index1,x
	cmp	index2,x
	com	direct
	com	,x
	com	index1,x
	coma
	comx
	cpx	#immed
	cpx	direct
	cpx	extend
	cpx	,x
	cpx	index1,x
	cpx	index2,x
	dec	direct
	dec	,x
	dec	index1,x
	deca
	decx
	eor	#immed
	eor	direct
	eor	extend
	eor	,x
	eor	index1,x
	eor	index2,x
	inc	direct
	inc	,x
	inc	index1,x
	inca
	incx
	jmp	direct
	jmp	extend
	jmp	,x
	jmp	index1,x
	jmp	index2,x
	jsr	direct
	jsr	extend
	jsr	,x
	jsr	index1,x
	jsr	index2,x
	lda	#immed
	lda	direct
	lda	extend
	lda	,x
	lda	index1,x
	lda	index2,x
	ldx	#immed
	ldx	direct
	ldx	extend
	ldx	,x
	ldx	index1,x
	ldx	index2,x
	lsl	direct
	lsl	,x
	lsl	index1,x
	lsla
	lslx
	lsr	direct
	lsr	,x
	lsr	index1,x
	lsra
	lsrx
	neg	direct
	neg	,x
	neg	index1,x
	nega
	negx
	nop
	ora	#immed
	ora	direct
	ora	extend
	ora	,x
	ora	index1,x
	ora	index2,x
	rol	direct
	rol	,x
	rol	index1,x
	rola
	rolx
	ror	direct
	ror	,x
	ror	index1,x
	rora
	rorx
	rsp
	rti
	rts
	sbc	#immed
	sbc	direct
	sbc	extend
	sbc	,x
	sbc	index1,x
	sbc	index2,x
	sec
	sei
	sta	direct
	sta	extend
	sta	,x
	sta	index1,x
	sta	index2,x
	stx	direct
	stx	extend
	stx	,x
	stx	index1,x
	stx	index2,x
	sub	#immed
	sub	direct
	sub	extend
	sub	,x
	sub	index1,x
	sub	index2,x
	swi
	tax
	tst	direct
	tst	,x
	tst	index1,x
	tsta
	tstx
	txa
