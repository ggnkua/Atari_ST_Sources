# single precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
#  single floating point add/subtract routine
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
	.globl	__subsf3, ___subsf3
	.globl	__addsf3, ___addsf3

__subsf3:
___subsf3:
	lea	0xfffa50,a0
	movew	#0x4400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movew	#0x4428,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@
	movew	#0x6400,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
 	rts

__addsf3:
___addsf3:
	lea	0xfffa50,a0
	movew	#0x4400,a0@(comm)		| load fp0
	cmpiw	#0x8900,a0@(resp)		| got it?
	movel	a7@(4),a0@			| take a from stack to FPU
	movew	#0x4422,a0@(comm)		| add second arg to fp0
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@			| move b from stack to FPU
	movew	#0x6400,a0@(comm)		| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0				| download result
 	rts
