	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB

dspread		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm


	org		p:00
	jmp		Init

	org		x:0
	
zero	ds		1

type	ds		1

pts	dc		256

Px1	dc		100
Py1	dc		100
Px2	dc		10
Py2	dc		100
Px3	dc		100
Py3	dc		80
Px4	dc		200
Py4	dc		100

	org		l:32

sixth	ds		1
t3rds	ds		1

term	ds		1
ti	ds		1

xx	ds		1
yy	ds		1	

t	ds		1
tx3	ds		1

t2	ds		1
t2x3	ds		1

t3o6	ds		1

t3	ds		1
t3x3	ds		1

	org		p:64

Init:	bclr		#2,omr			; disable ROM
	movep		#1,x:PBC			; enable HOST	
	move		#>6,a
	move		#>1,b
	jsr		Divs48_Real
	move		b,l:sixth
	move		#>3,a
	move		#>2,b
	jsr		Divs48_Real
	move		b,l:t3rds
	dspread	x:type
	jset		#0,x:type,spline

bezier:
	jsr		Fetch
	jsr		Init_bezier
	do		x:pts,blp
	jsr		Bezier_xy
	move		l:t,a
	move		l:ti,b
	add		b,a
	move		a,l:t
	move		l:xx,a
	rnd		a	l:yy,b
	dspwrite	a
	rnd		b
	dspwrite	b
blp:	nop
	jmp		bezier

spline:
	jsr		Fetch
	jsr		Init_bezier
	do		x:pts,slp
	jsr		Spline_xy
	move		l:t,a
	move		l:ti,b
	add		b,a
	move		a,l:t
	move		l:xx,a
	rnd		a	l:yy,b
	dspwrite	a
	rnd		b
	dspwrite	b
slp:	nop
	jmp		spline

Fetch:
	dspread	x:Px1
	dspread	x:Py1
	dspread	x:Px2
	dspread	x:Py2
	dspread	x:Px3
	dspread	x:Py3
	dspread	x:Px4
	dspread	x:Py4
	dspread	x:pts
	rts

;-----------------------------------*
Init_bezier:
;-----------------------------------*
	move		#>1,b
	move		x:pts,a
	sub		b,a
	jsr		Divs48_Real
	move		b,l:ti
	clr		b
	move		b,l:t
	rts
	
;-----------------------------------*
Bezier_xy:
;-----------------------------------*
	move			l:t,a
	tfr		a,b
	add		a,b
	add		a,b	l:t,a
	tfr		a,b	b,l:tx3	; tx3
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	tfr		b,a	b,l:t2	; t^2
;- - - - - - - - - - - - - - - - - -*
	add		a,b
	add		a,b	l:t,a
	move			b,l:t2x3	; 3t^2
;- - - - - - - - - - - - - - - - - -*
	move			l:t2,b
	jsr		RealMuls
	tfr		b,a	b,l:t3	; t^3
;- - - - - - - - - - - - - - - - - -*
	add		a,b
	add		a,b	l:t2x3,a
	move			b,l:t3x3	; 3t^3
;-----------------------------------*
	move			l:t3,b	; ( 3t^2
	sub		b,a	l:tx3,b	; - t^3
	sub		b,a	#>1,b		; - 3t
	add		b,a	x:Px1,b	; + 1 )
	move			a,l:term
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	move			b,l:xx	; (...)*Px1
	move			l:term,a
	move			x:Py1,b
	jsr		RealMuls
	move			b,l:yy	; (...)*Py1
;-----------------------------------*
	move			l:t2x3,b	;
	asl		b	l:t3x3,a	; ( 3t^3
	sub		b,a	l:tx3,b	; - 6t^2
	add		b,a	x:Px2,b	; + 3t )
	move			a,l:term
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py2,b
	move			a,l:xx	; +(...)*Px2
	move			l:term,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a	l:t3x3,b
	move			a,l:yy	; +(...)*Py2
