;
;	From NEXT dsp book page 7-4, take input, shift right, send it out
;

PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	start

	org	P:$40

start	
	move	#0,y0
	move	#0,a
	movep	#1,X:PBC		;  sinus teta dans x1
	jclr	#0,x:HSR,start
	move	x:HTX,a0
	asl	a	


	bset	#11,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next11	
	bclr	#11,y0
next11
	bset	#10,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next10	
	bclr	#10,y0
next10
	bset	#9,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next9	
	bclr	#9,y0
next9
	bset	#8,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next8	
	bclr	#8,y0
next8
	bset	#7,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next7	
	bclr	#7,y0
next7
	bset	#6,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next6	
	bclr	#6,y0
next6
	bset	#5,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next5	
	bclr	#5,y0
next5
	bset	#4,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next4	
	bclr	#4,y0
next4
	bset	#3,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next3
	bclr	#3,y0
next3
	bset	#2,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next2
	bclr	#2,y0
next2
	bset	#1,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next1
	bclr	#1,y0
next1
	bset	#0,y0
	mpy	y0,y0,b
	cmp	a,b
	jle	next0	
	bclr	#0,y0
next0
xmit1	jclr	#1,X:HSR,xmit1
	move	y0,X:HTX

fin_loop	

	jmp	start


