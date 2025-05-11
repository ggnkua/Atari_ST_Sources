|
|		Cross Development System for Atari ST 
|      Copyright (c) 1988, Memorial University of Newfoundland
|
|  C start-up routine.  Has several tasks to do:
|	release unneeded memory to the system
|	set up stack
|	set up argc, argv, and envp
|	set up an address trap handler for bsr.l instructions
|  Also defines _exit() so the address error handler can be restored
|
| $Header: crt0.s,v 1.3 88/02/03 20:23:26 m68k Exp $
|
| $Log:	crt0.s,v $
| Revision 1.3  88/02/03  20:23:26  m68k
| Added __in_trap flag - see atari/alarm()
| 
| Revision 1.2  88/01/29  17:24:37  m68k
| Re-wrote the argument parsing stuff
| Calls exit() instead of _exit()
| uses Setvec() trap instead of Super()/mov/Super() to change the ae trap
| stack now has initial size of 8k (up from 2)
| 
|
	.globl	__start
	.globl	__exit
	.globl	__base
	.globl	_environ
	.globl	_main
	.globl	_errno
	.globl	__in_trap

	.comm	__base,4
	.comm	__stksize,4
	.comm	_environ,4
	.comm	_errno,4
	.comm	old_aet,4
	.comm	__in_trap,1

	.text

__start:
	movl	a7@(4), a5
	movl	a5, __base

	| set up envp[] and argv[] stuff
	movl	a5@(0x18), a1		| envp = basepage->bss_address
	addl	a5@(0x1c), a1		|	+ basepage->bss_size;
	movl	a1, _environ		| _environ = envp;
	movl	a5@(0x2c), a2		| ep = basepage->envp;
L0:	tstb	a2@			| while (*ep) {
	beq	L3			|
	movl	a2, a1@+		|	*envp++ = ep;
L2:	tstb	a2@+			|	while (*ep++)
	bne	L2			|		;
	bra	L0			| }
L3:	clrl	a1@+			| *envp++ = (char *) 0; 
	|  From here down to 0: is only relivent if you are using the mark
	| williams shell, which passes the arguments in the environment as
	| well as the base page (also passes argv[0]).  The start of the
	| arguments is marked by a env variable by the name ARGV (which has
	| some i/o vector stuff in it - not used).
	movl	_environ, a3		|
L1:	tstl	a3@			| for (s = environ ; *s ; s++)
	beq	L7			|
	movl	a3@+, a4		|	if (strncmp(*s, "ARGV=", 5))
	cmpb	#0x41, a4@+		|
	bne	L1			|
	cmpb	#0x52, a4@+		|
	bne	L1			|
	cmpb	#0x47, a4@+		|
	bne	L1			|
	cmpb	#0x56, a4@+		|
	bne	L1			|
	cmpb	#0x3d, a4@+		|
	bne	L1			|	{
	clrl	a3@-			|		*--s = 0;
	movl	a3, a2			|		argv = s + 2;
	addql	#0x4, a2		|
	movl	a1, a0			|		
	movl	a1, d3			|		argc = (&a1[1] - argv)
	subl	a2, d3			|			/ sizeof(long);	
	subql	#0x4, d3		|
	asrl	#0x2, d3		|		break;
	bra	L6			|	}
L7:					| /* a1: envp -> argbuf */
	movl	a1, a0			| argv = argbuf
	addl	#128, a0		|	 + sizeof(baseage->cmdline);
	clrw	a0@+			| *((short)argv)++ = 0;
	movl	a1, d1			| argstart = argbuf;
	movl	a0, a2			| saveargv = argv;
|	movew	#1, d3			| argc = 1;
	movel	#1, d3			| .. jrd
	movl	#arg0, a0@+		| *argv++ = "arg0.prg";
	movl	#0x80, a3		| cmdline = basepage->cmdline;
	addl	a5, a3			|
	moveb	a3@, d0			| /* # of chars in cmdline buf (128) */
