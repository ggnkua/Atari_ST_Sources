
	public _cscreen
	public _iconvtab


	; conv_1	-	take 4 words and make them into 16 bytes byte-a-pixel
	public conv_1
conv_1	
	; first test for all zeroes - this happens a lot and is easy
	move.l	(a1),d3
	or.l	4(a1),d3
	bne	doconv
	adda	#8,a1
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+

	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+

	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+

	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	move.b	d3,(a0)+
	rts

	;trash all data regs except d0 and d1
doconv
	move.w (a1)+,d3
	move.w (a1)+,d4
	move.w (a1)+,d5
	move.w (a1)+,d6
	move.w #15,d7
conv_loop
	clr.b d2
	lsl.w	#1,d6
	roxl.b #1,d2
	lsl.w	#1,d5
	roxl.b	#1,d2
	lsl.w	#1,d4
	roxl.b	#1,d2
	lsl.w	#1,d3
	roxl.b	#1,d2
    move.b d2,(a0)+
	dbra d7,conv_loop
	rts


	;	conv_buf(inbuf, outbuf, words)
	;		convert words*16  # of pixels from interleave to byte-a-pixel
	public _conv_buf
_conv_buf
	move.l 4(sp),a1
	move.l 8(sp),a0
	move.w 12(sp),d1
	movem.l D2/D3/D4/D5/D6/D7,-(A7) ; save the world
	bra clnz
cln_lp	bsr conv_1
clnz dbra	d1,cln_lp
	movem.l (A7)+,D2/D3/D4/D5/D6/D7
	rts


	;	iconv_buf(inbuf, outbuf, words)
	;		iconvert words*16  # of pixels from byte-a-pixel to interleave
	public _iconv_buf
_iconv_buf
	move.l 4(sp),a0
	move.l 8(sp),a1
	move.w 12(sp),d1
	movem.l d2/d3/a2/a3,-(A7) ; save the world
	move.l	#_iconvtab,a2
	bra iclnz
icln_lp	
	move.l	(a0),d2
	bne		icnonzero
	move.l	4(a0),d3
	bne icnonzero
	move.l	8(a0),d3
	bne icnonzero
	move.l	12(a0),d3
	bne icnonzero
	adda.w	#16,a0
	bra		storeic
icnonzero
	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	move.l	(a3)+,d2
	move.l	(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	1*8*16+0(a3),d2
	or.l	1*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	2*8*16+0(a3),d2
	or.l	2*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	3*8*16+0(a3),d2
	or.l	3*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	4*8*16+0(a3),d2
	or.l	4*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	5*8*16+0(a3),d2
	or.l	5*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	6*8*16+0(a3),d2
	or.l	6*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	7*8*16+0(a3),d2
	or.l	7*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	8*8*16+0(a3),d2
	or.l	8*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	9*8*16+0(a3),d2
	or.l	9*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	10*8*16+0(a3),d2
	or.l	10*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	11*8*16+0(a3),d2
	or.l	11*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	12*8*16+0(a3),d2
	or.l	12*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	13*8*16+0(a3),d2
	or.l	13*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	14*8*16+0(a3),d2
	or.l	14*8*16+4(a3),d3

	clr.w	d0
	move.b	(a0)+,d0
	lsl.w	#3,d0	; 8 bytes per iconvtab entry
	lea		0(a2,d0.w),a3
	or.l	15*8*16+0(a3),d2
	or.l	15*8*16+4(a3),d3

storeic
	move.l	d2,(a1)+
	move.l	d3,(a1)+

iclnz dbra	d1,icln_lp
	movem.l (A7)+,d2/d3/a2/a3
	rts



