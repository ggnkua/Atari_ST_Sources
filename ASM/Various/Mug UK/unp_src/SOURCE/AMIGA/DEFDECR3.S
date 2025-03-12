;-----------------------------------------------------------------------;
;                                                                       ;
;          Defjam v3.6 Decrunch Routine Ripped By Native/EFFECT         ;
;                                                                       ;
;-----------------------------------------------------------------------;
org	$50000
load	$50000
begin:

X40020:	moveq	#$00,d7
	lea	X401ae+$102(pc),a1
	lea	$dff180.l,a5
	move.l	X4017e+2(pc),a4
	move.l	a4,a0
X40032:	add.l	#$00005b10,a0		;PASS 3 LENGTH(Look Up)
	cmp.l	a4,a1
	bgt	X40044
	move.l	a1,a0
	add.l	X40032+2(pc),a0
	bra	X4004a
X40044:	move.b	(a1)+,(a4)+
	cmp.l	a0,a4
	blt	X40044
X4004a:	lea	$0544ff.l,a1		;Look Up
	lea	X401ae+2(pc),a4
	move.l	-(a0),a2
	add.l	a1,a2
	move.l	-(a0),d0
X4005a:	moveq	#$03,d1
	bsr	X40130
	tst.w	d2
	beq	X400ec
	cmp.b	#$0007,d2
	bne	X400ac
	lsr.l	#1,d0
	bne	X40074
	bsr	X40116
X40074:	bcs	X40080
	moveq	#$02,d1
	bsr	X40130
	addq.w	#7,d2
	bra	X400ac
X40080:	moveq	#$08,d1
	bsr	X40130
	tst.w	d2
	beq	X40090
	add.w	#$000a,d2
	bra	X400ac
X40090:	moveq	#$0c,d1
	bsr	X40130
	tst.w	d2
	beq	X400a0
	add.w	#$0109,d2
	bra	X400ac
X400a0:	moveq	#$0f,d1
	bsr	X40130
	add.l	#$0000110b,d2
X400ac:	subq.w	#1,d2
	move.w	d2,d3
X400b0:	lsr.l	#1,d0
	bne	X400b6
	bsr	X40116
X400b6:	bcs	X400be
	moveq	#$08,d5
	moveq	#$06,d1
	bra	X400e0
X400be:	lsr.l	#1,d0
	bne	X400c4
	bsr	X40116
X400c4:	bcs	X400cc
	moveq	#$00,d5
	moveq	#$03,d1
	bra	X400e0
X400cc:	lsr.l	#1,d0
	bne	X400d2
	bsr	X40116
X400d2:	bcs	X400da
	moveq	#$48,d5
	moveq	#$06,d1
	bra	X400e0
X400da:	move.w	#$0088,d5
	moveq	#$07,d1
X400e0:	bsr	X40130
	add.w	d5,d2
	move.b	$00(a4,d2.w),-(a2)
	dbf	d3,X400b0
X400ec:	cmp.l	a2,a1
	bge	X4017c
	lsr.l	#1,d0
	bne	X400f8
	bsr	X40116
X400f8:	bcc	X40150
	moveq	#$02,d1
	bsr	X40130
	moveq	#$0a,d1
	moveq	#$03,d3
	tst.b	d2
	beq	X40162
	cmp.b	d2,d3
	beq	X40142
	cmp.b	#$0001,d2
	beq	X40124
	moveq	#$06,d3
	moveq	#$03,d1
	bra	X40128
X40116:	move.l	-(a0),d0
	move.b	d0,d7
	move.w	d7,(a5)
	move.w	#$0010,CCR
	roxr.l	#1,d0
	rts
X40124:	moveq	#$04,d3
	moveq	#$01,d1
X40128:	bsr	X40130
	add.w	d2,d3
	moveq	#$0a,d1
	bra	X40162
X40130:	subq.w	#1,d1
	moveq	#$00,d2
X40134:	lsr.l	#1,d0
	bne	X4013a
	bsr	X40116
X4013a:	addx.l	d2,d2
	dbf	d1,X40134
	rts
X40142:	moveq	#$08,d1
	bsr	X40130
	move.w	d2,d3
	add.w	#$000e,d3
	moveq	#$0b,d1
	bra	X40162
X40150:	lsr.l	#1,d0
	bne	X40156
	bsr	X40116
X40156:	bcs	X4015e
	moveq	#$02,d3
	moveq	#$09,d1
	bra	X40162
X4015e:	moveq	#$01,d3
	moveq	#$0b,d1
X40162:	bsr	X40130
X40164:	move.b	$ff(a2,d2.w),-(a2)
	dbf	d3,X40164
	cmp.l	a2,a1
	blt	X4005a
	bra	X4017c
X40174:	dc.b " DEFJAM "
X4017c:	moveq	#$3b,d7			;Look up in the crunched File
X4017e:	lea	$030000.l,a0		;Lowest Adres
	lea	$060000.l,a2		;Highest Adres
X4018a:	move.b	(a1)+,d0
	cmp.b	d7,d0
	bne	X401a0
	moveq	#$00,d1
	move.b	(a1)+,d1
	beq	X401a0
	move.b	(a1)+,d0
	addq.w	#1,d1
X4019a:	move.b	d0,(a0)+
	dbf	d1,X4019a
X401a0:	move.w	d0,(a5)
	move.b	d0,(a0)+
	cmp.l	a2,a1
	blt	X4018a
	JMP	$040000.l		;Jump Adres

X401ae:;	Start Crunched File !!!
end:
