; DSP matrix-water + voxel routine, by earx 2001/2002.
; Accuracy of 'crosshair' filter is high enough for this voxel.
; Now uses prerendering of column, to parallelise.
; Correct clipping.

HSR:		=	$FFE9
HTX:		=	$FFEB

; basin dimensions: be sure not to make them too big!
; This might overflow the DSP RAM!
WIDTH:		=	150
HEIGHT:		=	78
TOTALWIDTH:	=	WIDTH+1
TOTALHEIGHT:	=	HEIGHT+1
BASINSIZE:	=	TOTALWIDTH*TOTALHEIGHT

get:	MACRO
	jclr	#0,x:<<HSR,*
	movep	x:<<HTX,\1
	ENDM

send:	MACRO
	jclr	#1,x:<<HSR,*
	movep	\1,x:<<HTX
	ENDM

	ORG	P:$0000
	jmp	<start

	ORG	P:$0040
start:	movec	#$FFFF,m0
	movec	#BASINSIZE-1,m3					; Use modulo on bottom pointer.
	movec	m0,m1
	movec	m0,m2
	movec	m0,m4
	movec	m0,m6
	jsr	<clearBuffers
	jsr	<receivePal

_loop:	jsr	<updateX
	jsr	<dropOnX
	jsr	<sendXVoxel

	jsr	<updateY
	jsr	<dropOnY
	jsr	<sendYVoxel

	jmp	<_loop

clearBuffers:
	move			#>BASINSIZE,x0
	clr	a		#<0,r0
	do	x0,<_end_loop
_loop:	move			a,l:(r0)+
_end_loop:
	rts

sendYVoxel:
	move			#>TOTALWIDTH*HEIGHT,r0
	move			#<TOTALWIDTH,n2
	move			#>pal+TOTALHEIGHT,r5
	move			#>100,y0			; y0=max y
	move			#<$10,x1			; x1=scalar (anti-noise!)

	do	#WIDTH,_columnloop

; We render the column to dsp mem..
	move			#columnTable,r6
	move			r0,r2				; b=top=0
	move			#<1,r1				; r1=depth=0
	clr	a				y:(r2)-n2,x0	; x0=1st raw height
	clr	b		r1,a

	do	#HEIGHT,_zloop
	macr	x1,x0,a		(r1)+				; a=height, y1=depth
	cmp	y0,a		r1,y1				; Test if height is beyond screen, r1=depth+1
	jlt	<_go_on
	enddo
	move			y0,a
_go_on:	sub	b,a						; a=segheight
	jle	<_next
	add	a,b		a,n1
	move			x0,a				; b=new top, a=raw height
	sub	y1,a						; a=shade=raw height - depth, n1=segheight
	asr	a
	asr	a
	rep	n1						; Render #segheight pixels.
	move			a,x:(r6)+
_next:	tfr	y1,a				y:(r2)-n2,x0	; a=depth+1, x0=next raw height
_zloop:	

; We send the column to host.
	move			#columnTable,n6
	move			#columnTable,r4
	move			(r6)-n6				; r6=columnheight
	send	r6						; Send columnheight.
	do	r6,_send_loop
	move			x:(r4)+,n5			; n5=shade
	send	y:(r5+n5)					; Send pixel.
_send_loop:

	move			(r0)+				; Next column..
_columnloop:

	rts

sendXVoxel:
	move			#>TOTALWIDTH*HEIGHT,r0
	move			#<TOTALWIDTH,n2
	move			#>pal+TOTALHEIGHT,r5
	move			#>100,y0			; y0=max y
	move			#<$10,x1			; x1=scalar (anti-noise!)

	do	#WIDTH,_columnloop
	move			#columnTable,r6
	move			r0,r2				; b=top=0
	move			#<1,r1				; r1=depth=0
	move			x:(r2)-n2,x0			; x0=1st raw height
	clr	b		r1,a

	do	#HEIGHT,_zloop
	macr	x1,x0,a		(r1)+				; a=height, y1=depth
	cmp	y0,a		r1,y1				; Test if height is beyond screen, r1=depth+1
	jlt	<_go_on
	enddo
	move			y0,a
_go_on:	sub	b,a						; a=segheight
	jle	<_next
	move			a,n1
	add	a,b		x0,a				; b=new top, a=raw height
	sub	y1,a						; a=shade=raw height - depth, n1=segheight
	asr	a
	asr	a
	rep	n1
	move			a,x:(r6)+
_next:	tfr	y1,a		x:(r2)-n2,x0			; a=depth+1, x0=next raw height
_zloop:	

; We send the column to host.
	move			#columnTable,n6
	move			#columnTable,r4
	move			(r6)-n6				; r6=columnheight
	send	r6						; Send columnheight.
	do	r6,_send_loop
	move			x:(r4)+,n5			; n5=shade
	send	y:(r5+n5)					; Send pixel.
_send_loop:

	move			(r0)+				; Next column..
_columnloop:
	rts

updateX:move			#<0,r0				;top
	move			#<ybuf-1,r1			;left
	move			#<ybuf+1,r2			;right
	move			#>ybuf+TOTALWIDTH,r3		;bottom
	move			#<xbuf,r4			;current
	move			#<$40,x1
	move			#<$7E,y1

	do	#<HEIGHT,_yloop
	move					y:(r0)+,b	; get top
	move					y:(r1)+,y0	; get left
	add	y0,b				y:(r3)+,y0
	add	y0,b				y:(r2)+,y0

	do	#<WIDTH,_xloop
	add	y0,b		x:(r4),a
	move			b,x0		y:(r0)+,b
	mac	-x1,x0,a			y:(r1)+,y0
	add	y0,b		a,x0		y:(r3)+,y0
	mpy	-y1,x0,a
	add	y0,b		a,x:(r4)+	y:(r2)+,y0
