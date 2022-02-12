#ifndef SOZOBON
| unsigned long division and modulus routines
|
| written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
|
|
| Revision 1.1, kub 03-90
| first version, replaces the appropriate routine from fixnum.s.
| Should be faster in more common cases. Division is done by 68000 divu
| operations if divisor is only 16 bits wide. Otherwise the normal division
| algorithm as described in various papers takes place. The division routine
| delivers the quotient in d0 and the remainder in d1, thus the implementation
| of the modulo operation is trivial.

	.text
	.even
	.globl	__udivsi3, ___udivsi3, .uldiv
	.globl	__umodsi3, ___umodsi3, .ulrem

.uldiv:
__udivsi3:
___udivsi3:
	movel	d2,a0		| save registers
	movel	d3,a1
	clrl	d0		| prepare result
	movel	sp@(8),d2	| get divisor
	beq	9f		| divisor = 0 causes a division trap
	movel	sp@(4),d1	| get dividend
|== case 1) divident < divisor
	cmpl	d2,d1		| is divident smaller then divisor ?
	bcs	8f		| yes, return immediately
|== case 2) divisor has <= 16 significant bits
	tstw	sp@(8)
	bne	2f		| divisor has only 16 bits
	movew	d1,d3		| save dividend
	clrw	d1		| divide dvd.h by dvs
	swap	d1
	beq	0f		| (no division necessary if dividend zero)
	divu	d2,d1
0:	movew	d1,d0		| save quotient.h
	swap	d0
	movew	d3,d1		| (d1.h = remainder of prev divu)
	divu	d2,d1		| divide dvd.l by dvs
	movew	d1,d0		| save quotient.l
	clrw	d1		| get remainder
	swap	d1
	bra	8f		| and return
|== case 3) divisor > 16 bits (corollary is dividend > 16 bits, see case 1)
2:
	moveq	#31,d3		| loop count
3:
	addl	d1,d1		| shift divident ...
	addxl	d0,d0		|  ... into d0
	cmpl	d2,d0		| compare with divisor
	bcs	0f
	subl	d2,d0		| big enough, subtract
	addw	#1,d1		| and note bit in result
0:
	dbra	d3,3b
	exg	d0,d1		| put quotient and remainder in their registers
8:
	movel	a1,d3
	movel	a0,d2
	rts
9:
	divu	d2,d1		| cause division trap
	bra	8b		| back to user


.ulrem:
__umodsi3:
___umodsi3:
	movel	sp@(8),sp@-	| push divisor
	movel	sp@(8),sp@-	| push dividend
	jbsr	__udivsi3
	addql	#8,sp
	movel	d1,d0		| return the remainder in d0
	rts

#else

; unsigned long division and modulus routines
;
; written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
;
;
; Revision 1.1, kub 03-90
; first version, replaces the appropriate routine from fixnum.s.
; Should be faster in more common cases. Division is done by 68000 divu
; operations if divisor is only 16 bits wide. Otherwise the normal division
; algorithm as described in various papers takes place. The division routine
; delivers the quotient in d0 and the remainder in d1, thus the implementation
; of the modulo operation is trivial.

	.text
	.even
#ifdef GNUNAMES
	.globl	__udivsi3, ___udivsi3
	.globl	__umodsi3, ___umodsi3
__udivsi3:
___udivsi3:
#else
	.globl	ldivu
	.globl	lremu
#endif /* GNUNAMES */

ldivu:
	move.l	d2,a0		; save registers
	move.l	d3,a1
	clr.l	d0		; prepare result
	move.l	8(sp),d2	; get divisor
	beq	l9		; divisor = 0 causes a division trap
	move.l	4(sp),d1	; get dividend
;== case 1) divident < divisor
	cmp.l	d2,d1		; is divident smaller then divisor ?
	bcs	l8		; yes, return immediately
;== case 2) divisor has <= 16 significant bits
	tst.w	8(sp)
	bne	l2		; divisor has only 16 bits
	move.w	d1,d3		; save dividend
	clr.w	d1		; divide dvd.h by dvs
	swap	d1
	beq	l01		; (no division necessary if dividend zero)
	divu	d2,d1
l01:	move.w	d1,d0		; save quotient.h
	swap	d0
	move.w	d3,d1		; (d1.h = remainder of prev divu)
	divu	d2,d1		; divide dvd.l by dvs
	move.w	d1,d0		; save quotient.l
	clr.w	d1		; get remainder
	swap	d1
	bra	l8		; and return
;== case 3) divisor > 16 bits (corollary is dividend > 16 bits, see case 1)
l2:
	moveq	#31,d3		; loop count
l3:
	add.l	d1,d1		; shift divident ...
	addx.l	d0,d0		;  ... into d0
	cmp.l	d2,d0		; compare with divisor
	bcs	l02
	sub.l	d2,d0		; big enough, subtract
	add.w	#1,d1		; and note bit in result
l02:
	dbra	d3,l3
	exg	d0,d1		; put quotient and remainder in their registers
l8:
	move.l	a1,d3
	move.l	a0,d2
	rts
l9:
	divu	d2,d1		; cause division trap
	bra	l8		; back to user

#ifdef GNUNAMES
__umodsi3:
___umodsi3:
#else
lremu:
#endif /* GNUNAMES */
	move.l	8(sp),-(sp)	; push divisor
	move.l	8(sp),-(sp)	; push dividend
	bsr	ldivu
	addq.l	#8,sp
	move.l	d1,d0		; return the remainder in d0
	rts

#endif /* SOZOBON */
