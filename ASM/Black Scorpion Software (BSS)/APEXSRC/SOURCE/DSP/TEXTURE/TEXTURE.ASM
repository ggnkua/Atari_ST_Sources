	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB


	org		p:00
	jmp		Init

	org		l:32

XInc	ds		1
YInc	ds		1

	org		y:$200
	
zero		ds	1
width		ds	1
sx1		ds	1
sx2		ds	1
sy1		ds	1
sy2		ds	1
sdx		ds	1
	
	org		p:64

Init:	ori		#4,omr			; enable ROM
	movep		#1,x:PBC			; enable HOST	

	clr		a
	move		a,y:zero
	move		#zero,r5
	move		#XInc,r6
	move		#YInc,r7
	move		#>-1,m5
	move		#>-1,m6
	move		#>-1,m7
	
_wid	jclr		#0,x:<<HSR,_wid
	movep		x:<<HTX,a
	move		a,y:sdx

Line:	move		#>1,x0

_xsiz	jclr		#0,x:<<HSR,_xsiz
	movep		x:<<HTX,a
	move		a,y:width
_x2	jclr		#0,x:<<HSR,_x2
	movep		x:<<HTX,a
	add		x0,a
	move		a,y:sx2
_x1	jclr		#0,x:<<HSR,_x1
	movep		x:<<HTX,a
	move		a,y:sx1
_y2	jclr		#0,x:<<HSR,_y2
	movep		x:<<HTX,a
	move		a,y:sy2
_y1	jclr		#0,x:<<HSR,_y1
	movep		x:<<HTX,a
	move		a,y:sy1

	move		y:sx2,b
	move		y:sx1,a
	sub		a,b
	move		y:width,a
	jsr		Divs48_Real
	move		b,l:(r6)
	
	move		y:sy2,b
	move		y:sy1,a
	sub		a,b
	move		y:width,a
	jsr		Divs48_Real
	move		b,l:(r7)

	clr		a
	move		y:(r6),a0
	asr		a
	move		a0,x0
	clr		a
	move		y:(r7),a0
	asr		a
	move		a0,y0

	move		y:sx1,x1
	move		y:sy1,y1
	move		y:width,n3

	do		n3,_xlp
	tfr		y0,a		y:sdx,y0
	mpy		y1,y0,b	a,y0
	asr		b		x:(r6),a
	move		b0,b
	add		x1,b		y:(r6),a0
_w2	jclr		#1,x:<<HSR,_w2
	movep		b,x:<<HTX
	add		x,a		y:(r5),b
	add		a,b		l:(r7),a
	move		b0,x0
	add		y,a		y:(r5),b	b,x1
	add		a,b
	move		b1,y1
	move		b0,y0
_xlp	jmp		Line

;-----------------------------------------------------------------------*
;	Floating-point divide (48-Bit/48-Bit > 48-Bit real)			*
;-----------------------------------------------------------------------*
;	a	=	48-Bit divisor							*
;	b	=	48-Bit dividend							*
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
