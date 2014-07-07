; The following program performs a Radix 2, Decimation-In-Time 512 point 
; Fast Fourier Transform (FFT).

; This program is provided under a DISCLAMER OF WARRANTY available from 
; Motorola DSP Division, 6501 Wm. Cannon Drive W., Austin, Tx, 78735.

; Last Update 20 January 1992
 
; The Radix 2, Decimation-In-Time 512 point FFT reads data from EMI port 
; and writes results back to EMI port (using DSP56004 Y Data ROM sine-cosine 
; tables).

; 1.81 msec @ 40MHz, requires 184 words of P memory, however the code 
; contains 65 NOPs (waiting for emi data). These may be replaced by useful 
; instructions, giving an effective program length of 119 words.
 

; Radix 2 Decimation in Time Fast Fourier Transform Routine
;
;  Complex input and output data
;  Input and output data from EMI port
;  Normally ordered input data, data is in consecutive (real, imaginary) pairs
;  Bit reversed output data
;  Coefficient lookup table
;  Full cycle sinewave in Y memory
;
; Alters Data ALU Registers
;       x1      x0      y1      y0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0      n0      m0
;       r1      n1      m1
;               n2
;
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;       r7      n7      m7
;

; Alters Program Control Registers
;    pc      sr
;
; Uses 6 locations on System Stack
;
 
;*** EQUATES ***

points	equ	512	;number of points for fft
ebar0	equ	$ffe8	;base addr reg0
ebar1	equ	$ffec	;base addr reg1
ecsr	equ	$ffeb	;control/status reg
eor0	equ	$ffe9	;offset reg0
eor1	equ	$ffed	;offset reg1
edrr0	equ	$ffea	;data read reg0
edrr1	equ	$ffee	;data read reg1
edwr0	equ	$ffea	;data write reg0
edwr1	equ	$ffee 	;data write reg1
lowbase	equ	$0000	;base address of A emi data (1st pass)
upbase	equ	points	;base address of B emi data (1st pass)
table	equ	256	;size of sinewave table
data	equ	0	;starting address of data once in int. mem.
coef	equ	$100	;starting address of sine table in Y Rom
results	equ	$800	;emi base address of fft results (1st 256 pts)
result2 equ	$a00	;emi base address of fft results (2nd 256 pts)
 
	org	p:0
	jmp	start
	org	p:$100
;
;   ***** passes 2-9 of the fft *****
butterfly
	move    #table/4,n6	;initialize C pointer 
                 		;offset 
	move    n6,n7
	move    #-1,m0         	;initialize A and B 
				;address modifiers 
	move    m0,m1		;for linear addressing
        move    m0,m4
        move    m0,m5
       	move    m0,m7
        move    #0,m6          	;initialize C address modifier for 
				;reverse carry (bit-reversed) 
				;addressing
butterfly2
       	move    #points/4,n0 	;initialize butterflies per group
       	move    #1,n2          	;initialize groups per pass
 
;


; Perform 2nd - 9th FFT passes with triple nested DO loop
;
	do      #8,end_pass
	move    #data,r0  	;initialize A input pointer 
	move    r0,r4          	;initialize A output pointer
	lua     (r0)+n0,r1     	;initialize B input pointer
	move    #coef,r6       	;initialize C input pointer
	lua     (r1)-,r5       	;initialize B output pointer
       	move    n0,n1          	;initialize pointer offsets
       	move    n0,n4
       	move    n0,n5
 
       	do      n2,end_grp
     	move    r6,r7        		  ;get sine pointer
       	move    x:(r1),x1  y:(r6)+n6,y0	  ;lookup sine value
       	move    x:(r5),a   y:(r0),b	  ;preload data
       	move    	   y:(r7+n7),x0   ;lookup cosine value
 
 
       	do      n0,end_bfy     		  ;Radix 2 DIT butterfly kernel
       	mac     -x1,y0,b   y:(r1)+,y1
       	macr    x0,y1,b    a,x:(r5)+	y:(r0),a
       	subl    b,a        x:(r0),b	b,y:(r4)
       	mac     x1,x0,b    x:(r0)+,a	a,y:(r5)
        macr    y1,y0,b    x:(r1),x1
       	subl    b,a	   b,x:(r4)+	y:(r0),b
end_bfy
       	move    a,x:(r5)+n5     y:(r1)+n1,y1  	;update A and B pointers
       	move    x:(r0)+n0,x1    y:(r4)+n4,y1
