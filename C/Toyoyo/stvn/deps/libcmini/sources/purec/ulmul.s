		GLOBL _ulmul

; GCC: __mulsi3
		MODULE _ulmul

	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	_ulmul2
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	_ulmul1
	mulu	d1,d0
	rts

_ulmul1:
	mulu	d0,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	rts

_ulmul2:
	mulu	d1,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	rts

		ENDMOD
