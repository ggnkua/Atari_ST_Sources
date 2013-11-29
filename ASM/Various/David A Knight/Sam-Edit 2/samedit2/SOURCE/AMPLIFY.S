	SECTION	text
amplifySample
	displayDialog	#AMPLIFY,#16395,#.return

; set special redraw
	move.l	dialogTableAddress,a0

	move.l	#amplifyRedraw,dialogExtraRedraw(a0)

; set window title

	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#AMPLIFYTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	move.w	#100,amplifyPercentage
	bsr	amplifyVolumeDisplay

	rts

; the object that caused the return is in d0
.return
	cmpi.w	#OKAMPLIFY,d0
	beq	amplifyBegin

	cmpi.w	#CANCELAMPLIFY,d0
	beq	.done

	cmpi.w	#AUTOAMPLIFY,d0
	beq	autoAmplify

	cmpi.w	#APPLYAMPLIFY,d0
	beq	amplifyApply

	cmpi.w	#AMPLIFYBAR,d0
	beq	amplifyBar
	cmpi.w	#AMPLIFYMINUS,d0
	beq	amplifyMinus
	cmpi.w	#AMPLIFYPLUS,d0
	beq	amplifyPlus
.done
	rts
;-----------------------------------------------------------------
autoAmplify
	move.w	amplifyPercentage,-(sp)
	bsr	selectObject
	graf_mouse	#2,#0

	lea	sampleInfoTable,a3

	tst.w	sampleMode(a3)
	bne	autoAmplifyD2D

	move.l	sampleAddress(a3),a0
	add.l	blockStart,a0
	move.l	blockSize,d0
	moveq.l	#0,d2
	subq.l	#2,d0
	lea	autoAmplify8,a1
	move.b	(a0)+,d2
	cmpi.w	#16,sampleResolution(a3)
	bne	.not16
	subq.l	#2,d0
	move.w	-1(a0),d2
	lea	autoAmplify16,a1
.not16
	jmp	(a1)

autoAmplify8

	move.b	(a0)+,d6
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign8
	eor.b	#$80,d6
.noSign8
	tst.b	d6
	bmi	.notPlus8
	neg.b	d6
.notPlus8
	ext.w	d6
	cmp.w	d6,d2
	blt	.notNew8
	move.w	d6,d2
.notNew8
	subq.l	#1,d0
	bgt	autoAmplify8

; largest value in d2 (word as a negative)

	move.l	#-12800,d3	; 2^7 * 100
	divs	d2,d3
	move.w	d3,amplifyPercentage

	bra	autoAmplifyGo

autoAmplify16

	move.w	(a0)+,d6
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign16
	eor.w	#$4000,d6
.noSign16
	tst.w	d6
	bmi	.notPlus16
	neg.w	d6
.notPlus16
	ext.l	d6
	cmp.l	d6,d2
	blt	.notNew16
	move.l	d6,d2
.notNew16
	subq.l	#2,d0
	bgt	autoAmplify16

; largest value in d2 (word as a negative)

	move.l	#-3276700,d3	; 2^15 * 100
	divs	d2,d3
	move.w	d3,amplifyPercentage


autoAmplifyGo
	bsr	amplifyBegin

	move.w	(sp)+,amplifyPercentage

autoAmplifyDone
	graf_mouse	#0,#0
	rts
;-----------------------------------------------------------------
autoAmplifyD2D
	lea	sampleInfoTable,a3
	move.l	blockSize,d1
	lea	.autoAmplifyD2DGo,a4

	clr.w	amplifyD2DMax
	moveq.w	#1,d0
	bsr	generalD2DOperation

	cmpi.w	#16,sampleResolution(a3)
	beq	.set16
; largest value in d2 (word as a negative)

	move.l	#-12800,d3	; 2^7 * 100
	move.w	amplifyD2DMax,d2
	divs	d2,d3
	move.w	d3,amplifyPercentage
	graf_mouse	#0,#0
	bra	autoAmplifyGo

