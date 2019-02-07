;	:ts=10

	; stretch(s, d, scount, dcount)
firstp	equ	2+4
s	equ	firstp
d	equ	firstp+4
scount	equ	firstp+8
dcount	equ	firstp+10
	public _stretch
_stretch
	move.w	d3,-(sp)
	move.l	s(sp),a0
	move.l	d(sp),a1
	move.w	scount(sp),d0
	move.w	dcount(sp),d1
	move.w	d1,d2	; "dot count"
	move.w	d1,d3
	neg.w	d3
incdest	
	subq.w	#1,d2
	bmi	endstretch
	move.b	(a0),(a1)+
	add.w	d0,d3
	bmi	incdest
incsource	
	addq	#1,a0
	sub.w	d1,d3
	bpl	incsource
	bra	incdest
endstretch
	move.w	(sp)+,d3
	rts

