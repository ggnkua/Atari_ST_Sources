	SECTION	text
trimBlock
	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	.noBlock

	lea	blockArea,a0
	tst.w	blockDefined(a0)
	beq	.noBlock

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	trimD2D

	move.l	sampleAddress(a3),a0
	move.l	a0,a1
	add.l	blockStart,a1

	move.l	blockSize,d0
	subq.l	#2,d0

	cmpi.l	#16,sampleResolution(a3)
	beq	.trim16

	addq.l	#1,d0
.trim8
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bgt	.trim8
	bra	.shrink
.trim16
	move.w	(a1)+,(a0)+
	subq.l	#2,d0
	bgt	.trim16

.shrink
	move.l	blockSize,sampleDataSize(a3)
	clr.l	blockStart
	move.l	blockSize,blockEnd

	m_shrink	blockSize,sampleAddress(a3)

	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	graf_mouse	#0,#0

.noBlock
	rts
;------------------------------------------------
trimD2D
	bsr	initD2DFunction
	move.l	d2,-(sp)
	f_close	d5
	f_create	#0,#tempPath	; recreate
	move.w	d0,d5
	move.l	(sp)+,d2

.process
	cmp.l	d2,d3
	bge	.noSizeAlter
	move.l	d3,d2
.noSizeAlter
	movem.l	d0-d2/a0-a2,-(sp)
	f_read	D2DBuffer,d2,d4	; read next part
	movem.l	(sp)+,d0-d2/a0-a2

	movem.l	d1-d2/a0-a2,-(sp)
	f_write	D2DBuffer,d2,d5	; write part
	movem.l	(sp)+,d1-d2/a0-a2

	cmp.l	d2,d0		; written the whole
	bne	diskFull		; buffer?
.noWrite
	sub.l	d2,d3		; filesize-=buffer size
	bgt	.process

	f_close	d4
	f_close	d5
	lea	samplePathname(a3),a3
	f_delete	a3
	f_rename	a3,#tempPath

	clr.l	blockStart
	move.l	blockSize,sampleDataSize(a3)
	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
	graf_mouse	#0,#0
	rts