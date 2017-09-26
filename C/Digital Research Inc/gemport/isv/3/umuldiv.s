	.text

	.globl	_umul_div
	.globl	_UMUL_DIV

_UMUL_DIV:
_umul_div:
	move	6(sp),d0	* m2
	asl	#1,d0		* 2*m2
	mulu	4(sp),d0	* m1*2*m2
	divu	8(sp),d0	* (m1*2*m2)/d1
	addq	#1,d0		* ((m1*2*m2)/d1)+1
	asr	#1,d0		* (((m1*2*m2)/d1)+1)/2
	rts

	.end
