	SECTION	text

toolbar
	displayDialog	#TOOLBAR,#16393,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#TOOLBARTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

; reposition at left hand screen edge

	wind_get	d0,#5
	movem.w	intout+4,d2-d4
	lea	intin+4,a1
	move.w	#0,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)
	wind_set	d0,#5

	wind_get	d0,#4
	moveq.w	#0,d0
	movem.w	intout+2,d1-d4
	bsr	positionObject
	objc_draw	#0,#9,d1,d2,d3,d4,dialogResource(a0)

	rts

; the object that caused the return is in d0
.return

	bsr	selectObject

	cmpi.w	#PLAY,d0
	beq	playSample
	cmpi.w	#PLAYONCE,d0
	beq	playSampleOnce
	cmpi.w	#STOP,d0
	beq	stopSampleReplay

	cmpi.w	#RECORD,d0
	beq	selectRecordMethod

	cmpi.w	#FREQ,d0
	beq	setFrequency

	rts

	SECTION	bss
toolbarInfoString	ds.b	128