	SECTION	text
editOptions
	displayDialog	#OPTIONS,#16411,#.return

; set window title

	rsrc_gaddr	#5,#OPTIONSTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	dialogHandle(a0),#2

	clr.w	optionsState

	lea	optionsTable,a0
	move.w	optionSampleColour(a0),optionSColour
	move.w	optionBackground(a0),optionBColour

	add.l	#optionPath,a0
	stringCopy	a0,#defaultPath
	clr.b	(a1)

	stringCopy	#optionsTable+optionModulePath,#modulePath
	clr.b	(a1)

	stringCopy	#optionsTable+optionTempPath,#tempPath
	clr.b	(a1)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#SETD2DBUFFER*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	lea	optionsTable,a1
	move.w	optionD2DSize(a1),d0
	ext.l	d0
	str	d0,a0

	clr.w	defaultFile

	rts
;---------------------------------------------------------------------

; the object that caused the return is in d0
.return

	lea	optionsTable,a1

; was a colour clicked on?

	cmpi.w	#STARTCOLOUR,d0
	blt	.notAColour
	cmpi.w	#ENDCOLOUR,d0
	bgt	.notAColour

; is a colour suposed to be selected now?

	move.w	d0,d2
	subq.w	#STARTCOLOUR,d2

	cmpi.w	#1,optionsState
	beq	.setSampleColour
	cmpi.w	#2,optionsState
	beq	.setBackgroundColour
	bra	.colourfinished
.colourDone
	rsrc_gaddr	#5,#NULLSTRING
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	dialogHandle(a0),#3

.colourfinished
	clr.w	optionsState
	bsr	selectObject
	rts
;---------------------------------------------------------------------
.setSampleColour	; used to alter colour sample is displayed in
		; held in d2

	move.w	d2,optionSColour
	bra	.colourDone

.setBackgroundColour	; used to alter the background to the main window
		; held in d2

	move.w	d2,optionBColour
	bra	.colourDone
;---------------------------------------------------------------------
; If a colour was not clicked on this code is executed
.notAColour

	cmpi.w	#SETSAMPLECOLOUR,d0
	beq	.setState
	cmpi.w	#SETBACKGROUND,d0
	beq	.setState

	cmpi.w	#SETPATH,d0
	beq	.setDefaultPath
	cmpi.w	#SETTEMPPATH,d0
	beq	.setTempPath
	cmpi.w	#SETMODULEPATH,d0
	beq	.setModulePath

	cmpi.w	#OKSETTINGS,d0
	beq	.verifySettings
	cmpi.w	#APPLYSETTINGS,d0
	beq	.verifySettings

	rts
;---------------------------------------------------------------------
.setState	; used to prompt the user to select a colour for the sample
	; or the background

	rsrc_gaddr	#5,#SELECTCOLOUR
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	dialogHandle(a0),#3

	bsr	selectObject

	sub.w	#SETSAMPLECOLOUR,d0
	addq.w	#1,d0
	move.w	d0,optionsState

	rts
;---------------------------------------------------------------------
.setDefaultPath
	bsr	selectObject
	cmpi.w	#$140,aesVersion
	bgt	.extendedDefaultPath

	fsel_input	#defaultPath,#defaultFile
	bra	.defaultSetYet

.extendedDefaultPath
	rsrc_gaddr	#5,#DEFAULTPATH
	fsel_exinput	#defaultPath,#defaultFile,addrout

.defaultSetYet
	tst.w	intout
	beq	.defaultPathReset
	tst.w	intout+2
	beq	.defaultPathReset

	stringLength	#defaultPath
	lea	defaultPath,a0
	ext.l	d1
	add.l	d1,a0
	stringTruncate	a0,#'\'
	clr.w	defaultFile

	rts
.defaultPathReset
	lea	optionsTable,a0
	lea	optionPath(a0),a2
	stringCopy	a2,#defaultPath
	clr.b	(a1)

	clr.w	defaultFile
	rts
;---------------------------------------------------------------------
.setTempPath
	bsr	selectObject
	cmpi.w	#$140,aesVersion
	bgt	.extendedTempPath

	fsel_input	#tempPath,#defaultFile
	bra	.tempSetYet

.extendedTempPath
	rsrc_gaddr	#5,#TEMPPATH
	fsel_exinput	#tempPath,#defaultFile,addrout

