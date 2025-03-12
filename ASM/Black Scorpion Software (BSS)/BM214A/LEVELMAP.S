*=======================================================*
*	LevelMap: latest update 25/03/96		*
*=======================================================*
*	Display the 2D map.				*
*=======================================================*

*-------------------------------------------------------*
*	Find map x,y bounds for scaling			*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
adjust_map:
*-------------------------------------------------------*
	move.l	Line_Array,a0
	move.l	Vertex_Array,a1
	move.l	#32760,d4			; x map min
	move.l	#-32760,d5			; x map max
	move.l	#32760,d6			; y map min
	move.l	#-32760,d7			; y map max
	move.w	NumLines,d0	
	subq.w	#1,d0
*-------------------------------------------------------*
*	Search Xmap min, Xmap max, Ymap min & Ymap max	*
*-------------------------------------------------------*
.for_lines:
	moveq	#0,d1
	moveq	#0,d2
	movem.w	(a0),d1-d2			; linedef from d1 to d2
	move.w	Vertex_y(a1,d2.l*4),d3		; y2
	ext.l	d3
	cmp.l	d3,d6
	ble.s	.test2
	move.l	d3,d6
	bra.s	.test3
.test2:	cmp.l	d3,d7
	bge.s	.test3
	move.l	d3,d7
.test3:	move.w	Vertex_x(a1,d2.l*4),d3		; x2
	ext.l	d3
	cmp.l	d3,d4
	ble.s	.test4
	move.l	d3,d4
	bra.s	.test5
.test4:	cmp.l	d3,d5
	bge.s	.test5
	move.l	d3,d5
.test5:	move.w	Vertex_y(a1,d1.l*4),d3		; y1
	ext.l	d3
	cmp.l	d3,d6
	ble.s	.test6
	move.l	d3,d6
	bra.s	.test7
.test6:	cmp.l	d3,d7
	bge.s	.test7
	move.l	d3,d7
.test7:	move.w	Vertex_x(a1,d1.l*4),d3		; x1
	ext.l	d3
	cmp.l	d3,d4
	ble.s	.test8
	move.l	d3,d4
	bra.s	.next
.test8:	cmp.l	d3,d5
	bge.s	.next
	move.l	d3,d5
.next:	lea	Line_len(a0),a0			; Next line
	dbf	d0,.for_lines

*-------------------------------------------------------*
*	Calculate Dx = Xmap max - Xmap min		*
*	          Dy = Ymap max - Ymap min		*
*-------------------------------------------------------*
	sub.l	d4,d5
	sub.l	d6,d7
*-------------------------------------------------------*
*	Calculate Min( width / Dx ; height / Dy )	*
*-------------------------------------------------------*
	move.w	width,d0
	swap	d0
	clr.w	d0
	divu.l	d5,d0
	move.w	height,d1
	swap	d1
	clr.w	d1
	divu.l	d7,d1
	cmp.l	d1,d0
	ble.s	.small
	move.l	d1,d0
.small:	move.l	d4,xmapmin			; save xmap min
	move.l	d6,ymapmin			; save ymap min
	move.l	d0,X_Y_map_Corr			; save smaller_one
	rts
	
*-------------------------------------------------------*
*	This function displays the level's map when	*
*	the player press the TAB key.			*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
display_map:
*-------------------------------------------------------*
	tst.b	map_enabled
	bne.s	.go
	rts
*-------------------------------------------------------*
*	Main map display routine			*
*-------------------------------------------------------*
.go:	move.l	xmapmin,a2
	move.l	ymapmin,a3
	move.l	Vertex_Array,a1
	move.w	NumLines,d0	
	subq.w	#1,d0
	move.l	Line_Array,a0
.for_lines2:
	movem.w	(a0),d1-d3			; from, to, attributes				
	move.w	#$ffe0,d5			; wall color is yellow

	btst	#7,d3				; test is wall mustn't be
	bne.s	.next_line			;   on map

	move.w	d3,d4				; test if wall is already
	and.w	#$100,d4			;   on map, also if never
	beq.s	.next_line			;   seen before

.show_wall:
	btst	#0,d3
	beq.s	.not_external_wall
	move.w	#$f800,d5			; wall color is red			
.not_external_wall:
.display_level:
	move.w	Vertex_y(a1,d2.w*4),d6		; y2
	ext.l	d6
	sub.l	a3,d6
	mulu.l	X_Y_map_Corr,d6
	swap	d6
	move.w	height,d4
	subq.w	#1,d4
	sub.w	d6,d4

	move.w	Vertex_x(a1,d2.w*4),d3		; x2
	ext.l	d3
	sub.l	a2,d3
	mulu.l	X_Y_map_Corr,d3
	swap	d3

	move.w	Vertex_y(a1,d1.w*4),d6		; y1
	ext.l	d6
	sub.l	a3,d6
	mulu.l	X_Y_map_Corr,d6
	swap	d6
	move.w	height,d2
	subq.w	#1,d2
	sub.w	d6,d2

	move.w	Vertex_x(a1,d1.w*4),d1		; x1
	ext.l	d1
	sub.l	a2,d1
	mulu.l	X_Y_map_Corr,d1
	swap	d1
	bsr	display_line
