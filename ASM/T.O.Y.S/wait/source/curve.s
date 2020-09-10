; Curve definition:
;	dc.w	Points Defined (Not included head and tail)
;	dc.w	Point spacing
; For each point:
;	dc.w	Value
;	dc.w	Type (0 Step, 1 liniar, 2 Cubic-int, 3 Hermite-spl)


; In:	a0 = Curve definition table
;	d0 = Position
; Out:	d0 = Result
CALC_CURVE:
	movem.l	d1-6/a1,-(sp)
	divu.w	2(a0),d0
	move.l	d0,d1
	swap	d0		; Fraction!
	ext.l	d1
	divu.w	(a0),d1
	swap	d1		; Parent point
	lea	8(a0,d1.w*4),a1
	cmp.w	#2,2(a1)
	bgt.s	.Hermite
	beq.s	.Cubic
	tst.w	2(a1)
	bgt.s	.Liniar
.Step:
	move.w	(a1),d0
	bra	.done
.Liniar:
	move.w	4(a1),d1
	muls.w	d0,d1
	sub.w	2(a0),d0
	neg.w	d0
	move.w	(a1),d2
	muls.w	d0,d2
	add.l	d2,d1
	divs.w	2(a0),d1
	move.l	d1,d0
	bra	.done
.Cubic:
	ext.l	d0
; p = (v3 - v2) - (v0 - v1)
	move.w	8(a1),d1
	sub.w	4(a1),d1
	ext.l	d1
	move.w	-4(a1),d2
	sub.w	(a1),d2
	ext.l	d2
	sub.l	d2,d1		; d1 = p
; q = (v0 - v1) - p
	sub.l	d1,d2		; d2 = q
; r = v2 - v0
	move.w	4(a1),d3
	sub.w	-4(a1),d3	; d3 = r
	ext.l	d3
; x^2 = x*x
	move.l	d0,d4
	mulu.l	d4,d4		; d4 = x^2
; qdiv = Step ^ 2
	move.w	2(a0),d5
	mulu.w	d5,d5		; d5 = p div
; p = (p * x^3) / pdiv
	muls.l	d4,d1
	muls.l	d0,d1
	divs.w	d5,d1
; q = (q * x^2) / qdiv
	muls.l	d4,d2
	divs.w	2(a0),d2
; r = (r * x) / Step
	muls.l	d0,d3
	add.w	d2,d1
	add.w	d3,d1
	ext.l	d1
	divs.w	2(a0),d1
	add.w	(a1),d1
	move.l	d1,d0
	bra.s	.done
.Hermite:
; x = x * 256 / Step
	ext.l	d0
	asl.l	#8,d0
	divu.w	2(a0),d0
	ext.l	d0		; d0 = x
; x2 = x * x / 256
	move.l	d0,d1
	mulu.l	d1,d1
	asr.l	#8,d1		; d1 = x2
; x3 = x2 * x / 256
	move.l	d1,d2
	mulu.l	d0,d2
	asr.l	#8,d2		; d2 = x3	
; h4 = x3 - x2
	move.l	d2,d4
	sub.l	d1,d4		; d4 = h4
; h3 = h4 - x2 + x
	move.l	d4,d3
	sub.l	d1,d3
	add.l	d0,d3		; d3 = h3
; h2 = -(x3 * 2) + (x2 * 2)
	add.l	d2,d2
	neg.l	d2
	mulu.l	#3,d1
	add.l	d1,d2		; d2 = h2
; h1 = 256 - h2
	move.l	#$100,d1
	sub.l	d2,d1		; d1 = h1
; dx = v2 - v1
	move.w	4(a1),d5
	sub.w	(a1),d5
	ext.l	d5		; d5 = dx
; i1 = (dx + v3 - v2) / 2
	move.l	d5,d6
	add.w	8(a1),d6
	sub.w	4(a1),d6
	ext.l	d6
	asr.l	d6		; d6 = i1
; i0 = (dx + v1 - v0) / 2
	add.w	(a1),d5
	sub.w	-4(a1),d5
	ext.l	d5
	asr.l	d5		; d5 = i0
; h1 = h1 * v1
	move.w	(a1),d0
	ext.l	d0
	muls.l	d0,d1
; h2 = h2 * v2
	move.w	4(a1),d0
	ext.l	d0
	muls.l	d0,d2
; h3 = h3 * i0	
	muls.l	d5,d3
; h4 = h4 * i1
	muls.l	d6,d4
; result = h1 + h2 + h3 + h4
	add.l	d2,d1
	add.l	d3,d1
	add.l	d4,d1
	asr.l	#8,d1
	move.l	d1,d0
.done:
	ext.l	d0
	movem.l	(sp)+,d1-6/a1
	rts