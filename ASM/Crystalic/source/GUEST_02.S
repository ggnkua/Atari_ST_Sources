***************************************************************************
  	jsr	setsuper
	jsr	setscreen
	jsr	clearscreen
	jsr	setlogo
	jsr	init
***************************************************************************
logofade:
	move.l	#logofadetab,a0
	move.w	#5,d0
	logofadeloop:
		jsr	waitvbl
 		jsr	waitvbl
		jsr	waitvbl
 		jsr	waitvbl
		jsr	waitvbl
		move.l	#logopal,a1
		rept	8
		move.l	(a0)+,(a1)+
		endr
	dbra	d0,logofadeloop
***************************************************************************
	move.w	#49,d0
waitloop:
	jsr	waitvbl
	dbra	d0,waitloop
***************************************************************************
logoloop:
	jsr	waitvbl
	jsr	setlogo
	cmp.w	#0,logopos
	beq	linefade
	sub.w	#1,logopos
	bra	logoloop
***************************************************************************
linefade:
	move.l	#linefadetab,a0
	move.w	#13,d0
	linefadeloop:
		jsr	waitvbl
 		jsr	waitvbl
		jsr	waitvbl
		move.w	(a0)+,linecol
	dbra	d0,linefadeloop
loop:	jmp	loop
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
	move.l	#$60000,-(sp)
	move.l	#$60000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
clearscreen:
	move.l	#$60000,a0
	move.w	#40*250,d0
	clearscreenloop:
		clr.l	(a0)+
	dbf.w	d0,clearscreenloop
	rts
***************************************************************************
setlogo:
	move.l	#logo,a0		
	move.l	$44e,a1
	move.w	logopos,d0
	muls	#160,d0
	add.w	d0,a1 
	move.w	#1999,d0
	setlogoloop:
		move.l	(a0)+,(a1)+
	dbf.w	d0,setlogoloop
	rts
***************************************************************************
setpal:
	move.l	#logopal,a0
	move.l	#$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	rts
***************************************************************************
init:
	move	#$2700,sr
	move.b	#$21,$fffffa07.w
	clr.b	$fffffa09.w
	move.b	#$21,$fffffa13.w
	clr.b	$fffffa15.w
	clr.b	$fffffa19.w
	clr.b	$fffffa1b.w
	move.l	#phbi,$68.w
	move.l	#newvbi,$70.w
	move.l	#newvbi2,$134.w
	move.l	#newhbi,$120.w
	bclr.b	#3,$fffffa17.w
	move 	#$2300,sr	
	rts
***************************************************************************
retinit:
	move.w	#$2700,sr
	move.l	oldvbi,$70.w
	move.b	old07,$fffffa07.w
	move.b	old09,$fffffa09.w
	move.w	#$2300,sr
	rts
***************************************************************************
waitvbl:
	cmp.w	#1,vbiflag
	bne.s	waitvbl
	move.w	#0,vbiflag
	rts
***************************************************************************
newvbi:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#logopal,a0
	move.l	#$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	clr.b	$fffffa19.w
	move.b	#99,$fffffa1f.w
	move.b	#4,$fffffa19.w
	move.l	#newhbi,$120.w
	clr.b	$fffffa1b.w
	move.b	#120,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	move.l	distptr,a5
	cmp.l	#disttab+7*720,a5
	blo	nodistwrap
	move.l	#disttab,distptr
	move.l	distptr,a5
nodistwrap:
	move.l	distptr,a4
	move.w	(a4)+,d6
	move.w	(a4)+,d6
	move.l	a4,distptr
	move.l	distptr2,a6
	cmp.l	#disttab+7*720,a6
	blo	nodistwrap2
	move.l	#disttab,distptr2
	move.l	distptr2,a6
nodistwrap2:
	move.l	distptr2,a4
	move.w	(a4)+,d6
	move.l	a4,distptr2
	lea	plasmapal,a3
	add.w	(a5)+,a3
	add.w	(a6)+,a3
	move.l	#$ff8250,a4
	clr.l	d7
	move.w	logopos,d7
	add.w	#50,d7
	divu	#2,d7
	sub.w	#1,d7
