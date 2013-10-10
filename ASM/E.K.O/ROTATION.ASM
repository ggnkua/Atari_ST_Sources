PBC		equ	$ffe0
HSR		equ	$ffe9
HTX		equ	$ffeb

		org	p:$0
		jmp	debut

		org	p:$40
debut
		move	#-1,m0
		move	#-1,m1
		move	#-1,m2
		move	#-1,m3
		move	#-1,m4
		move	#-1,m5
		move	#-1,m6
		move	#-1,m7
		move	#$1000,r0
		do	#4000,re_init
		jsr	load
		move	a1,y:(r0)+
re_init
		move	#0,a
		move	#0,b

wait		movep	#1,X:PBC	
		jclr	#0,x:HSR,wait
		move	x:HTX,a1
		move	#0,b1
		cmp	a,b
		jseq	calcul		
		move	#1,b1
		cmp	a,b
		jseq	charge	
		jmp	re_init

; calcul attend les valeurs de cos B sin B
; cos C sin C cos A sin A
; puis l increment du Z pour la projection
; puis le coef multiplicateur tjs pour la projection
; enfin l adresse des points a tourner !

calcul
		move	#0,r0
		do	#6,fin_receive_cosinus		
		jsr	load
		move	a1,x:(r0)+
fin_receive_cosinus
		move	#15,r0
		do	#2,fin_receive_coef
		jsr	load
		move	a1,x:(r0)+
fin_receive_coef
		jsr	load
		move	a1,r6	

		move	#$1000,r7
		move	#0,r0
		move	#1,r3
		move	#6,r1
		move	#9,r2
		move	#12,r4
		move	#3,r5
		move	#-2,n5
		move	#192,n3
		move	#120,n4

		move	x:(r0)+,x0	 		;cos b
		move	x:(r0)+,x1			;sin b
		move	x:(r0)+,y0			;cos c
		move	x:(r0)+,y1			;sin c
		mpy	x0,y0,a		x1,x:(r4)+	; stock C et calcul A
		mpy	x0,y1,a		a1,x:(r1)+	; stock A et calcul B
		mpy	y0,x1,a		a1,x:(r2)+	; stock B
		move	x:(r0)+,y0			;cos a
		move	x:(r0)+,x1			;sin a
		mpy	-y1,y0,b	a1,y1
		mac	y1,x1,b				
		mpy	x0,x1,b		b1,x:(r1)+	;stock D 
		mpy	x0,y0,b		b1,x:(r4)+	;stock F
		move	x:(r3)+,y1			; x0=cos c   y0=cos a   x1=sin a  y1=sin b		
		move	x:(r3)+,x0						
		mpy	x1,y1,a		b1,x:(r4)+	; stock I
		mpy	x0,y0,b		
		move	a1,x0		
		move	x:(r5),y1	; charge sin c
		mpy	x0,y1,a
		add	b,a		x:(r5+n5),x0	
		mpy	y1,x1,a		a1,x:(r2)+	; stock E
		move	b1,y1				;x0= sin b  y1=sin c x1=sin a  y0=cos a
		mac     y1,x0,a		x:(r5)-,y1	
		mpy	y1,x0,a		a1,x:(r1)+	; y1=sin c x1= sin a x0=sin b y0=cos a
		move	a1,y1
		mpy	y1,y0,a		x:(r5),y0
		mac	-y0,x1,a
		move	a1,x:(r2)

		move	#$200,r4
		move	r6,r5

		move	x:(r6)+,x0
		do	x0,fin_calcul
		move	#6,r1
		move	x:(r6)+,x1
		move	x:(r6)+,y1
		move	x:(r6)+,y0
		move	x:(r1)+,x0
		mpy	x0,x1,a		x:(r1)+,x0
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0	
		mpy	x0,x1,a		x:(r1)+,x0	a,y:(r4)
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0
		mpy	-x0,x1,b	x:(r1)+,x0	
		mac	x0,y1,b		x:(r1)+,x0	y:(r4),y1	; y1= x tourne
		macr	x0,y0,b		x:(r1)+,x1
		sub	x1,b		a1,x0				; x0= y tourne
		neg	b
		move	b1,n7
		move	x:(r1)+,y0					; y0= multiplicateur x/2				
		move	y:(r7+n7),x1					; x1= 1/(z+profondeur)		
		mpy	y1,y0,a
		mpy	x0,y0,b		a0,y1
		mpyr	y1,x1,a		b0,x0
		move	n3,y1
		add	y1,a	
		mpyr	x0,x1,b		a1,y:(r4)+
		move	n4,y1
		add	y1,b	
		move	b1,y:(r4)+		
fin_calcul
		move	x:(r5),x1
		jsr	xmit
		move	#$200,r5
		do	x1,fin_transmet
		move	y:(r5)+,x1
		jsr	xmit
		move	y:(r5)+,x1
		jsr	xmit
fin_transmet
		rts

; charge attend le nombre de points a charger
; l adresse du chargement puis les coordonnees

charge	movep	#1,X:PBC	
	jclr	#0,x:HSR,charge
	move	x:HTX,x0

wait_ad	movep	#1,X:PBC	
	jclr	#0,x:HSR,wait_ad
	move	x:HTX,r0
	nop
	move	x0,x:(r0)+
	
	do	x0,fin_charge	
	jsr	load
	move	a1,x:(r0)+
	jsr	load
	move	a1,x:(r0)+
	jsr	load
	move	a1,x:(r0)+
fin_charge
	rts

load	movep	#1,X:PBC	
	jclr	#0,x:HSR,load
	move	x:HTX,a1
	rts

xmit	jclr	#1,X:HSR,xmit
	move	x1,X:HTX
	rts