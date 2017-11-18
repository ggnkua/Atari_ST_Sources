*	File	E:\WORMEN\WORMDIG.S
*	Created by TT-DIGGER v4.0
*	1996/09/12  14:18:20

*		TEXT	7508 bytes, segment starts at Start
*		DATA	598 bytes, segment starts at __data
*		BSS	9236 bytes, segment starts at _BasPag
*		SYMBOLS	2380 bytes
*		FLAG	0
*		External names not listed 

		.text

Start:		movea.l	a0,a3
		move.l	a3,d0
		bne.b	ACC
		movea.l	4(a7),a3
		moveq	#1,d0
		bra.b	APP

ACC:		clr	d0
APP:		move.l	a3,_BasPag
		move	d0,_app
		movea.l	12(a3),a0
		adda.l	20(a3),a0
		adda.l	28(a3),a0
		adda	#256,a0
		move.l	a0,_PgmSize
		move.l	a3,d0
		add.l	a0,d0
		and.b	#252,d0
		movea.l	d0,a7
		sub.l	#768,d0
		move.l	d0,_StkLim
		tst	_app
		beq.w	Start8
		sub.l	#250,d0
		and.b	#252,d0
		movea.l	d0,a1
		movea.l	a1,a4
		movea.l	44(a3),a2
		move.l	a2,(a1)+
Start1:		tst.b	(a2)+
		bne.b	Start1
		move.l	a2,(a1)+
		tst.b	(a2)+
		bne.b	Start1
		clr.l	-(a1)
		move.l	a0,-(a7)
		move.l	a3,-(a7)
		move	#0,-(a7)
		move	#74,-(a7)	; Mshrink
		trap	#1		; Gemdos
		lea	12(a7),a7
		lea	128(a3),a0
		move.b	(a0),d1
		cmp.b	#126,d1
		bmi.b	vallidLe
		addq.l	#1,a0
		moveq	#-1,d1
getLen:		addq	#1,d1
		move.b	(a0)+,d0
		bne.b	getLen
		lea	128(a3),a0
vallidLe:	move	#1,d3
		ext	d1
		lea	1(a0,d1),a1
		clr.b	(a1)
		clr.l	-(a7)
		bra.b	Start5

Start2:		cmpi.b	#33,(a1)
		bpl.b	Start3
		clr.b	(a1)
		tst.b	1(a1)
		beq.b	Start3
		pea	1(a1)
		addq	#1,d3
		bra.b	Start5

Start3:		cmpi.b	#34,(a1)
		bne.b	Start5
		move.b	#0,(a1)
Start4:		subq	#1,a1
		cmpi.b	#34,(a1)
		dbeq	d1,Start4
		subq	#1,d1
		bmi.b	Start6
		pea	1(a1)
		addq	#1,d3
		clr.b	(a1)
Start5:		subq.l	#1,a1
		dbf 	d1,Start2
Start6:		tst.b	1(a1)
		beq.b	Start7
		pea	1(a1)
		addq	#1,d3
Start7:		pea	EmpStr
		movea.l	a7,a2
Start8:		move	d3,d0
		movea.l	a2,a0
		movea.l	a4,a1
		jsr	main
exit:		move	d0,-(a7)
		move.l	_AtExitV,d0
		beq.b	__exit
		movea.l	d0,a0
		jsr	(a0)
__exit:		move.l	_FilSysV,d0
		beq.b	Exit1
		movea.l	d0,a0
		jsr	(a0)
Exit1:		jsr	_FreeAll
R296		equ	*-2
		move	#76,-(a7)	; Pterm
		trap	#1		; Gemdos
Rnd:		link	a6,#0
		bsr.w	Random
		fmove.l	d0,fp0
		fdiv.x	T7676,fp0
		unlk	a6
		rts

main:		link	a6,#-12
		movem.l	d3/a2-a5,-(a7)
		bsr.w	appl_ini
		lea	T7688,a0
R342		equ	*-4
		bsr.w	rsrc_loa
		tst	d0
		bne.b	R376
		lea	T7698,a0
		moveq	#1,d0
		bsr.w	form_ale
R366:		bsr.w	appl_exi
		moveq	#1,d0
		bra.w	R1520

R376:		lea	J,a2
		suba.l	a1,a1
		lea	-2(a2),a0
		bsr.w	instt_sc
		lea	scr,a3
		lea	xy,a4
		fmove	(a3),fp0
		fmove.x	fp0,-46(a4)
		fmove	2(a3),fp1
		fmove.x	fp1,-34(a4)
		move	(a3),4(a4)
		move	2(a3),6(a4)
		movea.l	a4,a0
		moveq	#1,d1
		move	-2(a2),d0
		bsr.w	vs_clip
		lea	6(a2),a5
		movea.l	a5,a0
		clr	d1
		clr	d0
		bsr.w	rsrc_gad
		movea.l	(a5),a0
		move.l	132(a0),10(a2)
		move.l	156(a0),14(a2)
		move.l	180(a0),18(a2)
		move.l	204(a0),22(a2)
		move.l	228(a0),26(a2)
		pea	-6(a6)
		pea	-8(a6)
		pea	-10(a6)
		lea	-12(a6),a1
		bsr.w	form_cen
		lea	12(a7),a7
R518:		suba.l	a0,a0
		clr	d0
		bsr.w	graf_mou
		movea.l	(a5),a0
		andi	#-2,322(a0)
		movea.l	(a5),a0
		andi	#-2,250(a0)
		movea.l	(a5),a0
		andi	#-2,298(a0)
		move	-2(a2),d1
		clr	d0
		movea.l	(a5),a0
		bsr.w	form_sav
		move.l	a0,-4(a6)
		pea	scr_grec
		moveq	#1,d0
		move	d0,-(a7)
		moveq	#5,d2
		move	d0,d1
		movea.l	a0,a1
		movea.l	(a5),a0
		move	-2(a2),d0
		bsr.w	form_mov
		addq	#6,a7
		move	d0,d3
		movea.l	-4(a6),a1
		move	-2(a2),d1
		movea.l	(a5),a0
		clr	d0
		bsr.w	form_res
		cmp	#10,d3
		beq.w	R1506
		suba.l	a0,a0
		move	#256,d0
		bsr.w	graf_mou
		clr	-(a7)
		clr	-(a7)
		moveq	#1,d2
		moveq	#1,d1
		move	-2(a2),d0
		bsr.w	deffill
		addq	#4,a7
		moveq	#3,d1
		move	-2(a2),d0
		bsr.w	vswr_mod
		cmp	#13,d3
		beq.b	R680
		cmp	#12,d3
		bne.w	R976
		move	8(a4),d0
		bne.w	R976
R680:		move	#1,8(a4)
		movea.l	10(a2),a0
		movea.l	(a0),a0
		bsr.w	atoi
		move	d0,-4(a4)
		movea.l	14(a2),a0
		movea.l	(a0),a0
		bsr.w	atoi
		move	d0,-2(a4)
		movea.l	18(a2),a0
		movea.l	(a0),a0
		bsr.w	atoi
		move	d0,-6(a4)
		movea.l	22(a2),a0
		movea.l	(a0),a0
		bsr.w	atoi
		move	d0,-10(a4)
		movea.l	26(a2),a0
		movea.l	(a0),a0
		bsr.w	atoi
		move	d0,-8(a4)
		fmove	-6(a4),fp0
R760		equ	*-2
		fmul.x	-58(a4),fp0
		fdiv.x	-22(a4),fp0
		fmove.x	fp0,-18(a2)
		move	-2(a2),d0
		bsr.w	v_clrwk
		clr	(a2)
		bra.b	R852

R792:		clr	2(a2)
		bra.b	R842

R798:		moveq	#100,d0
		muls	(a2),d0
		move	2(a2),d1
		add	d1,d1
		add	d1,d0
		lea	-4354(a2),a0
		clr	0(a0,d0)
		moveq	#100,d0
		muls	(a2),d0
		move	2(a2),d1
		add	d1,d1
		add	d1,d0
		lea	-2354(a2),a1
		clr	0(a1,d0)
		addq	#1,2(a2)
R842:		cmpi	#50,2(a2)
		blt.b	R798
		addq	#1,(a2)
R852:		cmpi	#20,(a2)
		blt.b	R792
		clr	(a2)
		bra.b	R968

R862:		bsr.w	Rnd
		fmul.x	-46(a4),fp0
		fintrz.x fp0
		fmove	fp0,d0
		moveq	#100,d1
		muls	(a2),d1
		lea	-4354(a2),a0
		move	d0,0(a0,d1)
		bsr.w	Rnd
		fmul.x	-34(a4),fp0
		fintrz.x fp0
		fmove	fp0,d0
		moveq	#100,d1
		muls	(a2),d1
		lea	-2354(a2),a0
		move	d0,0(a0,d1)
		bsr.w	Rnd
		fmul.x	T7726,fp0
		fmul.x	-58(a4),fp0
		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	fp0,0(a0,d0)
		move	(a2),d0
		add	d0,d0
		lea	-354(a2),a1
		clr	0(a1,d0)
		addq	#1,(a2)
