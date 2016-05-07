
;	:ts=12

	public	_blur_out
	public	_unp_colors
	public	_clookup
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3

	;blur_line(count)
	;	do a box-filter average on blbuf1-3 into blur_out
	public	_blur_line
firstp	set	9*4+4
count	set	firstp
_blur_line
	movem.l	a2/a3/a4/a5/a6/d3/d4/d5/d6,-(sp)

;load up all globals into registers cause going to cannibalize a5 for scratch
	move.l	_blur_out,a0
	move.l	_blbuf1,a1
	move.l	_blbuf2,a2
	move.l	_blbuf3,a3
	move.l	#_clookup,a4
	move.l	#_unp_colors,a6
	move.w	count(sp),d6
	bra	zbll_loop
bll_loop

	clr.w	d0
	move.b	(a1)+,d0	; fetch upper left pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d1	; fetch r
	move.w	(a5)+,d2	; fetch g
	move.w	(a5)+,d3	; fetch b

	clr.w	d0
	move.b	(a1),d0	; fetch upper pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d1	; add 2x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d2	; add 2x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d3	; add 2x component to b

	clr.w	d0
	move.b	1(a1),d0	; fetch upper right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fold in r
	add.w	(a5)+,d2	; fold in g
	add.w	(a5)+,d3	; fold in b

	clr.w	d0
	move.b	(a2)+,d0	; fetch left pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d1	; add 2x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d2	; add 2x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d3	; add 2x component to b

	clr.w	d0
	move.b	(a2),d0	; fetch center pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d1	; add 4x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d2	; add 4x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d3	; add 4x component to b

	clr.w	d0
	move.b	1(a2),d0	; fetch right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d1	; add 2x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d2	; add 2x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d3	; add 2x component to b

	clr.w	d0
	move.b	(a3)+,d0	; fetch lower left pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fetch r
	add.w	(a5)+,d2	; fetch g
	add.w	(a5)+,d3	; fetch b

	clr.w	d0
	move.b	(a3),d0	; fetch lower pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d1	; add 2x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d2	; add 2x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d3	; add 2x component to b

	clr.w	d0
	move.b	1(a3),d0	; fetch lower right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fold in r
	add.w	(a5)+,d2	; fold in g
	add.w	(a5)+,d3	; fold in b

	addq.w	#8,d1	; going to divide by 16, so round off
	addq.w	#8,d2	; going to divide by 16, so round off
	addq.w	#8,d3	; going to divide by 16, so round off
	asr.w	#4,d1	; 16 wieghts added, time to average
	asr.w	#4,d2	; 16 wieghts added, time to average
	asr.w	#4,d3	; 16 wieghts added, time to average

	asl.w	#6,d1
	asl.w	#3,d2
	add.w	d2,d1
	add.w	d3,d1
	move.b	0(a4,d1),(a0)+

zbll_loop	dbra	d6,bll_loop


	movem.l	(sp)+,a2/a3/a4/a5/a6/d3/d4/d5/d6
	rts

