	opt	o-,x+
*
*	BLITTER LINE ROUT	v 1.00
*

*	Coded by: PeyloW of T.O.Y.S. for Dynamic LABS 

*	uses:	d0-d7/a0-a6	(Sorry!!!)

*	Line:		# lines:

*	0,0-0,0		375
*	15,0-15,0	370
*	0,0-319,0	42
*	0,0-0,199	27
*	0,0-319,99	22
*	0,0-159,199	19
*	0,0-319,199	14



*---------------------------------------*
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,s_sp
	
	move.w	#$fff,$ffff8240.w
	
	move.l	$44e,a0
	move.l	#7999,d0
clear:	clr.l	(a0)+
	dbra	d0,clear
	
	move.b	#0,$ffff8260.w
	move.b	#$12,$fffffc02.w
	move.l	$44e.w,screen
*++----
LOOP:
*++----

	neg.w	$ffff8240.w
	
	REPT	14
	move.l	#0,d0		; X1
	move.l	#0,d1		; Y1
	move.l	#319,d2		; X2
	move.l	#199,d3		; Y2
	move.l	screen,a0	; screen add.
	bsr	B_LINE
	ENDR

	neg.w	$ffff8240.w

*++----
END:
*++----

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	cmp.b	#$39,$fffffc02.w
	bne	LOOP
	
	move.b	#8,$fffffc02.w
	move.b	#1,$ffff8260.w
	
	move.w	#$fff,$ffff8240.w              
	move.l	s_sp,-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
		
s_sp:	dc.l	"OBIS"
screen:	dc.l	"LAME"
*---------------------------------------*


B_LINE:
	
	move.w	#2,$ffff8a20.w			; x add source
	move.w	#2,$ffff8a22.w			; y add source	
	move.w	#8,$ffff8a2e.w			; x add dest
	move.l	#$ffffffff,$ffff8a28.w		; start mask
	move.w	#$ffff,$ffff8a2c.w		; end mask
	move.b	#2,$ffff8a3a.w			; operation
	move.b	#7,$ffff8a3b.w			; logical op.

	cmp.w	d0,d2
	blt.s	shift		; only X1  X2
	bne.s	noshift
	cmp.w	d1,d3
	bne.s	noshift
	move.w	d0,d2
	and.w	#$f,d2
	and.w	#$fff0,d0
	ror.w	d0
	add.w	d0,a0
	add.w	d1,d1
	lea	M160,a5
	add.w	(a5,d1.w),a0
	move.w	#$8000,d1
	ror.w	d2,d1
	or.w	d1,(a0)
	rts
shift:
	exg.l	d0,d2
	exg.l	d1,d3
noshift:
	move.w	d2,d4
	move.w	d3,d5
	sub.w	d0,d4		; Delta	X
	sub.w	d1,d5		; Delta Y
	moveq.l	#0,d6
	move.w	d4,d6
	tst.w	d5
	bge.s	negDY
	moveq.l	#0,d7
	sub.w	d5,d7
	bra.s	fixDY
negDY:
	move.w	d5,d7
fixDY:
	move.w	d7,a6
	add.w	d6,d6
	add.w	d6,d6
	lea	M20,a5
	move.l	(a5,d6.w),d6
	rol.w	#5,d7
	cmp.l	d6,d7
	bge.s	Y_biggest
	
	tst.w	d5
	bmi.s	XU_draw		; 0-31
	bra	XN_draw		; 329-360
Y_biggest:
	tst.w	d5
	bmi	YU_draw		; 32-90
	bra	YN_draw		; 270-328
	
	
