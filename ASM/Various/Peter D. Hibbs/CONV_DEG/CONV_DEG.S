;Converts a 'Degas' picture (PI1-3 or PC1-3) to normal format (all resolutions)
;ENTRY a0=source buffer address
;      a1=destination buffer address
;      k1 & k2 stores defined
;EXIT  destination buffer holds picture image
;      d0=0 OK, no other regs changed

conv_degas	movem.l	a0-a2/d1-d4,-(sp)
	move	(a0)+,d0

	movem.l	a0-a1/d0,-(sp)	set palette colours
	move.l	a0,-(sp)
	move	#6,-(sp)
	trap	#14
	addq	#6,sp
	movem.l	(sp)+,a0-a1/d0

	add	#32,a0	skip palette data
	btst	#15,d0	check if compressed
	beq	conv_degas6	bra if not
	and	#3,d0	mask high bits
	move	#2,k1	set planes value
	move	#80,k2	set columns
	cmp	#2,d0	high rez
	beq	conv_degas7	yes
	move	#4,k1	4 bytes/plane
	cmp	#1,d0	med rez ?
	beq	conv_degas7	yes
	move	#8,k1	8 bytes/plane
	move	#40,k2	40 columns
conv_degas7	clr	d2	
	clr	d3
	move.l	a1,d1	calc end addr
	add.l	#32000,d1
conv_degas1	clr.l	d0	fetch cntrl byte
	move.b	(a0)+,d0
	cmp.b	#128,d0
	beq	conv_degas1	loop if 128
	btst	#7,d0
	bne	conv_degas3	bra if neg
conv_degas2	move.b	(a0)+,(a1)	copy data to O/P buffer
	bsr	degas_next	calc next addr
	dbra	d0,conv_degas2	repeat d0 times
conv_degas5	cmp.l	d1,a1	
	blt	conv_degas1	repeat till all done
conv_degas9	clr	d0	no errors
	movem.l	(sp)+,a0-a2/d1-d4
	rts
	
conv_degas3	neg.b	d0	conv to positive
conv_degas4	move.b	(a0),(a1)	copy data to output
	bsr	degas_next	calc next addr
	dbra	d0,conv_degas4	repeat d0 times
	addq	#1,a0	inc source pointer
	bra	conv_degas5	& repeat
	
conv_degas6	move	#8000-1,d0	copy picture to buffer
conv_degas8	move.l	(a0)+,(a1)+	for uncompressed image
	dbra	d0,conv_degas8
	bra	conv_degas9

;Calc next output address

degas_next	add	#1,a1
	addq	#1,d2
	btst	#0,d2
	bne	degas_next1
	add	k1,a1
	subq	#2,a1
	cmp	k2,d2
	bne	degas_next1
	sub	#160-2,a1
	clr	d2
	addq	#1,d3
	move	k1,d4
	lsr	#1,d4
	cmp	d4,d3
	bne	degas_next1
	clr	d3
	add	#160,a1
	sub	k1,a1
degas_next1	rts

k1	ds.w	1
k2	ds.w	1
