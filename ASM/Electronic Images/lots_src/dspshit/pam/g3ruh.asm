	page	132,68,1,1
	opt	rc
	title	'G3RUH demodulator'

;***************************************************************
;* G3RUH.ASM -- 9600 bit/s G3RUH modem			       *
;*							       *
;* 9600 bit/s two level PAM demodulation with fixed rate       *
;* sampling and adaptive equalizer.			       *
;*							       *
;* PAM demodulation is based on some ideas presented in book   *
;*	Lee, E., A., Messerschmitt, D., G.:		       *
;*	"Digital Communication",			       *
;*	Kluwer, 1988					       *
;*							       *
;* Symbol synchronization is base on the article	       *
;*	Mueller, K., H., Mller, M.:			       *
;*	"Timing Recovery in Digital Synchronous Data           *
;*	Receivers",                                            *
;*	IEEE Trans. on Comm., Vol. COM-23, No. 5, May 1976     *
;*							       *
;* This module uses registers as follows:		       *
;*  r0 - general purpose (temporary use)		       *
;*  r1 - general purpose (temporary use)		       *
;*  r2 - sample buffer pointer				       *
;*  r4 - output filter pointer				       *
;*  r6 - general purpose (temporary use)		       *
;*							       *
;* Copyright (C) 1993, 1994 by Tecnomen. All rights reserved.  *
;* Author(s): Jarkko Vuori				       *
;* Modification(s):					       *
;***************************************************************

kiss	set	1				    ; give KISS data/debug data for SPY

	nolist
	include 'leonid'
	list


buflen	equ	256				    ; codec sample buffer lenght

fs	equ	48000.0 			    ; sampling frequency
fd	equ	9600.0				    ; decision rate
I	equ	2				    ; interpolation factor
D	equ	5				    ; decimation factor 48k*(I/D)=19.2k

; AGC
refLev	equ	0.4				    ; reference level for AGC
agcN	equ	20				    ; agc analyse block lenght
agcGain equ	100.0				    ; agc integrator gain

; symbol synchro
syncf	equ	0.9

; DCD
DCDFil	equ	0.05				    ; decision error IIR LPF coefficient

; G3RUH specific
poly	equ $10800				    ; G3RUH,K9NG scrambler polynomial (x^17 + x^12 + 1)

; flags
xmit	equ	0				    ; xmit on/off
car	equ	2				    ; carrier on/off
spyflg	equ	3				    ; spy on/off


; macro for red LED handling
pttled	macro	mode
	b\mode	#0,x:$ffe4
	endm

; macro for green LED handling
carled	macro	mode
	b\mode	#2,x:$ffe4
	endm

; first order high-pass IIR filter
; input in a, output in a
; frq is -3dB point (fc/fs)
hpass	macro	acc,frq,store
c1	set	-1.0/@cos(6.28319*frq)*(1.0-@sin(6.28319*frq))
	move		    acc,x0
	move		    #>(1.0-c1)/2.0,y0
	mpyr	x0,y0,acc   x:<store,y0
	move		    acc,x:<store
	sub	y0,acc	    x:<store+1,x0
	move		    #>c1,y0
	macr	-x0,y0,acc
	move		    acc,x:<store+1
	endm


	org	p:user_code

	move		    #buffer+2,r7	    ; codec sample buffer ptr
	move		    #buflen*4-1,m7

	move		    #buffer,r2		    ; sample buffer read ptr
	move		    #4-1,n2
	move		    #buflen*4-1,m2

	move		    #filtx,r4		    ; transmit filter ptr
	move		    #oftaps-1,m4

	if kiss
	move	#reject,a1			    ; serial interface to KISS mode
	move	#ptt,b1
	opensc
	endif

; fs = 48 kHz, line input, line output, no gain and attenuation
	ctrlcd	1,r2,buflen,LINEI,0.0,0.0,LINEO,0.0,0.0
	opencd	fs/1000.0

; wait for one complete block
loop	waitblk r2,buflen,D

; then filter the left channel
	move		    #buflen*4-1,m0
	move		    #-4,n0

