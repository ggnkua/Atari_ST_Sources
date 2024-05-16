PBC	equ	$ffe0
HSR	equ	$ffe9
HTX	equ	$ffeb
dimx	equ	192
dimy	equ	80
haut:	equ	120
fluid:	equ	0.9
	org	p:00
	jmp	start
	
	org	p:$40
start:
	move	#-1,m0
	move	#-1,m1
	move	#-1,m2
	move	#-1,m3
	move	#-1,m4
	movep	#1,X:PBC		; configure for host port
;-------------------------------------- clear map
	move	#map1,r0
	move	#map2,r4
	move	#0,x0
	move	#0,y0
	move	#dimx*dimy,r1
	rep	r1
	move	x0,x:(r0)+	y0,y:(r4)+
;-------------------------------------- Init float horizon
	move	#float1,r0
	move	#>haut,x0
	rep	#dimx*2
	move	x0,y:(r0)+
;-------------------------------------- recept color
	move	#color,r0
	do	#dimy,recept_color_loop
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,x0
	move	x0,y:(r0)+
recept_color_loop:
;--------------------------------------	Vbl loopz
vbl_loopz:
	;clr	a
	;move	a1,x:0
	jsr	gere_eau1

	jsr	aff3d1
	
	jsr	recept1

	jsr	gere_eau2

	jsr	aff3d2
	
	jsr	recept2
	
	jmp	vbl_loopz
aff3d1:
 	move	#map1+dimx*(dimy-1),r0		; pointe en bas
 	move	#dimx,n1
 	move	#color,r2
 	move	#float1,r4
 	move	#0,n4
 	move	#$ffff,r3
 	move	#>1,y0
 	move	#0.004,y1
 	do	#dimx,aff1_x
 	move	r0,r1
	clr	a		(r0)+		; colonne suivante
 	move	a,x1
 	do	#dimy,aff1_y
 	move	x:(r1)-n1,x0
 	move	a,b
 	macr	y1,x0,b				; divise l'altitude	
 	sub	x1,b	b1,x0			; alt - floathoz
 	jle	<no_aff1
	sub	y0,b	x0,x1			; pour le dbf
	
	jclr	#1,X:HSR,*
	move	b1,X:HTX			; send hauteur
	move	a,n2
	jclr	#1,X:HSR,*
	move	y:(r2+n2),x0
	move	x0,X:HTX			; send couleur
no_aff1:
 	add	y0,a
aff1_y
	clr	a
	move	y:(r4),a1
	sub	x1,a	x1,y:(r4)+
	;jmp	no_eff
	jle	no_eff
	sub	y0,a
	jclr	#1,X:HSR,*
	move	a1,X:HTX			; send hauteur eff
	jclr	#1,X:HSR,*
	move	n4,X:HTX			; send zero
no_eff
	jclr	#1,X:HSR,*
	move	r3,X:HTX			; send fin
aff1_x
	rts		
aff3d2:
 	move	#map1+dimx*(dimy-1),r0		; pointe en bas
 	move	#dimx,n1
 	move	#color,r2
 	move	#$ffff,r3
 	move	#float2,r4
 	move	#0,n4
 	move	#>1,y0
 	move	#0.004,y1
 	do	#dimx,aff2_x
 	move	r0,r1
	clr	a		(r0)+		; colonne suivante
 	move	a,x1
 	do	#dimy,aff2_y
 	move	y:(r1)-n1,x0
 	move	a,b
 	macr	y1,x0,b				; divise l'altitude	
 	sub	x1,b	b1,x0			; alt - floathoz
 	jle	no_aff2
	sub	y0,b		x0,x1
	jclr	#1,X:HSR,*
	move	b1,X:HTX			; send hauteur
	move	a,n2
	jclr	#1,X:HSR,*
	move	y:(r2+n2),x0
	move	x0,X:HTX			; send couleur
no_aff2:
 	add	y0,a
aff2_y
	clr	a
	move	y:(r4),a1
	sub	x1,a	x1,y:(r4)+
	;jmp	no_eff2
	jle	no_eff2
	sub	y0,a
	jclr	#1,X:HSR,*
	move	a1,X:HTX			; send hauteur eff
	jclr	#1,X:HSR,*
	move	n4,X:HTX			; send zero
no_eff2
	jclr	#1,X:HSR,*
	move	r3,X:HTX			; send fin
aff2_x
	rts		

recept1:
	clr	a
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,r0
	move	r0,x0
	cmp	x0,a
	jeq	no_recept1
	move	#map1,r0
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,y1
	do	x0,recept1_loopz
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,n0
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,r1
	move	r1,x0
	lua	(r0)+n0,r1
	rep	x0
	move	y1,x:(r1)+	
recept1_loopz:
no_recept1:	
	rts	

recept2:
	clr	a
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,r0
	move	r0,x0
	cmp	x0,a
	jeq	no_recept2
	move	#map1,r0
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,y1
	do	x0,recept2_loopz
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,n0
	jclr	#0,X:HSR,*		; wait for data from host
	move	X:HTX,r1
	move	r1,x0
	lua	(r0)+n0,r1
	rep	x0
	move	y1,y:(r1)+
recept2_loopz:
no_recept2:	
	rts	

	
gere_eau1:
	jsr	init_reg_gere_eau
	do	#dimy-2,gere_eau1_y
	move	y:(r0)+,b1
	move	y:(r1)+,x0
	do	#dimx-2,gere_eau1_x
	add	x0,b		y:(r2)+,x0
	add	x0,b		y:(r3)+,x0
	add	x0,b		x:(r4),a1
	move	b1,x0
	mac	x1,x0,a		y:(r0)+,b1
	move	a1,y0		
	mpy	y1,y0,a		y:(r1)+,x0
	move	a1,x:(r4)+
gere_eau1_x:
	move	(r0)+
	move	(r1)+
	move	(r2)+n2
	move	(r3)+n3
	move	(r4)+n4
gere_eau1_y:
	rts
gere_eau2:
	jsr	init_reg_gere_eau
	do	#dimy-2,gere_eau2_y
	move	x:(r0)+,b1
	move	x:(r1)+,x0
	do	#dimx-2,gere_eau2_x
	add	x0,b		x:(r2)+,x0
	add	x0,b		x:(r3)+,x0
	add	x0,b		y:(r4),a1
	move	b1,x0
	mac	x1,x0,a		x:(r0)+,b1
	move	a1,y0		
	mpy	y1,y0,a		x:(r1)+,x0
	move	a1,y:(r4)+
gere_eau2_x:
	move	(r0)+
	move	(r1)+
	move	(r2)+n2
	move	(r3)+n3
	move	(r4)+n4
gere_eau2_y:
	rts
	
init_reg_gere_eau:
	move	#map1+1,r0
	move	#map1+dimx,r1
	move	#map1+dimx+2,r2
	move	#map1+2*dimx+1,r3
	move	#map1+dimx+1,r4
	move	#2,n2
	move	#2,n3
	move	#2,n4
	move	#-0.5,x1
	move	#-fluid,y1
	rts





	org	x:00
map1:
	ds	dimx*dimy
	
	org	y:00
map2:
	ds	dimx*dimy
color:
	ds	dimy
float1:
	ds	dimx
float2:
	ds	dimx
