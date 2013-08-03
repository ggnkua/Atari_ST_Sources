	SECTION	text
create
	displayDialog	#CREATE,#16395,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#CREATETITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	bsr	newTypeWindow

	rts

; the object that caused the return is in d0
.return
	cmpi.w	#CREATENEW,d0
	beq	doCreate

	cmpi.w	#NEWTYPESLIDER,d0
	beq	createSampleSlider
	cmpi.w	#NEWTYPESCROLL,d0
	beq	createSampleSlider

	cmpi.w	#CANCELNEW,d0
	beq	.done

	bsr	selectObject
	cmpi.w	#UPNEWSLOT,d0
	beq	upNewSlot
	cmpi.w	#DOWNNEWSLOT,d0
	beq	downNewSlot

.done
	rts
;--------------------------------------------------------------------------
doCreate
	graf_mouse	#2,#0

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0

; which type of file to create?
	move.l	a0,a1
	move.l	#NEWSLOT1*24,d0
	add.l	d0,a1
	move.w	#NEW_SLOTS-1,d0
.loop
	move.w	objectStatus(a1),d1
	andi.w	#1,d1
	bne	.typeFound
	add.l	#objectSize,a1
	dbra	d0,.loop
** error no type found! **
	bra	quitRoutine	; fatal
.typeFound
	move.l	objectSpec(a1),a4
	cmp.l	#emptySlot,a4
	bne	.notEmpty
	lea	rawModuleInfo,a4
	move.l	moduleId(a4),a4
.notEmpty	; a4 points at string of module name

	lea	sampleInfoTable,a3
	move.l	a0,a1
	move.l	a0,a2
	move.l	#CREATEFREQUENCY*24,d0
	add.l	d0,a1
	move.l	objectSpec(a1),a1
	move.l	(a1),a1		; address of text in a1

	val	a1	; value returned in d0 (long)
	move.l	d0,sampleFrequency(a3)

	move.l	a2,a0
	move.l	a0,a1
	move.l	#CREATEMONO*24,d1
	add.l	d1,a1
	move.w	objectStatus(a1),d1
	andi.w	#1,d1	; 1 if selected 0 if not
	eor.w	#1,d1	; invert above
	addq.w	#1,d1	; make 1 or 2 for the multiplier
	ext.l	d1	; (mono or stereo)
	move.w	d1,sampleChannels(a3)

	move.l	#CREATE8BIT*24,d2
	add.l	d2,a0
	move.w	objectStatus(a0),d2
	andi.w	#1,d2	; 1 if selected 0 if not
	eor.w	#1,d2	; invert the above
	addq.w	#1,d2	; make 1 or 2 for the multiplier
	ext.l	d2	; (8 or 16 bit)
	move.l	d2,d3
	rol.w	#3,d3
	move.w	d3,sampleResolution(a3)
	move.w	#1,sampleSigned(a3)

	mulu	d2,d1
	bsr	long_mul

	move.l	a2,a1
	move.l	#CREATESECONDS*24,d1
	add.l	d1,a1
	move.l	objectSpec(a1),a1
	move.l	(a1),a1		; address of text in a1

	move.l	d0,-(sp)
	val	a1	; value returned in d0 (long)
	move.l	(sp)+,d1
	exg	d1,d0
	bsr	long_mul

; d0 holds memory needed for buffer

	tst.l	d0	; must be 0 if freq/sec was 0 or not entered
	beq	cancelCreate

	move.l	a2,a0
	move.l	#CREATEDISK*24,d1
	add.l	d1,a0
	move.w	objectStatus(a0),d1
	andi.w	#1,d1

;  d0 = size required   , d1 = type disk or mem

	lea	sampleInfoTable,a3
	tst.w	sampleLoaded(a3)
	beq	.createCheck

; sample loaded so inquire what to do now. 
	rsrc_gaddr	#5,#CLEAR
	form_alert	#1,addrout
	
	cmpi.w	#3,intout
	beq	createDone
	cmpi.w	#2,intout
	beq	.eraseOld

	bsr	saveFile
.eraseOld
	movem.l	d0-d1,-(sp)
	m_free	sampleAddress(a3)
	movem.l	(sp)+,d0-d1
; the sample in memory will no be cleared so procede with the create

.createCheck
	move.w	#1,sampleLoaded(a3)	; set info
	move.l	d0,sampleDataSize(a3)
	clr.w	sampleMode(a3)
	clr.l	blockStart
	move.l	d0,blockSize
	lea	blockArea,a0
	clr.w	blockDefined(a0)
	clr.w	redrawCached

	tst.w	d1	; create 2 disk?
	bne	createDisk
*************
; Determine Module for format address of id in a4
	move.l	a4,a0
	bsr	locateModuleId
	move.l	(a0),sampleModuleAddress(a3)
