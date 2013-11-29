;//////////////////////
;// Resample routine //
;//////////////////////
	SECTION	text
resampleSample
	rts

; the object that caused the return is in d0
.return
	cmpi.w	#DORESAMPLE,d0
	beq	resample

	cmpi.w	#CANCELRESAMPLE,d0
	beq	.done

	jsr	selectObject

	cmpi.w	#RESETORIGINAL,d0
	beq	setOriginal

	cmpi.w	#HALFFREQ,d0
	beq	setHalf
	cmpi.w	#THIRDFREQ,d0
	beq	setThirdFifth
	cmpi.w	#FIFTHFREQ,d0
	beq	setThirdFifth

	cmpi.w	#DOUBLEFREQ,d0
	beq	setDouble
	cmpi.w	#TREBBLEFREQ,d0
	beq	setTrebbleQuint
	cmpi.w	#QUINTFREQ,d0
	beq	setTrebbleQuint

.done
	rts
;-----------------------------------------------------------------------
setOriginal
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0		; points to text

	lea	sampleInfoTable,a3

	str	sampleFrequency(a3),a0

; redraw orig. freq display

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	#ORIGINALFREQ,a1
	movem.w	intout+2,d1-d2

	move.l	#ORIGINALFREQ*24,d1
	add.l	d0,a1
	add.w	objectW(a1),d3
	add.w	objectH(a1),d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	move.w	dialogHandle(a0),d0
	jsr	generalRedrawHandler

; is orignal freq display the current editable object?
	move.w	#ORIGINALFREQ,d0
	cmp.w	current,d0
	bne	.done

; it is so remove the cursor
	objc_edit	d0,#0,objectTextCursor,#3,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.done
	rts
;-----------------------------------------------------------------------
setHalf
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a3

	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	val	a0

	asr.l	#1,d0

	move.l	#NEWFREQ*24,d1
	add.l	d1,a3
	move.l	objectSpec(a3),a3
	move.l	(a3),a3

	str	d0,a3

; redraw new freq display

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	#NEWFREQ,a1
	movem.w	intout+2,d1-d2

	move.l	#NEWFREQ*24,d1
	add.l	d0,a1
	add.w	objectW(a1),d3
	add.w	objectH(a1),d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	move.w	dialogHandle(a0),d0
	jsr	generalRedrawHandler

; is orignal freq display the current editable object?
	move.w	#NEWFREQ,d0
	cmp.w	current,d0
	bne	.done

; it is so remove the cursor
	objc_edit	d0,#0,objectTextCursor,#3,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.done

	rts
;-----------------------------------------------------------------------
setThirdFifth
	move.w	d0,d4
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a3

	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	val	a0

	move.l	d0,d1
	moveq.l	#3,d0

	cmpi.w	#FIFTHFREQ,d4
	bne	.ok
	moveq.l	#5,d0
.ok
	jsr	long_div

	move.l	#NEWFREQ*24,d1
	add.l	d1,a3
	move.l	objectSpec(a3),a3
	move.l	(a3),a3

	str	d0,a3

; redraw new freq display

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	#NEWFREQ,a1
	movem.w	intout+2,d1-d2

	move.l	#NEWFREQ*24,d1
	add.l	d0,a1
	add.w	objectW(a1),d3
	add.w	objectH(a1),d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	move.w	dialogHandle(a0),d0
	jsr	generalRedrawHandler

; is orignal freq display the current editable object?
	move.w	#NEWFREQ,d0
	cmp.w	current,d0
	bne	.done

; it is so remove the cursor
	objc_edit	d0,#0,objectTextCursor,#3,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.done

	rts
;-----------------------------------------------------------------------
setDouble
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a3

	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	val	a0

	asl.l	#1,d0

	cmpi.l	#99999,d0
	blt	.fine

	asr.l	#1,d0	; reset

.fine
	move.l	#NEWFREQ*24,d1
	add.l	d1,a3
	move.l	objectSpec(a3),a3
	move.l	(a3),a3

	str	d0,a3

; redraw new freq display

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	#NEWFREQ,a1
	movem.w	intout+2,d1-d2

	move.l	#NEWFREQ*24,d1
	add.l	d0,a1
	add.w	objectW(a1),d3
	add.w	objectH(a1),d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	move.w	dialogHandle(a0),d0
	jsr	generalRedrawHandler

; is orignal freq display the current editable object?
	move.w	#NEWFREQ,d0
	cmp.w	current,d0
	bne	.done

; it is so remove the cursor
	objc_edit	d0,#0,objectTextCursor,#3,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.done

	rts
;-----------------------------------------------------------------------
setTrebbleQuint
	move.w	d0,d4
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a3

	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	val	a0

	moveq.l	#3,d1
	cmpi.w	#QUINTFREQ,d4
	bne	.ok
	moveq.l	#5,d1
.ok
	move.l	d1,d2
	jsr	long_mul

	cmpi.l	#99999,d0
	blt	.fine

	move.l	d2,d1
	exg	d0,d1
	jsr	long_div	; reset
.fine
	move.l	#NEWFREQ*24,d1
	add.l	d1,a3
	move.l	objectSpec(a3),a3
	move.l	(a3),a3

	str	d0,a3

; redraw new freq display

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1

	objc_offset	#NEWFREQ,a1
	movem.w	intout+2,d1-d2

	move.l	#NEWFREQ*24,d1
	add.l	d0,a1
	add.w	objectW(a1),d3
	add.w	objectH(a1),d4

	add.w	d1,d3
	add.w	d2,d4
	subq.w	#1,d3
	subq.w	#1,d4

	move.w	dialogHandle(a0),d0
	jsr	generalRedrawHandler

