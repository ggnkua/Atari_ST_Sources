;File name:	PFX_11.S		Revised:	1992.08.24
;Disassembler:	Ulf Ronald Andersson	Disassembled:	1992.08.24
;
	include	TOS\URAn_DOS.S
;
	text
;
	opt	o-
;
PFX_11_code:
.L0:
	bra.b	.L2E
;
;
.L2:
	dc.b	"LArc's PFX 1.13P ½1990 ä-soft, Markus Fritze"
.L2E:
	move.l	a0,d0			;d0-> ACC basepage  or  d0 == NULL
	beq.b	.L38			;go handle non_ACC
	move.l	bp_selfend_p(a0),sp	;sp = ACC bp_selfend_p
	bra.b	.L3C
;
.L38:
	move.l	4(sp),d0		;d0->non_ACC basepage
.L3C:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,a5			;a5-> basepage
	move.l	bp_bss_beg_p(a5),a1	;a1-> bss == end of data area
	move.l	bp_selfend_p(a5),a0
	lea	-1024(a0),a0
	move.l	a0,a2
	move.l	bp_datalen(a5),d0
	move.l	a0,a4
	suba.l	d0,a4
	lsr.l	#4,d0
.L5A:
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	subq.l	#1,d0
	bpl.b	.L5A
	move.l	a2,a0
	lea	.unpacker_start(pc),a1
	moveq	#(.unpacker_end-.unpacker_start)/4-1,d0
.L6E:	;moves code to high RAM, last is patch_adr so rounding is OK
	move.l	(a1)+,(a0)+
	dbra	d0,.L6E
	jmp	(a2)
;
;
;This block, from '.unpacker_start' to '.unpacker_end'
;is moved to high RAM before being run.
.unpacker_start:
	movep.w	14(a4),d4
	move.b	13(a4),d4
	swap	d4
	movep.w	12(a4),d4
.L84:
	move.b	11(a4),d4
	moveq	#2,d0
	add.b	(a4),d0
	adda	d0,a4
	move.l	8(a5),a6
	move	#$FED,d5
.L96:
	move	d5,d0
	moveq	#32,d1
.L9A:
	move.b	d1,(a6)+
	dbra	d0,.L9A
.LA0:
	move.l	a6,a3
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FED,d5
	move	#$FFF,d3
	dbra	d7,.LB8
.LB4:
	move.b	(a4)+,d6
	moveq	#7,d7
.LB8:
	lsr.b	#1,d6
	bcc.b	.LC8
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.b	.LFC
	dbra	d7,.LB8
	bra.b	.LB4
;
.LC8:
	movep.w	1(a4),d0
	lsr.w	#4,d0
	move.b	(a4)+,d0
	move.l	a6,d1
	sub.l	d5,d1
	and	d3,d1
	sub	d1,d0
	neg	d0
	and	d3,d0
	neg	d0
	lea	-1(a6,d0.w),a0
	moveq	#15,d1
	and.b	(a4)+,d1
	addq	#2,d1
	moveq	#1,d0
	add	d1,d0
.LEC:
	move.b	(a0)+,(a6)+
	dbra	d1,.LEC
	sub.l	d0,d4
	ble.b	.LFC
	dbra	d7,.LB8
	bra.b	.LB4
;
.LFC:
	move.l	8(a5),d3
	lea	.L226+2(pc),a0
	move.l	d3,(a0)
	movem.l	2(a3),d4-d7
	lea	28(a3),a0
	move.l	a0,a4
	tst	26(a3)
	bne.b	.L13E
	lea	0(a0,d4.l),a1
	adda.l	d5,a1
	adda.l	d7,a1
	move.l	(a1)+,d1
	beq.b	.L13E
	adda.l	d1,a0
	moveq	#0,d1
.L128:
	add.l	d3,(a0)
.L12A:
	move.b	(a1)+,d1
	beq.b	.L13E
	cmp.b	#1,d1
	bne.b	.L13A
	lea	254(a0),a0
	bra.b	.L12A
;
.L13A:
	adda	d1,a0
	bra.b	.L128
;
.L13E:
	move.l	d4,12(a5)
	move.l	d5,20(a5)
	move.l	d6,28(a5)
	move.l	d4,d7
	add.l	d5,d7
	lsr.l	#4,d7
	addq.l	#1,d7
	add.l	d3,d4
	move.l	d4,16(a5)
	add.l	d5,d4
	move.l	d4,24(a5)
	btst	#0,25(a3)
	sne	d1
	lea	28(a3),a1
	move.l	8(a5),a0
	sub.l	a0,d4
	lsr.l	#4,d4
.L172:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	subq.l	#1,d4
	bpl.b	.L172
	move.l	24(a5),a0
	adda.l	28(a5),a0
	tst.b	d1
	bne.b	.L18E
	lea	.L1B8(pc),a0
.L18E:
	move.l	a0,d0
	sub.l	24(a5),d0
	move.l	d0,d1
	lsr.l	#7,d0
	lsr.l	#3,d0
	beq.b	.L20E
	move.l	d1,-(sp)
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,a6
.L1B8:				;loop to clear 1 KByte per passage
	rept	19
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	movem.l	d1-d7/a1-a2,-(a0)
	subq.l	#1,d0
	bne.b	.L1B8		;loop back for each KByte to be cleared
	move.l	(sp)+,d1
.L20E:
	and	#$3FF,d1
	bra.b	.L216
;
.L214:				;loop to clear remainder < 1 KByte
	clr.b	-(a0)
.L216:
	dbra	d1,.L214	;loop back to clear < 1 KByte
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	a0,d0		;ACC ?
	beq.b	.L226		;go start non_ACC
	suba.l	sp,sp		;clear ACC sp
	moveq	#0,d0		;clear ACC d0
.L226:
	jmp	$DEADFACE.l	;Start unpacked program
.unpacker_end:
;
PFX_11_end:
;
;
	end	;of file:	PFX_11.S
