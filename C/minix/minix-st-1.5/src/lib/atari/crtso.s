#
! This is the C run-time start-off routine.  It's job is to take the
! arguments as put on the stack by EXEC, and to parse them and set them up the
! way _main expects them.

! public labels
	.define	_environ
#ifdef ACK
	.define	EXIT
	.define	.trpim
	.define	.trppc
#endif ACK
#ifdef ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif ACK
! external references
	.extern	_main
	.extern	_exit
	.extern	_etext
	.extern	_edata
	.extern	_end

	.sect	.text
start:	
	move.l	sp,a0
	move.l	(a0)+,d0	! long due to lib/exec.c and mm/exec.c
	move.l	d0,d1
	add.l	#1,d1
	asl.l	#2,d1		! pointers are four bytes on 68000
	move.l	a0,a1
	add.l	d1,a1
	move.l	a1,_environ	! save envp in environ
	move.l	a1,-(sp)	! push environ
	move.l	a0,-(sp)	! push argv
	move.w	d0,-(sp)	! push argc
	jsr	_main
	add.l	#10,sp
#ifdef ACK
EXIT:
#endif ACK
	move.w	d0,-(sp)	! push exit status
	jsr	_exit
L0:	bra	L0

	.sect	.data
_environ:
	.data4	0
#ifdef ACK
.trpim:	.data2	0
.trppc:	.data4	0
#endif ACK
