	page	132,63,1,1
	opt	rc
	title	'LPC Synthesis'

;***************************************************************
;* SYNT.ASM -- 2400 bit/s LPC synthesizer module	       *
;*							       *
;* Provides excitation source and Lattice filter for speech    *
;* generation.						       *
;*							       *
;* The overall implementation is based on application note     *
;*	Seshan, N.:					       *
;*	"A TMS320C30-based LPC Vocoder",		       *
;*	Texas Instruments, 1990 			       *
;*							       *
;* Lattice filter implementation is based on Motorola sample   *
;* code and book					       *
;*	Proakis, J., G.:				       *
;*	"Digital Communications",			       *
;*	McGraw-Hill, 1983				       *
;*							       *
;* Copyright (C) 1992 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;*	30-Sep-92: added monotonic mode 		       *
;***************************************************************

	section LPCsyn
	xdef	lpc_syn

	org	p:

	nolist
	include 'macros'
	include 'leonid'
	list


; Synthesize output from LPC parameters
lpc_syn move		    #-1,m0
	move		    m0,m4

	jclr	#monot,x:<flags,_inton		    ; set to constant pitch if monotonic mode
	move		    x:<p_s,a		    ; and current frame is voiced
	tst	a	    #>monopit,x0
	tne	x0,a
	move		    a1,x:<p_s

_inton	jclr	#whisper,x:<flags,_voice	    ; remove voicing if in whisper mode
	clr	a
	move		    a,x:<p_s

_voice	move		    x:<p_s,a		    ; test if voiced
	tst	a	    x:<p_d,x0
	jeq	<_novc
	add	x0,a	    #>10,x0		    ; then adjust pitch
	cmp	x0,a				    ; set floor on adjustment
	tlt	x0,a
	move		    a,x:<p_s
	jmp	<_vcend

_novc	move		    #>boost,x0		    ; if unvoiced boost gain
	move		    x:<g_s,x1
	mpy	x0,x1,a
	lsl	a				    ; adjust fraction (fraction, integer multiplication)
	asr	a
	move		    a0,x:<g_s

_vcend	jclr	#silence,x:<flags,_loud 	    ; set gain to zero if in silence mode
	clr	a
	move	a,x:<g_s
_loud

; Interpolate if voicing of previous frame and current frame is same
	move		    #-1,x0		    ; first convert pitchs to logical values
	move		    x:<p_s,a
	tst	a	    x:<p_s_0,b
	tne	x0,a
	tst	b	    a,x1
	tne	x0,b

	bclr	#ipolate,x:<flags		    ; then set interpolate flag if they are different
	eor	x1,b
	jne	<_clripo
	bset	#ipolate,x:<flags
_clripo

; If interpolating initialize with last frames parameters
	jclr	#ipolate,x:<flags,noipo

	move		    #<k_s_0,r0		    ; copy k_s_0[] to k_int[]
	move		    #k_int,r4
	do	#P,_endip
	move		    x:(r0)+,a1
	move		    a1,x:(r4)+
_endip

	move		    x:<g_s_0,a1 	    ; g_s_0 -> g_int
	move		    a1,x:g_int

	jmp	<ipo

; else reset interpolation index (exite), initialize system with
; current frame's LPC parameters and clear backward lattice state
noipo	clr	a	    x:<g_s,b1		    ; 0   -> excite
	move		    a,x:excite		    ; g_s -> g_int
	move		    b1,x:g_int

	move		    #b_s,r0		    ; clear b_s[]
	move		    r0,x:b_s_ptr
	rep	#P
	move		    a,y:(r0)+

	move		    #<k_s,r0		    ; copy k_s[] to k_int[]
	move		    #k_int,r4
	do	#P,_refcpy
	move		    x:(r0)+,a1
	move		    a1,x:(r4)+
_refcpy

; if unvoiced set interpolation interval to 1/8 frame size
ipo	move		    x:<p_s,a
	tst	a	    #>M/8,x0
	jeq	<ipintv

; else set interpolation interval to pitch. If interpolation
; is on set to last frame's pitch, otherwise set to current frame's pitch
von	move		    x:<p_s_0,x0 	    ; p_int = interpolate ? p_s_0 : p_s
	jset	#ipolate,x:<flags,ipintv
	move		    x:<p_s,x0
ipintv	move		    x0,x:p_int

;
	lua		    (r6)+,r0
	move		    #4-1,n0
	move		    #(3*M)*4-1,m0
	do	#M,frmend
	move		    r0,b		    ; sample index to b
	move		    r6,x0
	sub	x0,b	    #>1,x0
	sub	x0,b	    x:excite,a		    ; check if end of interpolation interval
	asr	b
	asr	b
	cmp	a,b
	jne	<genexc

