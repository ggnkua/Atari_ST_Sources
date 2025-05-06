; a short 8031 assembler example

	include "regdef.asm"

; BINBCD
; Convert 8-bit binary variable in accumulator to 3-digit packed BCD format
; Hundred's place left in variable HUND,
; ten's and one's places in TENONE.
;
HUND	equ	21h
TENONE	equ	22h

BINBCD	mov	b,#100
	div	ab
	mov	HUND,a
	xch	A,B
	div	ab
	
	swap 	a
	add	a,b
	mov	TENONE,a
	ret
;

