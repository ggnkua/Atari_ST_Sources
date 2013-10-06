	opt	x+
	bsr	res
start	
	bsr	set
	lea	data(pc),a3
	moveq	#0,d5
	moveq	#0,d6
	moveq	#5,d7
loop	bsr	losuj
	cmp.b	#49,d0
	bhi.s	loop
	moveq	#0,d1
	move.b	d0,d1
	move.w	d6,d4
	moveq	#0,d3
	lea	zapis(pc),a4
compare
	cmp.b	(a4)+,d1
	beq.s	start
	dbf	d4,compare
	move.b	d1,(a4,d3.w)
	addq.l	#1,a4
	tst.b	d1
	beq.s	only
	subq.w	#1,d1
	add.w	d1,d1
only	lea	liczba(pc),a0
	move.w	(a0,d1.w),(a3)+
	addq.w	#2,a3
	addq.w	#1,d6
	dbf	d7,loop
	pea	data(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	cmp.b	#$1b,d0
	bne.s	start
	clr.l	-(a7)
	trap	#1

losuj	move.w	#17,-(a7)
	trap	#14
	addq.l	#2,a7
	rts
res	*clr.l	-(a7)
	*move.w	#32,-(a7)
	*trap	#1
	*addq.l	#6,a7
	clr.w	-(a7)
	pea	$78000
	pea	$78000
	move.w	#5,-(a7)
	trap	#14	
	adda.l	#12,a7
	rts
set	moveq	#-1,d0
	moveq	#-1,d1
	movem.l	d0-d1,zapis
	move.l	#$2c20,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	#$2e0d,d5
	movem.l	d0-d5,data
	rts
zapis	dc.l	-1,-1
liczba	dc.b	' 1 2 3 4 5 6 7 8 910111213141516171819202122232425'
	dc.b	'26272829303132333435363738394041424344454647484950'
data	ds.w	1
	dc.b	', '
	ds.w	1
	dc.b	', '
	ds.w	1
	dc.b	', '
	ds.w	1
	dc.b	', '
	ds.w	1
	dc.b	', '
	ds.w	1
	dc.b	'.',13,10,0