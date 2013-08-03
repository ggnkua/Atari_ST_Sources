	SECTION	text
fadeSample
	move.w	#FADE,d0
	lea	.return,a1
	lea	sampleInfoTable,a0
*	cmpi.w	#2,sampleChannels(a0)
*	bne	.displayFade
*	move.w	#FADESTEREO,d0
*	lea	.returnStereo,a1
.displayFade
	displayDialog	d0,#16395,a1

; set special redraw
	move.l	dialogTableAddress,a0
	move.l	#fadeRedraw,dialogExtraRedraw(a0)

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#FADETITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	clr.l	fadePointY1
	clr.l	fadePointY3

	rts

; the object that caused the return is in d0
.return
	cmpi.w	#APPLYFADE,d0
	beq	applyFade
	cmpi.w	#DOFADE,d0
	beq	doFade

	cmpi.w	#CANCELMONOFADE,d0
	beq	.doneMono

	cmpi.w	#FADEINSLIDER,d0
	beq	fadeInSlider
	cmpi.w	#FADEINSCROLL,d0
	beq	fadeInSlider
	cmpi.w	#FADEOUTSLIDER,d0
	beq	fadeOutSlider
	cmpi.w	#FADEOUTSCROLL,d0
	beq	fadeOutSlider

	bsr	selectObject
	cmpi.w	#FADEINUP,d0
	beq	fadeInUp
	cmpi.w	#FADEINDOWN,d0
	beq	fadeInDown
	cmpi.w	#FADEOUTUP,d0
	beq	fadeOutUp
	cmpi.w	#FADEOUTDOWN,d0
	beq	fadeOutDown

.doneMono
	rts

.returnStereo
	cmpi.w	#CANCELSTEREOFADE,d0
	beq	.doneStereo

	cmpi.w	#FADEINLSLIDER,d0
	beq	fadeInLSlider
	cmpi.w	#FADEINLSCROLL,d0
	beq	fadeInLSlider
	cmpi.w	#FADEOUTLSLIDER,d0
	beq	fadeOutLSlider
	cmpi.w	#FADEOUTLSCROLL,d0
	beq	fadeOutLSlider
	cmpi.w	#FADEINRSLIDER,d0
	beq	fadeInRSlider
	cmpi.w	#FADEINRSCROLL,d0
	beq	fadeInRSlider
	cmpi.w	#FADEOUTRSLIDER,d0
	beq	fadeOutRSlider
	cmpi.w	#FADEOUTRSCROLL,d0
	beq	fadeOutRSlider

	bsr	selectObject
	cmpi.w	#FADEINLUP,d0
	beq	fadeInLUp
	cmpi.w	#FADEINLDOWN,d0
	beq	fadeInLDown
	cmpi.w	#FADEOUTLUP,d0
	beq	fadeOutLUp
	cmpi.w	#FADEOUTLDOWN,d0
	beq	fadeOutLDown
	cmpi.w	#FADEINRUP,d0
	beq	fadeInRUp
	cmpi.w	#FADEINRDOWN,d0
	beq	fadeInRDown
	cmpi.w	#FADEOUTRUP,d0
	beq	fadeOutRUp
	cmpi.w	#FADEOUTRDOWN,d0
	beq	fadeOutRDown

	cmpi.w	#EQUALSRIGHTFADE,d0
	beq	leftFadeERightFade
	cmpi.w	#EQUALSLEFTFADE,d0
	beq	rightFadeELeftFade

.doneStereo
	rts
;-----------------------------------------------------------------------
applyFade
	bsr	selectObject
doFade
	move.w	#1,fadeFlag
	move.l	blockStart,-(sp)
	move.l	blockSize,-(sp)
	move.l	blockEnd,-(sp)

	moveq.w	#-1,d2
	move.w	fadePointY1,d0
	move.w	fadePointY2,d1
	sub.w	d1,d0
	bpl	.notNeg
	neg	d0
	moveq.w	#1,d2
.notNeg
	move.l	blockSize,d1
	ext.l	d0
	tst.l	d0
	bne	.notZero
	moveq.l	#1,d0
.notZero
	bsr	long_div
