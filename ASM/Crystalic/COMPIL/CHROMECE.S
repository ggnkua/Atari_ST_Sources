   	JSR	SETSUPER
	jsr	clearpal
	JSR	SETSCREEN
	moveq	#1,d0
	jsr	music
	move.l	#music+8,$4d2
	move.w	#25,d1
	jsr	waitloop
	jsr	setcode
	jsr	fadecodeup
	jsr	calcdist
	jsr	calcwidth
	move.w	#125,d1
	jsr	waitloop
	jsr	fadecodedown
	jsr	clearpal
	move.w	#25,d1
	jsr	waitloop
	JSR	CLEARSCREEN
	jsr	setscrollback
	jsr	setchrome
	jsr	setcorny
	jsr	settext
	JSR	init	
mainloop:
	JSR	WAITVBL
	cmp.w	#1,exitflag
	beq	exit
	jsr	flaghandler
	cmp.w	#1,spd2
	beq	noscrswap
	cmp.l	#$50000,$44e
	beq	noscrswap
	jsr	delchoice
	move.w	choice,oldchoice
	jsr	scroll32p1
	jsr	setchoice
	jsr	setnuffror
	jsr	screenswap
noscrswap:
	cmp.w	#1,spd2
	beq	nochangeadr
	cmp.l	#$50000,$44e
	bne	continue
	cmp.l	#$60000,savepic
	beq	theother	
	clr.l	d0
	move.l	#$60000,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w
	move.l	#$40000,$44e.w
	bra	continue
theother:
	clr.l	d0
	move.l	#$40000,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w
	move.l	#$60000,$44e.w
	bra	continue
nochangeadr:
	cmp.l	#$50000,$44e
	beq	continue
	move.l	$44e,savepic
	clr.l	d0
	move.l	#$50000,d0
	lsr.l	#8,d0
	move.b	d0,$ffff8203.w
	lsr.w	#8,d0
	move.b	d0,$ffff8201.w
	move.l	#$50000,$44e.w
continue:
	move.w	#0,add1
	move.w	#0,add2
	move.w	#0,add3
	move.w	#0,add4
	move.w	#0,add5
	move.w	#0,add6
	move.w	#0,add7
	btst	#0,$fffc00
	beq	nokey
	cmp.b	#59,$fffc02
	beq	f1
	cmp.b	#60,$fffc02
	beq	f2
	cmp.b	#61,$fffc02
	beq	f3
	cmp.b	#62,$fffc02
	beq	f4
	cmp.b	#63,$fffc02
	beq	f5
	cmp.b	#57,$fffc02
	beq	spacepressed
	cmp.b	#75,$fffc02
	beq	decval
	cmp.w	#1,spd2
	beq	nonewchoice
	cmp.b	#72,$fffc02
	beq	deccho
	cmp.b	#80,$fffc02
	beq	inccho
nonewchoice:
	cmp.b	#77,$fffc02
	bne	nokey
	cmp.w	#1,choice
	bne	noc1
	move.w	#2,add1
noc1:	cmp.w	#2,choice
	bne	noc2
	move.w	#2,add2
noc2:	cmp.w	#3,choice
	bne	noc3
	move.w	#4,add3
noc3:	cmp.w	#4,choice
	bne	noc4
	move.w	#4,add4
noc4:	cmp.w	#5,choice
	bne	noc5
	move.w	#2,add5
noc5:	cmp.w	#6,choice
	bne	noc6
	move.w	#2,add6
noc6:	cmp.w	#7,choice
	bne	noc7
	move.w	#2,add7
noc7:	cmp.w	#8,choice
	bne	noc8
	add.w	#2,spd1
	cmp.w	#40,spd1
	ble	noc8
	move.w	#40,spd1
noc8:	cmp.w	#9,choice
	bne	noc9
	add.w	#1,spd2
	cmp.w	#1,spd2
	ble	noc9
	move.w	#1,spd2
noc9:	cmp.w	#10,choice
	bne	noc10
	add.w	#4,spd3
	cmp.w	#80,spd3
	ble	noc10
	move.w	#80,spd3
noc10:	cmp.w	#11,choice
	bne	noc11
	add.w	#4,spd4
	cmp.w	#80,spd4
	ble	noc11
	move.w	#80,spd4
noc11:	cmp.w	#12,choice
	bne	noc12
	add.w	#2,spd5
	cmp.w	#40,spd5
	ble	noc12
	move.w	#40,spd5
noc12:	cmp.w	#13,choice
	bne	noc13
	add.w	#2,spd6
	cmp.w	#40,spd6
	ble	noc13
	move.w	#40,spd6
noc13:	cmp.w	#14,choice
	bne	nokey
	add.w	#2,spd7
	cmp.w	#40,spd7
	bne	nokey
	move.w	#40,spd7
nokey:	move.w	spd1,d3
	add.w	d3,val1
	move.w	add1,d3
	add.w	d3,val1
	cmp.w	#718,val1
	ble	noval1wrap
	move.w	#0,val1
noval1wrap:
	move.w	add2,d3
	add.w	d3,val2
	cmp.w	#94,val2
	ble	noval2wrap
	move.w	#94,val2
noval2wrap:
	move.w	spd3,d3
	add.w	d3,val3
	move.w	add3,d3
	add.w	d3,val3
	cmp.w	#1436,val3
	ble	noval3wrap
	move.w	#0,val3
noval3wrap:
	move.w	spd4,d3
	add.w	d3,val4
	move.w	add4,d3
	add.w	d3,val4
	cmp.w	#1436,val4
	ble	noval4wrap
	move.w	#0,val4
