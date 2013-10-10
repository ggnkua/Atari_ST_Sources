* Convert value to hex-ascii string.
* By Niclas Pennskog (Jason/Unit #17)
*

hex_conv	lea	hex_chrs,A1	* a0=pointer to ascii
next_hex	move.b	D0,D2	* d0=value
	and.w	#$0F,D2	* d1=how many digits-1
	move.b	0(A1,D2.w),0(A0,D1.w)
	lsr.l	#4,D0
	dbra	D1,next_hex
	rts

hex_chrs	dc.b	'0123456789ABCDEF'
