; Decryptage de ABCDE * 9 = FGHIJ
; A - J sont 10 chiffres diff‚rents
; by Dumbo - XXeme siecle

	MC68030
	MC68881
	OPT	x+
	OUTPUT	"A:\DECRYPT1.PRG"

	TEXT

	lea.l	chif,a0
	move.w	#10,d4
	move.w	#4,d5
	move.w	#-1,d6
	move.w	#5,d0
chpred:	subq.w	#1,d0
debut:	move.w	(a0,d0.w*2),d1
suiv:	addq.w	#1,d1
	cmp.w	d4,d1
	beq.s	chpred
	tst.w	d0
	beq.s	suite1
	move.w	d0,d3
	subq.w	#1,d3
loop1:	cmp.w	(a0,d3.w*2),d1
	beq.s	suiv
	dbra	d3,loop1
suite1:	move.w	d1,(a0,d0.w*2)
	cmp.w	d5,d0
	beq.s	suite2
	move.w	d6,d2	; b
	move.w	d0,d1
loop8:	addq.w	#1,d1	; i
loop2:	addq.w	#1,d2
	move.w	d1,d3
	subq.w	#1,d3	; j
loop3:	cmp.w	(a0,d3.w*2),d2
	beq.s	loop2
	dbra	d3,loop3
	move.w	d2,(a0,d1.w*2)
	cmp.w	d5,d1
	blt.s	loop8
; multiplication
suite2:	move.l	a0,a1
	clr.l	d0
	clr.l	d1
compt:	SET	10000
	REPT	4
	move.w	(a1)+,d1
	mulu.w	#compt,d1
	add.w	d1,d0
compt:	SET	compt/10
	ENDR
	move.w	(a1)+,d1
	ext.l	d1
	add.w	d1,d0
	cmp.w	#10973,d0
	bgt	fin
	move.w	d0,d1
	lsl.l	#3,d0
	add.l	d1,d0
	lea.l	20(a0),a1
	REPT	4
	divu.w	d4,d0
	swap	d0
	move.w	d0,-(a1)
	clr.w	d0
	swap	d0
	ENDR
	move.w	d0,-(a1)
; Test nombre valable
	move.w	#18,d3
	move.w	#16,d0
loop4:	move.w	(a0,d0.w),d1
	move.w	d0,d2
loop5:	addq.w	#2,d2
	cmp.w	(a0,d2.w),d1
	beq.s	badnum
	cmp.w	d3,d2
	bne.s	loop5
	subq.w	#2,d0
	bpl.s	loop4
; Affichage
	move.l	a0,a1
	lea.l	txt,a2
	move.l	a2,-(sp)
	move.w	d5,d0
loop6:	move.w	(a1)+,d1
	add.b	#48,d1
	move.b	d1,(a2)+
	dbra	d0,loop6
	addq.l	#7,a2
	move.w	d5,d0
loop7:	move.w	(a1)+,d1
	add.b	#48,d1
	move.b	d1,(a2)+
	dbra	d0,loop7
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	lea.l	chif,a0
badnum:	move.w	d5,d0
	bra	debut
fin:	move.w	#7,-(sp)
	trap	#1
	clr.w	(sp)
	trap	#1


	DATA

chif:	DC.w	0,1,2,3,3
	DCB.w	5
txt:	DC.b	"00000 * 9 = 00000",13,10,0
