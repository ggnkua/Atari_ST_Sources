	lea	$10000,a0
	bsr	relocate

	jmp	$10000
relocate
	move.l	2(a0),d0
	add.l	6(a0),d0
	add.l	14(a0),d0
	adda.l	#$1c,a0
	movea.l	a0,a1
	movea.l	a1,a2
	move.l	#$10000,d1
	addi.w	#$1c,d1
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	clr.l	d0
l002a	move.b	(a1)+,d0
	beq	l002c
	cmp.b	#1,d0
	beq	l002b
	adda.l	d0,a2
	add.l	d1,(a2)
	bra	l002a
l002b	adda.l	#$fe,a2
	bra	l002a
l002c	rts
