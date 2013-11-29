; Sam-Edit 2 version 2.0 WAV module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\PCM_WAVE.SEM

	SECTION	data

moduleName		dc.b	'WAV Module ',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.5 (17/06/1998)',0
moduleFunctions	dc.w	%11111
moduleID		dc.b	'WAVE',0

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

; WAVE header
	rsreset	; form chunk
form	rs.l	1	; Holds "RIFF"
flength	rs.l	1	; length of chunk
ftype	rs.l	1	; holds type of form (ie "WAVE")

	rsreset	; common chunk
common		rs.l	1	; Holds "fmt "
clength		rs.l	1	; length of chunk
type		rs.w	1	; type of Wave
numChannels		rs.w	1	; number of channels
rate		rs.l	1	; freq
avg		rs.l	1
align		rs.w	1
res		rs.w	1	; resolution

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
;===============================================================================
idSample	; return in d0, non zero if found, zero if not found
	; if found enter data in info table
	; set header size/update data size needed

	; sampleDataSize=filesize when module is first called
	; for a sample

	cmpi.l	#'RIFF',form(a0)
	bne	.notWAVE

	cmpi.l	#'WAVE',ftype(a0)
	bne	.notWAVE

; locate the common chunk

	move.l	a0,a2

	move.w	#1024,d1
.loopCOMM
	subq.l	#1,d1
	ble	.notWAVE
	addq.l	#1,a2
	cmpi.l	#'fmt ',(a2)
	bne	.loopCOMM

; common chunk found if this point reached

	addq.l	#8,a2	; bypass chunk name/length

	move.w	(a2)+,d0
	cmpi.w	#$100,d0	; standard wav?
	bne	.notWAVE	; if not then not supported

	move.w	(a2)+,d0
	ror.w	#8,d0
	move.w	d0,sampleChannels(a1)

	move.b	3(a2),d0
	rol.l	#8,d0
	move.b	2(a2),d0
	rol.l	#8,d0
	move.b	1(a2),d0
	rol.l	#8,d0
	move.b	(a2),d0	; frequency
	move.l	d0,sampleFrequency(a1)
	addq.l	#4,a2

	addq.l	#6,a2

	move.w	(a2),d0
	ror.w	#8,d0
	move.w	d0,sampleResolution(a1)

; set header size by finding SSND chunk

	move.l	a0,a2
	move.w	#1024,d1
.loopSSND
	subq.w	#1,d1
	ble	.notWAVE
	addq.l	#1,a2
	cmpi.l	#'data',(a2)
	bne	.loopSSND

	addq.l	#4,a2	; bypass chunk name

	move.l	sampleDataSize(a1),d0
	move.b	3(a2),d1
	rol.l	#8,d1
	move.b	2(a2),d1
	rol.l	#8,d1
	move.b	1(a2),d1
	rol.l	#8,d1
	move.b	(a2),d1
	sub.l	d1,d0
	addq.l	#8,d0

	move.w	d0,sampleHeaderSize(a1)
	sub.l	d0,sampleDataSize(a1)

	move.w	#0,sampleSigned(a1)

	moveq.w	#1,d0	; set to found
	rts
.notWAVE
	moveq.w	#0,d0	; set to not found
	rts
;===============================================================================
loadSample	; memory has already been reserved and the data
	; loaded, this part is for any decoding that may
	; need to be done (such as byte swapping)

	cmpi.w	#16,sampleResolution(a1)
	beq	.byteSwap

	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.sign
	move.l	d1,a0
	move.l	d2,d0
.sign
	move.b	(a0),d2
	eor.b	#$80,d2
	move.b	d2,(a0)+
	subq.l	#1,d0
	bgt	.sign

	move.w	#1,sampleSigned(a1)

	rts
.byteSwap
	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.bs
	move.l	d1,a0
	move.l	d2,d0
.bs
	move.w	(a0),d2
	move.b	d2,d3
	rol.w	#8,d3
	ror.w	#8,d2
	move.b	d2,d3
	move.w	d3,(a0)+
	subq.l	#2,d0
	bgt	.bs
	rts
;===============================================================================
saveSample	; no need to actually write data to the file
	; as with loading this part is for any encoding that
	; may need to be done

	tst.w	sampleSigned(a1)
	beq	.noSign
	cmpi.w	#16,sampleResolution(a1)
	beq	.byteSwap

	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.sign
	move.l	d1,a0
	move.l	d2,d0
.sign
	move.b	(a0),d2
	eor.b	#$80,d2
	move.b	d2,(a0)+
	subq.l	#1,d0
	bgt	.sign
.noSign
	cmpi.w	#16,sampleResolution(a1)
	beq	.sign16c
	rts

.sign16c
	tst.w	sampleSigned(a1)
	bne	.byteSwap
	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.sign16
	move.l	d1,a0
	move.l	d2,d0
.sign16
	move.w	(a0),d2
	eor.w	#$4000,d2
	move.w	d2,(a0)+
	subq.l	#2,d0
	bgt	.sign16
.byteSwap
	move.l	sampleAddress(a1),a0
	move.l	sampleDataSize(a1),d0
	tst.w	sampleMode(a1)
	beq	.bs
	move.l	d1,a0
	move.l	d2,d0
.bs
	move.w	(a0),d2
	move.b	d2,d3
	rol.w	#8,d3
	ror.w	#8,d2
	move.b	d2,d3
	move.w	d3,(a0)+
	subq.l	#2,d0
	bgt	.bs
	rts
;===============================================================================
updateHeader	; Construct a new header to ensure a correct header

	move.l	#'RIFF',(a0)+

	move.l	sampleDataSize(a1),d0
	add.l	#36,d0	; +header size -8
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+	; size of file

	move.l	#'WAVE',(a0)+

	move.l	#'fmt ',(a0)+
	move.b	#$10,d0
	rol.l	#8,d0
	rol.l	#8,d0
	rol.l	#8,d0
	move.l	d0,(a0)+	; size of chunk

	move.w	#$0100,(a0)+	; type of wave

	move.w	sampleChannels(a1),d0
	rol.w	#8,d0
	move.w	d0,(a0)+	; channels

	move.l	sampleFrequency(a1),d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+	; frequency

	move.w	sampleChannels(a1),d0
	ext.l	d0
	move.w	sampleResolution(a1),d1
	ext.l	d1
	move.l	d1,d2
	bsr	long_mul
	move.l	d2,d1
	bsr	long_mul
	move.l	#8,d1
	exg	d1,d0
	bsr	long_div
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+	; avg bytes per sec

	move.w	sampleChannels(a1),d0
	ext.l	d0
	move.w	sampleResolution(a1),d1
	ext.l	d1
	bsr	long_mul
	move.l	#8,d1
	exg	d1,d0
	bsr	long_div
	move.b	d0,(a0)+
	ror.w	#8,d0
	move.b	d0,(a0)+	; block align

	move.w	sampleResolution(a1),d0
	move.b	d0,(a0)+
	ror.w	#8,d0
	move.b	d0,(a0)+	; resolution

	move.l	#'data',(a0)+
	move.l	sampleDataSize(a1),d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+
	ror.l	#8,d0
	move.b	d0,(a0)+	; size of data

	move.w	#44,sampleHeaderSize(a1)

	rts

	include	D:\develop\new_libs\div_mul.s