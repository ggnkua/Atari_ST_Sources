fix:	tst.w	.flag
	bne.s	.off

	bclr	#5,$fffffa15.w
	move.w	#1,.flag
	rts

.off:	bset	#5,$fffffa15.w
	clr.w	.flag
	rts

.flag:	dc.w	0