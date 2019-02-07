
	public _cscreen
	public conv_1

	; clear_screen()
	public _clear_screen
_clear_screen:
	movem.l D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7) ; save the world
	move.w #200-1,D0
	move.l	#0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,d7
	move.l	d7,a2
	move.l	a2,a3
	move.l	a3,a4
	move.l	_cscreen,a0
	adda	#32000,a0
cl_lp:  
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	dbf	D0,cl_lp
	movem.l (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
	rts

	; copy_screen(source, dest)  32000-byte block copy 
	public _copy_screen
_copy_screen:
	move.l	4(sp),a0
	move.l	8(sp),a1
	movem.l D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7) ; save the world
	move.w #200-1,D0
cp_lp:  
	movem.l (A0)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,(A1)
	movem.l (A0)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,40(A1)
	movem.l (A0)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,80(A1)
	movem.l (A0)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,120(A1)
	adda	#160,A1
	dbf	D0,cp_lp
	movem.l (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
	rts

	; exchange_screen(s1, s2)  32000-byte array swap
	public _exchange_screen
_exchange_screen
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l D2,-(A7) ; save the world
	move.w #8000-1,D0
ex_lp:  move.l (A0),D1
	move.l (A1),D2
	move.l D2,(A0)+
	move.l D1,(A1)+
	dbf	D0,ex_lp
	move.l (A7)+,D2
	rts


	; calc_mask( source, dest, words)
	;	or together source 4 words at a time and put it into dest
	;	dest is words long
	public _calc_mask
_calc_mask
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	12(sp),d0
	bra zcm_loop
cm_loop	move.w (a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	not.w	d1
	move.w	d1,(a1)+
zcm_loop dbra	d0,cm_loop
	rts




	;	line_zero( line )
	;		see if next 160 bytes are zero
	public _line_zero
_line_zero
	move.l	4(sp),a0
	move.w	#39,d0
lz_loop	tst.l	(a0)+
	bne	not_z
	dbra d0,lz_loop
	move.w	#1,d0
	rts
not_z	move.w	#0,d0
	rts




	;	first_zeros( line )
	;		return count of zeroes at start of line
	public _first_zeros
_first_zeros
	move.l	4(sp),a1
	movem.w D2/D3/D4/D5/D6/D7,-(A7) ; save the world
	move.w	#19,d1
	move.w #0,d0
f16_loop	tst.l	(a1)
	bne	f16z
	tst.l	4(a1)
	bne f16z
	add.w	#16,d0
	adda	#8,a1
	dbra	d1,f16_loop
f16z 
	suba	#16,sp
	move.l	sp,a0	;set a0 to temp buffer
	jsr		conv_1
	move.l	sp,a0	;and reset to buffer after conv_1
	move.w	#15,d1
f_loop2	tst.b	(a0)+
	bne fz
	addq.w	#1,d0
	dbra	d1,f_loop2
fz	adda	#16,sp	;clean off buffer
	movem.w (A7)+,D2/D3/D4/D5/D6/D7
	rts




	;	last_zeros( line )
	;		return count of zeroes at end of line
	public _last_zeros
_last_zeros
	move.l 4(sp),a1
	movem.w D2/D3/D4/D5/D6/D7,-(A7) ; save the world
	adda	#160,a1
	move.w	#19,d1
	move.w #320,d0
l16_loop	
	suba	#8,a1
	tst.l	4(a1)
	bne	l16z
	tst.l (a1)	
	bne l16z
	sub.w	#16,d0
	dbra d1,l16_loop
l16z	
	suba	#16,sp
	move.l	sp,a0	;set a0 to temp buffer
	jsr		conv_1
	move.w	#15,d1
l_loop2	tst.b	-(a0)
	bne lz
	subq.w	#1,d0
	dbra	d1,l_loop2
lz	adda	#16,sp	;clean off buffer
	movem.w (A7)+,D2/D3/D4/D5/D6/D7
	rts


	; Convert all the non-zero colors on cscreen to color 1
	public _b_pic
_b_pic
	move.w	#4000-1,d0
	move.l	_cscreen,a0
blop	move.w (a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0),d1	
	suba	#6,a0
	move.w	d1,(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	dbra	d0,blop
	rts


	; convert color ones to color zeroes on cscreen
	public _ub_pic
_ub_pic
	move.w #4000-1,d0
	move.l _cscreen,a0
ublop	move.w (a0)+,d1
	not.w	d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0),d1
	suba #6,a0
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	dbra d0,ublop
	rts