noval4wrap:
	move.w	spd5,d3
	add.w	d3,val5
	move.w	add5,d3
	add.w	d3,val5
	cmp.w	#718,val5
	ble	noval5wrap
	move.w	#0,val5
noval5wrap:
	move.w	spd6,d3
	add.w	d3,val6
	move.w	add6,d3
	add.w	d3,val6
	cmp.w	#718,val6
	ble	noval6wrap
	move.w	#0,val6
noval6wrap:
	move.w	spd7,d3
	add.w	d3,val7
	move.w	add7,d3
	add.w	d3,val7
	cmp.w	#718,val7
	ble	noval7wrap
	move.w	#0,val7
noval7wrap:
	jmp	mainloop
decval:
	cmp.w	#1,choice
	bne	nodec1
	sub.w	#2,val1
	cmp.w	#0,val1
	bge	nokey
	move.w	#718,val1
nodec1:	cmp.w	#2,choice
	bne	nodec2
	sub.w	#2,val2
	cmp.w	#0,val2
	bge	nokey
	move.w	#0,val2
nodec2:	cmp.w	#3,choice
	bne	nodec3
	sub.w	#4,val3
	cmp.w	#0,val3
	bge	nokey
	move.w	#1436,val3
nodec3:	cmp.w	#4,choice
	bne	nodec4
	sub.w	#4,val4
	cmp.w	#0,val4
	bge	nokey
	move.w	#1436,val4
nodec4:	cmp.w	#5,choice
	bne	nodec5
	sub.w	#2,val5
	cmp.w	#0,val5
	bge	nokey
	move.w	#718,val5
nodec5:	cmp.w	#6,choice
	bne	nodec6
	sub.w	#2,val6
	cmp.w	#0,val6
	bge	nokey
	move.w	#718,val6
nodec6:	cmp.w	#7,choice
	bne	nodec7
	sub.w	#2,val7
	cmp.w	#0,val7
	bge	nokey
	move.w	#718,val7
nodec7:	cmp.w	#8,choice
	bne	nodec8
	sub.w	#2,spd1
	cmp.w	#0,spd1
	bge	nokey
	move.w	#0,spd1
nodec8:	cmp.w	#9,choice
	bne	nodec9
	sub.w	#1,spd2
	cmp.w	#0,spd2
	bge	nokey
	move.w	#0,spd2
nodec9:	cmp.w	#10,choice
	bne	nodec10
	sub.w	#4,spd3
	cmp.w	#0,spd3
	bge	nokey
	move.w	#0,spd3
nodec10:cmp.w	#11,choice
	bne	nodec11
	sub.w	#4,spd4
	cmp.w	#0,spd4
	bge	nokey
	move.w	#0,spd4
nodec11:cmp.w	#12,choice
	bne	nodec12
	sub.w	#2,spd5
	cmp.w	#0,spd5
	bge	nokey
	move.w	#0,spd5
nodec12:cmp.w	#13,choice
	bne	nodec13
	sub.w	#2,spd6
	cmp.w	#0,spd6
	bge	nokey
	move.w	#0,spd6
nodec13:cmp.w	#14,choice
	bne	nodec14
	sub.w	#2,spd7
	cmp.w	#0,spd7
	bge	nokey
	move.w	#0,spd7
nodec14:jmp	nokey

deccho:	sub.w	#1,choice
	cmp.w	#1,choice
	bge	nokey
	move.w	#14,choice
	jmp	mainloop
inccho:	add.w	#1,choice
	cmp.w	#14,choice
	ble	nokey
	move.w	#1,choice
	jmp	nokey
spacepressed:
	move.w	#1,putoutflag
	jmp	mainloop
exit:
	move.l	#0,$4d2
	move	#$8800,a0
	move.l	#$08000000,(a0)
	move.l	#$09000000,(a0)
	move.l	#$0a000000,(a0)
	move.w	#$2700,sr
	move.b	old07,$fffffa07.w
	move.b	old09,$fffffa09.w
	move.b	old13,$fffffa13.w
	move.b	old15,$fffffa15.w
	move.b	old17,$fffffa17.w
	move.b	old19,$fffffa19.w
	move.b	old1b,$fffffa1b.w
	move.l	old68,$68.w
	move.l	old70,$70.w
	move.l	old120,$120.w
	move.l	old134,$134.w
	move.w	#$2300,sr
	jsr	clearpal
	jsr	CLEARSCREEN
	jsr	ENDSUPER
	clr.w	-(sp)
	trap	#1

flaghandler:
	cmp.w	#1,putoutflag
	beq	noputout
	jsr	putout
noputout:
	cmp.w	#0,putoutflag
	beq	noputaway
	jsr	putaway
noputaway:
	rts
setchoice:
	move.l	#$60000,a0
	move.l	#$40000,a1
	cmp.w	#8,choice
	bge	setother
	move.w	choice,d3
	muls	#9*160,d3
	add.w	d3,a0
	add.w	d3,a1
	add.w	#160*85+8*2,a0
	add.w	#160*85+8*2,a1
	jmp	setit
setother:
	move.w	choice,d3
	sub.w	#7,d3
	muls	#9*160,d3
	add.w	d3,a0
	add.w	d3,a1
	add.w	#160*85+8*9,a0
	add.w	#160*85+8*9,a1
