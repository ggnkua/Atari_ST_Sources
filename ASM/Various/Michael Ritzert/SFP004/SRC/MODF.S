# pml compatible lib for the atari sfp004
#
# Michael Ritzert, Oktober 1990
# ritzert@dfg.dbp.de
#
# FUNCTION:	double MODF(double X, double * Y)
#
# base =	0xfffa50
#      the fpu addresses are taken relativ to "base":
#
# a0: fpu base address
# a1: return address for int part
#

# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a1@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8 (a0)
# and
# www:	tst.w	a0@(resp)
#	bmi.b	www
# is coded by
#	.word	0x4a68,0xfff0,0x6bfa		| test
#

comm =	 -6
resp =	-16
zahl =	  0

.even
.text
	.globl _modf
.even
_modf:
	movel	a1,a7@-
	lea	0xfffa50,a0
	movew	#0x5403,a0@(comm)	| fintrz X -> fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(8),a0@		| load X_hi
	movel	a7@(12),a0@		| load X_low

	movew	#0x5480,a0@(comm)	| X -> fp1
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@		| load X_hi
	movel	a7@(12),a0@		| load X_low

#	movew	#%0000 0000 1010 1000,a0@(comm)	| sub fp0 -> fp1
	movew	#0x00a8,a0@(comm)		| sub fp0 -> fp1
	.word	0x4a68,0xfff0,0x6bfa		| test

	movew	#0x7400,a0@(comm)	| fp0 to IntPart
	moveal	a7@(16),a1		| address of IntPart while the fpu is active
# wait
	.long	0x0c688900, 0xfff067f8
	movel	a0@,a1@+
	movel	a0@,a1@+
	movew	#0x7480,a0@(comm)	| Rest to d0/d1
# wait
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	movel	a7@+,a1
 	rts
