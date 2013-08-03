	SECTION	text
mainWindowRedraw
	movem.l	d0-d7/a0-a6,-(sp)

	tst.w	mainWindowIconise
	bne	drawIconise

; AES to VDI
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

; set clipping zone
	vs_clip	wsHandle,#1,d1,d2,d3,d4

; set background colour
	lea	optionsTable,a0
	vsf_color	wsHandle,optionBackground(a0)
; redraw background of window
	v_bar	wsHandle,d1,d2,d3,d4

; redraw sample itself
	vsl_color	wsHandle,#1	; set line colour to black

	lea	sampleInfoTable,a0
; if D2D open the file and bypass the sample header
	tst.w	sampleMode(a0)
	beq	.notD2D

	movem.l	d0-d4/a0-a3,-(sp)
	move.l	a0,a1
	add.l	#samplePathname,a1

	f_open	#0,a1
	move.w	d0,D2DHandle
	move.w	sampleHeaderSize(a0),d3
	ext.l	d3
	f_seek	#0,d0,d3
	movem.l	(sp)+,d0-d4/a0-a3
.notD2D
; is it mono or stereo?  (always mono if >2 channels)
	cmpi.w	#2,sampleChannels(a0)
	beq	.stereoRedraw

.monoRedraw	; draw baseline
	movem.w	d1-d4,-(sp)
	wind_get	d0,#4
	movem.w	intout+2,d1-d4

	add.w	#10,d1
	sub.w	#20,d3
	asr.w	#1,d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d4,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)
	v_pline	#2,wsHandle
; is there even a sample loaded?
	tst.w	sampleLoaded(a0)
	beq	.monoDone

; set sample colour to draw
	lea	optionsTable,a1
	vsl_color	wsHandle,optionSampleColour(a1)

; calc draw offset
	move.l	d1,-(sp)
	move.l	sampleDataSize(a0),d1
	move.l	a0,a4

; set to max view as default for the moment
	move.l	#620,d0
	bsr	long_div
	move.l	d0,d5
	move.l	(sp)+,d1

	move.l	sampleAddress(a0),a0

	move.w	#619,d0
	lea	redrawCache1,a3
; scale in d5, start x in d1, line y in d4, redrawcache in a3
.monoDraw
	tst.w	redrawCached
	bne	.cachedMono
; D2D?
	tst.w	sampleMode(a4)
	beq	.noMonoD2D
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	lea	redrawLoadCache,a0
.noMonoD2D
	move.b	(a0),d7
	cmpi.w	#16,sampleResolution(a4)	; 16 bit sample?
	bne	.mono8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DMono16
	move.w	sampleModuleFunctions(a4),d6
	andi.w	#%10000,d6
	beq	.mono16	; Intel order
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,#1
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.mono8
.mono16
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	move.b	(a0),d7
	bra	.mono8
.notD2DMono16
	move.w	(a0),d7
	asr.w	#8,d7
.mono8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DMono8
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,d5
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.monoCalc
.notD2DMono8
	add.l	d5,a0
.monoCalc
; calculate coordinate
	eor.b	#$80,d7
	sub.b	#$80,d7
	ext.w	d7
	asr.w	#2,d7
	move.w	d7,(a3)+	; place in redrawCache1
	bra	.notCachedMono
.cachedMono
	move.w	(a3)+,d7
.notCachedMono
	move.w	d4,d6
	sub.w	d7,d6
	add.w	d4,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle	; plot point
	addq.w	#1,d1		; increment x coordinate

	dbra	d0,.monoDraw
.monoDone
	movem.w	(sp)+,d1-d4
	bra	sampleDrawn


.stereoRedraw	; draw baseline
	movem.w	d1-d4,-(sp)
	wind_get	d0,#4
	movem.w	intout+2,d1-d4

	add.w	#10,d1
	sub.w	#20,d3
	asr.w	#2,d4
	move.w	d4,d5

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d4,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)
	v_pline	#2,wsHandle
	move.w	d4,d6	; store line y coord

	move.w	d5,d4
	asl.w	#1,d5
	add.w	d4,d5
	add.w	d2,d5
	subq.w	#1,d5

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d5,(a2)+
	move.w	d3,(a2)+
	move.w	d5,(a2)+
	v_pline	#2,wsHandle

; store channel 1 and channel 2 y coords  (d2 and d4)
	move.w	d5,d4
	move.w	d6,d2

