	SECTION	text

openFile
	move.w	d0,d7	; menu item which selected open
	lea	sampleInfoTable,a0

	tst.w	sampleLoaded(a0)
	bne	confirmLoad

	tst.w	vaStart	; open called by VA_START?
	bne	.vaStarted

	clr.w	defaultFile
	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a0
	add.l	d1,a0
	stringTruncate	a0,#'\'

	cmpi.w	#$140,aesVersion
	bgt	.extended

	fsel_input	#samplePath,#defaultFile
	bra	.fileSelected

.extended
	rsrc_gaddr	#5,#OPENFILE
	fsel_exinput	#samplePath,#defaultFile,addrout

.fileSelected
	tst.w	intout
	beq	.openDone

	tst.w	intout+2
	beq	.openDone

	stringLength	#samplePath
	ext.l	d1
	lea	samplePath,a3
	add.l	d1,a3
	stringTruncate	a3,#'\'	
	lea	samplePath,a3
	stringLength	a3
	ext.l	d1
	add.l	d1,a3
	stringCopy	#defaultFile,a3
	clr.b	(a1)
.vaStarted
	bsr	loadHeader
	bsr	idSample

	tst.w	d0
	beq	.openDone	; aborted

	cmpi.w	#OPEND2D,d7
	beq	.d2d

	bsr	loadFile
.d2d
	bsr	enterSampleInfo

	lea	sampleInfoTable,a3

	move.l	sampleModuleAddress(a3),a4
	move.w	moduleProtocol(a4),sampleModuleFunctions(a3)
	move.l	a3,a4

	moveq.w	#0,d0
	cmpi.w	#OPEND2D,d7
	bne	.notD2D
	moveq.w	#1,d0

	tst.b	optionsTable+optionTempPath
	bne	.notD2D

	rsrc_gaddr	#5,#SETTEMP
	form_alert	#1,addrout
	clr.w	sampleLoaded(a3)
	bra	.openDone

.notD2D
	move.w	d0,sampleMode(a3)

	lea	samplePathname(a3),a3

	stringCopy	#samplePath,a3
	clr.b	(a1)

	clr.l	blockStart
	move.l	sampleDataSize(a4),d0
	move.l	d0,blockEnd
	move.l	d0,blockSize
	lea	blockArea,a0
	clr.l	blockX(a0)
	clr.l	blockX2(a0)
	clr.w	blockDefined(a0)

	move.w	#1,sampleLoaded(a4)
	clr.w	redrawCached
; force redraw
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler

; set info line to sample path
	lea	samplePathname(a4),a5
	move.l	a5,intin+4
	wind_set	mainWindowHandle,#3

	move.l	sampleModuleAddress(a4),d0
	cmp.l	#rawModule,d0
	bne	.openDone

	moveq.l	#0,d0
	bsr	alterSampleInfo

.openDone
	rts

;---------------------------------------------------------------

loadHeader	; file path+name in samplePath

	f_open	#0,#samplePath
	move.w	d0,d3

; read enough bytes to cover any file formats header

	f_read	#sampleHeader,#4096,d0
	move.w	d3,d0

; find file size

	f_close	d3

	f_sfirst	#%11111,#samplePath

	lea	sampleInfoTable,a1
	move.l	dta+26,sampleDataSize(a1)

	rts
;---------------------------------------------------------------

idSample	; find module to load sample with

	lea	moduleInformationTable,a0
	lea	sampleInfoTable,a1
	move.w	numberOfModules,d2
.loop
	move.l	moduleAddress(a0),d0
	beq	.allModulesChecked

	move.l	d0,sampleModuleAddress(a1)

	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#1
	movem.l	(sp)+,d1-d7/a0-a6

	tst.w	d0
	bne	.moduleFound

	add.l	#moduleSize,a0
	dbra	d2,.loop

.allModulesChecked	; no module for file format

	rsrc_gaddr	#5,#NOMODULE
	form_alert	#1,addrout

	moveq.w	#0,d0
	cmpi.w	#2,intout
	beq	.aborted

	moveq.w	#1,d0
	move.l	#rawModule,sampleModuleAddress(a1)
	move.w	#0,sampleHeaderSize(a1)

.aborted
	rts

.moduleFound
	moveq.w	#1,d0	; 1 = continue
	rts

;---------------------------------------------------------------

loadFile
	lea	sampleInfoTable,a3

	m_xalloc	#0,sampleDataSize(a3)
	moveq.w	#1,d1	; out of mem error code
	tst.l	d0
	beq	cantLoadError

	move.l	d0,sampleAddress(a3)

	f_open	#0,#samplePath
	move.w	d0,d3
	move.w	sampleHeaderSize(a3),d0
	ext.l	d0
	f_seek	#0,d3,d0
	move.w	d3,d0
	f_read	sampleAddress(a3),sampleDataSize(a3),d0
	f_close	d3

; process loaded data (call module)

	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#2
	movem.l	(sp)+,d1-d7/a0-a6

; set playback freq

	bsr	setPlaybackFreq

	rts

;---------------------------------------------------------------
confirmLoad
	clr.w	sampleLoaded(a0)
	
	m_free	sampleAddress(a0)

	bra	openFile
;---------------------------------------------------------------
	SECTION	bss
sampleHeader	ds.b	4096
samplePath	ds.b	256
vaStart	ds.w	1