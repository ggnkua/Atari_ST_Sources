# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double precision complex division
# makes use of many of the 68881 regs for high internal precision and speed
#
# M. Ritzert (mjr at dmzrzu71)
#
# 12.10.1990
#
# addresses of the 68881 data port. This choice is fastest when much data is
# transferred between the two processors.

comm =	 -6
resp =	-16
zahl =	  0

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
#	.word	0x4a68,0xfff0,0x6bfa		| test

	.text; .even
	.globl _cdiv
_cdiv:
	movel	a1,d0				| save a1 and return it finally
	lea	0xfffa50,a0			| fpu address

# load floating point registers
	movew	#0x5400,a0@(comm)		| real part of z1 to fp0
	.long	0x0c688900, 0xfff067f8
	movel	a7@(4),a0@			| load arg_hi
	movel	a7@(8),a0@			| load arg_low

	movew	#0x5480,a0@(comm)		| imaginary part of z1 to fp1
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@			| load arg_hi
	movel	a7@(16),a0@			| load arg_low

	movew	#0x5500,a0@(comm)		| real part of z2 to fp2
	.long	0x0c688900, 0xfff067f8
	movel	a7@(20),a0@			| load arg_hi
	movel	a7@(24),a0@			| load arg_low

	movew	#0x5580,a0@(comm)		| imaginary part of z2 to fp3
	.long	0x0c688900, 0xfff067f8
	movel	a7@(28),a0@			| load arg_hi
	movel	a7@(32),a0@			| load arg_low

# do the division

#	movew	#%0000 0010 0000 0000,a0@(comm)	| copy fp0 to fp4 (a)
	movew	#0x0200,a0@(comm)		| copy fp0 to fp4 (a)
	.word	0x4a68,0xfff0,0x6bfa		| test

# compute denominator (square of divisor's absolute value)
# result on fp5

#	movew	#%0000101010000000,a0@(comm)	| copy fp2 to fp5 (c)
	movew	#0x0a80,a0@(comm)		| copy fp2 to fp5 (c)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 010 101 010 0011,a0@(comm)	| mul fp2 -> fp5 (c*c)
	movew	#0x0aa3,a0@(comm)		| mul fp2 -> fp5 (c*c)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 011 110 0000000,a0@(comm)	| copy fp3 to fp6 (d)
	movew	#0x0f00,a0@(comm)		| copy fp3 to fp6 (d)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 011 110 0100011,a0@(comm)	| mul fp3 -> fp6 (d*d)
	movew	#0x0f23,a0@(comm)		| mul fp3 -> fp6 (d*d)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 110 101 0100010,a0@(comm)	| fp5 = fp5 + fp6
	movew	#0x1aa2,a0@(comm)		| fp5 = fp5 + fp6
	.word	0x4a68,0xfff0,0x6bfa		| test

# now compute the product

#	movew	#%000 010 100 0100011,a0@(comm)	| mul fp2 -> fp4 (a*c)
	movew	#0x0a23,a0@(comm)		| mul fp2 -> fp4 (a*c)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 011 000 0100011,a0@(comm)	| mul fp3 -> fp0 (a*d)
	movew	#0x0c23,a0@(comm)		| mul fp3 -> fp0 (a*d)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 001 010 0100011,a0@(comm)	| mul fp1 -> fp2 (b*c)
	movew	#0x0523,a0@(comm)		| mul fp1 -> fp2 (b*c)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0000 0101 1010 0011,a0@(comm)	| mul fp1 -> fp3 (b*d)
	movew	#0x05a3,a0@(comm)		| mul fp1 -> fp3 (b*d)
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0000 1110 0010 0010,a0@(comm)	| fp4 = fp3 + fp4
	movew	#0x0e22,a0@(comm)		| fp4 = fp3 + fp4
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0001 0110 0010 0000,a0@(comm)	| fp4 = fp4 / fp5
	movew	#0x1620,a0@(comm)		| fp4 = fp4 / fp5
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0000 0001 0010 1000,a0@(comm)	| fp2 = fp2 - fp0
	movew	#0x0128,a0@(comm)		| fp2 = fp2 - fp0
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0001 0101 0010 0000,a0@(comm)	| fp2 = fp2 / fp5
	movew	#0x1520,a0@(comm)		| fp2 = fp2 / fp5
	.word	0x4a68,0xfff0,0x6bfa		| test

# return real part (fp4) and imaginery part (fp2)

#	movew	#%0111 0110 0000 0000,a0@(comm)	| fp4 -> d0
	movew	#0x7600,a0@(comm)		| fp4 -> d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+

#	movew	#%0111 0101 0000 0000,a0@(comm)	| fp2 -> d1
	movew	#0x7500,a0@(comm)		| fp2 -> d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+

	rts					| sigh!


