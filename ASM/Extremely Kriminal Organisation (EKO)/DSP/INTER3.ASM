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
		jeq	calcul		

		move	#2,b1
		cmp	a,b
		jeq	charge_objet

		move	#1,b1
		cmp	a,b
		jeq	charge	

		move	#3,b1
		cmp	a,b
		jeq	mega_rout

		move	#4,b1
		cmp	a,b
		jeq	send_coor0

		move	#5,b1
		cmp	a,b
		jeq	send_coor1

		move	#6,b1
		cmp	a,b
		jeq	send_objet

		jmp	re_init
mega_rout
		move	#0,a
		move	#$e00,r0
		move	#$e02,r1
		move	a1,y:(r0)+
		move	r1,y:(r0)
		move	#$1d00,r0
		jsr	load
		move	a1,x:(r0)+
		do	a1,fin_liste
		jsr	load
		move	a1,x:(r0)+
		jsr	load
		move	a1,x:(r0)+
fin_liste		
		move	#$1d00,r3
		nop
		move	x:(r3)+,a1
		do	a1,fin_lance
		move	x:(r3)+,r0
		move	x:(r3)+,r1
		move	r3,n7
		jsr	creer_poly
		move	n7,r3
		nop
fin_lance
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
;		move	#15,r0
;		do	#2,fin_receive_coef
;		jsr	load
;		move	a1,x:(r0)+
;fin_receive_coef
		jsr	load
		move	a1,r6	
		jsr	load
		move	a1,r7	
		jsr	load
		move	a1,n3
		jsr	load
		move	a1,n4

		move	#0,r0
		move	#1,r3
		move	#6,r1
		move	#9,r2
		move	#12,r4
		move	#3,r5
		move	#-2,n5

;*		move	#192,n3
;*		move	#120,n4

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

		move	x:(r6)+,x0
		move	x0,y:(r7)+
		do	x0,fin_calcul
		move	#6,r1
		move	x:(r6)+,x1
		move	x:(r6)+,y1
		move	x:(r6)+,y0
		move	x:(r1)+,x0
		mpy	x0,x1,a		x:(r1)+,x0
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0	
		mpy	x0,x1,a		x:(r1)+,x0	a,y:(r7)
		mac	x0,y1,a		x:(r1)+,x0
		macr	x0,y0,a		x:(r1)+,x0
		mpy	-x0,x1,b	x:(r1)+,x0	
		mac	x0,y1,b		x:(r1)+,x0	y:(r7),y1	; y1= x tourne
		macr	x0,y0,b		a1,x1				; x1= y tourne
								
		move	n3,a
		add	y1,a		b,x0		
		move	n4,b
		add	x1,b	a1,y:(r7)+
		move	b1,y:(r7)+	
		move	x0,y:(r7)+	
			
fin_calcul
		jmp	re_init

send_coor0
		move	#$1000,r1
		move	#192,r2
		move	#120,r3		
		jsr	load
		move	a1,r0
		jsr	load
		move	a1,x0
		jsr	load
		move	a1,y0
		move	y:(r0)+,x1
		jsr	xmit
		jmp	send_coor2

send_coor1
		move	#$1000,r1
		move	#192,r2
		move	#120,r3		
		jsr	load
		move	a1,r0
		jsr	load
		move	a1,x0
		jsr	load
		move	a1,y0
		move	y:(r0)+,x1
		jsr	xmit
		move	y:(r0)+,y1
		jmp	send_coor2


send_coor2
		move	x1,a
		tst	a
		jeq	fin_send
		do	x1,fin_send
		move	y:(r0)+,x1
		move	y:(r0)+,y1
		move	y:(r0)+,a
		sub	y0,a
		neg	a
		mpy	x1,x0,a		a1,n1			
		mpy	y1,x0,b		
		move	y:(r1+n1),x1		
		move	a0,y1
		move	r2,a
		macr	x1,y1,a		b0,y1
		move	r3,b
		macr	x1,y1,b		
		move	a1,x1
		jsr	xmit
		move	b1,x1
		jsr	xmit
		move	n1,x1
		jsr	xmit
fin_send
		jmp	re_init


send_objet
		jsr	load
		move	a1,r0
		nop
		move	x:(r0)+,x1
		jsr	xmit

		do	x1,fin_send_o0	
		move	x:(r0)+,x1
		jsr	xmit

		do	x1,fin_send_o1
		move	x:(r0)+,x1
		jsr	xmit
fin_send_o1
		move	x:(r0)+,x1
		jsr	xmit
fin_send_o0
		jmp	re_init

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
	jmp	re_init

