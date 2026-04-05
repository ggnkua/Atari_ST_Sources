			GLOBL _ulmod

; GCC: __umodsi3
			MODULE _ulmod
			
			
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_ulmod2
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_ulmod1
	divu	d1,d0
	clr.w	d0
	swap	d0
	rts

_ulmod1:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	move.w	d2,d0
	divu	d1,d0
	clr.w	d0
	swap	d0
	rts

_ulmod2:
	movea.l	d1,a0
	move.l	d0,d1
	clr.w	d0
	swap	d0
	swap	d1
	clr.w	d1
	moveq	#15,d2
	add.l	d1,d1
	addx.l	d0,d0
_ulmod3:
	sub.l	a0,d0
	bcc.s	_ulmod4
	add.l	a0,d0
_ulmod4:
	addx.l	d1,d1
	addx.l	d0,d0
	dbf	d2,_ulmod3
	roxr.l	#1,d0
	rts

			ENDMOD
