


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

#define first_param 3*4
#define wordwidth first_param
#define width 	first_param+2
#define height  first_param+4

extern on_off();
extern on_off_buf[];


asm {
on_off:
	movem.l	d4/d5,-(sp)

/*
*imagept	=:	a0
*linept		=:	a1

*rot		=:	d2
*j		=:	d3
*height		=:	d4
*bytewidth	=:	d5
*/

	lea	on_off_buf(a4),a0
/*	move.l	#_on_off_buf,a0 */
	move.w	height(sp),d4

	move.w	wordwidth(sp),d5
	asl.w	#1,d5			;convert words to bytes
	bra	end_height_loop
height_loop:
	move.l	a0,a1
	move.w	width(sp),d3
start_off:
	move.w	(a1)+,d0
	bne	start_ofa
	sub.w	#16,d3
	ble	next_line
	bra 	start_off
start_ofa:
	subq	#2,a1		;go one past
	move.w	#0x8000,d2	
off_bits:	
	move.w	d0,d1
	and.w	d2,d1
	bne	skip_first_on
	subq	#1,d3
	ble	next_line
	lsr.w	#1,d2
	bra	off_bits
skip_first_on:
	subq	#1,d3
	ble	next_line
	lsr.w	#1,d2
start_on:
	move.w	d2,d1
	bne	start_ona
	addq	#2,a1
	bra	fill_word
start_ona:
	and.w	d0,d1
	bne	end_in_word
	or.w	d2,(a1)
	subq	#1,d3
	ble	next_line
	lsr.w	#1,d2
	bra	start_on
fill_word:
	move.w	#0xffff,d1
fw_a:
	move.w	(a1),d0
	bne	fw_z
	move.w	d1,(a1)+
	sub.w	#16,d3
	ble	next_line
	bra	fw_a
fw_z:
	move.w	#0x8000,d2
end_in_word:
	move.w	d0,d1
	and.w	d2,d1
	beq	end_inworda
look_last_bits:
	subq	#1,d3
	ble	next_line
	lsr.w	#1,d2
	bne	llbitsa
	addq	#2,a1
	bra	start_off
llbitsa:
	move.w	d0,d1
	and.w	d2,d1
	bne	skip_first_on
	bra	look_last_bits
end_inworda:
	or.w	d2,(a1)
	subq	#1,d3
	ble	next_line
	lsr.w	#1,d2
	bra	end_in_word
next_line:
	lea	0(a0,d5),a0
end_height_loop:
	dbf	d4,height_loop

on_off_return:
	movem.l	(sp)+,d4/d5
	rts
}

