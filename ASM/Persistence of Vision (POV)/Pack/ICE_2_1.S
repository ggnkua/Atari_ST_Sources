* ICE 2.1 trap 1 interception routine

FLASH_COLOUR	equ	0	;colour to flash on depack

begin:	lea	stackend,sp
	move.l	sp,d0
	subi.l	#begin-$0120,d0
	move.l	d0,-(sp)
	pea	begin-$0100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$0c,sp
	dc.w	$a00a
	bsr	ice3_04
	clr.w	$ffff8240.w
	move.w	#-1,$ffff825e.w
	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	$84.w,ice3_08+2
	move.l	#ice3_06,$84.w
	bsr	ice3_05

	move.w	#20000,d7
delay	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bmi.s	get
	dbf	d7,delay
	bra.s	load
get	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
load	
	pea	ice3_02(pc)
	pea	ice3_02(pc)
	pea	filename(pc)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	bsr	ice3_04
	move.l	ice3_08+2(pc),$84.w
	bsr	ice3_05
	dc.w	$a009
	clr.w	-(sp)
	trap	#1

ice3_02:dc.l 0
filename: dc.b 'CULT.EXE',0
	even
text	dc.b	27,'E'
 dc.b	27,'Y',32+6,32+(40-31)/2,"SLAYTANIC CULT DEMO 5"
 dc.b	27,'Y',32+7,32+(40-31)/2,"---------------------"
 dc.b	27,'Y',32+9,32+(40-32)/2,"Depacked and repacked smaller by"
 dc.b	27,'Y',32+11,32+(40-12)/2,"MAC SYS DATA"
 dc.b	27,'Y',32+13,32+(40-6)/2,"1/9/91"
 dc.b	27,'Y',32+17,32+(40-38)/2,"Roggie does it again with more amazing"
 dc.b	27,'Y',32+18,32+(40-14)/2,"Quartet tunes."
	dc.b	0
	even
ice3_04:clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts
ice3_05:move.l	d7,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
ice3_06:movea.l	sp,a0
	btst	#$0d-8,(sp)
	bne.s	ice3_07
	move	usp,a0
	subq.l	#6,a0
ice3_07:addq.l	#6,a0
	cmpi.w	#$3f,(a0)
	beq.s	ice3_0a

******** HISOFT BASIC FRIG
;;	cmpi.w	#$42,(a0)
;;	bne.s	ice3_08
;frig for seek to end of file (for file length to load)
;;	cmp.w	#2,8(a0)	;seek to end of file
;;	bne.s	ice3_08
;;	move.l	8(a0),loadadr
;;	move.l	2(sp),frig_jmp+2
;;	move.l	#seek_frig,2(sp)

ice3_08:jmp	$00.l


;;seek_frig
;;	move.l	a0,-(sp)
;;	move.l	length_table_pos,a0
;;	move.l	(a0)+,d0		;put new length in D0.L
;;	move.l	a0,length_table_pos
;;	move.l	(sp)+,a0
;;frig_jmp
;;	jmp	0.l

;;length_table_pos	dc.l	length_table
;;length_table
;;	dc.l	32000	;JARRE.PIC
;;	dc.l	2757	;JARRE.EXE
;;	dc.l	74725	;JARRE_01.SPL
;;	dc.l	135480	;JARRE_02.SPL
;;	dc.l	109086	;JARRE_03.SPL




ice3_0a
************* MASTERSOUND xtra bit ************
;	cmp.l	#4,6(a0)	;is 4 bytes load for MASTERSOUND?
;	beq.s	ice3_08		;YES!

***********************************************
	move.l	8(a0),loadadr
	move.l	2(sp),ice3_0c+2
	move.l	#ice3_0b,2(sp)
	bra.s	ice3_08
ice3_0b:tst.w	2(sp)
	bmi.s	ice3_0c
	movea.l	loadadr(pc),a0
	bsr.s	ice3_0e
ice3_0c:jmp	$00.l

ice3_0e:
;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data
decrunch:	movem.l d0-a6,-(sp)		; save registers
		cmpi.l	#'Ice!',(a0)+		; Data packed?
		bne	ice2_07			; no!
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

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#-1,-(sp)	;get old colour
	move.w	#FLASH_COLOUR,-(sp)	;colour number
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	move.w	d0,old_colour
	movem.l	(sp)+,d0-d7/a0-a6

		bsr	ice2_0c
		bsr.s	ice2_08

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	old_colour,-(sp)
	move.w	#FLASH_COLOUR,-(sp)	;colour number
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6

		bsr	ice2_10		;; Picture decrunch!
		bcc.s	ice2_04		;; These marked lines are only
		movea.l a3,a1		;; necessary, if you selected the
		move.w	#$0f9f,d7	;; additional picture packer
ice2_01:	moveq	#3,d6		;; in Pack-Ice.
ice2_02:	move.w	-(a1),d4	;;
		moveq	#3,d5		;; If you never use the picture
ice2_03:	add.w	d4,d4		;; pack option, you may delete
		addx.w	d0,d0		;; all the lines marked with ";;"
		add.w	d4,d4		;;
		addx.w	d1,d1		;;
		add.w	d4,d4		;;
		addx.w	d2,d2		;;
		add.w	d4,d4		;;
		addx.w	d3,d3		;;
		dbra	d5,ice2_03	;;
		dbra	d6,ice2_02	;;
		movem.w d0-d3,(a1)	;;
		dbra	d7,ice2_01	;;

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
		rts
ice2_08:
	bsr.s	ice2_10
	bcc.s	ice2_0b
	moveq	#0,d1
	bsr.s	ice2_10
	bcc.s	ice2_0a
	lea	ice2_1e(pc),a1
	moveq	#4,d3
ice2_09:
	move.l	-(a1),d0
	bsr	ice2_13
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice2_09
	add.l	20(a1),d1
ice2_0a:
	move.b	-(a5),-(a6)
	dbra	d1,ice2_0a
ice2_0b:
	cmpa.l	a4,a6
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

	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d7,-(sp)
	move.w	#FLASH_COLOUR,-(sp)
	move.w	#7,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d7/a0-a6
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
	SECTION	BSS
ice2_21:	ds.w 60			; free space (can be put in BSS)
old_colour	ds.w	1
loadadr:ds.l	1
	ds.l	1000
stackend:
	ds.b	10
