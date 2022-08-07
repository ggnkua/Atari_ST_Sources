

#define sp A7
#define a7 A7
#define a6 A6
#define a5 A5
#define a4 A4
#define a3 A3
#define a2 A2
#define a1 A1
#define a0 A0
#define d7 D7
#define d6 D6
#define d5 D5
#define d4 D4
#define d3 D3
#define d2 D2
#define d1 D1
#define d0 D0

extern y_xor_line();
extern on_off_buf[];

#define first_param 4*4
#define wordwidth first_param
#define x1 first_param+2
#define y1 first_param+4
#define x2 first_param+6
#define y2 first_param+8

asm	{
y_xor_line:
	movem.l	d4/d5/d6,-(sp)
/*
*imagept	=:	a0

*rot		=:	d0
*duty_cycle	=:	d1
*delta_x	=:	d2
*delta_y	=:	d3
*incx		=:	d4
*dots		=:	d5
*bytewidth	=:	d6
*/

	move.w	wordwidth(sp),d6
	asl.w	#1,d6			;words to bytes
/*d6 has wordwidth*/

	move.w	x1(sp),d1
	lea	on_off_buf(a4),a0
/*	move.l	#_on_off_buf,a0*/
	move.w	d1,d4
	asr.w	#4,d4
	asl.w	#1,d4
	ext.l	d4
	move.w	y1(sp),d5
	move.w	d5,d0
	muls	d6,d0
	add.l	d4,d0
	lea	0(a0,d0),a0
/*d1 has x1,	d5 has y1,	a0 has imagept*/

	move.w	d1,d4
	and.w	#15,d4
	move.w	#0x8000,d0
	lsr.w	d4,d0
/*d0 has rot*/

	move.w	#1,d4
/*d4 has incx*/

	move.w	x2(sp),d2
	sub.w	d1,d2
	bpl	incx_plus
	neg.w	d2
	neg.w	d4
incx_plus:
/*d2 has delta_x, d4 has incx*/

	move.w	y2(sp),d3
	sub.w	d5,d3
	bpl	incy_plus
	neg.w	d3
	neg.w	d6	
incy_plus:
/*d3 has delta_y, d6 has bytewidth*/

	move.w	d2,d1
	move.w  d3,d5
	asr.w	#1,d5
	sub.w	d5,d1
/*d1 has duty_cycle*/

	move.w	d3,d5
/*d5 has dots*/

	eor.w	d0,(a0)
	tst.w	d4
	bmi	leftwards

rightwards:
	tst.w	d1
	bmi	right_vpart
righthloop:
	lsr.w	#1,d0
	bne	rl0
	addq	#2,a0
	move.w	#0x8000,d0
rl0:	sub.w	d3,d1
	bgt	righthloop

right_vpart:
	lea	0(a0,d6),a0
	eor.w	d0,(a0)
	add.w	d2,d1
	subq	#1,d5
	bgt	rightwards
	movem.l	(sp)+,d4/d5/d6
	rts




leftwards:
	tst.w	d1
	bmi	left_vpart
lefthloop:
	lsl.w	#1,d0
	bne	ll0
	subq	#2,a0
	move.w	#0x0001,d0
ll0:	sub.w	d3,d1
	bgt	lefthloop

left_vpart:
	lea	0(a0,d6),a0
	eor.w	d0,(a0)
	add.w	d2,d1
	subq	#1,d5
	bgt	leftwards
	movem.l	(sp)+,d4/d5/d6
	rts
}


