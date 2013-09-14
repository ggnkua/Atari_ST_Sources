*
*
*  scaleman, courtesy of Jim Eisenstein
*
STATUS		equ	00

S_FORM		equ	02	; src form base address
S_NXLN		equ	06	; src form width in bytes
S_XMIN		equ	08	; Xmin of src region 
S_YMIN		equ	10	; Ymin of src region
S_WD		equ	12	; width in pixels of src region
S_HT		equ	14	; height in pixels of src region

D_FORM		equ	16	; dst form base address
D_NXLN		equ	20	; dst form width in bytes
D_XMIN		equ	22	; Xmin of dst region 
D_YMIN		equ	24	; Ymin of dst region
D_WD		equ	26	; width in pixels of dst region
D_HT		equ	28	; height in pixels of dst region

*------------------------- MAINTAINED INTERNALLY -----------------------------*

S_ADDR		equ	30	; address of first word of src region
S_XPIX		equ	34	; first pixel of first word    (15:msb 00:lsb)

D_ADDR		equ	36	; address of first word of src region
D_XPIX		equ	40	; first pixel of first word    (15:msb 00:lsb)

WD_MIN		equ	42	; width in pixels of smallest region
HT_MIN		equ	44	; height in pixels of smallest region

X_FINC		equ	46	; min width / max width      (fractional part)
X_FRAC		equ	48	; X DDA accumulator         (init to X_FINC/2)
Y_FINC		equ	50	; min height / max height    (fractional part) 
Y_FRAC		equ	52	; Y DDA accumulator         (init to Y_FINC/2)

D_SPAN		equ	54	; dst word span -1
D_LMSK		equ	56	; lf dst mask in hi and lo words (0:old 1:new)
D_RMSK		equ	60	; rt dst mask in hi and lo words (0:old 1:new)

SP_SAV		equ	64	; save the stack pointer here


	globl	scale_man
	globl	final_resting_place
	globl	opaqu400,opaqu401,opaqu410,opaqu411
	globl	rtnop400,rtnop401,rtnop410,rtnop411
	globl	xprnt400,xprnt401,xprnt410,xprnt411
	globl	rtnxp400,rtnxp401,rtnxp410,rtnxp411
	globl	pix_up_table,col_0000,col_null
	globl	pix_dn_table,pix_0000,pix_null
*
*
* general scaling routine (replacement mode)
*     must assume non-overlapping forms
*
*	    4 interwoven planes
*
*  in:
*
*	a6	points to parameter block
*
*
*		status word	0:replace mode  1:transparent mode
*		
*		src form base address
*		src form width
*		src Xmin
*		src Ymin
*		src width
*		src height
*				
*		dst form base address
*		dst form width
*		dst Xmin
*		dst Ymin
*		dst width
*		dst height
*
*		18 words of scratch ram

scale_man:

	move.l	sp,SP_SAV(a6)		; save A7

	move.l	S_FORM(a6),a4		; a4 -> base of src form
	move.w	S_YMIN(a6),d7
	mulu	S_NXLN(a6),d7		; d7 <- offset to row Y
	add.l	d7,a4			; a4 -> start of row Y	

	move.w	S_XMIN(a6),d0
	move.w	d0,d7
	and.w	#$FFF0,d7
	lsr.w	#1,d7			; d7 <- offset to word containing X
	add.l	d7,a4			; a4 -> first word of region
	move.l	a4,S_ADDR(a6)

	not.w	d0			
	and.w	#$000F,d0		; d0 <- 1st bit of 1st src word (0:msb)
	move.w	d0,S_XPIX(a6)


	move.l	D_FORM(a6),a5		; a5 -> base of src form
	move.w	D_YMIN(a6),d7
	mulu	D_NXLN(a6),d7		; d7 <- offset to row Y
	add.l	d7,a5			; a5 -> start of row Y	

	move.w	D_XMIN(a6),d7
	move.w	d7,d1
	and.w	#$FFF0,d7
	lsr.w	#1,d7			; d7 <- offset to word containing X
	add.l	d7,a5			; a5 -> first word of region
	move.l	a5,D_ADDR(a6)

	not.w	d1			
	and.w	#$000F,d1		; d1 <- 1st bit of 1st dst word (0:msb)
	move.w	d1,D_XPIX(a6)


	
	lea	scale_tab,a0

	move.w	S_WD(a6),d6
	move.w	D_WD(a6),d5
	cmp.w	d5,d6
	bge.s	save_wd_min

	exg	d5,d6
	lea	8(a0),a0

