	ORG	P:$0000
	jmp	START

	ORG	P:$0040
START:	move	#40*40,a0
	jsr	CALC_ATARISQRT
	stop

; INPUT: a: value to calculate the squareroot of (integer)
; OUTPUT: a: squareroot of value (12.12 fixed point)
CALC_ATARISQRT:
	move	#12,n0
	move	#$400000,b0

	do	n0,_loop1
	cmp	b,a
	jls	<_loop1on
	enddo
	jmp	<_loop1
_loop1on:
	asl	a
	lsr	b
_loop1:

	sub	b,a	b,x0
	tfr	x0,b	b,y0
	lsr	b

	do	n0,_loop2
	lsr	b
	add	b,a
	tfr	y0,b	b,x0
	cmp	a,b
	jgt	<_loop2else
	sub	x0,a
	asl	b
	jmp	<_loop2end
_loop2else:
	subl	a,b
	add	x0,a
_loop2end:
	tfr	x0,b	b,y0
_loop2:

	asl	a	#$008000,x0
	add	x0,a
	rts