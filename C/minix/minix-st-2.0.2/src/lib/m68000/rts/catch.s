#
	.define	__begsig
	.extern	__vectab
	.extern	__M
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

#ifdef ALCYON
#define FREEREGS d0-d2/a0-a2
sigoffset = 24
#endif
#ifdef __ACK__
#ifdef FOR_SOZOBON_ANY_MORE
#define FREEREGS d0-d2/a0-a2
sigoffset = 24
#else
#define FREEREGS d0-d2/a0-a1
sigoffset = 20
#endif /* FOR_SOZOBON */
#endif /* __ACK__ */

mtype = 2			! _M+mtype = &_M.m_type
	.sect	.text
__begsig:
	movem.l	FREEREGS,-(sp)
	clr.l	d0
	move.w	sigoffset(sp),d0	! d0 = signal number
	move.w	__M+mtype,-(sp)	! push status of last system call
	move.w	d0,-(sp)	! func called with signal number as arg
	asl.l	#2,d0		! pointers are four bytes on 68000
	move.l	#__vectab,a0
	move.l	-4(a0,d0),a0	! a0 = address of routine to call
	jsr	(a0)
back:
	add.l	#2,sp		! get signal number off stack
	move.w	(sp)+,__M+mtype	! restore status of previous system call
	movem.l	(sp)+,FREEREGS
	add.l	#2,sp		! remove signal number from stack
	rtr
