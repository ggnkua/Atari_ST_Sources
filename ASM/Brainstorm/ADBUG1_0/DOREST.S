;finds the RESET handler routine in Adebug and catches the RESET with it

	output	.ro

main:
	move.w	#'MA',d0
	lea	main(pc),a0
.l1:
	move.l	a0,d1
	beq.s	.end
	cmp.w	-(a0),d0
	bne.s	.l1

	cmp.l	#'GICR',2(a0)
	bne.s	.l1

	cmp.l	#'ESET',6(a0)
	bne.s	.l1

	lea	10(a0),a0
	move.l	a0,$42a.w
	move.l	#$31415926,$426.w
	moveq	#-1,d0
	rts
.end:
	moveq	#0,d0
	rts