;-----------------------------------*
	move			l:t2x3,a
	sub		b,a	x:Px3,b	
	move			a,l:term	; ( -3t^3 + 3t^2 )
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py3,b
	move			a,l:xx	; +(...)*Px3
	move			l:term,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a	x:Px4,b
	move			a,l:yy	; +(...)*Py3
;-----------------------------------*
	move			l:t3,a
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py4,b
	move			a,l:xx	; +t^3*Px4
	move			l:t3,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a
	move			a,l:yy	; +t^3*Px4
;-----------------------------------*
	rts

;-----------------------------------*
Spline_xy:
;-----------------------------------*
	move			l:t,a
	tfr		a,b
	jsr		RealMuls
	move			b,l:t2	; t^2
;- - - - - - - - - - - - - - - - - -*
	move			l:t,a
	move			l:t2,b
	jsr		RealMuls
	move			b,l:t3	; t^3
;- - - - - - - - - - - - - - - - - -*
	move			l:sixth,a
	jsr		RealMuls
	move			b,l:t3o6	; (1/6)t^3
;-----------------------------------*
	move			l:sixth,a	; ( (1/6)
;- - - - - - - - - - - - - - - - - -*
	sub		b,a	l:t2,b	; - (1/6)t^3
;- - - - - - - - - - - - - - - - - -*
	asr		b
	add		b,a	l:t,b		; + (1/2)t^2
;- - - - - - - - - - - - - - - - - -*
	asr		b
	sub		b,a	x:Px1,b
	move			a,l:term	; - (1/2)t )
;-----------------------------------*
	jsr		RealMuls
	move			b,l:xx	; (...)*Px1
	move			l:term,a
	move			x:Py1,b
	jsr		RealMuls
	move			b,l:yy	; (...)*Py1
;-----------------------------------*
	move			l:t3,a
	asr		a	l:t2,b	; ( (1/2)t^3
;- - - - - - - - - - - - - - - - - -*
	sub		b,a	l:t3rds,b	; - t^2
;- - - - - - - - - - - - - - - - - -*
	add		b,a	x:Px2,b
	move			a,l:term	; + (2/3) )
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py2,b
	move			a,l:xx	; +(...)*Px2
	move			l:term,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a
	move			a,l:yy	; +(...)*Py2
;-----------------------------------*
	move			l:t2,a
	asr		a	l:t3,b	; ( (1/2)t^2
;- - - - - - - - - - - - - - - - - -*
	asr		b
	sub		b,a	l:t,b		; - (1/2)t^3
;- - - - - - - - - - - - - - - - - -*
	asr		b
	add		b,a	l:sixth,b	; + (1/2)t
;- - - - - - - - - - - - - - - - - -*
	add		b,a	x:Px3,b
	move			a,l:term	; + (1/2) )
;-----------------------------------*
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py3,b
	move			a,l:xx	; +(...)*Px3
	move			l:term,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a	x:Px4,b
	move			a,l:yy	; +(...)*Py3
;-----------------------------------*
	move			l:t3o6,a
	move			a,l:term	; ( 1/6t^3 )
;- - - - - - - - - - - - - - - - - -*
	jsr		RealMuls
	move			l:xx,a
	add		b,a	x:Py4,b
	move			a,l:xx	; +(...)*Px4
	move			l:term,a
	jsr		RealMuls
	move			l:yy,a
	add		b,a
	move			a,l:yy	; +(...)*Py4
;-----------------------------------*
	rts

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
	eor		y0,b	b1,x:zero
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
	jclr		#23,x:zero,_posi
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
	eor		x0,b	#>0,r3
	eor		x0,b	b1,x:zero
	abs		b	#>2,r7
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
	jclr		#23,x:zero,_e
	neg		b	n7,r7
	rts
_L	neg		a
	rep		a2
	asl		b
	jclr		#23,x:zero,_e
	neg		b	n7,r7
	rts
_R	rep		a2
	asr		b
	jclr		#23,x:zero,_e
	neg		b
_e	move		n7,r7
	rts
