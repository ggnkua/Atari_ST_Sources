*+
*
*  Quickly zero (lots of) memory.
*
*  Synopsis:	clear(start, count)
*		    LONG start;	    4(sp) -> first location
*		    LONG count;	    8(sp) = #bytes to clobber
*
*    Uses:	C registers d0-d2/a0-a2
*
*-
_clear::
	move.l	4(sp),a0		; a0 -> start
	move.l	8(sp),a1		; a1 = count
	add.l	a0,a1			; ... a1 -> endLocation+1

	movem.l	d3-d7/a3,-(sp)		; save registers
	moveq	#0,d1			; clear d1-d7/a3
	moveq	#0,d2			;	to get 32 bytes of zeros
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a3

	move.l	a0,d0			; word align first location
	btst	#0,d0
	beq.s	.1			; (not necessary)
	move.b	d1,(a0)+

.1:	move.l	a1,d0			; d0 = ((a1 - a0) & ~0xff)
	sub.l	a0,d0
	and.l	#$ffffff00,d0		; mask fractional bits, d0 = whole part
	beq.s	.3			; if (d0 == 0) do end-fraction;
	lea	(a0,d0.l),a0		; a0 -> end of huge area
	move.l	a0,a2			; a2 -> there, too
	lsr.l	#8,d0			; get 256-byte chunk count
.2:
    .rept 8
	movem.l	d1-d7/a3,-(a2)		; clear 256 bytes (32 x 8)
    .endr
	subq.l	#1,d0			; decrement count
	bne.s	.2			; while (d0) clear some more...

.3:	cmp.l	a0,a1			; while (a0 != a1)
	beq.s	.4			; (done)
	move.b	d1,(a0)+		; clear a byte
	bra.s	.3

.4:	movem.l	(sp)+,d3-d7/a3		; restore registers and return
	rts
