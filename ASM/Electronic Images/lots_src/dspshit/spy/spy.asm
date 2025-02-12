;***************************************************************
;* SPY.ASM -- Simple oscilloscope with SPY		       *
;*							       *
;* Displays Left channel on the SPY program.		       *
;*							       *
;* Copyright (C) 1994 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************


	nolist
	include 'leonid'
	list


buflen	equ	16				    ; lenght of sample buffer

; flags
spyflg	equ	3				    ; spy on/off


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

; copy left channel to the both outputs
	move		    x:(r2)+,a
	move		    a,y:(r2)+
	move		    a,y:(r2)+
	move		    (r2)+

; and to the spy
	jsr	<spy

	jmp	<loop


; *** special spy ***
spy	jset	#spyflg,x:<flag,_spyon

	lookc					    ; check if spy operation requested
	jcs	<_spyend
	move		    #>'S',a
	cmp	x0,a
	jne	<_spyend

	move		    #>'P',x0		    ; yes, send first a preamble
	putc
	move		    #>512,a1
	move		    a1,x:<spyn
	move		    #>1,a1
	move		    a1,x:<spym
	bset	#spyflg,x:<flag
	jmp	<_spyend

; spy is active, send a register to the host
_spyon	move		    x:<spym,b
	move		    #>1,y1
	sub	y1,b	    #>1,y1
	move		    b,x:<spym
	jne	<_spyend
	move		    y1,x:<spym

	move		    a,y0		    ; LSB first
	rep	#8
	lsr	a
	move	a1,x0
	putc

	move		    y0,a		    ; then HSB
	rep	#16
	lsr	a
	move	a1,x0
	putc

	move		    x:<spyn,a		    ; check if all samples allready given
	move		    #>1,x0
	sub	x0,a
	move		    a,x:<spyn
	jne	<_spyend
	bclr	#spyflg,x:<flag

_spyend rts



	org	x:user_data

flag	dc	0
spyn	ds	1
spym	ds	1

buffer	dsm	buflen*4


	org	y:user_data

	dsm	buflen*4


	end
