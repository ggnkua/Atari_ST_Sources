/*
	This is the very first stuff that executes when a desk accessory is run.
	It sets up the global variables, strings, stack etc.
*/

#define STACKSIZE 4096

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
extern int _GLBLSIZE;
char *_base;	/* points to base page of program */
char _stack[STACKSIZE];	/* stack space for desk accessory */

#ifndef LINT
overlay "init!"
asm {
	_init:		/* initialization entry point; RTS plugged in by linker */
}
#endif

#ifndef LINT
overlay "main"
extern write_num();

asm {
	_main:
		lea		_main(PC), A5	;_main is first thing loaded into text seg.
	l1:
		cmpi	#0x4ef9,-6(A5)	;skip past jump table to beginning of text
		bne		l2
		subq.l	#6, A5
		bra		l1
	l2:
		suba.l	#256, A5		;base page 256 bytes in front of text seg.

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
		lea		_stack+STACKSIZE(A4), A7	;Set up stack

		move.l	lcode(A5), A5	;A5 points to jump table

		jsr		_init			;initialize globals and statics now
		jsr		main			;call application's entry point

		move	#0, -(A7)
		jsr		exit
notify:	/**** DEBUGING stuff ****/
	movem.l	A0-A6/D0-D7, -(A7)	
	move	#65, -(A7)
	move	#2, -(A7)
	trap	#1
	addq.l	#4, A7
	move.l	#1000000, D0
not1:
	subq.l	#1, D0
	bne.s	not1
	movem.l	(A7)+, D0-D7/A0-A6
	rts
}

/*write_num(x)
long x;
{
	if (x <= 9) {
		(int)x+'0';
		asm {
			move	D0, -(A7)
			move	#2, -(A7)
			trap	#1
			addq.l	#4, A7
		}
	}
	else {
		write_num(x/10);
		(int)(x%10 + '0');
		asm {
			move	D0, -(A7)
			move	#2, -(A7)
			trap	#1
			addq.l	#4, A7
		}
	}
}*/

#endif