charge_objet
	jsr	load
	move	a1,x0
	jsr	load
	move	a1,r0
	nop
	move	x0,x:(r0)+
	
	do	x0,fin_charge0	
	jsr	load
	move	a1,x:(r0)+
	do	a1,fin_charge1
	jsr	load
	move	a1,x:(r0)+
fin_charge1
	jsr	load
	move	a1,x:(r0)+
fin_charge0
	jmp	re_init

;********************************

calcul_inter
	move	#0,r6
	move	#15,r7	
	move	#2,n6
	move	#0,a
	move	#0,b
	do	#3,bcl1
	move	x:(r6)+,a	; calcul de x1-x2 y1-y2 z1-z2
	move	x:(r6+n6),b
	sub	b,a	
	move	a1,x:(r7)+
bcl1
	move	#6,r6
	nop

	move	x:(r6)+,a
	move	a1,x0
	move	x:(r6+n6),b
	sub	b,a
	move	a1,x:(r7)+	; calcul	x3-x4 sauve x3 dans x0

	move	x:(r6)+,a
	move	a1,x1
	move	x:(r6+n6),b
	sub	b,a
	move	a1,x:(r7)+

	move	x:(r6)+,a
	move	x:(r6+n6),b
	move	a1,y1
	sub	b,a
	move	a1,x:(r7)+

	move	#12,r6
	move	x0,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r7)+	

	move	x1,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r7)+	

	move	y1,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r7)+	

	move	#3,r6
	do	#3,bcl2
	move	x:(r6)+,a
	move	x:(r6+n6),b
	sub	b,a	
	move	a1,x:(r7)+
bcl2

	move	#15+2,r6
	move	#4,n6
	nop
	move	x:(r6)+,x0	; x0=c
	move	x:(r6)+n6,x1	; x1=d
	move	x:(r6),y0	; y0=g
	mpy	x0,x1,a
	asr	a
	move	a0,y1
	mpy	y1,y0,a
	asr	a		; dans a0=cdg

	move	#15+4,r6
	move	#2,n6
	nop
	move	x:(r6)+n6,x1	; x1=f
	move	x:(r6),y0	; y0=e
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-cfe
	add	b,a

	move	#15,r6
	move	#8,n6
	nop
	move	x:(r6)+n6,x0	; x0=a
	move	x:(r6),y0	; y0=i
	mpy	x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=afi
	add	b,a
	
	move	#15+1,r6
	move	#2,n6
	nop
	move	x:(r6)+n6,x1	; x1=b
	move	x:(r6),x0	; x0=d
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-bdi
	add	b,a

	move	#15+5,r6
	nop
	move	x:(r6)+,x0	; x0=h
	move	x:(r6),y0	; y0=e
	mpy	x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=bhe
	add	b,a

	move	#15,r6
	move	#7,n6
	nop
	move	x:(r6)+n6,x1	; x1=a
	move	x:(r6),y0	; y0=g
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-hag
	add	b,a		; dans	a  -bdi-hag+bhe+dgc+fai-cfe
	jeq	pas_d_inter
	move	a1,x:(r7)+
	move	a0,x:(r7)+

	move	#15+9,r6	; y0=g et x0=h
	nop
	move	x:(r6)+,x1	; x1=c1
	mpy	x0,x1,a
	asr	a
	move	a0,y1
	mpy	y1,y0,a
	asr	a		; dans a0=hgc1

	move	#15+4,r6
	move	#4,n6
	nop
	move	x:(r6)+n6,x0	; x0=f
	move	x:(r6),y0	; y0=i
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-fic1
	add	b,a

	move	#15+6,r6
	move	#5,n6
	nop
	move	x:(r6)+n6,x1	; x1=e
	move	x:(r6),y0	; y0=c3
	mpy	x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=fec3
	add	b,a
	
	move	#15+3,r6
	move	#4,n6
	nop
	move	x:(r6)+n6,x1	; x1=d
	move	x:(r6),x0	; x0=g
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-dgc3
	add	b,a

	move	#15+8,r6
	move	#2,n6
	nop
	move	x:(r6)+n6,x0	; x0=i
	move	x:(r6),y0	; y0=c2
	mpy	x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=idc2
	add	b,a

	move	#15+5,r6
	nop
	move	x:(r6)+,x0	; x0=h
	move	x:(r6),x1	; x1=e
	mpy	-x0,x1,b
	asr	b
	move	b0,y1
	mpy	y1,y0,b
	asr	b		; dans  b0=-hec2
	add	b,a		; dans	a  dic2+hgc1-hec2-dgc3-fic1+fec3

	tst	a		; ptet
	jeq	pas_d_inter
		
	move	#15+12,r6
	move	#0,b
	move	x:(r6)+,b
	move	x:(r6)+,b0
	tst	b
	jmi	negat1
	tst	a
	jmi	pas_d_inter		
	jmp	ivision