; is orignal freq display the current editable object?
	move.w	#NEWFREQ,d0
	cmp.w	current,d0
	bne	.done

; it is so remove the cursor
	objc_edit	d0,#0,objectTextCursor,#3,dialogResource(a0)
	move.w	intout+2,objectTextCursor
.done

	rts
;-----------------------------------------------------------------------
resample
	graf_mouse	#2,#0

; get the specified orig. frequency
	move.l	dialogTableAddress,a3
	move.l	dialogResource(a3),a1
	move.l	#ORIGINALFREQ*24,d0
	add.l	d0,a1
	move.l	objectSpec(a1),a1
	move.l	(a1),a1		; points to text

	val	a1
	move.l	d0,d2

; get the new frequency
	move.l	dialogResource(a3),a1
	move.l	#NEWFREQ*24,d1
	add.l	d1,a1
	move.l	objectSpec(a1),a1
	move.l	(a1),a1		; points to text

	val	a1
	move.l	d0,d3

	lea	sampleInfoTable,a3
	move.l	sampleAddress(a3),a0
	move.l	a0,a1
	move.l	sampleDataSize(a3),d5
; calc % resample

	move.l	#1000,d0
	move.l	d2,d1
	jsr	long_mul

	move.l	d3,d1
	exg	d1,d0
	jsr	long_div
	move.l	d0,d1	; value
	move.l	#0,d0
	move.l	#0,d6	; counter

; compress or interpolate sample?
	cmpi.l	#1000,d1		; up or down?
	blt	resampleGreater	; interpolate

** resample Less **	d2 original   d3 new
;		d1 = % value d0 = new length (0)
;----------------------------------------------------------------------------
	tst.w	sampleMode(a3)
	bne	resampleLessD2D

resampleLess
	cmpi.w	#16,sampleResolution(a3)
	beq	.stepDn16
;----------------------------------------------------------------------------
.stepDn	moveq	#0,d4
	add.l	d1,d6		; counter+factor
	move.b	(a0),d4
.nextDn	addq.l	#1,a0
	subq.l	#1,d5		; original length
	ble	.last
	subi.l	#1000,d6
	bgt.s	.nextDn
.last
	move.b	d4,(a1)+
	addq.l	#1,d0		; INC newlen%
	tst.l	d5
	bgt.s	.stepDn
	bra	resampleDone
;----------------------------------------------------------------------------
.stepDn16	moveq	#0,d4
	add.l	d1,d6		; counter+factor
	move.w	(a0),d4
.nextDn16	addq.l	#2,a0
	subq.l	#2,d5		; original length
	ble	.last16
	subi.l	#1000,d6
	bgt.s	.nextDn16
.last16
	move.w	d4,(a1)+
	addq.l	#2,d0		; INC newlen%
	tst.l	d5
	bgt.s	.stepDn16
;----------------------------------------------------------------------------
resampleDone
	move.l	d0,sampleDataSize(a3)
	move.l	d3,sampleFrequency(a3)
	m_shrink	d0,sampleAddress(a3)

	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)
	clr.l	blockStart
	move.l	sampleDataSize(a3),d0
	move.l	d0,blockEnd
	move.l	d0,blockSize
	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	jsr	enterSampleInfo

	graf_mouse	#0,#0
	rts
;----------------------------------------------------------------------------
resampleGreater
	tst.w	sampleMode(a3)
	bne	resampleGreaterD2D

	movem.l	d1-d7/a0-a6,-(sp)

	move.w	sampleChannels(a3),d0
	ext.l	d0
	move.l	sampleFrequency(a3),d1
	jsr	long_mul
	move.w	sampleResolution(a3),d1
	ror.w	#3,d1
	ext.l	d1
	move.l	d1,d2
	jsr	long_mul
	move.l	d5,d1
	jsr	long_div
	addq.l	#1,d0

	move.l	d0,d4

	move.l	d3,d1
	move.w	sampleChannels(a3),d0
	jsr	long_mul
	move.l	d2,d1
	jsr	long_mul
	move.l	d4,d1
	jsr	long_mul

	m_xalloc	#0,d0

	movem.l	(sp)+,d1-d7/a0-a6

	tst.l	d0
	beq	.noMemory

	move.l	d0,a1
	move.l	d0,sampleAddress(a3)
	move.l	#0,d0

	cmpi.w	#16,sampleResolution(a3)
	beq	.nextUp16
;----------------------------------------------------------------------------
.nextUp	move.b	(a0),(a1)+
	addq.l	#1,d0		; INC newlen%
	add.w	d1,d6		; counter+factor
	cmpi.w	#1000,d6
	blt.s	.nextUp
	subi.w	#1000,d6
	addq.l	#1,a0		; INC src%
	subq.l	#1,d5
	bgt.s	.nextUp
	bra	resampleDone
;----------------------------------------------------------------------------
.nextUp16	move.w	(a0),(a1)+
	addq.l	#2,d0		; INC newlen%
	add.w	d1,d6		; counter+factor
	cmpi.w	#1000,d6
	blt.s	.nextUp16
	subi.w	#1000,d6
	addq.l	#2,a0		; INC src%
	subq.l	#2,d5
	bgt.s	.nextUp16
	bra	resampleDone
;----------------------------------------------------------------------------
.noMemory
	rsrc_gaddr	#5,#OUTOFMEMORY
	form_alert	#1,addrout
	graf_mouse	#0,#0
	rts
;----------------------------------------------------------------------------
resampleLessD2D
	rts
;----------------------------------------------------------------------------
resampleGreaterD2D
	rts
;----------------------------------------------------------------------------