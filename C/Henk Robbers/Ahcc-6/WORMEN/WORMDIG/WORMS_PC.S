*	File	E:\WORMEN\WORMS_PC.S
*	Created by TT-DIGGER v4.0
*	1996/09/12  13:40:04

*		TEXT	1228 bytes, segment starts at Rnd
*		DATA	142 bytes, segment starts at T1228
*		BSS	4384 bytes, segment starts at U1370
*		FIXUPS	364 bytes
*		NAMES	374 bytes
*		names	62
*		External names not listed 

		.globl	wl
		.globl	Vm
		.globl	Hm
		.globl	hl
		.globl	Rnd
		.globl	Worms
		.globl	S
		.globl	dummy_voor_digger
		.globl	R
		.globl	Pi
		.globl	gr180
		.globl	wg
		.globl	db
		.globl	wa
		.globl	J
		.globl	i
		.globl	I
		.globl	main
		.globl	Worm
		.globl	vdivars
		.globl	Tail
		.globl	D
		.globl	Ycirc
		.globl	Xcirc
		.globl	Hoek
		.globl	xy
		.globl	Ny
		.globl	Rich
		.globl	Nx
		.globl	ws
		.globl	Wastail
		.globl	wr
		.globl	inkey
		.globl	Chg

		.text

.module Rnd
		link	a6,#0
		bsr.w	Random
		fmove.l	d0,fp0
		fdiv.x	T1296,fp0
		unlk	a6
		rts

.module main
		link	a6,#-12
		movem.l	d3/a2-a5,-(a7)
		bsr.w	appl_init
		lea	T1308,a0
		bsr.w	rsrc_load
		tst	d0
		bne.b	R72
		lea	T1318,a0
		moveq	#1,d0
		bsr.w	form_alert
R62:		bsr.w	appl_exit
		moveq	#1,d0
		bra.w	R1206

R72:		lea	J,a2
		suba.l	a1,a1
		lea	-2(a2),a0
		bsr.w	instt_scr
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
		bsr.w	rsrc_gaddr
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
		bsr.w	form_center
		lea	12(a7),a7
R214:		suba.l	a0,a0
		clr	d0
		bsr.w	graf_mouse
		movea.l	(a5),a0
		andi	#-2,322(a0)
		movea.l	(a5),a0
		andi	#-2,250(a0)
		movea.l	(a5),a0
		andi	#-2,298(a0)
		move	-2(a2),d1
		clr	d0
		movea.l	(a5),a0
		bsr.w	form_save
		move.l	a0,-4(a6)
		subq	#2,a7
		pea	scr_grect
		moveq	#1,d0
		move	d0,-(a7)
		moveq	#5,d2
		move	d0,d1
		movea.l	a0,a1
		movea.l	(a5),a0
		move	-2(a2),d0
		bsr.w	form_move
		addq	#8,a7
		move	d0,d3
		movea.l	-4(a6),a1
		move	-2(a2),d1
		movea.l	(a5),a0
		clr	d0
		bsr.w	form_rest
		cmp	#10,d3
		beq.w	R1192
		suba.l	a0,a0
		move	#256,d0
		bsr.w	graf_mouse
		clr	-(a7)
		clr	-(a7)
		moveq	#1,d2
		moveq	#1,d1
		move	-2(a2),d0
		bsr.w	deffill
		addq	#4,a7
		moveq	#3,d1
		move	-2(a2),d0
		bsr.w	vswr_mode
		cmp	#13,d3
		beq.b	R378
		cmp	#12,d3
		bne.w	R672
		move	8(a4),d0
		bne.w	R672
R378:		move	#1,8(a4)
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
R458		equ	*-2
		fmul.x	-58(a4),fp0
		fdiv.x	-22(a4),fp0
		fmove.x	fp0,-18(a2)
		move	-2(a2),d0
		bsr.w	v_clrwk
		clr	(a2)
		bra.b	R550

R490:		clr	2(a2)
		bra.b	R540

R496:		moveq	#100,d0
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
R540:		cmpi	#50,2(a2)
		blt.b	R496
		addq	#1,(a2)
R550:		cmpi	#20,(a2)
		blt.b	R490
		clr	(a2)
		bra.b	R664

R560:		bsr.w	Rnd
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
		fmul.x	T1346,fp0
		fmul.x	-58(a4),fp0
		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	fp0,0(a0,d0)
		move	(a2),d0
		lea	-354(a2),a1
		clr	0(a1,d0*2)
		addq	#1,(a2)
