	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB

;-----------------------------------*
;	Host macros
;-----------------------------------*

dspread		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm

;-----------------------------------*


max_edges:		=	24		; max edge x's per scanline
bucket_size:	=	1+max_edges	; size of scanline bucket

;-----------------------------------*

			org	p:00
			jmp	Init

;-----------------------------------*

			org	l:1

xinc			ds	1		; polygon edge x-inc

term			ds	1		; bezier long-vars
ti			ds	1
xx			ds	1
yy			ds	1	
t			ds	1
tx3			ds	1
t2			ds	1
t2x3			ds	1
t3			ds	1
t3x3			ds	1

;-----------------------------------*

			org	y:12

maxy			ds	1

;-----------------------------------*

			org	x:0

zero:			ds	1

			org	x:12

miny:			ds	1
newsign:		dc	(1<<22)
sign:			ds	1
xstart:		ds	1
width:		ds	1
height:		ds	1
pointer:		ds	1
temp:			ds	1
baseline:		ds	1
	
line_count:		ds	1
LX2:			ds	1
LY2:			ds	1
lx:			ds	1
ly:			ds	1

scaler:		ds	1
h_count:		ds	1

xbase:		ds	1
ybase:		ds	1

lines:		dc	scanlines

pts			dc	32	; bezier vars
Px1			dc	100
Py1			dc	100
Px2			dc	10
Py2			dc	100
Px3			dc	100
Py3			dc	80
Px4			dc	200
Py4			dc	100

CFN_routs:		dc	start_path
			dc	link_line
			dc	link_bezier
			dc	integrate_edges


last_LX:		ds	1
last_LY:		ds	1
line_buffer:			; buffer for definition lines
first_LX:		ds	1
first_LY:		ds	1

;-----------------------------------*

	org		p:64

Init:	bclr		#2,omr			; disable ROM
	dspread	x:pts
	jsr		clear_character

_loop	dspread	x0				; 0-256
	move		#>(1<<(3+8-2)),y0
	mpy		x0,y0,a			; shift 'scaler' to fit range
	move		a0,x:scaler
	move		a0,y0
	dspread	x0
	mpy		x0,y0,a
	move		a,x:baseline

	jsr		build_character		; create edge-list
	jsr		sort_buckets		; sort buckets in x-axis
	jsr		send_lines			; send lines in bracketed-order
	jsr		clear_character
	jmp		_loop
	
;-----------------------------------*
clear_character:
;-----------------------------------*
	move		#char,r7
	clr		a	#bucket_size,n7	; create character-polygon
	move		a,x:line_count
	rep		#scanlines
	move		a,y:(r7)+n7
	move		#>$0FFFFF,b
	clr		b	b,x:miny
	move		b,y:maxy
	rts

;-----------------------------------*
build_character:
;-----------------------------------*

;-----------------------------------*
next_code:
;-----------------------------------*
	dspread	a
	move		#CFN_routs,r3
	move		a,n3
	nop
	move		x:(r3+n3),r3
	nop
	jmp		(r3)
	
;-----------------------------------*
start_path:
;-----------------------------------*
	move		#>$0FFFFF,b
	move		b,x:last_LX
	move		b,x:last_LY
	clr		b
	move		b,x:h_count
	jsr		integrate_edges
	move		x:scaler,y0
	dspread	x1
	dspread	y1
	mpy		x1,y0,a
	mpy		y1,y0,a	a,x:(r4)+
	move				a,x:(r4)+
	jmp		next_code
	
;-----------------------------------*
link_line:
;-----------------------------------*
	move		x:scaler,y0
	move		r4,r0
	dspread	x1
	dspread	y1
	move		x:-(r0),b			; last-y
	mpy		y1,y0,a			; new-y
	move		a,x0
	cmp		x0,b	#>1,b
	jeq		_same
	clr		a
	move		a,x:h_count
	jmp		_diff
_same	move		x:h_count,a			; inc counter
	add		b,a	#>2,x0
	move		a,x:h_count
	cmp		x0,a
	jlt		_diff
	mpy		x1,y0,a			; new-x
	move		a,x:-(r0)
	jmp		next_code
_diff	mpy		x1,y0,a
	mpy		y1,y0,a	a,x:(r4)+	; new-x
	move				a,x:(r4)+	; new-y
	move		x:line_count,a
	add		b,a
	move		a,x:line_count
	jmp		next_code

