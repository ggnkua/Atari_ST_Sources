	SECTION text
falconRecord
	displayDialog	#FALCRECORD,#16395,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#RECORDMETHTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	rts

.return
	cmpi.w	#FTHRUREC,d0
	beq	toggleFalcSndThru

	cmpi.w	#FRECORDREC,d0
	beq	recordFalcon
	rts
;----------------------------------------------------------------
toggleFalcSndThru
	super	#0
	eor.b	#3,$ffff8938
	move.b	#3,$ffff8937
	super	d0
	rts
;----------------------------------------------------------------
recordFalcon
	displayDialog	#RECORDING,#0,#.return
.return
	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	wind_get	#4,d0
	movem.w	intout+2,d1-d4
	objc_draw	#0,#2,d1,d2,d3,d4,dialogResource(a0)

	super	#0
	move.l	d0,-(sp)

; set sound to microphone
	move.b	$ffff8938,-(sp)
	ori.b	#3,$ffff8938
	eor.b	#3,$ffff8938
	move.b	#3,$ffff8937

; set record registers
	ori.b	#128,$ffff8901

; set to 1 track
	ori.b	#3,$ffff8936
	eor.b	#3,$ffff8936

; set address registers
	lea	sampleInfoTable,a3
	move.l	sampleAddress(a3),d4
	move.l	d4,d5
	add.l	sampleDataSize(a3),d5

	move.b	d4,$ffff8907.w	; low
	move.b	d4,$ffff890d.w
	lsr.w	#8,d4
	move.b	d4,$ffff8905.w	; mid
	move.b	d4,$ffff890b
	swap	d4
	move.b	d4,$ffff8903.w	; high
	move.b	d4,$ffff8909.w

	sub.l	#4,d5
	move.b	d5,$ffff8913.w	; low
	lsr.w	#8,d5
	move.b	d5,$ffff8911.w	; mid
	swap	d5
	move.b	d5,$ffff890f.w	; high

	ori.w	#15,$ffff8932

; set Timer A
	Xbtimer	#endRecordingRoutine,#1,#8,#0

; go record
	ori.b	#32,$ffff8901
	eor.b	#32,$ffff8901
	ori.b	#16,$ffff8901
.recLoop
	btst	#4,$ffff8901
	bne	.recLoop

.recordFinished
	move.b	(sp)+,$ffff8938
	bclr	#7,$ffff8901
; reset Timer A
	Xbtimer	#endRecordingRoutine,#0,#0,#0
	bclr	#5,$fffffa0f.w
	move.l	(sp)+,d0
	super	d0

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	wind_close	d0
	wind_delete	d0

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	#4,d0
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

endRecordRoutine
	rts

endRecordingRoutine

	bclr	#4,$ffff8901
	rte