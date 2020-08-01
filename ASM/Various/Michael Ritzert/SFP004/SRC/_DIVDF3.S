# double precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# double precision division
#
# M. Ritzert (mjr at dmzrzu71)
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

	.even
LC0:
	.ascii "floating point division by 0\12\15\0"

	.text
	.even
	.globl	__divdf3, ___divdf3

__divdf3:
___divdf3:
	tstl	a7@(12)			| check if divisor is 0
	bne	continue
	tstl	a7@(16)
	bne	continue
	moveml	d0-d7/a0-a6,a7@-
	pea	LC0
	movew	#9,a7@-
	trap	#1
	addql	#6,a7
	moveml	a7@+,d0-d7/a0-a6
continue:
	lea	0xfffa50,a0
	movew	#0x5400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x5420,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@
	movel	a7@(16),a0@
	movew	#0x7400,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
 	rts
