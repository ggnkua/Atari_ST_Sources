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
start	movec	#0,sp
		movep	#$01F8,X:M_PCC
		movep	#$4100,X:M_CRA
		movep	#$3800,X:M_CRB		; Interruptions TX et RX OFF, activer TX et  RX, NetWork
		movep	#0,x:BCR
		movep	#1,x:PBC
		movep	#16,x:HCR			; Initialisation du port HOST
		movep	#$3000,x:IPR

		move	#states,r0
		movec	#(ntaps*2)-1,m0
		
		move	#coefs,r4
		movec	#ntaps-1,m4

		andi	#$fc,mr				; ITs ON


main		jsset	#0,x:HSR,GetCoefs

			clr		a
			clr		b			x:(r0)+,x0	y:(r4)+,y1
			do		#ntaps-1,loopfir
			mac		x0,y1,a		x:(r0)+,x0
			mac		x0,y1,b		x:(r0)+,x0	y:(r4)+,y1
loopfir		macr	x0,y1,a		x:(r0)+,x0
			macr	x0,y1,b

			jclr	#3,x:M_SR,*
			movep	x:adc,x:(r0)+
			movep	a,x:dac

			jclr	#7,x:M_SR,*
			movep	x:adc,x:(r0)+
			movep	b,x:dac

			jmp	main


GetCoefs	move	#coefs,r4
			nop
			movep	x:HRX,y:(r4)+
			do		#ntaps-1,ReadHost
			jclr	#0,x:HSR,*
			movep	x:HRX,y:(r4)+
ReadHost	rts

