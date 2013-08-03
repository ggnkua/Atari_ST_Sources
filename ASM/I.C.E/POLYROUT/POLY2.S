***
***	Kungs„ngen 15 July 1993
***
***	Alright. As I have bought a 486PC and don't code on the Atari
***	anymore I can just release my polygon rout aswell.
***	Hopefully SOMEONE will find it useful, and I really don't
***	mind if anyone uses it in their productions, as long as
***	credits are given to the author... (I believe you do..)
***
***	This routine is the one used in the Ecstasy! demo (TCC93 winner)
***	and is surely one of the fastest ever made. It's faster on drawing
***	a small number big polys than a great number of small ones.
***		About the 'polygon structure' referred to later on
*		(a0 input) this is it:
*	a0.l	= x address
*
*	x+0	screen offset,for different bitplanes	(word)	
*
*	x+2	# of points in polygon  (word)
*
*	x+4	p1*8,p2*8,p3*8,p4*8
*		p1*8,p2*8,p3*8,p4*8
*		p1*8,p2*8,p3*8,p4*8
*		(words)
*		Where pX = offset to point in pointlist (a1=pointlist)
*		multiplied with 8 for speed. (1 point is 1 word)
*		In the example above the polygon has 4 points..
*	
*	The points should be specified in a clockwise direction for
*	compability with the hide-face routine.
*	Hope this information isn't too complicated now!
*
***	Greetings to:
***		ICE
***		Silents
***		Aggression
***		Triton
***		Omega
***		
***	Special hellos to:
***		Michael Hildenborg (For being so lame...:-)
***
*
*	I never included my address in the Ecstasy demo, so here's
*	your chance to contact me!
*	New contacts are always welcome, especially if you are a
*	good musician and u want to work with The Silents (PC section)
*
*	H†kan Wallin
*	Knektv„gen 10
*	S-19630 Kungs„ngen
*	SWEDEN
*
*	Or phone me at +46-0(8)-58172710 
*
*******************************************************************
*******************************************************************
*	Routine coded in October 1992 by
*		H†kan Wallin	(Wallis/ICE!)
*		Knektv„gen 10
*		S-19630 Kungs„ngen
*
*	Uses d0-d7/a0-a5 + Stack
*
*	Size in memory: 56830 bytes
*		
*	Copyright (c) H†kan Wallin
*
********************************************************************
*	poly+0: DRAW FILLED POLYGON
*		Input:	a0 ~ Address to polygon structure
*			a1 ~ Address to point cordinates
*			a2 ~ Screen address
*		Output: d0.l = -1 ; Polygon not vizible on screen
*		        if d0.l <> -1 then
*		        d0.w =	Min x
*		        d1.w =	Min y
*		        d2.w =	Max x
*		        d3.w =	Max y
********************************************************************
*	poly+4:	PREPARE CODE AND CALCULATE TABLES
*		Initiates code and memory tables.
*		Must be called once.
********************************************************************
*	poly+8:	CHANGE Y-CLIPPING
*		Input:	d0.w ~ y_min
*			d1.w ~ y_max
*		The default is y_min = 0 and y_max = 199       
********************************************************************
*	poly+12: DRAW FILLED CIRCLE
* 		Input:	d0.w ~ x_cord
*			d1.w ~ y_cord
*			d2.w ~ x_radie
*			d3.w ~ y_radie
*			a1   ~ Address to sincos table
*			a2   ~ Screen address
*		Output: d0.l = -1 ; Circle not drawn on screen
*		        if d0.l <> -1 then
*		        d0.w =	Min x
*		        d1.w =	Min y
*		        d2.w =	Max x
*		        d3.w =	Max y
********************************************************************

poly		bra	.draw_poly
		bra	.prepare
		bra	.change_yclip
		bra	.draw_circle

		dc.b	"Wallis code // October 1992!"