; If interpolation flag, interpolate between previous and current frame
	move		    #>$03,x0
	putio
	wait
	move		    #>$01,x0
	putio

	jclr	#ipolate,x:<flags,nxtipo

	move		    b,x0		    ; x0 = index/M, y0 = (M - index)/M
	move		    #1.0/@cvf(M),x1
	mpy	x0,x1,a     #0.9999999,b
	lsl	a				    ; adjust fraction part
	asr	a
	move		    a0,x0
	sub	x0,b	    x:<p_s,a

	tst	a	    b,y0		    ; p_int = (i*p_s + l*p_s_0)/M
	jeq	<_nopitch
	move	a,x1
	mpy	x0,x1,a     x:<p_s_0,y1
	macr	y0,y1,a
	move		    a,x:p_int
_nopitch

	move		    #k_s,r1		    ; k_int[j] = (i*k_s[j] + j*k_s_0[j])/M
	move		    #<k_s_0,r4
	move		    #k_int,r5
	move		    #-1,m1
	move		    m1,m5
	do	#P,_refipo
	move		    x:(r1)+,x1
	mpy	x0,x1,a     x:(r4)+,y1
	macr	y0,y1,a
	move		    a,x:(r5)+
_refipo

	move		    x:<g_s,x1		    ; g_int = (i*g_s + l*g_s_0)/M
	mpy	x0,x1,a     x:<g_s_0,y1
	macr	y0,y1,a
	move		    a,x:g_int

nxtipo	move		    x:excite,a		    ; set next interpolation point
	move		    x:p_int,x0
	add	x0,a	    #glottal,b1 	    ; reset glottal pulse pointer
	move		    a1,x:excite
	move		    b1,x:pulse

; Generate excitation
genexc	move		    x:<p_s,b
	tst	b	    x:rand,a1
	jeq	<noise

; voiced, use 40 point DoD glottal pulse excitation
	move		    x:pulse,b		    ; give zero if end of excitation sequence
	clr	a	    #>glottal+40,x0
	cmp	x0,b	    x:pulse,r4
	jge	<genout
	move		    x:p_int,x0		    ; pulse[]*p_int/p_max*g_int
	move		    #1.0/(197.0+1.0),x1
	mpy	x0,x1,a     y:(r4)+,x0
	move	a0,x1
	mpyr	x0,x1,a     x:g_int,x0
	move	a,x1
	mpyr	x0,x1,a     r4,x:pulse
	jmp	<genout

; otherwise generate white noise excitation with random bit
noise	lsr	a	    #>poly,x0		     ; generate a new random bit to C flag
	jcc	<_rand
	eor	x0,a
_rand	move		    a,x:rand

	move		    x:g_int,a		    ; compose excitation value
	jcs	<_scale
	neg	a
_scale	move	a,x0				    ; scale output
	move		    #1.0/25.0,x1
	mpyr	x0,x1,a

; exite lattice filter and deemphasize output (excitation in a register)
genout	move		    #k_int+P-1,r1
	move		    x:b_s_ptr,r5
	move		    #P-1,m5
	nop

	move		    x:(r1)-,x0	y:(r5)+,y0  ; Lattice macro from Motorola bulletin board
	macr	-x0,y0,a    x:(r1)-,x0	y:(r5)-,y0
	do	#P-1,_endlat
	macr	-x0,y0,a		b,y:(r5)+
	move	a,x1			y:(r5)+,b
	macr	x1,x0,b     x:(r1)-,x0	y:(r5)-,y0
_endlat
	move				b,y:(r5)+
	move		    x:(r1)+,x0	a,y:(r5)+
	move		    r5,x:b_s_ptr

	move		    x:<old,x0		    ; deemphasize
	move		    #0.9375,x1
	macr	x0,x1,a
	move		    a,x:<old

	rep	#4				    ; scale output
	asl	a

	move		    a,y:(r0)+		    ; output left channel
	move		    a,y:(r0)+n0 	    ; output right channel
frmend

	move		    x:excite,a		    ; reset next excitation point for next frame
	move		    #>M,x0
	sub	x0,a	    x:<g_s,x0		    ; save current values for next frame
	move		    a,x:excite

	move		    x0,x:<g_s_0

	move		    x:<p_s,x0
	move		    x0,x:<p_s_0

	move		    #<k_s,r0
	move		    #-1,m0
	move		    #<k_s_0,r4
	do	#P,_ef
	move		    x:(r0)+,a1
	move		    a1,x:(r4)+
_ef

	rts


;****************************
;*	 DATA - AREA	    *
;****************************

	org	x:

k_s_0	ds	P				    ; previous reflection coefficients

g_s_0	ds	1				    ; gain for previous output frame
old	dc	0				    ; previous output value

p_s_0	ds	1				    ; previous output pitch period
pulse	ds	1				    ; index to glottal excitation
excite	dc	0				    ; sample for next parameter interpolation

g_int	ds	1				    ; interpolated gain
p_int	ds	1				    ; interpolated pitch
k_int	ds	P				    ; interpolated reflection coefficients

rand	dc	$12345				    ; random number generator seed

b_s_ptr ds	1


	org	y:

	ds	14
b_s	ds	P				    ; backward lattice state

	endsec

	end
