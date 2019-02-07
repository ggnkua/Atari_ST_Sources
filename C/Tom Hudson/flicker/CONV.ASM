
	public _cscreen


	; conv_1	-	take 4 words and make them into 16 bytes byte-a-pixel
	public conv_1
conv_1	
	; first test for all zeroes - this happens a lot and is easy
	move.l	(a1),d3
	bne	doconv
	move.l	4(a1),d3
	bne	doconv
	adda	#8,a1
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	move.l	d3,(a0)+
	rts

	;trash all data regs except d0 and d1
doconv
	move.w (a1)+,d3
	move.w (a1)+,d4
	move.w (a1)+,d5
	move.w (a1)+,d6
	move.w #15,d7
conv_loop
	clr.w d2
	asl #1,d3
	bcc co0
	or.w	#1,d2
co0	asl #1,d4
	bcc co1
	or.w	#2,d2
co1	asl #1,d5
	bcc co2
	or.w	#4,d2
co2	asl #1,d6
	bcc co3
	or.w	#8,d2
co3 move.b d2,(a0)+
	dbra d7,conv_loop
	rts


	; iconv_1   - inverse convert - take 16 bytes and put them into
	;	16 pixels in 4 words.
	public iconv_1
iconv_1
	; first test for all zero
	move.l	(a0),d3
	bne	doiconv
	move.l	4(a0),d3
	bne	doiconv
	move.l	8(a0),d3
	bne	doiconv
	move.l	12(a0),d3
	bne	doiconv
	move.l	d3,(a1)+
	move.l	d3,(a1)+
	adda	#16,a0
	rts

	; trash all registers except d1
doiconv
	move.w #15,d7
	move.w #$8000,d0
	clr.w d3
	move.w 	d3,d4
	move.w	d4,d5
	move.w	d5,d6
iconv_loop
	move.b (a0)+,d2
	asr	#1,d2
	bcc ic0
	or.w d0,d3
ic0	asr	#1,d2
	bcc ic1
	or.w d0,d4
ic1	asr	#1,d2
	bcc ic2
	or.w d0,d5
ic2 asr	#1,d2
	bcc ic3
	or.w d0,d6
ic3	lsr.w #1,d0
	dbra d7,iconv_loop
	move.w d3,(a1)+
	move.w d4,(a1)+
	move.w d5,(a1)+
	move.w d6,(a1)+
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
	movem.l D2/D3/D4/D5/D6/D7,-(A7) ; save the world
	bra iclnz
icln_lp	bsr iconv_1
iclnz dbra	d1,icln_lp
	movem.l (A7)+,D2/D3/D4/D5/D6/D7
	rts



