#
! This is the C run-time start-off routine.  It s job is to take the
! arguments as put on the stack by EXEC, and to parse them and set them up the
! way _main expects them.
! It also initializes _environ when this variable isn t defined by the
! programmer.  The detection of whether _environ belong to us is rather
! simplistic.  We simply check for some magic value, but there is no other
! way.
#define	SHL_STARTUP_INIT
! public labels
	.define	__penviron
	.define __penvp
	.extern	_environ
	.define	_etext
	.define	_edata
#ifdef __ACK__
	.define	EXIT
	.define	.trpim		! trap ignore mask
	.define	.trppc		! trap pc
#ifdef FLOAT_STARTUP
	.extern	__fp_hook	! link in floating point support (printf)
#endif /* FLOAT_STARTUP */
#endif	/* __ACK__ */

#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
	.sect	.end
#endif	/* __ACK__ */

! external references
	.extern	_main
	.extern	_exit
	.extern	___integersize_
#ifdef SHL_STARTUP_INIT
	.extern	initlib
#endif /* SHL_STARTUP_INIT */

!	.extern begtext, begdata, begbss, endtext, enddata, endbss
! Der GNU Linker definiert das Symbol _end intern
#ifndef GNUOBJ
	.define	__end
#endif /* GNUOBJ */

	.sect	.text
begtext:
start:
	move.l	sp,a0
	move.l	(a0)+,d0	! long due to lib/exec.c and mm/exec.c
#ifndef NO_TASK_STARTUP
	beq	2f		! argc == 0, user task, just call main()
#endif	/* NO_TASK_STARTUP */
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
#ifdef SHL_STARTUP_INIT
	jsr	initlib
#endif /* SHL_STARTUP_INIT */
	cmp.w	#2,___integersize_
	beq	2f
	move.l	d0,-(sp)	! push argc
	jsr	_main
	add.w	#12,sp
	bra	3f
2:
	move.w	d0,-(sp)	! push argc
	jsr	_main
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
_etext:
#ifndef	NO_TASK_STARTUP
_data_org:	! space for build to fill in sizes of KERNEL, MM, FS, INET, INIT
	.data2	0xDADA,0,0,0,0,0,0,0	! + long + __penvp for normal startup
#endif /* NO_TASK_STARTUP */
	.data4	0		! for sep I&D: *NULL == 0
__penviron:
	.data4	__penvp		! Pointer to environ, or hidden pointer

#ifdef	__ACK__
.trpim:	.data2	0
.trppc:	.data4	0
#endif	/* __ACK__ */
	.sect .bss
_edata:
#ifdef GNUOBJ
	.lcomm	begbss,2
#else
begbss:
#endif /* GNUOBJ */
	.comm	__penvp, 4		! Hidden environment vector

#ifndef GNUOBJ
	.sect	.end
__end:
#endif /* GNUOBJ */
