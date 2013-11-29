	SECTION	text

setFrequency
	move.w	#SETFREQ,d0
	lea	.return,a1
	lea	sampleInfoTable,a0

	move.l	machine,d1
	cmpi.l	#$30000,d1	; falcon?
	bne	.displayFreq ; if not then display dialog

	move.w	#SETFALCFREQ,d0
	lea	.returnFalc,a1
.displayFreq
	displayDialog	d0,#16395,a1

; set window title
	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#SETFREQSTTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2

; if STE DMA compatiable sound system present then
; enable the DMA freqs and the stereo setting

	move.l	dmaSound,d0
	move.l	machine,d1
	cmpi.l	#$30000,d1
	beq	.falcButtons

	andi.l	#2,d0
	beq	.done

	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
	move.l	a0,a1

	move.l	#EFREQ0*24,d0
	add.l	d0,a0

	ori.w	#8,objectStatus(a0)
	eor.w	#8,objectStatus(a0)
	add.l	#objectSize,a0
	ori.w	#8,objectStatus(a0)
	eor.w	#8,objectStatus(a0)	; EFREQ1
	add.l	#objectSize,a0
	ori.w	#8,objectStatus(a0)
	eor.w	#8,objectStatus(a0)	; EFREQ2
	add.l	#objectSize,a0
	ori.w	#8,objectStatus(a0)
	eor.w	#8,objectStatus(a0)	; EFREQ3	

	move.l	#STEREOSET*24,d0
	add.l	d0,a1
	ori.w	#8,objectStatus(a1)
	eor.w	#8,objectStatus(a1)	; Stereo setting
	bra	.done

.falcButtons

.done
	rts

; the object that caused the return is in d0
.return
	cmpi.w	#OKFREQSET,d0
	beq	setNewFreq

	cmpi.w	#APPLYFREQSET,d0
	bne	.checked
	jsr	selectObject
	bra	setNewFreq
.checked
	rts

.returnFalc
	cmpi.w	#OKSETFREQF,d0
	beq	setNewFreqFalc

	cmpi.w	#APPLYSETFREQF,d0
	bne	.checkedF
	jsr	selectObject
	bra	setNewFreqFalc
.checkedF
	rts
;------------------------------------------------------------------
setNewFreq

	move.l	#EFREQ0*24,d0
	move.w	#EFREQ0,d1
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
.check
	move.l	a0,a1
	add.l	d0,a1
	move.w	objectStatus(a1),d2
	andi.w	#1,d2
	bne	.found
	addq.w	#1,d1
	cmpi.w	#EFREQ3,d1
	bgt	.notDMA
	add.l	#24,d0
	bra	.check
.found		; d1 holds the object number, d0 will hold rate id

	cmpi.w	#EFREQ0,d1
	bne	.efreq1
	moveq.l	#0,d0
	bra	.efset
.efreq1
	cmpi.w	#EFREQ1,d1
	bne	.efreq2
	moveq.l	#1,d0
	bra	.efset
.efreq2
	cmpi.w	#EFREQ2,d1
	bne	.efreq3
	moveq.l	#2,d0
	bra	.efset
.efreq3
	moveq.l	#3,d0
.efset
; mono or stereo?  MONOSET

	move.l	a0,a1
	move.l	#MONOSET*24,d1
	add.l	d1,a1
	move.w	objectStatus(a1),d1
	andi.w	#1,d1
	beq	.dmaSet	; is stereo so done
	ori.b	#$80,d0	; set to mono
.dmaSet
	move.b	d0,DMARate
; now set the actual rate in the registers
	super	#0

	move.b	DMARate,$ffff8921

	super	d0

	rts
.notDMA
	rts
;------------------------------------------------------------------
setNewFreqFalc
	move.l	#FFREQ1*24,d0
	move.w	#FFREQ1,d1
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
.check1
	move.l	a0,a1
	add.l	d0,a1
	move.w	objectStatus(a1),d2
	andi.w	#1,d2
	bne	.found1
	addq.w	#1,d1
	cmpi.w	#FFREQ11,d1
	bgt	.notFalc
	add.l	#24,d0
	bra	.check1
.found1	; d1 holds the object number, d0 will hold rate id

	cmpi.w	#FFREQ1,d1
	bne	.ffreq2
	moveq.l	#1,d0
	bra	.ffset
.ffreq2
	cmpi.w	#FFREQ2,d1
	bne	.ffreq3
	moveq.l	#2,d0
	bra	.ffset
.ffreq3
	cmpi.w	#FFREQ3,d1
	bne	.ffreq4
	moveq.l	#3,d0
	bra	.ffset
.ffreq4
	cmpi.w	#FFREQ4,d1
	bne	.ffreq5
	moveq.l	#3,d0
	bra	.ffset
.ffreq5
	cmpi.w	#FFREQ5,d1
	bne	.ffreq7
	moveq.l	#5,d0
	bra	.ffset
.ffreq7
	cmpi.w	#FFREQ7,d1
	bne	.ffreq9
	moveq.l	#7,d0
	bra	.ffset
.ffreq9
	cmpi.w	#FFREQ9,d1
	bne	.ffreq11
	moveq.l	#9,d0
	bra	.ffset
