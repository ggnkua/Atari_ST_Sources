_puttime:
	movem.l	d0-a6,-(sp)
	bsr	gosup
	move.l	$114,save114
	move.l	$114,my114drop+2
	move.l	#my114,$114
	bsr	gouser
	movem.l	(sp)+,d0-a6
	rts
my114:
	subq.w	#1,_count20
	bgt.s	my114drop
	move.w	#20,_count20
	subq.w	#1,_ourcoun
	bge	my114drop
	move.w	#0,_ourcoun
my114drop:
	jmp	$0.L
