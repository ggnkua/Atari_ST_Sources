	text
begin
	move.l	#black,-(a7)
	move.w	#6,-(a7)		;setpallete
	trap	#$e
	adda.l	#6,a7
	movea.l	4(a7),a3
	movea.l	#mystack,a7
	move.l	12(a3),d0
	add.l	20(a3),d0
	add.l	28(a3),d0
	addi.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)		;mshrink
	trap	#1
	adda.l	#$c,a7
	move.l	#$33450,-(a7)
	move.w	#$48,-(a7)		;malloc
	trap	#1
	addq.l	#6,a7
	addi.l	#$2710,d0
	move.w	#3,-(a7)
	move.w	#$4b,-(a7)		;pexec
	trap	#1
	adda.l	#$e,a7
	addi.l	#$100,d0
	lea	picname,a4
	move.w	#2,-(a7)		;physbase
	trap	#$e
	adda.l	#2,a7
	movea.l	d0,a5
	suba.l	#$22,a5
	movea.l	#$7d64,a6
	bsr	open
	adda.l	#2,a5
	move.l	a5,-(a7)
	move.w	#6,-(a7)		;setpallete
	trap	#$e
	adda.l	#6,a7
	move.w	#$25,-(a7)		;vsync
	trap	#$e
	adda.l	#2,a7
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldstk
	move.l	$70.w,oldint
	bclr	#0,$484.w
	moveq	#1,d0
	bsr	music
	move.l	#zippy,$70.w
	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	move.l	oldstk,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	clr.w	-(a7)
	pea	$5000.l
	move.w	#$31,-(a7)		;ptermres
	trap	#1
zippy	movem.l	a0-a6/d0-d7,-(a7)
	bsr	l0008
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	oldint,-(a7)
	rts

oldstk	dcb.w	2
oldint	dcb.w	2
	move.w	#0,-(a7)
	move.w	#$4b,-(a7)		;pexec
	trap	#1
	addi.l	#$c,-(a7)
	move.w	#$ff,-(a7)
	move.w	#$4c,-(a7)		;pterm
	trap	#1
open	clr.w	-(a7)
	move.l	a4,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bmi	diskerr
	move.w	d0,-(a7)
	move.l	a5,-(a7)
	move.l	a6,-(a7)
	move.w	d0,-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	adda.w	#$c,a7
	move.l	d0,d7
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
	move.l	d7,d0
	tst.l	d0
diskerr	rts

black	dcb.w	16
picname	dc.b	'a:\progr'
	dc.b	'am.dat',0,0
music	bra	l0009
	bra	l000a
l0008	bra	l0010
	move.l	a0,-(a7)
	andi.b	#$1f,d0
	lea	l005f(pc),a0
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	#0,(a0)+
	movea.l	(a7)+,a0
	rts

l0009	movem.l	a0-a6/d0-d7,-(a7)
	bsr.s	l000c
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l000a	movem.l	a0-a6/d0-d7,-(a7)
	bsr.s	l000b
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l000b	lea	l0063(pc),a0
	bsr.s	l000e
	movea.l	l0061(pc),a1
	andi.l	#$ff,d0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a1
	lea	l005b(pc),a6
	move.w	(a1)+,(a6)
	move.w	(a1)+,d0
	andi.l	#$ff,d0
	bsr	l0046
	rts

l000c	lea	l0063(pc),a0
	bsr.s	l000e
	tst.w	d0
	beq.s	l000d
	movea.l	l0060(pc),a1
	andi.l	#$ff,d0
	subq.l	#1,d0
	mulu	#6,d0
	adda.w	d0,a1
	move.w	(a1)+,d0
	move.w	(a1)+,d1
	lea	l004c(pc),a6
	move.w	(a1),(a6)+
	move.w	(a1)+,(a6)+
	bsr	l0043
	rts

l000d	lea	l004d(pc),a0
	move.w	#1,(a0)
	bsr	l0010
	rts

l000e	move.w	l0062(pc),d7
	bne	l000f
	moveq	#0,d7
	lea	l0055(pc),a1
	move.w	#$40,(a1)
	lea	l0064(pc),a1
	lea	l0057(pc),a2
	move.l	a1,(a2)
	lea	l0065(pc),a1
	lea	l0058(pc),a2
	move.l	a1,(a2)
	lea	l0066(pc),a1
	lea	l0056(pc),a2
	move.l	a1,(a2)
	lea	l0067(pc),a1
	lea	l0059(pc),a2
	move.l	a1,(a2)
	lea	l0068(pc),a1
	lea	l0060(pc),a2
	move.l	a1,(a2)
	lea	l0069(pc),a1
	lea	l0061(pc),a2
	move.l	a1,(a2)
	lea	l0062(pc),a1
	move.w	#1,(a1)
	lea	l005c(pc),a1
	move.w	#0,(a1)