; calculate even phase
	move		    x:<eadr,r6
	move		    r2,r0
	clr	a
	move		    x:(r0)+n0,x0  y:(r6)+,y0
	rep	#iftaps-1
	mac	x0,y0,a     x:(r0)+n0,x0  y:(r6)+,y0
	macr	x0,y0,a     #ocoeffs,r1

; high-pass filter the signal (to reject CS4215 offset)
	hpass	a,5.0/(2.0*fd),hpf		    ; fc = 5 Hz

; AGC
	move	a,x0
	move		    y:<agc,y0
	mpy	x0,y0,a
	rep	#8
	asl	a
	move		    a,y:<s2

; calculate two first phases of the output filter
	clr	b	    (r2)+
	move		    x:(r1)+,x0	  y:(r4)+,y0
	rep	#oftaps-1
	mac	x0,y0,b     x:(r1)+,x0	  y:(r4)+,y0
	macr	x0,y0,b
	move		    b,y:(r2)+n2

	clr	b	    (r2)+
	move		    x:(r1)+,x0	  y:(r4)+,y0
	rep	#oftaps-1
	mac	x0,y0,b     x:(r1)+,x0	  y:(r4)+,y0
	macr	x0,y0,b
	move		    b,y:(r2)+n2

; calculate odd phase
	move		    x:<oadr,r6
	move		    r2,r0
	clr	a
	move		    x:(r0)+n0,x0  y:(r6)+,y0
	rep	#iftaps-1
	mac	x0,y0,a     x:(r0)+n0,x0  y:(r6)+,y0
	macr	x0,y0,a

; high-pass filter the signal (to reject CS4215 offset)
	hpass	a,5.0/(2.0*fd),hpf		    ; fc = 5 Hz

; AGC
	move	a,x0
	move		    y:<agc,y0
	mpy	x0,y0,a
	rep	#8
	asl	a
	move		    a,y:<s1

; make decision (for symbol synchro)
	tst	a	    #refLev,x0
	tpl	x0,a
	move		    #-refLev,x0
	tmi	x0,a

	move		    y:<d1,x0		    ; update decisions
	move		    x0,y:<d3
	move		    a,y:<d1

; calculate three last phases of the output filter
	clr	b	    (r2)+
	move		    x:(r1)+,x0	  y:(r4)+,y0
	rep	#oftaps-1
	mac	x0,y0,b     x:(r1)+,x0	  y:(r4)+,y0
	macr	x0,y0,b
	move		    b,y:(r2)+n2

	clr	b	    (r2)+
	move		    x:(r1)+,x0	  y:(r4)+,y0
	rep	#oftaps-1
	mac	x0,y0,b     x:(r1)+,x0	  y:(r4)+,y0
	macr	x0,y0,b
	move		    b,y:(r2)+n2

	clr	b	    (r2)+
	move		    x:(r1)+,x0	  y:(r4)+,y0
	rep	#oftaps-1
	mac	x0,y0,b     x:(r1)+,x0	  y:(r4)+,y0
	macr	x0,y0,b     (r4)-
	move		    b,y:(r2)+n2

; AGC control
	move		    y:<s1,a
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
	abs	a
	move		    a,y:<agc
_agc

; Symbol synchro
	move		    y:<d1,a
	move		    y:<d3,x0
	sub	x0,a	    y:<s2,x0
	move	a,x1
	move		    y:<rwfilt,b
	macr	x0,x1,b     #syncf,x0

	cmpm   x0,b	    b,y:<rwfilt 	    ; check if limits reached
	jlt	<_sync3

	tst	b				    ; yes, clear filter and advance or retard sampling
	jpl	_sync1
	jsr	<retard
	move		    #>-2*syncf/3,x0
	jmp	_sync2
_sync1	jsr	<advance
	move		    #>2*syncf/3,x0
_sync2	move		    x0,y:<rwfilt
_sync3

; unscramble symbol, result in C
	move		    y:<d1,a		    ; databit to C
	asl	a
	move		    x:<usrem,b1
	jcc	<unscram
	move		    #>(poly<<1)|1,x0
	eor	x0,b
unscram lsr	b
	move		    b1,x:<usrem

; make symbol decision (with NRZ-S decoding), databit in C, result in C
	rol	b	    y:<prvrsym,x0
	eor	x0,b	    b1,y:<prvrsym
	not	b
	lsr	b

