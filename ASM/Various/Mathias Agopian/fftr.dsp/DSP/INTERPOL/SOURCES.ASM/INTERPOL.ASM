
; Synthese de fonction par
; interpolation lin‚aire
; (c) 1994 AGOPIAN Mathias pour STMAG


HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register



		; Creation de la table des racines carres
		; de x compris entre 0 et 1		

		org	y:$200
sqrttbl	
count		set	0
		dup	256
		dc	@sqt(@cvf(count)/256.0)
count		set	count+1
		endm


	org	p:$0
	jmp	start
	
	org	p:$40
start	ori	#4,omr		; Table interne de SINUS
	move	#$ff,m0		; modulo 256
	move	#$100,r0	; La table interne se trouve en Y:$100

interp	jclr	#0,X:HSR,*
	movep	x:HRX,a
	
	tst	a	#>1,x0
	jeq	sinus
	cmp	x0,a	#>2,x0
	jeq	cosinus
	cmp	x0,a
	jeq	sqr
	jmp	interp

send	jclr	#1,X:HSR,*
	movep	b,x:HTX
	jmp	interp
	
sinus	jclr	#0,X:HSR,*
	movep	x:HRX,a
	jclr	#0,X:HSR,*
	movep	x:HRX,a0
	move	#$100,r0	; Base des 256 valeurs de sinus
	jsr	Tli
	jmp	send

cosinus	jclr	#0,X:HSR,*
	movep	x:HRX,a
	jclr	#0,X:HSR,*
	movep	x:HRX,a0
	move	#$140,r0	; Base des 256 valeurs de cosinus
	jsr	Tli
	jmp	send


sqr	jclr	#0,X:HSR,*
	movep	x:HRX,a
	jclr	#0,X:HSR,*
	movep	x:HRX,a0
	move	#$200,r0	; Base des 256 valeurs de racine carre
	jsr	Tli
	jmp	send


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

; Routine d'interpolation linaire de f(x) avec x=>0
; En entr‚e:
; A1:A0 contient x (A1=partie entiere, A0 partie decimale)
; R0 contient l'adresse (memoire Y) de la table des points connus
; M0 contient le nombre de points connus -1
; En sortie:
; B contient le resultat ( F(x) ).
	
Tli	move	a1,n0		; Partie entiere de l'angle
	move	a0,a1		; Partie d‚cimale dans A
	lua	(r0)+n0,r0	; Calcul de l'adresse de Y0 (ie X0)
	lsr	a		; Il faut diviser A par 2 pour avoir
	move	a1,y0		; FRAC(x)
	move	y:(r0)+,b	; b=f(INT(x))=f(x0)=y0
	move	y:(r0),a	; a=Y1
	sub	b,a		; a=Y1-Y0
	move	a,x0
	mac	x0,y0,b		; b=Y0+(Y1-Y0)*FRAC(x)
	rts

