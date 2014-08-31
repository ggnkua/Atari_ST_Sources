
color_reader:
	;d0:	x1
	;d1:	y1
	;d2:	x2
	;d3:	y2
	;a0:	EP structure
	
	movem.l	d0-d3,-(sp)
	
	movea.l	(a0),a1			;get screenadr
	movea.l	192(a0),a2		;adress of GetPalAdr-routine
	movea.l	12(a0),a3
	move.l	(a3),d0			;active screen
	jsr		(a2)
	;a0:	palette adress
	;a1:	screenadr
	
	movem.l	(sp)+,d0-d3
	
	;get x and y-counter and calculate lineoffset
	sub.l	d0,d2
	move.l	#320,d7
	sub.l	d2,d7
	lsl.l	d7
	subq.l	#1,d2
	sub.l	d1,d3
	subq.l	#1,d3
	;d2:	xcounter
	;d3:	ycounter
	;d7:	lineoffset
		
	;get startadress in screen
	mulu.l	#320,d1
	add.l	d0,d1
	lsl.l	d1
	adda.l	d1,a1
	
	;clear palette
	move.l	a0,-(sp)
	move.w	#128-1,d0
clear_palette:
	clr.l	(a0)+
	dbf		d0,clear_palette
	movea.l	(sp)+,a0
	
	;first value
	move.w	(a1),(a0)
	
	;palette counter
	moveq.l	#0,d6
	
readpal_yloop:
	move.l	d2,d1
readpal_xloop:

	;read pixel
	move.w	(a1)+,d0
	;d0:	16Bit pixel

	move.l	a0,a3	
	move.l	d6,d5
readpal_searchloop:
	cmp.w	(a3)+,d0
	beq		readpal_search_complete
	dbf		d5,readpal_searchloop
	move.w	d0,(a3)
	addq.l	#1,d6
	cmpi.l	#256-1,d6
	bgt		readpal_end		
readpal_search_complete:


	
	dbf		d1,readpal_xloop
	adda.l	d7,a1
	dbf		d3,readpal_yloop
	
readpal_end:
rts