main:
	lea	600000,a0
	move	#39900,d0
a:	move.b	(a0)+,d1
	cmp.l   #$004c0501,d1
	beq.s	ok
	lsl.l   #8,d1
	dbf	d0,a
	illegal
ok:
