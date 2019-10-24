;
; Initialisation du DSP
;


        page    132,56,1,1


;
; D'abord quelques Equates histoire de ce simplifier la vie
;

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


		org	y:0
out_buf		dsm	2		; buffer d'entree
in_buf		dsm	2		; buffer de sortie

		
	org	p:$0
	jmp	start			; on saute au debut du programme


	; ici on met la routine de reception
	; il s'agit d'une interruption courte.

	org	p:$c
	movep	x:adc,y:(r6)+
	
	; Idem, pour la routine d'‚mission.

	org	p:$10
	movep	y:(r7)+,x:dac

	; Programme principal
	
	org	p:$40
start	movep	#$01F8,X:M_PCC		; Mode SSI.
	movep	#$4100,X:M_CRA		; 16 bits, St‚r‚o.
	movep	#$F800,X:M_CRB		; Interruptions RX/TX OK, activer RX/TX, NetWork
	movep	#0,x:BCR		; Control du BUS: TOUJOURS ZERO
	movep	#1,x:PBC		; Port B = HOST
	movep   #$3000,x:IPR		; IPL 2 pour SSI

	; R6 pointe sur le buffer
	; de reception des donn‚es
	; il s'agit d'un buffer tournant
	; modulo 2

	move	#in_buf,r6
	move	#2-1,m6
	
	; R7 pointe sur le buffer d'emission 
	; des donnees, il s'agit aussi d'un buffer
	; tournant modulo 2
	
	move	#out_buf+1,r7
	move	#2-1,m7
	
	andi	#$fc,mr			; Interruptions activ‚es
	
	;
	; Routine principale
	; 1) Attendre que des donn‚es arrivent.
	; 	1.1) Ces donn‚es on ‚t‚ lu par la routine d'interruption
	; 2) Lire ces donn‚es
	; 3) Les modifier (genre appliquer un effet)
	; 4) Ecrire ces donn‚es en m‚moire
	; 	4.1) C'est la routine d'interruption qui ‚crira les donn‚es sur le port SSI
	; 5) Reboucler en (1)
	;


main	; Etape (1)
	; ---------
	
	jclr	#3,x:M_SR,*
	jset	#3,x:M_SR,*


	; Etape (2) 
	; ---------
	move	y:in_buf,x0
	move	y:in_buf+1,x1


	; Etape (3)
	; ---------	
	move	x0,a
	move	x1,b
	
	; Etape (4)
	; ---------	
	move	a,y:out_buf
	move	b,y:out_buf+1

	; Etape (5)
	; ---------
	jmp	main
