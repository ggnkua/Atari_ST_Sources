	page	132,63,1,1
	opt	rc
	title	'LPC Analysis'

;***************************************************************
;* ANAL.ASM -- 2400 bit/s LPC analyser module		       *
;*							       *
;* Provides pitch estimator and Leroux-Gueguen reflection      *
;* parameters estimation.				       *
;*							       *
;* The overall implementation is based on application note     *
;*	Seshan, N.:					       *
;*	"A TMS320C30-based LPC Vocoder",		       *
;*	Texas Instruments, 1990 			       *
;*							       *
;* Leroux-Gueguen algorithm implementation is based on article *
;*	LeRoux, J., Gueguen C.: 			       *
;*	"A Fixed Point Computation of Partial Correlation      *
;*	Coefficients", IEEE Trans. on Acoustics, Speech and    *
;*	Signal Processing, Vol. 25, June 1977		       *
;*							       *
;* Pitch detection is based on article			       *
;*	Gold, B., Rabiner, L.:				       *
;*	"Parallel Processing Techniques for Estimating Pitch   *
;*	Periods of Speech in the Time Domain"                  *
;*	J. of the Acoustic Society of America,		       *
;*	Vol. 46, August 1969				       *
;*							       *
;* Copyright (C) 1992 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************

	section LPCana
	xdef	lpc_ana
	xref	p_code,g_code,k_code

	org	p:

	nolist
	include 'macros'
	list


;***************************
;*     Pitch detection	   *
;***************************
lpc_ana
; First lowpass filter (FIR) speech frame.
;
	move		    r6,r0
	move		    #<filter+1,n0
	move		    #3*M-1,m0
	move		    #lotaps,r4
	move		    #<filter-1,m4
	move		    #temp,r1

	do	#M+2,_endlpf			    ; two extra samples for pitch detector
	clr	a	    x:(r0)-,x0	y:(r4)+,y0
	rep	#filter-1
	mac	x0,y0,a     x:(r0)-,x0	y:(r4)+,y0
	macr	x0,y0,a     (r0)+n0
	asr	a				    ; scaling for pitch detector
	move		    a,x:(r1)+
_endlpf

; Generate pitch estimate for six Gold-Rabiner series
;
	move		    #temp,r0
	move		    #-1,m0
	move		    m0,m1
	move		    m1,m4
	move		    m4,m5
	do	#M,endpeak

; update detection envelope
	move		    r0,a		    ; a contains speech frame index
	move		    #temp-1,x0
	sub	x0,a	    #<peakblk,r4
	move		    #5-1,n4
	do	#6,_elope2
	move		    y:(r4)+,x0		    ; decay if sample index > blank[j]
	cmp	x0,a	    y:(r4),b1
	jle	<_elope1
	move		    y:(r4)+,x0		    ; threshold[j] *= decay[j]
	move		    y:(r4)-,y0
	mpyr	x0,y0,b
_elope1 move		    b1,y:(r4)+n4
_elope2

; detect peaks
	move		    x:(r0)+,x0
	move		    x:(r0)+,b
	cmp	x0,b	    x:(r0),x0
	jle	<peak1
	cmp	x0,b	    (r0)-
	jle	<peak2

	move		    #<eblk,r1		    ; update peak
	move		    #6,n1
	move		    #<peakblk,r4
	move		    x:(r0),b
	jsr	<estimate			    ; m[0]
	move		    x:(r0),b
	move		    y:<valley,y0
	add	y0,b	    (r1)+n1
	move		    (r4)+n4
	jsr	<estimate			    ; m[1]
	move		    x:(r0),b
	move		    y:<peak,y0
	sub	y0,b	    (r1)+n1
	move		    (r4)+n4
	jsr	<estimate			    ; m[2]
	move		    x:(r0),b
	move		    b,y:<peak
	jmp	<peak2

