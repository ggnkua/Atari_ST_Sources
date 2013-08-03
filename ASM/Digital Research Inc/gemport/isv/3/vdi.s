	.text

	.globl	_gsx1
	.globl	_gsx2
	.globl	_iioff
	.globl	_iooff
	.globl	_pioff
	.globl	_pooff
	.globl	_vdi

	.xdef	_contrl

_vdi:
_gsx1:
_gsx2:
	move.l	#_contrl, pblock
	move.l	#pblock, d1
	move.l	#115, d0
	trap	#2
	rts

	.bss

pblock:	.ds.l	1
_iioff:	.ds.l	1
_pioff:	.ds.l	1
_iooff:	.ds.l	1
_pooff:	.ds.l	1


	end
