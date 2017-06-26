	COMMENT	HEAD=%111

Divu_LongLong:	MACRO	long,resLong,tempLong,tempLong2
		cmp.l	\1,\2
		blt.s	\@is_null
		moveq	#-1,\3
		moveq	#0,\4
\@loop1:	addq.w	#1,\3
		add.l	\1,\1
		cmp.l	\1,\2
		bhi.s	\@loop1
\@loop2:	lsr.l	#1,\1
		sub.l	\1,\2
		bmi.s	\@skip_set
		bset	\3,\4
\@skip_set:	dbra	\3,\@loop2
		bra.s	\@end
\@is_null:	moveq	#0,\4
\@end:		move.l	\4,\2
		ENDM

	lea	divisor_buf+2*4,a0
	lea	divident_buf+2*4,a1
	moveq	#$00000003,d1
	moveq	#$00000000,d0
	move.l	d0,-(a0)
	move.l	d1,-(a0)
	moveq	#$00000000,d1
	moveq	#$00000004,d0
	move.l	d0,-(a1)
	move.l	d1,-(a1)
	bsr	DIVU_BIG

	clr.w	-(sp)
	trap	#1

* INPUT: a0: divisor address
*        a1: divident address
DIVU_BIG:
	addq	#2*4,a0
	addq	#2*4,a1
	lea	.div1_buf+2*4(pc),a2
	lea	.div2_buf+2*4(pc),a3
	move.w	#2*32+1,d0
	moveq	#0,d2
	
.divide_loop:

	movea.l	a1,a4
	movea.l	a2,a5
	lea	.remainder_buf+2*4(pc),a6
	roxl.l	#1,d2

	REPT	2
	move.l	-(a4),d2
	roxl.l	#1,d2
	move.l	d2,(a4)
	ENDR

	REPT	2
	move.l	-(a5),d2
	move.l	d2,-(a6)
	roxl.l	#1,d2
	move.l	d2,(a5)
	ENDR

	subq.w	#1,d0
	beq.s	.exit

	movea.l	a0,a4
	movea.l	a2,a5
	movea.l	a3,a6

	REPT	2
	move.l	-(a5),-4(a6)
	subx.l	-(a4),-(a6)
	ENDR

	bcs.s	.divide_loop
	moveq	#$ffffffff,d2
	exg.l	a2,a3
	bra.s	.divide_loop
.exit:
	rts

.div1_buf:
	DS.L	2
.div2_buf:
	DS.L	2
.remainder_buf:
	DS.L	2

	BSS

divisor_buf:
	DS.L	2
divident_buf:
	DS.L	2