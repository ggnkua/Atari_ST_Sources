**********************************************************************
* Data Exploder  a0 = Source/Dest Buffer (must be size of dest!)
*                          Resource by GROO 1990
**********************************************************************
Explode_Data	movem.l	d0-d5/a0-a4,-(sp)
		move.l	a0,a3
		move.l	a0,a4
		cmp.l	#"IMP!",(a0)+
		bne.s	NotImplDataErr
		add.l	(a0)+,a4
		add.l	(a0)+,a3
		move.l	a3,a2
		move.l	(a2)+,-(a0)
		move.l	(a2)+,-(a0)
		move.l	(a2)+,-(a0)
		move.l	(a2)+,d2
		move.w	(a2)+,d3
		bmi.s	.1
		subq.l	#1,a3
.1		lea	-$001C(sp),sp
		move.l	sp,a1
		moveq.l	#6,d0
.2		move.l	(a2)+,(a1)+
		dbra	d0,.2
		move.l	sp,a1
		moveq.l	#0,d4
Expl1		tst.l	d2
		beq.s	.3
.4		move.b	-(a3),-(a4)
		subq.l	#1,d2
		bne.s	.4
.3		cmp.l	a4,a0
		bcs.s	Expl2
		lea	$001C(sp),sp
		moveq.l	#-1,d0
		cmp.l	a3,a0
		beq.s	Expl_Exit
NotImplDataErr	moveq.l	#0,d0
Expl_Exit	movem.l	(sp)+,d0-d5/a0-a4
		rts		; d0 = 0 = error
 
Expl2		add.b	d3,d3
		bne.s	.1
		move.b	-(a3),d3
		addx.b	d3,d3
.1		bcc.s	Expl3
		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		bcc.s	Expl4
		add.b	d3,d3
		bne.s	.3
		move.b	-(a3),d3
		addx.b	d3,d3
.3		bcc.s	Expl5
		add.b	d3,d3
		bne.s	.4
		move.b	-(a3),d3
		addx.b	d3,d3
.4		bcc.s	Expl6
		add.b	d3,d3
		bne.s	.5
		move.b	-(a3),d3
		addx.b	d3,d3
.5		bcc.s	.6
		move.b	-(a3),d4
		moveq.l	#3,d0
		bra.s	Expl7
 
.6		add.b	d3,d3
		bne.s	.7
		move.b	-(a3),d3
		addx.b	d3,d3
.7		addx.b	d4,d4
		add.b	d3,d3
		bne.s	.8
		move.b	-(a3),d3
		addx.b	d3,d3
.8		addx.b	d4,d4
		add.b	d3,d3
		bne.s	.9
		move.b	-(a3),d3
		addx.b	d3,d3
.9		addx.b	d4,d4
		addq.b	#6,d4
		moveq.l	#3,d0
		bra.s	Expl7
 
Expl6		moveq.l	#5,d4
		moveq.l	#3,d0
		bra.s	Expl7
 
Expl5		moveq.l	#4,d4
		moveq.l	#2,d0
		bra.s	Expl7
 
Expl4		moveq.l	#3,d4
		moveq.l	#1,d0
		bra.s	Expl7
 
Expl3		moveq.l	#2,d4
		moveq.l	#0,d0
Expl7		moveq.l	#0,d5
		move.w	d0,d1
		add.b	d3,d3
		bne.s	.1
		move.b	-(a3),d3
		addx.b	d3,d3
.1		bcc.s	.4
		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		bcc.s	.3
		move.b	Expl_Tab1(pc,d0.w),d5
		addq.b	#8,d0
		bra.s	.4
 
.3		moveq.l	#2,d5
		addq.b	#4,d0
.4		move.b	Expl_Tab2(pc,d0.w),d0
.5		add.b	d3,d3
		bne.s	.6
		move.b	-(a3),d3
		addx.b	d3,d3
.6		addx.w	d2,d2
		subq.b	#1,d0
		bne.s	.5
		add.w	d5,d2
		moveq.l	#0,d5
		move.l	d5,a2
		move.w	d1,d0
		add.b	d3,d3
		bne.s	.7
		move.b	-(a3),d3
		addx.b	d3,d3
.7		bcc.s	Expl9
		add.w	d1,d1
		add.b	d3,d3
		bne.s	.8
		move.b	-(a3),d3
		addx.b	d3,d3
.8		bcc.s	Expl8
		move.w	8(a1,d1.w),a2
		addq.b	#8,d0
		bra.s	Expl9
 
Expl8		move.w	0(a1,d1.w),a2
		addq.b	#4,d0
Expl9		move.b	$0010(a1,d0.w),d0
.1		add.b	d3,d3
		bne.s	.2
		move.b	-(a3),d3
		addx.b	d3,d3
.2		addx.l	d5,d5
		subq.b	#1,d0
		bne.s	.1
		addq.w	#1,a2
		add.l	d5,a2
		add.l	a4,a2
.3		move.b	-(a2),-(a4)
		subq.b	#1,d4
		bne.s	.3
		bra	Expl1
 
Expl_Tab1	dc.l	$060A0A12
Expl_Tab2	dc.l	$01010101
		dc.l	$02030304
		dc.l	$0405070E

; =========================================================================