XU_draw:
	move.w	a6,d5
	moveq.l	#0,d6
	move.l	d6,d7
	move.w	d4,d7
	move.w	d5,d6
	rol.w	#7,d6
	rol.w	#7,d7
	divu	#32,d7
	divu	d7,d6
	rol.w	d6
	lea	XUL,a1
	add.w	(a1,d6.w),a1	; A1=block data
	move.l	(a1)+,a2	; a2=antXled:antYled : a1=Block start
	move.w	d2,a4
	moveq.l	#0,d2
	move.w	d4,d2
	asr.w	#5,d2		; d2=antBlock
	ext.l	d5	
	addq.w	#1,d5
	rol.w	#5,d5
	divu	d4,d5
	move.l	d5,d6
	clr.w	d6
	swap	d5
	divu	d4,d6
	move.w	d6,d5			; d5=Xadd
	move.w	#144,$ffff8a30.w	; y add dest

	lea	M160,a5
	
	dbra	d2,XUloop
	bra.s	XUlast
XUloop:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	sub.w	a2,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!
	add.w	#32,d0
	swap	d1
	sub.l	d5,d1
	swap	d1	
	dbra	d2,XUloop
XUlast:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	sub.w	a2,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.w	a4,d7
	sub.w	d0,d7
	add.b	d6,d7
	add.w	d7,d7
	move.w	d7,d6
	add.w	d6,d7
	add.w	d6,d7
	lea	MASK,a5
	move.l	(a5,d7.w),$ffff8a28.w
	move.w	4(a5,d7.w),$ffff8a2c.w
	move.b	#$c0,$ffff8a3c.w		; run !!!

	rts
	
XN_draw:	
	move.w	a6,d5
	moveq.l	#0,d6
	move.l	d6,d7
	move.w	d4,d7
	move.w	d5,d6
	rol.w	#7,d6
	rol.w	#7,d7
	divu	#32,d7
	divu	d7,d6
	rol.w	d6
	lea	XNL,a1
	add.w	(a1,d6.w),a1	; A1=block data
	move.l	(a1)+,a2	; a2=antXled:antYled : a1=Block start
	move.w	d2,a4
	moveq.l	#0,d2
	move.w	d4,d2
	asr.w	#5,d2		; d2=antBlock
	ext.l	d5	
	addq.w	#1,d5
	rol.w	#5,d5
	divu	d4,d5
	move.l	d5,d6
	clr.w	d6
	swap	d5
	divu	d4,d6
	move.w	d6,d5			; d5=Xadd
	move.w	#144,$ffff8a30.w	; y add dest

	lea	M160,a5
	
	dbra	d2,XNloop
	bra.s	XNlast
XNloop:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!
	add.w	#32,d0
	swap	d1
	add.l	d5,d1
	swap	d1	
	dbra	d2,XNloop
XNlast:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.w	a4,d7
	sub.w	d0,d7
	add.b	d6,d7
	add.w	d7,d7
	move.w	d7,d6
	add.w	d6,d7
	add.w	d6,d7
	lea	MASK,a5
	move.l	(a5,d7.w),$ffff8a28.w
	move.w	4(a5,d7.w),$ffff8a2c.w
	move.b	#$c0,$ffff8a3c.w		; run !!!

	rts

YU_draw:
	move.w	a6,d5
*	cmp.w	d4,d5		; remove * to fix 45 deg. bug
*	bne.s	noYU45
*	move.w	#15,d6
*	bra.s	YU45
*noYU45:
	moveq.l	#0,d6
	move.l	d6,d7
	move.w	d4,d6
	move.w	d5,d7
	rol.w	#7,d6
	rol.w	#7,d7
	divu	#20,d7
	divu	d7,d6
YU45:
	rol.w	d6
	lea	YUL,a1
	add.w	(a1,d6.w),a1	; A1=block data
	move.l	(a1)+,a2	; a2=antXled:antYled : a1=Block start
	move.w	d3,a4
	moveq.l	#0,d3
	move.w	d5,d3
	lea	D20,a5
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a5,d3.w),d3
	ext.l	d3		; d3=antBlock
	ext.l	d4	
	addq.w	#1,d4
	add.w	d4,d4
	add.w	d4,d4
	lea	M20,a5
	move.l	(a5,d4.w),d4
	divu	d5,d4
	move.l	d4,d6
	clr.w	d6
	swap	d4
	divu	d5,d6
	move.w	d6,d4		; d4=Xadd
	move.l	a2,d6
	swap	d6
	rol.w	#3,d6
	move.w	#168,d7
	sub.w	d6,d7
	move.w	d7,$ffff8a30.w			; y add dest

	lea	M160,a5
	
	dbra	d3,YUloop
	bra.s	YUlast
