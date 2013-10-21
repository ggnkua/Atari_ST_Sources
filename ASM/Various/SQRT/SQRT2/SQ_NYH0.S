EXPORT sqrt_nyh0


sqrt_nyh0:
	moveq		#-1,		d1
loop:
	addq.l		#2,			d1
	sub.l		d1,			d0
	bcc.s		loop
	lsr.l		#1,			d1
	move.l		d1,			d0
	rts

