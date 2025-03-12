	text
begin
	lea	l00b5,a7
	lea	l00a2,a0
l0000	clr.w	(a0)+
	cmpa.l	#l00b7,a0
	blt.s	l0000
	bsr	l0073
	bsr	l0057
	bsr	l0035
l0001	bsr	l004b
	tst.b	l00a2
	beq.s	l0001
	bsr	l0058
	bsr	l0074
	clr.w	-(a7)
	trap	#1
l0002	clr.b	l00a4
	moveq	#0,d5
	move.w	l00ad,d6
	tst.b	l00a6
	beq.s	l0004
	move.w	l00a8,d5
	move.w	l00a9,d6
	move.w	#0,d0
	move.w	#$b,d1
	bsr	l0045
	lea	l0098,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l0099,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$d,d1
	bsr	l0045
	lea	l009a,a6
	bsr	l0040
l0003	bsr	l0048
	bsr	l0049
	cmp.b	#$79,d0
	beq.s	l0006
	cmp.b	#$59,d0
	beq.s	l0006
	cmp.b	#$6e,d0
	beq	l0008
	cmp.b	#$4e,d0
	beq	l0008
	bra.s	l0003
l0004	move.w	#0,d0
	move.w	#$b,d1
	bsr	l0045
	lea	l009b,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l009c,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$d,d1
	bsr	l0045
	lea	l009d,a6
	bsr	l0040
l0005	bsr	l0048
	bsr	l0049
	cmp.b	#$79,d0
	beq.s	l0006
	cmp.b	#$59,d0
	beq.s	l0006
	cmp.b	#$6e,d0
	beq.s	l0008
	cmp.b	#$4e,d0
	beq.s	l0008
	bra.s	l0005
l0006	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l009e,a6
	bsr	l0040
	lea	l00b6,a4
l0007	bsr.s	l0009
	addq.w	#1,d5
	cmp.w	d6,d5
	ble.s	l0007
l0008	bsr	l0035
	rts

l0009	move.w	d5,d0
	lsl.w	#2,d0
	movea.l	0(a4,d0.w),a6
	move.l	a6,d0
	beq.s	l000c
l000a	moveq	#0,d0
	move.b	(a6)+,d0
	beq.s	l000b
	bsr.s	l000d
	bra.s	l000a
l000b	moveq	#$d,d0
	bsr.s	l000d
	moveq	#$a,d0
	bsr.s	l000d
l000c	rts

l000d	move.w	d0,-(a7)
	move.w	#0,-(a7)
	move.w	#3,-(a7)
	trap	#$d
	addq.w	#6,a7
	rts

l000e	move.w	#0,d0
	move.w	#$b,d1
	bsr	l0045
	lea	l0094,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l0095,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$d,d1
	bsr	l0045
	lea	l0096,a6
	bsr	l0040
	bsr.s	l0011
	tst.b	l00b0
	beq.s	l0010
	bsr	l0018
	tst.b	l00a7
	bne.s	l000f
	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l0097,a6
	bsr	l0040
	bsr	l0046
	bsr	l0048
l000f	bsr	l0035
	rts

l0010	bsr	l0035
	rts

l0011	clr.b	l00a4
	lea	l00b0,a6
	moveq	#0,d7
	move.w	#9,d0
	move.w	#$c,d1
	bsr	l0045
	movea.l	a6,a5
l0012	move.b	(a5)+,d0
	beq.s	l0013
	bsr	l0043
	addq.w	#1,d7
	bra.s	l0012
l0013	move.w	d7,d0
	addi.w	#9,d0
	move.w	d0,d0
	move.w	#$c,d1
	bsr	l0045
	move.w	#$ae,d0
	bsr	l0043
	move.w	d7,d0
	addi.w	#9,d0
	move.w	d0,d0
	move.w	#$c,d1
	bsr	l0045
l0014	bsr	l0048
	bsr	l0049
	cmp.b	#$d,d0
	beq.s	l0017
	cmp.b	#$7f,d0
	beq.s	l0016
	cmp.b	#$20,d0
	blt.s	l0014
	cmp.b	#$7e,d0
	bgt.s	l0014
	cmp.w	#$45,d7
	bge.s	l0015
	move.b	d0,0(a6,d7.w)
	bsr	l0043
	addq.w	#1,d7
	bra.s	l0013
l0015	bsr	l0046
	bra.s	l0014
l0016	tst.w	d7
	beq.s	l0014
	move.w	d7,d0
	addi.w	#9,d0
	move.w	d0,d0
	move.w	#$c,d1
	bsr	l0045
	moveq	#$20,d0
	bsr	l0043
	subq.w	#1,d7
	bra.s	l0013
l0017	move.w	d7,d0
	addi.w	#9,d0
	move.w	d0,d0
	move.w	#$c,d1
	bsr	l0045
	moveq	#$20,d0
	bsr	l0043
	clr.b	0(a6,d7.w)
	rts

l0018	clr.b	l00a7
	lea	l00b6,a4
	move.w	l00af,d6
l0019	move.w	d6,d0
	lsl.w	#2,d0
	movea.l	0(a4,d0.w),a6
	move.l	a6,d0
	beq.s	l001e
	movea.l	a6,a3
