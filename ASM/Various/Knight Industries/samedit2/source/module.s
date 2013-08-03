	SECTION	text
loadModules

; get module path and begin search
	lea	optionsTable,a0
	add.l	#optionModulePath,a0
	stringCopy	a0,#modulePath
	stringLength	#modulePath
	lea	modulePath,a0
	ext.l	d1
	add.l	d1,a0
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'S',(a0)+
	move.b	#'E',(a0)+
	move.b	#'M',(a0)+
	clr.b	(a0)

	f_sfirst	#%11111,#modulePath
.loop
	tst.w	d0
	bmi	.allLoaded

	bsr	loadAndAllocateModule

	f_snext
	bra	.loop

.allLoaded
	bsr	.checkLoadedModules
.return
	bsr	enterRaw

	rts
;---------------------------------------------------------------
.checkLoadedModules
	tst.w	numberOfModules
	bne	.checkDone

	rsrc_gaddr	#5,#MODULESLOADED
	form_alert	#1,addrout
.checkDone
	rts
;---------------------------------------------------------------
loadAndAllocateModule

	stringLength	#modulePath
	lea	modulePath,a0
	ext.l	d1
	add.l	d1,a0
	stringTruncate	a0,#'\'

	stringLength	#modulePath
	lea	modulePath,a3
	ext.l	d1
	add.l	d1,a3
	stringCopy	#dta+30,a3

	move.l	dta+26,d3	; filesize

; reserve memory for the module

	m_xalloc	#3,d3
	tst.l	d0
	beq	quitRoutine	; .error

; enter address into table

	lea	moduleInformationTable,a3
	moveq.w	#99,d1
.loop
	tst.l	moduleAddress(a3)
	beq	.found
	add.l	#moduleSize,a3
	dbra	d1,.loop
** Error no space in module table **
	bra	quitRoutine
.found
	move.l	d0,moduleAddress(a3)

; load module into memory

	f_open	#0,#modulePath
	move.w	d0,d4
	f_read	moduleAddress(a3),d3,d0
	f_close	d4

; enter module info into the table

	move.l	moduleAddress(a3),a0

	move.l	2(a0),d0
	lea	28(a0),a0
	add.l	d0,a0	; points to moduleName

	move.l	a0,moduleName(a3)

	stringLength	moduleName(a3)
	move.l	moduleName(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.l	a0,moduleAuthor(a3)

	stringLength	moduleAuthor(a3)
	move.l	moduleAuthor(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.l	a0,moduleVersion(a3)

	stringLength	moduleVersion(a3)
	move.l	moduleVersion(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.w	(a0)+,moduleProtocol(a3)
	move.l	a0,moduleId(a3)

	addq.w	#1,numberOfModules
	rts
;---------------------------------------------------------------
releaseModules

	tst.w	numberOfModules
	beq	.done

	lea	moduleInformationTable,a0
	move.w	numberOfModules,d0
.loop
	tst.l	moduleAddress(a0)
	beq	.next

	m_free	moduleAddress(a0)
.next
	add.l	#moduleSize,a0
	dbra	d0,.loop
.done
	rts
;---------------------------------------------------------------
locateModule		; finds module in table from given address
		; address in a0
	movem.l	d0-d7/a1-a6,-(sp)

	lea	rawModuleInfo,a1
	moveq.w	#99,d0
.loop
	move.l	moduleAddress(a1),a2
	cmpa.l	a0,a2
	beq	.found
	add.l	#moduleSize,a1
	dbra	d0,.loop
** not found - Fatal Error **
	bra	quitRoutine
.found
	move.l	a1,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts
;---------------------------------------------------------------
locateModuleId	; finds module in table from given Id
		; Id address in a0
	movem.l	d0-d7/a1-a6,-(sp)

	lea	rawModuleInfo,a1
	moveq.w	#99,d0
.loop
	move.l	moduleId(a1),a2
	cmp.l	a0,a2
	beq	.found
	add.l	#moduleSize,a1
	dbra	d0,.loop
** not found - Fatal Error **
	bra	quitRoutine
.found
	move.l	a1,a0

	movem.l	(sp)+,d0-d7/a1-a6
	rts
;---------------------------------------------------------------
; enter raw info into pre-table
enterRaw
	lea	rawModuleInfo,a3
	move.l	#rawModule,a0
	move.l	a0,moduleAddress(a3)

	move.l	2(a0),d0
	lea	28(a0),a0
	add.l	d0,a0	; points to moduleName

	move.l	a0,moduleName(a3)

	stringLength	moduleName(a3)
	move.l	moduleName(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.l	a0,moduleAuthor(a3)

	stringLength	moduleAuthor(a3)
	move.l	moduleAuthor(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.l	a0,moduleVersion(a3)

	stringLength	moduleVersion(a3)
	move.l	moduleVersion(a3),a0
	ext.l	d1
	addq.l	#1,d1
	add.l	d1,a0
	move.w	(a0)+,moduleProtocol(a3)
	move.l	a0,moduleId(a3)

	rts
;---------------------------------------------------------------
	SECTION	bss
; module table
	rsreset
moduleAddress	rs.l	1
moduleName	rs.l	1
moduleAuthor	rs.l	1
moduleVersion	rs.l	1
moduleId	rs.l	1
moduleProtocol	rs.w	1
moduleSize	rs.w	0

numberOfModules	ds.w	1

rawModuleInfo	ds.b	moduleSize
moduleInformationTable	ds.b	moduleSize*100
; *100 to allow for 100 modules to be loaded


moduleDialogAddresses	ds.l	3	; name,Author,Version

	SECTION	text
rawModule	incbin	raw.sem