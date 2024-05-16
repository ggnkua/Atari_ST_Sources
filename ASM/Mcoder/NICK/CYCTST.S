x:	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#$2700,sr
	move.b	#2,$ffff820a.w
o:	blk.w	40053,$4e71
	move.w	#$700,$ffff8240.w
	move.w	#$777,$ffff8240.w
	jmp	o