; detect valleys
peak1	cmp	x0,b	    (r0)-
	jge	<peak2

	move		    #<eblk+3*6,r1	    ; update valley
	move		    #6,n1
	move		    #<peakblk+3*5,r4
	move		    x:(r0),b
	neg	b
	jsr	<estimate			    ; m[3]
	move		    x:(r0),b
	neg	b	    y:<peak,y0
	add	y0,b	    (r1)+n1
	move		    (r4)+n4
	jsr	<estimate			    ; m[4]
	move		    x:(r0),b
	neg	b	    y:<valley,y0
	sub	y0,b	    (r1)+n1
	move		    (r4)+n4
	jsr	<estimate			    ; m[5]
	move		    x:(r0),b
	neg	b
	move		    b,y:<valley

peak2	nop
endpeak

; update indices for next frame
	move		    #<peakblk,r4	    ; decrement blanking indices
	move		    #5,n4
	move		    #<peakblk+3,r5	    ; decrement series indices
	move		    n4,n5
	move		    #>M,x0
	do	#6,_updpk
	move		    y:(r4),a
	sub	x0,a	    y:(r5),b
	sub	x0,b	    a,y:(r4)+n4
	move		    b,y:(r5)+n5
_updpk

; Choose best pitch from Gold-Rabiner 6*6 pitch estimate matrix
;
	clr	a
	move		    a,y:<p_a
	move		    #<voiced,a1 	    ; assume frame is unvoiced initially
	move		    a1,y:<c_best

; calculate last columns of pitch estimate matrix
	move		    #<eblk,r1
	move		    #2,n1
	do	#6,_cpch2
	do	#3,_cpch1
	move		    y:(r1)+,a		    ; e[i][j+3] = e[i][j]+e[i][j+1]
	move		    y:(r1)+,x0
	add	x0,a	    (r1)+
	move		    a,y:(r1)-n1
_cpch1	move		    (r1)+n1
	move		    (r1)+
_cpch2

; use first column of pitch estimates as potential cadidates
	move		    #<eblk,r1
	move		    #6,n1
	do	#6,pold1

; compute coincidence count under four tolerance levels
	move		    #<bias,r4
	do	#4,pold2
	move		    y:(r4)+,b		    ; c = bias[k]
	move		    b,y:<c

	move		    #>bias,x0		    ; a = 0.04*e[l][0]*(k+1)+.5
	move		    r4,b
	sub	x0,b	    y:(r1),x0
	move		    b,x1
	mpy	x0,x1,b     #0.04,x0		    ; integer to integer multiplication
	asr	b				    ; adjust binary point
	move		    b0,x1
	mpyr	x0,x1,a     #<eblk,r0		    ; integer to fraction multiplication

; compare against all thirty-six values in estimate matrix
	do	#6*6,_pcomp2

; if compare estimate is within tolerance increment coincidence count
	move		    y:(r1),b		    ; if abs(e[l][0]-e[i][j]) < a
	move		    y:(r0)+,y0
	sub	y0,b
	abs	b	    #>1,y0
	cmp	b,a	    y:<c,b
	jlt	<_pcomp1
	add	y0,b				    ; then increment coincidence count
	move		    b,y:<c
_pcomp1 nop
_pcomp2

; if coincidence count is higher then for previous best estimate current
; candidate is new best estimate and current coincidence count is best coincidence count
	move		    y:<c_best,a
	cmp	a,b	    y:(r1),a
	jlt	<pold
	move		    b,y:<c_best
	move		    a,y:<p_a
pold	nop
pold2	move		    (r1)+n1
pold1

; Post process pitch
; Correct possible pitch tracking/voicing errors
;

; if an unvoiced frame occurs between two voiced frames interpolate
	move		    y:<p_a,a		    ; if p_a && !p_a_0 && p_a_1
	tst	a	    y:<p_a_0,b
	jeq	<voice
	tst	b	    y:<p_a_1,a
	jne	<voice
	tst	a	    y:<p_a,b
	jeq	<voice

	add	b,a				    ; then p_code = (p_a + p_a_1)/2
	asr	a
	rnd	a
	jmp	<median

