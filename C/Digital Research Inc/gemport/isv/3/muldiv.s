	.text

	.globl	_mul_div
	.globl	_MUL_DIV

_mul_div:
_MUL_DIV:
	move	6(sp), d0	* m2
	asl	#1, d0		* 2*m2
	muls	4(sp), d0	* m1*2*m2
	divs	8(sp), d0	* (m1*2*m2)/d1
	bmi	md_1

	addq	#1, d0		* ((m1*2*m2)/d1)+1
	bra	md_2

md_1:
	subq	#1, d0		* ((m1*2*m2)/d1)-1
md_2:
	asr	#1, d0		* (one of the above)/2
	rts

	.end