; create the header
	movem.l	d0-d7/a0-a6,-(sp)
	callModule	#4
	movem.l	(sp)+,d0-d7/a0-a6

	m_xalloc	#0,d0

	tst.l	d0
	beq	.notDone
	
	move.l	d0,sampleAddress(a3)
	bsr	enterSampleInfo
	bsr	deleteBlock
	bra	createDone
.notDone
	rsrc_gaddr	#5,#OUTOFMEMORY
	form_alert	#1,addrout
	clr.w	sampleLoaded(a3)
createDone
	graf_mouse	#0,#0

	move.w	mainWindowHandle,d0
	wind_get	#4,d0
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler
	
	rts
;-----------------------------------------------------------------------
createDisk
	move.w	#1,sampleMode(a3)
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
	rsrc_gaddr	#5,#CREATEFILE
	fsel_exinput	#samplePath,#defaultFile,addrout

.fileSelected
	tst.w	intout
	beq	createDone

	tst.w	intout+2
	beq	createDone

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

	lea	optionsTable,a0
	move.w	optionD2DSize(a0),d0
	beq	cantCreateNoD2D
	tst.l	D2DBuffer
	beq	cantCreateNoD2D

	ext.l	d0
	move.l	#1024,d1
	bsr	long_mul

	lea	sampleInfoTable,a3
	move.l	sampleDataSize(a3),d1
; d0 holds D2D buffer size in bytes
; d1 holds required filesize

	bsr	clearD2DBuffer
	move.l	d0,d2
	move.l	d1,d3
; create the file

	move.l	d2,-(sp)
	f_create	#0,#samplePath
	move.l	(sp)+,d2
	move.w	d0,d4
; write the header
	lea	sampleInfoTable,a3
; Determine Module for format address of id in a4
	move.l	a4,a0
	bsr	locateModuleId
	move.l	(a0),sampleModuleAddress(a3)
; create the header
	movem.l	d2-d4/a3,-(sp)
	callModule	#4
	movem.l	(sp)+,d2-d4/a3

	tst.w	sampleHeaderSize(a3)
	beq	.writeFile
	move.l	d2,-(sp)
	move.w	sampleHeaderSize(a3),d2
	ext.l	d2
	f_write	#sampleHeader,d2,d4
	move.l	(sp)+,d2
.writeFile
	cmp.l	d2,d3
	bgt	.noSizeAlter
	move.l	d3,d2
.noSizeAlter
	movem.l	d1-d2/a0-a2,-(sp)
	f_write	D2DBuffer,d2,d4
	movem.l	(sp)+,d1-d2/a0-a2
	cmp.l	d2,d0
	bne	createDiskFull

	sub.l	d2,d3
	bgt	.writeFile

	f_close	d4
	move.w	#1,sampleLoaded(a3)
	bsr	enterSampleInfo
	move.w	#1,sampleMode(a3)

	bra	createDone
;-----------------------------------------------------------------------
cancelCreate
	rsrc_gaddr	#5,#CANTCREATE
	form_alert	#1,addrout

cantCreate
	move.l	dialogTableAddress,a0
	wind_close	dialogHandle(a0)
	wind_delete	dialogHandle(a0)
	clr.w	dialogHandle(a0)

	graf_mouse	#0,#0

	rts
;-----------------------------------------------------------------------
cantCreateNoD2D
	rsrc_gaddr	#5,#NOD2D
	form_alert	#1,addrout

	move.l	(sp)+,d1
	bra	cantCreate
;-----------------------------------------------------------------------
createDiskFull

	rsrc_gaddr	#5,#CREATEDISKFULL
	form_alert	#1,addrout

	f_delete	#samplePath

	bra	cantCreate
;-----------------------------------------------------------------------
newTypeWindow
	movem.l	d0-d7/a0-a6,-(sp)

; find % number of modules that can be displayed in the window

	move.l	#NEW_SLOTS*100,d1
	move.w	numberOfModules,d0
	addq.w	#1,d0	; +1 for data module
	ext.l	d0
	bsr	long_div

; if > 100 then all can be displayed so set to 100

	cmpi.l	#100,d0
	ble	.percentFound

	move.l	#100,d0
.percentFound

; d0 now holds % height that NEWTYPESLIDER needs to be in comparison
; with NEWTYPESCROLL

; find height of scroll bar (NEWTYPESCROLL)
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.l	#NEWTYPESCROLL*24,d1
	add.l	d1,a1
	move.w	objectH(a1),d1
	ext.l	d1

; multiply % and height of NEWTYPESCROLL
	bsr	long_mul
; / by 100
	move.l	#100,d1
	exg	d0,d1
	bsr	long_div

; height of NEWTYPESLIDER in d0
	move.l	a0,a1
	move.l	#NEWTYPESLIDER*24,d1
	add.l	d1,a1
	move.w	d0,objectH(a1)

