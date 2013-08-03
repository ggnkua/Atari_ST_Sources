; Sam-Edit 2 version 2.0 DVS module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\DVS.SEM

	SECTION	data

moduleName		dc.b	'DVS Module ',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.5 (17/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'DVS',0

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

; DVS header
	rsreset
magic	rs.l	1
magic2	rs.w	1
headlen	rs.w	1
freq	rs.w	1
pack	rs.b	1
mode	rs.b	1
blocklen	rs.l	1

	SECTION	text

start	; header in a0, info table in a1, function number in d0
	; d1 = address of D2D buffer , d2 = size of d2d buffer
	; DO NOT touch sampleModuleAddress
	; DO NOT change sampleLoaded

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

	moveq.w	#0,d0	; set to not found

	cmpi.l	#'DVSM',magic(a0)
	bne	.notDVS
	tst.w	magic2(a0)
	bne	.notDVS

	cmpi.b	#0,pack(a0)
	bne	.notDVS	; don't support packed DVS files

	move.w	headlen(a0),d0
	move.w	d0,sampleHeaderSize(a1)
	sub.l	d0,sampleDataSize(a1)

	move.w	mode(a0),d0
	move.w	#8,sampleResolution(a1)
	btst	#0,d0
	beq	.not16
	move.w	#16,sampleResolution(a1)
.not16
	move.w	#1,sampleChannels(a1)
	btst	#1,d0
	beq	.notStereo
	move.w	#2,sampleChannels(a1)
.notStereo

	move.w	#1,sampleSigned(a1)

	move.w	freq(a0),d0
	ext.l	d0
	move.l	d0,d1
	cmpi.l	#256,d0
	bgt	.setFreq
; freq < 256 therefore is a code for which freq to use 
	move.l	#8195,d1
	tst.l	d0
	beq	.setFreq
	move.l	#9834,d1
	cmpi.l	#1,d0
	beq	.setFreq
	move.l	#12292,d1
	cmpi.l	#2,d0
	beq	.setFreq
	move.l	#16390,d1
	cmpi.l	#3,d0
	beq	.setFreq
	move.l	#19668,d1
	cmpi.l	#4,d0
	beq	.setFreq
	move.l	#24585,d1
	cmpi.l	#5,d0
	beq	.setFreq
	move.l	#32780,d1
	cmpi.l	#6,d0
	beq	.setFreq
	move.l	#49170,d1
	cmpi.l	#7,d0
	beq	.setFreq

	moveq.w	#0,d0	; invalid frequency so not DVS
	bra	.notDVS
.setFreq
	move.l	d1,sampleFrequency(a1)

	moveq.w	#1,d0	; set to found
.notDVS
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

updateHeader	; Construct a new header to ensure a correct header

	move.l	#'DVSM',magic(a0)		
	clr.w	magic2(a0)

	move.w	#16,headlen(a0)
	clr.b	pack(a0)

	move.w	sampleResolution(a1),d0
	ror.w	#3,d0
	subq.w	#1,d0
	move.w	sampleChannels(a1),d1
	andi.w	#1,d1
	add.w	d1,d0
	move.w	d0,mode(a0)

	clr.l	blocklen(a0)

	move.l	sampleFrequency(a1),d0
	move.w	d0,freq(a0)

	move.w	#16,sampleHeaderSize(a1)
	rts