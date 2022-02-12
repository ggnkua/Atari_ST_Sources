#ifndef SOZOBON
| long division and modulus routines
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
| of the modulo operation is trivial. We gain some extra speed by inlining
| the division code here instead of calling __udivsi3.

	.text
	.even
	.globl	__divsi3, ___divsi3, .ldiv
	.globl	__modsi3, ___modsi3, .lrem

.ldiv:
__divsi3:
___divsi3:
	movel	d2,a0		| save registers
	movel	d3,a1
	clrw	sp@-		| sign flag
	clrl	d0		| prepare result
	movel	sp@(10),d2	| get divisor
	beq	9f		| divisor = 0 causes a division trap
	bpl	0f		| divisor < 0 ?
	negl	d2		| negate it
	notw	sp@		| remember sign
0:	movel	sp@(6),d1	| get dividend
	bpl	0f		| dividend < 0 ?
	negl	d1		| negate it
	notw	sp@		| remember sign
0:
|== case 1) divident < divisor
	cmpl	d2,d1		| is divident smaller then divisor ?
	bcs	8f		| yes, return immediately
|== case 2) divisor has <= 16 significant bits
	tstw	sp@(10)
	bne	2f		| divisor has only 16 bits
	movew	d1,d3		| save dividend
	clrw	d1		| divide dvd.h by dvs
	swap	d1
	beq	0f		| (no division necessary if dividend zero)
	divu	d2,d1
0:	movew	d1,d0		| save quotient.h
	swap	d0
	movew	d3,d1		| (d0.h = remainder of prev divu)
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
	addqw	#1,d1		| and note bit into result
0:
	dbra	d3,3b
	exg	d0,d1		| put quotient and remainder in their registers
8:
	tstw	sp@(6)		| must the remainder be corrected ?
	bpl	0f
	negl	d1		| yes, apply sign
| the following line would be correct if modulus is defined as in algebra
|	addl	sp@(6),d1	| algebraic correction: modulus can only be >= 0
0:	tstw	sp@+		| result should be negative ?
	bpl	0f
	negl	d0		| yes, negate it
0:
	movel	a1,d3
	movel	a0,d2
	rts
9:
	divu	d2,d1		| cause division trap
	bra	8b		| back to user


.lrem:
__modsi3:
___modsi3:
	movel	sp@(8),sp@-	| push divisor
	movel	sp@(8),sp@-	| push dividend
	jbsr	__divsi3
	addql	#8,sp
	movel	d1,d0		| return the remainder in d0
	rts

#else

; long division and modulus routines
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
; of the modulo operation is trivial. We gain some extra speed by inlining
; the division code here instead of calling __udivsi3.

	.text
	.even
#ifdef GNUNAMES
	.globl	__divsi3, ___divsi3
	.globl	__modsi3, ___modsi3
__divsi3:
___divsi3:
#else
	.globl	ldiv
	.globl	lrem
#endif /* GNUNAMES */

ldiv:
	move.l	d2,a0		; save registers
	move.l	d3,a1
	clr.w	-(sp)		; sign flag
	clr.l	d0		; prepare result
	move.l	10(sp),d2	; get divisor
	beq	l9		; divisor = 0 causes a division trap
	bpl	l01		; divisor < 0 ?
	neg.l	d2		; negate it
	not.w	(sp)		; remember sign
l01:	move.l	6(sp),d1	; get dividend
	bpl	l02		; dividend < 0 ?
	neg.l	d1		; negate it
	not.w	(sp)		; remember sign
l02:
;== case 1) divident < divisor
	cmp.l	d2,d1		; is divident smaller then divisor ?
	bcs	l8		; yes, return immediately
;== case 2) divisor has <= 16 significant bits
	tst.w	10(sp)
	bne	l2		; divisor has only 16 bits
	move.w	d1,d3		; save dividend
	clr.w	d1		; divide dvd.h by dvs
	swap	d1
	beq	l03		; (no division necessary if dividend zero)
	divu	d2,d1
l03:	move.w	d1,d0		; save quotient.h
	swap	d0
	move.w	d3,d1		; (d0.h = remainder of prev divu)
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
	bcs	l04
	sub.l	d2,d0		; big enough, subtract
	addq.w	#1,d1		; and note bit into result
l04:
	dbra	d3,l3
	exg	d0,d1		; put quotient and remainder in their registers
l8:
	tst.w	6(sp)		; must the remainder be corrected ?
	bpl	l05
	neg.l	d1		; yes, apply sign
; the following line would be correct if modulus is defined as in algebra
;	add.l	6(sp),d1	; algebraic correction: modulus can only be >= 0
l05:	tst.w	(sp)+		; result should be negative ?
	bpl	l06
	neg.l	d0		; yes, negate it
l06:
	move.l	a1,d3
	move.l	a0,d2
	rts
l9:
	divu	d2,d1		; cause division trap
	bra	l8		; back to user


#ifdef GNUNAMES
__modsi3:
___modsi3:
#endif /* GNUNAMES */
lrem:
	move.l	8(sp),-(sp)	; push divisor
	move.l	8(sp),-(sp)	; push dividend
	bsr	ldiv
	addq.l	#8,sp
	move.l	d1,d0		; return the remainder in d0
	rts

#endif /* SOZOBON */
