# long integer to double float conversion routine
#
# Written by M.Ritzert
# 5.10.90
# ritzert@dfg.dbp.de
#

# addresses of the 68881 data port. This choice is fastest when much data is
# transferred between the two processors.

comm =	 -6	|	fpu command reg
resp =	-16	|	fpu response reg
zahl =	  0	|	fpu data reg

# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a1@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8

	.text
	.even
	.globl	__floatsidf, ___floatsidf

__floatsidf:
___floatsidf:
	lea	0xfffa50,a0
	movew	#0x4000,a0@(comm)	| load long int to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@
	movew	#0x7400,a0@(comm)	| get double from fp0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	rts