save_wd_min:

	move.w	d5,WD_MIN(a6)

	move.w	S_HT(a6),d4
	move.w	D_HT(a6),d3
	cmp.w	d3,d4
	bge.s	save_ht_min

	exg	d3,d4
	lea	4(a0),a0

save_ht_min:

	move.w	d3,HT_MIN(a6)

	move.l	#col_0000,pix_up_tab+00
	move.l	#pix_0000,pix_dn_tab+00

	tst.w	STATUS(a6)
	beq.s	default

	lea	16(a0),a0
	move.l	#col_null,pix_up_tab+00
	move.l	#pix_null,pix_dn_tab+00

default:

	move.w	D_XMIN(a6),d0		; d0 <- dst Xmin
	move.w	d0,d1
	add.w	D_WD(a6),d1
	subq.w	#1,d1			; d1 <- dst Xmax

	move.w	d0,d2
	lsr.w	#4,d2
	move.w	d1,d3
	lsr.w	#4,d3
	sub.w	d2,d3
	move.w	d3,D_SPAN(a6)

	and.w	#$000F,d0
	add.w	d0,d0
	move.w	l_fringe(pc,d0.w),d0
	and.w	#$000F,d1
	add.w	d1,d1
	move.w	r_fringe(pc,d1.w),d1
	not.w	d1

	move.w	d0,D_LMSK+00(a6)
	move.w	d0,D_LMSK+02(a6)
	move.w	d1,D_RMSK+00(a6)
	move.w	d1,D_RMSK+02(a6)

	move.l	(a0),a0			; a0 -> final prep routine
	jmp	(a0)			; goto the setup routine


final_resting_place:

	move.l	SP_SAV(a6),a7
	rts




l_fringe:	dc.w	%1111111111111111
r_fringe:	dc.w	%0111111111111111
		dc.w	%0011111111111111
		dc.w	%0001111111111111
       	       	dc.w   	%0000111111111111
		dc.w	%0000011111111111
		dc.w	%0000001111111111
		dc.w	%0000000111111111
		dc.w	%0000000011111111
		dc.w	%0000000001111111
		dc.w	%0000000000111111
		dc.w	%0000000000011111
		dc.w	%0000000000001111
		dc.w	%0000000000000111
		dc.w	%0000000000000011
		dc.w	%0000000000000001
                dc.w    %0000000000000000

scale_tab:	dc.l	o400,o401,o410,o411,x400,x401,x410,x411



*  S_WD > D_WD     S_HT > D_HT


x400:	lea	rtnxp400,a7
	lea	xprnt400,a5
	bra.s	s400

o400:	lea	rtnop400,a7
	lea	opaqu400,a5

s400:	move.l	D_WD(a6),d0
	clr.w	d0
	divu	S_WD(a6),d0
	subq.w	#1,d0
	move.w	d0,X_FINC(a6)
	lsr.w	#1,d0
	move.w	d0,X_FRAC(a6)

	move.l	D_HT(a6),d0
	clr.w	d0
	divu	S_HT(a6),d0
	subq.w	#1,d0
	move.w	d0,Y_FINC(a6)
	lsr.w	#1,d0
	move.w	d0,Y_FRAC(a6)

	jmp	(a5)


*  S_WD > D_WD     S_HT < D_HT


x401:	lea	rtnxp401,a7
	lea	xprnt401,a5
	bra.s	s401

o401:	lea	rtnop401,a7
	lea	opaqu401,a5

s401:	move.l	D_WD(a6),d0
	clr.w	d0
	divu	S_WD(a6),d0
	subq.w	#1,d0
	move.w	d0,X_FINC(a6)
	lsr.w	#1,d0
	move.w	d0,X_FRAC(a6)
*
*
	move.l	S_HT(a6),d0
	clr.w	d0
	divu	D_HT(a6),d0
*
*  start test
*
	bvc.s	s401x0
	moveq	#-1,d0
	bra.s	s401x2
s401x0:
	swap	d0		;check remainder
	add.w	d0,d0		;*2
	cmp.w	D_HT(a6),d0	;remainder > 1/2 divisor?
	bcs.s	s401x1		;br if not
	addi.l	#$10000,d0	;round quotient up
s401x1:
	swap	d0		;unswap
s401x2:
*
*  end test
*
	move.w	d0,Y_FINC(a6)
*
*  more test
*
	cmpi.w	#$FF,d0
	bcc.s	s401x4
	mulu	D_HT(a6),d0
	neg.w	d0
	bpl.s	s401x5		;br if not overflo'd
	clr.w	d0		;  else, just start w/0
