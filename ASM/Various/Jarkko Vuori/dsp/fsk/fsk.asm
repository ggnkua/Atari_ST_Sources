	page	132,79
	opt	rc
	title	'1200 bit/s FSK modem'

;***************************************************************
;* FSK.ASM -- Bell 202 1200 bit/s FSK modem		       *
;*							       *
;* Radio Amateur 1200 bit/s FSK modem. Demodulator is based    *
;* on first-order complex DPLL. Symbol synchro is based on     *
;* ML symbol synchro.					       *
;*							       *
;* DPLL consepts are from the book:			       *
;*	Lee, E., A., Messerschmitt, D., G.:		       *
;*	"Digital Communication",			       *
;*	Kluwer, 1990					       *
;*							       *
;* Sinewave synthesis is from the application note:	       *
;*	Chrysafis, A.:					       *
;*	"Digital Sine-Wave Synthesis Using the DSP56001",      *
;*	Motorola application note APR1, 1988		       *
;*							       *
;* Symbol synchro is from the article:			       *
;*	Franks, L., E.: 				       *
;*	"Carrier and bit Synchronization in Data               *
;*	Communication - A Tutorial Review",                    *
;*	IEEE Trans. on Communications,			       *
;*	Vol. COM-28, No. 8, May 1980, p. 1107-1121	       *
;*							       *
;* Copyright (C) 1994 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************

kiss	set	1				    ; give KISS data/debug data for SPY

	nolist
	include 'leonid'			    ; DSP CARD 4 monitor equates
	list

sinep	equ	$0100				    ; ROM sine table starting address
sinel	equ	256				    ; lenght of sine table
buflen	equ	256

fs	equ	9600				    ; sampling frequency
fd	equ	1200				    ; decision rate
N	equ	fs/fd				    ; samples per symbol
f0	equ	1200.0				    ; low FSK frequency
f1	equ	2200.0				    ; high FSK frequency

; AGC
refLev	equ	0.7				    ; reference level for AGC
agcN	equ	4*N				    ; agc analyse block lenght
agcGain equ	30.0				    ; agc integrator gain

; DPLL
Kg	equ	700.0				    ; NCO gain (in V/Hz)
Kpll	equ	(Kg/fs)/refLev
fc	equ	((f0+f1)/2)/fs			    ; center frequency

; Symbol synchro
Ksym	equ	0.06				    ; symbol synchro pll loop gain

; DCD
DCDFil	equ	0.03				    ; decision error IIR LPF coefficient

; flags
xmit	equ	0				    ; xmit on/off
mkdsion equ	1				    ; time to make a decision
car	equ	2				    ; carrier on/off
spyflg	equ	3				    ; spy on/off


	org	p:user_code


	ori	#$04,omr			    ; enable on-chip sine table

	move		    #buffer+2,r7	    ; codec sample buffer ptr
	move		    #buflen*4-1,m7

	move		    #buffer+4*16+1,r5	    ; sample buffer write ptr
	move		    #4,n5
	move		    #buflen*4-1,m5

	move		    #buffer,r2		    ; sample buffer read ptr
	move		    #4,n2
	move		    #buflen*4-1,m2

	move		    #<dfd,r6		    ; decision filter sample ptr
	move		    #2,n6
	move		    #<dftaps-1,m6

	if kiss
	move	#reject,a1			    ; serial interface to KISS mode
	move	#ptt,b1
	opensc
	endif

; fs = 9600 kHz, line input, line output, no gain and attenuation
	ctrlcd	1,r2,buflen,LINEI,0.0,0.0,LINEO,0.0,0.0
	opencd	fs/1000.0

; wait for one sample
loop	waitblk r2,buflen,1

; first get next sample from local oscillator
	move		    x:<nco,x0		    ; frequency in x0

; calculate frequency increment, Finc = sinel*(K*nco + fc)
	move		    #Kpll,x1
	move		    #fc,a
	macr	x0,x1,a     #>sinel,x0
	move	a,x1
	mpy	x0,x1,a
	move		    a10,l:<frqinc1	    ; frequency increment is real number

; generate one sinewave sample (Q)
	move		    #sinep,r0		    ; setup sine table pointers
	move		    #sinep+1,r1
	move		    x:<frqptr1,n0
	clr	b	    n0,n1
	move		    #sinel-1,m0
	move		    m0,m1
	move		    y:<frqptr1,b1	    ; convert frqinc1 fraction to signed
	lsr	b	    y:(r0+n0),x0
	move	b,x1	    y:(r1+n1),b

	sub	x0,b	    l:<frqptr1,y	    ; calculate difference of adjacent sine table entries
	move	b,x0	    y:(r0+n0),b
	macr	x0,x1,b     l:<frqinc1,a	    ; interpolate output sample
	add	y,a	    #>$ff,x0		    ; increment table pointer
	and	x0,a	    #sinep+sinel/4,r0
	move		    a,l:<frqptr1

