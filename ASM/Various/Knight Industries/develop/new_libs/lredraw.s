	SECTION	text

generalRedrawHandler	; area x,y,w,h in d1,d2,d3,d4

	movem.l	d0-d7/a0-a6,-(sp)
	graf_mouse	#256,#0
	wind_update	#1

	add.w	d1,d3
	subq.w	#1,d3
	add.w	d2,d4
	subq.w	#1,d4

; x1,y1,x2,y2 = d1,d2,d3,d4

	wind_get	d0,#11
.loop
	movem.w	d1-d4,-(sp)
	bsr	.calculateArea
	movem.w	(sp)+,d1-d4

	wind_get	d0,#12

	move.w	intout+6,d5
	add.w	intout+8,d5
	tst.w	d5
	bne	.loop

	wind_update	#0
	graf_mouse	#257,#0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

.calculateArea

; convert intout's to vdi coords

	move.w	intout+2,d5
	add.w	intout+6,d5
	move.w	d5,intout+6
	subq.w	#1,intout+6

	move.w	intout+4,d5
	add.w	intout+8,d5
	move.w	d5,intout+8
	subq.w	#1,intout+8

; if x,y of rectangle is outside redraw area
; then check the next rectangle in the list

	cmp.w	intout+2,d3
	blt	.nextRectangle
	cmp.w	intout+4,d4
	blt	.nextRectangle

; if x2,y2 of rectangle is above the redraw area
; then check the next rectangle in the list

	cmp.w	intout+6,d1
	bgt	.nextRectangle

	cmp.w	intout+8,d2
	bgt	.nextRectangle
.x1
	cmp.w	intout+2,d1
	bgt	.y1
	move.w	intout+2,d1
.y1
	cmp.w	intout+4,d2
	bgt	.x2
	move.w	intout+4,d2
.x2
	cmp.w	intout+6,d3
	blt	.y2
	move.w	intout+6,d3
.y2
	cmp.w	intout+8,d4
	blt	.areaSet
	move.w	intout+8,d4
.areaSet
	addq.w	#1,d3
	addq.w	#1,d4
	sub.w	d1,d3
	sub.w	d2,d4
; coords in AES format
; area now calculated for the rectangle
; determine type of redraw (dialog or window)

	bsr	findDialogHandle
	move.l	dialogTableAddress,d5
	tst.l	d5
	bne	.dialogRedraw

	bsr	programRedraw
	bra	.nextRectangle

.dialogRedraw
	bsr	redrawDialog

; redraw on rectangle is complete/not needed
; so end area calculation on this rectangle
.nextRectangle
	rts

;---------------------------------------------------------------------
drawIconise
	rsrc_gaddr	#0,#ICON
	move.l	addrout,a0

	wind_get	d0,#4

	move.w	intout+2,objectX(a0)
	move.w	intout+4,objectY(a0)

	objc_draw	#0,#9,d1,d2,d3,d4,a0

	movem.l	(sp)+,d0-d7/a0-a6
	rts

;---------------------------------------------------------------------
; Draw Horizontal Colour Bar (Extended Type $9)
; X coord in d1
; W in d2
; Y in d3
; H in d4

hcbRedraw
	movem.w	d1-d4,-(sp)
	add.w	d1,d3
	subq.w	#1,d3
	add.w	d2,d4
	subq.w	#1,d4

	graf_mouse	#256,#0
	wind_update	#1

	vs_clip	wsHandle,#1,d1,d2,d3,d4
	vsf_color	wsHandle,#3
	v_bar	wsHandle,d1,d2,d3,d4
	vs_clip	wsHandle,#0,d1,d2,d3,d4

	wind_update	#0
	graf_mouse	#257,#0
	movem.w	(sp)+,d1-d4
	rts