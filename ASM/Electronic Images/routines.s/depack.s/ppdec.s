
;-- Hi... Ive made a change that allows you to use any crunch efficiency...

;-- Erm I think I ought to explain what you need to pass
;-- to this routine in the registers because its a bit unclear:

;-- a0 = Pointer to longword AFTER crunched file
;-- a3 = Pointer to destination
;-- a5 = Pointer to 'efficiency' longword, which is the second
;        longword in the crunched data file.

;-- I think thats all... If it doesnt work gimme a call...
;							[ Dave ] 
	
Decrunch:
	moveq #3,d6
	moveq #7,d7
	moveq #1,d5
	move.l a3,a2			; remember start of file
	move.l -(a0),d1			; get file length and empty bits
	tst.b d1
	beq.s NoEmptyBits
	bsr.s ReadBit			; this will always get the next long (D5 = 1)
	subq.b #1,d1
	lsr.l d1,d5			; get rid of empty bits
NoEmptyBits:
	lsr.l #8,d1
	add.l d1,a3			; a3 = endfile
LoopCheckCrunch:
	bsr.s ReadBit			; check if crunch or normal
	bcs.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #1,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w d6,d1
	beq.s Read2BitsRow
ReadNormalByte:
	moveq #7,d0
	bsr.s ReadD1
	move.b d1,-(a3)
	dbf d2,ReadNormalByte
	cmp.l a3,a2
	bcs.s CrunchedBytes
	rts
ReadBit:
	lsr.l #1,d5			; this will also set X if d5 becomes zero
	beq.s GetNextLong
	rts
GetNextLong:
	move.l -(a0),d5
	roxr.l #1,d5			; X-bit set by lsr above
	rts
ReadD1sub:
	subq.w #1,d0
ReadD1:
	moveq #0,d1
ReadBits:
	lsr.l #1,d5			; this will also set X if d5 becomes zero
	beq.s GetNext
RotX:
	roxl.l #1,d1
	dbf d0,ReadBits
	rts
GetNext:
	move.l -(a0),d5
	roxr.l #1,d5			; X-bit set by lsr above
	bra.s RotX
CrunchedBytes:
	moveq #1,d0
	bsr.s ReadD1			; read code
	moveq #0,d0
	move.b 0(a5,d1.w),d0		; get number of bits of offset
	move.w d1,d2			; d2 = code = length-2
	cmp.w d6,d2			; if d2 = 3 check offset bit and read length
	bne.s ReadOffset
	bsr.s ReadBit			; read offset bit (long/short)
	bcs.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1sub
	move.w d1,d3			; d3 = offset
Read3BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2			; d2 = length-1
	cmp.w d7,d1			; cmp with #7
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1sub			; read offset
	move.w d1,d3			; d3 = offset
DecrunchBlock:
	addq.w #1,d2
DecrunchBlockLoop:
	move.b 0(a3,d3.w),-(a3)
	dbf d2,DecrunchBlockLoop
EndOfLoop:
	cmp.l a3,a2
	bcs.s LoopCheckCrunch
	rts
