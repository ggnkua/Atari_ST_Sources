#ifndef SOZOBON
| unsigned long integer multiplication routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
|
|
| Revision 1.1, kub 03-90
| first version, replaces the appropriate routine from fixnum.s.
| This one is short and fast for the common case of both longs <= 0x0000ffff,
| but the case of a zero lowword is no longer recognized.
| (besides its easier to read this source 8-)

	.text
	.even
	.globl	__umulsi3, ___umulsi3

__umulsi3:
___umulsi3:
	movel	d2,a0		| save registers
	movel	d3,a1
	movemw	sp@(4),d0-d3	| get the two longs. u = d0-d1, v = d2-d3
	extl	d0		| u.h <> 0 ?
	beq	1f
	mulu	d3,d0		| r  = v.l * u.h
1:	tstw	d2		| v.h <> 0 ?
	beq	2f
	mulu	d1,d2		| r += v.h * u.l
	addw	d2,d0
2:	swap	d0
	clrw	d0
	mulu	d3,d1		| r += v.l * u.l
	addl	d1,d0
	movel	a1,d3
	movel	a0,d2
	rts

#else

; unsigned long integer multiplication routine
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
;
;
; Revision 1.1, kub 03-90
; first version, replaces the appropriate routine from fixnum.s.
; This one is short and fast for the common case of both longs <= 0x0000ffff,
; but the case of a zero lowword is no longer recognized.
; (besides its easier to read this source 8-)

	.text
	.even
#ifdef GNUNAMES
	.globl	__umulsi3, ___umulsi3
__umulsi3:
___umulsi3:
#else
	.globl	lmulu
#endif /* GNUNAMES */
lmulu:
	move.l	d2,a0		; save registers
	move.l	d3,a1
	movem.w	4(sp),d0-d3	; get the two longs. u = d0-d1, v = d2-d3
	ext.l	d0		; u.h <> 0 ?
	beq	l1
	mulu	d3,d0		; r  = v.l * u.h
l1:	tst.w	d2		; v.h <> 0 ?
	beq	l2
	mulu	d1,d2		; r += v.h * u.l
	add.w	d2,d0
l2:	swap	d0
	clr.w	d0
	mulu	d3,d1		; r += v.l * u.l
	add.l	d1,d0
	move.l	a1,d3
	move.l	a0,d2
	rts
	
#endif /* SOZOBON */
