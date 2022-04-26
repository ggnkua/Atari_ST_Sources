
start	pea	0.w		Supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	
	move.b	$ffff8201.w,oldscr	Save old screen and resolution
	move.b	$ffff8203.w,oldscr+1
	move.b	$ffff8260.w,oldres
	
	lea	$ffff8240.w,a0
	clr.l	d0
	move.w	#7,d1
.loop	move.l	d0,(a0)+
	dbra.w	d1,.loop
	
	move.l	#$70000,scrbase		Set different for double-back
	move.l	#$78000,movebase
	move.l	scrbase,a0
	bsr	clrscr
	move.l	movebase,a0
	bsr	clrscr
	
	move.w	#$2700,sr
	
	lea	saveints,a1
	move.b	$fffffa07.w,(a1)+
	move.b	$fffffa09.w,(a1)+
	move.b	$fffffa13.w,(a1)+
	move.b	$fffffa15.w,(a1)+
	move.l	$70.w,(a1)+
	
	move.b	#$21,$fffffa07.w	Set VBL & HBL interupts
	move.b	#$21,$fffffa13.w	Set VBL & HBL mask
	clr.b	$fffffa09.w
	clr.b	$fffffa15.w
	
	moveq	#1,d0
	jsr	music

	clr.b	$fffffa1b.w	No HBL until VBL
	move.l	#vbl,$70.w
	move.w	#$2300,sr
	

vbloop	cmp.b	#0,waitz		Wait for VBL
	beq.s	vbloop
	clr.b	waitz
	
	clr.b	$ffff8260.w	Set low-res
	move.l	scrbase,d0	Flip screens
	move.l	movebase,scrbase
	move.l	d0,movebase
	
	move.w	#$777,$ffff8242.w
	move.w	#$077,$ffff8242.w
	move.w	#$007,$ffff8242.w
	clr.w	$ffff8240.w
	
	move.l	movebase,a0
	moveq	#0,d0
	
	move.w	#199,d7
.clr	move.w	d0,(a0)
	move.w	d0,8*1(a0)
	move.w	d0,8*2(a0)
	move.w	d0,8*3(a0)
	move.w	d0,8*4(a0)
	move.w	d0,8*5(a0)
	move.w	d0,8*6(a0)
	move.w	d0,8*7(a0)
	move.w	d0,8*8(a0)
	move.w	d0,8*9(a0)
	move.w	d0,8*10(a0)
	move.w	d0,8*11(a0)
	move.w	d0,8*12(a0)
	move.w	d0,8*13(a0)
	move.w	d0,8*14(a0)
	move.w	d0,8*15(a0)
	move.w	d0,8*16(a0)
	move.w	d0,8*17(a0)
	move.w	d0,8*18(a0)
	move.w	d0,8*19(a0)
	lea	160(a0),a0
	dbra.w	d7,.clr
	
	move.w	#$100,$ffff8240.w
	
	add.w	#16,yangle
	cmp.w	#2880,yangle
	bne.s	.nowrap
	clr.w	yangle
.nowrap	add.w	#20,xangle
	cmp.w	#2880,xangle
	bne.s	.nowrap2
	clr.w	xangle
.nowrap2	add.w	#8,zangle
	cmp.w	#2880,zangle
	bne.s	.nowrap5
	clr.w	zangle
.nowrap5	addq.w	#2,xcnt
	addq.w	#2,ycnt
	lea	xmove,a0
	add.w	xcnt,a0
	cmp.w	#-1,(a0)
	bne.s	.nowrap3
	clr.w	xcnt
	lea	xmove,a0
.nowrap3	move.w	(a0),xpos
	lea	ymove,a0
	add.w	ycnt,a0
	cmp.w	#-1,(a0)
	bne.s	.nowrap4
	clr.w	ycnt
	lea	ymove,a0
.nowrap4	move.w	(a0),ypos
	
	lea	objdat2,a0
	lea	nibbles,a3
	lea	linedat2,a2	For saving coordinates!
	clr.w	dotcnt
.dotfix	jsr	calcdot
	addq.l	#6,a0
	addq.w	#1,dotcnt
	move.w	dotcnt,d0
	cmp.w	maxdots,d0
	bne.s	.dotfix

	move.w	#$200,$ffff8240.w
	lea	linectrl,a1