; else if a voiced frame occurs between two unvoice frames switch to unvoice
voice	move		    y:<p_a,a
	tst	a	    y:<p_a_0,b
	jne	<nope
	tst	b	    y:<p_a_1,a
	jeq	<nope
	tst	a
	jne	<nope

	clr	a
	jmp	<median

nope	move		    y:<p_a_0,a

; perform median filtering within a series of voiced frames
median	move		    a,x:<p_code

	move		    y:<p_a,a
	tst	a	    y:<p_a_0,b
	jeq	<medend
	tst	b	    y:<p_a_1,a
	jeq	<medend
	tst	a	    x:<p_code,b
	jeq	<medend

	move		    y:<p_a,a		    ; i=a,j=b,l=x0,k=y0
	move		    b,x0

	cmp	x0,a	    y:<p_a_1,y0 	    ; j = (i>l) ? i : j
	tgt	a,b
	cmp	y0,b				    ; j = (j>k) ? k : j
	tgt	y0,b
	cmp	x0,a				    ; i = (i>l) ? l : i
	tgt	x0,a
	cmp	b,a				    ; b = (i>j) ? i : j
	tgt	a,b
	move		    b,x:<p_code

medend	move		    y:<p_a_0,a1 	    ; update previous pitch locations
	move		    a1,y:<p_a_1

	move		    y:<p_a,a1
	move		    a1,y:<p_a_0

;***************************
;* Preemphasize and window *
;***************************

; Preemphasize (H(z) = 1 - az^-1) speech signal and apply hamming window
	move		    r6,r0
	move		    #temp,r1
	move		    #hamming,r4
	move		    #-0.9375,x1 	    ; a = 15/16 = 0.9375

	move		    x:(r4)+,y0		    ; first term
	move		    x:(r0)+,x0
	mpyr	x0,y0,a
	move		    a,x:(r1)+

	do	#N-1,_hwin			    ; remaining terms
	move		    x:(r0),a
	macr	x0,x1,a     x:(r4)+,y0
	move		    a,y1
	mpyr	y0,y1,a     x:(r0)+,x0
	move		    a,x:(r1)+
_hwin


;***************************
;*     Autocorrelation	   *
;***************************

; Returns short time autocorrelation of result
	move		    #temp,r0
	move		    #en,r4
	move		    #<N,r5

	do	#P+1,_endac
	move		    #temp,r2
	move		    r0,r1
	clr	a	    x:(r2)+,x1
	do	r5,_endlag
	move		    x:(r1)+,x0
	mac	x0,x1,a     x:(r2)+,x1
_endlag
	rnd	a	    (r5)-
	move		    x:(r0)+,a	a,y:(r4)+   ; just incrementing r0
_endac

; Setup ACs for LG-algorithm
	move		    #en+1,r0
	move		    #ep,r1

	do	#P,_accpy
	move		    y:(r0)+,a1
	move		    a1,y:(r1)+
_accpy


; store previous results (in order to compensate
; pitch post processing delay)
	move		    y:g_a,a1
	move		    a1,x:g_code

	move		    #k_a,r0
	move		    #k_code,r1
	do	#P,_endsto
	move		    y:(r0)+,a1
	move		    a1,x:(r1)+
_endsto

;***************************
;*	Leroux-Gueguen	   *
;***************************

; Derive reflection coefficients using Leroux-Gueguen algorithm
	move		    #ep,r0
	move		    #k_a,r4
	do	#P,lgloop

	move		    y:en,x0		    ; k_a[j] = -ep[j]/en[0]
	move		    y:(r0),a
	abs	a	    a,b
	eor	x0,b	    b,y0
	and	#$fe,ccr
	rep	#24
	div	x0,a
	jmi	_L1
	neg	a
_L1	move		    a0,y:(r4)

	move		    r0,r5
	move		    #en,r1
	move		    y:(r4)+,x0
	do	lc,_lgker

	move		    y:(r5),x1		    ; temp     = en[i]
	move		    y:(r1),a		    ; en[i]   += k_a[j]*ep[i+j]
	macr	x0,x1,a     y:(r1),y0		    ; ep[i+j] += k_a[k]*temp
	move		    x1,b
	macr	x0,y0,b     a,y:(r1)+
	move		    b,y:(r5)+