l000f	rts

l0010	lea	l005f(pc),a0
	tst.b	(a0)
	beq.s	l0012
	subq.b	#1,1(a0)
	bpl.s	l0012
	move.b	(a0),1(a0)
	addq.w	#1,2(a0)
	move.w	2(a0),d0
	cmpi.w	#$a,d0
	bne.s	l0011
	clr.l	(a0)
	lea	l004d(pc),a0
	move.w	#1,(a0)
	bra.s	l0012
l0011	lea	l005e(pc),a0
	move.b	0(a0,d0.w),d0
	lea	l004f(pc),a0
	lea	l0051(pc),a1
	lea	l0053(pc),a2
	move.b	d0,(a0)
	move.b	d0,(a1)
	move.b	d0,(a2)
l0012	lea	l004a(pc),a6
	lea	l004c(pc),a5
	tst.w	4(a5)
	beq.s	l0013
	clr.b	34(a6)
	clr.b	38(a6)
	clr.b	42(a6)
	movem.l	28(a6),d0-d3
	movem.l	d0-d3,$ffff8800.w
	rts

l0013	subq.w	#1,(a5)+
	bne.s	l0014
	move.w	(a5),-(a5)
	lea	l004e(pc),a0
	bsr	l0017
	lea	l0050(pc),a0
	bsr	l0017
	lea	l0052(pc),a0
	bsr	l0017
l0014	lea	l005a(pc),a5
	lea	l004e(pc),a0
	bsr	l001f
	move.w	d0,-(a7)
	move.b	(a7)+,6(a6)
	move.b	d0,2(a6)
	move.b	d1,34(a6)
	lea	l0050(pc),a0
	bsr	l001f
	move.w	d0,-(a7)
	move.b	(a7)+,14(a6)
	move.b	d0,10(a6)
	move.b	d1,38(a6)
	lea	l0052(pc),a0
	bsr	l001f
	move.w	d0,-(a7)
	move.b	(a7)+,22(a6)
	move.b	d0,18(a6)
	move.b	d1,42(a6)
	move.w	4(a5),d0
	beq.s	l0016
	move.w	d0,-(a7)
	lea	l0054(pc),a0
	bsr	l001f
	movea.l	10(a0),a1
	adda.l	14(a0),a1
	cmpi.b	#$e1,1(a1)
	bne.s	l0015
	clr.w	4(a5)
l0015	move.w	(a7)+,d7
	lea	l004b(pc),a1
	add.w	d7,d7
	add.w	d7,d7
	adda.w	d7,a1
	moveq	#0,d6
	move.b	(a1)+,d6
	move.w	d0,-(a7)
	move.b	d0,0(a6,d6.w)
	move.b	(a1)+,d6
	move.b	(a7)+,0(a6,d6.w)
	move.b	(a1)+,d6
	move.b	d1,0(a6,d6.w)
l0016	move.b	(a5)+,d7
	ori.b	#$c0,d7
	move.b	d7,30(a6)
	move.b	(a5)+,26(a6)
	movem.l	(a6),a0-a2/d0-d7
	movem.l	a0-a2/d0-d7,$ffff8800.w
	rts

l0017	moveq	#0,d5
	moveq	#6,d6
	move.w	l0055(pc),d7
	movea.l	34(a0),a1
	adda.l	38(a0),a1
	move.b	(a1),d0
	andi.w	#$7f,d0
	cmpi.w	#1,d0
	beq.s	l0018
	cmp.w	40(a0),d7
	bne	l001c
l0018	movea.l	52(a0),a3
	movea.l	(a0),a2
	adda.l	4(a0),a2
	cmpa.l	a3,a2
	bne.s	l0019
	move.l	d5,4(a0)
	movea.l	(a0),a2
l0019	moveq	#0,d1
	move.b	(a2),d1
	move.b	1(a2),44(a0)
	move.b	2(a2),22(a0)
	move.b	3(a2),d0
	move.b	d0,d2
	andi.w	#$f0,d2
	cmpi.b	#$f0,d2
	bne	l001a
	move.b	d0,d2
	andi.b	#$f,d2
	move.b	d2,60(a0)
	bra.s	l001b
l001a	cmpi.b	#$e0,d2
	bne.s	l001b
	move.b	d0,d2
	andi.w	#$f,d2
	move.w	d2,2(a5)
l001b	move.l	d5,38(a0)
	mulu	d7,d1
	movea.l	l0056(pc),a3
	adda.l	d1,a3
	move.l	a3,34(a0)
	addi.l	#$c,4(a0)
	movea.l	34(a0),a1
	adda.l	38(a0),a1
