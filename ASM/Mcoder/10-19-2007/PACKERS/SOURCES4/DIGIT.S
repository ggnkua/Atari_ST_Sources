start:	equ	$40000
length:	equ	123106

	lea	start,a6
	lea	-8(a6),a5
bcl1:
	moveq	#7,d7
bcl2:
	moveq	#0,d6
	btst	d7,(a6)
	beq.s	no1
	tas	d6
no1:
	btst	d7,1(a6)
	beq.s	no2
	bset	#6,d6
no2:
	btst	d7,2(a6)
	beq.s	no3
	bset	#5,d6
no3:
	btst	d7,3(a6)
	beq.s	no4
	bset	#4,d6
no4:
	btst	d7,4(a6)
	beq.s	no5
	addq	#8,d6
no5:
	btst	d7,5(a6)
	beq.s	no6
	addq	#4,d6
no6:
	btst	d7,6(a6)
	beq.s	no7
	addq	#2,d6
no7:
	btst	d7,7(a6)
	beq.s	no8
	addq	#1,d6
no8:
	move.b	d6,(a5)+
	dbra	d7,bcl2

	addq	#8,a6
	cmp.l	#start+length,a6
	blo.s	bcl1

	illegal