end_grp
	move    n0,b1
	lsr  b  n2,a1		;divide butterflies per group by two
	lsl  a  b1,n0		;multiply groups per pass by two
       	move    a1,n2
end_pass
       	rts
 
; block move of complex data in 24-bit format from internal 
; memory x:00..ff, y:00..ff to EMI internal memory data consists 
; of 24-bit real data in x-memory and 24 bit imaginary data in y-memory
; data is normally ordered 

emwrite			; register `a' contains value of emi base address
 
size	equ	256	;block transfer size (number of x,y pairs)
base	equ	0000	;x,y-internal memory base address	
 
	move	#base,r7	;pointer for real,imag data
	movep	a,x:ebar0	;define emi base address
	movep	x:(r7),x:edwr0	;first write, real data
	movep	y:(r7)+,x:edwr0	;2nd write (pipelined), imag data
 
	do	#size-1,end_block
	nop
	nop			;wait for data write register empty
	nop
	movep	x:(r7),x:edwr0	;real data write
	nop
	nop
	nop
	nop
	movep	y:(r7)+,x:edwr0	;imag data write
	nop
end_block
	rts
 
; ******************************************
; Read data from EMI port and do first pass
; ******************************************
start	
	movep	#$80018d,x:ecsr	;emi enable, int. disable8 bit data bus, 
				;24 bit data word
				;ERTS=0, relative addr. mode 001
				;EBAR increment (read/write)
 
	movep	#lowbase,x:ebar0
	movep	#upbase,x:ebar1
	movep	#0,x:eor0	;trigger A read
	movep	#0,x:eor1	;trigger B read
	bset	#17,x:ecsr	;ERTS=1 (auto incr. read address)
	move	#0,r0		;output pointer to internal memory
 
;***** DO FIRST HALF OF FFT *****
;********************************
	do	#points/2-1,firstpass
	movep	x:edrr0,a	;read ar
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,x0	;read br
	add	x0,a		;cr'=ar+br
	move	a,x:(r0)	;store in internal x memory
	nop
	nop
	nop
	movep	x:edrr0,b	;read ai
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,y0	;read bi
	add	y0,b		;ci'=ai+bi
	move	b,y:(r0)+	;store in internal y memory
	nop
	nop
	nop
firstpass	
	
	movep	x:edrr0,a	;read last ar
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,x0	;read last br
	add	x0,a		;cr'=ar+br
	move	a,x:(r0)	;store in internal memory
	nop
	nop
	bclr	#17,x:ecsr	;turn ERTS off
	movep	x:edrr0,b	;read last ai
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,y0	;read last bi
	add	y0,b		;ci'=ai+bi
	move	b,y:(r0)	;store in internal memory	

; 256 complex data points are now stored in x,y internal memory
	
	jsr	butterfly	;do passes 2-9
	move	#results,a
	jsr	emwrite		;write results back to emi
 

;***** DO 2ND HALF OF THE FFT *****
;**********************************
 
	movep	#lowbase,x:ebar0
	movep	#upbase,x:ebar1
	movep	#0,x:eor0	;trigger A read
	movep	#0,x:eor1	;trigger B read
	bset	#17,x:ecsr	;ERTS=1 (auto incr. read address)
	move	#0,r0		;output pointer to internal memory
 
	do	#points/2-1,first_pass
	movep	x:edrr0,a	;read ar
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,x0	;read br
	sub	x0,a		;dr'=ar-br
	move	a,x:(r0)	;store in internal x memory
	nop
	nop
	nop
	movep	x:edrr0,b	;read ai
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,y0	;read bi
	sub	y0,b		;di'=ai-bi
	move	b,y:(r0)+	;store in internal y 
				;memory
	nop
	nop
	nop
first_pass	
	
	movep	x:edrr0,a	;read last ar
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,x0	;read last br
	sub	x0,a		;dr'=ar-br
	move	a,x:(r0)	;store in internal memory
	nop
	nop
	bclr	#17,x:ecsr	;turn ERTS off
 
	movep	x:edrr0,b	;read last ai
	nop
	nop
	nop
	nop
	nop
	movep	x:edrr1,y0	;read last bi
	sub	y0,b		;di'=ai-bi
	move	b,y:(r0)	;store in internal memory	
	nop
 
	jsr	butterfly2	;do passes 2-9
	move	#result2,a
	jsr	emwrite		;store results in emi
 
	end
