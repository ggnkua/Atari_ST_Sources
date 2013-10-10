LIGHT
;	movem.l	CLR,d0-d7/a0-a6
;calcul du vecteur vision
	move	X1,d0		
	move	Y1,d1
	move	Z1,d2
	moveq	#0,d3
	moveq	#0,d4
	move.l	#500,d5
	sub	d0,d3
	sub	d1,d4
	sub	d2,d5
	move	d3,a0	;vx
	move	d4,a1	;vy
	move	d5,a2	;vz
;calcul de p
	move	X2,d3
	move	Y2,d4
	move	Z2,d5

	sub	d0,d3	;px1
	sub	d1,d4	;py2
	sub	d2,d5	;pz3
	move	d3,a3
	move	d4,a4
	move	d5,a5
;calcul de q
	move	X3,d3
	move	Y3,d4
	move	Z3,d5
	sub	d0,d3	;qx1
	sub	d1,d4	;qy2
	sub	d2,d5	;qz3
;calcul du prod vectoriel:n=p^q
	move	a4,d1	;py2
	move	a5,d2	;pz3
	muls	d5,d1	
	muls	d4,d2
	sub	d2,d1	;nx
	move	d1,d7		

	move	a3,d0	;px1
	move	a5,d2	;pz3
	muls	d3,d2
	muls	d5,d0
	sub	d0,d2	;ny
	move	d2,a6	

	move	a3,d0	;px1
	move	a4,d1	;py2
	muls	d4,d0
	muls	d3,d1
	sub	d1,d0	;nz
;produit scalaire v.n
	moveq	#0,d1
	move	d7,d1	;nx
	moveq	#0,d2
	move	a6,d2	;ny
	moveq	#0,d3
	move	d0,d3	;nz
	moveq	#0,d4
	move	a0,d4	;vx
	moveq	#0,d5
	move	a1,d5	;vy
	moveq	#0,d6
	move	a2,d6	;vz

	muls	d1,d4
	muls	d2,d5
	muls	d3,d6	
	add.l	d4,d5
	add.l	d5,d6	;v.n
	move.l	d6,a4
;calcul de Id=k*(N.V)/(N*L)
;calcul des deus normes
	moveq	#0,d1
	move	d7,d1	;nx
	moveq	#0,d2
	move	a6,d2	;ny
	moveq	#0,d3
	move	d0,d3	;nz
	moveq	#0,d4
	move	a0,d4	;vx
	moveq	#0,d5
	move	a1,d5	;vy
	moveq	#0,d6
	move	a2,d6	;vz
	
	muls	d1,d1
	muls	d2,d2
	muls	d3,d3
	add.l	d1,d2
	add.l	d2,d3
	move.l	d3,d1
	bsr	SQR
	move.l	d2,d3

	muls	d4,d4
	muls	d5,d5
	muls	d6,d6
	add.l	d4,d5
	add.l	d5,d6
	move.l	d6,d1
	bsr	SQR
	move.l	d2,d6

	move.l	#$ff,$ffff9800
	mulu.l	d3,d6
	move.l	a4,d0
	asl.l	#6,d0	;k=64
	divu.l	d6,d0	;Id
	RTS

;racine carree
SQR
	movem.l	d0-d1/d3-d4,-(sp)
	moveq	#12,d0		;nb iterations
	move.l	#5,d2		;x0
;suite de la forme:Xn+1=(Xn+A/Xn)/2
.LOOP
	move.l	d2,d3
	move.l	d1,d4
	divu.l	d3,d4		;A/Xn
	add.l	d3,d4		;A/Xn+Xn
	asr.l	d4
	move.l	d4,d2
	dbf	d0,.LOOP
	movem.l	(sp)+,d0-d1/d3-d4
	rts

	SECTION	DATA
X1	DC	20
Y1	DC	-20
Z1	DC	10
X2	DC	20
Y2	DC	20
Z2	DC	10
X3	DC	-20
Y3	DC	20
Z3	DC	100