; This will run 100% in DSP internal P Memory! 
; High precision stuff, full 3*3 filter!

; basin dimentions: be sure not to make them too big!
; This might overflow the DSP RAM!
; Fucking dsp mixer limits this size smaller than a goddamn stamp!
WIDTH:		=	144
HEIGHT:		=	82
TOTALWIDTH:	=	WIDTH+2
TOTALHEIGHT:	=	HEIGHT+2

SCALAR:		=	1

get:	MACRO
__getl:
	jclr	#0,X:<<$FFE9,__getl
	movep	X:<<$FFEB,\1
	ENDM
send:	MACRO
__sendl:
	jclr	#1,X:<<$FFE9,__sendl
	movep	\1,X:<<$FFEB
	ENDM

	ORG	P:$0000
	jmp	<Main

	ORG	P:$0040
Main:	jsr	<clear_buffers

_loop:	jsr	<xupdate
	jsr	<drop_x
	jsr	<send_xbuffer

	jsr	<yupdate
	jsr	<drop_y
	jsr	<send_ybuffer

	jmp	<_loop

clear_buffers:
	move			#>TOTALWIDTH*TOTALHEIGHT+1,n7
	move			#>xbuf-(TOTALWIDTH+1),r0
	clr	a		#>ybuf-(TOTALWIDTH+1),r4
	do	n7,<_end_loop
_loop:	move			a,x:(r0)+	a,y:(r4)+
_end_loop:
	rts

send_ybuffer:
	move			#<2,n0
	move			#>ybuf+1,r0
	move			#>SCALAR,x1
	move					y:(r0)+,x0

	do	#<HEIGHT,_yloop

	do	#<WIDTH,_xloop
	mpy	x1,x0,a				y:(r0)+,x0
	send	a0
_xloop:

	move	(r0)+n0
_yloop:

	nop
	rts

send_xbuffer:
	move			#<2,n0
	move			#>xbuf+1,r0
	move			#>SCALAR,x1
	move			x:(r0)+,x0

	do	#<HEIGHT,_yloop

	do	#<WIDTH,_xloop
	mpy	x1,x0,a		x:(r0)+,x0
	send	a0
_xloop:

	move			(r0)+n0
_yloop:
	nop
	rts

xupdate:move			#>ybuf-TOTALWIDTH,r0		;top
	move			#>ybuf-1,r1			;left
	move			#>ybuf+1,r2			;right
	move			#>ybuf+TOTALWIDTH,r3		;bottom
	move			#>xbuf,r4			;current
	move			#>ybuf-TOTALWIDTH-1,r5		;left top
	move			#>ybuf+TOTALWIDTH-1,r6		;left bottom
	move			#<2,n2
	move			#<2,n3
	move			#<2,n4
	move			#<2,n5
	move			#<2,n6
	move			#<$7C,y1
	move			#<$20,x1

	do	#<HEIGHT,_yloop
	move					y:(r0)+,a	; get top
	move					y:(r1)+,y0	; get left

	do	#<WIDTH,_xloop
	add	y0,a				y:(r2)+,y0	; add left,get right
	add	y0,a				y:(r3)+,y0	; add right,get bottom
	add	y0,a				y:(r5)+,y0	; add right,get left top
	add	y0,a				y:(r6)+,y0	; add left top,get left bottom
	add	y0,a				y:(r0),y0	; add left bottom,get right top
	add	y0,a				y:(r3),y0	; add right top,get right bottom
	add	y0,a		x:(r4),b			; add right bottom,get destination
	move			a,x0
	mac	-x1,x0,b
	move			b,x0
	mpy	-y1,x0,a			y:(r1)+,y0
	move			a,x:(r4)+	y:(r0)+,a
_xloop:

	move			(r0)+
	move			(r1)+
	move			(r2)+n2
	move			(r3)+n3
	move			(r4)+n4
	move			(r5)+n5
	move			(r6)+n6
_yloop:
	nop
	rts

yupdate:move			#>xbuf-TOTALWIDTH,r0		;top
	move			#>xbuf-1,r1			;left
	move			#>xbuf+1,r2			;right
	move			#>xbuf+TOTALWIDTH,r3		;bottom
	move			#>ybuf,r4			;current
	move			#>xbuf-TOTALWIDTH-1,r5		;left top
	move			#>xbuf+TOTALWIDTH-1,r6		;left bottom
	move			#<2,n2
	move			#<2,n3
	move			#<2,n4
	move			#<2,n5
	move			#<2,n6
	move			#<$7C,y1
	move			#<$20,x1

	do	#<HEIGHT,_yloop
	move			x:(r0)+,a
	move			x:(r1)+,y0

	do	#<WIDTH,_xloop
	add	y0,a		x:(r2)+,y0
	add	y0,a		x:(r3)+,y0
	add	y0,a		x:(r5)+,y0			;add right,get left top
	add	y0,a		x:(r6)+,y0			;add left top,get left bottom
	add	y0,a		x:(r0),y0			;add left bottom,get right top
	add	y0,a		x:(r3),y0			;add right top,get right bottom
	add	y0,a				y:(r4),b
	move			a,x0
	mac	-x1,x0,b
	move			b,x0
	mpy	-y1,x0,a	x:(r1)+,y0
	move			x:(r0)+,a	a,y:(r4)+
_xloop:

	move			(r0)+
	move			(r1)+
	move			(r2)+n2
	move			(r3)+n3
	move			(r4)+n4
	move			(r5)+n5
	move			(r6)+n6
_yloop:
	nop
	rts

drop_x:	get	a
	tst	a
	jeq	<_end_loop
	move			a,n0
	move			#<xbuf,r1
	do	n0,<_end_loop

_loop:	get	n1
	get	x0
	move			x0,x:(r1+n1)
_end_loop:
	nop
	rts

drop_y:	get	a
	tst	a
	jeq	<_end_loop
	move			a,n0
	move			#<ybuf,r1
	do	n0,<_end_loop

_loop:	get	n1
	get	x0
	move			x0,y:(r1+n1)
_end_loop:
	nop
	rts

	ORG	X:$0000
	DS	TOTALWIDTH+1
xbuf:	DS	TOTALWIDTH*HEIGHT
	DS	TOTALWIDTH

	ORG	Y:$0000
	DS	TOTALWIDTH+1
ybuf:	DS	TOTALWIDTH*HEIGHT
	DS	TOTALWIDTH
