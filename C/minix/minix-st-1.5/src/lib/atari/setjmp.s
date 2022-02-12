#
	.define	_setjmp
	.define	_longjmp
#ifdef ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif ACK

	.sect	.text
_setjmp:
	move.l	4(sp),a0
	move.l	(sp),(a0)
	movem.l	d2-d7/a2-a7,4(a0)
	clr.l	d0
	rts

_longjmp:
	move.l	4(sp),a0
	move.w	8(sp),d0
	bne	L1
	move.l	#1,d0		! may not be 0
L1:
	movem.l	4(a0),d2-d7/a2-a7
	move.l	(a0),(sp)
	rts
