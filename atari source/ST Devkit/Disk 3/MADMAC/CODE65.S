;----------------
;
;    6502 Opcodes
;
;
	.6502

	.org	$f0
tmp:	ds.b	1
tmph:	ds.b	1
tmp1:	ds.b	1
tmp1h:	ds.b	1

	.org	$8000

	dc.w	$1234
	dc.b	12,34,56,78
	dc.b	'This is a test of the...',0
	dc.w	$1234,$5678,$9abc,@777

	adc	#immed
	adc	abs
	adc	tmp
	adc	(tmp,x)
	adc	(tmp),y
	adc	tmp,x
	adc	abs,x
	adc	abs,y

	and	#immed
	and	abs
	and	tmp
	and	(tmp,x)
	and	(tmp),y
	and	tmp,x
	and	abs,x
	and	abs,y

	asl	abs
	asl	tmp
	asl
	asl	tmp,x
	asl	abs,x

	bcc	where
	bcs	where
	beq	where
	bne	where
	bmi	where
	bpl	where
	bvc	where
	bvs	where

where:	bit	abs
	bit	tmp

	brk

	clc
	cld
	cli
	clv

	cmp	#immed
	cmp	abs
	cmp	tmp
	cmp	(tmp,x)
	cmp	(tmp),y
	cmp	tmp,x
	cmp	abs,x
	cmp	abs,y

	cpx	#immed
	cpx	abs
	cpx	tmp

	cpy	#immed
	cpy	abs
	cpy	tmp

	dec	abs
	dec	tmp
	dec	tmp,x
	dec	abs,x

	dex
	dey

	eor	#immed
	eor	abs
	eor	tmp
	eor	(tmp,x)
	eor	(tmp),y
	eor	tmp,x
	eor	abs,x
	eor	abs,y

	inc	abs
	inc	tmp
	inc	tmp,x
	inc	abs,x

	inx
	iny

	jmp	abs
	jmp	(abs)

	jsr	abs

	lda	#immed
	lda	abs
	lda	tmp
	lda	(tmp,x)
	lda	(tmp),y
	lda	tmp,x
	lda	abs,x
	lda	abs,y

	ldx	#immed
	ldx	abs
	ldx	tmp
	ldx	abs,y
	ldx	tmp,y

	ldy	#immed
	ldy	abs
	ldy	tmp
	ldy	abs,x
	ldy	tmp,x

	lsr	abs
	lsr	tmp
	lsr
	lsr	tmp,x
	lsr	abs,x

	nop

	ora	#immed
	ora	abs
	ora	tmp
	ora	(tmp,x)
	ora	(tmp),y
	ora	tmp,x
	ora	abs,x
	ora	abs,y

	pha
	php
	pla
	plp

	rol	abs
	rol	tmp
	rol
	rol	tmp,x
	rol	abs,x

	ror	abs
	ror	tmp
	ror
	ror	tmp,x
	ror	abs,x

	rti
	rts

	sbc	#immed
	sbc	abs
	sbc	tmp
	sbc	(tmp,x)
	sbc	(tmp),y
	sbc	tmp,x
	sbc	abs,x
	sbc	abs,y

	sec
	sed
	sei

	sta	abs
	sta	tmp
	sta	(tmp,x)
	sta	(tmp),y
	sta	tmp,x
	sta	abs,x
	sta	abs,y

	stx	abs
	stx	tmp
	stx	tmp,y

	sty	abs
	sty	tmp
	sty	tmp,x

	tax
	tay
	tsx
	txa
	txs
	tya


abs	=	$5ba
immed	=	$11
