# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double precision complex multipliation
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
#	.long	0x0c688900, 0xfff067f8 (a0)
# and
# www:	tst.w	a0@(resp)
#	bmi.b	www
# is coded by
#	.word	0x4a68,0xfff0,0x6bfa		| test

	.text; .even
	.globl _cmult
_cmult:
	movel	a1,d0				| save a1 as return value
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

#	move.w	#%0000 0010 0000 0000,comm(c)	; copy fp0 to fp4
	movew	#0x0200,a0@(comm)		| copy fp0 to fp4
	.word	0x4a68,0xfff0,0x6bfa		| test

# now compute the product

#	movew	#%000 010 100 0100011,a0@(comm)	| mul fp2 -> fp4
	movew	#0x0a23,a0@(comm)		| mul fp2 -> fp4
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 011 000 0100011,a0@(comm)	| mul fp3 -> fp0
	movew	#0x0c23,a0@(comm)		| mul fp3 -> fp0
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 001 010 0100011,a0@(comm)	| mul fp1 -> fp2
	movew	#0x0523,a0@(comm)		| mul fp1 -> fp2
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 001 011 0100011,a0@(comm)	| mul fp1 -> fp3
	movew	#0x05a3,a0@(comm)		| mul fp1 -> fp3
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 011 100 0101000,a0@(comm)	| sub fp3 -> fp4
	movew	#0x0e28,a0@(comm)		| sub fp3 -> fp4
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%000 000 010 0100010,a0@(comm)	| add fp0 -> fp2
	movew	#0x0122,a0@(comm)		| add fp0 -> fp2
	.word	0x4a68,0xfff0,0x6bfa		| test

# return real part (fp4) and imaginery part (fp2)

#	movew	#%011 101 100 0000000,a0@(comm)	| fp4 -> d0
	movew	#0x7600,a0@(comm)		| fp4 -> d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+

#	movew	#%011 101 010 0000000,a0@(comm)	| fp2 -> d1
	movew	#0x7500,a0@(comm)		| fp2 -> d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+
	rts					| sigh!
