; Sam-Edit 2 version 2.0 STOS Maestro module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\STOS.SEM

	SECTION	data

moduleName		dc.b	'STOS Module',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.4 (30/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'SAM',0

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


	SECTION	text

start	; header in a0, info table in a1, function number in d0
	; d1 = address of D2D buffer , d2 = size of d2d buffer
	; DO NOT touch sampleModuleAddress
	; DO NOT change sampleLoaded
	; DO NOT touch sampleMode

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

	move.l	(a0),d1
	andi.l	#$FFFFFF00,d0
	cmpi.l	#'JON'*256,d0
	bne	.notSTOS

	move.w	#4,sampleHeaderSize(a1)
	sub.l	#4,sampleDataSize(a1)

	moveq.l	#0,d1
	move.b	3(a0),d1
	mulu	#1000,d1
	move.l	d1,sampleFrequency(a1)
	move.w	#8,sampleResolution(a1)
	move.w	#0,sampleSigned(a1)

	moveq.w	#1,d0	; set to found
.notSTOS
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
	bne	.sign
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

	move.l	#'JON'*256,(a0)

	move.l	sampleFrequency(a1),d0
	divu	#1000,d0
	move.b	d0,3(a0)

	move.w	#4,sampleHeaderSize(a1)
	rts