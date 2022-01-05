
SAUVE_FEN::
	xref	WINDOW_LIST,WORK_BUF
	move	#$2300,sr
	clr	-(sp)
	pea	fname
	move	handle,-(sp)
	move	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move	d0,handle
	lea	WINDOW_LIST,a0
.CNT	tst.l	(a0)+
	bne.s	.CNT
	sub.l	#WINDOW_LIST,a0
	subq	#4,a0
	move.l	a0,d0
	lsr.l	#2,d0
	move	d0,WORK_BUF
	move.l	#WORK_BUF,-(sp)
	move	#2,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1			;write nb fenetres
	add.w	#12,sp


	lea	WINDOW_LIST,a0
.LOOP	move.l	(a0)+,d0
	beq.s	.FIN
	move.l	d0,a1
	move.l	a0,-(sp)

	move.l	a1,-(sp)
	move	#32,-(sp)
	move	handle,-(sp)
	move	#$40,-(sp)
	trap	#1
	add.w	#10,sp
	move.l	(sp)+,a0
	bra.s	.LOOP	
	
.FIN
	move	handle,-(sp)
	move	#$3e,-(sp)
	trap	#1
	addq	#4,sp	
	move	#$2700,sr
	rts
		


fname	dc.b	'centinel.cfg',0
	even
handle	dc	0

