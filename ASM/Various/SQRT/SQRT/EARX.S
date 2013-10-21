fast_sqrt:
	moveq		#1,			d2
	ror.l		#2,			d2
	moveq		#$F,		d3
.loop1:
	cmp.l		d2,			d0
	bgt.s		.endloop1
	add.l		d0,			d0
	lsr.l		#1,			d2
	dbf			d3,.loop1
	moveq		#0,			d1
	bra.s		.is_null
.endloop1:
	sub.l		d2,			d0
	move.l		d2,			d1
	lsr.l		#1,			d2
.loop2:
	lsr.l		#1,			d2
	add.l		d2,			d1
	cmp.l		d1,			d0
	bgt.s		.endloop2
	sub.l		d2,			d1
	add.l		d0,			d0
	dbf			d3,.loop2
	bra.s		.end
.endloop2:
	sub.l		d1,			d0
	add.l		d2,			d1
	add.l		d0,			d0
	dbf			d3,.loop2
.end:
	add.l		d1,			d1
	addi.l		#$00008000,	d1
.is_null:
	swap		d1
	move.w		d1,			d0
	rts