.next_line:
	lea	14(a0),a0			; next line
	dbf	d0,.for_lines2

	bsr	Display_Player_Position
	rts


*-------------------------------------------------------*
*	Draw a colored line between 2 points		*
*-------------------------------------------------------*
*		d1 : X1		d2 : Y1			*
*		d3 : X2		d4 : Y2			*
*		d5 : color of the line			*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
display_line:
*-------------------------------------------------------*
	movem.l		d0-d7/a0-a2,-(sp)
*-------------------------------------------------------*
	move.w		d5,a2

	rept		0
	
*-------------------------------------------------------*
*	Clip line [d1.w,d2.w -> d3.w,d4.w]		*
*-------------------------------------------------------*
.clip_line:
*-------------------------------------------------------*
	move.w		height,d7
	cmp.w		d2,d4
	bpl.s		.sort_y1y2
	exg		d1,d3
	exg		d2,d4
*-------------------------------------------------------*
.sort_y1y2:
*-------------------------------------------------------*
	cmp.w		d7,d2
	bpl		.error
	move.w		d4,d6
	bmi		.error
	sub.w		d2,d6
	move.w		d3,d5
	sub.w		d1,d5
	bne.s		.no_vertical
	tst.w		d2
	bpl.s		.y1in
	moveq		#0,d2
.y1in:	cmp.w		d7,d4
	bmi.s		.vertical_done
	move.w		d7,d4
	bra.s		.vertical_done
*-------------------------------------------------------*
.no_vertical:
*-------------------------------------------------------*
	tst.w		d2
	bpl.s		.y1_inside
	muls.w		d5,d2		; dx*(y1-tc)
	divs.w		d6,d2		; dx*(y1-tc) / (y2-y1)
	sub.w		d2,d1		; x1' = x1 - (dx*(y1-tc)) / (y2-y1)
	moveq		#0,d2		; y1' = ty
*-------------------------------------------------------*
.y1_inside:
*-------------------------------------------------------*
	sub.w		d4,d7
	bpl.s		.y2_inside
	muls.w		d7,d5		; dx*(bc-y2)
	divs.w		d6,d5		; dx*(bc-y2) / (y2-y1)
	add.w		d5,d3		; x2' = x2 + (dx*(bc-y2)) / (y2-y1)
	add.w		d7,d4		; y2' = by
*-------------------------------------------------------*
.y2_inside:
*-------------------------------------------------------*
.vertical_done:
*-------------------------------------------------------*
	move.w		width,d7
	cmp.w		d1,d3
	bpl.s		.sort_x1x2
	exg		d1,d3
	exg		d2,d4
*-------------------------------------------------------*
.sort_x1x2:
*-------------------------------------------------------*
	cmp.w		d7,d1
	bpl		.error
	move.w		d3,d5
	bmi		.error
	sub.w		d1,d5
	move.w		d4,d6
	sub.w		d2,d6
	bne.s		.no_horizontal
	tst.w		d1
	bpl.s		.x1in
	moveq		#0,d1
.x1in:	cmp.w		d7,d3
	bmi.s		.horizontal_done
	move.w		d7,d3
	bra.s		.horizontal_done
*-------------------------------------------------------*
.no_horizontal:
*-------------------------------------------------------*
	tst.w		d1
	bpl.s		.x1_inside
	muls.w		d6,d1		; dy*(x1-lc)
	divs.w		d5,d1		; dy*(x1-lc) / (x2-x1)
	sub.w		d1,d2		; y1' = y1 - (dy*(x1-lc)) / (x2-x1)
	moveq		#0,d1		; x1' = lc
*-------------------------------------------------------*
.x1_inside:
*-------------------------------------------------------*
	sub.w		d3,d7
	bpl.s		.x2_inside
	muls.w		d7,d6		; dy*(rc-x2)
	divs.w		d5,d6		; dy*(rc-x2) / (x2-x1)
	add.w		d6,d4		; y2' = y2 + (dx*(bc-y2)) / (y2-y1)
	add.w		d7,d3		; x2' = rc
