	move.l	#0,-(sp)
	move.w	#32,-(sp)
	trap	#1		superviseur
	addq.l	#6,sp
	move.l	d0,savsup

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14		rez
	adda.l	#12,sp

	pea	lirejoy
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		passage mode joy
	addq.l	#8,sp

	move.w	#34,-(sp)
	trap	#14		recupere adr joy
	addq.l	#2,sp
	add.l	#61,d0
	move.l	d0,adrjoy
			


	moveq	#0,d7		calcul des 16 positions du vaisseau
	move.l	#sprite,a1
loop2				
	moveq	#40,d0
	move.l	#sp1,a0
loop
LM1	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	ror.l	d7,d1
	ror.l	d7,d2
	ror.l	d7,d3
	ror.l	d7,d4
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	swap	d1
	swap	d2
	swap	d3
	swap	d4

LM2	moveq	#0,d5
	moveq	#0,d6
	move.w	(a0)+,d5
	move.w	(a0)+,d6
	ror.l	d7,d5
	ror.l	d7,d6
	or.w	d1,d5
	or.w	d2,d6
	moveq	#0,d1
	moveq	#0,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	ror.l	d7,d1
	ror.l	d7,d2
	or.w	d3,d1
	or.w	d4,d2
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	swap	d5
	swap	d6
	swap	d1
	swap	d2

LM3	move.w	d5,(a1)+
	move.w	d6,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+

	dbra	d0,loop

	addq	#1,d7
	cmp.b	#16,d7
	bne	loop2


	

joy	move.l	#0,a0
	move.l	#$eab,a0
	moveq	#0,d0
	move.b	(a0),d0
	


 	cmpi.b 	#0,d0		test joy/fire
	beq  	suite9
	cmpi.b	#128,d0		test fire
	bne	suite1
	subi.b	#128,d0
*	andi.b	#240,d0
suite1	cmpi.b	#1,d0		haut
	bne	suite2
	sub.b	#1,y
	bra	suite9

suite2	cmpi.b	#2,d0		bas
	bne	suite3
	add.b	#1,y
	bra	suite9

suite3	cmpi.b	#4,d0		droite
	bne	suite4
	add.w	#1,x
	bra	suite9

suite4	cmpi.b	#8,d0		gauche
	bne	suite5
	sub.w	#1,x
	bra	suite9

suite5	cmpi.b	#9,d0		haut droite
	bne	suite6

	bra	suite9

suite6	cmpi.b	#10,d0		bas droite
	bne	suite7

	bra	suite9

suite7	cmpi.b	#5,d0		haut gauche
	bne	suite8

	bra	suite9

suite8	cmpi.b	#6,d0		bas gauche
	bne	suite9

suite9

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	lea	x,a0
	lea	y,a1
	move.w	(a0),d0
	move.b	(a1),d1
	move.w	d0,d2
	andi.w	#$1f0,d0
	lsr.w	#1,d0
	mulu	#160,d1
	add.w	d1,d0
	add.l	#$f8000,d0
	andi.w	#$f,d2
	mulu	#984,d2
	
	lea	sprite,a0
	move.l	d0,a1
	add.l	d2,a0

	
	moveq	#40,d3
aff	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.l	#136,a1
	dbra	d3,aff
	

	cmp.b	#$39,$fffffc02
	beq 	fin




	bra	joy

fin
	move.w	d0,-(sp)
	move.w	#2,-(sp)
*	trap	#1
	addq.l	#4,sp

	move.w	#1,-(sp)
*	trap	#1
	addq.l	#2,sp

	pea	lirejoy+1
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		hors fonction joy
	addq.l	#8,sp
	
	pea	lirejoy+2
	move.w	#1,-(sp)
	move.w	#25,-(sp)
 	trap	#14		passage mode souris
	addq.l	#8,sp



	move.l	savsup,-(sp)
	move.w	#32,-(sp)
	trap	#1		util
	addq.l	#6,sp

	move.w	#0,-(sp)
	trap	#1		fin
	addq.l	#2,sp



	data

savsup	ds.l 1
sp1	incbin	sprite.jeu
sprite	ds.l	16*656
adrjoy	ds.l	1

lirejoy	dc.b	$0,$14,$15,$8
x	dc.w	160
y	dc.b	70


	end
	