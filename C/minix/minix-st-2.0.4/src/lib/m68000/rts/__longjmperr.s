#
! Assembler version of default _longjmperr().
! Does the same as other/_longjmperr.c.
! Not used!
!
! BSD calls this function _longjmperror()
! Minix-PC _longjerr()
! Minix-ST _longjmperr()
! Mmh. Why?
!
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
	.sect	.text
	.extern	__write
	.extern	__getpid
	.extern	__kill
	.define __longjmperr
__longjmperr:
#ifdef __MLONG__

	move.l	#14,-(sp)
	pea	failmsg		! message
	move.l	#2,-(sp)	! hope it is stderr
	jsr	__write
	add	#12,sp
abortlp:
	jsr	__getpid
	move.l	#6,-(sp)	! SIGABRT
	move.l	d0,-(sp)	! pid
	jsr	__kill		! should not return
	add	#8,sp
	bra	abortlp

#else

	move.w	#14,-(sp)	! strlen(message)
	pea	failmsg		! message
	move.w	#2,-(sp)	! hope it is stderr
	jsr	__write
	add	#8,sp
abortlp:
	jsr	__getpid
	move.w	#6,-(sp)	! SIGABRT
	move.w	d0,-(sp)	! pid
	jsr	__kill		! should not return
	add	#4,sp
	bra	abortlp
#endif /* __MLONG__ */

	.sect	.data
failmsg:
	.asciz	'longjmp error\n'
