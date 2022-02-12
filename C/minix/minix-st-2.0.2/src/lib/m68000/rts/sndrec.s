#
	.define	__send
	.define	__receive
	.define	__sendrec
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */
! =====================================================================
!                           send and receive                          =
! =====================================================================
! _send(), _receive(), _sendrec() destroy d0, d1, and a0.

! See ../h/com.h for C definitions
SEND	= 1
RECEIVE	= 2
BOTH	= 3

	.sect	.text

__send:	move.w	#SEND,d0	! send(dest, ptr)
	bra	L0

__receive:
	move.w	#RECEIVE,d0	! receive(src, ptr)
	bra	L0

__sendrec:
	move.w	#BOTH,d0	! sendrec(srcdest, ptr)
L0:				! d0 = SEND/RECEIVE/BOTH
#ifdef __MLONG__
	move.l	4(sp),d1	! d1 = dest-src
	move.l	8(sp),a0	! a0 = message pointer
#else
	move.w	4(sp),d1	! d1 = dest-src
	move.l	6(sp),a0	! a0 = message pointer
#endif /* __MLONG__ */
	trap	#0		! trap to the kernel
#ifdef	__MLONG__
	ext.l	d0		! return int
#endif /* __MLONG__ */
	rts			! return
