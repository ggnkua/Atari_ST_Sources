	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.l	#6,sp
	move.l	d0,oldsp             * Set supervisor mode

	lea	pic(pc),a0
	adda.l	#34,a0
	lea	table,a1
	
	moveq.w	#2,d0			* 3 rows of chars -1.

nextrow:	
	rept	20			* 40 characters (/2 coz 2 grabbed!)
	move.b	(a0),(a1)+
	move.b	160(a0),(a1)+
	move.b	320(a0),(a1)+
	move.b	480(a0),(a1)+
	move.b	640(a0),(a1)+
	move.b	800(a0),(a1)+
	move.b	960(a0),(a1)+
	move.b	1120(a0),(a1)+		* Get first 8x8 character.
	
	move.b	1(a0),(a1)+
	move.b	160+1(a0),(a1)+
	move.b	320+1(a0),(a1)+
	move.b	480+1(a0),(a1)+
	move.b	640+1(a0),(a1)+
	move.b	800+1(a0),(a1)+
	move.b	960+1(a0),(a1)+
	move.b	1120+1(a0),(a1)+	* And the one next to it.
	addq.l	#8,a0			* Next set.
	endr
	
	adda.l	#1280,a0		* Next row...
	dbra	d0,nextrow


	move.w	#$0,-(sp)
	pea	newf(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

next:	pea	table
	move.l	#760,-(sp)		* 8 bytes per char * 96 of 'em.
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
	dc.b	'8font.dat',0
pic:	even
	incbin	font.pi1
table:	even