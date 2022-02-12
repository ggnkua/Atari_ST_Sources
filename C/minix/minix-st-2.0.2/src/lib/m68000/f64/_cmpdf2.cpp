#ifndef SOZOBON
| double floating point compare routine
|
| written by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
| Based on a 68k floating point packet from Kai-Uwe Bloem, itself based
| on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 2.0: olaf 12-92.
| Revision 2.1: michal 05-93 allow for splitting in separate objects in make

#ifdef __DEF_ALL__	/* this def'ed when making on the ST */

/* gcc-2.0 stuff */
#define L_eqdf2
#define L_gtdf2
#define L_ledf2
#define L_gedf2
#define L_ltdf2

#endif /* __DEF_ALL__ */

#ifdef L_eqdf2
	.text
	.even
	.globl	___eqdf2, ___nedf2
	.globl	__cmpdf2, ___cmpdf2

__cmpdf2:
___cmpdf2:
___eqdf2:
___nedf2:
	moveml	sp@(4),d0-d1/a0-a1		| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

1:	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	2f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

2:	cmpl	d1,a1
	bne	4f
	cmpl	d0,a0
	bne	4f
	bclr	#31,d0
	cmpl	#0x7ff00000,d0		| NaN is not equal NaN !
	bgt	4f
	blt	3f
	tstl	d1
	bne	4f
3:	moveq	#0,d0
	rts

4:	moveql	#1,d0
	rts
#endif /* L_eqdf2 */

#ifdef L_gtdf2
	.text
	.even
	.globl	___gtdf2
___gtdf2:
	moveml	sp@(4),d0-d1/a0-a1		| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

1:	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	2f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

2:	exg	a0,d0
	exg	a1,d1
	cmpl	a0,d0
	bgt	4f		| d0 > a0 Test if NaN (should be false!)
	blt	3f		|
	cmpl	a1,d1
	bhi	4f
3:	moveq	#0,d0		| Test is false.
	rts
4:	bclr	#31,d0
	cmpl	#0x7ff00000,d0	| First operand == NaN =?
	bgt	3b
	blt	5f		| It is finite!
	tstl	d1
	bne	3b		| It *is* a NaN
5:	moveql	#1,d0		| Test True
	rts
#endif /* L_gtdf2 */

#ifdef L_ledf2
	.text
	.even
	.globl	___ledf2
___ledf2:
	moveml	sp@(4),d0-d1/a0-a1		| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

1:	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	2f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

2:	cmpl	d0,a0
	blt	4f
	bgt	3f
	cmpl	d1,a1
	bls	4f	        | <= !
3:	moveql	#1,d0		| Test is false
	rts
4:	bclr	#31,d0
	cmpl	#0x7ff00000,d0	| First operand == NaN =?
	bgt	3b
	blt	5f		| It is finite!
	tstl	d1
	bne	3b		| It *is* a NaN
5:	moveq	#0,d0		| Test true
	rts
#endif /* L_ledf2 */


#ifdef L_gedf2
	.text
	.even
	.globl	___gedf2
___gedf2:
	moveml	sp@(4),d0-d1/a0-a1		| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

1:	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	2f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

2:	exg	a0,d0
	exg	a1,d1
	cmpl	a0,d0
	bgt	4f
	blt	3f
	cmpl	a1,d1
	beq	4f		| >= !
	bhi	4f
3:	moveql	#-1,d0		| False
	rts
4:	bclr	#31,d0
	cmpl	#0x7ff00000,d0	| First operand == NaN =?
	bgt	3b
	blt	5f		| It is finite!
	tstl	d1
	bne	3b		| It *is* a NaN
5:	moveq	#0,d0		| Test True
	rts
#endif /* L_gedf2 */

#ifdef L_ltdf2
	.text
	.even
	.globl	___ltdf2
___ltdf2:
	moveml	sp@(4),d0-d1/a0-a1		| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

1:	exg	a0,d0
	exg	a1,d1
	tstl	d0		| check sign bit
	bpl	2f
	negl	d1		| negate
	negxl	d0
	bchg	#31,d0		| toggle sign bit

2:	cmpl	d0,a0
	blt	4f
	bgt	3f
	cmpl	d1,a1
	beq	3f
	bls	4f
3:	moveq	#0,d0
	rts
4:	bclr	#31,d0
	cmpl	#0x7ff00000,d0	| First operand == NaN =?
	bgt	3b
	blt	5f		| It is finite!
	tstl	d1
	bne	3b		| It *is* a NaN
5:	moveql	#-1,d0		| Test True
	rts
#endif /* L_ltdf2 */

#else

; double floating point compare routine
;
; written by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
; Based on a 68k floating point packet from Kai-Uwe Bloem, itself based
; on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 2.0: olaf 12-92.
; Revision 2.1: michal 05-93 allow for splitting in separate objects in make

	.text
	.even
#ifdef GNUNAMES
	.globl	___eqdf2, ___nedf2
	.globl	__cmpdf2, ___cmpdf2
__cmpdf2:
___cmpdf2:
___eqdf2:
___nedf2:
#else
	.globl	fpdcmp
#endif /* GNUNAMES */
fpdcmp:
	movem.l	4(sp),d0-d1/a0-a1		; get numbers to compare with
	tst.l	d0		; check sign bit
	bpl	l1
	neg.l	d1		; negate
	negx.l	d0
	bchg	#31,d0		; toggle sign bit

l1:	exg	a0,d0
	exg	a1,d1
	tst.l	d0		; check sign bit
	bpl	l2
	neg.l	d1		; negate
	negx.l	d0
	bchg	#31,d0		; toggle sign bit

l2:	cmp.l	d1,a1
	bne	l4
	cmp.l	d0,a0
	bne	l4
	bclr	#31,d0
	cmp.l	#$7ff00000,d0		; NaN is not equal NaN !
	bgt	l4
	blt	l3
	tst.l	d1
	bne	l4
l3:	moveq	#0,d0
	rts

l4:	cmp.l	d0,a0
	blt	lt
	bgt	gt
	cmp.l	d1,a1
	bhi	gt
;	beq	l3

lt:	moveq.l	#-1,d0
	rts

gt:	moveq.l	#1,d0
	rts

#endif /* SOZOBON */
