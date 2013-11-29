	SECTION	text

selectRecordMethod
	displayDialog	#RECORDSELECT,#16395,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#RECORDMETHTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

; activate the falcon button if a falcon

	move.l	machine,d0
	cmpi.l	#$30000,d0
	bne	.notFalc

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	#FALCONRECORD*24,d0
	add.l	d0,a0
	move.w	objectStatus(a0),d0
	ori.w	#8,d0
	eor.w	#8,d0
	move.w	d0,objectStatus(a0)

.notFalc
	rts

; the object that caused the return is in d0
.return
	cmpi.w	#OKRECMETHOD,d0
	beq	.selectMethod
	rts

.selectMethod
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a1
	move.l	#FALCONRECORD*24,d0
	add.l	d0,a1
	move.w	objectStatus(a1),d0
	andi.w	#1,d0
	bne	falconRecord
	rts