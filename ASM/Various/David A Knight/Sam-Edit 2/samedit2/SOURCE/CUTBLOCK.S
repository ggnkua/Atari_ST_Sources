	SECTION	text
cutCopyBlock
	lea	sampleInfoTable,a3
	tst.w	sampleLoaded(a3)
	beq	.done

	lea	blockArea,a0
	tst.w	blockDefined(a0)
	beq	.done

	move.l	d0,d7

	tst.w	GEMClip	; use GEM clipboard?
	bne	GEMCutCopyBlock

	bsr	checkClip
	m_xalloc	#3,blockSize	; reserve buffer
	tst.l	d0
	beq	noMemoryForClipBuffer

	move.l	d0,clipAddress
	move.l	blockSize,clipSize

	graf_mouse	#2,#0

	tst.w	sampleMode(a3)
	bne	.d2dCutCopy

	move.l	sampleAddress(a3),a0
	move.l	clipAddress,a1
	add.l	blockStart,a0
	move.l	blockSize,d0

	cmpi.w	#COPY,d7
	beq	.copy

	cmpi.w	#16,sampleResolution(a0)
	beq	.loop16
.loop8
	move.b	(a0),(a1)+
	clr.b	(a0)+
	subq.l	#1,d0
	bgt	.loop8
	bra	.cutDone
.loop16
	move.w	(a0),(a1)+
	clr.w	(a0)+
	subq.l	#2,d0
	bgt	.loop16
	bra	.cutDone
.copy
	cmpi.w	#16,sampleResolution(a0)
	beq	.loop16Copy
.loop8Copy
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bgt	.loop8Copy
	bra	.cutDone
.loop16Copy
	move.w	(a0)+,(a1)+
	subq.l	#2,d0
	bgt	.loop16Copy

.cutDone
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
;------------------------------------------------------------------
.d2dCutCopy
	lea	.loop8,a4
	lea	.loop8Copy,a5

	cmpi.w	#16,sampleChannels(a3)
	bne	.d2dCutCopySet

	lea	.loop16,a4
	lea	.loop16Copy,a5
.d2dCutCopySet
	cmpi.w	#COPY,d7
	bne	.notCopy
	move.l	a5,a4
.notCopy
	moveq.w	#0,d0
	bsr	generalD2DOperation

	graf_mouse	#0,#0

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
	rts
;------------------------------------------------------------------
checkClip
	tst.l	clipSize
	beq	.checkDone

	m_free	clipAddress	; free old clipboard
	clr.l	clipSize
.checkDone
	rts

noMemoryForClipBuffer
	rsrc_gaddr	#5,#OUTOFMEMORY
	form_alert	#1,addrout
	rts
;------------------------------------------------------------------
GEMCutCopyBlock
	stringLength	#clipPath
	lea	clipPath,a4
	ext.l	d1
	add.l	d1,a4
	stringCopy	#scrapFile,a4
	clr.b	(a1)

	f_create	#0,#clipPath
	move.w	d0,d3

	tst.w	sampleMode(a3)
	bne	D2DGEMCutCopyBlock

	move.l	sampleAddress(a3),a4
	add.l	blockStart,a4
	move.l	blockSize,d4
	f_write	a4,d4,d3
	f_close	d3
	cmpi.w	#COPY,d7
	beq	.done
.clear
	clr.b	(a4)+
	subq.l	#1,d4
	bgt	.clear
	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
.done
	rts
;------------------------------------------------------------------
D2DGEMCutCopyBlock	; d3 holds scrap file handle

	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	jsr	long_mul
	tst.l	d0
	ble	.cantDo
	move.l	d0,d6

	lea	samplePathname(a3),a4
	move.w	sampleHeaderSize(a3),d4
	ext.l	d4
	add.l	blockStart,d4
	f_open	#2,a4
	move.w	d0,d5
	f_seek	#0,d5,d4
	move.l	blockSize,d4
	exg	d4,d6
.loop
	cmp.l	d4,d6
	bgt	.noFix
	move.l	d6,d4
.noFix
	f_read	D2DBuffer,d4,d5
	f_write	D2DBuffer,d4,d3
	sub.l	d4,d6
	bgt	.loop
	f_close	d3
	f_close	d5

	cmpi.w	#COPY,d7
	bne	deleteBlock

	rts
.cantDo
	f_close	d3
	bra	cantAllocateD2D
;------------------------------------------------------------------
	SECTION	text
clipAddress	ds.l	1
clipSize	ds.l	1