; d0 holds blockSize

	move.l	blockSize,d3
	move.w	d2,d5
	move.l	d0,d2
	move.l	d2,blockSize
	move.w	fadePointY1,d4

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	add.l	#FADEDISPLAY*24,a0
	clr.l	d6
	move.w	objectH(a0),d6
	asr.w	#1,d6	; 1/2 the height to get max fade

; d4 = fadepoint Y coord
; d5 = +-1
; d6 = height of FADEDISPLAY
; d2 = temp block size
.loop
	clr.l	d0
	move.w	d4,d0
	mulu	#100,d0
	move.l	d6,d1
	exg	d0,d1
	bsr	long_div

	sub.w	#100,d0
	neg	d0
	move.w	d0,amplifyPercentage
	move.w	d0,amplifyPercentage2
	cmpi.w	#2,sampleChannels(a3)
	bne	.notStereo
.notStereo
	move.l	blockStart,d0
	add.l	blockSize,d0
	subq.l	#1,d0
	move.l	d0,blockEnd
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	amplifyBegin
	movem.l	(sp)+,d0-d7/a0-a6
	add.l	d2,blockStart

	add.w	d5,d4

	sub.l	d2,d3
	ble	.done

	cmp.l	d2,d3
	bgt	.loop
	move.l	d3,d2
	move.l	d2,blockSize
	bra	.loop

.done
	move.l	(sp)+,blockEnd
	move.l	(sp)+,blockSize
	move.l	(sp)+,blockStart
	clr.w	fadeFlag
	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
	graf_mouse	#0,#0

	rts

;-----------------------------------------------------------------------
fadeInUp
	move.w	fadePointY1,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeInNext

	andi.w	#1,d0
	bne	fadeInUp
	move.w	#FADEINUP,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeInDown
	move.w	fadePointY1,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeInNext

	andi.w	#1,d0
	bne	fadeInDown
	move.w	#FADEINDOWN,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeInNext
	lea	fadePointY1,a4
	lea	positionFadeInSlider,a5
	lea	drawMonoFadeLines,a6
	bsr	fadeNext
	rts
;-----------------------------------------------------------------------
fadeOutUp
	move.w	fadePointY2,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeOutNext
	andi.w	#1,d0
	bne	fadeOutUp
	move.w	#FADEOUTUP,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeOutDown
	move.w	fadePointY2,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeOutNext

	andi.w	#1,d0
	bne	fadeOutDown
	move.w	#FADEOUTDOWN,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeOutNext
	lea	fadePointY2,a4
	lea	positionFadeOutSlider,a5
	lea	drawMonoFadeLines,a6
	bsr	fadeNext
	rts
;-----------------------------------------------------------------------
fadeInSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEINSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeInNext

	rts
;-----------------------------------------------------------------------
fadeOutSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEOUTSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeOutNext

	rts
;-----------------------------------------------------------------------
positionFadeInSlider
	move.l	#FADEINSLIDER*24,d0
	move.w	#FADEINSLIDER,d1
	move.w	fadePointY1,d2

	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
positionFadeOutSlider
	move.l	#FADEOUTSLIDER*24,d0
	move.w	#FADEOUTSLIDER,d1
	move.w	fadePointY2,d2

	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
drawMonoFadeLines
	move.l	#FADEDISPLAY*24,d0
	move.w	#FADEDISPLAY,d1
	move.w	fadePointY1,d6
	move.w	fadePointY2,d7

	bsr	drawFadeLines
	rts
;-----------------------------------------------------------------------
fadeInLUp
	move.w	fadePointY1,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeInLNext
	andi.w	#1,d0
	bne	fadeInLUp
	move.w	#FADEINLUP,d0
	jsr	selectObject
	rts
;-----------------------------------------------------------------------
fadeInLDown
	move.w	fadePointY1,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY1*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeInLNext

	andi.w	#1,d0
	bne	fadeInLDown
	move.w	#FADEINLDOWN,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeInLNext
	lea	fadePointY1,a4
	lea	positionFadeInLSlider,a5
	lea	drawLeftFadeLines,a6
	bsr	fadeNext
	rts
;-----------------------------------------------------------------------
fadeOutLUp
	move.w	fadePointY2,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeOutLNext
	andi.w	#1,d0
	bne	fadeOutLUp
	move.w	#FADEOUTLUP,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeOutLDown
	move.w	fadePointY2,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY1*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeOutLNext
	andi.w	#1,d0
	bne	fadeOutLDown
	move.w	#FADEOUTLDOWN,d0
	jsr	selectObject

	rts
