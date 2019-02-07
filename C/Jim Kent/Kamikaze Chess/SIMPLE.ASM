
;:ts=12
	public _stuff_words
	;stuff_words(buf, what, count)
_stuff_words
	move.l	4(sp),a0
	move.w	8(sp),d0
	move.w	10(sp),d1
	bra	zstuffw
stuffw	move.w	d0,(a0)+
zstuffw	dbra	d1,stuffw
	rts

	public _clear_bytes
	;clear_bytes(buf, count)
_clear_bytes
	move.l	4(sp),a0
	move.w	8(sp),d0
	move.b	#0,d1
	bra	zcb
cb	move.b	d1,(a0)+
zcb	dbra	d0,cb
	rts

	public _iabs
	;iabs(val)	- integer absolute value
_iabs
	move.w	4(sp),d0
	bpl	iret
	neg.w	d0
iret	rts

	;	word_zero(pt, count)
	;		zero out count # of words starting at pt
	public _word_zero
_word_zero
	move.l	4(sp),a0
	move.w	8(sp),d0
	move.w	#0,d1
	bra wzz
wzlp	move.w	d1,(a0)+
wzz	dbra	d0,wzlp
	rts

	public _zero_structure
_zero_structure
	asr.w	8(sp)
	bra	_word_zero


	public _copy_structure
	; copy_structure(s, d, bytes)
	;	basically a word copy.  Bytes must be even as
	;	must be s and d
_copy_structure
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	lsr.w	#1,d0	; bytecount to wordcount
	bra	zcpstrc
cpstrc	move.w	(a0)+,(a1)+
zcpstrc	dbra	d0,cpstrc
	rts

