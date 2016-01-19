*** NANAUK Doc Displayer 1.4! *****

	pea	start(pc)
	move.w	#$26,-(a7)		;supexec
	trap	#$e
	addq.l	#6,a7
	clr.w	-(a7)		;pterm0
	trap	#1

start	move.b	$ffff8260.w,d0
	andi.b	#3,d0
	cmpi.b	#2,d0
	beq	l0005
	bsr	init_prg
	bsr	l005e
	lea	tog_table,a6
	bsr	l002f
	bsr	l0034
	move.l	a6,l00bc
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	lea	doc_file,a1
	moveq	#$16,d6
	bsr	print
	move.l	#tbs_mark,l00bd
	move.l	a1,l00be
;
;	main	keyboard	loop
;
key_loop	move.w	#$ff,-(a7)
	move.w	#6,-(a7)		;crawio
	trap	#1
	addq.l	#4,a7
	move.l	d0,d1
	swap	d1
	movea.l	line_a,a6
	move.w	6(a6),d3
	cmpi.w	#1,d3
	beq	l000a
	cmpi.w	#2,d3
	beq	l0008
	cmpi.w	#3,d3
	beq	l0004
	cmpi.b	#$32,d0
	beq	l000f
	cmpi.b	#$38,d0
	beq	l000c
	cmpi.b	#$11,d0
	beq	l0004
	cmpi.b	#$50,d1		;cursor down
	beq	l000a
	cmpi.b	#$48,d1		;cursor up
	beq	l0008
	cmpi.b	#$3c,d0		;shift & , (<)
	beq	invrt_pal
	cmpi.b	#$10,d0
	beq	l0040
	cmpi.b	#$19,d1		;p
	beq	l0045
	cmpi.b	#$20,d0
	beq	l000f
	cmpi.b	#$62,d1
	beq	l004b
	cmpi.l	#$14,d1
	beq	l0006
	cmpi.l	#$30,d1
	beq	l0007
	cmpi.b	#$21,d1
	beq	l0062
	cmpi.b	#$31,d1
	beq	l0065
	cmpi.b	#$30,d1
	beq	l0069
	cmpi.b	#$2b,d1		; ";" = music on/off
	beq	key_m
	cmpi.b	#$1f,d1
	beq	hertz
	cmpi.b	#$1f,d0
	beq	l0012
	cmpi.b	#$54,d1
	blt.b	l0002
	cmpi.b	#$5e,d1
	bgt.b	l0002
	bra	l0089
l0002	cmpi.b	#$3b,d1		;scan from f1
	blt.b	l0003		;less than - no key pressed yet
	cmpi.b	#$45,d1		;to f11	!! (code for f10 +1)
	bgt.b	l0003		;greater than = no key pressed
	bra	l008a
l0003	bra	key_loop
l0004	bsr	reset_prg
l0005	rts
l0006	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	lea	doc_file,a1
	moveq	#$16,d6
	bsr	print
	move.l	#tbs_mark,l00bd
	move.l	a1,l00be
	moveq	#1,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l0007	lea	tog_table,a6
	bsr	l0034
	bsr	l002f
	movea.l	a6,a5
	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	movea.l	a5,a1
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	move.w	l00bf,d0
	subi.w	#$16,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l0008	movea.l	l00bd,a6
	cmpa.l	#doc_file,a6
	bge.b	l0009
	moveq	#1,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l0009	bsr	l003a
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	movea.l	l00bd,a1
	moveq	#0,d6
	bsr	print
	movea.l	l00bd,a6
	bsr	l0034
	move.l	a6,l00bd
	movea.l	l00be,a6
	bsr	l0034
	move.l	a6,l00be
	move.w	l00c0,d0
	beq.b	l0009
	subq.w	#1,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l000a	movea.l	l00be,a1
	cmpa.l	#tog_table,a1
	bge.b	l000b
	bsr	l003d
	movea.l	$44e.w,a0
	lea	29440(a0),a0
	movea.l	l00be,a1
	moveq	#0,d6
	bsr	print
	move.l	a1,l00be
	movea.l	l00bd,a6
	bsr	l0038
	move.l	a6,l00bd
	move.w	l00c0,d0
	move.w	l00bf,d1
	cmp.w	d0,d1
	ble.b	l000b
	addq.w	#1,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
l000b	bra	key_loop
l000c	movea.l	l00bd,a6
	cmpa.l	#doc_file,a6
	blt.b	l000e
	bsr	l002f
	cmpa.l	#doc_file,a6
	bgt.b	l000d
	lea	doc_file,a6
	move.w	#$18,l00c0
l000d	movea.l	a6,a5
	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	movea.l	a5,a1
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	subi.w	#$17,l00c0
	move.w	l00c0,d0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
