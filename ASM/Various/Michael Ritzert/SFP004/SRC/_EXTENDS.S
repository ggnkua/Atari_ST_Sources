# single precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# single float to double float conversion routine
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
# ww:	cmpiw	#0x8900,a1@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8

	.text
	.even
	.globl	__extendsfdf2, ___extendsfdf2

__extendsfdf2:
___extendsfdf2:
	lea	0xfffa50,a0
	movew	#0x4400,a0@(comm)	| load argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@		| now push arg
	movew	#0x7400,a0@(comm)	| result to d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0			| pop double float
	movel	a0@,d1
	rts
