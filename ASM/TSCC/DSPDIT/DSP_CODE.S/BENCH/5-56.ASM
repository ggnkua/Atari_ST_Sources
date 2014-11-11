	page 132,66,0,6
	opt	rc
;*******************************************
;Motorola Austin DSP Operation  June 30,1988
;*******************************************
;DSP56000/1
;8 pole 5 multiply cascaded canonic IIR filter
;File name: 5-56.asm
;**************************************************************************
;	Maximum sample rate: 353.5 Khz at 20.5 MHZ/ 465.5 KHz at 27.0 MHz
;	Memory Size: Prog: 6+11 words ; Data :4*(2+5) words
;	Number of clock cycles:	58 (29 instruction cycles)
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
;
;	The equations of the filer are:
;       w(n) =    x(n) - ai1*w(n-1) - ai2*w(n-2)
;       y(n) = b0*w(n) + bi1*w(n-1) + bi2*w(n-2)
;
;		             w(n)
;   x (n)------(-)---------->-|->---bi0---(+)-------> y(n)
;               A             |            A
;               |            1/z           |
;               |             | w(n-1)     |
;               |             v            |
;               |-<--ai1----<-|->---bi1-->-|
;               |             |            |
;               |            1/z           |
;               |             | w(n-2)     |
;               |             v            |
;               |-<--ai2----<--->---bi2-->-|
;
;
;	All coefficents are divided by 2:
;	w(n)/2=      x(n)/2 - ai1/2*w(n-1) -ai2/2*w(n-2)
;	y(n)/2= bi0/1*w(n)/2 + bi1/2*w(n-1) +bi2/2*w(n-2)
;
;       X Memory Organization            Y Memory Organization
;					       |   b0N/2 | Coef. + 5*nsec-1
;         |         |                          |   b1N/2 |
;         |         |                          |   b2N/2 |
;         |         |                          |   a1N/2 |
;         |         |                          |   a2N/2 |
;         | wN(n-1) | Data + 2*nsec-1          |    .    |
;         | wN(n-2) |                          |   b01/2 |
;         |   .     |                          |   b11/2 |
;         |   .     |                          |   b21/2 |
;         | w1(n-1) |                          |   a11/2 |
;    R0 ->| w1(n-2) | Data                R4 ->|   a21/2 | Coef.
;         |         |                          |         |
;
;*************************************************************************
;
;	initialization
;**********************
nsec	equ	4
start	equ	$40
data	equ	0
coef	equ	0
input	equ	$ffe0
output  equ	$ffe1
igain	equ	0.5

    ori     #$08,mr		      ;set scaling mode
    move    #data,r0                  ;point to filter states
    move    #coef,r4		      ;point to filter coefficients
    move    #2*nsec-1,m0                                  
    move    #4*nsec-1,m4                                      
    move    #igain,y1                 ;y1=initial gain
;
    opt     cc
;      filter loop: 5*nsec+9
;*************************************************                                   
    movep   y:input,y0		                 ;get sample
    mpy    y0,y1,a	 x:(r0)+,x0  y:(r4)+,y0  ;x0=1st section w(n-2),y0=a12/2
;
    do	   #nsec,_ends				 ;do each section
    mac    -x0,y0,a	 x:(r0)-,x1  y:(r4)+,y0  ;x1=w(n-1) ,y0=ai1/2
    macr   -x1,y0,a	 x1,x:(r0)+  y:(r4)+,y0  ;push w(n-1) to w(n-2),y0=bi2/2
    mac    x0,y0,a	 a,x:(r0)    y:(r4)+,y0  ;push w(n) to w(n-1),y0=bi1/2
    mac    x1,y0,a	 x:(r0)+,x0  y:(r4)+,y0  :get this iter w(n),y0=bi0/2
    mac    x0,y0,a	 x:(r0)+,x0  y:(r4)+,y0  ;next iter:x0=w(n-2),y0=ai2/2
_ends
    rnd    a			      ;round result
    movep		a,y:output    ;output sample
;*************************************************                                   
    end