s401x4:
	lsr.w	#1,d0
s401x5:
*
*  end test
*
	move.w	d0,Y_FRAC(a6)
*
*
*
*
*	subq.w	#1,d0
*	move.w	d0,Y_FINC(a6)
*	lsr.w	#1,d0
*	move.w	d0,Y_FRAC(a6)

	jmp	(a5)


*  S_WD < D_WD     S_HT > D_HT

x410:	lea	rtnxp410,a7
	lea	xprnt410,a5
	bra.s	s410

o410:	lea	rtnop410,a7
	lea	opaqu410,a5

s410:	move.l	S_WD(a6),d0
	clr.w	d0
	divu	D_WD(a6),d0
*
*  start test
*
	bvc.s	s410x0
	moveq	#-1,d0
	bra.s	s410x2
s410x0:
	swap	d0		;check remainder
	add.w	d0,d0		;*2
	cmp.w	D_WD(a6),d0	;remainder > 1/2 divisor?
	bcs.s	s410x1		;br if not
	addi.l	#$10000,d0	;round quotient up
s410x1:
	swap	d0		;unswap
s410x2:
*
*  end test
*
	move.w	d0,X_FINC(a6)
*
*  more test
*
	cmpi.w	#$FF,d0
	bcc.s	s410x4
	mulu	D_WD(a6),d0
	neg.w	d0
	bpl.s	s410x5		;br if not overflo'd
	clr.w	d0		;  else, just start w/0
s410x4:
	lsr.w	#1,d0
s410x5:
*
*  end test
*
	move.w	d0,X_FRAC(a6)
*
	move.l	D_HT(a6),d0
	clr.w	d0
	divu	S_HT(a6),d0
	subq.w	#1,d0
	move.w	d0,Y_FINC(a6)
	lsr.w	#1,d0
	move.w	d0,Y_FRAC(a6)

	jmp	(a5)


*  S_WD < D_WD     S_HT < D_HT

x411:	lea	rtnxp411,a7
	lea	xprnt411,a5
	bra.s	s411

o411:	lea	rtnop411,a7
	lea	opaqu411,a5

s411:	move.l	S_WD(a6),d0
	clr.w	d0
	divu	D_WD(a6),d0

*
*  start test
*
	bvc.s	s411x0
	moveq	#-1,d0
	bra.s	s411x2
s411x0:
	swap	d0		;check remainder
	add.w	d0,d0		;*2
	cmp.w	D_WD(a6),d0	;remainder > 1/2 divisor?
	bcs.s	s411x1		;br if not
	addi.l	#$10000,d0	;round quotient up
s411x1:
	swap	d0		;unswap
s411x2:
*
*  end test
*
	move.w	d0,X_FINC(a6)
*
*  more test
*
	cmpi.w	#$FF,d0
	bcc.s	s411x4
	mulu	D_WD(a6),d0
	neg.w	d0
	bpl.s	s411x5		;br if not overflo'd
	clr.w	d0		;  else, just start w/0
s411x4:
	lsr.w	#1,d0
s411x5:
*
*  end test
*
*	subq.w	#1,d0
*	move.w	d0,X_FINC(a6)
*	lsr.w	#1,d0
*
	move.w	d0,X_FRAC(a6)
*
*
	move.l	S_HT(a6),d0
	clr.w	d0
	divu	D_HT(a6),d0
*

*
*  start test
*
	bvc.s	s411y0
	moveq	#-1,d0
	bra.s	s411y2
s411y0:
	swap	d0		;check remainder
	add.w	d0,d0		;*2
	cmp.w	D_HT(a6),d0	;remainder > 1/2 divisor?
	bcs.s	s411y1		;br if not
	addi.l	#$10000,d0	;round quotient up
s411y1:
	swap	d0		;unswap
s411y2:
*
*  end test
*
	move.w	d0,Y_FINC(a6)
*
*  more test
*
	cmpi.w	#$FF,d0
	bcc.s	s411y4
	mulu	D_HT(a6),d0
	neg.w	d0
	bpl.s	s411y5		;br if not overflo'd
	clr.w	d0		;  else, just start w/0
s411y4:
	lsr.w	#1,d0
s411y5:
*
*  end test
*
*	subq.w	#1,d0
*	move.w	d0,Y_FINC(a6)
*	lsr.w	#1,d0
*
	move.w	d0,Y_FRAC(a6)

	jmp	(a5)



