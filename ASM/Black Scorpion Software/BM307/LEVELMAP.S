*=======================================================*
*	Level map: updated 12/06/97			*
*=======================================================*

*-------------------------------------------------------*
adjust_map:
*-------------------------------------------------------*
*	Find map x,y bounds for scaling			*
*-------------------------------------------------------*
	move.l	Line_Array,a0		; Array of LineDefs
	move.l	Vertex_Array,a1		; Array of Points
	move.l	#32760,d4		; x map min
	move.l	#-32760,d5		; x map max
	move.l	#32760,d6		; y map min
	move.l	#-32760,d7		; y map max
	move.w	NumLines,d0		; Number of LineDefs
	subq.w	#1,d0			; -1
*-------------------------------------------------------*
*	Search Xmap min, Xmap max, Ymap min & Ymap max	*
*-------------------------------------------------------*
.for_lines:
	moveq	#0,d1			; d1=0
	moveq	#0,d2			; d2=0
	movem.w	(a0),d1-d2		; LineDef from points d1 to d2
	move.w	Vertex_y(a1,d2.l*4),d3	; y2
	ext.l	d3			; extended
	cmp.l	d3,d6			; new y map min ?
	ble.s	.test2			; if not,jump...
	move.l	d3,d6			; new y map min=y2
	bra.s	.test3			; jump...
.test2:	cmp.l	d3,d7			; new y map max ?
	bge.s	.test3			; if not,jump...
	move.l	d3,d7			; new y map max=y2
.test3:	move.w	Vertex_x(a1,d2.l*4),d3	; x2
	ext.l	d3			; extended
	cmp.l	d3,d4			; new x map min ?
	ble.s	.test4			; if not,jump...
	move.l	d3,d4			; new x map min=x2
	bra.s	.test5			; jump...
.test4:	cmp.l	d3,d5			; new x map max ?
	bge.s	.test5			; if not,jump...
	move.l	d3,d5			; new x map max=x2
.test5:	move.w	Vertex_y(a1,d1.l*4),d3	; y1
	ext.l	d3			; extended
	cmp.l	d3,d6			; new y map min ?
	ble.s	.test6			; if not,jump...
	move.l	d3,d6			; new y map min=y1
	bra.s	.test7			; jump...
.test6:	cmp.l	d3,d7			; new y map max ?
	bge.s	.test7			; if not,jump...
	move.l	d3,d7			; new y map max=y1
.test7:	move.w	Vertex_x(a1,d1.l*4),d3	; x1
	ext.l	d3			; extended
	cmp.l	d3,d4			; new x map min ?
	ble.s	.test8			; if not,jump...
	move.l	d3,d4			; new x map min=x1
	bra.s	.next			; jump...
.test8:	cmp.l	d3,d5			; new x map max ?
	bge.s	.next			; if not,jump...
	move.l	d3,d5			; new x map max=x1
.next:	lea	Line_len(a0),a0		; Next line
	dbf	d0,.for_lines		; Scan all lines

*-------------------------------------------------------*
*	Calculate Dx = Xmap max - Xmap min		*
*	          Dy = Ymap max - Ymap min		*
*-------------------------------------------------------*
	sub.l	d4,d5			; Dx
	sub.l	d6,d7			; Dy
*-------------------------------------------------------*
*	Calculate Min( width / Dx ; height / Dy )	*
*-------------------------------------------------------*
	move.w	width,d0		; Width of window
	swap	d0			; *$10000
	clr.w	d0			; Float part=0
	divu.l	d5,d0			; /width of window
	tst.b halfrows
	beq.b OKOK
	add.l d0,d0
OKOK
	move.l	d0,X_map_Corr		; X map correction
	move.w	height,d1		; Height of window
	swap	d1			; *$10000
	clr.w	d1			; Float part=0
	divu.l	d7,d1			; /height of window
	move.l	d1,Y_map_Corr		; Y map correction
	move.l	d4,xmapmin		; save xmap min
	move.l	d6,ymapmin		; save ymap min
	rts
	
*-------------------------------------------------------*
*	This function displays the level's map when	*
*	the player press the TAB key.			*
*-------------------------------------------------------*
	txtlong
*-------------------------------------------------------*
display_map:
*-------------------------------------------------------*
	tst.b	map_enabled		; Have to draw map ?
	bne.s	.go			; If not,jump...
	rts				; Return
*-------------------------------------------------------*
*	Main map display routine			*
*-------------------------------------------------------*
.go:
	move.l	xmapmin,a2		; x map min
	move.l	ymapmin,a3		; y map min
	move.l	Vertex_Array,a1		; Array of points
	move.w	NumLines,d0		; Number of LineDefs
	subq.w	#1,d0			; -1
	move.l	Line_Array,a0		; Array of LineDefs
.for_lines2:
	movem.w	(a0),d1-d3		; from, to, attributes				
	btst	#7,d3			; wall mustn't be on map ?
	bne	.next_line		; if yes,jump...
	move.w	d3,d4			; attributes
	and.w	#$100,d4		; tests if wall has been seen
	beq.b	.not_seen_yet		; if not,jump...
	bra.b	.show_wall		; display line
