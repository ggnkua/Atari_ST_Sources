#
.sect .text; .sect .rom; .sect .data; .sect .bss
.extern _frexp
.sect .text
_frexp:
#if __i386
	push	ebp
	mov	ebp, esp
	push	12(ebp)
	push	8(ebp)
	mov	eax, esp
	add	eax, -4
	push	eax
	call	.fef8
	mov	eax, 16(ebp)
	pop	(eax)
	pop	eax
	pop	edx
	leave
	ret
#else /* i86 */
#if !__m68000
	push	bp
	mov	bp, sp
	lea	bx, 4(bp)
	mov	cx, #8
	call	.loi
	mov	ax, sp
	add	ax, #-2
	push	ax
	call	.fef8
	mov	bx, 12(bp)
	pop	(bx)
	call	.ret8
	jmp	.cret
#else
 !-----------------------------------------------------------------------------
 ! remove exponent from floating point number
 ! C Interface
 ! double frexp(double value, int *eptr)
 !
 ! returns significand (!significand! < 1)
 !	   in *eptr returns n such that value = significand * 2**n
 !-----------------------------------------------------------------------------
 ! ported to 68000 by Kai-Uwe Bloem, 12/89
 !  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
 !  #2	added support for denormalized numbers			-kub-, 01/90
 !  #3  ported to gcc  ++jrb 04/90
 !  #4  support for signed 0 - consistently with the rest - michal, 05/93
 !      and some code cleanup
 !  #5  fixed __MSHORT__ bug - V.S 11/93
 !-----------------------------------------------------------------------------
#ifndef _EM_WSIZE
#define	_EM_WSIZE	2
#endif

BIAS8	=	0x3ff - 1

	move.l	12(sp),a0	! initialize exponent for loop
#if _EM_WSIZE == 2
	clr.w	(a0)
#else
	clr.l	(a0)
#endif
	lea	4(sp),a1	! sp@(4) -> a1 - an address of value
!				!   and a1@(8) - an address of *eptr
	move.l	(a1),d0		! keep value.sign
	move.l	d0,d1
	bclr	#31,d1		! kill sign bit
	tst.l	d1		! 1st arg == 0 ?
	bne	nonzero
	tst.l	4(a1)
	bne	nonzero
	rts			! if 0 or -0 then d0 and d1 already set
nonzero:
	move.l	d2,-(sp)
nl2:				! return here when looping
	swap	d0		! sign and exponent into lower 16 bits
	move.w	d0,d2		! set d2 for norm_df
	bclr	#15,d0		! kill sign bit
	lsr.w	#4,d0

	cmp.w	#BIAS8,d0	! get out of loop if finally (a1) in [0.5,1.0)
	beq	nl3

	move	#0x0f,d1	! remove exponent from value.mantissa
	and.b	d2,d1		! four upper bits of value in d1
	bset	#4,d1		! implied leading 1
	tst.w	d0		! check for zero exponent
	bne	nl1
	add.w	#1,d0
	bclr	#4,d1		! nah, we do not need stinkin leadin 1
nl1:	move.w	d1,(a1)		! save results of our efforts

	move.l	(a1),d1		! check for zero
	or.l	4(a1),d1
	beq	nl3		! if zero, all done : exp = 0, num = 0.0
				! sign of zero is correct
	sub.w	#BIAS8,d0	! remove bias
#if _EM_WSIZE == 2
	add.w	d0,(a0)		! add current exponent in
#else
	ext.l	d0
	add.l	d0,(a0)		! add current exponent in
#endif

	move.w	#BIAS8,d0	! set bias for return value
	clr.w	d1		! rounding = 0
	pea	nL0		! call to norm_df (dirty, but dont ...
	movem.l	d2-d7,-(sp)	! ... need to copy with -mshort)
	movem.l	(a1),d4-d5
	jmp	norm_df		! normalize result
nL0:				! norm_df does not affect a0 or a1
!				! but it pops d2-d7
	movem.l	d0-d1,(a1)
	bra	nl2		! loop around to catch denormalized numbers
nl3:
	movem.l	(a1),d0-d1
	move.l	(sp)+,d2
				! d0-d1 has normalized mantissa
	rts

!#######################################################################

! double floating point normalization routine
!
! written by Kai-Uwe Bloem (I5110401@dbstu1.bitnet).
! Based on a 80x86 floating point packet from comp.os.minix, written by P.Housel
!
! Revision 1.6.3 michal 05-93 (ntomczak@vm.ucs.ualberta.ca)
!  + restored and ensured future synchronization with errno codes
!  + removed bogus error when normalizing legitimate zero
!  + small mods to shave off few cycles
!
! patched by Olaf Flebbe (flebbe@tat.physik.uni-tuebingen.de)
!
! Revision 1.6.2 olaf 12-92:
!  + added support for -0.
!
! Revision 1.6.1 olaf 10-92:
!  + corrected rounding in tie case: round up, not down.
!    (needed for enquire 4.3)
!
! Revision 1.6, kub 04-90 :
! more robust handling exponent and sign handling for 32 bit integers. There
! are now overflow tests for 32 bit exponents, and bit 31 of the sign flag
! is or ed to bit 15 for later checks (i.e. both bits 31 and 15 are now sign
! bits). Take care, the upper 16 bits of rounding info are ignored for 32 bit
! integers !
!
! Revision 1.5, ++jrb 03-90:
! change __normdf interface to expect ints instead of shorts. easier
! to interface to 32 bit int code. this file is now pre-processed,
! with __MSHORT__ defined when ints are 16 bits.
!
! Revision 1.4, kub 03-90 :
! export ___normdf entry to C language. Rename the internal entry to a name
! not accessible from C to prevent crashes
!
! Revision 1.3, kub 01-90 :
! added support for denormalized numbers
!
! Revision 1.2, kub 01-90 :
! replace far shifts by swaps to gain speed
!
! Revision 1.1, kub 12-89 :
! Ported over to 68k assembler
!
! Revision 1.0:
! original 8088 code from P.S.Housel