negat1
	neg	b
	tst	a
	jpl	pas_d_inter	
	neg	a
ivision	
	cmp	a,b
	jlt	pas_d_inter			
;	asr	a
;	asr	a
;	asr	a
;	asr	a
;	asr	b
;	asr	b
;	asr	b
;	asr	b

	move	b0,x0
	move	#0,b
	move	a0,b1
	and	#$fe,ccr
	rep	#24
	div	x0,b
	move	b0,x0
	move	#15,r7
	move	#3,r6
	move	x:(r7)+,x1
	mpyr	x0,x1,a		x:(r6)+,x1
	add	x1,a		x:(r7)+,x1
	mpyr	x0,x1,b		x:(r6)+,x1
	add	x1,b		x:(r7)+,x1
	move	a1,y1	
	mpyr	x0,x1,a		x:(r6)+,x1
	add	x1,a		b1,y0		
	move	#0,b		
; y1=x y0=y a1=z
	rts
pas_d_inter
	move	#$ffffff,b
	rts
;************************************************
creer_poly
	; dans r0 l adresse du poly source
	; dans r1 l adresse du poly destination
	; dans r5 l adresse d un buffer vide en x pour y foutre les nouvo pts
	move	r1,r5
	move	#2,n5
	move	#$1f0,r6
	move	#3,n6
	move	x:(r5)+n5,x0
	move	#3,n5
	move	#2,n2
	move	#2,n3
	move	#2,n4

	move	x:(r5)+,r2
	move	x:(r5)+,r3
	move	x:(r5)+,r4

	move	y:(r2)+,a
	move	a1,x:(r6+n6)
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
	asr	a
	move	a0,x:(r6)+

	move	y:(r2)+,a
	move	a1,x:(r6+n6)
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
	asr	a	(r5)-n5
	move	a0,x:(r6)+

	move	x:(r5)+,r2
	move	x:(r5)+,r3
	move	x:(r5)+,r4

	move	y:(r2)+n2,a
	move	y:(r3)+n3,b
	sub	b,a	
	move	a1,x0
	move	y:(r4)+n4,a
	sub	b,a	
	move	a1,x1	

	move	y:(r2),a
	move	a1,x:(r6+n6)
	move	y:(r3),b
	sub	b,a
	move	a1,y0
	move	y:(r4),a
	sub	b,a	
	move	a1,y1	
	mpy	x0,y1,a
	mac	-x1,y0,a
	asr	a
	move	a0,x:(r6)+

	move	r0,r5	
	move	#2,n5
	move	#$1f3,r6
	move	x:(r5)+n5,x0

	move	x:(r5)+,r4
	move	x:(r6)+,a
	move	y:(r4)+,b
	sub	a,b	x:(r6)+,a
	move	b1,x0
	move	y:(r4)+,b
	sub	a,b	x:(r6)+,a
	move	b1,x1
	move	y:(r4)+,b
	sub	a,b	
	move	#$1f0,r6
	move	b1,y0
	move	x:(r6)+,y1
	mpy	y0,y1,a	x:(r6)+,y1
	mac	x0,y1,a	x:(r6)+,y1
	mac	-x1,y1,a
	move	a1,x:(r6)+	



	move	#$0,r3
	move	y:$e01,r5
	move	r3,y:(r3)+	
	move	#2,n1
	move	x:(r1)+,x0
	move	x:(r1)+,x0
	move	r0,n3

	move	x:(r0)+,x0
	do	x0,fin_creer_poly									
	move	r0,n0
	move	x:(r0)+,x0
	move	#$180,r2
	do	x0,fin_creer_poly1

	move	x:(r0)+,r4
	nop
	move	y:(r4)+,x0	
	move	x0,x:$0
	move	y:(r4)+,x0	
	move	x0,x:$1
	move	y:(r4)+,x0	
	move	x0,x:$2

	move	x:(r0),r4
	nop
	move	y:(r4)+,x0	
	move	x0,x:$3
	move	y:(r4)+,x0	
	move	x0,x:$4
	move	y:(r4)+,x0	
	move	x0,x:$5

	move	x:(r1)+,r4
	nop
	move	y:(r4)+,x0	
	move	x0,x:$6
	move	y:(r4)+,x0	
	move	x0,x:$7
	move	y:(r4)+,x0	
	move	x0,x:$8

	move	x:(r1)+,r4
	nop
	move	y:(r4)+,x0	
	move	x0,x:$9
	move	y:(r4)+,x0	
	move	x0,x:$a	
	move	y:(r4)+,x0	
	move	x0,x:$b

	move	x:(r1)-n1,r4
	nop
	move	y:(r4)+,x0	
	move	x0,x:$c
	move	y:(r4)+,x0	
	move	x0,x:$d
	move	y:(r4)+,x0	
	move	x0,x:$e
	jsr	calcul_inter
	tst	b
	jmi	negatof
	move	r5,y:(r2)+

	move	#$e00,r4
	move	y1,y:(r5)+
	move	y0,y:(r5)+
	move	a1,y:(r5)+
	
	move	y:(r4),a
	move	#0,b
	move	#1,b1
	add	b,a
	move	a1,y:(r4)

	jmp	positof
