***************************************************************************
*	 	   CORNYS DOTS      USES D0-D2/A0-A2		  	  * 	
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
	jsr	cleardots
	jsr	setdots
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
cleardots:
	addq.w	#8,clsine1
	cmp.w	#1432,clsine1
	ble	noclwrap1
	move.w	#0,clsine1
noclwrap1:
	addq.w	#2,clsine2
	cmp.w	#3598,clsine2
	ble	noclwrap2
	move.w	#2880,clsine2
noclwrap2:
	move.l	#dots,a0
	add.w	clsine1,a0
	move.l	#dots,a1
	add.w	clsine2,a1
	move.l	$44e,d1
	move.w	#0,d2
	move.w	#359,d0
	cleardotsloop:
		move.l	d1,a2
		add.w	(a0)+,a2
		add.w	(a1)+,a2
		addq.w	#2,a0
		move.w	d2,(a2)
	dbf.w	d0,cleardotsloop
	rts
***************************************************************************
setdots:
	addq.w	#8,sine1
	cmp.w	#1432,sine1
	ble	nowrap1
	move.w	#0,sine1
nowrap1:
	addq.w	#2,sine2
	cmp.w	#3598,sine2
	ble	nowrap2
	move.w	#2880,sine2
nowrap2:
	move.l	#dots,a0
	add.w	sine1,a0
	move.l	#dots,a1
	add.w	sine2,a1
	move.l	$44e,d1
	move.w	#359,d0
	setdotsloop:
		move.l	d1,a2
		add.w	(a0)+,a2
		add.w	(a1)+,a2
		move.w	(a0)+,d2
		or.w	d2,(a2)
	dbf.w	d0,setdotsloop
	rts
***************************************************************************
savesuper:	dc.l	0
oldvbi:		dc.l	0
vbiflag:	dc.w	0
sine1:		dc.w	16
sine2:		dc.w	360*8+4
clsine1:	dc.w	0
clsine2:	dc.w	360*8
palett:		dc.w	$000,$777,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
dots:		incbin	a:\sinedots.dat