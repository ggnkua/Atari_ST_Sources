	SECTION	text
alterSampleInfo
	cmpi.w	#ALTERINFO,d0	; from the menu?
	beq	.ok

	jsr	.disable
.ok
	displayDialog	#ALTER,#16393,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#ALTERTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	jsr	alterTypeWindow

	rts

; the object that caused the return is in d0
.return
	cmpi.w	#ALTEROK,d0
	beq	.setInfo
	cmpi.w	#ALTERNO,d0
	beq	.done

	cmpi.w	#ALTERTYPESLIDER,d0
	beq	AlterSampleSlider
	cmpi.w	#ALTERTYPESCROLL,d0
	beq	AlterSampleSlider

	jsr	selectObject
	cmpi.w	#UPALTERSLOT,d0
	beq	upAlterSlot
	cmpi.w	#DOWNALTERSLOT,d0
	beq	downAlterSlot


	jsr	.enable
.done
	rts
;-------------------------------------------------------------------------
.setInfo
	move.l	dialogTableAddress,a2
	move.l	dialogResource(a2),a2
	move.l	a2,a4
	lea	sampleInfoTable,a3
	move.l	#ALTERFREQ*24,d0
	add.l	d0,a2

	move.l	objectSpec(a2),a1
	move.l	(a1),a1
	val	a1
	move.l	d0,sampleFrequency(a3)
	lea	24(a2),a2
	move.l	objectSpec(a2),a1
	move.l	(a1),a1
	val	a1
	move.w	d0,sampleResolution(a3)
	lea	24(a2),a2
	move.l	objectSpec(a2),a1
	move.l	(a1),a1
	val	a1
	move.w	d0,sampleChannels(a3)

	moveq.w	#0,d1
	move.l	#ALTERSIGNED*24,d0
	add.l	d0,a4
	move.w	objectStatus(a4),d0
	andi.w	#1,d0
	beq	.alterSign
	moveq.w	#1,d1
.alterSign
	move.w	d1,sampleSigned(a3)

; identify module format to set as
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
; which type of file to create?
	move.l	a0,a1
	move.l	#ALTERSLOT1*24,d0
	add.l	d0,a1
	move.w	#NEW_SLOTS-1,d0
.loop
	move.w	objectStatus(a1),d1
	andi.w	#1,d1
	bne	.typeFound
	add.l	#objectSize,a1
	dbra	d0,.loop
** error no type found! **
	lea	quitRoutine,a0
	jmp	(a0)	; fatal
.typeFound
	move.l	objectSpec(a1),a4
	cmp.l	#emptySlot,a4
	bne	.notEmpty
	lea	rawModuleInfo,a4
	move.l	moduleId(a4),a4
.notEmpty	; a4 points at string of module name
	; Determine Module for format address of id in a4
	move.l	a4,a0
	jsr	locateModuleId
	move.l	(a0),sampleModuleAddress(a3)
; create the header
	movem.l	d0-d7/a0-a6,-(sp)
	callModule	#4
	movem.l	(sp)+,d0-d7/a0-a6

	jsr	enterSampleInfo
	jsr	.enable

	clr.w	redrawCached
	move.w	mainWindowHandle,d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	jsr	generalRedrawHandler

	bra	.done
;-------------------------------------------------------------------------
.disable
	rsrc_gaddr	#0,#MENUBAR
	move.l	addrout,a0

	move.l	a0,a1
	move.l	#FILE*24,d0
	add.l	d0,a1
	ori.w	#8,objectStatus(a1)

	move.l	a0,a1
	move.l	#EDIT*24,d0
	add.l	d0,a1
	ori.w	#8,objectStatus(a1)

	move.l	a0,a1
	move.l	#OPTIONS_*24,d0
	add.l	d0,a1
	ori.w	#8,objectStatus(a1)

	menu_bar	#1,a0

	rts
.enable
	rsrc_gaddr	#0,#MENUBAR
	move.l	addrout,a0

	move.l	a0,a1
	move.l	#FILE*24,d0
	add.l	d0,a1
	move.w	objectStatus(a1),d0
	andi.w	#8,d0
	beq	.enableDone
	eor.w	#8,objectStatus(a1)

	move.l	a0,a1
	move.l	#EDIT*24,d0
	add.l	d0,a1
	eor.w	#8,objectStatus(a1)

	move.l	a0,a1
	move.l	#OPTIONS_*24,d0
	add.l	d0,a1
	eor.w	#8,objectStatus(a1)

	menu_bar	#1,a0
.enableDone
	rts
;-----------------------------------------------------------------------
alterTypeWindow
	movem.l	d0-d7/a0-a6,-(sp)

; find % number of modules that can be displayed in the window

	move.l	#NEW_SLOTS*100,d1
	move.w	numberOfModules,d0
	addq.w	#1,d0	; +1 for data module
	ext.l	d0
	jsr	long_div

