immed	equ	11H
xdest	reg	$2d
xsrc	reg	$1c
xddest	rreg	$44
	adc	@ xdest , # immed
	adc	R13, @ R12
	adc	R13, R12
	adc	xdest , # immed
	adc	xdest, @ xsrc
	adc	xdest, xsrc
	add	@ xdest , # immed
	add	R13, @ R12
	add	R13, R12
	add	xdest , # immed
	add	xdest, @ xsrc
	add	xdest, xsrc
	and	@ xdest , # immed
	and	R13, @ R12
	and	R13, R12
	and	xdest , # immed
	and	xdest, @ xsrc
	and	xdest, xsrc
	call	@ xddest
	call	jmpdst
	ccf
	clr	@ xdest
	clr	xdest
	com	@ xdest
	com	xdest
	cp	@ xdest , # immed
	cp	R13, @ R12
	cp	R13, R12
	cp	xdest , # immed
	cp	xdest, @ xsrc
	cp	xdest, xsrc
	da	@ xdest
	da	xdest
	dec	@ xdest
	dec	xdest
	decw	@ xddest
	decw	xddest
	di
	djnz	R0, *+56
	djnz	R1, *+56
	djnz	R10, *+56
	djnz	R11, *+56
	djnz	R12, *+56
	djnz	R13, *+56
	djnz	R14, *+56
	djnz	R15, *+56
	djnz	R2, *+56
	djnz	R3, *+56
	djnz	R4, *+56
	djnz	R5, *+56
	djnz	R6, *+56
	djnz	R7, *+56
	djnz	R8, *+56
	djnz	R9, *+56
	ei
	inc	@ xdest
	inc	R0
	inc	R1
	inc	R10
	inc	R11
	inc	R12
	inc	R13
	inc	R14
	inc	R15
	inc	R2
	inc	R3
	inc	R4
	inc	R5
	inc	R6
	inc	R7
	inc	R8
	inc	R9
	inc	xdest
	incw	@ xddest
	incw	xddest
	iret
	jp	@ xddest
	jp	jmpdst
	jp	C, jmpdst
	jp	EQ, jmpdst
	jp	F, jmpdst
	jp	GE, jmpdst
	jp	GT, jmpdst
	jp	LE, jmpdst
	jp	LT, jmpdst
	jp	MI, jmpdst
	jp	NC, jmpdst
	jp	NE, jmpdst
	jp	NOV, jmpdst
	jp	NZ, jmpdst
	jp	OV, jmpdst
	jp	PL, jmpdst
	jp	UGE, jmpdst
	jp	UGT, jmpdst
	jp	ULE, jmpdst
	jp	ULT, jmpdst
	jp	Z, jmpdst
	jr	*+56
	jr	C, *+56
	jr	EQ, *+56
	jr	F, *+56
	jr	GE, *+56
	jr	GT, *+56
	jr	LE, *+56
	jr	LT, *+56
	jr	MI, *+56
	jr	NC, *+56
	jr	NE, *+56
	jr	NOV, *+56
	jr	NZ, *+56
	jr	OV, *+56
	jr	PL, *+56
	jr	UGE, *+56
	jr	UGT, *+56
	jr	ULE, *+56
	jr	ULT, *+56
	jr	Z, *+56
	ld	R13, $44(R12)
	ld	$55(R13), R12
	ld	R13, @ R12
	ld	xdest, xsrc
	ld	xdest, @ xsrc
	ld	xdest, # immed
	ld	@ xdest, # immed
	ld	@ R13, R12
	ld	@ xdest, xsrc
	ld	R0, # immed
	ld	R0, xsrc
	ld	R1, # immed
	ld	R1, xsrc
	ld	R10, # immed
	ld	R10, xsrc
	ld	R11, # immed
	ld	R11, xsrc
	ld	R12, # immed
	ld	R12, xsrc
	ld	R13, # immed
	ld	R13, xsrc
	ld	R14, # immed
	ld	R14, xsrc
	ld	R15, # immed
	ld	R15, xsrc
	ld	R2, # immed
	ld	R2, xsrc
	ld	R3, # immed
	ld	R3, xsrc
	ld	R4, # immed
	ld	R4, xsrc
	ld	R5, # immed
	ld	R5, xsrc
	ld	R6, # immed
	ld	R6, xsrc
	ld	R7, # immed
	ld	R7, xsrc
	ld	R8, # immed
	ld	R8, xsrc
	ld	R9, # immed
	ld	R9, xsrc
	ld	xdest, R0
	ld	xdest, R1
	ld	xdest, R10
	ld	xdest, R11
	ld	xdest, R12
	ld	xdest, R13
	ld	xdest, R14
	ld	xdest, R15
	ld	xdest, R2
	ld	xdest, R3
	ld	xdest, R4
	ld	xdest, R5
	ld	xdest, R6
	ld	xdest, R7
	ld	xdest, R8
	ld	xdest, R9
	ldc	@ RR10, R13
	ldc	R13, @RR10
	ldci	@ R13, @RR10
	ldci	@ RR10, @ R13
	lde	@ RR10, R13
	lde	R13, @RR10
	ldei	@ R13, @RR10
	ldei	@ RR10, @ R13
	nop
	or	@ xdest , # immed
	or	R13, @ R12
	or	R13, R12
	or	xdest , # immed
	or	xdest, @ xsrc
	or	xdest, xsrc
	pop	@ xdest
	pop	xdest
	push	@ xdest
	push	xdest
	rcf
	ret
	rl	@ xdest
	rl	xdest
	rlc	@ xdest
	rlc	xdest
	rr	@ xdest
	rr	xdest
	rrc	@ xdest
	rrc	xdest
	sbc	@ xdest , # immed
	sbc	R13, @ R12
	sbc	R13, R12
	sbc	xdest , # immed
	sbc	xdest, @ xsrc
	sbc	xdest, xsrc
	scf
	sra	@ xdest
	sra	xdest
	srp	# 112
	sub	@ xdest , # immed
	sub	R13, @ R12
	sub	R13, R12
	sub	xdest , # immed
	sub	xdest, @ xsrc
	sub	xdest, xsrc
	swap	@ xdest
	swap	xdest
	tcm	@ xdest , # immed
	tcm	R13, @ R12
	tcm	R13, R12
	tcm	xdest , # immed
	tcm	xdest, @ xsrc
	tcm	xdest, xsrc
	tm	@ xdest , # immed
	tm	R13, @ R12
	tm	R13, R12
	tm	xdest , # immed
	tm	xdest, @ xsrc
	tm	xdest, xsrc
	xor	@ xdest , # immed
	xor	R13, @ R12
	xor	R13, R12
	xor	xdest , # immed
	xor	xdest, @ xsrc
	xor	xdest, xsrc
jmpdst	
