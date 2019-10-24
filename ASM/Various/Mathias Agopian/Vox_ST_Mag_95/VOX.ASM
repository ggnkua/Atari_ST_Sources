; (c) 1995 AGOPIAN Mathias
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




fe_i		equ		16390
fe			equ		@cvf(fe_i)
nbspl		equ		@cvi(2.0*fe)
q0			equ		1.0

			; Passe bas 10Hz
fc			equ	10.0
k			equ	1.0/@TAN(@cvf(3.141592654*(fc/fe)))
d			equ	q0*k*k+q0+2*k
alpha		equ	(q0*k*k+q0-2*k)/d
beta		equ	(q0*k*k-q0)/d
gamma		equ	6.0*(q0/d)

			; Passe bas 60Hz
pbfc		equ	60.0
pbk			equ	1.0/@TAN(@cvf(3.141592654*(pbfc/fe)))
pbd			equ	q0*pbk*pbk+q0+2.0*pbk
pba			equ	(q0*pbk*pbk+q0-2.0*pbk)/pbd
pbb			equ	(q0*pbk*pbk-q0)/pbd
pbc			equ	(q0/pbd)


			; Passe bande 1500Hz
pbafc		equ	1500.0
pbaq0		equ	1.0
pbak		equ	1.0/@TAN(@cvf(3.141592654*(pbafc/fe)))
pbad		equ	 pbaq0*pbak*pbak+pbaq0+pbak
pbaa		equ	(pbaq0*pbak*pbak+pbaq0-pbak)/pbad
pbab		equ	(pbaq0*pbak*pbak-pbaq0)/pbad
pbac		equ	(pbak/pbad)

			; Passe bas 6000Hz (utilise comme passe haut)
phfc		equ	6000.0
phk			equ	1.0/@TAN(@cvf(3.141592654*(phfc/fe)))
phd			equ	q0*phk*phk+q0+2*phk
pha			equ	(q0*phk*phk+q0-2*phk)/phd
phb			equ	(q0*phk*phk-q0)/phd
phc			equ	(q0/phd)



				org		x:0
offset			ds		1
LowEnvStates	dsm		4
BandEnvStates	dsm		4
HighEnvStates	dsm		4
LowStates		dsm		4
BandStates		dsm		4
HighStates		dsm		4

				org		x:$200
Bravais
Results			ds		1
			

			
			org		y:0
			ds		1
TrueOffset	ds		1
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
invn		ds		1
max_quiet	dc		8000
cnt_quiet	dc		0
seuil_quiet	dc		0

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
			move	m3,m2
			movep	x:HRX,x0			; vide le HOST
			movep	x:HRX,x0
			movep	x:HRX,x0
			bclr	#0,y:frame			; Au debut, les buffers sont vides
			andi	#$fc,mr				; Interruptions actives
	
main		jsr		Comand				; Attendre une commande
			jsr		WaitSeuil			; Attendre que l'utilisateur parle
			tst		b
			jeq		main
			jsr		Aquisition			; Calcul des enveloppes
			jsr		SendToHost			; Renvoyer le resultat
			jmp		main				; On reboucle


WaitSeuil	jclr	#0,x:HSR,nobreak	; Un mot en provenance du HOST?
			movep	x:HRX,a				; Lire le mot recu
			move	#>100,x0
			cmp		x0,a
			jne		nobreak
			move	#>0,b
			rts
nobreak		jsr		GetOneSample		; Lire un sample
			move	y:seuil,x0
			cmpm	x0,a				; Compare la valeur absolue de x0 et a
			jle		WaitSeuil
			move	#>1,b
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
		clr		a	#Results,r3
		move	a,l:offset
		move	a,y:cnt_quiet
		
		move	#>nbspl,b
		do		b,loop0				; Lire pendant environ 2 secondes (65536 fois)
		jsr		GetOneSample			; Lire un sample Mono
		move	a,x0
		move	y:TrueOffset,y0
		sub		y0,a			#>1.0/nbspl,y0
		move	a,y:in
		move	l:offset,a
		mac		x0,y0,a
		move	a,l:offset

		
		; Test silence
		move	y:cnt_quiet,b
		move	y:in,a
		move	y:seuil_quiet,x0
		cmpm	x0,a		#>1,x0
		jlt		quiet
		clr		b
		jmp		nxt0
quiet	add		x0,b	y:max_quiet,x0
		cmp		x0,b
		jeq		fin_mot
nxt0	move	b,y:cnt_quiet


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
loop0	move	l:offset,a
		move	a,y:TrueOffset
		rts

fin_mot	enddo
		move		y:zerocnt,a
		clr		a	a,y:counter
		move	y:nbp,b
		move	#>Results,x0
		add		x0,b	r3,x0
		sub		x0,b
		do		b,fill0
		move	a,x:(r3)+
fill0	rts
		
SendToHost
		move	#Results,r3
		move	#1.0/256.0,y0
		clr		a	x:(r3)+,x0			; envoyer un mot bidon
		jclr	#1,x:HSR,*				; pour provoquer une
		movep	a,x:HTX					; interruption
		do		y:nbp,loop
		mpy		x0,y0,a		x:(r3)+,x0
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
		cmp		x0,a	#>4,x0
		jeq		npoints
		cmp		x0,a	#>100,x0
		jeq		pearson
		cmp		x0,a	#>10,x0
		jeq		faux_break
		cmp		x0,a
		jeq		get_volume
		jmp		Comand
go		rts

get_volume
		jsr		GetOneSample
		abs		a
		jclr	#1,x:HSR,*
		movep	a,x:HTX
		jmp		Comand
		
faux_break
		jclr	#0,x:HSR,*
		movep	x:HRX,a
		jmp		Comand
	
gseuil	jclr	#0,x:HSR,*
		movep	x:HRX,a
		move	a,y:seuil
		jclr	#0,x:HSR,*
		movep	x:HRX,a
		move	a,y:seuil_quiet	
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


		;*************************************
		;* Calcul de la formule (magique) de *
		;* Bravais et Pearson                *
		;*************************************

pearson	movep	#$0800,X:M_CRB		; Ne pas autoriser la reception de donnee
		move	#Bravais,r3
		jclr	#0,x:HSR,*
		movep	x:HRX,y1
		jclr	#0,x:HSR,*
		movep	x:HRX,n3
		clr		a		r3,r4

		; Premier signal, acquisition et moyenne
		do		n3,loop2
		jclr	#0,x:HSR,*
		movep	x:HRX,x0
		mac		x0,y1,a		x0,x:(r3)+
loop2	move	#Bravais,r3
		do		n3,loop21
		move	x:(r3),b
		sub		a,b
		move	b,x:(r3)+
loop21

		; Second signal, acquisition et moyenne
		clr		a
		do		n3,loop22
		jclr	#0,x:HSR,*
		movep	x:HRX,x0
		mac		x0,y1,a		x0,y:(r4)+
loop22	move	#Bravais,r4
		do		n3,loop23
		move	y:(r4),b
		sub		a,b
		move	b,y:(r4)+
loop23

		; Terme en (xi-<x>)*(yi-<y>)
		clr		a			#Bravais,r3
		move	a,r2
		move	r3,r4
		move	a,r5
		move				x:(r3)+,x0	y:(r4)+,y0
		rep		n3
		mac		x0,y0,a		x:(r3)+,x0	y:(r4)+,y0
		move	a,x0
		mpy		x0,x0,a		#Bravais,r3
		
		; Normalisation de A et calcul de l'exposant
		rep 	#47
		norm 	r2,a
		move	a,y1

		; Termes en (xi-<x>)^2 et (yi-<y>)^2 
		move	r3,r4
		clr		a			x:(r3)+,x0
		rep		n3
		mac		x0,x0,a		x:(r3)+,x0

		clr		b			y:(r4)+,y0
		rep		n3
		mac		y0,y0,b		y:(r4)+,y0

		rnd	a
		rnd b	a,x0
		move	b,y0
		mpy		x0,y0,a
		
		; Normalisation de A et calcul de l'exposant
		rep #47
		norm r5,a

		jclr	#1,x:HSR,*
		movep	y1,x:HTX
		jclr	#1,x:HSR,*
		movep	a,x:HTX
		jclr	#1,x:HSR,*
		movep	r2,x:HTX
		jclr	#1,x:HSR,*
		movep	r5,x:HTX

		movep	#$A800,X:M_CRB		; Re-autoriser la reception de donnee
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

