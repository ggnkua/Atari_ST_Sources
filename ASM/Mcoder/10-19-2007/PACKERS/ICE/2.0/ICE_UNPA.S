;***************************************************************************
; Unpacking source for Pack-Ice Version 2.0
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
decrunch:	movem.l d0-a6,-(sp)
		cmpi.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	l0003		; no!
		move.l	(a0)+,d0	; read packed data
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l	(sp),a6
		movea.l a6,a3
		bsr.s	l0008
		bsr.s	l0004
		bsr	l000c		;; Picture decrunch!
		bcc.s	l0003		;; These marked lines may be
		move.w	#$0f9f,d7	;; removed in your own sources
l0000:		moveq	#3,d6		;; if you do not use the
l0001:		move.w	-(a3),d4	;; additional algorithm.
		moveq	#3,d5		;;
l0002:		add.w	d4,d4		;;
		addx.w	d0,d0		;;
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,l0002	;;
		dbra	d6,l0001	;;
		movem.w d0-d3,(a3)	;;
		dbra	d7,l0000	;;
l0003:		movem.l (sp)+,d0-a6
		rts
l0004:		bsr.s	l000c
		bcc.s	l0007
		moveq	#0,d1
		bsr.s	l000c
		bcc.s	l0006
		lea	l001a(pc),a1
		moveq	#4,d3
l0005:		move.l	-(a1),d0
		bsr.s	l000f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,l0005
		add.l	20(a1),d1
l0006:		move.b	-(a5),-(a6)
		dbra	d1,l0006
l0007:		cmpa.l	a4,a6
		bgt.s	l0012
		rts
l0008:		moveq	#3,d0
l0009:		move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,l0009
		rts
l000a:		move.w	a5,d7
		btst	#0,d7
		bne.s	l000b
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	l0011
l000b:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	l0011
l000c:		add.l	d7,d7
		beq.s	l000d
		rts
l000d:		move.w	a5,d7
		btst	#0,d7
		bne.s	l000e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
l000e:		move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
l000f:		moveq	#0,d1
l0010:		add.l	d7,d7
		beq.s	l000a
l0011:		addx.w	d1,d1
		dbra	d0,l0010
		rts
l0012:		lea	l001b(pc),a1
		moveq	#3,d2
l0013:		bsr.s	l000c
		dbcc	d2,l0013
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	l0014
		bsr.s	l000f
l0014:		move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	l0016
		lea	l001c(pc),a1
		moveq	#1,d2
l0015:		bsr.s	l000c
		dbcc	d2,l0015
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	l000f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	l0018
l0016:		moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	l000c
		bcc.s	l0017
		moveq	#8,d0
		moveq	#$40,d2
l0017:		bsr.s	l000f
		add.w	d2,d1
l0018:		lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
l0019:		move.b	-(a1),-(a6)
		dbra	d4,l0019
		bra	l0004
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
l001a:		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
l001b:		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
l001c:		DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20
;***************************************************************************
