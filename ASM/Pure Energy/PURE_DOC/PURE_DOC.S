;-------------------------------------------------------------------------------------
; Pure Shit Doc Displayer (originally coded by Mushroom - yet another
; pseudonym for Alex - aka Falcon, Zak, INXS and/or Firehawk ?)
;
; Ripped by: A Totally Evil Bastard
;
; Music added by: A Complete And Utter Shit
;
; Original Source: Pure Shit Utilities Disk No. (can't remember - it was that awful !)
;
;-------------------------------------------------------------------------------------

	opt	o+,ow-

no_of_files	equ	6	; Guess what you change this too !

	text

begin	movea.l	4(a7),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0
	addi.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)		;mshrink
	trap	#1
	lea	12(a7),a7
	move.w	#4,-(a7)		;getrez
	trap	#$e
	addq.l	#2,a7
	cmp.b	#2,d0
	beq	its_hi_res
	move.w	d0,oldrez
	dc.w	$a00a
	bsr	super
	bclr	#0,$484.w
;
; This bit is new !!
;
	moveq	#1,d0		; initialise music
	bsr	music

; change this if required for a different tune/initialisation procedure

	move.l	#music+8,$4d2.w	; put it on the VBL

; the +8 is what you alter to change to another music format

	movea.l	#$ff8240,a0
	movem.l	(a0),d0-d7
	movea.l	#oldcolours,a0
	movem.l	d0-d7,(a0)
	moveq	#1,d0
	bsr	setres
	move.l	$44e.w,scradd
	move.l	#$7770000,$ffff8240.w
	move.l	#0,$ffff8244.w
	bsr	newfile
	movea.l	#textfile,a0
	move.l	a0,textpos
	clr.w	lineno1
	bra	showpage
mainloop	lea	totetext1,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
mainloop1	bsr	getkey
	cmp.l	#$500032,d0
	beq	downpage
	cmp.l	#$480038,d0
	beq	uppage
	cmp.b	#$20,d0
	beq	loadfile
	cmp.b	#$31,d0
	beq	gomarker1
	cmp.b	#$32,d0
	beq	gomarker2
	cmp.b	#$33,d0
	beq	gomarker3
	swap	d0
	cmp.b	#$48,d0
	beq	upline
	cmp.b	#$50,d0
	beq	downline
	cmp.b	#$14,d0
	beq	toptext
	cmp.b	#$4b,d0
	beq	toptext
	cmp.b	#$30,d0		;#'0'
	beq	bot
	cmp.b	#$4d,d0
	beq	bot
	cmp.b	#$78,d0
	beq	setmarker1
	cmp.b	#$79,d0
	beq	setmarker2
	cmp.b	#$7a,d0		;#'z'
	beq	setmarker3
	cmp.b	#$10,d0
	beq	quit
	cmp.b	#$61,d0		;#'a'
	beq	quit
	cmp.b	#$3e,d0
	beq	clrmarkers
	cmp.b	#$3b,d0
	beq	mark_start
	cmp.b	#$3c,d0
	beq	mark_end2
	cmp.b	#$3d,d0
	beq	mark_end1
	cmp.b	#$2e,d0
	beq	changecols
	cmp.b	#$44,d0
	beq	print
	cmp.b	#$62,d0
	beq	help
	bra	mainloop1
getkey	pea	$600ff
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	bne.s	getkey
	move.w	#7,-(a7)		;crawcin
	trap	#1
	addq.l	#2,a7
	rts


upline	sf	eof
	movea.l	textpos,a0
	cmpa.l	#textfile,a0
	bne.s	contup
	clr.w	lineno1
	bra	xdoneall
contup	subq.l	#1,a0
l0005	cmpa.l	#textfile,a0
	ble.s	itstop
	subq.l	#1,a0
	cmpi.b	#$a,(a0)
	bne.s	l0005
	addq.l	#1,a0
	subq.w	#1,lineno1
	bra.s	okup
itstop	lea	textfile(pc),a0
	move.l	a0,textpos
	clr.w	lineno1
	bra.s	okup1
okup	move.l	a0,textpos
okup1	movem.l	a1-a6/d0-d7,-(a7)
	movea.l	scradd,a0
	adda.l	#$5a00,a0
	movea.l	a0,a1
	adda.l	#$500,a0
	move.w	#$12,d0
shiftdown	bsr	doit
	suba.l	#$a00,a0
	suba.l	#$a00,a1
	dbf	d0,shiftdown
	clr.w	d0
	movea.l	textpos,a0
	bsr	pline
	movem.l	(a7)+,a1-a6/d0-d7
	bra	xdoneall
downline	tst.w	eof
	beq	godownthen
	bra	mainloop1
godownthen	movea.l	textpos,a0
	movea.l	a0,a1
l000c	move.b	(a0)+,d2
	cmpi.b	#$d,d2
	beq.s	l000d
	cmpi.b	#0,d2
	bne.s	l000c
	st	eof
	bra	mainloop1
l000d	addq.l	#1,a0
	move.l	a0,textpos
	move.w	#$12,d1
l000e	move.b	(a0)+,d2
	cmpi.b	#$d,d2
	beq.s	l000f
	cmpi.b	#0,d2
	bne.s	l000e
	st	eof
	move.l	a1,textpos
	bra	mainloop1
l000f	dbf	d1,l000e
	addq.l	#1,a0
	cmpa.l	fileend,a0
	ble.s	l0010
	bra	mainloop1
l0010	movem.l	a0-a6/d0-d7,-(a7)
	move.l	a0,-(a7)
	movea.l	scradd,a1
	movea.l	a1,a0
	adda.l	#$500,a1
	move.w	#$12,d0
shiftup	bsr	doit
	dbf	d0,shiftup
	movea.l	(a7)+,a0
	move.w	#$13,d0
	bsr	pline
	movem.l	(a7)+,a0-a6/d0-d7
	addq.w	#1,lineno1
	bra	xdoneall
downpage	movea.l	textpos,a0
	cmpi.b	#0,2(a0)
	beq	xdoneall
	addi.l	#$14,lineno1
	move.w	#$13,d1
downloop	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq	mainloop1
	cmp.b	#$a,d0
	bne.s	downloop
	dbf	d1,downloop
	cmpi.b	#0,-1(a0)
	beq	mainloop1
	move.l	a0,textpos
	addi.w	#$14,lineno1
	bra	showpage
uppage	sf	eof
	move.w	#$14,d1
	movea.l	textpos,a0
	cmpi.l	#textfile,textpos
	bgt	bloop
	clr.w	lineno1
	bra	xdoneall
bloop	move.b	(a0),d0
	subq.l	#1,a0
	cmpa.l	#textfile,a0
	bgt.s	l0016
	move.l	#textfile,textpos
	movea.l	textpos,a0
	clr.w	lineno1
	bra	showpage
l0016	cmp.b	#$a,d0
	bne.s	bloop
	dbf	d1,bloop
	addq.l	#2,a0
	move.l	a0,textpos
	subi.w	#$14,lineno1
	bra	showpage
