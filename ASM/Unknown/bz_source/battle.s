	*d0=dest x, d1=dest y, a1=dest address, a0=sprites address
	*d2=sprite number

start	clr.l	d3		Clear d3
	clr.l	d4		Clear d4
	clr.l	d5		Clear d5
	clr.l	d6		Clear d6
	lsl.l	#3,d2		Multiply sprite no by 8
	lea	14(a0,d2),a2	Find place in parameter table
	clr.l	d2		Clear d2
	add.l	(a2)+,a0		Find address of graphic data
	lea	22(a0),a0		Jump past header
	move.b	(a2)+,d2		Get width of sprite
	move.b	(a2)+,d3		Get height of sprite
	move.b	(a2)+,d4		Get x offset
	move.b	(a2)+,d5		Get y offset
	move.l	a0,a2		Get address of mask
	move.w	d2,d6		Get width
	mulu.w	d3,d6		Multiply by height
	add.w	d6,d6		Multiply by 2
	add.l	d6,a0		Get address of sprite

fastspr	sub.w	d5,d1		Find y position
	sub.w	#1,d3		Find height
	tst.w	d1		Off top edge?
	blt	cliptop		Yes, clip it
	move.w	d1,d6		Get y position
	add.w	d3,d6		Find bottom of sprite
	cmp.w	#199,d6		Off bottom edge
	bgt	clipbase		Yes, clip it

yclipr	lsl.w	#5,d1		Multiply dest y by 32
	add.l	d1,a1		Add to dest address
	add.w	d1,d1		Multiply by
	add.w	d1,d1		4 more
	add.l	d1,a1		Add to dest address

	sub.w	d4,d0		Find x position
	sub.w	#1,d2		Find width
	tst.w	d0		Off left edge?
	blt	clipleft		Yes, clip it

	move.w	d2,d7		Get width
	add.w	#1,d7		Find real width
	lsl.w	#4,d7		Convert to pixels
	add.w	d0,d7		Find right of sprite
	cmp.w	#320,d7		Off right edge?
	bgt	clipright		Yes, clip it

	move.w	d0,d1		Get dest x
	and.w	#$fff0,d1		Round off
	lsr.w	#1,d1		Divide by 2
	add.l	d1,a1		And add to dest address
	and.w	#$f,d0		Find dest shift

	clr.l	d4		Clear d4
	move.w	d2,d4		Get width
	lsl.w	#3,d4		Multiply by 8
	neg.l	d4		And subtract from
	add.l	#152,d4		152 to find eol increment
	move.w	d2,a3		Copy width

fastloop	move.l	#-1,d1		Fill d1
	move.w	(a2)+,d1		Get mask data
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
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	or.w	d1,(a1)+		Place on screen
	swap	d1		Get other half
	or.w	d1,6(a1)		Place on screen
	endr			Next bit-plane
	dbf	d2,fastloop	Do next word
	move.w	a3,d2		Restore width
	add.l	d4,a1		Move up dest address
	dbf	d3,fastloop	Do next line
return	rts			Return

clipbase	sub.w	#199,d6		How far is sprite off edge?
	cmp.w	d3,d6		Is sprite visible at all?
	bgt	return		No, quit routine
	sub.w	d6,d3		Reduce height
	bra	yclipr		Return

cliptop	neg.w	d1		How far is sprite off edge?
	cmp.w	d3,d1		Is sprite visible at all?
	bgt	return		No, quit routine
	sub.w	d1,d3		Reduce height
	mulu.w	d2,d1		Multiply by width
	add.w	d1,d1		Multiply by 2
	add.l	d1,a2		Move up mask address	
	add.w	d1,d1		Multiply by 2
	add.w	d1,d1		Multiply by 2 more
	add.l	d1,a0		Move up source address
	clr.w	d1		Draw sprite at top
	bra	yclipr		Return

