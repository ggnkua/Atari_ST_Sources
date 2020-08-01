# 1 "ldexp.cpp"
# add exponent to floating point number
# C Interface
# double ldexp(double value, unsigned int exp);
# returns value * 2**exp
# (int is 16 bits if -mshort, 32 bits if !-mshort)
# performed entirely on the 68881 to avoid overfow as good as possible
##############################################################################
# hacked for the 68881 by Michael Ritzert, 5.10.90
##############################################################################

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
#	.byte	0x0c,0x69,0x89,0x00,0xff,0xf0,0x67,0xf8 (a1)
#	or
#	.long	0x0c6889000, 0x000067f8			(a0)

	.text; .even
	.globl _ldexp
_ldexp:
	lea	0xfffa50,a0		| fpu address
	movew	#0x4011,a0@(comm)	| ftwotox to fp0 (as long int!)

	movew	a7@(12),d0		| get exponent
	extl	d0



	cmpiw	#0x8900,a0@(resp)	| check if fpu is ready
	movel	d0,a0@			| push arg
	.long	0x0c6889000, 0xfff067f8	| wait
	movew	#0x5423,a0@(comm)	| fmul value,fp0
	.long	0x0c6889000, 0xfff067f8	| wait
	movel	a7@(4),a0@		| load value
	movel	a7@(8),a0@		|
	.long	0x0c6889000, 0xfff067f8	| wait
	movew	#0x7400,a0@(comm)	| get double from fp0
	.long	0x0c6889000, 0xfff067f8	| wait
	movel	a0@,d0
	movel	a0@,d1
	rts


