; (c) 1994 AGOPIAN Mathias
; pour STMAG
;
; "La voix de son maitre"




        page    132,56,1,1



adc			EQU		$ffef		; ADC address
dac			EQU		$ffef		; DAC address
M_CRA		EQU		$FFEC		; SSI Control Register A
M_CRB		EQU		$FFED		; SSI Control Register B
M_SR		EQU		$FFEE		; SSI Status Register
M_PCC		EQU		$FFE1		; Port C Control Register
BCR			equ		$fffe
IPR			equ		$ffff
PBC			equ		$ffe0
HCR			equ		$ffe8		;Host Control Register
HSR			equ		$ffe9		;Host Status Register
HRX			equ		$ffeb		;Host Receive Register
HTX			equ		$ffeb		;Host Transmit Register




fe_i		equ		32780
fe			equ		@cvf(fe_i)
q0			equ		1.0

			; Passe bas 10Hz
fc			equ	10.0
k			equ	1.0/@TAN(@cvf(3.141592654*(fc/fe)))
d			equ	q0*k*k+q0+2*k
alpha		equ	(q0*k*k+q0-2*k)/d
beta		equ	(q0*k*k-q0)/d
gamma		equ	6*(q0/d)

			; Passe bas 100Hz
pbfc		equ	100.0
pbk			equ	1.0/@TAN(@cvf(3.141592654*(pbfc/fe)))
pbd			equ	q0*pbk*pbk+q0+2*pbk
pba			equ	(q0*pbk*pbk+q0-2*pbk)/pbd
pbb			equ	(q0*pbk*pbk-q0)/pbd
pbc			equ	(q0/pbd)


			; Passe bande 1000Hz
pbafc		equ	1000.0
pbaq0		equ	0.4
pbak		equ	1.0/@TAN(@cvf(3.141592654*(pbafc/fe)))
pbad		equ	 pbaq0*pbak*pbak+pbaq0+pbak
pbaa		equ	(pbaq0*pbak*pbak+pbaq0-pbak)/pbad
pbab		equ	(pbaq0*pbak*pbak-pbaq0)/pbad
pbac		equ	(pbak/pbad)

			; Passe bas 3000Hz (utilise comme passe haut)
phfc		equ	3000.0
phk			equ	1.0/@TAN(@cvf(3.141592654*(phfc/fe)))
phd			equ	q0*phk*phk+q0+2*phk
pha			equ	(q0*phk*phk+q0-2*phk)/phd
phb			equ	(q0*phk*phk-q0)/phd
phc			equ	(q0/phd)



				org		x:0
LowEnvStates	dsm		4
BandEnvStates	dsm		4
HighEnvStates	dsm		4
LowStates		dsm		4
BandStates		dsm		4
HighStates		dsm		4

				org		x:$200
Results			ds		3*100
			

			
			org		y:0
in_buf		dsm		2
frame		ds		1
seuil		ds		1
in			ds		1
counter		ds		1
zerocnt		ds		1
temp0		ds		1
temp1		ds		1
temp2		ds		1
nbp			ds		1

TempLowEnvStates	dc	LowEnvStates
TempBandEnvStates	dc	BandEnvStates
TempHighEnvStates	dc	HighEnvStates
EnvCoefs			dc	alpha,gamma,beta,gamma
TempLowStates		dc	LowStates
TempBandStates		dc	BandStates
TempHighStates		dc	HighStates
LowCoefs			dc	pba,pbc,pbb,pbc
BandCoefs			dc	pbaa,pbac,pbab,pbac
HighCoefs			dc	pha,phc,phb,phc


			org		p:$0
			jmp		start

			org		p:$c
			bset	#0,y:frame			; Interruption courte de reception
			movep	x:adc,y:(r6)+
	
			org		p:$40
start		movep	#1,x:PBC			; Les initialisations habituelles
			movep	#$01F8,X:M_PCC
			movep	#$4100,X:M_CRA
			movep	#$A800,X:M_CRB		; Autoriser seulement la reception de donnee
			movep	#0,x:BCR
			movep	#$3000,x:IPR

init		move	#in_buf,r6			; Buffer d'entree
			move	#1,m6				; r6 pointe sur un buffer tournant de longueur 2
			move	#-1,m3
			movep	x:HRX,x0
			movep	x:HRX,x0
			movep	x:HRX,x0
			bclr	#0,y:frame			; Au debut, les buffers sont vides
			andi	#$fc,mr				; Interruptions actives
	
main		jsr		Comand				; Attendre une commande
			jsr		WaitSeuil			; Attendre que l'utilisateur parle
			jsr		Aquisition			; Calcul des enveloppes
			jsr		SendToHost			; Renvoyer le resultat
			jmp		main				; On reboucle


WaitSeuil	jsr		GetOneSample		; Lire un sample (modifie a et b)
			move	y:seuil,x0
			cmpm	x0,a				; Compare la valeur absolue de x0 et a
			jle		WaitSeuil
			rts
		
		