; generate one cosinewave sample (I)
	move		    #sinep+sinel/4+1,r1     ; setup table pointers
	move		    y:(r0+n0),x0
	move		    y:(r1+n1),a

	sub	x0,a				    ; calculate difference of adjacent sine table entries
	move	a,x0	    y:(r0+n0),a
	macr	x0,x1,a 			    ; interpolate output sample

; output samples (I=a, Q=b)
	move	a,x1
	move	b,y1

; then filter input samples and produce the I channel signal
	move		    #buflen*4-1,m0
	move		    #-4,n0
	move		    #<ifc,r4

	move		    r2,r0
	clr	a
	move		    x:(r0)+n0,x0  y:(r4)+,y0
	rep	#iftaps-1
	mac	x0,y0,a     x:(r0)+n0,x0  y:(r4)+,y0
	macr	x0,y0,a     #qfc,r4

; AGC
	move	a,x0
	move		    y:<agc,y0
	mpy	x0,y0,a
	rep	#8
	asl	a

; then filter input samples and produce the Q channel signal
	move		    r2,r0
	clr	b
	move		    x:(r0)+n0,x0  y:(r4)+,y0
	rep	#iftaps-1
	mac	x0,y0,b     x:(r0)+n0,x0  y:(r4)+,y0
	macr	x0,y0,b     (r2)+n2

; AGC
	move	b,x0
	move		    y:<agc,y0
	mpy	x0,y0,b
	rep	#8
	asl	b

; output samples (I=a, Q=b)
	move	a,x0
	move	b,y0

; calculate the phase error, Im{rx*conj(osc)}
	mpy	y0,x1,b
	macr	-x0,y1,b
	move		    b,x:<nco		    ; this is control to the local NCO
	move		    b,y:-(r6)		    ; and also input signal for the decision filter

; AGC control
	move	x0,a				    ; find maximum
	abs	a
	move		    y:<agcmax,x0
	cmp	x0,a	    #>1,x1
	tlo	x0,a
	move		    a,y:<agcmax

	move		    y:<agcn,a		    ; if one block searched
	sub	x1,a	    #>agcN,x1
	move		    a,y:<agcn
	jne	<_agc

	move		    x1,y:<agcn		    ; calculate error and filter it
	clr	b	    y:<agcmax,a
	move		    b,y:<agcmax
	move		    #refLev,b

	sub	a,b	    #>@pow(2,-5)*agcGain/(fs/agcN),x1  ; rectangular integration
	move	b,x0
	move		    y:<agc,a
	macr	x0,x1,a
	move		    a,y:<agc
_agc

; Generate the output signal
	move		    #sinep,r0		    ; setup sine table pointers
	move		    #sinep+1,r1
	move		    x:<frqptr2,n0
	clr	b	    n0,n1
	move		    #sinel-1,m0
	move		    m0,m1
	move		    y:<frqptr2,b1	    ; convert frqinc fraction to signed
	lsr	b	    y:(r0+n0),x0
	move	b,x1	    y:(r1+n1),b

	sub	x0,b	    l:<frqptr2,y	    ; calculate difference of adjacent sine table entries
	move	b,x0	    y:(r0+n0),b
	macr	x0,x1,b     l:<frqinc2,a	    ; interpolate output sample
	add	y,a	    #>$ff,x0		    ; increment table pointer
	and	x0,a	    #0.7,y1		    ; output generated sample
	move	b,y0
	mpyr	y0,y1,a     a,l:<frqptr2
	jset	#xmit,x:<flag,_out1		    ; if xmit on, then output signal
	move		    p:(r7),a		    ; else give noise on output
	asr	a
_out1	move		    a,y:(r5)+n5

; Get next bit to be sent
	move		    x:<n,a		    ; check if new bit needed
	move		    #>1,x0
	sub	x0,a	    #>N,x0
	move		    a1,x:<n
	jne	<ss0

	move		    x0,x:<n		    ; yes, try to fetch a new one
	if kiss
	getbit
	jne	<_gb1
	andi	#$fe,ccr			    ; send zero if no data to be sent
	endif

