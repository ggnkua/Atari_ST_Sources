	movem.l	d0-a6,-(a7)

	move.l	64(a7),a5
	move.l	a1,a3

	moveq	#3,d6
	moveq	#7,d7
	moveq	#1,d5
	move.l	a3,a2		; remember start of file
	move.l	-(a0),d1	; get file length and empty bits
	tst.b	d1
	beq.s	.NoEmptyBits
	bsr.s	.ReadBit		; this will always get the next long (D5 = 1)
	subq.b	#1,d1
	lsr.l	d1,d5		; get rid of empty bits
.NoEmptyBits:
	lsr.l	#8,d1
	add.l	d1,a3		; a3 = endfile
.LoopCheckCrunch:
	bsr.s	.ReadBit		; check if crunch or normal
	bcs.s	.CrunchedBytes
.NormalBytes:
	moveq	#0,d2
.Read2BitsRow:
	moveq	#1,d0
	bsr.s	.ReadD1
	add.w	d1,d2
	cmp.w	d6,d1
	beq.s	.Read2BitsRow
.ReadNormalByte:
	moveq	#7,d0
	bsr.s	.ReadD1
	move.b	d1,-(a3)
	dbf	d2,.ReadNormalByte
	cmp.l	a3,a2
	bcs.s	.CrunchedBytes
	movem.l	(a7)+,d0-a6
	rts
.ReadBit:	lsr.l	#1,d5		; this will also set X if d5 becomes zero
	beq.s	.GetNextLong
	rts
.GetNextLong:
	move.l	-(a0),d5
	roxr.l	#1,d5		; X-bit set by lsr above
	rts
.ReadD1sub:
	subq.w	#1,d0
.ReadD1:	moveq	#0,d1
.ReadBits:
	lsr.l	#1,d5		; this will also set X if d5 becomes zero
	beq.s	.GetNext
.RotX:	roxl.l	#1,d1
	dbf	d0,.ReadBits
	rts
.GetNext:	move.l	-(a0),d5
	roxr.l	#1,d5		; X-bit set by lsr above
	bra.s	.RotX
.CrunchedBytes:
	moveq	#1,d0
	bsr.s	.ReadD1		; read code
	moveq	#0,d0
	move.b	0(a5,d1.w),d0	; get number of bits of offset
	move.w	d1,d2		; d2 = code = length-2
	cmp.w	d6,d2		; if d2 = 3 check offset bit and read length
	bne.s	.ReadOffset
	bsr.s	.ReadBit		; read offset bit (long/short)
	bcs.s	.LongBlockOffset
	moveq	#7,d0
.LongBlockOffset:
	bsr.s	.ReadD1sub
	move.w	d1,d3		; d3 = offset
.Read3BitsRow:
	moveq	#2,d0
	bsr.s	.ReadD1
	add.w	d1,d2		; d2 = length-1
	cmp.w	d7,d1		; cmp with #7
	beq.s	.Read3BitsRow
	bra.s	.decrunchBlock
.ReadOffset:
	bsr.s	.ReadD1sub		; read offset
	move.w	d1,d3		; d3 = offset
.decrunchBlock:
	addq.w	#1,d2
.decrunchBlockLoop:
	move.b	0(a3,d3.w),-(a3)
	dbf	d2,.decrunchBlockLoop
.EndOfLoop:
	cmp.l	a3,a2
	bcs	.LoopCheckCrunch
	rts

****************************************************************************

* pp_CalcCheckSum (char *);

.pp_calcchecksum:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
.sumloop:
	move.b (a0)+,d1
	beq.s .exitasm
	ror.w d1,d0
	add.w d1,d0
	bra.s .sumloop

* pp_CalcPasskey (char *);

._pp_CalcPasskey:
	move.l 4(a7),a0
	moveq #0,d0
	moveq #0,d1
.keyloop:
	move.b (a0)+,d1
	beq.s .exitasm
	rol.l #1,d0
	add.l d1,d0
	swap d0
	bra.s .keyloop
.exitasm:
	rts

* pp_Decrypt (UBYTE *, ULONG, ULONG);

._pp_Decrypt:
	move.l	4(a7),a0
	move.l	8(a7),d1
	move.l	12(a7),d0
	move.l	d2,-(a7)
	addq.l	#3,d1
	lsr.l	#2,d1
.encryptloop:
	move.l	(a0),d2
	eor.l	d0,d2
	move.l	d2,(a0)+
	subq.l	#1,d1
	bne.s	.encryptloop
	move.l	(a7)+,d2
	rts

