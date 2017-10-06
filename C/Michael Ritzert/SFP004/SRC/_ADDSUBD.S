# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double floating point add/subtract routine
#
# M. Ritzert (mjr at dmzrzu71)
#
# 4.10.1990
#
# no NAN checking implemented since the 68881 treats this situation "correct",
# i.e. according to IEEE

# addresses of the 68881 data port. This choice is fastest when much data is
# transferred between the two processors.

comm =	 -6
resp =	-16
zahl =	  0

# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a0@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8

	.text
	.even
	.globl	__subdf3, ___subdf3
	.globl	__adddf3, ___adddf3

__subdf3:
___subdf3:
# double precision subtraction
# sub second arg from fp0
	lea	0xfffa50,a0
	movew	#0x5400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x5428,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@
	movel	a7@(16),a0@
	movew	#0x7400,a0@(comm)	| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
 	rts

__adddf3:
___adddf3:
	lea	0xfffa50,a0
	movew	#0x5400,a0@(comm)		| load fp0
	cmpiw	#0x8900,a0@(resp)		| got it?
	movel	a7@(4),a0@			| take a hi from stack to FPU
	movel	a7@(8),a0@			| take a lo from stack to FPU
	movew	#0x5422,a0@(comm)		| add second arg to fp0
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@			| move b hi from stack to FPU
	movel	a7@(16),a0@			| move b lo from stack to FPU
	movew	#0x7400,a0@(comm)		| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0				| download result
	movel	a0@,d1				| download result
 	rts
