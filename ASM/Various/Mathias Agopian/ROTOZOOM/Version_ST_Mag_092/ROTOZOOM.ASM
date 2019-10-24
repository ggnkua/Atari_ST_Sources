;
; Rotations/Zooms DSP 56001
; Par AGOPIAN Mathias pour STMAG
;


HSR		equ	$ffe9		;Host Status Register
HRX		equ	$ffeb		;Host Receive Register
HTX		equ	$ffeb		;Host Transmit Register


SprAdd		equ	0
SprW		equ	1
SprH		equ	2
SprXinc		equ	3
SprXinc_d	equ	4
SprYinc		equ	5
SprYinc_d	equ	6
SprSinus	equ	7
SprCosinus	equ	8
SprLTrue	equ	9
SprHTrue	equ	10
SprXctr		equ	11
SprYctr		equ	12
StrucSize	equ	13

	org 	x:$0
Sprites	ds	StrucSize
Adresse	ds	1
TempH	ds	1
TempXc	ds	1
TempYc	ds	1
Black	ds	1
Xinc	ds	1
Yinc	ds	1
Col	ds	1
Line	ds	1

	org	y:Xinc
	ds	1
	ds	1
	ds	1
	ds	1

	org	p:$0
	jmp	start
	
	org	p:$40
start	ori	#4,omr		; Table interne de SINUS
	move	#-1,m0
	move	m0,m1
	move	m0,m2
	move	m0,m3
	move	m0,m4
	move	m0,m5
	move	m0,m6
	move	m0,m7
	
	jclr	#0,X:HSR,*
	movep	x:HRX,a
	move	a,x:Black		; Adresse d'un pixel noir
	
Command	jclr	#0,X:HSR,*
	movep	x:HRX,a
	tst	a	#>1,x0
	jeq	InitSprite
	cmp	x0,a
	jeq	DrawSprite
	jmp	Command


InitSprite
	jclr	#0,X:HSR,*
	move	#Sprites,r0
	
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Adresse du sprite
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Largeur du sprite en pixels
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Hauteur du sprite en pixels
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Partie entiere (inc X)	
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Partie decimale (inc X)
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Partie entiere (inc Y)
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Partie decimale (inc Y)
	
	move	#$100-1,m2	; Modulo pour table de sinus
	move	#$100,r1	; table de sinus
	move	#$100+64,r2	; table de cosinus
	jclr	#0,X:HSR,*
	movep	x:HRX,n1	; angle
	move	n1,n2
	move	y:(r1+n1),x0
	move	x0,x:(r0)+	; sinus
	move	#SprCosinus,n0
	move	y:(r2+n2),x0	; cosinus
	move	x0,x:(r0)+
	move	m0,m2

	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Largeur physique	
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Hauteur physique
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Point central	pour la rotation
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Point central	pour la rotation
	jmp	Command
	
DrawSprite
	move	x:Sprites+SprAdd,a
	move	a,x:Adresse

	move	#Xinc,r2
	move	#Sprites+SprXinc,r1
	clr	a
	move	x:(r1)+,x0
	move	x0,x:(r2)
	move	x:(r1)+,x0
	move	x0,y:(r2)+
	move	x:(r1)+,x0
	move	x0,x:(r2)
	move	x:(r1)+,x0
	move	x0,y:(r2)+
	move	a,l:Col
	move	a,l:Line
	
	move	#Sprites+SprSinus,r2
	move	x:Sprites+SprLTrue,x1	; Largeur en pixels (physique)
	move	x:Sprites+SprHTrue,y0	; Hauteur en pixels (physique)
	move	y0,x:TempH
	move	x:Sprites+SprXctr,y0	; centre X
	move	y0,x:TempXc
	move	x:Sprites+SprYctr,y0	; centre Y
	move	y0,x:TempYc

	do	x:Sprites+SprH,NextLine

	clr	a
	move	a,l:Col
	do	x:Sprites+SprW,NextPixel
	
		; x0=f(Col,Line)
		; y0=f(Col,Line)
				
		move	x:Col,a
		move	x:Line,b
		move		x:TempXc,x0
		sub	x0,a	x:TempYc,x0
		sub	x0,b	a,x0
		move		b,y0
	
		; Calcul de la Rotation et debordement de la zone du sprite
		move	x:TempXc,a
		move			x:(r2)+,y1	;sinus
		mac	-y0,y1,a	x:TempYc,b
		mac	x0,y1,b		x:(r2)-,y1	;cosinus
		macr	y0,y1,b
		jmi	out
		macr	x0,y1,a		b,y0
		jmi	out
		cmp	x1,a	x:TempH,x0
		jge	out
		cmp	x0,b
		jge	out
		
		; Calcul de l'adresse du pixel
		; a=partie entiere du pixel (x) logique
		; b=partie entiere de la ligne (y) logique
ok		mpy	y0,x1,b			; y*largeur -> resultat*2 dans B0
		move	b0,b			; 2*y*largeur dans B
		addl	b,a	x:Adresse,b	; B+2*x dans A
		add	b,a			; A+adresse
send		jclr	#1,X:HSR,*		;-> add=adresse+2*(y*largeur+x)
		movep	a,x:HTX			; Envoyer add du pixel
		
		move	l:Col,b			; Colone suivante
		move	l:Xinc,a		; c'est ici qu'est
		add	a,b			; calculer le zoom en X
		move	b,l:Col
	
NextPixel
	move	l:Yinc,a		; Ligne suivante, c'est
	move	l:Line,b		; l… qu'est calcule le zoom
	add	a,b			; en Y
	move	b,l:Line
	
NextLine
	jmp	Command


out	move	x:Black,a		; en cas de depassement
	jmp	send			; adresse du pixel noir
	


