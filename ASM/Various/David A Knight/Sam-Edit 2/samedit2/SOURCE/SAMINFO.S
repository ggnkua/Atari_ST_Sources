	SECTION	text

sampleInfo
	displayDialog	#SAMPLEINFO,#16395,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#SAMPLEINFOTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

	rts

; the object that caused the return is in d0
.return

	rts
;---------------------------------------------------------------
getInfoAddresses
	movem.l	d0-d4/a0-a5,-(sp)

	rsrc_gaddr	#0,#SAMPLEINFO
	move.l	addrout,a0

	move.l	a0,a1
	move.l	a1,a2
	move.l	a2,a3
	move.l	a3,a4

	move.l	#INFOFILEFORMAT*24,d0
	move.l	#INFOFREQUENCY*24,d1
	move.l	#INFOCHANNELS*24,d2
	move.l	#INFORESOLUTION*24,d3
	move.l	#INFOLENGTH*24,d4

	add.l	d0,a0
	add.l	d1,a1
	add.l	d2,a2
	add.l	d3,a3
	add.l	d4,a4

	move.l	objectSpec(a0),a0
	move.l	objectSpec(a1),a1
	move.l	objectSpec(a2),a2
	move.l	objectSpec(a3),a3
	move.l	objectSpec(a4),a4

	lea	sampleInfoAddresses,a5
	move.l	a0,(a5)+
	move.l	a1,(a5)+
	move.l	a2,(a5)+
	move.l	a3,(a5)+
	move.l	a4,(a5)

	movem.l	(sp)+,d0-d4/a0-a5
	rts
;---------------------------------------------------------------
enterSampleInfo
	movem.l	d0-d7/a0-a6,-(sp)

	lea	sampleInfoTable,a1
	lea	sampleInfoAddresses,a2

	move.l	sampleFrequency(a1),d0
	move.l	d0,d4
	str	d0,sampleInfoPlaybackFrequency(a2)

	move.w	sampleChannels(a1),d0
	ext.l	d0
	move.l	d0,d3
	str	d0,sampleInfoChannels(a2)

	move.w	sampleResolution(a1),d0
	ext.l	d0
	move.l	d0,d2
	str	d0,sampleInfoResolution(a2)

	move.l	d3,d0
	ror.l	#3,d2
	mulu	d2,d0
	move.l	d4,d1
	bsr	long_mul
	move.l	sampleDataSize(a1),d1
	bsr	long_div
	str	d0,sampleInfoLength(a2)

	move.l	moduleAddress(a1),a0
	bsr	locateModule
	move.l	moduleId(a0),a0
	stringCopy	a0,sampleInfoFileFormat(a2)
	clr.b	(a1)

; redraw sample info dialog if open
	rsrc_gaddr	#0,#SAMPLEINFO
	move.l	addrout,a2
	bsr	checkForDialog

	move.l	dialogTableAddress,a0
	cmp.l	#0,a0
	beq	.done

	move.w	dialogHandle(a0),d0
	wind_get	d0,#4
	movem.w	intout+2,d1-d4
	bsr	generalRedrawHandler
.done
	movem.l	(sp)+,d0-d7/a0-a6
	rts
;---------------------------------------------------------------
	SECTION	bss

	rsreset
sampleInfoFileFormat	rs.l	1
sampleInfoPlaybackFrequency	rs.l	1
sampleInfoChannels	rs.l	1
sampleInfoResolution	rs.l	1
sampleInfoLength	rs.l	1
sampleInfoAddressesSize	rs.w	0

sampleInfoAddresses	ds.b	sampleInfoAddressesSize