* Creates reset routine for reset screen
* Resident at $500

reset		move #$2700,sr
		moveq #7,d7
		move #$8240,a0
blank		clr.l (a0)+
		dbf d7,blank
		move.b #2,$ffff820a.w
		lea temp_stack(pc),sp
		lea reset(pc),a0
		move.l a0,$42a.w			res_vector
		move.l #$31415926,$426.w	res_valid
		lea code(pc),a0
		lea $10000,a1
		bsr decrunch
		lea $10000,a0
relocate	MOVE.L 2(A0),D0
		ADD.L $6(A0),D0
		ADD.L $E(A0),D0
		LEA $1C(A0),A0
		MOVE.L A0,A1
		MOVE.L A0,A2
		MOVE.L A0,D1
		ADD.L D0,A1
		MOVE.L (A1)+,D0
		ADD.L D0,A2
		ADD.L D1,(A2)
		MOVEQ #0,D0
rel_lp	MOVE.B (A1)+,D0
		BEQ.S rel_done
		CMP.B #1,D0
		BEQ.S rel_1
		ADD.L D0,A2
		ADD.L D1,(A2)
		BRA.S rel_lp
rel_1		LEA $FE(A2),A2
		BRA.S rel_lp
rel_done	jmp (a0)

; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
; a1: Pointer on destination of unpacked data

decrunch:	movem.l d0-a6,-(sp)
		addq.l #4,a0
		move.l (a0)+,d0	; read packed data
		lea -8(a0,d0.l),a5
		move.l (a0)+,(sp)
		movea.l a1,a4
		movea.l a1,a6
		adda.l (sp),a6
		movea.l a6,a3
		bsr.s	ice_08
		bsr.s	ice_04
ice_03:	movem.l (sp)+,d0-a6
		rts
ice_04:	bsr.s	ice_0c
		bcc.s	ice_07
		moveq	#0,d1
		bsr.s	ice_0c
		bcc.s	ice_06
		lea	ice_1a(pc),a1
		moveq	#4,d3
ice_05:	move.l	-(a1),d0
		bsr.s	ice_0f
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice_05
		add.l	20(a1),d1
ice_06:	move.b	-(a5),-(a6)
		dbra	d1,ice_06
ice_07:	cmpa.l	a4,a6
		bgt.s	ice_12
		rts
ice_08:	moveq	#3,d0
ice_09:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice_09
		rts
ice_0a:	move.w	a5,d7
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
ice_0c:	add.l	d7,d7
		beq.s	ice_0d
		rts
ice_0d:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice_0e
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice_0e:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice_0f:	moveq	#0,d1
ice_10:	add.l	d7,d7
		beq.s	ice_0a
ice_11:	addx.w	d1,d1
		dbra	d0,ice_10
		rts
ice_12:	lea	ice_1b(pc),a1
		moveq	#3,d2
ice_13:	bsr.s	ice_0c
		dbcc	d2,ice_13
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice_14
		bsr.s	ice_0f
ice_14:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice_16
		lea	ice_1c(pc),a1
		moveq	#1,d2
ice_15:	bsr.s	ice_0c
		dbcc	d2,ice_15
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice_0f
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice_18
ice_16:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice_0c
		bcc.s	ice_17
		moveq	#8,d0
		moveq	#$40,d2
ice_17:	bsr.s	ice_0f
		add.w	d2,d1
ice_18:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice_19:	move.b	-(a1),-(a6)
		dbra	d4,ice_19
		bra	ice_04
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ice_1a:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ice_1b:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ice_1c:	DC.B $0b,$04,$07,$00,$01,$20,$00,$00
		DC.B $00,$20
		EVEN

;***************************************************************************

code		incbin reset.tos
		section bss
		even
		ds.l 49
temp_stack	ds.l 1
