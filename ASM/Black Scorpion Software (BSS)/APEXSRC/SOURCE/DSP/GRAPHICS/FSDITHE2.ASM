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

		org	p:00
		jmp	Init

		org	x:0

rdat		ds	256

red		ds	1
green		ds	1
blue		ds	1
ored		ds	1
ogreen	ds	1
oblue		ds	1

ptr		ds	1
ocol		ds	1

count		ds	1

width		dc	322
xoffset	dc	0
linewid	dc	322*3

re:		ds	1
ge:		ds	1
be:		ds	1

rt:		dc	(7.0/16.0)
blt:		dc	(3.0/16.0)
bmd:		dc	(5.0/16.0)
brt:		dc	(1.0/16.0)

	org		y:0
	
gbdat	ds		256*2
near:	ds		1

	org		l:$201

buffer:
	ds		1280*3*2

hash:	ds		4096


	org		p:64

Init:	bclr		#2,omr

Load:	jsr		read_palette
	jsr		read_width
	jsr		reset

	clr		a
	move		a,x:ored
	move		a,x:ogreen
	move		a,x:oblue

	jsr		make_hash

	clr		a
	move		a,x:red
	move		a,x:green
	move		a,x:blue
	jsr		search_list
	move		a,x:ocol

loop:	jsr		read_pixel
	move		x:red,x0
	move		x:ored,b
	cmp		x0,b
	jne		force
	move		x:green,x0
	move		x:ogreen,b
	cmp		x0,b
	jne		force
	move		x:blue,x0
	move		x:oblue,b
	cmp		x0,b		x:ocol,a
	jeq		send
force	jsr		search_hash
	;jsr		search_list
send	dspwrite	a
	move		a,x:ocol
	jsr		distribute_error
	move		x:red,a
	move		a,x:ored
	move		x:green,a
	move		a,x:ogreen
	move		x:blue,a
	move		a,x:oblue
	jmp		loop

search_list:
	move		#0,r6
	move		#0,n7
	move		#>$300000,a
	move		a,l:near
	move		#>rdat,r0
	move		#>gbdat,r1
	move		x:(r0)+,a
	move		x:count,b
	do		b,_clop
	move		x:red,x0
	sub		x0,a		r6,n6
	move		a,x0		y:(r1)+,a
	mpy		x0,x0,b	x:green,x0	
	sub		x0,a		(r6)+
	move		a,x0		y:(r1)+,a
	mac		x0,x0,b	x:blue,x0	
	sub		x0,a
	move		a,x0
	mac		x0,x0,b	l:near,a
	cmp		a,b		x:(r0)+,a
	jge		_skip
	move		b,l:near
	move		n6,n7
_skip	nop
_clop	clr		a
	move		n7,a
	rts

distribute_error:
	move		#>rdat,b
	add		a,b
	move		b,r0
	asl		a	#>gbdat,b
	add		a,b
	move		b,r1
	move		#>buffer+(3*2),a
	move		x:xoffset,x1
	add		x1,a	#>(3*3),x1
	move		a,r2			; pixel error address (x+1,y)
	sub		x1,a	x:linewid,x1
	add		x1,a
	move		a,r3			; pixel error address (x-1,y+1)
	move		x:red,a		; or
	move		x:(r0)+,x0		; nr
	sub		x0,a			; re=or-nr
	move		a,x:re
	move		x:green,a		; og
	move		y:(r1)+,x0		; ng
	sub		x0,a			; ge=og-ng
	move		a,x:ge
	move		x:blue,a		; ob
	move		y:(r1)+,x0		; nb
	sub		x0,a			; be=ob-nb
	move		a,x:be
	move		r2,r4
	move		x:rt,y0
	jsr		spread
	move		r3,r4
	move		x:blt,y0
	jsr		spread
	move		x:bmd,y0
	jsr		spread
	move		x:brt,y0
