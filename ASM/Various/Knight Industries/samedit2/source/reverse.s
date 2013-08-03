reverseSample
	lea	sampleInfoTable,a3
	tst.w	sampleLoaded(a3)
	beq	.dontReverse

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	.reverseD2D

	move.l	sampleAddress(a3),a0
	add.l	blockStart,a0
	move.l	a0,a1
	move.l	blockSize,d1
	subq.l	#4,d1
	add.l	d1,a1

	cmpi.w	#16,sampleResolution(a3)
	beq	.c16

	addq.l	#2,d1
	addq.l	#2,a1
	cmpi.w	#2,sampleChannels(a3)
	beq	.reverse16
	addq.l	#1,d1
	addq.l	#1,a1
.reverse8
	move.b	(a0),d0
	move.b	(a1),(a0)+
	move.b	d0,(a1)
	subq.l	#1,a1
	subq.l	#2,d1
	bgt.s	.reverse8
	bra.s	.done

.c16
	cmpi.w	#2,sampleChannels(a3)
	beq	.reverse16s
	addq.l	#2,d1
	addq.l	#2,a1
.reverse16
	move.w	(a0),d0
	move.w	(a1),(a0)+
	move.w	d0,(a1)
	subq.l	#2,a1
	subq.l	#4,d1
	bgt.s	.reverse16
	bra	.done

.reverse16s
	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)
	subq.l	#4,a1
	subq.l	#8,d1
	bgt.s	.reverse16s

.done
	tst.w	sampleMode(a3)
	bne	.dontReverse

	graf_mouse	#0,#0
	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
.dontReverse
	rts
;--------------------------------------------------------------------
.reverseD2D

	bsr	initD2DFunction
.process
	cmp.l	d2,d3
	bge	.noSizeAlter
	move.l	d3,d2
.noSizeAlter
	sub.l	d2,d3	; find offset

	movem.l	d0-d3/a0-a2,-(sp)
	move.w	sampleHeaderSize(a3),d0
	ext.l	d0
	add.l	blockStart,d0
	add.l	d0,d3
	f_seek	#0,d4,d3	; position file pointer
	movem.l	(sp)+,d0-d3/a0-a2

	movem.l	d0-d2/a0-a2,-(sp)
	f_read	D2DBuffer,d2,d4	; read next part
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d2-d7/a2-a6,-(sp)
	callModule	#2		; process
	movem.l	(sp)+,d2-d7/a2-a6
	move.l	D2DBuffer,a0		; store address
				; of buffer in a0
	move.l	a0,a1
	move.l	d2,d1		; size to process
	subq.l	#4,d1
	add.l	d1,a1

	cmpi.w	#16,sampleResolution(a3)
	beq	.c16D2D
	addq.l	#2,d1
	addq.l	#2,a1
	cmpi.w	#2,sampleChannels(a3)
	beq	.s16D2D
	addq.l	#1,d1
	addq.l	#1,a1
	lea	.reverse8,a4
	bra	.processBuffer
.c16D2D
	cmpi.w	#2,sampleChannels(a3)
	beq	.c16SD2D
	addq.l	#2,d1
	addq.l	#2,a1
.s16D2D
	lea	.reverse16,a4
	bra	.processBuffer
.c16SD2D
	lea	.reverse16s,a4
.processBuffer
	movem.l	d0-d7/a0-a6,-(sp)
	pea	.reversedD2DBuffer
	jmp	(a4)
.reversedD2DBuffer
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	d2-d7/a2-a6,-(sp)
	callModule	#3		; process
	movem.l	(sp)+,d2-d7/a2-a6

	movem.l	d1-d2/a0-a2,-(sp)
	f_write	D2DBuffer,d2,d5	; write part
	movem.l	(sp)+,d1-d2/a0-a2

	cmp.l	d2,d0		; written the whole
	bne	diskFull		; buffer?

	tst.l	d3
	bgt	.process

	bsr	endD2DFunction
	graf_mouse	#0,#0
	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
	rts