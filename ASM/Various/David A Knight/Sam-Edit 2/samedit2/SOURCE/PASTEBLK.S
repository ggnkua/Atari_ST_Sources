	SECTION	text
pasteBlock
	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	.noPaste

	move.l	d0,d7

	tst.w	GEMClip
	bne	GEMPasteBlock

	tst.l	clipSize
	beq	.noPaste

	graf_mouse	#2,#0

	move.l	blockStart,d1
	move.l	clipSize,d0
	move.l	sampleDataSize(a3),d2
	sub.l	d1,d2

	cmp.l	d0,d2
	bgt	.noLimitPaste

	move.l	d2,d0	; limit the paste to sample buffer

.noLimitPaste
	move.l	clipAddress,a1

	tst.w	sampleMode(a3)
	bne	.pasteD2D

	cmpi.w	#OVERLAY,d7
	beq	.mixLoopCheck

	move.l	sampleAddress(a3),a0
	add.l	d1,a0
	cmpi.w	#16,sampleResolution(a3)
	beq	.loop16
.loop8
	moveq.l	#0,d1
	move.b	(a1)+,d1
	tst.w	sampleSigned(a3)
	beq	.pasteUnsigned
	eor.b	#$80,d1
.pasteUnsigned
	move.b	d1,(a0)+
	subq.l	#1,d0
	bgt	.loop8
	bra	.pasteDone
.loop16
	moveq.l	#0,d1
	move.w	(a1)+,d1
	tst.w	sampleSigned(a3)
	beq	.pasteUnsigned16
	eor.w	#$4000,d1
.pasteUnsigned16
	move.w	d1,(a0)+
	subq.l	#2,d0
	bgt	.loop16
.pasteDone
	tst.w	sampleMode(a3)
	bne	.noPaste
	graf_mouse	#0,#0

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
.noPaste
	rts
;------------------------------------------------------
.mixLoopCheck
	move.l	sampleAddress(a3),a0
	add.l	d1,a0
	cmpi.l	#16,sampleResolution(a3)
	beq	.mix16loop
.mix8loop
	move.b	(a0),d1
	tst.w	sampleSigned(a3)
	bne	.signed8
	eor.b	#$80,d1
.signed8
	ext.w	d1
	ext.l	d1
	move.b	(a1)+,d2
	ext.w	d2
	ext.l	d2
	ror.l	#1,d1
	ror.l	#1,d2
	add.l	d1,d2
	tst.w	sampleSigned(a3)
	bne	.signed82
	eor.b	#$80,d1
.signed82
	move.b	d2,(a0)+
	subq.l	#1,d0
	bgt	.mix8loop
	bra	.pasteDone

.mix16loop
	move.w	(a0),d1
	tst.w	sampleSigned(a3)
	bne	.signed16
	eor.w	#$4000,d1
.signed16
	ext.l	d1
	move.w	(a1)+,d2
	ext.l	d2
	ror.l	#1,d1
	ror.l	#1,d2
	add.l	d1,d2
	tst.w	sampleSigned(a3)
	bne	.signed162
	eor.w	#$4000,d1
.signed162
	move.w	d2,(a0)+
	subq.l	#2,d0
	bgt	.mix16loop
	bra	.pasteDone
;------------------------------------------------------
.pasteD2D
	move.l	blockSize,-(sp)
	move.l	blockEnd,-(sp)
	move.l	d0,blockSize
	add.l	blockStart,d0
	move.l	d0,blockEnd

	lea	.loop8,a4
	lea	.mix8loop,a5
	cmpi.w	#16,sampleResolution(a3)
	bne	.swap
	lea	.loop16,a4
	lea	.mix16loop,a5
.swap
	cmpi.w	#OVERLAY,d7
	bne	.set
	move.l	a5,a4
.set
	moveq.w	#0,d0
	bsr	generalD2DOperation

	graf_mouse	#0,#0

	move.l	(sp)+,blockEnd
	move.l	(sp)+,blockSize

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
	rts