.lines	move.l	a1,-(sp)

	lea	linedat2,a0
	add.w	(a1)+,a0
	move.w	(a0)+,d4
	move.w	(a0),d5

	lea	linedat2,a0
	add.w	(a1),a0
	move.w	(a0)+,d6
	move.w	(a0),d7
	bsr	line
	
	move.l	(sp)+,a1
	addq.l	#4,a1
	tst.w	(a1)
	bmi.s	.end
	bra.s	.lines
	
.end	clr.w	waitz
	move.b	movebase+1,$ffff8201.w	Show movebase
	move.b	movebase+2,$ffff8203.w	next VBL
	
	move.w	#$770,$ffff8240.w
	bsr	fixtxt
	
	addq.w	#1,hz
	cmp.w	#4,hz
	bne	tstdown
	
	clr.w	hz
	lea	objdat2,a0
	move.w	objcnt,d0
	mulu	#6,d0
	add.w	d0,a0
*	cmp.b	#2,$fffffc02.w
*	bne.s	.no1
*	subq.w	#1,(a0)		Dec x
*.no1	cmp.b	#3,$fffffc02.w
*	bne.s	.no2
*	addq.w	#1,(a0)		Inc x
*.no2	cmp.b	#4,$fffffc02.w
*	bne.s	.no3
*	subq.w	#1,2(a0)		Dec y
*.no3	cmp.b	#5,$fffffc02.w
*	bne.s	.no4
*	addq.w	#1,2(a0)		Inc y
*.no4	cmp.b	#6,$fffffc02.w
*	bne.s	.no5
*	subq.w	#1,4(a0)		Dec z
*.no5	cmp.b	#7,$fffffc02.w
*	bne.s	.no6
*	addq.w	#1,4(a0)		Inc z
*.no6	cmp.b	#8,$fffffc02.w
*	bne.s	.no7
*	subq.w	#1,objcnt		Dec point
*.no7	cmp.b	#9,$fffffc02.w
*	bne.s	.no8
*	addq.w	#1,objcnt		Inc point
.no8	tst.w	objcnt
	bpl.s	.ok1
	clr.w	objcnt
.ok1	cmp.w	#32,objcnt
	blo.s	linefix
	move.w	#31,objcnt
linefix	lea	linectrl,a0
	move.w	linecnt,d0
	mulu	#4,d0
	add.w	d0,a0
*	cmp.b	#9,$fffffc02.w
*	bne.s	.no1
*	subq.w	#1,(a0)		Dec 1
*.no1	cmp.b	#10,$fffffc02.w
*	bne.s	.no2
*	addq.w	#1,(a0)		Inc 1
*.no2	cmp.b	#11,$fffffc02.w
*	bne.s	.no3
*	subq.w	#1,2(a0)		Dec 2
*.no3	cmp.b	#12,$fffffc02.w
*	bne.s	.no4
*	addq.w	#1,2(a0)		Inc 2
*.no4	cmp.b	#13,$fffffc02.w
*	bne.s	.no7
*	subq.w	#1,linecnt	Dec point
*.no7	cmp.b	#14,$fffffc02.w
*	bne.s	.no8
*	addq.w	#1,linecnt	Inc point
.no8	tst.w	linecnt
	bpl.s	.ok1
	clr.w	linecnt
.ok1	cmp.w	#32,linecnt
	blo.s	.ok2
	move.w	#31,linecnt
.ok2	
	
tstdown	clr.w	$ffff8240.w
	cmp.b	#$39,$fffffc02.w		Test for space down
	bne	vbloop
	bra	return
	

*****************************************
*Interupts			*
*				*

vbl	move.b	#1,waitz
*	move.b	#199,$fffffa21.w
*	move.l	#hbl1,$120
*;	move.b	#8,$fffffa1b.w
	jsr	music+8
	rte

hbl1*	clr.b	$fffffa1b.w
*	bclr	#0,$fffffa0f.w
	rte

*****************************************
*Routines				*
*				*

calcdot	lea	sin_tab,a1	X2=X1*SIN(X)-Y1*COS(X)
	add.w	xangle,a1
	move.w	2(a1),d1
	move.w	(a0),d0
	
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part1
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part1
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part1
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part1	move.w	d1,d2
	lea	cos_tab,a1
	add.w	xangle,a1
	move.w	2(a1),d1
	move.w	2(a0),d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part2
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part2
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part2
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1