l001c	move.b	(a1)+,d0
	move.b	d0,d1
	andi.w	#$7f,d1
	tst.w	d1
	beq	l001e
	move.l	d5,56(a0)
	move.b	d1,8(a0)
	movea.l	a1,a3
	tst.l	38(a0)
	bne.s	l001d
	adda.w	d7,a3
l001d	move.b	-2(a3),31(a0)
	move.b	(a1),9(a0)
	tst.b	d0
	bmi.s	l001e
	move.b	(a1),d1
	andi.w	#$1f,d1
	add.b	22(a0),d1
	movea.l	l0058(pc),a2
	asl.w	d6,d1
	adda.w	d1,a2
	move.l	d5,14(a0)
	move.b	(a2),23(a0)
	move.b	(a2)+,24(a0)
	move.b	(a2)+,d1
	andi.w	#$ff,d1
	move.b	(a2)+,27(a0)
	move.b	#$40,46(a0)
	move.b	(a2)+,d0
	move.b	d0,28(a0)
	move.b	d0,29(a0)
	move.b	(a2)+,30(a0)
	move.l	a2,10(a0)
	movea.l	l0057(pc),a2
	asl.w	d6,d1
	adda.w	d1,a2
	move.l	a2,18(a0)
	move.l	d5,48(a0)
	move.b	d5,26(a0)
	move.b	d5,25(a0)
l001e	addq.l	#2,38(a0)
	rts

l001f	moveq	#0,d7
	move.b	d7,32(a0)
l0020	tst.b	26(a0)
	beq.s	l0021
	subq.b	#1,26(a0)
	bra	l002c
l0021	movea.l	18(a0),a1
	adda.l	48(a0),a1
l0022	cmpi.b	#$e1,(a1)
	beq	l002c
	cmpi.b	#$e0,(a1)
	bne.s	l0023
	move.b	1(a1),d0
	andi.l	#$3f,d0
	move.l	d0,48(a0)
	movea.l	18(a0),a1
	adda.l	d0,a1
l0023	cmpi.b	#$e2,(a1)
	bne.s	l0024
	clr.l	14(a0)
	move.b	#1,23(a0)
	addq.l	#1,48(a0)
	bra.s	l0021
l0024	cmpi.b	#$e9,(a1)
	bne	l0025
	move.b	#$b,$ffff8800.w
	move.b	1(a1),$ffff8802.w
	move.b	#$c,$ffff8800.w
	move.b	#0,$ffff8802.w
	move.b	#$d,$ffff8800.w
	move.b	#$a,$ffff8802.w
	addq.l	#2,48(a0)
	bra	l0021
l0025	cmpi.b	#$e7,(a1)
	bne.s	l0026
	move.b	1(a1),d0
	andi.w	#$ff,d0
	asl.w	#6,d0
	movea.l	l0057(pc),a1
	adda.w	d0,a1
	move.l	a1,18(a0)
	move.l	d7,48(a0)
	bra	l0022
l0026	cmpi.b	#$e8,(a1)
	bne.s	l0027
	move.b	1(a1),26(a0)
	addq.l	#2,48(a0)
	bra	l0020
l0027	cmpi.b	#$e4,(a1)
	bne.s	l0028
	move.b	d7,42(a0)
	move.b	1(a1),32(a0)
	addq.l	#2,48(a0)
	bra.s	l002b
l0028	cmpi.b	#$e5,(a1)
	bne.s	l0029
	move.b	#1,42(a0)
	addq.l	#1,48(a0)
	bra	l0020
l0029	cmpi.b	#$e6,(a1)
	bne.s	l002a
	move.b	#2,42(a0)
	addq.l	#1,48(a0)
	bra.s	l002b
l002a	cmpi.b	#$e3,(a1)
	bne.s	l002b
	addq.l	#3,48(a0)
	move.b	1(a1),27(a0)
	move.b	2(a1),28(a0)
l002b	movea.l	18(a0),a1
	adda.l	48(a0),a1
	move.b	(a1),43(a0)
	addq.l	#1,48(a0)
l002c	tst.b	25(a0)
	beq.s	l002d
	subq.b	#1,25(a0)
	bra.s	l0031
l002d	subq.b	#1,23(a0)
	bne.s	l0031
	move.b	24(a0),23(a0)
l002e	movea.l	10(a0),a1
	adda.l	14(a0),a1
	move.b	(a1),d0
	cmpi.b	#$e8,d0
	bne.s	l002f
	addq.l	#2,14(a0)
	move.b	1(a1),25(a0)
	bra.s	l002c
