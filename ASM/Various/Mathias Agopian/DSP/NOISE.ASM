; STMAG Aout 1996
; Effet DSP
;	- Noise Gate
;	- Compresseur
;	- Expenseur
; (c) AGOPIAN Mathias


	        page    132,56,1,1


adc			EQU		$ffef		; ADC address
dac			EQU		$ffef		; DAC address
M_CRA		EQU		$FFEC		; SSI Control Register A
M_CRB		EQU		$FFED		; SSI Control Register B
M_SR		EQU		$FFEE		; SSI Status Register
M_PCC		EQU 	$FFE1		; Port C Control Register
BCR			equ		$fffe
IPR			equ		$ffff
PBC			equ		$ffe0
HCR			equ		$ffe8		;Host Control Register
HSR			equ		$ffe9		;Host Status Register
HRX			equ		$ffeb		;Host Receive Register
HTX			equ		$ffeb		;Host Transmit Register

				org		x:0
EnvStates		dsm		8
SaveIn			ds		2
EnvG			ds		1
EnvD			ds		1
flags			dc		4+2+1		; Activer les 3 effets
save			ds		1

				org		y:0
StatesTempEnv	dc		EnvStates
out_buf			dsm		2
NoiseG			dc		0.01		; Niveau d'action du Noise Gate
NoiseD			dc		0.01

SCompG			dc		0.5
SCompD			dc		0.5
SExpG			dc		0.3
SExpD			dc		0.3


		; Passe bas 10Hz
		
fe			equ	49170.0
fc			equ	10.0
q0			equ	1.0
k			equ	1/@TAN(@cvf(3.141592654*(fc/fe)))
d			equ	q0*k*k+q0+2*k
alpha		equ	(q0*k*k+q0-2*k)/d
beta		equ	(q0*k*k-q0)/d
gamma		equ	6*(q0/d)

EnvCoefs	dc	alpha
			dc	alpha
			dc	gamma
			dc	gamma
			dc	beta
			dc	beta
			dc	gamma
			dc	gamma


			org		p:$0
			jmp		start

			; interruption d'emission des donnees

			org		p:$10
			movep	y:(r7)+,x:dac

			; Programme principal

		org		p:$40
start	movep	#$01F8,X:M_PCC		; Mode SSI.
		movep	#$4100,X:M_CRA		; 16 bits, 2 voix.
		movep	#$7800,X:M_CRB		; Interruptions TX OK, activer TX et RX, NetWork
		movep	#0,x:BCR			; Control du BUS: TOUJOURS ZERO
		movep	#1,x:PBC			; Port B = HOST
		movep   #$3000,x:IPR		; IPL 2 pour SSI

init	move	#SaveIn,r1
		movec	#-1,m1
		nop							; Sans ce NOP, le DSP plante !!!
		move	#1,n1
		move	#out_buf,r7			; Buffer de sortie
		movec	#2-1,m7				; droite/gauche

		andi	#$fc,mr				; Interruptions ON
	

main	jclr	#3,x:M_SR,*			; Attendre le debut de la trame
		movep	x:adc,a				; Lire la donnee sur l'ADC
		jclr	#7,x:M_SR,*			; Attendre la deuxieme voix
		movep	x:adc,b				; Lire la donnee

		move	a,x:(r1)			; Sauver les donnees
		move	b,x:(r1+n1)

		jsr		ExtractEnv			; Calculer l'enveloppe du son
		move	a,x:EnvG			; Sauver le resultat
		move	b,x:EnvD

		jsset	#0,x:flags,NoiseGate	; Noise gate actif ?
		jsset	#1,x:flags,Compress		; Compresseur actif ?
		jsset	#2,x:flags,Expense		; Expenseur actif ?

		move	x:(r1),a			; Lire les donnees calculees
		move	x:(r1+n1),b

		move	b,y:out_buf			; Ecriture sur le DAC.
		move	a,y:out_buf+1
		jmp		main				; Boucle infinie



