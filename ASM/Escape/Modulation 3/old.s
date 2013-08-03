	movem.l	d0-d1,-(sp)
	mulu.l	#320,d1
	add.l	d1,d0
	lsl.l	d0
	adda.l	d0,a1
	movem.l	(sp)+,d0-d1
	;first pixeladr. on screen

	move.w	#320-64,d6
	sub.w	d0,d6

	move.w	#240,d5
	sub.w	d1,d5
	
	addq.l	#4,a0		;id "TRUP"
	move.w	(a0)+,d0	;get width
	move.w	(a0)+,d1	;get height of trp-image
	
	moveq	#0,d7
	sub.w	d0,d6		;hor. clipping
	bge		dtrp_no_xclip
	add.w	d6,d0		;reduce width
	move.w	d6,d7
	neg		d7
	lsl		d7
dtrp_no_xclip:
	
	sub.w	d1,d5		;vert.clipping
	bge		dtrp_no_yclip
	add.w	d5,d1		;reduce height
dtrp_no_yclip:
	
	move.w	#320,d3
	sub.w	d0,d3
	lsl.w	d3
	;d3:	scr-lineoffset
	
	subq.w	#1,d0
	subq.w	#1,d1
dtrp_yloop:

	move.w	d0,d2
dtrp_xloop:

	move.w	(a0)+,(a1)+

	dbf		d2,dtrp_xloop
	
	adda.w	d7,a0
	adda.w	d3,a1

	dbf		d1,dtrp_yloop
	


*****************************
*infocontents

	;left right edge in screen ?
	cmpi.l	#320-64,d0
	blt		ditrp_x_in_scr
	rts
ditrp_x_in_scr:
	cmpi.l	#240,d1
	blt		ditrp_y_in_scr
	rts
ditrp_y_in_scr:

	movem.l	d0-a6,-(sp)
	;d0:	x
	;d1:	y
	;d2:	ypos
	;a0:	trp-daten
	;a1:	scradr

	movem.l	d0-d1,-(sp)
	mulu.l	#320,d1
	add.l	d1,d0
	lsl.l	d0
	adda.l	d0,a1
	movem.l	(sp)+,d0-d1
	;first pixeladr. on screen

	move.w	#320-64,d6
	sub.w	d0,d6

	move.w	#240,d5
	sub.w	d1,d5
	
	addq.l	#4,a0		;id "TRUP"
	move.w	(a0)+,d0	;get width
	move.w	(a0)+,d1	;get height of trp-image
	move.w	#37,d1
	mulu.w	d0,d2		;add yoffset to gfxdata
	lsl.w	d2
	adda.w	d2,a0

	moveq	#0,d7
	sub.w	d0,d6		;hor. clipping
	bge		ditrp_no_xclip
	add.w	d6,d0		;reduce width
	move.w	d6,d7
	neg		d7
	lsl		d7
ditrp_no_xclip:
	
	sub.w	d1,d5		;vert.clipping
	bge		ditrp_no_yclip
	add.w	d5,d1		;reduce height
ditrp_no_yclip:
	
	move.w	#320,d3
	sub.w	d0,d3
	lsl.w	d3
	;d3:	scr-lineoffset
	
	lea		plasmapic,a2
	adda.l	#640*410+220,a2
	
	subq.w	#1,d0
	subq.w	#1,d1
ditrp_yloop:

	move.w	d0,d2
ditrp_xloop:

	move.w	(a0)+,d5
	beq.b	ditrp_foreground
	move.w	d5,(a1)+
	addq	#2,a2
	dbf		d2,ditrp_xloop
	bra.b	ditrp_xloop_end	

ditrp_foreground:
	move.w	(a2)+,(a1)+
	dbf		d2,ditrp_xloop
ditrp_xloop_end:
	
	adda.w	d7,a0
	adda.w	d3,a1
	adda.w	d3,a2

	dbf		d1,ditrp_yloop
	
	movem.l	(sp)+,d0-a6
