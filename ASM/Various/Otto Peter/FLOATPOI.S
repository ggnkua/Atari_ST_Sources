;*************************************************
;* ROOT-ROUTINE FOR 32-BIT-FLOATINGPOINT-NUMBERS *
;*          coded by Otto Peter, Inbruck         *
;*             published in  C`T 1/90            *
;*************************************************

exp_offset:	equ $7f


domain_error:			;Error if number is negative
movem.l	(a7)+,d1-d4
rts

sq_0:
clr.l	d0
movem.l	(a7)+,d1-d4
rts

sqrt:
movem.l	d1-d4,-(a7)		;Save d1-d4
move.l	d0,d4
bmi.s	domain_error		;Error if number is negative
swap	d4			;MSW of number
and.l	#$7f80,d0		;isolate exponent
beq.s	sq_0			;exponent is 0 => root is 0
and.l	#$007fffff,d0		;isolate mantisse
sub.w	#exp_offset*$80,d4	;exponent in `2^i`-format
bclr	#7,d4			;exponent even?
beq.s	even_exp
add.l	d0,d0			;mantisse * 2
add.l	#$01000000-$00800000,d0	;set hidden-bit

even_exp:
asr.w	#1,d4			;exponent / 2
add.w	#exp_offset*$80,d4	;exponent in offset-format
swap	d4

lsl.l	#7,d0

move.l	#$40000000,d2		;xroot after 1. interation
move.l	#$10000000,d3		;m2 = 2 << (maxbit-1)

loop1_0:
move.l	d0,d1			;xx2 = x

loop1_1:
sub.l	d2,d1			;xx2 -= xroot
lsr.l	#1,d2			;xroot >>= 1
sub.l	d3,d1			;x2 -= m2
bmi.s	dont_set1
move.l	d1,d0			;x = xx2
or.l	d3,d2			;xroot += m2
lsr.l	#2,d3			;m2 >>= 2
bne.s	loop1_1
bra.s	d0_d1_same

dont_set1:
lsr.l	d2,d3			;m2 >>= 2
bne.s	loop1_0			;repeat loop 15 times (bit 22..8)

move.l	d0,d1

d0_d1_same:
sub.l	d2,d1			;xx2 -= xroot
ror.l	#1,d2			;xroot >>= 1 (with carry)
swap 	d2			;turn to new aligment
subq.l	#1,d1			;carry of 0-0x4000: x2 -= m2 (part 1)
bmi.s	dont_set7

or.l	#-$40000000,d1		;0-0x4000: x2 -= m2 (part 2)
move.l	d1,d0
or.w	#$4000,d2

dont_set7:
swap	d0			;turn x to new aligment

move.w	#$1000,d3		;m2 - bit 16..31 = 0

loop2_0:
move.l	d0,d1			;xx2 = x

loop2_1:
sub.l	d2,d1			;xx2 = xroot
lsr.l	#1,d2			;xroot >>= 1
sub.l	d3,d1
bmi.s	dont_set2

move.l	d1,d0			;x = xx2
or.l	d3,d2			;xroot += m2
lsr.w	#2,d3			;m2 >>= 2
bne.s	loop2_1

bra.s	finish

dont_set2:
lsr.w	#2,d3			;m2 >>= 2
bne.s	loop2_0			;repeat loop 7 times (n=6..0)

finish:
sub.l	d2,d0			;round root?
bls.s	no_inc
addq.l	#1,d2			;round up!

no_inc:
bclr	#23,d2			;clear hidden bit
or.l	d4,d2			;combine exponent and mantisse
move.l	d2,d0			;result
movem.l	(a7)+,d1-d4
rts

