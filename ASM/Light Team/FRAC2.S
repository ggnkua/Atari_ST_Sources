xinc	equ $e0
yinc	equ $160
xstart	equ -$85f3c00
ystart	equ -$2ba4600
	move #2,-(sp)
	trap #14
	addq #2,sp
	movea.l d0,a0
	lea (a0),a1
	move #$2000,d0
q0	clr.l (a1)+
	dbf d0,q0
	movea #200,a1
	movea.l #ystart,a3
q1	movea.l #xstart,a2
	movea #20,a4
q2	move #15,d4
q3	clr.l d5
	clr.l d6
	lea.l $0,a5
	lea.l $0,a6
	move #100,d3
q4	sub.l a5,a6
	move.l a6,d7
	add.l a2,d7
	move.l d5,d1
	move.l d6,d2
	bsr mlts
	move.l d2,d6
	asl.l #1,d6
	add.l a3,d6
	move.l d7,d5
	move.l d7,d1
	move.l d7,d2
	bsr mlts
	move.l d2,d7
	move.l d7,a6
	move.l d6,d0
	move.l d0,d1
	move.l d0,d2
	bsr mlts
	move.l d2,d0
	move.l d0,a5
	add.l d0,d7
	cmpi.l #$20000000,d7
	bhi q5
	dbf d3,q4
q5	move #3,d7
q52	move d3,d0
	andi #1,d0
	asl #1,d7
	asl 0(a0,d7)
	add d0,0(a0,d7)
	lsr #1,d7
	lsr #1,d3
	dbf d7,q52
	adda.l #xinc,a2
	dbf d4,q3
	adda #8,a0
	subq #1,a4
	move a4,d0
	dbf d0,q2
	adda.l #yinc,a3
	subq #1,a1
	move a1,d0
	dbf d0,q1
	move #7,-(sp)
	trap #1
	addq #2,sp
	rts
mlts
	movem.l d3-d7,-(sp)
	move.l d1,d6
	move.l d2,d7
	move.l d1,d3
	move.l d1,d4
	swap d4
	move.l d2,d5
	swap d5
	mulu d2,d1
	mulu d4,d2
	mulu d5,d3
	mulu d5,d4
	swap d1
	add d2,d1
	clr.l d5
	addx.l d5,d4
	add d3,d1
	addx.l d5,d4
	swap d1
	clr d2
	swap d2
	clr d3
	swap d3
	add.l d3,d2
	add.l d4,d2
	tst.l d7
	bpl.s chkd6
	sub.l d6,d2
chkd6	tst.l d6
	bpl.s done
	sub.l d7,d2
done	asl.l #5,d2
	swap d1
	rol #5,d1
	andi #$1f,d1
	add d1,d2
	movem.l (sp)+,d3-d7
	rts
