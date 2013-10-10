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
		jsr	load
		move	a1,n3	
		jsr	load
		move	a1,n2	

		move	#$1000,r7
		move	#0,r0
		move	#1,r3
		move	#6,r1
		move	#9,r2
		move	#12,r4
		move	#3,r5
		move	#-2,n5
		move	#2,n4
;		move	#192,n3
;		move	#120,n4

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

		move	#$300,r4
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
		move	b1,y:(r4+n4)
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
		move	n2,y1
		add	y1,b	
		move	b1,y:(r4)+
		move	y:(r4)+,x1
fin_calcul
		jsr	plans_secants
		jsr	produit_vectoriel
		move	x:(r5),x1
		jsr	xmit
		move	#$300,r6
		do	x1,fin_transmet
		move	y:(r6)+,x1
		jsr	xmit
		move	y:(r6)+,x1
		jsr	xmit
		move	y:(r6)+,x1
fin_transmet
		move	#20,r0
		nop
		move	x:(r0)+,x1
		jsr	xmit
		do	x1,fin_transmet1
		move	x:(r0)+,x1
		jsr	xmit
fin_transmet1
		move	#40,r0
		nop
		move	x:(r0)+,x1
		do	x1,trans_off
		move	x:(r0)+,x1
		jsr	xmit
		do	x1,trans_off2		
		move	x:(r0)+,x1
		jsr	xmit
trans_off2
		nop
trans_off
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
	move	#0,b
	jsr	load		; recois le nb d 'objets
	move	a1,x:(r0)+
	move	#0,a
	jsr	load
	move	a1,x:(r0)+	; recois le nb de plans secants
	cmp	a,b
	jeq	no_plans

	do	a1,no_plans	
	jsr	load		; recois le no d'objet 1
	move	a1,x:(r0)+
	jsr	load
	move	a1,x:(r0)+	; recois le no d'objet 2
	jsr	load
	move	a1,x:(r0)+	; recois les 3 offsets pour les faces
	jsr	load
	move	a1,x:(r0)+
	jsr	load
	move	a1,x:(r0)+

no_plans
	jsr	load		;   <---------+
	do	a1,waiting	;             |
	jsr	load		; recois le nb de valeurs pour les
	move	a1,x:(r0)+	; produits vectoriels
waiting
	rts	


	rts

load	movep	#1,X:PBC	
	jclr	#0,x:HSR,load
	move	x:HTX,a1
	rts

xmit	jclr	#1,X:HSR,xmit
	move	x1,X:HTX
	rts



plans_secants
	move	r6,r7
	clr 	a	#0,r0
	move	x:(r6)+,x1
	do	x1,fin_clr
	move	a1,x:(r0)+
fin_clr	
	move	x:(r6)+,x1
	cmp	x1,a
	jeq	un_seul_objet	
	do	x1,fin_calcul_plans
	move	x:(r6)+,r0
	move	x:(r6)+,r1
	move	x:(r6)+,r2
	move	x:(r6)+,r3
	move	x:(r6)+,r4

	move	y:(r2)+,a
	move	y:(r3)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r3),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	tmi	x1,a	r0,r1
	nop
	move	x:(r1),a
	move	#1,r0
	move	r0,x1
	add	x1,a
	move	a1,x:(r1)
fin_calcul_plans
	move	#$ffffff,y1
	move	#20,r3
	move	x:(r7),b
	move	b1,x:(r3)+
	sub	x1,b	b1,x0
	move	b1,y0
	do	x0,fin_tri1
	move	#0,r1
	move	#0,r2
	move	x:(r1)+,a
	do	y0,fin_tri
	move	x:(r1),b
	cmp	a,b
	tgt	b,a  r1,r2
	move	x:(r1)+,b
fin_tri
	move	r2,x:(r3)+	
	move	y1,x:(r2)
fin_tri1			
	rts							


un_seul_objet
	move	#20,r3
	move	#$1,r1
	move	#$0,r0
	move	r1,x:(r3)+
	move	r0,x:(r3)+
	rts


produit_vectoriel
	move	#2,n2
	move	#2,n3
	move	#2,n4
	move	#3,n6
	move	#40,r0
	move	x:(r7),x0
	move	x0,x:(r0)+
	do	x0,nb_objet

	move	x:(r6)+,x1
	move	x1,x:(r0)+
	do	x1,nb_face
	move	#0,r1

	move	x:(r6)+,n0
	move	r6,n1
	
	move	x:(r6)+,r2
	move	x:(r6)+,r3
	move	x:(r6)+,r4

	move	y:(r2)+,a
	move	y:(r3)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r3),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	move	#0,b
	move	#12,b0
	sub	b,a
	jmi	invisible
	add	b,a
	asr	a
	move	a0,y:(r1)+

	move	y:(r2)+,a
	move	y:(r3)+,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r3),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	asr	a	(r6)-n6
	move	a0,y:(r1)+

	move	x:(r6)+,r2
	move	x:(r6)+,r3
	move	x:(r6)+,r4

	move	y:(r2)+n2,a
	move	y:(r3)+n3,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+n4,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	y:(r3),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	asr	a
	move	a0,y:(r1)+
	move	#0,r1
	nop
	move	y:(r1)+,x0
	mpy	x0,x0,a		y:(r1)+,x0
	mac	x0,x0,a		y:(r1)+,x0
	mac	x0,x0,a
	move	#0,r1

	move	#0,x0
	bset	#19,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next19	
	bclr	#19,x0
next19
	bset	#18,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next18	
	bclr	#18,x0
next18
	bset	#17,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next17	
	bclr	#17,x0
next17
	bset	#16,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next16	
	bclr	#16,x0
next16
	bset	#15,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next15	
	bclr	#15,x0
next15
	bset	#14,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next14	
	bclr	#14,x0
next14
	bset	#13,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next13	
	bclr	#13,x0
next13
	bset	#12,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next12	
	bclr	#12,x0
next12
	bset	#11,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next11	
	bclr	#11,x0
next11
	bset	#10,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next10	
	bclr	#10,x0
next10
	bset	#9,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next9	
	bclr	#9,x0
next9
	bset	#8,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next8	
	bclr	#8,x0
next8
	bset	#7,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next7	
	bclr	#7,x0
next7
	bset	#6,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next6	
	bclr	#6,x0
next6
	bset	#5,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next5	
	bclr	#5,x0
next5
	bset	#4,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next4	
	bclr	#4,x0
next4
	bset	#3,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next3
	bclr	#3,x0
next3
	bset	#2,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next2
	bclr	#2,x0
next2
	bset	#1,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next1
	bclr	#1,x0
next1
	bset	#0,x0
	mpy	x0,x0,b
	cmp	a,b
	jle	next0	
	bclr	#0,x0
next0
	move	#0,b
	move	y:(r1),b1
	and	#$fe,ccr
	rep	#24
	div	x0,b
	move	#0,a
	move	b0,a0
	rep	#9
	asl	a	
	jmp	visible
invisible
	move	#$ffffff,a1
visible
	move	a1,x:(r0)+
	move	#0,a
	move	n1,a1
	move	n0,x1
	add	x1,a
	move	a1,r6
	nop
nb_face
	nop
nb_objet
	rts