l002f	cmpi.b	#$e1,d0
	beq.s	l0031
	cmpi.b	#$e0,d0
	bne.s	l0030
	move.b	1(a1),d0
	andi.l	#$3f,d0
	subq.l	#5,d0
	move.l	d0,14(a0)
	bra.s	l002e
l0030	move.b	(a1),45(a0)
	addq.l	#1,14(a0)
l0031	move.b	43(a0),d0
	bmi.s	l0032
	add.b	8(a0),d0
	add.b	44(a0),d0
l0032	andi.w	#$7f,d0
	lea	l005d(pc),a1
	add.w	d0,d0
	move.w	d0,d1
	adda.w	d0,a1
	move.w	(a1),d0
	move.b	33(a0),d3
	move.b	42(a0),d2
	andi.l	#$f,d2
	bne.s	l0033
	bclr	d3,(a5)
	addq.w	#3,d3
	bclr	d3,(a5)
	bra.s	l0036
l0033	cmpi.b	#1,d2
	bne.s	l0035
	bset	d3,(a5)
	addq.w	#3,d3
	bclr	d3,(a5)
	move.b	8(a0),32(a0)
	move.b	43(a0),d4
	bpl.s	l0034
	andi.b	#$7f,d4
	move.b	d4,32(a0)
	bra.s	l0036
l0034	add.b	d4,32(a0)
	bra.s	l0036
l0035	bclr	d3,(a5)
	addq.w	#3,d3
	bset	d3,(a5)
l0036	tst.b	32(a0)
	beq.s	l0037
	move.b	32(a0),d3
	andi.b	#$1f,d3
	eori.b	#$1f,d3
	move.b	d3,1(a5)
l0037	move.b	46(a0),d7
	tst.b	30(a0)
	beq.s	l0038
	subq.b	#1,30(a0)
	bra.s	l0040
l0038	move.b	d1,d5
	move.b	28(a0),d4
	add.b	d4,d4
	move.b	29(a0),d1
	tst.b	d7
	bpl.s	l0039
	btst	#0,d7
	bne.s	l003c
l0039	btst	#5,d7
	bne.s	l003a
	sub.b	27(a0),d1
	bcc.s	l003b
	bset	#5,d7
	moveq	#0,d1
	bra.s	l003b
l003a	add.b	27(a0),d1
	cmp.b	d4,d1
	bcs.s	l003b
	bclr	#5,d7
	move.b	d4,d1
l003b	move.b	d1,29(a0)
l003c	lsr.b	#1,d4
	sub.b	d4,d1
	bcc.s	l003d
	subi.w	#$100,d1
l003d	addi.b	#$a0,d5
	bcs.s	l003f
l003e	add.w	d1,d1
	addi.b	#$18,d5
	bcc.s	l003e
l003f	add.w	d1,d0
l0040	eori.b	#1,d7
	move.b	d7,46(a0)
	btst	#5,9(a0)
	beq	l0041
	moveq	#0,d7
	move.w	d7,d1
	move.b	31(a0),d1
	ext.w	d1
	move.l	56(a0),d2
	moveq	#$c,d3
	asl.l	d3,d1
	add.l	d1,d2
	move.l	d2,56(a0)
	swap	d2
	sub.w	d2,d0
l0041	move.b	45(a0),d1
	sub.b	60(a0),d1
	bpl.s	l0042
	moveq	#0,d1
l0042	rts

l0043	lea	l005f(pc),a0
	clr.l	(a0)
	move.l	d0,d7
	mulu	#$c,d7
	move.l	d1,d6
	addq.l	#1,d6
	mulu	#$c,d6
	moveq	#2,d0
	lea	l004e(pc),a0
	lea	l0048(pc),a1
	lea	l0049(pc),a2
l0044	move.l	a1,10(a0)
	clr.l	14(a0)
	move.b	#0,45(a0)
	clr.b	8(a0)
	clr.b	9(a0)
	move.l	a1,18(a0)
	clr.l	48(a0)
	move.b	#1,23(a0)
	move.b	#1,24(a0)
	clr.b	25(a0)
	clr.b	26(a0)
	clr.b	27(a0)
	clr.b	28(a0)
	clr.b	29(a0)
	clr.w	30(a0)
	clr.b	32(a0)
	move.b	(a2),d3
	andi.l	#$f,d3
	add.w	d3,d3
	add.w	d3,d3
	move.b	(a2)+,33(a0)
	move.l	l0059(pc),(a0)
	move.l	l0059(pc),52(a0)
	add.l	d6,52(a0)
	add.l	d3,52(a0)
	add.l	d7,(a0)
	add.l	d3,(a0)
	move.l	#$c,4(a0)
	movea.l	(a0),a3
	move.b	(a3),d1
	andi.l	#$ff,d1
	move.w	l0055(pc),d2
	mulu	d1,d2
	movea.l	l0056(pc),a4
	adda.l	d2,a4
	move.l	a4,34(a0)
	clr.l	38(a0)
	move.b	#2,42(a0)
	move.b	1(a3),44(a0)
	clr.b	43(a0)
	move.b	2(a3),22(a0)
	clr.b	60(a0)
	move.b	3(a3),d1
	andi.w	#$f0,d1
	cmpi.w	#$f0,d1
	bne	l0045
	move.b	3(a3),d1
	andi.b	#$f,d1
	move.b	d1,60(a0)
