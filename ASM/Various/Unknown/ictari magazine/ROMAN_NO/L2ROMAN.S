;Convert Long Integer to Roman Numerals - Sledge Hammer Method
;ENTRY:	A0 = Roman Numeral String Pointer - to be filled
;	D0 = Long Integer to be converted
;EXIT:	
;USES:	d0-d2/a0

Long_2_Roman
	sub.l	#1000,d0
	bmi.s	.1
	move.b	#'M',(a0)+	;1000's
	bra.s	Long_2_Roman
.1	add.l	#100,d0
	bmi.s	.2
	move.b	#'C',(a0)+
	move.b	#'M',(a0)+	;900?
	bra.s	.3
.2	add.l	#900,d0
.3	sub.l	#500,d0
	bmi.s	.3a
	move.b	#'D',(a0)+	;500's
	bra.s	.4a
.3a	add.l	#100,d0
	bmi.s	.4
	move.b	#'C',(a0)+
	move.b	#'D',(a0)+	;400?
	bra.s	.4a
.4	add.l	#400,d0
.4a	sub.l	#100,d0
	bmi.s	.5
	move.b	#'C',(a0)+	;100's
	bra.s	.4a
.5	add.l	#10,d0
	bmi.s	.6
	move.b	#'X',(a0)+
	move.b	#'C',(a0)+	;90?
	bra.s	.7
.6	add.l	#90,d0
.7	sub.l	#50,d0
	bmi.s	.7a
	move.b	#'L',(a0)+	;50's
	bra.s	.8a
.7a	add.l	#10,d0	
	bmi.s	.8
	move.b	#'X',(a0)+
	move.b	#'L',(a0)+	;40?
	bra.s	.8a
.8	add.l	#40,d0
.8a	sub.l	#10,d0
	bmi.s	.9
	move.b	#'X',(a0)+	;10's
	bra.s	.8a
.9	add.l	#1,d0
	bmi.s	.10
	move.b	#'I',(a0)+
	move.b	#'X',(a0)+	;9?
	bra.s	.11
.10	add.l	#9,d0
.11	sub.l	#5,d0
	bmi.s	.11a
	move.b	#'V',(a0)+	;5's
	bra.s	.12a
.11a	add.l	#1,d0
	bmi.s	.12
	move.b	#'I',(a0)+
	move.b	#'V',(a0)+
	bra.s	.12a
.12	add.l	#4,d0
.12a	sub.l	#1,d0
	bmi.s	.13
	move.b	#'I',(a0)+	;1's
	bra.s	.12a
.13	clr.b	(a0)+
	rts
