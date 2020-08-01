# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double precision multiplication
#
# M. Ritzert (mjr at dfg.dbp.de)
#
# 4.10.1990
#
# no NAN checking implemented since the 68881 treats this situation "correctly",
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
	.globl	__muldf3, ___muldf3

__muldf3:
___muldf3:
	lea	0xfffa50,a0
	movew	#0x5400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x5423,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@
	movel	a7@(16),a0@
	movew	#0x7400,a0@(comm)	| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	rts
