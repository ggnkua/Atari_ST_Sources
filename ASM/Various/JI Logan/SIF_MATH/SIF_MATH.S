* 21 June 1994
*
* sif (sign-integer-fraction) math routines
*
* Written in 68000 assembler using Devpac-3
*
* Each sif number is 32 bits long and has an imaginary binary point between
* bits 15 and 16 giving the format %siiiiiiiiiiiiiii.ffffffffffffffff. The
* integer range is from $FFFF0000 to $EFFF0000 (-32767 to +32767). The
* fraction range is from $00000001 (0.000015 to six decimal places) to
* $0000FFFF (0.999984 to six decimal places). The 2's complement system is
* used but for multiplication and division the number is converted to an
* unsigned format before the operation and converted back after.
*
* The number $80000000 ("-32767.999984") is reserved as an indicator of
* overflow. This number is assumed to behave like infinity. Any number
* added to, subtracted from, multiplied by or divided into infinity equals
* infinity. Infinity subtracted from a number should be minus infinity
* presumably but this cannot be indicated here and is simply called
* infinity. Any number divided by infinity equals zero.
*
* Routines available are load, store, dup (duplicate d7 to d6) ladd, lsub,
* lcmp, lmul, ldiv, power2, root2, log2, alog2, log10, and power.
*
* The routines were written for use in a physiological simulator (a model
* of the blood circulation) where the restricted range was not of import-
* ance but speed was.
*
* The module can be included in your own programme:
*
*           include     SIF_MATH.S
*
* and can be used by calling the appropriate routine. To make the listing
* look neater, I have used macros which load d6 and then jump to the
* appropriate subroutine.
*
* Example 1
* calculate the circumference of a circle
* pi        dc.l        $0003243F
*
*           load        #pi		load pi (= 355/113)
*           lmul        #$00020000		load '2', d6*d7->d7
*           lmul        radius(a5)		load radius, d6*d7->d7
*           store	circumference(a5)	store result
*
*
* Example 2
* test for overflow
*	load	result
*	lcmp	#infinity
*	beq	overflow
*
*
* Example 3
* taken from a physiological simulator
* IF PRA >= 8.028 THEN FA:= ((PRA * (-4.256E-2)) + 13.806) * HS * SYMHSM;
*	load	pra(a5)
*	lcmp	#$0008072B		8.028
*	blt	.pra1
*	lmul	#$FFFFF51B		-0.04256
*	ladd	#$000DCE56		13.806
* 	lmul	hs(a5)
*	lmul	symhsm(a5)
*	store	fa(a6)
*	bra	.continue
* .pra1	(further code)
* .continue
*
*
* Example 4
* taken from MATH_TST.S
*	load	yhexnum
*	root2
*	txt_gaddr	#rooty
*	bsr	hextodcmlo
*	draw	form_addr,#rooty
*
*
* Data register d7 is used as an accumulator and all operations act on it.
* Second operators (if given) are loaded into d6 by the calling macro.
*
* NB If you wish to perform an operation using the value already in d6
*    then you should specify d6 as the second operator.
*
* Example 5
*           lmul        d6          uses values in d6 and d7
*
*
* Most routines are based on those given by Eric Huggins in his most
* invaluable book "Microprocessors and Microcomputers - Their Use and
* Programming" published by The Macmillan Press Ltd in 1979. Other sources
* were "Programming the 68000" by Tim King and Brian Knight published by
* Addison-Wesley Publishing Company in 1983, and "Computer Arithmetic -
* Logic and Design" by Otto Spaniol published by John Wiley & Sons in 1981.
* The latter contains routines for speeding up multiplication and division
* but I have not been able to implement them. Any advice or coding leading
* to faster routines would be welcome.
*
*
* MATH_TST.PRG shows the limitations of the number format and allows you
* to check the accuracy of the routines.
*
* Please contact me if you have any comments or queries. SIF_MATH.S and
* MATH_TST.PRG are in the Public Domain and may be freely copied and used.
* Please distribute all files together.
*
* JI Logan, Belfast City Hospital, Lisburn Road, Belfast BT9 7AB, UK.

	SECTION TEXT

	bra	sif_end


