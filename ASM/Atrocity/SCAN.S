	opt	x+

TS	equ	0
TE	equ	79
NB	equ	9
BU	equ	$100000
FC	equ	0
OP	equ	8
DE	equ	0
ON	equ	1
OFF	equ	0
;scanner
SCAN	equ	ON
;continue on error
CONT	equ	OFF
;read every sector
READ	equ	OFF

scanner
	dc.w	$a00a
	lea	intro(pc),a0
	bsr	aff
	lea	BU,a6
	moveq	#TS,d6
	moveq	#TE,d5
.2
	lea	msgr(pc),a0
	cmp.w	#8,.7+2
	beq.s	.8
	lea	msgw(pc),a0
.8
	move.w	d6,d0
	and.w	#$F0,d0
	lsr.w	#4,d0
	add.b	#'0',d0
	move.b	d0,20(a0)
	move.w	d6,d0
	and.w	#$0F,d0
	add.b	#'0',d0
	cmp.b	#'9'+1,d0
	blo.s	.9
	add.b	#'A'-'9'-1,d0
.9	move.b	d0,21(a0)
	moveq	#0,d0
	move.w	d6,d0
	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,16(a0)
	swap	d0
	add.b	#'0',d0
	move.b	d0,17(a0)
	move.l	a6,d0
	lea	33(a0),a1
	bsr	hex

	bsr	aff
	move.w	#NB,-(sp)
	move.w	#FC,-(sp)
	move.w	d6,-(sp)
	move.w	#1,-(sp)
	move.w	#DE,-(sp)
	clr.l	-(sp)
	pea	(a6)
.7	move.w	#OP,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.w	d0
	bmi	.3
.6
	moveq	#SCAN,d0
	tst.w	d0
	beq	.10
	bsr	scan
.10	
	lea	NB*$200(a6),a6
	cmp.w	d6,d5
	beq.s	.1
	addq.w	#1,d6
	bra	.2
.1	lea	ok(pc),a0
	bsr	aff
	bsr	inp
	bra	fin
.15	bsr	goon
	bra	.6
.3
	moveq	#CONT,d1
	tst.w	d1
	beq.s	.16
	moveq	#READ,D0
	tst.w	d0
	bne	.15
.16	lea	err(pc),a0
	bsr	aff
	moveq	#CONT,d1
	tst.w	d1
	beq	.13
	lea	cont(pc),a0
	bsr	aff
	bsr	inp
	cmp.b	#'y',d0
	bne.s	.14
	bra	.6
.14
	cmp.b	#'Y',d0
	bne.s	fin
	bra	.6
.13	bsr	inp
fin
	dc.w	$a009
	clr.w	-(sp)
	trap	#1
goon
	move.l	a6,a5
	moveq	#1,d7
.1	move.w	#1,-(sp)
	move.w	#FC,-(sp)
	move.w	d6,-(sp)
	move.w	d7,-(sp)
	move.w	#DE,-(sp)
	clr.l	-(sp)
	pea	(a5)
	move.w	#OP,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.w	d0
	bmi	.2
.3	lea	$200(a5),a5
	addq.w	#1,d7
	cmp.b	#NB+1,d7
	bne.s	.1
	rts
.2
	move.l	#'ERR!',(a5)
	bra.s	.3
	
scan
	lea	-$200(a6),a5
	moveq	#1,d7
.6
	lea	$200(a5),a4
	move.l	a4,a5
	lea	$200(a4),a3
	cmp.l	#'ERR!',(a4)
	beq.s	.7
	movem.w	(a4)+,d0-d3
.1	move.w	(a4)+,d4
	cmp.w	d4,d0
	beq.s	.5
	cmp.w	d4,d1
	beq.s	.5
	cmp.w	d4,d2
	beq.s	.5
	cmp.w	d4,d3
	beq.s	.5
.2
	moveq	#'#',d0
	bra.s	.4
	
.5	cmp.l	a3,a4
	blo.s	.1
.3
	moveq	#'.',d0
.4	bsr	affc
	addq.w	#1,d7
	cmp.w	#NB+1,d7
	bne.s	.6
	rts
.7	moveq	#'E',d0
	bra.s	.4
inp	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
line	lea	lin(pc),a0
aff	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
affc	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	rts
;d0=donnee a afficher
hex
	movem.l	d0-d2/a0,-(sp)
	rol.l	#8,d0
	rol.l	#4,d0
	move.l	d0,d1
	move.w	#4,d2
.1	
	move.l	d1,d0
	rol.l	#4,d1
	swap	d0
	lsr.l	#8,d0
	lsr.l	#4,d0
	andi.l	#$f,d0
	bsr	hexf
	dbf	d2,.1
	movem.l	(sp)+,d0-d2/a0
	rts
hexf
	add.b	#'0',d0
	cmp.b	#'9'+1,d0
	blo	hexf1
	add.b	#'A'-'9'-1,d0
hexf1
	move.b	d0,(a1)+
	rts

savep	dc.l	0
intro	dc.b	27,'E Disk Scanner (c) 1990 YODA',10,13,0
msgr	dc.b	10,13,'Reading track:XX,$XX ,address:$XXXXX  Scan:',0
msgw	dc.b	10,13,'Writing track:XX,$XX ,address:$XXXXX',0
lin	dc.b	10,13,0
ok	dc.b	10,13,' Done. Press a key...',0
err	dc.b	' Error...',0
cont	dc.b	' Continue?(y/n)',0
