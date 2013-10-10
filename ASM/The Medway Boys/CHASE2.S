	opt s-
	lea $40000,sp
	clr.w $8240.w
	move.w #$777,$825e.w
	clr.l $24.w
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	move.w #7,-(sp)
	trap #1
	addq.l #8,sp
	cmp.b #'t',d0
	bne notr
	move.l #-1,$24.w
notr	lea $8240.w,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	move.b #$06,$8201.w
	move.b #$82,$8203.w
	lea pic(pc),a0
	lea ($68200-34),a1
	bsr unpack
	lea ($68200-32),a0
	lea $8240.w,a1
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l #$12345,d0
pl	subq.l #1,d0
	bne pl
	lea main(pc),a0
	lea $2000.w,a1
	bsr unpack
	move.b #$60,$d152
	tst.l $24.w
	beq noc
	move.b #$4a,$954e
	move.b #$4a,$a272
noc	jmp $2000.w
unpack		movem.l d0-a6,-(sp)
		cmpi.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	ice_03		; no!
		move.l	(a0)+,d0	; read packed data
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l	(sp),a6
		movea.l a6,a3
		bsr.s	ice_08
		bsr.s	ice_04
ice_03:		movem.l (sp)+,d0-a6
		rts
ice_04:		bsr.s	ice_0c
		bcc.s	ice_07
		moveq	#0,d1
		bsr.s	ice_0c
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:		move.l	-(a1),d0
		bsr.s	ice_0f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:		move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:		cmpa.l	a4,a6
		bgt.s	ice_12
		rts
ice_08:		moveq	#3,d0
ice_09:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice_09
		rts
ice_0a:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice_11
ice_0b:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice_11
ice_0c:		add.l	d7,d7
		beq.s	ice_0d
		rts
ice_0d:		move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice_0e:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice_0f:		moveq	#0,d1
ice_10:		add.l	d7,d7
		beq.s	ice_0a
ice_11:		addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:		lea	ice_1b(pc),a1
		moveq	#3,d2
ice_13:		bsr.s	ice_0c
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		bsr.s	ice_0f
ice_14:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		lea	ice_1c(pc),a1
		moveq	#1,d2
ice_15:		bsr.s	ice_0c
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice_0f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice_18
ice_16:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice_0c
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:		bsr.s	ice_0f
		add.w	d2,d1
ice_18:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice_19:		move.b	-(a1),-(a6)
		dbra	d4,ice_19
		bra	ice_04
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ice_1b:		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:		DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20

text	dc.b 27,'E',27,'f'
	dc.b "+--------------------------------------+",10,13
	dc.b "|                                      |",10,13
	dc.b "|      The Crunchy Cracking Crew       |",10,13
	dc.b "|      ~~~~~~~~~~~~~~~~~~~~~~~~~       |",10,13
	dc.b "|                                      |",10,13
	dc.b "|         CHASE HQ 2 (1 Disk)          |",10,13
	dc.b "|                                      |",10,13
	dc.b "|                                      |",10,13
	dc.b "| Press 'T' for Credit & Boost Trainer |",10,13
	dc.b "|                                      |",10,13
	dc.b "|  * * * All work done by Fizz * * *   |",10,13
	dc.b "|                                      |",10,13
	dc.b "|                                      |",10,13
	dc.b "| Giga Greetings to all our friends !! |",10,13
	dc.b "|                                      |",10,13
	dc.b "|                                      |",10,13
	dc.b "| Copy with FCOPY 3.0 - Disk Defs *ON* |",10,13
	dc.b "|                                      |",10,13
	dc.b "+--------------------------------------+",10,13
	dc.w 0
pic	incbin 'b:\chase2.pi1'
	even
	dc.w 0
main	incbin 'b:\main'