ERANGE	=	63
	.sect .text
	.extern	__infinitydf
	.extern	norm_df
#ifdef needed
	.extern ___normdf

	! C entry, for procs dealing with the internal representation :
	! double __normdf(long long mant, int exp, int sign, int rbits)!
___normdf:
	lea	4(sp),a0	! parameter pointer
	movem.l	d2-d7,-(sp)	! save working registers
	movem.l	(a0)+,d4-d5	! get mantissa

# if _EM_WSIZE == 2
	move.w	(a0)+,d0		! get exponent
	move.w	(a0)+,d2		! get sign
	move.w	(a0)+,d1		! rounding information
# else
	move.l	(a0)+,d0		! get exponent
	move.l	(a0)+,d2		! get sign
	bpl	l01		! or bit 31 to bit 15 for later tests
	bset	#15,d2
l01:	move.l	(a0)+,d1		! rounding information

	move.l	#0x7fff,d3
	cmp.l	d3,d0		! test exponent
	bgt	oflow
	not.l	d3		! #-0x8000 -> d3
	cmp.l	d3,d0
	blt	retz
# endif /* _EM_WSIZE == 2 */
#endif /* needed */

	! internal entry for floating point package, saves time
	! d0=u.exp, d2=u.sign, d1=rounding bits, d4/d5=mantissa
	! registers d2-d7 must be saved on the stack !
norm_df:
	move.l	d4,d3		! rounding and u.mant == 0 ?
	or.l	d5,d3
	bne	l11
	tst.b	d1
	beq	retzok
l11:
	move.l	d4,d3
	and.l	#0xfffff000,d3	! fast shift, 16 bits ?
	bne	l21
	cmp.w	#9,d0		! shift is going to far! do normal shift
	ble	l21		!  (minimize shifts here : 10l = 16l + 6r)
	swap	d4		! yes, swap register halfs
	swap	d5
	move.w	d5,d4
	move.b	d1,d5		! some doubt about this one !
	lsl.w	#8,d5
	clr.w	d1
	sub.w	#16,d0		! account for swap
	bra	l11
l21:
	clr.b	d2		! sticky byte
	move.l	#0xffe00000,d6
l3:	tst.w	d0		! divide (shift)
	ble	l03		!  denormalized number
l31:	move.l	d4,d3
	and.l	d6,d3		!  or until no bits above 53
	beq	l4
l03:	add.w	#1,d0		! increment exponent
	lsr.l	#1,d4
	roxr.l	#1,d5
	or.b	d1,d2		! set sticky
	roxr.b	#1,d1		! shift into rounding bits
	bra	l31
l4:
	and.b	#1,d2
	or.b	d2,d1		! make least sig bit sticky
	asr.l	#1,d6		! #0xfff00000 -> d6
l5:	move.l	d4,d3		! multiply (shift) until
	and.l	d6,d3		! one in implied position
	bne	l6
	sub.w	#1,d0		! decrement exponent
	beq	l6		!  too small. store as denormalized number
	add.b	d1,d1		! some doubt about this one *
	addx.l	d5,d5
	addx.l	d4,d4
	bra	l5
l6:
	tst.b	d1		! check rounding bits
	bge	l8		! round down - no action neccessary
	neg.b	d1
	bvc	l7		! round up
        move.w  d5,d1           ! tie case - round to even
                                ! dont need rounding bits any more
        and.w   #1,d1           ! check if even
        beq     l8              ! mantissa is even - no action necessary
                                ! fall through
l7:
	clr.l	d1		! zero rounding bits
	add.l	#1,d5
	addx.l	d1,d4
	tst.w	d0
	bne	l02		! renormalize if number was denormalized
	add.w	#1,d0		! correct exponent for denormalized numbers
	bra	l21
l02:	move.l	d4,d3		! check for rounding overflow
	asl.l	#1,d6		! #0xffe00000 -> d3
	and.l	d6,d3
	bne	l21		! go back and renormalize
l8:
	move.l	d4,d3		! check if normalization caused an underflow
	or.l	d5,d3
	beq	retz
	tst.w	d0		! check for exponent overflow or underflow
	blt	retz
	cmp.w	#2047,d0
	bge	oflow

	lsl.w	#5,d0		! re-position exponent - one bit too high
	lsl.w	#1,d2		! get X bit
	roxr.w	#1,d0		! shift it into sign position
	swap	d0		! map to upper word
	clr.w	d0
	and.l	#0x0fffff,d4	! top mantissa bits
	or.l	d0,d4		! insert exponent and sign
	move.l	d4,d0
	move.l	d5,d1
	movem.l	(sp)+,d2-d7
	rts

retz:
	move.l	#ERANGE,d0
	move.w  d0,_errno
retzok:
	move.l	#0,d0		! return zero value
	move.l	d0,d1
	lsl.w	#1,d2		! set value of extension
	roxr.l	#1,d0		! and move it to hight bit of d0
XX0:	movem.l	(sp)+,d2-d7
	rts

oflow:
	movem.l	__infinitydf(pc),d0-d1 ! return infinty value
	tst.w	d2
	bpl	l13
	bset	#31,d0
l13:
	movem.l	(sp)+,d2-d7	! should really cause trap ?!? (mjr: why?)
	rts


__infinitydf:			! +infinity as proposed by IEEE
	.data4	0x7ff00000,0x00000000

#endif /* !__m68000 */
#endif