.tempSetYet
	tst.w	intout
	beq	.tempPathReset
	tst.w	intout+2
	beq	.tempPathReset

	stringLength	#tempPath
	lea	tempPath,a0
	ext.l	d1
	add.l	d1,a0
	stringTruncate	a0,#'\'
	clr.w	defaultFile

	rts
.tempPathReset
	lea	optionsTable,a0
	lea	optionTempPath(a0),a2
	stringCopy	a2,#tempPath
	clr.b	(a1)

	clr.w	defaultFile
	rts
;---------------------------------------------------------------------
.setModulePath
	bsr	selectObject
	cmpi.w	#$140,aesVersion
	bgt	.extendedModulePath

	fsel_input	#modulePath,#defaultFile
	bra	.moduleSetYet

.extendedModulePath
	rsrc_gaddr	#5,#MODULEPATH
	fsel_exinput	#modulePath,#defaultFile,addrout

.moduleSetYet
	tst.w	intout
	beq	.modulePathReset
	tst.w	intout+2
	beq	.modulePathReset

	stringLength	#modulePath
	lea	modulePath,a0
	ext.l	d1
	add.l	d1,a0
	stringTruncate	a0,#'\'
	clr.w	defaultFile

	rts
.modulePathReset
	lea	optionsTable,a0
	lea	optionModulePath(a0),a2
	stringCopy	a2,#modulePath
	clr.b	(a1)

	clr.w	defaultFile
	rts
;---------------------------------------------------------------------
.verifySettings
	move.w	d0,-(sp)
	move.w	optionSColour,optionSampleColour(a1)
	move.w	optionBColour,optionBackground(a1)

	stringCopy	#defaultPath,#optionsTable
	clr.b	(a1)
	stringCopy	#modulePath,#optionsTable+optionModulePath	
	clr.b	(a1)
	stringCopy	#tempPath,#optionsTable+optionTempPath
	clr.b	(a1)

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#SETD2DBUFFER*24,d0
	add.l	d0,a0
	move.l	objectSpec(a0),a0
	move.l	(a0),a0

	val	a0

	lea	optionsTable,a0
	move.w	d0,optionD2DSize(a0)

	bsr	allocateD2DBuffer

	move.w	(sp)+,d0
	cmpi.w	#OKSETTINGS,d0
	beq	.settingsVerified

	bsr	selectObject

.settingsVerified
	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

; is the fade window open?

	rsrc_gaddr	#0,#FADE
	move.l	addrout,a2
	bsr	checkForDialog

	tst.l	dialogTableAddress
	beq	.settingsUpdated

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
.settingsUpdated
	rts

;---------------------------------------------------------------------
saveOptions
	f_delete	#infoPath
	f_create	#0,#infoPath
	move.w	d0,d3
	f_write	#optionsTable,#optionsSize,d0
	f_close	d3

	rts
;---------------------------------------------------------------------
loadOptions
; set correct path and filename for info file

	stringCopy	userDirectoryPath,#infoPath
	stringLength	#infoPath
	lea	infoPath,a2
	ext.l	d1
	add.l	d1,a2
	stringCopy	#infoFile,a2

	f_open	#0,#infoPath
	move.w	d0,d3
	f_read	#optionsTable,#optionsSize,d0
	f_close	d3

	lea	optionsTable,a3
	move.l	a3,a1
	add.l	#optionPath,a1

	stringCopy	a1,#samplePath
	clr.b	(a1)

	bsr	allocateD2DBuffer

	rts

;---------------------------------------------------------------------
	SECTION	data

infoFile	dc.b	'samedit2.inf',0

	SECTION	bss

infoPath	ds.b	256
optionsState	ds.w	1	; 0 = none
			; 1 = selecting sample colour
			; 2 = selecting background colour
	even
	rsreset
optionPath	rs.b	256
optionModulePath	rs.b	256
optionSampleColour	rs.b	2
optionBackground	rs.b	2
optionD2DSize	rs.b	2
optionMemLimit	rs.b	2
optionTempPath	rs.b	256
optionsSize	rs.b	0

optionsTable	ds.b	optionsSize

defaultPath	ds.b	256
defaultFile	ds.b	64
modulePath	ds.b	256
tempPath	ds.b	256
optionSColour	ds.w	1
optionBColour	ds.w	1