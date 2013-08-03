	SECTION	text

stopSampleReplay
	bra	.stopDMA
	rts
.stopDMA
	super	#0
	clr.b	$ffff8901
	super	d0
	rts
