;File name:	PFX_21.S		Revised:	1992.08.24
;Disassembler:	Ulf Ronald Andersson	Disassembled:	1992.08.24
;
;NB: This code has the following severe bugs:
;NB:	It calls AES functions when not being a GEM program.
;NB:	It calls AES functions without using appl_init.
;NB:	Having used AES functions it does not exit with appl_exit,
;NB:	but this would crash anyway, in the abscence of appl_init.
;
;
	include	TOS\URAn_SYS.S
	include	TOS\URAn_DOS.S
;
;
	text
;
PFX_21_code:
.L0:
	bra.b	.L42
;
;
.L2:
	dc.b	"LArc's PFX 2.1P ½1990-1992 ä-soft, Markus Fritze, Thomas Quester"
;
;
.L42:
	move.l	a0,d0
	beq.b	.L4C
	move.l	4(a0),sp
	bra.b	.L50
;
;
.L4C:
	move.l	4(sp),d0
.L50:
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,a5
	move.l	24(a5),a1
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$3FE,d5
	move.l	8(a5),a6
	move.l	a1,a5
	lea	192(a5),a0
	lea	0(a5),a1
	move.l	a1,(a0)+
	lea	32(a5),a1
	move.l	a1,(a0)+
	lea	64(a5),a1
	move.l	a1,(a0)+
	lea	96(a5),a1
	move.l	a1,(a0)+
	lea	128(a5),a1
	move.l	a1,(a0)+
	lea	160(a5),a1
	move.l	a1,(a0)+
	lea	0(a5),a0
	move.l	#$780000,(a0)+
	move.l	#$10002,(a0)+
	clr	(a0)
	lea	128(a5),a0
	lea	232(a5),a1
	move.l	a1,(a0)+
	lea	360(a5),a1
	move.l	a1,(a0)+
	lea	192(a5),a0
	move.l	a0,d1
	move.l	#$C8,d0
	trap	#2
	gemdos	Fopen,232(a5),!
	tst.l	d0
	bmi	.L214
	move	d0,d7
	lea	488(a5),a0
	pea	488(a5)
	move.l	d5,-(sp)
	addi.l	#$1C,(sp)
	gemdos	Fread,d7,(),()
	gemdos	Fclose,d7
	lea	488(a5),a0
	lea	.L148(pc),a1
	cmpi	#$601A,(a0)
	bne	.L1D2
	lea	28(a0),a0
	subq.l	#1,d5
	moveq	#0,d4
	moveq	#0,d6
	movem.l	d5/a0/a6,-(sp)
	lsr.w	#1,d5
	subq	#2,d5
.L120:
	add	(a0)+,d4
	add	(a6)+,d6
	dbra	d5,.L120
	movem.l	(sp)+,d5/a0/a6
.L12C:
	cmpm.b	(a0)+,(a6)+
	bne	.L1D2
	dbra	d5,.L12C
	lea	.L17F(pc),a1
	cmp.l	#$94CA,d4
	bne	.L1D2
	bra	.L214
;
;
.L148:
	dc.b	'[3]'
	dc.b	'[I am probably|infected by a virus]'
	dc.b	'[abort|continue]',NUL
;
.L17F:
	dc.b	'[3]'
	dc.b	'[Checksum-mismatch, I am either|patched or infected by|a virus]'
	dc.b	'[abort|continue]',NUL
;
;
.L1D2:
	lea	0(a5),a0
	move	#$7B,d0
	move.l	#$340001,(a0)+
	move.l	#$10001,(a0)+
	clr	(a0)+
	move.l	a1,a0
	move.l	a0,128(a5)
	move	#$1,64(a5)
	lea	192(a5),a0
	move.l	a0,d1
	move	#$C8,d0
	trap	#2
	move	96(a5),d0
	cmp	#$1,d0
	bne.b	.L214
	gemdos	Pterm0
;
;
	add.l	#$FFFF6B36,d0
.L214:
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	4(a5),a0
	lea	-1024(a0),a0
	move.l	a0,a2
	move.l	20(a5),d0
.L226:
	move.l	a0,a4
	suba.l	d0,a4
	lsr.l	#4,d0
.L22C:
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
.L230:
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	subq.l	#1,d0
	bpl.b	.L22C
.L238:
	move.l	a2,a0
	lea	.L248(pc),a1
	moveq	#108,d0
.L240:
	move.l	(a1)+,(a0)+
	dbra	d0,.L240
	jmp	(a2)
;
.L248:
	movep.w	14(a4),d4
	move.b	13(a4),d4
	swap	d4
	movep.w	12(a4),d4
	move.b	11(a4),d4
	moveq	#2,d0
	add.b	(a4),d0
	adda	d0,a4
	move.l	8(a5),a6
	move	#$FED,d5
	move	d5,d0
	moveq	#32,d1
.L26C:
	move.b	d1,(a6)+
	dbra	d0,.L26C
	move.l	a6,a3
	moveq	#0,d7
	move.l	a6,d5
	sub.l	#$FED,d5
	move	#$FFF,d3
	dbra	d7,.L28A
.L286:
	move.b	(a4)+,d6
	moveq	#7,d7
.L28A:
	lsr.b	#1,d6
	bcc.b	.L29A
	move.b	(a4)+,(a6)+
	subq.l	#1,d4
	ble.b	.L2CE
	dbra	d7,.L28A
	bra.b	.L286
;
.L29A:
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
.L2BE:
	move.b	(a0)+,(a6)+
	dbra	d1,.L2BE
	sub.l	d0,d4
	ble.b	.L2CE
	dbra	d7,.L28A
	bra.b	.L286
;
.L2CE:
	move.l	8(a5),d3
	lea	.L3F8+2(pc),a0
	move.l	d3,(a0)
	movem.l	2(a3),d4-d7
	lea	28(a3),a0
	move.l	a0,a4
	tst	26(a3)
	bne.b	.L310
	lea	0(a0,d4.l),a1
	adda.l	d5,a1
	adda.l	d7,a1
	move.l	(a1)+,d1
	beq.b	.L310
	adda.l	d1,a0
	moveq	#0,d1
.L2FA:
	add.l	d3,(a0)
.L2FC:
	move.b	(a1)+,d1
	beq.b	.L310
	cmp.b	#1,d1
	bne.b	.L30C
	lea	254(a0),a0
	bra.b	.L2FC
.L30C:
	adda	d1,a0
	bra.b	.L2FA
;
.L310:
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
.L344:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	subq.l	#1,d4
	bpl.b	.L344
	move.l	24(a5),a0
	adda.l	28(a5),a0
	tst.b	d1
	bne.b	.L360
	lea	.L38A(pc),a0
.L360:
	move.l	a0,d0
	sub.l	24(a5),d0
	move.l	d0,d1
	lsr.l	#7,d0
	lsr.l	#3,d0
	beq.b	.L3E0
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
.L38A:
	rept	19
	movem.l	d1-d7/a1-a6,-(a0)
	endr
	movem.l	d1-d7/a1-a2,-(a0)
	subq.l	#1,d0
	bne.b	.L38A
	move.l	(sp)+,d1
.L3E0:
	and	#$3FF,d1
	bra.b	.L3E8
;
.L3E6:
	clr.b	-(a0)
.L3E8:
	dbra	d1,.L3E6
	movem.l	(sp)+,d1-d7/a0-a6
	move.l	a0,d0
	beq.b	.L3F8
	suba.l	sp,sp
	moveq	#0,d0
.L3F8:
	jmp	$DEADFACE.l
PFX_21_end:
;
	end