setit:
	move.b	#%11000000,(a0)
	move.b	#%11110000,160(a0)
	move.b	#%11111100,320(a0)
	move.b	#%11111111,480(a0)
	move.b	#%11111100,640(a0)
	move.b	#%11110000,800(a0)
	move.b	#%11000000,960(a0)
	move.b	#%11000000,(a1)
	move.b	#%11110000,160(a1)
	move.b	#%11111100,320(a1)
	move.b	#%11111111,480(a1)
	move.b	#%11111100,640(a1)
	move.b	#%11110000,800(a1)
	move.b	#%11000000,960(a1)
	rts
delchoice:
	move.l	#$40000,a0
	move.l	#$60000,a1
	cmp.w	#8,oldchoice
	bge	delother
	move.w	oldchoice,d3
	muls	#9*160,d3
	add.w	d3,a0
	add.w	d3,a1
	add.w	#160*85+8*2,a0
	add.w	#160*85+8*2,a1
	jmp	delit
delother:
	move.w	oldchoice,d3
	sub.w	#7,d3
	muls	#9*160,d3
	add.w	d3,a0
	add.w	d3,a1
	add.w	#160*85+8*9,a0
	add.w	#160*85+8*9,a1
delit:	move.b	#0,(a0)
	move.b	#0,160(a0)
	move.b	#0,320(a0)
	move.b	#0,480(a0)
	move.b	#0,640(a0)
	move.b	#0,800(a0)
	move.b	#0,960(a0)
	move.b	#0,(a1)
	move.b	#0,160(a1)
	move.b	#0,320(a1)
	move.b	#0,480(a1)
	move.b	#0,640(a1)
	move.b	#0,800(a1)
	move.b	#0,960(a1)
	rts
setnuffror:
	cmp.l	#$50000,$44e
	beq	nonuff
	move.l	$44e,a0
	add.w	#160*93+7*8,a0
	move.w	val1,d0	
	bsr	setthenuff
	move.w	val2,d0	
	bsr	setthenuff
	move.w	val3,d0	
	bsr	setthenuff
	move.w	val4,d0	
	bsr	setthenuff
	move.w	val5,d0	
	bsr	setthenuff
	move.w	val6,d0	
	bsr	setthenuff
	move.w	val7,d0	
	bsr	setthenuff
	move.l	$44e,a0
	add.w	#160*93+16*8,a0
	move.w	spd1,d0	
	bsr	setthenuff
	move.w	spd2,d0	
	add.w	#9*160,a0
	move.w	spd3,d0	
	lsr.w	#1,d0
	bsr	setthenuff
	move.w	spd4,d0	
	lsr.w	#1,d0
	bsr	setthenuff
	move.w	spd5,d0	
	bsr	setthenuff
	move.w	spd6,d0	
	bsr	setthenuff
	move.w	spd7,d0	
	bsr	setthenuff
nonuff:
	rts
setthenuff:
	move.l	#nuffror,a1
	lsr.w	#1,d0
	and.w	#$ff,d0	
	mulu	#16,d0
	add.w	d0,a1
	move.w	(a1)+,(a0)
	move.w	(a1)+,160(a0)
	move.w	(a1)+,320(a0)
	move.w	(a1)+,480(a0)
	move.w	(a1)+,640(a0)
	move.w	(a1)+,800(a0)
	move.w	(a1)+,960(a0)
	add.w	#9*160,a0
	rts
putout:
	cmp.w	#111,rowcount
	beq	noincrow
	add.w	#1,rowcount
noincrow:
	rts	
putaway:
	cmp.w	#0,palette+30
	beq	fadeready
	add.w	#1,fontfadec
	cmp.w	#5,fontfadec
	ble	nofadefont
	move.w	#0,fontfadec
	add.l	#32,fontpal
	move.l	fontpal,a0
	add.w	#16,a0
	move.l	#palette+16,a1
	rept	4
	move.l	(a0)+,(a1)+
	endr
nofadefont:
	rts
fadeready:
	cmp.w	#0,rowcount
	beq	nodecrow
	sub.w	#1,rowcount
	bra	notaway
nodecrow:
	move.w	#1,exitflag
	rts
notaway:
	rts
setcode:
	move.l	#cornycode+34,a0
	move.l	#$60000,a1
	move.w	#7999,d0
	setcodeloop:
		move.l	(a0)+,(a1)+
	dbra	d0,setcodeloop
	rts
fadecodeup:
	move.w	#14,d2
	fadecodeuploop:
		rept	6
		jsr	vsync
		endr
		move.l	codepaladr,a0
		move.l	#$ff8240,a1
		rept	8
		move.l	(a0)+,(a1)+
		endr
		move.l	a0,codepaladr
	dbra	d2,fadecodeuploop
	rts
fadecodedown:
	move.w	#14,d2
	fadecodedownloop:
		rept	6
		jsr	vsync
		endr
		move.l	codepaladr,a0
		move.l	#$ff8260,a1
		rept	8
		move.l	-(a0),-(a1)
		endr
		move.l	a0,codepaladr
	dbra	d2,fadecodedownloop
	rts
vsync:	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
waitloop:
	jsr	vsync
	dbra	d1,waitloop
	rts
f1:
	move.w	#2,val2
	move.w	#2,spd1
	move.w	#8,spd3
	move.w	#4,spd4
	move.w	#4,spd5
	move.w	#2,spd6
	move.w	#0,spd7
	jmp	mainloop
f2:
	move.w	#2,val2
	move.w	#0,spd1
	move.w	#4,spd3
	move.w	#8,spd4
	move.w	#2,spd5
	move.w	#0,spd6
	move.w	#0,spd7
	jmp	mainloop