;-----------------------------------------------------------------------
fadeOutLNext
	lea	fadePointY2,a4
	lea	positionFadeOutLSlider,a5
	lea	drawLeftFadeLines,a6
	bsr	fadeNext
;-----------------------------------------------------------------------
fadeInLSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEINLSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeInLNext

	rts
;-----------------------------------------------------------------------
fadeOutLSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEOUTLSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeOutLNext

	rts
;-----------------------------------------------------------------------
positionFadeInLSlider
	move.l	#FADEINLSLIDER*24,d0
	move.w	#FADEINLSLIDER,d1
	move.w	fadePointY1,d2
	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
positionFadeOutLSlider
	move.l	#FADEOUTLSLIDER*24,d0
	move.w	#FADEOUTLSLIDER,d1
	move.w	fadePointY2,d2
	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
drawLeftFadeLines
	move.l	#FADEDISPLAY1*24,d0
	move.w	#FADEDISPLAY1,d1
	move.w	fadePointY1,d6
	move.w	fadePointY2,d7

	bsr	drawFadeLines
	rts
;-----------------------------------------------------------------------
fadeInRUp
	move.w	fadePointY3,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeInRNext

	andi.w	#1,d0
	bne	fadeInRUp
	move.w	#FADEINRUP,d0
	jsr	selectObject
	rts
;-----------------------------------------------------------------------
fadeInRDown
	move.w	fadePointY3,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY2*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeInRNext

	andi.w	#1,d0
	bne	fadeInRDown
	move.w	#FADEINRDOWN,d0
	jsr	selectObject
	rts
;-----------------------------------------------------------------------
fadeInRNext
	lea	fadePointY3,a4
	lea	positionFadeInRSlider,a5
	lea	drawRightFadeLines,a6
	bsr	fadeNext
	rts
;-----------------------------------------------------------------------
fadeOutRUp
	move.w	fadePointY4,d0
	subq.w	#1,d0
	bge	.ok
	moveq.w	#0,d0
.ok
	bsr	fadeOutRNext

	andi.w	#1,d0
	bne	fadeOutRUp
	move.w	#FADEOUTRUP,d0
	jsr	selectObject
	rts
;-----------------------------------------------------------------------
fadeOutRDown
	move.w	fadePointY4,d5
	addq.w	#1,d5

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FADEDISPLAY2*24,d0
	add.l	d0,a0
	move.w	objectH(a0),d6
	asr.w	#1,d6
	cmp.w	d6,d5
	ble	.ok
	move.w	d6,d5
.ok
	move.w	d5,d0
	bsr	fadeOutRNext

	andi.w	#1,d0
	bne	fadeOutRDown
	move.w	#FADEOUTRDOWN,d0
	jsr	selectObject
	rts
;-----------------------------------------------------------------------
fadeOutRNext
	lea	fadePointY4,a4
	lea	positionFadeOutRSlider,a5
	lea	drawRightFadeLines,a6
	bsr	fadeNext
	rts
;-----------------------------------------------------------------------
fadeInRSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEINRSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeInRNext
	rts
;-----------------------------------------------------------------------
fadeOutRSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FADEOUTRSLIDER*24,d0
	add.l	d0,a1
	move.w	objectY(a1),d0

	bsr	fadeOutRNext
	rts
;-----------------------------------------------------------------------
positionFadeInRSlider
	move.l	#FADEINRSLIDER*24,d0
	move.w	#FADEINRSLIDER,d1
	move.w	fadePointY3,d2
	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
positionFadeOutRSlider
	move.l	#FADEOUTRSLIDER*24,d0
	move.w	#FADEOUTRSLIDER,d1
	move.w	fadePointY4,d2
	bsr	positionFadeSlider
	rts
;-----------------------------------------------------------------------
drawRightFadeLines
	move.l	#FADEDISPLAY2*24,d0
	move.w	#FADEDISPLAY2,d1
	move.w	fadePointY3,d6
	move.w	fadePointY4,d7

	bsr	drawFadeLines
	rts
