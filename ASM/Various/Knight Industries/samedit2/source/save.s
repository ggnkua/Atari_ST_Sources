	SECTION	text
saveFile
	lea	sampleInfoTable,a3
	add.l	#samplePathname,a3

	stringCopy	a3,#samplePath

doSaveFile
	movem.l	d0-d7/a0-a6,-(sp)
	lea	sampleInfoTable,a3

	tst.w	sampleLoaded(a3)
	beq	saveDone

; perform any processing

	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#3
	movem.l	(sp)+,d1-d7/a0-a6

; filename in samplePath

	f_create	#0,#samplePath
	move.w	d0,d3

	tst.w	sampleHeaderSize(a3)
	beq	headerSaved
saveHeader
; create the header
	movem.l	d1-d7/a0-a6,-(sp)
	callModule	#4
	movem.l	(sp)+,d1-d7/a0-a6

	move.w	sampleHeaderSize(a3),d4
	ext.l	d4

	f_write	#sampleHeader,d4,d3
headerSaved

; save sample data

	f_write	sampleAddress(a3),sampleDataSize(a3),d3

	f_close	d3

saveDone
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;--------------------------------------------------------------------
saveFileAs
	lea	sampleInfoTable,a0

	tst.w	sampleLoaded(a0)
	beq	.saveAsDone

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
	rsrc_gaddr	#5,#SAVEASFILE
	fsel_exinput	#samplePath,#defaultFile,addrout

.fileSelected
	tst.w	intout
	beq	.saveAsDone

	tst.w	intout+2
	beq	.saveAsDone

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

; does the file already exist?  Test by attempting to read file attributes

	f_attrib	#0,#0,#samplePath
	tst.w	d0
	bmi	.ok

	rsrc_gaddr	#5,#FILEEXISTS
	form_alert	#1,addrout

	cmpi.w	#1,intout
	bne	.saveAsDone
.ok
	bsr	doSaveFile
	rsrc_gaddr	#5,#USEAS
	form_alert	#1,addrout
	cmpi.w	#1,intout
	bne	.saveAsDone

	lea	sampleInfoTable,a3
	add.l	#samplePathname,a3
	stringCopy	#samplePath,a3

.saveAsDone
	rts