l0045	clr.b	45(a0)
	clr.w	56(a0)
	adda.l	#$3e,a0
	dbf	d0,l0044
	lea	l004c(pc),a0
	move.w	2(a0),(a0)
	clr.w	4(a0)
	rts

l0046	move.w	l005b(pc),d2
	move.w	l005c(pc),d1
	tst.w	d2
	beq	l0047
	lea	l0054(pc),a0
	lea	l005a(pc),a5
	move.b	d2,8(a0)
	move.b	d1,33(a0)
	clr.b	22(a0)
	moveq	#6,d6
	moveq	#0,d5
	andi.w	#$1f,d0
	movea.l	l0058(pc),a2
	asl.w	d6,d0
	adda.w	d0,a2
	move.l	d5,14(a0)
	move.b	(a2),23(a0)
	move.b	(a2)+,24(a0)
	move.b	(a2)+,d0
	andi.w	#$ff,d0
	move.b	(a2)+,27(a0)
	moveq	#0,d2
	move.b	#$40,46(a0)
	move.b	(a2)+,d2
	move.b	d2,28(a0)
	move.b	d2,29(a0)
	move.b	(a2)+,30(a0)
	move.l	a2,10(a0)
	movea.l	l0057(pc),a2
	asl.w	d6,d0
	adda.w	d0,a2
	move.l	a2,18(a0)
	move.l	d5,48(a0)
	clr.b	25(a0)
	clr.b	26(a0)
	addq.w	#1,d1
	move.w	d1,4(a5)
l0047	rts

	dcb.w	2
l0048	dc.b	1,0,0,0,0,0,0,$e1
l0049	dc.b	0,1,2,0
l004a	dc.b	0,0,$f4,0,1,1,3,0
	dc.b	2,2,$e8,0,3,3,7,0
	dc.b	4,4,$ee,0,5,5,$e,0
	dc.b	6,6,$c,0,7,7,$f8,$ff
	dc.b	8,8,$f,0,9,9,$d,0
	dc.b	$a,$a,0,0
l004b	dcb.w	2
	dc.b	2,6,'"',0,$a,$e,'&',0
	dc.b	$12,$16,'*',0
l004c	dc.b	0,2,0,3
l004d	dc.b	0,0
l004e	dc.b	0,0,$a6,'|',0,0,0,'$'
	dc.b	$c,2,0,0,$9e,5,0,0
	dc.b	0,2,0,0,$9c,'@',0,1
	dc.b	1,0,0,0,0,0,0,0
	dcb.w	2
	dc.b	$9f,$bc,0,0,0,$12,2,$97
	dc.b	0,$f,'@',0,0,0,0,5
	dc.b	0,0,$a9,'L',0,0,0,0
l004f	dc.b	0,0
l0050	dc.b	0,0,$a6,$80,0,0,0,'$'
	dc.b	$b,1,0,0,$9d,$c5,0,0
	dc.b	0,1,0,0,$9c,0,0,2
	dc.b	3,0,0,2,3,3,2,1
	dc.b	0,1,0,0,$a6,'<',0,0
	dc.b	0,$12,2,0,0,$f,'@',0
	dc.b	0,0,0,4,0,0,$a9,'P'
	dcb.w	2
l0051	dc.b	2,0
l0052	dc.b	0,0,$a6,$84,0,0,0,'$'
	dcb.w	2
	dc.b	$99,'T',0,0,0,7,0,0
	dc.b	$99,'T',0,1,1,0,0,0
	dcb.w	2
	dc.b	0,2,0,0,$9f,'|',0,0
	dc.b	0,$12,2,0,0,0,0,0
	dc.b	0,0,0,7,0,0,$a9,'T'