part2	sub.w	d1,d2
	move.w	d2,x2data		-7
	
	lea	sin_tab,a1	Y2=Y1*SIN(X)+X1*COS(X)
	add.w	xangle,a1
	move.w	2(a1),d1
	move.w	2(a0),d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part3
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part3
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part3
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part3	move.w	d1,d2
	lea	cos_tab,a1
	add.w	xangle,a1
	move.w	2(a1),d1
	move.w	(a0),d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part4
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part4
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part4
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part4	add.w	d1,d2
	move.w	d2,y2data		7
	
	lea	sin_tab,a1	X3=X2*SIN(Y)-Z1*COS(Y)
	add.w	yangle,a1
	move.w	2(a1),d1
	move.w	x2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part5
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part5
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part5
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part5	move.w	d1,d2
	lea	cos_tab,a1
	add.w	yangle,a1
	move.w	2(a1),d1
	move.w	4(a0),d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part6
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part6
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part6
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part6	sub.w	d1,d2
	move.w	d2,x3data
	
	lea	sin_tab,a1	Z2=Z1*SIN(Y)+X2*COS(Y)
	add.w	yangle,a1
	move.w	2(a1),d1
	move.w	4(a0),d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part7
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part7
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part7
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part7	move.w	d1,d2
	lea	cos_tab,a1
	add.w	yangle,a1
	move.w	2(a1),d1
	move.w	x2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part8
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part8
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part8
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part8	add.w	d1,d2
	move.w	d2,z2data
	
	lea	sin_tab,a1	Y3=Y2*SIN(Z)-Z2*COS(Z)
	add.w	zangle,a1
	move.w	2(a1),d1
	move.w	y2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part9
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part9
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part9
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part9	move.w	d1,d2
	lea	cos_tab,a1
	add.w	zangle,a1
	move.w	2(a1),d1
	move.w	z2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part10
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part10
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part10
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part10	sub.w	d1,d2
	move.w	d2,y3data

	lea	sin_tab,a1	Z3=Z2*SIN(Z)+Y2*COS(Z)
	add.w	zangle,a1
	move.w	2(a1),d1
	move.w	z2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part11
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part11
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part11
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part11	move.w	d1,d2
	lea	cos_tab,a1
	add.w	zangle,a1
	move.w	2(a1),d1
	move.w	y2data,d0
	tst.w	d0		D2=0   neg-flag in(a1)
	bmi.s	.next1		D3=sin or cos value
	tst.w	(a1)
	beq.s	.next2
	mulu	d0,d1
	swap	d1
	bra.s	part12
.next2	mulu	d0,d1
	swap	d1
	neg.w	d1	Return negative result
	bra.s	part12
.next1	tst.w	(a1)
	beq.s	.twoneg
	neg.w	d0
	mulu	d0,d1
	swap	d1
	neg.w	d1
	bra.s	part12
.twoneg	neg.w	d0
	mulu	d0,d1
	swap	d1
part12	add.w	d1,d2
	move.w	d2,z3data
putdot	move.l	d5,a1
	move.w	xpos,d0
	add.w	x3data,d0
	move.w	ypos,d1
	add.w	y3data,d1
	move.w	d0,(a2)+		Save x
	move.w	d1,(a2)+		Save y
	rts

line	cmp.w	d4,d6
	bne.s	.nodot
	cmp.w	d5,d7
	bne.s	.nodot
	
	move.l	movebase,a1	Simply plot a dot!
	mulu	#160,d5
	add.w	d5,a1
	move.w	d4,d5
	and.w	#$fff0,d5
	asr.w	d5
	add.w	d5,a1
	lea	nibbles,a0
	and.w	#$000f,d4
	asl.w	d4
	move.w	(a0,d4.w),d0	Nibble to light
	or.w	d0,(a1)
	rts
	
.nodot	lea	$299a,a4		Real line!
	cmp.w	d5,d7
	beq	horizont		Draw horizontal line
	cmp.w	d4,d6
	beq	vertical		Draw vertical line

	move.l	movebase,a0	Get screenbase
	cmp.w	d4,d6		Compare x1,x2
	bge.s	.ok1		If x2<x1 then jump
	exg	d4,d6
	exg	d5,d7
.ok1	sub.w	d4,d6		x2-x1
	moveq	#0,d1
	move.w	d4,d0		x1 to d0
	not.w	d0		Invert d0 (x1)
	and.w	#$f,d0		Get 0-15
	bset	d0,d1		Set bits in d1
	moveq	#8,d3		8 in d3 (4-plane offset!)
	move.w	#160,d2		Bytes per scanline
	muls	d5,d2		Y1*160
	adda.l	d2,a0		Add to screenbase (start word!)
	asr.w	#4,d4		X1/16
	muls	d3,d4		(X1/16)*16 (x-offset)
	adda.l	d4,a0		Add x1-offset to screenbase
	move.w	#160,d0		Bytes per line
	
	sub.w	d5,d7		d7=Y2-Y1
	bge.s	.ok2		Jump if d7>0
	neg.w	d7
	neg.w	d0		-160
