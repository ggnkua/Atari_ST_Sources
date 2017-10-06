# remove exponent from floating point number
# C Interface
# double frexp(double value, int *eptr)
#
# returns significand (#significand# < 1)
#	   in *eptr returns n such that value = significand * 2**n
###############################################################################
# hacked for the 68881 by Michael Ritzert, 5.10.90
##############################################################################
# addresses of the 68881 data port. This choice is fastest when much data is
# transferred between the two processors.

comm =	 -6	|	fpu command reg
resp =	-16	|	fpu response reg
zahl =	  0	|	fpu data reg

# a1:	fpu base register
# a0:	pointer to n
# 	sp@(12) address of resulting exponent (n)

# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a0@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8                 (fpu base a1)
# and
# www:	tst.w	a0@(resp)
#	bmi.b	www
# is coded by
#	.word	0x4a68,0xfff0,0x6bfa		| test

	.text; .even

.globl _frexp

	lea	0xfffa50,a0
	movew	#0x5418,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@

	movew	#0x009f,a0@(comm)	| fgetman fp0,fp1
	.word	0x4a68,0xfff0,0x6bfa	| test

	movew	#0x001e,a0@(comm)	| fgetexp fp0,fp0
	moveal	a7@(12),a1		| address of n while the fpu is active
	.word	0x4a68,0xfff0,0x6bfa	| test
#ifdef __MSHORT__
	movew	#0x7080,a0@(comm)	| fetch exp (fmovew from fp1)
	.long	0x0c688900, 0xfff067f8
	movew	a0@,a1@			| return exp
#else
	movew	#0x7880,a0@(comm)	| fetch exp (fmovel from fp1)
	.long	0x0c688900, 0xfff067f8
	movel	a0@,a1@			| return exp
#endif
	movew	#0x7400,a0@(comm)	| now fetch significand
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	btst	#31,a7@(4)		| test sign of 1st arg
	bge	fini			| arg neg ?
	bset	#31,d0			| =>  negate result
fini:	rts
