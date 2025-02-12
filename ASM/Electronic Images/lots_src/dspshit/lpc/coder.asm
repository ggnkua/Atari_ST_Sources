	page	132,63,1,1
	opt	rc
	title	'LPC Coefficients coder'

;***************************************************************
;* CODER.ASM -- 2400 bit/s LPC Coefficients coder	       *
;*							       *
;* Encodes/Decodes reflection coefficients, gain and pitch to  *
;* one 48 bit block					       *
;*							       *
;* Copyright (C) 1992 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************

	section LPCcoder
	xdef	lpc_encode,lpc_decode
	xdef	lpcin,lpcout

	org	p:

	nolist
	include 'macros'
	list


encode	macro	src,table,len,pos
	move	src,x0
	move	#table,r0
	move	#>len,y0
	if pos!=0
	    move    #>@cvi(@pow(2,pos-1)),y1
	else
	    move    #0,y1
	endif
	jsr	<pack
	endm

decode	macro	table,len,pos,dest
	move	#table,r0
	move	#>len-1,y0
	if pos!=0
	    move    #>pos,y1
	else
	    move    #0,y1
	endif
	jsr	<unpack
	move	a,dest
	endm


; Encode LPC parameters to 48 bit block
lpc_encode
	clr	a	    #lpcout,r1
	move		    #-1,m0
	move		    a,x:(r1)
	encode	x:<p_code,p_codes,64,18 	    ; pitch
	encode	x:<g_code,g_codes,64,12 	    ; gain
	encode	x:<k_code+1,k1_codes,16,8	    ; k1
	encode	x:<k_code+2,k2_codes,16,4	    ; k2
	encode	x:<k_code+3,k3_codes,16,0	    ; k3

	clr	a	    (r1)+
	move		    a,x:(r1)
	encode	x:<k_code+9,k9_codes,8,21	    ; k9
	encode	x:<k_code+8,k8_codes,8,18	    ; k8
	encode	x:<k_code+7,k7_codes,8,15	    ; k7
	encode	x:<k_code+6,k6_codes,8,12	    ; k6
	encode	x:<k_code+5,k5_codes,8,9	    ; k5
	encode	x:<k_code+4,k4_codes,16,5	    ; k4
	encode	x:<k_code+0,k0_codes,32,0	    ; k0

	rts


; Decode LPC parameters from 48 bit block
lpc_decode
	move		    #-1,m0
	move		    #lpcin,r1
	decode	p_decodes,64,18,x:<p_s		    ; pitch
	decode	g_decodes,64,12,x:<g_s		    ; gain
	decode	k1_decodes,16,8,x:<k_s+1	    ; k1
	decode	k2_decodes,16,4,x:<k_s+2	    ; k2
	decode	k3_decodes,16,0,x:<k_s+3	    ; k3

	move		    (r1)+
	decode	k9_decodes,8,21,x:<k_s+9	    ; k9
	decode	k8_decodes,8,18,x:<k_s+8	    ; k8
	decode	k7_decodes,8,15,x:<k_s+7	    ; k7
	decode	k6_decodes,8,12,x:<k_s+6	    ; k6
	decode	k5_decodes,8,9,x:<k_s+5 	    ; k5
	decode	k5_decodes,8,9,x:<k_s+5 	    ; k5
	decode	k4_decodes,16,5,x:<k_s+4	    ; k4
	decode	k0_decodes,32,0,x:<k_s+0	    ; k0

	rts


; Quantize argument and pack it
;   x0 - value to be quantized
;   r1 - pointer to target where the result is to be packed
;   r0 - quantization table pointer
;   y0 - number of quantization values
;   y1 - shift position
pack	move		    r0,x1		    ; first search quantization value
	move		    x:(r0)+,a
	do	y0,_gcode
	cmp	x0,a
	jlt	<_gcodes
	enddo
	jmp	<_gcode
_gcodes move		    x:(r0)+,a
_gcode
	move		    (r0)-		    ; then calculate its bit value
	move		    r0,a
	sub	x1,a	    y1,b

	tst	b	    x:(r1),x1		    ; shift the result to appropriate position
	jeq	<_posok
	move		    a,y0		    ; shift left
	mpy	y0,y1,a
	move		    a0,a1

_posok	or	x1,a				    ; and add it to the result
	move		    a1,x:(r1)

	rts


