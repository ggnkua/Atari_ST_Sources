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
twidth:	ds	1
start:	ds	1
start15:	ds	1
lasta0:	ds	1
lasty0:	ds	1
	
shifter:	dc	1<<0,1<<15,1<<14,1<<13,1<<12,1<<11,1<<10,1<<9
		dc	1<<8,1<<7,1<<6,1<<5,1<<4,1<<3,1<<2,1<<1

	
		org	y:15
		ds	1
linebuffer:	ds	1024

;*----------------------------------------------------------------*

	org		p:$40

;*----------------------------------------------------------------*

Init:	bclr		#2,omr
	movep		#1,x:PBC			; enable HOST	

	move		#16-1,m1
	move		#>HTX,r2
	move		#>1,n4

read:	dsprreg	a
	tst		a	#>-1,b
	jpl		new_start
	cmp		b,a	#>-2,b
	jeq		use_bytes
	cmp		b,a	#>-3,b
	jeq		use_words
	cmp		b,a
	jeq		write_line
	jmp		read
	
write_line:
	move		x:lasta0,a0
	move		a0,y:(r4)+
	move		x:twidth,b
	move		x:start15,x1
	add		x1,b	#>15,x0
	add		x0,b				; got width in words
	lsr		b
	lsr		b
	lsr		b	#linebuffer,r5
	lsr		b	#>1,x0
	dspwreg	b
	sub		x0,b	#>HTX,r0
	jeq		_one
	do		b,_one
	dup		texplanes
	dspwrite	y:(r5)+
	endm
_one	move		x:twidth,a
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
_send	nop
	jmp		read

new_start:
	move		#linebuffer-1,r4
	move		#-1,m4
	move		a,x:start
	move		#>16-1,x0
	and		x0,a
	move		a,r1
	move		a,x:start15
	clr		a	y:(r4+n4),y0
	move		a,x:twidth
	move		a,x:lasta0
	move		y0,x:lasty0
	jmp		read	

use_bytes:
	dsprreg	a
	tst		a
	jmi		run_bytes

copy_bytes:
	move			x:twidth,b
	add		a,b	a,x:width
	move			b,x:twidth
	clr		a	x:lasty0,y0	; get y0 from previous call
	move			x:lasta0,a0	; get a0 from previous call
	do		x:width,_dots	
_rd	jclr		#0,x:<<HSR,_rd
	move		x:(r2),b		; fetch new pixel
	move			a0,y:(r4)+	; store last strip
	move		#tp-1,m4
	dup		texplanes-1
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move			a0,y:(r4)+
	endm
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move		x:(r1)+,m4
_dots	move		a0,x:lasta0		; keep a0 for next call
	move		y0,x:lasty0		; keep a0 for next call
	jmp		read	

run_bytes:
	neg		a	x:twidth,b
	add		a,b	a,x:width
	move			b,x:twidth
	clr		a	x:lasty0,y0	; get y0 from previous call
	move			x:lasta0,a0	; get a0 from previous call
	dsprreg	x1			; fetch new pixel
	do		x:width,_dots	
	move		x1,b
	move			a0,y:(r4)+	; store last strip
	move		#tp-1,m4
	dup		texplanes-1
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move			a0,y:(r4)+
	endm
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move		x:(r1)+,m4
_dots	move		a0,x:lasta0		; keep a0 for next call
	move		y0,x:lasty0		; keep a0 for next call
	jmp		read	

use_words:
	dsprreg	a
	neg		a

run_words:
	asl		a
	move			x:twidth,b
	add		a,b	a,x:width
	move			b,x:twidth
	clr		a	x:lasty0,y0	; get y0 from previous call
	move			x:lasta0,a0	; get a0 from previous call
	dsprreg	x1
	dsprreg	y1
	do		x:width,_dots	
	tfr		x1,b	y1,x1
	move		b,y1
	move			a0,y:(r4)+	; store last strip
	move		#tp-1,m4
	dup		texplanes-1
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move			a0,y:(r4)+
	endm
	lsr		b	y0,a0
	adc		y,a	y:(r4+n4),y0
	move		x:(r1)+,m4
_dots	move		a0,x:lasta0		; keep a0 for next call
	move		y0,x:lasty0		; keep a0 for next call
	jmp		read	

