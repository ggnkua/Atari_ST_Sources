	SECTION	text
clearBuffer

	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	.clearDone

	tst.w	sampleSaveStatus(a3)
	beq	.performClear

	rsrc_gaddr	#5,#CLEAR
	form_alert	#1,addrout

	move.w	intout,d0

	cmpi.w	#3,d0
	beq	.clearDone
	cmpi.w	#2,d0
	beq	.performClear

	bsr	saveFile

.performClear
	m_free	sampleAddress(a3)
	clr.w	sampleLoaded(a3)

	clr.w	redrawCached

	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
; set info line to null
	rsrc_gaddr	#5,#NULLSTRING
	move.l	addrout,intin+4
	wind_set	mainWindowHandle,#3

.clearDone
	rts