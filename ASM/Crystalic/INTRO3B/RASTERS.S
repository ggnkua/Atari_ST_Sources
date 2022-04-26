	move.l	$120,oldHBI
	move.l	$70,oldVBI
	move.l	$70,newVBIb+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
	move.b	$fffffa0f,old0f
	move.b	$fffffa11,old11
	move.b	$fffffa1b,old1b
	and.b 	#$df,$fffa09
	and.b 	#$fe,$fffa07
	move.l	#newHBI,$120
	move.l	#newVBI,$70
	or.b  	#1,$fffffa07
	or.b  	#1,$fffffa13
	rts

newVBI:
	movem.l	d0-d7/a0-a7,-(sp)
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21
	bclr	#0,$fffa0f
	move.b	#8,$fffffa1b.w
	move.l	#RasterColors,RasterPtr
	clr.b	$3000
	movem.l	(sp)+,d0-d7/a0-a7
	rte
newVBIb:	jmp		$11111110

newHBI:
	move.l  a0,-(sp)
	clr.b	$fffffa1b.w
	move.b  #1,$fffffa21
	move.l	RasterPtr,a0
	move.w	(a0)+,$ff8242
	move.l	a0,RasterPtr

	bclr	#0,$fffffa0f
	move.b	#8,$fffffa1b.w
	move.l	a0,RasterPtr

	move.l  (sp)+,a0
	rte
SaveSuper:	ds.l	1
RasterPtr:	ds.l	1
SaveColor:	ds.w	1
old07:		ds.b	1
old09:		ds.b	1
old0f:		ds.b	1
old11:		ds.b	1
old1b:		ds.b	1
oldHBI:		ds.l	1
oldVBI:		ds.l	1
RasterColors:
	dc.w	$000,$001,$002,$003,$004,$005,$006,$007,$117,$227,$337,$447,$557,$667,$777
	dc.w	$300,$500,$700,$500,$777,$777,$667,$557,$447,$337,$227,$117,$007,$006,$005,$004,$003,$002,$001,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$030,$040,$050,$060,$070,$171,$272,$373,$474,$575,$676,$777
	dc.w	$676,$575,$474,$373,$272,$171,$070,$060,$050,$040,$030,$020,$010,$000,$000,$000,$000