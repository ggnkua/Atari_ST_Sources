***************
*
* Dialog routines
*

	SECTION	bss

	rsreset
dialogHandle	rs.w	1
dialogResource	rs.l	1
dialogIndex	rs.w	1
dialogGadgets	rs.w	1
dialogReturn	rs.l	1
dialogEdit	rs.w	1
dialogIconiseState	rs.w	1
dialogExtraRedraw	rs.l	1
dialogSize	rs.w	0

dialogTableAddress	ds.b	4
dialogTable	ds.b	dialogSize*50

	include	d:\develop\new_libs\objects.s

	SECTION	text
;------------------------------------------------------
findDialogSpace
	movem.l	d0-d7/a0-a6,-(sp)
	lea	dialogTable,a0
	moveq.w	#49,d0
.loop
	tst.w	dialogHandle(a0)
	beq	.found
	add.l	#dialogSize,a0
	dbra	d0,.loop
** Error **
	bra	quitRoutine
.found
	move.l	a0,dialogTableAddress
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------
createDialogWindow
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a1
	rsrc_gaddr	#0,d0
	move.l	addrout,a2
	bsr	checkForDialog
	move.l	dialogTableAddress,d2
	tst.l	d2
	bne	.done

	move.l	a1,dialogTableAddress
	move.l	a2,dialogResource(a1)
	move.w	d0,dialogIndex(a1)
	move.w	d1,dialogGadgets(a1)
	move.l	a0,dialogReturn(a1)
	clr.w	dialogEdit(a1)
	clr.w	dialogIconiseState(a1)
	clr.l	dialogExtraRedraw(a1)
	clr.w	objectTextCursor


; centre dialog

	form_center	a2
	move.w	intout+2,d2
	move.w	intout+4,d3
	move.w	intout+6,d4
	move.w	intout+8,d5

; calc window size

	wind_calc	#0,d1,d2,d3,d4,d5
	move.w	intout+2,d2
	move.w	intout+4,d3
	move.w	intout+6,d4
	move.w	intout+8,d5

; create window

	wind_create	d1,d2,d3,d4,d5
	move.w	intout,d1
	move.w	d1,dialogHandle(a1)

; open window

	wind_open	d1,d2,d3,d4,d5

.done
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------
findDialogHandle	; handle in d0

	movem.l	d0-d7/a0-a6,-(sp)
	lea	dialogTable,a0
	move.l	#dialogSize,d1
	moveq.w	#49,d2
.loop
	cmp.w	dialogHandle(a0),d0
	beq	.found
	add.l	d1,a0
	dbra	d2,.loop
** error **
	movea.l	#0,a0
.found
	move.l	a0,dialogTableAddress
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------
checkForDialog	; resource address in a2

	movem.l	d0-d7/a0-a6,-(sp)
	lea	dialogTable,a1
	move.l	#dialogSize,d1
	moveq.w	#49,d2
.loop
	tst.w	dialogHandle(a1)
	ble	.next
	cmp.l	dialogResource(a1),a2
	beq	.found
.next
	add.l	d1,a1
	dbra	d2,.loop
** error **
	movea.l	#0,a1
.found
	move.l	a1,dialogTableAddress
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------
redrawDialog
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	dialogTableAddress,a0

	tst.w	dialogIconiseState(a0)
	bne	drawIconise

	objc_draw	#0,#9,d1,d2,d3,d4,dialogResource(a0)

	tst.l	dialogExtraRedraw(a0)
	beq	.done
; if this point is reached then
; dialog needs extra redraw beyond what the AES provides

	move.l	dialogExtraRedraw(a0),a0
	pea	.done
	jmp	(a0)
.done
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------
closeAllDialogs

	lea	dialogTable,a0
	moveq.w	#49,d0
.loop
	tst.w	dialogHandle(a0)
	beq	.found
.next	
	add.l	#dialogSize,a0
	dbra	d0,.loop
	rts
.found
	wind_close	dialogHandle(a0)
	wind_delete	dialogHandle(a0)
	bra	.next
;------------------------------------------------------