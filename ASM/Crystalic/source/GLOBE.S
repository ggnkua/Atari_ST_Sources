***************************************************************************
*			     STANDARD SOURCECODE			  * 
***************************************************************************
	jsr	setsuper
	jsr	clear
	jsr	setscreen
	jsr	setpal
	move.l	$70.w,oldvbi
	move.l	#newvbi,$70.w
***************************************************************************
mainloop:
	jsr	waitvbl
*	move.w	#$700,$ff8240
	jsr	clearglobe
	jsr	setglobe
	jsr	screenswap
	move.w	#$000,$ff8240
	jmp	mainloop
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
newvbi:
	move.w	#1,vbiflag
	rte
***************************************************************************
waitvbl:
	cmpi.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag
	rts 
***************************************************************************
setscreen:
	move.w	#0,-(sp)
	move.l	#$70000,-(sp)
	move.l	#$70000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
setpal:
	move.l	#palett,a0
	move.l	#$ff8240,a1
	rept 8
		move.l	(a0)+,(a1)+
	endr
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
clear:
	move.l	#$ff8240,a0
	rept	8
		move.l	#0,(a0)+
	endr
	move.l	#$70000,a0
	move.l	#$78000,a1
	move.w	#7999,d0
	clearloop:
		move.l	#0,(a0)+
		move.l	#0,(a1)+
	dbf.w	d0,clearloop
	rts
***************************************************************************
clearglobe:
	move.l	$44e,a0
	move.w	#0,d1
	move.w	#160,d2
	move.w	#199,d0
	clearglobeloop:
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
	dbf.w	d0,clearglobeloop
	rts
***************************************************************************
setglobe:
	add.w	#1,degrees
	cmp.w	#89,degrees
	ble	nodegwrap
	move.w	#0,degrees
nodegwrap:
	move.l	globecurveptr,a0
	move.w	(a0)+,d0
	move.w	(a0)+,d0
	move.l	a0,globecurveptr
	cmp.l	#globecurve+4*360,a0
	bne	noglobewrap
	move.l	#globecurve,globecurveptr
noglobewrap:
	move.l	#globedata,a0
	move.w	degrees,d0
	muls	#80,d0
	add.w	d0,a0
	move.l	a0,globeptr
	move.w	#0,d1
	setglobeloop:
		move.l	globeptr,a0
		move.b	(a0)+,d2
		move.l	a0,globeptr
		move.l	$44e,a1
		move.l	globecurveptr,a0
		add.w	(a0),d2
		move.w	2(a0),d3
		add.w	d1,d3
		cmp.w	#199,d3
		ble	nochanged3a
		move.w	#199,d3
nochanged3a:	cmp.w	#0,d3
		bge	nochanged3b
		move.w	#0,d3
nochanged3b:	muls	#160,d3
		add.w	d3,a1
		cmp.w	#319,d2
		ble	nochanged2a
		move.w	#319,d2
nochanged2a:	cmp.w	#0,d2
		bge	nochanged2b
		move.w	#0,d2
nochanged2b:	move.w	d2,d3
		and.w	#$fff0,d3
		asr.w	d3
		add.w	d3,a1
		lea	nibbles,a0
		and.w	#$000f,d2
		asl.w	d2
		move.w	(a0,d2.w),d0
		or.w	d0,(a1)
	addq.w	#1,d1
	cmp.w	#79,d1
	bne	setglobeloop
	rts
***************************************************************************
savesuper:	dc.l	0
vbiflag:	dc.w	0
oldvbi:		dc.l	0
degrees:	dc.w	0
globeptr:	dc.l	0
globecurveptr:	dc.l	globecurve
palett:		dc.w	$000,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
nibbles:	dc.w	$8000,$4000,$2000,$1000,$800,$400,$200,$100,$80,$40,$20,$10,$8,$4,$2,$1
globedata:	incbin	a:\globe.dat
globecurve:	include	a:\globcurv.dat
