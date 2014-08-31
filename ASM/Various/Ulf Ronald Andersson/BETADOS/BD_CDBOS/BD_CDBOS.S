;----------------------------------------------------------------------------
; File name:	BD_CDBOS.S			Revision date:	1998.09.11
; Created by:	Ulf Ronald Andersson		Creation date:	1998.03.06
;----------------------------------------------------------------------------
; Purpose:
;	BOS driver for CDROM access
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
	output	.BOS
;----------------------------------------------------------------------------
XHDI_MAGIC	=	$27011992
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
start:
	bsr	show_init_mess
	move.l	#BOS_init_p,d0
	rts
;----------------------------------------------------------------------------
BOS_Init_fun:
	movem.l	d1-d7/a0-a6,-(sp)
	move	d1,-(sp)
	move	d0,-(sp)
	bsr	BOS_init_sub
	addq.w	#4,sp
	movem.l	(sp)+,d1-d7/a0-a6
	rts
;----------------------------------------------------------------------------
Metaopen_fun:
	move.l	a0,-(sp)
	bsr	Metaopen_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
E_OK_sub:
	moveq	#0,d0
	rts
;----------------------------------------------------------------------------
Metaread_fun:
	move.l	a0,-(sp)
	bsr	Metaread_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
E_UNCMD_sub:
	moveq	#-3,d0
	rts
;----------------------------------------------------------------------------
Metastatus_fun:
	move.l	a0,-(sp)
	bsr	Metastatus_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metaioctl_fun:
	move.l	a0,-(sp)
	bsr	Metaioctl_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metagettoc_fun:
	move.l	a0,-(sp)
	bsr	Metagettoc_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metadiscinfo_fun:
	move.l	a0,-(sp)
	bsr	Metadiscinfo_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metastartaudio_fun:
	move.l	a0,-(sp)
	bsr	Metastartaudio_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metastopaudio_fun:
	move.l	a0,-(sp)
	bsr	Metastopaudio_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
Metasetsongtime_fun:
	move.l	a0,-(sp)
	bsr	Metasetsongtime_sub
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
	move.l	#10,-(sp)
	move	#12,-(sp)
	move	#12,-(sp)
	move	#12,-(sp)
	move	#$2e,-(sp)
	trap	#14			 ;nvmaccess
	lea	12(sp),sp
	rts
;----------------------------------------------------------------------------
	dc.l	XHDI_MAGIC
XHDI_dispatcher:
	move	4(sp),d0
	cmp	#15,d0
	beq.s	XHMediumChanged_fun
	bra.s	goto_old_XHDI
;
XHMediumChanged_fun:
	move.l	6(sp),-(sp)		;repush drive ID and LUN
	move	#15,-(sp)		;repush XHMediumChanged opcode
	bsr.s	goto_old_XHDI		;call old XHDI driver
	addq.w	#6,sp			;clean stack of repushed stuff
	movem.l	d1/d2/a0-a2,-(sp)
	move.l	$2e(sp),-(sp)		;NB: this looks BUGGY !!!
	move.l	d0,-(sp)
	jsr	XHMediumChanged_sub
	addq.w	#8,sp
	movem.l	(sp)+,d1/d2/a0-a2
	rts
;----------------------------------------------------------------------------
goto_old_XHDI:
	move.l	old_XHDI_p,-(sp)
	rts
;----------------------------------------------------------------------------
t_de:
	movem.l	d3/d4/a3/a4,-(sp)
	lea	-$c(sp),sp
	movea.l	a0,a4
	move.l	d0,d3
	move.l	d1,d4
	movea.l	a1,a3
	lea	(sp),a0
	clr.w	d0
	moveq	#12,d1
	bsr	t_32e6
	move.b	#-$42,(sp)
	move.l	d3,2(sp)
	move.l	d4,d0
	move.l	#$930,d1
	bsr	t_3442
	move.b	d0,8(sp)
	move.b	#-$10,9(sp)
	clr.l	-(sp)
	move.l	a3,-(sp)
	moveq	#3,d2
	move.l	d4,d1
	lea	8(sp),a1
	movea.l	a4,a0
	moveq	#12,d0
	bsr	t_1fc0
	addq.w	#8,sp
	lea	12(sp),sp
	movem.l	(sp)+,d3/d4/a3/a4
	rts
;----------------------------------------------------------------------------
t_136:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_13a:
	movem.l	d3-d7/a2-a4,-(sp)
	subq	#8,sp
	movea.l	a0,a4
	movea.l	a1,a3
	movea.l	4(a3),a2
	move.l	(a1),d3
	move.l	8(a3),d0
	move.l	#$930,d1
	bsr	t_3442
	move.l	d0,d4
	movea.l	a2,a3
	move.l	#$1b,2(sp)
	clr.w	(sp)
	clr.w	d0
	movea.l	a4,a0
	bsr	t_223a
	move.l	#$930,d2
	move.l	d4,d1
	move.l	a2,d0
	bsr	t_2208
	tst.w	d0
	bne	t_212
	movea.l	$a2(a4),a3
	move.l	$a6(a4),d0
	move.l	#$930,d1
	bsr	t_3442
	move.l	d0,2(sp)
	move	#1,(sp)
	bra.s	t_212
;----------------------------------------------------------------------------
t_1a0:
	move	#3,6(sp)
	move.l	d4,d6
	moveq	#-2,d7
	cmp.l	2(sp),d6
	ble.s	t_1b4
	move.l	2(sp),d6
t_1b4:
	move.l	d6,d5
	lsl.l	#3,d5
	add.l	d6,d5
	lsl.l	#3,d5
	add.l	d6,d5
	add.l	d5,d5
	add.l	d6,d5
	lsl.l	#4,d5
	bra.s	t_1d4
;----------------------------------------------------------------------------
t_1c6:
	movea.l	a3,a1
	move.l	d5,d1
	move.l	d3,d0
	movea.l	a4,a0
	bsr	t_de
	move	d0,d7
t_1d4:
	move	6(sp),d0
	subq	#1,6(sp)
	tst.w	d0
	beq.s	t_1e4
	tst.w	d7
	bne	t_1c6
t_1e4:
	tst.w	d7
	beq.s	t_1f4
	move	d7,d0
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	bra.s	t_21a
;----------------------------------------------------------------------------
t_1f4:
	move	(sp),d0
	beq.s	t_206
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	d5,d0
	bsr	t_30fc
	adda.l	d5,a2
	bra.s	t_208
;----------------------------------------------------------------------------
t_206:
	adda.l	d5,a3
t_208:
	sub.l	d6,d4
	add.l	d6,d3
	moveq	#$32,d0
	bsr	t_21f6
t_212:
	tst.l	d4
	bne	t_1a0
	moveq	#0,d0
t_21a:
	addq.w	#8,sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
;----------------------------------------------------------------------------
t_222:
	movem.l	d3/d4/a2,-(sp)
	movea.l	a0,a2
	clr.w	d3
	moveq	#-1,d4
	cmp	#-$2,d0
	blt	t_326
	cmp	#-$2,d0
	beq	t_2fe
	cmp	#-$1,d0
	beq	t_2fa
	tst.w	d0
	bne.s	t_24e
	moveq	#0,d0
	bra	t_328
;----------------------------------------------------------------------------
t_24e:
	movea.l	$a2(a2),a1
	lea	$3f8(a2),a0
	bsr	t_2010
	tst.w	d0
	bpl.s	t_26a
	moveq	#1,d0
	movea.l	a2,a0
	bsr	t_223a
	bra	t_2fa
;----------------------------------------------------------------------------
t_26a:
	movea.l	$a2(a2),a0
	clr.w	d0
	move.b	(a0),d0
	and	#$70,d0
	cmp	#$70,d0
	bne.s	t_28e
	clr.w	d3
	move.b	2(a0),d3
	and	#15,d3
	clr.w	d4
	move.b	12(a0),d4
	bra.s	t_29a
;----------------------------------------------------------------------------
t_28e:
	movea.l	$a2(a2),a0
	clr.w	d3
	move.b	(a0),d3
	and	#$7f,d3
t_29a:
	move	d4,d1
	move	10(a2),d0
	bsr	t_21c4
	move	d4,d0
	cmp	#$26,d0
	beq.s	t_2fe
	bgt.s	t_2d2
	cmp	#$20,d0
	beq.s	t_2fe
	bgt.s	t_2c6
	tst.w	d0
	beq.s	t_306
	subq	#4,d0
	beq.s	t_2fa
	subq	#5,d0
	beq.s	t_316
	bra.s	t_326
;----------------------------------------------------------------------------
t_2c6:
	sub.w	#$21,d0
	beq.s	t_312
	subq	#3,d0
	beq.s	t_2fe
	bra.s	t_326
;----------------------------------------------------------------------------
t_2d2:
	cmp	#$47,d0
	beq.s	t_316
	bgt.s	t_2ec
	sub.w	#$28,d0
	beq.s	t_306
	subq	#2,d0
	beq.s	t_2fe
	sub.w	#$10,d0
	beq.s	t_31a
	bra.s	t_326
;----------------------------------------------------------------------------
t_2ec:
	sub.w	#$64,d0
	beq.s	t_302
	sub.w	#$20,d0
	beq.s	t_302
	bra.s	t_326
;----------------------------------------------------------------------------
t_2fa:
	moveq	#-2,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_2fe:
	moveq	#-5,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_302:
	moveq	#-7,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_306:
	moveq	#1,d0
	movea.l	a2,a0
	bsr	t_223a
	moveq	#-14,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_312:
	moveq	#-8,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_316:
	moveq	#-12,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_31a:
	moveq	#1,d0
	movea.l	a2,a0
	bsr	t_223a
	moveq	#-$12,d0
	bra.s	t_328
;----------------------------------------------------------------------------
t_326:
	moveq	#-1,d0
t_328:
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
t_32e:
	move.l	a2,-(sp)
	movea.l	a0,a2
	move.l	#$800,d0
	movea.l	$48(a2),a1
	jsr	(a1)
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_342:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	$a2(a2),a3
	cmp.l	#$800,d0
	beq.s	t_358
	moveq	#-$20,d0
	bra.s	t_380
;----------------------------------------------------------------------------
t_358:
	move.l	#8,(a3)
	clr.l	4(a3)
	move.l	d0,8(a3)
	clr.l	12(a3)
	moveq	#12,d0
	movea.l	a3,a1
	lea	$3f8(a2),a0
	bsr	t_20b0
	move	d0,d3
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
t_380:
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_386:
	movem.l	d3/a3/a4,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a4
	movea.l	a1,a3
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#$43,(sp)
	clr.b	1(sp)
	move.b	#12,8(sp)
	move.b	#$40,9(sp)
	clr.l	(a3)
	clr.l	-(sp)
	move.l	$a2(a4),-(sp)
	moveq	#2,d2
	move.l	#$324,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a4,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne.s	t_3e4
	movea.l	$a2(a4),a0
	cmp.b	#1,6(a0)
	bls.s	t_3e4
	move.l	8(a0),(a3)
t_3e4:
	move	d3,d0
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	lea	10(sp),sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_3f8:
	clr.l	(a1)
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_3fe:
	movem.l	d3-d7/a2-a5,-(sp)
	lea	-$e(sp),sp
	movea.l	a0,a4
	movea.l	a1,a3
	move.l	d0,8(sp)
	move	d1,6(sp)
	movea.l	4(a3),a2
	move.l	(a1),d3
	move.l	8(a3),d0
	move.l	8(sp),d1
	bsr	t_3442
	move.l	d0,d5
	movea.l	a2,a3
	move.l	#$1fc00,d0
	move.l	8(sp),d1
	bsr	t_3442
	move.l	d0,2(sp)
	clr.w	(sp)
	movea.l	a4,a0
	clr.w	d0
	bsr	t_223a
	move.l	8(sp),d2
	move.l	d5,d1
	move.l	a2,d0
	bsr	t_2208
	tst.w	d0
	bne	t_4f6
	movea.l	$a2(a4),a3
	move.l	$a6(a4),d0
	move.l	8(sp),d1
	bsr	t_3442
	move.l	d0,2(sp)
	move	#1,(sp)
	bra	t_4f6
;----------------------------------------------------------------------------
t_472:
	move	6(sp),12(sp)
	move.l	d5,d7
	moveq	#-2,d4
	cmp.l	2(sp),d7
	ble.s	t_486
	move.l	2(sp),d7
t_486:
	move.l	8(sp),d0
	move.l	d7,d1
	bsr	t_33f8
	move.l	d0,d6
	bra.s	t_4be
;----------------------------------------------------------------------------
t_494:
	movea.l	a3,a1
	move.l	d6,d2
	move	d7,d1
	ext.l	d1
	move.l	d3,d0
	lea	$3f8(a4),a0
	movea.l	$40(a4),a5
	jsr	(a5)
	move	d0,d4
	tst.w	d0
	beq.s	t_4b6
	moveq	#$14,d0
	bsr	t_21f6
	bra.s	t_4be
;----------------------------------------------------------------------------
t_4b6:
	andi.l	#-$40000001,$d4(a4)
t_4be:
	move	12(sp),d0
	subq	#1,12(sp)
	tst.w	d0
	beq.s	t_4ce
	tst.w	d4
	bne	t_494
t_4ce:
	tst.w	d4
	beq.s	t_4de
	move	d4,d0
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	bra.s	t_4fe
;----------------------------------------------------------------------------
t_4de:
	move	(sp),d0
	beq.s	t_4f0
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	d6,d0
	bsr	t_30fc
	adda.l	d6,a2
	bra.s	t_4f2
;----------------------------------------------------------------------------
t_4f0:
	adda.l	d6,a3
t_4f2:
	sub.l	d7,d5
	add.l	d7,d3
t_4f6:
	tst.l	d5
	bne	t_472
	moveq	#0,d0
t_4fe:
	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a2-a5
	rts
;----------------------------------------------------------------------------
t_508:
	moveq	#2,d1
	move.l	#$800,d0
	bsr	t_3fe
	rts
;----------------------------------------------------------------------------
t_516:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	move.l	#$920,d0
	movea.l	$48(a2),a1
	jsr	(a1)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_550
	moveq	#2,d1
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	#$920,d0
	bsr	t_3fe
	move.l	d0,d3
	movea.l	a2,a0
	movea.l	$48(a2),a1
	move.l	#$800,d0
	jsr	(a1)
t_550:
	move.l	d3,d0
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_558:
	moveq	#2,d1
	move.l	#$800,d0
	bsr	t_3fe
	rts
;----------------------------------------------------------------------------
t_566:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	move.l	#$914,d0
	movea.l	$48(a2),a1
	jsr	(a1)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_5a0
	moveq	#1,d1
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	#$914,d0
	bsr	t_3fe
	move.l	d0,d3
	movea.l	a2,a0
	movea.l	$48(a2),a1
	move.l	#$800,d0
	jsr	(a1)
t_5a0:
	move.l	d3,d0
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_5a8:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#0,d3
	lea	$3f8(a2),a0
	bsr	t_1fda
	movea.l	$a2(a2),a1
	lea	$3f8(a2),a0
	bsr	t_2010
	tst.w	d0
	bmi.s	t_618
	movea.l	$a2(a2),a0
	clr.w	d1
	move.b	(a0),d1
	and	#$70,d1
	cmp	#$70,d1
	bne.s	t_5e4
	clr.w	d0
	move.b	12(a0),d0
	bra.s	t_5f0
;----------------------------------------------------------------------------
t_5e4:
	movea.l	$a2(a2),a0
	clr.w	d0
	move.b	(a0),d0
	and	#$7f,d0
t_5f0:
	move	d0,d1
	tst.w	d1
	beq.s	t_60c
	sub.w	#$28,d1
	beq.s	t_604
	sub.w	#$12,d1
	beq.s	t_604
	bra.s	t_610
;----------------------------------------------------------------------------
t_604:
	moveq	#1,d0
	movea.l	a2,a0
	bsr	t_223a
t_60c:
	moveq	#0,d3
	bra.s	t_626
;----------------------------------------------------------------------------
t_610:
	move.l	#-$7ffe,d3
	bra.s	t_626
;----------------------------------------------------------------------------
t_618:
	move.l	#-$7f80,d3
	moveq	#1,d0
	movea.l	a2,a0
	bsr	t_223a
t_626:
	move	$12(a2),d0
	beq.s	t_632
	or.l	#8,d3
t_632:
	move.l	a3,d0
	beq.s	t_642
	moveq	#$20,d1
	movea.l	a3,a0
	clr.w	d0
	bsr	t_32e6
	move.l	d3,(a3)
