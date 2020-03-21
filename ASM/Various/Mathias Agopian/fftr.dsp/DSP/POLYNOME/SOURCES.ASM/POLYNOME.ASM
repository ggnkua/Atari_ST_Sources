
; Synthese de fonction par approximation
; en polynomes.
; (c) 1994 AGOPIAN Mathias pour STMAG


HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register

	org	y:$0
SinCoefs
	dc	-1/6.0		; 1/3!
	dc	+1/120.0	; 1/5!
	dc	-1/5040.0	; 1/7!
	dc	+1/362880.0	; 1/9!


	org	p:$0
	jmp	start
	
	org	p:$40
start	move	#-1,m4
interp	jclr	#0,X:HSR,*
	movep	x:HRX,a
	tst	a	#>1,x0
	jeq	expo
	cmp	x0,a
	jeq	sin
	jmp	interp

send2	jclr	#1,X:HSR,*
	movep	a2,x:HTX
send1	jclr	#1,X:HSR,*
	movep	a1,x:HTX
	jmp	interp


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Calcule exp(x) par approximation en polynomes
; Valable pour -1>x>1
; Le calcul effectue est : 1+x+x^2/2+x^3/6+x^4/24
; Donnee dans X0, resultat dans A

; Pour x>0, exp(x)>1, c'est a dire que A2 est utilise
; il ne faudra donc pas oublier de transmetre cette 
; valeur au 68030.

expo	jclr	#0,X:HSR,*
	movep	x:HRX,x0
	mpy	x0,x0,a				;x^2
	asr	a		a,y0		;(x^2)/2,	x^2
	mpyr	y0,y0,b		#(1.0/24.0),x1	;x^4,		(1/24)
	add	x0,a		b,y1		;+x,		x^4
	mac	y1,x1,a		#$800000-1,x1	;+(x^4)/24, 	1.0
	mpyr	x0,y0,b		#(1.0/6.0),y1	;x^3, 		1/2
	add	x1,a		b,x0		;+1,		x^3
	mac	x0,y1,a				;+(x^3)/6
	jmp	send2


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Calcule sin(x) par approximation en polynomes
; Valable pour -1>x>1
; Le calcul effectue est : x-x^3/6+x^5/120-x^7/5040+...
; On ne peut pas effectuer le calcul a un ordre superieur … 5
; car la precision (24 bits) est trop faible pour
; stoker les coefficients.
;
; Donnee dans X0, resultat dans A

sin	jclr	#0,X:HSR,*
	movep	x:HRX,x0
	move	#SinCoefs,r4
	mpy	x0,x0,b		x0,a
	move			b,y0
	do	#4,loop	
	mpy	x0,y0,b		y:(r4)+,y1
	mpy	y0,y0,b		b,y0
	mac	y0,y1,a		b,y0
loop	rnd	a
	jmp	send1


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Essayez de faire une routine pour le cosinus
; La formule est la suivante:
;
; cos(x)=1-x^2/2!+x^4/4!-x^6/6!+...[(-1)^n]*[x^2n/2n!]...
;
; rappel: n!=1*2*3*...*n