NoiseGate
		move	#0,y0
		move	y:NoiseG,x0
		move			x:EnvG,a
		cmp		x0,a	x:EnvD,a	; si volume inferieur au seuil
		jgt		_okG
		move	y0,x:(r1)			; Couper le son
		move	y0,x:EnvG
_okG	move	y:NoiseD,x0			; idem pour l'autre voie
		cmp		x0,a
		jgt		_okD
		move	y0,x:(r1+n1)
		move	y0,x:EnvD
_okD	rts


;
; Formule du compresseur:
;	Si (Volume > Seuil)
;		Y = (Seuil / Volume) * X
;	Sinon
;		Y = X
;
;

Compress
		move	x:EnvG,b
		tst		b
		jeq		_okG
		move	y:SCompG,a
		cmp		a,b	
		jlt		_okG
		move	x:EnvG,x0
		jsr		division
		move	x:(r1),x0
		mpyr	x0,x1,a
		move	a,x:(r1)
_okG	move	x:EnvD,b
		tst		b
		jeq		_okD
		move	y:SCompD,a
		cmp		a,b
		jlt		_okD
		move	x:EnvD,x0
		jsr		division
		move	x:(r1+n1),x0
		mpyr	x0,x1,a
		move	a,x:(r1+n1)
_okD	rts


;
; Formule de l'expenseur:
;	Si (Volume < Seuil)
;		Y = (Seuil * X) / Volume
;	Sinon
;		Y = X
;
;

Expense
		move	x:EnvG,a
		tst		a
		jeq		_okG
		move	y:SExpG,y0
		cmp		y0,a
		jgt		_okG
		move	x:(r1),x0
		mpy		x0,y0,a
		move	x:EnvG,x0
		jsr		division
		move	x1,x:(r1)
_okG	move	x:EnvD,a
		tst		a
		jeq		_okD
		move	y:SExpD,y0
		cmp		y0,a
		jgt		_okD
		move	x:(r1+n1),x0
		mpy		x0,y0,a
		move	x:EnvD,x0
		jsr		division
		move	x1,x:(r1+n1)
_okD	rts


;
; Division signee sur 24 bits.
; realise A / X0
; resultat: X1 = quotient
;			B = reste (24 bits de precision)
;

division	abs		a		a,b
			eor		x0,b	b,x:save
			and		#$fe,ccr
			do		#$18,_loop
			div		x0,a
_loop		tfr		a,b
			jpl		_savequo
			neg		b
_savequo	tfr		x0,b	b0,x1
			abs		b
			add		a,b
			jclr	#23,x:save,_done
			move	#0,b0
			neg		b
_done		rts

;
; Calcul de l'enveloppe (volume) du son en entree:
; 1) Le son est redresse (Y = abs(X))
; 2) Le resultat est filtre a environ 10 Hz ( Y' = IIR_10_Hz(Y) )
;

ExtractEnv
	abs	a		y:StatesTempEnv,r0
	movec		#8-1,m0
	move		#EnvCoefs,r4
	movec		#-1,m4
	abs	b		a,x1
	move		b,y1	
	move				x:(r0)+,x0	y:(r4)+,y0	;y(n-2)L	
	mpy		-x0,y0,a	x:(r0)+,x0	y:(r4)+,y0	;y(n-2)R
	mpy		-x0,y0,b	x:(r0)+,x0	y:(r4)+,y0	;x(n-2)L
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;x(n-2)R
	mac		x0,y0,b		x:(r0)+,x0	y:(r4)+,y0	;y(n-1)L
	mac		x0,y0,a
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;y(n-1)R
	mac		x0,y0,b
	mac		x0,y0,b		x:(r0)+,x0	y:(r4)+,y0	;x(n-1)L
	mac		x0,y0,a
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;x(n-1)R
	mac		x0,y0,b
	mac		x0,y0,b
	macr	x1,y0,a
	macr	y1,y0,b		a,x:(r0)+
	move				b,x:(r0)+
	move				x1,x:(r0)+
	move				y1,x:(r0)+	
	move	r0,y:StatesTempEnv
	move	#-1,m0
	rts

