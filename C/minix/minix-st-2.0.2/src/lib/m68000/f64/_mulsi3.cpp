#ifndef SOZOBON
| long integer multiplication routine
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
|
|
| Revision 1.1, kub 03-90
| first version, replaces the appropriate routine from fixnum.s.
| This one is longer, but normally faster because __umulsi3 is no longer
| called for multiplication. Rather, the code is inlined here. See the
| comments in _umulsi3.s

	.text
	.even
	.globl	__mulsi3, ___mulsi3, .lmul, .ulmul

.lmul:
.ulmul:
__mulsi3:
___mulsi3:
	movel	d2,a0		| save registers
	movel	d3,a1
	movemw	sp@(4),d0-d3	| get the two longs. u = d0-d1, v = d2-d3
	movew	d0,sp@-		| sign flag
	bpl	0f		| is u negative ?
	negw	d1		| yes, force it positive
	negxw	d0
0:	tstw	d2		| is v negative ?
	bpl	0f
	negw	d3		| yes, force it positive ...
	negxw	d2
	notw	sp@		|  ... and modify flag word
0:
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
	tstw	sp@+		| should the result be negated ?
	bpl	3f		| no, just return
	negl	d0		| else r = -r
3:	rts

#else

; long integer multiplication routine
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
;
;
; Revision 1.1, kub 03-90
; first version, replaces the appropriate routine from fixnum.s.
; This one is longer, but normally faster because __umulsi3 is no longer
; called for multiplication. Rather, the code is inlined here. See the
; comments in _umulsi3.s

	.text
	.even
#ifdef GNUNAMES
	.globl	__mulsi3, ___mulsi3
__mulsi3:
___mulsi3:
#else
	.globl	lmul
;	.globl	ulmul
#endif /* GNUNAMES */
lmul:
;ulmul:
	move.l	d2,a0		; save registers
	move.l	d3,a1
	movem.w	4(sp),d0-d3	; get the two longs. u = d0-d1, v = d2-d3
	move.w	d0,-(sp)		; sign flag
	bpl	l01		; is u negative ?
	neg.w	d1		; yes, force it positive
	negx.w	d0
l01:	tst.w	d2		; is v negative ?
	bpl	l02
	neg.w	d3		; yes, force it positive ...
	negx.w	d2
	not.w	(sp)		;  ... and modify flag word
l02:
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
	tst.w	(sp)+		; should the result be negated ?
	bpl	l3		; no, just return
	neg.l	d0		; else r = -r
l3:	rts

#endif /*  SOZOBON */
