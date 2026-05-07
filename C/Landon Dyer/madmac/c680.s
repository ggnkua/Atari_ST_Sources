* c680.s

*------------------------------------------------------------------------
*									:
*	Alcyon lib7 startup code					:
*	Copyright 1986 Atari Corp.					:
*									:
*------------------------------------------------------------------------

*---------------- HISTORY ----------------
*
*  7-Sep-1986 lmd	added overflow check in _sbrk (chicken factor)
* 13-Aug-1986 lmd	added `_brk()'
* 10-Aug-1986 lmd	added `_sbrk()' and break stuff (needs overflow check)
*  7-Aug-1986 lmd	installed `__stackp' for user-defined stack
*  4-Aug-1986 lmd	hacked it up
*

CHICKEN		=	$400		; 1K chicken factor


* Imports:
	.globl	_main
	.globl	__stackp		; -> default stack (or NULL)


* Exports:
	.globl	__bp			; -> basepage
	.globl	__break			; -> "break"
	.globl	_sbrk			; adjust "break"
	.globl	_brk			; set "break"


*
*  Basepage structure
*
LOWTPA	=	0
HITPA	=	4
TBASE	=	8
TLEN	=	$c
DBASE	=	$10
DLEN	=	$14
BBASE	=	$18
BLEN	=	$1c
DTA	=	$20
PARENT	=	$24
ENV	=	$2c



*+
*  Initial startup for Atari GEMDOS programs
*
*	save pointer to basepage in "__bp"
*	setup break limits for _sbrk()
*	parse argc, argv commandline arguments
*	call _main
*
*-
	move.l	4(sp),a0		; a0 -> basepage
	tst.l	__stackp		; keep top-of-TPA stack?
	beq	su_1
	move.l	__stackp,sp		; use user stack

su_1:	move.l	a0,__bp			; record basepage addr in magic global
	move.l	BBASE(a0),d0		; set break to just past top of BSS
	add.l	BLEN(a0),d0
	move.l	d0,__break

	add.w	#$80,a0			; null-terminate commandline
	moveq	#0,d0
	move.b	(a0)+,d0
	clr.b	(a0,d0.w)		; (stuff with EOS)
	move.l	a0,a1

	moveq	#-1,d1			; d1 < 0, don't push addrs
	moveq	#0,d2			; starting arg count = 0
	lea	ret1(pc),a6		; a6 -> return addr
	bra.s	getargs			; get argument count

ret1:	lsl.w	#2,d2			; d2 *= sizeof(pointer)
	sub.w	d2,sp			; make room on stack for args
	moveq	#0,d1			; d1 >= 0, push addrs
	moveq	#1,d2			; starting arg count = 1
	lea	ret2(pc),a6		; a6 -> return addr
	move.l	a1,a0
	bra.s	getargs

ret2:	pea	arg0(pc)		; push addr of arg zero
	pea	(sp)			; push addr of pointer vector
	move.w	d2,-(sp)		; push number of arguments
	jsr	_main			; call main()
	clr.w	-(sp)			; Pterm0()
	trap	#1
	illegal				; "cannot happen"


*
*  Record/Count arguments
*
*  a0 -> null-terminated commandline
*  d2  = starting argument count
*
*  If d0 == -1, then count arguments at "a0"
*  If d0 == 0, then count arguments in d2 and record their addresses
*
getargs:
	move.b	(a0)+,d0		; get next char
	beq.s	ga_q			; quit on EOS
	cmp.b	#$20,d0			; continue if space
	beq.s	getargs
	cmp.b	#$09,d0			; continue if tab
	beq.s	getargs

	addq.w	#1,d2			; bump argument count
	tst.w	d1			; if (d1 < 0)
	bmi.s	ga_1			;    just count args...
	subq.l	#1,a0			; backup to first char in word
	move.l	a0,(sp,d1.w)		; save ptr to arg on stack
	addq.w	#4,d1			; bump stack index

ga_1:	move.b	(a0)+,d0		; get next char
	beq.s	ga_q			; quit on EOS
	cmp.b	#$20,d0			; stop on space
	beq.s	ga_2
	cmp.b	#$09,d0			; continue if not tab
	bne.s	ga_1

ga_2:	tst.w	d1			; if (d1 == -1)
	bmi.s	getargs			;    then don't terminate argument
	clr.b	-1(a0)			; terminate arg
	bra.s	getargs
ga_q:	jmp	(a6)			; return


*+
*  _sbrk(amount)	Allocate memory from top of break
*    LONG amount;	(between top of BSS and the stack bottom)
*
*  No check for overflow is done.  This needs to happen.
*
*-
_sbrk:
	move.l	__break,d0		; d0, d2 = break
	move.l	d0,d2
	move.l	4(sp),d1		; d1 = amount
	btst	#0,d1			; ensure amount is
	beq.s	sbrk1			;   even, to preserve
	addq.l	#1,d1			;   future WORD alignment
sbrk1:	add.l	d1,d2			; adjust new break value
	move.l	sp,d1			; d1 = sp - newbreak
	sub.l	d0,d1
	cmp.l	#CHICKEN,d1		; the infamous chicken factor
	blt.s	sbrko			; (wups!  break too close to stack...)
	move.l	d2,__break		; set new break value
	rts
sbrko:	moveq	#-1,d0			; return -1L
	rts				; (out of break)


*+
*  _brk - set break address
*
*-
_brk:
	move.l	4(sp),__break		; (stupid little assignment....)
	rts



__bp:		dc.l	0		; -> basepage
__break:	dc.l	0		; -> top of break (just past BSS)
arg0:		dc.w	0		; null argv[0]
