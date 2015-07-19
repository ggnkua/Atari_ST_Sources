freq:	equ	$58000

topos:	equ	$60000	;unused
datas:	equ	$68000	;unused

debut:	equ	$20000
;fin:	equ	$20000+222292
fin:	equ	$20000+20000

	clr	prof
rec:
	bsr	compact
	sub.l	#datas,a6
	cmp.l	min,a6
	bhs.s	notmin
	move.l	a6,min
	move	prof,max
notmin:	addq	#1,prof
	cmp	#100,prof
	blo.s	rec
	illegal
min:	dc.l	-1
prof:	dc.w	0
max:	dc.w	0

compact:
	lea	topos,a1
	lea	datas,a6

	lea	debut,a5
	lea	freq,a4

	moveq	#1,d3
	moveq	#0,d4
	moveq	#0,d5
	move	#$10000/4-1,d0
	move.l	a4,a0
clrf:	clr.l	(a0)+
	dbra	d0,clrf

pafini:
	move	d4,a2
	move	d5,a3
	moveq	#0,d6	;status fixed
	move.l	a5,a0
	move	prof,d7
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d0
suivant:
	move	(a0)+,d0
	cmp	d4,d0
	bne.s	pas1
	addq	#1,d1
	cmp	#2,d1
	blo.s	nxt
	or	#1,d6
	move	d6,d0
	and	#7-1,d0
	bne.s	fixed
	bra.s	nxt
pas1:	cmp	d5,d0
	bne.s	pas2
	addq	#1,d2
	cmp	#2,d2
	blo.s	nxt
	or	#2,d6
	move	d6,d0
	and	#7-2,d0
	bne.s	fixed
	bra.s	nxt
pas2:
	addq.b	#1,0(a4,d0.L)
	cmp.b	#2,0(a4,d0.L)
	blo.s	nxt
	bset	#2,d6
	bne.s	already
	move	d0,a2		;nouveau topo 1
	move	d6,d0
	and	#3,d0
	bne.s	fixed
	bra.s	nxt
already:
	cmp	a2,d0
	beq.s	nxt
	move	d0,a3
	bra.s	fixed
nxt:	dbra	d7,suivant
	moveq	#0,d7
fixed:
	neg	d7
	add	prof,d7
	addq	#1,d7
revoit:
	moveq	#0,d0
	move	(a5),d0
	clr.b	0(a4,d0.L)
	cmp	d4,d0
	bne.s	pl1
	bsr.s	zero
	bsr.s	one
	bra.s	next2
pl1:	cmp	d5,d0
	bne.s	pl2
	bsr.s	one
	bsr.s	zero
	bra.s	next2
pl2:	cmp	a2,d0
	bne.s	pl3
	move	a2,d4
	bsr.s	zero
	bsr.s	zero
	move	d4,(a6)+
;	addq	#2,a6
	bra.s	revoit
pl3:	cmp	a3,d0
	bne.s	pl4
	move	a3,d5
	bsr.s	zero
	bsr.s	zero
	bsr.s	zero
	bsr.s	zero
	move	d5,(a6)+
;	addq	#2,a6
	bra.s	revoit
pl4:	bsr.s	one
	bsr.s	one
	move	d0,(a6)+
;	addq	#2,a6
next2:	addq	#2,a5
	dbra	d7,revoit
	cmp.l	#fin,a5
	blo	pafini
fil0:
	cmp	#1,d3
	beq.s	fini
	bsr.s	zero
	bra.s	fil0
fini:	rts

zero:	add	d3,d3
	bcc.s	zero2
;	move	d3,(a1)+
	addq	#2,a1
	moveq	#1,d3
zero2:	rts

one:	add	d3,d3
	bcc.s	one2
	addq	#1,d3
;	move	d3,(a1)+
	addq	#2,a1
	moveq	#0,d3
one2:	addq	#1,d3
	rts

