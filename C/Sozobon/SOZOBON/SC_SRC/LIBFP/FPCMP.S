* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
*
* Permission is granted to anyone to use this software for any purpose
* on any computer system, and to redistribute it freely, with the
* following restrictions:
* 1) No charge may be made other than reasonable charges for reproduction.
* 2) Modified versions must be clearly marked as such.
* 3) The authors are not responsible for any harmful consequences
*    of using this software, even if they result from defects in it.
*
	.globl	fpcmp
	.globl	_fpcmp
fpcmp:
_fpcmp:
	move.l	4(sp),d0
	move.l	8(sp),d1

	cmp.b	d1,d0
	bne	L1
	cmp.l	d1,d0
L1:
	rts

	.globl	fpneg
	.globl	_fpneg
fpneg:
_fpneg:
	move.l	4(sp),d0

	tst.b	d0
	beq	L2
	eor.b	#$80,d0
L2:
	rts
