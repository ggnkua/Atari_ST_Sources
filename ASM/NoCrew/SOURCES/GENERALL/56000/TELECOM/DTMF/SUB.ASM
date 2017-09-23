	title	'SUBROUTINES '

	page	132,66,0,10





;************************************************************************

;This section contains miscellaneous subroutines for input and output

;as well computing energies in esch tone.

;************************************************************************



sub	IDENT	1,1

	section	sub

	xdef	iiraspi,rdlgln,ready,enerac

        opt     rc,mu,cc

	nolist

	include '\dsp56000.asm\ioequ'        

	list

	org	phi:

;

;*************

; write READY 

;*************

ready	move	x:(r0)+,x0

	do	n0,_fin

	movep	x0,x:M_STXL	;write in sci tx low byte

att	jclr	#M_TDRE,x:M_SSR,att	;wait for tx empty

	move	x:(r0)+,x0

_fin	rts

;

;**********

;  IIRASPI

;**********

;	Equation of the filter:

;	y(n) = b0*x(n) +w1(n-1)

;	w1(n)= b1*x(n) -a1*y(n) +w2(n-1)

;	w2(n)= b2*x(n) -a2*y(n)

;

;	Implemented in that way:

;	y(n)/2 = b0/2*x(n) +w1(n-1)/2

;	w1(n)/2= b1/2*x(n) -a1/2*y(n) +w2(n-1)/2

;	w2(n)/2= b2/2*x(n) -a2/2*y(n)

;

;	r0 -> X:xddr 

;	r4 -> Y:cddr 

;       n0 = number of cells = filter order/2

;

iiraspi	do	n0,_iirend	

	move	a,x0

	move	x:(r0)+,a y:(r4)+,y0		; a=w1n-1 x0=xn y0=b0

	mac	x0,y0,a	  x:(r0)-,b  y:(r4)+,y0 ; a=yn b=w2n-1 y0=b1

	asl	a

	mac	x0,y0,b   a,x1	     y:(r4)+,y0	; x1=yn y0=a1

	mac	-x1,y0,b 	     y:(r4)+,y0 ; y0=a2 b=w1n

	mpy     -x1,y0,a  b,x:(r0)+  y:(r4)+,y0 ; y0=b2

	mac	x0,y0,a				; a=w2n	     

	tfr	x1,a      a,x:(r0)+ 

_iirend	rts

;

;************************************

;  linear expansion

; uses a,x0,y0,x1,r3,n3,m3

;

; data for log/lin conversion routines

;************************************* 



inv     equ     $d5     ;invert even bits+sign 

msk13   equ     $fff800 ;mask  13 msb 

shift   equ     $80

mask    equ     $7f

tab     equ     $180 	;A law table address in DS56001 X ROM.

tab1	equ	$7f	;modulo value

;

rdlgln	

_wrdf	jclr	#M_RDF,x:M_SR,_wrdf	; wait for rdf

        movep   x:M_RX,x0               ; read data 

	move    #>shift,y0

        mpy     x0,y0,a         #>mask,x1

        and     x1,a            #tab,r3

	move	a1,n3

        move	#tab1,m3

	cmpm	y0,a	

	move	x:(r3+n3),a

	jge	<endp

        neg     a

endp	rts  

;

;************************************

;	energy computation subroutine

;************************************



enerac	move	a,x0	y:(r6),y0	; compute a*a/80

	mpy	x0,y0,a			; a=a/80

	move	a,y0

	mpy	x0,y0,a	x:(r2),b	;a=a*a/80

	add	b,a			;accumulate

	move 	a,x:(r2)+		;update

	rts

;

	endsec 



	end



















