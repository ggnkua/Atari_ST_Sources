	org $99
m	equ	$40
d	fdb	123H
	org	$1234
e	fdb	678
	org	$2000
o	set	$66
i	equ	32H
	aba 
	abx 
	aby 
	adc a #i 
	adc a d 
	adc a e 
	adc a o,x 
	adc a o,y 
	adc b #i 
	adc b d 
	adc b e 
	adc b o,x 
	adc b o,y 
	adca #i 
	adca d 
	adca e 
	adca o,x 
	adca o,y 
	adcb #i 
	adcb d 
	adcb e 
	adcb o,x 
	adcb o,y 
	add a #i 
	add a d 
	add a e 
	add a o,x 
	add a o,y 
	add b #i 
	add b d 
	add b e 
	add b o,x 
	add b o,y 
	adda #i 
	adda d 
	adda e 
	adda o,x 
	adda o,y 
	addb #i 
	addb d 
	addb e 
	addb o,x 
	addb o,y 
	addd #i 
	addd d 
	addd e 
	addd o,x 
	addd o,y 
	and a #i 
	and a d 
	and a e 
	and a o,x 
	and a o,y 
	and b #i 
	and b d 
	and b e 
	and b o,x 
	and b o,y 
	anda #i 
	anda d 
	anda e 
	anda o,x 
	anda o,y 
	andb #i 
	andb d 
	andb e 
	andb o,x 
	andb o,y 
	asl a 
	asl b 
	asl e 
	asl o,x 
	asl o,y 
	asla 
	aslb 
	asld 
	asr a 
	asr b 
	asr e 
	asr o,x 
	asr o,y 
	asra 
	asrb 
	bcc *-4 
	bclr d,m 
	bclr o,x,m 
	bclr o,y,m 
	bcs *-4 
	beq *-4 
	bge *-4 
	bgt *-4 
	bhi *-4 
	bhs *-4 
	bit a #i 
	bit a d 
	bit a e 
	bit a o,x 
	bit a o,y 
	bit b #i 
	bit b d 
	bit b e 
	bit b o,x 
	bit b o,y 
	bita #i 
	bita d 
	bita e 
	bita o,x 
	bita o,y 
	bitb #i 
	bitb d 
	bitb e 
	bitb o,x 
	bitb o,y 
	ble *-4 
	blo *-4 
	bls *-4 
	blt *-4 
	bmi *-4 
	bne *-4 
	bpl *-4 
	bra *-4 
	brclr d,m,*+5
	brclr o,x,m,*+5
	brclr o,y,m,*+5
	brn *-4 
	brset d,m,*+5 
	brset o,x,m,*+5
	brset o,y,m,*+5
	bset d,m
	bset o,x,m
	bset o,y,m 
	bsr *-4 
	bvc *-4 
	bvs *-4 
	cba 
	clc 
	cli 
	clr a 
	clr b 
	clr e 
	clr o,x 
	clr o,y 
	clra 
	clrb 
	clv 
	cmp a #i 
	cmp a d 
	cmp a e 
	cmp a o,x 
	cmp a o,y 
	cmp b #i 
	cmp b d 
	cmp b e 
	cmp b o,x 
	cmp b o,y 
	cmpa #i 
	cmpa d 
	cmpa e 
	cmpa o,x 
	cmpa o,y 
	cmpb #i 
	cmpb d 
	cmpb e 
	cmpb o,x 
	cmpb o,y 
	com a 
	com b 
	com e 
	com o,x 
	com o,y 
	coma 
	comb 
	cpd #i 
	cpd d 
	cpd e 
	cpd o,x 
	cpd o,y 
	cpx #i 
	cpx d 
	cpx e 
	cpx o,x 
	cpx o,y 
	cpy #i 
	cpy d 
	cpy e 
	cpy o,x 
	cpy o,y 
	daa 
	dec a 
	dec b 
	dec e 
	dec o,x 
	dec o,y 
	deca 
	decb 
	des 
	dex 
	dey 
	eor a #i 
	eor a d 
	eor a e 
	eor a o,x 
	eor a o,y 
	eor b #i 
	eor b d 
	eor b e 
	eor b o,x 
	eor b o,y 
	eora #i 
	eora d 
	eora e 
	eora o,x 
	eora o,y 
	eorb #i 
	eorb d 
	eorb e 
	eorb o,x 
	eorb o,y 
	fdiv 
	idiv 
	inc a 
	inc b 
	inc e 
	inc o,x 
	inc o,y 
	inca 
	incb 
	ins 
	inx 
	iny 
	jmp e 
	jmp o,x 
	jmp o,y 
	jsr d 
	jsr e 
	jsr o,x 
	jsr o,y 
	lda a #i 
	lda a d 
	lda a e 
	lda a o,x 
	lda a o,y 
	lda b #i 
	lda b d 
	lda b e 
	lda b o,x 
	lda b o,y 
	ldaa #i 
	ldaa d 
	ldaa e 
	ldaa o,x 
	ldaa o,y 
	ldab #i 
	ldab d 
	ldab e 
	ldab o,x 
	ldab o,y 
	ldd #i 
	ldd d 
	ldd e 
	ldd o,x 
	ldd o,y 
	lds #i 
	lds d 
	lds e 
	lds o,x 
	lds o,y 
	ldx #i 
	ldx d 
	ldx e 
	ldx o,x 
	ldx o,y 
	ldy #i 
	ldy d 
	ldy e 
	ldy o,x 
	ldy o,y 
	lsl a 
	lsl b 
	lsl e 
	lsl o,x 
	lsl o,y 
	lsla 
	lslb 
	lsld 
	lsr a 
	lsr b 
	lsr e 
	lsr o,x 
	lsr o,y 
	lsra 
	lsrb 
	lsrd 
	mul 
	neg a 
	neg b 
	neg e 
	neg o,x 
	neg o,y 
	nega 
	negb 
	nop 
	ora a #i 
	ora a d 
	ora a e 
	ora a o,x 
	ora a o,y 
	ora b #i 
	ora b d 
	ora b e 
	ora b o,x 
	ora b o,y 
	oraa #i 
	oraa d 
	oraa e 
	oraa o,x 
	oraa o,y 
	orab #i 
	orab d 
	orab e 
	orab o,x 
	orab o,y 
	psh a 
	psh b 
	psh x 
	psh y 
	psha 
	pshb 
	pshx 
	pshy 
	pul a 
	pul b 
	pul x 
	pul y 
	pula 
	pulb 
	pulx 
	puly 
	rol a 
	rol b 
	rol e 
	rol o,x 
	rol o,y 
	rola 
	rolb 
	ror a 
	ror b 
	ror e 
	ror o,x 
	ror o,y 
	rora 
	rorb 
	rti 
	rts 
	sba 
	sbc a #i 
	sbc a d 
	sbc a e 
	sbc a o,x 
	sbc a o,y 
	sbc b #i 
	sbc b d 
	sbc b e 
	sbc b o,x 
	sbc b o,y 
	sbca #i 
	sbca d 
	sbca e 
	sbca o,x 
	sbca o,y 
	sbcb #i 
	sbcb d 
	sbcb e 
	sbcb o,x 
	sbcb o,y 
	sec 
	sei 
	sev 
	sta a d 
	sta a e 
	sta a o,x 
	sta a o,y 
	sta b d 
	sta b e 
	sta b o,x 
	sta b o,y 
	staa d 
	staa e 
	staa o,x 
	staa o,y 
	stab d 
	stab e 
	stab o,x 
	stab o,y 
	std d 
	std e 
	std o,x 
	std o,y 
	stop 
	sts d 
	sts e 
	sts o,x 
	sts o,y 
	stx d 
	stx e 
	stx o,x 
	stx o,y 
	sty d 
	sty e 
	sty o,x 
	sty o,y 
	sub a #i 
	sub a d 
	sub a e 
	sub a o,x 
	sub a o,y 
	sub b #i 
	sub b d 
	sub b e 
	sub b o,x 
	sub b o,y 
	suba #i 
	suba d 
	suba e 
	suba o,x 
	suba o,y 
	subb #i 
	subb d 
	subb e 
	subb o,x 
	subb o,y 
	subd #i 
	subd d 
	subd e 
	subd o,x 
	subd o,y 
	swi 
	tab 
	tap 
	tba 
	test
	tpa 
	tst a 
	tst b 
	tst e 
	tst o,x 
	tst o,y 
	tsta 
	tstb 
	tsx 
	tsy 
	txs 
	tys 
	wai 
	xgdx 
	xgdy 
	end
