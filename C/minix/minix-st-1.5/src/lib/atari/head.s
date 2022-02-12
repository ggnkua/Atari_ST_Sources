#
! public labels
	.define	begtext
	.define	begdata
	.define	begbss
	.define	_exit
	.define	_data_org
#ifdef ACK
	.define	EXIT
	.define	.trpim
	.define	.trppc
#endif ACK
! external references
	.extern	_main
	.extern	_stackpt
#ifdef ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif ACK

	.sect	.text
begtext:
	move.l	_stackpt,sp
	jsr	_main
#ifdef ACK
EXIT:
#endif ACK
_exit:
	bra	_exit		! this will never be executed

	.sect	.data
begdata:
	! fs needs to know where build stuffed table
_data_org:
	! 0xDADA is magic number for build
	.data2	0xDADA,0,0,0,0,0,0,0
#ifdef ACK
.trpim:	.data2	0
.trppc:	.data4	0
#endif ACK

	.sect	.bss
begbss:
