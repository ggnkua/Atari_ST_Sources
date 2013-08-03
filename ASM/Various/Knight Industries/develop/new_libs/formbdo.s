	SECTION	text
generalClickHandler

	wind_find	mouseX,mouseY
	move.w	intout,d0
	ble	.done

	bsr	findDialogHandle

	tst.l	dialogTableAddress
	beq	programClick

	bra	.whichObject
.done
	rts
;-----------------------------------------------------------
.whichObject
	move.l	dialogTableAddress,a0
	objc_find	#0,#9,mouseX,mouseY,dialogResource(a0)

processObject
	tst.w	mouseClick
	beq	.noClick

	move.w	intout,d0
	bpl	.objectClicked

.noClick
	moveq.w	#0,d0
	beq	.touchexitObject

	rts
;-----------------------------------------------------------
.objectClicked
	cmpi.w	#2,mouseClick
	beq	programBubbleGem

; is it selectable?
	moveq.w	#1,d2
	bsr	typeObjectCheck
	tst.w	d1
	bne	.selectableObject

; is it editable?
	moveq.w	#8,d2
	bsr	typeObjectCheck
	tst.w	d1
	bne	.editableObject

.exitChecks
; is it touchexit?
	moveq.w	#64,d2
	bsr	typeObjectCheck
	tst.w	d1
	bne	.touchexitObject

; is it exit?
	moveq.w	#4,d2
	bsr	typeObjectCheck
	tst.w	d1
	bne	.exitObject

; is it a vertical slider?
	move.w	#$114,d2
	bsr	specialTypeObjectCheck
	tst.w	d1
	bne	.verticalSlider

; is it a horizontal slider?
	move.w	#$214,d2
	bsr	specialTypeObjectCheck
	tst.w	d1
	bne	.horizontalSlider

; is it a vertical scroll bar?
	move.w	#$714,d2
	bsr	specialTypeObjectCheck
	tst.w	d1
	bne	.verticalScrollBar

; is it a horizontal scroll bar?
	move.w	#$814,d2
	bsr	specialTypeObjectCheck
	tst.w	d1
	bne	.horizontalScrollBar

; is it a horizontal colour bar?
	move.w	#$914,d2
	bsr	specialTypeObjectCheck
	tst.w	d1
	bne	.horizontalColourBar


	rts
;-----------------------------------------------------------
.selectableObject

; is it a radio?
	moveq.w	#16,d2
	bsr	typeObjectCheck

	tst.w	d1
	bne	.radioObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.w	d0,d1
	mulu	#24,d1
	ext.l	d1
	add.l	d1,a1
	move.w	objectStatus(a1),d1
	move.w	d1,d2
	eor.w	#1,d1

	graf_watchbox	#0,d0,d1,d2,dialogResource(a0)

	move.w	d1,objectStatus(a1)
	tst.w	intout
	bne	.exitChecks

	move.w	d2,objectStatus(a1)
	rts
;-----------------------------------------------------------
.radioObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.w	d0,d1
	mulu	#24,d1
	ext.l	d1
	add.l	d1,a1
	move.w	objectStatus(a1),d1
	andi.w	#1,d1
	bne	.exitChecks

	bsr	selectObject

	move.w	d0,d1
	move.w	d1,d3
.radioLoop
; d1 = initial object
; d3 = current object
	move.w	objectNext(a1),d0
; d2 = object next
	move.w	d0,d2
	move.l	a0,a1
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a1
	move.w	objectTail(a1),d4
; d4 = object tail (object next)
	cmp.w	d4,d3
	bne	.headNotReached

	move.w	d2,d0
	move.l	a0,a1
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a1
	move.w	objectHead(a1),d2
.headNotReached
; is d2=d1?
	cmp.w	d1,d2
	bne	.radioNotFinished

	move.w	d1,d0
	bra	.exitChecks
.radioNotFinished
; set object to unselected
	move.l	a0,a1
	move.w	d2,d0
	mulu	#24,d0
	ext.l	d0
	add.l	d0,a1
	move.w	objectFlags(a1),d0
	andi.w	#16,d0
	beq	.notRadio
	move.w	objectStatus(a1),d0
	andi.w	#1,d0
	beq	.notRadio

	move.w	d2,d0
	move.w	d1,d4
	bsr	selectObject
	move.w	d4,d1
.notRadio
	move.w	d2,d3
	bra	.radioLoop
;-----------------------------------------------------------
.exitObject
	move.l	dialogTableAddress,a0

	bsr	selectObject

	move.w	dialogHandle(a0),d1
	clr.w	dialogHandle(a0)
	wind_close	d1
	wind_delete	d1

.touchexitObject

	move.l	dialogTableAddress,a0
	move.l	dialogReturn(a0),a0
	jmp	(a0)
.abortExit
	rts
;-----------------------------------------------------------
.editableObject

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	dialogTableAddress,a0
	move.w	dialogEdit(a0),d1
	tst.w	d1
	ble	.noCurrentEditableObject

	objc_edit	d1,#0,objectTextCursor,#3,dialogResource(a0)
.noCurrentEditableObject
	objc_edit	d0,#0,#0,#1,dialogResource(a0)
	move.w	d0,dialogEdit(a0)
	move.w	intout+2,objectTextCursor
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;-----------------------------------------------------------
.horizontalSlider

	movem.l	d0-d1/d3-d7/a0-a6,-(sp)

	bsr	selectObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.w	d0,d1
	mulu	#24,d1
	ext.l	d1
	add.l	d1,a0

	graf_mouse	#4,#0
	move.w	objectNext(a0),d2
	move.w	objectW(a0),d4
	graf_slidebox	d2,d0,#0,a1

; position at correct offset
; find width of parent

	move.w	intout,d1
	move.w	d1,-(sp)
	move.w	d2,d3
	move.l	a1,a0
	mulu	#24,d2
	ext.l	d2
	add.l	d2,a0
	move.w	objectW(a0),d2
	sub.w	d4,d2
	mulu	d2,d1
	divu	#1000,d1	

	moveq.w	#0,d2
	bsr	positionObject

	bsr	selectObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	objc_offset	d3,a0
	movem.w	intout+2,d1-d2
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#2,d1
	subq.w	#1,d2
	addq.w	#4,d3
	addq.w	#2,d4

	bsr	redrawDialog
	graf_mouse	#0,#0
	move.w	(sp)+,d2
	movem.l	(sp)+,d0-d1/d3-d7/a0-a6
	bra	.touchexitObject
;-----------------------------------------------------------
.verticalSlider

	movem.l	d0-d1/d3-d7/a0-a6,-(sp)

	bsr	selectObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.w	d0,d1
	mulu	#24,d1
	ext.l	d1
	add.l	d1,a0

	graf_mouse	#4,#0
	move.w	objectNext(a0),d2
	move.w	objectH(a0),d4
	graf_slidebox	d2,d0,#1,a1

; position at correct offset
; find height of parent

	move.w	intout,d1
	move.w	d1,-(sp)
	move.w	d2,d3
	move.l	a1,a0
	mulu	#24,d2
	ext.l	d2
	add.l	d2,a0
	move.w	objectH(a0),d2
	sub.w	d4,d2
	mulu	d1,d2
	divu	#1000,d2	

	moveq.w	#0,d1
	bsr	positionObject

	bsr	selectObject

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	objc_offset	d3,a0
	movem.w	intout+2,d1-d2
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#1,d1
	subq.w	#2,d2
	addq.w	#2,d3
	addq.w	#4,d4

	bsr	redrawDialog
	graf_mouse	#0,#0
	move.w	(sp)+,d2
	movem.l	(sp)+,d0-d1/d3-d7/a0-a6
	bra	.touchexitObject
;-----------------------------------------------------------
.verticalScrollBar
	movem.l	d0-d1/d3-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1

	move.w	d0,d1

	mulu	#24,d1
	ext.l	d1
	add.l	d1,a1	; points to scroll bar info

	move.l	a0,a2
	move.w	objectHead(a1),d2
	move.w	d2,d3
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a2	; points to slider info

	move.w	mouseY,d1

; d0 = scroll bar
; d1 = mouse y coordinate
; d2 = slider
; a1 = scroll bar resource
; a2 = slider resource

	move.w	objectH(a2),d3

	objc_offset	d0,a0
	move.w	intout+4,d4	; y position of scroll bar object
	objc_offset	d2,a0	
	move.w	intout+4,d5	; y position of slider object

	cmp.w	d1,d5
	bgt	.upVerticalScrollBar

