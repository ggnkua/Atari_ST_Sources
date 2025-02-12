;***************************************************************
;* NOCHANGE.ASM -- Pass input to output without change	       *
;*							       *
;* Provides extremely narrow FIR bandpass filter.	       *
;*							       *
;* Copyright (C) 1993 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************


	nolist
	include 'leonid'
	list


buflen	equ	16				    ; lenght of sample buffer
stereo	equ	0				    ; mono/stereo selector


	org	p:user_code

	move		    #buffer+2,r7
	move		    #buflen*4-1,m7

	move		    #buffer,r2
	move		    #4-1,n2
	move		    #buflen*4-1,m2

	ctrlcd	1,r2,buflen,LINEI,0.0,0.0,LINEO|HEADP,0.0,0.0
	opencd	16

; wait for one complete block
loop	waitblk r2,buflen,1

; *** stereo mode
	if stereo
; transfer left channel input to the output
	move		    x:(r2)+,a
	move		    a,y:(r2)

; transfer right channel input to the output
	move		    x:(r2)+,a
	move		    a,y:(r2)

	move		    (r2)+
	move		    (r2)+

; *** mono mode
	else
	move		    x:(r2)+,a
	move		    a,y:(r2)+
	move		    a,y:(r2)+
	move		    (r2)+

	endif

	jmp	<loop


	org	x:user_data

buffer	dsm	buflen*4


	org	y:user_data

	dsm	buflen*4


	end
