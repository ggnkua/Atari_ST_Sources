	nolist

PBC	equ	$FFE0
HSR	equ	$FFE9
HTX	equ	$FFEB

extract_rgb		macro
	move				#>col,r0
	move				#>col,r4
	move				x:(r0)+,x0
	move						y:(r4)+,y0
	mpy		x0,y0,a	x:(r0)+,x0
	move		a0,y0
	mpy		x0,y0,a	x:(r0)+,x0	y:(r4),y1
	and		y1,a		x:(r0)+,y1
	mpy		x0,y0,a	a,x:red
	and		y1,a		x:(r0)+,x0	y:(r4),y1
	mpy		x0,y0,a	a,x:grn
	and		y1,a		#>$04,x0
	add		x0,a		#>$02,y0
	move				a,x:blu
	move		x:red,a
	add		x0,a	x:grn,b
	add		y0,b	a,x:red
	move			b,x:grn
	endm	
	
combine_rgb		macro
	move				x:(r0)+,b	y:(r4),y1
	and		y1,b		x:(r0)+,x0
	move				x:(r0)+,b	b,y0
	mpy		x0,y0,a	x:(r0)+,y1
	and		y1,b		x:(r0)+,x0	y:(r4),y1
	move				x:(r0)+,b	b,y0
	and		y1,b
	mac		x0,y0,a	x:(r0)+,x0	b,y0
	mpy		x0,y0,b	a0,a
	add		b,a
	endm

;-----------------------------------------------------------------------*

dspread		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm

dspreadq		macro	src,dst
_wr	jclr		#0,x:<<HSR,_wr
	move		src,dst
	endm

dspwriteq		macro	src,dst
_wr	jclr		#1,x:<<HSR,_wr
	move		src,dst
	endm

dspwwait		macro
_wr	jclr		#1,x:<<HSR,_wr
	endm

dsprwait		macro
_wr	jclr		#0,x:<<HSR,_wr
	endm

;-----------------------------------------------------------------------*

		org	p:00
		jmp	Init

;-----------------------------------------------------------------------*

		org	x:00
		
temp:		ds	1

;-----------------------------------------------------------------------*

		org	x:8
		dc	(1<<6)
		dc	(1<<8)
		dc	(1<<13)
		dc	%11111100	;6
		dc	(1<<19)
		org	y:8
col		ds	1
		dc	%11111000	;5
		org	x:24
red		dc	0
		dc	(1<<7)
grn		dc	0
		dc	%11111100	;6
		dc	(1<<2)
blu		dc	0
		dc	(1<<20)
		org	y:24
cmb		dc	%11111000	;5

		org	x:16
reda:		ds	1
grna:		ds	1
blua:		ds	1
redc:		ds	1
grnc:		ds	1
bluc:		ds	1

count:	ds	1
thresh:	ds	1

;-----------------------------------------------------------------------*

	org	p:64

Init:	bclr		#2,omr
	movep		#1,x:PBC
	dspread	x:thresh

_loop	dspread	y:col
	extract_rgb

	move		x:red,a
	move		a,x:redc
	move		a,x:reda
	move		x:grn,a
	move		a,x:grnc
	move		a,x:grna
	move		x:blu,a
	move		a,x:bluc
	move		a,x:blua
	move		#>1,a
	move		a,x:count
	dspread	a
	do		a,_acc
	dspread	y:col
	extract_rgb
	move		x:red,x0
	move		x:redc,a
	sub		x0,a
	abs		a	x:thresh,y0
	cmp		y0,a	x:grn,x0
	jgt		_next
	move		x:grnc,a
	sub		x0,a
	abs		a
	cmp		y0,a	x:blu,x0
	jgt		_next
	move		x:bluc,a
	sub		x0,a
	abs		a
	cmp		y0,a	x:red,x0
	jgt		_next
	move		x:reda,a
	add		x0,a	x:grn,x0
	move		a,x:reda
	move		x:grna,a
	add		x0,a	x:blu,x0
	move		a,x:grna
	move		x:blua,a
	add		x0,a	#>1,x0
	move		a,x:blua
	move		x:count,a
	add		x0,a
	move		a,x:count
_next	nop
	move		#>%100,y1
_acc	clr		a	#>255,y0
	move		x:reda,a0
	move		x:count,x0
	rep		#4
	asl		a
	andi		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	add		y1,a
	rep		#3
	asr		a
	cmp		y0,a
	tge		y0,a
	move		a,x:red
	clr		a	x:count,x0
	move		x:grna,a0
	rep		#4
	asl		a
	andi		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	add		y1,a
	rep		#3
	asr		a
	cmp		y0,a
	tge		y0,a
	move		a,x:grn
	clr		a	x:count,x0
	move		x:blua,a0
	rep		#4
	asl		a
	andi		#$FE,ccr
	rep		#24
	div		x0,a
	move		a0,a
	add		y1,a
	rep		#3
	asr		a
	cmp		y0,a	#>cmb,r0		
	tge		y0,a
	move		r0,r4
	move		a,x:blu
	combine_rgb
	dspwrite	a
	jmp		_loop	

