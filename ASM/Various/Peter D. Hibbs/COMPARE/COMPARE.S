;compare routine
;ENTRY d0.w=value to compare
;      in-line data=no of words to test
;                  =first word
;                  =first address
;                  =etc
;EXIT  program jumps to new address or
;      continues

compare	movem.l	a0/d1,-(sp)
	move.l	8(sp),a0
	move	(a0)+,d1
	subq	#1,d1
compar1	cmp	(a0)+,d0
	beq	compar3
	addq.l	#4,a0
	dbra	d1,compar1
compar2	move.l	a0,8(sp)
	movem.l	(sp)+,a0/d1
	rts
	
compar3	move.l	(a0),a0
	bra	compar2