YUloop:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	sub.w	#20,d1
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!
	swap	d0
	add.l	d4,d0
	swap	d0	
	dbra	d3,YUloop
YUlast:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	sub.w	#19,d1
	sub.w	d1,a4
	addq.w	#1,a4
	move.l	a2,d2
	swap	d2
	rol.w	d2
	move.w	#21,d3
	move.w	a4,d3
	move.w	#21,d5
	sub.w	a4,d5
	subq.w	#1,d3
	mulu	d3,d2
	add.w	d2,a1
	add.w	d3,d1
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d5,$ffff8a38.w			; y counter	
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!

    	rts

YN_draw:
*	cmp.w	d4,d5		; remove * for the same reason
*	bne.s	noYN45
*	move.w	#15,d6
*	bra.s	YN45
*noYN45:
	moveq.l	#0,d6
	move.l	d6,d7
	move.w	d4,d6
	move.w	d5,d7
	rol.w	#7,d6
	rol.w	#7,d7
	divu	#20,d7
	divu	d7,d6
YN45:
	rol.w	d6
	lea	YNL,a1
	add.w	(a1,d6.w),a1	; A1=block data
	move.l	(a1)+,a2	; a2=antXled:antYled : a1=Block start
	move.w	d3,a4
	moveq.l	#0,d3
	move.w	d5,d3
	lea	D20,a5
	add.w	d3,d3
	add.w	d3,d3
	move.l	(a5,d3.w),d3
	ext.l	d3		; d3=antBlock
	ext.l	d4	
	addq.w	#1,d4
	add.w	d4,d4
	add.w	d4,d4
	lea	M20,a5
	move.l	(a5,d4.w),d4
	divu	d5,d4
	move.l	d4,d6
	clr.w	d6
	swap	d4
	divu	d5,d6
	move.w	d6,d4		; d4=Xadd
	move.l	a2,d6
	swap	d6
	rol.w	#3,d6
	move.w	#168,d7
	sub.w	d6,d7
	move.w	d7,$ffff8a30.w			; y add dest

	lea	M160,a5
	
	dbra	d3,YNloop
	bra.s	YNlast
YNloop:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!
	add.w	#20,d1
	swap	d0
	add.l	d4,d0
	swap	d0	
	dbra	d3,YNloop
YNlast:
	move.l	a0,a3
	move.w	d0,d6
	and.l	#$fff0,d6
	ror.w	d6
	add.l	d6,a3
	move.w	d1,d6
	add.w	d6,d6
	add.w	(a5,d6.w),a3
	move.l	a3,$ffff8a32.w			; dest address
	move.l	a1,$ffff8a24.w			; source address
	move.l	a2,$ffff8a36.w			; x counter
	sub.w	d1,a4
	addq.w	#1,a4
	move.w	a4,$ffff8a38.w			; y counter	
	move.w	d0,d6
	and.w	#$f,d6
	move.b	d6,$ffff8a3d.w			; shift
	move.b	#$c0,$ffff8a3c.w		; run !!!

	rts


	incbin	"m160n.tab"
M160:	incbin	"m160.tab"
M20:	incbin	"m20.tab"
D20:	incbin	"d20.tab"	

MASK:	incbin	"mask.bin"

XNL:	incbin	"xnl.dat"
XUL:	incbin	"xul.dat"
YNL:	incbin	"ynl.dat"
YUL:	incbin	"yul.dat"