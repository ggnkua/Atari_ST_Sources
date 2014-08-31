	output	.ro


;	bra.s	linefeed
linefeed:
	move	#12,-(sp)
	move	#5,-(sp)
	trap	#1
	addq	#4,sp
	rts