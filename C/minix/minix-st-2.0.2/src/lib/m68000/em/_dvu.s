.define .dvu
.sect .text
.sect .rom
.sect .data
.sect .bss

 ! unsigned long divide
 !-----------------------------------------------------------------------------
 ! modified by Kai-Uwe Bloem (i5110401@dbstu1.bitnet) for speed.
 !   #1  01/12/90  initial revision
 !-----------------------------------------------------------------------------
 ! To reduce the number of shift operations some minor improvements have been
 ! done. If the divisor is greater than 0x10000 or the divident is smaller than
 ! 0x10000 the divident/remainder pair can be shifted left by 16 bit at once.
 !-----------------------------------------------------------------------------

 ! register usage:
 ! 	 : d0 divisor
 !         d1 dividend
 ! exit  : d1 quotient
 !         d2 remainder

	.sect .text
.dvu:
	move.l	(sp)+,a1	! return address
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	move.l	d3,-(sp)	! save d3
	tst.l	d0		! divisor
	beq	9f		! error - divide by zero

	clr.l	d2		! initial remainder
	move	#32-1,d3
	cmp.l	#0xffff,d1	! is upper word of divident = 0 ?
	bhi	3f
	swap	d1		! yes, shift divident left 16 bits
	sub.w	#16,d3
3:
	cmp.l	#0x10000,d0	! is upper word of divisor # 0 ?
	bls	4f
	swap	d1		! yes, shift divident/remainder left 16 bits
	move.w	d1,d2
	clr.w	d1
	sub	#16,d3
	bmi	6f		! return, no more work to do
4:
	lsl.l	#1,d1
	roxl.l	#1,d2
	cmp.l	d0,d2
	blt	5f
	sub.l	d0,d2
	add	#1,d1
5:
	dbra	d3,4b
6:
	move.l	(sp)+,d3	! restore d3
	jmp	(a1)

EIDIVZ	= 6
9:	move.w	#EIDIVZ,-(sp)
	jsr	.trp
