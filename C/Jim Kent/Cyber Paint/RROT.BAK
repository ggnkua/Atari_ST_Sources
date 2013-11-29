;	:ts=10
	public	_iconv_buf

		;iconv_buf(pixel_buf, image, pixels16);

	;bap_rrot(source, sline_bytes, dest, dline_bytes, segments, lines,
	;	bap_buf);
	;	raster rotate on byte-a-pixel source to 
	;	word-interleaved bit-map dest using bap_buf
	;	(byte-a-pixel line buffer )
firstp	set	8*4+4+10
source	set	firstp
sline_bytes set	firstp+4
dest	set	firstp+6
dline_bytes set	firstp+10
segments	set	firstp+12
lines	set	firstp+16
bap_buf	set	firstp+18
	public _bap_rrot
_bap_rrot
	movem.l	d3/d4/d5/d6/d7/a2/a3/a4,-(sp)
	suba.w	#10,sp	/* make room for iconv_buf parameters & locals*/
	move.l	source(sp),a2
	move.l	bap_buf(sp),a3
	move.l	segments(sp),a4
	move.w	dline_bytes(sp),d1
	lsr.w	#3,d1	; convert from line-bytes to pixel16
	move.w	d1,8(sp)	; set up loop invarient pixels16 iconv parameter
	move.l	a3,(sp)	; set up byte-a-pixel iconv parameter
	move.l	dest(sp),4(sp)	; set up initial bitplane iconv param.
lineloop	subq.w	#1,lines(sp)
	bmi	zlineloop

	move.l	a3,a1	; get ready to clear bap-dest
	move.w	8(sp),d1	; get pixels 16
	clr.l	d2	; and load up 4 bytes of zeroes
	bra	zbapclr
bapclr	move.l	d2,(a1)+	; and start clearing 4x4 = 16
	move.l	d2,(a1)+
	move.l	d2,(a1)+
	move.l	d2,(a1)+
zbapclr	dbra	d1,bapclr

	move.l	a2,a0	; set up source for inner loop
	move.l	a3,a1	; set up bap-dest for inner loop
	move.w	(a4)+,d1	; get x0 of source
	move.w	(a4)+,d2	; get y0 of source
calcdx
	move.w	#1,d6	; what to add to source when stepping x
	adda.w	d1,a0	; add x0 to initial source address
	sub.w	(a4)+,d1	; and subtract x1 of source
	bmi	calcdy	; d1 gets -|x1-x0| and adjust step x if positive
	neg.w	d1
	neg.w	d6
calcdy
	move.w	sline_bytes(sp),d7 ; what to add to source when stepping y
	move.w	d2,d3
	mulu	d7,d3
	add.l	d3,a0	     ; add y0 to initial source address
	sub.w	(a4)+,d2	; subtract y1 of source
	bmi	init_errors ; d2 gets -|y1-y0| and adjust step y if positive
	neg.w	d2
	neg.w	d7
init_errors
	add.w	(a4)+,a1	;  add xoffset to dest address
	move.w	(a4)+,d0   ; set up dest width register
	move.w	d0,d5	;    set up count register
	move.w	d1,d3
	asr.w	#1,d3
	add.w	d0,d3	;    xerr = count - dx/2
	move.w	d2,d4
	asr.w	#1,d4
	add.w	d0,d4	;    yerr = count - dy/2

	subq.w	#1,d1	;    line between 0 and 2 has 3 pixels...
	subq.w	#1,d2

	bra	zrrot_loop
rrot_loop
	move.b	(a0),(a1)+	; sometimes we even move a pixel....
	add.w	d1,d3
	bgt	znextx
nextx	adda.w	d6,a0
	add.w	d0,d3
	ble	nextx
znextx
	add.w	d2,d4
	bgt	zrrot_loop
nexty	adda.w	d7,a0
	add.w	d0,d4
	ble	nexty
zrrot_loop dbra	d5,rrot_loop
zrrot

	jsr	_iconv_buf
	move.w	dline_bytes(sp),d0
	ext.l	d0
	add.l	d0,4(sp)	; go to next line of dest
	bra	lineloop
zlineloop
	adda.w	#10,sp	;	clear off icon_buf parameters
	movem.l	(sp)+,d3/d4/d5/d6/d7/a2/a3/a4
	rts