negatof
	move	b1,y:(r2)+	
positof
	nop
fin_creer_poly1
	move	#$1f3,r6
	move	#0,b	
	move	x:(r6)+,a
	tst	a
	jmi	et_pourri

	move	b1,y:(r3)+
	move	r3,n2
	move	n0,r4	
	move	#$180,r2
	move	x:(r4)+,x0
	do	x0,fin_range_poly

	move	x:(r4)+,x0
	move	x:(r4),x1
	move	y:(r2)+,a
	tst	a
	jmi	negataf
	tst	b
	jmi	remonte1	
	move	#-1,b
	move	x0,y:(r3)+
	move	a1,y:(r3)+
	jmp	ziguoi	
remonte1	
	move	a1,y:(r3)+
	move	#0,b
	jmp	ziguoi	

negataf						
	tst	b
	jmi	ziguoi
	move	x0,y:(r3)+
ziguoi
	nop
fin_range_poly
	tst	b	
	jmi	first_prb

	move	n2,a
	move	r3,b
	move	n2,r4
	sub	a,b
	move	y:(r4),a1
	move	b1,y:-(r4)
	move	a1,y:(r3)+
	move	#0,a
	move	#1,a1
	move	y:$0,b
	add	a,b
	move	b,y:$0
	jmp	deux_poly

et_pourri
	move	#0,a
	move	a0,y:(r3)+
	move	r3,n2
	move	#0,b	
	move	n0,r4	
	move	#$180,r2
	move	x:(r4)+,x0
	do	x0,fin_range_poly7

	move	x:(r4)+,x0
	move	x:(r4),x1
	move	y:(r2)+,a
	tst	a
	jmi	negataf7
	tst	b
	jmi	remonte17	
	move	#-1,b
	move	a1,y:(r3)+
	jmp	ziguoi7	
remonte17	
	move	x0,y:(r3)+
	move	a1,y:(r3)+
	move	#0,b
	jmp	ziguoi7	

negataf7						
	tst	b
	jpl	ziguoi7
	move	x0,y:(r3)+
ziguoi7
	nop
fin_range_poly7
	tst	b	
	jmi	first_prb


	move	n2,a
	move	r3,b
	sub	a,b
	jeq	first_prb	;_un_seul_poly
	move	n2,r4
	nop
	move	y:(r4),a1
	move	b1,y:-(r4)
	move	a1,y:(r3)+
	move	#0,a
	move	#1,a1
	move	y:$0,b
	add	a,b
	move	b,y:$0
	jmp	deux_poly
un_seul_poly
	move	b1,y:-(r3)
	jmp	deux_poly

first_prb
	move	n0,r4	
	move	n2,r3
	move	x:(r4)+,x0
	move	x0,y:-(r3)
	move	y:(r3)+,x0
	do	x0,fin_first
	move	x:(r4)+,x0
	move	x0,y:(r3)+
fin_first
	move	n0,r4	
	move	#0,a
	move	#1,a1
	move	y:$0,b
	add	a,b	(r4)+
	move	b,y:$0
	move	x:(r4)+,x0
	move	x0,y:(r3)+
	
deux_poly
	nop
fin_creer_poly
	move	#0,r1
	move	n3,r0
	move	y:(r1)+,x0
	move	x0,x:(r0)+	
	do	x0,fin_recopie0	
	move	y:(r1)+,x0
	move	x0,x:(r0)+	
	do	x0,fin_recopie1
	move	y:(r1)+,x0
	move	x0,x:(r0)+	
fin_recopie1
	move	y:(r1)+,x0
	move	x0,x:(r0)+	
fin_recopie0


	move	r5,y:$e01
	rts
	
load	movep	#1,X:PBC	
	jclr	#0,x:HSR,load
	move	x:HTX,a1
	rts

xmit	jclr	#1,X:HSR,xmit
	move	x1,X:HTX
	rts