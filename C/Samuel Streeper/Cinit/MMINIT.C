/*	Megamax program/accessory initialization */

/*                 by Samuel Streeper            */
/*          Copyright 1989 Antic Publishing      */

#define lcode 8			/* Code segment start */
#define codelen 12		/* Code segment length */
#define ldata 16		/* Data segment start */
#define datalen 20		/* Data segment length */
#define lbss 24			/* Bss  segment start */
#define bsslen 28		/* Bss  segment length */

extern _init(), _main(), main();
extern int _stack_bot, _stack[];

char *_base;		/* points to base page of program */
long _prog_size;	/* save size of program */
int _app;		/* 0xff if application, 0 if accessory */

overlay "init!"
asm {
	_init:	/* initialization entry point; RTS plugged in by linker */
}

overlay "main"
asm {
	_main:
		lea		_main,A5
	m1:	cmpi	#0x4ef9,-6(A5)	;find top of jump table
		bne	m2
		subq	#6,A5
		bra	m1

	m2:	suba	#0x100,A5		;A5=basepage address
		move.l	codelen(A5),D6
		add.l	datalen(A5),D6
		add.l	bsslen(A5),D6
		add.l	#0x100,D6		;D6=basepage+txtlen+datalen+bsslen+256

		move.l	lbss(A5), A0	;swap data and bss segments
		movea.l	A0, A1
		adda.l	bsslen(A5), A1
		move.l	datalen(A5), D0
		subq.l	#1, D0			;dbf loop is stupid
		ble		swapcont		;might not have any data
	swap:
		move.b	-(A0), -(A1)
		dbf		D0,swap
	swapcont:

		move.l	ldata(A5), A0		;clear bss segment
		move.l	bsslen(A5), D0
		subq.l	#1, D0
	clear:	
		clr.b	(A0)+
		dbf		D0, clear

		move.l	ldata(A5), A4		;A4 points between bss and data
		adda.l	bsslen(A5), A4

		lea		_stack_bot(A4),A7	;setup user stack

		moveq	#0,D5
		tst.l	0x24(A5)		;do I have a parent?
		sne		D5
		beq		is_da			;no, is desk acc

		move.l	D6,-(A7)		;return storage above stack to system
		move.l	A5,-(A7)
		clr		-(A7)
		move	#0x4a,-(A7)		;Mshrink
		trap	#1
		lea		12(A7),A7

	is_da:
		move.l	A5, _base(A4)
		move.l	D6, _prog_size(A4)
		move	D5, _app(A4)

		move.l	lcode(A5), A5	;A5 points to jump table

		jsr		_init			;initialize globals and statics now

		jsr		main			;call application's entry point

		clr -(A7)				;on return do Pterm0()
		trap #1
}
