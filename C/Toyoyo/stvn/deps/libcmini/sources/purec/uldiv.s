			GLOBL _uldiv

; GCC: __udivsi3
			MODULE _uldiv
			
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_uldiv2
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_uldiv1
	divu	d1,d0
	swap	d0
	clr.w	d0
	swap	d0
	rts

_uldiv1:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea	d0,a0
	move.w	d2,d0
	divu	d1,d0
	swap	d0
	move.w	a0,d0
	swap	d0
	rts

_uldiv2:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move.w	d0,d1
	clr.w	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
_uldiv3:
	sub.l	a0,d1
	bcc.s	_uldiv4
	add.l	a0,d1
_uldiv4:
	addx.l	d0,d0
	addx.l	d1,d1
	dbf	d2,_uldiv3
	not.w	d0
	rts

			ENDMOD