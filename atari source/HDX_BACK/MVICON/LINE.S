
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
; _vertline(X1,Y1,X2,Y2)
; WORD	X1 		4(sp)
; WORD	Y1 		6(sp)
; WORD	X2 		8(sp)
; WORD	Y2 		a(sp)
;
; draw a solid vertical line form (X1,Y1) to (X2,Y2)


		.globl	_vertline

_vertline:

		dc.w 	$A000				; Make line a Init call
		move.w	#1, COLBIT0(a0)		; set COLBIT variables
		move.w	#1, COLBIT1(a0)
		move.w	#1, COLBIT2(a0)
		move.w	#1, COLBIT3(a0)
		move.w	#0, LSTLIN(a0)		; draw last pixel of line
		move.w	#$FFFF, LNMASK(a0)	; line style mask
		move.w	#0, WMODE(a0)		; writing mode (replace)
		move.w 	4(sp), X1(a0)			; (x1,y1) and (x2, y2) into
		move.w 	6(sp), Y1(a0)			; appropriate variables
		move.w 	8(sp), X2(a0)
		move.w 	$a(sp), Y2(a0)
		dc.w	$A003				; Arbitrary Line
		rts


;------------------------------------------
;
; _horiline(X1,Y1,X2)
; WORD	X1 		4(sp)
; WORD	Y1 		6(sp)
; WORD	X2 		8(sp)
;
; draw a solid horizontal line form (X1,Y1) to (X2,Y1)

		.globl	_horiline

_horiline:

		dc.w 	$A000				; Make line a Init call
		move.w	#1, COLBIT0(a0)		; set COLBIT variables
		move.w	#1, COLBIT1(a0)
		move.w	#1, COLBIT2(a0)
		move.w	#1, COLBIT3(a0)
		move.w	#0, WMODE(a0)		; writing mode (replace)
		move.w 	4(sp), X1(a0)		; (x1,y1) and (x2, y2) into
		move.w 	6(sp), Y1(a0)		; appropriate variables
		move.w 	8(sp), X2(a0)
		move.l	#pat, PATPTR(a0)	; pattern pointer
		move.w 	#0,PATMSK(a0)		; Pattern length n-1=0
		move.w 	#0,MFILL(a0)		; Multiple Plane fill off
		dc.w	$A004				; Arbitrary Line
		rts

.data
pat: 	dc.w	$F0F0				; Pattern for line.