t_642:
	move.l	d3,d0
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_64a:
	move	d3,-(sp)
	move.l	a3,-(sp)
	subq	#6,sp
	movea.l	a0,a3
	move	d0,d3
	moveq	#6,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#$1b,(sp)
	move.b	#1,1(sp)
	move.b	d3,4(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a3,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a3,a0
	movea.l	$3c(a3),a1
	jsr	(a1)
	addq.w	#6,sp
	movea.l	(sp)+,a3
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_694:
	move	d3,-(sp)
	move.l	a3,-(sp)
	subq	#6,sp
	movea.l	a0,a3
	move	d0,d3
	moveq	#6,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#$1e,(sp)
	move.b	d3,4(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a3,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a3,a0
	movea.l	$3c(a3),a1
	jsr	(a1)
	addq.w	#6,sp
	movea.l	(sp)+,a3
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_6d8:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_6dc:
	move	d3,-(sp)
	move.l	a3,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a3
	move	d0,d3
	moveq	#10,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#$4b,(sp)
	move.b	d3,8(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a3,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a3,a0
	movea.l	$3c(a3),a1
	jsr	(a1)
	lea	10(sp),sp
	movea.l	(sp)+,a3
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_724:
	movem.l	d3/a2-a5,-(sp)
	lea	-$1c(sp),sp
	movea.l	a0,a3
	movea.l	a1,a2
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#$48,(sp)
	move.b	(a2),4(sp)
	move.b	1(a2),5(sp)
	move.b	2(a2),7(sp)
	move.b	3(a2),8(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a3,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a3,a0
	movea.l	$3c(a3),a1
	jsr	(a1)
	move.l	d0,d3
	moveq	#-5,d1
	cmp.l	d0,d1
	bne	t_81a
	cmp.b	#1,1(a2)
	bne	t_81a
	cmp.b	#1,3(a2)
	bne	t_81a
	lea	$1a(sp),a1
	movea.l	a3,a0
	movea.l	$7c(a3),a4
	jsr	(a4)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_81a
	lea	10(sp),a4
	move.b	(a2),(a4)
	move.b	#2,1(a4)
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$80(a3),a5
	jsr	(a5)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_81a
	lea	$14(sp),a5
	move.b	7(a4),(a5)
	move.b	8(a4),1(a5)
	move.b	9(a4),2(a5)
	moveq	#1,d0
	add.b	2(a2),d0
	move.b	d0,(a4)
	cmp.b	$1b(sp),d0
	bls.s	t_7e6
	move.b	#-$56,(a4)
t_7e6:
	move.b	#2,1(a4)
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$80(a3),a2
	jsr	(a2)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_81a
	move.b	7(a4),3(a5)
	move.b	8(a4),4(a5)
	move.b	9(a4),5(a5)
	movea.l	a5,a1
	movea.l	a3,a0
	movea.l	$74(a3),a2
	jsr	(a2)
	bra.s	t_81c
;----------------------------------------------------------------------------
t_81a:
	move.l	d3,d0
t_81c:
	lea	$1c(sp),sp
	movem.l	(sp)+,d3/a2-a5
	rts
;----------------------------------------------------------------------------
t_826:
	movem.l	d3/a3/a4,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a4
	movea.l	a1,a3
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#$47,(sp)
	move.b	(a3),3(sp)
	move.b	1(a3),4(sp)
	move.b	2(a3),5(sp)
	move.b	3(a3),6(sp)
	move.b	4(a3),7(sp)
	move.b	5(a3),8(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a4,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	lea	10(sp),sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_88c:
	movem.l	d3/a2-a5,-(sp)
	lea	-$e(sp),sp
	movea.l	a0,a2
	move.l	a1,(sp)
	move	$d2(a2),d0
	bne	t_92c
	movea.l	$a2(a2),a3
	lea	4(a3),a4
	clr.w	$d2(a2)
	move.l	#$320,d1
	clr.w	d0
	lea	$d8(a2),a0
	bsr	t_32e6
	lea	4(sp),a5
	moveq	#10,d1
	clr.w	d0
	movea.l	a5,a0
	bsr	t_32e6
	move.b	#$43,(a5)
	move.b	#2,1(a5)
	move.b	#3,7(a5)
	move.b	#$24,8(a5)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#2,d2
	move.l	#$324,d1
	moveq	#10,d0
	movea.l	a5,a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	beq.s	t_90a
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	bra.s	t_93a
;----------------------------------------------------------------------------
t_90a:
	moveq	#0,d0
	move	(a3),d0
	movea.l	a4,a1
	lea	$d8(a2),a0
	bsr	t_30fc
	clr.w	d0
	move.b	2(a3),d0
	move	d0,$d0(a2)
	clr.w	d1
	move.b	3(a3),d1
	move	d1,$d2(a2)
t_92c:
	movea.l	(sp),a0
	move.b	$d1(a2),(a0)
	move.b	$d3(a2),1(a0)
	moveq	#0,d0
t_93a:
	lea	14(sp),sp
	movem.l	(sp)+,d3/a2-a5
	rts
;----------------------------------------------------------------------------
t_944:
	movem.l	d3/a2-a5,-(sp)
	subq	#2,sp
	movea.l	a0,a2
	movea.l	a1,a4
	lea	$d8(a2),a3
	move	$d2(a2),d0
	bne.s	t_968
	lea	(sp),a1
	movea.l	$7c(a2),a5
	jsr	(a5)
	tst.l	d0
	beq.s	t_968
	bra.s	t_9e0
;----------------------------------------------------------------------------
t_968:
	clr.w	d3
	bra.s	t_9d8
;----------------------------------------------------------------------------
t_96c:
	cmp.b	#-$5e,2(a3)
	bne.s	t_97a
	move.b	#-$56,2(a3)
t_97a:
	move.b	2(a3),d0
	cmp.b	(a4),d0
	bne.s	t_9d4
	clr.w	d0
	move.b	1(a3),d0
	asr.w	#4,d0
	andi.w	#$fff,2(a4)
	and	#15,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,2(a4)
	clr.w	d0
	move.b	1(a3),d0
	and	#15,d0
	andi.w	#-$f01,2(a4)
	and	#15,d0
	lsl.w	#8,d0
	or.w	d0,2(a4)
	move.l	4(a3),6(a4)
	cmp.b	#1,1(a4)
	bne.s	t_9d0
	lea	5(a3),a0
	bsr	t_22d4
	move.l	d0,6(a4)
t_9d0:
	moveq	#0,d0
	bra.s	t_9e0
;----------------------------------------------------------------------------
t_9d4:
	addq.w	#1,d3
	addq.w	#8,a3
t_9d8:
	cmp	#$64,d3
	blt	t_96c
	moveq	#-$21,d0
t_9e0:
	addq.w	#2,sp
	movem.l	(sp)+,d3/a2-a5
	rts
;----------------------------------------------------------------------------
t_9e8:
	movem.l	d3-d6/a2/a3/a5,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a2
	move	d0,d3
	move	d1,d6
	move	d2,d4
	move	$2a(sp),d5
	movea.l	a1,a5
	movea.l	$a2(a2),a3
	lea	(sp),a0
	clr.w	d0
	moveq	#10,d1
	bsr	t_32e6
	move.b	#$42,(sp)
	cmp	#2,d3
	bne.s	t_a1a
	moveq	#2,d0
	bra.s	t_a1c
;----------------------------------------------------------------------------
t_a1a:
	clr.b	d0
t_a1c:
	move.b	d0,1(sp)
	move.b	#$40,2(sp)
	move.b	d4,3(sp)
	move.b	d6,6(sp)
	move.b	d5,8(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	move	d5,d0
	ext.l	d0
	divs	#$10,d0
	swap	d0
	tst.w	d0
	beq.s	t_a4a
	moveq	#2,d2
	bra.s	t_a4c
;----------------------------------------------------------------------------
t_a4a:
	moveq	#1,d2
t_a4c:
	move	d5,d1
	ext.l	d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d6
	tst.w	d0
	beq.s	t_a6e
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	bra.s	t_a8c
;----------------------------------------------------------------------------
t_a6e:
	move	2(a3),d0
	moveq	#-4,d1
	add.w	d5,d1
	cmp	d1,d0
	beq.s	t_a7e
	moveq	#-1,d0
	bra.s	t_a8c
;----------------------------------------------------------------------------
t_a7e:
	move	d5,d0
	ext.l	d0
	movea.l	a3,a1
	movea.l	a5,a0
	bsr	t_30fc
	moveq	#0,d0
t_a8c:
	lea	10(sp),sp
	movem.l	(sp)+,d3-d6/a2/a3/a5
	rts
;----------------------------------------------------------------------------
t_a96:
	move.l	d3,-(sp)
	move.l	a2,-(sp)
	lea	-$10(sp),sp
	movea.l	a1,a2
	moveq	#$10,d0
	move	d0,-(sp)
	lea	2(sp),a1
	moveq	#1,d2
	clr.w	d1
	clr.w	d0
	move.b	(a2),d0
	bsr	t_9e8
	addq.w	#2,sp
	move.l	d0,d3
	move.b	1(sp),1(a2)
	lea	4(sp),a1
	lea	2(a2),a0
	moveq	#12,d0
	bsr	t_30fc
	move.l	d3,d0
	lea	$10(sp),sp
	movea.l	(sp)+,a2
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_ad8:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_adc:
	movem.l	d3/d4/a4,-(sp)
	lea	-$18(sp),sp
	movea.l	a1,a4
	moveq	#$18,d0
	move	d0,-(sp)
	lea	2(sp),a1
	moveq	#2,d2
	clr.w	d1
	clr.w	d0
	bsr	t_9e8
	addq.w	#2,sp
	move.l	d0,d3
	tst.l	d0
	bne.s	t_b0c
	move.b	#-$80,d1
	and.b	8(sp),d1
	bne.s	t_b0c
	moveq	#-1,d3
t_b0c:
	moveq	#$18,d1
	clr.w	d0
	movea.l	a4,a0
	bsr	t_32e6
	move.b	1(sp),(a4)
	moveq	#15,d0
	lea	9(sp),a1
	lea	1(a4),a0
	bsr	t_30fc
	moveq	#1,d0
	move	d0,d1
	clr.w	d2
	bra.s	t_b50
;----------------------------------------------------------------------------
t_b30:
	move.b	1(a4,d2.w),d4
	tst.b	d4
	beq.s	t_b46
	cmp.b	#$39,d4
	bhi.s	t_b44
	cmp.b	#$30,d4
	bcc.s	t_b46
t_b44:
	clr.w	d0
t_b46:
	cmp.b	#9,d4
	bls.s	t_b4e
	clr.w	d1
t_b4e:
	addq.w	#1,d2
t_b50:
	cmp	#13,d2
	blt	t_b30
	tst.w	d1
	beq.s	t_b70
	lea	1(a4),a0
	clr.w	d2
	bra.s	t_b68
;----------------------------------------------------------------------------
t_b62:
	addi.b	#$30,(a0)+
	addq.w	#1,d2
t_b68:
	cmp	#$17,d2
	blt	t_b62
	bra.s	t_b9e
;----------------------------------------------------------------------------
t_b70:
	tst.w	d0
	bne.s	t_b9e
	lea	9(sp),a0
	lea	1(a4),a1
	clr.w	d4
	bra.s	t_b98
;----------------------------------------------------------------------------
t_b80:
	clr.w	d0
	move.b	(a0),d0
	asr.w	#4,d0
	add.b	#$30,d0
	move.b	d0,(a1)+
	moveq	#15,d0
	and.b	(a0),d0
	add.b	#$30,d0
	move.b	d0,(a1)+
	addq.w	#1,d4
t_b98:
	cmp	#12,d4
	blt	t_b80
t_b9e:
	clr.b	14(a4)
	move.l	d3,d0
	lea	$18(sp),sp
	movem.l	(sp)+,d3/d4/a4
	rts
;----------------------------------------------------------------------------
t_bae:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_bb2:
	move.l	d3,-(sp)
	move.l	a3,-(sp)
	lea	-$18(sp),sp
	movea.l	a1,a3
	moveq	#$18,d0
	move	d0,-(sp)
	lea	2(sp),a1
	moveq	#3,d2
	clr.w	d1
	move.b	(a3),d1
	clr.w	d0
	bsr	t_9e8
	addq.w	#2,sp
	move.l	d0,d3
	tst.l	d0
	bne.s	t_be4
	move.b	#-$80,d1
	and.b	8(sp),d1
	bne.s	t_be4
	moveq	#-1,d3
t_be4:
	move.b	1(sp),1(a3)
	moveq	#15,d0
	lea	9(sp),a1
	lea	2(a3),a0
	bsr	t_30fc
	move.l	d3,d0
	lea	$18(sp),sp
	movea.l	(sp)+,a3
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_c04:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_c08:
	movem.l	d3/d4/a2-a5,-(sp)
	lea	-$16(sp),sp
	movea.l	a0,a2
	movea.l	a1,a5
	movea.l	$a2(a2),a3
	movea.l	$a2(a2),a4
	lea	$400(a4),a4
	cmp	#$10,10(a2)
	blt.s	t_c42
	moveq	#12,d1
	clr.w	d0
	lea	10(sp),a0
	bsr	t_32e6
	move.b	#$5a,10(sp)
	move.b	#-1,$12(sp)
	bra.s	t_c5a
;----------------------------------------------------------------------------
t_c42:
	moveq	#12,d1
	clr.w	d0
	lea	10(sp),a0
	bsr	t_32e6
	move.b	#$1a,10(sp)
	move.b	#-1,14(sp)
t_c5a:
	move	(a5),d0
	beq.s	t_cc8
	move.b	#$4e,12(sp)
	clr.l	-(sp)
	move.l	a4,-(sp)
	moveq	#3,d2
	move.l	#$ff,d1
	move	d2,-(sp)
	move.l	d1,-(sp)
	cmp	#$10,10(a2)
	blt.s	t_c80
	moveq	#12,d0
	bra.s	t_c82
;----------------------------------------------------------------------------
t_c80:
	moveq	#6,d0
t_c82:
	lea	$18(sp),a1
	movea.l	a2,a0
	move.l	(sp)+,d1
	move	(sp)+,d2
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne	t_de2
	move.b	(a4),d1
	beq.s	t_caa
	clr.w	d2
	move.b	3(a4),d2
	addq.w	#4,d2
	adda.w	d2,a4
	bra.s	t_cbe
;----------------------------------------------------------------------------
t_caa:
	clr.w	d0
	move.b	6(a4),d0
	lsl.w	#8,d0
	clr.w	d1
	move.b	7(a4),d1
	add.w	d1,d0
	addq.w	#8,d0
	adda.w	d0,a4
t_cbe:
	andi.b	#$3f,(a4)
	cmp.b	#14,(a4)
	bne.s	t_d36
t_cc8:
	move.b	#14,12(sp)
	clr.l	-(sp)
	move.l	a3,-(sp)
	moveq	#3,d2
	move.l	#$ff,d1
	move	d2,-(sp)
	move.l	d1,-(sp)
	cmp	#$10,10(a2)
	blt.s	t_cea
	moveq	#12,d0
	bra.s	t_cec
;----------------------------------------------------------------------------
t_cea:
	moveq	#6,d0
t_cec:
	lea	$18(sp),a1
	movea.l	a2,a0
	move.l	(sp)+,d1
	move	(sp)+,d2
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne	t_de2
	move.b	(a3),d1
	beq.s	t_d16
	moveq	#4,d4
	clr.w	d2
	move.b	3(a3),d2
	add.w	d4,d2
	adda.w	d2,a3
	bra.s	t_d2c
;----------------------------------------------------------------------------
t_d16:
	moveq	#8,d4
	clr.w	d0
	move.b	6(a3),d0
	lsl.w	#8,d0
	clr.w	d1
	move.b	7(a3),d1
	add.w	d1,d0
	add.w	d4,d0
	adda.w	d0,a3
t_d2c:
	andi.b	#$3f,(a3)
	cmp.b	#14,(a3)
	beq.s	t_d3c
t_d36:
	moveq	#-$20,d0
	bra	t_dfa
;----------------------------------------------------------------------------
t_d3c:
	moveq	#8,d0
	lea	8(a3),a1
	lea	2(sp),a0
	bsr	t_30fc
	move	(a5),d0
	beq	t_dee
	move.b	8(a4),d1
	beq.s	t_d5c
	move.b	2(a5),8(a3)
t_d5c:
	move.b	9(a4),d0
	beq.s	t_d68
	move.b	3(a5),9(a3)
t_d68:
	move.b	10(a4),d0
	beq.s	t_d74
	move.b	4(a5),10(a3)
t_d74:
	move.b	11(a4),d0
	beq.s	t_d80
	move.b	5(a5),11(a3)
t_d80:
	move.b	12(a4),d0
	beq.s	t_d8c
	move.b	6(a5),12(a3)
t_d8c:
	move.b	13(a4),d0
	beq.s	t_d98
	move.b	7(a5),13(a3)
t_d98:
	move.b	14(a4),d0
	beq.s	t_da4
	move.b	8(a5),14(a3)
t_da4:
	move.b	15(a4),d0
	beq.s	t_db0
	move.b	9(a5),15(a3)
t_db0:
	move	d4,d1
	ext.l	d1
	clr.w	d0
	movea.l	a3,a0
	move	d4,d2
	ext.l	d2
	suba.l	d2,a0
	bsr	t_32e6
	clr.w	d0
	move.b	1(a3),d0
	add.w	d4,d0
	addq.w	#2,d0
	movea.l	a3,a1
	move	d4,d1
	ext.l	d1
	suba.l	d1,a1
	lea	$3f8(a2),a0
	bsr	t_20b0
	move	d0,d3
	tst.w	d0
	beq.s	t_dee
t_de2:
	move	d3,d0
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	bra.s	t_dfa
;----------------------------------------------------------------------------
t_dee:
	lea	(sp),a0
	movea.l	a5,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	moveq	#0,d0
t_dfa:
	lea	$16(sp),sp
	movem.l	(sp)+,d3/d4/a2-a5
	rts
;----------------------------------------------------------------------------
t_e04:
	moveq	#-$20,d0
	rts
;----------------------------------------------------------------------------
t_e08:
	movem.l	a2-a5,-(sp)
	lea	-$e(sp),sp
	movea.l	a0,a3
	movea.l	a1,a4
	lea	4(sp),a2
	clr.w	(a2)
	movea.l	a2,a1
	movea.l	a3,a0
	movea.l	$90(a3),a5
	jsr	(a5)
	tst.l	d0
	beq.s	t_e2a
	bra.s	t_e66
;----------------------------------------------------------------------------
t_e2a:
	move.b	3(a2),(sp)
	move.b	5(a2),1(sp)
	move.b	7(a2),2(sp)
	move.b	9(a2),3(sp)
	move.b	(a4),3(a2)
	move.b	1(a4),5(a2)
	move.b	2(a4),7(a2)
	move.b	3(a4),9(a2)
	move.l	(sp),(a4)
	move	#1,(a2)
	movea.l	a2,a1
	movea.l	a3,a0
	movea.l	$90(a3),a4
	jsr	(a4)
t_e66:
	lea	14(sp),sp
	movem.l	(sp)+,a2-a5
	rts
;----------------------------------------------------------------------------
t_e70:
	movem.l	d3/a2-a5,-(sp)
	lea	-$1a(sp),sp
	movea.l	a0,a3
	movea.l	a1,a2
	move.l	#$200,d1
	clr.w	d0
	movea.l	a1,a0
	bsr	t_32e6
	lea	$18(sp),a1
	movea.l	a3,a0
	movea.l	$7c(a3),a4
	jsr	(a4)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_eea
	move.b	$18(sp),1(a2)
	move.b	$19(sp),2(a2)
	lea	14(sp),a4
	move.b	#-$56,(a4)
	move.b	#2,1(a4)
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$80(a3),a5
	jsr	(a5)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_eea
	lea	7(a4),a0
	moveq	#3,d0
	bsr	t_22a2
	move.l	6(a4),12(a2)
	move.b	#2,(sp)
	lea	(sp),a1
	movea.l	a3,a0
	movea.l	$84(a3),a4
	jsr	(a4)
	move.l	d0,d3
	tst.l	d0
	beq.s	t_eee
t_eea:
	move.l	d3,d0
	bra.s	t_f1c
;----------------------------------------------------------------------------
t_eee:
	move.b	4(sp),3(a2)
	moveq	#3,d0
	lea	11(sp),a0
	bsr	t_22a2
	move.l	10(sp),4(a2)
	moveq	#3,d0
	lea	7(sp),a0
	bsr	t_22a2
	move.l	6(sp),8(a2)
	move.b	5(sp),$10(a2)
	moveq	#0,d0
t_f1c:
	lea	$1a(sp),sp
	movem.l	(sp)+,d3/a2-a5
	rts
;----------------------------------------------------------------------------
t_f26:
	movem.l	d3-d5/a2,-(sp)
	movea.l	a0,a2
	move	d0,d4
	move	d1,d5
	clr.w	d3
	addq.w	#2,d0
	blt.s	t_fb8
	cmp	#-$2,d4
	beq.s	t_fac
	cmp	#-$1,d4
	beq.s	t_fb0
	tst.w	d4
	beq.s	t_fa0
	moveq	#8,d2
	and	d4,d2
	beq.s	t_f56
	moveq	#1,d0
	bsr	t_223a
t_f56:
	moveq	#-9,d0
	and	d4,d0
	bne.s	t_f60
	tst.w	d5
	bne.s	t_fa0
t_f60:
	movea.l	$a2(a2),a1
	lea	$3f8(a2),a0
	bsr	t_2010
	tst.w	d0
	bmi.s	t_fb0
	movea.l	$a2(a2),a0
	clr.w	d3
	move.b	2(a0),d3
	and	#15,d3
	move	d3,d0
	cmp	#7,d0
	bhi.s	t_fb8
	add.w	d0,d0
	move	t_f90(pc,d0.w),d0
	jmp	t_f90(pc,d0.w)
;----------------------------------------------------------------------------
t_f90:
	dc.w	t_fa0-t_f90,t_fa0-t_f90,t_fb0-t_f90,t_fa4-t_f90
	dc.w	t_fa8-t_f90,t_fac-t_f90,t_fb0-t_f90,t_fb4-t_f90
;----------------------------------------------------------------------------
t_fa0:
	moveq	#0,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fa4:
	moveq	#-4,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fa8:
	moveq	#-12,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fac:
	moveq	#-5,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fb0:
	moveq	#-2,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fb4:
	moveq	#-7,d0
	bra.s	t_fba
;----------------------------------------------------------------------------
t_fb8:
	moveq	#-1,d0
t_fba:
	movem.l	(sp)+,d3-d5/a2
	rts
;----------------------------------------------------------------------------
t_fc0:
	clr.w	d1
	bsr	t_f26
	rts
;----------------------------------------------------------------------------
t_fc8:
	movem.l	d3/d4/a3,-(sp)
	subq	#6,sp
	movea.l	a0,a3
	move	d0,d4
	move.l	d1,d3
	lea	(sp),a0
	clr.w	d0
	moveq	#6,d1
	bsr	t_32e6
	move.b	#$15,(sp)
	move.l	d3,$cc(a3)
	move.b	d4,4(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#6,d0
	lea	8(sp),a1
	lea	$3f8(a3),a0
	bsr	t_1f20
	addq.w	#8,sp
	move	d0,d4
	movea.l	a3,a0
	bsr	t_fc0
	addq.w	#6,sp
	movem.l	(sp)+,d3/d4/a3
	rts
;----------------------------------------------------------------------------
t_1012:
	move.l	d3,-(sp)
	move.l	a2,-(sp)
	movea.l	a0,a2
	move.l	d0,d3
	cmp.l	#$800,d0
	bne.s	t_1030
	move.l	#$800,d1
	moveq	#$41,d0
	bsr	t_fc8
	bra.s	t_104a
;----------------------------------------------------------------------------
t_1030:
	cmp.l	#$920,d3
	bne.s	t_1048
	move.l	#$920,d1
	moveq	#$65,d0
	movea.l	a2,a0
	bsr	t_fc8
	bra.s	t_104a
;----------------------------------------------------------------------------
t_1048:
	moveq	#-$20,d0
t_104a:
	movea.l	(sp)+,a2
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_1050:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#0,d3
	lea	$3f8(a2),a0
	bsr	t_1fda
	tst.w	d0
	bpl.s	t_106e
	move.l	#-$7f80,d0
	bra.s	t_10b0
;----------------------------------------------------------------------------
t_106e:
	moveq	#15,d3
	and	d0,d3
	ext.l	d3
	moveq	#6,d0
	and.l	d3,d0
	beq.s	t_1082
	or.l	#-$8000,d3
	bra.s	t_1092
;----------------------------------------------------------------------------
t_1082:
	moveq	#8,d0
	and.l	d3,d0
	beq.s	t_1092
	movea.l	a2,a0
	moveq	#1,d0
	bsr	t_223a
	moveq	#0,d3
t_1092:
	move	$12(a2),d0
	beq.s	t_109e
	or.l	#8,d3
t_109e:
	move.l	a3,d0
	beq.s	t_10ae
	moveq	#$20,d1
	movea.l	a3,a0
	clr.w	d0
	bsr	t_32e6
	move.l	d3,(a3)
t_10ae:
	move.l	d3,d0
t_10b0:
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_10b6:
	move	d3,-(sp)
	move.l	a2,-(sp)
	subq	#6,sp
	movea.l	a0,a2
	move	d0,d3
	moveq	#6,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#5,(sp)
	tst.w	d3
	beq.s	t_10d6
	moveq	#-$20,d0
	bra.s	t_10f6
;----------------------------------------------------------------------------
t_10d6:
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	moveq	#1,d1
	movea.l	a2,a0
	bsr	t_f26
t_10f6:
	addq.w	#6,sp
	movea.l	(sp)+,a2
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_10fe:
	movem.l	d3/a3/a4,-(sp)
	subq	#6,sp
	movea.l	a0,a4
	movea.l	a1,a3
	moveq	#6,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#6,(sp)
	move.b	(a3),3(sp)
	moveq	#1,d0
	add.b	2(a3),d0
	sub.b	3(sp),d0
	move.b	d0,4(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	lea	8(sp),a1
	movea.l	a4,a0
	moveq	#6,d0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	moveq	#1,d1
	movea.l	a4,a0
	bsr	t_f26
	addq.w	#6,sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_1150:
	movem.l	d3/a3/a4,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a4
	movea.l	a1,a3
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#$11,(sp)
	move.b	(a3),2(sp)
	move.b	1(a3),3(sp)
	move.b	2(a3),4(sp)
	move.b	3(a3),5(sp)
	move.b	4(a3),6(sp)
	move.b	5(a3),7(sp)
	moveq	#6,d0
	lea	2(sp),a0
	bsr	t_22a2
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a4,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	moveq	#1,d1
	movea.l	a4,a0
	bsr	t_f26
	lea	10(sp),sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_11c0:
	movem.l	d3/a2-a4/a6,-(sp)
	subq	#6,sp
	movea.l	a0,a2
	movea.l	a1,a6
	movea.l	$a2(a2),a3
	lea	$d8(a2),a4
	move	$d2(a2),d0
	bne	t_12c2
	moveq	#6,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#$19,(sp)
	move.b	#-$80,5(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#1,d2
	move.l	#$200,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	beq.s	t_121c
	moveq	#1,d1
	movea.l	a2,a0
	bsr	t_f26
	bra	t_12ce
;----------------------------------------------------------------------------
t_121c:
	move	#$63,$d0(a2)
	clr.w	$d2(a2)
	move.l	#$320,d1
	clr.w	d0
	lea	$d8(a2),a0
	bsr	t_32e6
	clr.w	d3
	bra.s	t_12ba
;----------------------------------------------------------------------------
t_123c:
	moveq	#4,d0
	move	d3,d1
	ext.l	d1
	lsl.l	#2,d1
	lea	0(a3,d1.l),a0
	bsr	t_2266
	move	d3,d0
	ext.l	d0
	lsl.l	#2,d0
	clr.w	d1
	move.b	0(a3,d0.l),d1
	move	d1,d0
	tst.w	d0
	ble.s	t_1264
	cmp	#$64,d0
	blt.s	t_126a
t_1264:
	cmp	#$66,d0
	bne.s	t_12b8
t_126a:
	cmp	#$64,d0
	bge.s	t_1284
	cmp	$d2(a2),d0
	ble.s	t_127a
	move	d0,$d2(a2)
t_127a:
	cmp	$d0(a2),d0
	bge.s	t_1284
	move	d0,$d0(a2)
t_1284:
	clr.b	d1
	move.b	d1,1(a4)
	move.b	d1,3(a4)
	move.b	d1,(a4)
	cmp	#$66,d0
	bne.s	t_129c
	move.b	#-$56,d2
	bra.s	t_129e
;----------------------------------------------------------------------------
t_129c:
	move.b	d0,d2
t_129e:
	move.b	d2,2(a4)
	move.l	#$ffffff,d0
	move	d3,d1
	ext.l	d1
	lsl.l	#2,d1
	and.l	0(a3,d1.l),d0
	move.l	d0,4(a4)
	addq.w	#8,a4
t_12b8:
	addq.w	#1,d3
t_12ba:
	cmp	#$80,d3
	blt	t_123c
t_12c2:
	move.b	$d1(a2),(a6)
	move.b	$d3(a2),1(a6)
	moveq	#0,d0
t_12ce:
	addq.w	#6,sp
	movem.l	(sp)+,d3/a2-a4/a6
	rts
;----------------------------------------------------------------------------
t_12d6:
	movem.l	d3/a2/a3,-(sp)
	subq	#6,sp
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#6,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#3,(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#1,d2
	moveq	#$10,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	beq.s	t_1318
	moveq	#1,d1
	movea.l	a2,a0
	bsr	t_f26
	bra	t_13b8
;----------------------------------------------------------------------------
t_1318:
	clr.b	1(a3)
	andi.w	#-$f1,2(a3)
	movea.l	$a2(a2),a0
	clr.w	d0
	move.b	$10(a0),d0
	asr.w	#4,d0
	andi.w	#-$10,2(a3)
	and	#15,d0
	or.w	d0,2(a3)
	moveq	#1,d0
	movea.l	$a2(a2),a0
	lea	$11(a0),a0
	bsr	t_2266
	movea.l	$a2(a2),a0
	move.b	$11(a0),4(a3)
	moveq	#1,d0
	movea.l	$a2(a2),a0
	lea	$12(a0),a0
	bsr	t_2266
	movea.l	$a2(a2),a0
	move.b	$12(a0),5(a3)
	moveq	#0,d0
	move.l	d0,10(a3)
	move.l	d0,6(a3)
	movea.l	$a2(a2),a0
	lea	$13(a0),a0
	moveq	#3,d0
	bsr	t_2266
	moveq	#3,d0
	movea.l	$a2(a2),a0
	lea	$17(a0),a0
	bsr	t_2266
	moveq	#3,d0
	movea.l	$a2(a2),a1
	lea	$17(a1),a1
	lea	7(a3),a0
	bsr	t_30fc
	moveq	#3,d0
	movea.l	$a2(a2),a1
	lea	$13(a1),a1
	lea	11(a3),a0
	bsr	t_30fc
	moveq	#0,d0
t_13b8:
	addq.w	#6,sp
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_13c0:
	movem.l	d3/a2/a3,-(sp)
	subq	#6,sp
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#6,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#3,(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#1,d2
	moveq	#$10,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	move.l	#$200,d1
	movea.l	a3,a0
	clr.w	d0
	bsr	t_32e6
	movea.l	$a2(a2),a0
	move.b	$10(a0),(a3)
	movea.l	$a2(a2),a0
	move.b	$1a(a0),1(a3)
	movea.l	$a2(a2),a0
	move.b	$1b(a0),2(a3)
	movea.l	$a2(a2),a0
	move.b	$11(a0),3(a3)
	clr.b	d0
	move.b	d0,12(a3)
	move.b	d0,8(a3)
	move.b	d0,4(a3)
	movea.l	$a2(a2),a0
	move.b	$13(a0),5(a3)
	movea.l	$a2(a2),a0
	move.b	$14(a0),6(a3)
	movea.l	$a2(a2),a0
	move.b	$15(a0),7(a3)
	movea.l	$a2(a2),a0
	move.b	$17(a0),9(a3)
	movea.l	$a2(a2),a0
	move.b	$18(a0),10(a3)
	movea.l	$a2(a2),a0
	move.b	$19(a0),11(a3)
	movea.l	$a2(a2),a0
	move.b	$1c(a0),13(a3)
	movea.l	$a2(a2),a0
	move.b	$1d(a0),14(a3)
	movea.l	$a2(a2),a0
	move.b	$1e(a0),15(a3)
	movea.l	$a2(a2),a0
	move.b	$12(a0),$10(a3)
	moveq	#1,d1
	move	d3,d0
	movea.l	a2,a0
	bsr	t_f26
	addq.w	#6,sp
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_14aa:
	movem.l	d3-d7/a2-a4,-(sp)
	lea	-$10(sp),sp
	movea.l	a0,a3
	movea.l	a1,a4
	move.l	d0,d3
	move.l	8(a4),d0
	move.l	d3,d1
	bsr	t_3442
	move.l	d0,d4
	movea.l	4(a4),a2
	move.l	(a4),12(sp)
	movea.l	a3,a0
	movea.l	$48(a3),a1
	move.l	#$920,d0
	jsr	(a1)
	move.l	d0,d6
	tst.l	d0
	beq	t_159e
	bra.s	t_153a
;----------------------------------------------------------------------------
t_14e4:
	move.l	d4,d0
	move.l	d3,d1
	bsr	t_33f8
	move.l	d0,d5
	move.l	d5,d0
	move.l	#$920,d1
	bsr	t_3442
	move.l	d0,d7
	move.l	a2,4(sp)
	tst.w	d7
	bne.s	t_150c
	move.l	$a2(a3),4(sp)
	moveq	#1,d7
t_150c:
	move.l	12(sp),(sp)
	move	d7,d1
	ext.l	d1
	move.l	d1,d0
	lsl.l	#3,d0
	add.l	d1,d0
	lsl.l	#3,d0
	add.l	d1,d0
	lsl.l	#5,d0
	move.l	d0,8(sp)
	lea	(sp),a1
	movea.l	a3,a0
	move.l	#$920,d0
	moveq	#3,d1
	bsr	t_3fe
	move.l	d0,d6
	tst.l	d0
	beq.s	t_154c
t_153a:
	move.l	#$800,d0
	movea.l	a3,a0
	movea.l	$48(a3),a1
	jsr	(a1)
	move.l	d6,d0
	bra.s	t_15b4
;----------------------------------------------------------------------------
t_154c:
	clr.w	d5
	bra.s	t_1584
;----------------------------------------------------------------------------
t_1550:
	move.l	d3,d0
	move	d5,d2
	ext.l	d2
	move.l	d2,d1
	lsl.l	#3,d1
	add.l	d2,d1
	lsl.l	#3,d1
	add.l	d2,d1
	lsl.l	#5,d1
	movea.l	4(sp),a1
	lea	8(a1,d1.l),a1
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	move.l	d2,d0
	move.l	d3,d1
	bsr	t_33f8
	lea	0(a2,d0.l),a0
	movea.l	(sp)+,a1
	move.l	(sp)+,d0
	bsr	t_30fc
	addq.w	#1,d5
t_1584:
	cmp	d5,d7
	bgt	t_1550
	move	d7,d0
	ext.l	d0
	move.l	d3,d1
	bsr	t_33f8
	adda.l	d0,a2
	move	d7,d1
	ext.l	d1
	sub.l	d1,d4
	add.l	d1,12(sp)
t_159e:
	tst.l	d4
	bne	t_14e4
	move.l	#$800,d0
	movea.l	a3,a0
	movea.l	$48(a3),a1
	jsr	(a1)
	moveq	#0,d0
t_15b4:
	lea	$10(sp),sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
;----------------------------------------------------------------------------
t_15be:
	movem.l	d3/a2/a3,-(sp)
	lea	-$c(sp),sp
	movea.l	a0,a2
	movea.l	$a2(a2),a3
	move.l	#$800,d1
	moveq	#$40,d0
	bsr	t_fc8
	move.l	d0,d3
	tst.l	d0
	bne.s	t_1614
	move.l	#$10,(sp)
	move.l	a3,4(sp)
	move.l	#$800,8(sp)
	moveq	#2,d1
	lea	(sp),a1
	movea.l	a2,a0
	move.l	#$800,d0
	bsr	t_3fe
	move.l	d0,d3
	move.l	#$800,d1
	movea.l	a2,a0
	moveq	#$41,d0
	bsr	t_fc8
	tst.l	d3
	beq.s	t_161e
t_1614:
	move	d3,d0
	movea.l	a2,a0
	bsr	t_fc0
	bra.s	t_163c
;----------------------------------------------------------------------------
t_161e:
	move.b	(a3),d0
	bne.s	t_1632
	cmp.b	#2,1(a3)
	bne.s	t_1632
	cmp.b	#$16,2(a3)
	beq.s	t_1636
t_1632:
	moveq	#-1,d0
	bra.s	t_163c
;----------------------------------------------------------------------------
t_1636:
	moveq	#0,d0
	move.b	3(a3),d0
t_163c:
	lea	12(sp),sp
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_1646:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	cmp	#2,$ca(a2)
	beq.s	t_1684
	moveq	#2,d1
	move.l	#$800,d0
	bsr	t_3fe
	move.l	d0,d3
	tst.l	d0
	beq.s	t_1694
	move	$ca(a2),d1
	bne.s	t_1694
	movea.l	a2,a0
	bsr	t_15be
	moveq	#2,d1
	cmp.l	d0,d1
	beq.s	t_167c
	moveq	#1,d0
t_167c:
	move	d0,$ca(a2)
	subq	#2,d0
	bne.s	t_1694
t_1684:
	move.l	#$800,d0
	movea.l	a3,a1
	movea.l	a2,a0
	bsr	t_14aa
	bra.s	t_1696
;----------------------------------------------------------------------------
t_1694:
	move.l	d3,d0
t_1696:
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_169c:
	move.l	#$914,d0
	bsr	t_14aa
	rts
;----------------------------------------------------------------------------
t_16a8:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	$a2(a2),a3
	clr.w	d1
	cmp.l	#$800,d0
	beq.s	t_16cc
	cmp.l	#$920,d0
	beq.s	t_16cc
	cmp.l	#$914,d0
	bne.s	t_16d2
t_16cc:
	move	#$83,d1
	bra.s	t_16e4
;----------------------------------------------------------------------------
t_16d2:
	cmp.l	#$930,d0
	bne.s	t_16e0
	move	#$82,d1
	bra.s	t_16e4
;----------------------------------------------------------------------------
t_16e0:
	moveq	#-$20,d0
	bra.s	t_1714
;----------------------------------------------------------------------------
t_16e4:
	move.l	#8,(a3)
	move	d1,d2
	ext.l	d2
	moveq	#$18,d3
	lsl.l	d3,d2
	move.l	d2,4(a3)
	move.l	d0,8(a3)
	clr.l	12(a3)
	moveq	#12,d0
	movea.l	a3,a1
	lea	$3f8(a2),a0
	bsr	t_20b0
	move	d0,d3
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
t_1714:
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_171a:
	movem.l	d3-d6/a2,-(sp)
	movea.l	a0,a2
	moveq	#3,d3
	bra.s	t_177c
;----------------------------------------------------------------------------
t_1724:
	move.l	#$800,d0
	movea.l	a2,a0
	bsr	t_16a8
	move.l	d0,d4
	tst.l	d0
	bne.s	t_1776
	moveq	#$14,d5
	bra.s	t_176e
;----------------------------------------------------------------------------
t_173a:
	lea	$3f8(a2),a0
	bsr	t_1fda
	move	d0,d6
	tst.w	d0
	beq.s	t_1760
	moveq	#$32,d0
	bsr	t_21f6
	move	d6,d0
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	move.l	d0,d4
	moveq	#-$12,d1
	cmp.l	d0,d1
	bne.s	t_1764
t_1760:
	moveq	#0,d0
	bra.s	t_1786
;----------------------------------------------------------------------------
t_1764:
	move.l	#$3e8,d0
	bsr	t_21f6
t_176e:
	move	d5,d0
	subq	#1,d5
	tst.w	d0
	bne	t_173a
t_1776:
	moveq	#$32,d0
	bsr	t_21f6
t_177c:
	move	d3,d0
	subq	#1,d3
	tst.w	d0
	bne	t_1724
	moveq	#-1,d0
t_1786:
	movem.l	(sp)+,d3-d6/a2
	rts
;----------------------------------------------------------------------------
t_178c:
	movem.l	d3/d4/a2/a3/a5,-(sp)
	lea	-$e(sp),sp
	movea.l	a0,a5
	movea.l	a1,a3
	moveq	#3,d3
	lea	4(sp),a2
	moveq	#10,d1
	clr.w	d0
	movea.l	a2,a0
	bsr	t_32e6
	move.b	#-$39,(a2)
	move.b	#3,1(a2)
	clr.l	(a3)
	moveq	#4,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	bra.s	t_182a
;----------------------------------------------------------------------------
t_17c0:
	clr.l	-(sp)
	move.l	$a2(a5),-(sp)
	moveq	#5,d2
	moveq	#4,d1
	moveq	#10,d0
	movea.l	a2,a1
	movea.l	a5,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d4
	movea.l	$a2(a5),a1
	lea	(sp),a0
	moveq	#4,d0
	bsr	t_30fc
	tst.w	d4
	bne.s	t_1818
	cmp.b	#$20,(sp)
	bne.s	t_1818
	move.b	1(sp),d0
	bne.s	t_1800
	move.b	2(sp),d1
	bne.s	t_1800
	move.b	3(sp),d2
	beq.s	t_1818
t_1800:
	moveq	#3,d0
	lea	1(sp),a0
	bsr	t_2266
	lea	1(sp),a0
	bsr	t_22d4
	move.l	d0,(a3)
	moveq	#0,d0
	bra.s	t_1834
;----------------------------------------------------------------------------
t_1818:
	movea.l	$a2(a5),a1
	lea	$3f8(a5),a0
	bsr	t_2010
	moveq	#$32,d0
	bsr	t_21f6
t_182a:
	move	d3,d0
	subq	#1,d3
	tst.w	d0
	bne	t_17c0
	moveq	#-1,d0
t_1834:
	lea	14(sp),sp
	movem.l	(sp)+,d3/d4/a2/a3/a5
	rts
;----------------------------------------------------------------------------
t_183e:
	movem.l	d3/a2/a3,-(sp)
	movea.l	a0,a2
	movea.l	a1,a3
	move.l	#$930,d0
	movea.l	$48(a2),a1
	jsr	(a1)
	move.l	d0,d3
	tst.l	d0
	bne.s	t_1878
	moveq	#1,d1
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	#$930,d0
	bsr	t_3fe
	move.l	d0,d3
	movea.l	a2,a0
	movea.l	$48(a2),a1
	move.l	#$800,d0
	jsr	(a1)
t_1878:
	move.l	d3,d0
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_1880:
	movem.l	d3/d4/a2-a5,-(sp)
	lea	-$12(sp),sp
	movea.l	a0,a2
	move.l	a1,(sp)
	move	$d2(a2),d0
	bne	t_19ba
	lea	$d8(a2),a3
	move.l	#$320,d1
	movea.l	a3,a0
	clr.w	d0
	bsr	t_32e6
	lea	4(sp),a4
	moveq	#10,d1
	clr.w	d0
	movea.l	a4,a0
	bsr	t_32e6
	move.b	#-$3f,(a4)
	move.b	#4,8(a4)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#4,d2
	moveq	#4,d1
	moveq	#10,d0
	movea.l	a4,a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne	t_1990
	movea.l	$a2(a2),a0
	moveq	#2,d0
	bsr	t_2266
	movea.l	$a2(a2),a0
	clr.w	d0
	move.b	(a0),d0
	move	d0,$d0(a2)
	movea.l	$a2(a2),a0
	clr.w	d1
	move.b	1(a0),d1
	move	d1,$d2(a2)
	move	$d0(a2),d4
	bra.s	t_195e
;----------------------------------------------------------------------------
t_1906:
	movea.l	$a2(a2),a5
	move.b	d4,5(a4)
	moveq	#1,d0
	lea	5(a4),a0
	bsr	t_22a2
	move.b	#-$80,9(a4)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#4,d2
	moveq	#4,d1
	moveq	#10,d0
	movea.l	a4,a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne.s	t_1990
	move.b	d4,2(a3)
	move.b	(a5),1(a3)
	lea	1(a5),a0
	moveq	#3,d0
	bsr	t_2266
	moveq	#3,d0
	lea	1(a5),a1
	lea	5(a3),a0
	bsr	t_30fc
	addq.w	#8,a3
	addq.w	#1,d4
t_195e:
	cmp	$d2(a2),d4
	ble	t_1906
	move.l	$a2(a2),14(sp)
	clr.b	5(a4)
	move.b	#$40,9(a4)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#4,d2
	moveq	#4,d1
	moveq	#10,d0
	movea.l	a4,a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	beq.s	t_199c
t_1990:
	move	d3,d0
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	bra.s	t_19c8
;----------------------------------------------------------------------------
t_199c:
	move.b	#-$56,2(a3)
	moveq	#3,d0
	movea.l	14(sp),a0
	bsr	t_2266
	moveq	#3,d0
	movea.l	14(sp),a1
	lea	5(a3),a0
	bsr	t_30fc
t_19ba:
	movea.l	(sp),a0
	move.b	$d1(a2),(a0)
	move.b	$d3(a2),1(a0)
	moveq	#0,d0
t_19c8:
	lea	$12(sp),sp
	movem.l	(sp)+,d3/d4/a2-a5
	rts
;----------------------------------------------------------------------------
t_19d2:
	movem.l	d3/d4/a2-a5,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a2
	movea.l	a1,a5
	movea.l	$a2(a2),a3
	movea.l	$a2(a2),a4
	clr.w	d3
	moveq	#14,d1
	move	d3,d0
	movea.l	a1,a0
	bsr	t_32e6
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#-$34,(sp)
	move.b	#6,8(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#3,d2
	moveq	#6,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d4
	tst.w	d0
	bne.s	t_1aa2
	clr.w	d1
	move.b	(a3),d1
	cmp	#5,d1
	bhi.s	t_1a6e
	add.w	d1,d1
	move	t_1a3a(pc,d1.w),d1
	jmp	t_1a3a(pc,d1.w)
;----------------------------------------------------------------------------
t_1a3a:
	dc.w	t_1a46-t_1a3a,t_1a4e-t_1a3a,t_1a46-t_1a3a,t_1a56-t_1a3a
	dc.w	t_1a5e-t_1a3a,t_1a66-t_1a3a
;----------------------------------------------------------------------------
t_1a46:
	move.b	#$11,1(a5)
	bra.s	t_1a6e
;----------------------------------------------------------------------------
t_1a4e:
	move.b	#$12,1(a5)
	bra.s	t_1a6e
;----------------------------------------------------------------------------
t_1a56:
	move.b	#$13,1(a5)
	bra.s	t_1a6c
;----------------------------------------------------------------------------
t_1a5e:
	move.b	#$14,1(a5)
	bra.s	t_1a6c
;----------------------------------------------------------------------------
t_1a66:
	move.b	#$15,1(a5)
t_1a6c:
	moveq	#1,d3
t_1a6e:
	tst.w	d3
	beq.s	t_1aa2
	moveq	#3,d0
	lea	2(a3),a0
	bsr	t_2266
	moveq	#3,d0
	lea	2(a3),a1
	lea	7(a5),a0
	bsr	t_30fc
	cmp.b	#1,(a5)
	bne	t_1b2e
	lea	2(a3),a0
	bsr	t_22d4
	move.l	d0,6(a5)
	bra	t_1b2e
;----------------------------------------------------------------------------
t_1aa2:
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#-$3e,(sp)
	move.b	#9,8(sp)
	clr.l	-(sp)
	move.l	$a2(a2),-(sp)
	moveq	#2,d2
	moveq	#9,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d4
	tst.w	d0
	beq.s	t_1ade
	movea.l	a2,a0
	movea.l	$3c(a2),a1
	jsr	(a1)
	bra.s	t_1b30
;----------------------------------------------------------------------------
t_1ade:
	moveq	#8,d0
	lea	1(a4),a0
	bsr	t_2266
	move.b	1(a4),4(a5)
	move.b	2(a4),5(a5)
	moveq	#3,d0
	lea	3(a4),a1
	lea	11(a5),a0
	bsr	t_30fc
	moveq	#3,d0
	lea	6(a4),a1
	lea	7(a5),a0
	bsr	t_30fc
	cmp.b	#1,(a5)
	bne.s	t_1b2e
	lea	3(a4),a0
	bsr	t_22d4
	move.l	d0,10(a5)
	lea	6(a4),a0
	bsr	t_22d4
	move.l	d0,6(a5)
t_1b2e:
	moveq	#0,d0
t_1b30:
	lea	10(sp),sp
	movem.l	(sp)+,d3/d4/a2-a5
	rts
;----------------------------------------------------------------------------
t_1b3a:
	movem.l	d3/a3/a4,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a4
	movea.l	a1,a3
	moveq	#10,d1
	clr.w	d0
	lea	(sp),a0
	bsr	t_32e6
	move.b	#-$38,(sp)
	move.b	#$19,1(sp)
	moveq	#3,d0
	movea.l	a3,a1
	lea	3(sp),a0
	bsr	t_30fc
	moveq	#3,d0
	lea	3(sp),a0
	bsr	t_22a2
	move.b	#$40,9(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a4,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	tst.w	d0
	bne.s	t_1bc6
	move.b	#-$37,(sp)
	lea	3(a3),a1
	lea	3(sp),a0
	moveq	#3,d0
	bsr	t_30fc
	moveq	#3,d0
	lea	3(sp),a0
	bsr	t_22a2
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	moveq	#10,d0
	lea	8(sp),a1
	movea.l	a4,a0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
t_1bc6:
	move	d3,d0
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	lea	10(sp),sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_1bda:
	movem.l	d3/a2-a5,-(sp)
	lea	-$10(sp),sp
	movea.l	a0,a4
	movea.l	a1,a2
	move.b	(a1),(sp)
	move.b	#1,1(sp)
	lea	(sp),a1
	movea.l	$80(a4),a3
	jsr	(a3)
	move.l	d0,d3
	lea	10(sp),a5
	tst.l	d3
	bne.s	t_1c44
	movea.l	a5,a0
	move.l	6(sp),d0
	bsr	t_231a
	moveq	#1,d0
	add.b	2(a2),d0
	move.b	d0,(sp)
	move.b	#1,1(sp)
	lea	(sp),a1
	movea.l	a4,a0
	movea.l	$80(a4),a2
	jsr	(a2)
	move.l	d0,d3
	moveq	#-$21,d1
	cmp.l	d0,d1
	bne.s	t_1c40
	move.b	#-$56,(sp)
	move.b	#1,1(sp)
	lea	(sp),a1
	movea.l	a4,a0
	movea.l	$80(a4),a2
	jsr	(a2)
	move.l	d0,d3
t_1c40:
	tst.l	d3
	beq.s	t_1c48
t_1c44:
	move.l	d3,d0
	bra.s	t_1c5e
;----------------------------------------------------------------------------
t_1c48:
	lea	3(a5),a0
	moveq	#-1,d0
	add.l	6(sp),d0
	bsr	t_231a
	movea.l	a5,a1
	movea.l	a4,a0
	bsr	t_1b3a
t_1c5e:
	lea	$10(sp),sp
	movem.l	(sp)+,d3/a2-a5
	rts
;----------------------------------------------------------------------------
t_1c68:
	move	d3,-(sp)
	move.l	a3,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a3
	move	d0,d3
	moveq	#10,d1
	lea	(sp),a0
	clr.w	d0
	bsr	t_32e6
	move.b	#-$36,(sp)
	tst.w	d3
	beq.s	t_1c8a
	clr.b	d0
	bra.s	t_1c8c
;----------------------------------------------------------------------------
t_1c8a:
	moveq	#$10,d0
t_1c8c:
	move.b	d0,1(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	moveq	#0,d1
	lea	8(sp),a1
	movea.l	a3,a0
	moveq	#10,d0
	bsr	t_1fc0
	addq.w	#8,sp
	move	d0,d3
	movea.l	a3,a0
	movea.l	$3c(a3),a1
	jsr	(a1)
	lea	10(sp),sp
	movea.l	(sp)+,a3
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_1cba:
	movem.l	d3/d4/a3/a4,-(sp)
	lea	-$c(sp),sp
	movea.l	a0,a4
	move.l	d0,d3
	move.l	d1,d4
	movea.l	a1,a3
	lea	(sp),a0
	clr.w	d0
	moveq	#12,d1
	bsr	t_32e6
	move.b	#-$28,(sp)
	move.l	d3,2(sp)
	move.l	d4,d0
	move.l	#$930,d1
	bsr	t_3442
	move.l	d0,6(sp)
	clr.l	-(sp)
	move.l	a3,-(sp)
	moveq	#3,d2
	move.l	d4,d1
	lea	8(sp),a1
	movea.l	a4,a0
	moveq	#12,d0
	bsr	t_1fc0
	addq.w	#8,sp
	lea	12(sp),sp
	movem.l	(sp)+,d3/d4/a3/a4
	rts
;----------------------------------------------------------------------------
t_1d0c:
	movem.l	d3-d7/a2-a4,-(sp)
	subq	#8,sp
	movea.l	a0,a4
	movea.l	a1,a3
	movea.l	4(a3),a2
	move.l	(a1),d3
	move.l	8(a3),d0
	move.l	#$930,d1
	bsr	t_3442
	move.l	d0,d4
	movea.l	a2,a3
	move.l	#$1b,2(sp)
	clr.w	(sp)
	clr.w	d0
	movea.l	a4,a0
	bsr	t_223a
	move.l	#$930,d2
	move.l	d4,d1
	move.l	a2,d0
	bsr	t_2208
	tst.w	d0
	bne	t_1de4
	movea.l	$a2(a4),a3
	move.l	$a6(a4),d0
	move.l	#$930,d1
	bsr	t_3442
	move.l	d0,2(sp)
	move	#1,(sp)
	bra.s	t_1de4
;----------------------------------------------------------------------------
t_1d72:
	move	#3,6(sp)
	move.l	d4,d6
	moveq	#-2,d7
	cmp.l	2(sp),d6
	ble.s	t_1d86
	move.l	2(sp),d6
t_1d86:
	move.l	d6,d5
	lsl.l	#3,d5
	add.l	d6,d5
	lsl.l	#3,d5
	add.l	d6,d5
	add.l	d5,d5
	add.l	d6,d5
	lsl.l	#4,d5
	bra.s	t_1da6
;----------------------------------------------------------------------------
t_1d98:
	movea.l	a3,a1
	move.l	d5,d1
	move.l	d3,d0
	movea.l	a4,a0
	bsr	t_1cba
	move	d0,d7
t_1da6:
	move	6(sp),d0
	subq	#1,6(sp)
	tst.w	d0
	beq.s	t_1db6
	tst.w	d7
	bne	t_1d98
t_1db6:
	tst.w	d7
	beq.s	t_1dc6
	move	d7,d0
	movea.l	a4,a0
	movea.l	$3c(a4),a1
	jsr	(a1)
	bra.s	t_1dec
;----------------------------------------------------------------------------
t_1dc6:
	move	(sp),d0
	beq.s	t_1dd8
	movea.l	a3,a1
	movea.l	a2,a0
	move.l	d5,d0
	bsr	t_30fc
	adda.l	d5,a2
	bra.s	t_1dda
;----------------------------------------------------------------------------
t_1dd8:
	adda.l	d5,a3
t_1dda:
	sub.l	d6,d4
	add.l	d6,d3
	moveq	#$32,d0
	bsr	t_21f6
t_1de4:
	tst.l	d4
	bne	t_1d72
	moveq	#0,d0
t_1dec:
	addq.w	#8,sp
	movem.l	(sp)+,d3-d7/a2-a4
	rts
;----------------------------------------------------------------------------
t_1df4:
	move.l	a2,-(sp)
	move.l	a3,-(sp)
	lea	scsidrv_p,a2
	movea.l	a2,a0
	move.l	#'SCSI',d0
	bsr	t_354e
	tst.w	d0
	bne	t_1eaa
	move	d_377a,d0
	bne	t_1eaa
	move	#1,d_377a
	lea	scsidrv_fname_s_arr,a3
	clr.l	-(sp)				;push NULL
	lea	scsidrv_fname_slen(a3),a1	;a1 -> NUL
	movea.l	a3,a0				;a0 -> 1'st scsidrv fname
	clr.w	d0
	bsr	Pexec_fun
	addq.w	#4,sp
	movea.l	a2,a0
	move.l	#'SCSI',d0
	bsr	t_354e
	tst.w	d0
	bne.s	t_1e5a
	clr.l	-(sp)				;push NULL
	lea	scsidrv_fname_slen(a3),a1	;a1 -> NUL
	lea	(scsidrv_fname_slen+1)(a3),a0	;a0 -> 2'nd scsidrv fname
	clr.w	d0
	bsr	Pexec_fun
	addq.w	#4,sp
t_1e5a:
	movea.l	a2,a0
	move.l	#'SCSI',d0
	bsr	t_354e
	tst.w	d0
	bne.s	t_1e7c
	clr.l	-(sp)				;push NULL
	lea	scsidrv_fname_slen(a3),a1	;a1 -> NUL
	lea	(scsidrv_fname_slen+1)*2(a3),a0	;a0 -> 3'rd scsidrv fname
	clr.w	d0
	bsr	Pexec_fun
	addq.w	#4,sp
t_1e7c:
	movea.l	a2,a0
	move.l	#'SCSI',d0
	bsr	t_354e
	tst.w	d0
	bne.s	t_1e9e
	clr.l	-(sp)				;push NULL
	lea	scsidrv_fname_slen(a3),a1	;a1 -> NUL
	lea	(scsidrv_fname_slen+1)*3(a3),a0	;a0 -> 4'th scsidrv fname
	clr.w	d0
	bsr	Pexec_fun
	addq.w	#4,sp
t_1e9e:
	movea.l	a2,a0
	move.l	#'SCSI',d0
	bsr	t_354e
t_1eaa:
	movea.l	(sp)+,a3
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_1eb0:
	movem.l	d3/d4/a2,-(sp)
	lea	-$c(sp),sp
	move	d0,d3
	move	d1,d4
	movea.l	a0,a2
	bsr	t_1df4
	move.l	scsidrv_p,d0
	bne.s	t_1ed8
	lea	d_37fa,a0
	bsr	Bconws_fun
	clr.w	d0
	bra.s	t_1f16
;----------------------------------------------------------------------------
t_1ed8:
	clr.l	4(sp)
	moveq	#7,d0
	and	d3,d0
	moveq	#0,d1
	move	d0,d1
	move.l	d1,8(sp)
	pea	(sp)
	pea	8(sp)
	move	d3,d2
	lsr.w	#3,d2
	move	d2,-(sp)
	movea.l	scsidrv_p,a0
	movea.l	$1a(a0),a0
	jsr	(a0)
	lea	10(sp),sp
	move.l	d0,(a2)
	move	d4,4(a2)
	tst.l	d0
	bmi.s	t_1f12
	moveq	#1,d1
	bra.s	t_1f14
;----------------------------------------------------------------------------
t_1f12:
	clr.w	d1
t_1f14:
	move	d1,d0
t_1f16:
	lea	12(sp),sp
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
;a1 -> char	temp_buf[6]
;
t_1f20:
	move.l	a2,-(sp)
	move.l	a3,-(sp)
	lea	-$1c(sp),sp
	movea.l	a0,a2
	movea.l	$28(sp),a3
	andi.b	#$1f,1(a1)	;clr 3 top bits of temp_buf[1]
	move.b	5(a2),d2	;d2 = code
	lsl.b	#5,d2		;d2 = code << 5
	or.b	d2,1(a1)	;set code bits as top 3 of temp_buf[1]
	clr.w	b_3a1c
	move.l	(a0),(sp)
	move.l	a1,4(sp)
	move	d0,8(sp)
	move.l	a3,d2
	beq.s	t_1f56
	movea.l	a3,a1
	bra.s	t_1f5a
;
t_1f56:
	movea.l	$2c(sp),a1
t_1f5a:
	move.l	a1,10(sp)
	move.l	d1,14(sp)
	move.l	#b_3a06,$12(sp)
	move.l	#$c80,$16(sp)
	clr.w	$1a(sp)
	move.l	a3,d0
	beq.s	t_1f8e
	pea	(sp)
	movea.l	scsidrv_p,a0
	movea.l	2(a0),a0
	jsr	(a0)
	addq.w	#4,sp
	move.l	d0,d1
	bra.s	t_1fa0
;----------------------------------------------------------------------------
t_1f8e:
	pea	(sp)
	movea.l	scsidrv_p,a0
	movea.l	6(a0),a0
	jsr	(a0)
	addq.w	#4,sp
	move.l	d0,d1
t_1fa0:
	moveq	#2,d0
	cmp.l	d1,d0
	bne.s	t_1fb4
	move	#1,b_3a1c
	move.l	(a2),b_3a18
t_1fb4:
	move	d1,d0
	lea	$1c(sp),sp
	movea.l	(sp)+,a3
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_1fc0:
	move.l	a3,-(sp)
	movea.l	a0,a3
	move.l	12(sp),-(sp)
	move.l	12(sp),-(sp)
	lea	$3f8(a3),a0
	bsr	t_1f20
	addq.w	#8,sp
	movea.l	(sp)+,a3
	rts
;----------------------------------------------------------------------------
t_1fda:
	move.l	a2,-(sp)	;protect entry a2
	subq	#6,sp		;reserve temporary buffer
	movea.l	a0,a2		;a2 = a0 -> command  (?)
	lea	d_377c,a1	;a1 -> 6 NUL bytes
	lea	(sp),a0		;a0 -> temp buffer
	move.b	(a1)+,(a0)+	;\
	move.b	(a1)+,(a0)+	; \
	move.b	(a1)+,(a0)+	;  \/ Preclear
	move.b	(a1)+,(a0)+	;  /\ temp buffer
	move.b	(a1)+,(a0)+	; /
	move.b	(a1)+,(a0)+	;/
	clr.l	-(sp)		;push NULL pointer
	clr.l	-(sp)		;push NULL pointer
	moveq	#1,d2
	moveq	#0,d1
	moveq	#6,d0		;d0 =  sizeof temp buffer
	lea	8(sp),a1	;a1 -> temp buffer
	movea.l	a2,a0		;a0 = a2 -> command  (?)
	bsr	t_1f20
	addq.w	#8,sp		;clean stack after call
	addq.w	#6,sp		;release temp buffer
	movea.l	(sp)+,a2	;restore entry a2
	rts			;return to caller
;----------------------------------------------------------------------------
t_2010:
	move.l	a2,-(sp)
	move.l	a3,-(sp)
	subq	#6,sp
	movea.l	a0,a2
	movea.l	a1,a3
	lea	d_3782,a1
	lea	(sp),a0
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	move.l	(a2),d0
	cmp.l	b_3a18,d0
	bne.s	t_2052
	move	b_3a1c,d1
	beq.s	t_2052
	lea	b_3a06,a1
	movea.l	a3,a0
	moveq	#$12,d0
	bsr	t_30fc
	clr.w	d0
	bra.s	t_2068
;----------------------------------------------------------------------------
t_2052:
	clr.l	-(sp)
	move.l	a3,-(sp)
	moveq	#1,d2
	moveq	#$20,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a2,a0
	bsr	t_1f20
	addq.w	#8,sp
t_2068:
	addq.w	#6,sp
	movea.l	(sp)+,a3
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_2070:
	move.l	a2,-(sp)
	move.l	a3,-(sp)
	subq	#6,sp
	movea.l	a0,a3
	movea.l	a1,a2
	lea	d_3788,a0
	lea	(sp),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	clr.l	-(sp)
	move.l	a2,-(sp)
	moveq	#3,d2
	move.l	#$ff,d1
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a3,a0
	bsr	t_1f20
	addq.w	#8,sp
	addq.w	#6,sp
	movea.l	(sp)+,a3
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_20b0:
	movem.l	d3/a2/a3,-(sp)
	subq	#6,sp
	movea.l	a0,a3
	movea.l	a1,a2
	move	d0,d3
	lea	d_379b,a0
	lea	(sp),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	d3,4(sp)
	move.l	a2,-(sp)
	clr.l	-(sp)
	moveq	#1,d2
	move	d3,d1
	ext.l	d1
	lea	8(sp),a1
	movea.l	a3,a0
	moveq	#6,d0
	bsr	t_1f20
	addq.w	#8,sp
	addq.w	#6,sp
	movem.l	(sp)+,d3/a2/a3
	rts
;----------------------------------------------------------------------------
t_20f4:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	subq	#6,sp
	movea.l	a0,a4
	movea.l	a1,a3
	lea	d_37a1,a0
	lea	(sp),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.l	d0,(sp)
	move.b	#8,(sp)
	move.b	d1,4(sp)
	clr.l	-(sp)
	move.l	a3,-(sp)
	moveq	#6,d0
	lea	8(sp),a1
	movea.l	a4,a0
	move.l	d2,d1
	moveq	#1,d2
	bsr	t_1f20
	addq.w	#8,sp
	addq.w	#6,sp
	movea.l	(sp)+,a4
	movea.l	(sp)+,a3
	rts
;----------------------------------------------------------------------------
t_213a:
	movem.l	d3/a3/a4,-(sp)
	lea	-$a(sp),sp
	movea.l	a0,a4
	move.l	d2,d3
	movea.l	a1,a3
	lea	d_37a7,a0
	lea	(sp),a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.l	d0,d2
	add.l	#$96,d2
	move.l	d2,2(sp)
	move.l	d1,d0
	asr.l	#8,d0
	move.b	d0,7(sp)
	move.b	d1,d2
	and.b	#-1,d2
	move.b	d2,8(sp)
	clr.l	-(sp)
	move.l	a3,-(sp)
	move.l	d3,d1
	lea	8(sp),a1
	movea.l	a4,a0
	moveq	#10,d0
	moveq	#1,d2
	bsr	t_1f20
	addq.w	#8,sp
	lea	10(sp),sp
	movem.l	(sp)+,d3/a3/a4
	rts
;----------------------------------------------------------------------------
t_21a2:
	subq	#4,sp
	lea	(sp),a0
	move.l	#'HDJR',d0
	bsr	t_354e
	tst.w	d0
	beq.s	t_21c0
	subi.l	#$20,(sp)
	move.l	(sp),d_3816
t_21c0:
	addq.w	#4,sp
	rts
;----------------------------------------------------------------------------
t_21c4:
	movem.l	d3/d4/a2,-(sp)
	move	d0,d3
	move	d1,d4
	lea	d_3816,a2
	move	4(a2),d0
	beq.s	t_21e0
	clr.w	4(a2)
	bsr	t_21a2
t_21e0:
	move.l	(a2),d0
	beq.s	t_21f0
	movea.l	d0,a0
	move.b	d3,$43(a0)
	movea.l	(a2),a0
	move.b	d4,$42(a0)
t_21f0:
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
t_21f6:
	moveq	#5,d1
	bsr	t_3442
	add.l	(_hz_200).w,d0
t_2200:
	cmp.l	(_hz_200).w,d0
	bhi	t_2200
	rts
;----------------------------------------------------------------------------
t_2208:
	movem.l	d3-d5,-(sp)
	move.l	d0,d3
	move.l	d1,d4
	move.l	d2,d5
	and.l	#-$ffffff,d0
	beq.s	t_221e
	clr.w	d0
	bra.s	t_2234
;----------------------------------------------------------------------------
t_221e:
	move.l	d5,d0
	move.l	d4,d1
	bsr	t_33f8
	add.l	d3,d0
	cmp.l	(phystop).w,d0
	bcc.s	t_2232
	moveq	#1,d0
	bra.s	t_2234
;----------------------------------------------------------------------------
t_2232:
	clr.w	d0
t_2234:
	movem.l	(sp)+,d3-d5
	rts
;----------------------------------------------------------------------------
t_223a:
	move.l	a2,-(sp)
	movea.l	a0,a2
	move	d0,$12(a2)
	tst.w	d0
	beq.s	t_2262
	clr.w	d0
	move	d0,$d2(a2)
	move	d0,$ca(a2)
	moveq	#4,d1
	and	$a0(a2),d1
	beq.s	t_2262
	move	10(a2),d0
	clr.w	d1
	bsr	t_305e
t_2262:
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_2266:
	move	d3,-(sp)
	move.l	d4,-(sp)
	clr.w	d1
	bra.s	t_2298
;----------------------------------------------------------------------------
t_226e:
	clr.w	d2
	move.b	0(a0,d1.w),d2
	move	d2,d3
	move	d2,d4
	ext.l	d4
	divs	#$10,d4
	move	d4,d2
	move	d2,d4
	lsl.w	#2,d4
	add.w	d2,d4
	add.w	d4,d4
	move	d4,d2
	and	#15,d3
	move.b	d2,d4
	add.b	d3,d4
	move.b	d4,0(a0,d1.w)
	addq.w	#1,d1
t_2298:
	cmp	d1,d0
	bgt	t_226e
	move.l	(sp)+,d4
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_22a2:
	move.l	d3,-(sp)
	clr.w	d1
	bra.s	t_22cc
;----------------------------------------------------------------------------
t_22a8:
	clr.w	d2
	move.b	0(a0,d1.w),d2
	move	d2,d3
	ext.l	d3
	divs	#10,d3
	lsl.b	#4,d3
	move.b	d3,0(a0,d1.w)
	move	d2,d3
	ext.l	d3
	divs	#10,d3
	swap	d3
	add.b	d3,0(a0,d1.w)
	addq.w	#1,d1
t_22cc:
	cmp	d1,d0
	bgt	t_22a8
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_22d4:
	move.l	d3,-(sp)
	move.l	a2,-(sp)
	movea.l	a0,a2
	moveq	#0,d3
	clr.w	d1
	move.b	(a0),d1
	ext.l	d1
	move.l	d1,d0
	lsl.l	#4,d0
	sub.l	d1,d0
	lsl.l	#2,d0
	clr.w	d2
	move.b	1(a2),d2
	ext.l	d2
	add.l	d2,d0
	move.l	d0,d3
	lsl.l	#3,d3
	add.l	d0,d3
	lsl.l	#2,d3
	add.l	d0,d3
	add.l	d3,d3
	add.l	d0,d3
	clr.w	d0
	move.b	2(a2),d0
	ext.l	d0
	add.l	d0,d3
	move.l	d3,d0
	add.l	#-$96,d0
	movea.l	(sp)+,a2
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_231a:
	movem.l	d3-d5/a2,-(sp)
	move.l	d0,d3
	movea.l	a0,a2
	move.l	#$1194,d1
	bsr	t_33a6
	move.l	d0,d4
	move	d4,d1
	ext.l	d1
	move.l	d1,d0
	lsl.l	#4,d0
	add.l	d1,d0
	add.l	d0,d0
	add.l	d1,d0
	lsl.l	#3,d0
	add.l	d1,d0
	lsl.l	#2,d0
	add.l	d1,d0
	lsl.l	#2,d0
	sub.l	d0,d3
	move.l	d3,d0
	moveq	#$4b,d1
	bsr	t_33a6
	move.l	d0,d5
	move	d5,d1
	ext.l	d1
	move.l	d1,d0
	lsl.l	#3,d0
	add.l	d1,d0
	lsl.l	#2,d0
	add.l	d1,d0
	add.l	d0,d0
	add.l	d1,d0
	sub.l	d0,d3
	move	d3,d0
	move.b	d4,(a2)+
	moveq	#2,d2
	add.b	d5,d2
	move.b	d2,(a2)+
	move.b	d0,(a2)
	movem.l	(sp)+,d3-d5/a2
	rts
;----------------------------------------------------------------------------
XHMediumChanged_sub:
	move.l	d2,-(sp)
	move.l	8(sp),d1
	move	12(sp),d0
	tst.w	14(sp)
	bne.s	t_23a2
	cmp	#$12,d0
	bcc.s	t_23a2
	moveq	#0,d2
	move	d0,d2
	lsl.l	#2,d2
	lea	b_3a1e,a1
	movea.l	0(a1,d2.l),a0
	move.l	a0,d2
	bne.s	t_23a6
t_23a2:
	move.l	d1,d0
	bra.s	t_23c2
;
t_23a6:
	move	#1,$12(a0)
	clr.w	d0
	move	d0,$d2(a0)
	move	d0,$ca(a0)
	moveq	#-15,d2
	cmp.l	d1,d2
	bne.s	t_23c0
	moveq	#0,d0
	bra.s	t_23c2
;
t_23c0:
	move.l	d1,d0
t_23c2:
	move.l	(sp)+,d2
	rts
;----------------------------------------------------------------------------
Bconws_fun:
	move	d3,-(sp)
	move.l	a2,-(sp)
	movea.l	a0,a2
	clr.w	d3
	bra.s	.t_23ec
;
.t_23d0:
	addq.w	#1,d3
	cmp.b	#LF,(a2)
	bne.s	.t_23e2
	moveq	#CR,d1
	moveq	#2,d0
	bsr	Bconout_fun
	addq.w	#1,d3
.t_23e2:
	move.b	(a2)+,d1
	ext.w	d1
	moveq	#2,d0
	bsr	Bconout_fun
.t_23ec:
	move.b	(a2),d0
	bne	.t_23d0
	move	d3,d0
	movea.l	(sp)+,a2
	move	(sp)+,d3
	rts
;----------------------------------------------------------------------------
t_23f8:
	move.l	d3,-(sp)
	move.l	d4,-(sp)
	move.l	d0,d3
	clr.w	d1
	bsr	Mxalloc_fun
	move.l	a0,d4
	moveq	#-$20,d0
	cmp.l	d4,d0
	bne.s	t_2414
	move.l	d3,d0
	bsr	Malloc_fun
	move.l	a0,d4
t_2414:
	movea.l	d4,a0
	move.l	(sp)+,d4
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
Metaopen_sub:
	movem.l	d2/d3/a2/a3,-(sp)
	movea.l	$14(sp),a2
	movea.l	$1c(sp),a3
	clr.w	d3
	bra.s	t_2452
;----------------------------------------------------------------------------
t_242c:
	lea	$3f8(a2),a0
	bsr	t_1fda
	tst.w	d0
	bmi.s	t_2450
	lea	$1c(a2),a0
	move.l	a0,(a3)
	moveq	#0,d0
	move.l	d0,12(a3)
	move.l	d0,8(a3)
	move.l	d0,4(a3)
	moveq	#0,d0
	bra.s	t_245a
;----------------------------------------------------------------------------
t_2450:
	addq.w	#1,d3
t_2452:
	cmp	#3,d3
	blt	t_242c
	moveq	#-2,d0
t_245a:
	movem.l	(sp)+,d2/d3/a2/a3
	rts
;----------------------------------------------------------------------------
Metaread_sub:
	movem.l	d2/a2/a3,-(sp)
	lea	-$c(sp),sp
	movea.l	$1c(sp),a2
	move.l	$24(sp),4(sp)
	move.l	$28(sp),(sp)
	move	$2c(sp),d0
	ext.l	d0
	moveq	#11,d1
	lsl.l	d1,d0
	move.l	d0,8(sp)
	lea	(sp),a1
	movea.l	a2,a0
	movea.l	$50(a2),a3
	jsr	(a3)
	lea	12(sp),sp
	movem.l	(sp)+,d2/a2/a3
	rts
;----------------------------------------------------------------------------
Metastatus_sub:
	movem.l	d2/a2/a3,-(sp)
	movea.l	$10(sp),a2
	movea.l	$18(sp),a1
	movea.l	a2,a0
	movea.l	$64(a2),a3
	jsr	(a3)
	movem.l	(sp)+,d2/a2/a3
	rts
;----------------------------------------------------------------------------
Metaioctl_sub:
	movem.l	d2-d4/a2-a4,-(sp)
	lea	-$5c(sp),sp
	movea.l	$78(sp),a3
	move.l	$86(sp),d3
	cmp.l	#$4643544c,$80(sp)	;First arg == 'FCTL' ?
	bne	t_2814
	move	$84(sp),d0		;d0 = FCTL opcode
	cmp	#$430a,d0
	beq	t_2774
	bgt.s	t_2532
	cmp	#$4304,d0
	beq	t_2712
	bgt.s	t_2512
	cmp	#$4301,d0
	beq	t_2600
	bgt.s	t_2500
	tst.w	d0
	beq.s	t_255e
	sub.w	#$4300,d0
	beq	t_25f2
	bra	t_2814
;----------------------------------------------------------------------------
t_2500:
	sub.w	#$4302,d0
	beq	t_260e
	subq	#1,d0
	beq	t_2720
	bra	t_2814
;----------------------------------------------------------------------------
t_2512:
	sub.w	#$4305,d0
	cmp	#4,d0
	bhi	t_2814
	add.w	d0,d0
	move	t_2528(pc,d0.w),d0
	jmp	t_2528(pc,d0.w)
;----------------------------------------------------------------------------
t_2528:
	dc.w	t_272e-t_2528,t_273c-t_2528,t_2670-t_2528,t_262a-t_2528
	dc.w	t_261c-t_2528
;----------------------------------------------------------------------------
t_2532:
	sub.w	#$430b,d0
	cmp	#10,d0
	bhi	t_2814
	add.w	d0,d0
	move	t_2548(pc,d0.w),d0
	jmp	t_2548(pc,d0.w)
;----------------------------------------------------------------------------
t_2548:
	dc.w	t_274a-t_2548,t_279e-t_2548,t_2790-t_2548,t_26dc-t_2548
	dc.w	t_26a6-t_2548,t_2782-t_2548,t_27aa-t_2548,t_2814-t_2548
	dc.w	t_2758-t_2548,t_2766-t_2548,t_27b6-t_2548
;----------------------------------------------------------------------------
t_255e:
	movea.l	d3,a2
	cmp.l	#$494e464f,(a2)
	bne	t_2814
	move.l	#$494e464f,(sp)
	move.l	4(a2),4(sp)
	move	10(a3),8(sp)
	clr.w	d0
	move	d0,10(sp)
	move	d0,$56(sp)
	move	10(a3),d1
	ext.l	d1
	divs	#8,d1
	move	d1,$52(sp)
	moveq	#7,d0
	and	10(a3),d0
	move	d0,$54(sp)
	lea	$aa(a3),a1
	lea	12(sp),a0
	bsr	t_307e
	move	#5,$4c(sp)
	moveq	#7,d0
	or.l	$d4(a3),d0
	move.l	d0,$4e(sp)
	moveq	#4,d1
	and	$a0(a3),d1
	beq.s	t_25e0
	clr.l	-(sp)
	lea	$5c(sp),a1
	suba.l	a0,a0
	move	10(a3),d0
	clr.w	d1
	bsr	t_2fdc
	addq.w	#4,sp
	tst.l	d0
	bne.s	t_25e0
	move.l	$58(sp),$4e(sp)
t_25e0:
	move.l	4(a2),d0
	lea	(sp),a1
	movea.l	a2,a0
	bsr	t_30fc
	moveq	#0,d0
	bra	t_2816
;----------------------------------------------------------------------------
t_25f2:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$4c(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2600:
	clr.w	d0
	movea.l	a3,a0
	movea.l	$70(a3),a1
	jsr	(a1)
	bra	t_2816
;----------------------------------------------------------------------------
t_260e:
	moveq	#1,d0
	movea.l	a3,a0
	movea.l	$70(a3),a1
	jsr	(a1)
	bra	t_2816
;----------------------------------------------------------------------------
t_261c:
	moveq	#2,d0
	movea.l	a3,a0
	movea.l	$68(a3),a1
	jsr	(a1)
	bra	t_2816
;----------------------------------------------------------------------------
t_262a:
	moveq	#3,d0
	movea.l	a3,a0
	movea.l	$68(a3),a1
	jsr	(a1)
	move.l	d0,d4
	tst.l	d0
	beq.s	t_2646
	movea.l	a3,a0
	movea.l	$68(a3),a1
	moveq	#1,d0
	jsr	(a1)
	move.l	d0,d4
t_2646:
	tst.l	d4
	bne.s	t_2652
	andi.l	#-$40000001,$d4(a3)
t_2652:
	moveq	#4,d0
	and	$a0(a3),d0
	beq.s	t_266a
	clr.w	-(sp)
	clr.w	d2
	clr.w	d1
	move	10(a3),d0
	bsr	t_3034
	addq.w	#2,sp
t_266a:
	move.l	d4,d0
	bra	t_2816
;----------------------------------------------------------------------------
t_2670:
	clr.w	d0
	movea.l	a3,a0
	movea.l	$68(a3),a1
	jsr	(a1)
	move.l	d0,d4
	tst.l	d0
	bne.s	t_2688
	ori.l	#$40000000,$d4(a3)
t_2688:
	moveq	#4,d0
	and	$a0(a3),d0
	beq.s	t_26a0
	clr.w	-(sp)
	moveq	#1,d2
	clr.w	d1
	move	10(a3),d0
	bsr	t_3034
	addq.w	#2,sp
t_26a0:
	move.l	d4,d0
	bra	t_2816
;----------------------------------------------------------------------------
t_26a6:
	clr.w	d0
	movea.l	a3,a0
	movea.l	$6c(a3),a1
	jsr	(a1)
	move.l	d0,d4
	tst.l	d0
	bne.s	t_26be
	andi.l	#-$20000001,$d4(a3)
t_26be:
	moveq	#4,d0
	and	$a0(a3),d0
	beq.s	t_26d6
	clr.w	-(sp)
	clr.w	d2
	clr.w	d1
	move	10(a3),d0
	bsr	t_300a
	addq.w	#2,sp
t_26d6:
	move.l	d4,d0
	bra	t_2816
;----------------------------------------------------------------------------
t_26dc:
	moveq	#1,d0
	movea.l	a3,a0
	movea.l	$6c(a3),a1
	jsr	(a1)
	move.l	d0,d4
	tst.l	d0
	bne.s	t_26f4
	ori.l	#$20000000,$d4(a3)
t_26f4:
	moveq	#4,d0
	and	$a0(a3),d0
	beq.s	t_270c
	clr.w	-(sp)
	moveq	#1,d2
	clr.w	d1
	move	10(a3),d0
	bsr	t_300a
	addq.w	#2,sp
t_270c:
	move.l	d4,d0
	bra	t_2816
;----------------------------------------------------------------------------
t_2712:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$78(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2720:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$74(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_272e:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$7c(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_273c:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$80(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_274a:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$84(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2758:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$88(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2766:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$8c(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2774:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$94(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2782:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$90(a3),a2
	jsr	(a2)
	bra	t_2816
;----------------------------------------------------------------------------
t_2790:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$50(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_279e:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$54(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_27aa:
	movea.l	d3,a1
	movea.l	a3,a0
	movea.l	$58(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_27b6:
	movea.l	d3,a0
	movea.l	d3,a4
	move	12(a0),d0
	cmp	#4,d0
	bhi.s	t_2814
	add.w	d0,d0
	move	t_27ce(pc,d0.w),d0
	jmp	t_27ce(pc,d0.w)
;----------------------------------------------------------------------------
t_27ce:
	dc.w	t_27d8-t_27ce,t_27e4-t_27ce,t_27f0-t_27ce,t_27fc-t_27ce
	dc.w	t_2808-t_27ce
;----------------------------------------------------------------------------
t_27d8:
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$58(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_27e4:
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$50(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_27f0:
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$54(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_27fc:
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$5c(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_2808:
	movea.l	a4,a1
	movea.l	a3,a0
	movea.l	$60(a3),a2
	jsr	(a2)
	bra.s	t_2816
;----------------------------------------------------------------------------
t_2814:
	moveq	#-$20,d0
t_2816:
	lea	$5c(sp),sp
	movem.l	(sp)+,d2-d4/a2-a4
	rts
;----------------------------------------------------------------------------
Metagettoc_sub:
	movem.l	d2-d6/a2-a5,-(sp)
	lea	-$c(sp),sp
	movea.l	$34(sp),a3
	movea.l	$3e(sp),a4
	movea.l	a4,a2
	move.l	#$200,d1
	clr.w	d0
	movea.l	a4,a0
	bsr	t_32e6
	lea	(sp),a1
	movea.l	a3,a0
	movea.l	$7c(a3),a4
	jsr	(a4)
	move.l	d0,d3
	lea	2(sp),a5
	tst.l	d3
	bne.s	t_2884
	clr.w	d4
	move.b	(sp),d4
	bra.s	t_28b8
;----------------------------------------------------------------------------
t_285a:
	move	d4,d5
	clr.w	d0
	move.b	1(sp),d0
	addq.w	#1,d0
	cmp	d0,d4
	bne.s	t_286c
	move	#$aa,d5
t_286c:
	move.b	d5,(a5)
	move.b	#2,1(a5)
	movea.l	a5,a1
	movea.l	a3,a0
	movea.l	$80(a3),a4
	jsr	(a4)
	move.l	d0,d3
	tst.l	d0
	beq.s	t_2888
t_2884:
	move.l	d3,d0
	bra.s	t_28c6
;----------------------------------------------------------------------------
t_2888:
	move	d5,d6
	ext.l	d6
	cmp.l	#$aa,d6
	bne.s	t_289a
	move.l	#$a2,d6
t_289a:
	moveq	#$18,d0
	lsl.l	d0,d6
	lea	7(a5),a0
	moveq	#3,d0
	bsr	t_22a2
	move.l	6(a5),d0
	and.l	#$ffffff,d0
	or.l	d0,d6
	move.l	d6,(a2)+
	addq.w	#1,d4
t_28b8:
	clr.w	d0
	move.b	1(sp),d0
	addq.w	#1,d0
	cmp	d0,d4
	ble	t_285a
	moveq	#0,d0
t_28c6:
	lea	12(sp),sp
	movem.l	(sp)+,d2-d6/a2-a5
	rts
;----------------------------------------------------------------------------
Metadiscinfo_sub:
	movem.l	d2/a2/a3,-(sp)
	movea.l	$10(sp),a2
	movea.l	$18(sp),a1
	movea.l	a2,a0
	movea.l	$98(a2),a3
	jsr	(a3)
	movem.l	(sp)+,d2/a2/a3
	rts
;----------------------------------------------------------------------------
Metastartaudio_sub:
	movem.l	d2/d3/a2/a3,-(sp)
	subq	#4,sp
	movea.l	$18(sp),a3
	move.l	$1c(sp),d3
	movea.l	$22(sp),a0
	move.b	1(a0),d0
	ext.w	d0
	move.b	(a0),d1
	ext.w	d1
	add.w	d1,d0
	cmp	#$64,d0
	ble.s	t_2916
	moveq	#$64,d0
	sub.b	1(a0),d0
	move.b	d0,(a0)
t_2916:
	move.b	1(a0),(sp)
	move.b	1(a0),d0
	add.b	(a0),d0
	add.b	#-1,d0
	move.b	d0,2(sp)
	move.b	#1,1(sp)
	move.b	#$63,3(sp)
	lea	(sp),a1
	movea.l	a3,a0
	movea.l	$78(a3),a2
	jsr	(a2)
	move.l	d0,d3
	moveq	#-5,d1
	cmp.l	d0,d1
	bne.s	t_2958
	move.b	#1,3(sp)
	lea	(sp),a1
	movea.l	a3,a0
	movea.l	$78(a3),a2
	jsr	(a2)
	move.l	d0,d3
t_2958:
	move.l	d3,d0
	addq.w	#4,sp
	movem.l	(sp)+,d2/d3/a2/a3
	rts
;----------------------------------------------------------------------------
Metastopaudio_sub:
	move.l	d2,-(sp)
	move.l	a2,-(sp)
	movea.l	12(sp),a2
	clr.w	d0
	movea.l	a2,a0
	movea.l	$68(a2),a1
	jsr	(a1)
	movea.l	(sp)+,a2
	move.l	(sp)+,d2
	rts
;----------------------------------------------------------------------------
Metasetsongtime_sub:
	movem.l	d2/a2/a3/a5,-(sp)
	subq	#6,sp
	movea.l	$1a(sp),a5
	lea	$24(sp),a2
	lea	$28(sp),a3
	moveq	#3,d0
	lea	1(a2),a0
	bsr	t_2266
	moveq	#3,d0
	lea	1(a3),a0
	bsr	t_2266
	move.b	1(a2),(sp)
	move.b	2(a2),1(sp)
	move.b	3(a2),2(sp)
	move.b	1(a3),3(sp)
	move.b	2(a3),4(sp)
	move.b	3(a3),5(sp)
	lea	(sp),a1
	movea.l	a5,a0
	movea.l	$74(a5),a2
	jsr	(a2)
	addq.w	#6,sp
	movem.l	(sp)+,d2/a2/a3/a5
	rts
;----------------------------------------------------------------------------
t_29d4:
	movem.l	d3/d4/a2,-(sp)
	move	d0,d3
	move	d1,d4
	lea	d_3868,a2
	lea	d_3874,a1
	movea.l	a2,a0
	bsr	t_307e
	moveq	#8,d0
	and	d3,d0
	beq.s	t_29f8
	moveq	#$53,d1
	bra.s	t_29fa
;----------------------------------------------------------------------------
t_29f8:
	moveq	#$41,d1
t_29fa:
	move.b	d1,1(a2)
	moveq	#7,d0
	and.b	d3,d0
	add.b	#$30,d0
	move.b	d0,6(a2)
	cmp	#15,d3
	bls.s	t_2a20
	lea	d_3880,a1
	lea	1(a2),a0
	moveq	#4,d0
	bsr	t_30fc
t_2a20:
	moveq	#7,d0
	and.b	d4,d0
	add.b	#$30,d0
	move.b	d0,8(a2)
	movea.l	a2,a0
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
t_2a34:
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	subq	#4,sp
	movea.l	a0,a3
	movea.l	a1,a4
	lea	(sp),a0
	move.l	#'XFRB',d0
	bsr	t_354e
	tst.w	d0
	beq.s	t_2a86
t_2a4e:
	movea.l	(sp),a0
	movea.l	2(a0),a1
	move.b	(a1),d0
	bne.s	t_2a72
	move.l	6(a0),d1
	beq.s	t_2a72
	move.b	#1,(a1)
	movea.l	(sp),a0
	move.l	6(a0),(a3)
	movea.l	(sp),a0
	move.l	10(a0),(a4)
	moveq	#1,d0
	bra.s	t_2a88
;----------------------------------------------------------------------------
t_2a72:
	movea.l	(sp),a0
	cmp	#$101,(a0)
	blt.s	t_2a80
	move.l	14(a0),(sp)
	bra.s	t_2a82
;----------------------------------------------------------------------------
t_2a80:
	clr.l	(sp)
t_2a82:
	move.l	(sp),d0
	bne	t_2a4e
t_2a86:
	clr.w	d0
t_2a88:
	addq.w	#4,sp
	movea.l	(sp)+,a4
	movea.l	(sp)+,a3
	rts
;----------------------------------------------------------------------------
move_l_cookies_d0_2:
	move.l	(_cookies).w,d0
	rts
;----------------------------------------------------------------------------
install_new_XHDI:
	move.l	a2,-(sp)
	lea	move_l_cookies_d0_2(pc),a0
	bsr	Supexec_fun
	movea.l	d0,a0
	move.l	a0,d0
	beq.s	.t_2ace
.t_2aa6:
	lea	XHDI_dispatcher,a2
	lea	old_XHDI_p,a1
	cmp.l	#'XHDI',(a0)
	bne.s	.t_2ac6
	move.l	4(a0),(a1)		;link new XHDI to old one
	move.l	a2,4(a0)		;activate new XHDI dispatcher
	moveq	#1,d0			;flag success
	bra.s	.t_2ad0
;
.t_2ac6:
	addq.w	#8,a0
	move.l	-$8(a0),d0
	bne	.t_2aa6
.t_2ace:
	clr.w	d0			;flag failure
.t_2ad0:
	movea.l	(sp)+,a2
	rts				;return to caller
;----------------------------------------------------------------------------
BOS_init_sub:
	movem.l	d2-d4/a2-a5,-(sp)
	lea	-$32(sp),sp
	lea	$54(sp),a4
	clr.w	d3
	moveq	#-1,d0
	bsr	Kbshift_fun
	and.l	#8,d0			;[Alternate] pressed ?
	beq.s	t_2afe
	lea	abort_Alternate_s,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2afe:
	lea	(sp),a0
	move	(a4),d1
	moveq	#13,d0
	lsr.w	d0,d1
	and	#7,d1
	move	(a4),d0
	and	#$1fff,d0
	bsr	t_1eb0
	tst.w	d0
	beq	t_2e1a
	move	(a4),d1
	moveq	#13,d0
	lsr.w	d0,d1
	and	#7,d1
	move	(a4),d0
	and	#$1fff,d0
	bsr	t_29d4
	bsr	Bconws_fun
	lea	d_381c,a2
	move.l	(a2),d0
	bne.s	t_2b46
	lea	4(a2),a1
	movea.l	a2,a0
	bsr	t_2a34
t_2b46:
	move.l	(a2),d0
	bne.s	t_2b78
	suba.l	a0,a0
	move.l	#'SWAP',d0
	bsr	t_354e
	tst.w	d0
	bne.s	t_2b78
	lea	$2e(sp),a0
	move.l	#'_FRB',d0
	bsr	t_354e
	tst.w	d0
	beq.s	t_2b78
	move.l	#$10000,4(a2)
	move.l	$2e(sp),(a2)
t_2b78:
	move.l	(a2),d0
	bne.s	t_2bac
	move.l	#$a14,4(a2)
	suba.l	a0,a0
	move.l	#'_FRB',d0
	bsr	t_354e
	tst.w	d0
	beq.s	t_2b9c
	move.l	#$10000,4(a2)
t_2b9c:
	move.l	4(a2),d0
	bsr	t_23f8
	move.l	a0,(a2)
	move.l	a0,d0
	beq.s	t_2bfa
	moveq	#1,d3
t_2bac:
	clr.w	d4
t_2bae:
	moveq	#$64,d0
	bsr	t_21f6
	lea	(sp),a0
	bsr	t_1fda
	tst.w	d0
	bpl.s	t_2be0
	cmp	#2,d4
	bne.s	t_2bdc
	tst.w	d3
	beq.s	t_2bce
	movea.l	(a2),a0
	bsr	Mfree_fun
t_2bce:
	lea	d_38ce,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2bdc:
	addq.w	#1,d4
	bra	t_2bae
;
t_2be0:
	move.l	#$124,d0
	bsr	t_23f8
	movea.l	a0,a5
	move.l	a5,d0
	bne.s	t_2c08
	tst.w	d3
	beq.s	t_2bfa
	movea.l	(a2),a0
	bsr	Mfree_fun
t_2bfa:
	lea	d_38af,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2c08:
	movea.l	(a2),a1
	lea	(sp),a0
	bsr	t_2010
	move.l	#$124,d1
	clr.w	d0
	movea.l	(a2),a0
	bsr	t_32e6
	movea.l	(a2),a1
	lea	(sp),a0
	bsr	t_2070
	move	d0,d4
	movea.l	(a2),a1
	movea.l	a5,a0
	move.l	#$124,d0
	bsr	t_30fc
	tst.w	d4
	bpl.s	t_2c58
	movea.l	a5,a0
	bsr	Mfree_fun
	tst.w	d3
	beq.s	t_2c4a
	movea.l	(a2),a0
	bsr	Mfree_fun
t_2c4a:
	lea	d_38f6,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2c58:
	move	(a5),d0
	lsr.w	#8,d0
	and	#$1f,d0
	subq	#5,d0
	beq.s	t_2ca2
	move	(a5),d1
	lsr.w	#8,d1
	and	#$1f,d1
	subq	#4,d1
	beq.s	t_2ca2
	lea	MATSHITAPD_1_s,a1
	lea	8(a5),a0
	moveq	#12,d0
	bsr	t_30c4
	tst.w	d0
	beq.s	t_2ca2
	movea.l	a5,a0
	bsr	Mfree_fun
	tst.w	d3
	beq.s	t_2c94
	movea.l	(a2),a0
	bsr	Mfree_fun
t_2c94:
	lea	unit_not_a_CD_ROM_s,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2ca2:
	move.l	#$3fe,d0
	bsr	t_23f8
	movea.l	a0,a3
	move.l	a3,d0
	bne.s	t_2cd0
	movea.l	a5,a0
	bsr	Mfree_fun
	tst.w	d3
	beq.s	t_2cc2
	movea.l	(a2),a0
	bsr	Mfree_fun
t_2cc2:
	lea	not_enough_memory_s,a0
	bsr	Bconws_fun
	bra	t_2e1a
;
t_2cd0:
	move.l	#$3fe,d1
	clr.w	d0
	movea.l	a3,a0
	bsr	t_32e6
	move	$52(sp),8(a3)
	move	(a4),d0
	and	#$1fff,d0
	move	d0,10(a3)
	move.l	#BOS_func_t,14(a3)
	lea	(sp),a0
	lea	$3f8(a3),a1
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	lea	BOS_driver_name_s,a1
	lea	$1c(a3),a0
	bsr	t_307e
	moveq	#15,d0
	and	2(a5),d0
	bne.s	t_2d24
	move	2(a5),d1
	lsr.w	#8,d1
	and	#7,d1
	subq	#2,d1
	bcs.s	t_2d36
t_2d24:
	move	6(a5),d0
	lsr.w	#3,d0
	and	#1,d0
	beq.s	t_2d36
	ori.w	#1,$a0(a3)
t_2d36:
	move.l	#$800,$cc(a3)
	move.l	(a2),$a2(a3)
	move.l	4(a2),$a6(a3)
	lea	d_3586,a0
	lea	$3c(a3),a1
	moveq	#$18,d0
t_2d54:
	move.l	(a0)+,(a1)+
	dbra	d0,t_2d54
	moveq	#8,d0
	lea	d_3958,a1
	lea	8(a5),a0
	bsr	t_30c4
	tst.w	d0
	bne.s	t_2d80
	lea	d_35ea,a0
	lea	$3c(a3),a1
	moveq	#$18,d0
t_2d7a:
	move.l	(a0)+,(a1)+
	dbra	d0,t_2d7a
t_2d80:
	moveq	#8,d0
	lea	TOSHIBA_s,a1
	lea	8(a5),a0
	bsr	t_30c4
	tst.w	d0
	bne.s	t_2da6
	lea	d_364e,a0
	lea	$3c(a3),a1
	moveq	#$18,d0
t_2da0:
	move.l	(a0)+,(a1)+
	dbra	d0,t_2da0
t_2da6:
	moveq	#8,d0
	lea	SONY_s,a1
	lea	8(a5),a0
	bsr	t_30c4
	tst.w	d0
	beq.s	t_2dce
	moveq	#8,d0
	lea	PLEXTOR_s,a1
	lea	8(a5),a0
	bsr	t_30c4
	tst.w	d0
	bne.s	t_2de0
t_2dce:
	lea	d_3716,a0
	lea	$3c(a3),a1
	moveq	#$18,d0
t_2dda:
	move.l	(a0)+,(a1)+
	dbra	d0,t_2dda
t_2de0:
	moveq	#$17,d0
	lea	SONY_CDU_8002_s,a1
	lea	8(a5),a0
	bsr	t_30c4
	tst.w	d0
	bne.s	t_2e06
	lea	d_36b2,a0
	lea	$3c(a3),a1
	moveq	#$18,d0
t_2e00:
	move.l	(a0)+,(a1)+
	dbra	d0,t_2e00
t_2e06:
	cmp.l	#'JRCD',$9c(a3)
	beq.s	t_2e20
	lea	crack_ARG_s,a0
	bsr	Bconws_fun
t_2e1a:
	moveq	#-1,d0
	bra	t_2ef8
;
t_2e20:
	movea.l	a3,a0
	movea.l	$44(a3),a1
	jsr	(a1)
	lea	6(sp),a2
	cmp.b	#$1c,4(a5)
	bcs.s	t_2e46
	moveq	#$1c,d0
	lea	8(a5),a1
	movea.l	a2,a0
	bsr	t_30e2
	clr.b	$1c(a2)
	bra.s	t_2e62
;
t_2e46:
	clr.w	d0
	move.b	4(a5),d0
	ext.l	d0
	lea	5(a5),a1
	movea.l	a2,a0
	bsr	t_30e2
	clr.w	d0
	move.b	4(a5),d0
	clr.b	0(a2,d0.w)
t_2e62:
	movea.l	a5,a0
	bsr	Mfree_fun
	movea.l	a2,a1
	lea	$aa(a3),a0
	bsr	t_307e
	movea.l	a2,a0
	bsr	Bconws_fun
	bsr	t_2f46
	cmp	#$100,d0
	bcs.s	t_2eec
	suba.l	a0,a0
	move.l	#'HDJR',d0
	bsr	t_354e
	tst.w	d0
	bne.s	t_2eec
	clr.l	-(sp)
	suba.l	a1,a1
	suba.l	a0,a0
	move	(a4),d1
	moveq	#13,d0
	lsr.w	d0,d1
	and	#7,d1
	move	(a4),d0
	and	#$1fff,d0
	bsr	t_2f88
	addq.w	#4,sp
	tst.l	d0
	bne.s	t_2eec
	ori.w	#4,$a0(a3)
	lea	XHDI_parenth_s,a0
	bsr	Bconws_fun
	move	(a4),d0
	and	#$1fff,d0
	cmp	#$11,d0
	bhi.s	t_2ee0
	move	(a4),d1
	and	#$1fff,d1
	lsl.w	#2,d1
	lea	b_3a1e,a0
	move.l	a3,0(a0,d1.w)
t_2ee0:
	move.l	old_XHDI_p,d0
	bne.s	t_2eec
	bsr	install_new_XHDI
t_2eec:
	lea	d_38ad,a0
	bsr	Bconws_fun
	move.l	a3,d0
t_2ef8:
	lea	$32(sp),sp
	movem.l	(sp)+,d2-d4/a2-a5
	rts
;----------------------------------------------------------------------------
show_init_mess:
	lea	init_mess_s,a0
	bsr	Bconws_fun
	rts
;----------------------------------------------------------------------------
t_2f0e:
	move.l	a2,-(sp)
	lea	d_39fc,a2
	move	4(a2),d0
	bne.s	t_2f40
	movea.l	a2,a0
	move.l	#'XHDI',d0
	bsr	t_354e
	move	#1,4(a2)
	movea.l	(a2),a0
	move.l	a0,d0
	beq.s	t_2f40
	cmp.l	#$27011992,-$4(a0)
	beq.s	t_2f40
	clr.l	(a2)
t_2f40:
	movea.l	(a2),a0
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
t_2f46:
	movem.l	d3/d4/a2,-(sp)
	bsr	t_2f0e
	movea.l	a0,a2
	moveq	#0,d3
	clr.w	d4
	movea.l	#1,a0
	bsr	Super_fun
	tst.l	d0
	bne.s	t_2f6a
	suba.l	a0,a0
	bsr	Super_fun
	move.l	d0,d3
t_2f6a:
	move.l	a2,d0
	beq.s	t_2f76
	clr.w	-(sp)
	jsr	(a2)
	addq.w	#2,sp
	move.l	d0,d4
t_2f76:
	tst.l	d3
	beq.s	t_2f80
	movea.l	d3,a0
	bsr	Super_fun
t_2f80:
	move	d4,d0
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
t_2f88:
	movem.l	d3-d5/a2-a4,-(sp)
	move	d0,d5
	move	d1,d4
	movea.l	a0,a4
	movea.l	a1,a3
	bsr	t_2f0e
	movea.l	a0,a2
	moveq	#0,d3
	movea.l	#1,a0
	bsr	Super_fun
	tst.l	d0
	bne.s	t_2fb2
	suba.l	a0,a0
	bsr	Super_fun
	move.l	d0,d3
t_2fb2:
	move.l	$1c(sp),-(sp)
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move	d4,-(sp)
	move	d5,-(sp)
	moveq	#1,d0
	move	d0,-(sp)
	jsr	(a2)
	lea	$12(sp),sp
	move.l	d0,d5
	tst.l	d3
	beq.s	t_2fd4
	movea.l	d3,a0
	bsr	Super_fun
t_2fd4:
	move.l	d5,d0
	movem.l	(sp)+,d3-d5/a2-a4
	rts
;----------------------------------------------------------------------------
t_2fdc:
	movem.l	d3/d4/a2-a4,-(sp)
	move	d0,d4
	move	d1,d3
	movea.l	a0,a4
	movea.l	a1,a3
	bsr	t_2f0e
	movea.l	a0,a2
	move.l	$18(sp),-(sp)
	move.l	a3,-(sp)
	move.l	a4,-(sp)
	move	d3,-(sp)
	move	d4,-(sp)
	moveq	#1,d0
	move	d0,-(sp)
	jsr	(a2)
	lea	$12(sp),sp
	movem.l	(sp)+,d3/d4/a2-a4
	rts
;----------------------------------------------------------------------------
t_300a:
	movem.l	d3-d5/a2,-(sp)
	move	d0,d5
	move	d1,d4
	move	d2,d3
	bsr	t_2f0e
	movea.l	a0,a2
	move	$14(sp),-(sp)
	move	d3,-(sp)
	move	d4,-(sp)
	move	d5,-(sp)
	moveq	#3,d0
	move	d0,-(sp)
	jsr	(a2)
	lea	10(sp),sp
	movem.l	(sp)+,d3-d5/a2
	rts
;----------------------------------------------------------------------------
t_3034:
	movem.l	d3-d5/a2,-(sp)
	move	d0,d5
	move	d1,d4
	move	d2,d3
	bsr	t_2f0e
	movea.l	a0,a2
	move	$14(sp),-(sp)
	move	d3,-(sp)
	move	d4,-(sp)
	move	d5,-(sp)
	moveq	#4,d0
	move	d0,-(sp)
	jsr	(a2)
	lea	10(sp),sp
	movem.l	(sp)+,d3-d5/a2
	rts
;----------------------------------------------------------------------------
t_305e:
	movem.l	d3/d4/a2,-(sp)
	move	d0,d4
	move	d1,d3
	bsr	t_2f0e
	movea.l	a0,a2
	move	d3,-(sp)
	move	d4,-(sp)
	moveq	#15,d0
	move	d0,-(sp)
	jsr	(a2)
	addq.w	#6,sp
	movem.l	(sp)+,d3/d4/a2
	rts
;----------------------------------------------------------------------------
t_307e:
	move.l	a0,d0
t_3080:
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	beq.s	t_30c0
	move.b	(a1)+,(a0)+
	bne	t_3080
t_30c0:
	movea.l	d0,a0
	rts
;----------------------------------------------------------------------------
t_30c4:
	subq.l	#1,d0
	bcs.s	t_30da
	move.b	(a0)+,d1
	beq.s	t_30d6
	cmp.b	(a1)+,d1
	beq	t_30c4
	bhi.s	t_30de
t_30d2:
	moveq	#-1,d0
	rts
;----------------------------------------------------------------------------
t_30d6:
	tst.b	(a1)+
	bne	t_30d2
t_30da:
	moveq	#0,d0
	rts
;----------------------------------------------------------------------------
t_30de:
	moveq	#1,d0
	rts
;----------------------------------------------------------------------------
t_30e2:
	move.l	a0,d1
t_30e4:
	subq.l	#1,d0
	bcs.s	t_30f8
	move.b	(a1)+,(a0)+
	bne	t_30e4
	clr.b	d2
	tst.l	d0
	beq.s	t_30f8
t_30f2:
	move.b	d2,(a0)+
	subq.l	#1,d0
	bne	t_30f2
t_30f8:
	movea.l	d1,a0
	rts
;----------------------------------------------------------------------------
t_30fc:
	tst.l	d0
	beq	t_32e4
	move.l	a0,-(sp)
	cmp.l	a0,a1
	bhi	t_3200
	beq	t_32e2
	adda.l	d0,a1
	adda.l	d0,a0
	move	a1,d1
	move	a0,d2
	btst	#0,d1
	beq.s	t_312c
	btst	#0,d2
	bne.s	t_3134
t_3122:
	move.b	-(a1),-(a0)
	subq.l	#1,d0
	bne	t_3122
	bra	t_32e2
;----------------------------------------------------------------------------
t_312c:
	btst	#0,d2
	bne	t_3122
	bra.s	t_313c
;----------------------------------------------------------------------------
t_3134:
	move.b	-(a1),-(a0)
	subq.l	#1,d0
	beq	t_32e2
t_313c:
	move.l	d0,d1
	lsr.l	#5,d1
	lsr.l	#4,d1
	beq	t_31da
	movem.l	d2-d7/a3-a6,-(sp)
t_314a:
	movem.l	-$28(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$50(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$78(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$a0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$c8(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$f0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$118(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$140(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$168(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$190(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$1b8(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$1e0(a1),d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,-(a0)
	movem.l	-$200(a1),d2-d7/a3/a4
	movem.l	d2-d7/a3/a4,-(a0)
	suba.w	#$200,a1
	subq.l	#1,d1
	bne	t_314a
	movem.l	(sp)+,d2-d7/a3-a6
t_31da:
	move	d0,d1
	and	#$1ff,d0
	lsr.w	#2,d0
	beq.s	t_31ec
	subq	#1,d0
t_31e6:
	move.l	-(a1),-(a0)
	dbra	d0,t_31e6
t_31ec:
	and	#3,d1
	beq	t_32e2
	subq	#1,d1
t_31f6:
	move.b	-(a1),-(a0)
	dbra	d1,t_31f6
	bra	t_32e2
;----------------------------------------------------------------------------
t_3200:
	move	a1,d1
	move	a0,d2
	btst	#0,d1
	beq.s	t_321a
	btst	#0,d2
	bne.s	t_3222
t_3210:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bne	t_3210
	bra	t_32e2
;----------------------------------------------------------------------------
t_321a:
	btst	#0,d2
	bne	t_3210
	bra.s	t_3226
;----------------------------------------------------------------------------
t_3222:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
t_3226:
	move.l	d0,d1
	lsr.l	#5,d1
	lsr.l	#4,d1
	beq	t_32c2
	movem.l	d2-d7/a3-a6,-(sp)
t_3234:
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$28(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$50(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$78(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$a0(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$c8(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$f0(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$118(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$140(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$168(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$190(a0)
	movem.l	(a1)+,d2-d7/a3-a6
	movem.l	d2-d7/a3-a6,$1b8(a0)
	movem.l	(a1)+,d2-d7/a3/a4
	movem.l	d2-d7/a3/a4,$1e0(a0)
	adda.w	#$200,a0
	subq.l	#1,d1
	bne	t_3234
	movem.l	(sp)+,d2-d7/a3-a6
t_32c2:
	move	d0,d1
	and	#$1ff,d0
	lsr.w	#2,d0
	beq.s	t_32d4
	subq	#1,d0
t_32ce:
	move.l	(a1)+,(a0)+
	dbra	d0,t_32ce
t_32d4:
	and	#3,d1
	beq.s	t_32e2
	subq	#1,d1
t_32dc:
	move.b	(a1)+,(a0)+
	dbra	d1,t_32dc
t_32e2:
	movea.l	(sp)+,a0
t_32e4:
	rts
;----------------------------------------------------------------------------
t_32e6:
	move.l	a0,-(sp)
	adda.l	d1,a0
	move.l	a0,d2
	btst	#0,d2
	beq.s	t_32fa
	subq.l	#1,d1
	bcs	t_33a2
	move.b	d0,-(a0)
t_32fa:
	move.b	d0,-(sp)
	move	(sp)+,d2
	move.b	d0,d2
	move	d2,d0
	swap	d2
	move	d0,d2
	move.l	d1,d0
	lsr.l	#8,d0
	lsr.l	#2,d0
	beq.s	t_3386
	movem.l	d1/d3-d7/a2-a6,-(sp)
	move.l	d2,d1
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5
	move.l	d2,d6
	move.l	d2,d7
	movea.l	d2,a1
	movea.l	d2,a2
	movea.l	d2,a3
	movea.l	d2,a4
	movea.l	d2,a5
	movea.l	d2,a6
t_332a:
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1-a6,-(a0)
	movem.l	d1-d7/a1/a2,-(a0)
	subq.l	#1,d0
	bne	t_332a
	movem.l	(sp)+,d1/d3-d7/a2-a6
	and	#$3ff,d1
t_3386:
	move	d1,d0
	lsr.w	#2,d0
	beq.s	t_3394
	subq	#1,d0
t_338e:
	move.l	d2,-(a0)
	dbra	d0,t_338e
t_3394:
	and	#3,d1
	beq.s	t_33a2
	subq	#1,d1
t_339c:
	move.b	d2,-(a0)
	dbra	d1,t_339c
t_33a2:
	movea.l	(sp)+,a0
	rts
;----------------------------------------------------------------------------
t_33a6:
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	t_33d6
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	t_33c0
	divu	d1,d0
	swap	d0
	clr.w	d0
	swap	d0
	rts
;----------------------------------------------------------------------------
t_33c0:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea.w	d0,a0
	move	d2,d0
	divu	d1,d0
	swap	d0
	move	a0,d0
	swap	d0
	rts
;----------------------------------------------------------------------------
t_33d6:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	clr.w	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
t_33e6:
	sub.l	a0,d1
	bcc.s	t_33ec
	add.l	a0,d1
t_33ec:
	addx.l	d0,d0
	addx.l	d1,d1
	dbra	d2,t_33e6
	not.w	d0
	rts
;----------------------------------------------------------------------------
t_33f8:
	move.l	d0,d2
	bpl.s	t_33fe
	neg.l	d0
t_33fe:
	eor.l	d1,d2
	movea.l	d2,a0
	tst.l	d1
	bpl.s	t_3408
	neg.l	d1
t_3408:
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	t_3432
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	t_3422
	mulu	d1,d0
	move.l	a0,d2
	bpl.s	t_3420
	neg.l	d0
t_3420:
	rts
;----------------------------------------------------------------------------
t_3422:
	mulu	d0,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	t_3430
	neg.l	d0
t_3430:
	rts
;----------------------------------------------------------------------------
t_3432:
	mulu	d1,d2
	swap	d2
	mulu	d1,d0
	add.l	d2,d0
	move.l	a0,d2
	bpl.s	t_3440
	neg.l	d0
t_3440:
	rts
;----------------------------------------------------------------------------
t_3442:
	move.l	d0,d2
	bpl.s	t_3448
	neg.l	d0
t_3448:
	eor.l	d1,d2
	movea.l	d2,a1
	tst.l	d1
	bpl.s	t_3452
	neg.l	d1
t_3452:
	move.l	d1,d2
	swap	d2
	tst.w	d2
	bne.s	t_348e
	move.l	d0,d2
	swap	d2
	tst.w	d2
	bne.s	t_3472
	divu	d1,d0
	swap	d0
	clr.w	d0
	swap	d0
	move.l	a1,d2
	bpl.s	t_3470
	neg.l	d0
t_3470:
	rts
;----------------------------------------------------------------------------
t_3472:
	clr.w	d0
	swap	d0
	swap	d2
	divu	d1,d0
	movea.w	d0,a0
	move	d2,d0
	divu	d1,d0
	swap	d0
	move	a0,d0
	swap	d0
	move.l	a1,d2
	bpl.s	t_348c
	neg.l	d0
t_348c:
	rts
;----------------------------------------------------------------------------
t_348e:
	movea.l	d1,a0
	swap	d0
	moveq	#0,d1
	move	d0,d1
	clr.w	d0
	moveq	#15,d2
	add.l	d0,d0
	addx.l	d1,d1
t_349e:
	sub.l	a0,d1
	bcc.s	t_34a4
	add.l	a0,d1
t_34a4:
	addx.l	d0,d0
	addx.l	d1,d1
	dbra	d2,t_349e
	not.w	d0
	move.l	a1,d2
	bpl.s	t_34b4
	neg.l	d0
t_34b4:
	rts
;----------------------------------------------------------------------------
Kbshift_fun:
	pea	(a2)
	move	d0,-(sp)
	move	#11,-(sp)
	trap	#13			 ;kbshift
	addq.w	#4,sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Bconout_fun:
	pea	(a2)
	move	d1,-(sp)
	move	d0,-(sp)
	move	#3,-(sp)
	trap	#13			 ;bconout
	addq.w	#6,sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Super_fun:
	pea	(a2)
	pea	(a0)
	move	#$20,-(sp)
	trap	#1			 ;super
	addq.w	#6,sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Mxalloc_fun:
	pea	(a2)
	move	d1,-(sp)
	move.l	d0,-(sp)
	move	#$44,-(sp)
	trap	#1			 ;mxalloc
	addq.w	#8,sp
	movea.l	d0,a0
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Mfree_fun:
	pea	(a2)
	pea	(a0)
	move	#$49,-(sp)
	trap	#1			 ;mfree
	addq.w	#6,sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Malloc_fun:
	pea	(a2)
	move.l	d0,-(sp)
	move	#$48,-(sp)
	trap	#1			 ;malloc
	addq.w	#6,sp
	movea.l	d0,a0
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Pexec_fun:
	pea	(a2)
	move.l	8(sp),-(sp)
	pea	(a1)
	pea	(a0)
	move	d0,-(sp)
	move	#$4b,-(sp)
	trap	#1			 ;pexec
	lea	$10(sp),sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
Supexec_fun:
	pea	(a2)
	pea	(a0)
	move	#$26,-(sp)
	trap	#14			 ;supexec
	addq.w	#6,sp
	movea.l	(sp)+,a2
	rts
;----------------------------------------------------------------------------
move_l_cookies_d0:
	move.l	(_cookies).w,d0
	rts
;----------------------------------------------------------------------------
t_354e:
	move.l	d3,-(sp)
	move.l	a2,-(sp)
	move.l	d0,d3
	movea.l	a0,a2
	lea	move_l_cookies_d0(pc),a0
	jsr	Supexec_fun
	movea.l	d0,a0
	move.l	a0,d0
	beq.s	t_357e
t_3566:
	cmp.l	(a0),d3
	bne.s	t_3576
	move.l	a2,d0
	beq.s	t_3572
	move.l	4(a0),(a2)	;store cookie value
t_3572:
	moveq	#1,d0		;flag success
	bra.s	t_3580
;
t_3576:
	addq.w	#8,a0
	move.l	-$8(a0),d0
	bne	t_3566
t_357e:
	clr.w	d0		;flag failure
t_3580:
	movea.l	(sp)+,a2
	move.l	(sp)+,d3
	rts
;----------------------------------------------------------------------------
	SECTION	DATA
;----------------------------------------------------------------------------
d_3586:
	dc.l	t_222
	dc.l	t_20f4
	dc.l	t_32e
	dc.l	t_342
	dc.l	t_386
	dc.l	t_508
	dc.l	t_516
	dc.l	t_13a
	dc.l	t_558
	dc.l	t_566
	dc.l	t_5a8
	dc.l	t_64a
	dc.l	t_694
	dc.l	t_6dc
	dc.l	t_826
	dc.l	t_724
	dc.l	t_88c
	dc.l	t_944
	dc.l	t_a96
	dc.l	t_adc
	dc.l	t_bb2
	dc.l	t_c08
	dc.l	t_e08
	dc.l	t_e70
	dc.b	'JRCD'
;----------------------------------------------------------------------------
d_35ea:
	dc.l	t_fc0
	dc.l	t_213a
	dc.l	t_32e
	dc.l	t_1012
	dc.l	t_3f8
	dc.l	t_1646
	dc.l	t_516
	dc.l	t_13a
	dc.l	t_1646
	dc.l	t_169c
	dc.l	t_1050
	dc.l	t_10b6
	dc.l	t_694
	dc.l	t_6d8
	dc.l	t_1150
	dc.l	t_10fe
	dc.l	t_11c0
	dc.l	t_944
	dc.l	t_12d6
	dc.l	t_ad8
	dc.l	t_bae
	dc.l	t_c04
	dc.l	t_e04
	dc.l	t_13c0
	dc.b	'JRCD'
;----------------------------------------------------------------------------
d_364e:
	dc.l	t_222
	dc.l	t_20f4
	dc.l	t_171a
	dc.l	t_16a8
	dc.l	t_178c
	dc.l	t_508
	dc.l	t_516
	dc.l	t_183e
	dc.l	t_558
	dc.l	t_566
	dc.l	t_5a8
	dc.l	t_64a
	dc.l	t_694
	dc.l	t_6dc
	dc.l	t_826
	dc.l	t_724
	dc.l	t_88c
	dc.l	t_944
	dc.l	t_a96
	dc.l	t_adc
	dc.l	t_bb2
	dc.l	t_c08
	dc.l	t_e08
	dc.l	t_e70
	dc.b	'JRCD'
;----------------------------------------------------------------------------
d_36b2:
	dc.l	t_222
	dc.l	t_20f4
	dc.l	t_32e
	dc.l	t_342
	dc.l	t_3f8
	dc.l	t_508
	dc.l	t_516
	dc.l	t_136
	dc.l	t_558
	dc.l	t_566
	dc.l	t_5a8
	dc.l	t_64a
	dc.l	t_694
	dc.l	t_1c68
	dc.l	t_1b3a
	dc.l	t_1bda
	dc.l	t_1880
	dc.l	t_944
	dc.l	t_19d2
	dc.l	t_ad8
	dc.l	t_bae
	dc.l	t_c04
	dc.l	t_e04
	dc.l	t_e70
	dc.b	'JRCD'
;----------------------------------------------------------------------------
d_3716:
	dc.l	t_222
	dc.l	t_20f4
	dc.l	t_32e
	dc.l	t_342
	dc.l	t_386
	dc.l	t_508
	dc.l	t_516
	dc.l	t_1d0c
	dc.l	t_558
	dc.l	t_566
	dc.l	t_5a8
	dc.l	t_64a
	dc.l	t_694
	dc.l	t_6dc
	dc.l	t_826
	dc.l	t_724
	dc.l	t_88c
	dc.l	t_944
	dc.l	t_a96
	dc.l	t_adc
	dc.l	t_bb2
	dc.l	t_c08
	dc.l	t_e08
	dc.l	t_e70
	dc.b	'JRCD'
;----------------------------------------------------------------------------
d_377a:
	dc.w	0
d_377c:
	dcb.b	6,0
d_3782:
	dc.b	$3,$0,$0,$0,$12,$0
d_3788:
	dc.b	$12,$0,$0,$0,$ff,$0,$12,$0,$0,$0,$ff,$0,$1f
	dc.b	$12,$0,$0,$0,$ff,$0
d_379b:
	dc.b	$15,$10,$0,$0,$0,$0
d_37a1:
	dc.b	$8,$0,$0,$0,$0,$0
d_37a7:
	dc.b	$18,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
scsidrv_fname_s_arr:
	dc.b	'\auto\scsidrv.prx',$0
	dc.b	'\auto\scsidrv.prg',$0
	dc.b	'\auto\mm_scsi.prx',$0
	dc.b	'\auto\mm_scsi.prg',$0
scsidrv_fname_slen	equ	(((*-scsidrv_fname_s_arr)/4)-1)
d_37fa:
	dc.b	' SCSI driver not present',CR,LF,NUL
	even
d_3816:
	dc.b	$0,$0,$0,$0,$0,$1
d_381c:
	dc.b	$0,$0,$0,$0,$0,$0,$0,$0
;----------------------------------------------------------------------------
BOS_init_p:
	dc.l	BOS_Init_fun
BOS_func_t:
	dc.l	-1		;Metainit
	dc.l	Metaopen_fun	;Metaopen
	dc.l	E_OK_sub	;Metaclose
	dc.l	Metaread_fun	;Metaread
	dc.l	E_UNCMD_sub	;Metawrite
	dc.l	E_OK_sub	;Meta func  5
	dc.l	Metastatus_fun	;Metastatus
	dc.l	Metaioctl_fun	;Metaioctl
	dc.l	E_OK_sub	;Meta func  8
	dc.l	E_UNCMD_sub	;Meta func  9
	dc.l	E_UNCMD_sub	;Meta func 10
	dc.l	Metastartaudio_fun
	dc.l	Metastopaudio_fun
	dc.l	Metasetsongtime_fun
	dc.l	Metagettoc_fun
	dc.l	Metadiscinfo_fun
;----------------------------------------------------------------------------
d_3868:
	dc.b	' ACSI #.$: ',$0
d_3874:
	dc.b	' ACSI #.$: ',$0
d_3880:
	dc.b	' IDE',$0
abort_Alternate_s:
	dc.b	' Alternate pressed; installation aborted'
d_38ad:
	dc.b	$A,$0
d_38af:
	dc.b	'not enough memory for buffers',$A,$0
d_38ce:
	dc.b	'unit not responding to TEST UNIT READY',$A
	dc.b	$0
d_38f6:
	dc.b	'unit not responding to INQUIRY',$A,$0
MATSHITAPD_1_s:
	dc.b	'MATSHITAPD-1',$0
unit_not_a_CD_ROM_s:
	dc.b	'unit not a CD-ROM',$A,$0
not_enough_memory_s:
	dc.b	'Not enough memory',$A,$0
BOS_driver_name_s:
	dc.b	'SPIN! /SD 0.34',$0
d_3958:
	dc.b	'ROM :1: ',$0
TOSHIBA_s:
	dc.b	'TOSHIBA ',$0
SONY_s:
	dc.b	'SONY    ',$0
PLEXTOR_s:
	dc.b	'PLEXTOR ',$0
SONY_CDU_8002_s:
	dc.b	'SONY    CD-ROM CDU-8002',$0
crack_ARG_s:
	dc.b	'ARG!',$A,$0
XHDI_parenth_s:
	dc.b	' (XHDI)',$0
	dc.b	'@(#)spin_sd.bos 0.34, Copyright (c) Julian F. Reschke, Nov  4 1997',$0
init_mess_s:
	dc.b	ESC,'p'
	dc.b	' SPIN! /SD 0.34 ',ESC,'q',CR,LF,NUL
	even
d_39fc:
	dc.b	$0,$0,$0,$0,$0,$0
;----------------------------------------------------------------------------
	SECTION	BSS
;----------------------------------------------------------------------------
scsidrv_p:
	ds.l	1
b_3a06:
	ds.w	9			 ;=18
b_3a18:
	ds.l	1			 ;=4
b_3a1c:
	ds.w	1			 ;=2
b_3a1e:
	ds.l	18			 ;=72
old_XHDI_p:
	ds.w	53			 ;=106
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	BD_CDBOS.S
;----------------------------------------------------------------------------
