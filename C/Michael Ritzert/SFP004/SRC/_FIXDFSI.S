# single precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
#  double float to long conversion routine
#
# M. Ritzert (mjr at dmzrzu71)
#
# 4.10.1990
#
# no oflow checking implemented since the 68881 treats this situation "correct",
# i.e. according to IEEE. it returns MAXINT = 0x7fffffff and proceeds.

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
	.globl	__fixdfsi, ___fixdfsi
__fixdfsi:
___fixdfsi:
	lea	0xfffa50,a0
	movew	#0x5403,a0@(comm)	| fintrz to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x6000,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
 	rts

