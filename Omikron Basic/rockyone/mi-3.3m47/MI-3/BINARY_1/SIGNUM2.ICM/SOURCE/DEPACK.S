;Signum! image decompressoion code for PureC
;code taken from Imagic demo -> denisdem.prg
;size of unpacked data is always 32000 bytes (st high resolution)
;dis-assembled and modified by Lonny Pursell

;note: destination buffer must be all 0's -> memset(dst, 0, 32000);
;      decompressor uses some kind of skip code, so ram cannot be dirty
;      after checking the 8 byte file id, call this subroutine
;      thus source address would be start of file + 8

;extern cdecl depack_imc(void *src, void *dst);

SRC_ADR	= (15*4)+4	;a0
DST_ADR	= (15*4)+8	;a1

	.export	depack_imc

	.text

MODULE	depack_imc:

L2AE2E:	movem.l	d0-d7/a0-a6,-(sp)	;+
	movea.l	SRC_ADR(sp),a0		;+
	movea.l	DST_ADR(sp),a1		;+
	moveq	#$50,d7			;+
	movea.l	a1,a2
	link	a4,#-$002E
	moveq	#$00,d5
	move.w	$0008(a0),-$0002(a4)
	move.w	$000A(a0),-$0004(a4)
	move.w	$0014(a0),-$0006(a4)
	movea.l	a0,a6
	lea 	$0020(a6),a6
	moveq	#$08,d6
	movea.l	a6,a5
	adda.l	$000C(a0),a5
	move.l	a2,-$000A(a4)
	move.w	d7,d4
	ext.l	d4
	asl.l	#4,d4
	move.w	-$0004(a4),d3
	bra	L2AE76

L2AE68:	bsr	L2AFB8
	bcc.s	L2AE72
	bsr	L2AE82
L2AE72:	add.l	d4,-$000A(a4)
L2AE76:	dbf	d3,L2AE68
	bsr	L2AFC4
	unlk	a4
	movem.l	(sp)+,d0-d7/a0-a6	;+
	rts

L2AE82:	move.l	d3,-(a7)
	move.l	-$000A(a4),-$000E(a4)
	move.w	-$0002(a4),d3
	bra	L2AEA0

L2AE92:	bsr	L2AFB8
	bcc.s	L2AE9C
	bsr	L2AEA8
L2AE9C:	addq.l	#2,-$000E(a4)
L2AEA0:	dbf	d3,L2AE92
	move.l	(a7)+,d3
	rts

L2AEA8:	movem.l	d3/a3,-(a7)
	moveq	#$00,d3
	bsr	L2AFB8
	bcc.s	L2AEB6
	addq.w	#2,d3
L2AEB6:	bsr	L2AFB8
	bcc.s	L2AEBE
	addq.w	#1,d3
L2AEBE:	cmpi.w	#$0003,d3
	beq	L2AF20
	bsr	L2AFA2
	lea 	-$002E(a4),a3
	bsr	L2AFB8
	bcc.s	L2AEDA
	movea.l	a3,a0
	bsr	L2AF42
L2AEDA:	addq.l	#1,a3
	bsr	L2AFB8
	bcc.s	L2AEE8
	movea.l	a3,a0
	bsr	L2AF42
L2AEE8:	lea 	$000F(a3),a3
	bsr	L2AFB8
	bcc.s	L2AEF8
	movea.l	a3,a0
	bsr	L2AF42
L2AEF8:	addq.l	#1,a3
	bsr	L2AFB8
	bcc.s	L2AF06
	movea.l	a3,a0
	bsr	L2AF42
L2AF06:	cmpi.w	#$0001,d3
	beq.s	L2AF14
	cmpi.w	#$0002,d3
	beq.s	L2AF1A
	bra.s	L2AF24

L2AF14:	bsr	L2AF56
	bra.s	L2AF24

L2AF1A:	bsr	L2AF6A
	bra.s	L2AF24

L2AF20:	bsr	L2AF2E
L2AF24:	bsr	L2AF7E
	movem.l	(a7)+,d3/a3
	rts

L2AF2E:	lea 	-$002E(a4),a0
	moveq	#$07,d0
L2AF34:	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	move.b	(a5)+,(a0)+
	dbf	d0,L2AF34
	rts

L2AF42:	move.b	(a5)+,d1
	beq.s	L2AF54
	moveq	#$07,d0
L2AF48:	add.b	d1,d1
	bcc.s	L2AF4E
	move.b	(a5)+,(a0)
L2AF4E:	addq.l	#2,a0
	dbf	d0,L2AF48
L2AF54:	rts

L2AF56:	lea 	-$002E(a4),a0
	move.w	(a0)+,d0
	moveq	#$0E,d2
L2AF5E:	move.w	(a0),d1
	eor.w	d1,d0
	move.w	d0,(a0)+
	dbf	d2,L2AF5E
	rts

L2AF6A:	lea 	-$002E(a4),a0
	move.l	(a0)+,d0
	moveq	#$06,d2
L2AF72:	move.l	(a0),d1
	eor.l	d1,d0
	move.l	d0,(a0)+
	dbf	d2,L2AF72
	rts

L2AF7E:	lea 	-$002E(a4),a0
	movea.l	-$000E(a4),a1
	move.w	d7,d1
	ext.l	d1
	moveq	#$03,d0
L2AF8C:	move.w	(a0)+,(a1)
	adda.l	d1,a1
	move.w	(a0)+,(a1)
	adda.l	d1,a1
	move.w	(a0)+,(a1)
	adda.l	d1,a1
	move.w	(a0)+,(a1)
	adda.l	d1,a1
	dbf	d0,L2AF8C
	rts

L2AFA2:	lea 	-$002E(a4),a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	rts

L2AFB8:	dbf	d5,L2AFC0
	moveq	#$07,d5
	move.b	(a6)+,d6
L2AFC0:	add.b	d6,d6
	rts

L2AFC4:	tst.w	-$0006(a4)
	bne.s	L2AFCC
	rts

L2AFCC:	movea.l	a2,a0
	clr.l	d0
	move.b	-$0006(a4),d0
	bsr	L2AFE8
	movea.l	a2,a0
	adda.w	d7,a0
	clr.l	d0
	move.b	-$0005(a4),d0
	bsr	L2AFE8
	rts

L2AFE8:	move.w	d0,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	-$0004(a4),d1
	asl.w	#3,d1
	bra	L2B00C

L2AFF8:	movea.l	a0,a1
	adda.w	d7,a0
	adda.w	d7,a0
	move.w	-$0002(a4),d2
	bra	L2B008

L2B006:	eor.w	d0,(a1)+
L2B008:	dbf	d2,L2B006
L2B00C:	dbf	d1,L2AFF8
	rts

	.end

ENDMOD


