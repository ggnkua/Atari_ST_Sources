 nolist
;-----------------------------------------------*
	
PBC			=	$FFE0
HSR			=	$FFE9
HTX			=	$FFEB

texplanes		=	8

;-----------------------------------------------*

dspread		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	movep		x:<<HTX,var
	endm

dspwrite		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	movep		var,x:<<HTX
	endm

dsprreg		macro	var
_rd	jclr		#0,x:<<HSR,_rd
	move		x:HTX,var
	endm

dspwreg		macro	var
_wr	jclr		#1,x:<<HSR,_wr
	move		var,x:HTX
	endm

dspwait		macro
_wr	jclr		#1,x:<<HSR,_wr
	endm

		org	p:$0
		jmp	Init

		org	x:0

tp		=	texplanes

skips:	dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	tp-1
		dc	0-1

width:	ds	1
start:	ds	1
	
shifter:	dc	1<<0,1<<15,1<<14,1<<13,1<<12,1<<11,1<<10,1<<9
		dc	1<<8,1<<7,1<<6,1<<5,1<<4,1<<3,1<<2,1<<1
	
		org	y:15
		ds	1
linebuffer:


;*----------------------------------------------------------------*

	org		p:$40

;*----------------------------------------------------------------*

Init:	bclr		#2,omr

	move		#>0,y1
	move		#16-1,m1
	move		#>HTX,r2
	move		#>1,n4

read:	move		#linebuffer-1,r4
	move		#-1,m4
	dsprreg	a
	move		a,x:width
	dsprreg	b
	move		b,x:start

	move			#>16-1,x0
	and		x0,b	y:(r4+n4),y0
	clr		a	b,r1
	move			b,x1

	do		x:width,_dots	
_rd	jclr		#0,x:<<HSR,_rd
	move			x:(r2),b
	move			a0,y:(r4)+
	move		#tp-1,m4
	dup		texplanes-1
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move			a0,y:(r4)+
	endm
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move		x:(r1)+,m4
_dots	move			a0,y:(r4)+


	move			x:width,b
	add		x1,b	#>16-1,x0
	add		x0,b	#linebuffer,r5
	move			b,x0
	move			#>1<<(23-4),y0
	mpy		x0,y0,b	#>1,x0
	move		b1,b

	dspwreg	b

	sub		x0,b		#>HTX,r0
	jle		_one

	do		b,_one
	dup		texplanes
	dspwrite	y:(r5)+
	endm
_one
	move		x:width,a
	move		x:start,b
	add		b,a		#>16-1,x0
	and		x0,a		#>shifter,x0

	add		x0,a
	move		a,r3
	nop
	move		x:(r3),x0	y:(r5)+,y0
	mpy		x0,y0,a
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	mpy		x0,y0,a	a0,x:(r0)
	asr		a		y:(r5)+,y0
	dspwait
	move				a0,x:(r0)

_send	jmp		read	
	