; forward to the HDLC handler
	if kiss
	putbit
	endif

; Get next bit to be sent
	if kiss
	getbit					    ; fetch a new one
	jne	<_gb1
	endif
	andi	#$fe,ccr			    ; send zero if no data to be sent

_gb1	rol	a	    y:<prvxsym,x0	    ; NRZ-S coding
	not	a
	eor	x0,a
	ror	a	    a1,y:<prvxsym

	clr	a				    ; scrambler, databit in C flag, result in a (-1 or 1)
	rol	a	    x:<srem,x0
	eor	x0,a	    #-0.7,x1
	lsr	a	    #>poly,x0
	jcc	<_gb2
	eor	x0,a
_gb2	move		    a1,x:<srem
	move		    #0.7,a
	tcc	x1,a

	jset	#xmit,x:<flag,_out1		    ; if xmit on, then mute output
	clr	a
_out1	move		    a,y:(r4)		    ; put bit to output filter


; calculate the eye opening
	move		    y:<d1,b
	move		    y:<s1,x0
	sub	x0,b
	abs	b	    #DCDFil,x1

; filter it (with first order IIR filter)
	move	b,x0
	mpy	x0,x1,b     #(1.0-DCDFil),x0
	move		    y:<eyefilt,x1
	macr	x0,x1,b
	move		    b,y:<eyefilt

; and make decision if carrier detected
	jset	#car,x:<flag,_caron
	move		    #0.6/3-0.07,x0	   ; check if carrier appeared
	cmp	x0,b
	jgt	_car2
	carled	set
	bset	#car,x:<flag
	caron
	jmp	<_car2

_caron	move		    #0.6/3+0.07,x0	   ; check if carrier disappeared
	cmp	x0,b
	jlt	_car2
	carled	clr
	bclr	#car,x:<flag
	caroff
_car2

	if !kiss
	move		    y:<eyefilt,a
	jsr	<spy
	endif

; all this again, sigh!
	jmp	<loop


; KISS parameter handling
reject	rts

; transmitter PTT control
ptt	jcc	_pttoff
	pttled	set
	bset	#xmit,x:<flag
	rts
_pttoff pttled	clr
	bclr	#xmit,x:<flag
	rts

; retard sampling
retard	move		    x:<eadr,a		    ; select previous filter tap set
	move		    #>iftaps,x0
	sub	x0,a	    #>icoeffs,x0
	cmp	x0,a	    #>ifbnks*iftaps,x0
	jhs	<_adv1
	move		    (r2)+
	add	x0,a	    (r2)+n2		    ; jumped over the first taps set
_adv1	add	x0,a	    a,x:<eadr		    ; store those new tap set addresses
	move		    a,x:<oadr
	rts

; advance sampling
advance move		    x:<eadr,a		    ; select next filter tap set
	move		    #>iftaps,x0
	add	x0,a	    #>icoeffs+ifbnks*iftaps,x0
	cmp	x0,a	    #>ifbnks*iftaps,x0
	jlo	<_ret1
	move		    (r2)-
	sub	x0,a	    (r2)-n2		    ; jumped over the first taps set
_ret1	add	x0,a	    a,x:<eadr		    ; store those new tap set addresses
	move		    a,x:<oadr
	rts


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

n	dc	8

hpf	ds	2				    ; data storage for the input DC-cancellation IIR filter

eadr	dc	icoeffs 			    ; input polyphase filter even bank pointer
oadr	dc	icoeffs+ifbnks*iftaps		    ; input polyphase filter odd  bank pointer

srem	ds	1
usrem	ds	1

flag	dc	0
spyn	ds	1
spym	ds	1

	include 'filtx.asm'

buffer	dsm	buflen*4


	org	y:user_data

s1	ds	1
d1	ds	1
s2	ds	1
d3	ds	1

rwfilt	dc	0
eyefilt dc	0

prvrsym ds	1				    ; previous received symbol
prvxsym ds	1				    ; previous xmitted symbol

agc	dc	@pow(2,-7)
agcn	dc	agcN				    ; agc block counter
agcmax	dc	0

filtx	dsm	oftaps

	include 'filtr.asm'

	dsm	buflen*4

	end