l000e	bra	key_loop
l000f	movea.l	l00be,a6
	cmpa.l	#tog_table,a6
	bge.b	l0011
	cmpa.l	l00bc,a6
	blt.b	l0010
	movea.l	l00bc,a6
	move.l	a6,l00be
	move.w	l00bf,d0
	subi.w	#$2d,d0
	move.w	d0,l00c0
l0010	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	movea.l	l00be,a1
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	move.w	l00c0,d0
	addi.w	#$17,d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
l0011	bra	key_loop
l0012	move.b	#2,$ffff8260.w
print	movea.l	a1,a6
	lea	font(pc),a2
l0014	move.l	#$10003,l0098
	lea	(a0),a4
	move.w	#$4f,d7
l0015	moveq	#0,d0
	move.b	(a1)+,d0
	bra	l0023
l0016	move.l	l0098,d1
	swap	d1
	move.l	d1,l0098
	move.w	d1,l0019
	lsl.w	#3,d0
	movea.l	a2,a3
	adda.l	d0,a3
	jmp	l001c
l0017	equ	*-4
l0018	lea	1(a4),a4
l0019	equ	*-2
	dbf	d7,l0015
	movea.l	a1,a6
	bsr	l0038
	movea.l	a6,a1
l001a	lea	1280(a0),a0
	dbf	d6,l0014
l001b	rts
l001c	move.b	(a3)+,0(a4)
	move.b	(a3)+,160(a4)
	move.b	(a3)+,320(a4)
	move.b	(a3)+,480(a4)
	move.b	(a3)+,640(a4)
	move.b	(a3)+,800(a4)
	move.b	(a3)+,960(a4)
	move.b	(a3)+,1120(a4)
	bra	l0018
