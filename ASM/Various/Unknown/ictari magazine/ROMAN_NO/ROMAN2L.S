;Convert Roman to Long Integer - Sledge Hammer Method
;ENTRY:	A0 = Pointer to Roman Numeral String IN CAPITALS
;EXIT:	D0 = Number if succesful, -1 if not
;USES:	d0-d1/a0

Roman_2_Long
	clr.b	-(sp)		;end of string
.in	tst.b	(a0)
	beq.s	.I
	move.b	(a0)+,-(sp)	;deal in reverse order
	bra.s	.in
.I	move.b	(sp)+,d1
	cmp.b	#'I',d1
	bne.s	.V1
	addq.l	#1,d0
	bra.s	.I
.V	move.b	(sp)+,d1
.V1	cmp.b	#'V',d1
	bne.s	.Ineg1
	addq.l	#5,d0
	bra.s	.V
.Ineg	move.b	(sp)+,d1
.Ineg1	cmp.b	#'I',d1
	bne.s	.X1
	subq.l	#1,d0
.X	move.b	(sp)+,d1
.X1	cmp.b	#'X',d1
	bne.s	.Ineg3
	add.l	#10,d0
	bra.s	.X
.Ineg2	move.b	(sp)+,d1
.Ineg3	cmp.b	#'I',d1
	bne.s	.X3
	subq.l	#1,d0
.X2	move.b	(sp)+,d1
.X3	cmp.b	#'X',d1
	bne.s	.L1
	add.l	#10,d0
	bra.s	.X2
.Lz	move.b	(sp)+,d1
.L1	cmp.b	#'L',d1
	bne.s	.Xneg1
	add.l	#50,d0
	bra.s	.Lz
.Xneg	move.b	(sp)+,d1
.Xneg1	cmp.b	#'X',d1
	bne.s	.C1
	sub.l	#10,d0
.C	move.b	(sp)+,d1
.C1	cmp.b	#'C',d1
	bne.s	.Xneg3
	add.l	#100,d0
	bra.s	.C
.Xneg2	move.b	(sp)+,d1
.Xneg3	cmp.b	#'X',d1
	bne.s	.C3
	sub.l	#10,d0
.C2	move.b	(sp)+,d1
.C3	cmp.b	#'C',d1
	bne.s	.D1
	add.l	#100,d0
	bra.s	.C2
.D	move.b	(sp)+,d1
.D1	cmp.b	#'D',d1
	bne.s	.Cneg1
	add.l	#500,d0
	bra.s	.D
.Cneg	move.b	(sp)+,d1
.Cneg1	cmp.b	#'C',d1
	bne.s	.M1
	sub.l	#100,d0
.M	move.b	(sp)+,d1
.M1	cmp.b	#'M',d1
	bne.s	.Cneg3
	add.l	#1000,d0
	bra.s	.M
.Cneg2	move.b	(sp)+,d1
.Cneg3	cmp.b	#'C',d1
	bne.s	.M3		;extra M's
	sub.l	#100,d0
.M2	move.b	(sp)+,d1
.M3	cmp.b	#'M',d1
	bne.s	.end	;no more possibilities
	add.l	#1000,d0
	bra.s	.M2
.end	tst.b	d1
	beq.s	.ret
	moveq.l	#-1,d0
.ret	rts

	