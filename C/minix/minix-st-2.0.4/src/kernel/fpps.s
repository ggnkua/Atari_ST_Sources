#include <minix/config.h>
#ifdef FPP

#ifdef ACK
! section definition
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif
	.define	__fppsave
	.define __fppsavereg
	.define __fpprestore
	.define __fpprestreg

	.sect	.text
!
! save context in save area 
! arg -> fsave
!
__fppsave:
	move.l	4(a7),a0
	fsave	(a0)		! save state
	rts

__fppsavereg:
	move.l	4(a7),a0
	fmovem.l	fpcr/fpsr/fpiar,(a0)
	add.l	#12,a0
	fmovem.x	fp0-fp7,(a0)
	rts
!
! restore context from save area
! arg -> fsave
!
__fpprestore:
	move.l	4(a7),a0
	frestore	(a0)	! restore state
	rts

__fpprestreg:
	move.l	4(a7),a0
	fmovem.l	(a0),fpcr/fpsr/fpiar
	add.l	#12,a0
	fmovem.x	(a0),fp0-fp7
	rts
#endif
