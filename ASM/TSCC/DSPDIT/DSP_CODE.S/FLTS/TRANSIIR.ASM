	page	132,60,1,1
;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive, West, Austin, Texas  78735-8598.
;
;
;  The cascaded transpose IIR filter has a filter section:
;
;
;      x  --------------bi0---->(+)--------------------> y
;                  |             ^            |
;                  |             | w1         |
;                  |            1/z           |
;                  |             |            |
;                  |----bi1---->(+)<---ai1----|
;                  |             ^            |
;                  |             | w2         |
;                  |            1/z           |
;                  |             |            |
;                  |----bi2---->(+)<---ai2----|
;
;  The filter equations are:
;      y  = x*bi0 + w1
;      w1 = x*bi1 + y*ai1 + w2
;      w2 = x*bi2 + y*a2

nsec	equ	2		;number of sections

	org	x:0
w1	dsm	nsec		;w1
w2	dsm	nsec		;w2

	org	y:0
coef
;	section 1
	dc	.8/2.0		;b0
	dc	-.5/2.0		;b1
	dc	-.6/2.0		;a1
	dc	.3/2.0		;b2
	dc	.2/2.0		;a2
;	section 2
	dc	-.8/2.0		;b0
	dc	.5/2.0		;b1
	dc	-.6/2.0		;a1
	dc	-.3/2.0		;b2
	dc	.1/2.0		;a2


	org	p:$50
start
	move	#w1,r0
	move	#w2,r1
	move	#coef,r4

	move	#nsec-1,m0
	move	#5*nsec-1,m4
	move	#nsec-1,m1

;
;	filter setup
;
	ori	#$08,mr				;set scaling mode
	move		x:(r0),a  y:(r4)+,y0	;get w1, b0
	asr	a				;w1/2

	do	#20,endloop			;process 20 samples

	move	x:$50,y1			;get input

;	filter loop
	do	#nsec,_filt			;do filter sections
	macr	y1,y0,a	x:(r1),b  y:(r4)+,y0	;x*b0+w1/2, get w2, b1
	asr	b	a,x0			;w2/2, move y to x0
       	mac	y1,y0,b		  y:(r4)+,y0	;x*b1+w2/2, get a1
	macr	x0,y0,b		  y:(r4)+,y0	;+y*a1, get b2
	mpy	y1,y0,b	b,x:(r0)+ y:(r4)+,y0	;x*b2, save w1, get a2
	macr	x0,y0,b	x:(r0),a  a,y1		;y*a2, get w1, move y->x
	asr	a	b,x:(r1)+ y:(r4)+,y0	;w1/2, save w2, get b0
_filt
	move	y1,y:$50			;save output
endloop
	end

