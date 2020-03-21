
; (c) 1994 AGOPIAN Mathias
; pour STMAG

; Utilisation des interruptions courtes appliquee
; a la reception/emmission de sample stereo en DMA.

; Routine d'exemple de base pour le calcul
; d'effet temps reel sur du son par exemple



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


		org	y:0
frame		dc	0		; Flag pour la reception
out_buf		dsm	2		; buffer d'entree
in_buf		dsm	2		; buffer de sortie

		
	org	p:$0
	jmp	start			; on saute au debut du programme


	; ici on met la routine de reception
	; il s'agit d'une interruption courte.
	; La premiere instruction positionne un flag pour
	; que le programme principal puisse se synchroniser.
	; La deuxieme instruction recupere la donnee sur le port SSI
	; et la stocke en memoire.

	org	p:$c
	bset	#0,y:frame
	movep	x:adc,y:(r6)+
	
	; Idem, pour la routine d'emmission, mais ici
	; on a pas besoin de positionner le flag.

	org	p:$10
	movep	y:(r7)+,x:dac

	; Programme principal
	
	org	p:$40
start	movep	#$01F8,X:M_PCC		; diverses initialisations
	movep	#$4100,X:M_CRA		; pour le port SSI et le port
	movep	#$F800,X:M_CRB		; HOST
	movep	#0,x:BCR
	movep	#$3000,x:IPR
	movep	#$1,x:PBC

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
	
	bclr	#0,y:frame	;Buffers vides
	andi	#$fc,mr		;Interruptions activees
	
main	; ici on attend qu'une donn‚e
	; soit re‡ue.
	
	jclr	#0,y:frame,*

	; Maintenant on peut recuperer les donnees
	; En theorie, il faudrait attendre que la voix
	; gauche soit arrivee, en effacant le flag et
	; en attendant encore une fois, ca donne:
	; bclr	#0,y:frame
	; jclr	#0,y:frame,*
	;
	; Mais ca ralenti et ne sert pas a grand chose
	; qui va entendre le dephasage entre les deux voix
	; qui est de un 1/50000ieme de seconde (a 50Khz)?

	move	y:in_buf,x0
	move	y:in_buf+1,x1

	
	; - - - - - - - - - - - - - - -	
	; Ici vous pouvez faire n'importe quoi
	; comme par exemple traiter le son

	move	x0,a	; pour l'exemple, on ne fait que
	move	x1,b	; recopier l'entree
	
	; Notez que si vous n'avez pas attendu la voix gauche
	; votre routine ne doit pas etre trop rapide!
	; Sinon vous aurez reboucle alors que la voix gauche ne
	; sera pas encore arrivee!
	; - - - - - - - - - - - - - - -	
	
	; L… on renvoie les donnees
	
	move	a,y:out_buf
	move	b,y:out_buf+1

	; On efface le flag
	bclr	#0,y:frame
	
	; et on reboucle
	jmp	main