infinity	equ	$80000000


load	macro	d7 = memory
	move.l	\1,d7
	endm


store	macro	memory = d7
	move.l	d7,\1
	endm


dup	macro	d6 = d7
	move.l	d7,d6
	endm



* Compare
*
* Compare d7 with second operator if given or with d6. This simply
* uses the standard cmp.l and is only given for uniformity with the
* other operators.
lcmp	macro	compare by (d7 - d6)
	cmp.l	\1,d7
	endm



* Addition
*
* Check for infinity (answer is infinity if d7 or d6 infinity)
* and deal with overflow.

ladd	macro	d7 = d7 + d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	ladd.sr	do it
	endm
ladd.sr	lcmp	#infinity,d7
	beq	.exit
	lcmp	#infinity,d6
	beq	.overflow
	add.l	d6,d7
	bvc	.exit
.overflow	move.l	#infinity,d7
.exit	rts



* Subtraction
*
* Check for infinity (answer is infinity if d6 or d7 infinity)
* and deal with overflow.

lsub	macro	d7 = d7 - d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	lsub.sr	do it
	endm
lsub.sr	lcmp	#infinity,d7
	beq	.exit
	lcmp	#infinity,d6
	beq	.overflow
	sub.l	d6,d7
	bvc	.exit
.overflow	move.l	#infinity,d7
.exit	rts



* Multiplication
*
* Check both y and x for infinity and sign. If negative make positive.
* d7 * d6 -> d7. The 68000 does not have a 32 bit multiply instruction
* but does have a 16 * 16 bit instruction. This is used to form the
* partial products (fraction2 * fraction1, integer2 * fraction1,
* fraction2 * integer1 and integer2 * integer1) which are then added.
* Of the 64 bit answer, only the middle 32 bits are preserved. The upper
* 16 and lower 16 bits are discarded after using them to test for over-
* flow and rounding respectively.

lmul	macro	d7 = d7 * d6
	IFNC	'\1','d6'
	move.l	\1,d6		load x if given
	ENDC
	bsr	lmul.sr		basic routine
	endm
lmul.sr	movem.l	d3-5,-(a7)		save registers
	clr.w	d3		clear sign
	tst.l	d7
	bpl	.yplus
	neg.l	d7
	bmi	.overflow		d7 = infinity
	eori.w	#1,d3		d7 negative
.yplus	tst.l	d6
	bpl	.xplus
	neg.l	d6
	bmi	.overflow		d6 = infinity
	eori.w	#1,d3		d6 negative
.xplus	move.l	d7,d5		copy num_2
	move.l	d7,d4		 and again
	mulu	d6,d7		frac_2 * frac_1
	addi.l	#$00008000,d7	roundoff result
	clr.w	d7		forget least signif word
	swap	d7		shift right 16 times
	swap	d5		access int_2
	mulu	d6,d5		int_2 * frac_1
	add.l	d5,d7		add to result
	swap	d6		access int_1
	move.l	d4,d5		copy num_2
	mulu	d6,d5		frac_2 * int_1
	add.l	d5,d7		add to result
	swap	d4		access int_2
	mulu	d6,d4		int_2 * int_1
	swap	d4		shift left 16 times
	tst.w	d4		word <> 0 means overflow
	bne	.overflow
	add.l	d4,d7		result
	bmi	.overflow		overflow if bit #31 set
	tst.w	d3		sign
	beq	.exit		= 0 positive result
	neg.l	d7		<> 0 negative
	bra	.exit
.overflow	move.l	#infinity,d7
.exit	movem.l	(a7)+,d3-5		restore registers
	rts			and return



* Division
*
* Check both y and x for infinity and sign. If negative make positive.
* d7 / d6 -> d7. The 68000 does not have a 32 bit divide instruction and
* unlike the multiply routine, use cannot be made of the 32 / 16 bit
* instruction. This routine therefore does the division completely in
* software using a restoring algorithm.
*
* >>>> If anyone knows how to code a quicker algorithm (eg non-restoring
* with shift over zeros and ones) then please let me know <<<<.

