.define .csb
.sect .text
.sect .rom
.sect .data
.sect .bss

	.sect .text
.csb:
	move.l	(sp)+,a0	! case descriptor
	move	(sp)+,d0	! index
	move.l	(a0)+,a1	! default jump address
	move	(a0)+,d1	! # entries
	dbra	d1,3f
1:
	move.l	a1,d1		! default jump address
	beq	4f
	jmp	(a1)
2:
	add.l	#4,a0		! skip jump address
3:	cmp	(a0)+,d0
	dbeq	d1,2b
	bne	1b		! case selector not found
	move.l	(a0)+,a1	! get jump address
	jmp	(a1)

ECASE	= 20
4:	move.w	#ECASE,-(sp)
	jmp	.fat

