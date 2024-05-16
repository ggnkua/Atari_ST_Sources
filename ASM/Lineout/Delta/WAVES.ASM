;======== GLOBAL MACROS ========

get:	MACRO
	jclr	#0,X:<<$FFE9,*
	movep	X:<<$FFEB,\1
	ENDM

send:	MACRO
	jclr	#1,X:<<$FFE9,*
	movep	\1,X:<<$FFEB
	ENDM

;======== P-Memory Code ========

	ORG	P:$0000
	jmp	<Waves

	ORG	P:$0040
Waves:	jsr	<fillTable
	jsr	<receiveRadiusMap
_loop:	jsr	<receiveWaveTable
	jsr	<sendWaves
	jmp	<_loop

fillTable:
	move			#<xTable,r0
	move			#>-80,a
	move			#>1,x0
	do	#160,_loop
	add	x0,a		a1,x:(r0)+
_loop:	rts

receiveRadiusMap:
	move			#<radiusMap,r0
	move			#>80*100,x0
	do	x0,_loop
	get	y:(r0)+
_loop:	rts

receiveWaveTable:
	move			#<waveTable,r0
	do	#>95,_loop
	get	x:(r0)
	get	y:(r0)+
_loop:	rts

sendWaves:
	move			#<radiusMap,r0
	move			#<waveTable,r1
	move			#<$80,r4			; r4=ny scalar
	move			#<81,n0
	move			#>-50,y0			; y0=ycount=-50

	do	#100,_yloop
	move					y:(r0)+,n1	; n1 = radius
	move			#<xTable,r3
	move			l:(r1+n1),x

	do	#80,_xloop
	mpy	+x0,y0,a	x:(r3)+,y1			; a = sin*y = nx
	macr	+x1,y1,a			y:(r0)+,n1	; a = cos*x+sin*y = nx, n1 = radius
	mpy	-x0,y1,b	a1,a0				; b = -sin*x
	macr	+x1,y0,b	r4,x0				; b = -sin*x+cos*y = ny, x0 = ny scalar
	move			b1,x1				; x1 = ny
	mac	+x0,x1,a	l:(r1+n1),x			; a = scaled ny + scaled nx = offset, x0=1
	send	a0						; Send offset to host.
_xloop:
; b = 1
	move			(r0)-
	move					y:-(r0),n1
	nop
	move			l:(r1+n1),x

	do	#80,_xloop2
	mpy	+x0,y0,a	x:(r3)+,y1			; a = sin*y
	macr	+x1,y1,a			y:-(r0),n1	; a = cos*x+sin*y = nx, n1 = radius
	mpy	-x0,y1,b	a1,a0				; b = -sin*x
	macr	+x1,y0,b	r4,x0				; b = -sin*x+cos*y = ny, x0 = ny scalar
	move			b1,x1				; x1 = ny
	mac	+x0,x1,a	l:(r1+n1),x			; a = scaled ny + scaled nx = offset, x0=1
	send	a0						; Send offset to host.
_xloop2:
	
; Increase ycount..
	move			#<1,b1
	add	y0,b		(r0)+n0				; r0: next line in radiusmap
	move			b1,y0
_yloop:	rts

;======== X Memory ========

	ORG	X:$0000

count:	DS	1
waveTable:
	DS	95
xTable:	DS	160						; contains -80,-79,...+79

;======== Y Memory ========

	ORG	Y:95

	DS	1
radiusMap:
	DS	80*100
