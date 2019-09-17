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
	move.w	d0,_mbut
b1:	move.w	_my,d1
	cmp.w	#20,d1
	bgt.w	b3
	move.w	_mx,d0
	pea		b2
	move.l	_sysmouse,-(sp)
	rts
b2:	move.w	#0,d0
	pea		b3
	move.l	_sysbuttn,-(sp)
b3:	move.w	_mbut,d0
	move.l	_sysbuttn,-(sp)
	rts
	