_xloop:

	move			(r4)+
_yloop:
	rts

updateY:move			#<0,r0				;top
	move			#<xbuf-1,r1			;left
	move			#<xbuf+1,r2			;right
	move			#>xbuf+TOTALWIDTH,r3		;bottom
	move			#<ybuf,r4			;current
	move			#<$40,x1
	move			#<$7E,y1

	do	#<HEIGHT,_yloop
	move			x:(r0)+,b			; get top
	move			x:(r1)+,x0			; get left
	add	x0,b		x:(r3)+,x0
	add	x0,b		x:(r2)+,x0

	do	#<WIDTH,_xloop
	add	x0,b				y:(r4),a
	move			x:(r0)+,b	b,y0
	mac	-x1,y0,a	x:(r1)+,x0
	add	x0,b		x:(r3)+,x0	a,y0
	mpy	-y1,y0,a
	add	x0,b		x:(r2)+,x0	a,y:(r4)+
_xloop:

	move			(r4)+
_yloop:
	rts

dropOnX:get	a
	tst	a		#<xbuf,r1
	jeq	<_end
	jmi	<_get_block
	move			a,n0
	do	n0,<_loop

	get	n1
	get	x:(r1+n1)
_loop:	rts

; Gets (in sequential order): x, y, width, height, amp, blockdata.
_get_block:
	get	x0						; x0=lx
	get	y0						; y0=ty
	move			#<xbuf,r0
	move			#>TOTALWIDTH,x1
	mpy	x1,y0,a		#>HTX,r1
	asr	a						; a0=ty*TOTALWIDTH
	move			a0,a				; a=ty*TOTALWIDTH
	add	x0,a						; a=ty*TOTALWIDTH+lx=offset
	move			a,n0				; n0=offset
	move			x1,a				; a=TOTALWIDTH
	get	x1						; x1=width
	get	y1						; y1=height
	get	y0						; y0=amp
	move			(r0)+n0				; a=TOTALWIDTH-width=offset to next line, r0=start in buffer
	move			r0,r2
	move			#>TOTALWIDTH,n2			; n2=offset to next line

	do	y1,_yloop

	clr	b						; b=pixelcount=0

_block_loop:
	jclr	#0,x:<<HSR,*
	move			x:(r1),y1
	move			y1,n0
	jset	#15,y1,_masked
; Receive some void..
	move			(r0)+n0
	jmp	<_next
; Receive some pixels..
_masked:bclr	#15,y1

	do	y1,_pixel_loop
	jclr	#0,x:<<HSR,*
	move			x:(r1),x0
	mpy	x0,y0,a
	move			a,x:(r0)+
_pixel_loop:

_next:	add	y1,b
	cmp	x1,b
	jlt	<_block_loop

	move			(r2)+n2
	move			r2,r0
_yloop:

_end:	rts

dropOnY:get	a
	tst	a		#<ybuf,r1
	jeq	<_end
	jmi	<_get_block
	move			a,n0
	do	n0,<_loop

	get	n1
	get	y:(r1+n1)
_loop:	rts

; Gets (in sequential order): x, y, width, height, amp, blockdata.
_get_block:
	get	x0						; x0=lx
	get	y0						; y0=ty
	move			#<xbuf,r0
	move			#>TOTALWIDTH,x1
	mpy	x1,y0,a		#>HTX,r1
	asr	a						; a0=ty*TOTALWIDTH
	move			a0,a				; a=ty*TOTALWIDTH
	add	x0,a						; a=ty*TOTALWIDTH+lx=offset
	move			a,n0				; n0=offset
	get	x1						; x1=width
	get	y1						; y1=height
	get	y0						; y0=amp
	move			(r0)+n0				; a=TOTALWIDTH-width=offset to next line, r0=start in buffer
	move			r0,r2
	move			#>TOTALWIDTH,n2			; n2=offset to next line

	do	y1,_yloop

	clr	b						; b=pixelcount=0

_block_loop:
	jclr	#0,x:<<HSR,*
	move			x:(r1),y1
	move			y1,n0
	jset	#15,y1,_masked
; Receive some void..
	move			(r0)+n0
	jmp	<_next
; Receive some pixels..
_masked:bclr	#15,y1

	do	y1,_pixel_loop
	jclr	#0,x:<<HSR,*
	move			x:(r1),x0
	mpy	x0,y0,a
	move					a,y:(r0)+
_pixel_loop:

_next:	add	y1,b
	cmp	x1,b
	jlt	<_block_loop

	move			(r2)+n2
	move			r2,r0
_yloop:

_end:	rts

receivePal:
	move			#pal,r0
	do	#256,_loop
	get	y:(r0)+
_loop:	rts

	ORG	X:$0000
	DS	TOTALWIDTH
xbuf:	DS	TOTALWIDTH*HEIGHT
columnTable:
	DS	100

	ORG	Y:$0000
	DS	TOTALWIDTH
ybuf:	DS	TOTALWIDTH*HEIGHT
pal:	DS	256