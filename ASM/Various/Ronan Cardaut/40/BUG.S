	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	
	moveq	#0,d4
	move.l	$24,d7
	move.l	$8c,d6
	move.l	#trace,$24.w
	move.l	#trap3,$8c.w
	
	
	move.w	#$a300,sr		; declanche le trace
	
	nop
	nop
	nop
	nop
	
	
	trap	#3
	
	
	
	move.w	#$2300,sr
	
	move.l	d7,$24.w
	move.l	d6,$8c.w
	
	
	clr.l	-(sp)
	trap	#1
	
	
	
	
trap3
	nop
	nop
	nop
	rte
	
trace
	addq.l	#1,d4
	move.l	d0,-(sp)
	move.l	#trap3,d0
	cmp.l	6(sp),d0
	beq.s	.dedant
	move.l	(sp)+,d0
	bset	#7,(sp)			; reactive le trace
	rte
	
.dedant
	illegal				; ici cela veut dire que l'on trace dans l'exception

	
	