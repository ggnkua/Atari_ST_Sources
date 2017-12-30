get:	MACRO
	jclr	#0,X:<<$FFE9,*
	movep	X:<<$FFEB,\1
	ENDM

send:	MACRO
	jclr	#1,X:<<$FFE9,*
	movep	\1,X:<<$FFEB
	ENDM

ITERATIONS:	=	32

	ORG	P:$0000
	jmp	<start

	ORG	P:$0040

start:	move			#<jx,r0
	do	#8,_loop
	get	x:(r0)+
_loop:	jsr	<calcJulia
	jmp	<start

calcJulia:
	move			#>$FFEB,r1
	move			x:<lx,a
	move			a1,x:<vx
	move			x:<ty,b
	move			b1,x:<vy
	do	#50,_yloop

	move			x:<vx,a
	move			a1,x:<hx
	move			x:<vy,b
	move			b1,x:<hy
	do	#160,_xloop

	move			x:<hx,x0
	move			x:<hy,b
	move			x:<jx,a
	andi	#%10111111,ccr					; Clear limit bit.
	do	#ITERATIONS,_iteration_loop

; r0=#iterations done
; f(c,n) = f(c,n-1)^2 + j, f(c,0) = c
; Calculate f(c,n-1)^2 = x*x-y*y + i(x*y+x*y)
; |C| = |X + i*Y| = sqrt(X*X+Y*Y) < 2.0; faster: |C|^2 = (X*X+Y*Y) < 4.0
; Blah. That circle check takes too much time, better use 1d check!
	mac	+x0,x0,a	b,y0				; a=(xn^2+jx)/4, y0=yn/2
	jls	<_end_iterations				; Limiting ? (=> divergence)
	macr	-y0,y0,a	x:<jy,b				; a=(xn^2-yn^2+jx)/4, b=jy/8
	macr	+x0,y0,b	a,x0				; b=(xn*yn+jy/2)/4, x0=x(n+1)/2
	asl	b		x:<jx,a				; b=y(n+1)/4, a=jx/4
_iteration_loop:
	clr	a
	jclr	#1,x:<<$FFE9,*
	move			a,x:(r1)			; Write #iterations
	jmp	<_yeah
_end_iterations:
	jclr	#1,x:<<$FFE9,*
	movec			lc,x:(r1)			; Write #iterations
	enddo

_yeah:	move			x:<hx,a
	move			x:<hdx,x0
	add	x0,a						; a=cx+dx
	move			a1,x:<hx
_xloop:

	move			x:<vy,b
	move			x:<vdy,y0
	add	y0,b						; b=cy+dy
	move			b1,x:<vy
_yloop:
	rts

;== INTERNAL X RAM ==========================================================

	ORG	X:$0000

jx:	DS	1						; re julia param
jy:	DS	1						; im julia param
lx:	DS	1						; left x
ty:	DS	1						; top y
hdx:	DS	1						; horizontal x step
hdy:	DS	1						; horizontal y step
vdx:	DS	1						; vertical x step
vdy:	DS	1						; vertical y step
hx:	DS	1						; horizontal x
hy:	DS	1						; horizontal y
vx:	DS	1						; vertical x
vy:	DS	1						; vertical y