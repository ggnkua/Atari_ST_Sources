; Sam-Edit 2 version 2.0 IFF module
; for Devpac 3

	OUTPUT	D:\SamEdit2\MODULES\IFF.SEM

	SECTION	data

moduleName		dc.b	'IFF Module ',0
moduleAuthor		dc.b	'D.A.Knight',0
moduleVersion	dc.b	'0.3 (17/06/1998)',0
moduleFunctions	dc.w	%01111
moduleID		dc.b	'IFF',0

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

; IFF header
	rsreset	; form chunk
form	rs.l	1	; Holds "FORM"
flength	rs.l	1	; length of chunk
ftype	rs.l	1	; holds type of form (ie "8SVX")

	rsreset	; Voice8Header chunk
vhdr	rs.l	1	; Holds "VHDR"
clength	rs.l	1	; length of chunk
samples	rs.l	1	; as 8 bit mono = size of data
samples2	rs.l	1	; ignore and set to 0 when creating
samples3	rs.l	1	; ignore and set to 0 when creating
freq	rs.w	1	; sample frequency
noOctaves	rs.b	1	; set to 1
compression	rs.b	1	; 0 = non, 1 = fibonacci-delta
volume	rs.l	1	; 65536 = 1.0 = full volume

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
	bne	.not8SVX

	cmpi.l	#'8SVX',ftype(a0)
	bne	.not8SVX

; locate the Voice8Header chunk

	move.l	a0,a2

	move.w	#1024,d1
.loopVHDR
	subq.l	#1,d1
	ble	.not8SVX
	addq.l	#1,a2
	cmpi.l	#'VHDR',(a2)
	bne	.loopVHDR

; VHDR chunk found if this point reached

	move.w	#1,sampleChannels(a1)
	move.w	#1,sampleSigned(a1)

	move.w	#8,sampleResolution(a1)

	move.w	freq(a2),d0
	ext.l	d0
	move.l	d0,sampleFrequency(a1)

	move.w	#1,sampleSigned(a1)

; set header size by finding BODY chunk

	move.l	a0,a2
	move.w	#1024,d1
.loopBODY
	subq.w	#1,d1
	ble	.not8SVX
	addq.l	#1,a2
	cmpi.l	#'BODY',(a2)
	bne	.loopBODY

	move.l	sampleDataSize(a1),d0
	move.l	4(a2),d1
	sub.l	d1,d0
	addq.l	#8,d0

	move.w	d0,sampleHeaderSize(a1)
	sub.l	d0,sampleDataSize(a1)

	moveq.w	#1,d0	; set to found
	rts
.not8SVX
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
	add.l	#40,d0
	move.l	d0,(a0)+
	move.l	#'8SVX',(a0)+

	move.l	#'VHDR',(a0)+
	move.l	#20,(a0)+
	move.l	sampleDataSize(a1),(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	sampleFrequency(a1),d0
	move.w	d0,(a0)+
	move.b	#1,(a0)+
	clr.b	(a0)+
	move.l	#65536,(a0)+

	move.l	#'BODY',(a0)+
	move.l	sampleDataSize(a1),(a0)

	move.w	#48,sampleHeaderSize(a1)
	rts