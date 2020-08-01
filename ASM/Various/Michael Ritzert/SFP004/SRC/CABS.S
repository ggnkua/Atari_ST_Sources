# pml compatible lib for the atari sfp004
#
# Michael Ritzert, Oktober 1990
# ritzert@dfg.dbp.de
#
# FUNCTION:	CABS(COMPLEX X)
#
# base =	0xfffa50
#      the fpu addresses are taken relativ to "base":
#
# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a1@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8
# and
# www:	tst.b	a1@(resp)
#	bmi.b	www
# is coded by
#	word	0x4a68,0xfff0,0x6bfa		| test

comm =	 -6
resp =	-16
zahl =	  0

.globl _cabs
.text
.even
_cabs:
	lea	0xfffa50,a0

	movew	#0x5400,a0@(comm)			| load fp0
	.long	0x0c688900, 0xfff067f8
	movel	a7@(4),a0@				| load arg_hi
	movel	a7@(8),a0@				| load arg_low

	movew	#0x5480,a0@(comm)			| load fp1
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@				| load arg_hi
	movel	a7@(16),a0@				| load arg_low

	movew	#0x0023,a0@(comm)
	.word	0x4a68,0xfff0,0x6bfa		| test

	movew	#0x04a3,a0@(comm)
	.word	0x4a68,0xfff0,0x6bfa		| test

	movew	#0x0422,a0@(comm)			| fp0 = fp0 + fp1
	.word	0x4a68,0xfff0,0x6bfa		| test

	movew	#0x0004,a0@(comm)			| sqrt(fp0)
	.word	0x4a68,0xfff0,0x6bfa		| test

	movew	#0x7400,a0@(comm)			| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),d0
	movel	a0@(zahl),d1
	rts

