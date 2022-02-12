.sect .text
.sect .rom
.sect .data
.sect .bss
.sect .bss
.comm _gtobuf,18
.extern ___setjmp
.extern _sigprocmask
.extern __longjmperr
.extern __sigjmp
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
	move.l (a6),-(sp)	! push frame pointer
	pea     8(a6)		! stack pointer
	move.l  4(a6),-(sp)	! program counter
	pea 0			! signal mask (to be filled in later if needed)
	move.w #4,-(sp)		! flags (4 is SC_NOREGLOCALS)
	tst.w	 12(a6)		! get the savemask arg
	beq	nosigstate	! don't save signal state

	or.w	#2,-18(a6)	! flags |= SC_SIGCONTEXT

	pea	-16(a6)		! place to store old mask
	pea	0		! set pointer; NULL
	move.w #0,-(sp)		! how; SIG_BLOCK
	jsr	_sigprocmask	! fill in signal mask
	add.l	#10,sp

nosigstate:
	move.l 8(a6),a0
	move.l #8,d0		! copy structure (9 words)
1:
	move.w (sp)+,(a0)+
	dbf d0,1b
	clr.w d0
	unlk a6
	rts

.extern __longjmp
__longjmp:
	link	a6,#-0
! Copy the jmp_buf to the gtobuf.
	lea _gtobuf,a0
	move.l 8(a6),a1
	move.l #8,d0
	1:
	move.w (a1)+,(a0)+
	dbf d0,1b

! Check that this jmp_buf has no saved registers.
	cmp.w 	#4, _gtobuf
	bne	__longjmperr

! Set up the value for setjmp to return in d0.
	move.w 12(a6),d0
	bne I3_3
	move.l #1,d0
I3_3:
	lea _gtobuf,a0
	move.l 14(a0),a6
	move.l 10(a0),sp
	move.l 6(a0),a0
	jmp (a0)

.extern _longjmp
_longjmp:
	link	a6,#-0

! Check that this is a jmp_buf with no saved regs and with signal context info.
	move.l 8(a6),a0
	cmp.w 	#6,(a0)
	bne	__longjmperr

! Set up the value for setjmp to return in d0.
	move.w 12(a6),d0
	bne I3_4
	move.l #1,d0
I3_4:

! Call _sigjmp to restore the old signal context.
	move.w	d0,-(sp)
	move.l	 8(a6),-(sp)
	jsr	__sigjmp	! does not return!