.draw_circle	cmpi.w	#$00e0,d2
		bgt	.not_vizi
		cmpi.w	#$00e0,d3
		bgt	.not_vizi
		move.w	d0,d4
		move.w	d1,d5
		move.w	d0,d6
		move.w	d1,d7
		sub.w	d2,d4
		sub.w	d3,d5
		add.w	d2,d6
		add.w	d3,d7

		movea.w	#$0000,a4
		movea.w	#$013f,a5
		cmp.w	a4,d6
		blt	.not_vizi
		cmp.w	a5,d4
		bgt	.not_vizi
		cmp.w	a4,d4
		bge.s	.circle1
		move.w	a4,d4
.circle1	cmp.w	a5,d6
		ble.s	.circle2
		move.w	a5,d6

.circle2	movem.w	.y_clip(pc),a4-5
		lea	.rgt_cords(pc),a0
		cmp.w	a4,d7
		blt	.not_vizi
		cmp.w	a5,d5
		bgt	.not_vizi
		cmp.w	a4,d5
		bge.s	.circle3
		move.w	a4,d5
.circle3	cmp.w	a5,d7
		ble.s	.circle4
		move.w	a5,d7

.circle4	movem.w	d4-7,-(a7)
		sub.w	d5,d7
		subq.w	#2,d7
		bge.s	.circle5
		addq.w	#8,a7
		bra	.not_vizi
.circle5	move.w	d7,-(a7)
		move.w	d1,d6
		sub.w	d5,d6
		lea	.yprep_tab(pc),a3
		add.w	d5,d5
		add.w	d5,d5
		adda.l	0(a3,d5.w),a2
		add.w	d6,d6
		add.w	d6,d6
		lea	0(a0,d6.w),a0
		moveq	#4,d5
		move.w	#$00a0,d6
		move.w	#$00ff,d7
		bra.s	.circle7
.circle6	add.w	d5,d5
		lsr.w	#1,d7
.circle7	lsr.w	#1,d6
		cmp.w	d6,d3
		blt.s	.circle6
		subq.w	#4,d5
		movea.w	d5,a3

.circle8	move.w	d2,d6
		muls	(a1)+,d6
		add.l	d6,d6
		swap	d6
		move.w	d0,d4
		move.w	d0,d5
		add.w	d6,d4
		sub.w	d6,d5
		swap	d4
		move.w	d5,d4
		add.l	d4,d4
		add.l	d4,d4
		move.w	d3,d6
		muls	(a1)+,d6
		add.l	d6,d6
		swap	d6
		move.w	d6,d5
		neg.w	d5
		add.w	d1,d5
		add.w	d1,d6
		cmp.w	a4,d5
		blt.s	.circle9
		cmp.w	a5,d5
		bgt.s	.circle9
		sub.w	d1,d5
		add.w	d5,d5
		add.w	d5,d5
		move.l	d4,0(a0,d5.w)
.circle9	cmp.w	a4,d6
		blt.s	.circle10
		cmp.w	a5,d6
		bgt.s	.circle10
		sub.w	d1,d6
		add.w	d6,d6
		add.w	d6,d6
		move.l	d4,0(a0,d6.w)
.circle10	adda.w	a3,a1
		dbra	d7,.circle8

		lea	.rgt_cords+4(pc),a0
		lea	.lft_tab(pc),a3
		lea	.rgt_tab(pc),a4
		move.w	(a7)+,d7
		moveq	#-1,d6
		move.w	#$ca58,.and_code
		jsr	.draw_start
		move.w	#$ca40,.and_code

		movem.w	(a7)+,d0-3
		rts

.change_yclip	move.w	#$0000,d2
		move.w	#$012b,d3

		cmp.w	d2,d0
		bge.s	.change_yc1
		move.w	d2,d0
.change_yc1	cmp.w	d3,d0
		ble.s	.change_yc2
		move.w	d3,d0
.change_yc2	cmp.w	d2,d0
		bge.s	.change_yc3
		move.w	d2,d0
.change_yc3	cmp.w	d3,d0
		ble.s	.change_yc4
		move.w	d3,d0