R968:		move	(a2),d0
		cmp	-2(a4),d0
		blt.b	R862
R976:		bsr.w	Rnd
		fmul	-2(a4),fp0
		fintrz.x fp0
		fmove	fp0,d0
		move	d0,(a2)
		add	d0,d0
		lea	-354(a2),a0
		move	(a2),d1
		add	d1,d1
		lea	-314(a2),a1
		move	0(a0,d0),0(a1,d1)
		move	(a2),d0
		add	d0,d0
		move	0(a0,d0),d1
		ext.l	d1
		divs	-4(a4),d1
		swap	d1
		addq	#1,d1
R1034:		move	d1,0(a0,d0)
		moveq	#100,d0
		muls	(a2),d0
		add	d1,d1
		add	d1,d0
		lea	-4354(a2),a1
		move	0(a1,d0),d2
		move	d2,4(a4)
		move	d2,(a4)
		lea	-2354(a2),a0
		move	0(a0,d0),d3
		move	d3,6(a4)
		move	d3,2(a4)
		move	(a4),d2
		bne.b	R1084
		tst	d3
		beq.b	R1116
R1084:		move	-10(a4),-(a7)
		move	2(a4),d2
		move	(a4),d1
R1094:		move	-2(a2),d0
		bsr.w	v_circle
		addq	#2,a7
		movea.l	a4,a0
		moveq	#2,d1
		move	-2(a2),d0
		bsr.w	v_pline
R1116:		bsr.w	Rnd
		fmove.x	fp0,-30(a2)
		fcmp.x	T7738,fp0
		fbge.w	R1166
		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	0(a0,d0),fp1
		fadd.x	-18(a2),fp1
		fmove.x	fp1,0(a0,d0)
R1160		equ	*-4
		bra.b	R1192

R1166:		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	0(a0,d0),fp0
		fsub.x	-18(a2),fp0
		fmove.x	fp0,0(a0,d0)
R1192:		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fcos.x	0(a0,d0),fp0
		fmul	-8(a4),fp0
		fintrz.x fp0
		fmove	fp0,d1
		moveq	#100,d2
		muls	(a2),d2
		move	(a2),d3
		add	d3,d3
		lea	-314(a2),a1
		move	0(a1,d3),d0
		add	d0,d0
		add	d0,d2
		lea	-4354(a2),a0
		add	0(a0,d2),d1
		ext.l	d1
		divs	(a3),d1
		swap	d1
		move	d1,-274(a2)
		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fsin.x	0(a0,d0),fp0
		fmul	-8(a4),fp0
		fintrz.x fp0
		fmove	fp0,d2
		moveq	#100,d3
		muls	(a2),d3
		move	(a2),d1
		add	d1,d1
		lea	-314(a2),a1
		move	0(a1,d1),d0
		add	d0,d0
		add	d0,d3
		lea	-2354(a2),a0
		add	0(a0,d3),d2
		ext.l	d2
		divs	2(a3),d2
		swap	d2
		move	d2,-272(a2)
		move	-274(a2),d0
		bpl.b	R1338
		move	(a3),d1
		add	d1,-274(a2)
R1338:		move	-272(a2),d0
		bpl.b	R1352
		move	2(a3),d1
		add	d1,-272(a2)
R1352:		moveq	#100,d0
		muls	(a2),d0
		move	(a2),d1
		add	d1,d1
		lea	-354(a2),a0
		move	0(a0,d1),d2
		add	d2,d2
		add	d2,d0
		lea	-4354(a2),a1
		move	-274(a2),0(a1,d0)
		moveq	#100,d0
		muls	(a2),d0
		move	(a2),d1
		add	d1,d1
		move	0(a0,d1),d2
		add	d2,d2
		add	d2,d0
		lea	-2354(a2),a1
		move	-272(a2),0(a1,d0)
		move	-10(a4),-(a7)
		move	-272(a2),d2
		move	-274(a2),d1
		move	-2(a2),d0
		bsr.w	v_circle
		addq	#2,a7
		move	#255,d0
		bsr.w	Crawio
		move	d0,4(a2)
		tst	d0
		beq.w	R976
		andi	#255,4(a2)
		cmpi	#32,4(a2)
		bne.b	R1476
		moveq	#2,d0
		bsr.w	Bconin
		and	#255,d0
		move	d0,4(a2)
R1476:		cmpi	#99,4(a2)
		beq.w	R976
		suba.l	a0,a0
		move	#257,d0
		bsr.w	graf_mou
		cmpi	#113,4(a2)
		bne.w	R518
R1506:		move	-2(a2),d0
		bsr.w	v_clsvwk
		bsr.w	appl_exi
		clr	d0
R1520:		movem.l	-32(a6),d3/a2-a5
		unlk	a6
		rts

find_ob:	link	a6,#0
		movem.l	d3-d6/a2,-(a7)
		movea.l	a0,a2
		move	d0,d6
		clr	d3
		moveq	#8,d4
		moveq	#1,d5
		move	d1,d2
		addq	#3,d2
		beq.b	R1572
		subq	#1,d2
		beq.b	R1566
		subq	#1,d2
		beq.b	R1564
		bra.b	R1614

R1564:		moveq	#-1,d5
R1566:		move	d6,d3
		add	d5,d3
		bra.b	R1614

R1572:		moveq	#2,d4
		bra.b	R1614

R1576:		move	d3,d1
		ext.l	d1
		move.l	d1,d0
		add.l	d0,d0
		add.l	d1,d0
		lsl.l	#3,d0
		move	8(a2,d0.l),d1
		move	d1,d2
		and	d4,d2
		beq.b	R1602
		move	d3,d0
		bra.b	R1620

R1602:		moveq	#32,d0
		and	d1,d0
		beq.b	R1612
		moveq	#-1,d3
		bra.b	R1614

R1612:		add	d5,d3
R1614:		tst	d3
		bpl.b	R1576
		move	d6,d0
R1620:		movem.l	-20(a6),d3-d6/a2
		unlk	a6
		rts

init_fie:	link	a6,#0
		move	d3,-(a7)
		move	d0,d3
		tst	d0
		bne.b	R1652
		moveq	#-2,d1
		clr	d0
		bsr.w	find_ob
		move	d0,d3
R1652:		move	d3,d0
		move	-2(a6),d3
		unlk	a6
		rts

aform_do:	link	a6,#-20
		movem.l	d3-d6/a2-a5,-(a7)
		movea.l	a0,a2
		move	d0,d3
		move.l	a1,-20(a6)
		move	d1,d6
		lea	-16(a6),a3
		move	d3,d0
		movea.l	a2,a0
		bsr.w	init_fie
		move	d0,(a3)
		clr	d3
		moveq	#1,d4
		move	d4,d0
		bsr.w	wind_upd
		moveq	#3,d0
		bsr.w	wind_upd
		lea	-14(a6),a4
		lea	-4(a6),a5
		bra.w	R1954

R1722:		move	(a3),d0
		beq.b	R1748
		cmp	d0,d3
		beq.b	R1748
		move	d0,d3
		clr	(a3)
		moveq	#1,d2
		movea.l	a4,a1
		clr	d1
		move	d3,d0
		movea.l	a2,a0
		bsr.w	objc_edi
R1748:		pea	-2(a6)
		pea	(a5)
		pea	-6(a6)
		pea	-8(a6)
		pea	-10(a6)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		clr	-(a7)
		moveq	#1,d0
		move	d0,-(a7)
		lea	-12(a6),a1
		suba.l	a0,a0
		move	d0,d2
		moveq	#2,d1
		moveq	#3,d0
		bsr.w	evnt_mul
		lea	46(a7),a7
		move	d0,d5
		moveq	#1,d1
		and	d0,d1
		beq.b	R1858
		pea	(a5)
		movea.l	a3,a1
		move	(a5),d2
		movea.l	a2,a0
		move	d3,d0
		move	(a3),d1
		bsr.w	form_key
		addq	#4,a7
		move	d0,d4
		move	(a5),d1
		beq.b	R1858
		moveq	#2,d2
		movea.l	a4,a1
		movea.l	a2,a0
		move	d3,d0
		bsr.w	objc_edi
R1858:		moveq	#2,d0
		and	d5,d0
		beq.b	R1928
		move	-10(a6),-(a7)
		move	-12(a6),d2
		moveq	#8,d1
		movea.l	a2,a0
		clr	d0
		bsr.w	objc_fin
		addq	#2,a7
		move	d0,(a3)
		addq	#1,d0
		bne.b	R1900
		moveq	#7,d0
		bsr.w	Cconout
		clr	(a3)
		bra.b	R1928

