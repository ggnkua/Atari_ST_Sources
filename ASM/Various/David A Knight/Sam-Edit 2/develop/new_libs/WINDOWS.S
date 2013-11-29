	SECTION	text
;----------------------------------------------------------
moveWindowHandler

	movem.w	6(a0),d0-d4

	move.w	d1,intin+4
	move.w	d2,intin+6
	move.w	d3,intin+8
	move.w	d4,intin+10
	wind_set	d0,#5

	bsr	findDialogHandle
	tst.l	dialogTableAddress
	beq	programMoveWindow
; move dialog
	move.l	dialogTableAddress,a0
	wind_get	d0,#4
	move.w	intout+2,d1
	move.w	intout+4,d2

	tst.w	dialogIconiseState(a0)
	bne	.iconised

	move.l	dialogTableAddress,a0
	moveq.w	#0,d0
	bsr	positionObject
.iconised
	rts
;----------------------------------------------------------
closeWindowHandler

	move.w	6(a0),d0
	bsr	findDialogHandle

	tst.l	dialogTableAddress
	beq	programCloseWindow
; close dialog
	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d1
	clr.w	dialogHandle(a0)
	wind_close	d1
	wind_delete	d1

*	moveq.w	#-1,d0	; return cancel dialog value
*
*	move.l	dialogTableAddress,a0
*	move.l	dialogReturn(a0),a0
*	jmp	(a0)

	rts

;----------------------------------------------------------
topWindowHandler

	move.w	6(a0),d0
	bsr	findDialogHandle

	wind_set	d0,#10
	rts
;----------------------------------------------------------
iconiseHandler

	movem.w	6(a0),d0-d4
doIconise
	bsr	findDialogHandle

	move.w	d1,intin+4
	move.w	d2,intin+6
	move.w	d3,intin+8
	move.w	d4,intin+10
	wind_set	d0,#wf_iconify

	tst.l	dialogTableAddress
	beq	programIconiseWindow
; set dialog to iconised
	move.l	dialogTableAddress,a0
	move.w	#1,dialogIconiseState(a0)
	rts
;----------------------------------------------------------
uniconiseHandler

	movem.w	6(a0),d0-d4
	bsr	findDialogHandle

	move.w	d1,intin+4
	move.w	d2,intin+6
	move.w	d3,intin+8
	move.w	d4,intin+10
	wind_set	d0,#wf_uniconify

	tst.l	dialogTableAddress
	beq	programIconiseWindow
; set dialog to iconised
	move.l	dialogTableAddress,a0
	clr.w	dialogIconiseState(a0)
	rts
;----------------------------------------------------------
redrawWindowHandler

	movem.w	6(a0),d0-d4
	bsr	findDialogHandle

	bsr	generalRedrawHandler
	rts
;----------------------------------------------------------
iconifyTop
	wind_get	#0,#10
	movem.w	intout+2,d0-d1
	cmp.w	apId,d1	; window belong to this program?
	bne	.done
	wind_get	d0,#26
	tst.w	intout+2
	bne	.done	; already iconified
	move.w	#-1,d1
	move.w	#-1,d2
	movem.w	intout+4,d3-d4
	bra	doIconise
.done
	rts
;----------------------------------------------------------
	include	d:\develop\new_libs\lredraw.s