synclock:
	move.b 	$ffff8209.w,d0
	beq 	synclock
	moveq 	#64,d1
	sub.w 	d0,d1
	asr.w 	d1,d0
	move.b	#0,$ffff8260.w
	dcb.w	70,$4e71
vertloop:
	rept	39
	move.w	(a3)+,(a4)
	endr
	lea	plasmapal,a3
	add.w	(a5)+,a3
	add.w	(a6)+,a3
	dcb.w	1,$4e71
	rept	39
	move.w	(a3)+,(a4)
	endr
	lea	plasmapal,a3
	add.w	(a5)+,a3
	add.w	(a6)+,a3
	dbf.w	d7,vertloop
	move.w	linecol,$ff8240
	move.l	#palette+2,a0
	move.l	#$ff8242,a1
	move.w	(a0)+,(a1)+
	rept	7
	move.l	(a0)+,(a1)+
	endr
	dcb.w	55,$4e71
	move.w	palette,$ff8240
	move.w	#1,vbiflag
	movem.l	(sp)+,d0-d7/a0-a6
	rte
***************************************************************************
newvbi2:
	move	#$2100,sr
	stop	#$2100
	move	#$2700,sr
	clr.b	$fffffa19.w	
	movem.l	d0-d7/a0-a1,-(sp)
	dcb.w	60,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	7,$4e71
	clr	d1
	move	#$8209,a0
	move.b	#2,$ffff820a.w
	movem.l	(sp)+,d0-d7/a0-a1
phbi:	rte
***************************************************************************
newhbi:
	move.w	linecol,$ff8240
	move.l	#newhbi2,$120.w
	move.b	#1,$fffffa21.w
	bclr	#0,$fffffa0f
	rte
***************************************************************************
newhbi2:
	clr.b	$fffffa1b.w
	move.w	#$000,$ff8240
	bclr	#0,$fffffa0f
	rte
***************************************************************************
savesuper:	dc.l	0
oldvbi:		dc.l	0
old07:		dc.b	0
old09:		dc.b	0
linecol:	dc.w	0
logopos:	dc.w	100
vbiflag:	dc.w	0 
palette:	dc.w	$000,$542,$431,$320,$210,$202,$303,$404,$111,$222,$505,$606,$123,$234,$345,$777
logopal:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
distptr:	dc.l	disttab
distptr2:	dc.l	disttab2
plasmapal:	dc.w	$001,$002,$003,$004,$005,$006
		dc.w	$007,$017,$037,$037,$047,$057,$067,$077,$167,$257,$347,$437,$527,$617,$707,$717,$727,$737,$747,$757,$767,$777,$766,$755,$744,$733,$722,$711,$700,$710,$720,$730,$740,$750,$760,$770,$671,$572,$473,$374
		dc.w	$275,$176,$077,$176,$275,$374,$473,$572,$671,$770,$761,$752,$743,$734,$725,$716,$707,$617,$527,$437,$347,$257,$167,$077,$076,$075,$074,$003,$072,$071,$070,$060,$050,$040,$030,$020,$010,$000,$000,$000
linefadetab:	dc.w	$111,$222,$333,$444,$555,$666,$777,$666,$555,$445,$335,$225,$115,$005
logofadetab:	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$000,$100,$000,$000,$000,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$000,$210,$100,$000,$000,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$000,$320,$210,$100,$000,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$000,$431,$320,$210,$100,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
		dc.w	$000,$542,$431,$320,$210,$000,$000,$000,$777,$777,$777,$777,$777,$777,$777,$777
disttab:	include	a:\realwave.dat
disttab2:	include	a:\realwav2.dat
		include	a:\realwav3.dat
		include	a:\realwave.dat
		include	a:\realwav2.dat
logo:		incbin	a:\reslogo.dat