R1900:		tst	d6
		beq.b	R1912
		cmp	(a3),d6
		bne.b	R1912
		clr	d4
		bra.b	R1928

R1912:		movea.l	a3,a1
		move	-2(a6),d1
		move	(a3),d0
		movea.l	a2,a0
		bsr.w	form_but
		move	d0,d4
R1928:		tst	d4
		beq.b	R1940
		move	(a3),d0
		beq.b	R1954
		cmp	d0,d3
		beq.b	R1954
R1940:		moveq	#3,d2
		movea.l	a4,a1
		clr	d1
		move	d3,d0
		movea.l	a2,a0
		bsr.w	objc_edi
R1954:		tst	d4
		bne.w	R1722
		moveq	#2,d0
		bsr.w	wind_upd
		clr	d0
		bsr.w	wind_upd
		move.l	-20(a6),d0
		beq.b	R1982
		movea.l	d0,a0
		move	d3,(a0)
R1982:		move	(a3),d0
		movem.l	-52(a6),d3-d6/a2-a5
		unlk	a6
		rts

get_cook:	movem.l	d3/a2-a3,-(a7)
		move.l	d0,d3
		movea.l	a0,a3
		suba.l	a0,a0
		jsr	Super
		move.l	d0,sstack
		movea.l	1440.w,a2
		movea.l	d0,a0
		jsr	Super
		move.l	a2,d0
		bne.b	R2052
		bra.b	R2056

R2034:		cmp.l	(a2),d3
		bne.b	R2050
		move.l	a3,d0
		beq.b	R2046
		move.l	4(a2),(a3)
R2046:		moveq	#1,d0
		bra.b	R2058

R2050:		addq	#8,a2
R2052:		move.l	(a2),d0
		bne.b	R2034
R2056:		clr	d0
R2058:		movem.l	(a7)+,d3/a2-a3
		rts

copy_gfo:	movem.l	d3/a2-a4,-(a7)
		move	d0,d3
		movea.l	a0,a4
		movea.l	a1,a3
		lea	20(a7),a2
		moveq	#-1,d0
		add	(a2),d0
		add	d0,4(a2)
		moveq	#-1,d0
		add	2(a2),d0
		add	d0,6(a2)
		moveq	#-1,d0
		add	8(a2),d0
		add	d0,12(a2)
		moveq	#-1,d0
		add	10(a2),d0
		add	d0,14(a2)
		move.l	a3,-(a7)
		movea.l	a4,a1
		movea.l	a2,a0
		moveq	#3,d1
		move	d3,d0
		jsr	vro_cpyf
		addq	#4,a7
		movem.l	(a7)+,d3/a2-a4
		rts

instt_sc:	movem.l	d3/a2-a6,-(a7)
		subq	#2,a7
		movea.l	a0,a4
		movea.l	a1,a5
		lea	_fhc,a2
		lea	scr,a3
		pea	(a7)
		pea	4(a7)
		movea.l	a2,a1
		lea	1814(a3),a0
		jsr	graf_han
		addq	#8,a7
		move	d0,(a4)
		clr	d3
		bra.b	R2200

R2188:		move	d3,d0
		add	d0,d0
		move	#1,0(a3,d0)
		addq	#1,d3
R2200:		cmp	#10,d3
		ble.b	R2188
		move	#2,20(a3)
		pea	(a3)
		movea.l	a4,a1
		movea.l	a3,a0
		jsr	v_opnvwk
		addq	#4,a7
		move	(a4),146(a3)
		moveq	#1,d1
		move	(a4),d0
		jsr	vsf_inte
		clr	d1
		move	(a4),d0
		jsr	vsf_styl
		clr	d1
		move	(a4),d0
		jsr	vsf_colo
		clr	d1
		move	(a4),d0
		jsr	vsf_peri
		lea	(a7),a1
		lea	(a7),a0
		moveq	#4,d2
		clr	d1
		move	(a4),d0
		jsr	vst_alig
		lea	instmfdb,a6
		move	(a3),-24(a6)
		move	2(a3),-22(a6)
		addq	#1,(a3)
		addq	#1,2(a3)
		move	(a3),1818(a3)
		move	2(a3),1816(a3)
		move	1818(a3),-32(a6)
		move	1816(a3),-30(a6)
		move	70(a3),d0
		beq.b	R2340
		moveq	#-1,d1
		bra.b	R2342

R2340:		moveq	#1,d1
R2342:		move	d1,70(a3)
		move	(a2),132(a3)
		move	1814(a3),130(a3)
		move	26(a3),d3
		lea	148(a3),a0
		moveq	#1,d1
		move	(a4),d0
		jsr	vq_extnd
		lea	1810(a3),a4
		move	156(a3),(a4)
		move	(a4),122(a3)
		move	(a3),d0
		ext.l	d0
		move	2(a3),d1
		ext.l	d1
		jsr	_lmul
		move	(a4),d1
		ext.l	d1
		jsr	_lmul
		moveq	#8,d1
		jsr	_ldiv
		move.l	d0,126(a3)
		suba.l	a0,a0
		move.l	#1229803077,d0
		jsr	get_cook
		move	d0,1822(a3)
		cmpi	#4,(a4)
		bne.b	R2460
		cmpi	#8,(a2)
		bne.b	R2460
		clr	124(a3)
		bra.b	R2478

R2460:		cmpi	#2,(a4)
		bne.b	R2518
		cmpi	#8,(a2)
		bne.b	R2518
		move	#1,124(a3)
R2478:		cmpi	#512,78(a3)
		ble.b	R2490
		moveq	#3,d0
		bra.b	R2492

R2490:		moveq	#2,d0
R2492:		move	d0,134(a3)
		cmpi	#512,78(a3)
		ble.b	R2508
		moveq	#16,d1
		bra.b	R2510

R2508:		clr	d1
R2510:		move	d1,142(a3)
		bra.w	R2704

R2518:		cmpi	#1,(a4)
		bne.b	R2586
		cmpi	#16,(a2)
		bne.b	R2586
		cmpi	#-1,70(a3)
		bne.b	R2558
		move	#3,134(a3)
R2544:		move	#2,124(a3)
R2550:		clr	142(a3)
		bra.w	R2704

R2558:		cmpi	#1024,(a3)
		ble.b	R2578
		move	#5,124(a3)
		move	#3,134(a3)
		bra.b	R2550

R2578:		move	#2,134(a3)
		bra.b	R2544

R2586:		cmpi	#8,(a4)
		bne.b	R2622
		cmpi	#16,(a2)
		bne.b	R2622
		move	(a3),d0
		cmp	2(a3),d0
		ble.b	R2614
		move	#6,124(a3)
		bra.b	R2676

R2614:		move	#3,124(a3)
		bra.b	R2640

R2622:		cmpi	#4,(a4)
		bne.b	R2648
		cmpi	#16,(a2)
		bne.b	R2648
		move	#4,124(a3)
R2640:		move	#3,134(a3)
		bra.b	R2682

R2648:		cmpi	#8,(a4)
		ble.b	R2690
		move	158(a3),d0
		bne.b	R2690
		cmpi	#16,(a4)
		bne.b	R2670
		moveq	#7,d1
		bra.b	R2672

R2670:		moveq	#8,d1
R2672:		move	d1,124(a3)
R2676:		move	#1,134(a3)
R2682:		move	#16,142(a3)
		bra.b	R2704

R2690:		lea	T7869,a0
		moveq	#1,d0
		jsr	form_ale
R2704:		move	(a3),d0
		ext.l	d0
		move.l	d0,114(a3)
		move	2(a3),d1
		ext.l	d1
		move.l	d1,118(a3)
		move	(a3),d0
		ext.l	d0
		divs	1814(a3),d0
		muls	(a4),d0
		move	d0,138(a3)
		moveq	#-1,d1
		add	(a4),d1
		add	d1,d1
		move	d1,140(a3)
		move	138(a3),d0
		ext.l	d0
		divs	#2,d0
		move	d0,136(a3)
		move	d0,1820(a3)
		move	138(a3),1808(a3)
		move.l	a5,d0
		beq.b	R2780
		move.l	d0,1802(a3)
		bra.b	R2820

R2780:		move.l	126(a3),d0
		add.l	#512,d0
		jsr	Malloc
		move.l	a0,1802(a3)
		move.l	a0,d0
		bne.b	R2820
		moveq	#1,d0
		movea.l	-40(a6),a0
		jsr	form_ale
		suba.l	a0,a0
		bra.b	R2932