.ok2	movea.w	d0,a1		Move line-add to A1
	cmp.w	d6,d7		Compare (X2-X1) and (Y2-Y1)
	bgt.s	.angle2
	exg	d6,d7
	bra.s	.angle1
	
.angle2	move.w	d6,d4		For more vertical lines
	add.w	d4,d4
	move.w	d4,d5
	sub.w	d7,d4
	move.w	d4,d6
	sub.w	d7,d6
	
.plot1	or.w	d1,(a0)		Draw angled line
	add.w	a1,a0
	tst.w	d4
	bmi.s	.half
	add.w	d6,d4
	ror.w	#1,d1
	bcc.s	.no1
	addq.w	#8,a0
.no1	dbf	d7,.plot1
	rts
.half	add.w	d5,d4
	dbf	d7,.plot1
	rts

.angle1	move.w	d6,d4		For more horizontal lines
	add.w	d4,d4
	move.w	d4,d5
	sub.w	d7,d4
	move.w	d4,d6
	sub.w	d7,d6
	
.plot2	or.w	d1,(a0)		Draw angled line
	;ror.w	#1,d0		d0=x-value (clipping!)
	ror.w	#1,d1
	bcc.s	.no2
	addq.w	#8,a0
.no2	tst.w	d4
	bmi.s	.half2
	add.w	d6,d4
	add.w	a1,a0
	dbf	d7,.plot2
	rts
.half2	add.w	d5,d4
	dbf	d7,.plot2
	rts

horizont	cmp.w	d4,d6		compare x-cords
	bge.s	draw		to fix for left to right
	exg	d4,d6
.ok1	bra.s	draw

linedat	dc.w	$ffff	Data for horizontal lines
	dc.w	$7fff,$3fff,$1fff,$fff
	dc.w	$7ff,$3ff,$1ff,$ff
	dc.w	$7f,$3f,$1f,$f
	dc.w	7,3,1
	dc.w	0
	
draw	move.w	d4,flum		Draw horizontal line
	asr.w	#4,d1		X1/16
	move.w	d6,d2
	move.w	d6,d0
	move.w	d4,d7
	asr.w	#4,d2		X2/16
	moveq	#$f,d3
	and.w	d3,d4		X1(0-31)
	add.w	d4,d4		X1(0-31)*2
	move.w	linedat(pc,d4.w),d4
	and.w	d3,d6		X2(0-31)
	add.w	d6,d6		X2(0-31)*2
	move.w	linedat+2(pc,d6.w),d6
	not.w	d6
	sub.w	d1,d2
;	bne.s	.ok1
;	and.w	d6,d4
.ok1	movea.l	movebase,a1
	mulu	#160,d5
	add.w	d5,a1		Add y
	move.w	flum,d1
	asr.w	#4,d1		X1/16*8
	asl.w	#3,d1
	add.w	d1,a1		Add X2

	move.l	movebase,a2
	add.w	d5,a2		Add y
	
	move.w	d0,d1
	asr.w	#4,d0		X2/16*8
	asl.w	#3,d0
	add.w	d0,a2		Add X2
	cmp.l	a1,a2
	beq.s	.short		Short within one word!
	or.w	d4,(a1)
	addq.l	#8,a1
.ok2	cmp.l	a1,a2
	bne.s	.loop2
	or.w	d6,(a1)	
	rts
.loop2	move.w	#$ffff,(a1)
	addq.l	#8,a1
	cmp.l	a1,a2
	bne.s	.loop2
	or.w	d6,(a1)
	rts
	
.short	sub.w	d7,d1
	move.w	d1,d2
	and.w	d3,d7		X1
	asl.w	d7
	lea	nibbles,a0
	move.w	(a0,d7.w),d1	X1
	clr.w	d4
	rol.w	d4
.loop	or.w	d1,(a1)
	ror.w	d1
	dbra.w	d2,.loop
	rts

vertical	move.l	movebase,a1		Vertical line
	cmp.w	d5,d7
	bhi.s	.ok
	exg	d5,d7
