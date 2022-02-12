#
! public labels
	.define	begtext
	.define	begdata
	.define	begbss
#ifndef HEAD_WITHOUT_EXIT
	.define	_exit
#else
	.extern	_exit
#endif /* HEAD_WITHOUT_EXIT */
	.define	_data_org
#ifndef GNUOBJ
	.define	__end
#endif /* GNUOBJ */
#ifdef __ACK__
	.define	EXIT
	.define	.trpim
	.define	.trppc
#endif	/* __ACK__ */
! external references
	.extern	_main
!	.extern	_stackpt
#ifdef __ACK__
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif	/* __ACK__ */

	.sect	.text
begtext:
!	move.l	_stackpt,sp
	jsr	_main
#ifdef __ACK__
EXIT:
#endif	/* __ACK__ */
#ifndef HEAD_WITHOUT_EXIT
_exit:
	bra	_exit		! this will never be executed
#endif /* HEAD_WITHOUT_EXIT */

	.sect	.data
begdata:
	! fs needs to know where build stuffed table
_data_org:
	! 0xDADA is magic number for build
	.data2	0xDADA,0,0,0,0,0,0,0,0,0,0,0
#ifdef __ACK__
.trpim:	.data2	0
.trppc:	.data4	0
#endif	/* __ACK__ */

	.sect	.bss
begbss:
#ifndef GNUOBJ
	.sect	.end		! so we don't need _end.o any more
__end:
#endif /* GNUOBJ */