R2820:		move.l	1802(a3),d0
		asr.l	#8,d0
		addq.l	#1,d0
		lsl.l	#8,d0
		move.l	d0,1802(a3)
		jsr	Physbase
		move.l	a0,1798(a3)
		move.l	a0,d0
		move.l	1802(a3),d1
		eor.l	d1,d0
		move.l	d0,1828(a3)
		jsr	Logbase
		move.l	a0,1824(a3)
		move	1818(a3),4(a6)
		move	1816(a3),6(a6)
		move	1818(a3),d0
		ext.l	d0
		divs	#16,d0
		move	d0,8(a6)
		move	(a4),12(a6)
		clr	1832(a3)
		clr	1834(a3)
		move	1818(a3),1836(a3)
		move	1816(a3),1838(a3)
		lea	1832(a3),a0
		lea	1840(a3),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		movea.l	1802(a3),a0
R2932:		addq	#2,a7
		movem.l	(a7)+,d3/a2-a6
		rts

R2940:		move.l	a2,-(a7)
		lea	-12(a7),a7
		lea	U14392,a2
		move	(a2),d0
		add	d0,16(a2)
		move	2(a2),d0
		add	d0,18(a2)
		lea	32(a2),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		lea	24(a2),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		lea	16(a7),a1
		lea	18(a7),a0
		move	32(a2),d1
		move	form_out,d0
		pea	20(a7)
		jsr	snapbox
		lea	20(a7),a7
		lea	4(a7),a0
		lea	-8(a2),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move	2(a7),d0
		beq.b	R3038
		move	-8(a2),16(a2)
R3038:		move	(a7),d0
		beq.b	R3048
		move	-6(a2),18(a2)
R3048:		lea	12(a7),a7
		movea.l	(a7)+,a2
		rts

aform_mo:	movem.l	d3-d5/a2-a5,-(a7)
		lea	-56(a7),a7
		movea.l	a0,a4
		move	d2,d5
		move	92(a7),d4
		clr	d3
		lea	MFDBnull,a0
		lea	36(a7),a2
		moveq	#4,d2
R3086:		move.l	(a0)+,(a2)+
		dbf 	d2,R3086
		lea	16(a7),a2
		lea	MFDBnull,a0
		movea.l	a2,a3
		moveq	#4,d2
R3106:		move.l	(a0)+,(a3)+
		dbf 	d2,R3106
		move	d0,form_hnd
		lea	U14384,a5
		movea.l	94(a7),a0
		lea	32(a5),a3
		move.l	(a0)+,(a3)+
		move.l	(a0)+,(a3)+
		move	d1,40(a5)
		move.l	a1,(a2)
R3142:		pea	(a2)
		move.l	a4,-(a7)
		clr	d0
		movea.l	a5,a1
		lea	8(a7),a0
		jsr	form_set
		addq	#8,a7
		movea.l	a5,a0
		lea	8(a7),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move	d4,d1
		movea.l	88(a7),a1
		move	d5,d0
		movea.l	a4,a0
		jsr	aform_do
		move	d0,d3
		cmp	d0,d4
		bne.w	R3410
		suba.l	a0,a0
		move	#256,d0
		jsr	graf_mou
		lea	16(a7),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		lea	52(a7),a1
		movea.l	a2,a0
		move	form_hnd,d0
		jsr	copy_gfo
		lea	16(a7),a7
		suba.l	a0,a0
		move	#257,d0
		jsr	graf_mou
		pea	R2940(pc)
		moveq	#1,d1
		lea	8(a5),a1
		movea.l	a5,a0
		move	form_hnd,d0
		jsr	movebox
		addq	#4,a7
		move	(a5),d0
		add	form_out,d0
		move	d0,16(a4)
		move	2(a5),d1
		add	form_out,d1
		move	d1,18(a4)
		pea	(a2)
		move.l	a4,-(a7)
		clr	d0
		lea	8(a7),a1
		lea	16(a7),a0
		jsr	form_set
		addq	#8,a7
		suba.l	a0,a0
		move	#256,d0
		jsr	graf_mou
		lea	16(a7),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		movea.l	a2,a1
		lea	52(a7),a0
		move	form_hnd,d0
		jsr	copy_gfo
		lea	16(a7),a7
		suba.l	a0,a0
		move	#257,d0
		jsr	graf_mou
		lea	8(a5),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		clr	d0
		movea.l	a4,a0
		jsr	draw_ob
		addq	#8,a7
		bra.w	R3142

R3410:		move	d3,d0
		lea	56(a7),a7
		movem.l	(a7)+,d3-d5/a2-a5
		rts

form_mov:	move.l	6(a7),-(a7)
		move	8(a7),-(a7)
		clr.l	-(a7)
		bsr.w	aform_mo
		lea	10(a7),a7
		rts

draw_ob:	movem.l	d3/a2-a3,-(a7)
		movea.l	a0,a3
		move	d0,d3
		lea	16(a7),a2
		move	6(a2),-(a7)
		move	4(a2),-(a7)
		move	2(a2),-(a7)
		move	(a2),d2
		moveq	#8,d1
		move	d3,d0
		movea.l	a3,a0
		jsr	objc_dra
		addq	#6,a7
		movem.l	(a7)+,d3/a2-a3
		rts

form_set:	movem.l	d3/a2-a5,-(a7)
		subq	#4,a7
		movea.l	a0,a2
		movea.l	a1,a4
		move	d0,d3
		movea.l	32(a7),a5
		pea	(a7)
		lea	6(a7),a1
		movea.l	32(a7),a0
		jsr	objc_off
		addq	#4,a7
		lea	form_out,a3
		move	#3,(a3)
		move	2(a7),d0
		sub	(a3),d0
		move	d0,(a4)
		move	(a7),d1
		sub	(a3),d1
		move	d1,2(a4)
		move	(a3),d0
		add	d0,d0
		move	d3,d1
		ext.l	d1
		move.l	d1,d2
		add.l	d2,d2
		add.l	d1,d2
		lsl.l	#3,d2
		movea.l	28(a7),a0
		add	20(a0,d2.l),d0
		move	d0,4(a4)
		move	(a3),d0
		add	d0,d0
		add	22(a0,d2.l),d0
		move	d0,6(a4)
		move	4(a4),d3
		asr	#4,d3
		addq	#1,d3
		lsl	#4,d3
		move	d3,4(a5)
		move	6(a4),6(a5)
		move	4(a5),d0
		ext.l	d0
		divs	#16,d0
		move	d0,8(a5)
		lea	scr,a0
		move	156(a0),12(a5)
		move	2(a7),d0
		cmp	(a3),d0
		bge.b	R3644
		clr	(a4)
R3644:		move	(a7),d0
		cmp	(a3),d0
		bge.b	R3654
		clr	2(a4)
R3654:		move	4(a4),d0
		add	(a4),d0
		cmp	(a0),d0
		ble.b	R3672
		move	(a0),d1
		sub	(a4),d1
		move	d1,4(a4)
R3672:		move	6(a4),d0
		add	2(a4),d0
		cmp	2(a0),d0
		ble.b	R3698
		move	2(a0),d1
		sub	2(a4),d1
		move	d1,6(a4)
R3698:		clr	(a2)
		clr	2(a2)
		move	4(a4),4(a2)
		move	6(a4),6(a2)
		addq	#4,a7
		movem.l	(a7)+,d3/a2-a5
		rts

form_sav:	movem.l	d3-d4/a2-a3,-(a7)
		lea	-56(a7),a7
		movea.l	a0,a3
		move	d0,d3
		move	d1,d4
		lea	MFDBnull,a1
		lea	36(a7),a0
		moveq	#4,d2
R3750:		move.l	(a1)+,(a0)+
		dbf 	d2,R3750
		lea	16(a7),a2
		lea	MFDBnull,a0
		movea.l	a2,a1
		moveq	#4,d0
R3770:		move.l	(a0)+,(a1)+
		dbf 	d0,R3770
		pea	(a2)
		move.l	a3,-(a7)
		move	d3,d0
		lea	8(a7),a1
		lea	16(a7),a0
		bsr.w	form_set
		addq	#8,a7
		move	8(a2),d0
		ext.l	d0
		move	6(a2),d1
		ext.l	d1
		jsr	_lmul
		move	U12692,d1
		ext.l	d1
		jsr	_lmul
		add.l	d0,d0
		jsr	malloc
		move.l	a0,(a2)
		move.l	a0,d0
		bne.b	R3860
		moveq	#1,d0
		movea.l	sch_aler,a0
		jsr	form_ale
		suba.l	a0,a0
		bra.b	R3940

R3860:		suba.l	a0,a0
		move	#256,d0
		jsr	graf_mou
		move	d4,form_hnd
		lea	16(a7),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		movea.l	a2,a1
		lea	52(a7),a0
		move	d4,d0
		jsr	copy_gfo
		lea	16(a7),a7
		suba.l	a0,a0
		move	#257,d0
		jsr	graf_mou
		lea	8(a7),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move	d3,d0
		movea.l	a3,a0
		bsr.w	draw_ob
		addq	#8,a7
		movea.l	(a2),a0