;--------------------------------------------------------------------------
GEMPasteBlock
	graf_mouse	#2,#0

	stringLength	#clipPath
	lea	clipPath,a4
	ext.l	d1
	add.l	d1,a4
	stringCopy	#scrapFile,a4
	clr.b	(a1)

	f_sfirst	#%11111,#clipPath
	tst.w	d0
	bmi	.done

	move.l	dta+26,d4	; size

	f_open	#0,#clipPath
	move.w	d0,d3

	tst.w	sampleMode(a3)
	bne	D2DGEMPasteBlock

	cmpi.w	#OVERLAY,d7
	beq	GEMOverlayBlock

	move.l	sampleAddress(a3),a4
	add.l	blockStart,a4
	move.l	sampleDataSize(a3),d5
	sub.l	blockStart,d5
	cmp.l	d4,d5
	bge	.ok
	move.l	d5,d4	; limit ammount to be pasted
.ok
	f_read	a4,d4,d3
	f_close	d3
	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
.done
	graf_mouse	#0,#0
	rts
;--------------------------------------------------------------------------
GEMOverlayBlock	; file handle in d3
		; size in d4
; Use the D2D buffer
	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	jsr	long_mul
	tst.l	d0
	beq	.cantDo

	move.l	d0,d5	; bufferSize
	move.l	sampleDataSize(a3),d6

	sub.l	blockStart,d6
	cmp.l	d4,d6
	bgt	.ok
	move.l	d6,d4	; limit the amount to paste to the buffer size
.ok

** d3 = clip handle
** d4 = size to paste
** d5 = buffer size
	move.l	sampleAddress(a3),a4
	add.l	blockStart,a4
	move.l	D2DBuffer,a5
.loop
	cmp.l	d5,d4
	bgt	.cont
	move.l	d5,d4
.cont
	f_read	a5,d5,d3

	move.l	d5,d6
	move.l	a5,a6
** a6 = buffer address for overlay
** a4 = address to overlay to.
** d6 = process size
	cmpi.w	#16,sampleResolution(a3)
	beq	.mix16loop
.mix8loop
	move.b	(a4),d1
	tst.w	sampleSigned(a3)
	bne	.signed8
	eor.b	#$80,d1
.signed8
	ext.w	d1
	ext.l	d1
	move.b	(a6)+,d2
	ext.w	d2
	ext.l	d2
	ror.l	#1,d1
	ror.l	#1,d2
	add.l	d1,d2
	tst.w	sampleSigned(a3)
	bne	.signed82
	eor.b	#$80,d1
.signed82
	move.b	d2,(a4)+
	subq.l	#1,d6
	bgt	.mix8loop
	bra	.mixNext
.mix16loop
	move.w	(a4),d1
	tst.w	sampleSigned(a3)
	bne	.signed16
	eor.w	#$4000,d1
.signed16
	ext.l	d1
	move.w	(a6)+,d2
	ext.l	d2
	ror.l	#1,d1
	ror.l	#1,d2
	add.l	d1,d2
	tst.w	sampleSigned(a3)
	bne	.signed162
	eor.w	#$4000,d1
.signed162
	move.w	d2,(a4)+
	subq.l	#2,d6
	bgt	.mix16loop
** processed buffer
.mixNext
	sub.l	d5,d4
	bgt	.loop

	f_close	d3
	rts
.cantDo
	f_close	d3
	bra	cantAllocateD2D
;--------------------------------------------------------------------------
D2DGEMPasteBlock	; scrap file handle in d3
		; size in d4

	cmpi.w	#OVERLAY,d7
	beq	D2DGEMOverlayBlock

; Use the D2D buffer
	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	ext.l	d0
	move.l	#1024,d1
	jsr	long_mul
	tst.l	d0
	beq	.cantDo

	move.l	d0,d5	; bufferSize
	move.l	sampleDataSize(a3),d6

	sub.l	blockStart,d6
	cmp.l	d4,d6
	bgt	.ok
	move.l	d6,d4	; limit the amount to paste to the buffer size
.ok

** d3 = clip handle
** d4 = size to paste
** d5 = buffer size
	lea	samplePathname(a3),a4
	move.l	D2DBuffer,a5
	f_open	#2,a4
	move.w	d0,d7
	move.w	sampleHeaderSize(a3),d6
	ext.l	d6
	add.l	blockStart,d6
	f_seek	#0,d7,d6
.loop
	cmp.l	d5,d4
	bgt	.cont
	move.l	d5,d4
.cont
	f_read	a5,d5,d3
	f_write	a5,d5,d7

	sub.l	d5,d4
	bgt	.loop

	f_close	d3
	f_close	d7

	graf_mouse	#0,#0
	rts
.cantDo
	f_close	d3
	bra	cantAllocateD2D
;--------------------------------------------------------------------------
D2DGEMOverlayBlock
	rts
;--------------------------------------------------------------------------