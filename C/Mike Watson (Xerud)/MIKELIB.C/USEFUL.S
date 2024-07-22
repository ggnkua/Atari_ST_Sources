	EXPORT	SetIKBD

SetIKBD:
.loop:
	btst	#1,$fffffc00.w
	beq.s	.loop                           
	move.b	d0,$fffffc02.w
	rts
