*****************************************
*	Name:	Toilet Demo 2		*
*	By:	Corny of Crystalic	*
*	For:	Ambition		*
*	Date:	1993-03-08		*
*****************************************
 section text
	jsr	setsuper
	jsr	setscreen
	jsr	clear
	move.l	toapal+0,$ff8240
	move.l	toapal+4,$ff8244
	move.l	toapal+8,$ff8248
	move.l	toapal+12,$ff824c
	move.l	toapal+16,$ff8250
	move.l	toapal+20,$ff8254
	move.l	toapal+24,$ff8258
	move.l	toapal+28,$ff825c
	jsr	settoa2
	move.w	#5,d1
	jsr	waitloop2
	jsr	playsample
	jsr	startinter
	jsr	settoa3
	move.w	#0,d1
	jsr	waitloop2
	jsr	settoa1
	move.w	#10,d1
	jsr	waitloop2
	jsr	setbubbla1
	move.w	#20,d1
	jsr	waitloop2
	jsr	delbubbla
	move.w	#7,d1
	jsr	waitloop2
	jsr	setbubbla2
	move.w	#20,d1
	jsr	waitloop2
	jsr	delbubbla
	move.w	#7,d1
	jsr	waitloop2
	jsr	setbubbla3
	move.w	#20,d1
	jsr	waitloop2
	jsr	delbubbla
	jsr	clear2
	jsr	setupdist
	jsr	rotatedist
	jsr	setupletters
	jsr	makeletters
	jsr	setlogo
***************************************************************************
mainloop:
	jsr	waitvbl
	jsr	delstars
	jsr	delletters
	jsr	scroll32p1buf
	jsr	showscroll
	jsr	setstars
	jsr	setletters
	jsr	setdist
	jsr	screenswap
	cmp.b	#57,$fffc02
	bne	mainloop
***************************************************************************
exit:
	jsr	endinter
	jsr	endsuper
	clr.w	-(sp)
	trap	#1
***************************************************************************
setsuper:
	clr.l	-(sp)			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesuper
	rts
***************************************************************************
endsuper:
	move.l	savesuper,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
***************************************************************************
waitvbl:
	cmpi.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag
	rts 
***************************************************************************
setlogo:
	move.l	#treelogo,a0
	move.l	#$70000,a1
	move.l	#$78000,a2
	move.l	#$68000,a3
	move.w	#61*40-1,d0
	setlogoloop:
		move.l	(a0),(a1)+
		move.l	(a0),(a2)+
		move.l	(a0)+,(a3)+
	dbra	d0,setlogoloop
	rts
***************************************************************************
waitloop2:
	move.w	#$ffff,d0
	waitloop1:
		nop
	dbra	d0,waitloop1
	dbra	d1,waitloop2
	rts
***************************************************************************
settoa1:	
	move.l	#toa1,a0
	jsr	settoa
	rts
***************************************************************************
settoa2:	
	move.l	#toa2,a0
	jsr	settoa
	rts
***************************************************************************
settoa3:	
	move.l	#toa3,a0
	jsr	settoa
	rts
***************************************************************************
setbubbla1:	
	move.l	#bubbla1,a0
	jsr	setbubbla
	rts
***************************************************************************
setbubbla2:	
	move.l	#bubbla2,a0
	jsr	setbubbla
	rts
***************************************************************************
setbubbla3:	
	move.l	#bubbla3,a0
	jsr	setbubbla
	rts
