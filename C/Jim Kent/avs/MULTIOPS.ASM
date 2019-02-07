	; :ts=10

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

	;words_same(w1, w2, count)
	;	see if count words are the same
	public _words_same
_words_same
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	bra	zws
ws	cmp.w	(a0)+,(a1)+
	bne	wdiff
zws	dbra	d0,ws
	rts
wdiff	clr.w	d0
	rts



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

	;stuff_words(d, value, count)
	;WORD *d;
	;WORD value;
	;WORD count;
	;
	;stuff value into d count times
	public	_stuff_words
_stuff_words move.l	4(sp),a0
	move.w	8(sp),d0
	move.w	10(sp),d1
	bra	zstf
stf	move.w	d0,(a0)+
zstf	dbra	d1,stf
	rts

	public _copy_lots
	; copy_lots(s, d, bytes)
	;	a copy especially good for more than 10K at a time
_copy_lots
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	12(sp),d0
	move.l	d0,d1
	lsr.l	#5,d1
	cmp.l	a0,a1
	ble	zcl_forz
	add.l	d0,a0
	add.l	d0,a1
	bra	zclbk
clbk	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
zclbk	subq.l	#1,d1
	bpl	clbk
	and.w	#31,d0
	lsr.w	#1,d0
	bra	zlclbk
lclbk	move.w	-(a0),-(a1)
zlclbk	dbra	d0,lclbk
	rts
cl_forz	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
zcl_forz	subq.l	#1,d1
	bpl	cl_forz
	and.w	#31,d0
	lsr.w	#1,d0
	bra	zlclf
lclf	move.w	(a0)+,(a1)+
zlclf	dbra	d0,lclf
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