l001a	lea	l00b0,a5
	movea.l	a3,a6
l001b	move.b	(a5)+,d1
	beq.s	l001d
	move.b	(a6)+,d0
	beq.s	l001f
	cmp.b	d1,d0
	beq.s	l001b
	cmp.b	#$61,d1
	blt.s	l001c
	cmp.b	#$7a,d1
	bgt.s	l001c
	subi.b	#$20,d1
	cmp.b	d1,d0
	beq.s	l001b
l001c	addq.w	#1,a3
	bra.s	l001a
l001d	st	l00a7
	move.w	d6,l00af
l001e	rts

l001f	addq.w	#1,d6
	bra.s	l0019
l0020	move.w	l00a8,d0
	cmp.w	l00a9,d0
	bgt.s	l0021
	st	l00a6
	bra	l0035
l0021	clr.b	l00a6
	bra	l0035
l0022	clr.w	l00a8
	move.w	#-1,l00a9
	clr.b	l00a6
	bra	l0035
l0023	move.w	l00af,l00a8
	bra.s	l0020
l0024	move.w	l00af,l00a9
	bra.s	l0020
l0025	tst.w	l00af
	beq.s	l0026
	clr.w	l00af
	bsr	l0035
l0026	rts

l0027	move.w	l00af,d0
	cmp.w	l00ad,d0
	bge.s	l0028
	move.w	l00ad,l00af
	bsr	l0035
l0028	rts

l0029	tst.w	l00af
	beq.s	l002c
	moveq	#$16,d0
l002a	tst.w	l00af
	beq.s	l002b
	subq.w	#1,l00af
	dbf	d0,l002a
l002b	bsr	l0035
l002c	rts

l002d	move.w	l00af,d0
	cmp.w	l00ad,d0
	bge.s	l0030
	moveq	#$16,d1
l002e	move.w	l00af,d0
	cmp.w	l00ad,d0
	bge.s	l002f
	addq.w	#1,l00af
	dbf	d1,l002e
l002f	bsr.s	l0035
l0030	rts

l0031	tst.w	l00af
	beq.s	l0032
	subq.w	#1,l00af
	bsr	l0055
	move.w	#0,d0
	move.w	#1,d1
	bsr	l0045
	move.w	l00af,l00ae
	bsr.s	l0037
l0032	rts

l0033	move.w	l00af,d0
	cmp.w	l00ad,d0
	bge.s	l0034
	addq.w	#1,l00af
	bsr	l0053
	move.w	#0,d0
	move.w	#$17,d1
	bsr	l0045
	move.w	l00af,d0
	addi.w	#$16,d0
	move.w	d0,l00ae
	bsr.s	l0037
l0034	rts

l0035	move.w	l00af,l00ae
	moveq	#1,d7
l0036	move.w	#0,d0
	move.w	d7,d1
	bsr	l0045
	bsr.s	l0037
	addq.w	#1,l00ae
	addq.w	#1,d7
	cmp.w	#$18,d7
	blt.s	l0036
	rts

l0037	clr.b	l00a5
	move.w	l00ae,d0
	tst.b	l00a6
	beq.s	l0038
	cmp.w	l00a8,d0
	blt.s	l0038
	cmp.w	l00a9,d0
	bgt.s	l0038
	st	l00a5
l0038	lsl.w	#2,d0
	lea	l00b6,a6
	movea.l	0(a6,d0.w),a6
	move.l	a6,d0
	beq.s	l003a
l0039	move.b	(a6)+,d0
	beq.s	l003a
	bsr.s	l003c
	bra.s	l0039
l003a	cmpi.w	#$50,l00aa
	bge.s	l003b
	moveq	#$20,d0
	bsr.s	l003c
	bra.s	l003a
l003b	rts

l003c	andi.w	#$ff,d0
	lsl.w	#3,d0
	lea	l0078,a0
	adda.w	d0,a0
	movea.l	l00ac,a1
	moveq	#0,d0
	tst.b	l00a5
	bne.s	l003f
	move.b	(a0)+,d0
	movep.w	d0,0(a1)
	move.b	(a0)+,d0
	movep.w	d0,160(a1)
	move.b	(a0)+,d0
	movep.w	d0,320(a1)
	move.b	(a0)+,d0
	movep.w	d0,480(a1)
	move.b	(a0)+,d0
	movep.w	d0,640(a1)
	move.b	(a0)+,d0
	movep.w	d0,800(a1)
	move.b	(a0)+,d0
	movep.w	d0,960(a1)
	move.b	(a0)+,d0
	movep.w	d0,1120(a1)
l003d	addq.w	#1,a1
	move.w	a1,d0
	andi.w	#1,d0
	bne.s	l003e
	addq.w	#2,a1
l003e	move.l	a1,l00ac
	addq.w	#1,l00aa
	rts

