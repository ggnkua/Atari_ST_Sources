|
| Initialization code; this is common to both 16 and 32 bit libraries,
| so be careful!
|
| WARNING: All the instructions before the call to _checkcpu() must be
| compatible with any processor (including 680x0 and ColdFire models).
| So it must be written carefully by using only instructions common to all
| of the supported processors. Especially, gas pseudo-jump instructions must
| be avoided (jbsr, jbra...), because they may be translated to unsupported
| jump instructions.

| No __FASTCALL__ modifications required.

#include "libc-symbols.h"

|
| The following external symbols are declared with .globl rather than
| .extern in order to ensure they will be linked into the executable
| even if they are not used in this file.

	.globl	C_SYMBOL_NAME(_base)		| BASEPAGE *, defined in globals.c
	.globl	C_SYMBOL_NAME(_stksize)	| long, defined by user or in stksiz.c

|
| externs to pull ident strings of all used libraries into the
| executable; if a library is not used, then the extern is
| satisfied by a dummy in the library

| nobody needs this
|	.globl	C_SYMBOL_NAME(__Ident_gnulib)
|	.globl	C_SYMBOL_NAME(__Ident_socketlib)
|	.globl	C_SYMBOL_NAME(__Ident_gem)

|
| Functions defined elsewhere.

	.extern C_SYMBOL_NAME(_acc_main)	| void _acc_main(void);
	.extern	C_SYMBOL_NAME(_crtinit)	| void _crtinit(void);

|
| Assumption: basepage is passed in a0 for accessories; for programs
| a0 is always 0.

	.text
	.even
#ifdef __ELF__
	.section	.text.entry.mint,"ax",@progbits
#endif /* __ELF__ */
	.globl	C_SYMBOL_NAME(_start)
C_SYMBOL_NAME(_start):
	subl	%a6, %a6		| clear a6 for debuggers
	cmpl	#0, %a0		| test if acc or program
	beqs	__startprg	| if a program, go elsewhere
	tstl	%a0@(36)		| also test parent basepage pointer
	bnes	__startprg	| for accs, it must be 0
	movel	%a0, C_SYMBOL_NAME(_base)	| acc basepage is in A0
	lea	%a0@(252), %sp	| use the command line as a temporary stack
	jmp	C_SYMBOL_NAME(_acc_main)	| function is in accmain.c
|
| program startup code: doesn''t actually do much, other than push
| the basepage onto the stack and call _start1 in crtinit.c
|
__startprg:
	movel	%sp@(4), %a0	| get basepage
	movel	%a0, C_SYMBOL_NAME(_base)	| save it
	movel	%a0@(4), %d0	| get _base->p_hitpa
	bclr	#0, %d0		| round off
	movel	%d0, %sp		| set stack (temporarily)
	subl	#64, %sp		| see note in mintlib/setstack.S
	jmp	C_SYMBOL_NAME(_crtinit)	| in main.c

|
| interfaces for gprof: for crt0.o, does nothing, but for gcrt0.o branches
| to the appropriate subroutines
|
	.globl 	C_SYMBOL_NAME(_monstartup)
	.globl	C_SYMBOL_NAME(_moncontrol)
	.globl 	C_SYMBOL_NAME(__mcleanup)

#ifdef GCRT0
	.extern	C_SYMBOL_NAME(monstartup)
	.extern	C_SYMBOL_NAME(moncontrol)
	.extern	C_SYMBOL_NAME(_mcleanup)

C_SYMBOL_NAME(_monstartup):
	jmp	C_SYMBOL_NAME(monstartup)
C_SYMBOL_NAME(_moncontrol):
	jmp	C_SYMBOL_NAME(moncontrol)
C_SYMBOL_NAME(__mcleanup):
	jmp	C_SYMBOL_NAME(_mcleanup)
#else
C_SYMBOL_NAME(_monstartup):
C_SYMBOL_NAME(_moncontrol):
C_SYMBOL_NAME(__mcleanup):
	rts
#endif /* GCRT0 */