.change_yc4	movem.w	d0-1,.y_clip
		rts

.draw_poly	move.w	(a0)+,d7
		move.w	d7,d1
		add.w	d1,d1
		lea	0(a0,d1.w),a0
		move.w	(a0)+,d0
		movem.w	0(a1,d0.w),d0-1
		move.w	d0,d2
		move.w	d1,d3
		movea.l	a0,a3
		subq.w	#2,d7

.max_loop	move.w	(a0)+,d4
		movem.w	0(a1,d4.w),d4-5
		***	cmpi.w	#-80,d6
		***	bgt	.not_vizi
		cmp.w	d0,d4
		bge.s	.ml1
		move.w	d4,d0
.ml1		cmp.w	d1,d5
		bge.s	.ml2
		move.w	d5,d1
		movea.l	a0,a3
.ml2		cmp.w	d2,d4
		ble.s	.ml3
		move.w	d4,d2
.ml3		cmp.w	d3,d5
		ble.s	.ml4
		move.w	d5,d3
.ml4		dbra	d7,.max_loop

		cmp.w	d1,d3
		ble.s	.not_vizi

		movem.w	.y_clip(pc),d5-6

		cmpi.w	#319,d0
		bgt.s	.not_vizi		
		cmp.w	d6,d1
		bgt.s	.not_vizi
		tst.w	d2
		blt.s	.not_vizi
		cmp.w	d5,d3
		blt.s	.not_vizi
		tst.w	d0
		bge.s	.set_b1
		clr.w	d0
.set_b1		cmp.w	d5,d1
		bge.s	.set_b2
		move.w	d5,d1
.set_b2		cmpi.w	#319,d2
		ble.s	.set_b3
		move.w	#319,d2
.set_b3		cmp.w	d6,d3
		ble.s	.set_b4
		move.w	d6,d3

.set_b4		movem.w	d0-3,-(a7)

		movem.w	-4(a3),d0/a0/a4
		move.w	0(a1,a0.l),d2
		move.w	d2,d7
		sub.w	0(a1,d0.w),d2
		bpl.s	.check_vizi	
		sub.w	0(a1,a4.l),d7
		bpl.s	.not_vizi_stc
.vector_equ	move.w	2(a1,a0.l),d3
		move.w	d3,d4
		sub.w	2(a1,d0.w),d3
		sub.w	2(a1,a4.l),d4
		muls.w	d4,d2
		muls.w	d3,d7
		sub.l	d2,d7
		bgt.s	.vizi
.not_vizi_stc	addq.w	#8,a7
.not_vizi	moveq	#-1,d0
		rts

.check_vizi	sub.w	0(a1,a4.l),d7
		bpl.s	.vector_equ

.vizi		lea	.yprep_tab(pc),a0
		add.w	d1,d1
		add.w	d1,d1
		adda.l	0(a0,d1.w),a2
		lea	-$a0(a2),a2

		lea	.rgt_cords(pc),a0
		lea	.calc_rgt_vec(pc),a4
		lea	.addx_tab(pc),a5
		subq.w	#2,a3
		move.l	a3,-(a7)


.calc_rgt_vec	move.w	(a3)+,d0
		move.w	(a3),d2
		movem.w	0(a1,d0.w),d0-1
		movem.w	0(a1,d2.w),d2-3
		cmp.w	d1,d3
		beq.s	.calc_rgt_vec
		blt	.calc_rgt_ready

		cmp.w	#0,d3
		ble.s	.calc_rgt_vec
		cmp.w	#199,d1
		bge	.calc_rgt_ready

		move.w	d2,d4
		move.w	d3,d5
		sub.w	d0,d4
		sub.w	d1,d5

		cmp.w	#0,d1
		bge.s	.noc1
		sub.w	#0,d1
		muls	d4,d1
		divs	d5,d1
		sub.w	d1,d0
		move.w	#0,d1
