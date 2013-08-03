
	movea.l scradr2,A0
	movea.l scradr1,A1

	move.l  points+8,D0
	sub.l   points+0,D0     ;d0: dx
	swap    D0
	divs.l  #140,D0         ;dx/280
	move.l  points+12,D1
	sub.l   points+4,D1     ;d1: dy
	swap    D1
	divs.l  #100,D1         ;dy/200

	movea.l D0,A5
	adda.l  A5,A5

;Startadresse zum auslesen
	move.l  points+4,D2
	muls.l  #160,D2
	add.l   points,D2
	lea     0(A0,D2.l*2),A0

;Startadresse zum Zeichnen
	lea     640*12+4*7(A1),A1

	lea     multab,A6

	moveq   #0,D4
	moveq   #0,D5

	move.w  #100-1,D7
rum_yloop:

	swap    D5
	move.l  0(A6,D5.w*4),D3
	swap    D5
	lea     0(A0,D3.l*2),A2

	sub.l   D1,D4
	add.l   D0,D5
	movea.l A1,A3
	move.w  #140/4-1,D6
	movem.l D4-D5,-(SP)
	moveq   #0,D5
rum_xloop:
	REPT 4
	swap    D5
	move.w  2(A6,D5.w*4),D3
	swap    D5
	swap    D4
	add.w   D4,D3
	swap    D4

	move.l  0(A2,D3.w*2),(A3)+

	add.l   A5,D4
	add.l   D1,D5

	ENDR
	dbra    D6,rum_xloop
	movem.l (SP)+,D4-D5

	lea     640(A1),A1

	dbra    D7,rum_yloop

	rts