.ok	move.w	d7,d2
	sub.w	d5,d2		D2=Number of pixels!
	
	mulu	#160,d5
	add.w	d5,a1
	move.w	d4,d5
	and.w	#$fff0,d5
	asr.w	d5
	add.w	d5,a1		Start address
	lea	nibbles,a0
	and.w	#$000f,d4
	asl.w	d4
	move.w	(a0,d4.w),d0	Nibble to light
	cmp.w	#0,d2
	bne.s	.loop
	or.w	d0,(a1)
	rts
	
.loop	or.w	d0,(a1)		Draw vertical line
	lea	160(a1),a1
	dbra.w	d2,.loop
	rts
	
fixtxt	move.w	objcnt,d0
	move.l	movebase,a1
	clr.w	negflg2
	bsr	.putchar		Print current point

	lea	objdat2,a0
	move.w	objcnt,d0
	mulu	#6,d0
	add.w	d0,a0
	move.l	movebase,a1
	lea	16(a1),a1
	move.w	(a0)+,d0		Print x,y,z
	clr.w	negflg2
	tst.w	d0
	bpl.s	.ok1
	neg.w	d0
	move.w	#1,negflg2
.ok1	bsr	.putchar
	lea	160*6(a1),a1
	move.w	(a0)+,d0
	clr.w	negflg2
	tst.w	d0
	bpl.s	.ok2
	neg.w	d0
	move.w	#1,negflg2
.ok2	bsr	.putchar
	lea	160*6(a1),a1
	move.w	(a0),d0
	clr.w	negflg2
	tst.w	d0
	bpl.s	.ok3
	neg.w	d0
	move.w	#1,negflg2
.ok3	bsr	.putchar
	rts

.putchar	clr.w	d1		Hundred
	clr.w	d2		Ten
	clr.w	d3		Single
.loop1	cmp.w	#100,d0
	blo.s	.loop2
	add.w	#32,d1		Add one char to 100
	sub.w	#100,d0
	bra.s	.loop1
.loop2	cmp.w	#10,d0
	blo.s	.loop3
	add.w	#32,d2		Add one char to 10
	sub.w	#10,d0
	bra.s	.loop2
.loop3	tst.w	d0
	beq.s	.fixed
	add.w	#32,d3		Add one char to 1
	subq.w	#1,d0
	bra.s	.loop3
.fixed	clr.b	160*2(a1)
	tst.w	negflg2
	move.b	#$78,160*2(a1)
	add.w	d1,a2
	move.b	(a2),1(a1)
	move.b	2(a2),160*1+1(a1)
	move.b	4(a2),160*2+1(a1)
	move.b	6(a2),160*3+1(a1)
	move.b	8(a2),160*4+1(a1)
	add.w	d2,a2
	move.b	(a2),8(a1)
	move.b	2(a2),160*1+8(a1)
	move.b	4(a2),160*2+8(a1)
	move.b	6(a2),160*3+8(a1)
	move.b	8(a2),160*4+8(a1)
	add.w	d3,a2
	move.b	(a2),9(a1)
	move.b	2(a2),160*1+9(a1)
	move.b	4(a2),160*2+9(a1)
	move.b	6(a2),160*3+9(a1)
	move.b	8(a2),160*4+9(a1)
	rts

	
	

*****************************************
*Data				*
*				*

	section	data

objcnt	ds.w	1
linecnt	ds.w	1
	
flum	ds.l	1
nibbles	dc.w	$8000,$4000,$2000,$1000
	dc.w	$800,$400,$200,$100
	dc.w	$80,$40,$20,$10
	dc.w	$8,$4,$2,$1
	


	
sin_tab	incbin	a:\sin_tab2.bin	Angle*8
cos_tab	incbin	a:\cos_tab2.bin	Angle*8 here too..
xmove	dc.w	150,150,150,150,150,150,150,150,150,150,150
	dc.w	150,150,150,150,150,150,150,150,150,150
	dc.w	150,150,150,150,150,150
	dc.w	150,150,150,150,150,150,150,150,150,150,150
	dc.w	150,150,150,150,150,150,150,150,150,150
	;incbin	a:\xdat1.bin
	dc.w	-1
ymove	dc.w	100,100,100,100,100,100,100,100,100,100,100,100,100
	dc.w	100,100,100,100,100,100,100,100,100,100,100,100
	dc.w	100,100,100,100,100,100,100,100,100,100,100,100
	dc.w	100,100,100
	;incbin	a:\ydat1.bin
	dc.w	-1
