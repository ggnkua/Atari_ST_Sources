			GLOBL _lmod

; GCC: __modsi3
			MODULE _lmod
			
	movea.l	d0,a1
	move.l	d0,d2
	bpl.s	_lmod1
	neg.l	d0
_lmod1:
	tst.l	d1
	bpl.s	_lmod2
	neg.l	d1
_lmod2:
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_lmod6
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_lmod4
	divu	d1,d0
	clr.w	d0
	swap	d0
	move.l	a1,d2
	bpl.s	_lmod3
	neg.l	d0
_lmod3:
	rts

_lmod4:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	move.w	d2,d0
	divu	d1,d0
	clr.w	d0
	swap	d0
	move.l	a1,d2
	bpl.s	_lmod5
	neg.l	d0
_lmod5:
	rts

_lmod6:
	movea.l	d1,a0
	move.l	d0,d1
	clr.w	d0
	swap	d0
	swap	d1
	clr.w	d1
	moveq	#15,d2
	add.l	d1,d1
	addx.l	d0,d0
_lmod7:
	sub.l	a0,d0
	bcc.s	_lmod8
	add.l	a0,d0
_lmod8:
	addx.l	d1,d1
	addx.l	d0,d0
	dbf	d2,_lmod7
	roxr.l	#1,d0
	move.l	a1,d2
	bpl.s	_lmod9
	neg.l	d0
_lmod9:
	rts
			
			ENDMOD