f3:
	move.w	#2,val2
	move.w	#2,spd1
	move.w	#8,spd3
	move.w	#0,spd4
	move.w	#2,spd5
	move.w	#0,spd6
	move.w	#0,spd7
	jmp	mainloop
f4:
	move.w	#6,val2
	move.w	#0,spd1
	move.w	#4,spd3
	move.w	#0,spd4
	move.w	#4,spd5
	move.w	#0,spd6
	move.w	#0,spd7
	jmp	mainloop
f5:
	move.w	#4,val2
	move.w	#2,spd1
	move.w	#8,spd3
	move.w	#4,spd4
	move.w	#4,spd5
	move.w	#2,spd6
	move.w	#0,spd7
	jmp	mainloop

*******************************
*       SUB - ROUTINES        *
*******************************
SETSUPER:
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	MOVE.L	D0,savesuper
	RTS
ENDSUPER:
	MOVE.L	savesuper,-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	RTS
*******************************
SETSCREEN:
	MOVE.W	#0,-(SP)
	MOVE.L	#$60000,-(SP)
	MOVE.L	#$40000,-(SP)
	MOVE.W	#$5,-(SP)
	TRAP	#14
	ADD.L	#12,SP
	RTS
*******************************
CLEARSCREEN:
	MOVE.L	#$60000,A0
	MOVE.L	#$40000,A1
	MOVE.L	#$50000,A2
	MOVE.W	#40*280,D0
CLEARSCREENLOOP:
	CLR.L	(A0)+
	CLR.L	(A1)+
	CLR.L	(A2)+
	DBF.W	D0,CLEARSCREENLOOP
	RTS
***************************************************************************
setscrollback:
	move.l	#scrollback,a0
	move.l	#$60000+160*230,a1
	move.l	#$40000+160*230,a2
	move.w	#40*30-1,d0
	setscrollbackloop:
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	dbra	d0,setscrollbackloop
	rts
***************************************************************************
calcdist:
	move.l	#disttab,a0
	move.w	#127,d1
	calcdistloop1:
		move.l	#sintab,a1
		move.w	#359,d0
		calcdistloop2:
			clr.l	d2
			move.w	(a1)+,d2
			muls	d1,d2
			divs	#512,d2
			bclr	#0,d2
			move.w	d2,(a0)+
		dbra	d0,calcdistloop2
	dbra	d1,calcdistloop1
	rts
***************************************************************************
calcwidth:
	move.l	#widthtab,a0
	move.l	#sintab,a1
	move.w	#359,d0
	calcwidthloop:
		clr.l	d2
		move.w	(a1)+,d2
		muls	#50,d2
		divs	#512,d2
		add.w	#50,d2
		muls	#720,d2
		move.l	d2,(a0)+
	dbra	d0,calcwidthloop
	rts
***************************************************************************
setchrome:
	move.l	#chrome,a0
	move.l	#$60000+10*160,a1
	move.l	#$40000+10*160,a2
	move.w	#40*53-1,d0
	setchromeloop:
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	dbra	d0,setchromeloop
	rts
***************************************************************************
setcorny:
	move.l	#corny,a0
	move.l	#$60000+166*160,a1
	move.l	#$40000+166*160,a2
	move.w	#40*53-1,d0
	setcornyloop:
		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
	dbra	d0,setcornyloop
	rts
***************************************************************************
settext:
	move.l	#text,a0
	move.l	#$60000+78*160+2*8,a1
	move.l	#$40000+78*160+2*8,a2
	move.w	#76,d0
	settextloop:
		rept 	15
		move.w	(a0),(a1)
		move.w	(a0)+,(a2)
		addq.w	#8,a1
		addq.w	#8,a2
		endr
		add.w	#5*8,a1
		add.w	#5*8,a2
	dbra	d0,settextloop
	rts
***************************************************************************
clearpal:
	move.l	#$ff8240,a0
	rept	8
	clr.l	(a0)+
	endr
	rts
***************************************************************************
setpal:
	move.l	chromepal,$ff8240
	move.l	chromepal+4,$ff8244
	move.l	chromepal+8,$ff8248
	move.l	chromepal+12,$ff824c
	move.l	chromepal+16,$ff8250
	move.l	chromepal+20,$ff8254
	move.l	chromepal+24,$ff8258
	move.l	chromepal+28,$ff825c
	rts
***************************************************************************
init:
	move.b	$fffffa07.w,old07
	move.b	$fffffa09.w,old09
	move.b	$fffffa13.w,old13
	move.b	$fffffa15.w,old15
	move.b	$fffffa17.w,old17
	move.b	$fffffa19.w,old19
	move.b	$fffffa1b.w,old1b
	move.l	$68.w,old68
	move.l	$70.w,old70
	move.l	$120.w,old120
	move.l	$134.w,old134
	
	move	#$2700,sr
	move.b	#$21,$fffffa07.w
	clr.b	$fffffa09.w
	move.b	#$21,$fffffa13.w
	clr.b	$fffffa15.w
	clr.b	$fffffa19.w
	clr.b	$fffffa1b.w
	move.l	#PHBL,$68.w
	move.l	#NEWVBI,$70.w
	move.l	#NEWVBL2,$134.w
	move.l	#newhbi,$120.w
	bclr.b	#3,$fffffa17.w
	move 	#$2300,sr	
	rts
*******************************
WAITVBL:
	CMP.W	#1,WFNC
	BNE.S	WAITVBL
	MOVE.W	#0,WFNC
	RTS
