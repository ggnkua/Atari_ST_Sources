#
.sect .text; .sect .rom; .sect .data; .sect .bss
.extern _modf
.sect .text
_modf:
#if __i386
	push	ebp
	mov	ebp, esp
	push	12(ebp)
	push	8(ebp)
	push	1
	push	4
	call	.cif8
	mov	eax, esp
	push	eax
	call	.fif8
	pop	ecx
	mov	edx, 16(ebp)
	pop	ecx
	pop	ebx
	mov	0(edx), ecx
	mov	4(edx), ebx
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
	mov	dx, #1
	push	dx
	push	dx
	push	dx
	mov	ax, #2
	push	ax
	call	.cif8
	mov	ax, sp
	push	ax
	call	.fif8
	pop	bx
	mov	bx, 12(bp)
	mov	cx, #8
	call	.sti
	call	.ret8
	jmp	.cret

#else /* !__m68000 */

 ! take floating point to integer and fractional pieces
 !
 ! C interface
 !  double modf( double value, double *iptr)
 !  returns fractional part of value
 !	   in *iptr returns the integral part
 !	   such that (*iptr + fractional) == value
 !
 !-----------------------------------------------------------------------------
 ! ported to 68000 by Kai-Uwe Bloem, 12/89
 !  #1  original author: Peter S. Housel 9/21/88,01/17/89,03/19/89,5/24/89
 !  #2  replaced shifts by swap if possible for speed increase	-kub-, 01/90
 !  #3  ported to gcc ++jrb 03/90
 !  #4  replaced by a completely new, smaller and faster implementation,
 !        Michal Jaegermann, ntomczak@vm.ucs.ualberta.ca - 05/93
 !-----------------------------------------------------------------------------

BIAS8	=	0x3ff - 1

	lea	4(sp),a0	! a0 -> float argument
	movem.l	d2-d7,-(sp)	! save d2-d7
	movem.l	(a0)+,d0-d1
	move.l  (a0),a1		! a1 -> ipart result

	move.l	d0,d2		! calculate exponent
	swap	d2
	bclr	#15,d2		! kill sign bit
	lsr.w	#4,d2		! exponent in lower 12 bits of d2

	cmp.w	#BIAS8,d2
	bgt	l1		! fabs(value) >= 1.0
!				! return entire value as fractional part
	clr.l	(a1)+		! d0, d1 already ok
	clr.l	(a1)		! make integer part 0

l0:
	movem.l	(sp)+,d2-d7	! restore saved d2-d7
	rts

l1:
	move.w	#BIAS8+53,d3
	sub.w	d2,d3		! compute position of "binary point"
	bgt	l2		! branch if we do have fractional part

	movem.l d0-d1,(a1)	! store entire value as the integer part
	move.l	#0,d0		! return zero as fractional part
	move.l	d0,d1
	bra	l0
l2:
	move.l	d1,d5		! save for computation of fractional part

	move.l	#32,d6
	cmp.w	d6,d3
	blt	l3		! jump if "binary point" in a lower part
	move.l	d0,d4
	sub.w	d6,d3
	move.l	#0,d6		! compute mask for splitting
	bset	d3,d6
	neg.l	d6
	and.l	d6,d0		! this is integer part
	move.l	#0,d1
	not.l	d6
	and.l	d6,d4		! and denormalized fractional part
	bra	l4
l3:
	move.l	#0,d6		! splitting on lower part
	bset	d3,d6
	neg.l	d6
	and.l	d6,d1		! this is integer part
	move.l	#0,d4		! nothing in an upper fraction
	not.l	d6
	and.l	d6,d5		! and clear those unneded bits
l4:
	movem.l	d0-d1,(a1)	! store computed integer part

	swap	d0
	exg	d0,d2		! set registers for norm_df
	clr.w	d1		! rounding = 0
!				! normalize fractional part
	jmp	norm_df		! norm_df will pop d2/d7 we saved before
				! it will return to our caller via rts
				! with result in d0-d1
#endif /* !__m68000 */
#endif