ldiv	macro	d7 = d7 / d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	ldiv.sr
	endm

* clear low d3 to be exor'd with signs of d6 and d7. Check d6 and d7
* for zero and infinity (of all the negative numbers, only $80000000
* remains negative after negation).

ldiv.sr	movem.l	d3-5,-(a7)		save registers
	clr.w	d3
	tst.l	d7
	bgt	.ygtzero		gt correct here
	beq	.underflow		as test eq here
	neg.l	d7
	bmi	.overflow
	eori.w	#1,d3
.ygtzero	tst.l	d6
	bgt	.xgtzero		gt ditto
	beq	.overflow		eq ditto
	neg.l	d6
	bmi	.underflow
	eori.w	#1,d3

* If d7 and d6 are equal, then at the end the quotient = $80000000. The
* answer should be $00010000 so the quotient has to be shifted right 15
* times.  This figure of 15 is modified according to the  number of shifts
* required to normalise d7 and d6.  The figure is increased by one for
* each d7 shift to the left (because more d7 shifts mean a smaller d7
* therefore a smaller answer) and decreased for every d6 shift (because
* more d6 shifts means a smaller d6 and therefore a larger answer).  If
* the final shift figure is greater than 32, then d7 is excessively small
* compared with d6 and underflow will result.  Similarly, if the final
* figure is less than 0, then d6 is excessively small compared with d7 and
* overflow will result. After normalisation, d6 and d7 are shifted right
* to leave a leading zero.


.xgtzero	move.w	#15,d4		base count is 15
.normaly	addq.w	#1,d4
	asl.l	#1,d7		normalise d7
	bpl	.normaly
	lsr.l	#1,d7		leave a leading 0
.normalx	subq.w	#1,d4
	asl.l	#1,d6		normalise d6
	bpl	.normalx
	lsr.l	#1,d6		leave a leading 0
	cmp.w	#32,d4
	bgt	.underflow		d7 <<< d6
	tst.w	d4
	bmi	.overflow		d7 >>> d6
	swap	d4		save shift figure

* Here is the main loop.  The divisor is subtracted from the dividend and
* a branch taken if the carry is set (NB not if the result is negative).
* The carry is rotated into the quotient, the dividend restored (if
* necessary) and shifted.  Because the answer is built from the carry, it
* is in fact the 1's complement of what is required and must be reversed.

	move.w	#31,d4		going to do 32 loops
.divloop	sub.l	d6,d7		dividend - divisor
	bcs	.restore		NB use CARRY not NEGATIVE
	roxl.l	#1,d5		insert carry into quotient
	asl.l	#1,d7		dividend left
	dbra	d4,.divloop		again till done
	bra	.donediv
.restore	roxl.l	#1,d5		insert carry into quotient
	add.l	d6,d7		divisor > dividend, add back
	asl.l	#1,d7		 and shift dividend
	dbra	d4,.divloop		again till done
.donediv	not.l	d5		1's complement quotient

* The main loop is finished.  The quotient is moved to d7 and the shift
* figure retrieved and used to shift the answer.  The answer is rounded if
* the last bit to be shifted out was set.  The sign is checked and d7 is
* negated if required.

	move.l	d5,d7
	swap	d4
	lsr.l	d4,d7		shift right 0 < n < 32
	bcc	.tstover		check for rounding
	addq.l	#1,d7		round
.tstover	bmi	.overflow		overflow if msb set
	tst.w	d3		check sign
	beq	.exit                   OK if positive
	neg.l	d7		negate if not
	bra	.exit
.overflow	move.l	#infinity,d7	set d7 = infinity
	bra	.exit
.underflow	move.l	#0,d7		set d7 = 0
.exit	movem.l	(a7)+,d3-5		restore register
	rts



* Square
*
power2	macro	d7 = d7 * d7
	bsr	power2.sr
	endm
