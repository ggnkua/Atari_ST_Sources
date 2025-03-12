*
*		BitPlane Packer v 1.0
*		
*		Approx. 1/5 picture size and 40% VBL depack
*		These routines may be used by anyone in any production
*		aslong as the author is given credits for it!
*
*		Coded on the 7 April 1993 by:
*		 H†kan Wallin	(Wallis/ICE!)
*		 Knektv„gen 10
*		 19630 Kungs„ngen
*		 Sweden
*
*		For faster version, write me!
*
*		Size in memory: 370 bytes
*		depack:
*		    input:	a0.l ~ Address to packed data
*				a1.l ~ Bitplane address
*		    output:	None.
*		    uses:	d0-d4/a0-6/blitter
*		pack:
*		    input:	a0.l ~ Bitplane address
*				a1.l ~ Dataarea address
*				d0.l ~ Picture size (Whole screen=32000)
*		    output:	d0.l ~ Packed data size (bytes)
*		    uses:	d0-7/a0-6

depack		movea.w	#$8a22,a2
		lea	$06(a2),a3
		lea	$02(a2),a4
		lea	$14(a2),a5
		lea	$18(a2),a6
		moveq	#-1,d0
		moveq	#8,d1
		moveq	#2,d3
		moveq	#8,d4
		move.l	d1,-8(a3)
		move.l	d0,(a3)+
		move.w	d0,(a3)+
		move.l	d1,(a3)+
		move.w	#1,(a5)+
		move.w	#$0203,(a6)+
		move.w	#$c000,d1
		move.w	(a0)+,(a1)
		addq.w	#8,a1
		move.l	a1,(a3)
		move.w	(a0)+,d0
		bgt.s	.copy
.no_copy	beq.s	.ready
.direct		neg.w	d0
		move.w	d3,(a2)
		move.l	a0,(a4)
		move.w	d0,(a5)
		move.w	d1,(a6)
		add.w	d0,d0
		adda.w	d0,a0
		move.w	d4,(a2)
		move.w	(a0)+,d0
		ble.s	.no_copy
.copy		move.l	(a3),d2
		add.w	(a0)+,d2
		move.l	d2,(a4)
		move.w	d0,(a5)
		move.w	d1,(a6)
		move.w	(a0)+,d0
		ble.s	.no_copy
		move.l	(a3),d2
		add.w	(a0)+,d2
		move.l	d2,(a4)
		move.w	d0,(a5)
		move.w	d1,(a6)
		move.w	(a0)+,d0
		bgt.s	.copy
		blt.s	.direct
.ready		rts

pack		movea.l	a0,a2
		move.l	a0,d1
		add.l	d0,d1
		moveq	#0,d7
		move.l	a1,-(a7)
		move.w	(a2),(a1)+
		addq.w	#8,a2
		moveq	#0,d3
		move.l	a0,-(a7)
.pack_lop	move.w	(a2),d0
		addq.w	#8,a2
		cmp.l	a2,d1
		ble.s	.stop_pack
		moveq	#0,d4
		movea.l	(a7),a3
		move.w	d7,d6
		move.w	d6,d5
		andi.w	#3,d5
		lsr.w	#2,d6
		add.w	d5,d5
		suba.w	.sear_aadd(pc,d5.w),a3
		jmp	.sear_jmps(pc,d5.w)
.sear_aadd	dc.w	24,16,08,00
.sear_jmps	bra.s	.cont3
		bra.s	.cont2
		bra.s	.cont1
.search_lop	cmp.w	(a3),d0
		beq.s	.equ1
.cont1		cmp.w	08(a3),d0
		beq.s	.equ2
.cont2		cmp.w	16(a3),d0
		beq.s	.equ3
.cont3		cmp.w	24(a3),d0
		lea	32(a3),a3
		beq.s	.equ4
.cont4		dbra	d6,.search_lop
		move.w	d4,d5
		beq.s	.direct
		move.l	a6,d6
		sub.l	a2,d6
		add.w	d5,d7
		lsl.w	#3,d5
		sub.w	d6,d5
		lea	-8(a6,d5.w),a2
		move.l	a2,d5
		sub.l	d1,d5
		blt.s	.no_end
		lsr.w	#3,d5
		sub.w	d5,d4
		move.w	d4,(a1)+
		move.w	d6,(a1)+
.end_pack	clr.w	(a1)+
		addq.w	#4,a7
		move.l	a1,d0
		sub.l	(a7)+,d0
		rts
.direct		subq.w	#1,d3
		addq.w	#1,d7
		bra.s	.pack_lop
.no_end		move.w	d4,(a1)+
		move.w	d6,(a1)+
		bra	.pack_lop
.stop_pack	moveq	#-1,d7
		bra.s	.equ_found
.equ1		lea	08(a3),a0
		move.l	a0,d2
		lea	.cont1(pc),a0
		bra.s	.equ_found
.equ2		lea	16(a3),a0
		move.l	a0,d2
		lea	.cont2(pc),a0
		bra.s	.equ_found
.equ3		lea	24(a3),a0
		move.l	a0,d2
		lea	.cont3(pc),a0
		bra.s	.equ_found
.equ4		move.l	a3,d2
		lea	.cont4(pc),a0
.equ_found	tst.w	d3
		beq.s	.no_direct_sav
		move.w	d3,(a1)+
		move.w	d3,d5
		neg.w	d5
		lsl.w	#3,d3
		lea	-8(a2,d3.w),a4
		subq.w	#1,d5
.direct_sav	move.w	(a4),(a1)+
		addq.w	#8,a4
		dbra	d5,.direct_sav
		moveq	#0,d3
.no_direct_sav	tst.w	d7
		bmi.s	.end_pack
		movea.l	a2,a4
		movea.l	d2,a5
		moveq	#-1,d5
.scan_lop	cmpm.w	(a4)+,(a5)+
		addq.w	#6,a4
		addq.w	#6,a5
		dbne	d5,.scan_lop
		neg.w	d5
		cmp.w	d4,d5
		blt.s	.not_this
		move.w	d5,d4
		movea.l	d2,a6
.not_this	jmp	(a0)