.noc1
		cmp.w	#199,d3
		ble.s	.noc1a
		sub.w	#199,d3
		muls	d4,d3
		divs	d5,d3
		sub.w	d3,d2
		move.w	#199,d3
.noc1a
		move.w	d2,d4
		move.w	d3,d5
		sub.w	d0,d4
		sub.w	d1,d5

		cmp.w	#-320,d0
		bge.s	.noc2
		move.l	#$fb00fb00,d6
		cmp.w	#-320,d2
		blt	.rak
		sub.w	#-320,d0
		muls	d5,d0
		divs	d4,d0
		sub.w	d0,d1
		move.w	d0,d7
		move.w	#-320,d0
		bsr	.move_tab
.noc2
		cmp.w	#639,d0
		ble.s	.noc3
		move.l	#$09fc09fc,d6
		cmp.w	#639,d2
		bgt	.rak
		sub.w	#639,d0
		muls	d5,d0
		divs	d4,d0
		sub.w	d0,d1
		move.w	d0,d7
		move.w	#639,d0
		bsr	.move_tab
.noc3
		cmp.w	#639,d2
		ble.s	.nxt1
		sub.w	#639,d2
		muls	d5,d2
		divs	d4,d2
		sub.w	d2,d3
		lea	.after1(pc),a4
		move.l	#$09fc09fc,d6
		move.w	d2,d7
		neg.w	d7
		move.w	#639,d2
		bra.s	.nxt2
.nxt1
		cmp.w	#-320,d2
		bge.s	.nxt2
		sub.w	#-320,d2
		muls	d5,d2
		divs	d4,d2
		sub.w	d2,d3

		lea	.after1(pc),a4
		move.l	#$fb00fb00,d6
		move.w	d2,d7
		neg.w	d7
		move.w	#-320,d2
.nxt2
		sub.w	d0,d2
		sub.w	d3,d1
		move.w	d1,d5
		neg.w	d5
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d1
		add.w	d1,d1

		tst.w	d2
		bpl.s	.cals1
		subq.w	#2,d2
.cals1		addq.w	#1,d2
		addq.w	#1,d5
		ext.l	d2
		lsl.l	#7,d2
		divs.w	d5,d2
		swap	d2
		clr.w	d2
		asr.l	#5,d2
		swap	d0
		move.w	d2,d0
		swap	d0
		swap	d2
		jmp	-4(a5,d1.w)
.rak		sub.w	d3,d1
		move.w	d1,d7
.rak2		move.l	a4,-(a7)
		bra	.move_tab
.after1		lea	.calc_rgt_vec(pc),a4
		move.l	a4,-(a7)
		bra	.move_tab

.poly_ready	movem.w	(a7)+,d0-3
		rts

.calc_rgt_ready	lea	.rgt_cords(pc),a0
		lea	.lft_tab(pc),a3
		lea	.rgt_tab(pc),a4
		movea.l	(a7)+,a5

.draw_back	movem.w	.y_clip(pc),d5-6
.calc_lft_vec	move.w	(a5),d0
		move.w	-(a5),d2
		movem.w	0(a1,d0.w),d0-1
		movem.w	0(a1,d2.w),d2-3
		cmp.w	d1,d3
		blt.s	.poly_ready
		beq.s	.calc_lft_vec

		cmp.w	#0,d3
		ble.s	.calc_lft_vec
		cmp.w	#199,d1
		bge	.poly_ready

		pea	.draw_back(pc)

		move.w	d2,d4
		move.w	d3,d5
		sub.w	d0,d4
		sub.w	d1,d5

		cmp.w	#0,d1
		bge.s	.lnoc1
		sub.w	#0,d1
		muls	d4,d1
		divs	d5,d1
		sub.w	d1,d0
		move.w	#0,d1
.lnoc1
		cmp.w	#199,d3
		ble.s	.lnoc1a
		sub.w	#199,d3
		muls	d4,d3
		divs	d5,d3
		sub.w	d3,d2
		move.w	#199,d3
