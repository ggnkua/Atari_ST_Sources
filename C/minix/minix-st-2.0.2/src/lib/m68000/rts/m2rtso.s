#
! This is the C run-time start-off routine.  It s job is to take the
! arguments as put on the stack by EXEC, and to parse them and set them up the
! way _main expects them.
! It also initializes _environ when this variable isn t defined by the
! programmer.  The detection of whether _environ belong to us is rather
! simplistic.  We simply check for some magic value, but there is no other
! way.

! public labels
	.define	m2rtso
	.define	hol0
	.define	__fpu_present
	.define	__penviron
	.define __penvp
	.extern	_environ
#ifdef __ACK__
	.define	EXIT
	.define	.trpim
	.define	.trppc
	.define	.lino
	.define	.filn
	.define	.limhp		! heap pointer (heap checking)
	.define	.reghp		! upper heap margin
#ifdef FLOAT_STARTUP
	.extern	__fp_hook
#endif /* FLOAT_STARTUP */
#endif	/* __ACK__ */

#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

! external references
	.extern	_exit
	.extern	___integersize_
	.extern	endbss

!	.extern begtext, begdata, begbss, endtext, enddata, endbss

	.sect	.text
begtext:
m2rtso:
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
	move.l	#0,__fpu_present ! no fpu present
	move.l	a1,-(sp)	! push environ
	move.l	__penviron,a1	! get pointer __penviron
	move.l	(sp),(a1)	! *__penviron = _penvp;
	move.l	a0,-(sp)	! push argv
	cmp.w	#2,___integersize_
	beq	2f
	move.l	d0,-(sp)	! push argc
	jsr	__m_a_i_n	! run Modula-2 program
	add.w	#12,sp
	bra	3f
2:
	move.w	d0,-(sp)	! push argc
	jsr	__m_a_i_n	! run Modula-2 program
	add.w	#10,sp
3:
#ifdef __ACK__
EXIT:
#endif	/* __ACK__ */
	cmp.w	#2,___integersize_
	beq	4f
	move.l	d0,-(sp)	! push exit status
	bra	5f
4:
	move.w	d0,-(sp)	! push exit status
5:
	jsr	_exit
L0:	bra	L0

	.sect	.data
begdata:
	.data4	0		! for sep I&D: *NULL == 0
hol0:
	.data4	0, 0
	.data4	0, 0
__penviron:
	.data4	__penvp		! Pointer to environ, or hidden pointer

#ifdef	__ACK__
.trpim:	.data2	0
.trppc:	.data4	0
.lino:	.data2	0		! source line number
.reghp:	.data4	endbss		! em_end.s
.limhp:	.data4	endbss		! em_ens.s
#endif	/* __ACK__ */
	.sect .bss

begbss:
	.comm	__penvp, 4		! Hidden environment vector
	.comm	__fpu_present, 4	! FPU present flag
#ifdef	__ACK__
	.comm	.filn, 4		! source filename
#endif /* __ACK__ */
