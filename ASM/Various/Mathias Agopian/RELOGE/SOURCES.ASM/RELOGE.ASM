
; Exemple de DSP subroutine avec relocation
; (c) 1994 AGOPIAN Mathias
; Pour STMAG.
;
; Exemple d'une subroutine de tri
; (sources Motorola)


; Format de la page pour le listing (optionnel)

	        page    132,56,1,1
	        
; Ici les equates	        
	        
HCR		equ	$ffe8	; Host Control Register
HSR		equ	$ffe9	; Host Status Register
HRX		equ	$ffeb	; Host Receive Register
HTX		equ	$ffeb	; Host Transmit Register

Bss_x		equ	$3f00	; Adresse de la zone bss
Bss_y		equ	$3f00	; Adresse de la zone bss
NbItems		equ	100	; nombre de mot a trier
zone_a_trier	equ	Bss_x

	
	; Dans cet exemple, on ne sauve pas les registres
	; en effet, etant donn‚ que l'on s'assure que le DSP
	; n'etait pas en train de travailler, ce n'est pas la
	; peine.
	; Mais il faudra imperativement faire un DSP_LOCK()
	; pour en etre sur.
	

	org	p:$0		; le prg DOIT etre assemble a l'adresse p:0
	
	movec	#-1,m0
	movec	m0,m1
	movec	m0,m2
	movep	x:<<HRX,r0	; Adresse de base du programme
	
	
	; Ici on reloge la routine de relocation !
	
	move	r0,r1		; Adresse de base
	move	#<RelocBcl-1,n1	; Adresse de la fin de la boucle-1
	move	#Loop+1,n0	; modifier le mot d'extension de l'instruction DO
	move	(r1)+n1		; nouvelle adresse
	movem	r1,p:(r0+n0)	; on modifie l'instruction DO
	
	
	; Routine de relocation proprement dite
	
	move	r0,r1		; Adresse de base
	move	#>RelocTbl,n1	; Offset sur la table de relocation
	nop			; nop a cause de la pipe-line
	move	(r1)+n1		; -> Adresse veritable de la table de relocation

Loop	do	#(RelocTblEnd-RelocTbl),RelocBcl
	movem	p:(r1)+,n0	; On recupere l'Offset a modifier dans la table
	move	r0,r2		; Adresse de base du programme
	movem	p:(r0+n0),n2	; offset auquel il faut ajouter l'adresse de base
	nop			; Un nop a cause de la pile-line
	move	(r2)+n2		; r2=r2+n2 -> on obtient l'adresse correcte
	nop			; Un nop a cause du pile-line
	movem	r2,p:(r0+n0)	; on reecrit cette adresse
RelocBcl
	move	#<SubRoutine,n0			; Offset de la subroutine
	move	#%000010101111000010000000,x0	; code de l'instruction JMP
	lua	(r0)+n0,r1			; Adresse veritable de la subroutine
	movem	x0,p:(r0)+			; on poke le JMP
	movem	r1,p:(r0)			; on poke la nouvelle adresse
	
	
	; Ici on met la subroutine, comme si de rien etait
	; il faut ajouter des labels aux endroits a modifier
	; (ici se sont "do1" et "do2").
	
SubRoutine

	; - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; Voici la dsp subroutine
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	movec	#-1,m0
	movec	m0,m1
	movec	m0,m2
	movec	m0,m4

	move	#zone_a_trier,r4		; charger les donnees a trier
do0	do	#NbItems,loop0
w0	jclr	#0,X:HSR,w0
	movep	x:HRX,x:(r4)+
loop0

	move	#NbItems,r4        		; nombre de mots a trier
        move	#zone_a_trier,r2
        move	#-2,n1  

do1	do	#NbItems-1,loop2
	lua	(r2)+,r0
	move	x:(r2),a	y:(r4)-,b
	move	x:(r0)+,b 
	move	r0,r1

do2	do      r4,loop1
	cmp     b,a		x:(r0)+,b	b,y0
	tge     y0,a		r0,r1
loop1
	move	x:(r2),y0
	move	a,x:(r2)+
	move	y0,x:(r1+n1)
loop2

	move	#zone_a_trier,r4		; renvoyer les donnees triees
do3	do	#NbItems,loop3
w1	jclr	#1,X:HSR,w1
	movep	x:(r4)+,x:HTX
loop3
	rti


	; - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; fin de la subroutine
	; - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
RelocTbl			; ici, on met la table de relocation
	dc	do0+1
	dc	do1+1
	dc	do2+1
	dc	do3+1
	dc	w0+1
	dc	w1+1
RelocTblEnd