.ffreq11
	moveq.l	#11,d0

.ffset
	move.l	d0,d3

; mono or stereo
	move.l	a0,a1
	move.l	#FMONOSET*24,d0
	add.l	d0,a1
	move.w	objectStatus(a1),d0
	andi.w	#1,d0
	beq	.stereo
	moveq.w	#2,d0
.stereo
	lea	sampleInfoTable,a3
	move.w	sampleResolution(a3),d1
	ror.w	#3,d1
	subq.w	#1,d1
	add.w	d1,d0

	move.w	d0,-(sp)
	move.w	#132,-(sp)
	trap	#xbios
	addq.l	#4,sp

	super	#0
	clr.b	$ffff8934	; set STE mode
	move.b	d3,$ffff8935
	super	d0

	rts
.notFalc
	move.l	#FEFREQ1*24,d0
	move.w	#FEFREQ1,d1
	move.l	dialogTableAddress,a0
	move.l	dialogResource(a0),a0
.check2
	move.l	a0,a1
	add.l	d0,a1
	move.w	objectStatus(a1),d2
	andi.w	#1,d2
	bne	.found2
	addq.w	#1,d1
	cmpi.w	#FEFREQ3,d1
	bgt	.notDMA
	add.l	#24,d0
	bra	.check2
.found2	; d1 holds the object number, d0 will hold rate id

	cmpi.w	#FEFREQ1,d1
	bne	.fefreq2
	moveq.l	#1,d0
	bra	.feset
.fefreq2
	cmpi.w	#FEFREQ2,d1
	bne	.fefreq3
	moveq.l	#2,d0
	bra	.feset
.fefreq3
	moveq.l	#3,d0
.feset
; mono or stereo?  MONOSET

	move.l	a0,a1
	move.l	#FMONOSET*24,d1
	add.l	d1,a1
	move.w	objectStatus(a1),d1
	andi.w	#1,d1
	beq	.dmaSet	; is stereo so done
	ori.b	#$80,d0	; set to mono
.dmaSet
	move.b	d0,DMARate
; now set the actual rate in the registers
	super	#0

	clr.b	$ffff8934	; set STE mode
	clr.b	$ffff8935	; "
	move.b	DMARate,$ffff8921

	super	d0
	rts
.notDMA
	rts
;------------------------------------------------------------------
setPlaybackFreq
	move.l	dmaSound,d1

	tst.l	d1
	bne	.notYamaha

	move.w	#1,fmFreq

.notYamaha
	lea	sampleInfoTable,a3

	move.l	sampleFrequency(a3),d0

	tst.w	fmFreq
	bne	setFMFreq

	cmpi.l	#8000,d0
	bgt	.not6

	moveq.b	#0,d7
	bra	.set
	
.not6
	cmpi.l	#16000,d0
	bgt	.not12

	moveq.b	#1,d7
	bra	.set
.not12
	cmpi.l	#35000,d0
	bgt	.not25
	
	moveq.b	#2,d7
	bra	.set
.not25
	moveq.b	#3,d7
.set

	cmpi.w	#1,sampleChannels(a3)
	bne	.done
; set Mono
	ori.b	#128,d7
.done
	move.b	d7,DMARate

	move.l	machine,d0
	cmpi.l	#$30000,d0
	beq	.falcFreqs

	rts

.falcFreqs
	super	#0
	move.l	sampleFrequency(a3),d2

	cmpi.l	#9014,d2
	bgt	.not8195
	move.w	#%1011,d1
	bra	.go
.not8195
	cmpi.l	#11063,d2
	bgt	.not9834
	move.w	#%1001,d1
	bra	.go
.not9834
	cmpi.l	#14341,d2
	bgt	.not12292
	move.w	#%111,d1
	bra	.go
.not12292
	cmpi.l	#18029,d2
	bgt	.not16390
	move.w	#%101,d1
	bra	.go
.not16390
	cmpi.l	#22126,d2
	bgt	.not19668
	move.w	#%100,d1
	bra	.go
.not19668
	cmpi.l	#28682,d2
	bgt	.not24585
	move.w	#%11,d1
	bra	.go
.not24585
	cmpi.l	#40975,d2
	bgt	.not32780
	move.w	#%10,d1
	bra	.go
.not32780
	move.w	#%1,d1

.go
	clr.b	$ffff8934
	move.b	d1,$ffff8935
	super	d0

	move.w	sampleChannels(a3),d0
	moveq.w	#0,d2
	cmpi.w	#1,d0
	bgt	.noFix
	moveq.w	#2,d2
.noFix
	move.w	sampleResolution(a3),d1
	ror.w	#3,d1
	subq.w	#1,d1
	add.w	d1,d2

	move.w	d2,-(sp)
	move.w	#132,-(sp)
	trap	#xbios
	addq.l	#4,sp

	rts
;------------------------------------------------------------------
setFMFreq

	rts
;------------------------------------------------------------------
	SECTION	bss
fmFreq	ds.w	1	; flag to use FM sound
	SECTION	data
setNewFreqError	dc.b	'No freq selected error',0