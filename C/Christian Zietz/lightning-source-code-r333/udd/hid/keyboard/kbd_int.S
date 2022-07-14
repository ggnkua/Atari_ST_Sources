|
| Low level and interrupt routines for the USB keyboard driver
|

#ifdef TOSONLY
	.globl _old_ikbd_int
	.globl _interrupt_ikbd
	.globl _kbd_int
	.globl _set_old_int_lvl

	.text

	dc.l	0x58425241		| XBRA
	dc.l	0x554b4244		| UKBD
_old_ikbd_int:
	ds.l	1
_interrupt_ikbd:
	tas	lock
	bne	skip
	movem.l	a0-a7/d0-d7,registersave
	lea	ourSP,a7
	bsr	_kbd_int
	movem.l	registersave,a0-a7/d0-d7
	clr.w	lock
skip:	move.l	_old_ikbd_int(PC),-(sp)
	rts
#endif

	.globl _send_data
	.globl _fake_hwint

_send_data:
	lea	-60(sp),sp
	movem.l	d0-a6,(sp)
	move.l	64(sp),a2
	move.l	68(sp),a0
	move.l	72(sp),d0
	suba.l	a5,a5 		| needed for TOS 1.x
	jsr	(a2)
	movem.l	(sp),d0-a6
	lea	60(sp),sp
	rts

_fake_hwint:
	tst.w	0x59e.w
	beq	shortframe
	move.w	#0x118,-(sp)
shortframe:
	pea	retaddr(pc)
	move	sr,d0
	move.w	d0,-(sp)
	move.l	0x118,a0
	jmp	(a0)
retaddr:
	rts

	.bss
lock:	ds.w 1
	ds.l 1024
ourSP:
registersave:
	ds.l 8+8
	.end
