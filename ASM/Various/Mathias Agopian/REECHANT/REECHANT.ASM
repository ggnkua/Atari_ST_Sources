;
; Filtre FIR a 63 coefficients
;

		page	132,60

adc			EQU		$ffef		; ADC address
dac			EQU		$ffef		; DAC address
M_CRA		EQU     $FFEC		; SSI Control Register A
M_CRB		EQU     $FFED		; SSI Control Register B
M_SR		EQU     $FFEE		; SSI Status Register
M_PCC		EQU     $FFE1		; Port C Control Register
BCR			equ		$fffe
IPR			equ		$ffff
PBC			equ		$ffe0
HCR			equ		$ffe8		;Host Control Register
HSR			equ		$ffe9		;Host Status Register
HRX			equ		$ffeb		;Host Receive Register
HTX			equ		$ffeb		;Host Transmit Register

ntaps		equ		63			; Ordre du filtre


; ---------------------
;  Donn‚es
; ---------------------


			org		x:$0
states		dsm		ntaps*2		; Stockage des x(n) pass‚s

			org		y:$0
coefs		dsm		ntaps		; Stockage des coefficients h(k)

; ---------------------
;  Programme principal
; ---------------------

        org		p:0
        jmp		start

		org		p:$40
start	ori		#$3,mr				; ITs OFF
		movec	#0,sp
		movep	#$01F8,X:M_PCC
		movep	#0,x:BCR
		movep	#1,x:PBC
		movep	#16,x:HCR			; Initialisation du port HOST
		movep	#$3000,x:IPR

		move	#states,r0
		movec	#(ntaps*2)-1,m0
		
		move	#coefs,r4
		movec	#ntaps-1,m4

		jsr		GetCoefs


main		clr		a
			clr		b			x:(r0)+,x0	y:(r4)+,y1
			do		#ntaps-1,loopfir
			mac		x0,y1,a		x:(r0)+,x0
			mac		x0,y1,b		x:(r0)+,x0	y:(r4)+,y1
loopfir		macr	x0,y1,a		x:(r0)+,x0
			macr	x0,y1,b

			jclr	#1,x:HSR,*
			movep	a,x:HTX
			jclr	#1,x:HSR,*
			movep	b,x:HTX

			jclr	#0,x:HSR,*
			movep	x:HRX,x:(r0)+
			jclr	#0,x:HSR,*
			movep	x:HRX,x:(r0)+

			jmp	main


GetCoefs	move	#coefs,r4
			do		#ntaps,ReadHost
			jclr	#0,x:HSR,*
			movep	x:HRX,y:(r4)+
ReadHost	rts

