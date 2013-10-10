PBC		equ	$ffe0
HSR		equ	$ffe9
HTX		equ	$ffeb

	org	p:$0
	jmp	init

	org	p:$40
init
	jsr	receive_1surX		; recoit table de 1 sur x
	jsr	load			
	move	a1,x:$120		; recoit la taille de l'image
	jsr	receive_img		; recoit l'image pas tournee
	jsr	receive_palette	
	jsr	tab_line
main	
	move	#$100,r0
	do	#17,fin_rec_coor
	jsr	load
	move	a1,x:(r0)+
fin_rec_coor	

	move	#1,n0
	jsr	droite_ab
	jsr	droite_bc
	jsr	droite_cd
	jsr	droite_da
	move	#$200,r1
	move	#$10c,r7
	move	#$100,r0
	move	#$10d,r5
	move	#$102,r6
	jsr	calcul_col
	move	#$10d,r7
	move	#$102,r0
	move	#$10e,r5
	move	#$104,r6
	jsr	calcul_col
	move	#$10e,r7
	move	#$104,r0
	move	#$10f,r5
	move	#$106,r6
	jsr	calcul_col
	move	#$10f,r7
	move	#$106,r0
	move	#$110,r5
	move	#$108,r6
	jsr	calcul_col

	jsr	calcul_mapp
	jmp	main

calcul_mapp
	move	#$10a,r0		; adresse du point le plus o
	clr	a	#$300,b		; 0 ds a et $300 dans b
	move	x:(r0)+,x1		; charge le pt le plus bas
	add	x1,a	#2,n2		;
	add	x1,a	#$120,r5
	add	x1,a	
	add	b,a	#2,n1
	add	b,a	a1,r1
	move	a1,r2
	move	#$900,a
	add	x1,a	#$a00,b
	add	x1,b	a1,r4
	move	b1,r3
	move	x:(r0)+,x1	
	move	#$fe,r0
	move	#1,n0
	move	#$fc,r6
	move	#1,n6
	do	x1,calcul_line
	move	#$200,r7	
	clr	b	x:(r1)+,a
	move	x:(r2)+,x1
	jsr	send_x1
	sub	x1,a	#1,b1
	jsr	send
	tst	a
	jpl	no_bug
	move	x:(r2)+n2,a
	move	x:(r1)+n1,a
	jmp	fin_ligne_tourne
no_bug
	add	b,a
	move	a1,n7

	move	x:(r4)+,a
	move	x:(r3),x1
	sub	x1,a		
	move	x:(r7+n7),y0
	move	a1,x0
	mpy	y0,x0,a		x:(r3)+,b
	move	a,l:(r0)+
	move	b,l:(r0)-n0

	move	x:(r1)+,a
	move	x:(r1)+,b
	move	x:(r2)+,x1
	move	x:(r2)+,y1

	sub	x1,a	(r2)-n2
	sub	y1,b		a1,x0
	mpy	y0,x0,a		b1,x0
	mpy	y0,x0,b		a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0

	move	x:(r2)+,a
	move	x:(r2)+,b
	move	y,l:(r6+n6)	
	
	move	#$ffeb,r7
	
	do	n7,fin_ligne_tourne

	add	y,b	b1,r5
	add	x,a	a1,n5
	move	x:(r5),r5

	move	b,l:(r6)+
	move	y:(r5+n5),r5
	move	l:(r0)+,y
	move	l:(r0),b
	add	y,b	l:(r6)-n6,y	
	rnd	b	b,l:(r0)-n0
	move	b1,n5
	move	l:(r6),b	


	move	y:(r5+n5),r5
	jclr	#1,X:HSR,*
	move	r5,X:(r7)
	
fin_ligne_tourne
	nop
calcul_line
	rts	


