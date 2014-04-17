	page	132,60,1,1
fftr2aa	macro	points,data,coef
fftr2aa	ident	1,2
; This routine can be used with automatic scaling down turned on
; (S1=0, S0=1). In that case, place the (real) input data in the
; high portion of the accumulator.
; Radix 2 Decimation in Time In-Place Fast Fourier Transform Routine
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Bit reversed output data
;	Coefficient lookup table
;        -Cosine value in X memory
;        -Sine value in Y memory
;
; Macro Call - fftr2a   points,data,coef
;
;	points     number of points (2-32768, power of 2)
;	data       start of data buffer
;	coef	   start of sine/cosine table
;
; Alters Data ALU Registers
;	x1	x0	y1	y0
;	a2	a1	a0	a
;	b2	b1	b0	b
;
; Alters Address Registers
;	r0	n0	m0
;	r1	n1	m1
;	r2	n2
;
;	r4	n4	m4
;	r5	n5	m5
;	r6	n6	m6
;
; Alters Program Control Registers
;	pc	sr
;
; Uses 6 locations on System Stack
;
; Tested and verified - April 4, 1988
;
	move 	#points/2,n1	;initialize butterflies per group
	move	#1,n2		;initialize groups per pass
	move	#points/4,n6	;initialize C pointer offset
	move	#-1,m0		;initialize A and B address modifiers
	move	m0,m1		;for linear addressing
	move	m0,m2
	move	m0,m4
	move	m0,m5
	move	#0,m6		;initialize C address modifier for
				;reverse carry (bit-reversed) addressing
;
; Perform all FFT passes except last pass with triple nested DO loop
;
	do	#@cvi(@log(points)/@log(2)-0.5),_end_pass
	move	#data,r0	;initialize A input pointer
	move	r0,r1
	move	n1,r2
	move	r0,r4		;initialize A output pointer
	move	(r1)+n1		;initialize B input pointer
	move	r1,r5		;initialize B output pointer
	move	#coef,r6	;initialize C input pointer
	lua	(r2)+,n0	;initialize pointer offsets
	move	n0,n4
	move	n0,n5
	move	(r2)-		;butterfly loop count
	move	x:(r1),x1	y:(r6),y0	;lookup -sine and -cosine values
	move	x:(r6)+n6,x0	y:(r0),b	;update C pointer, preload data
	mac	x1,y0,b		y:(r1)+,y1
	macr	-x0,y1,b	y:(r0),a

	do	n2,_end_grp
	do	r2,_end_bfy
	subl	b,a		x:(r0),b	b,y:(r4)	;Radix 2 DIT butterfly kernel
	mac	-x1,x0,b	x:(r0)+,a	a,y:(r5)
	macr	-y1,y0,b	x:(r1),x1
	subl	b,a		b,x:(r4)+	y:(r0),b
	mac	x1,y0,b				y:(r1)+,y1
	macr	-x0,y1,b	a,x:(r5)+	y:(r0),a
_end_bfy
	move	(r1)+n1
	subl	b,a		x:(r0),b	b,y:(r4)
	mac	-x1,x0,b	x:(r0)+n0,a	a,y:(r5)
	macr	-y1,y0,b	x:(r1),x1	y:(r6),y0
	subl	b,a		b,x:(r4)+n4	y:(r0),b
	mac	x1,y0,b		x:(r6)+n6,x0	y:(r1)+,y1
	macr	-x0,y1,b	a,x:(r5)+n5	y:(r0),a
_end_grp
	move	n1,b1
	lsr	b	n2,a1	;divide butterflies per group by two
	lsl	a	b1,n1	;multiply groups per pass by two
	move	a1,n2
_end_pass
;
; Do last FFT pass
;
	move	#2,n0		;initialize pointer offsets
	move	n0,n1
	move	n0,n4
	move	n0,n5
	move	#data,r0	;initialize A input pointer
	move	r0,r4		;initialize A output pointer
	lua	(r0)+,r1	;initialize B input pointer
	move	#coef,r6	;initialize C input pointer
	lua	(r1)-n1,r5	;initialize B output pointer
	move	x:(r1),x1	y:(r6),y0
	move	x:(r5),a	y:(r0),b

	do	n2,_lastpass
	mac	x1,y0,b	x:(r6)+n6,x0	y:(r1)+n1,y1	;Radix 2 DIT butterfly kernel
	macr	-x0,y1,b	a,x:(r5)+n5	y:(r0),a	;with one butterfly per group
	subl	b,a	x:(r0),b	b,y:(r4)
	mac	-x1,x0,b	x:(r0)+n0,a	a,y:(r5)
	macr	-y1,y0,b	x:(r1),x1	y:(r6),y0
	subl	b,a		b,x:(r4)+n4	y:(r0),b
_lastpass
	move	a,x:(r5)+n5
	endm
