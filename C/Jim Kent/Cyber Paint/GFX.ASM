
	public _cscreen
	public conv_1



	;	mask_screen(s)
	public _mask_screen
_mask_screen
	move.l	4(sp),a0
	move.w	#(32000/8)-1,d1
mkslp
	move.w	0(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbra	d1,mkslp
	rts

	;	imask_screen(s)
	public _imask_screen
_imask_screen
	move.l	4(sp),a0
	move.w	#(32000/8)-1,d1
imkslp
	move.w	0(a0),d0
	or.w	2(a0),d0
	or.w	4(a0),d0
	or.w	6(a0),d0
	not.w	d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbra	d1,imkslp
	rts


	;	and_screen(s, d)
	public _and_screen
_and_screen
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	#32000/16,d1	;loop counter
	bra	zandlp
andlp	
	move.l	(a0)+,d0
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	and.l	d0,(a1)+
zandlp	dbra	d1,andlp
	rts

	;	xor_screen(s, d)
	public _xor_screen
_xor_screen
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	#32000/16,d1	;loop counter
	bra	zxorlp
xorlp	
	move.l	(a0)+,d0
	eor.l	d0,(a1)+
	move.l	(a0)+,d0
	eor.l	d0,(a1)+
	move.l	(a0)+,d0
	eor.l	d0,(a1)+
	move.l	(a0)+,d0
	eor.l	d0,(a1)+
zxorlp	dbra	d1,xorlp
	rts

	; zero_screen(s)
	public _zero_screen
_zero_screen:
	move.l	4(sp),a0
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
	adda	#32000,a0
cl_lp:  
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A0)
	dbf	D0,cl_lp
	movem.l (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
	rts

	; mask_copy_screen(source, mask, dest);
	public _mask_copy_screen
mscregs	reg	a2/d2/d3/d4/d5
firstp set 4+4*5
source set firstp
mask 	set	firstp+4
dest	set	firstp+8
_mask_copy_screen
	movem.l	mscregs,-(sp)
	move.l	source(sp),a0
	move.l	mask(sp),a1
	move.l	dest(sp),a2
	move.w	#4000,d5

	bra	zmsclp
mscplp
	move.w	(a1)+,d1	; grab and mask
	move.w	d1,d2		
	not.w	d2			; invert it
	bsr		mcone
	bsr		mcone
	bsr		mcone
	bsr		mcone
zmsclp	dbra	d5,mscplp
	movem.l	(sp)+,mscregs
	rts

mcone	
	move.w	(a0)+,d0	; fetch next source word
	and.w	d2,d0
	move.w	(a2),d3		; get dest word
	and.w	d1,d3
	or.w	d0,d3
	move.w	d3,(a2)+
	rts






	;zscopy_screen(background, forground, dest)
	; zero-suppress copy forground onto background
	public _zscopy_screen
_zscopy_screen
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.l	12(sp),a2
	move.w	#(20*200)-1,d2
zsclp	move.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	or.w	(a1)+,d0
	subq.w	#8,a1
	not.w	d0
	move.w	d0,d1
	and.w	(a0)+,d1
	or.w	(a1)+,d1
	move.w	d1,(a2)+
	move.w	d0,d1
	and.w	(a0)+,d1
	or.w	(a1)+,d1
	move.w	d1,(a2)+
	move.w	d0,d1
	and.w	(a0)+,d1
	or.w	(a1)+,d1
	move.w	d1,(a2)+
	move.w	d0,d1
	and.w	(a0)+,d1
	or.w	(a1)+,d1
	move.w	d1,(a2)+
	dbra	d2,zsclp
	rts

	public _copy_lines
_copy_lines
	move.w	12(sp),d0
	bra		cplines

	; copy_screen(source, dest)  32000-byte block copy 
	public _copy_screen
_copy_screen:
	move.w #200,D0
cplines
	move.l	4(sp),a0
	move.l	8(sp),a1
	movem.l D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7) ; save the world
	bra zcp_lp
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
zcp_lp	dbf	D0,cp_lp
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
	move.l	12(sp),d0
cm_loop	
	subq.l	#1,d0
	bmi		zcm_loop
	move.w (a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	not.w	d1
	move.w	d1,(a1)+
	bra		cm_loop
zcm_loop
	rts




	;	line_zero( line )
	;		see if next 160 bytes are zero
	public _line_zero
_line_zero
	move.l	4(sp),a0
	clr.l	d1
	move.w	#4,d0
lz_loop	
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	or.l	(a0)+,d1
	dbra d0,lz_loop
	tst.l	d1
	bne		not_z
	move.w	#1,d0
	rts
not_z	move.w	#0,d0
	rts




	;	first_zeros( line )
	;		return count of zeroes at start of line
	public _first_zeros
_first_zeros
	move.l	4(sp),a0
	move.w	#19,d1
	move.w #0,d0
f16_loop	
	move.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	or.w	(a0)+,d2
	bne	f16z
	add.w	#16,d0
	dbra	d1,f16_loop
	rts
f16z	move.w	#15,d1
lfzl	btst	d1,d2
	bne	fz
	add.w	#1,d0
	dbra	d1,lfzl
fz	rts




	;	last_zeros( line )
	;		return count of zeroes at end of line
	public _last_zeros
_last_zeros
	move.l 4(sp),a1
	adda	#160,a1
	move.w	#19,d1
	move.w #320,d0
l16_loop	
	move.w	-(a1),d2
	or.w	-(a1),d2
	or.w	-(a1),d2
	or.w	-(a1),d2
	bne l16z
	sub.w	#16,d0
	dbra d1,l16_loop
	rts
l16z	
	move.w	#0,d1
ll2 btst	d1,d2
	bne		lz
	add		#1,d1
	cmp.w	#16,d1
	bne	ll2
lz  sub.w	d1,d0
	rts


	; stencil1(mask, screen);
	;	plots mask on screen in color 1
	public _stencil1
_stencil1
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	#4000-1,d0
stlp	move.w	(a0)+,d1
	not.w	d1
	or.w	d1,(a1)+
	not.w	d1
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	and.w	d1,(a1)+
	dbra	d0,stlp
	rts

	; blue_mask(source, mask)
	;	converts a screen into a mask for color 1
	public _blue_mask
_blue_mask
	move.l	4(sp),a0
	move.l	8(sp),a1
	move.w	#4000-1,d0
bmloop	move.w (a0)+,d1
	not.w	d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a1)+
	dbra d0,bmloop
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

