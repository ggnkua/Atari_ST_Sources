;	:ts=10
;	This file is in Aztec 68000 syntax assembler.
;
;	There are two subroutines here.  stretcht makes up a
;	lookup-table for stretching a horizontal line.
;	xlookup uses this table to stretch a horizontal line.
;	The code that does a "rectangle" stretch is still in
;	C calling these guys.
;
;	This algorithm works on byte-a-pixel source and dest.
;	After quite a bit of testing it was found that when
;	you can convert the source to byte-a-pixel just once
;	for multiple stretches off the same source (as when
;	"rubberbanding" the stretch in flicker) it is about 30-40%
;	faster to do the conversion from byte-a-pixel back to
;	"word-interleaved" bitplanes with the stretch itself
;	taking almost no time at all, than it is to do all the
;	bit twiddling necessary to stretch something in word-
;	interleaved format.  This probably isn't true in medium
;	rez, and certainly not in hi-res, but for 320x200 it
;	seems to be the case, as my stretch is faster than 
;	Neochromes, which Jim Eisenstien tweaked to the point
;	that he managed to get all the variables in registers etc.
;
;	Hope this is useful Jez.  Maybe give you an idea of how
;	easy a fast stretch is to do if you've got a reasonable
;	screen archetecture anyways.



	; stretcht(d, scount, dcount)
firstp	set	2*2+4
d	set	firstp
scount	set	firstp+4
dcount	set	firstp+6
	public _stretcht
_stretcht
	movem.w	d3/d4,-(sp)
	move.l	d(sp),a1
	move.w	scount(sp),d0	; pixels in source
	move.w	dcount(sp),d1	; pixels in dest
	move.w	d1,d2	; "dot count"
	clr.w	d4	; source index
	cmp.w	d0,d1
	bge	bigdest	; test to see if source or dest bigger
	move.w	#-1,d3
	sub.w	#1,d0
	sub.w	#1,d1
	bgt	incdest	; special case for 1 long destination
	move.w	d4,(a1)+
	bra	endstretch
bigdest
	move.w	d0,d3
	asr.w	#1,d3
	sub.w	d1,d3	; d3 = error = scount/2 - dcount
incdest	
	subq.w	#1,d2
	bmi	endstretch
	move.w	d4,(a1)+
	add.w	d0,d3
	bmi	incdest
incsource	
	addq	#1,d4
	sub.w	d1,d3
	bpl	incsource
	bra	incdest
endstretch
	movem.w	(sp)+,d3/d4
	rts



	; xlookup(s, d, t, dcount);
	;	sample dcount pixels of s into d via table t
	public _xlookup
_xlookup
firstp	set	1*4+4
s	set	firstp
d	set	firstp+4
t	set	firstp+8
dcount	set	firstp+12
	move.l	a2,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.l	t(sp),a2
	move.w	dcount(sp),d1
	bra	zxlloop
xlloop	move.w	(a2)+,d0	
	move.b	0(a0,d0.w),d0
	move.b	d0,(a1)+
zxlloop	dbra	d1,xlloop
	move.l	(sp)+,a2
	rts
