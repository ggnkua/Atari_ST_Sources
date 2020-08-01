; BMATHS.S: Basic integer maths and logic module
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even
;
;_UDMOD:	(u32,u32--u32,u32)
_udmod: movem.l d2/d5,-(a7)
	moveq	#31,d5		;loop counter
	pop	d2		;divisor
	pop	d1		;dividend
	moveq	#0,d0
.udmlp: add.l	d1,d1
	addx.l	d0,d0		;shift dividend left
	cmp.l	d2,d0		;can we divide?
	bcs.s	.udm5		;otherwise branch
	sub.l	d2,d0
	addq.w	#1,d1
.udm5:	dbra	d5,.udmlp
	push	d0		;remainder
	push	d1		;quotient
	movem.l (a7)+,d2/d5
udmx:	rts
;
; _UMULT: (n16,n16--n32)
_umult:
	pop	d0
	pop	d1
	mulu	d1,d0
	push	d0
umx:	rts
;
; _UXMULT:	(u32,u32--u64)
_uxmult: movem.l d2-d3,-(a7)
	clr.l	d3		;highest word ready for overflow
	move.w	2(a6),d0
	mulu	6(a6),d0
	move.l	d0,d1
	clr.w	d1		;remove low word
	swap	d1		;get carry ready in low word
	move.w	(a6),d2
	mulu	6(a6),d2
	add.l	d1,d2		;build words1&2
	bcc	.nc1
	addq.l	#1,d3		;carry into top word?
.nc1:	move.w	2(a6),d1
	mulu	4(a6),d1
	add.l	d1,d2		;add to words1&2
	bcc	.nc2
	addq.l	#1,d3		;carry into top word?
.nc2:	move.w	(a6),d1
	mulu	4(a6),d1	;build top word
	swap	d1
	add.w	d1,d3		;word3 of product
	clr.w	d1		;strip high half
	add.l	d1,d2		;complete words 1 & 2
	bcc	.nc3
	addq.l	#1,d3
.nc3:	move.w	d0,6(a6)
	move.l	d2,2(a6)
	move.w	d3,(a6)
	movem.l (a7)+,d2-d3
uxmx:	rts
;
	section	data
	even
;
 	dc.b	$85,'U/MO','D'!$80
	lptrs	_udmod,(udmx-_udmod)/2,18
;
	dc.b	$83,'UM','*'!$80
	lptrs	_uxmult,(uxmx-_uxmult)/2,16
;
	dc.b	$82,'U*',$a0
	lptrs	_umult,(umx-_umult)/2,16
