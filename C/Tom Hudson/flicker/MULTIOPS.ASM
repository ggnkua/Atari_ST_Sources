

	;	xbytes(bytes, xlator, count)
	;		run bytes through xlator table
	public _xbytes
_xbytes
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	bra	xllpz
xllp	move.w #0,d1
	move.b	(a0),d1
	move.b	0(a1,d1.w),(a0)+
xllpz	dbra d0,xllp
	rts



	;	word_zero(pt, count)
	;		zero out count # of words starting at pt
	public _word_zero
_word_zero
	move.l	4(sp),a0
	move.w	8(sp),d0
	move.w	#0,d1
	bra wzz
wzlp	move.w	d1,(a0)+
wzz		dbra	d0,wzlp
	rts



	;	copy_words(s, d, count)
	;		copy count # of words from s to d
	public _copy_words
_copy_words
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	bra	cpwz
cpw_lp	move.w	(a0)+,(a1)+
cpwz	dbra	d0,cpw_lp
	rts





	; copy_pointers(s, d, count)
	;	copy count # of pointer (long) values from s to d
	;	do it either forwards or backwards so don't overwrite self
	;	if coming from same buffer
	public _copy_pointers
_copy_pointers
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	cmp.l	a0,a1
	ble	cpt_forz
	move.l	#0,d1	; it's backwards so move pointers to end of buffer
	move.w	d0,d1	; do the arithmetic as longs cause the shift might
	lsl.l	#2,d1	; take count out of 16 bits.
	add.l	d1,a0
	add.l	d1,a1
	bra cpt_revz
cpt_rlp	move.l	-(a0),-(a1)
cpt_revz dbra	d0,cpt_rlp
	rts
cpt_flp	move.l	(a0)+,(a1)+
cpt_forz dbra	d0,cpt_flp
	rts

