	lea	$50000,a0

	lea	-$100(a0),a1
	move.l	4(a7),a5
	move.l	a1,4(a7)
	move.l	#255/4,d0
cp	move.l	(a5)+,(a1)+
	dbf	d0,cp
	move.l	a0,-$2c(a7)
	lea	-$100(a0),a1
	move.l	a1,(a1)+
	addq.l	#4,a1
	move.l	a0,(a1)+
	move.l	(a1)+,d0
	add.l	a0,d0
	move.l	d0,(a1)+
	add.l	(a1)+,d0
	move.l	d0,(a1)+
relog
	lea	-(load2-load1)(a7),a6
	move.l	4(a7),a5
	lea	prog+$1C(pc),a1
	move.l	2-$1C(a1),a0
	add.l	6-$1C(a1),a0
	add.l	14-$1C(a1),a0
	add.l	a1,a0
	move.l	8(a5),d0
	tst.l	(a0)
	beq.s	fin_rel
	add.l	(a0)+,a1

.1
	add.l	d0,(a1)
.2	clr.l	d1
	move.b	(a0)+,d1
	tst.w	d1
	beq.s	fin_rel
	cmp.b	#1,d1
	bne.s	.3
	lea	$fe(a1),a1
	bra.s	.2
.3	add.l	d1,a1
	bra.s	.1
fin_rel
	lea	prog+2(pc),a0
	lea	$1C-2(a0),a3
	move.l	(a0),$c(a5)
	add.l	(a0),d0
	move.l	d0,$10(a5)
	move.l	4(a0),$14(a5)
	add.l	4(a0),d0
	move.l	d0,$18(a5)
	move.l	8(a0),$1c(a5)
	lea	load1(pc),a1
	move.l	a6,a0
	moveq	#load2-load1-1,d0
.4	move.b	(a1)+,(a0)+
	dbf	d0,.4
add	jmp	(a6)
load1
	move.l	a5,a1
	move.l	$c(a1),d0		
	add.l	$14(a1),d0
	lsr.l	#2,d0
	addq.l	#2,d0
	lea	$100(a1),a1
	move.l	a1,a2
.1	move.l	(a3)+,(a1)+
	subq.l	#1,d0
	bne.s	.1
	move.l	$18(a5),a0
.2	clr.l	(a0)+
	cmp.l	a7,a0
	bcs.s	.2
	jmp	(a2)
load2
prog
	incbin	'c:\work\crack.prg'