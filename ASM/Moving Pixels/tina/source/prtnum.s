*****************************************
*	number in d0.l			*
*	d1.l is base			*
*	d2,x cursor			*
*	d3,y cursor			*
*****************************************
prtnum:
	movem.l	d0/d1,-(sp)
	lea	posstring,a0
	add.w	#32,d3
	move.b	d3,2(a0)	
	add.w	#32,d2
	move.b	d2,3(a0)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0/d1

	lea	linebuffer,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
loop1:
	divu	d1,d0
	swap	d0
	addi	#'0',d0
	cmpi.w	#'9',d0
	ble.s	ok
	addq.w	#7,d0
ok:
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	bne	loop1
loop2:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

clearnums:
	lea	clearstring,a0
	add.w	#32,d3
	move.b	d3,2(a0)	
*	move.b	d3,10(a0)	
	add.w	#32,d2
	move.b	d2,3(a0)
*	move.b	d2,11(a0)	
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
linebuffer:
	ds.l	5
digits:
	dc.b	0
posstring:	dc.b	27,'Y',0,0,0,0
clearstring:	dc.b	27,'Y',0,0,'   ',0,0
	even