; largest value in d2 (word as a negative)
.set16
	move.l	#-3276700,d3	; 2^15 * 100
	move.w	amplifyD2DMax,d2
	divs	d2,d3
	move.w	d3,amplifyPercentage
	graf_mouse	#0,#0
	bra	autoAmplifyGo

.autoAmplifyD2DGo
	cmpi.w	#16,sampleResolution(a3)
	beq	.autoD2D16
.autoD2D8
	move.b	(a0)+,d6
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign8
	eor.b	#$80,d6
.noSign8
	tst.b	d6
	bmi	.notPlus8
	neg.b	d6
.notPlus8
	ext.w	d6
	cmp.w	amplifyD2DMax,d6
	bgt	.notNew8
	move.w	d6,amplifyD2DMax
.notNew8
	subq.l	#1,d0
	bgt	.autoD2D8

	rts

.autoD2D16
	move.w	(a0)+,d6
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign16
	eor.w	#$4000,d6
.noSign16
	tst.w	d6
	bmi	.notPlus16
	neg.w	d6
.notPlus16
	ext.l	d6
	cmp.l	amplifyD2DMax,d6
	bgt	.notNew16
	move.l	d6,amplifyD2DMax
.notNew16
	subq.l	#2,d0
	bgt	.autoD2D16

	rts
;-----------------------------------------------------------------
amplifyApply
	bsr	selectObject
amplifyBegin
	graf_mouse	#2,#0

	lea	sampleInfoTable,a3
	tst.w	sampleLoaded(a3)
	beq	amplifyFinished

	move.w	amplifyPercentage,d0
	move.w	d0,amplifyPercentage2

	tst.w	sampleMode(a3)
	bne	amplifyD2DBegin

	move.l	sampleAddress(a3),a0
	add.l	blockStart,a0
	move.l	blockSize,d0
	lea	amplify8,a1
	cmpi.w	#16,sampleResolution(a3)
	bne	.not16
	lea	amplify16,a1
.not16
	jmp	(a1)

amplify8
	move.w	amplifyPercentage,d2
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign8
	eor.b	#$80,(a0)
.noSign8
	move.b	(a0),d6
	ext.w	d6
	ext.l	d6
	muls	d2,d6
	divs	#100,d6
	cmpi.w	#127,d6
	blt	.noFix8
	move.w	#127,d6
	bra	.noFix82
.noFix8
	cmpi.w	#-127,d6
	bgt	.noFix82
	move.w	#-127,d6
.noFix82
	move.b	d6,(a0)+
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign82
	eor.b	#$80,-1(a0)
.noSign82
	cmpi.w	#2,sampleChannels(a3)
	bne	.notStereo8
	move.w	amplifyPercentage2,d6
	move.w	amplifyPercentage,d7
	move.w	d6,amplifyPercentage
	move.w	d7,amplifyPercentage2
	eor.w	#1,amplifyPercentageW
.notStereo8
	subq.l	#1,d0
	bgt	amplify8
	bra	amplifyFinished

amplify16
	move.w	amplifyPercentage,d2
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign16
	eor.w	#$4000,(a0)
.noSign16
	move.w	(a0),d6
	ext.l	d6
	moveq.l	#1,d5
	tst.l	d6
	bpl	.positive16
	moveq.l	#-1,d5
.positive16
	muls	d2,d6
	divs	#100,d6
	bvc	.noFix16
	move.w	#32767,d6
	tst.l	d5
	bpl	.noFix16
	neg.w	d6
.noFix16
	move.w	d6,(a0)+
	cmpi.w	#1,sampleSigned(a3)
	beq	.noSign162
	eor.w	#$4000,-2(a0)