; Unpack parameter and give its value
;   r1 - pointer to source where the result is to be fetched
;   r0 - quantization table pointer
;   y0 - bitmask
;   y1 - shift position
unpack	move		    y1,a		    ; fetch quantized value
	tst	a	    x:(r1),b
	jeq	<_posok
	rep	y1
	lsr	b

_posok	and	y0,b				    ; convert it to result
	move		    b1,n0
	nop
	move		    y:(r0+n0),a

	rts


;****************************
;*	 DATA - AREA	    *
;****************************

; The following tables are used for 2400 bps coding.
; They the index in the array to the first value less
; than or equal to the value to be coded represents the code.
; Gain tables are logarithmically coded in order to maximize dynamic
; levels and obey square root function.
; Other tables are based on TMS320C30 LPC Vocoder implementation.

	org	x:

lpcin	ds	2				    ; 48 bit coded parameters
lpcout	ds	2				    ; 48 bit coded parameters

g_codes
dum	set	0
	dup	64
	dc	@pow(@xpn(@cvf(dum-63)/7.0),2.0)
dum	set	dum+1
	endm

p_codes dc	0,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc	32,33,34,35,36,37,39,40,42,44,46,48,50,52,54,56
	dc	58,61,63,66,69,72,74,77,80,83,87,90,94,98,102,106
	dc	111,115,120,124,129,135,140,146,152,158,165,172,178,185,193,32767

k0_codes dc	-9.55048e-01,-9.37592e-01,-9.18121e-01,-8.97949e-01
	dc	-8.74268e-01,-8.48053e-01,-8.19855e-01,-7.89185e-01
	dc	-7.56073e-01,-7.19574e-01,-6.80115e-01,-6.38123e-01
	dc	-5.92133e-01,-5.42633e-01,-4.87457e-01,-4.26727e-01
	dc	-3.59741e-01,-2.88483e-01,-2.07733e-01,-1.24878e-01
	dc	-3.47900e-02,6.03333e-02,1.52863e-01,2.55432e-01
	dc	3.54248e-01,4.49585e-01,5.42542e-01,6.40015e-01
	dc	7.35138e-01,8.13599e-01,8.73596e-01,9.99969e-01

k1_codes dc	-4.02374e-01,-2.53571e-01,-1.25000e-01,-1.08948e-02
	dc	9.46045e-02,1.94031e-01,2.85522e-01,3.72040e-01
	dc	4.54041e-01,5.31738e-01,6.06720e-01,6.79169e-01
	dc	7.46094e-01,8.10913e-01,8.67310e-01,9.99969e-01

k2_codes dc	-6.89941e-01,-5.97595e-01,-5.14465e-01,-4.32007e-01
	dc	-3.48572e-01,-2.67548e-01,-1.85059e-01,-9.79309e-02
	dc	-8.14819e-03,8.36792e-02,1.75079e-01,2.68127e-01
	dc	3.66760e-01,4.70978e-01,5.89172e-01,9.99969e-01

k3_codes dc	-3.65662e-01,-2.57019e-01,-1.68213e-01,-8.74634e-02
	dc	-1.25732e-02,5.56641e-02,1.22009e-01,1.87286e-01
	dc	2.52411e-01,3.18146e-01,3.85803e-01,4.57825e-01
	dc	5.37445e-01,6.25793e-01,7.18903e-01,9.99969e-01

k4_codes dc	-4.01245e-01,-3.02185e-01,-2.20673e-01,-1.47827e-01
	dc	-8.15430e-02,-1.98059e-02,4.00391e-02,9.93042e-02
	dc	1.59424e-01,2.20825e-01,2.85553e-01,3.53851e-01
	dc	4.32190e-01,5.22919e-01,6.31531e-01,9.99969e-01

k5_codes dc	-1.40167e-01,8.27026e-03,1.28906e-01,2.43042e-01
	dc	3.63312e-01,4.88190e-01,6.21246e-01,9.99969e-01

k6_codes dc	-2.79236e-01,-1.26251e-01,-2.74658e-03,1.09100e-01
	dc	2.24518e-01,3.54706e-01,5.10498e-01,9.99969e-01

k7_codes dc	-2.13196e-01,-7.72400e-02,3.59497e-02,1.44073e-01
	dc	2.65991e-01,4.18549e-01,5.77789e-01,9.99969e-01

