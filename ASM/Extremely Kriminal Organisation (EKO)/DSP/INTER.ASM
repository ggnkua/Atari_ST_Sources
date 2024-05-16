	org	p:$0

;	dans x:$0 les points x1,y1,z1  x2,y2,z2  x3,y3,z3  x4,y4,z4  x5,y5,z5
; 	registre utilisee r6,n6,r5,n5 a,b x1,x0 y1,y0

	org	p:$40
main
	jsr	calcul_inter
	jmp	main

calcul_inter
	move	#0,r6
	move	#15,r5	
	move	#2,n6
	move	#0,a
	move	#0,b
	do	#3,bcl1
	move	x:(r6)+,a
	move	x:(r6+n6),b
	sub	b,a	
	move	a1,x:(r5)+
bcl1
	move	#6,r6
	nop

	move	x:(r6)+,a
	move	a1,x0
	move	x:(r6+n6),b
	sub	b,a
	move	a1,x:(r5)+
	move	x:(r6)+,a
	move	a1,x1
	move	x:(r6+n6),b
	sub	b,a
	move	a1,x:(r5)+
	move	x:(r6)+,a
	move	x:(r6+n6),b
	move	a1,y1
	sub	b,a
	move	a1,x:(r5)+

	move	#12,r6
	move	x0,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r5)+	
	move	x1,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r5)+	
	move	y1,a
	move	x:(r6)+,b
	sub	b,a
	move	a1,x:(r5)+	

	move	#3,r6
	do	#3,bcl2
	move	x:(r6)+,a
	move	x:(r6+n6),b
	sub	b,a	
	move	a1,x:(r5)+
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
	move	a1,x:(r5)+
	move	a0,x:(r5)+

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

	move	b0,x0
	move	#0,b
	move	a0,b1
	rep	#24
	div	x0,b
	move	b0,x0
	move	#15,r5
	move	#3,r6
	move	x:(r5)+,x1
	mpyr	x0,x1,a		x:(r6)+,x1
	add	x1,a		x:(r5)+,x1
	mpyr	x0,x1,b		x:(r6)+,x1
	add	x1,b		x:(r5)+,x1
	move	a1,y1	
	mpyr	x0,x1,a		x:(r6)+,x1
	add	x1,a		b1,y0		
	move	#0,b		
; y1=x y0=y a1=z
	rts
pas_d_inter
	move	#$ffffff,b
	rts


	org	x:$0
	dc	0,0,0
	dc	10,10,-100
	dc	0,0,-50
	dc	50,0,-50
	dc	0,50,-50	
