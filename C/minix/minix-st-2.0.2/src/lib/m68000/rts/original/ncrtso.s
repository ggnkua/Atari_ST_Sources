#
! This is the C run-time start-off routine.  It s job is to take the
! arguments as put on the stack by EXEC, and to parse them and set them up the
! way _main expects them.
! It also initializes _environ when this variable isn t defined by the
! programmer.  The detection of whether _environ belong to us is rather
! simplistic.  We simply check for some magic value, but there is no other
! way.

! public labels
	.define	__penviron
	.define __penvp
	.extern	_environ
#ifdef __ACK__
	.define	EXIT
	.define	.trpim
	.define	.trppc
#endif	/* __ACK__ */
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */
! external references
	.extern	_main
	.extern	_exit
	.extern begtext, begdata, begbss, endtext, enddata, endbss

	.sect	.text
begtext:
start:	
	move.l	sp,a0
	move.l	(a0)+,d0	! long due to lib/exec.c and mm/exec.c
	move.l	d0,d1
	add.l	#1,d1
	asl.l	#2,d1		! pointers are four bytes on 68000
	move.l	a0,a1
	add.l	d1,a1
#ifdef __ACK__
	move.l	a1,__penvp
	! Test whether address of environ < address of end.
	! This is done for separate I&D systems.
	! There is no separate I&D for the 68000-MINIX versions (yet),
	! the check is included for safety reasons.
	move.l	#_environ,d1	! get address of environ
	cmp.l	#begbss,d1	! inside data space?
	bcc	1f		! no
	cmp.w	#0x5353,_environ ! initialization intact?
	bne	1f		! no
#endif	/* __ACK__ */
	move.l	a1,_environ	! save _penvp in environ
1:
	move.l	a1,-(sp)	! push environ
	move.l	__penviron,a1	! get pointer __penviron
	move.l	(sp),(a1)	! *__penviron = _penvp;
	move.l	a0,-(sp)	! push argv
	move.w	d0,-(sp)	! push argc
	jsr	_main
	add.l	#10,sp
#ifdef __ACK__
EXIT:
#endif	/* __ACK__ */
	move.w	d0,-(sp)	! push exit status
	jsr	_exit
L0:	bra	L0

	.sect	.data
begdata:
	.data4	0		! for sep I&D: *NULL == 0
__penviron:
	.data4	__penvp		! Pointer to environ, or hidden pointer

#ifdef	__ACK__
.trpim:	.data2	0
.trppc:	.data4	0
#endif	/* __ACK__ */
	.sect .bss
begbss:
	.sect	.bss
	.comm	__penvp, 4		! Hidden environment vector