l0053	dcb.w	3
l0054	dcb.w	31
l0055	dc.b	0,'@',0,0
l0056	dc.b	0,0,$9f,'|'
l0057	dc.b	0,0,$9b,$c0
l0058	dc.b	0,0,$9d,$80
l0059	dc.b	0,0,$a6,'|'
l005a	dc.b	'8',$c,0,0,0,0
l005b	dc.b	0,0
l005c	dc.b	0,0
l005d	dc.b	$e,$ee,$e,$17,$d,'M',$c,$8e
	dc.b	$b,$d9,$b,'/',$a,$8e,9,$f7
	dc.b	9,'g',8,$e0,8,'a',7,$e8
	dc.b	7,'w',7,$b,6,$a6,6,'G'
	dc.b	5,$ec,5,$97,5,'G',4,$fb
	dc.b	4,$b3,4,'p',4,'0',3,$f4
	dc.b	3,$bb,3,$85,3,'S',3,'#'
	dc.b	2,$f6,2,$cb,2,$a3,2,'}'
	dc.b	2,'Y',2,'8',2,$18,1,$fa
	dc.b	1,$dd,1,$c2,1,$a9,1,$91
	dc.b	1,'{',1,'e',1,'Q',1,'>'
	dc.b	1,',',1,$1c,1,$c,0,$fd
	dc.b	0,$ee,0,$e1,0,$d4,0,$c8
	dc.b	0,$bd,0,$b2,0,$a8,0,$9f
	dc.b	0,$96,0,$8e,0,$86,0,'~'
	dc.b	0,'w',0,'p',0,'j',0,'d'
	dc.b	0,'^',0,'Y',0,'T',0,'O'
	dc.b	0,'K',0,'G',0,'C',0,'?'
	dc.b	0,';',0,'8',0,'5',0,'2'
	dc.b	0,'/',0,',',0,'*',0,$27
	dc.b	0,'%',0,'#',0,'!',0,$1f
	dc.b	0,$1d,0,$1c,0,$1a,0,$19
	dc.b	0,$17,0,$16,0,$15,0,$13
	dc.b	0,$12,0,$11,0,$10,0,$f
l005e	dc.b	0,1,2,3,4,5,6,7
	dc.b	8,9,$a,$b,$f,$f,$f,$f
	dc.b	$f,$f
l005f	dcb.w	2
l0060	dc.b	0,0,$a9,'L'
l0061	dc.b	0,0,$a9,'X',0,0,0,0
	dc.b	0,0
l0062	dcb.w	2
l0063	dc.b	'TFMX',0,6,0,7
	dc.b	0,$16,0,';',0,'@',0,4
	dc.b	0,1,0,0,0,0,0,0
	dcb.w	4
l0064	dc.b	$e2,$e6,1,0,0,0,0,0
	dc.b	0,0,$e0,2,0,0,0,0
	dcb.w	24
	dc.b	$e2,$e6,$c,0,$e1,0,0,0
	dcb.w	28
	dc.b	$e2,$e5,$93,$e6,$97,$94,$90,$8c
	dc.b	$88,$8d,$8c,$8b,$8d,$8e,$e0,7
	dcb.w	24
	dc.b	$e2,$e5,$93,$e6,$9e,$9f,$e4,$95
	dc.b	$9e,$9d,$9c,$9b,$9a,$e0,9,0
	dcb.w	24
	dc.b	$e2,$e5,$9f,$e1,0,0,0,0
	dcb.w	28
	dc.b	$e2,$e6,0,$e1,0,0,0,0
	dcb.w	28
	dc.b	$e2,$e5,$9f,$e6,0,$e1,0,0
	dcb.w	28
l0065	dc.b	3,0,1,2,3,$f,$e,$d
	dc.b	$c,$b,$a,9,8,7,6,5
	dc.b	4,3,2,1,0,$e1,0,0
	dcb.w	20
	dc.b	3,1,2,3,4,$f,$e,$d
	dc.b	$c,$b,$a,9,8,7,6,5
	dc.b	4,3,2,1,0,$e1,0,0
	dcb.w	20
	dc.b	1,2,0,0,0,$d,$f,$f
	dc.b	$f,$f,$f,0,$e1,0,0,0
	dcb.w	24
	dc.b	1,3,0,0,0,$d,$f,$f
	dc.b	$f,$f,$e,$d,$c,$b,$a,9
	dc.b	8,7,6,5,4,3,2,1
	dc.b	$e1,0,0,0,0,0,0,0
	dcb.w	16
	dc.b	1,4,0,0,0,$d,0,$e1
	dcb.w	28
	dc.b	1,5,1,2,0,$e,$d,$e1
	dcb.w	28
	dc.b	2,5,1,2,0,$d,$c,$b
	dc.b	$a,9,8,7,6,5,4,3
	dc.b	2,1,0,$e1,0,0,0,0
	dcb.w	20
	dc.b	1,6,2,2,3,$d,$f,$e
	dc.b	$e,$d,$c,$c,$c,$b,$a,9
	dc.b	8,7,6,5,4,3,2,1
	dc.b	0,$e1,0,0,0,0,0,0
	dcb.w	14
