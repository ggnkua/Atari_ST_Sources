	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	
	lea	pic+18(pc),a0
	move.l	$44e.w,a1
	
	move.w	#128-1,d0
aff_pic
	move.w	#128-1,d1
aff_ligne
	move.w	(a0)+,d2
	
	move.w	d2,d3
	move.w	d2,d4
	move.w	d2,d5
	
	lsr.w	#8,d2
	and.w	#%11111,d2
	
	lsr.w	#8,d3
	lsr.w	#5,d3
	and.w	#%111,d3
	lsl.w	#3,d4
	and.w	#%11000,d4
	or.w	d3,d4
	lsl.w	#6,d4
	or.w	d4,d2
	
	lsr.w	#2,d5
	and.w	#%11111,d5
	lsl.w	#5,d5
	lsl.w	#6,d5
	or.w	d5,d2
	
	move.w	d2,(a1)+
	dbf	d1,aff_ligne
	lea	640*2-128*2(a1),a1
	dbf	d0,aff_pic
	
	clr.l	-(sp)
	trap	#1
	
pic	incbin	baby.tga
	