_gb1	rol	a	    y:<prvxsym,x0	    ; NRZ-S coding
	not	a	    #>sinel,x1
	eor	x0,a	    #f0/fs,x0
	ror	a	    a1,y:<prvxsym

	jcc	<_gb2				    ; calculate output frq
	move		    #f1/fs,x0
_gb2	mpy	x0,x1,a
	move		    a10,l:<frqinc2

; Symbol synchro
ss0	move		    y:(r6),a		    ; comb filter to remove harmonics
	move		    y:(r6+n6),y0
	add	y0,a
	asr	a
	abs	a				    ; get absolute value to generate line at symbol frequence
	move	a,y0

	asr	a	    x:<clocka,b 	    ; remove DC with IIR LPF
	asr	b	    #sinep,r0		    ; and setup sine table pointers
	add	a,b	    y0,a
	move		    b,x:<clocka
	sub	b,a	    #sinep+1,r1
	move		    a,x:<clocke

	move		    x:<frqptr3,n0	    ; setup nco
	clr	b	    n0,n1
	move		    #sinel-1,m0
	move		    m0,m1
	move		    y:<frqptr3,b1	    ; convert frqinc fraction to signed
	lsr	b	    y:(r0+n0),x0
	move	b,x1	    y:(r1+n1),b

	sub	x0,b	    l:<frqptr3,y	    ; calculate difference of adjacent sine table entries
	move	b,x0	    y:(r0+n0),b
	macr	x0,x1,b     l:<frqinc3,a	    ; interpolate output sample
	add	y,a	    #>$100,x0		    ; increment table pointer
	cmp	x0,a	    #>$ff,x0		    ; if over 2PI then make a decision
	jlo	<ss1
	bset	#mkdsion,x:<flag
ss1	and	x0,a				    ; output generated sample
	move		    a,l:<frqptr3

	move		    x:<clocke,y0	    ; multiply local clock with derived signal
	move	b,y1
	mpyr	y0,y1,b     #-Ksym,y0
	move	b,y1
	mpyr	y0,y1,b     #f0/fs,y0

	add	y0,b	    #>sinel,y0		    ; and calculate the symbol clock frq
	move	b,y1
	mpy	y0,y1,b
	move		    b10,l:<frqinc3

; Decision filter
	bclr	#mkdsion,x:<flag		    ; check if time to make a decision
	jcc	<loop

	move		    #<dfc,r0		    ; yes, first filter the signal from DPLL
	nop
	clr	a	    x:(r0)+,x0	y:(r6)+,y0
	rep	#dftaps-1
	mac	x0,y0,a     x:(r0)+,x0	y:(r6)+,y0
	macr	x0,y0,a

; make symbol decision (with NRZ-S decoding)
	move		    y:<prvrsym,x0
	eor	x0,a	    a1,y:<prvrsym
	not	a
	btst	#23,a1

; forward to the HDLC handler
	if kiss
	putbit
	endif

; calculate decision error
	move		    y:<prvrsym,b
	abs	b	    #((f1-f0)/2)/Kg,x0
	sub	x0,b
	abs	b	    #DCDFil,x1

; filter it (with first order IIR filter)
	move	b,x0
	mpy	x0,x1,b     #(1.0-DCDFil),x0
	move		    y:<decierr,x1
	macr	x0,x1,b
	move		    b,y:<decierr

; and make decision if carrier detected
	jset	#car,x:<flag,_caron
	move		    #0.75/3-0.02,x0	    ; check if carrier appeared
	cmp	x0,b
	jgt	_car2
	bset	#2,x:$FFE4
	bset	#car,x:<flag
	caron
	jmp	<_car2

_caron	move		    #0.75/3+0.2,x0	    ; check if carrier disappeared
	cmp	x0,b
	jlt	_car2
	bclr	#2,x:$FFE4
	bclr	#car,x:<flag
	caroff
_car2

; loop forever
	jmp	<loop


; KISS parameter handling
reject	rts

; transmitter PTT control
ptt	jcc	_pttoff
	bset	#0,x:$FFE4
	bset	#xmit,x:<flag
	rts
_pttoff bclr	#0,x:$FFE4
	bclr	#xmit,x:<flag
	rts


; *** DEBUG ***
; special spy
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


	org	l:user_data

frqinc1 ds	1				    ; demodulator DPLL synthesizer
frqptr1 dc	0

frqinc2 dc	256*2200.0/fs*@pow(2,-23)	    ; output wave synthesizer
frqptr2 dc	0

