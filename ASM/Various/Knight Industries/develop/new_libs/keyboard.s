	SECTION	text

generalKeyboardHandler

	wind_get	#0,#10
	move.w	intout+2,d0
	bsr	findDialogHandle

	move.w	keyPressed,d0
	move.l	dialogTableAddress,a0

; ctrl/alt/shift combination?

	move.w	controlKeys,d1
	andi.w	#%1111,d1
	cmpi.w	#3,d1
	bgt	keyCombo

	cmpa.l	#0,a0
	beq	.noEditableField

	move.w	dialogEdit(a0),d1
	ble	.noEditableField

	cmpi.w	#$5000,d0
	beq	.moveCursorToNextField

	cmpi.w	#$0f09,d0
	beq	.moveCursorToNextField

	cmpi.w	#$1c0d,d0
	beq	.moveCursorToNextField

	cmpi.w	#$4800,d0
	beq	.moveCursorToPreviousField

	objc_edit	d1,d0,objectTextCursor,#2,dialogResource(a0)
	move.w	intout+2,objectTextCursor

	rts

.noEditableField
	cmpi.w	#$1c0d,d0	; return
	beq	.findDefault_

	bra	programInput
;---------------------------------------------------------------
.moveCursorToNextField
	move.w	d1,d0
	ble	.noEditableField
	moveq.w	#1,d2
	bsr	findNextEditable

	move.w	keyPressed,d1
	cmpi.w	#$1c0d,d1
	beq	.checkReturn
		
.movedNext
	rts

.checkReturn
	tst.w	d0
	bpl	.movedNext
; find default object and exit dialog
.findDefault_
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	moveq.w	#0,d0
.findDefault
	move.w	objectFlags(a1),d1
	btst	#1,d1
	bne	.foundDefault
	btst	#5,d1
	bne	.noDefault
	add.l	#24,a1
	addq.w	#1,d0
	bra	.findDefault
.noDefault
	rts
.foundDefault
	move.w	#1,mouseClick
	move.w	d0,intout
	bra	processObject
;---------------------------------------------------------------
.moveCursorToPreviousField
	move.w	d1,d0
	ble	.noEditableField
	bsr	findPreviousEditable

	rts
;---------------------------------------------------------------
keyCombo

	cmpi.w	#$1011,d0	; ctrl + Q/q
	beq	quitRoutine

	bra	programKeys
;---------------------------------------------------------------