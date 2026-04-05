		GLOBL _lmul

; GCC: __mulsi3
		MODULE _lmul

	move.l	d0,d2
	bpl.s	_lmul1
	neg.l	d0
_lmul1:
	eor.l	d1,d2
	movea.l	d2,a0
	tst.l	d1
	bpl.s	_lmul2
	neg.l	d1
_lmul2:
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_lmul6
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_lmul4
	mulu	d1,d0
	move.l	a0,d2
	bpl.s	_lmul3
	neg.l	d0
_lmul3:
	rts

_lmul4:
	mulu	d0,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	_lmul5
	neg.l	d0
_lmul5:
	rts

_lmul6:
	mulu	d1,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	_lmul7
	neg.l	d0
_lmul7:
	rts

		ENDMOD		