.not_seen_yet
	tst.b	all_map_on		; all-map activated ?
	beq	.next_line		; if not,jump...
	move.w	#$8410,d5		; wall color is gray
	bra.b	.display_level		; draw line
.show_wall:
	move.w	#$f800,d5		; wall color is red			
	cmpi.w #$ffff,12(a0)		; one-sided wall ?
	beq.b .display_level		; if yes,jump...
	btst #5,d3			; secret wall ?
	bne.b .display_level		; if yes,jump...
	move.w 10(a0),d6		; number of the right SideDef
	mulu.w #Side_len,d6		; *SideDef length
	move.w 12(a0),d7		; number of the left Sidedef
	mulu.w #Side_len,d7		; *SideDef length
	movea.l Side_Array,a4		; Array of SideDefs
	move.w 28(a4,d6),d6		; number of the right faced Sector
	mulu.w #Sector_len,d6		; *Sector length
	move.w 28(a4,d7),d7		; number of the left faced Sector
	mulu.w #Sector_len,d7		; *Sector length
	movea.l Sector_Array,a4		; Array of Sectors
	move.w (a4,d6),d3		; Floor height of right sector
	move.w (a4,d7),d4		; Floor height of left sector
	move.w 2(a4,d6),d6		; Ceiling height of right sector
	move.w 2(a4,d7),d7		; Ceiling height of left sector
	move.w	#$8b47,d5		; wall color is brown
	cmp.w d3,d4			; Same floor ?
	bne.b .display_level		; If not,jump...
	cmp.w d6,d7			; Same ceiling ?
	beq .next_line			; If yes,line not displayed...
	move.w #$ffc0,d5		; wall color is yellow
.display_level:
	move.w	Vertex_y(a1,d2.w*4),d6	; y2
	ext.l	d6			; extended
	sub.l	a3,d6			; -y map min
	mulu.l	Y_map_Corr,d6		; corrected
	swap	d6			; takes high-word
	move.w	height,d4		; height of window
	subq.w	#1,d4			; -1
	sub.w	d6,d4			; corrected value-height of window
	move.w	Vertex_x(a1,d2.w*4),d3	; x2
	ext.l	d3			; extended
	sub.l	a2,d3			; -x map min
	mulu.l	X_map_Corr,d3		; corrected
	swap	d3			; takes high-word
	move.w	Vertex_y(a1,d1.w*4),d6	; y1
	ext.l	d6			; extended
	sub.l	a3,d6			; -y map min
	mulu.l	Y_map_Corr,d6		; corrected
	swap	d6			; takes high-word
	move.w	height,d2		; height of window
	subq.w	#1,d2			; -1
	sub.w	d6,d2			; corrected value-height of window
	move.w	Vertex_x(a1,d1.w*4),d1	; x1
	ext.l	d1			; extended
	sub.l	a2,d1			; -x map min
	mulu.l	X_map_Corr,d1		; corrected
	swap	d1			; takes high-word
	bsr	display_line		; Display line
.next_line:
	lea	14(a0),a0		; next line
	dbf	d0,.for_lines2		; Scan all lines
	bsr	Display_Player_Position	; Display player's 'line'
	rts				; Return

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
	beq.s		.end_v
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

.for_v:	move.w		a2,(a0)
	add.l		d5,a0
.svl:	dbf		d6,.for_v
.end_v:	movem.l		(sp)+,d0-d7/a0-a2
	rts

*-------------------------------------------------------*
*	Clip line [d1.w,d2.w -> d3.w,d4.w]		*
*-------------------------------------------------------*
clip_line:
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
	;bpl		.error
	move.w		d4,d6
	;bmi		.error
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
	;bpl		.error
	move.w		d3,d5
	;bmi		.error
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
	rts
	
*-------------------------------------------------------*
*	Display player position on the map		*
*-------------------------------------------------------*
Display_Player_Position:
	move.l	px,d3
	move.l	a2,d6			; -x map min
	swap	d6
	clr.w	d6
	sub.l	d6,d3
	mulu.l	X_map_Corr,d6:d3	; corrected
	move.w	d6,d3
	swap	d3
	move.l	py,d4
	move.l	a3,d6			; -y map min
	swap	d6
	clr.w	d6
	sub.l	d6,d4
	mulu.l	Y_map_Corr,d6:d4	; corrected
	move.w	d6,d4
	swap	d4
	move.l	cospangle,d5		; x player vector view
	move.l	d3,d1
	add.l	d5,d1
	sub.l	d5,d3
	move.l	sinpangle,d5		; y player vector view
	move.l	d4,d2
	sub.l	d5,d2
	add.l	d5,d4
	swap	d1
	swap	d2
	swap	d3
	swap	d4
	move.w	height,d6		; height of window
	subq.w	#1,d6			; -1
	neg.w	d2
	neg.w	d4
	add.w	d6,d2
	add.w	d6,d4
	move.w	#$ffff,d5		; display in white
	;bsr	clip_line
	bsr	display_line		; Display line
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

xmapmin:		ds.l	1
ymapmin:		ds.l	1
X_map_Corr:		ds.l	1
Y_map_Corr:		ds.l	1
map_enabled:		ds.b	1
all_map_on:		ds.b	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*

		
