	txtlong
sfx_debug:
	move.l	screen,a0
	lea	channellist,a1
	move.w	num_channels,d0
.loop:
	move.w	#%1111100000000000,d1
	tst.w	chanstatus(a1)
	beq.s	.hopp
	move.w	#%0000011111100000,d1
.hopp:
	move.w	d1,(a0)
	addq.l	#4,a0
	add.l	#chansize,a1
	dbra	d0,.loop
	rts
