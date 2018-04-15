; Rob Northern Depacker v2.0
; --------------------------
;
; A0 = source
; A1 = destination


rob_dpak_v2	movem.l	a0-a6/d0-d7,-(a7)
	bsr	l0043
	moveq	#0,d1
	cmpi.l	#$524e4302,d0
	bne	l0041
	bsr	l0043
	move.l	d0,(a7)
	lea	10(a0),a3
	movea.l	a1,a5
	lea	0(a5,d0.l),a6
	bsr	l0043
	lea	0(a3,d0.l),a4
	clr.w	-(a7)
	cmpa.l	a4,a5
	bcc.s	l0011
	moveq	#0,d0
	move.b	-2(a3),d0
	lea	0(a6,d0.l),a0
	cmpa.l	a4,a0
	bls.s	l0011
	addq.w	#2,a7
	move.l	a4,d0
	btst	#0,d0
	beq.s	l000c
	addq.w	#1,a4
	addq.w	#1,a0
l000c	move.l	a0,d0
	btst	#0,d0
	beq.s	l000d
	addq.w	#1,a0
l000d	moveq	#0,d0
l000e	cmpa.l	a0,a6
	beq.s	l000f
	move.b	-(a0),d1
	move.w	d1,-(a7)
	addq.b	#1,d0
	bra.s	l000e
l000f	move.w	d0,-(a7)
	adda.l	d0,a0
l0010	lea	-32(a4),a4
	movem.l	(a4),d0-d7
	movem.l	d0-d7,-(a0)
	cmpa.l	a3,a4
	bhi.s	l0010
	suba.l	a4,a3
	adda.l	a0,a3
l0011	moveq	#$80,d7
	add.b	d7,d7
	move.b	(a3)+,d7
	addx.b	d7,d7
	add.b	d7,d7
	bra	l002f
l0012	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l001c
l0013	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l001f
l0014	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0020
l0015	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0021
l0016	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0023
l0017	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0024
l0018	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0025
l0019	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0027
l001a	moveq	#3,d5
l001b	add.b	d7,d7
	beq.s	l0012
l001c	addx.w	d6,d6
	dbf	d5,l001b
	addq.w	#2,d6
l001d	move.b	(a3)+,(a5)+
	move.b	(a3)+,(a5)+
	move.b	(a3)+,(a5)+
	move.b	(a3)+,(a5)+
	dbf	d6,l001d
	bra.s	l002f
l001e	add.b	d7,d7
	beq.s	l0013
l001f	addx.w	d5,d5
	add.b	d7,d7
	beq.s	l0014
l0020	bcc.s	l0022
	subq.w	#1,d5
	add.b	d7,d7
	beq.s	l0015
l0021	addx.w	d5,d5
	cmpi.b	#9,d5
	beq.s	l001a
l0022	add.b	d7,d7
	beq.s	l0016
l0023	bcc.s	l0029
	add.b	d7,d7
	beq.s	l0017
l0024	addx.w	d6,d6
	add.b	d7,d7
	beq.s	l0018
l0025	bcs.s	l0035
	tst.w	d6
	bne.s	l0028
	addq.w	#1,d6
l0026	add.b	d7,d7
	beq.s	l0019
l0027	addx.w	d6,d6
l0028	rol.w	#8,d6
l0029	move.b	(a3)+,d6
	movea.l	a5,a0
	suba.w	d6,a0
	subq.w	#1,a0
	lsr.w	#1,d5
	bcc.s	l002a
	move.b	(a0)+,(a5)+
l002a	subq.w	#1,d5
	tst.w	d6
	bne.s	l002c
	move.b	(a0),d6
l002b	move.b	d6,(a5)+
	move.b	d6,(a5)+
	dbf	d5,l002b
	bra.s	l002f
l002c	move.b	(a0)+,(a5)+
	move.b	(a0)+,(a5)+
	dbf	d5,l002c
	bra.s	l002f
l002d	move.b	(a3)+,d7
	addx.b	d7,d7
	bcs.s	l0031
l002e	move.b	(a3)+,(a5)+
l002f	add.b	d7,d7
	bcs.s	l0030
	move.b	(a3)+,(a5)+
	move.b	(a3),$ffff8240.w
	add.b	d7,d7
	bcc.s	l002e
l0030	beq.s	l002d
l0031	moveq	#2,d5
	moveq	#0,d6
	add.b	d7,d7
	beq.s	l0038
l0032	bcc	l001e
	add.b	d7,d7
	beq.s	l0039
l0033	bcc.s	l0029
	addq.w	#1,d5
	add.b	d7,d7
	beq.s	l003a
l0034	bcc	l0022
	move.b	(a3)+,d5
	beq.s	l003d
	addq.w	#8,d5
	bra	l0022
l0035	add.b	d7,d7
	beq.s	l003b
l0036	addx.w	d6,d6
	ori.w	#4,d6
	add.b	d7,d7
	beq.s	l003c
l0037	bcs	l0028
	bra	l0026
l0038	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0032
l0039	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0033
l003a	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0034
l003b	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0036
l003c	move.b	(a3)+,d7
	addx.b	d7,d7
	bra.s	l0037
l003d	add.b	d7,d7
	bne.s	l003e
	move.b	(a3)+,d7
	addx.b	d7,d7
l003e	bcs.s	l002f
	move.w	(a7)+,d0
	beq.s	l0040
l003f	move.w	(a7)+,d1
	move.b	d1,(a5)+
	subq.b	#1,d0
	bne.s	l003f
l0040	bra.s	l0042
l0041	move.l	d1,(a7)
l0042	movem.l	(a7)+,a0-a6/d0-d7
	rts

l0043	moveq	#3,d1
l0044	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l0044
	rts

