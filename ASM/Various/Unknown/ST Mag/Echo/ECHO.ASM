; Echo double

        page    132,56,1,1



adc		EQU	$ffef		; ADC address
dac		EQU	$ffef		; DAC address
M_CRA		EQU     $FFEC           ; SSI Control Register A
M_CRB		EQU     $FFED           ; SSI Control Register B
M_SR		EQU     $FFEE           ; SSI Status Register
M_PCC		EQU     $FFE1           ; Port C Control Register
BCR		equ	$fffe
IPR		equ	$ffff
PBC		equ	$ffe0
HCR		equ	$ffe8		;Host Control Register
HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register

retard_max	equ	16000
retard1		equ	16000
retard2		equ	10000

		org	x:0
ligne1		dsm	retard_max	; Premiere ligne a retard

		org	y:0
ligne2		dsm	retard_max	; Deuxieme ligne a retard
out_buf		dsm	2
Org		dc	0.6		; Volume de l'original
Rvb1		dc	0.15		; Volume du son r‚fl‚chi 1
Rvb2		dc	0.25		; Volume de son r‚fl‚chi 2
Feedback1	dc	0.15		; Feedback 1
Feedback2	dc	0.15		; Feedback 2


	; Vecteur reset
	
	org	p:$0
	jmp	start

	; interruption d'‚mission des donn‚e

	org	p:$10
	movep	y:(r7)+,x:dac

	; Programme principal

	org	p:$40
start	movep	#$01F8,X:M_PCC		; Mode SSI.
	movep	#$4100,X:M_CRA		; 16 bits, 2 voix.
	movep	#$7800,X:M_CRB		; Interruptions TX OK, activer TX et RX, NetWork
	movep	#0,x:BCR		; Control du BUS: TOUJOURS ZERO
	movep	#1,x:PBC		; Port B = HOST
	movep   #$3000,x:IPR		; IPL 2 pour SSI

init	move	#ligne1,r1		; Adresse de la 1er file
	move	#retard1-1,m1		; Cette valeur d‚termine le retard
	move	#ligne2,r4		; idem
	move	#retard2-1,m4		; idem
	move	#out_buf,r7		; Buffer de sortie
	move	#2-1,m7			; droite/gauche
	andi	#$fc,mr			; Activer les interruptions
	
main	jclr	#3,x:M_SR,*		; Attendre le debut de la trame
	movep	x:adc,a			; Lire la donn‚e sur l'ADC
	jclr	#7,x:M_SR,*		; Attendre la deuxieme voix
	movep	x:adc,b			; Lire la donn‚e
	
; Calcul de l'echo
	
	; Initialisation
	
	move	a,x1
	move	b,y1
	add	b,a

	; Calcul du 1er echo (1ere montagne)
	
	asr	a		x:(r1),x0
	tfr	a,b				y:Feedback1,y0
	macr	x0,y0,a				y:Rvb1,y0
	mpy	x0,y0,a		a,x:(r1)+
	
	; Calcul de 2nd (2eme montagne)
	
	move			y:(r4),x0
	move					y:Feedback2,y0
	macr	x0,y0,b				y:Rvb2,y0	
	macr	x0,y0,a		b,y:(r4)+

	; Ajout du son original (st‚r‚o)
	
	tfr	a,b				y:Org,y0
	macr	x1,y0,a
	macr	y1,y0,b

	; Sortie sur les convertisseurs
	
	move	a,y:out_buf
	move	b,y:out_buf+1
	jmp	main

