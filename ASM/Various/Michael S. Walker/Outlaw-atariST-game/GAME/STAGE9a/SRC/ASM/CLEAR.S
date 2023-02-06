  		xdef		_ClearScreen

base		equ		8

_ClearScreen:	link		a6,#0
		movem.l		d0-1/a0,-(sp)
		movea.l		base(a6),a0
		move.w		#7999,d0
		clr.l		d1
fill_loop:	move.l		d1,(a0)+        ; strangely, faster than clr
		dbra		d0,fill_loop
		movem.l		(sp)+,d0-1/a0
		unlk		a6
		rts
