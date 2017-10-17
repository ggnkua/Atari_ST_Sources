	text
*****************************************************************************************
*BINTODEC	Converts a binary number passed in D0 into a decimal ascii string	*
*	whose address is passed here in A0. The ASCII string is terminated with a zero	*
*	BYTE.										*
*											*
*	 D0 = Number to convert							*
*	 A0 = Pointer to string to contain resulting ASCII decimal string		*
*											*
*	 D1 = Lenght of the resulting string						*
*											*
*****************************************************************************************
btdr		reg	d0/a0-1	
bintodec:	movem.l	btdr,-(sp)	
		lea	.bindecsum,a1	;ASCII sum buffer
		move.b	#48,(a1)	;In case the resoult is 0
.bindec0:	moveq	#0,d1		;Clear Work reg
.bindec1:	sub.l	#10000000,d0
		bcs.s	.bindec2
		add.l	#1000000,d1
		bra.s	.bindec1
.bindec2:	add.l	#10000000,d0
		beq	.bindec15
.bindec3:	sub.l	#1000000,d0
		bcs.s	.bindec4
		add.l	#100000,d1
		bra.s	.bindec3
.bindec4:	add.l	#1000000,d0
		beq.s	.bindec15
.bindec5:	sub.l	#100000,d0	
		bcs.s	.bindec6
		add.l	#10000,d1
		bra.s	.bindec5
.bindec6:	add.l	#100000,d0
		beq.s	.bindec15
.bindec7:	sub.l	#10000,d0
		bcs.s	.bindec8
		add.l	#1000,d1
		bra.s	.bindec7
.bindec8:	add.l	#10000,d0
		beq.s	.bindec15
.bindec9:	sub.l	#1000,d0
		bcs.s	.bindec10
		add.l	#100,d1
		bra.s	.bindec9
.bindec10:	add.l	#1000,d0
		beq.s	.bindec15
.bindec11:	sub.l	#100,d0
		bcs.s	.bindec12
		add.l	#10,d1
		bra.s	.bindec11
.bindec12:	add.l	#100,d0
		beq.s	.bindec15
.bindec13:	sub.l	#10,d0
		bcs.s	.bindec14
		addq.l	#1,d1
		bra.s	.bindec13
.bindec14:	add.l	#10,d0
.bindec15:	add.b	#$30,d0
		move.b	d0,(a1)+
		move.l	d1,d0
		bne	.bindec0
		moveq	#0,d1
.bindec16:	addq.w	#1,d1
		move.b	-(a1),(a0)+
		bpl.s	.bindec16
.bindec17:	clr.b	-1(a0)	;Terminate
		move.l	a0,d1
		sub.l	4(sp),d1
		movem.l	(sp)+,btdr
		rts
		dc.w	255	;Do not remove this..
.bindecsum:	ds.l	4	;..or this!
