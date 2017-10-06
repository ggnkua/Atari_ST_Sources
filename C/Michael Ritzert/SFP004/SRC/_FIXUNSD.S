# double float to unsigned long conversion routine
# mjr: simplified
# does not really return unsigned long: max result is 0x7fffffff instead
# of 0xffffffff	(as in the original routine)

comm =	 -6
resp =	-16
zahl =	  0

	.text
	.even
	.globl	__fixunsdfsi, ___fixunsdfsi

__fixunsdfsi:
___fixunsdfsi:
	lea	0xfffa50,a0
	movew	#0x5403,a0@(comm)	| fintrz to fp0
	cmpiw	#0x8900,a0@(resp)	| check
	tstl	a4@(4)			| negative?
	bne	Negative
	movel	a7@(4),a0@
	movel	a7@(8),a0@
	movew	#0x6000,a0@(comm)	| result to d0
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	rts
Negative:
	clrl	d0
 	rts
