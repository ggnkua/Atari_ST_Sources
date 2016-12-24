	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp             * Set supervisor mode

	lea	pic+34(pc),a0
	lea	table,a1
	
	rept	56			* Store MIX
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	move.l	32(a0),(a1)+
	move.l	36(a0),(a1)+
	move.l	40(a0),(a1)+
	move.l	44(a0),(a1)+
	move.l	48(a0),(a1)+
	move.l	52(a0),(a1)+
	lea	160(a0),a0
	endr

	rept	56			* Store U
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	move.l	32(a0),(a1)+
	move.l	36(a0),(a1)+
	lea	160(a0),a0
	endr

	rept	56			* Store LOAD
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	8(a0),(a1)+
	move.l	12(a0),(a1)+
	move.l	16(a0),(a1)+
	move.l	20(a0),(a1)+
	move.l	24(a0),(a1)+
	move.l	28(a0),(a1)+
	move.l	32(a0),(a1)+
	move.l	36(a0),(a1)+
	move.l	40(a0),(a1)+
	move.l	44(a0),(a1)+
	move.l	48(a0),(a1)+
	move.l	52(a0),(a1)+
	move.l	56(a0),(a1)+
	move.l	60(a0),(a1)+
	lea	160(a0),a0
	endr


	move.w	#$0,-(sp)
	pea	newf(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

next:	pea	table
	move.l	#(3136+2240+3584),-(sp)
	move.w	handle(pc),-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

next2:	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	
out:	move.l	oldsp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp

	clr.l	-(sp)
	trap	#1
	
oldsp:	even
	ds.l	1
handle:	even
	ds.w	1
newf:	even
	dc.b	'mixit.dat',0
pic:	even
	incbin	fighterp.pi1
table:	even