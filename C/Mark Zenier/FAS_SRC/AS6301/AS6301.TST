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
	adc a #i 
	adc a d 
	adc a e 
	adc a o,x 
	adc b #i 
	adc b d 
	adc b e 
	adc b o,x 
	adca #i 
	adca d 
	adca e 
	adca o,x 
	adcb #i 
	adcb d 
	adcb e 
	adcb o,x 
	add a #i 
	add a d 
	add a e 
	add a o,x 
	add b #i 
	add b d 
	add b e 
	add b o,x 
	adda #i 
	adda d 
	adda e 
	adda o,x 
	addb #i 
	addb d 
	addb e 
	addb o,x 
	addd #i 
	addd d 
	addd e 
	addd o,x 
	aim #i,d
	aim #i,o,x
	and a #i 
	and a d 
	and a e 
	and a o,x 
	and b #i 
	and b d 
	and b e 
	and b o,x 
	anda #i 
	anda d 
	anda e 
	anda o,x 
	andb #i 
	andb d 
	andb e 
	andb o,x 
	asl a 
	asl b 
	asl e 
	asl o,x 
	asla 
	aslb 
	asld 
	asr a 
	asr b 
	asr e 
	asr o,x 
	asra 
	asrb 
	bcc *-4 
	bclr 0,d
	bclr 1,d
	bclr 2,d
	bclr 3,d
	bclr 4,d
	bclr 5,d
	bclr 6,d
	bclr 7,d
	bclr 0,o,x
	bclr 1,o,x
	bclr 2,o,x
	bclr 3,o,x
	bclr 4,o,x
	bclr 5,o,x
	bclr 6,o,x
	bclr 7,o,x
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
	bit b #i 
	bit b d 
	bit b e 
	bit b o,x 
	bita #i 
	bita d 
	bita e 
	bita o,x 
	bitb #i 
	bitb d 
	bitb e 
	bitb o,x 
	ble *-4 
	blo *-4 
	bls *-4 
	blt *-4 
	bmi *-4 
	bne *-4 
	bpl *-4 
	bra *-4 
	brn *-4 
	bset 0,d
	bset 1,d
	bset 2,d
	bset 3,d
	bset 4,d
	bset 5,d
	bset 6,d
	bset 7,d
	bset 0,o,x
	bset 1,o,x
	bset 2,o,x
	bset 3,o,x
	bset 4,o,x
	bset 5,o,x
	bset 6,o,x
	bset 7,o,x
	bsr *-4 
	btgl 0,d
	btgl 1,d
	btgl 2,d
	btgl 3,d
	btgl 4,d
	btgl 5,d
	btgl 6,d
	btgl 7,d
	btgl 0,o,x
	btgl 1,o,x
	btgl 2,o,x
	btgl 3,o,x
	btgl 4,o,x
	btgl 5,o,x
	btgl 6,o,x
	btgl 7,o,x
	btst 0,d
	btst 1,d
	btst 2,d
	btst 3,d
	btst 4,d
	btst 5,d
	btst 6,d
	btst 7,d
	btst 0,o,x
	btst 1,o,x
	btst 2,o,x
	btst 3,o,x
	btst 4,o,x
	btst 5,o,x
	btst 6,o,x
	btst 7,o,x
	bvc *-4 
	bvs *-4 
	cba 
	clc 
	cli 
	clr a 
	clr b 
	clr e 
	clr o,x 
	clra 
	clrb 
	clv 
	cmp a #i 
	cmp a d 
	cmp a e 
	cmp a o,x 
	cmp b #i 
	cmp b d 
	cmp b e 
	cmp b o,x 
	cmpa #i 
	cmpa d 
	cmpa e 
	cmpa o,x 
	cmpb #i 
	cmpb d 
	cmpb e 
	cmpb o,x 
	com a 
	com b 
	com e 
	com o,x 
	coma 
	comb 
	cpx #i 
	cpx d 
	cpx e 
	cpx o,x 
	daa 
	dec a 
	dec b 
	dec e 
	dec o,x 
	deca 
	decb 
	des 
	dex 
	eim #i,d
	eim #i,o,x
	eor a #i 
	eor a d 
	eor a e 
	eor a o,x 
	eor b #i 
	eor b d 
	eor b e 
	eor b o,x 
	eora #i 
	eora d 
	eora e 
	eora o,x 
	eorb #i 
	eorb d 
	eorb e 
	eorb o,x 
	inc a 
	inc b 
	inc e 
	inc o,x 
	inca 
	incb 
	ins 
	inx 
	jmp e 
	jmp o,x 
	jsr d 
	jsr e 
	jsr o,x 
	lda a #i 
	lda a d 
	lda a e 
	lda a o,x 
	lda b #i 
	lda b d 
	lda b e 
	lda b o,x 
	ldaa #i 
	ldaa d 
	ldaa e 
	ldaa o,x 
	ldab #i 
	ldab d 
	ldab e 
	ldab o,x 
	ldd #i 
	ldd d 
	ldd e 
	ldd o,x 
	lds #i 
	lds d 
	lds e 
	lds o,x 
	ldx #i 
	ldx d 
	ldx e 
	ldx o,x 
	lsl a 
	lsl b 
	lsl e 
	lsl o,x 
	lsla 
	lslb 
	lsld 
	lsr a 
	lsr b 
	lsr e 
	lsr o,x 
	lsra 
	lsrb 
	lsrd 
	mul 
	neg a 
	neg b 
	neg e 
	neg o,x 
	nega 
	negb 
	nop 
	oim #i,d
	oim #i,o,x
	ora a #i 
	ora a d 
	ora a e 
	ora a o,x 
	ora b #i 
	ora b d 
	ora b e 
	ora b o,x 
	oraa #i 
	oraa d 
	oraa e 
	oraa o,x 
	orab #i 
	orab d 
	orab e 
	orab o,x 
	psh a 
	psh b 
	psh x 
	psha 
	pshb 
	pshx 
	pul a 
	pul b 
	pul x 
	pula 
	pulb 
	pulx 
	rol a 
	rol b 
	rol e 
	rol o,x 
	rola 
	rolb 
	ror a 
	ror b 
	ror e 
	ror o,x 
	rora 
	rorb 
	rti 
	rts 
	sba 
	sbc a #i 
	sbc a d 
	sbc a e 
	sbc a o,x 
	sbc b #i 
	sbc b d 
	sbc b e 
	sbc b o,x 
	sbca #i 
	sbca d 
	sbca e 
	sbca o,x 
	sbcb #i 
	sbcb d 
	sbcb e 
	sbcb o,x 
	sec 
	sei 
	sev 
	slp
	sta a d 
	sta a e 
	sta a o,x 
	sta b d 
	sta b e 
	sta b o,x 
	staa d 
	staa e 
	staa o,x 
	stab d 
	stab e 
	stab o,x 
	std d 
	std e 
	std o,x 
	sts d 
	sts e 
	sts o,x 
	stx d 
	stx e 
	stx o,x 
	sub a #i 
	sub a d 
	sub a e 
	sub a o,x 
	sub b #i 
	sub b d 
	sub b e 
	sub b o,x 
	suba #i 
	suba d 
	suba e 
	suba o,x 
	subb #i 
	subb d 
	subb e 
	subb o,x 
	subd #i 
	subd d 
	subd e 
	subd o,x 
	swi 
	tab 
	tap 
	tba 
	tim #i,d
	tim #i,o,x
	tpa 
	tst a 
	tst b 
	tst e 
	tst o,x 
	tsta 
	tstb 
	tsx 
	txs 
	wai 
	xgdx 
	end
