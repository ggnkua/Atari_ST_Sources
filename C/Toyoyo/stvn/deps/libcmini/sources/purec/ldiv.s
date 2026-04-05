			GLOBL _ldiv

; GCC: __divsi3
			MODULE _ldiv
			
	move.l	d0,d2
	bpl.s	_ldiv1
	neg.l	d0
_ldiv1:
	eor.l	d1,d2
	movea.l	d2,a1
	tst.l	d1
	bpl.s	_ldiv2
	neg.l	d1
_ldiv2:
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_ldiv6
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_ldiv4
	divu	d1,d0
	swap	d0
	clr.w	d0
	swap	d0
	move.l	a1,d2
	bpl.s	_ldiv3
	neg.l	d0
_ldiv3:
	rts

_ldiv4:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea	d0,a0
	move	d2,d0
	divu	d1,d0
	swap	d0
	move	a0,d0
	swap	d0
	move.l	a1,d2
	bpl.s	_ldiv5
	neg.l	d0
_ldiv5:
	rts

_ldiv6:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move.w	d0,d1
	clr.w	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
_ldiv7:
	sub.l	a0,d1
	bcc.s	_ldiv8
	add.l	a0,d1
_ldiv8:
	addx.l	d0,d0
	addx.l	d1,d1
	dbf	d2,_ldiv7
	not.w	d0
	move.l	a1,d2
	bpl.s	_ldiv9
	neg.l	d0
_ldiv9:
	rts


			ENDMOD