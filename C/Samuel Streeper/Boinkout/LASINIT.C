/****	init.c - Laser program/accessory startup *****/

/* Base page definitions */
#define codelen 12		/* Code segment length */
#define datalen 20		/* Data segment length */
#define bsslen 28		/* Bss  segment length */
#define par_bp 36		/* Parent basepage */

extern _main(), main(), _dbuginit();
char *_base;			/* points to base page of program */
int _app;				/* 0xff=program is app, 0=program is accessory */

long _progsize;			/* since I must calc this, I will leave this */
						/* value handy for terminate-stay resident progs */
int errno;
extern char _stack[];
extern long _stksize;

asm {
	_main:
		; I know I am running as a desk accessory by 2 tests:
		; if my initial stack is zero, or if I have a null
		; pointer to my parents basepage (All PROGRAMS have a
		; parent, be it the desktop or another program.
		; Null stack is undocumented, though! (so don't count on it)
		; note 2:
		; At startup, a program may get its basepage address from the
		; stack, ie
		;
		;			move.l 4(sp),A5		;A5 points to basepage
		;
		; For an accessory, however, the stack pointer is null and
		; this generates a bus error, so we assume that the basepage
		; immediately precedes the program, which is true if the
		; desktop or most shells executed the program. The following
		; code could be tweaked to accomodate discontiguous basepages
		; if necessary.

		lea		_main, A5		;Compute basepage address
		suba	#0x100, A5		;subtract size of basepage
		lea		_stack,A7
		adda.l	_stksize,A7		;set up our stack

		moveq	#0,D5
		tst.l   par_bp(A5)		;Parent basepage pointer clear if ACC
		sne		D5				;D5 set if application
		move	D5,_app
		beq     cont			;is an accessory

	app:
			; if we are here, our thing is being run as a program, not
			; an accessory.

		move.l	codelen(A5),D0
		add.l	datalen(A5),D0
		add.l	bsslen(A5),D0
		addi.l	#0x100,D0

		move.l	D0,_progsize	;save program size
		move.l	D0,-(A7)		;amount of memory to keep
		move.l	A5,-(A7)		;starting at basepage
		clr		-(A7)			;junk word
		move	#0x4a,-(A7)		;Mshrink() - return excess storage
		trap	#1
		lea		12(A7),A7

	cont:
		move.l	A5, _base;		;so user progs can find basepage

		jsr		main			;call applications entry point

		clr		-(A7)			;do Pterm0() on return
		trap	#1
}
