	SECTION	text
convertLeftToLeftRight
	lea	sampleInfoTable,a3

	cmpi.w	#2,sampleChannels(a3)
	bne	.notStereo

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	.d2dl2lr

	move.l	sampleAddress(a3),a0

	move.l	sampleDataSize(a3),d0

	cmpi.w	#16,sampleResolution(a3)
	beq	.loop16
.loop8
	move.b	(a0)+,d2
	move.b	d2,(a0)+
	subq.l	#2,d0
	bgt	.loop8
	bra	.done

.loop16
	move.w	(a0)+,d2
	move.w	d2,(a0)+
	subq.l	#4,d0
	bgt	.loop16

.done
	tst.w	sampleMode(a3)
	bne	.d2dDone

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	graf_mouse	#0,#0
.d2dDone
	rts

.notStereo

	rts
;--------------------------------------------------------------------
.d2dl2lr
	lea	sampleInfoTable,a3

	move.l	blockStart,-(sp)
	move.l	blockSize,-(sp)
	clr.l	blockStart
	move.l	sampleDataSize(a3),blockSize

	lea	.loop8,a4
	
	cmpi.w	#16,sampleResolution(a3)
	bne	.d2dL2lrSet

	lea	.loop16,a4
.d2dL2lrSet
	moveq.w	#0,d0
	jsr	generalD2DOperation

	move.l	(sp)+,blockSize
	move.l	(sp)+,blockStart

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	graf_mouse	#0,#0

	rts