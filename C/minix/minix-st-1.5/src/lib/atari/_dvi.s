.define .dvi
.sect .text
.sect .rom
.sect .data
.sect .bss

 ! signed long divide
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
.dvi:
	move.l	(sp)+,a1	! return address
	move.l	(sp)+,d0
	move.l	(sp)+,d1
	move.l	d3,-(sp)	! save d3 and d4
	move.l	d4,-(sp)
	clr.l	d4
	tst.l	d0		! divisor
	beq	9f
	bpl	1f
	neg.l	d0
	not	d4
1:
	tst.l	d1		! dividend
	bpl	2f
	neg.l	d1
	not.l	d4
2:
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
	tst	d4
	beq	7f
	neg.l	d1		! quotient
7:
	tst.l	d4
	bpl	8f
	neg.l	d2		! remainder
8:
	move.l	(sp)+,d4	! restore d4 and d3
	move.l	(sp)+,d3
	jmp	(a1)

EIDIVZ	= 6
9:	move.w	#EIDIVZ,-(sp)
	jsr	.trp
