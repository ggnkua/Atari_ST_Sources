
; This is a super-mega-fast routine to extract the square root
; of an integer number.
;  
; At the moment the routine calculates with 16 bits.
; To calculate with 32 bits, simply change all instructions to long
; and replace the `move.w #$4000,d2` with `move.l #$40000000,d2`.
;
; This program is based on an article by OTTO PETER, Innsbruck
; and translated into MC68000 assembler by MISSION of COMA.
;
; If you are interested in the development of this algorithm,
; go into a library and search for c`t 1/1990, page 300-306.
; You will find there a nice version of the routine which
; calculates the square root for the 32-bit-IEEE-single-precision-format


ROOT:

;	SETTINGS IN:      D0.w   -   number
;
;		OUT:      D0.w   -   result
;                                -   sign- and zeroflag are valid

movem.w	d1-d3,-(sp)
move.w	#$4000,d2

root_loop:
move.w	d1,d3
add.w	d2,d3

lsr.w	#1,d1
cmp.w	d3,d0
ble.s	boing
sub.w	d3,d0
or.w	d2,d1

boing:
lsr.w	#2,d2
bne.s	root_loop

cmp.w	d1,d0
blt.s	no_round_up
addq.w	#1,d1

no_round_up:
move.w	d1,d0
movem.w	(sp)+,d1-d3
rts

