	page	132,63,1,1
	opt	rc
	title	'LPC Vocoder'

;***************************************************************
;* RECODER.ASM -- 2400 bit/s LPC Vocoder main control loop     *
;*							       *
;* Provides main control loop of the LPC codec. Wait (in order *
;* to reduce power consumption) for a one frame to be sampled. *
;* Then analyze it, send to the host computer (via serial line)*
;* check if block from the host computer has been received, and*
;* if there are any, then synthesize it.		       *
;*							       *
;* This module reserves registers as follows:		       *
;*  r7 - input/output sample pointer			       *
;*							       *
;* Copyright (C) 1992 by Alef Null. All rights reserved.       *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************

; Mies katsoo tuossa,
; on nainen sielt„ poissa.
; Itku katseen samentaa
; ja s„rky ohimoissa.
;
; Korvissa soi jo kohisten.
; Kuin takaa j„rjen rajan
; nyt mieleen tunkee, t„ytt„„ sen
; vain meri koko ajan.
;
; On poissa h„n, on l„htenyt
; pois yhteisilt„ teilt„.
; Vain kipu sy”pyy luuhun nyt
; ja nielee kaiken h„lt„.
;
;	Jacques Berg


	section Recoder

	xref	lpc_ana,lpc_syn

	org	p:

	nolist
	include 'macros'
	include 'leonid'
	list

; initialize input and output sample buffer pointers
	move		    #samples+2,r7
	move		    #(3*M)*4-1,m7

	move		    #samples,r6
	move		    #M*4,n6
	move		    #(3*M)*4-1,m6

; initialize codec
; fs = 8 kHz, line input, headphones and line output, max gain and zero attenuation
	ctrlcd	1,r6,3*M,MIC,22.5,22.5,LINEO|HEADP,0.0,0.0
	opencd	8

; initialize flags and parameters
	clr	a
	move		    a,x:<flags
	move		    a,x:<p_d
	move		    #speech,a1
	move		    a1,x:<speptr


;****************************
;*	  Main Loop	    *
;****************************
loop	waitblk r6,3*M,M

	move		    x:<speptr,r0
	move		    #-1,m0

; check if end of speech
	move		    r0,a
	move		    #>endspe,x0
	cmp	x0,a
	jne	<go_ahead
	stop					    ; we get reset this way

; load speech data
go_ahead
	move		    p:(r0)+,a1
	move		    a1,x:lpcin
	move		    p:(r0)+,a1
	move		    a1,x:lpcin+1
	move		    r0,x:<speptr

; decode and synthesize it
	jsr	<lpc_decode
	jsr	<lpc_syn

; finally update current frame pointer
	move		    (r6)+n6

	jmp	<loop


;****************************
;*	 DATA - AREA	    *
;****************************

	xdef	flags,p_d
	xdef	p_code,g_code,k_code
	xdef	p_s,g_s,k_s

	org	x:

; Global parameters
flags	ds	1				    ; global Vocoder flags
p_d	ds	1				    ; pitch adjustment

; Parameters for LPC analysis
p_code	ds	1				    ; pitch estimate
g_code	ds	1				    ; gain estimate
k_code	ds	P				    ; estimated reflection coefficients

; Parameters for LPC sythesis
p_s	ds	1				    ; current pitch period
g_s	ds	1				    ; gain for current output frame
k_s	ds	P				    ; current reflection coefficients

; Speech data pointer
speptr	ds	1

	endsec


	section Samples

	xdef	samples,temp,lotaps,hamming,glottal

	nolist
	include 'macros'
	list


	org	x:

samples ds	3*M				    ; input sample buffer
	ds	512-3*M

temp	ds	N

; Hamming window
hamming
dum	set	0
	dup	N
	dc	0.54-0.46*@cos(6.283185*@cvf(dum)/@cvf(N))
dum	set	dum+1
	endm


	org	y:

	ds	3*M				    ; output sample buffer
	ds	512-3*M

; 900 Hz lowpass filter generated using Parks-McClellan algorithm
;   sampling rate   8000 Hz
;   passband edge    840 Hz
;   stop band edge   960 Hz
;   filter lenght     79 taps
lotaps	dc	 1.619394e-02,5.805688e-03,3.155693e-03,-1.500173e-03,-6.545769e-03
	dc	-9.963868e-03,-1.022255e-02,-7.061145e-03,-1.754771e-03,3.332559e-03
	dc	 5.765334e-03,4.199639e-03,-8.617942e-04,-7.138900e-03,-1.151400e-02
	dc	-1.147496e-02,-6.426490e-03,1.780802e-03,9.467491e-03,1.274443e-02
	dc	 9.432186e-03,3.507424e-04,-1.070496e-02,-1.840716e-02,-1.827196e-02
	dc	-9.051937e-03,6.112294e-03,2.066623e-02,2.704929e-02,2.031219e-02
	dc	 9.089151e-04,-2.437167e-02,-4.415325e-02,-4.639930e-02,-2.320264e-02
	dc	 2.545267e-02,9.059131e-02,1.564397e-01,2.052803e-01,2.232958e-01	; center tap
	dc	 2.052803e-01,1.564397e-01,9.059131e-02,2.545267e-02,-2.320264e-02
	dc	-4.639930e-02,-4.415325e-02,-2.437167e-02,9.089151e-04,2.031219e-02
	dc	 2.704929e-02,2.066623e-02,6.112294e-03,-9.051937e-03,-1.827196e-02
	dc	-1.840716e-02,-1.070496e-02,3.507424e-04,9.432186e-03,1.274443e-02
	dc	 9.467491e-03,1.780802e-03,-6.426490e-03,-1.147496e-02,-1.151400e-02
	dc	-7.138900e-03,-8.617942e-04,4.199639e-03,5.765334e-03,3.332559e-03
	dc	-1.754771e-03,-7.061145e-03,-1.022255e-02,-9.963868e-03,-6.545769e-03
	dc	-1.500173e-03,3.155693e-03,5.805688e-03,1.619394e-02

; DoD stadard glottal pulse excitation
; Normalized for unity gain
glottal dc	.249,-.262,.363,-.362,.100,.367,.079,.078,.010,-.277
	dc	-.082,.376,.288,-.065,-.020,.138,-.062,-.315,-.247,-.078
	dc	-.082,-.123,-.039,.065,.064,.019,.016,.032,.018,-.015
	dc	-.029,-.021,-.018,-.027,-.031,-.022,-.012,-.010,-.010,-.004

	endsec

	end
