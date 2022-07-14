| 
| Low level and interrupt routines for the Unicorn USB driver
|
	.globl _old_mfp_int
	.globl _interrupt_mfp
	.globl _unicorn_int
	.globl _check_flock

	.text

oldSR:  ds.w    1

	dc.l	0x58425241		| XBRA
	dc.l	0x554e4943		| UNIC
_old_mfp_int:
	ds.l	1
_interrupt_mfp:
	lea -64(sp),sp
	movem.l	a0-a7/d0-d7,(sp)
	bsr	_unicorn_int
	movem.l	(sp),a0-a7/d0-d7
	lea 64(sp),sp
	move.l	_old_mfp_int(PC),-(sp)
	rts

| Checks & Sets FLOCK
_check_flock:
	tst.w 0x43e
	bne.w done
	dc.w 0x50f9
	dc.l 0x43e
	move.b #0, D0
	rts
done:
	move.b #0xFF, D0
	rts