power2.sr	dup
	lmul	d6
	rts



* Square root d7
*
* This routine uses Newton's method of successive approximation to
* determine the square root of the number in d7. To speed things up a
* first "guess" is made as to the answer. This guess is arrived at by
* dividing the original number by a power of 2 (by shifting right) if there
* is an integer component or multiplying by a power of 2 (by shifting left)
* if there is only a fraction. The number of shifts right or left depends on
* the size of the original number. A good guess will reduce the number of
* times round the loop. Since each loop contains a long division (slow),
* greatest speed is obtained by reducing the number of loops.
* Once the first guess has been made there is then an iterative process to
* determine the next approximation. The process is stopped when there is no
* difference between the current approximation and the new approximation.
* The maximum number of loops seems to be 5 but can be as few as 1 (for
* perfect squares which are also a power of 2 eg 4, 16, 64 etc).

root2	macro	d7 = square root d7
	bsr	root2.sr
	endm
root2.sr	movem.l	d2-5,-(a7)		save registers
	tst.l	d7
	bpl	.yplus
	move.l	#infinity,d7	error if negative
	bra	.exit
.yplus	move.l	d7,d4		save original number (a)
	lcmp	#$40000000,d7	>= 16384 ?
	blt	.try28		then / by 128
	lsr.l	#7,d7
	bra	.nextry
.try28	lcmp	#$10000000,d7	>= 4096 ?
	blt	.try26		then / by 64
	lsr.l	#6,d7
	bra	.nextry
.try26	lcmp	#$04000000,d7	>= 1024 ?
	blt	.try24
	lsr.l	#5,d7		then / by 32
	bra	.nextry
.try24	lcmp	#$01000000,d7	>= 256 ?
	blt	.try22
	lsr.l	#4,d7		then / by 16
	bra	.nextry
.try22	lcmp	#$00400000,d7	>= 64 ?
	blt	.try20
	lsr.l	#3,d7		then / by  8
	bra	.nextry
.try20	lcmp	#$00100000,d7	>= 16 ?
	blt	.try18
	lsr.l	#2,d7		then / by  4
	bra	.nextry
.try18	lcmp	#$00040000,d7	>= 4 ?
	blt	.try16
	lsr.l	#1,d7		then / by  2
	bra	.nextry
.try16	lcmp	#$00010000,d7	>= 1 ?
	blt	.tryfrac
	bra	.nextry
.tryfrac	lcmp	#$00004000,d7	>= 0.25 ?
	blt	.try12
	lsl.l	#1,d7		then * by 2
	bra	.nextry
.try12	lcmp	#$00001000,d7	>= 0.0625 ?
	blt	.try10
	lsl.l	#2,d7		then * by 4
	bra	.nextry
.try10	lcmp	#$00000400,d7	>= 0.015625 ?
	blt	.try8
	lsl.l	#3,d7		then * by 8
	bra	.nextry
.try8	lcmp	#$00000100,d7	>= 0.00390625 ?
	blt	.try6
	lsl.l	#4,d7		then * by 16
	bra	.nextry
.try6	lcmp	#$00000040,d7	>= 0.000976563 ?
	blt	.try4
	lsl.l	#5,d7		then * by 32
	bra	.nextry
.try4	lcmp	#$00000010,d7	>= 0.000244141 ?
	blt	.try2
	lsl.l	#6,d7		then * by 64
	bra	.nextry
.try2	lcmp	#$00000004,d7	>= 0.000061035 ?
	blt	.try1
	lsl.l	#7,d7		then * by 128
	bra	.nextry
.try1	lcmp	#$00000001,d7	>= 0.000015259 ?
	blt	.nextry
	lsl.l	#8,d7		then * by 256
.nextry	move.l	d7,d6		save xn
	move.l	d7,d5		save xn
	move.l	d4,d7		load a (original number)
	ldiv	d6		a / xn
	add.l	d5,d7		xn + (a / xn)
	lsr.l	d7		xn+1 = 1/2(xn + (a / xn))
	lcmp	d7,d5
	bne	.nextry
