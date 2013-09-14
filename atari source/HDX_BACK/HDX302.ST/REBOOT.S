* reboot.s
* $Header: reboot.s,v 1.1 86/05/29 12:13:38 dyer Exp $


*+
*  Reboot the ST.
*
*    Synopsis:		reboot()
*			Fake COLD start.
*
*    Discussion:	Must be called from user mode.
*			Never returns; causes the ST to go through
*			the 68000's RESET vector.
*
*-
	.globl	_reboot
_reboot:
	clr.l	-(sp)			; get supervisor mode from GEMDOS
	move.w	#$20,-(sp)
	trap	#1
	clr.l	$420			; clobber `memvalid'
	move.l	4,-(sp)			; indirect-jump through 0x000004
	rts				; (never returns)
