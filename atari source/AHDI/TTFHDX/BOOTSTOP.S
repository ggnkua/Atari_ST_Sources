* bootstop.s
* $Header$

*------------------------------------------------------------------------
*									:
*	Stop DMA boot from completing					:
*	Copyright 1986, Atari Corp.					:
*									:
*  When written to a hard disk's boot sector, this code prevents	:
*  the DMA bus from locking up on 20-Nov-1985-derived versions of	:
*  TOS.									:
*									:
*  Modified 18-Feb-1988 by AKP to stop the boot sequence ONLY		:
*  on 11/20 ROMs.							:
*									:
*------------------------------------------------------------------------

* $Log$



*+
*  Stop the boot sequence in its tracks by
*  jamming $100-$20 into D7 and returning.
*  This causes the code in the BIOS routine
*  `dmaboot' to quit early, thinking that it
*  has scanned all eight devices, when in
*  fact it has only (hopefully) touched the
*  first device.
*
*-
	.globl _bootstop
	.globl _bootend

_sysbase = $4f2

_bootstop:
	move.l	_sysbase,a0		; get system header address
	cmp.w	#$0100,2(a0)		; version $0100 is 11/20-derived
	bne.s	dontstop		; if not 11/20, don't stop.
	move.w	#$100-$20,d7
dontstop:
	rts

	dc.b	'$Header$',0
	even

_bootend:
	dc.l	0

