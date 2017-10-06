# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double precision complex exponential function
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
	.globl _cexp
_cexp:
	movel	a1,d0				| save a1 as return value
	lea	0xfffa50,a0			| fpu address
	movew	#0x5410,a0@(comm)		| exp()
	cmpiw	#0x8900,a0@(resp)		| check
	movel	a7@(4),a0@			| load arg_hi
	movel	a7@(8),a0@			| load arg_low

#	movew	#%0101 0101 0011 0001,a0@(comm)	| sincos: sin -> fp2
	movew	#0x5531,a0@(comm)	| sincos: sin -> fp2
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@			| load arg_hi
	movel	a7@(16),a0@			| load arg_low

#	movew	#%0000 0000 1010 0011,a0@(comm)	| mul fp0 -> fp1
	movew	#0x00a3,a0@(comm)		| mul fp0 -> fp1
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0000 0001 0010 0011,a0@(comm)	| mul fp0 -> fp2
	movew	#0x0123,a0@(comm)		| mul fp0 -> fp2
	.word	0x4a68,0xfff0,0x6bfa		| test

#	movew	#%0111 0100 1000 0000,a0@(comm)	| fetch fp1
	movew	#0x7480,a0@(comm)		|
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+

#	movew	#%0111 0101 0000 0000,a0@(comm)	| fetch fp2
	movew	#0x7500,a0@(comm)		|
	.long	0x0c688900, 0xfff067f8
	movel	a0@(zahl),a1@+
	movel	a0@(zahl),a1@+

	rts