R3940:		lea	56(a7),a7
		movem.l	(a7)+,d3-d4/a2-a3
		rts

form_res:	movem.l	d3-d4/a2-a4,-(a7)
		lea	-56(a7),a7
		movea.l	a0,a4
		move	d0,d3
		move	d1,d4
		movea.l	a1,a3
		lea	MFDBnull,a1
		lea	36(a7),a0
		moveq	#4,d2
R3978:		move.l	(a1)+,(a0)+
		dbf 	d2,R3978
		lea	16(a7),a2
		lea	MFDBnull,a0
		movea.l	a2,a1
		moveq	#4,d0
R3998:		move.l	(a0)+,(a1)+
		dbf 	d0,R3998
		move.l	a3,d0
		beq.b	R4092
		move.l	d0,(a2)
		pea	(a2)
		move.l	a4,-(a7)
		lea	16(a7),a1
		lea	8(a7),a0
		move	d3,d0
		bsr.w	form_set
		addq	#8,a7
		suba.l	a0,a0
		move	#256,d0
		jsr	graf_mou
		lea	16(a7),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		lea	52(a7),a1
		movea.l	a2,a0
		move	d4,d0
		jsr	copy_gfo
		lea	16(a7),a7
		suba.l	a0,a0
		move	#257,d0
		jsr	graf_mou
		movea.l	a3,a0
		jsr	free
R4092:		lea	56(a7),a7
		movem.l	(a7)+,d3-d4/a2-a4
		rts

cont_mov:	move	move_mod,d1
		bne.b	R4124
		tst	d0
		bne.b	R4118
		moveq	#1,d2
		bra.b	R4120

R4118:		clr	d2
R4120:		move	d2,d0
		rts

R4124:		tst	d0
		beq.b	R4132
		moveq	#1,d1
		bra.b	R4134

R4132:		clr	d1
R4134:		move	d1,d0
		rts

movebox:	movem.l	d3-d6/a2-a5,-(a7)
		subq	#6,a7
		move	d0,d3
		movea.l	a0,a2
		movea.l	a1,a3
		move	d1,d4
		move	#21845,d1
		jsr	vsl_udst
		moveq	#7,d1
		move	d3,d0
		jsr	vsl_type
		moveq	#1,d1
		move	d3,d0
		jsr	vsl_colo
		moveq	#3,d1
		move	d3,d0
		jsr	vswr_mod
		tst	d4
		beq.b	R4214
		lea	8(a2),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move	d3,d0
		jsr	gsbox
		addq	#8,a7
R4214:		move	move_mod,d0
		bne.b	R4234
R4222:		move	d3,d0
		jsr	mousek
		tst	d0
		bne.b	R4222
R4234:		lea	2(a7),a4
		lea	4(a7),a5
		pea	(a4)
		movea.l	a5,a1
		lea	4(a7),a0
		move	d3,d0
		jsr	vq_mouse
		addq	#4,a7
		move	(a5),d4
		move	(a4),d5
		movea.l	a2,a0
		lea	8(a3),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		movea.l	a2,a0
		lea	16(a3),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		lea	T7958,a0
		move	#255,d0
		jsr	graf_mou
R4300:		pea	(a4)
		movea.l	a5,a1
		lea	4(a7),a0
		move	d3,d0
		jsr	vq_mouse
		addq	#4,a7
		move	(a5),d0
		sub	d4,d0
		move	d0,(a3)
		move	(a4),d1
		sub	d5,d1
		move	d1,2(a3)
		movea.l	42(a7),a0
		jsr	(a0)
		move	(a7),d0
		bsr.w	cont_mov
		move	d0,d6
		move	(a2),d1
		cmp	8(a3),d1
		bne.b	R4364
		move	2(a2),d2
		cmp	10(a3),d2
		beq.b	R4414
R4364:		tst	d6
		beq.b	R4414
		lea	16(a3),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move	d3,d0
		jsr	gsbox
		addq	#8,a7
		lea	8(a2),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move	d3,d0
		jsr	gsbox
		addq	#8,a7
		movea.l	a2,a0
		lea	8(a3),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
R4414:		move	(a5),d4
		move	(a4),d5
		tst	d6
		bne.b	R4300
		lea	8(a2),a0
		move.l	-(a0),-(a7)
		move.l	-(a0),-(a7)
		move	d3,d0
		jsr	gsbox
		addq	#8,a7
		move	move_mod,d0
		bne.b	R4466
		cmpi	#1,(a7)
		bne.b	R4458
		moveq	#1,d1
		bra.b	R4460

R4458:		clr	d1
R4460:		move	d1,6(a3)
		bra.b	R4472

R4466:		move	#1,6(a3)
R4472:		moveq	#1,d1
		move	d3,d0
		jsr	vswr_mod
		moveq	#1,d1
		move	d3,d0
		jsr	vsl_type
		move	move_mod,d0
		bne.b	R4512
R4500:		move	d3,d0
		jsr	mousek
		tst	d0
		bne.b	R4500
R4512:		suba.l	a0,a0
		clr	d0
		jsr	graf_mou
		addq	#6,a7
		movem.l	(a7)+,d3-d6/a2-a5
		rts

snapbox:	movem.l	d3/a2-a3,-(a7)
		lea	28(a7),a2
		lea	20(a7),a3
		clr	(a0)
		clr	(a1)
		move	(a3),d2
		cmp	(a2),d2
		bge.b	R4558
		move	(a2),(a3)
		move	#1,(a0)
R4558:		move	(a3),d2
		add	4(a3),d2
		move	(a2),d3
		add	4(a2),d3
		cmp	d3,d2
		ble.b	R4584
		sub	4(a3),d3
		move	d3,(a3)
		move	#1,(a0)
R4584:		move	2(a3),d2
		cmp	2(a2),d2
		bge.b	R4604
		move	2(a2),2(a3)
		move	#1,(a1)
R4604:		move	2(a3),d2
		add	6(a3),d2
		move	2(a2),d3
		add	6(a2),d3
		cmp	d3,d2
		ble.b	R4636
		sub	6(a3),d3
		move	d3,2(a3)
		move	#1,(a1)
R4636:		tst	d1
		beq.b	R4676
		move	(a3),d1
		add	d0,d1
		move	d1,d2
		ext.l	d2
		divs	#8,d2
		move	d2,d1
		lsl	#3,d2
		move	d2,d1
		sub	d0,d2
		cmp	(a2),d2
		bge.b	R4670
		addq	#8,d1
		move	#1,(a0)
R4670:		move	d1,d2
		sub	d0,d2
		move	d2,(a3)
R4676:		movea.l	a3,a0
		movea.l	16(a7),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		movem.l	(a7)+,d3/a2-a3
		rts

gsbox:		move	d3,-(a7)
		move.l	a2,-(a7)
		move	d0,d3
		lea	10(a7),a2
		moveq	#-1,d0
		add	(a2),d0
		add	d0,4(a2)
		moveq	#-1,d0
		add	2(a2),d0
		add	d0,6(a2)
		move	6(a2),-(a7)
		move	4(a2),-(a7)
		move	2(a2),d2
		move	(a2),d1
		move	d3,d0
		jsr	box
		addq	#4,a7
		movea.l	(a7)+,a2
		move	(a7)+,d3
		rts

box:		movem.l	d3-d7,-(a7)
		lea	-20(a7),a7
		move	d0,d7
		move	d1,d3
		move	d2,d5
		move	44(a7),d4
		move	46(a7),d6
		suba.l	a0,a0
		move	#256,d0
		jsr	graf_mou
		move	d3,(a7)
		move	d4,4(a7)
		move	d4,8(a7)
		move	d3,12(a7)
		move	d3,16(a7)
		move	d5,2(a7)
		move	d5,6(a7)
		move	d6,10(a7)
		move	d6,14(a7)
		moveq	#1,d0
		add	d5,d0
		move	d0,18(a7)
		lea	(a7),a0
		moveq	#5,d1
		move	d7,d0
		jsr	v_pline
		suba.l	a0,a0
		move	#257,d0
		jsr	graf_mou
		lea	20(a7),a7
		movem.l	(a7)+,d3-d7
		rts

deffill:	move	d4,-(a7)
		move	d5,-(a7)
		move	d0,d4
		move	d1,d5
		move	d2,d1
		jsr	vsf_inte
		move	8(a7),d1
		move	d4,d0
		jsr	vsf_styl
		move	d5,d1
		move	d4,d0
		jsr	vsf_colo
		move	10(a7),d1
		move	d4,d0
		jsr	vsf_peri
		move	(a7)+,d5
		move	(a7)+,d4
		rts

