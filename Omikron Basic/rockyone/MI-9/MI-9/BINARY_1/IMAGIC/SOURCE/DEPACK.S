;Imagic image decompressoion code for PureC
;code taken from Imagic demo -> denisdem.prg
;size of unpacked data is always 32000 bytes (st resolutions)
;dis-assembled and modified by Lonny Pursell

;note: after processing the 64 byte header, call this subroutine
;      thus source address would be start of file + 64

;extern cdecl depack_icx(void *src, void *dst);

SRC_ADR	= (15*4)+4	;a0
DST_ADR	= (15*4)+8	;a1
			;d6 = bitmap size in bytes

	;used d0,d1,d2,d3,d4,d5,d7	a3,a4,a5,a6
	;not used: a2

	.export	depack_icx

	.text

MODULE	depack_icx:

L176170:;link	a2,#-8
	movem.l	d0-d7/a0-a6,-(sp)	;+
	movea.l	SRC_ADR(sp),a0		;+
	movea.l	DST_ADR(sp),a1		;+
	move.l	#32000,d6		;+
	move.l	a1,start_adr
	movea.l	a1,a3
	adda.w	d6,a3
	move.l	a3,end_adr
	moveq	#0,d1
	moveq	#0,d2
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d7
	mulu.w	#80,d2
	cmpi.b	#255,d1
	bne.s	L176212
	move.w	d6,d1
	move.w	#1,d2
L176212:movea.w	d2,a4
	move.w	d2,d6
	subq.w	#1,d6
	move.w	d1,d5
	subq.w	#1,d5
	movea.w	d5,a3
	neg.w	d1
	muls	d2,d1
	addq.l	#1,d1
	movea.l	d1,a5
	muls	d5,d2
	movea.l	d2,a6
	moveq	#1,d1
	moveq	#3,d2
	moveq	#2,d4
	moveq	#0,d0
L176244:move.b	(a0)+,d0
	cmp.b	d0,d7
	beq.s	L176290
L176250:cmpa.l	start_adr,a1
	bmi	L176428
	cmpa.l	end_adr,a1
	bpl	L176428
	move.b	d0,(a1)
	adda.l	a4,a1
	dbf	d5,L176244
	move.w	a3,d5
	adda.l	a5,a1
	dbf	d6,L176244
	move.w	a4,d6
	subq.w	#1,d6
	adda.l	a6,a1
	bra.s	L176244

L176290:move.b	(a0)+,d0
	cmp.b	d0,d7
	beq.s	L176250
	moveq	#0,d3
	cmp.w	d2,d0
	bpl.s	L176374
	cmp.b	d4,d0
	bne.s	L176360
	move.b	(a0)+,d0
	beq.s	L176428
	cmp.w	d2,d0
	bpl.s	L176332
	cmp.b	d4,d0
	beq.s	L176420
L176318:cmp.b	d1,d0
	bne.s	L176330
	addi.w	#256,d3
	move.b	(a0)+,d0
	bra.s	L176318

L176330:move.b	(a0)+,d0
L176332:add.w	d0,d3
L176334:adda.l	a4,a1
	dbf	d5,L176354
	move.w	a3,d5
	adda.l	a5,a1
	dbf	d6,L176354
	move.w	a4,d6
	subq.w	#1,d6
	adda.l	a6,a1
L176354:dbf	d3,L176334
	bra.s	L176244

L176360:cmp.b	d1,d0
	bne.s	L176372
	addi.w	#256,d3
	move.b	(a0)+,d0
	bra.s	L176360

L176372:move.b	(a0)+,d0
L176374:add.w	d0,d3
	move.b	(a0)+,d0
L176378:cmpa.l	start_adr,a1
	bmi.s	L176428
	cmpa.l	end_adr,a1
	bpl.s	L176428
	move.b	d0,(a1)
	adda.l	a4,a1
	dbf	d5,L176412
	move.w	a3,d5
	adda.l	a5,a1
	dbf	d6,L176412
	move.w	a4,d6
	subq.w	#1,d6
	adda.l	a6,a1
L176412:dbf	d3,L176378
	bra	L176244

L176420:move.b	(a0)+,d0
	beq	L176244
	bra.s	L176420

L176428:;unlk	a2
	movem.l	(sp)+,d0-d7/a0-a6	;+
	rts

	;.data

start_adr:	dc.l	0
end_adr:	dc.l	0

	.end

ENDMOD
