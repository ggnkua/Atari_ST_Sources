;***************************************************************************
; Unpacking source for Pack-Ice Version 2.0
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
decrunch:	movem.l d0-a6,-(sp)		; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne.s	l0007			; no!
		move.l	(a0)+,d0
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea	l0021+120(pc),a2	; at the end of the
		moveq	#$77,d0			; unpacked data
l0000:		move.b	-(a1),-(a2)
		dbra	d0,l0000
		bsr	l000c
		bsr.s	l0008
		bsr	l0010		;; Picture decrunch!
		bcc.s	l0004		;; These marked lines are only
		movea.l a3,a1		;; necessary, if you selected the
		move.w	#$0f9f,d7	;; additional picture decrunch
l0001:		moveq	#3,d6		;; in Pack-Ice.
l0002:		move.w	-(a1),d4	;;
		moveq	#3,d5		;;
l0003:		add.w	d4,d4		;;
		addx.w	d0,d0		;;
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,l0003	;;
		dbra	d6,l0002	;;
		movem.w d0-d3,(a1)	;;
		dbra	d7,l0001	;;
l0004:		move.l	(sp),d0			; move all data to
		lea	-120(a4),a1		; 120 bytes lower
l0005:		move.b	(a4)+,(a1)+
		dbra	d0,l0005
		subi.l	#$010000,d0
		bpl.s	l0005
		moveq	#$77,d0			; restore saved data
		movea.l l0021+120(pc),a2
l0006:		move.b	-(a2),-(a3)
		dbra	d0,l0006
l0007:		movem.l (sp)+,d0-a6		; restore registers
		rts
l0008:		bsr.s	l0010
		bcc.s	l000b
		moveq	#0,d1
		bsr.s	l0010
		bcc.s	l000a
		lea	l001e(pc),a1
		moveq	#4,d3
l0009:		move.l	-(a1),d0
		bsr.s	l0013
		swap	d0
		cmp.w	d0,d1
		dbne	d3,l0009
		add.l	20(a1),d1
l000a:		move.b	-(a5),-(a6)
		dbra	d1,l000a
l000b:		cmpa.l	a4,a6
		bgt.s	l0016
		rts
l000c:		moveq	#3,d0
l000d:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,l000d
		rts
l000e:		move.w	a5,d7
		btst	#0,d7
		bne.s	l000f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	l0015
l000f:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	l0015
l0010:		add.l	d7,d7
		beq.s	l0011
		rts
l0011:		move.w	a5,d7
		btst	#0,d7
		bne.s	l0012
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
l0012:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
l0013:		moveq	#0,d1
l0014:		add.l	d7,d7
		beq.s	l000e
l0015:		addx.w	d1,d1
		dbra	d0,l0014
		rts
l0016:		lea	l001f(pc),a1
		moveq	#3,d2
l0017:		bsr.s	l0010
		dbcc	d2,l0017
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	l0018
		bsr.s	l0013
l0018:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	l001a
		lea	l0020(pc),a1
		moveq	#1,d2
l0019:		bsr.s	l0010
		dbcc	d2,l0019
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	l0013
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	l001c
l001a:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	l0010
		bcc.s	l001b
		moveq	#8,d0
		moveq	#$40,d2
l001b:		bsr.s	l0013
		add.w	d2,d1
l001c:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
l001d:		move.b	-(a1),-(a6)
		dbra	d4,l001d
		bra	l0008
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
l001e:		dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
l001f:		dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
l0020:		dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
l0021:		ds.w 60			; free space (can be put in BSS)

