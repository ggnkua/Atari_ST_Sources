	SECTION	text

locateEnvString
	move.l	a0,a2
	move.l	envPointer,a1
.search
	move.b	(a0)+,d0
	beq	.found
.loop	
	move.b	(a1)+,d1
	cmp.b	d0,d1
	beq	.search
.next
	tst.b	(a1)
	beq	.confirm
.do_next
	move.b	(a1)+,d1
	bne	.next
	move.l	a2,a0
	bra	.search	
.confirm
	tst.b	1(a1)
	bne	.do_next
.notFound	
	moveq.l	#0,d0
	rts
.found
	move.l	a1,d0
	rts
	
	SECTION	data
	
avString	dc.b	'AVSERVER=',0
browserString	dc.b	'BROWSER=',0
stguideString	dc.b	'STGUIDE=',0
userString	dc.b	'HOME=',0