mousek:		subq	#6,a7
		pea	2(a7)
		lea	8(a7),a1
		lea	4(a7),a0
		jsr	vq_mouse
		addq	#4,a7
		move	(a7),d0
		addq	#6,a7
		rts

atoi:		move	d3,-(a7)
		move	d4,-(a7)
		clr	d0
		lea	_ChrCla1(pc),a1
R4954:		move.b	(a0)+,d0
		beq.b	R5032
		move.b	0(a1,d0),d0
		bmi.b	R4954
		clr	d0
		clr	d1
		move.b	#9,d3
		lea	_DigCnvT(pc),a1
		move.b	-1(a0),d1
		cmp.b	#45,d1
		seq	d2
		beq.b	R4994
		cmp.b	#43,d1
		bne.b	R4998
R4994:		move.b	(a0)+,d1
		beq.b	R5032
R4998:		move.b	0(a1,d1),d1
		cmp.b	d3,d1
		bhi.b	R5032
R5006:		add	d1,d0
		move.b	(a0)+,d1
		beq.b	R5032
		move.b	0(a1,d1),d1
		cmp.b	d3,d1
		bhi.b	R5032
		add	d0,d0
		move	d0,d4
		add	d0,d0
		add	d0,d0
		add	d4,d0
		bra.b	R5006

R5032:		tst.b	d2
		beq.b	R5038
		neg	d0
R5038:		move	(a7)+,d4
		move	(a7)+,d3
		rts

R5044:		movem.l	d3/a2,-(a7)
		move.l	d0,d3
R5050:		move.l	d3,-(a7)
		move	#72,-(a7)	; Malloc
		trap	#1		; Gemdos
		addq	#6,a7
		tst.l	d0
		bne.b	R5084
		move.l	_heapErr,d0
		beq.b	R5084
		movea.l	d0,a0
		move.l	d3,d0
		jsr	(a0)
		tst	d0
		bne.b	R5050
		moveq	#0,d0
R5084:		movea.l	d0,a0
		movem.l	(a7)+,d3/a2
		rts

malloc:		movem.l	d3/a2-a3,-(a7)
		move.l	d0,d3
		beq.w	R5272
		addq.l	#8,d3
		addq.l	#1,d3
		and.b	#254,d3
		cmp.l	#4088,d3
		bcs.b	R5150
		move.l	d3,d0
		bsr.w	R5044
		move.l	a0,d0
		beq.w	R5282
		move.l	d3,4(a0)
		lea	_MemBlkL,a1
		move.l	(a1),(a0)
		move.l	a0,(a1)
		lea	8(a0),a0
		bra.b	R5266

R5150:		lea	_MemCluL,a3
R5156:		movea.l	(a3),a3
		move.l	a3,d0
		bne.b	R5210
		move.l	#8192,d0
		bsr.w	R5044
		move.l	a0,d0
		beq.b	R5282
		movea.l	d0,a3
		lea	8(a3),a0
		moveq	#0,d0
		move.l	d0,(a0)
		move.l	#8184,4(a0)
		move.l	a0,4(a3)
		move.l	_MemCluL,(a3)
		move.l	a3,_MemCluL
R5210:		lea	4(a3),a0
		movea.l	(a0),a1
		bra.b	R5230

R5218:		move.l	4(a1),d0
		sub.l	d3,d0
		bcc.b	R5236
		movea.l	a1,a0
		movea.l	(a1),a1
R5230:		move.l	a1,d0
		bne.b	R5218
		bra.b	R5156

R5236:		moveq	#16,d1
		cmp.l	d1,d0
		bcc.b	R5246
		move.l	(a1),(a0)
		bra.b	R5256

R5246:		move.l	d0,4(a1)
		adda.l	d0,a1
		move.l	d3,4(a1)
R5256:		move.l	#-1796116985,(a1)
		lea	8(a1),a0
R5266:		movem.l	(a7)+,d3/a2-a3
		rts

R5272:		bmi.b	R5282
		movea.l	#-1048576,a0
		bra.b	R5266

R5282:		suba.l	a0,a0
		move	#12,errno
		bra.b	R5266

free:		move.l	a2,-(a7)
		move.l	a0,d0
		ble.b	R5366
		subq.l	#8,a0
		cmpi.l	#-1796116985,(a0)
		bne.b	R5320
		bsr.w	_InsFreB
		tst.b	d0
		beq.b	R5360
		bra.b	R5374

R5320:		lea	_MemBlkL,a1
		move.l	(a1),d0
		beq.b	R5374
R5330:		cmp.l	a0,d0
		beq.b	R5342
		movea.l	d0,a1
		move.l	(a1),d0
		bne.b	R5330
		bra.b	R5374

R5342:		move.l	(a0),(a1)
		move.l	a0,-(a7)
		move	#73,-(a7)	; Mfree
		trap	#1		; Gemdos
		addq	#6,a7
		tst.l	d0
		bpl.b	R5360
		bra.b	R5374

R5360:		moveq	#0,d0
R5362:		movea.l	(a7)+,a2
		rts

R5366:		cmpa.l	#-1048576,a0
		beq.b	R5360
R5374:		moveq	#-1,d0
		bra.b	R5362

_FreeAll:	move.l	a3,-(a7)
		movea.l	_MemBlkL,a3
R5386:		move.l	a3,d0
		beq.b	R5404
		move.l	a3,-(a7)
		movea.l	(a3),a3
		move	#73,-(a7)	; Mfree
		trap	#1		; Gemdos
		addq	#6,a7
		bra.b	R5386

R5404:		movea.l	_MemCluL,a3
R5410:		move.l	a3,d0
		beq.b	R5428
		move.l	a3,-(a7)
		movea.l	(a3),a3
		move	#73,-(a7)	; Mfree
		trap	#1		; Gemdos
		addq	#6,a7
		bra.b	R5410

R5428:		movea.l	(a7)+,a3
		rts

_InsFreB:	movem.l	a2-a4,-(a7)
		move.l	#8176,d2
		lea	-8(a0),a1
		lea	_MemCluL,a3
		move.l	(a3),d0
		beq.w	R5632
R5458:		move.l	a1,d1
		sub.l	d0,d1
		cmp.l	d2,d1
		bls.b	R5476
		movea.l	d0,a3
		move.l	(a3),d0
		bne.b	R5458
		bra.w	R5632

R5476:		movea.l	d0,a4
		move.l	4(a4),d0
		beq.b	R5504
		cmpa.l	d0,a0
		bhi.b	R5530
		move.l	a0,d1
		add.l	4(a0),d1
		cmp.l	d0,d1
		bcs.b	R5504
		beq.b	R5512
		bra.w	R5632

R5504:		move.l	d0,(a0)
		move.l	a0,4(a4)
		bra.b	R5624

R5512:		movea.l	d0,a1
		move.l	4(a1),d1
		add.l	d1,4(a0)
		move.l	(a1),(a0)
		move.l	a0,4(a4)
		bra.b	R5592

R5530:		movea.l	d0,a1
		move.l	(a1),d0
		beq.b	R5540
		cmpa.l	d0,a0
		bhi.b	R5530
R5540:		move.l	a1,d1
		add.l	4(a1),d1
		cmp.l	a0,d1
		bcs.b	R5564
		beq.b	R5554
		bra.b	R5632

R5554:		move.l	4(a0),d1
		add.l	d1,4(a1)
		bra.b	R5570

R5564:		move.l	a0,(a1)
		move.l	d0,(a0)
		movea.l	a0,a1
R5570:		move.l	a1,d1
		add.l	4(a1),d1
		cmp.l	d0,d1
		bne.b	R5592
		movea.l	d0,a0
		move.l	4(a0),d1
		add.l	d1,4(a1)
		move.l	(a0),(a1)
R5592:		movea.l	4(a4),a0
		cmpi.l	#8184,4(a0)
		bcs.b	R5624
		bhi.b	R5632
		move.l	(a4),(a3)
		move.l	a4,-(a7)
		move	#73,-(a7)	; Mfree
		trap	#1		; Gemdos
		addq	#6,a7
		tst.l	d0
		bne.b	R5632
R5624:		sf 	d0
R5626:		movem.l	(a7)+,a2-a4
		rts

R5632:		st 	d0
		bra.b	R5626

_ChrCla1:	dc.b	'@@@@@@@@@',192
		dc.b	192,192,192,192,'@@@@@@@@@@@@@@@@@@',128,1
		dc.b	1,1,1,1,1,1,1,1
		dc.b	1,1,1,1,1,1,18,18
		dc.b	18,18,18,18,18,18,18,18
		dc.b	1,1,1,1,1,1,0,'::::::88888888888888888888',1
		dc.b	1,1,1,1,1,'66666644444444444444444444',1
		dc.b	1,1,1,'@',0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0
		dc.b	0,0,0,0