***************************************************************************
settoa:
	move.l	#$70000+160*80+8*8,a1
	move.w	#48,d0
	settoaloop:
		move.l	(a0)+,0(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		add.w	#160,a1
	dbra	d0,settoaloop
	rts
***************************************************************************
setbubbla:
	move.l	#$70000+160*70+11*8,a1
	move.w	#27,d0
	setbubblaloop:
		move.l	(a0)+,0(a1)
		move.l	(a0)+,4(a1)
		move.l	(a0)+,8(a1)
		move.l	(a0)+,12(a1)
		move.l	(a0)+,16(a1)
		move.l	(a0)+,20(a1)
		move.l	(a0)+,24(a1)
		move.l	(a0)+,28(a1)
		move.l	(a0)+,32(a1)
		move.l	(a0)+,36(a1)
		add.w	#160,a1
	dbra	d0,setbubblaloop
	rts
***************************************************************************
delbubbla:
	move.l	#$70000+160*70+11*8,a0
	move.w	#27,d0
	delbubblaloop:
		clr.l	0(a0)
		clr.l	4(a0)
		clr.l	8(a0)
		clr.l	12(a0)
		clr.l	16(a0)
		clr.l	20(a0)
		clr.l	24(a0)
		clr.l	28(a0)
		clr.l	32(a0)
		clr.l	36(a0)
		add.w	#160,a0
	dbra	d0,delbubblaloop
	rts
***************************************************************************
startinter:
	move.l	$120.w,oldhbi 
	move.l	$70.w,oldvbi
	move.b	$fffffa07.w,old07
	move.b	$fffffa09.w,old09
	move.b	$fffffa0f.w,old0f
	move.b	$fffffa11.w,old11
	move.b	$fffffa11.w,old13
	move.b	$fffffa1b.w,old1b
	move.b	$fffffa21.w,old21
	and.b 	#$df,$fffa09
	and.b 	#$fe,$fffa07
	move.l	#newvbi,$70
	or.b  	#1,$fffffa07
	or.b  	#1,$fffffa13
	moveq	#1,d0
	jsr	music
	rts
***************************************************************************
endinter:
	move.b	old07,$fffffa07.w
	move.b	old09,$fffffa09.w
	move.b	old0f,$fffffa0f.w
	move.b	old11,$fffffa11.w
	move.b	old13,$fffffa13.w
	move.b	old1b,$fffffa1b.w
	move.b	old21,$fffffa21.w
	move.l	oldhbi,$120.w 
	move.l	oldvbi,$70.w
	rts
***************************************************************************
newvbi:
	clr.b	$fffffa1b.w
	move.w	#1,vbiflag
	movem.l	d0-a6,-(sp)
	jsr	music+8
	movem.l	(sp)+,d0-a6
	jsr	setpal
	move.l	#newpal,$120.w
	move.b	#61,$fffffa21.w
	move.l	#rasters,a6
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f
	rte
***************************************************************************
newhbi:
	move.w	(a6)+,$ff8250
	bclr	#0,$fffffa0f
	rte
***************************************************************************
setscreen:
	move.b	#0,$ffff8260.w
	clr.l	d0
	move.l	#$70000,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w
	move.l	#$78000,$44e.w
	rts
***************************************************************************
screenswap:
	cmp.l	#$78000,$44e
	bne	logphys	
	physlog:
		move.l	#$78000,d0
		lsr.l	#8,d0
		move.b	d0,$ffff8203.w
		lsr.w	#8,d0
		move.b	d0,$ffff8201.w
		move.l	#$70000,$44e
		rts
	logphys:
		move.l	#$70000,d0
		lsr.l	#8,d0
		move.b	d0,$ffff8203.w
		lsr.w	#8,d0
		move.b	d0,$ffff8201.w
		move.l	#$78000,$44e
		rts
***************************************************************************
newpal:
	clr.b	$fffffa1b.w
	move.w	toapal+2,$ff8242
	move.l	toapal+4,$ff8244
	move.l	toapal+8,$ff8248
	move.l	toapal+12,$ff824c
	move.l	toapal+16,$ff8250
	move.l	toapal+20,$ff8254
	move.l	toapal+24,$ff8258
	move.l	toapal+28,$ff825c
	move.b	#1,$fffffa21.w
	move.l	#newhbi,$120.w
	bclr	#0,$fffffa0f
	move.b	#8,$fffffa1b.w
	rte
***************************************************************************
setpal:
	move.l	logopal,$ff8240
	move.l	logopal+4,$ff8244
	move.l	logopal+8,$ff8248
	move.l	logopal+12,$ff824c
	move.l	logopal+16,$ff8250
	move.l	logopal+20,$ff8254
	move.l	logopal+24,$ff8258
	move.l	logopal+28,$ff825c
	rts
***************************************************************************
clearscreen:
	move.l	#$70000,a0
	move.l	#$78000,a1
	move.w	#7999,d0
	clearscreenloop:
		clr.l	(a0)+
		clr.l	(a1)+
	dbra	d0,clearscreenloop
	rts
***************************************************************************
setstars:
	move.l	#stardata,a0
	move.w	starpos1,d1
	muls	#135*4,d1
	add.w	d1,a0
	move.l	$44e,d1
	move.w	#134,d0
	setstarsloop:
		move.l	d1,a1
		add.w	(a0)+,a1
		move.w	(a0)+,d2
		or.w	d2,(a1)
	dbra	d0,setstarsloop
	add.w	#1,starpos1
	cmp.w	#34,starpos1
	bne	nostarwrap1
	move.w	#0,starpos1
nostarwrap1:
	rts
***************************************************************************
delstars:
	move.l	#stardata,a0
	move.w	starpos2,d1
	muls	#135*4,d1
	add.w	d1,a0
	move.l	#$68000,d2
	move.l	$44e,d1
	move.w	#134,d0
	delstarsloop:
		move.l	d1,a1
		move.l	d2,a2
		add.w	(a0),a1
		add.w	(a0)+,a2
		move.w	(a0)+,d3
		move.w	(a2),(a1)
	dbra	d0,delstarsloop
	add.w	#1,starpos2
	cmp.w	#34,starpos2
	bne	nostarwrap2
	move.w	#0,starpos2
nostarwrap2:
	rts
***************************************************************************
showscroll:
	move.l	$44e,a0
	add.w	#6+160*148,a0
	move.w	#19,d0
	move.w	#0,d1
	move.w	#160,d2
	jsr	clearscrolloop
	move.l	$44e,a0
	add.w	#6+160*180,a0
	move.w	#18,d0
	move.w	#0,d1
	move.w	#160,d2
	jsr	clearscrolloop
	move.l	studsptr,a0
	move.w	(a0)+,d0
	move.l	a0,studsptr
	cmp.w	#-1,d0
	bne	nostudswrap
	move.l	#studskurva,studsptr
	bra	showscroll
nostudswrap:
	muls	#160,d0
	move.l	scroll32p1bufadr,a0
	move.l	$44e,a1
	add.w	#6,d0
	add.w	d0,a1
	move.w	#160,d1
	move.w	#31,d0
	showscrolloop:
	move.w	(a0)+,0(a1)
	move.w	(a0)+,8(a1)
	move.w	(a0)+,16(a1)
	move.w	(a0)+,24(a1)
	move.w	(a0)+,32(a1)
	move.w	(a0)+,40(a1)
	move.w	(a0)+,48(a1)
	move.w	(a0)+,56(a1)
	move.w	(a0)+,64(a1)
	move.w	(a0)+,72(a1)
	move.w	(a0)+,80(a1)
	move.w	(a0)+,88(a1)
	move.w	(a0)+,96(a1)
	move.w	(a0)+,104(a1)
	move.w	(a0)+,112(a1)
	move.w	(a0)+,120(a1)
	move.w	(a0)+,128(a1)
	move.w	(a0)+,136(a1)
	move.w	(a0)+,144(a1)
	move.w	(a0)+,152(a1)
	add.w	d1,a1
	dbf.w	d0,showscrolloop
	rts
	clearscrolloop:
	move.w	d1,0(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	add.w	d2,a0
	dbf.w	d0,clearscrolloop
	rts
***************************************************************************
setupletters:
	move.l	#letters,a0
	move.l	#blocks,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4*2,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4*3,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4*4,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4*5,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	move.l	#blocks+16*16*4*6,a1
	rept 16
	move.w	(a0)+,(a1)+
	clr.w	(a1)+
	endr
	rts
***************************************************************************
makeletters:
	move.w	#6,d2
	makelettloop:
	move.w	d2,d1
	muls	#16*4*16,d1
	move.l	#blocks,a0
	add.w	d1,a0
	move.l	#blocks+16*4,a1
	add.w	d1,a1
	move.w	#14,d0
	rotatelettloop:
	rept 16
	move.l	(a0)+,(a1)
	roxr.w	(a1)+
	roxr.w	(a1)+
	endr
	dbra	d0,rotatelettloop
	dbra	d2,makelettloop
	rts	
***************************************************************************
setletters:
	move.l	savcircptr,oldcircptr
	move.l	circptr,savcircptr
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	circptr,a3
	move.w	#6,d7	
setlettersloop:
	move.w	avst,d4
	avstloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	cmp.w	#-1,d0
	bne	nocircwrap
	move.l	#circletab,a3
	bra	avstloop
nocircwrap:
	dbra	d4,avstloop
	move.l	#blocks,a0
	move.w	d7,d6
	muls	#16*4*16,d6
	add.w	d6,a0
	bsr	setletter
	dbra	d7,setlettersloop
	clr.l	d4
	move.w	speed,d4
	speedloop:
	move.l	circptr,a3
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	move.l	a3,circptr
	cmp.w	#-1,d0
	bne	nocircwrap2
	move.l	#circletab,circptr
nocircwrap2:
	dbra	d4,speedloop
	rts
***************************************************************************
delletters:
	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	oldcircptr,a3
	move.w	#6,d7	
dellettersloop:
	move.w	oldavst,d4
	oldavstloop:
	move.w	(a3)+,d0
	move.w	(a3)+,d1
	cmp.w	#-1,d0
	bne	nooldcircwrap
	move.l	#circletab,a3
	bra	oldavstloop
nooldcircwrap:
	dbra	d4,oldavstloop
	bsr	delletter
	dbra	d7,dellettersloop
	rts
***************************************************************************
setletter:
	move.l	$44e,a1 
	muls	#160,d1
	add.w	d1,a1
	move.w	d0,d1
	and.w	#$fff0,d0
	divs	#2,d0
	and.w	#$000f,d1
	muls	#4*16,d1
	add.w	d0,a1
	add.w	d1,a0
	rept	16
	move.w	(a0)+,d1
	or.w	d1,6(a1)
	move.w	(a0)+,d1
	or.w	d1,14(a1)
	add.w	#160,a1
	endr
	rts
***************************************************************************
delletter:
	move.l	$44e,a1 
	muls	#160,d1
	add.w	d1,a1
	and.w	#$fff0,d0
	divs	#2,d0
	add.w	d0,a1
	rept	16
	clr.w	6(a1)
	clr.w	14(a1)
	add.w	#160,a1
	endr
	rts
***************************************************************************
setupdist:
	move.l	#toa1,a0		
	move.l	#$78000,a1
	move.w	#48,d0
	setupdistloop:
		rept	6
		move.l	(a0)+,(a1)+
		endr
		add.w	#160-6*4,a1
		dbf.w	d0,setupdistloop
	rts
***************************************************************************
rotatedist:
	lea	distbuf,a1
	move.w	#15,d0
	rotatedistloop:
		jsr	rotatedistsave
		jsr	rotatedistscroll
	dbf.w	d0,rotatedistloop	
	rts
***************************************************************************
rotatedistscroll:
	move.l	#$78000,a0
	move.w	#48,d1
	rotatedistscrolloop:
		rept	20
		roxr.w	0(a0)
		addq.w	#8,a0
		endr
		sub.w	#8*20,a0
		rept	20
		roxr.w	2(a0)
		addq.w	#8,a0
		endr
		sub.w	#8*20,a0
		rept	20
		roxr.w	4(a0)
		addq.w	#8,a0
		endr
		sub.w	#8*20,a0
		rept	20
		roxr.w	6(a0)
		addq.w	#8,a0
		endr
	dbf.w	d1,rotatedistscrolloop	
	rts
***************************************************************************
rotatedistsave:
	move.l	#$78000,a0
	move.w	#48,d1
	rotatedistsaveloop:
		rept	4
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		endr
		add.w	#160-4*8,a0
		dbf.w	d1,rotatedistsaveloop
	rts
***************************************************************************
clear:
	move.l	#$70000,a0
	move.l	#$78000,a1
	move.w	#0,d1
	move.w	#7999,d0
	clearloop:
		move.l	d1,(a0)+
		move.l	d1,(a1)+
	dbf.w	d0,clearloop
	rts
***************************************************************************
clear2:
	move.l	#$78000,a0
	move.l	#$68000,a1
	move.w	#0,d1
	move.w	#7999,d0
	clearloop2:
		move.l	d1,(a0)+
		move.l	d1,(a1)+
	dbf.w	d0,clearloop2
	rts
***************************************************************************
setdist:
	move.l	$44e,a5
	add.w	#160*80+8*8,a5
	move.l	distptr,a3
	move.w	#0,ypos
	move.w	#48,d7
	setdistloop:
		move.w	(a3)+,d0
		cmp.w	#-1,d0
		bne	nodistwrap1
		move.l	#disttab,a3
		bra	setdistloop
	nodistwrap1:
		move.l	#distbuf,a4
		muls	#4*8*49,d0
		add.l	d0,a4
		add.w	ypos,a4
		movem.l	(a4)+,d0-d3
		movem.l	d0-d3,(a5)
		movem.l	(a4)+,d0-d3
		movem.l	d0-d3,16(a5)
		add.w	#160,a5
		add.w	#4*8,ypos
	dbf.w	d7,setdistloop
	move.l	distptr,a0
	move.w	(a0)+,d0
	move.l	a0,distptr
	cmp.w	#-1,d0
	bne	nodistwrap2
	move.l	#disttab,distptr
nodistwrap2:
	rts
***************************************************************************
scroll32p1buf:
 	jsr	scroll32p1bufswap
 	jsr	scroll32p1bufscroll
	add.w	#1,scroll32p1bufcount
	cmp.w	#1,scroll32p1bufcount
	beq	scroll32p1bufsetfont1
	cmp.w	#2,scroll32p1bufcount
	beq	scroll32p1bufsetfont2
	cmp.w	#3,scroll32p1bufcount
	beq	scroll32p1bufsetfont3
	cmp.w	#4,scroll32p1bufcount
	beq	scroll32p1bufsetfont4
	cmp.w	#5,scroll32p1bufcount
	beq	scroll32p1bufnewchar
	rts
scroll32p1bufnewchar:
	move.w	#0,scroll32p1bufcount
	jsr	scroll32p1bufsetfont5
	jsr	scroll32p1bufreadchar
	rts
scroll32p1bufreadchar:
	move.l	#scroll32p1bufptr,a0
	move.l 	(a0),a0
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,scroll32p1bufptr
	
	cmp.b	#$ff,d0
	bne	scroll32p1bufnowrap
	move.l	#scroll32p1txt,scroll32p1bufptr
	bra	scroll32p1bufreadchar
scroll32p1bufnowrap:
	sub.w	#32,d0
	muls	#128,d0
	add.l	#scroll32p1fnt,d0
	move.l	d0,scroll32p1bufcharadr
	rts
scroll32p1bufsetfont1:
	move.l	scroll32p1bufcharadr,a0
	move.l	scroll32p1bufadr,a1
	add.w	#38,a1
	move.w	#31,d0
	scroll32p1bufsetfontloop1buf:
		move.b	#0,(a1)
		move.b	(a0),1(a1)
		add.w	#4,a0
		add.w	#40,a1
	dbf.w	d0,scroll32p1bufsetfontloop1buf
	rts
scroll32p1bufsetfont2:
	move.l	scroll32p1bufcharadr,a0		
	move.l	scroll32p1bufadr,a1
	add.w	#38,a1
	move.w	#31,d0
	scroll32p1bufsetfontloop2:
		move.w	(a0),(a1)
		add.w	#4,a0
		add.w	#40,a1
	dbf.w	d0,scroll32p1bufsetfontloop2
	rts
scroll32p1bufsetfont3:
	move.l	scroll32p1bufcharadr,a0
	move.l	scroll32p1bufadr,a1
	add.w	#38,a1
	move.w	#31,d0
	scroll32p1bufsetfontloop3:
		move.b	1(a0),(a1)
		move.b	2(a0),1(a1)
		add.w	#4,a0
		add.w	#40,a1
	dbf.w	d0,scroll32p1bufsetfontloop3
	rts
scroll32p1bufsetfont4:
	move.l	scroll32p1bufcharadr,a0
	move.l	scroll32p1bufadr,a1
	add.w	#38,a1
	move.w	#31,d0
	scroll32p1bufsetfontloop4:
		move.w	2(a0),(a1)
		add.w	#4,a0
		add.w	#40,a1
	dbf.w	d0,scroll32p1bufsetfontloop4
	rts
scroll32p1bufsetfont5:
	move.l	scroll32p1bufcharadr,a0
	move.l	scroll32p1bufadr,a1
	add.w	#38,a1
	move.w	#31,d0
	scroll32p1bufsetfontloop5:
		move.b	3(a0),(a1)
		move.b	#0,1(a1)
		add.w	#4,a0
		add.w	#40,a1
	dbf.w	d0,scroll32p1bufsetfontloop5
	rts
scroll32p1bufscroll:
	move.l	scroll32p1bufadr,a0
	move.w	#31,d0
 scroll32p1bufscrolloop:
	move.w	2(a0),0(a0)
	move.w	4(a0),2(a0)
	move.w	6(a0),4(a0)
	move.w	8(a0),6(a0)
	move.w	10(a0),8(a0)
	move.w	12(a0),10(a0)
	move.w	14(a0),12(a0)
	move.w	16(a0),14(a0)
	move.w	18(a0),16(a0)
	move.w	20(a0),18(a0)
	move.w	22(a0),20(a0)
	move.w	24(a0),22(a0)
	move.w	26(a0),24(a0)
	move.w	28(a0),26(a0)
	move.w	30(a0),28(a0)
	move.w	32(a0),30(a0)
	move.w	34(a0),32(a0)
	move.w	36(a0),34(a0)
	move.w	38(a0),36(a0)
	add.w	#40,a0
	dbf.w	d0,scroll32p1bufscrolloop
	rts
scroll32p1bufswap:
	cmp.l	#scroll32p1buffer1,scroll32p1bufadr
	bne	scroll32p1swap2
	scroll32p1swap1:
	move.l	#scroll32p1buffer2,scroll32p1bufadr
	rts
	scroll32p1swap2:
	move.l	#scroll32p1buffer1,scroll32p1bufadr
	rts
scroll32p1bufptr:	dc.l	scroll32p1txt
scroll32p1bufcount:	dc.w	0
scroll32p1bufcharadr:	dc.l	scroll32p1fnt
scroll32p1bufadr:	dc.l	scroll32p1buffer1
scroll32p1buffer1:	dcb.w	20*32
scroll32p1buffer2:	dcb.w	20*32
***************************************************************************
playsample:	include	a:\play_sam.dat  
 section data
savesuper:	dc.l	0
vbiflag:	dc.w	0
oldvbi:		dc.l	0
oldhbi:		dc.l	0
old1b:		dc.b	0
old21:		dc.b	0
old07:		dc.b	0
old09:		dc.b	0
old0f:		dc.b	0
old11:		dc.b	0
old13:		dc.b	0
ypos:		dc.w	0
starpos1:	dc.w	2
starpos2:	dc.w	0
avst:		dc.w	20
oldavst:	dc.w	20
speed:		dc.w	4
oldspeed:	dc.w	4
distptr:	dc.l	disttab1
circptr:	dc.l	circletab
oldcircptr:	dc.l	circletab
savcircptr:	dc.l	circletab
studsptr:	dc.l	studskurva
rasterptr:	dc.l	rasters
rasters:	dc.w	$001
		dc.w	$002,$003,$004,$005,$006,$007,$017,$027,$037,$047,$057,$067,$077,$167,$257,$347,$437,$527,$617,$707,$f0e,$706,$f0d,$705,$f0c,$704,$f0b,$703,$f0a,$702,$f09,$701,$700,$f08,$710,$720,$730,$740,$750,$760,$770
		dc.w	$671,$572,$473,$374,$275,$176,$077,$176,$275,$374,$473,$572,$671,$770,$761,$752,$743,$734,$725,$716,$707,$617,$527,$437,$347,$257,$167,$077,$076,$075,$074,$073,$072,$071,$070,$060,$050,$040,$030,$020,$010
		dc.w	$000,$000,$000
		dc.w	$100,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f
		dc.w	$017,$09f,$027,$0af,$037,$0bf,$047,$0cf,$057,$0df,$067,$0ef
		dc.w	$077,$0ef,$067,$0df,$057,$0cf,$047,$0bf,$037,$0af,$027,$09f,$017
		dc.w	$00f,$007,$00e,$006,$00d,$005,$00c,$004,$00b,$003,$00a,$002,$009,$001
scroll32p1txt:
  DC.B "GOSH!.. CAN IT BE TRUE..ANOTHER LOUSY TOILET DEMO (THE SECOND ONE IN FACT!)..YES,OF COURSE IT IS!..WE GOT BORED WITH ALL THOSE COLORSHOCK SCREENS SO WE DECIDED TO START A NEW FORM OF SERIES..THE TOILET DEMOS!.NOW LET'S HAVE SOME"
  DC.B " HISTORY:  THE FIRST TOILET DEMO WAS DONE BY A GROUP CALLED 2 LIFE CREW..WITH MUCH HELP FROM MEMBERS OF THE CAREBEARS.THIS ONE IS DONE BY US (CRYSTALIC) WITH NO HELP FROM ANY BEAR!.THE THIRD ONE HAS NOT YET BEEN DONE (YET!).NOW"
  DC.B " I WILL TALK ABOUT THE LATEST NIGHT OUT WITH THE CREW (A REAL BASH,ACTUALLY!).FEAR,CORNY AND LORD GOT TOGETHER IN A BASEMENT THAT WE BORROWED FROM DAG (THANX!).AFTER WE HAD PACKED UP OUR STUFF WE WENT TO THE LOCAL DRUG STORE"
  DC.B " AND BOUGHT SOME BEER.THEN WE WENT BACK TO THE BASEMENT AND LOOKED AT SOME DEMOS AND DRANK OUR BEER.THEN WE TOOK THE BUS AND GOT TO THE PLACE CALLED PROJECT.IT WAS A NEW PLACE WITH A BAR AND ALOT OF CHAIRS AND TABLES.WE GOT A"
  DC.B " LITTLE AFRAID THAT THEY DID NOE HAVE ANY DANCE FLOOR AT ALL,LATER ON WE FOUND ONE OUTSIDE THE TOILET (WHICH WE USED QUIT ALOT!) AND SO THE NIGHT WAS SAVED.AT FIRST THERE WAS NOT SO MUCH PEOPLE AROUND BUT LATER IT GOT CROWDED."
  DC.B "WE ALL BOUGHT SOME DRINKS FROM THE BAR..SNOWBALL,PINA COLADA,SCREWDRIVER,BLOODY MARY,YEAGER,THE GREEN ELEVATOR (?) AND EVEN WATER COZ WE RAVED AS HELL SO WE GOT SO DAMN THURSTY.THE BABES AROUND GOT REALLY NICE LOOKING AFTER"
  DC.B " A WHILE AND WE WENT TO THE TOILET ALOT.WHEN THE PARTY WAS OVER WE WENT OUT ON THE STREET AND BEGAN TO WALK TO THE BASEMENT,BUT AS AN ANGEL OF MERCY A CERTAIN CAR PULLED UP BESIDE US AND IT WAS...TERRY!.HE GAVE US A WELL NEEDED"
  DC.B " RIDE HOME IN HIS CAR..AS WE ENTERED THE BASEMENT AND SAW OUR BEDS WE ALL FELL ASLEEP.THE MORNING AFTER ONE OF US HAD TO GO TO THE TOILET FOR OTHER REASONS THAN PISS!.THAT AFTERNOON WE ALL WANTED TO JUST SIT AND TAKE IT EASY"
  DC.B " SO WE RENTED ..PEOPLE UNDER THE STAIRS..AND A VIDEO BOX AND WATCHED THAT MOVIE FOR A WHILE,THEN WE FELT BETTER AND STARTED TO CODE AND DRAW LIKE HELL...END OF STORY.AS YOU HAVE READ WE HAD A REALLY NICE NIGHT OUT,AND YOU"
  DC.B " CAN BET ANYTHING ON THAT WE WILL HAVE MANY MORE (WITHOUT THAT MUCH DRINKS!)..NOW OVER TO THE PRESENT.    RIGHT NOW CORNY AND LORD ARE AT LORDS HUMBLE HOUSE,PUTTING THIS PART TOGETHER AS FAST AS WE CAN.THIS SCREEN IS MENT"
  DC.B " AS A DISC FILLER SO DONT JUDGE THE POOR THING TO HARD GUYS.AS YOU HEAR WE HAVE THE SAME TUNE AS IN THE FIRST TOILET DEMO,THANX TO TAO OF ACF IT HAS DIGIDRUMS AND IS A BIT FASTER!...NOW I DO NOT REALLY HAVE MUCH MORE TO SAY"
  DC.B " SO I THINK I WILL QUIT THIS SCROLLER..LET'S END IT WITH A JOKE: WE ARE REALLY HAPPY WITH THIS SCREEN (HAW,HAW..)....NOW IT'S    WRAP TIME!.....                                                                                  ",$FF
 even
logopal:	dc.w	$000,$222,$333,$431,$555,$335,$224,$113,$666,$002,$600,$500,$400,$210,$320,$432
toapal:		dc.w	$000,$222,$333,$666,$555,$777,$444,$643,$000,$600,$650,$760,$700,$400,$540,$432
disttab1:	dcb.w	348,0
		dc.w	0,1,2,3,4,5,6,7
disttab: 	include a:\toilet_2\sprytab.dat
		dc.w	-1
circletab:	include	a:\toilet_2\circltab.dat
		dc.w	-1
studskurva:	include	a:\toilet_2\scrlwave.dat
		dc.w	-1
letters:	incbin	a:\toilet_2\t.dat
		incbin	a:\toilet_2\o.dat
		incbin	a:\toilet_2\i.dat
		incbin	a:\toilet_2\l.dat
		incbin	a:\toilet_2\e.dat
		incbin	a:\toilet_2\t.dat
		incbin	a:\toilet_2\2.dat
stardata:	incbin	a:\toilet_2\starcalc.dat
music:		incbin	a:\toilet_2\zoolook.mus
treelogo:	incbin	a:\toilet_2\treelogo.dat
scroll32p1fnt:	incbin	a:\toilet_2\321font.dat
toa1:		incbin	a:\toilet_2\toilet3.dat
toa2:		incbin	a:\toilet_2\toilet1.dat
toa3:		incbin	a:\toilet_2\toilet2.dat
bubbla1:	incbin	a:\toilet_2\bubbla1.dat
bubbla2:	incbin	a:\toilet_2\bubbla2.dat
bubbla3:	incbin	a:\toilet_2\bubbla3.dat
 section bss
distbuf:	ds.b	16*4*8*49+160*5
blocks:		ds.b	16*16*4*7
                                                