# single precision floating point stuff for Atari-gcc using the SFP004
# developed with gas
#
# single floating point multiplication routine
#
# M. Ritzert (mjr at dfg.dbp.de)
#
# 7. Juli 1989
#
# revision 1.1: adapted to the gcc lib patchlevel 58
# 4.10.90

comm =	 -6
resp =	-16
zahl =	  0

	.text
	.even
	.globl	__mulsf3, ___mulsf3

__mulsf3:
___mulsf3:
	lea	0xfffa50,a0
	movew	#0x4400,a0@(comm)	| load first argument to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movew	#0x4427,a0@(comm)
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@
	movew	#0x6400,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	rts