;-----------------------------------------------------------------------
leftFadeERightFade

	rts
;-----------------------------------------------------------------------
rightFadeELeftFade

	rts
;-----------------------------------------------------------------------
positionFadeSlider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	add.l	d0,a1
	move.w	d2,objectY(a1)
	move.w	objectW(a1),d3
	move.w	objectH(a1),d4

	objc_offset	d1,dialogResource(a0)
	movem.w	intout+2,d1-d2
	subq.w	#2,d2
	addq.w	#4,d4
	objc_draw	#0,#9,d1,d2,d3,d4,dialogResource(a0)
	rts
;-----------------------------------------------------------------------
fadeNext
	move.l	dialogTableAddress,a0
	wind_get	dialogHandle(a0),#4
	movem.w	intout+2,d1-d4
	add.w	d1,d3
	add.w	d2,d4
	vs_clip	wsHandle,#1,d1,d2,d3,d4
	movem.w	d1-d4,-(sp)
	move.w	d0,-(sp)
	pea	.return1
	jmp	(a6)
.return1
	move.w	(sp)+,(a4)
	pea	.return2
	jmp	(a5)
.return2
	pea	.return3
	jmp	(a6)
.return3
	movem.w	(sp)+,d1-d4
	vs_clip	wsHandle,#0,d1,d2,d3,d4

	evnt_timer	#25,#0
	graf_mkstate
	move.w	intout+6,d0
	rts
;-----------------------------------------------------------------------
drawFadeLines
	vsl_color	wsHandle,#1	; colour = black
	vswr_mode	wsHandle,#3

	graf_mouse	#256,#0
	wind_update	#1

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	d1,a1
	movem.w	intout+2,d1-d2	x,y of first line
	add.l	d0,a1
	move.w	objectW(a1),d3
	move.w	objectH(a1),d4
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	movem.w	d1-d4,-(sp)
	move.w	d2,d4
	add.w	d6,d2
	add.w	d7,d4
	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)
	v_pline	#2,wsHandle
	movem.w	(sp)+,d1-d4

	move.w	d4,d2
	sub.w	d6,d2
	sub.w	d7,d4
	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d4,(a2)
	v_pline	#2,wsHandle

	wind_update	#0
	graf_mouse	#257,#0

	vswr_mode	wsHandle,#0
	rts
;-----------------------------------------------------------------------
fadeRedraw
	movem.l	d0-d7/a0-a6,-(sp)

; convert AES to VDI coordinates
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

; set cliping zone
	vs_clip	wsHandle,#1,d1,d2,d3,d4
	movem.w	d1-d4,-(sp)

	vsl_ends	wsHandle,#0,#0

; set background colour to user chosen 1

	lea	optionsTable,a0
	vsf_color	wsHandle,optionBackground(a0)

	lea	sampleInfoTable,a0
*	cmpi.w	#2,sampleChannels(a0)
*	beq	fadeStereoRedraw

** start of mono redraw **
; get resource address

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0


	objc_offset	#FADEDISPLAY,a0
	movem.w	intout+2,d1-d2

	move.l	#FADEDISPLAY*24,d0
	add.l	d0,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4

	movem.w	d1-d4,-(sp)

	addq.w	#1,d1
	addq.w	#1,d2
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#3,d3
	subq.w	#3,d4

	v_bar	wsHandle,d1,d2,d3,d4

	movem.w	(sp)+,d1-d4

; draw centre line
	vsl_color	wsHandle,#1
	move.w	d4,d5
	addq.w	#5,d1
	add.w	d1,d3
	add.w	d2,d4
	sub.w	#11,d3
	subq.w	#1,d4
	movem.w	d1-d4,-(sp)

	asr.w	#1,d5
	add.w	d5,d2
	subq.w	#1,d2

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)
	v_pline	#2,wsHandle

; set sample colour
	lea	optionsTable,a0
	vsl_color	wsHandle,optionSampleColour(a0)
; draw sample    (from cache)
	lea	redrawCache1,a0
	move.w	d2,d4
	move.w	#309,d0
.monoDraw
	move.w	(a0)+,d7
	addq.l	#2,a0
	move.w	d4,d6
	sub.w	d7,d6
	add.w	d4,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle

	addq.w	#1,d1
	dbra	d0,.monoDraw


	movem.w	(sp)+,d1-d4