frqinc3 dc	256*1200.0/fs*@pow(2,-23)	    ; symbol clock synthesizer
frqptr3 dc	0

buffer	dsm	buflen*4


	org	x:user_data+6

flag	dc	0

nco	dc	0

n	dc	N

clocka	dc	0
clockb	dc	0
clocke	ds	1

spyn	ds	1
spym	ds	1
apux	ds	1


; Decision filter
dfc	dc	-0.00041567696103898691,-0.00081890562387841972,-0.00077287490021642181,1.2127626692456339E-18,0.0012649095635366239
	dc	0.0022206573645156612,0.0019203394725415372,-2.4103681676650389E-18,-0.0027727292080740626,-0.0046459993765459286
	dc	-0.0038631268777868074,3.908467500183978E-18,0.0052444495308750288,0.008578347763639995,0.0069893345319871946
	dc	-5.5625867930785253E-18,-0.009204649706698589,-0.014902880347551255,-0.012059755791003872,7.1756438651449731E-18
	dc	0.015845903566402978,0.02579978381752315,0.02111502337770264,-8.5315994303790973E-18,-0.029056447470843367
	dc	-0.049268154359086921,-0.042777427656427156,9.4358452693819397E-18,0.073704602333730412,0.15797540308255884
	dc	0.22479821342437376,0.25020332089952807,0.22479821342437376,0.15797540308255884,0.073704602333730412
	dc	9.4358452693819397E-18,-0.042777427656427156,-0.049268154359086921,-0.029056447470843367,-8.5315994303790973E-18
	dc	0.02111502337770264,0.02579978381752315,0.015845903566402978,7.1756438651449731E-18,-0.012059755791003872
	dc	-0.014902880347551255,-0.009204649706698589,-5.5625867930785253E-18,0.0069893345319871946,0.008578347763639995
	dc	0.0052444495308750288,3.908467500183978E-18,-0.0038631268777868074,-0.0046459993765459286,-0.0027727292080740626
	dc	-2.4103681676650389E-18,0.0019203394725415372,0.0022206573645156612,0.0012649095635366239,1.2127626692456339E-18
	dc	-0.00077287490021642181,-0.00081890562387841972,-0.00041567696103898691
dftaps	equ	*-dfc


	org	y:user_data+6

agc	dc	@pow(2,-7)
agcn	dc	agcN
agcmax	dc	0

decierr dc	0

prvxsym ds	1
prvrsym ds	1

dfd	dsm	dftaps

; Bandpass filter (I)
ifc	dc	-2.6158392e-03,-9.0552363e-04,-7.8803034e-19,-3.3417659e-03,-3.9437887e-03
	dc	5.8712929e-03,1.1637071e-02,2.1618050e-03,5.6086809e-03,3.1781607e-02
	dc	2.4681104e-02,-2.6383625e-02,-3.1286527e-02,1.0386163e-02,-5.0248521e-02
	dc	-1.9543656e-01,-1.4305906e-01,1.7572822e-01,3.7525749e-01,1.7572822e-01
	dc	-1.4305906e-01,-1.9543656e-01,-5.0248521e-02,1.0386163e-02,-3.1286527e-02
	dc	-2.6383625e-02,2.4681104e-02,3.1781607e-02,5.6086809e-03,2.1618050e-03
	dc	1.1637071e-02,5.8712929e-03,-3.9437887e-03,-3.3417659e-03,-7.8803034e-19
	dc	-9.0552363e-04,-2.6158392e-03
iftaps	equ	*-ifc

; Bandpass filter (Q)
qfc	dc	-0.0000000e+00,-1.5684129e-03,1.3649086e-18,4.0924827e-19,-6.8308425e-03
	dc	-1.0169378e-02,-2.8502602e-18,3.7443561e-03,-9.7145203e-03,4.4779103e-17
	dc	4.2748926e-02,4.5697779e-02,1.5325978e-17,1.7989363e-02,8.7032991e-02
	dc	-2.2749469e-16,-2.4778556e-01,-3.0437020e-01,1.0574477e-15,3.0437020e-01
	dc	2.4778556e-01,-5.2679160e-16,-8.7032991e-02,-1.7989363e-02,3.0651955e-17
	dc     -4.5697779e-02,-4.2748926e-02,7.7881830e-17,9.7145203e-03,-3.7443561e-03
	dc	2.7091879e-17,1.0169378e-02,6.8308425e-03,-7.3706064e-18,-1.3649086e-18
	dc	1.5684129e-03,3.8441750e-18


	end
