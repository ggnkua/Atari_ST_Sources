	**************************************
	*graphic3 - General graphics routines*
	* a0=source address, a1=dest address *
	*       a2=source mask address       *
	*        d0=dest x, d1=dest y        *
	* d2=width(in words)-1, d3=height-1  *
	*     Corrupts a0-a2 d0-d1/d3-d5     *
	**************************************

graphic3	lsl.w	#5,d1		Multiply dest y by 32
	add.w	d1,a1		Add to dest address
	add.w	d1,d1		Multiply by
	add.w	d1,d1		4 more
	add.w	d1,a1		Add to dest address

	move.w	d0,d1		Get dest x
	and.w	#$fff0,d1		Round off
	lsr.w	#1,d1		Divide by 2
	add.w	d1,a1		And add to dest address
	and.w	#$f,d0		Find dest shift

	clr.l	d4		Clear d4
	move.w	d2,d4		Get width
	lsl.w	#3,d4		Multiply by 8
	neg.w	d4		And subtract from
	add.w	#152,d4		152 to find eol increment
	move.w	d2,d5		Copy width

loopg3	move.l	#-1,d1		Fill d1
	move.w	(a2),d1		Get mask data
	ror.l	d0,d1		shift it
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	swap	d1		Get other half
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	lea	-16(a1),a1	Move back dest address
	addq.l	#8,a2		Move up mask address
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	or.w	d1,(a1)+		Place on screen
	swap	d1		Get other half
	or.w	d1,6(a1)		Place on screen
	endr			Next bit-plane
	dbf	d2,loopg3		Do next word
	move.w	d5,d2		Restore width
	add.l	d4,a0		Move up source address
	add.l	d4,a1		Move up dest address
	add.l	d4,a2		Move up mask address
	dbf	d3,loopg3		Do next line
	rts			Return