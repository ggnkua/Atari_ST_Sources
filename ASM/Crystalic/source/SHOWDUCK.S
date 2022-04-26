***************************************************************************
	jsr	setsuper
	jsr	setscreen
	jsr	clear
	jsr	setpal
	jsr	initborder
***************************************************************************
ankloop:
	jsr	waitvbl
	jsr	setback
	jsr	screenswap
	cmp.w	#160*50,ypos
	bne	ankloop
	jsr	endborder
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
setscreen:
	move.w	#0,-(sp)
	move.l	#$30000,-(sp)
	move.l	#$60000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
setpal:
	lea	anka+2,a0
	move.l	#$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	rts
***************************************************************************
screenswap:
	cmpi.l	#$30000,$44e
	bne	logphys	
	physlog:
		move.w	#-1,-(sp)
		move.l	#$30000,-(sp)
		move.l	#$60000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
		rts
	logphys:
		move.w	#-1,-(sp)
		move.l	#$60000,-(sp)
		move.l	#$30000,-(sp)
		move.w	#$5,-(sp)
		trap	#14
		add.l	#12,sp
	rts
***************************************************************************
clear:
	move.l	#$ff8240,a0
	rept	8
	move.l	#0,(a0)+
	endr
	move.l	#$30000,a0
	move.l	#$60000,a1
	move.w	#7999,d0
	clearloop1:
	move.l	#0,(a0)+
	move.l	#0,(a1)+
	dbf.w	d0,clearloop1
	rts
***************************************************************************
initborder:
	move.l	$70.w,oldvbl
	move.l	$120.w,oldhbl
	move.b	$fffffa1b.w,old1b
	move.b	$fffffa21.w,old21
	move.b	$fffffa07.w,old07
	move.b	$fffffa09.w,old09
	move.b	$fffffa13.w,old13
	move.w	#$2700,sr
	move.l	#newvbi,$70.w
	move.l	#borderhbi,$120.w	
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	clr.b	$fffffa1b.w
	move.w	#$2300,sr
	rts
***************************************************************************
endborder:
	move.l	oldvbl,$70.w
	move.l	oldhbl,$120.w
	move.b	old1b,$fffffa1b.w
	move.b	old21,$fffffa21.w
	move.b	old07,$fffffa07.w
	move.b	old09,$fffffa09.w
	move.b	old13,$fffffa13.w
	rts
***************************************************************************
newvbi:
	move.w	#1,vbiflag
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21.w
	move.l	#borderhbi,$120.w
	move.b	#8,$fffffa1b.w
	rte
***************************************************************************
borderhbi:
	clr.b	$fffffa1b.w
	movem.l	d0/a0,-(a7)	
	movea.w	#$fa21,a0
	move.b	#200,(a0)
	move.b	#8,$fffffa1b.W
	move.b	(a0),d0
bwait:	cmp.b	(a0),d0			
	beq	bwait
	clr.b	$ffff820a.w
	moveq.w	#2,d0
bloop:	nop
	dbf	d0,bloop
	move.b	#2,$ffff820a.w
	movem.l	(a7)+,d0/a0
	bclr	#0,$fffffa0f.w
	rte
***************************************************************************
waitvbl:
	cmp.w	#1,vbiflag
	bne	waitvbl
	move.w	#0,vbiflag
	rts
***************************************************************************
setback:
	lea	anka+34,a5
	move.l	$44e,a6
	add.w	ypos,a6
	sub.w	#160,ypos
	move.w	#800,d6
	move.w	#39,d7
	setbackloop:
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,40(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,80(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,120(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,160(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,200(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,240(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,280(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,320(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,360(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,400(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,440(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,480(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,520(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,560(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,600(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,640(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,680(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,720(a6)
		movem.l	(a5)+,d0-d4/a0-a4
		movem.l	d0-d4/a0-a4,760(a6)
		add.w	d6,a6
	dbf.w	d7,setbackloop
	rts
***************************************************************************
savesuper:	dc.l	0
vbiflag:	dc.w	0
oldvbl:		dc.l	0
oldhbl:		dc.l	0
old1b:		dc.b	0
old21:		dc.b	0
old07:		dc.b	0
old09:		dc.b	0
old13:		dc.b	0
ypos:		dc.w	32000
anka:		incbin	a:\coolduck.pi1