; down vertical scroll bar
	move.w	d5,d6
	add.w	d3,d6

	move.w	d4,d7
	add.w	objectH(a1),d7
; d6 = slider y2
; d7 = scroll bar object y2
	sub.w	d6,d7

	cmp.w	d3,d7
	bgt	.downVerticalScrollBarOK
	exg	d3,d7
.downVerticalScrollBarOK
	add.w	d3,objectY(a2)

	bra	.verticalScrollBarDone

.upVerticalScrollBar
	sub.w	d3,d5
	cmp.w	d5,d4
	ble	.upVerticalScrollBarOK
	moveq.w	#0,d3
	move.w	#0,objectY(a2)
.upVerticalScrollBarOK
	sub.w	d3,objectY(a2)

.verticalScrollBarDone
	move.w	d0,d3
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	objc_offset	d3,a0
	movem.w	intout+2,d1-d2
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#4,d3
	addq.w	#4,d4
	bsr	redrawDialog

; return % value
	move.w	objectY(a2),d2
	ext.l	d2
	mulu	#1000,d2
	move.w	objectH(a1),d1
	ext.l	d1
	divu	d1,d2

	movem.l	(sp)+,d0-d1/d3-d7/a0-a6
	bra	.touchexitObject
;-----------------------------------------------------------
.horizontalScrollBar
	movem.l	d0-d1/d3-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1

	move.w	d0,d1

	mulu	#24,d1
	ext.l	d1
	add.l	d1,a1	; points to scroll bar info

	move.l	a0,a2
	move.w	objectHead(a1),d2
	move.w	d2,d3
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a2	; points to slider info

	move.w	mouseX,d1

; d0 = scroll bar
; d1 = mouse x coordinate
; d2 = slider
; a1 = scroll bar resource
; a2 = slider resource

	move.w	objectW(a2),d3

	objc_offset	d0,a0
	move.w	intout+2,d4	; x position of scroll bar object
	objc_offset	d2,a0	
	move.w	intout+2,d5	; x position of slider object

	cmp.w	d1,d5
	bgt	.leftHorizontalScrollBar

; right horizontal scroll bar

	move.w	d5,d6
	add.w	d3,d6

	move.w	d4,d7
	add.w	objectW(a1),d7
; d6 = slider x2
; d7 = scroll bar object x2
	sub.w	d6,d7

	cmp.w	d3,d7
	bgt	.rightHorizontalScrollBarOK
	exg	d3,d7
.rightHorizontalScrollBarOK
	add.w	d3,objectX(a2)

	bra	.horizontalScrollBarDone

.leftHorizontalScrollBar
	sub.w	d3,d5
	cmp.w	d5,d4
	ble	.leftHorizontalScrollBarOK
	moveq.w	#0,d3
	move.w	#0,objectX(a2)
.leftHorizontalScrollBarOK
	sub.w	d3,objectX(a2)

.horizontalScrollBarDone
	move.w	d0,d3
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	objc_offset	d3,a0
	movem.w	intout+2,d1-d2
	mulu	#24,d3
	ext.l	d3
	add.l	d3,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#4,d3
	addq.w	#4,d4
	bsr	redrawDialog

; return % value
	move.w	objectY(a2),d2
	ext.l	d2
	mulu	#1000,d2
	move.w	objectH(a1),d1
	ext.l	d1
	divu	d1,d2

	movem.l	(sp)+,d0-d1/d3-d7/a0-a6
	bra	.touchexitObject
;-----------------------------------------------------------
.horizontalColourBar
	movem.l	d0-d1/d3-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	d0,dialogResource(a0)
	movem.w	intout+2,d1-d2

	move.w	mouseX,d3
	sub.w	d1,d3
	addq.w	#1,d3

	mulu	#24,d0
	ext.l	d0
	add.l	d0,a1
	move.w	objectW(a1),d5
	move.w	objectH(a1),d4
	objc_draw	#0,#9,d1,d2,d5,d4,dialogResource(a0)

	bsr	hcbRedraw

	move.w	d3,d2
	movem.l	(sp)+,d0-d1/d3-d7/a0-a6
	bra	.touchexitObject
;-----------------------------------------------------------