;-----------------------------------*
link_bezier:
;-----------------------------------*
	move		r4,r5
	move		x:scaler,y0
	move		x:-(r5),a
	move				a,x:Py1
	move		x:-(r5),a
	dspread	x1
	dspread	y1
	mpy		x1,y0,a	a,x:Px1
	mpy		y1,y0,a	a,x:Px2
	move				a,x:Py2
	dspread	x1
	dspread	y1
	mpy		x1,y0,a
	mpy		y1,y0,a	a,x:Px3
	move				a,x:Py3
	dspread	x1
	dspread	y1
	mpy		x1,y0,a
	mpy		y1,y0,a	a,x:Px4
	move				a,x:Py4
	jsr		init_curve
	do		x:pts,bezlp
	jsr		bezier_xy
	move		l:t,a
	move		l:ti,b
	add		b,a	#>1,x0
	move		r4,r0
	move		a,l:t
	move		l:yy,a			; new-y
	rnd		a	x:-(r0),b		; last-y
	cmp		a,b	#0,a
	jeq		_same
	move		a,x:h_count
	jmp		_diff
_same	move		x:h_count,a			; inc counter
	add		x0,a	#>2,x1
	move		a,x:h_count
	cmp		x1,a
	jlt		_diff
	move		l:xx,a			; new-y
	rnd		a
	move		a,x:-(r0)			; new-x
	jmp		_skip
_diff	move			l:xx,a
	rnd		a	l:yy,b
	rnd		b	a,x:(r4)+
	move			b,x:(r4)+
	move		x:line_count,a
	add		x0,a
	move		a,x:line_count
_skip	nop
bezlp	nop
	jmp		next_code

;-----------------------------------*
integrate_edges:
;-----------------------------------*
	move		x:line_count,a		; create edge-buckets from poly
	tst		a		x:first_LX,a	
	jeq		LineLoop
	move		x:first_LY,b
	move		a,x:(r4)+	
	move		b,x:(r4)+
	move		x:line_count,a
	clr		b		#>line_buffer,r0
	move		b,x:line_count
	move		#>1,b
	add		b,a		#>miny,r1
	move		#>maxy,r4
;-----------------------------------*
scan_conversion:
;-----------------------------------*
	do		a,LineLoop
;-----------------------------------*
_Read	move		x:(r0)+,x0
	move		x:(r0)+,a
	move		x:(r0)+,x1
	move		x:(r0)-,b
;-----------------------------------*
	tst		a		#>0,y1
	tmi		y1,a
	tst		b		a,y0
	tmi		y1,b
	move		b,y1
	move		x:(r1),a	y:(r4),b
	cmp		y0,a
	tgt		y0,a
	cmp		y0,b		a,x:(r1)
	tlt		y0,b
	move		y1,a
;-----------------------------------*
	clr		b		b,y:(r4)
	cmp		y0,a		x:newsign,a
	jeq		NextLine
	tlt		a,b
;-----------------------------------*
	move		x1,a
	cmp		x0,a		b,x:sign
	jpl		_rght
	tfr		x0,a		x1,x0
	move		a,x1
	tfr		y0,a		y1,y0
	move		a,y1
;-----------------------------------*
_rght	move		y1,a
	sub		y0,a		#>bucket_size,n7
	jpl		_curd	
	neg		a		#>(-bucket_size),n7
;-----------------------------------*
_curd	move		#>1,b
	move		a,x:height		; adjusted height
	move		x1,a
	sub		x0,a	x0,x:xstart	; store start-x
	add		b,a		#0,b	; adjusted width
	move		a,x:width		; adjusted height
;-----------------------------------*
	move		#>bucket_size,y1
	mpy		y0,y1,b
	asr		b		#>char,a
	move		b0,b
	add		a,b
	move		b,x:pointer
;-----------------------------------*
	move		x:height,a
	move		#>1,x0
	add		x0,a
	move		x:width,b
	jsr		Divs48_Real
	move		b,l:xinc
;-----------------------------------*
	move		n7,a2
	tst		a		x:pointer,r7
	jpl		dnfil
