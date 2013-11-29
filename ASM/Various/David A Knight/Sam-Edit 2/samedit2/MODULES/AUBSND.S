; Sam-Edit 2 version 2.0 AU / SND module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\AU_SND.SEM

	SECTION	data

moduleName		dc.b	'AU / SND Module',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.7 (17/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'AU/SND',0

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

; AU/SND header
	rsreset
code	rs.l	1
headersize	rs.l	1
samLength	rs.l	1
encoding	rs.l	1
rate	rs.l	1
channels	rs.l	1
size	rs.w	0

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

	cmpi.l	#'.snd',code(a0)
	beq	.SND
	cmpi.l	#'dns.',code(a0)
	bne	.notSND
.SND
	move.l	headersize(a0),d0
	move.w	d0,sampleHeaderSize(a1)
	sub.l	d0,sampleDataSize(a1)

	move.l	channels(a0),d0
	move.w	d0,sampleChannels(a1)

	moveq.w	#0,d0	; set not found flag
	move.l	encoding(a0),d1
	cmpi.l	#2,d1
	blt	.notSND	; doesn't support u-law
	cmpi.l	#3,d1
	bgt	.notSND	; only supports 8/16 bit (encoding 2 or 3)
	subq.l	#1,d1
	rol.l	#3,d1
	move.w	d1,sampleResolution(a1)

	move.w	#1,sampleSigned(a1)

	move.l	rate(a0),sampleFrequency(a1)

	moveq.w	#1,d0	; set to found
.notSND
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

	move.l	#'.snd',code(a0)
	move.l	#24,headersize(a0)
	move.l	sampleDataSize(a1),samLength(a0)
	move.w	sampleChannels(a1),d0
	ext.l	d0
	move.l	d0,channels(a0)

	move.w	sampleResolution(a1),d0
	ror.w	#3,d0
	addq.w	#1,d0
	ext.l	d0
	move.l	d0,encoding(a0)

	move.l	sampleFrequency(a1),rate(a0)

	move.w	#24,sampleHeaderSize(a1)
	rts