; is there even a sample loaded?
	tst.w	sampleLoaded(a0)
	beq	.stereoDone

; set sample colour to draw
	lea	optionsTable,a1
	vsl_color	wsHandle,optionSampleColour(a1)

; calc draw offset
	move.l	d1,-(sp)
	move.l	sampleDataSize(a0),d1
	move.l	a0,a4

; set to max view as default for the moment
	move.l	#1240,d0	; double view as 2 channels
	bsr	long_div
	move.l	d0,d5
	move.l	(sp)+,d1

	move.l	sampleAddress(a0),a0

	move.w	#619,d0
	lea	redrawCache1,a3
	lea	redrawCache2,a5
; scale in d5, start x in d1, line y in d4, redrawcache in a3 and a5
.stereoDraw
	tst.w	redrawCached
	bne	.cached1Stereo
; D2D?
	tst.w	sampleMode(a4)
	beq	.noLeftD2D
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	lea	redrawLoadCache,a0
.noLeftD2D
	move.b	(a0),d7
	cmpi.w	#16,sampleResolution(a4)	; 16 bit sample?
	bne	.left8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DLeft16
	move.w	sampleModuleFunctions(a4),d6
	andi.w	#%10000,d6
	beq	.left16	; Intel order
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,#1
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.left8
.left16
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	move.b	(a0),d7
	bra	.left8
.notD2DLeft16
	move.w	(a0),d7
	asr.w	#8,d7
.left8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DLeft8
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,d5
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.leftCalc
.notD2DLeft8
	add.l	d5,a0
.leftCalc

; calculate coordinate
	eor.b	#$80,d7
	sub.b	#$80,d7
	ext.w	d7
	asr.w	#3,d7
	move.w	d7,(a3)+	; place in redrawCache1
	bra	.notCached1Stereo
.cached1Stereo
	move.w	(a3)+,d7
.notCached1Stereo
	move.w	d2,d6
	sub.w	d7,d6
	add.w	d2,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle	; plot point

	tst.w	redrawCached
	bne	.cached2Stereo

; D2D?
	tst.w	sampleMode(a4)
	beq	.noRightD2D
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	lea	redrawLoadCache,a0
.noRightD2D
	move.b	(a0),d7
	cmpi.w	#16,sampleResolution(a4)	; 16 bit sample?
	bne	.right8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DRight16
	move.w	sampleModuleFunctions(a4),d6
	andi.w	#%10000,d6
	beq	.right16	; Intel order
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,#1
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.right8
.right16
	movem.l	d0-d3/a0-a3,-(sp)
	f_read	#redrawLoadCache,#1,D2DHandle
	movem.l	(sp)+,d0-d3/a0-a3
	move.b	(a0),d7
	bra	.right8
.notD2DRight16
	move.w	(a0),d7
	asr.w	#8,d7
.right8
; D2D?
	tst.w	sampleMode(a4)
	beq	.notD2DRight8
	movem.l	d0-d3/a0-a3,-(sp)
	f_seek	#1,D2DHandle,d5
	movem.l	(sp)+,d0-d3/a0-a3
	bra	.rightCalc
.notD2DRight8
	add.l	d5,a0
.rightCalc
; calculate coordinate
	eor.b	#$80,d7
	sub.b	#$80,d7
	ext.w	d7
	asr.w	#3,d7
	move.w	d7,(a5)+	; place in redrawCache2
	bra	.notCached2Stereo
.cached2Stereo
	move.w	(a5)+,d7
.notCached2Stereo
	move.w	d4,d6
	sub.w	d7,d6
	add.w	d4,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle	; plot point

	addq.w	#1,d1		; increment x coordinate
	dbra	d0,.stereoDraw
.stereoDone
	movem.w	(sp)+,d1-d4


sampleDrawn
	bsr	redrawMarkedBlock
; disable clipping zone
	vs_clip	wsHandle,#0,d1,d2,d3,d4
; set cached flag
	move.w	#1,redrawCached

	lea	sampleInfoTable,a0
	tst.w	sampleMode(a0)
	beq	.done
	f_close	D2DHandle
.done
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	SECTION	bss
redrawCached	ds.w	1
redrawCache1	ds.w	621
redrawCache2	ds.w	621
redrawLoadCache	ds.w	1
D2DHandle	ds.w	1
sampleDrawDivisor	ds.w	1