*******************************
*       VBL - INTERUPPT       *
*******************************
NEWVBI:
	movem.l	d0-d7/a0-a6,-(sp)
	CLR.B	$FFFFFA19.W
	MOVE.B	#99,$FFFFFA1F.W
	MOVE.B	#4,$FFFFFA19.W
	MOVE.W	#1,WFNC
	jsr	music+8
	jsr	setpal
	move.l	#newhbi,$120.w
	move.b	#229,$fffffa21.w
	move.b	#8,$fffa1b	
	bclr	#0,$fffa0f
	move.l	#disttab,a5
	move.l	#widthtab,a4
	add.w	val3,a4
	add.l	(a4),a5
	add.w	val5,a5
	add.w	val6,a5
	add.w	val7,a5
	move.l	#disttab,a6
	move.l	#widthtab,a4
	add.w	val4,a4
	add.l	(a4),a6
	add.w	val1,a6
	move.l	#plasmacolors+270,a3
	add.w	(a6),a3
	move.l	a6,savea6
	move.l	a3,a6
	clr.l	d4
	move.w	#90,d4

	move.l	#$ff8240,a4
	move.l	#rasters,a2
	move.w	(a2)+,2(a4)

	clr.l	d6
	move.w	val2,d6
	add.w	(a5),a3
	add.w	d6,a5
SYNCLOCK:
	MOVE.B 	$FFFF8209.W,D0
	BEQ 	SYNCLOCK
	MOVEQ 	#64,D1
	SUB.W 	D0,D1
	ASR.W 	D1,D0
	MOVE.B	#0,$FFFF8260.W
	DCB.W	70,$4E71
	MOVE.W	rowcount,D7
LOOP:
	rept	37
	MOVE.W	(A3)+,(a4)
	endr
	move.w	(a2)+,2(a4)
	add.w	d4,a6
	move.l	a6,a3
	add.w	(a5),a3
	add.w	d6,a5
	dcb.w	1,$4e71
	rept	37
	MOVE.W	(A3)+,(a4)
	endr
	move.w	(a2)+,2(a4)
	add.w	d4,a6
	move.l	a6,a3
	add.w	(a5),a3
	add.w	d6,a5
	move.w	#0,$ff8240
	DCB.W	1,$4E71
	DBF.W	D7,LOOP
	clr.l	$ff8240
	clr.l	$ff8244
	clr.l	$ff8248
	clr.l	$ff824c
	clr.l	$ff8250
	clr.l	$ff8254
	clr.l	$ff8258
	clr.l	$ff825c
	move.l	savea6,a6
	bclr	#0,$fffffa0f.w
	movem.l	(sp)+,d0-d7/a0-a6
	RTE
***************************************************************************
NEWVBL2:
	MOVE	#$2100,SR
	STOP	#$2100
	MOVE	#$2700,SR
	CLR.B	$FFFFFA19.W	
	MOVEM.L	D0-D7/A0-A1,-(SP)
	DCB.W	60,$4E71
	MOVE.B	#0,$FFFF820A.W
	DCB.W	7,$4E71
	CLR	D1
	MOVE	#$8209,A0
	MOVE.B	#2,$FFFF820A.W
	MOVEM.L	(SP)+,D0-D7/A0-A1
PHBL:
	rte
***************************************************************************
newhbi:
	move.b	#%11111100,$ff820a
	dcb.w	5,$4e71
	move.b	#%11111110,$ff820a
	move.l	palette+16,$ff8250
	move.l	palette+20,$ff8254
	move.l	palette+24,$ff8258
	move.l	palette+28,$ff825c
 	clr.b 	$fffffa1b.w	
	bclr 	#0,$fffffa0f.w	
	rte
***************************************************************************
screenswap:
	cmpi.l	#$40000,$44e
	bne	logphys	
	physlog:
		move.w	#-1,-(sp)
		move.l	#$40000,-(sp)
		move.l	#$60000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
		rts
	logphys:
		move.w	#-1,-(sp)
		move.l	#$60000,-(sp)
		move.l	#$40000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
	rts
***************************************************************************
scroll32p1:
 	bsr	scroll32p1scroll
	add.w	#1,scroll32p1count
	cmp.w	#1,scroll32p1count
	beq.s	scroll32p1setfont1
	cmp.w	#2,scroll32p1count
	beq	scroll32p1setfont2
	cmp.w	#3,scroll32p1count
	beq	scroll32p1setfont3
	cmp.w	#4,scroll32p1count
	beq	scroll32p1setfont4
	cmp.w	#5,scroll32p1count
	beq.s	scroll32p1newchar
	rts
scroll32p1newchar:
	move.w	#0,scroll32p1count
	bsr	scroll32p1setfont5
	bsr.s	scroll32p1readchar
	rts
scroll32p1readchar:
	move.l	#scroll32p1ptr,a0
	move.l 	(a0),a0
	clr.l	d0
	move.b	(a0)+,d0
	move.l	a0,scroll32p1ptr
	
	cmp.b	#$ff,d0
	bne.s	scroll32p1nowrap
	move.l	#scroll32p1txt,scroll32p1ptr
	bra.s	scroll32p1readchar
scroll32p1nowrap:
	sub.w	#32,d0
	muls	#128,d0
	add.l	#scroll32p1fnt+34,d0
	move.l	d0,scroll32p1charadr
	rts
scroll32p1setfont1:
	move.l	scroll32p1charadr,a0
	move.l	$44e,a1
	add.l	#160*230+158,a1
	move.w	#31,d0
	scroll32p1setfontloop1:
		move.b	#0,(a1)
		move.b	(a0),1(a1)
		add.w	#4,a0
		add.w	#160,a1
	dbf.w	d0,scroll32p1setfontloop1
	rts
