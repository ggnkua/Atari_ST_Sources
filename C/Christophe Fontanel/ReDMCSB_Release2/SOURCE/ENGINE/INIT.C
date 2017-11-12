/*
	This is the very first stuff that executes when a program is run.
	It sets up the global variables, strings, stack etc.
*/

#define STACKSIZE 2000

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

extern _init(), _main(), main();
char *_base;	/* points to base page of program */

#ifndef LINT
overlay "init!"
asm {
	_init:		/* initialization entry point; RTS plugged in by linker */
}
#endif

#ifndef LINT
overlay "main"
asm {
	_main:
		movea.l	4(A7),A5		; A5=basepage address
		move.l	bsslen(A5),D6
		move.l	codelen(A5),D0
		add.l	datalen(A5),D0
		add.l	D6,D0
		add.l	#256+STACKSIZE,D0 ;D0=basepage+textlen+datalen+bsslen+stack
		move.l	D0,D1
		add.l	A5,D0			; compute stack top
		andi.w	#-2,D0			; ensure even byte boundary
		movea.l	D0,A7			; setup user stack

		move.l	D1,-(A7)		; return storage above stack to system
		move.l	A5,-(A7)
		clr.w	-(A7)			; junk word
		move	#0x4a,-(A7)		; return excess storage
		trap	#1
		adda.w	#12,A7

		movea.l	lbss(A5), A0	;swap data and bss segments
		movea.l	A0, A1
		adda.l	D6, A1
		move.l	datalen(A5), D0
		subq.l	#1, D0			; dbf loop is stupid
		ble.s		swapcont		;might not have any data
	swap:
		move.b	-(A0), -(A1)
		dbf		D0,swap
	swapcont:

		movea.l	ldata(A5), A0	;clear bss segment
		move.l	D6, D0
		movea.l	A0, A4
		adda.l	D6, A4
		subq.l	#1, D0
	clear:	
		clr.b	(A0)+
		dbf		D0, clear

		move.l	A5, _base(A4);

		movea.l	lcode(A5), A5	;A5 points to jump table

		jsr		_init			;initialize globals and statics now
		jmp		main			;call application's entry point
}
#endif