toptext	lea	textfile,a0
	move.l	a0,textpos
	sf	eof
	clr.w	lineno1
	bra	showpage
bot	tst.w	eof
	bne	xdoneall
	move.w	bottomno,lineno1
	movea.l	bottom1,a0
	move.l	a0,textpos
	bra	showpage
mark_start	movea.l	textpos,a0
	sf	eof
	move.l	a0,markstart
	bra	showpage
mark_end1	movea.l	textpos,a0
	sf	eof
	move.l	a0,markend
	bra	showpage
mark_end2	movea.l	textpos,a0
	cmpi.b	#0,2(a0)
	beq.s	bendx
	move.w	#$13,d1
bendloop	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq.s	bendx
	cmp.b	#$a,d0
	bne.s	bendloop
	dbf	d1,bendloop
	cmpi.b	#0,(a0)
	bne.s	bendcont
bendx	movea.l	fileend,a0
	subq.l	#1,a0
bendcont	move.l	a0,markend
	sf	eof
	movea.l	textpos,a0
	bra	showpage
clrmarkers	clr.l	markstart
	clr.l	markend
	sf	eof
	movea.l	textpos,a0
	bra	showpage
changecols	not.w	$ffff8240.w
	not.w	$ffff8242.w
	not.w	$ffff8244.w
	not.w	$ffff8246.w
	bra	mainloop1
setmarker1	movea.l	textpos,a0
	move.l	a0,marker1
	move.w	lineno1,marker1line
	bra	mainloop1
setmarker2	movea.l	textpos,a0
	move.l	a0,marker2
	move.w	lineno1,marker2line
	bra	mainloop1
setmarker3	movea.l	textpos,a0
	move.l	a0,marker3
	move.w	lineno1,marker3line
	bra	mainloop1
gomarker1	tst.l	marker1
	beq	mainloop
	movea.l	marker1,a0
	move.l	a0,textpos
	sf	eof
	move.w	marker1line,lineno1
	bra	showpage
gomarker2	tst.l	marker2
	beq	mainloop
	movea.l	marker2,a0
	move.l	a0,textpos
	sf	eof
	move.w	marker2line,lineno1
	bra	showpage
gomarker3	tst.l	marker3
	beq	mainloop
	movea.l	marker3,a0
	move.l	a0,textpos
	sf	eof
	move.w	marker3line,lineno1
	bra	showpage
doneall	move.w	lineno1,d0
	lea	showing1,a0
	bsr	todecimal
	move.w	lineno1,d0
	addi.w	#$13,d0
	move.w	lines,d1
	cmp.w	d0,d1
	bgt.s	doneall1
	move.w	lines,d0
	lea	showing2,a0
	bsr	todecimal
	bra	doneall2
doneall1	lea	showing2,a0
	bsr	todecimal
doneall2	lea	showingx,a0
	move.w	#$16,d0
	bsr	pline
	bra	mainloop
xdoneall	move.w	lineno1,d0
	lea	showing1,a0
	bsr	todecimal
	move.w	lineno1,d0
	addi.w	#$13,d0
	move.w	lines,d1
	cmp.w	d0,d1
	bgt.s	xdoneall1
	move.w	lines,d0
	lea	showing2,a0
	bsr	todecimal
	bra	xdoneall2
xdoneall1	lea	showing2,a0
	bsr	todecimal
xdoneall2	lea	showingx,a0
	move.w	#$16,d0
	bsr	pline
	bra	mainloop1
showpage	move.w	#0,d0
	clr.w	lineno2
l002e	bsr.s	pline
	tst.w	eof
	bne.s	endoftext
	addq.w	#1,d0
	cmp.w	#$14,d0
	bge.s	gorts

	bra.s	l002e
gorts
	bra	doneall
endoftext	lea	endspaces,a0
	bsr.s	pline
	addq.w	#1,d0
	cmp.w	#$14,d0
	bge.s	gorts

	bra.s	endoftext
pline	bsr	clearbuff
	move.w	d0,d1
	mulu	#$500,d1
	lea	linebuffer,a1
	movea.l	scradd,a2
	adda.l	d1,a2
	move.l	a2,screenpos
lineloop	clr.l	d2
	move.b	(a0)+,d2
	tst.b	d2
	bne.s	l0033
	st	eof
	bra	endofline
l0033	cmpi.b	#$d,d2
	beq	endofline
	cmpi.b	#9,d2
	beq	tab
	bsr.s	dochar
	addq.l	#1,a1
	move.b	(a0)+,d2
	tst.b	d2
	bne.s	l0034
	st	eof
	bra	endofline
l0034	cmpi.b	#$d,d2
	beq	endofline
	cmpi.b	#9,d2
	beq	tab
	bsr.s	dochar
	addq.l	#3,a1
	bra.s	lineloop
dochar	lea	font(pc),a2
	adda.w	d2,a2
	move.b	(a2),(a1)
	move.b	256(a2),160(a1)
	move.b	512(a2),320(a1)
	move.b	768(a2),480(a1)
	move.b	1024(a2),640(a1)
	move.b	1280(a2),800(a1)
	move.b	1536(a2),960(a1)
	move.b	1792(a2),1120(a1)
	cmpa.l	markstart,a0
	ble.s	noblock
	cmpa.l	markend,a0
	bge.s	noblock
	tst.l	markend
	beq	noblock
	andi.b	#$55,(a1)
	andi.b	#$55,160(a1)
	andi.b	#$55,320(a1)
	andi.b	#$55,480(a1)
	andi.b	#$55,640(a1)
	andi.b	#$55,800(a1)
	andi.b	#$55,960(a1)
	andi.b	#$55,1120(a1)
noblock	rts

tab	move.l	a1,d3
	btst	#0,d3
	beq.s	nexttab
	clr.b	(a1)
	clr.b	160(a1)
	clr.b	320(a1)
	clr.b	480(a1)
	clr.b	640(a1)
	clr.b	800(a1)
	clr.b	960(a1)
	clr.b	1120(a1)
	addq.l	#3,a1
nexttab	clr.w	(a1)
	clr.w	160(a1)
	clr.w	320(a1)
	clr.w	480(a1)
	clr.w	640(a1)
	clr.w	800(a1)
	clr.w	960(a1)
	clr.w	1120(a1)
	addq.l	#4,a1
nexttab1	move.l	a1,d2
	lea	linebuffer,a3
	sub.l	a3,d2
	divu	#$a0,d2
	swap	d2
	tst.w	d2
	beq	startofline
	andi.l	#$ffff,d2
	divu	#$10,d2
	swap	d2
	divu	#$a,d2
	swap	d2
	tst.b	d2
	beq.s	donetab
startofline	clr.w	(a1)
	clr.w	160(a1)
	clr.w	320(a1)
	clr.w	480(a1)
	clr.w	640(a1)
	clr.w	800(a1)
	clr.w	960(a1)
	clr.w	1120(a1)
	addq.l	#4,a1
	bra.s	nexttab1
donetab	clr.l	d2
	bra	lineloop
endofline	movem.l	a0-a6/d0-d7,-(a7)
	lea	linebuffer,a1
	movea.l	screenpos,a0
	bsr	doit
	movem.l	(a7)+,a0-a6/d0-d7
	addq.l	#1,a0
	rts

