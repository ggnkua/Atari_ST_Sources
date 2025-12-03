|
| tapebind.cpp definitions for the library. 
| With these it is now compatible with 16 bit integers
|
#ifdef __MSHORT__
	.globl	_tapebios

	.text
	.even

_tapebios:
	lea	sp@(20), a0	| 4 bytes for ret addr + 16 for parameters
	moveml	d2/a2, sp@-	| save registers that TOS clobbers
	movel	a0@-, sp@-	
	movel	a0@-, sp@-
	movel	a0@-, sp@-
	movel	a0@-, sp@-
	trap	#10
	addl	#16, sp
	moveml	sp@+, d2/a2
	rts
#else
	.globl	_trap_10_wwll

_trap_10_wwll:
	moveml	d2/a2, sp@-
	movel	sp@(28), a1 
	movel	sp@(24), a0
	movel	sp@(20), d1
	movel	sp@(16), d0
	movel	a1, sp@-
	movel	a0, sp@-
	movew	d1, sp@-
	movew	d0, sp@-
	trap	#10
	addl	#12,sp
	moveml	sp@+, d2/a2
	rts
#endif
	
