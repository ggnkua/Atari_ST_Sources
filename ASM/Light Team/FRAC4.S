	move #2,-(sp)
	trap #14
	addq #2,sp
	movea.l d0,a4
	lea (a4),a0
	move #$2000,d0
q0	clr.l (a0)+
	dbf d0,q0
	lea (a4),a0
	movea #401,a1
	movea #-11*164,a3
q1	movea #-17*164,a2
	move #39,d1
q2	move #15,d4
q3	clr d5
	clr d6
	move #20,d3
q4	move d5,d0
	muls d0,d0
	move.l d0,d7
	move d6,d2
	muls d2,d2
	sub.l d2,d7
	asl.l #3,d7
	swap d7
	add a2,d7
	muls d5,d6
	asl.l #4,d6
	swap d6
	add a3,d6
	move d7,d5
	muls d7,d7
	move d6,d0
	muls d0,d0
	add.l d0,d7
	cmpi.l #$20000000,d7
	bhi q5
	dbf d3,q4
q5	andi #1,d3
	asl (a0)
	add d3,(a0)
	adda #$1c,a2
	dbf d4,q3
	addq #2,a0
	dbf d1,q2
	adda #$2d,a3
	subq #1,a1
	move a1,d0
	dbf d0,q1
	move #7,-(sp)
	trap #1
	addq #2,sp
	rts
