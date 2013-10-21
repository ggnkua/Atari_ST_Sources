	page 132,66,0,6
	opt	rc
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;64 tap FIR filter
;File name: 2-56.asm
;**************************************************************************
;	Maximum sample rate: 144.4 Khz at 20.5 MHZ/ 190.1 KHz at 27.0 MHz
;	Memory Size: Prog: 4+6 words ; Data :2 x 64 words
;	Number of clock cycles:	142 (71 instruction cycles)
;	Clock Frequency:	20.5MHz/27.0MHz
;	Cycle time:		97.5ns /  74.1ns
;**************************************************************************
;	This FIR filter reads the input sample
;	from the memory location Y:input
;	and writes the filtered output sample
;	to the memory location Y:output
;
;	The samples are stored in the X memory
;	The coefficients are stored in the Y memory
;**************************************************************************
;
;          X MEMORY                               Y MEMORY
;
;         |        |                             |        |
;    R0   |--------|                             |--------|
;  +----->|  X(n)  |                      +----->|  c(0)  |
;  |  t   |--------|                      |t,t+T |--------|
;  |      | X(n-1) |                      |      |  c(1)  |
;  |      |--------|                      |      |--------|
;  |      |        |                      |      |        |
;  |      |        |                      |      |        |
;  |      |        |                      |      |        |
;  |      |        |                      |      |        |
;  |      |--------|                      |      |--------|
;  +----->|X(n-k+1)|  X(n+1)              +<-----| c(k-1) |
;   t+T   |--------|                             |--------|
;         |        |                             |        |
;
;
;                              C(0)                      
;                              ___          ___
;    x(n)                     /   \        /   \         y(n)
;    -------------+----------|  X  |----->|  +  |--------->
;                 |           \___/        \___/
;                 |                          ^             k-1
;                 |                          |             ____
;              +-----+                       |             \   '
;              |  T  |         C(1)          |      y(n)=  /___,c(p)x(n-p)
;              +-----+         ___           |             p=0
;                 |           /   \          |
;                 +----------|  X  |-------->+  
;                 |           \___/          |
;              +-----+                       |
;              |  T  |         C(2)          |
;              +-----+         ___           |
;                 |           /   \          |
;                 +----------|  X  |-------->+   
;                 |           \___/          |
;                 |                          |
;                 |                          |
;                 |                          |
;                 |                          |
;                 |                          |
;                 |                          |
;              +-----+                       |
;              |  T  |         C(K-1)        |
;              +-----+         ___           |
;                 |           /   \          |
;                 +----------|  X  |-------->+     
;                             \___/
;
;
;                            F I R
;
;**************************************************************************
;
;	initialization
;**********************
n	equ	64
start	equ	$40
wddr	equ	$0
cddr	equ	$0
input	equ	$ffe0
output	equ	$ffe1
;
	org	p:start
	move 	#wddr,r0		;r0 -> samples
	move	#cddr,r4		;r4 -> coefficients
	move 	#n-1,m0			;set modulo arithmetic
	move	m0,m4			;for the 2 circular buffers
;
	opt	cc
;	filter loop :8+(n-1) cycles
;***************************************************************
	movep 	y:input,x:(r0)		;input sample in memory
	clr	a	x:(r0)+,x0	y:(r4)+,y0
 
	rep	#n-1
	mac	x0,y0,a	x:(r0)+,x0 	y:(r4)+,y0
	macr	x0,y0,a	(r0)-

	movep	a,y:output		;output filtered sample
;***************************************************************
	end


