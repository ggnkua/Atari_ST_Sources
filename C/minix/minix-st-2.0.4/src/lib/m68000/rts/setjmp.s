#ifndef _SETJMP_SAVES_REGS
#define _SETJMP_SAVES_REGS	0
#endif

SC_SIGCONTEXT	=	2	! nonzero if signal context is included
SC_NOREGLOCALS	=	4	! nonzero if registers are not be saved/rest.

.sect .text
.sect .rom
.sect .data
.sect .bss

.sect .bss
.comm _gtobuf,18
.globl ___setjmp
.globl _sigprocmask
.globl __longjmperr
.globl __sigjmp
.sect .text
!
! Warning:  this code depends on the C language declaration of
! jmp_buf in <setjmp.h>, and on the definitions of the flags SC_ONSTACK,#
! SC_SIGCONTEXT, and SC_NOREGLOCALS in <sys/sigcontext.h>.
!
! ___setjmp is called with two arguments.  The third argument is pushed
! by compiler generated code transparently to the caller.
!
! ___setjmp(jmp_buf, savemask, retaddr)
!
___setjmp:
	link	a6,#-0
#if (_SETJMP_SAVES_REGS==1)
	move.l	a0,-(sp)	! save a0
	move.l	8(a6),a0	! jmp_buf
	movem.l	d0-d7,6(a0)		! dregs!
	move.l	(sp)+,6+32(a0)		! copy a0
	movem.l	a1-a5,6+32+4(a0)	! aregs
	move.l	(a6),6+32+24(a0)	! frame pointer
	pea	8(a6)			! stack pointer
	move.l	(sp)+,6+32+28(a0)
	move.l	4(a6),6+32+32(a0)	! program counter
	move.w	sr,6+32+32+4(a0)	! status reg
	clr.w	6+32+32+6(a0)		! dummy

	pea	0		! signal mask (to be filled in later if needed)
	move.w	#0,-(sp)	! flags (0 is !SC_NOREGLOCALS & !SC_SIGCONTEXT)
#ifdef __MLONG__
	tst.w	12+2(a6)	! get the savemask arg (32bit)
#else
	tst.w	12(a6)		! get the savemask arg
#endif /* __MLONG__ */
	beq	nosigstate	! don't save signal state

	or.w	#SC_SIGCONTEXT,-6(a6)	! flags |= SC_SIGCONTEXT

	pea	-4(a6)		! place to store old mask
	pea	0		! set pointer; NULL
#ifdef __MLONG__
	pea	0		! how; SIG_BLOCK
	jsr	_sigprocmask	! fill in signal mask
	add.l	#12,sp
#else	
	move.w	#0,-(sp)	! how; SIG_BLOCK
	jsr	_sigprocmask	! fill in signal mask
	add.l	#10,sp
#endif /* __MLONG__ */

nosigstate:
	move.l	8(a6),a0	! jmp_buf
#if 0
	move.w	-6(a6),(a0)+	! __flags
	move.l	-4(a6),(a0)+	! mask
	add.l	#6,sp
#else
	! dasselbe, nur einfacher
	move.w	(sp)+,(a0)+	! __flags
	move.l	(sp)+,(a0)+	! mask
#endif

#else
	move.l (a6),-(sp)	! push frame pointer
	pea     8(a6)		! stack pointer
	move.l  4(a6),-(sp)	! program counter
	pea	0		! signal mask (to be filled in later if needed)
	move.w	#SC_NOREGLOCALS,-(sp)	! flags (4 is SC_NOREGLOCALS)
#ifdef __MLONG__
	tst.w	12+2(a6)	! get the savemask arg
#else
	tst.w	12(a6)		! get the savemask arg
#endif /* __MLONG__ */
	beq	nosigstate	! don't save signal state

	or.w	#SC_SIGCONTEXT,-18(a6)	! flags |= SC_SIGCONTEXT

	pea	-16(a6)		! place to store old mask
	pea	0		! set pointer; NULL
#ifdef __MLONG__
	move.l	#0,-(sp)	! how; SIG_BLOCK
	jsr	_sigprocmask	! fill in signal mask
	add.l	#12,sp
#else
	move.w #0,-(sp)		! how; SIG_BLOCK
	jsr	_sigprocmask	! fill in signal mask
	add.l	#10,sp
#endif /* __MLONG__ */

nosigstate:
	move.l 8(a6),a0
	move.l #8,d0		! copy structure (9 words)
1:
	move.w (sp)+,(a0)+
	dbf d0,1b

#endif /* _SETJMP_SAVES_REGS */

#ifdef __MLONG__
	clr.l	d0
#else
	clr.w d0
#endif /* __MLONG__ */
	unlk a6
	rts

.globl __longjmp
__longjmp:
	link	a6,#-0

#if (_SETJMP_SAVES_REGS==1)
	move.l	8(a6),a0	! jmp_buf
	tst.w	(a0)		! __flags, regs saved, no sigcontext?
	bne	__longjmperr	! no, mmh
! Set up the value for setjmp to return in d0.
#ifdef __MLONG__
	move.l	12(a6),d0	! test return
#else
	move.w	12(a6),d0	! test return
#endif /* __MLONG__ */
	bne	1f		! branch if set
	move.l	#1,d0		! default 1
1:
	movem.l	6+4(a0),d1-d7		! restore d-regs
	movem.l	6+32+4(a0),a1-a7	! restore a-regs
#if 1
	move.l	6+32+32(a0),-(sp)	! program pointer to jump to
	move.l	6+32(a0),a0	! restore a0
	rts			! longjmp ...
#else
	move.l	6+64(a0),a0	! program pointer to jump to
	jmp	(a0)
#endif

#else

! Copy the jmp_buf to the gtobuf.
	lea _gtobuf,a0
	move.l 8(a6),a1
	move.l #8,d0
	1:
	move.w (a1)+,(a0)+
	dbf d0,1b

! Check that this jmp_buf has no saved registers.
	cmp.w 	#SC_NOREGLOCALS, _gtobuf
	bne	__longjmperr

! Set up the value for setjmp to return in d0.
#ifdef __MLONG__
	move.l	12(a6),d0
#else
	move.w	12(a6),d0
#endif /* __MLONG__ */
	bne	I3_3
	move.l #1,d0
I3_3:
	lea _gtobuf,a0
	move.l 14(a0),a6
	move.l 10(a0),sp
	move.l 6(a0),a0
	jmp (a0)

#endif /* _SETJMP_SAVES_REGS */

.globl _longjmp
_longjmp:
	link	a6,#-0

! Check if this is a jmp_buf with no saved regs and with signal context info.
	move.l 8(a6),a0		! jmp_buf

#if (_SETJMP_SAVES_REGS==1)
	cmp.w	#SC_SIGCONTEXT,(a0) ! regs saved, signal context info present
#else
	cmp.w 	#SC_NOREGLOCALS+SC_SIGCONTEXT,(a0) ! no regs saved, signal context info present
#endif /* _SETJMP_SAVES_REGS == 1 */

	bne	__longjmperr

! Set up the value for setjmp to return in d0.
#ifdef __MLONG__
	move.l	12(a6),d0
#else
	move.w	12(a6),d0
#endif /* __MLONG__ */
	bne	I3_4
	move.l	#1,d0
I3_4:

! Call _sigjmp to restore the old signal context.
#ifdef __MLONG__
	move.l	d0,-(sp)
#else
	move.w	d0,-(sp)
#endif /* __MLONG__ */
	move.l	 8(a6),-(sp)
	jsr	__sigjmp	! does not return!
