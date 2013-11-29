	SECTION	text
signUnsign
	graf_mouse	#2,#0

	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	.signUnsignDone

	tst.w	sampleMode(a3)
	bne	.d2dSign

	move.l	sampleAddress(a3),a0
	move.l	sampleDataSize(a3),d0

	eor.w	#1,sampleSigned(a3)

	cmpi.w	#16,sampleResolution(a3)
	beq	.sign16

.sign8
	move.b	(a0),d1
	eor.b	#$80,d1
	move.b	d1,(a0)+
	subq.l	#1,d0
	bgt	.sign8
	bra	.signUnsignDone
.sign16
	move.w	(a0),d1
	eor.w	#$4000,d1
	move.w	d1,(a0)+
	subq.l	#2,d0
	bgt	.sign16

.signUnsignDone
	tst.w	sampleMode(a3)
	bne	.signFinished

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

	graf_mouse	#0,#0

.signFinished
	rts
;--------------------------------------------------------------------
.d2dSign
	lea	sampleInfoTable,a3
	eor.w	#1,sampleSigned(a3)

	move.l	blockStart,-(sp)
	move.l	blockSize,-(sp)
	move.l	blockEnd,-(sp)
	clr.l	blockStart
	move.l	sampleDataSize(a3),blockSize
	move.l	blockSize,blockEnd

	lea	.sign8,a4
	
	cmpi.w	#16,sampleResolution(a3)
	bne	.d2dSignSet

	lea	.sign16,a4
.d2dSignSet
	moveq.w	#0,d0
	bsr	generalD2DOperation

	move.l	(sp)+,blockEnd
	move.l	(sp)+,blockSize
	move.l	(sp)+,blockStart

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

	graf_mouse	#0,#0

	rts