spread:
	move				x:re,x0
	move		l:(r4),a
	mac		x0,y0,a	x:ge,x0
	move		a,l:(r4)+
	move		l:(r4),a	
	mac		x0,y0,a	x:be,x0
	move		a,l:(r4)+
	move		l:(r4),a	
	mac		x0,y0,a
	move		a,l:(r4)+
	rts
	
next_line:
	move		x:linewid,x0
	move		#>buffer,b
	add		x0,b		b,a
	clr		b	b,r0
	move		a,r1
	move		x:width,a
	do		a,_copy
	move		l:(r0),a
	move		b,l:(r0)+
	move		a,l:(r1)+	
	move		l:(r0),a
	move		b,l:(r0)+
	move		a,l:(r1)+	
	move		l:(r0),a
	move		b,l:(r0)+
	move		a,l:(r1)+	
_copy	rts
	
read_pixel:
_next	dspread	a				; fetch x-coord
	move		#>$1000,x0
	cmp		x0,a
	jne		_cont
	jsr		next_line
	jmp		_next
_cont	move		a,b
	asl		a	a,x0
	add		x0,a
	move		a,x:xoffset
	move		x:xoffset,a
	move		#>buffer+3,x0
	add		x0,a
	move		a,r0
	move		#>0,y0
	move		#>$FF,y1
	move		x:(r0)+,x0
	dspread	a
	add		x0,a	x:(r0)+,x0
	tst		a
	tmi		y0,a
	cmp		y1,a
	tgt		y1,a
	move		a,x:red
	dspread	a
	add		x0,a	x:(r0)+,x0
	tst		a
	tmi		y0,a
	cmp		y1,a
	tgt		y1,a
	move		a,x:green
	dspread	a
	add		x0,a
	tst		a
	tmi		y0,a
	cmp		y1,a
	tgt		y1,a
	move		a,x:blue
	rts

read_palette:
	move		#>rdat,r0
	move		#>gbdat,r1
	dspread	a
	move		a,x:count
	do		a,_get
	dspread	x:(r0)+
	dspread	y:(r1)+
	dspread	y:(r1)+
_get	rts

read_width:
	dspread	a
	move		#>2,x0
	add		x0,a
	move		a,x:width
	asl		a	a,x0
	add		x0,a
	move		a,x:linewid
	rts

reset:
	clr		b	#buffer,r0
	move		x:width,a
	do		a,_clr
	move		b,l:(r0)+
	move		b,l:(r0)+
	move		b,l:(r0)+
	move		b,l:(r0)+
	move		b,l:(r0)+
	move		b,l:(r0)+
_clr	rts

make_hash:
	clr		a
	move		a,x:ocol
	move		#>hash,r0
	move		r0,x:ptr
	move		#>4096,x0
	do		x0,_next
	move		x:ocol,a
	move			#>$F00,y0
	and		y0,a	#>$008,y0
	rep		#4
	lsr		a
	add		y0,a
	move		a,x:red
	move		x:ocol,a
	move			#>$0F0,y0
	and		y0,a	#>$008,y0
	add		y0,a
	move		a,x:green
	move		x:ocol,a
	move			#>$00F,y0
	and		y0,a	#>$008,y0
	rep		#4
	lsl		a
	add		y0,a
	move		a,x:blue
	jsr		search_list
	move		x:ptr,r0
	move		#>1,x0
	move		x:ocol,b
	add		x0,b
	move		b,x:ocol
	move		a,x:(r0)+	
	move		r0,x:ptr
_next	rts

search_hash:
	move		#>hash,a
	move			x:red,b
	move		#>$0F0,y0
	and		y0,b
	rep		#4
	lsl		b
	add		b,a	x:green,b
	move		#>$0F0,y0
	and		y0,b
	add		b,a	x:blue,b
	move		#>$0F0,y0
	and		y0,b
	rep		#4
	lsr		b
	add		b,a
	move		a,r0
	nop
	move		x:(r0),a
	rts	
	