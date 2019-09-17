;Return random number within specified range
;ENTRY Inline data specify range (lowest - highest)
;EXIT  d0.w=16 bit value in range

rnd_scale	movem.l	a0/d1-d4,-(sp)	save registers

	move.l	20(sp),a0	# fetch return address
	move.l	(a0)+,d0	# copy low limit to d0
	move.l	(a0)+,d1	# copy high limit to d1
	
	move	d0,d2	copy d0 to d2
	sub	d0,d1	calculate difference
	addq	#1,d1	correct d1
	move	d1,d3	and copy to d3
	move	#17,d4	calculate number of bits
rnd_scale1	subq	#1,d4	dec d4
	lsl	#1,d3	shift high bit to Cy
	bcc	rnd_scale1	jump if bit=0

	clr.l	d0	* generate 16 bit random No
	move	seed,d0	* fetch last seed
	mulu	#58653,d0	* multiply by 58653
	add	#13849,d0	* add 13849
	move	d0,seed	* restore seed

	lsr	d4,d0	shift right d4 times
	mulu	d1,d0	multiply by high limit
	neg	d4
	add	#16,d4	calculate shift value
	lsr.l	d4,d0	shift right d4 times
	add	d2,d0	add difference
	
	move.l	a0,20(sp)	# restore return address

	movem.l	(sp)+,a0/d1-d4	restore registers
	rts		return

seed	ds.w	1