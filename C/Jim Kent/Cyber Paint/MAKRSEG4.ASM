
;	:ts=10

	;fix_rseg(rs, ycount);
	;	convert x1 x2 representation to xoff, height ...
	;	and do some swapping if x1 > x2
	public _fix_rseg
firstp	set	2*4+4
rs	set	firstp
ycount	set	firstp+2
_fix_rseg
	movem.l	d3/d4,-(sp)
	move.l	rs(sp),a0
	move.l	ycount(sp),d4
	addq	#8,a0	; point to x1/x2 dest part of structure
	bra	zfix_loop
fix_loop	
	; first grab x endpoints and see if need to swap
	move.w	(a0),d0	; grab x1	dest
	move.w	2(a0),d1	; grab x2 dest
	cmp.w	d0,d1
	bpl	noswap

	; swap endpoints if necessary
	move.l	-8(a0),d2	; grab 1st point of source
	move.l	-4(a0),d3	; grab 2nd point of source
	move.l	d2,-4(a0)
	move.l	d3,-8(a0)
	exg	d0,d1
	move.w	d0,(a0)	; store x offset

noswap	sub.w	d0,d1	; find x2-x1
	addq.w	#1,d1	; don't forget the extra pixel!
	move.w	d1,2(a0)	; store the width
	adda.w	#12,a0	; and move pointer to next structure

zfix_loop	dbra	d4,fix_loop
	movem.l	(sp)+,d3/d4
	rts

