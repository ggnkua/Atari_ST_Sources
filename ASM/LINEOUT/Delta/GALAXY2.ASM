; Dsp mass point rotator and clipper, by earx.

;======== GLOBAL MACROS ========

get:	MACRO
	jclr	#0,x:<<$FFE9,*
	movep	x:<<$FFEB,\1
	ENDM

send:	MACRO
	jclr	#1,x:<<$FFE9,*
	movep	\1,x:<<$FFEB
	ENDM

	ORG	P:$0000
	jmp	<START

	ORG	P:$0040

START:	
; Loop it..
_loop:
; Initialize..
	jsr	<receivePoints

	get	x:>amount
	move			#<sinX,r0
	move			#<cosX,r1
	move			#<sinY,r2
	move			#<cosY,r3
	move			#<sinZ,r4
	move			#<cosZ,r5
	jsr	<receiveRotation
	jsr	<Matrix.generate
	jsr	<rotate
	jmp	<_loop

receivePoints:
	get	a
	tst	a		#>points,r0
	jeq	<_loop

	do	a,_loop
	get	y:(r0)+
	get	y:(r0)+
	get	y:(r0)+
_loop:
	rts

; Receives rotation cos/sin values from CPU.
; INPUT:
; r0: X-sine
; r1: X-cosine
; r2: Y-sine
; r3: Y-cosine
; r4: Z-sine
; r5: Z-cosine
receiveRotation:
	get	x:(r0)
	get	x:(r1)
	get	x:(r2)
	get	x:(r3)
	get	y:(r4)
	get	y:(r5)
	rts

rotate:	get	x:>center					; Read center from host.
	move			#<points,r0
	move			#<transformed,r1
	move			#<matrix,r4
	movec			#<2*3-1,m4
	move			#<wh,r2
	move			#<wh,r5
	move			x:(r4)+,x0	y:(r0)+,y0	; x0 = MXX, y0 = x
	mpy	x0,y0,a		x:(r4)+,x0	y:(r0)+,y1	; x * MXX +

; Transform all points.
	do	x:<amount,_rotate_loop
	mac	x0,y1,a		x:(r4)+,x0	y:(r0)-,y1	; y * MXY +
	mac	x0,y1,a		x:(r4)+,x0			; z * MXZ, a=X
	mpy	x0,y0,b		x:(r4)+,x0	y:(r0)+,y1	; x * MYX +
	mac	x0,y1,b		x:(r4)+,x0	y:(r0)+,y1	; y * MYY +
	mac	x0,y1,b		x:(r4)+,x0	y:(r2),y0	; z * MYZ, b=Y, y0=height/2
	cmpm	y0,b		x:(r5),x1	y:(r0)+,y0	; x1=width/2 ,y0=x
	jhs	<_next
	cmpm	x1,a
	jhs	<_next
	move			a,x:(r1)+
	move			b,x:(r1)+
_next:	mpy	x0,y0,a		x:(r4)+,x0	y:(r0)+,y1	; x * MXX +
_rotate_loop:

	movec			#$FFFF,m4
	move			#<2,n1
	move			#<2,n3
	move			r1,a
	move			#>transformed,x0
	sub	x0,a		x:<scrwidth,x1			; x1 = width/2
	asr	a		x0,r1				; r1: x_table
	move			x0,r3				; r3: x_table
	move			#>$FFEB,r2			; r2: HTX
	move			(r3)+				; r3: y_table
	move			x:(r1)+n1,b0			; b0 = X1
	move			x:(r3)+n3,y1			; y1 = Y1
	move			a1,n0
	send	a1						; Send amount of visible dots.
	move			x:<center,x0			; x1 = screencenter

; Send all of them!
	do	n0,_sendloop
	mac	x1,y1,b		x:(r3)+n3,y1			; b0 = Y*width+X
	move			b0,a				; a = Y*width+X
	lsl	a						; a = 2(Y*width+X)
	add	x0,a		x:(r1)+n1,b0			; a = 2(Y*width+X)+center
	jclr	#1,x:<<$FFE9,*
	move			a1,x:(r2)
_sendloop:

	rts

; INPUT:
; r0: X-sine
; r1: X-cosine
; r2: Y-sine
; r3: Y-cosine
; r4: Z-sine
; r5: Z-cosine
Matrix.generate:
	move			#<matrix,r6

; XX := + x*cos(b)*cos(c)
; XY := - y*cos(b)*sin(c)
; XZ := + z*sin(b)
	move			x:(r3),x1	y:(r5),y1
; x0:-- x1:r3 y0:-- y1:r5
	mpyr	+x1,y1,a	x:(r0),x0	y:(r4),y0	; r3*r5

	move			a,x:(r6)+

; x0:r0 x1:r3 y0:r4 y1:r5
	mpyr	-x1,y0,a	x:(r2),x1			; -r3*r4
; x0:r0 x1:r3 y0:r2 y1:r5

	move			a,x:(r6)+
	move			x1,x:(r6)+			; r2
	
; YX := + x*sin(a)*sin(b)*cos(c)+cos(a)*sin(c)
; YY := + y*cos(a)*cos(c)-sin(a)*sin(b)*sin(c)
; YZ := - z*sin(a)*cos(b)
	mpyr	+x0,x1,a			y:(r5),y0	; r0*r2
; x0:r0 x1:r3 y0:r5 y1:r5
	move			a,y1
	mpy	+y0,y1,a	x:(r1),x1	y:(r4),y1	; a*r5
; x0:r0 x1:r1 y0:r5 y1:r4
	macr	+x1,y1,a			y:(r5),y1	; a+r1*r4
; x0:r0 x1:r1 y0:r5 y1:r5

	move			a,x:(r6)+

	mpy	+x1,y1,a	x:(r2),x1			; r1*r5
; x0:r0 x1:r2 y0:r5 y1:r5

	mpyr	-x0,x1,b			y:(r4),y0	; r0*r2
; x0:r0 x1:r2 y0:r4 y1:r5
	move			b,y1
	macr	+y0,y1,a	x:(r3),x1	y:(r4),y1	; a+b*r4
; x0:r0 x1:r3 y0:r4 y1:r4

	move			a,x:(r6)+

	mpyr	-x0,x1,a	x:(r2),x1			; r0*r3
; x0:r0 x1:r2 y0:r4 y1:r4

	move			a,x:(r6)+
	rts

;== X RAM ====================================================================

		ORG	X:$0000

wh:		DC	300/2					; width/2
amount:		DS	1
transAmount:	DS	1
center:		DS	1
sinX:		DS	1
cosX:		DS	1
sinY:		DS	1
cosY:		DS	1
matrix:		DS	2*3					; Must be 8word aligned!
scrwidth:	DC	320/2
transformed:	DS	5100*2

;== Y RAM ====================================================================

		ORG	Y:$0000

		DC	200/2					; height/2
sinZ:		DS	1
cosZ:		DS	1
points:		DS	5100*3