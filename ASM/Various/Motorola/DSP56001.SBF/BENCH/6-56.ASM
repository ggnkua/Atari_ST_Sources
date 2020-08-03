	page 132,66,0,6
	opt	rc
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;8 pole cascaded transposed IIR filter
;File name: 6-56.asm
;**************************************************************************
;	Maximum sample rate: 292.9 Khz at 20.5 MHZ/ 385.7 KHz at 27.0 MHz
;	Memory Size: Prog: 9+11 words ; Data :4(2+5)=28 words
;	Number of clock cycles:	70 (35 instruction cycles)
;	Clock Frequency:	20.5MHz/27.0MHz
;	Cycle time:		97.5ns /  74.1ns
;**************************************************************************
;	This IIR filter reads the input sample
;	from the memory location Y:input
;	and writes the filtered output sample
;	to the memory location Y:output
;
;	The samples are stored in the X memory
;	The coefficients are stored in the Y memory
;**************************************************************************
;	initialization
;**********************
nsec	equ	4
start	equ	$40
wdd1	equ 	0	;w1,...
wdd2	equ 	8	;w2,...
cddr	equ 	0	;b0,b1,a1,b2,a2
input	equ	$ffe0
output	equ	$ffe1

;The filter equations are:
;    y  = x*bi0 + w1
;    w1 = x*bi1 + y*ai1 + w2
;    w2 = x*bi2 + y*a2
;
;   x  --------------bi0---->(+)--------------------> y
;               |             ^            |
;               |             | w1         |
;               |            1/z           |
;               |             |            |
;               |----bi1---->(+)<---ai1----|
;               |             ^            |
;               |             | w2         |								
;               |            1/z           |
;               |             |            |
;               |----bi2---->(+)<---ai2----|
;
;	Implemented in that way:
;
;	y/2 = bi0/2*x +w1/2
;	w1/2= bi1/2*x -ai1/2*y +w2/2
;	w2/2= bi2/2*x -ai2/2*y
;
;	r0 -> X:xddr->w1
;	r1 -> x:addr->w2
;	r4 -> Y:cddr 
;
	org	p:start
	move 	#wdd1,r0	;r0 -> w1
	move	#wdd2,r1	;r1 -> w2
	move	#cddr,r4	;r4 -> coefficients
	move	#nsec-1,m0
	move	m0,m1
	move	#5*nsec-1,m4
;
	ori	#$08,mr				;set scaling mode
	move	x:(r0),a	y:(r4)+,y0	;a=w1;b=b0/2
	asr	a				;a=w1/2
;
	opt	cc
;	filter loop: 7*nsec+7
;**********************************************
	movep 	y:input,y1			;input sample in y1
;	
	do	#nsec,filt
	macr	y1,y0,a	x:(r1),b  y:(r4)+,y0	;a=y/2=x*bi0/2+w1/2;get w2,bi1/2
	asr	b	a,x0	  		;b=w2/2; move y/2 to x0=y
	mac	y1,y0,b		  y:(r4)+,y0	;b=x*bi1/2+w2/2 ,get ai1/2
	macr	x0,y0,b		  y:(r4)+,y0	;b=b+y*ai1/2=w1/2, get bi2/2		
	mpy	y1,y0,b	b,x:(r0)+ y:(r4)+,y0	;b=x*bi2/2, save w1, get ai2/2
	macr	x0,y0,b	x:(r0),a  a,y1		;b=b+y*ai2/2=w2, get w1 ,y1=y
	asr	a	b,x:(r1)+ y:(r4)+,y0	;a=w1/2, save w2, get b(i+1)0
filt
	movep	y1,y:output			;output sample
;***********************************************
	end
