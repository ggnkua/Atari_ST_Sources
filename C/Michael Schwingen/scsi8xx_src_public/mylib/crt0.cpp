|
| Initialization code; this is common to both 16 and 32 bit libraries,
| so be careful!
|
	.globl	__base		| BASEPAGE *, declared in crtinit.c

|
| Assumption: basepage is passed in a0 for accessories; for programs
| a0 is always 0.

	.text
	.even
	.globl	__start
__start:

	subl	a6, a6		| clear a6 for debuggers
	cmpw	#0, a0		| test if acc or program
	jeq	__startprg	| if a program, go elsewhere
	tstl	a0@(36)		| also test parent basepage pointer
	jne	__startprg	| for accs, it must be 0

	clr.w	-(sp)
	trap #1

| program startup code: doesn''t actually do much, other than push
| the basepage onto the stack and call _start1 in crtinit.c
|
__startprg:
	movel	sp@(4), a0	| get basepage
	movel	a0, __base	| save it

	lea	newstack(pc),sp
	jmp	__crtinit	| in crtinit.c

	.bss
	.align 4
stack:	ds.l 1000
newstack:	ds.l 1

