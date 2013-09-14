
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
; _drawicon(X,Y)
; WORD	X1 		4(sp)
; WORD	Y1 		6(sp)
; draw a icon in the point of (X,Y)


		.globl	_drawicon

_drawicon:

	dc.w 	$A000				; Make line a Init call
	move.l	a0,	a3
	move.l	a1,	a4
	move.l	a2,	a5
	move.w 	4(sp), d3
	move.w 	6(sp), d4
	move.w 	d4, d5
	move.w	d3,	d6
	addi.w 	#40, d5 
	addi.w 	#20, d6 
	jsr		_vhline
	move.w 	d4, d5
	move.w	d3,	d6
	subi.w	#20, d3
	addi.w 	#40, d4 
	addi.w 	#50, d5 
	jsr		_vhline
	move.w 	4(sp), d3
	move.w 	6(sp), d4
	move.w 	d4, d5
	move.w	d3,	d6
	addi.w 	#40, d3 
	addi.w 	#50, d4 
	addi.w 	#40, d5 
	subi.w 	#20, d6 
	jsr		_vhlineb
	move.w 	4(sp), d3
	move.w 	6(sp), d4
	move.w 	d4, d5
	move.w	d3,	d6
	addi.w 	#20, d3 
	addi.w 	#40, d4 
	addi.w 	#40, d6 
	jsr		_vhliner
	rts

;------------------------------------------
;
; _vhline(X1,Y1,X2,Y2, X3)
; WORD	X1 		d3
; WORD	Y1		d4 		
; WORD	X2		d3 	
; WORD	Y2		d5 
; WORD	X3		d6
;
; draw a solid vertical line form (X1,Y1) to (X2,Y2)
; draw a solid horizontal line form (X1,Y1) to (X3,Y1)


		.globl	_vhline

_vhline:

		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w	#1, COLBIT0(a0)		; set COLBIT variables
		move.w	#1, COLBIT1(a0)
		move.w	#1, COLBIT2(a0)
		move.w	#1, COLBIT3(a0)
		move.w	#0, LSTLIN(a0)		; draw last pixel of line
		move.w	#$FFFF, LNMASK(a0)	; line style mask
		move.w	#2, WMODE(a0)		; writing mode (replace)
		move.w 	d3, X1(a0)			; (x1,y1) and (x2, y2) into
		move.w 	d4, Y1(a0)			; appropriate variables
		move.w 	d3, X2(a0)
		move.w 	d5, Y2(a0)
		dc.w	$A003				; Arbitrary Line


		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w 	d6, X2(a0)
		move.l	#pat, PATPTR(a0)	; pattern pointer
		move.w 	#0,PATMSK(a0)		; Pattern length n-1=0
		move.w 	#0,MFILL(a0)		; Multiple Plane fill off
		dc.w	$A004				; Arbitrary Line
		rts

		.globl	_vhliner

_vhliner:

		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w	#1, COLBIT0(a0)		; set COLBIT variables
		move.w	#1, COLBIT1(a0)
		move.w	#1, COLBIT2(a0)
		move.w	#1, COLBIT3(a0)
		move.w	#0, LSTLIN(a0)		; draw last pixel of line
		move.w	#$FFFF, LNMASK(a0)	; line style mask
		move.w	#2, WMODE(a0)		; writing mode (replace)
		move.w 	d3, X1(a0)			; (x1,y1) and (x2, y2) into
		move.w 	d5, Y1(a0)			; appropriate variables
		move.w 	d3, X2(a0)
		move.w 	d4, Y2(a0)
		dc.w	$A003				; Arbitrary Line


		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w 	d4, Y1(a0)			; appropriate variables
		move.w 	d6, X2(a0)
		move.l	#pat, PATPTR(a0)	; pattern pointer
		move.w 	#0,PATMSK(a0)		; Pattern length n-1=0
		move.w 	#0,MFILL(a0)		; Multiple Plane fill off
		dc.w	$A004				; Arbitrary Line
		rts

		.globl	_vhlineb

_vhlineb:

		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w	#1, COLBIT0(a0)		; set COLBIT variables
		move.w	#1, COLBIT1(a0)
		move.w	#1, COLBIT2(a0)
		move.w	#1, COLBIT3(a0)
		move.w	#0, LSTLIN(a0)		; draw last pixel of line
		move.w	#$FFFF, LNMASK(a0)	; line style mask
		move.w	#2, WMODE(a0)		; writing mode (replace)
		move.w 	d3, X1(a0)			; (x1,y1) and (x2, y2) into
		move.w 	d5, Y1(a0)			; appropriate variables
		move.w 	d3, X2(a0)
		move.w 	d4, Y2(a0)
		dc.w	$A003				; Arbitrary Line


		move.l	a3,	a0
		move.l	a3,	d0
		move.l	a4,	a1
		move.l	a5,	a2
		move.w 	d6, X1(a0)			; appropriate variables
		move.w 	d4, Y1(a0)			; appropriate variables
		move.w 	d3, X2(a0)
		move.l	#pat, PATPTR(a0)	; pattern pointer
		move.w 	#0,PATMSK(a0)		; Pattern length n-1=0
		move.w 	#0,MFILL(a0)		; Multiple Plane fill off
		dc.w	$A004				; Arbitrary Line
		rts

.data
pat: 	dc.w	$FFFF				; Pattern for line.



