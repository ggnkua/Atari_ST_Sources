
COLBIT0	equ	$018
COLBIT1	equ	$01A
COLBIT2	equ	$01C
COLBIT3	equ	$01E
LSTLIN	equ	$020
LNMASK	equ	$022
WMODE	equ	$024
X1		equ	$026
Y1		equ	$028
X2		equ	$02A
Y2	 	equ	$02C
PATPTR 	equ	$02E
PATMSK	equ	$032
MFILL	equ	$034

;------------------------------------------
;
; _drawframe(X,Y,W,Z)
; WORD	X1 		4(sp)
; WORD	Y1 		6(sp)
; WORD	W1 		8(sp)
; WORD	Z1 		a(sp)
; draw a frame at the points (X,Y) and (W,Z)


		.globl	_drawframe

_drawframe:

		dc.w	$A000
		movea.l	a0,	a3
		movea.l	a1,	a4
		movea.l	a2,	a5
		move.w 	4(sp), d3
		move.w 	6(sp), d4
		move.w 	8(sp), d5
		move.w 	$a(sp), d6
		cmp.w	d3,	d5 
		bge.w	COMP
		move.w	d3,	d7
		move.w	d5,	d3
		move.w	d7,	d5
		cmp.w	d4,	d6 
COMP:	bge.w	DRAW
		move.w	d4,	d7
		move.w	d6,	d4
		move.w	d7,	d6

DRAW:	move.l	a3,	d0
		move.l	#$00010001, COLBIT0(a0)		; set COLBIT variables
;move.w	#1, COLBIT1(a0)
		move.l	#$00010001, COLBIT2(a0) 	
;move.w	#1, COLBIT3(a0)
		move.w	#1,	LSTLIN(a0)			; draw last pixel of line
		move.l	#$FFFF0002, LNMASK(a0)	; line style mask
;move.w	#2, WMODE(a0)		 writing mode (replace)
		move.w 	d3, X1(a0)			; (x1,y1) and (x2, y2) into
		move.w 	d4, Y1(a0)			; appropriate variables
		move.w 	d3, X2(a0)
		move.w 	d6, Y2(a0)
		dc.w	$A003				; Arbitrary Line


		movea.l	a4,	a1
		movea.l	a5,	a2
		move.w 	d5, X2(a3)
		move.l	#pat, PATPTR(a3)	; pattern pointer
		clr.l 	PATMSK(a3)			; Pattern length n-1=0
;clr.w 	MFILL(a0)			 Multiple Plane fill off
		dc.w	$A004				; Arbitrary Line


		move.l	a3,	d0
		movea.l	a4,	a1
		movea.l	a5,	a2
		move.w 	d5, X1(a3)			; (x1,y1) and (x2, y2) into
		move.w 	d4, Y1(a3)			; appropriate variables
		move.w 	d5, X2(a3)
		move.w 	d6, Y2(a3)
		dc.w	$A003				; Arbitrary Line

		movea.l	a4,	a1
		movea.l	a5,	a2
		move.w 	d3, X1(a3)
		move.w 	d6, Y1(a3)
		dc.w	$A004				; Arbitrary Line
		rts

.data
pat:	dc.w	$FFFF				; Pattern for line.