.exit	movem.l	(a7)+,d2-5		restore registers
	rts



* Logarithm (base2)
*
* Logs of a number 'a' to any base can be found by computing the series:
* 2rx + 2r(xpower3)/3 + 2r(xpower5)/5 + etc etc where x = (a-1)/(a+1)
* and r = the conversion factor from log e to the required base. Base 2 is
* convenient for dealing with binary numbers. The precomputed factors below
* are 2*1.4426952, 2*1.4426952/3, 2*1.4426952/5 etc until the resultant
* factor is too small to be represented by the sif method. The number has
* to be normalised first.
log2	macro	d7 = log d7 base 2
	bsr	log2.sr
	endm
log2fctrs	dc.l	$0002E2A9,$0000F638,$000093BB,$00006986,$00005213
	dc.l	$00004327,$000038D2,$0000313E,$00002B73,$000026E0
log2.sr	movem.l	d2-5/a0,-(a7)
	tst.l	d7
	ble	.error
	moveq.l	#16,d2		set characteristic count
.normalx	subq.w	#1,d2		subtract 1
	lsl.l	#1,d7		& shift up
	bpl	.normalx		till normalised
	clr.w	d7
	swap	d7		shift right 16 times
	move.l	d7,d6		a
	sub.l	#$00010000,d7	a - 1
	add.l	#$00010000,d6	a + 1
	ldiv	d6		x = a - 1 / a + 1
	move.l	d7,d5		save copy
	move.l	d7,d6		prepare to square
	lmul	d6		x power 2
	move.l	d7,d4		saved
	lea	log2fctrs,a0	precomputed factors
	move.l	d5,d7		x into d4 for 1st factor
	move.l	(a0)+,d6
	lmul	d6
	move.l	d7,d3
.nxtfactor	move.l	d5,d7		x power i
	move.l	d4,d6		x power 2
	lmul	d6		x power i * x power 2
	move.l	d7,d5		x power (i + 2)
	move.l	(a0)+,d6		get factor
	lmul	d6
	add.l	d7,d3		2r(x power i)/i
	tst.l	d7		stop when next factor
	bne	.nxtfactor		  is zero
	move.l	d3,d7
	swap	d2		move characteristic up
	add.l	d2,d7		add characteristic
	bra	.exit		& finish
.error	move.l	#infinity,d7	error
.exit	movem.l	(a7)+,d2-5/a0
	rts


* Antilogarithm (base 2)
*
* The antilog base e of a number can be found by computing the series:
* e(powerx) = 1 + x + x(power2)/2! + x(power3)/3! etc etc.  This can be
* converted to another base by multiplying by a conversion factor.
alog2	macro	d7 = antilog d7 base 2
	bsr	alog2.sr
	endm
alog2fctrs	dc.l	$00008000,$00002AAB,$00000AAB,$00000222,$0000005B
	dc.l	$0000000D,$00000002,$00000000
alog2.sr	movem.l	d2-5/a0,-(a7)
	lcmp	#$000F0000,d7
	bgt	.overflow		won't fit into sif
	move.l	d7,d2		save characteristic
	move.l	#$00010000,d3	x power 0
	andi.l	#$0000FFFF,d7	clear characteristic
	move.l	#$0000B172,d6	log of 2 (base e)
	lmul	d6		x * factor
	add.l	d7,d3		x power 1
	move.l	d7,d5		save x
	move.l	d7,d4		  "
	lea	alog2fctrs,a0
.nxtfactor	move.l	d5,d7		get x power i
	move.l	d4,d6		get x power 1
	lmul	d6		x power i * x power 1
	move.l	d7,d5		save x power (i + 1)
	move.l	(a0)+,d6		get factor
	lmul	d6		multiply
	add.l	d7,d3		add to answer
	tst.l	d7		stop when next factor
	bne	.nxtfactor		  is zero
	swap	d2
	tst.w	d2
	bpl	.shiftleft
	neg.w	d2
	lsr.l	d2,d3
	move.l	d3,d7
	bra	.exit