droite_ab
	move	#$100,r0
	move	#$200,r1
	move	#$120,r2
	move	x:(r0)+,x1	; x1
	move	x:(r0)+,x0	; y1
	move	x:(r0)+,a	; x2
	move	x:(r0)+,b	; y2
	move	#$600,r3	; dans r3 buffer droit
	move	#$100,r0		
	sub	x1,a		; calcul delta x
	sub	x0,b		; calcul delta y
	jpl	positif1	; test signe du delta y
	move	#$300,r3	; on range dans le buffer gauche
	move	#$102,r0		
	neg	b	
	neg	a		

	tst	b	b1,n1
	jeq	fin_calcul_buff_dg9

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	-x0,y1,b	(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	x:(r2),b	
	move	#0,n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg9
	add	x,a	a1,x:(r3)+
	move	n3,x:(r3)+
	add	y,b	b,x:(r3)+
fin_calcul_buff_dg9
	rts

positif1
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	x0,y1,b		(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	#0,b	
	move	#0,n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg
	add	x,a	a1,x:(r3)+
	move	n3,x:(r3)+
	add	y,b	b,x:(r3)+
fin_calcul_buff_dg
	rts


droite_bc
	move	#$102,r0
	move	#$200,r1
	move	#$120,r2
	move	x:(r0)+,x1	; x1
	move	x:(r0)+,x0	; y1
	move	x:(r0)+,a	; x2
	move	x:(r0)+,b	; y2
	move	#$600,r3	; dans r3 buffer droit
	move	#$102,r0		
	sub	x1,a		; calcul delta x
	sub	x0,b		; calcul delta y
	jpl	positif11	; test signe du delta y
	move	#$300,r3	; on range dans le buffer gauche
	move	#$104,r0		
	neg	b	
	neg	a		
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg19

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	-x0,y1,b	(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	x:(r2),b	
	move	x:(r2),n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg19
	add	x,a	a1,x:(r3)+
	add	y,b	b1,x:(r3)+
	move	n3,x:(r3)+
fin_calcul_buff_dg19
	rts


positif11
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg1

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	x0,y1,b		(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	#0,b	
	move	x:(r2),n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg1
	add	x,a	a1,x:(r3)+
	add	y,b	b1,x:(r3)+
	move	n3,x:(r3)+
fin_calcul_buff_dg1
	rts


droite_cd
	move	#$104,r0
	move	#$200,r1
	move	#$120,r2
	move	x:(r0)+,x1	; x1
	move	x:(r0)+,x0	; y1
	move	x:(r0)+,a	; x2
	move	x:(r0)+,b	; y2
	move	#$600,r3	; dans r3 buffer droit
	move	#$104,r0		
	sub	x1,a		; calcul delta x
	sub	x0,b		; calcul delta y
	jpl	positif111	; test signe du delta y
	move	#$300,r3	; on range dans le buffer gauche
	move	#$106,r0		
	neg	b	
	neg	a		
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg29

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	x0,y1,b	(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	#0,b	
	move	x:(r2),n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg29
	add	x,a	a1,x:(r3)+
	move	n3,x:(r3)+
	add	y,b	b,x:(r3)+
fin_calcul_buff_dg29
	rts
positif111
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg2

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	-x0,y1,b		(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	x:(r2),b	
	move	x:(r2),n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg2
	add	x,a	a1,x:(r3)+
	move	n3,x:(r3)+
	add	y,b	b,x:(r3)+
fin_calcul_buff_dg2
	rts



droite_da
	move	#$106,r0
	move	#$200,r1
	move	#$120,r2
	move	x:(r0)+,x1	; x1
	move	x:(r0)+,x0	; y1
	move	x:(r0)+,a	; x2
	move	x:(r0)+,b	; y2
	move	#$600,r3	; dans r3 buffer droit
	move	#$106,r0		
	sub	x1,a		; calcul delta x
	sub	x0,b		; calcul delta y
	jpl	positif1111	; test signe du delta y
	move	#$300,r3	; on range dans le buffer gauche
	move	#$108,r0		
	neg	b	
	neg	a	
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg39

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	x0,y1,b	(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	#0,b	
	move	#0,n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg39
	add	x,a	a1,x:(r3)+
	add	y,b	b1,x:(r3)+
	move	n3,x:(r3)+
fin_calcul_buff_dg39
	rts

positif1111
	tst	b	b1,n1
	jeq	fin_calcul_buff_dg3

	move	x:(r0+n0),n3
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		x:(r2),y1
	mpy	-x0,y1,b	(r3)+n3	
	move	x:(r3)+n3,x0
	move	x:(r3)+n3,x0
	move	a1,x1
	move	a0,x0
	move	b1,y1
	move	b0,y0
	clr	a	x:(r2),b	
	move	#0,n3
	move	x:(r0),a
	do	n1,fin_calcul_buff_dg3
	add	x,a	a1,x:(r3)+
	add	y,b	b1,x:(r3)+
	move	n3,x:(r3)+
fin_calcul_buff_dg3
	rts




calcul_col
	move	r7,r3
	move	r0,r4
	move	x:(r0)+,x1	; x1
	move	x:(r0)+,x0	; y1
	move	x:(r0)+,a	; x2
	move	x:(r0)+,b	; y2
	move	x:(r7)+,x1
	move	x:(r7)+,a	

	move	#$a00,r2	; dans r3 buffer droit
	sub	x1,a	r3,r7
	sub	x0,b	r4,r0		; calcul delta y
	jpl	pos_col			; test signe du delta y
	move	#$900,r2		; on range dans le buffer gauche
	neg	b	r6,r0	
	neg	a	r5,r7
pos_col
	tst	b	b1,n1
	jeq	fin_calcul_col

	move	x:(r0+n0),n2
	move	x:(r1+n1),x0
	move	a1,y0
	mpy	y0,x0,a		(r2)+n2
	move	x:(r7),b
	move	a1,x1
	move	a0,x0
	tfr	b,a
	do	n1,fin_calcul_col
	add	x,b	a1,x:(r2)+	
	tfr	b,a
	rnd	a	
fin_calcul_col
	rts

receive_img
	move	#$a00,r0
	move	x:$120,y0
	do	y0,re1

	do	y0,re0
	jsr	load
	move	a1,y:(r0)+
re0
	jsr	load
	move	a1,y:(r0)+
re1
	do	y0,re10
	jsr	load
	move	a1,y:(r0)+
re10
	jsr	load
	move	a1,y:(r0)+

	rts

receive_1surX
	move	#$200,r0
	do	#256,re011
	jsr	load
	move	a1,x:(r0)+
re011
	rts

send	jclr	#1,X:HSR,*
	move	a1,X:HTX
	rts

send_x1	jclr	#1,X:HSR,*
	move	x1,X:HTX
	rts

load	
	movep	#1,X:PBC		
	jclr	#0,x:HSR,load
	move	x:HTX,a1
	rts

tab_line
	clr	a
	move	#1,a1
	move	#1,b1
	move	b1,x0
	move	x:$120,x1
	add	x1,a
	move	a1,x1
	move	#$0,r0
	clr	a	#0,b

	do	#256,fin_tab_line
	clr	a
	move	#$a00*2,a0
	move	b1,y1
	mac	x1,y1,a
	asr	a
	move	a0,x:(r0)+	
	add	x0,b
	
fin_tab_line
	rts

receive_palette
	move	#0,r0
	do	#512,fin_receive_palette
	jsr	load
	move	a1,y:(r0)+
fin_receive_palette
	rts


