		opt s-
		move.l a7,oldstack
      MOVE.L  #$10000,D1
      MOVEA.L 4(A7),A0
      ADDQ.L  #8,A0 
      MOVE.L  (A0)+,D0
      SUB.L   D0,D1 
      ADDI.L  #$11CC0,D1
      MOVE.L  D1,(A0)+
      ADD.L   D0,D1 
      MOVE.L  D1,(A0)+
      MOVE.L  #$27BE,D0 
      MOVE.L  D0,(A0)+
      ADD.L   D0,D1 
      MOVE.L  D1,(A0)+
      MOVE.L  #$3BE6,(A0)+
		clr.l -(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		move.l d0,$8.w
		lea $80000,sp
		clr.w $ffff8240.w
		move.w #$777,$ffff825e.w
		pea text
		move.w #9,-(sp)
		trap #1
		addq.l #6,sp
		move.w #7,-(sp)
		trap #1
		addq.l #2,sp 
		lea name1,a5
		lea $10000,a6
		bsr load
		lea $10000,a0
		bsr decrunch
		move.l $8.w,-(sp)
		move.w #$20,-(sp)
		trap #1
		addq.l #6,sp
		move.l oldstack,a7
		jmp $10000
		
oldstack	dc.l 0
load	move.w #0,-(sp)
	pea (a5)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	move.w d0,d7
	pea (a6)
	pea $70000
	move.w d7,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	rts

;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
decrunch:	move.w $ffff8240.w,-(sp)
		movem.l d0-a6,-(sp)		; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne.s	ice2_07			; no!
		move.l	(a0)+,d0
		lea	-8(a0,d0.l),a5
		move.l	(a0)+,(sp)
		lea	108(a0),a4
		movea.l a4,a6
		adda.l	(sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea	ice2_21+120(pc),a2	; at the end of the
		moveq	#$77,d0			; unpacked data
ice2_00:	move.b	-(a1),-(a2)
		dbra	d0,ice2_00
		bsr	ice2_0c
		bsr.s	ice2_08
ice2_04:	move.l	(sp),d0			; move all data to
		lea	-120(a4),a1		; 120 bytes lower
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0			; restore saved data
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	movem.l (sp)+,d0-a6		; restore registers
		move.w (sp)+,$ffff8240.w
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		eor.w #$070,$ffff8240.w
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60			; free space (can be put in BSS)

name1		dc.b 'FINAL',0
text		dc.b 27,'E',27,'f'
		dc.b "The Medway Boys Present",10,13
		dc.b "~~~~~~~~~~~~~~~~~~~~~~~",10,10,13
		dc.b "KICK OFF 2 (FINAL WHISTLE)",10,10,13
		dc.b "Cracked/Packed by Zippy",10,13
		dc.b "Original Supplied by Teddystacker+Gino",10,10,10,13
		dc.b "Another very good protection from Anco!",10,13
		dc.b "This time we had 6 disk protection",10,13
		dc.b "checks, 9 checksums and a nice little",10,13
		dc.b "routine that checked the file order",10,13
		dc.b "on the disk, then used it along with a",10,13
		dc.b "checksum of a raw sector read from the",10,13
		dc.b "main file.",10,13
		dc.b "As well as all that, the main file was",10,13
		dc.b "also encrypted !!!",10,10,13
		dc.b "Press a key to load....."
		even
		dc.w 0