l001d	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,0(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,160(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,320(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,480(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,640(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,800(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,960(a4)
	move.b	(a3)+,d0
	move.b	d0,d1
	lsl.b	#1,d1
	or.b	d1,d0
	move.b	d0,1120(a4)
	bra	l0018
l001e	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,0(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,160(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,320(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,480(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,640(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,800(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,960(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,1120(a4)
	bra	l0018
l001f	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,0(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,160(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,320(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,480(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,640(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,800(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,960(a4)
	move.b	(a3)+,d0
	andi.b	#$aa,d0
	move.b	d0,1120(a4)
	bra	l0018
l0020	move.b	(a3)+,d0
	lsr.b	#1,d0
	move.b	d0,(a4)
	move.b	(a3)+,d0
	lsr.b	#1,d0
	move.b	d0,160(a4)
	move.b	(a3)+,320(a4)
	move.b	(a3)+,480(a4)
	move.b	(a3)+,640(a4)
	move.b	(a3)+,d0
	lsl.b	#1,d0
	move.b	d0,800(a4)
	move.b	(a3)+,d0
	lsl.b	#1,d0
	move.b	d0,960(a4)
	move.b	(a3)+,d0
	lsl.b	#1,d0
	move.b	d0,1120(a4)
	bra	l0018
l0021	move.b	(a3)+,0(a4)
	move.b	(a3)+,160(a4)
	move.b	(a3)+,320(a4)
	move.b	(a3)+,480(a4)
	move.b	(a3)+,640(a4)
	move.b	(a3)+,800(a4)
	move.b	(a3)+,960(a4)
	move.b	#$ff,1120(a4)
	bra	l0018
l0022	move.b	(a3)+,d5
	move.b	d5,2(a4)
	move.b	(a3)+,d5
	move.b	d5,162(a4)
	move.b	(a3)+,d5
	move.b	d5,322(a4)
	move.b	(a3)+,d5
	move.b	d5,482(a4)
	move.b	(a3)+,d5
	move.b	d5,642(a4)
	move.b	(a3)+,d5
	move.b	d5,802(a4)
	move.b	(a3)+,d5
	move.b	d5,962(a4)
	move.b	(a3)+,d5
	move.b	d5,1122(a4)
	bra	l0018
l0023	tst.b	d0
	beq	l001b
	cmpi.b	#$a,d0
	beq	l001a
	cmpi.b	#$d,d0
	beq	l0015
	cmpi.b	#9,d0
	bne.b	l0025
	move.w	l00a4,d0
	move.w	#$4f,d1
	sub.w	d7,d1
	divu	d0,d1
	mulu	d0,d1
	add.w	d0,d1
	move.w	#$4f,d7
	sub.w	d1,d7
	moveq	#0,d0
	move.l	#$30001,d2
l0024	add.w	d2,d0
	swap	d2
	dbf	d1,l0024
	swap	d2
	move.l	d2,l0098
	lea	0(a0,d0.w),a4
	bra	l0015
l0025	cmpi.b	#$1b,d0
	bne	l0016
	move.b	(a1)+,d0
	addq.b	#1,d7
	cmpi.b	#$62,d0
	bne.b	l0026
	move.l	#l001d,l0017
	addq.b	#1,d7
	bra	l0015
l0026	cmpi.b	#$63,d0
	bne.b	l0027
	move.l	#l0022,l0017
	addq.b	#1,d7
	bra	l0015
l0027	cmpi.b	#$69,d0
	bne.b	l0028
	move.l	#l0020,l0017
	addq.b	#1,d7
	bra	l0015
l0028	cmpi.b	#$76,d0
	bne.b	l0029
	move.l	#l001e,l0017
	addq.b	#1,d7
	bra	l0015
l0029	cmpi.b	#$6e,d0
	bne.b	l002a
	move.l	#l001c,l0017
	addq.b	#1,d7
	bra	l0015
l002a	cmpi.b	#$70,d0
	bne.b	l002b
	move.l	#l001e,l0017
	addq.b	#1,d7
	bra	l0015
l002b	cmpi.b	#$71,d0
	bne.b	l002c
	move.l	#l001c,l0017
	addq.b	#1,d7
	bra	l0015
l002c	cmpi.b	#$75,d0
	bne.b	l002d
	move.l	#l0021,l0017
	addq.b	#1,d7
	bra	l0015
l002d	cmpi.b	#$6c,d0
	bne.b	l002e
	move.l	#l001f,l0017
	addq.b	#1,d7
	bra	l0015
l002e	bra	l0016
l002f	moveq	#$15,d1
l0030	suba.l	#2,a6
l0031	move.b	-(a6),d0
	cmpi.b	#$a,d0
	beq.b	l0032
	cmpi.b	#$d,d0
	beq.b	l0032
	cmpa.l	#doc_file,a6
	ble.b	l0033
	bra.b	l0031
l0032	tst.b	(a6)+
	dbf	d1,l0030
l0033	rts
l0034	suba.l	#2,a6
l0035	move.b	-(a6),d0
	cmpi.b	#$a,d0
	beq.b	l0036
	cmpi.b	#$d,d0
	beq.b	l0036
	cmpa.l	#doc_file,a6
	ble.b	l0037
	bra.b	l0035
l0036	tst.b	(a6)+
l0037	rts
l0038	movea.l	a6,a5
	move.b	(a6)+,d0
	cmpi.b	#$a,d0
	beq.b	l0039
	cmpi.b	#$d,d0
	beq.b	l0039
	bra.b	l0038
l0039	tst.b	(a6)+
	rts
	movea.l	a5,a6
	rts
l003a	movea.l	$44e.w,a6
	lea	29280(a6),a5
	lea	30560(a6),a6
	move.w	#$af,d0
l003b	movem.l	(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,(a6)
	movem.l	40(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,40(a6)
	movem.l	80(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,80(a6)
	movem.l	120(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,120(a6)
	lea	-160(a5),a5
	lea	-160(a6),a6
	dbf	d0,l003b
	movem.l	l0099,a0-a2/d1-d7
	moveq	#7,d0
l003c	movem.l	a0-a2/d1-d7,(a6)
	movem.l	a0-a2/d1-d7,40(a6)
	movem.l	a0-a2/d1-d7,80(a6)
	movem.l	a0-a2/d1-d7,120(a6)
	lea	-160(a6),a6
	dbf	d0,l003c
	rts
l003d	movea.l	$44e.w,a6
	lea	2560(a6),a5
	lea	1280(a6),a6
	move.w	#$af,d0
l003e	movem.l	(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,(a6)
	movem.l	40(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,40(a6)
	movem.l	80(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,80(a6)
	movem.l	120(a5),a0-a2/d1-d7
	movem.l	a0-a2/d1-d7,120(a6)
	lea	160(a5),a5
	lea	160(a6),a6
	dbf	d0,l003e
	movem.l	l0099,a0-a2/d1-d7
	move.w	#7,d0
l003f	movem.l	a0-a2/d1-d7,(a6)
	movem.l	a0-a2/d1-d7,40(a6)
	movem.l	a0-a2/d1-d7,80(a6)
	movem.l	a0-a2/d1-d7,120(a6)
	lea	160(a6),a6
	dbf	d0,l003f
	rts
l0040	move.w	#$11,-(a7)		;cprnos
	trap	#1
	addq.l	#2,a7
	tst.w	d0
	beq	l004a
	lea	doc_file,a6
l0041	moveq	#0,d0
	move.b	(a6)+,d0
	beq.b	l0044
	cmpi.w	#9,d0
	beq.b	l0043
	cmpi.w	#$a,d0
	beq.b	l0043
	cmpi.w	#$d,d0
	beq.b	l0043
	cmpi.w	#$1b,d0
	bne.b	l0042
	tst.b	(a6)+
	bra.b	l0041
l0042	cmpi.w	#$20,d0
	blt.b	l0041
	cmpi.w	#$f8,d0
	bgt.b	l0043
	cmpi.w	#$c0,d0
	bge.b	l0041
l0043	cmpi.b	#1,$fffffc02.w
	beq	l0044
	move.w	d0,-(a7)
	move.w	#5,-(a7)		;cprnout
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	beq	l004a
	bra.b	l0041
l0044	bra	key_loop
l0045	move.w	#$11,-(a7)		;cprnos
	trap	#1
	addq.l	#2,a7
	tst.w	d0
	beq	l004a
	movea.l	l00bd,a6
	movea.l	l00be,a5
l0046	moveq	#0,d0
	move.b	(a6)+,d0
	cmpi.w	#9,d0
	beq.b	l0048
	cmpi.w	#$a,d0
	beq.b	l0048
	cmpi.w	#$d,d0
	beq.b	l0048
	cmpi.w	#$1b,d0
	bne.b	l0047
	tst.b	(a6)+
	bra.b	l0046
l0047	cmpi.w	#$20,d0
	blt.b	l0046
	cmpi.w	#$f8,d0
	bgt.b	l0048
	cmpi.w	#$c0,d0
	bge.b	l0046
l0048	cmpa.l	a6,a5
	blt.b	l0049
	cmpi.b	#1,$fffffc02.w
	beq	l0049
	move.w	d0,-(a7)
	move.w	#5,-(a7)		;cprnout
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	beq	l004a
	bra.b	l0046
l0049	bra	key_loop
l004a	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l00a0,a1
	moveq	#0,d6
	bsr	print
	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l004b	bsr	l0056
l004c	movea.l	$44e.w,a0
	lea	help_page,a1
	moveq	#$18,d6
	bsr	print
	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	swap	d0
	cmpi.b	#$20,d0
	beq	l004e
	cmpi.b	#$14,d0
	beq	l004d
	cmpi.b	#$27,d0
	beq	l004f
	cmpi.b	#$18,d0
	beq	l0050
	cmpi.b	#$19,d0
	beq	l0051
	move.w	init_prt,-(a7)
	move.w	#$21,-(a7)		;setprt
	trap	#$e
	addq.l	#4,a7
	bsr	l0056
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	movea.l	l00bd,a6
	bsr	l0038
	movea.l	a6,a1
	moveq	#$16,d6
	bsr	print
	bra	key_loop
l004d	bchg	#1,init_prt
	lea	color,a0
	bsr	l0052
	lea	mono,a0
	bsr	l0052
	bra	l004c
l004e	bchg	#2,init_prt
	lea	atari,a0
	bsr	l0052
	lea	epson,a0
	bsr	l0052
	bra	l004c
l004f	bchg	#3,init_prt
	lea	draft,a0
	bsr	l0052
	lea	final,a0
	bsr	l0052
	bra	l004c
l0050	bchg	#4,init_prt
	lea	centron,a0
	bsr	l0052
	lea	rs232,a0
	bsr	l0052
	bra	l004c
l0051	bchg	#5,init_prt
	lea	listing,a0
	bsr	l0052
	lea	a4_form,a0
	bsr	l0052
	bra	l004c
l0052	cmpi.b	#$e8,(a0)
	beq.b	l0053
	subi.b	#1,(a0)
	rts
l0053	addi.b	#1,(a0)
	rts
l0054	movem.l	l0099,a2-a4/d1-d7
	movea.l	$44e.w,a6
	lea	1280(a6),a6
	move.w	#$b7,d0
l0055	movem.l	a2-a4/d1-d7,(a6)
	movem.l	a2-a4/d1-d7,40(a6)
	movem.l	a2-a4/d1-d7,80(a6)
	movem.l	a2-a4/d1-d7,120(a6)
	lea	160(a6),a6
	dbf	d0,l0055
	rts
l0056	movea.l	$44e.w,a0
	move.w	#$1f3f,d0
	move.l	#$ffff,d1
l0057	move.l	d1,(a0)+
	dbf	d0,l0057
	rts

invrt_pal	move.l	$ffff8244.w,d0
	swap	d0
	move.l	d0,$ffff8244.w
	bra	key_loop


init_prg	bsr	l008b
	dc.w	$a000
	suba.l	#$25a,a0
	move.l	a0,line_a
	dc.w	$a00a
	pea	$e0001
	trap	#$e
	addq.l	#4,a7
	movea.l	d0,a0
	move.w	4(a0),l00b7
	move.w	#5,4(a0)
	move.w	#4,-(a7)		;getrez
	trap	#$e
	addq.l	#2,a7
	move.w	d0,old_rez
	move.l	$466.w,d0
l005a	cmp.l	$466.w,d0
	bne.b	l005a
	move.b	#1,$ffff8260.w	;	medium	rez
	pea	$f0001
	move.w	#$23,-(a7)		;kbrate
	trap	#$e
	addq.l	#6,a7
	move.b	$484.w,bell_stat
	move.b	#6,$484.w

	move.w	init_prt,-(a7)
	move.w	#$21,-(a7)		;setprt
	trap	#$e
	addq.l	#4,a7

	movem.l	$ffff8240.w,d0-d1
	movem.l	d0-d1,old_pal
	movem.l	new_pal,d0-d1
	movem.l	d0-d1,$ffff8240.w
	bsr	l0056
;	jsr	music	; for grazey relocated files !!
	bsr	mus_on
	rts

reset_prg	move.w	old_rez,d1
	move.l	$466.w,d0
l005c	cmp.l	$466.w,d0
	bne.b	l005c
	move.b	d1,$ffff8260.w
	movea.l	$44e.w,a0
	move.w	#$1f3f,d0
l005d	clr.l	(a0)+
	dbf	d0,l005d
	pea	$e0001
	trap	#$e
	addq.l	#4,a7
	movea.l	d0,a0
	move.w	l00b7,4(a0)
	pea	$f0002
	move.w	#$23,-(a7)		;kbrate
	trap	#$e
	addq.l	#6,a7
	bsr	mus_off
	move.b	bell_stat,$484.w
	movem.l	old_pal,d0-d1
	movem.l	d0-d1,$ffff8240.w
	dc.b	$a0,$09
	rts

l005e	lea	doc_file,a0
	moveq	#1,d0
l005f	move.b	(a0)+,d1
	beq.b	l0061
	cmpi.b	#$a,d1
	beq.b	l0060
	cmpi.b	#$d,d1
	beq.b	l0060
	cmpa.l	#l00b2,a0
	bge.b	l0061
	bra.b	l005f
l0060	move.b	(a0)+,d1
	addq.w	#1,d0
	bra.b	l005f
l0061	move.w	d0,l00bf
	move.w	#1,l00c0
	bsr	l0087
	lea	l009e,a0
	bsr	l0084
	rts
l0062	movea.l	l00bd,a6
	bsr	l0038
	bsr	l0038
	move.l	a6,l0095
	lea	l00a1,a0
	lea	l00c1,a1
	moveq	#$f,d0
	bsr	l006d
	bsr	l0074
	cmpa.l	#0,a0
	beq	l0083
	cmpa.l	l00bc,a0
	blt.b	l0063
	movea.l	a0,a6
	movea.l	l00bc,a6
	move.l	a6,l00be
	move.w	l00bf,d0
	subi.w	#$16,d0
	move.w	d0,l00c0
	bsr	l0038
	movea.l	a6,a0
	pea	(a0)
	bra.b	l0064
l0063	pea	(a0)
	move.w	l00c0,d0
	add.w	d7,d0
	move.w	d0,l00c0
l0064	move.w	l00c0,d0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	movea.l	(a7)+,a0
	movea.l	a0,a6
	bsr	l0034
	movea.l	a6,a1
	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l0065	movea.l	l00bd,a6
	bsr	l0038
	bsr	l0038
	move.l	a6,l0095
	tst.b	l00c1
	beq	l0068
	bsr	l0074
	cmpa.l	#0,a0
	beq	l0083
	cmpa.l	l00bc,a0
	blt.b	l0066
	movea.l	a0,a6
	movea.l	l00bc,a6
	move.l	a6,l00be
	move.w	l00bf,d0
	subi.w	#$16,d0
	move.w	d0,l00c0
	bsr	l0038
	movea.l	a6,a0
	pea	(a0)
	bra.b	l0067
l0066	pea	(a0)
	move.w	l00c0,d0
	add.w	d7,d0
	move.w	d0,l00c0
l0067	move.w	l00c0,d0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	movea.l	(a7)+,a0
	movea.l	a0,a6
	bsr	l0034
	movea.l	a6,a1
	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
l0068	bra	key_loop
l0069	movea.l	l00bd,a6
	bsr	l0038
	lea	-2(a6),a6
	move.l	a6,l0095
	tst.b	l00c1
	beq	l006c
	bsr	l007b
	cmpa.l	#0,a0
	beq	l0083
	cmpa.l	l00bc,a0
	blt.b	l006a
	movea.l	a0,a6
	movea.l	l00bc,a6
	move.l	a6,l00be
	move.w	l00bf,d0
	subi.w	#$16,d0
	move.w	d0,l00c0
	bsr	l0038
	movea.l	a6,a0
	pea	(a0)
	bra.b	l006b
l006a	pea	(a0)
	move.w	l00c0,d0
	sub.w	d7,d0
	move.w	d0,l00c0
l006b	move.w	l00c0,d0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	movea.l	(a7)+,a0
	movea.l	a0,a6
	bsr	l0034
	movea.l	a6,a1
	bsr	l0034
	move.l	a6,l00bd
	bsr	l0054
	movea.l	$44e.w,a0
	lea	1280(a0),a0
	moveq	#$16,d6
	bsr	print
	move.l	a1,l00be
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
l006c	bra	key_loop
l006d	movem.l	a1/d0,-(a7)
	movea.l	a0,a1
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	movea.l	a0,a6
	lea	l009a,a5
	movem.l	(a5),a2-a4/d1-d7
	moveq	#7,d0
l006e	movem.l	a2-a4/d1-d7,(a6)
	movem.l	a2-a4/d1-d7,40(a6)
	movem.l	a2-a4/d1-d7,80(a6)
	movem.l	a2-a4/d1-d7,120(a6)
	lea	160(a6),a6
	dbf	d0,l006e
	move.l	#0,d6
	bsr	print
	movem.l	(a7)+,a1/d0
	move.l	d0,d6
	move.l	d0,d7
l006f	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	cmpi.b	#$d,d0
	beq	l0073
	cmpi.b	#8,d0
	bne.b	l0071
	addq.w	#1,d6
	cmp.b	d6,d7
	bge.b	l0070
	subq.w	#1,d6
	bra.b	l006f
l0070	suba.l	#1,a1
	move.l	l0098,d1
	suba.w	d1,a4
	swap	d1
	move.l	d1,l0098
	move.w	d1,l0072
	move.b	#$ff,0(a4)
	move.b	#$ff,160(a4)
	move.b	#$ff,320(a4)
	move.b	#$ff,480(a4)
	move.b	#$ff,640(a4)
	move.b	#$ff,800(a4)
	move.b	#$ff,960(a4)
	move.b	#$ff,1120(a4)
	bra.b	l006f
l0071	tst.w	d6
	ble.b	l006f
	move.b	d0,(a1)+
	lea	font(pc),a2
	move.l	l0098,d1
	swap	d1
	move.l	d1,l0098
	move.w	d1,l0072
	lsl.w	#3,d0
	movea.l	a2,a3
	adda.w	d0,a3
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,0(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,160(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,320(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,480(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,640(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,800(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,960(a4)
	move.b	(a3)+,d0
	not.b	d0
	move.b	d0,1120(a4)
	lea	1(a4),a4
l0072	equ	*-2
	dbf	d6,l006f
	bra	l006f
l0073	clr.b	(a1)
	rts
l0074	moveq	#1,d7
	lea	l00c1,a0
	movea.l	l0095,a1
l0075	move.b	(a0),d0
	move.b	(a1)+,d1
	cmpi.b	#$a,d1
	bne.b	l0076
	addq.w	#1,d7
l0076	cmpa.l	#tog_table,a1
	bge.b	l0079
	cmp.b	d0,d1
	bne.b	l0075
l0077	adda.l	#1,a0
	tst.b	(a0)
	beq.b	l007a
	move.b	(a0),d0
	move.b	(a1)+,d1
	cmpi.b	#$a,d1
	bne.b	l0078
	addq.w	#1,d7
l0078	cmpa.l	#tog_table,a1
	bge.b	l0079
	cmp.b	d0,d1
	beq.b	l0077
	lea	l00c1,a0
	bra.b	l0075
l0079	lea	0.l,a0
	rts
l007a	movea.l	a1,a0
	addq.l	#1,a1
	move.l	a1,l0095
	rts
l007b	moveq	#1,d7
	lea	l00c1,a0
l007c	tst.b	(a0)+
	bne.b	l007c
	lea	-2(a0),a0
	movea.l	a0,a6
	movea.l	l0095(pc),a1
l007d	move.b	(a0),d0
	move.b	(a1),d1
	suba.l	#1,a1
	cmpi.b	#$a,d1
	bne.b	l007e
	addq.w	#1,d7
l007e	cmpa.l	#doc_file,a1
	ble.b	l0081
	cmp.b	d0,d1
	bne.b	l007d
l007f	suba.l	#1,a0
	tst.b	(a0)
	beq.b	l0082
	move.b	(a0),d0
	move.b	(a1),d1
	suba.l	#1,a1
	cmpi.b	#$a,d1
	bne.b	l0080
	addq.w	#1,d7
l0080	cmpa.l	#doc_file,a1
	ble.b	l0081
	cmp.b	d0,d1
	beq.b	l007f
	movea.l	a6,a0
	bra.b	l007d
l0081	lea	0.l,a0
	rts
l0082	movea.l	a1,a0
	addq.l	#1,a1
	move.l	a1,l0095
	rts
l0083	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l00a2,a1
	moveq	#0,d6
	bsr	print
	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	movea.l	$44e.w,a0
	lea	30720(a0),a0
	lea	l009f,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l0084	adda.l	#4,a0
	moveq	#0,d1
	move.w	#3,d2
l0085	move.b	d0,d1
	andi.b	#$f,d1
	move.b	l0086(pc,d1.w),-(a0)
	lsr.l	#4,d0
	dbf	d2,l0085
	rts
l0086	dc.b	'0123456789abcdef'
l0087	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	moveq	#3,d1
l0088	andi.l	#$ffff,d0
	divu	#$a,d0
	move.l	d0,d6
	swap	d6
	lsl.w	d5,d6
	or.w	d6,d7
	addq.w	#4,d5
	dbf	d1,l0088
	move.w	d7,d0
	rts
l0089	subi.b	#$54,d1
	mulu	#6,d1
	lea	l009b(pc),a0
	adda.w	d1,a0
	move.l	l00bd,(a0)+
	move.w	l00c0,(a0)
	bra	key_loop

l008a	subi.w	#$3b,d1
	mulu	#6,d1
	lea	l009b(pc),a5
	adda.w	d1,a5
	bsr	l0054
	pea	(a5)
	movea.l	(a5),a6
	bsr	l0038
	movea.l	a6,a1
	movea.l	$44e.l,a0
	lea	1280(a0),a0
	moveq	#$16,d6
	bsr	print
	movea.l	(a7)+,a5
	move.l	(a5),l00bd
	move.l	a1,l00be
	move.w	4(a5),d0
	move.w	d0,l00c0
	bsr	l0087
	lea	l009d,a0
	bsr	l0084
	movea.l	$44e.w,a0
	lea	l009c,a1
	moveq	#0,d6
	bsr	print
	bra	key_loop
l008b	lea	doc_file(pc),a0
l008c	move.b	(a0)+,d0
	cmpa.l	#tog_table,a0
	bgt.b	l008f
	tst.b	d0
	bne.b	l008d
	move.b	#$20,-1(a0)
	bra.b	l008c
l008d	cmpi.b	#$a,d0
	bne.b	l008e
	move.b	(a0)+,d0
	cmpi.b	#$a,d0
	bne.b	l008c
	move.b	#$d,-1(a0)
	bra.b	l008c
l008e	cmpi.b	#$d,d0
	bne.b	l008c
	move.b	(a0)+,d0
	cmpi.b	#$d,d0
	bne.b	l008c
	move.b	#$a,-1(a0)
	bra.b	l008c
l008f	rts

mus_on	move.l	$4d6.w,old_456
	lea	music,a0
	move.w	-8(a0),d1	; offset to call for init
	move.b	-13(a0),d0	; get tune no. to use
	andi.l	#$ff,d0
	jsr	0(a0,d1.w)	; jsr music + d1
	move.w	-4(a0),d0	; get vbl offset
	adda.w	d0,a0		; add offset to start of music
	move.l	a0,$4d6.w	; shove it on the vbl
	bset	#0,music_tog	; music playing toggle is now on
	rts

mus_off	move.l	old_456,$4d6.w
	move.l	#$a0a0000,$ffff8800.w
	move.l	#$9090000,$ffff8800.w
	move.l	#$8080000,$ffff8800.w
	bclr	#0,music_tog
	rts

key_m	tst.b	music_tog		; is music off
	bne.b	no_music
	bsr	mus_on
	bra	key_loop
no_music	bsr	mus_off
	bra	key_loop
hertz	bchg	#1,$ffff820a.w
	bra	key_loop

	section	data

l0095	dc.l	doc_file
init_prt	dc.w	$0005
new_pal	dc.w	$302,$000,$777,$000
l0098	dc.b	$00,$01,$00,$03

l0099	rept	10
	dc.l	$0000ffff
	endr

l009a	rept	10
	dc.l	$ffffffff
	endr

l009b	rept	10
	dc.l	tbs_mark
	dc.b	$00,$01
	endr	

l009c	dc.b	27,'v  Thunderbirds doc displayer 1.4 coded by Nanouk '
	dc.b	'               line '
l009d	dc.b	'0001/'
l009e	dc.b	'0000  ',$1b,'n',$00
l009f	dc.b	27,'v    Use arrows to scroll up and down, shift arrows to page, help for more ..    ',27,'n',0
l00a0	dc.b	27,'v    Your printer is not ready !!!!! (Oh no!!)              - Press any key -    ',27,'n',0
l00a1	dc.b	27,'v Enter text to find    ',27,'n',0
l00a2	dc.b	27,'v   Not found         - Press any key -                                          ',27,'n',0,0

;
;	new	font	data
;
font	incbin	'font.bin'
	even


l00a4	dc.b	$00,$08
help_page	
	dc.b      13,10 
	dc.b      '                       ',27,'bTHE THUNDERBIRDS DOC DISPLAYER V1.4',27,'n',13,10
	dc.b      13,10 
	dc.b      ' ñ ',27,'bEDITION',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõó ñ ',27,'bPRINTER',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõõó',13,10 
	dc.b      ' Ã                                    Ä Ã                                     Ä',13,10 
	dc.b      ' ÃScroll up ......... ',1,' / Right buttonÄ ÃPrint page ........................ PÄ',13,10 
	dc.b      ' ÃScroll down ........ ',2,' / Left buttonÄ ÃPrint all text ............... CTRL PÄ',13,10 
	dc.b      ' ÃPage up .................... Shift ',1,'Ä ÃAbort printing .................. EscÄ',13,10 
	dc.b      ' ÃPage down .......... Shift ',2,' / SpaceÄ ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
	dc.b      ' Ã                                    Ä ñ ',27,'bPRINTER CONFIGURATION',27,'n õõõõõõõõõõõõõõó',13,10 
	dc.b      ' ÃTop of text .................. Alt TÄ Ã                                     Ä',13,10 
	dc.b      ' Ãbottom of text ............... Alt BÄ Ã',27,'bD',27,'nriver     '
atari	dc.b      'è ATARI       '
epson	dc.b      'é EPSON FX  Ä',13,10 
	dc.b      ' Ã                                    Ä Ã',27,'bT',27,'nype       '
color	dc.b      'è COLOR       '
mono	dc.b      'é MONOCHROM Ä',13,10 
	dc.b      ' ÃFind text ........................ FÄ Ã',27,'bM',27,'node       '
draft	dc.b      'é DRAFT       '
final	dc.b      'è FINAL     Ä',13,10 
	dc.b      ' ÃFind next ........................ NÄ Ã',27,'bO',27,'nutput     '
centron	dc.b      'é CENTRONICS  '
rs232	dc.b      'è RS232     Ä',13,10 
	dc.b      ' ÃFind previous .................... BÄ Ã',27,'bP',27,'naper      '
listing	dc.b      'é LISTING     '
a4_form	dc.b      'è A4 FORMAT Ä',13,10 
	dc.b      ' Ã                                    Ä ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
	dc.b      ' ÃShift F1 ',3,' F10 ..... Set mark 1 ',3,' 10Ä ñ ',27,'bUSER',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõó',13,10 
	dc.b      ' ÃF1 ',3,' F10 .......... Goto mark 1 ',3,' 10Ä Ã                                     Ä',13,10 
	dc.b      ' ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö ÃChange colors ..................... <Ä',13,10 
	dc.b      ' ñ ',27,'bGREETINGS',27,'n õõõõõõõõõõõõõõõõõõõõõõõõõó Ã50/60Hz ........................... SÄ',13,10 
	dc.b      ' Ã                                    Ä ÃMusic ON/OFF ...................... #Ä',13,10 
	dc.b      ' Ã Hi to : FUZION, ARTIS MAGIA, NGC   Ä ÃQuit ......................... CTRL QÄ',13,10 
	dc.b      ' Ã YOYO, RAF, MISFITS, MAD VISION...  Ä ÃBoot ....................... CTRL DELÄ',13,10 
	dc.b      ' ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö ôõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõõö',13,10 
	dc.b      0,0 



tbs_mark	dc.b	'tbs!',$0d,$0a
;
;	document file goes here
;
doc_file
	incbin	'e:\articles\compacts.asc'
	even

l00b2	dc.b	$20,$00
;
;	various	toggles	& offsets
;
tog_table	dc.b	$00
	dc.b	$00
	dc.b	$4d
	dc.b	$58
	dc.b	$04
	dc.b	$01		; tune no.
	dc.b	$ff
	dc.b	$ff
	dc.b	$ff
	dc.b	$ff
	dc.w	$0		;music init offset
	dc.b	$ff
	dc.b	$ff
	dc.w	$2		; music vbl offset
	dc.w	$37d1

;
;	music file goes here
;
music	incbin	'd:\musichak.mug\sentry\horr*.xms'
	even

	bss
music_tog	ds.w	1
line_a	ds.b	8
l00b7	ds.w	1
old_rez	ds.w	1
old_pal	ds.b	8
bell_stat	ds.w	1
old_456	ds.l	1
l00bc	ds.l	1
l00bd	ds.l	1
l00be	ds.l	1
l00bf	ds.l	1
l00c0	ds.l	1
l00c1	ds.b	16
zuend	end