scroll32p1setfont2:
	move.l	scroll32p1charadr,a0		
	move.l	$44e,a1
	add.l	#160*230+158,a1
	move.w	#31,d0
	scroll32p1setfontloop2:
		move.w	(a0),(a1)
		add.w	#4,a0
		add.w	#160,a1
	dbf.w	d0,scroll32p1setfontloop2
	rts
scroll32p1setfont3:
	move.l	scroll32p1charadr,a0
	move.l	$44e,a1
	add.l	#160*230+158,a1
	move.w	#31,d0
	scroll32p1setfontloop3:
		move.b	1(a0),(a1)
		move.b	2(a0),1(a1)
		add.w	#4,a0
		add.w	#160,a1
	dbf.w	d0,scroll32p1setfontloop3
	rts
scroll32p1setfont4:
	move.l	scroll32p1charadr,a0
	move.l	$44e,a1
	add.l	#160*230+158,a1
	move.w	#31,d0
	scroll32p1setfontloop4:
		move.w	2(a0),(a1)
		add.w	#4,a0
		add.w	#160,a1
	dbf.w	d0,scroll32p1setfontloop4
	rts
scroll32p1setfont5:
	move.l	scroll32p1charadr,a0
	move.l	$44e,a1
	add.l	#160*230+158,a1
	move.w	#31,d0
	scroll32p1setfontloop5:
		move.b	3(a0),(a1)
		move.b	#0,1(a1)
		add.w	#4,a0
		add.w	#160,a1
	dbf.w	d0,scroll32p1setfontloop5
	rts
scroll32p1scroll:
	move.l	$44e,a0
	add.l	#160*230+6,a0
	move.w	#31,d0
 scroll32p1scrolloop:
	move.w	8(a0),0(a0)
	move.w	16(a0),8(a0)
	move.w	24(a0),16(a0)
	move.w	32(a0),24(a0)
	move.w	40(a0),32(a0)
	move.w	48(a0),40(a0)
	move.w	56(a0),48(a0)
	move.w	64(a0),56(a0)
	move.w	72(a0),64(a0)
	move.w	80(a0),72(a0)
	move.w	88(a0),80(a0)
	move.w	96(a0),88(a0)
	move.w	104(a0),96(a0)
	move.w	112(a0),104(a0)
	move.w	120(a0),112(a0)
	move.w	128(a0),120(a0)
	move.w	136(a0),128(a0)
	move.w	144(a0),136(a0)
	move.w	152(a0),144(a0)
	add.w	#160,a0
	dbf.w	d0,scroll32p1scrolloop
	rts