.lnoc1a
		move.w	d2,d4
		move.w	d3,d5
		sub.w	d0,d4
		sub.w	d1,d5

		cmp.w	#-320,d0
		bge.s	.lnoc2
		move.w	#$fb00,d6
		cmp.w	#-320,d2
		blt	.lrak
		sub.w	#-320,d0
		muls	d5,d0
		divs	d4,d0
		sub.w	d0,d1
		move.w	d0,d7
		neg.w	d7
		move.w	#-320,d0

		subq.w	#1,d7
		blt.s	.lnoc2
		movem.w	d0-5,-(a7)
		clr.w	d2
		move.w	d6,d0
		moveq	#-1,d6
		jsr	.draw_loop
		movem.w	(a7)+,d0-5

.lnoc2
		cmp.w	#639,d0
		ble.s	.lnoc3
		move.w	#$09fc,d6
		cmp.w	#639,d2
		bgt	.lrak
		sub.w	#639,d0
		muls	d5,d0
		divs	d4,d0
		sub.w	d0,d1
		move.w	d0,d7
		neg.w	d7
		move.w	#639,d0

		subq.w	#1,d7
		blt.s	.lnoc3
		movem.w	d0-5,-(a7)
		clr.w	d2
		move.w	d6,d0
		moveq	#-1,d6
		jsr	.draw_loop
		movem.w	(a7)+,d0-5

.lnoc3
		cmp.w	#639,d2
		ble.s	.lnxt1
		sub.w	#639,d2
		muls	d5,d2
		divs	d4,d2
		sub.w	d2,d3
		move.w	#$09fc,d6
		move.w	d2,d7
		movem.w	d6-7,-(a7)
		pea	.lafter1(pc)
		move.w	#639,d2
		bra.s	.lnxt2
.lnxt1
		cmp.w	#-320,d2
		bge.s	.lnxt2
		sub.w	#-320,d2
		muls	d5,d2
		divs	d4,d2
		sub.w	d2,d3

		move.w	#$fb00,d6
		move.w	d2,d7
		movem.w	d6-7,-(a7)
		pea	.lafter1(pc)
		move.w	#-320,d2
.lnxt2
		sub.w	d0,d2
		sub.w	d1,d3
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d1
		add.w	d1,d1

		move.w	d3,d7
		subq.w	#1,d7
		blt.s	.ratta

		tst.w	d2
		bpl.s	.lcals1
		subq.w	#2,d2
.lcals1		addq.w	#1,d2
		addq.w	#1,d3
		ext.l	d2
		lsl.l	#7,d2
		divs.w	d3,d2
		swap	d2
		clr.w	d2
		asr.l	#5,d2
		move.w	d2,d1
		move.w	d2,d3
		swap	d2
		moveq	#-1,d6
		jmp	.draw_loop

.lrak		sub.w	d1,d3
		move.w	d3,d7
.lrak2		move.w	d6,d0
		bra.s	.gaffel
.lafter1	movem.w	(a7)+,d0/d7
.gaffel		clr.w	d3
		clr.w	d2
		subq.w	#1,d7
		blt.s	.ratta
		moveq	#-1,d6
		jmp	.draw_loop
.ratta		rts

		tst.w	d2
		bpl.s	.calc_lft3
		subq.w	#2,d2
.calc_lft3	addq.w	#1,d2
		addq.w	#1,d3
		ext.l	d2
		lsl.l	#7,d2
		divs.w	d3,d2
		swap	d2
		clr.w	d2
		asr.l	#5,d2
		move.w	d2,d1
		move.w	d2,d3
		swap	d2
		jmp	.draw_loop

.prepare	lea	.draw_loop,a0
		lea	.code_area1(pc),a1
		move.l	#$8b6a0000,d0
		move.l	#$48444845,d3
		move.l	#$35460000,d5
		movea.w	#$8b52,a5

