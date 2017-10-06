# double float to single float conversion routine
# oflow checking is omitted. The '881 returns a signed infinity.
#
# Written by M.Ritzert
# 5.10.90
# ritzert@dfg.dbp.de
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

	.text
	.even
	.globl	__truncdfsf2, ___truncdfsf2

__truncdfsf2:
___truncdfsf2:
	lea	0xfffa50,a0
	movew	#0x5400,a0@(comm)	| load double to  fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@		| push arguments
	movel	a7@(8),a0@		|
	movew	#0x6400,a0@(comm)	| result (real) to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	rts