scroll32p1ptr:		dc.l	scroll32p1txt
scroll32p1count:	dc.w	0
scroll32p1charadr:	dc.l	scroll32p1fnt+34
***************************************************************************
savesuper:	dc.l	0
savea6:		dc.l	0
old07:		dc.b	0
old09:		dc.b	0
old13:		dc.b	0
old15:		dc.b	0
old17:		dc.b	0
old19:		dc.b	0
old1b:		dc.b	0
old68:		dc.l	0
old70:		dc.l	0
old120:		dc.l	0
old134:		dc.l	0
WFNC:		DC.W	0 
val1:		dc.w	0
val2:		dc.w	2
val3:		dc.w	$ce*2
val4:		dc.w	$aa*2
val5:		dc.w	0
val6:		dc.w	0
val7:		dc.w	$f6*2
add1:		dc.w	0
add2:		dc.w	0
add3:		dc.w	0
add4:		dc.w	0
add5:		dc.w	0
add6:		dc.w	0
add7:		dc.w	0
spd1:		dc.w	2
spd2:		dc.w	0
spd3:		dc.w	0
spd4:		dc.w	0
spd5:		dc.w	2
spd6:		dc.w	4
spd7:		dc.w	0
choice:		dc.w	1
oldchoice:	dc.w	1
distptr:	dc.l	0
savepic:	dc.l	0
rowcount:	dc.w	0
putoutflag:	dc.w	0	
exitflag:	dc.w	0
fontfadec:	dc.w	0
fontpal:	dc.l	palette
codepaladr:	dc.l	codepal
scroll32p1txt:
 dc.b "                            "
 DC.B "            YO! THIS IS CORNY, AND I'VE MADE THE SCREEN YOU'RE LOOKING AT RIGHT NOW. I KNOW THAT THIS ISN'T THE FIRST PLASMA SCREEN I MAKE, BUT IT'S SURE THE BEST. THE CREDITS FOR THE SCREEN: ALL CODE BY CORNY. ALL GRAPHIX AND MUZAX BY "
 DC.B "LORD.     OKAY, EHAT SHOULD I WRITE ABOUT NOW?           YEAH, THE GREETINGS:        ANATOMICA (NICE LITTLE MEETING YOU ARRANGED IN UPPSALA. TOO BAD THAT WE DIDN'T FINISH THIS DEMO THERE)           WILDFIRE (KEEP CODING, AND DONT BE "
 DC.B " AFRAID TO GET IN TOUCH)            ZEAL (TOO BAD YOUR GUESTSCREEN DIDN'T WORK ON 520ST)         THE FINAL SPACECODERS (THANKS FOR THE GUESTSCREEN GUYS!)                IMPULSE (SORRY I COULDN'T COME TO YOUR PARTY THIS SUMMER, BUT I "
 DC.B "COULDN'T AFFORD SUCH A LONG TRIP AT THE TIME)           DANNE (NICE TO HEAR FROM YOU AGAIN. HOPE YOU JOIN OR START A GROUP AND GET ACTIVE AGAIN)          WOLF (WE COULDN'T USE ANY OF YOUR MODULES IN THIS DEMO, BUT WE HAVE OTHER PROJECTS "
 DC.B "PLANNED)          HYBRIS (I HAVEN'T HEARD FROM YOU FOR A LONG WHILE. IF YOU READ THIS, PLEEEZE GET IN TOUCH)             THE INVIZIBLES (PLEASE SEND MY DISKS BACK, DARK SHADOW. THAT'S THE LEAST YOU CAN DO AS WE SENT YOU THE ONLY NEW DEMOS "
 DC.B "THAT YOU'VE GOT YOUR HAND ON THE LATEST CENTURY)            CYBERPUNKS (WHEN DO I GET A DEMO FROM YOU?)       WELL, THAT'S IT. OH! I ALMOST FORGOT! MEGA GREETS OF COURSE TO SILENTS ON AMIGA ($RE KUL I LUMPEN SIGGE?).  NOW I'VE RUN OUT OF "
 DC.B "IDEAS WHAT TO WRITE ABOUT, SO I THINK I'LL JUST GIVE YOU MY ADDRESS AND LEAVE IT LIKE THAT. TO CONTACT ME, WRITE TO : CORNY OF CRYSTALIC      GAMMELBANSV. 26    82440 HUDIKSVALL      CORNY OF CRYSTALIC      GAMMELBANSV. 26    82440 "
 DC.B "HUDIKSVALL.      THAT'S IT, CORNY OF CRYSTALIC SIGNING OF, NOW OVER TO LORD: "

 dc.b "            AGAIN THIS IS LORD FROM CRYSTALIC WRITING..  "
 DC.B "I WILL NOW TURN OVER TO SWEDISH (AS MANY FRENCH CREWS WRITES IN FRENCH,ANOYING!) FOR A WHILE....   HUR $R L$GET GRABBAR?."
 DC.B "T$NK VAD ALLA SNUBBAR SOM INTE KAN SVENSKA SKA UNDRA VAD JAG SKRIVER.JAG TROR JAG DRAR TILL MED N#GRA F# ORD SOM DOM "
 DC.B "KANSKE FATTAR S# BLIR DOM $NNU MER VARULV!.. L#T OSS B%RJA: DENNA VACKRA PLASMA $R GJORD AV CORNY OCH INTE OMEGA ELLER ELECTRA (FAST DOM KAN B$TTRE,TROR JAG).. COKE TYCKER JAG INTE OM.. LIPTON YELLOW LABEL "
 DC.B "TEA $LSKAR JAG...  JAG GILLAR ATT #KA BIL MED H%G FART (SMART VA!,NU TROR DOM JAG SKREV ATT JAG FES!)... JAG $GER EN CM8833-II SOM JAG V#RDAR %MT (J$VLA SM%RIGT VA?).. VAD NU R#?.. JO! JAG KAN V$L H$LSA TILL "
 DC.B "ALLA SOM VAR P# DET PRIVATA PARTYT I UPPSALA SOM OB FIXADE...HEJ GOSSAR SM#!.NU B%RJAR JAG BLI LITE TR%TT P# ATT SKRIVA P# SVENSKA S# JAG GER ER BARA THE CREDITS INNAN JAG SWAPPAR TILL ENGELSKA OCH L#TER ER "
 DC.B "L$SA LITE GAMMALT GROLL FR#N OB OF ANATOMICA.H$R $ DET!..  CODAT AV CORNY FR#N CRYSTALIC   MED     GRAFIK SOM KOMMER FR#N SAMMA GRUPP MED DERAS GRAFIKER   LORD   SOM $VEN GJORT DEN TRALLV$NLIGA MUSIKEN.    "
 DC.B "N$$$ NU TROR JAG DET F#R R$CKA.. L#T MIG PRESENTERA OB OF ANATOMICA....      IN ENGLISH!....                                          "             
 dc.b "HEY !!!    WHY AM I WRITING A GUEST SCROLLER FOR "
 dc.b "CRYSTALIC WHEN I HARDLY CAN WRITE MY OWN SCROLLERS, I HATE TO WRITE 'EM !!!! "
 dc.b "BUT WHEN LORD ASKED ME IF I WOULD LIKE TO WRITE A GUEST SCROLLER I JUST "
 dc.b "COULDN'T SAY NO... IN FACT I DON'T HAVE TIME TO WRITE THIS AT ALL 'CAUSE I HAVE "
 dc.b "A GERMAN TEST TOMORROW AND A TECNOLOGY TEST THE DAY AFTER TOMORROW, BUT YOU "
 dc.b "KNOW, IT'S A LOT MORE FUNNY TO WRITE A SCROLLER THAN TO READ GERMAN !!! WELL, "
 dc.b "EVERYBODY HERE IN SWEDEN IS WAITING FOR THE "
 dc.b "FALCON. IT LOOKS LIKE THIS WINTER WILL BE JUST AS SNOW EMPTY AS THE LAST ONE. "
 dc.b "THERE IS STILL NO SNOW ON THE GROUND AND I THINK THATS SAD 'CAUSE I LIKE SNOW "
 dc.b "!!!     IN THE END OF THIS MONTH I'LL GET ON THE TRAIN AND HAVE A RIDE UP TO "
 dc.b "HUDIKVALL HERE IN SWEDEN WHERE ANATOMICA AND CAC WILL HAVE A PARTY.....   WAIT, "
 dc.b "I HAVN'T TOLD YOU WHO I AM YET, I'M -OB- OF ANATOMICA AND IF YOU'VE HEARD OF "
 dc.b "ME, THEN GOOD, ELSE, SORRY SUCKER !!!   WELL, BACK TO THE PARTY. AS A SAID I'LL "
 dc.b "GO UP TO HUDIKSVALL AND ON THE NEW YEAR'S EVE WE'LL (I AND CAC) GO OUT ON A "
 dc.b "DISCO OR SOMETHING LIKE THAT AND GET DRUNK.... WELL TWO DAYS AFTER THAT THE "
 dc.b "REAL PARTY STARTS, AS I SAID IT'LL BE ANATOMICA, CRYSTALIC AND MAYBE "
 dc.b "POWERSONIC, FRIENDCHIP AND THE BRAINIACS. THE PARTY WILL BE IN 3 DAYS AND THEN "
 dc.b "WE'LL BE REALLY TIRED...       I WONDER WHAT THIS SCREEN LOOKS LIKE.... IT'S "
 dc.b "PERHAPS A VECTOR SCREEN OR A PLASMA SCREEN, I DON'T KNOW. NO TIME TO TAKE A "
 dc.b "BREAK AND GO BACK TO THE HOMEWORK, I'LL FINISH THIS SCROLL SOME OTHER TIME. "
 dc.b "HI AGAIN, NOW I'M BACK ALMOST TWO WEEKS LATER AND IT IS AS WE SAY IN SWEDEN "
 dc.b "'DAN F%RE DAN F%RE DAN F%RE DOPPAREDAN'. TODAY I LOST A LOT OF MY CODE TOO, THE "
 dc.b "DISC JUST SCREWED UP, FUCK !!!   AND STILL NO SNOW !!!!       NOPE, I HOPE CAC "
 dc.b "WILL BE SATISFIED WITH 'DIS SCROLLER 'CAUSE NOW I'LL WRAP....... MERRY "
 dc.b "CHRISTMAS DUDES !!!   (CHRISTMAS!,DE E JU SEPTEMBER F%R FAAN!,LORD)                                                                                       WRAP!                                                  ",$ff
		EVEN