_lgker
	move		    (r0)+
lgloop
	move		    y:en,x0		    ; g_a = sqrt(en[0]/N)
	move		    #1.0/N,x1
	mpyr	x0,x1,a
	move		    a,y:g_a

	rts


; Estimate peaks by checking if potential series value is outside blanking
; interval and exceeds threshold value. If a new pitch estimate is generated
; and Gold-Rabiner parameters are updated.
;   r1 - pointer to e vector (a row of e matrix)
;   r4 - pointer to (blank,threshold,decay,i0,p_av) vector (incremented by 1)
;    a - speech frame sample index
;    b - Gold-Rabiner series value
estimate move		    y:(r4)+,x0		    ; if index > blank[j] and value > threshold[j]
	cmp	x0,a	    y:(r4),x0
	jle	<estiend
	cmp	x0,b
	jle	<estiend

; update envelope threshold
	tfr	a,b	    b,y:(r4)+

; update 3rd and 2nd newest estimates
	move		    y:(r1)+,x0		    ; e[j][2] = e[j][1]
	move		    y:(r1)+,x1		    ; e[j][1] = e[j][0]
	move		    x1,y:(r1)-
	move		    x0,y:(r1)-

; compute newest estimate and update index to last point of pitch estimation
	move		    (r4)+
	move		    y:(r4),x0		   ; e[j][0] = index - i0[j]
	move		    b,y:(r4)+		   ; i0[j] = index
	sub	x0,b	    y:(r4),x0
	move		    b,y:(r1)

; compute moving pitch average
	add	x0,b	    #>32,x0		    ; p_av[j] = 0.5*(e[j][0]+p_av[j])
	asr	b	    #>80,x1
	rnd	b	    #<exptab,r2
	cmp	x0,b				    ; limit to interval 32..80
	tlt	x0,b
	cmp	x1,b	    #0.4,y1
	tgt	x1,b
	sub	x0,b	    b,y:(r4)

; calculate envelope decay value
	move		    b,n2
	move		    y:(r4)-,x1
	move		    y:(r2+n2),y0	    ; decay[j] = exp(-.695/p_av[j])

; update blanking interval
	mpy	x1,y1,b     (r4)-		    ; blank[j] = .4*p_av[j]+i
	add	a,b	    y0,y:(r4)-
	rnd	b	    (r4)-
	move		    b,y:(r4)+

estiend rts


;****************************
;*	 DATA - AREA	    *
;****************************

	org	y:

; Gold-Rabiner pitch tracking variables
p_a	ds	1				    ; pitch estimate for current frame
p_a_0	dc	0				    ; previous frame's p_a
p_a_1	dc	0				    ; previous frame's p_a_0
c_best	ds	1

c	ds	1				    ; coincidence counter

peak	dc	0				    ; last maximum in speech frame
valley	dc	0				    ; last minimum in speech frame

peakblk dc	0,0,0,0,32			    ; blank, threshold, decay, i0, p_av
	dc	0,0,0,0,32
	dc	0,0,0,0,32
	dc	0,0,0,0,32
	dc	0,0,0,0,32
	dc	0,0,0,0,32

eblk	dc	0,0,0,0,0,0			    ; pitch estimate matrix
	dc	0,0,0,0,0,0
	dc	0,0,0,0,0,0
	dc	0,0,0,0,0,0
	dc	0,0,0,0,0,0
	dc	0,0,0,0,0,0

bias	dc	-2,-3,-6,-8			    ; tolerance based coincidence bias
exptab						    ; decay exponent table
dum	set	32
	dup	80-32+1
	dc	@xpn(-.695/@cvf(dum))
dum	set	dum+1
	endm

; Leroux-Gueguen coefficient extraction variables
k_a	ds	P				    ; reflection coefficient array

en	ds	P+1				    ; Leroux-Gueguen estimation arrays
ep	ds	P

g_a	dc	0				    ; gain

	endsec

	end
