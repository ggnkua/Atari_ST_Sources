	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB


	org		p:00
	jmp		Init

	org		x:16

red	dc		100
grn	dc		150
blu	dc		200

h	dc		130
s	dc		200
v	dc		120

max	ds		1
min	ds		1
delta	ds		1
i	ds		1
f	ds		1
p	ds		1
q	ds		1
t	ds		1

table	dc		case0
	dc		case1
	dc		case2
	dc		case3
	dc		case4
	dc		case5

	org		p:64

Init:	bclr		#2,omr
	movep		#1,x:PBC			; enable HOST	
	
Convert:

_code	jclr		#0,x:<<HSR,_code
	movep		x:<<HTX,a
	tst		a
	jeq		HSV_RGB

RGB_HSV:
_R	jclr		#0,x:<<HSR,_R
	movep		x:<<HTX,a
	move		a,x:red
_G	jclr		#0,x:<<HSR,_G
	movep		x:<<HTX,a
	move		a,x:grn
_B	jclr		#0,x:<<HSR,_B
	movep		x:<<HTX,a
	move		a,x:blu
	move				x:red,a
	tfr		a,b		x:grn,x0
	cmp		x0,a
	tlt		x0,a
	cmp		x0,b		x:blu,y0
	tgt		x0,b
	cmp		y0,a
	tlt		y0,a
	cmp		y0,b
	tgt		y0,b				; a=max(r,g,b),b=min(r,g,b)
	move		a,x:max
	move		b,x:min
	tst		a
	jne		_nz
_gr	move		a,x:h
	move		a,x:s
	move		a,x:v
	jmp		Unload_HSV
_nz	move		a,x:v				; v=a
	sub		b,a		#>128,y0
	move		a,x:delta
	move		a,x0
	mpy		x0,y0,b
	move		b0,b
	move		x:max,a
	jsr		Divs48_Real			; b=(max-min)/max
	move		#>255,y1
	cmp		y1,b
	tge		y1,b
	move		b,x:s				; s=b
	move		x:max,x0
	move		x:red,a
	cmp		x0,a
	jeq		_magenta_cyan		; if max=red, h=(magenta-cyan)
	move		x:grn,a
	cmp		x0,a
	jeq		_yellow_magenta		; if max=grn, h=(yellow_magenta)
_cyan_yellow					; if max=blu, h=(cyan-yellow)
	move		x:red,b
	move		x:grn,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	move		#>4,a
	add		a,b
	jmp		_norm	
_magenta_cyan
	move		x:grn,b
	move		x:blu,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	tst		b		#>6,a
	jpl		_norm
	add		a,b
	jmp		_norm	
_yellow_magenta
	move		x:blu,b
	move		x:red,a
	sub		a,b		x:delta,a
	jsr		Divs48_Real
	move		#>2,a
	add		a,b
_norm	clr		a
	move		#0.66666,a0
	asl		a
	move		#>42,a1
	jsr		RealMuls
	move		b,x:h
	
Unload_HSV:
	move		x:min,a
	move		x:max,b
	cmp		a,b		#>256,a
	jne		_ngr
	move		a,x:h
_ngr	move		x:v,a
_V	jclr		#1,x:<<HSR,_V
	movep		a,x:<<HTX
	move		x:s,a
_S	jclr		#1,x:<<HSR,_S
	movep		a,x:<<HTX
	move		x:h,a
_H	jclr		#1,x:<<HSR,_H
	movep		a,x:<<HTX
	jmp		Convert

;-----------------------------------------------------------------------*

HSV_RGB:
_V	jclr		#0,x:<<HSR,_V
	movep		x:<<HTX,a
	move		a,x:v
_S	jclr		#0,x:<<HSR,_S
	movep		x:<<HTX,a
	move		a,x:s
_H	jclr		#0,x:<<HSR,_H
	movep		x:<<HTX,a
	move		a,x:h
	move		x:h,b
	move		#256,x0
	cmp		x0,b
	jlt		_ok
	sub		x0,b
