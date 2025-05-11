|
|		Cross Development System for Atari ST 
|      Copyright (c) 1988, Memorial University of Newfoundland
|
|   At this point we take over from dos - we know (think?) that the stack
| looks like this now:
|	0	long	pc
|	4	long	arg (pointer to d7 below)
|		(stuff - unknown size - depends on compiler - could be size 0)
|		long	pc
|	*4	long	d7
|	*4+0x4	long	a0
|	*4+0x8	long	d0
|	*4+0xc	long	d1
|		.
|		.
|	*4+0x24	long	d7
|	*4+0x28	long	a0
|		.
|		.
|	*4+0x40	long	a6
|	*4+0x44	word	sr	status register from exception
|	*4+0x46	long	pc	pc from exception
|		stuff
|  The stratagy at this point consists of saving the exception sr/pc and puting
| out own address in place of the pc.  When the system does it's rte we get
| called and we call do_signal (which can call some routine which can do a 
| longjmp).  If do_signal returns then we restore the sr/pc and do a rte.
|
| $Header: alrm_nasty.s,v 1.1 88/02/03 22:37:55 m68k Exp $
|
| $Log:	alrm_nasty.s,v $
| Revision 1.1  88/02/03  22:37:55  m68k
| Initial revision
| 

.globl	__in_trap			| extern
.globl	__do_signal			| extern
.globl	__alrm_nasty

.comm	__in_trap, 1

.comm	alrm_sr, 2			| static
.comm	alrm_pc, 4			| static

__alrm_nasty:
	movel	sp@(0x4), a0
	movew	a0@(0x44), alrm_sr
	movel	a0@(0x46), alrm_pc
	movew	#0x2300, a0@(0x44)	| fake sr (with super bit on)
	movel	#alrm_fake, a0@(0x46)	| our fake return routine
	rts

alrm_fake:
	moveml	d0-d2/a0-a2, sp@-	| save registers
	movel	#0x1, sp@-		| _do_signal(SIGALRM)
	jsr	__do_signal		|
	addql	#0x4, sp		| pop signum
	moveml	sp@+, d0-d2/a0-a2	| pop registers
	movel	alrm_pc, sp@-		| push the original sr/pc on stack
	movew	alrm_sr, sp@-
	rte
