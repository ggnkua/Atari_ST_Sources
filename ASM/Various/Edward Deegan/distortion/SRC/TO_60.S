
siper:	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	D0,save_ssp

	clr.b	$FF820A

	move.l	save_ssp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

save_ssp:	ds.l	1