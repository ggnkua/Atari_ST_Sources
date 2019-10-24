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

facteur		equ		0
points		equ		1024
data		equ		$400
odata		equ		$400
coef		equ		$800


		include 'SINCOS.ASM'
		include 'FFTR2CC.ASM'

; ----------------------------------------------------
;  Precalcul des termes en exp(- 2 * i * pi * k * l )
; ----------------------------------------------------

		sincos  points,coef

; ---------------------
;  Programme principal
; ---------------------

        org		p:0
        jmp		start

		org		p:$40
start	movep	#16,x:HCR	; Initialisation du port HOST
		ori		#3,mr		; Interruptions non autorisees

main	movec	#-1,m0
		move	#data,r0	; Adresse des echantillons

	; ---------------------------
	; Acquisition des echantillons 
	; ---------------------------

		jclr	#0,x:HSR,*
		movep	x:HRX,x:facteur

		do		#points,loop
		jclr	#0,x:HSR,*
		movep	x:HRX,x:(r0)
		jclr	#0,x:HSR,*
		movep	x:HRX,y:(r0)+
loop	


	; -------------------------
	; Calcul de la DFS par FFT
	; -------------------------

		fftr2cc	points,data,coef
		
	; --------------------------------
	; Retour de donnees vers le 68030
	; --------------------------------

		movec	#0,m0			; Bit reversed
		move	#points/2,n0	; 2^(k-1) avec k le nombre d'echantillon
		move	#odata,r0		; Adresse des echantillons: L * 2^k

		move	x:facteur,y0	; Facteur de division
		move	x:(r0),x0

		do		#points,loop2
		jclr	#1,x:HSR,*					; Partie reelle
		mpyr	x0,y0,a		y:(r0)+n0,x0
		movep	a,x:HTX

		jclr	#1,x:HSR,*					; Partie imaginaire
		mpyr	x0,y0,a		x:(r0),x0
		movep	a,x:HTX		
loop2	



		jmp	main