_DigCnvT:	dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	0,1,2,3,4,5,6,7
		dc.b	8,9,255,255,255,255,255,255
		dc.b	255,10,11,12,13,14,15,16
		dc.b	17,18,19,20,21,22,23,24
		dc.b	25,26,27,28,29,30,31,' !"#',255
		dc.b	255,255,255,255,255,10,11,12
		dc.b	13,14,15,16,17,18,19,20
		dc.b	21,22,23,24,25,26,27,28
		dc.b	29,30,31,' !"#',255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255,255,255,255,255
		dc.b	255,255,255,255

_lmul:		move.l	d0,d2
		bpl.b	R6154
		neg.l	d0
R6154:		eor.l	d1,d2
		movea.l	d2,a0
		tst.l	d1
		bpl.b	R6164
		neg.l	d1
R6164:		move.l	d0,d2
		swap	d2
		tst	d2
		bne.b	R6206
		move.l	d1,d2
		swap	d2
		tst	d2
		bne.b	R6190
		mulu	d1,d0
		move.l	a0,d2
		bpl.b	R6188
		neg.l	d0
R6188:		rts

R6190:		mulu	d0,d2
		swap	d2
		mulu	d1,d0
		add.l	d2,d0
		move.l	a0,d2
		bpl.b	R6204
		neg.l	d0
R6204:		rts

R6206:		mulu	d1,d2
		swap	d2
		mulu	d1,d0
		add.l	d2,d0
		move.l	a0,d2
		bpl.b	R6220
		neg.l	d0
R6220:		rts

_ldiv:		move.l	d0,d2
		bpl.b	R6228
		neg.l	d0
R6228:		eor.l	d1,d2
		movea.l	d2,a1
		tst.l	d1
		bpl.b	R6238
		neg.l	d1
R6238:		move.l	d1,d2
		swap	d2
		tst	d2
		bne.b	R6298
		move.l	d0,d2
		swap	d2
		tst	d2
		bne.b	R6270
		divu	d1,d0
		swap	d0
		clr	d0
		swap	d0
		move.l	a1,d2
		bpl.b	R6268
		neg.l	d0
R6268:		rts

R6270:		clr	d0
		swap	d0
		swap	d2
		divu	d1,d0
		movea	d0,a0
		move	d2,d0
		divu	d1,d0
		swap	d0
		move	a0,d0
		swap	d0
		move.l	a1,d2
		bpl.b	R6296
		neg.l	d0
R6296:		rts

R6298:		movea.l	d1,a0
		swap	d0
		moveq	#0,d1
		move	d0,d1
		clr	d0
		moveq	#15,d2
		add.l	d0,d0
		addx.l	d1,d1
R6314:		sub.l	a0,d1
		bcc.b	R6320
		add.l	a0,d1
R6320:		addx.l	d0,d0
		addx.l	d1,d1
		dbf 	d2,R6314
		not	d0
		move.l	a1,d2
		bpl.b	R6336
		neg.l	d0
R6336:		rts

Bconin:		pea	(a2)
		move	d0,-(a7)
		move	#2,-(a7)	; Bconin
		trap	#13		; Bios
		addq	#4,a7
		movea.l	(a7)+,a2
		rts

Super:		pea	(a2)
		pea	(a0)
		move	#32,-(a7)	; Super
		trap	#1		; Gemdos
		addq	#6,a7
		movea.l	(a7)+,a2
		rts

Malloc:		pea	(a2)
		move.l	d0,-(a7)
		move	#72,-(a7)	; Malloc
		trap	#1		; Gemdos
		addq	#6,a7
		movea.l	d0,a0
		movea.l	(a7)+,a2
		rts

Crawio:		pea	(a2)
		move	d0,-(a7)
		move	#6,-(a7)	; Crawio
		trap	#1		; Gemdos
		addq	#4,a7
		movea.l	(a7)+,a2
		rts

Cconout:	pea	(a2)
		move	d0,-(a7)
		move	#2,-(a7)	; Cconout
		trap	#1		; Gemdos
		addq	#4,a7
		movea.l	(a7)+,a2
		rts

Random:		pea	(a2)
		move	#17,-(a7)	; Random
		trap	#14		; Xbios
		addq	#2,a7
		movea.l	(a7)+,a2
		rts

Physbase:	pea	(a2)
		move	#2,-(a7)	; Physbase
		trap	#14		; Xbios
		addq	#2,a7
		movea.l	d0,a0
		movea.l	(a7)+,a2
		rts

Logbase:	pea	(a2)
		move	#3,-(a7)	; Logbase
		trap	#14		; Xbios
		addq	#2,a7
		movea.l	d0,a0
		movea.l	(a7)+,a2
		rts

_aes:		lea	Gem_pb,a1
_aesP:		pea	(a2)
		moveq	#0,d2
		move.l	d2,(a1)+
		move.l	d2,(a1)+
		move	d2,(a1)
		movep.l	d1,-7(a1)
		move.l	#AES_pb,d1
		move	#200,d0
		trap	#2		; VDI/AES
		lea	U14756,a0
		move	(a0)+,d0
		movea.l	(a7)+,a2
		rts

appl_exi:	move.l	#318767360,d1
		bra.w	_aes

appl_ini:	move.l	#167772416,d1
		bra.w	_aes

evnt_mul:	pea	(a1)
		lea	U14492,a1
		move.l	a0,544(a1)
		move	d0,(a1)+
		move	d1,(a1)+
		move	d2,(a1)+
		move.l	8(a7),(a1)+
		move.l	12(a7),(a1)+
		move.l	16(a7),(a1)+
		move.l	20(a7),(a1)+
		move.l	24(a7),(a1)+
		move.l	28(a7),(a1)+
		move	32(a7),(a1)
		move.l	#420480769,d1
		bsr.w	_aes
		move.l	a2,d1
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		lea	30(a7),a2
		movea.l	(a2)+,a1
		move	(a0)+,(a1)
		movea.l	(a2)+,a1
		move	(a0)+,(a1)
		movea.l	(a2)+,a1
		move	(a0)+,(a1)
		movea.l	(a2)+,a1
		move	(a0)+,(a1)
		movea.l	(a2)+,a1
		move	(a0),(a1)
		movea.l	d1,a2
		rts

form_but:	pea	(a1)
		movem	d0-d1,U14492
		move.l	a0,U15036
		move.l	#939655681,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0),(a1)
		rts

form_cen:	pea	(a1)
		move.l	a0,U15036
		move.l	#905970945,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		movea.l	4(a7),a1
		move	(a0)+,(a1)
		movea.l	8(a7),a1
		move	(a0)+,(a1)
		movea.l	12(a7),a1
		move	(a0),(a1)
		rts

form_key:	pea	(a1)
		lea	U14492,a1
		move	d0,(a1)+
		move	d2,(a1)+
		move	d1,(a1)
		move.l	a0,540(a1)
		move.l	#922944257,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		movea.l	4(a7),a1
		move	(a0),(a1)
		rts

graf_han:	pea	(a1)
		pea	(a0)
		move.l	#1291846912,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		movea.l	4(a7),a1
		move	(a0)+,(a1)
		movea.l	8(a7),a1
		move	(a0),(a1)
		rts

graf_mou:	move	d0,U14492
		move.l	a0,U15036
		move.l	#1308688641,d1
		bra.w	_aes

objc_dra:	lea	U14492,a1
		move.l	a0,544(a1)
		move	d0,(a1)+
		move	d1,(a1)+
		move	d2,(a1)+
		move.l	4(a7),(a1)+
		move	8(a7),(a1)
		move.l	#705036545,d1
		bra.w	_aes

objc_edi:	pea	(a1)
		lea	U14492,a1
		move.l	a0,544(a1)
		move	d0,(a1)+
		move	d1,(a1)+
		movea.l	(a7),a0
		move	(a0),(a1)+
		move	d2,(a1)
		move.l	#772014593,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0),(a1)
		rts

objc_fin:	lea	U14492,a1
		move.l	a0,544(a1)
		move	d0,(a1)+
		move	d1,(a1)+
		move	d2,(a1)+
		move	4(a7),(a1)
		move.l	#721682689,d1
		bra.w	_aes

objc_off:	pea	(a1)
		move	d0,U14492
		move.l	a0,U15036
		move.l	#738263809,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move	(a0)+,(a1)
		movea.l	4(a7),a1
		move	(a0),(a1)
		rts

rsrc_gad:	pea	(a0)
		movem	d0-d1,U14492
		move.l	#1879179520,d1
		bsr.w	_aes
		movea.l	(a7)+,a1
		move.l	342(a0),(a1)
		rts

wind_upd:	move	d0,U14492
		move.l	#1795227904,d1
		bra.w	_aes

form_ale:	move	d0,U14492
		move.l	a0,U15036
		move.l	#872481025,d1
		bra.w	_aes

