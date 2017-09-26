	.text

	.globl	_SMUL_DIV
	.globl	_smul_div

*******************************************************************************
*									      *
* smul_div (m1,m2,d1)							      *
*									      *
*	( ( m1 * m2 ) / d1 ) + 1					      *
*	m1 = signed 16 bit integer					      *
*	m2 = unsigned 15 bit integer					      *
*	d1 = signed 16 bit integer					      *
*									      *
*******************************************************************************

_SMUL_DIV:
_smul_div:
	moveq	#1,d1		* preload increment
	move	6(sp),d0
	muls	4(sp),d0	* m2 * m1
	bpl	smd_1

	neg	d1		* negate increment
smd_1:
	move	8(sp),d2
	divs	d2,d0		* m2 * m1 / d1
	and	d2,d2		* test if divisor is negative
	bpl	smd_2

	neg	d1		* negate increment
	neg	d2		* make divisor positive
smd_2:
	move.l	d3, -(sp)
	move.l	d0,d3		* extract remainder
	swap	d3
	and	d3,d3		* test if remainder is negative
	bpl	smd_3

	neg	d3		* make remainder positive
smd_3:
	asl	#1,d3		* see if 2*remainder is > divisor
	cmp	d2,d3
	blt	smd_4

	add	d1,d0		* add increment
smd_4:
	move.l	(sp)+,d3
	rts

	.end
