*
* COOKIE.S
*
*	Finds and returns a Cookie. Supervisor only!
*
* In	d1.l=Cookie name
* Out	d0.l=Cookie value or -1
*	(destroys a0)
*

@getcookie
	move.l	$5a0,a0
	move.l	a0,d0
	beq.s	.failed
.loop	move.l	(a0)+,d0
	beq.s	.failed
	cmp.l	d0,d1
	beq.s	.success
	addq.l	#4,a0
	bra.s	.loop

.success
	move.l	(a0)+,d0
	cmp.b	d0,d0
	rts

.failed
	moveq	#-1,d0
	rts