R664:		move	(a2),d0
		cmp	-2(a4),d0
		blt.b	R560
R672:		bsr.w	Rnd
		fmul	-2(a4),fp0
		fintrz.x fp0
		fmove	fp0,d0
		move	d0,(a2)
		lea	-354(a2),a0
		move	(a2),d1
		lea	-314(a2),a1
		move	0(a0,d0*2),0(a1,d1*2)
		move	(a2),d0
		move	0(a0,d0*2),d1
		ext.l	d1
		divs	-4(a4),d1
		swap	d1
		addq	#1,d1
		move	d1,0(a0,d0*2)
R726		equ	*-2
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
		bne.b	R774
		tst	d3
		beq.b	R808
R774:		subq	#2,a7
		move	-10(a4),-(a7)
		move	2(a4),d2
		move	(a4),d1
R786:		move	-2(a2),d0
		bsr.w	v_circle
		addq	#4,a7
		movea.l	a4,a0
		moveq	#2,d1
		move	-2(a2),d0
		bsr.w	v_pline
R808:		bsr.w	Rnd
		fmove.x	fp0,-30(a2)
		fcmp.x	T1358,fp0
		fbge.w	R858
		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	0(a0,d0),fp1
		fadd.x	-18(a2),fp1
		fmove.x	fp1,0(a0,d0)
R856:		bra.b	R884

R858:		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fmove.x	0(a0,d0),fp0
		fsub.x	-18(a2),fp0
		fmove.x	fp0,0(a0,d0)
R884:		moveq	#12,d0
		muls	(a2),d0
		lea	-270(a2),a0
		fcos.x	0(a0,d0),fp0
		fmul	-8(a4),fp0
		fintrz.x fp0
		fmove	fp0,d1
		moveq	#100,d2
		muls	(a2),d2
		move	(a2),d3
		lea	-314(a2),a1
		move	0(a1,d3*2),d0
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
		movea	(a2),a1
		lea	-314(a2),a0
		move	0(a0,a1*2),d1 ; **** ----> **** Dit is het struikelblok voor PASM
		add	d1,d1
		add	d1,d3
		lea	-2354(a2),a1
		add	0(a1,d3),d2
		ext.l	d2
		divs	2(a3),d2
		swap	d2
		move	d2,-272(a2)
		move	-274(a2),d0
		bpl.b	R1026
		move	(a3),d1
		add	d1,-274(a2)
R1026:		move	-272(a2),d0
		bpl.b	R1040
		move	2(a3),d1
		add	d1,-272(a2)
R1040:		moveq	#100,d0
		muls	(a2),d0
		move	(a2),d1
		lea	-354(a2),a0
		move	0(a0,d1*2),d2
		add	d2,d2
		add	d2,d0
		lea	-4354(a2),a1
		move	-274(a2),0(a1,d0)
		moveq	#100,d0
		muls	(a2),d0
		move	(a2),d1
		move	0(a0,d1*2),d2
		add	d2,d2
		add	d2,d0
		lea	-2354(a2),a1
		move	-272(a2),0(a1,d0)
		subq	#2,a7
		move	-10(a4),-(a7)
		move	-272(a2),d2
		move	-274(a2),d1
		move	-2(a2),d0
		bsr.w	v_circle
		addq	#4,a7
		move	#255,d0
		bsr.w	Crawio
		move	d0,4(a2)
		tst	d0
		beq.w	R672
		andi	#255,4(a2)
		cmpi	#32,4(a2)
		bne.b	R1162
		moveq	#2,d0
		bsr.w	Bconin
		and	#255,d0
		move	d0,4(a2)
R1162:		cmpi	#99,4(a2)
		beq.w	R672
		suba.l	a0,a0
		move	#257,d0
		bsr.w	graf_mouse
		cmpi	#113,4(a2)
		bne.w	R214
R1192:		move	-2(a2),d0
		bsr.w	v_clsvwk
		bsr.w	appl_exit
		clr	d0
R1206:		movem.l	-32(a6),d3/a2-a5
		unlk	a6
		rts

.module dummy_voor_digger
		link	a6,#0
		bsr.w	main
		unlk	a6
		rts

		.data

.module T1228

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
.module T1296
		dc	16407,0,32768,0
		dc	0,0
T1308:		dc.b	'WORMS.RSC',0
T1318:		dc.b	'[1][Geen Resource!][ ACH ]',0,0
T1346:		dc	16384,0,32768,0
		dc	0,0
T1358:		dc	16382,0,32768,0
		dc	0,0

		.bss

.module U1370

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
U5754:
		end	
