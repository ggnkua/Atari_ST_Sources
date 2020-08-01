x_ffe0	equ	$ffe0
x_ffe9	equ	$ffe9
x_ffeb	equ	$ffeb
	org	p:$0000

	jmp	start
	org	p:$0040

start	movep	#>1,x:<<x_ffe0
	bset	#2,omr
Main	move	#$1000,r0
	move	#$100,a
	do	#$ce,recloop
Wait1	jclr	#0,x:<<x_ffe9,Wait1
	movep	x:<<x_ffeb,a
	move	a,x:(r0)
Wait2	jclr	#0,x:<<x_ffe9,Wait2
	move	x:x_ffeb,a
	clr	a
	move	a,y:(r0)+
Wait3	jclr	#0,x:<<x_ffe9,Wait3
Wait4	jclr	#0,x:<<x_ffe9,Wait4
recloop	move	#<-$80,n0
	move	#<1,n2
	move	#<$40,n6
	move	n6,n7
	movec	#-1,m0
	movec	m0,m1
	movec	m0,m4
	movec	m0,m5
	movec	m0,m7
	movec	#0,m6
	do	#8,p_0082
	move	#$1000,r0
	move	r0,r4
	lua	(r0)+n0,r1
	move	#$100,r6
	lua	(r1)-,r5
	move	n0,n1
	move	n0,n4
	move	n0,n5
	do	#$da,p_007e
	move	r6,r7
	move	x:(r1)-n1,x1	y:(r6)+n6,y0
	move	x:(r5)-n5,a	y:(r0)-n0,b
	move	y:(r7+n7),x0
	do	#$d8,p_007c
	mac	x1,y0,b	y:(r1)+,y1
	macr	x0,y1,b	a,x:(r5)+	y:(r0)-n0,a
	subl	b,a	x:(r0)-n0,b	b,y:(r4)-n4
	mac	x1,x0,b	x:(r0)+,a	a,y:(r5)-n5
	macr	y1,y0,b	x:(r1),x1
	subl	b,a	b,x:(r4)+	y:(r0)-n0,b
p_007c	move	a,x:(r5)+n5	y:(r1)+n1,y1
	move	x:(r0)+n0,x1	y:(r4)+n4,y1
p_007e	move	n0,b1
	lsr	b	n2,a1
	lsl	a	b1,n0
	move	a1,n2
p_0082	movec	#0,m2
	move	#<-$80,n2
	move	#$1000,r2
	movec	#-1,m3
	move	#$1100,r3
	do	#$80,bloop
	move	x:(r2),a
	move	a,x0
	mpy	x0,x0,a
	move	y:(r2)+n2,b
	move	b,x0
	mpy	x0,x0,b
	add	b,a
	jsr	sqrt
	move	a,x:(r3)+
bloop	movec	#-1,m2
	move	#$1100,r2
	do	#$80,playloop
Loop1	jclr	#1,x:<<x_ffe9,Loop1
	move	x:(r2)+,a
	movep	a,x:<<x_ffeb
playloop	movec	#-1,m0
	jmp	<Main
sqrt	clr	b	#>1,x1
	move	b,r0
	move	a1,b0
	move	#<2,n1
	do	#$c,end
	asl	b	r0,n0
	asl	b
	tfr	x1,y0,b	(r0)+n0
	sub	x1,a	r0,r1
	move	r0,x0
	sub	x0,a	(r1)+n1
	tpl	a,b	r1,r0
end	move	r0,a
	asr	a
	rts