l0066	dcb.w	32
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	4
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	4
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	4
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	4
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	4
	dc.b	$c,2,0,0,0,0,0,0
	dcb.w	2
	dc.b	$c,2,0,0,$c,2,0,0
	dcb.w	6
	dc.b	$c,2,0,0,$c,2,0,0
	dc.b	$c,2,0,0,$c,2,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,2,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,3,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,2,0,0
	dc.b	$c,4,0,0,$c,2,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,1,0,0,0,0,0,0
	dc.b	$c,1,0,0,0,0,0,0
	dc.b	$c,1,0,0,$c,1,0,0
	dc.b	$c,1,0,0,$c,1,0,0
	dcb.w	2
	dc.b	$c,1,0,0,$c,1,0,0
	dcb.w	2
	dc.b	$c,1,0,0,0,0,0,0
	dc.b	$e,1,0,0,0,0,0,0
	dc.b	$f,1,0,0,0,0,0,0
	dc.b	$f,1,0,0,0,0,0,0
	dc.b	$f,1,0,0,$f,1,0,0
	dc.b	$f,1,0,0,$f,1,0,0
	dcb.w	2
	dc.b	$f,1,0,0,$f,1,0,0
	dcb.w	2
	dc.b	$f,1,0,0,0,0,0,0
	dc.b	$13,1,0,0,0,0,0,0
	dc.b	$11,1,0,0,0,0,0,0
	dc.b	$11,1,0,0,0,0,0,0
	dc.b	$11,1,0,0,$11,1,0,0
	dc.b	$11,1,0,0,$11,1,0,0
	dcb.w	2
	dc.b	$11,1,0,0,$11,1,0,0
	dcb.w	2
	dc.b	$11,1,0,0,0,0,0,0
	dc.b	$a,1,0,0,0,0,0,0
	dc.b	$c,1,0,0,0,0,0,0
	dc.b	$c,1,0,0,0,0,0,0
	dc.b	$c,1,0,0,$c,1,0,0
	dc.b	$c,1,0,0,$a,1,0,0
	dcb.w	2
	dc.b	$a,1,0,0,$a,1,0,0
	dcb.w	2
	dc.b	$a,1,0,0,$a,1,0,0
	dc.b	$a,1,0,0,$a,1,0,0
	dc.b	'+',0,0,0,0,0,0,0
	dcb.w	20
	dc.b	'-',0,0,0,0,0,0,0
	dc.b	'.',0,0,0,0,0,0,0
	dc.b	$27,0,0,0,0,0,0,0
	dcb.w	20
	dc.b	'.',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'.',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'-',0,0,0,0,0,0,0
	dcb.w	20
	dc.b	'.',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'-',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'+',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	')',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'.',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'0',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'.',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'-',0,0,0,0,0,0,0
	dcb.w	4
	dc.b	'+',0,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	'-',0,0,0,'-',6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	$27,0,0,0,$27,6,0,0
	dc.b	$27,6,0,0,$27,6,0,0
	dc.b	$27,6,0,0,$27,6,0,0
	dc.b	$27,6,0,0,$27,6,0,0
	dc.b	$27,6,0,0,$27,6,0,0
	dc.b	$27,6,0,0,$27,6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	'.',6,0,0,'.',6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	'.',6,0,0,'.',6,0,0
	dc.b	'-',0,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	'.',6,0,0,'.',6,0,0
	dc.b	'-',0,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	'+',0,0,0,'+',6,0,0
	dc.b	'+',6,0,0,'+',6,0,0
	dc.b	')',0,0,0,')',6,0,0
	dc.b	')',6,0,0,')',6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	'.',6,0,0,'.',6,0,0
	dc.b	'0',0,0,0,'0',6,0,0
	dc.b	'0',6,0,0,'0',6,0,0
	dc.b	'.',0,0,0,'.',6,0,0
	dc.b	'.',6,0,0,'.',6,0,0
	dc.b	'-',0,0,0,'-',6,0,0
	dc.b	'-',6,0,0,'-',6,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	'(',0,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'$',0,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	')',0,0,0,')',6,0,0
	dc.b	')',6,0,0,')',6,0,0
	dc.b	'(',0,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	')',0,0,0,')',6,0,0
	dc.b	')',6,0,0,')',6,0,0
	dc.b	'(',0,0,0,'(',6,0,0
	dc.b	'$',0,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'$',6,0,0,'$',6,0,0
	dc.b	'&',0,0,0,'&',6,0,0
	dc.b	'&',6,0,0,'&',6,0,0
	dc.b	'&',0,0,0,'&',6,0,0
	dc.b	'&',6,0,0,'&',6,0,0
	dc.b	'(',0,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'(',6,0,0,'(',6,0,0
	dc.b	'&',0,0,0,'&',6,0,0
	dc.b	'+',1,0,0,0,0,0,0
	dc.b	'*',1,0,0,0,0,0,0
	dc.b	')',1,0,0,0,0,0,0
	dc.b	'(',1,0,0,0,0,0,0
	dc.b	$27,1,0,0,0,0,0,0
	dc.b	'&',1,0,0,0,0,0,0
	dc.b	'%',1,0,0,0,0,0,0
	dc.b	'$',1,0,0,0,0,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,2,0,0
	dc.b	$c,2,0,0,$c,4,0,0
	dc.b	$c,4,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,4,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$c,3,0,0,$c,3,0,0
	dc.b	$a,1,$b,1,$d,1,$f,1
	dc.b	$10,1,$10,1,$f,1,$d,1
	dc.b	$b,1,$a,1,$a,1,$a,1
	dc.b	$a,1,$a,1,$a,1,$a,1
	dc.b	$a,1,$a,1,$a,1,$a,1
	dc.b	$a,1,$a,1,$a,1,$a,1
	dc.b	$a,1,$a,1,$a,1,$a,1
	dc.b	$a,1,$a,1,$a,1,$a,1
