xstart	equ -$1800
ystart	equ -$1800
xinc	equ $26
yinc	equ $3e
kimag	equ $a7e
kreal	equ $1c2
kinc	equ $20
	move.l #kreal,d2
q01	move #2,-(sp)
	trap #14
	addq #2,sp
	movea.l d0,a4
	sub #$8000,d0
	movea.l d0,a0
	move #$2000,d1
q02	move.l (a0)+,(a4)+
	dbf d1,q02
	movea.l d0,a4
	lea (a4),a0
	move #$2000,d0
q0	clr.l (a0)+
	dbf d0,q0
	lea (a4),a0
	movea #200,a1
	movea #ystart,a3
q1	movea #xstart,a2
	move #19,d1
q2	move #15,d4
q3	move a2,d5
	move a3,d6
	move d5,d0
	muls d0,d0
	movea.l d0,a6
	move d6,d0
	muls d0,d0
	movea.l d0,a5
	move #14,d3
q4	sub.l a5,a6
	move.l a6,d7
	asl.l #4,d7
	swap d7
	add d2,d7
	muls d5,d6
	asl.l #5,d6
	swap d6
	addi #kimag,d6
	move d7,d5
	muls d7,d7
	move.l d7,a6
	move d6,d0
	muls d0,d0
	move.l d0,a5
	add.l d0,d7
	cmpi.l #$4000000,d7
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
	adda #xinc,a2
	dbf d4,q3
	adda #8,a0
	dbf d1,q2
	adda #yinc,a3
	subq #1,a1
	move a1,d0
	dbf d0,q1
	add #kinc,d2
	bra q01