; if > 100 then all can be displayed so set to 100

	cmpi.l	#100,d0
	ble	.percentFound

	move.l	#100,d0
.percentFound

; d0 now holds % height that ALTERTYPESLIDER needs to be in comparison
; with ALTERTYPESCROLL

; find height of scroll bar (ALTERTYPESCROLL)
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.l	#ALTERTYPESCROLL*24,d1
	add.l	d1,a1
	move.w	objectH(a1),d1
	ext.l	d1

; multiply % and height of ALTERTYPESCROLL
	jsr	long_mul
; / by 100
	move.l	#100,d1
	exg	d0,d1
	jsr	long_div

; height of ALTERTYPESLIDER in d0
	move.l	a0,a1
	move.l	#ALTERTYPESLIDER*24,d1
	add.l	d1,a1
	move.w	d0,objectH(a1)

; now fill in the slot entries
	move.w	#0,firstAlterSlot
	jsr	alterSlotEntry

	movem.l	(sp)+,d0-d7/a0-a6

	rts
;-----------------------------------------------------------------------
alterSlotEntry
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,a1	; a0 holds dialogResource

	move.l	#ALTERSLOT1*24,d0
	add.l	d0,a1
; a1 points at first slot in resource

	move.w	firstAlterSlot,d0
	ext.l	d0
	move.l	#moduleSize,d1
	jsr	long_mul

	move.w	numberOfModules,d2
	sub.w	firstAlterSlot,d2
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
AlterSampleSlider	; 1000th value in d2
	ext.l	d2
	move.w	numberOfModules,d0
	sub.w	#NEW_SLOTS-1,d0
	move.l	d2,d1
	ext.l	d0
	jsr	long_mul
	move.l	#1000,d1
	exg	d1,d0
	jsr	long_div
	tst.l	d2
	bne	.noZero
	moveq.w	#0,d0
.noZero
	move.w	d0,firstAlterSlot

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	jsr	alterSlotEntry
	jsr	redrawAlterModuleList

	rts
;-----------------------------------------------------------------------
positionAlterSlider
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1
	move.l	a1,a2

	move.w	firstAlterSlot,d0
	beq	.set
	addq.w	#1,d0
	move.w	#1000,d1
	jsr	long_mul
	move.w	numberOfModules,d1
	addq.w	#1,d1
	exg	d1,d0
	jsr	long_div

	move.l	#ALTERTYPESCROLL*24,d1
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
	move.l	#ALTERTYPESLIDER*24,d1
	add.l	d1,a1
	move.w	d0,objectY(a1)
; redraw the slider
	objc_offset	#ALTERTYPESCROLL,a2
	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	subq.w	#2,d1
	subq.w	#2,d2
	addq.w	#4,d3
	addq.w	#4,d4
	jsr	redrawDialog
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;--------------------------------------------------------------------------
upAlterSlot
	move.w	firstAlterSlot,d0
	beq	.done
	subq.w	#1,d0
	bge	.greater
	moveq.w	#0,d0
.greater
	move.w	d0,firstAlterSlot
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	jsr	alterSlotEntry
	jsr	redrawAlterModuleList
	jsr	positionAlterSlider
; mouse button still held?
.done
	evnt_timer	#250,#0
	graf_mkstate
	move.w	intout+6,d0
	andi.w	#1,d0
	bne	upAlterSlot
	move.w	#UPALTERSLOT,d0
	jsr	selectObject
	rts
;--------------------------------------------------------------------------
downAlterSlot
	move.w	numberOfModules,d1
	cmpi.w	#7,d1
	blt	.done	; lt due to data module not included in count
	move.w	firstAlterSlot,d0
	addq.w	#1,d0
	move.w	d1,d2
	sub.w	d0,d1
	cmpi.w	#7,d1
	bge	.greater
	subq.w	#NEW_SLOTS-1,d2
	move.w	d2,d0
.greater
	move.w	d0,firstAlterSlot
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	jsr	alterSlotEntry
	jsr	redrawAlterModuleList
	jsr	positionAlterSlider
; mouse button still held?
.done
	evnt_timer	#250,#0
	graf_mkstate
	move.w	intout+6,d0
	andi.w	#1,d0
	bne	downAlterSlot
	move.w	#DOWNALTERSLOT,d0
	jsr	selectObject
	rts
;--------------------------------------------------------------------------
redrawAlterModuleList	; resource address in a0
	objc_offset	#ALTERMODLIST,a0
	move.w	#ALTERMODLIST*24,d0
	add.l	d0,a0

	movem.w	intout+2,d1-d2
	move.w	objectW(a0),d3
	move.w	objectH(a0),d4
	jsr	redrawDialog
	rts
;--------------------------------------------------------------------------
	SECTION	bss
firstAlterSlot	ds.w	1