l003f	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,0(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,160(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,320(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,480(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,640(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,800(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,960(a1)
	move.b	(a0)+,d0
	not.b	d0
	movep.w	d0,1120(a1)
	bra.s	l003d
l0040	move.b	(a6)+,d0
	beq.s	l0041
	bsr.s	l0043
	bra.s	l0040
l0041	cmpi.w	#$50,l00aa
	bge.s	l0042
	moveq	#$20,d0
	bsr.s	l0043
	bra.s	l0041
l0042	rts

l0043	andi.w	#$ff,d0
	lsl.w	#3,d0
	lea	l0078,a0
	adda.w	d0,a0
	movea.l	l00ac,a1
	moveq	#-1,d0
	move.b	(a0)+,d0
	movep.w	d0,0(a1)
	move.b	(a0)+,d0
	movep.w	d0,160(a1)
	move.b	(a0)+,d0
	movep.w	d0,320(a1)
	move.b	(a0)+,d0
	movep.w	d0,480(a1)
	move.b	(a0)+,d0
	movep.w	d0,640(a1)
	move.b	(a0)+,d0
	movep.w	d0,800(a1)
	move.b	(a0)+,d0
	movep.w	d0,960(a1)
	move.b	(a0)+,d0
	movep.w	d0,1120(a1)
	addq.w	#1,a1
	move.w	a1,d0
	andi.w	#1,d0
	bne.s	l0044
	addq.w	#2,a1
l0044	move.l	a1,l00ac
	addq.w	#1,l00aa
	rts

l0045	move.w	d0,l00aa
	move.w	d1,l00ab
	movea.l	$44e,a0
	mulu	#$500,d1
	adda.w	d1,a0
	move.w	d0,d1
	andi.w	#-2,d1
	add.w	d1,d1
	adda.w	d1,a0
	andi.w	#1,d0
	adda.w	d0,a0
	move.l	a0,l00ac
	rts

l0046	move.w	#7,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.w	#4,a7
	rts

l0047	st	l00a2
	rts

l0048	btst	#7,l00a4
	bne.s	l0048
	bset	#7,l00a4
	rts

l0049	move.b	l00a4,d0
	andi.w	#$7f,d0
	move.b	l00a3,d1
	andi.b	#3,d1
	beq.s	l004a
	ori.b	#-$80,d0
l004a	lea	l009f,a0
	move.b	0(a0,d0.w),d0
	rts

l004b	move.b	l00a3,d0
	andi.w	#$f,d0
	lsl.w	#8,d0
	move.b	l00a4,d0
	bmi.s	l004d
	lea	l00a0,a0
l004c	move.w	(a0)+,d1
	beq.s	l004d
	movea.l	(a0)+,a1
	cmp.w	d1,d0
	bne.s	l004c
	jmp	(a1)
l004d	rts

l004e	lea	l00a1,a0
	lea	l00b6,a1
	clr.w	l00ad
l004f	move.l	a0,(a1)+
	addq.w	#1,l00ad
l0050	move.b	(a0)+,d0
	beq.s	l0052
	cmp.b	#$d,d0
	bne.s	l0050
	clr.b	-1(a0)
	cmpi.b	#$a,(a0)
	bne.s	l0051
	addq.w	#1,a0
l0051	bra.s	l004f
l0052	rts

l0053	movea.l	$44e,a0
	lea	1280(a0),a0
	lea	1280(a0),a1
	moveq	#$15,d0
l0054	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,48(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,96(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,144(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,192(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,240(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,288(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,336(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,384(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,432(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,480(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,528(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,576(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,624(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,672(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,720(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,768(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,816(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,864(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,912(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,960(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1008(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1056(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1104(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1152(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1200(a0)
	movem.l	(a1)+,a2/d1-d7
	movem.l	a2/d1-d7,1248(a0)
	lea	1280(a0),a0
	dbf	d0,l0054
	rts

l0055	movea.l	$44e,a0
	lea	28160(a0),a0
	lea	1280(a0),a1
	moveq	#$15,d0
l0056	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,48(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,96(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,144(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,192(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,240(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,288(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,336(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,384(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,432(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,480(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,528(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,576(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,624(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,672(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,720(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,768(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,816(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,864(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,912(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,960(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1008(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1056(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1104(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1152(a1)
	movem.l	(a0)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,1200(a1)
	movem.l	(a0)+,a2/d1-d7
	movem.l	a2/d1-d7,1248(a1)
	lea	-2560(a0),a0
	lea	-1280(a1),a1
	dbf	d0,l0056
	rts

l0057	bsr	l0071
	bsr	l006e
	bsr	l006f
	bsr	l0067
	bsr	l0069
	bsr	l005b
	move.l	$44e,l00ac
	bsr.s	l0059
	bsr	l004e
	bsr	l0022
	rts

l0058	bsr	l005c
	bsr	l006b
	bsr	l0070
	bsr	l0072
	rts

l0059	move.w	#0,d0
	move.w	#0,d1
	bsr	l0045
	lea	l0079,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$18,d1
	bsr	l0045
	lea	l007a,a6
	bsr	l0040
	rts

l005a	bsr	l0048
	move.w	#0,d0
	move.w	#0,d1
	bsr	l0045
	lea	l007b,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#1,d1
	bsr	l0045
	lea	l007c,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#2,d1
	bsr	l0045
	lea	l007d,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#3,d1
	bsr	l0045
	lea	l007e,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#4,d1
	bsr	l0045
	lea	l007f,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#5,d1
	bsr	l0045
	lea	l0080,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#6,d1
	bsr	l0045
	lea	l0081,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#7,d1
	bsr	l0045
	lea	l0082,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#8,d1
	bsr	l0045
	lea	l0083,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#9,d1
	bsr	l0045
	lea	l0084,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$a,d1
	bsr	l0045
	lea	l0085,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$b,d1
	bsr	l0045
	lea	l0086,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$c,d1
	bsr	l0045
	lea	l0087,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$d,d1
	bsr	l0045
	lea	l0088,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$e,d1
	bsr	l0045
	lea	l0089,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$f,d1
	bsr	l0045
	lea	l008a,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$10,d1
	bsr	l0045
	lea	l008b,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$11,d1
	bsr	l0045
	lea	l008c,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$12,d1
	bsr	l0045
	lea	l008d,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$13,d1
	bsr	l0045
	lea	l008e,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$14,d1
	bsr	l0045
	lea	l008f,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$15,d1
	bsr	l0045
	lea	l0090,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$16,d1
	bsr	l0045
	lea	l0091,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$17,d1
	bsr	l0045
	lea	l0092,a6
	bsr	l0040
	move.w	#0,d0
	move.w	#$18,d1
	bsr	l0045
	lea	l0093,a6
	bsr	l0040
	bsr	l0048
	bsr	l0059
	bsr	l0035
	rts

l005b	move.l	$118,l00b1
	move.l	#l005d,$118
	rts

l005c	move.l	l00b1,$118
	rts

l005d	move.l	d0,-(a7)
l005e	move.b	-$3fe,d0
	cmp.b	#$2a,d0
	bne.s	l005f
	ori.b	#1,l00a3
l005f	cmp.b	#-$56,d0
	bne.s	l0060
	andi.b	#-2,l00a3
l0060	cmp.b	#$36,d0
	bne.s	l0061
	ori.b	#2,l00a3
l0061	cmp.b	#-$4a,d0
	bne.s	l0062
	andi.b	#-3,l00a3
l0062	cmp.b	#$1d,d0
	bne.s	l0063
	ori.b	#4,l00a3
l0063	cmp.b	#-$63,d0
	bne.s	l0064
	andi.b	#-5,l00a3
l0064	cmp.b	#$38,d0
	bne.s	l0065
	ori.b	#8,l00a3
l0065	cmp.b	#-$48,d0
	bne.s	l0066
	andi.b	#-9,l00a3
l0066	move.b	d0,l00a4
	btst	#4,-$5ff
	beq	l005e
	bclr	#6,-$5ef
	move.l	(a7)+,d0
	rte

l0067	lea	-$7dc0,a0
	lea	l00b3,a1
	moveq	#3,d0
l0068	move.w	(a0)+,(a1)+
	dbf	d0,l0068
	rts

l0069	lea	l0077,a0
	lea	-$7dc0,a1
	moveq	#3,d0
l006a	move.w	(a0)+,(a1)+
	dbf	d0,l006a
	rts

l006b	lea	l00b3,a0
	lea	-$7dc0,a1
	moveq	#3,d0
l006c	move.w	(a0)+,(a1)+
	dbf	d0,l006c
	rts

l006d	move.w	#$25,-(a7)
	trap	#$e
	addq.w	#2,a7
	rts

l006e	move.w	#4,-(a7)
	trap	#$e
	addq.w	#2,a7
	move.w	d0,l00b2
	rts

l006f	bsr.s	l006d
	move.w	#1,-(a7)
	move.l	$44e,-(a7)
	move.l	$44e,-(a7)
	move.w	#5,-(a7)
	trap	#$e
	adda.w	#$c,a7
	rts

l0070	bsr.s	l006d
	move.w	l00b2,-(a7)
	move.l	$44e,-(a7)
	move.l	$44e,-(a7)
	move.w	#5,-(a7)
	trap	#$e
	adda.w	#$c,a7
	rts

l0071	pea	l0075
	move.w	#1,-(a7)
	move.w	#$19,-(a7)
	trap	#$e
	addq.w	#8,a7
	rts

l0072	pea	l0076
	move.w	#1,-(a7)
	move.w	#$19,-(a7)
	trap	#$e
	addq.w	#8,a7
	rts

l0073	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l	d0,l00b4
	rts

l0074	move.l	l00b4,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

	data
	dc.b	'p',0,'B',$b8,4,$da,'Nu'
l0075	dc.b	$12,$1a
l0076	dc.b	$14,8
******
l0077	dc.b	6,$67,0,0,0,0,7,$75	!colours	here!
l0078	ds.w	132
	dc.b	$18,$18,$18,$18,$18,0,$18,0
	dc.b	'fff',0,0,0,0,0
	dc.b	0,'l',$fe,'ll',$fe,'l',0
	dc.b	$18,'>`<',6,'|',$18,0
	dc.b	0,'fl',$18,'0fF',0
	dc.b	'8l8p',$de,$cc,'v',0
	dc.b	$18,$18,$18,0,0,0,0,0
	dc.b	$e,$1c,$18,$18,$18,$1c,$e,0
	dc.b	'p8',$18,$18,$18,'8p',0
	dc.b	0,'f<',$ff,'<f',0,0
	dc.b	0,$18,$18,'~',$18,$18,0,0
	ds.w	2
	dc.b	0,'00`',0,0,0,'~'
	ds.w	4
	dc.b	0,$18,$18,0,2,6,$c,$18
	dc.b	'0`@',0,'<fnv'
	dc.b	'ff<',0,$18,'8',$18,$18
	dc.b	$18,$18,'~',0,'<f',6,$c
	dc.b	$18,'0~',0,'~',$c,$18,$c
	dc.b	6,'f<',0,$c,$1c,'<l'
	dc.b	'~',$c,$c,0,'~`|',6
	dc.b	6,'f<',0,'<``|'
	dc.b	'ff<',0,'~',6,$c,$18
	dc.b	'000',0,'<ff<'
	dc.b	'ff<',0,'<ff>'
	dc.b	6,$c,'8',0,0,$18,$18,0
	dc.b	$18,$18,0,0,0,$18,$18,0
	dc.b	$18,$18,'0',0,6,$c,$18,'0'
	dc.b	$18,$c,6,0,0,0,'~',0
	dc.b	0,'~',0,0,'`0',$18,$c
	dc.b	$18,'0`',0,'<f',6,$c
	dc.b	$18,0,$18,0,'<fnj'
	dc.b	'n`>',0,$18,'<ff'
	dc.b	'~ff',0,'|ff|'
	dc.b	'ff|',0,'<f``'
	dc.b	'`f<',0,'xlff'
	dc.b	'flx',0,'~``|'
	dc.b	'``~',0,'~``|'
	dc.b	'```',0,'>``n'
	dc.b	'ff>',0,'fff~'
	dc.b	'fff',0,'<',$18,$18,$18
	dc.b	$18,$18,'<',0,6,6,6,6
	dc.b	6,'f<',0,'flxp'
	dc.b	'xlf',0,'````'
	dc.b	'``~',0,$c6,$ee,$fe,$d6
	dc.b	$c6,$c6,$c6,0,'fv~~'
	dc.b	'nff',0,'<fff'
	dc.b	'ff<',0,'|ff|'
	dc.b	'```',0,'<fff'
	dc.b	'vl6',0,'|ff|'
	dc.b	'lff',0,'<f`<'
	dc.b	6,'f<',0,'~',$18,$18,$18
	dc.b	$18,$18,$18,0,'ffff'
	dc.b	'ff>',0,'ffff'
	dc.b	'f<',$18,0,$c6,$c6,$c6,$d6
	dc.b	$fe,$ee,$c6,0,'ff<',$18
	dc.b	'<ff',0,'fff<'
	dc.b	$18,$18,$18,0,'~',6,$c,$18
	dc.b	'0`~',0,$1e,$18,$18,$18
	dc.b	$18,$18,$1e,0,'@`0',$18
	dc.b	$c,6,2,0,'x',$18,$18,$18
	dc.b	$18,$18,'x',0,$10,'8l',$c6
	ds.w	5
	dc.b	$fe,0,$1c,'60|00'
	dc.b	'~',0,0,0,'<',6,'>f'
	dc.b	'>',0,'``|fff'
	dc.b	'|',0,0,0,'<```'
	dc.b	'<',0,6,6,'>fff'
	dc.b	'>',0,0,0,'<f~`'
	dc.b	'<',0,$1c,'0|000'
	dc.b	'0',0,0,0,'>ff>'
	dc.b	6,'|``|fff'
	dc.b	'f',0,$18,0,'8',$18,$18,$18
	dc.b	'<',0,$18,0,$18,$18,$18,$18
	dc.b	$18,'p``flxl'
	dc.b	'f',0,'8',$18,$18,$18,$18,$18
	dc.b	'<',0,0,0,$ec,$fe,$d6,$c6
	dc.b	$c6,0,0,0,'|fff'
	dc.b	'f',0,0,0,'<fff'
	dc.b	'<',0,0,0,'|fff'
	dc.b	'|`',0,0,'>fff'
	dc.b	'>',6,0,0,'|f``'
	dc.b	'`',0,0,0,'>`<',6
	dc.b	'|',0,0,$18,'~',$18,$18,$18
	dc.b	$e,0,0,0,'ffff'
	dc.b	'>',0,0,0,'fff<'
	dc.b	$18,0,0,0,$c6,$c6,$d6,'|'
	dc.b	'l',0,0,0,'f<',$18,'<'
	dc.b	'f',0,0,0,'fff>'
	dc.b	6,'|',0,0,'~',$c,$18,'0'
	dc.b	'~',0,$e,$18,$18,'0',$18,$18
	dc.b	$e,0,$18,$18,$18,$18,$18,$18
	dc.b	$18,$18,'p',$18,$18,$c,$18,$18
	dc.b	'p',0,0,'`',$f2,$9e,$c,0
	ds.w	1
	dc.b	0,$18,$18,'44b~',0
	dc.b	0,'<f`f<',8,'8'
	dc.b	'f',0,0,'fff>',0
	dc.b	$c,$18,0,'<~`<',0
	dc.b	$18,'f',0,'<',6,'~>',0
	dc.b	'f',0,'<',6,'>f>',0
	dc.b	'0',$18,0,'<',6,'~>',0
	dc.b	$18,$18,0,'<',6,'~>',0
	ds.w	1
	dc.b	'<``<',8,$18,$18,'f'
	dc.b	0,'<~`<',0,'f',0
	dc.b	'<f~`<',0,'0',$18
	dc.b	0,'<~`<',0,'f',0
	dc.b	0,'8',$18,$18,'<',0,$18,'f'
	dc.b	0,'8',$18,$18,'<',0,'`0'
	dc.b	0,'8',$18,$18,'<',0,'f',0
	dc.b	$18,'<f~f',0,$18,0
	dc.b	$18,'<f~f',0,$c,$18
	dc.b	'~`|`~',0,0,0
	dc.b	'~',$1b,'',$d8,'~',0,'?x'
	dc.b	$d8,$de,$f8,$d8,$df,0,$18,'f'
	dc.b	0,'<ff<',0,'f',0
	dc.b	0,'<ff<',0,'0',$18
	dc.b	0,'<ff<',0,$18,'f'
	dc.b	0,'fff>',0,'0',$18
	dc.b	0,'fff>',0,'f',0
	dc.b	'fff>',6,'|f',0
	dc.b	'<fff<',0,'f',0
	dc.b	'ffff>',0,$18,$18
	dc.b	'<``<',$18,$18,$1c,':'
	dc.b	'0|00~',0,'ff'
	dc.b	'<',$18,'<',$18,$18,0,$1c,'6'
	dc.b	'f|ff|`',$1e,'0'
	dc.b	'|000`',0,$c,$18
	dc.b	0,'<',6,'~>',0,$c,$18
	dc.b	0,'8',$18,$18,'<',0,$c,$18
	dc.b	0,'<ff<',0,$c,$18
	dc.b	0,'fff>',0,'4X'
	dc.b	0,'|fff',0,'4X'
	dc.b	0,'fvnf',0,0,'<'
	dc.b	6,'>f>',0,'<',0,'<'
	dc.b	'fff<',0,'<',0,$18
	dc.b	0,$18,'0`f<',0,0
	dc.b	0,'>000',0,0,0
	dc.b	0,'|',$c,$c,$c,0,$c6,$cc
	dc.b	$d8,'6k',$c3,$86,$f,$c6,$cc
	dc.b	$d8,'6n',$d6,$9f,6,0,$18
	dc.b	0,$18,$18,$18,$18,$18,$1b,'6'
	dc.b	'l',$d8,'l6',$1b,0,$d8,'l'
	dc.b	'6',$1b,'6l',$d8,0,'4X'
	dc.b	0,'<',6,'~>',0,'4X'
	dc.b	0,'<ff<',0,2,'<'
	dc.b	'fnvf<@',0,2
	dc.b	'<nvf<@',0,0
	dc.b	'~',$db,$df,$d8,'~',0,'',$d8
	dc.b	$d8,$de,$d8,$d8,'',0,'0',$18
	dc.b	0,$18,'<f~f4X'
	dc.b	0,$18,'<f~f4X'
	dc.b	'<ffff<f',0
	ds.w	3
	dc.b	$c,$18,'0',0,0,0,0,0
	dc.b	0,$10,'8',$10,$10,$10,0,0
	dc.b	'z',$ca,$ca,$ca,'z',$a,$a,$a
	dc.b	'~',$c3,$bd,$b1,$b1,$bd,$c3,'~'
	dc.b	'~',$c3,$bd,$a5,$b9,$ad,$c3,'~'
	dc.b	$f1,'[_UQ',0,0,0
	dc.b	'f',0,$e6,'ff',$f6,6,$1c
	dc.b	$f6,'ffff',$f6,6,$1c
	dc.b	0,'fv<nf',0,0
	dc.b	0,'|',$c,$c,$c,'~',0,0
	dc.b	0,$1e,6,$e,$1e,'6',0,0
	dc.b	0,'~',$c,$c,$c,$c,0,0
	dc.b	0,'|',6,'fff',0,0
	dc.b	0,$1c,$c,$c,$c,$c,0,0
	dc.b	0,$1e,$c,6,6,6,0,0
	dc.b	0,'~6666',0,0
	dc.b	'`nfff~',0,0
	dc.b	0,'<',$c,$c,0,0,0,0
	dc.b	0,'>',6,6,6,'>',0,0
	dc.b	'`~',6,6,6,$e,0,0
	dc.b	0,'l>ffn',0,0
	dc.b	0,$1c,$c,$c,$c,'<',0,0
	dc.b	0,'>666',$1c,0,0
	dc.b	0,'6666~',0,0
	dc.b	0,'~fv',6,'~',0,0
	dc.b	0,'ff<',$e,'~',0,0
	dc.b	0,'>',6,'6640',0
	dc.b	0,'x',$c,$c,$c,$c,0,0
	dc.b	0,$d6,$d6,$d6,$d6,$fe,0,0
	dc.b	0,'|lll',$ec,0,0
	dc.b	0,$1c,$c,$c,$c,$c,$c,0
	dc.b	0,'>',6,6,6,6,6,0
	dc.b	0,$fe,'fff~',0,0
	dc.b	0,'~fv',6,6,6,0
	dc.b	0,'66',$1c,$c,$c,$c,0
	dc.b	$e,$1b,'<ff<',$d8,'p'
	dc.b	0,$10,'8l',$c6,$82,0,0
	dc.b	'f',$f7,$99,$99,$ef,'f',0,0
	ds.w	1
	dc.b	'v',$dc,$c8,$dc,'v',0,$1c,'6'
	dc.b	'f|ff|`',0,$fe
	dc.b	'fb```',$f8,0,0
	dc.b	$fe,'llllH',$fe,'f'
	dc.b	'0',$18,'0f',$fe,0,0,$1e
	dc.b	'8lll8',0,0,0
	dc.b	'llll',$c0,0,0
	dc.b	'~',$18,$18,$18,$18,$10,'<',$18
	dc.b	'<ff<',$18,'<',0,'<'
	dc.b	'f~ff<',0,0,'<'
	dc.b	'fff$f',0,$1c,'6'
	dc.b	'x',$dc,$cc,$ec,'x',0,$c,$18
	dc.b	'8TT80`',0,$10
	dc.b	'|',$d6,$d6,$d6,'|',$10,'>p'
	dc.b	'`~`p>',0,'<f'
	dc.b	'fffff',0,0,'~'
	dc.b	0,'~',0,'~',0,0,$18,$18
	dc.b	'~',$18,$18,0,'~',0,'0',$18
	dc.b	$c,$18,'0',0,'~',0,$c,$18
	dc.b	'0',$18,$c,0,'~',0,0,$e
	dc.b	$1b,$1b,$18,$18,$18,$18,$18,$18
	dc.b	$18,$18,$d8,$d8,'p',0,$18,$18
	dc.b	0,'~',0,$18,$18,0,0,'2'
	dc.b	'L',0,'2L',0,0,'8l'
	dc.b	'8',0,0,0,0,0,'8|'
	dc.b	'8',0,0,0,0,0,0,0
	ds.w	1
	dc.b	$18,$18,0,0,0,0,$f,$18
	dc.b	$d8,'p0',0,'8lll'
	dc.b	'l',0,0,0,'8l',$18,'0'
	dc.b	'|',0,0,0,'x',$c,'8',$c
	dc.b	'x',0,0,0,0,$fe,0,0
	ds.w	2
l0079		dc.b	'0123465789012345678901234567890123456789'
	dc.b	'0123456789012345678901234567890123456789',0
l007a	dc.b	'      Us'
	dc.b	'e Cursor'
	dc.b	' Keys To'
	dc.b	' Scroll '
	dc.b	'Up and D'
	dc.b	'own. Pre'
	dc.b	'ss HELP '
	dc.b	'For More'
	dc.b	' Options'
	dc.b	'.',0
l007b	ds.w	1
l007c	ds.w	1
l007d	ds.w	1
l007e	dc.b	'        '
	dc.b	'        '
	dc.b	'               HEL'
	dc.b	'P SCREEN'
	ds.w	1
l007f	ds.w	1
l0080	dc.b	'        '
	dc.b	'        '
	dc.b	' CODI'
	dc.b	'NG BY:- '
	dc.b	' BORIS A'
	dc.b	'ND MOOKI'
	dc.b	'E  ',$bd,' 199'
	dc.b	'2 (ADR)',0
l0081	ds.w	1
l0082	dc.b	'        '
	dc.b	'        '
	dc.b	' UP ARRO'
	dc.b	'W       '
	dc.b	'    - MO'
	dc.b	'VE UP A '
	dc.b	'LINE',0,0
l0083	dc.b	'        '
	dc.b	'        '
	dc.b	' DOWN AR'
	dc.b	'ROW     '
	dc.b	'    - MO'
	dc.b	'VE DOWN '
	dc.b	'A LINE',0,0
l0084	dc.b	'        '
	dc.b	'        '
	dc.b	' SHIFT +'
	dc.b	' UP ARRO'
	dc.b	'W   - UP'
	dc.b	' ONE PAG'
	dc.b	'E',0
l0085	dc.b	'        '
	dc.b	'        '
	dc.b	' SHIFT +'
	dc.b	' DOWN AR'
	dc.b	'ROW - DO'
	dc.b	'WN ONE P'
	dc.b	'AGE',0
l0086	dc.b	'        '
	dc.b	'        '
	dc.b	' CTRL + '
	dc.b	'UP ARROW'
	dc.b	'    - TO'
	dc.b	'P OF TEX'
	dc.b	'T',0
l0087	dc.b	'        '
	dc.b	'        '
	dc.b	' CTRL + '
	dc.b	'DOWN ARR'
	dc.b	'OW  - BO'
	dc.b	'TTOM OF '
	dc.b	'TEXT',0,0
l0088	dc.b	'        '
	dc.b	'        '
	dc.b	' F1     '
	dc.b	'        '
	dc.b	'    - ST'
	dc.b	'ART OF B'
	dc.b	'LOCK',0,0
l0089	dc.b	'        '
	dc.b	'        '
	dc.b	' F2     '
	dc.b	'        '
	dc.b	'    - EN'
	dc.b	'D OF BLO'
	dc.b	'CK',0,0
l008a	dc.b	'        '
	dc.b	'        '
	dc.b	' F3     '
	dc.b	'        '
	dc.b	'    - CA'
	dc.b	'NCEL BLO'
	dc.b	'CK',0,0
l008b	dc.b	'        '
	dc.b	'        '
	dc.b	' ALT + F'
	dc.b	'        '
	dc.b	'    - FI'
	dc.b	'ND A WOR'
	dc.b	'D',0
l008c	dc.b	'        '
	dc.b	'        '
	dc.b	' ALT + P'
	dc.b	'        '
	dc.b	'    - PR'
	dc.b	'INT',0
l008d	dc.b	'        '
	dc.b	'        '
	dc.b	' HELP   '
	dc.b	'        '
	dc.b	'    - TH'
	dc.b	'IS HELP '
	dc.b	'SCREEN',0,0
l008e	dc.b	'        '
	dc.b	'        '
	dc.b	' ESC    '
	dc.b	'        '
	dc.b	'    - QU'
	dc.b	'IT THE D'
	dc.b	'OC DISPL'
	dc.b	'AYER',0,0
l008f	ds.w	1
l0090	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'   PRESS'
	dc.b	' A KEY T'
	dc.b	'O EXIT !'
	dc.b	'!',0
l0091	ds.w	1
l0092	ds.w	1
l0093	ds.w	1
l0094	dc.b	0
l0095	dc.b	'  Find ?'
l0096	dc.b	0
l0097	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'  Not fo'
	dc.b	'und!',0,0
l0098	dc.b	0
l0099	dc.b	'         '
	dc.b	'        '
	dc.b	'     Out'
	dc.b	'put bloc'
	dc.b	'k to par'
	dc.b	'allel pr'
	dc.b	'inter?'
l009a	ds.w	1
l009b	dc.b	0
l009c	dc.b	'         '
	dc.b	'        '
	dc.b	'      Ou'
	dc.b	'tput all'
	dc.b	' to para'
	dc.b	'llel pri'
	dc.b	'nter?'
l009d	dc.b	0
l009e	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'  Printi'
	dc.b	'ng...',0
l009f	dc.b	0,$1b,'123456'
	dc.b	'7890-=',9
	dc.b	'qwertyui'
	dc.b	'op[]',$d,0,'as'
	dc.b	'dfghjkl;'
	dc.b	$27,'`',0,'#zxcv'
	dc.b	'bnm,./',0,0
	dc.b	0,' ',0,0,0,0,0,0
	ds.w	5
	dc.b	'-',0,0,0,'+',0,0,0
	ds.w	7
	dc.b	'\',0,0,'()/*7'
	dc.b	'89456123'
	dc.b	'0.',$d,0,0,0,0,0
	ds.w	4
	dc.b	0,$1b,'!"',$9c,'$%^'
	dc.b	'&*()_+',9
	dc.b	'QWERTYUI'
	dc.b	'OP{}',$d,0,'AS'
	dc.b	'DFGHJKL:'
	dc.b	'@_',0,'~ZXCV'
	dc.b	'BNM<>?',0,0
	dc.b	0,' ',0,0,0,0,0,0
	ds.w	5
	dc.b	'-',0,0,0,'+',0,0,0
	ds.w	7
	dc.b	'|',0,0,'()/*7'
	dc.b	'89456123'
	dc.b	'0.',$d,0,0,0,0,0
	ds.w	4
l00a0	dc.b	4,'H'
	dc.l	l0025
	dc.b	4,'P'
	dc.l	l0027
	dc.b	2,'H'
	dc.l	l0029
	dc.b	2,'P'
	dc.l	l002d
	dc.b	1,'H'
	dc.l	l0029
	dc.b	1,'P'
	dc.l	l002d
	dc.b	0,'H'
	dc.l	l0031
	dc.b	0,'P'
	dc.l	l0033
	dc.b	0,';'
	dc.l	l0023
	dc.b	0,'<'
	dc.l	l0024
	dc.b	0,'='
	dc.l	l0022
	dc.b	8,'!'
	dc.l	l000e
	dc.b	8,$19
	dc.l	l0002
	dc.b	0,'b'
	dc.l	l005a
	dc.b	0,1
	dc.l	l0047
	ds.w	1
l00a1
	dc.b	$a,$d,$a,$d,$a,$d,$a,$d,$a,$d
	incbin	'sircware.asc'	!include any doc file here

	bss
zuend	ds.b	32628
l00a2	equ	zuend+0
l00a3	equ	zuend+1
l00a4	equ	zuend+2
l00a5	equ	zuend+3
l00a6	equ	zuend+4
l00a7	equ	zuend+5
l00a8	equ	zuend+6
l00a9	equ	zuend+8
l00aa	equ	zuend+$a
l00ab	equ	zuend+$c
l00ac	equ	zuend+$e
l00ad	equ	zuend+$12
l00ae	equ	zuend+$14
l00af	equ	zuend+$16
l00b0	equ	zuend+$18
l00b1	equ	zuend+$5e
l00b2	equ	zuend+$62
l00b3	equ	zuend+$64
l00b4	equ	zuend+$6c
l00b5	equ	zuend+$270
l00b6	equ	zuend+$274
l00b7	equ	zuend+$7f74

	end
