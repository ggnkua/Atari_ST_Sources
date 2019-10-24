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
SprYinc		equ	4
SprSinus	equ	5
SprCosinus	equ	6
SprLTrue	equ	7
SprHTrue	equ	8
SprXctr		equ	9
SprYctr		equ	10
SprTrueAdd	equ	11
SprEndAdd	equ	12
SprBlack	equ	13
StrucSize	equ	14


	org 	x:$0
Sprites	ds	StrucSize
XposA	ds	1
YposA	ds	1
XposO	ds	1
YposO	ds	1
TCosA	ds	1
TSinA	ds	1
TCosO	ds	1
TSinO	ds	1

	org	x:$200
AxeX	ds	320
AxeY	ds	320

	org	y:XposA
	ds	1
	ds	1
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
	movep	x:HRX,x:(r0)+	; Partie entiere (inc Y)
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
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Adresse du sprite (sauvegarde)
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Adresse de fin du sprite
	jclr	#0,X:HSR,*
	movep	x:HRX,x:(r0)+	; Adresse d'un pixel noir
	jmp	Command


DrawSprite
	; Ici on calcule les axes du nouveau repere
	; -----------------------------------------
	jsr	CalcAxes
		
	move	#AxeY,r1			;Table des offset pour chaque ligne
	do	x:Sprites+SprH,NextLine		;Pour chaque ligne

	; C'est ici qu'on envoie les donnees au DSP
	; Et qu'a lieu le calcule de la rotation
	; Je crois que ca va etre difficile d'aller
	; plus vite!
	
	move	x:Sprites+SprAdd,a		;Adresse du sprite modifiee
	move	x:Sprites+SprTrueAdd,y0		;Adresse reelle
	move	x:Sprites+SprEndAdd,x1		;Adresse de fin
	move	x:Sprites+SprBlack,y1		;Adresse du pixel noir
	move	x:(r1)+,x0			;Offset de la ligne
	add	x0,a	#AxeX,r2		;plus adresse du sprite
	tfr	a,b
	do	x:Sprites+SprW,NextPixel	

		tfr	b,a	x:(r2)+,x0
		add	x0,a			; plus offset de la colone
		cmp	y0,a			; Si on sort
		tlt	y1,a			; pixel noir
		cmp	x1,a			; idem
		tgt	y1,a			; idem
		jclr	#1,X:HSR,*
		movep	a,x:HTX			; et on envoie	
NextPixel
	nop
NextLine
	jmp	Command


	; Ca c'est la routine la plus compliqu‚e.
	; C'est ici que sont calcul‚s les axes du
	; Nouveau repere (rotate et zoome).
	;
	; En changant la fonction calculee par cette
	; routine, vous pourrez faire toutes les deformations
	; dont vous revez (essayez de faire un spirale).
	; Allez on y va:

CalcAxes
	; Calcul des vecteurs directeurs
	; Direction et longueur sur chaque axes pour chaque vecteur
	move			x:Sprites+SprCosinus,x0
	move			x:Sprites+SprXinc,y0
	mpy	x0,y0,a		#>(1.0/65536.0),y1
	move			a,x0
	mpy	x0,y1,a		x:Sprites+SprSinus,x0
	mpy	x0,y0,a		a,l:TCosA
	move			a,x0
	mpy	x0,y1,a		x:Sprites+SprCosinus,x0
	move			x:Sprites+SprYinc,y0
	mpy	x0,y0,a		a,l:TSinA
	move			a,x0
	mpy	x0,y1,a		x:Sprites+SprSinus,x0
	mpy	x0,y0,a		a,l:TCosO
	move			a,x0
	mpy	x0,y1,a		#AxeX,r0
	move			a,l:TSinO
	move			#AxeY,r1

	
	; Prise en compte du point de rotation
	; Entraine un recalcul de l'adresse

	move			x:Sprites+SprYctr,y0
	move			x:Sprites+SprLTrue,x1
	mpy	y0,x1,b		x:Sprites+SprXctr,a
	move	b0,b	
	addl	b,a		x:Sprites+SprAdd,b
	add	a,b
	move			b,x:Sprites+SprAdd
	
	
	; Calcul de la position de d‚part
	; En principe, il faudrait multiplier
	; YposO,XposO,YposA et XposA par
	; L'incrementation en X et Y
	; de maniere a ce que point de rotation
	; reste toujours au meme endroit a l'ecran independemment
	; du taux de zoom.
	; le probleme c'est qu'ici il faudrait
	; faire une multiplication sur 48*48 bits, alors
	; on s'en passe pour cette fois ci!
	 
	move			x:Sprites+SprSinus,x0
	move			x:Sprites+SprYctr,y0
	mpy	-x0,y0,a	x:Sprites+SprCosinus,x0
	move	a,l:YposO	
	mpy	-x0,y0,a	x:Sprites+SprXctr,y0
	move	a,l:XposO
	mpy	-x0,y0,a	x:Sprites+SprSinus,x0
	move	a,l:XposA
	mpy	-x0,y0,a
	move	a,l:YposA
	
	
	; Calcul des axes
	; Mise "bout a bout" des vecteur directeur
	
	move	x:Sprites+SprLTrue,x1
	do	#320,loop0
	move			x:YposA,x0
	mpy	x0,x1,a		x:XposA,b
	move	a0,a
	addr	b,a
	lsl	a		x:XposO,x0
	move	a,x:(r0)+
	mpy	x0,x1,a		x:YposO,b
	move	a0,a
	subr	b,a
	lsl	a		l:TCosA,b
	move	a,x:(r1)+
	move			l:XposA,a
	add	b,a		l:TSinA,b
	move			a,l:XposA	
	move			l:YposA,a
	add	b,a		l:TCosO,b
	move			a,l:YposA
	move			l:XposO,a
	add	b,a		l:TSinO,b
	move			a,l:XposO	
	move			l:YposO,a
	add	b,a	
	move			a,l:YposO
loop0	rts	