;-----------------------------------*
upfil	move				x:xstart,a
	asl		a		x:sign,x0
	move		b0,a0
	asr		a		x:height,b
	do		b,_ylop
	move		l:xinc,b
	add		b,a		(r7)+n7
	move		y:(r7),r5
	tfr		a,b		r7,r6
	or		x0,b		(r5)+
	move		r5,n6
	move		r5,y:(r7)
	move		b,y:(r6+n6)
_ylop	jmp		NextLine
;-----------------------------------*
dnfil	move				x:xstart,a
	asl		a		x:sign,x0
	move		b0,a0
	asr		a		x:height,b
	do		b,NextLine
	move		y:(r7),r5
	tfr		a,b		r7,r6
	or		x0,b		(r5)+
	move		r5,n6
	move		r5,y:(r7)
	move		b,y:(r6+n6)
	move		l:xinc,b
	add		b,a		(r7)+n7
;-----------------------------------*
NextLine:
	nop
;-----------------------------------*
LineLoop:
	move		#>line_buffer,r4
	rts

;-----------------------------------*
sort_buckets:
;-----------------------------------*
	move		x:miny,y0
	move		#>bucket_size,y1
	mpy		y0,y1,b	y:maxy,a
	asr		b	#>char,x0
	move		b0,b
	add		x0,b	#bucket_size-1,n7
	sub		y0,a	b,x:pointer
	move		b,r7
	move		x:miny,b
	add		a,b
	move		b,x0
	move		#>scanlines,b
	sub		x0,b
	jpl		_go
	add		b,a
_go	move		a,x:height
	tst		a
	jle		sylp
	move		#>1,x1
	move		#>$00FFFF,y1
	do		x:height,sylp
	move		y:(r7)+,a
	sub		x1,a	
	jle		solp
	move		a,r4
	do		r4,solp
	move		r7,r6
	do		r4,sxlp
	move		y:(r6)+,a
	and		y1,a		a,y0
	move		y:(r6),b
	and		y1,b		b,x0
	cmp		a,b
	jgt		sord
	move		y0,y:(r6)-
	move		x0,y:(r6)+
sord	nop
sxlp	lua		(r4)-,r4
solp	move		y:(r7)+n7,a
sylp	rts

;-----------------------------------*
send_lines:
;-----------------------------------*
	move		x:miny,a
	move		x:baseline,b
	sub		b,a
	dspwrite	a
	move		x:pointer,r7
	move		#>bucket_size,n7
	move		r7,r6
	move		#>temp,r0
	move		#>$FF0000,y0
	move		#>1,x1
	move		x:height,a
	tst		a
	jle		_ylp
	do		a,_ylp
	move		y:(r6)+,b
	asr		b
	sub		x1,b		(r7)+n7
	jmi		_none
_xlp	clr		a		y:(r6)+,x0
_look	move		a,x:(r0)	y:(r6)+,y1
	move		x0,a
	eor		y1,a
	and		y0,a
	tst		a		x:(r0),a
	jne		_new
	sub		x1,b
	jmi		_none
	add		x1,a
	jmp		_look
_new	sub		x1,a
	jpl		_look
	dspwrite	x0
	dspwrite	y1
	sub		x1,b
	jpl		_xlp
_none	move		r7,r6		
	dspwrite	#>-32767		; 'end of scanline' code
_ylp	nop
	dspwrite	#>-32766		; send 'end of character' code
	rts

;-----------------------------------*
bezier_xy:
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
Divs48_Real:	; trashes r3/n3/r7
;-----------------------------------------------------------------------*
	abs		a	a1,x0
	eor		x0,b	#>0,r3
	eor		x0,b	b1,x:zero
	abs		b	#>2,r7
	rep		#11
_Na	norm		r3,a
	norm		r3,a
	jnn		_Na
	rep		#11
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
	jgt		_R
	jeq		_done
_L	neg		a
	rep		a2
	asl		b
	jmp		_done
_R	rep		a2
	asr		b
_done	jclr		#23,x:zero,_e
	neg		b
_e	rts

;-----------------------------------*
init_curve:
;-----------------------------------*
	move		#>1,b				; set up bezier increment for 'T'
	move		x:pts,a
	sub		b,a
	jsr		Divs48_Real
	clr		b	b,l:ti
	move		b,l:t
	rts

;-----------------------------------*
endcode:
;-----------------------------------*

char_start:	=	endcode

	org		y:char_start
char:
	org		y:16384
endy:

scanlines:	=	(endy-char)/bucket_size