*-------------------------------------------------------*
.x2_inside:
*-------------------------------------------------------*
.horizontal_done:
*-------------------------------------------------------*

	endr
	
	move.l		screen,a0
	move.w		scrwidth,d0			; 2 * width screen
	add.w		d0,d0
	move.w		d4,d6				; d6 = Y1-Y2 = dY
	sub.w		d2,d6
	beq		.h_line
	move.w		d3,d5
	sub.w		d1,d5				; d5 = X2-X1 = dX
	beq		.v_line	
	bmi.s		.line1				; dX < 0 ?
	move.w		d2,d7
	add.w		d1,d1				; X2 > X1
	move.w		d1,a1
	bra.w		.n_line
.line1:	neg.w		d5				; X2 < X1
	neg.w		d6
	move.w		d4,d7
	add.w		d3,d3
	move.w		d3,a1 	
.n_line:
	tst.w		d6
	bpl.s		.n_line0
	neg.w		d6
	neg.w		d0
.n_line0:
	move.w		scrwidth,d1
	add.w		d1,d1
	cmp.w		d6,d5
	bmi.s		.n_line2
.n_line1:					; dX > dY
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	mulu.w		d1,d7
	add.l		a1,d7
	lea		(a0,d7.l),a0			; logscreen adress
	move.w		a2,d2				; pixel color

.lin1_lp2
	tst.w		d6
	bmi.s		.lin1_no_y
	add.w		d4,d6
	move.w		d2,(a0)+			; display pixel
	add.w		d0,a0
	dbf		d5,.lin1_lp2
	movem.l		(sp)+,d0-d7/a0-a2
	rts
.lin1_no_y	
	add.w		d3,d6		
	move.w		d2,(a0)+			; display pixel
	dbf		d5,.lin1_lp2
	movem.l		(sp)+,d0-d7/a0-a2
	rts
	
.n_line2:					; dX < dY
	exg		d6,d5
	add.w		d6,d6
	move.w		d6,d3
	sub.w		d5,d6
	move.w		d6,d4
	sub.w		d5,d4

	mulu.w		d1,d7
	add.l		a1,d7
	lea		(a0,d7.l),a0
	move.w		a2,d2				; pixel color

.lin2_lp:
	tst.w		d6
	bmi.s		.lin2_no_x
 	add.w		d4,d6
	move.w		d2,(a0)+			; display pixel
	add.w		d0,a0 
	dbf		d5,.lin2_lp
	movem.l		(sp)+,d0-d7/a0-a2
	rts
.lin2_no_x:
	add.w		d3,d6
	move.w		d2,(a0)				; display pixel
	add.w		d0,a0 
	dbf		d5,.lin2_lp

.error:	movem.l		(sp)+,d0-d7/a0-a2
	rts
	
.h_line:					; Y1 = Y2
	cmp.w		d1,d3
	bge.s		.hline1	
	exg		d1,d3
.hline1:
	sub.w		d1,d3
	mulu.w		scrwidth,d2
	lea		(a0,d2.l*2),a0			; screen adress
	add.w		d1,d1
	add.w		d1,a0
.for_h:	move.w		a2,(a0)+
.shl:	dbf		d3,.for_h

.end_h:	movem.l		(sp)+,d0-d7/a0-a2
	rts
	
.v_line:					; X1 = X2
	tst.w		d6
	bgt.s		.lvert2
	exg		d2,d4	
	neg.w		d6
.lvert2:
	moveq		#0,d5
	move.w		scrwidth,d5
	add.l		d5,d5
	mulu.w		d5,d2
	add.l		d2,a0
	add.w		d1,d1
	add.w		d1,a0
	bra.s		.svl
.for_v:	move.w		a2,(a0)
	add.l		d5,a0
.svl:	dbf		d6,.for_v
.end_v:	movem.l		(sp)+,d0-d7/a0-a2
	rts

*-------------------------------------------------------*
*	Display player position on the map		*
*-------------------------------------------------------*
Display_Player_Position:
	move.w	px,d3				; Player's x position
	ext.l	d3
	sub.l	a2,d3
	mulu.l	X_Y_map_Corr,d3
	swap	d3
	move.w	py,d6				; Player's y position
	ext.l	d6
	sub.l	a3,d6
	mulu.l	X_Y_map_Corr,d6
	swap	d6
	move.w	height,d4
	subq.w	#1,d4
	sub.w	d6,d4
	move.l	sinpangle,d2			; y player vector view
	move.w	#14,d6
	asr.l	d6,d2	
	add.w	d4,d2
	move.l	cospangle,d1			; x player vector view
	asr.l	d6,d1	
	add.w	d3,d1
	move.w	#$ffff,d5			; display in white
	bsr	display_line
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

xmapmin:		ds.l	1
ymapmin:		ds.l	1
X_Y_map_Corr:		ds.l	1

map_enabled:		ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*

		