palette:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$010,$090,$020,$0a0,$030,$0b0,$040 
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$080,$010,$090,$020,$0a0,$030 
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$080,$010,$090,$020 
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$080,$010 
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 
codepal:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000 
		dc.w	$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111
		dc.w	$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222
		dc.w	$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333
		dc.w	$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444
		dc.w	$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555
		dc.w	$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666
		dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$777,$666,$666,$666,$666,$666,$666,$666,$767,$767,$767,$677,$677,$677,$677,$677
		dc.w	$777,$555,$666,$555,$555,$555,$555,$555,$767,$656,$656,$577,$577,$577,$577,$677
		dc.w	$777,$444,$666,$555,$444,$444,$444,$444,$767,$656,$545,$477,$477,$477,$577,$677
		dc.w	$777,$333,$666,$555,$444,$333,$333,$333,$767,$656,$545,$377,$377,$477,$577,$677
		dc.w	$777,$222,$666,$555,$444,$333,$222,$222,$767,$656,$545,$277,$377,$477,$577,$677
		dc.w	$777,$111,$666,$555,$444,$333,$222,$111,$767,$656,$545,$277,$377,$477,$577,$677
		dc.w	$777,$000,$666,$555,$444,$333,$222,$111,$767,$656,$545,$277,$377,$477,$577,$677
chromepal:	dc.w	$000,$000,$210,$321,$421,$431,$532,$542,$643,$653,$654,$754,$763,$765,$774,$777
rasters:	dcb.w	30,$000
		dc.w	$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$017,$09f,$027,$0af,$037,$0bf
		dc.w	$047,$0cf,$057,$0df,$067,$0ef,$077,$0ff
		dcb.w	19,$000
		dc.w	$213,$324,$435,$546,$657,$546,$435,$324,$000
		dcb.w	6,$000
		dc.w	$123,$234,$345,$456,$567,$456,$345,$234,$000
		dc.w	$132,$243,$354,$465,$576,$465,$354,$243,$000
		dc.w	$232,$343,$454,$565,$676,$565,$454,$343,$000
		dc.w	$332,$443,$554,$665,$776,$665,$554,$443,$000
		dc.w	$311,$422,$533,$644,$755,$644,$533,$422,$000
		dc.w	$312,$423,$534,$645,$756,$645,$534,$423,$000
		dc.w	$302,$403,$504,$605,$706,$605,$504,$403,$000
		dcb.w	31,$000
		dc.w	$001,$009,$002,$00a,$003,$00b,$004,$00c,$005,$00d,$006,$00e,$007,$00f,$017,$09f,$027,$0af,$037,$0bf
		dc.w	$047,$0cf,$057,$0df,$067,$0ef,$077,$0ff
sintab:		incbin	a:\cosin.dat
music:		incbin	a:\lordfunk.mus
scroll32p1fnt:	incbin	a:\32stret2.dat
scrollback:	incbin	a:\scrlback.dat
chrome:		incbin	a:\chrome.dat
corny:		incbin	a:\corny.dat
text:		incbin	a:\text2.dat
nuffror:	incbin	a:\nuffror.dat
plasmacolors:	incbin	a:\colours.dat
cornycode:	incbin	a:\cornyco.pi1
 section bss
widthtab:	ds.w	720
disttab:	ds.w	128*360
  