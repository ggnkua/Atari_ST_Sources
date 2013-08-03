	SECTION	text

copyString
	move.b	(a0)+,d0
	beq	.done
	move.b	d0,(a1)+
	bra	copyString
.done
	rts
;------------------------------------------------------
lengthString
	addq.w	#1,d1
	move.b	(a0)+,d0
	bne	lengthString
	subq.w	#1,d1
	rts
;------------------------------------------------------
truncateString
	move.b	(a0),d1
	cmp.b	d0,d1
	beq	.done
	clr.b	(a0)
	subq.l	#1,a0
	bra	truncateString
.done
	rts
;------------------------------------------------------
locateString
	move.b	(a0)+,d1
	cmp.b	d0,d1
	beq	.done
	tst.b	d1
	bne	locateString
	moveq.w	#0,d0
.done
	rts
;------------------------------------------------------
valueString
	move.l	d1,-(sp)

	moveq.l	#0,d0
	moveq.l	#0,d1

	cmpi.b	#'@',(a0)
	beq	.done

	tst.b	(a0)
	beq	.done
.loop
	moveq.l	#10,d1
	bsr	long_mul
.next
	move.b	(a0)+,d1
	cmpi.b	#$39,d1
	bgt	.not_num
	cmpi.b	#$30,d1
	blt	.not_num
	sub.b	#$30,d1
	ext.l	d1
	add.l	d1,d0

	tst.b	(a0)
	bne	.loop
.done
	move.l	(sp)+,d1
	rts
.not_num
	bra	.done
;------------------------------------------------------
valueToString
	movem.l	d2-d3,-(sp)
	moveq.l	#0,d2
	moveq.l	#10,d3
.loop
	move.l	d0,d1
	move.l	d3,d0
	bsr	long_div

	add.b	#$30,d1
	move.b	d1,-(sp)
	addq.w	#1,d2

	tst.l	d0
	bne	.loop

	subq.w	#1,d2
.loop2
	move.b	(sp)+,(a0)+
	dbra	d2,.loop2

	clr.b	(a0)
	movem.l	(sp)+,d2-d3
	rts