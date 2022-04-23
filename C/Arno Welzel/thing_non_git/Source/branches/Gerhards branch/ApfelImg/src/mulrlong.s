; -------------------------------------------------------------------
; long mul_reallong(long op1, long op2);
; Multipliziert op1 und op2 und gibt die mitteleren 32 Bit des
; 64-Bit-Produktes zurck
; -------------------------------------------------------------------


EXPORT apfel_calc, apfel2_calc
IMPORT maxiter


	TEXT


MACRO mul2_reallong

	muls.l	d1,d1:d0
	
	clr.w	d0
	add.w	d1,d0
	swap	d0
	
ENDM


MODULE mul_reallong

	movem.l	d2-d7,-(sp)
	
	clr.w	d5
	
	tst.l	d0
	bpl.s	no_neg1
	neg.l	d0
	eori.w	#1,d5
no_neg1:
	tst.l	d1
	bpl.s	no_neg2
	neg.l	d1
	eori.w	#1,d5

no_neg2:
	move.w	d5,-(sp)
	
	swap	d0
	move.w	d0,d2
	swap	d0
	
	swap	d1
	move.w	d1,d3
	swap	d1
	
	move.w	d1,d6
	mulu	d0,d6
	
	move.w	d3,d7
	mulu	d2,d7
	
	mulu	d0,d3
	moveq	#0,d4
	move.w	d3,d4
	swap	d4
	moveq	#0,d5
	swap	d3
	move.w	d3,d5
	
	add.l	d4,d6
	addx.l	d5,d7
	
	mulu	d2,d1
	moveq	#0,d4
	move.w	d1,d4
	swap	d4
	moveq	#0,d5
	swap	d1
	move.w	d1,d5
	
	add.l	d4,d6
	addx.l	d5,d7
	
	move.w	d7,d6
	swap	d6
	
	tst.w	(sp)+
	beq.s	no_neg3
	neg.l	d6

no_neg3:
	move.l	d6,d0
	
	movem.l	(sp)+,d2-d7
	rts
	
ENDMOD


MODULE apfel_calc
	; d2: ax
	; d3: ay
	; d4: cx
	; d5: cy
	; d6: xx - yy
	; d7: tiefe
	
	movem.l d3-d7,-(sp)
	
	move.l	d0,d4
	move.l	d1,d5
	
	; ax = ay = 0
	moveq	#0,d2
	moveq	#0,d3
	; tiefe = 0
	moveq	#0,d7

loop:	
	; if ((xx = ax * ax) + (yy = ay * ay) > (4 * 65536))
	move.l	d2,d0
	move.l	d2,d1
	jsr		mul_reallong
	move.l	d0,d6
	move.l	d3,d0
	move.l	d3,d1
	jsr		mul_reallong
	move.l	d6,d1
	sub.l	d0,d6
	add.l	d1,d0
	cmp.l	#$40000,d0
	bgt.s	exit
	
	; ay = 2 * ax * ay + cy
	move.l	d3,d0
	move.l	d2,d1
	jsr		mul_reallong
	add.l	d0,d0
	add.l	d5,d0
	move.l	d0,d3
	
	; ax = xx - yy + cx
	add.l	d4,d6
	move.l	d6,d2
	
	addq.w	#1,d7
	cmp.w	maxiter,d7
	bne.s	loop

exit:
	move.w	d7,d0

	movem.l	(sp)+,d3-d7
	rts

ENDMOD


MODULE apfel2_calc
	; d2: ax
	; d3: ay
	; d4: cx
	; d5: cy
	; d6: xx - yy
	; d7: tiefe

	mc68020
	
	movem.l d3-d7,-(sp)
	
	move.l	d0,d4
	move.l	d1,d5
	
	; ax = ay = 0
	moveq	#0,d2
	moveq	#0,d3
	; tiefe = 0
	moveq	#0,d7

loop:	
	; if ((xx = ax * ax) + (yy = ay * ay) > (4 * 65536))
	move.l	d2,d0
	move.l	d2,d1
	mul2_reallong
	move.l	d0,d6
	move.l	d3,d0
	move.l	d3,d1
	mul2_reallong
	move.l	d6,d1
	sub.l	d0,d6
	add.l	d1,d0
	cmp.l	#$40000,d0
	bgt.s	exit
	
	; ay = 2 * ax * ay + cy
	move.l	d3,d0
	move.l	d2,d1
	mul2_reallong
	add.l	d0,d0
	add.l	d5,d0
	move.l	d0,d3
	
	; ax = xx - yy + cx
	add.l	d4,d6
	move.l	d6,d2
	
	addq.w	#1,d7
	cmp.w	maxiter,d7
	bne.s	loop

exit:
	move.w	d7,d0

	movem.l	(sp)+,d3-d7
	rts

	mc68000

ENDMOD
