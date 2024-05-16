;
; 3Šme m‚thode : calcul des fr‚quences
;
; 1) bytes
;
debut:	equ	$20000
fin:	equ	debut+224094
datas:	equ	$57000
findatas:equ	$57000+$200
trions:	equ	findatas

	lea	debut,a0
	lea	fin,a1
	lea	datas,a6
	move.l	a6,a5
	moveq	#-1,d0
	moveq	#0,d1
clrk:	move	d1,(a5)+
	dbra	d0,clrk

rept:	moveq	#0,d0
	move.b	(a0)+,d0
	add	d0,d0
	addq	#1,0(a6,d0.L)
	cmp.l	a1,a0
	blo.s	rept

	lea	trions,a2
	lea	datas,a5
	lea	findatas,a6
tri1:	moveq	#0,d5
	move.l	d5,a1

	move.l	a5,a4
tri2:	cmp	(a4)+,d5
	blo.s	set1
tri3:	cmp.l	a6,a4
	blo.s	tri2
	move.l	a1,d0
	beq.s	fini
	sub.l	a5,d0
	lsr.l	#1,d0
	move	d0,(a2)+
	move	d5,(a2)+
	clr	(a1)
	bra.s	tri1
fini:
	illegal
set1:
	lea	-2(a4),a1
	move	(a1),d5
	bra.s	tri3

