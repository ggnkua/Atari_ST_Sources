#include <minix/config.h>
#if (SHADOWING == 0)

!
! even though there are a lot of instructions in the 68851, we will 
! try only using those that will also occur in a 68030
!
#ifdef ACK
! section definition
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif
	.define	__pmmu_load_crp
	.define	__pmmu_load_srp
	.define	__pmmu_load_tc
	.define	__pmmu_pflush

	.sect	.text
	
! routines to deal with m68851 PMMU registers
__pmmu_load_crp:
	move.l	4(sp),a0
!	pmove	(a0),crp
	.data2	0xf010
	.data2	0x4c00
	rts
__pmmu_load_srp:
	move.l	4(sp),a0
!	pmove	(a0),srp
	.data2	0xf010
	.data2	0x4800
	rts
__pmmu_load_tc:
	move.l	4(sp),a0
!	pmove	(a0),tc
	.data2	0xf010
	.data2	0x4000
	rts
__pmmu_pflush:
!	pflush	0,#4
!	.data2	0xf000
!	.data2	0x3000
	.data2	0xf000
	.data2	0x2400
	rts
#endif