clipleft	move.w	d0,d4		Get x position
	neg.w	d4		How far is sprite off edge?
	lsr.w	#4,d4		Convert to words
	cmp.w	d2,d4		Is sprite visible at all?
	bgt	return		No, quit routine
	sub.w	d4,d2		Reduce width
	add.w	d4,d4		Multiply overflow by 2
	add.w	d4,a2		Move up mask address
	add.w	d4,d4		Multiply overflow by 2
	add.w	d4,d4		Multiply overflow by 2
	add.w	d4,a0		Move up graphic address
	add.w	d4,d4		Multiply overflow by 2
	add.w	d4,d0		Move sprite right
	lsr.w	#1,d4		Find sprite increment
	move.w	d4,d7		Store in d7
	lsr.w	#2,d4		Find mask increment
	move.w	d4,d6		Store in d6

	move.w	d0,d1		Get dest x
	add.w	#160,d1		Sum won't work if it's negative
	and.w	#$fff0,d1		Round off
	lsr.w	#1,d1		Divide by 2
	add.l	d1,a1		And add onto dest address
	lea	-80(a1),a1	Allow for earlier adjustment
	add.w	#160,d0		Sum won't work if it's negative
	and.w	#$f,d0		Find dest shift

	clr.l	d4		Clear d4
	move.w	d2,d4		Get width
	lsl.w	#3,d4		Multiply by 8
	neg.l	d4		And subtract from
	add.l	#152,d4		152 to find eol increment
	sub.w	#1,d2		Reduce width by 1
	move.w	d2,a3		Copy width

lloop	move.l	#-1,d1		Fill d1
	move.w	(a2)+,d1		Get mask data
	ror.l	d0,d1		shift it
	addq.l	#8,a1		Skip first half
	swap	d1		Get other half
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	lea	-16(a1),a1	Move back dest address
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	addq.l	#2,a1		Skip first half
	swap	d1		Get other half
	or.w	d1,6(a1)		Place on screen
	endr			Next bit-plane

	tst.w	d2		Any more to draw?
	blt	nlloop		No, don't draw it

lloopb	move.l	#-1,d1		Fill d1
	move.w	(a2)+,d1		Get mask data
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
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	or.w	d1,(a1)+		Place on screen
	swap	d1		Get other half
	or.w	d1,6(a1)		Place on screen
	endr			Next bit-plane
	dbf	d2,lloopb		Do next word
nlloop	move.w	a3,d2		Restore width
	add.l	d4,a1		Move up dest address
	add.l	d6,a2		Move up mask address
	add.l	d7,a0		Move up source address
	dbf	d3,lloop		Do next line
	rts			Return

clipright	sub.w	#320,d7		How far is sprite off edge?
	move.w	d7,d6		Make copy of overflow
	lsr.w	#4,d6		Convert to words
	cmp.w	d2,d6		Is sprite visible at all?
	bgt	return		No, quit routine
	sub.w	d6,d2		Reduce width

	move.w	d0,d1		Get dest x
	and.w	#$fff0,d1		Round off
	lsr.w	#1,d1		Divide by 2
	add.l	d1,a1		And add to dest address
	and.w	#$f,d0		Find dest shift

	clr.l	d4		Clear d4
	move.w	d2,d4		Get width
	lsl.w	#3,d4		Multiply by 8
	neg.l	d4		And subtract from
	add.l	#152,d4		152 to find eol increment
	sub.w	#1,d2		Reduce width by 1
	move.w	d2,a3		Copy width
	move.w	d3,a4		Copy height
	move.l	a1,a5		Copy dest address
	add.w	d6,d6		Find mask increment
	move.w	d6,d7		Copy into d7
	add.w	d7,d7		Find sprite increment
	add.w	d7,d7		Find sprite increment

rloop	tst.w	d2		Any more to draw?
	blt	nrloop		No, don't draw it

rloopb	move.l	#-1,d1		Fill d1
	move.w	(a2)+,d1		Get mask data
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
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	or.w	d1,(a1)+		Place on screen
	swap	d1		Get other half
	or.w	d1,6(a1)		Place on screen
	endr			Next bit-plane
	dbf	d2,rloopb		Do next word

nrloop	move.l	#-1,d1		Fill d1
	move.w	(a2)+,d1		Get mask data
	ror.l	d0,d1		shift it
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	and.w	d1,(a1)+		Place on screen
	lea	-8(a1),a1		Move back dest address
	rept	4		4 bit planes
	clr.l	d1		Clear d1
	move.w	(a0)+,d1		Get graphic data
	ror.l	d0,d1		Shift it
	or.w	d1,(a1)+		Place on screen
	endr			Next bit-plane

	move.w	a3,d2		Restore width
	add.l	d4,a1		Move up dest address
	add.l	d6,a2		Move up mask address
	add.l	d7,a0		Move up source address
	dbf	d3,rloop		Do next line
	rts			Return