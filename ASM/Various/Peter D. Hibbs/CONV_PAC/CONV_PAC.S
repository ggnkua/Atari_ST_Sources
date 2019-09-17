;Convert PAC compressed file to bit image (high rez only)
;ENTRY a0=source buffer address
;      a1=destination buffer address
;EXIT  destination buffer holds picture image
;      d0=0 OK, d0<>0 error

conv_pac	movem.l	a0-a2/d1-d7,-(sp)
	move	#1,d0	set error flag
	clr	d7	set vertical format
	cmp.b	#'p',(a0)+	check for pM85 or pM86
	bne	conv_pac9	
	cmp.b	#'M',(a0)+
	bne	conv_pac9
	cmp.b	#'8',(a0)+
	bne	conv_pac9
	cmp.b	#'6',(a0)+
	beq	conv_pac0
	move	#1,d7	set horiz format
conv_pac0	clr	d3	zero column counter
	clr	d2	zero line counter
	move.b	(a0)+,d4	fetch ID byte
	move.b	(a0)+,d5	fetch pack byte
	move.b	(a0)+,d6	fetch special byte
conv_pac1	tst	d7	check flag
	bne	conv_pac7
	cmp	#80,d3	80 columns done
	beq	conv_pac6	bra if yes
conv_pac8	move.b	(a0)+,d0	fetch next byte
	cmp.b	d0,d4	=ID byte ?
	beq	conv_pac2
	cmp.b	d0,d6	=special byte ?
	beq	conv_pac3
	bsr	op_pac	output byte
	bra	conv_pac1	repeat
	
conv_pac2	move.b	(a0)+,d1	fetch count
	and	#$ff,d1
conv_pac5	move.b	d5,d0	fetch pack byte
	bsr	op_pac	output byte
	dbra	d1,conv_pac5	repeat d1+1 times
	bra	conv_pac1
	
conv_pac3	move.b	(a0)+,d0	fetch data byte
	move.b	(a0)+,d1	fetch count byte
	and	#$ff,d1
conv_pac4	bsr	op_pac	output byte
	dbra	d1,conv_pac4	repeat d1+1 times
	bra	conv_pac1

conv_pac7	cmp	#400,d3	end of screen ?
	bne	conv_pac8
conv_pac6	clr	d0	no errors
conv_pac9	movem.l	(sp)+,a0-a2/d1-d7
	rts

;Output byte data to buffer in Vertical or Horizontal format
;ENTRY d7 =0 Vertical format, =1 Horizontal format
;      a1=destination address
;      d0.b=data byte
;      d2=line/column counter
;      d3=column/line counter
;EXIT  d3=80 or 400 when picture complete

op_pac	tst	d7
	bne	op_pac2
	move.b	d0,(a1)
	add	#80,a1
	add	#1,d2
	cmp	#400,d2
	bne	op_pac1
	clr	d2
	sub	#400*80,a1
	add	#1,a1
	add	#1,d3
op_pac1	rts

op_pac2	move.b	d0,(a1)
	add	#1,a1
	add	#1,d2
	cmp	#80,d2
	bne	op_pac1
	clr	d2
	sub	#80,a1
	add	#80,a1
	add	#1,d3
	rts