.noSign162
	cmpi.w	#2,sampleChannels(a3)
	bne	.notStereo16
	move.w	amplifyPercentage2,d6
	move.w	amplifyPercentage,d7
	move.w	d6,amplifyPercentage
	move.w	d7,amplifyPercentage2
	eor.w	#1,amplifyPercentageW
.notStereo16
	subq.l	#2,d0
	bgt	amplify16

amplifyFinished
	tst.w	amplifyPercentageW	; not really needed
	beq	.ampPCorrect	; as a stereo sample is always
	move.w	amplifyPercentage2,d6	; an even length
	move.w	amplifyPercentage,d7	; then amplifyPercentage
	move.w	d6,amplifyPercentage	; will always be the
	move.w	d7,amplifyPercentage2	; left channel when
	eor.w	#1,amplifyPercentageW	; amplify has finished
.ampPCorrect
	tst.w	sampleMode(a3)
	bne	.amplifyDone

	tst.w	fadeFlag
	bne	.amplifyDone

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

	graf_mouse	#0,#0

.amplifyDone
	rts
;-----------------------------------------------------------------
amplifyD2DBegin
	lea	sampleInfoTable,a3

	lea	amplify8,a4
	
	cmpi.w	#16,sampleResolution(a3)
	bne	.d2dAmplifySet

	lea	amplify16,a4
.d2dAmplifySet
	moveq.w	#0,d0
	bsr	generalD2DOperation

	tst.w	fadeFlag
	bne	.amplifyDone

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

	graf_mouse	#0,#0
.amplifyDone
	rts
;-----------------------------------------------------------------
amplifyBar
	move.w	d2,amplifyPercentage

	bsr	amplifyVolumeDisplay

	rts
;------------------------------------------------------------------
amplifyMinus
	bsr	selectObject
	subq.w	#1,amplifyPercentage
	bpl	.ok
	clr.w	amplifyPercentage
	rts
.ok
	bsr	amplifyVolumeDisplay

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d5
	move.l	dialogResource(a0),a0
	objc_offset	#AMPLIFYHIDDEN,a0
	move.l	#AMPLIFYHIDDEN*24,d0
	add.l	d0,a0

	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	move.w	d5,d0
	bsr	generalRedrawHandler

	rts
;-----------------------------------------------------------------
amplifyPlus
	bsr	selectObject
	addq.w	#1,amplifyPercentage
	cmpi.w	#200,amplifyPercentage
	ble	.ok
	move.w	#200,amplifyPercentage
	rts
.ok
	bsr	amplifyVolumeDisplay

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d5
	move.l	dialogResource(a0),a0
	objc_offset	#AMPLIFYHIDDEN,a0
	move.l	#AMPLIFYHIDDEN*24,d0
	add.l	d0,a0

	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	move.w	d5,d0
	bsr	generalRedrawHandler

	rts
;-----------------------------------------------------------------
amplifyRedraw
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0

	objc_offset	#AMPLIFYBAR,a0
	movem.w	intout+2,d1-d2

	add.l	#AMPLIFYBAR*24,a0

	move.w	amplifyPercentage,d3
	move.w	objectH(a0),d4

	bsr	hcbRedraw

	movem.l	(sp)+,d0-d7/a0-a6
	rts
;-----------------------------------------------------------------
amplifyVolumeDisplay
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0

	move.l	#AMPPERCENT*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0

	move.w	amplifyPercentage,d2
	ext.l	d2
	str	d2,a0

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	move.l	dialogResource(a0),a1
	move.l	#AMPPERCENT*24,d1
	add.l	d1,a1

	objc_offset	#AMPPERCENT,dialogResource(a0)
	
	movem.w	intout+2,d1-d2
	move.w	objectW(a1),d3
	move.w	objectH(a1),d4
	bsr	redrawDialog

	rts
;------------------------------------------------------------------
	SECTION	bss
amplifyPercentage	ds.w	1
amplifyPercentage2	ds.w	1
amplifyPercentageW	ds.w	1
amplifyD2DMax	ds.w	1