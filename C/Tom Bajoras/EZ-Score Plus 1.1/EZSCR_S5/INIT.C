/*
	This is the very first stuff that executes when a program is run.
	It sets up the global variables, strings, stack etc.
*/

#define STACKSIZE 8192

/* Base page definitions */
#define ltpa 0			/* Low TPA address */
#define htpa 4			/* High TPA address */
#define lcode 8			/* Code segment start */
#define codelen 12		/* Code segment length */
#define ldata 16		/* Data segment start */
#define datalen 20		/* Data segment length */
#define lbss 24			/* Bss  segment start */
#define bsslen 28		/* Bss  segment length */
#define freelen 32		/* free segment length */
#define resvd 36		/* Reserved */
#define fcb2 56			/* 2nd parsed fcb */
#define fcb1 92			/* 1st parsed fcb */
#define command 128		/* Command tail */

extern _init(), _main(), main(), _initargcv(), exit();
char *_base;	/* points to base page of program */

#ifndef LINT
overlay "init!"
asm {
	_init:		/* initialization entry point; RTS plugged in by linker */
}
#endif

int _argc;		/* initialized by _initargcv */
char **_argv;

#ifndef LINT
overlay "main"
asm {
	_main:
		move.l	A7,A5			; save A7 so we can get the 
                                                ; base page address
		move.l	4(A5),A5		; A5=basepage address
		move.l	codelen(A5),D0
		add.l	datalen(A5),D0
		add.l	bsslen(A5),D0
		add.l	#256+STACKSIZE,D0 ;D0=basepage+textlen+datalen+bsslen
                                          ;+8K stack
		move.l	D0,D1
		add.l	A5,D1			; compute stack top
		and.l	#-2,D1			; ensure even byte boundary
		move.l	D1,A7			; setup user stack

		move.l	D0,-(A7)		; return storage above stack to system
		move.l	A5,-(A7)
		clr.w	-(A7)			; junk word
		move	#0x4a,-(A7)		; return excess storage
		trap	#1
		adda.l	#12,A7

		move.l	lbss(A5), A0	;swap data and bss segments
		move.l	lbss(A5), A1
		adda.l	bsslen(A5), A1
		move.l	datalen(A5), D0
		subq.l	#1, D0			; dbf loop is stupid
		ble		swapcont		;might not have any data
	swap:
		move.b	-(A0), -(A1)
		dbf		D0,swap
	swapcont:

		move.l	ldata(A5), A0	;clear bss segment
		move.l	bsslen(A5), D0
		subq.l	#1, D0
	clear:	
		clr.b	(A0)+
		dbf		D0, clear

		move.l	ldata(A5), A4	;A4 points between bss and data
		adda.l	bsslen(A5), A4

		move.l	A5, _base(A4);

		move.l	lcode(A5), A5	;A5 points to jump table

		jsr		_init			;initialize globals and statics now

		move.l	_base(A4), A0	;set up argc and argv parameters
		pea		command(A0)
		jsr		_initargcv		;parse command line into argc and argv
		addq.l	#4, A7
		move.l	_argv(A4),-(A7)
		move.w	_argc(A4),-(A7)
		jsr		main			;call application's entry point
		addq.l	#6, A7

		move	#0, -(A7)
		jsr		exit

notify:	/**** DEBUGING stuff ****/
	move	#65, -(A7)
	move	#2, -(A7)
	trap	#1
	addq.l	#4, A7
	rts
}
#endif