; draw the fade lines
	bsr	drawMonoFadeLines

; disable clipping zone
	movem.w	(sp)+,d1-d4
	vs_clip	wsHandle,#1,d1,d2,d3,d4

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;----------------------------------------------------------------------
fadeStereoRedraw

; get resource address

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0

; first the left channel

	objc_offset	#FADEDISPLAY1,a0
	movem.w	intout+2,d1-d2

	move.l	#FADEDISPLAY1*24,d0
	add.l	d0,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4

	movem.w	d1-d4,-(sp)

	addq.w	#1,d1
	addq.w	#1,d2
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#3,d3
	subq.w	#3,d4

	v_bar	wsHandle,d1,d2,d3,d4

	movem.w	(sp)+,d1-d4

; draw centre line
	vsl_color	wsHandle,#1
	move.w	d4,d5
	addq.w	#5,d1
	add.w	d1,d3
	add.w	d2,d4
	sub.w	#11,d3
	subq.w	#1,d4
	movem.w	d1-d4,-(sp)

	asr.w	#1,d5
	add.w	d5,d2
	subq.w	#1,d2

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)
	v_pline	#2,wsHandle

; set sample colour
	lea	optionsTable,a0
	vsl_color	wsHandle,optionSampleColour(a0)
; draw sample    (from cache)
	lea	redrawCache1,a0
	move.w	d2,d4
	move.w	#309,d0
.leftDraw
	move.w	(a0)+,d7
	addq.l	#2,a0
	asr.w	#1,d7

	move.w	d4,d6
	sub.w	d7,d6
	add.w	d4,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle

	addq.w	#1,d1
	dbra	d0,.leftDraw


	movem.w	(sp)+,d1-d4

; now the right channel
; get resource address

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	objc_offset	#FADEDISPLAY2,a0
	movem.w	intout+2,d1-d2

	move.l	#FADEDISPLAY2*24,d0
	add.l	d0,a0
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4

	movem.w	d1-d4,-(sp)

	addq.w	#1,d1
	addq.w	#1,d2
	add.w	d1,d3
	add.w	d2,d4
	subq.w	#3,d3
	subq.w	#3,d4

	v_bar	wsHandle,d1,d2,d3,d4

	movem.w	(sp)+,d1-d4

; draw centre line
	vsl_color	wsHandle,#1
	move.w	d4,d5
	addq.w	#5,d1
	add.w	d1,d3
	add.w	d2,d4
	sub.w	#11,d3
	subq.w	#1,d4
	movem.w	d1-d4,-(sp)

	asr.w	#1,d5
	add.w	d5,d2
	subq.w	#1,d2

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.w	d3,(a2)+
	move.w	d2,(a2)
	v_pline	#2,wsHandle

; set sample colour
	lea	optionsTable,a0
	vsl_color	wsHandle,optionSampleColour(a0)
; draw sample    (from cache)
	lea	redrawCache2,a0
	move.w	d2,d4
	move.w	#309,d0
.rightDraw
	move.w	(a0)+,d7
	addq.l	#2,a0
	asr.w	#1,d7

	move.w	d4,d6
	sub.w	d7,d6
	add.w	d4,d7

	lea	ptsin,a2
	move.w	d1,(a2)+
	move.w	d6,(a2)+
	move.w	d1,(a2)+
	move.w	d7,(a2)
	v_pline	#2,wsHandle

	addq.w	#1,d1
	dbra	d0,.rightDraw


	movem.w	(sp)+,d1-d4

; draw the fade lines
	bsr	drawLeftFadeLines
	bsr	drawRightFadeLines
; disable clipping zone
	movem.w	(sp)+,d1-d4
	vs_clip	wsHandle,#1,d1,d2,d3,d4

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;------------------------------------------------------------------------
	SECTION	bss
fadePointY1	ds.w	1
fadePointY2	ds.w	1

fadePointY3	ds.w	1
fadePointY4	ds.w	1

leftFade	ds.w	1
rightFade	ds.w	1
leftCounter	ds.w	1
rightCounter	ds.w	1
leftFadePercent	ds.w	1
rightFadePercent	ds.w	1

fadeFlag	ds.w	1