_ok	clr		a
	move		#0.66666,a0
	asl		a
	move		#>42,a1
	jsr		Divs48_Real
	move		b1,x:i
	move		b0,x:f
	move		#>256,a
	move		x:s,b
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:p			; v*(256-s)
	move		x:s,b
	clr		a
	move		x:f,a0
	jsr		RealMuls		; (s*f)
	move		#>256,a
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:q			; v*(256-(s*f))
	clr		b		#>1,a
	move		x:f,b0
	sub		b,a
	move		x:s,b
	jsr		RealMuls		; (s*(1.0-f))
	move		#>256,a
	sub		b,a		x:v,x0
	move		a,y0
	mpy		x0,y0,a	#>64*256,x0
	move		a0,y0
	mpy		x0,y0,a
	move		a,x:t			; v*(256-(s*(1.0-f)))
	move		x:i,n0
	move		#table,r0	
	nop
	move		x:(r0+n0),r1
	nop
	jmp		(r1)
	
case0	move		x:v,a
	move		a,x:red
	move		x:t,a
	move		a,x:grn
	move		x:p,a
	move		a,x:blu
	jmp		Unload_RGB

case1	move		x:q,a
	move		a,x:red
	move		x:v,a
	move		a,x:grn
	move		x:p,a
	move		a,x:blu
	jmp		Unload_RGB

case2	move		x:p,a
	move		a,x:red
	move		x:v,a
	move		a,x:grn
	move		x:t,a
	move		a,x:blu
	jmp		Unload_RGB

case3	move		x:p,a
	move		a,x:red
	move		x:q,a
	move		a,x:grn
	move		x:v,a
	move		a,x:blu
	jmp		Unload_RGB

case4	move		x:t,a
	move		a,x:red
	move		x:p,a
	move		a,x:grn
	move		x:v,a
	move		a,x:blu
	jmp		Unload_RGB

case5	move		x:v,a
	move		a,x:red
	move		x:p,a
	move		a,x:grn
	move		x:q,a
	move		a,x:blu

Unload_RGB:
	move		x:red,a
_R	jclr		#1,x:<<HSR,_R
	movep		a,x:<<HTX
	move		x:grn,a
_G	jclr		#1,x:<<HSR,_G
	movep		a,x:<<HTX
	move		x:blu,a
_B	jclr		#1,x:<<HSR,_B
	movep		a,x:<<HTX
	jmp		Convert

;-----------------------------------------------------------------------*
;	Real-number multiply {24:24}*{24:24}={24:24} (23~24 cycles)		*
;-----------------------------------------------------------------------*
;	a	=	48-Bit multiplier							*
;	b	=	48-Bit multiplicand						*
;	b	=	48-Bit quotient							*
;-----------------------------------------------------------------------*

RealMuls:
	abs		a	a1,y0
	eor		y0,b	a1,x1
	eor		y0,b	b1,x:0
	abs		b	a0,a1
	move		b1,y1
	lsr		a	b0,b1
	lsr		b	a1,x0
	move		b1,y0
	mpy		x0,y0,b
	asl		b
	move		b2,a
	move		b1,a0
	mac		x1,y0,a
	mac		x0,y1,a
	asl		a	a0,b1
	move		a1,a0
	move		a2,a1
	mac		x1,y1,a
	asr		a	b1,b0
	move		a0,b1
	move		a2,b2
	jclr		#23,x:0,_posi
	neg		b
_posi	rts

;-----------------------------------------------------------------------*
;	Floating-point divide (48-Bit/48-Bit > 48-Bit real)			*
;-----------------------------------------------------------------------*
;	a	=	48-Bit divisor  (Int:Frc)					*
;	b	=	48-Bit dividend (Int:Frc)					*
;	b	=	48-Bit quotient (Int:Frc)					*
;-----------------------------------------------------------------------*
Divs48_Real:
;-----------------------------------------------------------------------*
	move		r7,n7
	abs		a	a1,x0
	eor		x0,b	#0,r3
	eor		x0,b	b1,x:0
	abs		b	#2,r7
	rep		#9
_Na	norm		r3,a
	norm		r3,a
	jnn		_Na
	rep		#9
_Nb	norm		r7,b
	norm		r7,b
	jnn		_Nb
	move		r7,n3
	asr		b	a,x0
	andi		#$FE,ccr
	rep		#24
	div		x0,b
	clr		a	(r3)-n3
	move		b0,x0
	clr		b	r3,a2
	tst		a	x0,b0
	jlt		_L
	jgt		_R
	jclr		#23,x:0,_e
	neg		b	n7,r7
	rts
_L	neg		a
	rep		a2
	asl		b
	jclr		#23,x:0,_e
	neg		b	n7,r7
	rts
_R	rep		a2
	asr		b
	jclr		#23,x:0,_e
	neg		b
_e	move		n7,r7
	rts

