	.globl	_setstack
_setstack:
	movel	sp@+, a0	| save return address
	movel	sp@, sp		| new stack pointer
	subql	#4, sp		| fixup for tidy upon return
	jmp	a0@		| back to caller

