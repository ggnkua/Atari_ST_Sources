***************************************************************************
*			 Updistande scroll av OB 921122			  * 
***************************************************************************
	jsr	setsuper
	jsr	setscreen

	move.w	#16000,d0
	move.l	#$30000,a0
clear2:	move.l	#0,(a0)+
	dbf.w	d0,clear2

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	clr.b	$fffa1b
	and.b	#$df,$fffa09
	move.l	#rasters,$120
	bset	#0,$fffa07
	bset	#0,$fffa13
	move.b	#0,$fffa21
	move.b	#8,$fffa1b

	move.l	$70.w,oldvbi
	move.l	#newvbi,$70.w

	move.l	#rastcol,a4
	move.w	#0,d3
***************************************************************************
mainloop:
	move.w	#$0,$ff8240
	jsr	waitvbl
	jsr	screenswap
	move.w	#$2,$ff8240

	move.w	#99,d0
	move.l	#schack,a0
	move.l	#$30000,a1
	add.w	srnp,a1
toscreen:
	move.w	(a0)+,(a1)
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
	add.w	#160,a1
	dbf.w	d0,toscreen

	jmp	mainloop
****************************************************************************
setsuper:
	clr.l	-(sp)			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesuper
	rts
***************************************************************************
newvbi:
	clr.b	$fffa1b
	move.b	#3,$fffa21
	move.b	#8,$fffa1b
	move.l	#rasters,$120
	move.w	#1,vbiflag

	move.w	#0,d3
	move.l	#rastcol,a4

	move.w	(a4)+,$ff8240
	move.w	(a4)+,$ff8242

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
	move.l	#$30000,-(sp)
	move.l	#$30000,-(sp)
	move.w	#$5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
***************************************************************************
rasters:	
	move.w	(a4)+,$ff8240
	move.w	(a4)+,$ff8242

	clr.b	$fffffa1b.w
	bclr	#0,$fffffa0f.w
	move.b	#10,$ffffa21
	move.b	#$8,$fffffa1b.w
	
	addq.w	#2,d3
	cmp.w	#12,d3
	beq	nomorerast

	move.l	#rasters,$120
	rte

nomorerast:
	move.l	#nmrast,$120

	rte
***************************************************************************
nmrast:
	clr.b	$fffa1b
	bclr	#0,$fffffa0f.w
	move.b	#8,$fffa1b
	rte
***************************************************************************
screenswap:
	add.w	#32000,srnp
	cmp.w	#64000,srnp
	bne	jhopp2
	move.w	#0,srnp
	move.w	#32000,osrnp
	bra	jhopp3
jhopp2:
	move.w	#0,osrnp
jhopp3:
	move.l	#$30000,d2
	add.w	srnp,d2
	lsr.l	#8,d2
	move.b	d2,$ff8203
	lsr.l	#8,d2
	move.b	d2,$ff8201
	rts
***************************************************************************
savesuper:	dc.l	0
vbiflag:	dc.w	0
oldvbi:		dc.l	0
srnp:		dc.w	0
osrnp:		dc.w	0
schack:		incbin	"schack.pic"
	even
rastcol:	dc.w	$1,$100,$200,$2,$3,$300,$400,$4,$5,$500,$600,$6,$7,$700
