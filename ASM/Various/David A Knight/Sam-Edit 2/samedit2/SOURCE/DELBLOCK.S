	SECTION	text
deleteBlock
	lea	sampleInfoTable,a3
	tst.w	sampleLoaded(a3)
	beq	.done

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	.d2dErase

	move.l	sampleAddress(a3),a0
	add.l	blockStart,a0
	move.l	blockSize,d0

	cmpi.w	#16,sampleResolution(a3)
	beq	.check16

	cmpi.w	#2,sampleChannels(a3)
	beq	.erase16

.erase8
	clr.b	(a0)+
	subq.l	#1,d0
	bgt	.erase8
	bra	.erased

.check16
	cmpi.w	#2,sampleChannels(a3)
	beq	.erase16Stereo
.erase16
	clr.w	(a0)+
	subq.l	#2,d0
	bgt	.erase16
	bra	.erased
.erase16Stereo
	clr.l	(a0)+
	subq.l	#4,d0
	bgt	.erase16Stereo
.erased
	tst.w	sampleMode(a3)
	bne	.done

	graf_mouse	#0,#0
	
	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
.done
	rts
;----------------------------------------------
.d2dErase
	lea	.erase8,a4
	
	cmpi.w	#16,sampleResolution(a3)
	beq	.d2dErase16
	cmpi.w	#2,sampleChannels(a3)
	bne	.d2dEraseSet
.d2dErase16
	lea	.erase16,a4
	cmpi.w	#2,sampleChannels(a3)
	bne	.d2dEraseSet
	lea	.erase16Stereo,a4
.d2dEraseSet
	moveq.w	#0,d0
	bsr	generalD2DOperation

	graf_mouse	#0,#0

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
	rts