clearbuff	move.l	a0,-(a7)
	lea	linebuffer,a0
	clr.l	d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6
	movem.l	a2-a6/d1-d7,(a0)
	movem.l	a2-a6/d1-d7,48(a0)
	movem.l	a2-a6/d1-d7,96(a0)
	movem.l	a2-a6/d1-d7,144(a0)
	movem.l	a2-a6/d1-d7,192(a0)
	movem.l	a2-a6/d1-d7,240(a0)
	movem.l	a2-a6/d1-d7,288(a0)
	movem.l	a2-a6/d1-d7,336(a0)
	movem.l	a2-a6/d1-d7,384(a0)
	movem.l	a2-a6/d1-d7,432(a0)
	movem.l	a2-a6/d1-d7,480(a0)
	movem.l	a2-a6/d1-d7,528(a0)
	movem.l	a2-a6/d1-d7,576(a0)
	movem.l	d1-d4,624(a0)
	lea	640(a0),a0
	movem.l	a2-a6/d1-d7,(a0)
	movem.l	a2-a6/d1-d7,48(a0)
	movem.l	a2-a6/d1-d7,96(a0)
	movem.l	a2-a6/d1-d7,144(a0)
	movem.l	a2-a6/d1-d7,192(a0)
	movem.l	a2-a6/d1-d7,240(a0)
	movem.l	a2-a6/d1-d7,288(a0)
	movem.l	a2-a6/d1-d7,336(a0)
	movem.l	a2-a6/d1-d7,384(a0)
	movem.l	a2-a6/d1-d7,432(a0)
	movem.l	a2-a6/d1-d7,480(a0)
	movem.l	a2-a6/d1-d7,528(a0)
	movem.l	a2-a6/d1-d7,576(a0)
	movem.l	d1-d4,624(a0)
	movea.l	(a7)+,a0
	rts