k8_codes dc	-2.72003e-01,-1.56097e-01,-6.65894e-02,1.22070e-02
	dc	9.06677e-02,1.79260e-01,3.01880e-01,9.99969e-01

k9_codes dc	-1.97052e-01,-1.07269e-01,-3.49731e-02,3.17078e-02
	dc	1.00159e-01,1.77277e-01,2.78564e-01,9.99969e-01


	org	y:

g_decodes
	dc	0
dum	set	1
	dup	64-1
	dc	@xpn(@cvf(dum-63)/7.0)
dum	set	dum+1
	endm

p_decodes dc	0,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc	32,33,34,35,36,37,39,40,41,43,45,47,49,51,53,55
	dc	57,60,62,65,68,71,73,76,79,82,86,89,92,96,100,104,109
	dc	113,118,122,127,132,138,143,149,155,162,169,175,182,189,197

k0_decodes dc	-9.63440e-01,-9.46167e-01,-9.28223e-01,-9.08356e-01
	dc	-8.86292e-01,-8.61420e-01,-8.34320e-01,-8.04901e-01
	dc	-7.72797e-01,-7.38586e-01,-7.00256e-01,-6.59393e-01
	dc	-6.16089e-01,-5.67841e-01,-5.14984e-01,-4.57184e-01
	dc	-3.94806e-01,-3.23730e-01,-2.48962e-01,-1.65771e-01
	dc	-8.12683e-02,1.37939e-02,1.06323e-01,2.04132e-01
	dc	3.05695e-01,4.03778e-01,4.95178e-01,5.89935e-01
	dc	6.89148e-01,7.75482e-01,8.45001e-01,8.96667e-01

k1_decodes dc	-4.91791e-01,-3.23212e-01,-1.87592e-01,-6.70166e-02
	dc	4.23584e-02,1.45294e-01,2.40448e-01,3.29926e-01
	dc	4.13452e-01,4.93378e-01,5.68726e-01,6.43280e-01
	dc	7.13745e-01,7.78473e-01,8.40088e-01,8.96667e-01

k2_decodes dc	-7.40662e-01,-6.41907e-01,-5.55847e-01,-4.72900e-01
	dc	-3.90411e-01,-3.07770e-01,-2.26837e-01,-1.40869e-01
	dc	-5.40161e-02,3.87573e-02,1.28571e-01,2.21344e-01
	dc	3.15979e-01,4.16748e-01,5.28748e-01,6.58478e-01

k3_decodes  dc	-4.32495e-01,-3.08533e-01,-2.10876e-01,-1.27136e-01
	dc	-4.96826e-02,2.18811e-02,8.95386e-02,1.54602e-01
	dc	2.19391e-01,2.85400e-01,3.51562e-01,4.20746e-01
	dc	4.97223e-01,5.80933e-01,6.71021e-01,7.75757e-01

k4_decodes  dc	-4.66675e-01,-3.47412e-01,-2.60071e-01,-1.83228e-01
	dc	-1.13983e-01,-5.02625e-02,1.04980e-02,6.94580e-02
	dc	1.29456e-01,1.89697e-01,2.53113e-01,3.18848e-01
	dc	3.90961e-01,4.77051e-01,5.73639e-01,6.90735e-01

k5_decodes  dc	-2.37793e-01,-6.14929e-02,7.08008e-02,1.85760e-01
	dc	3.01697e-01,4.25049e-01,5.54657e-01,6.99585e-01

k6_decodes  dc	-3.77716e-01,-1.98029e-01,-6.22253e-02,5.45044e-02
	dc	1.65771e-01,2.87018e-01,4.29474e-01,6.10352e-01

k7_decodes  dc	-3.04535e-01,-1.41754e-01,-1.86462e-02,8.90808e-02
	dc	2.02698e-01,3.38226e-01,4.97986e-01,6.58142e-01

k8_decodes  dc	-3.49945e-01,-2.09595e-01,-1.08887e-01,-2.65198e-02
	dc	5.10559e-02,1.32782e-01,2.34582e-01,3.99811e-01

k9_decodes  dc	-2.60620e-01,-1.48865e-01,-7.00989e-02,-1.22070e-03
	dc	6.48804e-02,1.36963e-01,2.23297e-01,3.56262e-01

	endsec

	end
