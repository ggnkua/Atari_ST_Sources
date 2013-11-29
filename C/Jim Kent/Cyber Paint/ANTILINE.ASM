
;	:ts=12

	dseg
	public	_blur_out
	public	_unp_colors
	public	_clookup
	public	_blbuf1
	public	_blbuf2
	public	_blbuf3

	cseg
	;anti_line(count)
	;	do a box-filter average on blbuf1-3 into blur_out
	public	_anti_line

firstp	set	9*4+4
count	set	firstp
_anti_line
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
	;test to see if all they pixels in the box same color
	move.b	1(a2),d0
	cmp.b	(a2),d0
	bne 	check_vert
	cmp.b	2(a2),d0
	beq	pass

check_vert
	cmp.b	1(a1),d0
	bne	check_diag1
	cmp.b	1(a3),d0
	beq	pass

check_diag1
	cmp.b	(a1),d0
	bne	check_diag2
	cmp.b	2(a3),d0
	beq	pass

check_diag2
	cmp.b	2(a1),d0
	bne	do_anti
	cmp.b	(a3),d0
	bne	do_anti

; here's where to jump if no anti-aliasing
pass	add	#1,a1
	add	#1,a2
	add	#1,a3
	move.b	(a2),(a0)+
	dbra	d6,bll_loop
	bra	outta_here

do_anti	;this is like blur ... does average for this pixel

	;add	#1,a1	;DEBUG
	;add	#1,a2
	;add	#1,a3
	;move.b	#0,(a0)+
	;dbra	d6,bll_loop
	;bra	outta_here

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
	move.b	1(a1),d0	; fetch upper right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fold in r
	add.w	(a5)+,d2	; fold in g
	add.w	(a5)+,d3	; fold in b

	clr.w	d0
	move.b	(a2)+,d0	; fetch left pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
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
	move.b	(a2),d0	; fetch center pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
	move.w	(a5)+,d0	; fetch r
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d1	; add 12x component to r
	add.w	d0,d1	; add 12x component to r
	add.w	d0,d1	; add 12x component to r
	move.w	(a5)+,d0	; fetch g
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d2	; add 12x component to g
	add.w	d0,d2	; add 12x component to g
	add.w	d0,d2	; add 12x component to g
	move.w	(a5)+,d0	; fetch b
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d3	; add 12x component to b
	add.w	d0,d3	; add 12x component to b
	add.w	d0,d3	; add 12x component to b

	clr.w	d0
	move.b	1(a2),d0	; fetch right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
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
	move.b	(a3)+,d0	; fetch lower left pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fetch r
	add.w	(a5)+,d2	; fetch g
	add.w	(a5)+,d3	; fetch b

	clr.w	d0
	move.b	(a3),d0	; fetch lower pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
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
	move.b	1(a3),d0	; fetch lower right pixel
	asl.w	#3,d0	; 8 bytes per unpacked color
	lea	0(a6,d0.w),a5	; point a5 to unpacked color
	add.w	(a5)+,d1	; fold in r
	add.w	(a5)+,d2	; fold in g
	add.w	(a5)+,d3	; fold in b

	add.w	#16,d1	; going to divide by 32, so round off
	add.w	#16,d2	; going to divide by 32, so round off
	add.w	#16,d3	; going to divide by 32, so round off
	asr.w	#5,d1	; 32 wieghts added, time to average
	asr.w	#5,d2	; 32 wieghts added, time to average
	asr.w	#5,d3	; 32 wieghts added, time to average

	asl.w	#6,d1
	asl.w	#3,d2
	add.w	d2,d1
	add.w	d3,d1

	move.b	0(a4,d1.w),(a0)+

zbll_loop	dbra	d6,bll_loop

outta_here

	movem.l	(sp)+,a2/a3/a4/a5/a6/d3/d4/d5/d6
	rts

