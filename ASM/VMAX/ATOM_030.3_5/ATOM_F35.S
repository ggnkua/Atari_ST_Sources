	text
begin	movea.l	4(a7),a5
	bsr	l004f
	bsr	l004d
	bsr	l0130
	bsr	l00b7
	move.w	#4,-(a7)
	trap	#$e
	addq.w	#2,a7
	move.w	d0,l0263
l0000	lea	l0212(pc),a0
	bsr	l003c
	lea	l0214(pc),a0
	bsr	l003c
	clr.w	l020d
l0001	bsr	l003d
	swap	d0
	cmp.w	#$3b,d0
	beq	l0026
	cmp.w	#$3c,d0
	beq	l0025
	cmp.w	#$3d,d0
	beq	l0082
	cmp.w	#$3e,d0
	beq	l006c
	cmp.w	#$3f,d0
	beq	l0054
	cmp.w	#$40,d0
	beq.s	l0005
	cmp.w	#$41,d0
	beq.s	l0002
	cmp.w	#$42,d0
	bne.s	l0001
	lea	l024e(pc),a0
	bsr.s	l0004
	lea	l024f(pc),a0
	bsr.s	l0004
	lea	l0250(pc),a0
	bsr.s	l0004
	bra.s	l0000
	bne.s	l0001
l0002	move.w	l0263(pc),d0
	beq.s	l0003
	lea	l024c(pc),a0
	bsr.s	l0004
l0003	lea	l024d(pc),a0
	bsr.s	l0004
	bra.s	l0000
l0004	bsr	l003c
	bsr	l003d
	rts

l0005	subi.l	#$1000,l0267
l0006	lea	l0212(pc),a0
	bsr	l003c
	lea	l0215(pc),a0
	bsr	l003c
l0007	bsr	l003d
	swap	d0
	cmp.w	#$3b,d0
	beq	l0013
	cmp.w	#$3c,d0
	beq	l0014
	cmp.w	#$3d,d0
	beq.s	l0008
	cmp.w	#$3e,d0
	bne.s	l0007
	addi.l	#$1000,l0267
	bra	l0000
l0008	lea	l0212(pc),a0
	bsr	l003c
	lea	l0216(pc),a0
	bsr	l003c
l0009	bsr	l003d
	swap	d0
	cmp.w	#$3b,d0
	beq.s	l000c
	cmp.w	#$3c,d0
	beq.s	l000b
	cmp.b	#$3d,d0
	beq.s	l000a
	cmp.b	#$3e,d0
	bne.s	l0009
	bra.s	l0006
l000a	lea	l0252(pc),a3
	bsr	l003e
	bra.s	l0008
l000b	lea	l0252(pc),a0
	lea	l0252(pc),a3
	sf	l0278
	bra.s	l000d
	illegal
l000c	lea	l0251(pc),a0
	lea	l0251(pc),a3
	st	l0278
l000d	lea	l025d(pc),a1
l000e	move.b	(a0)+,(a1)+
	bne.s	l000e
	st	l0275
	lea	l027b(pc),a0
	clr.w	(a0)
	clr.w	-2(a0)
	bsr	l0093
	bpl.s	l000f
	lea	l0222(pc),a0
	bsr	l003c
	bsr	l003d
	bra	l0008
l000f	move.b	l0278(pc),d0
	bne.s	l0010
	bsr	l0015
	bra.s	l0011
l0010	bsr	l0017
l0011	bsr	l0092
	beq.s	l000f
	bsr.s	l0012
	bsr	l0091
	bsr	l003d
	bra	l0008
l0012	lea	l0223(pc),a0
	bsr	l003c
	move.w	l027b(pc),d2
	bsr	l0090
	lea	l0229(pc),a0
	bsr	l003c
	lea	l0225(pc),a0
	bsr	l003c
	move.w	l027a(pc),d2
	bsr	l0090
	lea	l0226(pc),a0
	bsr	l003c
	rts

l0013	lea	l0251(pc),a3
	sf	l0275
	lea	l027b(pc),a0
	clr.w	(a0)
	clr.w	-2(a0)
	bsr.s	l0017
	bra	l0006
l0014	lea	l0252(pc),a3
	sf	l0275
	lea	l027b(pc),a0
	clr.w	(a0)
	clr.w	-2(a0)
	bsr.s	l0015
	bra	l0006
l0015	bsr	l0020
	bmi	l001f
	movea.l	l0267(pc),a0
	cmpi.l	#$41544d35,(a0)
	beq.s	l0016
	lea	l0212(pc),a0
	bsr	l003c
	lea	l0239(pc),a0
	bsr	l003c
	move.b	l0275(pc),d0
	bne	l001f
	bra	l001e
l0016	lea	4(a0),a1
	bra	l001d
	illegal
l0017	bsr	l0020
	bmi	l001f
	movea.l	l0267(pc),a0
	cmpi.w	#$601a,(a0)
	beq.s	l0018
	lea	l0212(pc),a0
	bsr	l003c
	lea	l0238(pc),a0
	bsr	l003c
	move.b	l0275(pc),d0
	bne	l001f
	bra	l001e
l0018	cmpi.l	#$ddc04e52,234(a0)
	beq.s	l001a
l0019	lea	l0212(pc),a0
	bsr	l003c
	lea	l0239(pc),a0
	bsr	l003c
	move.b	l0275(pc),d0
	bne.s	l001f
	bra.s	l001e
l001a	cmpi.l	#$332e3520,716(a0)
	beq.s	l001b
	cmpi.l	#$332e3520,634(a0)
	bne.s	l0019
l001b	cmpi.w	#$4bed,240(a0)
	bne.s	l001c
	st	l0277
l001c	movea.l	a0,a1
	lea	78(a1),a1
	adda.w	(a1),a1
	move.l	(a1),d0
	cmp.l	l0269(pc),d0
	ble.s	l001d
	lea	l023a(pc),a0
	bsr	l003c
	move.b	l0275(pc),d0
	bne.s	l001f
	bra.s	l001e
l001d	pea	(a0)
	lea	l0212(pc),a0
	bsr	l003c
	lea	l0233(pc),a0
	bsr	l003c
	lea	l025d(pc),a0
	bsr	l003c
	movea.l	(a7)+,a0
	movea.l	4(a1),a2
	lea	8(a1,a2.l),a2
	bsr	l0143
	bsr	l0028
	rts

l001e	bsr	l003d
l001f	subq.w	#1,l027b
	rts

l0020	lea	l027b(pc),a0
	addq.w	#1,(a0)
	addq.w	#1,-2(a0)
	bsr.s	l0021
	rts

l0021	move.l	a3,l0271
	move.b	l0275(pc),d0
	bne.s	l0022
	bsr	l003e
	tst.w	d0
	bne.s	l0023
l0022	bsr	l0049
	bsr	l0055
	move.b	l0261(pc),d0
	beq.s	l0024
	lea	l0212(pc),a0
	bsr	l003c
	lea	l023c(pc),a0
	bsr	l003c
	move.b	l0275(pc),d0
	bne.s	l0023
	bsr	l003d
l0023	moveq	#$ff,d0
	rts

l0024	move.l	l0264(pc),d0
	rts

l0025	st	l0207
	lea	l0252(pc),a3
	bra.s	l0027
l0026	sf	l0207
	lea	l0251(pc),a3
l0027	move.l	a3,l0271
	bsr	l003e
	tst.w	d0
	bne	l0000
	lea	l0212(pc),a0
	bsr	l003c
	sf	l0275
	bsr	l009a
	bra	l0000
l0028	move.l	d0,l020e
	lea	l0230(pc),a0
	bsr	l003c
	move.l	l020e(pc),d0
	bsr	l005e
	move.b	l0275(pc),d0
	bne.s	l002b
	lea	l023f(pc),a0
	bsr	l003c
l0029	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq.s	l002a
	cmp.w	#$4e,d0
	bne.s	l0029
	bra.s	l002c
l002a	movea.l	l0271(pc),a3
	bsr	l003e
	tst.w	d0
	bne.s	l002c
	lea	l0212(pc),a0
	bsr	l003c
l002b	bsr	l0049
	movea.l	l0267(pc),a2
	move.l	l020e(pc),d2
	bsr	l005a
	tst.b	l0261
	bne.s	l002d
	move.b	l0275(pc),d0
	bne.s	l002c
	lea	l0231(pc),a0
	bsr	l003c
	lea	l025d(pc),a0
	bsr	l003c
	lea	l0232(pc),a0
	bsr	l003c
	bsr	l003d
l002c	rts

l002d	lea	l023b(pc),a0
	bsr	l003c
l002e	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq	l0028
	cmp.w	#$4e,d0
	bne.s	l002e
	bra.s	l002c
l002f	lea	l023d(pc),a4
	move.l	l0210(pc),d0
	bra.s	l0031
l0030	lea	l023d(pc),a4
	lea	l003b(pc),a0
	bsr	l0039
	move.l	l026b(pc),d0
	sub.l	l026a(pc),d0
	add.l	d0,l0210
l0031	moveq	#0,d2
	lsr.l	#3,d0
	moveq	#$19,d1
l0032	sub.l	d1,d0
	bmi.s	l0033
	addq.l	#1,d2
	bra.s	l0032
l0033	divu	#$3c,d2
	swap	d2
	move.w	d2,-(a7)
	clr.w	d2
	swap	d2
	divu	#$3c,d2
	lea	l0270(pc),a0
	bsr.s	l0034
	swap	d2
	bsr.s	l0037
	bsr.s	l0036
	move.w	(a7)+,d2
	bsr.s	l0037
	bsr.s	l0036
	clr.b	-(a0)
	movea.l	a4,a0
	bsr.s	l003c
	lea	l0270(pc),a0
	bsr.s	l003c
	rts

l0034	bsr.s	l0037
	move.w	d3,d4
	lsr.w	#8,d4
	bne.s	l0035
	moveq	#$f0,d4
l0035	addi.w	#$30,d4
	move.b	d4,(a0)+
l0036	move.w	d3,d4
	lsr.w	#4,d4
	andi.w	#$f,d4
	addi.w	#$30,d4
	move.b	d4,(a0)+
	move.w	d3,d4
	andi.w	#$f,d3
	addi.w	#$30,d3
	move.b	d3,(a0)+
	move.b	#$3a,(a0)+
	rts

l0037	move.w	d1,-(a7)
	move.l	d2,-(a7)
	ext.l	d2
	moveq	#0,d3
	clr.w	d1
l0038	divu	#$a,d2
	swap	d2
	lsl.w	d1,d2
	or.w	d2,d3
	addq.w	#4,d1
	clr.w	d2
	swap	d2
	tst.w	d2
	bne.s	l0038
	move.l	(a7)+,d2
	move.w	(a7)+,d1
	rts

l0039	pea	(a0)
	move.w	#$26,-(a7)
	trap	#$e
	addq.w	#6,a7
	rts

l003a	move.l	$4ba.w,l026a
	rts

l003b	move.l	$4ba.w,l026b
	rts

l003c	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

l003d	move.w	#7,-(a7)
	trap	#1
	addq.w	#2,a7
	rts

l003e	movem.l	a0-a2/d1-d3,-(a7)
	bsr	l004e
	bsr.s	l0047
	lea	l025b(pc),a2
	tst.b	(a2)+
	beq.s	l0040
l003f	tst.b	(a2)+
	bne.s	l003f
l0040	move.b	#$5c,-1(a2)
l0041	move.b	(a3)+,(a2)+
	bne.s	l0041
	lea	l0253(pc),a0
	move.l	a0,d1
	move.w	#$c8,d0
	trap	#2
	bsr	l004d
	tst.w	l0258
	beq.s	l0042
	bsr.s	l0044
	moveq	#0,d0
	bra.s	l0043
l0042	moveq	#$ff,d0
l0043	movem.l	(a7)+,a0-a2/d1-d3
	rts

l0044	lea	l025b(pc),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	pea	(a1)
	subi.w	#$41,d0
	move.w	d0,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.w	#4,a7
	movea.l	(a7)+,a1
l0045	move.b	(a1)+,d0
	beq.s	l0046
	cmp.b	#$2a,d0
	bne.s	l0045
	clr.b	-(a1)
l0046	pea	l025b(pc)
	move.w	#$3b,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

l0047	movem.l	a0-a2,-(a7)
	lea	l025b(pc),a1
	movea.l	a1,a2
	moveq	#$40,d0
l0048	clr.b	(a1)+
	dbf	d0,l0048
	move.w	#$19,-(a7)
	trap	#1
	addq.w	#2,a7
	addi.w	#$41,d0
	move.b	d0,(a2)+
	move.b	#$3a,(a2)+
	clr.w	-(a7)
	pea	(a2)
	move.w	#$47,-(a7)
	trap	#1
	addq.w	#8,a7
	movem.l	(a7)+,a0-a2
	rts

l0049	lea	l025d(pc),a0
	lea	l025b(pc),a1
	bsr.s	l0047
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	beq.s	l004b
l004a	move.b	(a1)+,(a0)+
	bne.s	l004a
	subq.w	#1,a0
l004b	move.b	#$5c,(a0)+
	lea	l025c(pc),a1
l004c	move.b	(a1)+,(a0)+
	bne.s	l004c
	rts

l004d	movem.l	a0-a2/d0-d2,-(a7)
	dc.b	$a0,$a
	movem.l	(a7)+,a0-a2/d0-d2
	rts

l004e	movem.l	a0-a2/d0-d2,-(a7)
	dc.b	$a0,9
	movem.l	(a7)+,a0-a2/d0-d2
	rts

l004f	bsr.s	l0050
	bsr.s	l0051
	rts

l0050	moveq	#$40,d0
	lsl.w	#2,d0
	add.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	move.l	d0,-(a7)
	pea	(a5)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

l0051	moveq	#$ff,d0
	bsr.s	l0052
	subi.l	#$2a58,d0
	bmi.s	l0053
	move.l	d0,d1
	subi.l	#$1000,d1
	move.l	d1,l0269
	bsr.s	l0052
	lea	l0267(pc),a0
	move.l	d0,(a0)
	addi.l	#$1000,(a0)
	move.l	d0,4(a0)
l0052	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

l0053	lea	l022b(pc),a0
	bsr	l003c
	bsr	l003d
l0054	bsr.s	l004e
	clr.w	-(a7)
	trap	#1
l0055	bsr.s	l004e
	tst.b	l0275
	bne.s	l0056
	bsr	l0093
	tst.w	d0
	bmi.s	l0059