rsrc_loa:	move.l	a0,U15036
		move.l	#1845494017,d1
		bra.w	_aes

_vdi:		lea	_VDIParB,a0
		move	d0,12(a0)
		move	d1,(a0)+
		move	d2,4(a0)
		swap	d2
		move	d2,(a0)
		moveq	#115,d0
		move.l	#VDI_pb,d1
		pea	(a2)
		trap	#2		; VDI/AES
		movea.l	(a7)+,a2
		lea	U15458,a0
		move	(a0)+,d0
		rts

v_pline:	move.l	a0,T8074
		move	d1,d2
		swap	d2
		clr	d2
		moveq	#6,d1
		bsr.w	_vdi
		move.l	#U15738,T8074
		rts

v_opnvwk:	pea	(a2)
		pea	(a1)
		lea	_VDIParB,a2
		move	(a1),12(a2)
		lea	T8086,a1
		move.l	a1,d1
		move.l	a0,4(a1)
		movea.l	12(a7),a0
		move.l	a0,12(a1)
		lea	90(a0),a0
		move.l	a0,16(a1)
		move.l	#6553600,(a2)
		move	#11,6(a2)
		moveq	#115,d0
		trap	#2		; VDI/AES
		movea.l	(a7)+,a0
		move	U15176,(a0)
		movea.l	(a7)+,a2
		rts

v_clsvwk:	moveq	#101,d1
		moveq	#0,d2
		bra.w	_vdi

v_clrwk:	moveq	#3,d1
		moveq	#0,d2
		bra.w	_vdi

v_circle:	lea	U15738,a0
		move	d1,(a0)+
		move	d2,(a0)+
		clr.l	(a0)+
		move	4(a7),(a0)+
		clr	(a0)
		moveq	#11,d1
		move.l	#196608,d2
		move	#4,-574(a0)
		bra.w	_vdi

vs_clip:	lea	U15738,a1
		move.l	(a0)+,(a1)+
		move.l	(a0),(a1)
		move	d1,-548(a1)
		move	#129,d1
		move.l	#131073,d2
		bra.w	_vdi

vswr_mod:	move	d1,U15194
		moveq	#32,d1
		moveq	#1,d2
		bra.w	_vdi

vst_alig:	pea	(a1)
		pea	(a0)
		movem	d1-d2,U15194
		moveq	#39,d1
		moveq	#2,d2
		bsr.w	_vdi
		movea.l	(a7)+,a1
		move	d0,(a1)
		movea.l	(a7)+,a1
		move	(a0),(a1)
		rts

vsl_udst:	move	d1,U15194
		moveq	#113,d1
		moveq	#1,d2
		bra.w	_vdi

vsl_type:	move	d1,U15194
		moveq	#15,d1
		moveq	#1,d2
		bra.w	_vdi

vsl_colo:	move	d1,U15194
		moveq	#17,d1
		moveq	#1,d2
		bra.w	_vdi

vsf_styl:	move	d1,U15194
		moveq	#24,d1
		moveq	#1,d2
		bra.w	_vdi

vsf_peri:	move	d1,U15194
		moveq	#104,d1
		moveq	#1,d2
		bra.w	_vdi

vsf_inte:	move	d1,U15194
		moveq	#23,d1
		moveq	#1,d2
		bra.w	_vdi

vsf_colo:	move	d1,U15194
		moveq	#25,d1
		moveq	#1,d2
		bra.w	_vdi

vro_cpyf:	move.l	a0,T8074
		lea	U15178,a0
		move.l	a1,(a0)+
		move.l	4(a7),(a0)
		move	d1,12(a0)
		moveq	#109,d1
		move.l	#262145,d2
		bsr.w	_vdi
		move.l	#U15738,T8074
		rts

vq_mouse:	pea	(a1)
		pea	(a0)
		moveq	#124,d1
		moveq	#0,d2
		bsr.w	_vdi
		movea.l	(a7)+,a1
		move	d0,(a1)
		movea.l	(a7)+,a1
		move	568(a0),(a1)
		movea.l	4(a7),a1
		move	570(a0),(a1)
		rts

vq_extnd:	move.l	a0,T8078
		lea	90(a0),a0
		move.l	a0,T8082
		move	d1,U15194
		moveq	#102,d1
		moveq	#1,d2
		bsr.w	_vdi
		move.l	#U15458,T8078
		move.l	#U16028,T8082
		rts

		.data

__data:		dc.b	'>>>> PURE-C <<<<  for ATARI-ST    Version  1.0  (C'
		dc.b	')88-90 Borland International  '
EmpStr:		dc	0
errno:		dc	0
_AtExitV:	dc	0,0
_FilSysV:	dc	0,0
		dc.l	_RedirTa
		dc	0,1024
Pi:		dc	16384,0,51471,55970
		dc	9270,65248
Hm:		dc	16392,0,40960,0
		dc	0,0
Vm:		dc	16388,0,40960,0
		dc	0,0
gr180:		dc	16390,0,46080,0
		dc	0,0
R:		dc	6
S:		dc	4
Hoek:		dc	10
Worm:		dc	15
Worms:		dc	3
xy:		dc	0,0,639,399
eerste:		dc	0
T7676:		dc	16407,0,32768,0
		dc	0,0
T7688:		dc.b	'WORMS.RSC',0
T7698:		dc.b	'[1][Geen Resource!][ ACH ]',0,0
T7726:		dc	16384,0,32768,0
		dc	0,0
T7738:		dc	16382,0,32768,0
		dc	0,0
sch_aler:	dc.l	T7810
scr_grec:	dc	0,0,0,0
scr_vrec:	dc	0,0,0,0
MFDBnull:	dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0
instmfdb:	dc	0,0,0,0
		dc	0,0,0,0
		dc	0,0
T7810:		dc.b	'[1][Niet genoeg geheugen|voor schermdump area. !]['
		dc.b	' Quit! ]',0
T7869:		dc.b	'[3][| Install screen: | Intractable combination | '
		dc.b	'of physical characteristics ][ Oh! ]',0
form_hnd:	dc	0
T7958:		dc	4,4,1,0
		dc	1,31232,32576,65504
		dc	65520,65528,16380,4094
		dc	51199,61439,65535,65535
		dc	32767,16383,4095,1022
		dc	252,20480,10752,5440
		dc	51872,13648,2728,1028
		dc	594,50178,43521,20481
		dc	12289,3073,768,192
		dc	0
move_mod:	dc	1
_MemBlkL:	dc	0,0
_MemCluL:	dc	0,0
AES_pb:		dc.l	Gem_pb
		dc.l	U14462
		dc.l	U14492
		dc.l	U14756
		dc.l	U15036
		dc.l	U15100
VDI_pb:		dc.l	_VDIParB
		dc.l	U15194
T8074:		dc.l	U15738
T8078:		dc.l	U15458
T8082:		dc.l	U16028
T8086:		dc.l	_VDIParB
		dc.l	U15194
		dc.l	U15458
		dc.l	U15738
		dc.l	U16028

		.bss

_BasPag:	ds.b	4
_app:		ds.b	2
_StkLim:	ds.b	4
_PgmSize:	ds.b	4
_RedirTa:	ds.b	24
Xcirc:		ds.b	2000
Ycirc:		ds.b	2000
Tail:		ds.b	40
Wastail:	ds.b	40
Nx:		ds.b	2
Ny:		ds.b	2
Rich:		ds.b	240
Chg:		ds.b	12
D:		ds.b	12
vdivars:	ds.b	2
i:		ds.b	2
hl:		ds.b	2
J:		ds.b	2
I:		ds.b	2
inkey:		ds.b	2
db:		ds.b	4
wl:		ds.b	4
wa:		ds.b	4
wg:		ds.b	4
wr:		ds.b	4
ws:		ds.b	4
stackcor:	ds.b	4
sstack:		ds.b	4
scr:		ds.b	156
U12692:		ds.b	106
desk:		ds.b	1536
scr1:		ds.b	4
scr2:		ds.b	6
_frd:		ds.b	2
_fp:		ds.b	2
_fhc:		ds.b	2
_fwc:		ds.b	2
_fh:		ds.b	2
_fw:		ds.b	2
_fww:		ds.b	2
_nova:		ds.b	2
_f_logba:	ds.b	8
instdrb:	ds.b	16
U14384:		ds.b	8
U14392:		ds.b	34
form_out:	ds.b	2
_heapErr:	ds.b	4
Gem_pb:		ds.b	30
U14462:		ds.b	30
U14492:		ds.b	264
U14756:		ds.b	280
U15036:		ds.b	64
U15100:		ds.b	64
_VDIParB:	ds.b	12
U15176:		ds.b	2
U15178:		ds.b	16
U15194:		ds.b	264
U15458:		ds.b	280
U15738:		ds.b	290
U16028:		ds.b	1314
U17342:
		end	
