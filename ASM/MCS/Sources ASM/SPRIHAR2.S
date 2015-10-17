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

	move.l	#a4ecran,d0
	and.l	#$ffffff00,d0
	move.l	d0,base
	move.b	base+1,$ff8201
	move.b	base+2,$ff8203
	move.b	base+3,$ff820d
	move.b	#80,$ff820f
	add.l	#160*2,d0 		??????
	move.l	d0,adscreen
	move.l	d0,adscreen1
	
	move.l	d0,a0
	move.l	#400*160/4/3*2,d0
motif	move.l	#$ff00f,(a0)+
	move.l	#$f0ff0,(a0)+
	move.l	#$fff0f,(a0)+
	dbra	d0,motif

joy	move.l	#$eab,a0
	moveq	#0,d0
	move.b	(a0),d0
 	cmpi.b 	#0,d0		test joy/fire
	beq  	suite9
	cmpi.b	#128,d0		test fire
	bne	suite1
	subi.b	#128,d0
suite1	cmpi.b	#1,d0		haut
	bne	suite2
	sub.w	#1,y
	bne.s	suite11
	move.w	#1,y
suite11	
	bra	suite9

suite2	cmpi.b	#2,d0		bas
	bne	suite3
	add.w	#1,y
	cmp.w	#199-41,y
	bls.s	suite21
	move.w	#199-41,y
suite21	
	bra	suite9

suite3	cmpi.b	#4,d0		gauche
	bne	suite4
	jsr	gauche
	bra	suite9

suite4	cmpi.b	#8,d0		droite
	bne	suite5
	jsr	droite
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
	move.w	x,d0
	move.w	xe,d1
	add.w	d1,d0
	move.w	y,d1
	move.w	d0,d2
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	mulu	#320,d1
	add.w	d1,d0
	add.l	adscreen1,d0
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
	add.l	#136+160,a1
	dbra	d3,aff
	
	move.w	ye,d0
	addi.b	#1,d0
	cmpi.b	#200,d0
	bne	cestbon
	moveq	#0,d0
cestbon move.w	d0,ye
	mulu.w	#320,d0
	move.l	base,d1
	add.l	#160*2,d1	????
	add.l	d1,d0
	move.l	d0,adscreen1
	moveq	#0,d1
	move.w	xe,d1
	andi.w	#$fff0,d1
	lsr.w	#1,d1		xe/16*8=xe/2
	add.l	d1,d0
	move.l	d0,adscreen

	cmp.b	#$39,$fffffc02
	beq 	fin

	move.w	#0,$ff8240

	move.w	#37,-(sp)
	trap	#14			vsync
	addq.l	#2,sp

	move.w	#$777,$ff8240

	move.w	xe,d0
	andi.b	#$f,d0
	move.b	d0,$ff8265
	beq.s	v80
v76	move.b	#76,$ff820f
	bra.s	aller
v80	move.b	#80,$ff820f
aller	
	move.b	adscreen+1,$ff8205
	move.b	adscreen+2,$ff8207
	move.b	adscreen+3,$ff8209

	bra	joy

gauche	movem.l	d0-d3,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	move.w	xe,d0
	move.w	x,d1
	cmpi.w	#0,d0
	bne	xesup0
xeeg0	cmpi.w	#0,d1
	beq	suitg
xsup0	subi.w	#1,d1
	bra	suitg
xesup0	cmpi.w	#50,d1		xmin=50
	beq	xegxmin
xsupxmin subi.w	#1,d1
	bra	suitg
xegxmin	subi.w	#1,d0
suitg	move.w	d0,xe
	move.w	d1,x
	movem.l	(sp)+,d0-d3
	rts

droite	movem.l	d0-d3,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	move.w	xe,d0
	move.w	x,d1
	cmpi.w	#320,d0
	bne	xeinf320
xeeg320	cmpi.w	#319-32,d1
	beq	suitd
xinf187	addi.w	#1,d1
	bra	suitd
xeinf320 cmpi.w	#238,d1		xmax=238
	bne	xinfxmax	
xegxmax	addi.w	#1,d0
	bra	suitd
xinfxmax addi.w	#1,d1
suitd	move.w	d0,xe
	move.w	d1,x
	movem.l	(sp)+,d0-d3
	rts

fin
	move.w	d0,-(sp)
	move.w	#2,-(sp)
*	trap	#1
	addq.l	#4,sp

	move.w	#1,-(sp)
*	trap	#1
	addq.l	#2,sp

	clr.b	$ff820f
	clr.b	$ff8265

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
base	ds.l 	1
adscreen ds.l	1
adscreen1 ds.l	1

lirejoy	dc.b	$0,$14,$15,$8
x	dc.w	160
y	dc.w	100
xe	dc.w	0
ye	dc.w	0

a4ecran	ds.b	32000*4+256
	end
	