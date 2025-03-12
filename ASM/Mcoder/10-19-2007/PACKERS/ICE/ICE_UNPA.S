;
; registres utilis‚s :
;
; a0=pointeur sur source
; a1=pointeur sur destination
; a2=ptr d‚but dest
; a3=scratch register
;
; unused :
; a4/a5/a6
;
; avec PI1 :
;	d0-d7
;
; sans PI1 :
;	d0-d3/d7
;
		OPT	O+
PI1=
READBIT		MACRO
		add	d7,d7
		bne.s	.\@
		movep	-2(a0),d7
		move.b	-(a0),d7
		subq.l	#1,a0
		addx	d7,d7
.\@:
		ENDM

READBITS:	MACRO
		moveq	#0,d1
.\@A:		add	d7,d7
		bne.s	.\@B
		movep	-2(a0),d7
		move.b	-(a0),d7
		subq.l	#1,a0
		addx	d7,d7
.\@B:		addx	d1,d1
		dbra	d0,.\@A
		ENDM
READBITS2:	MACRO
.\@A:		add	d7,d7
		bne.s	.\@B
		movep	-2(a0),d7
		move.b	-(a0),d7
		subq.l	#1,a0
		addx	d7,d7
.\@B:		addx	d1,d1
		bcc.s	.\@A
		ENDM

;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data
decrunch:
		movem.l	d0-d7/a0-a3,-(sp)
		cmp.l	#'Ice!',(a0)+	; Is data packed?
		bne.s	ice_03		; no!
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		lea	-12(a0,d0.l),a0
		move.l	d1,(sp)
		move.l	a1,a2
		add.l	d1,a1
		movep	-2(a0),d7
		move.b	-(a0),d7
		subq	#1,a0

		bsr	depack
		ifeq	PI1
		READBIT			;; picture decrunch
		bcc.s	ice_03		;; These marked lines may be
		add.l	(sp),a1
		move	#32000/8-1,d7	;; removed in your own sources
ice_00:		moveq	#3,d6		;; if you do not use the
ice_01:		move	-(a1),d4	;; additional algorithm.
		moveq	#3,d5		;;
ice_02:		add	d4,d4		;;
		addx	d0,d0		;;
		add	d4,d4		;;
		addx	d1,d1		;;
		add	d4,d4		;;
		addx	d2,d2		;;
		add	d4,d4		;;
		addx	d3,d3		;;
		dbra	d5,ice_02	;;
		dbra	d6,ice_01	;;
		movem	d0-d3,(a1)	;;
		dbra	d7,ice_00	;;
		endc
ice_03:
		movem.l	(sp)+,d0-d7/a0-a3
		rts
;
;
ice_16:
		move	#$10000>>6,d1
		moveq	#0,d2
		READBIT
		bcc.s	.ice_17
		move	#$10000>>9,d1
		moveq	#$40,d2
.ice_17:	READBITS2
		add	d2,d1
ice_18:		lea	2(a1,d1.w),a3
		add	d3,a3
		move.b	-(a3),-(a1)
.ice_19:	move.b	-(a3),-(a1)
		dbra	d3,.ice_19
depack:
		READBIT
		bcc.s	ice_07
		moveq	#0,d1
		READBIT
		bcc.s	ice_06
		lea	ice_1a(pc),a3
		moveq	#5-1,d2
.ice_05:	move	-(a3),d1
		READBITS2
		cmp	-(a3),d1
		dbne	d2,.ice_05
		add	22(a3),d1
ice_06:		move.b	-(a0),-(a1)
		dbra	d1,ice_06
ice_07:		cmp.l	a2,a1
		bls.s	return

		moveq	#3,d2
.ice_13:	READBIT
		dbcc	d2,.ice_13

		clr	d3
		move.b	ice_1b+1(pc,d2.w),d3
		moveq	#0,d1
		move.b	ice_1b+6(pc,d2.w),d0
		bmi.s	.ice_14
		ext	d0
		READBITS
.ice_14:
		add	d1,d3
		beq	ice_16

		moveq	#1,d2
.ice_15:	READBIT
		dbcc	d2,.ice_15
		add	d2,d2
		move	ice_1c+2(pc,d2.w),d1
		READBITS2
		add	ice_1c+8(pc,d2.w),d1
		bra	ice_18
return:		rts
ice_1b:
		DC.B	$08,$04,$02,$01,$00
		DC.B	$09,$01,$00,$ff,$ff

ice_1c:		DC.W	$10000>>12
		DC.W	$10000>>5
		DC.W	$10000>>8

		DC.W	$0120
		DC.W	$0000
		DC.W	$0020

		DC.W	$7fff,$10000>>15
		DC.W	$00ff,$10000>>8
		DC.W	$0007,$10000>>3
		DC.W	$0003,$10000>>2
		DC.W	$0003,$10000>>2
ice_1a:
		DC.L	$0000010d
		DC.L	$0000000e
		DC.L	$00000007
		DC.L	$00000004
		DC.L	$00000001