L8:	subqb	#1, d0			| while (d0-- > 0)
|	ble	L9			|
	blt	L9			| .. jrd
	addql	#1, a3			|	 if (*++cmdline == 0)
	tstb	a3@			| 	{
	bne	L11			|
L9:	cmpl	a1, d1			|		if (argbuf != argstart)
	beq	L10			|		{
	clrb	a1@+			|		    *argbuf++ = '\0';
	movl	d1, a0@+		|		    *argv++ = argstart;
|	addqw	#1, d3			|		    argc++;
	addql	#1, d3
					|		}
L10:	clrl	a0@+			|		*argv++ = (char *) NULL;
	bra	L6			| 		break;
L11:	cmpb	#0x20, a3@		|	 } else if (*cmdline == ' ')
	bne	L12			|	 {
|	addqw	#1, d3			|		argc++;
	addql	#1,d3			| .. jrd
	movl	d1, a0@+		|		*argv++ = argstart;
	clrb	a1@+			|		*argbuf++ = '\0';
	movl	a1, d1			|		argstart = argbuf;
	bra	L8			|	 } else
L12:	moveb	a3@, a1@+		|		*argbuf++ = *cmdline;
	bra	L8

L6:
	movl	a0, a3			| reserve = argv - __base;
	subl	a5, a3
	tstl	__stksize		| if (!__stksize)
	bne	L13			|
	movl	#0x2000, __stksize	|	__stksize = 8 * 1024;
L13:	addl	__stksize, a3		| reserve += __stksize;
	movl	a3, d1
	addl	a5, d1			| compute stack top
	andl	#-2, d1			| even boundry
	movl	d1, sp			| set up user stack

	movl	a3, sp@-
	movl	a5, sp@-
	clrw	sp@-
	movw	#0x4a, sp@-
	bset	#0, __in_trap
	trap	#1			| release excess storage
	bclr	#0, __in_trap
	addl	#12, sp

	movl	_environ, sp@-		| push saveenvp
	movl	a2, sp@-		| push saveargv
|	movw	d3, sp@-		| push argc
	movel	d3,sp@-			| .. jrd

	subl	a6, a6			| clear link reg - why I don't know

	| here we set up a trap handler for address errors - this is used in
	| doing long branches and long bsrs (see comments in Leat()).

	movl	#aet, sp@-	| set address error vector to our handler
	movew	#0xc, sp@-
	movew	#0x5, sp@-
	bset	#0, __in_trap
	trap	#13
	bclr	#0, __in_trap
	addql	#0x8, sp
	movl	d0, old_aet	| save old trap handler

|	jsr	_main
	jsr	__main		| -- jrd.  call the standard wrapper fun
	movew	d0, sp@-
	jsr	_exit		| _exit calls __exit
	| Not reached

|
| _exit is here because it has to restore the old address error vector
|
__exit:
	movl	old_aet, sp@-	| restore old address trap before we exit
	movew	#0xc, sp@-
	movew	#0x5, sp@-
	bset	#0, __in_trap
	trap	#13
	bclr	#0, __in_trap
	addql	#0x8, sp
|	movew	sp@(0x4), sp@-	| .. jrd
	movel	sp@(4),d0
	movew	d0,sp@-
	movew	#0x4c, sp@-
	bset	#0, __in_trap
	trap	#1
	| The End.

|  This is a trap handler for address errors.  It is used in doing long
| branches and long bsrs.  It looks to see if a long branch (0x6?ff) caused
| the trap and if the destination is valid (not an odd address).  If so
| the branch is taken and we return, otherwise, we call the old address
| trapper.
aet:
	| d0, and a1 used 0x8080/101
	| exp_frame is distance from top of stack to exception frame
	Lexp_frame = 8			| 2 * sizeof(register)
	moveml	#0x8080, sp@-		| save registers used
	movw	sp@(Lexp_frame+6), d0	| the bad instruction
	andw	#0xf0ff, d0
	cmpw	#0x60ff, d0		| is a b?? instruction?
	jne	L20			| nop, call old ae trap

	movl	sp@(Lexp_frame+10), a0	| the pc (currently bewtixt branch)
	addql	#1, a0			| increment to long offset
	addl	a0@, a0			| calculate new pc
	movl	a0, d0
	andb	#1, d0			| are we still an odd address?
	jne	L20			| yep, get out.

	movl	a0, sp@(Lexp_frame+10)	| put new pc into the stack frame
	cmpw	#0x61ff, sp@(Lexp_frame+6)	| if this is a bsrl
	jne	L21			|  we need to fix up the return
	movl	usp, a0			|  address on the user stack
	addql	#4, a0@
L21:
	moveml	sp@+, #0x0101		| restore regs
	addql	#8,sp			| pop part of stack frame
	rte

L20:
	moveml	sp@+, #0x0101
	movl	old_aet, sp@(-4)	| done this way so no regs get mussed up
	jmp	sp@(-4)

.data
arg0:	.ascii "arg0\0"
