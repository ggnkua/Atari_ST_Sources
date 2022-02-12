.define	.strhp
.sect .text
.sect .rom
.sect .data
.sect .bss

	.sect .text
.strhp:
	move.l	(sp)+,a0
	move.l	(sp)+,d0	! heap pointer
	move.l	d0,.reghp
	cmp.l	.limhp,d0
	bmi	1f
	add.l	#0x200,d0
	and.l	#~0x1ff,d0
	move.l	d0,.limhp
	cmp.l	d0,sp
	bls	2f
1:
	jmp	(a0)
2:
EHEAP	= 17
	move.w	#EHEAP,-(sp)
	jsr	.trp
	jmp	(a0)
