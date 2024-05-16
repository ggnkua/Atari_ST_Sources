PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb

	org	p:$0
	jmp	load

	org	P:$40
load
	move	#$ffff,m0
	move	#$ffff,m1
	move	#$ffff,m2
	move	#$ffff,m3
	move	#$ffff,m4
	move	#$ffff,m5
	move	#$ffff,m6
	move	#$ffff,m7
	move	#$2,n0
	move	#13,n5
	jsr	calcul_tab
	jsr	load_palette
	jsr	clear_ecran
	move	#$3ff,r0
	move	#$12d45f,y0
	move	y0,y:(r0)
start	
	move	#0,a
	movep	#1,X:PBC		
	jclr	#0,x:HSR,start
	move	x:HTX,a1

	move	#0,b
	cmp	a,b
	jeq	calcul_flammes
	
	move	a1,r7
	move	#192,n7
start123
	movep	#1,X:PBC		
	jclr	#0,x:HSR,start123
	move	x:HTX,x0
	
	move	#$180,a0
	move	a0,y1
	move	#0,a
	do	#8,calcul_flammes
	move	r7,r6
	do	x0,calcul_flammes0
wait23
	movep	#1,X:PBC		
	jclr	#0,x:HSR,wait23
	move	x:HTX,b0
	cmp	a,b
	jne	joker	
	move	y1,p:(r6)
joker
	move	p:(r6)+,y0
calcul_flammes0
	move	p:(r7)+n7,x1
calcul_flammes
	move	#$2,n4
	move	#$500,r6	;r6	pointe sur l ecran + 1 ligne
	move	#$501,r7	;r7 	pointe sur l ecran + 1 pixel
	move	#$200,r0
	move	#$300,r1
	move	#$400,r2
	move	r1,r3
	jsr	charge_a_ligne
	move	r2,r3
	jsr	charge_a_ligne

	do	#120,fin_loop

	move	r0,r3
	move	r1,r0
	move	r2,r1
	move	r3,r2
 	jsr	charge_a_ligne
	move	r0,r3
	move	r1,r4
	move	r2,r5
	jsr	creer_ligne
fin_loop	
	jsr	rempli_aleat
	jsr	send_data

	jmp	start

charge_a_ligne:
;--------------
	do	#194,fin_charge
	move	p:(r6)+,x1
	move	x1,y:(r3)+
fin_charge
	move	r6,a1
	move	#0,a2
	move	n0,x1
	sub	x1,a
	move	a1,r6	
	rts

creer_ligne:
;-----------
	move	r6,n2
	move	#$3600,r6
	move	r6,y0
	move	y:(r3)+,a0
	move	y:(r5)+,a0	
	move	#0,a
	move	#0,b
	move	y:(r4+n4),b1
	move	y:(r4)+,a1
	add	b,a	y:(r3)+,b1
	add	b,a	y:(r5)+,b1
	add	b,a	y:(r4+n4),b1
	move	a1,n6

	do	#191,label2
	add	b,a	x:(r6)+n6,x0	y:(r3)+,y1	
	move	x0,p:(r7)+
	add	y1,a	y:(r5)+,b	y0,r6
	add	b,a	y:(r4+n4),b1
	move	a1,n6
	move	y:(r4)+,a1
label2
	move	x:(r6+n6),x0
	move	x0,p:(r7)+
	move	n2,r6
	rts

calcul_tab
	move	#$3600,r7
	move	#1,b1
	move	b1,x1
	move	#0,b
	do	#512*4,fin_calcul
	move	b,a

;	bchg	#2,a1
	lsr	a
	lsr	a	
	jeq	zero	
	sub	x1,a	
	jeq	zero	
	sub	x1,a	
zero	
	move	a1,x:(r7)+
	add	x1,b
fin_calcul
	rts


load_palette:
;------------
	move	#0,r7
	do	#512,load_pal1
load_pal2
	movep	#1,X:PBC		
	jclr	#0,x:HSR,load_pal2
	move	x:HTX,a0
	move	a0,y:(r7)+
load_pal1
	rts


clear_ecran:
;-----------
	move	#$500,r6
	move	#0,x0
	do	#2880,fin_clr
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
	move	x0,p:(r6)+
fin_clr
	rts

rempli_aleat:
;------------
	move	#$5f00,r6

	move	#$3f,b1		; f
	move	#$80,b0		;$45
	move	b0,y1
	move	b1,y0

	do	#384,fin_rempli
	jsr	nb_aleat
	and	y0,a
	add	y1,a
	move	a1,p:(r6)+
fin_rempli		

	move	#$3f,b1		; f
	move	#$85,b0		;$45
	move	b0,y1
	move	b1,y0


	do	#192,fin_rempli1
	jsr	nb_aleat
	and	y0,a
	add	y1,a
	move	a1,p:(r6)+
fin_rempli1		

	move	#$1f,b1		; f
	move	b1,y0

	move	#0,b
	move	n5,b1	
	jsr	nb_aleat
	and	y0,a
	add	b,a
	move	#$1ff,b1
	move	b1,y0
		

	move	#192,b1
	
	do	a1,fin_pti_carre_blanc
	move	#$5f00,r6
	jsr	nb_aleat
	and	y0,a
	cmp	a,b
	jlt	clip

	move	r6,y1
	add	y1,a
	move	a1,r6	
	nop
	move	y0,p:(r6)+
	move	y0,p:(r6)+
	move	y0,p:(r6)+
	move	b1,y1
	add	y1,a
	move	a1,r6	
	nop
	move	y0,p:(r6)+
	move	y0,p:(r6)+
	move	y0,p:(r6)+
	add	y1,a
	move	a1,r6	
	nop
	move	y0,p:(r6)+
	move	y0,p:(r6)+
	move	y0,p:(r6)+
clip
	nop
fin_pti_carre_blanc
	rts

nb_aleat:
;--------
	move	#13017,r2
	move	#$3ff,r0
	move	#$4b17f3,x0
	move	y:(r0),x1
	mpy	x0,x1,a
	asr	a
	move	r2,x0
	add	x,a

	move	a1,y:(r0)

	move	a0,a1
	move	#0,a0
	move	#0,a2
	rts
	
send_data:
;---------
	move	#$500,r6
	move	#$0,r3
	move	#23040,x0
	do	x0,fin_send
	move	p:(r6)+,n3
wait_send	
	jclr	#1,X:HSR,wait_send
	move	y:(r3+n3),x1
	move	x1,X:HTX
fin_send
	rts