l0067	dc.b	1,0,0,0,$1b,$fe,0,$f4
	dcb.w	2
	dc.b	1,0,0,0,$1b,$ff,0,$f3
	dcb.w	2
	dc.b	1,0,0,0,$1b,0,0,$f2
	dcb.w	2
	dc.b	2,0,0,0,$1b,1,0,$f1
	dcb.w	2
	dc.b	3,0,0,0,5,0,0,$f0
	dc.b	9,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$a,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$b,0,0,0,4,0,0,0
	dc.b	8,0,0,0,$c,0,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	9,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$a,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$b,0,0,0,4,0,0,0
	dc.b	8,0,0,0,$d,0,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$e,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$f,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$10,0,0,0,4,0,0,0
	dc.b	8,0,0,0,$11,0,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$e,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$f,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$10,0,0,0,$13,0,0,0
	dc.b	8,0,0,0,$12,0,0,0
	dc.b	3,0,0,0,5,$fd,0,0
	dc.b	$14,0,0,0,4,0,0,0
	dc.b	6,$fd,0,0,$15,0,0,0
	dc.b	3,0,0,0,7,$fd,0,0
	dc.b	$16,0,0,0,4,0,0,0
	dc.b	8,$fd,0,0,$17,0,0,0
	dc.b	3,0,0,0,5,$fd,0,0
	dc.b	$14,0,0,0,4,0,0,0
	dc.b	6,$fd,0,0,$15,0,0,0
	dc.b	3,0,0,0,7,$fd,0,0
	dc.b	$16,0,0,0,4,0,0,0
	dc.b	8,$fd,0,0,$17,0,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$14,3,0,0,4,0,0,0
	dc.b	6,0,0,0,$15,3,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$16,3,0,0,4,0,0,0
	dc.b	8,0,0,0,$17,3,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$14,3,0,0,4,0,0,0
	dc.b	6,0,0,0,$15,3,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$16,3,0,0,4,0,0,0
	dc.b	8,0,0,0,$17,3,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$e,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$f,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$10,0,0,0,4,0,0,0
	dc.b	8,0,0,0,$11,0,0,0
	dc.b	3,0,0,0,5,0,0,0
	dc.b	$e,0,0,0,4,0,0,0
	dc.b	6,0,0,0,$f,0,0,0
	dc.b	3,0,0,0,7,0,0,0
	dc.b	$10,0,0,0,$13,0,0,0
	dc.b	8,0,0,0,$18,0,0,0
	dc.b	3,0,0,0,5,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,6,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,7,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,8,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,5,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,6,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,7,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,8,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,5,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,6,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,7,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,8,$fd,0,0
	dcb.w	2
	dc.b	3,0,0,0,5,$fd,0,0
	dcb.w	2
	dc.b	4,0,0,0,6,$fd,0,0
	dcb.w	2
	dc.b	$19,0,0,0,7,$fd,0,0
	dcb.w	2
	dc.b	$1a,0,0,0,8,$fd,0,0
	dcb.w	2
l0068	dc.b	0,0,0,';',0,3,0,0
	dcb.w	2
l0069	dcb.w	206
mystack	dc.b	0,0
zuend	end
