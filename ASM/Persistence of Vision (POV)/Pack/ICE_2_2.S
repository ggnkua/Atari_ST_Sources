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
filename: dc.b 'TMP1.PRG',0
	even
text	dc.b	27,'E'
	dc.b	"PACK TEXT......"
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
ice3_08:jmp	$00.l
ice3_0a

************* MASTERSOUND xtra bit ************
	cmp.l	#4,6(a0)	;is 4 bytes load for MASTERSOUND?
	beq.s	ice3_08		;YES!

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
bp
;*********************************************
; assemble with Devpac or any other Assembler
; length of this unpacking routine: 294 bytes
;  a0 = address of packed data

	movem.l d0-a6,-(sp)
	bsr.s	ice04
	cmpi.l	#'Ice!',d0		; Is file packed?
	bne	ice03			; no, leave this routine
	bsr.s	ice04
	lea	-8(a0,d0.l),a5
	bsr.s	ice04
	move.l	d0,(sp)

	lea	-12(a0),a4
	movea.l a4,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.l	a6,a1
	lea	space+120,a2
	move.w	#$77,d0
icemove1
	move.b	-(a1),-(a2)
	dbf	d0,icemove1

	move.b	-(a5),d7
	bsr	ice06

;	bsr	get_1_bit		;; Picture decrunch!
;	bcc.s	not_packed		;; Enable these lines in your own
;	move.w	#$0f9f,d7		;; sources if you are using the
;pic00: moveq	#3,d6			;; additional algorithm for lores
;pic01: move.w	-(a3),d4		;; picture pre-compression.
;	moveq	#3,d5			;;
;pic02: add.w	d4,d4			;;
;	addx.w	d0,d0			;;
;	add.w	d4,d4			;;
;	addx.w	d1,d1			;;
;	add.w	d4,d4			;;
;	addx.w	d2,d2			;;
;	add.w	d4,d4			;;
;	addx.w	d3,d3			;;
;	dbra	d5,pic02		;;
;	dbra	d6,pic01		;;
;	movem.w d0-d3,(a3)		;;
;	dbra	d7,pic00		;;

	move.w	#$77,d0
	lea	space+120,a2
icemove2
	move.b	-(a2),-(a3)
	dbf	d0,icemove2

ice03:	movem.l (sp)+,d0-a6
	rts

ice04:	moveq	#3,d1
ice05:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,ice05
	rts

ice06:	bsr.s	ice0a
	bcc.s	ice09
	moveq	#0,d1
	bsr.s	ice0a
	bcc.s	ice08
	lea	ice17(pc),a1
	moveq	#4,d3
ice07:	move.l	-(a1),d0
	bsr.s	ice0c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice07
	add.l	20(a1),d1
ice08:	move.b	-(a5),-(a6)
	dbra	d1,ice08
ice09:	cmpa.l	a4,a6
	bgt.s	ice0f
	rts
ice0a:	add.b	d7,d7
	bne.s	ice0b
	move.b	-(a5),d7
	addx.b	d7,d7
ice0b:	rts
ice0c:	moveq	#0,d1
ice0d:	add.b	d7,d7
	bne.s	ice0e
	move.b	-(a5),d7
	addx.b	d7,d7
ice0e:	addx.w	d1,d1
	dbra	d0,ice0d
	rts
ice0f:	lea	ice18(pc),a1
	moveq	#3,d2
ice10:	bsr.s	ice0a
	dbcc	d2,ice10
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice11
	bsr.s	ice0c
ice11:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice13
	lea	ice19(pc),a1
	moveq	#1,d2
ice12:	bsr.s	ice0a
	dbcc	d2,ice12
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice0c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	ice15
	sub.w	d4,d1
	bra.s	ice15
ice13:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	ice0a
	bcc.s	ice14
	moveq	#8,d0
	moveq	#$3f,d2
ice14:	bsr.s	ice0c
	add.w	d2,d1
ice15:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice16:	move.b	-(a1),-(a6)
	dbra	d4,ice16
	bra	ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice17:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice18:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice19:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f

	SECTION	BSS
space		ds.w 60			; free space (can be put in BSS)
old_colour	ds.w	1
loadadr:ds.l	1
	ds.b	500
stackend:
	ds.b	10







