	**************************************
	*graphic2 - General graphics routines*
	*  Non-masked, word boundaries only  *
	* a0=source address, a1=dest address *
	* d0=width(in words)-1, d1=height-1  *
	*       Corrupts a0-a1, d1-d3        *
	**************************************

graphic2	clr.l	d2		Clear d2
	move.w	d0,d2		Get width
	lsl.w	#3,d2		Multiply by 8
	neg.w	d2		And subtract from
	add.w	#152,d2		152 to find eol increment
	move.w	d0,d3		Copy width
	
loopg2	rept	4		4 bit planes
	move.w	(a0)+,(a1)+	Copy graphic data to screen
	endr			Next bit-plane
	dbf	d0,loopg2		Do next word
	move.w	d3,d0		Restore width
	add.l	d2,a0		Move up source address
	add.l	d2,a1		Move up dest address
	dbf	d1,loopg2		Do next line
	rts			Return