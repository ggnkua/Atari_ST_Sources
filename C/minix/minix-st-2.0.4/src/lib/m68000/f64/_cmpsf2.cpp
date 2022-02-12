#ifndef SOZOBON
| single floating point compare routine
|
| written by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
| Based on a 68k floating point packet from Kai-Uwe Bloem, itself based
| on a 80x86 floating point packet from comp.os.minix, written by P.Housel
|
| Revision 2.0: olaf 12-92.
| Revision 2.1: michal 05-93 allow for splitting in separate objects in make
|

#ifdef __DEF_ALL__	/* this def'ed when making on the ST */

/* gcc-2.0 stuff */
#define L_eqsf2
#define L_gtsf2
#define L_lesf2
#define L_gesf2
#define L_ltsf2

#endif /* __DEF_ALL__ */

#ifdef L_eqsf2
	.text
	.even
	.globl	___eqsf2, ___nesf2
	| additional entry points for gcc 1.X
	.globl	__cmpsf2, ___cmpsf2

__cmpsf2:
___cmpsf2:
___eqsf2:
___nesf2:
	moveml	sp@(4),d0-d1	| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d0
	bchg	#31,d0		| toggle sign bit

1:	tstl	d1		| check sign bit
	bpl	2f
	negl	d1		| negate
	bchg	#31,d1		| toggle sign bit

2:	cmpl	d1,d0
	bne	4f
	bclr	#31,d1
	cmpl	#0x7f800000,d1		| NaN is not equal NaN !
	bgt	4f
	moveq	#0,d0
	rts

4:	moveql	#1,d0
	rts
#endif /* L_eqsf2 */

#ifdef L_gtsf2
	.text
	.even
	.globl	___gtsf2
___gtsf2:
	moveml	sp@(4),d0-d1	| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d0		| negate
	bchg	#31,d0		| toggle sign bit

1:	tstl	d1		| check sign bit
	bpl	2f
	negl	d1		| negate
	bchg	#31,d1		| toggle sign bit

2:	cmpl	d1,d0
	bgt	4f		| d0 > d1 Test if NaN (should be false!)
3:	moveq	#0,d0		| Test is false.
	rts

4:	bclr	#31,d0
	cmpl	#0x7f800000,d0	| First operand == NaN =?
	bgt	3b
	moveql	#1,d0		| Test True
	rts
#endif /* L_gtsf2 */

#ifdef L_lesf2
	.text
	.even
	.globl  ___lesf2
___lesf2:
	moveml	sp@(4),d0-d1	| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d0		| negate
	bchg	#31,d0		| toggle sign bit

1:	tstl	d1		| check sign bit
	bpl	2f
	negl	d1		| negate
	bchg	#31,d1		| toggle sign bit

2:	cmpl	d1,d0
	ble	4f
3:	moveql	#1,d0		| Test is false
	rts
4:	bclr	#31,d0
	cmpl	#0x7f800000,d0	| First operand == NaN =?
	bgt	3b
	moveq	#0,d0		| Test true
	rts
#endif /* L_lesf2 */

#ifdef L_gesf2
	.text
	.even
	.globl	___gesf2
___gesf2:
	moveml	sp@(4),d0-d1	| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d0		| negate
	bchg	#31,d0		| toggle sign bit

1:	tstl	d1		| check sign bit
	bpl	2f
	negl	d1		| negate
	bchg	#31,d1		| toggle sign bit

2:	cmpl	d1,d0
	bge	4f
3:	moveql	#-1,d0		| False
	rts

4:	bclr	#31,d0
	cmpl	#0x7f800000,d0	| First operand == NaN =?
	bgt	3b
	moveq	#0,d0		| Test True
	rts
#endif /* L_gesf2 */

#ifdef L_ltsf2
	.text
	.even
	.globl	 ___ltsf2
___ltsf2:
	moveml	sp@(4),d0-d1	| get numbers to compare with
	tstl	d0		| check sign bit
	bpl	1f
	negl	d0		| negate
	bchg	#31,d0		| toggle sign bit

1:	tstl	d1		| check sign bit
	bpl	2f
	negl	d1		| negate
	bchg	#31,d1		| toggle sign bit

2:	cmpl	d1,d0
	blt	4f
3:	moveq	#0,d0
	rts
4:	bclr	#31,d0
	cmpl	#0x7f800000,d0	| First operand == NaN =?
	bgt	3b
5:	moveql	#-1,d0		| Test True
	rts
#endif /* L_ltsf2 */

#else

; single floating point compare routine
;
; written by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
; Based on a 68k floating point packet from Kai-Uwe Bloem, itself based
; on a 80x86 floating point packet from comp.os.minix, written by P.Housel
;
; Revision 2.0: olaf 12-92.
; Revision 2.1: michal 05-93 allow for splitting in separate objects in make
;

	.text
	.even
#ifdef GNUNAMES
	.globl	___eqsf2, ___nesf2
	; additional entry points for gcc 1.X
	.globl	__cmpsf2, ___cmpsf2

__cmpsf2:
___cmpsf2:
___eqsf2:
___nesf2:
#else
	.globl	fpfcmp
#endif /* GNUNAMES */

fpfcmp:
	movem.l	4(sp),d0-d1	; get numbers to compare with
	tst.l	d0		; check sign bit
	bpl	l1
	neg.l	d0
	bchg	#31,d0		; toggle sign bit

l1:	tst.l	d1		; check sign bit
	bpl	l2
	neg.l	d1		; negate
	bchg	#31,d1		; toggle sign bit

l2:	cmp.l	d1,d0
	blt	lt
	bgt	gt
	bclr	#31,d1
	cmp.l	#$7f800000,d1		; NaN is not equal NaN !
	bgt	gt
	moveq	#0,d0
	rts

gt:	moveq.l	#1,d0
	rts

lt:	moveq.l	#-1,d0
	rts
#endif /* SOZOBON */