.make_code1	moveq	#0,d1
.make_code2	movea.l	a1,a2
		lea	$60(a1),a1
		cmp.w	d0,d1
		ble.s	.make_code3
		move.l	d3,(a2)+
		move.w	d1,d5
		move.w	#$896a,(a2)+
		move.w	d5,(a2)+
		bra.s	.make_code6
.make_code3	blt.s	.make_code8
		move.l	#$ca844845,(a2)+
		bra.s	.make_code7
.make_code4	move.w	a5,(a2)+
		bra.s	.make_code8
.make_code5	move.l	d5,(a2)+
.make_code6	subq.w	#8,d5
		cmp.w	d0,d5
		bne.s	.make_code5
.make_code7	tst.w	d0
		beq.s	.make_code4
		move.l	d0,(a2)+
.make_code8	move.w	#$51cf,(a2)+
		move.l	a0,d6
		sub.l	a2,d6
		move.w	d6,(a2)+
		move.w	#$4e75,(a2)
		addq.w	#8,d1
		cmpi.w	#$00a0,d1
		blt.s	.make_code2
		addq.w	#8,d0
		cmpi.w	#$0050,d0
		blt.s	.make_code1
		bgt.s	.make_code9
		lea	.code_area2,a1
		clr.w	d4
.make_code9	cmpi.w	#$00a0,d0
		blt.s	.make_code1

		lea	.lft_tab-$a00(pc),a0
		lea	.rgt_tab-$a00(pc),a1
		move.l	#$ffffb4e2,d2
		moveq	#0,d3
		move.w	#$0780,d4
		move.w	#$0060,d5
		move.w	#$027f,d0
.make_tabs1	move.l	d2,(a0)+
		move.l	d3,(a1)+
		dbra	d0,.make_tabs1
		moveq	#1,d7
.make_tabs2	moveq	#9,d6
.make_tabs3	move.w	#$ffff,d0
		move.w	#$8000,d1
.make_tabs4	move.w	d0,(a0)+
		move.w	d2,(a0)+
		move.w	d1,(a1)+
		move.w	d3,(a1)+
		lsr.w	#1,d0
		asr.w	#1,d1
		bcc.s	.make_tabs4
		add.w	d4,d2
		add.w	d5,d3
		dbra	d6,.make_tabs3
		clr.w	d2
		dbra	d7,.make_tabs2
		move.l	#$00004380,d2
		move.l	#$ffff0720,d3
		move.w	#$027f,d0
.make_tabs5	move.l	d2,(a0)+
		move.l	d3,(a1)+
		dbra	d0,.make_tabs5

		lea	.yprep_tab(pc),a0
		moveq	#0,d0
		move.w	#$12b,d1
.make_tabs6	move.l	d0,(a0)+
		addi.l	#$a0,d0
		dbra	d1,.make_tabs6
		rts

		REPT 199
		addx.l	d2,d0
		move.w	d0,(a0)+
		ENDR
		addx.l	d2,d0
		move.w	d0,(a0)
.addx_tab	jmp	(a4)

		REPT 100
		move.l	d6,(a0)+
		ENDR
		rts
.move_tab	asr.w	#1,d7
		bcc.s	.not_odd
		move.w	d6,(a0)+
		addq.w	#1,d7
.not_odd	add.w	d7,d7
		jmp	.move_tab-2(pc,d7.w)

.y_clip		dc.w	$0000
		dc.w	$00c7
.rgt_cords	ds.l	$0500
.lft_tab	ds.l	$0640
.rgt_tab	ds.l	$03c0
.yprep_tab	ds.l	$012c
.code_area1	ds.l	$12c0

.draw_loop	lea	$a0(a2),a2
		add.w	d3,d1
		addx.w	d2,d0
.draw_start	moveq	#-4,d4
		moveq	#-4,d5
		and.w	(a0)+,d4
.and_code	and.w	d0,d5
		move.l	0(a3,d5.w),d5
		move.l	0(a4,d4.w),d4
		add.w	d4,d5
		jmp	.code_area2(pc,d5.w)

.code_area2	ds.l	$12c0