xcnt	ds.l	1
ycnt	ds.l	1
xpos	ds.l	1
ypos	ds.l	1

xangle	dc.w	0
yangle	dc.w	0
zangle	dc.w	0
x2data	ds.l	1
y2data	ds.l	1
z2data	ds.l	1
x3data	ds.l	1
y3data	ds.l	1
z3data	ds.l	1

linedat2	ds.w	2*100	100 points

linectrl
	dc.w	0,4,4,8,8,12  * s
	dc.w	16,20,20,24,20,28  * e
	dc.w	32,44,32,36,36,40,40,48 * r
	dc.w	52,56,56,60,60,64,64,68 * m
	dc.w	72,76,76,80,80,84,84,72 * o
	dc.w	88,92,92,96,96,100 * n
	dc.w	-1
objdat2
	dc.w	-65,-15,30	* s
	dc.w	-90,0,30
	dc.w	-65,0,30
	dc.w	-90,15,30

	dc.w	-35,-15,30	* e
	dc.w	-60,0,30
	dc.w	-35,0,30
	dc.w	-35,15,30

	dc.w	-30,-15,30      * r
	dc.w	-5,-7,30
	dc.w	-30,0,30
	dc.w	-30,15,30
	dc.w	-5,15,30

	dc.w	0,15,30		* m
	dc.w	5,-15,30
	dc.w	15,-5,30
	dc.w	25,-15,30
	dc.w	30,15,30

	dc.w	35,0,30		* o
	dc.w	47,-15,30
	dc.w	59,0,30
	dc.w	47,15,30

	dc.w	65,15,30	* n
	dc.w	65,-15,30
	dc.w	90,15,30
	dc.w	90,-15,30
	ds.w	3*26	Max 32 points
	
colors	dc.w	0,0,0,0
	dc.w	0,0,0,0
	dc.w	2,2,2,2
	dc.w	0,0,2,2
	dc.w	4,4,4,4
	dc.w	0,0,4,4
	dc.w	2,2,4,4
	dc.w	0,2,4,0
	dc.w	6,6,6,6
	dc.w	0,0,6,6
	dc.w	2,2,6,6
	dc.w	0,2,6,6
	dc.w	4,4,6,6
	dc.w	0,4,6,0
	dc.w	2,4,6,2
	dc.w	0,2,4,6

dotcnt	ds.w	1
maxdots	dc.w	26
negflg2	ds.w	1

*****************************************
*Part of baseprogram		*
*				*

	section	text	

return	move.w	#$2700,sr
	lea	saveints,a1		Return old interupts
	move.b	(a1)+,$fffffa07.w
	move.b	(a1)+,$fffffa09.w
	move.b	(a1)+,$fffffa13.w
	move.b	(a1)+,$fffffa15.w
	move.l	(a1)+,$70.w
	move.l	scrbase,a0		Clear screens
	bsr	clrscr
	move.l	movebase,a0
	bsr	clrscr
	move.w	#$2300,sr
	
	move.w	#37,-(sp)			Wait for next VBL
	trap	#14
	addq.l	#2,sp
	
	move.b	oldres,$ffff8260.w
	move.b	oldscr,$ffff8201.w		Return old screen
	move.b	oldscr+1,$ffff8203.w
	
nochars	btst	#0,$fffffc00.w
	beq.s	cont
	move.b	$fffffc02.w,d0
	bra.s	nochars
	
cont	clr.w	-(sp)			Restore keyboard
	move.w	#11,-(sp)
	trap	#13
	addq.l	#4,sp

	movem.l	retpal,d0-d7		Set a nice return-pal
	movem.l	d0-d7,$ffff8240.w
	
	move.l	#$08000000,$ffff8800.w	Kill sound
	move.l	#$09000000,$ffff8800.w
	move.l	#$0a000000,$ffff8800.w 

	move.w	#$20,-(sp)		Return old stack
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)			Return to calling program
	trap	#1

clrscr	move.w	#7999,d0
.loop	clr.l	(a0)+
	dbra.w	d0,.loop
	rts
music:
	incbin	a:\fletch.mus
	
*DATA DATA DATA DATA DATA DATA DATA DATA DATA*
**********************************************

	section	data

hz	ds.l	1
retpal	dc.w	$000,$777,$777,$777,$777,$777,$777,$777
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777

	section	bss

waitz	ds.w	1
oldscr	ds.w	1
oldres	ds.w	1
scrbase	ds.l	1
movebase	ds.l	1
saveints	ds.l	4

