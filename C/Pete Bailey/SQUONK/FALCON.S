*=========================================================================
* Mouse movement and button trap routines
*=========================================================================
*
* Movements...
*
	.text
	.globl	_mousetrap
_mousetrap:
	move.w	d0,_mx
	move.w	d1,_my
	cmp.w	#20,d1
	ble.s	m6
m5:	move.l	_sysmouse,-(sp)
m6:	rts
*
* Buttons...
*
	.globl	_buttntrap
_buttntrap:
	pea		b1
	move.l	_sysbuttn,-(sp)
	rts
b1:	move.w	_my,d1
	cmp.w	#20,d1
	bgt.w	b9
	move.w	_mx,d0
	move.l	_sysmouse,-(sp)
b9:	rts
