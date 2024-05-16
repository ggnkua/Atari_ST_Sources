	lea	$40000,a0
	move	#1284-1,d0
	lea	freqs(pc),a1
count:
	moveq	#0,d1
	move.b	(a0)+,d1
	add	d1,d1
	addq	#1,(a1,d1.w)
	dbra	d0,count


	illegal

freqs:	blk.w	100,0