doit	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,48(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,96(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,144(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,192(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,240(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,288(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,336(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,384(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,432(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,480(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,528(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,576(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,624(a0)
	lea	640(a0),a0
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,48(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,96(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,144(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,192(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,240(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,288(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,336(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,384(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,432(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,480(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,528(a0)
	movem.l	(a1)+,a2-a6/d1-d7
	movem.l	a2-a6/d1-d7,576(a0)
	movem.l	(a1)+,d1-d4
	movem.l	d1-d4,624(a0)
	lea	640(a0),a0
	rts

print	bsr	cls
	lea	potext,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
print1	move.l	linespp,d0
	movea.l	#lppx,a0
	bsr	todecimal
	move.w	#$15,d0
	lea	lpptext,a0
	bsr	pline
	bsr	showblk
	bsr	showpall
printopts	bsr	getkey
	cmp.l	#$500032,d0
	beq	down10lpp
	cmp.l	#$480038,d0
	beq	up10lpp
	swap	d0
	cmp.b	#$3b,d0
	beq	cptype
	cmp.b	#$3c,d0
	beq	cpmode
	cmp.b	#$3d,d0
	beq	cpport
	cmp.b	#$52,d0
	beq	restorelpp
	cmp.b	#$48,d0
	beq	uplpp
	cmp.b	#$50,d0
	beq	downlpp
	cmp.b	#$43,d0
	beq	printblock
	cmp.b	#$44,d0
	beq	printall
	cmp.b	#$10,d0
	beq	mainloop
	cmp.b	#$61,d0		;#'a'
	beq	doneprint
	bra.s	printopts
doneprint	bsr	cls
	movea.l	textpos,a0
	sf	eof
	bra	showpage
cptype	move.w	pconfig,d0
	btst	#2,d0
	beq	toepson
	bclr	#2,d0
	bra	okptype
toepson	bset	#2,d0
okptype	move.w	d0,pconfig
	btst	#2,d0
	beq	typeatari
	lea	pepson,a0
	lea	pttype,a1
	bra.s	xtype
typeatari	lea	patari,a0
	lea	pttype,a1
xtype	move.w	#$15,d0
typechange	move.b	(a0)+,(a1)+
	dbf	d0,typechange
	bra	print1
cpmode	move.w	pconfig,d0
	btst	#3,d0
	beq	toquality
	bclr	#3,d0
	bra.s	okpmode
toquality	bset	#3,d0
okpmode	move.w	d0,pconfig
	btst	#3,d0
	beq	modedraft
	lea	pquality,a0
	lea	ptmode,a1
	bra.s	xtype
modedraft	lea	pdraft,a0
	lea	ptmode,a1
	bra.s	xtype
cpport	move.w	pconfig,d0
	btst	#4,d0
	beq	tors232
	bclr	#4,d0
	bra.s	okpport
tors232	bset	#4,d0
okpport	move.w	d0,pconfig
	btst	#4,d0
	beq	portcent
	lea	prs232,a0
	lea	ptport,a1
	bra	xtype
portcent	lea	pcentron,a0
	lea	ptport,a1
	bra	xtype
showblk	movea.l	markstart,a2
	movea.l	markend,a3
ploop	move.b	(a2)+,d0
	cmpa.l	a2,a3
	blt.s	donep
	cmp.b	#$d,d0
	bne.s	ploop
	addq.l	#1,d5
	bra.s	ploop
donep	move.l	linespp,d4
	divu	d4,d5
	move.l	d5,d3
	swap	d3
	tst.w	d3
	beq.s	notadd
	addq.l	#1,d5
notadd	andi.l	#$ffff,d5
	move.l	d5,d0
	lea	blknopages(pc),a0
	bsr	todecimal
	lea	blkprint1,a0
	move.w	#$16,d0
	bsr	pline
	rts

showpall	lea	textfile,a2
	movea.l	fileend,a3
ploop1	move.b	(a2)+,d0
	cmpa.l	a2,a3
	blt.s	donep1
	cmp.b	#$d,d0
	bne.s	ploop1
	addq.l	#1,d5
	bra.s	ploop1
donep1	move.l	linespp,d4
	divu	d4,d5
	move.l	d5,d3
	swap	d3
	tst.w	d3
	beq.s	notadd1
	addq.l	#1,d5
notadd1	andi.l	#$ffff,d5
	move.l	d5,d0
	lea	allnopages(pc),a0
	bsr	todecimal
	lea	allprint1,a0
	move.w	#$17,d0
	bsr	pline
	rts

printblock	tst.l	markstart
	beq	print1
	tst.l	markend
	beq	print1
	lea	blknopages,a0
	lea	pall,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	movea.l	markstart,a0
	movea.l	markend,a1
	bra	printer
printall	lea	allnopages,a0
	lea	pall,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	lea	textfile,a0
	movea.l	fileend,a1
printer	movea.l	a0,a2
	movea.l	a1,a3
	clr.l	d5
	movem.l	a0-a6/d0-d7,-(a7)
	bsr	cls
	lea	printing,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
	move.w	pconfig,-(a7)
	move.w	#$21,-(a7)		;setprt
	trap	#$e
	addq.l	#4,a7
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	#0,pagesdone
	clr.l	d5
prtloop1	addq.l	#1,pagesdone
	bsr.s	pagexofx
	move.w	linespp,d7
	subq.w	#1,d7
prtloop	move.w	#$ff,-(a7)
	move.w	#6,-(a7)		;crawio
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	beq.s	nokey
	bra	quitprint
nokey	move.b	(a0)+,d5
	cmpa.l	a0,a1
	bgt.s	printchar
	bsr.s	newpage
	bra	doneprint
printchar	move.w	d5,-(a7)
	move.w	d5,-(a7)
	move.w	#5,-(a7)		;cprnout
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	beq	quitprint
	move.w	(a7)+,d5
	cmp.b	#$a,d5
	bne.s	cont
	dbf	d7,prtloop
	bsr.s	newpage
	bra.s	prtloop1
cont	bra.s	prtloop
newpage	move.w	#$c,-(a7)
	move.w	#5,-(a7)		;cprnout
	trap	#1
	addq.l	#4,a7
	rts

pagexofx	movem.l	a0-a6/d0-d7,-(a7)
	move.l	pagesdone,d0
	lea	pdone,a0
	bsr	todecimal
	lea	going,a0
	move.w	#$16,d0
	bsr	pline
	movem.l	(a7)+,a0-a6/d0-d7
	rts

	bra	print
quitprint	lea	printerror1,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
	lea	printerror2,a0
	move.w	#$16,d0
	bsr	pline
	bsr	getkey
	bra	print
restorelpp	move.l	#$40,linespp
	bra	print1
down10lpp	subi.l	#$a,linespp
	cmpi.l	#1,linespp
	bge	print1
	move.l	#1,linespp
	bra	print1
up10lpp	addi.l	#$a,linespp
	cmpi.l	#$3e8,linespp
	ble	print1
	move.l	#$3e8,linespp
	bra	print1
downlpp	subq.l	#1,linespp
	cmpi.l	#1,linespp
	bge	print1
	move.l	#1,linespp
	bra	print1
uplpp	addq.l	#1,linespp
	cmpi.l	#$3e8,linespp
	ble	print1
	move.l	#$3e8,linespp
	bra	print1
	move.l	linespp,d0
	movea.l	#lppx,a0
	bsr	todecimal
	move.w	#$14,d0
	lea	lpptext,a0
	bsr	pline
	bra	printopts
invert	movem.l	a1/d0,-(a7)
	movea.l	scradd,a1
	mulu	#$500,d0
	adda.w	d0,a1
	move.w	#$27,d0
inv1	not.w	(a1)
	not.w	160(a1)
	not.w	320(a1)
	not.w	480(a1)
	not.w	640(a1)
	not.w	800(a1)
	not.w	960(a1)
	not.w	1120(a1)
	addq.l	#4,a1
	dbf	d0,inv1
	movem.l	(a7)+,a1/d0
	rts

todecimal	andi.l	#$ffff,d0
	divu	#$3e8,d0
	addi.b	#$30,d0
	move.b	d0,(a0)+
	swap	d0
	andi.l	#$ffff,d0
	divu	#$64,d0
	addi.b	#$30,d0
	move.b	d0,(a0)+
	swap	d0
	andi.l	#$ffff,d0
	divu	#$a,d0
	addi.b	#$30,d0
	move.b	d0,(a0)+
	swap	d0
	andi.l	#$ffff,d0
	addi.b	#$30,d0
	move.b	d0,(a0)+
	rts

cls	clr.w	d0
cls1	lea	endspaces,a0
	bsr	pline
	addq.w	#1,d0
	cmp.w	#$18,d0
	beq.s	clsend
	bra.s	cls1
clsend	rts

help	bsr.s	cls
	lea	helptextf1,a0
	bsr	showhelp1
	lea	hlinesf1,a6
	bsr	boxlinea
helpwait	lea	helptexta,a0
	move.w	#$17,d0
	bsr	pline
	bsr	invert
	bsr	getkey
	swap	d0
	cmp.b	#$3b,d0
	bne	helpf2
	bsr.s	cls
	lea	helptextf1,a0
	bsr	showhelp1
	lea	hlinesf1,a6
	bsr	boxlinea
	bra.s	helpwait
helpf2	cmp.b	#$3c,d0
	bne	helpundo
	bsr.s	cls
	lea	helptextf2,a0
	bsr	showhelp1
	lea	hlinesf2,a6
	bsr	boxlinea
helpundo	cmp.b	#$61,d0		;#'a'
	bne.s	helpwait
	bsr	cls
	movea.l	textpos,a0
	sf	eof
	bra	showpage
showhelp1	sf	eof
	move.w	#0,d0
hloop	bsr	pline
	tst.w	eof
	bne.s	endofhelp
	addq.w	#1,d0
	cmp.w	#$16,d0
	bge.s	gohrts

	bra.s	hloop
gohrts
	rts

endofhelp	lea	endspaces,a0
	bsr	pline
	addq.w	#1,d0
	cmp.w	#$16,d0
	bge.s	gohrts

	bra.s	endofhelp

boxlinea	dc.w	$a000
	movea.l	a0,a4
drawloop	movea.l	a6,a1
	cmpi.w	#$ffff,(a1)
	beq.s	exit_draw
	move.w	(a1),38(a4)
	move.w	2(a1),40(a4)
	move.w	4(a1),42(a4)
	move.w	6(a1),44(a4)
	move.w	#$ff,24(a4)
	move.w	#0,26(a4)
	move.w	#0,28(a4)
	move.w	#0,30(a4)
	move.w	#$ffff,34(a4)
	move.w	#1,36(a4)
	move.w	#$ffff,32(a4)
	dc.w	$a003
	addq.l	#8,a6
	bra.s	drawloop
exit_draw	rts

loadfile	bsr.s	newfile
	sf	eof
	clr.w	lineno1
	lea	textfile,a0
	move.l	a0,textpos
	bra	showpage
newfile	bsr	cls
	movea.l	#$ff8240,a0
	movem.l	(a0),d0-d7
	movea.l	#stcolours,a1
	movem.l	d0-d7,(a1)
	movea.l	#loadtext2a,a0
	clr.w	d0
	bsr	pline
	bsr	invert
	movea.l	#loadtext2b,a0
	moveq	#2,d0
	bsr	pline
	bsr	redraw
sfileloop	bsr	getkey
	swap	d0
	cmp.b	#$48,d0
	bne	trydownarr
	subq.w	#1,selectfile
	cmpi.w	#0,selectfile
	bge.s	fnottop
	move.w	#0,selectfile
	bra.s	sfileloop
fnottop	bsr	redraw
	bra.s	sfileloop
trydownarr	cmp.b	#$50,d0
	bne.s	tryok
	addq.w	#1,selectfile
	cmpi.w	#(no_of_files-1),selectfile		;	no	of	files	!!
	ble.s	fnotbottom
	move.w	#(no_of_files-1),selectfile
	bra.s	sfileloop
fnotbottom	bsr	redraw
	bra.s	sfileloop
tryok	swap	d0
	cmp.b	#$20,d0
	bne.s	trycancel
	bra	gothen
trycancel	swap	d0
	cmp.b	#$61,d0		;#'a'
	bne.s	sfileloop
	bra	noload
redraw	move.w	#(no_of_files-1),d0
	move.w	#0,d1
donextl	lea	filetab(pc),a6
	move.w	d1,d4
	lsl.w	#3,d4
	movea.l	0(a6,d4.w),a0
	movem.l	d0-d7,-(a7)
	bsr	pline
	movem.l	(a7)+,d0-d7
	addq.w	#1,d0
	addq.w	#1,d1
	cmp.w	#(no_of_files-1),d1		;	no	of	files	?
	ble.s	donextl
	movea.l	scradd,a0
	move.w	selectfile,d3
	mulu	#$500,d3
	addi.w	#$1900,d3
	adda.w	d3,a0
	adda.w	#$40,a0
	move.w	#6,d3
xyzloop	not.w	(a0)
	not.w	160(a0)
	not.w	320(a0)
	not.w	480(a0)
	not.w	640(a0)
	not.w	800(a0)
	not.w	960(a0)
	not.w	1120(a0)
	addq.l	#4,a0
	dbf	d3,xyzloop
	rts

gothen	move.w	selectfile,d0
	lsl.w	#3,d0
	lea	filetab,a0
	movea.l	4(a0,d0.w),a6
	movem.l	a0-a6/d0-d7,-(a7)
	bsr	cls
	lea	loadtext1,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
	movem.l	(a7)+,a0-a6/d0-d7
	clr.l	markstart
	clr.l	markend
	lea	textfile(pc),a0
	move.w	#$f424,d0
clrte
xtblk	clr.l	(a0)+
	dbf	d0,clrte

	bsr	unsuper
	move.w	#0,-(a7)
	move.l	a6,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	move.w	d0,handle
	pea	textfile
	move.l	#$3d08f,-(a7)
	move.w	handle,-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	adda.l	#$c,a7
	move.w	handle,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
	bsr	super
	lea	textfile,a0
	cmpi.l	#$49434521,(a0)
	bne.s	findend
	lea	depacktext,a0
	move.w	#$14,d0
	bsr	pline
	bsr	invert
	lea	textfile,a0
	bsr	ice_decrunch_2
findend	lea	textfile(pc),a0
endloop	cmpi.b	#0,(a0)+
	bne.s	endloop
	subq.l	#1,a0
	move.l	a0,fileend
	move.w	#$13,d1
	movea.l	fileend,a0
botloop	move.b	(a0),d0
	subq.l	#1,a0
	cmpa.l	#textfile,a0
	bge.s	l0089
	move.l	#textfile,bottom1
	bra.s	getlno
l0089	cmp.b	#$a,d0
	bne.s	botloop
	dbf	d1,botloop
	addq.l	#2,a0
	move.l	a0,bottom1
getlno	lea	textfile(pc),a1
	clr.w	d1
rbotno	move.b	(a1)+,d0
	cmpa.l	a0,a1
	beq.s	donebotno
	cmp.b	#$d,d0
	bne.s	rbotno
	addq.w	#1,d1
	bra.s	rbotno
donebotno	move.w	d1,bottomno
	lea	textfile(pc),a0
	clr.w	lines
rlines	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq.s	donelines
	cmp.b	#$d,d0
	bne.s	rlines
	addq.w	#1,lines
	bra.s	rlines
donelines	cmpi.b	#$a,-2(a0)
	beq	noload
	addq.l	#1,lines
noload	movea.l	#stcolours,a1
	movem.l	(a1),d0-d7
	movea.l	#$ff8240,a0
	movem.l	d0-d7,(a0)
	tst.b	textfile
	beq	quit
	rts


quit	move.w	oldrez,d0
	bsr	setres
	bset	#0,$484.w

	bsr	music+4
	clr.l	$4d2.w

	lea	oldcolours,a0
	movem.l	(a0),d0-d7
	lea	$ff8240.l,a0
	movem.l	d0-d7,(a0)
	move.l	oldstack,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7

its_hi_res	clr.w	-(a7)		;pterm0
	trap	#1

super	move.l	#1,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	tst.w	d0
	bne.s	exitsuper
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,oldstack
exitsuper	rts


unsuper	move.l	#1,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	tst.l	d0
	beq.s	exitun
	move.l	oldstack,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
exitun	rts


setres	move.w	d0,-(a7)
	pea	$ffffffff.w
	pea	$ffffffff.w
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	lea	12(a7),a7
	rts

;---------------------------------------------------------------
;
; A0 - A0 ICE PACKER v2.4 Decruncher (only one that works on the Falcon ?)
;
ice_decrunch_2	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr	l009f
	bsr.s	l009f
	lea	-8(a0,d0.l),a5
	bsr.s	l009f
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l0098	move.b	-(a1),-(a3)
	dbf	d0,l0098
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	l00a1
	movea.l	a3,a5
	bsr	l00a5
	bcc.s	l009c
	move.w	#$f9f,d7
	bsr	l00a5
	bcc.s	l0099
	moveq	#$f,d0
	bsr	l00a7
	move.w	d1,d7
l0099	moveq	#3,d6
l009a	move.w	-(a3),d4
	moveq	#3,d5
l009b	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,l009b
	dbf	d6,l009a
	movem.w	d0-d3,(a3)
	dbf	d7,l0099
l009c	movem.l	(a7),a0-a3/d0-d7
l009d	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l009d
	moveq	#$77,d0
l009e	move.b	-(a3),-(a5)
	dbf	d0,l009e
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l009f	moveq	#3,d1
l00a0	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l00a0
	rts

l00a1	bsr.s	l00a5
	bcc.s	l00a4
	moveq	#0,d1
	bsr.s	l00a5
	bcc.s	l00a3
	lea	l00b2(pc),a1
	moveq	#4,d3
l00a2	move.l	-(a1),d0
	bsr.s	l00a7
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l00a2
	add.l	20(a1),d1
l00a3	move.b	-(a5),-(a6)
	dbf	d1,l00a3
l00a4	cmpa.l	a4,a6
	bgt.s	l00aa
	rts

l00a5	add.b	d7,d7
	bne.s	l00a6
	move.b	-(a5),d7
	addx.b	d7,d7
l00a6	rts

l00a7	moveq	#0,d1
l00a8	add.b	d7,d7
	bne.s	l00a9
	move.b	-(a5),d7
	addx.b	d7,d7
l00a9	addx.w	d1,d1
	dbf	d0,l00a8
	rts

l00aa	lea	l00b3(pc),a1
	moveq	#3,d2
l00ab	bsr.s	l00a5
	dbcc	d2,l00ab
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l00ac
	bsr.s	l00a7
l00ac	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l00ae
	lea	l00b4(pc),a1
	moveq	#1,d2
l00ad	bsr.s	l00a5
	dbcc	d2,l00ad
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l00a7
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	l00b0
	sub.w	d4,d1
	bra.s	l00b0
l00ae	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	l00a5
	bcc.s	l00af
	moveq	#8,d0
	moveq	#$3f,d2
l00af	bsr.s	l00a7
	add.w	d2,d1
l00b0	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l00b1	move.b	-(a1),-(a6)
	dbf	d4,l00b1
	bra	l00a1
	dc.b	$7f,$ff,0,$e,0,$ff,0,7
	dc.b	0,7,0,2,0,3,0,1
	dc.b	0,3,0,1
l00b2	dc.b	0,0,1,$d,0,0,0,$e
	dc.b	0,0,0,7,0,0,0,4
	dc.b	0,0,0,1
l00b3	dc.b	9,1,0,$ff,$ff,8,4,2
	dc.b	1,0
l00b4	dc.b	$b,4,7,0,1,$1f,$ff,$ff
	dc.b	0,$1f
;---------------------------------------------------------------

loadtext1	dc.b	'                        Loading text file  -  Please wait',13,10
	dc.b	0
loadtext2a	dc.b	'          Pure Energy In 93  Coded By Mushromm -  Please select a file          '
	dc.b	'        ',13,10
	dc.b	0
loadtext2b	dc.b	0,'Use UP/DOWN arrows to select, SPACE will load the inversed file, UNDO to cancel',13
	dc.b	10
	dc.b	0
depacktext	dc.b	'                           Depacking - ICE Packer 2.4 File',13,10
	dc.b	0
helptexta	dc.b	' HELP  PAGE  -  F1 for NORMAL COMMANDS,  F2 for PRINT COMMANDS,  UNDO to exit.',13,10
	dc.b	0,0,'                      This displayer was coded by MUSHROOM',13,10
	dc.b	0,0,'      Greets go to other members of Talk of The East, TBE, Bacchus, and you',13,10
	dc.b	0
helptextf1	dc.b	13,10
	dc.b	'  ',9,'                      Normal Commands',13,10
	dc.b	13,10
	dc.b	'    KEY(s)                                 ACTION',13,10
	dc.b	13,10
	dc.b	'    cursor up                              up 1 line',13,10
	dc.b	'    shift-cursor up                        up 1 page (20 lines)',13,10
	dc.b	'    cursor down                            down 1 line',13,10
	dc.b	'    shift-cursor down                      down 1 page (20 lines)',13,10
	dc.b	'    alt-T or cursor left                   goto top of document',13,10
	dc.b	'    alt-B or cursor right                  goto bottom of document',13,10
	dc.b	'    alt-1 / 1                              set / goto marker 1',13,10
	dc.b	'    alt-2 / 2                              set / goto marker 2',13,10
	dc.b	'    alt-3 / 3                              set / goto marker 3',13,10
	dc.b	'    HELP                                   obvious!',13,10
	dc.b	'    SPACE                                  load a new file',13,10
	dc.b	'    alt-C                                  invert colours',13,10
	dc.b	'    UNDO or alt-Q                          quit',13,10
	dc.b	0
helptextf2	dc.b	13,10
	dc.b	'  ',9,'                       Print Commands',13,10
	dc.b	13,10
	dc.b	'    KEY(s)                                 ACTION',13,10
	dc.b	13,10
	dc.b	'    F1                                     Mark start of block',13,10
	dc.b	'    F2                                     Mark end of block at bottom',13,10
	dc.b	'    F3                                     Mark end of block to top',13,10
	dc.b	'    F4                                     Clear block markers',13,10
	dc.b	'    F10                                    Enter printing and print options',13,10
	dc.b	13,10
	dc.b	'    When in the print menu the following keys have the corresponding effect.',13,10
	dc.b	13,10
	dc.b	'    F1                                     Toggle printer type',13,10
	dc.b	'    F2                                     Toggle printer mode',13,10
	dc.b	'    F3                                     Toggle printer port',13,10
	dc.b	'    F9                                     Print marked block',13,10
	dc.b	'    F10                                    Print all of the textfile',13,10
	dc.b	'    (shift) cursor up                      increases lines per page by (10) 1',13,10
	dc.b	'    (shift) cursor down                    decreases lines per page by (10) 1',13,10
	dc.b	'    INSERT                                 restore lines per page (64)',13,10
	dc.b	'    UNDO                                   return to main menu',13,10
	dc.b	0,0,27,'E',0
totetext1	dc.b	'     Pure Energy Doc Displayer V.1   -   Press HELP for instructions',13,10
	dc.b	0
printerror1	dc.b	'                    Error or key press occurred during printing.',13,10
	dc.b	0
printerror2	dc.b	'                       Press any key to return to print menu.',13,10
	dc.b	0
printing	dc.b	'                         PRINTING - PRESS ANY KEY TO CANCEL',13,10
	dc.b	0
going	dc.b	'                             PRINTING PAGE '
pdone	dc.b	'0000 OF '
pall	dc.b	'0000',13,10
	dc.b	0
showingx	dc.b	'Current lines being displayed  : '
showing1	dc.b	'0000 - '
showing2	dc.b	'0000',13,10
	dc.b	0
patari	dc.b	'F1 - Atari printer  ',13,10
pepson	dc.b	'F1 - Epson printer  ',13,10
pquality	dc.b	'F2 - Quality mode   ',13,10
pdraft	dc.b	'F2 - Draft mode     ',13,10
prs232	dc.b	'F3 - RS-232 port    ',13,10
pcentron	dc.b	'F3 - Centronics port',13,10
potext	dc.b	'  PRINT AND PRINT-OPTIONS     F9 - Print block, F10 - Print all, UNDO - Exit',13,10
	dc.b	0
lpptext	dc.b	'Number of lines per page       : '
lppx	dc.b	'0000           '
pttype	dc.b	'F1 - Epson printer  ',13,10
	dc.b	0
blkprint1	dc.b	'NUMBER OF PAGES MARKED BY BLOCK: '
blknopages	dc.b	'0000           '
ptmode	dc.b	'F2 - Draft mode     ',13,10
	dc.b	0
allprint1	dc.b	'NUMBER OF PAGES IN WHOLE TEXT  : '
allnopages	dc.b	'0000           '
ptport	dc.b	'F3 - Centronics port',13,10
	dc.b	0
endspaces	dc.b	'                                                                                '
	dc.b	13,10
font	dc.w	$18,$3c18,$183c,$ffe7,$17e,$1818,$f0f0,$5a0,$7c06,$7c7c,$c67c,$7c7c
	dc.w	$7c7c,$78,$7f0,$1104,$18,$6600,$1800,$3818,$e70,0,0,2
	dc.w	$3c18,$3c7e,$c7e,$3c7e,$3c3c,0,$600,$603c,$3c18,$7c3c,$787e,$7e3e
	dc.w	$663c,$666,$60c6,$663c,$7c3c,$7c3c,$7e66,$66c6,$6666,$7e1e,$4078,$1000
	dc.w	0,$6000,$600,$1c00,$6018,$1860,$3800,0,0,0,0,0
	dc.w	0,$e,$1870,0,$66,$c18,$6630,$1800,$1866,$3066,$1860,$6618
	dc.w	$c00,$3f18,$6630,$1830,$6666,$6618,$1c66,$1c1e,$c0c,$c0c,$3434,0
	dc.w	0,$c6,$c600,$1bd8,$3434,$200,$7f,$3034,$3466,$c00,$7a7e,$7ef1
	dc.w	$66f6,0,0,0,0,$6000,$60,0,0,0,0,0
	dc.w	0,0,$e,$66,$1c,0,$fe00,0,$3c00,$1c,$c00,$3e3c
	dc.w	$18,$300c,$18,$1800,$3838,0,$3838,$7800,$3c,$241c,$3899,$ffc3
	dc.w	$3c3,$3c1c,$c0c0,$5a0,$c606,$606,$c6c0,$c006,$c6c6,$60,$ff8,$b28
	dc.w	$18,$666c,$3e66,$6c18,$1c38,$6618,0,6,$6638,$660c,$1c60,$6006
	dc.w	$6666,$1818,$c00,$3066,$663c,$6666,$6c60,$6060,$6618,$66c,$60ee,$7666
	dc.w	$6666,$6666,$1866,$66c6,$6666,$618,$6018,$3800,$c000,$6000,$600,$3000
	dc.w	$6000,$60,$1800,0,0,0,$1800,0,0,$18,$1818,$6018
	dc.w	$3c00,$1866,$18,$1800,$6600,$1800,$6630,0,$1800,$7866,$18,$6618
	dc.w	0,$18,$3a66,$3630,$1818,$1818,$5858,$3c3c,$1800,$cc,$cc18,$366c
	dc.w	$5858,$3c02,$d8,$1858,$5800,$1810,$cac3,$c35b,$66,$667c,$1e7e,$7c1c
	dc.w	$1e7e,$6e3c,$3e7e,$6c1c,$3e36,$7e66,$3e78,$d67c,$1c3e,$fe7e,$361b,$10f7
	dc.w	$36,$fe00,$661e,0,$183c,$3c36,$1810,$7066,$7e18,$1818,$e18,$1832
	dc.w	$6c7c,0,$6c6c,$cfe,$66,$24f6,$6fc3,$fe99,$6d3,$3c16,$fedf,$5a0
	dc.w	$c606,$606,$c6c0,$c006,$c6c6,$3c78,$1fec,$dd8,$18,$66fe,$606c,$3818
	dc.w	$1818,$3c18,0,$c,$6e18,$618,$3c7c,$600c,$6666,$1818,$187e,$1806
	dc.w	$6e66,$6660,$6660,$6060,$6618,$678
l00d8	bra.s	l00d8
	dc.w	$7e66,$6666,$6660,$1866,$66c6,$3c66,$c18,$3018,$6c00,$603c,$7c3c,$3e3c
	dc.w	$7c3e,$7c38,$1866,$18ec,$7c3c,$7c3e,$7c3e,$7e66,$66c6,$6666,$7e18,$1818
	dc.w	$f218,$6600,0,$3c00,$3c,$3c,0,0,$1818,$7e7e,$d800,0
	dc.w	0,$663c,$663c,$303c,$667c,0,0,0,$666,0,$d8,$d800
	dc.w	$6c36,0,$663c,$7ed8,0,$3c00,$3038,$cabd,$bd5f,$e666,$760c,$60c
	dc.w	$60c,$c36,$660c,$606,$3e0c,$3636,$6666,$60c,$d66c,$c06,$6666,$363c
	dc.w	$3899,$7666,$66fe,$3038,$6c7e,$3c66,$6678,$387c,$6066,$7e,$c30,$1b18
	dc.w	$4c,$3838,$f,$6c18,$3800,$c3,$e783,$c1e7,$fc3c,$8cd3,$3c10,$d8db
	dc.w	$db0,0,$7c7c,$7c7c,$7c00,$7c7c,$660,$1804,$628,$18,$6c,$3c18
	dc.w	$7000,$1818,$ff7e,$7e,$18,$7618,$c0c,$6c06,$7c18,$3c3e,0,$3000
	dc.w	$c0c,$6a66,$7c60,$667c,$7c6e,$7e18,$670,$60d6,$7e66,$7c66,$7c3c,$1866
	dc.w	$66d6,$183c,$1818,$1818,$c600,$3006,$6660,$6666,$3066,$6618,$186c,$18fe
	dc.w	$6666,$6666,$6660,$1866,$66c6,$3c66,$c30,$180c,$9e34,$6066,$3c3c,$63c
	dc.w	$3c60,$3c66,$3c38,$3838,$3c3c,$601b,$de3c,$3c3c,$6666,$6666,$6660,$7c18
	dc.w	$7c30,$3c38,$3c66,$7c66,$3e66,$183e,$7c36,$3618,$d81b,$3c3c,$6e6e,$dbde
	dc.w	$1818,$6600,$10,$cab1,$a555,$6666,$3c0c,$e0c,$660c,$636,$660c,$606
	dc.w	$660c,$3636,$763c,$360c,$d66c,$c06,$6676,$1c66,$6c99,$dc7c,$626c,$186c
	dc.w	$6c18,$667e,$66dc,$54d6,$7e66,$7e18,$1818,$1b18,$7e00,0,$18,$6c30
	dc.w	$c00,$e7,$c383,$c1c3,$f999,$d8db,$7e10,$deff,$db0,$c606,$c006,$606
	dc.w	$c606,$c606,$7e7e,$1804,$7d0,$18,$6c,$630,$de00,$1818,$3c18,0
	dc.w	$30,$6618,$1806,$7e06,$6630,$6606,$1818,$1800,$1818,$6e7e,$6660,$6660
	dc.w	$6066,$6618,$678,$60c6,$6e66,$6076,$6c06,$1866,$66fe,$3c18,$3018,$c18
	dc.w	0,$3e,$6660,$667e,$3066,$6618,$1878,$18d6,$6666,$6666,$603c,$1866
	dc.w	$66d6,$1866,$1818,$1818,$c34,$6666,$7e06,$3e06,$660,$7e7e,$7e18,$1818
	dc.w	$6666,$7c7f,$f866,$6666,$6666,$6666,$6660,$303c,$6630,$618,$6666,$6676
	dc.w	$6666,$3030,$c6b,$6e18,$6c36,$666,$7676,$dfd8,$3c3c,$6600,$10,$7ab1
	dc.w	$b951,$6666,$6e0c,$1e0c,$660c,$636,$6600,$606,$660c,$3636,$60e,$360c
	dc.w	$d66c,$c06,$6606,$c66,$c6ef,$c866,$606c,$306c,$6c18,$6666,$66cc,$54d6
	dc.w	$6066,$18,$300c,$18d8,$32,0,$18d8,$6c7c,$7800,$24,$66f6,$6f99
	dc.w	$f3c3,$70c3,$1070,$181e,$1998,$c606,$c006,$606,$c606,$c606,$6618,$1004
	dc.w	$2e10,0,$fe,$7c66,$cc00,$1c38,$6618,$3000,$1860,$6618,$3066,$c66
	dc.w	$6630,$660c,$1818,$c7e,$3000,$6066,$6666,$6c60,$6066,$6618,$666c,$60c6
	dc.w	$6666,$606c,$6666,$1866,$3cee,$6618,$6018,$618,0,$66,$6660,$6660
	dc.w	$303e,$6618,$186c,$18c6,$6666,$6666,$6006,$1866,$3c7c,$3c3e,$3018,$1818
	dc.w	$62,$3c66,$607e,$667e,$7e3c,$6060,$6018,$1818,$7e7e,$60d8,$d866,$6666
	dc.w	$6666,$3e66,$663c,$3018,$6630,$7e18,$6666,$666e,$3e3c,$6030,$cc3,$d618
	dc.w	$366c,$7e66,$6666,$d8d8,$6666,$6600,$10,$abd,$ad00,$f6f6,$667e,$360c
	dc.w	$660c,$636,$7e00,$3e0e,$6e3c,$1c7e,$7e7e,$340c,$feec,$c06,$7e06,$c3c
	dc.w	$8266,$dc66,$606c,$666c,$6c18,$3c66,$24ec,$38d6,$7066,$7e00,0,$18d8
	dc.w	$184c,0,$1870,0,0,$24,$3c1c,$383c,$e7e7,$20c3,$38f0,$181b
	dc.w	$799e,$7c06,$7c7c,$67c,$7c06,$7c7c,$3c1e,$1e3c,$39e0,$18,$6c,$1846
	dc.w	$7600,$e70,0,$3000,$1840,$3c7e,$7e3c,$c3c,$3c30,$3c38,$30,$600
	dc.w	$6018,$3e66,$7c3c,$787e,$603e,$663c,$3c66,$7ec6,$663c,$6036,$663c,$183e
	dc.w	$18c6,$6618,$7e1e,$278,$fe,$3e,$7c3c,$3e3c,$3006,$663c,$1866,$3cc6
	dc.w	$663c,$7c3e,$607c,$e3e,$186c,$6606,$7e0e,$1870,$7e,$83e,$3c3e,$3e3e
	dc.w	$3e08,$3c3c,$3c3c,$3c3c,$6666,$7e7e,$df3c,$3c3c,$3e3e,$63c,$3e18,$7e18
	dc.w	$7c60,$3e3c,$3c3e,$6666,0,$6630,$c86,$9f18,$1bd8,$3e3c,$3c3c,$7e7f
	dc.w	$7e7e,$6600,0,$ac3,$c300,$606,0,0,0,0,0,0
	dc.w	0,0,0,$3000,0,$c06,6,$cd8,0,$767c,$606c,$fe38
	dc.w	$7f18,$183c,$6678,$307c,$3e66,$7e,$7e7e,$1870,$1800,0,$30,0
	dc.w	0,$3c,$1818,$1800,0,$7e,$1060,0,$718e,0,0,0
	dc.w	0,0,0,$1754,$3800,0,0,0,0,0,0,$6000
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,$7c,0,$7000,0,0,$6006,0,0
	dc.w	0,$7c,0,$1800,0,$3800,0,0,$18,0,0,0
	dc.w	0,0,0,0,0,$7c00,$18,0,$6000,0,0,0
	dc.w	$3c3c,$3c00,$f,$618,0,0,$4040,0,$6666,$3c00,0,$a7e
	dc.w	$7e00,$1c1c,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,$70,0,$60,$f848,0,$c010,$3c00,0,$6010
	dc.w	0,0,0,$1800,0,0,0,0,0,$5379,$7374,$656d
	dc.w	$2066,$6f6e,$7400,0,0,0
linespp	dc.l	64
selectfile	dc.b	0,0
sel1	dc.b	'PLEASE SELECT A DOC FILE:        BLADERUN.DOC',13,10
sel2	dc.b	'                                 DRUGS_1.DOC',13,10
sel3	dc.b	'                                 DRUGS_2.DOC',13,10
sel4	dc.b	'                                 LOCKPICK.DOC',13,10
sel5	dc.b	'                                 SEX_WIZ.DOC',13,10
sel6	dc.b	'                                 KAMASUTR.DOC',13,10
sel7	dc.b	'                                   ',13,10
sel8	dc.b	'                                   ',13,10
sel9	dc.b	'                                   ',13,10
sel10	dc.b	'                              ',13,10
	dc.b	0

fil1	dc.b	'A:\BLADERUN.DOC'
	even
fil2	dc.b	'A:\DRUGS_1.DOC'
	even
fil3	dc.b	'A:\DRUGS_2.DOC'
	even
fil4	dc.b	'A:\LOCKPICK.DOC'
	even
fil5	dc.b	'A:\SEX_WIZ.DOC'
	even
fil6	dc.b	'A:\KAMASUTR.DOC'
	even
fil7	dc.b	'A:\FILE_07.DOC'
	even
fil8	dc.b	'A:\FILE_08.DOC'
	even
fil9	dc.b	'A:\FILE_09.DOC'
	even
fil10	dc.b	'A:\FILE_10.DOC'
	even

filetab	dc.l	sel1
	dc.l	fil1
	dc.l	sel2
	dc.l	fil2
	dc.l	sel3
	dc.l	fil3
	dc.l	sel4
	dc.l	fil4
	dc.l	sel5
	dc.l	fil5
	dc.l	sel6
	dc.l	fil6
	dc.l	sel7
	dc.l	fil7
	dc.l	sel8
	dc.l	fil8
	dc.l	sel9
	dc.l	fil9
	dc.l	sel10
	dc.l	fil10

pconfig	dc.w	6		;	no	of	files	available	?

hlinesf1	dc.w	$a,5,$275,5,$a,$13,$275,$13
	dc.w	$a,$23,$275,$23,$a,$96,$275,$96
	dc.w	$a,5,$a,$96,$275,5,$275,$96
	dc.w	$140,$13,$140,$96,$ffff,$ffff,$ffff,$ffff
hlinesf2	dc.w	$a,5,$275,5,$a,$13,$275,$13
	dc.w	$a,$23,$275,$23,$a,$b2,$275,$b2
	dc.w	$a,$54,$275,$54,$a,$64,$275,$64
	dc.w	$a,5,$a,$b2,$275,5,$275,$b2
	dc.w	$140,$13,$140,$54,$140,$64,$140,$b2
	dc.w	$ffff,$ffff,$ffff,$ffff

music	incbin	'D:\MUSICHAK.MUG\FRAGGLE.MUS'
	even

	bss
	ds.l	1
lines	ds.w	1
pagesdone	ds.w	1
handle	ds.w	1
eof	ds.w	1
scradd	ds.l	1
oldrez	ds.w	1
oldcolours	ds.b	32
stcolours	ds.b	32
oldstack	ds.l	1
markstart	ds.l	1
markend	ds.b	6
marker1	ds.l	1
marker2	ds.l	1
marker3	ds.l	1
marker1line	ds.l	1
marker2line	ds.l	1
marker3line	ds.l	1
textpos	ds.l	1
lineno1	ds.w	1
lineno2	ds.w	1
bottomno	ds.w	1
bottom1	ds.l	1
screenpos	ds.l	1
linebuffer	ds.b	1280
fileend	ds.l	1
textfile	ds.b	25000
zuend	end