l0056	move.w	#2,-(a7)
	pea	l025d(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.w	#8,a7
	tst.w	d0
	bmi.s	l0059
	move.w	d0,l0262
	move.l	l0267(pc),-(a7)
	move.l	l025f(pc),-(a7)
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi.s	l0057
	move.l	d0,l0264
	bra.s	l0058
l0057	st	l0261
l0058	bra.s	l005c
l0059	bsr	l004d
	st	l0261
	rts

l005a	bsr	l004e
	sf	l0261
	clr.w	-(a7)
	pea	l025d(pc)
	move.w	#$3c,-(a7)
	trap	#1
	addq.w	#8,a7
	tst.w	d0
	bpl.s	l005b
	bsr	l004d
	moveq	#$ff,d0
	bra.s	l005d
l005b	move.w	d0,l0262
	pea	(a2)
	move.l	d2,-(a7)
	move.w	d0,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bpl.s	l005c
	st	l0261
l005c	bsr	l004d
	move.w	l0262(pc),-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.w	#4,a7
	tst.w	d0
l005d	rts

l005e	moveq	#0,d3
	lea	l027c(pc),a0
	lea	l027d(pc),a1
	moveq	#7,d2
l005f	rol.l	#4,d0
	move.w	d0,d1
	andi.w	#$f,d1
	tst.w	d3
	bne.s	l0061
	tst.w	d1
	bne.s	l0060
	tst.w	d2
	beq.s	l0062
	move.b	#$20,(a1)+
	bra.s	l0063
l0060	moveq	#$ff,d3
l0061	cmp.b	#9,d1
	bls.s	l0062
	addq.w	#7,d1
l0062	addi.w	#$30,d1
	move.b	d1,(a1)+
l0063	dbf	d2,l005f
	bsr	l003c
	rts

l0064	move.l	l020f(pc),d0
	sub.l	a4,d0
	move.l	d0,l026d
	lea	509(a4),a4
	move.l	a4,l026e
	lea	l022e(pc),a0
	bsr	l003c
	move.l	l026d(pc),d0
	move.l	d0,-(a7)
	bsr.s	l005e
	move.l	l026c(pc),d0
	move.l	(a7)+,d1
	sub.l	d0,d1
	neg.l	d1
	bsr	l0133
	rts

l0065	lea	l022f(pc),a0
	bsr	l003c
	move.l	a5,d0
	movea.l	l0268(pc),a0
	sub.l	a0,d0
	move.l	d0,-(a7)
	bsr	l005e
	move.l	(a7)+,d1
	move.l	l026c(pc),d0
	bsr	l0133
	rts

l0066	movem.l	a0-a4/d1-d3,-(a7)
	bsr.s	l0065
l0067	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.w	#4,a7
	swap	d0
	cmp.w	#$61,d0
	beq.s	l0068
	tst.l	d0
	bne.s	l0067
	bra.s	l006b
l0068	lea	l0240(pc),a0
	bsr	l003c
l0069	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq.s	l006a
	cmp.w	#$4e,d0
	bne.s	l0069
	bra.s	l006b
l006a	st	l0276
	move.w	#$ff4,l020c
l006b	movem.l	(a7)+,a0-a4/d1-d3
	rts

l006c	lea	l0212(pc),a0
	bsr	l003c
	lea	l0217(pc),a0
	bsr	l003c
l006d	bsr	l003d
	swap	d0
	cmp.w	#$3b,d0
	beq.s	l0070
	cmp.w	#$3c,d0
	beq.s	l0071
	cmp.w	#$3d,d0
	beq.s	l006e
	cmp.w	#$3e,d0
	bne.s	l006d
	bra	l0000
l006e	lea	l021f(pc),a0
	bsr	l003c
l006f	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$4e,d0
	beq.s	l006c
	cmp.w	#$59,d0
	bne.s	l006f
	lea	l0220(pc),a0
	bsr	l003c
	clr.b	l0273
	bsr	l003d
	bra.s	l006c
l0070	lea	l0212(pc),a0
	bsr	l003c
	lea	l022a(pc),a0
	bsr	l003c
	bsr	l003d
	bra.s	l006c
l0071	lea	l0218(pc),a0
	bsr	l003c
	moveq	#2,d3
	moveq	#9,d6
	bsr	l007b
	bsr.s	l0074
	move.b	d4,l0273
	lea	l0246(pc),a0
	bsr	l003c
	lea	l0272(pc),a2
l0072	tst.b	d4
	beq	l006c
	bsr.s	l0073
	move.l	d2,(a2)+
	bra.s	l0072
l0073	lea	l0219(pc),a0
	bsr	l003c
	move.w	d4,d2
	bsr	l0037
	move.w	d3,d1
	bsr.s	l0077
	lea	l021d(pc),a0
	bsr	l003c
	moveq	#5,d3
	moveq	#$f,d6
	bsr.s	l007b
	lsr.w	#1,d2
	bcs.s	l0073
	add.w	d2,d2
	subq.w	#1,d4
	rts

l0074	clr.w	d4
l0075	subi.w	#$10,d2
	bmi.s	l0076
	addi.w	#$a,d4
	bra.s	l0075
l0076	addi.w	#$10,d2
	add.w	d2,d4
	rts

l0077	move.w	d1,-(a7)
	lsr.b	#4,d1
	bsr.s	l0078
	move.w	(a7)+,d1
	andi.w	#$f,d1
	bsr.s	l0078
	rts

l0078	cmp.w	#9,d1
	ble.s	l0079
	addi.w	#$37,d1
	bra.s	l007a
l0079	addi.w	#$30,d1
l007a	move.w	d1,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.w	#4,a7
	rts

l007b	move.w	d3,d5
l007c	moveq	#0,d2
l007d	bsr	l003d
	cmp.w	#$d,d0
	beq.s	l0080
	cmp.w	#8,d0
	beq.s	l0081
	move.w	d0,d1
	cmp.w	#$39,d0
	bgt.s	l007e
	subi.w	#$30,d0
	bmi.s	l007d
	bra.s	l007f
l007e	andi.w	#$df,d0
	subi.w	#$37,d0
	bmi.s	l007d
l007f	cmp.w	d6,d0
	bgt.s	l007d
	lsl.l	#4,d2
	or.b	d0,d2
	bsr.s	l007a
	dbf	d3,l007d
	move.w	d5,d1
	mulu	#3,d1
	neg.w	d1
	lea	l024a(pc),a0
	lea	0(a0,d1.w),a0
	bsr	l003c
	move.w	d5,d3
	bra.s	l007c
l0080	cmp.w	d5,d3
	beq.s	l007d
	rts

l0081	cmp.w	d5,d3
	beq.s	l007d
	addq.w	#1,d3
	lsr.l	#4,d2
	lea	l024a(pc),a0
	bsr	l003c
	bra.s	l007d
l0082	lea	l0212(pc),a0
	bsr	l003c
	lea	l0221(pc),a0
	bsr	l003c
	moveq	#0,d0
	lea	l027a(pc),a0
	move.w	d0,(a0)
	move.w	d0,2(a0)
	move.l	d0,-268(a0)
	move.l	d0,-264(a0)
l0083	bsr	l003d
	swap	d0
	cmp.w	#$3b,d0
	beq.s	l0086
	cmp.w	#$3c,d0
	beq.s	l0085
	cmp.w	#$3d,d0
	beq.s	l0084
	cmp.w	#$3e,d0
	bne.s	l0083
	bra	l0000
l0084	lea	l0252(pc),a3
	bsr	l003e
	bra.s	l0082
l0085	lea	l0252(pc),a0
	st	l0207
	bra.s	l0087
l0086	lea	l0251(pc),a0
	sf	l0207
l0087	lea	l025d(pc),a1
l0088	move.b	(a0)+,(a1)+
	bne.s	l0088
	bsr	l0093
	beq.s	l0089
	lea	l0222(pc),a0
	bsr	l003c
	bsr	l003d
	bra	l0082
l0089	st	l0275
l008a	tst.b	l0261
	bne.s	l008c
	lea	l027a(pc),a0
	addq.w	#1,(a0)
	addq.w	#1,2(a0)
	bsr	l009a
	move.b	l0276(pc),d2
	bne.s	l008b
	move.b	l0279(pc),d2
	beq.s	l008c
l008b	lea	l020d(pc),a2
	move.w	2(a2),(a2)
	subq.w	#1,l027b
	move.l	l0264(pc),d2
	add.l	d2,l0266
	move.b	l0276(pc),d2
	bne.s	l008d
l008c	bsr	l0092
	beq.s	l008a
l008d	lea	l0244(pc),a0
	bsr	l003c
	bsr	l002f
	lea	l0223(pc),a0
	bsr	l003c
	move.w	l027b(pc),d2
	bsr.s	l0090
	lea	l0224(pc),a0
	bsr	l003c
	lea	l0225(pc),a0
	bsr	l003c
	move.w	l027a(pc),d2
	bsr.s	l0090
	lea	l0226(pc),a0
	bsr	l003c
	lea	l0234(pc),a0
	bsr	l003c
	lea	l0236(pc),a0
	move.w	l020d(pc),d5
	addq.w	#1,d5
	bclr	#0,d5
	bsr	l00ad
	move.l	l0265(pc),d0
	move.l	l0266(pc),d1
	cmp.l	d0,d1
	bne.s	l008e
	lea	l0228(pc),a0
	bsr	l003c
	bra.s	l008f
l008e	movem.l	d0-d1,-(a7)
	lea	l0227(pc),a0
	bsr	l003c
	movem.l	(a7)+,d0-d1
	bsr	l0133
l008f	bsr.s	l0091
	bsr	l003d
	bra	l0082
l0090	bsr	l0037
	move.w	d3,-(a7)
	move.b	(a7)+,d1
	bsr	l0077
	move.b	d3,d1
	bsr	l0077
	rts

l0091	lea	l024b(pc),a0
	bsr	l003c
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.w	#4,a7
	tst.w	d0
	beq.s	l0091
	rts

l0092	moveq	#$4f,d5
	bra.s	l0094
l0093	moveq	#$4e,d5
	bsr	l00b7
l0094	sf	l0261
	clr.w	-(a7)
	pea	l025d(pc)
	move.w	d5,-(a7)
	trap	#1
	addq.w	#8,a7
	move.w	d0,-(a7)
	bmi.s	l0095
	move.l	l0269(pc),d0
	cmp.l	l025f(pc),d0
	blt.s	l0098
	bsr.s	l0096
l0095	move.w	(a7)+,d0
	rts

l0096	lea	l0260(pc),a0
	lea	l025c(pc),a1
	moveq	#$d,d1
l0097	move.b	(a0)+,(a1)+
	dbf	d1,l0097
	rts

l0098	lea	l0212(pc),a0
	bsr	l003c
	lea	l0237(pc),a0
	bsr	l003c
	tst.b	l0275
	bne.s	l0099
	bsr	l003d
l0099	st	l0261
	rts

l009a	bsr	l0101
	bsr	l00f2
	lea	l020c(pc),a2
	move.w	#$ff4,(a2)
	move.b	l0207(pc),d0
	bne.s	l009b
	addq.w	#4,(a2)
l009b	move.w	2(a2),d2
	move.w	d2,4(a2)
	bsr	l0049
	bsr	l0055
	move.l	l0264(pc),d0
	add.l	d0,l0265
	lea	l0212(pc),a0
	bsr	l003c
	tst.b	l0261
	beq.s	l009d
	lea	l023c(pc),a0
	bsr	l003c
	tst.b	l0275
	bne.s	l009c
	bsr	l003d
l009c	bra	l00b6
l009d	move.l	l0264(pc),d0
	move.l	d0,-(a7)
	moveq	#0,d1
	move.b	l0273(pc),d1
	lea	l0272(pc),a0
	bne.s	l009e
	sf	l0274
	bra.s	l00a1
l009e	st	l0274
	subq.w	#1,d1
	subi.l	#$7d00,d0
	bmi.s	l00a0
l009f	cmp.l	(a0)+,d0
	dblt	d1,l009f
	bge.s	l00a1
l00a0	addq.w	#1,d1
	move.w	d1,-(a7)
	lea	l021b(pc),a0
	bsr	l003c
	move.w	(a7)+,d2
	bsr	l0037
	move.w	d3,d1
	bsr	l0077
	lea	l021c(pc),a0
	bsr	l003c
	bsr	l003d
	addq.w	#4,a7
	st	l0276
	move.w	#$ff4,l020c
	bra	l00b6
l00a1	move.l	(a7)+,d0
	moveq	#0,d7
	move.b	l0273(pc),d7
	beq.s	l00a3
	movea.l	l0267(pc),a0
	movea.l	a0,a2
	addq.l	#1,d0
	bclr	#0,d0
	adda.l	d0,a0
	lea	l0272(pc),a1
l00a2	move.l	(a1)+,(a0)+
	subq.w	#1,d7
	bne.s	l00a2
	move.l	a0,d0
	sub.l	a2,d0
l00a3	move.l	d0,l026c
	move.l	d0,l026d
	lea	l022d(pc),a0
	bsr	l003c
	lea	l025d(pc),a0
	bsr	l003c
	lea	l0246(pc),a0
	bsr	l003c
	sf	l0279
	lea	l003a(pc),a0
	bsr	l0039
	bsr	l00b8
	move.b	l0276(pc),d2
	bne	l00b6
	bsr	l0030
	move.l	l026c(pc),d0
	move.l	(a5),d1
	lsr.w	#1,d1
	bcc.s	l00a4
	add.w	d1,d1
	addq.l	#2,d1
	bra.s	l00a5
l00a4	add.w	d1,d1
l00a5	movea.l	d1,a0
	addq.w	#8,a0
	moveq	#0,d3
	move.b	l0207(pc),d2
	bne.s	l00a7
	move.l	a0,d3
	move.b	l0274(pc),d2
	beq.s	l00a6
	lea	82(a0),a0
l00a6	lea	656(a0),a0
	sub.l	a0,d3
	neg.l	d3
	bra.s	l00a8
l00a7	addq.w	#4,a0
l00a8	sub.l	a0,d0
	ble	l00b5
	moveq	#0,d1
	move.w	l020c(pc),d1
	subi.w	#$ff4,d1
	move.b	l0207(pc),d2
	bne.s	l00a9
	subq.w	#4,d1
l00a9	neg.w	d1
	addq.w	#1,d1
	bclr	#0,d1
	move.w	d1,l0188
	move.w	d1,l01cb
	add.l	d1,d0
	add.l	d3,d0
	addq.l	#8,d0
	move.l	d0,l017b
	move.l	d0,l01be
	move.l	a0,l020e
	lea	l0230(pc),a0
	bsr	l003c
	move.l	l020e(pc),d0
	move.l	d0,-(a7)
	bsr	l005e
	move.l	l0264(pc),d0
	move.l	(a7)+,d1
	bsr	l0133
	tst.b	l0207
	bne.s	l00ac
	movea.l	l020e(pc),a0
	move.l	a0,d2
	lea	-28(a0),a0
	move.l	a0,l017a
	move.l	a0,l01bd
	movea.l	l0268(pc),a1
	suba.w	#$290,a1
	lea	l01bc(pc),a0
	move.w	#$147,d0
	tst.b	l0274
	beq.s	l00aa
	suba.w	#$52,a1
	lea	l0179(pc),a0
	addi.w	#$29,d0
l00aa	movea.l	a1,a2
l00ab	move.w	(a0)+,(a1)+
	dbf	d0,l00ab
	bra.s	l00ae
l00ac	movea.l	l0268(pc),a2
	move.l	l020e(pc),d2
	bra.s	l00ae
l00ad	bsr	l003c
	move.w	d5,-(a7)
	move.b	(a7)+,d1
	bsr	l0077
	move.b	d5,d1
	bsr	l0077
	rts

l00ae	lea	l0244(pc),a0
	bsr	l003c
	lea	l0235(pc),a0
	move.w	l020c(pc),d5
	subi.w	#$ff4,d5
	move.b	l0207(pc),d0
	bne.s	l00af
	subq.w	#4,d5
l00af	neg.w	d5
	addq.w	#1,d5
	bclr	#0,d5
	bsr.s	l00ad
	move.b	l0275(pc),d0
	bne.s	l00b2
	lea	l023e(pc),a0
	bsr	l003c
l00b0	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq.s	l00b1
	cmp.w	#$4e,d0
	bne.s	l00b0
	bra	l00b6
l00b1	movea.l	l0271(pc),a3
	bsr	l003e
	tst.w	d0
	bne.s	l00b6
	lea	l0212(pc),a0
	bsr	l003c
l00b2	bsr	l0049
	add.l	d2,l0266
	bsr	l005a
	tst.b	l0261
	bne.s	l00b3
	move.b	l0275(pc),d0
	bne.s	l00b6
	lea	l0231(pc),a0
	bsr	l003c
	lea	l025d(pc),a0
	bsr	l003c
	lea	l0232(pc),a0
	bsr	l003c
	bsr	l003d
	bra.s	l00b6
l00b3	lea	l023b(pc),a0
	bsr	l003c
l00b4	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq	l00ae
	cmp.w	#$4e,d0
	bne.s	l00b4
	bra.s	l00b6
l00b5	st	l0279
	lea	l022c(pc),a0
	bsr	l003c
	tst.b	l0275
	bne.s	l00b6
	bsr	l003d
l00b6	rts

l00b7	pea	l025e(pc)
	move.w	#$1a,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

l00b8	moveq	#0,d7
	move.b	l0273(pc),d7
	beq.s	l00bb
	lea	l0272(pc),a2
l00b9	dbf	d7,l00ba
	bra.s	l00bb
l00ba	lea	l021e(pc),a0
	bsr	l003c
	move.w	d7,d2
	addq.w	#1,d2
	bsr	l0037
	move.w	d3,d1
	bsr	l0077
	lea	l021a(pc),a0
	bsr	l003c
	movea.l	l0267(pc),a0
	adda.l	(a2)+,a0
	bsr	l012c
	bra.s	l00b9
l00bb	bsr.s	l00bc
	rts

l00bc	movea.l	l0267(pc),a0
	move.l	a0,l026e
	move.l	a0,l026f
	movea.l	l0268(pc),a5
	tst.b	l0207
	beq.s	l00bd
	move.b	#$41,(a5)+
	move.b	#$54,(a5)+
	move.b	#$4d,(a5)+
	move.b	#$35,(a5)+
l00bd	move.l	l026c(pc),d0
	btst	#0,d0
	bcc.s	l00be
	addq.l	#1,d0
	move.l	d0,l026c
l00be	lea	0(a0,d0.l),a6
	move.l	a6,l020f
	moveq	#0,d0
	movep.l	d0,0(a6)
	movep.l	d0,1(a6)
	move.l	a6,d0
	sub.l	a0,d0
	move.l	d0,(a5)+
	addq.w	#4,a5
	pea	(a5)
	moveq	#0,d3
	moveq	#$80,d7
	clr.b	l0276
	swap	d7
	move.w	#$2408,l00ce
	movea.l	a0,a4
	move.l	a0,l026e
	movem.l	a0-a6/d0-d7,-(a7)
	bsr	l0064
	bsr	l0065
	movem.l	(a7)+,a0-a6/d0-d7
	bsr	l0139
	moveq	#0,d6
	sf	l0209
	bsr	l00cb
	tst.b	l0276
	beq.s	l00bf
	addq.w	#4,a7
	bra.s	l00c2
l00bf	swap	d7
	move.b	d7,(a5)+
	move.b	l0273(pc),d7
	move.b	l0207(pc),d0
	bne.s	l00c0
	tst.b	d7
	beq.s	l00c1
l00c0	move.b	d7,(a5)+
l00c1	moveq	#0,d0
	movep.l	d0,0(a5)
	movep.l	d0,1(a5)
	move.l	a5,d0
	movea.l	(a7)+,a5
	sub.l	a5,d0
	move.l	d0,-(a5)
l00c2	rts

l00c3	movem.l	a0-a4/d1-d3,-(a7)
	bsr	l0064
l00c4	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.w	#4,a7
	swap	d0
	cmp.w	#$61,d0
	beq.s	l00c5
	tst.l	d0
	bne.s	l00c4
	bra.s	l00c9
l00c5	lea	l0240(pc),a0
	bsr	l003c
l00c6	bsr	l003d
	andi.w	#$df,d0
	cmp.w	#$59,d0
	beq.s	l00c7
	cmp.w	#$4e,d0
	bne.s	l00c6
	bra.s	l00c9
l00c7	lea	l0276(pc),a0
	st	(a0)
	move.w	#$ff4,-8849(a0)
	movem.l	(a7)+,a0-a4/d1-d3
l00c8	rts

l00c9	movem.l	(a7)+,a0-a4/d1-d3
	move.b	-1(a4),d0
	bra.s	l00cc
l00ca	movea.l	l0268(pc),a5
	adda.l	l026c(pc),a5
	rts

l00cb	moveq	#0,d0
	lea	l0204(pc),a3
	move.l	d0,(a3)+
	move.b	d0,(a3)
	lea	l0140(pc),a3
	lea	l0141(pc),a2
	move.b	(a4)+,d0
	cmpa.l	l026e(pc),a4
	bge.s	l00c3
l00cc	move.b	(a4),d1
l00cd	lea	16224(a4),a1
	cmpa.l	a1,a6
	bgt.s	l00cf
l00ce	move.l	a0,d2
	lea	-1(a4),a0
	subq.w	#1,a4
	bsr	l00e4
	addq.w	#1,a4
	move.b	l0276(pc),d2
	bne.s	l00c8
	move.b	l0209(pc),d2
	bne.s	l00ca
	bsr	l0139
	bra.s	l00cd
	movea.l	a6,a1
l00cf	move.w	d0,d2
	add.w	d2,d2
	adda.w	d2,a2
	subq.w	#1,(a2)
	beq.s	l00d2
	move.w	(a2),d7
	subq.w	#1,d7
	lea	l0142(pc),a2
	adda.w	d2,a2
	addq.w	#2,(a2)
	move.w	(a2),d6
	add.w	d2,d2
	movea.l	0(a3,d2.w),a2
	adda.l	d6,a2
	pea	(a2)
l00d0	movea.l	a0,a3
	adda.w	(a2)+,a3
	cmpa.l	a3,a1
	ble.s	l00d1
	cmp.b	(a3)+,d1
	dbeq	d7,l00d0
	bne.s	l00d1
	addq.w	#1,a4
	cmpa.l	a3,a1
	bge.s	l00d3
	subq.w	#1,a4
	tst.w	l0205
	bge.s	l00d1
	move.l	a3,d2
	sub.l	a4,d2
	cmp.w	#$360,d2
	bgt.s	l00d1
	subq.w	#1,d2
	move.w	d2,l0204
	addq.w	#2,l0205
	st	l0206
l00d1	bra.s	l00db
l00d2	lea	l0142(pc),a2
	adda.w	d2,a2
	move.w	(a2),d6
	addq.w	#2,d6
	add.w	d2,d2
	lea	l0140(pc),a2
	movea.l	0(a2,d2.w),a2
	adda.l	d6,a2
	bra.s	l00dc
l00d3	move.l	a4,d2
l00d4	cmpm.b	(a4)+,(a3)+
	bne.s	l00d5
	cmpa.l	a3,a1
	bge.s	l00d4
l00d5	sub.l	a4,d2
	neg.w	d2
	addq.w	#1,d2
	suba.w	d2,a4
	cmp.w	#$100,d2
	ble.s	l00d8
	cmp.w	#1,d7
	blt.s	l00d8
l00d6	moveq	#0,d4
	move.w	(a2)+,d4
	add.l	a0,d4
	cmpa.l	d4,a3
	ble.s	l00d7
	dbf	d7,l00d6
	clr.w	d7
l00d7	subq.w	#2,a2
l00d8	cmp.w	l0205(pc),d2
	ble.s	l00da
	move.w	d2,l0205
	move.l	a3,d5
	sub.l	a4,d5
	cmp.w	#2,d2
	bgt.s	l00d9
	cmp.w	#$362,d5
	bgt.s	l00da
l00d9	st	l0206
	sub.w	d2,d5
	subq.w	#1,d5
	st	l0206
	move.w	d5,l0204
l00da	dbf	d7,l00d0
l00db	movea.l	(a7)+,a2
l00dc	move.b	l0206(pc),d1
	bne.s	l00de
	move.b	(a4),d1
	sub.b	d0,d1
	cmp.b	#7,d1
	bgt.s	l00dd
	cmp.b	#$f8,d1
	blt.s	l00dd
	addq.w	#1,l020b
l00dd	add.w	d0,d0
	lea	l01fc(pc),a3
	adda.w	d0,a3
	addq.w	#1,(a3)
	move.w	#$ffff,-(a2)
	cmpa.l	a4,a6
	bgt	l00cb
	bra	l00e3
l00de	move.w	l0204(pc),d0
	move.w	d0,-(a2)
	lea	l01f7(pc),a2
	andi.w	#$f,d0
	add.w	d0,d0
	adda.w	d0,a2
	addq.w	#1,(a2)
	move.w	l0205(pc),d0
	subq.w	#1,d0
	movea.l	a4,a2
	adda.w	d0,a4
	lea	l0141(pc),a3
	move.b	(a2)+,d1
	moveq	#0,d2
	move.b	d1,d2
	add.w	d2,d2
	adda.w	d2,a3
	subq.w	#1,(a3)
	lea	l0142(pc),a3
	adda.w	d2,a3
	move.w	(a3),d6
	addq.w	#2,(a3)
	add.w	d2,d2
	lea	l0140(pc),a3
	movea.l	0(a3,d2.w),a3
	adda.l	d6,a3
	move.w	d0,(a3)
	subq.w	#1,d0
	move.w	d0,d1
	cmp.w	#$ff,d1
	bgt.s	l00df
	add.w	d1,d1
	lea	l01ff(pc),a3
	adda.w	d1,a3
	addq.w	#1,(a3)
	bra.s	l00e0
l00df	addq.w	#1,l0201
l00e0	dbf	d0,l00e1
	bra.s	l00e2
l00e1	lea	l0141(pc),a3
	move.b	(a2)+,d1
	moveq	#0,d2
	move.b	d1,d2
	add.w	d2,d2
	adda.w	d2,a3
	subq.w	#1,(a3)
	lea	l0142(pc),a3
	adda.w	d2,a3
	addq.w	#2,(a3)
	bra.s	l00e0
l00e2	cmpa.l	a4,a6
	bgt	l00cb
l00e3	move.l	a0,d2
	bsr.s	l00e4
	move.b	l0276(pc),d2
	bne	l00c8
	move.b	l0209(pc),d2
	bne	l00ca
	rts

l00e4	movem.l	a0-a3/d0-d6,-(a7)
	move.l	d2,-(a7)
	swap	d7
	bsr	l00f4
	tst.w	d2
	bne.s	l00e5
	sf	l0208
	lea	l0242(pc),a0
	bra.s	l00e6
l00e5	st	l0208
	lea	l0243(pc),a0
l00e6	bsr	l003c
	bsr	l00f9
	bsr.s	l00ea
	bsr	l00ff
	movea.l	(a7)+,a0
	move.l	a4,d0
	sub.l	a0,d0
	move.w	d0,l0203
	bsr	l0105
	lea	l0245(pc),a0
	bsr	l003c
	move.b	l0209(pc),d2
	bne.s	l00e9
	tst.b	l0276
	bne.s	l00e9
	lea	l020c(pc),a2
	move.w	(a2),d1
	subi.w	#$ff4,d1
	move.b	l0207(pc),d0
	bne.s	l00e7
	subq.w	#4,d1
l00e7	neg.w	d1
	cmp.w	l020d(pc),d1
	ble.s	l00e8
	move.w	d1,2(a2)
l00e8	bsr	l0124
	bsr	l0101
	movem.l	(a7)+,a0-a3/d0-d6
	swap	d7
	rts

l00e9	movem.l	(a7)+,a0-a3/d0-d6
	rts

l00ea	st	l020a
	lea	l01f8(pc),a0
	lea	l01f9(pc),a1
	moveq	#7,d0
l00eb	move.w	(a0),(a1)+
	addq.w	#4,a0
	dbf	d0,l00eb
	lea	l01f9(pc),a0
	lea	l01fa(pc),a1
	moveq	#7,d2
	moveq	#0,d3
l00ec	movea.l	a0,a2
	movea.l	a2,a3
	moveq	#7,d1
	move.w	(a2),d0
l00ed	cmp.w	(a2)+,d0
	dblt	d1,l00ed
	bge.s	l00ee
	lea	-2(a2),a3
	move.w	(a3),d0
	dbf	d1,l00ed
l00ee	move.l	a3,d0
	sub.l	a0,d0
	add.w	(a3),d3
	clr.w	(a3)
	lsr.b	#1,d0
	move.b	d0,(a1)+
	dbf	d2,l00ec
	lea	l0121(pc),a2
	moveq	#6,d1
	moveq	#0,d2
l00ef	cmp.b	d2,d0
	bne.s	l00f0
	addq.w	#1,a2
l00f0	move.b	d2,(a2)+
	addq.w	#1,d2
	dbf	d1,l00ef
	add.w	d0,d0
	add.w	d0,d0
	lea	l01f7(pc),a0
	sub.w	2(a0,d0.w),d3
	moveq	#7,d1
	clr.w	d0
l00f1	add.w	(a0),d0
	addq.w	#4,a0
	dbf	d1,l00f1
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	sub.w	d0,d3
	subq.w	#8,d3
	bgt.s	l00f2
	sf	l020a
l00f2	lea	l01f7(pc),a0
	moveq	#7,d0
l00f3	clr.l	(a0)+
	dbf	d0,l00f3
	rts

l00f4	pea	(a4)
	lea	l01fc(pc),a0
	lea	l01fd(pc),a1
	moveq	#$f,d2
	moveq	#0,d3
l00f5	movea.l	a0,a2
	movea.l	a0,a3
	move.w	(a2)+,d0
	movea.l	a0,a4
	move.w	#$ff,d1
l00f6	cmp.w	(a4)+,d0
	dblt	d1,l00f6
	bge.s	l00f7
	lea	-2(a4),a3
	move.w	(a3),d0
	dbf	d1,l00f6
l00f7	move.l	a3,d0
	sub.l	a0,d0
	lsr.w	#1,d0
	move.b	d0,(a1)+
	add.w	(a3),d3
	clr.w	(a3)
	dbf	d2,l00f5
	movea.l	(a7)+,a4
	subi.w	#$80,d3
	cmp.w	l020b(pc),d3
	ble.s	l00f8
	moveq	#0,d2
l00f8	rts

l00f9	move.w	l0201(pc),d1
	lea	l0200(pc),a0
	lea	l0201(pc),a1
	lea	l0202(pc),a2
	move.w	#$7fff,(a2)
	move.w	#$ff,d0
l00fa	add.w	-(a0),d1
	move.w	d1,-(a1)
	dbf	d0,l00fa
	moveq	#0,d5
	move.w	#$fe,d4
l00fb	addq.w	#2,d5
	moveq	#0,d1
	movea.l	a0,a3
	move.w	d5,d0
	moveq	#1,d3
l00fc	moveq	#0,d2
	move.w	(a3)+,d2
	mulu	d3,d2
	add.l	d2,d1
	addq.w	#1,d3
	subq.w	#2,d0
	bne.s	l00fc
	movea.l	a0,a3
	adda.w	d5,a3
	moveq	#$f,d0
	moveq	#0,d2
l00fd	add.w	(a3)+,d2
	dbf	d0,l00fd
	move.l	d5,d0
	lsr.w	#1,d0
	mulu	d2,d0
	lsl.l	#2,d2
	add.l	d0,d2
	add.l	d2,d1
	move.w	32(a1,d5.w),d0
	ext.l	d0
	move.l	d5,d2
	lsr.w	#1,d2
	mulu	d0,d2
	lsl.l	#2,d0
	move.l	d0,d3
	add.l	d0,d0
	add.l	d3,d0
	add.l	d0,d1
	add.l	d2,d1
	cmp.l	(a2),d1
	dblt	d4,l00fb
	bge.s	l00fe
	move.l	d1,(a2)
	move.w	d5,4(a2)
	dbf	d4,l00fb
l00fe	move.w	4(a2),d4
	lsr.w	#1,d4
	subq.w	#1,d4
	rts

l00ff	lea	l0142(pc),a0
	moveq	#0,d0
	moveq	#$7f,d1
l0100	move.l	d0,(a0)+
	dbf	d1,l0100
	rts

l0101	lea	l01fc(pc),a0
	lea	l0201(pc),a1
	moveq	#0,d0
l0102	move.l	d0,(a0)+
	cmpa.l	a0,a1
	bgt.s	l0102
	bne.s	l0103
	move.w	d0,(a0)+
l0103	rts

l0104	st	l0209
	move.w	#$ff4,l020c
	rts

l0105	move.l	a0,d1
	sub.l	a5,d1
	blt.s	l0104
	cmp.l	#$ff4,d1
	bge.s	l0106
	lea	l020c(pc),a2
	cmp.w	(a2),d1
	bge.s	l0106
	move.w	d1,(a2)
l0106	moveq	#0,d5
	move.b	(a0)+,d5
	bsr	l0112
	move.w	d0,d1
	bpl.s	l010c
	move.b	l0208(pc),d1
	beq.s	l0107
	cmpa.l	l020f(pc),a0
	beq.s	l010a
	move.b	(a0),d0
	sub.b	d5,d0
	cmp.b	#7,d0
	bgt.s	l010a
	cmp.b	#$f8,d0
	blt.s	l010a
	bra.s	l0109
l0107	lea	l01fd(pc),a1
	move.l	a1,d0
	lea	16(a1),a2
	move.b	d5,(a2)+
l0108	cmp.b	(a1)+,d5
	bne.s	l0108
	cmpa.l	a1,a2
	beq.s	l010a
	sub.l	a1,d0
	not.w	d0
l0109	ori.w	#$30,d0
	move.w	d0,d1
	moveq	#5,d3
	bsr	l011f
	bra.s	l010f
l010a	move.b	d5,(a5)+
	lsr.b	#1,d7
	bcc.s	l010b
	move.b	d7,(a5)+
	moveq	#$80,d7
l010b	bra.s	l0110
l010c	move.b	(a0)+,d5
	bsr.s	l0112
	lea	l0142(pc),a2
	move.w	d0,d6
	subq.w	#1,d6
	beq.s	l010e
l010d	move.b	(a0)+,d2
	moveq	#0,d3
	move.b	d2,d3
	add.w	d3,d3
	addq.w	#2,0(a2,d3.w)
	subq.w	#1,d6
	bne.s	l010d
l010e	bsr.s	l0114
l010f	lsr.b	#1,d7
	bset	#7,d7
	bcc.s	l0110
	move.b	d7,(a5)+
	moveq	#$80,d7
l0110	cmpa.l	l026f(pc),a0
	bge.s	l0113
l0111	cmpa.l	a0,a4
	bne	l0105
	rts

l0112	lea	l0140(pc),a2
	move.w	d5,d0
	add.w	d0,d0
	lea	l0142(pc),a1
	adda.w	d0,a1
	move.w	(a1),d6
	addq.w	#2,(a1)
	add.w	d0,d0
	movea.l	0(a2,d0.w),a2
	adda.l	d6,a2
	move.w	(a2),d0
	rts

l0113	lea	316(a0),a1
	move.l	a1,l026f
	bsr	l0066
	tst.b	l0276
	beq.s	l0111
	rts

l0114	bsr.s	l0118
	move.w	d0,d1
	subq.w	#1,d1
	sub.w	d4,d1
	bgt.s	l0115
	add.w	d4,d1
	move.w	d1,d3
	moveq	#1,d1
	bra	l011f
l0115	subi.w	#$f,d1
	bgt.s	l0116
	addi.w	#$f,d1
	moveq	#4,d3
	add.w	d4,d3
	bra.s	l011f
l0116	subi.w	#$ff,d1
	bgt.s	l0117
	addi.w	#$ff,d1
	moveq	#$c,d3
	add.w	d4,d3
	bra.s	l011f
l0117	moveq	#$1a,d3
	add.w	d4,d3
	bra.s	l011f
l0118	lea	l01bb(pc),a2
	move.l	a2,d3
l0119	cmp.w	(a2)+,d1
	blt.s	l011a
	sub.w	-2(a2),d1
	bra.s	l0119
l011a	sub.l	a2,d3
	neg.w	d3
	or.w	l0122(pc,d3.w),d1
	move.w	l0123(pc,d3.w),d3
	move.b	l020a(pc),d2
	beq.s	l011e
	move.w	d1,d6
	andi.w	#$f,d6
	lsr.w	#4,d1
	lsr.b	#1,d6
	bcs.s	l011b
	ori.b	#$78,d6
	move.w	d3,d2
	move.w	d1,d5
	move.w	d6,d1
	moveq	#6,d3
	bra.s	l011d
l011b	cmp.b	l01fb(pc),d6
	bne.s	l011c
	lsl.w	#4,d1
	ori.w	#$e,d1
	bra.s	l011e
l011c	move.b	l0121(pc,d6.w),d6
	move.w	d3,d2
	moveq	#2,d3
	move.w	d1,d5
	move.w	d6,d1
l011d	bsr.s	l011f
	move.w	d5,d1
	subq.w	#4,d2
	move.w	d2,d3
l011e	subq.w	#1,d3
l011f	lsr.w	#1,d1
	roxr.b	#1,d7
	dbcs	d3,l011f
	bcc.s	l0120
	move.b	d7,(a5)+
	moveq	#$80,d7
	dbf	d3,l011f
l0120	rts

l0121	dcb.w	3
l0122	dcb.w	2
	dc.b	0,'@',2,0,6,0,$10,0
	dc.b	'(',0,'`',0
l0123	dc.b	$e0,0,0,8,0,9,0,$b
	dc.b	0,$c,0,$d,0,$e,0,$f
	dc.b	0,$10
l0124	lea	l0203(pc),a2
	move.b	1(a2),(a5)+
	move.b	(a2),(a5)+
	move.b	d4,(a5)+
	move.b	l0208(pc),d0
	beq.s	l0125
	bsr.s	l0129
	bra.s	l0127
l0125	lea	l01fe(pc),a1
	moveq	#$f,d0
l0126	move.b	-(a1),(a5)+
	dbf	d0,l0126
	bsr.s	l0128
l0127	move.b	l020a(pc),d0
	beq.s	l0129
	move.b	l01fb(pc),d0
	add.b	d0,d0
	addq.b	#1,d0
	move.b	d0,(a5)+
l0128	lsr.b	#1,d7
	bset	#7,d7
	bra.s	l012a
l0129	lsr.b	#1,d7
l012a	bcc.s	l012b
	move.b	d7,(a5)+
	moveq	#$80,d7
l012b	rts

l012c	lea	32000(a0),a1
l012d	movem.w	(a0),d0-d3
	moveq	#3,d6
l012e	moveq	#3,d5
l012f	add.w	d0,d0
	addx.w	d4,d4
	add.w	d1,d1
	addx.w	d4,d4
	add.w	d2,d2
	addx.w	d4,d4
	add.w	d3,d3
	addx.w	d4,d4
	dbf	d5,l012f
	move.w	d4,(a0)+
	dbf	d6,l012e
	cmpa.l	a0,a1
	bne.s	l012d
	rts

l0130	move.w	#4,-(a7)
	trap	#$e
	addq.w	#2,a7
	move.b	l0132(pc,d0.w),d0
	lea	l0211(pc),a0
	lea	l0213(pc),a1
	move.w	#$95,d1
l0131	movea.l	a1,a2
	adda.w	(a0)+,a2
	add.b	d0,(a2)
	dbf	d1,l0131
	rts

l0132	move.l	l027e(pc),d3
l0133	movem.l	d0-d1,-(a7)
	lea	l0248(pc),a0
	bsr	l003c
	movem.l	(a7)+,d0-d1
	bsr.s	l0134
	move.w	d1,d2
	bsr	l0037
	move.w	d3,d1
	bsr	l0077
	lea	l0249(pc),a0
	bsr	l003c
	rts

l0134	bsr.s	l0135
	divu	d0,d1
	swap	d1
	mulu	#$64,d1
	divu	d0,d1
	ext.l	d1
	rts

l0135	moveq	#0,d2
	not.w	d2
l0136	cmp.l	d2,d0
	bgt.s	l0137
	cmp.l	d2,d1
	ble.s	l0138
l0137	lsr.l	#1,d0
	lsr.l	#1,d1
	bra.s	l0136
l0138	rts

l0139	movem.l	a0-a5/d0-d2,-(a7)
	clr.w	l020b
	lea	l0241(pc),a0
	bsr	l003c
	movea.l	12(a7),a0
	lea	l0141(pc),a1
	moveq	#0,d0
	moveq	#$7f,d1
l013a	move.l	d0,(a1)+
	move.l	d0,(a1)+
	dbf	d1,l013a
	lea	32767(a0),a2
	cmpa.l	l020f(pc),a2
	ble.s	l013b
	movea.l	l020f(pc),a2
	move.w	#$601e,l00ce
l013b	movea.l	a0,a1
	lea	l0141(pc),a3
l013c	moveq	#0,d0
	move.b	(a1)+,d0
	add.w	d0,d0
	addq.w	#1,0(a3,d0.w)
	cmpa.l	a1,a2
	bgt.s	l013c
	move.w	#$ff,d1
	moveq	#0,d0
	lea	l027f(pc),a4
	lea	l0140(pc),a6
	movea.l	a4,a5
	moveq	#0,d0
l013d	adda.l	d0,a5
	move.w	(a3)+,d0
	move.l	a5,(a6)+
	add.w	d0,d0
	dbf	d1,l013d
	lea	l0142(pc),a4
	movea.l	a0,a1
	moveq	#0,d1
l013e	moveq	#0,d0
	move.b	(a1)+,d0
	move.l	a1,d2
	add.w	d0,d0
	movea.l	a4,a5
	adda.w	d0,a5
	move.w	(a5),d1
	addq.w	#2,(a5)
	add.w	d0,d0
	movea.l	l0140(pc,d0.w),a5
	adda.l	d1,a5
	sub.l	a0,d2
	move.w	d2,(a5)
	cmpa.l	a1,a2
	bgt.s	l013e
	movea.l	a2,a6
	lea	l0142(pc),a3
	moveq	#$7f,d0
	moveq	#0,d1
l013f	move.l	d1,(a3)+
	dbf	d0,l013f
	lea	l021a(pc),a0
	bsr	l003c
	lea	l0247(pc),a0
	bsr	l003c
	movem.l	(a7)+,a0-a5/d0-d2
	rts

l0140	dcb.w	512
l0141	dcb.w	256
l0142	dcb.w	256
l0143	movea.l	a0,a3
l0144	move.l	(a1)+,(a3)+
	move.l	(a1)+,(a3)+
	cmpa.l	a1,a2
	bgt.s	l0144
	movem.l	a0-a6/d1-d7,-(a7)
	link	a2,#$ffe4
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	movea.l	a5,a4
	lea	4096(a4),a5
	subq.w	#8,a4
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	clr.w	-2(a2)
	move.b	l0277(pc),d0
	bne.s	l0145
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	suba.w	d0,a4
l0145	sf	l0277
	pea	(a4)
	pea	(a5)
	move.b	-(a6),d7
	bra	l0166
l0146	move.w	d3,d5
l0147	add.b	d7,d7
l0148	dbcs	d5,l0147
	beq.s	l014b
	bcc.s	l0149
	sub.w	d3,d5
	neg.w	d5
	bra.s	l014e
l0149	moveq	#3,d6
	bsr.s	l0154
	beq.s	l014a
	bra.s	l014d
l014a	moveq	#7,d6
	bsr.s	l0154
	beq.s	l014c
	addi.w	#$f,d5
	bra.s	l014d
l014b	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l0148
l014c	moveq	#$d,d6
	bsr.s	l0154
	addi.w	#$10e,d5
l014d	add.w	d3,d5
l014e	lea	l0170(pc),a4
	move.w	d5,d2
	bne.s	l0158
	add.b	d7,d7
	bne.s	l014f
	move.b	-(a6),d7
	addx.b	d7,d7
l014f	bcs.s	l0150
	moveq	#1,d6
	bra.s	l0159
l0150	moveq	#3,d6
	bsr.s	l0154
	tst.b	-28(a2)
	beq.s	l0151
	move.b	-18(a2,d5.w),-(a5)
	bra	l0164
l0151	move.b	(a5),d0
	btst	#3,d5
	bne.s	l0152
	bra.s	l0153
l0152	addi.b	#$f0,d5
l0153	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l0164
l0154	clr.w	d5
l0155	add.b	d7,d7
	beq.s	l0157
l0156	addx.w	d5,d5
	dbf	d6,l0155
	tst.w	d5
	rts

l0157	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l0156
l0158	moveq	#2,d6
l0159	bsr.s	l0154
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	l015a
	addq.w	#4,d6
	bra.s	l015e
l015a	bsr.s	l0154
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l0154
	cmp.b	#7,d5
	blt.s	l015c
	moveq	#0,d6
	bsr.s	l0154
	beq.s	l015b
	moveq	#2,d6
	bsr.s	l0154
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l015f
l015b	or.b	-26(a2),d1
	bra.s	l015d
l015c	or.b	-25(a2,d5.w),d1
l015d	move.w	d1,d5
	bra.s	l015f
l015e	bsr.s	l0154
l015f	add.w	d4,d4
	beq.s	l0160
	add.w	-2(a4,d4.w),d5
l0160	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l0161	move.b	-(a4),-(a5)
	dbf	d2,l0161
	bra.s	l0164
l0162	add.b	d7,d7
	bne.s	l0163
	move.b	-(a6),d7
	addx.b	d7,d7
l0163	bcs.s	l016e
	move.b	-(a6),-(a5)
l0164	cmpa.l	a5,a3
l0165	bne.s	l0162
	cmpa.l	a6,a0
	beq.s	l016f
l0166	moveq	#0,d6
	bsr	l0154
	beq.s	l0169
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l0167	cmp.b	d0,d1
	bne.s	l0168
	addq.w	#2,d1
l0168	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l0167
	st	-27(a2)
	bra.s	l016a
l0169	sf	-27(a2)
l016a	moveq	#0,d6
	bsr	l0154
	beq.s	l016c
	lea	-18(a2),a1
	moveq	#$f,d0
l016b	move.b	-(a6),(a1)+
	dbf	d0,l016b
	st	-28(a2)
	bra.s	l016d
l016c	sf	-28(a2)
l016d	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l0162
l016e	bra	l0146
l016f	movea.l	(a7)+,a0
	pea	(a2)
	bsr.s	l0171
	movea.l	(a7)+,a2
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	bsr.s	l0177
	unlk	a2
	move.l	d1,d0
	movem.l	(a7)+,a0-a6/d1-d7
	rts

l0170	dc.b	0,' ',0,'`',1,'`',3,'`'
	dc.b	7,'`',$f,'`',$1f,'`',0,1
	dc.b	3,4,5,6,7,8
l0171	move.w	-2(a2),d7
l0172	dbf	d7,l0173
	rts

l0173	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
	lea	32000(a1),a2
l0174	moveq	#3,d6
l0175	move.w	(a1)+,d0
	moveq	#3,d5
l0176	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l0176
	dbf	d6,l0175
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	l0174
	bra.s	l0172
l0177	lsr.l	#4,d0
	subq.w	#8,a6
	sub.l	a6,d1
l0178	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,l0178
	rts

l0179	dc.b	'`',$1a
l017a	dcb.w	4
l017b	dcb.w	8
	dc.b	$ff,$ff
l017c	move.w	#2,-(a7)
	trap	#$e
	movea.l	d0,a0
	move.w	#$17d,d0
l017d	clr.l	(a0)+
	dbf	d0,l017d
	move.w	#4,(a7)
	trap	#$e
	tst.b	d0
	lea	l01ba(pc),a0
	beq.s	l017e
	move.b	#$39,3(a0)
l017e	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#8,a7
	lea	l01bb(pc),a0
	move.l	(a0)+,d0
	bsr	l0187
	movea.l	a5,a3
	lea	l0165(pc),a6
	move.l	2(a3),d0
	add.l	6(a3),d0
	add.l	14(a3),d0
	lea	28(a3,d0.l),a0
	move.l	8(a6),d0
	lea	28(a3),a3
	lea	16(a0),a4
	tst.l	(a0)
	beq.s	l0182
	adda.l	(a0)+,a3
	moveq	#0,d1
l017f	add.l	d0,(a3)
l0180	clr.b	-1(a0)
	move.b	(a0)+,d1
	beq.s	l0182
	cmp.b	#1,d1
	bne.s	l0181
	lea	254(a3),a3
	bra.s	l0180
l0181	adda.w	d1,a3
	bra.s	l017f
l0182	lea	2(a5),a3
	addq.w	#8,a6
	movea.l	(a6)+,a2
	move.l	(a3),(a6)+
	move.l	(a3),d6
	adda.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	add.l	(a3),d6
	adda.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	lea	l0184(pc),a1
	moveq	#3,d0
	movea.l	a4,a2
l0183	move.l	(a1)+,(a4)+
	dbf	d0,l0183
	lea	l017c(pc),a3
	move.l	4(a7),d0
	lea	28(a5),a5
	jmp	(a2)
l0184	movea.l	a3,a4
l0185	move.l	(a5)+,(a3)+
	subq.l	#4,d6
	bcc.s	l0185
l0186	clr.l	(a2)+
	bra.s	l0186
	jmp	(a4)
l0187	move.l	d0,-(a7)
	lea	4(a0,d0.l),a5
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	link	a2,#$ffe4
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	suba.w	d0,a4
	lea	2(a5),a5
l0188	equ	*-2
	pea	(a5)
	move.b	-(a6),d7
	bra	l01a8
l0189	move.w	d3,d5
l018a	add.b	d7,d7
l018b	dbcs	d5,l018a
	beq.s	l018e
	bcc.s	l018c
	sub.w	d3,d5
	neg.w	d5
	bra.s	l0191
l018c	moveq	#3,d6
	bsr.s	l0197
	beq.s	l018d
	bra.s	l0190
l018d	moveq	#7,d6
	bsr.s	l0197
	beq.s	l018f
	addi.w	#$f,d5
	bra.s	l0190
l018e	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l018b
l018f	moveq	#$d,d6
	bsr.s	l0197
	addi.w	#$10e,d5
l0190	add.w	d3,d5
l0191	lea	l01b3(pc),a4
	move.w	d5,d2
	bne.s	l019b
	add.b	d7,d7
	bne.s	l0192
	move.b	-(a6),d7
	addx.b	d7,d7
l0192	bcs.s	l0193
	moveq	#1,d6
	bra.s	l019c
l0193	moveq	#3,d6
	bsr.s	l0197
	tst.b	-28(a2)
	beq.s	l0194
	move.b	-18(a2,d5.w),-(a5)
	bra	l01a7
l0194	move.b	(a5),d0
	btst	#3,d5
	bne.s	l0195
	bra.s	l0196
l0195	addi.b	#$f0,d5
l0196	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l01a7
l0197	clr.w	d5
l0198	add.b	d7,d7
	beq.s	l019a
l0199	addx.w	d5,d5
	dbf	d6,l0198
	tst.w	d5
	rts

l019a	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l0199
l019b	moveq	#2,d6
l019c	bsr.s	l0197
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	l019d
	addq.w	#4,d6
	bra.s	l01a1
l019d	bsr.s	l0197
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l0197
	cmp.b	#7,d5
	blt.s	l019f
	moveq	#0,d6
	bsr.s	l0197
	beq.s	l019e
	moveq	#2,d6
	bsr.s	l0197
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l01a2
l019e	or.b	-26(a2),d1
	bra.s	l01a0
l019f	or.b	-25(a2,d5.w),d1
l01a0	move.w	d1,d5
	bra.s	l01a2
l01a1	bsr.s	l0197
l01a2	add.w	d4,d4
	beq.s	l01a3
	add.w	-2(a4,d4.w),d5
l01a3	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l01a4	move.b	-(a4),-(a5)
	dbf	d2,l01a4
	bra.s	l01a7
l01a5	add.b	d7,d7
	bne.s	l01a6
	move.b	-(a6),d7
	addx.b	d7,d7
l01a6	bcs.s	l01b1
	move.b	-(a6),-(a5)
l01a7	cmpa.l	a5,a3
	bne.s	l01a5
	cmpa.l	a6,a0
	beq.s	l01b2
l01a8	moveq	#0,d6
	bsr	l0197
	beq.s	l01ac
	move.b	-(a6),d0
	lea	-26(a2),a1
l01a9	equ	*-2
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l01aa	cmp.b	d0,d1
	bne.s	l01ab
	addq.w	#2,d1
l01ab	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l01aa
	st	-27(a2)
	bra.s	l01ad
l01ac	sf	-27(a2)
l01ad	moveq	#0,d6
	bsr	l0197
	beq.s	l01af
	lea	-18(a2),a1
	moveq	#$f,d0
l01ae	move.b	-(a6),(a1)+
	dbf	d0,l01ae
	st	-28(a2)
	bra.s	l01b0
l01af	sf	-28(a2)
l01b0	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l01a5
l01b1	bra	l0189
l01b2	movea.l	(a7)+,a0
	bsr.s	l01b4
	dc.b	'NZ,',$1f,'Nu'
l01b3	dc.b	0,' ',0,'`',1,'`',3,'`'
	dc.b	7,'`',$f,'`',$1f,'`',0,1
	dc.b	3,4,5,6,7,8
l01b4	move.w	-2(a2),d7
l01b5	dbf	d7,l01b6
	rts

l01b6	movea.l	a5,a1
	adda.l	-(a0),a1
	move.w	#$1f3f,d0
	lea	32000(a1),a3
l01b7	moveq	#3,d6
l01b8	move.w	(a1)+,d0
	moveq	#3,d5
l01b9	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l01b9
	dbf	d6,l01b8
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a3
	bne.s	l01b7
	bra.s	l01b5
l01ba	dc.b	$1b,'Y %ATOM'
	dc.b	'IK v3.5 '
	dc.b	'by ALTAI'
	dc.b	'R VMAX/M'
	dc.b	'CS'
l01bb	dc.b	0,' ',0,'@',1,0,2,0
	dc.b	4,0,8,0,$10,0,' ',0
l01bc	dc.b	'`',$1a
l01bd	dcb.w	4
l01be	dcb.w	8
	dc.b	$ff,$ff
l01bf	move.w	#2,-(a7)
	trap	#$e
	movea.l	d0,a0
	move.w	#$17d,d0
l01c0	clr.l	(a0)+
	dbf	d0,l01c0
	move.w	#4,(a7)
	trap	#$e
	tst.b	d0
	lea	l01f6(pc),a0
	beq.s	l01c1
	move.b	#$39,3(a0)
l01c1	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#8,a7
	lea	l01f7(pc),a0
	move.l	(a0)+,d0
	bsr	l01ca
	movea.l	a5,a3
	lea	l01a9(pc),a6
	move.l	2(a3),d0
	add.l	6(a3),d0
	add.l	14(a3),d0
	lea	28(a3,d0.l),a0
	move.l	8(a6),d0
	lea	28(a3),a3
	lea	16(a0),a4
	tst.l	(a0)
	beq.s	l01c5
	adda.l	(a0)+,a3
	moveq	#0,d1
l01c2	add.l	d0,(a3)
l01c3	clr.b	-1(a0)
	move.b	(a0)+,d1
	beq.s	l01c5
	cmp.b	#1,d1
	bne.s	l01c4
	lea	254(a3),a3
	bra.s	l01c3
l01c4	adda.w	d1,a3
	bra.s	l01c2
l01c5	lea	2(a5),a3
	addq.w	#8,a6
	movea.l	(a6)+,a2
	move.l	(a3),(a6)+
	move.l	(a3),d6
	adda.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	add.l	(a3),d6
	adda.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	lea	l01c7(pc),a1
	moveq	#3,d0
	movea.l	a4,a2
l01c6	move.l	(a1)+,(a4)+
	dbf	d0,l01c6
	lea	l01bf(pc),a3
	move.l	4(a7),d0
	lea	28(a5),a5
	jmp	(a2)
l01c7	movea.l	a3,a4
l01c8	move.l	(a5)+,(a3)+
	subq.l	#4,d6
	bcc.s	l01c8
l01c9	clr.l	(a2)+
	bra.s	l01c9
	nop		clr.l	(a2)+
	jmp	(a4)
l01ca	move.l	d0,-(a7)
	lea	4(a0,d0.l),a5
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	link	a2,#$ffe6
	lea	2(a5),a5
l01cb	equ	*-2
	move.b	-(a6),d7
	bra	l01eb
l01cc	move.w	d3,d5
l01cd	add.b	d7,d7
l01ce	dbcs	d5,l01cd
	beq.s	l01d1
	bcc.s	l01cf
	sub.w	d3,d5
	neg.w	d5
	bra.s	l01d4
l01cf	moveq	#3,d6
	bsr.s	l01da
	beq.s	l01d0
	bra.s	l01d3
l01d0	moveq	#7,d6
	bsr.s	l01da
	beq.s	l01d2
	addi.w	#$f,d5
	bra.s	l01d3
l01d1	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l01ce
l01d2	moveq	#$d,d6
	bsr.s	l01da
	addi.w	#$10e,d5
l01d3	add.w	d3,d5
l01d4	lea	l01f5(pc),a4
	move.w	d5,d2
	bne.s	l01de
	add.b	d7,d7
	bne.s	l01d5
	move.b	-(a6),d7
	addx.b	d7,d7
l01d5	bcs.s	l01d6
	moveq	#1,d6
	bra.s	l01df
l01d6	moveq	#3,d6
	bsr.s	l01da
	tst.b	-26(a2)
	beq.s	l01d7
	move.b	-16(a2,d5.w),-(a5)
	bra	l01ea
l01d7	move.b	(a5),d0
	btst	#3,d5
	bne.s	l01d8
	bra.s	l01d9
l01d8	addi.b	#$f0,d5
l01d9	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l01ea
l01da	clr.w	d5
l01db	add.b	d7,d7
	beq.s	l01dd
l01dc	addx.w	d5,d5
	dbf	d6,l01db
	tst.w	d5
	rts

l01dd	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l01dc
l01de	moveq	#2,d6
l01df	bsr.s	l01da
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-25(a2)
	bne.s	l01e0
	addq.w	#4,d6
	bra.s	l01e4
l01e0	bsr.s	l01da
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l01da
	cmp.b	#7,d5
	blt.s	l01e2
	moveq	#0,d6
	bsr.s	l01da
	beq.s	l01e1
	moveq	#2,d6
	bsr.s	l01da
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l01e5
l01e1	or.b	-24(a2),d1
	bra.s	l01e3
l01e2	or.b	-23(a2,d5.w),d1
l01e3	move.w	d1,d5
	bra.s	l01e5
l01e4	bsr.s	l01da
l01e5	add.w	d4,d4
	beq.s	l01e6
	add.w	-2(a4,d4.w),d5
l01e6	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l01e7	move.b	-(a4),-(a5)
	dbf	d2,l01e7
	bra.s	l01ea
l01e8	add.b	d7,d7
	bne.s	l01e9
	move.b	-(a6),d7
	addx.b	d7,d7
l01e9	bcs.s	l01f3
	move.b	-(a6),-(a5)
l01ea	cmpa.l	a5,a3
	bne.s	l01e8
	cmpa.l	a6,a0
	beq.s	l01f4
l01eb	moveq	#0,d6
	bsr	l01da
	beq.s	l01ee
	move.b	-(a6),d0
	lea	-24(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l01ec	cmp.b	d0,d1
	bne.s	l01ed
	addq.w	#2,d1
l01ed	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l01ec
	st	-25(a2)
	bra.s	l01ef
l01ee	sf	-25(a2)
l01ef	moveq	#0,d6
	bsr	l01da
	beq.s	l01f1
	lea	-16(a2),a1
	moveq	#$f,d0
l01f0	move.b	-(a6),(a1)+
	dbf	d0,l01f0
	st	-26(a2)
	bra.s	l01f2
l01f1	sf	-26(a2)
l01f2	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l01e8
l01f3	bra	l01cc
l01f4	unlk	a2
	move.l	(a7)+,d6
	rts

l01f5	dc.b	0,' ',0,'`',1,'`',3,'`'
	dc.b	7,'`',$f,'`',$1f,'`',0,1
	dc.b	3,4,5,6,7,8
l01f6	dc.b	$1b,'Y %ATOM'
	dc.b	'IK v3.5 '
	dc.b	'by ALTAI'
	dc.b	'R VMAX/M'
	dc.b	'CS'
l01f7	dc.b	0,0
l01f8	dcb.w	15
l01f9	dcb.w	8
l01fa	dcb.w	3
	dc.b	0
l01fb	dc.b	0,0,0,0,0,0,0,0,0
	dcb.w	4
l01fc	dcb.w	256
l01fd	dcb.w	8
l01fe	dc.b	0,0
l01ff	dcb.w	256
l0200	dcb.w	256
l0201	dc.b	0,0
l0202	dcb.w	3
l0203	dc.b	0,0
l0204	dc.b	0,0
l0205	dc.b	0,0
l0206	dc.b	0
l0207	dc.b	0
l0208	dc.b	0
l0209	dc.b	0
l020a	dc.b	0,0
l020b	dc.b	0,0
l020c	dc.b	0,0
l020d	dcb.w	2
l020e	dcb.w	2
l020f	dcb.w	2
l0210	dcb.w	2
l0211	dc.b	0,3,0,'#',0,'C',0,'c'
	dc.b	0,$a4,0,$c4,0,$e4,1,3
	dc.b	2,$98,2,$b6,2,$d2,3,'@'
	dc.b	3,$d1,$17,$9d,3,$f0,4,$e
	dc.b	9,'s',0,$84,2,'z',2,$ef
	dc.b	3,$a,3,' ',3,'c',3,'{'
	dc.b	3,$98,3,$b2,4,'-',4,'I'
	dc.b	4,'c',7,$d8,7,$14,7,'4'
	dc.b	7,'F',7,'X',7,'j',7,'}'
	dc.b	8,'j',8,$9a,9,'3',7,$aa
	dc.b	8,$b4,8,$f0,9,$13,8,$89
	dc.b	9,'S',$17,'q',9,'z',7,$c1
	dc.b	1,'A',$10,'i',$10,$96,$10,$c3
	dc.b	$16,$ea,$10,$f0,$11,$1e,$11,'L'
	dc.b	$11,'z',$11,$a9,$11,$d1,$11,$fa
	dc.b	$12,'#',$12,'N',$12,'x',$12,$a3
	dc.b	$12,$ce,$12,$f6,1,'`',$13,'"'
	dc.b	$13,'N',$13,'z',$13,$a6,$13,$d2
	dc.b	$13,$fe,$14,'*',$14,'V',$14,$82
	dc.b	$14,$ae,$14,$da,$15,6,$15,'2'
	dc.b	$15,'^',$15,$8a,$15,$b6,$15,$e2
	dc.b	$16,$e,$16,':',$16,'f',$16,$92
	dc.b	$16,$be,$17,$19,$17,'E',$17,$c9
	dc.b	$17,$f5,$1b,$94,$18,'!',$18,'M'
	dc.b	$18,'y',$18,$a5,$18,$d1,$18,$fd
	dc.b	$19,')',$19,'U',$19,$81,$19,$ad
	dc.b	$19,$d9,$1a,5,$1a,'1',$1a,']'
	dc.b	$1a,$89,$1a,$b5,$1d,$fc,7,$a3
	dc.b	$1b,$c0,$1b,$ec,$1c,$18,$1c,'D'
	dc.b	$1c,'p',$1c,$9c,$1c,$c8,$1c,$f4
	dc.b	$1d,' ',$1d,'L',$1d,'x',$1d,$a4
	dc.b	$1d,$d0,$1e,'(',$1e,'T',$1e,$ac
	dc.b	$1b,$10,$1b,'<',$1b,'h',$1a,$e1
	dc.b	$1e,$80,$1e,$d8,4,'}',4,$96
	dc.b	1,'"',1,$80,1,$9f,1,$be
	dc.b	1,$dd,7,$f6,8,$12,8,'>'
	dc.b	7,$91,8,$d0,1,$fd,2,$1c
	dc.b	2,';',2,'Z'
l0212	dc.b	$1b,'E'
l0213	dc.b	$1b,'Y ',0,'****'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	$1b,'Y!',0,'*ATO'
	dc.b	'MIK CRUN'
	dc.b	'CHER3 BY'
	dc.b	' ALTAIR*'
	dc.b	$1b,'Y"',0,'*v3.'
	dc.b	'5 comple'
	dc.b	'ted on: '
	dc.b	'27/1/92*'
	dc.b	$1b,'Y#',0,'****'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	0
l0214	dc.b	$1b,'Y%',0,'F1: C'
	dc.b	'RUNCH EX'
	dc.b	'ECUTABLE'
	dc.b	' |TOTAL',$1b
	dc.b	'Y&',0,'F2: C'
	dc.b	'RUNCH DA'
	dc.b	'TA FILE.'
	dc.b	' |ERROR',$1b
	dc.b	'Y',$27,0,'F3: C'
	dc.b	'RUNCH AL'
	dc.b	'L FILES.'
	dc.b	' |FREE!',$1b
	dc.b	'Y)',0,'F4: C'
	dc.b	'RUNCH PA'
	dc.b	'RAMETERS'
	dc.b	' |VMAX',$1b,'Y'
	dc.b	'*',0,'F5: EX'
	dc.b	'IT FROM '
	dc.b	'ATOMIK. '
	dc.b	'|&MCS',$1b,'Y,'
	dc.b	0,'F6: UNP'
	dc.b	'ACKER PR'
	dc.b	'OGRAM. |'
	dc.b	'UNPK',$1b,'Y.',0
	dc.b	'F7: BUSI'
	dc.b	'NESS SEC'
	dc.b	'TION. |P'
	dc.b	'UB!',$1b,'Y/',0,'F'
	dc.b	'8: GREET'
	dc.b	'ING SECT'
	dc.b	'ION. |MO'
	dc.b	'A!',0
l0215	dc.b	$1b,'Y%',0,'F1: U'
	dc.b	'NPACK EX'
	dc.b	'ECUTABLE'
	dc.b	' |EXEC',$1b,'Y'
	dc.b	'&',0,'F2: UN'
	dc.b	'PACK DAT'
	dc.b	'A FILE. '
	dc.b	'|DATA',$1b,'Y('
	dc.b	0,'F3: UNP'
	dc.b	'ACK ALL '
	dc.b	'FILES. |'
	dc.b	'ALL!',$1b,'Y*',0
	dc.b	'F4: EXIT'
	dc.b	' FROM UN'
	dc.b	'PACK. |Q'
	dc.b	'UIT',0
l0216	dc.b	$1b,'Y%',0,'F1: '
	dc.b	'UNPACK A'
	dc.b	'LL IN EX'
	dc.b	'EC MODE',$1b
	dc.b	'Y&',0,'F2: U'
	dc.b	'NPACK AL'
	dc.b	'L IN DAT'
	dc.b	'A MODE',$1b,'Y'
	dc.b	'(',0,'F3: SE'
	dc.b	'T DIR TO'
	dc.b	' BE UNPA'
	dc.b	'CKED.',$1b,'Y)'
	dc.b	0,'F4: EXI'
	dc.b	'T FROM M'
	dc.b	'ULTI UNP'
	dc.b	'ACK.',0
l0217	dc.b	$1b,'Y%',0,'F1: E'
	dc.b	'XTENDS F'
	dc.b	'OR PARAM'
	dc.b	'ETERS',$1b,'Y&'
	dc.b	0,'F2: SET'
	dc.b	' PICTURE'
	dc.b	' PARAMET'
	dc.b	'ERS',$1b,'Y(',0,'F'
	dc.b	'3: CLEAR'
	dc.b	' ALL PAR'
	dc.b	'AMETERS',$1b
	dc.b	'Y)',0,'F4: E'
	dc.b	'XIT FROM'
	dc.b	' PARAMET'
	dc.b	'ERS',0
l0218	dc.b	$1b,'Y+',0,'ENTE'
	dc.b	'R PICTUR'
	dc.b	'E NUMBER'
	dc.b	': ',0
l0219	dc.b	$1b,'Y-',0,'ENTER'
	dc.b	' OFFSET '
	dc.b	'N.'
l021a	dc.b	$1b,'K',0
l021b	dc.b	$1b,'Y%',0,'PICTU'
	dc.b	'RE PARAM'
	dc.b	'ETERS N.'
	dc.b	0
l021c	dc.b	' BAD',$a,$d,$1b,'Y',$27
	dc.b	0,'OFFSET '
	dc.b	'+ 7D00 >'
	dc.b	' FILE LE'
	dc.b	'NGHT',0
l021d	dc.b	': ',0
l021e	dc.b	$1b,'Y*',0,'ENCO'
	dc.b	'DING PIC'
	dc.b	'TURE N.',0
l021f	dc.b	$1b,'Y*',0,'CLEA'
	dc.b	'R PARAME'
	dc.b	'TERS? (Y'
	dc.b	'/N) ',0
l0220	dc.b	$1b,'Y*',0,'PARAM'
	dc.b	'ETERS CL'
	dc.b	'EARED!',$1b,'K'
	dc.b	0
l0221	dc.b	$1b,'Y%',0,'F1: C'
	dc.b	'RUNCH AL'
	dc.b	'L IN EXE'
	dc.b	'C MODE',$1b,'Y'
	dc.b	'&',0,'F2: CR'
	dc.b	'UNCH ALL'
	dc.b	' IN DATA'
	dc.b	' MODE',$1b,'Y('
	dc.b	0,'F3: SET'
	dc.b	' DIR TO '
	dc.b	'BE CRUNC'
	dc.b	'HED',$1b,'Y)',0,'F'
	dc.b	'4: EXIT '
	dc.b	'FROM MUL'
	dc.b	'TI CRUNC'
	dc.b	'H',0
l0222	dc.b	$1b,'Y+',0,'HEY!'
	dc.b	' EMPTY D'
	dc.b	'IRECTORY'
	dc.b	'!',$1b,'K',0
l0223	dc.b	$1b,'Y)',0,'OK ',0
l0224	dc.b	' FILE(S)'
	dc.b	' PACKED',$1b
	dc.b	'K',0
l0225	dc.b	$1b,'Y*',0,'IN ',0
l0226	dc.b	' FILE(S)'
	dc.b	' LOADED',$1b
	dc.b	'K',0
l0227	dc.b	$1b,'Y.',0,'TOTA'
	dc.b	'L PACKED'
	dc.b	' LENGHT '
	dc.b	0
l0228	dc.b	$1b,'Y.',0,'TOTAL'
	dc.b	' PACKED '
	dc.b	'LENGHT ('
	dc.b	'100%) SH'
	dc.b	'EAT!',0
l0229	dc.b	' FILE(S) '
	dc.b	'UNPACKED'
	dc.b	$1b,'K',0
l022a	dc.b	'extends f'
	dc.b	'or use.',$d
	dc.b	$a,$a,'for be'
	dc.b	'st pictu'
	dc.b	're crunc'
	dc.b	'h i use '
	dc.b	'a specia'
	dc.b	'l bits p'
	dc.b	'lanes al'
	dc.b	'gorythm',$d
	dc.b	$a,'but i c'
	dc.b	'annot de'
	dc.b	'tect pic'
	dc.b	'ture ver'
	dc.b	'y well w'
	dc.b	'ithout m'
	dc.b	'ake many'
	dc.b	' analyse'
	dc.b	$d,$a,'and te'
	dc.b	'st and i'
	dc.b	't',$27,'s bett'
	dc.b	'er if yo'
	dc.b	'u give m'
	dc.b	'e the fi'
	dc.b	'rst word'
	dc.b	' picture'
	dc.b	$d,$a,'offset'
	dc.b	' from th'
	dc.b	'e top of'
	dc.b	' the fil'
	dc.b	'e',$d,$a,$a,'CAUT'
	dc.b	'ION !',$d,$a,$a
	dc.b	'the offs'
	dc.b	'et you g'
	dc.b	'ive me m'
	dc.b	'ust be t'
	dc.b	'he first'
	dc.b	' plane p'
	dc.b	'icture',$d,$a
	dc.b	'and not '
	dc.b	'the firs'
	dc.b	't word p'
	dc.b	'icture f'
	dc.b	'ile.',$d,$a,$a,'e'
	dc.b	'xemple:',$d
	dc.b	$a,$a,'for a '
	dc.b	'degelite'
	dc.b	' picture'
	dc.b	' format '
	dc.b	'you must'
	dc.b	' give me'
	dc.b	' the pic'
	dc.b	'ture fil'
	dc.b	'e',$d,$a,'offse'
	dc.b	't increa'
	dc.b	'sed of $'
	dc.b	'22 (i ju'
	dc.b	'st encod'
	dc.b	'e $7d00 '
	dc.b	'bytes',$d,$a,'t'
	dc.b	'he exact'
	dc.b	' picture'
	dc.b	' screen '
	dc.b	'lenght.)'
	dc.b	$d,$a,$a,'CAUTI'
	dc.b	'ON!: off'
	dc.b	'set in H'
	dc.b	'ex,pictu'
	dc.b	're numbe'
	dc.b	'r in Dec'
	dc.b	'.',0
l022b	dc.b	$1b,'Eout of'
	dc.b	' memory!'
	dc.b	0
l022c	dc.b	$1b,'Y%',0,'SORRY'
	dc.b	' CANNOT '
	dc.b	'CRUNCH..'
	dc.b	$1b,'K',$d,$a,$1b,'K',0
l022d	dc.b	$1b,'Y%',0,'CRUNC'
	dc.b	'HING  : '
	dc.b	0
l022e	dc.b	$1b,'Y',$27,0,'CRUNC'
	dc.b	'H LEFT: '
	dc.b	0
l022f	dc.b	$1b,'Y(',0,'CRUNC'
	dc.b	'H DONE: '
	dc.b	0
l0230	dc.b	$1b,'Y)',0,'SAVE '
	dc.b	'LENGHT: '
	dc.b	' ',0
l0231	dc.b	$1b,'Y-',0,'FILE'
	dc.b	': ',0
l0232	dc.b	' SAVED',$1b,'K',0
l0233	dc.b	$1b,'Y%',0,'UNPA'
	dc.b	'CKING  :'
	dc.b	' ',0
l0234	dc.b	$1b,'Y+',0,$1b,'K',0
l0235	dc.b	$1b,'Y+',0,'DECRU'
	dc.b	'NCH SPAC'
	dc.b	'E = $',0
l0236	dc.b	$1b,'Y,',0,'DECR'
	dc.b	'UNCH SPA'
	dc.b	'CE = $',0
l0237	dc.b	$1b,'Y%',0,'FREE '
	dc.b	'MEMORY <'
	dc.b	' LENGHT '
	dc.b	'FILE',0
l0238	dc.b	$1b,'Y%',0,'NOT A'
	dc.b	'N EXECUT'
	dc.b	'ABLE FIL'
	dc.b	'E!',0
l0239	dc.b	$1b,'Y%',0,'THIS '
	dc.b	'IS NOT A'
	dc.b	'N ATOMIK'
	dc.b	' V3.5 PA'
	dc.b	'CKED FIL'
	dc.b	'E!',0
l023a	dc.b	$1b,'Y%',0,'NOT E'
	dc.b	'NOUGHT M'
	dc.b	'EMORY TO'
	dc.b	' UNPACK '
	dc.b	'THIS FIL'
	dc.b	'E!',0
l023b	dc.b	$1b,'Y.',0,'WRITE'
	dc.b	' ERROR! '
	dc.b	'RETRY (Y'
	dc.b	'/N)',$1b,'K',0
l023c	dc.b	$1b,'Y%',0,'READ'
	dc.b	' ERROR! '
	dc.b	0
l023d	dc.b	$1b,'Y',$27,0,'CRUNC'
	dc.b	'HING TIM'
	dc.b	'E:    ',$1b,'K'
	dc.b	0
l023e	dc.b	$1b,'Y-',0,'SAVE '
	dc.b	'PACK FIL'
	dc.b	'E? (Y/N)'
	dc.b	$1b,'K',0
l023f	dc.b	$1b,'Y-',0,'SAVE '
	dc.b	'UNPACKED'
	dc.b	' FILE? ('
	dc.b	'Y/N)',$1b,'K',0
l0240	dc.b	$1b,'Y',$27,0,'    I'
	dc.b	'NTERUPTI'
	dc.b	'ON? (Y/N'
	dc.b	')',$1b,'K',$d,$a,$1b,'K',$1b
	dc.b	'I',0
l0241	dc.b	$1b,'Y*',0,'ANAL'
	dc.b	'YSING DA'
	dc.b	'TA STRUC'
	dc.b	'TURE',$1b,'K',$d,0
l0242	dc.b	$1b,'Y*',0,'HUFF'
	dc.b	'MAN DATA'
	dc.b	' PACK SY'
	dc.b	'STEM.',$1b,'K',0
l0243	dc.b	$1b,'Y*',0,'RELA'
	dc.b	'TIF DATA'
	dc.b	' PACK SY'
	dc.b	'STEM.',$1b,'K',0
l0244	dc.b	$1b,'Y(',0,$1b,'K',0
l0245	dc.b	$1b,'Y*',0,$1b,'K',0
l0246	dc.b	$d,$a,$d,$a,0
l0247	dc.b	$1b,'I',$1b,'I',0
l0248	dc.b	' (',0
l0249	dc.b	'%)',0,8,8,8,8,8,8
	dc.b	8,8,8,0,8,' ',8,8
	dc.b	' ',8,8,' ',8,8,' ',8
	dc.b	8,' ',8,8,' ',8,8,' '
	dc.b	8,8,' ',8
l024a	dc.b	8,' ',8,0
l024b	dc.b	7,0
l024c	dc.b	$1b,'q',$1b,'E',$d,$a,$a,' '
	dc.b	'   ',$1b,'p---'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'--------'
	dc.b	'-----',$1b,'q',$d
	dc.b	$a,'    ',$1b,'p*'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*** MESS'
	dc.b	'AGE INSO'
	dc.b	'LITE ***'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*******',$1b
	dc.b	'q',$d,$a,'    ',$1b
	dc.b	'p',$9c,$1b,'q    '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'  ',$1b,'p',$9c,$1b,'q',$d
	dc.b	$a,'    ',$1b,'p',$9c
	dc.b	$1b,'q La F',$82
	dc.b	'd',$82,'ration'
	dc.b	' Nationa'
	dc.b	'le de Yo'
	dc.b	'ga Tradi'
	dc.b	'tionnel '
	dc.b	'(F.N.Y.T'
	dc.b	'.) dont '
	dc.b	'        '
	dc.b	$1b,'p',$9c,$1b,'q',$d,$a,' '
	dc.b	'   ',$1b,'p',$9c,$1b,'q'
	dc.b	' SWAMI N'
	dc.b	'ATARAJAN'
	dc.b	'ANDA SAR'
	dc.b	'ASWATI e'
	dc.b	'st l',$27,'aut'
	dc.b	'orit',$82,' mo'
	dc.b	'rale et '
	dc.b	'spiritue'
	dc.b	'lle,  ',$1b,'p'
	dc.b	$9c,$1b,'q',$d,$a,'   '
	dc.b	' ',$1b,'p',$9c,$1b,'q a'
	dc.b	' pour bu'
	dc.b	'ts de ma'
	dc.b	'intenir '
	dc.b	'la p',$82,'ren'
	dc.b	'nit',$82,' du '
	dc.b	'Yoga Aut'
	dc.b	'hentique'
	dc.b	', d',$27,'en  '
	dc.b	'    ',$1b,'p',$9c,$1b
	dc.b	'q',$d,$a,'    ',$1b
	dc.b	'p',$9c,$1b,'q per'
	dc.b	'p',$82,'tuer l'
	dc.b	'a puret',$82
	dc.b	', d',$27,'en f'
	dc.b	'aire con'
	dc.b	'naitre l'
	dc.b	$27,'Univers'
	dc.b	'alit',$82,', d'
	dc.b	$27,'en     '
	dc.b	'  ',$1b,'p',$9c,$1b,'q',$d
	dc.b	$a,'    ',$1b,'p',$9c
	dc.b	$1b,'q propa'
	dc.b	'ger la v'
	dc.b	'raie sci'
	dc.b	'ence sou'
	dc.b	's l',$27,'uniq'
	dc.b	'ue r',$82,'f',$82,'r'
	dc.b	'ence ',$85,' l'
	dc.b	'a V',$82,'rit',$82
	dc.b	',       '
	dc.b	$1b,'p',$9c,$1b,'q',$d,$a,' '
	dc.b	'   ',$1b,'p',$9c,$1b,'q'
	dc.b	' d',$27,$b4,'uvre'
	dc.b	'r sous s'
	dc.b	'on ',$82,'clai'
	dc.b	'rage ',$82,'co'
	dc.b	'logique '
	dc.b	'et ',$82,'thiq'
	dc.b	'ue pour '
	dc.b	'le perfe'
	dc.b	'ction-',$1b,'p'
	dc.b	$9c,$1b,'q',$d,$a,'   '
	dc.b	' ',$1b,'p',$9c,$1b,'q n'
	dc.b	'ement ma'
	dc.b	't',$82,'riel, '
	dc.b	'corporel'
	dc.b	', intell'
	dc.b	'ectuel e'
	dc.b	't spirit'
	dc.b	'uel de l'
	dc.b	$27,'Humanit'
	dc.b	$82,',  ',$1b,'p',$9c,$1b
	dc.b	'q',$d,$a,'    ',$1b
	dc.b	'p',$9c,$1b,'q de '
	dc.b	'former d'
	dc.b	'es ensei'
	dc.b	'gnants d'
	dc.b	'e Yoga s'
	dc.b	'elon les'
	dc.b	' crit',$8a,'re'
	dc.b	's de com'
	dc.b	'p',$82,'tence,'
	dc.b	'  ',$1b,'p',$9c,$1b,'q',$d
	dc.b	$a,'    ',$1b,'p',$9c
	dc.b	$1b,'q moral'
	dc.b	'it',$82,' et s'
	dc.b	'piritual'
	dc.b	'it',$82,' auth'
	dc.b	'entique.'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	$1b,'p',$9c,$1b,'q',$d,$a,' '
	dc.b	'   ',$1b,'p',$9c,$1b,'q'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'      ',$1b,'p'
	dc.b	$9c,$1b,'q',$d,$a,'   '
	dc.b	' ',$1b,'p',$9c,$1b,'q L'
	dc.b	'a d',$82,'marc'
	dc.b	'he de SW'
	dc.b	'AMI NATA'
	dc.b	'RAJANAND'
	dc.b	'A SARASV'
	dc.b	'ATI et, '
	dc.b	'par suit'
	dc.b	'e, de la'
	dc.b	'    ',$1b,'p',$9c,$1b
	dc.b	'q',$d,$a,'    ',$1b
	dc.b	'p',$9c,$1b,'q F',$82,'d'
	dc.b	$82,'ration '
	dc.b	'National'
	dc.b	'e de Yog'
	dc.b	'a Tradit'
	dc.b	'ionnel e'
	dc.b	'st d',$27,$b5,'uv'
	dc.b	'rer pour'
	dc.b	' le     '
	dc.b	'  ',$1b,'p',$9c,$1b,'q',$d
	dc.b	$a,'    ',$1b,'p',$9c
	dc.b	$1b,'q bonhe'
	dc.b	'ur de l',$27
	dc.b	'Homme et'
	dc.b	' de l',$27,'Hu'
	dc.b	'manit',$82,' a'
	dc.b	'fin que '
	dc.b	'r',$8a,'gnent:'
	dc.b	' Harmoni'
	dc.b	'e,      '
	dc.b	$1b,'p',$9c,$1b,'q',$d,$a,' '
	dc.b	'   ',$1b,'p',$9c,$1b,'q'
	dc.b	' Concord'
	dc.b	'e et Amo'
	dc.b	'ur vrai.'
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'      ',$1b,'p'
	dc.b	$9c,$1b,'q',$d,$a,'   '
	dc.b	' ',$1b,'p',$9c,$1b,'q  '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'        '
	dc.b	'    ',$1b,'p',$9c,$1b
	dc.b	'q',$d,$a,'    ',$1b
	dc.b	'p  Parta'
	dc.b	'gez-vous'
	dc.b	' cette a'
	dc.b	'mbition?'
	dc.b	'   Pour '
	dc.b	'tous ren'
	dc.b	'seigneme'
	dc.b	'nts, con'
	dc.b	'tactez: '
	dc.b	' ',$d,$a,$1b,'q   '
	dc.b	' ',$1b,'p  F.N'
	dc.b	'.Y.T. Le'
	dc.b	's Isni',$8a,'r'
	dc.b	'es St An'
	dc.b	'dr',$82,' de R'
	dc.b	'osans 05'
	dc.b	'150 ROSA'
	dc.b	'NS.Tel:9'
	dc.b	'2 66 63 '
	dc.b	'16 ',$1b,'q',0
l024d	dc.b	$1b,'E',$1b,'Y ',$fa,'AT'
	dc.b	'OMIK IS '
	dc.b	'ACTUALLY'
	dc.b	' THE BES'
	dc.b	'T COMPRE'
	dc.b	'SSION',$d,$a,$1b
	dc.b	'Y!',$fa,'SYSTE'
	dc.b	'M EVER C'
	dc.b	'ODED ON '
	dc.b	'ANY COMP'
	dc.b	'UTER AND'
	dc.b	' I',$d,$a,$1b,'Y"',$fa
	dc.b	'THINK TH'
	dc.b	'AT I HAV'
	dc.b	'E REACHE'
	dc.b	'D THE LI'
	dc.b	'MITS OF',$d
	dc.b	$a,$1b,'Y#',$fa,'THE'
	dc.b	' STO PAC'
	dc.b	'K SYSTEM'
	dc.b	' BUT NOW'
	dc.b	' I AM WO'
	dc.b	'RKING',$d,$a,$1b
	dc.b	'Y$',$fa,'ON A '
	dc.b	'PACKER W'
	dc.b	'ICH WILL'
	dc.b	' BE CALL'
	dc.b	'ED ATM V'
	dc.b	'4.0',$d,$a,$1b,'Y&'
	dc.b	$fa,'THIS WI'
	dc.b	'LL BE A '
	dc.b	'PROFESSI'
	dc.b	'ONAL PRO'
	dc.b	'DUCT WIT'
	dc.b	'H',$d,$a,$1b,'Y',$27,$fa,'M'
	dc.b	'ANY MORE'
	dc.b	' OPTIONS'
	dc.b	' THAN AT'
	dc.b	'OMIK V3.'
	dc.b	'5 LIKE:',$d
	dc.b	$a,$a,$1b,'Y)',$fa,'1:'
	dc.b	' TOTAL H'
	dc.b	'ARD DISK'
	dc.b	' ARCHIVE'
	dc.b	'R WITH D'
	dc.b	'IR',$1b,'Y+',$fa,'2:'
	dc.b	' TRACKER'
	dc.b	'S MODULE'
	dc.b	'S COMPRE'
	dc.b	'SSER ~(5'
	dc.b	'0%)',$1b,'Y-',$fa,'3'
	dc.b	': MULTI '
	dc.b	'DEPACKER'
	dc.b	' (ICE,JA'
	dc.b	'M,POMPEY'
	dc.b	'...)',$1b,'Y/',$fa
	dc.b	'4: AUTOM'
	dc.b	'ATIC OTH'
	dc.b	'ER PACKE'
	dc.b	'R DECOMP'
	dc.b	'RESSING',$1b
	dc.b	'Y0',$fa,'   AN'
	dc.b	'D NEW CO'
	dc.b	'MPRESSIN'
	dc.b	'G WITH A'
	dc.b	'TOMIK 4.'
	dc.b	'0',$1b,'Y2',$fa,'5: '
	dc.b	'IT WILL '
	dc.b	'BE MORE '
	dc.b	'BETTER T'
	dc.b	'HAN ATM '
	dc.b	'3.5!',$1b,'Y4',$fa
	dc.b	'6: IT WI'
	dc.b	'LL BE CO'
	dc.b	'MMERCIAL'
	dc.b	'ISED IN '
	dc.b	'FRANCE,',$1b
	dc.b	'Y5',$fa,'   EN'
	dc.b	'GLAND,DU'
	dc.b	'TCHLAND,'
	dc.b	'FOR ~130'
	dc.b	' Fr TTC',$1b
	dc.b	'Y9',$fa,'   ED'
	dc.b	'ITED BY '
	dc.b	'THUNDERS'
	dc.b	'OFT Deve'
	dc.b	'llopment'
	dc.b	0
l024e	dc.b	$1b,'E',$1b,'Y ',$fa,'...'
	dc.b	'........'
	dc.b	'........'
	dc.b	'........'
	dc.b	'........'
	dc.b	'.....',$1b,'Y!'
	dc.b	$fa,'*******'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*',$1b,'Y"',$fa,'***'
	dc.b	'***** GR'
	dc.b	'EETINGS '
	dc.b	'ARE SENT'
	dc.b	' TO: ***'
	dc.b	'*****',$1b,'Y#'
	dc.b	$fa,'*******'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*',$1b,'Y%',$fa,'ALL'
	dc.b	' VMAX ME'
	dc.b	'MBERS: T'
	dc.b	'ST D0,CO'
	dc.b	'MTE ZERO'
	dc.b	',BVCA',$1b,'Y&'
	dc.b	$fa,'ROBOCAM'
	dc.b	'P,MIKOU,'
	dc.b	'ICE,FRA,'
	dc.b	'ME,ALL M'
	dc.b	'EMBERS O'
	dc.b	'F',$1b,'Y',$27,$fa,'MCS'
	dc.b	'... SORR'
	dc.b	'Y BUT I '
	dc.b	'DONT REM'
	dc.b	'ENBER AL'
	dc.b	'L THE',$1b,'Y('
	dc.b	$fa,'ALLIAS '
	dc.b	'NAMES.. '
	dc.b	'I TRY TO'
	dc.b	' MENSION'
	dc.b	' ALL THA'
	dc.b	'T',$1b,'Y)',$fa,'I R'
	dc.b	'EMENBERS'
	dc.b	': MAGNUM'
	dc.b	'...,GADG'
	dc.b	'ET...HEU'
	dc.b	'..(?)',$1b,'Y*'
	dc.b	$fa,'AXEL FO'
	dc.b	'LLET,...'
	dc.b	'?,ZORGLU'
	dc.b	'B...??.('
	dc.b	'?),ME (!'
	dc.b	')',$1b,'Y+',$fa,'BLO'
	dc.b	'NDIN (CA'
	dc.b	'NNOT REM'
	dc.b	'ENBER...'
	dc.b	'),HEY BL'
	dc.b	'ONDIN',$1b,'Y,'
	dc.b	$fa,'KEEP ON'
	dc.b	'LY THE G'
	dc.b	'OOD LIVE'
	dc.b	' SIDE...'
	dc.b	'...,AND '
	dc.b	'I',$1b,'Y-',$fa,'AM '
	dc.b	'REALLY R'
	dc.b	'EALLY SO'
	dc.b	'RRY FOR '
	dc.b	'ALL THE '
	dc.b	'MCS..',$1b,'Y.'
	dc.b	$fa,'MEMBERS'
	dc.b	' I HAVE '
	dc.b	'FORGOTTE'
	dc.b	'N...,TRI'
	dc.b	'O (ALONE'
	dc.b	')',$1b,'Y/',$fa,'BUS'
	dc.b	'HWAKERS '
	dc.b	'(THE SER'
	dc.b	'GENT),AL'
	dc.b	'L MEMBER'
	dc.b	'S OF.',$1b,'Y0'
	dc.b	$fa,'THE WHI'
	dc.b	'TE SHADO'
	dc.b	'W (GREAT'
	dc.b	' CODING.'
	dc.b	'..),XANT'
	dc.b	'A',$1b,'Y1',$fa,'DR '
	dc.b	'CLONE,TH'
	dc.b	'E GERMAN'
	dc.b	' ALLIANC'
	dc.b	'E,APA,AC'
	dc.b	'F,TBC',$1b,'Y2'
	dc.b	$fa,'THE COC'
	dc.b	'A COLA C'
	dc.b	'OMPANY,T'
	dc.b	'NT-CREW,'
	dc.b	'42-CREW.'
	dc.b	'.',$1b,'Y3',$fa,'EQU'
	dc.b	'INOX (GR'
	dc.b	'EAT DEMO'
	dc.b	'),LIGHTI'
	dc.b	'NGS,D.M.'
	dc.b	'A,XTC',$1b,'Y4'
	dc.b	$fa,'THE CAR'
	dc.b	'EBEARS,T'
	dc.b	'HE LOST '
	dc.b	'BOYS,EMP'
	dc.b	'IRE (...'
	dc.b	')',$1b,'Y5',$fa,'THE'
	dc.b	' REPLICA'
	dc.b	'NTS (!!!'
	dc.b	'),THE MA'
	dc.b	'STERS (?'
	dc.b	'??)..',$1b,'Y6'
	dc.b	$fa,'ARE YOU'
	dc.b	' STILL A'
	dc.b	'LIVE AFT'
	dc.b	'ER I QUI'
	dc.b	'TTED YOU'
	dc.b	'?',$1b,'Y8',$fa,'***'
	dc.b	'* PRESS '
	dc.b	'A KEY TO'
	dc.b	' SEE NEX'
	dc.b	'T GREETS'
	dc.b	' ****',0
l024f	dc.b	$1b,'E',$1b,'Y ',$fa,'**'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'******',$1b,'Y'
	dc.b	'!',$fa,'* WELC'
	dc.b	'OME TO T'
	dc.b	'HE 2ND G'
	dc.b	'REETINGS'
	dc.b	' SECTION'
	dc.b	' *',$1b,'Y"',$fa,'**'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'******',$1b,'Y'
	dc.b	'$',$fa,'THE OV'
	dc.b	'ERLANDER'
	dc.b	'S !! (ES'
	dc.b	'PECIALLY'
	dc.b	' TYPHON '
	dc.b	'&.',$1b,'Y%',$fa,'SP'
	dc.b	'EEDLIGHT'
	dc.b	'),M-CODE'
	dc.b	'R,HYSTER'
	dc.b	'IA (ESPC'
	dc.b	' BVCA.',$1b,'Y'
	dc.b	'&',$fa,'CAPTAI'
	dc.b	'N BUG AN'
	dc.b	'D ARCONI'
	dc.b	'X),ZOOL,'
	dc.b	'ZUUL,ZER'
	dc.b	',.',$1b,'Y',$27,$fa,'FA'
	dc.b	'NATIC (B'
	dc.b	'ETTLEGUE'
	dc.b	'SE),TANK'
	dc.b	'ARD,TECH'
	dc.b	'NICS,.',$1b,'Y'
	dc.b	'(',$fa,'THE FO'
	dc.b	'LLOWINGS'
	dc.b	' CREWS A'
	dc.b	'RE GOOD '
	dc.b	'COMPACTE'
	dc.b	'R.',$1b,'Y)',$fa,'MA'
	dc.b	'KERS TEX'
	dc.b	' (ONE OF'
	dc.b	' THE FIR'
	dc.b	'ST WHO C'
	dc.b	'ODED A',$1b,'Y'
	dc.b	'*',$fa,'STO GO'
	dc.b	'OD PACKI'
	dc.b	'NG SYSTE'
	dc.b	'M ON THE'
	dc.b	' ATARI S'
	dc.b	'T)',$1b,'Y+',$fa,'AX'
	dc.b	'E,AT THE'
	dc.b	' START H'
	dc.b	'E JUST U'
	dc.b	'SE AUTOM'
	dc.b	'ATION.',$1b,'Y'
	dc.b	',',$fa,'ALGORY'
	dc.b	'THM BUT '
	dc.b	'HE LURN '
	dc.b	'COMPACTO'
	dc.b	'R CODING'
	dc.b	'..',$1b,'Y-',$fa,'AN'
	dc.b	'D NOW HE'
	dc.b	' IS GOOD'
	dc.b	' IN COMP'
	dc.b	'ACTOR CO'
	dc.b	'DING..',$1b,'Y'
	dc.b	'.',$fa,'THE ME'
	dc.b	'DWAY BOY'
	dc.b	'S (HARD '
	dc.b	'TO FOUND'
	dc.b	' THEIR',$27,'S'
	dc.b	'..',$1b,'Y/',$fa,'PA'
	dc.b	'CKERS!! '
	dc.b	'NOT SWAP'
	dc.b	'PED!!),P'
	dc.b	'OMPEY PI'
	dc.b	'RATES.',$1b,'Y'
	dc.b	'0',$fa,'(GOOD '
	dc.b	'PACKERS '
	dc.b	'TOO),AUT'
	dc.b	'OMATION '
	dc.b	'(GOOD OL'
	dc.b	'D.',$1b,'Y1',$fa,'AU'
	dc.b	'TOMATION'
	dc.b	' PACKERS'
	dc.b	'...),A.C'
	dc.b	'.A (I TE'
	dc.b	'STED..',$1b,'Y'
	dc.b	'2',$fa,'THE CO'
	dc.b	'MPRESSIO'
	dc.b	'N QUALIT'
	dc.b	'Y WITH Y'
	dc.b	'OUR XENO'
	dc.b	'N2',$1b,'Y3',$fa,'CR'
	dc.b	'ACKED VE'
	dc.b	'RSION) I'
	dc.b	'T',$27,'S ACTU'
	dc.b	'ALLY VER'
	dc.b	'Y OLD.',$1b,'Y'
	dc.b	'4',$fa,'BUT TH'
	dc.b	'E IDEA W'
	dc.b	'AS NOT B'
	dc.b	'AD AT AL'
	dc.b	'L. IT WA'
	dc.b	'S.',$1b,'Y5',$fa,'TH'
	dc.b	'E BEST O'
	dc.b	'NE TWO Y'
	dc.b	'EARS AGO'
	dc.b	'...,FMCC'
	dc.b	' (ESPC',$1b,'Y'
	dc.b	'6',$fa,'CRYSTA'
	dc.b	'L,KILLER'
	dc.b	'-D),ELDA'
	dc.b	'R,NEXT ('
	dc.b	'LEM,MYTH'
	dc.b	'),',$1b,'Y8',$fa,'**'
	dc.b	'** PRESS'
	dc.b	' A KEY T'
	dc.b	'O SEE NE'
	dc.b	'XT GREET'
	dc.b	'S ****',0
l0250	dc.b	$1b,'E',$1b,'Y ',$fa,'***'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*****',$1b,'Y!'
	dc.b	$fa,'* WELCO'
	dc.b	'ME TO TH'
	dc.b	'E 3TH GR'
	dc.b	'EETINGS '
	dc.b	'SECTION '
	dc.b	'*',$1b,'Y"',$fa,'***'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*****',$1b,'Y$'
	dc.b	$fa,'ST-MAD2'
	dc.b	',ETERNAL'
	dc.b	',DELTA-F'
	dc.b	',TANGOLI'
	dc.b	'MA 67,DO'
	dc.b	'M',$1b,'Y%',$fa,'GIG'
	dc.b	'ABYTE-CR'
	dc.b	'EW,FOXX,'
	dc.b	'MARTIN B'
	dc.b	'ACKSHAT,'
	dc.b	'M.A.R',$1b,'Y&'
	dc.b	$fa,'.K.U.S '
	dc.b	'(GOOD GF'
	dc.b	'A PROTEC'
	dc.b	'T BUT NO'
	dc.b	'T GOOD A'
	dc.b	'S',$1b,'Y',$27,$fa,'MY '
	dc.b	'SYNC PRO'
	dc.b	'TECT...)'
	dc.b	',FOXX (I'
	dc.b	' DONT KN'
	dc.b	'OW IF',$1b,'Y('
	dc.b	$fa,'THE RAS'
	dc.b	'TERS WIC'
	dc.b	'H APPEAR'
	dc.b	' BEFORE '
	dc.b	'YOUR DEM'
	dc.b	'O',$1b,'Y)',$fa,'ARE'
	dc.b	' AN UNPA'
	dc.b	'CKER OR '
	dc.b	'AN UNCOD'
	dc.b	'ER.),TNT'
	dc.b	'-CREW',$1b,'Y*'
	dc.b	$fa,'(ONE OF'
	dc.b	' THE FIR'
	dc.b	'ST 3D RO'
	dc.b	'UT CODER'
	dc.b	' CREW BU'
	dc.b	'T',$1b,'Y+',$fa,'NOW'
	dc.b	' YOUR RO'
	dc.b	'UTS ARE '
	dc.b	'BEATED B'
	dc.b	'Y THE GR'
	dc.b	'EATS.',$1b,'Y,'
	dc.b	$fa,'ICC II '
	dc.b	'NICK',$27,'S 3'
	dc.b	'D ROUTS '
	dc.b	'HAHAHA.)'
	dc.b	',I FORGO'
	dc.b	'T',$1b,'Y-',$fa,'THE'
	dc.b	' CRUSADE'
	dc.b	'RS.. ARE'
	dc.b	' YOU STI'
	dc.b	'LL ALIVE'
	dc.b	' TOO?',$1b,'Y.'
	dc.b	$fa,'ROXR (T'
	dc.b	'HE SKWEE'
	dc.b	'K & SUPE'
	dc.b	'R SKWEEK'
	dc.b	' AUTHOR.'
	dc.b	')',$1b,'Y/',$fa,'EXP'
	dc.b	'RESS IN '
	dc.b	'GAP,LAUR'
	dc.b	'ENT IN G'
	dc.b	'RENOBLE,'
	dc.b	'KENT.',$1b,'Y0'
	dc.b	$fa,'INNER C'
	dc.b	'IRCLE,M.'
	dc.b	'C.A,NO-C'
	dc.b	'REW,NORD'
	dc.b	'IK CODER'
	dc.b	'S',$1b,'Y1',$fa,'S.T'
	dc.b	'.C.S,THE'
	dc.b	' RESPECT'
	dc.b	'ABLES (G'
	dc.b	'OOD SCRE'
	dc.b	'ENS).',$1b,'Y2'
	dc.b	$fa,'NAOS,CH'
	dc.b	'AOS COMP'
	dc.b	'UTER CLU'
	dc.b	'B,ULM,MI'
	dc.b	'LAN BEDO'
	dc.b	'V',$1b,'Y3',$fa,'CEN'
	dc.b	'TURY,SUN'
	dc.b	'DANCE,LO'
	dc.b	'OK,MASTE'
	dc.b	'R-GIN,XA'
	dc.b	'NAX..',$1b,'Y4'
	dc.b	$fa,'AND A B'
	dc.b	'IG HELLO'
	dc.b	' TO ALL '
	dc.b	'THE FORG'
	dc.b	'OTEN GUY'
	dc.b	'S',$1b,'Y6',$fa,'***'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*****',$1b,'Y7'
	dc.b	$fa,'***** E'
	dc.b	'ND OF TH'
	dc.b	'E GREETI'
	dc.b	'NGS SECT'
	dc.b	'ION ****'
	dc.b	'*',$1b,'Y8',$fa,'***'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'********'
	dc.b	'*****',0
l0251	dc.b	'*.PRG',0
l0252	dc.b	'*.*',0
l0253	dc.l	l0254
	dc.l	l0255
	dc.l	l0256
	dc.l	l0257
	dc.l	l0259
	dc.l	l025a
l0254	dc.b	0,'Z',0,0,0,2,0,2
l0255	dc.b	1,' ',0,1
l0256	dc.b	0,0
l0257	dc.b	0,1
l0258	dcb.w	2
l0259	dc.l	l025b
	dc.l	l025c
l025a	dc.b	0,0
l025b	dcb.w	39
	dc.b	0
l025c	dc.b	0,0,0,0,0,0,0,0,0
	dcb.w	28
l025d	dcb.w	33
l025e	dcb.w	13
l025f	dcb.w	2
l0260	dcb.w	7
l0261	dc.b	0,0
l0262	dc.b	0,0
l0263	dc.b	0,0
l0264	dcb.w	2
l0265	dcb.w	2
l0266	dcb.w	2
l0267	dcb.w	2
l0268	dcb.w	2
l0269	dcb.w	2
l026a	dcb.w	2
l026b	dcb.w	2
l026c	dcb.w	2
l026d	dcb.w	2
l026e	dcb.w	2
l026f	dcb.w	2
l0270	dcb.w	6
l0271	dcb.w	2
l0272	dcb.w	100
l0273	dc.b	0
l0274	dc.b	0
l0275	dc.b	0
l0276	dc.b	0
l0277	dc.b	0
l0278	dc.b	0
l0279	dc.b	0,0
l027a	dc.b	0,0
l027b	dc.b	0,0
l027c	dc.b	' '
l027d	dc.b	0,0,0,0,0,0,0,0,0
	bss
	ds.b	58
l027e	ds.b	222
l027f	ds.b	65536
zuend	end