; now fill in the slot entries
	move.w	#0,firstSlot
	bsr	newSlotEntry

	movem.l	(sp)+,d0-d7/a0-a6

	rts
;-----------------------------------------------------------------------
newSlotEntry
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a1	; a0 holds dialogResource

	move.l	#NEWSLOT1*24,d0
	add.l	d0,a1
; a1 points at first slot in resource

	move.w	firstSlot,d0
	ext.l	d0
	move.l	#moduleSize,d1
	bsr	long_mul

	move.w	numberOfModules,d2
	sub.w	firstSlot,d2
	move.w	#NEW_SLOTS-1,d3
; d0 holds offset in module table of first module to show in window
	lea	rawModuleInfo,a2	; raw to include Data module
	add.l	#moduleId,d0
	add.l	d0,a2

; set null slot contents
	move.l	#emptySlot,nullSlot

; loop round filling in the slots
.loop
	move.l	(a2),objectSpec(a1)
	add.l	#objectSize,a1
	subq.w	#1,d2
	bge	.stillModules
	lea	nullSlot,a2	; no more modules so put -- line in slot
	dbra	d3,.loop
	bra	.done
.stillModules
	add.l	#moduleSize,a2	; more module so advance
	dbra	d3,.loop		; module address

.done
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;-----------------------------------------------------------------------
createSampleSlider	; 1000th value in d2
	ext.l	d2
	move.w	numberOfModules,d0
	sub.w	#NEW_SLOTS-1,d0
	move.l	d2,d1
	ext.l	d0
	bsr	long_mul
	move.l	#1000,d1
	exg	d1,d0
	bsr	long_div
	tst.l	d2
	bne	.noZero
	moveq.w	#0,d0
.noZero
	move.w	d0,firstSlot

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	bsr	newSlotEntry
	bsr	redrawModuleList

	rts
;-----------------------------------------------------------------------
positionCreateSlider
	movem.l	d0-d7/a0-a6,-(sp)

	clr.l	d0
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.l	a1,a2

	move.w	firstSlot,d0
	beq	.set
	addq.w	#1,d0
	move.w	#1000,d1
	jsr	long_mul
	move.w	numberOfModules,d1
	addq.w	#1,d1
	exg	d1,d0
	jsr	long_div

	move.l	#NEWTYPESCROLL*24,d1
	add.l	d1,a0
	move.w	objectH(a0),d1
	ext.l	d1
	jsr	long_mul
	move.l	#1000,d1
	exg	d1,d0
	jsr	long_div

	move.w	numberOfModules,d1
	addq.w	#1,d1
	ext.l	d1
	sub.l	d1,d0
.set
	move.l	#NEWTYPESLIDER*24,d1
	add.l	d1,a1
	move.w	d0,objectY(a1)

; redraw the slider
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a2
	move.l	#NEWTYPESCROLL*24,d0
	add.l	d0,a0
	objc_offset	#NEWTYPESCROLL,a2
	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#4,d3
	addq.w	#4,d4
	bsr	redrawDialog
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;--------------------------------------------------------------------------
upNewSlot
	move.w	firstSlot,d0
	beq	.done
	subq.w	#1,d0
	bge	.greater
	moveq.w	#0,d0
.greater
	move.w	d0,firstSlot
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	bsr	newSlotEntry
	bsr	redrawModuleList
	bsr	positionCreateSlider
; mouse button still held?
.done
	evnt_timer	#250,#0
	graf_mkstate
	move.w	intout+6,d0
	andi.w	#1,d0
	bne	upNewSlot
	move.w	#UPNEWSLOT,d0
	bsr	selectObject
	rts
;--------------------------------------------------------------------------
downNewSlot
	move.w	numberOfModules,d1
	cmpi.w	#7,d1
	blt	.done	; lt due to data module not included in count
	move.w	firstSlot,d0
	addq.w	#1,d0
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#7,d1
	bge	.greater	; gt as above
	subq.w	#NEW_SLOTS-1,d2
	move.w	d2,d0
.greater
	move.w	d0,firstSlot
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	bsr	newSlotEntry
	bsr	redrawModuleList
	bsr	positionCreateSlider
; mouse button still held?
.done
	evnt_timer	#250,#0
	graf_mkstate
	move.w	intout+6,d0
	andi.w	#1,d0
	bne	downNewSlot
	move.w	#DOWNNEWSLOT,d0
	bsr	selectObject
	rts
;--------------------------------------------------------------------------
redrawModuleList	; resource address in a0
	objc_offset	#CREATEMODLIST,a0
	move.w	#CREATEMODLIST*24,d0
	add.l	d0,a0

	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	bsr	redrawDialog
	rts
;--------------------------------------------------------------------------
NEW_SLOTS	equ	7
	SECTION	bss

firstSlot	ds.w	1
nullSlot	ds.l	1
	SECTION	data
emptySlot	dc.b	'------',0