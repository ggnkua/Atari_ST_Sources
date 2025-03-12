;***************************************************************
;* BANDPASS.ASM -- 800 Hz audio bandpass filter 	       *
;*							       *
;* Provides extremely narrow FIR bandpass filter.	       *
;*							       *
;* Copyright (C) 1992 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************


	nolist
	include 'leonid'
	list


buflen	equ	600


	org	p:user_code

	move		    #buffer+2,r7
	move		    #buflen*4-1,m7

	move		    #buffer,r2
	move		    #4-1,n2
	move		    #buflen*4-1,m2

	ctrlcd	1,r2,buflen,LINEI,0.0,0.0,LINEO|HEADP,0.0,0.0
	opencd	8

; wait for one complete block
loop	waitblk r2,buflen,1

; then filter the left channel
	move		    #buflen*4-1,m0
	move		    #-4,n0
	move		    #coeffs,r4

	move		    r2,r0
	clr	a
	move		    x:(r0)+n0,x0  y:(r4)+,y0
	rep	#taps-1
	mac	x0,y0,a     x:(r0)+n0,x0  y:(r4)+,y0
	macr	x0,y0,a     (r2)+
	move		    a,y:(r2)+n2

	jmp	<loop


	org	x:user_data

buffer	dsm	buflen*4


	org	y:user_data

	include 'coeff.asm'

	dsm	buflen*4


	end
