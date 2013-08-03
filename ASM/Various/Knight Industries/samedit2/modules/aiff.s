; Sam-Edit 2 version 2.0 AIFF module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\AIFF.SEM

	SECTION	data

moduleName		dc.b	'AIFF Module',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.5 (17/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'AIFF',0

; functions Bit:  0  = ID	(Necessary for all modules)
;           Bit:  1  = Load	"
;           Bit:  2  = Save	"
;           Bit:  3  = Update Header	"
;           Bit:  4  = Intel byte order if set (required)

	SECTION	bss
; info table
	rsreset
sampleModuleAddress	rs.l	1
sampleHeaderSize	rs.w	1
sampleDataSize	rs.l	1
sampleAddress	rs.l	1
sampleFrequency	rs.l	1
sampleChannels	rs.w	1
sampleResolution	rs.w	1
sampleSigned	rs.w	1
sampleLoaded	rs.w	1
sampleSaveStatus	rs.w	1
sampleMode	rs.w	1	; 0 = mem, 1 = d2d
sampleModuleFunctions	rs.w	1
samplePathname	rs.b	256	; holds directory+file
sampleInfoSize	rs.w	0

; AIFF header
	rsreset	; form chunk
form	rs.l	1	; Holds "FORM"
flength	rs.l	1	; length of chunk
ftype	rs.l	1	; holds type of form (ie "AIFF")

	rsreset	; common chunk
common		rs.l	1	; Holds "COMM"
clength		rs.l	1	; length of chunk
numChannels		rs.w	1	; number of channels
numSampleFrames	rs.l	1	; number of sample frames
sampleSize		rs.w	1	; bits per sample
sampleRate		rs.b	10	; int rate in high word

	rsreset	; sound data chunk

soundData	rs.l	1	; Holds "SSND"
slength	rs.l	1	; length of data
soffset	rs.l	1	; offset to data (should be 0)
sblocksize	rs.l	1	; size of alignment blocks (should be 0)

	SECTION	text

start	; header in a0, info table in a1, function number in d0
	; d1 = address of D2D buffer , d2 = size of d2d buffer
	; DO NOT touch sampleModuleAddress
	; DO NOT change sampleLoaded
	; DO NOT change sampleMode
	; DO NOT change sampleSaveStatus

	cmpi.w	#1,d0
	beq	idSample

	cmpi.w	#2,d0
	beq	loadSample

	cmpi.w	#3,d0
	beq	saveSample

	cmpi.w	#4,d0
	beq	updateHeader

	rts

idSample	; return in d0, non zero if found, zero if not found
	; if found enter data in info table
	; set header size/update data size needed

	; sampleDataSize=filesize when module is first called
	; for a sample

	cmpi.l	#'FORM',form(a0)
	bne	.notAIFF

	cmpi.l	#'AIFF',ftype(a0)
	bne	.notAIFF

; locate the common chunk

	move.l	a0,a2

	move.w	#1024,d1
.loopCOMM
	subq.l	#1,d1
	ble	.notAIFF
	addq.l	#1,a2
	cmpi.l	#'COMM',(a2)
	bne	.loopCOMM

; common chunk found if this point reached

	addq.l	#8,a2	; bypass chunk name/length

	move.w	(a2)+,sampleChannels(a1)
	addq.l	#4,a2	; bypass frames
	move.w	(a2)+,sampleResolution(a1)

	move.w	(a2)+,d0	; exponent
	sub.w	#$3fff,d0
	move.l	(a2)+,d1
	moveq.l	#0,d2
.loopFreq
	rol.l	#1,d2
	rol.l	#1,d1
	bcc	.noCarry
	addq.l	#1,d2
.noCarry
	dbra	d0,.loopFreq
	move.l	d2,sampleFrequency(a1)

	move.w	#1,sampleSigned(a1)

; set header size by finding SSND chunk

	move.l	a0,a2
	move.w	#1024,d1
.loopSSND
	subq.w	#1,d1
	ble	.notAIFF
	addq.l	#1,a2
	cmpi.l	#'SSND',(a2)
	bne	.loopSSND

	move.l	sampleDataSize(a1),d0
	move.l	4(a2),d1
	sub.l	d1,d0
	addq.l	#8,d0

	move.w	d0,sampleHeaderSize(a1)

	sub.l	d0,sampleDataSize(a1)


	moveq.w	#1,d0	; set to found
	rts
.notAIFF
	moveq.w	#0,d0	; set to not found
	rts

loadSample	; memory has already been reserved and the data
	; loaded, this part is for any decoding that may
	; need to be done (such as byte swapping)

	rts

saveSample	; no need to actually write data to the file
	; as with loading this part is for any encoding that
	; may need to be done

	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.sign
	move.l	d1,a0
	move.l	d2,d0
.sign
	tst.w	sampleSigned(a1)
	bne	.notNeeded
	cmpi.w	#16,sampleResolution(a1)
	beq	.s16
.s8
	move.b	(a0),d2
	eor.b	#$80,d2
	move.b	d2,(a0)+
	subq.l	#1,d0
	bgt	.s8
	bra	.notNeeded
.s16
	move.w	(a0),d2
	eor.w	#$4000,d2
	move.w	d2,(a0)+
	subq.l	#2,d0
	bgt	.s16

.notNeeded
	rts

	rts

updateHeader	; Construct a new header to ensure a correct header

	move.l	#'FORM',(a0)+
	move.l	sampleDataSize(a1),d0
	add.l	#54,d0
	move.l	d0,(a0)+
	move.l	#'AIFF',(a0)+


	move.l	#'COMM',(a0)+
	move.l	#18,(a0)+

	move.w	sampleChannels(a1),d0
	move.w	d0,(a0)+

	move.l	sampleDataSize(a1),d1
	move.l	d1,d2

	; divide d1 by d0 for numSampleFrames
	ext.l	d0
	bsr	long_div

	move.l	d0,(a0)+
	move.w	sampleResolution(a1),(a0)+
	move.l	sampleFrequency(a1),d0
	moveq.w	#32,d1
.loopSetFreq
	btst	#31,d0
	bne	.freqSet
	rol.l	#1,d0
	subq.w	#1,d1
	bra	.loopSetFreq
.freqSet
	add.w	#$3ffe,d1
	move.w	d1,(a0)+	; exponent 16
	move.l	d0,(a0)+
	clr.l	(a0)+

	move.l	#'SSND',(a0)+
	move.l	d2,d0
	add.l	#12,d0
	move.l	d0,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+

	move.w	#54,sampleHeaderSize(a1)

	rts

	include	D:\develop\new_libs\div_mul.s