GetOneSample
			jclr	#0,y:frame,*		; Attendre la voie droite
			bclr	#0,y:frame		
			jclr	#0,y:frame,*		; Attendre la voie gauche
			bclr	#0,y:frame			; Au debut, les buffers sont vides
			move		y:in_buf,b		; Mixage des deux voies
			asr		b	y:in_buf+1,a
			addr	b,a
			rts			
	

Aquisition
		move	#Results,r3
		do		#0,loop0				; Lire pendant environ 2 secondes (65536 fois)
		jsr		GetOneSample			; Lire un sample Mono
		move	a,y:in
		
		move	y:in,a					; Passe bas
		jsr		low_pass
		jsr		ExtractLow
		move	a,y:temp0
		
		move	y:in,a					; Passe bande
		jsr		band_pass
		jsr		ExtractBand
		move	a,y:temp1
		
		move	y:in,a					; Passe haut
		jsr		hi_pass
		jsr		ExtractHigh
		move	a,y:temp2
		
		move	#>1,x0
		move	y:counter,a
		sub		x0,a
		tst		a
		jne		suite
		move	y:temp0,x0
		move	x0,x:(r3)+
		move	y:temp1,x0
		move	x0,x:(r3)+
		move	y:temp2,x0
		move	x0,x:(r3)+
		move	y:zerocnt,a
suite	move	a,y:counter
loop0
		rts

		
SendToHost
		move	#1.0/256.0,y0
		move	#Results,r3
		do		y:nbp,loop
		move	x:(r3)+,x0
		mpy		x0,y0,a
		jclr	#1,x:HSR,*
		movep	a,x:HTX
loop	rts



Comand	jclr	#0,x:HSR,*				; Un mot en provenance du HOST?
		movep	x:HRX,a					; Lire le mot recu
		tst		a		#>1,x0
		jeq		go
		cmp		x0,a	#>2,x0
		jeq		gseuil
		cmp		x0,a	#>3,x0
		jeq		zero
		cmp		x0,a
		jeq		npoints
		jmp		Comand
go		rts

gseuil	jclr	#0,x:HSR,*
		movep	x:HRX,a
		move	a,y:seuil
		jmp		Comand

zero	jclr	#0,x:HSR,*
		movep	x:HRX,a
		move	a,y:zerocnt
		move	a,y:counter
		jmp		Comand

npoints	jclr	#0,x:HSR,*
		movep	x:HRX,a
		move	a,y:nbp
		jmp		Comand


low_pass
		move	#4-1,m0
		move	y:TempLowStates,r0
		jsr		iir_low_pass
		move	r0,y:TempLowStates
		move	#-1,m0
		rts

band_pass
		move	#4-1,m0
		move	y:TempBandStates,r0
		jsr		iir_band_pass
		move	r0,y:TempBandStates
		move	#-1,m0
		rts

hi_pass	move	#4-1,m0
		move	y:TempHighStates,r0
		jsr		iir_high_pass
		move	r0,y:TempHighStates
		move	#-1,m0
		rts


ExtractLow
		move	#4-1,m0
		move	y:TempLowEnvStates,r0
		jsr		ExtractEnv
		move	r0,y:TempLowEnvStates
		move	#-1,m0
		rts

ExtractBand
		move	#4-1,m0
		move	y:TempBandEnvStates,r0
		jsr		ExtractEnv
		move	r0,y:TempBandEnvStates
		move	#-1,m0
		rts

ExtractHigh
		move	#4-1,m0
		move	y:TempHighEnvStates,r0
		jsr		ExtractEnv
		move	r0,y:TempHighEnvStates
		move	#-1,m0
		rts
		
ExtractEnv
	move	#-1,m4
	abs		a		#EnvCoefs,r4
iir	move	a,x1
	move				x:(r0)+,x0	y:(r4)+,y0	;y(n-2)L	
	mpy		-x0,y0,a	x:(r0)+,x0	y:(r4)+,y0	;x(n-2)L
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;y(n-1)L
	mac		x0,y0,a
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;x(n-1)L
	mac		x0,y0,a
	mac		x0,y0,a
	macr	x1,y0,a
	move	a,x:(r0)+
	move	x1,x:(r0)+
	rts

iir_low_pass
	move	#-1,m4
	move	#LowCoefs,r4
	jmp		iir


iir_band_pass
	move	#-1,m4
	move	#BandCoefs,r4
	move	a,x1
	move				x:(r0)+,x0	y:(r4)+,y0	;y(n-2)L
	mpy		-x0,y0,a	x:(r0)+,x0	y:(r4)+,y0	;x(n-2)L
	mac		-x0,y0,a	x:(r0)+,x0	y:(r4)+,y0	;y(n-1)L
	mac		x0,y0,a
	mac		x0,y0,a		x:(r0)+,x0	y:(r4)+,y0	;x(n-1)L / x0 est un dummy
	macr	x1,y0,a
	move	a,x:(r0)+
	move	x1,x:(r0)+
	rts

iir_high_pass
	move	#-1,m4
	tfr		a,b		#HighCoefs,r4
	jsr		iir
	sub		a,b
	tfr		b,a
	rts