.shiftleft	lsl.l	d2,d3
	move.l	d3,d7
	bra	.exit
.overflow	move.l	#infinity,d7
.exit	movem.l	(a7)+,d2-5/a0
	rts



* Logarithm (base 10)
*
* log 10 is obtained by determining log 2 and applying a conversion factor
log10	macro	d7 = log d7 base 10
	bsr	log10.sr
	endm
log10.sr	log2
	ldiv	#$0003526A
	rts



* can't get this going yet
alog10	macro
	bsr	alog10.sr
	endm
alog10.sr	rts


* Power
*
* simply uses logs in the usual way
power	macro	d7 = d7 raised to power d6
	IFNC	'\1','d6'
	move.l	\1,d6	load x if given
	ENDC
	bsr	power.sr
	endm
power.sr	move.l	d6,-(a7)		save exponent
	log2			log y
	move.l	(a7)+,d6		restore exponent
	lmul	d6		log y * exponent
	alog2			alog
	rts



* Make ASCII. Other input/output routines can be found in MATH_TST.S
*
* This routine converts the value in d7 to ascii and outputs it to memory
* pointed to by a0.  The ascii format is determined by a word passed in
* d1 of the form 'if' where 'i' represents number of decimal integer digits
* required and 'f' represents the number of decimal fraction digits
* required (eg '41' will give 4 integer digits and 1 fraction digit).
* NOTE - the space required for output is the number of integer digits plus
* the number of fraction digits plus 1 for a leading space plus 1 for the
* sign plus 1 for the decimal point.
* The integer routine finds the decimal digits starting with 'units' and
* progressing to 'tens' etc.  These have to be written in reverse and this
* is why the addressing mode is (a0,d1.w) as d1 contains the count which
* decreases by 1 each time.
ascii	macro	address,format
	lea	\1,a0
	move.w	\2,d6
	bsr	ascii.sr
	endm
ascii.sr	move.l	d3,-(a7)		save register
	move.l	d7,d5		get value
	bmi	.neg
	move.b	#' ',(a0)+		leading space
	bra	.cont
.neg	neg.l	d5		negate value
	bmi	.overflow		branch infinity
	move.b	#'-',(a0)+		leading minus sign
	move.l	d5,d7		store pos value
.cont	move.l	a0,-(a7)		address of 1st digit
	andi.l	#$0000FFFF,d6	clear high d6
	divu	#10,d6		'i' d6.lo,'f' d6.hi
	move.w	d6,-(a7)		save for later
	clr.w	d5
	swap	d5		get int part
	bra	.enterint		'while...end'
.intloop	divu	#10,d5		remainder in hi d5
	swap	d5
	add.b	#$30,d5		make ascii
	move.b	d5,(a0,d6.w)	store ascii
	clr.w	d5
	swap	d5
.enterint	dbra	d6,.intloop		next integer
	adda.w	(a7)+,a0		point past int
	move.b	#'.',(a0)+		decimal point
	clr.l	d5
	move.w	d7,d5		get frac
	swap	d6		get frac count
	bra	.enterfrac		'while...end'
.fracloop	mulu	#10,d5
	swap	d5		get fraction
	add.b	#$30,d5		make ascii
	move.b	d5,(a0)+		save fraction
	clr.w	d5
	swap	d5
.enterfrac	dbra	d6,.fracloop	another frac?
	move.l	(a7)+,a0		address 1st digit
	cmpi.b	#'0',(a0)		ascii zero
	bne	.exit
.space	move.b	#' ',(a0)+		blank leading zeros
	cmpi.b	#'0',(a0)
	beq	.space		not anything else
	bra	.exit
.overflow	divu	#10,d6		split format
	move.w	d6,-(a7)		store one
	swap	d6
	add.w	(a7)+,d6		add together
.overfloop	move.b	#' ',(a0)+		all spaces - no
	dbra	d6,.overfloop	decimal point
	clr.b	(a0)		terminal null
.exit	move.l	(a7)+,d3		restore register
	rts			end



sif_end